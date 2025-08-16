# frozen_string_literal: true

module PieceSolver
  class AnsiRenderer
    RESET = "\e[0m"

    # Map piece names to background color codes (ANSI 8-color backgrounds)
    # Pegs will use red background (41)
    PIECE_BG_COLORS = {
      "square"   => 44, # blue
      "bar"      => 46, # cyan
      "short_l"  => 42, # green
      "long_l"   => 45, # magenta
      "zig"      => 43, # yellow
      "triangle" => 47  # white
    }.freeze

    PEG_BG_COLOR = 41 # red
    EMPTY_BG_COLOR = 40 # black (shouldn't occur if fully tiled)

    def self.render(board_size:, pegs:, placements:)
      grid = Array.new(board_size) { Array.new(board_size, nil) }

      pegs.each do |(x, y)|
        next unless x.between?(0, board_size - 1) && y.between?(0, board_size - 1)
        grid[y][x] = :peg
      end

      placements.each do |pl|
        name = pl.piece_name
        pl.cells.each do |(x, y)|
          grid[y][x] = name
        end
      end

      lines = []
      grid.each do |row|
        line = row.map do |cell|
          if cell == :peg
            "\e[#{PEG_BG_COLOR}m  #{RESET}"
          elsif cell && PIECE_BG_COLORS[cell]
            "\e[#{PIECE_BG_COLORS[cell]}m  #{RESET}"
          else
            "\e[#{EMPTY_BG_COLOR}m  #{RESET}"
          end
        end.join
        lines << line
      end

      # Legend
      legend = []
      legend << legend_entry("peg", PEG_BG_COLOR)
      PIECE_BG_COLORS.each do |name, bg|
        legend << legend_entry(name, bg)
      end

      (lines + ["", "Legend:", legend.join("  ")]).join("\n")
    end

    def self.legend_entry(name, bg)
      sample = "\e[#{bg}m  #{RESET}"
      "#{sample} #{name}"
    end
  end
end
