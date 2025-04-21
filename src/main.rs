#![no_std]
#![no_main]

use panic_halt as _;

use cortex_m::peripheral::{syst, Peripherals};
use cortex_m_rt::{entry, exception};
use mec1723n_b0_sz;

const SYSTICK_PERIOD: u32 = 96_000_000;

fn initialize_systick() {
    let cp = unsafe { Peripherals::steal() };
    let mut systick = cp.SYST;

    systick.set_clock_source(syst::SystClkSource::Core);
    systick.set_reload(SYSTICK_PERIOD);
    systick.clear_current();
    systick.enable_counter();
    systick.enable_interrupt();
}

#[entry]
fn main() -> ! {

    // Globally enable interrupts.
    unsafe {cortex_m::interrupt::enable();}

    // Set the vector table address (aligned to link.x layout).
    unsafe {
        let peripherals = Peripherals::steal();
        peripherals.SCB.vtor.write(0xc0000);
    }

    // Turn LED2 (GPIO 153) on.
    let g = unsafe {mec1723n_b0_sz::Gpio::steal()};
    g.ctrl15(3).write(|w| unsafe {w.bits(0x0000_8200)});

    // Initialize systick timer.
    initialize_systick();

    loop {}
}

#[exception]
fn SysTick() {
    let g = unsafe {mec1723n_b0_sz::Gpio::steal()};
    // Toggle LED2 (GPIO 153).
    let current_val = g.ctrl15(3).read().alt_gpio_data().bit_is_set();
    g.ctrl15(3).modify(|_r, w| w.alt_gpio_data().bit(!current_val));
}
