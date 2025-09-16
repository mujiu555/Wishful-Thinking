use std::num;

struct Solution {}
impl Solution {
    pub fn convert(s: String, num_rows: i32) -> String {
        let total_length = s.len();
        let struct_length = num_rows + (num_rows - 2);
        let num_half_z = total_length.div_ceil(struct_length);
        let num_tile = total_length % struct_length;

        String::from("")
    }
}

fn main() {
    print!("{}", Solution::convert(String::from("PAYPALISHIRING"), 3));
}
