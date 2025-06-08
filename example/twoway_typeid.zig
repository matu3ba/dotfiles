// The following code and commentary is a constant-time two-way typeId idea that
// Matthew Lugg (mlugg) shared on Discord:

// mlugg:
// The "right" way to do this is, in my view, "don't do it".
// I have never seen a use case for type IDs which I actually thought was a good one --
// even if the alternative is just listing the types in an explicit array somewhere,
// I'd generally consider that better, because it's more explicit, and it's not actually
// bug-prone in any meaningful way.
// However, if you absolutely must, here is something which I think will reliably work.

pub const TypeId = *const opaque {};

pub inline fn typeId(comptime T: type) TypeId {
    const S = struct {
        /// This is a `var`, so it's guaranteed to have a unique address.
        var dummy: u8 = undefined;

        /// This needs to be a `const` because there's a `type` field in the `struct`.
        /// Because it's a `const`, in theory, it could be deduped by the linker.
        /// However, it contains a pointer to `dummy`, so that is guaranteed to never happen.
        /// One thing that's important to know: even though `TypeAndId` is a comptime-only type, pointers
        /// into runtime fields of it can exist at runtime (the runtime fields make it into the binary).
        const type_and_id: TypeAndId = .{
            .T = T,
            .dedup = &dummy,
        };
    };
    return @ptrCast(&S.type_and_id.dedup);
}

pub fn typeFromId(comptime id: TypeId) type {
    const ptr_dedup: *const *anyopaque = @ptrCast(@alignCast(id));
    const ptr_type_and_id: *const TypeAndId = @fieldParentPtr("dedup", ptr_dedup);
    return ptr_type_and_id.T;
}

const TypeAndId = struct {
    T: type,
    dedup: *anyopaque,
};

// stub for compilation check
pub fn main() void {}
