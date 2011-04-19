f
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


; routines for Surface mode
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 10/01/05
; last updated: 080905
; known bugs:
; ToDo:

surfloop:
; Boot tasks for all modes
	call	restart_set_modes_and_flags	; Sets decomode flags
	clrf	lo
	movff	lo,char_I_const_ppO2			; reset to standard mode, OSTC assumes Air breathing at the surface!

	call	PLED_brightness_full			;max. brightness
	
	call 	I2CReset
	call	enable_rs232
	call	PLED_boot
	call	PLED_serial						; Show OSTC serial and firmware version
	call	PLED_clock						; display time
	call	update_date						; display date
	movff	last_surfpressure_30min+0,int_I_pres_respiration+0		; copy surface air pressure to deco routine
	movff	last_surfpressure_30min+1,int_I_pres_respiration+1		; 30min old values 
	movff	last_surfpressure_30min+0,int_I_pres_surface+0			; copy surface air pressure to deco routine
	movff	last_surfpressure_30min+1,int_I_pres_surface+1			; 30min old values 

	clrf	menupos3					; Reset Custom views (Default: No custom view)

	btfsc	gauge_mode					; Ignore in gauge mode
	bra		surfloop1
	btfsc	FLAG_apnoe_mode				; Ignore in Apnoe mode
	bra		surfloop1

; Startup tasks for decompression modes
	call	PLED_display_cns_surface		; Update surface CNS display (If allowed by CF15)
	call	PLED_desaturation_time			; display desaturation time
	call	PLED_nofly_time					; display nofly time

	call	PLED_active_gas_surfmode		; Show start gas
	call	PLED_display_decotype_surface	; Show deco mode (ZH-L16, const. ppO2 or Multi-GF)

surfloop1:
	btfss	gauge_mode					; Display only in gauge mode	
	bra		surfloop2
	DISPLAYTEXT	d'103'					; Gauge mode
surfloop2:
	btfss	FLAG_apnoe_mode				; Display only in Apnoe mode
	bra		surfloop3
	DISPLAYTEXT	d'116'					; Apnoe mode

surfloop3:
; Startup tasks for all modes
	clrf	timeout_counter2				
	clrf 	timeout_counter3
	bcf		premenu						; clear premenu flag
	bcf		menubit						; clear menu flag
	bcf		pressure_refresh
	clrf	last_pressure+0
	clrf	last_pressure+1
	clrf	last_temperature+0
	clrf	last_temperature+1

	movlw	d'5'
	movwf	timeout_counter			; reload counter

	bcf		LED_blue
	bcf		LED_red
	bcf		simulatormode_active		; Quit simulator mode (if active)
	bcf		standalone_simulator		; Quit simulator mode (if active)
	WIN_TOP		.0
	WIN_LEFT	.0
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	call	PLED_standard_color

	bcf		switch_left
	bcf		switch_right
	call	PLED_active_gas_surfmode	; Show start gas / SetPoint
	call	PLED_custom_text			; Displays custom text
	clrf	cf_checker_counter			; next cf to check
	ostc_debug	'G'						; Sends debug-information to screen if debugmode active

    ; Desaturation time needs:
    ;   int_I_pres_surface
    ;   char_I_desaturation_multiplier
	GETCUSTOM8	d'12'					; Desaturation multiplier %
	movff	WREG,char_I_desaturation_multiplier

	call	deco_calc_desaturation_time ; calculate desaturation time
	movlb	b'00000001'					; select ram bank 1
	ostc_debug	'H'						; Sends debug-information to screen if debugmode active

	call	wait_switches		; Waits until switches are released, resets flag if button stays pressed!

surfloop_loop:
	btfss	onesecupdate				; do every second tasks?
	bra		surfloop_loop2				; no, loop

	btfss	FLAG_const_ppO2_mode		; are we in const. ppO2 mode?	
	bra		surfloop_loop1				; No
; One Second tasks for ppO2 modes

	bra		surfloop_loop1				; Do not search for sensor in CC mode

surfloop_loop1:
; One Second tasks for all modes
	call	PLED_clock					; update clock
	call	test_charger				; check if charger IC is active
	call	timeout_surfmode			; check timeout 
	call	get_battery_voltage			; get battery voltage
	call	update_batt_voltage			; display battery voltage
	call	timeout_premenu				; timeout premenu
	call	set_leds_surfmode			; Sets Warning and No-Fly LEDs
	call    check_customfunctions       ; Checks CF functions and displays warning symbol if something critical is wrong
	call	PLED_display_decotype_surface	; Show deco mode
	call	surfcustomview_second		; Do every-second tasks for the custom view area
	call    dive_type_icons             ; Draw Air/Nitrox/Trimix color icon.
	btfsc	enter_error_sleep			; Enter Fatal Error Routine?
	call	fatal_error_sleep			; Yes (In Sleepmode.asm!)
	bcf		onesecupdate				; every second tasks done
	
surfloop_loop2:	
; Tasks approx. every 50ms for all modes
	call	test_switches_surfmode		; check switches

; Sensor tasks for all modes
	btfsc	pressure_refresh			; new pressure available?
	call	update_surf_press			; display surface pressure
	btfsc	pressure_refresh			; new temperature available?
	call	PLED_temp_surfmode			; Displays temperature
	btfsc	pressure_refresh			; new pressure available?
	call	set_dive_modes				; tests if depth>threshold
	
	; jDG TESTS =========================
	btfss	pressure_refresh			; new pressure available?
	bra     surfloop_loop3
	call    altimeter_calc
    movf    menupos3,W                  ; Get customview status.
    bnz     surfloop_loop3              ; Already used ?
    call    altimeter_display
surfloop_loop3:
	; jDG TESTS =========================

	bcf		pressure_refresh			; until new pressure is available

; One minute tasks for all modes
	btfsc	oneminupdate				; do every minute tasks
	call	update_surfloop60			; yes, e.g. update time and date

; Mode tasks
	btfsc	menubit						; Menu?
	goto	menu						; Menu!
	btfsc	divemode					; Divemode active?
	goto	diveloop					; Yes, switch into Divemode!
	btfsc	sleepmode					; Sleepmode active?
	goto	sleeploop					; Yes, switch into sleepmode!

	btfsc	toggle_customview			; Next view?
	call	surfcustomview_toggle		; Yes, show next customview (and delete this flag)

; Check for the different UART flags
	btfsc	dump_external_eeprom		; Start interface (dumps EEPROM BANK 0 + additional data)?
	goto	menu_interface				; Yes!
	btfsc	uart_settime				; Sync clock with PC?
	goto	sync_clock					; Yes!
	btfsc	internal_eeprom_write		; Access internal EEPROM BANK 0 via UART module
	goto	internal_eeprom_access_b0	; Yes!
	btfsc	internal_eeprom_write2		; Access internal EEPROM BANK 1 via UART module
	goto	internal_eeprom_access_b1	; Yes!
	btfsc	uart_send_hash				; Send MD2 hash values
	goto	send_md2_hash				; Yes!
	btfsc	uart_send_int_eeprom		; Send internal EEPROM BANK 0
	goto	send_int_eeprom_b0			; Yes!
	btfsc	uart_reset_decodata			; Reset Deco Data?
	goto	reset_decodata				; Yes!
	btfsc	uart_send_int_eeprom2		; Send internal EEPROM BANK 1
	goto	send_int_eeprom_b1			; Yes!
	btfsc	uart_store_tissue_data		; Store tissue data?
	goto	uart_store_tissues			; Yes!
	btfsc	uart_115200_bootloader		; Look for 115200Baud bootloader?
	goto	uart_115k_bootloader		; Yes!

	bra		surfloop_loop				; loop surfacemode


update_surfloop60:
; One minute tasks for all modes
;	call	PLED_active_gas_surfmode	; Show start gas / SetPoint
	call	update_date					; and date in divemode
	call	calc_deko_surfmode			; calculate desaturation every minute
	call	check_temp_extrema			; check for new temperature extremas
	call	PLED_custom_text			; Displays custom text
	call	calc_surface_interval		; Increases Surface-Interval time
	call	surfcustomview_minute		; Do every-minute tasks for the custom view area

	btfsc	gauge_mode					; Ignore in gauge mode
	bra		update_surfloop60_2
	btfsc	FLAG_apnoe_mode				; Ignore in Apnoe mode
	bra		update_surfloop60_2

; One Minute tasks for deco modes
	call	PLED_display_cns_surface	; Update surface CNS display (If allowed by CF15)
	call	PLED_nofly_time				; display nofly time
	call	PLED_desaturation_time		; display desaturation time
	btfsc	premenu						; Not when "Menu?" is displayed!
	bra		update_surfloop60_2

update_surfloop60_2:
	call	nofly_timeout60				; checks if nofly time is > 0
	bcf		oneminupdate				
	return

nofly_timeout60:
    movf    nofly_time+0,W              ; Is nofly null ?
    iorwf   nofly_time+1,W
    bnz     nofly_timeout60_1           ; No...
    
	bcf		nofly_active                ; Clear flag
	bcf		LED_blue                    ; Clear led.
	return

nofly_timeout60_1:
	bsf		nofly_active                ; Set flag
	movlw	d'1'
	subwf	nofly_time+0,F
	movlw	d'0'
	subwfb	nofly_time+1,F              ; reduce by one
	return

calc_surface_interval:
	movff		int_O_desaturation_time+0,lo			; divide by 60...
	movff		int_O_desaturation_time+1,hi
	tstfsz		lo							;=0?
	bra			calc_surface_interval2		; No
	tstfsz		hi							;=0?
	bra			calc_surface_interval2		; No
	clrf		surface_interval+0
	clrf		surface_interval+1			; Clear surface interval timer
	return

calc_surface_interval2:						; Increase surface interval timer 
	movlw		d'1'
	addwf		surface_interval+0,F
	movlw		d'0'
	addwfc		surface_interval+1,F
	return

set_leds_surfmode:	
	btfsc	nofly_active
	btg		LED_blue
	return	

calc_deko_surfmode:
	ostc_debug	'I'		; Sends debug-information to screen if debugmode active

	movff	last_surfpressure+0,int_I_pres_surface+0	; copy surface air pressure to deco routine
	movff	last_surfpressure+1,int_I_pres_surface+1		
	clrf	wait_temp						; Use as buffer
	movff	wait_temp,char_I_He_ratio		; No He at the Surface
	movlw	d'79'							; 79% N2
	movwf	wait_temp						; Use as buffer
	movff	wait_temp,char_I_N2_ratio		; No He at the Surface

	movff	amb_pressure+0,int_I_pres_respiration+0		; copy surface air pressure to deco routine
	movff	amb_pressure+1,int_I_pres_respiration+1		
	GETCUSTOM8	d'11'									; Saturation multiplier %
	movff	WREG,char_I_saturation_multiplier
	GETCUSTOM8	d'12'									; Desaturation multiplier %
	movff	WREG,char_I_desaturation_multiplier

	call	deco_calc_wo_deco_step_1_min    ; calculate deco in surface mode 
	movlb	b'00000001'									; select ram bank 1
	ostc_debug	'J'		; Sends debug-information to screen if debugmode active

    movff	int_O_desaturation_time+0,desaturation_time_buffer+0
    movff	int_O_desaturation_time+1,desaturation_time_buffer+1

	return


test_charger:
	bcf		TRISC,1						; CHRG_OUT output
	bsf		CHRG_OUT
	
	bcf		cc_active					; Constant Current mode active?
	btfss	CHRG_IN						; If CHRG_IN=0 -> CC active
	bsf		cc_active					; Constant Current mode Active!
	
	bcf		CHRG_OUT		
	bsf		TRISC,1						; CHRG_OUT high impedance
	
	WAIT10US	d'10'
	
	bcf		cv_active					; Constant Voltage mode Active?
	btfss	CHRG_IN						; If CHRG_IN=0 -> CV active
	bsf		cv_active					; Constant Voltage mode active!

	bcf		TRISC,1						; CHRG_OUT output
	bcf		CHRG_OUT		

	btfsc	cc_active
	bra		show_cc_active
	btfsc	cv_active
	bra		show_cv_active

	bsf		TRISC,1						; CHRG_OUT high impedance

	; Charger inactive or ready
	btfss	charge_done					; charge done?
	bra		test_charger2				; No, add incomplete cycle!
	
	; Yes, store all data for complete cycle
	bcf		charge_started				; Clear flag
	bcf		charge_done					; Clear flag
	; Store incomplete/total cycles
	read_int_eeprom 	d'50'		; Read byte (stored in EEDATA)
	movff	EEDATA,temp1				; Low byte
	read_int_eeprom 	d'51'		; Read byte (stored in EEDATA)
	movff	EEDATA,temp2				; high byte
	bcf		STATUS,C
	movlw	d'1'
	addwf	temp1
	movlw	d'0'
	addwfc	temp2				
	movff	temp1,EEDATA
	write_int_eeprom	d'50'			; write byte stored in EEDATA
	movff	temp2,EEDATA
	write_int_eeprom	d'51'			; write byte stored in EEDATA

	; Store complete cycles
	read_int_eeprom 	d'52'		; Read byte (stored in EEDATA)
	movff	EEDATA,temp1				; Low byte
	read_int_eeprom 	d'53'		; Read byte (stored in EEDATA)
	movff	EEDATA,temp2				; high byte
	bcf		STATUS,C
	movlw	d'1'
	addwf	temp1
	movlw	d'0'
	addwfc	temp2				
	movff	temp1,EEDATA
	write_int_eeprom	d'52'			; write byte stored in EEDATA
	movff	temp2,EEDATA
	write_int_eeprom	d'53'			; write byte stored in EEDATA
	; Store date of complete cycle
	movff	month,EEDATA
	write_int_eeprom	d'47'
	movff	day,EEDATA
	write_int_eeprom	d'48'
	movff	year,EEDATA
	write_int_eeprom	d'49'

	return

test_charger2:
	btfss	charge_started				; Did the charger ever start?
	return								; No, quit!

	bcf		charge_started				; Clear flag
	; Store incomplete/total cycles
	read_int_eeprom 	d'50'			; Read byte (stored in EEDATA)
	movff	EEDATA,temp1				; Low byte
	read_int_eeprom 	d'51'			; Read byte (stored in EEDATA)
	movff	EEDATA,temp2				; high byte
	bcf		STATUS,C
	movlw	d'1'
	addwf	temp1
	movlw	d'0'
	addwfc	temp2				
	movff	temp1,EEDATA
	write_int_eeprom	d'50'			; write byte stored in EEDATA
	movff	temp2,EEDATA
	write_int_eeprom	d'51'			; write byte stored in EEDATA
	return	

show_cv_active:							; CV mode
	bsf		LED_red
	WAITMS	d'100'
	bcf		LED_red
	WAITMS	d'100'
	bsf		LED_red
	bsf		charge_done					; Charge cycle finished
	return

show_cc_active:							; CC mode
	bsf		LED_red
	bsf		charge_started				; Charger started in CC mode
	bcf		charge_done					; Charge cycle not finished
	return

	
timeout_premenu:
	btfss	premenu					; is "Menu?" displayed?
	return							; No
	incf	timeout_counter3,F		; Yes...
	GETCUSTOM8	d'4'				; loads premenu_timeout into WREG
	cpfsgt	timeout_counter3		; ... longer then premenu_timeout
	return							; No!
	bcf		premenu					; Yes, so clear "Menu?" and clear pre_menu bit

	call	PLED_topline_box_clear	; Clears Bar at the top

	btfsc	gauge_mode
	bra		timeout_premenu2		; Skip in Gauge mode
	btfsc	FLAG_apnoe_mode
	bra		timeout_premenu2		; Skip in Apnoe mode

timeout_premenu2:
	call	update_surf_press		; rewrite serial number
	call	PLED_serial				; rewrite serial number
	clrf	timeout_counter3		; Also clear timeout
	bcf		switch_left				; and debounce switches
	bcf		switch_right
	return

test_switches_surfmode:		; checks switches in surfacemode
	btfsc	switch_left
	bra		test_switches_surfmode2
	btfsc	switch_right
	bra		test_switches_surfmode3		
	
	; No button press, reset timer0
	bcf		T0CON,TMR0ON				; Stop Timer 0
	bcf		INTCON,TMR0IF				; Clear flag
	clrf	TMR0H
	clrf	TMR0L
	bcf		INTCON,INT0IF				; Clear flag
	bcf		INTCON3,INT1IF				; Clear flag
	return

test_switches_surfmode3:
	bcf		switch_right
	call	PLED_topline_box		; Write a filled bar at the top
	WIN_INVERT	.1					; Init new Wordprocessor
	DISPLAYTEXT	.4			;Menu?
	WIN_INVERT	.0					; Init new Wordprocessor
	bsf		premenu
	clrf	timeout_counter2
	return

test_switches_surfmode2:
	bcf		switch_left
	btfss	premenu
	bra		test_switches_surfmode4
	bsf		menubit					; Enter Menu!
	return

test_switches_surfmode4:
	bsf		toggle_customview	; Toggle customview (Cleared in customview.asm)
	return

timeout_surfmode:
	incf	timeout_counter2,F		; increase timeout counter
	GETCUSTOM8	d'3'				; loads surfloop_timeout into WREG
	addlw	d'5'					; adds five seconds in case timout=zero!
	btfsc	STATUS,C				; > 255?
	movlw	d'255'					; Set to 255...
	decf	WREG,F					; Limit to 254	
	cpfsgt	timeout_counter2		; Compare with timeout_counter2
	return							; return, no timeout
	bsf		sleepmode				; Set Flag
	return							; Return
