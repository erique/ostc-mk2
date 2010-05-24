
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


; menu "Simulator"
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 081210
; last updated: 081210
; known bugs:
; ToDo: 

menu_simulator:
	movlw	d'1'
	movwf	logbook_temp1		; Bottom time
	movlw	d'15'
	movwf	logbook_temp2		; Max. Depth
	movlw	d'1'
	movwf	menupos

menu_simulator1:
	clrf	timeout_counter2
	bsf		menubit
	bsf		cursor
	call	PLED_ClearScreen
	call	PLED_simulator_mask

menu_simulator2:
	bcf		switch_left
	bcf		switch_right
	bcf		menubit2
	bcf		menubit3
	call	PLED_simulator_data
	call	PLED_menu_cursor

menu_simulator_loop:
	call	check_switches_menu
menu_simulator_loop2:
	btfss	onesecupdate
	bra		menu_simulator_loop3

	call	timeout_surfmode
	call	set_dive_modes
	call	test_charger				; check if charger IC is active
	call	get_battery_voltage			; get battery voltage
	
	bcf		onesecupdate				; End of one second tasks

menu_simulator_loop3:
	btfsc	menubit2
	goto	menu_simulator_do			; call submenu

	btfss	menubit
	goto	menu						; exit setup menu and return to main menu

	btfsc	sleepmode
	goto	more_menu

	btfsc	divemode
	goto	restart						; exit menu, restart and enter divemode

	bra		menu_simulator_loop

menu_simulator_do:						; calls submenu
	dcfsnz	menupos,F
	bra		simulator_startdive
	dcfsnz	menupos,F
	bra		simulator_inc_bottomtime
	dcfsnz	menupos,F
	bra		simulator_inc_maxdepth
	dcfsnz	menupos,F
	bra		simulator_calc_deco
	dcfsnz	menupos,F
	bra		simulator_show_decoplan
	movlw	d'4'
	movwf	menupos
	goto	more_menu2						; exit...

simulator_inc_bottomtime:
	movlw	d'2'
	addwf	logbook_temp1,F				; Here: Bottomtime in m
	movlw	d'199'
	cpfslt	logbook_temp1
	movwf	logbook_temp1
	movlw	d'2'
	movwf	menupos
	bra		menu_simulator2

simulator_inc_maxdepth:
	movlw	d'3'
	addwf	logbook_temp2,F				; Here: Maxdepth in m
	movlw	d'99'
	cpfslt	logbook_temp2
	movwf	logbook_temp2
	movlw	d'3'
	movwf	menupos
	bra		menu_simulator2

simulator_startdive:
	; Descent to -3m depth
	; Set standalone_simulator flag (Displays Simulator menu during simulation by pressing ENTER button)
	; Clear standalone_simulator after (any) dive
	bsf		simulatormode_active			; normal simulator mode
	bsf		standalone_simulator			; Standalone Simulator active
	
	movff	logbook_temp2,xA+0
	clrf	xA+1
	movlw	d'100'
	movwf	xB+0
	clrf	xB+1
	call	mult16x16	;xA*xB=xC			; Depth in m*100

	movlw	LOW		d'1000'
	addwf	xC+0,F
	movlw	HIGH	d'1000'
	addwfc	xC+1,F							; Add 1000mBar
	
	movff	xC+0,sim_pressure+0
	movff	xC+1,sim_pressure+1
	
	movff	sim_pressure+0,amb_pressure+0	; override readings with simulator values
	movff	sim_pressure+1,amb_pressure+1

	bcf		menubit2
	bcf		menubit3
	bcf		menubit
	bcf		switch_left
	bcf		switch_right

	call	simulator_save_tissue_data		; Stores 32 floats "pre_tissue" into bank3

	bsf		divemode						; Set divemode flag
	ostc_debug	'P'							; Sends debug-information to screen if debugmode active
	goto	diveloop						; Start Divemode

simulator_save_tissue_data:
	bsf		restore_deco_data		; Set restore flag
	ostc_debug	'S'							; Sends debug-information to screen if debugmode active
	call	main_push_tissues_to_vault
	movlb	0x01							; Back to RAM Bank1
	ostc_debug	'T'							; Sends debug-information to screen if debugmode active
	return

simulator_restore_tissue_data:
	bcf		restore_deco_data		; clear restore flag
	ostc_debug	'S'							; Sends debug-information to screen if debugmode active
	call	main_pull_tissues_from_vault
	movlb	0x01						; Back to RAM Bank1
	ostc_debug	'T'							; Sends debug-information to screen if debugmode active

	ostc_debug	'G'		; Sends debug-information to screen if debugmode active
	call	deco_main_calc_desaturation_time	; calculate desaturation time
	movlb	b'00000001'						; select ram bank 1
	call	calculate_noflytime				; Calc NoFly time
	ostc_debug	'H'		; Sends debug-information to screen if debugmode active
	return
	
simulator_show_decoplan:
	call	PLED_ClearScreen
	call	divemenu_see_decoplan
	
	bcf		switch_left
	bcf		switch_right

simulator_show_decoplan2:
	btfss	onesecupdate
	bra		simulator_show_decoplan3

	call	timeout_surfmode
	call	set_dive_modes
	call	test_charger				; check if charger IC is active
	call	get_battery_voltage			; get battery voltage
	
	bcf		onesecupdate				; End of one second tasks

simulator_show_decoplan3:
	btfsc	switch_left
	bra		simulator_show_decoplan4	; Quit display

	btfsc	switch_right
	bra		simulator_show_decoplan4	; Quit display

	btfsc	sleepmode
	goto	more_menu

	btfsc	divemode
	goto	restart						; exit menu, restart and enter divemode

	bra		simulator_show_decoplan2

simulator_show_decoplan4:
	movlw	d'5'
	movwf	menupos
	bra		menu_simulator1
	
	
simulator_calc_deco:
	call	diveloop_boot					; configure gases, etc.

	bsf		simulatormode_active			; normal simulator mode
	bsf		standalone_simulator			; Standalone Simulator active


	movff	logbook_temp2,xA+0
	clrf	xA+1
	movlw	d'100'
	movwf	xB+0
	clrf	xB+1
	call	mult16x16	;xA*xB=xC			; Depth in m*100

	movlw	LOW		d'1000'
	addwf	xC+0,F
	movlw	HIGH	d'1000'
	addwfc	xC+1,F							; Add 1000mBar
	
	movff	xC+0,sim_pressure+0
	movff	xC+1,sim_pressure+1

	movff	sim_pressure+0,amb_pressure+0	; override readings with simulator values
	movff	sim_pressure+1,amb_pressure+1

	call	simulator_save_tissue_data		; Stores 32 floats "pre_tissue" into bank3

	WIN_INVERT	.1
	DISPLAYTEXT	.12							;" Wait.."
	WIN_INVERT	.0

	movlw	d'255'
	movff	WREG,char_O_deco_status			; Reset Deco module

simulator_calc_deco_loop1:

;	movlw	.011
;	call	PLED_SetColumn
;	movlw	.009
;	call	PLED_SetRow
;	lfsr	FSR2,letter
;	movff	char_O_array_decodepth+0,lo		; Get Depth
;	bsf		leftbind
;	output_8
;	bcf		leftbind
;	movlw	' '
;	movwf	POSTINC2
;call	word_processor	

	call	divemode_check_decogases			; Checks for decogases and sets the gases
	call	divemode_prepare_flags_for_deco

	call	deco_main_calc_hauptroutine		; calc_tissue
	movlb	b'00000001'						; rambank 1 selected

	movff	char_O_deco_status,deco_status		; 
	tstfsz	deco_status							; deco_status=0 if decompression calculation done
	bra		simulator_calc_deco_loop1			; Not finished

	movlw	d'1'
	movff	WREG,char_I_step_is_1min		; 1 minute mode
	movff	WREG,unused_x24B

	movlw	d'255'
	movff	WREG,char_O_deco_status			; Reset Deco module

	
simulator_calc_deco_loop2:
	call	PLED_simulator_data

	btg		LED_red

	call	divemode_check_decogases			; Checks for decogases and sets the gases
	call	divemode_prepare_flags_for_deco

	call	deco_main_calc_hauptroutine		; calc_tissue
	movlb	b'00000001'						; rambank 1 selected
	ostc_debug	'C'		; Sends debug-information to screen if debugmode active
	
	decfsz	logbook_temp1,F
	bra		simulator_calc_deco_loop2

	movlw	d'0'
	movff	WREG,char_I_step_is_1min		; 2 second deco mode
	movff	WREG,unused_x24B

	movlw	d'255'
	movff	WREG,char_O_deco_status			; Reset Deco module

	movff	char_O_deco_status,deco_status		; 
	tstfsz	deco_status							; deco_status=0 if decompression calculation done
	bra		simulator_calc_deco2				; Not finished

simulator_calc_deco3:
	bsf		LED_red
	
	call	simulator_restore_tissue_data	; Restore 32 floats "pre_tissue" from bank3

	bcf		simulatormode_active			; normal simulator mode
	bcf		standalone_simulator			; Standalone Simulator active

	WAITMS	d'250'
	WAITMS	d'250'
	WAITMS	d'250'							; Wait for Pressure Sensor to get real pressure again...

	bcf		LED_red
	
	movlw	d'1'
	movwf	logbook_temp1					; Bottom time>0!

	movlw	d'5'							; Pre-Set Cursor to "Show Decoplan"
	movwf	menupos

	bra		menu_simulator1					; Done.

simulator_calc_deco2:
	call	divemode_check_decogases			; Checks for decogases and sets the gases
	call	divemode_prepare_flags_for_deco

	call	deco_main_calc_hauptroutine		; calc_tissue
	movlb	b'00000001'						; rambank 1 selected

	movff	char_O_deco_status,deco_status		; 
	tstfsz	deco_status							; deco_status=0 if decompression calculation done
	bra		simulator_calc_deco2				; Not finished
	bra		simulator_calc_deco3				; finished!