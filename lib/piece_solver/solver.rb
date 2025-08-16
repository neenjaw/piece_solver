# frozen_string_literal: true

require_relative "piece"
require_relative "pieces"
require_relative "board"

module PieceSolver
  class Solver
    Placement = Struct.new(:piece_name, :origin, :orientation_index, :cells, keyword_init: true)

    def initialize(board, pieces = Pieces.all)
      @board = board
      @pieces = pieces
      @solutions = []
    end

    def solve_one
      used = {}
      placements = []
      backtrack(placements, used)
      @solutions.first
    end

    private

    def backtrack(placements, used)
      # Check completion
      if @board.occupancy_count == @board.free_cells_target
        @solutions << placements.map(&:dup)
        return true
      end

      target = @board.next_free_cell
      return false unless target
      tx, ty = target

      # Try remaining pieces
      @pieces.each do |piece|
        next if used[piece.name]

        piece.orientations.each_with_index do |orientation, oidx|
          # Shift origins so that one of the oriented cells covers target
          orientation.each do |(dx, dy)|
            ox = tx - dx
            oy = ty - dy
            cells = orientation.map { |(cx, cy)| [ox + cx, oy + cy] }
            next unless placement_valid?(cells)

            @board.place(cells)
            used[piece.name] = true
            placements << Placement.new(piece_name: piece.name, origin: [ox, oy], orientation_index: oidx, cells: cells)

            return true if backtrack(placements, used)

            placements.pop
            used.delete(piece.name)
            @board.unplace(cells)
          end
        end
      end

      false
    end

    def placement_valid?(cells)
      cells.all? { |(x, y)| @board.free?(x, y) }
    end
  end
end
