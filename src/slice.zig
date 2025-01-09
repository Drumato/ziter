const std = @import("std");
const ziter = @import("ziter.zig");

pub fn SliceIterator(comptime T: type) type {
    return struct {
        items: []T,
        index: usize,

        pub fn init(items: []T) @This() {
            return @This(){
                .items = items,
                .index = 0,
            };
        }

        pub fn next(self: *@This()) ?T {
            if (self.index >= self.items.len) {
                return null;
            }

            const v = self.items[self.index];
            self.index += 1;
            return v;
        }

        pub fn reset(self: *@This()) void {
            self.index = 0;
        }
    };
}

test "SliceIterator next" {
    // to avoid implicity casting to pointer of array, use var instead of const.
    var base = [_]i64{ 1, 2, 3, 4, 5 };
    var iter = SliceIterator(i64).init(base[0..base.len]);

    try std.testing.expectEqual(1, iter.next());
    try std.testing.expectEqual(2, iter.next());
    try std.testing.expectEqual(3, iter.next());
    try std.testing.expectEqual(4, iter.next());
    try std.testing.expectEqual(5, iter.next());
    try std.testing.expectEqual(null, iter.next());
}

test "SliceIterator reset" {
    var base = [_]i64{ 1, 2, 3, 4, 5 };
    var iter = SliceIterator(i64).init(base[0..base.len]);

    try std.testing.expectEqual(1, iter.next());
    iter.reset();
    try std.testing.expectEqual(1, iter.next());
}
