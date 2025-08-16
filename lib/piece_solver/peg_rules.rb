# frozen_string_literal: true

module PieceSolver
  class PegRules
    # Returns allowed positions for each peg index (0-based array of arrays),
    # filtered to the board bounds.
    def self.allowed_positions(board_size = 5)
      raw = [
        [[1, 0], [0, 0], [0, 1], [0, 2], [0, 3], [0, 4], [1, 4]],
        [[1, 2], [2, 2], [2, 1], [2, 0], [3, 0], [4, 0], [4, 1]],
        [[1, 3], [2, 3], [3, 3], [3, 2], [3, 1], [4, 3], [4, 4], [3, 4]]
      ]
      raw.map do |list|
        list.select do |(x, y)|
          x.is_a?(Integer) && y.is_a?(Integer) &&
            x.between?(0, board_size - 1) && y.between?(0, board_size - 1)
        end
      end
    end

    # Validates peg triplet against allowed domains and board bounds.
    # Generalized rule: exactly one peg must fall in each domain, but any peg
    # can occupy any domain (no index-to-domain binding). Raises ArgumentError
    # on problems; returns true otherwise.
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
      end

      # Build domain options for each peg coordinate
      domain_options = pegs.map do |(x, y)|
        allowed.each_index.select { |di| allowed[di].include?([x, y]) }
      end

      if domain_options.any?(&:empty?)
        idx = domain_options.index { |opts| opts.empty? }
        raise ArgumentError, "peg #{idx + 1} (#{pegs[idx].join(',')}) is not in any allowed domain"
      end

      # Try all assignments of domains (permutations of [0,1,2]) so that each
      # peg takes one domain it belongs to, with all domains used exactly once.
      domains = [0, 1, 2]
      feasible = domains.permutation.any? do |perm|
        perm.each_with_index.all? { |dom, i| domain_options[i].include?(dom) }
      end
      unless feasible
        raise ArgumentError, "pegs must occupy exactly one coordinate in each domain (domains: #{allowed.inspect})"
      end

      true
    end
  end
end
