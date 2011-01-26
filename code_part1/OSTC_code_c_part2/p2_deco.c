// **************************************************************
// p2_deco.c
//
//  Created on: 12.05.2009
//  Author: chsw
//
// **************************************************************

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

// *****************************
// ** I N T R O D U C T I O N **
// *****************************
//
// OSTC
//
// code:
// p2_deco_main_c_v101.c
// part2 of the OSTC code
// code with constant O2 partial pressure routines
// under construction !!
//
// summary:
// decompression routines
// for the OSTC experimental project
// written by Christian Weikamp
// last revision __________
// comments added _________
//
// additional files:
// p2_tables_v100.romdata (other files)
// 18f4685_ostc_v100.lkr (linker script)
//
// history:
// 01/03/08 v100: first release candidate
// 03/13/08 v101: start of programming ppO2 code
// 03/13/25 v101a: backup of interrim version with ppO2 calculation
// 03/13/25 v101: open circuit gas change during deco
// 03/13/25 v101: CNS_fraction calculation
// 03/13/26 v101: optimization of tissue calc routines
// 07/xx/08 v102a: debug of bottom time routine
// 09/xx/08 v102d: Gradient Factor Model implemenation
// 10/10/08 v104: renamed to build v103 for v118 stable
// 10/14/08	v104: integration of temp_depth_last_deco for Gradient Model
// 03/31/09 v107: integration of FONT Incon24
// 05/23/10 v109: 5 gas changes & 1 min timer
// 07/13/10 v110: cns vault added
// 12/25/10 v110: split in three files (deco.c, main.c, definitions.h)
// 2011/01/20: [jDG] Create a common file included in ASM and C code.
// 2011/01/23: [jDG] Added read_custom_function().
// 2011/01/24: [jDG] Make ascenttime an int. No more overflow!
// 2011/01/25: [jDG] Fusion deco array for both models.
// 2011/01/25: [jDG] Use CF(54) to reverse deco order.
//
// TODO:
//  + Allow (CF) delay for gas switch while predicting ascent.
//  + Allow to abort MD2 calculation (have to restart next time).
//
// Literature:
// B"uhlmann, Albert: Tauchmedizin; 4. Auflage;
// Schr"oder, Kai & Reith, Steffen; 2000; S"attigungsvorg"ange beim Tauchen, das Modell ZH-L16, Funktionsweise von Tauchcomputern; http://www.achim-und-kai.de/kai/tausim/saett_faq
// Morrison, Stuart; 2000; DIY DECOMPRESSION; http://www.lizardland.co.uk/DIYDeco.html
// Balthasar, Steffen; Dekompressionstheorie I: Neo Haldane Modelle; http://www.txfreak.de/dekompressionstheorie_1.pdf
// Baker, Erik C.; Clearing Up The Confusion About "Deep Stops"
// Baker, Erik C.; Understanding M-values; http://www.txfreak.de/understanding_m-values.pdf
//
//

// *********************
// ** I N C L U D E S **
// *********************
#include <math.h>

// *************************
// ** P R O T O T Y P E S **
// *************************

static void calc_hauptroutine(void);
static void calc_tissue_2_secs(void);
static void calc_tissue_1_min(void);
static void calc_nullzeit(void);
static void backup_sim_pres_tissue(void);
static void restore_sim_pres_tissue(void);

static void calc_without_deco(void);
static void clear_tissue(void);
static void calc_ascenttime(void);
static void update_startvalues(void);
static void clear_deco_table(void);
static void update_deco_table(void);
static void sim_tissue_1min(void);
static void sim_tissue_10min(void);
static void calc_gradient_factor(void);
static void calc_wo_deco_step_1_min(void);

static void calc_hauptroutine_data_input(void);
static void calc_hauptroutine_update_tissues(void);
static void calc_hauptroutine_calc_deco(void);
static void sim_ascent_to_first_stop(void);

static void calc_nextdecodepth_GF(void);

// ***********************************************
// ** V A R I A B L E S   D E F I N I T I O N S **
// ***********************************************

#include "p2_definitions.h"
#include "../OSTC_code_c_part2/shared_definitions.h"

//---- Bank 3 parameters -----------------------------------------------------
#pragma udata bank4=0x400

static unsigned char 	lock_GF_depth_list;
static float			temp_limit;
static float			GF_low;
static float			GF_high;
static float			GF_delta;
static float			GF_temp;
static float			GF_step;
static float			GF_step2;
static float			temp_pres_gtissue;
static float			temp_pres_gtissue_diff;
static float			temp_pres_gtissue_limit_GF_low;
static float			temp_pres_gtissue_limit_GF_low_below_surface;
static	unsigned int	temp_depth_limit;
static unsigned char	temp_gtissue_no;
static	unsigned int	temp_depth_last_deco;				// new in v.101

static unsigned char	temp_depth_GF_low_meter;
static unsigned char	internal_deco_pointer;

static unsigned char	internal_deco_time[32];
static unsigned char	internal_deco_depth[32];

static float cns_vault;
static float pres_tissue_vault[32];

//---- Bank 5 parameters -----------------------------------------------------
#pragma udata bank5=0x500

static unsigned char	ci;
static float 			pres_respiration;
static float			pres_surface;
static float			temp1;
static float			temp2;
static float			temp3;
static float			temp4;
static float			temp_deco;
static float			temp_atem;
static float			temp2_atem;
static float			temp_tissue;
static float			temp_surface;
static float			N2_ratio;
static float			He_ratio;
static float 			var_N2_a;
static float 			var_N2_b;
static float 			var_He_a;
static float 			var_He_b;
static float  			var_N2_e;
static float  			var_He_e;
static float  			var_N2_halftime;
static float  			var_He_halftime;
static float			pres_gtissue_limit;
static float			temp_pres_gtissue_limit;

static float            pres_diluent;               // new in v.101
static float            deco_diluent;               // new in v.101
static float            const_ppO2;                 // new in v.101
static float            deco_ppO2_change;           // new in v.101
static float            deco_ppO2;                  // new in v.101

static float			calc_N2_ratio;			// new in v.101
static float			calc_He_ratio;			// new in v.101
static float			CNS_fraction;			// new in v.101
static float			float_saturation_multiplier;		// new in v.101
static float			float_desaturation_multiplier;		// new in v.101
static float			float_deco_distance;	// new in v.101
static char			    flag_in_divemode;		// new in v.108

static float			deco_gas_change1;		// new in v.101
static float			deco_gas_change2;		// new in v.109
static float			deco_gas_change3;		// new in v.109
static float			deco_gas_change4;		// new in v.109
static float			deco_gas_change5;		// new in v.109

static float			deco_N2_ratio1;			// new in v.101
static float			deco_He_ratio1;			// new in v.101
static float			deco_N2_ratio2;			// new in v.109
static float			deco_N2_ratio3;			// new in v.109
static float			deco_N2_ratio4;			// new in v.109
static float			deco_N2_ratio5;			// new in v.109
static float			deco_He_ratio2;			// new in v.109
static float			deco_He_ratio3;			// new in v.109
static float			deco_He_ratio4;			// new in v.109
static float			deco_He_ratio5;			// new in v.109


//---- Bank 6 parameters -----------------------------------------------------
#pragma udata bank6=0x600

static float  pres_tissue[32];
static float  pres_tissue_limit[16];
static float  sim_pres_tissue_limit[16];

//---- Bank 7 parameters -----------------------------------------------------
#pragma udata bank7=0x700

static float  sim_pres_tissue[32];              // 32 floats = 128 bytes.
static float  sim_pres_tissue_backup[32];

//---- Bank 8 parameters -----------------------------------------------------
#pragma udata bank8=0x800

static char	  md_pi_subst[256];
#define C_STACK md_pi_subst                     // Overlay C-code data stack here, too.

//---- Bank 9 parameters -----------------------------------------------------
#pragma udata bank9=0x900

static char	  md_state[48];		        // DONT MOVE !! // has to be at the beginning of bank 9 for the asm code!!!

// internal, dbg:
static unsigned char	DBG_char_I_deco_model;	// new in v.108.
static unsigned char	DBG_char_I_depth_last_deco;			// new in v.108
static float			DBG_pres_surface;		// new in v.108
static float			DBG_GF_low;				// new in v.108
static float			DBG_GF_high;			// new in v.108
static float			DBG_const_ppO2;			// new in v.108
static float			DBG_deco_ppO2_change;	// new in v.108
static float			DBG_deco_ppO2;			// new in v.108
static float			DBG_deco_N2_ratio;		// new in v.108
static float			DBG_deco_He_ratio;		// new in v.108
static float			DBG_deco_gas_change;	// new in v.108
static float			DBG_float_saturation_multiplier;	// new in v.108
static float			DBG_float_desaturation_multiplier;	// new in v.108
static float			DBG_float_deco_distance;			// new in v.108
static float			DBG_deco_N2_ratio;		// new in v.108
static float			DBG_deco_He_ratio;		// new in v.108
static float			DBG_N2_ratio;			// new in v.108
static float			DBG_He_ratio;			// new in v.108

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
///////////////////////////// THE LOOKUP TABLES //////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//
// End of PROM code is 17F00, So push tables on PROM top...
//
#pragma romdata buhlmann_tables = 0x017B00  // Needs to be in UPPER bank.
#include "p2_tables.romdata" 		        // new table for deco_main_v.101 (var_N2_a modified)

// Magic table to compute the MD2 HASH
//
#pragma romdata hash_tables = 0x017E00  // Address fixed by ASM access...
rom const rom unsigned int md_pi[] =
{
    0x292E, 0x43C9, 0xA2D8, 0x7C01, 0x3D36, 0x54A1, 0xECF0, 0x0613
  , 0x62A7, 0x05F3, 0xC0C7, 0x738C, 0x9893, 0x2BD9, 0xBC4C, 0x82CA
  , 0x1E9B, 0x573C, 0xFDD4, 0xE016, 0x6742, 0x6F18, 0x8A17, 0xE512
  , 0xBE4E, 0xC4D6, 0xDA9E, 0xDE49, 0xA0FB, 0xF58E, 0xBB2F, 0xEE7A
  , 0xA968, 0x7991, 0x15B2, 0x073F, 0x94C2, 0x1089, 0x0B22, 0x5F21
  , 0x807F, 0x5D9A, 0x5A90, 0x3227, 0x353E, 0xCCE7, 0xBFF7, 0x9703
  , 0xFF19, 0x30B3, 0x48A5, 0xB5D1, 0xD75E, 0x922A, 0xAC56, 0xAAC6
  , 0x4FB8, 0x38D2, 0x96A4, 0x7DB6, 0x76FC, 0x6BE2, 0x9C74, 0x04F1
  , 0x459D, 0x7059, 0x6471, 0x8720, 0x865B, 0xCF65, 0xE62D, 0xA802
  , 0x1B60, 0x25AD, 0xAEB0, 0xB9F6, 0x1C46, 0x6169, 0x3440, 0x7E0F
  , 0x5547, 0xA323, 0xDD51, 0xAF3A, 0xC35C, 0xF9CE, 0xBAC5, 0xEA26
  , 0x2C53, 0x0D6E, 0x8528, 0x8409, 0xD3DF, 0xCDF4, 0x4181, 0x4D52
  , 0x6ADC, 0x37C8, 0x6CC1, 0xABFA, 0x24E1, 0x7B08, 0x0CBD, 0xB14A
  , 0x7888, 0x958B, 0xE363, 0xE86D, 0xE9CB, 0xD5FE, 0x3B00, 0x1D39
  , 0xF2EF, 0xB70E, 0x6658, 0xD0E4, 0xA677, 0x72F8, 0xEB75, 0x4B0A
  , 0x3144, 0x50B4, 0x8FED, 0x1F1A, 0xDB99, 0x8D33, 0x9F11, 0x8314
};

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
////////////////////////////// THE SUBROUTINES ///////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//
// all new in v.102
// moved from 0x0D000 to 0x0C000 in v.108

#pragma code p2_deco = 0x0C000

//////////////////////////////////////////////////////////////////////////////
// DBS - debug on start of dive
//
static void create_dbs_set_dbg_and_ndl20mtr(void)
{
    overlay char i;                     // Local loop index.

    //---- Reset DEBUG bit fields --------------------------------------------
	int_O_DBS_bitfield = 0;
	int_O_DBS2_bitfield = 0;
	if(int_O_DBG_pre_bitfield & DBG_RUN)
		int_O_DBG_pre_bitfield = DBG_RESTART;
	else
		int_O_DBG_pre_bitfield = DBG_RUN;
	int_O_DBG_post_bitfield = 0;
	
	//---- Set 20meters ND limit ---------------------------------------------
	char_O_NDL_at_20mtr = 255;

    //---- Copy all dive parameters ------------------------------------------
	DBG_N2_ratio = N2_ratio;
	DBG_He_ratio = He_ratio;
	DBG_char_I_deco_model = char_I_deco_model;
	DBG_char_I_depth_last_deco = char_I_depth_last_deco;
	DBG_pres_surface = pres_surface;
	DBG_GF_low = GF_low;
	DBG_GF_high = GF_high;
	DBG_const_ppO2 = const_ppO2;
	DBG_deco_ppO2_change = deco_ppO2_change;
	DBG_deco_ppO2 = deco_ppO2;
	DBG_deco_N2_ratio = deco_N2_ratio1;
	DBG_deco_He_ratio = deco_He_ratio1;
	DBG_deco_gas_change = deco_gas_change1;
	DBG_float_saturation_multiplier = float_saturation_multiplier;
	DBG_float_desaturation_multiplier = float_desaturation_multiplier;
	DBG_float_deco_distance = float_deco_distance;

    //---- Setup some error (?) conditions -----------------------------------
	if(char_I_deco_model)
		int_O_DBS_bitfield |= DBS_mode;
	if(const_ppO2)
		int_O_DBS_bitfield |= DBS_ppO2;
	for(i = 16; i < 32; i++)
		if(pres_tissue[i])
			int_O_DBS_bitfield |= DBS_HE_sat;
	if(deco_ppO2_change)
		int_O_DBS_bitfield |= DBS_ppO2chg;
	if(float_saturation_multiplier < 0.99)
		int_O_DBS_bitfield |= DBS_SAT2l;
	if(float_saturation_multiplier > 1.3)
		int_O_DBS_bitfield |= DBS_SAT2h;
	if(GF_low < 0.19)
		int_O_DBS_bitfield |= DBS_GFLOW2l;
	if(GF_low > 1.01)
		int_O_DBS_bitfield |= DBS_GFLOW2h;
	if(GF_high < 0.6)
		int_O_DBS_bitfield |= DBS_GFHGH2l;
	if(GF_high > 1.01)
		int_O_DBS_bitfield |= DBS_GFHGH2h;
	if((N2_ratio + He_ratio) > 0.95)
		int_O_DBS_bitfield |= DBS_GASO22l;
	if((N2_ratio + He_ratio) < 0.05)
		int_O_DBS_bitfield |= DBS_GASO22h;
	if(float_deco_distance > 0.25)
		int_O_DBS_bitfield |= DBS_DIST2h;
	if(char_I_depth_last_deco > 8)
		int_O_DBS_bitfield |= DBS_LAST2h;
	if(DBG_deco_gas_change && ((deco_N2_ratio1 + deco_He_ratio1) > 0.95))
		int_O_DBS_bitfield |= DBS_DECOO2l;
	if(DBG_deco_gas_change && ((deco_N2_ratio1 + deco_He_ratio1) < 0.05))
		int_O_DBS_bitfield |= DBS_DECOO2h;
	if(pres_respiration > 3.0)
		int_O_DBS2_bitfield |= DBS2_PRES2h;
	if(pres_surface - pres_respiration > 0.2)
		int_O_DBS2_bitfield |= DBS2_PRES2l;
	if(pres_surface < 0.75)
		int_O_DBS2_bitfield |= DBS2_SURF2l;
	if(pres_surface > 1.11)
		int_O_DBS2_bitfield |= DBS2_SURF2h;
	if(float_desaturation_multiplier < 0.70)
		int_O_DBS2_bitfield |= DBS2_DESAT2l;
	if(float_desaturation_multiplier > 1.01)
		int_O_DBS2_bitfield |= DBS2_DESAT2h;
	if(GF_low > GF_high)
		int_O_DBS2_bitfield |= DBS2_GFDneg;
}

//////////////////////////////////////////////////////////////////////////////
// DBG - set DBG to end_of_dive
//
static void set_dbg_end_of_dive(void)
{
	int_O_DBG_pre_bitfield &= (~DBG_RUN);
	int_O_DBG_post_bitfield &= (~DBG_RUN);
}

//////////////////////////////////////////////////////////////////////////////
// DBG - NDL at first 20 m. hit
//
static void check_ndl(void)
{
	if( char_O_NDL_at_20mtr == 255      // Still in NDL mode ?
	 && int_I_pres_respiration > 3000   // And we hit the 20m limit ?
	)
	{
		char_O_NDL_at_20mtr = char_O_nullzeit;  // change to max bottom time.
		if( char_O_NDL_at_20mtr == 255)         // and avoid confusion.
			char_O_NDL_at_20mtr == 254;
	}
}

//////////////////////////////////////////////////////////////////////////////
// DBG - multi main during dive
//
static void check_dbg(static char is_post_check)
{
	overlay unsigned int temp_DBS = 0;
    overlay char i;                     // Local loop index.

	if( (DBG_N2_ratio != N2_ratio) || (DBG_He_ratio != He_ratio) )
		temp_DBS |= DBG_c_gas;
	if(DBG_const_ppO2 != const_ppO2)
		temp_DBS |= DBG_c_ppO2;
	if( DBG_float_saturation_multiplier != float_saturation_multiplier
     || DBG_float_desaturation_multiplier != float_desaturation_multiplier
    )
		temp_DBS |= DBG_CdeSAT;
	if(DBG_char_I_deco_model != char_I_deco_model)
		temp_DBS |= DBG_C_MODE;
	if(DBG_pres_surface != pres_surface)
		temp_DBS |= DBG_C_SURF;

	if( !DBS_HE_sat && !He_ratio)
		for(i = 16; i < 32; i++)
			if(pres_tissue[i])
				temp_DBS |= DBG_HEwoHE;

	if(DBG_deco_ppO2 != deco_ppO2)
		temp_DBS |= DBG_C_DPPO2;

	if( DBG_deco_gas_change != deco_gas_change1
	 || DBG_deco_N2_ratio != deco_N2_ratio1
	 || DBG_deco_He_ratio != deco_He_ratio1 )
		temp_DBS |= DBG_C_DGAS;

	if(DBG_float_deco_distance != float_deco_distance)
		temp_DBS |= DBG_C_DIST;
	if(DBG_char_I_depth_last_deco != char_I_depth_last_deco)
		temp_DBS |= DBG_C_LAST;
	if( DBG_GF_low != GF_low
	 || DBG_GF_high != GF_high )
		temp_DBS |= DBG_C_GF;
	if(pres_respiration > 13.0)
		temp_DBS |= DBG_PHIGH;
	if(pres_surface - pres_respiration > 0.2)
		temp_DBS |= DBG_PLOW;
	if(is_post_check)
		int_O_DBG_post_bitfield |= temp_DBS;
	else
		int_O_DBG_pre_bitfield |= temp_DBS;
}

//////////////////////////////////////////////////////////////////////////////
// DBG - prior to calc. of dive
//
static void check_pre_dbg(void)
{
	check_dbg(0);
}

//////////////////////////////////////////////////////////////////////////////
// DBG - after decocalc of dive
//
static void check_post_dbg(void)
{
	check_dbg(1);
}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
///////////////////////  U T I L I T I E S   /////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

static int read_custom_function(static unsigned char cf)
{
    extern unsigned char hi, lo;
    extern void getcustom15();
    _asm
        movff   cf,WREG
        call    getcustom15,0
        movff   lo,PRODL
        movff   hi,PRODH
    _endasm
}

//////////////////////////////////////////////////////////////////////////////
// read buhlmann tables for compatriment ci
// If period == 0 : 2sec interval
//              1 : 1 min interval
//              2 : 10 min interval.
static void read_buhlmann_coeffifients(static char period)
{
    // Note: we don't use far rom pointer, because the
    //       24 bits is to complex, hence we have to set
    //       the UPPER page ourself...
    //       --> Set zero if tables are moved to lower pages !
    _asm
        movlw 1
        movwf TBLPTRU,0
    _endasm

    var_N2_a = buhlmann_a[ci];
    var_N2_b = buhlmann_b[ci];
    var_He_a = (buhlmann_a+16)[ci];
    var_He_b = (buhlmann_b+16)[ci];

    // Check reading consistency:
	if(	(var_N2_a < 0.231)
	 || (var_N2_a > 1.27)
	 || (var_N2_b < 0.504)
	 || (var_N2_b > 0.966)
	 || (var_He_a < 0.510)
	 || (var_He_a > 1.75)
	 || (var_He_b < 0.423)
	 || (var_He_b > 0.927)
    )
        int_O_DBG_pre_bitfield |= DBG_ZH16ERR;
        
    // Integration intervals.
    switch(period)
    {
    case -1://---- no interval -----------------------------------------------
        var_N2_e = var_He_e = 0.0;
        break;

    case 0: //---- 2 sec -----------------------------------------------------
        var_N2_e = e2secs[ci];
        var_He_e = (e2secs+16)[ci];

        // Check reading consistency:
    	if(	(var_N2_e < 0.0000363)
    	 || (var_N2_e > 0.00577)
    	 || (var_He_e < 0.0000961)
    	 || (var_He_e > 0.150)
        )
            int_O_DBG_pre_bitfield |= DBG_ZH16ERR;

        break;

    case 1: //---- 1 min -----------------------------------------------------
        var_N2_e = e1min[ci];
        var_He_e = (e1min+16)[ci];

        // Check reading consistency:
    	if(	(var_N2_e < 1.09E-3)
    	 || (var_N2_e > 0.1592)
    	 || (var_He_e < 0.00288)
    	 || (var_He_e > 0.3682)
        )
            int_O_DBG_pre_bitfield |= DBG_ZH16ERR;

        break;

    case 2: //---- 10 min ----------------------------------------------------
        var_N2_e = e10min[ci];
        var_He_e = (e10min+16)[ci];

        // Check reading consistency:
    	if(	(var_N2_e < 0.01085)
    	 || (var_N2_e > 0.82323)
    	 || (var_He_e < 0.02846)
    	 || (var_He_e > 0.98986)
        )
            int_O_DBG_pre_bitfield |= DBG_ZH16ERR;

        break;
    }
}

//////////////////////////////////////////////////////////////////////////////
// calc_next_decodepth_GF
//
// new in v.102
//
// INPUT, changing during dive:
//      temp_pres_gtissue_limit_GF_low
//      temp_pres_gtissue_limit_GF_low_below_surface
//      temp_pres_gtissue
//      temp_pres_gtissue_diff
//      lock_GF_depth_list
//
// INPUT, fixed during dive:
//      pres_surface
//      GF_delta
//      GF_high
//      GF_low
//      temp_depth_last_deco
//      float_deco_distance
//
// OUTPUT
//      GF_step
//      temp_deco
//      temp_depth_limt
//      lock_GF_depth_list
//
static void calc_nextdecodepth_GF(void)
{

	char_I_table_deco_done[0] = 0; // safety if changed somewhere else. Needed for exit
	
	//---- ZH-L16 + GRADIENT FACTOR model ------------------------------------
	if (char_I_deco_model == 1)
	{
        overlay float next_stop;            // Next stop to test, in Bar.
        overlay float press_tol;            // Upper limit (lower pressure) tolerated.
        overlay int   int_temp;
        overlay unsigned char temp_depth_GF_low_number;
        overlay float temp_pres_deco_GF_low;

		if (lock_GF_depth_list == 0)
		{
			next_stop =  temp_pres_gtissue_limit_GF_low_below_surface / 0.29985; 					// = ... / 99.95 / 0.003;
 			int_temp = (int) (next_stop + 0.99);
			if (int_temp > 31)
				int_temp = 31;						//	deepest deco at 93 meter (31 deco stops)
			if (int_temp < 0)
				int_temp = 0;
			temp_depth_GF_low_number = int_temp;
 			temp_depth_GF_low_meter = 3 * temp_depth_GF_low_number;
			next_stop = (float)temp_depth_GF_low_meter * 0.09995;
			temp_pres_deco_GF_low = next_stop + float_deco_distance + pres_surface;
			if (temp_depth_GF_low_number == 0)
				GF_step = 0;
			else
				GF_step = GF_delta / (float)temp_depth_GF_low_number;
			if (GF_step < 0)
				GF_step = 0;
			if (GF_step > GF_delta)
				GF_step = GF_delta;
			int_O_GF_step = (int)(GF_step * 10000);
			int_O_limit_GF_low = (int)(temp_pres_deco_GF_low * 1000);
			int_O_gtissue_press_at_GF_low = (int)(temp_pres_gtissue * 1000);
			char_O_GF_low_pointer = temp_depth_GF_low_number;
			lock_GF_depth_list = 1;
			internal_deco_pointer = 0;
		}
		if (internal_deco_pointer == 0)		// new run
		{
			internal_deco_pointer = temp_depth_GF_low_number;
			GF_temp = GF_high - ((float)internal_deco_pointer * GF_step);
			int_temp = char_I_table_deco_done[internal_deco_pointer];
		}
		else
		{
			int_temp = 1;
		}
		while (int_temp == 1)
		{
			int_temp = internal_deco_pointer - 1;
			if (int_temp == 1)								// new in v104
			{
				next_stop = (float)(temp_depth_last_deco * int_temp) * 0.09995;
				GF_step2 = GF_step/3.0 * ((float)(6 - temp_depth_last_deco));
			}
			else
			if (int_temp == 0)
			{
				next_stop = 0.0;
				GF_step2 = GF_high - GF_temp;
			}
			else
			{
				next_stop = (float)(3 *int_temp) * 0.09995;
				GF_step2 = GF_step;
			}
			next_stop = next_stop + pres_surface; // next deco stop to be tested
			press_tol = ((GF_temp + GF_step2)* temp_pres_gtissue_diff) + temp_pres_gtissue;	// upper limit (lowest pressure allowed) // changes GF_step2 in v104
			if (press_tol > next_stop) // check if ascent to next deco stop is ok
			{
				int_temp = 0;	// no
			}
			else
			{
				internal_deco_pointer = int_temp;
				GF_temp = GF_temp + GF_step2; // changed in v104
				int_temp = char_I_table_deco_done[internal_deco_pointer]; // yes and check for ascent to even next stop if deco_done is set
			}
		} // while

		if (internal_deco_pointer > 0)
		{
			next_stop = 0.29985 * internal_deco_pointer;
			temp_deco = next_stop + float_deco_distance + pres_surface;
			if (internal_deco_pointer == 1)						// new in v104
				temp_depth_limit = temp_depth_last_deco;
			else
				temp_depth_limit = 3 * internal_deco_pointer;
		}
		else	// 	if (char_I_deco_model == 1)
		{
			temp_deco = pres_surface;
			temp_depth_limit = 0;
		}
	}
	else //---- ZH-L16 model -------------------------------------------------
	{
		// calc_nextdecodepth - original
		// optimized in v.101
		// depth_last_deco included in v.101

		overlay float pres_gradient = temp_pres_gtissue_limit - pres_surface;
		if (pres_gradient >= 0)
 		{
 			pres_gradient = pres_gradient / 0.29985; 	        // = pres_gradient / 99.95 / 0.003;
 			temp_depth_limit = (int) (pres_gradient + 0.99);
 			temp_depth_limit = 3 * temp_depth_limit;            // depth for deco [m]
 			if (temp_depth_limit == 0)
  				temp_deco = pres_surface;
 			else
  			{
  				if (temp_depth_limit < temp_depth_last_deco)
					temp_depth_limit = temp_depth_last_deco;
  				pres_gradient = (float)temp_depth_limit * 0.09995;
  				temp_deco = pres_gradient + float_deco_distance + pres_surface;    // depth for deco [bar]
  			} // if (temp_depth_limit == 0)
 		} // if (pres_gradient >= 0)
		else
 		{
 			temp_deco = pres_surface;
 			temp_depth_limit = 0;
 		} // if (pres_gradient >= 0)
	} // calc_nextdecodepth original
}

//////////////////////////////////////////////////////////////////////////////
// copy_deco_table
//
// Buffer the stops, once computed, so we can continue to display them
// while computing the next set.
//
static void copy_deco_table(void)
{
    // Copy depth of the first (deepest) stop, because when reversing
    // order, it will be hard to find...    
    char_O_first_deco_depth = internal_deco_depth[0];
    char_O_first_deco_time  = internal_deco_time [0];

    if( read_custom_function(54) & 1 ) //---- Should we reverse table ? ------
    {
        overlay unsigned char x, y;

        //---- First: search the first non-null depth
        for(x=31; x != 0; --x)
            if( internal_deco_depth[x] != 0 ) break;

        //---- Second: copy to output table (in reverse order)
        for(y=0; y<32; y++, --x)
        {
            char_O_deco_depth[y] = internal_deco_depth[x];
            char_O_deco_time [y] = internal_deco_time [x];

            // Stop only once the last transfer is done.
            if( x == 0 ) break;
        }

        //---- Third: fill table end with null
        for(y++; y<32; y++)
        {
            char_O_deco_time [y] = 0;
            char_O_deco_depth[y] = 0;
        }
    }
    else //---- Straight copy ------------------------------------------------
    {
        overlay unsigned char x;

        for(x=0; x<32; x++)
        {
            char_O_deco_depth[x] = internal_deco_depth[x];
            char_O_deco_time [x] = internal_deco_time [x];
        }
    }
}

//////////////////////////////////////////////////////////////////////////////
// temp_tissue_safety //
//
// outsourced in v.102
//
// Apply safety factors for brand ZH-L16 model.
//
static void temp_tissue_safety(void)
{
	if( char_I_deco_model == 0 )
	{
		if (temp_tissue < 0.0)
			temp_tissue *= float_desaturation_multiplier;
 		else
			temp_tissue *= float_saturation_multiplier;
	}
}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
// ** THE JUMP-IN CODE **
// ** for the asm code **
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

void fillDataStack(void)
{
    _asm
        LFSR    1,C_STACK
        MOVLW   0xCC
loop:   MOVWF   POSTINC1,0
        TSTFSZ  FSR1L,0
        BRA     loop

        LFSR    1,C_STACK
        LFSR    2,C_STACK
    _endasm
}

//////////////////////////////////////////////////////////////////////////////
// When calling C code from ASM context, the data stack pointer and
// frames should be reset. Bank3 is dedicated to the stack (see the
// .lkr script).
#ifdef __DEBUG
#   define RESET_C_STACK fillDataStack();
#else
#   define RESET_C_STACK    \
    _asm                    \
        LFSR    1, C_STACK  \
        LFSR    2, C_STACK  \
    _endasm
#endif

//////////////////////////////////////////////////////////////////////////////
// Called every 2 seconds during diving.
// update tissues every time.
// Every 6 seconds (or slower when TTS > 16):
//    - update deco table (char_O_deco_time/depth) with new values.
//    - update ascent time,
//    - set status to zero (so we can check there is new results).
//
void deco_calc_hauptroutine(void)
{
    RESET_C_STACK
    calc_hauptroutine();
    int_O_desaturation_time = 65535;
}

//////////////////////////////////////////////////////////////////////////////

void deco_calc_without_deco(void)
{
    RESET_C_STACK
    calc_without_deco();
    deco_calc_desaturation_time();
}

//////////////////////////////////////////////////////////////////////////////

void deco_clear_tissue(void)
{
    RESET_C_STACK
    clear_tissue();
    char_I_depth_last_deco	= 0;		// for compatibility with v.101pre_no_last_deco
}

//////////////////////////////////////////////////////////////////////////////

void deco_calc_wo_deco_step_1_min(void)
{
    RESET_C_STACK
    calc_wo_deco_step_1_min();
    char_O_deco_status = 3; // surface new in v.102 overwrites value of calc_wo_deco_step_1_min
    deco_calc_desaturation_time();
}

//////////////////////////////////////////////////////////////////////////////

void deco_debug(void)
{
    RESET_C_STACK
}

//////////////////////////////////////////////////////////////////////////////
// clear_tissue
//
// optimized in v.101 (var_N2_a)
//
// preload tissues with standard pressure for the given ambient pressure.
// Note: fixed N2_ratio for standard air.

static void clear_tissue(void)
{
	flag_in_divemode = 0;
	int_O_DBS_bitfield = 0;
	int_O_DBS2_bitfield = 0;
	int_O_DBG_pre_bitfield = 0;
	int_O_DBG_post_bitfield = 0;
	char_O_NDL_at_20mtr = 255;

    // Kludge: the 0.0002 of 0.7902 are missing with standard air.
    N2_ratio = 0.7902;
    pres_respiration = (float)int_I_pres_respiration / 1000.0;
    
    for(ci=0; ci<16; ci++)
    {
        // cycle through the 16 b"uhlmann tissues
        overlay float p = N2_ratio * (pres_respiration -  0.0627);
        pres_tissue[ci] = p;
        
        read_buhlmann_coeffifients(-1);

        p = (p - var_N2_a) * var_N2_b ;
        if( p < 0.0 )
            p = 0.0;
        pres_tissue_limit[ci] = p;

        // cycle through the 16 b"uhlmann tissues for Helium
        (pres_tissue+16)[ci] = 0.0;
    } // for 0 to 16

    clear_deco_table();
    char_O_deco_status = 0;
    char_O_nullzeit = 0;
    int_O_ascenttime = 0;
    char_O_gradient_factor = 0;
    char_O_relative_gradient_GF = 0;
}

//////////////////////////////////////////////////////////////////////////////
// calc_without_deco
//
// optimized in v.101 (float_..saturation_multiplier)
//
// Note: fixed N2_ratio for standard air.

static void calc_without_deco(void)
{
    N2_ratio = 0.7902; // Sum as stated in b"uhlmann
    pres_respiration = (float)int_I_pres_respiration / 1000.0; // assembler code uses different digit system
    pres_surface = (float)int_I_pres_surface / 1000.0;
    temp_atem = N2_ratio * (pres_respiration - 0.0627); // 0.0627 is the extra pressure in the body
    temp2_atem = 0.0;
    temp_surface = pres_surface; // the b"uhlmann formula using temp_surface does apply to the pressure without any inert ratio
    float_desaturation_multiplier = char_I_desaturation_multiplier / 100.0;
    float_saturation_multiplier = char_I_saturation_multiplier / 100.0;
    
    calc_tissue_2_secs();  // update the pressure in the 32 tissues in accordance with the new ambient pressure
    
    clear_deco_table();
    char_O_deco_status = 0;
    char_O_nullzeit = 0;
    int_O_ascenttime = 0;
    calc_gradient_factor();
}

//////////////////////////////////////////////////////////////////////////////
// calc_hauptroutine
//
// this is the major code in dive mode calculates:
// 		the tissues,
//		the bottom time,
//		and simulates the ascend with all deco stops.

static void calc_hauptroutine(void)
{
	calc_hauptroutine_data_input();

	if(!flag_in_divemode)
	{
		flag_in_divemode = 1;
		create_dbs_set_dbg_and_ndl20mtr();
	}
	else
		check_pre_dbg();

	calc_hauptroutine_update_tissues();
	calc_gradient_factor();

    // toggle between calculation for nullzeit (bottom time), 
    //                deco stops 
    //                and more deco stops (continue)
	switch( char_O_deco_status )
	{
    case 0: //---- bottom time -----------------------------------------------
    	update_startvalues();
    	calc_nullzeit();
    	check_ndl();
    	char_O_deco_status = 2; // calc ascent next time.
    	break;

    case 1: //---- Simulate stops --------------------------------------------
    	calc_hauptroutine_calc_deco();
    	break;

    case 3: //---- At surface: start a new dive ------------------------------
    	clear_deco_table();
    	copy_deco_table();
    	internal_deco_pointer = 0;
    	lock_GF_depth_list = 0;
    	update_startvalues();
    	calc_nextdecodepth_GF();
    	char_O_deco_status = 0; // Calc nullzeit next time.
    	break;

    case 2: //---- Simulate ascent to first stop -----------------------------
    	sim_ascent_to_first_stop();
    	char_O_deco_status = 1;     // Cacl stops next time.
    	break;
	}

	check_post_dbg();
}

//////////////////////////////////////////////////////////////////////////////
// calc_hauptroutine_data_input
//
// Reset all C-code dive parameters from their ASM-code values.
// Detect gas change condition.
//
void calc_hauptroutine_data_input(void)
{
    overlay int int_temp;
    
    pres_respiration    = int_I_pres_respiration / 1000.0;
    pres_surface        = int_I_pres_surface / 1000.0;
    N2_ratio            = char_I_N2_ratio / 100.0;
    He_ratio            = char_I_He_ratio / 100.0;
    deco_N2_ratio1      = char_I_deco_N2_ratio1 / 100.0;
    deco_He_ratio1      = char_I_deco_He_ratio1 / 100.0;
    deco_N2_ratio2      = char_I_deco_N2_ratio2 / 100.0;
    deco_He_ratio2      = char_I_deco_He_ratio2 / 100.0;
    deco_N2_ratio3      = char_I_deco_N2_ratio3 / 100.0;
    deco_He_ratio3      = char_I_deco_He_ratio3 / 100.0;
    deco_N2_ratio4      = char_I_deco_N2_ratio4 / 100.0;
    deco_He_ratio4      = char_I_deco_He_ratio4 / 100.0;
    deco_N2_ratio5      = char_I_deco_N2_ratio5 / 100.0;
    deco_He_ratio5      = char_I_deco_He_ratio5 / 100.0;
    float_deco_distance = char_I_deco_distance / 100.0;

    // ____________________________________________________
    //
    // _____________ G A S _ C H A N G E S ________________
    // ____________________________________________________
    
    int_temp = (int_I_pres_respiration - int_I_pres_surface) + MBAR_REACH_GASCHANGE_AUTO_CHANGE_OFF;
    
    deco_gas_change1 = 0;
    deco_gas_change2 = 0;
    deco_gas_change3 = 0;
    deco_gas_change4 = 0;
    deco_gas_change5 = 0;

    if(char_I_deco_gas_change1)
    {
        overlay int int_temp2 = ((int)char_I_deco_gas_change1) * 100;
        if(int_temp > int_temp2)
        {
        	deco_gas_change1 = (float)char_I_deco_gas_change1 / 9.995 + pres_surface;
        	deco_gas_change1 += float_deco_distance;
    	}
    }
    if(char_I_deco_gas_change2)
    {
        overlay int int_temp2 = ((int)char_I_deco_gas_change2) * 100;
        if(int_temp > int_temp2)
        {
        	deco_gas_change2 = (float)char_I_deco_gas_change2 / 9.995 + pres_surface;
        	deco_gas_change2 += float_deco_distance;
    	}
    }
    if(char_I_deco_gas_change3)
    {
        overlay int int_temp2 = ((int)char_I_deco_gas_change3) * 100;
        if(int_temp > int_temp2)
        {
        	deco_gas_change3 = (float)char_I_deco_gas_change3 / 9.995 + pres_surface;
        	deco_gas_change3 += float_deco_distance;
    	}
    }
    if(char_I_deco_gas_change4)
    {
        overlay int int_temp2 = ((int)char_I_deco_gas_change4) * 100;
        if(int_temp > int_temp2)
        {
        	deco_gas_change4 = (float)char_I_deco_gas_change4 / 9.995 + pres_surface;
        	deco_gas_change4 += float_deco_distance;
    	}
    }
    if(char_I_deco_gas_change5)
    {
        overlay int int_temp2 = ((int)char_I_deco_gas_change5) * 100;
        if(int_temp > int_temp2)
        {
        	deco_gas_change5 = (float)char_I_deco_gas_change5 / 9.995 + pres_surface;
        	deco_gas_change5 += float_deco_distance;
    	}
    }

    const_ppO2 = (float)char_I_const_ppO2 / 100.0;
    deco_ppO2_change = (float)char_I_deco_ppO2_change / 99.95 + pres_surface;
    deco_ppO2_change = deco_ppO2_change + float_deco_distance;
    deco_ppO2 = (float)char_I_deco_ppO2 / 100.0;
    float_desaturation_multiplier = char_I_desaturation_multiplier / 100.0;
    float_saturation_multiplier = char_I_saturation_multiplier / 100.0;
    GF_low = (float)char_I_GF_Low_percentage / 100.0;
    GF_high = (float)char_I_GF_High_percentage / 100.0;
    GF_delta = GF_high - GF_low;
    
    temp2 = (pres_respiration - pres_surface) / 0.29985;
    int_temp = (int)(temp2);
    if (int_temp < 0)
        int_temp = 0;
    if (int_temp > 255)
        int_temp = 255;
    char_O_actual_pointer = int_temp;
    
    temp_depth_last_deco = (int)char_I_depth_last_deco;
}

//////////////////////////////////////////////////////////////////////////////

void calc_hauptroutine_update_tissues(void)
{
	int_O_calc_tissue_call_counter = int_O_calc_tissue_call_counter + 1;
 	if (char_I_const_ppO2 == 0)													// new in v.101
  		pres_diluent = pres_respiration;										// new in v.101
 	else																		// new in v.101
  		pres_diluent = ((pres_respiration - const_ppO2)/(N2_ratio + He_ratio));	// new in v.101
 	if (pres_diluent > pres_respiration)										// new in v.101
  		pres_diluent = pres_respiration;										// new in v.101
 	if (pres_diluent > 0.0627)													// new in v.101
 	{
 		temp_atem = N2_ratio * (pres_diluent - 0.0627);							// changed in v.101
 		temp2_atem = He_ratio * (pres_diluent - 0.0627);						// changed in v.101
 		char_O_diluent = (char)(pres_diluent/pres_respiration*100.0);
 	}
 	else																		// new in v.101
 	{
 		temp_atem = 0.0;														// new in v.101
 		temp2_atem = 0.0;														// new in v.101
 		char_O_diluent = 0;
 	}
 	temp_surface = pres_surface;

 	if(!char_I_step_is_1min)
 		calc_tissue_2_secs();
 	else
 		calc_tissue_1_min();

 	int_O_gtissue_limit = (int)(pres_tissue_limit[char_O_gtissue_no] * 1000);
	int_O_gtissue_press = (int)((pres_tissue[char_O_gtissue_no] + pres_tissue[char_O_gtissue_no+16]) * 1000);
 	if (char_I_deco_model == 1)
 	{
		temp1 = temp1 * GF_high;
 	}
	else
	{
        temp1 = temp_surface;
	}
	if (pres_gtissue_limit > temp1 && char_O_deco_status == 0)  // if guiding tissue can not be exposed to surface pressure immediately
 	{
  		char_O_nullzeit = 0;    // deco necessary
  		char_O_deco_status = 2; // calculate ascent on next iteration.
 	}
} 		// calc_hauptroutine_update_tissues

//////////////////////////////////////////////////////////////////////////////
// Compute stops.
// 
// Note: because this can be very long, break on 16 iterations, and set state
//       to 0 when finished, or to 1 when needing to continue.
//
void calc_hauptroutine_calc_deco(void)
{
    overlay unsigned char loop;

 	for(loop = 0; loop < 16; ++loop)
  	{
  		calc_nextdecodepth_GF();

        //---- Finish computations once surface is reached -------------------
        if( temp_depth_limit <= 0 )
      	{
    		copy_deco_table();
        	calc_ascenttime();
    		char_O_deco_status = 0; // calc nullzeit next time.
    		return;
      	}

        //---- Else, continue simulating the stops ---------------------------
        calc_N2_ratio = N2_ratio;
        calc_He_ratio = He_ratio;
        
        if (char_I_const_ppO2 == 0)
        {
        	deco_diluent = temp_deco;

    		if(deco_gas_change1 && (temp_deco < deco_gas_change1))
    		{
        		calc_N2_ratio = deco_N2_ratio1;
        		calc_He_ratio = deco_He_ratio1;
        	}
    		if(deco_gas_change2 && (temp_deco < deco_gas_change2))
    		{
        		calc_N2_ratio = deco_N2_ratio2;
        		calc_He_ratio = deco_He_ratio2;
        	}
    		if(deco_gas_change3 && (temp_deco < deco_gas_change3))
    		{
        		calc_N2_ratio = deco_N2_ratio3;
        		calc_He_ratio = deco_He_ratio3;
        	}
    		if(deco_gas_change4 && (temp_deco < deco_gas_change4))
    		{
        		calc_N2_ratio = deco_N2_ratio4;
        		calc_He_ratio = deco_He_ratio4;
        	}
    		if(deco_gas_change5 && (temp_deco < deco_gas_change5))
    		{
        		calc_N2_ratio = deco_N2_ratio5;
        		calc_He_ratio = deco_He_ratio5;
        	}
        }
        else
       	{
       		if (temp_deco > deco_ppO2_change)
        	{
                deco_diluent = ((temp_deco - const_ppO2)/(N2_ratio + He_ratio));
        	}
       		else
        	{
                deco_diluent = ((temp_deco - deco_ppO2)/(N2_ratio + He_ratio));
        	}
      	}

        if (deco_diluent > temp_deco)															// new in v.101
        	deco_diluent = temp_deco;																// new in v.101

        if (deco_diluent > 0.0627)																// new in v.101
        {
            temp_atem = calc_N2_ratio * (deco_diluent - 0.0627);										// changed in v.101
            temp2_atem = calc_He_ratio * (deco_diluent - 0.0627);										// changed in v.101
        }
        else																					// new in v.101
        {
            temp_atem = 0.0;																		// new in v.101
            temp2_atem = 0.0;																		// new in v.101
        }

        sim_tissue_1min();          // Simulate compartiments for 1 minute.
        update_deco_table();        // Add one minute stops.
	}

	// Surface not reached, need more stops...
    char_O_deco_status = 1; // calc more stops next time.
}

//////////////////////////////////////////////////////////////////////////////
// Simulation ascention to first deco stop.
//
// Note: because we ascent with a constant speed (10m/mn, ie. 1bar/mn),
//       there is no need to break on more that 16 iterations
//       (or we are already in deep shit).
//
void sim_ascent_to_first_stop(void)
{
 	update_startvalues();
    clear_deco_table();

   	temp_deco = pres_respiration;
 	lock_GF_depth_list = 1;

    // Loop until first top or surface is reached.
 	for(;;)
  	{
  		temp_deco = temp_deco - 1.0;    // Ascent 1 min, at 10m/min. == 1bar/min.

  		if ( char_I_deco_model == 1)
			temp_limit = temp_pres_gtissue_limit_GF_low;
  		else
			temp_limit = temp_pres_gtissue_limit;

        // Did we hit the first stop ?
        if( temp_deco <= temp_limit )
            break;
        
        // Or the surface ?
        if( temp_deco <= pres_surface )
            break;
        
		lock_GF_depth_list = 0;
 		temp_deco += 0.5;           // Check gas change 5 meter below new depth.

        //---- Simulat gas switches, at half the ascent
 		calc_N2_ratio = N2_ratio;
		calc_He_ratio = He_ratio;

		if (char_I_const_ppO2 == 0)
		{
			deco_diluent = temp_deco;

 				if(deco_gas_change1 && (temp_deco < deco_gas_change1))
	 			{
 				calc_N2_ratio = deco_N2_ratio1;
 				calc_He_ratio = deco_He_ratio1;
 			}
 				if(deco_gas_change2 && (temp_deco < deco_gas_change2))
	 			{
 				calc_N2_ratio = deco_N2_ratio2;
 				calc_He_ratio = deco_He_ratio2;
 			}
 				if(deco_gas_change3 && (temp_deco < deco_gas_change3))
	 			{
 				calc_N2_ratio = deco_N2_ratio3;
 				calc_He_ratio = deco_He_ratio3;
 			}
 				if(deco_gas_change4 && (temp_deco < deco_gas_change4))
	 			{
 				calc_N2_ratio = deco_N2_ratio4;
 				calc_He_ratio = deco_He_ratio4;
 			}
 				if(deco_gas_change5 && (temp_deco < deco_gas_change5))
	 			{
 				calc_N2_ratio = deco_N2_ratio5;
 				calc_He_ratio = deco_He_ratio5;
 			}
		}
		else
		{
			if( temp_deco > deco_ppO2_change )
					deco_diluent = (temp_deco - const_ppO2)/(N2_ratio + He_ratio);  // calculate at half of the ascent
			else
					deco_diluent = (temp_deco - deco_ppO2)/(N2_ratio + He_ratio);   // calculate at half of the ascent
			if( deco_diluent > temp_deco )
					deco_diluent = temp_deco;
		}
		
 		temp_deco -= 0.5;   // Back to new depth.

		if (deco_diluent > 0.0627)
		{
			temp_atem = calc_N2_ratio * (deco_diluent - 0.0627);
			temp2_atem = calc_He_ratio * (deco_diluent - 0.0627);
		}
		else
		{
			temp_atem = 0.0;
			temp2_atem = 0.0;
		}

        // Then simulate with the new gas pressures...s
		sim_tissue_1min();
	}
}

//////////////////////////////////////////////////////////////////////////////
// calc_tissue
//
// optimized in v.101
//
static void calc_tissue(static unsigned char period)
{
    char_O_gtissue_no = 255;
    pres_gtissue_limit = 0.0;
    
    for (ci=0;ci<16;ci++)
    {
        read_buhlmann_coeffifients(period);   // 2 sec or 1 min period.

        // N2
        temp_tissue = (temp_atem - pres_tissue[ci]) * var_N2_e;
        temp_tissue_safety();
        pres_tissue[ci] += temp_tissue;

        // He
        temp_tissue = (temp2_atem - (pres_tissue+16)[ci]) * var_He_e;
        temp_tissue_safety();
        (pres_tissue+16)[ci] += temp_tissue;

        temp_tissue = pres_tissue[ci] + (pres_tissue+16)[ci];

        var_N2_a = (var_N2_a * pres_tissue[ci] + var_He_a * (pres_tissue+16)[ci]) / temp_tissue;
        var_N2_b = (var_N2_b * pres_tissue[ci] + var_He_b * (pres_tissue+16)[ci]) / temp_tissue;
        pres_tissue_limit[ci] = (temp_tissue - var_N2_a) * var_N2_b;
        if (pres_tissue_limit[ci] < 0)
            pres_tissue_limit[ci] = 0;
        if (pres_tissue_limit[ci] > pres_gtissue_limit)
        {
            pres_gtissue_limit = pres_tissue_limit[ci];
            char_O_gtissue_no = ci;
        }//if
    } // for
}

//////////////////////////////////////////////////////////////////////////////
// calc_tissue_2_secs
//
// optimized in v.101
//
static void calc_tissue_2_secs(void)
{
    calc_tissue(0);
}

//////////////////////////////////////////////////////////////////////////////
// calc_tissue_1_min
//
// optimized in v.101
//
static void calc_tissue_1_min(void)
{
    calc_tissue(1);
}

//////////////////////////////////////////////////////////////////////////////
// calc_nullzeit
//
// calculates the remaining bottom time
//
// unchanged in v.101
//
static void calc_nullzeit(void)
{
    overlay int loop;
    
	char_O_nullzeit = 0;
	for(loop = 1; loop <= 17; loop++)
	{
  		backup_sim_pres_tissue();
  		sim_tissue_10min();
  		char_O_nullzeit += 10;

		if (char_I_deco_model == 1)
			temp1 = GF_high * temp_pres_gtissue_diff + temp_pres_gtissue;
		else
			temp1 = temp_pres_gtissue_limit;
		if (temp1 > temp_surface)  // changed in v.102 , if guiding tissue can not be exposed to surface pressure immediately
			loop = 255;
 	}

 	if (loop == 255)
 	{
  		restore_sim_pres_tissue();
  		char_O_nullzeit -= 10;
 	} //if loop == 255

 	if (char_O_nullzeit < 60)
 	{
     	for(loop=1; loop <= 10; loop++)
		{
   			sim_tissue_1min();
   			char_O_nullzeit = char_O_nullzeit + 1;
    		if (char_I_deco_model == 1)
    			temp1 = GF_high * temp_pres_gtissue_diff + temp_pres_gtissue;
    		else
    			temp1 = temp_pres_gtissue_limit;
    		if (temp1 > temp_surface)  // changed in v.102 , if guiding tissue can not be exposed to surface pressure immediately
    			loop = 255;
  		}
  		if (loop == 255)
   			char_O_nullzeit = char_O_nullzeit - 1;
 	} // if char_O_nullzeit < 60
} //calc_nullzeit

//////////////////////////////////////////////////////////////////////////////
// backup_sim_pres_tissue
//
void backup_sim_pres_tissue(void)
{
    overlay unsigned char x;

    for(x = 0; x<32; x++)
        sim_pres_tissue_backup[x] = sim_pres_tissue[x];
}

//////////////////////////////////////////////////////////////////////////////
// restore_sim_pres_tissue
//
void restore_sim_pres_tissue(void)
{
    overlay unsigned char x;

    for(x = 0; x<32; x++)
        sim_pres_tissue[x] = sim_pres_tissue_backup[x];
}

//////////////////////////////////////////////////////////////////////////////
// calc_ascenttime
//
static void calc_ascenttime(void)
{
    if (pres_respiration > pres_surface)
    {
        overlay unsigned char x;

        // + 0.6 to count 1 minute ascent time from 4 meter to surface
        overlay float ascent = pres_respiration - pres_surface + 0.6; 
        if (ascent < 0.0)
            ascent = 0.0;
        int_O_ascenttime = (unsigned int)ascent;

        for(x=0; x<32 && internal_deco_depth[x]; x++)
            int_O_ascenttime += (unsigned int)internal_deco_time[x];
    }
    else
        int_O_ascenttime = 0;
}

//////////////////////////////////////////////////////////////////////////////
// update_startvalues
//
// updated in v.102
//
void update_startvalues(void)
{
    overlay unsigned char x;
    
  	temp_pres_gtissue_limit = pres_gtissue_limit;
  	temp_pres_gtissue = pres_tissue[char_O_gtissue_no] + pres_tissue[char_O_gtissue_no+16];
  	temp_pres_gtissue_diff = temp_pres_gtissue_limit - temp_pres_gtissue;						// negative number
	temp_pres_gtissue_limit_GF_low = GF_low * temp_pres_gtissue_diff + temp_pres_gtissue;
  	temp_pres_gtissue_limit_GF_low_below_surface = temp_pres_gtissue_limit_GF_low - pres_surface;
	if (temp_pres_gtissue_limit_GF_low_below_surface < 0)
		temp_pres_gtissue_limit_GF_low_below_surface = 0;

	temp_gtissue_no = char_O_gtissue_no;
  	for (x = 0;x<16;x++)
  	{
   		sim_pres_tissue[x] = pres_tissue[x];
   		(sim_pres_tissue+16)[x] = (pres_tissue+16)[x];
   		sim_pres_tissue_limit[x] = pres_tissue_limit[x];
  	}
}

//////////////////////////////////////////////////////////////////////////////
// sim_tissue_1min
//
// optimized in v.101
//
// Function very simular to calc_tissue, but:
//   + Use a 1min or 10min period.
//   + Do it on sim_pres_tissue, instead of pres_tissue.
//   + Update GF_low state for GF decompression model.
//
static void sim_tissue(static unsigned char period)
{
    temp_pres_gtissue_limit = 0.0;
    temp_gtissue_no = 255;

    for (ci=0;ci<16;ci++)
    {
        read_buhlmann_coeffifients(period);  // 1 or 10 minute(s) interval

        // N2
        temp_tissue = (temp_atem - sim_pres_tissue[ci]) * var_N2_e;
        temp_tissue_safety();
        sim_pres_tissue[ci] += temp_tissue;
        
        // He
        temp_tissue = (temp2_atem - (sim_pres_tissue+16)[ci]) * var_He_e;
        temp_tissue_safety();
        (sim_pres_tissue+16)[ci] += temp_tissue;
        
        // pressure limit
        temp_tissue = sim_pres_tissue[ci] + (sim_pres_tissue+16)[ci];
        var_N2_a = (var_N2_a * sim_pres_tissue[ci] + var_He_a * (sim_pres_tissue+16)[ci]) / temp_tissue;
        var_N2_b = (var_N2_b * sim_pres_tissue[ci] + var_He_b * (sim_pres_tissue+16)[ci]) / temp_tissue;
        sim_pres_tissue_limit[ci] = (temp_tissue - var_N2_a) * var_N2_b;
        
        if (sim_pres_tissue_limit[ci] < 0)
            sim_pres_tissue_limit[ci] = 0;
        if (sim_pres_tissue_limit[ci] > temp_pres_gtissue_limit)
        {
            temp_pres_gtissue = temp_tissue;
            temp_pres_gtissue_limit = sim_pres_tissue_limit[ci];
            temp_gtissue_no = ci;
        }
    } // for

    temp_pres_gtissue_diff = temp_pres_gtissue_limit - temp_pres_gtissue;
    temp_pres_gtissue_limit_GF_low = GF_low * temp_pres_gtissue_diff + temp_pres_gtissue;
    temp_pres_gtissue_limit_GF_low_below_surface = temp_pres_gtissue_limit_GF_low - pres_surface;
    if (temp_pres_gtissue_limit_GF_low_below_surface < 0)
        temp_pres_gtissue_limit_GF_low_below_surface = 0;
}

//////////////////////////////////////////////////////////////////////////////
// sim_tissue_1min
//
static void sim_tissue_1min(void)
{
    sim_tissue(1);  // 1 minute period
}

//////////////////////////////////////////////////////////////////////////////
// sim_tissue_10min
//
static void sim_tissue_10min(void)
{
    sim_tissue(2);  // 10 minutes period
}
        
//////////////////////////////////////////////////////////////////////////////
// clear_deco_table
//
// unchanged in v.101
//
static void clear_deco_table(void)
{
    overlay unsigned char x;

    for(x=0; x<32; ++x)
    {
        internal_deco_time [x] = 0;
        internal_deco_depth[x] = 0;
    }
}

//////////////////////////////////////////////////////////////////////////////
// update_deco_table
//
// Add 1 min to current stop.
//
// Inputs:
//      temp_depth_limit = stop's depth, in meters.
// In/Out:
//      internal_deco_depth[] : depth (in meters) of each stops.
//      internal_deco_time [] : time (in minutes) of each stops.
//
static void update_deco_table()
{
	overlay unsigned char x;

	if( temp_depth_limit > 255 ) // Can't store stops at more than 255m.
	    temp_depth_limit = 255;

	for(x=0; x<32; ++x)
	{
    	// Did we found the right stop ?
    	if( internal_deco_depth[x] == temp_depth_limit )
    	{
        	// Increment stop time, but do test overflow:
        	overlay int stop_time = 1 + (int)internal_deco_time[x];
        	if( stop_time > 255 )
        	    stop_time = 255;
            internal_deco_time[x] = stop_time;
            
            // Done !
            return;
        }
        
        if( internal_deco_depth[x] == 0 )
        {
            // Found a free position: initialise it.
            internal_deco_depth[x] = (unsigned char)temp_depth_limit;
            internal_deco_time[x]  = 1;
            return;
        }
    }

    // Here, there is no space left for stops. 
    // Ie. the first one starts at 3m*32 positions = 96m...
    // Just do nothing with that...
}

//////////////////////////////////////////////////////////////////////////////
// calc_gradient_factor
//
// optimized in v.101 (var_N2_a)
// new code in v.102
//
static void calc_gradient_factor(void)
{
	// tissue > respiration (entsaettigungsvorgang)
	// gradient ist wieviel prozent an limit mit basis tissue
	// dh. 0% = respiration == tissue
	// dh. 100% = respiration == limit
	temp_tissue = pres_tissue[char_O_gtissue_no] + pres_tissue[char_O_gtissue_no+16];
	temp1 = temp_tissue - pres_respiration;
	temp2 = temp_tissue - pres_tissue_limit[char_O_gtissue_no];	// changed in v.102
	temp2 = temp1/temp2;
	temp2 = temp2 * 100; // displayed in percent
	if (temp2 < 0)
		temp2 = 0;
	if (temp2 > 255)
		temp2 = 255;
	if (temp1 < 0)
 		char_O_gradient_factor = 0;
	else
 		char_O_gradient_factor = (char)temp2;

	temp3 = temp2;

	if (char_I_deco_model == 1)		// calculate relative gradient factor
	{
		temp1 = (float)temp_depth_GF_low_meter * 0.09995;
		temp2 = pres_respiration - pres_surface;
		if (temp2 <= 0)
			temp1 = GF_high;
		else
		if (temp2 >= temp1)
			temp1 = GF_low;
		else
			temp1 = GF_low + (temp1 - temp2)/temp1*GF_delta;
		if (temp_depth_GF_low_meter == 0)
			temp1 = GF_high;
		temp2 = temp3 / temp1; // temp3 is already in percent
		if (temp2 < 0)
			temp2 = 0;
		if (temp2 > 255)
			temp2 = 255;
		char_O_relative_gradient_GF  = (char)temp2;
	}	// calc relative gradient factor
	else
	{
 			char_O_relative_gradient_GF = char_O_gradient_factor;
	}
}

//////////////////////////////////////////////////////////////////////////////
// deco_calc_desaturation_time
//
// FIXED N2_ratio
// unchanged in v.101
//
void deco_calc_desaturation_time(void)
{
    overlay int desat_time;     // For a particular compartiment, in min.

    RESET_C_STACK

    N2_ratio = 0.7902; // FIXED sum as stated in b"uhlmann
    pres_surface = (float)int_I_pres_surface / 1000.0;
    temp_atem = N2_ratio * (pres_surface - 0.0627);
    int_O_desaturation_time = 0;
    float_desaturation_multiplier = char_I_desaturation_multiplier / 142.0; // new in v.101	(70,42%/100.=142)
    
    for (ci=0;ci<16;ci++)
    {
        var_N2_halftime = buhlmann_ht[ci];
        var_He_halftime = (buhlmann_ht+16)[ci];

        // saturation_time (for flight) and N2_saturation in multiples of halftime
        // version v.100: 1.1 = 10 percent distance to totally clean (totally clean is not possible, would take infinite time )
        // new in version v.101: 1.07 = 7 percent distance to totally clean (totally clean is not possible, would take infinite time )
        // changes in v.101: 1.05 = 5 percent dist to totally clean is new desaturation point for display and noFly calculations
        // N2
        temp1 = 1.05 * temp_atem;
        temp1 = temp1 - pres_tissue[ci];
        temp2 = temp_atem - pres_tissue[ci];
        if (temp2 >= 0.0)
        {
            temp1 = 0;
            temp2 = 0;
        }
        else
            temp1 = temp1 / temp2;
         if (temp1 > 0.0)
        {
            temp1 = log(1.0 - temp1);
            temp1 = temp1 / -0.6931; // temp1 is the multiples of half times necessary.
            						 // 0.6931 is ln(2), because the math function log() calculates with a base of e not 2 as requested.
            						 // minus because log is negative
            temp2 = var_N2_halftime * temp1 / float_desaturation_multiplier; // time necessary (in minutes ) for complete desaturation (see comment about 10 percent) , new in v.101: float_desaturation_multiplier
        }
        else
        {
            temp1 = 0;
            temp2 = 0;
        }

        // He
        temp3 = 0.1 - (pres_tissue+16)[ci];
        if (temp3 >= 0.0)
        {
            temp3 = 0;
            temp4 = 0;
        }
        else
            temp3 = -1.0 * temp3 / (pres_tissue+16)[ci];
        if (temp3 > 0.0)
    	{
        	temp3 = log(1.0 - temp3);
        	temp3 = temp3 / -0.6931; // temp1 is the multiples of half times necessary.
        							 // 0.6931 is ln(2), because the math function log() calculates with a base of e  not 2 as requested.
        							 // minus because log is negative
        	temp4 = var_He_halftime * temp3 / float_desaturation_multiplier; // time necessary (in minutes ) for "complete" desaturation, new in v.101 float_desaturation_multiplier
    	}
        else
    	{
        	temp3 = 0;
        	temp4 = 0;
    	}

        // saturation_time (for flight)
        if (temp4 > temp2)
            desat_time = (int)temp4;
        else
            desat_time = (int)temp2;
         if(desat_time > int_O_desaturation_time)
        	int_O_desaturation_time = desat_time;

        // N2 saturation in multiples of halftime for display purposes
        temp2 = temp1 * 20.0;  // 0 = 1/8, 120 = 0, 249 = 8
        temp2 = temp2 + 80.0; // set center
        if (temp2 < 0.0)
            temp2 = 0.0;
        if (temp2 > 255.0)
            temp2 = 255.0;
        char_O_tissue_saturation[ci] = (char)temp2;
        // He saturation in multiples of halftime for display purposes
        temp4 = temp3 * 20.0;  // 0 = 1/8, 120 = 0, 249 = 8
        temp4 = temp4 + 80.0; // set center
        if (temp4 < 0.0)
            temp4 = 0.0;
        if (temp4 > 255.0)
            temp4 = 255.0;
        (char_O_tissue_saturation+16)[ci] = (char)temp4;
    } // for
}

//////////////////////////////////////////////////////////////////////////////
// calc_wo_deco_step_1_min
//
// FIXED N2 Ratio
// optimized in v.101 (...saturation_multiplier)
// desaturation slowed down to 70,42%
//
static void calc_wo_deco_step_1_min(void)
{
	if(flag_in_divemode)
	{
		flag_in_divemode = 0;
		set_dbg_end_of_dive();
	}

    N2_ratio = 0.7902; // FIXED, sum lt. buehlmann
    pres_respiration = (float)int_I_pres_respiration / 1000.0; // assembler code uses different digit system
    pres_surface = (float)int_I_pres_surface / 1000.0;
    temp_atem = N2_ratio * (pres_respiration - 0.0627); // 0.0627 is the extra pressure in the body
    temp2_atem = 0.0;
    temp_surface = pres_surface; // the b"uhlmann formula using temp_surface does not use the N2_ratio
    float_desaturation_multiplier = char_I_desaturation_multiplier / 142.0; // new in v.101	(70,42%/100.=142)
    float_saturation_multiplier = char_I_saturation_multiplier / 100.0;
    
    calc_tissue_1_min();  // update the pressure in the 32 tissues in accordance with the new ambient pressure
    
    clear_deco_table();
    char_O_deco_status = 0;
    char_O_nullzeit = 0;
    int_O_ascenttime = 0;
    calc_gradient_factor();
}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
////////////////////////////////// deco_hash /////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

void deco_hash(void)
{
    overlay unsigned char md_i, md_j;   // Loop index.
    overlay unsigned char md_t;
    overlay unsigned char md_buffer[16];
    overlay unsigned char md_temp;
    overlay unsigned int  md_pointer;

    RESET_C_STACK
    
    // init
    for(md_i=0;md_i<16;md_i++)
    {
         md_state[md_i] = 0;
         char_O_hash[md_i] = 0;
    } // for md_i 16

    _asm
        movlw	0x01            // md_pi address.
        movwf	TBLPTRU,0
        movlw	0x7E
        movwf	TBLPTRH,0
        movlw	0x00
        movwf	TBLPTRL,0
    _endasm;
    md_i = 0;
    do {
        _asm
        TBLRDPOSTINC
        movff	TABLAT,md_temp
        _endasm
        md_pi_subst[md_i++] = md_temp;
    } while( md_i != 0 );

    _asm
         movlw	0x00
         movwf	TBLPTRU,0
         movlw	0x00
         movwf	TBLPTRH,0
         movlw	0x00
         movwf	TBLPTRL,0
    _endasm

    // cycle buffers
    for (md_pointer=0x0000;md_pointer<0x17f3;md_pointer++)
    {
        md_t = 0;
        for (md_i=0;md_i<16;md_i++)
        {
            if(md_pointer == 9)
                md_temp = char_O_hash[md_i];
            else
            {
                _asm
                    TBLRDPOSTINC
                    movff	TABLAT,md_temp
                _endasm
            } // else

            md_buffer[md_i]   = md_temp;
            md_state[md_i+16] = md_buffer[md_i];
            md_state[md_i+32] = (unsigned char)(md_buffer[md_i] ^ md_state[md_i]);
        } // for md_i 16
            
        for (md_i=0;md_i<18;md_i++)
        {
            for (md_j=0;md_j<48;md_j++)
            {
                md_state[md_j] ^= md_pi_subst[md_t];
                md_t = md_state[md_j];
            } // for md_j 48
            md_t = (unsigned char)(md_t+1);
        } // for md_i 18
        md_t = char_O_hash[15];
            
        for (md_i=0;md_i<16;md_i++)
        {
            char_O_hash[md_i] ^= md_pi_subst[(md_buffer[md_i] ^ md_t)];
            md_t = char_O_hash[md_i];
        } // for md_i 16
    } // for md_pointer
} // void deco_hash(void)

//////////////////////////////////////////////////////////////////////////////
// deco_clear_CNS_fraction
//
// new in v.101
//
void deco_clear_CNS_fraction(void)
{
    RESET_C_STACK
    CNS_fraction = 0.0;
    char_O_CNS_fraction = 0;
}

//////////////////////////////////////////////////////////////////////////////
// deco_calc_CNS_fraction
//
// new in v.101
// optimized in v.102 : with new variables char_I_actual_ppO2 and actual_ppO2
//
// Input: char_I_actual_ppO2
// Output: char_O_CNS_fraction
// Uses and Updates: CNS_fraction
// Uses: acutal_ppO2
//
void deco_calc_CNS_fraction(void)
{
    overlay float actual_ppO2;
    RESET_C_STACK

    actual_ppO2 = (float)char_I_actual_ppO2 / 100.0;

    if (char_I_actual_ppO2 < 50)
        CNS_fraction = CNS_fraction;// no changes
    else if (char_I_actual_ppO2 < 60)
        CNS_fraction = 1/(-54000.0 * actual_ppO2 + 54000.0) + CNS_fraction;
    else if (char_I_actual_ppO2 < 70)
        CNS_fraction = 1/(-45000.0 * actual_ppO2 + 48600.0) + CNS_fraction;
    else if (char_I_actual_ppO2 < 80)
        CNS_fraction = 1/(-36000.0 * actual_ppO2 + 42300.0) + CNS_fraction;
    else if (char_I_actual_ppO2 < 90)
        CNS_fraction = 1/(-27000.0 * actual_ppO2 + 35100.0) + CNS_fraction;
    else if (char_I_actual_ppO2 < 110)
        CNS_fraction = 1/(-18000.0 * actual_ppO2 + 27000.0) + CNS_fraction;
    else if (char_I_actual_ppO2 < 150)
        CNS_fraction = 1/(-9000.0 * actual_ppO2 + 17100.0) + CNS_fraction;
    else if (char_I_actual_ppO2 < 160)
        CNS_fraction = 1/(-22500.0 * actual_ppO2 + 37350.0) + CNS_fraction;
    else if (char_I_actual_ppO2 < 165)
        CNS_fraction =  0.000755 + CNS_fraction; // Arieli et all.(2002): Modeling pulmonary and CNS O2 toxicity... Formula (A1) based on value for 1.55 and c=20
    else if (char_I_actual_ppO2 < 170)
        CNS_fraction =  0.00102 + CNS_fraction; // example calculation: Sqrt((1.7/1.55)^20)*0.000404
    else if (char_I_actual_ppO2 < 175)
        CNS_fraction =  0.00136 + CNS_fraction;
    else if (char_I_actual_ppO2 < 180)
        CNS_fraction =  0.00180 + CNS_fraction;
    else if (char_I_actual_ppO2 < 185)
        CNS_fraction =  0.00237 + CNS_fraction;
    else if (char_I_actual_ppO2 < 190)
        CNS_fraction =  0.00310 + CNS_fraction;
    else if (char_I_actual_ppO2 < 195)
        CNS_fraction =  0.00401 + CNS_fraction;
    else if (char_I_actual_ppO2 < 200)
        CNS_fraction =  0.00517 + CNS_fraction;
    else if (char_I_actual_ppO2 < 230)
        CNS_fraction =  0.0209 + CNS_fraction;
    else
        CNS_fraction =  0.0482 + CNS_fraction; // value for 2.5

    if (CNS_fraction > 2.5)
        CNS_fraction = 2.5;
    if (CNS_fraction < 0.0)
        CNS_fraction = 0.0;

    char_O_CNS_fraction = (char)((CNS_fraction + 0.005)* 100.0);
}

//////////////////////////////////////////////////////////////////////////////
// deco_calc_CNS_decrease_15min
//
// new in v.101
//
// calculates the half time of 90 minutes in 6 steps of 15 min
//
// Output: char_O_CNS_fraction
// Uses and Updates: CNS_fraction
//
void deco_calc_CNS_decrease_15min(void)
{
    RESET_C_STACK    
    CNS_fraction =  0.890899 * CNS_fraction;
    char_O_CNS_fraction = (char)(CNS_fraction * 100.0 + 0.5);
}

//////////////////////////////////////////////////////////////////////////////
// deco_calc_percentage
//
// new in v.101
//
// calculates int_I_temp * char_I_temp / 100
// output is int_I_temp

void deco_calc_percentage(void)
{
    RESET_C_STACK
    temp1 = (float)int_I_temp;
    temp2 = (float)char_I_temp / 100.0;
    temp3 = temp1 * temp2;
    int_I_temp = (int)temp3;
}

//////////////////////////////////////////////////////////////////////////////

void deco_push_tissues_to_vault(void)
{
    overlay unsigned char x;
    RESET_C_STACK

	cns_vault = CNS_fraction;
	for (x=0;x<32;x++)
		pres_tissue_vault[x] = pres_tissue[x];
}

void deco_pull_tissues_from_vault(void)
{
    overlay unsigned char x;
    RESET_C_STACK

	CNS_fraction = cns_vault;
	for (x=0;x<32;x++)
		pres_tissue[x] = pres_tissue_vault[x];
}

//////////////////////////////////////////////////////////////////////////////
//
void main() {}