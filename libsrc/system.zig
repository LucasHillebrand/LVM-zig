const t = @import("./thread.zig");
const std = @import("std");

pub const system = struct {
    threads: [8]t.thread,
    mem: []u8,

    pub fn init(self: *system, memsize: usize) !void {
        self.mem = try std.heap.page_allocator.alloc(u8, memsize);
        self.clr();
    }

    pub fn clr(self: *system) void {
        for (self.threads) |*thread| {
            thread.clr();
        }
    }

    pub fn free(self: *system) void {
        std.heap.page_allocator.free(self.mem);
    }

    // start commands
    pub fn smv(self: *system, thread: u4, args: [3]u8) void {
        _ = args;
        _ = thread;
        _ = self;
    }
    pub fn gmv(self: *system, thread: u4, args: [3]u8) void {
        _ = args;
        _ = thread;
        _ = self;
    }
    pub fn gms(self: *system, thread: u4, args: [3]u8) void {
        _ = args;
        _ = thread;
        _ = self;
    }
    pub fn nt(self: *system, thread: u4, args: [3]u8) void {
        _ = args;
        _ = thread;
        _ = self;
    }
    pub fn kt(self: *system, thread: u4, args: [3]u8) void {
        _ = args;
        _ = thread;
        _ = self;
    }
    pub fn hlt(self: *system, thread: u4, args: [3]u8) void {
        _ = args;
        _ = thread;
        _ = self;
    }
};
