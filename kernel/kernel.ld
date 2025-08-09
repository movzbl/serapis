OUTPUT_FORMAT("binary")
SECTIONS
{
    /* kernel is loaded at 0x100000 */
    . = 0x100000;

    /* code */
    .text : {
         FILL(0);
         *(.entry )
         . = ALIGN(0x1000);
         *(.text  )
         . = ALIGN(0x1000);
    }

    /* initialised data */
    .data : {
         FILL(0);
         *(.rodata)
         . = ALIGN(0x1000);
         *(.data  )
         . = ALIGN(0x1000);
    }

    /* uninitialised data */
    .bss : {
         *(.bss   )
         . = ALIGN(0x1000);
    }

    /DISCARD/ :
    {
        *(*)
    }
}
