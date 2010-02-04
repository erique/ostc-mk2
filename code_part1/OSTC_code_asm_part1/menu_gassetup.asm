
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


; Gas Setup menu
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 10/08/07
; last updated: 080906
; known bugs:
; ToDo: 

menu_gassetup:				
	movlw	d'1'
	movwf	menupos

menu_gassetup_prelist:
	call	PLED_ClearScreen
	clrf	timeout_counter2
	bcf		sleepmode
	bcf		menubit2
	bcf		menubit3
	call	PLED_topline_box
	WIN_INVERT	.1	; Init new Wordprocessor
	DISPLAYTEXT	.106			; Gas List
	WIN_INVERT	.0	; Init new Wordprocessor
	clrf	decodata+0				; Here: # of gas 0-4
	clrf	divemins+0				; Here: # of Gas * 4
	movlw	d'5'
	movwf	waitms_temp		; here: stores row for gas list
	movlw	d'2'
	movwf	wait_temp			; here: stores eeprom address for gas list

; Changed v1.44se
menu_gassetup_list:
	WIN_LEFT	.20
	movlw	d'4'
	addwf	wait_temp,F			; Increase eeprom address for gas list
	movlw	d'30'
	addwf	waitms_temp,F		; Increase row
	movf	waitms_temp,W		; Load row into WREG
	movff	WREG,win_top
	lfsr	FSR2,letter
	movlw	'G'
	movwf	POSTINC2
	movff	decodata+0,lo		
	incf	lo,F				
	bsf		leftbind
	output_99
	movlw	':'
	movwf	POSTINC2
	
	call	menu_gassetup_grey_inactive			; Sets Greyvalue for inactive gases
	call	word_processor
	WIN_LEFT	.40
	movf	waitms_temp,W		; Load row into WREG
	movff	WREG,win_top
	lfsr	FSR2,letter

	movlw	d'33'
	movwf	EEADR
	call	read_eeprom			; Get current startgas 1-5 # into EEDATA
	decf	EEDATA,W			; 0-4
	cpfseq	decodata+0			; =current displayed gas #?
	bra		menu_gassetup_Tx	; no, do not display *
	movlw	'*'					; display *
	movwf	POSTINC2	

; New v1.44se
menu_gassetup_Tx:
	call	menu_gassetup_grey_inactive			; Sets Greyvalue for inactive gases	
	call	word_processor

	WIN_LEFT	.48
	movf	waitms_temp,W		; Load row into WREG
	movff	WREG,win_top
	lfsr	FSR2,letter

	movff	wait_temp, EEADR	; Gas %He - Set address in internal EEPROM
	incf	EEADR,F				; Gas %He - Set address in internal EEPROM
	call	read_eeprom			; Read He value from EEPROM
	movff	EEDATA,lo			; Move EEDATA -> lo
	movf	lo,f				; Move lo -> f
	movlw	d'0'				; Move 0 -> WREG
	cpfsgt	lo					; He > 0?
	bra 	menu_gassetup_Nx	; NO check o2

	; YES Write TX 15/55
	call 	gassetup_write_Tx
	movff	wait_temp, EEADR	; Gas %O2 - Set address in internal EEPROM
	call	read_eeprom			; O2 value
	movff	EEDATA,lo
	output_8
	movlw	'/'
	movwf	POSTINC2
	incf	EEADR,F				; Gas #hi: %He - Set address in internal EEPROM
	call	read_eeprom			; He value
	movff	EEDATA,lo
	output_8
	bra 	menu_gassetup_list0

; New v1.44se
menu_gassetup_Nx:
	movff	wait_temp, EEADR	; Gas %O2 - Set address in internal EEPROM
	call	read_eeprom			; Read O2 value from EEPROM
	movff	EEDATA,lo			; Move EEDATA -> lo
	movf	lo,f				; Move lo -> f
	movlw	d'21'				; Move 21 -> WREG
	cpfsgt	lo					; o2 > 21%
	bra 	menu_gassetup_Air	; NO AIR
	movlw	d'100'				; Move 100 -> WREG
	cpfslt	lo					; o2 < 100%
	bra		menu_gassetup_O2	; NO write O2
	
	; YES Write NX 32
	call	gassetup_write_Nx
	output_8
	bra 	menu_gassetup_list0

; New v1.44se
menu_gassetup_O2:
	movlw	'O'
	movwf	POSTINC2
	movlw	'2'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	output_8
	bra 	menu_gassetup_list0

; New v1.44se
menu_gassetup_Air:
	cpfseq	lo					; o2 = 21%
	call menu_gassetup_Err

	movlw	'A'
	movwf	POSTINC2
	movlw	'I'
	movwf	POSTINC2
	movlw	'R'
	movwf	POSTINC2
	movlw	' '		
	movwf	POSTINC2
	output_8
	bra 	menu_gassetup_list0

; New v1.44se
menu_gassetup_Err:
	movlw	'E'
	movwf	POSTINC2
	movlw	'R'
	movwf	POSTINC2
	movlw	'R'
	movwf	POSTINC2
	movlw	' '		
	movwf	POSTINC2
	output_8

; Changed v1.44se
menu_gassetup_list0:
	call	menu_gassetup_grey_inactive			; Sets Greyvalue for inactive gases
	call	word_processor

	WIN_LEFT	.105
	movf	waitms_temp,W		; Load row into WREG
	movff	WREG,win_top
	lfsr	FSR2,letter

	movlw	' '
	movwf	POSTINC2
	movlw	'i'
	movwf	POSTINC2
	movlw	'n'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	movf	decodata+0,W		; read current value 
	addlw	d'28'				; offset in memory
	movwf	EEADR
	call	read_eeprom			; Low-value
	movff	EEDATA,lo
	output_8
	movlw	'm'
	movwf	POSTINC2
	call	menu_gassetup_grey_inactive			; Sets Greyvalue for inactive gases
	call	word_processor	

	call	PLED_standard_color
	
	incf	decodata+0,F
	movlw	d'5'	
	cpfseq	decodata+0
	goto	menu_gassetup_list

	DISPLAYTEXT	.11			; Exit
	call	wait_switches		; Waits until switches are released, resets flag if button stays pressed!
	call	PLED_menu_cursor

gassetup_list_loop:
	call	check_switches_logbook

	btfsc	menubit3
	bra		gassetup_list2		; move cursor

	btfsc	menubit2
	bra		do_gassetup_list; call gas-specific submenu

	btfsc	divemode
	goto	restart			; dive started!

	btfsc	onesecupdate
	call	timeout_surfmode

	btfsc	onesecupdate
	call	set_dive_modes

	bcf		onesecupdate	; 1 sec. functions done

	btfsc	sleepmode
	bra		exit_gassetup_list

	bra		gassetup_list_loop

gassetup_list2:
	incf	menupos,F
	movlw	d'7'
	cpfseq	menupos			; =7?
	bra		gassetup_list3	; No
	movlw	d'1'
	movwf	menupos

gassetup_list3:
	clrf	timeout_counter2
	call	PLED_menu_cursor

	call	wait_switches		; Waits until switches are released, resets flag if button stays pressed!

	bcf		menubit3		; clear flag
	bra		gassetup_list_loop

exit_gassetup_list:			; exit...
	movlw	d'2'
	movwf	menupos
	goto	menu2

do_gassetup_list:
	dcfsnz	menupos,F
	bra		gassetup_list_edit_gas1
	dcfsnz	menupos,F
	bra		gassetup_list_edit_gas2
	dcfsnz	menupos,F
	bra		gassetup_list_edit_gas3
	dcfsnz	menupos,F
	bra		gassetup_list_edit_gas4
	dcfsnz	menupos,F
	bra		gassetup_list_edit_gas5
	bra		exit_gassetup_list			; Exit List

gassetup_list_edit_gas1:
	movlw	d'0'
	movwf	decodata+0
	movlw	d'0'
	movwf	divemins+0
	bra		menu_gassetup_page1

gassetup_list_edit_gas2:
	movlw	d'1'
	movwf	decodata+0
	movlw	d'4'
	movwf	divemins+0
	bra		menu_gassetup_page1

gassetup_list_edit_gas3:
	movlw	d'2'
	movwf	decodata+0
	movlw	d'8'
	movwf	divemins+0
	bra		menu_gassetup_page1

gassetup_list_edit_gas4:
	movlw	d'3'
	movwf	decodata+0
	movlw	d'12'
	movwf	divemins+0
	bra		menu_gassetup_page1

gassetup_list_edit_gas5:
	movlw	d'4'
	movwf	decodata+0
	movlw	d'16'
	movwf	divemins+0
	bra		menu_gassetup_page1

menu_gassetup_page1:
	movlw	d'1'
	movwf	menupos
	bcf		gas_setup_page2			; Page 1 of gassetup
	bcf		menubit4
	bcf		cursor
	bcf		sleepmode
	bcf		first_FA				; Here: =1: -, =0: +

menu_gassetup0:
	call	PLED_ClearScreen
	DISPLAYTEXT	.30			; More...
	DISPLAYTEXT	.11			; Exit

menu_gassetup1:
	clrf	timeout_counter2
	bcf		menubit2
	bcf		menubit3

	rcall	gassetup_title_bar2			; Displays the title bar with the current Gas info

	WIN_TOP		.65
	WIN_LEFT	.20
	lfsr	FSR2,letter
	movlw	'O'
	movwf	POSTINC2
	movlw	'2'
	movwf	POSTINC2
	movlw	':'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2

	movf	divemins+0,W
	addlw	0x06
	movwf	EEADR
	call	read_eeprom		; O2 value
	movff	EEDATA,lo
	output_8
	movlw	'%'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	movlw	'('
	movwf	POSTINC2
	movlw	'M'
	movwf	POSTINC2
	movlw	'O'
	movwf	POSTINC2
	movlw	'D'
	movwf	POSTINC2
	movlw	':'
	movwf	POSTINC2

; Show MOD in m
	GETCUSTOM8 .18				; ppO2 warnvalue in WREG
	mullw	d'10'
	movff	PRODL,xA+0
	movff	PRODH,xA+1			; ppO2 in [0.01Bar] * 10

	movf	divemins+0,W
	addlw	0x06
	movwf	EEADR
	call	read_eeprom			; O2 value
	movff	EEDATA,xB+0
	clrf	xB+1
	call	div16x16			;xA/xB=xC with xA as remainder
	movlw	d'10'
	subwf	xC+0,F				; Subtract 10m...
	movff	xC+0,lo
	movlw	d'0'
	subwfb	xC+1,F
	movff	xC+1,hi
	output_16
	movlw	'm'
	movwf	POSTINC2
	movlw	')'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	call	word_processor	

	WIN_TOP		.95
	lfsr	FSR2,letter
	movlw	'H'
	movwf	POSTINC2
	movlw	'e'
	movwf	POSTINC2
	movlw	':'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	movf	divemins+0,W
	addlw	0x07
	movwf	EEADR
	call	read_eeprom		; He value
	movff	EEDATA,lo
	output_8
	movlw	'%'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	call	word_processor		

	WIN_TOP		.125
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

	WIN_TOP		.155
	lfsr	FSR2,letter
	OUTPUTTEXT	.89			; Default: 
	movf	divemins+0,W
	addlw	0x04
	movwf	EEADR
	call	read_eeprom		; Default O2 value
	movff	EEDATA,lo
	output_8
	movlw	'/'
	movwf	POSTINC2
	movf	divemins+0,W
	addlw	0x05
	movwf	EEADR
	call	read_eeprom		; Default He value
	movff	EEDATA,lo
	output_8
	movlw	' '
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	call	word_processor		

	call	wait_switches		; Waits until switches are released, resets flag if button stays pressed!
	call	PLED_menu_cursor

gassetup_loop:
	call	check_switches_logbook

	btfsc	menubit3
	bra		gassetup2	; move cursor

	btfsc	menubit2
	bra		do_gassetup		; call submenu

	btfsc	divemode
	goto	restart			; dive started!

	btfsc	onesecupdate
	call	timeout_surfmode

	btfsc	onesecupdate
	call	set_dive_modes

	bcf		onesecupdate	; 1 sec. functions done

	btfsc	sleepmode
	bra		exit_gassetup

	bra	gassetup_loop

gassetup2:
	incf	menupos,F
	movlw	d'7'
	cpfseq	menupos			; =7?
	bra		gassetup3	; No
	movlw	d'1'
	movwf	menupos

gassetup3:

	clrf	timeout_counter2
	call	PLED_menu_cursor

	call	wait_switches		; Waits until switches are released, resets flag if button stays pressed!

	bcf		menubit3		; clear flag
	bra		gassetup_loop

do_gassetup:
	dcfsnz	menupos,F
	bra		next_gas_page
	dcfsnz	menupos,F
	bra		adjust_o2
	dcfsnz	menupos,F
	bra		adjust_he
	dcfsnz	menupos,F
	bra		toggle_plus_minus_gassetup
	dcfsnz	menupos,F
	bra		restore_gas
exit_gassetup:			; exit...
	movff	decodata+0,menupos
	incf	menupos,F
	bra		menu_gassetup_prelist

toggle_plus_minus_gassetup:
	btg		first_FA
	movlw	d'4'
	movwf	menupos
	bra		menu_gassetup1	; return

next_gas:
	movlw	d'1'
	movwf	menupos
	bra		menu_gassetup0		; incl. clear screen

adjust_o2:
	movf	divemins+0,W			; read current value 
	addlw	0x06
	movwf	EEADR
	call	read_eeprom		; Low-value
	movff	EEDATA,lo

	btfsc	first_FA				; Minus?
	bra		adjust_o2_1			; yes, minus!
	
	incf	lo,F			; increase O2
	movlw	d'101'
	cpfseq	lo
	bra		adjust_o2_2
	movlw	d'4'			; LOWER O2 Limit
	movwf	lo
	bra		adjust_o2_2

adjust_o2_1:
	decf	lo,F			; decrease O2
	movlw	d'3'
	cpfseq	lo
	bra		adjust_o2_2

	movf	divemins+0,W
	addlw	0x07
	movwf	EEADR
	call	read_eeprom		; read He value

	movlw	d'100'
	movwf	lo
	movf	EEDATA,W		; He value
	subwf	lo,F			; lo=100% - He%

adjust_o2_2:				; test if O2+He>100...
	movf	divemins+0,W
	addlw	0x07
	movwf	EEADR
	call	read_eeprom		; read He value
	movf	EEDATA,W		; He value
	addwf	lo,W			; add O2 value
	movwf	hi				; store in temp
	movlw	d'101'
	cpfseq	hi				; O2 and He > 100?
	bra		adjust_o2_3		; No!

	movlw	d'4'			; LOWER O2 Limit
	movwf	lo
	
adjust_o2_3:
	movf	divemins+0,W			; save current value
	addlw	0x06
	movwf	EEADR
	movff	lo,EEDATA
	call	write_eeprom		; Low-value

	movlw	d'2'
	movwf	menupos
	bra		menu_gassetup1	

adjust_he:
	movf	divemins+0,W			; read current value
	addlw	0x07
	movwf	EEADR
	call	read_eeprom		; Low-value
	movff	EEDATA,lo

	btfsc	first_FA			; Minus?
	bra		adjust_he_1			; yes, minus!
	
	incf	lo,F
	movlw	d'92'			; He limited to (useless) 90%
	cpfseq	lo
	bra		adjust_he_2
	clrf	lo
	bra		adjust_he_2

adjust_he_1:
	decf	lo,F			; decrease He
	movlw	d'255'
	cpfseq	lo
	bra		adjust_he_2
	clrf	lo

adjust_he_2:				; test if O2+He>100...
	movf	divemins+0,W
	addlw	0x06
	movwf	EEADR
	call	read_eeprom		; read He value
	movf	EEDATA,W		; He value
	addwf	lo,W			; add O2 value
	movwf	hi				; store in temp
	movlw	d'101'
	cpfseq	hi				; O2 and He > 100?
	bra		adjust_he_3		; No!
;	clrf	lo				; Yes, clear He to zero
	decf	lo,F			; reduce He again = unchanged after operation

adjust_he_3:
	movf	divemins+0,W			; save current value
	addlw	0x07
	movwf	EEADR
	movff	lo,EEDATA
	call	write_eeprom		; Low-value

	movlw	d'3'
	movwf	menupos
	bra		menu_gassetup1	; 

restore_gas:
	movf	divemins+0,W			; read Default value 
	addlw	0x04
	movwf	EEADR
	call	read_eeprom		; Low-value
	movff	EEDATA,lo
	movf	divemins+0,W
	addlw	0x05
	movwf	EEADR
	call	read_eeprom		; High-value
	movff	EEDATA,hi

	movf	divemins+0,W			; save Default value
	addlw	0x06
	movwf	EEADR
	movff	lo,EEDATA
	call	write_eeprom		; Low-value
	movf	divemins+0,W
	addlw	0x07
	movwf	EEADR
	movff	hi,EEDATA
	call	write_eeprom		; High-value

	movlw	d'5'
	movwf	menupos
	bra		menu_gassetup1	; 


next_gas_page:
	call	PLED_ClearScreen		
	movlw	d'1'
	movwf	menupos
	DISPLAYTEXT	.109		; Back

	DISPLAYTEXT	.11			; Exit

next_gas_page1:
	clrf	timeout_counter2
	bcf		menubit2
	bcf		menubit3

	rcall	gassetup_title_bar2			; Displays the title bar with the current Gas info
	rcall	gassetup_show_ppO2			; Display the ppO2 of the change depth with the current gas

	WIN_TOP		.65
	WIN_LEFT	.20
	lfsr	FSR2,letter
	OUTPUTTEXT	.105			; "Active Gas? "
	read_int_eeprom		d'27'	; read flag register

	; hi contains active gas flags in BIT0:4 ....

	movff	decodata+0,lo	; Gas 0-4
	incf	lo,F			; Gas 1-5

active_gas_display:
	rrcf	EEDATA			; roll flags into carry
	decfsz	lo,F			; max. 5 times...
	bra		active_gas_display
	
	btfss	STATUS,C		; test carry
	bra		active_gas_display_no
	
	OUTPUTTEXT	.96			; Yes 
	bra		active_gas_display_end
	
active_gas_display_no:
	movlw	' '					; three spaces instead of "Yes"
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2

active_gas_display_end:	
	call	word_processor	

	WIN_TOP		.95
	WIN_LEFT	.20
	lfsr	FSR2,letter
	OUTPUTTEXT	.88			; First Gas?
	movlw	' '
	movwf	POSTINC2

	movlw	d'33'
	movwf	EEADR
	call	read_eeprom		; Get current startgas 1-5 # into EEDATA
	decf	EEDATA,W		; 0-4
	cpfseq	decodata+0		; =current displayed gas #?
	bra		menu_firstgas0	; no, display three spaces

	OUTPUTTEXT	.96			; Yes 
	bra		menu_firstgas1

menu_firstgas0:
	movlw	' '
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2

menu_firstgas1:
	call	word_processor			

	WIN_TOP		.125
	WIN_LEFT	.20
	lfsr	FSR2,letter
	OUTPUTTEXT	.107		; Change+
	call	word_processor		

	WIN_TOP		.155
	WIN_LEFT	.20
	lfsr	FSR2,letter
	OUTPUTTEXT	.108		; Change-
	call	word_processor		

	call	wait_switches		; Waits until switches are released, resets flag if button stays pressed!
	call	PLED_menu_cursor

next_gas_page_loop:
	call	check_switches_logbook

	btfsc	menubit3
	bra		next_gas_page2	; move cursor

	btfsc	menubit2
	bra		do_next_gas_page		; call submenu

	btfsc	divemode
	goto	restart			; dive started!

	btfsc	onesecupdate
	call	timeout_surfmode

	btfsc	onesecupdate
	call	set_dive_modes

	bcf		onesecupdate	; 1 sec. functions done

	btfsc	sleepmode
	bra		exit_gassetup

	bra		next_gas_page_loop

next_gas_page2:
	incf	menupos,F

	movlw	d'7'
	cpfseq	menupos			; =7?
	bra		next_gas_page3	; No
	movlw	d'1'
	movwf	menupos

next_gas_page3:
	clrf	timeout_counter2
	call	PLED_menu_cursor
	
	call	wait_switches		; Waits until switches are released, resets flag if button stays pressed!

	bcf		menubit3		; clear flag
	bra		next_gas_page_loop

do_next_gas_page:
	dcfsnz	menupos,F
	bra		next_gas
	dcfsnz	menupos,F
	bra		toggle_active_gas
	dcfsnz	menupos,F
	bra		make_first_gas
	dcfsnz	menupos,F
	bra		change_gas_depth_plus
	dcfsnz	menupos,F
	bra		change_gas_depth_minus
	bra		exit_gassetup			; Exit menu

make_first_gas:
	movff	decodata+0,EEDATA		; current gas (0-4) into EEDATA
	incf	EEDATA,F				; current gas (1-5) into EEDATA
	movlw	d'33'
	movwf	EEADR
	call	write_eeprom			; store in internal EEPROM
	movlw	d'3'
	movwf	menupos
	bra		next_gas_page1

toggle_active_gas:
	read_int_eeprom		d'27'		; read flag register
	movff	decodata+0,lo			; selected gas 0-4
	incf	lo,F
	dcfsnz	lo,F
	btg		EEDATA,0
	dcfsnz	lo,F
	btg		EEDATA,1
	dcfsnz	lo,F
	btg		EEDATA,2
	dcfsnz	lo,F
	btg		EEDATA,3
	dcfsnz	lo,F
	btg		EEDATA,4
	write_int_eeprom	d'27'		; write flag register
	movlw	d'2'
	movwf	menupos
	bra		next_gas_page1
	
change_gas_depth_plus:
	movf	decodata+0,W		; read current value 
	addlw	d'28'				; offset in memory
	movwf	EEADR
	call	read_eeprom			; Low-value
	movff	EEDATA,lo
	
	incf	lo,F				; increase depth
	movlw	d'100'				; Change depth limit + 1
	cpfseq	lo
	bra		change_gas_depth_plus2
	movlw	d'99'				; Change depth limit
	movwf	lo
change_gas_depth_plus2:
	movff	lo,EEDATA			; write result
	call	write_eeprom		; save result in EEPROM

	movlw	d'4'
	movwf	menupos
	bra		next_gas_page1


change_gas_depth_minus:
	movf	decodata+0,W		; read current value 
	addlw	d'28'				; offset in memory
	movwf	EEADR
	call	read_eeprom			; Low-value
	movff	EEDATA,lo
	
	decf	lo,F				; decrease depth
	movlw	d'255'
	cpfseq	lo
	bra		change_gas_depth_minus2
	movlw	d'0'
	movwf	lo

change_gas_depth_minus2:
	movff	lo,EEDATA			; write result
	call	write_eeprom		; save result in EEPROM

	movlw	d'5'
	movwf	menupos
	bra		next_gas_page1

; Changed v1.44se
gassetup_title_bar2:
	call	PLED_topline_box
	WIN_INVERT	.1	; Init new Wordprocessor	
	WIN_TOP		.2
	WIN_LEFT	.0
	lfsr	FSR2,letter
	OUTPUTTEXT	.95				; Gas# 
	movff	decodata+0,lo		
	incf	lo,F				
	bsf		leftbind
	output_99
	movlw	':'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	call	word_processor
	
	WIN_TOP		.2
	WIN_LEFT	.50
	lfsr	FSR2,letter

	;He check
	movf	divemins+0,W
	addlw	0x07
	movwf	EEADR
	call	read_eeprom			; He value
	movff	EEDATA,lo			; Move EEData -> lo
	movf	lo,f				; Move lo -> f
	movlw	d'0'				; Move 0 -> WREG
	cpfsgt	lo					; He > 0?
	bra 	gassetup_title_bar3	; NO check o2
	
	; YES Write TX 15/55
	call 	gassetup_write_Tx	; Write TX
	movf	divemins+0,W
	addlw	0x06
	movwf	EEADR
	call	read_eeprom			; O2 value
	movff	EEDATA,lo
	output_8					; Write O2
	movlw	'/'
	movwf	POSTINC2
	movf	divemins+0,W
	addlw	0x07
	movwf	EEADR
	call	read_eeprom			; He value
	movff	EEDATA,lo
	output_8					; Write He
	bra		gassetup_title_bar7

; New v1.44se
gassetup_title_bar3:			; O2 Check		
	movf	divemins+0,W
	addlw	0x06
	movwf	EEADR
	call	read_eeprom			; O2 value
	movff	EEDATA,lo	
	movf	lo,f				; Move lo -> f
	movlw	d'21'				; Move 21 -> WREG
	cpfseq	lo					; o2 = 21
	cpfsgt	lo					; o2 > 21%
	bra 	gassetup_title_bar5	; NO AIR
	movlw	d'100'				; Move 100 -> WREG
	cpfslt	lo					; o2 < 100%
	bra		gassetup_title_bar4	; NO write O2

	; YES Write NX 32
	call	gassetup_write_Nx 	
	output_8
	bra 	gassetup_title_bar7

; New v1.44se
gassetup_title_bar4:
	movlw	'O'
	movwf	POSTINC2
	movlw	'2'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	output_8
	bra 	gassetup_title_bar7

; New v1.44se
gassetup_title_bar5:
	cpfseq	lo					; o2 = 21%
	bra 	gassetup_title_bar6

	movlw	'A'
	movwf	POSTINC2
	movlw	'I'
	movwf	POSTINC2
	movlw	'R'
	movwf	POSTINC2
	movlw	' '		
	movwf	POSTINC2
	output_8
	bra 	gassetup_title_bar7

; New v1.44se
gassetup_title_bar6:		; ERROR
	movlw	'E'
	movwf	POSTINC2
	movlw	'R'
	movwf	POSTINC2
	movlw	'R'
	movwf	POSTINC2
	movlw	' '		
	movwf	POSTINC2
	output_8
	bra 	gassetup_title_bar7

gassetup_title_bar7:
	movlw	' '
	movwf	POSTINC2
	movlw	'i'
	movwf	POSTINC2
	movlw	'n'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	movf	decodata+0,W		; read current value 
	addlw	d'28'				; offset in memory
	movwf	EEADR
	call	read_eeprom			; Low-value
	movff	EEDATA,lo
	output_8
	movlw	'm'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2

	call	word_processor	
	WIN_INVERT	.0	; Init new Wordprocessor	
	return

; New v1.44se
gassetup_write_Nx:
	movlw	'N'
	movwf	POSTINC2
	movlw	'X'
	movwf	POSTINC2
	movlw	' '					
	movwf	POSTINC2	
	return

; New v1.44se
gassetup_write_Tx:
	movlw	'T'
	movwf	POSTINC2
	movlw	'X'
	movwf	POSTINC2
	movlw	' '					
	movwf	POSTINC2
	return

; New v1.44se
menu_gassetup_grey_inactive:
; Set Greyvalue to lower value when gas is inactive
	read_int_eeprom		d'27'	; read flag register
	movff	decodata+0,lo		; copy gas number 0-4
	incf	lo,F				; 1-5
menu_gassetup_list1:
	rrcf	EEDATA			; roll flags into carry
	decfsz	lo,F			; max. 5 times...
	bra		menu_gassetup_list1
	
	btfss	STATUS,C		; test carry
	bra		menu_gassetup_list1_grey

	GETCUSTOM8	d'35'		;movlw	color_white	
	call	PLED_set_color	; grey out inactive gases!
	return

menu_gassetup_list1_grey:
	movlw	color_grey
	call	PLED_set_color	; grey out inactive gases!
	return
	
gassetup_show_ppO2:
	movf	divemins+0,W
	addlw	0x06
	movwf	EEADR
	call	read_eeprom			; O2 value
	movff	EEDATA,hi

	movf	decodata+0,W		; read current value 
	addlw	d'28'				; offset in memory
	movwf	EEADR
	call	read_eeprom			; Change depth in m
	movff	EEDATA,lo
	movlw	d'10'
	addwf	lo,F				; Depth+10m=lo
	movf	hi,W
	mulwf	lo					; (Depth+10m)*O2
	movff	PRODL,xA+0
	movff	PRODH,xA+1
	movlw	d'10'
	movwf	xB+0
	clrf	xB+1
	call	div16x16			;xA/xB=xC with xA as remainder 	
	movff	xC+0,lo				; ((Depth+10m)*O2)/10 = [0.01Bar] ppO2
	movff	xC+1,hi

	WIN_LEFT	.55
	WIN_TOP		.35
	lfsr	FSR2,letter
	movlw	'('
	movwf	POSTINC2
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
	output_16dp	d'3'
	movlw	'B'
	movwf	POSTINC2
	movlw	'a'
	movwf	POSTINC2
	movlw	'r'
	movwf	POSTINC2
	movlw	')'
	movwf	POSTINC2
	movlw	' '
	movwf	POSTINC2
	call	word_processor
	return