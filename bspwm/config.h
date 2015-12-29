/* The height of the bar (in pixels) */
#define BAR_HEIGHT  18
/* The width of the bar. Set to -1 to fit screen */
#define BAR_WIDTH   -1
/* Offset from the left. Set to 0 to have no effect */
#define BAR_OFFSET  0
/* Choose between an underline or an overline */
#define BAR_UNDERLINE 1
/* The thickness of the underline (in pixels). Set to 0 to disable. */
#define BAR_UNDERLINE_HEIGHT 2
/* Default bar position, overwritten by '-b' switch */
#define BAR_BOTTOM 0
/* The fonts used for the bar, comma separated. Only the first 2 will be used. */
/*#define BAR_FONT       "-*-terminus-medium-r-normal-*-12-*-*-*-c-*-*-1","fixed" */
//#define BAR_FONT "-*-uushi-medium-r-normal-*-*-*-*-*-*-*-*-*", "fixed"
/*#define BAR_FONT "-*-tewi-medium-*-*-*-*-*-*-*-*-*-*-*", "fixed"*/
#define BAR_FONT "-misc-stlarch-medium-r-normal--10-100-75-75-c-80-iso10646-1", "-lucy-tewi-medium-r-normal--11-90-75-75-p-58-iso10646-1"

/* Some fonts don't set the right width for some chars, pheex it */
#define BAR_FONT_FALLBACK_WIDTH 6
/* Define the opacity of the bar (requires a compositor such as compton) */
#define BAR_OPACITY 0.95 /* 0 is invisible, 1 is opaque */

/* Color palette */
//#define BACKGROUND 0x151515
//#define BACKGROUND 0x232c31
#define BACKGROUND 0x000000
#define COLOR0 0x2D3C46
#define COLOR1 0xFF005B         //red
#define COLOR2 0xFFE755         //yellow
#define COLOR3 0xFF9F00         //orange
#define COLOR4 0x48C6FF         //light blue
#define COLOR5 0xBE67E1         //magenta
#define COLOR6 0xCCFF00         //green
//#define COLOR7 0xB0B0B00         //light grey
//#define COLOR8 0x505050E         //darker grey
//#define COLOR7 0x6c7a80         //light grey
#define COLOR7 0xe5e5e5         //light grey
#define COLOR8 0x425059         //darker grey
#define COLOR9 0xff00a0         //pink
#define FOREGROUND 0xc5c8c6

/* Mouse button to react to */
#define MOUSE_BUTTON 1
