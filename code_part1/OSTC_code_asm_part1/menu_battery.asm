
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


; Submenu battery state
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 05/15/08
; last updated: 05/15/08
; known bugs:
; ToDo: 

menu_battery_state:
	call	PLED_ClearScreen
	call	PLED_topline_box
	WIN_INVERT	.1	; Init new Wordprocessor	
	DISPLAYTEXT	.114		; Battery Information
	WIN_INVERT	.0	; Init new Wordprocessor	
	
	WIN_TOP		.35
	WIN_LEFT	.0
	WIN_FONT 	FT_SMALL

	lfsr	FSR2,letter
	OUTPUTTEXT	.115		; Cycles:
	read_int_eeprom	d'50'	; Get charge cycles
	movff	EEDATA,lo
	read_int_eeprom	d'51'
	movff	EEDATA,hi
	bsf		leftbind
	output_16
	STRCAT  " ("
	read_int_eeprom	d'52'	; Get complete cycles
	movff	EEDATA,lo
	read_int_eeprom	d'53'
	movff	EEDATA,hi
	bsf		leftbind
	output_16
	STRCAT_PRINT  ")"

	WIN_TOP		.63
	lfsr	FSR2,letter
	OUTPUTTEXT	.117		; Last Complete at:
	read_int_eeprom	d'47'	; Month
	movff	EEDATA,convert_value_temp+0
	read_int_eeprom	d'48'	; Day
	movff	EEDATA,convert_value_temp+1
	read_int_eeprom	d'49'	; Year
	movff	EEDATA,convert_value_temp+2
	call	PLED_convert_date		; coverts into "DD/MM/YY" or "MM/DD/YY" or "YY/MM/DD" in postinc2
	call	word_processor

	WIN_TOP		.91
	lfsr	FSR2,letter
	OUTPUTTEXT	.118		; Lowest Battery:
	read_int_eeprom	d'40'	; Batt LOW
	movff	EEDATA,lo
	read_int_eeprom	d'41'	; Batt HIGH
	movff	EEDATA,hi
	movlw	d'1'
	movwf	ignore_digits
	bsf		leftbind
	output_16dp	d'2'
	bcf		leftbind
	STRCAT_PRINT TXT_VOLT1

	WIN_TOP		.119
	lfsr	FSR2,letter
	OUTPUTTEXT .119		; Lowest Battery at:
	read_int_eeprom	d'42'	; Month
	movff	EEDATA,convert_value_temp+0
	read_int_eeprom	d'43'	; Day
	movff	EEDATA,convert_value_temp+1
	read_int_eeprom	d'44'	; Year
	movff	EEDATA,convert_value_temp+2
	call	PLED_convert_date		; coverts into "DD/MM/YY" or "MM/DD/YY" or "YY/MM/DD" in postinc2
	call	word_processor

	WIN_TOP		.147
	lfsr	FSR2,letter
	OUTPUTTEXT .120		; Temp min:
	read_int_eeprom	d'54'	; TEMP_min LOW
	movff	EEDATA,lo
	read_int_eeprom	d'55'	; TEMP_min HIGH
	movff	EEDATA,hi
	call	PLED_convert_signed_temperature	; converts lo:hi into signed-short and adds '-' to POSTINC2 if required
	movlw	d'3'
	movwf	ignore_digits
	bsf		leftbind			; left orientated output
	output_16dp	d'2'
	bcf		leftbind
	STRCAT  "° ("
	read_int_eeprom	d'56'	; Month
	movff	EEDATA,convert_value_temp+0
	read_int_eeprom	d'57'	; Day
	movff	EEDATA,convert_value_temp+1
	read_int_eeprom	d'58'	; Year
	movff	EEDATA,convert_value_temp+2
	call		PLED_convert_date		; coverts into "DD/MM/YY" or "MM/DD/YY" or "YY/MM/DD" in postinc2
	STRCAT_PRINT ") "

	WIN_TOP		.175
	lfsr	FSR2,letter
	OUTPUTTEXT .121		; Temp max:
	read_int_eeprom	d'59'	; TEMP_max LOW
	movff	EEDATA,lo
	read_int_eeprom	d'60'	; TEMP_max HIGH
	movff	EEDATA,hi
	call	PLED_convert_signed_temperature	; converts lo:hi into signed-short and adds '-' to POSTINC2 if required
	movlw	d'3'
	movwf	ignore_digits
	bsf		leftbind			; left orientated output
	output_16dp	d'2'
	bcf		leftbind
	STRCAT  "° ("
	read_int_eeprom	d'61'	; Month
	movff	EEDATA,convert_value_temp+0
	read_int_eeprom	d'62'	; Day
	movff	EEDATA,convert_value_temp+1
	read_int_eeprom	d'63'	; Year
	movff	EEDATA,convert_value_temp+2
	call	PLED_convert_date		; coverts into "DD/MM/YY" or "MM/DD/YY" or "YY/MM/DD" in postinc2
	STRCAT_PRINT ") "

	WIN_TOP		.203
	lfsr	FSR2,letter
	OUTPUTTEXT .228			; Total Dives: 
	read_int_eeprom	d'2'	; Total dives low
	movff	EEDATA,lo
	read_int_eeprom	d'3'	; Total dives high
	movff	EEDATA,hi
	bsf		leftbind			; left orientated output
	output_16
	STRCAT_PRINT ""

	call	wait_switches		; Waits until switches are released, resets flag if button stays pressed!	
	bcf		menubit2
menu_battery_state_loop:
	call	check_switches_logbook

	btfsc	menubit2
	bra		menu_battery_state_exit		; Exit

	btfsc	onesecupdate
	call	menu_check_dive_and_timeout	; "Goto restart" or sets sleepmode flag

	bcf		onesecupdate	; 1 sec. functions done

	btfsc	sleepmode
	bra		menu_battery_state_exit

	bra		menu_battery_state_loop
	
menu_battery_state_exit:		; exit...
	movlw	d'3'
	movwf	menupos
	goto	more_menu2
