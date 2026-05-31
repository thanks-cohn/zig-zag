const std = @import("std");

pub fn pathExists(path: []const u8) bool {
    std.fs.cwd().access(path, .{}) catch return false;
    return true;
}

pub fn fileExists(path: []const u8) bool {
    const file = if (std.fs.path.isAbsolute(path))
        std.fs.openFileAbsolute(path, .{}) catch return false
    else
        std.fs.cwd().openFile(path, .{}) catch return false;
    file.close();
    return true;
}

pub fn dirExists(path: []const u8) bool {
    var dir = if (std.fs.path.isAbsolute(path))
        std.fs.openDirAbsolute(path, .{}) catch return false
    else
        std.fs.cwd().openDir(path, .{}) catch return false;
    dir.close();
    return true;
}

pub fn ensureDir(path: []const u8) !void {
    try std.fs.cwd().makePath(path);
}

pub fn currentDirectoryWritable() bool {
    const probe = ".zag-write-probe.tmp";
    {
        const file = std.fs.cwd().createFile(probe, .{ .exclusive = true }) catch return false;
        file.close();
    }
    std.fs.cwd().deleteFile(probe) catch return false;
    return true;
}

pub fn writeFileExclusive(path: []const u8, contents: []const u8) !void {
    const file = try std.fs.cwd().createFile(path, .{ .exclusive = true });
    defer file.close();
    try file.writeAll(contents);
}

pub fn readFileAlloc(allocator: std.mem.Allocator, path: []const u8) ![]u8 {
    if (std.fs.path.isAbsolute(path)) {
        const file = try std.fs.openFileAbsolute(path, .{});
        defer file.close();
        return try file.readToEndAlloc(allocator, 1024 * 1024);
    }
    return try std.fs.cwd().readFileAlloc(allocator, path, 1024 * 1024);
}
