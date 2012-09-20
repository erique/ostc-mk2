
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
; last updated: 120920
; known bugs:
; ToDo: 
;
; New in 2.52 Diluents stored seperately in EEPROM Bank1
; EEPROM BANK1 Byte96-97:
; Diluent 1 (%O2,%He)
; EEPROM BANK1 Byte98-99:
; Diluent 2 (%O2,%He)
; EEPROM BANK1 Byte100-101:
; Diluent 3 (%O2,%He)
; EEPROM BANK1 Byte102-103:
; Diluent 4 (%O2,%He)
; EEPROM BANK1 Byte104-105:
; Diluent 5 (%O2,%He)


menu_const_ppO2:
	movlw	d'1'
	movwf	menupos
menu_const_ppO2_return:
    call	PLED_ClearScreen
    call    PLED_ccr_setup_menu_mask
	call	refresh_cursor
    call    menu_pre_loop_common

menu_const_ppO2_preloop:
	call	check_switches_menu
	movlw	d'3'
	cpfseq	menupos
	bra		menu_const_ppO2_preloop2	; Returns
	movlw	d'6'
    movwf   menupos
    call    PLED_menu_cursor

menu_const_ppO2_preloop2:
	btfsc	menubit2
	bra		do_ccr_pre_menu             ; call submenu
	btfss	menubit
	goto	restart						; exit menu, restart
	btfsc	onesecupdate
	call	menu_check_dive_and_timeout	; "Goto restart" or sets sleepmode flag
	bcf		onesecupdate				; End of one second tasks
	btfsc	sleepmode
	goto	restart
	bra		menu_const_ppO2_preloop

do_ccr_pre_menu:
    dcfsnz	menupos,F
	goto	menu_diluentsetup
	dcfsnz	menupos,F
	goto	menu_const_ppO2_setpoints
	dcfsnz	menupos,F
	goto	exit_menu_const_ppO2			; exit...
	dcfsnz	menupos,F
	goto	exit_menu_const_ppO2			; exit...
	dcfsnz	menupos,F
	goto	exit_menu_const_ppO2			; exit...
exit_menu_const_ppO2:			; exit...
	movlw	d'2'
	movwf	menupos
	goto	more_menu2

menu_diluentsetup:
	movlw	d'1'
	movwf	menupos

menu_diluentsetup_prelist:
	call	PLED_ClearScreen
	call	menu_pre_loop_common		; Clear some menu flags, timeout and switches
	call	PLED_topline_box
	WIN_INVERT	.1	; Init new Wordprocessor
	DISPLAYTEXT	.106			; Gas List
	WIN_INVERT	.0	; Init new Wordprocessor
	clrf	decodata+0				; Here: # of gas 0-4
	clrf	divemins+0				; Here: # of Gas * 4
	movlw	d'5'
	movwf	waitms_temp		; here: stores row for gas list
	movlw	d'94'
	movwf	wait_temp			; here: stores eeprom address for gas list
    movlw   .1
    movwf   EEADRH

menu_diluentsetup_list:
	WIN_LEFT	.20
	movlw	d'2'
	addwf	wait_temp,F			; Increase eeprom address for gas list
	movlw	d'30'
	addwf	waitms_temp,F		; Increase row
	movf	waitms_temp,W		; Load row into WREG
	movff	WREG,win_top
	lfsr	FSR2,letter
	PUTC	TXT_DIL_C
	movff	decodata+0,lo
	incf	lo,F
	bsf		leftbind
	output_99
	PUTC	':'

menu_diluentsetup_Tx:
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
	bra 	menu_diluentsetup_Nx	; NO check o2

	; YES Write TX 15/55
	call 	gassetup_write_Tx
	movff	wait_temp, EEADR	; Gas %O2 - Set address in internal EEPROM
	call	read_eeprom			; O2 value
	movff	EEDATA,lo
	output_8
	PUTC	'/'
	incf	EEADR,F				; Gas #hi: %He - Set address in internal EEPROM
	call	read_eeprom			; He value
	movff	EEDATA,lo
	output_8
	bra 	menu_diluentsetup_list0

; New v1.44se
menu_diluentsetup_Nx:
	movff	wait_temp, EEADR	; Gas %O2 - Set address in internal EEPROM
	call	read_eeprom			; Read O2 value from EEPROM
	movff	EEDATA,lo			; Move EEDATA -> lo
	movf	lo,f				; Move lo -> f
	movlw	d'21'				; Move 21 -> WREG
	cpfsgt	lo					; o2 > 21%
	bra 	menu_diluentsetup_Air	; NO AIR
	movlw	d'100'				; Move 100 -> WREG
	cpfslt	lo					; o2 < 100%
	bra		menu_diluentsetup_O2	; NO write O2

	; YES Write NX 32
	call	gassetup_write_Nx
	output_8
	bra 	menu_diluentsetup_list0

menu_diluentsetup_O2:
    STRCAT  TXT_O2_3
	output_8
	bra 	menu_diluentsetup_list0

menu_diluentsetup_Air:
	cpfseq	lo					; o2 = 21%
	call    menu_gassetup_Err

    STRCAT  TXT_AIR4
	output_8
	bra 	menu_diluentsetup_list0

menu_diluentsetup_Err:
    STRCAT  TXT_ERR4
	output_8

menu_diluentsetup_list0:
	call	word_processor

	incf	decodata+0,F
	movlw	d'5'
	cpfseq	decodata+0
	goto	menu_diluentsetup_list

	DISPLAYTEXT	.11                     ; Exit
	call	wait_switches               ; Waits until switches are released, resets flag if button stays pressed!
	call	PLED_menu_cursor
    clrf    EEADRH

menu_diluentsetup_loop:
	call	check_switches_logbook

	btfsc	menubit3
	bra		menu_diluentsetup_list2              ; move cursor

	btfsc	menubit2
	bra		do_diluentsetup_list        ; call gas-specific submenu

	btfsc	onesecupdate
	call	menu_check_dive_and_timeout	; "Goto restart" or sets sleepmode flag

	bcf		onesecupdate                ; 1 sec. functions done

	btfsc	sleepmode
	bra		menu_const_ppO2

	bra		menu_diluentsetup_loop

menu_diluentsetup_list2:
	incf	menupos,F
	movlw	d'7'
	cpfseq	menupos			; =7?
	bra		menu_diluentsetup_list3	; No
	movlw	d'1'
	movwf	menupos

menu_diluentsetup_list3:
	clrf	timeout_counter2
	call	PLED_menu_cursor

	call	wait_switches		; Waits until switches are released, resets flag if button stays pressed!

	bcf		menubit3		; clear flag
	bra		menu_diluentsetup_loop


do_diluentsetup_list:
	dcfsnz	menupos,F
	bra		diluent_list_edit_gas1
	dcfsnz	menupos,F
	bra		diluent_list_edit_gas1
	dcfsnz	menupos,F
	bra		diluent_list_edit_gas1
	dcfsnz	menupos,F
	bra		diluent_list_edit_gas1
	dcfsnz	menupos,F
	bra		diluent_list_edit_gas1
	bra		menu_const_ppO2             ; Exit List

diluent_list_edit_gas1:
diluent_list_edit_gas2:
diluent_list_edit_gas3:
diluent_list_edit_gas4:
diluent_list_edit_gas5:
    bra		menu_const_ppO2             ; Exit List

; ***







menu_const_ppO2_setpoints:          ; Setpoint menu
	movlw	d'1'
	movwf	menupos

	bcf		menubit4
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

    movlw   .1
    movwf   EEADRH
	addlw	d'96'						; = address for O2 ratio
	movwf	EEADR
	call	read_eeprom					; Read O2 ratio
	movff	EEDATA, lo                  ; O2 ratio
	bsf		leftbind
	output_99
	PUTC	'/'
	addlw	d'97'						; = address for He ratio
	movwf	EEADR
	call	read_eeprom					; Read He ratio
	movff	EEDATA,lo                   ; And copy into hold register
    clrf    EEADRH
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
	STRCAT_PRINT TXT_BAR4

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
	call	menu_pre_loop_common		; Clear some menu flags, timeout and switches
	call	PLED_menu_cursor

menu_const_ppO2_loop:
	call	check_switches_logbook

	btfsc	menubit3
	bra		menu_const_ppO22	; move cursor

	btfsc	menubit2
	bra		do_menu_const_ppO2		; call submenu

	btfsc	onesecupdate
	call	menu_check_dive_and_timeout	; "Goto restart" or sets sleepmode flag

	bcf		onesecupdate	; 1 sec. functions done

	btfsc	sleepmode
	bra		exit_menu_const_ppO2

	bra		menu_const_ppO2_loop

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
	call	menu_pre_loop_common		; Clear some menu flags, timeout and switches
	call	PLED_menu_cursor
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
	movlw	d'2'
	movwf	menupos
    bra     menu_const_ppO2_return

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
	bra		menu_const_ppO21

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
	bra		menu_const_ppO21	