### Piece Solver

A tiny Ruby CLI that solves a 5×5 pegged polyomino puzzle. Provide three peg coordinates and it finds a tiling of six pieces that covers all non‑pegged cells.

### Requirements
- Ruby 3.4.4 (see `mise.toml`)
- Bundler

If you use `mise`:
```bash
mise install  # installs Ruby 3.4.4
```

### Setup
```bash
bundle install
```

### Usage
- Coordinates are zero‑based `(x,y)` with origin at top‑left.
- Provide exactly three pegs.

Solve and print JSON (default):
```bash
bin/solve --pegs "1,0 3,2 4,4"
```

ANSI render (colored board in terminal):
```bash
bin/solve --pegs "1,0 3,2 4,4" --format ansi
```

Interactive peg placement (use arrows or `h`,`j`,`k`,`l`; press space to toggle, enter to solve):
```bash
bin/solve --interactive
```

Exit codes:
- 0: solution found
- 1: invalid pegs (violates domain rule)
- 2: no solution

### Tests
```bash
bundle exec rspec
```
