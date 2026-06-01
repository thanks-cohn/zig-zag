const std = @import("std");
const errors = @import("errors.zig");

pub const FailureMessages = struct {
    where: []const u8,
    when: []const u8,
    start_what: []const u8,
    start_why: []const u8,
    failed_what: []const u8,
    failed_why: []const u8,
    interrupted_what: []const u8,
    interrupted_why: []const u8,
    next: []const u8,
};

pub fn run(allocator: std.mem.Allocator, failure: FailureMessages) u8 {
    var child = std.process.Child.init(&[_][]const u8{ "zig", "build" }, allocator);
    child.stdin_behavior = .Inherit;
    child.stdout_behavior = .Inherit;
    child.stderr_behavior = .Inherit;

    const term = child.spawnAndWait() catch {
        printBuildFailed(failure, failure.start_what, failure.start_why);
        return 1;
    };

    return switch (term) {
        .Exited => |code| if (code == 0) 0 else blk: {
            printBuildFailed(failure, failure.failed_what, failure.failed_why);
            break :blk code;
        },
        else => {
            printBuildFailed(failure, failure.interrupted_what, failure.interrupted_why);
            return 1;
        },
    };
}

fn printBuildFailed(failure: FailureMessages, what: []const u8, why: []const u8) void {
    errors.printBreadcrumb(.{
        .code = errors.ZAG_E_CHILD_FAILED,
        .where = failure.where,
        .what = what,
        .path = "./build.zig",
        .when = failure.when,
        .why = why,
        .next = failure.next,
    });
}
