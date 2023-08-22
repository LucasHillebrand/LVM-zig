const std = @import("std");
const m = @import("./math.zig");

const obj = @This();

chars: []u8,

pub fn genstr(str: []const u8) !obj {
    var out: obj = undefined;
    out.chars = try std.heap.page_allocator.alloc(u8, str.len);
    var i: u64 = 0;
    while (i < str.len) : (i += 1) out.chars[i] = str[i];
    return out;
}

pub fn getargs() ![]obj {
    var args: [][]const u8 = try std.process.argsAlloc(std.heap.page_allocator);
    var out: []obj = try std.heap.page_allocator.alloc(obj, args.len);

    var i: u64 = 0;
    while (i < out.len) : (i += 1) out[i] = try genstr(args[i]);
    return out;
}

pub fn argsfree(args: []obj) void {
    for (args) |*arg| arg.free();
    std.heap.page_allocator.free(args);
}

pub fn free(self: *const obj) void {
    std.heap.page_allocator.free(self.chars);
}

pub fn len(self: *const obj) u64 {
    return self.chars.len;
}

pub fn cut(self: *const obj, start: u64, size: ?u64) !obj {
    var end: u64 = if (size != null and start + size.? < self.len()) start + size.? else self.len();
    var length: u64 = if (end > start) end - start else 0;
    var out: obj = undefined;
    out.chars = try std.heap.page_allocator.alloc(u8, length);

    var i: u64 = start;
    while (i < end) : (i += 1) out.chars[i - start] = self.chars[i];
    return out;
}

pub fn toint(self: *const obj, mode: enum { dec, hex, bin }) u64 {
    var out: u64 = 0;
    var i: u64 = self.len() -% 1;
    var decptr: u64 = 0;

    switch (mode) {
        .dec => {
            while (i >> 63 != 1) : (i -%= 1) {
                switch (self.chars[i]) {
                    '0' => {},
                    '1' => out += m.pow(10, decptr) * 1,
                    '2' => out += m.pow(10, decptr) * 2,
                    '3' => out += m.pow(10, decptr) * 3,
                    '4' => out += m.pow(10, decptr) * 4,
                    '5' => out += m.pow(10, decptr) * 5,
                    '6' => out += m.pow(10, decptr) * 6,
                    '7' => out += m.pow(10, decptr) * 7,
                    '8' => out += m.pow(10, decptr) * 8,
                    '9' => out += m.pow(10, decptr) * 9,
                    else => decptr -%= 1,
                }
                decptr +%= 1;
            }
        },
        .hex => {
            while (i >> 63 != 1) : (i -%= 1) {
                switch (self.chars[i]) {
                    '0' => {},
                    '1' => out += m.pow(16, decptr) * 1,
                    '2' => out += m.pow(16, decptr) * 2,
                    '3' => out += m.pow(16, decptr) * 3,
                    '4' => out += m.pow(16, decptr) * 4,
                    '5' => out += m.pow(16, decptr) * 5,
                    '6' => out += m.pow(16, decptr) * 6,
                    '7' => out += m.pow(16, decptr) * 7,
                    '8' => out += m.pow(16, decptr) * 8,
                    '9' => out += m.pow(16, decptr) * 9,

                    'a', 'A' => out += m.pow(16, decptr) * 10,
                    'b', 'B' => out += m.pow(16, decptr) * 11,
                    'c', 'C' => out += m.pow(16, decptr) * 12,
                    'd', 'D' => out += m.pow(16, decptr) * 13,
                    'e', 'E' => out += m.pow(16, decptr) * 14,
                    'f', 'F' => out += m.pow(16, decptr) * 15,
                    else => decptr -%= 1,
                }
                decptr +%= 1;
            }
        },
        .bin => {
            while (i >> 63 != 1) : (i -%= 1) {
                switch (self.chars[i]) {
                    '0' => {},
                    '1' => out += m.pow(2, decptr),
                    else => decptr -%= 1,
                }
                decptr +%= 1;
            }
        },
    }
    return out;
}

pub fn strmod(self: *obj, pos: u64, str: union(enum) { string: obj, temp: []const u8, char: u8 }) !void {
    var i: u64 = pos;
    switch (str) {
        .string => {
            var fullsize: u64 = pos + str.string.chars.len;
            self.chars = if (fullsize > self.chars.len) try std.heap.page_allocator.realloc(self.chars, fullsize) else self.chars;
            while (i < fullsize) : (i += 1) self.chars[i] = str.string.chars[i - pos];
        },
        .temp => {
            var fullsize: u64 = pos + str.temp.len;
            self.chars = if (fullsize > self.chars.len) try std.heap.page_allocator.realloc(self.chars, fullsize) else self.chars;
            while (i < fullsize) : (i += 1) self.chars[i] = str.temp[i - pos];
        },
        .char => {
            var fullsize: u64 = pos + 1;
            self.chars = if (fullsize > self.chars.len) try std.heap.page_allocator.realloc(self.chars, fullsize) else self.chars;
            self.chars[pos] = str.char;
        },
    }
}

pub fn iseq(self: *const obj, str: union(enum) { string: obj, temp: []const u8 }) bool {
    var out: bool = true;
    var i: u64 = 0;
    switch (str) {
        .string => {
            if (self.len() != str.string.len()) out = false;
            while (i < self.len() and out) : (i += 1) {
                if (self.chars[i] != str.string.chars[i]) out = false;
            }
        },
        .temp => {
            if (self.len() != str.temp.len) out = false;
            while (i < self.len() and out) : (i += 1) {
                if (self.chars[i] != str.temp[i]) out = false;
            }
        },
    }
    return out;
}
