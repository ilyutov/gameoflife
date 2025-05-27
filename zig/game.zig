const std = @import("std");
const stdout = std.io.getStdOut().writer();
const rand = std.crypto.random;

const DIM = 32;
const SLEEP_NANOS = 300_000_000;

const LIVE = "\u{25FD}";
const DEAD = "\u{25FE}";
const CLEAR = "\x1B[1A\x1B[0K";

const TIndex = u5; // must align with DIM or wrapping math won't work
const TState = [DIM][DIM]bool;

const World = struct {
    state: TState,

    pub fn init() World {
        return World{ .state = randomState() };
    }

    pub fn next(prev: World) World {
        return World{ .state = nextState(prev.state) };
    }
};

pub fn main() void {
    // var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    // defer std.debug.assert(general_purpose_allocator.deinit() == .ok);

    var world = World.init();
    render(world);

    while (true) {
        std.time.sleep(SLEEP_NANOS);
        world = world.next();
        clear();
        render(world);
    }
}

fn randomState() TState {
    var state: TState = [_][DIM]bool{[_]bool{false} ** DIM} ** DIM; // alloc
    for (state, 0..) |row, i| {
        for (row, 0..) |_, j| {
            state[i][j] = rand.boolean();
        }
    }
    return state;
}

fn nextState(prev: TState) TState {
    var next: TState = [_][DIM]bool{[_]bool{false} ** DIM} ** DIM; // alloc

    for (prev, 0..) |row, i| {
        for (row, 0..) |cell, j| {
            const neighbours = liveNeighbours(prev, @truncate(i), @truncate(j));
            if (cell) {
                next[i][j] = neighbours == 2 or neighbours == 3;
            } else {
                next[i][j] = neighbours == 3;
            }
        }
    }

    return next;
}

fn liveNeighbours(state: TState, i: TIndex, j: TIndex) u4 {
    var count: u4 = 0;

    if (state[i -% 1][j -% 1]) count += 1;
    if (state[i -% 1][j]) count += 1;
    if (state[i -% 1][j +% 1]) count += 1;
    if (state[i][j -% 1]) count += 1;
    if (state[i][j +% 1]) count += 1;
    if (state[i +% 1][j -% 1]) count += 1;
    if (state[i +% 1][j]) count += 1;
    if (state[i +% 1][j +% 1]) count += 1;

    return count;
}

fn render(world: World) void {
    for (world.state) |row| {
        for (row) |cell| {
            stdout.print("{s}", .{if (cell) LIVE else DEAD}) catch unreachable;
        }
        stdout.print("\n", .{}) catch unreachable;
    }
}

fn clear() void {
    for (0..DIM) |_| {
        stdout.print("{s}", .{CLEAR}) catch unreachable;
    }
}
