const std = @import("std");
const errors = @import("errors.zig");
const paths = @import("paths.zig");

pub fn run(allocator: std.mem.Allocator) !u8 {
    if (!paths.fileExists("build.zig")) {
        errors.printBreadcrumb(.{
            .code = errors.ZAG_E_NO_BUILD_ZIG,
            .where = "run/project-root",
            .what = "build.zig was not found in the current directory",
            .path = "build.zig",
            .why = "zag run must be used inside a Zig project",
            .next = "run `pwd`; inspect the current directory for `build.zig`",
        });
        return 1;
    }

    var child = std.process.Child.init(&[_][]const u8{ "zig", "build", "run" }, allocator);
    child.stdin_behavior = .Inherit;
    child.stdout_behavior = .Inherit;
    child.stderr_behavior = .Inherit;

    const term = child.spawnAndWait() catch {
        errors.printBreadcrumb(.{
            .code = errors.ZAG_E_CHILD_FAILED,
            .where = "run/zig-build-run",
            .what = "zig build run could not be started",
            .path = "build.zig",
            .why = "zig is not installed, is not on PATH, or the child process could not start",
            .next = "run `zig version`; run `zig build run`",
        });
        return 1;
    };

    return switch (term) {
        .Exited => |code| if (code == 0) 0 else blk: {
            errors.printBreadcrumb(.{
                .code = errors.ZAG_E_CHILD_FAILED,
                .where = "run/zig-build-run",
                .what = "zig build run exited with a non-zero status",
                .path = "build.zig",
                .why = "the Zig project build or run step failed",
                .next = "run `zig build run` from this directory",
            });
            break :blk code;
        },
        else => {
            errors.printBreadcrumb(.{
                .code = errors.ZAG_E_CHILD_FAILED,
                .where = "run/zig-build-run",
                .what = "zig build run ended without a normal exit status",
                .path = "build.zig",
                .why = "the child process was interrupted or terminated by the operating system",
                .next = "run `zig build run` from this directory",
            });
            return 1;
        },
    };
}
