
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


; Menu "Logbook"
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 060107
; last updated: 081026
; known bugs: 
; ToDo: 

; searches external EEPROM for dive headers and displays them in a list
; a detailed view with all informations and profile can be selected
; does not require a FAT, will work with other profile intervals as ten seconds, too

menu_logbook:
	bcf		return_from_profileview				; clear some flags
;call	enable_rs232
menu_logbook1:
	bcf			logbook_header_drawn
	call		PLED_ClearScreen				; Clear screen
	bcf			all_dives_shown					; clear some flags
	bcf			logbook_profile_view
	bcf			logbook_page_not_empty
	clrf		menupos3						; Here: used rows on current logbook-page	
	clrf		menupos2						; Here: # of current displayed page
	clrf		divenumber						; # of dive in list during search


menu_logbook1a:
	WIN_INVERT	.1
	DISPLAYTEXT	.12							;" Wait.."
	WIN_INVERT	.0
	clrf		divemins+0					; Here: used as temp variables
	clrf		divemins+1
	call 		I2CReset					; Reset I2C Bus
	call		get_free_EEPROM_location	; search from "here" backwards through the external memory
	clrf		temp1						; max. 32KB
	clrf		temp2

	movlw		d'5'
	movwf		menupos					; Here: stores current position on display (5-x)
	
menu_logbook1b:
									; search external EEPROM backwards from eeprom_address
									; for 0xFA, 0xFA (store 1st. 0xFA position for next search)
									; read header data and display it
									; wait for user to confirm/exit
									; recopy data to search from here
	WIN_INVERT	.1
	DISPLAYTEXT	.12						;" Wait.."
	WIN_INVERT	.0
	bcf		first_FA					; clear flags
	bcf		second_FA

menu_logbook2:
	movlw		d'1'						; increase 16Bit value
	addwf		divemins+0,F
	movlw		d'0'
	addwfc		divemins+1,F

	btfsc		divemins+1,7				; At 0x8000?
	bra			menu_logbook_reset			; yes, restart (if not empty)

	decf_eeprom_address	d'1'			; Macro, that subtracts 8Bit from eeprom_address:2 with banking at 0x8000
	
	call		I2CREAD					; reads one byte (Slow! Better use Blockread!)

	btfsc		first_FA					; 
	bra			test_2nd_FA

	bsf			first_FA					; Found 1st. 0xFA?
	movlw		0xFA
	cpfseq		SSPBUF
	bcf			first_FA					; No, clear flag
	bra			menu_logbook3				; and continue search

test_2nd_FA:
	btfsc		second_FA
	bra			test_FA_DONE

	bsf			second_FA					; found 2nd 0xFA?
	movlw		0xFA
	cpfseq		SSPBUF
	rcall		no_second_FA				; No, clear both flags!
	bra			menu_logbook3				; and continue search

test_FA_DONE:							; Found 0xFA 0xFA!
	movff		eeprom_address+0,eeprom_header_address+0	; store current address into temp register
	movff		eeprom_address+1,eeprom_header_address+1	; we must continue search here later
	incf		divenumber,F				; new header found, increase divenumber
	bra			menu_logbook4				; Done with searching, display the header!

no_second_FA:							; discard both flags!
	bcf			second_FA					
	bcf			first_FA			
	return


menu_logbook3:
	movlw		d'1'						; increase global counter
	addwf		temp1,F
	movlw		d'0'
	addwfc		temp2,F

	btfsc		temp2,7					; 32KB searched?
	bra			menu_logbook3b				; Yes
	bra			menu_logbook2				; No, not now


menu_logbook3b:
	btfss		logbook_page_not_empty			; Was there at least one dive?
	goto		menu						; Not a single header was found, leave logbook.
	bra		menu_logbook_display_loop2		; rcall of get_free_eeprom_location not required here (faster)

menu_logbook_reset:	
	movf		divenumber,W
	btfsc		STATUS,Z					; Was there at least one dive?
	bra		menu_logbook3b				; No, Nothing to do

	bsf		all_dives_shown				; Yes
	bra		menu_logbook_display_loop2		; rcall of get_free_eeprom_location not required here (faster)


menu_logbook4:
	; Adjust eeprom_address to set pointer on first headerbyte
	incf_eeprom_address	d'3'				; Macro, that adds 8Bit to eeprom_address:2 with banking at 0x8000

	btfss		logbook_profile_view			; Display profile (search routine is used in profileview, too)
	bra			menu_logbook_display_loop		; No, display overwiev list

	movf		divesecs,W					; divenumber that is searched
	cpfseq		divenumber					; current divenumber
	bra			next_logbook				; No match, continue search
	bra			display_profile2
	

menu_logbook_display_loop:
	btfsc		all_dives_shown				; All dives displayed?
	bra			menu_logbook_display_loop2		; Yes, but display first page again.

	rcall 		display_listdive			; display short header for list on current list position

	movlw		d'5'
	cpfseq		menupos					; first dive on list (top place)?
	bra			menu_logbook_display_loop1		; no, so skip saving of address


	movff		divenumber,mintemp+0			; store all registered required to rebuilt the current logbookpage after the detail/profile view
	movff		eeprom_header_address+0,decodata+0	; several registers are used as temp registers here
	movff		eeprom_header_address+1,decodata+1		
	movff		divemins+0,max_pressure+0			
	movff		divemins+1,max_pressure+1			
	movff		temp1,logbook_temp6
	movff		temp2,samplesecs					

	movlw		d'3'
	addwf		decodata+0,F
	movlw 		d'0'
	addwfc		decodata+1,F				; Re-Adjust pointer again
	movlw		d'3'						; So first row will be the same again after detail/profile view
	subwf		max_pressure+0,F
	movlw		d'0'
	subwfb		max_pressure+1,F

menu_logbook_display_loop1:
	decfsz	menupos,F					; List full?
	bra		next_logbook				; no, search another dive for our current logbook page

menu_logbook_display_loop2:
	btfss	logbook_page_not_empty			; Was there one dive at all?
	bra		menu_logbook				; Yes, so reload the first page

	call	PLED_topline_box			; Draw box
	WIN_INVERT	.1	
	DISPLAYTEXT	.26						; "Logbook"
	WIN_INVERT	.0
	
	DISPLAYTEXT .11						; Displays "Exit" in the last row on the current page

	bcf		sleepmode					; clear some flags for user input
	bcf		menubit2
	bcf		menubit3
	bcf		cursor
	bcf		switch_right
	bcf		switch_left
	clrf		timeout_counter2

	movlw		d'1'						; Set cursor to position 1...
	btfsc		return_from_profileview		; .. unless we are returning from a detail/profile view
	movf		mintemp+1,W					; load last cursor position again
	movwf		menupos						; and set menupos byte
	bcf			return_from_profileview		; Do this only once while the page is loaded again!

	bcf			logbook_page_not_empty			; Obviously the current page is NOT empty
	call		PLED_logbook_cursor

menu_logbook_loop:
	call		check_switches_logbook
	
	btfsc		menubit3					; SET/MENU?
	bra			next_logbook3				; adjust cursor or create new page

	btfsc		menubit2					; ENTER?
	bra			display_profile_or_exit		; view details/profile or exit logbook

	btfsc		onesecupdate
	call		timeout_surfmode			; Timeout

	btfsc		onesecupdate
	call		set_dive_modes				; Check, if divemode must be entered

	bcf			onesecupdate				; one second update 

	btfsc		sleepmode					; Timeout?
	goto		menu						; Yes

	btfsc		divemode
	goto		restart						; Enter Divemode if required

	bra			menu_logbook_loop			; Wait for something to do

display_profile_or_exit:
	bcf			menubit2					; debounce
	movlw		d'6'						; exit?
	cpfseq		menupos
	bra			display_profile				; No, show details/profile
	goto		menu

display_profile:	
	movff		menupos,mintemp+1				; store current cursor position
	bsf			return_from_profileview			; tweak search routine to exit after found

	movf		menupos2,W						; Number of page
	mullw		d'5'				
	movf		PRODL,W						
	addwf		menupos,W						; page*5+menupos=
	movwf		divesecs						; # of dive to search

	call		PLED_ClearScreen				; search for dive
	bsf			logbook_profile_view			; set flag for search routine

	clrf		divenumber					; search from scratch
	bra			menu_logbook1a				; start search
display_profile2:
	bcf			logbook_profile_view			; clear flag for search routine

	call		PLED_display_wait_clear
	WIN_TOP		.0
	WIN_LEFT	.0
	lfsr		FSR2,letter
	movlw		'#'
	movwf		POSTINC2

	GETCUSTOM15	.28							; Logbook Offset -> lo, hi
	tstfsz		lo							; lo=0?
	bra			display_profile_offset1		; No, adjust offset	
	tstfsz		hi							; hi=0?
	bra			display_profile_offset1		; No, adjust offset
	bra			display_profile_offset2		; lo=0 and hi=0 -> skip Offset routine

display_profile_offset1:
	movlw		d'1'
	addwf		lo,F
	movlw		d'0'
	addwfc		hi,F						; hi:lo = hi:lo + 1
	movff		lo,sub_a+0
	movff		hi,sub_a+1
	movff		divesecs,sub_b+0
	clrf		sub_b+1
	call		sub16						;  sub_c = sub_a - sub_b
	movff		sub_c+0,lo
	movff		sub_c+1,hi
	bsf			leftbind
	output_16dp	d'10'						; # of dive with offset
	bra			display_profile_offset3		; Skip normal routine
	
display_profile_offset2:
	movff		divesecs,lo
	output_99x							; # of dive

display_profile_offset3:
	movlw		' '
	movwf		POSTINC2
	call		I2CREAD2	
	movff		SSPBUF,lo				; 

	call		I2CREAD2				; Skip Profile version
	movff		SSPBUF,lo				; read month

;	movff		eeprom_address+0, EventByte		; Store current EEPROM position
;	movff		eeprom_address+1, ProfileFlagByte
; Offset to SamplingRate
	incf_eeprom_address	d'32'				; Macro, that adds 8Bit to eeprom_address:2 with banking at 0x8000
	call		I2CREAD						; Read Sampling rate
	movff		SSPBUF,samplesecs_value		; Copy sampling rate
	decf_eeprom_address	d'32'				; Macro, that subtracts 8Bit from eeprom_address:2 with banking at 0x8000
;	movff		EventByte, eeprom_address+0		; Re-Store current EEPROM position
;	movff		ProfileFlagByte, eeprom_address+1		; Re-Store current EEPROM position

;display_profile2a:

	movff		lo,convert_value_temp+0		; Month (in lo, see above)
	call		I2CREAD2					; Day
	movff		SSPBUF,convert_value_temp+1
	call		I2CREAD2					; Year
	movff		SSPBUF,convert_value_temp+2
	call		PLED_convert_date		; converts into "DD/MM/YY" or "MM/DD/YY" or "YY/MM/DD" in postinc2

	movlw		' '
	movwf		POSTINC2
	call		I2CREAD2					; hour
	movff		SSPBUF,lo
	output_99x			
	movlw		':'
	movwf		POSTINC2
	call		I2CREAD2					; Minute
	movff		SSPBUF,lo
	output_99x			
	call		word_processor				; Display 1st row of details

	WIN_TOP		.25
	WIN_LEFT	.05
	lfsr		FSR2,letter
	call		I2CREAD2	
	movff		SSPBUF,lo
	call		I2CREAD2	
	movff		SSPBUF,hi
	movff		lo,xA+0					; calculate y-scale for profile display
	movff		hi,xA+1
	movlw		d'164'					; 164pixel height available
	movwf		xB+0
	clrf		xB+1
	call		div16x16				; does xA/xB=xC
	movff		xC+0,sim_pressure+0		; holds LOW byte of y-scale   (mbar/pixel!)
	movff		xC+1,sim_pressure+1		; holds HIGH byte of y-scale  (mbar/pixel!)
	incf		sim_pressure+0,F		; increase one, because there may be a remainder
	movlw		d'0'
	addwfc		sim_pressure+1,F

	bsf		leftbind
	output_16dp	d'3'						; max. depth
	movlw		'm'
	movwf		POSTINC2
	movlw		' '
	movwf		POSTINC2
	call		I2CREAD2	
	movff		SSPBUF,lo
	call		I2CREAD2	
	movff		SSPBUF,hi

	movff		lo,xA+0					; calculate x-scale for profile display
	movff		hi,xA+1					; calculate total diveseconds first
	movlw		d'60'					; 60seconds are one minute
	movwf		xB+0
	clrf		xB+1
	call		mult16x16				; result is in xC:2 !

	bsf		leftbind
	output_16							; divetime minutes
	movlw		d'39'
	movwf		POSTINC2
	call		I2CREAD2	
	movff		SSPBUF,lo
	movf		lo,W					; add seconds to total seconds
	addwf		xC+0
	movlw		d'0'
	addwfc		xC+1					; xC:2 now holds total dive seconds!
	movff		xC+0,xA+0				; now calculate x-scale value
	movff		xC+1,xA+1
	movlw		d'159'					; 159pix width available
	movwf		xB+0
	clrf		xB+1
	call		div16x16				; xA/xB=xC
	movff		xC+0,xA+0	
	movff		xC+1,xA+1
	movf		samplesecs_value,W		; devide through sample interval!
	movwf		xB+0
	clrf		xB+1
	call		div16x16				; xA/xB=xC
	movff		xC+0,profile_temp+0		; store value (use any #xC sample, skip xC-1) into temp registers
	movff		xC+1,profile_temp+1		; store value (use any #xC sample, skip xC-1) into temp registers
	incf		profile_temp+0,F		; increase one, because there may be a remainder
	movlw		d'0'
	addwfc		profile_temp+1,F

	bsf		leftbind
	output_99x							; divetime seconds
	movlw		'"'
	movwf		POSTINC2
	movlw		' '
	movwf		POSTINC2
	call		I2CREAD2	
	movff		SSPBUF,lo
	call		I2CREAD2	
	movff		SSPBUF,hi
	movlw		d'3'
	movwf		ignore_digits
	bsf		leftbind
	output_16dp	d'2'						; temperature
	movlw		'°'
	movwf		POSTINC2
	movlw		'C'		
	movwf		POSTINC2
	call		word_processor				; Display 2nd row of details

	WIN_TOP		.50
	WIN_LEFT	.05
	lfsr		FSR2,letter

	call		I2CREAD2	
	movff		SSPBUF,lo
	call		I2CREAD2	
	movff		SSPBUF,hi
	bsf		leftbind
	output_16							; Air pressure before dive
	movlw		'm'
	movwf		POSTINC2
	movlw		'b'
	movwf		POSTINC2
	movlw		'a'
	movwf		POSTINC2
	movlw		'r'
	movwf		POSTINC2
	movlw		' '
	movwf		POSTINC2

	movlw		'D'
	movwf		POSTINC2
	movlw		'e'
	movwf		POSTINC2
	movlw		's'
	movwf		POSTINC2
	movlw		'a'
	movwf		POSTINC2
	movlw		't'
	movwf		POSTINC2
	movlw		' '
	movwf		POSTINC2

	call		I2CREAD2	
	movff		SSPBUF,lo
	call		I2CREAD2	
	movff		SSPBUF,hi
	call		convert_time				; converts hi:lo in minutes to hours (hi) and minutes (lo)
	bsf			leftbind
	movf		lo,W
	movff		hi,lo
	movwf		hi							; exchange lo and hi...
	output_8								; Hours
	movlw		':'
	movwf		POSTINC2
	movff		hi,lo						; Minutes
	output_99x
	bcf			leftbind
	call		word_processor				; display 3rd page of details

	call		I2CREAD2					; Skip Gas1 current O2
	call		I2CREAD2					; Skip Gas1 current HE
	call		I2CREAD2					; Skip Gas2 current O2
	call		I2CREAD2					; Skip Gas2 current HE
	call		I2CREAD2					; Skip Gas3 current O2
	call		I2CREAD2					; Skip Gas3 current HE
	call		I2CREAD2					; Skip Gas4 current O2
	call		I2CREAD2					; Skip Gas4 current HE
	call		I2CREAD2					; Skip Gas5 current O2
	call		I2CREAD2					; Skip Gas5 current HE
	call		I2CREAD2					; Skip Gas6 current O2
	call		I2CREAD2					; Skip Gas6 current HE
	call		I2CREAD2					; Skip Start Gas
	call		I2CREAD2					; Skip Firmware x
	call		I2CREAD2					; Skip Firmware y
	call		I2CREAD2					; Skip battery
	call		I2CREAD2					; Skip battery
	call		I2CREAD2					; Skip Sampling rate
	call		I2CREAD2					; Read divisor
	movff		SSPBUF,divisor_temperature	; Store divisor
	bcf			divisor_temperature,4		; Clear information length
	bcf			divisor_temperature,5
	bcf			divisor_temperature,6
	bcf			divisor_temperature,7
	incf		divisor_temperature,F		; increase divisor 
	movff		divisor_temperature,logbook_temp1		; Store as temp, too
	call		I2CREAD2					; Read divisor
	movff		SSPBUF,divisor_deco			; Store divisor
	bcf			divisor_deco,4				; Clear information length
	bcf			divisor_deco,5
	bcf			divisor_deco,6
	bcf			divisor_deco,7
	movff		divisor_deco,logbook_temp2	; Store as temp, too
	call		I2CREAD2					; Read divisor
	movff		SSPBUF,divisor_tank			; Store divisor
	call		I2CREAD2					; Read divisor
	movff		SSPBUF,divisor_ppo2			; Store divisor
	call		I2CREAD2					; Read divisor
	movff		SSPBUF,divisor_deco_debug	; Store divisor
	call		I2CREAD2					; Read divisor
	movff		SSPBUF,divisor_nuy2			; Store divisor
	call		I2CREAD2					; Read Salinity
	call		I2CREAD2					; Skip Dummy byte

display_profile2d:
	; Start Profile display
	
	movlw		color_deepblue
	movff		WREG,box_temp+0		; Data
	movlw		.75
	movff		WREG,box_temp+1		; row top (0-239)
	movlw		.239
	movff		WREG,box_temp+2		; row bottom (0-239)
	movlw		.0
	movff		WREG,box_temp+3		; column left (0-159)
	movlw		.159	
	movff		WREG,box_temp+4		; column right (0-159)
	call		PLED_box


	call		I2CREAD2					; skip 0xFB		(Header-end)
	clrf		timeout_counter2			; here: used as counter for depth readings
	call		I2CREAD2					; skip 0xFB		(Header-end)
	movlw		d'158'
	movwf		ignore_digits				; here: used as counter for x-pixels
	bcf			second_FD					; clear flag
	movlw		d'5'
	movwf		timeout_counter3			; here: used as colum x2 (Start at Colum 5)
	movlw		d'75'						; Zero-m row
	movwf		apnoe_mins					; here: used for fill between rows
	incf		timeout_counter3,W			; Init Column
	call		PLED_SetColumnPixel			; pixel x2

profile_display_loop:
	movff		profile_temp+0,profile_temp2+0
	movff		profile_temp+1,profile_temp2+1		; 16Bit x-scaler
	incf		profile_temp2+1,F					

profile_display_loop2:
	rcall		profile_view_get_depth		; reads depth, ignores temp and profile data	-> hi, lo

	btfsc		second_FD					; end-of profile reached?
	bra			profile_display_loop_done	; Yes, skip all remaining pixels

	movff		sim_pressure+0,xB+0			; devide pressure in mbar/quant for row offsett
	movff		sim_pressure+1,xB+1
	movff		lo,xA+0
	movff		hi,xA+1
	call		div16x16					; xA/xB=xC
	movlw		d'75'
	addwf		xC+0,F						; add 75 pixel offset to result
	
btfsc		STATUS,C						; Ignore potential profile errors
movff		apnoe_mins,xC+0

	call		profile_display_fill		; In this column between this row (xC+0) and the last row (apnoe_mins)
	movff		xC+0,apnoe_mins				; Store last row for fill routine
	movf		xC+0,W
	call		PLED_SetRow					; 0...259

	incf		timeout_counter3,F
	movf		timeout_counter3,W
	call		PLED_SetColumnPixel			; pixel x2
	call		PLED_standard_color
	call		PLED_PxlWrite				; Write two pixels

profile_display_skip_loop1:					; skips readings!
	dcfsnz		profile_temp2+0,F
	bra			profile_display_loop3		; check 16bit....

	rcall		profile_view_get_depth		; reads depth, ignores temp and profile data
	bra			profile_display_skip_loop1

profile_display_loop3:
	decfsz		profile_temp2+1,F			; 16 bit x-scaler test
	bra			profile_display_skip_loop1	; skips readings!

	decfsz		ignore_digits,F				; counts x-pixels to zero
	bra			profile_display_loop		; Not ready yet
; Done.
profile_display_loop_done:
	bcf			sleepmode					; clear some flags
	bcf			menubit2
	bcf			menubit3
	bcf			switch_right
	bcf			switch_left
	clrf		timeout_counter2

display_profile_loop:
	call		check_switches_logbook
	
	btfsc		menubit2					; SET/MENU?
	bra			exit_profileview			; back to list

	btfsc		menubit3					; ENTER?
	bra			exit_profileview			; back to list
;	bra			profileview_menu			; Switch to the Profileview menu

	btfsc		onesecupdate
	call		timeout_surfmode			; timeout

	btfsc		onesecupdate
	call		set_dive_modes				; check, if divemode must be entered

	bcf			onesecupdate				; one second update

	btfsc		sleepmode					; Timeout?
	bra			exit_profileview			; back to list

	btfsc		divemode
	goto		restart						; Enter Divemode if required

	bra			display_profile_loop		; wait for something to do

profile_display_fill:		; In this column between this row (xC+0) and the last row (apnoe_mins), keep xC+0!!
; First, check if xC+0>apnoe_mins or xC+0<aponoe_mins
	movf	xC+0,W
	cpfseq	apnoe_mins				; xC+0 = apone_mins?
	bra		profile_display_fill2	; No!
	return
profile_display_fill2:	
	movf	xC+0,W
	cpfsgt	apnoe_mins				; apnoe_mins>xC+0?
	bra		profile_display_fill_up	; Yes!

profile_display_fill_down:			; Fill downwards from apone_mins to xC+0!
	movff		apnoe_mins,xC+1		; Copy
profile_display_fill_down2:			; Loop	
	decf		xC+1,F
	movf		xC+1,W				; Row
	call		PLED_SetRow			; 0...259
	call		PLED_standard_color

	call		PLED_PxlWrite_Single; Write one Pixel
	movf		xC+0,W
	cpfseq		xC+1				; Loop until xC+1=xC+0
	bra			profile_display_fill_down2
	return							; apnoe_mins and xC+0 are untouched

profile_display_fill_up:			; Fill upwards from xC+0 to apone_mins!
	movff		xC+0,xC+1			; Copy
profile_display_fill_up2:			; Loop	
	decf		xC+1,F
	movf		xC+1,W				; Row
	call		PLED_SetRow			; 0...259
	call	PLED_standard_color

	call		PLED_PxlWrite_Single; Write one Pixel
	movf		apnoe_mins,W
	cpfseq		xC+1				; Loop until xC+1=apnoe_mins
	bra			profile_display_fill_up2
	return							; apnoe_mins and xC+0 are untouched

profile_view_get_depth:						
	call		I2CREAD2					; read first depth
	movff		SSPBUF,lo					; low value
	call		I2CREAD2					; read first depth
	movff		SSPBUF,hi					; high value
	call		I2CREAD2					; read Profile Flag Byte
	movff		SSPBUF,timeout_counter2		; Read Profile Flag Byte
	bcf			event_occured				; clear flag
	btfsc		timeout_counter2,7
	bsf			event_occured				; We also have an Event byte!
	bcf			timeout_counter2,7			; Clear Event Byte Flag (If any)
	; timeout_counter2 now holds the number of additional bytes to ignore (0-127)
	movlw		0xFD						; end of profile bytes?
	cpfseq		lo
	bra			profile_view_get_depth_new1	; no 0xFD
	movlw		0xFD						; end of profile bytes?
	cpfseq		hi
	bra			profile_view_get_depth_new1	; no 0xFD
	bsf			second_FD					; End found! Set Flag! Skip remaining pixels!
	return

profile_view_get_depth_new1:
;bra		profile_view_get_depth_new1_1		; Skip all data to ignore...

;	decfsz		divisor_deco,F				; Check divisor
;	bra			profile_view_get_depth_new1_1	; Divisor not zero...	
;
;;	tstfsz		timeout_counter2			; Any bytes to ignore
;;	bra			profile_view_get_depth_new2	; Yes (1-127)
;;	return									; No (0)
;
;	movff	logbook_temp2,divisor_deco		; Restore divisor value!
;; check for event byte and the extra informations
;	btfss		event_occured
;	bra			profile_view_get_depth_new2		; No event!
;	
;	call		I2CREAD2					; read event byte
;	decf		timeout_counter2,F			; Reduce number of bytes to ignore
;
;	movlw		d'0'						; Extra bytes to ignore because of event
;	btfsc		SSPBUF,4
;	addlw		d'2'						; two bytes for manual gas set
;	btfsc		SSPBUF,5
;	addlw		d'1'						; one byte for gas change
;	movwf		logbook_temp5				; store extra bytes to ignore
;
;	tstfsz		logbook_temp5				; Anything to ignore?
;	bra			profile_view_get_depth_new1_2	; Yes
;	bra			profile_view_get_depth_new2	; No, continue with normal routine
;
;profile_view_get_depth_new1_2:
;	call		I2CREAD2					; ignore byte
;	decf		timeout_counter2,F			; Reduce number of bytes to ignore
;	decfsz		logbook_temp5,F				; reduce extra bytes ignore counter
;	bra			profile_view_get_depth_new1_2	; loop
;
;profile_view_get_depth_new2:
;	movlw		d'4'							; Temp (2) and Deko (2) in the sample?
;	cpfseq		timeout_counter2
;	bra			profile_view_get_depth_new2_2	; No
;	; Yes, skip Temp!
;	call		I2CREAD2					; ignore byte
;	decf		timeout_counter2,F			; Reduce number of bytes to ignore
;	call		I2CREAD2					; ignore byte
;	decf		timeout_counter2,F			; Reduce number of bytes to ignore
;
;profile_view_get_depth_new2_2:
;	call		I2CREAD2					; ignore byte
;
;	decfsz		timeout_counter2,F			; reduce counter
;	bra			profile_view_get_depth_new2_2; Loop
;	return

profile_view_get_depth_new1_1:
	tstfsz		timeout_counter2			; Any bytes to ignore
	bra			profile_view_get_depth_new3	; Yes (1-127)
	return									; No (0)

	; timeout_counter2 now holds the number of additional bytes to ignore (0-127)
profile_view_get_depth_new3:
	call		I2CREAD2					; ignore byte
	decfsz		timeout_counter2,F			; reduce counter
	bra			profile_view_get_depth_new3	; Loop
	return

exit_profileview:
	bcf			sleepmode
	clrf		timeout_counter2				; restore all registers to build same page again
	movff		decodata+0,eeprom_address+0
	movff		decodata+1,eeprom_address+1		
	movff		max_pressure+0,divemins+0
	movff		max_pressure+1,divemins+1
	movff		mintemp+0, divenumber
	movff		logbook_temp6,temp1
	movff		samplesecs,temp2
	decf		divenumber,F
	bcf			all_dives_shown

	decf		menupos2,F	

	clrf		menupos3					; here: used row on current page
	movlw		d'5'
	movwf		menupos						; here: active row on current page
	incf		menupos2,F					; start new page
	call		PLED_ClearScreen			; clear details/profile
	bra			menu_logbook1b					; start search

next_logbook2:
	btfsc		all_dives_shown				; all shown
	goto		menu_logbook1				; all reset

	clrf		menupos3	
	movlw		d'5'
	movwf		menupos					; 
	incf		menupos2,F					; start new screen
	call		PLED_ClearScreen
	
next_logbook:
	movff		eeprom_header_address+0,eeprom_address+0
	movff		eeprom_header_address+1,eeprom_address+1	; continue search here
	goto		menu_logbook1b

check_switches_logbook:
	btfsc		switch_right			
	bsf			menubit3
	btfsc		switch_left
	bsf			menubit2					; Enter
	return

next_logbook3:
	incf		menupos,F
	movlw		d'7'
	cpfseq		menupos					; =7?
	bra			next_logbook3a				; No
	bra			next_logbook2				; yes, new page please

next_logbook3a:
	incf		menupos3,W					; 
	cpfseq		menupos
	bra			next_logbook3b
	movlw		d'6'
	movwf		menupos					; Jump directly to exit if page is not full

next_logbook3b:
	clrf		timeout_counter2
	call		PLED_logbook_cursor

	bcf			switch_right
	bcf			menubit3					; clear flag
	bra			menu_logbook_loop

display_listdive:
	bsf			logbook_page_not_empty		; Page not empty
	incf		menupos3,F					

	btfsc		logbook_header_drawn		; "Logbook already displayed?
	bra			display_listdive1a
	call		PLED_topline_box			; Draw box
	WIN_INVERT	.1
	DISPLAYTEXT	.26							; "Logbook"
	WIN_INVERT	.0
	bsf			logbook_header_drawn
	
display_listdive1a:	
	WIN_LEFT	.20
	
	movf		menupos2,W
	mullw		d'5'
	movf		PRODL,W
	subwf		divenumber,W				; current row on page

	mullw		d'30'						; x30
	movf		PRODL,W						; is pixel-row for entry
	addlw		d'5'						; +5 Pixel, so list entries are at rows 35,65,95,125,155,185
	movff		WREG,win_top

	lfsr		FSR2,letter
	movff		divenumber,lo
	output_99x								; # of dive
	movlw		' '
	movwf		POSTINC2
	call		I2CREAD2	
	movff		SSPBUF,lo
	movlw		d'13'
	cpfsgt		lo							; Skip if lo>13
	bra			display_listdive2			; use old format

	call		I2CREAD2					; Skip Profile version
	movff		SSPBUF,lo					; in new format, read month

display_listdive2:
	movff		lo,convert_value_temp+0		; Month (in lo, see above)
	call		I2CREAD2					; Day
	movff		SSPBUF,convert_value_temp+1
	call		I2CREAD2					; Year
	movff		SSPBUF,convert_value_temp+2
	call		PLED_convert_date_short		; converts into "DD/MM" or "MM/DD" or "MM/DD" in postinc2


	call		I2CREAD2					; hours (Skip)
	call		I2CREAD2					; minutes (skip)
	movlw		' '
	movwf		POSTINC2
	call		I2CREAD2					; Depth
	movff		SSPBUF,lo
	call		I2CREAD2	
	movff		SSPBUF,hi
	bsf			leftbind
	bsf			ignore_digit5				; Do not display 1cm figure
	output_16dp	d'3'						; max. depth
	movlw		'm'
	movwf		POSTINC2
	movlw		' '
	movwf		POSTINC2
	call		I2CREAD2	
	movff		SSPBUF,lo
	call		I2CREAD2	
	movff		SSPBUF,hi
	bsf			leftbind
	output_16								; Divetime minutes
	movlw		d'39'						; "'"
	movwf		POSTINC2
	
	call		word_processor				; Display header-row in list
	return


;profileview_menu:
;	movlw		d'1'
;	movwf		menupos
;profileview_menu1:	
;	call		PLED_clear_divemode_menu
;	call		PLED_profileview_menu		; Displays Menu
;profileview_menu2:
;	call		PLED_divemenu_cursor
;	bcf			sleepmode					; clear some flags
;	bcf			menubit2
;	bcf			menubit3
;	bcf			switch_right
;	bcf			switch_left
;	clrf		timeout_counter2
;
;profileview_menu_loop:
;	call		check_switches_logbook
;	
;	btfsc		menubit3					; SET/MENU?
;	bra			profileview_menu_move_cursor; Move Cursor
;	btfsc		menubit2					; ENTER?
;	bra			profileview_menu_do			; Do task
;
;	btfsc		onesecupdate
;	call		timeout_surfmode			; timeout
;	btfsc		onesecupdate
;	call		set_dive_modes				; check, if divemode must be entered
;	bcf			onesecupdate				; one second update
;	btfsc		sleepmode					; Timeout?
;	bra			exit_profileview			; back to list
;	btfsc		divemode
;	goto		restart						; Enter Divemode if required
;
;	bra			profileview_menu_loop		; wait for something to do
;	
;profileview_menu_do:
;	dcfsnz		menupos,F
;	bra			exit_profileview		; back to list, quit profileview menu
;	dcfsnz		menupos,F
;	bra			profileview_menu_delete	; Delete Dive from external EEPROM
;;	dcfsnz		menupos,F
;;	bra			profileview_menu_format	; Delete all Dives from external EEPROM
;;
;profileview_menu_move_cursor:
;	incf		menupos,F
;	movlw		d'3'						; number of menu options+1
;	cpfseq		menupos						; =limit?
;	bra			profileview_menu_move_cursor2	; No!
;	movlw		d'1'							; Yes, reset to position 1!
;	movwf		menupos
;profileview_menu_move_cursor2:
;	bra			profileview_menu2		; Return to Profile Menu, also updates cursor

;profileview_menu_format:
;	call		PLED_confirmbox				; Returns WREG=0 for Cancel (Or Timeout) and WREG=1 for OK!
;
;	movwf		menupos						; Used as temp
;	tstfsz		menupos
;	bra			profileview_menu_format_loop2		; Format now!
;
;	bra			exit_profileview		; back to list, quit profileview menu
;
;profileview_menu_format_loop2:			; Do now format!
;	call		PLED_ClearScreen
;	DISPLAYTEXT	.12						; "Wait.."
;	call		reset_external_eeprom		; delete profile memory
;	goto		menu						; Return to Menu

;profileview_menu_delete:
;	call		PLED_confirmbox				; Returns WREG=0 for Cancel (Or Timeout) and WREG=1 for OK!
;	movwf		menupos						; Used as temp
;	tstfsz		menupos
;	bra			profileview_menu_delete_loop2		; Delete now!
;
;	bra			exit_profileview		; back to list, quit profileview menu
;
;profileview_menu_delete_loop2:	; Do now delete
;	call		PLED_ClearScreen
;	DISPLAYTEXT	.12				; "Wait.."
;
;; eeprom_address:2 is set to the second byte after the ending 0xFD 0xFD
;; eeprom_address:2 - 1 -> set to the last byte after the 0xFD 0xFD of the current dive
;
;; Set pointer to Byte after the final "0xFD 0xFD"
;	decf_eeprom_address	d'1'			; Macro, that subtracts 8Bit from eeprom_address:2 with banking at 0x8000
;	movff		eeprom_address+0,divemins+0
;	movff		eeprom_address+1,divemins+1			
;
;; eeprom_header_address:2 + 1 -> set to the first 0xFA of the 0xFA 0xFA start bytes of the header
;	movlw		d'1'								; 
;	addwf		eeprom_header_address+0,F
;	movlw		d'0'
;	addwfc		eeprom_header_address+1,F			; eeprom_header_address:2 + 1
;	btfsc		eeprom_header_address+1,7			; at 7FFF?
;	clrf		eeprom_header_address+0				; Yes, clear address (+0 first!)
;	btfsc		eeprom_header_address+1,7			; at 7FFF?
;	clrf		eeprom_header_address+1				; Yes, clear address
;
;	movff		divemins+0,eeprom_address+0
;	movff		divemins+1,eeprom_address+1					; Read source
;	call		I2CREAD										; reads one byte (Slow! Better use Blockread!)	
;	movwf		profile_temp+0
;	movlw		0xFE
;	cpfseq		profile_temp+0
;	bra			profileview_menu_delete_notlast				; we're not deleting the last dive....
;
;; Just move the 0xFE after the dive and delete the rest with 0xFF			
;	movff		eeprom_header_address+0, eeprom_address+0
;	movff		eeprom_header_address+1, eeprom_address+1	; Write target
;	movlw		0xFE
;	call		I2CWRITE									; Write the byte
;
;; Now, delete everything _between_ eeprom_header_address and divemins:2+2 with 0xFF
;	movlw		d'1'								; 
;	addwf		eeprom_header_address+0,F
;	movlw		d'0'
;	addwfc		eeprom_header_address+1,F			; eeprom_header_address:2 + 1
;	btfsc		eeprom_header_address+1,7			; at 7FFF?
;	clrf		eeprom_header_address+0				; Yes, clear address (+0 first!)
;	btfsc		eeprom_header_address+1,7			; at 7FFF?
;	clrf		eeprom_header_address+1				; Yes, clear address
;
;	movff		eeprom_header_address+0,eeprom_address+0
;	movff		eeprom_header_address+1,eeprom_address+1
;
;	movlw		d'1'								; 
;	addwf		divemins+0,F
;	movlw		d'0'
;	addwfc		divemins+1,F						; divemins:2 + 1
;	btfss		divemins+1,7						; at 7FFF?
;	bra			profileview_menu_delete_loop2a		; Skip
;	clrf		divemins+0							; Yes, clear address
;	clrf		divemins+1
;
;;	movff		eeprom_header_address+0,eeprom_address+0
;;	movff		eeprom_header_address+1,eeprom_address+1
;
;
;profileview_menu_delete_loop2a:	
;	movlw		0xFF
;	call		I2CWRITE							; Write the byte
;
;	incf_eeprom_address	d'1'				; Macro, that adds 8Bit to eeprom_address:2 with banking at 0x8000
;
;	movff		divemins+0,sub_a+0
;	movff		divemins+1,sub_a+1
;	movff		eeprom_address+0,sub_b+0
;	movff		eeprom_address+1,sub_b+1
;	call		sub16								; sub_c = sub_a - sub_b
;	tstfsz		sub_c+0								; Done (Result=Zero?) ?
;	bra			profileview_menu_delete_loop2a		; No, continue
;	tstfsz		sub_c+1								; Done (Result=Zero?) ?
;	bra			profileview_menu_delete_loop2a		; No, continue
;	goto		menu_logbook						; Return to list when done deleting
;
;profileview_menu_delete_notlast:
;; Move everything byte-wise from divemins:2 to eeprom_header_address:2 until 0xFD 0xFD 0xFE is found and were moved
;	call		get_free_EEPROM_location			; Searches 0xFD, 0xFD, 0xFE and sets Pointer to 0xFE
;
;	incf_eeprom_address	d'2'				; Macro, that adds 8Bit to eeprom_address:2 with banking at 0x8000
;	movff		eeprom_address+0,profile_temp+0		
;	movff		eeprom_address+1,profile_temp+1	
;; holds now address of 0xFE + 2 (Abort condition....)
;	decf_eeprom_address	d'2'			; Macro, that subtracts 8Bit from eeprom_address:2 with banking at 0x8000
;; holds now address of 0xFE again
;	movff		eeprom_address+0,divemins+0
;	movff		eeprom_address+1,divemins+1					; Copy to working read registers
;
;profileview_menu_delete_loop3:
;	movff		divemins+0,eeprom_address+0
;	movff		divemins+1,eeprom_address+1					; Read source
;	call		I2CREAD										; reads one byte (Slow! Better use Blockread!)	
;	movff		eeprom_header_address+0, eeprom_address+0
;	movff		eeprom_header_address+1, eeprom_address+1	; Write target
;	call		I2CWRITE									; Write the byte
;
;	movff		divemins+0,eeprom_address+0
;	movff		divemins+1,eeprom_address+1					; Set to source again
;	movlw		0xFF
;	call		I2CWRITE									; Delete the source....
;
;	movlw		d'1'
;	addwf		divemins+0,F							; Increase source (Divemins:2)
;	movlw		d'0'
;	addwfc		divemins+1,F
;	btfsc		divemins+1,7						; at 0x8000?
;	clrf		divemins+0							; Yes, clear address (+0 first!)
;	btfsc		divemins+1,7						; at 0x8000?
;	clrf		divemins+1							; Yes, clear address
;
;	movlw		d'1'								; Increase target (eeprom_header_address:2)
;	addwf		eeprom_header_address+0,F
;	movlw		d'0'
;	addwfc		eeprom_header_address+1,F			; eeprom_header_address:2 + 1
;	btfsc		eeprom_header_address+1,7			; at 7FFF?
;	clrf		eeprom_header_address+0				; Yes, clear address (+0 first!)
;	btfsc		eeprom_header_address+1,7			; at 7FFF?
;	clrf		eeprom_header_address+1				; Yes, clear address
;
;	movff		divemins+0,sub_a+0
;	movff		divemins+1,sub_a+1
;	movff		profile_temp+0,sub_b+0
;	movff		profile_temp+1,sub_b+1
;	call		sub16								; sub_c = sub_a - sub_b
;	tstfsz		sub_c+0								; Done (Result=Zero?) ?
;	bra			profileview_menu_delete_loop3		; No, continue
;	tstfsz		sub_c+1								; Done (Result=Zero?) ?
;	bra			profileview_menu_delete_loop3		; No, continue
;
;	goto		menu_logbook								; Return to list when done deleting


	