#
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
