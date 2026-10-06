# Local LLM Optimizer

External control/measurement tool for the local Qwen3-Coder 30B-A3B setup on Apple Silicon.

## Target

Current known baseline: ~4.6 tok/s generation on MacBook Air M3 8 GB.

Stretch target: 10+ tok/s.

The optimizer does not replace or fork the model project. It operates on an existing checkout supplied by `TARGET_PROJECT`.

## Safety

- Never reset, clean, or overwrite the target repository automatically.
- Changes are applied only when an explicit patch command is used.
- Benchmarks are read-only.
- Every optimization should be isolated in its own Git commit in the target project.
- Nested repositories such as `third_party/llama.cpp` must be treated independently.

## Usage

```bash
cp config.env.example config.env
# edit TARGET_PROJECT if needed

./optimizer.sh inspect
./optimizer.sh benchmark
```

For future patches:

```bash
./optimizer.sh patch <path-to-patch>
```

The first optimization stage is telemetry; measurements decide the next change.
