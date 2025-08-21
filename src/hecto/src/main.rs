use std::io::{stdin, stdout};
use termion::{event::Key, input::TermRead, raw::IntoRawMode};

fn die(e: impl std::error::Error) {
    panic!("{}", e);
}

fn main() {
    let _stdout = stdout().into_raw_mode().unwrap();
    for k in stdin().keys() {
        match k {
            Ok(k) => match k {
                Key::Char(c) => println!("{:?} ({:?}) \r", c as u8, c),
                Key::Ctrl('q') => break,
                Key::Ctrl(c) => println!("{:?} (Ctrl: '{}')\r", c as u8, c),
                _ => println!("{:?}\r", k),
            },
            Err(e) => die(e),
        }
    }
}
