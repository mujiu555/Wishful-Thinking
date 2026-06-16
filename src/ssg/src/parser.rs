use serde_json::Value;
use std::collections::HashMap;

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Parse the first `#meta(…)` call found in `source` and return the named
/// arguments as a `field → JSON-value` map.  Returns `None` when no meta
/// call is present.
pub fn parse_meta_call(source: &str) -> Option<HashMap<String, Value>> {
    let start = find_meta_call(source)?;
    // `start` points to 'm' of "meta".  Advance past "meta" so the cursor
    // is positioned at the whitespace / '(' after the function name.
    let cursor_start = start + "meta".len();
    let mut c = Cursor::new(&source[cursor_start..]);

    c.skip_whitespace();
    if c.peek() != Some('(') {
        return None;
    }
    c.advance(); // consume '('

    let fields = c.parse_named_args().ok()?;
    Some(fields)
}

/// Find the byte offset of "meta" in `#meta(…)` or `#meta (…)`.
fn find_meta_call(source: &str) -> Option<usize> {
    let mut chars = source.char_indices().peekable();
    while let Some((i, ch)) = chars.next() {
        if ch == '#' {
            // Check for "meta" following optional whitespace
            let mut lookahead = chars.clone();
            // Skip whitespace
            while let Some((_, c)) = lookahead.peek() {
                if c.is_whitespace() {
                    lookahead.next();
                } else {
                    break;
                }
            }
            // Check for "meta"
            let mut buf = String::new();
            let mut la2 = lookahead.clone();
            for _ in 0..4 {
                match la2.next() {
                    Some((_, c)) => buf.push(c),
                    None => break,
                }
            }
            if buf == "meta" {
                // Verify it's followed by '(' or whitespace then '('
                let mut la3 = la2.clone();
                while let Some((_, c)) = la3.peek() {
                    if c.is_whitespace() {
                        la3.next();
                    } else {
                        break;
                    }
                }
                if la3.next().map(|(_, c)| c) == Some('(') {
                    return Some(i + 1); // position of 'm' in "meta"
                }
            }
            chars = lookahead;
        }
    }
    None
}

// ---------------------------------------------------------------------------
// Cursor
// ---------------------------------------------------------------------------

struct Cursor {
    chars: Vec<char>,
    pos: usize,
}

impl Cursor {
    fn new(input: &str) -> Self {
        Cursor {
            chars: input.chars().collect(),
            pos: 0,
        }
    }

    fn peek(&self) -> Option<char> {
        self.chars.get(self.pos).copied()
    }

    fn advance(&mut self) -> Option<char> {
        let c = self.chars.get(self.pos).copied();
        if c.is_some() {
            self.pos += 1;
        }
        c
    }

    fn skip_whitespace(&mut self) {
        while let Some(c) = self.peek() {
            if c.is_whitespace() || c == '\n' || c == '\r' {
                self.advance();
            } else {
                break;
            }
        }
    }

    /// Skip whitespace including Typst line comments `// …`.
    fn skip_whitespace_and_comments(&mut self) {
        loop {
            self.skip_whitespace();
            if self.peek() == Some('/') && self.chars.get(self.pos + 1) == Some(&'/') {
                // Skip to end of line
                while let Some(c) = self.advance() {
                    if c == '\n' {
                        break;
                    }
                }
            } else {
                break;
            }
        }
    }

    // ------------------------------------------------------------------
    // value parsers
    // ------------------------------------------------------------------

    /// Parse any Typst value and return it as a JSON value.
    fn parse_value(&mut self) -> Result<Value, String> {
        self.skip_whitespace_and_comments();
        match self.peek() {
            Some('"') => self.parse_string().map(Value::String),
            Some('(') => self.parse_parens(),
            Some('[') => self.parse_content_block().map(Value::String),
            Some('n') => {
                self.parse_ident().and_then(|id| {
                    if id == "none" {
                        Ok(Value::Null)
                    } else {
                        Err(format!("Unexpected identifier: {}", id))
                    }
                })
            }
            Some('t') => {
                self.parse_ident().and_then(|id| {
                    if id == "true" {
                        Ok(Value::Bool(true))
                    } else {
                        Err(format!("Unexpected identifier: {}", id))
                    }
                })
            }
            Some('f') => {
                self.parse_ident().and_then(|id| {
                    if id == "false" {
                        Ok(Value::Bool(false))
                    } else {
                        Err(format!("Unexpected identifier: {}", id))
                    }
                })
            }
            Some('d') => {
                // Could be "datetime(…)" or a regular identifier
                let save = self.pos;
                let ident = self.parse_ident()?;
                self.skip_whitespace_and_comments();
                if ident == "datetime" && self.peek() == Some('(') {
                    self.parse_datetime()
                } else {
                    // Not datetime — rewind and treat as regular ident
                    self.pos = save;
                    Err("Expected a value".into())
                }
            }
            Some(c) if c.is_ascii_digit() || c == '-' => self.parse_number(),
            Some(c) => Err(format!("Unexpected character '{}' at pos {}", c, self.pos)),
            None => Err("Unexpected end of input".into()),
        }
    }

    /// Parse a double-quoted string with escape sequences.
    fn parse_string(&mut self) -> Result<String, String> {
        match self.advance() {
            Some('"') => {}
            c => return Err(format!("Expected '\"', got {:?}", c)),
        }
        let mut s = String::new();
        loop {
            match self.advance() {
                Some('"') => break,
                Some('\\') => match self.advance() {
                    Some('"') => s.push('"'),
                    Some('\\') => s.push('\\'),
                    Some('n') => s.push('\n'),
                    Some('t') => s.push('\t'),
                    Some('r') => s.push('\r'),
                    Some(c) => {
                        s.push('\\');
                        s.push(c);
                    }
                    None => return Err("Unterminated escape sequence".into()),
                },
                Some(c) => s.push(c),
                None => return Err("Unterminated string literal".into()),
            }
        }
        Ok(s)
    }

    /// Parse `(…)` — either an array or a dict depending on presence of `:`.
    fn parse_parens(&mut self) -> Result<Value, String> {
        self.advance(); // consume '('
        self.skip_whitespace_and_comments();

        // Empty parens → empty array
        if self.peek() == Some(')') {
            self.advance();
            return Ok(Value::Array(Vec::new()));
        }

        // Peek ahead to determine if this is a dict (has `key:` pattern) or array
        let is_dict = Self::looks_like_dict(&self.chars, self.pos);

        if is_dict {
            let mut map = HashMap::new();
            loop {
                self.skip_whitespace_and_comments();
                if self.peek() == Some(')') {
                    self.advance();
                    break;
                }
                let key = self.parse_ident()?;
                self.skip_whitespace_and_comments();
                if self.peek() != Some(':') {
                    return Err(format!("Expected ':' after key '{}', got {:?}", key, self.peek()));
                }
                self.advance(); // consume ':'
                self.skip_whitespace_and_comments();
                let val = self.parse_value()?;
                map.insert(key, val);
                self.skip_whitespace_and_comments();
                if self.peek() == Some(',') {
                    self.advance();
                } else if self.peek() == Some(')') {
                    self.advance();
                    break;
                } else {
                    return Err(format!(
                        "Expected ',' or ')' in dict, got {:?}",
                        self.peek()
                    ));
                }
            }
            Ok(Value::Object(map.into_iter().collect()))
        } else {
            let mut arr = Vec::new();
            loop {
                self.skip_whitespace_and_comments();
                if self.peek() == Some(')') {
                    self.advance();
                    break;
                }
                let val = self.parse_value()?;
                arr.push(val);
                self.skip_whitespace_and_comments();
                if self.peek() == Some(',') {
                    self.advance();
                } else if self.peek() == Some(')') {
                    self.advance();
                    break;
                } else {
                    return Err(format!(
                        "Expected ',' or ')' in array, got {:?}",
                        self.peek()
                    ));
                }
            }
            Ok(Value::Array(arr))
        }
    }

    /// Peek ahead to guess whether `(…)` is a dict (has unquoted `key:`).
    fn looks_like_dict(chars: &[char], start: usize) -> bool {
        let mut depth = 0;
        let mut i = start;
        while i < chars.len() {
            match chars[i] {
                '(' | '[' => {
                    depth += 1;
                    i += 1;
                }
                ')' | ']' => {
                    if depth == 0 {
                        return false;
                    }
                    depth -= 1;
                    i += 1;
                }
                '"' => {
                    // Skip string
                    i += 1;
                    while i < chars.len() {
                        if chars[i] == '\\' {
                            i += 2;
                        } else if chars[i] == '"' {
                            i += 1;
                            break;
                        } else {
                            i += 1;
                        }
                    }
                }
                ':' if depth == 0 && i > start => {
                    // Check that the thing before ':' looks like an ident key
                    let mut j = i;
                    while j > start {
                        j -= 1;
                        let c = chars[j];
                        if c.is_whitespace() || c == ',' || c == '(' {
                            j += 1;
                            break;
                        }
                    }
                    // j is at start of potential key
                    if j < i && chars[j].is_ascii_alphabetic() {
                        return true;
                    }
                    i += 1;
                }
                _ => {
                    i += 1;
                }
            }
        }
        false
    }

    /// Parse a content block `[…]` — return the raw text between brackets.
    fn parse_content_block(&mut self) -> Result<String, String> {
        self.advance(); // consume '['
        let mut depth = 1;
        let mut s = String::new();
        while depth > 0 {
            match self.advance() {
                Some('[') => {
                    depth += 1;
                    s.push('[');
                }
                Some(']') => {
                    depth -= 1;
                    if depth > 0 {
                        s.push(']');
                    }
                }
                Some('\\') => {
                    s.push('\\');
                    if let Some(c) = self.advance() {
                        s.push(c);
                    }
                }
                Some(c) => s.push(c),
                None => return Err("Unterminated content block".into()),
            }
        }
        Ok(s.trim().to_string())
    }

    /// Parse a `datetime(year: Y, month: M, day: D)` call → JSON object.
    fn parse_datetime(&mut self) -> Result<Value, String> {
        // We already consumed "datetime" and peeked '('
        self.advance(); // consume '('
        let mut year: Option<i64> = None;
        let mut month: Option<i64> = None;
        let mut day: Option<i64> = None;
        let mut hour: Option<i64> = None;
        let mut minute: Option<i64> = None;

        loop {
            self.skip_whitespace_and_comments();
            if self.peek() == Some(')') {
                self.advance();
                break;
            }
            let key = self.parse_ident()?;
            self.skip_whitespace_and_comments();
            if self.peek() != Some(':') {
                return Err(format!("Expected ':' in datetime args, got {:?}", self.peek()));
            }
            self.advance();
            self.skip_whitespace_and_comments();

            // Parse the numeric value
            let val = self.parse_number()?;
            let num = val.as_i64().unwrap_or(0);

            match key.as_str() {
                "year" => year = Some(num),
                "month" => month = Some(num),
                "day" => day = Some(num),
                "hour" => hour = Some(num),
                "minute" => minute = Some(num),
                _ => {}
            }

            self.skip_whitespace_and_comments();
            if self.peek() == Some(',') {
                self.advance();
            } else if self.peek() == Some(')') {
                self.advance();
                break;
            } else {
                return Err(format!(
                    "Expected ',' or ')' in datetime, got {:?}",
                    self.peek()
                ));
            }
        }

        let mut map = serde_json::Map::new();
        if let Some(y) = year {
            map.insert("year".into(), Value::Number(y.into()));
        }
        if let Some(m) = month {
            map.insert("month".into(), Value::Number(m.into()));
        }
        if let Some(d) = day {
            map.insert("day".into(), Value::Number(d.into()));
        }
        if let Some(h) = hour {
            map.insert("hour".into(), Value::Number(h.into()));
        }
        if let Some(min) = minute {
            map.insert("minute".into(), Value::Number(min.into()));
        }
        Ok(Value::Object(map))
    }

    /// Parse a bare identifier (alphanumeric + underscores + hyphens).
    fn parse_ident(&mut self) -> Result<String, String> {
        self.skip_whitespace_and_comments();
        let mut s = String::new();
        while let Some(c) = self.peek() {
            if c.is_alphanumeric() || c == '_' || c == '-' {
                s.push(c);
                self.advance();
            } else {
                break;
            }
        }
        if s.is_empty() {
            Err(format!(
                "Expected identifier, got {:?} at pos {}",
                self.peek(),
                self.pos
            ))
        } else {
            Ok(s)
        }
    }

    /// Parse a numeric literal (integer or float).
    fn parse_number(&mut self) -> Result<Value, String> {
        self.skip_whitespace_and_comments();
        let mut s = String::new();
        let mut is_float = false;
        let mut is_negative = false;

        if self.peek() == Some('-') {
            s.push('-');
            self.advance();
            is_negative = true;
        }

        while let Some(c) = self.peek() {
            if c.is_ascii_digit() {
                s.push(c);
                self.advance();
            } else if c == '.' && !is_float {
                is_float = true;
                s.push(c);
                self.advance();
            } else {
                break;
            }
        }

        if s.is_empty() || (is_negative && s.len() == 1) {
            return Err(format!("Expected number, got {:?}", self.peek()));
        }

        if is_float {
            s.parse::<f64>()
                .map(|n| Value::Number(serde_json::Number::from_f64(n).unwrap()))
                .map_err(|e| format!("Invalid float '{}': {}", s, e))
        } else {
            s.parse::<i64>()
                .map(|n| Value::Number(n.into()))
                .map_err(|e| format!("Invalid integer '{}': {}", s, e))
        }
    }

    // ------------------------------------------------------------------
    // argument list parser
    // ------------------------------------------------------------------

    /// Parse `key: value, …` named arguments inside the meta call.
    fn parse_named_args(&mut self) -> Result<HashMap<String, Value>, String> {
        let mut fields = HashMap::new();

        self.skip_whitespace_and_comments();
        if self.peek() == Some(')') {
            self.advance();
            return Ok(fields);
        }

        loop {
            self.skip_whitespace_and_comments();
            if self.peek() == Some(')') {
                self.advance();
                break;
            }

            let key = self.parse_ident()?;
            self.skip_whitespace_and_comments();

            if self.peek() != Some(':') {
                return Err(format!(
                    "Expected ':' after '{}' in meta args, got {:?}",
                    key,
                    self.peek()
                ));
            }
            self.advance(); // consume ':'

            let val = self.parse_value()?;
            fields.insert(key, val);

            self.skip_whitespace_and_comments();
            if self.peek() == Some(',') {
                self.advance();
            } else if self.peek() == Some(')') {
                self.advance();
                break;
            } else if self.peek().is_none() {
                break; // tolerate missing closing paren
            } else {
                return Err(format!(
                    "Expected ',' or ')' in meta args, got {:?} at pos {}",
                    self.peek(),
                    self.pos
                ));
            }
        }

        Ok(fields)
    }
}

// ---------------------------------------------------------------------------
// tests
// ---------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_simple_meta() {
        let src = r##"
#import "lib.typ": meta
#meta(
  title: "Hello World",
  author: "Alice",
  date: datetime(year: 2024, month: 5, day: 20),
  id: "hello-world",
  category: "blog",
)
"##;
        let fields = parse_meta_call(src).expect("should parse");
        assert_eq!(fields.get("title").unwrap(), "Hello World");
        assert_eq!(fields.get("author").unwrap(), "Alice");
        assert_eq!(fields.get("id").unwrap(), "hello-world");
        assert_eq!(fields.get("category").unwrap(), "blog");
        let date = fields.get("date").unwrap().as_object().unwrap();
        assert_eq!(date.get("year").unwrap().as_i64().unwrap(), 2024);
        assert_eq!(date.get("month").unwrap().as_i64().unwrap(), 5);
        assert_eq!(date.get("day").unwrap().as_i64().unwrap(), 20);
    }

    #[test]
    fn test_parse_array_author() {
        let src = r##"
#meta(
  title: "Test",
  author: ("Alice", "Bob"),
  id: "test",
  date: datetime(year: 2024, month: 1, day: 1),
)
"##;
        let fields = parse_meta_call(src).expect("should parse");
        let authors = fields.get("author").unwrap().as_array().unwrap();
        assert_eq!(authors.len(), 2);
        assert_eq!(authors[0], "Alice");
        assert_eq!(authors[1], "Bob");
    }

    #[test]
    fn test_parse_tags_and_keywords() {
        let src = r##"
#meta(
  title: "Tagged",
  author: "Alice",
  date: datetime(year: 2024, month: 1, day: 1),
  id: "tagged",
  tag: ("rust", "typst"),
  keywords: ("ssg", "web"),
)
"##;
        let fields = parse_meta_call(src).expect("should parse");
        let tags: Vec<_> = fields
            .get("tag")
            .unwrap()
            .as_array()
            .unwrap()
            .iter()
            .map(|v| v.as_str().unwrap().to_string())
            .collect();
        assert_eq!(tags, vec!["rust", "typst"]);
    }

    #[test]
    fn test_parse_with_tbl() {
        let src = r##"
#meta(
  title: "With Extra",
  author: "Alice",
  id: "extra-test",
  date: datetime(year: 2024, month: 6, day: 15),
  tbl: (
    taxon: "Theorem",
    series: "Math Notes",
  ),
)
"##;
        let fields = parse_meta_call(src).expect("should parse");
        let tbl = fields.get("tbl").unwrap().as_object().unwrap();
        assert_eq!(tbl.get("taxon").unwrap(), "Theorem");
        assert_eq!(tbl.get("series").unwrap(), "Math Notes");
    }

    #[test]
    fn test_no_meta_returns_none() {
        let src = "= Just a heading\nNo meta here.";
        assert!(parse_meta_call(src).is_none());
    }

    #[test]
    fn test_parse_content_abstract() {
        let src = r##"
#meta(
  title: "Abstract Test",
  author: "Alice",
  id: "abstract-test",
  date: datetime(year: 2024, month: 1, day: 1),
  abstract: [This is an *abstract* with **markup**.],
)
"##;
        let fields = parse_meta_call(src).expect("should parse");
        let abs = fields.get("abstract").unwrap().as_str().unwrap();
        assert!(abs.contains("abstract"));
    }
}

    #[test]
    fn test_meta_not_at_beginning() {
        let src = r##"
= Heading First

Some introductory text.

#meta(
  title: "After Content",
  author: ("Bob",),
  date: datetime(year: 2025, month: 6, day: 1),
  id: "after-content",
)
"##;
        let fields = parse_meta_call(src).expect("should find meta even mid-file");
        assert_eq!(fields.get("title").unwrap(), "After Content");
        assert_eq!(fields.get("id").unwrap(), "after-content");
    }
