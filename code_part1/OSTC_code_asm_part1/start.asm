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


; Start and init
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 10/13/04
; last updated: 06/24/08
; known bugs:
; ToDo: 

start:
	movlb	b'00000001'				; ram bank 1 selected
	call	init
	btfsc	divemode				; Reset from Divemode?
	call	PLED_resetdebugger		; Yes! Something went wrong, show reset informations

	clrf	STKPTR					; Clear Stackpointer
	lfsr	FSR0, 109h				; Clear rambank 1-9, do not delete RTC registers
clear_rambank:
	clrf	POSTINC0
	movlw	0x0A
	cpfseq	FSR0H					; Bank 9 done?
	bra		clear_rambank			; clear...

; Defaults for RTC
	call	disable_rs232			; disable UART module
	call	RTCinit					; reset RTC

; Air pressure compensation	after reset
	call	get_calibration_data	; Get calibration data from pressure sensor

	bcf		pressure_refresh
wait_start_pressure:
	btfss	pressure_refresh 		; Air pressure compensation
	bra		wait_start_pressure

	clrf	rel_pressure+0
	clrf	rel_pressure+1
	clrf	surface_interval+0
	clrf	surface_interval+1

	bsf		sleepmode				; Routine only works in sleepmode...
	call	pressuretest_sleep_fast	; Gets pressure without averaging (faster!)
	bcf		sleepmode				; Normal mode again
	
	movff	amb_pressure+0,last_surfpressure+0
	movff	amb_pressure+1,last_surfpressure+1
	movff	amb_pressure+0,last_surfpressure_15min+0
	movff	amb_pressure+1,last_surfpressure_15min+1
	movff	amb_pressure+0,last_surfpressure_30min+0
	movff	amb_pressure+1,last_surfpressure_30min+1	; Rests all airpressure registers

; reset deco data
	incf	nofly_time+0,F					; =1
	clrf	wait_temp						; Use as buffer
	movff	wait_temp,char_I_He_ratio		; No He at the Surface
	movlw	d'79'							; 79% N2
	movwf	wait_temp						; Use as buffer
	movff	wait_temp,char_I_N2_ratio		; No He at the Surface
	movff	amb_pressure+0,int_I_pres_respiration+0		; copy surface air pressure to deco routine
	movff	amb_pressure+1,int_I_pres_respiration+1		

	movlw	d'0'
	movff	WREG,char_I_step_is_1min		; 2 second deco mode
	call	deco_main_clear_tissue			;
	movlb	b'00000001'						; select ram bank 1
	call	deco_main_calc_desaturation_time; calculate desaturation time
	movlb	b'00000001'						; select ram bank 1
	call	main_clear_CNS_fraction			; clear CNS
	movlb	b'00000001'						; select ram bank 1
	call	calc_deko_surfmode				; calculate desaturation every minute
	movlb	b'00000001'						; select ram bank 1
	call	deco_main_calc_wo_deco_step_1_m				; calculate deco in surface mode 
	movlb	b'00000001'									; select ram bank 1

; check firmware and reset Custom Functions after an update
	movlw	LOW		0x101
	movwf	EEADR
	movlw	HIGH 	0x101
	movwf	EEADRH
	call	read_eeprom				; read current version x
	movff	EEDATA,temp1
	incf	EEADR,F					; set to 0x102
	call	read_eeprom				; read current version y
	movff	EEDATA,temp2
	clrf	EEADRH					; Reset EEADRH
	
	movlw	softwareversion_x
	cpfseq	temp1					; compare version x
	bra		check_firmware_new		; is not equal -> reset CF and store new version in EEPROM

	movlw	softwareversion_y
	cpfseq	temp2					; compare version y
	bra		check_firmware_new		; is not equal -> reset CF and store new version in EEPROM
	bra		restart					; x and y are equal -> do not reset cf
			
check_firmware_new:
	movlw	LOW		0x101			; store current version in EEPROM
	movwf	EEADR
	movlw	HIGH 	0x101
	movwf	EEADRH
	movlw	softwareversion_x
	movwf	EEDATA		
	call	write_eeprom			; write version x
	incf	EEADR,F					; set to 0x102
	movlw	softwareversion_y
	movwf	EEDATA		
	call	write_eeprom			; write version y
	clrf	EEADRH					; Reset EEADRH
;	goto	reset_all_cf			; resets all custom functions bank0 and bank1 and jumps to "restart"
	goto	reset_all_cf_bank1		; resets all custom functions bank1 and jumps to "restart"
			
restart:
	bcf		LED_red
	bcf		LED_blue				; all LEDs off

	clrf	flag1					; clear all flags
	clrf	flag2
	clrf	flag3
	clrf	flag4
	clrf	flag5
	clrf	flag6
	clrf	flag7
	clrf	flag8
	clrf	flag9
	clrf	flag10
	clrf	flag11
	clrf	flag12
	clrf	flag13
	clrf	flag14
	clrf	flag15

	call	PLED_boot				; PLED boot (Incl. Clear Screen!)
	WIN_TOP		.0
	WIN_LEFT	.0
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	movlw	0xFF
	movwf	oled1_temp
	movff	oled1_temp,win_color1
	movlw	0xFF
	movwf	oled1_temp
	movff	oled1_temp,win_color2
	call	I2CReset				; Just in Case any I2C device blocks the Bus
	movff	last_surfpressure_30min+0,last_surfpressure+0		; Use 30min old airpressure 
	movff	last_surfpressure_30min+1,last_surfpressure+1		; Use 30min old airpressure

; Check if new CF were added in the last firmware version
	clrf	EEADRH
	read_int_eeprom	d'92'			; Read number of CF used in this firmware	
	movlw	max_custom_number		; Defined in definitions.asm
	cpfseq	EEDATA					; Compare with last version
	bra		restart_01				; New CF, show warning and store new number
	bra		restart_1				; No new CF, continue with boot
restart_01:
; Save new number of current CF count
	rcall	display_new_cf_installed; Show warning
	movlw	max_custom_number		; Defined in definitions.asm
	movwf	EEDATA
	write_int_eeprom	d'92'		; Store number of CF used in this firmware

restart_1:
;	btfss	pressure_refresh 		; Wait for pressure sensor...
;	bra		restart_1				; loop until pressure and temp stable
;

; Set Debug mode?
	read_int_eeprom	d'39'
	bsf		debug_mode			
	movlw	d'1'
	cpfseq	EEDATA
	bcf		debug_mode				; clear flag if <> 1

	goto	surfloop				; Jump to Surfaceloop!
	

display_new_cf_installed:
	call	PLED_new_cf_warning		; Display new CF warning screen
	movlw	d'20'					; timeout for warning screen
	bra		startup_screen3a		; Will RETURN after timeout or button press
	
restart_set_modes_and_flags:		; "Call"ed from divemode, as well!
	bcf		gauge_mode
	bcf		FLAG_const_ppO2_mode
	bcf		FLAG_apnoe_mode			
	clrf	EEADRH
	read_int_eeprom d'34'			; Read deco data	
	movlw	d'1'					; Gauge mode
	cpfseq	EEDATA
	 bra	restart_3_test_ppO2_mode; check for ppO2 mode
	bsf		gauge_mode				; Set flag for gauge mode
	movlw	d'0'
	movwf	wait_temp
	movff	wait_temp,char_I_deco_model	; Clear Flagbyte 
	return							; start in Surfacemode
restart_3_test_ppO2_mode:
	movlw	d'2'					; const ppO2 mode
	cpfseq	EEDATA
	 bra	restart_3_test_apnoe_mode; check for apnoe mode
	bsf		FLAG_const_ppO2_mode	; Set flag for ppO2 mode
	movlw	d'0'
	movwf	wait_temp
	movff	wait_temp,char_I_deco_model	; Clear Flagbyte 
	return							; start in Surfacemode
restart_3_test_apnoe_mode:
	movlw	d'3'					; Apnoe mode
	cpfseq	EEDATA
	 bra	restart_4_test_gf_mode	; check for GF OC mode
	bsf		FLAG_apnoe_mode			; Set flag for Apnoe Mode
	movlw	d'0'
	movwf	wait_temp
	movff	wait_temp,char_I_deco_model	; Clear Flagbyte 
	return							; start in Surfacemode
restart_4_test_gf_mode:
	movlw	d'4'					; GF OC mode
	cpfseq	EEDATA
	bra		restart_5_test_gfO2_mode; check for GF CC mode
	movlw	d'1'
	movwf	wait_temp
	movff	wait_temp,char_I_deco_model	; Set Flagbyte for GF method
	return							; start in Surfacemode
restart_5_test_gfO2_mode:
	movlw	d'5'					; GF CC mode
	cpfseq	EEDATA
	return							; Start in Surfacemode
	bsf		FLAG_const_ppO2_mode	; Set flag for ppO2 mode
	movlw	d'1'
	movwf	wait_temp
	movff	wait_temp,char_I_deco_model	; Set Flagbyte for GF method
	return							; start in Surfacemode

startup_screen1:
	call	PLED_ClearScreen		
	call	PLED_startupscreen1		; show startup sreen
startup_screen1_2:
	movlw	d'10'					; timeout for startup screen
	movwf	temp1			
	WAITMS	d'200'
	bcf		switch_left
	bcf		switch_right
screen1_loop:
	btfsc	onesecupdate				; do every second tasks?
	call	set_dive_modes				; tests if depth>threshold
	btfsc	onesecupdate				; do every second tasks?
	decf	temp1,F
	bcf		onesecupdate				; every second tasks done

	tstfsz	temp1						; timout occured?
	bra		screen1_loop2				; no
	return

screen1_loop2:
	btfsc	divemode					; Divemode active?
	return
	btfsc	switch_left					; Ack?
	return
	btfsc	switch_right				; Ack?
	return
	bra		screen1_loop				; loop screen

startup_screen2:
	call	PLED_ClearScreen		; Page 1
	call	PLED_startupscreen2		; show startup sreen
	bra		startup_screen1_2

startup_screen3a:; WARNING: Also used for decodescriptions and CF Warning screen!
	movwf	temp1			
	WAITMS	d'200'
	bcf		switch_left
	bcf		switch_right
screen3_loop:
	btfsc	onesecupdate				; do every second tasks?
	call	set_dive_modes				; tests if depth>threshold
	
	btfsc	onesecupdate				; do every second tasks?
	decf	temp1,F
	bcf		onesecupdate				; every second tasks done

	tstfsz	temp1						; timout occured?
	bra		screen3_loop2				; no
	return
screen3_loop2:
	btfsc	switch_left					; Ack?
	return
	btfsc	switch_right				; Ack?
	return
	bra		screen3_loop				; loop screen

init:						
	movlw	b'01101100'		; 4MHz (x4 PLL)
	movwf	OSCCON

	movlw	b'00010001'		; I/O Ports
	movwf	TRISA
	clrf	PORTA
	movlw	b'00000011'
	movwf	TRISB
	clrf	PORTB
	movlw	b'11011101'		; UART
	movwf	TRISC
	clrf	PORTC
	movlw	b'00000000'
	movwf	TRISE
	clrf	PORTE
	movlw	b'00000000'
	movwf	TRISD
	clrf	PORTD

	movlw	b'01000000'		; Bit6: PPL enable
	movwf	OSCTUNE

	movlw	b'00011111'		; Timer0
	movwf	T0CON

	movlw	b'00000111'		; Timer1
	movwf	T1CON

	movlw	b'11010000'		; Interrups
	movwf	INTCON
	movlw	b'00000101'
	movwf	INTCON2
	movlw	b'00001000'
	movwf	INTCON3
	movlw	b'00100001'
	movwf	PIE1
	movlw	b'00000000'
	movwf	PIE2
	clrf	RCON

	movlw	b'00000000'		; A/D Converter
	movwf	ADCON0
	movlw	b'00001110'
	movwf	ADCON1
	movlw	b'10001010'		; Right justified
	movwf	ADCON2

	clrf	SSPCON1			; Set I�C Mode
	movlw	b'00000000'
	movwf	SSPSTAT
	movlw	b'00101000'
	movwf	SSPCON1
	movlw	b'00000000'
	movwf	SSPCON2
	movlw	d'8'			; 400kHz I2C clock @ 16MHz Fcy
	movwf	SSPADD

	clrf	CCP1CON			; PWM Module off
	clrf	ECCP1CON		; PWM Module off

	movlw	b'00000111'		; Comperator Module off
	movwf	CMCON
	
	movlw	b'00100000'
	movwf	CANCON			; ECAN Module OFF

	movlw	b'00100100'		; UART
	movwf	TXSTA
	movlw	b'10010000'
	movwf	RCSTA
	movlw	b'00001000'
	movwf	BAUDCON
	clrf	SPBRGH
	movlw	d'34'
	movwf	SPBRG
	clrf	RCREG
	clrf	PIR1
	return
