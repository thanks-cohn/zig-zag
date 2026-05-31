const std = @import("std");
const fs = @import("fs.zig");
const log = @import("log.zig");

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
    try validateName(name);

    if (fs.pathExists(name)) {
        log.errorMsg("project '{s}' already exists", .{name});
        log.note("why: zag new refuses to overwrite existing files", .{});
        log.note("inspect next: choose a different name or inspect './{s}'", .{name});
        return error.ProjectAlreadyExists;
    }

    const template_paths = findTemplatePaths(allocator) catch |err| {
        log.errorMsg("basic template not found: {s}", .{@errorName(err)});
        log.note("why: zag new requires a real template at './templates/basic' or beside the built zag binary", .{});
        log.note("inspect next: run 'zag doctor' from the zig.zg repository root", .{});
        return err;
    };
    defer template_paths.deinit(allocator);

    const build_contents = fs.readFileAlloc(allocator, template_paths.build_file) catch |err| {
        log.errorMsg("failed to read '{s}': {s}", .{ template_paths.build_file, @errorName(err) });
        log.note("why: the basic template is incomplete or unreadable", .{});
        log.note("inspect next: inspect '{s}'", .{template_paths.build_file});
        return err;
    };
    defer allocator.free(build_contents);

    const main_contents = fs.readFileAlloc(allocator, template_paths.main_file) catch |err| {
        log.errorMsg("failed to read '{s}': {s}", .{ template_paths.main_file, @errorName(err) });
        log.note("why: the basic template is incomplete or unreadable", .{});
        log.note("inspect next: inspect '{s}'", .{template_paths.main_file});
        return err;
    };
    defer allocator.free(main_contents);

    fs.ensureDir(name) catch |err| {
        log.errorMsg("failed to create project directory './{s}': {s}", .{ name, @errorName(err) });
        log.note("why: the current directory may not be writable", .{});
        log.note("inspect next: run 'pwd' and check directory permissions", .{});
        return err;
    };

    errdefer std.fs.cwd().deleteTree(name) catch {};

    const src_path = try std.fs.path.join(allocator, &[_][]const u8{ name, "src" });
    defer allocator.free(src_path);
    fs.ensureDir(src_path) catch |err| {
        log.errorMsg("failed to create source directory './{s}': {s}", .{ src_path, @errorName(err) });
        log.note("why: the destination may not be writable", .{});
        log.note("inspect next: inspect './{s}'", .{name});
        return err;
    };

    const out_build = try std.fs.path.join(allocator, &[_][]const u8{ name, "build.zig" });
    defer allocator.free(out_build);
    const out_main = try std.fs.path.join(allocator, &[_][]const u8{ name, "src", "main.zig" });
    defer allocator.free(out_main);

    fs.writeFileExclusive(out_build, build_contents) catch |err| {
        log.errorMsg("failed to write './{s}': {s}", .{ out_build, @errorName(err) });
        log.note("why: the destination may not be writable or may already contain files", .{});
        log.note("inspect next: inspect './{s}'", .{name});
        return err;
    };

    fs.writeFileExclusive(out_main, main_contents) catch |err| {
        log.errorMsg("failed to write './{s}': {s}", .{ out_main, @errorName(err) });
        log.note("why: the destination may not be writable or may already contain files", .{});
        log.note("inspect next: inspect './{s}'", .{name});
        return err;
    };

    log.info("created project: {s}", .{name});
    log.info("next steps:", .{});
    log.info("  cd {s}", .{name});
    log.info("  zig build", .{});
    log.info("  zig build run", .{});
}

fn validateName(name: []const u8) !void {
    if (name.len == 0) {
        log.errorMsg("project name is empty", .{});
        log.note("why: zag new needs a directory name", .{});
        log.note("inspect next: run 'zag help'", .{});
        return error.InvalidProjectName;
    }

    if (std.mem.indexOfScalar(u8, name, '/') != null or std.mem.indexOfScalar(u8, name, '\\') != null) {
        log.errorMsg("invalid project name '{s}'", .{name});
        log.note("why: project names must be a single directory name, not a path", .{});
        log.note("inspect next: use a name like 'my_app'", .{});
        return error.InvalidProjectName;
    }

    for (name) |ch| {
        const ok = std.ascii.isAlphanumeric(ch) or ch == '_' or ch == '-';
        if (!ok) {
            log.errorMsg("invalid project name '{s}'", .{name});
            log.note("why: only letters, numbers, '-' and '_' are supported", .{});
            log.note("inspect next: use a name like 'my_app'", .{});
            return error.InvalidProjectName;
        }
    }
}


pub fn findTemplatePaths(allocator: std.mem.Allocator) !TemplatePaths {
    if (fs.dirExists("templates/basic")) {
        return TemplatePaths{
            .templates_dir = try allocator.dupe(u8, "templates"),
            .basic_dir = try allocator.dupe(u8, "templates/basic"),
            .build_file = try allocator.dupe(u8, "templates/basic/build.zig"),
            .main_file = try allocator.dupe(u8, "templates/basic/src/main.zig"),
        };
    }

    const exe_path = try std.fs.selfExePathAlloc(allocator);
    defer allocator.free(exe_path);

    const exe_dir = std.fs.path.dirname(exe_path) orelse return error.ExecutableDirectoryMissing;
    const install_root = std.fs.path.dirname(std.fs.path.dirname(exe_dir) orelse exe_dir) orelse exe_dir;
    const templates_dir = try std.fs.path.join(allocator, &[_][]const u8{ install_root, "templates" });
    errdefer allocator.free(templates_dir);

    const basic_dir = try std.fs.path.join(allocator, &[_][]const u8{ templates_dir, "basic" });
    errdefer allocator.free(basic_dir);

    if (!fs.dirExists(templates_dir)) return error.TemplatesDirectoryMissing;
    if (!fs.dirExists(basic_dir)) return error.BasicTemplateMissing;

    const build_file = try std.fs.path.join(allocator, &[_][]const u8{ basic_dir, "build.zig" });
    errdefer allocator.free(build_file);

    const main_file = try std.fs.path.join(allocator, &[_][]const u8{ basic_dir, "src", "main.zig" });
    errdefer allocator.free(main_file);

    return TemplatePaths{
        .templates_dir = templates_dir,
        .basic_dir = basic_dir,
        .build_file = build_file,
        .main_file = main_file,
    };
}
