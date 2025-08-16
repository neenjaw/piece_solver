# frozen_string_literal: true

require "spec_helper"

RSpec.describe PieceSolver::Piece do
  let(:pieces) { PieceSolver::Pieces.all }

  it "computes exact unique orientation counts for all pieces" do
    counts = pieces.map { |p| [p.name, p.orientations.size] }.to_h
    expect(counts).to include(
      "square"   => 1,
      "bar"      => 2,
      "short_l"  => 4,
      "zig"      => 8,
      "triangle" => 4,
      "long_l"   => 8
    )
  end

  it "normalizes orientations to start at (0,0) and be within bounds" do
    pieces.each do |piece|
      piece.orientations.each do |cells|
        min_x = cells.map(&:first).min
        min_y = cells.map(&:last).min
        expect(min_x).to eq(0)
        expect(min_y).to eq(0)
      end
    end
  end
end
