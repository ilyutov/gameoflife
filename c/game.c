#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <unistd.h>

#define LIVE "\u25FD"
#define DEAD "\u25FE"
#define CLEAR "\033[1A\033[0K"

#define DIM 32
#define FRAME_MS 200

void clear() {
    for (int i = 0; i < DIM; i++) {
        printf(CLEAR);
    }
}

void init(bool state[DIM][DIM]) {
    for (int i = 0; i < DIM; i++) {
        for (int j = 0; j < DIM; j++) {
            state[i][j] = rand() % 2;
        }
    }
}

int get(bool state[DIM][DIM], int i, int j) {
    int row = (i + DIM) % DIM;
    int col = (j + DIM) % DIM;
    return state[row][col];
}

int countNeighbours(bool state[DIM][DIM], int i, int j) {
    return get(state, i - 1, j - 1) +
           get(state, i - 1, j) +
           get(state, i - 1, j + 1) +
           get(state, i, j - 1) +
           get(state, i, j + 1) +
           get(state, i + 1, j - 1) +
           get(state, i + 1, j) +
           get(state, i + 1, j + 1);
}

void update(bool prev[DIM][DIM], bool next[DIM][DIM]) {
    for (int i = 0; i < DIM; i++) {
        for (int j = 0; j < DIM; j++) {
            int neighbours = countNeighbours(prev, i, j);
            if (prev[i][j]) {
                next[i][j] = neighbours == 2 || neighbours == 3;
            } else {
                next[i][j] = neighbours == 3;
            }
        }
    }
}

void render(bool state[DIM][DIM]) {
    for (int i = 0; i < DIM; i++) {
        for (int j = 0; j < DIM; j++) {
            if (state[i][j]) {
                printf(LIVE);
            } else {
                printf(DEAD);
            }
        }
        printf("\n");
    }
}

int main() {
    bool (*state)[DIM];
    bool (*prev)[DIM];

    state = malloc(sizeof(bool[DIM][DIM]));
    init(state);
    render(state);

    while (true)
    {
        usleep(FRAME_MS * 1000);
        prev = state;
        state = malloc(sizeof(bool[DIM][DIM]));
        update(prev, state);
        free(prev);
        clear();
        render(state);
    }
    
    free(state);
    return 0;
}
