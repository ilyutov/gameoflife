#![feature(random)]
use std::fmt::{self, Formatter, Display};
use std::time::Duration;

const LIVE: &str = "\u{25FD}";
const DEAD: &str = "\u{25FE}";
const CLEAR: &str = "\x1B[1A\x1B[0K";

const DIM: usize = 32;
const FRAME: Duration = Duration::from_millis(200);

struct State([[bool; DIM]; DIM]);

fn main() {
    let mut state = init();
    print!("{}", state);
    loop {
        std::thread::sleep(FRAME);
        state = next(state);
        clear();
        print!("{}", state);
    }
}

fn clear() {
    for _ in 0..DIM {
        print!("{}", CLEAR);
    }
}

fn init() -> State {
    State(std::array::from_fn(|_| std::array::from_fn(|_| std::random::random())))
}

fn next(prev: State) -> State {
    State(std::array::from_fn(|i| std::array::from_fn(|j| survives(&prev, i, j))))
}

fn survives(state: &State, i: usize, j: usize) -> bool {
    let n = neighbours(&state, i, j);
    match (state.0[i][j], n) {
        (true, 2) => true,
        (true, 3) => true,
        (false, 3) => true,
        _ => false,
    }
}

fn neighbours(prev: &State, i: usize, j: usize) -> usize {
    let mut count = 0;
    let cells = &prev.0;

    let im = if i == 0 { DIM - 1 } else { i - 1 };
    let ip = if i == DIM - 1 { 0 } else { i + 1 };
    let jm = if j == 0 { DIM - 1 } else { j - 1 };
    let jp = if j == DIM - 1 { 0 } else { j + 1 };

    if cells[im][jm] { count += 1; }
    if cells[im][j] { count += 1; }
    if cells[im][jp] { count += 1; }
    if cells[i][jm] { count += 1; }
    if cells[i][jp] { count += 1; }
    if cells[ip][jm] { count += 1; }
    if cells[ip][j] { count += 1; }
    if cells[ip][jp] { count += 1; }

    count
}

impl Display for State {
    fn fmt(&self, f: &mut Formatter) -> fmt::Result {
        for row in self.0 {
            for cell in row {
                write!(f, "{}", if cell { LIVE } else { DEAD })?;
            }
            write!(f, "\n")?;
        }
        fmt::Result::Ok(())
    }
}