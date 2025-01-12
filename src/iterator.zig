const std = @import("std");
const FilterIterator = @import("filter.zig").FilterIterator;
const MapIterator = @import("map.zig").MapIterator;

/// Iterator is an interface of the iterable object.
pub fn Iterator(comptime Impl: type, comptime T: type) type {
    return struct {
        impl: Impl,

        // i for enum_next()
        i: usize,

        const Self = @This()(Impl, T);

        pub fn init(impl: Impl) @This() {
            // TODO: check the implementation satisfies the iterator interface at comptime.
            return @This(){
                .impl = impl,
                .i = 0,
            };
        }

        pub fn next(self: *@This()) ?T {
            return self.impl.next();
        }

        pub fn reset(self: *@This()) void {
            self.impl.reset();
        }

        pub fn deinit(self: *@This()) void {
            if (!@hasDecl(Impl, "deinit")) {
                false;
            }

            self.impl.deinit();
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

        pub fn any(
            self: *@This(),
            satisfy_fn: *const fn (v: T) bool,
        ) bool {
            while (self.next()) |v| {
                if (satisfy_fn(v)) {
                    return true;
                }
            }
            self.reset();
            return false;
        }

        pub const EnumerateItem = struct {
            value: T,
            i: usize,
        };

        pub fn enum_next(
            self: *@This(),
        ) ?EnumerateItem {
            if (self.next()) |v| {
                const i = self.i;
                self.i += 1;
                return EnumerateItem{ .value = v, .i = i };
            }

            return null;
        }

        pub fn filter(
            self: *@This(),
            filter_fn: *const fn (v: T) bool,
        ) !Iterator(FilterIterator(Impl, T), T) {
            return Iterator(
                FilterIterator(Impl, T),
                T,
            ).init(
                FilterIterator(Impl, T).init(self.impl, filter_fn),
            );
        }

        pub fn map(
            self: *@This(),
            comptime U: type,
            map_fn: *const fn (v: T) U,
        ) !Iterator(MapIterator(Impl, T, U), U) {
            return Iterator(
                MapIterator(Impl, T, U),
                U,
            ).init(
                MapIterator(Impl, T, U).init(self.impl, map_fn),
            );
        }

        pub fn fold_left(
            self: *@This(),
            comptime U: type,
            init_value: U,
            fold_fn: *const fn (acc: U, v: T) U,
        ) U {
            var acc = init_value;
            while (self.next()) |v| {
                acc = fold_fn(acc, v);
            }
            self.reset();
            return acc;
        }

        pub fn for_each(
            self: *@This(),
            for_each_fn: *const fn (v: T) void,
        ) !Iterator(MapIterator(Impl, T, void), void) {
            return Iterator(
                MapIterator(Impl, T, void),
                void,
            ).init(
                MapIterator(Impl, T, void).init(self.impl, for_each_fn),
            );
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

test "Iterator any" {
    const I = array.ArrayIterator(i64, 3);

    // one elements satisfy
    {
        var iter = Iterator(I, i64).init(I.init([_]i64{ 1, 2, 2 }));

        try std.testing.expect(iter.any(satisfy_fn_for_test));
    }

    // all element doesn't satisfy
    {
        var iter = Iterator(I, i64).init(I.init([_]i64{ 2, 2, 2 }));

        try std.testing.expect(!iter.any(satisfy_fn_for_test));
    }
}

test "Iterator enum_next" {
    const I = array.ArrayIterator(i64, 3);

    var iter = Iterator(I, i64).init(I.init([_]i64{ 1, 2, 3 }));

    const result1 = iter.enum_next().?;
    try std.testing.expectEqual(0, result1.i);
    try std.testing.expectEqual(1, result1.value);

    const result2 = iter.enum_next().?;
    try std.testing.expectEqual(1, result2.i);
    try std.testing.expectEqual(2, result2.value);

    const result3 = iter.enum_next().?;
    try std.testing.expectEqual(2, result3.i);
    try std.testing.expectEqual(3, result3.value);
}

test "Iterator filter" {
    const I = array.ArrayIterator(i64, 3);

    var iter = Iterator(I, i64).init(I.init([_]i64{ 1, 2, 3 }));

    var i = try iter.filter(satisfy_fn_for_test);

    try std.testing.expectEqual(1, i.next().?);
    try std.testing.expectEqual(null, i.next());
}

fn map_fn_for_test(v: i64) i64 {
    return v * 2;
}

test "Iterator map" {
    const I = array.ArrayIterator(i64, 3);

    var iter = Iterator(I, i64).init(I.init([_]i64{ 1, 2, 3 }));

    var i = try iter.map(i64, map_fn_for_test);

    try std.testing.expectEqual(2, i.next());
    try std.testing.expectEqual(4, i.next());
    try std.testing.expectEqual(6, i.next());
    try std.testing.expectEqual(null, i.next());
}

fn fold_left_for_test(acc: i64, v: i64) i64 {
    return acc + v;
}

test "Iterator fold_left" {
    const I = array.ArrayIterator(i64, 3);

    var iter = Iterator(I, i64).init(I.init([_]i64{ 1, 2, 3 }));

    try std.testing.expectEqual(6, iter.fold_left(i64, 0, fold_left_for_test));
}
