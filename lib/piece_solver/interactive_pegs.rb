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
      puts "Interactive mode: place 3 pegs"
      puts "Keys: arrows or h/j/k/l to move, space/enter to place, u to undo, q to quit"
      puts "Domains (one peg per domain):"
      @domains.each_with_index do |d, i|
        puts "  D#{i}: #{d.inspect}"
      end
    end

    def draw
      system("clear")
      puts AnsiRenderer.render(board_size: @board_size, pegs: @pegs, placements: nil, cursor: @cursor)
      puts "\nPegs placed: #{@pegs.size}/3"
    end

    def handle_key(key)
      case key
      when :up, 'k' then move(0, -1)
      when :down, 'j' then move(0, 1)
      when :left, 'h' then move(-1, 0)
      when :right, 'l' then move(1, 0)
      when :place then place
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

    def place
      return if @pegs.include?(@cursor)
      # Validate domain uniqueness as we place
      temp = @pegs + [@cursor]
      begin
        PegRules.validate!(temp, board_size: @board_size)
      rescue ArgumentError => e
        warn e.message
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
  end
end
