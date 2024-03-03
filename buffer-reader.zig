const std = @import("std");
const benchmark = @import("lib/benchmark.zig");

fn streamUntilDelimiter(buffered: anytype, writer: anytype, delimiter: u8) !void {
    while (true) {
        const start = buffered.start;
        if (std.mem.indexOfScalar(u8, buffered.buf[start..buffered.end], delimiter)) |pos| {
            // we found the delimiter
            try writer.writeAll(buffered.buf[start .. start + pos]);
            // skip the delimiter
            buffered.start += pos + 1;
            return;
        } else {
            // we didn't find the delimiter, add everything to the output writer...
            try writer.writeAll(buffered.buf[start..buffered.end]);

            // ... and refill the buffer
            const n = try buffered.unbuffered_reader.read(buffered.buf[0..]);
            if (n == 0) {
                return error.EndOfStream;
            }
            buffered.start = 0;
            buffered.end = n;
        }
    }
}

fn bufRead(_: std.mem.Allocator, _: *std.time.Timer) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var file = try std.fs.cwd().openFile("large-file.json", .{});
    defer file.close();

    // Things are _a lot_ slower if we don't use a BufferedReader
    var buffered = std.io.bufferedReader(file.reader());

    // lines will get read into this
    var arr = std.ArrayList(u8).init(allocator);
    defer arr.deinit();

    var line_count: usize = 0;
    var byte_count: usize = 0;
    while (true) {
        streamUntilDelimiter(&buffered, arr.writer(), '\n') catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        line_count += 1;
        byte_count += arr.items.len;
        arr.clearRetainingCapacity();
    }

    // std.debug.print("{d} lines, {d} bytes", .{ line_count, byte_count });
}

fn stdRead(_: std.mem.Allocator, _: *std.time.Timer) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var file = try std.fs.cwd().openFile("large-file.json", .{});
    defer file.close();

    // Things are _a lot_ slower if we don't use a BufferedReader
    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();

    // lines will get read into this
    var arr = std.ArrayList(u8).init(allocator);
    defer arr.deinit();

    var line_count: usize = 0;
    var byte_count: usize = 0;
    while (true) {
        reader.streamUntilDelimiter(arr.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        line_count += 1;
        byte_count += arr.items.len;
        arr.clearRetainingCapacity();
    }

    //std.debug.print("{d} lines, {d} bytes", .{ line_count, byte_count });
}

pub fn main() !void {
    (try benchmark.run(stdRead, .{})).print("stdRead");
    (try benchmark.run(bufRead, .{})).print("bufRead");
}
