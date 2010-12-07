;=============================================================================
;
; file   aa_tests.asm
; brief  Draw various OSTC MK2 menus.
; author JD Gascuel.
;
; copyright (c) 2010, JD Gascuel. All rights reserved.
; $Id$
;=============================================================================
; HISTORY
;  2010-11-29 : [jDG] Reset, for TESTING=1 mode...
;
; BUGS:
;

battery_eedata:
	DB		0xB8, 0x0B,  .12,  .31,  .10, 0xB4, 0x01,  .12
	DB		 .31,  .10, 0x2C, 0x01, 0x96, 0x00, 0x00, 0x00
	DB		 .12,  .31,  .10, 0xE7, 0x03,  .12,  .31,  .10
battery_eedata_end:

    ;=========================================================================

test_menus:
	call	PLED_confirmbox
	movwf	WREG						; NOP, but set Z
	bz		skip_fonts
	call	test_printf
	rcall	wait_page

skip_fonts:
	movlw	0xFC						; Reset ambiant pres to 1015 mBar
	movwf	D1+0
	movlw	0x21
	movwf	D1+1
	movff	D1+0, amb_pressure+0
	movff	D1+1, amb_pressure+1

	movlw	0x48						; Reset temperature ~ 19°C
	movwf	D2
	movlw	0x26
	movwf	D2+1

	call	do_menu_reset_all2			; Force reset all CFxx

	return

    ;=========================================================================

wait_page:
	bcf		switch_left
	bcf		switch_right

wait_page_loop:
	bsf		LED_red		; Set it many times, better for OLEDSim...
	bsf		LED_blue

	WAITMS	.250
	WAITMS	.250
	btfsc	switch_right
	bra		wait_page_done

	WAITMS	.250
	WAITMS	.250
	btfss	switch_left
	bra		wait_page_loop

wait_page_done:
	bcf		LED_red
	bcf		LED_blue

	bcf		switch_left
	bcf		switch_right
	goto	PLED_ClearScreen
	