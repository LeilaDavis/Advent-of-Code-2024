const std = @import("std");

pub fn main() !void {
    // General idea: split input into 2 lists, sort them both, subtract in new order, add to overall answer

    // Get a General Purpose Allocator to use:
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Get a writer for writing to the terminal:
    const stdout = std.io.getStdOut().writer();

    // Open the input file:
    var file = try std.fs.cwd().openFile("day1.txt", .{});
    defer file.close();

    // Set up a buffered reader for reading from the file:
    var buffered = std.io.bufferedReader(file.reader());
    var bufreader = buffered.reader();

    // Inspiration for having arrays where size is based on file size: https://blog.muthukumar.dev/posts/read-file-in-zig/
    // Get the size of the file and allocate an array of that size to hold the contents:
    const stat = try file.stat();
    const fileSize = stat.size;
    const buffer = try allocator.alloc(u8, fileSize);
    defer allocator.free(buffer);

    // Read from file:
    _ = try bufreader.readAll(buffer[0..]);
    try stdout.print("{s}\n", .{buffer});

    // Initialise variables for use in creating the lists of distances:
    var i: usize = 0;
    var j: u64 = 2;
    var listSize: usize = 0;

    // Split by newline to get an iterator for each line of the input file:
    var lineItr = std.mem.split(u8, buffer, "\n");
    // Count how many lines are in the file:
    while (lineItr.next() != null) {
        listSize += 1;
    }

    const list1 = try allocator.alloc(i64, listSize);
    defer allocator.free(list1);
    const list2 = try allocator.alloc(i64, listSize);
    defer allocator.free(list2);

    // Split by line again:
    var lineItr2 = std.mem.split(u8, buffer, "\n");
    while (lineItr2.next()) |line2| {
        // For each line, split by the three spaces that seperate the two values:
        var valItr = std.mem.split(u8, line2, "   ");
        while (valItr.next()) |val| {
            // Add to each of the two lists in turn:
            if (i < listSize) {
                if (j % 2 == 0) {
                    list1[i] = try std.fmt.parseInt(i64, val, 10);
                } else {
                    list2[i] = try std.fmt.parseInt(i64, val, 10);
                }
            }
            j = j + 1;
        }
        i = i + 1;
    }

    // Sort both lists:
    std.mem.sort(i64, list1, {}, comptime std.sort.asc(i64));
    std.mem.sort(i64, list2, {}, comptime std.sort.asc(i64));

    var answer: i64 = 0;
    // Calculate final answer as required:
    for (list1, list2) |list1item, list2item| {
        if (list1item > list2item) {
            answer += (list1item - list2item);
        } else {
            answer += (list2item - list1item);
        }
    }

    try stdout.print("Answer: {d}\n", .{answer});
}
