
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


;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either versio
; includes and isr
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 041013
; last updated: 081219
; known bugs:
; ToDo: 

	
	LIST P=18F4685							;directive to define processor
	#include <P18F4685.INC>					;processor specific variable definitions

	#include	definitions.asm				; Defines, I/O Ports and variables

		ORG     0x0000
		goto	start						; Start!

		ORG		0x0008
		bra		HighInt						;High Priority Interrups

		ORG	0x0018							;Low Priority Interrups
;	*** low priority interrupts not used
		bra		HighInt						;High Priority Interrups

HighInt:
		movff	BSR,0x102					;save BSR register
		movlb	b'00000001'					;select Bank1
		
		movff	STATUS,status_temp			;save STATUS register
		movff	WREG,wreg_temp				;save working register

		movf	PORTB,W						;move portb into latch register

		btfsc	PIR1,TMR1IF					;Timer1 INT (external 32.768kHz Clock)
		call	timer1int

		btfsc	INTCON,TMR0IF				;Timer0 INT (Debounce Timer)
		call	timer0int

		btfsc	PIR2,TMR3IF					;Timer3 INT (Delay for PWM Buzzer)
		call	timer3int

		btfsc	PIR1,RCIF					; UART
		call	uartint

		btfsc	INTCON,INT0IF				; Switch left
		call	schalter_links

		btfsc	INTCON3,INT1IF				; switch right
		call	schalter_rechts

		movff	wreg_temp,WREG				;restore working register
		movff	status_temp,STATUS			;restore STATUS register
		movff	0x102,BSR					;restore BSR register
		retfie

		ORG	0x00100				; 
#include	text_table.asm		; includes textmacros
#include	displaytext.asm		; sends texts to wordprocessor
#include	math.asm			; mathematical functions
#include 	wait.asm			; waitroutines
#include	valconv.asm			; outputs to POSTINC2
#include	eeprom_rs232.asm	; Internal EEPROM and RS232 Interface
#include	oled_samsung.asm	; Attached in 80-System 8-Bit Mode
#include	menu_custom.asm		; Menu "Custom FunctionsI" and "Custom FunctionsII"
#include	menu.asm			; Main Menu and Setup Menu
#include	menu_reset.asm		; Submenu "Reset"
#include	menu_settime.asm	; Submenu "Set Time"
#include	ms5535.asm			; Interface to MS5535A,B or C pressure sensor
#include	pled_outputs.asm	; div. PLED outputs and background debugger
#include	i2c_eeprom.asm		; for external I2C EEPROM and general I2C Routines
#include	menu_logbook.asm	; Submenu "Logbook"
#include	interface.asm		; Interface routines 
#include	menu_ppO2.asm		; Constant ppO2 setup menu
#include 	menu_battery.asm	; Submenu "Battery Info"
#include	menu_gassetup.asm	; Menu "Gas Setup"
#include	isr.asm				; Interrupt service routine (RTC&Sensor)
#include	surfmode.asm		; Mainroutines for Surfacemode
#include	divemode.asm		; Mainroutines for Divemode
#include	divemode_menu.asm	; Underwater menu
#include	sleepmode.asm		; Mainroutines for Sleepmode
#include	adc_rtc.asm			; A/D converter (battery control) and RTC init
#include	temp_extrema.asm	; Takes care of the temperature extrema logger
#include	sync_clock.asm		; syncs RTC with PC
#include	tempcomp.asm		; extra temperature compensation
#include	start.asm			; Startup and init, checks background debugger
#include	simulator.asm		; Stand-alone simulator routines
#include 	io.asm				; Low-Level I/O access

	ORG	0x0A000		; keep free for new c_code
	nop

	ORG deco_main_calc_hauptroutine
	return			;Dummy
	ORG deco_main_calc_without_deco
	return			;Dummy
	ORG deco_main_clear_tissue
	return			;Dummy
	ORG deco_main_calc_desaturation_time
	return			;Dummy
	ORG deco_main_calc_wo_deco_step_1_m
	return			;Dummy
	ORG deco_main_hash
	return			;Dummy
	ORG main_clear_CNS_fraction
	return			;Dummy
	ORG	main_calc_CNS_fraction
	return			;Dummy
	ORG	main_calc_CNS_decrease_15min
	return			;Dummy	
	ORG	main_push_tissues_to_vault
	return			;Dummy
	ORG	main_pull_tissues_from_vault
	return			;Dummy
	
	
    MESSG "OSTC - diving computer code,  Copyright (C) 2009 HeinrichsWeikamp GbR"
    MESSG "This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the"
    MESSG "Free Software Foundation, either version 3 of the License, or (at your option) any later version."
    MESSG "This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY"
    MESSG "or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details."
    MESSG "You should have received a copy of the GNU General Public License along with this program.If not, see http://www.gnu.org/licenses/."

	END				; end of program
