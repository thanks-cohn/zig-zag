const std = @import("std");
const checker = @import("check.zig");
const doctor = @import("doctor.zig");
const errors = @import("errors.zig");
const log = @import("log.zig");
const project = @import("project.zig");
const runner = @import("run.zig");

pub const version = "0.0.1";

pub fn run(allocator: std.mem.Allocator, args: []const []const u8) !u8 {
    if (args.len < 2) {
        printHelp();
        return 0;
    }

    const command = args[1];

    if (std.mem.eql(u8, command, "version")) {
        log.out("zag {s}", .{version});
        log.out("zig.zg application platform bootstrap", .{});
        return 0;
    }

    if (std.mem.eql(u8, command, "help") or std.mem.eql(u8, command, "--help") or std.mem.eql(u8, command, "-h")) {
        printHelp();
        return 0;
    }

    if (std.mem.eql(u8, command, "doctor")) {
        return doctor.run(allocator);
    }

    if (std.mem.eql(u8, command, "check")) {
        if (args.len != 2) {
            errors.printBreadcrumb(.{
                .code = errors.ZAG_E_IO,
                .where = "cli/check",
                .what = "expected no extra arguments",
                .why = "the command was run with unsupported arguments",
                .next = "run `zag help`",
            });
            return 1;
        }
        return checker.run(allocator);
    }

    if (std.mem.eql(u8, command, "run")) {
        if (args.len != 2) {
            errors.printBreadcrumb(.{
                .code = errors.ZAG_E_IO,
                .where = "cli/run",
                .what = "expected no extra arguments",
                .why = "the command was run with unsupported arguments",
                .next = "run `zag help`",
            });
            return 1;
        }
        return runner.run(allocator);
    }

    if (std.mem.eql(u8, command, "new")) {
        if (args.len != 3) {
            errors.printBreadcrumb(.{
                .code = errors.ZAG_E_BAD_PROJECT_NAME,
                .where = "cli/new",
                .what = "expected exactly one project name",
                .why = "the command was run without a name or with extra arguments",
                .next = "run `zag help`",
            });
            return 1;
        }
        project.create(allocator, args[2]) catch return 1;
        return 0;
    }

    errors.printBreadcrumb(.{
        .code = errors.ZAG_E_UNKNOWN_COMMAND,
        .where = "cli/dispatch",
        .what = "zag does not have that command",
        .path = command,
        .when = "while dispatching CLI arguments",
        .why = "typo or unsupported command",
        .next = "run `zag help`",
    });
    return 1;
}

fn printHelp() void {
    log.out("zag - zig.zg application platform CLI", .{});
    log.out("", .{});
    log.out("usage:", .{});
    log.out("  zag version", .{});
    log.out("  zag help", .{});
    log.out("  zag doctor", .{});
    log.out("  zag new <name>", .{});
    log.out("  zag run", .{});
    log.out("  zag check", .{});
    log.out("", .{});
    log.out("commands:", .{});
    log.out("  zag version     print the zag version", .{});
    log.out("  zag help        print this help text", .{});
    log.out("  zag doctor      run environment and template checks", .{});
    log.out("  zag new <name>  create a compilable Zig project from templates/basic", .{});
    log.out("  zag run         run the current Zig project with zig build run", .{});
    log.out("  zag check       check the current Zig project without running it", .{});
}
