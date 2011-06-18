
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
; last updated: 10/12/08 by JD Gascuel at free.fr
; known bugs:
; ToDo: 

; routines to reset external EEPROM (currently inactvated!)
; routines to reset custom function, gases and decompression values
; does not reset clock

;=============================================================================
; CF default values
;

; Macro to check values, and construct PROM CF default table.
; If in types mode, set flags into hi. If not, clear it.
CF_DEFAULT	macro	type, default, min, max
    noexpand
CFn set 1+CFn
    if (type) == CF_INT15
    	if HIGH (default) > .127
    		error CF#v(CFn) "15bit default too big: ", default
    	endif
    	if (min)>0 && (max>min)
    	    error CF#v(CFn) "15bit defaults cannot have both MIN & MAX flags"
    	endif
    	if HIGH(min) > .127
    	    error CF#v(CFn) "15bit MIN value too big: ", min
    	endif
    	if HIGH(max) > .127
    	    error CF#v(CFn) "15bit MAX value too big: ", max
    	endif
    
        ifdef NO_CF_TYPES
    		DB  LOW (default), HIGH(default) + 0x80
    	else
    		DB  LOW (default), HIGH(default) + 0x80
    		if (max) > (min)
        		DB  LOW(max), HIGH(max) + 0x80
        	else
        		DB  LOW(min), HIGH(min)
        	endif
    	endif
    else
        ; Basic sanity check for 8bit values:
    	if HIGH(default) > 0
    		error CF#v(CFn) "8bit default too big: ", default
    	endif
        if type & CF_NEG
        	if HIGH(-min) != 0
        		error CF#v(CFn) "8bit negativ min too big: ", min
        	endif
        else
        	if HIGH(min) != 0
        		error CF#v(CFn) "8bit min too big: ", min
        	endif
        endif
    	if HIGH(max) != 0
    		error CF#v(CFn) "8bit max too big: ", max
    	endif
    	if ((type)==CF_BOOL) && ( (default)>1 )
    		error CF#v(CFn) "BOOL default too big: ", default
    	endif
    	if ((type)==CF_BOOL) && ( (min)>0 || (max)>0 )
    		error CF#v(CFn) "BOOL cannot have min/max"
    	endif
    
        ifdef NO_CF_TYPES
    	    DB  LOW(default), 0
    	else
            local typeFlags
typeFlags   set type
            if (min)!=0
typeFlags       set type + CF_MIN
            endif
            if (max)>(min)
typeFlags       set typeFlags + CF_MAX
            endif
    	    DB  LOW(default), (typeFlags), LOW(min), LOW(max)
        endif
    endif
    expand
    endm

; Starting at CF0
CFn set     -1

; resets all customfunctions to the following default values
cf_default_table0:
    ;---- BANK0 custom function defaults -------------------------------------
    ;                          DEFAULT   MIN     MAX
	CF_DEFAULT    CF_CENTI,	    d'100', d'50',  d'250'  ; dive_threshold	        100cm
	CF_DEFAULT    CF_CENTI,	    d'30',  d'10',  d'100'  ; surf_threshold        	30cm
	CF_DEFAULT    CF_INT15,	    d'240', d'0',   d'600'  ; diveloop_timeout      	240s
	CF_DEFAULT    CF_SEC,	    d'120', d'30',  d'240'  ; surfloop_timeout	        120s
	CF_DEFAULT    CF_SEC,	    d'5',   d'1',   d'30'   ; premenu_timeout	        5s

	CF_DEFAULT    CF_INT8, 	    d'7',   d'3',   d'18'   ; minimum_velocity		    7min/min
	CF_DEFAULT    CF_INT15,	    d'1160',d'950', 0    	; pressure_offset_divemode	1160mBar
	CF_DEFAULT    CF_INT15,	    d'1080',d'1080', 0   	; max_surfpressure		    1080mBar
	CF_DEFAULT    CF_PERCENT,	d'20',  d'1',  d'99'   	; min_gradient_factor		20%
	CF_DEFAULT    CF_PERCENT,	d'20',  d'1',  d'22'	; oxygen_threshold			22%

	CF_DEFAULT    CF_SEC,	    d'45',  d'5',   d'60'   ; dive_menu_timeout		    45s
	CF_DEFAULT    CF_PERCENT,   d'110', d'110', d'200' 	; saturation_multiplier		x1.10
	CF_DEFAULT    CF_PERCENT,   d'90',  d'50',  d'90'   ; desaturation_multiplier	x0.90
	CF_DEFAULT    CF_PERCENT,	d'60',  d'60',  d'100'	; nofly_time_ratio			60%
	CF_DEFAULT    CF_PERCENT,	d'100', d'50',  d'100'  ; gradient_factor_alarm1	100%

	CF_DEFAULT    CF_PERCENT,	d'10',  d'0',  	d'100'  ; cns_display_surface		10%
	CF_DEFAULT    CF_DECI,	    d'10',  d'0',  	d'10'	; deco_distance_for_sim		1m
	CF_DEFAULT    CF_CENTI,     d'019', d'19', 	d'021'	; ppo2_warning_low			0.19 Bar
	CF_DEFAULT    CF_CENTI,     d'160', d'0', 	d'160'  ; ppo2_warning_high			1.60 Bar
	CF_DEFAULT    CF_CENTI,     d'150', d'0', 	d'150'	; ppo2_display_high			1.50 Bar
    
	CF_DEFAULT    CF_INT8,	    d'10',  d'1',   d'120'  ; sampling_rate				10s
	CF_DEFAULT    CF_INT8,	    d'6',   d'0',   d'15'   ; sampling_divisor_temp		/6
	CF_DEFAULT    CF_INT8,	    d'6',   d'0',   d'15'   ; sampling_divisor_deco		/6
	CF_DEFAULT    CF_INT8,	    d'6',   d'0',   d'15'   ; sampling_divisor_gf		/6
	CF_DEFAULT    CF_INT8,	    d'0',   d'0',   d'15'   ; sampling_divisor_ppo2		never

	CF_DEFAULT    CF_INT8,	    d'0',   d'0',   d'15'   ; sampling_divisor_deco2	never
	CF_DEFAULT    CF_INT8,	    d'12',  d'0',   d'15'   ; sampling_divisor_cns		/12
	CF_DEFAULT    CF_PERCENT,	d'20',  d'5',   d'75'   ; cns_display_high			20%
	CF_DEFAULT    CF_INT15,	    d'0',   d'0',   0 		; logbook_offset			No Offset, but 15Bit value
	CF_DEFAULT    CF_INT8,	    d'3',   d'2',   d'6'	; last_deco_depth			3m

	CF_DEFAULT    CF_SEC,	    d'10',  d'1',   d'15'   ; timeout_apnoe_mode		10min
	CF_DEFAULT    CF_BOOL,	    d'0',   0,      0       ; show_voltage_value		=1 Show value instead of symbol, =0 Show Symbol

    ;---- BANK1 custom function defaults -------------------------------------
cf_default_table1:
    ;                          DEFAULT   MIN     MAX
	CF_DEFAULT    CF_PERCENT,   d'30',  d'5',  	d'90'   ; GF_low_default			30%
	CF_DEFAULT    CF_PERCENT,   d'90', 	d'30',  d'95'   ; GF_high_default			90%
	CF_DEFAULT    CF_COLOR,     d'199', 0,      0 		; color_battery_surface		Color Battery sign: Deep blue
	CF_DEFAULT    CF_COLOR,     d'255', 0,      0 		; color_standard1			Color Standard: White
	CF_DEFAULT    CF_COLOR,     d'62',  0,      0 		; color_divemask			Color Divemask: Light green
    
	CF_DEFAULT    CF_COLOR,     d'224', 0,      0 		; color_warnings			Color Warnings: Red
	CF_DEFAULT    CF_BOOL,	    d'0',   0,      0       ; show_seconds_divemode		=1 Show the seconds in Divemode
	CF_DEFAULT    CF_BOOL,     	0,      0,      0 		; Adjust SetPoint if Diluent ppO2 > SetPoint
	CF_DEFAULT    CF_BOOL,	    d'1',   0,      0       ; warn_ceiling_divemode		=1 Warn ceiling violation in divemode
	CF_DEFAULT    CF_BOOL,      d'1',   0,      0 		; Show mix type is surfmode

	CF_DEFAULT    CF_BOOL,	    d'1',   0,      0       ; blink_gas_divemode 		=1 blink better gas
	CF_DEFAULT    CF_INT15,     d'13000', 0,   d'13000' ; color_warn_depth_mBar		Warn depths
	CF_DEFAULT    CF_PERCENT,	d'101', d'50',  d'101'	; color_warn_cns_percent    Warn-%
	CF_DEFAULT    CF_PERCENT,	d'101', d'50',  d'101'  ; color_warn_gf_percent		Warn-%
	CF_DEFAULT    CF_CENTI,     d'161', d'100', d'161'  ; color_warn_ppo2_cbar		ppO2 warn

	CF_DEFAULT    CF_INT8,	    d'15',  d'7',   d'20'	; color_warn_celocity_mmin	warn at xx m/min
	CF_DEFAULT    CF_SEC+CF_NEG,d'42',  -d'120',d'120'  ; time_correction_value_default	Adds to Seconds on Midnight
	CF_DEFAULT    CF_BOOL,      d'0',   0,      0 		; CF#49 Show Altimeter in surface mode
	CF_DEFAULT    CF_BOOL,     	d'0',   0,      0       ; CF50 Show Log-Marker
	CF_DEFAULT    CF_BOOL,	    d'1',   0,      0 		; CF51 Show Stopwatch
	                
	CF_DEFAULT    CF_BOOL,     	d'0',   0,      0 		; CF52 Show Tissue Graph in Divemode
	CF_DEFAULT    CF_BOOL,	    d'0',   0,      0 		; CF53 Show Laeding Tissue in Divemode
	CF_DEFAULT    CF_BOOL,      d'0',   0,      0 		; CF54 Display shallowest stop first
	CF_DEFAULT    CF_INT8,      d'0',   d'0',   d'10'   ; GF55 Gas switch additional delay
	CF_DEFAULT    CF_DECI,      d'200', d'5',   0       ; CF56 Bottom gas usage (l/min or bar/min)

	CF_DEFAULT    CF_DECI,      d'200', d'5',   0       ; CF57 Ascent/deco gas usage (l/min or bar/min)
	CF_DEFAULT    CF_INT8,      d'0',   d'0',   d'10'   ; CF58 TTS for extra time at current depth [min]
	CF_DEFAULT    CF_INT15,     0,      0,      0 		; UNUSED
	CF_DEFAULT    CF_INT15,     0,      0,      0 		; UNUSED
	CF_DEFAULT    CF_INT15,     0,      0,      0 		; UNUSED
	                
	CF_DEFAULT    CF_INT15,     0,      0,      0 		; UNUSED
	CF_DEFAULT    CF_INT15,     0,      0,      0 		; UNUSED
	CF_DEFAULT    CF_INT15,     0,      0,      0 		; UNUSED
cf_default_table2:

;=============================================================================

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
    setf    win_color1                  ; Make sure to display in white color.
    setf    win_color2
	DISPLAYTEXT	.25					    ; "Reset..."
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
    SAFE_2BYTE_COPY amb_pressure,int_I_pres_respiration	; copy surface air pressure to deco routine
	call	deco_clear_tissue
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
    SAFE_2BYTE_COPY amb_pressure,int_I_pres_respiration	; copy surface air pressure to deco routine
	call	deco_clear_tissue
	movlb	b'00000001'				; RAM Bank1 selected

; reset gases
	clrf	EEADRH					; EEPROM BANK 0 !

	movlw	d'3'					; address of first gas-1
	movwf	EEADR
	clrf	hi						; He part (default for all gases: 0%)
	movlw	d'21'					; O2 part (21%)
	rcall	reset_gas               ; saves default and current value for gas #1
	movlw	d'21'					; O2 part (21%)
	rcall	reset_gas               ; saves default and current value for gas #2
	movlw	d'21'					; O2 part (21%)
	rcall	reset_gas               ; saves default and current value for gas #3
	movlw	d'21'					; O2 part (21%)
	rcall	reset_gas               ; saves default and current value for gas #4
	movlw	d'21'					; O2 part (21%)
	rcall	reset_gas               ; saves default and current value for gas #5
	movlw	d'21'					; O2 part (21%)
	rcall	reset_gas               ; saves default and current value for gas #6

reset_all_cf:
	movlw	d'1'
	movwf	EEDATA
	write_int_eeprom	d'33'		; reset start gas
	clrf	EEDATA
	write_int_eeprom	d'34'		; reset deco model to ZH-L16
	clrf	EEDATA
	write_int_eeprom	d'35'		; unused in Mk.2

	clrf	EEDATA
	write_int_eeprom	d'39'		; Disable Debugbode
	clrf	EEDATA
	write_int_eeprom	d'90'		; Disable Brightness offset? (Dim=1, Normal = 0)

	movlw	d'1'
	movwf	EEDATA
	write_int_eeprom	d'91'		; Reset Date format to DD.MM.YY

	movlw	d'100'
	movwf	EEDATA
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

	movlw	d'80'
	movwf	EEDATA
	write_int_eeprom	d'36'		; reset mix1 to ppO2=0.80Bar
	movlw	d'100'
	movwf	EEDATA
	write_int_eeprom	d'37'		; reset mix2 to ppO2=1.00Bar
	movlw	d'120'
	movwf	EEDATA
	write_int_eeprom	d'38'		; reset mix3 to ppO2=1.20Bar

	clrf	nofly_time+0			; Clear nofly time
	clrf	nofly_time+1			; Clear nofly time

reset_all_cf_bank0:
    clrf    EEADRH
	movlw	d'127'					; address of low byte of first custom function
	movwf	EEADR

    movlw   LOW cf_default_table0    ; Load PROM pointer.
    movwf   TBLPTRL,A
    movlw   HIGH cf_default_table0
    movwf   TBLPTRH,A
    movlw   UPPER cf_default_table0
    movwf   TBLPTRU,A

cf_bank0_loop:
	; Did we already read 32 (decimal) words or double-words (with types) ?
	movf    TBLPTRL,W
	sublw   LOW (cf_default_table1)
	bz      reset_all_cf_bank1

	rcall	reset_customfunction	; saves default and current value
	bra     cf_bank0_loop
	
reset_all_cf_bank1:
	movlw	d'1'
	movwf	EEADRH					; EEPROM BANK 1 !!
	movlw	d'127'					; address of low byte of first custom function
	movwf	EEADR
	
cf_bank1_loop:
	; Did we already read another 32 (decimal) words or double-words ?
	movf    TBLPTRL,W
	sublw   LOW (cf_default_table2)
	bz      cf_bank1_end

	rcall	reset_customfunction	; saves default and current value
	bra     cf_bank1_loop

cf_bank1_end:
	clrf	EEADRH					; EEPROM BANK 0 !

;call	reset_external_eeprom	; delete profile memory
	goto	restart					; all reset, quit to surfmode

; Write WREG:lo twice, w/o any type clearing, pre-incrementing EEADR
reset_gas:
    movwf   lo
    rcall   reset_eeprom_value      ; First pair
    goto    reset_eeprom_value      ; Second pair.

reset_customfunction:
    tblrd*+
    movff   TABLAT, lo              ; Low byte in lo,
    tblrd*+
    movff   TABLAT, hi              ; High byte in hi

  ifndef NO_CF_TYPES
    tblrd*+                         ; Skip advanced min/max values.
    tblrd*+
    btfss   hi,7                    ; In EEPROM, just clear all types,
    clrf    hi                      ; to keep external program compat (jdivelog etc.)
    bcf     hi,7
  endif

    ; Manage the default/value tuple
    rcall   reset_eeprom_value      ; First pair, untouched.
    bcf     hi,7                    ; Just clear type bit.
    bra    reset_eeprom_value       ; Second pair, cleared

; Write the two bytes lo:hi into EEPROM
reset_eeprom_value:
	incf	EEADR,F
	movff	lo, EEDATA				; Lowbyte Default value

	movlw	d'127'					; Work-around to prevent writing at EEPROM 0x00 to 0x04 
	cpfslt	EEADR					; EEADR > 127?
	call	write_eeprom			; Yes, write!

	incf	EEADR,F
	movff	hi, EEDATA				; Highbyte default value

	movlw	d'127'					; Work-around to prevent writing at EEPROM 0x00 to 0x04 
	cpfslt	EEADR					; EEADR > 127?
	call    write_eeprom			; Yes, write!
	return

reset_external_eeprom:				; deletes complete external eeprom!
	clrf	eeprom_address+0
	clrf	eeprom_address+1

	movlw	d'4'
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
	bra		reset_eeprom02				; and this all 4 times -> 1024 *64Bytes = 64KB

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
	
