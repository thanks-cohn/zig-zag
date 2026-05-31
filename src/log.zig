const std = @import("std");

pub fn info(comptime fmt: []const u8, args: anytype) void {
    std.debug.print(fmt ++ "\n", args);
}

pub fn errorMsg(comptime fmt: []const u8, args: anytype) void {
    std.debug.print("error: " ++ fmt ++ "\n", args);
}

pub fn note(comptime fmt: []const u8, args: anytype) void {
    std.debug.print("note: " ++ fmt ++ "\n", args);
}
