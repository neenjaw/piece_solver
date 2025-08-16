# frozen_string_literal: true

require "io/console"
require_relative "ansi_renderer"
require_relative "peg_rules"

module PieceSolver
  # Simple interactive peg placement with arrow keys or hjkl
  class InteractivePegs
    Result = Struct.new(:pegs, keyword_init: true)

    def initialize(board_size: 5, domains: PegRules.allowed_positions(5))
      @board_size = board_size
      @domains = domains
      @pegs = []
      @cursor = [0, 0]
    end

    def run
      with_raw_tty do
        instructions
        while @pegs.size < 3
          draw
          key = read_key
          handle_key(key)
        end
      end
      Result.new(pegs: @pegs)
    end

    private

    def instructions
      puts "Interactive mode: place 3 pegs (toggle to place/remove)"
      puts "Keys: arrows or h/j/k/l to move, space/enter to toggle, u to undo, q to quit"
      puts "Ctrl-C / Ctrl-D to quit"
      puts "Domains (one peg per domain):"
      @domains.each_with_index do |d, i|
        puts "  D#{i}: #{d.inspect}"
      end
    end

    def draw
      # Clear screen and move cursor to home to avoid line wrapping/indentation issues
      print "\e[2J\e[H"
      candidates, domain_map = highlight_candidates_with_domains
      print AnsiRenderer.render(board_size: @board_size, pegs: @pegs, placements: nil, cursor: @cursor, highlight_cells: candidates, domain_highlights: domain_map)
      print "\r\n"
      puts "\nPegs placed: #{@pegs.size}/3"
    end

    def handle_key(key)
      case key
      when :up, 'k' then move(0, -1)
      when :down, 'j' then move(0, 1)
      when :left, 'h' then move(-1, 0)
      when :right, 'l' then move(1, 0)
      when :place then toggle_place
      when :undo then undo
      when :quit then abort("Aborted by user")
      end
    end

    def move(dx, dy)
      x, y = @cursor
      nx = [[x + dx, 0].max, @board_size - 1].min
      ny = [[y + dy, 0].max, @board_size - 1].min
      @cursor = [nx, ny]
    end

    def toggle_place
      if @pegs.include?(@cursor)
        @pegs.delete(@cursor)
        return
      end
      temp = @pegs + [@cursor]
      unless partial_feasible?(temp)
        warn "invalid placement (domain conflict or out of domains)"
        sleep 0.6
        return
      end
      @pegs << @cursor.dup
    end

    def undo
      @pegs.pop
    end

    def with_raw_tty
      old_state = $stdin.raw!
      yield
    ensure
      $stdin.cooked!
    end

    # Basic key reader for arrows, hjkl, space/enter, u, q
    def read_key
      c1 = $stdin.getch
      case c1
      when "\e"
        c2 = $stdin.getch
        return :quit unless c2
        if c2 == "["
          c3 = $stdin.getch
          case c3
          when "A" then return :up
          when "B" then return :down
          when "C" then return :right
          when "D" then return :left
          end
        end
      when "\u0003" then return :quit # Ctrl-C
      when "\u0004" then return :quit # Ctrl-D
      when "h" then return :left
      when "j" then return :down
      when "k" then return :up
      when "l" then return :right
      when " " then return :place
      when "\r" then return :place
      when "u" then return :undo
      when "q" then return :quit
      end
      nil
    end

    # Check if the partial set of pegs can still satisfy one-per-domain rule
    def partial_feasible?(pegs_subset)
      return false unless pegs_subset.uniq.size == pegs_subset.size
      # All within bounds
      return false unless pegs_subset.all? { |(x, y)| x.between?(0, @board_size - 1) && y.between?(0, @board_size - 1) }

      allowed = @domains
      domain_opts = pegs_subset.map do |(x, y)|
        opts = allowed.each_index.select { |i| allowed[i].include?([x, y]) }
        return false if opts.empty?
        opts
      end

      # Try to assign distinct domains to each peg (permutation over 0..2)
      domains = [0, 1, 2]
      domains.permutation(pegs_subset.size).any? do |perm|
        perm.each_with_index.all? { |dom, i| domain_opts[i].include?(dom) }
      end
    end

    # Return set of candidate cells the current cursor could be placed in,
    # based on domains not yet used by placed pegs
    def highlight_candidates_with_domains
      used_domains = used_domain_indices(@pegs)
      remaining_domains = [0, 1, 2] - used_domains
      return [nil, nil] if remaining_domains.empty?

      candidates = []
      domain_map = {}
      remaining_domains.each do |di|
        @domains[di].each do |(x, y)|
          next unless x.between?(0, @board_size - 1) && y.between?(0, @board_size - 1)
          next if @pegs.include?([x, y])
          candidates << [x, y]
          domain_map[[x, y]] = di
        end
      end
      [candidates.to_set, domain_map]
    end

    def used_domain_indices(pegs)
      allowed = @domains
      # Greedy: map each peg to any matching domain, then minimal cover; since validation ensures feasibility, this is fine for highlighting
      indices = []
      pegs.each do |(x, y)|
        match = allowed.each_index.find { |i| allowed[i].include?([x, y]) }
        indices << match if match
      end
      indices
    end
  end
end
