;=============================================================================
;
;    File aa_fonts.asm
;
;    Font-data for the anti-aliased word processor
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
;  2010-11-23 : [jDG] Creation with the original 1.72 fonts repacked.
;  2010-12-01 : [jDG] Adding 3bits antialiased fonts.
;=============================================================================

; Original fonts where byte swapped in PROM memory, but the repacked don't...
; AA_BYTE_SWAP		EQU	1

;---- SMALL font description and data ----------------------------------------
aa_fonts	code_pack
aa_font28_block:
			DB	' ', 0x80		; Translate space
			DB	'²', 0x81
			DB	'°', 0x82
			DB	'¤', 0x83
			DB	0xB7,0x7F		        ; Cursor
			DB	0xB8,0x84		        ; Dimmed cursor.
			DB	0				; End of translation table
			DB	aa_font28_firstChar			; To be substracted
			DB	aa_font28_chars				; Max value
			DB	0x83-aa_font28_firstChar; replace by ¤ when unknown.
			DB	aa_font28_height + 0x80
;
#include	"aa_font28_idx.inc"				; SHOULD FOLLOW !
#include	"aa_font28.inc"
aa_font28_end:
; Make sure this is coherent...
	if aa_font28_nbbits != 3
		error SMALL fount should be encoded with anti-aliasing...
	endif

;---- MEDIUM font description and data ---------------------------------------
aa_font48_block:
			DB	0x27, 0x3B					; ' char
			DB	'"', 0x3C
			DB	'm', 0x3D
			DB	' ', 0x3E
			DB	0
			DB	aa_font48_firstChar
			DB	aa_font48_chars
			DB	0x3E-aa_font48_firstChar
			DB	aa_font48_height + 0x80		; AA flag.
;
#include	"aa_font48_idx.inc"
#include	"aa_font48.inc"
aa_font48_end:
; Make sure this is coherent...
	if aa_font48_nbbits != 3
		error MEDIUM fount should be encoded with 3bits anti-aliasing...
	endif

;---- LARGE font description and data ----------------------------------------
aa_font90_block:
			DB	' ', 0x2F
			DB	0
			DB	aa_font90_firstChar
			DB	aa_font90_chars
			DB	0x2F-aa_font90_firstChar
			DB	aa_font90_height + 0x80		; AA flag.
;
#include	"aa_font90_idx.inc"
#include	"aa_font90.inc"
aa_font90_end:
; Make sure this is coherent...
	if aa_font90_nbbits != 3
		error SMALL fount should be encoded with 3bits anti-aliasing...
	endif

;=============================================================================
