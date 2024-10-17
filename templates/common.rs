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