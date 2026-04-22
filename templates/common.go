// The Computer Language 25.03 Benchmarks Game
// indicates 1-3x slower than .NET for same code complexity,
// but .NET has has up to 3x more memory needs and significant more latency.
// It would be interesting to benchmark Fil-C against Go, since Go does not have
// data race safety, which can in turn create unsoundness.

// https://shane.ai/posts/cgo-performance-in-go1.21/
// Go/Cgo latency
// Benchmark Name          1 core    16 cores
// Inlined Empty func      0.271 ns  0.02489 ns
// Empty func              1.5s ns   0.135 ns
// cgo                     40 ns     4.281 ns
// encoding/json int parse 52.89 ns  5.518 ns
