
#include <stdio.h>
#include <stdlib.h>
#define EXIT_SUCCESS 0
#define LIST_SIZE 1000

int comp(const void *el1, const void *el2) {
  int f = *((int *)el1);
  int s = *((int *)el2);
  if (f > s)
    return 1;
  if (f < s)
    return -1;
  return 0;
}

int part1(int *list1, int *list2) {
  qsort(list1, LIST_SIZE, sizeof(*list1), comp);
  qsort(list2, LIST_SIZE, sizeof(*list2), comp);

  int sum = 0;
  for (int i = 0; i < LIST_SIZE; i++) {
    sum += abs(list1[i] - list2[i]);
  }

  return sum;
}

int main(void) {
  FILE *file;
  int buffer[LIST_SIZE];
  // Open the binary file for reading
  file = fopen("input1.txt", "rb");
  if (file == NULL) {
    perror("Error opening file");
    return 1;
  }

  int list1[LIST_SIZE];
  int list2[LIST_SIZE];

  int first_num;
  int second_num;
  int i = 0;
  while (fscanf(file, "%d %d", &first_num, &second_num) == 2) {
    list1[i] = first_num;
    list2[i] = second_num;
    i++;

    if (i > LIST_SIZE) {
      perror("Buffer Overflow");
      return -1;
    }
  }

  // Close the file
  fclose(file);
  int sum = part1(list1, list2);
  printf("%d \n", sum);

  sum = 0;
  int inner_sum = 0;
  for (int i = 0; i < LIST_SIZE; i++) {
    inner_sum = 0;
    for (int j = 0; j < LIST_SIZE; j++) {
      if (list1[i] == list2[j]) {
        inner_sum += 1;
      }
    }
    sum += inner_sum * list1[i];
  }

  printf("%d", sum);

  return EXIT_SUCCESS;
}
