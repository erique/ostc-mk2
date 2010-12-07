;=============================================================================
;
; file   printf.asm
; brief  Implementation code for the PRINTF macros.
; author JD Gascuel.
;
; copyright (c) 2010, JD Gascuel. All rights reserved.
; $Id: printf.asm 60 2010-11-27 18:40:53Z gascuel $
;=============================================================================
; HISTORY
;  2010-11-17 : [jDG] Creation...
;
; BUGS : repetitive calls to the same CF# color do strange things...

#include printf.inc

; We need to keep the flags. To avoid trouble of memory alloc, put it in
; some register untouched by any called function...
#define		flags	FSR0L

printf_subroutine:
			movff	TBLPTRL, printf_len	; Save bloc start before parsing

			tblrd*+						; Read flags...
			movf	TABLAT,W			; Get flags
			movwf	flags				; and save for later use.

			andlw	3					; Select font bits
			bz		printf_keep_font	; Keep font ? skip setting
			decf	WREG				; Minus one make it font size.
			movff	WREG, win_font

printf_keep_font:
			clrf	WREG				; Normal or invert video ?
			btfsc	flags,2
			movlw	1
			movff	WREG, win_invert

			btfss	flags,3				; Optional Top/Left position ?
			bra		printf_no_position

			tblrd*+						; Copy it...
			movff	TABLAT, win_top
			tblrd*+
			movff	TABLAT, win_leftx2

printf_no_position:
			btfss	flags,4				; Optional RRRGGGBB packed color ?
			bra		printf_no_color8
			tblrd*+
			movff	TABLAT, WREG
			call	PLED_set_color

printf_no_color8:
			btfss	flags,5				; Optional CF color ?
			bra		printf_no_color_cf
			tblrd*+
			movff	TABLAT, WREG
			call	getcustom8_1		; Read CF into WREG
			call	PLED_set_color		; convert it to 16bits into win_color1:2

printf_no_color_cf:
			movf	flags,W				; Should we completely skip string copy/append ?
			andlw	.192
			xorlw	.192				; Is command 192 (no string op) ?
			bz		printf_exec

			btfsc	flags,7				; Don't reset FRS2 index ?
			bra		printf_strcat
			lfsr	FSR2, letter
			bra		printf_loop

printf_strcat:
			movlw	0x60
			cpfslt	FSR2L
			decf	FSR2L

printf_loop:							; Loop over string append byte by byte.
			tblrd*+
			movff	TABLAT, POSTINC2
			tstfsz	TABLAT
			bra		printf_loop

printf_exec:
			movf	printf_len,W		; Get back block start
			subwf	TBLPTRL,W			; Compute block len
			movwf	printf_len			; And backup for inline variante

			movf	flags,W				; Was is a NO-PRINT command ?
			addlw	.64					; DEF/CPY/CAT/PRT ->64/128/192/0
			btfsc	WREG,7				; Test if 128 or 192 ?
			return

	ifdef AAFFONTS
			goto	aa_wordprocessor	; TESTING NEW STRINGWIDTH ROUTINE
	else
			goto	word_processor
	endif

;=============================================================================

printf_inline:
			movff	TOSU, TBLPTRU		; Transfer return addr to Table ptr
			movff	TOSH, TBLPTRH
			movff	TOSL, TBLPTRL

			rcall	printf_subroutine	; Execute command bloc

			movlb	1					; Restore BANK1 after C-code

			; Round-up block length, so to branch to even addr.
			movf	printf_len,W		; Get back block len
			incf	WREG				; Add +1
			andlw	0xFE				; Then clean odd bit

			; Then add len to return address
			addwf	TOSL,F
			movlw	0					; Clear WREG, but keep carry
			addwfc	TOSH,F
			addwfc	TOSU,F
			return
