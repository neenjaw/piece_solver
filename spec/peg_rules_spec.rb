# frozen_string_literal: true

require "spec_helper"
require_relative "../lib/piece_solver/peg_rules"

RSpec.describe PieceSolver::PegRules do
  it "accepts a valid peg triplet for 5x5 (any peg per domain)" do
    pegs = [[1, 0], [2, 2], [3, 1]]
    expect { described_class.validate!(pegs, board_size: 5) }.not_to raise_error
  end

  it "rejects a peg that is not in any domain" do
    pegs = [[2, 0], [2, 2], [3, 1]] # (2,0) is not in any allowed list
    expect { described_class.validate!(pegs, board_size: 5) }.to raise_error(ArgumentError, /not in any allowed domain/)
  end

  it "rejects out-of-bounds coordinates" do
    pegs = [[0, 0], [4, 4], [10, 10]]
    expect { described_class.validate!(pegs, board_size: 5) }.to raise_error(ArgumentError, /out of bounds/)
  end

  it "filters OOB entries from allowed positions for 5x5 (e.g., (0,5))" do
    allowed = described_class.allowed_positions(5)
    expect(allowed[0]).not_to include([0, 5])
  end
end
