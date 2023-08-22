const std = @import("std");
const sys = @import("./libsrc/system.zig");
const m = @import("./libsrc/math.zig");
const efn = @import("./libsrc/efn.zig");
const string = @import("./libsrc/string.zig");

const size: struct { KB: u64, MB: u64, GB: u64 } = .{ .KB = 1024, .MB = 1024 * 1024, .GB = 1024 * 1024 * 1024 };

pub fn main() void {
    var errc: u64 = 0;
    var args: []string = string.getargs() catch |err| efn.errhandl(err, &errc, []string);

    // programm flags
    var memsize: u64 = 512 * size.MB;
    var file: ?string = null;
    var debugflag: bool = false;

    // parsing arguments
    var i: u64 = 0;
    while (i < args.len) : (i += 1) {
        if (args.len > i + 1 and args[i].iseq(.{ .temp = "-m" })) {
            i += 1;
            var num: u64 = args[i].toint(.dec);
            var tmpstr: string = args[i].cut(args[i].len() -% 2, null) catch |err| efn.errhandl(err, &errc, string);
            if (tmpstr.iseq(.{ .temp = "KB" })) memsize = num * size.KB else if (tmpstr.iseq(.{ .temp = "MB" })) memsize = num * size.MB else if (tmpstr.iseq(.{ .temp = "GB" })) memsize = num * size.GB else memsize = num;
            tmpstr.free();
        } else if (args[i].iseq(.{ .temp = "-f" }) and args.len > i + 1) {
            i += 1;
            file = string.genstr(args[i].chars) catch {
                errc += 1;
                return undefined;
            };
        } else if (args[i].iseq(.{ .temp = "-h" }) or args[i].iseq(.{ .temp = "--help" })) {
            efn.print("-m [memory allocation](KB/MB/GB) // default 512 MB\n-f [file to execute]\n-d // debug mode\n-h // prints help\n", .{}, &errc);
        } else if (args[i].iseq(.{ .temp = "-d" })) debugflag = true;
    }
    string.argsfree(args);
    // end initialisation

    if (file != null) {
        var system: sys.system = undefined;
        system.init(memsize) catch |err| efn.errhandl(err, &errc, void);
        var filestream: std.fs.File = std.fs.cwd().openFile(file.?.chars, .{}) catch |err| efn.errhandl(err, &errc, std.fs.File);
        var filesize: u64 = filestream.getEndPos() catch |err| efn.errhandl(err, &errc, u64);
        i = 0;
        while (i < filesize and i < system.mem.len) : (i += 1) system.mem[i] = filestream.reader().readByte() catch |err| efn.errhandl(err, &errc, u8);
        system.status = 1;
        system.threads[0].status = 1;

        var nextBytes: [4]u8 = undefined;
        var j: u64 = 0;
        var pcbak: u64 = 0;
        while (system.status == 1) {
            i = 0;
            while (i < 8) : (i += 1) {
                j = 0;
                if (system.threads[i].status == 1) {
                    pcbak = system.threads[i].pc;
                    while (j < 4) : (j += 1) nextBytes[j] = system.mem[pcbak + j];
                    system.exec(@intCast(u4, i), nextBytes, &errc);
                    if (pcbak == system.threads[i].pc) system.threads[i].pc += 4;
                }
            }
        }

        if (debugflag) system.print(&errc);
        system.free();
    }

    if (debugflag) efn.print("\nmemsize:  {d}\nfilename: {s}\n", .{ memsize, if (file != null) file.?.chars else "<-- NO FILE SPECIFIED -->" }, &errc);

    if (errc > 0) efn.print("Warning: programm exited with {d} error/s\n", .{errc}, &errc);
}
