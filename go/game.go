package main

import (
	"fmt"
	"math/rand"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"
)

const Live = "\u25FD"
const Dead = "\u25FE"
const Clear = "\033[1A\033[0K"

type World struct {
	dim   int
	state []bool
}

func newWorld(dim int) *World {
	world := World{
		dim:   dim,
		state: make([]bool, dim*dim),
	}

	return &world
}

func (world *World) _index(i, j int) int {
	i = (i + world.dim) % world.dim
	j = (j + world.dim) % world.dim
	return i*world.dim + j
}

func (world *World) get(i, j int) bool {
	index := world._index(i, j)
	return world.state[index]
}

func (world *World) set(i, j int, val bool) {
	index := world._index(i, j)
	world.state[index] = val
}

func (world *World) randomize(rng *rand.Rand) {
	for i := range world.state {
		world.state[i] = rng.Intn(2) == 1
	}
}

func (world *World) render() {
	for i := range world.dim {
		for j := range world.dim {
			live := world.get(i, j)
			if live {
				fmt.Print(Live)
			} else {
				fmt.Print(Dead)
			}
		}
		fmt.Print("\n")
	}
}

func (world *World) liveNeighbours(i, j int) int {
	count := 0

	if world.get(i-1, j-1) {
		count++
	}
	if world.get(i-1, j) {
		count++
	}
	if world.get(i-1, j+1) {
		count++
	}
	if world.get(i, j-1) {
		count++
	}
	if world.get(i, j+1) {
		count++
	}
	if world.get(i+1, j-1) {
		count++
	}
	if world.get(i+1, j) {
		count++
	}
	if world.get(i+1, j+1) {
		count++
	}

	return count
}

func (world *World) next() *World {
	newWorld := newWorld(world.dim)
	for i := range world.dim {
		for j := range world.dim {
			cell := world.get(i, j)
			neighbours := world.liveNeighbours(i, j)
			if cell {
				cell = neighbours == 2 || neighbours == 3
			} else {
				cell = neighbours == 3
			}
			newWorld.set(i, j, cell)
		}
	}

	return newWorld
}

func main() {
	sigChannel := make(chan os.Signal, 1)
	signal.Notify(sigChannel, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-sigChannel
		fmt.Println("\rBye")
		os.Exit(1)
	}()

	dim := 32
	seed := int64(123)
	rng := rand.New(rand.NewSource(seed))

	world := newWorld(dim)
	world.randomize(rng)

	clear := strings.Repeat(Clear, dim)
	rendered := false

	for {
		if rendered {
			fmt.Print(clear)
		}

		world.render()
		world = world.next()
		time.Sleep(200 * time.Millisecond)

		rendered = true
	}
}
