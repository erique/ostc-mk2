
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


; DIGIT DRAW (dd)
; routines for nice digit OLED output
; written by: Christian Weikamp, info@heinrichsweikamp.com
; written: 08/11/07
; last updated: 12/17/07
; known bugs:
; ToDo:

; -----------------------------
; Routines, accessible
; -----------------------------
; DD_Main
; DD_Graph_tissue
; dd_print_mini_font

; -----------------------------
; DD_Main: (alpha)
; -----------------------------
; INPUT (for main only):
; is different in mini_font and print graph 
; temp_font_select = width:0 (for digits before decpoint)
; temp2_pointer_row = width:1
; temp_pointer_column = width:2
; temp2_pointer_column = width:3
; temp_pointer_decpoint = width:4
; temp_font_select = width:5 (for decpoint and following digits)
; letter

DD_Main:
return
dd_print_mini_font:
return
DD_Graph_tissue:
return
DD_graf_Main:
return

