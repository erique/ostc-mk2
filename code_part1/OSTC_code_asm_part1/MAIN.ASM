
; OSTC Mk.2, 2N and 2C - diving computer code
; Copyright (C) 2008-2015 HeinrichsWeikamp GbR

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


; includes and isr
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 041013
; last updated: 081219
; known bugs:
; ToDo: 

	
	LIST P=18F4685							;directive to define processor
	#include <P18F4685.INC>					;processor specific variable definitions

	#include	definitions.asm				; Defines, I/O Ports and variables
    #include    shared_definitions.h

reset_v code     0x0000
        goto	start						; Start!

inter_v	code	0x0008
		bra		HighInt						;High Priority Interrups

inter_asm	code	0x0018                  ;Low Priority Interrups
;	*** low priority interrupts not used
		bra		HighInt						;High Priority Interrups

HighInt:
		movlb	b'00000001'					;select Bank1
		movff   PRODL,prod_temp+0
		movff   PRODH,prod_temp+1

		movf	PORTB,W						; move portb into latch register

		btfsc	INTCON,TMR0IF				; Timer0 INT (Debounce Timer)
		call	timer0int

		btfsc	INTCON,INT0IF				; Switch left
		call	switch_left_int

		btfsc	INTCON3,INT1IF				; switch right
		call	switch_right_int

		btfsc	PIR1,TMR1IF					; Timer1 INT (external 32.768kHz Clock)
		call	timer1int

		btfsc	PIR1,RCIF					; UART
		call	uartint

		movff   prod_temp+1,PRODH
		movff   prod_temp+0,PRODL
		retfie FAST

;=============================================================================
#include    multilang_text.asm		; includes textmacros

;=============================================================================
osct_asm	code
#include    strings.inc

#include	isr.asm				; Interrupt service routine (RTC&Sensor)
#include	displaytext.asm		; sends texts to wordprocessor
#include	math.asm			; mathematical functions
#include 	wait.asm			; waitroutines
#include	display_lowlevel.asm; Low level display routines
#include	aa_wordprocessor.asm; New antialiased word processor and fonts
#include    color_processor.asm ; Color image drawing.
#include    dump_screen.asm     ; Copy screen contains to serial interface
#include	valconv.asm			; outputs to POSTINC2
#include	eeprom_rs232.asm	; Internal EEPROM and RS232 Interface
#include	menu_custom.asm		; Menu "Custom FunctionsI" and "Custom FunctionsII"
#include	menu.asm			; Main Menu and Setup Menu
#include	menu_reset.asm		; Submenu "Reset"
#include	menu_settime.asm	; Submenu "Set Time"
#include	ms5535.asm			; Interface to MS5535A,B or C pressure sensor
#include	outputs.asm         ; div. outputs and background debugger
#include	i2c_eeprom.asm		; for external I2C EEPROM and general I2C Routines
#include	menu_logbook.asm	; Submenu "Logbook"
#include	interface.asm		; Interface routines 
#include	menu_ppO2.asm		; Constant ppO2 setup menu
#include 	menu_battery.asm	; Submenu "Battery Info"
#include	menu_gassetup.asm	; Menu "Gas Setup"
#include	surfmode.asm		; Mainroutines for Surfacemode
#include	divemode.asm		; Mainroutines for Divemode
#include	divemode_menu.asm	; Underwater menu
#include	sleepmode.asm		; Mainroutines for Sleepmode
#include	adc_rtc.asm			; A/D converter (battery control) and RTC init
#include	temp_extrema.asm	; Takes care of the temperature extrema logger
#include	sync_clock.asm		; syncs RTC with PC
#include	start.asm			; Startup and init, checks background debugger
#include	simulator.asm		; Stand-alone simulator routines
#include	customview.asm		; Customview for divemode
#include    strings.asm         ; Basic string operations

#include    altimeter.asm

;=============================================================================
; Extracted from p3_wordprocessor includes:
#include	aa_fonts.asm

;=============================================================================
    MESSG "OSTC Mk.2, 2N and 2C - diving computer code,  Copyright (C) 2015 HeinrichsWeikamp"
    MESSG "This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the"
    MESSG "Free Software Foundation, either version 3 of the License, or (at your option) any later version."
    MESSG "This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY"
    MESSG "or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details."
    MESSG "You should have received a copy of the GNU General Public License along with this program.If not, see http://www.gnu.org/licenses/."

  ifdef __DEBUG
   	MESSG "OSTC2 code compiled in DEBUG configuration!"
  else
	MESSG "OSTC2 code compiled in RELEASE configuration!"
  endif


	END				; end of program

