
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


; Underwater Menu (Set Gas, Decoplan, etc.)
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 11/11/05
; last updated: 090305
; known bugs:
; ToDo:


test_switches_divemode:
									; checks switches in divemode
	btfsc	switch_left
	bra		test_switches_divemode2

	btfss	switch_right
	return
	
	bcf		switch_left				; Left button pressed!
	bcf		switch_right
	
	bcf		select_bailoutgas		; Clear Flag for Bailout list
	bsf		premenu					; Set Flag for premenu
	bcf		menubit
	clrf	timeout_counter3		; timeout_divemenu
		
	btfsc	FLAG_apnoe_mode			; In Apnoe mode?
	bra		test_switches_divemode1	; Yes!

test_switches_divemode0:	
	WIN_INVERT		.1
	DISPLAYTEXT	.4			;Menu?
	WIN_INVERT		.0
	return

test_switches_divemode1:
	DISPLAYTEXT	.141			;Quit?
	return

test_switches_divemode2:
	bcf		switch_left			; Also reactivate left button if there was a right press without prior left press
	bcf		switch_right		; enable right button again

	btfss	premenu
	bra		set_marker			; No Pre-Menu displayed -> Set Markerflag!

	btfss	FLAG_apnoe_mode		; In Apnoe mode?
	bra		test_switches_divemode2a; No!
	
	; Yes, so quit Apnoe mode at once...
	bcf		divemode			; Clear Divemode flag...
	bcf		premenu				; clear premenu flag
	return

test_switches_divemode2a:
	bsf		menubit					; Enter Divemode-Menu!
	bcf		premenu					; clear premenu flag
	call	PLED_clear_divemode_menu		; Clear dive mode menu area
	call	PLED_divemode_menu_mask_first	; Write Divemode menu1 mask
	bcf		display_set_simulator			; Clear Simulator-Menu flag
	bcf		divemode_menu_page				; Start in Menu Page one
	movlw	d'1'
	movwf	menupos					; reset cursor in divemode menu
	call	PLED_divemenu_cursor	; show cursor
	bcf		switch_right
	bcf		switch_left				; Left button pressed!
	return

set_marker:
	btfsc		standalone_simulator	; Standalone Simualtor active?
	bra			divemode_menu_simulator	; Yes, Show simulator menu!

	call		set_LEDg			; LEDg on
	movlw		d'6'				; Type of Alarm  (Manual Marker)
	movwf		AlarmType			; Copy to Alarm Register
	bsf			event_occured		; Set Event Flag

	btfss	stopwatch_active			;  =1: Reset Average registers
	return
; Maker Set, also reset average Depth....
	clrf	average_depth_hold+0
	clrf	average_depth_hold+1
	clrf	average_depth_hold+2
	clrf	average_depth_hold+3		; Clear average depth register
	movlw	d'2'
	movwf	average_divesecs+0
	clrf	average_divesecs+1
	call	calc_average_depth
	return

test_switches_divemode_menu:
	btfsc	switch_left
	bra		test_switches_divemode_menu3
	btfss	switch_right
	return

	btfsc	display_see_l_tissue		; Is the leading tissue info screen active
	bra		divemenu_see_leading_tissue2; Yes, quit menu

	btfsc 	display_see_deco			; Is the Decoplan displayed?
	bra		divemenu_see_decoplan2		; Yes, exit menu on left button press

	btfsc 	display_set_graphs			; Is the Graph displayed?
	bra		divemode_set_graphs2		; Yes, exit menu on right button press
	
	bcf		switch_right				; Left button pressed
	clrf	timeout_counter3			; timout_divemenu!
	incf	menupos,F

; Following routine configures the number of menu entries for the different modes
	movlw	d'6'						; number of available gases+1, ; number of menu options+1
	btfsc	display_set_setpoint		; In SetPoint Menu?
	movlw	d'4'						; Number of entries for this menu+1

	cpfseq	menupos						; =limit?
	bra		test_switches_divemode_menu1; No!
	movlw	d'1'						; Yes, reset to position 1!
	movwf	menupos
test_switches_divemode_menu1:
	call	PLED_divemenu_cursor		; update cursor
	return

test_switches_divemode_menu3:
	bcf		switch_left
	bcf		switch_right
	bsf		menubit					; Enter Divemode-Menu!
	bcf		premenu					; clear premenu flag
	clrf	timeout_counter3

	btfsc	display_see_l_tissue		; Is the leading tissue info screen active
	bra		divemenu_see_leading_tissue2; Yes, quit menu

	btfsc	display_set_gas				; Are we in the "Gaslist" or "SetPoint" menu?
	bra		divemenu_set_gas2			; Yes, so set gas and exit menu

	btfsc 	display_see_deco			; Is the Decoplan displayed?
	bra		divemenu_see_decoplan2		; Yes, exit menu on right button press

	btfsc 	display_set_graphs			; Is the Graph displayed?
	bra		divemode_set_graphs2		; Yes, exit menu on right button press

	btfsc	display_set_xgas			; Are we in the "Set Gas" menu?
	bra		divemenu_set_xgas2			; Yes, so configure gas or set menu and exit menu

	btfsc	display_set_simulator		; Are we in the Divemode Simulator menu?
	goto	divemode_menu_simulator2	; Yes, so adjust depth or set and exit

	btfsc	divemode_menu_page			; Are we in the second menu page?
	bra		test_switches_divemode_menu4; Yes, use second page items
; Options for Menu 1
	dcfsnz	menupos,F
	bra		divemenu_see_decoplan		; display the full decoplan
	dcfsnz	menupos,F
	bra		divemenu_set_gas			; Set gas sub-menu
	dcfsnz	menupos,F
	bra		divemode_set_xgas			; Configure the extra gas / Select Bailout
	dcfsnz	menupos,F
	bra		divemenu_enter_second		; Enter second Menu page
	dcfsnz	menupos,F
	bra		timeout_divemenu2			; Quit divemode menu
	return

test_switches_divemode_menu4:
; Options for Menu 2
	dcfsnz	menupos,F
	bra		divemode_set_graphs			; Show saturation graphs
	dcfsnz	menupos,F
	bra		divemode_toggle_brightness	; Toggle OLED-Brightness
	dcfsnz	menupos,F
	bra		divemenu_see_leading_tissue	; Display details about leading tissue
	dcfsnz	menupos,F
	bra		toggle_stopwatch			; Toggle Stopwatch
	dcfsnz	menupos,F
	bra		timeout_divemenu2			; Quit divemode menu
	return

toggle_stopwatch:
	btg		stopwatch_active			; Toggle Flag
	
	btfss	stopwatch_active			; Show Stopwatch?
	bra		toggle_stopwatch2			; No, remove outputs

	clrf	average_depth_hold+0
	clrf	average_depth_hold+1
	clrf	average_depth_hold+2
	clrf	average_depth_hold+3		; Clear average depth register
	movlw	d'2'
	movwf	average_divesecs+0
	clrf	average_divesecs+1
	call	calc_average_depth
	
	bra		timeout_divemenu2			; quit menu!

toggle_stopwatch2:
	call	PLED_stopwatch_remove		; Remove Stopwatch Outputs
	bra		timeout_divemenu2			; quit menu!

divemode_toggle_brightness:
	read_int_eeprom	d'90'				; Brightness offset? (Dim>0, Normal = 0)
	tstfsz	EEDATA						; Was dimmed?
	bra		divemode_toggle_brightness1	; Yes...

	call	PLED_brightness_low
	movlw	d'1'
	movwf	EEDATA						; Copy to EEDATA
	write_int_eeprom	d'90'			; Brightness offset? (Dim=1, Normal = 0)
	bra		divemode_toggle_brightness3

divemode_toggle_brightness1:
	call	PLED_brightness_full
	movlw	d'0'
	movwf	EEDATA						; Copy to EEDATA
	write_int_eeprom	d'90'			; Brightness offset? (Dim=1, Normal = 0)

divemode_toggle_brightness3:
; Now, redraw all outputs (All modes)
	call	PLED_active_gas_divemode	; Display gas, if required
	call	PLED_temp_divemode			; Displays temperature
	call	PLED_depth					; Displays new depth...
	call	PLED_max_pressure			; ...and max. depth

	btfsc	FLAG_apnoe_mode				; Ignore in Apnoe mode
	bra		timeout_divemenu2			; quit menu!
	btfsc	gauge_mode					; Ignore in Gauge mode
	bra		timeout_divemenu2			; quit menu!

; Redraw Outputs in Deco modes
	btfsc	dekostop_active
	call	PLED_display_deko_mask		; clear nostop time, display decodata
	btfss	dekostop_active
	call	PLED_display_ndl_mask		;  Clear deco data, display nostop time
	bra		timeout_divemenu2			; quit menu!

divemenu_enter_second:
	call	PLED_clear_divemode_menu		; Clear dive mode menu area
	call	PLED_divemode_menu_mask_second	; Write Divemode menu1 mask
	movlw	d'1'
	movwf	menupos					; reset cursor to first item in divemode menu page two
	bsf		divemode_menu_page		; Enter Menu Page two
	call	PLED_divemenu_cursor	; show cursor
	bcf		switch_right
	bcf		switch_left				; Left button pressed!
	return

divemode_set_xgas:						; Set the extra gas...
	btfsc	FLAG_const_ppO2_mode		; are we in ppO2 mode?
	bra		divemenu_set_bailout		; Yes, so display Bailot list...

	bsf		display_set_xgas			; Set Flag
	call	PLED_clear_divemode_menu	; Clear Menu

	movff	char_I_O2_ratio, EEDATA		; Reset Gas6 to current gas
	write_int_eeprom	d'24'
	movff	char_I_He_ratio, EEDATA
	write_int_eeprom	d'25'

	call	PLED_divemode_set_xgas		; Show mask

	movlw	d'1'
	movwf	menupos						; reset cursor
	call	PLED_divemenu_cursor		; update cursor

	return

divemode_menu_simulator:
	bsf		menubit					; Enter Divemode-Menu!
	bcf		premenu					; clear premenu flag
	bcf		switch_right
	bcf		switch_left				; Left button pressed!
	bsf		display_set_simulator		; Set Flag
	call	PLED_clear_divemode_menu	; Clear Menu
	call	PLED_divemode_simulator_mask; Show mask
	bcf		divemode_menu_page			; Start in Menu Page one
	movlw	d'1'
	movwf	menupos						; reset cursor
	call	PLED_divemenu_cursor		; update cursor
	return

divemode_menu_simulator2:
	dcfsnz	menupos,F
	bra		timeout_divemenu2			; quit underwater menu!
	dcfsnz	menupos,F
	bra		divemode_menu_simulator_p1	; Adjust +1m
	dcfsnz	menupos,F
	bra		divemode_menu_simulator_m1	; Adjust -1m
	dcfsnz	menupos,F
	bra		divemode_menu_simulator_p10	; Adjust +10m
	dcfsnz	menupos,F
	bra		divemode_menu_simulator_m10	; Adjust -10m
	bra		timeout_divemenu2			; quit underwater menu!

divemode_menu_simulator_common:
	call	PLED_divemode_simulator_mask		; Redraw Simualtor mask

	; Check limits (140m and 0m)
	movlw	LOW		d'15000'
	movwf	sub_a+0
	movlw	HIGH	d'15000'
	movwf	sub_a+1
	movff	sim_pressure+0,sub_b+0
	movff	sim_pressure+1,sub_b+1
	call	sub16				; sub_c = sub_a - sub_b
	btfss	neg_flag	
	bra		divemode_menu_simulator_common2
	; Too deep, limit to 140m
	movlw	LOW		d'15000'
	movwf	sim_pressure+0
	movlw	HIGH	d'15000'
	movwf	sim_pressure+1
	return

divemode_menu_simulator_common2:
	movlw	LOW		d'1000'
	movwf	sub_a+0
	movlw	HIGH	d'1000'
	movwf	sub_a+1
	movff	sim_pressure+0,sub_b+0
	movff	sim_pressure+1,sub_b+1
	call	sub16				; sub_c = sub_a - sub_b
	btfsc	neg_flag	
	return
	; Too shallow, limit to 1m
	movlw	LOW		d'1000'
	movwf	sim_pressure+0
	movlw	HIGH	d'1000'
	movwf	sim_pressure+1
	return

divemode_menu_simulator_m10:
	movlw	LOW		d'1000'
	subwf	sim_pressure+0,F
	movlw	HIGH	d'1000'
	subwfb	sim_pressure+1,F
	movlw	d'5'
	movwf	menupos						; reset cursor
	bra		divemode_menu_simulator_common

divemode_menu_simulator_p10:
	movlw	LOW		d'1000'
	addwf	sim_pressure+0,F
	movlw	HIGH	d'1000'
	addwfc	sim_pressure+1,F
	movlw	d'4'
	movwf	menupos						; reset cursor
	bra		divemode_menu_simulator_common

divemode_menu_simulator_p1:
	movlw	d'100'
	addwf	sim_pressure+0,F
	movlw	d'0'
	addwfc	sim_pressure+1,F
	movlw	d'2'
	movwf	menupos						; reset cursor
	bra		divemode_menu_simulator_common

divemode_menu_simulator_m1:
	movlw	d'100'
	subwf	sim_pressure+0,F
	movlw	d'0'
	subwfb	sim_pressure+1,F
	movlw	d'3'
	movwf	menupos						; reset cursor
	bra		divemode_menu_simulator_common

divemode_set_graphs:
	bsf		display_set_graphs			; set flag
	call	PLED_clear_divemode_menu	; Clear Menu
	call	deco_main_calc_desaturation_time	; calculate desaturation time
	movlb	b'00000001'						; select ram bank 1
	call	PLED_saturation_graph_divemode	; Display saturation graph
	return

divemode_set_graphs2:
	bcf		display_set_graphs			; clear flag
	bra		timeout_divemenu2			; quit menu!

divemenu_see_leading_tissue:
	bsf		display_see_l_tissue		; Set Flag
	call	PLED_clear_divemode_menu	; Clear Menu
	call	PLED_show_leading_tissue	; Show infos about leading tissue
	return

divemenu_see_leading_tissue2:
	bcf		display_see_l_tissue		; Clear Flag
	bra		timeout_divemenu2			; quit menu!
	
divemenu_see_decoplan:
	bsf		display_see_deco			; set flag
	
	read_int_eeprom	d'34'
	movlw	d'3'
	cpfsgt	EEDATA						; in multi-gf mode? Z16 GF OC=4 and Z16 GF CC=5
	bra		divemenu_see_decoplan1		; No!

bra		divemenu_see_decoplan1		; Show normal plan! ToDo: MultiGF Plan....

	bsf		multi_gf_display			; Yes, display the multi-gf table screen
	call	PLED_ClearScreen			; clean up OLED
	call	PLED_MultiGF_deco_mask

	movff	char_O_deco_status,deco_status		; 
	tstfsz	deco_status							; deco_status=0 if decompression calculation done
	return										; calculation not yet finished!

	call	PLED_MultiGF_deco_all		; Display the new screen
	return
	
divemenu_see_decoplan1:	
	call	PLED_clear_divemode_menu	; Clear Menu

	movff	char_O_deco_status,deco_status		; 
	tstfsz	deco_status							; deco_status=0 if decompression calculation done
	return										; calculation not yet finished!
	
	call	PLED_decoplan				; display the Decoplan
	return

divemenu_see_decoplan2:
	bcf		display_see_deco			; clear flag
	bra		timeout_divemenu2			; quit menu!

divemenu_set_xgas2:
	dcfsnz	menupos,F
	bra		divemenu_set_xgas2_exit		; Use the gas6 configured and exit
	dcfsnz	menupos,F
	bra		divemenu_set_xgas2_o2plus	; Adjust O2+
	dcfsnz	menupos,F
	bra		divemenu_set_xgas2_o2minus	; Adjust O2-
	dcfsnz	menupos,F
	bra		divemenu_set_xgas2_heplus	; Adjust He+
	dcfsnz	menupos,F
	bra		divemenu_set_xgas2_heminus	; Adjust He-
	return

divemenu_set_xgas2_heminus:
	read_int_eeprom		d'25'			; He value
	movff	EEDATA,lo
	decf	lo,F						; decrease He
	movlw	d'255'
	cpfseq	lo
	bra		divemenu_set_xgas2_heminus2
	incf	lo,F						; limit to min=0
divemenu_set_xgas2_heminus2:
	movff	lo, EEDATA
	write_int_eeprom	d'25'			; He Value

	call	PLED_divemode_set_xgas		; Redraw menu
	movlw	d'5'
	movwf	menupos						; reset cursor
	return

divemenu_set_xgas2_heplus:
	read_int_eeprom		d'25'			; He value
	movff	EEDATA,lo
	incf	lo,F						; increase He
	movlw	d'101'
	cpfseq	lo
	bra		divemenu_set_xgas2_heplus2
	movlw	d'4'						; O2 Limit
	movwf	lo
divemenu_set_xgas2_heplus2:				; test if O2+He>100...
	read_int_eeprom		d'24'			; O2 value
	movf	EEDATA,W
	addwf	lo,W						; add He value
	movwf	hi							; store in temp
	movlw	d'101'
	cpfseq	hi							; O2 and He > 100?
	bra		divemenu_set_xgas2_heplus3	; No!
	decf	lo,F						; reduce He again = unchanged after operation
divemenu_set_xgas2_heplus3:				; save current value
	movff	lo, EEDATA
	write_int_eeprom	d'25'			; He Value

	call	PLED_divemode_set_xgas		; Redraw menu
	movlw	d'4'
	movwf	menupos						; reset cursor
	return

divemenu_set_xgas2_o2minus:
	read_int_eeprom		d'24'			; O2 value
	movff	EEDATA,lo
	decf	lo,F						; decrease O2
	movlw	d'3'						; Limit-1
	cpfseq	lo
	bra		divemenu_set_xgas2_o2minus2
	incf	lo,F						; limit to min=9
divemenu_set_xgas2_o2minus2:
	movff	lo, EEDATA
	write_int_eeprom	d'24'			; O2 Value

	call	PLED_divemode_set_xgas		; Redraw menu
	movlw	d'3'
	movwf	menupos						; reset cursor
	return

divemenu_set_xgas2_o2plus:
	read_int_eeprom		d'24'			; O2 value
	movff	EEDATA,lo
	incf	lo,F						; increase O2
	movlw	d'101'
	cpfseq	lo
	bra		divemenu_set_xgas2_o2plus2
	movlw	d'5'						; O2 limit
	movwf	lo
divemenu_set_xgas2_o2plus2:				; test if O2+He>100...
	read_int_eeprom		d'25'			; He value
	movf	EEDATA,W
	addwf	lo,W						; add O2 value
	movwf	hi							; store in temp
	movlw	d'101'
	cpfseq	hi							; O2 and He > 100?
	bra		divemenu_set_xgas2_o2plus3	; No!
	decf	lo,F						; reduce O2 again = unchanged after operation
divemenu_set_xgas2_o2plus3:				; save current value
	movff	lo, EEDATA
	write_int_eeprom	d'24'			; O2 Value

	call	PLED_divemode_set_xgas		; Redraw menu
	movlw	d'2'
	movwf	menupos						; reset cursor
	return

divemenu_set_xgas2_exit:
	read_int_eeprom		d'25'			; Read He ratio
	movff	EEDATA,char_I_He_ratio		; And copy into hold register

	read_int_eeprom		d'24'			; Read O2 ratio
	movff	EEDATA, char_I_O2_ratio		; O2 ratio
	movff	char_I_He_ratio, wait_temp	; copy into bank1 register
	bsf		STATUS,C					; 
	movlw	d'100'						; 100%
	subfwb	wait_temp,W					; minus He
	subfwb	EEDATA,F					; minus O2
	movff	EEDATA, char_I_N2_ratio		; = N2!
	bsf		manual_gas_changed			; set event flag
	bsf		event_occured				; set global event flag
	bra		timeout_divemenu2			; quit underwater menu!

divemenu_set_bailout:
	bsf		display_set_gas				; set flag	
	call	PLED_clear_divemode_menu	; Clear Menu

	bcf		FLAG_const_ppO2_mode		; Delete Flag to show all bailouts
	bsf		select_bailoutgas			; Set Flag for Bailout list
	call	PLED_gas_list				; Display all 5 gases
	bsf		FLAG_const_ppO2_mode		; Reset Flag

	movlw	d'1'
	movwf	menupos						; reset cursor
	call	PLED_divemenu_cursor		; update cursor
	return

divemenu_set_gas:
	btfsc	FLAG_const_ppO2_mode		; in ppO2 mode?
	bra		divemenu_set_setpoint		; Yes, display SetPoint/Sensor result list

	bsf		display_set_gas				; set flag	
	call	PLED_clear_divemode_menu	; Clear Menu
	call	PLED_gas_list				; Display all 5 gases
	movlw	d'1'
	movwf	menupos						; reset cursor
	call	PLED_divemenu_cursor		; update cursor
	return

divemenu_set_setpoint:
	bsf		display_set_setpoint		; set flag	
	bsf		display_set_gas				; set flag	

	call	PLED_clear_divemode_menu	; Clear Menu
	call	PLED_splist_start			; Display SetPoints and Sensor results
	movlw	d'1'
	movwf	menupos						; reset cursor
	call	PLED_divemenu_cursor		; update cursor
	
	return


divemenu_set_gas2:
	btfsc	select_bailoutgas			; Are we in the Bailout list?
	bra		divemenu_set_gas2a			; Yes, choose gas

	btfss	FLAG_const_ppO2_mode		; are we in ppO2 mode?
	bra		divemenu_set_gas2a			; no, choose gas
	; Yes, so select SP 1-3 or Sensor mode
	
divemenu_set_gas1:	
	movlw	d'35'						; offset in memory
	addwf	menupos,W					; add SP number 0-2
	movwf	EEADR
	call	read_eeprom					; Read SetPoint
	movff	EEDATA, char_I_const_ppO2	; Use SetPoint

divemenu_set_gas1a:
	bcf		display_set_setpoint		; Clear Display Flag
; Now, Set correct Diluent (again)
	read_int_eeprom 	d'33'			; Read byte (stored in EEDATA)
	movff	EEDATA,active_gas			; Read start gas (1-5)

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

	call	PLED_active_gas_clear		; Clear gas in case of AIR (Will be redrawn)	
	
	bsf		stored_gas_changed			; set event flag
	bsf		event_occured				; set global event flag
	bra		timeout_divemenu2			; quit menu!

divemenu_set_gas2a:
	clrf	lo							; clear Setpoint, PLED_const_ppO2_value now displayes "Bail"
	movff	lo,char_I_const_ppO2		

	bcf		display_set_gas				; clear flag
	movff	menupos,active_gas			; copy into active gas register
	decf	menupos,W					; # of selected gas (0-4)
	mullw	d'4'						; times 4...
	movf	PRODL,W						;
	addlw	d'7'						; +7 = address for He ratio
	movwf	EEADR
	call	read_eeprom					; Read He ratio
	movff	EEDATA,char_I_He_ratio		; And copy into hold register

	decf	menupos,W					; # of selected gas (0-4)
	mullw	d'4'						; times 4...
	movf	PRODL,W						;
	addlw	d'6'						; +6 = address for O2 ratio
	movwf	EEADR
	call	read_eeprom					; Read O2 ratio
	movff	EEDATA, char_I_O2_ratio		; O2 ratio
	movff	char_I_He_ratio, wait_temp	; copy into bank1 register
	bsf		STATUS,C					; 
	movlw	d'100'						; 100%
	subfwb	wait_temp,W					; minus He
	subfwb	EEDATA,F					; minus O2
	movff	EEDATA, char_I_N2_ratio		; = N2!
	bsf		stored_gas_changed			; set event flag
	bsf		event_occured				; set global event flag
	bra		timeout_divemenu2			; quit menu!
	
timeout_divemenu:
	btfss	menubit					; is the Dive mode menu displayed?
	return							; No

	btfsc	display_see_l_tissue	; Are the leading tissue details displayed?
	bra		timeout_divemenu7		; Yes, update them

	btfsc	display_set_simulator	; Is the Simulator Mask active?
	bra		timeout_divemenu6		; Yes, update Simulator mask

	
	btfss	display_see_deco		; Is the decoplan active?
	bra		timeout_divemenu1		; No, skip updating the decoplan

	btfsc	multi_gf_display		; display the multi-gf table screen?
	bra		timeout_divemenu3		; Yes...

	movff	char_O_deco_status,deco_status		; 
	tstfsz	deco_status							; deco_status=0 if decompression calculation done
	bra		timeout_divemenu1				; No, skip updating the decoplan
	
	call	PLED_decoplan				; update the Decoplan
	
timeout_divemenu1:	
	incf	timeout_counter3,F		; increase timeout_counter3
	GETCUSTOM8	d'10'				; loads timeout_divemenu into WREG
	cpfsgt	timeout_counter3		; ... longer then timeout_divemenu
	return							; No!
timeout_divemenu2:					; quit divemode menu
	btfss	multi_gf_display			; Was the Multi-GF Table displayed?
	bra		timeout_divemenu2a			; No, normal OLED rebuild

; Restore some outputs
	bcf		multi_gf_display			; Do not display the multi-gf table screen
	call	PLED_ClearScreen			; Yes, clean up OLED first
	call	PLED_temp_divemode			; Displays temperature
	call	PLED_max_pressure			; Max. Depth
	btfsc	dekostop_active
	call	PLED_display_deko_mask		; clear nostop time, display decodata
	btfss	dekostop_active
	call	PLED_display_ndl_mask		;  Clear deco data, display nostop time

timeout_divemenu2a:
	bcf		multi_gf_display			; Do not display the multi-gf table screen
	bcf		menubit
	bcf		premenu					; Yes, clear flags and menu, display dive time and mask again
	call	PLED_active_gas_divemode	; Display gas, if required
	call	PLED_clear_divemode_menu; Clear dive mode menu
	call	PLED_divemode_mask		; Display mask
	call	PLED_divemins			; Display (new) divetime!
	clrf	timeout_counter3		; Also clear timeout
	bcf		display_see_deco		; clear all display flags
	bcf		display_see_l_tissue
	bcf		display_set_gas			
	bcf		display_set_graphs
	bcf		display_set_xgas
	bcf		display_set_setpoint
	bcf		display_set_simulator
	bcf		switch_left				; and debounce switches
	bcf		switch_right
	return
	
timeout_divemenu3:
	call	PLED_MultiGF_deco_mask

	movff	char_O_deco_status,deco_status		; 
	tstfsz	deco_status							; deco_status=0 if decompression calculation done
	bra		timeout_divemenu1				; No, skip updating the decoplan

	call	PLED_MultiGF_deco_all		; Display the new screen
	bra		timeout_divemenu1			; Check timeout
	
timeout_divemenu6:
	; Update Simulator Mask
	call	PLED_divemode_simulator_mask; Show mask
	call	PLED_divemenu_cursor		; update cursor
	bra		timeout_divemenu1			; Check timeout
	
timeout_divemenu7:
	; Update Leading tissue infos
	call	PLED_show_leading_tissue	; Update infos about leading tissue	
	bra		timeout_divemenu1			; Check timeout