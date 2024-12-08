module day8;

import std.stdio;
import std.file;
import std.algorithm : map;
import std.algorithm.comparison : equal;
import std.algorithm.iteration;
import std.array;
import std.range : enumerate;
import std.range : zip;

int[2] sub(int[2] a, int[2] b)
{
  return [a[0] - b[0], a[1] - b[1]];
}

int[2] add(int[2] a, int[2] b)
{
  return [a[0] + b[0], a[1] + b[1]];
}

int part1(dchar[][] content, int[2][][dchar] positions)
{

  bool[50][50] has_antinode;
  foreach (values; positions.byValue())
  {
    foreach (perm; values.permutations())
    {
      foreach (value1; zip(perm, perm[1 .. $]))
      {
        auto antinode = add(value1[0], sub(value1[0], value1[1]));

        if (antinode[0] >= 0 && antinode[0] < 50 && antinode[1] >= 0 && antinode[1] < 50)
        {
          has_antinode[antinode[0]][antinode[1]] = true;
        }
      }
    }
  }

  auto count = 0;
  foreach (row; has_antinode)
  {
    foreach (col; row)
    {
      if (col)
        count++;
    }
  }

  return count;
}

int part2(dchar[][] content, int[2][][dchar] positions)
{

  bool[50][50] has_antinode;
  foreach (values; positions.byValue())
  {
    foreach (perm; values.permutations())
    {
      foreach (value1; zip(perm, perm[1 .. $]))
      {
        auto direction = sub(value1[0], value1[1]);
        auto antinode = value1[0];

        while (antinode[0] >= 0 && antinode[0] < 50 && antinode[1] >= 0 && antinode[1] < 50)
        {
          has_antinode[antinode[0]][antinode[1]] = true;
          antinode = add(antinode, direction);
        }
      }
    }
  }

  auto count = 0;
  foreach (row; has_antinode)
  {
    foreach (col; row)
    {
      if (col)
        count++;
    }
  }

  return count;
}

void main()
{
  auto content = File("input8.txt")
    .byLine()
    .map!(x => x.array())
    .array();

  int[2][][dchar] positions;

  foreach (idx_y, line; content.enumerate(0))
  {
    foreach (idx_x, c; line.enumerate(0))
    {
      if (c == '.')
      {

      }
      else if (c in positions)
      {
        positions[c] ~= [idx_x, idx_y];
      }
      else
      {
        positions[c] = [[idx_x, idx_y]];
      }
    }
  }

  writeln(part1(content, positions));
  writeln(part2(content, positions));

}
