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
;  2011-01-03 : [jDG] Force first gas to be active from depth=0.
;
; RATIONALS: Enabled gazes are used to predict TTS in divemode, hence they
;            are a critical aspect that should be double-checked before dive.
;
; Known bug:
;=============================================================================
mixtype_icons   code

;=============================================================================
; Display either Air, Nitrox, or Trimix icon (in surface mode).
; Inputs:  None: explore the gaz list.
; Ouputs:  None.
; Trashed: hi:lo, PROD, and registers trashed by color_processor.asm
dive_type_icons:
            ;---- Don't display when not in the right deco mode --------------
            btfsc   FLAG_apnoe_mode     ; Apnoe selected ?
            return                      ; YES: just return.
            btfsc   gauge_mode          ; gauge mode ?
            return                      ; YES: also return.
            
            ;---- Don't display CF#41 is false -------------------------------
            GETCUSTOM8  d'41'           ; Read CF#41
            btfss   WREG,0              ; Set ?
            return                      ; NO: return

            ;---- Common setup -----------------------------------------------
            movlw   .170
            movff   WREG, win_top
            movlw   .110
            movff   WREG, win_leftx2
            movlw   UPPER(dive_air_block)
            movwf   TBLPTRU

            ;---- Explore gas list -------------------------------------------
            ; EEADR <-- gas# + 6
            ; EEADR-2 = default O2%
            ; EEADR-1 = default He%
            ; EEADR+0 = current O2%
            ; EEADR+1 = current He%
            ; EEADR+4 = next gaz current O2%
            
          	read_int_eeprom		d'27'	; read gas flag register --> hi
          	movff   EEDATA,hi
            rrcf    hi                  ; Dummy shift first... why does it works ?
          	setf    lo                  ; Start with gas# -1
	        clrf    PRODL               ; =0 : no nitrox found yet.

dive_type_loop:
            incf    lo,F                ; Next gaz number.

            movlw   .33                 ; Read first gas #.
            movwf   EEADR
            call    read_eeprom
            incf    lo,W                ; Current gas# 1..5
            subwf   EEDATA,W            ; == first ?
            bz      dive_type_loop_2    ; YES: analyse that gas !
            
            rrcf    hi                  ; Check next enabled flag ?
            bnc     dive_type_loop_9    ; Disabled.

            movlw   .28                 ; Switch depth is at gas#+28
            addwf   lo,W
            movwf   EEADR               ; address in EEPROM.
            call    read_eeprom         ; Read depth
            clrf    WREG                
            cpfsgt  EEDATA              ; is depth > 0 ?
            bra      dive_type_loop_9   ; NO: disabled too.

dive_type_loop_2:
            rlncf   lo,W                ; Gas# times 4
            rlncf   WREG
            addlw   4+2                 ; 6 + 4 * gas#
            movwf   EEADR               ; address in EEPROM for current O2.
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
            movlw   4                   ; Already done all gas ? (index 0..4)
            cpfseq  lo                  ; gas# == 4 ?
            bra     dive_type_loop      ; NO: loop...
	        
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
            call    color_image
            movlb   1                   ; Back to bank 1.
            return

;=============================================================================

#include    dive_air.inc
#include    dive_nitrox.inc
#include    dive_trimix.inc

