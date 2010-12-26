
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
	call	gassetup_sort_gaslist			; Sorts Gaslist according to change depth
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
	
	movf    decodata+0,W
	call	PLED_grey_inactive_gas			; Sets Greyvalue for inactive gases
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
	movf    decodata+0,W
	call	PLED_grey_inactive_gas			; Sets Greyvalue for inactive gases	
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
	movf    decodata+0,W
	call	PLED_grey_inactive_gas			; Sets Greyvalue for inactive gases
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
	movf    decodata+0,W
	call	PLED_grey_inactive_gas			; Sets Greyvalue for inactive gases
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
	DISPLAYTEXT	.147		; More...
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
	movlw	'('
	movwf	POSTINC2
	movlw	'E'
	movwf	POSTINC2
	movlw	'N'
	movwf	POSTINC2
	movlw	'D'
	movwf	POSTINC2
	movlw	':'
	movwf	POSTINC2

; Show END in m
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
	movff	xC+1,hi				; lo:hi holding MOD in meters
	movlw	d'10'
	addwf	lo,F
	movlw	d'0'
	addwfc	hi,F				; lo:hi holding MOD+10m

	movf	divemins+0,W
	addlw	0x07
	movwf	EEADR
	call	read_eeprom		; He value in % -> EEDATA
	movlw	d'100'
	movwf	xA+0
	movf	EEDATA,W		; He value in % -> EEDATA
	subwf	xA+0,F			; xA+0 = 100 - He Value in %
	clrf	xA+1
	movff	lo,xB+0
	movff	hi,xB+1			; Copy MOD+10
	call	mult16x16		;xA*xB=xC
	movff	xC+0,xA+0
	movff	xC+1,xA+1
	movlw	d'100'
	movwf	xB+0
	clrf	xB+1
	call	div16x16		;xA/xB=xC with xA as remainder 	
	;	xC:2 = ((MOD+10) * 100 - HE Value in %) / 100
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

; Set First gas to "Active"
	read_int_eeprom		d'27'		; read flag register
	movff	decodata+0,lo			; selected gas 0-4
	incf	lo,F
	dcfsnz	lo,F
	bsf		EEDATA,0
	dcfsnz	lo,F
	bsf		EEDATA,1
	dcfsnz	lo,F
	bsf		EEDATA,2
	dcfsnz	lo,F
	bsf		EEDATA,3
	dcfsnz	lo,F
	bsf		EEDATA,4
	write_int_eeprom	d'27'		; write flag register

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
	OUTPUTTEXT 	d'149'		; (ppO2:
	output_16dp	d'3'
	OUTPUTTEXT 	d'150'		; Bar: 
	call	word_processor
	return


gassetup_sort_gaslist:			; Sorts Gaslist according to change depth
; EEPROM Locations of Gaslist
; Gas1: 
; O2 Default:4
; He Default:5
; O2 Current:6
; He Current:7
; Change: 28
; Active: 27,0

; Gas2: 
; O2 Default:8
; He Default:9
; O2 Current:10
; He Current:11
; Change: 29
; Active: 27,1

; Gas3: 
; O2 Default:12
; He Default:13
; O2 Current:14
; He Current:15
; Change: 30
; Active: 27,2

; Gas4: 
; O2 Default:16
; He Default:17
; O2 Current:18
; He Current:19
; Change: 31
; Active: 27,3

; Gas5: 
; O2 Default:20
; He Default:21
; O2 Current:22
; He Current:23
; Change: 32
; Active: 27,4

; reset Change depths (Important for all users who upgrade from <1.60!)
	clrf	EEADRH
	clrf	EEDATA
	write_int_eeprom		d'118'		; 
	write_int_eeprom		d'119'		; 
	write_int_eeprom		d'120'		; 
	write_int_eeprom		d'121'		; 
	write_int_eeprom		d'122'		; 
	movlw	d'21'				; O2 Current
	movwf	EEDATA	
	write_int_eeprom		d'96'		; 
	write_int_eeprom		d'100'		; 
	write_int_eeprom		d'104'		; 
	write_int_eeprom		d'108'		; 
	write_int_eeprom		d'112'		; 

	clrf	EEDATA				; He Current
	write_int_eeprom		d'97'		; 
	write_int_eeprom		d'101'		; 
	write_int_eeprom		d'105'		; 
	write_int_eeprom		d'109'		; 
	write_int_eeprom		d'113'		; 

; Find deepest Gas
; Copy all to RAM
	movlw	d'3'
	movwf	EEADR
	clrf	EEADRH
	lfsr	FSR2,letter			; Store gases in Letter buffer (max. 26Byte!)
gassetup_sort_gaslist1:
	incf	EEADR,F				; Next Adress
	call	read_eeprom			; Read byte
	movff	EEDATA,POSTINC2		; Copy into RAM
	movlw	d'23'				
	cpfseq	EEADR				; All done?
	bra		gassetup_sort_gaslist1	; No, not yet
; Letter+0	=	EEPROM 4
; ...
; Letter+20 =	EEPROM 23
	read_int_eeprom	d'28'
	movff	EEDATA,POSTINC2		; Change Depth Gas1 -> Letter+21
	read_int_eeprom	d'29'
	movff	EEDATA,POSTINC2		; Change Depth Gas2 -> Letter+22
	read_int_eeprom	d'30'
	movff	EEDATA,POSTINC2		; Change Depth Gas3 -> Letter+23
	read_int_eeprom	d'31'
	movff	EEDATA,POSTINC2		; Change Depth Gas4 -> Letter+24
	read_int_eeprom	d'32'
	movff	EEDATA,POSTINC2		; Change Depth Gas5 -> Letter+25
	read_int_eeprom	d'27'
	movff	EEDATA,POSTINC2		; Active Byte 		-> Letter+26

; All change depths = 0? -> Skip sort!
	lfsr	FSR2,letter+.20		; Change depths...
	movlw	d'5'
	movwf	logbook_temp3		; Gas (0-4)
	clrf	logbook_temp1		; counter
gassetup_sort_gaslist1a:	
	movf	POSTINC2,W
	addwf	logbook_temp1,F		; sum
	decfsz	logbook_temp3,F		; Loop
	bra		gassetup_sort_gaslist1a

	tstfsz	logbook_temp1		; All depths = 0?
	bra		gassetup_sort_gaslist1b	; No
	return						; Yes, skip all!

gassetup_sort_gaslist1b:
; Initialize sorting...
	bcf		menubit2				; Change Start gas only 1x
	movlw	d'99'
	movwf	logbook_temp4		; Last Gas change depth

	rcall	gassetup_sort_sort	; Sort!
; Done. Copy Gas #logbook_temp3 into EEPROM Place Gas 5
	movlw	d'5'					; Gas 5
	movwf	logbook_temp5
	rcall	gassetup_sort_store
	movff	logbook_temp1,EEDATA	; Change depth -> EEDATA
	write_int_eeprom	d'122'		; Write Change Depth Gas 5

	rcall	gassetup_sort_sort	; Sort!
; Done. Copy Gas #logbook_temp3 into EEPROM Place Gas 4
	movlw	d'4'					; Gas 4
	movwf	logbook_temp5
	rcall	gassetup_sort_store
	movff	logbook_temp1,EEDATA	; Change depth -> EEDATA
	write_int_eeprom	d'121'		; Write Change Depth Gas 4

	rcall	gassetup_sort_sort	; Sort!
; Done. Copy Gas #logbook_temp3 into EEPROM Place Gas 3
	movlw	d'3'					; Gas 3
	movwf	logbook_temp5
	rcall	gassetup_sort_store
	movff	logbook_temp1,EEDATA	; Change depth -> EEDATA
	write_int_eeprom	d'120'		; Write Change Depth Gas 3

	rcall	gassetup_sort_sort	; Sort!
; Done. Copy Gas #logbook_temp3 into EEPROM Place Gas 2
	movlw	d'2'					; Gas 2
	movwf	logbook_temp5
	rcall	gassetup_sort_store
	movff	logbook_temp1,EEDATA	; Change depth -> EEDATA
	write_int_eeprom	d'119'		; Write Change Depth Gas 2

	rcall	gassetup_sort_sort	; Sort!
; Done. Copy Gas #logbook_temp3 into EEPROM Place Gas 1
	movlw	d'1'					; Gas 1
	movwf	logbook_temp5
	rcall	gassetup_sort_store
	movff	logbook_temp1,EEDATA	; Change depth -> EEDATA
	write_int_eeprom	d'118'		; Write Change Depth Gas 1
	return

gassetup_sort_sort:
	clrf	logbook_temp2			; Gas (0-4)
	clrf	logbook_temp1			; Here: Change depth in m
	clrf	logbook_temp3			; Gas (0-4)

	lfsr	FSR2,letter+.20			; Change depths...
gassetup_sort_gaslist2:
	movf	POSTINC2,W						; Get Change depth into WREG

	cpfsgt	logbook_temp4					; logbook_temp4 < W? Here: Change depth of last sort run
	bra		gassetup_sort_gaslist3			; Skip, tested depth > max. Depth from last run

	cpfslt	logbook_temp1					; logbook_temp1 < W?
	bra		gassetup_sort_gaslist3			; Skip, tested depth < max. Depth from this run

	movwf	logbook_temp1					; copy new depth (current run)
	movff	logbook_temp2,logbook_temp3		; Holds deepest Gas 0-4 of this run
gassetup_sort_gaslist3:
	incf	logbook_temp2,F					; Check next Gas
	movlw	d'5'
	cpfseq	logbook_temp2					; All done?
	bra		gassetup_sort_gaslist2			; No
gassetup_sort_gaslist4:
	movff	logbook_temp1,logbook_temp4		; copy new depth (Store for next run)

; Debugger
;call	enable_rs232	
;	movff	logbook_temp1,TXREG
;	call	rs232_wait_tx				; wait for UART
;	movff	logbook_temp2,TXREG
;	call	rs232_wait_tx				; wait for UART
;	movff	logbook_temp3,TXREG
;	call	rs232_wait_tx				; wait for UART
;	movff	logbook_temp4,TXREG
;	call	rs232_wait_tx				; wait for UART
;	movff	logbook_temp5,TXREG
;	call	rs232_wait_tx				; wait for UART
;	WAITMS	d'255'
	return

gassetup_sort_store:
	lfsr	FSR2,letter				; Point to Gas0
	movf	logbook_temp3,W
	mullw	d'4'
	movf	PRODL,W					; x4
	addwf	FSR2L,F
	movlw	d'0'
	addwfc	FSR2H,F					; Point to Gas #logbook_temp3 (0-4)

;	btfsc	menubit2				; Change Start gas only 1x
;	bra		gassetup_sort_store2	; Skip
;; First Gas: 33 (1-5)
;; Was gas #logbook_temp3 first gas?
;	read_int_eeprom		d'33'		; Get old first gas (1-5)
;	incf	logbook_temp3,W			; Gas 1-5 -> WREG
;	cpfseq	EEDATA					; Compare with EEDATA d'33'
;	bra		gassetup_sort_store2	; Was not first gas!
;	movff	logbook_temp5,EEDATA	; Copy new first gas
;	write_int_eeprom	d'123'		; Store
;	bsf		menubit2				; Done. Do not change again.

gassetup_sort_store2:
; Was Gas #logbook_temp3 active?
; Letter+26 holds active bits  25?
	movff	logbook_temp3,logbook_temp6	; Counter 0-4
	incf	logbook_temp6,F				; Counter 1-5
	movff	letter+.25, logbook_temp2	; No longer used
	read_int_eeprom		d'27'			; Active flag register
gassetup_sort_store3:
	rrcf	logbook_temp2,F				; Shift into Carry
	decfsz	logbook_temp6,F				; 1-5 x
	bra		gassetup_sort_store3		; Loop
; Carry now holds active bit of gas #logbook_temp3 (0-4)

	btfss	STATUS,C				; Was Gas active?
	clrf	logbook_temp1			; No!, Clear change Depth to make it inactive for sorted list!

;call	enable_rs232	
;movff	logbook_temp1,TXREG
;call	rs232_wait_tx				; wait for UART

	movf	logbook_temp5,W			; 1-5
	mullw	d'4'
	movff	PRODL,EEADR				; Point to EEPROM of Gas #logbook_temp5
	movlw	d'90'					; +90 Offset to new... 
	addwf	EEADR,F					; ..sorted list!

	movff	POSTINC2,EEDATA			; O2 Default
	call	write_eeprom			; store in internal EEPROM
	incf	EEADR,F					; +1
	movff	POSTINC2,EEDATA			; He Default
	call	write_eeprom			; store in internal EEPROM
	incf	EEADR,F					; +1
	movff	POSTINC2,EEDATA			; O2 Current
	call	write_eeprom			; store in internal EEPROM
	incf	EEADR,F					; +1
	movff	POSTINC2,EEDATA			; He Current
	call	write_eeprom			; store in internal EEPROM
	return