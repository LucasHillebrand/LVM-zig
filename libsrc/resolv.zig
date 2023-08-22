const string = @import("./string.zig");
const parser = @import("./parser.zig");
const commands = @import("./commands.zig");
const std = @import("std");
const m = @import("./math.zig");
const efn = @import("./efn.zig");

pub fn resolveline(line: string, file: std.fs.File, pc: *u64, vars: *parser.sysvars, errc: *u64) void {
    var words: [4]string = undefined;
    for (words) |*w| w.* = string.genstr("") catch |err| efn.errhandl(err, errc, string);
    var word: u4 = 0;
    var i: u64 = 0;
    var curr: u8 = 0;
    var str: bool = false;

    while (i < line.len() and word < 4) : (i += 1) {
        curr = line.chars[i];
        if (curr == '\"') str = !str else if (curr != ' ' or str) words[word].strmod(words[word].len(), .{ .char = curr }) catch |err| efn.errhandl(err, errc, void) else word += 1;
    }

    resolvwords(words, file, pc, vars, errc);

    for (words) |*w| w.free();
}

pub fn resolvwords(words: [4]string, file: std.fs.File, pc: *u64, vars: *parser.sysvars, errc: *u64) void {
    var args: [3]string = undefined;
    var i: u64 = 0;
    while (i < 3) : (i += 1) args[i] = words[i + 1];

    if (words[0].iseq(.{ .temp = "noop" })) noop(file, pc, args, vars) catch |err| efn.errhandl(err, errc, void);
    if (words[0].iseq(.{ .temp = "add" })) add(file, pc, args, vars) catch |err| efn.errhandl(err, errc, void);
    if (words[0].iseq(.{ .temp = "sub" })) sub(file, pc, args, vars) catch |err| efn.errhandl(err, errc, void);
    if (words[0].iseq(.{ .temp = "sma" })) sma(file, pc, args, vars) catch |err| efn.errhandl(err, errc, void);
    if (words[0].iseq(.{ .temp = "smv" })) smv(file, pc, args, vars) catch |err| efn.errhandl(err, errc, void);
    if (words[0].iseq(.{ .temp = "gmv" })) gmv(file, pc, args, vars) catch |err| efn.errhandl(err, errc, void);
    if (words[0].iseq(.{ .temp = "gms" })) gms(file, pc, args, vars) catch |err| efn.errhandl(err, errc, void);
    if (words[0].iseq(.{ .temp = "jmp" })) jmp(file, pc, args, vars) catch |err| efn.errhandl(err, errc, void);
    if (words[0].iseq(.{ .temp = "jiz" })) jiz(file, pc, args, vars) catch |err| efn.errhandl(err, errc, void);
    if (words[0].iseq(.{ .temp = "jnz" })) jnz(file, pc, args, vars) catch |err| efn.errhandl(err, errc, void);
    if (words[0].iseq(.{ .temp = "nt" })) nt(file, pc, args, vars) catch |err| efn.errhandl(err, errc, void);
    if (words[0].iseq(.{ .temp = "kt" })) kt(file, pc, args, vars) catch |err| efn.errhandl(err, errc, void);
    if (words[0].iseq(.{ .temp = "srb" })) srb(file, pc, args, vars) catch |err| efn.errhandl(err, errc, void);
    if (words[0].iseq(.{ .temp = "spc" })) spc(file, pc, args, vars) catch |err| efn.errhandl(err, errc, void);
    if (words[0].iseq(.{ .temp = "hlt" })) hlt(file, pc, args, vars) catch |err| efn.errhandl(err, errc, void);

    if (words[0].iseq(.{ .temp = "sfr" })) sfr(file, pc, args, vars) catch |err| efn.errhandl(err, errc, void);
    if (words[0].iseq(.{ .temp = "var!" })) setvar(file, pc, args, vars) catch |err| efn.errhandl(err, errc, void);
    if (words[0].iseq(.{ .temp = "pub!" })) setpub(file, pc, args, vars) catch |err| efn.errhandl(err, errc, void);
    if (words[0].iseq(.{ .temp = "free" })) free(file, pc, args, vars) catch |err| efn.errhandl(err, errc, void);
    if (words[0].iseq(.{ .temp = "incf" })) include(file, pc, args, vars) catch |err| efn.errhandl(err, errc, void);
    if (words[0].iseq(.{ .temp = "print!" })) print(file, pc, args, vars) catch |err| efn.errhandl(err, errc, void);
}

pub fn noop(file: std.fs.File, pc: *u64, args: [3]string, vars: *parser.sysvars) !void {
    _ = vars;
    _ = args;
    try parser.parse(file, .{ commands.noop, 0, 0, 0 }, pc);
}
pub fn add(file: std.fs.File, pc: *u64, args: [3]string, vars: *parser.sysvars) !void {
    try parser.parse(file, .{ commands.add, @intCast(u8, try parser.argparse(vars, pc, args[0]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[1]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[2]) % 256) }, pc);
}
pub fn sub(file: std.fs.File, pc: *u64, args: [3]string, vars: *parser.sysvars) !void {
    try parser.parse(file, .{ commands.sub, @intCast(u8, try parser.argparse(vars, pc, args[0]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[1]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[2]) % 256) }, pc);
}

pub fn sma(file: std.fs.File, pc: *u64, args: [3]string, vars: *parser.sysvars) !void {
    try parser.parse(file, .{ commands.sma, @intCast(u8, try parser.argparse(vars, pc, args[0]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[1]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[2]) % 256) }, pc);
}
pub fn smv(file: std.fs.File, pc: *u64, args: [3]string, vars: *parser.sysvars) !void {
    try parser.parse(file, .{ commands.smv, @intCast(u8, try parser.argparse(vars, pc, args[0]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[1]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[2]) % 256) }, pc);
}
pub fn gmv(file: std.fs.File, pc: *u64, args: [3]string, vars: *parser.sysvars) !void {
    try parser.parse(file, .{ commands.gmv, @intCast(u8, try parser.argparse(vars, pc, args[0]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[1]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[2]) % 256) }, pc);
}
pub fn gms(file: std.fs.File, pc: *u64, args: [3]string, vars: *parser.sysvars) !void {
    try parser.parse(file, .{ commands.gms, @intCast(u8, try parser.argparse(vars, pc, args[0]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[1]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[2]) % 256) }, pc);
}

pub fn jmp(file: std.fs.File, pc: *u64, args: [3]string, vars: *parser.sysvars) !void {
    try parser.parse(file, .{ commands.jmp, @intCast(u8, try parser.argparse(vars, pc, args[0]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[1]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[2]) % 256) }, pc);
}
pub fn jiz(file: std.fs.File, pc: *u64, args: [3]string, vars: *parser.sysvars) !void {
    try parser.parse(file, .{ commands.jiz, @intCast(u8, try parser.argparse(vars, pc, args[0]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[1]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[2]) % 256) }, pc);
}
pub fn jnz(file: std.fs.File, pc: *u64, args: [3]string, vars: *parser.sysvars) !void {
    try parser.parse(file, .{ commands.jnz, @intCast(u8, try parser.argparse(vars, pc, args[0]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[1]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[2]) % 256) }, pc);
}

pub fn nt(file: std.fs.File, pc: *u64, args: [3]string, vars: *parser.sysvars) !void {
    try parser.parse(file, .{ commands.nt, @intCast(u8, try parser.argparse(vars, pc, args[0]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[1]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[2]) % 256) }, pc);
}
pub fn kt(file: std.fs.File, pc: *u64, args: [3]string, vars: *parser.sysvars) !void {
    try parser.parse(file, .{ commands.kt, @intCast(u8, try parser.argparse(vars, pc, args[0]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[1]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[2]) % 256) }, pc);
}
pub fn srb(file: std.fs.File, pc: *u64, args: [3]string, vars: *parser.sysvars) !void {
    try parser.parse(file, .{ commands.srb, @intCast(u8, try parser.argparse(vars, pc, args[0]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[1]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[2]) % 256) }, pc);
}
pub fn spc(file: std.fs.File, pc: *u64, args: [3]string, vars: *parser.sysvars) !void {
    try parser.parse(file, .{ commands.spc, @intCast(u8, try parser.argparse(vars, pc, args[0]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[1]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[2]) % 256) }, pc);
}

pub fn hlt(file: std.fs.File, pc: *u64, args: [3]string, vars: *parser.sysvars) !void {
    try parser.parse(file, .{ commands.hlt, @intCast(u8, try parser.argparse(vars, pc, args[0]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[1]) % 256), @intCast(u8, try parser.argparse(vars, pc, args[2]) % 256) }, pc);
}

pub fn sfr(file: std.fs.File, pc: *u64, args: [3]string, vars: *parser.sysvars) !void {
    var num: u64 = try parser.argparse(vars, pc, args[1]);
    var arr: [8]u8 = m.toArr(num);
    var i: u64 = 0;
    while (i < 8) : (i += 1) try parser.parse(file, .{ commands.srb, @intCast(u8, try parser.argparse(vars, pc, args[0])), @intCast(u8, i), @intCast(u8, arr[i]) }, pc);
}
pub fn setvar(file: std.fs.File, pc: *u64, args: [3]string, vars: *parser.sysvars) !void {
    _ = file;
    try vars.append(.{ .string = args[0] }, try parser.argparse(vars, pc, args[1]), .private);
}
pub fn setpub(file: std.fs.File, pc: *u64, args: [3]string, vars: *parser.sysvars) !void {
    _ = file;
    try vars.append(.{ .string = args[0] }, try parser.argparse(vars, pc, args[1]), .public);
}
pub fn free(file: std.fs.File, pc: *u64, args: [3]string, vars: *parser.sysvars) !void {
    var bytes = try parser.argparse(vars, pc, args[0]);
    var i: u64 = 0;
    while (i < bytes) : (i += 1) {
        try file.writer().writeByte(0);
        pc.* += 1;
    }
}
pub fn include(file: std.fs.File, pc: *u64, args: [3]string, vars: *parser.sysvars) !void {
    var size: u64 = try parser.argparse(vars, pc, args[1]);
    var raw: ?std.fs.File = std.fs.cwd().openFile(args[0].chars, .{}) catch null;
    var bytes: u64 = if (raw != null) try raw.?.getEndPos() else 0;
    if (size == 0) size = bytes;
    var i: u64 = 0;
    while (i < size) : (i += 1) {
        try file.writer().writeByte(if (i < bytes) try raw.?.reader().readByte() else 0);
        pc.* += 1;
    }
    if (raw != null) raw.?.close();
}
pub fn print(file: std.fs.File, pc: *u64, args: [3]string, vars: *parser.sysvars) !void {
    _ = file;
    var num: u64 = try parser.argparse(vars, pc, args[1]);
    var dummy: u64 = 0;
    efn.print(" => {s}: {d} (hex: [{x}])\n", .{ args[0].chars, num, num }, &dummy);
}
