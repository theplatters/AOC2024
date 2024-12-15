#include <algorithm>
#include <array>
#include <cstddef>
#include <cstring>
#include <fstream>
#include <iostream>
#include <map>
#include <numeric>
#include <ranges>
#include <set>
#include <stdexcept>
#include <vector>

#define NROWS 10
#define NCOLS 10

using Par = std::pair<int, int>;

Par add(Par a, Par b) { return Par(a.first + b.first, a.second + b.second); }
bool inbounds(Par &a) {
  auto condition = [](int x) { return x >= 0 && x < NCOLS; };
  return condition(a.first) && condition(a.second);
}

struct Graph {

  std::map<Par, std::set<Par>> adj_list;
  std::set<Par> vertices;

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
    auto filtered = vertices | std::views::filter([&](const auto &p) {
                      return adj_list[p].size() < 4;
                    });
    auto cmp = [](const Par &left, const Par &right) {
      return (left.second < right.second) ||
             (left.second == right.second && left.first < right.first);
    };
    std::set<Par> intersections_x;
    std::set<Par, decltype(cmp)> intersections_y;

    std::set<Par> duplicates_x;
    std::set<Par> duplicates_y;
    for (const auto &p : filtered) {
      auto up = add(p, Par(0, -1));
      auto down = add(p, Par(0, 1));
      auto left = add(p, Par(-1, 0));
      auto right = add(p, Par(1, 0));
      if (!vertices.contains(up)) {
        if (intersections_y.contains(up)) {
          duplicates_y.insert(up);
        } else {
          intersections_y.insert(up);
        }
      }
      if (!vertices.contains(down)) {
        if (intersections_y.contains(down)) {
          duplicates_y.insert(down);
        } else {
          intersections_y.insert(down);
        }
      }
      if (!vertices.contains(left)) {
        if (intersections_x.contains(left)) {
          duplicates_x.insert(left);
        } else {
          intersections_x.insert(left);
        }
      }
      if (!vertices.contains(right)) {
        if (intersections_x.contains(right)) {
          duplicates_x.insert(right);
        } else {
          intersections_x.insert(right);
        }
      }
    }

    long wall_number = 0;
    auto curr = Par(-10, -10);
    std::vector<Par> sides;
    for (const auto &par : intersections_x) {
      if (par != curr) {
        wall_number++;
        sides.push_back(par);
        if (duplicates_x.contains(par))
          wall_number++;
        curr = par;
      }
      curr = add(curr, Par(0, 1));
    }

    curr = Par(-10, -10);
    for (const auto &par : intersections_y) {
      if (par != curr) {
        wall_number++;
        sides.push_back(par);
        curr = par;
      }
      curr = add(curr, Par(1, 0));
    }

    std::cout << "Wall number: " << wall_number << "\n";
    return wall_number;
  }
};

void bfs(std::array<std::array<char, NROWS>, NCOLS> &matrix, Par curr, Par prev,
         std::set<Par> &visited, Graph &g) {

  g.add_vertex(curr);
  g.add_edge(curr, prev);
  if (visited.contains(curr)) {
    return;
  }

  visited.insert(curr);
  auto up = add(curr, Par(0, -1));
  auto down = add(curr, Par(0, 1));
  auto left = add(curr, Par(-1, 0));
  auto right = add(curr, Par(1, 0));
  if (inbounds(up) &&
      matrix[curr.second][curr.first] == matrix[up.second][up.first]) {
    bfs(matrix, up, curr, visited, g);
  }
  if (inbounds(down) &&
      matrix[curr.second][curr.first] == matrix[down.second][down.first]) {
    bfs(matrix, down, curr, visited, g);
  }
  if (inbounds(left) &&
      matrix[curr.second][curr.first] == matrix[left.second][left.first]) {
    bfs(matrix, left, curr, visited, g);
  }
  if (inbounds(right) &&
      matrix[curr.second][curr.first] == matrix[right.second][right.first]) {
    bfs(matrix, right, curr, visited, g);
  }
}

void bfs(std::array<std::array<char, NROWS>, NCOLS> &matrix, Par curr,
         std::set<Par> &visited, Graph &g) {

  g.add_vertex(curr);
  visited.insert(curr);

  auto up = add(curr, Par(0, -1));
  auto down = add(curr, Par(0, 1));
  auto left = add(curr, Par(-1, 0));
  auto right = add(curr, Par(1, 0));
  if (inbounds(up) &&
      matrix[curr.second][curr.first] == matrix[up.second][up.first]) {
    bfs(matrix, up, curr, visited, g);
  }
  if (inbounds(down) &&
      matrix[curr.second][curr.first] == matrix[down.second][down.first]) {
    bfs(matrix, down, curr, visited, g);
  }
  if (inbounds(left) &&
      matrix[curr.second][curr.first] == matrix[left.second][left.first]) {
    bfs(matrix, left, curr, visited, g);
  }
  if (inbounds(right) &&
      matrix[curr.second][curr.first] == matrix[right.second][right.first]) {
    bfs(matrix, right, curr, visited, g);
  }
}

int main() {
  // Define the matrix dimensions (known beforehand)
  const int rows = NROWS;
  const int cols = NCOLS;

  // Static 2D char array
  std::array<std::array<char, cols>, cols> matrix;

  // File path to the matrix file
  std::string filePath = "input12_2.txt";

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
        visited.clear();
        graphs.emplace_back();
        bfs(matrix, Par(j, i), visited, graphs.back());
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
