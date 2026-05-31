const std = @import("std");
const errors = @import("errors.zig");
const log = @import("log.zig");
const paths = @import("paths.zig");

pub const TemplatePaths = struct {
    templates_dir: []u8,
    basic_dir: []u8,
    build_file: []u8,
    main_file: []u8,

    pub fn deinit(self: TemplatePaths, allocator: std.mem.Allocator) void {
        allocator.free(self.templates_dir);
        allocator.free(self.basic_dir);
        allocator.free(self.build_file);
        allocator.free(self.main_file);
    }
};

pub fn create(allocator: std.mem.Allocator, name: []const u8) !void {
    validateName(name) catch |err| return err;

    if (paths.pathExists(name)) {
        log.err("project '{s}' already exists", .{name});
        log.note("what failed: the destination path already exists", .{});
        log.note("likely cause: a file or directory named '{s}' is already in this directory", .{name});
        log.note("inspect next: choose a different name or inspect './{s}'", .{name});
        return errors.ZagError.ProjectAlreadyExists;
    }

    const template_paths = findTemplatePaths(allocator) catch |err| {
        log.err("basic template not available: {s}", .{@errorName(err)});
        log.note("what failed: zag could not locate the basic project template", .{});
        log.note("likely cause: the templates/basic directory is missing or zag is being run from an unexpected install layout", .{});
        log.note("inspect next: run 'zag doctor' or inspect './templates/basic'", .{});
        return err;
    };
    defer template_paths.deinit(allocator);

    const build_contents = paths.readFileAlloc(allocator, template_paths.build_file) catch |err| {
        log.err("failed to read '{s}': {s}", .{ template_paths.build_file, @errorName(err) });
        log.note("what failed: the template build.zig file could not be read", .{});
        log.note("likely cause: the template file is missing or unreadable", .{});
        log.note("inspect next: inspect '{s}'", .{template_paths.build_file});
        return err;
    };
    defer allocator.free(build_contents);

    const main_contents = paths.readFileAlloc(allocator, template_paths.main_file) catch |err| {
        log.err("failed to read '{s}': {s}", .{ template_paths.main_file, @errorName(err) });
        log.note("what failed: the template src/main.zig file could not be read", .{});
        log.note("likely cause: the template file is missing or unreadable", .{});
        log.note("inspect next: inspect '{s}'", .{template_paths.main_file});
        return err;
    };
    defer allocator.free(main_contents);

    paths.ensureDir(name) catch |err| {
        log.err("failed to create project directory './{s}': {s}", .{ name, @errorName(err) });
        log.note("what failed: zag could not create the destination directory", .{});
        log.note("likely cause: the current directory is not writable", .{});
        log.note("inspect next: run 'pwd' and check directory permissions", .{});
        return err;
    };
    errdefer std.fs.cwd().deleteTree(name) catch {};

    const src_path = try std.fs.path.join(allocator, &[_][]const u8{ name, "src" });
    defer allocator.free(src_path);
    paths.ensureDir(src_path) catch |err| {
        log.err("failed to create source directory './{s}': {s}", .{ src_path, @errorName(err) });
        log.note("what failed: zag could not create the src directory", .{});
        log.note("likely cause: the destination directory is not writable", .{});
        log.note("inspect next: inspect './{s}'", .{name});
        return err;
    };

    const out_build = try std.fs.path.join(allocator, &[_][]const u8{ name, "build.zig" });
    defer allocator.free(out_build);
    const out_main = try std.fs.path.join(allocator, &[_][]const u8{ name, "src", "main.zig" });
    defer allocator.free(out_main);

    paths.writeFileExclusive(out_build, build_contents) catch |err| {
        log.err("failed to write './{s}': {s}", .{ out_build, @errorName(err) });
        log.note("what failed: zag could not write the generated build.zig", .{});
        log.note("likely cause: the destination may not be writable or may already contain files", .{});
        log.note("inspect next: inspect './{s}'", .{name});
        return err;
    };

    paths.writeFileExclusive(out_main, main_contents) catch |err| {
        log.err("failed to write './{s}': {s}", .{ out_main, @errorName(err) });
        log.note("what failed: zag could not write the generated src/main.zig", .{});
        log.note("likely cause: the destination may not be writable or may already contain files", .{});
        log.note("inspect next: inspect './{s}'", .{name});
        return err;
    };

    log.out("created project: {s}", .{name});
    log.out("next steps:", .{});
    log.out("  cd {s}", .{name});
    log.out("  zig build", .{});
    log.out("  zig build run", .{});
}

fn validateName(name: []const u8) !void {
    if (name.len == 0) {
        return invalidName("project name is empty", "zag new needs a directory name", "run 'zag help'", .{});
    }

    if (name[0] == '.') {
        return invalidName("invalid project name '{s}'", "project names must not begin with '.'", "use a name like 'hello'", .{name});
    }

    if (std.mem.indexOfScalar(u8, name, '/') != null or std.mem.indexOfScalar(u8, name, '\\') != null) {
        return invalidName("invalid project name '{s}'", "project names must be a single directory name, not a path", "use a name like 'hello'", .{name});
    }

    if (std.mem.indexOf(u8, name, "..") != null) {
        return invalidName("invalid project name '{s}'", "project names must not contain '..'", "use a name like 'hello'", .{name});
    }

    for (name) |ch| {
        if (std.ascii.isWhitespace(ch)) {
            return invalidName("invalid project name '{s}'", "project names must not contain spaces", "use a name like 'hello_app'", .{name});
        }
        if (!(std.ascii.isAlphanumeric(ch) or ch == '_' or ch == '-')) {
            return invalidName("invalid project name '{s}'", "project names may contain only letters, numbers, '-' and '_'", "use a name like 'hello_app'", .{name});
        }
    }
}

fn invalidName(comptime message: []const u8, comptime cause: []const u8, comptime next: []const u8, args: anytype) errors.ZagError {
    log.err(message, args);
    log.note("what failed: project name validation", .{});
    log.note("likely cause: {s}", .{cause});
    log.note("inspect next: {s}", .{next});
    return errors.ZagError.InvalidProjectName;
}

pub fn findTemplatePaths(allocator: std.mem.Allocator) !TemplatePaths {
    if (paths.dirExists("templates/basic")) {
        return makeTemplatePaths(allocator, "templates", "templates/basic");
    }

    const exe_path = try std.fs.selfExePathAlloc(allocator);
    defer allocator.free(exe_path);

    const exe_dir = std.fs.path.dirname(exe_path) orelse return errors.ZagError.ExecutableDirectoryMissing;
    const zig_out_dir = std.fs.path.dirname(exe_dir) orelse exe_dir;
    const repo_root = std.fs.path.dirname(zig_out_dir) orelse zig_out_dir;
    const templates_dir = try std.fs.path.join(allocator, &[_][]const u8{ repo_root, "templates" });
    defer allocator.free(templates_dir);
    const basic_dir = try std.fs.path.join(allocator, &[_][]const u8{ templates_dir, "basic" });
    defer allocator.free(basic_dir);

    if (!paths.dirExists(templates_dir)) return errors.ZagError.TemplatesDirectoryMissing;
    if (!paths.dirExists(basic_dir)) return errors.ZagError.BasicTemplateMissing;

    return makeTemplatePaths(allocator, templates_dir, basic_dir);
}

fn makeTemplatePaths(allocator: std.mem.Allocator, templates_dir: []const u8, basic_dir: []const u8) !TemplatePaths {
    const build_file = try std.fs.path.join(allocator, &[_][]const u8{ basic_dir, "build.zig" });
    errdefer allocator.free(build_file);
    const main_file = try std.fs.path.join(allocator, &[_][]const u8{ basic_dir, "src", "main.zig" });
    errdefer allocator.free(main_file);

    return TemplatePaths{
        .templates_dir = try allocator.dupe(u8, templates_dir),
        .basic_dir = try allocator.dupe(u8, basic_dir),
        .build_file = build_file,
        .main_file = main_file,
    };
}
