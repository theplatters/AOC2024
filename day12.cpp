#include <array>
#include <cstddef>
#include <cstring>
#include <fstream>
#include <iostream>
#include <map>
#include <numeric>
#include <set>
#include <stdexcept>
#include <vector>

#define NROWS 140
#define NCOLS 140
#define INPUT_FILE "input12.txt"

using Par = std::pair<int, int>;

Par add(Par a, Par b) { return Par(a.first + b.first, a.second + b.second); }
bool inbounds(Par &a) {
  auto condition = [](int x) { return x >= 0 && x < NCOLS; };
  return condition(a.first) && condition(a.second);
}

static const Par up_dir = Par(0, -1);
static const Par down_dir = Par(0, 1);
static const Par left_dir = Par(-1, 0);
static const Par right_dir = Par(1, 0);

class Graph {
  std::map<Par, std::set<Par>> adj_list;
  std::set<Par> vertices;

private:
  template <typename SetType>
  void bounds(Par &dir, SetType &intersections, std::set<Par> &duplicates) {
    if (!vertices.contains(dir)) {
      if (intersections.contains(dir)) {
        duplicates.insert(dir);
      } else {
        intersections.insert(dir);
      }
    }
  }

  template <typename SetType>
  long calculateWalls(SetType &intersections, std::set<Par> &duplicates,
                      Par dir) {
    auto curr = Par(-10, -10);
    long wall_number = 0;
    bool duplicate_wall = false;
    for (const auto &par : intersections) {
      if (par != curr) {
        wall_number++;
        curr = par;
        duplicate_wall = false;
      }
      if (duplicates.contains(par) && !duplicate_wall) {
        wall_number++;
        duplicate_wall = true;
      } else if (duplicate_wall) {
        duplicate_wall = duplicates.contains(par);
      }
      curr = add(curr, dir);
    }
    return wall_number;
  }

public:
  Graph() {
    vertices = std::set<Par>();
    adj_list = std::map<Par, std::set<Par>>();
  }

  void add_vertex(Par a) { vertices.insert(a); }
  void add_edge(Par a, Par b) {
    if (!vertices.contains(a) || !vertices.contains(b))
      throw std::out_of_range("Vertices not in Graph");
    adj_list[a].insert(b);
    adj_list[b].insert(a);
  }

  size_t size() { return vertices.size(); }

  int fences() {
    if (vertices.size() == 1)
      return 4;
    int sum = 0;
    for (const auto &x : adj_list) {
      sum += 4 - x.second.size();
    }
    return sum;
  }

  int sides() {
    auto cmp = [](const Par &left, const Par &right) {
      return (left.second < right.second) ||
             (left.second == right.second && left.first < right.first);
    };
    std::set<Par> intersections_x;
    std::set<Par, decltype(cmp)> intersections_y;

    std::set<Par> duplicates_x;
    std::set<Par> duplicates_y;

    for (const auto &p : vertices) {
      auto up = add(p, up_dir);
      auto down = add(p, down_dir);
      auto left = add(p, left_dir);
      auto right = add(p, right_dir);

      bounds(up, intersections_y, duplicates_y);
      bounds(down, intersections_y, duplicates_y);
      bounds(left, intersections_x, duplicates_x);
      bounds(right, intersections_x, duplicates_x);
    }

    long wall_number = calculateWalls(intersections_x, duplicates_x, down_dir) +
                       calculateWalls(intersections_y, duplicates_y, right_dir);

    return wall_number;
  }
};

void bfs(std::array<std::array<char, NROWS>, NCOLS> &matrix, Par curr,
         std::set<Par> &visited, Graph &g) {

  if (visited.contains(curr)) {
    return;
  }

  visited.insert(curr);

  std::array<Par, 4> directions = {add(curr, up_dir), add(curr, down_dir),
                                   add(curr, left_dir), add(curr, right_dir)};

  for (auto &dir : directions) {
    if (inbounds(dir) &&
        matrix[curr.second][curr.first] == matrix[dir.second][dir.first]) {
      g.add_vertex(dir);
      g.add_edge(curr, dir);
      bfs(matrix, dir, visited, g);
    }
  }
}

int main() {
  // Define the matrix dimensions (known beforehand)
  const int rows = NROWS;
  const int cols = NCOLS;

  // Static 2D char array
  std::array<std::array<char, cols>, cols> matrix;

  // File path to the matrix file
  std::string filePath = INPUT_FILE;

  // Open the file
  std::ifstream file(filePath);
  if (!file.is_open()) {
    std::cerr << "Failed to open the file!" << std::endl;
    return 1;
  }

  for (int i = 0; i < rows; ++i) {
    std::string line;
    if (std::getline(file, line)) {
      for (int j = 0; j < cols; ++j) {
        matrix[i][j] = line[j];
      }
    } else {
      std::cerr << "File does not contain enough rows!" << std::endl;
      return 1;
    }
  }

  std::vector<Graph> graphs;
  std::set<Par> visited;
  for (int i = 0; i < NROWS; i++) {
    for (int j = 0; j < NCOLS; j++) {
      if (matrix[i][j] != '-') {
        auto curr = Par(j, i);
        visited.clear();
        graphs.emplace_back();
        graphs.back().add_vertex(curr);
        bfs(matrix, curr, visited, graphs.back());
        for (const auto &par : visited) {
          matrix[par.second][par.first] = '-';
        }
      }
    }
  }

  auto reducer = [](size_t acc, auto &g) {
    return acc + g.size() * g.fences();
  };

  std::cout << std::accumulate(graphs.begin(), graphs.end(), size_t(0), reducer)
            << std::endl;

  auto reducer2 = [](size_t acc, auto &g) {
    return acc + g.size() * g.sides();
  };

  std::cout << std::accumulate(graphs.begin(), graphs.end(), size_t(0),
                               reducer2)
            << std::endl;

  file.close(); // Close the file

  return 0;
}
