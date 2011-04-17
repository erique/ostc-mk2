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
// 10/14/08	v104: integration of char_I_depth_last_deco for Gradient Model
// 03/31/09 v107: integration of FONT Incon24
// 05/23/10 v109: 5 gas changes & 1 min timer
// 07/13/10 v110: cns vault added
// 12/25/10 v110: split in three files (deco.c, main.c, definitions.h)
// 2011/01/20: [jDG] Create a common file included in ASM and C code.
// 2011/01/23: [jDG] Added read_custom_function().
// 2011/01/24: [jDG] Make ascenttime an short. No more overflow!
// 2011/01/25: [jDG] Fusion deco array for both models.
// 2011/01/25: [jDG] Use CF(54) to reverse deco order.
// 2011/02/11: [jDG] Reworked gradient-factor implementation.
// 2011/02/13: [jDG] CF55 for additional gas switch delay in decoplan.
// 2011/02/15: [jDG] Fixed inconsistencies introduced by gas switch delays.
// 2011/03/21: [jDG] Added gas consumption (CF56 & CF57) evaluation for OCR mode.
// 2011/04/10: [jDG] Use timer TMR3 to limit loops in calc_hauptroutine_calc_deco()
// 2011/04/15: [jDG] Store low_depth in 32bits (w/o rounding), for a better stability.
//
// TODO:
//  + Allow to abort MD2 calculation (have to restart next time).
//
// Literature:
// Bühlmann, Albert: Tauchmedizin; 4. Auflage [2002];
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

// ***********************************************
// ** V A R I A B L E S   D E F I N I T I O N S **
// ***********************************************

#include "p2_definitions.h"
#define TEST_MAIN
#include "shared_definitions.h"

// Water vapour partial pressure in the lumb.
#define ppWVapour 0.0627

// *************************
// ** P R O T O T Y P E S **
// *************************

static void calc_hauptroutine(void);
static void calc_nullzeit(void);

static void calc_tissue(PARAMETER unsigned char period);
static void calc_limit(void);

static void clear_tissue(void);
static void calc_ascenttime(void);
static void update_startvalues(void);
static void clear_deco_table(void);
static void update_deco_table(void);

static void backup_sim_pres_tissue(void);
static void restore_sim_pres_tissue(void);
static void sim_tissue(PARAMETER unsigned char period);
static void sim_limit(PARAMETER float GF_current);
static void calc_gradient_factor(void);
static void calc_wo_deco_step_1_min(void);

static void calc_hauptroutine_data_input(void);
static void calc_hauptroutine_update_tissues(void);
static void calc_hauptroutine_calc_deco(void);
static void sim_ascent_to_first_stop(void);

static unsigned char gas_switch_deepest(void);
static void gas_switch_set(void);

static unsigned char calc_nextdecodepth(void);

//---- Bank 4 parameters -----------------------------------------------------
#pragma udata bank4=0x400

static float			temp_limit;
static float			GF_low;
static float			GF_high;
static float			GF_delta;
static float            low_depth;                  // Depth of deepest stop
static float			locked_GF_step;             // GF_delta / low_depth

static unsigned char    temp_depth_limit;

// Simulation context: used to predict ascent.
static unsigned char	sim_lead_tissue_no;         // Leading compatiment number.
static float			sim_lead_tissue_limit;      // Buhlmann tolerated pressure.

// Real context: what we are doing now.
static float			calc_lead_tissue_limit;     // 

static unsigned char	internal_deco_time[32];
static unsigned char	internal_deco_depth[32];

static float cns_vault;
static float pres_tissue_vault[32];

//---- Bank 5 parameters -----------------------------------------------------
#pragma udata bank5=0x500

static unsigned char	ci;
static float 			pres_respiration;
static float			pres_surface;
static float			temp_deco;
static float			ppN2;
static float			ppHe;
static float			temp_tissue;
static float			N2_ratio;       // Breathed gas nitrogen ratio.
static float			He_ratio;       // Breathed gas helium ratio.
static float 			var_N2_a;       // Bühlmann a, for current N2 tissue.
static float 			var_N2_b;       // Bühlmann b, for current N2 tissue.
static float 			var_He_a;       // Bühlmann a, for current He tissue.
static float 			var_He_b;       // Bühlmann b, for current He tissue.
static float  			var_N2_e;       // Exposition, for current N2 tissue.
static float  			var_He_e;       // Exposition, for current He tissue.

static float            pres_diluent;               // new in v.101
static float            const_ppO2;                 // new in v.101
static float            deco_ppO2_change;           // new in v.101
static float            deco_ppO2;                  // new in v.101

static unsigned char    sim_gas_last_depth;             // Depth of last used gas, to detected a gas switch. 
static unsigned char    sim_gas_last_used;              // Number of last used gas, to detected a gas switch. 
static unsigned short   sim_gas_delay;                  // Time of gas-switch-stop ends [min on dive].
static unsigned short   sim_dive_mins;                  // Simulated dive time.
static float			calc_N2_ratio;                  // Simulated (switched) nitrogen ratio.
static float			calc_He_ratio;                  // Simulated (switched) helium ratio.
static float			CNS_fraction;			        // new in v.101
static float			float_saturation_multiplier;    // new in v.101
static float			float_desaturation_multiplier;  // new in v.101
static float			float_deco_distance;	// new in v.101
static char			    flag_in_divemode;		// new in v.108

static unsigned char    deco_gas_change[5];		// new in v.109

//---- Bank 6 parameters -----------------------------------------------------
#pragma udata bank6=0x600

float  pres_tissue[32];

//---- Bank 7 parameters -----------------------------------------------------
#pragma udata bank7=0x700

float  sim_pres_tissue[32];                 // 32 floats = 128 bytes.
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
static unsigned char	DBG_deco_gas_change;	// new in v.108
static unsigned char    DBG_deco_N2_ratio;		// new in v.108
static unsigned char	DBG_deco_He_ratio;		// new in v.108
static float			DBG_pres_surface;		// new in v.108
static float			DBG_GF_low;				// new in v.108
static float			DBG_GF_high;			// new in v.108
static float			DBG_const_ppO2;			// new in v.108
static float			DBG_deco_ppO2_change;	// new in v.108
static float			DBG_deco_ppO2;			// new in v.108
static float			DBG_float_saturation_multiplier;	// new in v.108
static float			DBG_float_desaturation_multiplier;	// new in v.108
static float			DBG_float_deco_distance;			// new in v.108
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
rom const rom unsigned short md_pi[] =
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
	DBG_deco_N2_ratio = char_I_deco_N2_ratio[0];
	DBG_deco_He_ratio = char_I_deco_He_ratio[0];
	DBG_deco_gas_change = deco_gas_change[0];
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
	if(DBG_deco_gas_change && ((char_I_deco_N2_ratio[0] + char_I_deco_He_ratio[0]) > 95))
		int_O_DBS_bitfield |= DBS_DECOO2l;
	if(DBG_deco_gas_change && ((char_I_deco_N2_ratio[0] + char_I_deco_He_ratio[0]) <  5))
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
			char_O_NDL_at_20mtr = 254;
	}
}

//////////////////////////////////////////////////////////////////////////////
// DBG - multi main during dive
//
static void check_dbg(PARAMETER char is_post_check)
{
	overlay unsigned short temp_DBS = 0;
    overlay unsigned char i;            // Local loop index.

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

	if( DBG_deco_gas_change != deco_gas_change[0]
	 || DBG_deco_N2_ratio != char_I_deco_N2_ratio[0]
	 || DBG_deco_He_ratio != char_I_deco_He_ratio[0] )
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

//////////////////////////////////////////////////////////////////////////////
// Bump to blue-screen when an assert is wrong
#ifdef __DEBUG
void assert_failed(PARAMETER short int line)
{
    extern void PLED_resetdebugger(void);
    extern unsigned short temp10;

    temp10 = line;          // Show source line number as stack depth.
    PLED_resetdebugger();
}
#endif

//////////////////////////////////////////////////////////////////////////////
// When calling C code from ASM context, the data stack pointer and
// frames should be reset. Bank8 is used by stack, when not doing hashing.

#ifdef CROSS_COMPILE
#       define RESET_C_STACK
#else
#   ifdef __DEBUG
#       define RESET_C_STACK fillDataStack();
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
#   else
#       define RESET_C_STACK    \
        _asm                    \
            LFSR    1, C_STACK  \
            LFSR    2, C_STACK  \
        _endasm
#   endif
#endif

//////////////////////////////////////////////////////////////////////////////
// Read CF values from the C code.

static short read_custom_function(PARAMETER unsigned char cf)
{
#ifdef CROSS_COMPILE
    extern unsigned short custom_functions[];
    return custom_functions[cf];
#else
    extern unsigned char hi, lo;
    extern void getcustom15();
    _asm
        movff   cf,WREG
        call    getcustom15,0
        movff   lo,PRODL
        movff   hi,PRODH
    _endasm
#endif
}

//////////////////////////////////////////////////////////////////////////////
// Fast subroutine to read RTC timer 3.
// Note: result is in 1/32 of msecs.
static unsigned short tmr3(void)
{
#ifndef CROSS_COMPILE
    _asm
        movff   0xfb2,PRODL     // TMR3L
        movff   0xfb3,PRODH     // TMR3H
    _endasm                     // result in PRODH:PRODL.
#else
    return 0;
#endif
}

//////////////////////////////////////////////////////////////////////////////
// read buhlmann tables A and B for compatriment ci
// 
static void read_buhlmann_coefficients(void)
{
#ifndef CROSS_COMPILE
    // Note: we don't use far rom pointer, because the
    //       24 bits is to complex, hence we have to set
    //       the UPPER page ourself...
    //       --> Set zero if tables are moved to lower pages !
    _asm
        movlw 1
        movwf TBLPTRU,0
    _endasm
#endif

    assert( 0 <= ci && ci < 16 );
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
}

//////////////////////////////////////////////////////////////////////////////
// read buhlmann tables for compatriment ci
// If period == 0 : 2sec interval
//              1 : 1 min interval
//              2 : 10 min interval.
static void read_buhlmann_times(PARAMETER char period)
{
#ifndef CROSS_COMPILE
    // Note: we don't use far rom pointer, because the
    //       24 bits is to complex, hence we have to set
    //       the UPPER page ourself...
    //       --> Set zero if tables are moved to lower pages !
    _asm
        movlw 1
        movwf TBLPTRU,0
    _endasm
#endif
    assert( 0 <= ci && ci < 16 );

    // Integration intervals.
    switch(period)
    {
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

    default:
            assert(0);  // Never go there...
    }
}

//////////////////////////////////////////////////////////////////////////////
// calc_next_decodepth_GF
//
// new in v.102
//
// INPUT, changing during dive:
//      low_depth
//
// INPUT, fixed during dive:
//      pres_surface
//      GF_delta
//      GF_high
//      GF_low
//      char_I_depth_last_deco
//      float_deco_distance
//
// RETURN TRUE iff a stop is needed.
//
// OUTPUT
//      locked_GF_step
//      temp_depth_limt
//      low_depth
//
static unsigned char calc_nextdecodepth(void)
{
    //--- Max ascent speed ---------------------------------------------------
    // Recompute leading gas limit, at current depth:
    overlay float depth = (temp_deco - pres_surface) / 0.09985;

    // At most, ascent 1 minute, at 10m/min == 10.0 m.
    overlay float min_depth = depth - 10.0;
    
    // Do we need to stop at current depth ?
    overlay unsigned char need_stop = 0;

    assert( depth >= -0.2 );        // Allow for 200mbar of weather change.

    //---- ZH-L16 + GRADIENT FACTOR model ------------------------------------
	if (char_I_deco_model == 1)
	{
        if( depth >= low_depth )
            sim_limit( GF_low );
        else
            sim_limit( GF_high - depth * locked_GF_step );

        // Stops are needed ?
        if( sim_lead_tissue_limit > pres_surface )
        {
            // Compute tolerated depth, for the leading tissue [metre]:
            overlay float depth_tol = (sim_lead_tissue_limit - pres_surface) / 0.09985;

            // Deepest stop, in multiples of 3 metres.
            overlay unsigned char first_stop = 3 * (short)(0.99999 + depth_tol * 0.33333 );
            assert( first_stop < 128 );

            // Is it a new deepest needed stop ? If yes this is the reference for
            // the varying gradient factor. So reset that:
            if( depth_tol > min_depth && depth_tol > low_depth )
            {
                // Store the deepest stop depth, as reference for GF_low.
                low_depth = depth_tol;
                locked_GF_step = GF_delta / low_depth;
            }

#if defined(__DEBUG) || defined(CROSS_COMPILE)
            {
                // Extra testing code to make sure the first_stop formula
                // and rounding provides correct depth:
                overlay float pres_stop =  first_stop * 0.09985            // Meters to bar
        	                  + pres_surface;

                // Keep GF_low until a first stop depth is found:
                if( first_stop >= low_depth )
                    sim_limit( GF_low );
                else
                    // current GF is GF_high - alpha (GF_high - GF_low)
                    // With alpha = currentDepth / maxDepth, hence in [0..1]
                    sim_limit( GF_high - first_stop * locked_GF_step );

                // upper limit (lowest pressure tolerated):
                assert( sim_lead_tissue_limit < pres_stop );
            }
#endif

            // Apply correction for the shallowest stop.
            if( first_stop == 3 )                           // new in v104
                first_stop = char_I_depth_last_deco;        // Use last 3m..6m instead.

            // Because gradient factor at first_stop might be bigger than at 
            // current depth, we might ascent a bit more.
            // Hence, check all stops until one is indeed higher than tolerated presure:
            while(first_stop > 0)
            {
                overlay unsigned char next_stop;            // Next index (0..30)
                overlay float pres_stop;                    // Next depth (0m..90m)

                // Check max speed, or reaching surface.
                if( first_stop <= min_depth )
                    break;

                // So, there is indeed a stop needed:
                need_stop = 1;

                if( first_stop <= char_I_depth_last_deco )  // new in v104
                    next_stop = 0;
                else if( first_stop == 6 )
                    next_stop = char_I_depth_last_deco;
                else
                    next_stop = first_stop - 3;             // Index of next (upper) stop.

        	    pres_stop =  next_stop * 0.09985            // Meters to bar
        	              + pres_surface;

                // Keep GF_low until a first stop depth is found:
                if( next_stop >= low_depth )
                    sim_limit( GF_low );
                else
                    // current GF is GF_high - alpha (GF_high - GF_low)
                    // With alpha = currentDepth / maxDepth, hence in [0..1]
                    sim_limit( GF_high - next_stop * locked_GF_step );

                // upper limit (lowest pressure tolerated):
                if( sim_lead_tissue_limit >= pres_stop )    // check if ascent to next deco stop is ok
                    break;
                
                // Else, validate that stop and loop...
                first_stop = next_stop;
            }

            // next stop is the last validated depth found, aka first_stop
            temp_depth_limit = first_stop;                  // Stop depth, in metre.
        }
        else
 			temp_depth_limit = 0;                           // stop depth, in metre.
	}
	else //---- ZH-L16 model -------------------------------------------------
	{
        overlay float pres_gradient;

		// Original model
		// optimized in v.101
		// char_I_depth_last_deco included in v.101

        // Compute sim_lead_tissue_limit too, but just once.
        sim_limit(1.0);

		pres_gradient = sim_lead_tissue_limit - pres_surface;
		if (pres_gradient >= 0)
 		{
 			pres_gradient /= 0.29955; 	                            // Bar --> stop number;
 			temp_depth_limit = 3 * (short) (pres_gradient + 0.99);  // --> metre : depth for deco
            need_stop = 1;                                          // Hit.

            // Implement last stop at 4m/5m/6m...
			if( temp_depth_limit == 3 )
				temp_depth_limit = char_I_depth_last_deco;
 		}
		else
 			temp_depth_limit = 0;
	}

    //---- Check gas change --------------------------------------------------
    need_stop |= gas_switch_deepest();  // Update temp_depth_limit if there is a change,

    return need_stop;
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
    assert( 0.0 <  float_desaturation_multiplier && float_desaturation_multiplier <= 1.0 );
    assert( 1.0 <= float_saturation_multiplier   && float_saturation_multiplier   <= 2.0 );

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

//////////////////////////////////////////////////////////////////////////////
// Called every 2 seconds during diving.
// update tissues every time.
//
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
// Reset decompression model:
// + Set all tissues to equilibrium with Air at ambient pressure.
// + Reset last stop to 0m
// + Reset all model output.
void deco_clear_tissue(void)
{
    RESET_C_STACK
    clear_tissue();
}

//////////////////////////////////////////////////////////////////////////////

void deco_calc_wo_deco_step_1_min(void)
{
    RESET_C_STACK
    calc_wo_deco_step_1_min();
    deco_calc_desaturation_time();
}

//////////////////////////////////////////////////////////////////////////////

void deco_debug(void)
{
    RESET_C_STACK
}


//////////////////////////////////////////////////////////////////////////////
// Find current gas in the list (if any).
// 
// Input:  char_I_deco_N2_ratio[] and He, to detect breathed gas.
//
// Output: sim_gas_depth_used
//
static void gas_switch_find_current(void)
{
    overlay unsigned char j;
    overlay unsigned char N2 = (unsigned char)(N2_ratio * 100 + 0.5);
    overlay unsigned char He = (unsigned char)(He_ratio * 100 + 0.5);

    for(j=0; j<5; ++j)
    {
        // Make sure to detect if we are already breathing some gas in
        // the current list (happends when first gas do have a depth).
        if( N2 == char_I_deco_N2_ratio[j] 
         && He == char_I_deco_He_ratio[j] 
        )                                 
        {                                 
            temp_depth_limit = sim_gas_last_depth = char_I_deco_gas_change[j];
            sim_gas_last_used  = j+1;
            break;
        }
    }

    // If there is no gas-switch-delay running ?
    if( sim_gas_delay <= sim_dive_mins)
    {
        // Compute current depth:
        overlay unsigned char depth = (unsigned char)((pres_respiration - pres_surface) / 0.09985);
        assert( depth < 130 );

        // And if I'm above the last decostop (with the 3m margin) ?
        if( (sim_gas_last_depth-3) > depth )
        {
            for(j=0; j<5; ++j)
            {
                // And If I am in the range of a valide stop ?
                // (again, with the same 3m margin)
                if( char_I_deco_gas_change[j]
                 && depth <= char_I_deco_gas_change[j]
                 && depth >= (char_I_deco_gas_change[j] - 3)
                )
                {
                    // Then start gas-switch timer there,
                    sim_gas_delay = sim_dive_mins 
                                  + read_custom_function(55);

                    // And make sure decostop will be recorded at the right depth.
                    temp_depth_limit = char_I_deco_gas_change[j];
                    break;
                }
            }
        }
        else
            // Make clear there is no deay anymore.
            sim_gas_delay = 0;
    }
}

//////////////////////////////////////////////////////////////////////////////
// Find deepest available gas.
// 
// Input:  temp_depth_limit,
//         deco_gas_change[]
//         sim_gas_delay, sim_gas_depth_used, sim_dive_mins.
//
// RETURNS TRUE if a stop is needed for gas switch.
//
// Output: temp_depth_limit, sim_gas_delay, sim_gas_depth_used IFF the is a switch.
//
// NOTE: might be called from bottom (when sim_gas_delay and sim_gas_depth_used
//       are null), or during the ascent to make sure we are not passing a
//       stop (in which case both can be already set).
//
static unsigned char gas_switch_deepest(void)
{
    overlay unsigned char switch_deco = 0, switch_last = 0;

    if (char_I_const_ppO2 == 0)
    {
        overlay unsigned char j;

        // Loop over all enabled gas, to find the deepest one,
        // above las gas, but below temp_depth_limit.
        for(j=0; j<5; ++j)
        {
            // Gas not (yet) allowed ? Skip !
            if( temp_depth_limit > deco_gas_change[j] )
                continue;

            // Gas deeper than the current/previous one ? Skip !
            if( sim_gas_last_depth && deco_gas_change[j] >= sim_gas_last_depth )
                continue;

            // First, or deeper ?
            if( switch_deco < deco_gas_change[j] )
            {
                switch_deco = deco_gas_change[j];
                switch_last = j+1;
            }
        }
    }

    // If there is a better gas available
    if( switch_deco )
    {
        assert( !sim_gas_last_depth || sim_gas_last_depth > switch_deco );

        // Should restart gas-switch delay only when gas do changes...
        assert( sim_gas_delay <= sim_dive_mins );

        sim_gas_last_depth = switch_deco;
        sim_gas_last_used  = switch_last;
        sim_gas_delay = read_custom_function(55);

        // Apply depth correction ONLY if CF#55 is not null:
        if( sim_gas_delay > 0 )
        {
            sim_gas_delay += sim_dive_mins;
            temp_depth_limit = switch_deco;
            return 1;
        }
        
        return 0;
    }

    sim_gas_delay = 0;
    return 0;
}

//////////////////////////////////////////////////////////////////////////////
// Calculate gas switches
// 
//
// Input:  N2_ratio, He_ratio.
//         sim_gas_last_used
//
// Output: calc_N2_ratio, calc_He_ratio
//
static void gas_switch_set(void)
{
    assert( 0 <= sim_gas_last_used && sim_gas_last_used <= 5 );

    if( sim_gas_last_used == 0 )
    {
        calc_N2_ratio = N2_ratio;
	    calc_He_ratio = He_ratio;
    }
    else
    {
        calc_N2_ratio = char_I_deco_N2_ratio[sim_gas_last_used-1] * 0.01;
	    calc_He_ratio = char_I_deco_He_ratio[sim_gas_last_used-1] * 0.01;
    }

    assert( 0.0 <= calc_N2_ratio && calc_N2_ratio <= 0.95 );
    assert( 0.0 <= calc_He_ratio && calc_He_ratio <= 0.95 );
    assert( (calc_N2_ratio + calc_He_ratio) <= 1.00 );
}

//////////////////////////////////////////////////////////////////////////////
//
// Input: calc_N2_ratio, calc_He_ratio : simulated gas mix.
//        temp_deco : simulated respiration pressure + security offset (deco_distance)
//        Water-vapor pressure inside lumbs (ppWVapour).
//
// Output: ppN2, ppHe.
//
static void sim_alveolar_presures(void)
{
    overlay float deco_diluent = temp_deco;                 // new in v.101

    //---- CCR mode : deco gas switch ? --------------------------------------
    if (char_I_const_ppO2 != 0)
   	{
        // In CCR mode, calc_XX_ratio == XX_ratio.
   		if( temp_deco > deco_ppO2_change )
            deco_diluent = ((temp_deco - const_ppO2)/(calc_N2_ratio + calc_He_ratio));
   		else
            deco_diluent = ((temp_deco - deco_ppO2)/(calc_N2_ratio + calc_He_ratio));

        if (deco_diluent > temp_deco)
    	    deco_diluent = temp_deco;
  	}

    // Take deco offset into account, but not at surface.
    if( deco_diluent > pres_surface )
        deco_diluent += float_deco_distance;

    if( deco_diluent > ppWVapour )
    {
        ppN2 = calc_N2_ratio * (deco_diluent - ppWVapour);
        ppHe = calc_He_ratio * (deco_diluent - ppWVapour);
    }
    else
    {
        ppN2 = 0.0;
        ppHe = 0.0;
    }
    assert( 0.0 <= ppN2 && ppN2 < 14.0 );
    assert( 0.0 <= ppHe && ppHe < 14.0 );
}

//////////////////////////////////////////////////////////////////////////////
// clear_tissue
//
// optimized in v.101 (var_N2_a)
//
// preload tissues with standard pressure for the given ambient pressure.
// Note: fixed N2_ratio for standard air.
//
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
    pres_respiration = int_I_pres_respiration * 0.001;
    
    for(ci=0; ci<16; ci++)
    {
        // cycle through the 16 Bühlmann tissues
        overlay float p = N2_ratio * (pres_respiration -  ppWVapour);
        pres_tissue[ci] = p;

        // cycle through the 16 Bühlmann tissues for Helium
        (pres_tissue+16)[ci] = 0.0;
    } // for 0 to 16

    clear_deco_table();
    char_O_deco_status = 0;
    char_O_nullzeit = 0;
    int_O_ascenttime = 0;
    char_O_gradient_factor = 0;
    char_O_relative_gradient_GF = 0;
    char_I_depth_last_deco = 0;		// for compatibility with v.101pre_no_last_deco

    calc_lead_tissue_limit = 0.0;
    char_O_gtissue_no = 0;
}

//////////////////////////////////////////////////////////////////////////////
// calc_hauptroutine
//
// this is the major code in dive mode calculates:
// 		the tissues,
//		the bottom time,
//		and simulates the ascend with all deco stops.
//
// The deco_state sequence is :
//       3 (at surface)
// +---> 0 : calc nullzeit
// |     2 : simulate ascent to first stop (at 10m/min, less that 16x 1min simu)
// | +-> 1 : simulate up to 16min of stops.
// | +------< not finished
// +--------< finish
//
static void calc_hauptroutine(void)
{
	static unsigned char backup_gas_used  = 0;
	static unsigned char backup_gas_depth = 0;
	static unsigned char backup_gas_delay = 0;

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
    case 3: //---- At surface: start a new dive ------------------------------
    	clear_deco_table();
    	copy_deco_table();
    	int_O_ascenttime = 0;       // Reset DTR.
    	char_O_nullzeit = 0;        // Reset bottom time.
      	char_O_deco_status = 0;     // Calc bottom-time/nullzeit next iteration.

        // Values that should be reset just once for the full real dive.
        // This is used to record the lowest stop for the whole dive,
        // Including ACCROSS all simulated ascent.
        low_depth = 0;

        // Reset gas switch history.
        backup_gas_used  = sim_gas_last_used  = 0;
        backup_gas_depth = sim_gas_last_depth = 0;
        backup_gas_delay = sim_gas_delay = 0;
        sim_dive_mins = 0;
        break;

    case 0: //---- bottom time -----------------------------------------------
    	calc_nullzeit();
    	check_ndl();
   	    char_O_deco_status = 2; // calc ascent next time.
    	break;

    case 2: //---- Simulate ascent to first stop -----------------------------
        // Check proposed gas at begin of ascent simulation
        sim_dive_mins = int_I_divemins;         // Init current time.

        gas_switch_find_current();              // Lookup for current gas & time.
        gas_switch_set();                       // setup calc_ratio's

        backup_gas_used  = sim_gas_last_used;   // And save for later simu steps.
        backup_gas_depth = sim_gas_last_depth;  // And save for later simu steps.
        backup_gas_delay = sim_gas_delay;

    	sim_ascent_to_first_stop();

        char_O_deco_status = 1;     // Calc stops next time (deco or gas switch).
    	break;

    case 1: //---- Simulate stops --------------------------------------------
    	calc_hauptroutine_calc_deco();

        // If simulation is finished, restore the GF low reference, so that
        // next ascent simulation is done from the current depth:
    	if( char_O_deco_status == 0 )
    	{
            sim_gas_last_used  = backup_gas_used;
            sim_gas_last_depth = backup_gas_depth;
            sim_gas_delay      = backup_gas_delay;
        }
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
    overlay short int_temp;
    
    pres_respiration    = int_I_pres_respiration * 0.001;
    pres_surface        = int_I_pres_surface     * 0.001;
    N2_ratio            = char_I_N2_ratio        * 0.01;
    He_ratio            = char_I_He_ratio        * 0.01;
    float_deco_distance = char_I_deco_distance   * 0.01;     // Get offset is in mbar.

    // ____________________________________________________
    //
    // _____________ G A S _ C H A N G E S ________________
    // ____________________________________________________
    
    // Keep a margin of 150mbar = 1.50m
    int_temp = (int_I_pres_respiration - int_I_pres_surface)
             + MBAR_REACH_GASCHANGE_AUTO_CHANGE_OFF;
    
    deco_gas_change[0] = 0;
    deco_gas_change[1] = 0;
    deco_gas_change[2] = 0;
    deco_gas_change[3] = 0;
    deco_gas_change[4] = 0;

    // Gas are selectable if we did not pass the change depth by more than 1.50m:
    if(char_I_deco_gas_change[0])
    {
        if( int_temp > 100 *(short)char_I_deco_gas_change[0] )
        	deco_gas_change[0] = char_I_deco_gas_change[0];
    }
    if(char_I_deco_gas_change[1])
    {
        if( int_temp > 100 *(short)char_I_deco_gas_change[1] )
        	deco_gas_change[1] = char_I_deco_gas_change[1];
    }
    if(char_I_deco_gas_change[2])
    {
        if( int_temp > 100 *(short)char_I_deco_gas_change[2] )
        	deco_gas_change[2] = char_I_deco_gas_change[2];
    }
    if(char_I_deco_gas_change[3])
    {
        if( int_temp > 100 *(short)char_I_deco_gas_change[3] )
        	deco_gas_change[3] = char_I_deco_gas_change[3];
    }
    if(char_I_deco_gas_change[4])
    {
        if( int_temp > 100 *(short)char_I_deco_gas_change[4] )
        	deco_gas_change[4] = char_I_deco_gas_change[4];
    }

    const_ppO2 = char_I_const_ppO2 * 0.01;
    deco_ppO2_change = char_I_deco_ppO2_change / 99.95 
                     + pres_surface
                     + float_deco_distance;
    deco_ppO2 = char_I_deco_ppO2 * 0.01;
    float_desaturation_multiplier = char_I_desaturation_multiplier * 0.01;
    float_saturation_multiplier   = char_I_saturation_multiplier   * 0.01;
    GF_low   = char_I_GF_Low_percentage  * 0.01;
    GF_high  = char_I_GF_High_percentage * 0.01;
    GF_delta = GF_high - GF_low;
}

//////////////////////////////////////////////////////////////////////////////
//
//
void calc_hauptroutine_update_tissues(void)
{
    assert( 0.00 <= N2_ratio && N2_ratio <= 1.00 );
    assert( 0.00 <= He_ratio && He_ratio <= 1.00 );
    assert( (N2_ratio + He_ratio) <= 0.95 );
    assert( 0.800 < pres_respiration && pres_respiration < 14.0 );

    if (char_I_const_ppO2 == 0)													// new in v.101
  		pres_diluent = pres_respiration;										// new in v.101
 	else
    {
  		pres_diluent = ((pres_respiration - const_ppO2)/(N2_ratio + He_ratio));	// new in v.101
 	    if (pres_diluent > pres_respiration)									// new in v.101
  		    pres_diluent = pres_respiration;								    // new in v.101
    }
 	if (pres_diluent > ppWVapour)                                               // new in v.101
 	{
 		ppN2 = N2_ratio * (pres_diluent - ppWVapour);                           // changed in v.101
 		ppHe = He_ratio * (pres_diluent - ppWVapour);                           // changed in v.101
 		char_O_diluent = (char)(pres_diluent/pres_respiration*100.0);
 	}
 	else																		// new in v.101
 	{
 		ppN2 = 0.0;                                                             // new in v.101
 		ppHe = 0.0;                                                             // new in v.101
 		char_O_diluent = 0;
 	}

 	if(!char_I_step_is_1min)
 		calc_tissue(0);
 	else
 		calc_tissue(1);

    // Calc limit for surface, ie. GF_high.
    calc_limit();

 	int_O_gtissue_limit = (short)(calc_lead_tissue_limit * 1000);
	int_O_gtissue_press = (short)((pres_tissue[char_O_gtissue_no] + (pres_tissue+16)[char_O_gtissue_no]) * 1000);

    // if guiding tissue can not be exposed to surface pressure immediately
    if( calc_lead_tissue_limit > pres_surface && char_O_deco_status == 0)  
 	{
  		char_O_nullzeit = 0;    // deco necessary
  		char_O_deco_status = 2; // calculate ascent on next iteration.
 	}
}


//////////////////////////////////////////////////////////////////////////////
// Compute stops.
// 
// Note: because this can be very long, break on 16 iterations, and set state
//       to 0 when finished, or to 1 when needing to continue.
// Note: because this might be very long (~ 66 ms by iteration in 1.84beta),
//       break the loop when total time > 512msec.
//
void calc_hauptroutine_calc_deco(void)
{
    overlay unsigned char loop;

 	for(loop = 0; loop < 16; ++loop)
  	{
      	// Limit loops to 512ms, using the RTC timer 3:
      	if( tmr3() & (512*32) )
      	    break;
          	
        // Do not ascent while doing a gas switch ?
        if( sim_gas_delay <= sim_dive_mins )
        {
            if( calc_nextdecodepth() )
            {
                if( temp_depth_limit == 0 )
                    goto Surface;

                //---- We hit a stop at temp_depth_limit ---------------------
                temp_deco = temp_depth_limit * 0.09985      // Convert to relative bar,
	                      + pres_surface;                   // To absolute.
                update_deco_table();                        // Adds a one minute stops.
            }
            else
            {
                //---- No stop -----------------------------------------------
                temp_deco -= 0.9985;                        // Ascend 10m, no wait.

                //---- Finish computations once surface is reached -----------
                if( temp_deco <= pres_surface )
                {
Surface:
    		        copy_deco_table();
        	        calc_ascenttime();
    		        char_O_deco_status = 0; // calc nullzeit next time.
    		        return;
                }
            }
        }
        else
            update_deco_table();    // Just pass one minute.

        //---- Then update tissue --------------------------------------------
        sim_dive_mins++;            // Advance simulated time by 1 minute.
        gas_switch_set();           // Apply any simulated gas change, once validated.
        sim_alveolar_presures();    // Updates ppN2 and ppHe. 
        sim_tissue(1);              // Simulate compartiments for 1 minute.
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

   	temp_deco = pres_respiration;       // Starts from current real depth.

    // Do we have a gas switch going on ?
    if( sim_gas_delay > sim_dive_mins )
        return;

    //---- Loop until first stop, gas switch, or surface is reached ----------
 	for(;;)
  	{
        // Try ascending 1 full minute.
	    temp_deco -= 0.9985;        // 1 min, at 10m/min. ~ 1bar.

        // Compute sim_lead_tissue_limit at GF_low (deepest stop).
        sim_limit(GF_low);

        // Did we reach deepest remaining stop ?
        if( temp_deco < sim_lead_tissue_limit )
        {
            temp_deco += 0.9985;        // Restore last correct depth,
            break;                      // End fast ascent.
        }

        // Did we reach surface ?
        if( temp_deco <= pres_surface )
        {
            temp_deco = pres_surface;   // Yes: finished !
            break;
        }

        // Check for gas change below new depth ?
        temp_depth_limit = (temp_deco - pres_surface) / 0.09985;

        if( gas_switch_deepest() )
        {
            temp_deco = temp_depth_limit * 0.09985 + pres_surface;
            break;
        }

        sim_dive_mins++;                // Advance simulated time by 1 minute.
        sim_alveolar_presures();        // temp_deco --> ppN2/ppHe
		sim_tissue(1);                  // and update tissues for 1 min.
	}
}

//////////////////////////////////////////////////////////////////////////////
// calc_tissue
//
// optimized in v.101
//
static void calc_tissue(PARAMETER unsigned char period)
{
    assert( 0.00 <= ppN2 && ppN2 < 11.2 );  // 80% N2 at 130m
    assert( 0.00 <= ppHe && ppHe < 12.6 );  // 90% He at 130m

    for (ci=0;ci<16;ci++)
    {
        read_buhlmann_times(period);        // 2 sec or 1 min period.

        // N2
        temp_tissue = (ppN2 - pres_tissue[ci]) * var_N2_e;
        temp_tissue_safety();
        pres_tissue[ci] += temp_tissue;

        // He
        temp_tissue = (ppHe - (pres_tissue+16)[ci]) * var_He_e;
        temp_tissue_safety();
        (pres_tissue+16)[ci] += temp_tissue;
    }
}

//////////////////////////////////////////////////////////////////////////////
// calc_limit
//
// New in v.111 : separated from calc_tissue(), and depends on GF value.
//
static void calc_limit(void)
{
    char_O_gtissue_no = 255;
    calc_lead_tissue_limit = 0.0;

    for (ci=0;ci<16;ci++)
    {
        overlay float p = pres_tissue[ci] + (pres_tissue+16)[ci];

        read_buhlmann_coefficients();
        var_N2_a = (var_N2_a * pres_tissue[ci] + var_He_a * (pres_tissue+16)[ci]) / p;
        var_N2_b = (var_N2_b * pres_tissue[ci] + var_He_b * (pres_tissue+16)[ci]) / p;

        // Apply the Eric Baker's varying gradient factor correction.
        // Note: the correction factor depends both on GF and b,
        //       Actual values are in the 1.5 .. 1.0 range (for a GF=30%),
        //       so that can change who is the leading gas...
        // Note: Also depends of the GF. So the calcul is different for
        //       GF_low, current GF, or GF_high...
        //       *BUT* calc_tissue() is used to compute bottom time,
        //       hence what would happend at surface,
        //       hence at GF_high.
        if( char_I_deco_model == 1 )
            p = ( p - var_N2_a * GF_high) * var_N2_b
              / (GF_high + var_N2_b * (1.0 - GF_high));
        else
            p = (p - var_N2_a) * var_N2_b;
        if( p < 0.0 ) p = 0.0;

        if( p > calc_lead_tissue_limit )
        {
            char_O_gtissue_no = ci;
            calc_lead_tissue_limit = p;
        }
    }

    assert( char_O_gtissue_no < 16 );
    assert( 0.0 <= calc_lead_tissue_limit && calc_lead_tissue_limit <= 14.0);
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
    overlay unsigned char loop;
    update_startvalues();
    
	char_O_nullzeit = 0;
	for(loop = 1; loop <= 17; loop++)
	{
  		backup_sim_pres_tissue();
  		sim_tissue(2);      // 10 min.
        sim_limit(GF_high);

		if( sim_lead_tissue_limit > pres_surface )  // changed in v.102 , if guiding tissue can not be exposed to surface pressure immediately
        {
  		    restore_sim_pres_tissue();
            break;
        }
        // Validate once we know its good.
  		char_O_nullzeit += 10;
 	}

 	if (char_O_nullzeit < 60)
 	{
     	for(loop=1; loop <= 10; loop++)
		{
   			sim_tissue(1);  // 1 min
            sim_limit(GF_high);

    		if( sim_lead_tissue_limit > pres_surface)  // changed in v.102 , if guiding tissue can not be exposed to surface pressure immediately
                break;
   			char_O_nullzeit++;
  		}
 	}
}

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

        // + 0.7 to count 1 minute ascent time from 3 metre to surface
        overlay float ascent = pres_respiration - pres_surface + 0.7; 
        if (ascent < 0.0)
            ascent = 0.0;
        int_O_ascenttime = (unsigned short)(ascent + 0.99);

        for(x=0; x<32 && internal_deco_depth[x]; x++)
            int_O_ascenttime += (unsigned short)internal_deco_time[x];
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

    // Start ascent simulation with current tissue partial pressures.
  	for (x = 0;x<16;x++)
  	{
   		sim_pres_tissue[x] = pres_tissue[x];
   		(sim_pres_tissue+16)[x] = (pres_tissue+16)[x];
  	}

    // No leading tissue (yet) for this ascent simulation.
    sim_lead_tissue_limit = 0.0;
    sim_lead_tissue_no = 255;
}

//////////////////////////////////////////////////////////////////////////////
// sim_tissue
//
// optimized in v.101
//
// Function very simular to calc_tissue, but:
//   + Use a 1min or 10min period.
//   + Do it on sim_pres_tissue, instead of pres_tissue.
static void sim_tissue(PARAMETER unsigned char period)
{
    assert( 0.00 <= ppN2 && ppN2 < 11.2 );  // 80% N2 at 130m
    assert( 0.00 <= ppHe && ppHe < 12.6 );  // 90% He at 130m

    for(ci=0; ci<16; ci++)
    {
        read_buhlmann_times(period);        // 1 or 10 minute(s) interval

        // N2
        temp_tissue = (ppN2 - sim_pres_tissue[ci]) * var_N2_e;
        temp_tissue_safety();
        sim_pres_tissue[ci] += temp_tissue;
        
        // He
        temp_tissue = (ppHe - (sim_pres_tissue+16)[ci]) * var_He_e;
        temp_tissue_safety();
        (sim_pres_tissue+16)[ci] += temp_tissue;
    }
}

//////////////////////////////////////////////////////////////////////////////
// sim_limit()
//
// New in v.111
//
// Function separated from sim_tissue() to allow recomputing limit on
// different depth, because it depends on current gradient factor.
//
static void sim_limit(PARAMETER float GF_current)
{
    assert( 0.0 < GF_current && GF_current <= 1.0f);

    sim_lead_tissue_limit = 0.0;
    sim_lead_tissue_no = 0;             // If no one is critic, keep first tissue.

    for(ci=0; ci<16; ci++)
    {
        overlay float N2 = sim_pres_tissue[ci];
        overlay float He = (sim_pres_tissue+16)[ci];
        overlay float p = N2 + He;

        read_buhlmann_coefficients();
        var_N2_a = (var_N2_a * N2 + var_He_a * He) / p;
        var_N2_b = (var_N2_b * N2 + var_He_b * He) / p;

        // Apply the Eric Baker's varying gradient factor correction.
        // Note: the correction factor depends both on GF and b,
        //       Actual values are in the 1.5 .. 1.0 range (for a GF=30%),
        //       so that can change who is the leading gas...
        // Note: Also depends of the GF_current...
        if( char_I_deco_model == 1 )
            p = ( p - var_N2_a * GF_current) * var_N2_b
              / (GF_current + var_N2_b * (1.0 - GF_current));
        else
            p = (p - var_N2_a) * var_N2_b;
        if( p < 0.0 ) p = 0.0;

        if( p > sim_lead_tissue_limit )
        {
            sim_lead_tissue_no = ci;
            sim_lead_tissue_limit = p;
        }
    } // for ci

    assert( sim_lead_tissue_no < 16 );
    assert( 0.0 <= sim_lead_tissue_limit && sim_lead_tissue_limit <= 14.0 );
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
//      internal_deco_depth[] : depth (in metres) of each stops.
//      internal_deco_time [] : time (in minutes) of each stops.
//
static void update_deco_table()
{
    overlay unsigned char x;
    assert( temp_depth_limit < 128 );   // Can't be negativ (overflown).
    assert( temp_depth_limit > 0 );     // No stop at surface...

    for(x=0; x<32; ++x)
    {
        // Make sure deco-stops are recorded in order:
        assert( !internal_deco_depth[x] || temp_depth_limit <= internal_deco_depth[x] );

        if( internal_deco_depth[x] == temp_depth_limit )
        {
            // Do not overflow (max 255')
	        if( internal_deco_time[x] < 255 )
            {
                internal_deco_time[x]++;
                return;
            }
            // But store extra in the next stop...
        }

        if( internal_deco_depth[x] == 0 )
        {
            internal_deco_depth[x] = temp_depth_limit;
            internal_deco_time[x]  = 1;
            return;
        }
    }

    // Can't store stops at more than 96m.
    // Or stops at less that 3m too.
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
    overlay float gf;

    assert( char_O_gtissue_no < 16 );
    assert( 0.800 <= pres_respiration && pres_respiration < 14.0 );

	// tissue > respiration (entsaettigungsvorgang)
	// gradient ist wieviel prozent an limit mit basis tissue
	// dh. 0% = respiration == tissue
	// dh. 100% = respiration == limit
	temp_tissue = pres_tissue[char_O_gtissue_no] + (pres_tissue+16)[char_O_gtissue_no];
    if( temp_tissue < pres_respiration )
 		gf = 0.0;
    else
    {
       gf = (temp_tissue - pres_respiration) 
          / (temp_tissue - calc_lead_tissue_limit)
          * 100.0;
        if( gf > 255.0 ) gf = 255.0;
        if( gf < 0.0   ) gf = 0.0;
    }
	char_O_gradient_factor = (unsigned char)gf;

	if (char_I_deco_model == 1)		// calculate relative gradient factor
	{
        overlay float rgf;

		if( low_depth == 0 )
			rgf = GF_high;
        else
        {
            overlay float temp1 = low_depth * 0.09985;
            overlay float temp2 = pres_respiration - pres_surface;

            if (temp2 <= 0)
			    rgf = GF_high;
		    else if (temp2 >= temp1)
			    rgf = GF_low;
		    else
			    rgf = GF_low + (temp1 - temp2)/temp1*GF_delta;
        }

		rgf = gf / rgf; // gf is already in percent
		if( rgf <   0.0 ) rgf =   0.0;
		if( rgf > 255.0 ) rgf = 255.0;
		char_O_relative_gradient_GF  = (unsigned char)rgf;
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
// Inputs:  int_I_pres_surface, ppWVapour, char_I_desaturation_multiplier
// Outputs: int_O_desaturation_time, char_O_tissue_saturation[0..31]
//
void deco_calc_desaturation_time(void)
{
    RESET_C_STACK

    assert( 800 < int_I_pres_surface && int_I_pres_surface < 1100 );
    assert( 0 < char_I_desaturation_multiplier && char_I_desaturation_multiplier <= 100 );

#ifndef CROSS_COMPILE
    // Note: we don't use far rom pointer, because the
    //       24 bits is to complex, hence we have to set
    //       the UPPER page ourself...
    //       --> Set zero if tables are moved to lower pages !
    _asm
        movlw 1
        movwf TBLPTRU,0
    _endasm
#endif

    N2_ratio = 0.7902; // FIXED sum as stated in bühlmann
    pres_surface = int_I_pres_surface * 0.001;
    ppN2 = N2_ratio * (pres_surface - ppWVapour);
    int_O_desaturation_time = 0;
    float_desaturation_multiplier = char_I_desaturation_multiplier / 142.0; // new in v.101	(70,42%/100.=142)

    for (ci=0;ci<16;ci++)
    {
        overlay unsigned short desat_time;    // For a particular compartiment, in min.
        overlay float temp1;
        overlay float temp2;
        overlay float temp3;
        overlay float temp4;
    
        // saturation_time (for flight) and N2_saturation in multiples of halftime
        // version v.100: 1.1 = 10 percent distance to totally clean (totally clean is not possible, would take infinite time )
        // new in version v.101: 1.07 = 7 percent distance to totally clean (totally clean is not possible, would take infinite time )
        // changes in v.101: 1.05 = 5 percent dist to totally clean is new desaturation point for display and NoFly calculations
        // N2
        temp1 = 1.05 * ppN2 - pres_tissue[ci];
        temp2 = ppN2 - pres_tissue[ci];
        if (temp2 >= 0.0)
        {
            temp1 = 0.0;
            temp2 = 0.0;
        }
        else
            temp1 = temp1 / temp2;
        if( 0.0 < temp1 && temp1 < 1.0 )
        {
            overlay float var_N2_halftime = buhlmann_ht[ci];
            assert( 4.0 <= var_N2_halftime && var_N2_halftime <= 635.0 );

            // 0.6931 is ln(2), because the math function log() calculates with a base of e not 2 as requested.
            // minus because log is negative.
            temp1 = log(1.0 - temp1) / -0.6931; // temp1 is the multiples of half times necessary.
            temp2 = var_N2_halftime * temp1 / float_desaturation_multiplier; // time necessary (in minutes ) for complete desaturation (see comment about 5 percent) , new in v.101: float_desaturation_multiplier

        }
        else
        {
            temp1 = 0.0;
            temp2 = 0.0;
        }

        // He
        temp3 = 0.1 - (pres_tissue+16)[ci];
        if (temp3 >= 0.0)
        {
            temp3 = 0.0;
            temp4 = 0.0;
        }
        else
            temp3 = - temp3 / (pres_tissue+16)[ci];
        if( 0.0 < temp3 && temp3 < 1.0 )
    	{
            overlay float var_He_halftime = (buhlmann_ht+16)[ci];
            assert( 1.51 <= var_He_halftime && var_He_halftime <= 240.03 );

        	temp3 = log(1.0 - temp3) / -0.6931; // temp1 is the multiples of half times necessary.
        							 // 0.6931 is ln(2), because the math function log() calculates with a base of e  not 2 as requested.
        							 // minus because log is negative
        	temp4 = var_He_halftime * temp3 / float_desaturation_multiplier; // time necessary (in minutes ) for "complete" desaturation, new in v.101 float_desaturation_multiplier
    	}
        else
    	{
        	temp3 = 0.0;
        	temp4 = 0.0;
    	}

        // saturation_time (for flight)
        if (temp4 > temp2)
            desat_time = (unsigned short)temp4;
        else
            desat_time = (unsigned short)temp2;
        
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
    assert( 800 < int_I_pres_surface && int_I_pres_surface < 1100 );
    assert( 800 < int_I_pres_respiration && int_I_pres_respiration < 1100 );
    assert( 100 <= char_I_saturation_multiplier && char_I_saturation_multiplier < 200 );
    assert( 0 < char_I_desaturation_multiplier && char_I_desaturation_multiplier <= 100 );

	if(flag_in_divemode)
	{
		flag_in_divemode = 0;
		set_dbg_end_of_dive();
	}

    N2_ratio = 0.7902; // FIXED, sum lt. buehlmann
    pres_respiration = int_I_pres_respiration * 0.001;  // assembler code uses different digit system
    pres_surface = int_I_pres_surface * 0.001;          // the b"uhlmann formula using pres_surface does not use the N2_ratio
    ppN2 = N2_ratio * (pres_respiration - ppWVapour);   // ppWVapour is the extra pressure in the body
    ppHe = 0.0;
    float_desaturation_multiplier = char_I_desaturation_multiplier / 142.0; // new in v.101	(70,42%/100.=142)
    float_saturation_multiplier   = char_I_saturation_multiplier   * 0.01;
    
    calc_tissue(1);  // update the pressure in the 32 tissues in accordance with the new ambient pressure
    
    clear_deco_table();
    char_O_deco_status = 3;     // surface new in v.102 : stays in surface state.
    char_O_nullzeit = 0;
    int_O_ascenttime = 0;
    calc_gradient_factor();
}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
////////////////////////////////// deco_hash /////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

#ifndef CROSS_COMPILE
void deco_hash(void)
{
    overlay unsigned char md_i, md_j;   // Loop index.
    overlay unsigned char md_t;
    overlay unsigned char md_buffer[16];
    overlay unsigned char md_temp;
    overlay unsigned short  md_pointer;

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
            md_state[md_i+16] = md_temp;
            md_state[md_i+32] = (unsigned char)(md_temp ^ md_state[md_i]);
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
#endif

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

    assert( 0.0 <= CNS_fraction && CNS_fraction <= 2.5 );
    assert( char_I_actual_ppO2 > 15 );

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
// (Used in sleepmode, for low battery mode).
//
// Output: char_O_CNS_fraction
// Uses and Updates: CNS_fraction
//
void deco_calc_CNS_decrease_15min(void)
{
    RESET_C_STACK
    assert( 0.0 <= CNS_fraction && CNS_fraction <= 2.5 );

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
//
// Used to compute NoFly remaining time.
//
void deco_calc_percentage(void)
{
    RESET_C_STACK

    assert( 60 <= char_I_temp && char_I_temp <= 100 );
    assert(  0 <= int_I_temp  && int_I_temp  < 2880 );      // Less than 48h...

    int_I_temp = (unsigned short)(((float)int_I_temp * (float)char_I_temp) * 0.01 );

    assert( int_I_temp < 1440 );                            // Less than 24h...
}


//////////////////////////////////////////////////////////////////////////////
// deco_gas_volumes
//
// new in v.111
//
// calculates volumes for each gas.
//
// Input:   char_I_bottom_depth, char_I_bottom_time for planned dive.
//          Gas list.
//          char_I_first_gas is the bottom gas.
//          decoplan (char_O_deco_depth, char_O_deco_time).
//          CF#54 == TRUE if shallowest stop first.
//          CF#56 == bottom deci-liters/minutes (0.5 .. 50.0) or bar/min.
//          CF#57 == deco deci-liters/minutes (0.5 .. 50.0) or bar/min.
// Output:  int_O_gas_volumes[0..4] in litters * 0.1
//
void deco_gas_volumes(void)
{
    overlay float volumes[5];
    overlay float bottom_usage, ascent_usage;
    overlay unsigned char i, deepest_first;
    overlay unsigned char gas;
    RESET_C_STACK

    //---- initialize with bottom consumption --------------------------------
    for(i=0; i<5; ++i)                              // Nothing yet...
        volumes[i] = 0.0;

    assert(1 <= char_I_first_gas && char_I_first_gas <= 5);
    gas = char_I_first_gas - 1;

    bottom_usage = read_custom_function(56) * 0.1;
    if( bottom_usage > 0.0 )
        volumes[gas]
            = (char_I_bottom_depth*0.1 + 1.0)           // Use Psurface = 1.0 bar.
            * char_I_bottom_time                        // in minutes.
            * bottom_usage;                             // In liter/minutes.
    else
        volumes[gas] = 65535.0;

    //---- Ascent usage ------------------------------------------------------

    deepest_first = read_custom_function(54) == 0;
    ascent_usage  = read_custom_function(57) * 0.1; // In liter/minutes.

    // Usage up to the first stop:
    //  - computed at MAX depth (easier, safer),
    //  - with an ascent speed of 10m/min.
    //  - with ascent litter / minutes.
    //  - still using bottom gas:
    if( ascent_usage > 0.0 )
        volumes[gas]
            += (char_I_bottom_depth*0.1 + 1.0)          // Depth -> bar
             * (char_I_bottom_depth - char_O_first_deco_depth) * 0.1  // ascent time (min)
             * ascent_usage;                            // Consumption ( xxx / min @ 1 bar)
    else
        volumes[gas] = 65535.0;

    for(i=0; i<32; ++i)
    {
        overlay unsigned char j;
        overlay unsigned char depth, time, ascent;

        // Manage stops in reverse order (CF#54)
        if( deepest_first )
        {
            time = char_O_deco_time[i];
            if( time == 0 ) break;          // End of table: done.

            ascent = depth  = char_O_deco_depth[i];
            if( i < 31 )
                ascent -= char_O_deco_depth[i+1];
        }
        else
        {
            time = char_O_deco_time[31-i];
            if( time == 0 ) continue;       // not yet: still searh table.

            ascent = depth = char_O_deco_depth[31-i];
            if( i < 31 )
                ascent -= char_O_deco_depth[30-i];
        }

        // Gas switch depth ?
        for(j=0; j<5; ++j)
        {
            if( depth <= char_I_deco_gas_change[j] )
                if( !char_I_deco_gas_change[gas] || (char_I_deco_gas_change[gas] > char_I_deco_gas_change[j]) )
                    gas = j;
        }

        // usage during stop:
        // Note: because first gas is not in there, increment gas+1
        if( ascent_usage > 0.0 )
            volumes[gas] += (depth*0.1 + 1.0)   // depth --> bar.
                          * time                // in minutes.
                          * ascent_usage        // in xxx / min @ 1bar.
            // Plus usage during ascent to the next stop, at 10m/min.
                          + (depth*0.1  + 1.0)
                          * ascent*0.1          // metre --> min
                          * ascent_usage;
        else
            volumes[gas] = 65535.0;
    }

    //---- convert results for the ASM interface -----------------------------
    for(i=0; i<5; ++i)
        if( volumes[i] > 6553.4 )
            int_O_gas_volumes[i] = 65535;
        else
            int_O_gas_volumes[i] = (unsigned short)(volumes[i]*10.0 + 0.5);
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
#ifndef CROSS_COMPILE
void main() {}
#endif
