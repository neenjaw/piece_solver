# frozen_string_literal: true

require "spec_helper"
require_relative "../lib/piece_solver/ansi_renderer"
require_relative "../lib/piece_solver/board"
require_relative "../lib/piece_solver/solver"

RSpec.describe PieceSolver::AnsiRenderer do
  it "renders ANSI output for a solved board" do
    pegs = [[1, 0], [2, 2], [3, 1]]
    board = PieceSolver::Board.new(size: 5, pegs: pegs)
    solver = PieceSolver::Solver.new(board)
    placements = solver.solve_one
    expect(placements).to be_a(Array)

    output = described_class.render(board_size: 5, pegs: pegs, placements: placements)
    expect(output).to include("Legend:")
    expect(output).to include("\e[")
  end
end
