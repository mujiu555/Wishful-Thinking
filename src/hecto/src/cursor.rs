use std::io::{self, Write, stdin, stdout};
use termion::{event::Key, input::TermRead, raw::IntoRawMode, raw::RawTerminal};

struct Pos {
    x: usize,
    y: usize,
}

pub struct Cursor {
    pos: Pos,
}

impl Cursor {
    pub fn new() -> Self {
        Self {
            pos: Pos { x: 0, y: 0 },
        }
    }
    pub fn pos(x: u16, y: u16) {
        let x = x.saturating_add(1);
        let y = y.saturating_add(1);
        print!("{}", termion::cursor::Goto(x, y));
    }

    pub fn hide() {
        print!("{}", termion::cursor::Hide);
    }

    pub fn show() {
        print!("{}", termion::cursor::Show);
    }
}
