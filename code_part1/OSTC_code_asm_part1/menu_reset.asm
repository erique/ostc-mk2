
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


; Menu "Reset all"
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 10/30/05
; last updated: 08/08/31
; known bugs:
; ToDo: 

; routines to reset external EEPROM (currently inactvated!)
; routines to reset custom function, gases and decompression values
; does not reset clock

menu_reset:
	movlw	d'1'
	movwf	menupos

	call	PLED_ClearScreen
	call	PLED_reset_menu_mask

menu_reset2:
	clrf	timeout_counter2
	bcf		sleepmode
	bcf		menubit2
	bcf		menubit3
	bsf		menubit
	bsf		cursor
	call	PLED_reset_menu_mask
	call	PLED_menu_cursor
	bcf		switch_left
	bcf		switch_right
menu_reset_loop:
	call	check_switches_menu
	btfsc	menubit2
	bra		do_menu_reset					; call submenu
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
	goto	menu
	btfsc	divemode
	goto	restart						; exit menu, restart and enter divemode
	bra		menu_reset_loop
do_menu_reset:						; calls submenu
	dcfsnz	menupos,F
	bra		do_menu_reset_exit				; Cancel, exit
	dcfsnz	menupos,F
	bra		do_menu_reset_all				; Reset all settings
	dcfsnz	menupos,F
	bra		do_menu_reset_logbook			; Reset Logbook Memory!
	dcfsnz	menupos,F
	bra		do_menu_reset_reboot			; Reboot OSTC
	dcfsnz	menupos,F
	bra		do_menu_reset_decodata			; Reset Decodata
do_menu_reset_exit:
	movlw	d'3'
	movwf	menupos
	bra		menu2							; exit...


do_menu_reset_reboot:
	call	PLED_confirmbox				; Returns WREG=0 for Cancel (Or Timeout) and WREG=1 for OK!
	movwf	menupos						; Used as temp
	tstfsz	menupos
	bra		do_menu_reset_reboot2		; Delete now!
	bra		do_menu_reset_exit			; Cancel!

do_menu_reset_reboot2:
	call	PLED_DisplayOff					; Power-down OLED 
	movlw	b'00000000'						; Bit6: PPL Disable
	movwf	OSCTUNE
	movlw	b'01111110'						; 8MHz
	movwf	OSCCON
	reset
	goto	0x00000							; restart to 0x00000

do_menu_reset_logbook:
	call	PLED_confirmbox				; Returns WREG=0 for Cancel (Or Timeout) and WREG=1 for OK!
	movwf	menupos						; Used as temp
	tstfsz	menupos
	bra		do_menu_reset_logbook2		; Delete Logbook now!
	bra		do_menu_reset_exit			; Cancel!

do_menu_reset_logbook2:
	call	PLED_ClearScreen
	DISPLAYTEXT	.25					; "Reset..."
	call	reset_external_eeprom		; delete profile memory
	bra		do_menu_reset_exit

do_menu_reset_decodata:
	call	PLED_confirmbox				; Returns WREG=0 for Cancel (Or Timeout) and WREG=1 for OK!
	movwf	menupos						; Used as temp
	tstfsz	menupos
	bra		do_menu_reset_decodata2		; Reset Deco Data now!
	bra		do_menu_reset_exit			; Cancel!

do_menu_reset_decodata2:
; reset deco data
	call	PLED_ClearScreen
	DISPLAYTEXT	.25					; "Reset..."
	movff	amb_pressure+0,int_I_pres_respiration+0		; copy surface air pressure to deco routine
	movff	amb_pressure+1,int_I_pres_respiration+1		
	call	deco_main_clear_tissue	;
	movlb	b'00000001'				; RAM Bank1 selected
	goto	restart					; done. quit to surfmode

do_menu_reset_all:
	call	PLED_confirmbox				; Returns WREG=0 for Cancel (Or Timeout) and WREG=1 for OK!
	movwf	menupos						; Used as temp
	tstfsz	menupos
	bra		do_menu_reset_all2			; Reset all now!
	bra		do_menu_reset_exit			; Cancel!

do_menu_reset_all2:
	call	PLED_ClearScreen
	DISPLAYTEXT	.25					; "Reset..."

reset_start:
; reset deco data
	movff	amb_pressure+0,int_I_pres_respiration+0		; copy surface air pressure to deco routine
	movff	amb_pressure+1,int_I_pres_respiration+1		
	call	deco_main_clear_tissue	;
	movlb	b'00000001'				; RAM Bank1 selected

; reset gases
	clrf	EEADRH					; EEPROM BANK 0 !

	movlw	d'3'					; address of first gas-1
	movwf	EEADR
	clrf	hi						; He part (default for all gases: 0%)
	movlw	d'21'					; O2 part (21%)
	rcall	reset_customfunction	; saves default and current value for gas #1
	movlw	d'21'					; O2 part (21%)
	rcall	reset_customfunction	; saves default and current value for gas #2
	movlw	d'21'					; O2 part (21%)
	rcall	reset_customfunction	; saves default and current value for gas #3
	movlw	d'21'					; O2 part (21%)
	rcall	reset_customfunction	; saves default and current value for gas #4
	movlw	d'21'					; O2 part (21%)
	rcall	reset_customfunction	; saves default and current value for gas #5
	movlw	d'21'					; O2 part (21%)
	rcall	reset_customfunction	; saves default and current value for gas #6

reset_all_cf:
; resets all customfunctions to the following default values
	movlw	d'1'
	movwf	EEDATA
	write_int_eeprom	d'33'		; reset start gas
	clrf	EEDATA
	write_int_eeprom	d'34'		; reset deco model to ZH-L16
	clrf	EEDATA
	write_int_eeprom	d'35'		; Do not use O2 Sensor in CC Modes

	movlw	d'0'
	clrf	EEDATA
	write_int_eeprom	d'39'		; Disable Debugbode
	clrf	EEDATA
	write_int_eeprom	d'90'		; Disable Brightness offset? (Dim=1, Normal = 0)
	clrf	EEDATA
	write_int_eeprom	d'91'		; Reset Date format to MM/DD/YY

	movlw	d'100'
	write_int_eeprom	d'26'		; Salinity default: 1.00 kg/l

	movlw	b'00011111'	
	movwf	EEDATA
	write_int_eeprom	d'27'		; reset active gas flags

	clrf	EEDATA
	write_int_eeprom	d'28'		; reset change depth gas #1
	clrf	EEDATA
	write_int_eeprom	d'29'		; reset change depth gas #2
	clrf	EEDATA
	write_int_eeprom	d'30'		; reset change depth gas #3
	clrf	EEDATA
	write_int_eeprom	d'31'		; reset change depth gas #4
	clrf	EEDATA
	write_int_eeprom	d'32'		; reset change depth gas #5

	movlw	d'100'
	movwf	EEDATA
	write_int_eeprom	d'36'		; reset mix1 to ppO2=1.00Bar
	write_int_eeprom	d'37'		; reset mix2 to ppO2=1.00Bar
	write_int_eeprom	d'38'		; reset mix3 to ppO2=1.00Bar

	movlw	d'1'
	movwf	nofly_time+0			; Clear nofly time
	clrf	nofly_time+1			; Clear nofly time

#DEFINE dive_threshold				d'100'		; 8BIT 		100cm
#DEFINE surf_threshold				d'30'		; 8BIT 		30cm
#DEFINE diveloop_timeout    		d'240'		; 8BIT 		240s
#DEFINE surfloop_timeout			d'120'		; 8BIT 		120s
#DEFINE	premenu_timeout				d'5'		; 8BIT 		5s

#DEFINE	minimum_velocity			d'7'		; 8BIT 		7min/min
#DEFINE	pressure_offset_divemode	d'1160'		; 15BIT		1160mBar
#DEFINE	max_surfpressure			d'1100'		; 15BIT		1100mBar
#DEFINE	min_gradient_factor			d'20'		; 8Bit 		20%
#DEFINE	oxygen_threshold			d'20'		; 8Bit 		20%

#DEFINE	dive_menu_timeout			d'30'		; 8BIT 		30s
#DEFINE	saturation_multiplier		d'110'		; 8BIT 		x1.1
#DEFINE	desaturation_multiplier		d'90'		; 8BIT 		x0.9
#DEFINE	nofly_time_ratio			d'60'		; 8BIT		60%
#DEFINE	gradient_factor_alarm1		d'100'		; 8Bit		100%

#DEFINE	not_used_CF15				d'100'		; 8Bit		
#DEFINE	deco_distance_for_sim		d'10'		; 8Bit		1m
#DEFINE	ppo2_warning_low			d'019'		; 8Bit		0.19 Bar
#DEFINE	ppo2_warning_high			d'160'		; 8Bit		1.60 Bar
#DEFINE	ppo2_display_high			d'150'		; 8Bit		1.50 Bar

#DEFINE	sampling_rate				d'10'		; 8Bit		10s
#DEFINE	sampling_divisor_temp		d'6'		; 8Bit		/6
#DEFINE	sampling_divisor_deco		d'6'		; 8Bit		/6
#DEFINE	sampling_divisor_tank		d'0'		; 8Bit		never
#DEFINE	sampling_divisor_ppo2		d'0'		; 8Bit		never

#DEFINE	sampling_divisor_deco2		d'12'		; 8Bit		/12
#DEFINE	sampling_divisor_nyu2		d'0'		; 8Bit		never
#DEFINE	cns_display_high			d'20'		; 8Bit		20%
#DEFINE	logbook_offset				d'0'		; 15Bit		No Offset, but 15Bit value
#DEFINE	last_deco_depth				d'3'		; 8Bit		3m
#DEFINE	timeout_apnoe_mode			d'10'		; 8Bit		10min
#DEFINE	show_voltage_value			d'0'		; 1Bit		=1 Show value instead of symbol, =0 Show Symbol

#DEFINE	GF_low_default				d'30'		; 8Bit		30%
#DEFINE	GF_high_default				d'90'		; 8Bit		90%
#DEFINE	color_battery_surface		d'223'		; 8Bit		Color Battery sign: Cyan
#DEFINE	color_standard1				d'255'		; 8Bit		Color Standard: White
#DEFINE	color_divemask				d'224'		; 8Bit		Color Divemask: Red
#DEFINE	color_warnings				d'224'		; 8Bit		Color Warnings: Red

#DEFINE	show_seconds_divemode		d'0'		; 1Bit 		=1 Show the seconds in Divemode
#DEFINE	not_used_cf39_binary		d'0'		; 1Bit		=1 Flip Display
#DEFINE	not_used_cf40_binary		d'0'		; 1Bit		=1 Use alternative outputs for ppO2 sensor
#DEFINE	start_with_stopwatch		d'0'		; 1Bit		=1 start with stopwatch
#DEFINE	blink_gas_divemode 			d'0'		; 1Bit		=1 Show (resetable) average Depth instead of temperature

#DEFINE	color_warn_depth_mBar		d'13000'	; 15Bit		Warn depths
#DEFINE	color_warn_cns_percent		d'101'		; 8Bit		Warn-%
#DEFINE	color_warn_gf_percent		d'101'		; 8Bit		Warn-%
#DEFINE	color_warn_ppo2_cbar		d'161'		; 8Bit		ppO2 warn
#DEFINE	color_warn_celocity_mmin	d'15'		; 8Bit		warn at xx m/min

	movlw	d'127'					; address of low byte of first custom function
	movwf	EEADR
	clrf	hi						; only required once
	movlw	LOW		dive_threshold	; 8Bit value
	rcall	reset_customfunction	; saves default and current value

	movlw	LOW		surf_threshold
	rcall	reset_customfunction	; saves default and current value

	movlw	LOW		diveloop_timeout
	rcall	reset_customfunction	; saves default and current value

	movlw	LOW		surfloop_timeout
	rcall	reset_customfunction	; saves default and current value

	movlw	LOW		premenu_timeout
	rcall	reset_customfunction	; saves default and current value

	movlw	LOW		minimum_velocity
	rcall	reset_customfunction	; saves default and current value

	movlw	HIGH	pressure_offset_divemode
	movwf	hi
	bsf		hi,7					; 15Bit value
	movlw	LOW		pressure_offset_divemode
	rcall	reset_customfunction	; saves default and current value

	movlw	HIGH	max_surfpressure
	movwf	hi
	bsf		hi,7					; 15Bit value
	movlw	LOW		max_surfpressure
	rcall	reset_customfunction	; saves default and current value

	movlw	LOW		min_gradient_factor
	rcall	reset_customfunction	; saves default and current value

	movlw	LOW		oxygen_threshold
	rcall	reset_customfunction	; saves default and current value

	movlw	LOW		dive_menu_timeout
	rcall	reset_customfunction	; saves default and current value

	movlw	LOW		saturation_multiplier
	rcall	reset_customfunction	; saves default and current value

	movlw	LOW		desaturation_multiplier
	rcall	reset_customfunction	; saves default and current value

	movlw	LOW		nofly_time_ratio
	rcall	reset_customfunction	; saves default and current value

	movlw	LOW		gradient_factor_alarm1
	rcall	reset_customfunction	; saves default and current value

	movlw	LOW		not_used_CF15
	rcall	reset_customfunction	; saves default and current value
	
	movlw	LOW		deco_distance_for_sim
	rcall	reset_customfunction	; saves default and current value
		
	movlw	LOW		ppo2_warning_low
	rcall	reset_customfunction	; saves default and current value
	
	movlw	LOW		ppo2_warning_high
	rcall	reset_customfunction	; saves default and current value
	
	movlw	LOW		ppo2_display_high
	rcall	reset_customfunction	; saves default and current value
	
	movlw	LOW		sampling_rate
	rcall	reset_customfunction	; saves default and current value

	movlw	LOW		sampling_divisor_temp
	rcall	reset_customfunction	; saves default and current value

	movlw	LOW		sampling_divisor_deco
	rcall	reset_customfunction	; saves default and current value

	movlw	LOW		sampling_divisor_tank
	rcall	reset_customfunction	; saves default and current value

	movlw	LOW		sampling_divisor_ppo2
	rcall	reset_customfunction	; saves default and current value

	movlw	LOW		sampling_divisor_deco2
	rcall	reset_customfunction	; saves default and current value

	movlw	LOW		sampling_divisor_nyu2
	rcall	reset_customfunction	; saves default and current value

	movlw	LOW		cns_display_high
	rcall	reset_customfunction	; saves default and current value

	clrf	hi	
	bsf		hi,7					; 15Bit value
	movlw	LOW		logbook_offset
	rcall	reset_customfunction	; saves default and current value

	movlw	LOW		last_deco_depth				
	rcall	reset_customfunction	; saves default and current value
	
	movlw	LOW		timeout_apnoe_mode
	rcall	reset_customfunction	; saves default and current value
	
	movlw	LOW		show_voltage_value
	rcall	reset_customfunction	; saves default and current value

reset_all_cf_bank1:
	movlw	d'1'
	movwf	EEADRH					; EEPROM BANK 1 !!
	movlw	d'127'					; address of low byte of first custom function
	movwf	EEADR
	clrf	hi						; only required once/bank
	
	movlw	LOW		GF_low_default
	rcall	reset_customfunction	; saves default and current value

	movlw	LOW		GF_high_default
	rcall	reset_customfunction	; saves default and current value

	movlw	color_battery_surface
	rcall	reset_customfunction	; saves default and current value

	movlw	color_standard1
	rcall	reset_customfunction	; saves default and current value

	movlw	color_divemask
	rcall	reset_customfunction	; saves default and current value

	movlw	color_warnings
	rcall	reset_customfunction	; saves default and current value

	movlw	show_seconds_divemode
	rcall	reset_customfunction	; saves default and current value

	movlw	not_used_cf39_binary
	rcall	reset_customfunction	; saves default and current value

	movlw	not_used_cf40_binary	
	rcall	reset_customfunction	; saves default and current value

	movlw	start_with_stopwatch
	rcall	reset_customfunction	; saves default and current value

	movlw	blink_gas_divemode	
	rcall	reset_customfunction	; saves default and current value

	movlw	HIGH	color_warn_depth_mBar
	movwf	hi
	bsf		hi,7					; 15Bit value
	movlw	LOW		color_warn_depth_mBar
	rcall	reset_customfunction	; saves default and current value

	movlw	color_warn_cns_percent
	rcall	reset_customfunction	; saves default and current value

	movlw	color_warn_gf_percent
	rcall	reset_customfunction	; saves default and current value

	movlw	color_warn_ppo2_cbar
	rcall	reset_customfunction	; saves default and current value

	movlw	color_warn_celocity_mmin
	rcall	reset_customfunction	; saves default and current value

	movlw	d'0'
	rcall	reset_customfunction	; saves default and current value
	movlw	d'0'
	rcall	reset_customfunction	; saves default and current value
	movlw	d'0'
	rcall	reset_customfunction	; saves default and current value
	movlw	d'0'
	rcall	reset_customfunction	; saves default and current value
	movlw	d'0'
	rcall	reset_customfunction	; saves default and current value
	movlw	d'0'
	rcall	reset_customfunction	; saves default and current value
	movlw	d'0'
	rcall	reset_customfunction	; saves default and current value
	movlw	d'0'
	rcall	reset_customfunction	; saves default and current value
	movlw	d'0'
	rcall	reset_customfunction	; saves default and current value
	movlw	d'0'
	rcall	reset_customfunction	; saves default and current value
	movlw	d'0'
	rcall	reset_customfunction	; saves default and current value
	movlw	d'0'
	rcall	reset_customfunction	; saves default and current value
	movlw	d'0'
	rcall	reset_customfunction	; saves default and current value
	movlw	d'0'
	rcall	reset_customfunction	; saves default and current value
	movlw	d'0'
	rcall	reset_customfunction	; saves default and current value
	movlw	d'0'
	rcall	reset_customfunction	; saves default and current value

	clrf	EEADRH					; EEPROM BANK 0 !
	

;call	reset_external_eeprom	; delete profile memory
	goto	restart					; all reset, quit to surfmode

reset_customfunction:
	movwf	lo
	incf	EEADR,F
	movff	lo, EEDATA					; Lowbyte Defaul value
	call	write_eeprom
	incf	EEADR,F
	movff	hi, EEDATA					; Highbyte default value
	call	write_eeprom
	incf	EEADR,F
	movff	lo, EEDATA					; Lowbyte current value
	call	write_eeprom
	incf	EEADR,F
	bcf		hi,7						; This bit will only be written for the default value
	movff	hi, EEDATA					; Highbyte current value
	call	write_eeprom
	clrf	hi	
	return
	

reset_external_eeprom:				; deletes complete external eeprom!
	clrf	eeprom_address+0
	clrf	eeprom_address+1

	movlw	d'2'
	movwf	temp3
reset_eeprom02:
	clrf	temp4
reset_eeprom01:
	movlw	d'64'
	movwf	temp2
	bcf		eeprom_blockwrite		; Blockwrite start
reset_eeprom1:
	setf	ext_ee_temp1			; byte for Blockwrite....
	movf	ext_ee_temp1,W			; So, 1st. Byte of block is fine, too
	call	write_external_eeprom_block
	decfsz	temp2,F		; 64 Byte done
	bra		reset_eeprom1
	bsf		SSPCON2,PEN					; Stop condition
	call	WaitMSSP	
	WAITMS	d'7'
	decfsz	temp4,F
	bra		reset_eeprom01				; do this 256 times
	decfsz	temp3,F
	bra		reset_eeprom02				; and this all 2 times -> 512 *64Bytes = 32KB

	bcf		eeprom_blockwrite			; clear blockwrite flag

	clrf	eeprom_address+0
	clrf	eeprom_address+1

	movlw	0xFD						; With these three bytes the OSTC will find the free area in the EEPROM faster
	call	write_external_eeprom
	movlw	0xFD
	call	write_external_eeprom
	movlw	0xFE						
	call	write_external_eeprom	

	clrf	eeprom_address+0
	clrf	eeprom_address+1
	return
	
