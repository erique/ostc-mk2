
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


; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 10/30/05
; last updated: 05/16/08
; known bugs:
; ToDo:

; the timer1 module interrupts every 62.5ms (16x/second)
; temperature and pressure is averaged over 4 measurements
; flag pressure_refresh is set every 500ms 
; and provides accurate pressure (+/-1mBar stable) and temperature (0.1C stable)

uartint:
		btfsc	simulatormode_active		; are we in simulatormode?
		bra		simulator_int				; Yes, reading is depth in m!

		movff	RCREG,uart1_temp
		movlw	d'96'
		subwf	uart1_temp,F
		dcfsnz	uart1_temp,F				; "a"
		bsf		dump_external_eeprom		; set flag
		dcfsnz	uart1_temp,F				; "b"
		bsf		uart_settime				; set flag
		dcfsnz	uart1_temp,F				; "c"
		bsf		simulatormode_active		; set flag
		dcfsnz	uart1_temp,F				; "d"
		bsf		internal_eeprom_write		; set flag
		dcfsnz	uart1_temp,F				; "e"
		bsf		uart_send_hash				; set flag
		dcfsnz	uart1_temp,F				; "f"
		bsf		uart_compensate_temp		; set flag
		dcfsnz	uart1_temp,F				; "g"
		bsf		uart_send_int_eeprom		; set flag
		dcfsnz	uart1_temp,F				; "h"
		bsf		uart_reset_decodata			; set flag
		dcfsnz	uart1_temp,F				; "i"
		bsf		internal_eeprom_write2		; set flag
		dcfsnz	uart1_temp,F				; "j"
		bsf		uart_send_int_eeprom2		; set flag
		dcfsnz	uart1_temp,F				; "k"
		bsf		uart_store_tissue_data		; set flag


uartint1:
		movf	RCREG,w						; unload RCREG in stand-alone simulator mode
		bcf		PIR1,RCIF					; Clear flag
		bcf		RCSTA,CREN					; Clear receiver status
		bsf		RCSTA,CREN
		return

simulator_int:
		btfsc	standalone_simulator		; ignore in standalone simulator mode
		bra		uartint1

		call	set_LEDusb
		tstfsz	RCREG						; =0x00?
		bra		simulator_int1				; No
		incf	RCREG,F						; Yes, so force RCREG=1

simulator_int1:
		movf	RCREG,w						; depth in m
		mullw	d'100'						; result will be mbar
		movff	PRODL,sim_pressure+0		; stored for pressure overwrite
		movff	PRODH,sim_pressure+1
		bra		uartint1					; exit uart int

schalter_links:								; 
		bcf		INTCON,INT0IF				; Clear flag

		btfsc	T0CON,TMR0ON				; Timer0 running?
		bra		timer0_restart				; Yes, restart

		bsf		switch_left					; Set flag, button press is OK

		bsf		T0CON,TMR0ON				; Start Timer 0
		return


schalter_rechts:							; 
		bcf		INTCON3,INT1IF				; Clear flag

		btfsc	T0CON,TMR0ON				; Timer0 running?
		bra		timer0_restart				; Yes, restart

		bsf		switch_right				; Set flag, button press is OK

		bsf		T0CON,TMR0ON				; Start Timer 0
		return

timer0_restart:
		bcf		INTCON,TMR0IF				; Clear flag

		clrf	T0CON						; Timer0
		clrf	TMR0H
		clrf	TMR0L
		bsf		T0CON,TMR0ON				; Start Timer 0
		return

timer0int:
		bcf		INTCON,TMR0IF				; Clear flag
		bcf		T0CON,TMR0ON				; Stop Timer 0
		clrf	TMR0H
		clrf	TMR0L
		return
		

timer0int_left_reset:
		bcf		INTCON2, INTEDG0			; Interrupt on faling edge again
		bcf		switch_left_isr				; Clear flag, button press is done

		movlw	T0CON_debounce				; Timer0
		movwf	T0CON

		bsf		T0CON,TMR0ON				; Start Timer 0
		return

timer0int_left:
		bsf		INTCON2, INTEDG0			; Interrupt on rising edge again
		return

timer0int_right_reset:
		bcf		INTCON2, INTEDG1			; Interrupt on faling edge again
		bcf		switch_right_isr			; Clear flag, button press is done

		movlw	T0CON_debounce				; Timer0
		movwf	T0CON

		bsf		T0CON,TMR0ON				; Start Timer 0
		return

timer0int_right:
		bsf		INTCON2, INTEDG1			; Interrupt on rising edge again
		return

timer3int:
		bcf		PIR2,TMR3IF					; Clear flag
		bcf		T3CON,TMR0ON				; Stop Timer 3
		bcf		T2CON,2						; stop Timer 2
		return

timer1int:
		bcf		PIR1,TMR1IF					; Clear flag

timer1int_debug:

		call	clear_LEDr					; LEDr off (For charge indicator)

		movlw	0x08						; Timer1 int after 62.5ms (=16/second)
		cpfslt	TMR1H						; Did we miss a 1/16 second?
		incf	timer1int_counter1,F		; Yes, add extra 1/16 second

		movlw	0x08						; Timer1 int after 62.5ms (=16/second)
		subwf	TMR1H,F			
	
		incf	timer1int_counter1,F
		movlw	d'15'						; One second 16
		cpfsgt	timer1int_counter1			 
		bra		sensor_int_pre				; only pressure sensor
		call	RTCisr						; adjust time, then query pressure sensor

sensor_int_pre:
		btfss	sleepmode					; In sleepmode?
		bra		sensor_int					; No
		return

sensor_int:
		btfsc		no_sensor_int			; No sensor interrupt (because it's addressed during sleep)
		return						

		incf		timer1int_counter2,F		; counts to eight for state maschine

		movlw		d'1'
		cpfseq		timer1int_counter2		; State 1?
		bra			sensor_int1				; No

		bcf			pressure_refresh			; clear flags
		clrf		isr3_temp+0				; pressure average registers
		clrf		isr3_temp+1
		clrf		temperature_temp+0
		clrf		temperature_temp+1
sensor_int0:
		call		get_temperature_value		; State 1: Get temperature
		call		get_pressure_start	 	; and start pressure integration.
		return						; Done.
sensor_int1:
		movlw		d'2'
		cpfseq		timer1int_counter2		; State 2?
		bra			sensor_int2				; No
		
sensor_int1_1:
		call		get_pressure_value		; State2: Get pressure (51us)
		call		get_temperature_start		; and start temperature integration (73,5us)
		call		calculate_compensation		; calculate temperature compensated pressure (233us)
		movf		amb_pressure+0,W
		addwf		isr3_temp+0				; average pressure
		movf		amb_pressure+1,W
		addwfc		isr3_temp+1
		movf		temperature+0,W
		addwf		temperature_temp+0		; average temperature
		movf		temperature+1,W
		addwfc		temperature_temp+1
		return		
sensor_int2:
		movlw		d'3'
		cpfseq		timer1int_counter2		; State 3?
		bra			sensor_int3				; No
		bra			sensor_int0				; Yes, but same as State 1!
sensor_int3:
		movlw		d'4'
		cpfseq		timer1int_counter2		; State 4?
		bra			sensor_int4				; No
		bra			sensor_int1_1			; Yes, but same as State 2!
sensor_int4:
		movlw		d'5'					
		cpfseq		timer1int_counter2		; State 5?
		bra			sensor_int5				; No
		bra			sensor_int0				; Yes, but same as State 1!
sensor_int5:
		movlw		d'6'
		cpfseq		timer1int_counter2		; State 6?
		bra			sensor_int6				; No
		bra			sensor_int1_1			; Yes, but same as State 2!
sensor_int6:
		movlw		d'7'
		cpfseq		timer1int_counter2		; State 7?
		bra			sensor_int7				; No
		bra			sensor_int0				; Yes, but same as State 1!
sensor_int7:
		rcall		sensor_int1_1			; Do State 2...
		clrf		timer1int_counter2		; ..then reset State counter...
		movlw		d'2'					; and calculate average!
		movwf		isr2_temp				
sensor_int8:		
		bcf			STATUS,C
		rrcf		isr3_temp+1				; isr3_temp / 2
		rrcf		isr3_temp+0
		bcf			STATUS,C
		rrcf		temperature_temp+1		; temperature_temp /2
		rrcf		temperature_temp+0
		decfsz		isr2_temp,F
		bra			sensor_int8				; once more
		
		movff		isr3_temp+1,amb_pressure+1	; copy into actual register
		movff		isr3_temp+0,amb_pressure+0

		movff		temperature_temp+1,temperature+1
		movff		temperature_temp+0,temperature+0

		bsf			pressure_refresh 			; Set flag! Temp and pressure were updated!

		btfss		simulatormode_active		; are we in simulator mode?
		bra			comp_air_pressure			; no

comp_air_pressure0:	
		movlw		LOW		d'1000'				; yes, so simulate 1Bar surface pressure
		movwf		last_surfpressure+0
		movlw		HIGH	d'1000'
		movwf		last_surfpressure+1

comp_air_pressure:
		bcf			neg_flag				
		movf		last_surfpressure+0,W		; compensate airpressure
		subwf   	amb_pressure+0,W             
		movwf   	rel_pressure+0			; rel_pressure stores depth!

		movf		last_surfpressure+1,W
		subwfb  	amb_pressure+1,W
		movwf   	rel_pressure+1
		btfss		STATUS,N				; result is below zero?
		return
		clrf		rel_pressure+0			; Yes, do not display negative depths
		clrf		rel_pressure+1			; e.g. when surface air pressure dropped during the dive
		return

RTCisr:			
		clrf		timer1int_counter1		; counts to 16 (one second / 62.5ms)
		bsf			onesecupdate			; we have a new second!

		bcf			STATUS,Z				; are we in dive mode?
		btfss		divemode
		bra			RTCisr2				; No, must be surface or sleepmode

		incf		samplesecs,F			; CF20 diving seconds done 
		decf		samplesecs_value,W		; holds CF20 value  (minus 1 into WREG)
		cpfsgt		samplesecs
		bra			RTCisr1				; no

		clrf		samplesecs				; clear counter...
		bsf			store_sample			; ...and set bit for profile storage
RTCisr1:		
; Increase re-setable average depth divetime counter
		incf		average_divesecs+0,F	; increase divetime registers	
		btfsc		STATUS,Z
		incf		average_divesecs+1,F	; increase divetime registers	

		btfss		divemode2				; displayed divetime is running?
		bra			RTCisr2					; No (e.g. too shallow)

		incf		divesecs,F				; increase divetime registers
		movlw		d'59'
		cpfsgt		divesecs
		bra			RTCisr1a
		clrf		divesecs
		bsf			realdive				; this bit is always set (again) if the dive is longer then one minute

		incf		divemins+0,F			; increase divemins
		btfsc		STATUS,Z
		incf		divemins+1,F			; and now do the realtime clock routine anyway
		
RTCisr1a:	
		btfss		FLAG_apnoe_mode			; Are we in Apnoe mode?
		bra			RTCisr2					; No, skip the following
		
		incf		apnoe_secs,F			; increase descent registers
		movlw		d'59'
		cpfsgt		apnoe_secs
		bra			RTCisr2
		clrf		apnoe_secs
		
		incf		apnoe_mins,F			; increase descent mins
		; Now, do the RTC routine....
RTCisr2:
		incf		secs,F					; adjusts seconds, minutes, hours, day, month and year. Checks for a leap year and works until 2099!
		movlw		d'59'
		cpfsgt		secs
		return
		clrf		secs
		bsf			oneminupdate
		incf		mins,F
		movlw		d'59'
		cpfsgt		mins
		return
		clrf		mins
		incf		hours,F
		movlw		d'23'
		cpfsgt		hours
		return
		clrf		hours
		incf		day,F
movlw	plus_time_correction			; Correct too slow clock
movwf	secs

						
check_date:
		movff		month,isr_divB		; new month?
		dcfsnz		isr_divB,F
		movlw		.31
		dcfsnz		isr_divB,F
		movlw		.28
		dcfsnz		isr_divB,F
		movlw		.31
		dcfsnz		isr_divB,F
		movlw		.30
		dcfsnz		isr_divB,F
		movlw		.31
		dcfsnz		isr_divB,F
		movlw		.30
		dcfsnz		isr_divB,F
		movlw		.31
		dcfsnz		isr_divB,F
		movlw		.31
		dcfsnz		isr_divB,F
		movlw		.30
		dcfsnz		isr_divB,F
		movlw		.31
		dcfsnz		isr_divB,F
		movlw		.30
		dcfsnz		isr_divB,F
		movlw		.31
		cpfsgt		day,1
		return
		movlw		.1
		movwf		day
		incf		month,F				
		movlw		.12					
		cpfsgt		month,1
		return
		movlw		.1
		movwf		month
		incf		year,F				
		return