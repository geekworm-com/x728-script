# X728 GPIO & I²C Wiring Guide

Overview
- This document lists the GPIO (BCM) and I²C lines commonly used with X728 family expansion boards and provides guidance for wiring, chip selection when using libgpiod tools, and recommended defaults for different board revisions.
- All GPIO numbers below use BCM (Broadcom) numbering. When using libgpiod or gpioset/gpioget, BCM numbers are used as line offsets on the selected gpiochip.

GPIO lines (BCM)
- BCM 6
	- Role: PLD (Power Loss Detect).
	- Direction: Input.
	- Notes: Reads 1 if A/C power is lost, 0 if A/C power is available.

- BCM 5
	- Role: Shutdown (Sense button press).
	- Direction: Input.
	- Notes: Reads the status of the hardware button. Works only if Boot (BCM 12) is set to 1. When Boot is 1, reads 1 if pressed, 0 if released.

- BCM 12
	- Role: Boot (Control SW/HW controlled button).
	- Direction: Output.
	- Notes: Must be set to 1 to enable reading BCM 5 (Shutdown button).

- BCM 20
	- Role: Buzzer.
	- Direction: Output.
	- Notes: Set to 1 for a loud beep, 0 for off.

- BCM 26
	- Role: Button (Simulate power button press).
	- Direction: Output.
	- Notes: Simulates pressing the hardware Off button. Set to 1 for 6 seconds to trigger system poweroff.

- BCM 13 (X728 v1)
	- Role: Power-control / power-cut latch output (v1 boards).
	- Direction: Output.
	- Notes: Controls the board’s power latch (cut after OS shutdown). Not the same as BCM 12; BCM 12 is the shutdown request pulse to the MCU.


I²C device(s)
- I2C bus: 1 (/dev/i2c-1)
- I2C address: 0x36
- Purpose: Battery fuel-gauge — voltage and capacity readings.
- Register access (summary):
	- Raw voltage is read as a 16-bit word from the gauge, bytes are byte-swapped and scaled to compute voltage in volts.
	- Raw capacity is read as a 16-bit word from the gauge, bytes are byte-swapped and scaled/divided to compute battery capacity (reported as percentage after clamping).

Choosing gpiochip / line offsets for libgpiod and gpioset/gpioget
- On many Raspberry Pi models (Pi 3, Pi 4 and similar), the SoC GPIO controller exposing BCM N lines commonly appears as `gpiochip0`. When using libgpiod tools, pass the appropriate chip (for example `gpiochip0`) and use BCM numbers as the line offsets.
- On Raspberry Pi 5 the SoC GPIO controller may appear at a different index such as `gpiochip4`. If `gpiochip0` does not expose the expected BCM lines, run the platform's gpiochip enumeration tools to find the chip that lists the SoC GPIO lines and use that chip.
- Quick check method: enumerate gpiochip devices with the system tools and inspect which chip lists the BCM lines you expect. Then use that chip name or index with gpioset/gpioget and the BCM numbers as offsets.

Recommended defaults and board mapping guidance
- X728 v2 boards: Use BCM 6 for power-loss detect input and BCM 26 for shutdown/power-control output.
- X728 v1 boards: Use BCM 6 for power-loss detect input and BCM 13 for shutdown/power-control output.
- Optional buzzer (v2 examples): BCM 20.
- Enable Button Reading: Set BCM 12 to 1 to enable reading the hardware button on BCM 5.

Usage notes (plain guidance)
- To set a BCM line on the correct gpiochip, choose the gpiochip that exposes the SoC GPIOs and set the line offset equal to the BCM number.
- To read a BCM input from the correct chip, query the chip and the BCM line offset; returned values indicate input state (0 or 1).
- To monitor edges, use the platform's line-monitoring tools on the chip and BCM line offset you selected.

Support and troubleshooting
- If expected BCM lines are not present on the chip you selected, enumerate available gpiochip devices and inspect which one exposes the SoC GPIOs for your Pi model.
- If you are unsure which hardware revision you have, identify which BCM mapping (13 vs 26 for shutdown) matches the board's silks or vendor documentation before applying pulses.

- Changelog
- Document created to summarize GPIO and I²C lines used by X728-family boards and to provide mapping guidance for libgpiod/gpioset usage across Raspberry Pi models.

Raspberry Pi 4 (40-pin header) — BCM to physical pin mapping
- This mapping is the standard 40-pin header layout used on Raspberry Pi 4 boards. Use these physical pin numbers when wiring connectors to the Pi header.
- Note: BCM numbers are used throughout this document; the table below translates the BCM number to the physical header pin.

- BCM 2  → Physical pin 3 (I²C SDA)
- BCM 3  → Physical pin 5 (I²C SCL)
- BCM 5  → Physical pin 29
- BCM 6  → Physical pin 31 (power-loss detect input)
- BCM 12 → Physical pin 32
- BCM 13 → Physical pin 33 (X728 v1 shutdown output)
- BCM 20 → Physical pin 38 (optional buzzer)
- BCM 26 → Physical pin 37 (X728 v2 shutdown output)

Using the mapping
- For I²C connections (battery fuel gauge): wire SDA to physical pin 3 and SCL to physical pin 5 on the Pi header.
- For power-detect input (BCM 6): wire the board input to physical pin 31 and ensure correct pull-up/pull-down per your board's expected active level.
- For shutdown/power-control output: wire the board's control line to the physical pin corresponding to BCM 26 (pin 37) for X728 v2 boards, or BCM 13 (pin 33) for X728 v1 boards.

Clarifying BCM 12 vs BCM 13 / 26
- BCM12: momentary shutdown request (pulse). Used to signal the UPS MCU to begin graceful shutdown logic.
- BCM13 (v1) or BCM26 (v2): power-cut / latch control. After the OS has halted, this line is toggled (often driven high briefly then low) to physically remove power.
- They are separate nets on the PCB; they are not shorted. Treat them as distinct functions.
- Caution: If both appear to act identically in your script, inspect whether the script mistakenly drives the same offset twice or you misidentified the gpiochip index.
Verification (if uncertain):
1. Use gpioset to pulse BCM12 only; observe that system begins shutdown sequence but power remains until final cut.
2. After halt, toggle BCM13 (v1) or BCM26 (v2); observe power removal.
3. With a logic probe: BCM12 shows brief activity during scripted shutdown; BCM13/26 changes near final power cut.
4. Inspect board silks: labels commonly differentiate PWR (13/26) vs SHDN or similar (12).
5. In git history: search for scripts issuing two different gpioset calls (one to 12 early, one to 13/26 late).
If behavior appears merged:
- Check for mistaken overlay/remap in /boot/ firmware config.
- Ensure no exported sysfs or daemon is re-driving both lines.
- Confirm you are addressing correct gpiochip (mismatch can make two offset numbers hit same physical pin on an alternate chip).
Troubleshooting:
- Run: gpiodetect; gpioinfo <chip>; confirm both lines report distinct offsets.
- Temporarily drive one line and measure continuity with multimeter—there should be no direct short between BCM12 and BCM13/26.

Detected I²C devices (example)
- The I²C bus commonly used on Raspberry Pi is `i2c-1` (pins SDA=BCM2, SCL=BCM3). A typical scan may show devices at addresses `0x36` and `0x68`.
- `0x36` is commonly a battery fuel-gauge IC (MAX17041 / MAX17043 family).
- `0x68` is commonly a real-time clock (RTC) such as the DS1307.

MAX17041 (battery fuel gauge) — summary
- I2C address: `0x36` on bus 1.
- Purpose: reports battery voltage and state-of-charge (capacity) for attached battery packs.
- Typical accesses and interpretation:
	- Raw voltage data is read as a 16-bit word from a dedicated voltage register. The raw word is byte-swapped and scaled; a commonly used formula to compute volts is: voltage = raw * 1.25 / 1000 / 16 (this yields volts after applying the chip's LSB scaling).
	- State-of-charge / capacity is read as a 16-bit register and after byte-swap and scaling (dividing by 256) yields a percentage-like value (often clamped to 0–100%).
- Wiring: connect SDA to physical pin 3 (BCM 2), SCL to physical pin 5 (BCM 3), power to the module's VCC (3.3V recommended) and GND to a Pi ground pin. Use the module's recommended supply voltage — many MAX1704x carrier boards are 3.3V compatible.
- Notes: The fuel-gauge is read via SMBus/I²C. Confirm the carrier board's supply voltage and whether any onboard pull-ups are present. On the Pi, the I²C bus already provides pull-ups to 3.3V; avoid adding conflicting pull-ups to other voltages.

DS1307 (real-time clock) — summary
- I2C address: `0x68` on bus 1.
- Purpose: battery-backed real-time clock — provides timekeeping even when the Pi is powered down (via coin cell on the RTC module).
- Registers: the DS1307 exposes time/date registers in BCD format (seconds, minutes, hours, day-of-week, date, month, year) at consecutive addresses starting at 0x00. It typically also provides control/status bytes and a RAM block.
- Wiring: connect SDA to physical pin 3 (BCM 2), SCL to physical pin 5 (BCM 3), GND to a Pi ground pin, and VCC to the module's VCC pin. Prefer powering the DS1307 module from 3.3V when the board supports it. If the module expects 5V, use a proper I²C level shifter between the Pi (3.3V) and the module.
- Battery backup: DS1307 modules typically include a coin-cell holder and a diode or power-path to allow the RTC to run from the backup battery when main power is removed. Do not omit the backup if continuous timekeeping is required.

# x728-script
User Guide: https://wiki.geekworm.com/X728-script

Email: support@geekworm.com
