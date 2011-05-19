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


; routines for Intersema MS5535A, MS5541B and MS5541C
; history:
; 2005-09-26: Written by Matthias Heinrichs, info@heinrichsweikamp.com
; 2008-08-21: MH last updated, with second order compensation.
; 2011-01-19: jDG Clean up using true signed arithmetics.
; known bugs:
; ToDo: 

;=============================================================================
; Expose internal variables, to ease debug:
    global D1, D2
    global C1, C2, C3, C4, C5, C6
    global xdT, xdT2, OFF, SENS, amb_pressure_avg, temperature_avg

;=============================================================================
calculate_compensation:
    ; calculate UT1 = 8*C5 + 10000 (u16 range 10.000 .. +42.760)
	clrf	isr_xA+1
	movlw	d'8'
	movwf	isr_xA+0
	movff	C5+0,isr_xB+0
	movff	C5+1,isr_xB+1
	call	isr_unsigned_mult16x16      ;isr_xA*isr_xB=isr_xC
	movlw   LOW		d'10000'
	addwf   isr_xC+0, f
	movlw   HIGH 	d'10000'
	addwfc  isr_xC+1, f			        ;isr_xC= 8*C5 + 10000
	
	; xdT = D2 - UT1    (s16 range -11.400 .. +12.350)
	movf   isr_xC+0,W                   ;  Get Value to be subtracted
	subwf  D2+0,W             	        ;  Do the Low Byte
	movwf  xdT+0
	movf   isr_xC+1,W                   ;  Then the high byte.
	subwfb D2+1,W
	movwf  xdT+1

    ; Second order temperature calculation
    ; xdT/128 is in range -89..+96, hence signed 8bit. dT/128 = (2*dT)/256
    rlcf    xdT+0,W                     ; put hit bit in carry.
    rlcf    xdT+1,W                     ; inject in high byte.
    movwf   isr_xA+0                    ; and put result in low byte.
    clrf    isr_xA+1
    btfsc   xdT+1,7                     ; If dT < 0
    setf    isr_xA+1                    ; then signextend to -1
	movff	isr_xA+0,isr_xB+0           ; copy A to B
	movff	isr_xA+1,isr_xB+1
	call	isr_signed_mult16x16        ; dT*dT --> xC (32 bits)

	; dT >= 0: divide by 8, ie. 3 shifts rights.
	; dT <  0: divide by 2, ie. 1 shifts rights.
    movlw   .3
	btfss	xdT+1,7                     ; Was dT negatif ?
	movlw   .1
calc_loop_1:
    bcf     STATUS,C                    ;dT^2 is positiv, so injected zeros.
    rrcf    isr_xC+1,F
    rrcf    isr_xC+0,F
    decfsz  WREG
    bra     calc_loop_1

    movf    isr_xC+0,W                  ; dT2 = dT - (dT/128)*(dT/128)/(2 ...or... 8)
	subwf   xdT+0,W
	movwf   xdT2+0
	movf    isr_xC+1,W
	subwfb  xdT+1,W
	movwf   xdT2+1

    ; Calculate OFF = C2 + ((C4-250)*dT2)/2^12 + 10000
    ; (range +9.246 .. +18.887)
	movlw   LOW(-.250)                  ; C4 - 250 --> A
	addwf	C4+0,W
	movwf   isr_xA+0
	movlw   -1                          ; HIGH(- .250) is not hunderstood...
	addwfc  C4+1,W
	movwf   isr_xA+1
	
	movff   xdT2+0,isr_xB+0             ; dT2 --> B
	movff   xdT2+1,isr_xB+1
	call    isr_signed_mult16x16
    movlw   .12-.8                      ; A 12bit shift = 1 byte + 4 bits.
    call    isr_shift_C31

    movlw   LOW(.10000)                 ; Add 10000
    addwf   isr_xC+1,F
    movlw   HIGH(.10000)
    addwfc  isr_xC+2,F
    
    movf    C2+0,W                      ; Add C2, and save into OFF
	addwf   isr_xC+1,W
	movwf   OFF+0
	movf	C2+1,W
	addwfc  isr_xC+2,W
	movwf   OFF+1

    ; Calculate SENS = C1/2 + ((C3+200)*dT)/2^13 + 3000
    movlw   LOW(.200)                   ; C3+200 --> A
    addwf   C3+0,W
    movwf   isr_xA+0
    movlw   HIGH(.200)
    addwfc  C3+1,W
    movwf   isr_xA+1
                                        ; B still contains dT2
	call    isr_signed_mult16x16        ; A*B --> C
    movlw   .13-.8                      ; A 13bit shift = 1 byte + 5 bits.
    call    isr_shift_C31
    
    bcf     STATUS,C                    ; SENS = C1 / 2
    rrcf    C1+1,W
    movwf   SENS+1
    rrcf    C1+0,W
    movwf   SENS+0

    movlw   LOW(.3000)                  ; Add 3000
    addwf   isr_xC+1,F
    movlw   HIGH(.3000)
    addwfc  isr_xC+2,F

    movf    isr_xC+1,W                  ; And sum into SENS
    addwf   SENS+0,F
    movf    isr_xC+2,W
    addwfc  SENS+1,F

    ; calculate amb_pressure = (sens * (d1-off))/2^12 + 1000
    movf    OFF+0,W                      ; d1-off --> a
    subwf   D1+0,W
    movwf   isr_xA+0
    movf    OFF+1,W
    subwfb  D1+1,W
    movwf   isr_xA+1

	movff   SENS+0,isr_xB+0             ; sens --> b
	movff   SENS+1,isr_xB+1
	call    isr_signed_mult16x16
    movlw   .12-.8                      ; a 12bit shift = 1 byte + 4 bits.
    call    isr_shift_C31

    movlw   LOW(.1000)                  ; add 1000
    addwf   isr_xC+1,F
    movlw   HIGH(.1000)
    addwfc  isr_xC+2,F

	btfss	simulatormode_active		; are we in simulator mode?
	bra		calc_compensation_2			; no

	movff	sim_pressure+0,isr_xC+1	    ; override readings with simulator values
	movff	sim_pressure+1,isr_xC+2
	
calc_compensation_2:
    movf    isr_xC+1,W                  ; Then sum_up to pressure averaging buffer.
    addwf   amb_pressure_avg+0,F
    movf    isr_xC+2,W
    addwfc  amb_pressure_avg+1,F

    ; calculate temp = 200 + dT*(C6+100)/2^11
    movlw   LOW(.100)                   ; C6 + 100 --> A
    addwf   C6+0,W
    movwf   isr_xA+0
    movlw   HIGH(.100)
    addwfc  C6+1,W
    movwf   isr_xA+1

    movff   xdT2+0,isr_xB+0             ; dT2 --> B
    movff   xdT2+1,isr_xB+1
	call    isr_signed_mult16x16        ; A*B
    movlw   .11-.8                      ; A 12bit shift = 1 byte + 3 bits.
    call    isr_shift_C31

    movlw   LOW(.200)                   ; Add 200
    addwf   isr_xC+1,F
    movlw   HIGH(.200)
    addwfc  isr_xC+2,F

    movf    isr_xC+1,W
    addwf   temperature_avg+0,F
    movf    isr_xC+2,W
    addwfc  temperature_avg+1,F

	return			                    ; Fertig mit allem

;=============================================================================
get_pressure_start:
	rcall	reset_MS5535A
	movlw	b'10100000'	;+3*high as start and 1+low as stop!
get_pressure_start2:
	movwf	isr1_temp
	movlw	d'12'
	movwf	clock_count
	rcall	send_data_MS55535A
	return

get_pressure_value:
#ifndef TESTING
	; Use register injection instead when in MPLab Sim emulation...
	rcall	get_2bytes_MS5535A
	movff	dMSB,D1+1	
	movff	dLSB,D1+0
#endif
	return

;=============================================================================
get_temperature_start:
	rcall	reset_MS5535A
	movlw	b'10010000'	;+3*high as start and 1+low as stop!
	bra		get_pressure_start2	; continue in "get_pressure"

get_temperature_value:
#ifndef TESTING
	; Use register injection instead...
	rcall	get_2bytes_MS5535A
	movff	dMSB,D2+1
	movff	dLSB,D2+0
#endif
	return

;=============================================================================
get_calibration_data:
	rcall	reset_MS5535A
	movlw	d'13'
	movwf	clock_count
	movlw	b'01010100'	;+3*high as start and 1+low as stop!
	movwf	isr1_temp
	rcall	send_data_MS55535A
	rcall	get_2bytes_MS5535A

#ifdef TESTING
    movlw   LOW(.18556)
    movff   WREG,W1+0
    movlw   HIGH(.18556)
    movff   WREG,W1+1
#else
	movff	dMSB,W1+1	
	movff	dLSB,W1+0
#endif

	movlw	d'13'
	movwf	clock_count
	movlw	b'01011000'	;+3*high as start and 1+low as stop!
	movwf	isr1_temp
	rcall	send_data_MS55535A
	rcall	get_2bytes_MS5535A
#ifdef TESTING
    movlw   LOW(.49183)
    movff   WREG,W2+0
    movlw   HIGH(.49183)
    movff   WREG,W2+1
#else
	movff	dMSB,W2+1	
	movff	dLSB,W2+0
#endif

	movlw	d'13'
	movwf	clock_count
	movlw	b'01100100'	;+3*high as start and 1+low as stop!
	movwf	isr1_temp
	rcall	send_data_MS55535A
	rcall	get_2bytes_MS5535A
#ifdef TESTING
    movlw   LOW(.22354)
    movff   WREG,W3+0
    movlw   HIGH(.22354)
    movff   WREG,W3+1
#else
	movff	dMSB,W3+1	
	movff	dLSB,W3+0
#endif

	movlw	d'13'
	movwf	clock_count
	movlw	b'01101000'	;+3*high as start and 1+low as stop!
	movwf	isr1_temp
	rcall	send_data_MS55535A
	rcall	get_2bytes_MS5535A
#ifdef TESTING
    movlw   LOW(.28083)
    movff   WREG,W4+0
    movlw   HIGH(.28083)
    movff   WREG,W4+1
#else
	movff	dMSB,W4+1	
	movff	dLSB,W4+0
#endif

; calculate C1 (16Bit)
	movff	W1+1, C1+1
	bcf		STATUS,C
	rrcf	C1+1
	bcf		STATUS,C
	rrcf	C1+1
	bcf		STATUS,C
	rrcf	C1+1
	movff	W1+0, C1+0
	bsf		STATUS,C
	btfss	W1+1,0
	bcf		STATUS,C
	rrcf	C1+0
	bsf		STATUS,C
	btfss	W1+1,1
	bcf		STATUS,C
	rrcf	C1+0
	bsf		STATUS,C
	btfss	W1+1,2
	bcf		STATUS,C
	rrcf	C1+0

; calculate C2 (16Bit)
	movff	W2+0, C2+0
	bsf		STATUS,C
	btfss	W2+1,0
	bcf		STATUS,C
	rrcf	C2+0
	bsf		STATUS,C
	btfss	W2+1,1
	bcf		STATUS,C
	rrcf	C2+0
	bsf		STATUS,C
	btfss	W2+1,2
	bcf		STATUS,C
	rrcf	C2+0
	bsf		STATUS,C
	btfss	W2+1,3
	bcf		STATUS,C
	rrcf	C2+0
	bsf		STATUS,C
	btfss	W2+1,4
	bcf		STATUS,C
	rrcf	C2+0
	bsf		STATUS,C
	btfss	W2+1,5
	bcf		STATUS,C
	rrcf	C2+0

	movff	W2+1, C2+1
	bsf		STATUS,C
	btfss	W1+0,0
	bcf		STATUS,C
	rrcf	C2+1
	bsf		STATUS,C
	btfss	W1+0,1
	bcf		STATUS,C
	rrcf	C2+1
	bsf		STATUS,C
	btfss	W1+0,2
	bcf		STATUS,C
	rrcf	C2+1
	bcf		STATUS,C
	rrcf	C2+1
	bcf		STATUS,C
	rrcf	C2+1
	bcf		STATUS,C
	rrcf	C2+1

; calculate C3 (16Bit)
	movff	W3+1,C3+0
	bsf		STATUS,C
	btfss	W3+0,7
	bcf		STATUS,C
	rlcf	C3+0
	bsf		STATUS,C
	btfss	W3+0,6
	bcf		STATUS,C
	rlcf	C3+0
	clrf	C3+1
	btfsc	W3+1,7
	bsf		C3+1,1
	btfsc	W3+1,6
	bsf		C3+1,0
	
; calculate C4 (16Bit)	
	movff	W4+1,C4+0
	bsf		STATUS,C
	btfss	W4+0,7
	bcf		STATUS,C
	rlcf	C4+0
	clrf	C4+1
	btfsc	W4+1,7
	bsf		C4+1,0
	
; calculate C5 (16Bit)		
	movff	W3+0,C5+0
	bcf		C5+0,6
	btfsc	W2+0,0
	bsf		C5+0,6
	bcf		C5+0,7
	btfsc	W2+0,1
	bsf		C5+0,7
	clrf	C5+1
	btfsc	W2+0,2
	bsf		C5+1,0
	btfsc	W2+0,3
	bsf		C5+1,1
	btfsc	W2+0,4
	bsf		C5+1,2
	btfsc	W2+0,5
	bsf		C5+1,3

; calculate C6 (16Bit)		
	clrf	C6+1
	movff	W4+0,C6+0
	bcf		C6+0,7

	bcf		no_sensor_int		; enable sensor interrupts
	return

;=============================================================================
reset_MS5535A_one:
	bsf		sensor_SDO
	nop
	bsf		sensor_CLK
	nop
	nop
	nop
	nop
	nop
	nop
	bcf		sensor_CLK	
	return	

reset_MS5535A_zero:
	bcf		sensor_SDO
	nop
	bsf		sensor_CLK
	nop
	nop
	nop
	nop
	nop
	nop
	bcf		sensor_CLK	
	return	

reset_MS5535A:
	rcall	reset_MS5535A_one			;0
	rcall	reset_MS5535A_zero
	rcall	reset_MS5535A_one
	rcall	reset_MS5535A_zero
	rcall	reset_MS5535A_one
	rcall	reset_MS5535A_zero
	rcall	reset_MS5535A_one
	rcall	reset_MS5535A_zero
	rcall	reset_MS5535A_one
	rcall	reset_MS5535A_zero
	rcall	reset_MS5535A_one
	rcall	reset_MS5535A_zero
	rcall	reset_MS5535A_one
	rcall	reset_MS5535A_zero
	rcall	reset_MS5535A_one
	rcall	reset_MS5535A_zero			;15
	rcall	reset_MS5535A_zero	
	rcall	reset_MS5535A_zero	
	rcall	reset_MS5535A_zero	
	rcall	reset_MS5535A_zero	
	rcall	reset_MS5535A_zero			;20
	return

get_2bytes_MS5535A:
	movlw	d'8'
	movwf	clock_count
	rcall	recieve_loop
	movff	isr1_temp,dMSB

	movlw	d'8'
	movwf	clock_count
	rcall	recieve_loop
	movff	isr1_temp,dLSB
	bsf		sensor_CLK	
	nop
	nop
	nop
	nop
	nop
	nop
	bcf		sensor_CLK	
	return

recieve_loop:
	bsf		sensor_CLK	
	nop
	nop
	nop
	nop
	nop
	nop
	bcf		sensor_CLK	
	btfss	sensor_SDI	;MSB first
	bcf		STATUS,C
	btfsc	sensor_SDI	;MSB first
	bsf		STATUS,C
	rlcf	isr1_temp,F
	decfsz	clock_count,F
	bra		recieve_loop
	return

send_data_MS55535A:
	; send three startbits first
	bcf		sensor_CLK
	bsf		sensor_SDO
	movlw	d'3'
	subwf	clock_count,F	; total bit counter
	bsf		sensor_CLK		
	nop
	nop
	nop
	nop
	nop
	nop
	bcf		sensor_CLK	
	nop
	nop
	nop
	nop
	nop
	nop
	bsf		sensor_CLK	
	nop
	nop
	nop
	nop
	nop
	nop
	bcf		sensor_CLK	
	nop
	nop
	nop
	nop
	nop
	nop
	bsf		sensor_CLK	
	nop
	nop
	nop
	nop
	nop
	nop
	bcf		sensor_CLK	
	; now send 8 bytes from isr_temp1 and fill-up with zeros
datenbits:
	btfss	isr1_temp,7	;MSB first
	bcf		sensor_SDO
	btfsc	isr1_temp,7	;MSB first
	bsf		sensor_SDO
	bcf		STATUS,C
	rlcf	isr1_temp

	bsf		sensor_CLK	
	nop
	nop
	nop
	nop
	nop
	nop
	bcf		sensor_CLK	

	decfsz	clock_count,F
	bra		datenbits
	return
