############################################################################
#                            CONSTANTS                                     #
############################################################################

            # PIXEL SIZE
            .set   PIXEL_BITSHFT,          2
            .set   PIXEL_SIZE,             (1<<PIXEL_BITSHFT) # 4 BYTES

            # VALUES FOR PIXFMT
            .set   PIXFMT_RGBX32,          0
            .set   PIXFMT_BGRX32,          1

            # FONT SPECS
            .set   FONT_CHAR_WIDTH_BITSHFT,   3
            .set   FONT_CHAR_WIDTH,           (1<<FONT_CHAR_WIDTH_BITSHFT) # 8 PIXELS
            .set   FONT_CHAR_HEIGHT_BITSHFT,  4
            .set   FONT_CHAR_HEIGHT,          (1<<FONT_CHAR_HEIGHT_BITSHFT) # 16 PIXELS
            .set   FONT_CHAR_TOTSIZE_BITSHFT, (FONT_CHAR_WIDTH_BITSHFT+FONT_CHAR_HEIGHT_BITSHFT)
            .set   FONT_CHAR_TOTSIZE,         (1<<FONT_CHAR_TOTSIZE_BITSHFT) # 128 PIXELS

            # COLOURS
            .set   CLR_BLACK,              0x00
            .set   CLR_BLUE,               0x01
            .set   CLR_GREEN,              0x02
            .set   CLR_CYAN,               0x03
            .set   CLR_RED,                0x04
            .set   CLR_MAGENTA,            0x05
            .set   CLR_YELLOW,             0x06
            .set   CLR_WHITE,              0x07
            .set   CLR_LIGHT_BLACK,        0x08
            .set   CLR_LIGHT_BLUE,         0x09
            .set   CLR_LIGHT_GREEN,        0x0A
            .set   CLR_LIGHT_CYAN,         0x0B
            .set   CLR_LIGHT_RED,          0x0C
            .set   CLR_LIGHT_MAGENTA,      0x0D
            .set   CLR_LIGHT_YELLOW,       0x0E
            .set   CLR_LIGHT_WHITE,        0x0F

            # WINDOW MAXIMA
            .set   WIN_COUNT_MAX,          10
            .set   WIN_COLS_MAX,           128
            .set   WIN_ROWS_MAX,           32
            .set   WIN_CLR_MAX,            0x10

############################################################################
#                       TERMINAL CONFIGURATION                             #
############################################################################

            # TERMINAL RESOLUTION
            .set   RESOLUTION_WIDTH,       640
            .set   RESOLUTION_HEIGHT,      480
            .set   RESOLUTION_PIXFMT,      PIXFMT_BGRX32

            # COLOUR PALETTE
            .set   PALETTE_00,             0x00000000    # 0x00: BLACK
            .set   PALETTE_01,             0x000000AA    # 0x01: BLUE
            .set   PALETTE_02,             0x0000AA00    # 0x02: GREEN
            .set   PALETTE_03,             0x0000AAAA    # 0x03: CYAN
            .set   PALETTE_04,             0x00AA0000    # 0x04: RED
            .set   PALETTE_05,             0x00AA00AA    # 0x05: MAGENTA
            .set   PALETTE_06,             0x00AA5500    # 0x06: YELLOW
            .set   PALETTE_07,             0x00AAAAAA    # 0x07: WHITE
            .set   PALETTE_08,             0x00555555    # 0x08: LIGHT BLACK
            .set   PALETTE_09,             0x005555FF    # 0x09: LIGHT BLUE
            .set   PALETTE_0A,             0x0055FF55    # 0x0A: LIGHT GREEN
            .set   PALETTE_0B,             0x0055FFFF    # 0x0B: LIGHT CYAN
            .set   PALETTE_0C,             0x00FF5555    # 0x0C: LIGHT RED
            .set   PALETTE_0D,             0x00FF55FF    # 0x0D: LIGHT MAGENTA
            .set   PALETTE_0E,             0x00FFFF55    # 0x0E: LIGHT YELLOW
            .set   PALETTE_0F,             0x00FFFFFF    # 0x0F: LIGHT WHITE

            # TERMINAL WINDOWS
            .set   WIN_COUNT,              5

            # WINDOW 0 SETTINGS
            .set   WIN0_X,                 0*FONT_CHAR_WIDTH
            .set   WIN0_Y,                 5*FONT_CHAR_HEIGHT
            .set   WIN0_COLS,              80
            .set   WIN0_ROWS,              24
            .set   WIN0_FG,                CLR_LIGHT_YELLOW
            .set   WIN0_BG,                CLR_BLACK
            .set   WIN0_CURS_EN,           1

            # WINDOW 1 SETTINGS
            .set   WIN1_X,                 0*FONT_CHAR_WIDTH
            .set   WIN1_Y,                 0*FONT_CHAR_HEIGHT
            .set   WIN1_COLS,              80
            .set   WIN1_ROWS,              5
            .set   WIN1_FG,                CLR_LIGHT_WHITE
            .set   WIN1_BG,                CLR_BLUE
            .set   WIN1_CURS_EN,           0

            # WINDOW 2 SETTINGS
            .set   WIN2_X,                 0*FONT_CHAR_WIDTH
            .set   WIN2_Y,                 29*FONT_CHAR_HEIGHT
            .set   WIN2_COLS,              60
            .set   WIN2_ROWS,              1
            .set   WIN2_FG,                CLR_LIGHT_YELLOW
            .set   WIN2_BG,                CLR_RED
            .set   WIN2_CURS_EN,           0

            # WINDOW 3 SETTINGS
            .set   WIN3_X,                 60*FONT_CHAR_WIDTH
            .set   WIN3_Y,                 29*FONT_CHAR_HEIGHT
            .set   WIN3_COLS,              18
            .set   WIN3_ROWS,              1
            .set   WIN3_FG,                CLR_BLACK
            .set   WIN3_BG,                CLR_YELLOW
            .set   WIN3_CURS_EN,           0

            # WINDOW 4 SETTINGS
            .set   WIN4_X,                 78*FONT_CHAR_WIDTH
            .set   WIN4_Y,                 29*FONT_CHAR_HEIGHT
            .set   WIN4_COLS,              2
            .set   WIN4_ROWS,              1
            .set   WIN4_FG,                CLR_LIGHT_YELLOW
            .set   WIN4_BG,                CLR_RED
            .set   WIN4_CURS_EN,           0

############################################################################
#                          DATA STRUCTURES                                 #
############################################################################

            # KERNINIT STRUCT
            .set   KERNINIT_FBBASE,     0x00
            .set   KERNINIT_FBSIZE,     0x08
            .set   KERNINIT_FBSCNLN,    0x10
            .set   KERNINIT_FBWIDTH,    0x18
            .set   KERNINIT_FBHEIGHT,   0x20
            .set   KERNINIT_FBPIXFMT,   0x28
            .set   KERNINIT_SZ,         0x30

            # WININFO STRUCT
            .set   WININFO_X,           0x00
            .set   WININFO_Y,           0x02
            .set   WININFO_COLS,        0x04
            .set   WININFO_ROWS,        0x06
            .set   WININFO_FG,          0x08
            .set   WININFO_BG,          0x09
            .set   WININFO_CURS_COL,    0x0A
            .set   WININFO_CURS_ROW,    0x0C
            .set   WININFO_CURS_EN,     0x0E
            .set   WININFO_RSV,         0x0F
            .set   WININFO_SZ,          0x10

            # WINCELL STRUCT
            .set   WINCELL_CHR,         0x00
            .set   WINCELL_RSV,         0x01
            .set   WINCELL_FG,          0x02
            .set   WINCELL_BG,          0x03
            .set   WINCELL_SZ,          0x04
