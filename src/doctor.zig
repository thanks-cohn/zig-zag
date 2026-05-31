const std = @import("std");
const errors = @import("errors.zig");
const log = @import("log.zig");
const paths = @import("paths.zig");
const project = @import("project.zig");

pub fn run(allocator: std.mem.Allocator) !u8 {
    var failed = false;

    if (paths.currentDirectoryWritable()) {
        log.pass("current directory writable", .{});
    } else {
        failed = true;
        log.fail("current directory writable", .{});
        explain("current directory is not writable", "zag needs to create files for generated projects", "run 'pwd' and check directory permissions");
    }

    const zig_version = readZigVersion(allocator) catch |err| blk: {
        failed = true;
        log.fail("zig found", .{});
        explainError("zig version could not be executed successfully", "Zig is not installed, is not on PATH, or returned an error", "run 'zig version'", err);
        break :blk null;
    };
    if (zig_version) |text| {
        defer allocator.free(text);
        const trimmed = std.mem.trim(u8, text, " \t\r\n");
        log.pass("zig found: {s}", .{trimmed});
    }

    const template_paths = project.findTemplatePaths(allocator) catch |err| blk: {
        failed = true;
        log.fail("templates/basic found", .{});
        explainError("templates/basic could not be found", "the repository templates are missing or zag is running from an unsupported layout", "inspect './templates/basic' or run from the repository root", err);
        log.fail("basic build.zig found", .{});
        explain("templates/basic/build.zig could not be checked", "the basic template directory was not found", "inspect './templates/basic/build.zig'");
        log.fail("basic src/main.zig found", .{});
        explain("templates/basic/src/main.zig could not be checked", "the basic template directory was not found", "inspect './templates/basic/src/main.zig'");
        break :blk null;
    };
    if (template_paths) |tp| {
        defer tp.deinit(allocator);

        if (paths.dirExists(tp.basic_dir)) {
            log.pass("templates/basic found", .{});
        } else {
            failed = true;
            log.fail("templates/basic found", .{});
            explain("templates/basic is missing", "zag new copies the basic template directory", "inspect './templates/basic'");
        }

        if (paths.fileExists(tp.build_file)) {
            log.pass("basic build.zig found", .{});
        } else {
            failed = true;
            log.fail("basic build.zig found", .{});
            explain("templates/basic/build.zig is missing", "the basic template is incomplete", "inspect './templates/basic/build.zig'");
        }

        if (paths.fileExists(tp.main_file)) {
            log.pass("basic src/main.zig found", .{});
        } else {
            failed = true;
            log.fail("basic src/main.zig found", .{});
            explain("templates/basic/src/main.zig is missing", "the basic template is incomplete", "inspect './templates/basic/src/main.zig'");
        }
    }

    return if (failed) 1 else 0;
}

fn readZigVersion(allocator: std.mem.Allocator) ![]u8 {
    const result = std.process.Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "zig", "version" },
    }) catch return errors.ZagError.ZigNotFound;
    defer allocator.free(result.stderr);

    switch (result.term) {
        .Exited => |code| {
            if (code != 0) {
                allocator.free(result.stdout);
                return errors.ZagError.ZigVersionFailed;
            }
        },
        else => {
            allocator.free(result.stdout);
            return errors.ZagError.ZigVersionFailed;
        },
    }

    if (result.stdout.len == 0) {
        allocator.free(result.stdout);
        return errors.ZagError.ZigVersionEmpty;
    }

    return result.stdout;
}

fn explain(what_failed: []const u8, likely_cause: []const u8, next: []const u8) void {
    log.note("what failed: {s}", .{what_failed});
    log.note("likely cause: {s}", .{likely_cause});
    log.note("inspect next: {s}", .{next});
}

fn explainError(what_failed: []const u8, likely_cause: []const u8, next: []const u8, err: anyerror) void {
    log.note("what failed: {s} ({s})", .{ what_failed, @errorName(err) });
    log.note("likely cause: {s}", .{likely_cause});
    log.note("inspect next: {s}", .{next});
}
