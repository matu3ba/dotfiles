// data oriented design strategies for C++
// zig c++ -std=c++20 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-switch-default ./templates/dod.cpp -o ./build/dod.exe && ./build/dod.exe
// zig c++ -std=c++26 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-switch-default ./templates/dod.cpp -o ./build/dod.exe && ./build/dod.exe
// clang++ -std=c++20 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-switch-default ./templates/dod.cpp -o ./build/dod.exe && ./build/dod.exe
// clang++ -std=c++26 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-switch-default ./templates/dod.cpp -o ./build/dod.exe && ./build/dod.exe

// https://johnnysswlab.com/memory-subsystem-optimizations/
// https://johnnysswlab.com/the-true-price-of-virtual-functions-in-c/
// https://abseil.io/fast/hints.html
// https://johnfarrier.com/custom-allocators-in-c-high-performance-memory-management/
// * mostly AI generated

// std::set (binary search tree), std::unordered_set (hash table)
// std::vector (unsorted->linear search), std::vector (sorted->binary search)
// CPU cache effect dominate for small size N, so binary search in continuous memory fast
// unfortunately no numbers on std::flat_map and std::flat_set

// M1 costs (2020)
// L1 64-128        KB 3 cycles
// L2 8-12          MB 18 cycles
// L3 8(GPU-shared) MB 18 cycles + 10-15ns
// RAM 16           GB 18 cycles + 100ns

// Write-through cache - write to cache and main memory
// Write-back cache - write to main memory upon cache eviction
// * modern CPUs are usually write-back cache

// sufficient cache size: arithmetic on 1 byte often slower than on 2 bytes, but
// faster than on 4 bytes

// char8_t unsigned 8 bit for UTF-8
// std::byte 8 bit for raw memory access ((signed/unsigned) char has same handling
//   for compat reasons)

// #include <concepts> // NOLINT
// #include <string>
#include <atomic>
#include <cstdint>
#include <cstring>
#include <limits>
#include <memory>
#include <mutex>
#include <print>
#include <shared_mutex>
#include <type_traits>
#include <typeinfo>
#include <utility> // std::true_type, to_underlying
#include <utility>
#include <vector>

// worst, because size() is accessed and thus can not be optimized out
// strict aliasing applies here
// T non-aliasing: modification of data[i] can only modify other T objects
// T aliasing: modification of data[i] may modify arbitrary other objects including
//   std::vector<T> data, including the size field of the vector
// template<typename T>
// requires(sizeof(T) == 1) void pointer_aliasing(std::vector<T> &data) {
//   for (std::size_t i = 0; i < data.size(); i += 1)
//     data[i] = static_cast<T>(int(data[i]) + 1);
// }
// somewhat better, but longer to write
// template<typename T>
// requires(sizeof(T) == 1) void pointer_aliasing(std::vector<T> &data) {
//   auto size = data.size();
//   for (std::size_t i = 0; i < size; i += 1)
//     data[i] = static_cast<T>(int(data[i]) + 1);
// }

// best
template<typename T>
requires(sizeof(T) == 1) void pointer_aliasing(std::vector<T> &data) {
  auto size = data.size();
  for (auto &value : data)
    value = static_cast<T>(int(value) + 1);
}

// classical reordering of members
// alignment = sum up consecutive elements until biggest element of struct
// internal and tail padding used, simpler to use -Wpadded
enum class State : uint8_t { A, B, C };
struct Widget {
  bool is_enabled : 1;
  bool is_visible : 1;
  State state : 2;
  uint8_t _pad : 4;
};
static_assert(sizeof(Widget) == 1, "size of Widget != 1 byte");
// consequentially: T* points to multiple of alignof(T) or nullptr, T& does always
// => lower logs(alignof(T)) bits of T* are always zero and can be used for data

// wasteful, when we only need 1 bit
// class ContainerOrText {
//   bool _is_container;
//   void* _ptr;
//   public:
//   bool is_container() const { return _is_container; }
//   Container* as_container() const { return (Container*)_ptr; }
//   Text* as_text() const { return (Text*)_ptr; }
// };
// static_assert(sizeof(ContainerOrText) == 16, "size of Widget != 1 byte");

// better (here uses pointer alignment, but page sizes could also be used)
class ContainerOrText {
  std::uintptr_t _impl;

public:
  bool is_container() const { return (_impl & 0b1) == 0; }
  // Container *as_container() const { return (Container *)_ptr; }
  // Text *as_text() const { return (Text*)(_impl & ~uintptr_t(0b0); }
};
static_assert(sizeof(ContainerOrText) == 8, "size of Widget != 1 byte");

// minimize RAM access (cache locality)
// * minimize type sizes
// * move uninteresting data away
// ensure cache line alignment; specifically on sharing, false sharing and with atomics
// prefetcher detects linear memory access patterns; complex ones depend on hardware
// * predicable access via sequential memory access

// cache friendly:
// * std::vector<T>
// * C++23 std::flat_map<K,V> and std::flat_set<K,V>
// * hash tables with open addressing(vector as data) like absl::flat_hash_map/flat_hash_set
//   Open Address Hash Map (not std::unsorted_map)
// * some implementations of std::deque<T>
// maybe cash friendly: std::deque<T, BLK_SIZE> (BLK_SIZE must be high enough)
// no cache friendly: std::list<T>/(unordered_)map<K,V>/(unordered_)set<T>
// * https://abseil.io/blog/20180927-swisstables

// L1 cache separated between code and data
// L2 cache shared between code and data
// can result in weird results

// For weird reasons faster than swapping to first do increment and then do if
// check on Apple M1
// void increments_then_sum(std::vector<unsigned> const &data) {
//   auto count = 0;
//   for (auto d : data) {
//     if (d == 0) { // rarely true
//       REPEAT64(benchmark::DoNotOptimize(++count));
//     }
//     count += d;
//   }
//   benchmark::DoNotOptimize(++count);
// }

// data access patterns
// * access data in linear order
// * avoid pointer chasing
// * minimize size of data

// code patterns
// * avoid long branches, indirect jumps
// * minimize size of hot code
// => avoid virtual fn calls, if possible, because prefetcher can't help you much
// => looks like Jonathan did not measure ARM pointer prefetches due to having no
// ARM M2 or M3

// data oriented design
// * focus on algos with data transformations
//   => design algos first
//   => use vectors and do index lookups
// * algos operate on dumb data without behavior
// * multiple homogenous collection of different record
enum class Age : std::size_t {
  Ok = 0,
  Bad = 1,
};
struct People {
  std::vector<std::string> const names;
  std::vector<Age> const ages;
};

Age average_age(std::vector<Age> const &ages);
std::size_t index_of_oldest_person(std::vector<Age> const &ages);
std::size_t index_of_oldest_person(std::vector<Age> const &ages) {
  std::underlying_type_t<Age> tyAge = std::to_underlying(ages[0]);
  (void)tyAge;
  auto index = ages.size();
  for (auto rit = ages.rbegin(); rit != ages.rend(); (++rit, --index)) {
    switch (*rit) {
      case Age::Bad:
        continue;
      case Age::Ok:
        return index;
    }
  }
  return std::numeric_limits<std::size_t>::max();
}
std::string_view name_of_oldest_person(std::vector<std::string_view> const &names, std::vector<Age> const &ages);
std::string_view name_of_oldest_person(std::vector<std::string_view> const &names, std::vector<Age> const &ages) {
  auto index = index_of_oldest_person(ages);
  return names[index];
}

// tagged union via std::vector<std::variant<Circle, Square>> also stores tag
// here: 1 bit + padding is a full byte
// multiple homogenous vectors best std::vector<Circle>, std::vector<Square>
// operate on N elements, not single elements

// avoid false sharing
// template<typename T> void parallel_fold() {
//   std::vector<T> local_results(pool.thread_count());
//   pool.run([&](std::size_t thread_idx) { local_results[thread_idx] = fold(work.slice(thread_idx)); });
//   T global_result = fold(local_results);
// }
// void accumulate_fib(unsigned &result, unsigned n) {
//   if (n < 2) {
//     result += n;
//   } else {
//     accumulate_fib(result, n - 1);
//     accumulate_fib(result, n - 2);
//   }
//
//   intel platforms load/store 2 cache lines each, but only 1 cache lines is invalidated
//   constexpr auto alignment = std::hardware_desstructive_interference_size / sizeof(unsigned);
//   std::vector<unsigned> results(thread_count * alignment);
//   for (auto _ : state) {
//     pool.run([&](std::size_t thread_idx) {
//       auto local = 0u;
//       results[thread_id] = 0;
//       for (auto i = 0; i != 1024 / thread_count; i += 1)
//         accumulate_fib(results[thread_id * alignment], id % 20);
//       results[thread_id] = local;
//     });
//     benchmark::DoNotOptimize(result);
//   }
// }

// SIMD
// * not portable even though LLVM has portable SIMD
// * in theory lowering to SWAR or fallback possible

// constexpr everything

// narrowing conversion workaround https://stackoverflow.com/questions/36270158/avoiding-narrowing-conversions-with-c-type-traits
template<typename From, typename To>
concept is_narrowing_conversion = !requires(From f) { To{f}; };
template<typename From, typename To>
concept is_non_narrowing = !is_narrowing_conversion<From, To>;

// explicit constructors by default
// ideal: remove copy, assign, move constructors
class Second {
public:
  // constexpr Second() = default; // default construction of constructors + operators
  explicit Second() = delete;

  // before:
  // explicit constexpr Second(double value)
  // after (prevents implicit conversion)
  template<typename U>
  // requires no_narrowing_conversion<U, double> does not exist yet
  // requires std::same_as<U, double>
  requires std::same_as<U, double> explicit constexpr Second(U value)
      : value_{value} {
    // checks
  }
  // before:
  // constexpr Second &operator=(double value)
  // after (prevents narrowing)
  template<typename U>
  // requires no_narrowing_conversion<U, double> does not exist yet
  // requires std::same_as<U, double>
  requires std::same_as<U, double> constexpr Second &operator=(U value) {
    // checks
    value_ = value;
    return *this;
  }
  [[nodiscard]] constexpr double value() const { return value_; }

private:
  double value_{};
};

// strong types
template<typename T, typename Parameter> class NamedType {
public:
  explicit NamedType(T const &value)
      : value_(value) {}
  explicit NamedType(T &&value)
      : value_(std::move(value)) {}
  T &get() { return value_; }
  T const &get() const { return value_; }

private:
  T value_;
};
// major annoyance
using Meter = NamedType<long double, struct MeterParameter>;
using Width = NamedType<Meter, struct WidthParameter>;
using Height = NamedType<Meter, struct HeightParameter>;
// SHENNANIGAN used defined literals are constrained to use
// Meter operator""_meter(uint64_t length) { return Meter(length); }
static Meter operator""_meter(long double length) { return Meter(length); }

class Rectangle {
public:
  Rectangle(Width, Height) {
    // do nothing
  }
};

// destructive moves
// after-thought in C++, compiler may or may not optimize away destructor of moved object
// S&  lvalue                                           var, a[42], foo->bar
// S&& prvalues not allowed to take address of values   S{}, &var, byval()
//     xvalue std::move/                                static_cast<S&&>(lvalue)
//     rvalue: prvalue or xvalue
//     glvalue: lvalue or rvalue
// S const&    lvalue or rvalue
// S const&&   rvalue [only relevant for very generic library code]
// * dont try destructive moves for stack-values, because it is very error-prone
// * best practice: test via static_assert that types are "trivially relocatable",
//   but unfortunately they did not make it into C++26
//   * not possible, if address is part of objects state
//   * folly:fbvector<MyType> v treats vector as relocatable for optimizations
//   namespace folly {
//     struct IsRelocatable<MyType> : std::true_type {};
//   }
//   Unit Engine assumes and uses property automatically: TArray<FMyType> v
//   * workarounds:
//     memcpy only allowed for std::is_trivially_moveable
//     std::is_default_constructible
//     is_trivially_default_constructible
//     is_nothrow_default_constructible
//     std::is_copy_constructible
//     std::is_move_constructible
//   * general rules
//     delete copy constructor
//     std::swap trades speed for memory savings, but does not solve destructive moves
//     problem

// TODO check out c++ libraries offering destructive moves how to implement it
// https://0xghost.dev/blog/std-move-deep-dive/
// https://0xghost.dev/blog/template-parameter-deduction/
// TODO use code for this https://lobste.rs/s/n9tev4/who_owns_memory_part_2_who_calls_free#c_863kc6
class DestrMoves {
  char expensive_resource;

public:
  DestrMoves(DestrMoves const &value) = delete;
  DestrMoves(DestrMoves &&other) = delete;
  explicit constexpr DestrMoves(char value)
      : expensive_resource(value) { // checks
  }
  void print() {
    std::string s1 = std::format("The answer is {}.", expensive_resource);
    std::print(stdout, "{}\n", s1);
  }
  constexpr DestrMoves &operator=(char value) noexcept {
    expensive_resource = value;
    return *this;
  }
  // DestrMoves(DestrMoves const &other)
  //     : expensive_resource(other.expensive_resource) {}
};

// allocator usage, see example/allocator.cpp

// ranges for loop fusion
// std::vector<int> get_ids_adult_users(std::vector<user_t>& users) {
//     auto ids = users | std::views::filter([](auto const& user){ return user.age >= 18; })
//                      | std::views::transform([](auto const& user){ return user.id; });
//     return {ids.begin(), ids.end()}
// }
// Kernel Fusion

// Compiler optimizations
// Overview https://en.wikipedia.org/wiki/Optimizing_compiler
// https://johnnysswlab.com/loop-optimizations-interpreting-the-compiler-optimization-report/
// compiler optimization report
// clang -O2 -Rpass=.* code.cc -o code
// and -Rpass-analysis, -Rpass-missed
// clang -emit-llvm-bc -o /dev/null -mllvm -print-pipeline-passes -O0
// godbolt.org dogbolt.org like output
//   objdump -dxS -Mintel binary
// clang -fproc-stat-report=abc foo.c
// clang -c foo.c -o foo.o -O3 -fsave-optimization-record
// llvm-opt-report foo.opt.yaml -o foo.lst
// and -foptimization-record-file, -f[no-]diagnostics-show-hotness

// https://johnfarrier.com/powerful-tips-and-techniques-for-stdmutex-in-c/
// 1 mutex handling
// * double locking, unlocking by different thread, not unlocking
// 2 types of mutexes
// * std::mutex           exclusive, non-recursive ownership
// * std::timed_mutex     lock mutex for specified period or until a specific time point
// * std::recursive_mutex allows same thread to acquire mutex without causing deadlock
// 3 types of locks
// * std::lock_guard   asdasd
// * std::unique_lock
// * std::shared_lock
// * std::scoped_lock
// * Spin Locks
// * std::barrier
// * std::mutex and std::condition_variable

// Avoid Spurious Wakes
// Minimal Scope
// Clear Signaling
// Consistent Locking Order
// std::lock()

// performance checklist https://johnfarrier.com/c-performance-checklist-for-low-latency-systems/
// 1 mindset
//   * branch prediction
//   * every conditional in hot path as perf risk
//   * prefer predictability over flexibility, no unnecessary indirection/generic dispatch
// 2 code structuring for prediction
//   * branches follow stable patterns
//   * split cold and hot paths into separate fns
//   * flatten nested branches into simpler structures (luts, state machines)
//   * prefer direct branches over indirect branches (virtual calls, fn ptrs) in tight loops
// 3 data handling
//   * pre-sort or batch-process data
//   * avoid mixing random data-dependent branches (directly) into perf-critical loops
//   * avoid branches depending directly on timestamps, random numbers, or external entropy sources
// 5 compiler hints and optimizations
//   * [[likely]] and [[unlikely]]
//   * enable PGO
//   * correct optimization flags like -O3 -march=native
// 6 branch removal
//   * replace simple branches with conditional moves (cmov) where supported
//     TODO check how to do this in practice https://kristerw.github.io/2022/05/24/branchless/
//   * branchless algo tricks (masks, bit shifts, etc) to remove predictable conditionals
//   * use for logic LUTs, where applicable
// 7 measurement and analysis
//   * tools
//     - perf (Linux)
//     - VTune (Intel)
//     - Callgrind (Valgrind)
//     - IACA(Intel Architecture Code Analyzer)
//   * track branch miss-rate alongside latencies in production, automate alerts, if
//     misprediciton rate cross acceptable thresholds
//   * use celero or other for targeted microbenchmarking of specific branches or logic blocks
//   * compare prediction rates across different compilers, flags, hw platforms
// 8 continuous monitoring
//   * periodic branch miss rate profiling to CI perf monitoring pipelines
//   * compare branch miss spikes against unknown latency outliers,
//     for example correlation of misprediction with P99+ spikes
// 9 review checklist for each hot path
//   * how many branches in this path?
//   * any branches data dependent?
//   * virtual calls or fn pointers inside tight loops?
//   * hot and old paths clearly separated?
//   * do branches follow predictable patterns?
//   * have you measured branch miss rates before and after optimizations

// https://johnfarrier.com/branch-prediction-the-definitive-guide-for-high-performance-c/
// TODO branch predictions

// https://johnnysswlab.com/vectorization-dependencies-and-outer-loop-vectorization-if-you-cant-beat-them-join-them/
// https://johnnysswlab.com/decreasing-the-number-of-memory-accesses-1-2/
// https://johnnysswlab.com/decreasing-the-number-of-memory-accesses-the-compilers-secret-life-2-2/
// https://johnnysswlab.com/horrible-code-clean-performance/

// C++: Some Assembly Required - Matt Godbolt - CppCon 2025 https://www.youtube.com/watch?v=zoYT7R94S3c
// Building Secure C++ Applications: A Practical End-to-End Approach - CppCon 2025  https://www.youtube.com/watch?v=GtYD-AIXBHk
// More Speed & Simplicity: Practical Data-Oriented Design in C++ - Vittorio Romeo - CppCon 2025 https://www.youtube.com/watch?v=SzjJfKHygaQ
// Microarchitecture: What Happens Beneath https://www.youtube.com/watch?v=BVVNtG5dgks
// Deep dive into training performance https://www.youtube.com/watch?v=pHqcHzxx6I8
// https://xania.org/Coding

//spinlock
static std::atomic_flag spinlock = ATOMIC_FLAG_INIT;
static void spinlock_acquire() {
  while (spinlock.test_and_set(std::memory_order_acquire)) {
    // Spin: Keep looping until the spinlock is released
  }
}
static void spinlock_release() { spinlock.clear(std::memory_order_release); }

int main() {
  // Second s{42};
  Second sec{42.0};
  sec = 12.0;
  // s = 12; // or use compiler checks
  (void)sec;

  Rectangle rec{Width(10.0_meter), Height(12.0_meter)};
  (void)rec;

  DestrMoves destrmov_a{'a'};
  DestrMoves destrmov_b{'b'};
  // destrmov_b = std::move(destrmov_a);
  // auto c = DestrMoves('a'); // create object and move a into c
  destrmov_a.print();
  destrmov_b.print();

  std::mutex mtx;
  std::timed_mutex tmtx;
  std::recursive_mutex rec_mtx;
  std::recursive_timed_mutex rec_timed_mtx;
  std::shared_mutex shared_mtx;
  std::mutex m1, m2;

  std::condition_variable cv;

  { // simple mutex
    std::lock_guard<std::mutex> lock(mtx);
    // Minimized critical section
  }
  {
    std::unique_lock<std::mutex> lock(mtx);
    // critical section
    lock.unlock(); // manually unlock
    // non-critical section
    lock.lock(); // manually unlock
    // critical section
  }
  // timed_mutex
  if (tmtx.try_lock_for(std::chrono::seconds(1))) {
    std::print("Acquired lock within 1 second!\n");
    tmtx.unlock();
  } else {
    std::print("Failed to acquire lock within 1 second!\n");
  }
  // recursive_mutex
  {
    std::lock_guard<std::recursive_mutex> lock(rec_mtx);
    int count = 0;
    if (rec_timed_mtx.try_lock_for(std::chrono::milliseconds(100))) {
      // std::string fmtet = std::format("Count: {}", count);
      std::print(stdout, "{}\n", count);
      // std::this_thread::sleep_for(std::chrono::milliseconds(50));
      rec_timed_mtx.unlock();
    } else {
      std::print(stdout, "Failed to acquire lock!\n");
    }
  }

  { //shared_lock
    std::shared_lock<std::shared_mutex> lock(shared_mtx);
    // read-only critical section
  }
  { // scoped_lock
    std::scoped_lock lock(m1, m2);
  }

  { // spinlock
    spinlock_acquire();
    // critical section
    spinlock_release();
  }

  return 0;
}
