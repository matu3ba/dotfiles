void new_memcpy(char* aa, char* bb, char* cc) {
    int i;
    for (i = 0; i < 100; ++i) {
        cc[i] = aa[i] + bb[i];
    }
}
