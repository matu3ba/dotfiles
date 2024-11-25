#include "opaque.h"
struct item {
  int32_t id;
};
size_t item_size(void) { return sizeof(struct item); }
void id_setid(struct item *it, int32_t id) { it->id = id; }
int32_t item_getid(struct item *it) { return it->id; }

int32_t main(void) { return 0; }
