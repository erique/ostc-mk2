; ********************************************************************
; ** ASM code for simulation / tests without full simulation code  **
; ** This is NOT a part of the OSTC                                 **
; ********************************************************************

;/////////////////////////////////////////////////////////////////////////////
; OSTC - diving computer code
; Copyright (C) 2008 HeinrichsWeikamp GbR
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
;/////////////////////////////////////////////////////////////////////////////
; History:
; 01/24/11     : [jDG] make p2_main.c link with oled+wordprocessor display functions

	LIST P=18F4685                      ;directive to define processor
#include <P18F4685.INC>                 ;processor specific variable definitions

;=============================================================================
; Reset and interupt vectors.
;
reset_v     code    0x0000
            extern  main
restart     goto    main
            
            ORG     0x0008              ; Interupt vector
            bra     HighInt
            ORG     0x0018              ; Other interupt vector
HighInt:    retfie                      ; Return from everything.

#include    definitions.asm
#include    strings.inc

;=============================================================================
; Minimal routines to include
;
p2_env      code    0x400
#include    wait.asm                    ; Delay routines.
#include    oled_samsung.asm            ; Screen display routines.
#include    aa_wordprocessor.asm        ; Text printing routines.
#include    strings.asm                 ; String concatenations.

;=============================================================================
;
; Fake a few calls, to avoid linking the whole OSTC simulation code.
; Note: Needing to do so is a clear indication that cleanups are necessary...
;
            global  PLED_warnings_color
PLED_warnings_color:
            movlw   b'11100000'         ; Red
            goto    PLED_set_color

            global  PLED_standard_color
PLED_standard_color:
            setf    WREG                ; White
            goto    PLED_set_color

            global  getcustom15
getcustom15:
            clrf    hi
            clrf    lo
            return

;=============================================================================
; Needed fonts definition.
#include    aa_fonts.asm
            end
            
