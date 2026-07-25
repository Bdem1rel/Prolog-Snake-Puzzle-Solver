# Prolog Snake Solver

A constraint logic programming solver for the Snake puzzle, implemented in SWI-Prolog using CLP(FD).

## The Puzzle

Snake is played on a rectangular grid. Given two marked head/tail cells and optional row/column hints, the goal is to draw a single connected path between them such that:

- The snake does not touch itself, not even diagonally (except through valid corner turns)
- Row/column numbers, where given, indicate how many cells in that row/column are part of the snake
- Pre-filled cells (empty or snake) must be respected

## Implementation

The solver is built around the `snake/4` predicate:

```prolog
snake(RowHints, ColHints, Grid, Solution)
```

Key design choices:
- **CLP(FD)** constraints are posted before labeling, enabling early pruning during search
- **ffc labeling strategy** (first-fail constraint) to minimize backtracking
- **2×2 sliding window** for the non-touching constraint
- **DFS-based connectivity check** run after labeling on the fully bound solution

## Files

| File | Description |
|------|-------------|
| `SnakeGame.pl` | Main solver implementation |
| `tests.pl` | Provided test suite and example puzzles |
| `mytests.pl` | Custom test cases targeting specific constraints |

## Requirements

- [SWI-Prolog](https://www.swi-prolog.org/) 8.0 or later
- CLP(FD) library (included with SWI-Prolog)

## Running

```bash
swipl SnakeGame.pl
```

Then query individual puzzles:

```prolog
?- solvePuzzle(p7x7).
?- timedSolveAll(p10x10).
```

Run the sanity checks (all should return `false`):

```prolog
?- testSanity.
?- testSolved.
?- testErrors.
?- testCycles.
?- testTricky.
```

Run the full test suite:

```prolog
?- test.
```
