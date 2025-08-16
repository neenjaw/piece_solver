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

    def self.render(board_size:, pegs:, placements:, cursor: nil)
      grid = Array.new(board_size) { Array.new(board_size, nil) }

      pegs.each do |(x, y)|
        next unless x.between?(0, board_size - 1) && y.between?(0, board_size - 1)
        grid[y][x] = :peg
      end

      if placements
        placements.each do |pl|
          name = pl.piece_name
          pl.cells.each do |(x, y)|
            grid[y][x] = name
          end
        end
      end

      if cursor
        cx, cy = cursor
        if cx.between?(0, board_size - 1) && cy.between?(0, board_size - 1)
          grid[cy][cx] = :cursor unless grid[cy][cx]
        end
      end

      # Build ANSI tile rows
      tile_rows = grid.map do |row|
        row.map do |cell|
          if cell == :peg
            "\e[#{PEG_BG_COLOR}m  #{RESET}"
          elsif cell == :cursor
            "\e[107m  #{RESET}"
          elsif cell && PIECE_BG_COLORS[cell]
            "\e[#{PIECE_BG_COLORS[cell]}m  #{RESET}"
          else
            "\e[#{EMPTY_BG_COLOR}m  #{RESET}"
          end
        end.join
      end

      # Add a Unicode border sized for two-character-wide tiles
      horiz = "─" * (board_size * 2)
      top_border = "┌#{horiz}┐"
      bottom_border = "└#{horiz}┘"
      bordered_rows = tile_rows.map { |r| "│#{r}│" }

      # Legend
      legend = []
      legend << legend_entry("peg", PEG_BG_COLOR)
      legend << legend_entry("cursor", 107)
      PIECE_BG_COLORS.each do |name, bg|
        legend << legend_entry(name, bg)
      end

      ([top_border] + bordered_rows + [bottom_border, "", "Legend:", legend.join("  ")]).join("\n")
    end

    def self.legend_entry(name, bg)
      sample = "\e[#{bg}m  #{RESET}"
      "#{sample} #{name}"
    end
  end
end
