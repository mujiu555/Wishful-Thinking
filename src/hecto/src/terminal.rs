use std::io::{Write, stdin, stdout};
use termion::{event::Key, input::TermRead, raw::IntoRawMode, raw::RawTerminal};

pub struct Size {
    pub width: u16,
    pub height: u16,
}

pub struct Terminal {
    _stdout: RawTerminal<std::io::Stdout>,
}

impl Terminal {
    /// # Errors
    pub fn new() -> Result<Self, std::io::Error> {
        Ok(Self {
            _stdout: stdout().into_raw_mode()?,
        })
    }

    #[must_use]
    pub fn size() -> Result<Size, std::io::Error> {
        let size = termion::terminal_size()?;
        Ok(Size {
            width: size.0,
            height: size.1,
        })
    }

    pub fn clear() {
        print!("{}", termion::clear::All);
    }

    pub fn clear_line() {
        print!("{}", termion::clear::CurrentLine);
    }

    /// # Errors
    pub fn flush() -> Result<(), std::io::Error> {
        stdout().flush()
    }

    /// # Errors
    pub fn read() -> Result<Key, std::io::Error> {
        loop {
            if let Some(k) = stdin().lock().keys().next() {
                return k;
            }
        }
    }
}
