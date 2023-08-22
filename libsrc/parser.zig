const string = @import("./string.zig");
const std = @import("std");

const nu = union(enum) { string: string, temp: []const u8 };

const vartype = struct {
    names: []string,
    values: []u64,

    pub fn getIndex(self: *vartype, name: nu) ?u64 {
        var namecstr: []const u8 = undefined;
        switch (name) {
            .string => namecstr = name.string.chars,
            .temp => namecstr = name.temp,
        }

        var i: u64 = 0;
        var out: ?u64 = null;
        while (i < self.names.len) : (i += 1) {
            if (self.names[i].iseq(.{ .temp = namecstr })) out = i;
        }
        return out;
    }

    pub fn search(self: *vartype, name: nu) u64 {
        var index: ?u64 = self.getIndex(name);
        var out: u64 = 0;
        if (index != null) out = self.values[index.?];
        return out;
    }

    pub fn init(self: *vartype) !void {
        self.names = try std.heap.page_allocator.alloc(string, 0);
        self.values = try std.heap.page_allocator.alloc(u64, 0);
    }

    pub fn append(self: *vartype, name: nu, value: u64) !void {
        var nm: []const u8 = undefined;
        switch (name) {
            .string => nm = name.string.chars,
            .temp => nm = name.temp,
        }
        var index: ?u64 = self.getIndex(.{ .temp = nm });
        if (index == null) {
            self.names = try std.heap.page_allocator.realloc(self.names, self.names.len + 1);
            self.names[self.names.len - 1] = try string.genstr(nm);

            self.values = try std.heap.page_allocator.realloc(self.values, self.values.len + 1);
            self.values[self.values.len - 1] = value;
        } else self.values[index.?] = value;
    }
    pub fn free(self: *vartype) void {
        std.heap.page_allocator.free(self.names);
        std.heap.page_allocator.free(self.values);
    }
};

pub const sysvars = struct {
    private: vartype,
    public: vartype,

    pub fn init(self: *sysvars) !void {
        try self.private.init();
        try self.public.init();
    }

    pub fn search(self: *sysvars, name: nu) u64 {
        var out: u64 = 0;
        var privindex: ?u64 = self.private.getIndex(name);
        var pubindex: ?u64 = self.public.getIndex(name);
        if (privindex != null) out = self.private.values[privindex.?];
        if (pubindex != null) out = self.public.values[pubindex.?];

        return out;
    }

    pub fn append(self: *sysvars, name: nu, value: u64, vtype: enum { public, private }) !void {
        switch (vtype) {
            .public => try self.public.append(name, value),
            .private => try self.private.append(name, value),
        }
    }

    pub fn clearpriv(self: *sysvars) !void {
        self.private.free();
        try self.private.init();
    }
};

pub fn parse(file: std.fs.File, binval: [4]u8, pc: *u64) !void {
    for (binval) |num| try file.writer().writeByte(num);
    pc.* += 4;
}

pub fn argparse(svars: *sysvars, pc: *u64, text: string) !u64 {
    var out: u64 = 0;

    var cstr: string = try text.cut(0, 2);
    if (cstr.iseq(.{ .temp = "0x" })) {
        out = text.toint(.hex);
    } else if (cstr.iseq(.{ .temp = "0b" })) {
        out = text.toint(.bin);
    } else {
        out = text.toint(.dec);
    }
    cstr.free();

    cstr = try text.cut(0, 1);
    if (cstr.iseq(.{ .temp = "$" })) {
        var nm: string = try text.cut(1, null);
        out = svars.search(.{ .string = nm });
        nm.free();
    } else if (cstr.iseq(.{ .temp = "." })) {
        out = pc.*;
    }
    cstr.free();

    return out;
}
