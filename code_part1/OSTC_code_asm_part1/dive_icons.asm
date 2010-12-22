;=============================================================================
;
;    File dive_icons.asm
;
;    Draw Air/Nitrox/Trimix colored icon on surface mode.
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
;    Copyright (c) 2010, JD Gascuel.
;=============================================================================
; HISTORY
;  2010-12-21 : [jDG] Creation
;
; RATIONALS: Enabled gazes are used to predict TTS in divemode, hence they
;            are a critical aspect that should be double-checked before dive.
;
;=============================================================================
; Display either Air, Nitrox, or Trimix icon (in surface mode).
; Inputs:  None: explore the gaz list.
; Ouputs:  None.
; Trashed: hi:lo, PROD, and registers trashed by color_processor.asm
dive_type_icons:
            ;---- Common setup -----------------------------------------------
            movlw   .170
            movff   WREG, img_top
            movlw   .110
            movff   WREG, img_left
            movlw   UPPER(dive_air_block)
            movwf   TBLPTRU

            ;---- Explore gazlist --------------------------------------------
            ; EEADR+0 = O2%
            ; EEADR+1 = He%
            ; EEADR+4 = next gaz O2%
            
          	read_int_eeprom		d'27'	; read gas flag register --> hi
          	movff   EEDATA,hi
          	movlw   5                   ; Number of gas to check --> lo
          	movwf   lo
          	movlw	6-4                 ; Gas list start in eeprom.
	        movwf	EEADR
	        clrf    PRODL               ; =0 : no nitrox found yet.

dive_type_loop:
            movlw   4                   ; Advance to next gas data in EEPROM.
            addwf   EEADR,F
            rrcf    hi                  ; Check next enabled flag ?
            bnc     dive_type_loop_9    ; Disabled.
            
            call    read_eeprom         ; Read O2 %
            movlw   .21
            cpfseq  EEDATA              ; O2 == 21% ?
            setf    PRODL               ; NO: not simple air !

            incf    EEADR               ; Read He %
            call    read_eeprom
            decf    EEADR
            clrf    WREG                ; H2 == 0% ?
            cpfseq  EEDATA
            bra     dive_trimix_icon    ; No: go for the Tx icon, now.
            
dive_type_loop_9:
            decfsz  lo                  ; More gas ?
            bra     dive_type_loop      ; YES: loop...
	        
	        btfsc   PRODL,0             ; Did we find a nitrox gaz ?
	        bra     dive_nitrox_icon    ; YES: display nitrox icon.;.

            ;---- Draw air ---------------------------------------------------
dive_air_icon:
            movlw   HIGH(dive_air_block)
            movwf   TBLPTRH
            movlw   LOW(dive_air_block)
            movwf   TBLPTRL
            bra     dive_gaz_99

dive_nitrox_icon:
            movlw   HIGH(dive_nitrox_block)
            movwf   TBLPTRH
            movlw   LOW(dive_nitrox_block)
            movwf   TBLPTRL
            bra     dive_gaz_99

dive_trimix_icon:
            movlw   HIGH(dive_trimix_block)
            movwf   TBLPTRH
            movlw   LOW(dive_trimix_block)
            movwf   TBLPTRL

dive_gaz_99:
            rcall   color_image
            movlb   1                   ; Back to bank 1.
            return

;=============================================================================

#include    dive_air.inc
#include    dive_nitrox.inc
#include    dive_trimix.inc

