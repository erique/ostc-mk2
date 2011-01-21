#ifdef xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;    shared_definitions.h
;
;    Declare variables used both in C and ASM code
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
; RATIONAL
;
; We must enforce good data passing between the C and the ASM parts of code.
; The previous design used two independant definitions of each variable,
; one in C, one in ASM. If they did not match, no error was generated, and
; anything can happend at runtime...
;
; The new design use LINKING to ensure the variables defined in C are at the
; same address when used in ASM code. And it uses a unique declaration file
; (with suitable macros) to make sure they have the same size in both language.
;
; HISTORY
;  2011-01-20: [jDG] Creation.
;
; NOTE
;
; This file have to obey both ASM and C syntax. The only common directives
; are #if/#ifdef/#endif and the #define, so they are eavily used to do the
; trick.
;
; BUGS
;=============================================================================
#endif

#ifdef __18CXX
    //------------------------------------------------------------------------
    // C-style declarations:
#   define VAR_UCHAR(n)      unsigned char n
#   define TAB_UCHAR(n,size) unsigned char n[size]
#   define VAR_UINT(n)       unsigned  int n
#   define TAB_UINT(n,size)  unsigned  int n[size]
#else
    ;-------------------------------------------------------------------------
    ; ASM-style declarations:
#define VAR_UCHAR(n)       n    res     1
#define TAB_UCHAR(n,size)  n    res     size
#define VAR_UINT(n)        n    res     2
#define TAB_UINT(n,size)   n    res     2*size
#endif

#ifdef __18CXX
    //---- BANK 2 DATA -------------------------------------------------------
    // Gather all data C-code --> ASM-code
#   pragma udata overlay bank2=0x200
#else
bank2   udata_ovr  0x200
#endif

VAR_UINT  (int_O_GF_step);
VAR_UINT  (int_O_gtissue_limit);
VAR_UINT  (int_O_gtissue_press);
VAR_UINT  (int_O_limit_GF_low);
VAR_UINT  (int_O_gtissue_press_at_GF_low);
VAR_UINT  (int_O_calc_tissue_call_counter);

VAR_UCHAR (char_O_GF_low_pointer);
VAR_UCHAR (char_O_actual_pointer);

VAR_UINT  (int_O_desaturation_time);       // 
VAR_UCHAR (char_O_nullzeit);               // 
VAR_UCHAR (char_O_deco_status);            // 
VAR_UCHAR (char_O_ascenttime);             // 
VAR_UCHAR (char_O_gradient_factor);        // 
VAR_UCHAR (char_O_gtissue_no);             // 
VAR_UCHAR (char_O_diluent);                // new in v.101
VAR_UCHAR (char_O_CNS_fraction);           // new in v.101
VAR_UCHAR (char_O_relative_gradient_GF);   // new in v.102

TAB_UCHAR (char_O_array_decotime, 7);      // Old-school decompression table (ZHL-16)
TAB_UCHAR (char_O_array_decodepth, 6);     // 

TAB_UCHAR (char_O_deco_table, 0x20);        // New school decompression table (GF mode)
TAB_UCHAR (char_O_tissue_saturation, 0x20); // Compartiment desaturation time, in min.

VAR_UINT  (int_O_DBS_bitfield);
VAR_UINT  (int_O_DBS2_bitfield);
VAR_UINT  (int_O_DBG_pre_bitfield);
VAR_UINT  (int_O_DBG_post_bitfield);
VAR_UCHAR (char_O_NDL_at_20mtr);

#ifdef __18CXX
    //---- BANK 3 DATA -------------------------------------------------------
    // Gather all data ASM-code --> C-code
#   pragma udata overlay bank3=0x300
#else
    ; In ASM, put the same bank, in overlay mode, at the same address
bank3   udata_ovr  0x300
#endif

VAR_UCHAR (char_I_step_is_1min);
TAB_UCHAR (char_I_table_deco_done, 0x20);

VAR_UINT  (int_I_pres_respiration);        // 
VAR_UINT  (int_I_pres_surface);            // 
VAR_UINT  (int_I_temp);                    // new in v101
VAR_UCHAR (char_I_temp);                   // new in v101
VAR_UCHAR (char_I_actual_ppO2);            // 
VAR_UCHAR (char_I_deco_N2_ratio2);         // new in v.109
VAR_UCHAR (char_I_deco_He_ratio2);         // new in v.109
VAR_UCHAR (char_I_deco_N2_ratio3);         // new in v.109
VAR_UCHAR (char_I_deco_He_ratio3);         // new in v.109
VAR_UCHAR (char_I_deco_N2_ratio4);         // new in v.109
VAR_UCHAR (char_I_deco_He_ratio4);         // new in v.109
VAR_UCHAR (char_I_deco_N2_ratio5);         // new in v.109
VAR_UCHAR (char_I_deco_He_ratio5);         // new in v.109
VAR_UCHAR (char_I_N2_ratio);               //
VAR_UCHAR (char_I_He_ratio);               //
VAR_UCHAR (char_I_saturation_multiplier);  // for conservatism/safety values 1.0  no conservatism to 1.5  50% faster saturation
VAR_UCHAR (char_I_desaturation_multiplier);// for conservatism/safety values 0.66  50% slower desaturation to 1.0  no conservatism// consveratism used in calc_tissue , calc_tissue_step_1_min  and sim_tissue_1min 
VAR_UCHAR (char_I_GF_High_percentage);     // new in v.102
VAR_UCHAR (char_I_GF_Low_percentage);      // new in v.102
VAR_UCHAR (char_I_deco_distance);          // 
VAR_UCHAR (char_I_const_ppO2);             // new in v.101
VAR_UCHAR (char_I_deco_ppO2_change);       // new in v.101
VAR_UCHAR (char_I_deco_ppO2);              // new in v.101
VAR_UCHAR (char_I_deco_gas_change);        // new in v.101
VAR_UCHAR (char_I_deco_N2_ratio);          // new in v.101
VAR_UCHAR (char_I_deco_He_ratio);          // new in v.101
VAR_UCHAR (char_I_depth_last_deco);        // new in v.101 unit: [m]
VAR_UCHAR (char_I_deco_model);             // new in v.102	  1 = MultiGraF, sonst Std. mit  de-saturation_multiplier

VAR_UCHAR (char_I_deco_gas_change2);       // new in v.109
VAR_UCHAR (char_I_deco_gas_change3);       // new in v.109
VAR_UCHAR (char_I_deco_gas_change4);       // new in v.109
VAR_UCHAR (char_I_deco_gas_change5);       // new in v.109
