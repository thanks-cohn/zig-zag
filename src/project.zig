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
        errors.printBreadcrumb(.{
            .code = errors.ZAG_E_PROJECT_EXISTS,
            .where = "new/destination",
            .what = "destination path already exists",
            .path = name,
            .when = "before copying template files",
            .why = "a file or directory with that name is already in the current directory",
            .next = "choose a different name or inspect the existing path",
        });
        return errors.ZagError.ProjectAlreadyExists;
    }

    const template_paths = findTemplatePaths(allocator) catch |err| {
        errors.printBreadcrumb(.{
            .code = errors.ZAG_E_TEMPLATE_MISSING,
            .where = "new/templates/basic",
            .what = "expected template directory is missing",
            .path = "templates/basic",
            .why = "template directory is incomplete or repo checkout is damaged",
            .next = "run `zag doctor`; inspect `templates/basic`",
        });
        return err;
    };
    defer template_paths.deinit(allocator);

    try ensureTemplateFile(template_paths.build_file, "new/templates/basic/build.zig", "expected template file is missing", errors.ZagError.BasicBuildFileMissing);
    try ensureTemplateFile(template_paths.main_file, "new/templates/basic/src/main.zig", "expected template file is missing", errors.ZagError.BasicMainFileMissing);

    const build_contents = paths.readFileAlloc(allocator, template_paths.build_file) catch |err| {
        printIoBreadcrumb("new/read-template", "template build.zig file could not be read", template_paths.build_file, "template file is missing or unreadable", "inspect the template file");
        return err;
    };
    defer allocator.free(build_contents);

    const main_contents = paths.readFileAlloc(allocator, template_paths.main_file) catch |err| {
        printIoBreadcrumb("new/read-template", "template src/main.zig file could not be read", template_paths.main_file, "template file is missing or unreadable", "inspect the template file");
        return err;
    };
    defer allocator.free(main_contents);

    paths.ensureDir(name) catch |err| {
        printIoBreadcrumb("new/create-directory", "could not create the destination directory", name, "the current directory is not writable", "run `pwd` and check directory permissions");
        return err;
    };
    errdefer std.fs.cwd().deleteTree(name) catch {};

    const src_path = try std.fs.path.join(allocator, &[_][]const u8{ name, "src" });
    defer allocator.free(src_path);
    paths.ensureDir(src_path) catch |err| {
        printIoBreadcrumb("new/create-src", "could not create the src directory", src_path, "the destination directory is not writable", "inspect the generated project directory");
        return err;
    };

    const out_build = try std.fs.path.join(allocator, &[_][]const u8{ name, "build.zig" });
    defer allocator.free(out_build);
    const out_main = try std.fs.path.join(allocator, &[_][]const u8{ name, "src", "main.zig" });
    defer allocator.free(out_main);

    paths.writeFileExclusive(out_build, build_contents) catch |err| {
        printIoBreadcrumb("new/write-build", "could not write generated build.zig", out_build, "the destination may not be writable or may already contain files", "inspect the generated project directory");
        return err;
    };

    paths.writeFileExclusive(out_main, main_contents) catch |err| {
        printIoBreadcrumb("new/write-main", "could not write generated src/main.zig", out_main, "the destination may not be writable or may already contain files", "inspect the generated project directory");
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
        return invalidName("project name is empty", null, "zag new needs a directory name", "run `zag help`");
    }

    if (name[0] == '.') {
        return invalidName("project names must not begin with '.'", name, "leading dots are reserved for hidden or special paths", "use a name like `hello`");
    }

    if (std.mem.indexOfScalar(u8, name, '/') != null or std.mem.indexOfScalar(u8, name, '\\') != null) {
        return invalidName("project names must be a single directory name, not a path", name, "path separators can write outside the intended destination", "use a name like `hello`");
    }

    if (std.mem.indexOf(u8, name, "..") != null) {
        return invalidName("project names must not contain '..'", name, "parent-directory segments are not safe project names", "use a name like `hello`");
    }

    for (name) |ch| {
        if (std.ascii.isWhitespace(ch)) {
            return invalidName("project names must not contain spaces", name, "spaces make generated command examples ambiguous", "use a name like `hello_app`");
        }
        if (!(std.ascii.isAlphanumeric(ch) or ch == '_' or ch == '-')) {
            return invalidName("project names may contain only letters, numbers, '-' and '_'", name, "unsupported characters are not accepted in generated project paths", "use a name like `hello_app`");
        }
    }
}

fn invalidName(what: []const u8, path: ?[]const u8, why: []const u8, next: []const u8) errors.ZagError {
    errors.printBreadcrumb(.{
        .code = errors.ZAG_E_BAD_PROJECT_NAME,
        .where = "new/validate-name",
        .what = what,
        .path = path,
        .when = "while validating project name",
        .why = why,
        .next = next,
    });
    return errors.ZagError.InvalidProjectName;
}

fn ensureTemplateFile(path: []const u8, where: []const u8, what: []const u8, err: errors.ZagError) !void {
    if (!paths.fileExists(path)) {
        errors.printBreadcrumb(.{
            .code = errors.ZAG_E_TEMPLATE_MISSING,
            .where = where,
            .what = what,
            .path = path,
            .why = "template directory is incomplete or repo checkout is damaged",
            .next = "run `zag doctor`; inspect the missing template file",
        });
        return err;
    }
}

fn printIoBreadcrumb(where: []const u8, what: []const u8, path: []const u8, why: []const u8, next: []const u8) void {
    errors.printBreadcrumb(.{
        .code = errors.ZAG_E_IO,
        .where = where,
        .what = what,
        .path = path,
        .why = why,
        .next = next,
    });
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
