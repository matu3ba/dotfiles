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
