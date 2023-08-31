const std = @import("std");

const SwpfError = error{
    InvalidArguments,
    RenameFailed,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const stderr = std.io.getStdErr().writer();

    if (args.len != 3) {
        try stderr.print("usage: swpf <file1> <file2>\n", .{});
        return SwpfError.InvalidArguments;
    }

    const file1 = args[1];
    const file2 = args[2];
    const tmp_file: [:0]const u8 = "swpf_tmp_file_with_stupid_huizilopochtli1234567890_name";

    try std.os.renameZ(file1, tmp_file);
    std.os.renameZ(file2, file1) catch {
        try std.os.renameZ(tmp_file, file1);
        return SwpfError.RenameFailed;
    };
    try std.os.renameZ(tmp_file, file2);
}
