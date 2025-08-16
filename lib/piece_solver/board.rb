# frozen_string_literal: true

require "set"

module PieceSolver
  class Board
    attr_reader :size, :pegs

    def initialize(size: 5, pegs: [])
      @size = size
      @pegs = Set.new(pegs.map { |(x, y)| [x, y] })
      @occupied = Set.new
    end

    def in_bounds?(x, y)
      x.between?(0, size - 1) && y.between?(0, size - 1)
    end

    def blocked?(x, y)
      @pegs.include?([x, y])
    end

    def occupied?(x, y)
      @occupied.include?([x, y])
    end

    def free?(x, y)
      in_bounds?(x, y) && !blocked?(x, y) && !occupied?(x, y)
    end

    def place(cells)
      cells.each { |(x, y)| @occupied.add([x, y]) }
    end

    def unplace(cells)
      cells.each { |(x, y)| @occupied.delete([x, y]) }
    end

    def occupancy_count
      @occupied.size
    end

    def free_cells_target
      size * size - @pegs.size
    end

    # Returns the next free cell to fill as [x, y], or nil if full.
    def next_free_cell
      (0...size).each do |y|
        (0...size).each do |x|
          return [x, y] if free?(x, y)
        end
      end
      nil
    end

    def occupied_cells
      @occupied.dup
    end
  end
end
