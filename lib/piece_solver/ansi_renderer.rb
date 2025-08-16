# frozen_string_literal: true

module PieceSolver
  class AnsiRenderer
    RESET = "\e[0m"

    # Map piece names to foreground color codes (ANSI 8-color)
    # We draw with foreground-colored full blocks ("██") for better alignment
    PIECE_FG_COLORS = {
      "square"   => 34, # blue
      "bar"      => 36, # cyan
      "short_l"  => 32, # green
      "long_l"   => 35, # magenta
      "zig"      => 33, # yellow
      "triangle" => 37  # white
    }.freeze

    PEG_FG_COLOR = 31 # red

    def self.render(board_size:, pegs:, placements:, cursor: nil, highlight_cells: nil, domain_highlights: nil)
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

      # Build ANSI tile rows using foreground-colored full blocks
      tile_rows = (0...board_size).map do |y|
        (0...board_size).map do |x|
          cell = grid[y][x]
          if cell == :peg
            "\e[#{PEG_FG_COLOR}m██#{RESET}"
          elsif cell == :cursor
            "\e[97m██#{RESET}"
          elsif cell && PIECE_FG_COLORS[cell]
            "\e[#{PIECE_FG_COLORS[cell]}m██#{RESET}"
          else
            if highlight_cells && highlight_cells.include?([x, y])
              color = 90
              if domain_highlights && domain_highlights.is_a?(Hash)
                domain_idx = domain_highlights[[x, y]]
                # Map domain index 0,1,2 to cyan, yellow, magenta (36,33,35)
                color = { 0 => 36, 1 => 33, 2 => 35 }[domain_idx] || 90
              end
              "\e[#{color}m··#{RESET}"
            else
              "  "
            end
          end
        end.join
      end

      # Use Unicode box-drawing border sized for 2-char tiles
      horiz = "─" * (board_size * 2)
      top_border = "┌#{horiz}┐"
      bottom_border = "└#{horiz}┘"
      bordered_rows = tile_rows.map { |r| "│#{r}│" }

      # Legend
      legend = []
      legend << legend_entry("peg", PEG_FG_COLOR, fg: true)
      legend << legend_entry("cursor", 97, fg: true)
      PIECE_FG_COLORS.each do |name, fg|
        legend << legend_entry(name, fg, fg: true)
      end
      if domain_highlights
        legend << legend_entry("D0", 36, fg: true)
        legend << legend_entry("D1", 33, fg: true)
        legend << legend_entry("D2", 35, fg: true)
      end

      # Use CRLF to ensure return to column 0 on terminals that treat LF as line feed only
      ([top_border] + bordered_rows + [bottom_border, "", "Legend:", legend.join("  ")]).join("\r\n")
    end

    def self.legend_entry(name, code, fg: false)
      sample = if fg
        "\e[#{code}m██#{RESET}"
      else
        "\e[#{code}m  #{RESET}"
      end
      "#{sample} #{name}"
    end
  end
end
