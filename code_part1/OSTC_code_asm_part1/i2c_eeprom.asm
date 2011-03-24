
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
; provides routines for external EEPROM via I2C
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 10/30/05
; last updated: 08/21/06
; known bugs:
; ToDo: use 2nd 32KB from external EEPROM for something

incf_eeprom_address	macro	ext_ee_temp1	; Will increase eeprom_address:2 with the 8Bit value "ext_ee_temp1" and takes
    	movlw	ext_ee_temp1                ; care of bank switching at 0x8000
    	call 	incf_eeprom_address0
	endm

incf_eeprom_address0:
    	addwf		eeprom_address+0,F      ; increase address
    	movlw		d'0'
    	addwfc		eeprom_address+1,F

    	btfss		eeprom_address+1,7		; at address 8000?
    	return                              ; No, continue
    
    	; Yes, clear eeprom_address:2
    	clrf		eeprom_address+0		; Clear eeprom address
    	clrf		eeprom_address+1
    	return								; Done.

;=============================================================================
; Will decrease eeprom_address:2 with the 8Bit value "ext_ee_temp1" and takes
; care of bank switching at 0x8000

decf_eeprom_address	macro	ext_ee_temp1
        movlw	ext_ee_temp1
        call 	decf_eeprom_address0
    endm

decf_eeprom_address0:
        subwf		eeprom_address+0,F      ; decrease address: do a 16-8bits substract.
        movlw		d'0'
        subwfb		eeprom_address+1,F

        btfss		eeprom_address+1,7		; at address 8000?
        return                              ; No, done.

        movlw		b'01111111'             ; yes, reset highbyte
        movwf		eeprom_address+1
    	return								; Done.

;=============================================================================

write_external_eeprom:				; data in WREG
								; increase address eeprom_address+0:eeprom_address+1 after write
								; with banking after 7FFF
#ifdef TESTING
	; When Simulating with MPLabSIM, there is no way to emulate external EEPROM...
	return
#endif

	rcall		I2CWRITE			; writes WREG into EEPROM@eeprom_address
	movlw		d'1'				; increase address
	addwf		eeprom_address+0,F
	movlw		d'0'
	addwfc		eeprom_address+1,F
	bcf			eeprom_overflow		
	btfss		eeprom_address+1,7		; at address 8000?
	return								; no, return

	clrf		eeprom_address+0		; Clear eeprom address
	clrf		eeprom_address+1
	bsf			eeprom_overflow			; and set overflow bit
	return

write_external_eeprom_block:			; Writes a block of 64Byte (one page in external EEPROM without stop condition
#ifdef TESTING
	; When Simulating with MPLabSIM, there is no way to emulate external EEPROM...
	return
#endif

	btfsc		eeprom_blockwrite		; Blockwrite continue?
	rcall		I2CWRITE_BLOCK2
	btfss		eeprom_blockwrite		; Blockwrite start?
	rcall		I2CWRITE_BLOCK
	bsf			eeprom_blockwrite		; After the start, do blockwriting for the next 63Bytes!
	
	movlw		d'0'				; increase address
	incf		eeprom_address+0,F	
	addwfc		eeprom_address+1,F
	bcf			eeprom_overflow		
	
	btfss		eeprom_address+1,7	; at address 8000
	return						; no, return
	
	clrf		eeprom_address+0		; Clear eeprom address
	clrf		eeprom_address+1
	bsf			eeprom_overflow		; and set overflow bit
	return
I2CWRITE_BLOCK:
	movwf		ext_ee_temp1				; Data byte in WREG
	bsf			SSPCON2,SEN			; Start condition
	rcall		WaitMSSP
	movlw		b'10100110'			; Bit0=0: WRITE, Bit0=1: READ
	movwf		SSPBUF				; control byte
	rcall		WaitMSSP	
	rcall		I2C_WaitforACK
	movff		eeprom_address+1,SSPBUF	; High Address byte
	rcall		WaitMSSP	
	rcall		I2C_WaitforACK
	movff		eeprom_address+0,SSPBUF	; Low Address byte
	rcall		WaitMSSP	
	rcall		I2C_WaitforACK
I2CWRITE_BLOCK2:	
	movff		ext_ee_temp1, SSPBUF		; Data Byte
	rcall		WaitMSSP	
	rcall		I2C_WaitforACK
	return


get_free_EEPROM_location:			; Searches 0xFD, 0xFD, 0xFE and sets Pointer to 0xFE

#ifdef TESTING
	; In testing mode, find 0x100 (internal EEPROM) as the first free location...
	clrf 		eeprom_address+0		; Not found in entire EEPROM, set to address 0
	movlw		0x1
	movwf 		eeprom_address+1
	return
#endif

	clrf		ext_ee_temp1		; low address counter
	clrf		ext_ee_temp2		; high address counter
	bcf			second_FD			; clear flags
	bcf			first_FD
get_free_EEPROM_location3:
	bsf			SSPCON2, PEN		; Stop condition
	rcall		WaitMSSP	
	bsf			SSPCON2,SEN			; Start condition
	rcall		WaitMSSP
	movlw		b'10100110'			; Bit0=0: WRITE, Bit0=1: READ
	movwf		SSPBUF				; control byte
	rcall		WaitMSSP	
	btfsc		SSPCON2,ACKSTAT
	bra			get_free_EEPROM_location3	; EEPROM NOT acknowledged, retry!
	
	movff		ext_ee_temp2,SSPBUF		; High Address byte
	rcall		WaitMSSP	
	rcall		I2C_WaitforACK
	movff		ext_ee_temp1,SSPBUF		; Low Address byte
	rcall		WaitMSSP	
	rcall		I2C_WaitforACK
	
	bsf			SSPCON2,RSEN		; Start condition
	rcall		WaitMSSP
	movlw		b'10100111'			; Bit0=0: WRITE, Bit0=1: READ
	movwf		SSPBUF			; control byte
	rcall		WaitMSSP	
	rcall		I2C_WaitforACK

get_free_EEPROM_location2:
	bsf			SSPCON2, RCEN		; Enable recieve mode
	rcall		WaitMSSP	
	btfsc		first_FD
	bra			test_2nd_FD
	bsf			first_FD			; found first 0xFD?
	movlw		0xFD
	cpfseq		SSPBUF
	bcf			first_FD			; No
	bra			get_free_EEPROM_location2c

test_2nd_FD:
	btfsc		second_FD
	bra			test_FE
	bsf			second_FD			; found second 0xFD?
	movlw		0xFD
	cpfseq		SSPBUF
	bra			get_free_EEPROM_location2b	;No, clear both flags
	bra			get_free_EEPROM_location2c	
test_FE:
	movlw		0xFE				; found the final 0xFE?
	cpfseq		SSPBUF
	bra			get_free_EEPROM_location2b	;No, clear both flags
	movff		ext_ee_temp1,eeprom_address+0	;Yes, copy ext_ee_temp1->eeprom_address+0 and 
	movff		ext_ee_temp2,eeprom_address+1	;ext_ee_temp2->eeprom_address+1
	bra			get_free_EEPROM_location4	; Done.

get_free_EEPROM_location2b:
	bcf			second_FD			; clear both flags!
	bcf			first_FD
get_free_EEPROM_location2c:
	movlw		d'1'				; and increase search address
	addwf		ext_ee_temp1,F
	movlw		d'0'
	addwfc		ext_ee_temp2,F
	
	btfsc		ext_ee_temp2,7			; 0x8000 reached?
	bra			get_free_EEPROM_location3b	; yes
	
	bsf			SSPCON2, ACKEN		; no, send Ack
	rcall		WaitMSSP				
	bra			get_free_EEPROM_location2	; and continue search
get_free_EEPROM_location3b:
	clrf 		eeprom_address+0		; Not found in entire EEPROM, set to address 0
	clrf 		eeprom_address+1
get_free_EEPROM_location4:
	bsf			SSPCON2, PEN		; Stop
	rcall		WaitMSSP	
	
	bcf			second_FD			; clear flags
	bcf			first_FD
	return					; return
	
	
I2CREAD:
	rcall		I2CREAD_COMMON
	bsf			SSPCON2, PEN	; Stop
	rcall		WaitMSSP	
	return

I2CREAD2:						; same as I2CREAD but with automatic address increase 
	rcall		I2CREAD
I2CREAD2_2:
	movlw		d'1'
	addwf		eeprom_address+0,F
	movlw		d'0'
	addwfc		eeprom_address+1,F
	bcf			eeprom_overflow		
	btfss		eeprom_address+1,7	; at 0x8000?
	return		; no, return
	
	clrf		eeprom_address+0	; Yes, clear address
	clrf		eeprom_address+1
	bsf			eeprom_overflow		; and set overflow bit
	return

I2CREAD3:						; block read start with automatic address increase 
	rcall		I2CREAD_COMMON
	; no Stop condition here
	bra			I2CREAD2_2

I2CREAD4:						; block read with automatic address increase 
	bsf			SSPCON2,ACKEN	; Master acknowlegde
	rcall		WaitMSSP	
	bsf			SSPCON2, RCEN	; Enable recieve mode
	rcall		WaitMSSP	
	movf		SSPBUF,W		; copy read byte into WREG
	; no Stop condition here
	bra			I2CREAD2_2


I2CREAD_COMMON:
	bsf			SSPCON2, PEN	; Stop
	rcall		WaitMSSP	
	bsf			SSPCON2,SEN		; Start condition
	rcall		WaitMSSP
	movlw		b'10100110'		; Bit0=0: WRITE, Bit0=1: READ
	movwf		SSPBUF			; control byte
	rcall		WaitMSSP	
	btfsc		SSPCON2,ACKSTAT
	bra			I2CREAD			; EEPROM NOT acknowledged, retry!	
	movff		eeprom_address+1,SSPBUF	; High Address byte
	rcall		WaitMSSP	
	rcall		I2C_WaitforACK
	movff		eeprom_address+0,SSPBUF	; Low Address byte
	rcall		WaitMSSP	
	rcall		I2C_WaitforACK
	
	bsf			SSPCON2,RSEN	; Start condition
	rcall		WaitMSSP
	movlw		b'10100111'		; Bit0=0: WRITE, Bit0=1: READ
	movwf		SSPBUF			; control byte
	rcall		WaitMSSP	
	rcall		I2C_WaitforACK
	
	bsf			SSPCON2, RCEN	; Enable recieve mode
	rcall		WaitMSSP	
	movf		SSPBUF,W		; copy read byte into WREG
	return


I2CWRITE:
	movwf		ext_ee_temp1				; Data byte
	bsf			SSPCON2,SEN			; Start condition
	rcall		WaitMSSP
	movlw		b'10100110'			; Bit0=0: WRITE, Bit0=1: READ
	movwf		SSPBUF			; control byte
	rcall		WaitMSSP	
	rcall		I2C_WaitforACK
	movff		eeprom_address+1,SSPBUF	; High Address byte
	rcall		WaitMSSP	
	rcall		I2C_WaitforACK
	movff		eeprom_address+0,SSPBUF	; Low Address byte
	rcall		WaitMSSP	
	rcall		I2C_WaitforACK
	movff		ext_ee_temp1, SSPBUF		; Data Byte
	rcall		WaitMSSP	
	rcall		I2C_WaitforACK
	bsf			SSPCON2,PEN			; Stop condition
	rcall		WaitMSSP	
	WAITMS		d'5'				; Write delay
	return

I2C_WaitforACK:
	btfsc		SSPCON2,ACKSTAT		; checks for ACK bit from slave
	rcall		I2CFail
	return
	
I2CFail:
	ostc_debug	'M'		; Sends debug-information to screen if debugmode active
	bsf			LED_red
	rcall		I2CReset			; I2C Reset
	bcf			PIR1,SSPIF
	clrf		i2c_temp
	return	
	
WaitMSSP:
	decfsz		i2c_temp,F		; check for timeout during I2C action
	bra			WaitMSSP2
	bra			I2CFail			; timeout occured
WaitMSSP2:
	btfss		PIR1,SSPIF
	bra		WaitMSSP
	clrf		i2c_temp
	bcf			PIR1,SSPIF
	return

I2CReset:						; Something went wrong (Slave holds SDA low?)
	clrf		SSPCON1			; wake-up slave and reset entire module
	ostc_debug	'N'		; Sends debug-information to screen if debugmode active
	clrf		SSPCON2
	clrf		SSPSTAT
	bcf			TRISC,3			; SCL	OUTPUT
	bsf			TRISC,4			; SDA	Input
	bcf			PORTC,3
	movlw		d'9'
	movwf		i2c_temp		; clock-out 9 clock cycles manually
I2CReset_1:
	bsf			PORTC,3			; SCL=1
	nop
	btfsc		PORTC,4			; SDA=1?
	bra		I2CReset_2		; =1, SDA has been released from slave
	bcf			PORTC,3			; SCL=0	
	bcf			PORTC,3
	decfsz		i2c_temp,F
	bra		I2CReset_1			; check for nine clock cycles
I2CReset_2:
	bsf			TRISC,3			; SCL	Input
	clrf		SSPCON1			; set I²C Mode
	WAITMS		d'10'				; Reset-Timeout for I2C devices
	movlw		b'00000000'
	movwf		SSPSTAT
	movlw		b'00101000'
	movwf		SSPCON1
	movlw		b'00000000'
	movwf		SSPCON2
	movlw		d'8'				; 400kHz I2C clock @ 16MHz Fcy
	movwf		SSPADD
	bcf			LED_red
	ostc_debug	'O'		; Sends debug-information to screen if debugmode active
	return

;I2C_TX:
;	movwf		i2c_temp2				; Data byte
;	bsf			SSPCON2,SEN			; Start condition
;	rcall		WaitMSSP
;	movlw		b'10010000'		; Bit0=0: WRITE, Bit0=1: READ
;	movwf		SSPBUF			; control byte
;	rcall		WaitMSSP	
;	rcall		I2C_WaitforACK
;	movff		i2c_temp2, SSPBUF		; Data Byte
;	rcall		WaitMSSP	
;	rcall		I2C_WaitforACK
;	bsf			SSPCON2,PEN			; Stop condition
;	rcall		WaitMSSP	
;	return
;I2C_RX:
;	bcf			PIR1,SSPIF
;	bsf			SSPCON2,SEN			; Start condition
;	rcall		WaitMSSP
;	movlw		b'10010001'		; Bit0=0: WRITE, Bit0=1: READ
;	movwf		SSPBUF			; control byte
;	rcall		WaitMSSP	
;	rcall		I2C_WaitforACK
;	bsf			SSPCON2, RCEN	; Enable recieve mode
;	rcall		WaitMSSP	
;	movff		SSPBUF,i2c_temp2	; Data Byte
;	bsf			SSPCON2,ACKEN		; Master acknowlegde
;	rcall		WaitMSSP	
;	bsf			SSPCON2,PEN			; Stop condition
;	rcall		WaitMSSP	
;	return