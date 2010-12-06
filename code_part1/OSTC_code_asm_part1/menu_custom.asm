
; OSTC - diving computer code
; Copyright (C) 2008 HeinrichsWeikamp GbR

;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.

;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.

;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <http://www.gnu.org/licenses/>.


; Menu "Custom Functions", Custom Functions checker (Displays permanent warning if critical custom functions are altered)
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 05/10/30
; last updated: 08/08/31
; known bugs:
; ToDo: 

;First Bank of Custom Functions:
; The custom functions are stored in the internal EEPROM after 0x80
; any custom function occupies 4 byte:
; 2 byte (low:high) store the default value, reset from menu "reset"
; if bit16=1 then the custrom function is 15bit value, if not it's a 8bit value
; 2 byte (low:high) store the actual value
; defaults for custom functions are in menu "reset"
; get values with GETCUSTOM8	.x with x=0...32 for 8 Bit values (stored in WREG)
; or with GETCUSTOM15	.x with x=0...32 for 15 Bit values (stored in lo and hi)

;Second Bank of Custom Functions:
; The custom functions are stored in the internal EEPROM after 0x180
; any custom function occupies 4 byte:
; 2 byte (low:high) store the default value, reset from menu "reset"
; if bit16=1 then the custrom function is 15bit value, if not it's a 8bit value
; 2 byte (low:high) store the actual value
; defaults for custom functions are in menu "reset"
; get values with GETCUSTOM8	.x with x=0...32 for 8 Bit values (stored in WREG)
; or with GETCUSTOM15	.x with x=0...32 for 15 Bit values (stored in lo and hi)

; [jDG] 2010-11-30 More fancy displsy of the various CF types
; data types. When we do have a 8bit data (bit16=0), the high byte serves to
; define the display format:

CF_INT8		EQU	0	; Default display, 8 or 15 bits values.
CF_PERCENT	EQU	1	; Displays 110%
CF_DECI		EQU	2	; Displays 1.6
CF_CENTI	EQU	3	; Displays 1.50
CF_MILI		EQU	4	; Displays 1.015
CF_BOOL		EQU	5	; Displays ON/OFF
CF_SEC		EQU	6	; Displays 4:00
CF_COLOR	EQU	7	; Display 240 plus a color watch (inverse video space)
CF_INT15	EQU	0x80; Default display. Flag for 15bit, typeless values.

GETCUSTOM8	macro	custom8
	movlw	custom8
	call	getcustom8_1
	endm

getcustom8_1:
	; # number of requested custom function in wreg
	movwf	customfunction_temp2
	
	movlw	d'31'
	cpfsgt	customfunction_temp2
	bra		getcustom8_2			; Lower bank
	
	movlw	d'1'					; Upper Bank
	movwf	EEADRH
	movlw	d'32'
	subwf	customfunction_temp2,F
	bra		getcustom8_3

getcustom8_2:
	clrf	EEADRH
getcustom8_3:
	movf	customfunction_temp2,W
	mullw	d'4'
	movf	PRODL,W			; x4 for adress
	addlw	d'130'
	movwf	EEADR			; +130 for LOW Byte of value
	call	read_eeprom		; Lowbyte
	movf	EEDATA,W		; copied into wreg
	clrf	EEADRH
	return					; return

GETCUSTOM15	macro	custom15
	movlw	custom15
	call	getcustom15_1
	endm

getcustom15_1:
	; # number of requested custom function in wreg
	movwf	customfunction_temp2
	
	movlw	d'31'
	cpfsgt	customfunction_temp2
	bra		getcustom15_2			; Lower bank
	
	movlw	d'1'					; Upper Bank
	movwf	EEADRH
	movlw	d'32'
	subwf	customfunction_temp2,F
	bra		getcustom15_3
getcustom15_2:
	clrf	EEADRH
getcustom15_3:
	movf	customfunction_temp2,W
	mullw	d'4'
	movf	PRODL,W			; x4 for adress
	addlw	d'130'
	movwf	EEADR			; +130 for LOW Byte of value
	call	read_eeprom		; Lowbyte
	movff	EEDATA,lo
	incf	EEADR,F
	call	read_eeprom		; Highbyte
	movff	EEDATA,hi
	clrf	EEADRH
	return					; return

menu_custom_functions_page2:
	movlw	d'154'			; start of custom function descriptors		
	movwf	customfunction_temp1
	bsf		customfunction_page	; Use Page II...
	bra		menu_custom_functions0

menu_custom_functions:
	movlw	d'36'			; start of custom function descriptors		
	movwf	customfunction_temp1
	bcf		customfunction_page	; Use Page I...
	
menu_custom_functions0:
	bsf		leftbind
	call	PLED_ClearScreen
	movlw	d'1'
	movwf	menupos

	bcf		menubit4
	bcf		cursor
	bcf		sleepmode
	clrf	decodata+0				; here: # of CustomFunction
	clrf	divemins+0				; here: # of CustomFunction*4
	bcf		first_FA				; here: =1: -, =0: +
	bcf		second_FA				; here: =1: stepsize 1, =0: stepsize 10

	call	PLED_topline_box
	WIN_INVERT	.1	; Init new Wordprocessor	

	btfss	customfunction_page		;
	bra		menu_custom_functions10
	DISPLAYTEXT	.186				; Custom FunctionsII
	bra		menu_custom_functions11
	
menu_custom_functions10:
	DISPLAYTEXT	.27					; Custom FunctionsI
	
menu_custom_functions11:
	WIN_INVERT	.0	; Init new Wordprocessor	

menu_custom_functions1:

#ifndef NO_CF_TYPES
	;---- Clear color swatches area ------------------------------------------
	; BEWARE: PLED_box reset the EEADRH register, so t should be
    ; be done before setting CF page I/II...
	clrf	WREG				; Black background
	movff	WREG,box_temp+0		; Set color
	movlw	.125
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.178
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.75
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.150
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_box
#endif
	call	PLED_standard_color

	movlw	d'1'
	btfss	customfunction_page	; Use Page II...
	movlw	d'0'
	movwf	EEADRH

	clrf	timeout_counter2
	bcf		menubit2
	bcf		menubit3
	WIN_LEFT 	.20
	WIN_TOP		.35
	lfsr	FSR2,letter
	movff	decodata+0,lo
	
	movlw	d'0'
	btfsc	customfunction_page			; Add offset for display
	movlw	d'32'
	addwf	lo,F
	movff	lo, apnoe_mins     			; Copy use when NO_CF_TYPES
				
	output_99x
	movlw	':'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	call	word_processor

	movf	customfunction_temp1,W		; start of custom function descriptors		
	addwf	decodata+0,W				; add # of current custom function, place result in wreg
	call	displaytext1				; shows descriptor

	; Read defaults into hi:lo
	movf	divemins+0,W
	addlw	0x80
	movwf	EEADR
	call	read_eeprom					; Lowbyte
	movff	EEDATA,lo
	movf	divemins+0,W
	addlw	0x81
	movwf	EEADR
	call	read_eeprom						; Highbyte
	movff	EEDATA,hi

#ifdef	NO_CF_TYPES
	movlw	binary_cf1
	subwf	apnoe_mins,W						; Binary cf?
	bz		menu_custom_functions10c	; Yes

	movlw	binary_cf2
	subwf	apnoe_mins,W						; Binary cf?
	bz		menu_custom_functions10c	; Yes

	movlw	binary_cf3
	subwf	apnoe_mins,W						; Binary cf?
	bz		menu_custom_functions10c	; Yes

	movlw	binary_cf4
	subwf	apnoe_mins,W						; Binary cf?
	bz		menu_custom_functions10c	; Yes

	movlw	binary_cf5
	subwf	apnoe_mins,W						; Binary cf?
	bz		menu_custom_functions10c	; Yes

	movlw	binary_cf6
	subwf	apnoe_mins,W						; Binary cf?
	bz		menu_custom_functions10c	; Yes

	bra     menu_custom_functions10a    ; Not a binary CF...
#else
	movf	hi,W						; Is it a ON/OFF flag ?
	xorlw	CF_BOOL
	bnz		menu_custom_functions10a	; Not a  binary CF selected
#endif

menu_custom_functions10c:
	setf	apnoe_mins					; Yes, set apnoe_mins to 0xFF

	WIN_LEFT 	.20
	WIN_TOP		.65
	lfsr	FSR2,letter					; Make a string of 8 spaces
	movlw	' '
	movwf	POSTINC2
	movwf	POSTINC2
	movwf	POSTINC2
	movwf	POSTINC2
	movwf	POSTINC2
	movwf	POSTINC2
	movwf	POSTINC2
	movwf	POSTINC2
	call	word_processor				; Clear +/- line

	WIN_TOP		.95
	call	word_processor				; Clear 1/10 line
	bra		menu_custom_functions10b

menu_custom_functions10a:
	clrf	apnoe_mins					; Yes, clear apnoe_mins

	WIN_LEFT 	.20
	WIN_TOP		.65
	lfsr	FSR2,letter
	movlw	'+'
	movwf	POSTINC2
	movlw	'/'
	movwf	POSTINC2
	movlw	'-'
	movwf	POSTINC2
	movlw	':'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	movlw	'+'
	btfsc	first_FA
	movlw	'-'
	movwf	POSTINC2
	call	word_processor		

	WIN_LEFT 	.20
	WIN_TOP		.95
	lfsr	FSR2,letter
	movlw	'1'
	movwf	POSTINC2
	movlw	'/'
	movwf	POSTINC2
	movlw	'1'
	movwf	POSTINC2
	movlw	'0'
	movwf	POSTINC2
	movlw	':'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	movlw	'1'
	movwf	POSTINC2
	movlw	'0'
	btfsc	second_FA
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	call	word_processor		

menu_custom_functions10b:
	WIN_LEFT 	.20
	WIN_TOP		.125
	lfsr	FSR2,letter
	OUTPUTTEXT	d'89'				;"Default:"
	movlw	' '
	movwf	POSTINC2

	call	display_customfunction	; Typed display.

	WIN_LEFT 	.20
	WIN_TOP		.155
	lfsr	FSR2,letter
	OUTPUTTEXT	d'97'				; "Current:"
	movlw	' '
	movwf	POSTINC2

	movf	divemins+0,W
	addlw	0x82
	movwf	EEADR
	call	read_eeprom				; Lowbyte
	movff	EEDATA,lo

	movf	divemins+0,W
	addlw	0x83
	movwf	EEADR
	call	read_eeprom				; Highbyte

	btfss	hi,7					; A 15bit value ?
	bra		menu_custom_functions1b	; No : keep types there !

	movff	EEDATA,hi
	bsf		hi,7					; Mark it a 15bit value.

menu_custom_functions1b:
	call	display_customfunction

menu_custom_functions1a:
	DISPLAYTEXT	.11					; Exit

	call	wait_switches		; Waits until switches are released, resets flag if button stays pressed!
	call	PLED_menu_cursor

customfunctions_loop:
	call	check_switches_logbook

	btfsc	menubit3
	bra	customfunctions2		; Move cursor or generate next page

	btfsc	menubit2
	bra	do_customfunction		; call subfunction

	btfsc	divemode
	goto	restart					; dive started during cf menu

	btfsc	onesecupdate
	call	timeout_surfmode

	btfsc	onesecupdate
	call	set_dive_modes

	bcf		onesecupdate			; end of 1sek. tasks

	btfsc	sleepmode
	bra	exit_customfunctions

	bra	customfunctions_loop

customfunctions2:
	incf	menupos,F
	movlw	d'7'
	cpfseq	menupos					; =7?
	bra		customfunctions3		; No
	movlw	d'1'
	movwf	menupos

customfunctions3:
	clrf	timeout_counter2
	call	PLED_menu_cursor
	
	call	wait_switches		; Waits until switches are released, resets flag if button stays pressed!

	bcf		menubit3				; clear flag
	bra		customfunctions_loop

;-----------------------------------------------------------------------------
; Input : hi:lo = data to display, with type embebed into hi
;         FSR2  = current string pointer.
; Trash : FSR1 (used to backup EEADRH and hi)

display_customfunction:
#ifndef NO_CF_TYPES
	movff	EEADRH, FSR1H		; Backup...
	movff	hi, FSR1L

	;---- decode type --------------------------------------------------------
	movf	hi,W				; Just set N/Z flags
	bn		cf_type_0			; Keep 15bits value in old format.
	bz		cf_type_99			; 8bit standard mode

	; Jump table:
	dcfsnz	hi
	bra		cf_type_01
	dcfsnz	hi
	bra		cf_type_02
	dcfsnz	hi
	bra		cf_type_03
	dcfsnz	hi
	bra		cf_type_04
	dcfsnz	hi
	bra		cf_type_05
	dcfsnz	hi
	bra		cf_type_06
	dcfsnz	hi
	bra		cf_type_07
	bra		cf_type_99			; Default to 8bit mode...

cf_type_01:						; Type == 1 is percent mode
	output_16dp	0				; NOTE : hi is already reseted...
	movlw	'%'
	movwf	POSTINC2
	bra		cf_done

cf_type_02:						; Type == 2 is deci mode.
	output_16dp	4
	bra		cf_done

cf_type_03:						; Type == 3 is centi mode.
	output_16dp	3
	bra		cf_done

cf_type_04:						; Type == 4 is mili mode
	output_16dp	2
	bra		cf_done

cf_type_05:						; Type == 5 is on/off mode.
	movf	lo,W				; Get flag value...
	bz		cf_type_off
	OUTPUTTEXT	d'130'			; ON
	bra		cf_done
cf_type_off:
	OUTPUTTEXT	d'131'			; OFF
	bra		cf_done

cf_type_06:						; Type == 6 is mm:ss mode (... or hh:mm)
	call	convert_time		; Convert to min:sec into hi:low.
	movff	lo,wp_temp			; Save seconds,
	movff	hi,lo				; Get minutes
	output_8					; Print them
	movlw	':'					; Separator
	movwf	POSTINC2
	movff	wp_temp,lo			; Get back seconds
	output_99x					; lo in 2 digits with trailing zeros.
	bra		cf_done

cf_type_07:						; Type == 7 is Color swatch.
	output_8

	movf	lo,W				; Get color.
	movff	WREG,box_temp+0		; Set color
	movff	win_top,WREG		; BEWARE : this is a bank0 variable !
	movff	WREG,box_temp+1		; row top (0-239)
	addlw	.23
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.110
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.140	
	movff	WREG,box_temp+4		; column right (0-159)

	call	PLED_box
	bra		cf_done				; W/o trailling spaces...

cf_type_99:						; 8bit mode. Or unrecognized type...
	clrf	hi

cf_type_0:						; 15bit mode.
	bcf		hi,7
	output_16

cf_done:
	movff	FSR1L, hi			; Restore saved registers...
	movff	FSR1H, EEADRH
#else
	bcf		hi,7				; clear Bit 7 of value
	output_16

	movff	win_top,WREG		; Get "Default:" line position (BANK0 !)
	xorlw	.125				; This is the default value ?
	bnz		cf_no_bits			; NO: skip bits for current value

	movlw	','
	movwf	POSTINC2

	movlw	'1'
	btfss	EEDATA,7			; 15Bit?
	movlw	'8'					; 8Bit!
	tstfsz  apnoe_mins			; apnoe_mins=0?
	movlw	'1'					; No, 1Bit!
	movwf	POSTINC2

	movlw	'5'
	btfsc	EEDATA,7			; 15Bit?
	movwf	POSTINC2
	movlw	'B'
	movwf	POSTINC2

cf_no_bits:
	movlw	' '
	movwf	POSTINC2
	movwf	POSTINC2
	movwf	POSTINC2
#endif
	goto	word_processor		

;-----------------------------------------------------------------------------

do_customfunction:
	CLRF	EEADRH					
	movlw	d'1'
	btfsc	customfunction_page
	movwf	EEADRH					; Reset EEADRH correct (Was adjusted in check_timeout...)

	dcfsnz	menupos,F
	bra		next_customfunction
	dcfsnz	menupos,F
	bra		toggle_plusminus
	dcfsnz	menupos,F
	bra		toggle_oneorten
	dcfsnz	menupos,F
	bra		restore_cfn_value
	dcfsnz	menupos,F
	bra		adjust_cfn_value
exit_customfunctions:
	movlw	d'2'					; Return to correct list entry
	btfss	customfunction_page
	movlw	d'1'
	movwf	menupos					; 
	clrf	EEADRH					; Clear EEADRH !
	goto	setup_menu2				; exit...


next_customfunction:
	incf	decodata+0
	btfsc	decodata+0,5			;>31?
	clrf	decodata+0				;Yes, so reset to zero
	
	movf	decodata+0,W
	mullw	d'4'
	movff	PRODL, divemins+0		;divemins+0 for correct addressing

	movlw	d'1'
	movwf	menupos
	bra		menu_custom_functions1	; also debounces switches

toggle_plusminus:
	btg		first_FA
	movlw	d'2'
	movwf	menupos
	bra		menu_custom_functions1	; also debounces switches

toggle_oneorten:
	btg		second_FA
	movlw	d'3'
	movwf	menupos
	bra		menu_custom_functions1	; also debounces switches

restore_cfn_value:
	movf	divemins+0,W			; read default value
	addlw	0x80
	movwf	EEADR
	call	read_eeprom				; Lowbyte
	movff	EEDATA,lo
	movf	divemins+0,W
	addlw	0x81
	movwf	EEADR
	call	read_eeprom				; Highbyte
	movff	EEDATA,hi
	bcf		hi,7					; clear bit 7 of value

	movf	divemins+0,W			; store default value
	addlw	0x82
	movwf	EEADR
	movff	lo,EEDATA
	call	write_eeprom			; Lowbyte
	movf	divemins+0,W
	addlw	0x83
	movwf	EEADR
	movff	hi,EEDATA
	call	write_eeprom			; Highbyte

	movlw	d'4'
	movwf	menupos
	bra		menu_custom_functions1	; also debounces switches

adjust_cfn_value:
	movf	divemins+0,W			; get current value
	addlw	0x82
	movwf	EEADR
	call	read_eeprom				; Lowbyte
	movff	EEDATA,lo
	movf	divemins+0,W
	addlw	0x83
	movwf	EEADR
	call	read_eeprom				; Highbyte
	movff	EEDATA,hi

	movf	divemins+0,W
	addlw	0x81
	movwf	EEADR
	call	read_eeprom				; Highbyte
	movff	EEDATA,divemins+1		; Highbyte of default value

	btfss	apnoe_mins,0			; If apnoe_mins=1 then CF is binary
	bra		adjust_cfn_value1		; Not Binary

	tstfsz	lo				; =0?
	setf	lo				; No, Set to 255
	incf	lo,F			; Increase by one
	clrf	hi				; Delete hi byte (Not required but to make sure...)
	bra		adjust_cfn_value3		; Store result

adjust_cfn_value1:
	btfss	first_FA				; Minus?
	bra		adjust_cfn_value2		; No, Plus

	movlw	d'1'
	btfsc	second_FA				; -10?
	movlw	d'10'
	
	subwf	lo,F					; substract value
	movlw	d'0'
	btfsc	divemins+1,7			; 8Bit value
	subwfb	hi,F

	movlw	b'01111111'
	btfsc	hi,7					; >32768?
	movwf	hi						

	bra		adjust_cfn_value3
	
adjust_cfn_value2:
	movlw	d'1'
	btfsc	second_FA				; +10?
	movlw	d'10'
	
	addwf	lo,F					; add value
	movlw	d'0'
	btfsc	divemins+1,7			; 8Bit value?
	addwfc	hi,F

	btfsc	hi,7					; >32768?
	clrf	hi

adjust_cfn_value3:
	movf	divemins+0,W			; Store current value
	addlw	0x82
	movwf	EEADR
	movff	lo,EEDATA
	call	write_eeprom			; Lowbyte
	movf	divemins+0,W
	addlw	0x83
	movwf	EEADR
	movff	hi,EEDATA
	call	write_eeprom			; Highbyte 
	movlw	d'5'
	movwf	menupos
	bra		menu_custom_functions1	; also debounces switches

getcustom15_default:
	; # number of requested custom function in wreg
	movwf	customfunction_temp2
	
	movlw	d'31'
	cpfsgt	customfunction_temp2
	bra		getcustom15_d2			; Lower bank
	
	movlw	d'1'					; Upper Bank
	movwf	EEADRH
	movlw	d'32'
	subwf	customfunction_temp2,F
	bra		getcustom15_d3
getcustom15_d2:
	clrf	EEADRH
getcustom15_d3:
	movf	customfunction_temp2,W
	mullw	d'4'
	movf	PRODL,W			; x4 for adress
	addlw	d'128'
	movwf	EEADR			; +130 for LOW Byte of value
	call	read_eeprom		; Lowbyte
	movff	EEDATA,lo
	incf	EEADR,F
	call	read_eeprom		; Highbyte
	movff	EEDATA,hi
	clrf	EEADRH
#ifndef NO_CF_TYPES
	btfss	hi,7			; Is it a 15bit value ?
	clrf	hi				; NO: clear type flags.
#endif
	bcf		hi,7			; Always clear 15bit flag.
	return					; return

custom_functions_check_divemode:			;displays warning if a critical custom function is not set to default
	dcfsnz	cf_checker_counter,F			; counts custom functions to check for warning symbol
	bra		check_cf11
	dcfsnz	cf_checker_counter,F			; counts custom functions to check for warning symbol
	bra		check_cf12
	return

custom_functions_check_surfmode:			;displays warning if a critical custom function is not set to default
	dcfsnz	cf_checker_counter,F			; counts custom functions to check for warning symbol
	bra		check_cf11
	dcfsnz	cf_checker_counter,F			; counts custom functions to check for warning symbol
	bra		check_cf12
	dcfsnz	cf_checker_counter,F			; counts custom functions to check for warning symbol
	bra		check_cf17
	dcfsnz	cf_checker_counter,F			; counts custom functions to check for warning symbol
	bra		check_cf18
	dcfsnz	cf_checker_counter,F			; counts custom functions to check for warning symbol
	bra		check_cf19
	dcfsnz	cf_checker_counter,F			; counts custom functions to check for warning symbol
	bra		check_cf29
	dcfsnz	cf_checker_counter,F			; counts custom functions to check for warning symbol
	bra		check_cf32
	dcfsnz	cf_checker_counter,F			; counts custom functions to check for warning symbol
	bra		check_cf33
	return

check_cf11:
	movlw	d'11'					; saturation factor
	rcall	custom_function_check_low	; compares current with default value
	call	test_and_display_warning	; displays the warning if the custom function is not correct
	movlw	d'2'						; next in testing row
	movwf	cf_checker_counter			; 
	return

check_cf12:
	movlw	d'12'					; desaturation factor
	rcall	custom_function_check_high	; compares current with default value
	call	test_and_display_warning	; displays the warning if the custom function is not correct
	movlw	d'3'						; next in testing row
	movwf	cf_checker_counter			; 
	return

check_cf17:
	movlw	d'17'					; lower threshold ppO2
	rcall	custom_function_check_low	; compares current with default value
	call	test_and_display_warning	; displays the warning if the custom function is not correct
	movlw	d'4'						; next in testing row
	movwf	cf_checker_counter			; 
	return

check_cf18:
	movlw	d'18'					; upper threshold ppO2
	rcall	custom_function_check_high	; compares current with default value
	call	test_and_display_warning	; displays the warning if the custom function is not correct
	movlw	d'5'						; next in testing row
	movwf	cf_checker_counter			; 
	return

check_cf19:
	movlw	d'19'					; upper threshold ppO2 display
	rcall	custom_function_check_high	; compares current with default value
	call	test_and_display_warning	; displays the warning if the custom function is not correct
	movlw	d'6'						; next in testing row
	movwf	cf_checker_counter			; 
	return

check_cf29:
	movlw	d'6'
	movwf	cf_checker_counter		; upper limit for CF29, here: used as a temp variable
	movlw	d'29'					; last deco stop in [m]
	rcall	custom_function_check_high_limit	; compares current with default value
	call	test_and_display_warning			; displays the warning if the custom function is not correct
	movlw	d'7'						; next in testing row
	movwf	cf_checker_counter			; 
	return

check_cf32:
	movlw	d'32'					; GF LOW
	rcall	custom_function_check_high	; compares current with default value
	call	test_and_display_warning			; displays the warning if the custom function is not correct
	movlw	d'8'						; next in testing row
	movwf	cf_checker_counter			; 
	return

check_cf33:
	movlw	d'33'					; GF HIGH
	rcall	custom_function_check_high	; compares current with default value
	call	test_and_display_warning			; displays the warning if the custom function is not correct
	movlw	d'1'						; next in testing row
	movwf	cf_checker_counter			; 
	return


test_and_display_warning:
	movwf	lo						; copy result
	tstfsz	lo
	return							; CF OK
	goto	custom_warn_surfmode

custom_function_check_low:					; Checks CF (#WREG)
											; Returns WREG=0 if CF is lower then default
	movwf	temp1							; save for custom value
	call	getcustom15_1					; Get Current Value stored in hi and lo
	movff	lo,sub_a+0
	movff	hi,sub_a+1						; save value
	
	movf	temp1,w
	call	getcustom15_default				; Get Default value stored in hi and lo
	movff	lo,sub_b+0
	movff	hi,sub_b+1						; save value
	call	sub16							; sub_c = sub_a - sub_b with "neg_flag" bit set if sub_b > sub_a
	btfss	neg_flag						; negative?
	retlw	.255							; no
	retlw	.0								; yes

custom_function_check_high:					; Checks CF (#WREG)
											; Returns WREG=0 if CF is higher then default
	movwf	temp1							; save for custom value
	call	getcustom15_1					; Get Current Value stored in hi and lo
	movff	lo,sub_b+0
	movff	hi,sub_b+1						; save value
	
	movf	temp1,w
	call	getcustom15_default				; Get Default value stored in hi and lo
	movff	lo,sub_a+0
	movff	hi,sub_a+1						; save value
	call	sub16							; sub_c = sub_a - sub_b with "neg_flag" bit set if sub_b > sub_a
	btfss	neg_flag						; negative?
	retlw	.255							; no
	retlw	.0								; yes

custom_function_check_high_limit:			; Checks if CF (#WREG) is lower then limit (#cf_checker_counter)
	movwf	temp1							; save for custom value
	call	getcustom15_1					; Get Current Value stored in hi and lo
	movff	lo,sub_b+0
	movff	hi,sub_b+1						; save value
	movff	cf_checker_counter, sub_a+0
	clrf	sub_a+1
	call	sub16							; sub_c = sub_a - sub_b with "neg_flag" bit set if sub_b > sub_a
	btfss	neg_flag						; negative?
	retlw	.255							; no
	retlw	.0								; yes