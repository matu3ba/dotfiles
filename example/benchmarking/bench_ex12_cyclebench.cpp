//==delta benchmarking
// base = overhead + N x cost
auto const base = measure(N);
// bench = overhead + 2*N x cost
auto const bench = measure(N * 2);
// result = (overhead + 2N x cost) - overhead + N x cost
//        = N x cost
auto const result = (bench - base) / N;
// cancel overhead
