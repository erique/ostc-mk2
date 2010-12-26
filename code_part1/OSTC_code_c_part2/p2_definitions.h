// *********************************************************
// ** Common definitions for the OSTC decompression code  **
// *********************************************************

//////////////////////////////////////////////////////////////////////////////
// OSTC - diving computer code
// Copyright (C) 2008 HeinrichsWeikamp GbR
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//////////////////////////////////////////////////////////////////////////////
// history:
// 12/25/10 v110: [jDG] split in three files (deco.c, main.c, definitions.h)

#	define	DBG_c_gas	0b0000000000000001
#	define	DBG_c_ppO2	0b0000000000000010
#	define	DBG_RUN 	0b0000000000000100
#	define	DBG_RESTART 0b0000000000001000

#	define	DBG_CdeSAT 	0b0000000000010000
#	define	DBG_C_MODE	0b0000000000100000
#	define	DBG_C_SURF	0b0000000001000000
#	define	DBG_HEwoHE 	0b0000000010000000

#	define	DBG_C_DPPO2	0b0000000100000000
#	define	DBG_C_DGAS 	0b0000001000000000
#	define	DBG_C_DIST	0b0000010000000000
#	define	DBG_C_LAST	0b0000100000000000

#	define	DBG_C_GF	0b0001000000000000
#	define	DBG_ZH16ERR	0b0010000000000000
#	define	DBG_PHIGH	0b0100000000000000
#	define	DBG_PLOW	0b1000000000000000


#	define	DBS_mode	0b0000000000000001
#	define	DBS_ppO2	0b0000000000000010
#	define	DBS_HE_sat	0b0000000000000100
#	define	DBS_ppO2chg 0b0000000000001000

#	define	DBS_SAT2l	0b0000000000010000
#	define	DBS_SAT2h	0b0000000000100000
#	define	DBS_GFLOW2l	0b0000000001000000
#	define	DBS_GFLOW2h	0b0000000010000000

#	define	DBS_GFHGH2l	0b0000000100000000
#	define	DBS_GFHGH2h	0b0000001000000000
#	define	DBS_GASO22l	0b0000010000000000
#	define	DBS_GASO22h	0b0000100000000000

#	define	DBS_DIST2h 	0b0001000000000000
#	define	DBS_LAST2h 	0b0010000000000000
#	define	DBS_DECOO2l	0b0100000000000000
#	define	DBS_DECOO2h	0b1000000000000000


#	define	DBS2_PRES2h 0b0000000000000001
#	define	DBS2_PRES2l 0b0000000000000010
#	define	DBS2_SURF2l	0b0000000000000100
#	define	DBS2_SURF2h	0b0000000000001000

#	define DBS2_DESAT2l 0b0000000000010000
#	define DBS2_DESAT2h 0b0000000000100000
#	define	DBS2_GFDneg 0b0000000001000000
#	define	DBS2_ 0b000000000000000

#	define	DBS2_ 0b000000000000000
#	define	DBS2_ 0b000000000000000
#	define	DBS2_ 0b000000000000000
#	define	DBS2_ 0b000000000000000

#	define	MBAR_REACH_GASCHANGE_AUTO_CHANGE_OFF	150

// *************************
// ** P R O T O T Y P E S **
// *************************
void calc_hauptroutine(void);
void calc_tissue(void);
void calc_nullzeit(void);
void backup_sim_pres_tissue(void);
void restore_sim_pres_tissue(void);

void calc_without_deco(void);
void clear_tissue(void);
void calc_ascenttime(void);
void update_startvalues(void);
void clear_decoarray(void);
void update_decoarray(void);
void sim_tissue_1min(void);
void sim_tissue_10min(void);
void calc_gradient_factor(void);
void calc_wo_deco_step_1_min(void);
void calc_tissue_step_1_min(void);
//void debug(void);
void calc_percentage(void);
void calc_hauptroutine_data_input(void);
void calc_hauptroutine_update_tissues(void);
void calc_hauptroutine_calc_deco(void);
void calc_hauptroutine_calc_ascend_to_deco(void);
//void build_debug_output(void);
void calc_nextdecodepth_GF(void);
void copy_deco_table_GF(void);
void clear_internal_deco_table_GF(void);
void update_internal_deco_table_GF(void);


void deco_calc_hauptroutine(void);
void deco_calc_without_deco(void);
void deco_clear_tissue(void);
void deco_calc_percentage(void);
void deco_calc_wo_deco_step_1_min(void);
void deco_debug(void);
void deco_gradient_array(void);
void deco_hash(void);
void deco_calc_desaturation_time(void);
void deco_calc_CNS_fraction(void);
void deco_clear_CNS_fraction(void);
void deco_push_tissues_to_vault(void);
void deco_pull_tissues_from_vault(void);

// *************************************************
// ** V A R I A B L E S   D E C L A R A T I O N S **
// *************************************************
// prefixes etc:
// _O_ = output for use in the assembler code
// _I_ = input from the assembler code for the c code
// char_ and int_ = used to identify output and input size
// var = variable (from b"uhlmann)
// pres = pressure
// gtissue = guiding tissue, the one limiting the ascent
// e2secs = exp of the b"uhlmann formula precalculated for a 2 second step
// e1min = same for 1 minute step
// sim = used in simulating the ascent to the surface
// nullzeit = remaining ground/bottom time for "no deco"
// hauptroutine = main

extern unsigned int  int_O_tissue_for_debug[32];
extern unsigned int	 int_O_GF_spare____;					
extern unsigned int	 int_O_GF_step;						
extern unsigned int  int_O_gtissue_limit;			
extern unsigned int  int_O_gtissue_press;			
extern unsigned int  int_O_limit_GF_low;				
extern unsigned int  int_O_gtissue_press_at_GF_low;	
extern unsigned char char_I_step_is_1min;		
extern unsigned char char_O_GF_low_pointer;		
extern unsigned char char_O_actual_pointer;		
extern unsigned char char_O_deco_table[32];		
extern unsigned char char_I_table_deco_done[32];
extern unsigned int  int_O_calc_tissue_call_counter;

//---- Bank 5 parameters -----------------------------------------------------
extern unsigned int  int_I_pres_respiration;
extern unsigned int  int_I_pres_surface;	
extern unsigned int  int_I_temp;
extern unsigned char char_I_temp;
extern unsigned char char_I_actual_ppO2;	
extern unsigned char char_I_deco_N2_ratio2; 
extern unsigned char char_I_deco_He_ratio2; 
extern unsigned char char_I_deco_N2_ratio3; 
extern unsigned char char_I_deco_He_ratio3; 
extern unsigned char char_I_deco_N2_ratio4; 
extern unsigned char char_I_deco_He_ratio4; 
extern unsigned char char_I_deco_N2_ratio5; 
extern unsigned char char_I_deco_He_ratio5; 
extern unsigned char char_I_N2_ratio;		
extern unsigned char char_I_He_ratio;		
extern unsigned char char_I_saturation_multiplier;
extern unsigned char char_I_desaturation_multiplier;
extern unsigned char char_I_GF_High_percentage;
extern unsigned char char_I_GF_Low_percentage;
extern unsigned char char_I_spare;
extern unsigned char char_I_deco_distance;
extern unsigned char char_I_const_ppO2;
extern unsigned char char_I_deco_ppO2_change;
extern unsigned char char_I_deco_ppO2;
extern unsigned char char_I_deco_gas_change;
extern unsigned char char_I_deco_N2_ratio;
extern unsigned char char_I_deco_He_ratio;
extern unsigned char char_I_depth_last_deco;
extern unsigned char char_I_deco_model;

extern unsigned int  int_O_desaturation_time;			
extern unsigned char char_O_nullzeit;					
extern unsigned char char_O_deco_status;				
extern unsigned char char_O_array_decotime[7];			
extern unsigned char char_O_array_decodepth[6];		
extern unsigned char char_O_ascenttime;				
extern unsigned char char_O_gradient_factor;			
extern unsigned char char_O_tissue_saturation[32];		
extern unsigned char char_O_array_gradient_weighted[16];
extern unsigned char char_O_gtissue_no;				
extern unsigned char char_O_diluent;				
extern unsigned char char_O_CNS_fraction;			
extern unsigned char char_O_relative_gradient_GF;	
extern unsigned char char_I_deco_gas_change2;       
extern unsigned char char_I_deco_gas_change3;       
extern unsigned char char_I_deco_gas_change4;       
extern unsigned char char_I_deco_gas_change5;       

//---- Bank 9 parameters -----------------------------------------------------
extern unsigned int  int_O_DBS_bitfield;				
extern unsigned int  int_O_DBS2_bitfield;				
extern unsigned int  int_O_DBG_pre_bitfield;			
extern unsigned int  int_O_DBG_post_bitfield;			
extern unsigned char char_O_NDL_at_20mtr;				
