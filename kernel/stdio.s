            # USE INTEL SYNTAX
            .intel_syntax noprefix

            # 64-BIT CODE
            .code64

            # GLOBAL SYMBOLS
            .global  PUTC
            .global  PUTS

            # INCLUDE MACROS
            .include "kernel/common.inc"

############################################################################
#                           TEXT SECTION                                   #
############################################################################

            # TEXT SECTION
            .section .text

# ==========================================================================
#                              PUTC
# ============+=============================================================
# DESCRIPTION | PRINT CHAR TO SCREEN
# ------------+-------------------------------------------------------------
# INPUTS      | AL = ASCII
#             | DX = WINDOW
# ------------+-------------------------------------------------------------
# OUTPUTS     | N/A
# ============+=============================================================

PUTC:       # STORE REGS
            PUSH  RAX

            # HANDLE ASCII
            CMP   AL, '\r'
            JE    CR
            CMP   AL, '\n'
            JE    LF
            CMP   AL, '\b'
            JE    BK

            # NORMAL CHARACTER
NR:         CALL TERMCHRSET
            CALL TERMCURNXT
            JMP  DONE

CR:         # CARRIAGE RETURN
            CALL TERMCURCAR
            JMP  DONE

LF:         # LINE FEED
            CALL TERMCURLFD
            JMP  DONE

BK:         # BACKSPACE
            CALL TERMCHRCLR
            CALL TERMCURPRV
            JMP  DONE

            # RESTORE REGS
DONE:       POP   RAX

            # DONE
            RET

# ==========================================================================
#                              PUTS
# ============+=============================================================
# DESCRIPTION | PRINT STRING TO SCREEN
# ------------+-------------------------------------------------------------
# INPUTS      | DX  = WINDOW
#             | RSI = PTR TO STRING
# ------------+-------------------------------------------------------------
# OUTPUTS     | N/A
# ============+=============================================================

PUTS:       # STORE REGS
            PUSH  RAX
            PUSH  RSI

            # LOOP
1:          MOV   AL, [RSI]
            CMP   AL, 0
            JE    2f
            CALL  PUTC
            INC   RSI
            JMP   1b

            # RESTORE REGS
2:          POP   RSI
            POP   RAX

            # DONE
            RET

############################################################################
#                           DATA SECTION                                   #
############################################################################

            # DATA SECTION
            .section .data

############################################################################
#                           BSS SECTION                                    #
############################################################################

            # BSS SECTION
            .section .bss
