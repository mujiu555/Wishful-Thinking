#[derive(Debug)]
struct Pos {
    x: usize,
    y: usize,
}

#[derive(Debug)]
pub struct Cursor {
    pos: Pos,
}

impl Default for Cursor {
    fn default() -> Self {
        Self {
            pos: Pos { x: 0, y: 0 },
        }
    }
}

impl Cursor {
    pub fn x(&self) -> usize {
        self.pos.x
    }

    pub fn y(&self) -> usize {
        self.pos.y
    }
}

impl Cursor {
    pub fn goto(&mut self, x: usize, y: usize) {
        self.pos.x = x;
        self.pos.y = y;
    }

    pub fn mv(&mut self, x: isize, y: isize) {
        self.pos.x = (self.pos.x as isize + x) as usize;
        self.pos.y = (self.pos.y as isize + y) as usize;
    }
}
