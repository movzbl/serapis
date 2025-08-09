OUTPUT_FORMAT("binary")

SECTIONS
{
    /* start at base address 0 */
    . = 0x0;

    /* sections */
    .text : {
         FILL(0)

         HEADER_START = .;
         *(.header)
         HEADER_END = .;
         HEADER_SIZE = HEADER_END - HEADER_START;
         . = ALIGN(0x1000);
         HEADER_SIZE_ALIGNED = .;

         TEXT_START = .;
         *(.text)
         TEXT_END = .;
         TEXT_SIZE = TEXT_END - TEXT_START;
         . = ALIGN(0x1000);
         TEXT_SIZE_ALIGNED = .;

         DATA_START = .;
         *(.data)
         DATA_END = .;
         DATA_SIZE = DATA_END - DATA_START;
         . = ALIGN(0x1000);
         DATA_SIZE_ALIGNED = .;

         KERN_START = .;
         *(.kern)
         KERN_END = .;
         KERN_SIZE = KERN_END - KERN_START;
         . = ALIGN(0x1000);
         KERN_SIZE_ALIGNED = .;

         RAMD_START = .;
         *(.ramd)
         RAMD_END = .;
         RAMD_SIZE = RAMD_END - RAMD_START;
         . = ALIGN(0x1000);
         RAMD_SIZE_ALIGNED = .;

         RELOC_START = .;
         *(.reloc)
         RELOC_END = .;
         RELOC_SIZE = RELOC_END - RELOC_START;
         . = ALIGN(0x1000);
         RELOC_SIZE_ALIGNED = .;

         CODE_SIZE = TEXT_SIZE;
         INIT_DATA_SIZE = DATA_SIZE + KERN_SIZE + RAMD_SIZE + RELOC_SIZE;
         UNINIT_DATA_SIZE = 0;
         FULL_IMAGE_SIZE = .;
    }

    /DISCARD/ :
    {
        *(*)
    }
}
