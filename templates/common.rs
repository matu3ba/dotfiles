//====use_cases
//====tooling
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

//====design_flaws
// SHENNANIGANs
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

// SHENNANIGANs cargo and rustc:
// * dynamic linking to musl is broken since a very long time https://github.com/rust-lang/rust/issues/135244 and
// https://github.com/rust-lang/rust/issues/95926 and filing issues / ask how to disable proc macro and other stuff
// depending on dynamic linking is the only solution aside of rewriting or patching rust compiler
// * force static linking: set -x RUSTFLAGS "-C target-feature=+crt-static"
// * ignored on cross-compilation: cargo install stylua --features lua52 --target x86_64-unknown-linux-musl
// * proc-macro/clap needs dynamic linking: set -x RUSTFLAGS "-C target-feature=-crt-static"
// * dynamic linking on musl systems needs libc path, which should be supported by Rust,
// but not necessary on the target system

// SHENNANIGANs
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

//====setup
//curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs
