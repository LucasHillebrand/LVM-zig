const std = @import("std");

pub fn errhandl(err: anytype, errc: *u64, comptime T: type) T {
    errc.* += 1;
    std.debug.print("ERROR!: {any}\n", .{err});
    return if (T != void) undefined;
}

pub fn print(comptime str: []const u8, args: anytype, errc: *u64) void {
    std.io.getStdOut().writer().print(str, args) catch |err| errhandl(err, errc, void);
}
