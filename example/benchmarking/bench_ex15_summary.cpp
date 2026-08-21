//==Summary
// use good clock
// defeat optimizers
// beware OoO execution
// consider overheads
// example/benchmarking/bench_ex14_branching.cpp
// - branching
// - system behavior
//   * CPU
//   * Kernel
//   * Kernel load
// - approaches to system? embraces vs minimise
// - minimise
//   * noise mitigations
//   * what to measure? best case, typical, bounded worst case
// - sensitivity of task?
// - real workloads > benchmarks
// - in-situ stats
// - benchmarking vs profiling
// - profile: why that fast?
// - perf
// - tools
// - rule of thumb on single optimisations

// Problems
// * compiler: can eliminate work
// * cpu: predicts overlaps work
// * caches can make data unrealistically fast
// * os can interrupt measurement
// * clock itself has overhead

// Solutions
// * compiler limits, workaround them
// * clock choice + tradeoff
// * cpu suprises (BPU, OoO, cache)
// * know your sensitivity
// * distribution: fastest? bounded?
// * tools: catch2, gbench, in-situ
