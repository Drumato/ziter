const std = @import("std");
const ziter = @import("ziter.zig");

pub fn FilterIterator(comptime Impl: type, comptime T: type) type {
    return struct {
        impl: Impl,
        filter_fn: *const fn (v: T) bool,

        pub fn init(impl: Impl, filter_fn: *const fn (v: T) bool) @This() {
            return @This(){
                .impl = impl,
                .filter_fn = filter_fn,
            };
        }

        pub fn next(self: *@This()) ?T {
            while (self.impl.next()) |v| {
                if (self.filter_fn(v)) {
                    return v;
                }
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

fn satisfy_fn_for_test(v: i64) bool {
    return v == 1;
}

const array = @import("array.zig");
test "FilterIterator next" {
    const base = [_]i64{ 1, 2, 3, 4, 5 };
    const impl = array.ArrayIterator(i64, 5).init(base);
    var iter = FilterIterator(array.ArrayIterator(i64, 5), i64).init(impl, satisfy_fn_for_test);
    try std.testing.expectEqual(1, iter.next());
    try std.testing.expectEqual(null, iter.next());
}

test "FilterIterator reset" {}
