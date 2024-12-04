library(slider)

myData <- read.delim("input4.txt", header = FALSE)
print(myData)
input <- lapply(myData,function(x) strsplit(x, ""))
mat <- do.call("cbind",do.call("cbind",input))

window_size <- 4
part1 <- 0
search_string <- c("XMAS","SAMX")

for (i in 1:(nrow(mat) - window_size + 1)) {
  for (j in 1:(ncol(mat) - window_size + 1)) {
    window <- mat[i:(i + window_size - 1), j:(j + window_size - 1)]
    ad <- paste(diag(apply(window, 2, rev)), collapse = "")  # Reverse columns and take diagonal
    d <- paste(diag(window),collapse= "")

    if (d %in% search_string) {part1 <- part1 + 1}
    if (ad %in% search_string) {sum <- part1 + 1}
  }
}

for (i in 1:nrow(mat)){
  for (j in 1:(ncol(mat) - window_size + 1)) {
    window <- mat[i, j:(j + window_size - 1)]
    r <- paste(window, collapse = "")
    if (r %in% search_string){part1 <- part1 + 1}
  }
}

for (i in 1:(nrow(mat) - window_size + 1)){
  for (j in 1:ncol(mat)){
    window <- mat[i:(i + window_size - 1), j]
    r <- paste(window, collapse = "")
    if (r %in% search_string){part1 <- part1 + 1}
  }
}

print(part1)

#======================
#   Part 2
#======================


search_string2 <- c("MAS","SAM")

window_x <- 3
window_y <- 6
part2 <- 0

for (i in 1:(nrow(mat) - window_x + 1)) {
  for (j in 1:(ncol(mat) - window_y + 1)) {
    window <- mat[i:(i + window_x - 1), j:(j + window_y - 1)]
    ad <- paste(diag(apply(window, 2, rev)), collapse = "")  # Reverse columns and take diagonal
    d <- paste(diag(window),collapse= "")
    print(window)
    if(ad %in% search_string2 && d %in% search_string2) {part2 <- part2 + 1}
  }
}

