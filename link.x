MEMORY
{
  CRAM (rwx) : ORIGIN = 0x000C0000, LENGTH = 352K
  DRAM       : ORIGIN = 0x00118000, LENGTH = 64K
  DRAM_ALIAS : ORIGIN = 0x20000000, LENGTH = 32K
  /*FLASH : ORIGIN = 0x000C0000, LENGTH = 0*/
}

/* # Entry point = reset vector */
EXTERN(__RESET_VECTOR);
EXTERN(Reset);
ENTRY(Reset);

EXTERN(DefaultHandler);

PROVIDE(NonMaskableInt = DefaultHandler);
PROVIDE(MemoryManagement = DefaultHandler);
PROVIDE(BusFault = DefaultHandler);
PROVIDE(UsageFault = DefaultHandler);
PROVIDE(SVCall = DefaultHandler);
PROVIDE(DebugMonitor = DefaultHandler);
PROVIDE(PendSV = DefaultHandler);

PROVIDE(DefaultHandler = DefaultHandler_);
PROVIDE(HardFault = HardFault_);

PROVIDE(__pre_init = DefaultPreInit);

SECTIONS
{
    PROVIDE(_ram_start = ORIGIN(DRAM_ALIAS));
    PROVIDE(_ram_end = ORIGIN(DRAM_ALIAS) + LENGTH(DRAM_ALIAS));
    PROVIDE(_stack_start = _ram_end);

    .vector_table ORIGIN(CRAM) :
    {
      __vector_table = .;

      LONG(_stack_start & 0xFFFFFFF8);

      KEEP(*(.vector_table.reset_vector));

      __exceptions = .;
      KEEP(*(.vector_table.exceptions));
      __eexceptions = .;

      KEEP(*(.vector_table.interrupts));
    } > CRAM

    PROVIDE(_stext = ADDR(.vector_table) + SIZEOF(.vector_table));

    .text _stext :
    {
        __stext = .;
        *(.Reset);
        *(.text .text.*);
        . = ALIGN(4);
        __etext = .;
    } > CRAM

    .rodata : ALIGN(4)
    {
        . = ALIGN(4);
        __srodat = .;
        *(.rodata .rodata.*);
        . = ALIGN(4);
        __erodata = .;
    } > CRAM

    .bss (NOLOAD) : ALIGN(4)
    {
        . = ALIGN(4);
        __sbss = .;
        *(.bss .bss.*);
        *(COMMON);
        . = ALIGN(4);
        __ebss = .;
    } > DRAM

    .data : ALIGN(4)
    {
        . = ALIGN(4);
        __sdata = .;
        *(.data .data.*);
    } > DRAM_ALIAS

    /* Allow sections from user `memory.x` injected using `INSERT AFTER .data` to
     * use the .data loading mechanism by pushing __edata. Note: do not change
     * output region or load region in those user sections! */
    . = ALIGN(4);
    __edata = .;

    __sidata = LOADADDR(.data);

  /* ## Discarded sections */
  /DISCARD/ :
  {
    /* Unused exception related info that only wastes space */
    *(.ARM.exidx);
    *(.ARM.exidx.*);
    *(.ARM.extab.*);
  }
}
