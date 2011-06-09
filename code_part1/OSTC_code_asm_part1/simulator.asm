
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
	movwf	logbook_temp1               ; Bottom time
	movlw	d'15'
	movwf	logbook_temp2               ; Max. Depth
	movlw	d'1'
	movwf	menupos
    clrf    WREG                        ; Interval
    movff   WREG,char_I_dive_interval

menu_simulator1:
	clrf	timeout_counter2
	bsf		menubit
	bsf		cursor
	call	PLED_brightness_full			;max. brightness
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
	goto	menu_simulator_exit

	btfsc	sleepmode
	goto	menu_simulator_exit

	btfsc	divemode
	goto	restart						; exit menu, restart and enter divemode

	bra		menu_simulator_loop

menu_simulator_do:						; calls submenu
	dcfsnz	menupos,F
	bra		simulator_inc_interval
	dcfsnz	menupos,F
	bra		simulator_startdive
	dcfsnz	menupos,F
	bra		simulator_inc_bottomtime
	dcfsnz	menupos,F
	bra		simulator_inc_maxdepth
	dcfsnz	menupos,F
	bra		simulator_calc_deco

menu_simulator_exit:
	movlw	d'4'
	movwf	menupos
	goto	more_menu2                  ; exit...

simulator_inc_interval:
    movff   char_I_dive_interval,PRODL
    incf    PRODL,F
    movlw   .24*6                       ; Max 24h delay.
    cpfslt  PRODL
    clrf    PRODL
    movff   PRODL,char_I_dive_interval

	movlw	d'1'
	movwf	menupos
	bra		menu_simulator2
    
simulator_inc_bottomtime:
	movlw	d'2'
	addwf	logbook_temp1,F				; Here: Bottomtime in m
	movlw	d'199'
	cpfslt	logbook_temp1
	movwf	logbook_temp1
	movlw	d'3'
	movwf	menupos
	bra		menu_simulator2

simulator_inc_maxdepth:
	movlw	d'3'
	addwf	logbook_temp2,F				; Here: Maxdepth in m
	movlw	d'99'
	cpfslt	logbook_temp2
	movwf	logbook_temp2
	movlw	d'4'
	movwf	menupos
	bra		menu_simulator2

;=============================================================================

simulator_startdive:
	; Descent to -15m depth
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
	addwfc	xC+1,F							; add 1000mBar

	movff	xC+0,sim_pressure+0
	movff	xC+1,sim_pressure+1

    ; This override is done in ISR too, but do it right now also:	
	movff	sim_pressure+0,amb_pressure+0
	movff	sim_pressure+1,amb_pressure+1

	bcf		menubit2
	bcf		menubit3
	bcf		menubit
	bcf		switch_left
	bcf		switch_right

	call	simulator_save_tissue_data  ; Stores 32 floats "pre_tissue" into bank3

    movff   char_I_dive_interval,WREG   ; Any interval ?
    iorlw   0                           ; Test for null
    btfss   STATUS,Z
    call    deco_calc_dive_interval     ; NZ: call interval subroutine.
    movlb   1
    
	movlw	d'3'                        ; Begin of deco cycle (reset table).
	movff	WREG,char_O_deco_status     ; Reset Deco module.

	bsf		divemode                    ; Set divemode flag
	ostc_debug	'P'                     ; Sends debug-information to screen if debugmode active
	goto	diveloop                    ; Start Divemode

;=============================================================================
; Show decoplanning result.
;
simulator_show_decoplan:
        call	PLED_ClearScreen
        call	PLED_simdata_screen
        call	divemenu_see_decoplan
        
        WIN_LEFT .0
        call    PLED_standard_color

        ; Display TTS, if any...
        movff   int_O_ascenttime+0,lo
        movff   int_O_ascenttime+1,hi
        movf    lo,W
        iorwf   hi,W
        bz      simulator_decoplan_notts
        
        WIN_TOP .162
        lfsr    FSR2, letter
        OUTPUTTEXT .85                  ; TTS
        STRCAT  ": "
        bsf		leftbind
        output_16
        STRCAT_PRINT    "'"		

simulator_decoplan_notts:
        WIN_TOP .190                    ; Print calculated CNS before and after dive
        STRCPY  "CNS:"
        movff   char_O_CNS_fraction,lo  ; Current CNS, before dive.
        output_8

        STRCAT  "%\x92"                 ; Right-arrow
        movff   logbook_temp3,lo        ; Get back CNS value.
        output_8                        ; CNS after dive.
        STRCAT_PRINT    "%"

        WIN_INVERT	.1	                ; Init new Wordprocessor	
        DISPLAYTEXT	.188		        ; Sim. Results:
        WIN_INVERT	.0                  ; Init new Wordprocessor	
	
simulator_show_decoplan1:
        bcf		switch_left
        bcf		switch_right
simulator_show_decoplan2:
        btfsc	uart_dump_screen        ; Asked to dump screen contains ?
        call	dump_screen             ; Yes!
        
        btfss	onesecupdate
        bra		simulator_show_decoplan3
        
        call	timeout_surfmode
        call	set_dive_modes
        call	test_charger            ; check if charger IC is active
        call	get_battery_voltage     ; get battery voltage
        
        bcf		onesecupdate            ; End of one second tasks

simulator_show_decoplan3:
	btfsc	switch_right
	bra		menu_simulator1             ; Quit display

	btfsc	switch_left
	bra		simulator_show_decoplan5	; Next decoplan-page.

	btfsc	sleepmode
	goto	more_menu

	btfsc	divemode
	goto	restart						; exit menu, restart and enter divemode

	bra		simulator_show_decoplan2

simulator_show_decoplan5:
	incf	decoplan_page,F
	btfsc	last_ceiling_gf_shown		; last ceiling shown?
	bra		simulator_show_decoplan5_0	; All done, clear and return

	call	PLED_decoplan               ; Re-Draw Current page of GF Decoplan
	bra		simulator_show_decoplan1	

;---- In OCR mode, show the gas Usage special page ---------------------------
simulator_show_decoplan5_0:    
    btfss   display_see_deco            ; Already displayed ?
    bra     menu_simulator1             ; Exit to menu.

	bcf		display_see_deco			; clear flag
   
    btfsc   FLAG_const_ppO2_mode        ; In CCR mode ?
    bra     menu_simulator1             ; YES: finished.

    ; Make sure to pass first gas
    clrf    EEADRH
    read_int_eeprom .33                 ; First gas.
    movff   EEDATA,char_I_first_gas

    ; Compute gas consumption for each tank.
    call    deco_gas_volumes
    movlb   1

    ; Clear the complete stop result column:
    WIN_BOX_BLACK   .0, .239, .85, .160		;top, bottom, left, right

	movlw	d'10'
	movwf	waitms_temp                 ; Row for gas list is .10+.25
	clrf	wait_temp                   ; Gas counter
    lfsr	FSR0,int_O_gas_volumes      ; Initialize indexed addressing.

	WIN_LEFT	.90                     ; Set column
    call    PLED_standard_color   

simulator_show_decoplan5_loop:
    incf    wait_temp,F                 ; Increment gas #
    
	movlw	.25
	addwf	waitms_temp,F		        ; Increase row position
	movff	waitms_temp,win_top         ; Set Row

    movff   POSTINC0,lo                 ; Read (16bit) result, low first,
    movff   POSTINC0,hi                 ; then high.
    movf    lo,W                        ; Null ?
    iorwf   hi,W
    bz      simulator_show_decoplan5_1  ; Skip printing.

    movf    lo,W                        ; == 65535 (saturated ?)
    andwf   hi,W
    incf    WREG
    bnz     simulator_show_decoplan5_2
    call    PLED_warnings_color
    STRCPY_PRINT  "= xxxx.x"
    call    PLED_standard_color   
    bra     simulator_show_decoplan5_1
    
simulator_show_decoplan5_2: 
    STRCPY  "= "

    bsf     leftbind
    output_16dp .4                      ; 1 decimal.
    bcf     leftbind
    call    word_processor              ; No unit: can be bars or litters.
    
    ; Loop for all 5 gas
simulator_show_decoplan5_1:
	movlw	d'5'                        ; list all five gases
	cpfseq	wait_temp                   ; All gases shown?
	bra		simulator_show_decoplan5_loop	; No
	
	WIN_INVERT 1
	DISPLAYTEXTH .301                   ; OCR Gas Usage:
	WIN_INVERT 0

	bra		simulator_show_decoplan1		

;=============================================================================
; OSTC Simulator: compute a new runtime
;
simulator_calc_deco:
	call	simulator_save_tissue_data  ; Stores 32 floats "pre_tissue" into bank3

    movff   char_I_dive_interval,WREG   ; Any interval ?
    iorlw   0                           ; Test for null
    btfss   STATUS,Z
    call    deco_calc_dive_interval     ; NZ: call interval subroutine.
    movlb   1

	bsf		simulatormode_active        ; normal simulator mode
	bsf		standalone_simulator        ; Standalone Simulator active
	bsf		no_sensor_int               ; Disable sensor interrupt
	clrf	T3CON                       ; Restart time3 counter,
	clrf	TMR3L                       ; so the simu won't stop right away.
	clrf	TMR3H

	call	diveloop_boot               ; configure gases, etc.

    ; Save dive parameters for gas volume estimation:
    movff   logbook_temp2,char_I_bottom_depth
    movff   logbook_temp1,char_I_bottom_time

	movff	logbook_temp2,xA+0          ; Bottom depth. 
	clrf	xA+1
	movlw	d'100'
	movwf	xB+0
	clrf	xB+1
	call	mult16x16                   ;xA*xB=xC, Depth in m*100

	movlw	LOW		d'1000'
	addwf	xC+0,F
	movlw	HIGH	d'1000'
	addwfc	xC+1,F                      ; add 1000mBar

	movff	xC+0,sim_pressure+0
	movff	xC+1,sim_pressure+1

	call	PLED_topline_box
	WIN_INVERT	.1
	DISPLAYTEXT	.12                     ; "Wait..."
	WIN_INVERT	.0

    ; This override is done in ISR too, but do it right now also:	
	movff	sim_pressure+0,amb_pressure+0
	movff	sim_pressure+1,amb_pressure+1

	call	divemode_check_decogases    ; Checks for decogases and sets the gases
	call	divemode_prepare_flags_for_deco
	call    set_first_gas               ; Set current N2/He/O2 ratios.
    call    set_actual_ppo2             ; Then configure char_I_actual_ppO2

    ; First minute is special: init everything.
	movlw	d'3'                        ; Begin of deco cycle (reset table).
	movff	WREG,char_O_deco_status     ; Reset Deco module.

	movlw	d'1'
	movff	WREG,char_I_step_is_1min    ; 1 minute mode.

	call	deco_calc_hauptroutine      ; Reset table + sim one minute for descent.
    call	deco_calc_CNS_fraction      ; Also calculate CNS (in 1min loop)
	movlb	b'00000001'                 ; rambank 1 selected

    decf    logbook_temp1,F             ; One minute done.

    ; Loop for bottom time duration
simulator_calc_deco_loop2:
    call	PLED_simulator_data         ; Update display of bottom time.

    call	deco_calc_tissue		    ; JUST calc tissue (faster).
    call	deco_calc_CNS_fraction      ; Also calculate CNS (in 1min loop)
    movlb	b'00000001'                 ; rambank 1 selected
    ostc_debug	'C'	                    ; Sends debug-information to screen if debugmode active

    decfsz  logbook_temp1,F             ; Decrement bottom time,
	bra     simulator_calc_deco_loop2   ; and loop while not finished.

    ; No the bottom time is finish, restart a full ascent simulation,
	movlw	d'0'
	movff	WREG,char_I_step_is_1min    ; Back to 2 second deco mode

	clrf	timeout_counter2			; timeout used as maxloop here
	movff   char_I_bottom_depth,char_O_deco_last_stop

simulator_calc_deco2:
	call	deco_calc_hauptroutine		; calc_tissue
	movlb	b'00000001'                 ; rambank 1 selected

    movff   char_O_deco_last_stop,logbook_temp2
    call    PLED_simulator_data         ; Animate ascent simu.

	dcfsnz	timeout_counter2,F			; Abort loop (max. 256 tries)?
	bra		simulator_calc_deco3		; Yes...

	movff	char_O_deco_status,WREG
	iorwf	WREG                        ; deco_status=0 if decompression calculation done
	bnz		simulator_calc_deco2        ; Not finished

; Finished
simulator_calc_deco3:
    movff   char_O_CNS_fraction,logbook_temp3   ; Save calculated CNS.     
	rcall	simulator_restore_tissue_data	; Restore CNS & 32 floats "pre_tissue" from vault

	bcf		simulatormode_active        ; normal simulator mode
	bcf		standalone_simulator        ; Standalone Simulator active
	bcf		no_sensor_int				; Re-enable sensor interrupt

	WAITMS	d'250'
	WAITMS	d'250'
	WAITMS	d'250'                      ; Wait for Pressure Sensor to get real pressure again...

	movlw	d'5'                        ; Pre-Set Cursor to "Show Decoplan"
	movwf	menupos
	movff	char_I_bottom_time,logbook_temp1    ; Restore bottom time,
	movff   char_I_bottom_depth,logbook_temp2   ; and depth.

	clrf	timeout_counter2            ; Restart menu timeout.
    bra     simulator_show_decoplan     ; Done.

simulator_save_tissue_data:
	bsf		restore_deco_data           ; Set restore flag
	ostc_debug	'S'                     ; Sends debug-information to screen if debugmode active
	call	deco_push_tissues_to_vault
	movlb	0x01                        ; Back to RAM Bank1
	ostc_debug	'T'                     ; Sends debug-information to screen if debugmode active
	return

simulator_restore_tissue_data:
	bcf		restore_deco_data           ; clear restore flag
	ostc_debug	'S'                     ; Sends debug-information to screen if debugmode active
	call	deco_pull_tissues_from_vault ; Restore CNS too...
	movlb	0x01						; Back to RAM Bank1
	ostc_debug	'T'                     ; Sends debug-information to screen if debugmode active

	ostc_debug	'G'		; Sends debug-information to screen if debugmode active
	call	deco_calc_desaturation_time	; calculate desaturation time
	movlb	b'00000001'                 ; select ram bank 1
	
	; Note: should not reset nofly-time here: the true value have continued to be decremented
	;       during simulation, which is the right thing to do...
	ostc_debug	'H'		; Sends debug-information to screen if debugmode active

	return
