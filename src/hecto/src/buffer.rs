use crate::Cursor;
use crate::Row;
use std::fs;

#[derive(Debug, Default)]
pub struct Buffer {
    cur: Cursor,
    rows: Vec<Row>,
}

impl Buffer {
    pub fn open(fp: &str) -> Result<Self, std::io::Error> {
        let contents = fs::read_to_string(fp)?;
        Ok(Self {
            cur: Cursor::default(),
            rows: contents.lines().map(Row::from).collect(),
        })
    }
}

impl Buffer {
    pub fn x(&self) -> usize {
        self.cur.x()
    }
    pub fn y(&self) -> usize {
        self.cur.y()
    }

    pub fn is_empty(&self) -> bool {
        self.rows.is_empty()
    }

    pub fn len(&self) -> usize {
        self.rows.len()
    }

    pub fn broad(&self) -> usize {
        self.rows[self.y()].len()
    }
}

impl Buffer {
    pub fn goto(&mut self, x: u16, y: u16) -> Result<&mut Self, std::io::Error> {
        // TODO: overflow
        self.cur.goto(x as usize, y as usize);
        Ok(self)
    }

    pub fn forward(&mut self, step: usize) -> Result<&mut Self, std::io::Error> {
        let mut new_x = self.x().saturating_add(step);
        if new_x > self.rows[self.cur.y()].len() {
            new_x = self.rows[self.cur.y()].len();
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
        if new_y > self.rows.len() {
            new_y = self.rows.len();
        }
        let new_x = if self.x() < self.rows[new_y].len() {
            self.x()
        } else {
            self.rows[new_y].len()
        };
        self.cur.goto(new_x, new_y);
        Ok(self)
    }

    pub fn prev(&mut self, step: usize) -> Result<&mut Self, std::io::Error> {
        let new_y = self.y().saturating_sub(step);
        let new_x = if self.x() < self.rows[new_y].len() {
            self.x()
        } else {
            self.rows[new_y].len()
        };
        self.cur.goto(new_x, new_y);
        Ok(self)
    }

    pub fn begin(&mut self) -> Result<&mut Self, std::io::Error> {
        self.cur.goto(0, 0);
        Ok(self)
    }
    pub fn end(&mut self) -> Result<&mut Self, std::io::Error> {
        // TODO:
        self.cur.goto(0, 0);
        Ok(self)
    }

    pub fn bol(&mut self) -> Result<&mut Self, std::io::Error> {
        self.cur.goto(0, self.y());
        Ok(self)
    }

    pub fn eol(&mut self) -> Result<&mut Self, std::io::Error> {
        // TODO:
        self.cur.goto(0, self.y());
        Ok(self)
    }
}

impl Buffer {
    pub fn row(&self, index: usize) -> Option<&Row> {
        self.rows.get(index)
    }
}
