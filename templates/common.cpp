#include <algorithm>
#include <array>
#include <array>
#include <atomic>
#include <cstdio>
#include <map>
#include <mutex>
#include <string>
#include <vector>

#include <cstring> // C++ has no string split method, so use strok() or strsep()
/// logging (better would be test based and scoped macros)
#define DEBUG_FN_ENTER(message)                                                                                   \
    if (debug)                                                                                                    \
    {                                                                                                             \
        debug_nesting += 1;                                                                                       \
        std::cout << message << ": " << debug_nesting << "\n";                                                    \
    }

#define DEBUG_FN_EXIT(message)                                                                                    \
    if (debug)                                                                                                    \
    {                                                                                                             \
        std::cout << message << ": " << debug_nesting << "\n";                                                    \
        debug_nesting -= 1;                                                                                       \
    }
#define DEBUG_COUT(message)                                                                                       \
    if (debug)                                                                                                    \
    {                                                                                                             \
        std::cout << message << "\n";                                                                             \
    }
#define DEBUG_COUT_SAMELINE(message)                                                                              \
    if (debug)                                                                                                    \
    {                                                                                                             \
        std::cout << message;                                                                                     \
    }

/// taken from boost hash_combine, only ok for <10% of used range, optimized for performance
inline void hash_combine(unsigned long &seed, unsigned long const &value)
{
    seed ^= value + 0x9e3779b9 + (seed << 6) + (seed >> 2);
}
// TODO: get better non-cryptographic hash

// Macros for creating enum + string for lookup up to 256 values from https://stackoverflow.com/a/5094430
// Usage:
// DEFINE_ENUM_WITH_STRING_CONVERSIONS(OS_type, (Linux)(Apple)(Windows))
// OS_type t = Windows;
// std::cout << ToString(t) << " " << ToString(Apple) << std::endl;
// Might get superfluous with new C standard (C2x).
#define X_DEFINE_ENUM_WITH_STRING_CONVERSIONS_TOSTRING_CASE(r, data, elem)                                        \
    case elem:                                                                                                    \
        return BOOST_PP_STRINGIZE(elem);

#define DEFINE_ENUM_WITH_STRING_CONVERSIONS(name, enumerators)                                                    \
    enum name                                                                                                     \
    {                                                                                                             \
        BOOST_PP_SEQ_ENUM(enumerators)                                                                            \
    };                                                                                                            \
                                                                                                                  \
    inline const char *ToString(name v)                                                                           \
    {                                                                                                             \
        switch (v)                                                                                                \
        {                                                                                                         \
            BOOST_PP_SEQ_FOR_EACH(X_DEFINE_ENUM_WITH_STRING_CONVERSIONS_TOSTRING_CASE, name, enumerators)         \
            default:                                                                                              \
                return "[Unknown " BOOST_PP_STRINGIZE(name) "]";                                                  \
        }                                                                                                         \
    }

// defer-like behavior in C++
#include <openssl/err.h>
#include <openssl/evp.h>
#include <memory>
using EVP_CIPHER_CTX_free_ptr = std::unique_ptr<EVP_CIPHER_CTX, decltype(&::EVP_CIPHER_CTX_free)>;

unsigned char* encrypt(unsigned char* plaintext, int plaintext_len, unsigned char key[16], unsigned char iv[16]) {
    // equivalent of c++
    // EVP_CIPHER_CTX *ctx = try { EVP_CIPHER_CTX_new(); }
    // with equivalent of Zig
    // defer EVP_CIPHER_CTX_free(ctx);
    EVP_CIPHER_CTX_free_ptr ctx(EVP_CIPHER_CTX_new(), ::EVP_CIPHER_CTX_free);

    std::unique_ptr<int[]> p(new int[10]);
    std::unique_ptr<unsigned char[]> p2(new unsigned char[plaintext_len]);

    // main problem: throw not forced to be handled locally and hidden control
    // other problem: we cant only defer on error to provide ctx to another function
    return NULL;
}

// SHENNANIGAN: default values prevent the class from being an aggregate, so
// list initialization breaks with a very unhelpful message like:
// error: could not convert xxx from race-enclosed initializer list
//
// The lsp is even worse/more unhelpful claiming "no matching constructor" without
// bothering any explanation.

// map only works with iterators AND SHOULD ONLY BE USED WITH ITERATORS, see below
// This is extremely easy to miss,
void iter() {
    std::map<int, std::string> mapexample;
    mapexample[1] = "t1";
    mapexample[2] = "t2";
    for (auto iter = std::cbegin(mapexample); iter != std::cend(mapexample); ++iter) {
        printf("mapexample period.uiStartPeriod: %d %s", iter->first, iter->second.c_str());
    }
}

void sortarray() {
    std::array<int, 5> arr_x {{0,1,2,3,4}};
    std::sort(arr_x.begin(), arr_x.end()); // cbegin, cend
}

void sortarray_lambda_expression() {
    std::array<int, 5> arr_x {{0,1,2,3,4}};
    std::sort(arr_x.begin(), arr_x.end(), [](int a, int b)
        {
              if (a < b)
                return true;
              else
                return false;
        });
}

void simpleCAS() {
    std::atomic<bool> is_initialized(false);

    // imagine 2 threads could do stuff with is_initialized

    // CAS: expect atomic transition is_initialized false -> true, no spurious wakeups.
    // atomic equal with expected => replace with desired
    //                       else => load memory into expected
    bool expected = false;
    const bool desired = true;
    is_initialized.compare_exchange_strong(expected, desired);
    if (true == expected) {
        return; // already initialized
    }

}

void always_emplace_back() {
    std::vector<int> someints;
    someints.push_back(1); // might make unnecessary copies, which can be seen in the move call.
    someints.emplace_back(1); // can leverage constructor as arguments
}

// SHENNANIGAN: managed objects like std::string or std::vector require manual
// call of the destructor with active tag and construction of the destructor
// `~Union(){}`.
union S
{
    std::string str;
    std::vector<int> vec;
    ~S() {} // whole union occupies max(sizeof(string), sizeof(vector<int>))
};
int libmain() {
    S s = {"Hello, world"};
    // at this point, reading from s.vec is undefined behavior
    printf("s.str = %s\n", s.str.c_str());
    s.str.~basic_string();
    return 0;
}

bool contains(std::map<int,int>& container, int search_key) {
    // return container.end() != container.find(search_key);
    return 1 == container.count(search_key); // std::map enforces 0 or 1 matches
}

// SHENNANIGAN: Random access operators on hashmap use on non-existent of object
// a default constructor or fail with an extremely bogous error message, if none
// is given.
// It always better to never use hashmap[key], because there is no check for the elements
// existence or values (typically raw C values) object creation can remain undefined.
// tldr; do not use hashmap[key], use `auto search_hashmap = hashmap.find();`
// and write via iterator or use `emplace`.

class T1 {
public:
    T1(); // needed to allow convenient random access via [] operator
    T1(const std::string &t1): mName(t1) {};
    std::string mName;
    std::string prop1;
};
class T2 {
public:
    std::map<std::string, T1> mapex1;
    void AddT1 (const std::string &t1str) {
        T1 t1obj(t1str);
        mapex1.emplace(t1str, t1obj);
        mapex1[t1str].prop1 = "blabla"; // potential footgun!
    }
};


// SHENNANIGAN: C++11 emplace() may or may not create in-place (eliding the move).
// more context https://jguegant.github.io/blogs/tech/performing-try-emplace.html

void stringRawDataAccess(std::string &comp) {
    std::string component_name = comp.c_str(); // copy construct
    // char* p_component_name = component_name.data(); returns const char*
    char* p_component_name = &component_name[0];
    // component_X_Y, X,Y in [0-9]+
    // char* component_name = "some_example_t1";
    if (p_component_name == nullptr) return;
    char* name = strtok(p_component_name, "_");
    if (name == nullptr) return;
    printf("%s\n", name);

    // awkward hackaround
    int the_int = -1;
    try {
        the_int = std::stoi(std::string(comp));
    } catch (...) {
        goto ACTIONEXIT;
    }
ACTIONEXIT:
    printf("%d\n", the_int);

    char* end;
    long i = strtol(p_component_name, &end, 10);
    i = i;
    // This requires usage of errno, so pick your poison.
}

class ClassWithMutex { // class with mutex
  std::string s1;
  std::mutex m1;
  // copy constructor
  ClassWithMutex(const ClassWithMutex& class1) {
    s1 = class1.s1;
    // mutex has forbidden move and copy constructor, so it must be omitted.
  }
};

// SHENNANIGAN Providing a const char* to function with reference will use the stack-local
// memory instead of using a copy. If further, c_str() is used to emplace into a std::map,
// this leads to UB due to usage of invalid memory once the stack local memory goes out of scope.
// - 1. In doubt, alloc a copy with `std::string newstring = std::string(some_string)`
// - 2. Especially in std::map or other owned containers.
// - 3. **Only** if there is an explicit comment on the storage including
//      handling of move and copy constructor, use `(const) char*` as provided
//      argument for `(const) std::string &`.

// SHENNANIGAN Reinterpreting bytes requires reinterpret_cast instead of static_cast.
