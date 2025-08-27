use crate::Cursor;

#[derive(Debug, Default)]
pub struct Buffer {
    cur: Cursor,
}

impl Buffer {
    pub fn x(&self) -> usize {
        self.cur.x()
    }
    pub fn y(&self) -> usize {
        self.cur.y()
    }
}

impl Buffer {
    pub fn goto(&mut self, x: u16, y: u16) -> Result<&mut Self, std::io::Error> {
        // TODO: overflow
        self.cur.goto(x as usize, y as usize);
        Ok(self)
    }

    pub fn forward(&mut self, step: usize) -> Result<&mut Self, std::io::Error> {
        let new_x = self.x().saturating_add(step);
        self.cur.goto(new_x, self.y());
        Ok(self)
    }

    pub fn back(&mut self, step: usize) -> Result<&mut Self, std::io::Error> {
        let new_x = self.x().saturating_sub(step);
        self.cur.goto(new_x, self.y());
        Ok(self)
    }

    pub fn next(&mut self, step: usize) -> Result<&mut Self, std::io::Error> {
        let new_y = self.y().saturating_add(step);
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
