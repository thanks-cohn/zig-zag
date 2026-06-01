const std = @import("std");
const errors = @import("errors.zig");
const log = @import("log.zig");
const paths = @import("paths.zig");

const artifacts = [_][]const u8{
    ".zig-cache",
    "zig-out",
};

pub fn run(allocator: std.mem.Allocator) !u8 {
    _ = allocator;

    if (!paths.fileExists("build.zig")) {
        errors.printBreadcrumb(.{
            .code = errors.ZAG_E_NO_BUILD_ZIG,
            .where = "clean/current-project",
            .what = "expected build.zig in current directory",
            .path = "./build.zig",
            .when = "before cleaning build artifacts",
            .why = "zag clean must be used inside a Zig project",
            .next = "run `pwd`; run `ls`; or create a project with `zag new my_app`",
        });
        return 1;
    }

    log.pass("build.zig found", .{});

    for (artifacts) |artifact| {
        if (!cleanArtifact(artifact)) {
            return 1;
        }
    }

    return 0;
}

fn cleanArtifact(artifact: []const u8) bool {
    const exists = artifactExists(artifact) catch {
        errors.printBreadcrumb(.{
            .code = errors.ZAG_E_CLEAN_FAILED,
            .where = "clean/check-artifact",
            .what = "could not inspect build artifact",
            .path = artifact,
            .when = "before cleaning build artifacts",
            .why = "the artifact may be inaccessible or permissions may be denied",
            .next = "inspect permissions with `ls -la`; remove manually if safe",
        });
        return false;
    };

    if (!exists) {
        log.pass("{s} already clean", .{artifact});
        return true;
    }

    std.fs.cwd().deleteTree(artifact) catch {
        errors.printBreadcrumb(.{
            .code = errors.ZAG_E_CLEAN_FAILED,
            .where = "clean/remove-artifact",
            .what = "could not remove build artifact",
            .path = artifact,
            .when = "while cleaning build artifacts",
            .why = "the artifact may be locked, permission denied, or not removable",
            .next = "inspect permissions with `ls -la`; remove manually if safe",
        });
        return false;
    };

    log.pass("removed {s}", .{artifact});
    return true;
}

fn artifactExists(artifact: []const u8) !bool {
    std.fs.cwd().access(artifact, .{}) catch |err| switch (err) {
        error.FileNotFound => return false,
        else => return err,
    };
    return true;
}
