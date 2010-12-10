
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


; routines for display outputs
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 15/01/05
; last updated: 06/06/08
; known bugs:
; ToDo:	More comments

PLED_divemask_color:
	GETCUSTOM8	d'36'			; Divemask output color
	bra		PLED_standard_color_0

PLED_warnings_color:
	GETCUSTOM8	d'37'			; Warnings output color
	bra		PLED_standard_color_0

PLED_standard_color:
	GETCUSTOM8	d'35'			; Standard output color
PLED_standard_color_0:			; Common entry point
	movwf	oled1_temp			; copy
	movlw	d'0'
	cpfseq	oled1_temp
	bra		PLED_standard_color_1
	bra		PLED_standard_color2
PLED_standard_color_1:
	movlw	d'4'
	cpfseq	oled1_temp
	bra		PLED_standard_color_2
	bra		PLED_standard_color2
PLED_standard_color_2:
	movlw	d'8'
	cpfseq	oled1_temp
	bra		PLED_standard_color_3
	bra		PLED_standard_color2
PLED_standard_color_3:
	movlw	d'192'
	cpfseq	oled1_temp
	bra		PLED_standard_color_4
	bra		PLED_standard_color2
PLED_standard_color_4:
	movlw	d'196'
	cpfseq	oled1_temp
	bra		PLED_standard_color_5
	bra		PLED_standard_color2
PLED_standard_color_5:
	movlw	d'200'
	cpfseq	oled1_temp
	bra		PLED_standard_color_6
	bra		PLED_standard_color2
PLED_standard_color_6:
	movf	oled1_temp,W		; Color should be OK...
	call	PLED_set_color
	return
PLED_standard_color2:
	movlw	0xFF		        ; Force full white.
	call	PLED_set_color
	return

PLED_color_code macro color_code_temp
	movlw	color_code_temp
	call	PLED_color_code1
	endm

PLED_color_code1:				; Color-codes the output, if required
	movwf	debug_temp
	dcfsnz	debug_temp,F
	bra		PLED_color_code_depth		; CF43 [mBar], 16Bit
	dcfsnz	debug_temp,F
	bra		PLED_color_code_cns			; CF44 [%]
	dcfsnz	debug_temp,F
	bra		PLED_color_code_gf			; CF45 [%]
	dcfsnz	debug_temp,F
	bra		PLED_color_code_ppo2		; CF46 [cBar]
	dcfsnz	debug_temp,F
	bra		PLED_color_code_velocity	; CF47 [m/min]
	dcfsnz	debug_temp,F
	bra		PLED_color_code_ceiling		; Show warning if CF41=1 and current depth>shown ceiling
	dcfsnz	debug_temp,F
	bra		PLED_color_code_gaslist		; Color-code current row in Gaslist (%O2 in "EEDATA")


PLED_color_code_gaslist:				; %O2 in "EEDATA"
; Check very high ppO2 manually
	movff		amb_pressure+0,xA+0
	movff		amb_pressure+1,xA+1
	movlw		d'10'
	movwf		xB+0
	clrf		xB+1
	call		div16x16				; xC=p_amb/10
	movff		xC+0,xA+0
	movff		xC+1,xA+1
	movff		EEDATA,xB+0
	clrf		xB+1
	call		mult16x16				; EEDATA * p_amb/10

	tstfsz		xC+2						; char_I_O2_ratio * p_amb/10 > 65536, ppO2>6,55Bar?
	bra			PLED_color_code_gaslist1	; Yes, warn in warning color

	movff		xC+0,sub_a+0
	movff		xC+1,sub_a+1
	GETCUSTOM8	d'46'					; color-code ppO2 warning [cBar]
	mullw		d'100'					; ppo2_warning_high*100
	movff		PRODL,sub_b+0
	movff		PRODH,sub_b+1
	call		sub16					;  sub_c = sub_a - sub_b	
	btfss		neg_flag
	bra			PLED_color_code_gaslist1; too high -> Warning Color!
	call		PLED_standard_color
	return

PLED_color_code_gaslist1:
	call	PLED_warnings_color
	return


PLED_color_code_ceiling:
	GETCUSTOM8	d'40'			; =1: Warn at all?
	movwf	lo					
	movlw	d'1'
	cpfseq	lo					; =1?
	bra		PLED_color_code_ceiling1	; No, Set to default color

	movff	char_O_array_decodepth+0,lo	; Ceiling in m
	decf	lo,F	; -1
	movff	rel_pressure+1,xA+1
	movff	rel_pressure+0,xA+0
	movlw	LOW		d'100'
	movwf	xB+0
	clrf	xB+1						; Devide/100 -> xC+0 = Depth in m
	call	div16x16					; xA/xB=xC with xA as remainder 	
	movf	xC+0,W						; Depth in m
	subwf	lo,W
	btfsc	STATUS,C
	bra		PLED_color_code_ceiling2	; Set to warning color
PLED_color_code_ceiling1:
	call	PLED_standard_color
	return
PLED_color_code_ceiling2:
	call	PLED_warnings_color
	return

PLED_color_code_depth:
	movff	hi,hi_temp
	movff	lo,lo_temp
	movff	rel_pressure+1,hi
	movff	rel_pressure+0,lo
	call	adjust_depth_with_salinity			; computes salinity setting into lo:hi [mBar]
	movff	lo,sub_a+0
	movff	hi,sub_a+1
	GETCUSTOM15	d'43'				; Depth warn [mBar]
	movff	lo,sub_b+0
	movff	hi,sub_b+1
	call	sub16			;  sub_c = sub_a - sub_b
	btfss	neg_flag
	bra		PLED_color_code_depth2; Set to warning color
	call	PLED_standard_color
	movff	hi_temp,hi
	movff	lo_temp,lo			; Restore hi, lo
	return
PLED_color_code_depth2:
	call	PLED_warnings_color
	movff	hi_temp,hi
	movff	lo_temp,lo			; Restore hi, lo
	return

PLED_color_code_cns:
	movff	char_O_CNS_fraction,lo
	GETCUSTOM8	d'44'			; CNS Warn [%]
	subwf	lo,W
	btfsc	STATUS,C
	bra		PLED_color_code_cns2		; Set to warning color
	call	PLED_standard_color
	return
PLED_color_code_cns2:
	call	PLED_warnings_color
	return

PLED_color_code_gf:
	movff	char_O_gradient_factor,lo		; gradient factor
	GETCUSTOM8	d'45'			; GF Warn [%]
	subwf	lo,W
	btfsc	STATUS,C
	bra		PLED_color_code_gf2		; Set to warning color
	call	PLED_standard_color
	return
PLED_color_code_gf2:
	call	PLED_warnings_color
	return

PLED_color_code_ppo2:
; Check very high ppO2 manually
	tstfsz	xC+2					; char_I_O2_ratio * p_amb/10 > 65536, ppO2>6,55Bar?
	bra		PLED_color_code_ppo22	; Yes, warn in warning color

	movff	xC+0,sub_a+0
	movff	xC+1,sub_a+1
	GETCUSTOM8	d'46'			; color-code ppO2 warning [cBar]
	mullw	d'100'
	movff	PRODL,sub_b+0
	movff	PRODH,sub_b+1
	call	sub16			;  sub_c = sub_a - sub_b
	btfss	neg_flag
	bra		PLED_color_code_ppo22; Set to warning color
	call	PLED_standard_color
	return
PLED_color_code_ppo22:
	call	PLED_warnings_color
	return

PLED_color_code_velocity:
	btfss	neg_flag			; Ignore for ascend!
	bra		PLED_color_code_velocity1		; Skip check!
	movff	divA+0,lo
	GETCUSTOM8	d'47'			; Velocity warn [m/min]
	subwf	lo,W
	btfsc	STATUS,C
	bra		PLED_color_code_velocity2		; Set to warning color
PLED_color_code_velocity1:
	call	PLED_standard_color
	return
PLED_color_code_velocity2:
	call	PLED_warnings_color
	return

ostc_debug	macro debug_temp
	movlw	debug_temp
	call	ostc_debug1
	endm

ostc_debug1:
	movwf	debug_temp

	movff	debug_char+4,debug_char+5		; Save for background debugger
	movff	debug_char+3,debug_char+4
	movff	debug_char+2,debug_char+3
	movff	debug_char+1,debug_char+2
	movff	debug_char+0,debug_char+1
	movff	debug_temp,debug_char+0

	btfss	debug_mode				; Are we in debugmode?
	return							; No, return!

	WIN_TOP		.200
	WIN_LEFT	.100
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color
	lfsr	FSR2,letter
	movf	debug_char+0,W
	movwf 	POSTINC2
	movf	debug_char+1,W
	movwf 	POSTINC2
	movf	debug_char+2,W
	movwf 	POSTINC2
	movf	debug_char+3,W
	movwf 	POSTINC2
	movf	debug_char+4,W
	movwf 	POSTINC2
	movf	debug_char+5,W
	movwf 	POSTINC2
	movlw	' '
	movwf	POSTINC2
	call	word_processor
	return


PLED_resetdebugger:
	bcf		LED_blue
	call	PLED_boot				; PLED boot
	call	PLED_ClearScreen		; clean up OLED
	call	PLED_standard_color
	WIN_INVERT	.0					; Init new Wordprocessor

	DISPLAYTEXT	.133
	DISPLAYTEXT	.134
	DISPLAYTEXT	.135
	DISPLAYTEXT	.136				; Display Debug intro
	
	WIN_TOP		.100
	WIN_LEFT	.10
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color
	lfsr	FSR2,letter
	movf	debug_char+0,W
	movwf 	POSTINC2
	movf	debug_char+1,W
	movwf 	POSTINC2
	movf	debug_char+2,W
	movwf 	POSTINC2
	movf	debug_char+3,W
	movwf 	POSTINC2
	movf	debug_char+4,W
	movwf 	POSTINC2
	movf	debug_char+5,W
	movwf 	POSTINC2
	movlw	'.'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	movff	flag1,lo
	output_8		
	movlw	' '
	movwf	POSTINC2
	movff	flag2,lo
	output_8		
	call	word_processor

	WIN_TOP		.125
	WIN_LEFT	.10
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color

	lfsr	FSR2,letter
	movff	flag3,lo
	output_8		
	movlw	' '
	movwf	POSTINC2
	movff	flag4,lo
	output_8		
	movlw	' '
	movwf	POSTINC2
	movff	flag5,lo
	output_8		
	movlw	' '
	movwf	POSTINC2
	movff	flag6,lo
	output_8		
	movlw	' '
	movwf	POSTINC2
	movff	flag7,lo
	output_8		
	call	word_processor

	WIN_TOP		.150
	WIN_LEFT	.10
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color

	lfsr	FSR2,letter
	movff	flag8,lo
	output_8		
	movlw	' '
	movwf	POSTINC2
	movff	flag9,lo
	output_8		
	movlw	' '
	movwf	POSTINC2
	movff	flag10,lo
	output_8		
	movlw	' '
	movwf	POSTINC2
	movff	flag11,lo
	output_8		
	movlw	' '
	movwf	POSTINC2
	movff	flag12,lo
	output_8		
	call	word_processor

PLED_resetdebugger_loop:
	btfss	switch_left
	bra		PLED_resetdebugger_loop		; Loop
	bcf		LED_red
	return

PLED_divemode_mask:					; Displays mask in Dive-Mode
	call		PLED_divemask_color	; Set Color for Divemode mask
	DISPLAYTEXTH	.267		; Max.
	DISPLAYTEXT		.86			; Divetime
	DISPLAYTEXT		.87			; Depth
	call	PLED_standard_color
	return

PLED_clear_customview_divemode:
	movlw	.0
	movff	WREG,box_temp+0		; Data
	movlw	.168
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.239
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.090
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.159	
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_box
	return

PLED_clear_decoarea:
	movlw	.0
	movff	WREG,box_temp+0		; Data
	movlw	.54
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.168
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.090
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.159	
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_box
	return

PLED_display_ndl_mask:
	; Clear Dekostop and Dekosum
	rcall	PLED_clear_decoarea	

	call	PLED_divemask_color	; Set Color for Divemode mask
	DISPLAYTEXT		d'84'			; NoStop
	call	PLED_standard_color

PLED_display_ndl_mask2:
	; Clears Gradient Factor
	movlw	d'8'
	movwf	temp1
	WIN_TOP		.145
	WIN_LEFT	.0
	call	PLED_display_clear_common_y1	
	return

PLED_display_ndl:
	btfsc	menubit					; Divemode menu active?
	return							; Yes, return

	ostc_debug	'z'		; Sends debug-information to screen if debugmode active
	
	WIN_TOP		.136
	WIN_LEFT	.119
	WIN_FONT 	FT_MEDIUM
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color

	lfsr	FSR2,letter
	movff	char_O_nullzeit,lo				; NDL in minutes
	output_8
	movlw	0x27			; "'"
	movwf	POSTINC2
	call	word_processor
	WIN_FONT 	FT_SMALL
	return

PLED_display_deko_mask:
	rcall	PLED_clear_decoarea	
; total deco time word
	call		PLED_divemask_color	; Set Color for Divemode mask
	DISPLAYTEXT	d'85'			; TTS
	call	PLED_standard_color
	return

PLED_display_deko:
	btfsc	menubit					; Divemode menu active?
	bra		PLED_display_deko1		; Yes, do not display deco, only GF (if required)

	ostc_debug	'y'		; Sends debug-information to screen if debugmode active
; deco stop word
	call		PLED_divemask_color	; Set Color for Divemode mask
	DISPLAYTEXT	d'82'			; DEKOSTOP
	call	PLED_standard_color

	WIN_TOP		.80
	WIN_LEFT	.94
	WIN_FONT 	FT_MEDIUM
	WIN_INVERT	.0					; Init new Wordprocessor
	PLED_color_code		warn_ceiling	; Color-code Output
	lfsr	FSR2,letter
	movff	char_O_array_decodepth+0,lo		; Ceiling in m
	output_99
	movlw	'm'		;	"m"
	movwf	POSTINC2
	movff	char_O_array_decotime,lo		; length of first stop in m
	output_99
	movlw	0x27				; "'"
	movwf	POSTINC2
	call	word_processor
	WIN_FONT 	FT_SMALL
	
;PLED_display_deko1:
	ostc_debug	'x'		; Sends debug-information to screen if debugmode active
	
	WIN_TOP		.136
	WIN_LEFT	.119
	WIN_FONT 	FT_MEDIUM
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color
	lfsr	FSR2,letter
	movff	char_O_ascenttime,lo		; complete ascend time
	movlw	d'199'							; limit display of total ascend time to 99mins....
	cpfslt	lo								; skip if 199 (WREG) > lo
	movwf	lo
	bcf		leftbind
	output_8
	movlw	0x27			; "'"
	movwf	POSTINC2
	call	word_processor

PLED_display_deko1:
	movff	char_O_gradient_factor,lo		; gradient factor
	GETCUSTOM8	d'8'		; threshold for display
	cpfslt	lo				; show value?
	bra		PLED_display_deko2	; Yes
	; No
	bra		PLED_display_ndl_mask2	; Clear gradient factor

PLED_display_deko2:
	ostc_debug	'w'		; Sends debug-information to screen if debugmode active
;GF
	WIN_TOP		.145
	WIN_LEFT	.0
	WIN_FONT 	FT_SMALL
	PLED_color_code		warn_gf		; Color-code Output
	lfsr	FSR2,letter
	movlw	'G'
	movwf	POSTINC2
	movlw	'F'
	movwf	POSTINC2
	movlw	':'
	movwf	POSTINC2
	movff	char_O_gradient_factor,lo		; gradient factor
	output_8
	movlw	'%'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	call	word_processor
	call	PLED_standard_color
	return

PLED_simulator_data:
	WIN_TOP		.65
	WIN_LEFT	.105
	WIN_FONT 	FT_SMALL
	call	PLED_standard_color
	lfsr	FSR2,letter
	movff	logbook_temp1,lo
	bsf		leftbind
	output_8
	bcf		leftbind
	movlw	'm'
	movwf	POSTINC2
	movlw	'i'
	movwf	POSTINC2
	movlw	'n'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	call	word_processor	

	WIN_TOP		.95
	WIN_LEFT	.100
	WIN_FONT 	FT_SMALL
	call	PLED_standard_color
	lfsr	FSR2,letter
	movff	logbook_temp2,lo
	bsf		leftbind
	output_8
	bcf		leftbind
	movlw	'm'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	call	word_processor	
	return

PLED_display_velocity:
	btfsc	multi_gf_display			; Is the Multi-GF Table displayed?
	return							; Yes, No update and return!

	ostc_debug	'v'		; Sends debug-information to screen if debugmode active
	WIN_TOP		.90
	WIN_LEFT	.0
	WIN_FONT 	FT_SMALL
	PLED_color_code		warn_velocity		; Color code output
	lfsr	FSR2,letter
	movlw	'-'
	btfsc	neg_flag
	movlw	'+'
	movwf	POSTINC2
	movff	divA+0,lo
	output_99
	OUTPUTTEXT	d'83'			; m/min
	call	word_processor
	call	PLED_standard_color
	bsf		pled_velocity_display
	return

PLED_display_velocity_clear:
	movlw	d'8'
	movwf	temp1
	WIN_TOP		.90
	WIN_LEFT	.0
	bcf		pled_velocity_display
	bra		PLED_display_clear_common_y1

PLED_display_wait_clear
	movlw	d'6'
	movwf	temp1
	WIN_TOP		.2
	WIN_LEFT	.115
	bra		PLED_display_clear_common_y1

PLED_display_clear_common_y2:				; Clears with y-scale=2
	WIN_FONT 	FT_MEDIUM
	bra		PLED_display_clear_common1

PLED_display_clear_common_y1:				; Clears with y-scale=1
	WIN_FONT 	FT_SMALL
PLED_display_clear_common1:
	lfsr	FSR2,letter
PLED_display_clear_common2:
	movlw	' '
	movwf	POSTINC2
	decfsz	temp1,F
	bra 	PLED_display_clear_common2
	call	word_processor
	WIN_FONT 	FT_SMALL
	return

PLED_diveclock:
	GETCUSTOM8	d'39'			; =1: Show clock in Divemode
	movwf	lo
	movlw	d'1'
	cpfseq	lo					; =1?
	return						; No, Done.

	btfsc	menubit	; is the Dive mode menu displayed?
	return			; Yes

	WIN_TOP		.2
	WIN_LEFT	.64
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color
	lfsr	FSR2,letter
	movff	hours,lo
	output_99x
	movlw	':'
	movwf	POSTINC2
	movff	mins,lo
	output_99x
	call	word_processor
	return

PLED_clock:
	ostc_debug	'c'
	
	;If > 0 display surface_interval:2 and clock changing every 5 seconds
	;use timeout_counter for this
	WIN_TOP		.50
	WIN_LEFT	.1
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color

	lfsr	FSR2,letter

	movff	surface_interval+0,lo
	tstfsz	lo
	bra		PLED_clock0				; Not Zero, switch between Interval and clock
	movff	surface_interval+1,lo
	tstfsz	lo
	bra		PLED_clock0				; Not Zero, switch between Interval and clock
	bra		PLED_clock3				; surface_interval=0, always display clock!

PLED_clock0:
	btfss	show_interval			; Show Interval?
	bra		PLED_clock2				; No, display clock and reset counter

PLED_clock1:
	decfsz	timeout_counter,F		; =0?
	bra		PLED_clock1a			; No...
	bra		PLED_clock3				; Yes, display clock and reset counter

PLED_clock1a:
	bsf		show_interval
	movlw	d'6'
	cpfslt	timeout_counter			; f < w? -> timeout_counter>5?
	rcall	PLED_clock_reload_timer	; No, reload counter

	movff	surface_interval+0,lo
	movff	surface_interval+1,hi
	call	convert_time			; lo=mins, hi=hours

	movf	hi,W
	movff	lo,hi
	movwf	lo					; exchange lo and hi

	movlw	'I'
	movwf	POSTINC2
	movlw	'n'
	movwf	POSTINC2
	movlw	't'
	movwf	POSTINC2
	movlw	':'
	movwf	POSTINC2
	output_99x
	movlw	':'
	movwf	POSTINC2
	movff	hi,lo
	output_99x
	movlw	' '
	movwf	POSTINC2
	call	word_processor
	return

PLED_clock_reload_timer:
	bcf		show_interval
	movlw	d'5'
	movwf	timeout_counter
	return

PLED_interval_reload_timer:
	bsf		show_interval
	movlw	d'5'
	movwf	timeout_counter
	return

PLED_clock2:
	decfsz	timeout_counter,F		; =0?
	bra		PLED_clock3				; No...
	bra		PLED_clock1a			; Yes, display interval and reset counter

PLED_clock3:
	bcf		show_interval
	movlw	d'6'
	cpfslt	timeout_counter			; f < w? -> timeout_counter>5?
	rcall	PLED_interval_reload_timer; No, reload counter

	movff	hours,lo
	output_99x
	movlw	':'
	movwf	POSTINC2
	movff	mins,lo
	output_99x
	movlw	':'
	movwf	POSTINC2
	movff	secs,lo
	output_99x
	movlw	' '
	movwf	POSTINC2
	call	word_processor
	return

PLED_logbook_cursor:

PLED_menu_cursor:
	WIN_TOP		.35
	WIN_LEFT	.0
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color

	lfsr	FSR2,letter
	movlw	0xB8
	movwf	POSTINC2
	call	word_processor

	WIN_TOP		.65
	lfsr	FSR2,letter
	movlw	0xB8
	movwf	POSTINC2
	call	word_processor

	WIN_TOP		.95
	lfsr	FSR2,letter
	movlw	0xB8
	movwf	POSTINC2
	call	word_processor

	WIN_TOP		.125
	lfsr	FSR2,letter
	movlw	0xB8
	movwf	POSTINC2
	call	word_processor

	WIN_TOP		.155
	call	PLED_standard_color
	lfsr	FSR2,letter
	movlw	0xB8
	movwf	POSTINC2
	call	word_processor

	WIN_TOP		.185
	lfsr	FSR2,letter
	movlw	0xB8
	movwf	POSTINC2
	call	word_processor

	movff	menupos,temp1
	dcfsnz	temp1,F
	movlw	d'35'
	dcfsnz	temp1,F
	movlw	d'65'
	dcfsnz	temp1,F
	movlw	d'95'
	dcfsnz	temp1,F
	movlw	d'125'
	dcfsnz	temp1,F
	movlw	d'155'
	dcfsnz	temp1,F
	movlw	d'185'
	
	movff	WREG,win_top
	lfsr	FSR2,letter
	movlw	0xB7
	movwf	POSTINC2
	call	word_processor
	return

PLED_menu_mask:
	call	PLED_topline_box
	WIN_INVERT	.1	; Init new Wordprocessor
	DISPLAYTEXT	.5			; Menu:
	WIN_INVERT	.0	; Init new Wordprocessor
	DISPLAYTEXT .6			; Logbook
	DISPLAYTEXT .7			; Gas Setup
	DISPLAYTEXT .9			; Reset all
	DISPLAYTEXT .10			; Setup...
	DISPLAYTEXT	.142		; More...
	DISPLAYTEXT .11			; Exit
	return	

PLED_setup_menu_mask:
	call	PLED_topline_box
	WIN_INVERT	.1	; Init new Wordprocessor	
	DISPLAYTEXT	.98			; Setup Menu:
	WIN_INVERT	.0	; Init new Wordprocessor	
	DISPLAYTEXT .99			; Custom FunctionsI
	DISPLAYTEXT	.153		; Custom FunctionsII
	DISPLAYTEXTH	.276	; Salinity:
	DISPLAYTEXT .100		; Decotype:
	DISPLAYTEXT	.142		; More...
	DISPLAYTEXT .11			; Exit
	return	

PLED_more_setup_menu_mask:
	call	PLED_topline_box
	WIN_INVERT	.1	; Init new Wordprocessor	
	DISPLAYTEXTH	.258	; Setup Menu 2:
	WIN_INVERT	.0	; Init new Wordprocessor	
	DISPLAYTEXTH	.257	; Date format:
	DISPLAYTEXT		.129	; Debug: 
	DISPLAYTEXT		.187	; Show License
	
	DISPLAYTEXT .11			; Exit
	return	

PLED_more_menu_mask:
	call	PLED_topline_box
	WIN_INVERT	.1	; Init new Wordprocessor
	DISPLAYTEXT	.144		; Menu 2:
	WIN_INVERT	.0	; Init new Wordprocessor
	DISPLAYTEXT .8			; Set Time
	DISPLAYTEXT	.110		; Const. ppO2 Setup
	DISPLAYTEXT	.113		; Battery Info
	DISPLAYTEXT	.247		; Simulator

	DISPLAYTEXT .11			; Exit
	return

PLED_reset_menu_mask:
	call	PLED_topline_box
	WIN_INVERT	.1	; Init new Wordprocessor	
	DISPLAYTEXT	.28				; Reset Menu
	WIN_INVERT	.0	; Init new Wordprocessor	
	DISPLAYTEXT	.21				; Cancel Reset
	DISPLAYTEXT	.245			; Reset CF,Gases & Deco
	DISPLAYTEXTH .284			; Reset Logbook
	DISPLAYTEXTH .285			; Reboot OSTC
	DISPLAYTEXTH .286			; Reset Decodata
	DISPLAYTEXT .11			; Exit
	return

PLED_simulator_mask:
	call	PLED_topline_box
	WIN_INVERT	.1	; Init new Wordprocessor	
	DISPLAYTEXT	.248		; OSTC Simulator
	WIN_INVERT	.0	; Init new Wordprocessor	
	DISPLAYTEXT	.249		; Start Dive
	DISPLAYTEXTH	.277	; Bottom Time:
	DISPLAYTEXTH	.278	; Max. Depth:
	DISPLAYTEXTH	.279	; Calculate Deco
	DISPLAYTEXTH	.280	; Show Decoplan
	DISPLAYTEXT .11			; Exit
	return
	
PLED_temp_surfmode:
	ostc_debug	'e'
	movff	temperature+0,last_temperature+0
	movff	temperature+1,last_temperature+1
	WIN_TOP		.100
	WIN_LEFT	.1
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color

	lfsr	FSR2,letter
	movlw	'-'
	btfsc	neg_temp			; Show "-"?
	movwf	POSTINC2			; Yes
	movff	temperature+0,lo
	movff	temperature+1,hi
	movlw	d'3'
	movwf	ignore_digits
	bsf		leftbind			; left orientated output
	output_16dp	d'2'
	bcf		leftbind
	movlw	'°'
	movwf	POSTINC2
	movlw	'C'
	movwf	POSTINC2
	movlw	' '						
	movwf	POSTINC2
	call	word_processor
	return

PLED_temp_divemode:
	btfsc	multi_gf_display			; Is the Multi-GF Table displayed?
	return								; Yes, No update and return!

	ostc_debug	'u'		; Sends debug-information to screen if debugmode active

; temperature
	movff	temperature+0,last_temperature+0
	movff	temperature+1,last_temperature+1

	WIN_TOP		.216
	WIN_LEFT	.50
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color

	lfsr	FSR2,letter
	movlw	'-'
	btfsc	neg_temp			; Show "-"?
	movwf	POSTINC2			; Yes
	movff	temperature+0,lo
	movff	temperature+1,hi
	movlw	d'3'
	movwf	ignore_digits
	bsf		leftbind			; left orientated output
	output_16dp	d'2'
	bcf		leftbind
	movlw	'°'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	call	word_processor
	return

PLED_show_ppO2:					; Show ppO2
	ostc_debug	't'		; Sends debug-information to screen if debugmode active
	WIN_TOP		.120
	WIN_LEFT	.0
	WIN_FONT 	FT_SMALL
	PLED_color_code		warn_ppo2		; Color-code output (ppO2 stored in xC)

	lfsr	FSR2,letter
	movlw	'p'
	movwf	POSTINC2
	movlw	'p'
	movwf	POSTINC2
	movlw	'O'
	movwf	POSTINC2
	movlw	'2'
	movwf	POSTINC2
	movlw	':'
	movwf	POSTINC2

; Check very high ppO2 manually
	tstfsz		xC+2					; char_I_O2_ratio * p_amb/10 > 65536, ppO2>6,55Bar?
	bra			PLED_show_ppO2_3		; Yes, display fixed Value!

	movff	xC+0,lo
	movff	xC+1,hi
	bsf		ignore_digit4
	output_16dp	d'1'
	bcf		ignore_digit4
PLED_show_ppO2_2:
	movlw	' '
	movwf	POSTINC2
	call	word_processor
	call	PLED_standard_color
	return

PLED_show_ppO2_3:
	movlw	'>'
	movwf	POSTINC2
	movlw	'6'
	movwf	POSTINC2
	movlw	'.'
	movwf	POSTINC2
	movlw	'6'
	movwf	POSTINC2
	bra		PLED_show_ppO2_2

PLED_show_ppO2_clear:					; Clear ppO2
	movlw	d'10'
	movwf	temp1
	WIN_TOP		.120
	WIN_LEFT	.0
	call	PLED_display_clear_common_y1
	return

PLED_active_gas_clear:					; clears active gas!
	WIN_TOP		.192
	WIN_LEFT	.50
	movlw	d'5'
	movwf	temp1
	bra		PLED_display_clear_common_y1; also returns!

PLED_active_gas_divemode:				; Displays current gas (e.g. 40/20) if a) He>0 or b) O2>Custom9
	btfsc	FLAG_apnoe_mode				; Ignore in Apnoe mode
	return

	btfsc	multi_gf_display			; Is the Multi-GF Table displayed?
	return								; Yes, No update and return!

	WIN_INVERT	.0					; Init new Wordprocessor	
	call	PLED_active_gas_divemode_show	; Show gas (Non-Inverted in all cases)

	btfss	better_gas_available	;=1: A better gas is available and a gas change is advised in divemode
	return					; Done.

; Check if Gas Output should blink when a better gas is available...
	GETCUSTOM8	d'42'			; =1 if gas should blink
	movwf	lo
	movlw	d'1'
	cpfseq	lo					; =1?
	return						; No, Done.

	btg		blinking_better_gas		; Toggle blink bit...
	btfss	blinking_better_gas		; blink now?
	return							; No, Done.
	WIN_INVERT	.1					; Init new Wordprocessor	
	call	PLED_active_gas_divemode_show	; Show gas (Non-Inverted in all cases)
	WIN_INVERT	.0					; Init new Wordprocessor	
	return							; Done.

PLED_active_gas_divemode_show:
	ostc_debug	's'		; Sends debug-information to screen if debugmode active
; gas
	WIN_TOP		.192
	WIN_LEFT	.50
	WIN_FONT 	FT_SMALL
	call	PLED_standard_color

	movlw	d'100'						; 100% in the tank
	movff	char_I_N2_ratio,lo			; minus N2
	bsf		STATUS,C					; set borrow bit
	subfwb	lo,W
	movff	char_I_He_ratio,lo			; minus He
	bsf		STATUS,C					; set borrow bit
	subfwb	lo,F						; =% O2
	GETCUSTOM8		d'9'				; get oxygen treshold
	movff	char_I_He_ratio,hi			; He ratio
	cpfsgt	lo
	bra		PLED_active_gas_divemode2		; Check He
	bra		PLED_active_gas_divemode3		; Skip He check, display gas
	
PLED_active_gas_divemode2:
	tstfsz	hi							; He = 0 %
	bra		PLED_active_gas_divemode3	; display gas
										; O2 below treshold, He=0 -> Skip display!
	movlw	d'5'
	movwf	temp1
	bra		PLED_display_clear_common_y1		; also returns!

PLED_active_gas_divemode3:
	movlw	d'21'
	cpfseq	lo				; Air? (O2=21%)
	bra		PLED_active_gas_divemode4 ; No!
	tstfsz	hi				; Air? (He=0%)
	bra		PLED_active_gas_divemode4 ; No!
	
							; Yes, display "Air" instead of 21/0
	lfsr	FSR2,letter
	OUTPUTTEXTH		d'264'			;"Air "
	movlw	' '
	btfsc	better_gas_available	;=1: A better gas is available and a gas change is advised in divemode
	movlw	'*'
	movwf	POSTINC2
	call	word_processor
	return

PLED_active_gas_divemode4:
	lfsr	FSR2,letter
	bsf		leftbind			; left orientated output
	output_8					; O2 ratio is still in "lo"
	movlw	'/'
	movwf	POSTINC2
	movff	char_I_He_ratio,lo		; copy He ratio into lo
	output_8
	movlw	' '
	btfsc	better_gas_available	;=1: A better gas is available and a gas change is advised in divemode
	movlw	'*'
	movwf	POSTINC2
	bcf		leftbind
	call	word_processor
	return



PLED_display_decotype_surface:
	WIN_LEFT	.85
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	clrf	EEADRH
	read_int_eeprom d'34'		; Read deco data	
	tstfsz	EEDATA
	bra		show_decotype_surface2

;ZH-L16
	WIN_TOP		.125
	call	PLED_standard_color

	lfsr	FSR2,letter		
	movlw	'O'
	movwf	POSTINC2
	call	word_processor
	WIN_LEFT	.85
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	WIN_TOP		.150
	call	PLED_standard_color

	lfsr	FSR2,letter		
	movlw	'C'
	movwf	POSTINC2
	call	word_processor
	return		
show_decotype_surface2:
	decf	EEDATA,F
	tstfsz	EEDATA
	bra		show_decotype_surface3
; Gauge
	return
	
show_decotype_surface3:
	decf	EEDATA,F
	tstfsz	EEDATA
	bra	show_decotype_surface4
	; const. ppO2
	WIN_TOP		.125
	call	PLED_standard_color

	lfsr	FSR2,letter		
	movlw	'C'
	movwf	POSTINC2
	WIN_LEFT	.85
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call	word_processor
	WIN_TOP		.150
	call	PLED_standard_color

	lfsr	FSR2,letter		
	movlw	'C'
	movwf	POSTINC2
	WIN_LEFT	.85
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call	word_processor
	return
show_decotype_surface4:
	decf	EEDATA,F
	tstfsz	EEDATA
	bra		show_decotype_surface5
; Apnoe
	return
show_decotype_surface5:
	decf	EEDATA,F
	tstfsz	EEDATA
	bra		show_decotype_surface6
	; Multi-GF OC
	WIN_TOP		.125
	lfsr	FSR2,letter		
	movlw	'G'
	movwf	POSTINC2
	WIN_LEFT	.85
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color

	call	word_processor
	WIN_TOP		.150
	lfsr	FSR2,letter		
	movlw	'F'
	movwf	POSTINC2
	WIN_LEFT	.85
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color

	call	word_processor
	return

show_decotype_surface6:
	; Multi-GF CC
	WIN_TOP		.125
	lfsr	FSR2,letter		
	movlw	'G'
	movwf	POSTINC2
	WIN_LEFT	.85
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color

	call	word_processor
	WIN_TOP		.150
	lfsr	FSR2,letter		
	movlw	'F'
	movwf	POSTINC2
	WIN_LEFT	.85
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color

	call	word_processor
	return

PLED_pre_dive_screen:			;Display Pre-Dive Screen
	movlw	.0
	movff	WREG,box_temp+0		; Data
	movlw	.25
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.120
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.82
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.159
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_box

	; List active gases/Setpoints

	btfsc	FLAG_const_ppO2_mode		; in ppO2 mode?
	bra		PLED_pre_dive_screen3		; Yes, display SetPoint/Sensor result list

PLED_pre_dive_screen2:
	ostc_debug	'm'		; Sends debug-information to screen if debugmode active

	WIN_LEFT	.90
	WIN_FONT	FT_SMALL
	bsf		leftbind
	
	movlw	d'2'
	movwf	wait_temp			; here: stores eeprom address for gas list
	movlw	d'0'
	movwf	waitms_temp		; here: stores row for gas list
	clrf	hi					; here: Gas counter

PLED_pre_dive_screen2_loop:
	incf	hi,F				; Increase Gas
	movlw	d'4'
	addwf	wait_temp,F			; Increase eeprom address for gas list
	
	lfsr	FSR2,letter		
	movlw	'G'
	movwf	POSTINC2
	movff	hi,lo			; copy gas number
	output_8				; display gas number
	movlw	':'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	movff	wait_temp, EEADR; Gas #hi: %O2 - Set address in internal EEPROM
	call	read_eeprom		; get byte (stored in EEDATA)
	movff	EEDATA,lo		; copy to lo
	output_8				; outputs into Postinc2!
	movlw	'/'
	movwf	POSTINC2
	incf	EEADR,F			; Gas #hi: %He - Set address in internal EEPROM
	call	read_eeprom		; get byte (stored in EEDATA)
	movff	EEDATA,lo		; copy to lo
	output_8				; outputs into Postinc2!
	
	read_int_eeprom		d'27'	; read flag register
	movff	hi,lo			; copy gas number
PLED_pre_dive_screen2_loop1:
	rrcf	EEDATA			; roll flags into carry
	decfsz	lo,F			; max. 5 times...
	bra		PLED_pre_dive_screen2_loop1
	
	btfsc	STATUS,C		; test carry
	bra		PLED_pre_dive_white

	movlw	color_grey
	call	PLED_set_color	; grey out inactive gases!
	bra		PLED_pre_dive_color_done

PLED_pre_dive_white:
	call	PLED_standard_color

PLED_pre_dive_color_done:	
	read_int_eeprom 	d'33'			; Read start gas (1-5)
	movf	EEDATA,W
	cpfseq	hi				; Current Gas the active gas?
	bra		PLED_pre_dive_screen2a
	bra		PLED_pre_dive_screen2b

PLED_pre_dive_screen2a:
	movlw	d'25'
	addwf	waitms_temp,F		; Increase row
	WIN_LEFT	.90
	movff	waitms_temp,win_top ; Set Row
	call	word_processor	; No, display gas

PLED_pre_dive_screen2b:
	call		PLED_standard_color

	movlw	d'5'			; list all four (remaining) gases
	cpfseq	hi				; All gases shown?
	bra		PLED_pre_dive_screen2_loop	; No
	
	return							; No, return (OC mode)

PLED_pre_dive_screen3:	
	WIN_LEFT	.90
	WIN_FONT	FT_SMALL
	bsf		leftbind

	; list three SP in Gaslist
	movlw	d'35'				; 36 = current SP position in EEPROM
	movwf	wait_temp			; here: stores eeprom address for gas list
	movlw	d'0'
	movwf	waitms_temp			; here: stores row for gas list
	clrf 	temp6				; here: SP counter

PLED_pre_dive_screen3_loop:
	incf	wait_temp,F			; EEPROM address
	incf	temp6,F			; Increase SP

	movlw	d'25'
	addwf	waitms_temp,F		; Increase row
	WIN_LEFT	.90
	movff	waitms_temp,win_top ; Set Row
	
	lfsr	FSR2,letter		
	movlw	'S'
	movwf	POSTINC2
	movlw	'P'
	movwf	POSTINC2
	movff	temp6,lo		; copy gas number
	output_8				; display gas number
	movlw	':'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	movff	wait_temp, EEADR; SP #hi position
	call	read_eeprom		; get byte (stored in EEDATA)
	movff	EEDATA,lo		; copy to lo
	clrf	hi
	output_16dp	d'3'		; outputs into Postinc2!
	call	word_processor	

	movlw	d'3'		; list all three SP
	cpfseq	temp6		; All gases shown?
	bra		PLED_pre_dive_screen3_loop	;no

	read_int_eeprom 	d'33'			; Read byte (stored in EEDATA)
	movff	EEDATA,active_gas			; Read start gas (1-5)
	decf	active_gas,W				; Gas 0-4
	mullw	d'4'
	movf	PRODL,W			
	addlw	d'7'						; = address for He ratio
	movwf	EEADR
	call	read_eeprom					; Read He ratio
	movff	EEDATA,hi		; And copy into hold register
	decf	active_gas,W				; Gas 0-4
	mullw	d'4'
	movf	PRODL,W			
	addlw	d'6'						; = address for O2 ratio
	movwf	EEADR
	call	read_eeprom					; Read O2 ratio
	movff	EEDATA, lo		; O2 ratio

	WIN_LEFT	.90
	WIN_TOP		.100
	lfsr	FSR2,letter		
	movlw	'D'
	movwf	POSTINC2
	movlw	'i'
	movwf	POSTINC2
	movlw	'l'
	movwf	POSTINC2
	movlw	':'
	movwf	POSTINC2
	output_8				; O2 Ratio
	movlw	'/'
	movwf	POSTINC2
	movff	hi,lo
	output_8				; He Ratio
	call	word_processor		

	bcf		leftbind
	return				; Return (CC Mode)

PLED_active_gas_surfmode:				; Displays start gas/SP 1
	ostc_debug	'q'		; Sends debug-information to screen if debugmode active
		
	btfsc	FLAG_apnoe_mode				; In Apnoe mode?
	return								; Yes, return

	btfsc	gauge_mode					; In Gauge mode?
	return								; Yes, return

	btfss	FLAG_const_ppO2_mode	; are we in const. ppO2 mode?	
	bra		PLED_active_gas_surfmode2	; No, display gases

; In CC Mode
	WIN_TOP		.135
	WIN_LEFT	.90
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color

	lfsr	FSR2,letter		
	read_int_eeprom	d'36'
	movff	EEDATA,lo				; copy to lo
	clrf	hi
	output_16dp	d'3'		; outputs into Postinc2!
	movlw	'B'
	movwf	POSTINC2
	movlw	'a'
	movwf	POSTINC2
	movlw	'r'
	movwf	POSTINC2
	bcf		leftbind
	call	word_processor
	bra		PLED_active_gas_surfmode_exit

PLED_active_gas_surfmode2:
	WIN_TOP		.130
	WIN_LEFT	.100
	WIN_FONT 	FT_MEDIUM
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color


	read_int_eeprom 	d'33'			; Read byte (stored in EEDATA)
	movff	EEDATA,active_gas			; Read start gas (1-5)

	decf	active_gas,W				; Gas 0-4
	mullw	d'4'
	movf	PRODL,W			
	addlw	d'7'						; = address for He ratio
	movwf	EEADR
	call	read_eeprom					; Read He ratio
	movff	EEDATA,char_I_He_ratio		; And copy into hold register

	decf	active_gas,W				; Gas 0-4
	mullw	d'4'
	movf	PRODL,W			
	addlw	d'6'						; = address for O2 ratio
	movwf	EEADR
	call	read_eeprom					; Read O2 ratio
	movff	EEDATA, char_I_O2_ratio		; O2 ratio
	movff	char_I_He_ratio, wait_temp	; copy into bank1 register
	bsf		STATUS,C					; Borrow bit
	movlw	d'100'						; 100%
	subfwb	wait_temp,W					; minus He
	bsf		STATUS,C					; Borrow bit
	subfwb	EEDATA,F					; minus O2
	movff	EEDATA, char_I_N2_ratio		; = N2!

	movlw	d'100'						; 100% in the tank
	movff	char_I_N2_ratio,lo			; minus N2
	bsf		STATUS,C					; set borrow bit
	subfwb	lo,W
	movff	char_I_He_ratio,lo			; minus He
	bsf		STATUS,C					; set borrow bit
	subfwb	lo,F						; =% O2

	movff	char_I_He_ratio,hi			; Copy into Bank1 register

	movlw	d'21'
	cpfseq	lo				; Air? (O2=21%)
	bra		PLED_active_gas_surfmode4 ; No!
	tstfsz	hi							; Air? (He=0%)
	bra		PLED_active_gas_surfmode4 ; No!
	
							; Yes, display "Air" instead of 21/0
	DISPLAYTEXTH		d'265'		;"Air  ", y-scale=2
	bra		PLED_active_gas_surfmode_exit

PLED_active_gas_surfmode4:
	lfsr	FSR2,letter
	bsf		leftbind			; left orientated output
	output_99					; O2 ratio is still in "lo"
	movlw	'/'
	movwf	POSTINC2
	movff	char_I_He_ratio,lo		; copy He ratio into lo
	output_99
	bcf		leftbind
	call	word_processor
	bra		PLED_active_gas_surfmode_exit

PLED_active_gas_surfmode_exit:
	movlw	.0
	movff	WREG,box_temp+0		; Data
	movlw	.122
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.175
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.82
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.159
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_frame
	return

PLED_confirmbox:
	movlw	.0
	movff	WREG,box_temp+0		; Data
	movlw	.68
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.146
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.34
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.101
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_box

	GETCUSTOM8	d'35'			; Standard output color
	movff	WREG,box_temp+0		; Data
	movlw	.70
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.144
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.35
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.100
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_frame
	DISPLAYTEXT	.143			; Confirm:
	DISPLAYTEXT	.145			; Cancel
	DISPLAYTEXT	.146			; OK!

	movlw		d'1'
	movwf		menupos

PLED_confirmbox2:
	movlw	.0
	movff	WREG,box_temp+0		; Data
	movlw	.96
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.143
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.39
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.51
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_box

	movff	menupos,temp1
	movlw	d'96'
	dcfsnz	temp1,F
	movlw	d'96'
	dcfsnz	temp1,F
	movlw	d'120'
	movff	WREG,win_top
	WIN_LEFT	.39
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color

	lfsr	FSR2,letter
	movlw	0xB7			; Arrow for menu
	movwf	POSTINC2
	call	word_processor

	bcf			sleepmode					; clear some flags
	bcf			menubit2
	bcf			menubit3
	bcf			switch_right
	bcf			switch_left
	clrf		timeout_counter2
	WAITMS		d'100'

PLED_confirmbox_loop:
	call		check_switches_logbook
	
	btfsc		menubit3					; SET/MENU?
	bra			PLED_confirmbox_move_cursor; Move Cursor
	btfsc		menubit2					; ENTER?
	bra			PLED_confirmbox_menu_do		; Do task

	btfsc		onesecupdate
	call		timeout_surfmode			; timeout

	btfsc		onesecupdate
	call		set_dive_modes				; check, if divemode must be entered
	bcf			onesecupdate				; one second update

	btfsc		sleepmode					; Timeout?
	bra			PLED_confirmbox_cancel		; back with cancel
	btfsc		divemode
	bra			PLED_confirmbox_cancel		; back with cancel

	bra			PLED_confirmbox_loop		; wait for something to do

PLED_confirmbox_cancel:
	retlw	.0
PLED_confirmbox_ok:
	retlw	.1

PLED_confirmbox_menu_do:
	dcfsnz	menupos,F
	bra		PLED_confirmbox_cancel
	dcfsnz	menupos,F
	bra		PLED_confirmbox_ok
	bra		PLED_confirmbox_cancel

PLED_confirmbox_move_cursor:
	incf	menupos,F
	movlw	d'3'						; number of menu options+1
	cpfseq	menupos						; =limit?
	bra		PLED_confirmbox_move_cursor2	; No!
	movlw	d'1'							; Yes, reset to position 1!
	movwf	menupos
PLED_confirmbox_move_cursor2:
	bra		PLED_confirmbox2		; Return to Profile Menu, also updates cursor


PLED_depth:
	ostc_debug	'r'		; Sends debug-information to screen if debugmode active
	movff	rel_pressure+1,hi
	movff	rel_pressure+0,lo
	call	adjust_depth_with_salinity			; computes salinity setting into lo:hi [mBar]

	movlw	.039
	cpfslt	hi
		bra	depth_greater_99_84mtr

	btfsc	depth_greater_100m			; Was depth>100m during last call
	call	PLED_clear_depth			; Yes, clear depth area
	bcf		depth_greater_100m			; Do this once only...

	lfsr	FSR2,letter

	movlw	HIGH	d'1000'
	movwf	sub_a+1
	movlw	LOW		d'1000'
	movwf	sub_a+0
	movff	hi,sub_b+1
	movff	lo,sub_b+0
	incf	sub_b+0,F
	movlw	d'0'
	addwfc	sub_b+1,F		; Add 1mBar offset
	call	sub16					; sub_c = sub_a - sub_b
	btfss	neg_flag				; Depth lower then 10m?
	rcall	depth_less_10mtr		; Yes, add extra space

	WIN_TOP		.24
	WIN_LEFT	.0
	WIN_FONT 	FT_LARGE
	WIN_INVERT	.0					; Init new Wordprocessor
	PLED_color_code	warn_depth		; Color-code the output

	movlw	HIGH	d'99'
	movwf	sub_a+1
	movlw	LOW		d'99'
	movwf	sub_a+0
	movff	hi,sub_b+1
	movff	lo,sub_b+0
	call	sub16					; sub_c = sub_a - sub_b
	btfss	neg_flag				; Depth lower then 1m?
	bra		pled_depth2				; Yes, display manual Zero

	bsf		leftbind
	bsf		ignore_digit4
	output_16		; Full meters in Big font
	bcf		leftbind
	bra		pled_depth3

pled_depth2:
	movlw	'0'
	movwf	POSTINC2
pled_depth3:
	call	word_processor
	bcf		ignore_digit4

	WIN_FONT 	FT_MEDIUM
	WIN_TOP		.50
	WIN_LEFT	.40
	PLED_color_code	warn_depth		; Color-code the output

	movff	rel_pressure+1,hi
	movff	rel_pressure+0,lo
	call	adjust_depth_with_salinity			; computes salinity setting into lo:hi [mBar]
	lfsr	FSR2,letter
	movlw	'.'
	movwf	POSTINC2

	movlw	HIGH	d'9'
	movwf	sub_a+1
	movlw	LOW		d'9'
	movwf	sub_a+0
	movff	hi,sub_b+1
	movff	lo,sub_b+0
	call	sub16					; sub_c = sub_a - sub_b
	btfss	neg_flag				; Depth lower then 0.1m?
	bra		pled_depth4				; Yes, display manual Zero

	movlw	d'4'
	movwf	ignore_digits
	bsf		ignore_digit5
	output_16dp	d'0'
	bra		pled_depth5

pled_depth4:
	movlw	'0'
	movwf	POSTINC2

pled_depth5:
	call	word_processor			; decimeters in medium font
	bcf		ignore_digit5
	WIN_FONT 	FT_SMALL
	return

depth_greater_99_84mtr:			; Display only in full meters
	btfss	depth_greater_100m			; Is depth>100m already?
	call	PLED_clear_depth			; No, clear depth area and set flag
	; Depth is already in hi:lo
	; Show depth in Full meters
	; That means ignore figure 4 and 5
	lfsr	FSR2,letter
	WIN_TOP		.24
	WIN_LEFT	.0
	WIN_FONT 	FT_LARGE
	WIN_INVERT	.0					; Init new Wordprocessor
	PLED_color_code	warn_depth		; Color-code the output

	bsf		ignore_digit4
	bsf		leftbind
	output_16
	bcf		leftbind
	call	word_processor
	bcf		ignore_digit4
	WIN_FONT 	FT_SMALL
	return
	
depth_less_10mtr:
	movlw	' '
	movwf	POSTINC2
	return

PLED_clear_depth			; No, clear depth area and set flag
	movlw	.0
	movff	WREG,box_temp+0		; Data
	movlw	.24
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.90
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.0
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.90
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_box
	bsf		depth_greater_100m			; Set Flag
	return


PLED_desaturation_time:	
	ostc_debug	'h'
	WIN_TOP		.150
	WIN_LEFT	.1
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color

	lfsr	FSR2,letter
	OUTPUTTEXT	d'14'				; Desat
	movlw		' '
	movwf		POSTINC2
	movff		int_O_desaturation_time+0,lo			; divide by 60...
	movff		int_O_desaturation_time+1,hi
	call		convert_time				; converts hi:lo in minutes to hours (hi) and minutes (lo)
	bsf			leftbind
	movf		lo,W
	movff		hi,lo
	movwf		hi							; exchange lo and hi...
	output_8								; Hours
	movlw		':'
	movwf		POSTINC2
	movff		hi,lo					; Minutes
	output_99x
	bcf		leftbind
	call	word_processor
	return

PLED_nofly_time:	
	ostc_debug	'g'
	WIN_TOP		.125
	WIN_LEFT	.1
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color

	lfsr	FSR2,letter
	OUTPUTTEXT	d'35'				; NoFly
	movlw		' '
	movwf		POSTINC2
	movff		nofly_time+0,lo			; divide by 60...
	movff		nofly_time+1,hi
	call		convert_time				; converts hi:lo in minutes to hours (hi) and minutes (lo)
	bsf			leftbind
	movf		lo,W
	movff		hi,lo
	movwf		hi							; exchange lo and hi...
	output_8								; Hours
	movlw		':'
	movwf		POSTINC2
	movff		hi,lo					; Minutes
	decf		lo,F
	btfsc		lo,7					; keep Nofly time
	clrf		lo
	output_99x
	bcf		leftbind
	call	word_processor
	return


update_surf_press:
	btfsc	premenu		; Do not update when "Menu?" is displayed!
	return

	ostc_debug	'b'		; Sends debug-information to screen if debugmode active
	WIN_TOP		.25
	WIN_LEFT	.1
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color

	lfsr	FSR2,letter
	movff	amb_pressure+0,lo
	movff	amb_pressure+1,hi
	bsf		leftbind
	output_16
	bcf		leftbind
	movlw	'm'
	movwf	POSTINC2
	movlw	'b'
	movwf	POSTINC2
	movlw	'a'
	movwf	POSTINC2
	movlw	'r'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	call	word_processor
	return

update_batt_voltage_divemode:

update_batt_voltage:
	ostc_debug	'f'

	GETCUSTOM8	d'31'			; =1 if battery voltage should be visible
	movwf	lo
	movlw	d'1'
	cpfseq	lo					; =1?
	bra		update_batt_voltage2	; No, show symbol

	WIN_TOP		.175
	WIN_LEFT	.1
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color

	lfsr	FSR2,letter
	movff	batt_voltage+0,lo
	movff	batt_voltage+1,hi
	movlw	d'1'
	movwf	ignore_digits
	bsf		ignore_digit5		; do not display mV
	bsf		leftbind
	output_16dp	d'2'			; e.g. 3.45V
	bcf		leftbind
	movlw	'V'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	call	word_processor
	return
	
update_batt_voltage2:
	GETCUSTOM8	d'35'			; Standard output color
	movff	WREG,box_temp+0		; Data
	movlw	.174
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.194
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.1
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.32
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_frame

; 4100-Vbatt
	movlw	LOW		d'4100'
	movwf	sub_a+0
	movlw	HIGH	d'4100'
	movwf	sub_a+1
	movff	batt_voltage+0,sub_b+0
	movff	batt_voltage+1,sub_b+1
	call	sub16				;  sub_c = sub_a - sub_b
; Battery full (>4100mV?
	btfsc	neg_flag
	bra		update_batt_voltage2_full

; Vbatt-3500
	movlw	LOW		d'3500'
	movwf	sub_b+0
	movlw	HIGH	d'3500'
	movwf	sub_b+1
	movff	batt_voltage+0,sub_a+0
	movff	batt_voltage+1,sub_a+1
	call	sub16				;  sub_c = sub_a - sub_b
; Battery lower then 3500mV?
	btfsc	neg_flag
	bra		update_batt_voltage2_empty

; Battery is between 3500 and 4100mV
; sub_c:2 is between 0 and 600	
	movff	sub_c+0,xA+0
	movff	sub_c+1,xA+1
	movlw	d'20'
	movwf	xB+0
	clrf	xB+1
	call	div16x16					;xA/xB=xC with xA as remainder 	
; xC is between 0 and 30
	movff	xC+0,wait_temp				;save value
	incf	wait_temp,F					; +1

	movlw	d'3'
	cpfsgt	wait_temp
	movwf	wait_temp					; Minimum = 3

update_batt_voltage2a:
	GETCUSTOM8	d'35'			; Standard output color
	movff	WREG,box_temp+0		; Data
	movlw	.181
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.187
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.32
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.34
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_box			; Full Cap

update_batt_voltage3:
	GETCUSTOM8	d'34'			; Color battery
	movff	WREG,box_temp+0		; Color Data
	movlw	.176
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.192
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.2
	movff	WREG,box_temp+3		; column left (0-159)
	movff	wait_temp,box_temp+4		; column right (0-159)
	call	PLED_box

	call		PLED_standard_color
	return
		
update_batt_voltage2_empty:
	movlw	d'1'
	movwf	wait_temp
	bra		update_batt_voltage2a

update_batt_voltage2_full:
	movlw	d'30'
	movwf	wait_temp
	bra		update_batt_voltage2a

PLED_convert_date:	; converts into "DD/MM/YY" or "MM/DD/YY" or "YY/MM/DD" in postinc2
	read_int_eeprom d'91'			; Read date format (0=MMDDYY, 1=DDMMYY, 2=YYMMDD)
	tstfsz	EEDATA
	bra		PLED_convert_date1

; Use MMDDYY
	movff	convert_value_temp+0,lo			;month
	bsf		leftbind
	output_99x
	bcf		leftbind
	movlw	'/'
	movwf	POSTINC2
	movff	convert_value_temp+1,lo			;day
	bra 	PLED_convert_date1_common		;year

PLED_convert_date1:
	read_int_eeprom d'91'			; Read date format (0=MMDDYY, 1=DDMMYY, 2=YYMMDD)
	decfsz	EEDATA,F
	bra		PLED_convert_date2

; Use DDMMYY
	movff	convert_value_temp+1,lo			;day
	bsf		leftbind
	output_99x
	bcf		leftbind
	movlw	'/'
	movwf	POSTINC2
	movff	convert_value_temp+0,lo			;month

PLED_convert_date1_common:
	bsf		leftbind
	output_99x
	bcf		leftbind
	movlw	'/'
	movwf	POSTINC2
	movff	convert_value_temp+2,lo			;year
	bsf		leftbind
	output_99x
	return

PLED_convert_date2:
; Use YYMMDD
	movff	convert_value_temp+2,lo			;year
	bsf		leftbind
	output_99x
	bcf		leftbind
	movlw	'/'
	movwf	POSTINC2
	movff	convert_value_temp+0,lo			;month
	bsf		leftbind
	output_99x
	bcf		leftbind
	movlw	'/'
	movwf	POSTINC2
	movff	convert_value_temp+1,lo			;day
	bsf		leftbind
	output_99x
	return

PLED_convert_date_short:	; converts into "DD/MM" or "MM/DD" or "MM/DD" in postinc2
	read_int_eeprom d'91'			; Read date format (0=MMDDYY, 1=DDMMYY, 2=YYMMDD)
	tstfsz	EEDATA
	bra		PLED_convert_date_short1

; Use MMDDYY
PLED_convert_date_short_common:
	movff	convert_value_temp+0,lo			;month
	bsf		leftbind
	output_99x
	bcf		leftbind
	movlw	'/'
	movwf	POSTINC2
	movff	convert_value_temp+1,lo			;day
	bsf		leftbind
	output_99x
	bcf		leftbind
	return

PLED_convert_date_short1:
	read_int_eeprom d'91'			; Read date format (0=MMDDYY, 1=DDMMYY, 2=YYMMDD)
	decfsz	EEDATA,F
	bra		PLED_convert_date_short_common	; Use YYMMDD

; Use DDMMYY
	movff	convert_value_temp+1,lo			;day
	bsf		leftbind
	output_99x
	bcf		leftbind
	movlw	'/'
	movwf	POSTINC2
	movff	convert_value_temp+0,lo			;month
	bsf		leftbind
	output_99x
	bcf		leftbind
	return

update_date:
	ostc_debug	'd'
	WIN_TOP		.75
	WIN_LEFT	.1
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color

	lfsr	FSR2,letter

	movff	month,convert_value_temp+0
	movff	day,convert_value_temp+1
	movff	year,convert_value_temp+2
	call	PLED_convert_date		; converts into "DD/MM/YY" or "MM/DD/YY" or "YY/MM/DD" in postinc2	
	call	word_processor
	return

PLED_menu_clear:
	movlw	.0
	movff	WREG,box_temp+0		; Data
	movlw	.0
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.26
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.65
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.100	
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_box
	return

PLED_max_pressure:
	ostc_debug	'p'		; Sends debug-information to screen if debugmode active
	movff	max_pressure+0,lo
	movff	max_pressure+1,hi
	call	adjust_depth_with_salinity			; computes salinity setting into lo:hi [mBar]

	movlw	.039
	cpfslt	hi
		bra		maxdepth_greater_99_84mtr

; Display normal "xx.y"
	lfsr	FSR2,letter
	call	PLED_standard_color
	WIN_TOP		.184
	WIN_LEFT	.0
	WIN_FONT 	FT_MEDIUM
	WIN_INVERT	.0					; Init new Wordprocessor
	bsf		leftbind
	bsf		ignore_digit5		; do not display 1cm depth
	output_16dp	d'3'
	bcf		leftbind
	bcf		show_last3
	call	word_processor
	WIN_FONT 	FT_SMALL
	return

maxdepth_greater_99_84mtr:			; Display only in full meters
	btfss	maxdepth_greater_100m	; Is max.depth>100m already?
	call	PLED_clear_maxdepth		; No, clear maxdepth area and set flag
	; max Depth is already in hi:lo
	; Show max depth in Full meters
	; That means ignore figure 4 and 5
	lfsr	FSR2,letter
	call	PLED_standard_color
	WIN_TOP		.184
	WIN_LEFT	.0
	WIN_FONT 	FT_MEDIUM
	WIN_INVERT	.0					; Init new Wordprocessor

	bsf		ignore_digit4
	bsf		leftbind
	output_16
	bcf		leftbind
	call	word_processor
	bcf		ignore_digit4
	WIN_FONT 	FT_SMALL
	return

PLED_clear_maxdepth:
	movlw	.0
	movff	WREG,box_temp+0		; Data
	movlw	.184
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.215
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.0
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.41
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_box
	bsf		maxdepth_greater_100m	; Set Flag
	return

PLED_divemins:
	btfsc	menubit					; Divemode menu active?
	return							; Yes, do not update divetime

	ostc_debug	'A'		; Sends debug-information to screen if debugmode active

	btfsc	gauge_mode				; different display in gauge mode
	bra		PLED_divemins_gauge

	btfsc	FLAG_apnoe_mode			; different display in apnoe mode
	bra		PLED_divemins_apnoe

	GETCUSTOM8	d'38'		; Show seconds (=1?)
	movwf	lo
	movlw	d'1'
	cpfseq	lo					; =1?
	bra		PLED_divemins2		; No, minutes only
	bra		PLED_divemins_gauge	; Yes, use Gauge routine
	
PLED_divemins2:
	movff	divemins+0,lo
	movff	divemins+1,hi
	bcf		leftbind
	lfsr	FSR2,letter
	output_16_3	; displays only last three figures from a 16Bit value (0-999)
	WIN_TOP		.20
	WIN_LEFT	.120
	WIN_FONT	FT_MEDIUM
	call	PLED_standard_color

	call	word_processor
	WIN_FONT	FT_SMALL
	return

PLED_display_apnoe_surface:
	btfsc	menubit					; Divemode menu active?
	return							; Yes, do not display surface mode timeout

	call		PLED_divemask_color	; Set Color for Divemode mask
	DISPLAYTEXT	d'140'			; "SURFACE"
	call	PLED_standard_color


	WIN_TOP		.85
	WIN_LEFT	.90
	WIN_FONT	FT_MEDIUM
	call	PLED_standard_color


	movff	apnoe_surface_mins,lo
	bcf		leftbind
	lfsr	FSR2,letter
	output_8
	movlw	':'
	movwf	POSTINC2
	movff	apnoe_surface_secs,lo
	output_99x
	call	word_processor
	WIN_FONT	FT_SMALL
	return

PLED_apnoe_clear_surface:
	; Clear Surface timer....
	movlw	.0
	movff	WREG,box_temp+0		; Data
	movlw	.60
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.119
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.90
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.159	
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_box
	return


PLED_display_apnoe_descent:
	call		PLED_divemask_color	; Set Color for Divemode mask
	DISPLAYTEXT		d'139'			; "Descent"
	call	PLED_standard_color


	WIN_TOP		.145
	WIN_LEFT	.90
	WIN_FONT	FT_MEDIUM
	call	PLED_standard_color


	movff	apnoe_mins,lo
	lfsr	FSR2,letter
	output_8
	movlw	':'
	movwf	POSTINC2
	movff	apnoe_secs,lo
	output_99x
	call	word_processor
	WIN_FONT	FT_SMALL
	return
	
PLED_divemins_apnoe:

PLED_divemins_gauge:
	movff	divemins+0,lo
	movff	divemins+1,hi
	bcf		leftbind
	bsf		show_last3
	lfsr	FSR2,letter
	output_16_3					;Displays only 0...999
	movlw	':'
	movwf	POSTINC2
	movff	divesecs,lo
	output_99x
	WIN_TOP		.20
	WIN_LEFT	.90
	WIN_FONT	FT_MEDIUM
	call	PLED_standard_color

	call	word_processor
	bcf		show_last3
	WIN_FONT	FT_SMALL
	return

;PLED_stopwatch_remove:
;	movlw	.0
;	movff	WREG,box_temp+0		; Data
;	movlw	.54
;	movff	WREG,box_temp+1		; row top (0-239)
;	movlw	.102
;	movff	WREG,box_temp+2		; row bottom (0-239)
;	movlw	.062
;	movff	WREG,box_temp+3		; column left (0-159)
;	movlw	.159	
;	movff	WREG,box_temp+4		; column right (0-159)
;	call	PLED_box
;	return
	

PLED_stopwatch_show:
	ostc_debug	'V'		; Sends debug-information to screen if debugmode active
	; Stopwatch

	call		PLED_divemask_color	; Set Color for Divemode mask
	DISPLAYTEXTH	d'283'			; Stopwatch
	call	PLED_standard_color

	WIN_TOP		.192
	WIN_LEFT	.110
	WIN_FONT	FT_SMALL
	call	PLED_standard_color

	lfsr	FSR2,letter
	movff	average_divesecs+0,lo				; Stopwatch
	movff	average_divesecs+1,hi				; Stopwatch
	movlw	d'2'
	subwf	lo,F
	movlw	d'0'
	subwfb	hi,F						; Subtract 2 seconds

	call	convert_time				; converts hi:lo in seconds to mins (hi) and secs (lo)

	movff	lo,wait_temp
	movff	hi,lo
	clrf	hi	

	movlw	d'0'
	bcf		leftbind
	bsf		show_last3
	output_16_3					;Displays only 0...999
	movlw	':'
	movwf	POSTINC2
	movff	wait_temp,lo
	output_99x
	bcf		leftbind
	call	word_processor

	ostc_debug	'U'				; Sends debug-information to screen if debugmode active

	WIN_TOP		.216
	WIN_LEFT	.110
	WIN_FONT	FT_SMALL
	call	PLED_standard_color


	lfsr	FSR2,letter
	movff	avr_rel_pressure+0,lo
	movff	avr_rel_pressure+1,hi
	call	adjust_depth_with_salinity			; computes salinity setting into lo:hi [mBar]
	bsf		ignore_digit5		; do not display 1cm depth
	output_16dp	d'3'
	bcf		leftbind
	movlw	'm'
	movwf	POSTINC2
	call	word_processor
	return


PLED_serial:			; Writes OSTC #Serial and Firmware version in surfacemode
	ostc_debug	'a'		; Sends debug-information to screen if debugmode active
	WIN_TOP		.0
	WIN_LEFT	.1
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color


	lfsr	FSR2,letter
	movlw   0x85                        ; New aa_font_28 5 grays HW logo.
	movwf   POSTINC2
	movlw   0x86
	movwf   POSTINC2
	movlw   ' '
	movwf   POSTINC2
	movwf   POSTINC2
	
	OUTPUTTEXTH		d'262'			; "OSTC "
	clrf	EEADRH
	clrf	EEADR				; Get Serial number LOW
	call	read_eeprom					; read byte
	movff	EEDATA,lo
	incf	EEADR,F				; Get Serial number HIGH
	call	read_eeprom					; read byte
	movff	EEDATA,hi

	bsf		leftbind
	output_16
	movlw	' '
	movwf	POSTINC2
	movlw	'V'
	movwf	POSTINC2
	movlw	softwareversion_x
	movwf	lo
	bsf		leftbind
	output_8
	movlw	'.'
	movwf	POSTINC2
	movlw	softwareversion_y
	movwf	lo
	bsf		leftbind
	output_99x
	bcf		leftbind
	
	call	word_processor
	return

PLED_divemode_menu_mask_first:			; Write Divemode menu1 mask
	ostc_debug	'o'		; Sends debug-information to screen if debugmode active
	call	PLED_menu_clear			; clear "Menu?"

	btfsc	FLAG_const_ppO2_mode	; are we in ppO2 mode?
	bra		PLED_divemode_menu_mask_first2

; in OC Mode
	DISPLAYTEXT	.32					;"Gaslist"
	DISPLAYTEXT	.31					;"Decoplan"
	DISPLAYTEXT	.122				;"Set Gas"
	bra		PLED_divemode_menu_mask_first3

PLED_divemode_menu_mask_first2:
; in CC Mode
	DISPLAYTEXT	.238				;"SetPoint"
	DISPLAYTEXT	.31					;"Decoplan"
	DISPLAYTEXT	.137				;"Bailout"

PLED_divemode_menu_mask_first3:
; In all modes
	DISPLAYTEXT	.33					;"More"
	DISPLAYTEXT	.34					;"Exit"
	return							

PLED_divemode_menu_mask_second:			; Write Divemode menu1 mask
	ostc_debug	'o'		; Sends debug-information to screen if debugmode active
	DISPLAYTEXT	.240				;"Graphs"
	DISPLAYTEXT	.241				;"Display"
	DISPLAYTEXTH .281				;"L. Tissue"
	DISPLAYTEXT	.147				;"Stopwat."
	DISPLAYTEXT	.244				;"Exit"
	return

PLED_divemode_set_xgas:				; Displayes the "Set Gas" menu
	WIN_LEFT	.100
	WIN_TOP		.0
	WIN_FONT	FT_SMALL
	call	PLED_standard_color

	lfsr	FSR2,letter	
	movlw	'S'
	movwf	POSTINC2
	movlw	'e'
	movwf	POSTINC2
	movlw	'l'
	movwf	POSTINC2
	read_int_eeprom	d'24'			; Get Gas6 %O2
	movff	EEDATA,lo
	bcf		leftbind
	output_99					; outputs into Postinc2!
	movlw	'/'
	movwf	POSTINC2
	read_int_eeprom	d'25'			; Get Gas6 %He
	movff	EEDATA,lo
	output_99					; outputs into Postinc2!
	call	word_processor
	DISPLAYTEXT	.123			; O2 +
	DISPLAYTEXT	.124			; O2 -
	DISPLAYTEXT	.125			; He +
	DISPLAYTEXT	.126			; He -
	return

PLED_divemode_simulator_mask:
	DISPLAYTEXT	.254			; EXIT
	DISPLAYTEXT	.250			; + 1m
	DISPLAYTEXT	.251			; - 1m
	DISPLAYTEXT	.252			; +10m
	DISPLAYTEXT	.253			; -10m
	return

PLED_decoplan_bargraph:
	GETCUSTOM8	d'35'				; Standard output color
	movff	WREG,box_temp+0			; Data
	movff	hi,win_top
	incf	win_top,F				; +1
	movff	win_top,box_temp+1		; row top (0-239)
	movff	win_top,box_temp+2		; 
	movlw	d'18'
	addwf	box_temp+2,F			; row bottom (0-239)
	movlw	.122
	movff	WREG,box_temp+3			; column left (0-159)
	addwf	lo,F					; Add time offset
	btfsc	STATUS,C				; >255?
	setf	lo						; limit to 255
	decf	lo,F					; No, minus one
	movlw	d'138'					; Limit length (16min)
	cpfslt	lo
	movwf	lo					
	movff	lo,box_temp+4			; column right (0-159)
	call	PLED_box
	
	movlw	.0
	movff	WREG,box_temp+0			; Data
	movff	win_top,box_temp+1		; row top (0-239)
	movff	win_top,box_temp+2		; 
	movlw	d'18'
	addwf	box_temp+2,F			; row bottom (0-239)
	movff	lo,box_temp+3			; 
	incf	box_temp+3,F			; column left (0-159)
	movlw	.139
	movff	WREG,box_temp+4			; column right (0-159)
	call	PLED_box
	return

PLED_decoplan_delete_gf:		; Delete unused rows
	movlw	.238
	movff	WREG,box_temp+2	; row bottom (0-239)
	bra		PLED_decoplan_delete_common

PLED_decoplan_delete:			; Delete unused rows
	movlw	.184
	movff	WREG,box_temp+2	; row bottom (0-239)
PLED_decoplan_delete_common:
	movlw	.0
	movff	WREG,box_temp+0	; data 00, x0, 0y, xy clear, links, rechts, beide
	movff	hi,box_temp+1	; row top (0-239)
	movlw	.100
	movff	WREG,box_temp+3	; column left (0-159)
	movlw	.159	
	movff	WREG,box_temp+4	; column right (0-159)
	call	PLED_box				
	bsf		last_ceiling_gf_shown		; Set flag
	return


PLED_decoplan_gf_page_current:
	movlw	d'0'
	cpfseq	temp8
	bra		PLED_decoplan_gf_page2				; =1: Dispplay Page 2
	bra		PLED_decoplan_gf_page1				; =0, Display Page 1

PLED_decoplan_gf_page1:
	ostc_debug	'n'		; Sends debug-information to screen if debugmode active

	movff	char_O_array_decodepth+0,lo		; Get Depth
	tstfsz	lo
	bra		PLED_decoplan_gf_page1x
	; No Deco, show "no Deco"
	DISPLAYTEXT	d'239'						;"No Deco"
	return

PLED_decoplan_gf_page2:
	; temp7 holds last displayed depth
	; temp5 list entry
	movff	temp5,temp9		; save
	movff	temp7,temp10	; save
	movlw	.231
	movwf	temp6			; row
PLED_decoplan_gf_page2y:
	movlw	d'3'
	addwf	temp7,F			; Add 3m for next stop
	movlw	d'25'
	addwf	temp6,F
	incf	temp5,F
	call	PLED_decoplan_show_stop_gf
	movlw	d'15'			; the next 8 Stops...
	cpfseq	temp5
	bra		PLED_decoplan_gf_page2y
	movff	temp9,temp5			; restore
	movff	temp10,temp7		; restore
	bsf		last_ceiling_gf_shown		; Set flag
	return

PLED_decoplan_gf_page1x:
	clrf	temp8				; Page 0-3 of deco list
	GETCUSTOM8	d'29'			; Last Deco in m
	movwf	temp7				; Start with last stop
	setf	temp5
	movlw	.231
	movwf	temp6			; row

	; Show last stop manually
	movlw	d'25'
	addwf	temp6,F
	incf	temp5,F
	call	PLED_decoplan_show_stop_gf
	GETCUSTOM8	d'29'			; Last Deco in m
	movwf	temp7				; Last deco
	movlw	d'4'
	cpfslt	temp7				; >=3m?
	bra		PLED_decoplan_gf_page1x_next_6m

	movlw	d'3'
	movwf	temp7
	bra		PLED_decoplan_gf_page1y

PLED_decoplan_gf_page1x_next_6m:
	movlw	d'6'
	movwf	temp7
	incf	temp5,F
PLED_decoplan_gf_page1y:
	movlw	d'3'
	addwf	temp7,F			; Add 3m for next stop
	movlw	d'25'
	addwf	temp6,F
	incf	temp5,F
	call	PLED_decoplan_show_stop_gf
	movlw	d'7'			; the next 7 Stops...
	cpfseq	temp5
	bra		PLED_decoplan_gf_page1y
	return


PLED_decoplan_show_stop_gf:
	bsf		leftbind
	WIN_LEFT	.100
	movff	temp6,win_top
	movff	temp6,hi						; copy for PLED_decoplan_bargraph

	movff	char_O_array_decodepth+0,WREG	; Ceiling
	cpfslt	temp7							; Ceiling already displayed?
	goto	PLED_decoplan_delete_gf			; Yes, quit display	and RETURN	
	movff	temp7,lo						; Decodepth

	lfsr	FSR2,letter		
	output_99x								; outputs into Postinc2!
	movlw	'm'
	movwf	POSTINC2
	call	word_processor	
	WIN_LEFT	.140
	movff	temp6,win_top
;	lfsr	FSR1,0x251
	lfsr	FSR1,0x0E1						; Gf_decolist_copy
	movf	temp5,W							; number of entry
	movff	PLUSW1,lo						; Stop length
	incf	lo,F							; add one dummy minute
	lfsr	FSR2,letter	
	output_99x								; outputs into Postinc2!
	movlw	d'39'							;"'"
	movwf	POSTINC2
	call	word_processor	
	tstfsz	lo								; 0 min "Stop"?
	rcall	PLED_decoplan_bargraph			; draws a box representing the decotime (stored in lo...) for this depth
	return


PLED_decoplan:				; display the Decoplan
	ostc_debug	'n'		; Sends debug-information to screen if debugmode active

	movff	char_O_array_decodepth+0,lo		; Get Depth
	tstfsz	lo
	bra		PLED_decoplan1
	; No Deco, show "no Deco"
;	call	PLED_clear_divemode_menu		; Clear Deco area
	DISPLAYTEXT	d'239'						;"No Deco"
	return

PLED_decoplan1:
	setf	temp5
	movlw	.231
	movwf	temp6			; row
PLED_decoplan2:
	movlw	d'25'
	addwf	temp6,F
	incf	temp5,F
	call	PLED_decoplan_show_stop
	movlw	d'5'			; 6 Stops...
	cpfseq	temp5
	bra		PLED_decoplan2
	return

PLED_decoplan_show_stop:
	bsf		leftbind
	WIN_LEFT	.100
	movff	temp6,win_top
	movff	temp6,hi						; copy for PLED_decoplan_bargraph

	lfsr	FSR1,char_O_array_decodepth;+0
	movf	temp5,W							; number of entry
	movff	PLUSW1,lo
	movf	lo,w
	btfsc	STATUS,Z						; =0
	goto	PLED_decoplan_delete			; Yes, quit display		

	lfsr	FSR2,letter		
	output_8								; outputs into Postinc2!
	movlw	'm'
	movwf	POSTINC2
	call	word_processor	

	WIN_LEFT	.140
	movff	temp6,win_top

	lfsr	FSR1,char_O_array_decotime;+0
	movf	temp5,W							; number of entry
	movff	PLUSW1,lo

	lfsr	FSR2,letter	
	output_99x								; outputs into Postinc2!
	movlw	d'39'							;"'"
	movwf	POSTINC2
	call	word_processor	
	tstfsz	lo								; 0 min "Stop"?
	rcall	PLED_decoplan_bargraph			; draws a box representing the decotime (stored in lo...) for this depth
	return


PLED_gas_list:
	ostc_debug	'm'		; Sends debug-information to screen if debugmode active

	WIN_LEFT	.100
	WIN_FONT	FT_SMALL
	bsf		leftbind
	
	movlw	d'2'
	movwf	wait_temp			; here: stores eeprom address for gas list
	movlw	d'231'
	movwf	waitms_temp			; here: stores row for gas list
	clrf	hi					; here: Gas counter

PLED_gas_list_loop:
	incf	hi,F				; Increase Gas
	movlw	d'4'
	addwf	wait_temp,F			; Increase eeprom address for gas list
	movlw	d'25'
	addwf	waitms_temp,F		; Increase row
	WIN_LEFT	.100
	movff	waitms_temp,win_top ; Set Row
	
	lfsr	FSR2,letter		
	movlw	'G'
	movwf	POSTINC2
	movff	hi,lo			; copy gas number
	output_8				; display gas number
	movlw	':'
	movwf	POSTINC2
	movff	wait_temp, EEADR; Gas #hi: %O2 - Set address in internal EEPROM
	call	read_eeprom		; get byte (stored in EEDATA)
	movff	EEDATA,lo		; copy to lo
	output_8				; outputs into Postinc2!
	movlw	'/'
	movwf	POSTINC2
	incf	EEADR,F			; Gas #hi: %He - Set address in internal EEPROM
	call	read_eeprom		; get byte (stored in EEDATA)
	movff	EEDATA,lo		; copy to lo
	output_8				; outputs into Postinc2!

	decf	EEADR,F			; Gas #hi: %O2 - Set address in internal EEPROM
	call	read_eeprom		; get byte (stored in EEDATA)
	PLED_color_code		warn_gas_in_gaslist		; Color-code output	(%O2 in "EEDATA")
; Check if gas needs to be greyed-out (inactive)	
	read_int_eeprom		d'27'	; read flag register
	movff	hi,lo			; copy gas number
PLED_gas_list_loop1:
	rrcf	EEDATA			; roll flags into carry
	decfsz	lo,F			; max. 5 times...
	bra		PLED_gas_list_loop1

	movlw	color_grey
	btfss	STATUS,C		; test carry
	call	PLED_set_color	; grey out inactive gases!
	
	call	word_processor	
	call	PLED_standard_color	

	movlw	d'5'			; list all five gases
	cpfseq	hi				; All gases shown?
	bra		PLED_gas_list_loop	; No
	
	return							; No, return (OC mode)

PLED_splist_start:	
	WIN_LEFT	.100
	WIN_FONT	FT_SMALL
	bsf		leftbind

	; list three SP in Gaslist
	movlw	d'35'				; 36 = current SP position in EEPROM
	movwf	wait_temp			; here: stores eeprom address for gas list
	movlw	d'231'
	movwf	waitms_temp			; here: stores row for gas list
	clrf 	temp5				; here: SP counter

PLED_splist_loop:
	incf	wait_temp,F			; EEPROM address
	incf	temp5,F			; Increase SP

	movlw	d'25'
	addwf	waitms_temp,F		; Increase row
	movff	waitms_temp,win_top ; Set Row
	WIN_LEFT	.100
	
	lfsr	FSR2,letter		
	movlw	'S'
	movwf	POSTINC2
	movlw	'P'
	movwf	POSTINC2
	movff	temp5,lo		; copy gas number
	output_8				; display gas number
	movlw	':'
	movwf	POSTINC2
	movff	wait_temp, EEADR; SP #hi position
	call	read_eeprom		; get byte (stored in EEDATA)
	movff	EEDATA,lo		; copy to lo
	clrf	hi
	output_16dp	d'3'		; outputs into Postinc2!
	call	word_processor	

	movlw	d'3'		; list all three SP
	cpfseq	temp5		; All gases shown?
	bra		PLED_splist_loop	; No

	bcf		leftbind
	return						; no, return

PLED_clear_divemode_menu:
	movlw	.0
	movff	WREG,box_temp+0		; Data
	movlw	.0
	movff	WREG,box_temp+1		; row top (0-239)
;	movlw	.125
	movlw	.185
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.082
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.159	
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_box
	return

PLED_divemenu_cursor:
	ostc_debug	'l'		; Sends debug-information to screen if debugmode active
	WIN_TOP		.0
	WIN_LEFT	.85
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color

	lfsr	FSR2,letter
	movlw	0xB8
	movwf	POSTINC2
	call	word_processor

	WIN_TOP		.25
	lfsr	FSR2,letter
	movlw	0xB8
	movwf	POSTINC2
	call	word_processor

	WIN_TOP		.50
	lfsr	FSR2,letter
	movlw	0xB8
	movwf	POSTINC2
	call	word_processor

	WIN_TOP		.75
	lfsr	FSR2,letter
	movlw	0xB8
	movwf	POSTINC2
	call	word_processor

	WIN_TOP		.100
	lfsr	FSR2,letter
	movlw	0xB8
	movwf	POSTINC2
	call	word_processor

	movff	menupos,temp1
	movlw	d'0'
	dcfsnz	temp1,F
	movlw	d'0'
	dcfsnz	temp1,F
	movlw	d'25'
	dcfsnz	temp1,F
	movlw	d'50'
	dcfsnz	temp1,F
	movlw	d'75'
	dcfsnz	temp1,F
	movlw	d'100'
	movff	WREG,win_top

	lfsr	FSR2,letter
	movlw	0xB7			; Arrow for menu
	movwf	POSTINC2
	call	word_processor
	return

;PLED_profileview_menu:
;	DISPLAYTEXT	.127					;"Exit"
;	DISPLAYTEXT	.128					;"Delete"
;;	DISPLAYTEXT	.132					;"Format"
;	return

custom_warn_surfmode:			; With CF in temp1
	movlw	.0
	movff	WREG,box_temp+0		; Data
	movlw	.56
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.88
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.69
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.115
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_box

	GETCUSTOM8	d'35'			; Standard output color
	movff	WREG,box_temp+0		; Data
	movlw	.58
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.86
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.70
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.114
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_frame
	; warning text

	WIN_TOP		.60
	WIN_LEFT	.71
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.1					; Init new Wordprocessor
	call	PLED_warnings_color		; Set Color for Warning
 	lfsr	FSR2,letter
	movlw	'C'
	movwf	POSTINC2
	movlw	'F'
	movwf	POSTINC2
	movff	temp1,lo
	output_8
	movlw	'!'
	movwf	POSTINC2
	call	word_processor

	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color
	return

PLED_saturation_graph_divemode:
	ostc_debug	'h'		; Sends debug-information to screen if debugmode active
PLED_tissue_saturation_graph:
	ostc_debug	'i'		; Sends debug-information to screen if debugmode active

; Clear graph area...
	movlw	.0
	movff	WREG,box_temp+0		; Data
	movlw	.25
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.120
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.82
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.159
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_box

; Draw Frame
	GETCUSTOM8	d'35'			; Standard output color
	movff	WREG,box_temp+0		; Data
	movlw	.25
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.120
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.82
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.159
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_frame

; Draw N2 Tissues
	lfsr	FSR2, char_O_tissue_saturation+.000	; N2
	movlw	d'16'
	movwf	wait_temp		; 16 tissues
	clrf	waitms_temp		; Row offset
PLED_tissue_saturation_graph3:
	GETCUSTOM8	d'35'			; Standard output color
	movff	WREG,box_temp+0		; Data
	movlw	.28
	addwf	waitms_temp,W
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.28
	addwf	waitms_temp,W
	movff	WREG,box_temp+2		; row bottom (0-239)

	incf	waitms_temp,F
	incf	waitms_temp,F

	movlw	.100
	movff	WREG,box_temp+3		; column left (0-159)

	movff	POSTINC2,box_temp+4
	bcf		STATUS,C
	rrcf	box_temp+4,F
	bcf		STATUS,C
	rrcf	box_temp+4,F		
	movlw	.100
	addwf	box_temp+4,F		; column right (0-159)

	movlw	d'157'							; limit display 
	cpfslt	box_temp+4						; skip if 157 (WREG) < box_temp+4
	movwf	box_temp+4

	call	PLED_box	

	decfsz	wait_temp,F
	bra		PLED_tissue_saturation_graph3

; Draw He Tissues
	lfsr	FSR2, char_O_tissue_saturation+.016	; He
	movlw	d'16'
	movwf	wait_temp		; 16 tissues
	clrf	waitms_temp		; Row offset
PLED_tissue_saturation_graph2:
	GETCUSTOM8	d'35'			; Standard output color
	movff	WREG,box_temp+0		; Data
	movlw	.86
	addwf	waitms_temp,W
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.86
	addwf	waitms_temp,W
	movff	WREG,box_temp+2		; row bottom (0-239)

	incf	waitms_temp,F
	incf	waitms_temp,F

	movlw	.100
	movff	WREG,box_temp+3		; column left (0-159)

	movff	POSTINC2,box_temp+4
	bcf		STATUS,C
	rrcf	box_temp+4,F
	bcf		STATUS,C
	rrcf	box_temp+4,F		
	movlw	.100
	addwf	box_temp+4,F		; column right (0-159)

	movlw	d'157'							; limit display 
	cpfslt	box_temp+4						; skip if 157 (WREG) < box_temp+4
	movwf	box_temp+4

	call	PLED_box	

	decfsz	wait_temp,F
	bra		PLED_tissue_saturation_graph2

; Draw Text
	WIN_LEFT	.84
	WIN_TOP		.32
	call	PLED_standard_color
	lfsr	FSR2,letter
	movlw	'N'
	movwf	POSTINC2
	movlw	'2'
	movwf	POSTINC2
	call	word_processor
	WIN_LEFT	.84
	WIN_TOP		.90
	call	PLED_standard_color
	lfsr	FSR2,letter
	movlw	'H'
	movwf	POSTINC2
	movlw	'e'
	movwf	POSTINC2
	call	word_processor

	movff	char_O_gtissue_no,wait_temp			; used as temp

	lfsr	FSR2,letter
	lfsr	FSR1,char_O_tissue_saturation+0
	incf	wait_temp,F			; make 1-16 of 0-15
PLED_tissue_saturation_graph4:		; point to leading tissue...
	movff	POSTINC1,lo			; copy/overwrite to lo register
	decfsz	wait_temp,F			; count until zero
	bra		PLED_tissue_saturation_graph4	;loop
	output_8
	movlw	'%'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	WIN_LEFT	.84
	WIN_TOP		.62
	WIN_FONT	FT_SMALL
	call	PLED_standard_color
	call	word_processor
	bcf		leftbind

; Draw Scale
	GETCUSTOM8	d'35'			; Standard output color
	movff	WREG,box_temp+0		; Data
	movlw	.73
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.74
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.121
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.157
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_frame

	GETCUSTOM8	d'35'			; Standard output color
	movff	WREG,box_temp+0		; Data
	movlw	.61
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.84
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.121
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.122
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_box
	GETCUSTOM8	d'35'			; Standard output color
	movff	WREG,box_temp+0		; Data
	movlw	.65
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.80
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.121+.9
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.122+.9
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_box
	GETCUSTOM8	d'35'			; Standard output color
	movff	WREG,box_temp+0		; Data
	movlw	.65
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.80
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.121+.18
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.122+.18
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_box
	GETCUSTOM8	d'35'			; Standard output color
	movff	WREG,box_temp+0		; Data
	movlw	.65
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.80
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.121+.27
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.122+.27
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_box
	GETCUSTOM8	d'35'			; Standard output color
	movff	WREG,box_temp+0		; Data
	movlw	.61
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.84
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.121+.36
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.122+.36
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_box

	return


PLED_startupscreen1:
	call	PLED_topline_box
	WIN_INVERT	.1	; Init new Wordprocessor
	DISPLAYTEXT d'3'			; "HeinrichsWeikamp"
	WIN_INVERT	.0	; Init new Wordprocessor
	DISPLAYTEXT	.68				; Licence 1/2
	DISPLAYTEXT	.69
	DISPLAYTEXT	.70
	DISPLAYTEXT	.71
	DISPLAYTEXT	.72
	DISPLAYTEXT	.73
	DISPLAYTEXT	.74
	return

PLED_startupscreen2:
	call	PLED_topline_box
	WIN_INVERT	.1	; Init new Wordprocessor
	DISPLAYTEXT d'3'			; "HeinrichsWeikamp"
	WIN_INVERT	.0	; Init new Wordprocessor
	DISPLAYTEXT	.75				; Licence 2/2
	DISPLAYTEXT	.76
	DISPLAYTEXT	.77
	DISPLAYTEXT	.78
	DISPLAYTEXT	.79
	DISPLAYTEXT	.80
	DISPLAYTEXT	.81
	return

PLED_new_cf_warning:
	call	PLED_topline_box
	WIN_INVERT	.1	; Init new Wordprocessor	
	DISPLAYTEXTH	.271		; New CF added!
	WIN_INVERT	.0	; Init new Wordprocessor	
	DISPLAYTEXTH .272		; New CustomFunctions
	DISPLAYTEXTH .273		; were added! Check
	DISPLAYTEXTH .274		; CF I and CF II Menu
	DISPLAYTEXTH .275		; for Details!
	return

PLED_const_ppO2_value:
	btfsc	multi_gf_display			; Is the Multi-GF Table displayed?
	return								; Yes, No update and return!

	ostc_debug	'j'		; Sends debug-information to screen if debugmode active
	
	WIN_TOP		.168
	WIN_LEFT 	.50
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor

	lfsr	FSR2,letter
	movff	char_I_const_ppO2,lo
	
	tstfsz	lo						; In Bailout mode (char_I_const_ppO2=0)?
	bra		PLED_const_ppO2_value2	; No, display Setpoint

; Yes, Display "Bail"
	call		PLED_standard_color
	OUTPUTTEXTH		d'263'			;"Bail"
	call	word_processor
	return

PLED_const_ppO2_value2:				; Display SetPoint
;Show fixed SP value
	movff		amb_pressure+0,xA+0
	movff		amb_pressure+1,xA+1
	movlw		d'10'
	movwf		xB+0
	clrf		xB+1
	;xA/xB=xC with xA as remainder 	
	call		div16x16				; xC+0=p_amb/10

	; char_I_const_ppO2 > p_amb/10 -> Not physically possible! -> Display actual value!
	tstfsz	xC+1				; xC>255
	setf	xC+0				; Yes, set xC+0 to 2,55bar ppO2

	movff		ppO2_setpoint_store,WREG
	cpfslt		xC+0							; Setpoint value possible?
	bra			PLED_const_ppO2_value1			; Yes

	movff		xC+0,char_I_const_ppO2			; No, Overwrite with actual value
	bra			PLED_const_ppO2_value1a

PLED_const_ppO2_value1:
	; char_I_const_ppO2 < ppO2[Diluent] -> Not physically possible! -> Display actual value!
	movff		amb_pressure+0,xA+0
	movff		amb_pressure+1,xA+1
	movlw		d'10'
	movwf		xB+0
	clrf		xB+1
	call		div16x16				; xC=p_amb/10
	movff		xC+0,xA+0
	movff		xC+1,xA+1
	movff		char_I_O2_ratio,xB+0
	clrf		xB+1
	call		mult16x16				; xC:2=char_I_O2_ratio * p_amb/10

	movff		xC+0,sub_b+0
	movff		xC+1,sub_b+1
	movff		ppO2_setpoint_store,WREG; Setpoint
	mullw		d'100'					; Setpoint*100
	movff		PRODL,sub_a+0
	movff		PRODH,sub_a+1
	call		sub16					; sub_c = sub_a - sub_b

	btfss		neg_flag
	bra			PLED_const_ppO2_value11			; Value in range

	; char_I_const_ppO2 < ppO2[Diluent] -> Not physically possible! -> Display actual value!

	movff		xC+0,xA+0
	movff		xC+1,xA+1
	movlw		d'100'
	movwf		xB+0
	clrf		xB+1
	call		div16x16				;xA/xB=xC with xA as remainder 	

	movff		xC+0,char_I_const_ppO2			; No, Overwrite with actual value
	bra			PLED_const_ppO2_value1a

PLED_const_ppO2_value11:

; Setpoint in possible limits
	movff		ppO2_setpoint_store,char_I_const_ppO2		; Restore Setpoint

PLED_const_ppO2_value1a:
	PLED_color_code		warn_ppo2		; Color-code output
	movff	char_I_const_ppO2,lo
	clrf	hi
	bsf		leftbind
	output_16dp	d'3'
	bcf		leftbind
	call	word_processor
	call	PLED_standard_color
	return

PLED_show_leading_tissue:
	call	deco_main_calc_desaturation_time	; calculate desaturation time
	movlb	b'00000001'						; select ram bank 1

	DISPLAYTEXTH	.282		; L. Tissue:
	lfsr	FSR2,letter
	movlw	'#'
	movwf	POSTINC2
	movff	char_O_gtissue_no,lo
	movff	char_O_gtissue_no,wait_temp			; used as temp
	bsf		leftbind
	output_8
	movlw	' '
	movwf	POSTINC2
	movlw	'('
	movwf	POSTINC2
	
	movlw	d'16'
	cpfslt	wait_temp
	bra		PLED_show_leading_tissue_he
	movlw	'N'
	movwf	POSTINC2
	movlw	'2'
	movwf	POSTINC2
	bra		PLED_show_leading_tissue2
PLED_show_leading_tissue_he:	
	movlw	'H'
	movwf	POSTINC2
	movlw	'e'
	movwf	POSTINC2
PLED_show_leading_tissue2:	
	movlw	')'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	WIN_LEFT	.100
	WIN_TOP		.25
	WIN_FONT	FT_SMALL
	call	PLED_standard_color
	call	word_processor

	lfsr	FSR2,letter
	lfsr	FSR1,char_O_tissue_saturation+0
	incf	wait_temp,F			; make 1-16 of 0-15
PLED_show_leading_tissue3:		; point to leading tissue...
	movff	POSTINC1,lo			; copy/overwrite to lo register
	decfsz	wait_temp,F			; count until zero
	bra		PLED_show_leading_tissue3	;loop
	output_8
	movlw	'%'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	WIN_LEFT	.100
	WIN_TOP		.50
	WIN_FONT	FT_SMALL
	call	PLED_standard_color
	call	word_processor
	bcf		leftbind
	return

PLED_topline_box_clear:			; Writes an empty box
	movlw	.0
	bra		PLED_topline_box2
PLED_topline_box:				; Writes a filled box
	GETCUSTOM8		d'35'
PLED_topline_box2:
	movff	WREG,box_temp+0		; Data
	movlw	.000
	movff	WREG,box_temp+1		; row top (0-239)
	movlw	.026
	movff	WREG,box_temp+2		; row bottom (0-239)
	movlw	.000
	movff	WREG,box_temp+3		; column left (0-159)
	movlw	.159	
	movff	WREG,box_temp+4		; column right (0-159)
	call	PLED_box
	return

PLED_display_cns:
	btfsc	multi_gf_display			; Is the Multi-GF Table displayed?
	return								; Yes, No update and return!

	btfsc	gauge_mode			; Do not display in gauge mode
	 return

	btfsc	FLAG_apnoe_mode		; Do not display in apnoe mode
	 return

	btfsc	pled_velocity_display	; Is velocity displayed?`
	 return							; Yes, do not overwrite until pled_velocity_clear was called

	ostc_debug	'k'				; Sends debug-information to screen if debugmode active

	WIN_TOP		.090
	WIN_LEFT	.0
	WIN_FONT 	FT_SMALL
	PLED_color_code		warn_cns		; Color-code CNS output
	
 	lfsr	FSR2,letter
	movlw	'C'
	movwf	POSTINC2
	movlw	'N'
	movwf	POSTINC2
	movlw	'S'
	movwf	POSTINC2
	movlw	':'
	movwf	POSTINC2
	movff	char_O_CNS_fraction,lo
	bsf		leftbind
	output_8
	bcf		leftbind
	movlw	'%'
	movwf	POSTINC2
	call	word_processor
	return

PLED_display_cns_surface:
; Check if CNS should be displayed
	movff	char_O_CNS_fraction,lo		; copy into bank1
	GETCUSTOM8	d'15'					; cns_display_high_surfacemode
	subwf	lo,W
	btfss	STATUS,C
	return								; Do not show...
	; Show CNS

	ostc_debug	'W'				; Sends debug-information to screen if debugmode active

	WIN_TOP		.175
	WIN_LEFT	.45
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	PLED_color_code		warn_cns		; Color-code CNS output
	
 	lfsr	FSR2,letter
	movlw	'C'
	movwf	POSTINC2
	movlw	'N'
	movwf	POSTINC2
	movlw	'S'
	movwf	POSTINC2
	movlw	':'
	movwf	POSTINC2
	movff	char_O_CNS_fraction,lo
	bsf		leftbind
	output_8
	bcf		leftbind
	movlw	'%'
	movwf	POSTINC2
	call	word_processor
	return


PLED_custom_text:
	read_int_eeprom	d'64'
	movlw	d'1'
	cpfseq	EEDATA						; Custom text active?
	bra		PLED_clear_custom_text		; No, Delete row
	WIN_TOP		.200
	WIN_LEFT	.0
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call		PLED_divemask_color	; Set Color for Divemode mask

	lfsr	FSR2,letter	
	movlw	d'64'
	movwf	lo
	movlw	d'24'
	movwf	hi					; counter

PLED_custom_text1:
	incf	lo,F
	call	PLED_get_custom_letter			; Get one letter for the custom text
	movlw	'}'							; End marker found?
	cpfseq	EEDATA
	bra		PLED_custom_text2			; No
	bra		PLED_custom_text3
PLED_custom_text2:
	movff	EEDATA,POSTINC2				; Copy into Postinc

	decfsz	hi,F				; Max. numbers?
	bra		PLED_custom_text1			; No, get next letters

PLED_custom_text3:
	call	word_processor
	call	PLED_standard_color
	return

PLED_get_custom_letter:
	movff	lo,EEADR			; Address for next custom text letter
	call	read_eeprom					; Read letter
	return

PLED_clear_custom_text:
	movlw		d'24'
	movwf		temp1
	WIN_TOP		.200
	WIN_LEFT	.0
	call		PLED_display_clear_common_y1
	return

PLED_simdata_screen:			;Display Pre-Dive Screen
	; List active gases/Setpoints
	btfsc	FLAG_const_ppO2_mode		; in ppO2 mode?
	bra		PLED_simdata_screen3		; Yes, display SetPoint/Sensor result list

PLED_simdata_screen2:
	ostc_debug	'm'		; Sends debug-information to screen if debugmode active

	WIN_LEFT	.0
	WIN_FONT	FT_SMALL
	bsf		leftbind
	
	movlw	d'2'
	movwf	wait_temp			; here: stores eeprom address for gas list
	movlw	d'10'
	movwf	waitms_temp		; here: stores row for gas list
	clrf	hi					; here: Gas counter

PLED_simdata_screen2_loop:
	incf	hi,F				; Increase Gas
	movlw	d'4'
	addwf	wait_temp,F			; Increase eeprom address for gas list
	
	lfsr	FSR2,letter		
	movlw	'G'
	movwf	POSTINC2
	movff	hi,lo			; copy gas number
	output_8				; display gas number
	movlw	':'
	movwf	POSTINC2
	movff	wait_temp, EEADR; Gas #hi: %O2 - Set address in internal EEPROM
	call	read_eeprom		; get byte (stored in EEDATA)
	movff	EEDATA,lo		; copy to lo
	output_8				; outputs into Postinc2!
	movlw	'/'
	movwf	POSTINC2
	incf	EEADR,F			; Gas #hi: %He - Set address in internal EEPROM
	call	read_eeprom		; get byte (stored in EEDATA)
	movff	EEDATA,lo		; copy to lo
	output_8				; outputs into Postinc2!
	movlw	' '
	movwf	POSTINC2
	movf	hi,W			; Gas number
	addlw	d'27'			; -> Adress of change depth register
	call	read_int_eeprom_1
	movff	EEDATA,lo		; Change depth in m
	output_99				; outputs into Postinc2!
	movlw	'm'
	movwf	POSTINC2
	read_int_eeprom		d'27'	; read flag register
	movff	hi,lo			; copy gas number
PLED_simdata_screen2_loop1:
	rrcf	EEDATA			; roll flags into carry
	decfsz	lo,F			; max. 5 times...
	bra		PLED_simdata_screen2_loop1
	
	btfsc	STATUS,C		; test carry
	bra		PLED_simdata_white

	movlw	color_grey
	call	PLED_set_color	; grey out inactive gases!
	bra		PLED_simdata_color_done

PLED_simdata_white:
	call	PLED_standard_color

PLED_simdata_color_done:	
	movlw	d'25'
	addwf	waitms_temp,F		; Increase row
	WIN_LEFT	.0
	movff	waitms_temp,win_top ; Set Row
	call	word_processor		; display gas

PLED_simdata_screen2b:
	call		PLED_standard_color

	movlw	d'5'			; list all five gases
	cpfseq	hi				; All gases shown?
	bra		PLED_simdata_screen2_loop	; No
	
	return							; No, return (OC mode)

PLED_simdata_screen3:	
	WIN_LEFT	.0
	WIN_FONT	FT_SMALL
	bsf		leftbind

	; list three SP in Gaslist
	movlw	d'35'				; 36 = current SP position in EEPROM
	movwf	wait_temp			; here: stores eeprom address for gas list
	movlw	d'10'
	movwf	waitms_temp			; here: stores row for gas list
	clrf 	temp6				; here: SP counter

PLED_simdata_screen3_loop:
	incf	wait_temp,F			; EEPROM address
	incf	temp6,F			; Increase SP

	movlw	d'25'
	addwf	waitms_temp,F		; Increase row
	WIN_LEFT	.0
	movff	waitms_temp,win_top ; Set Row
	
	lfsr	FSR2,letter		
	movlw	'S'
	movwf	POSTINC2
	movlw	'P'
	movwf	POSTINC2
	movff	temp6,lo		; copy gas number
	output_8				; display gas number
	movlw	':'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	movff	wait_temp, EEADR; SP #hi position
	call	read_eeprom		; get byte (stored in EEDATA)
	movff	EEDATA,lo		; copy to lo
	clrf	hi
	output_16dp	d'3'		; outputs into Postinc2!
	call	word_processor	

	movlw	d'3'		; list all three SP
	cpfseq	temp6		; All gases shown?
	bra		PLED_simdata_screen3_loop	;no

	read_int_eeprom 	d'33'			; Read byte (stored in EEDATA)
	movff	EEDATA,active_gas			; Read start gas (1-5)
	decf	active_gas,W				; Gas 0-4
	mullw	d'4'
	movf	PRODL,W			
	addlw	d'7'						; = address for He ratio
	movwf	EEADR
	call	read_eeprom					; Read He ratio
	movff	EEDATA,hi		; And copy into hold register
	decf	active_gas,W				; Gas 0-4
	mullw	d'4'
	movf	PRODL,W			
	addlw	d'6'						; = address for O2 ratio
	movwf	EEADR
	call	read_eeprom					; Read O2 ratio
	movff	EEDATA, lo		; O2 ratio

	WIN_LEFT	.0
	WIN_TOP		.110
	lfsr	FSR2,letter		
	movlw	'D'
	movwf	POSTINC2
	movlw	'i'
	movwf	POSTINC2
	movlw	'l'
	movwf	POSTINC2
	movlw	':'
	movwf	POSTINC2
	output_8				; O2 Ratio
	movlw	'/'
	movwf	POSTINC2
	movff	hi,lo
	output_8				; He Ratio
	call	word_processor		

	bcf		leftbind
	return				; Return (CC Mode)



adjust_depth_with_salinity:			; computes salinity setting into lo:hi [mBar]

	btfsc	simulatormode_active	; Do apply salinity in Simulatormode
	return

	read_int_eeprom	d'26'			; Read Salinity from EEPROM
	movff	EEDATA, wait_temp		; salinity
	
	movlw	d'105'					; 105% ?
	cpfslt	wait_temp				; Salinity higher limit
	return							; Out of limit, do not adjust lo:hi
	
	movlw	d'99'					; 99% ?
	cpfsgt	wait_temp				; Salinity lower limit
	return							; Out of limit, do not adjust lo:hi

	movff	lo,xA+0
	movff	hi,xA+1

	movlw	d'100'
	movwf	xB+0
	clrf	xB+1
	
	call	mult16x16				;xA*xB=xC (lo:hi * 100)
	
	movff	wait_temp,xB+0			; Salinity
	clrf	xB+1
							
	call	div32x16  				; xC:4 / xB:2 = xC+3:xC+2 with xC+1:xC+0 as remainder

	movff	xC+0,lo
	movff	xC+1,hi					; restore lo and hi with updated value
	
	return