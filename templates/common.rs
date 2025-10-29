//====use_cases
//====tooling
//====design_better
//====design_flaws
//====setup

//====use_cases
//Small to medium sized projects with well-known kinda fixed semantics/problem space, since huge
//refactorings and explorative coding is slow in Rust. Besides that, one here wants the benefits of
//memory safety (and typestate programming ie preventing api misuse like deadlocking) without needing
//optimal performance (given by things like nonsequential atomics, opaque memory, non-tree like
//memory lifetimes) or have existing libraries handling that for you (or be very limited in scope).

//====tooling
// SHENNANIGAN cargo packages depend on dynamic gcc libraries during linking,
// which may not be provided
//  cargo install du-dust
//  ld: error: unable to find library -lgcc_s
//
//du-dust ripgrep sd tokei
// exa https://the.exa.website/ https://github.com/ogham/exa
// gisht https://github.com/Xion/gisht
// just https://github.com/casey/just
// mdBook https://github.com/rust-lang-nursery/mdBook
// ripgrep - ripgrep
// tokei https://github.com/XAMPPRocky/tokei
// uutils/coreutils https://github.com/uutils/coreutils
// xsv https://github.com/BurntSushi/xsv
//
// often breaking: asuran gitoxide gitui
// cli name                    | cargo package name | links
// bat                         | -                  |
// btm                         | -                  |
// cargo-config                | -                  |
// cargo-install-update        | -                  |
// cargo-install-update-config | -                  |
// cargo-make                  | -                  |
// dust                        | -                  |
// emulsion                    | -                  |
// exa                         | -                  |
// fd                          | fd-find            | https://github.com/sharkdp/fd
// hexyl                       | -                  |
// hx                          | -                  |
// hyperfine                   | hyperfine          |
// inferno-collapse-dtrace     | -                  |
// inferno-collapse-guess      | -                  |
// inferno-collapse-perf       | -                  |
// inferno-collapse-sample     | -                  |
// inferno-collapse-vtune      | -                  |
// inferno-diff-folded         | -                  |
// inferno-flamegraph          | -                  |
// interactive-rebase-tool     | -                  |
// kalk                        | -                  |
// makers                      | -                  |
// mandown                     | -                  |
// procs                       | -                  |
// rg                          | ripgrep            | https://github.com/BurntSushi/ripgrep
// rustinstalled               | -                  |
// rusty-man                   | -                  |
// sd                          | -                  |
// tcount                      | -                  |
// tokei                       | -                  |
// watchexec                   | -                  |
// xargo                       | -                  |
// xargo-check                 | -                  |
// zellij                      | -                  |
// zoxide                      | -                  |

//====design_better
//https://graydon2.dreamwidth.org/218040.html
//no
//  null pointers
//  array overruns
//  data races
//  wild pointers
//  uninitialized, yet addressable memory
//  unions that allow access to the wrong field
//no
// shared root namespace
// variables with runtime "before main" static initialization (the .ctors section)
// compilation model that relies on textual inclusion (#include) or textual elision (#ifdef)
// compilation model that relies on the order of declarations (possible caveat: macros)
// accidental identifier capture in macros
// random-access strings
// UTF-16 or UCS-2 support anywhere outside windows API compatibility routines
// signed character types
// (hah! vertical tab escapes (as recently discussed) along with the escapes for bell and form-feed)
// "accidental octal" from leading zeroes
// goto (not even as a reserved word)
// dangling else (or misgrouped control structure bodies of any sort)
// case fallthrough
// == operator you can easily typo as = and still compile
// === operator, or any set of easily-confused equality operators
// silent coercions between boolean and anything else
// silent coercions between enums and integers
// silent arithmetic coercions, promotions
// implementation-dependent sign for the result of % with negative dividend
// bitwise operators with lower precedence than comparison operators
// auto-increment operators
// poor-quality default hash function
// pointer-heavy default containers

//====design_flaws
// SHENNANIGAN
// * still not possible to write your own smart pointer which would work with dyn traits, including
// coercions
// * macros have artificial limits when called from other macros (can not put PoC into bigger
// project)
// * borrow-checker very dumb, simple things like x(&mut self.a, &mut self.b) don't work and
// require destructures, inners and other mumbo-jumbos.
// * often solution is to write macro, so lots of macros pile up and they feel like an entirely
// different language
//
// https://model-checking.github.io/verify-rust-std/

// SHENNANIGAN cargo and rustc:
// * dynamic linking to musl is broken since a very long time https://github.com/rust-lang/rust/issues/135244 and
// https://github.com/rust-lang/rust/issues/95926 and filing issues / ask how to disable proc macro and other stuff
// depending on dynamic linking is the only solution aside of rewriting or patching rust compiler
// * force static linking: set -x RUSTFLAGS "-C target-feature=+crt-static"
// * ignored on cross-compilation: cargo install stylua --features lua52 --target x86_64-unknown-linux-musl
// * proc-macro/clap needs dynamic linking: set -x RUSTFLAGS "-C target-feature=-crt-static"
// * dynamic linking on musl systems needs libc path, which should be supported by Rust,
// but not necessary on the target system

// SHENNANIGAN
// * intentionally racy reads and writes (like for parallel seeded region growing) are not
// expressible currently in Rust
//   - Function atomic_load_unordered in nightly, do not use this intrinsic as its not in memory model
//   - Function atomic_store_unordered in nightly, do not use this intrinsic as its not in memory model
//   - However, according to kprotty "unordered should still be safe to race with"
// pub struct UnorderedAtomic(UnsafeCell<i32>);
// impl UnorderedAtomic {
//     pub fn new() -> Self {
//         UnorderedAtomic(Default::default())
//     }
//     pub fn load(&self) -> i32 {
//         unsafe { atomic_load_unordered(self.0.get()) }
//     }
//     pub fn store(&self, i: i32) {
//         unsafe { atomic_store_unordered(self.0.get(), i) }
//     }
//     unsafe fn raw(&self) -> *mut i32 { self.0.get() }
// }

// SHENNANIGAN async canceling has affine semantics (cancels whole tree)
// https://sunshowers.io/posts/cancelling-async-rust/

// SHENNANIGAN not good on: buffer reuse, self-referential structs, compile-time generics (versioned generics)
// https://databento.com/blog/why-we-didnt-rewrite-our-feed-handler-in-rust

//====setup
//curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs
