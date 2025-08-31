use std::io::{Write, stdout};

use crate::Cursor;
use crossterm::event::{self, Event, KeyEvent};
use crossterm::execute;
use crossterm::terminal::{
    Clear, EnterAlternateScreen, LeaveAlternateScreen, disable_raw_mode, enable_raw_mode,
};

#[derive(Debug, Default)]
pub struct Size {
    width: u16,
    height: u16,
}

impl Size {
    pub fn width(&self) -> u16 {
        self.width
    }
    pub fn height(&self) -> u16 {
        self.height
    }
}

#[derive(Debug)]
pub struct Terminal {
    stdout: std::io::Stdout,
    cur: Cursor,
    size: Size,
}

impl Default for Terminal {
    fn default() -> Self {
        Self {
            stdout: stdout(),
            cur: Cursor::default(),
            size: Size::default(),
        }
    }
}

impl Terminal {
    pub fn new() -> Result<Self, std::io::Error> {
        let size = crossterm::terminal::size()?;
        Ok(Self {
            stdout: stdout(),
            cur: Cursor::default(),
            size: Size {
                width: size.0,
                height: size.1,
            },
        })
    }
}

impl Terminal {
    pub fn x(&self) -> usize {
        self.cur.x()
    }

    pub fn y(&self) -> usize {
        self.cur.y()
    }
}

impl Terminal {
    pub fn init(&mut self) -> Result<&mut Self, std::io::Error> {
        enable_raw_mode()?;
        execute!(self.stdout, EnterAlternateScreen)?;
        Ok(self)
    }

    pub fn exit(&mut self) -> Result<&mut Self, std::io::Error> {
        execute!(self.stdout, LeaveAlternateScreen)?;
        disable_raw_mode()?;
        Ok(self)
    }
}

impl Terminal {
    pub fn read() -> Result<KeyEvent, std::io::Error> {
        loop {
            if let Event::Key(key) = event::read()? {
                return Ok(key);
            }
        }
    }
}

impl Terminal {
    pub fn hide(&mut self) -> Result<&mut Self, std::io::Error> {
        execute!(self.stdout, crossterm::cursor::Hide)?;
        Ok(self)
    }

    pub fn show(&mut self) -> Result<&mut Self, std::io::Error> {
        execute!(self.stdout, crossterm::cursor::Show)?;
        Ok(self)
    }
}

impl Terminal {
    pub fn size(&mut self) -> Result<&Size, std::io::Error> {
        let size = crossterm::terminal::size()?;
        self.size = Size {
            width: size.0,
            height: size.1,
        };
        Ok(&self.size)
    }

    pub fn width(&self) -> Result<u16, std::io::Error> {
        Ok(self.size.width)
    }

    pub fn height(&self) -> Result<u16, std::io::Error> {
        Ok(self.size.height)
    }
}

impl Terminal {
    pub fn goto(&mut self, x: u16, y: u16) -> Result<&mut Self, std::io::Error> {
        // TODO: overflow
        self.cur.goto(x as usize, y as usize);
        Ok(self)
    }

    pub fn forward(&mut self, step: usize) -> Result<&mut Self, std::io::Error> {
        let mut new_x = self.x().saturating_add(step);
        if new_x >= self.width()? as usize {
            new_x = self.width()? as usize - 1;
        }
        self.cur.goto(new_x, self.y());
        Ok(self)
    }

    pub fn back(&mut self, step: usize) -> Result<&mut Self, std::io::Error> {
        let new_x = self.x().saturating_sub(step);
        self.cur.goto(new_x, self.y());
        Ok(self)
    }

    pub fn next(&mut self, step: usize) -> Result<&mut Self, std::io::Error> {
        let mut new_y = self.y().saturating_add(step);
        if new_y >= self.height()? as usize {
            new_y = self.height()? as usize - 1;
        }
        self.cur.goto(self.x(), new_y);
        Ok(self)
    }

    pub fn prev(&mut self, step: usize) -> Result<&mut Self, std::io::Error> {
        let new_y = self.y().saturating_sub(step);
        self.cur.goto(self.x(), new_y);
        Ok(self)
    }

    pub fn begin(&mut self) -> Result<&mut Self, std::io::Error> {
        self.cur.goto(0, 0);
        Ok(self)
    }

    pub fn end(&mut self) -> Result<&mut Self, std::io::Error> {
        self.cur
            .goto(self.width()? as usize, self.height()? as usize);
        Ok(self)
    }

    pub fn bol(&mut self) -> Result<&mut Self, std::io::Error> {
        self.cur.goto(0, self.y());
        Ok(self)
    }

    pub fn eol(&mut self) -> Result<&mut Self, std::io::Error> {
        self.cur.goto(self.width()? as usize, self.y());
        Ok(self)
    }
}

impl Terminal {
    pub fn clear(&mut self) -> Result<&mut Self, std::io::Error> {
        execute!(self.stdout, Clear(crossterm::terminal::ClearType::All))?;
        Ok(self)
    }

    pub fn clear_line(&mut self) -> Result<&mut Self, std::io::Error> {
        execute!(
            self.stdout,
            Clear(crossterm::terminal::ClearType::CurrentLine)
        )?;
        Ok(self)
    }

    pub fn refresh(&mut self) -> Result<&mut Self, std::io::Error> {
        execute!(
            self.stdout,
            crossterm::cursor::MoveTo(self.cur.x() as u16, self.cur.y() as u16)
        )?;
        self.stdout.flush()?;
        Ok(self)
    }
}
