# frozen_string_literal: true

module PieceSolver
  # Represents a polyomino piece and generates unique orientations
  class Piece
    attr_reader :name, :base_cells, :orientations

    def initialize(name, base_cells)
      @name = name
      @base_cells = normalize(base_cells)
      @orientations = compute_unique_orientations(@base_cells)
    end

    private

    def compute_unique_orientations(cells)
      transforms = all_transforms
      shapes = transforms.map { |t| normalize(apply_transform(cells, t)) }
      # dedupe by set of coords
      unique = []
      seen = {}
      shapes.each do |shape|
        key = shape.sort.flatten.join(",")
        next if seen[key]

        seen[key] = true
        unique << shape
      end
      unique
    end

    def all_transforms
      rotations = [
        ->(x, y) { [x, y] },
        ->(x, y) { [-y, x] },
        ->(x, y) { [-x, -y] },
        ->(x, y) { [y, -x] }
      ]
      flips = [
        ->(x, y) { [x, y] },              # no flip
        ->(x, y) { [-x, y] }              # horizontal flip
      ]
      transforms = []
      rotations.each do |rot|
        flips.each do |flip|
          transforms << ->(x, y) do
            xr, yr = rot.call(x, y)
            flip.call(xr, yr)
          end
        end
      end
      transforms
    end

    def apply_transform(cells, transform)
      cells.map { |(x, y)| transform.call(x, y) }
    end

    def normalize(cells)
      min_x = cells.map(&:first).min
      min_y = cells.map(&:last).min
      cells.map { |(x, y)| [x - min_x, y - min_y] }.uniq.sort
    end
  end
end
