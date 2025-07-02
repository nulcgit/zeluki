const std = @import("std");
const builtin = @import("builtin");

pub fn main() !void {
    // Set console code page to UTF-8 on Windows
    if (builtin.os.tag == .windows) {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const allocator = arena.allocator();

        const args = [_][]const u8{ "chcp", "65001" };
        var process = std.process.Child.init(&args, allocator);
        process.stdout_behavior = .Inherit;
        process.stderr_behavior = .Inherit;
        const term = process.spawnAndWait() catch |err| {
            std.debug.print("Failed to execute 'chcp 65001': {}\n", .{err});
            return err;
        };
        if (term.Exited != 0) {
            std.debug.print("Command 'chcp 65001' failed with exit code {}\n", .{term.Exited});
            return error.SetCodePageFailed;
        }
    }

    // Write UTF-8 text to stdout
    const text = "Варкалось. Хливкие шорьки\nПырялись по наве,\nИ хрюкотали зелюки,\nКак мюмзики в мове.\n";
    const stdout = std.io.getStdOut().writer();
    stdout.writeAll(text) catch |err| {
        std.debug.print("Failed to write to stdout: {}\n", .{err});
        return err;
    };
}
