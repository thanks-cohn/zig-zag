const std = @import("std");
const fs = @import("fs.zig");
const log = @import("log.zig");
const project = @import("project.zig");

pub const version = "0.1.0";

pub fn run(allocator: std.mem.Allocator, args: []const []const u8) !u8 {
    if (args.len < 2) {
        printHelp();
        return 0;
    }

    const command = args[1];

    if (std.mem.eql(u8, command, "version")) {
        log.info("zag {s}", .{version});
        return 0;
    }

    if (std.mem.eql(u8, command, "help") or std.mem.eql(u8, command, "--help") or std.mem.eql(u8, command, "-h")) {
        printHelp();
        return 0;
    }

    if (std.mem.eql(u8, command, "new")) {
        if (args.len != 3) {
            log.errorMsg("invalid arguments for 'new'", .{});
            log.note("why: 'zag new' needs exactly one project name", .{});
            log.note("inspect next: run 'zag help'", .{});
            return 1;
        }
        project.create(allocator, args[2]) catch return 1;
        return 0;
    }

    if (std.mem.eql(u8, command, "doctor")) {
        return doctor(allocator);
    }

    log.errorMsg("unknown command '{s}'", .{command});
    log.note("why: zag only supports version, help, new, and doctor in this milestone", .{});
    log.note("inspect next: run 'zag help'", .{});
    return 1;
}

fn printHelp() void {
    log.info("zag - zig.zg application platform CLI", .{});
    log.info("", .{});
    log.info("usage:", .{});
    log.info("  zag version", .{});
    log.info("  zag help", .{});
    log.info("  zag new <name>", .{});
    log.info("  zag doctor", .{});
    log.info("", .{});
    log.info("commands:", .{});
    log.info("  version       print the zag version", .{});
    log.info("  help          print this help text", .{});
    log.info("  new <name>    create a compilable Zig project from templates/basic", .{});
    log.info("  doctor        check Zig, write access, and required templates", .{});
}

fn doctor(allocator: std.mem.Allocator) !u8 {
    var failed = false;

    const zig_version = readZigVersion(allocator) catch |err| blk: {
        failed = true;
        log.errorMsg("Zig check failed: {s}", .{@errorName(err)});
        log.note("why: 'zig version' could not be executed or did not exit successfully", .{});
        log.note("inspect next: run 'zig version' and confirm Zig is on PATH", .{});
        break :blk null;
    };
    if (zig_version) |text| {
        defer allocator.free(text);
        const trimmed = std.mem.trim(u8, text, " \t\r\n");
        log.info("ok: Zig is installed ({s})", .{trimmed});
    }

    if (fs.currentDirectoryWritable()) {
        log.info("ok: current directory is writable", .{});
    } else {
        failed = true;
        log.errorMsg("current directory is not writable", .{});
        log.note("why: zag must create project directories and files", .{});
        log.note("inspect next: run 'pwd' and check directory permissions", .{});
    }

    const template_paths = project.findTemplatePaths(allocator) catch |err| blk: {
        failed = true;
        log.errorMsg("template check failed: {s}", .{@errorName(err)});
        log.note("why: zag new copies files from the basic project template", .{});
        log.note("inspect next: run from the repository root or inspect './templates/basic'", .{});
        break :blk null;
    };
    if (template_paths) |paths| {
        defer paths.deinit(allocator);
        log.info("ok: templates directory exists ({s})", .{paths.templates_dir});
        log.info("ok: basic template exists ({s})", .{paths.basic_dir});
    }

    if (failed) return 1;
    log.info("doctor: all checks passed", .{});
    return 0;
}

fn readZigVersion(allocator: std.mem.Allocator) ![]u8 {
    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "zig", "version" },
    });
    defer allocator.free(result.stderr);

    switch (result.term) {
        .Exited => |code| {
            if (code != 0) {
                allocator.free(result.stdout);
                return error.ZigVersionFailed;
            }
        },
        else => {
            allocator.free(result.stdout);
            return error.ZigVersionFailed;
        },
    }

    if (result.stdout.len == 0) {
        allocator.free(result.stdout);
        return error.ZigVersionEmpty;
    }

    return result.stdout;
}
