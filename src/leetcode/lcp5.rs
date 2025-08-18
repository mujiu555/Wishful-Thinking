struct Solution {}

impl Solution {
    pub fn longest_palindrome(s: String) -> String {
        if !s.is_ascii() {
            return s;
        }
        let mut arr = [[false; 1000]; 1000];
        let str = s.as_bytes();

        let mut mi = 0;
        let mut mj = 0;
        for i in 0..s.len() {
            for j in 0..s.len() - i {
                if i == 0 {
                    arr[j][j + i] = true;
                } else if j + 1 == j + i {
                    arr[j][j + i] = str[j] == str[j + i];
                } else {
                    arr[j][j + i] = arr[j + 1][j + i - 1] && str[j] == str[j + i];
                }
                if mj - mi < i && arr[j][j + i] {
                    mi = j;
                    mj = j + i;
                }
            }
        }
        s[mi..=mj].to_string()
    }
}

fn main() {
    print!("{}", Solution::longest_palindrome(String::from("abacd")));
}
