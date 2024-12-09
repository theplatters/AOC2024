content = File.read('input9.txt').split(//).map(&:to_i)
# content = '2333133121414131402'.split(//).map(&:to_i)
file = true

def check_sum(disk)
  cs = 0
  disk.each_with_index do |e, i|
    cs += e * i if e != -1
  end
  cs
end

disk = []
disk2 = []
id = 0
content.each do |e|
  if file
    disk += Array.new(e, id)
    disk2 << [e, id]
    id += 1
    file = false
  else
    disk += Array.new(e, -1)
    disk2 << [e, -1]
    file = true
  end
end

free_space = disk.count(-1)
while free_space != 0
  el = disk.pop
  disk[disk.index(-1)] = el if el != -1

  free_space -= 1
end

puts check_sum disk

# =========================
#          Part 2
# =========================

i = disk2.length - 1
while i.positive?
  file = disk2[i].clone
  i -= 1
  next unless file[1] != -1

  place_into = disk2[0..i].index { |e| e[1] == -1 and e[0] >= file[0] }
  next unless place_into

  free_space = disk2[place_into].clone
  disk2[i + 1] = [file[0], -1]
  disk2[place_into] = file
  if file[0] < free_space[0]
    disk2.insert(place_into + 1, [free_space[0] - file[0], -1]) or i -= 1
    i += 1
  end
end

disk3 = []

disk2.each do |e|
  disk3 += Array.new(e[0], e[1]) if e[0] != 0
end

puts check_sum disk3
