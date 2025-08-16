# frozen_string_literal: true

module PieceSolver
  class PegRules
    # Returns allowed positions for each peg index (0-based array of arrays),
    # filtered to the board bounds.
    def self.allowed_positions(board_size = 5)
      raw = [
        [[1, 0], [0, 0], [0, 1], [0, 2], [0, 3], [0, 4], [0, 5]],
        [[1, 2], [2, 2], [2, 3], [2, 4], [3, 4], [4, 4], [4, 3]],
        [[1, 1], [2, 1], [3, 1], [3, 2], [3, 3], [4, 1], [4, 0], [3, 0]]
      ]
      raw.map do |list|
        list.select do |(x, y)|
          x.is_a?(Integer) && y.is_a?(Integer) &&
            x.between?(0, board_size - 1) && y.between?(0, board_size - 1)
        end
      end
    end

    # Validates peg triplet against allowed positions and board bounds.
    # Raises ArgumentError on problems; returns true otherwise.
    def self.validate!(pegs, board_size: 5)
      unless pegs.is_a?(Array) && pegs.size == 3
        raise ArgumentError, "expected 3 pegs, got #{pegs.inspect}"
      end
      unless pegs.all? { |p| p.is_a?(Array) && p.size == 2 && p.all? { |v| v.is_a?(Integer) } }
        raise ArgumentError, "pegs must be [[x,y], [x,y], [x,y]] with integers"
      end
      if pegs.uniq.size != 3
        raise ArgumentError, "pegs must be distinct"
      end

      allowed = allowed_positions(board_size)
      pegs.each_with_index do |(x, y), idx|
        unless x.between?(0, board_size - 1) && y.between?(0, board_size - 1)
          raise ArgumentError, "peg #{idx + 1} (#{x},#{y}) is out of bounds for #{board_size}x#{board_size}"
        end
        unless allowed[idx].include?([x, y])
          raise ArgumentError, "peg #{idx + 1} (#{x},#{y}) must be in #{allowed[idx].inspect}"
        end
      end

      true
    end
  end
end
