
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


; Mainroutines for divemode
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 10/01/05
; last updated: 15/05/08
; known bugs:
; ToDo: 

diveloop:
	call	diveloop_boot			; Boot tasks for all modes

; Startup Tasks for all modes
	ostc_debug	'R'		; Sends debug-information to screen if debugmode active
	call	PLED_ClearScreen			; clean up OLED
	call	PLED_divemode_mask					; Display mask
	call	PLED_active_gas_divemode	; Display gas, if required
	call	PLED_temp_divemode			; Displays temperature

	btfsc	FLAG_apnoe_mode
	bsf		realdive					; Set Realdive flag in Apnoe mode

	btfsc	gauge_mode
	bra		diveloop_loop				; Skip in gauge mode
	btfsc	FLAG_apnoe_mode
	bra		diveloop_loop				; Skip in apnoe mode

; Startup Tasks for deco modes
	call	PLED_display_ndl_mask		; display "no stop" if not in gauge or apnoe mode

diveloop_loop:		; The diveloop starts here
	btfss	onesecupdate					; tasks any new second
	bra		diveloop_loop2

	btfsc	gauge_mode						; Only in gauge mode
	bra		diveloop_loop1a					; One Second Tasks in Gauge mode
	btfsc	FLAG_apnoe_mode					; Only in apnoe mode
	bra		diveloop_loop1b					; One Second Tasks in Apnoe mode
	btfsc	FLAG_const_ppO2_mode			; only in const_ppO2_mode
	bra		diveloop_loop1c					; One Second Tasks in const_ppO2 mode

; Tasks only for OC modes
	call	check_ppO2						; check ppO2 and displays warning if required
	call	calc_deko_divemode				; calculate decompression and display result (any two seconds)
	bra		diveloop_loop1x					; Common Tasks

; Tasks only for Gauge mode
diveloop_loop1a:
	btfss	premenu							; Is the divemode menu active?
	call	PLED_divemins					; display (new) divetime!
	call	timeout_divemode				; dive finished? This routine sets the required flags

	btfsc	twosecupdate					; two seconds after the last call
	bra		diveloop_loop1a2					; Common Tasks

	bsf		twosecupdate				; Routines used in the "other second"
	call	calc_average_depth			; calculate average depth
	
	bra		diveloop_loop1x					; Common Tasks

diveloop_loop1a2:
	bcf		twosecupdate		
	bra		diveloop_loop1x					; Common Tasks

; Tasks only for Apnoe mode
diveloop_loop1b:
	call	divemode_apnoe_tasks			; 1 sec. Apnoe tasks
	bra		diveloop_loop1x					; Common Tasks

; Tasks only for ppO2 mode
diveloop_loop1c:
	call	PLED_const_ppO2_value			; display const ppO2 setting in [Bar]
	call	calc_deko_divemode				; calculate decompression and display result (any two seconds)
	btfsc	is_bailout						; Are we in Bailout mode?
	call	check_ppO2_bail					; Yes, display ppO2 (If required)

	bra		diveloop_loop1x					; Common Tasks
	
; Common Tasks for all modes
diveloop_loop1x:
	call	timeout_divemode				; dive finished? This routine sets the required flags
	btfsc	low_battery_state				; If battery is low, then...
	call	update_batt_voltage_divemode	; Display Battery Warning Text
	btfsc	premenu							; is Menu? displayed?
	call	timeout_premenu_divemode		; No, so check for timeout premenu
	btfsc	menubit							; is the Dive mode menu displayed?
	call	timeout_divemenu				; Yes, so check for timeout divemenu
	call	set_leds_divemode				; Sets warnings, if required. Also Sets buzzer
	btfsc	enter_error_sleep				; Enter Fatal Error Routine?
	call	fatal_error_sleep				; Yes (In Sleepmode_vxx.asm!)
	call	customview_second				; Do every-second tasks for the custom view area

	bcf		onesecupdate					; one seconds update done

	GETCUSTOM8	d'38'		; Show seconds (=1?)
	movwf	lo
	movlw	d'1'
	cpfseq	lo					; =1?
	bra		diveloop_loop2		; No, minutes only
	bsf		update_divetime		; Set Update flag


diveloop_loop2:	
	btfss	update_divetime				; display new divetime?
	bra		diveloop_loop3				; No
	btfsc	premenu						; Is the divemode menu active?
	bra		diveloop_loop2a				; Yes
	call	PLED_divemins				; Display (new) divetime!
	btfsc	FLAG_const_ppO2_mode		; only in const_ppO2_mode
	call	PLED_const_ppO2_value		; display const ppO2 setting in [Bar]
	btfsc	ppO2_show_value				; show ppO2?
	call	check_ppO2					; check ppO2 and displays warning if required

diveloop_loop2a:
	bcf		update_divetime				; clear flag

diveloop_loop3:
	btfss	menubit							; Divemode menu active?
	call	test_switches_divemode			; No, Check switches normal

	btfsc	menubit							; Divemode menu active?
	call	test_switches_divemode_menu		; Yes, check switches divemode menu

	btfss	divemode						; Dive finished?
	bra		end_dive						; Dive finished!

	btfsc	pressure_refresh				; new pressure available?
	call	update_divemode1				; Yes, display new depth
	bcf		pressure_refresh				; until new pressure is available

	btfsc	oneminupdate					; one minute tasks
	call	update_divemode60				; Update clock, etc.

	btfsc	store_sample					; store new sample?
	call	store_dive_data					; Store profile data

	btfsc	toggle_customview				; Next view?
	call	customview_toggle				; Yes, show next customview (and delete this flag)

	btfsc	menubit							; Sleep only with inactive menu...
	bra		diveloop_loop4

	btfsc	simulatormode_active			; Do not sleep in Simualtor mode
	bra		diveloop_loop4

	sleep
	nop
diveloop_loop4:
	bra		diveloop_loop					; Loop the divemode

timeout_premenu_divemode:
	incf	timeout_counter3,F              ; Yes...

	GETCUSTOM8	d'4'                        ; loads premenu_timeout into WREG
	cpfsgt	timeout_counter3                ; ... longer then premenu_timeout
	return                                  ; No!

	bcf		premenu                         ; Yes, so clear "Menu?" and clear pre_menu bit
	call	PLED_menu_clear                 ; Remove "Menu?"
	return

divemode_apnoe_tasks:                       ; 1 sec. Apnoe tasks
	call	PLED_display_apnoe_descent		; Show descent timer

	btfsc	divemode2						; Time running?
	bra		divemode_apnoe_tasks2			; New descent, reset data if flag is set

	call	PLED_display_apnoe_surface
	incf	apnoe_surface_secs,F
	movlw	d'60'
	cpfseq	apnoe_surface_secs
	bra		divemode_apnoe_tasks1
	clrf	apnoe_surface_secs
	incf	apnoe_surface_mins,F

divemode_apnoe_tasks1:	
	bcf		FLAG_active_descent				; Clear flag
	btfsc	divemode2						; Time running?
	return									; Yes, return
	
	bsf		FLAG_active_descent				; Set Flag
	return

divemode_apnoe_tasks2:
	btfss	FLAG_active_descent				; Are descending?			
	return									; No, We are at the surface
	rcall	apnoe_calc_maxdepth				; Yes!
	
divemode_apnoe_tasks3:
	call	PLED_apnoe_clear_surface		; Clear Surface timer
	
	clrf	apnoe_timeout_counter			; Delete timeout
	clrf	apnoe_surface_secs
	clrf	apnoe_surface_mins
	clrf	apnoe_secs
	clrf	apnoe_mins						; Reset Descent time
	clrf	max_pressure+0
	clrf	max_pressure+1					; Reset Max. Depth
	bcf		FLAG_active_descent				; Clear flag
	return

apnoe_calc_maxdepth:
	movff	apnoe_max_pressure+0,sub_a+0
	movff	apnoe_max_pressure+1,sub_a+1
	movff	max_pressure+0,sub_b+0
	movff	max_pressure+1,sub_b+1
	call	sub16				; sub_c = sub_a - sub_b
								; apnoe_max_pressure<max_pressure -> neg_flag=1
								; max_pressure<=apnoe_max_pressure -> neg_flag=0
	btfss	neg_flag	
	return
								;apnoe_max_pressure<max_pressure
	movff	max_pressure+0,apnoe_max_pressure+0
	movff	max_pressure+1,apnoe_max_pressure+1
	return

set_leds_divemode:
	movff	char_O_gradient_factor,lo		; gradient factor absolute

	GETCUSTOM8	d'14'		; threshold for LED warning
	cpfslt	lo				; 
	call	warn_gf1		; show warning, set flags

	movff	char_I_deco_model,lo
		decfsz	lo,W		; jump over return if char_I_deco_model == 1
	return

	movff	char_O_relative_gradient_GF,lo		; gradient factor relative (GF model)

	GETCUSTOM8	d'14'		; threshold for LED warning
	cpfslt	lo				; 
	call	warn_gf1		; show warning, set flags

	return

warn_gf1:
	movlw		d'2'			; Type of Alarm
	movwf		AlarmType		; Copy to Alarm Register
	bsf			event_occured	; Set Event Flag
	return

calc_deko_divemode:
	btfsc	twosecupdate		; two seconds after the last call
	bra		calc_deko_divemode2		; Yes, calculate and display deco data ("first second")

	bsf		twosecupdate		; No, but next second!
	; Routines used in the "other second"
	call	calc_average_depth	; calculate average depth
	call	calc_velocity		; calculate vertical velocity and display if > threshold (every two seconds)
	
	; calculate ppO2 in 0.1Bar (e.g. 150 = 1.50Bar ppO2)
	movff		amb_pressure+0,xA+0
	movff		amb_pressure+1,xA+1
	movlw		d'10'
	movwf		xB+0
	clrf		xB+1
	call		div16x16				; xC=p_amb/10
	movff		xC+0,xA+0
	movff		xC+1,xA+1
	movff		char_I_O2_ratio,xB+0
	clrf		xB+1
	call		mult16x16				; char_I_O2_ratio * p_amb/10
	movff		xC+0,xA+0
	movff		xC+1,xA+1
	movlw		d'100'
	movwf		xB+0
	clrf		xB+1
	call		div16x16				; xC=(char_I_O2_ratio * p_amb/10)/100

; Copy ppO2 for CNS calculation
	movff		xC+0, char_I_actual_ppO2	; copy last ppO2 to buffer register
	btfsc		FLAG_const_ppO2_mode		; do in const_ppO2_mode
	movff		char_I_const_ppO2, char_I_actual_ppO2	; copy last ppO2 to buffer register

; Calculate CNS	
	call	deco_calc_CNS_fraction		; calculate CNS
	movlb	b'00000001'					; rambank 1 selected

; Check if CNS should be displayed
	movff	char_O_CNS_fraction,lo		; copy into bank1
	GETCUSTOM8	d'27'					; cns_display_high
	subwf	lo,W
	btfsc	STATUS,C
	call	PLED_display_cns			; Show CNS
	call	check_gas_change			; Checks if a better gas should be selected (by user)

; Check for decompression gases if in decomode
	btfss	dekostop_active
	bra		reset_decompression_gases	; While in NDL, do not set deompression gas

divemode_check_decogases:					; CALLed from Simulator
; Copy active gases to char_I_deco_N2_ratio and char_I_deco_He_ratio
	read_int_eeprom		d'97'			; Read He ratio
	movff	EEDATA,char_I_deco_He_ratio5	; And copy into hold register
	read_int_eeprom		d'96'			; Read O2 ratio
	movff	char_I_deco_He_ratio5, wait_temp			; copy into bank1 register
	bsf		STATUS,C					; 
	movlw	d'100'						; 100%
	subfwb	wait_temp,W					; minus He
	subfwb	EEDATA,F					; minus O2
	movff	EEDATA, char_I_deco_N2_ratio5; = N2!

	read_int_eeprom		d'101'			; Read He ratio
	movff	EEDATA,char_I_deco_He_ratio4	; And copy into hold register
	read_int_eeprom		d'100'			; Read O2 ratio
	movff	char_I_deco_He_ratio4, wait_temp			; copy into bank1 register
	bsf		STATUS,C					; 
	movlw	d'100'						; 100%
	subfwb	wait_temp,W					; minus He
	subfwb	EEDATA,F					; minus O2
	movff	EEDATA, char_I_deco_N2_ratio4; = N2!

	read_int_eeprom		d'105'			; Read He ratio
	movff	EEDATA,char_I_deco_He_ratio3	; And copy into hold register
	read_int_eeprom		d'104'			; Read O2 ratio
	movff	char_I_deco_He_ratio3, wait_temp			; copy into bank1 register
	bsf		STATUS,C					; 
	movlw	d'100'						; 100%
	subfwb	wait_temp,W					; minus He
	subfwb	EEDATA,F					; minus O2
	movff	EEDATA, char_I_deco_N2_ratio3; = N2!

	read_int_eeprom		d'109'			; Read He ratio
	movff	EEDATA,char_I_deco_He_ratio2	; And copy into hold register
	read_int_eeprom		d'108'			; Read O2 ratio
	movff	char_I_deco_He_ratio2, wait_temp			; copy into bank1 register
	bsf		STATUS,C					; 
	movlw	d'100'						; 100%
	subfwb	wait_temp,W					; minus He
	subfwb	EEDATA,F					; minus O2
	movff	EEDATA, char_I_deco_N2_ratio2; = N2!

	read_int_eeprom		d'113'			; Read He ratio
	movff	EEDATA,char_I_deco_He_ratio1; And copy into hold register
	read_int_eeprom		d'112'			; Read O2 ratio
	movff	char_I_deco_He_ratio1, wait_temp			; copy into bank1 register
	bsf		STATUS,C					; 
	movlw	d'100'						; 100%
	subfwb	wait_temp,W					; minus He
	subfwb	EEDATA,F					; minus O2
	movff	EEDATA, char_I_deco_N2_ratio1; = N2!

; Now, set change depth. Inactive gases have depth=0!
	read_int_eeprom		d'118'				; read gas_change_depth Gas1
	btfss	sorted_gaslist_active,0			; Apply depth?
	clrf	EEDATA							; No, clear!
	movff	EEDATA,char_I_deco_gas_change5	; Yes!

	read_int_eeprom		d'119'				; read gas_change_depth Gas2
	btfss	sorted_gaslist_active,1			; Apply depth?
	clrf	EEDATA							; No, clear!
	movff	EEDATA,char_I_deco_gas_change4	; Yes!

	read_int_eeprom		d'120'				; read gas_change_depth Gas3
	btfss	sorted_gaslist_active,2			; Apply depth?
	clrf	EEDATA							; No, clear!
	movff	EEDATA,char_I_deco_gas_change3	; Yes!

	read_int_eeprom		d'121'				; read gas_change_depth Gas4
	btfss	sorted_gaslist_active,3			; Apply depth?
	clrf	EEDATA							; No, clear!
	movff	EEDATA,char_I_deco_gas_change2	; Yes!

	read_int_eeprom		d'122'				; read gas_change_depth Gas5
	btfss	sorted_gaslist_active,4			; Apply depth?
	clrf	EEDATA							; No, clear!
	movff	EEDATA,char_I_deco_gas_change1	; Yes!

; Debugger
;	call	enable_rs232	
;	movff	char_I_deco_He_ratio5,TXREG
;	call	rs232_wait_tx				; wait for UART
;	movff	char_I_deco_N2_ratio5,TXREG
;	call	rs232_wait_tx				; wait for UART
;	movff	char_I_deco_He_ratio4,TXREG
;	call	rs232_wait_tx				; wait for UART
;	movff	char_I_deco_N2_ratio4,TXREG
;	call	rs232_wait_tx				; wait for UART
;	movff	char_I_deco_He_ratio3,TXREG
;	call	rs232_wait_tx				; wait for UART
;	movff	char_I_deco_N2_ratio3,TXREG
;	call	rs232_wait_tx				; wait for UART
;	movff	char_I_deco_He_ratio2,TXREG
;	call	rs232_wait_tx				; wait for UART
;	movff	char_I_deco_N2_ratio2,TXREG
;	call	rs232_wait_tx				; wait for UART
;	movff	char_I_deco_He_ratio,TXREG
;	call	rs232_wait_tx				; wait for UART
;	movff	char_I_deco_N2_ratio,TXREG
;	call	rs232_wait_tx				; wait for UART
;	movff	char_I_deco_gas_change5,TXREG
;	call	rs232_wait_tx				; wait for UART
;	movff	char_I_deco_gas_change4,TXREG
;	call	rs232_wait_tx				; wait for UART
;	movff	char_I_deco_gas_change3,TXREG
;	call	rs232_wait_tx				; wait for UART	
;	movff	char_I_deco_gas_change2,TXREG
;	call	rs232_wait_tx				; wait for UART
;	movff	char_I_deco_gas_change,TXREG
;	call	rs232_wait_tx				; wait for UART

	return

reset_decompression_gases:				; reset the deco gas while in NDL
	ostc_debug	'F'		; Sends debug-information to screen if debugmode active
  	clrf	lo
	movff	lo,char_I_deco_gas_change5
	movff	lo,char_I_deco_gas_change4
	movff	lo,char_I_deco_gas_change3
	movff	lo,char_I_deco_gas_change2
 	movff	lo,char_I_deco_gas_change1  ; clear 
	return

calc_deko_divemode2:
	bcf		twosecupdate		

	btfsc	gauge_mode				; ignore decompression calculation in gauge mode
	return
	btfsc	FLAG_apnoe_mode			; ignore decompression calculation in apnoe mode
	return

 	ostc_debug	'B'		; Sends debug-information to screen if debugmode active
	call	divemode_prepare_flags_for_deco
	
	movlw	d'0'
	movff	WREG,char_I_step_is_1min		; 2 second deco mode

	call	deco_calc_hauptroutine		; calc_tissue
	movlb	b'00000001'						; rambank 1 selected
	ostc_debug	'C'		; Sends debug-information to screen if debugmode active

	movff	char_O_first_deco_depth,wait_temp	; copy ceiling to temp register
	tstfsz	wait_temp							; Ceiling<0m?
	bra		calc_deko_divemode3					; Yes!

	btfsc	dekostop_active
	call	PLED_display_ndl_mask			; Clear deco data, display nostop time
	bcf		dekostop_active					; clear flag

	clrf	decodata+0						; for profile memory
	movff	char_O_nullzeit,decodata+1		; nostop time
	
	call	PLED_display_ndl				; display no deco limit
	return

;-----------------------------------------------------------------------------

divemode_prepare_flags_for_deco:	
	movff	amb_pressure+0,int_I_pres_respiration+0		; lo  and copy result to deco routine
	movff	amb_pressure+1,int_I_pres_respiration+1		; hi
	GETCUSTOM8	d'11'                           ; Saturation multiplier %
	movff	WREG,char_I_saturation_multiplier
	GETCUSTOM8	d'12'                           ; Desaturation multiplier %
	movff	WREG,char_I_desaturation_multiplier
	GETCUSTOM8	d'16'                           ; Deco distance to decostop in 1/10 meter for simulation
	movff	WREG,char_I_deco_distance
	GETCUSTOM8	d'29'                           ; Depth Last Deco in meter for simulation
	movff	WREG,char_I_depth_last_deco
	movff   divemins+0,int_I_divemins+0         ; Current dive time.
	movff   divemins+1,int_I_divemins+1
	goto	restart_set_modes_and_flags			; Sets decomode (char_I_deco_model) and flags (again)

calc_deko_divemode3:
	btfss	dekostop_active
	call	PLED_display_deko_mask              ; clear nostop time, display decodata
	bsf		dekostop_active						; Set flag

	movff	char_O_first_deco_depth,decodata+0	; ceiling
	movff	char_O_first_deco_time,decodata+1	; length of first stop in minues

	call	PLED_display_deko					; display decodata
	return						

store_dive_data:						; CF20 seconds gone
	bcf		store_sample				; update only any CF20 seconds
	bsf		update_divetime				; update divemins every CF20 seconds

	btfsc	simulatormode_active		; Are we in simulator mode?
	return								; Yes, discard everything

	btfsc	header_stored				; Header already stored?
	bra		store_dive_data2			; Yes, store only profile data
	bsf		header_stored				; Store header
	
	movff	eeprom_address+0, eeprom_header_address+0	; store startposition
	movff	eeprom_address+1, eeprom_header_address+1	; store startposition

; shift address for header
; the header will be stored after the dive
	incf_eeprom_address	d'47'				; Macro, that adds 8Bit to eeprom_address:2 with banking at 0x8000

store_dive_data2:
	movf	rel_pressure+0,W				; store depth with every sample
	call	write_external_eeprom
	movf	rel_pressure+1,W
	call	write_external_eeprom

;First, find out how many bytes will append to this sample....
	clrf	ProfileFlagByte					; clear number of bytes to append

; Check Extented informations
	decfsz	divisor_temperature,W	; Check divisor
	bra		check_extended1		
	movlw	d'2'				; Information length	
	addwf	ProfileFlagByte,F	; add to ProfileFlagByte
check_extended1:
	decfsz	divisor_deco,W		; Check divisor
	bra		check_extended2		
	movlw	d'2'				; Information length	
	addwf	ProfileFlagByte,F	; add to ProfileFlagByte
check_extended2:
	decfsz	divisor_tank,W		; Check divisor
	bra		check_extended3		
	movlw	d'2'				; Information length	
	addwf	ProfileFlagByte,F	; add to ProfileFlagByte
check_extended3:
	decfsz	divisor_ppo2,W		; Check divisor
	bra		check_extended4		
	movlw	d'3'				; Information length	
	addwf	ProfileFlagByte,F	; add to ProfileFlagByte
check_extended4:
	decfsz	divisor_deco_debug,W; Check divisor
	bra		check_extended5		
	movlw	d'9'				; Information length	
	addwf	ProfileFlagByte,F	; add to ProfileFlagByte
check_extended5:
	decfsz	divisor_nuy2,W		; Check divisor
	bra		check_extended6		
	movlw	d'0'				; Information length	
	addwf	ProfileFlagByte,F	; add to ProfileFlagByte
check_extended6:

; Second, check global event flag
	btfss	event_occured		; Check global event flag
	bra		store_dive_data3	; No Event
	movlw	d'1'
	addwf	ProfileFlagByte,F	; add one byte (The EventByte)

	clrf	EventByte			; reset EventByte

	movf	AlarmType,W			; Type of Alarm Bit 0-3
	addwf	EventByte,F			; Copy to EventByte Bit 0-3
	clrf	AlarmType			; Reset AlarmType
	
; Third, check events and add aditional bytes
	btfss	manual_gas_changed	; Check flag	
	bra		check_event1
	movlw	d'2'				; Information length	
	addwf	ProfileFlagByte,F	; add to ProfileFlagByte
	bsf		EventByte,4			; Also set Flag in EventByte!
check_event1:
	btfss	stored_gas_changed	; Check flag	
	bra		check_event2
	movlw	d'1'				; Information length	
	addwf	ProfileFlagByte,F	; add to ProfileFlagByte
	bsf		EventByte,5			; Also set Flag in EventByte!
check_event2:
	bsf		ProfileFlagByte,7	; Set EventByte Flag in ProfileFlagByte

store_dive_data3:
	movf	ProfileFlagByte,W	; finally, write ProfileFlagByte!
	call	write_external_eeprom

	btfss	event_occured		; Check global event flag (again)
	bra		store_dive_data4	; No Event

; Store the EventByte + additional bytes now
	movf	EventByte,W		
	call	write_external_eeprom

	btfss	manual_gas_changed	; Check flag	
	bra		store_dive_data3a
	read_int_eeprom	d'24'			; % O2 Gas6
	movf	EEDATA,W
	call	write_external_eeprom
	read_int_eeprom	d'25'			; % He Gas6
	movf	EEDATA,W
	call	write_external_eeprom

store_dive_data3a:
	btfss	stored_gas_changed	; Check flag	
	bra		store_dive_data3b			
	movf	active_gas,W		; Store active gas
	call	write_external_eeprom

store_dive_data3b:

store_dive_data4:
	bcf		event_occured		; Clear the global event flag
	bcf		manual_gas_changed	; Clear all events
	bcf		stored_gas_changed	; Clear all events

; Store extended informations
	decfsz	divisor_temperature,F	; Check divisor
	bra		store_extended1	
	rcall	store_dive_temperature
store_extended1:
	decfsz	divisor_deco,F		; Check divisor
	bra		store_extended2	
	rcall	store_dive_decodata
store_extended2:
	decfsz	divisor_tank,F		; Check divisor
	bra		store_extended3	
	rcall	store_dive_tankdata
store_extended3:
	decfsz	divisor_ppo2,F		; Check divisor
	bra		store_extended4	
	rcall	store_dive_ppo2
store_extended4:
	decfsz	divisor_deco_debug,F; Check divisor
	bra		store_extended5	
	rcall	store_dive_decodebug
store_extended5:
	decfsz	divisor_nuy2,F		; Check divisor
	bra		store_extended6	
	rcall	store_dive_nuy2
store_extended6:

; The next block is required to take care of "store never"
	btfsc	divisor_temperature,7	; Test highest Bit (Register must have been zero before the "decfsz" command!)
	clrf	divisor_temperature		; And clear register again, so it will never reach zero...
	btfsc	divisor_deco,7			; Test highest Bit (Register must have been zero before the "decfsz" command!)
	clrf	divisor_deco			; And clear register again, so it will never reach zero...
	btfsc	divisor_tank,7			; Test highest Bit (Register must have been zero before the "decfsz" command!)
	clrf	divisor_tank			; And clear register again, so it will never reach zero...
	btfsc	divisor_ppo2,7			; Test highest Bit (Register must have been zero before the "decfsz" command!)
	clrf	divisor_ppo2			; And clear register again, so it will never reach zero...
	btfsc	divisor_deco_debug,7	; Test highest Bit (Register must have been zero before the "decfsz" command!)
	clrf	divisor_deco_debug		; And clear register again, so it will never reach zero...
	btfsc	divisor_nuy2,7			; Test highest Bit (Register must have been zero before the "decfsz" command!)
	clrf	divisor_nuy2			; And clear register again, so it will never reach zero...

	ostc_debug	'D'		; Sends debug-information to screen if debugmode active
	return				; Done.
	
store_dive_nuy2:
	GETCUSTOM8	d'26'
	movwf	divisor_nuy2			; Reload divisor from CF
	return

store_dive_decodebug:
    ; Dump 9 bytes, int_O_DBS_bitfield .. char_O_NDL_at_20mtr
    lfsr    FSR2, int_O_DBS_bitfield
    movf    POSTINC2,W
	call	write_external_eeprom		; Store in EEPROM
    movf    POSTINC2,W
	call	write_external_eeprom		; Store in EEPROM
    movf    POSTINC2,W
	call	write_external_eeprom		; Store in EEPROM
    movf    POSTINC2,W
	call	write_external_eeprom		; Store in EEPROM
    movf    POSTINC2,W
	call	write_external_eeprom		; Store in EEPROM
    movf    POSTINC2,W
	call	write_external_eeprom		; Store in EEPROM
    movf    POSTINC2,W
	call	write_external_eeprom		; Store in EEPROM
    movf    POSTINC2,W
	call	write_external_eeprom		; Store in EEPROM
    movf    POSTINC2,W
	call	write_external_eeprom		; Store in EEPROM
	GETCUSTOM8	d'25'
	movwf	divisor_deco_debug			; Reload divisor from CF
	return

store_dive_ppo2:
	movlw	0x00			; Dummy
	call	write_external_eeprom
	movlw	0x00			; Dummy
	call	write_external_eeprom
	movlw	0x00			; Dummy
	call	write_external_eeprom
	GETCUSTOM8	d'24'
	movwf	divisor_ppo2			; Reload divisor from CF
	return

store_dive_tankdata:
	movlw	d'0'				; Dummy Tank1
	call	write_external_eeprom
	movlw	d'0'				; Dummy Tank2
	call	write_external_eeprom
	GETCUSTOM8	d'23'
	movwf	divisor_tank			; Reload divisor from CF
	return

store_dive_decodata:
	movf	decodata+0,W				; =0:no stop dive, if in deco mode: ceiling in m
	call	write_external_eeprom
	movf	decodata+1,W				; no stop time of length of first stop
	call	write_external_eeprom
	GETCUSTOM8	d'22'
	movwf	divisor_deco			; Reload divisor from CF
	return

store_dive_temperature:
	movf	temperature+0,W				; append temperature to current sample!
	call	write_external_eeprom
	movf	temperature+1,W
	call	write_external_eeprom
	GETCUSTOM8	d'21'
	movwf	divisor_temperature			; Reload divisor from CF
	return

calc_velocity:								; called every two seconds
	btfss	divemode						
	bra		do_not_display_velocity			; display velocity only in divemode

calc_velocity2:
	movff	amb_pressure+0,sub_a+0
	movff	amb_pressure+1,sub_a+1
	movff	last_pressure+0,sub_b+0
	movff	last_pressure+1,sub_b+1
	movff	amb_pressure+0,last_pressure+0	; store old value for velocity
	movff	amb_pressure+1,last_pressure+1

	call	sub16						; sub_c = amb_pressure - last_pressure

	movff	sub_c+0,xA+0
	movff	sub_c+1,xA+1
	movlw	d'39'			;77 when called every second....
	movwf	xB+0
	clrf	xB+1
	call	mult16x16					; differential pressure in mBar*77...
	movff	xC+0,divA+0
	movff	xC+1,divA+1
	movlw	d'7'
	movwf	divB
	call	div16						; devided by 2^7 equals velocity in m/min

	movlw	d'99'
	cpfsgt	divA
	bra		calc_velocity3
	movwf	divA						; divA=99

calc_velocity3:

	GETCUSTOM8	d'5'					; threshold for display vertical velocity
	subwf	divA+0,W					; 

	btfss	STATUS,C
	bra		do_not_display_velocity

update_velocity:
	bsf		display_velocity
	call	PLED_display_velocity
	return

do_not_display_velocity:
	btfss	display_velocity			; Velocity was not displayed, do not delete
	return
		
	bcf		display_velocity			; Velocity was displayed, delete velocity now
	call	PLED_display_velocity_clear
	return

check_ppO2:								; check current ppO2 and display warning if required
	btfsc		FLAG_const_ppO2_mode		; ignore in ppO2 mode....
	return

check_ppO2_bail:						; In CC mode but bailout active!
	movff		amb_pressure+0,xA+0
	movff		amb_pressure+1,xA+1
	movlw		d'10'
	movwf		xB+0
	clrf		xB+1
	call		div16x16				; xC=p_amb/10
	movff		xC+0,xA+0
	movff		xC+1,xA+1
	movff		char_I_O2_ratio,xB+0
	clrf		xB+1
	call		mult16x16				; char_I_O2_ratio * p_amb/10

; Check very high ppO2 manually
	tstfsz		xC+2					; char_I_O2_ratio * p_amb/10 > 65536, ppO2>6,55Bar?
	bra			check_ppO2_bail2		; Yes, display Value!

; Check if ppO2 should be displayed
	movff		xC+0,sub_b+0
	movff		xC+1,sub_b+1
	GETCUSTOM8	d'19'					; ppo2_display_high
	mullw		d'100'					; ppo2_display_high*100
	movff		PRODL,sub_a+0
	movff		PRODH,sub_a+1
	call		sub16					
	bcf			ppO2_show_value		; clear flag
	btfsc		neg_flag
	bsf			ppO2_show_value		; set flag if required

;check if we are within our warning thresholds!
	bcf			ppO2_warn_value		; clear flag
	movff		xC+0,sub_b+0
	movff		xC+1,sub_b+1
	GETCUSTOM8	d'18'					; ppo2_warning_high
	mullw		d'100'					; ppo2_warning_high*100
	movff		PRODL,sub_a+0
	movff		PRODH,sub_a+1
	call		sub16					
	btfss		neg_flag
	bra			check_ppO2_0		; Not too high

check_ppO2_bail2:
	bsf			ppO2_show_value		; set flag if required
	bsf			ppO2_warn_value		; set flag 
	movlw		d'5'				; Type of Alarm
	movwf		AlarmType			; Copy to Alarm Register
	bsf			event_occured		; Set Event Flag

check_ppO2_0:
	movff		xC+0,sub_b+0
	movff		xC+1,sub_b+1
	GETCUSTOM8	d'17'				; ppo2_warning_low
	mullw		d'100'				; ppo2_warning_low*100
	movff		PRODL,sub_a+0
	movff		PRODH,sub_a+1
	call		sub16					
	btfsc		neg_flag
	bra			check_ppO2_1		; Not too low

	bsf			ppO2_warn_value		; set flag 
	bsf			ppO2_show_value		; show ppO2 if below threshold!
	movlw		d'4'				; Type of Alarm
	movwf		AlarmType			; Copy to Alarm Register
	bsf			event_occured		; Set Event Flag

check_ppO2_1:
	btfsc		ppO2_show_value		; show value?
	bra			check_ppO2_2		; yes!

	btfss		ppO2_display_active	; is the value displayed?
	bra			check_ppO2_3		; No, so clear not required
	
	call		PLED_show_ppO2_clear; Clear ppO2 value
	bcf			ppO2_display_active	; clear flag
	bra			check_ppO2_3		; done

check_ppO2_2:
	call		PLED_show_ppO2		; Display ppO2 (stored in xC)
	bsf			ppO2_display_active	; Set flag		

check_ppO2_3:
	return		; done


check_gas_change:					; Checks if a better gas should be selected (by user)
	bcf		better_gas_available	;=1: A better gas is available and a gas change is advised in divemode
	
	movff	rel_pressure+0,xA+0			
	movff	rel_pressure+1,xA+1
	movlw	d'100'
	movwf	xB+0
	clrf	xB+1
	call	div16x16				; compute depth in full m -> result in xC+0

check_gas_change1:					; check gas1 
	read_int_eeprom		d'27'		; read flag register
	btfss	EEDATA,0				; check active flag
	bra		check_gas_change2		; skip inactive gases!
	movlw	d'1'
	cpfseq	active_gas				; is this gas currently selected?
	bra		check_gas_change1x		; No...
	bra		check_gas_change2		; Yes, skip depth check
check_gas_change1x:	
	read_int_eeprom		d'28'		; read gas_change_depth
	movlw	d'3'
	cpfsgt	EEDATA					; Change depth>3m?
	bra		check_gas_change2		; No, Change depth not deep enough, skip!
	movf	xC+0,W					; load depth in m into WREG
	cpfsgt	EEDATA					; gas_change_depth < current depth?
	bra		check_gas_change2		; No, check next gas
	movlw	d'3'
	subwf	EEDATA,W				; Change depth-3m
	cpfslt	xC+0					; current depth<Change depth-3m?
	bsf		better_gas_available	;=1: A better gas is available and a gas change is advised in divemode

check_gas_change2:					; check gas2
	read_int_eeprom		d'27'		; read flag register
	btfss	EEDATA,1				; check active flag
	bra		check_gas_change3		; skip inactive gases!
	movlw	d'2'
	cpfseq	active_gas				; is this gas currently selected?
	bra		check_gas_change2x		; No...
	bra		check_gas_change3		; Yes, skip depth check
check_gas_change2x:	
	read_int_eeprom		d'29'		; read gas_change_depth
	movlw	d'3'
	cpfsgt	EEDATA					; Change depth>3m?
	bra		check_gas_change3		; No, Change depth not deep enough, skip!
	movf	xC+0,W					; load depth in m into WREG
	cpfsgt	EEDATA					; gas_change_depth < current depth?
	bra		check_gas_change3		; No, check next gas
	movlw	d'3'
	subwf	EEDATA,W				; Change depth-3m
	cpfslt	xC+0					; current depth<Change depth-3m?
	bsf		better_gas_available	;=1: A better gas is available and a gas change is advised in divemode

check_gas_change3:					; check gas3
	read_int_eeprom		d'27'		; read flag register
	btfss	EEDATA,2				; check active flag
	bra		check_gas_change4		; skip inactive gases!
	movlw	d'3'
	cpfseq	active_gas				; is this gas currently selected?
	bra		check_gas_change3x		; No...
	bra		check_gas_change4		; Yes, skip depth check
check_gas_change3x:	
	read_int_eeprom		d'30'		; read gas_change_depth
	movlw	d'3'
	cpfsgt	EEDATA					; Change depth>3m?
	bra		check_gas_change4		; No, Change depth not deep enough, skip!
	movf	xC+0,W					; load depth in m into WREG
	cpfsgt	EEDATA					; gas_change_depth < current depth?
	bra		check_gas_change4		; No, check next gas
	movlw	d'3'
	subwf	EEDATA,W				; Change depth-3m
	cpfslt	xC+0					; current depth<Change depth-3m?
	bsf		better_gas_available	;=1: A better gas is available and a gas change is advised in divemode

check_gas_change4:					; check gas4
	read_int_eeprom		d'27'		; read flag register
	btfss	EEDATA,3				; check active flag
	bra		check_gas_change5		; skip inactive gases!
	movlw	d'4'
	cpfseq	active_gas				; is this gas currently selected?
	bra		check_gas_change4x		; No...
	bra		check_gas_change5		; Yes, skip depth check
check_gas_change4x:	
	read_int_eeprom		d'31'		; read gas_change_depth
	movlw	d'3'
	cpfsgt	EEDATA					; Change depth>3m?
	bra		check_gas_change5		; No, Change depth not deep enough, skip!
	movf	xC+0,W					; load depth in m into WREG
	cpfsgt	EEDATA					; gas_change_depth < current depth?
	bra		check_gas_change5		; No, check next gas
	movlw	d'3'
	subwf	EEDATA,W				; Change depth-3m
	cpfslt	xC+0					; current depth<Change depth-3m?
	bsf		better_gas_available	;=1: A better gas is available and a gas change is advised in divemode

check_gas_change5:					; check gas5
	read_int_eeprom		d'27'		; read flag register
	btfss	EEDATA,4				; check active flag
	bra		check_gas_change6		; skip inactive gases!
	movlw	d'5'
	cpfseq	active_gas				; is this gas currently selected?
	bra		check_gas_change5x		; No...
	bra		check_gas_change6		; Yes, skip depth check
check_gas_change5x:	
	read_int_eeprom		d'32'		; read gas_change_depth
	movlw	d'3'
	cpfsgt	EEDATA					; Change depth>3m?
	bra		check_gas_change6		; No, Change depth not deep enough, skip!
	movf	xC+0,W					; load depth in m into WREG
	cpfsgt	EEDATA					; gas_change_depth < current depth?
	bra		check_gas_change6		; No, check next gas
	movlw	d'3'
	subwf	EEDATA,W				; Change depth-3m
	cpfslt	xC+0					; current depth<Change depth-3m?
	bsf		better_gas_available	;=1: A better gas is available and a gas change is advised in divemode

check_gas_change6:			;Done
	call	PLED_active_gas_divemode; Display gas, if required (and with "*" if irequired...)
	return

calculate_noflytime:
	; calculate nofly time
	movff	int_O_desaturation_time+0,xA+0
	movff	int_O_desaturation_time+1,xA+1
	tstfsz	xA+0			; Desat=0?
	bra		calculate_noflytime2
	tstfsz	xA+1			; Desat=0?
	bra		calculate_noflytime2
	; Desaturation time = zero
	movlw	d'1'
	movwf	nofly_time+0			; Clear nofly time
	clrf	nofly_time+1			; Clear nofly time
	bcf		nofly_active			; Clear flag
	return

calculate_noflytime2:	
	movff	xA+0,int_I_temp+0
	movff	xA+1,int_I_temp+1
	GETCUSTOM8 	.13					; nofly_time_ratio
	movff	WREG,char_I_temp
	ostc_debug	'K'		; Sends debug-information to screen if debugmode active
	call	deco_calc_percentage
	movlb	b'00000001'				; select ram bank 1
	ostc_debug	'L'		; Sends debug-information to screen if debugmode active
	movff	int_I_temp+0,xA+0
	movff	int_I_temp+1,xA+1
	tstfsz	xA+0			; Desat=0?
	bra		calculate_noflytime_2_final
	tstfsz	xA+1			; Desat=0?
	bra		calculate_noflytime_2_final
	; noflytime = zero
	movlw	d'1'
	movwf	nofly_time+0			; Clear nofly time
	clrf	nofly_time+1			; Clear nofly time
	bcf		nofly_active			; Clear flag
	return
calculate_noflytime_2_final:
	movff	xA+0,nofly_time+0
	movff	xA+1,nofly_time+1
	bsf		nofly_active			; Set flag
	return

end_dive:
	btfss	realdive					; dive longer then one minute
	goto	end_dive_common				; No, discard everything

	btfsc	simulatormode_active		; Are we in simulator mode?
	goto	end_dive_common				; Yes, discard everything

	; Dive finished (and longer then one minute or Apnoe timeout occured)

	btfsc	FLAG_apnoe_mode			; Calc max. depth (again) for very short apnoe dives
	rcall	apnoe_calc_maxdepth

	; calculate desaturation time
	movff	last_surfpressure_30min+0,int_I_pres_respiration+0		; copy surface air pressure to deco routine
	movff	last_surfpressure_30min+1,int_I_pres_respiration+1		; 30min old values 

	GETCUSTOM8	d'12'				; Desaturation multiplier %
	movwf	wait_temp
	movff	wait_temp,char_I_desaturation_multiplier

	ostc_debug	'G'		; Sends debug-information to screen if debugmode active
	call	deco_calc_desaturation_time	; calculate desaturation time
	movlb	b'00000001'						; select ram bank 1
	rcall	calculate_noflytime				; Calc NoFly time
	ostc_debug	'H'		; Sends debug-information to screen if debugmode active
										; store header and ...
	movlw	0xFD						; .... End-of-Profile Bytes
	call	write_external_eeprom
	movlw	0xFD
	call	write_external_eeprom
	movlw	0xFE						; This positon will be overwritten for the next profile
	call	write_external_eeprom			; and is required to find the newest dive after a firmware reset

	movff	eeprom_header_address+0, eeprom_address+0	; set header adress
	movff	eeprom_header_address+1, eeprom_address+1	; write header

	movlw	0xFA						; Header start
	call	write_external_eeprom
	movlw	0xFA
	call	write_external_eeprom
	movlw	logbook_profile_version			; Defined in definitions_vxyy.asm
	call	write_external_eeprom
	movf	month,W					; Date
	call	write_external_eeprom
	movf	day,W
	call	write_external_eeprom
	movf	year,W
	call	write_external_eeprom
	movf	hours,W					; End of dive time
	call	write_external_eeprom
	movf	mins,W
	call	write_external_eeprom

	btfss	FLAG_apnoe_mode				; Store apnoe max or normal max (Which is only max from the last descent)
	bra		end_dive1					; Store normal depth

	movff	apnoe_max_pressure+0,lo
	movff	apnoe_max_pressure+1,hi
	call	adjust_depth_with_salinity			; computes salinity setting into lo:hi [mBar]
	movff	lo,apnoe_max_pressure+0
	movff	hi,apnoe_max_pressure+1
	
	movf	apnoe_max_pressure+0,W		; Max. depth
	call	write_external_eeprom
	movf	apnoe_max_pressure+1,W
	call	write_external_eeprom
	bra		end_dive2					; skip
		
end_dive1:
	movff	max_pressure+0,lo
	movff	max_pressure+1,hi
	call	adjust_depth_with_salinity			; computes salinity setting into lo:hi [mBar]
	movff	lo,max_pressure+0
	movff	hi,max_pressure+1
	
	movf	max_pressure+0,W			; Max. depth
	call	write_external_eeprom
	movf	max_pressure+1,W
	call	write_external_eeprom

end_dive2:
	movf	divemins+0,W				; divetime minutes
	call	write_external_eeprom
	movf	divemins+1,W
	call	write_external_eeprom
	movf	divesecs,W					; divetime seconds
	call	write_external_eeprom
	movf	mintemp+0,W					; minimum temperature
	call	write_external_eeprom
	movf	mintemp+1,W		
	call	write_external_eeprom
	movf	last_surfpressure_30min+0,W		; airpressure before dive
	call	write_external_eeprom
	movf	last_surfpressure_30min+1,W		
	call	write_external_eeprom
	movff	int_O_desaturation_time+0,lo			; 
	movff	int_O_desaturation_time+1,hi
	movf	lo,W						; desaturation time in minutes
	call	write_external_eeprom
	movf	hi,W						; 
	call	write_external_eeprom

	; Gases....
	read_int_eeprom 	d'6'		; Read byte (stored in EEDATA)
	movf	EEDATA,W
	call	write_external_eeprom
	read_int_eeprom 	d'7'		; Read byte (stored in EEDATA)
	movf	EEDATA,W
	call	write_external_eeprom

	read_int_eeprom 	d'10'		; Read byte (stored in EEDATA)
	movf	EEDATA,W
	call	write_external_eeprom
	read_int_eeprom 	d'11'		; Read byte (stored in EEDATA)
	movf	EEDATA,W
	call	write_external_eeprom

	read_int_eeprom 	d'14'		; Read byte (stored in EEDATA)
	movf	EEDATA,W
	call	write_external_eeprom
	read_int_eeprom 	d'15'		; Read byte (stored in EEDATA)
	movf	EEDATA,W
	call	write_external_eeprom

	read_int_eeprom 	d'18'		; Read byte (stored in EEDATA)
	movf	EEDATA,W
	call	write_external_eeprom
	read_int_eeprom 	d'19'		; Read byte (stored in EEDATA)
	movf	EEDATA,W
	call	write_external_eeprom

	read_int_eeprom 	d'22'		; Read byte (stored in EEDATA)
	movf	EEDATA,W
	call	write_external_eeprom
	read_int_eeprom 	d'23'		; Read byte (stored in EEDATA)
	movf	EEDATA,W
	call	write_external_eeprom

	read_int_eeprom	d'24'			; % O2 Gas6
	movf	EEDATA,W
	call	write_external_eeprom
	read_int_eeprom	d'25'			; % He Gas6
	movf	EEDATA,W
	call	write_external_eeprom
	read_int_eeprom	d'33'			; start gas
	movf	EEDATA,W
	call	write_external_eeprom

	movlw	softwareversion_x			; Firmware version
	call	write_external_eeprom
	movlw	softwareversion_y
	call	write_external_eeprom
	movf	batt_voltage+0,W			; Battery voltage 
	call	write_external_eeprom
	movf	batt_voltage+1,W
	call	write_external_eeprom

	GETCUSTOM8	d'20'					; sampling rate in WREG
	btfsc	FLAG_apnoe_mode				; Apnoe mode?
	movlw	d'1'						; Apnoe sampling rate
	call	write_external_eeprom

	movlw	d'2'		; information size temperature
	movwf	temp1		; copy to bits 0-3
	swapf	temp1,F		; swap nibbels 0-3 with 4-7
	GETCUSTOM8	d'21'	; Divisor temperature
	addwf	temp1,W		; copy to bits 0-3, result in WREG
	call	write_external_eeprom

	movlw	d'2'		; information size deco
	movwf	temp1		; copy to bits 0-3
	swapf	temp1,F		; swap nibbels 0-3 with 4-7
	GETCUSTOM8	d'22'	; Divisor deco
	addwf	temp1,W		; copy to bits 0-3, result in WREG
	call	write_external_eeprom

	movlw	d'2'		; information size tank
	movwf	temp1		; copy to bits 0-3
	swapf	temp1,F		; swap nibbels 0-3 with 4-7
	GETCUSTOM8	d'23'					; Divisor Tank
	addwf	temp1,W		; copy to bits 0-3, result in WREG
	call	write_external_eeprom

	movlw	d'3'		; information size pp02
	movwf	temp1		; copy to bits 0-3
	swapf	temp1,F		; swap nibbels 0-3 with 4-7
	GETCUSTOM8	d'24'	; Divisor pp02
	addwf	temp1,W		; copy to bits 0-3, result in WREG
	call	write_external_eeprom

	movlw	d'9'		; information size Decodebug
	movwf	temp1		; copy to bits 0-3
	swapf	temp1,F		; swap nibbels 0-3 with 4-7
	GETCUSTOM8	d'25'	; Divisor Decodebug
	addwf	temp1,W		; copy to bits 0-3, result in WREG
	call	write_external_eeprom

	movlw	d'0'		; information size nuy2
	movwf	temp1		; copy to bits 0-3
	swapf	temp1,F		; swap nibbels 0-3 with 4-7
	GETCUSTOM8	d'26'	; Divisor nuy2
	addwf	temp1,W		; copy to bits 0-3, result in WREG
	call	write_external_eeprom

	read_int_eeprom	d'26'			; Read Salinity from EEPROM
	movf	EEDATA,W
	call	write_external_eeprom	; Store Salinity to Dive
	
	GETCUSTOM8	d'33'				; GF_hi
	movwf	temp1
	swapf	temp1,F					; GF_hi -> Bit7-4
	GETCUSTOM8	d'32'				; GF_lo
	addwf	temp1,W					; Add GF_lo -> Bit 3-0
	call	write_external_eeprom	; Stores GF_hi and GF_lo

	movlw	0xFB						; Header stop
	call	write_external_eeprom
	movlw	0xFB
	call	write_external_eeprom
	
	; Increase total dive counter
	read_int_eeprom 	d'2'		; Read byte (stored in EEDATA)
	movff	EEDATA,temp1			; Low byte
	read_int_eeprom 	d'3'		; Read byte (stored in EEDATA)
	movff	EEDATA,temp2			; high byte
	bcf		STATUS,C
	movlw	d'1'
	addwf	temp1
	movlw	d'0'
	addwfc	temp2				
	movff	temp1,EEDATA
	write_int_eeprom	d'2'			; write byte stored in EEDATA
	movff	temp2,EEDATA
	write_int_eeprom	d'3'			; write byte stored in EEDATA

	GETCUSTOM15	.28							; Logbook Offset -> lo, hi
	tstfsz		lo							; lo=0?
	bra		change_logbook_offset1		; No, adjust offset	
	tstfsz		hi						; hi=0?
	bra		change_logbook_offset1		; No, adjust offset
	bra		change_logbook_offset2		; lo=0 and hi=0 -> skip Offset routine
change_logbook_offset1:
	movlw	d'1'
	addwf	lo
	movlw	d'0'
	addwfc	hi
	movlw	d'112'					; CF28 *4 Bytes...
	addlw	0x82
	movwf	EEADR
	movff	lo,EEDATA
	call	write_eeprom			; Lowbyte
	movlw	d'112'					; CF28 *4 Bytes...
	addlw	0x83
	movwf	EEADR
	movff	hi,EEDATA
	call	write_eeprom			; Highbyte 

change_logbook_offset2:
	bcf		LED_blue
	clrf	surface_interval+0
	clrf	surface_interval+1		; Clear surface interval timer

end_dive_common:
	bcf		simulatormode_active		; if we were in simulator mode

	btfsc	restore_deco_data			; Restore decodata?
	call	simulator_restore_tissue_data		; Yes!

	goto	surfloop					; and return to surfaceloop

timeout_divemode:
	btfss	realdive					; Dive longer then one minute
	return
	
	btfsc	FLAG_apnoe_mode				; In Apnoe mode?
	bra		timeout_divemode2			; Yes, use CF30 [min] for timeout

	btfsc	simulatormode_active		; In Simulator mode?
	bra		timeout_divemode3			; Yes, use fixed 5 seconds timeout			
	
	bcf		divemode
	incf	timeout_counter,F
	GETCUSTOM8	d'2'					; diveloop_timeout
	addlw	d'2'						; adds two seconds in case timout=zero!
	btfsc	STATUS,C					; > 255?
	movlw	d'255'						; Set to 255...
	decf	WREG,F						; Limit to 254
	cpfsgt	timeout_counter
	bsf		divemode
	return

timeout_divemode2:
	incf	timeout_counter,F			; seconds...
	movlw	d'60'
	cpfseq	timeout_counter				; timeout_counter=60?
	return								; No.

	clrf	timeout_counter
	bcf		divemode
	incf	apnoe_timeout_counter,F
	GETCUSTOM8	d'30'					; apnoe timeout [min]
	cpfseq	apnoe_timeout_counter
	bsf		divemode
	return

timeout_divemode3:
	bcf		divemode
	incf	timeout_counter,F
	movlw	d'5'						; Fixed timeout of 5 seconds
	cpfsgt	timeout_counter
	bsf		divemode
	return

update_divemode1:						; update any second
	call	set_dive_modes				; tests if depth>threshold
	
	btfsc	divemode
	call	set_max_depth				; update max. depth if required

	btfsc	divemode
	call	set_min_temp				; store min. temp if required

	bcf		temp_changed			; Display temperature?
	movf	temperature+0,W
	cpfseq	last_temperature+0
	bsf		temp_changed			; Yes
	movf	temperature+1,W
	cpfseq	last_temperature+1
	bsf		temp_changed			; Yes
	btfsc	temp_changed	
	call	PLED_temp_divemode		; Displays temperature

	bcf		pres_changed			; Display new depth?
	movf	amb_pressure+0,W
	cpfseq	last_pressure+0
	bsf		pres_changed			; Yes
	movf	amb_pressure+1,W
	cpfseq	last_pressure+1
	bsf		pres_changed			; Yes

	btfsc	simulatormode_active	; always update depth when in simulator mode
	bsf		pres_changed				

	btfsc	pres_changed	
	call	PLED_depth					; Displays new depth
	return

update_divemode60:					; update any minute
	call	get_battery_voltage			; gets battery voltage
	call	set_powersafe				; red LED blinking if battery is low
	call	PLED_max_pressure			; No, use normal max. depth
	call	check_temp_extrema			; check for new temperature extremas
	call	customview_minute			; Do every-minute tasks for the custom view area
	bcf		oneminupdate
	return

set_max_depth:
	movff	max_pressure+0,sub_a+0
	movff	max_pressure+1,sub_a+1
	movff	rel_pressure+0,sub_b+0
	movff	rel_pressure+1,sub_b+1
	call	sub16						; sub_c = sub_a - sub_b
								; max_pressure<rel_pressure -> neg_flag=1
								; rel_pressure<=max_pressure -> neg_flag=0
	btfss	neg_flag	
	return
								;max_pressure<rel_pressure
	movff	rel_pressure+0,max_pressure+0
	movff	rel_pressure+1,max_pressure+1
	call	PLED_max_pressure			; No, use normal max. depth
	return

set_min_temp:
	movff	mintemp+0,sub_a+0
	movff	mintemp+1,sub_a+1
	movff	temperature+0,sub_b+0
	movff	temperature+1,sub_b+1
	call	sub16						; sub_c = sub_a - sub_b
								; mintemp<T -> neg_flag=1
								; T<=mintemp -> neg_flag=0
	btfsc	neg_flag	
	return
								;mintemp>=T
	movff	temperature+0,mintemp+0
	movff	temperature+1,mintemp+1
	return

set_dive_modes:
	bcf		divemode2				; Stop time

	GETCUSTOM8	.0					; loads dive_threshold in WREG
	movwf	sub_a+0					; dive_treshold is in cm
	clrf	sub_a+1

	movff	rel_pressure+0,sub_b+0
	movff	rel_pressure+1,sub_b+1
		
	call	sub16						; sub_c = sub_a - sub_b
	
	btfss	neg_flag	
	bra		set_dive_modes2				; too shallow (rel_pressure<dive_threshold)

	btfsc	realdive					; Dive longer than one minute?
	clrf 	timeout_counter

	bsf		divemode
	bsf		divemode2				; displayed divetime is running
	return

set_dive_modes2:
	btfss	realdive					; dive longer then one minute?
	bcf		divemode					; no -> this was no real dive
	return

set_powersafe:
	btfsc	low_battery_state		; battery warning alread active?
	bra		set_powersafe2			; Yes, but is it still required?
									; battery voltage in mV (value*256+Lowbyte=actual treshold)
	movlw	d'12'					; 3,328V
	cpfsgt	batt_voltage+1
	bra		set_powersafe1
	return

set_powersafe1:
	movlw	d'7'					; Type of Alarm (Battery Low)
	movwf	AlarmType				; Copy to Alarm Register
	bsf		event_occured			; Set Event Flag
	bsf		low_battery_state		; set flag for battery warning
	return							; return

set_powersafe2:
	movlw	d'13'					; 3,584V
	cpfsgt	batt_voltage+1
	bra		set_powersafe1			; Still to low
	bcf		low_battery_state		; clear flag for battery warning mode
	return

calc_average_depth:
	btfsc	reset_average_depth		; Reset the Avewrage depth?
	rcall	reset_average1			; Reset the resettable average depth

	; 1. Add new 2xdepth to the Sum of depths registers
	movff	rel_pressure+0,b0_lo
	movff	rel_pressure+1,b0_hi	; Buffer...

	movf	b0_lo,w
	addwf	average_depth_hold+0,F
	movf	b0_hi,w
	addwfc	average_depth_hold+1,F
	movlw	d'0'
	addwfc	average_depth_hold+2,F
	addwfc	average_depth_hold+3,F ; Will work up to 9999mBar*60*60*24=863913600mBar

	movf	b0_lo,w
	addwf	average_depth_hold+0,F
	movf	b0_hi,w
	addwfc	average_depth_hold+1,F
	movlw	d'0'
	addwfc	average_depth_hold+2,F
	addwfc	average_depth_hold+3,F ; Will work up to 9999mBar*60*60*24=863913600mBar

; Do the same for the _total registers (Non-Resettable)
	movf	b0_lo,w
	addwf	average_depth_hold_total+0,F
	movf	b0_hi,w
	addwfc	average_depth_hold_total+1,F
	movlw	d'0'
	addwfc	average_depth_hold_total+2,F
	addwfc	average_depth_hold_total+3,F ; Will work up to 9999mBar*60*60*24=863913600mBar

	movf	b0_lo,w
	addwf	average_depth_hold_total+0,F
	movf	b0_hi,w
	addwfc	average_depth_hold_total+1,F
	movlw	d'0'
	addwfc	average_depth_hold_total+2,F
	addwfc	average_depth_hold_total+3,F ; Will work up to 9999mBar*60*60*24=863913600mBar

	; 2. Compute Average Depth on base of average_divesecs:2
	movff	average_divesecs+0,xB+0
	movff	average_divesecs+1,xB+1		; Copy
	movff	average_depth_hold+0,xC+0
	movff	average_depth_hold+1,xC+1
	movff	average_depth_hold+2,xC+2
	movff	average_depth_hold+3,xC+3

	call	div32x16 	; xC:4 / xB:2 = xC+3:xC+2 with xC+1:xC+0 as remainder
	movff	xC+0,avr_rel_pressure+0
	movff	xC+1,avr_rel_pressure+1

	; Compute Total Average Depth on base of divemins:2 and divesecs
	movff	divemins+0,xA+0
	movff	divemins+1,xA+1
	movlw	d'60'
	movwf	xB+0
	clrf	xB+1
	call	mult16x16				; xC:4=xA:2*xB:2
	movf	divesecs,W
	addwf	xC+0,F
	movlw	d'0'
	addwfc	xC+1,F
	movlw	d'3'					; 2+1
	btfss	divesecs,0				; divesecs even?
	movlw	d'2'					; Yes, do not add +1
	addwf	xC+0,F
	movlw	d'0'
	addwfc	xC+1,F
	; Ignore xC+2 and xC+3. Total Average will only work up to divetime=1092:16
	movff	xC+0,xB+0
	movff	xC+1,xB+1		; Copy
	movff	average_depth_hold_total+0,xC+0
	movff	average_depth_hold_total+1,xC+1
	movff	average_depth_hold_total+2,xC+2
	movff	average_depth_hold_total+3,xC+3

	call	div32x16 	; xC:4 / xB:2 = xC+3:xC+2 with xC+1:xC+0 as remainder
	movff	xC+0,avr_rel_pressure_total+0
	movff	xC+1,avr_rel_pressure_total+1

	return
	
reset_average1:
	clrf	average_depth_hold+0
	clrf	average_depth_hold+1
	clrf	average_depth_hold+2
	clrf	average_depth_hold+3		; Clear average depth register
	movlw	d'2'
	movwf	average_divesecs+0
	clrf	average_divesecs+1
	bcf		reset_average_depth			; Clear flag
	return

diveloop_boot:	
	ostc_debug	'Q'		; Sends debug-information to screen if debugmode active
	clrf	max_pressure+0				; clear some variables
	clrf	max_pressure+1

	clrf	avr_rel_pressure+0
	clrf	avr_rel_pressure+1

	call	PLED_brightness_low
	read_int_eeprom	d'90'				; Brightness offset? (Dim>0, Normal = 0)
	movlw	d'0'
	cpfsgt	EEDATA
	call	PLED_brightness_full

	movlw	d'1'
	movwf	apnoe_max_pressure+0
	clrf	apnoe_max_pressure+1
	clrf	apnoe_surface_mins			
	clrf	apnoe_surface_secs		
	clrf	apnoe_mins
	clrf	apnoe_secs
	clrf	divemins+0
	clrf	divemins+1
	clrf	menupos3
	bcf		menu3_active
	clrf	divesecs
	clrf	samplesecs
	clrf	apnoe_timeout_counter		; timeout in minutes
	clrf 	timeout_counter				; takes care of the timeout
	clrf 	timeout_counter2			; Here: counts to six, then store deco data and temperature
	clrf	AlarmType					; Clear all alarms
	bcf		event_occured				; clear flag
	rcall	reset_average1				; Reset the resettable average depth
	clrf	average_depth_hold_total+0
	clrf	average_depth_hold_total+1
	clrf	average_depth_hold_total+2
	clrf	average_depth_hold_total+3	; Clear Non-Resettable Average
	bcf		depth_greater_100m			; clear flag
	setf	last_diluent				; to be displayed after first calculation (range: 0 to 100 [%])
	bcf		dekostop_active	
	bcf		is_bailout					;=1: CC mode, but bailout active!		
	bcf		better_gas_available	;=1: A better gas is available and a gas change is advised in divemode
	
	call	get_free_EEPROM_location	; get last position in external EEPROM, may be up to 2 secs!

	movff	last_surfpressure_30min+1,int_I_pres_surface+1	; HIGH copy surfacepressure to deco routine
	movff	last_surfpressure_30min+0,int_I_pres_surface+0	; LOW copy surfacepressure to deco routine
	movff	temperature+0,mintemp+0						; Reset Min-Temp registers
	movff	temperature+1,mintemp+1						; Reset Min-Temp registers

; Init profile recording parameters	
	GETCUSTOM8	d'20'			; sample rate
	movwf	samplesecs_value	; to avoid EEPROM access in the ISR
	GETCUSTOM8	d'21'
	movwf	divisor_temperature			; load divisors for profile storage
	GETCUSTOM8	d'22'
	movwf	divisor_deco				
	GETCUSTOM8	d'23'
	movwf	divisor_tank
	GETCUSTOM8	d'24'
	movwf	divisor_ppo2
	GETCUSTOM8	d'25'
	movwf	divisor_deco_debug
	GETCUSTOM8	d'26'
	movwf	divisor_nuy2

	btfss	FLAG_apnoe_mode		; In Apnoe mode?
	bra		divemode1
; Overwrite some parameters in Apnoe mode....
	movlw	d'1'
	movwf	samplesecs_value	; to avoid EEPROM access in the ISR

divemode1:
	read_int_eeprom	d'36'				; Read mix 1 ppO2
	btfsc	FLAG_const_ppO2_mode
	movff	EEDATA,char_I_const_ppO2	; Set ppO2 setpoint if in ppO2 mode
	movff	EEDATA, ppO2_setpoint_store	; Store also in this byte...

	bcf		LED_blue
	bcf		low_battery_state			; clear flag for battery warning mode
	bcf		header_stored				
	bcf		premenu
	bcf		realdive
	bsf		update_divetime				; set flag
	btfss	simulatormode_active		; do not disable in simulator mode!					
	call	disable_rs232				; Disable RS232

	read_int_eeprom 	d'33'			; Read byte (stored in EEDATA)
	movff	EEDATA,active_gas			; Read start gas (1-5)

; Read Start Gas and configure char_I_He_ratio, char_I_O2_ratio and char_I_N2_ratio
	decf	active_gas,W				; Gas 0-4
	mullw	d'4'
	movf	PRODL,W			
	addlw	d'7'						; = address for He ratio
	movwf	EEADR
	call	read_eeprom					; Read He ratio
	movff	EEDATA,char_I_He_ratio		; And copy into hold register
	decf	active_gas,W				; Gas 0-4
	mullw	d'4'
	movf	PRODL,W			
	addlw	d'6'						; = address for O2 ratio
	movwf	EEADR
	call	read_eeprom					; Read O2 ratio
	movff	EEDATA, char_I_O2_ratio		; O2 ratio
	movff	char_I_He_ratio, wait_temp	; copy into bank1 register
	bsf		STATUS,C					; Borrow bit
	movlw	d'100'						; 100%
	subfwb	wait_temp,W					; minus He
	bsf		STATUS,C					; Borrow bit
	subfwb	EEDATA,F					; minus O2
	movff	EEDATA, char_I_N2_ratio		; = N2!

; Configure sorted_gaslist_active flag register
	clrf	sorted_gaslist_active	; Clear all flags
	read_int_eeprom		d'118'		; read gas_change_depth Gas1
	tstfsz	EEDATA					; =0m?
	bsf		sorted_gaslist_active,0	; No, Set Flag for Gas1

	read_int_eeprom		d'119'		; read gas_change_depth Gas2
	tstfsz	EEDATA					; =0m?
	bsf		sorted_gaslist_active,1	; No, Set Flag for Gas2

	read_int_eeprom		d'120'		; read gas_change_depth Gas3
	tstfsz	EEDATA					; =0m?
	bsf		sorted_gaslist_active,2	; No, Set Flag for Gas3

	read_int_eeprom		d'121'		; read gas_change_depth Gas4
	tstfsz	EEDATA					; =0m?
	bsf		sorted_gaslist_active,3	; No, Set Flag for Gas4

	read_int_eeprom		d'122'		; read gas_change_depth Gas5
	tstfsz	EEDATA					; =0m?
	bsf		sorted_gaslist_active,4	; No, Set Flag for Gas5
	return
