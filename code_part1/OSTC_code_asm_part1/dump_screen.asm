;=============================================================================
;
;    File dump_screen.asm
;
;    Dump screen contains to the serial interface.
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
;    Copyright (c) 2011, JD Gascuel.
;=============================================================================
; HISTORY
;  2011-05-08 : [jDG] Creation.
;
; BUGS :
;  * ...
;=============================================================================

; Manage interface to the OSTC platform:
dump_screen:
	bcf		    uart_dump_screen        ; clear flag!

	movlw	    'l'
	movwf	    TXREG                   ; Send command echo.
	bsf		    no_sensor_int           ; No Sensor Interrupt
	bcf		    PIE1,RCIE               ; no interrupt for UART
	bcf		    PIR1,RCIF               ; clear flag
	bsf		    LED_blue                ; LEDusb ON
	call		rs232_wait_tx           ; wait for UART

    call        dump_screen_0

	bcf		    no_sensor_int           ; Restore Sensor Interrupt
	bcf			LED_blue                ; Clear led
	bcf			LED_red                 ; Clear led
	bsf			PIE1,RCIE               ; Interrupt for RS232
	return

;=============================================================================
; Dump screen contains to the UART

dump_screen_0:

    ;---- Send OLED box command for the full screen window -------------------
    mullw       0                       ; PRODH:L <- 0

    AA_CMD_WRITE    0x35                ; VerticalStartAddress HIGH:LOW
    AA_DATA_WRITE_PROD                  ; 00:00

    AA_CMD_WRITE    0x36                ; VerticalEndAddress HIGH:LOW
    AA_DATA_WRITE   0x01
    AA_DATA_WRITE   0x3F

    AA_CMD_WRITE    0x37                ; HorizontalAddress START:END
    AA_DATA_WRITE   0x00
    AA_DATA_WRITE   0xEF

    AA_CMD_WRITE    0x20                ; Start Address Horizontal (.0 - .239)
    AA_DATA_WRITE_PROD                  ; 00:00

    AA_CMD_WRITE    0x21                ; Start Address Vertical (.0 - .319)
    AA_DATA_WRITE_PROD                  ; 00:00

    AA_CMD_WRITE    0x22                ; Start reading.
    rcall       PLED_DataRead           ; Dummy pixel to skip.
    rcall       PLED_DataRead           ; Dummy pixel to skip.

   	movlw	    .160                    ; 160x2 columns
	movwf	    uart1_temp
dump_screen_1:
    btg         LED_red                 ; LEDactivity toggle

    AA_CMD_WRITE    0x22                ; Re-sync data.

	movlw	    .240                    ; 240 lines
	movwf	    uart2_temp

    setf        TRISD                   ; PortD as input.
    clrf        PORTD

dump_screen_2:

    rcall       PLED_DataRead           ; read first pixel-low byte
    movwf       TXREG                   ; send
	call		rs232_wait_tx           ; wait for UART

    rcall       PLED_DataRead           ; read first pixel-high byte
    movwf       TXREG                   ; send
    call		rs232_wait_tx           ; wait for UART

    rcall       PLED_DataRead           ; read second pixel-low byte
    movwf       TXREG                   ; send
    call		rs232_wait_tx           ; wait for UART
    
    rcall       PLED_DataRead           ; read second pixel-high byte
    movwf       TXREG                   ; send
    call		rs232_wait_tx           ; wait for UART


    decfsz	    uart2_temp,F
    bra		    dump_screen_2

    clrf        TRISD                   ; Back to normal (PortD as output)

    decfsz	    uart1_temp,F
    bra		    dump_screen_1

    AA_CMD_WRITE    0x00        ; NOP, to stop Address Update Counter
    return

