#pragma once
#include <cstddef>
#include <cstdint>
#include <future>
#include <list>
#include <mutex>
#include <string>
#include <unordered_map>
#include <vector>

namespace macstrata {

struct ExpertRef {
    uint32_t id{};
    uint64_t offset{};
    uint64_t bytes{};
};

struct Slot {
    int index{-1};
    uint32_t expert_id{UINT32_MAX};
    uint64_t bytes{0};
    uint64_t last_use{0};
    bool loading{false};
    std::vector<std::byte> data;
};

struct Stats {
    uint64_t requests{0};
    uint64_t hits{0};
    uint64_t misses{0};
    uint64_t evictions{0};
    uint64_t bytes_read{0};
};

class ExpertStore {
public:
    explicit ExpertStore(std::string path);
    ~ExpertStore();
    ExpertStore(const ExpertStore&) = delete;

    std::vector<std::byte> read(const ExpertRef& ref) const;
    int fd() const { return fd_; }

private:
    int fd_{-1};
    std::string path_;
};

class ExpertManager {
public:
    ExpertManager(std::string file, std::vector<ExpertRef> manifest,
                  std::size_t slot_count);

    std::vector<int> acquire(const std::vector<uint32_t>& expert_ids);
    void prefetch(const std::vector<uint32_t>& expert_ids);

    Stats stats() const;
    std::size_t resident_bytes() const;
    std::size_t slot_count() const { return slots_.size(); }

private:
    int find_slot_locked(uint32_t expert_id) const;
    int choose_victim_locked();
    void touch_locked(int slot);
    void load_into_slot_locked(int slot, const ExpertRef& ref);

    ExpertStore store_;
    std::unordered_map<uint32_t, ExpertRef> manifest_;
    std::vector<Slot> slots_;
    std::list<int> lru_;
    std::unordered_map<uint32_t, std::shared_future<void>> inflight_;
    mutable std::mutex mutex_;
    uint64_t clock_{0};
    Stats stats_{};
};

} // namespace macstrata
