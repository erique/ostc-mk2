;////////////////////////////////////////////////////////////////////////////
;
; file   printf.inc
; brief  Compact macro to print PROM text, with formating options.
; author JD Gascuel.
;
; copyright (c) 2010, JD Gascuel. All rights reserved.
; $Id: test_printf.asm 72 2010-11-29 22:45:12Z gascuel $
;//////////////////////////////////////////////////////////////////////////////
; HISTORY
;  2010-11-17 : [jDG] Creation...
;

;=============================================================================
; test font screen

test_printf	code_pack
test_printf:		
			call	PLED_ClearScreen

			call	printf_inline
				DB	PRINTF_FONT_SMALL + PRINTF_TOPLEFT + PRINTF_COLOR8
				DB	.4, .2		; top, leftx2
				DB	0xFF		; White
				DB	" !\"#$%&'()*+,-;/"
				DB 0,0

			call	printf_inline
				DB	PRINTF_INVERT + PRINTF_TOPLEFT + PRINTF_COLOR8
				DB	.30, .2		; top, leftx2
				DB	0xE0		; Red
				DB  "0123456789:;<=>?"
				DB	0,0

			call	printf_inline
				DB	PRINTF_TOPLEFT + PRINTF_COLOR8
				DB	.56, .2		; top, leftx2
				DB	0x1C		; Green
				DB	"@ABCDEFGHIJKLMNO"
				DB	0,0
	
			call	printf_inline
				DB	PRINTF_INVERT + PRINTF_TOPLEFT + PRINTF_COLOR8
				DB	.82, .2		; top, leftx2
				DB	0x03		; Blue
				DB	"PQRSTUVWXYZ[\\]^_"
				DB	0,0
	
			call	printf_inline
				DB	PRINTF_TOPLEFT + PRINTF_COLOR8
				DB	.108, .2	; top, leftx2
				DB	0x1F		; Cyan
				DB	"`abcdefghijklmno"
				DB 	0,0
		
			call	printf_inline
				DB	PRINTF_TOPLEFT + PRINTF_COLOR8
				DB	.134, .2	; top, leftx2
				DB	0xE3		; Magenta
				DB	"pqrstuvwxyz{|}~¤"
				DB 	0,0

			call	printf_inline
				DB	PRINTF_TOPLEFT + PRINTF_COLOR8
				DB	.160, .2	; top, leftx2
				DB	0xFC		; Yellow
				DB	"°", 0xB7
				DB	0x01, ' '
				DB	0x1F, ' '
				DB	0x84, ' '
				DB	0xFF, ' '
				DB 	0,0

			;=================================================================
			call 	wait_page

			call	printf_inline
				DB	PRINTF_FONT_MEDIUM + PRINTF_TOPLEFT + PRINTF_COLOR8
				DB	.4, .4	; top, leftx2
				DB	0xFF		; White
				DB	"{/.01234567/}" 
				DB	0

			call	printf_inline
				DB	PRINTF_INVERT + PRINTF_FONT_MEDIUM + PRINTF_TOPLEFT
				DB	.36, .4	; top, leftx2
				DB "[/890:'\"m /]"
				DB	0

			call	printf_inline
				DB	PRINTF_INVERT + PRINTF_FONT_LARGE + PRINTF_TOPLEFT
				DB	.68, .4
				DB	"123456"
				DB	0

			call	printf_inline
				DB	PRINTF_INVERT + PRINTF_FONT_LARGE + PRINTF_TOPLEFT
				DB	.124, .4
				DB	"789. "
				DB	0,0

			return

; Back to auto-aligned code:
post_test	code