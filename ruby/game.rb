class World
  attr_reader :dim

  def initialize(dim)
    @dim = dim
    @state = Array.new(dim * dim)
  end

  def [](i, j)
    i %= dim
    j %= dim
    @state[i * dim + j]
  end

  def []=(i, j, value)
    i %= dim
    j %= dim
    @state[i * dim + j] = value
  end

  def neighbours(i,j)
    [
      self[i-1, j-1],
      self[i-1, j],
      self[i-1, j+1],
      self[i, j-1],
      self[i, j+1],
      self[i+1, j-1],
      self[i+1, j],
      self[i+1, j+1],
    ]
  end

  def randomize!(rng)
    @state.size.times do |i|
      @state[i] = rng.rand(2) == 1
    end
  end
end

class Game
  LIVE = "\u25FD"
  DEAD = "\u25FE"
  CLEAR = "\e[1A\e[K"

  attr_reader :dim, :world

  def initialize(dim:, seed:, buffer:)
    @dim = dim
    @world = World.new(dim)
    @buffer = buffer

    rng = Random.new(seed)
    world.randomize!(rng)
  end

  def run
    loop do
      render
      next!
      sleep(0.2)
    rescue Interrupt
      puts "\rBye"
      break
    end
  end

  def next!
    new_world = World.new(dim)

    dim.times do |i|
      dim.times do |j|
        cell = world[i,j]
        live_neighbours = world.neighbours(i,j).count(true)
        if cell
          cell = live_neighbours == 2 || live_neighbours == 3
        else
          cell = live_neighbours == 3
        end
        new_world[i,j] = cell
      end
    end

    @world = new_world
  end

  def render
    @buffer.print(CLEAR * dim) if @rendered

    dim.times do |i|
      dim.times do |j|
        @buffer.print world[i,j] ? LIVE : DEAD
      end
      print "\n"
    end

    @buffer.flush
    @rendered = true
  end
end

Game.new(dim: 32, seed: 123, buffer: $stdout).run
