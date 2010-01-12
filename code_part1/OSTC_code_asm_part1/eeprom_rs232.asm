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


; internal EEPROM and RS232 UART interface
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 02/01/06
; last updated: 090109
; known bugs:
; ToDo: 

write_int_eeprom	macro	eeprom_address
	movlw	eeprom_address
	call	write_int_eeprom_1
	endm

write_int_eeprom_1:
	movwf	EEADR
	bra		write_eeprom			; writes and "returns" after write

read_int_eeprom	macro	eeprom_address
	movlw	eeprom_address
	call	read_int_eeprom_1
	endm

read_int_eeprom_1:
	movwf	EEADR
	bra		read_eeprom					; reads and "returns" after write

internal_eeprom_access_b1:				; accesses internal EEPROM BANK 1 via the UART
	bcf		internal_eeprom_write2		; clear flag!
	movlw	d'1'
	movwf	EEADRH						;BANK1
	movlw	"i"
	bra		internal_eeprom_access1		; Continue with bank1 and bank0 common routines

internal_eeprom_access_b0:				; accesses internal EEPROM BANK 0 via the UART
	bcf		internal_eeprom_write		; clear flag!
	clrf	EEADRH						; Bank0
	movlw	"d"
;	bra		internal_eeprom_access1		; Continue with bank1 and bank0 common routines

internal_eeprom_access1:
	movwf	TXREG						; Send command echo ("i" or "d")
	bsf		no_sensor_int				; No Sensor Interrupt
	movlw	d'4'
	movwf	EEADR
	bcf		PIE1,RCIE					; no interrupt for UART
	bcf		PIR1,RCIF					; clear flag
	call	set_LEDusb					; LEDusb ON

internal_eeprom_access2:
	rcall	rs232_get_byte				; Get byte to write...
	movff	RCREG,EEDATA				; copy to write register
	call	set_LEDy					; show activity

	btfsc	rs232_recieve_overflow		; overflow recieved?
	bra		internal_eeprom_access3		; Yes, abort!

	rcall	write_eeprom				; No, write one byte
	call	clear_LEDy					
	movff	EEDATA,TXREG				; Send echo!
	rcall	rs232_wait_tx				; Wait for UART
	incfsz 	EEADR,F						; Do until EEADR rolls to zero
	bra		internal_eeprom_access2
internal_eeprom_access2a:
	call	clear_LEDusb				; LEDusb OFF
	bcf		PIR1,RCIF					; clear flag
	bsf		PIE1,RCIE					; re-enable interrupt for UART
	clrf	EEADRH						; Point to Bank0 again
	bcf		rs232_recieve_overflow		; Clear Flag
	bcf		no_sensor_int				; Renable Sensor Interrupt
	goto	restart

internal_eeprom_access3:				; Overflow! Abort writing
	movlw	0xFF
	movwf	TXREG						; Error Byte
	bra		internal_eeprom_access2a	; Quit

read_eeprom: 							; reads from internal eeprom
	bcf		EECON1,EEPGD
	bcf		EECON1,CFGS
	bsf		EECON1,RD
	return

write_eeprom:							; writes into internal eeprom
	bcf		EECON1,EEPGD
	bcf		EECON1,CFGS
	bsf		EECON1,WREN

	bcf		INTCON,GIE					; even the RTC will be delayed for the next 5 instructions...
	movlw	0x55		
	movwf	EECON2
	movlw	0xAA
	movwf	EECON2
	bsf		EECON1,WR
	bsf		INTCON,GIE					; ...but the flag for the ISR routines were still set, so they will interrupt now!

write_eep2:
	btfsc	EECON1,WR		
	bra 	write_eep2					; wait about 4ms...
	bcf		EECON1,WREN
	return



; RS232 Routines:
;enable_rs232_19k2_tx:
;	bsf		TRISC,6			; TX Pin 
;	movlw	b'00100100'			; initialise serial port for 19200/8/N/1 BRGH=1
;	movwf	TXSTA
;	return	
;
;disable_rs232_19k2_tx:
;	bcf		TRISC,6			; TX Pin 
;	movlw	b'00000100'			; Only receiver mode, BRGH=1
;	movwf	TXSTA
;	bsf		PORTC,6				; TX PIN
;	return	
;
;enable_rs232_19k2:
;	bsf		TRISC,6			; TX Pin IO Ports must be input in order to activate the module
;	bsf		TRISC,7			; RX Pin
;				
;	movlw	b'00100100'			; initialise serial port for 19200/8/N/1 BRGH=1
;	movwf	TXSTA
;	movlw	b'10000000'			
;	movwf	RCSTA
;	movlw	b'00001000'			; BRG16=1
;	movwf	BAUDCON
;	bsf		RCSTA,CREN				; Enable
;	movlw	d'0'
;	movwf	SPBRGH
;	movlw	d'207'				; Take care of the baud rate when changing Fosc!
;	movwf	SPBRG
;	clrf	RCREG
;	bcf		PIE1,RCIE			; disable interrupt for RS232
;	clrf	PIR1
;	return
;

enable_rs232:				;IO Ports must be input in order to activate the module
	bsf		TRISC,6			; TX Pin
	bsf		TRISC,7			; RX Pin

	movlw	b'00100100'			; BRGH=1
	movwf	TXSTA
	movlw	b'10010000'
	movwf	RCSTA
	movlw	b'00001000'
	movwf	BAUDCON
	clrf	SPBRGH
	movlw	d'34'				; Take care of the baud rate when changing Fosc!
	movwf	SPBRG
	clrf	RCREG
	clrf	PIR1
	bsf		PIE1,RCIE			; enable interrupt for RS232
	return

disable_rs232:
	clrf	TXSTA
	clrf	RCSTA
	bcf		PIE1,RCIE			; disable interrupt for RS232
	bcf		TRISC,6			; TX Pin
	bcf		TRISC,7			; RX Pin
	bcf		PORTC,6			; TX Pin
	bcf		PORTC,7			; RX Pin
	return

rs232_wait_tx:
	btfss	RCSTA,SPEN			; Transmitter active?
	return						; No, return!
	nop
	btfss	TXSTA,TRMT			; RS232 Busy?
	bra		rs232_wait_tx		; yes, wait...
	return						; Done.


rs232_get_byte:
	bcf		PIR1,RCIF		; clear flag
	bcf		rs232_recieve_overflow		; clear flag
	clrf 	uart1_temp
rs232_get_byte2:
	clrf 	uart2_temp
rs232_get_byte3:
	btfsc 	PIR1,RCIF		; data arrived?
	return					; data received

	nop						; Wait 1us * 255 * 255 = 65ms+x Timeout/Byte
	nop
	nop
	nop
	btfsc 	PIR1,RCIF		; data arrived?
	return	

	nop
	nop
	nop
	nop
	btfsc 	PIR1,RCIF		; data arrived?
	return	

	nop
	nop
	nop
	nop
	btfsc 	PIR1,RCIF		; data arrived?
	return	
	nop
	nop
	nop
	nop
	btfsc 	PIR1,RCIF		; data arrived?
	return	

	decfsz 	uart2_temp,F
	bra 	rs232_get_byte3
	decfsz 	uart1_temp,F
	bra		rs232_get_byte2
						; timeout occoured (about 20ms)
	bcf		RCSTA,CREN		; Clear receiver status
	bsf		RCSTA,CREN
	bsf		rs232_recieve_overflow		; set flag
	return				; and return anyway