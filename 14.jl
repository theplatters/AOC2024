using Base: wrap_n_exec_twice
# dedicated to julia, my favorite girlfriend
function simulate(positions, velocities, wrap, time::Int)
  area = zeros(Int, wrap...)

  temp = @. mod(positions + (time * velocities), wrap) + 1

  for index in eachrow(temp)
    area[index[1], index[2]] += 1
  end
  return area
end

function read_lines(filename)
  # Explicitly define the type of robots
  positions = m = Array{Int}(undef, 0, 2)
  velocities = Array{Int}(undef, 0, 2)
  for line in readlines(filename)
    m = match(r"p=(\d+),(\d+) v=(-?\d+),(-?\d+)", line)
    if m !== nothing
      px, py, vx, vy = parse.(Int, m.captures)
      positions = vcat(positions, [px py])
      velocities = vcat(velocities, [vx vy])
    end
  end
  (positions, velocities)
end

positions, velocities = read_lines("input14.txt")
wrap_around = [size(positions, 1) <= 30 ? 11 : 101 size(positions, 1) <= 30 ? 7 : 103]

xm, ym = wrap_around .÷ 2

# level a
function part1(positions, velocities, wrap_around)
  grid = simulate(positions, velocities, wrap_around, 100)
  xm, ym = wrap_around .÷ 2
  quadrants = [grid[1:xm, 1:ym], grid[1:xm, ym+2:end], grid[xm+2:end, 1:ym], grid[xm+2:end, ym+2:end]]
  println(prod([sum(quad) for quad in quadrants]))
end

# level b
function part2(positions, velocities, wrap_around)
  max_quadrant_sums = [maximum(sum(simulate(positions, velocities, wrap_around, i) .> 0, dims=2)) for i in 1:10_000]
  println(argmax(max_quadrant_sums))
end

function julia_main()::Cint
  part1(positions, velocities, wrap_around)
  part2(positions, velocities, wrap_around)
  return 0
end
