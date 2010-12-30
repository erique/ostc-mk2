
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


; Constant ppO2 Setup menu
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 08/04/04
; last updated: 080904
; known bugs:
; ToDo: 

menu_const_ppO2:
	movlw	d'1'
	movwf	menupos

	bcf		menubit4
	bcf		cursor
	bcf		sleepmode
	clrf	decodata+0				; Here: # of SP
	bcf		first_FA				; Here: =1: -, =0: +
	bcf		second_FA				; Here: =1: 1, =0: 10 steps

menu_const_ppO20:
	call	PLED_ClearScreen
	call	PLED_topline_box

	WIN_INVERT	.1			; Init new Wordprocessor	
	DISPLAYTEXT	.111		; Constant ppO2 Setup
	WIN_INVERT	.0			; Init new Wordprocessor	


menu_const_ppO21:
	clrf	timeout_counter2
	bcf		menubit2
	bcf		menubit3

	WIN_LEFT 	.20
	WIN_TOP		.35
	lfsr	FSR2,letter
	OUTPUTTEXT	.112				; SP# 
	movff	decodata+0,lo		
	incf	lo,F				
	bsf		leftbind
	output_99
	STRCAT  " ("
	
	OUTPUTTEXT	d'192'				; Dil.
	PUTC	' '

	read_int_eeprom 	d'33'			; Read byte (stored in EEDATA)
	movff	EEDATA,active_gas			; Read start gas (1-5)

	decf	active_gas,W				; Gas 0-4
	mullw	d'4'
	movf	PRODL,W			
	addlw	d'6'						; = address for O2 ratio
	movwf	EEADR
	call	read_eeprom					; Read O2 ratio
	movff	EEDATA, lo		; O2 ratio


	bsf		leftbind
	output_99

	PUTC	'/'

	decf	active_gas,W				; Gas 0-4
	mullw	d'4'
	movf	PRODL,W			
	addlw	d'7'						; = address for He ratio
	movwf	EEADR
	call	read_eeprom					; Read He ratio
	movff	EEDATA,lo		; And copy into hold register

	bsf		leftbind
	output_99
	STRCAT_PRINT ")"


	WIN_LEFT 	.20
	WIN_TOP		.65

	lfsr	FSR2,letter
	OUTPUTTEXT	.97			; "Current: "
	movf	decodata+0,W
	addlw	d'36'				; offset in eeprom
	movwf	EEADR
	call	read_eeprom		; ppO2 value
	movff	EEDATA,lo
	clrf	hi
	bsf		leftbind
	output_16dp	d'3'
	bcf		leftbind
	STRCAT_PRINT "Bar "

	WIN_LEFT 	.20
	WIN_TOP		.95

	lfsr	FSR2,letter
	OUTPUTTEXT	d'190'			; ppO2 +
	call	word_processor		

	WIN_LEFT 	.20
	WIN_TOP		.125

	lfsr	FSR2,letter
	OUTPUTTEXT	d'191'			; ppO2 -
	call	word_processor		

	WIN_LEFT 	.20
	WIN_TOP		.155

	lfsr	FSR2,letter
	OUTPUTTEXT	.89			; "Default: "
	STRCAT_PRINT "1.00"

	DISPLAYTEXT	.11			; Exit
	call	wait_switches		; Waits until switches are released, resets flag if button stays pressed!
	call	PLED_menu_cursor

menu_const_ppO2_loop:
	call	check_switches_logbook

	btfsc	menubit3
	bra	menu_const_ppO22	; move cursor

	btfsc	menubit2
	bra	do_menu_const_ppO2		; call submenu

	btfsc	divemode
	goto	restart			; dive started!

	btfsc	onesecupdate
	call	timeout_surfmode

	btfsc	onesecupdate
	call	set_dive_modes

	bcf		onesecupdate	; 1 sec. functions done

	btfsc	sleepmode
	bra	exit_menu_const_ppO2

	bra	menu_const_ppO2_loop

menu_const_ppO22:
	incf	menupos,F
	
	movlw	d'2'
	cpfseq	menupos				; =2?
	bra		menu_const_ppO22a	; No
	incf	menupos,F			; Skip pos. 2

menu_const_ppO22a:
	movlw	d'7'
	cpfseq	menupos			; =7?
	bra		menu_const_ppO23	; No
	movlw	d'1'
	movwf	menupos

menu_const_ppO23:
	clrf	timeout_counter2
	call	PLED_menu_cursor
	
	; debounce switches
	call	wait_switches		; Waits until switches are released, resets flag if button stays pressed!	
	bcf		menubit3		; clear flag
	bra		menu_const_ppO2_loop

do_menu_const_ppO2:
	dcfsnz	menupos,F
	bra		next_ppO2
	dcfsnz	menupos,F
	bra		change_ppo2_plus
	dcfsnz	menupos,F
	bra		change_ppo2_plus
	dcfsnz	menupos,F
	bra		change_ppo2_minus
	dcfsnz	menupos,F
	bra		change_ppo2_reset
exit_menu_const_ppO2:			; exit...
	movlw	d'2'
	movwf	menupos
	goto	more_menu2

change_ppo2_plus:
	movf	decodata+0,W		; read current value 
	addlw	d'36'				; offset in memory
	movwf	EEADR
	call	read_eeprom			; Low-value
	movff	EEDATA,lo
	
	incf	lo,F				; increase depth
	movlw	d'251'
	cpfseq	lo
	bra		change_ppo2_plus2
	movlw	d'250'
	movwf	lo
change_ppo2_plus2:
	movff	lo,EEDATA			; write result
	call	write_eeprom		; save result in EEPROM
	movlw	d'3'
	movwf	menupos
	bra		menu_const_ppO21

change_ppo2_minus:
	movf	decodata+0,W		; read current value 
	addlw	d'36'				; offset in memory
	movwf	EEADR
	call	read_eeprom			; Low-value
	movff	EEDATA,lo
	
	decf	lo,F				; decrease depth
	movlw	d'255'
	cpfseq	lo
	bra	change_ppo2_minus2
	movlw	d'0'
	movwf	lo

change_ppo2_minus2:
	movff	lo,EEDATA			; write result
	call	write_eeprom		; save result in EEPROM

	movlw	d'4'
	movwf	menupos
	bra	menu_const_ppO21

change_ppo2_reset:				; reset to 1.00Bar
	movf	decodata+0,W		; read current value 
	addlw	d'36'				; offset in memory
	movwf	EEADR
	movlw	d'100'
	movwf	EEDATA
	call	write_eeprom		; save result in EEPROM
	movlw	d'5'
	movwf	menupos
	bra	menu_const_ppO21

next_ppO2:
	incf	decodata+0,F
	movlw	d'3'
	cpfseq	decodata+0			; =3?
	bra	next_ppO22
	clrf	decodata+0			; yes, so reset to zero
next_ppO22:	
	movlw	d'1'
	movwf	menupos
	bra	menu_const_ppO21	