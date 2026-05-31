const std = @import("std");

pub fn out(comptime fmt: []const u8, args: anytype) void {
    std.debug.print(fmt ++ "\n", args);
}

pub fn err(comptime fmt: []const u8, args: anytype) void {
    std.debug.print("error: " ++ fmt ++ "\n", args);
}

pub fn note(comptime fmt: []const u8, args: anytype) void {
    std.debug.print("note: " ++ fmt ++ "\n", args);
}

pub fn pass(comptime fmt: []const u8, args: anytype) void {
    std.debug.print("[PASS] " ++ fmt ++ "\n", args);
}

pub fn fail(comptime fmt: []const u8, args: anytype) void {
    std.debug.print("[FAIL] " ++ fmt ++ "\n", args);
}
