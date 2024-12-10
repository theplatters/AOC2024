import java.io.File; // Import the File class
import java.io.FileNotFoundException; // Import this class to handle errors
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Scanner;
import java.util.Set;
import java.util.stream.Stream;

public class day10 {

  static class Index {
    public int x;
    public int y;

    @Override
    public int hashCode() {
      final int prime = 31;
      int result = 1;
      result = prime * result + x;
      result = prime * result + y;
      return result;
    }

    @Override
    public boolean equals(Object obj) {
      if (this == obj)
        return true;
      if (obj == null)
        return false;
      if (getClass() != obj.getClass())
        return false;
      Index other = (Index) obj;
      if (x != other.x)
        return false;
      if (y != other.y)
        return false;
      return true;
    }

    @Override
    public String toString() {
      return "Index [x=" + x + ", y=" + y + "]";
    }

    Index(int x, int y) {
      this.x = x;
      this.y = y;
    }

    public Index add(Index other) {
      return new Index(this.x + other.x, this.y + other.y);
    }

    public Boolean inbounds() {
      return this.x < 60 && this.y < 60 && this.y >= 0 && this.x >= 0;
    }
  }

  public static List<Index> findAllIndices(List<List<Integer>> listOfLists, int target) {
    List<Index> result = new ArrayList<>();

    for (int i = 0; i < listOfLists.size(); i++) {
      List<Integer> subList = listOfLists.get(i);
      for (int j = 0; j < subList.size(); j++) {
        if (subList.get(j) == target) {
          result.add(new Index(j, i));
        }
      }
    }

    return result;
  }

  static class Score {
    public Set<Index> visited;
    int rating;

    public Score(Set<day10.Index> visited, int rating) {
      this.visited = visited;
      this.rating = rating;
    }

    void add(Score other) {
      this.visited.addAll(other.visited);
      this.rating += other.rating;
    }

    int score() {
      return this.visited.size();
    }

  }

  public static Score visit(int value, Index index, List<List<Integer>> matrix) {
    if (value == 9) {
      Set<Index> vi = new HashSet<>();
      vi.add(index);
      return new Score(vi, 1);
    }

    Index dir_up = index.add(new Index(0, -1));
    Index dir_down = index.add(new Index(0, 1));
    Index dir_left = index.add(new Index(1, 0));
    Index dir_right = index.add(new Index(-1, 0));

    Score sum = new Score(new HashSet<Index>(), 0);
    if (dir_up.inbounds() && (matrix.get(dir_up.y).get(dir_up.x) == value + 1)) {
      sum.add(visit(value + 1, dir_up, matrix));
    }
    if (dir_down.inbounds() && (matrix.get(dir_down.y).get(dir_down.x) == value + 1)) {
      sum.add(visit(value + 1, dir_down, matrix));
    }
    if (dir_left.inbounds() && (matrix.get(dir_left.y).get(dir_left.x) == value + 1)) {
      sum.add(visit(value + 1, dir_left, matrix));
    }
    if (dir_right.inbounds() && (matrix.get(dir_right.y).get(dir_right.x) == value + 1)) {
      sum.add(visit(value + 1, dir_right, matrix));
    }

    return sum;
  }

  public static void main(String[] args) {
    try {
      File myObj = new File("input10.txt");
      List<List<Integer>> lines = new ArrayList<>();
      Scanner myReader = new Scanner(myObj);
      while (myReader.hasNextLine()) {
        lines.add(myReader.nextLine().chars().map(x -> x - '0').boxed().toList());
      }

      List<Index> indices = findAllIndices(lines, 0);
      // Part 1
      int part1 = 0;
      for (Index index : indices) {
        part1 += visit(0, index, lines).score();
      }
      System.out.println(part1);

      // Part 2
      int part2 = 0;
      for (Index index : indices) {
        part2 += visit(0, index, lines).rating;
      }

      System.out.println(part2);
      myReader.close();
    } catch (FileNotFoundException e) {
      System.out.println("An error occurred.");
      e.printStackTrace();
    }
  }
}
