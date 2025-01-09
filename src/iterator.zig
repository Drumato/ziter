const std = @import("std");

/// Iterator is an interface of the iterable object.
pub fn Iterator(comptime Impl: type, comptime T: type) type {
    return struct {
        impl: Impl,

        pub fn init(impl: Impl) @This() {
            // TODO: check the implementation satisfies the iterator interface at comptime.
            return @This(){
                .impl = impl,
            };
        }

        pub fn next(self: *@This()) ?T {
            return self.impl.next();
        }

        pub fn reset(self: *@This()) void {
            self.impl.reset();
        }

        pub fn all(
            self: *@This(),
            satisfy_fn: *const fn (v: T) bool,
        ) bool {
            while (self.next()) |v| {
                if (!satisfy_fn(v)) {
                    return false;
                }
            }
            self.reset();
            return true;
        }
    };
}

const array = @import("array.zig");
fn satisfy_fn_for_test(v: i64) bool {
    return v == 1;
}

test "Iterator all" {
    const I = array.ArrayIterator(i64, 3);

    // all elements satisfy
    {
        var iter = Iterator(I, i64).init(I.init([_]i64{ 1, 1, 1 }));

        try std.testing.expect(iter.all(satisfy_fn_for_test));
    }

    // one element doesn't satisfy
    {
        var iter = Iterator(I, i64).init(I.init([_]i64{ 1, 1, 10 }));

        try std.testing.expect(!iter.all(satisfy_fn_for_test));
    }

    // no one element satisfy
    {
        var iter = Iterator(I, i64).init(I.init([_]i64{ 5, 6, 10 }));

        try std.testing.expect(!iter.all(satisfy_fn_for_test));
    }
}
