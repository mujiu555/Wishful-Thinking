use crate::Cursor;
use crate::Terminal;
use std::io::{Write, stdout};
use termion::event::Key;

const VERSION: &str = env!("CARGO_PKG_VERSION");

pub struct Editor {
    quit: bool,
    term: Terminal,
    cur: Cursor,
}

impl Editor {
    pub fn run(&mut self) {
        loop {
            if let Err(e) = self.refresh() {
                die(e);
            }
            if self.quit {
                break;
            }
            if let Err(e) = self.process_keypress() {
                die(e);
            }
        }
    }

    pub fn new() -> Self {
        Self {
            quit: false,
            term: Terminal::new().expect("Failed to initialize terminal"),
            cur: Cursor::new(),
        }
    }

    fn process_keypress(&mut self) -> Result<(), std::io::Error> {
        let key = Terminal::read()?;
        match key {
            Key::Esc => self.quit = true,
            // TODO:
            Key::Up => self.quit = false,
            _ => (),
        }
        Ok(())
    }

    fn wlcome_msg() {
        let wlcome_msg = format!("version -- {VERSION}");
        let w = Terminal::size().unwrap().width as usize;
        let len = wlcome_msg.len();
        let padding = w.saturating_sub(len) / 2;
        let spaces = " ".repeat(padding.saturating_sub(1));
        let mut wlcome_msg = format!("{spaces}{wlcome_msg}");
        wlcome_msg.truncate(w);
        println!("~{wlcome_msg}\r",);
    }

    fn refresh(&self) -> Result<(), std::io::Error> {
        Cursor::pos(0, 0);
        if self.quit {
            Cursor::pos(0, 0);
            println!("quit!");
        } else {
            Self::lines();
            Cursor::pos(0, 0);
        }
        stdout().flush()
    }

    fn lines() {
        let h = Terminal::size().unwrap().height;
        for row in 0..h - 1 {
            Terminal::clear_line();
            if row == h / 3 {
                Self::wlcome_msg();
            } else {
                println!("~\r");
            }
        }
    }
}

fn die(e: impl std::error::Error) {
    Terminal::clear();
    panic!("{}", e);
}
