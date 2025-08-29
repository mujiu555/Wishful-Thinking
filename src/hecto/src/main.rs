mod buffer;
mod cursor;
mod editor;
mod exp;
mod terminal;
pub use buffer::Buffer;
pub use cursor::Cursor;
pub use editor::Editor;
pub use exp::EXIT_EXPT;
pub use exp::INIT_EXPT;
pub use terminal::Terminal;

fn main() {
    editor::Editor::new().unwrap().run();
}
