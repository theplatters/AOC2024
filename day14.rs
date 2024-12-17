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

    let results: Vec<(i32, i32)> = positions
        .iter()
        .zip(velocities.iter())
        .map(|(pos, vel)| {
            (
                mod_pos(pos.0 + 100 * vel.0, 101),
                mod_pos(pos.1 + 100 * vel.1, 103),
            )
        })
        .collect();

    let part1 = quadrant(&results, (0, 0), (50, 51))
        * quadrant(&results, (0, 52), (50, 103))
        * quadrant(&results, (51, 0), (151, 51))
        * quadrant(&results, (51, 52), (150, 150));
    println!("Result {}", part1);

    let arr: [[char; 101]; 103] = [['-'; 101]; 103];
    // Print the array to verify
    for row in arr.iter() {
        for row in arr.iter() {
            let row_str: String = row.iter().collect();
            println!("{}", row_str);
        }
    }
}

// Function to parse "x,y" into a tuple (i32, i32)
fn parse_tuple(s: &str) -> (i32, i32) {
    let nums: Vec<i32> = s.split(',').map(|n| n.parse::<i32>().unwrap()).collect();
    (nums[0], nums[1])
}
fn mod_pos(a: i32, b: i32) -> i32 {
    (a % b + b) % b
}

fn quadrant(result: &[(i32, i32)], lower: (i32, i32), upper: (i32, i32)) -> usize {
    result
        .iter()
        .filter(|value| {
            value.0 >= lower.0 && value.1 >= lower.1 && value.0 < upper.0 && value.1 < upper.1
        })
        .count()
}
