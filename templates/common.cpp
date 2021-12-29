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
