#[derive(Debug)]
pub struct Row {
    string: String,
}

impl From<&str> for Row {
    fn from(slice: &str) -> Self {
        Self {
            string: String::from(slice),
        }
    }
}

impl From<String> for Row {
    fn from(slice: String) -> Self {
        Self { string: slice }
    }
}

impl Row {
    pub fn len(&self) -> usize {
        self.string.len()
    }
}

impl Row {
    pub fn render(&self, start: usize, end: usize) -> &str {
        let end = std::cmp::min(end, self.string.len());
        let start = std::cmp::min(start, end);
        self.string.get(start..end).unwrap_or_default()
    }
}
