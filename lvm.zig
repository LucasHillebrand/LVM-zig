const std = @import("std");
const sys = @import("./libsrc/system.zig");
const m = @import("./libsrc/math.zig");

fn errhandl(err: anytype, errc: *u64, comptime T: type) T {
    errc.* += 1;
    std.debug.print("ERROR!: {any}\n", .{err});
    return if (T != void) undefined;
}

pub fn main() void {
    var errc: u64 = 0;
    var S: sys.system = undefined;
    if (S.init(m.pow(1024, 3) * 1)) {
        S.threads[0].register[0] = m.toArr(1337);
        S.threads[0].print();
        S.free();
    } else |err| errhandl(err, &errc, void);
    if (errc > 0) std.debug.print("errc: {d}\n", .{errc});
}
