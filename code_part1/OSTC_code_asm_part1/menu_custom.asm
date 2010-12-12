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
; last updated: 2010/12/11
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
; define the display format. Also stores min/max bounds into the PROM table.
; And provides surfacemode checking of all parameters.

CF_INT8		EQU	0	; Default display, 8 or 15 bits values.
CF_PERCENT	EQU	1	    ; Displays 110%
CF_DECI		EQU	2	    ; Displays 1.6
CF_CENTI	EQU	3	    ; Displays 1.50
CF_MILI		EQU	4	    ; Displays 1.015
CF_BOOL		EQU	5	    ; Displays ON/OFF
CF_SEC		EQU	6	    ; Displays 4:00
CF_COLOR	EQU	7	    ; Display 240 plus a color watch (inverse video space)
;
CF_TYPES    EQU 0x1F    
CF_MAX_BIT  EQU 6       ; Default is the highest safe value.
CF_MAX      EQU (1<<CF_MAX_BIT)
CF_MIN_BIT  EQU 5       ; Default is the lowest safe value.
CF_MIN      EQU (1<<CF_MIN_BIT)
;
CF_INT15	EQU	0x80; Default display. Flag for 15bit, typeless values.

; Overlay our tmp data with some unused variables. But use more
; meaningfull labels...
cf32_x4     EQU divemins+0      ; CF# modulus 32, time 4.
cf_type     EQU divemins+1      ; Type of the edited CF
cf_value    EQU divesecs
cf_min      EQU apnoe_mins
cf_max      EQU apnoe_secs
            
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
	clrf	cf32_x4                 ; here: # of CustomFunction*4
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
	movff	decodata+0,lo               ; decodata == CF number % 32

	movlw	d'0'
	btfsc	customfunction_page			; Add offset for display in CF menu II
	movlw	d'32'
	addwf	lo,F

	output_99x
	movlw	':'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	call	word_processor

	movf	customfunction_temp1,W		; start of custom function descriptors		
	addwf	decodata+0,W				; add # of current custom function, place result in wreg
	call	displaytext1				; shows descriptor

; Read default, type and min/max from reset table.
    rcall    cf_read_default

	movf	cf_type,W					; Is it a ON/OFF flag ?
	xorlw	CF_BOOL
	bnz		menu_custom_functions10a	; Not a  binary CF selected

menu_custom_functions10c:
    ; Erase unused lines when editing boolean...
	WIN_LEFT 	.20
	WIN_TOP		.65
	lfsr	FSR2,letter					; Make a string of 8 spaces
	call    cf_fill_line
	call	word_processor				; Clear +/- line

	WIN_TOP		.95
	call	word_processor				; Clear 1/10 line
 
	bra		menu_custom_functions10b

menu_custom_functions10a:
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

	call	display_customfunction	; Typed display.

	WIN_LEFT 	.20
	WIN_TOP		.155
	lfsr	FSR2,letter
	OUTPUTTEXT	d'97'				; "Current:"

	movf	cf32_x4,W
	addlw	0x82
	movwf	EEADR
	call	read_eeprom				; Lowbyte
	movff	EEDATA,lo
	movff   EEDATA, cf_value        ; Backup low 8bit value.

	movf	cf32_x4,W
	addlw	0x83
	movwf	EEADR
	call	read_eeprom				; Highbyte
	movff	EEDATA,hi

	call	display_customfunction

; End of mask: min/max and the exit line...
	rcall display_minmax
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
	movf    cf_type,W               ; Are we editing a boolean value ?
	xorlw   CF_BOOL
	bnz     customfunctions2a       ; NO : don't skip lines 2/3.
	
	movlw   d'4'                    ; Just after increment,
	cpfsgt  menupos                 ; Is current position < 4 ?
	movwf   menupos                 ; NO: skip set to 4.

customfunctions2a:
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
; Read default value, type, and constraints
;
; Input: customfunction_page, cf32_x4
; Output: hi:lo, cf_type, cf_min, cf_max.
; Trashes: TBLPTR

cf_read_default:
    movlw   LOW(cf_default_table0)      ; Get 24bit PROM pointer. SKIP 
    movwf   TBLPTRL
    movlw   HIGH(cf_default_table0)
    movwf   TBLPTRH
    movlw   UPPER(cf_default_table0)
    movwf   TBLPTRU

    movlw   0
	btfsc	customfunction_page	        ; Page II CF# ?
	movlw   0x80                        ; YES: add 128 to ptr.
	addwf   cf32_x4,W                   ; Add 4 x (CF index modulus 32)
    addwf   TBLPTRL,F                   ; And to a 8+16 add into TBLPTR
    movlw   0                           ; (keep carry)
    addwfc  TBLPTRH,F                   ; Propagate to 16bit (but not 24bits).

    tblrd*+
    movff   TABLAT,lo                   ; Low byte --> lo
    tblrd*+
    movff   TABLAT,hi                   ; High byte --> hi
    btfss   hi,7                        ; 15bit ?
    clrf    hi                          ; NO: clear extra type flags
    bcf     hi,7                        ; clear 15bit flag
    
    movff   TABLAT,cf_type              ; type (high byte) --> cf_type

    tblrd*+
    movff   TABLAT,cf_min               ; Then get optional min/max
    tblrd*+
    movff   TABLAT,cf_max

    return

;-----------------------------------------------------------------------------
; Display a 8/15bit value, plus optional min and max bound.
; Input : hi:lo = data to display.
;         cf_type = the type.
;         cf_min, cf_max : the optional min/max.
;         FSR2  = current string pointer.
; Trash : hi:lo (when displaying min/max)

display_customfunction:
	movff	EEADRH, FSR1H		; Backup...

	rcall   display_formated
    rcall   cf_fill_line
	call	word_processor

	movff	FSR1H, EEADRH
	return

;-----------------------------------------------------------------------------
; Display optional min/max values.
; Inputs: cf_value, cf_min, cf_max (and cf_type to display min/max).
; Trashed: hi:lo while display min and max values.
display_minmax:
; Min/max unsupported for 15bit values yet...
    btfsc   cf_type,7           ; A 15bit value ?
    return

	movff	EEADRH, FSR1H		; Backup...

; Display min line
    WIN_TOP  .65
    WIN_LEFT .100
    lfsr    FSR2, letter

    btfss   cf_type, CF_MIN_BIT ; A min value exists ?
    bra     cf_no_min

    movf    cf_min,W            ; Retrieve current 8b value
    subwf   cf_value,W          ; Compute (lo-min)
    bc     cf_min_passed        ; Ok if CARRY, ie. min >= lo
    call    PLED_warnings_color
    WIN_INVERT  1
cf_min_passed:
    
    movlw   '>'                 ; A min value follows
    movwf   POSTINC2
    movlw   ' '
    movwf   POSTINC2
    movff   cf_min, lo
    rcall   display_formated

cf_no_min:
    rcall   cf_fill_line        ; Fill buffer
    lfsr    FSR2, letter+.7     ; Limit to 8 chars btw.
	call	word_processor

; Display max line
    WIN_TOP  .95
    call    PLED_standard_color
    WIN_INVERT 0
    lfsr    FSR2, letter

    btfss   cf_type, CF_MAX_BIT ; A max value exists ?
    bra     cf_no_max

    movf    cf_value,W          ; Retrieve current max bound
    subwf   cf_max,W            ; Compute (max-lo)
    bc     cf_max_passed        ; Ok if no carry, ie. max <= lo
    call    PLED_warnings_color
    WIN_INVERT  1
cf_max_passed:
    
    movlw   '<'                 ; A max value follows
    movwf   POSTINC2
    movlw   ' '
    movwf   POSTINC2
    movff   cf_max, lo
    rcall   display_formated

cf_no_max:
    rcall   cf_fill_line        ; Fill buffer
    lfsr    FSR2, letter+.7     ; Limit to 8 chars btw.
	call	word_processor

cf_minmax_done:
    call    PLED_standard_color
    WIN_INVERT  0
	movff	FSR1H, EEADRH
	return

;-----------------------------------------------------------------------------
; Display a single 8/15 bit value, according to cf_type.
; Input : hi:lo = data to display.
;         cf_type = the type.
;         cf_min, cf_max : the optional min/max.
;         FSR2  = current string pointer.
display_formated:

	;---- decode type --------------------------------------------------------
	movf	cf_type,W			; Just set N/Z flags
	bn		cf_type_neg			; Keep 15bits value in old format.
	andlw   CF_TYPES            ; Look just at types
	bz		cf_type_00			; 8bit standard mode

	; Jump table:               ; test the value with cleared flags...
	dcfsnz	WREG
	bra		cf_type_01
	dcfsnz	WREG
	bra		cf_type_02
	dcfsnz	WREG
	bra		cf_type_03
	dcfsnz	WREG
	bra		cf_type_04
	dcfsnz	WREG
	bra		cf_type_05
	dcfsnz	WREG
	bra		cf_type_06
	dcfsnz	WREG
	bra		cf_type_07
	bra		cf_type_00			; Default to 8bit mode...

cf_type_01:						; Type == 1 is CF_PERCENT mode
    bcf     leftbind
	output_8
	movlw	'%'
	movwf	POSTINC2
	retlw   0

cf_type_02:						; Type == 2 is CF_DECI mode.
    clrf    hi
    bsf     leftbind
	output_16dp	4
	retlw   0

cf_type_03:						; Type == 3 is CF_CENTI mode.
    clrf    hi
    bsf     leftbind
	output_16dp	3
	retlw   0

cf_type_04:						; Type == 4 is CF_MILI mode
	output_16dp	2
	retlw   0

cf_type_05:						; Type == 5 is CF_BOOL mode.
	movf	lo,W				; Get flag value...
	bz		cf_type_off
	OUTPUTTEXT	d'130'			; ON
	retlw   0

cf_type_off:
	OUTPUTTEXT	d'131'			; OFF
	retlw   0

cf_type_06:						; Type == 6 is CF_SECS mode (mm:ss or hh:mm)
    clrf    hi
	call	convert_time		; Convert to min:sec into hi:low.
	movff	lo,wp_temp			; Save seconds,
	movff	hi,lo				; Get minutes
    bsf     leftbind            ; Skip leading space(s).
	output_8					; Print them
	movlw	':'					; Separator
	movwf	POSTINC2
	movff	wp_temp,lo			; Get back seconds
	output_99x					; lo in 2 digits with trailing zeros.
	retlw   0

cf_type_07:						; Type == 7 is CF_COLOR swatch.
    bcf     leftbind            ; Keep leading space (better alignement)
	output_8
	movlw	' '
	movwf	POSTINC2
	call    word_processor

	movf	lo,W				; Get color.
	movff	WREG,box_temp+0		; Set color
	movff	win_top,WREG		; BEWARE : this is a bank0 variable !
	movff	WREG,box_temp+1		; row top (0-239)
	addlw	.23
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.110
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.148	
	movff	WREG,box_temp+4		; column right (0-159)

	call	PLED_box
    retlw   -1  				; wp already done. Skip it...

cf_type_00:						; 8bit mode. Or unrecognized type...
	clrf	hi
    bsf     leftbind

cf_type_neg:					; 15bit mode.
	bcf		hi,7
	output_16
	retlw   0

;-----------------------------------------------------------------------------

cf_fill_line:                   ; Mattias: No flicker if u clear just what you need...
	movf    FSR2L,W             ; How many chars lefts ?
	sublw   (LOW letter) + .18  ; Remaining chars to fill: (letter + 18) - PTR
	btfsc   STATUS,N            ; Add chars until none left...
	return
	movlw   ' '
	movwf   POSTINC2
	bra     cf_fill_line

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

;-----------------------------------------------------------------------------

exit_customfunctions:
	movlw	d'2'					; Return to correct list entry
	btfss	customfunction_page
	movlw	d'1'
	movwf	menupos					; 
	clrf	EEADRH					; Clear EEADRH !
	goto	setup_menu2				; exit...

;-----------------------------------------------------------------------------

next_customfunction:
	incf	decodata+0
	btfsc	decodata+0,5			;>31?
	clrf	decodata+0				;Yes, so reset to zero
	
	movf	decodata+0,W
	mullw	d'4'
	movff	PRODL, cf32_x4          ; 12bit address for correct addressing

	movlw	d'1'
	movwf	menupos
	bra		menu_custom_functions1  ; also debounces switches

;-----------------------------------------------------------------------------

toggle_plusminus:
	btg		first_FA
	movlw	d'2'
	movwf	menupos
	bra		menu_custom_functions1	; also debounces switches

;-----------------------------------------------------------------------------

toggle_oneorten:
	btg		second_FA
	movlw	d'3'
	movwf	menupos
	bra		menu_custom_functions1	; also debounces switches

;-----------------------------------------------------------------------------

restore_cfn_value:
    rcall    cf_read_default        ; hi:lo is trashed by min/max display.

	movf	cf32_x4,W               ; store default value
	addlw	0x82
	movwf	EEADR
	movff	lo,EEDATA
	call	write_eeprom			; Lowbyte
	movf	cf32_x4,W
	addlw	0x83
	movwf	EEADR
	movff	hi,EEDATA
	call	write_eeprom			; Highbyte

	movlw	d'4'
	movwf	menupos
	bra		menu_custom_functions1	; also debounces switches

;-----------------------------------------------------------------------------
; Adjust current value.
adjust_cfn_value:
	movf	cf32_x4,W               ; get current value
	addlw	0x82
	movwf	EEADR
	call	read_eeprom				; Lowbyte
	movff	EEDATA,lo
	movf	cf32_x4,W
	addlw	0x83
	movwf	EEADR
	call	read_eeprom				; Highbyte
	movff	EEDATA,hi

    movf    cf_type,W
    xorlw   CF_BOOL
    bnz      adjust_cfn_value1

	btg     lo,0			            ; Change lower bit.
	bra		adjust_cfn_value3		    ; Store result

adjust_cfn_value1:
	movlw	d'1'
	btfsc	second_FA			    	; -10?
	movlw	d'10'
	
	btfss	first_FA				    ; Minus?
	bra		adjust_cfn_value2	    	; No, Plus

	subwf	lo,F					    ; substract value
	movlw	d'0'
	btfsc	cf_type,7			        ; 8Bit value
	subwfb	hi,F

	movlw	b'01111111'
	btfsc	hi,7				        ; >32768?
	movwf	hi						

	bra		adjust_cfn_value3
	
adjust_cfn_value2:
	addwf	lo,F					    ; add value
	movlw	d'0'
	btfsc	cf_type,7			        ; 8Bit value?
	addwfc	hi,F

	btfsc	hi,7					    ; >32768?
	clrf	hi

adjust_cfn_value3:
	movf	cf32_x4,W                   ; Store current value
	addlw	0x82
	movwf	EEADR
	movff	lo,EEDATA
	call	write_eeprom			    ; Lowbyte
	movf	cf32_x4,W
	addlw	0x83
	movwf	EEADR
	movff	hi,EEDATA
	call	write_eeprom			    ; Highbyte 
	movlw	d'5'
	movwf	menupos
	bra		menu_custom_functions1	    ; also debounces switches

;-----------------------------------------------------------------------------
; Check all CF values that have max and min constraints.
; Input: cf_checker_counter.
; Output: Pop warning with the first CF number if bad.
;        cf_checker_counter incremented.
; Trashes: TBLPTR, EEADR, PROD

check_customfunctions:
;   rcall   check_next_cf               ; Check 5 at a time...
;   rcall   check_next_cf
;   rcall   check_next_cf
;   rcall   check_next_cf
;
;check_next_cf:

    movf    cf_checker_counter,W        ; Get current CF to ckeck

    ; Setup cf32_x4 and cf page bit:
    rlcf    WREG                        ; x4
    rlcf    WREG
    bcf     customfunction_page
    btfsc   WREG,7   
    bsf     customfunction_page
    andlw   4*.31
    movwf   cf32_x4
    
    ; Do the check
    rcall   check_one_cf
    btfsc   WREG,7
    bra     check_cf_ok
    
    ; Went wrong: pop the warning
    movwf   temp1
    call    custom_warn_surfmode
    
    ; Increment counter (modulo 64)
check_cf_ok:
    movlw   1
    addwf   cf_checker_counter,W
    andlw   .63
    movwf   cf_checker_counter
    return

; Check one CF value ---------------------------------------------------------
check_one_cf:
    rcall   cf_read_default             ; Sets hi:lo, cf_type, cf_min, cf_max.
    
    movf    cf_type,W                   ; MIN or MAX set ?
    andlw   (CF_MIN + CF_MAX)
    bnz     check_cf_check              ; yes: do something.
    retlw   -1                          ; no: no problem there.

; It does have bound:
check_cf_check:
    movf    cf32_x4,W                    ; Compute current CF number
    rrncf   WREG                        ; Div 4
    rrncf   WREG
    btfsc   customfunction_page         ; Upper page ?
    addlw   .32                         ; just add 32.
    movwf   TABLAT                      ; saved to return error, if any.

    btfss   cf_type,7                   ; 15 or 8 bit value ?
    bra     cf_check_8bit
    
; Implement the 15bit check, even if not displayed...
    rcall   getcustom15_1               ; Read into hi:lo

    movf    cf_min,W                    ; Compute (bound-value) -> hi:lo
    subwf   lo,F
    movf    cf_max,W
    bcf     WREG,7                      ; Clear min or max bit
    subwfb  hi,F

    movf    lo,W                        ; Is it a 0 result ?
    iorwf   hi,W
    bnz     cf_15_not_equal             ; NO: check sign.
    retlw   -1                          ; YES: then it is ok.

cf_15_not_equal:
    btfss   cf_max,7                    ; Checking min or max ?
    btg     hi,6                        ; exchange wanted sign
    
    setf    WREG                        ; -1 for return w/o error
    btfss   hi,6                        ; Is sign correct ?
    movf    TABLAT,W                    ; NO: get back failed CF number
    return                              ; and return that.    

; Do a 8bit check
cf_check_8bit:
    rcall   getcustom8_1                ; Read into WREG
    movwf   lo                          ; Save it.

    btfss   cf_type,CF_MIN_BIT
    bra     check_no_min
    
    cpfsgt  cf_min                      ; Compare to cf_min
    bra     check_no_min

    movf    TABLAT,W                    ; NO: get back failed CF number
    return

check_no_min:
    btfss   cf_type,CF_MAX_BIT
    bra     check_no_max
    
    movf    lo,W                        ; Compute value-max
    cpfslt  cf_max
    bra     check_no_max

    movf    TABLAT,W                    ; NO: get back failed CF number
    return

check_no_max:                           ; Then everything was ok...
    retlw   -1
