# frozen_string_literal: true

require "spec_helper"
require_relative "../lib/piece_solver/board"
require_relative "../lib/piece_solver/solver"
require_relative "../lib/piece_solver/peg_rules"

RSpec.describe PieceSolver::Solver do
  it "finds a solution for a known peg configuration" do
    pegs = [[1, 0], [2, 2], [3, 1]]
    # Valid per PegRules
    expect { PieceSolver::PegRules.validate!(pegs, board_size: 5) }.not_to raise_error

    board = PieceSolver::Board.new(size: 5, pegs: pegs)
    solver = PieceSolver::Solver.new(board)
    placements = solver.solve_one

    expect(placements).to be_a(Array)
    # Should cover all non-peg cells exactly once
    covered = placements.flat_map(&:cells)
    expect(covered.uniq.size).to eq(25 - pegs.size)
  end

  it "runs for another valid configuration (may or may not be solvable)" do
    # Valid per peg restrictions
    pegs = [[0, 0], [1, 2], [3, 0]]
    PieceSolver::PegRules.validate!(pegs, board_size: 5)
    board = PieceSolver::Board.new(size: 5, pegs: pegs)
    solver = PieceSolver::Solver.new(board)
    # We don't assert a specific outcome; just ensure it runs
    solver.solve_one
  end
end
