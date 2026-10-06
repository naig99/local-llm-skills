#include "expert_manager.hpp"
#include <cassert>
#include <fstream>
#include <vector>
using namespace macstrata;
int main() {
    const char* p = "/tmp/macstrata-test.bin";
    std::ofstream f(p, std::ios::binary | std::ios::trunc);
    for (int i = 0; i < 4; ++i) {
        std::vector<char> b(16, static_cast<char>(i));
        f.write(b.data(), b.size());
    }
    f.close();
    std::vector<ExpertRef> m;
    for (int i = 0; i < 4; ++i) m.push_back({static_cast<uint32_t>(i), static_cast<uint64_t>(i) * 16, 16});
    ExpertManager x(p, m, 2);
    auto a = x.acquire({0});
    assert(a.size() == 1);
    assert(x.stats().misses == 1);
    x.acquire({0});
    assert(x.stats().hits == 1);
    x.acquire({1});
    x.acquire({2});
    assert(x.stats().evictions == 1);
    assert(x.stats().bytes_read == 48);
    return 0;
}
