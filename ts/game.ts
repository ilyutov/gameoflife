const LIVE = "\u25FD";
const DEAD = "\u25FE";
const CLEAR = "\x1b[1A\x1b[0K";

class World {
  readonly dim: number;
  state: boolean[];

  constructor(dim: number) {
    this.dim = dim;
    this.state = new Array(dim * dim);
  }

  randomize() {
    for (let i = 0; i < this.state.length; i++) {
      this.state[i] = Math.random() < 0.5;
    }
  }

  get(i: number, j: number): boolean {
    return this.state[this.index(i, j)]!;
  }

  set(i: number, j: number, value: boolean) {
    this.state[this.index(i, j)] = value;
  }

  liveNeighbours(i: number, j: number) {
    return [
      this.get(i - 1, j - 1),
      this.get(i - 1, j),
      this.get(i - 1, j + 1),
      this.get(i, j - 1),
      this.get(i, j + 1),
      this.get(i + 1, j - 1),
      this.get(i + 1, j),
      this.get(i + 1, j + 1),
    ].reduce((acc, live) => (live ? acc + 1 : acc), 0);
  }

  private index(i: number, j: number) {
    i = (i + this.dim) % this.dim;
    j = (j + this.dim) % this.dim;
    return i * this.dim + j;
  }
}

class Game {
  world: World;

  constructor(dim: number) {
    this.world = new World(dim);
    this.world.randomize();
  }

  async run() {
    await this.flush();

    let running = true;
    let rendered = false;
    process.on("SIGINT", () => {
      running = false;
    });

    while (running) {
      await this.render(rendered);
      rendered = true;

      this.next();
      await this.sleep(200);
    }

    process.stdout.write("\rBye");
  }

  next() {
    const newWorld = new World(this.world.dim);
    for (let i = 0; i < this.world.dim; i++) {
      for (let j = 0; j < this.world.dim; j++) {
        let cell = this.world.get(i, j);
        const liveNeighbours = this.world.liveNeighbours(i, j);
        if (cell) {
          cell = liveNeighbours === 2 || liveNeighbours === 3;
        } else {
          cell = liveNeighbours === 3;
        }
        newWorld.set(i, j, cell);
      }
    }
    this.world = newWorld;
  }

  async render(rendered: boolean) {
    if (rendered) {
      process.stdout.write(CLEAR.repeat(this.world.dim));
    }

    for (let i = 0; i < this.world.dim; i++) {
      for (let j = 0; j < this.world.dim; j++) {
        const cell = this.world.get(i, j);
        process.stdout.write(cell ? LIVE : DEAD);
      }
      process.stdout.write("\n");
    }

    await this.flush();
  }

  private sleep(ms: number) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  private flush() {
    return new Promise((resolve) => process.stdout.write("", resolve));
  }
}

const game = new Game(32);
await game.run();
