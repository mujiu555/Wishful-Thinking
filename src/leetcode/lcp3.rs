struct Solution {
}
impl Solution {
    pub fn length_of_longest_substring(s: String) -> i32 {
        let mut window = vec![];

        let mut maxlen = 0;
        let mut clen = 0;

        if !s.is_ascii() {
            return 0;
        }

        let mut i = 0;
        let mut j = i;
        while i < s.len() && j < s.len() {
            let cc = char::from(s.as_bytes()[i]);

            if window.contains(&cc) {
                j += 1;
                window.remove(0);
                clen -= 1;
            } else {
                i += 1;
                window.push(cc);
                clen += 1;
                maxlen = std::cmp::max(maxlen, clen);
            }
        }
        maxlen
    }
}
