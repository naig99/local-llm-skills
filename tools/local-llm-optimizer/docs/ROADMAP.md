# Optimization Roadmap

## Phase 0 — Baseline

Record the current stable configuration and generation throughput.

Known reference:
- Apple Silicon: M3
- Unified memory: 8 GB
- Model: Qwen3-Coder-30B-A3B-Instruct-Q4_K_M.gguf
- MoE slots: 26
- Threads: 8
- Batch: 256
- UBatch: 1
- Context: 1024
- GPU layers: current project setting
- Historical best: ~4.6 tok/s

## Phase 1 — Telemetry

Measure:
- cache hits / misses
- hit rate
- expert bytes read
- number of read tasks
- pread latency
- sidecar wait
- Metal event wait

Do not optimize from guesses.

## Phase 2 — Expert I/O

Investigate whether multiple reads for one logical expert can be made more contiguous or better queued without increasing memory materially.

## Phase 3 — Asynchronous Prefetch

Add prefetch that begins reading predicted experts before the Metal interceptor reaches the hard dependency.

## Phase 4 — Routing Lookahead

Use a prediction-only path to warm likely next-layer experts. Prediction must never change actual routing decisions.

## Phase 5 — Residency / Budget

Keep only a carefully measured hot set resident. Respect the 8 GB unified-memory ceiling.

## Phase 6 — Speculative / MTP

Determine whether this exact model/runtime exposes a compatible draft or MTP path. Only enable after correctness is proven.

## Rule

Every phase must:
1. build successfully,
2. preserve correctness,
3. be benchmarked against the same baseline,
4. be isolated in Git,
5. be reverted when it does not measurably help.
