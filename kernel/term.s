            # USE INTEL SYNTAX
            .intel_syntax noprefix

            # 64-BIT CODE
            .code64

            # GLOBAL SYMBOLS
            .global  TERMWINGET
            .global  TERMWINSET
            .global  TERMCLRGET
            .global  TERMCLRSET
            .global  TERMCURGET
            .global  TERMCURSET
            .global  TERMCURNXT
            .global  TERMCURPRV
            .global  TERMCURCAR
            .global  TERMCURLFD
            .global  TERMCURVIS
            .global  TERMCHRSET
            .global  TERMCHRCLR
            .global  TERMINIT

            # INCLUDE MACROS
            .include "kernel/common.inc"

############################################################################
#                           TEXT SECTION                                   #
############################################################################

            # TEXT SECTION
            .section .text

# ==========================================================================
#                             TERMGET
# ============+=============================================================
# DESCRIPTION | LOW LEVEL GET CHAR AT SPECIFIC ROW AND COL IN WINDOW
# ------------+-------------------------------------------------------------
# INPUTS      | DX = WINDOW INDEX
#             | SI = ROW INDEX
#             | DI = COL INDEX
# ------------+-------------------------------------------------------------
# OUTPUTS     | AL = ASCII
#             | BL = FG COLOUR
#             | BH = BG COLOUR
# ============+=============================================================

TERMGET:    # STORE REGS
            PUSH  RDX
            PUSH  R10
            PUSH  R11
            PUSH  R12
            PUSH  R13
            PUSH  R14
            PUSH  R15

            #########################
            # R10: COPY OF RAX
            # R11: COL INDEX
            # R12: ROW INDEX
            # R13: WINDOW INDEX
            #########################

            # SAVE RAX
            MOV   R10, RAX

            # SAVE INPUTS TO RX REGISTERS
            MOVZX R11, DI
            MOVZX R12, SI
            MOVZX R13, DX

            #########################
            # R15:  PTR TO WININFO
            # R14:  PTR TO CELL
            #########################

            # GET WININFO PTR IN R15
            LEA   R15, [WININFO]
            MOV   RAX, WININFO_SZ
            MUL   R13
            ADD   R15, RAX

            # GET CELL PTR IN R14
            LEA   R14, [WINDATA]  # R14 = &WINDATA
            MOV   RAX, WIN_ROWS_MAX*WIN_COLS_MAX*WINCELL_SZ
            MUL   R13
            ADD   R14, RAX        # R14 += WIN_ID*ROWS_MAX*COLS_MAX*4
            MOV   RAX, WIN_COLS_MAX*WINCELL_SZ
            MUL   R12
            ADD   R14, RAX        # R14 += ROW*COLS_MAX*4
            MOV   RAX, WINCELL_SZ
            MUL   R11
            ADD   R14, RAX        # R14 += COL*4

            # GET DATA FROM CELL
            MOV   RAX, R10
            MOV   AL,  [R14+WINCELL_CHR]
            MOV   BL,  [R14+WINCELL_BG]
            MOV   BH,  BL
            MOV   BL,  [R14+WINCELL_FG]

            # RESTORE REGS
            POP   R15
            POP   R14
            POP   R13
            POP   R12
            POP   R11
            POP   R10
            POP   RDX

            # DONE
            RET

# ==========================================================================
#                             TERMSET
# ============+=============================================================
# DESCRIPTION | LOW LEVEL SET CHAR AT SPECIFIC ROW AND COL IN WINDOW
# ------------+-------------------------------------------------------------
# INPUTS      | AL = ASCII
#             | BL = FG COLOUR
#             | BH = BG COLOUR
#             | DX = WINDOW INDEX
#             | SI = ROW INDEX
#             | DI = COL INDEX
# ------------+-------------------------------------------------------------
# OUTPUTS     | N/A
# ============+=============================================================

TERMSET:    # STORE REGS
            PUSH  RAX
            PUSH  RBX
            PUSH  RCX
            PUSH  RDX
            PUSH  RSI
            PUSH  RDI
            PUSH  R8
            PUSH  R9
            PUSH  R10
            PUSH  R11
            PUSH  R12
            PUSH  R13
            PUSH  R14
            PUSH  R15

            #########################
            # R8:  ASCII
            # R9:  FG COLOUR
            # R10: BG COLOUR
            # R11: COL INDEX
            # R12: ROW INDEX
            # R13: WINDOW INDEX
            #########################

            # SAVE INPUTS TO RX REGISTERS
            MOVZX R8,  AL
            MOVZX R9,  BL
            MOV   BL,  BH
            MOVZX R10, BL
            MOVZX R11, DI
            MOVZX R12, SI
            MOVZX R13, DX

            #########################
            # R15:  PTR TO WININFO
            # R14:  PTR TO CELL
            # RDI:  PTR TO FB PIXEL
            # RSI:  PTR TO FONT DATA
            #########################

            # GET WININFO PTR IN R15
            LEA   R15, [WININFO]
            MOV   RAX, WININFO_SZ
            MUL   R13
            ADD   R15, RAX

            # GET CELL PTR IN R14
            LEA   R14, [WINDATA]  # R14 = &WINDATA
            MOV   RAX, WIN_ROWS_MAX*WIN_COLS_MAX*WINCELL_SZ
            MUL   R13
            ADD   R14, RAX        # R14 += WIN_ID*ROWS_MAX*COLS_MAX*4
            MOV   RAX, WIN_COLS_MAX*WINCELL_SZ
            MUL   R12
            ADD   R14, RAX        # R14 += ROW*COLS_MAX*4
            MOV   RAX, WINCELL_SZ
            MUL   R11
            ADD   R14, RAX        # R14 += COL*4

            # GET PTR TO FIRST PIXEL IN RDI
            MOV   RAX, R12                        # RAX = ROW
            SHL   RAX, FONT_CHAR_HEIGHT_BITSHFT   # RAX = ROW*16
            XOR   RBX, RBX
            MOV   BX,  [R15+WININFO_Y]
            ADD   RAX, RBX                        # RAX = Y+ROW*16
            MOV   RBX, [FBSCNLN]
            MUL   RBX                             # RAX = (Y+ROW*16)*SL
            MOV   RDX, R11                        # RDX = COL
            SHL   RDX, FONT_CHAR_WIDTH_BITSHFT    # RDX = COL*8
            XOR   RBX, RBX
            MOV   BX,  [R15+WININFO_X]
            ADD   RDX, RBX                        # RDX = X+COL*8
            ADD   RAX, RDX                        # RAX = (Y+ROW*16)*SL+(X+COL*8)
            SHL   RAX, PIXEL_BITSHFT              # RAX = ((Y+ROW*16)*SL+(X+COL*8))*4
            ADD   RAX, [FBBASE]
            MOV   RDI, RAX

            # GET PTR TO FIRST FONT BYTE IN RSI
            MOV   RSI, R8
            SHL   RSI, FONT_CHAR_TOTSIZE_BITSHFT
            ADD   RSI, OFFSET FONT

            # STORE DATA TO CELL
            XOR   AL, AL
            MOV   [R14+WINCELL_CHR], R8B
            MOV   [R14+WINCELL_RSV], AL
            MOV   [R14+WINCELL_FG],  R9B
            MOV   [R14+WINCELL_BG],  R10B

            #########################
            # AL:  FONT BYTE
            # AH:  PRINT CURSOR
            # RBX: 0->16 COUNTER
            # RCX: 0->8  COUNTER
            # RDX: SCANLINE*4
            # RSI: PTR TO CUR FONT BYTE
            # RDI: PTR TO CUR FB PIXEL
            # R8:  ASCII
            # R9:  FG RGB
            # R10: BG RGB
            #########################

            # DETERMINE IF WE NEED TO PRINT CURSOR
            XOR   AH,    AH
            CMP   R11W,  [R15+WININFO_CURS_COL]
            JNE   1f
            CMP   R12W,  [R15+WININFO_CURS_ROW]
            JNE   1f
            MOV   BL,    [R15+WININFO_CURS_EN]
            MOV   AH,    BL

            # GET FG RGB IN RBX
1:          SHL   R9,    3
            MOV   R9D,   [PALETTE+R9]

            # GET BG RGB IN RCX
            SHL   R10,   3
            MOV   R10D,  [PALETTE+R10]

            # LOAD SCANLINE SIZE IN RDX
            MOV   RDX,   [FBSCNLN]
            SHL   RDX,   PIXEL_BITSHFT

            # DRAW PIXEL DATA
            MOV   RBX,   FONT_CHAR_HEIGHT
1:          MOV   RCX,   FONT_CHAR_WIDTH
2:          CMP   RBX,   1
            JNE   3f
            CMP   AH,    1
            JE    4f
3:          MOV   AL,    [RSI]
            CMP   AL,    '0'
            JNE   4f
            MOV   [RDI], R10D
            JMP   5f
4:          MOV   [RDI], R9D
5:          INC   RSI
            ADD   RDI,   PIXEL_SIZE
            LOOP  2b
            ADD   RDI,   RDX
            SUB   RDI,   FONT_CHAR_WIDTH*PIXEL_SIZE
            DEC   RBX
            JNZ   1b

            # RESTORE REGS
            POP  R15
            POP  R14
            POP  R13
            POP  R12
            POP  R11
            POP  R10
            POP  R9
            POP  R8
            POP  RDI
            POP  RSI
            POP  RDX
            POP  RCX
            POP  RBX
            POP  RAX

            # DONE
            RET

# ==========================================================================
#                             TERMWINGET
# ============+=============================================================
# DESCRIPTION | GET WINDOW CONFIGURATION
# ------------+-------------------------------------------------------------
# INPUTS      | DX = WINDOW INDEX
# ------------+-------------------------------------------------------------
# OUTPUTS     | BX = X
#             | CX = Y
#             | SI = ROW
#             | DI = COL
# ============+=============================================================

TERMWINGET: # STORE REGS
            PUSH  RAX
            PUSH  RDX
            PUSH  R14
            PUSH  R15

            #########################
            # R15:  PTR TO WININFO
            # R14:  COPY OF WINDOW ID
            #########################

            # KEEP A COPY OF WINDOW ID
            MOVZX R14, DX

            # GET WININFO PTR IN R15
            MOV   RAX, WININFO_SZ
            MUL   R14
            LEA   R15, [WININFO]
            ADD   R15, RAX

            # GET WINDOW CONFIG
            MOV   BX, [R15+WININFO_X]
            MOV   CX, [R15+WININFO_Y]
            MOV   SI, [R15+WININFO_ROWS]
            MOV   DI, [R15+WININFO_COLS]

            # RESTORE REGS
            POP  R15
            POP  R14
            POP  RDX
            POP  RAX

            # DONE
            RET

# ==========================================================================
#                             TERMWINSET
# ============+=============================================================
# DESCRIPTION | SET WINDOW CONFIGURATION
# ------------+-------------------------------------------------------------
# INPUTS      | BX = X
#             | CX = Y
#             | DX = WINDOW INDEX
#             | SI = ROW
#             | DI = COL
# ------------+-------------------------------------------------------------
# OUTPUTS     | N/A
# ============+=============================================================

TERMWINSET: # STORE REGS
            PUSH  RAX
            PUSH  RDX
            PUSH  R14
            PUSH  R15

            #########################
            # R15:  PTR TO WININFO
            # R14:  COPY OF WINDOW ID
            #########################

            # KEEP A COPY OF WINDOW ID
            MOVZX R14, DX

            # GET WININFO PTR IN R15
            MOV   RAX, WININFO_SZ
            MUL   R14
            LEA   R15, [WININFO]
            ADD   R15, RAX

            # SET WINDOW CONFIG
            MOV   [R15+WININFO_X], BX
            MOV   [R15+WININFO_Y], CX
            MOV   [R15+WININFO_ROWS], SI
            MOV   [R15+WININFO_COLS], DI

            # RESTORE REGS
            POP  R15
            POP  R14
            POP  RDX
            POP  RAX

            # DONE
            RET

# ==========================================================================
#                             TERMCLRGET
# ============+=============================================================
# DESCRIPTION | GET COLOURS
# ------------+-------------------------------------------------------------
# INPUTS      | DX = WINDOW INDEX
# ------------+-------------------------------------------------------------
# OUTPUTS     | BL = FG COLOUR
#             | BH = BG COLOUR
# ============+=============================================================

TERMCLRGET: # STORE REGS
            PUSH  RAX
            PUSH  RDX
            PUSH  R14
            PUSH  R15

            #########################
            # R15:  PTR TO WININFO
            # R14:  COPY OF WINDOW ID
            #########################

            # KEEP A COPY OF WINDOW ID
            MOVZX R14, DX

            # GET WININFO PTR IN R15
            MOV   RAX, WININFO_SZ
            MUL   R14
            LEA   R15, [WININFO]
            ADD   R15, RAX

            # GET COLOURS
            MOV   BL, [R15+WININFO_FG]
            MOV   AL, [R15+WININFO_BG]
            MOV   BH, AL

            # RESTORE REGS
            POP  R15
            POP  R14
            POP  RDX
            POP  RAX

            # DONE
            RET

# ==========================================================================
#                             TERMCLRSET
# ============+=============================================================
# DESCRIPTION | SET COLOUR
# ------------+-------------------------------------------------------------
# INPUTS      | BL = FG COLOUR
#             | BH = BG COLOUR
#             | DX = WINDOW INDEX
# ------------+-------------------------------------------------------------
# OUTPUTS     | N/A
# ============+=============================================================

TERMCLRSET: # STORE REGS
            PUSH  RAX
            PUSH  RDX
            PUSH  R14
            PUSH  R15

            #########################
            # R15:  PTR TO WININFO
            # R14:  COPY OF WINDOW ID
            #########################

            # KEEP A COPY OF WINDOW ID
            MOVZX R14, DX

            # GET WININFO PTR IN R15
            MOV   RAX, WININFO_SZ
            MUL   R14
            LEA   R15, [WININFO]
            ADD   R15, RAX

            # SET COLOURS
            MOV   AL, BH
            MOV   [R15+WININFO_BG], AL
            MOV   [R15+WININFO_FG], BL

            # RESTORE REGS
            POP  R15
            POP  R14
            POP  RDX
            POP  RAX

            # DONE
            RET

# ==========================================================================
#                             TERMCURGET
# ============+=============================================================
# DESCRIPTION | GET CURSOR POSITION
# ------------+-------------------------------------------------------------
# INPUTS      | DX = WINDOW INDEX
# ------------+-------------------------------------------------------------
# OUTPUTS     | SI = ROW INDEX
#             | DI = COL INDEX
# ============+=============================================================

TERMCURGET: # STORE REGS
            PUSH  RAX
            PUSH  RDX
            PUSH  R14
            PUSH  R15

            #########################
            # R15:  PTR TO WININFO
            # R14:  COPY OF WINDOW ID
            #########################

            # KEEP A COPY OF WINDOW ID
            MOVZX R14, DX

            # GET WININFO PTR IN R15
            MOV   RAX, WININFO_SZ
            MUL   R14
            LEA   R15, [WININFO]
            ADD   R15, RAX

            # LOAD CURSOR POS
            MOV   SI, [R15+WININFO_CURS_ROW]
            MOV   DI, [R15+WININFO_CURS_COL]

            # RESTORE REGS
            POP  R15
            POP  R14
            POP  RDX
            POP  RAX

            # DONE
            RET

# ==========================================================================
#                             TERMCURSET
# ============+=============================================================
# DESCRIPTION | SET CURSOR POSITION
# ------------+-------------------------------------------------------------
# INPUTS      | DX = WINDOW INDEX
#             | SI = NEW ROW INDEX
#             | DI = NEW COL INDEX
# ------------+-------------------------------------------------------------
# OUTPUTS     | N/A
# ============+=============================================================

TERMCURSET: # STORE REGS
            PUSH  RAX
            PUSH  RDX
            PUSH  RSI
            PUSH  RDI
            PUSH  R12
            PUSH  R13
            PUSH  R14
            PUSH  R15

            #########################
            # R15:  PTR TO WININFO
            # R14:  COPY OF WINDOW ID
            # R13:  OLD COL INDEX
            # R12:  OLD ROW INDEX
            #########################

            # KEEP A COPY OF WINDOW ID
            MOVZX R14, DX

            # GET WININFO PTR IN R15
            MOV   RAX, WININFO_SZ
            MUL   R14
            LEA   R15, [WININFO]
            ADD   R15, RAX

            # GET OLD CUR POSITION
            MOV   R12W, [R15+WININFO_CURS_ROW]
            MOV   R13W, [R15+WININFO_CURS_COL]

            # SET NEW CUR POSITION
            MOV   [R15+WININFO_CURS_ROW], SI
            MOV   [R15+WININFO_CURS_COL], DI

            # REPRINT CHAR AT NEW CUR POSITION
            MOV   DX, R14W
            CALL  TERMGET
            CALL  TERMSET

            # REPRINT CHAR AT OLD CUR POSITION
            MOV   SI, R12W
            MOV   DI, R13W
            MOV   DX, R14W
            CALL  TERMGET
            CALL  TERMSET

            # RESTORE REGS
            POP  R15
            POP  R14
            POP  R13
            POP  R12
            POP  RDI
            POP  RSI
            POP  RDX
            POP  RAX

            # DONE
            RET

# ==========================================================================
#                             TERMCURNXT
# ============+=============================================================
# DESCRIPTION | MOVE CURSOR TO NEXT CELL
# ------------+-------------------------------------------------------------
# INPUTS      | DX = WINDOW INDEX
# ------------+-------------------------------------------------------------
# OUTPUTS     | N/A
# ============+=============================================================

TERMCURNXT: # STORE REGS
            PUSH  RAX
            PUSH  RDX
            PUSH  RSI
            PUSH  RDI
            PUSH  R14
            PUSH  R15

            #########################
            # R15:  PTR TO WININFO
            # R14:  COPY OF WINDOW ID
            # R13:  OLD COL INDEX
            # R12:  OLD ROW INDEX
            #########################

            # KEEP A COPY OF WINDOW ID
            MOVZX R14, DX

            # GET WININFO PTR IN R15
            MOV   RAX, WININFO_SZ
            MUL   R14
            LEA   R15, [WININFO]
            ADD   R15, RAX

            # GET CUR POSITION
            MOV   SI, [R15+WININFO_CURS_ROW]
            MOV   DI, [R15+WININFO_CURS_COL]

            # INCREASE COL
            INC   DI
            CMP   DI, [R15+WININFO_COLS]
            JNE   1f
            XOR   DI, DI

            # INCREASE ROW
            INC   SI
            CMP   SI, [R15+WININFO_ROWS]
            JNE   1f
            DEC   SI

            # SCROLL
            #CALL  TERMSCRL

            # UPDATE CURSOR POSITION
1:          MOV   DX, R14W
            CALL  TERMCURSET

            # RESTORE REGS
            POP   R15
            POP   R14
            POP   RDI
            POP   RSI
            POP   RDX
            POP   RAX

            # DONE
            RET

# ==========================================================================
#                             TERMCURPRV
# ============+=============================================================
# DESCRIPTION | MOVE CURSOR TO PREV CELL
# ------------+-------------------------------------------------------------
# INPUTS      | DX = WINDOW INDEX
# ------------+-------------------------------------------------------------
# OUTPUTS     | N/A
# ============+=============================================================

TERMCURPRV: # STORE REGS
            PUSH  RAX
            PUSH  RDX
            PUSH  RSI
            PUSH  RDI
            PUSH  R14
            PUSH  R15

            #########################
            # R15:  PTR TO WININFO
            # R14:  COPY OF WINDOW ID
            # R13:  OLD COL INDEX
            # R12:  OLD ROW INDEX
            #########################

            # KEEP A COPY OF WINDOW ID
            MOVZX R14, DX

            # GET WININFO PTR IN R15
            MOV   RAX, WININFO_SZ
            MUL   R14
            LEA   R15, [WININFO]
            ADD   R15, RAX

            # GET CUR POSITION
            MOV   SI, [R15+WININFO_CURS_ROW]
            MOV   DI, [R15+WININFO_CURS_COL]

            # DECREASE COL
            DEC   DI
            CMP   DI, 0xFFFF
            JNE   1f
            MOV   DI, [R15+WININFO_COLS]
            DEC   DI

            # DECREASE ROW
            DEC   SI
            CMP   SI, 0xFFFF
            JNE   1f
            XOR   SI, SI

            # UPDATE CURSOR POSITION
1:          MOV   DX, R14W
            CALL  TERMCURSET

            # RESTORE REGS
            POP   R15
            POP   R14
            POP   RDI
            POP   RSI
            POP   RDX
            POP   RAX

            # DONE
            RET

# ==========================================================================
#                             TERMCURCAR
# ============+=============================================================
# DESCRIPTION | MOVE CURSOR TO CARRIAGE RETURN POSITION
# ------------+-------------------------------------------------------------
# INPUTS      | DX = WINDOW INDEX
# ------------+-------------------------------------------------------------
# OUTPUTS     | N/A
# ============+=============================================================

TERMCURCAR: # STORE REGS
            PUSH  RAX
            PUSH  RDX
            PUSH  RSI
            PUSH  RDI
            PUSH  R14
            PUSH  R15

            #########################
            # R15:  PTR TO WININFO
            # R14:  COPY OF WINDOW ID
            # R13:  OLD COL INDEX
            # R12:  OLD ROW INDEX
            #########################

            # KEEP A COPY OF WINDOW ID
            MOVZX R14, DX

            # GET WININFO PTR IN R15
            MOV   RAX, WININFO_SZ
            MUL   R14
            LEA   R15, [WININFO]
            ADD   R15, RAX

            # GET CUR POSITION
            MOV   SI, [R15+WININFO_CURS_ROW]
            MOV   DI, [R15+WININFO_CURS_COL]

            # SET COL TO ZERO
            XOR   DI, DI

            # UPDATE CURSOR POSITION
1:          MOV   DX, R14W
            CALL  TERMCURSET

            # RESTORE REGS
            POP   R15
            POP   R14
            POP   RDI
            POP   RSI
            POP   RDX
            POP   RAX

            # DONE
            RET

# ==========================================================================
#                             TERMCURLFD
# ============+=============================================================
# DESCRIPTION | MOVE CURSOR TO LINE FEED POSITION
# ------------+-------------------------------------------------------------
# INPUTS      | DX = WINDOW INDEX
# ------------+-------------------------------------------------------------
# OUTPUTS     | N/A
# ============+=============================================================

TERMCURLFD: # STORE REGS
            PUSH  RAX
            PUSH  RDX
            PUSH  RSI
            PUSH  RDI
            PUSH  R14
            PUSH  R15

            #########################
            # R15:  PTR TO WININFO
            # R14:  COPY OF WINDOW ID
            # R13:  OLD COL INDEX
            # R12:  OLD ROW INDEX
            #########################

            # KEEP A COPY OF WINDOW ID
            MOVZX R14, DX

            # GET WININFO PTR IN R15
            MOV   RAX, WININFO_SZ
            MUL   R14
            LEA   R15, [WININFO]
            ADD   R15, RAX

            # GET CUR POSITION
            MOV   SI, [R15+WININFO_CURS_ROW]
            MOV   DI, [R15+WININFO_CURS_COL]

            # INCREASE ROW
            INC   SI
            CMP   SI, [R15+WININFO_ROWS]
            JNE   1f
            DEC   SI

            # SCROLL
            #CALL  TERMSCRL

            # UPDATE CURSOR POSITION
1:          MOV   DX, R14W
            CALL  TERMCURSET

            # RESTORE REGS
            POP   R15
            POP   R14
            POP   RDI
            POP   RSI
            POP   RDX
            POP   RAX

            # DONE
            RET

# ==========================================================================
#                             TERMCURVIS
# ============+=============================================================
# DESCRIPTION | SET CURSOR VISIBILITY
# ------------+-------------------------------------------------------------
# INPUTS      | AL = CURSOR VISIBILITY ENABLE/DISABLE FLAG
#             | DX = WINDOW INDEX
# ------------+-------------------------------------------------------------
# OUTPUTS     | N/A
# ============+=============================================================

TERMCURVIS: # STORE REGS
            PUSH  RAX
            PUSH  RDX
            PUSH  RSI
            PUSH  RDI
            PUSH  R13
            PUSH  R14
            PUSH  R15

            #########################
            # R15:  PTR TO WININFO
            # R14:  COPY OF WINDOW ID
            # R13:  COPY OF RAX
            #########################

            # KEEP A COPY OF RAX
            MOV   R13, RAX

            # KEEP A COPY OF WINDOW ID
            MOVZX R14, DX

            # GET WININFO PTR IN R15
            MOV   RAX, WININFO_SZ
            MUL   R14
            LEA   R15, [WININFO]
            ADD   R15, RAX

            # SET CURSOR VISIBILITY
            MOV   [R15+WININFO_CURS_EN], R13B

            # REPRINT CHAR AT CURSOR
            MOV   DX, R14W
            MOV   SI, [R15+WININFO_CURS_ROW]
            MOV   DI, [R15+WININFO_CURS_COL]
            CALL  TERMGET
            CALL  TERMSET

            # RESTORE REGS
            POP  R15
            POP  R14
            POP  R13
            POP  RDI
            POP  RSI
            POP  RDX
            POP  RAX

            # DONE
            RET

# ==========================================================================
#                             TERMCHRSET
# ============+=============================================================
# DESCRIPTION | SET CHARACTER AT CURRENT CURSOR POSITION
# ------------+-------------------------------------------------------------
# INPUTS      | AL = ASCII
#             | DX = WINDOW INDEX
# ------------+-------------------------------------------------------------
# OUTPUTS     | N/A
# ============+=============================================================

TERMCHRSET: # STORE REGS
            PUSH  RAX
            PUSH  RBX
            PUSH  RCX
            PUSH  RDX
            PUSH  RSI
            PUSH  RDI
            PUSH  R13
            PUSH  R14
            PUSH  R15

            #########################
            # R15:  PTR TO WININFO
            # R14:  COPY OF WINDOW ID
            # R13:  COPY OF ASCII
            # AL:   ASCII
            # BL:   FG COLOUR
            # BH:   BG COLOUR
            # DX:   WINDOW ID
            # SI:   ROW
            # DI:   COL
            #########################

            # KEEP A COPY OF ASCII
            MOVZX R13, AL

            # KEEP A COPY OF WINDOW ID
            MOVZX R14, DX

            # GET WININFO PTR IN R15
            MOV   RAX, WININFO_SZ
            MUL   R14
            LEA   R15, [WININFO]
            ADD   R15, RAX

            # PRINT CHAR
            MOV   AL, R13B
            MOV   BL, [R15+WININFO_BG]
            MOV   BH, BL
            MOV   BL, [R15+WININFO_FG]
            MOV   DX, R14W
            MOV   SI, [R15+WININFO_CURS_ROW]
            MOV   DI, [R15+WININFO_CURS_COL]
            CALL  TERMSET

            # RESTORE REGS
            POP   R15
            POP   R14
            POP   R13
            POP   RDI
            POP   RSI
            POP   RDX
            POP   RCX
            POP   RBX
            POP   RAX

            # DONE
            RET

# ==========================================================================
#                             TERMCHRCLR
# ============+=============================================================
# DESCRIPTION | CLEAR CHARACTER AT CURRENT CURSOR POSITION
# ------------+-------------------------------------------------------------
# INPUTS      | DX = WINDOW INDEX
# ------------+-------------------------------------------------------------
# OUTPUTS     | N/A
# ============+=============================================================

TERMCHRCLR: # STORE REGS
            PUSH  RAX
            PUSH  RBX
            PUSH  RCX
            PUSH  RDX
            PUSH  RSI
            PUSH  RDI
            PUSH  R14
            PUSH  R15

            #########################
            # R15:  PTR TO WININFO
            # R14:  COPY OF WINDOW ID
            # AL:   ASCII (0)
            # BL:   FG COLOUR
            # BH:   BG COLOUR
            # DX:   WINDOW ID
            # SI:   ROW
            # DI:   COL
            #########################

            # KEEP A COPY OF WINDOW ID
            MOVZX R14, DX

            # GET WININFO PTR IN R15
            MOV   RAX, WININFO_SZ
            MUL   R14
            LEA   R15, [WININFO]
            ADD   R15, RAX

            # PRINT NULL
            XOR   AL, AL
            MOV   BL, [R15+WININFO_BG]
            MOV   BH, BL
            MOV   BL, [R15+WININFO_FG]
            MOV   DX, R14W
            MOV   SI, [R15+WININFO_CURS_ROW]
            MOV   DI, [R15+WININFO_CURS_COL]
            CALL  TERMSET

            # RESTORE REGS
            POP   R15
            POP   R14
            POP   RDI
            POP   RSI
            POP   RDX
            POP   RCX
            POP   RBX
            POP   RAX

            # DONE
            RET

# ==========================================================================
#                             TERMCLS
# ============+=============================================================
# DESCRIPTION | CLEAR SCREEN
# ------------+-------------------------------------------------------------
# INPUTS      | DX = WINDOW INDEX
# ------------+-------------------------------------------------------------
# OUTPUTS     | N/A
# ============+=============================================================

TERMCLS:    # STORE REGS
            PUSH  RAX
            PUSH  RBX
            PUSH  RCX
            PUSH  RDX
            PUSH  RSI
            PUSH  RDI
            PUSH  R14
            PUSH  R15

            #########################
            # R15:  PTR TO WININFO
            # R14:  COPY OF WINDOW ID
            # AL:   NULL CHAR
            # BL:   FG COLOUR
            # BH:   BG COLOUR
            # DX:   WINDOW ID
            # SI:   ROW COUNTER
            # DI:   COL COUNTER
            #########################

            # KEEP A COPY OF WINDOW ID
            MOVZX R14, DX

            # GET WININFO PTR IN R15
            MOV   RAX, WININFO_SZ
            MUL   R14
            LEA   R15, [WININFO]
            ADD   R15, RAX

            # LOAD PARAMETERS
            XOR   AL, AL
            MOV   BL, [R15+WININFO_BG]
            MOV   BH, BL
            MOV   BL, [R15+WININFO_FG]
            MOV   DX, R14W
            MOV   SI, 0
            MOV   DI, 0

            # LOOP
1:          CALL  TERMSET
            INC   DI
            CMP   DI, [R15+WININFO_COLS]
            JNE   1b
            XOR   DI, DI
            INC   SI
            CMP   SI, [R15+WININFO_ROWS]
            JNE   1b

            # RESTORE REGS
            POP  R15
            POP  R14
            POP  RDI
            POP  RSI
            POP  RDX
            POP  RCX
            POP  RBX
            POP  RAX

            # DONE
            RET

# ==========================================================================
#                             TERM_INIT
# ============+=============================================================
# DESCRIPTION | INITIALIZE TERMINAL
# ------------+-------------------------------------------------------------
# INPUTS      | N/A
# ------------+-------------------------------------------------------------
# OUTPUTS     | N/A
# ============+=============================================================

TERMINIT:   # STORE REGS
            PUSH RAX
            PUSH RDX
            PUSH RDI

            # GET FB INFO FROM KERNINIT
            MOV  RAX, [KERNINIT+KERNINIT_FBBASE]
            MOV  [FBBASE], RAX
            MOV  RAX, [KERNINIT+KERNINIT_FBSIZE]
            MOV  [FBSIZE], RAX
            MOV  RAX, [KERNINIT+KERNINIT_FBSCNLN]
            MOV  [FBSCNLN], RAX
            MOV  RAX, [KERNINIT+KERNINIT_FBWIDTH]
            MOV  [FBWIDTH], RAX
            MOV  RAX, [KERNINIT+KERNINIT_FBHEIGHT]
            MOV  [FBHEIGHT], RAX
            MOV  RAX, [KERNINIT+KERNINIT_FBPIXFMT]
            MOV  [FBPIXFMT], RAX

            # INIT WIN0
            MOV  DX, 0
            MOV  BX, WIN0_X
            MOV  CX, WIN0_Y
            MOV  SI, WIN0_ROWS
            MOV  DI, WIN0_COLS
            CALL TERMWINSET
            MOV  BL, WIN0_FG
            MOV  BH, WIN0_BG
            CALL TERMCLRSET
            XOR  SI, SI
            XOR  DI, DI
            CALL TERMCURSET
            MOV  AL, WIN0_CURS_EN
            CALL TERMCURVIS
            CALL TERMCLS

            # INIT WIN1
            MOV  DX, 1
            MOV  BX, WIN1_X
            MOV  CX, WIN1_Y
            MOV  SI, WIN1_ROWS
            MOV  DI, WIN1_COLS
            CALL TERMWINSET
            MOV  BL, WIN1_FG
            MOV  BH, WIN1_BG
            CALL TERMCLRSET
            XOR  SI, SI
            XOR  DI, DI
            CALL TERMCURSET
            MOV  AL, WIN1_CURS_EN
            CALL TERMCURVIS
            CALL TERMCLS

            # INIT WIN2
            MOV  DX, 2
            MOV  BX, WIN2_X
            MOV  CX, WIN2_Y
            MOV  SI, WIN2_ROWS
            MOV  DI, WIN2_COLS
            CALL TERMWINSET
            MOV  BL, WIN2_FG
            MOV  BH, WIN2_BG
            CALL TERMCLRSET
            XOR  SI, SI
            XOR  DI, DI
            CALL TERMCURSET
            MOV  AL, WIN2_CURS_EN
            CALL TERMCURVIS
            CALL TERMCLS

            # INIT WIN3
            MOV  DX, 3
            MOV  BX, WIN3_X
            MOV  CX, WIN3_Y
            MOV  SI, WIN3_ROWS
            MOV  DI, WIN3_COLS
            CALL TERMWINSET
            MOV  BL, WIN3_FG
            MOV  BH, WIN3_BG
            CALL TERMCLRSET
            XOR  SI, SI
            XOR  DI, DI
            CALL TERMCURSET
            MOV  AL, WIN3_CURS_EN
            CALL TERMCURVIS
            CALL TERMCLS

            # INIT WIN4
            MOV  DX, 4
            MOV  BX, WIN4_X
            MOV  CX, WIN4_Y
            MOV  SI, WIN4_ROWS
            MOV  DI, WIN4_COLS
            CALL TERMWINSET
            MOV  BL, WIN4_FG
            MOV  BH, WIN4_BG
            CALL TERMCLRSET
            XOR  SI, SI
            XOR  DI, DI
            CALL TERMCURSET
            MOV  AL, WIN4_CURS_EN
            CALL TERMCURVIS
            CALL TERMCLS

            # RESTORE REGS
            POP  RDI
            POP  RDX
            POP  RAX

            # DONE
            RET

############################################################################
#                           DATA SECTION                                   #
############################################################################

            # DATA SECTION
            .section .data

            # WININFO STRUCT
WININFO:    .fill    WIN_COUNT_MAX*WININFO_SZ

            # FRAME BUFFER DATA STRUCTURE
FBBASE:     .quad    0
FBSIZE:     .quad    0
FBSCNLN:    .quad    0
FBWIDTH:    .quad    0
FBHEIGHT:   .quad    0
FBPIXFMT:   .quad    0

            # COLOUR PALETTE
PALETTE:    .quad    PALETTE_00
            .quad    PALETTE_01
            .quad    PALETTE_02
            .quad    PALETTE_03
            .quad    PALETTE_04
            .quad    PALETTE_05
            .quad    PALETTE_06
            .quad    PALETTE_07
            .quad    PALETTE_08
            .quad    PALETTE_09
            .quad    PALETTE_0A
            .quad    PALETTE_0B
            .quad    PALETTE_0C
            .quad    PALETTE_0D
            .quad    PALETTE_0E
            .quad    PALETTE_0F

############################################################################
#                           BSS SECTION                                    #
############################################################################

            # BSS SECTION
            .section .bss

            # WINDOW PAGES
WINDATA:   .space    WIN_COUNT_MAX*WIN_ROWS_MAX*WIN_COLS_MAX*WINCELL_SZ
