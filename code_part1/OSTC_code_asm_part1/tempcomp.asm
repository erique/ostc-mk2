
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


; routine for extra temperature compensation
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 01/12/08
; last updated: 08/08/31
; known bugs:
; ToDo:

; routine echoes the "f" command as ready signal
; PC has to send 2 bytes containing the actual temperature in 0.1C
; Byte1: low
; Byte2: high


compensate_temperature:	bcf		uart_compensate_temp		; clear flag	bcf		PIE1,RCIE					; no interrupt for UART;
;	call	set_LEDusb					; LEDusb ON;
;	bcf		PIR1,RCIF					; clear flag;
;;
;	movlw	"f"							; send echo;
;	movwf	TXREG						;
;	call	rs232_wait_tx				; wait for UART;
;	;
;	call	rs232_get_byte				; low byte;
;	movff	RCREG, lo;
;;
;	call	rs232_get_byte				; high byte;
;	movff	RCREG, hi;
;;
;	clrf	temperature_correction		; wait for uncompensated temperature value!;
;	WAITMS	d'250'						; wait for new temperature;
;	WAITMS	d'250';
;	WAITMS	d'250';
;	WAITMS	d'250';
;;
;	movff	lo,sub_a+0					; calculate difference;
;	movff	hi,sub_a+1;
;	movff	temperature+0, sub_b+0;
;	movff	temperature+1, sub_b+1;
;	call	sub16						;  sub_c = sub_a - sub_b;
;	;
;	movf	sub_c+0,W;
;	btfsc	neg_flag					; compensate negative?;
;	movlw	d'0'						; use zero compensation!;
;	movwf	sub_c+0;
;;
;	movff	sub_c+0,TXREG				; Send answer;
;;
;	movff	sub_c+0,EEDATA				; store low byte only!;
;	movff	sub_c+0,temperature_correction	; no reboot required then...;
;	movlw	0x01;
;	movwf	EEADRH;
;	movlw	0x00;
;	movwf	EEADR;
;	call	write_eeprom		; stores in internal eeprom;
;;
;	movlw	0x00;
;	movwf	EEADRH				; reset high address byte;
;;
;	call	clear_LEDusb		; LEDusb OFF;
;	bcf		PIR1,RCIF					; clear flag	bsf		PIE1,RCIE					; enable interrupt for UART	goto	surfloop_loop				; return to surface loop
