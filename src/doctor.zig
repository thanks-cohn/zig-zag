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
        errors.printBreadcrumb(.{
            .code = errors.ZAG_E_NOT_WRITABLE,
            .where = "doctor/current-directory",
            .what = "current directory is not writable",
            .path = ".",
            .why = "zag needs to create files for generated projects",
            .next = "run `pwd` and check directory permissions",
        });
    }

    const zig_version = readZigVersion(allocator) catch |err| blk: {
        failed = true;
        log.fail("zig found", .{});
        const code = if (err == errors.ZagError.ZigNotFound) errors.ZAG_E_ZIG_NOT_FOUND else errors.ZAG_E_CHILD_FAILED;
        errors.printBreadcrumb(.{
            .code = code,
            .where = "doctor/zig-version",
            .what = "zig version could not be executed successfully",
            .path = "zig",
            .why = "Zig is not installed, is not on PATH, or returned an error",
            .next = "run `zig version`; inspect `zig-version.txt`",
        });
        break :blk null;
    };
    if (zig_version) |text| {
        defer allocator.free(text);
        const trimmed = std.mem.trim(u8, text, " \t\r\n");
        log.pass("zig found: {s}", .{trimmed});
    }

    const template_paths = project.findTemplatePaths(allocator) catch blk: {
        failed = true;
        log.fail("templates/basic found", .{});
        printTemplateBreadcrumb("doctor/templates/basic", "expected template directory is missing", "templates/basic");
        log.fail("basic build.zig found", .{});
        printTemplateBreadcrumb("doctor/templates/basic/build.zig", "template file could not be checked because templates/basic is missing", "templates/basic/build.zig");
        log.fail("basic src/main.zig found", .{});
        printTemplateBreadcrumb("doctor/templates/basic/src/main.zig", "template file could not be checked because templates/basic is missing", "templates/basic/src/main.zig");
        break :blk null;
    };
    if (template_paths) |tp| {
        defer tp.deinit(allocator);

        if (paths.dirExists(tp.basic_dir)) {
            log.pass("templates/basic found", .{});
        } else {
            failed = true;
            log.fail("templates/basic found", .{});
            printTemplateBreadcrumb("doctor/templates/basic", "expected template directory is missing", tp.basic_dir);
        }

        if (paths.fileExists(tp.build_file)) {
            log.pass("basic build.zig found", .{});
        } else {
            failed = true;
            log.fail("basic build.zig found", .{});
            printTemplateBreadcrumb("doctor/templates/basic/build.zig", "expected template file is missing", tp.build_file);
        }

        if (paths.fileExists(tp.main_file)) {
            log.pass("basic src/main.zig found", .{});
        } else {
            failed = true;
            log.fail("basic src/main.zig found", .{});
            printTemplateBreadcrumb("doctor/templates/basic/src/main.zig", "expected template file is missing", tp.main_file);
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

fn printTemplateBreadcrumb(where: []const u8, what: []const u8, path: []const u8) void {
    errors.printBreadcrumb(.{
        .code = errors.ZAG_E_TEMPLATE_MISSING,
        .where = where,
        .what = what,
        .path = path,
        .why = "template directory is incomplete or repo checkout is damaged",
        .next = "run `git status`; inspect the template path",
    });
}
