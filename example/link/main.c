volatile char src[] = {1, 2, 3, 4, 5};
volatile char dst[50] = {0};

void* new_memcpy(void* dst, void* src, int len);

int main(int argc, const char* argv[])
{
    new_memcpy(dst, src, sizeof(src));
    return dst[4];
}
