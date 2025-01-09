const std = @import("std");
const slice = @import("slice.zig");
const array = @import("array.zig");
const iterator = @import("iterator.zig");

pub const ArrayIterator = array.ArrayIterator;
pub const SliceIterator = slice.SliceIterator;
pub const Iterator = iterator.Iterator;

test "all" {
    _ = @import("slice.zig");
    _ = @import("array.zig");
    _ = @import("iterator.zig");
}
