          # USE INTEL SYNTAX
          .intel_syntax noprefix

          # 64-BIT CODE
          .code64

          # GLOBAL SYMBOLS
          .global  KERNINIT

          # INCLUDE MACROS
          .include "kernel/common.inc"

          # ENTRY SECTION
          .section .entry

          # ENTRY CODE
          MOV  RAX, 0x00
          MOV  RBX, 0x00
          MOV  RCX, 0x00
          MOV  RDX, 0x00
          MOV  RSI, 0x00
          MOV  RDI, 0x00
          MOV  RBP, 0x00
          #MOV  RSP, 0x00
          MOV  R8,  0x00
          MOV  R9,  0x00
          MOV  R10, 0x00
          MOV  R11, 0x00
          MOV  R12, 0x00
          MOV  R13, 0x00
          MOV  R14, 0x00

          # COPY KERNINIT STRUCTURE FROM BOOTLOADER
          MOV  RSI, R15
          MOV  RDI, OFFSET KERNINIT
          MOV  RCX, KERNINIT_SZ>>3
          REP  MOVSQ

          # INITIALIZE KERNEL MODULES
          CALL TERMINIT
          CALL SPLINIT

          # DONE
          JMP  .

          # DATA SECTION
          .section .data

          # KERNINIT STRUCTURE
KERNINIT: .fill    KERNINIT_SZ
