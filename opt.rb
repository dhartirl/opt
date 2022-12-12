#!/usr/bin/env ruby
require 'benchmark'
require 'optparse'

$debug = false

def opt_log(obj)
  puts obj.to_s if $debug
end

def delimit(num)
  num.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
end

Point = Struct.new(:x, :y) do
  def self.from_s(str)
    parts = str.split(",")
    px = parts[0].scan(/\d+/).first.to_i
    py = parts[1].scan(/\d+/).first.to_i
    raise Exception.new("Invalid Point #{str}") if px.nil? || py.nil?
    Point.new(px, py)
  end

  def diff(point)
    Point.new(self.x - point.x, self.y - point.y)
  end

  def distance(point)
    diff_pt = diff(point)
    diff_pt.x.abs + diff_pt.y.abs
  end

  def steps_to(point)
    steps = ""
    moves = diff(point)
    moves.x.abs.times do
      steps << (moves.x > 0 ? 'W' : 'E')
    end
    moves.y.abs.times do
      steps << (moves.y > 0 ? 'S' : 'N')
    end
    steps
  end

  def to_s
    "(#{self.x},#{self.y})"
  end
end

Path = Struct.new(:points) do
  def length
    len = 0
    clean = 1
    points.each_index do |index|
      next if index === 0
      len += points[index - 1].distance(points[index]) + clean
    end
    len
  end

  def traverse
    @current = points.first
    output = ""
    points.each_with_index do |point, index|
      next if index === 0
      output << move_to(point)
    end
    output
  end

  def move_to(point)
    output = ""
    output << @current.steps_to(point)
    output << 'C'
    @current = point
    output
  end

  def concat(point)
    Path.new(points + [point])
  end

  def contains?(point)
    points.include?(point)
  end

  def to_s
    points.map(&:to_s).join(',')
  end
end

Grid = Struct.new(:height, :width, :origin, :points) do
  def draw
    output_lines = []
    height.times do |y|
      output_lines[y] = ""
      width.times do |x|
        output_lines[y] << char_for_point(Point.new(x, y))
      end
    end
    output_lines.reverse.each do |line|
      opt_log(line)
    end
  end

  def char_for_point(point)
    if origin == point
      "O"
    elsif points.include? point
      "X"
    else
      "_"
    end
  end

  def all_paths
    # Exhaustive approach to generating paths
    # Much slower than heuristic_paths but good for result comparison
    points.permutation.to_a.map do |perm|
      Path.new([origin].concat(perm))
    end
  end

  def discard_points(remaining_points, current_path)
    remaining_points.filter do |point|
      !current_path.contains?(point)
    end
  end

  def discard_paths(paths)
    # This is where the optimization happens
    num_kept = [(paths.size / 3).ceil, 1].max
    @paths_discarded += paths[num_kept..paths.size].size
    paths[0..num_kept]
  end

  def generate_paths(remaining_points, current_path)
    new_paths = remaining_points.map do |point|
      current_path.concat(point)
    end
    best_paths = discard_paths(new_paths.sort_by(&:length))

    best_paths = best_paths.map do |path|
      heuristic_paths(remaining_points, path)
    end
    best_paths.flatten
  end

  def heuristic_paths(remaining_points, current_path)
    remaining_points = discard_points(remaining_points, current_path)
    return current_path if remaining_points.size === 0

    generate_paths(remaining_points, current_path)
  end

  def possible_paths
    (1..points.size).reduce(1, :*)
  end

  def best_path
    @paths_discarded = 0
    opt_log "Generating paths..."
    opt_log "Possible paths: #{delimit(possible_paths)}"
    opt_log "This may take a while..." if points.size > 10
    sorted_paths = heuristic_paths(points, Path.new([origin])).sort_by(&:length)
    opt_log "Found #{delimit(sorted_paths.size)} paths"
    opt_log "Discarded #{delimit(@paths_discarded)} suboptimal branches"
    opt_log "Shortest path: #{sorted_paths.first.length}, Longest path: #{sorted_paths.last.length}"
    opt_log "Selected path: #{sorted_paths.first.to_s}"
    opt_log "There are #{sorted_paths.select {|p| p.length == sorted_paths.first.length}.length - 1} equivalent paths"
    sorted_paths.first
  end

  def valid?
    points.select { |point| point.x >= width || point.y >= height || point.x < 0 || point.y < 0 }.empty?
  end
end

def get_parameters
  xy = ARGV[0].split('x')
  points = ARGV[1].split(" ").map {|point| Point.from_s(point)}
  {
    width: xy[0].to_i,
    height: xy[1].to_i,
    points: points
  }
end

def set_opts
  OptionParser.new do |opts|
    opts.banner = "Usage: opt.rb [--debug] WxH \"(X,Y) (X,Y)\""

    opts.on("-d", "--debug", "Debug mode") do |d|
      $debug = true
    end
  end.parse!
end

def run(params)
  grid = Grid.new(params[:width], params[:height], Point.new(0, 0), params[:points])

  raise Exception.new('Invalid Grid') unless grid.valid?

  grid.draw

  bm = Benchmark.measure do
    result = grid.best_path.traverse
    puts result
    opt_log "Steps: #{result.length}"
  end

  opt_log "Calculation took #{bm.total.round(2)} seconds"
end

set_opts
params = get_parameters

run(params)