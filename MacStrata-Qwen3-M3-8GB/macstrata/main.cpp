#include "expert_manager.hpp"
#include <algorithm>
#include <fstream>
#include <iostream>
#include <random>
#include <stdexcept>
#include <string>
#include <vector>

using namespace macstrata;

int main(int argc, char** argv) {
    size_t experts = 128, slots = 16, expert_bytes = 1024 * 1024, requests = 1000;
    std::string path = "/tmp/macstrata-experts.bin";
    for (int i = 1; i < argc; ++i) {
        std::string a = argv[i];
        auto next = [&](size_t& v) {
            if (i + 1 >= argc) throw std::runtime_error("missing value");
            v = std::stoull(argv[++i]);
        };
        if (a == "--experts") next(experts);
        else if (a == "--slots") next(slots);
        else if (a == "--expert-bytes") next(expert_bytes);
        else if (a == "--requests") next(requests);
        else if (a == "--file") {
            if (i + 1 >= argc) throw std::runtime_error("missing value");
            path = argv[++i];
        } else throw std::runtime_error("unknown argument: " + a);
    }
    if (experts == 0 || slots == 0 || expert_bytes == 0) throw std::runtime_error("experts/slots/expert-bytes must be > 0");
    {
        std::ofstream f(path, std::ios::binary | std::ios::trunc);
        if (!f) throw std::runtime_error("cannot create " + path);
        std::vector<char> block(expert_bytes, 0);
        for (size_t i = 0; i < experts; ++i) {
            block[0] = static_cast<char>(i);
            f.write(block.data(), static_cast<std::streamsize>(block.size()));
        }
    }
    std::vector<ExpertRef> manifest;
    manifest.reserve(experts);
    for (size_t i = 0; i < experts; ++i) manifest.push_back({static_cast<uint32_t>(i), i * expert_bytes, expert_bytes});
    ExpertManager mgr(path, manifest, slots);
    std::mt19937 rng(42);
    std::uniform_int_distribution<uint32_t> dist(0, static_cast<uint32_t>(experts - 1));
    for (size_t i = 0; i < requests; ++i) {
        uint32_t id = (i % 10 < 7)
            ? static_cast<uint32_t>(rng() % std::max<size_t>(1, experts / 4))
            : dist(rng);
        (void) mgr.acquire({id});
    }
    const auto s = mgr.stats();
    std::cout << "requests=" << s.requests << " hits=" << s.hits << " misses=" << s.misses
              << " hit_rate=" << (s.requests ? 100.0 * s.hits / s.requests : 0.0) << "%\n"
              << "slots=" << slots << " resident_bytes=" << mgr.resident_bytes() << "\n";
    return 0;
}
