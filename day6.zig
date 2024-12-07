const std = @import("std");
const data = @embedFile("input6.txt");
const split = std.mem.split;
const allocator = std.heap.page_allocator;
const maxLines: usize = 130;
const maxLineLength: usize = 130;

const stdout = std.io.getStdOut().writer();

fn contains(list: std.ArrayList(Index), value: Index) bool {
    for (list.items) |item| {
        if (item.x == value.x and item.y == value.y) {
            return true;
        }
    }
    return false;
}

const Vec2 = struct {
    x: isize,
    y: isize,

    fn rotate(self: *Vec2) void {
        const tmp = self.x;
        self.x = -self.y;
        self.y = tmp;
    }
};

const Index = struct {
    x: usize,
    y: usize,

    fn step(self: *Index, dir: Vec2) !void {
        const x_curr: isize = @intCast(self.x);
        const y_curr: isize = @intCast(self.y);

        const x: isize = x_curr + dir.x;
        const y: isize = y_curr + dir.y;
        if (x < 0 or y < 0 or x >= maxLineLength or y >= maxLines) {
            return error.NegativeOrZeroResult;
        }

        self.x = @intCast(x);
        self.y = @intCast(y);
    }

    fn next(self: *Index, dir: Vec2) !Index {
        const x_curr: isize = @intCast(self.x);
        const y_curr: isize = @intCast(self.y);

        const x: isize = x_curr + dir.x;
        const y: isize = y_curr + dir.y;
        if (x < 0 or y < 0 or x >= maxLineLength or y >= maxLines) {
            return error.NegativeOrZeroResult;
        }
        return Index{
            .x = @intCast(x),
            .y = @intCast(y),
        };
    }
};

pub fn main() !void {
    var splits = split(u8, data, "\n");
    var charGrid: [maxLines][maxLineLength]u8 = undefined;

    var lineIndex: usize = 0;
    while (splits.next()) |line| {
        if (lineIndex >= maxLines) {
            break;
        }

        // Copy the line into the 2D array
        var charIndex: usize = 0;
        while (charIndex < line.len) : (charIndex += 1) {
            charGrid[lineIndex][charIndex] = line[charIndex];
        }

        // Fill the remaining part of the row with zeros
        while (charIndex < maxLineLength) : (charIndex += 1) {
            charGrid[lineIndex][charIndex] = 0;
        }

        lineIndex += 1;
    }

    var starting_direction = Vec2{ .x = 0, .y = 0 };
    var starting_position = Index{ .x = 0, .y = 0 };

    outer: for (charGrid, 0..) |line, index_y| {
        for (line, 0..) |c, index_x| {
            if (c == '^') {
                starting_direction.y = -1;
                starting_position.x = index_x;
                starting_position.y = index_y;
                break :outer;
            }
        }
    }
    var count: i64 = 0;

    var visited = std.ArrayList(Index).init(allocator);
    var visitedDirection = std.ArrayList(Vec2).init(allocator);

    var direction = starting_direction;
    var position = starting_position;
    const unchangedGrid = charGrid;
    while (position.x > 0 and position.y > 0 and position.x < maxLineLength and position.y < maxLines) {
        if (charGrid[position.y][position.x] != 'X') {
            try visited.append(position);
            try visitedDirection.append(direction);
            count = count + 1;
            charGrid[position.y][position.x] = 'X';
        }
        const new_pos = position.next(direction) catch {
            break;
        };
        if (charGrid[new_pos.y][new_pos.x] == '#') {
            direction.rotate();
        } else {
            try position.step(direction);
        }
    }
    std.debug.print("{d}", .{count});

    var visitedWhileWalking = std.ArrayList(Index).init(allocator);
    var visitedDirectionWhileWalking = std.ArrayList(Vec2).init(allocator);
    var endless_loop: u32 = 0;
    charGrid = unchangedGrid;
    for (visited.items) |value| {
        position = starting_position;
        direction = starting_direction;
        charGrid[value.y][value.x] = '#';

        while (position.x > 0 and position.y > 0 and position.x < maxLineLength and position.y < maxLines) {
            if (contains(visitedWhileWalking, position)) {
                const item_index = for (visitedWhileWalking.items, 0..) |pos, index| {
                    if (std.meta.eql(pos, position)) break index;
                } else null;

                if (std.meta.eql(visitedDirectionWhileWalking.items[item_index.?], direction)) {
                    endless_loop += 1;
                    break;
                }
            } else {
                try visitedWhileWalking.append(position);
                try visitedDirectionWhileWalking.append(direction);
                charGrid[position.y][position.x] = 'X';
            }
            const new_pos = position.next(direction) catch {
                break;
            };
            if (charGrid[new_pos.y][new_pos.x] == '#') {
                direction.rotate();
            } else {
                try position.step(direction);
            }
        }

        charGrid[value.y][value.x] = '.';
        visitedWhileWalking.clearRetainingCapacity();
        visitedDirectionWhileWalking.clearRetainingCapacity();
    }
    std.debug.print("\n \n {d}", .{endless_loop});

    visitedWhileWalking.deinit();
    visitedDirection.deinit();
    visited.deinit();
    visitedDirectionWhileWalking.deinit();
}
