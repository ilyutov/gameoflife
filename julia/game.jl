using Random: bitrand
Base.exit_on_sigint(false)

const DIM = 32

const LIVE = "\u25FD"
const DEAD = "\u25FE"
const CLEAR = "\e[1A\e[K" ^ DIM

const SLEEP_S = 0.2

function run()
    state = bitrand(DIM, DIM)
    render(state)
    while true
        sleep(SLEEP_S)
        state = next(state)
        print(CLEAR)
        render(state)
    end
end

function render(state::BitMatrix)
    for i=1:DIM
        for j=1:DIM
            print(state[i, j] ? LIVE : DEAD)
        end
        println()
    end
end

function next(state::BitMatrix)::BitMatrix
    BitMatrix(survives(state, i, j) for i=1:DIM, j=1:DIM)
end

function survives(state::BitMatrix, i::Int, j::Int)
    nx = mod1.([
        i-1  j-1
        i-1  j    
        i-1  j+1
        i    j-1
        i    j+1
        i+1  j-1
        i+1  j    
        i+1  j+1
    ], DIM)

    live_neighbours = count(state[ix, jx] for (ix, jx) in eachrow(nx))

    if state[i, j]
        live_neighbours == 2 || live_neighbours == 3
    else
        live_neighbours == 3
    end
end

try
    run()
catch e
    if e isa InterruptException
        println("Bye")
    else
        rethrow(e)
    end
end
