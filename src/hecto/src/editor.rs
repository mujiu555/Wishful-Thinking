use crate::Buffer;
use crate::Cursor;
use crate::EXIT_EXPT;
use crate::INIT_EXPT;
use crate::Row;
use crate::Terminal;
use crossterm::event::KeyCode;
use crossterm::event::KeyEvent;
use std::env;

const VERSION: &str = env!("CARGO_PKG_VERSION");

#[derive(Default)]
pub struct Editor {
    init: bool,
    quit: bool,
    term: Terminal,
    buf: Buffer,
    offset: Cursor,
}

impl Editor {
    pub fn new() -> Result<Self, std::io::Error> {
        let args: Vec<String> = env::args().collect();
        let buf = if args.len() > 1 {
            Buffer::open(&args[1]).unwrap_or_default()
        } else {
            Buffer::default()
        };
        Ok(Editor {
            init: true,
            quit: false,
            term: Terminal::new()?,
            buf,
            offset: Cursor::default(),
        })
    }
}

impl Editor {
    pub fn run(&mut self) {
        self.term.init().expect(INIT_EXPT);
        loop {
            if let Err(e) = self.refresh() {
                self.die(e);
            }
            if self.quit {
                break;
            }
            if let Err(e) = self.process_keypress() {
                self.die(e);
            }
        }
        self.term.exit().expect(EXIT_EXPT);
    }

    fn process_keypress(&mut self) -> Result<(), std::io::Error> {
        let key = Terminal::read()?;
        let KeyEvent {
            code,
            modifiers: _modifiers,
            kind: _kind,
            state: _state,
        } = key;
        match code {
            KeyCode::Esc => self.quit = true,
            KeyCode::Up
            | KeyCode::Down
            | KeyCode::Right
            | KeyCode::Left
            | KeyCode::PageUp
            | KeyCode::PageDown
            | KeyCode::End
            | KeyCode::Home => self.cursor(key)?,
            _ => (),
        }
        Ok(())
    }

    fn cursor(&mut self, key: KeyEvent) -> Result<(), std::io::Error> {
        let KeyEvent {
            code,
            modifiers: _modifiers,
            kind: _kind,
            state: _state,
        } = key;
        match code {
            KeyCode::Up => {
                self.buf.prev(1)?;
                self.term.prev(1)?;
            }
            KeyCode::Down => {
                self.buf.next(1)?;
                if self.term.y().saturating_add(1) <= self.buf.len() {
                    self.term.next(1)?;
                }
            }
            KeyCode::Left => {
                self.buf.back(1)?;
                self.term.back(1)?;
            }
            KeyCode::Right => {
                self.buf.forward(1)?;
                if self.term.x().saturating_add(1) <= self.buf.broad() {
                    self.term.forward(1)?;
                }
            }
            KeyCode::PageUp => {
                self.buf.prev((self.term.height()? as usize).div_ceil(2))?;
                self.term.prev((self.term.height()? as usize).div_ceil(2))?;
            }
            KeyCode::PageDown => {
                self.buf.next((self.term.height()? as usize).div_ceil(2))?;
                self.term.next((self.term.height()? as usize).div_ceil(2))?;
            }
            KeyCode::Home => {
                self.buf.bol()?;
                self.term.bol()?;
            }
            KeyCode::End => {
                self.buf.eol()?;
                self.term.eol()?;
            }
            _ => (),
        }
        self.scroll()?;
        Ok(())
    }

    fn wlcome_msg(&mut self) {
        let wlcome_msg = format!("version -- {VERSION}");
        let w = self.term.width().unwrap() as usize;
        let len = wlcome_msg.len();
        let padding = w.saturating_sub(len) / 2;
        let spaces = " ".repeat(padding.saturating_sub(1));
        let mut wlcome_msg = format!("{spaces}{wlcome_msg}");
        wlcome_msg.truncate(w);
        println!("~{wlcome_msg}\r",);
    }

    fn refresh(&mut self) -> Result<(), std::io::Error> {
        print!("\r");
        if self.quit {
            self.term.goto(1, 1)?;
            println!("quit!\r");
        } else {
            self.rows()?;
            self.term.hide()?;
        }
        self.term.refresh()?.show()?;
        Ok(())
    }

    fn row(&self, row: &Row) -> Result<(), std::io::Error> {
        let start = self.offset.x();
        let width = self.term.width()? as usize;
        let end = width + self.offset.x();
        let row = row.render(start, end);
        println!("{}\r", row);
        Ok(())
    }

    fn rows(&mut self) -> Result<(), std::io::Error> {
        let height = self.term.height()?;
        for term_row_i in 0..height - 1 {
            self.term.clear_line()?;
            if let Some(row) = self.buf.row(term_row_i as usize + self.offset.y()) {
                self.row(row)?;
            } else if (term_row_i == height / 3) && self.init && self.buf.is_empty() {
                self.wlcome_msg();
            } else {
                println!("~\r");
            }
        }
        Ok(())
    }

    fn scroll(&mut self) -> Result<(), std::io::Error> {
        let x = self.buf.x();
        let y = self.buf.y();
        let width = self.term.width()? as usize;
        let height = self.term.height()? as usize;

        let offest = &mut self.offset;
        if y < offest.y() {
            offest.goto(offest.x(), y);
        } else if y >= offest.y().saturating_add(height) {
            offest.goto(offest.x(), y.saturating_sub(height).saturating_add(1));
        }

        if x < offest.x() {
            offest.goto(x, offest.y());
        } else if x >= offest.x().saturating_add(width) {
            offest.goto(x.saturating_sub(width).saturating_add(1), offest.y());
        }
        Ok(())
    }

    fn die(&mut self, e: impl std::error::Error) {
        self.term.clear().unwrap();
        panic!("{}", e);
    }
}
