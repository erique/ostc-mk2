;=============================================================================
;
; file   printf.inc
; brief  Compact macro to print PROM text, with formating options.
; author JD Gascuel.
;
; copyright (c) 2010, JD Gascuel. All rights reserved.
; $Id: printf.inc 37 2010-11-22 03:22:39Z gascuel $
;=============================================================================
; HISTORY
;  2010-11-17 : [jDG] Creation...
;
;=============================================================================
;
; Compact macro to print PROM text, with formating options.
;
; The aim is to allow compact formating code, with formating options, to allow
; smaller footprint in the PROM.
;
; A print block (in PROM space) is used as paramaters. The block starts with
; a set of flags, telling what options are needed.
;
; The block format is :
;	label	DB	flag+flag+flag+...	; A combination of various flags...
;			DB	top, leftx2			; Optional text position.
;			DB  0b1110011			; Optional color in RRRGGGBB format.
;			DB  .35					; Optional CF color (CF35 = standard).
;			DB  "The text string."	; Optional null-terminated text string
;			DB	0
;
; Two usage variantes:
; + The more compact one, use just 4 bytes for the call:
;           code_pack               ; Don't insert nulls 
;           call printf_inline
;     tfAILED   DB  PRINTF_FONT_SMALL + PRINTF_TOPLEFT + PRINTF_COLOR8
;               DB  100, 100
;               DB  color_red
;               DB  "FAILED"
;               DB  0
;           code                    ; back to normal
;
; + A more classic one, but uses 16 bytes to load 24bits address:
;           WIN_PRINTF tFAILED
;
;=============================================================================
; Flags for basic option (no argument):
#define		PRINTF_FONT_KEEP	.0		; Keep last font size. DEFAULT.
#define		PRINTF_FONT_SMALL	.1		; Switch to small font.
#define		PRINTF_FONT_MEDIUM	.2		; Switch to medium font.
#define		PRINTF_FONT_LARGE	.3		; Switch to large font.

#define		PRINTF_INVERT		.4		; Draw in reverse color.

; Flags that requires optional argument:
#define		PRINTF_TOPLEFT		.8		; Set Top/Left text position.
#define		PRINTF_COLOR8		.16		; Change text color to packed RRRGGGBB format.
#define		PRINTF_COLOR_CF		.32		; Change text color to preference CF#

; Flags for final operation
#define		PRINTF_COPY_PRINT	.0		; strcpy() from PROM, then print. DEFAULT.
#define		PRINTF_COPY			.64		; just strcpy(), no final print.
#define		PRINTF_APPEND		.128	; just strcat() (don't reset FSR2 fist), no final print.
#define		PRINTF_PRINT		.192	; no string ops, just final call to print.

;=============================================================================

WIN_PRINTF	macro	bloc
			movlw	UPPER bloc
			movwf	TBLPTRU
			movlw	HIGH bloc
			movwf	TBLPTRH
			movlw	LOW bloc
			movwf	TBLPTRL
			call	printf_subroutine
			endm

