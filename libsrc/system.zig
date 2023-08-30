const t = @import("./thread.zig");
const m = @import("./math.zig");
const std = @import("std");
const efn = @import("./efn.zig");
const cmd = @import("./commands.zig");

pub const system = struct {
    threads: [8]t.thread,
    mem: []u8,
    status: u1,

    pub fn init(self: *system, memsize: usize) !void {
        self.mem = try std.heap.page_allocator.alloc(u8, memsize);
        self.clr();
    }

    pub fn clr(self: *system) void {
        for (&self.threads) |*thread| {
            thread.clr();
        }
    }

    pub fn free(self: *system) void {
        std.heap.page_allocator.free(self.mem);
    }

    pub fn print(self: *system, errc: *u64) void {
        var i: u4 = 0;
        for (&self.threads) |*thread| {
            efn.print("\n\n--- thread: {d} --- \n", .{i}, errc);
            thread.print(errc);
            i += 1;
        }
    }

    pub fn exec(self: *system, thread: u4, command: [4]u8, errc: *u64) void {
        var args: [3]u8 = .{ 0, 0, 0 };
        for (&args, 0..) |*argument, i| {
            argument.* = command[i + 1];
        }
        switch (command[0]) {
            cmd.noop => {},

            cmd.add => self.threads[thread].add(args),
            cmd.sub => self.threads[thread].sub(args),

            cmd.sma => self.threads[thread].sma(args),
            cmd.smv => self.smv(thread, args),
            cmd.gmv => self.gmv(thread, args),
            cmd.gms => self.gms(thread, args),

            cmd.jmp => self.threads[thread].jmp(args),
            cmd.jiz => self.threads[thread].jiz(args),
            cmd.jnz => self.threads[thread].jnz(args),

            cmd.nt => self.nt(thread, args),
            cmd.kt => self.kt(thread, args),
            cmd.srb => self.threads[thread].srb(args),
            cmd.spc => self.threads[thread].spc(args),

            cmd.hlt => self.hlt(thread, args),
            else => errc.* += 1,
        }
    }

    // start commands
    pub fn smv(self: *system, thread: u4, args: [3]u8) void {
        self.mem[self.threads[thread].cma] = self.threads[thread].register[args[0]][args[1]];
    }
    pub fn gmv(self: *system, thread: u4, args: [3]u8) void {
        self.threads[thread].register[args[0]][args[1]] = self.mem[self.threads[thread].cma];
    }
    pub fn gms(self: *system, thread: u4, args: [3]u8) void {
        self.threads[thread].register[args[0]] = m.toArr(self.mem.len);
    }
    pub fn nt(self: *system, thread: u4, args: [3]u8) void {
        self.threads[self.threads[thread].register[args[0]][0]].status = 1;
        self.threads[self.threads[thread].register[args[0]][0]].pc = m.toInt(self.threads[thread].register[args[1]]);
    }
    pub fn kt(self: *system, thread: u4, args: [3]u8) void {
        self.threads[self.threads[thread].register[args[0]][0]].status = 0;
    }
    pub fn hlt(self: *system, thread: u4, args: [3]u8) void {
        _ = thread;
        self.status = 0;
        var i: u4 = 0;
        while (i < 8) : (i += 1) self.threads[i].status = 0;
        _ = args;
    }
};
