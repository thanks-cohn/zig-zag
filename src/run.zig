const std = @import("std");
const paths = @import("paths.zig");

pub fn run(allocator: std.mem.Allocator) !u8 {
    if (!paths.fileExists("build.zig")) {
        std.debug.print("failed: no build.zig found in current directory\n", .{});
        std.debug.print("likely cause: zag run must be used inside a Zig project\n", .{});
        std.debug.print("inspect: pwd; ls\n", .{});
        return 1;
    }

    var child = std.process.Child.init(&[_][]const u8{ "zig", "build", "run" }, allocator);
    child.stdin_behavior = .Inherit;
    child.stdout_behavior = .Inherit;
    child.stderr_behavior = .Inherit;

    const term = child.spawnAndWait() catch |err| {
        std.debug.print("failed: zig build run could not be started ({s})\n", .{@errorName(err)});
        std.debug.print("likely cause: zig is not installed or is not on PATH\n", .{});
        std.debug.print("inspect: zig version\n", .{});
        return 1;
    };

    return switch (term) {
        .Exited => |code| code,
        else => 1,
    };
}
