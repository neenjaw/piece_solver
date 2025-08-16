# frozen_string_literal: true

require_relative "piece"

module PieceSolver
  module Pieces
    def self.all
      [
        Piece.new("short_l", [[0,0],[1,0],[0,1]]),
        Piece.new("long_l", [[0,0],[1,0],[2,0],[0,1]]),
        Piece.new("square",  [[0,0],[1,0],[0,1],[1,1]]),
        Piece.new("zig",     [[0,0],[0,1],[1,1],[2,1]]),
        Piece.new("bar",     [[0,0],[0,1],[0,2]]),
        Piece.new("triangle",[[0,0],[0,1],[1,1],[0,2]])
      ]
    end

    def self.by_name
      all.to_h { |p| [p.name, p] }
    end
  end
end
