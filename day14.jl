using Base: nothing_sentinel
# dedicated to julia, my favorite girlfriend
function simulate(positions, velocities, wrap, time::Int)
  area = zeros(Int, wrap...)
  simulate!(area, positions, velocities, wrap, time)
  return area
end

function simulate!(area, positions, velocities, wrap, time::Int)
  area .= 0
  @simd for i in axes(positions, 1)
    @inbounds x = mod(positions[i, 1] + time * velocities[i, 1], wrap[1]) + 1
    @inbounds y = mod(positions[i, 2] + time * velocities[i, 2], wrap[2]) + 1
    @inbounds area[x, y] += 1
  end
  nothing
end

function read_lines(filename)
  # Explicitly define the type of robots
  lines = readlines(filename)
  positions = m = Array{Int}(undef, length(lines), 2)
  velocities = Array{Int}(undef, length(lines), 2)
  re = r"p=(\d+),(\d+) v=(-?\d+),(-?\d+)"
  for (idx, line) in enumerate(lines)
    m = match(re, line)
    if m !== nothing
      px, py, vx, vy = parse.(Int, m.captures)
      @inbounds positions[idx, :] .= [px, py]
      @inbounds velocities[idx, :] .= [vx, vy]
    end
  end
  (positions, velocities)
end

# level a
function part1(positions, velocities, wrap_around)
  grid = simulate(positions, velocities, wrap_around, 100)
  xm, ym = wrap_around .÷ 2
  quadrants = [grid[1:xm, 1:ym], grid[1:xm, ym+2:end], grid[xm+2:end, 1:ym], grid[xm+2:end, ym+2:end]]
  println(prod([sum(quad) for quad in quadrants]))
end

# level b
function part2(positions, velocities, wrap_around)
  max_count = 0
  best_i = 0
  simulation_result = Matrix{Int}(undef, wrap_around...)
  for i in 1:10_000
    simulate!(simulation_result, positions, velocities, wrap_around, i)
    ct = count(!iszero, simulation_result)
    if ct > max_count
      max_count = ct
      best_i = i
    end
  end
  println(best_i)
end

function julia_main()::Cint
  positions, velocities = read_lines("input14.txt")
  wrap_around = [size(positions, 1) <= 30 ? 11 : 101 size(positions, 1) <= 30 ? 7 : 103]

  part1(positions, velocities, wrap_around)
  part2(positions, velocities, wrap_around)
  return 0
end

@time julia_main()
@time julia_main()
