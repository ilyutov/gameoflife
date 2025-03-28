class State
  attr_reader :dim

  def initialize(dim)
    @dim = dim
    @state = Array.new(dim * dim)
  end

  def [](i, j)
    @state[i * dim + j]
  end

  def []=(i, j, value)
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
end

class Game
  LIVE = "\u25FD"
  DEAD = "\u25FE"
  CLEAR = "\e[1A\e[K"

  attr_reader :dim

  def initialize(dim:, seed:, buffer:)
    @dim = dim
    @state = State.new(dim)
    @buffer = buffer

    rng = Random.new(seed)
    dim.times do |i|
      dim.times do |j|
        @state[i,j] = rng.rand(2) == 1
      end
    end
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
    next_state = State.new(dim)

    dim.times do |i|
      dim.times do |j|
        cell = @state[i,j]
        live_neighbours = @state.neighbours(i,j).count(true)
        if cell
          cell = live_neighbours == 2 || live_neighbours == 3
        else
          cell = live_neighbours == 3
        end
        next_state[i,j] = cell
      end
    end

    @state = next_state
  end

  def render
    @buffer.print(CLEAR * dim) if @rendered

    dim.times do |i|
      dim.times do |j|
        @buffer.print @state[i,j] ? LIVE : DEAD
      end
      print "\n"
    end

    @buffer.flush
    @rendered = true
  end
end

Game.new(dim: 32, seed: 123, buffer: $stdout).run
