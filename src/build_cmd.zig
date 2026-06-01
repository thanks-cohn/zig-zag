const std = @import("std");
const errors = @import("errors.zig");
const log = @import("log.zig");
const paths = @import("paths.zig");
const zig_build = @import("zig_build.zig");

pub fn run(allocator: std.mem.Allocator) !u8 {
    if (!paths.fileExists("build.zig")) {
        errors.printBreadcrumb(.{
            .code = errors.ZAG_E_NO_BUILD_ZIG,
            .where = "build/current-project",
            .what = "expected build.zig in current directory",
            .path = "./build.zig",
            .when = "before running zig build",
            .why = "zag build must be used inside a Zig project",
            .next = "run `pwd`; run `ls`; or create a project with `zag new my_app`",
        });
        return 1;
    }

    log.pass("build.zig found", .{});

    const code = zig_build.run(allocator, .{
        .where = "build/zig-build",
        .when = "while building current Zig project",
        .start_what = "zig build could not be started",
        .start_why = "zig is not installed, is not on PATH, or the child process could not start",
        .failed_what = "zig build failed",
        .failed_why = "the project did not compile",
        .interrupted_what = "zig build failed",
        .interrupted_why = "the child process was interrupted or terminated by the operating system",
        .next = "run `zig build` directly to inspect compiler output",
    });
    if (code != 0) {
        return code;
    }

    log.pass("zig build passed", .{});
    return 0;
}
