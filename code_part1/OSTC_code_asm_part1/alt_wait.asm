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
; Wait routines
; written by: chsw, info@heinrichsweikamp.com
; written: 01/31/04
; last updated: 11/05/07
; known bugs:
; ToDo: 
	IFDEF	Clk_4_MHZ
  MESSG "wait_v2i: switched to 4 MHZ operation"
 ELSE 
  IFDEF Clk_8_MHZ
    MESSG "wait_v2i: switched to 8 MHZ operation"
  ELSE
  IFDEF Clk_16_MHZ
    MESSG "wait_v2i: switched to 16 MHZ operation"
  ELSE
   IFDEF Clk_20_MHZ
    MESSG "wait_v2i: switched to 20 MHZ operation"
    ELSE
     ERROR "wait_v2i: Operating Frequency has to be specified by #DEFINE Clk_4_MHZ or Clk_8_MHZ"
    ENDIF
  ENDIF
 ENDIF
 IFDEF	Clk_16_MHZ
; ==========================================================
; 	WAIT 10 MICROSECONDS  -  16 MHZ
; ==========================================================
WAIT10US 	macro	wait_temp
			movlw	wait_temp
	IFNDEF DEBUG
			call	WAIT10USX
	ENDIF
			endm

WAIT10USX	movwf	wait_temp
			goto	JumpIn10us
WAIT10USX2	nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
JumpIn10us:
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			decfsz	wait_temp,1
			goto	WAIT10USX2
			return
; ==========================================================
; 	WAIT 1 MILLISECOND  -  16 MHZ
; ==========================================================
WAITMS		macro	waitms_temp
			movlw	waitms_temp
	IFNDEF	DEBUG
			call WAITMSX
	ENDIF
			endm
WAITMSX		movwf	waitms_temp
			goto	JumpInMSX
WAITMSX2	nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
JumpInMSX:
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			WAIT10US d'99'
			decfsz	waitms_temp,1
			goto	WAITMSX2
			return
 ELSE
 IFDEF	Clk_8_MHZ
; ==========================================================
; 	WAIT 10 MICROSECONDS  -  8 MHZ
; ==========================================================
WAIT10US 	macro	wait_temp
			movlw	wait_temp
	IFNDEF DEBUG
			call	WAIT10USX
	ENDIF
			endm
WAIT10USX	movwf	wait_temp
			goto	JumpIn10us
WAIT10USX2	nop
			nop
			nop
			nop
			nop
			nop
			nop
JumpIn10us:
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			decfsz	wait_temp,1
			goto	WAIT10USX2
			return
; ==========================================================
; 	WAIT 1 MILLISECOND  -  8 MHZ
; ==========================================================
WAITMS		macro	waitms_temp
			movlw	waitms_temp
	IFNDEF	DEBUG
			call WAITMSX
	ENDIF
			endm
WAITMSX		movwf	waitms_temp
			goto	JumpInMSX
	
WAITMSX2	nop
			nop
			nop
			nop
			nop
			nop
			nop
JumpInMSX:
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			WAIT10US d'99'
			decfsz	waitms_temp,1
			goto	WAITMSX2
			return
 ELSE
 IFDEF	Clk_4_MHZ
; ==========================================================
; 	WAIT 10 MICROSECONDS  -  4 MHZ
; ==========================================================
WAIT10US 	macro	wait_temp
			movlw	wait_temp
	IFNDEF DEBUG
			call	WAIT10USX
	ENDIF
			endm
WAIT10USX	movwf	wait_temp
			goto	JumpIn10us
WAIT10USX2	nop
			nop
			nop
			nop
			nop
			nop
			nop
JumpIn10us:
			decfsz	wait_temp,1
			goto	WAIT10USX2
			return
; ==========================================================
; 	WAIT 1 MILLISECOND  -  4 MHZ
; ==========================================================
WAITMS		macro	waitms_temp
			movlw	waitms_temp
	IFNDEF	DEBUG
			call WAITMSX
	ENDIF
			endm
WAITMSX		movwf	waitms_temp
			goto	JumpInMSX
	
WAITMSX2	nop
			nop
			nop
			nop
			nop
			nop
			nop
JumpInMSX:
			WAIT10US d'99'
			decfsz	waitms_temp,1
			goto	WAITMSX2
			return
 ELSE
 IFDEF	Clk_20_MHZ
 ==========================================================
; 	WAIT 10 MICROSECONDS  -  20 MHZ
; ==========================================================
WAIT10US 	macro	wait_temp
			movlw	wait_temp
	IFNDEF DEBUG
			call	WAIT10USX
	ENDIF
			endm
WAIT10USX	movwf	wait_temp
			goto	JumpIn10us
WAIT10USX2	nop
			nop
			nop
			nop
			nop
			nop
			nop
JumpIn10us:
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			decfsz	wait_temp,1
			goto	WAIT10USX2
			return
; ==========================================================
; 	WAIT 1 MILLISECOND  -  20 MHZ
; ==========================================================
WAITMS		macro	waitms_temp
			movlw	waitms_temp
	IFNDEF	DEBUG
			call WAITMSX
	ENDIF
			endm
WAITMSX		movwf	waitms_temp
			goto	JumpInMSX
	
WAITMSX2	nop
			nop
			nop
			nop
			nop
			nop
			nop
JumpInMSX:
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			WAIT10US d'99'
			decfsz	waitms_temp,1
			goto	WAITMSX2
			return
 ENDIF
 ENDIF
 ENDIF
 ENDIF
 ENDIF


wait_one_second:
	WAITMS	d'250'
	WAITMS	d'250'
	WAITMS	d'250'
	WAITMS	d'250'
	return
