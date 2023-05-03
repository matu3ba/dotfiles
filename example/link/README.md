#### Minimal tutorial to understand the link order and link order dependency ####

https://eli.thegreenplace.net/2013/07/09/library-order-in-static-linking written by Eli Bendersky.

Just as a quick reminder: An object file both provides
- 1. (exports) external symbols to other objects and libraries, and
- 2. expects (imports) symbols from other objects and libraries.

See:
```c
int imported(int);

static int internal(int x) {
    return x * 2;
}

int exported(int x) {
    return imported(x) * internal(x);
}
```
```
$ gcc -c x.c
$ nm x.o
000000000000000e T exported
                 U imported
0000000000000000 t internal
```

This means
- `exported` is an external symbol - defined in the object file and visible from the outside.
- `imported` is an undefined symbol; in other words, the linker is expected to find it elsewhere.
- `internal` is defined within the object but invisible from the outside.

A static library (file ending `.a`) is simply a collection of object files.

Consider `$ gcc main.o -L/some/lib/dir -lfoo -lbar -lbaz`.


- While doing its work, the linker maintains symbol table (most relevant here 2 lists):
  * 1. list of symbols exported by all objects and libraries encountered so far
  * 2. list of undefined symbols that the encountered and libraries requested to import and were not found yet
- On encountering a new object file, the linker looks as
  * 1. Symbols the object file exports, which are added to list of exported symbols mentioned above.
    - 1. If any symbol is in the undefined list, it's removed from there, because it has now been found.
    - 2. If any symbol has already been in the exported list, we get a "multiple definition" error: 2 different
    objects export the same symbol and the linker aborts
  * 2. Symbol the object file imports, which are added to list of undefined symbols, unless they are found in
    list of exported symbols
- On encountering a new library, the linker goes over all objects in the library. For each one,
  * 1. it first looks at the symbols it exports
    - If any of the symbols it exports are on the undefined list, the object is added to the link and the next
      step is executed. Otherwise, the step is skipped.
    - If the object has been added to the link, it is treated as described above: It is undefined and the 
      exported symbols get added to the symbol table.
  * If **any** of the objects in the library has been included in the link, the library is rescanned again,
    since its possible that symbols imported by the includede object can be found in other objects within
    the same library.
- When the linker finishes, it looks at the symbol table: If any symbol remains on the undefined list,
  the linker throws an "undefined reference" error.
  
One very simple example is forgetting to defined _start or main in an executable, so the linker
complains with `In function '_start' ..: undefined reference to 'main'`.

After a library was processed, it is not looked upon again. So if the library exports symbols needed
by some later library, the symbol is not taken into the symbol list to be marked as used.
The only time a linker repeats a scan on an object it has already seen happens in a single (the same) library.

An object within the library can be left out of the link, if it does not provide symbols, that the
symbol table needs.

>> If object or library AA needs a symbol from library BB, 
>> then AA should come before library BB in the command-line invocation of the linker.

```
$ cat simplemain.c
int func(int);
int main(int argc, const char* argv[])
{
    return func(argc);
}

$ cat func_dep.c
int bar(int);
int func(int i) {
    return bar(i + 1);
}

$ cat bar_dep.c
int func(int);
int bar(int i) {
    if (i > 3)
        return i;
    else
        return func(i);
}
```
See `./link1.sh`: `gcc  simplemain.o -L. -lfunc_dep -lbar_dep` works, the other not.
Q: What undefined symbols does the symbol table contain when the linker first sees `-lfunc_dep`?
A: 
1. main
```
000000000000000e T main
                 U func
0000000000000000 t no static
```
2. library funct_dep
```
000000000000000e T func
                 U bar
0000000000000000 t no static
```
3. library bar_dep
```
000000000000000e T bar
                 U func
0000000000000000 t no static
```
With `gcc  simplemain.o -L. -lfunc_dep -lbar_dep`
after 1: symbol: [main], undefined: [func]
after 2: symbol: [main,func], undefined: [bar]
after 3: symbol: [main,func,bar], undefined: []
With `gcc  simplemain.o -L. -lbar_dep -lfunc_dep`
after 1: symbol: [main], undefined: [func]
after 2: symbol: [main], undefined: [func] (bar not in undefined table, so its dropped)
after 3: symbol: [main,func], undefined: []

Circular dependency example
```
$ cat simplemain.c
int func(int);
int main(int argc, const char* argv[])
{
    return func(argc);
}

$ cat func_dep.c
int bar(int);
int func(int i) {
    return bar(i + 1);
}

$ cat bar_dep.c
int func(int);
int frodo(int);
int bar(int i) {
    if (i > 3)
        return frodo(i);
    else
        return func(i);
}

$ cat frodo_dep.c
int frodo(int i) {
    return 6 * i;
}
```
No matter the order, linking fails:
- `gcc  -L. simplemain.o -lfunc_dep -lbar_dep -lfrodo_dep`
- `gcc  -L. simplemain.o -lbar_dep -lfunc_dep -lfrodo_dep`
It is very much valid to list a library more than once on the linker line:
- `gcc  -L. simplemain.o -lfunc_dep -lbar_dep -lfunc_dep -lfrodo_dep`

Q: Does - `gcc  -L. simplemain.o -lbar_dep -lfunc_dep -lbar_dep -lfrodo_dep` work?
A:
```
main
000000000000000e T main
                 U func
bar_dep
000000000000000e T bar
                 U func
                 U frodo
func_dep
000000000000000e T func
                 U bar
frodo_dep
000000000000000e T frodo
```

- after simplemain: sy: [main], un: [func]
- after bar_dep: sy: [main], un: [func,frodo]
- after func_dep: sy: [main,func], un: [frodo,bar]
- after bar_dep: sy: [main,func,bar], un: [frodo]
- after frodo_dep: sy: [main,func,bar,frodo], un: []

Yes.

Advice:
- 1. Use `-###` to tell gcc showing the full commands it passes
- 2. Use `nm` to show the symbol table.
