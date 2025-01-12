const std = @import("std");
const slice = @import("slice.zig");
const array = @import("array.zig");
const iterator = @import("iterator.zig");
const filter = @import("filter.zig");
const map = @import("map.zig");

pub const FilterIterator = filter.FilterIterator;
pub const MapIterator = map.MapIterator;
pub const ArrayIterator = array.ArrayIterator;
pub const SliceIterator = slice.SliceIterator;
pub const Iterator = iterator.Iterator;

test "all" {
    _ = @import("filter.zig");
    _ = @import("slice.zig");
    _ = @import("array.zig");
    _ = @import("iterator.zig");
    _ = @import("map.zig");
}
