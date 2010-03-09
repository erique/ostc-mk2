
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


; Interface, Downloader, MD2 Hash send routine
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 10/30/05
; last updated: 12/27/07
; known bugs:
; ToDo: 

uart_store_tissues:
	bcf		uart_store_tissue_data			; Clear flag
	bcf		PIE1,RCIE						; No Interrupt for UART
	call	set_LEDusb
	call	simulator_save_tissue_data		; store and set flag for automatic restore
	movlw		'k'							; send echo
	movwf		TXREG						; When done
	call		rs232_wait_tx				; wait for UART
	call	clear_LEDusb
	bsf			PIE1,RCIE				; Interrupt for RS232
	goto		surfloop_loop			; return to surface loop

; reset Decodata
reset_decodata:
	bcf			uart_reset_decodata				; clear flag
	bcf			PIE1,RCIE						; No Interrupt for UART
	call		set_LEDusb

	call		deco_main_clear_tissue			; Reset Decodata
	movlb		b'00000001'						; select ram bank 1
	call		deco_main_calc_desaturation_time	; calculate desaturation time
	movlb		b'00000001'						; select ram bank 1
	call		main_clear_CNS_fraction			; clear CNS
	movlb		b'00000001'						; select ram bank 1

	movlw		d'1'
	movwf		nofly_time+0				; Clear nofly time
	clrf		nofly_time+1				; Clear nofly time

	movlw		'h'							; send echo
	movwf		TXREG						; When done
	call		rs232_wait_tx				; wait for UART

	bsf			oneminupdate				; set flag, so display will be updated at once
	call		clear_LEDusb
	bsf			PIE1,RCIE					; Interrupt for RS232
	goto		surfloop_loop				; return to surface loop

; send internal EEPROM BANK 0 via the UART
send_int_eeprom_b0:
	bcf			uart_send_int_eeprom	; clear flag
	bcf			PIE1,RCIE				; No Interrupt for UART
	call		set_LEDusb

	clrf		EEADRH						; Point to Bank0
	rcall		send_internal_eeprom1		; sends complete 1st. page of internal EEPROM

	call		clear_LEDusb
	bsf			PIE1,RCIE				; Interrupt for RS232
	goto		surfloop_loop			; return to surface loop

; send internal EEPROM BANK 1 via the UART
send_int_eeprom_b1:
	bcf			uart_send_int_eeprom2	; clear flag
	bcf			PIE1,RCIE				; No Interrupt for UART
	call		set_LEDusb

	movlw		d'1'
	movwf		EEADRH						; Point to Bank1
	rcall		send_internal_eeprom1		; sends complete 2nd page of internal EEPROM
	clrf		EEADRH						; Point to Bank0

	call		clear_LEDusb
	bsf			PIE1,RCIE				; Interrupt for RS232
	goto		surfloop_loop			; return to surface loop


; Send firmware version and 16bytes MD2 hash via the UART
send_md2_hash:
	bcf			uart_send_hash			; clear flag
	bcf			PIE1,RCIE				; No Interrupt for UART
	call		set_LEDusb

	call		rs232_wait_tx					; wait for UART
	movlw		softwareversion_x				; Softwareversion
	movwf		TXREG
	call		rs232_wait_tx					; wait for UART
	movlw		softwareversion_y				; Softwareversion
	movwf		TXREG

	lfsr		FSR2, char_O_hash
	movlw		d'16'
	movwf		temp1
send_md2_hash2:
	call		rs232_wait_tx					; wait for UART
	movff		POSTINC2,TXREG					; copy hash byte to TXREG
	decfsz		temp1,F
	bra		send_md2_hash2					; loop 16 times

	call		clear_LEDusb
	bsf			PIE1,RCIE				; Interrupt for RS232
	goto		surfloop_loop			; return to surface loop


; Sends first 256Byte from internal and first 32KB from external EEPROM using the UART module
menu_interface:
	bcf		dump_external_eeprom			; clear flag
	bcf		PIE1,RCIE					; No Interrupt for UART
	call	set_LEDusb
	call	PLED_ClearScreen
	call	PLED_topline_box
	WIN_INVERT	.1					; Init new Wordprocessor	
	DISPLAYTEXT	.15						; "Interface"
	WIN_INVERT	.0					; Init new Wordprocessor

	movlw		d'5'
	movwf		uart1_temp
menu_interface1:
	movlw		0xAA						; Startbytes
	movwf		TXREG
	call		rs232_wait_tx				; wait for UART
	decfsz	uart1_temp
	bra		menu_interface1
	movlw		0x55						; finish preamble
	movwf		TXREG

	DISPLAYTEXT	.16						; "Start"

	call		get_free_EEPROM_location		; 
	movlw		d'1'						; increase
	addwf		eeprom_address+0,F
	movlw		d'0'
	addwfc	eeprom_address+1,F

	DISPLAYTEXT	.17						; "Data"

	rcall		send_internal_eeprom1		; sends complete 1st. page of internal EEPROM

	call		rs232_wait_tx				; wait for UART
	movff		batt_voltage+0,TXREG			; Battery

	call		rs232_wait_tx				; wait for UART
	movff		batt_voltage+1,TXREG			; Battery 

	call		rs232_wait_tx				; wait for UART
	movlw		softwareversion_x				; Softwareversion
	movwf		TXREG

	call		rs232_wait_tx				; wait for UART
	movlw		softwareversion_y				; Softwareversion
	movwf		TXREG

	DISPLAYTEXT .18						; "Header"

	clrf		uart1_temp					; low address counter
	clrf		uart2_temp					; high address counter

menu_interface3:
	bsf		SSPCON2,SEN					; Start condition
	call		WaitMSSP

	movlw		b'10100110'					; Bit0=0: WRITE, Bit0=1: READ
	movwf		SSPBUF					; control byte
	call		WaitMSSP	
	btfsc		SSPCON2,ACKSTAT
	bra		menu_interface3				; No Ack, try again!
	
	movff		eeprom_address+1,SSPBUF			; High Address byte
	call		WaitMSSP	
	call		I2C_WaitforACK
	movff		eeprom_address+0,SSPBUF			; Low Address byte
	call		WaitMSSP	
	call		I2C_WaitforACK
	bsf		SSPCON2,RSEN				; Start condition
	call		WaitMSSP

	movlw		b'10100111'					; Bit0=0: WRITE, Bit0=1: READ
	movwf		SSPBUF					; control byte
	call		WaitMSSP	
	call		I2C_WaitforACK

	DISPLAYTEXT	.19						; "Profile"

menu_interface2:
	call		rs232_wait_tx				; wait for UART

	bsf			SSPCON2, RCEN				; Enable recieve mode
	call		WaitMSSP	

	movff		SSPBUF, TXREG

	movlw		d'1'
	addwf		uart1_temp,F
	movlw		d'0'
	addwfc		uart2_temp,F

	btfsc		uart2_temp,7				; 32KB done?
	bra			menu_interface4				; Yes
	
	bsf			SSPCON2, ACKEN				; Ack
	call		WaitMSSP	
	bra			menu_interface2				; go on

menu_interface4:
	bsf			SSPCON2, PEN				; Stop
	call		WaitMSSP	
	
	DISPLAYTEXT	.20						; Done.

	WAITMS	d'250'
	call		clear_LEDusb
	bsf			PIE1,RCIE					; Interrupt for RS232
	goto		surfloop					; back to surfacemode

send_internal_eeprom1:
	clrf		uart1_temp					; Send the total of 256bytes
	clrf		EEADR						; Send bytes 0-255 from internal EEPROM
send_internal_eeprom2:
	call		read_eeprom					; read byte
	movff		EEDATA,TXREG				; send byte
	incf		EEADR,F						; increase pointer
	call		rs232_wait_tx				; wait for UART
	decfsz		uart1_temp,F				; until limit reached
	bra			send_internal_eeprom2
	return