const std = @import("std");
const ziter = @import("ziter.zig");

pub fn MapIterator(
    comptime Impl: type,
    comptime T: type,
    comptime U: type,
) type {
    return struct {
        impl: Impl,
        map_fn: *const fn (v: T) U,

        pub fn init(impl: Impl, map_fn: *const fn (v: T) U) @This() {
            return @This(){
                .impl = impl,
                .map_fn = map_fn,
            };
        }

        pub fn next(self: *@This()) ?U {
            if (self.impl.next()) |v| {
                return self.map_fn(v);
            }
            return null;
        }

        pub fn reset(self: *@This()) void {
            self.impl.reset();
        }

        pub fn deinit(self: @This()) void {
            self.impl.deinit();
        }
    };
}

fn map_fn_for_test(v: i64) i64 {
    return v * 2;
}

const array = @import("array.zig");
test "MapIterator next" {
    const base = [_]i64{ 1, 2, 3 };
    const impl = array.ArrayIterator(i64, 3).init(base);
    var iter = MapIterator(
        array.ArrayIterator(i64, 3),
        i64,
        i64,
    ).init(impl, map_fn_for_test);
    try std.testing.expectEqual(2, iter.next());
    try std.testing.expectEqual(4, iter.next());
    try std.testing.expectEqual(6, iter.next());
    try std.testing.expectEqual(null, iter.next());
}
