
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
	DISPLAYTEXT	.231			; Dil. Setup - Gaslist
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

	incf	wait_temp, W        ; Gas %O2
	movwf	EEADR				; Gas %He - Set address in internal EEPROM
    movlw   .1
    movwf   EEADRH
	call	read_eeprom			; Read He value from EEPROM
	movff	EEDATA,lo			; Move EEDATA -> lo
	movf	lo,f				; Move lo -> f
	movlw	d'0'				; Move 0 -> WREG
	cpfsgt	lo					; He > 0?
	bra 	menu_diluentsetup_Nx	; NO check o2

	; YES Write TX 15/55
   STRCAT  TXT_TX3
	movff	wait_temp, EEADR	; Gas %O2 - Set address in internal EEPROM
    movlw   .1
    movwf   EEADRH
	call	read_eeprom			; O2 value
	movff	EEDATA,lo
	output_8
	PUTC	'/'
	incf	EEADR,F				; Gas #hi: %He - Set address in internal EEPROM
    movlw   .1
    movwf   EEADRH
	call	read_eeprom			; He value
	movff	EEDATA,lo
	output_8
	bra 	menu_diluentsetup_list0

; New v1.44se
menu_diluentsetup_Nx:
	movff	wait_temp, EEADR	; Gas %O2 - Set address in internal EEPROM
    movlw   .1
    movwf   EEADRH
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
    STRCAT  TXT_NX3
	output_8
	bra 	menu_diluentsetup_list0

menu_diluentsetup_O2:
    STRCAT  TXT_O2_3
	output_8
	bra 	menu_diluentsetup_list0

menu_diluentsetup_Air:
	cpfseq	lo					; o2 = 21%
	bra     menu_diluentsetup_Err

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
	bra		diluent_list_edit_gas2
	dcfsnz	menupos,F
	bra		diluent_list_edit_gas3
	dcfsnz	menupos,F
	bra		diluent_list_edit_gas4
	dcfsnz	menupos,F
	bra		diluent_list_edit_gas5
	bra		menu_const_ppO2             ; Exit List

diluent_list_edit_gas1:
	movlw	d'0'                        ; Diluent Number 0-4
	movwf	decodata+0
	movlw	d'96'                       ; EEPROM address of %O2
	movwf	divemins+0
	bra		menu_diluentgas
diluent_list_edit_gas2:
	movlw	d'1'                        ; Diluent Number 0-4
	movwf	decodata+0
	movlw	d'98'                       ; EEPROM address of %O2
	movwf	divemins+0
	bra		menu_diluentgas
diluent_list_edit_gas3:
	movlw	d'2'                        ; Diluent Number 0-4
	movwf	decodata+0
	movlw	d'100'                       ; EEPROM address of %O2
	movwf	divemins+0
	bra		menu_diluentgas
diluent_list_edit_gas4:
	movlw	d'3'                        ; Diluent Number 0-4
	movwf	decodata+0
	movlw	d'102'                       ; EEPROM address of %O2
	movwf	divemins+0
	bra		menu_diluentgas
diluent_list_edit_gas5:
	movlw	d'4'                        ; Diluent Number 0-4
	movwf	decodata+0
	movlw	d'104'                       ; EEPROM address of %O2
	movwf	divemins+0
;	bra		menu_diluentgas
menu_diluentgas:
	movlw	d'1'
	movwf	menupos
	bcf		menubit4
	bcf		first_FA				; Here: =1: -, =0: +

menu_diluentgas0:
	call	PLED_ClearScreen
    WIN_LEFT    .20
	WIN_TOP		.155
    lfsr    FSR2, letter
	OUTPUTTEXT  .11			; Exit
    STRCAT_PRINT  ""

menu_diluentgas1:
	call	menu_pre_loop_common		; Clear some menu flags, timeout and switches

	call	diluent_title_bar2			; Displays the title bar with the current Gas info

	WIN_LEFT	.20
	WIN_TOP		.35
	STRCPY  TXT_O2_4
	movff	divemins+0,EEADR
    movlw   .1
    movwf   EEADRH
	call	read_eeprom                 ; O2 value
	movff	EEDATA,lo
	output_8
	STRCAT_PRINT "% "

; Show MOD in m
	WIN_LEFT	.90
    lfsr    FSR2, letter
	OUTPUTTEXTH .297                    ; MOD:

    GETCUSTOM8 .18                      ; ppO2 warnvalue in WREG
	mullw	d'10'
	movff	PRODL,xA+0
	movff	PRODH,xA+1                  ; ppO2 in [0.01bar] * 10
	movff	divemins+0,EEADR
	movlw   .1
	movwf	EEADRH
	call	read_eeprom                 ; O2 value
	movff	EEDATA,xB+0
	clrf	xB+1
	call	div16x16                    ; xA/xB=xC with xA as remainder
	movlw	d'10'
	subwf	xC+0,F                      ; Subtract 10m...
	movff	xC+0,lo
	movlw	d'0'
	subwfb	xC+1,F
	movff	xC+1,hi

	output_16
	STRCAT_PRINT  TXT_METER3

	WIN_LEFT	.20
	WIN_TOP		.65
	STRCPY  TXT_HE4
	incf	divemins+0,W
    movwf   EEADR
    movlw   .1
    movwf   EEADRH
	call	read_eeprom                 ; He value
	movff	EEDATA,lo
	output_8
	STRCAT_PRINT "% "

; Show END in m
    lfsr    FSR2, letter
	WIN_LEFT	.90
	OUTPUTTEXTH .298                    ; END:
	GETCUSTOM8 .18				        ; ppO2 warnvalue in WREG
	mullw	d'10'
	movff	PRODL,xA+0
	movff	PRODH,xA+1		            ; ppO2 in [0.01bar] * 10
    movff	divemins+0,EEADR
    movlw   .1
    movwf   EEADRH
	call	read_eeprom                 ; O2 value
	movff	EEDATA,xB+0
	clrf	xB+1
	call	div16x16                    ; xA/xB=xC with xA as remainder
	movlw	d'10'
	subwf	xC+0,F                      ; Subtract 10m...
	movff	xC+0,lo
	movlw	d'0'
	subwfb	xC+1,F
	movff	xC+1,hi                     ; lo:hi holding MOD in meters
	movlw	d'10'
	addwf	lo,F
	movlw	d'0'
	addwfc	hi,F                        ; lo:hi holding MOD+10m

	incf	divemins+0,W
    movwf   EEADR
    movlw   .1
    movwf   EEADRH
	call	read_eeprom                 ; He value in % -> EEDATA
	movlw	d'100'
	movwf	xA+0
	movf	EEDATA,W                    ; He value in % -> EEDATA
	subwf	xA+0,F                      ; xA+0 = 100 - He Value in %
	clrf	xA+1
	movff	lo,xB+0
	movff	hi,xB+1                     ; Copy MOD+10
	call	mult16x16                   ; xA*xB=xC
	movff	xC+0,xA+0
	movff	xC+1,xA+1
	movlw	d'100'
	movwf	xB+0
	clrf	xB+1
	call	div16x16                    ; xA/xB=xC with xA as remainder
	;	xC:2 = ((MOD+10) * 100 - HE Value in %) / 100
	movlw	d'10'
	subwf	xC+0,F				        ; Subtract 10m...
	movff	xC+0,lo
	movlw	d'0'
	subwfb	xC+1,F
	movff	xC+1,hi
	output_16
	STRCAT_PRINT  TXT_METER3

    WIN_LEFT    .20
	WIN_TOP		.95
	STRCPY  "+/-: "
	movlw	'+'
	btfsc	first_FA
	movlw	'-'
	movwf	POSTINC2
	call	word_processor

	WIN_TOP		.125
	lfsr	FSR2,letter
	OUTPUTTEXT	.89			            ; Default:
    movlw   .21
    movwf   lo                          ; Default always Air
	output_8
	PUTC	'/'
    clrf    lo                          ; Default He value
	output_8
	STRCAT_PRINT  "  "

	call	wait_switches		; Waits until switches are released, resets flag if button stays pressed!
	call	PLED_menu_cursor

diluentgassetup_loop:
	call	check_switches_logbook

	btfsc	menubit3
	bra		diluentgassetup2           ; move cursor

	btfsc	menubit2
	bra		do_diluentgassetup		; call submenu

	btfsc	onesecupdate
	call	menu_check_dive_and_timeout	; "Goto restart" or sets sleepmode flag

	bcf		onesecupdate	; 1 sec. functions done

	btfsc	sleepmode
	bra		exit_menu_const_ppO2

	bra     diluentgassetup_loop

diluentgassetup2:
	incf	menupos,F
	movlw	d'6'
	cpfseq	menupos             ; =6?
	bra		diluentgassetup3	; No
	movlw	d'1'
	movwf	menupos

diluentgassetup3:
	clrf	timeout_counter2
	call	PLED_menu_cursor

	call	wait_switches		; Waits until switches are released, resets flag if button stays pressed!

	bcf		menubit3		; clear flag
	bra		diluentgassetup_loop

do_diluentgassetup:
	dcfsnz	menupos,F
	bra		adjust_o2_diluent
	dcfsnz	menupos,F
	bra		adjust_he_diluent
	dcfsnz	menupos,F
	bra		toggle_plus_minus_diluentsetup
	dcfsnz	menupos,F
	bra		restore_gas_diluent
exit_diluentgassetup:			; exit...
	movff	decodata+0,menupos
	incf	menupos,F
	bra		menu_diluentsetup_prelist

toggle_plus_minus_diluentsetup:
	btg		first_FA
	movlw	d'3'
	movwf	menupos
	bra		menu_diluentgas1	; return

adjust_o2_diluent:
	movff	divemins+0,EEADR			; read current value
	movlw   .1
	movwf	EEADRH
	call	read_eeprom		; Low-value
	movff	EEDATA,lo

	btfsc	first_FA			; Minus?
	bra		adjust_o2_1_diluent			; yes, minus!

	incf	lo,F			; increase O2
	movlw	d'101'
	cpfseq	lo
	bra		adjust_o2_2_diluent
	movlw	d'4'			; LOWER O2 Limit
	movwf	lo
	bra		adjust_o2_2_diluent

adjust_o2_1_diluent:
	decf	lo,F			; decrease O2
	movlw	d'3'
	cpfseq	lo
	bra		adjust_o2_2_diluent

	incf	divemins+0,W
	movwf	EEADR
    movlw   .1
    movwf   EEADRH
	call	read_eeprom		; read He value

	movlw	d'100'
	movwf	lo
	movf	EEDATA,W		; He value
	subwf	lo,F			; lo=100% - He%

adjust_o2_2_diluent:				; test if O2+He>100...
	incf	divemins+0,W
	movwf	EEADR
    movlw   .1
    movwf   EEADRH
	call	read_eeprom		; read He value
	movf	EEDATA,W		; He value
	addwf	lo,W			; add O2 value
	movwf	hi				; store in temp
	movlw	d'101'
	cpfseq	hi				; O2 and He > 100?
	bra		adjust_o2_3_diluent		; No!

	movlw	d'4'			; LOWER O2 Limit
	movwf	lo

adjust_o2_3_diluent:
	movff	divemins+0,EEADR		; save current value
	movff	lo,EEDATA
    movlw   .1
    movwf   EEADRH
	call	write_eeprom		; Low-value

	movlw	d'1'
	movwf	menupos
	bra		menu_diluentgas1	; return

adjust_he_diluent:
	incf	divemins+0,W
    movwf   EEADR			; read current value
	movlw   .1
	movwf	EEADRH
	call	read_eeprom		; Low-value
	movff	EEDATA,lo

	btfsc	first_FA			; Minus?
	bra		adjust_he_1_diluent			; yes, minus!

	incf	lo,F
	movlw	d'92'			; He limited to (useless) 90%
	cpfseq	lo
	bra		adjust_he_2_diluent
	clrf	lo
	bra		adjust_he_2_diluent

adjust_he_1_diluent:
	decf	lo,F			; decrease He
	movlw	d'255'
	cpfseq	lo
	bra		adjust_he_2_diluent
	clrf	lo

adjust_he_2_diluent:				; test if O2+He>100...
	incf	divemins+0,W
	movwf	EEADR
    movlw   .1
    movwf   EEADRH
	call	read_eeprom		; read He value
	movf	EEDATA,W		; He value
	addwf	lo,W			; add O2 value
	movwf	hi				; store in temp
	movlw	d'101'
	cpfseq	hi				; O2 and He > 100?
	bra		adjust_he_3_diluent		; No!
;	clrf	lo				; Yes, clear He to zero
	decf	lo,F			; reduce He again = unchanged after operation

adjust_he_3_diluent:
	incf	divemins+0,W			; save current value
	movwf	EEADR
	movff	lo,EEDATA
    movlw   .1
    movwf   EEADRH
	call	write_eeprom		; Low-value

	movlw	d'2'
	movwf	menupos
	bra		menu_diluentgas1	;

restore_gas_diluent:
	movff	divemins+0,EEADR			; save Default value (O2)
    movlw   .1
    movwf   EEADRH
    movlw   .21                         ; Always Air
	movwf	EEDATA
	call	write_eeprom
	incf   	EEADR,F                     ; Point to He
	clrf    EEDATA
	call	write_eeprom
	movlw	d'4'
	movwf	menupos
	bra		menu_diluentgas1


diluent_title_bar2:
	call	PLED_topline_box
	WIN_INVERT	.1	; Init new Wordprocessor
	WIN_TOP		.2
	WIN_LEFT	.30
	lfsr	FSR2,letter
    STRCAT  TXT_DIL5            ; Dil.#
	movff	decodata+0,lo
	incf	lo,F
	bsf		leftbind
	output_99
	STRCAT_PRINT ": "

	WIN_TOP		.2
	WIN_LEFT	.80
	lfsr	FSR2,letter

	;He check
	incf	divemins+0,W
	movwf	EEADR
    movlw   .1
    movwf   EEADRH
	call	read_eeprom			; He value
	movff	EEDATA,lo			; Move EEData -> lo
	movf	lo,f				; Move lo -> f
	movlw	d'0'				; Move 0 -> WREG
	cpfsgt	lo					; He > 0?
	bra 	diluent_title_bar3	; NO check o2

	; YES Write TX 15/55
    STRCAT  TXT_TX3
	movff	divemins+0,EEADR
	movlw   .1
	movwf	EEADRH
	call	read_eeprom			; O2 value
	movff	EEDATA,lo
	output_8					; Write O2
	PUTC	'/'
	incf	divemins+0,W
	movwf	EEADR
	call	read_eeprom			; He value
	movff	EEDATA,lo
	output_8					; Write He
	bra		diluent_title_bar7

; New v1.44se
diluent_title_bar3:			; O2 Check
	movff	divemins+0,EEADR
	call	read_eeprom			; O2 value
	movff	EEDATA,lo
	movf	lo,f				; Move lo -> f
	movlw	d'21'				; Move 21 -> WREG
	cpfseq	lo					; o2 = 21
	cpfsgt	lo					; o2 > 21%
	bra 	diluent_title_bar5	; NO AIR
	movlw	d'100'				; Move 100 -> WREG
	cpfslt	lo					; o2 < 100%
	bra		diluent_title_bar4	; NO write O2

	; YES Write NX 32
    STRCAT  TXT_NX3
	output_8
	bra 	diluent_title_bar7

; New v1.44se
diluent_title_bar4:
    STRCAT  TXT_O2_3
	output_8
	bra 	diluent_title_bar7

; New v1.44se
diluent_title_bar5:
	cpfseq	lo					; o2 = 21%
	bra 	diluent_title_bar6

    STRCAT  TXT_AIR4
	output_8
	bra 	diluent_title_bar7

; New v1.44se
diluent_title_bar6:		; ERROR
    STRCAT  TXT_ERR4
	output_8
	;bra 	diluent_title_bar7

diluent_title_bar7:
    STRCAT_PRINT  ""
	WIN_INVERT	.0	; Init new Wordprocessor
	return


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

 	movlw	d'96'						; = address for O2 ratio
	movwf	EEADR
    movlw   .1
    movwf   EEADRH
	call	read_eeprom					; Read O2 ratio
	movff	EEDATA, lo                  ; O2 ratio
	bsf		leftbind
	output_99
	PUTC	'/'
	movlw	d'97'						; = address for He ratio
	movwf	EEADR
    movlw   .1
    movwf   EEADRH
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