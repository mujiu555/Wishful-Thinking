#![no_std]
#![no_main]

use cortex_m_rt::entry;
use panic_halt as _;
use stm32f1xx_hal as hal;

use crate::hal::{pac, prelude::*, rcc};

#[entry]
fn main() -> ! {
  let dp = pac::Peripherals::take().unwrap();

  let mut flash = dp.FLASH.constrain();

  // Clocks: externer 8 MHz Quarz -> 48 MHz SYSCLK
  let mut rcc = dp
    .RCC
    .freeze(rcc::Config::hse(8.MHz()).sysclk(48.MHz()), &mut flash.acr);

  let mut gpioa = dp.GPIOA.split(&mut rcc);
  let mut p1 = gpioa.pa1.into_push_pull_output(&mut gpioa.crl);

  let mut delay = dp.TIM2.delay_us(&mut rcc);

  loop {}
}
