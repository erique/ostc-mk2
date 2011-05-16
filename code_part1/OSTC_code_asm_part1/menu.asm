
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


; Main Menu and Setup menu
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 11/1/05
; last updated: 05/15/80
; known bugs:
; ToDo: 

wait_switches:
	bcf		switch_left
	bcf		switch_right
	return

menu:
	bcf		deco_mode_changed			; Clear flag (Description is only showed once)
	bcf		LED_blue
	movlw	d'1'
	movwf	menupos
menu2:

	bcf		leftbind
	call	PLED_ClearScreen
	clrf	timeout_counter2
	bcf		sleepmode
	bcf		menubit2
	bcf		menubit3
	bsf		menubit
	bsf		cursor
	call	PLED_menu_mask
	call	PLED_menu_cursor
	rcall	wait_switches

menu_loop:
	call	check_switches_menu

	btfsc	menubit2
	bra		do_menu						; call submenu

	btfss	menubit
	goto	restart						; exit menu, restart

	btfsc	onesecupdate
	call	timeout_surfmode

	btfsc	onesecupdate
	call	set_dive_modes

	btfsc	onesecupdate
	call	test_charger				; check if charger IC is active

	btfsc	onesecupdate
	call	get_battery_voltage			; get battery voltage

	bcf		onesecupdate				; End of one second tasks

	btfsc	sleepmode
	goto	restart

	btfsc	divemode
	goto	restart						; exit menu, restart and enter divemode

	bra		menu_loop	
		
check_switches_menu:                    ; checks switches
    btfsc	uart_dump_screen            ; Asked to dump screen contains ?
	call	dump_screen                 ; Yes!

	btfss	switch_right			
	bra		check_switches_menu2
	bsf		menubit3
	incf	menupos,F
	movlw	d'6'
	cpfsgt	menupos
	bra		refresh_cursor
	movlw	d'1'
	movwf	menupos
	bra		refresh_cursor
check_switches_menu2:
	btfsc	switch_left
	bsf		menubit2					; Enter!
	return


do_menu:								; calls submenu
	dcfsnz	menupos,F
	goto	menu_logbook
	dcfsnz	menupos,F
	goto	menu_gassetup
	dcfsnz	menupos,F
	goto	menu_reset
	dcfsnz	menupos,F
	goto	setup_menu
	dcfsnz	menupos,F
	goto	more_menu
	dcfsnz	menupos,F
	goto	restart						; exit...

refresh_cursor:
	clrf	timeout_counter2
	btfsc	cursor
	call	PLED_menu_cursor
	bcf		switch_right
	bcf		switch_left
	return

more_menu:
	movlw	d'1'
	movwf	menupos
more_menu2:
	bcf		leftbind
	call	PLED_ClearScreen
more_menu3:
	clrf	timeout_counter2
	bcf		sleepmode
	bcf		menubit2
	bcf		menubit3
	bsf		menubit
	bsf		cursor
	call	PLED_more_menu_mask
	call	PLED_menu_cursor
	bcf		switch_left
	bcf		switch_right
more_menu_loop:
	call	check_switches_menu

;	movlw	d'5'					; 5 items in "More Menu"
;	cpfseq	menupos
;	bra		more_menu_loop2
;	movlw	d'6'
;	movwf	menupos
;	call	PLED_menu_cursor
	
;more_menu_loop2:
	btfsc	menubit2
	bra	do_more_menu						; call submenu

	btfss	menubit
	bra		menu							; exit setup menu and return to main menu

	btfsc	onesecupdate
	call	timeout_surfmode

	btfsc	onesecupdate
	call	set_dive_modes

	btfsc	onesecupdate
	call	test_charger				; check if charger IC is active

	btfsc	onesecupdate
	call	get_battery_voltage			; get battery voltage

	bcf		onesecupdate				; End of one second tasks

	btfsc	sleepmode
	bra		menu

	btfsc	divemode
	goto	restart						; exit menu, restart and enter divemode

	bra		more_menu_loop	

do_more_menu:								; calls submenu
	dcfsnz	menupos,F
	goto	menu_settime
	dcfsnz	menupos,F
	goto	menu_const_ppO2
	dcfsnz	menupos,F
	goto	menu_battery_state
	dcfsnz	menupos,F
	goto	menu_simulator
	dcfsnz	menupos,F
	goto	altimeter_menu
	movlw	d'5'
	movwf	menupos
	bra		menu2						; exit...

setup_menu:
	bcf		deco_mode_changed			; Clear flag
	movlw	d'1'
	movwf	menupos
setup_menu2:
	bcf		leftbind
	call	PLED_ClearScreen
	call	PLED_setup_menu_mask
setup_menu3a:
	clrf	timeout_counter2
	bcf		sleepmode
	bcf		menubit2
	bcf		menubit3
	bsf		menubit
	bsf		cursor
	call	show_decotype
	call	show_salinity_value
	call	PLED_menu_cursor
	bcf		switch_left
	bcf		switch_right

setup_menu_loop:
	call	check_switches_menu

	btfsc	menubit2
	bra		do_setup_menu						; call submenu

	btfss	menubit
	goto	restart						; exit menu, restart and enter surfmode
	btfsc	onesecupdate
	call	timeout_surfmode
	btfsc	onesecupdate
	call	set_dive_modes
	btfsc	onesecupdate
	call	test_charger				; check if charger IC is active
	btfsc	onesecupdate
	call	get_battery_voltage			; get battery voltage

	bcf		onesecupdate				; End of one second tasks

	btfsc	sleepmode
	goto	restart						; exit menu, restart and enter surfmode

	btfsc	divemode
	goto	restart						; exit menu, restart and enter divemode

	bra		setup_menu_loop	


do_setup_menu:								; calls submenu
	dcfsnz	menupos,F
	goto	menu_custom_functions
	dcfsnz	menupos,F
	goto	menu_custom_functions_page2
	dcfsnz	menupos,F
	bra		toggle_salinity
	dcfsnz	menupos,F
	bra		toggle_decotype
	dcfsnz	menupos,F
	bra		more_setup_menu
	bra		exit_setup_menu						; exit...

toggle_decotype:
	bsf		deco_mode_changed			; Set flag
	read_int_eeprom d'34'		; Read deco data
	incf	EEDATA,F
	
toggle_decotype0:	
	movlw	d'6'						; number of different modes
	cpfseq	EEDATA
	bra		toggle_decotype1
	clrf	EEDATA

toggle_decotype1:
	call	write_eeprom			; save new mode
	movlw	d'4'
	movwf	menupos
	bcf		switch_right
	bra		setup_menu3a				; return to manu loop

show_decotype:
	read_int_eeprom d'34'		; Read deco data
	tstfsz	EEDATA
	bra		show_decotype2
	DISPLAYTEXT	.101			; ZH-L16 OC =0
	return
show_decotype2:
	decfsz	EEDATA,F
	bra		show_decotype3
	DISPLAYTEXT	.102			; Gauge	=1
	return
show_decotype3:
	decfsz	EEDATA,F
	bra		show_decotype4
	DISPLAYTEXT	.104			; ZH-L16 CC =2
	return
show_decotype4:
	decfsz	EEDATA,F
	bra		show_decotype5
	DISPLAYTEXT	.138			; Apnoe	=3
	return
show_decotype5:
	decfsz	EEDATA,F
	bra		show_decotype6
	DISPLAYTEXT	.152			; L16-GF OC	=4
	return
show_decotype6:
	decfsz	EEDATA,F
	return
	DISPLAYTEXT	.236			; L16-GF CC	=5
	return

exit_setup_menu:
	btfss	deco_mode_changed			; Was the decomode changed in Setup menu?
	goto	restart						; No, restart to surfacemode

	call	PLED_ClearScreen
	
deco_info_screen1:
	call	PLED_topline_box
	WIN_INVERT	.1	; Init new Wordprocessor	
	DISPLAYTEXT	.235			;Decomode changed!
	WIN_INVERT	.0	; Init new Wordprocessor	

	read_int_eeprom d'34'		; Read deco data

	movlw	d'7'						; length of description text
	mulwf	EEDATA						; Multiply with Decomode 0-5 (5=Spare)	
	
	movf	PRODL,W
	addlw	d'193'						; Description text offset
	movwf	menupos						; Used as loop counter temp
	
	movlw	d'7'
	movwf	temp1						; Loop 7 times

menu0:
	movf	menupos,W	
	call	displaytext_1_low           ; Display text!
	incf	menupos,F
	
	decfsz	temp1,F
	bra		menu0						; loop 7 times

	movlw	d'30'
	call	startup_screen3a
	goto	restart						; Restart to surfacemode

more_setup_menu:
	movlw	d'1'
	movwf	menupos
more_setup_menu2:
	bcf		leftbind
	call	PLED_ClearScreen
	call	PLED_more_setup_menu_mask
more_setup_menu3a:
	clrf	timeout_counter2
	bcf		sleepmode
	bcf		menubit2
	bcf		menubit3
	bsf		menubit
	bsf		cursor
	call	show_debugstate
	call	show_dateformat
	call	PLED_menu_cursor
	bcf		switch_left
	bcf		switch_right

more_setup_menu_loop:
	call	check_switches_menu

	movlw	d'5'				; x-1 menu entries
	cpfseq	menupos
	bra		more_setup_menu_loop2
	movlw	d'6'
	movwf	menupos
	call	PLED_menu_cursor
more_setup_menu_loop2:

	btfsc	menubit2
	bra		do_more_setup_menu						; call submenu

	btfss	menubit
	goto	restart						; exit menu, restart and enter surfmode

	btfsc	onesecupdate
	call	timeout_surfmode
	btfsc	onesecupdate
	call	set_dive_modes
	btfsc	onesecupdate
	call	test_charger				; check if charger IC is active
	btfsc	onesecupdate
	call	get_battery_voltage			; get battery voltage

	bcf		onesecupdate				; End of one second tasks

	btfsc	sleepmode
	goto	setup_menu					; exit menu

	btfsc	divemode
	goto	restart						; exit menu, restart and enter divemode

	bra		more_setup_menu_loop	

do_more_setup_menu:								; calls submenu
	dcfsnz	menupos,F
	bra		toggle_datemode
	dcfsnz	menupos,F
	bra		toggle_debugmode
	dcfsnz	menupos,F
	bra		show_license
	dcfsnz	menupos,F
	bra		show_rawdata
	dcfsnz	menupos,F
	bra		setup_menu						; spare
	movlw	d'5'					; set cursor to "More again"
	movwf	menupos
	bra		setup_menu2						; exit...

show_rawdata:						; Displays Sensor raw data
	call	PLED_ClearScreen
	call	PLED_topline_box
	WIN_INVERT	.1	; Init new Wordprocessor
	DISPLAYTEXTH	.296		; Raw Data:
	WIN_INVERT	.0	; Init new Wordprocessor

	call	PLED_static_raw_data

	clrf	timeout_counter2
	bcf		sleepmode
	bcf		menubit2
	bcf		menubit3
	bsf		menubit
	bcf		switch_left
	bcf		switch_right
show_rawdata_loop:
	btfsc	uart_dump_screen                ; Asked to dump screen contains ?
	call	dump_screen     			    ; Yes!

	btfsc	switch_left					; Ack?
	bsf		menubit2
	btfsc	switch_right				; Ack?
	bsf		menubit2

	btfsc	menubit2
	bra		show_rawdata_exit

	btfss	menubit
	goto	restart						; exit menu, restart and enter surfmode

	btfsc	onesecupdate
	call	timeout_surfmode

	btfsc	onesecupdate
	call	PLED_update_raw_data

	btfsc	onesecupdate
	call	set_dive_modes

	bcf		onesecupdate				; End of one second tasks

	btfsc	sleepmode
	bra		show_rawdata_exit			; Exit

	btfsc	divemode
	goto	restart						; exit menu, restart and enter divemode

	bra		show_rawdata_loop

show_rawdata_exit:	
	movlw	d'4'
	movwf	menupos
	bcf		switch_right
	bra		more_setup_menu2			; return to "more menu" loop

show_license:
	call	startup_screen1				;1/2
	call	startup_screen2				;1/2
	movlw	d'3'
	movwf	menupos
	bcf		switch_right
	bra		more_setup_menu2			; return to "more menu" loop

toggle_salinity:
; Toggles between 1.00 and 1.04
	read_int_eeprom	d'26'			; Read Salinity from EEPROM
	incf	EEDATA,F				; Increase value
	
	movlw	d'99'					; 99% ?
	cpfsgt	EEDATA					; Salinity lower limit
	bra		toggle_salinity_reset	; Out of limit, reset value to 1.00
	movlw	d'105'					; 105% ?
	cpfslt	EEDATA					; Salinity higher limit
	bra		toggle_salinity_reset	; Out of limit, reset value to 1.00

toggle_salinity2:
	write_int_eeprom	d'26'			; Store salinity
	movlw	d'3'
	movwf	menupos
	bcf		switch_right
	bra		setup_menu3a			; return to manu loop

toggle_salinity_reset:
	movlw	d'100'
	movwf	EEDATA
	bra		toggle_salinity2			; back

show_salinity_value:
	read_int_eeprom	d'26'			; Read Salinity from EEPROM
	movlw	d'99'					; 99% ?
	cpfsgt	EEDATA					; Salinity lower limit
	rcall	toggle_salinity_reset2	; Reset before display!
	movlw	d'105'					; 105% ?
	cpfslt	EEDATA					; Salinity higher limit
	rcall	toggle_salinity_reset2	; Reset before display!
	WIN_TOP		.95
	WIN_LEFT	.90                 ; +7 for spanish
	WIN_FONT 	FT_SMALL
	lfsr	FSR2,letter
	movff	EEDATA,lo
	clrf	hi
	bsf		leftbind
	output_16dp	d'3'
	bcf		leftbind
	STRCAT_PRINT "kg/l"
	return

toggle_salinity_reset2:
	movlw	d'100'
	movwf	EEDATA
	write_int_eeprom	d'26'			; Store salinity
	return
	
toggle_datemode:
; Toggles setting for 
; MM/DD/YY =0, Default
; DD/MM/YY =1
; YY/MM/DD =2
	read_int_eeprom	d'91'				; Read date format
	incf	EEDATA,F
	movlw	d'2'
	cpfsgt	EEDATA
	bra		toggle_datemode1
	clrf	EEDATA
toggle_datemode1:
	write_int_eeprom	d'91'			; Store date format
	movlw	d'1'
	movwf	menupos
	bcf		switch_right
	bra		more_setup_menu3a			; return to manu loop

show_dateformat:
	read_int_eeprom d'91'			; Read date format (0=MMDDYY, 1=DDMMYY, 2=YYMMDD)
	tstfsz	EEDATA
	bra		show_dateformat2
	DISPLAYTEXTH	.259			; MM/DD/YY = 0
	return
show_dateformat2:
	decfsz	EEDATA,F
	bra		show_dateformat3
	DISPLAYTEXTH	.260			; DD/MM/YY = 1
	return
show_dateformat3:
	DISPLAYTEXTH	.261			; YY/MM/DD = 2 
	return

toggle_debugmode:
	read_int_eeprom	d'39'				; Read status
	incf	EEDATA,F
	movlw	d'1'
	cpfsgt	EEDATA
	bra		toggle_debugmode1
	clrf	EEDATA
toggle_debugmode1:
	write_int_eeprom	d'39'			; Store status
	bsf		debug_mode					; set flag
	movlw	d'1'
	cpfseq	EEDATA
	bcf		debug_mode					; clear flag
	movlw	d'2'
	movwf	menupos
	bcf		switch_right
	bra		more_setup_menu3a			; return to manu loop

show_debugstate:
	read_int_eeprom	d'39'
	tstfsz	EEDATA
	bra		show_debugstate2
	DISPLAYTEXT	.131			; OFF
show_debugstate2:
	decf	EEDATA,F
	tstfsz	EEDATA
	bra		show_decotype3
	DISPLAYTEXT	.130			; ON
	return
