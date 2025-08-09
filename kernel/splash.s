          # USE INTEL SYNTAX
          .intel_syntax noprefix

          # 64-BIT CODE
          .code64

          # GLOBAL SYMBOLS
          .global  SPLINIT

          # INCLUDE MACROS
          .include "kernel/common.inc"

############################################################################
#                           TEXT SECTION                                   #
############################################################################

            # TEXT SECTION
            .section .text

# ==========================================================================
#                             SPLINIT
# ============+=============================================================
# DESCRIPTION | INITIALIZE SPLASH
# ------------+-------------------------------------------------------------
# INPUTS      | N/A
# ------------+-------------------------------------------------------------
# OUTPUTS     | N/A
# ============+=============================================================

SPLINIT:    # STORE REGISTERS
            PUSH RAX
            PUSH RDX
            PUSH RSI

            # PRINT BOOTMSG
            MOV  DX,  0
            LEA  RSI, [BOOTMSG]
            CALL PUTS

            # PRINT HEADLINE
            MOV  DX,  1
            LEA  RSI, [HEADLINE]
            CALL PUTS

            # PRINT RTCLINE
            MOV  DX,  2
            LEA  RSI, [RTCLINE]
            CALL PUTS

            # PRINT PITLINE
            MOV  DX,  3
            LEA  RSI, [PITLINE]
            CALL PUTS

            # RESTORE REGISTERS
            POP  RSI
            POP  RDX
            POP  RAX

            # DONE
            RET

############################################################################
#                          RODATA SECTION                                  #
############################################################################

            # RODATA SECTION
            .section .rodata

BOOTMSG:    .ascii   "\r\n"
            .ascii   "STARTING KERNEL...\r\n"
            .ascii   "\0"

HEADLINE:   .ascii   "\r\n"
            .ascii   "                     THE SERAPIS SYSTEM FOR X86-64 COMPUTERS\r\n"
            .ascii   "                            COPYRIGHT (C) 2025, MOVZBL\r\n"
            .ascii   "                                  VERSION 1.0.1\r\n"
            .ascii   "\0"

RTCLINE:    .ascii   "  RTC NOT INITIALISED\0"
PITLINE:    .ascii   " FFFFFFFFFFFFFFFF\0"
