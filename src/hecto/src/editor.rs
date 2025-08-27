use crate::Buffer;
use crate::INIT_EXPT;
use crate::Terminal;
use crate::exp::EXIT_EXPT;
use crossterm::event::KeyCode;
use crossterm::event::KeyEvent;

const VERSION: &str = env!("CARGO_PKG_VERSION");

#[derive(Default)]
pub struct Editor {
    quit: bool,
    term: Terminal,
    buf: Buffer,
}

impl Editor {
    pub fn new() -> Result<Self, std::io::Error> {
        Ok(Editor {
            quit: false,
            term: Terminal::new()?,
            buf: Buffer::default(),
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
                self.term.prev(1)?;
                self.buf.prev(1)?;
            }
            KeyCode::Down => {
                self.term.next(1)?;
                self.buf.next(1)?;
            }
            KeyCode::Left => {
                self.term.back(1)?;
                self.buf.back(1)?;
            }
            KeyCode::Right => {
                self.term.forward(1)?;
                self.buf.forward(1)?;
            }
            KeyCode::PageUp => {
                self.term.prev((self.term.height()? as usize).div_ceil(2))?;
                self.buf.prev((self.term.height()? as usize).div_ceil(2))?;
            }
            KeyCode::PageDown => {
                self.term.next((self.term.height()? as usize).div_ceil(2))?;
                self.buf.next((self.term.height()? as usize).div_ceil(2))?;
            }
            KeyCode::Home => {
                self.term.bol()?;
                self.buf.bol()?;
            }
            KeyCode::End => {
                self.term.eol()?;
                self.buf.eol()?;
            }
            _ => (),
        }
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
        if self.quit {
            self.term.goto(1, 1)?;
            println!("quit!\r");
        } else {
            self.lines()?;
            self.term.hide()?;
        }
        self.term.refresh()?.show()?;
        Ok(())
    }

    fn lines(&mut self) -> Result<(), std::io::Error> {
        print!("\r");
        let height = self.term.height().unwrap();
        for row in 0..height - 1 {
            self.term.clear_line()?;
            if row == height / 3 {
                self.wlcome_msg();
            } else {
                println!("~\r");
            }
        }
        Ok(())
    }

    fn die(&mut self, e: impl std::error::Error) {
        self.term.clear().unwrap();
        panic!("{}", e);
    }
}
