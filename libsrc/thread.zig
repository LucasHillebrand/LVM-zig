const m = @import("./math.zig");
const std = @import("std");

pub const thread = struct {
    register: [8][8]u8,
    pc: u64, // programm counter
    cba: u64, // current bus address
    status: u1, // status (1 => runnnung, 0 => not running)

    pub fn add(self: *thread, args: [3]u8) void {
        self.register[args[0]] = m.add(self.register[args[1]], self.register[args[2]]);
    }
    pub fn sub(self: *thread, args: [3]u8) void {
        self.register[args[0]] = m.sub(self.register[args[1]], self.register[args[2]]);
    }
    pub fn sma(self: *thread, args: [3]u8) void {
        self.cba = m.toInt(self.register[args[0]]);
    }
    pub fn jmp(self: *thread, args: [3]u8) void {
        self.pc = m.toInt(self.register[args[0]]);
    }
    pub fn jiz(self: *thread, args: [3]u8) void {
        if (m.isEQ(self.register[args[1]], m.toArr(0))) self.pc = m.toInt(self.register[args[0]]);
    }
    pub fn jnz(self: *thread, args: [3]u8) void {
        if (!m.isEQ(self.register[args[1]], m.toArr(0))) self.pc = m.toInt(self.register[args[0]]);
    }
    pub fn srb(self: *thread, args: [3]u8) void {
        self.register[args[0]][args[1]] = args[2];
    }
    pub fn spc(self: *thread, args: [3]u8) void {
        self.register[args[0]] = m.toArr(self.pc);
    }

    pub fn print(self: *thread) void {
        var i: u4 = 0;
        while (i < 8) : (i += 1) {
            std.debug.print("reg: ({d}) {any} => ({d})\n", .{ i, self.register[i], m.toInt(self.register[i]) });
        }
        std.debug.print("pc: ({d})\ncma: ({d})\nstatus: ({d})\n", .{ self.pc, self.cba, self.status });
    }

    pub fn clr(self: *thread) void {
        self.cba = 0;
        self.pc = 0;
        self.status = 0;
        for (self.register) |*iteml| {
            for (iteml.*) |*item| {
                item.* = 0;
            }
        }
    }
};
