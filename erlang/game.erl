-module(game).
-export([start/0]).

-define(LIVE, <<226, 151, 189>>).
-define(DEAD, <<226, 151, 190>>).
-define(CLEAR, <<27, 91, 49, 65, 27, 91, 75>>).
-define(DIM, 32).

start() ->
    World = init(?DIM),
    Clear = lists:duplicate(?DIM, ?CLEAR),
    step(World, 1, Clear).

init(Dim) -> {Dim, build_world(1, Dim * Dim, [])}.

step(World, Step, Clear) ->
    clear(Step, Clear),
    render(World),
    timer:sleep(200),
    NewWorld = next(World),
    step(NewWorld, Step + 1, Clear).

next(World) -> next(World, 1, []).

next({Dim, _}, Index, NewState) when Index > Dim * Dim ->
    {Dim, NewState};
next({Dim, _} = World, Index, NewState) ->
    {Row, Col} = ltos(Index, Dim),
    Cell = get_cell(World, Row, Col),
    LiveNeighbours = live_neighbours(World, Row, Col),
    NewCell =
        case {Cell, LiveNeighbours} of
            {live, 2} -> live;
            {live, 3} -> live;
            {dead, 3} -> live;
            _ -> dead
        end,
    next(World, Index + 1, NewState ++ [NewCell]).

render(World) -> render(World, 1).
render({_, []}, _) ->
    noop;
render({Dim, [Cell | Rest]}, Index) ->
    case Cell of
        live -> io:format("~ts", [?LIVE]);
        dead -> io:format("~ts", [?DEAD])
    end,
    {_, Col} = ltos(Index, Dim),
    case Col rem Dim of
        0 -> io:fwrite("~n");
        _ -> noop
    end,
    render({Dim, Rest}, Index + 1).

clear(1, _) -> noop;
clear(_, Clear) -> io:format("~ts", [Clear]).

% Build a random(live,dead) list of size Size
build_world(Size, Size, Acc) -> [random_cell() | Acc];
build_world(Index, Size, Acc) -> build_world(Index + 1, Size, [random_cell() | Acc]).

random_cell() ->
    case rand:uniform() > 0.5 of
        true -> live;
        false -> dead
    end.

% Count live neighbours for a cell
live_neighbours(World, Row, Col) ->
    Neighbours = [
        get_cell(World, Row - 1, Col - 1),
        get_cell(World, Row - 1, Col),
        get_cell(World, Row - 1, Col + 1),
        get_cell(World, Row, Col - 1),
        get_cell(World, Row, Col + 1),
        get_cell(World, Row + 1, Col - 1),
        get_cell(World, Row + 1, Col),
        get_cell(World, Row + 1, Col + 1)
    ],
    lists:foldl(
        fun(Cell, Count) ->
            case Cell of
                live -> Count + 1;
                dead -> Count
            end
        end,
        0,
        Neighbours
    ).

get_cell({Dim, State}, Row, Col) when Row < 1 -> get_cell({Dim, State}, Row + Dim, Col);
get_cell({Dim, State}, Row, Col) when Col < 1 -> get_cell({Dim, State}, Row, Col + Dim);
get_cell({Dim, State}, Row, Col) when Row > Dim -> get_cell({Dim, State}, Row - Dim, Col);
get_cell({Dim, State}, Row, Col) when Col > Dim -> get_cell({Dim, State}, Row, Col - Dim);
get_cell({Dim, State}, Row, Col) ->
    Index = stol(Row, Col, Dim),
    lists:nth(Index, State).

% square <> linear
stol(Row, Col, Dim) -> (Row - 1) * Dim + Col.
ltos(Index, Dim) -> {Index div Dim + 1, Index rem Dim}.
