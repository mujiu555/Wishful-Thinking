use std::io::stdout;

use crate::Cursor;
use crossterm::event::{self, Event, KeyEvent};
use crossterm::terminal::{
    Clear, EnterAlternateScreen, LeaveAlternateScreen, disable_raw_mode, enable_raw_mode,
};
use crossterm::{ExecutableCommand, execute};

#[derive(Debug)]
struct Size {
    width: usize,
    height: usize,
}

#[derive(Debug)]
pub struct Terminal {
    size: Size,
    cursor: Cursor,
}

impl Default for Terminal {
    fn default() -> Self {
        Self {
            size: Size {
                width: 1,
                height: 1,
            },
            cursor: Cursor::default(),
        }
    }
}

impl Terminal {
    pub fn init() -> Result<(), std::io::Error> {
        enable_raw_mode()?;
        execute!(stdout(), EnterAlternateScreen)?;
        Ok(())
    }

    pub fn exit() -> Result<(), std::io::Error> {
        execute!(stdout(), LeaveAlternateScreen)?;
        disable_raw_mode()?;
        Ok(())
    }

    pub fn read() -> Result<KeyEvent, std::io::Error> {
        loop {
            if let Event::Key(key) = event::read()? {
                return Ok(key);
            }
        }
    }

    pub fn clear() -> Result<(), std::io::Error> {
        stdout().execute(Clear(crossterm::terminal::ClearType::All))?;
        Ok(())
    }
}
