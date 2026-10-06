#include "expert_manager.hpp"
#include <algorithm>
#include <cerrno>
#include <cstring>
#include <fcntl.h>
#include <future>
#include <stdexcept>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

namespace macstrata {

ExpertStore::ExpertStore(std::string path) : path_(std::move(path)) {
    fd_ = ::open(path_.c_str(), O_RDONLY);
    if (fd_ < 0) throw std::runtime_error("cannot open expert file: " + path_ + ": " + std::strerror(errno));
}
ExpertStore::~ExpertStore() { if (fd_ >= 0) ::close(fd_); }

std::vector<std::byte> ExpertStore::read(const ExpertRef& ref) const {
    std::vector<std::byte> out(static_cast<size_t>(ref.bytes));
    size_t done = 0;
    while (done < out.size()) {
        ssize_t n = ::pread(fd_, out.data() + done, out.size() - done,
                            static_cast<off_t>(ref.offset + done));
        if (n < 0) {
            if (errno == EINTR) continue;
            throw std::runtime_error("pread failed: " + std::string(std::strerror(errno)));
        }
        if (n == 0) throw std::runtime_error("unexpected EOF while reading expert");
        done += static_cast<size_t>(n);
    }
    return out;
}

ExpertManager::ExpertManager(std::string file, std::vector<ExpertRef> manifest,
                             std::size_t slot_count)
    : store_(std::move(file)), slots_(slot_count) {
    if (slot_count == 0) throw std::invalid_argument("slot_count must be > 0");
    for (const auto& e : manifest) manifest_[e.id] = e;
    for (size_t i = 0; i < slots_.size(); ++i) {
        slots_[i].index = static_cast<int>(i);
        lru_.push_back(static_cast<int>(i));
    }
}

int ExpertManager::find_slot_locked(uint32_t expert_id) const {
    for (const auto& s : slots_) if (s.expert_id == expert_id && !s.loading) return s.index;
    return -1;
}

int ExpertManager::choose_victim_locked() {
    for (const auto& s : slots_) if (s.expert_id == UINT32_MAX && !s.loading) return s.index;
    return lru_.back();
}

void ExpertManager::touch_locked(int slot) {
    slots_[slot].last_use = ++clock_;
    lru_.remove(slot);
    lru_.push_front(slot);
}

void ExpertManager::load_into_slot_locked(int slot, const ExpertRef& ref) {
    auto data = store_.read(ref);
    auto& s = slots_[slot];
    if (s.expert_id != UINT32_MAX) ++stats_.evictions;
    s.data = std::move(data);
    s.expert_id = ref.id;
    s.bytes = ref.bytes;
    stats_.bytes_read += ref.bytes;
    touch_locked(slot);
}

std::vector<int> ExpertManager::acquire(const std::vector<uint32_t>& expert_ids) {
    std::lock_guard<std::mutex> lock(mutex_);
    std::vector<int> result;
    result.reserve(expert_ids.size());
    for (uint32_t id : expert_ids) {
        ++stats_.requests;
        int slot = find_slot_locked(id);
        if (slot >= 0) {
            ++stats_.hits;
            touch_locked(slot);
            result.push_back(slot);
            continue;
        }
        ++stats_.misses;
        auto it = manifest_.find(id);
        if (it == manifest_.end()) throw std::out_of_range("unknown expert id");
        slot = choose_victim_locked();
        load_into_slot_locked(slot, it->second);
        result.push_back(slot);
    }
    return result;
}

void ExpertManager::prefetch(const std::vector<uint32_t>& expert_ids) {
    std::vector<uint32_t> todo;
    {
        std::lock_guard<std::mutex> lock(mutex_);
        for (auto id : expert_ids) {
            if (find_slot_locked(id) >= 0 || manifest_.find(id) == manifest_.end()) continue;
            todo.push_back(id);
        }
    }
    for (auto id : todo) {
        std::async(std::launch::async, [this, id] { try { acquire({id}); } catch (...) {} });
    }
}

Stats ExpertManager::stats() const {
    std::lock_guard<std::mutex> lock(mutex_);
    return stats_;
}

std::size_t ExpertManager::resident_bytes() const {
    std::lock_guard<std::mutex> lock(mutex_);
    size_t n = 0;
    for (const auto& s : slots_) n += s.data.size();
    return n;
}

} // namespace macstrata
