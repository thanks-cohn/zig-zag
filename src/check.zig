const std = @import("std");
const errors = @import("errors.zig");
const log = @import("log.zig");
const paths = @import("paths.zig");

pub fn run(allocator: std.mem.Allocator) !u8 {
    if (!paths.fileExists("build.zig")) {
        errors.printBreadcrumb(.{
            .code = errors.ZAG_E_NO_BUILD_ZIG,
            .where = "check/current-project",
            .what = "expected build.zig in current directory",
            .path = "./build.zig",
            .when = "before running zig build",
            .why = "zag check must be used inside a Zig project",
            .next = "run `pwd`; run `ls`; or create a project with `zag new my_app`",
        });
        return 1;
    }

    log.pass("build.zig found", .{});

    if (paths.dirExists("src")) {
        log.pass("src directory found", .{});
    }

    var child = std.process.Child.init(&[_][]const u8{ "zig", "build" }, allocator);
    child.stdin_behavior = .Inherit;
    child.stdout_behavior = .Inherit;
    child.stderr_behavior = .Inherit;

    const term = child.spawnAndWait() catch {
        printBuildFailed("zig build could not be started", "zig is not installed, is not on PATH, or the child process could not start");
        return 1;
    };

    return switch (term) {
        .Exited => |code| if (code == 0) blk: {
            log.pass("zig build passed", .{});
            break :blk 0;
        } else blk: {
            printBuildFailed("zig build failed", "the project did not compile");
            break :blk code;
        },
        else => {
            printBuildFailed("zig build failed", "the child process was interrupted or terminated by the operating system");
            return 1;
        },
    };
}

fn printBuildFailed(what: []const u8, why: []const u8) void {
    errors.printBreadcrumb(.{
        .code = errors.ZAG_E_CHILD_FAILED,
        .where = "check/zig-build",
        .what = what,
        .path = "./build.zig",
        .when = "while checking current Zig project",
        .why = why,
        .next = "run `zig build` directly to inspect compiler output",
    });
}
