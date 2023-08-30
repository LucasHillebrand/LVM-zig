pub fn toArr(num: u64) [8]u8 {
    var arr: [8]u8 = undefined;
    var number: u64 = num;

    var i: u4 = 0;
    while (i < 8) : (i += 1) {
        arr[i] = @as(u8, @intCast(number % 256));
        number -= arr[i];
        number /= 256;
    }
    return arr;
}

pub fn pow(o: u64, n: u64) u64 {
    var i: u64 = 0;
    var res: u64 = 1;
    while (i < n) : (i += 1) res *%= o;
    return res;
}

pub fn toInt(arrnum: [8]u8) u64 {
    var i: u4 = 0;
    var res: u64 = 0;
    while (i < 8) : (i += 1) res +%= @as(u64, arrnum[i]) * pow(256, i);
    return res;
}

pub fn add(a: [8]u8, b: [8]u8) [8]u8 {
    var overhead: u1 = 0;
    var res: [8]u8 = undefined;
    var tmpres: u9 = 0;
    var i: u4 = 0;
    while (i < 8) : (i += 1) {
        tmpres = @as(u9, a[i]) +% (@as(u9, @intCast(b[i])) + overhead);
        overhead = 0;
        if (tmpres >= 0x100) overhead = 1;
        res[i] = @as(u8, @intCast(tmpres % 256));
    }
    return res;
}

pub fn sub(a: [8]u8, b: [8]u8) [8]u8 {
    var overhead: u1 = 0;
    var res: [8]u8 = undefined;
    var tmpres: u9 = 0;
    var i: u4 = 0;
    while (i < 8) : (i += 1) {
        tmpres = @as(u9, a[i]) -% (@as(u9, b[i]) + overhead);
        overhead = 0;
        if (tmpres >= 0x100) overhead = 1;
        res[i] = @as(u8, @intCast(tmpres % 256));
    }
    return res;
}

pub fn isEQ(a: [8]u8, b: [8]u8) bool {
    var res: u1 = 1;
    var i: u4 = 0;
    while (i < 8) : (i += 1) {
        if (a[i] != b[i]) res = 0;
    }
    return (res == 1);
}
