const std = @import("std");
const string = @import("libsrc/string.zig");
const parser = @import("libsrc/parser.zig");
const efn = @import("libsrc/efn.zig");
const resolv = @import("libsrc/resolv.zig");
const commands = @import("libsrc/commands.zig");
const m = @import("libsrc/math.zig");

pub fn main() !void {
    var errc: u64 = 0;

    var pc: u64 = 0;
    var output: string = try string.genstr("out.lbin");
    var input: []string = try std.heap.page_allocator.alloc(string, 0);
    var args: []string = try string.getargs();
    var mainfn: bool = true;

    var i: u64 = 1;
    while (i < args.len) : (i += 1) {
        if (args[i].iseq(.{ .temp = "-o" }) and i + 1 < args.len) {
            output.free();
            output = args[i + 1];
            i += 1;
        } else if (args[i].iseq(.{ .temp = "-h" }) or args[i].iseq(.{ .temp = "--help" })) {
            efn.print("args:\n  -h / --help => show this help\n  -o => define the output file\n  -s => define starting position\n  --nomain => don't jump to the main func\n", .{}, &errc);
        } else if (args[i].iseq(.{ .temp = "-s" }) and i + 1 < args.len) {
            i += 1;
            pc = args[i].toint(.dec);
        } else if (args[i].iseq(.{ .temp = "--nomain" })) {
            mainfn = false;
        } else {
            input = try std.heap.page_allocator.realloc(input, input.len + 1);
            input[input.len - 1] = args[i];
        }
    }

    efn.print("input files:\n", .{}, &errc);
    for (input) |name| efn.print("-> {s}\n", .{name.chars}, &errc);
    efn.print("\noutput file => {s}\n", .{output.chars}, &errc);

    if (input.len > 0) try compilefiles(input, output, &pc, mainfn, &errc);

    string.argsfree(args);
    std.heap.page_allocator.free(input);

    if (errc > 0) efn.print("WARNING: programm exitet with {d} errors\n", .{errc}, &errc);
}

fn compilefiles(filenames: []string, dst: string, pc: *u64, mainfn: bool, errc: *u64) !void {
    var dststream: std.fs.File = try std.fs.cwd().createFile(dst.chars, .{});
    var sv: parser.sysvars = undefined;
    try sv.init();

    // reserve first 9 operations
    var i: u64 = 0;
    if (mainfn) {
        while (i < 9) : (i += 1) try parser.parse(dststream, .{ commands.noop, 0, 0, 0 }, pc);
    }
    // compile files
    for (filenames) |filename| {
        try compilefile(filename, dststream, &sv, pc, errc);
        try sv.clearpriv();
    }

    // jump to main
    if (mainfn) {
        try dststream.seekTo(0);
        var mainptr: u64 = sv.search(.{ .temp = "main" });
        var numb: [8]u8 = m.toArr(mainptr);
        i = 0;
        pc.* = 0;
        while (i < 8) : (i += 1) try parser.parse(dststream, .{ @as(u8, commands.srb), @intCast(u8, 0), @intCast(u8, i), @intCast(u8, numb[i]) }, pc);
        if (mainptr != 0) try parser.parse(dststream, .{ commands.jmp, 0, 0, 0 }, pc);
    }
    sv.public.free();
    sv.private.free();
    dststream.close();
}

fn compilefile(filename: string, dst: std.fs.File, vars: *parser.sysvars, pc: *u64, errc: *u64) !void {
    var src: std.fs.File = try std.fs.cwd().openFile(filename.chars, .{});
    var size: u64 = try src.getEndPos();
    var i: u64 = 0;
    var line: string = try string.genstr("");
    var curr: u8 = 0;
    while (i < size + 1) : (i += 1) {
        curr = src.reader().readByte() catch 0;

        if (curr != '\n' and i != size) try line.strmod(line.len(), .{ .char = curr }) else {
            resolv.resolveline(line, dst, pc, vars, errc);
            line.free();
            line = try string.genstr("");
        }
    }
    src.close();
}
