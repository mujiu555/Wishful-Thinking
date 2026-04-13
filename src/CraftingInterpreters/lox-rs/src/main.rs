use std::{error::Error, fmt::Display, io::Read};

#[derive(Debug)]
struct ParseError {}

impl Display for ParseError {
  fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {}
}

fn error_report(msg: &str, wh: &str, line: usize, offset: usize) {
  eprintln!("Error: {}", msg);
  eprintln!("{:4} | {}", line, wh);
  eprintln!("       {:>width$}^", "", width = offset);
}

struct Lox {
  has_error: bool,
}

impl Lox {
  fn run(src: &str) {
    // scanning
    todo!()
  }

  fn run_file(&self, path: &str) -> Result<(), Box<dyn std::error::Error>> {
    let mut input = std::fs::File::open(path)?;
    let mut buffer = String::new();
    input
      .read_to_string(&mut buffer)
      .expect("Failed to read line");
    Self::run(buffer.as_str());
    if self.has_error {
      Err(Box::new(ParseError {}))
    } else {
      Ok(())
    }
  }

  fn run_prompt() {
    use std::io::{self, Write};
    let mut input = String::new();
    loop {
      print!("> ");
      io::stdout().flush().unwrap();
      input.clear();
      match io::stdin().read_line(&mut input) {
        Err(e) => eprintln!("Error reading input: {}", e),
        Ok(0) => break,
        Ok(_) => (),
      }
      Self::run(input.as_str());
      input.clear();
    }
  }
}

fn main() {
  Lox::run_prompt();
}
