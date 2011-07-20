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
	movff	STKPTR,temp10
	clrf    temp10+1
	call	init
	btfsc	divemode				; Reset from Divemode?
	call	PLED_resetdebugger		; Yes! Something went wrong, show reset informations
start3:
	clrf	STKPTR					; Clear Stackpointer
	lfsr	FSR0,year+1				; Clear rambank 1-9, do not delete RTC registers
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
    SAFE_2BYTE_COPY amb_pressure_avg, amb_pressure	; copy for compatibility

    SAFE_2BYTE_COPY amb_pressure_avg, last_surfpressure
	SAFE_2BYTE_COPY amb_pressure_avg, amb_pressure
	movff	last_surfpressure+0,last_surfpressure_15min+0
	movff	last_surfpressure+1,last_surfpressure_15min+1
	movff	last_surfpressure+0,last_surfpressure_30min+0
	movff	last_surfpressure+1,last_surfpressure_30min+1	; Rests all airpressure registers

; Extra power-up reset (JeanDo)
	ifdef	TESTING
		call 	do_menu_reset_all2
	endif

; reset deco data
	ostc_debug	'0'		; Sends debug-information to screen if debugmode active

	movlw	d'79'							; 79% N2
	movff	WREG,char_I_N2_ratio            ; No He at the Surface
	clrf	WREG                            ; Use as buffer
	movff	WREG,char_I_He_ratio            ; No He at the Surface
	movff	WREG,char_I_step_is_1min		; 2 second deco mode
	GETCUSTOM8	d'11'					    ; Saturation multiplier %
	movff	WREG,char_I_saturation_multiplier
	GETCUSTOM8	d'12'					    ; Desaturation multiplier %
	movff	WREG,char_I_desaturation_multiplier
    SAFE_2BYTE_COPY amb_pressure,int_I_pres_respiration ; copy for deco routine
	movff	int_I_pres_respiration+0,int_I_pres_surface+0     ; copy for desat routine
	movff	int_I_pres_respiration+1,int_I_pres_surface+1		

	call	deco_clear_tissue			    ;
	call	deco_calc_desaturation_time     ; calculate desaturation time
	call	deco_clear_CNS_fraction			; clear CNS
	call	calc_deko_surfmode				; calculate desaturation every minute
	call	deco_calc_wo_deco_step_1_min	; calculate deco in surface mode 
	movlb	b'00000001'									; select ram bank 1
  	clrf	nofly_time+0	              	; Reset NoFly
  	clrf	nofly_time+1    	          	; Reset NoFly
	bcf		nofly_active                	; Clear flag

; check firmware and reset Custom Functions after an update
	movlw	d'1'
	movwf	EEADR
	movlw	d'1'
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
	movlw	d'1'					; store current version in EEPROM
	movwf	EEADR
	movlw	d'1'
	movwf	EEADRH
	movlw	softwareversion_x
	movwf	EEDATA		
	call	write_eeprom			; write version x
	incf	EEADR,F					; set to 0x102
	movlw	softwareversion_y
	movwf	EEDATA		
	call	write_eeprom			; write version y
	clrf	EEADRH					; Reset EEADRH

; Reset CF48
	movlw	d'1'
	movwf	EEADRH					; EEPROM Bank1
	clrf	EEDATA					; =0
	write_int_eeprom	d'191'
	write_int_eeprom	d'192'	
	write_int_eeprom	d'193'
	write_int_eeprom	d'194'		; Reset Default and Current Value to zero
	clrf	EEADRH
;	goto	reset_all_cf			; resets all custom functions bank0 and bank1 and jumps to "restart"
			
restart:
	movlw	b'00000011'
	movwf	T3CON					; Timer3 with 32768Hz clock running
	clrf	TMR3L
	clrf	TMR3H
	bcf		LED_red
	bcf		LED_blue				; all LEDs off
	GETCUSTOM8	d'48'				; time correction value
	movff	WREG, time_correction_value	; store in Bank0 register

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

    ; Should we set win_flip_screen ?
	bsf		flag1,0                 ; Precondition to yes
	clrf	EEADRH					; Reset EEADRH
	read_int_eeprom	d'1'
	movlw	.7
	cpfsgt	EEDATA					; serial > 2048 (Mk2n hardware) ?
	bcf		flag1,0
	incf    EEDATA,W                ; serial == 65535 (emulation) ?
	btfsc   STATUS,Z
	bcf     flag1,0
	movff	flag1,win_flags			; store in Bank0 register
	clrf	flag1					; Clear flag1 (again)

	; Select high altitude (Fly) mode?
	movff	last_surfpressure_30min+0,sub_b+0
	movff	last_surfpressure_30min+1,sub_b+1
	movlw	HIGH	d'880'
	movwf	sub_a+1
	movlw	LOW		d'880'			; Hard-wired 880mBar
	movwf	sub_a+0
	call	sub16					; sub_c = sub_a - sub_b
	btfss	neg_flag				; Result negative (Ambient>880mBar)?
	bsf		high_altitude_mode		; No, Set Flag!
	
	; Should we disable sleep (hardware emulator)
restart_loop:
	btfss	0xF81,0,A
	bra		restart_loop
	btfss	0xF81,1,A
	bra		restart_loop
	movlw	0x80
	cpfslt	0xFB3,A
	bsf		nsm						; NO-SLEEP-MODE : for hardware debugging

	call	gassetup_sort_gaslist       ; Sorts Gaslist according to change depth
	WIN_TOP		.0
	WIN_LEFT	.0
	WIN_FONT 	FT_SMALL
	WIN_INVERT	.0					; Init new Wordprocessor
	setf	WREG
	movff	WREG,win_color1			; Beware: win_color1 is bank0, and we are bank1 currently
	movff	WREG,win_color2
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
	call	PLED_boot               ; PLED boot (Incl. Clear Screen!)
	rcall	display_new_cf_installed; Show warning
	movlw	max_custom_number		; Defined in definitions.asm
	movwf	EEDATA
	write_int_eeprom	d'92'		; Store number of CF used in this firmware

restart_1:

; Set Debug mode?
	read_int_eeprom	d'39'
	bsf		debug_mode			
	movlw	d'1'
	cpfseq	EEDATA
	bcf		debug_mode				; clear flag if <> 1

; Check if logbook has been converted already (Internal EEPROM 0x100=0xAA)
	movlw	LOW		0x100
	movwf	EEADR
	movlw	HIGH 	0x100
	movwf	EEADRH
	call	read_eeprom				; read byte
	movlw	0xAA
	cpfseq	EEDATA					; is 0xAA already?
	call	logbook_convert_64k		; No, convert now (And write 0xAA to internal EEPROM 0x100)

	goto	surfloop				; Jump to Surfaceloop!
	

display_new_cf_installed:
	call	PLED_new_cf_warning		; Display new CF warning screen
	movlw	d'20'					; timeout for warning screen
	bra		startup_screen3a		; Will RETURN after timeout or button press

;=============================================================================
; Setup all flags and parameters for divemode and simulator computations.
;
restart_set_modes_and_flags:		    ; "Call"ed from divemode, as well!
	bcf		gauge_mode
	bcf		FLAG_const_ppO2_mode
	bcf		FLAG_apnoe_mode			

; Pre-load modes for OC, GF 90/90 and no Aponoe or Gauge.
	bcf		no_deco_customviews		    ; Clear no-deco-mode-flag
	movlw	d'0'
	movff	WREG,char_I_deco_model	    ; Clear Flagbyte 
; Load GF values into RAM
	movlw	d'90'
	movff	WREG,char_I_GF_Low_percentage
	movff	WREG,char_I_GF_High_percentage		; Set to 90/90...
	clrf	EEADRH
	read_int_eeprom d'34'			    ; Read deco data	
	movlw	d'1'					    ; Gauge mode
	cpfseq	EEDATA
	bra     restart_3_test_ppO2_mode    ; check for ppO2 mode
	bsf		gauge_mode				    ; Set flag for gauge mode
	bsf		no_deco_customviews		    ; Set no-deco-mode-flag
    return							    ; start in Surfacemode
restart_3_test_ppO2_mode:
	movlw	d'2'					    ; const ppO2 mode
	cpfseq	EEDATA
    bra	    restart_3_test_apnoe_mode; check for apnoe mode
	bsf		FLAG_const_ppO2_mode	    ; Set flag for ppO2 mode
	return							    ; start in Surfacemode
restart_3_test_apnoe_mode:
	movlw	d'3'                        ; Apnoe mode
	cpfseq	EEDATA
	bra     restart_4_test_gf_mode	    ; check for GF OC mode
	bsf		FLAG_apnoe_mode			    ; Set flag for Apnoe Mode
	bsf		no_deco_customviews		    ; Set no-deco-mode-flag
    return							    ; start in Surfacemode
restart_4_test_gf_mode:
	movlw	d'4'					    ; GF OC mode
	cpfseq	EEDATA
	bra		restart_5_test_gfO2_mode    ; check for GF CC mode
	movlw	d'1'
	movff	WREG,char_I_deco_model      ; Set Flagbyte for GF method
; Load GF values into RAM
	GETCUSTOM8	d'32'			        ; GF low
	movff   EEDATA,char_I_GF_Low_percentage
	GETCUSTOM8	d'33'			        ; GF high
	movff   EEDATA,char_I_GF_High_percentage
	return							    ; start in Surfacemode
restart_5_test_gfO2_mode:
	movlw	d'5'					    ; GF CC mode
	cpfseq	EEDATA
	return							    ; Start in Surfacemode
	bsf		FLAG_const_ppO2_mode	    ; Set flag for ppO2 mode
	movlw	d'1'
	movff	WREG,char_I_deco_model	    ; Set Flagbyte for GF method
	; Load GF values into RAM
	GETCUSTOM8	d'32'                   ; GF low
	movff		EEDATA,char_I_GF_Low_percentage
	GETCUSTOM8	d'33'                   ; GF high
	movff		EEDATA,char_I_GF_High_percentage
	return							    ; start in Surfacemode

;=============================================================================

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
	btfsc	uart_dump_screen                ; Asked to dump screen contains ?
	call	dump_screen     			    ; Yes!

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
	btfsc	uart_dump_screen                ; Asked to dump screen contains ?
	call	dump_screen     			    ; Yes!

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

;=============================================================================

first_start:
	movlw	max_custom_number		; Defined in definitions.asm
	movwf	EEDATA
	write_int_eeprom	d'92'		; Store number of CF used in this firmware
	bra		start3					; continue with normal start

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

	clrf	SSPCON1			; Set I²C Mode
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
