pub struct Solution {}

impl Solution {
    fn mid(nums: &[i32]) -> f64 {
        let len = nums.len();
        f64::from(nums[len / 2] + nums[len.div_ceil(2) - 1]) / 2.0
    }

    pub fn find_median_sorted_arrays(nums1: Vec<i32>, nums2: Vec<i32>) -> f64 {
        if nums1.is_empty() {
            return Solution::mid(nums2.as_slice());
        } else if nums2.is_empty() {
            return Solution::mid(nums1.as_slice());
        }
        let (nums1, nums2) = if nums1.len() > nums2.len() {
            (nums2, nums1)
        } else {
            (nums1, nums2)
        };
        // l1 <= l2
        let l1 = nums1.len();
        let l2 = nums2.len();

        let mut upper = l1;
        let mut lower = 0;

        // left part |    right part
        //   i + j   | l1 + l2 - i - j
        // count from 1
        // index next one
        loop {
            // i + j = (l1 + l2) / 2;
            // i \in [0, l1)
            // j \in [1, (l1+l2)/2)
            let i = (upper - lower) / 2 + lower;
            let j = (l1 + l2) / 2 - i;
            // l1 < l2,
            // i <= l1 => j = (l1 + l2) / 2 - i > (l1 + l2) / 2 - m >= 1 >= 0,
            // i >= 0 => j = (l1 + l2) / 2 - i > (l1 + l2) / 2 <= n
            // if i == 0, j > 0,
            // if j == 0, i > 0
            if (i < l1) && nums2[j - 1] > nums1[i] {
                lower = i + 1;
            } else if i > 0 && nums1[i - 1] > nums2[j] {
                upper = i - 1;
            } else {
                let lm = if i == 0 {
                    nums2[j - 1]
                } else if j == 0 {
                    nums1[i - 1]
                } else {
                    std::cmp::max(nums1[i - 1], nums2[j - 1])
                };
                let rm = if i == l1 {
                    nums2[j]
                } else if j == l2 {
                    nums1[i]
                } else {
                    std::cmp::min(nums1[i], nums2[j])
                };
                if (l1 + l2) % 2 == 1 {
                    break f64::from(rm);
                } else {
                    break f64::from(lm + rm) / 2.0;
                }
            }
        }
    }
}

fn main() {
    print!(
        "{}",
        Solution::find_median_sorted_arrays(vec![1, 2, 3, 4], vec![4, 5, 6, 7])
    )
}
