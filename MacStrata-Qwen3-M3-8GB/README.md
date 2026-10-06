# MacStrata-Qwen3-M3-8GB

A reproducible macOS/Apple-Silicon project for experimenting with **Qwen3-30B-A3B Q4_K_M** on an **8 GB M3 MacBook Air** using a disk-backed MoE expert residency runtime.

## What is included

This repository contains the supplied MacStrata v0.1 storage/cache prototype, a reproducible build/test setup, an exact pinned llama.cpp experimental runtime reference, a Qwen model manifest with SHA-256, and one-command installation/run scripts.

The inference runtime is pinned to `kisasexypantera94/llama.cpp` commit `41ec4c4e94fd5ff6c258691f35f2fcd0d3dde892` on `moe-expert-residency`. That PoC implements a compact Metal expert slot pool and on-demand expert loading from the GGUF file. Its documented run path uses `--moe-n-slots`, `--moe-n-layers`, `--no-mmap` and `--no-warmup`.

**Important:** the supplied MacStrata v0.1 library is included as a standalone cache/storage prototype and benchmark. It is not falsely presented as the hot-path implementation inside llama.cpp. The actual inference path is the pinned llama.cpp MoE-residency branch.

## Target profile

Qwen3-30B-A3B has 48 hidden layers, 128 experts and activates 8 experts per token. The Q4_K_M GGUF is 18.6 GB. The model binary is therefore not committed to this Git repository; the installer downloads the exact upstream file and verifies its SHA-256.

The first-run profile is deliberately conservative for an 8 GB machine:

- 8 MoE slots per layer
- 48 MoE layers
- ubatch 1 / batch 1
- context 1024
- no mmap for the expert-paging path
- no warmup
- Metal enabled for the non-expert workload

These values are a starting point for an 8 GB Mac, not a performance guarantee.

## One-command installation

From the project directory on your M3 Mac:

```bash
./scripts/install.sh
```

Then:

```bash
./scripts/run_qwen3.sh
```

The model download resumes after interruption and refuses to run if the SHA-256 does not match the pinned file.

## Manual steps

```bash
./scripts/install_m3_8gb.sh
./scripts/download_model.sh
./scripts/self_check.sh
./scripts/run_qwen3.sh
```

## MacStrata prototype

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j
ctest --test-dir build --output-on-failure
./build/macstrata_sim --experts 128 --slots 16 --expert-bytes 1048576 --requests 10000
```

## Sources

- Qwen GGUF: https://huggingface.co/ggml-org/Qwen3-30B-A3B-GGUF
- Qwen3 config: https://huggingface.co/Qwen/Qwen3-30B-A3B/blob/main/config.json
- llama.cpp MoE disk-paging discussion: https://github.com/ggml-org/llama.cpp/discussions/23324
- Apple/unified-memory MoE cache discussion: https://github.com/ggml-org/llama.cpp/issues/20757
- Pinned runtime: https://github.com/kisasexypantera94/llama.cpp/tree/41ec4c4e94fd5ff6c258691f35f2fcd0d3dde892

## License note

The Qwen3 model repository states Apache-2.0. llama.cpp is MIT-licensed. This project does not redistribute the 18.6 GB model binary.
