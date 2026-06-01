const std = @import("std");

pub const ZagError = error{
    CurrentDirectoryNotWritable,
    ZigNotFound,
    ZigVersionFailed,
    ZigVersionEmpty,
    TemplatesDirectoryMissing,
    BasicTemplateMissing,
    BasicBuildFileMissing,
    BasicMainFileMissing,
    InvalidProjectName,
    ProjectAlreadyExists,
    ExecutableDirectoryMissing,
};

pub const ZAG_E_UNKNOWN_COMMAND = "ZAG_E_UNKNOWN_COMMAND";
pub const ZAG_E_BAD_PROJECT_NAME = "ZAG_E_BAD_PROJECT_NAME";
pub const ZAG_E_PROJECT_EXISTS = "ZAG_E_PROJECT_EXISTS";
pub const ZAG_E_TEMPLATE_MISSING = "ZAG_E_TEMPLATE_MISSING";
pub const ZAG_E_ZIG_NOT_FOUND = "ZAG_E_ZIG_NOT_FOUND";
pub const ZAG_E_NOT_WRITABLE = "ZAG_E_NOT_WRITABLE";
pub const ZAG_E_NO_BUILD_ZIG = "ZAG_E_NO_BUILD_ZIG";
pub const ZAG_E_CHILD_FAILED = "ZAG_E_CHILD_FAILED";
pub const ZAG_E_IO = "ZAG_E_IO";

pub const Breadcrumb = struct {
    code: []const u8,
    where: []const u8,
    what: []const u8,
    path: ?[]const u8 = null,
    why: []const u8,
    next: []const u8,
};

pub fn printBreadcrumb(breadcrumb: Breadcrumb) void {
    std.debug.print("error: {s}\n", .{breadcrumb.code});
    std.debug.print("where: {s}\n", .{breadcrumb.where});
    std.debug.print("what: {s}\n", .{breadcrumb.what});
    if (breadcrumb.path) |path| {
        std.debug.print("path: {s}\n", .{path});
    }
    std.debug.print("why: {s}\n", .{breadcrumb.why});
    std.debug.print("next: {s}\n", .{breadcrumb.next});
}
