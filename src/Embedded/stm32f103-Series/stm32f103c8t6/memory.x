/* memory.x – Bluepill STM32F103C8 */

MEMORY
{
  FLASH : ORIGIN = 0x08000000, LENGTH = 64K
  RAM   : ORIGIN = 0x20000000, LENGTH = 20K
}

/* Stack am Ende des RAMs */
_stack_start = ORIGIN(RAM) + LENGTH(RAM);
