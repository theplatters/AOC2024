use std::fs;

fn main() {
    let binding = fs::read_to_string("input14.txt").expect("Whupsie");

    let contents = binding.split_terminator("\n").collect::<Vec<&str>>();

    // Two vectors for positions and velocities
    let mut positions = Vec::new();
    let mut velocities = Vec::new();
    // Process each line
    for line in contents {
        let parts: Vec<&str> = line.split_whitespace().collect();

        // Extract position (p=...) and velocity (v=...) parts
        if let (Some(p_str), Some(v_str)) = (parts.get(0), parts.get(1)) {
            // Parse position
            let position = parse_tuple(&p_str[2..]);
            // Parse velocity
            let velocity = parse_tuple(&v_str[2..]);

            positions.push(position);
            velocities.push(velocity);
        }
    }

    let mut step_iterator = StepIterator::new(&positions, &velocities);
    let _v: Vec<(usize, usize)> = (30..=32).map(|i| (50, i)).collect();
    for n in 0..15000 {
        if let Some(result) = step_iterator.next() {
            if entropy(&result) < 50_000_000 {
                println!("Found at {}", n);
                println!("Entropy: {}", entropy(&result));
                let matrix = draw_matrix(&result);
                print_matrix(&matrix);
            }
        }
    }
    println!("Result {:?}", move_steps(&positions, &velocities, 100));
}

fn step(positions: &[(i32, i32)], velocities: &[(i32, i32)], n: i32) -> Vec<(usize, usize)> {
    positions
        .iter()
        .zip(velocities.iter())
        .map(|(pos, vel)| {
            (
                mod_pos(pos.0 + n * vel.0, 101),
                mod_pos(pos.1 + n * vel.1, 103),
            )
        })
        .collect()
}

fn entropy(result: &[(usize, usize)]) -> usize {
    quadrant(result, (0, 0), (50, 51))
        * quadrant(result, (0, 52), (50, 103))
        * quadrant(result, (51, 0), (151, 51))
        * quadrant(result, (51, 52), (150, 150))
}
fn move_steps(positions: &[(i32, i32)], velocities: &[(i32, i32)], n: i32) -> usize {
    let result: Vec<(usize, usize)> = step(positions, velocities, n);

    entropy(&result)
}

// Function to parse "x,y" into a tuple (i32, i32)
fn parse_tuple(s: &str) -> (i32, i32) {
    let nums: Vec<i32> = s.split(',').map(|n| n.parse::<i32>().unwrap()).collect();
    (nums[0], nums[1])
}
fn mod_pos(a: i32, b: i32) -> usize {
    ((a % b + b) % b) as usize
}

fn quadrant(result: &[(usize, usize)], lower: (usize, usize), upper: (usize, usize)) -> usize {
    result
        .iter()
        .filter(|value| {
            value.0 >= lower.0 && value.1 >= lower.1 && value.0 < upper.0 && value.1 < upper.1
        })
        .count()
}

fn draw_matrix(indices: &[(usize, usize)]) -> Vec<Vec<char>> {
    // Initialize the matrix with '-' in all positions
    let mut matrix = vec![vec!['-'; 102]; 104];

    // Place the special character (e.g., 'X') at the specified indices
    for &(row, col) in indices {
        if row < 101 && col < 103 {
            matrix[col][row] = 'X';
        }
    }

    matrix
}

fn print_matrix(matrix: &[Vec<char>]) {
    for row in matrix {
        println!("{}", row.iter().collect::<String>());
    }
}

struct StepIterator<'a> {
    current_positions: Vec<(i32, i32)>,
    velocities: &'a [(i32, i32)],
}

impl<'a> Iterator for StepIterator<'a> {
    type Item = Vec<(usize, usize)>;

    fn next(&mut self) -> Option<Self::Item> {
        // Update current positions by adding velocities
        self.current_positions
            .iter_mut()
            .zip(self.velocities.iter())
            .for_each(|(pos, vel)| {
                pos.0 = mod_pos(pos.0 + vel.0, 101) as i32;
                pos.1 = mod_pos(pos.1 + vel.1, 103) as i32;
            });

        // Convert to usize with wrapping and return the result
        Some(
            self.current_positions
                .iter()
                .map(|&(x, y)| (x as usize, y as usize))
                .collect(),
        )
    }
}

impl<'a> StepIterator<'a> {
    fn new(positions: &'a [(i32, i32)], velocities: &'a [(i32, i32)]) -> Self {
        StepIterator {
            current_positions: positions.to_vec(),
            velocities,
        }
    }
}
