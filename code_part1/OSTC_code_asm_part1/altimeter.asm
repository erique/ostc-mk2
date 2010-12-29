;=============================================================================
;
;    File altimeter.asm
;
;    Altimeter function prototype.
;
;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <http://www.gnu.org/licenses/>.
;
;    Copyright (c) 2010, JD Gascuel.
;=============================================================================
; HISTORY
;  2010-12-15 : [jDG] First prototype with quadratic polynomial ant tp°.
;  2010-12-28 : [jDG] Use MPLAB Math and C libraries for FP32 computations.
;  2011-01-02 : [jDG] Edit reference pressure by 0.25 mbar.
;
altimeter_calc:
        movlb   HIGH(pressureAvg)
        
        movf    pressureRef+0,W         ; Already initialized ?
        iorwf   pressureRef+1,W
        bnz     altimeter_1             ; Yes...
            
        movlw   LOW(4*.1013+1)          ; Init see level at 1013,25 mbar.
        movwf   pressureRef+0
        movlw   HIGH(4*.1013+1)
        movwf   pressureRef+1

; Reset computation. Eg. after a sleep, enables to faster restart with correct
; values...
altimeter_reset:
        movlb   HIGH(pressureAvg)
        clrf    pressureSum+0           ; Init averaging area
        clrf    pressureSum+1
        clrf    pressureCount

        clrf    altitude+0              ; Mark as not computed yet.
        clrf    altitude+1

        movff   amb_pressure+0,pressureAvg+0    ; And init first average.
        movff   amb_pressure+1,pressureAvg+1

        movlw   4                       ; And multiply AVG by 16 to be coherent.
altimeter_reset_1:
        bcf     STATUS,C
        rlcf    pressureAvg+0
        rlcf    pressureAvg+1
        decfsz  WREG
        bra     altimeter_reset_1

        movlb   1                       ; Back to normal bank1.
        return

altimeter_1:
        ;---- Do a bank-safe 16bit summing -----------------------------------
        movff   amb_pressure+0,WREG
        addwf   pressureSum+0,F
        movff   amb_pressure+1,WREG
        addwfc  pressureSum+1,F

        incf    pressureCount           ; Increment count too.
        movlw   .32                     ; Already 32 done ?
        subwf   pressureCount,W
        bnz     altimeter_4             ; NO: skip update.

        ;---- Update altitude every 32 pressure measures --------------------
        bcf     STATUS,C                ; Divide by 2, to store pressure x16
        rrcf    pressureSum+1
        rrcf    pressureSum+0
        
        movff   pressureSum+0,pressureAvg+0
        movff   pressureSum+1,pressureAvg+1

        rcall   compute_altitude        ; Compute from the averaged value...

        clrf    pressureSum+0           ; And reset sum zone for next averaging.
        clrf    pressureSum+1
        clrf    pressureCount

altimeter_4:
        movlb   1                       ; make sure to be in normal bank1
        return

        ;---- Display result -------------------------------------------------
altimeter_display:
        GETCUSTOM8  .49                 ; Check CF#49
        btfss   WREG,0                  ; Enabled ?
        return                          ; NO: return

        WIN_TOP     .35                 ; Custom view drawing zone...
        WIN_LEFT    .90
        WIN_INVERT  .0
        WIN_FONT    .0
        call    PLED_standard_color

        STRCPY  "Alt:"

        movff   altitude+0,lo           ; BANK-SAFE read altitude
        movff   altitude+1,hi
        movf    lo,W                    ; Is it zero (not computed yet) ?
        iorwf   hi,W
        bz      altimeter_2

        bsf     leftbind
        output_16
        bcf     leftbind
        bra     altimeter_3

altimeter_2:
        STRCAT  "****"

altimeter_3:
        STRCAT_PRINT "m  "        
        return

;=============================================================================
; Compute altitude, using the formula:
; H(P) = 18.787 log10(P0/P)  (Log base 10)

;---- Interface the the Mayh library -----------------------------------------
        extern  __AARGB2                ; A float in fA2, fA1, fA0, fAExo
        extern  __BARGB2                ; B float in fB2, fB1, fB0, fBExo
        extern  FLO1632U                ; convert uint16 fA+1 --> fp32 fA
        extern  FPD32                   ; fp32 divide fA/fB --> fA
        extern  FPM32                   ; fp32 multiply fA*fB --> fA
        extern  INT3216                 ; convert fp32 fA --> int16 fA+1
#define fA __AARGB2
#define fB __BARGB2

;---- Interface to the C library ---------------------------------------------
        extern  __AARGB3
        extern  log10                   ; float32 log(auto float32)
#define fRet __AARGB3

compute_altitude:
        ; Setup C-code stack, to enable calling the log() function.
        lfsr    FSR1, c_code_data_stack
        lfsr    FSR2, c_code_data_stack
        
        ; Convert pressure to float, --> fB
        movff   pressureAvg+0, fA+1 
        movff   pressureAvg+1, fA+2
        call    FLO1632U                ; u16 fA[1:2] --> fp32 fA
        movff   fA+0, fB+0
        movff   fA+1, fB+1
        movff   fA+2, fB+2
        movff   fA+3, fB+3

        ; Convert sea-level reference pressure to float, --> fB
        movff   pressureRef+0, fA+1     ; Get sea level pressure.
        movff   pressureRef+1, fA+2
        bcf     STATUS,C                ; Multiply by 4.
        rlcf    fA+1
        rlcf    fA+2
        bcf     STATUS,C
        rlcf    fA+1
        rlcf    fA+2
        call    FLO1632U                ; to float: u16 fA[1:2] --> fp32 fA

        ; Divide
        call    FPD32                   ; fp32 X/Y --> X

        ; log10()
        movff   fA+0, POSTINC1          ; Push X to stack
        movff   fA+1, POSTINC1
        movff   fA+2, POSTINC1
        movff   fA+3, POSTINC1
        call    log10                   ; log(P0/P)

        movf    POSTDEC1,F,ACCESS       ; pop argument
        movf    POSTDEC1,F,ACCESS            
        movf    POSTDEC1,F,ACCESS     
        movf    POSTDEC1,F,ACCESS

        ; Move log10(P0/P) to fB
        movff   fRet+0,fB+0             ; move result to fB
        movff   fRet+1,fB+1
        movff   fRet+2,fB+2 
        movff   fRet+3,fB+3

        ; Multiply by scaling factor for meters, and standatd atmosphere.
        movlw   LOW(.18787)
        movff   WREG, fA+1
        movlw   HIGH(.18787)
        movff   WREG, fA+2
        call    FLO1632U                ; u16 fA[1:2] --> fp32 fA
        call    FPM32                   ; altitute --> fp32 fA

        ; Convert result to int16 --> altitude.
        call    INT3216                 ; fp32 fA --> int16 fA+1
        movff   fA+1, altitude+0
        movff   fA+2, altitude+1

        return

;=============================================================================
; Altimeter menu
;
; Edit reference (where altitude = 0) pressure, while displaying corresponding
; altitude.
;
altimeter_menu:
        call    PLED_ClearScreen        ; Menu header.
        call    PLED_standard_color
    	call	PLED_topline_box
    	WIN_INVERT	.1	; Init new Wordprocessor	
        WIN_FONT    .0
        WIN_LEFT    .80-7*7
        WIN_TOP     .0
        STRCPY_PRINT "Set Altimeter:"

        movlw       3                   ; Start menu on line 3.
        movwf       menupos

altimeter_menu_2:
        WIN_FONT    .0                  ; Reset, because compute erase that...
        WIN_INVERT  .0
        WIN_LEFT    .20                 ; First line:
        WIN_TOP     .35
        STRCPY      "Sea ref:"

        movff       pressureRef+0, lo
        movff       pressureRef+1, hi
        bcf         STATUS,C            ; Divide ref pressure by 4
        rrcf        hi                  ; to get the integer part of it:
        rrcf        lo
        bcf         STATUS,C
        rrcf        hi
        rrcf        lo
        bsf         leftbind
        output_16
        
        PUTC    '.'
        movff       pressureRef+0, hi   ; Decimal part is constructed
        clrf        WREG                ; from the 2 lower bits.
        btfsc       hi,0
        addlw       .25   
        btfsc       hi,1
        addlw       .50 
        movwf       lo  
        output_99x
        
        STRCAT_PRINT    "mbar  "
        
        WIN_TOP     .65                 ; Second line:
        STRCPY      "Alt:"
        movff       altitude+0, lo
        movff       altitude+1, hi
        bcf         leftbind
        output_16
        STRCAT_PRINT    "m    "

        WIN_TOP     .95                 ; Action enable
        STRCPY      "Enabled: "
        GETCUSTOM8  .49
        btfss       WREG,0
        bra         alt_menu_1
        STRCAT_PRINT "ON "
        bra         alt_menu_2
alt_menu_1:
        STRCAT_PRINT "OFF"
alt_menu_2:
        
        WIN_TOP     .125                ; Action add
        STRCPY_PRINT "+0.25 mbar"
        WIN_TOP     .155                ; Action sub
        STRCPY_PRINT "-0.25 mbar"
        WIN_TOP     .185                ; Action exit
        STRCPY_PRINT "Exit"

alt_menu_loop:
        call        PLED_menu_cursor    ; Display cursor
    	bcf		    switch_left         ; reset buttons state
    	bcf		    switch_right

alt_menu_loop1:                         ; Wait for button.
    	btfsc   	switch_right        ; [[MENU]] button
    	bra	        alt_menu_next

    	btfsc	    switch_left         ;[[ENTER]] button
    	bra	        alt_menu_do_it

    	btfsc	    divemode            ; Diving stared ?
    	goto	    restart             ; YES: quit this menu !

    	btfsc	    onesecupdate        ; Check what should be every 1sec.
    	call    	timeout_surfmode

    	btfsc	    onesecupdate
    	call	    set_dive_modes

    	bcf		    onesecupdate		; end of 1sek. tasks

    	btfsc	    sleepmode           ; Sleep mode entered ?
    	bra	        alt_menu_exit

    	bra	        alt_menu_loop1

;---- Move to next line ------------------------------------------------------

alt_menu_next:
        incf        menupos             ; next line.
        movlw       .7
        cpfseq      menupos             ; Below last line ?
        bra         alt_menu_loop
        movlw       .3                  ; Yes: back to line no 3.
        movwf       menupos
        bra         alt_menu_loop

;----- Execute menu line -----------------------------------------------------

alt_menu_do_it:
        movf        menupos,W           ; test line value
        addlw       -3
        bz          alt_menu_enable
        dcfsnz      WREG
        bra         alt_menu_plus1      ; 4 --> +1
        dcfsnz      WREG
        bra         alt_menu_minus1     ; 5 --> -1
        bra         alt_menu_exit       ; else --> exit

;---- Toggle altimeter (CF#49) -----------------------------------------------        
alt_menu_enable:
        GETCUSTOM8  .49                 ; Read CF#49
        btg         WREG,0              ; Toggle boolean value
    	movwf	    EEDATA              
    	movlw	    d'1'				; Upper EEPROM Bank
    	movwf	    EEADRH
        movlw       4*(.49-.32) + 0x82  ; CF#49 low byte address in EEPROM
    	movwf	    EEADR
    	call	    write_eeprom
    	bra         altimeter_menu_2

;---- Increment sea level pressure -------------------------------------------        

alt_menu_plus1:
        movlb       HIGH(pressureRef)   ; Setup our own ram bank
        infsnz      pressureRef+0       ; 16bit inc.
        incf        pressureRef+1
        bra         alt_menu_recompute  ; then recompute altitude.

;---- Decrement sea level pressure -------------------------------------------        

alt_menu_minus1:
        movlb       HIGH(pressureRef)   ; Setup our own ram bank
        decf        pressureRef+0       ; 16bit decrement
        movlw       0
        subwfb      pressureRef+1

alt_menu_recompute:
        rcall       compute_altitude    ; Recompute altitude
        movlb       1                   ; Go back to normal bank1
        bra         altimeter_menu_2

;---- Exit altimeter menu ----------------------------------------------------
alt_menu_exit:
    	movlw	.5                      ; reset position to Altimeter line.
    	movwf	menupos					; 
    	goto	more_menu2				; in the More... menu.
