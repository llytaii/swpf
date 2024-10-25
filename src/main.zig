const std = @import("std");
const mem = std.mem;
const os = std.os;
const assert = std.debug.assert;

fn validateArgs(args: [][]const u8) !void {
    if (args.len != 3) return error.InvalidArgCount;

    const stat1 = try std.fs.cwd().statFile(args[1]);
    if (stat1.kind != .file) return error.Arg1IsNotAFile;

    const stat2 = try std.fs.cwd().statFile(args[2]);
    if (stat2.kind != .file) return error.Arg2IsNotAFile;

    if (mem.eql(u8, args[1], args[2])) return error.ArgsAreTheSameFileName;
}

fn printHelpTo(writer: anytype) !void {
    try writer.print("usage: swpf <file1> <file2>\n", .{});
    try writer.print("description: swaps the given files\n", .{});
    try writer.print("note: files must be different and reside in the current working directory.\n", .{});
}

fn swapFiles(file1: []const u8, file2: []const u8) !void {
    const tmp_file = "very_long_and_stupid_random_name1224123huizilopochtli_1212121212";
    comptime assert(tmp_file.len < 250); // 256 chars is the file size limit on linux

    assert(!mem.eql(u8, file1, tmp_file));
    assert(!mem.eql(u8, file2, tmp_file));

    try std.posix.rename(file1, tmp_file);
    try std.posix.rename(file2, file1);
    try std.posix.rename(tmp_file, file2);
}

pub fn main() !void {
    // allocations
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // help
    if (args.len == 2 and mem.eql(u8, args[1], "--help")) {
        const stdout = std.io.getStdOut().writer();
        try printHelpTo(stdout);
        return;
    }

    // validations
    const stderr = std.io.getStdErr().writer();

    validateArgs(args) catch |err| {
        try stderr.print("{}\n\n", .{err});
        try printHelpTo(stderr);
        return;
    };

    // swapping
    swapFiles(args[1], args[2]) catch |err| {
        try stderr.print("error {} while swapping, manual intervention necessary!\n", .{err});
    };
}
