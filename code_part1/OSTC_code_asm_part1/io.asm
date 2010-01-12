; OSTC - diving computer code
; Copyright (C) 2009 HeinrichsWeikamp GbR
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


; low-level routines for i/O
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 090801
; last updated: 090801
; known bugs:
; ToDo:

set_LEDy:	; Yellow LED
	bsf		LED_red
	return
clear_LEDy	; Yellow LED
	bcf		LED_red
	return

set_LEDr:	; Red LED
	bsf		LED_red
	return
clear_LEDr	; Red LED
	bcf		LED_red
	return
toggle_LEDr	; Red LED
	btg		LED_red
	return


set_LEDg:	; Green LED
	bsf		LED_red
	return
clear_LEDg	; Green LED
	bcf		LED_red
	return

set_LEDusb:	; USB LED
	bsf		LED_blue
	return
clear_LEDusb;  USB LED
	bcf		LED_blue
	return

set_LEDnofly:	; nofly LED
	bsf		LED_blue
	return
clear_LEDnofly;  nofly LED
	bcf		LED_blue
	return
toggle_LEDnofly	; nofly LED
	btg		LED_blue
	return


