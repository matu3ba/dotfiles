### Synchronization

#### Synchronization basics

Except for weak memory, which may create miscompilations due to missing
formal models and/or test data.

- advanced
  * hazard pointers - `hazard_ptr.zig` idea
  * read copy update (RCU) - `rcu.zig` idea
  * epochs - `epochs.zig` idea
- medium
  * read-write locks - `wr_locks.zig` idea
  * shared\_ptr - `shared_ptr.cpp` idea
  * atomics without sequential consistency - `atomics_adv.zig` idea
- simple
  * lock - `lock.zig` idea
  * spinlock - `spinlock.zig` idea
  * atomics with sequential consistency - `atomics_seq.zig` idea

#### Synchronization data structures

Except for weak memory, which may create miscompilations due to missing
formal models and/or test data.

- advanced: wait-free algorithms (use advanced methods)
- medium: lock-free (no locks involved and not sequential consistent)
- simple: locking-based (locks or sequential consistent access)

### Data Parallelism Execution

#### SIMD routines

- advanced: portable bit compression techniques idea
- medium: portablel parallel processing idea
- simple: target-specific parallel processing idea

#### SWAR routines

- simple: reuse standard approaches idea

### Sources

missing
