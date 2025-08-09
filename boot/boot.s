          # USE INTEL SYNTAX
          .intel_syntax noprefix

          # 64-BIT CODE
          .code64

          # INCLUDE KERNEL MACROS
          .include "kernel/common.inc"

########################################################################
#                         HEADER SECTION                               #
########################################################################

          # HEADER SECTION
          .section .header

          # MZ HEADER
          .ascii "MZ"                  # MZ Magic Number
          .fill  0x3C - 2, 1, 0        # Padding
          .long  0x40                  # e_lfanew

          # PE HEADER
          .ascii "PE\0\0"              # PE Magic Number
          .short 0x8664                # Machine: x86_64
          .short 5                     # NumberOfSections
          .long  0                     # TimeDateStamp
          .long  0                     # PointerToSymbolTable
          .long  0                     # NumberOfSymbols
          .short 0x00F0                # SizeOfOptionalHeader
          .short 0x020E                # Characteristics (EXE|NOLN|NOSYM|NODBG)

          # OPTIONAL HEADER
          .short 0x020B                # Magic: PE32+
          .byte  0                     # MajorLinkerVersion
          .byte  0                     # MinorLinkerVersion
          .long  CODE_SIZE             # SizeOfCode
          .long  INIT_DATA_SIZE        # SizeOfInitializedData
          .long  UNINIT_DATA_SIZE      # UninitializedData
          .long  TEXT_START            # AddressOfEntryPoint (RVA)
          .long  TEXT_START            # BaseOfCode
          .quad  0x0000000000000000    # ImageBase
          .long  0x1000                # SectionAlignment
          .long  0x1000                # FileAlignment
          .short 0                     # MajorOSVersion
          .short 0
          .short 0                     # MajorImageVersion
          .short 0
          .short 0                     # MajorSubsystemVersion
          .short 0
          .long  0                     # Win32VersionValue
          .long  FULL_IMAGE_SIZE       # SizeOfImage
          .long  HEADER_SIZE_ALIGNED   # SizeOfHeaders (Rounded Up)
          .long  0                     # CheckSum
          .short 10                    # Subsystem: EFI_APPLICATION
          .short 0x8540                # DllCharacteristics (DYN|NX|NOSEH|TERM)
          .quad  0x10000               # SizeOfStackReserve
          .quad  0x10000               # SizeOfStackCommit
          .quad  0x10000               # SizeOfHeapReserve
          .quad  0x10000               # SizeOfHeapCommit
          .long  0                     # LoaderFlags
          .long  0x10                  # NumberOfRvaAndSizes

          # DATA DIRECTORY TABLE
          .long  0                     # Export
          .long  0
          .long  0                     # Import
          .long  0
          .long  0                     # Resource
          .long  0
          .long  0                     # Exception
          .long  0
          .long  0                     # Certificate
          .long  0
          .long  RELOC_START           # BaseReloc
          .long  RELOC_SIZE
          .long  0                     # Debug
          .long  0
          .long  0                     # Architecture
          .long  0
          .long  0                     # GlobalPtr
          .long  0
          .long  0                     # TLS
          .long  0
          .long  0                     # LoadConfig
          .long  0
          .long  0                     # BoundImport
          .long  0
          .long  0                     # IAT
          .long  0
          .long  0                     # DelayImport
          .long  0
          .long  0                     # COMDescriptor
          .long  0
          .long  0                     # Reserved
          .long  0

          # TEXT SECTION HEADER
          .ascii ".text\0\0\0"         # SectionName
          .long  TEXT_SIZE             # VirtualSize
          .long  TEXT_START            # VirtualAddress
          .long  TEXT_SIZE             # SizeOfRawData
          .long  TEXT_START            # PointerToRawData
          .long  0                     # PointerToRelocations
          .long  0                     # PointerToLinenumbers
          .short 0                     # NumberOfRelocations
          .short 0                     # NumberOfLinenumbers
          .long  0x60000020            # Characteristics (CODE|EXEC|READ)

          # DATA SECTION HEADER
          .ascii ".data\0\0\0"         # SectionName
          .long  DATA_SIZE             # VirtualSize
          .long  DATA_START            # VirtualAddress
          .long  DATA_SIZE             # SizeOfRawData
          .long  DATA_START            # PointerToRawData
          .long  0                     # PointerToRelocations
          .long  0                     # PointerToLinenumbers
          .short 0                     # NumberOfRelocations
          .short 0                     # NumberOfLinenumbers
          .long  0xC0000040            # Characteristics (INIT|READ|WRITE)

          # KERN SECTION HEADER
          .ascii ".kern\0\0\0"         # SectionName
          .long  KERN_SIZE             # VirtualSize
          .long  KERN_START            # VirtualAddress
          .long  KERN_SIZE             # SizeOfRawData
          .long  KERN_START            # PointerToRawData
          .long  0                     # PointerToRelocations
          .long  0                     # PointerToLinenumbers
          .short 0                     # NumberOfRelocations
          .short 0                     # NumberOfLinenumbers
          .long  0x40000040            # Characteristics (INIT|READ)

          # RAMD SECTION HEADER
          .ascii ".ramd\0\0\0"         # SectionName
          .long  RAMD_SIZE             # VirtualSize
          .long  RAMD_START            # VirtualAddress
          .long  RAMD_SIZE             # SizeOfRawData
          .long  RAMD_START            # PointerToRawData
          .long  0                     # PointerToRelocations
          .long  0                     # PointerToLinenumbers
          .short 0                     # NumberOfRelocations
          .short 0                     # NumberOfLinenumbers
          .long  0x40000040            # Characteristics (INIT|READ)

          # RELOC SECTION HEADER
          .ascii ".reloc\0\0"          # SectionName
          .long  RELOC_SIZE            # VirtualSize
          .long  RELOC_START           # VirtualAddress
          .long  RELOC_SIZE            # SizeOfRawData
          .long  RELOC_START           # PointerToRawData
          .long  0                     # PointerToRelocations
          .long  0                     # PointerToLinenumbers
          .short 0                     # NumberOfRelocations
          .short 0                     # NumberOfLinenumbers
          .long  0x42000040            # Characteristics (INIT|DISCARD|READ)

########################################################################
#                          TEXT SECTION                                #
########################################################################

          # TEXT SECTION
          .section .text

          # ALIGN THE STACK
          SUB  RSP, 40
          MOV  RBP, RSP

          # MAKE SURE DIRECTION FLAG IS CLEARED
          CLD

          # SAVE IMAGE BASE ADDR IN RSI
          LEA  RSI, [RIP]
          AND  RSI, 0xFFFFFFFFFFFFF000
          SUB  RSI, OFFSET TEXT_START          # RSI = MEM BASE ADDR OF IMAGE

          # SAVE EFI_SYSTEM_TABLE IN RDI
          MOV  RDI, RDX                        # RDI = EFI_SYSTEM_TABLE

          # SAVE PTR TO KERNINIT IN R15
          LEA  R15, [RSI + KERNINIT]

          # CLEAR REMAINING REGS
          XOR  RAX, RAX
          XOR  RBX, RBX
          XOR  RCX, RCX
          XOR  RDX, RDX
          XOR  R8,  R8
          XOR  R9,  R9
          XOR  R10, R10
          XOR  R11, R11
          XOR  R12, R12
          XOR  R13, R13
          XOR  R14, R14

          # PRINT BOOTMSG
          MOV  RCX, [RDI + 0x40]               # RCX = SysTable->ConOut
          LEA  RDX, [RSI + BOOTMSG]            # RDX = &BOOTMSG
          MOV  RAX, [RCX + 0x08]               # RAX = RCX->OutputString()
          CALL RAX

          # CALL EFI_SYSTEM_TABLE->BootServices->LocateProtocol()
          LEA  RCX, [RSI + GOPGUID]            # RCX = &GOPGUID
          XOR  RDX, RDX                        # RDX = NULL
          LEA  R8,  [RSI + GOPPTR]             # R8  = &GOPPTR
          MOV  RAX, [RDI + 0x60]               # RAX = SysTable->BootServices
          MOV  RAX, [RAX + 0x140]              # RAX = RAX->LocateProtocol()
          CALL RAX
          CMP  RAX, 0
          JNE  PANGOP

          # GET EFI_GRAPHICS_OUTPUT_PROTOCOL->QueryMode
          # AND EFI_GRAPHICS_OUTPUT_PROTOCOL->Mode->MaxMode
          MOV  R14, [RSI + GOPPTR]             # R14 = GOP
          MOV  R13, [R14 + 0x18]               # R13 = GOP->Mode
          MOV  R12, [R13 + 0x00]               # R12 = GOP->Mode->MaxMode

          # LOOP OVER ALL MODES UNTIL WE FIND 640x480
MODELOOP: DEC  R12                             # R12--
          CMP  R12, -1
          JE   PANMNF
          MOV  RCX, R14                        # RCX = GOP
          MOV  RDX, R12                        # RDX = MODE COUNTER
          LEA  R8,  [RSI + MODESZ]             # R8  = &MODESZ
          LEA  R9,  [RSI + MODEPTR]            # R9  = &MODEPTR
          MOV  RAX, [R14 + 0x00]               # RAX = GOP->QueryMode()
          CALL RAX
          CMP  RAX, 0
          JNE  PANMQF
          MOV  R8,  [RSI + MODEPTR]            # R8  = MODEPTR
          MOV  EAX, [R8  + 0x04]               # RAX = MODEPTR->HorizRes
          CMP  EAX, RESOLUTION_WIDTH
          JNE  MODELOOP
          MOV  EAX, [R8  + 0x08]               # RAX = MODEPTR->VertRes
          CMP  EAX, RESOLUTION_HEIGHT
          JNE  MODELOOP
          MOV  EAX, [R8  + 0x0C]               # RAX = MODEPTR->PixFmt
          CMP  EAX, RESOLUTION_PIXFMT
          JNE  MODELOOP

          # CALL GOP->SetMode
          MOV  RCX, R14                        # RCX = GOP
          MOV  RDX, R12                        # RDX = MODE COUNTER
          MOV  RAX, [R14 + 0x08]               # RAX = GOP->SetMode()
          CALL RAX
          CMP  RAX, 0
          JNE  PANMSF

          # STORE FRAME BUFFER INFO IN KERNINIT
          MOV  R12, [R13 + 0x18]               # R12 = GOP->Mode->FrameBufBase
          MOV  [R15+KERNINIT_FBBASE], R12
          MOV  R12, [R13 + 0x20]               # R12 = GOP->Mode->FrameBufSize
          MOV  [R15+KERNINIT_FBSIZE], R12
          MOV  R12, [R13 + 0x08]               # R12 = GOP->Mode->Info
          XOR  RAX, RAX
          MOV  EAX, [R12 + 0x04]               # RAX = GOP->Mode->Info->HorRes
          MOV  [R15+KERNINIT_FBWIDTH], RAX
          MOV  EAX, [R12 + 0x08]               # RAX = GOP->Mode->Info->VerRes
          MOV  [R15+KERNINIT_FBHEIGHT], RAX
          MOV  EAX, [R12 + 0x0C]               # RAX = GOP->Mode->Info->PixFmt
          MOV  [R15+KERNINIT_FBPIXFMT], RAX
          MOV  EAX, [R12 + 0x20]               # RAX = GOP->Mode->Info->ScnLn
          MOV  [R15+KERNINIT_FBSCNLN], RAX

          # LOAD KERNEL.BIN TO RAM
          LEA  RSI, [RSI + KERN_START]
          MOV  RDI, 0x100000
          MOV  RCX, OFFSET KERN_SIZE
          SHR  RCX, 3
          REP  MOVSQ

          # DISABLE INTERRUPTS
          CLI

          # JUMP TO KERNEL
          MOV  R8, 0x100000
          JMP  R8

          # RETURN TO EFI (UNREACHABLE)
          XOR  EAX, EAX
          ADD  RSP, 40
          RET

          # PANIC: GOP NOT FOUND
PANGOP:   MOV  RCX, [RDI + 0x40]               # RCX = SysTable->ConOut
          LEA  RDX, [RSI + ERRGOP]             # RDX = &ERRGOP
          MOV  RAX, [RCX + 0x08]               # RAX = RCX->OutputString()
          CALL RAX
          JMP  .

          # PANIC: MODE NOT FOUND
PANMNF:   MOV  RCX, [RDI + 0x40]               # RCX = SysTable->ConOut
          LEA  RDX, [RSI + ERRMNF]             # RDX = &ERRMNF
          MOV  RAX, [RCX + 0x08]               # RAX = RCX->OutputString()
          CALL RAX
          JMP  .

          # PANIC: MODE QUERY FAILED
PANMQF:   MOV  RCX, [RDI + 0x40]               # RCX = SysTable->ConOut
          LEA  RDX, [RSI + ERRMQF]             # RDX = &ERRMQF
          MOV  RAX, [RCX + 0x08]               # RAX = RCX->OutputString()
          CALL RAX
          JMP  .

          # PANIC: MODE SET FAILED
PANMSF:   MOV  RCX, [RDI + 0x40]               # RCX = SysTable->ConOut
          LEA  RDX, [RSI + ERRMSF]             # RDX = &ERRMSF
          MOV  RAX, [RCX + 0x08]               # RAX = RCX->OutputString()
          CALL RAX
          JMP  .

########################################################################
#                          DATA SECTION                                #
########################################################################

          # DATA SECTION
          .section .data

          # LOADER WILL RELOCATE THIS (SEE RELOC TABLE)
          .quad    0

          # KERNEL INIT DATA STRUCTURE
KERNINIT: .fill    KERNINIT_SZ

          # GOP GUID (EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID)
GOPGUID:  .long    0x9042A9DE
          .short   0x23DC
          .short   0x4A38
          .byte    0x96
          .byte    0xFB
          .byte    0x7A
          .byte    0xDE
          .byte    0xD0
          .byte    0x80
          .byte    0x51
          .byte    0x6A

          # POINTER TO GOP DATA STRUCTURE
GOPPTR:   .quad    0

          # POINTER TO MODE INFO STRUCTURE
MODEPTR:  .quad    0

          # SIZE OF MODE INFO STRUCTURE
MODESZ:   .quad    0

          # BOOT MESSAGE
BOOTMSG:  .short   'B'
          .short   'O'
          .short   'O'
          .short   'T'
          .short   'I'
          .short   'N'
          .short   'G'
          .short   ' '
          .short   'S'
          .short   'Y'
          .short   'S'
          .short   'T'
          .short   'E'
          .short   'M'
          .short   '.'
          .short   '.'
          .short   '.'
          .short   '\r'
          .short   '\n'
          .short   0

          # GOP NOT FOUND ERROR
ERRGOP:   .short   'E'
          .short   'R'
          .short   'E'
          .short   'O'
          .short   'R'
          .short   ':'
          .short   ' '
          .short   'G'
          .short   'O'
          .short   'P'
          .short   ' '
          .short   'N'
          .short   'O'
          .short   'T'
          .short   ' '
          .short   'F'
          .short   'O'
          .short   'U'
          .short   'N'
          .short   'D'
          .short   '!'
          .short   '\r'
          .short   '\n'
          .short   0

          # MODE NOT FOUND ERROR
ERRMNF:   .short   'E'
          .short   'R'
          .short   'E'
          .short   'O'
          .short   'R'
          .short   ':'
          .short   ' '
          .short   'M'
          .short   'O'
          .short   'D'
          .short   'E'
          .short   ' '
          .short   'N'
          .short   'O'
          .short   'T'
          .short   ' '
          .short   'F'
          .short   'O'
          .short   'U'
          .short   'N'
          .short   'D'
          .short   '!'
          .short   '\r'
          .short   '\n'
          .short   0

          # MODE QUERY ERROR
ERRMQF:   .short   'E'
          .short   'R'
          .short   'E'
          .short   'O'
          .short   'R'
          .short   ':'
          .short   ' '
          .short   'M'
          .short   'O'
          .short   'D'
          .short   'E'
          .short   ' '
          .short   'Q'
          .short   'U'
          .short   'E'
          .short   'R'
          .short   'Y'
          .short   ' '
          .short   'F'
          .short   'A'
          .short   'I'
          .short   'L'
          .short   'E'
          .short   'D'
          .short   '!'
          .short   '\r'
          .short   '\n'
          .short   0

          # MODE SET ERROR
ERRMSF:   .short   'E'
          .short   'R'
          .short   'E'
          .short   'O'
          .short   'R'
          .short   ':'
          .short   ' '
          .short   'M'
          .short   'O'
          .short   'D'
          .short   'E'
          .short   ' '
          .short   'S'
          .short   'E'
          .short   'T'
          .short   ' '
          .short   'F'
          .short   'A'
          .short   'I'
          .short   'L'
          .short   'E'
          .short   'D'
          .short   '!'
          .short   '\r'
          .short   '\n'
          .short   0

########################################################################
#                          KERN SECTION                                #
########################################################################

          # KERN SECTION
          .section .kern

          # KERNEL BINARY
          .incbin "build/kernel/kernel.bin"

########################################################################
#                          RAMD SECTION                                #
########################################################################

          # RAMD SECTION
          .section .ramd

          # RAM DISK
          .quad 0

########################################################################
#                          RELOC SECTION                               #
########################################################################

          # RELOC SECTION
          .section .reloc

          # RELOCATION BLOCK
          .long  DATA_START           # Page RVA (0 for base address reloc)
          .long  12                   # Block Size (4 + 4 + 2 + 2)
          .short 0xA000               # Type = 0xA (DIR64), Offset = 0x0000
          .short 0                    # Padding
