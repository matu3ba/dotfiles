// C++ tooling
// https://github.com/andreasfertig/cppinsights

#include <algorithm>
#include <array>
#include <array>
#include <atomic>
#include <cstdio>
#include <map>
#include <mutex>
#include <stdexcept> // std::runtime_error
#include <string>
#include <vector>
#include <memory> // unique_ptr
#include <fstream> // fstream

// posix only
#ifndef _WIN32
#include <sys/mman.h> // mmap flags
#include <unistd.h> // execve in libc
#endif

#include <cstring> // C++ has no string split method, so use strtok() or strsep()
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
// xxhash claims 31 GB/s, so thats ~10 byte/clock cycle on a 3 GHz cpu
// ssic" old-school hash is for (string) |char| hash = 31 *% hash +% char;,
// which has a multiply and add on the critical path, so it has 5-7 cycles of
// latency per byte, plus 11 or so for the branch mispredict at the end of the loop.
// FNV hash algorithm ?

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

// better enums via enum class
void enum_class_example() {
	enum class Loc {
		Abs,
		Rel,
	};
  Loc loc1 = Loc::Rel;
}

// defer-like behavior in C++
#ifndef _WIN32
#include <openssl/err.h>
#include <openssl/evp.h>
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
#endif

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
    mapexample[1] = "t1"; // do not use this, reason below
    mapexample[2] = "t2"; // do not use this
    for (auto iter = std::cbegin(mapexample); iter != std::cend(mapexample); ++iter) {
        printf("mapexample period.uiStartPeriod: %d %s", iter->first, iter->second.c_str());
    }
    std::string* ptr_str = nullptr; // or 0 if portability is needed
    for (auto iter = std::begin(mapexample); iter != std::end(mapexample); ++iter) {
        printf("mapexample period.uiStartPeriod: %d %s", iter->first, iter->second.c_str());
        ptr_str = &iter->second;
        ptr_str = ptr_str; // read the value
    }
    auto search = mapexample.find(1);
    if (search != mapexample.end()) ptr_str = &search->second;;
    ptr_str = ptr_str; // read the value
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
    // SHENNANIGAN atomic default initializer of integers is 0, but not well documented/simple to find
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

#ifndef _WIN32
// Also does split string.
void stringRawDataAccess(std::string &comp) {
    std::string component_name = comp.c_str(); // may or may not copy construct (careful)
    // char* p_component_name = component_name.data(); returns const char*
    char* p_component_name = &component_name[0];
    // component_X_Y, X,Y in [0-9]+
    // char* component_name = "some_example_t1";
    if (p_component_name == nullptr) return;
    char* name = strtok(p_component_name, "_"); // strok deprecated by windows
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
    // alternative: use find with substring
}
#endif

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

// Note: Reinterpreting bytes requires reinterpret_cast instead of static_cast.

int reinterpret_cast_usage() {
  // see also common.c no_reinterpret_cast
  // clang-format: off
  uint8_t some_vals[9] = { 0,
                              1, 0, 0, 0
                            , 0, 0, 0 ,0 };
  // clang-format: on
	int64_t val = *reinterpret_cast<int64_t*>(&some_vals[1]);
	// SHENNANIGAN less type safe than C variant (memcpy)
  // WRONG int64_t val = *reinterpret_cast<int64_t*>(some_vals[1]);
  if (val != INT64_MIN) return 1;
  return 0;
}

int ptr_no_reinterpret_cast() {
  char some_vals[5] = {0, 0,0,0,1};
	// SHENNANIGAN less type safe than C variant
  // WRONG int32_t val = reinterpret_cast<int32_t*>(some_vals[1]);
  int32_t * i32_arr_ptr = reinterpret_cast<int32_t*>(&some_vals[1]);
  (void)i32_arr_ptr;
  // dont return stack local variable here
  return 0;
}

// SHENNANIGAN https://en.cppreference.com/w/cpp/container/map/find
// "Compiler decides whether to return iterator of (non) const type by way of
// accessing map. Not the standard???

// Object oriented in-place mutex storage, with aforementioned limitation might not work.
class Variable {
public:
    Variable() = delete; // forbid default constructor to prevent [] access in std::map
    Variable(std::string value) : mValue(value) {} // initializer list
    Variable(const Variable& aCpyVar) {
        mValue = aCpyVar.mValue;
    } // mutex requires copy constructor
    std::string mValue;
    std::mutex mValueMutex; // must not be initialized and must not be copied
};
struct struct_iter {
    std::map<std::string, Variable> map_str_str;
};
int findReturnsMutIterAssignBoolValue(struct struct_iter* str_iter_ptr, std::string search_key, bool value) {
    auto var_iter = str_iter_ptr->map_str_str.find(search_key);
    if (var_iter == str_iter_ptr->map_str_str.end()) return 1;
    { // locked section
        std::unique_lock<std::mutex> lock(var_iter->second.mValueMutex);
        if (true == value) var_iter->second.mValue = std::string("true");
        else var_iter->second.mValue = std::string("false");
    }
    return 0;
}
std::map<std::string, Variable> iterGetValues(struct struct_iter* str_iter_ptr, std::string search_key, bool value) {
    std::map<std::string, Variable> res;
    std::map<std::string, Variable>::iterator var_iter;
    for (var_iter = str_iter_ptr->map_str_str.begin(); var_iter != str_iter_ptr->map_str_str.end(); var_iter++) {
        std::unique_lock<std::mutex> lock(var_iter->second.mValueMutex);
        res.emplace(var_iter->first, var_iter->second); // multiple keys not possible in std::map
    }
    return res;
}

void mutex_usage() {
    std::mutex m1; // incorrect for simplification
    std::lock_guard<std::mutex> guard(m1);
    // critical section
    // Prefer immutable object, see SimplifiedImmutable for time critical code
    // or possible changes to use atomic swap ie via ImmutableObject, which is
    // automatically handled ptr with atomic cnt.
    // Consider using adaptions of SimplifiedImmutable for special cases, like
    // to forbid copy constructor, handle different types of callbacks, data etc.
}

template <typename _RetTy, typename Ty>
class Callback {
  // how to update SimplifiedImmutable, typically via loop
};

// ImmutableObject as template for shared_ptr with constructors and operators on
// top. It usually has fancy templates to check and inline properties of a
// method externally provided often called 'update' via delegator/callback
// instead of fn ptrs for additional type and runtime safety.
// static_assert(std::is_copy_constructible<Type>::value, "not default constructible!");
// static_assert(std::is_default_constructible<Type>::value, "not copy constructible!");
template <typename _Ty>
class SimplifiedImmutable {
  SimplifiedImmutable();

	std::shared_ptr<const _Ty> Get() const;
	void Set(const _Ty& Val);
	void Set(_Ty&& Val);
	void Update(const Callback<void, _Ty&>& CallsLater);
	void Reset();
	_Ty Type() const;

private:
	void Set(std::shared_ptr<const _Ty> Val);
	std::shared_ptr<const _Ty> m_Obj;
};
template<typename _Ty>
inline void SimplifiedImmutable<_Ty>::Set(const _Ty & Val) {
	Set(std::make_shared<const _Ty>(Val));
}
template<typename _Ty>
inline void SimplifiedImmutable<_Ty>::Set(std::shared_ptr<const _Ty> Val) {
	std::atomic_store(&m_Obj, Val);
}
// ..

// idea: criteria-based (name) selection of operator implementation of class to
// reduce template boilerplate (concepts) should be possible in C++23 or something

// Naive DOD-based intrusive structure would use
// 1. std::vector for value_storage
// 2. std::map<std::string, int> for the index into value_storage
// 3. std::vector<int, std::mutex> for the mutexes

// googletest reference
// http://google.github.io/googletest/reference/actions.html

// SHENNANIGAN googlemock googletest
// std::shared_ptr is not assignable
//   MOCK_METHOD3(TheMock_MockedFn, uint8_t(Object::enum0 e0, const std::string &arg1, std::shared_ptr<VarI> & var2));
//     EXPECT_CALL(*THE_MOCK, TheMock_MockedFn(_,"arg",_))
//       .Times(AtLeast(0))
//       .WillRepeatedly(DoAll(SetArgPointee<2>(map.find("map_key")->second),Return(0)));
// One must use
//   MOCK_METHOD3(TheMock_MockedFn, uint8_t(Object::enum0 e0, const std::string &arg1, std::shared_ptr<VarI> var2));
//     EXPECT_CALL(*THE_MOCK, TheMock_MockedFn(_,"arg",_))
//       .Times(AtLeast(0))
//       .WillRepeatedly(DoAll(SetArgReferee<2>(map.find("map_key")->second),Return(0)));
// or use 'Invoke(object_pointer, &class::method)' instead of 'SetArgReferee<X>(..>)'.

// SHENNANIGAN googlemock requires default constructor, even though usage can
// create UB (for types without explicit default constructor).
// Workaround: Make default constructor protected and use FriendOfVariable2.
// #define protected public
// #include <Variable.h>
// #undef protected
class Variable2 {
private:
    friend class FriendOfVariable2;
protected:
    Variable2(): mValue("") {}
public:
    // Variable2() = delete; // forbid default constructor to prevent [] access in std::map
    Variable2(std::string value) : mValue(value) {} // initializer list
    Variable2& operator=(Variable2 other) { // user-defined copy assignment (copy-and-swap idiom)
        std::swap(mValue, other.mValue);
        return *this;
    }
    Variable2(const Variable2& aCpyVar) {
        mValue = aCpyVar.mValue;
    } // mutex requires copy constructor
    std::string mValue;
    std::mutex mValueMutex; // must not be initialized and must not be copied
};
struct struct_iter2 {
    std::map<std::string, Variable2> map_str_str;
};
class FriendOfVariable2 {
    FriendOfVariable2() {
        mVar = Variable2();
    }
    Variable2 mVar;
};

// SHENNANIGAN googlemock creates default return values for mocked objects, which
// hides the origin of errors and invalidates iterators and pointers.
// SHENNANIGAN cheat sheet by fuchsia is better than official docs and cook book
// Solution: EXPECT_CALL(testobject, testfunction(_, _, _)).WillOnce(DoAll(SetArgReferee<0>(v), SetArgReferee<1>(i), Return(true)));
// adjusted from https://fuchsia.googlesource.com/third_party/googletest/+/HEAD/googlemock/docs/cheat_sheet.md

// SHENNANIGAN googlemock can require to introduce additional objects to prevent segfaults etc.
//   Mock function call argument (prevent null pointer access in non-mocked function):
// EXPECT_CALL(testobject, testfunction(_)).Times(AtLeast(1))
//                 .WillRepeatedly(Return(returnval));
// ON_CALL(testobject, defaultfunctioncall(_,_,_,_,_))
//                 .WillByDefault(Return(1));
// EXPECT_CALL(testobject, testfunction(_,"specialval1",_,_,_))
//                 .Times(AtLeast(0))
//                 .WillRepeatedly(DoAll(SetArgReferee<2>(mockedarg1),Return(0)));
// EXPECT_CALL(testobject, testfunction(_,"specialval2",_,_,_))
//                 .Times(AtLeast(0))
//                 .WillRepeatedly(DoAll(SetArgReferee<2>(mockedarg2),Return(0)));

// SHENNANIGAN namespaces can not befriended, so test code relying on those
// plus macros or templaces forces use of macro hacks to prevent outlined above
// to prevent accidental use of the default constructor: In short, friend
// classes are a leaky abstraction (useless or force to use the pattern
// everywhere).
// => In practice it is simpler to use
// - 1. hacks
// - 2. horrible behavior
// - 3. DOD / C with more sane ~~namespaces~~classes + more typed macros

// SHENNANIGAN googlemock
// inline implementation in headers can not be mocked and fail with bogous errors
//   error: redefinition of ‘Ctor::Ctor(const string&)’
//   ..
//   error: redefinition of ‘Ctor::Ctor(const string&)’
// for each such used function.

// SHENNANIGAN googlemock
// Template types force senseless duplicate code (not DRY),
// because templated functions can not be linked against. See 'SHENNANIGAN DESIGN ERROR'.
// Googlemock assumes it can link against .h code, which is not the case for templates
// and all code should be directly used in the unit test instead like "inline fns".
// https://github.com/google/googletest/issues/2660

// PERF of exceptions with handling
// * Walk the stack with the help of the exception tables until it finds a handler for that exception
//   in the function info tables.
// * Unwind the stack until it gets to that handler.
// * Actually call the handler.
// => Even with additional bookkeeping by OS, this is slow.
// => ~1.5us per level of stack, see https://stackoverflow.com/questions/1018800/cost-of-throwing-c0x-exceptions/1019020#1019020
// without handling on x86_64 OS does heavy lifting, on x86 not.

// idea if needed
// - minimal own unit testing lib
//   * high perf + 0BSD to let others steal the code
// - minimal own injection lib
//   * high perf + 0BSD to let others steal the code

// SHENNANIGAN
// "static initialization order ‘fiasco’ (problem)"
// 2 static objects in 'x.cpp' and 'y.cpp', y.init() calls method on x object.
// poor solution "Construct On First Use Idiom", which never destructs
// better solution "Make it a lib" to provide explicit context instead of implicit
// object one, because comptime-code execution should not hide control flow
// okayish solution "Explicit dependencies on objects/strong coupling"

// Note
// << operator uses as few digits as possible to print, also omitting '.0' digits.

// SHENNANIGAN
// The linker is a separate thing without knowledge on the compiler invocation,
// so it does not explain linking failures with context.
// Linkerpath filepath:line: undefined reference to `classname::functionname()'
// Most likely, functionname() was declared in class, but no implementation
// given as classname::functionname().
// Other typical causes are incorrect usage of mocking or linker substitution.

// performance traps https://wolchok.org/posts/cxx-trap-1-constant-size-vector/

// SHENNANIGAN
// C++ conversion string to int is worse without boost, so use C's strtol from templates/common.c
// https://stackoverflow.com/questions/11598990/is-stdstoi-actually-safe-to-use

// Logging exceptions
// catch (const std::exception &e) {
//     log(e.what());
// }

// SHENNANIGAN
// error: Unkown classname, did you mean xyz?
// headers with classes include another:
//  h1.h: #include h2.h
//  h2.h: #include h1.h
// must use in h1.h (assumed to be main class) as class declaration
//  class h2;

// SHENNANIGAN
// Template usage with base class adding to map via emplace (base class with interfaces is not
// templated, specialized one is) may have undecipherable error messages (due no automatic upcast to base class):
//   file.cpp:1032:64:   required from here
//   /usr/include/c++/9/ext/new_allocator.h:146:4: error: no matching function for call to ‘std::pair<const std::__cxx11::basic_string<char>, std::shared_ptr<FileInterface> >::pair(std::__cxx11::basic_string<char>, std::shared_ptr<File<std::__cxx11::basic_string<char> > >&)’
//     146 |  { ::new((void *)__p) _Up(std::forward<_Args>(__args)...); }
//         |    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// It does not matter to use std::shared_ptr<Variable<std::string>> var_obj = std::make_shared<Variable<std::string>>(varValue, varName.c_str(), varPath.c_str(), varAttr);
//      or std::shared_ptr<Variable<std::string>> var_obj(new Variable<std::string>>(varValue, varName.c_str(), varPath.c_str(), varAttr));
// Solution:
//   1. Make functions within interface class templated (no virtual) or purely virtual (no body and write 'virtual fnname() = 0;')
//   2. Remove all data from interface class
//   4. Check, if constructor of base class is public to make it accessible to specialized one
//   5. Use one of the following patterns:
//     + 1. fns not impacting object lifetime should use 'int foo(bar& b)'
//     + 2. fns consuming object should use 'baseobjfn(unique_ptr<specialobj> b)' and be called with std::move to move the value into fn
//     + 3. fns extending lifetime object should use 'baseobjfn(shared_ptr<specialobj>)' and care should be taken to avoid circular references

// SHENNANIGAN DESIGN ERROR
// Virtual functions can only be used with overloaded and explicit implementations,
// because templated functions can not be linked against.
//    class Base {
//    public:
//       template <typename T> void f( T a ) {}
//       virtual void f( int a ) { std::cout << "base" << std::endl; }
//    };
//    class Derived : public Base {
//    public:
//       virtual void f( int a ) { std::cout << "derived" << std::endl; }
//    };
//    int main() {
//       Derived d;
//       Base& b = d;
//       b.f( 5 ); // The compiler will prefer the non-templated method and print "derived"
//    }
// Solution: 1. Use regular function overloading (copy-pasta or spaghetti code) or
// 2. template <typename T> std::string GetValueAsString() {}
//    template <typename Y=T>
//    std::string GetValueAsString() {
//      if (std::is_same<Y, std::string>::value) { return mtVal; }
//      else { return std::to_string(mtVal); }
//    }
// Solution 2. has drawback, that caller must know type or lookup must be annotated somewhere (ie in the base class),
// so we have barely an advantage over not using enum + union.

// Constructor types and assignment operator types
class ExampleClass {
    int mValue;
    std::mutex mMut;
    // move constructor (move means much (2) ampersand arg)
    // ExampleClass ex2 = std::move(ex1); // or ExampleClass ex2 = &&ex1;
    // default: requires opt-in unless other constructors forbidden (move-only type)
    ExampleClass(ExampleClass&& aCpyVar) {
        mValue = aCpyVar.mValue;
    }
    // simple constructor
    // ExampleClass ex1(1);
    // default: used on default in constructor
    ExampleClass(int aValue) {
        mValue = aValue;
    }
    // copy constructor: ExampleClass ex1(1); ExampleClass ex2(ex1); // also ExampleClass ex2 = ex1;
    // default: requires opt-in unless other constructors forbidden
    ExampleClass(const ExampleClass& aCpyVar) {
        mValue = aCpyVar.mValue;
    } // mutex requires copy constructor

    // On absence of assignment operators primitive types are assigned, whereas
    // the according default assignment (and on absence simple constructor) is
    // called

    // move assign operator (move means much (2) ampersand arg) usually used for move-only types
    // ExampleClass ex1(1); ExampleClass ex2(2); ex2 = std:move(ex1); // or ex2 = &&ex1;
    // default: requires opt-in unless other assignment operators forbidden (as move-only type)
    ExampleClass& operator=(ExampleClass&& other) {
        // swap lifts destruction and deallocation out of a critical/hot section
        // and instead is UB on target as different allocator and it leaves swapped items "destroyed"
        std::swap(mValue, other.mValue);
        return *this;
    };
    // simple assign operator (C++98 style)
    // ExampleClass ex2(1), ex1(2); ex2 = ex1;
    // default: used on default for assignments unless forbidden
    ExampleClass& operator=(ExampleClass& other) {
        // move leaves moved items "undestroyed" to have defined state for
        // different allocators usage not being UB
        // => no allocations => use std::swap
        // => allocations => use std::move
        mValue = std::move(other.mValue);
        return *this;
    };
    // copy assign operator (must have a public copy assignment operator), also
    // allowed signature: const ExampleClass& ExampleClass ex1(1); ExampleClass
    // ExampleClass ex2(1), ex1(2); ex2 = std::copy(ex1); // or ex2=ex1; if simple assign operator forbidden
    // default: requires opt-in unless other assignment operators forbidden
    ExampleClass& operator=(ExampleClass other) {
        return *this;
    };
};

// https://stackoverflow.com/questions/1226634/how-to-use-base-classs-constructors-and-assignment-operator-in-c
// You can and might need to explicitly call constructors and assignment operators.
class Base {
public:
    Base(const Base&) { /*...*/ }
    Base& operator=(const Base&) { /*...*/ } // simple assign op, NOLINT
    Base& operator=(const Base&&) { /*...*/ } // move assign op, NOLINT
};

class Derived : public Base {
    int additional_;
public:
    Derived(const Derived& d)
        : Base(d) // dispatch to base copy constructor
        , additional_(d.additional_) {}
    Derived& operator=(const Derived& d) { // simple assign op
        Base::operator=(d);
        additional_ = d.additional_;
        return *this;
    }
    Derived& operator=(const Derived&& d) { // move assign op
        Base::operator=(std::move(d));
        additional_ = d.additional_;
        return *this;
    }
};

// Debugging templates guidelines
// * do *never* try to separate templates code into .h and .cpp. It will not work. Use .hpp.
// * static_assert everywhere
// * Sandboxes: Test as soon as it starts behaving weird, ideally with commits (ie on separate branch)
// * Specify temporary types for better source location info, debugging, to prevent compiler limitations etc
// * use typeid: std::cout << "testing type " << typeid(T).name() << std::endl;
// * remove unnecessary default implemenations
//     template<typename T, bool is_integral = boost::is_numeric<T>::value >
//       struct my_traits;
//
//     template<typename T>
//       struct my_traits<T, true> {
//         typedef uint32_t cast_type;
//       };
//
//     template<typename T>
//       void print_whole_number(T &val) {
//         std::cout << static_cast<my_traits<T>::cast_type>(val) << std::endl;
//       }
// * use templight or metashell
// * try https://cppinsights.io
// * std::cout << "testing type " << typeid(T).name() << std::endl;
// * To generalize a type (GetVarAsString) via base class, one has to
//   overload the pure function and use inner functions as templates.

// From https://gpfault.net/posts/mapping-types-to-values.txt.html
// SHENNANIGAN
// std::type_info::hash_code can return different values for different types
// for all std::type_info objects referring to the same type, their hash code is the same.
// type_id and dynamic_cast are the other options
// std::type_index

// Nice template overview: https://caiorss.github.io/C-Cpp-Notes/CPP-template-metaprogramming.html
// function overloading and the object code need a unique function name for
// every function, the compiler generates an unique name for every function
// overload, classes and template classes. This process is called name mangling,
// or name decoration and is unique to each compiler.
// Possible Template Parameters: 1. class or typename, 2. Integers, 3. Function pointer, 4. Member function pointer

// SHENNANIGAN
// Non-template classes need to be stored in helper structure or have lookup
// helper function.

// SHENNANIGAN
// Checking, if typename is a string is complex (even with C++17 extension)
#if __cplusplus > 201402L
template<typename STR>
inline constexpr bool is_string_class_decayed = false;
template<typename... STR>
inline constexpr bool is_string_class_decayed<std::basic_string<STR...>> = true;
// decay_t will remove const, & and volatile from the type
template<typename STR>
inline constexpr bool is_string_class = is_string_class_decayed<std::decay_t<STR>>;
template <typename TChar, typename TString>
inline constexpr bool is_string = is_string_class<TString> && std::is_same_v<TChar, typename TString::value_type>;
static_assert(is_string_class<std::string>);
static_assert(is_string_class<const std::wstring&>); // that's why we need decay_t
static_assert(!is_string_class<int>);
static_assert(!is_string_class<const double>);
static_assert(!is_string_class<const char*>);
static_assert(!is_string_class<std::vector<char>>);
#endif

// SHENNANIGAN
// stringstream is simpler to use than template code (DIY is annoying)
// std::string GetValueAsString() override {
//     std::stringstream ss;
//     ss << (*mtValue);
//     return ss.str();
// }

// SHENNANIGAN
// std::to_string not defined for std::string, which is ennoying for generics

// SHENNANIGAN
// Errors are unfeasible to decipher. Consider
// std::string GetValueAsString1() {
//   if (!std::is_same<bool, Y>::value && !std::numeric_limits<Y>::is_integer && !std::is_floating_point<Y>::value) { return *mtValue; }
//   else { return std::to_string(*mtValue); }
// }
// template <typename Y=T>
// std::string GetValueAsString2() {
//   if (std::is_same<std::basic_string<char>, Y>::value) { return *mtValue; }
//   return std::to_string(*mtValue);
// }
// Neither function works and comparing types in templates is very cryptic.

// SHENNANIGAN
// Errors from pure virtual functions, ie destructors, which are needed are cryptic:
// undefined reference to `VarInterface::~VarInterface()'
// Solution: Change 'virtual ~VarInterface() = 0' to 'virtual ~VarInterface() {}'

// Singleton http://www.java2s.com/example/cpp/template/create-the-singleton-template.html
// https://stackoverflow.com/questions/41328038/singleton-template-as-base-class-in-c

// Using C++ as C with templates:
// 1. Compile with g++, link with gcc
//   g++ -nodefaultlibs -fno-exceptions -fno-rtti -std=c++11 -c main.cpp -o main.o
//   gcc -o main main.o
// 2. Using clang
//   clang++ -nodefaultlibs -fno-exceptions -fno-rtti -std=c++11 -c main.cpp -o main.o
// Mac might need `-nostdlib -L libcpath` due to automatically invoking -stdlib=libc++.
//
// Separately linking libc++:
// clang your.cpp -lstdc++

// SHENNANIGAN
// make_shared is faster due having references next to storage
// make_shared and weak_ptr do not co-exist well, because one can only call the
// destructor to remove all associated memory.

// SHENNANIGAN
// Problem auto does verbatim replacement of the return type, which can hide a stack-local copy
// Solution: Only use 'auto' for well-known iterators and status tuples, **never**
// for objects.

#ifdef _POSIX
// IPC over shared process memory
enum ProcState { IDLE, STOPPING, RUNNING };
static void * some_memregion = nullptr; // c++ only
static bool app_stopped = false;
void some_ipc() {
  some_memregion = mmap(nullptr, sizeof(ProcState), PROT_READ | PROT_WRITE, MAP_SHARED | MAP_ANONYMOUS, -1, 0);
  if (some_memregion == MAP_FAILED) {
      perror("mmap failed");
      exit(1);
  }
  ProcState proc_state = ProcState::IDLE;
  memcpy(some_memregion, &proc_state, sizeof(proc_state));

  // process/thread creation

  // write to process/thread
  proc_state = ProcState::RUNNING;
  memcpy(some_memregion, &proc_state, sizeof(proc_state));
  msync(some_memregion, sizeof(proc_state), MS_SYNC | MS_INVALIDATE);
  printf("starting proc_state...");
}

void ipc_read() {
  while(!app_stopped) {
    ProcState proc_state; // undefined
    // get old state
    memcpy(some_memregion, &proc_state, sizeof(proc_state));
    switch (proc_state) {
      case ProcState::STOPPING: {
        proc_state = ProcState::IDLE;
        // write back new state
        memcpy(some_memregion, &proc_state, sizeof(proc_state));
        msync(some_memregion, sizeof(proc_state), MS_ASYNC);
        break;
      }
      case ProcState::IDLE: [[fallthrough]];
      case ProcState::RUNNING: break;
    }
  }
}
#endif

// SHENNANIGAN
// interoperating type safe with c strings is very cumbersome
void cstring_interop_annoying() {
  const char * cmd = "ls";
  char const * buffer[] = {"ls", "-l", NULL};
  char * const * argv = const_cast<char * const *>(buffer);
  // Posix name is deprecated, use _execve
  int execed = _execve(cmd, argv, NULL);
  execed = execed;
}

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
// unique_ptr pattern to handle file handles and cleanup via RAII
void raii_filehandles() {
  std::string sFile = "blablabla";
  char csFile[MAX_PATH] = "";
  memcpy(csFile, sFile.c_str(), sFile.size());
  std::unique_ptr<void, decltype (&CloseHandle)> hFile(nullptr, CloseHandle);
  // GENERIC_WRITE, FILE_SHARE_WRITE for setting anything on the file
  HANDLE tmphFile = CreateFile(csFile,
    GENERIC_READ, // SYNCHRONIZED, GENERIC_WRITE
    FILE_SHARE_READ, // FILE_SHARE_WRITE
    NULL,
    OPEN_EXISTING, //  CREATE_ALWAYS to overwrite if exists
    FILE_ATTRIBUTE_NORMAL,
    NULL
  );
  if (tmphFile == INVALID_HANDLE_VALUE) fprintf(stderr, "could not open file handle\n");
  hFile.reset(tmphFile);

  // do some work
  // < unique_ptr deleter is run
}

void systemtime_filetime() {
  SYSTEMTIME st_base = { 0 }; // looks like compiler does not support C initialization list (since C11/C++11)
  st_base.wYear = 2000;
  FILETIME ft_base;
  FILETIME ft_wanted;

  bool bSt = false;
  bSt = SystemTimeToFileTime(&st_base, &ft_base);
  if (bSt == false) exit(1);

  st_base.wMonth = 12;
  st_base.wDayOfWeek = 12;
  st_base.wDay = 12;
  st_base.wHour = 12;
  st_base.wMinute = 12;
  st_base.wSecond = 12;
  st_base.wMilliseconds = 12;
  bSt = SystemTimeToFileTime(&st_base, &ft_wanted);
  if (bSt == false) exit(2);
}

// https://stackoverflow.com/questions/70715882/modify-file-create-time-in-windows-using-only-c

// windows GetLastError
//
//#include <system_error>
void printGetLastError() {
    DWORD error = ::GetLastError();
    std::string message = std::system_category().message(error);
    fprintf(stdout, "ERROR: %s\n", message.c_str());
}
#endif

/// Prefer 'if constexpr' over 'enable_if' over SFINAE to keep things readable.
/// Prefer template type specialization, if possible ('template <int T>').
/// enable_if, enable_if_t etc available since C++14 (implementable via SFINAE)
/// if constexpr since C++17 (not implementable via SFINAE)
// template <typename _Integral>
// void BestPracticeTemplateUsage(std::unique_ptr<Class<_Integral>> & ClassRef, const _Integral expected)
// {
//   // prefer in class definition:
//   static_assert( std::is_same<_Integral, int64_t>::value || std::is_same<_Integral, double>::value );
//   if constexpr (std::is_same<_Integral, int64_t>::type_id) {
//     std::shared_ptr<const CPxIntegerValue> out_data = ClassRef->GetTypedData();
//     TEST_EQUAL(out_data->ToInt64(), expected);
//   }
//   else if constexpr (std::is_same<_Integral, double>) {
//     std::shared_ptr<const CPxIntegerValue> out_data = ClassRef->GetTypedData();
//     TEST_EQUAL(out_data->ToDouble(), expected);
//   } else {
//     static_assert(!std::is_same<_Integral, _Integral>::value); // template error
//   }
// }

// substitution failure is not an error (SFINAE) to conditionally include
// function best via https://en.cppreference.com/w/cpp/types/enable_if
// using enable_if_int64 = std::enable_if_t<true, int64_t>::value>;
// using enable_if_double = std::enable_if_t<std::is_base_of<Foo, T>::value>;
// template <typename T, typename = std::enable_if_t< std::is_base_of<Foo, T>::value>

// more simple std::is_same<T, int64_t>:
template <typename _Integral, typename std::is_same<_Integral, int64_t>::type_value>
void fun_placeholder1();

// Forward declaration must specify one template per class and variable name
// in order of first occurence.
// template<typename T>
// template <int N>
// class Outer<T>::Inner {};
// or Class1<T>::Fn1(const Class2<N> arg) { .. }

// https://stackoverflow.com/questions/2351148/explicit-template-instantiation-when-is-it-used
// Best practice to prevent hidden code bloat is "template interface":
// interfacefile.xyz = [template_interface.hpp|template.h]
// interfacefile.xyz
//   no includes of template.[hpp|cpp]
//   template fn + class declarations
//   extern template class Class<int>;
//   typedef Class<int> ClassInt;
// template.hpp
//   include of interfacefile.xyz
//   template fn + classes implementations
// template.cpp
//   include of interfacefile.xyz and template.hpp
//   include of _def files for the static bits, see IWYU and clang tooling
//   template class Class<int>;
// usage.cpp
//   include interfacefile.xyz
//   ClassInt classIntInstance;

// With injection template.hpp also forces tests to be written inside, because
// underlying types must be resolved.
// Pure templates are ideal, since their testing can be contextual.

// templace specialization
//   template <typename T, bool AorB>
//   struct dummy;
//   template <typename T, true>
//   struct dummy {
//     static void MyFunc() {  FunctionA<T>(); }
//   }
//   template <typename T, false>
//   struct dummy {
//     static void MyFunc() {  FunctionB<T>(); }
//   }
//   template <typename T>
//   void Facade() {
//     dummy<T, MeetsConditions<T>::value>::MyFunc();
//   }
// enable_if
//   template<typename _Integral, std::enable_if_t<true, int64_t>::value>
//   MyFunc() {
//     FunctionA<T>();
//   }
//   template<typename _Integral, std::enable_if_t<true, double>::value>
//   MyFunc() {
//      FunctionB<T>();
//   }
// specialization of member class
//   template<>
//   static void MyFunc<true>() {}
// specialization of member fn inside class
//   private:
//     template <int I>
//     void foo();

// void msvcExampleFunction()
// {
// printf("Function name: %s\n", __FUNCTION__);
// printf("Decorated function name: %s\n", __FUNCDNAME__);
// printf("Function signature: %s\n", __FUNCSIG__);
// // Sample Output
// // -------------------------------------------------
// // Function name: exampleFunction
// // Decorated function name: ?exampleFunction@@YAXXZ
// // Function signature: void __cdecl exampleFunction(void)
// }

// SHENNANIGAN
// C++ standard forbids specializations of a templatized function inside a class
// (via SFINAE).
// This might work with enable_if if constexpr + static_cast.

// https://learn.microsoft.com/en-us/cpp/cpp/explicit-instantiation?view=msvc-170
// "The extern keyword in the specialization only applies to member functions
// defined outside of the body of the class. Functions defined inside the
// class declaration are considered inline functions and are always
// instantiated." => Always move template fn implementations outside of
// classes.

// SHENNANIGAN
// msvc has no reliable relative paths as macro yet (see experimental:deterministic mode)
// workaround get filename by Andry https://stackoverflow.com/a/54335644
template <typename T, size_t S>
inline constexpr size_t fname_offs(const T(&str)[S], size_t i = S - 1) {
	return (str[i] == '/' || str[i] == '\\') ? i + 1 : (i > 0 ? fname_offs(str, i - 1) : 0);
}
template <typename T>
inline constexpr size_t fname_offs(T(&str)[1]) {
	return 0;
}
namespace util_force_const_eval {
	template <typename T, T v>
	struct const_expr_value
	{
		static constexpr const T value = v;
	};
}
#define FORCE_CONST_EVAL(exp) ::util_force_const_eval::const_expr_value<decltype(exp), exp>::value
#define LEAF(FN) (&FN[FORCE_CONST_EVAL(fname_offs(FN))])

int testEq(int a, int b) {
  if (a != b) {
    // Prefer __FILE_NAME__, which also works in C. Ideally, the compiler
    // can be told to provide relative file paths.
    fprintf(stderr,"%s:%d got '%d' expected '%d'\n", LEAF(__FILE__), __LINE__, a, b);
    return 1;
  }
  return 0;
}

// forward declaration in interface the Test function, if TV convertible to
// double. Usage should be not inlined and use explicit instantiation,
// especially in big code bases to save compilation time.
template <class TVAL, class TEXP, class TEPS>
static typename std::enable_if<std::is_convertible<TVAL, double>::value, void>::type testApprox(const TVAL & Val, const TEXP & Expect, const TEPS & Eps);

// check that value NaN if value convertible to double via parameter
template <class TVAL>
static bool isNan(const typename std::enable_if<std::is_convertible<TVAL, double>::value, double>::type & Val);

template <class TVAL>
static bool isNan(const typename std::enable_if<std::is_convertible<TVAL, double>::value, double>::type & Val) {
  return (Val != Val); // NaN => (Val != Val)
  static_assert(std::is_copy_constructible<TVAL>::value, "Type must be copy-constructible!");
}
// Explanation: return value of std::is_convertible is true/false, enable_if
// first param is boolean, second is enabled type result is either empty struct
// or struct with type, value and we want the type from that

void someLambda(bool bVal1, const std::string & sName) {
  auto DrawOp = [&](bool bVal1, const std::string & sName) {
    if (bVal1)
      fprintf(stdout, "%s\n", sName.c_str());
  };
}

/// Windows Performance counter API's
// WINBASEAPI BOOL WINAPI
// QueryPerformanceCounter(__out LARGE_INTEGER *lpPerformanceCount);
// WINBASEAPI BOOL WINAPI
// QueryPerformanceFrequency(__out LARGE_INTEGER *lpFrequency);

// SHENNANIGAN
// C++ does not capture C type problems, especially memcpy, memset etc
// Prefer ape_printing, not ape_printing_bad
#ifdef _WIN32
void ape_printing_bad() {
  std::fstream fs;
  fs.open("filename.txt", std::fstream::app | std::fstream::out);
  fs << "somestuff\n";
  fs.close();
}
#endif

#ifdef _WIN32
// make msvc not complain about fopen
// to be used in first lines of .cpp file
#define _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_DEPRECATE
#endif
void ape_print() {
  FILE * f1 = fopen("file1", "a+");
  fprintf(f1, "sometext\n");
  fprintf(f1, "f1 ptr: %p\n", f1);
  fclose(f1);
}

void ape_throw() {
  throw std::runtime_error("error");
}

// Cast iterator to pointer
void ape_itertoptr() {
  std::string my_str= "hello world";
  std::string::iterator it(my_str.begin());
  char* pointer_inside_buffer=&(*it);
  fprintf(stdout, "%s\n", pointer_inside_buffer);
}

// SHENNANIGAN
// destructors of virtual classes should ALWAYS have lifetime annotation
// Otherwise: hell to debug, because ambiguous object lifetimes
// (unless final class)
// Use clang -Wnon-virtual-dtor or recent msvc (~ year 2020)

// SHENNANIGAN
// Classes must be annotated as final, if they are not supposed to be inherited from.

// SHENNANIGAN
// Delete copy + move constructors for non-final classes with no pure-virtual methods.

// Consider marking copy constructr as explicit and deleting copy assignment, if
// copying class is expensive. Consider providing a "clone fn" as syntactic sugar.

// SHENNANIGAN
// synchronization of virtual classes should ALWAYS be annotated
// Otherwise: hell to debug, because ambiguous synchronization

// SHENNANIGAN clang-format annoyingly verbose to setup and configure
// clang-format -style=llvm -dump-config > .clang-format

// https://learn.microsoft.com/de-de/cpp/error-messages/compiler-warnings/compiler-warning-level-1-c4251?view=msvc-170
// SHENNANIGAN poor phrasing of "use virtual classes or c abi for dll exports"
// class __declspec(dllexport) X
// {
// public:
//     X();
//     ~X();
//     void do_something();
// private:
//     void do_something_else();
//     std::vector<int> data; // warning c4251
// };
// SHENNANIGAN no explanation how dllexports can be omitted (private classes)

// SHENNANIGAN Error C2681 invalid expression type for dynamic_cast
// is confusing. The type may simply not known instead of "invalid".

void chrono_usage() {
  // auto timeFromDb = std::chrono::system_clock::from_time_t(std::mktime(&dbTime));
  auto t_start = std::chrono::high_resolution_clock::now();
  // the work...
  auto t_end = std::chrono::high_resolution_clock::now();
  double elapsed_time = std::chrono::duration<double, std::milli>(t_end - t_start).count();
	uint64_t elapsed_time_ms_cast = std::chrono::duration_cast<std::chrono::milliseconds>(t_end - t_start).count();

  double elapsed_time_ms = std::chrono::duration<double, std::milli>(
      std::chrono::high_resolution_clock::now() - t_start
  ).count();
  (void)elapsed_time;
  (void)elapsed_time_ms_cast;
  (void)elapsed_time_ms;
  // fprintf ..
}

// UB: OOB access very evil and may lead to eventual crashes.
// ape_debug via tracing amount of expected loops vs actual loops, which may
// prevent crash.

// SHENNANIGAN C2259 'class' : cannot instantiate abstract class
// if virtual function overload is missing from class provides no correct source
// locations (may point to useless template classes instead)

// Bounded quantification
// universal or existential quantifier which are restricted to range only over subtypes
// of a particular type (parametric polymorphism <-> subtyping)

// F-bounded quantification
// * purpose: allow polymorphic fns to depend on specific behavior of objects
//   instead of type inheritance
// * assume: record-based model for object classes (each class member is record element and class members are named fns)
// * application of bounded quantification on recursive types

// The Curiously Recurring Template Pattern (CRTP) = F-bounded polymorphism (subform of F-bounded quantification)
// * Data, context and interaction (DCI)
// * no runtime overhead in contrast to dynamic
// * simplified with C++23
template <class T>
class Base1
{
    // methods within Base1 can use template to access members of Derived
};
class Derived1 : public Base1<Derived>
{
    // ..
};
// Use case Static Polymorphism
template <class T>
struct Base2
{
    void interface() {
        static_cast<T*>(this)->implementation();
    }
    static void static_func() {
        T::static_sub_func();
    }
};
struct Derived2 : Base2<Derived>
{
    void implementation();
    static void static_sub_func();
};
// other use cases include object counter, polymorphic chaining|copy construct

// SHENNANIGAN streams do not enforce C abi and are overly complex for printing memory
// This may hide serious bugs like memcpy to std::vector<bool>.
void stream_flags() {
  // https://codereview.stackexchange.com/questions/165120/printing-hex-dumps-for-diagnostics
  std::vector<uint8_t> array {1, 0, 0, 0};

  // SHENNANIGAN implicit instantiation is allowed at least in msvc of visual studio 2015
  std::fstream fstream{"somestream.txt", std::fstream::app | std::fstream::out};
  /*fstream.open();*/
  auto flags = fstream.flags();
  fstream << std::hex;
  for (uint32_t i = 0; i < array.size(); i+=1)
    fstream << std::hex << array[i];
  fstream.flags(flags);
  fstream << "\n";
  fstream.close();
}

// SHENNANIGAN Unspecified how the compiler treats references (pointer or copy),
// so "Strict Aliasing Rule" still applies.

// SHENNANIGAN C++ compilers
// msvc Compiler Warning (level 2) C4308
// constexpr int64_t cnt_value = (int64_t)((uint64_t) 1 << 63)
// leads to weird warnings, even though its clear that we want to construct a number at comptime
// constexpr int64_t cnt_value = -(((int64_t)1 << 32) + (int64_t)UINT32_MAX);

// SHENNANIGAN
// incomplete type can not be instantiated in template:
// * pull in all headers deps of headers
// * class forward declares may create circular dependencies
// * build each file individually
// * might be a circular dependency during template usage

// SHENNANIGAN missing virtual destructor for non-final methods in classes technically UB
class ISomeInterface {
public:
  virtual int SomeMethod() = 0;
};
class CSomeClass : ISomeInterface
{
  CSomeClass();
  public:
  int SomeMethod() override {
    return 1;
  }
  virtual ~CSomeClass();
};
class CSomeDerivedClass : CSomeClass
{
  CSomeDerivedClass();
  public:
  int SomeMethod() override final {
    return 2;
  }
  virtual ~CSomeDerivedClass(); // optional virtual
};

//====injection via override implementaion of base class
// idea: write the private classs of "SomeClass" via replacing the shared_ptr
// which the class holds to the private class with the struct class instead.
struct CTestSomeInterface : ISomeInterface {
  int SomeMethod() override {
    // do injected functionality
    return 0;
  }
};

struct SomeDll {
  std::string m_filename;
  void SetupDll(const std::string & config_file) {
    // do stuff and simplify by comparing to config_file
    if (config_file == "DriverError")
      throw std::runtime_error("DriverError: sometext");
    else if (config_file == "InitError")
      throw std::runtime_error("InitError: sometext");
    else if (config_file == "NoDeviceError")
      throw std::runtime_error("NoDeviceError: sometext");
    // skip unknown runtime_error and unknown exception here for brevity
  }
};

int why_exceptions_dont_scale(char * errmsg_ptr, uint32_t * errmsg_len) {
  // SHENNANIGAN clangd
  // shows ISO C++11 does not allow conversion from string literal to 'char *const' instead of
  // recommending the proper fix below
  // constexpr char * const_drivermsg = "DriverError: ";
  constexpr char const_drivermsg[] = "DriverError: ";
  constexpr char const_initmsg[] = "InitError: ";
  constexpr char const_nocamfoundmsg[] = "NoCameraFound: ";
  // Underlying idea: prefix exception strings with text. Below case handling
  // shows how error prone this is to make runtime decisions with C abi
  // compatibililty across dll. And this does not cover compiler mangling and
  // dependency on runtime etc.
  // Further more, tooling like clangd is unable to infer all possible strings
  // to enforce correct error handling of the bubbled up exceptions and not even
  // all possible derived exception types.
  struct SomeDll some_dll;
  try {
    some_dll.SetupDll("someconfig_file");
  }
  catch (std::runtime_error & rt_err) {
    std::string err = rt_err.what();
    // std::string::StartsWith : err.rfind("DriverError:", 0) == 0)
    if (err.rfind(const_drivermsg, 0) == 0) {
      int st = snprintf(&errmsg_ptr[0], *errmsg_len, "%s", &err.c_str()[sizeof(const_drivermsg)]);
      if (st <= 0) return 1; // C89 allows less than 1, C99 NULL
        return 2;
    }
    else if (err.rfind(const_initmsg, 0) == 0) {
      int st = snprintf(&errmsg_ptr[0], *errmsg_len, "%s", &err.c_str()[sizeof(const_initmsg)]);
      if (st <= 0) return 1;
        return 2;
    }
    else if (err.rfind(const_nocamfoundmsg, 0) == 0) {
      int st = snprintf(&errmsg_ptr[0], *errmsg_len, "%s", &err.c_str()[sizeof(const_nocamfoundmsg)]);
      if (st <= 0) return 1;
      return 3;
    }
  }
  catch (std::exception & exc)
  {
    std::string err = exc.what();
    int st = snprintf(&errmsg_ptr[0], *errmsg_len, "%s", &err.c_str()[sizeof(const_nocamfoundmsg)]);
    if (st <= 0) return 1;
    return 100;
  }
  return 0;
}

// SHENNANIGAN exceptions implementation are complex
// See https://maskray.me/blog/2020-12-12-c++-exception-handling-abi
// and compare to setjmp and longjmp (store and retrieve stack)

// ====caching fixen
// https://stackoverflow.com/questions/1704907/how-can-i-get-my-c-code-to-automatically-print-out-its-git-version-hash
// try: specify macro via msvc compiler
// https://learn.microsoft.com/en-us/cpp/build/reference/d-preprocessor-definitions?view=msvc-170
// https://learn.microsoft.com/de-de/cpp/build/reference/compiler-options?view=msvc-170
// https://learn.microsoft.com/en-us/visualstudio/msbuild/cl-task?view=vs-2022
// adjust graphical msvc compiler invocation
// => must use build system to invoke correct flags, if they are changing to prevent cache misses
// resulting in unnecessary checks

// https://en.cppreference.com/w/cpp/atomic/memory_order
// TODO
// * difference to C memory order =>
// * guide to check for yourself with cerberus

// SHENNANIGAN
// templated classes with forwarded declared private class defined in cpp may
// prevent usage of 'MyClass class = MyClass();' due to unknown type, which
// needs to replaced by 'MyClass class();'

// SHENNANIGANS implicit coercion via other class possible
// templated constexpr can coerce implicitly via other class, but it must have the direct includes.

// SHENNANIGAN msvc before VS2022 also uses indirect includes for templates
// SHENNANIGAN msvc before VS2022 created implicit assignment operators

// SHENNANIGAN msvc
// private interior class may need inline constructor to propagate type
// information to header, if forward declared in header
