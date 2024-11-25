#include <stddef.h>
#include <stdint.h>
struct item;
size_t item_size(void);
void id_setid(struct item *it, int32_t id);
int32_t item_getid(struct item *it);
