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
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 9/26/05
; last updated: 08/08/31
; known bugs:
; ToDo: 

; with second order temperature compensation

calculate_compensation:
; calculate xdT
	clrf	isr_xA+1
	movlw	d'8'
	movwf	isr_xA+0
	movff	C5+0,isr_xB+0
	movff	C5+1,isr_xB+1
	call	isr_mult16x16		;isr_xA*isr_xB=isr_xC
	movlw   LOW		d'10000'
	addwf   isr_xC+0, f
	movlw   HIGH 	d'10000'
	addwfc  isr_xC+1, f			;isr_xC= 8*C5 + 10000
	movff	D2+0,isr_sub_a+0
	movff	D2+1,isr_sub_a+1
	movff	isr_xC+0,isr_sub_b+0
	movff	isr_xC+1,isr_sub_b+1
	call	isr_sub16	;  isr_sub_c = isr_sub_a - isr_sub_b
	movff	isr_sub_c+0,xdT+0
	movff	isr_sub_c+1,xdT+1

; Second order temperature calculation
	btfsc	neg_flag_isr		
	bra		dTzero_yes
;	dT>0
	bcf		neg_flag_xdT
	movff	xdT+0,isr_xA+0
	movff	xdT+1,isr_xA+1
	movff	xdT+0,isr_xB+0
	movff	xdT+1,isr_xB+1
	call	isr_mult16x16		;isr_xA*isr_xB=isr_xC
	movlw	d'17'			; 2^17=(128*128)*8
	movwf	isr_divB
	call	isr_div32			; isr_xC=isr_xC(32Bit)/2^isr_divB (isr_divB: 8Bit only!)
	movff	xdT+0,isr_sub_a+0
	movff	xdT+1,isr_sub_a+1
	movff	isr_xC+0,isr_sub_b+0
	movff	isr_xC+1,isr_sub_b+1
	call	isr_sub16	;  isr_sub_c = isr_sub_a - isr_sub_b
	movff	isr_sub_c+0,xdT2+0
	movff	isr_sub_c+1,xdT2+1
	bra		OFF_calc			; Done
		
dTzero_yes:
;	dT<0
	bsf		neg_flag_xdT
	movff	xdT+0,isr_xA+0
	movff	xdT+1,isr_xA+1
	movff	xdT+0,isr_xB+0
	movff	xdT+1,isr_xB+1
	call	isr_mult16x16		;isr_xA*isr_xB=isr_xC
	movlw	d'15'			; 2^15=(128*128)*2
	movwf	isr_divB
	call	isr_div32			; isr_xC=isr_xC(32Bit)/2^isr_divB (isr_divB: 8Bit only!)

	movf	xdT+0,W
	addwf	isr_xC+0,F
	movf	xdT+1,W
	addwfc	isr_xC+1,F	
	movff	isr_xC+0,xdT2+0
	movff	isr_xC+1,xdT2+1

OFF_calc:
; calculate OFF
	movff	C4+0,isr_sub_a
	movff	C4+1,isr_sub_a+1
	movlw	d'250'
	movwf	isr_sub_b
	clrf	isr_sub_b+1
	call	isr_sub16				; (C4-250) - Sets neg_flag_isr!
	movff	isr_sub_c,isr_xA
	movff	isr_sub_c+1,isr_xA+1
	movff	xdT+0,isr_xB
	movff	xdT+0+1,isr_xB+1
	call	isr_mult16x16			; (C4-250)*dT
	movff	isr_xC+0,isr_divA
	movff	isr_xC+1,isr_divA+1
	movlw	d'12'
	movwf	isr_divB
	call	isr_div16				; [(C4-250)*dT]/2^12
	movff	isr_divA+0,isr_xC+0	
	movff	isr_divA+1,isr_xC+1			; isr_xC= {[(C4-250)*dT]/2^12}
	btfss	neg_flag_isr			; neg_flag_isr=1?
	bra		OFF_calc2			; Yes, do C2 - isr_xC
								; no, so do C2 + isr_xC
	movf	C2+0,W
	addwf   isr_xC+0, f				
	movf	C2+1,W
	addwfc  isr_xC+1, f				; isr_xC= C2 + {[(C4-250)*dT/2^12]}
OFF_calc3:	
	movlw   LOW	d'10000'
	addwf   isr_xC+0, f
	movlw   HIGH d'10000'
	addwfc  isr_xC+1, f				; isr_xC=[(C4-250)*dT/2^12] + 10000
	movff	isr_xC+0,OFF+0
	movff	isr_xC+1,OFF+1
	bra		calculate_SENS		; Done with OFF

OFF_calc2:	
	movff	C2+0,isr_sub_a+0
	movff	C2+1,isr_sub_a+1
	movff	isr_xC+0,isr_sub_b+0
	movff	isr_xC+1,isr_sub_b+1
	call	isr_sub16	;  isr_sub_c = isr_sub_a - isr_sub_b
						; isr_xC= C2 - {[(C4-250)*dT/2^12]}
	movff	isr_sub_c+0,isr_xC+0
	movff	isr_sub_c+1,isr_xC+1			; Done with OFF
	bra		OFF_calc3
	
calculate_SENS:
	movff	C3+0, C3_temp+0
	movff	C3+1, C3_temp+1
	movlw   d'200'
	addwf   C3_temp+0, f
	movlw   d'0'
	addwfc  C3_temp+1, f		; C3 no longer valid!
	movff	C3_temp+0, isr_xA
	movff	C3_temp+1, isr_xA+1
	movff	xdT+0, isr_xB
	movff	xdT+1, isr_xB+1
	call	isr_mult16x16
	movff	isr_xC+0,isr_divA
	movff	isr_xC+1,isr_divA+1
	movlw	d'13'
	movwf	isr_divB
	call	isr_div16
	movff	isr_divA,SENS+0
	movff	isr_divA+1,SENS+1
	movff	C1+0,isr_divA
	movff	C1+1,isr_divA+1
	movlw	d'1'
	movwf	isr_divB
	call	isr_div16
	movf	isr_divA,W
	addwf   SENS+0, f
	movf	isr_divA+1,W
	addwfc  SENS+1, f
	movlw   d'184'
	addwf   SENS+0, f
	movlw   d'11'
	addwfc  SENS+1, f

; calculate amb_pressure
	movff	D1+0,isr_sub_a
	movff	D1+1,isr_sub_a+1
	movff	OFF+0,isr_sub_b
	movff	OFF+1,isr_sub_b+1
	call	isr_sub16
	movff	isr_sub_c,isr_xA
	movff	isr_sub_c+1,isr_xA+1
	movff	SENS+0,isr_xB
	movff	SENS+1,isr_xB+1
	call	isr_mult16x16
	movlw	d'12'
	movwf	isr_divB
	call	isr_div32
	btfsc	neg_flag_isr		; invert isr_xC+0 and isr_xC+1
	call	isr_invert_xC
	movlw   LOW 	d'1000'
	addwf   isr_xC+0, f
	movlw   HIGH 	d'1000'
	addwfc  isr_xC+1, f
	movff	isr_xC+0,amb_pressure+0
	movff	isr_xC+1,amb_pressure+1

	btfss	simulatormode_active		; are we in simulator mode?
	bra		calc_pressure_done			; no

	movff	sim_pressure+0,amb_pressure+0	; override readings with simulator values
	movff	sim_pressure+1,amb_pressure+1
	
calc_pressure_done:

; calculate temp	
	movff	C6+0, C3_temp+0
	movff	C6+1, C3_temp+1
	movlw   d'100'
	addwf   C3_temp+0, f
	movlw   d'0'
	addwfc  C3_temp+1, f
	movff	C3_temp+0,isr_xA+0
	movff	C3_temp+1,isr_xA+1
	movff	xdT2+0,isr_xB+0	
	movff	xdT2+1,isr_xB+1
	call	isr_mult16x16
	movlw	d'11'
	movwf	isr_divB
	call	isr_div32
	bcf		neg_temp				; Temperatur positive 
	
	btfsc	neg_flag_xdT			; was xdT negative?
	bra		neg_sub_temp			; yes,  200 - dT*(....
									; No, 200 + dT*(....
;	movf	temperature_correction,W
;	addlw   d'200'
;	btfsc	STATUS,C
;	incf	isr_xC+1,F

	movlw	d'200'
	addwf   isr_xC+0, f
	movlw   d'0'
	addwfc  isr_xC+1, f
	movff	isr_xC+0,temperature+0
	movff	isr_xC+1,temperature+1
	return			; done

neg_sub_temp:					; 200 - dT*(....
;	movf	temperature_correction,W
;	addlw   d'200'
;	btfsc	STATUS,C
;	decf	isr_xC+1,F

	movlw	d'200'
neg_sub_temp3:
	movwf	isr_sub_a+0
	clrf	isr_sub_a+1
	movff	isr_xC+0, isr_sub_b+0
	movff	isr_xC+1, isr_sub_b+1
	call	isr_sub16				; isr_sub_c = isr_sub_a - isr_sub_b
	btfsc	neg_flag_isr			; below zero?
	bsf		neg_temp			; temperature negative!

	movff	isr_sub_c+0,temperature+0
	movff	isr_sub_c+1,temperature+1
	return			; Fertig mit allem


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
	rcall	get_2bytes_MS5535A
	movff	dMSB,D1+1	
	movff	dLSB,D1+0
	return

get_temperature_start:
	rcall	reset_MS5535A
	movlw	b'10010000'	;+3*high as start and 1+low as stop!
	bra		get_pressure_start2	; continue in "get_pressure"

get_temperature_value:
	rcall	get_2bytes_MS5535A
	movff	dMSB,D2+1
	movff	dLSB,D2+0
	return

get_calibration_data:
;	; read addional temperature correction from internal EEPROM 0x100
;	bsf		no_sensor_int				; No sensor interupt!
;	clrf	temperature_correction		; clear compensation value
;	movlw	LOW		0x100
;	movwf	EEADR
;	movlw	HIGH	0x100
;	movwf	EEADRH
;	call	read_eeprom
;	clrf	EEADRH						; Only 256Bytes used in normal program
;	movlw	d'200'						; limit value
;	cpfsgt	EEDATA						; EEDATA>200?
;	movff	EEDATA, temperature_correction	; No, Store for compensation
;	
	rcall	reset_MS5535A
	movlw	d'13'
	movwf	clock_count
	movlw	b'01010100'	;+3*high as start and 1+low as stop!
	movwf	isr1_temp
	rcall	send_data_MS55535A
	rcall	get_2bytes_MS5535A
	movff	dMSB,W1+1	
	movff	dLSB,W1+0

	movlw	d'13'
	movwf	clock_count
	movlw	b'01011000'	;+3*high as start and 1+low as stop!
	movwf	isr1_temp
	rcall	send_data_MS55535A
	rcall	get_2bytes_MS5535A
	movff	dMSB,W2+1	
	movff	dLSB,W2+0

	movlw	d'13'
	movwf	clock_count
	movlw	b'01100100'	;+3*high as start and 1+low as stop!
	movwf	isr1_temp
	rcall	send_data_MS55535A
	rcall	get_2bytes_MS5535A
	movff	dMSB,W3+1	
	movff	dLSB,W3+0

	movlw	d'13'
	movwf	clock_count
	movlw	b'01101000'	;+3*high as start and 1+low as stop!
	movwf	isr1_temp
	rcall	send_data_MS55535A
	rcall	get_2bytes_MS5535A
	movff	dMSB,W4+1	
	movff	dLSB,W4+0

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
