#include <cstring>
#include <fstream>
#include <iostream>
#include <vector>

int main() {
  // Define the matrix dimensions (known beforehand)
  const int rows = 140;
  const int cols = 140;

  // Static 2D char array
  char matrix[rows][cols];

  // File path to the matrix file
  std::string filePath = "input12.txt";

  // Open the file
  std::ifstream file(filePath);
  if (!file.is_open()) {
    std::cerr << "Failed to open the file!" << std::endl;
    return 1;
  }

  // Read the matrix from the file
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

  file.close(); // Close the file

  // Print the matrix to verify
  for (int i = 0; i < rows; ++i) {
    for (int j = 0; j < cols; ++j) {
      std::cout << matrix[i][j];
    }
    std::cout << std::endl;
  }

  return 0;
}
