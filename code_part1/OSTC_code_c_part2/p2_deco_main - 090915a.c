/*
 *  p2_deco_main.c
 *
 *  Created on: 31.08.2009
 *      Author: christian.w @ heinrichsweikamp.com
 *
 */

//#include <p2_deco_header_c_v102d.h>

// OSTC - diving computer code
// Copyright (C) 2009 HeinrichsWeikamp GbR

//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.

//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.

//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.


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
// 03/31/090 v107: integration of FONT Incon24

//
// literature:
// B"uhlmann, Albert: Tauchmedizin; 4. Auflage;
// Schr"oder, Kai & Reith, Steffen; 2000; S"attigungsvorg"ange beim Tauchen, das Modell ZH-L16, Funktionsweise von Tauchcomputern; http://www.achim-und-kai.de/kai/tausim/saett_faq
// Morrison, Stuart; 2000; DIY DECOMPRESSION; http://www.lizardland.co.uk/DIYDeco.html
// Balthasar, Steffen; Dekompressionstheorie I: Neo Haldane Modelle; http://www.txfreak.de/dekompressionstheorie_1.pdf
// Baker, Erik C.; Clearing Up The Confusion About "Deep Stops"
// Baker, Erik C.; Understanding M-values; http://www.txfreak.de/understanding_m-values.pdf


// *********************
// ** I N C L U D E S **
// *********************
 #include <p18f4685.h>
 #include <math.h>

// ********************************
// ** C O N F I G U R A T I O N  **
// ** for simulation without asm **
// ********************************
 #pragma config OSC = IRCIO67
 #pragma config FCMEN = OFF
 #pragma config IESO = OFF
 #pragma config PWRT = ON
 #pragma config BOREN = OFF
 #pragma config WDT = OFF
 #pragma config WDTPS = 128
 #pragma config MCLRE = ON
 #pragma config LPT1OSC = OFF
 #pragma config PBADEN = OFF
 #pragma config DEBUG = OFF
 #pragma config XINST = OFF
 #pragma config LVP = OFF
 #pragma config STVREN = OFF

// ****************************
// ** D E F I N E S          **
// ** missing in  p18f4685.h **
// ****************************
#define INT0IF	1
#define INT1IF	0
#define TMR1IF	0


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

// NDL_at_20mtr



// ***********************
// ** V A R I A B L E S **
// ***********************
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

#define	WP_FONT_SMALL_HEIGHT	 24
#define	WP_FONT_MEDIUM_HEIGHT	 32
#define	WP_FONT_LARGE_HEIGHT	 58

#define oled_rw	PORTA,2,0
#define oled_rs	PORTE,0,0

#define U8 unsigned char
#define U16 unsigned int

// IO assembler
#pragma udata bank0a=0x060
volatile unsigned char wp_stringstore[26];
volatile U8 wp_color1;
volatile U8 wp_color2;
volatile U8 wp_top;
volatile U8 wp_leftx2;
volatile U8 wp_font;
volatile U8 wp_invert;
volatile U8 wp_temp_U8;
// internal C
#pragma udata bank0b=0x081
volatile U8 wp_txtptr;
volatile unsigned char wp_char;
volatile U8	wp_command;
volatile U16	wp_data_16bit;
volatile U8	wp_data_8bit_one;
volatile U8	wp_data_8bit_two;
volatile U16	wp_start;
volatile U16	wp_end;
volatile U16	wp_i;
volatile U8 	wp_black;
// some spare
volatile U8	wp_debug_U8;

// asm only
#pragma udata bank0c=0x0D0
#define LENGTH_kf_bank0	48
volatile unsigned char keep_free_bank0[LENGTH_kf_bank0];


#pragma udata bank1=0x100
#define LENGTH_kf_bank1	256
volatile unsigned char keep_free_bank1[LENGTH_kf_bank1]; // used by the assembler code

 #pragma udata bank2a=0x200
// output:
 static unsigned int	int_O_tissue_for_debug[32];
 static unsigned int	int_O_GF_spare____;						// 0x240
 static unsigned int	int_O_GF_step;							// 0x242
 static unsigned int 	int_O_gtissue_limit;					// 0x244
 static unsigned int 	int_O_gtissue_press;					// 0x246
 static unsigned int 	int_O_limit_GF_low;						// 0x248
 static unsigned int 	int_O_gtissue_press_at_GF_low;			// 0x24A
// 0x24C + 0x24D noch unbenutzt

 #pragma udata bank2b=0x24E
 static unsigned char	char_O_GF_low_pointer;					// 0x24E
 static unsigned char	char_O_actual_pointer;					// 0x24F
 #pragma udata bank2c=0x250
 static unsigned char	char_O_deco_table[32];					// 0x250
 #pragma udata bank2d=0x270
 static unsigned char	char_I_table_deco_done[32];
 #pragma udata bank2e=0x290
 static unsigned int 	int_O_calc_tissue_call_counter;			// 0x290
// internal:
 unsigned char 			lock_GF_depth_list;
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
 static unsigned char	temp_decotime;
 static unsigned char	temp_gtissue_no;
 static	unsigned int	temp_depth_last_deco;				// new in v.101

 static unsigned char	temp_depth_GF_low_meter;
 static unsigned char	temp_depth_GF_low_number;
 static unsigned char	internal_deco_pointer;
 static unsigned char	internal_deco_table[32];
 static float			temp_pres_deco_GF_low;

static unsigned int debug_temp;


#pragma udata bank3a=0x300
static char output[32];
// used by the math routines
#pragma udata bank3b=0x380
volatile float pres_tissue_vault[32];
 #pragma udata bank4a=0x400
// internal:
 unsigned char			ci ; // don't move - used in _asm routines - if moved then modify movlb commands
 unsigned char 			x;
 unsigned int 			main_i;
 unsigned int 			int_temp;
 unsigned int 			int_temp_decostatus;
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
 static float			temp_ratio;
 static float 			var_a;
 static float 			var2_a;
 static float 			var_b;
 static float 			var2_b;
 static float 			var_t05nc;
 static float 			var2_t05nc;
 static float  			var_e2secs;
 static float  			var2_e2secs;
 static float  			var_e1min;
 static float  			var2_e1min;
 static float  			var_halftimes;
 static float  			var2_halftimes;
 static float			pres_gtissue_limit;
 static float			temp_pres_gtissue_limit;
 static float			actual_ppO2;						// new in v.102
 #pragma udata bank4b=0x480
 static float			pres_tissue[32];

 #pragma udata bank5=0x500
// don't move positions in this bank, the registers are addressed directly from assembler code
// input:
 static unsigned int	int_I_pres_respiration;				// 0x500
 static unsigned int	int_I_pres_surface;					// 0x502
 static unsigned int	int_I_temp;							// 0x504  new in v101
 static unsigned char	char_I_temp;						// 0x506  new in v101
 static unsigned char	char_I_actual_ppO2;					// 0x507
 static unsigned int	int_I_spare_3;
 static unsigned int	int_I_spare_4;
 static unsigned int	int_I_spare_5;
 static unsigned int	int_I_spare_6;
 static unsigned char	char_I_N2_ratio;					// 0x510
 static unsigned char	char_I_He_ratio;					// 0x511
 static unsigned char	char_I_saturation_multiplier;		// for conservatism/safety values 1.0 (no conservatism) to 1.5 (50% faster saturation
 static unsigned char	char_I_desaturation_multiplier; 	// for conservatism/safety values 0.66 (50% slower desaturation) to 1.0 (no conservatism)// consveratism used in calc_tissue(), calc_tissue_step_1_min() and sim_tissue_1min()
 static unsigned char	char_I_GF_High_percentage;			// 0x514	new in v.102
 static unsigned char	char_I_GF_Low_percentage;			// 0x515	new in v.102
 static unsigned char	char_I_spare;					// 0x516
 static unsigned char	char_I_deco_distance;				// 0x517
 static unsigned char	char_I_const_ppO2;					// 0x518	new in v.101
 static unsigned char	char_I_deco_ppO2_change;			// 0x519	new in v.101
 static unsigned char	char_I_deco_ppO2;					// 0x51A	new in v.101
 static unsigned char	char_I_deco_gas_change;				// 0x51B	new in v.101
 static unsigned char	char_I_deco_N2_ratio;				// 0x51C	new in v.101
 static unsigned char	char_I_deco_He_ratio;				// 0x51D	new in v.101
 static unsigned char	char_I_depth_last_deco;				// 0x51E	new in v.101 unit: [m]
 static unsigned char	char_I_deco_model;					// 0x51F	new in v.102	( 1 = MultiGraF, sonst Std. mit (de-)saturation_multiplier)
// output:
 static unsigned int	int_O_desaturation_time;			// 0x520
 static unsigned char	char_O_nullzeit;					// 0x522
 static unsigned char	char_O_deco_status;					// 0x523
 static unsigned char	char_O_array_decotime[7];			// 0x524
 static unsigned char	char_O_array_decodepth[6];			// 0x52B
 static unsigned char	char_O_ascenttime;					// 0x531
 static unsigned char	char_O_gradient_factor;				// 0x532
 static unsigned char	char_O_tissue_saturation[32];		// 0x533
 static unsigned char	char_O_array_gradient_weighted[16];	// 0x553
 static unsigned char	char_O_gtissue_no;					// 0x563
 static unsigned char	char_O_diluent;						// 0x564	new in v.101
 static unsigned char	char_O_CNS_fraction;				// 0x565	new in v.101
 static unsigned char	char_O_relative_gradient_GF;		// 0x566	new in v.102

// internal:
 static float			pres_tissue_limit[16];
 static float			sim_pres_tissue_limit[16];
 static float			pres_diluent;						// new in v.101
 static float			deco_diluent;						// new in v.101
 static float			const_ppO2;							// new in v.101
 static float			deco_ppO2_change;					// new in v.101
 static float			deco_ppO2;							// new in v.101



 #pragma udata bank6=0x600
// internal:
 static float			sim_pres_tissue[32];
 static float			sim_pres_tissue_backup[32];

 //#pragma udata bank7=0x700
 //const unsigned char keep_free_bank7[256]; // used by the assembler code (DD font2display)

 #pragma udata bank8=0x800
 static char			md_pi_subst[256];

 #pragma udata bank9a=0x900
// output:
 static char			md_state[48];		// DONT MOVE !! // has to be at the beginning of bank 9 for the asm code!!!
 #pragma udata bank9b=0x930
// output:
 static unsigned int	int_O_DBS_bitfield;					// 0x930	new in v.108
 static unsigned int	int_O_DBS2_bitfield;				// 0x932	new in v.108
 static unsigned int	int_O_DBG_pre_bitfield;				// 0x934	new in v.108
 static unsigned int	int_O_DBG_post_bitfield;			// 0x936	new in v.108
 static char			char_O_NDL_at_20mtr;				// 0x938	new in v.108 // 0xFF == undefined, max. 254
// internal:
 static char			md_t;
 static char			md_buffer[16];
 static char			md_cksum[16];
 static char			md_i;
 static char			md_j;
 static char			md_temp;
 static unsigned int	md_pointer;
 static float			deco_N2_ratio;						// new in v.101
 static float			deco_He_ratio;						// new in v.101
 static float			calc_N2_ratio;						// new in v.101
 static float			calc_He_ratio;						// new in v.101
 static float			deco_gas_change;					// new in v.101
 static float			CNS_fraction;						// new in v.101
 static float			float_saturation_multiplier;		// new in v.101
 static float			float_desaturation_multiplier;		// new in v.101
 static float			float_deco_distance;				// new in v.101
// internal, dbg:
 static unsigned char	DBG_char_I_deco_model;				// new in v.108
 static unsigned char	DBG_char_I_depth_last_deco;			// new in v.108
 static float			DBG_pres_surface;					// new in v.108
 static float			DBG_GF_low;							// new in v.108
 static float			DBG_GF_high;						// new in v.108
 static float			DBG_const_ppO2;						// new in v.108
 static float			DBG_deco_ppO2_change;				// new in v.108
 static float			DBG_deco_ppO2;						// new in v.108
 static float			DBG_deco_N2_ratio;					// new in v.108
 static float			DBG_deco_He_ratio;					// new in v.108
 static float			DBG_deco_gas_change;				// new in v.108
 static float			DBG_float_saturation_multiplier;	// new in v.108
 static float			DBG_float_desaturation_multiplier;	// new in v.108
 static float			DBG_float_deco_distance;			// new in v.108
 static float			DBG_deco_N2_ratio;					// new in v.108
 static float			DBG_deco_He_ratio;					// new in v.108
 static float			DBG_N2_ratio;						// new in v.108
 static float			DBG_He_ratio;						// new in v.108
 static char			flag_in_divemode;					// new in v.108
 static	int 			int_dbg_i;							// new in v.108
 unsigned int 			temp_DBS;

// *************************
// ** P R O T O T Y P E S **
// *************************
void main_calc_hauptroutine(void);
void main_calc_without_deco(void);
void main_clear_tissue(void);
void main_calc_percentage(void);
void main_calc_wo_deco_step_1_min(void);
void main_debug(void);
void main_gradient_array(void);
void main_hash(void);

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
void calc_gradient_array_only(void);
void calc_desaturation_time(void);
void calc_wo_deco_step_1_min(void);
void calc_tissue_step_1_min(void);
void hash(void);
void clear_CNS_fraction(void);
void calc_CNS_fraction(void);
void calc_CNS_decrease_15min(void);
void calc_percentage(void);
void main(void);
void calc_hauptroutine_data_input(void);
void calc_hauptroutine_update_tissues(void);
void calc_hauptroutine_calc_deco(void);
void calc_hauptroutine_calc_ascend_to_deco(void);
void calc_nextdecodepth_GF(void);
void copy_deco_table_GF(void);
void clear_internal_deco_table_GF(void);
void update_internal_deco_table_GF(void);
void DD2_write(void);
void DD2_write_incon42(void);
void DD2_get_pointer_to_char(void);
void DD2_set_column(void);
void DD2_load_background(void);
void DD2_build_one_line_of_char(void);
void DD2_print_column(void);
void DD2_CmdWrite(void);
void DD2_DataWrite(void);
void push_tissues_to_vault(void);
void pull_tissues_from_vault(void);
void main_push_tissues_to_vault(void);
void main_pull_tissues_from_vault(void);
void wordprocessor(void);

// *******************************
// ** start                     **
// ** necessary for compilation **
// *******************************
#pragma romdata der_code = 0x0000
#pragma code der_start = 0x0000
void der_start(void)
{
_asm
	goto	main
_endasm
}

// ***********************************
// ** main code for simulation /    **
// ** tests without assembler code  **
// ** is NOT a part of the OSTC     **
// ***********************************
#pragma code main = 0x9000
void main(void)
{
	for(wp_temp_U8=0;wp_temp_U8<LENGTH_kf_bank0 - 1;wp_temp_U8++)
		keep_free_bank0[wp_temp_U8] = 7;
	keep_free_bank0[LENGTH_kf_bank0 - 1] = 7;

	for(wp_temp_U8=0;wp_temp_U8<LENGTH_kf_bank1 - 1;wp_temp_U8++)
		keep_free_bank1[wp_temp_U8] = 7;
	keep_free_bank1[LENGTH_kf_bank1 - 1] = 7;

#if 1
// new main to test DR-5

wp_top = 10;
wp_leftx2 = 10;
wp_color1 = 255;
wp_color2 = 255;
wp_font   = 0;
wp_invert = 0;
wp_stringstore[0] = ' ';
wp_stringstore[1] = '!';
wp_stringstore[2] = '"';
wp_stringstore[3] = ':';
wp_stringstore[4] = 0;
wordprocessor();

GF_low = 1.0;
GF_high = 1.0;

GF_temp = GF_low * GF_high;

clear_CNS_fraction();
//char_I_const_ppO2 = 100;
//for (main_i=0;main_i<255;main_i++)
//{
//calc_CNS_fraction();
//} //for




int_I_pres_respiration = 1000;//980;
int_I_pres_surface = 1000;//980;
char_I_N2_ratio = 39; //38;
char_I_He_ratio = 40; //50;
char_I_deco_distance = 0; // 10 = 1 meter
char_I_depth_last_deco = 3;	// values below 3 (meter) are ignored

char_I_const_ppO2 = 0;
char_I_deco_ppO2_change = 0; // [dm] 10 = 1 meter
char_I_deco_ppO2 = 0;

char_I_deco_gas_change = 0; // [m] 1 = 1 meter
char_I_deco_N2_ratio = 0;
char_I_deco_He_ratio = 0;

//char_I_actual_ppO2;					// 0x507
char_I_GF_High_percentage = 100;			// 0x514	new in v.102
char_I_GF_Low_percentage = 100;			// 0x515	new in v.102

char_I_saturation_multiplier = 110;
char_I_desaturation_multiplier = 90;

char_I_deco_model = 0;

main_clear_tissue();

int_I_pres_respiration = 1000 + int_I_pres_surface;
main_calc_wo_deco_step_1_min();
int_I_pres_respiration = 3000 + int_I_pres_surface;
main_calc_wo_deco_step_1_min();
int_I_pres_respiration = 5000 + int_I_pres_surface;
main_calc_wo_deco_step_1_min();

/*
int_I_pres_respiration = 6000 + int_I_pres_surface;
for (main_i=0;main_i<27;main_i++)
	main_calc_wo_deco_step_1_min();
*/

char_O_deco_status = 255;
while (char_O_deco_status)
	main_calc_hauptroutine();
_asm
nop
_endasm

for (main_i=0;main_i<50;main_i++)
{
main_calc_hauptroutine();
}
int_I_pres_respiration = 10000;
for (main_i=0;main_i<1500;main_i++)
{
main_calc_hauptroutine();
}

_asm
nop
_endasm


int_I_pres_respiration = 3000;
for (main_i=0;main_i<150;main_i++)
{
	calc_hauptroutine_data_input();
	calc_hauptroutine_update_tissues();
} //for

			update_startvalues();
			clear_decoarray();
			clear_internal_deco_table_GF();
			calc_hauptroutine_calc_ascend_to_deco();
 			if (char_O_deco_status > 15)		// can't go up to first deco, too deep to calculate in the given time slot
			{
				char_O_deco_status = 2;
//				char_O_lock_depth_list = 255;
			}
 			else
			{
//				char_O_lock_depth_list = lock_GF_depth_list;
				calc_hauptroutine_calc_deco();
			}
//			build_debug_output();

_asm
nop
_endasm
while (char_O_deco_status == 1)
{
			char_O_deco_status = 0;
//			char_O_lock_depth_list = 255;
			calc_hauptroutine_calc_deco();
//			build_debug_output();
_asm
nop
_endasm
};
debug_temp = 60; // [mtr Aufstieg in 10 mtr/min (30steps'2sec/min]
int_I_pres_respiration = 9980;
for (main_i=0;main_i<debug_temp;main_i++)
{
int_I_pres_respiration = int_I_pres_respiration - 33;
	calc_hauptroutine_data_input();
	calc_hauptroutine_update_tissues();
int_I_pres_respiration = int_I_pres_respiration - 33;
	calc_hauptroutine_data_input();
	calc_hauptroutine_update_tissues();
int_I_pres_respiration = int_I_pres_respiration - 34;
	calc_hauptroutine_data_input();
	calc_hauptroutine_update_tissues();
} //for
_asm
nop
_endasm

			update_startvalues();
			clear_decoarray();
			clear_internal_deco_table_GF();
			calc_hauptroutine_calc_ascend_to_deco();
 			if (char_O_deco_status > 15)		// can't go up to first deco, too deep to calculate in the given time slot
			{
				char_O_deco_status = 2;
//				char_O_lock_depth_list = 255;
			}
 			else
			{
//				char_O_lock_depth_list = lock_GF_depth_list;
				calc_hauptroutine_calc_deco();
			}
//			build_debug_output();

_asm
nop
_endasm
while (char_O_deco_status == 1)
{
			char_O_deco_status = 0;
//			char_O_lock_depth_list = 255;
			calc_hauptroutine_calc_deco();
//			build_debug_output();
_asm
nop
_endasm
};
_asm
nop
_endasm
debug_temp = 60; // [mtr Aufstieg in 10 mtr/min (30steps'2sec/min]
int_I_pres_respiration = 9980;
debug_temp = debug_temp * 3;
for (main_i=0;main_i<debug_temp;main_i++)
{
	calc_hauptroutine_data_input();
	calc_hauptroutine_update_tissues();
} //for
_asm
nop
_endasm
#endif
// -----------------------

} // main

// ******************************************************
// ******************************************************
// ** THE FOLLOWING CODE HAS TO BE COPPIED TO THE OSTC **
// ******************************************************
// ******************************************************

// ***************
// ***************
// ** THE FONTS **
// ***************
// ***************
// all new for bigscreen

#pragma romdata font_data_large = 0x09A00
rom const rom U16 wp_large_data[] =
{
#include "ostc90.drx.txt"
};

#pragma romdata font_table_medium = 0x0A000
rom const rom U16 wp_medium_table[] =
{
#include "ostc48.tbl.txt" // length 0x22
};

#pragma romdata font_data_medium = 0x0A024
rom const rom U16 wp_medium_data[] =
{
#include "ostc48.drx.txt" // length 0x390
};

#pragma romdata font_table_small = 0x0A39A
rom const rom U16 wp_small_table[] =
{
#include "ostc28.tbl.txt"
};

#pragma romdata font_data_small = 0x0A484
rom const rom U16 wp_small_data[] =
{
#include "ostc28.drx.txt"
};

#pragma romdata font_table_large = 0x0BEE0
rom const rom U16 wp_large_table[] =
{
0x0000
//#include "ostc90.tbl.txt"
};

// ***********************
// ***********************
// ** THE SUBROUTINES 2 **
// ***********************
// ***********************
// all new in v.102
// moved from 0x0D000 to 0x0C000 in v.108

#pragma code subroutines2 = 0x0C000	// can be adapted to fit the romdata tables ahead

// -------------------------------
// DBS - debug on start of dive //
// -------------------------------
void create_dbs_set_dbg_and_ndl20mtr(void)
{
	int_O_DBS_bitfield = 0;
	int_O_DBS2_bitfield = 0;
	if(int_O_DBG_pre_bitfield & DBG_RUN)
		int_O_DBG_pre_bitfield = DBG_RESTART;
	else
		int_O_DBG_pre_bitfield = DBG_RUN;
	int_O_DBG_post_bitfield = 0;
	char_O_NDL_at_20mtr = 255;

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
	DBG_deco_N2_ratio = deco_N2_ratio;
	DBG_deco_He_ratio = deco_He_ratio;
	DBG_deco_gas_change = deco_gas_change;
	DBG_float_saturation_multiplier = float_saturation_multiplier;
	DBG_float_desaturation_multiplier = float_desaturation_multiplier;
	DBG_float_deco_distance = float_deco_distance;

	if(char_I_deco_model)
		int_O_DBS_bitfield |= DBS_mode;
	if(const_ppO2)
		int_O_DBS_bitfield |= DBS_ppO2;
	for(int_dbg_i = 16; int_dbg_i < 32; int_dbg_i++)
		if(pres_tissue[int_dbg_i])
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
	if(DBG_deco_gas_change && ((deco_N2_ratio + deco_He_ratio) > 0.95))
		int_O_DBS_bitfield |= DBS_DECOO2l;
	if(DBG_deco_gas_change && ((deco_N2_ratio + deco_He_ratio) < 0.05))
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

// -------------------------------
// DBG - set DBG to end_of_dive //
// -------------------------------
void set_dbg_end_of_dive(void)
{
	int_O_DBG_pre_bitfield &= (~DBG_RUN);
	int_O_DBG_post_bitfield &= (~DBG_RUN);
}

// -------------------------------
// DBG - NDL at first 20 m. hit //
// -------------------------------
void check_ndl(void)
{
	if((char_O_NDL_at_20mtr == -1) && (int_I_pres_respiration > 3000))
	{
		char_O_NDL_at_20mtr = char_O_nullzeit;
		if(char_O_NDL_at_20mtr == 255)
			char_O_NDL_at_20mtr == 254;
	}
}

// -------------------------------
// DBG - multi main during dive //
// -------------------------------
void check_dbg(char is_post_check)
{
	temp_DBS = 0;
	if( (DBG_N2_ratio != N2_ratio) || (DBG_He_ratio != He_ratio) )
		temp_DBS |= DBG_c_gas;
	if(DBG_const_ppO2 != const_ppO2)
		temp_DBS |= DBG_c_ppO2;
	if((DBG_float_saturation_multiplier != float_saturation_multiplier) || (DBG_float_desaturation_multiplier != float_desaturation_multiplier))
		temp_DBS |= DBG_CdeSAT;
	if(DBG_char_I_deco_model != char_I_deco_model)
		temp_DBS |= DBG_C_MODE;
	if(DBG_pres_surface != pres_surface)
		temp_DBS |= DBG_C_SURF;
	if((!DBS_HE_sat) && (!He_ratio))
		for(int_dbg_i = 16; int_dbg_i < 32; int_dbg_i++)
			if(pres_tissue[int_dbg_i])
				temp_DBS |= DBG_HEwoHE;
	if(DBG_deco_ppO2 != deco_ppO2)
		temp_DBS |= DBG_C_DPPO2;
	if((DBG_deco_gas_change != deco_gas_change) || (DBG_deco_N2_ratio != deco_N2_ratio) || (DBG_deco_He_ratio != deco_He_ratio))
		temp_DBS |= DBG_C_DGAS;
	if(DBG_float_deco_distance != float_deco_distance)
		temp_DBS |= DBG_C_DIST;
	if(DBG_char_I_depth_last_deco != char_I_depth_last_deco)
		temp_DBS |= DBG_C_LAST;
	if((DBG_GF_low != GF_low) || (DBG_GF_high != GF_high))
		temp_DBS |= DBG_C_GF;
	if(pres_respiration > 13.0)
		temp_DBS |= DBG_PHIGH;
	if(pres_surface - pres_respiration > 0.2)
		temp_DBS |= DBG_PLOW;
/*
	if()
		temp_DBS |= ;
	if()
		temp_DBS |= ;
 */
	if(is_post_check)
		int_O_DBG_post_bitfield |= temp_DBS;
	else
		int_O_DBG_pre_bitfield |= temp_DBS;
}

// -------------------------------
// DBG - prior to calc. of dive //
// -------------------------------
void check_pre_dbg(void)
{
	check_dbg(0);
}

// -------------------------------
// DBG - after decocalc of dive //
// -------------------------------
void check_post_dbg(void)
{
	check_dbg(1);
}



// -------------------------
// calc_next_decodepth_GF //
// -------------------------
// new in v.102
void calc_nextdecodepth_GF(void)
{
// INPUT, changing during dive:
// temp_pres_gtissue_limit_GF_low
// temp_pres_gtissue_limit_GF_low_below_surface
// temp_pres_gtissue
// temp_pres_gtissue_diff
// lock_GF_depth_list

// INPUT, fixed during dive:
// pres_surface
// GF_delta
// GF_high
// GF_low
// temp_depth_last_deco
// float_deco_distance

// OUTPUT
// GF_step
// temp_deco
// temp_depth_limt
// lock_GF_depth_list

// USES
// temp1
// temp2
// int_temp

	char_I_table_deco_done[0] = 0; // safety if changed somewhere else. Needed for exit
	if (char_I_deco_model == 1)
	{
		if (lock_GF_depth_list == 0)
		{
			temp2 =  temp_pres_gtissue_limit_GF_low_below_surface / 0.29985; 					// = ... / 99.95 / 0.003;
 			int_temp = (int) (temp2 + 0.99);
			if (int_temp > 31)
				int_temp = 31;						//	deepest deco at 93 meter (31 deco stops)
			if (int_temp < 0)
				int_temp = 0;
			temp_depth_GF_low_number = int_temp;
 			temp_depth_GF_low_meter = 3 * temp_depth_GF_low_number;
			temp2 = (float)temp_depth_GF_low_meter * 0.09995;
			temp_pres_deco_GF_low = temp2 + float_deco_distance + pres_surface;
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
			output[8] = int_temp;
			output[9] = 33;
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
				temp2 = (float)(temp_depth_last_deco * int_temp) * 0.09995;
				GF_step2 = GF_step/3.0 * ((float)(6 - temp_depth_last_deco));
			}
			else
			if (int_temp == 0)
			{
				temp2 = 0.0;
				GF_step2 = GF_high - GF_temp;
			}
			else
			{
				temp2 = (float)(3 *int_temp) * 0.09995;
				GF_step2 = GF_step;
			}
			temp2 = temp2 + pres_surface; // next deco stop to be tested
			temp1 = ((GF_temp + GF_step2)* temp_pres_gtissue_diff) + temp_pres_gtissue;	// upper limit (lowest pressure allowed) // changes GF_step2 in v104
			if (temp1 > temp2) // check if ascent to next deco stop is ok
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
			temp2 = (float)(0.29985 * internal_deco_pointer);
			temp_deco = temp2 + float_deco_distance + pres_surface;
			if (internal_deco_pointer == 1)						// new in v104
				temp_depth_limit = temp_depth_last_deco;
			else
				temp_depth_limit = 3 * internal_deco_pointer;
			if (output[9] == 33)
			{
				output[9] = internal_deco_pointer;
				output[10] = char_I_table_deco_done[internal_deco_pointer];
				output[12] = output[12] + 1;
				if (output[12] == 100)
					output[12] = 0;
			}
		}
		else	// 	if (char_I_deco_model == 1)
		{
			temp_deco = pres_surface;
			temp_depth_limit = 0;
		}
	}
	else
	{
		// calc_nextdecodepth - original
		// optimized in v.101
		// depth_last_deco included in v.101

		temp1 = temp_pres_gtissue_limit - pres_surface;
		if (temp1 >= 0)
 		{
 			temp1 = temp1 / 0.29985; 									// = temp1 / 99.95 / 0.003;
 			temp_depth_limit = (int) (temp1 + 0.99);
 			temp_depth_limit = 3 * temp_depth_limit; 					// depth for deco [m]
 			if (temp_depth_limit == 0)
  				temp_deco = pres_surface;
 			else
  			{
  				if (temp_depth_limit < temp_depth_last_deco)
					temp_depth_limit = temp_depth_last_deco;
  				temp1 = (float)temp_depth_limit * 0.09995;
  				temp_deco = temp1 + float_deco_distance + pres_surface; 	// depth for deco [bar]
  			} // if (temp_depth_limit == 0)
 		} // if (temp1 >= 0)
		else
 		{
 			temp_deco = pres_surface;
 			temp_depth_limit = 0;
 		} // if (temp1 >= 0)
	} // calc_nextdecodepth original
} // calc_nextdecodepth_GF


#if 0
void 			build_debug_output(void)
{
output[0] = 0; // not used in asm PLED output
output[1] = (int) (GF_low * 100);
output[2] = (int) (GF_high * 100);
output[3] = (int) (GF_step * 100);
output[4] = (int) temp_depth_GF_low_number;
output[5] = (int) temp_depth_GF_low_meter;
//output[6]
output[7] = (int) internal_deco_pointer;
//output[8] = char_I_table_deco_done[temp_depth_GF_low_number]
//output[9] = internal_deco_pointer @ new run
//output[10] = char_I_table_deco_done[internal_deco_pointer] @ new run
output [11] = (int) (temp_pres_deco_GF_low * 10);
}	// build_debug_output
#endif

// ---------------------
// copy_deco_table_GF //
// ---------------------
// new in v.102
void copy_deco_table_GF(void)
{
	if (char_I_deco_model == 1)
	{
		int_temp = 32;
		for (ci=0;ci<int_temp;ci++)
			char_O_deco_table[ci] = internal_deco_table[ci];
	}
}		// copy_deco_table_GF


// ------------------------------
// clear_internal_deco_table_GF//
// ------------------------------
// new in v.102
void clear_internal_deco_table_GF(void)
{
	if (char_I_deco_model == 1)
	{
		for (ci=0;ci<32;ci++)  // cycle through the 16 b"uhlmann tissues for Helium
		{
			internal_deco_table[ci] = 0;
		}
	}
}	// clear_internal_deco_table_GF


// --------------------------------
// update_internal_deco_table_GF //
// --------------------------------
// new in v.102
void update_internal_deco_table_GF(void)
{
	if ((char_I_deco_model == 1) && (internal_deco_table[internal_deco_pointer] < 255))
		internal_deco_table[internal_deco_pointer] = internal_deco_table[internal_deco_pointer] + 1;
}	// update_internal_deco_table_GF


// ---------------------
// temp_tissue_safety //
// ---------------------
// outsourced in v.102
void temp_tissue_safety(void)
{
	if (char_I_deco_model == 1)
	{
	}
	else
	{
		if (temp_tissue < 0.0)
			temp_tissue = temp_tissue * float_desaturation_multiplier;
 		else
			temp_tissue = temp_tissue * float_saturation_multiplier;
	}
} // temp_tissue_safety

// -----------
// dd2 OLD  //
// -----------
void DD2_write(void)
{
	_asm
	nop
	_endasm
}
void DD2_write_incon42(void)
{
	DD2_write();
}

void DD2_write_incon24(void)
{
	DD2_write();
}
void DD2_get_pointer_to_char(void)
{
	DD2_write();
}
void DD2_set_column(void)
{
	DD2_write();
}
void DD2_load_background(void)
{
	DD2_write();
}
void DD2_build_one_line_of_char(void)
{
	DD2_write();
}
void DD2_print_column(void)
{
	DD2_write();
}
void DD2_CmdWrite(void)
{
	DD2_write();
}
void DD2_DataWrite(void)
{
	DD2_write();
}

// **********************
// **********************
// ** THE JUMP-IN CODE **
// ** for the asm code **
// **********************
// **********************
#pragma code main_calc_hauptroutine = 0x10000
void main_calc_hauptroutine(void)
{
calc_hauptroutine();
int_O_desaturation_time = 65535;
}				// divemode
#pragma code main_without_deco = 0x10020
void main_calc_without_deco(void)
{
calc_without_deco();
calc_desaturation_time();
}

#pragma code main_clear_CNS_fraction = 0x10030
void main_clear_CNS_fraction(void)
{
clear_CNS_fraction();
}

#pragma code main_calc_CNS_decrease_15min = 0x10034
void main_calc_CNS_decrease_15min(void)
{
calc_CNS_decrease_15min();
}

#pragma code main_calc_percentage = 0x10038
void main_calc_percentage (void)
{
calc_percentage();
}

#pragma code main_clear_tissue = 0x10040
void main_clear_tissue(void)
{
clear_tissue();
char_I_depth_last_deco	= 0;		// for compatibility with v.101pre_no_last_deco
}

#pragma code main_calc_CNS_fraction = 0x10050
void main_calc_CNS_fraction(void)
{
calc_CNS_fraction();
}

#pragma code main_calc_desaturation_time = 0x10060
void main_calc_desaturation_time(void)
{
calc_desaturation_time();
}

#pragma code main_calc_wo_deco_step_1_min = 0x10080
void main_calc_wo_deco_step_1_min(void)
{
calc_wo_deco_step_1_min();
char_O_deco_status = 3; // surface new in v.102 overwrites value of calc_wo_deco_step_1_min
calc_desaturation_time();
}			// surface mode

#pragma code main_debug = 0x100A0
void main_debug(void)
{
//debug();
}

#pragma code main_DD2_write_incon42 = 0x100B0
void main_DD2_write_incon42(void)
{
	DD2_write_incon42();
}

#pragma code main_DD2_write_incon24 = 0x100B4
void main_DD2_write_incon24(void)
{
	DD2_write_incon24();
}

#pragma code main_wordprocessor = 0x100B8
void main_wordprocessor(void)
{
	wordprocessor();
}

#pragma code main_gradient_array = 0x100C0
void main_gradient_array(void)
{
calc_gradient_array_only();
}
#pragma code main_push_tissues = 0x100C4
void main_push_tissues_to_vault(void)
{
	push_tissues_to_vault();
}
#pragma code main_pull_tissues = 0x100C8
void main_pull_tissues_from_vault(void)
{
	pull_tissues_from_vault();
}

#pragma code main_hash = 0x100E0
void main_hash(void)
{
hash();
}

// ***********************
// ***********************
// ** THE LOOKUP TABLES **
// ***********************
// ***********************

#pragma romdata tables = 0x10200
#include	<p2_tables.romdata> 		// new table for deco_main_v.101 (var_a modified)

#pragma romdata tables2 = 0x10600
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

// *********************
// *********************
// ** THE SUBROUTINES **
// *********************
// *********************

#pragma code subroutines = 0x10700	// can be adapted to fit the romdata tables ahead


// ---------------
// CLEAR tissue //
// ---------------
// optimized in v.101 (var_a)

void clear_tissue(void)    // preload tissues with standard pressure for the given ambient pressure
{

	flag_in_divemode = 0;
	int_O_DBS_bitfield = 0;
	int_O_DBS2_bitfield = 0;
	int_O_DBG_pre_bitfield = 0;
	int_O_DBG_post_bitfield = 0;
	char_O_NDL_at_20mtr = 255;

_asm
lfsr 1, 0x300 // C math routines shall use this variable bank
movlw	0x01
movwf	TBLPTRU,0
_endasm

// N2_ratio = (float)char_I_N2_ratio; // the 0.0002 of 0.7902 are missing with standard air
 N2_ratio = 0.7902; // N2_ratio / 100.0;
 pres_respiration = (float)int_I_pres_respiration / 1000.0;
for (ci=0;ci<16;ci++)  // cycle through the 16 b"uhlmann tissues
{
 pres_tissue[ci] =  N2_ratio * (pres_respiration -  0.0627) ;
_asm
movlw	0x02
movwf	TBLPTRH,0
movlb	4 // fuer ci
movf ci,0,1
addwf	ci,0,1
addwf	ci,0,1
addwf	ci,0,1
addlw	0x80
movwf	TBLPTRL,0
TBLRDPOSTINC
movff	TABLAT,var_a+1
TBLRDPOSTINC
movff	TABLAT,var_a
TBLRDPOSTINC
movff	TABLAT,var_a+3
TBLRD
movff	TABLAT,var_a+2
addlw	0x80
movwf	TBLPTRL,0
incf	TBLPTRH,1,0
TBLRDPOSTINC
movff	TABLAT,var_b+1
TBLRDPOSTINC
movff	TABLAT,var_b
TBLRDPOSTINC
movff	TABLAT,var_b+3
TBLRD
movff	TABLAT,var_b+2
_endasm

pres_tissue_limit[ci] = (pres_tissue[ci] - var_a) * var_b ;
// now update the guiding tissue
if (pres_tissue_limit[ci] < 0)
pres_tissue_limit[ci] = 0;
} // for 0 to 16

for (ci=16;ci<32;ci++)  // cycle through the 16 b"uhlmann tissues for Helium
{
 pres_tissue[ci] = 0.0;
}  // for

 clear_decoarray();
 char_O_deco_status = 0;
 char_O_nullzeit = 0;
 char_O_ascenttime = 0;
 char_O_gradient_factor = 0;
 char_O_relative_gradient_GF = 0;
} // clear_tissue(void)


// --------------------
// calc_without_deco //
// fixed N2_ratio !  //
// --------------------
// optimized in v.101 (float_..saturation_multiplier)

void calc_without_deco(void)
{
_asm
 lfsr 1, 0x300
_endasm
 N2_ratio = 0.7902; // FIXED RATIO !! sum as stated in b"uhlmann
 pres_respiration = (float)int_I_pres_respiration / 1000.0; // assembler code uses different digit system
 pres_surface = (float)int_I_pres_surface / 1000.0;
 temp_atem = N2_ratio * (pres_respiration - 0.0627); // 0.0627 is the extra pressure in the body
 temp2_atem = 0.0;
 temp_surface = pres_surface; // the b"uhlmann formula using temp_surface does apply to the pressure without any inert ratio
 float_desaturation_multiplier = char_I_desaturation_multiplier / 100.0;
 float_saturation_multiplier = char_I_saturation_multiplier / 100.0;

 calc_tissue();  // update the pressure in the 16 tissues in accordance with the new ambient pressure

 clear_decoarray();
 char_O_deco_status = 0;
 char_O_nullzeit = 0;
 char_O_ascenttime = 0;
 calc_gradient_factor();

} // calc_without_deco


// --------------------
// calc_hauptroutine //
// --------------------
// this is the major code in dive mode
// calculates:
// 		the tissues,
//		the bottom time
//		and simulates the ascend with all deco stops

void calc_hauptroutine(void)
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


	switch (char_O_deco_status)	// toggle between calculation for nullzeit (bottom time), deco stops and more deco stops (continue)
	{
 		case 0:
			update_startvalues();
			calc_nullzeit();
			check_ndl();
			char_O_deco_status = 255; // calc deco next time
			break;
		case 1:
			if (char_O_deco_status == 3)
				break;
			char_O_deco_status = 0;
//			char_O_lock_depth_list = 255;
			calc_hauptroutine_calc_deco();
//			build_debug_output();
			break;
		case 3:				// new dive
			clear_decoarray();
			clear_internal_deco_table_GF();
			copy_deco_table_GF();
			internal_deco_pointer = 0;
			lock_GF_depth_list = 0;
			update_startvalues();
			calc_nextdecodepth_GF();
			char_O_deco_status = 0;
			break;
		default:
			update_startvalues();
			clear_decoarray();
			clear_internal_deco_table_GF();
			output[6] = 1;
			calc_hauptroutine_calc_ascend_to_deco();
 			if (char_O_deco_status > 15)		// can't go up to first deco, too deep to calculate in the given time slot
			{
				char_O_deco_status = 2;
//				char_O_lock_depth_list = 255;
			}
 			else
			{
//				char_O_lock_depth_list = lock_GF_depth_list;
				calc_hauptroutine_calc_deco();
			}
//			build_debug_output();
			break;
	}
	calc_ascenttime();
	check_post_dbg();
}

void calc_hauptroutine_data_input(void)
{
 pres_respiration = (float)int_I_pres_respiration / 1000.0;
 pres_surface = (float)int_I_pres_surface / 1000.0;

 N2_ratio = (float)char_I_N2_ratio / 100.0;; // the 0.0002 of 0.7902 are missing with standard air
 He_ratio = (float)char_I_He_ratio / 100.0;;
 deco_N2_ratio = (float)char_I_deco_N2_ratio / 100.0;
 deco_He_ratio = (float)char_I_deco_He_ratio / 100.0;
 float_deco_distance = (float)char_I_deco_distance / 100.0;
 if(char_I_deco_gas_change)
 {
	 deco_gas_change = (float)char_I_deco_gas_change / 9.995 + pres_surface;
	 deco_gas_change = deco_gas_change + float_deco_distance;
 }
 else
	deco_gas_change = 0;
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

void calc_hauptroutine_update_tissues(void)
{
	int_O_calc_tissue_call_counter = int_O_calc_tissue_call_counter + 1;
 	if (char_I_const_ppO2 == 0)																// new in v.101
  		pres_diluent = pres_respiration;															// new in v.101
 	else																						// new in v.101
  		pres_diluent = ((pres_respiration - const_ppO2)/(N2_ratio + He_ratio));					// new in v.101
 	if (pres_diluent > pres_respiration)														// new in v.101
  		pres_diluent = pres_respiration;															// new in v.101
 	if (pres_diluent > 0.0627)																	// new in v.101
 	{
 		temp_atem = N2_ratio * (pres_diluent - 0.0627);											// changed in v.101
 		temp2_atem = He_ratio * (pres_diluent - 0.0627);											// changed in v.101
 		char_O_diluent = (char)(pres_diluent/pres_respiration*100.0);
 	}
 	else																						// new in v.101
 	{
 		temp_atem = 0.0;																			// new in v.101
 		temp2_atem = 0.0;																			// new in v.101
 		char_O_diluent = 0;
 	}
 	temp_surface = pres_surface;
 	calc_tissue();
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
  		char_O_nullzeit = 0; // deco necessary
  		char_O_deco_status = 255; // calculate deco skip nullzeit calculation
 	}
} 		// calc_hauptroutine_update_tissues
void calc_hauptroutine_calc_deco(void)
{
 	do
  	{
  		int_temp_decostatus = 0;
  		calc_nextdecodepth_GF();
  		if (temp_depth_limit > 0)
   		{
    		if (char_I_const_ppO2 == 0)																// new in v.101
	 		{
     			deco_diluent = temp_deco;																// new in v.101
	 			if (temp_deco > deco_gas_change)
	  			{
	  				calc_N2_ratio = N2_ratio;
	  				calc_He_ratio = He_ratio;
	  			}
	 			else
	  			{
	  				calc_N2_ratio = deco_N2_ratio;
	  				calc_He_ratio = deco_He_ratio;
	  			}
	 		}
    		else																					// new in v.101
	 		{
	 			calc_N2_ratio = N2_ratio;
	 			calc_He_ratio = He_ratio;
	 			if (temp_deco > deco_ppO2_change)
				{
      				deco_diluent = ((temp_deco - const_ppO2)/(N2_ratio + He_ratio));			// new in v.101
				}
	 			else
				{
      				deco_diluent = ((temp_deco - deco_ppO2)/(N2_ratio + He_ratio));			// new in v.101
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
   			sim_tissue_1min();
			update_internal_deco_table_GF();
   			temp_decotime = 1;
   			update_decoarray();
   			char_O_deco_status = char_O_deco_status + 1;
   			if (char_O_deco_status < 16)
     			int_temp_decostatus = 1;
   		}
  		else // if (temp_depth_limit > 0)
		{
   		char_O_deco_status = 0;
		}
	} while (int_temp_decostatus == 1);
	if (char_O_deco_status > 15)
	{
   		char_O_deco_status = 1;
	}
  	else
  	{
		copy_deco_table_GF();
		char_O_deco_status = 0;
  	}
}

void calc_hauptroutine_calc_ascend_to_deco(void)
{
 	update_startvalues();
 	char_O_deco_status = 0;
   	temp_deco = pres_respiration;
 	lock_GF_depth_list = 1; 																// new in v.102
 	do								// go up to first deco
  	{
  		int_temp_decostatus = 0;
  		temp_deco = temp_deco - 1.0;
  		if ( char_I_deco_model == 1)																// new in v.102 , 4 = deep stops
			temp_limit = temp_pres_gtissue_limit_GF_low;
  		else
			temp_limit = temp_pres_gtissue_limit;
  		if ((temp_deco > temp_limit) && (temp_deco > pres_surface)) 								// changes in v.102
   		{
   			lock_GF_depth_list = 0; 																	// new in v.102, distance to first stop > 10 mtr.
			output[6] = 0;
  		 	if (char_I_const_ppO2 == 0)																// new in v.101 // calculate at half of the ascent
			{
    			deco_diluent = temp_deco + 0.5;															// new in v.101
				if (temp_deco + 0.5 > deco_gas_change)
	 			{
	 				calc_N2_ratio = N2_ratio;
	 				calc_He_ratio = He_ratio;
	 			}
				else
	 			{
	 				calc_N2_ratio = deco_N2_ratio;
	 				calc_He_ratio = deco_He_ratio;
	 			}
			}
   			else																						// new in v.101
			{
					calc_N2_ratio = N2_ratio;
					calc_He_ratio = He_ratio;
					if (temp_deco + 0.5 > deco_ppO2_change)
     					deco_diluent = ((temp_deco + 0.5 - const_ppO2)/(N2_ratio + He_ratio));	// new in v.101 // calculate at half of the ascent
					else
     					deco_diluent = ((temp_deco + 0.5 - deco_ppO2)/(N2_ratio + He_ratio));	// new in v.101 // calculate at half of the ascent
    				if (deco_diluent > (temp_deco +0.5))															// new in v.101
     					deco_diluent = temp_deco + 0.5;															// new in v.101 // calculate at half of the ascent
			}
   			if (deco_diluent > 0.0627)																// new in v.101
    		{
    			temp_atem = calc_N2_ratio * (deco_diluent - 0.0627);											// changed in v.101
    			temp2_atem = calc_He_ratio * (deco_diluent - 0.0627);										// changed in v.101
    		}
   			else																						// new in v.101
    		{
    			temp_atem = 0.0;																		// new in v.101
    			temp2_atem = 0.0;																		// new in v.101
    		}
   			sim_tissue_1min();
   			char_O_deco_status = char_O_deco_status + 1;
   			if (char_O_deco_status < 16)  // 16 is the limit of calculations for one time slot
    			int_temp_decostatus = 1;
   		}
	} while (int_temp_decostatus == 1);
}	// calc_hauptroutine_calc_ascend_to_deco

// --------------
// calc_tissue //
// --------------
// optimized in v.101

void calc_tissue(void)
{
_asm
lfsr 1, 0x300
movlw	0x01
movwf	TBLPTRU,0
_endasm

 char_O_gtissue_no = 255;
 pres_gtissue_limit = 0.0;

for (ci=0;ci<16;ci++)
{
_asm
movlw	0x02
movwf	TBLPTRH,0
movlb	4 // fuer ci
movf ci,0,1
addwf	ci,0,1
addwf	ci,0,1
addwf	ci,0,1
movwf	TBLPTRL,0
TBLRDPOSTINC
movff	TABLAT,var_e2secs+1 // the order is confussing
TBLRDPOSTINC
movff	TABLAT,var_e2secs	// low byte first, high afterwards
TBLRDPOSTINC
movff	TABLAT,var_e2secs+3
TBLRD
movff	TABLAT,var_e2secs+2
addlw	0x40
movwf	TBLPTRL,0
TBLRDPOSTINC
movff	TABLAT,var2_e2secs+1
TBLRDPOSTINC
movff	TABLAT,var2_e2secs
TBLRDPOSTINC
movff	TABLAT,var2_e2secs+3
TBLRD
movff	TABLAT,var2_e2secs+2
addlw	0x40
movwf	TBLPTRL,0
TBLRDPOSTINC
movff	TABLAT,var_a+1
TBLRDPOSTINC
movff	TABLAT,var_a
TBLRDPOSTINC
movff	TABLAT,var_a+3
TBLRD
movff	TABLAT,var_a+2
addlw	0x40
movwf	TBLPTRL,0
TBLRDPOSTINC
movff	TABLAT,var2_a+1
TBLRDPOSTINC
movff	TABLAT,var2_a
TBLRDPOSTINC
movff	TABLAT,var2_a+3
TBLRD
movff	TABLAT,var2_a+2
addlw	0x40
movwf	TBLPTRL,0
incf	TBLPTRH,1,0
TBLRDPOSTINC
movff	TABLAT,var_b+1
TBLRDPOSTINC
movff	TABLAT,var_b
TBLRDPOSTINC
movff	TABLAT,var_b+3
TBLRD
movff	TABLAT,var_b+2
addlw	0x40
movwf	TBLPTRL,0
TBLRDPOSTINC
movff	TABLAT,var2_b+1
TBLRDPOSTINC
movff	TABLAT,var2_b
TBLRDPOSTINC
movff	TABLAT,var2_b+3
TBLRD
movff	TABLAT,var2_b+2
_endasm
 // the start values are the previous end values // write new values in temp

	if(	(var_e2secs < 0.0000363)
		|| (var_e2secs > 0.00577)
		|| (var2_e2secs < 0.0000961)
		|| (var2_e2secs > 0.150)
		|| (var_a < 0.231)
		|| (var_a > 1.27)
		|| (var_b < 0.504)
		|| (var_b > 0.966)
		|| (var2_a < 0.510)
		|| (var2_a > 1.75)
		|| (var2_b < 0.423)
		|| (var2_b > 0.927)
		)
		int_O_DBG_pre_bitfield |= DBG_ZH16ERR;

// N2
 temp_tissue = (temp_atem - pres_tissue[ci]) * var_e2secs;
 temp_tissue_safety();
 pres_tissue[ci] = pres_tissue[ci] + temp_tissue;

// He
 temp_tissue = (temp2_atem - pres_tissue[ci+16]) * var2_e2secs;
 temp_tissue_safety();
 pres_tissue[ci+16] = pres_tissue[ci+16] + temp_tissue;

 temp_tissue = pres_tissue[ci] + pres_tissue[ci+16];

 var_a = (var_a * pres_tissue[ci] + var2_a * pres_tissue[ci+16]) / temp_tissue;
 var_b = (var_b * pres_tissue[ci] + var2_b * pres_tissue[ci+16]) / temp_tissue;
 pres_tissue_limit[ci] = (temp_tissue - var_a) * var_b;
 if (pres_tissue_limit[ci] < 0)
  pres_tissue_limit[ci] = 0;
 if (pres_tissue_limit[ci] > pres_gtissue_limit)
  {
  pres_gtissue_limit = pres_tissue_limit[ci];
  char_O_gtissue_no = ci;
  }//if
} // for
}//calc_tissue(void)

// ----------------
// calc_nullzeit //
// ----------------
// calculates the remaining bottom time

// unchanged in v.101

void calc_nullzeit(void)
{
	char_O_nullzeit = 0;
	int_temp = 1;
 	do
	{
  		backup_sim_pres_tissue();
  		sim_tissue_10min();
  		char_O_nullzeit = char_O_nullzeit + 10;
  		int_temp = int_temp + 1;
		if (char_I_deco_model == 1)
			temp1 = GF_high * temp_pres_gtissue_diff + temp_pres_gtissue;
		else
			temp1 = temp_pres_gtissue_limit;
		if (temp1 > temp_surface)  // changed in v.102 , if guiding tissue can not be exposed to surface pressure immediately
			int_temp = 255;
 	} while (int_temp < 17);
 	if (int_temp == 255)
 	{
  		restore_sim_pres_tissue();
  		char_O_nullzeit = char_O_nullzeit - 10;
 	} //if int_temp == 255]
 	int_temp = 1;
 	if (char_O_nullzeit < 60)
 	{
  		do
		{
   			sim_tissue_1min();
   			char_O_nullzeit = char_O_nullzeit + 1;
   			int_temp = int_temp + 1;			// new in v.102a
		if (char_I_deco_model == 1)
			temp1 = GF_high * temp_pres_gtissue_diff + temp_pres_gtissue;
		else
			temp1 = temp_pres_gtissue_limit;
		if (temp1 > temp_surface)  // changed in v.102 , if guiding tissue can not be exposed to surface pressure immediately
			int_temp = 255;
  		} while (int_temp < 10);
  		if (int_temp == 255)
   			char_O_nullzeit = char_O_nullzeit - 1;
 	} // if char_O_nullzeit < 60
} //calc_nullzeit

// -------------------------
// backup_sim_pres_tissue //
// -------------------------
void backup_sim_pres_tissue(void)
{
  for (x = 0;x<16;x++)
  {
   sim_pres_tissue_backup[x] = sim_pres_tissue[x];
   sim_pres_tissue_backup[x+16] = sim_pres_tissue[x+16];
  }
} // backup_sim

// --------------------------
// restore_sim_pres_tissue //
// --------------------------
void restore_sim_pres_tissue(void)
{
  for (x = 0;x<16;x++)
  {
   sim_pres_tissue[x] = sim_pres_tissue_backup[x];
   sim_pres_tissue[x+16] = sim_pres_tissue_backup[x+16];
  }
} // restore_sim

// ------------------
// calc_ascenttime //
// ------------------

void calc_ascenttime(void)
{
if (pres_respiration > pres_surface)
 {
 switch (char_O_deco_status)
  {
  case 2:
	char_O_ascenttime = 255;
	break;
  case 1:
	break;
  default:
	temp1 = pres_respiration - pres_surface + 0.6; // + 0.6 hence 1 minute ascent time from a depth of 4 meter on
	if (temp1 < 0)
		temp1 = 0;
	if (temp1 > 255)
		temp1 = 255;
    char_O_ascenttime = (char)temp1;

	for(ci=0;ci<7;ci++)
	{
	x = char_O_ascenttime + char_O_array_decotime[ci];
	if (x < char_O_ascenttime)
		char_O_ascenttime = 255;
	else
		char_O_ascenttime = x;
	}
  }
 }
else
 char_O_ascenttime = 0;
} // calc_ascenttime()


// ---------------------
// update_startvalues //
// ---------------------
// updated in v.102

void update_startvalues(void)
{
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
   		sim_pres_tissue[x+16] = pres_tissue[x+16];
   		sim_pres_tissue_limit[x] = pres_tissue_limit[x];
  	}
} // update_startvalues


// ------------------
// sim_tissue_1min //
// ------------------
// optimized in v.101

void sim_tissue_1min(void)
{
temp_pres_gtissue_limit = 0.0;
temp_gtissue_no = 255;

_asm
lfsr 1, 0x300
movlw	0x01
movwf	TBLPTRU,0
_endasm


for (ci=0;ci<16;ci++)
{
_asm
movlw	0x02
movwf	TBLPTRH,0
movlb	4 // fuer ci
movf ci,0,1
addwf	ci,0,1
addwf	ci,0,1
addwf	ci,0,1
addlw	0x80
movwf	TBLPTRL,0
TBLRDPOSTINC
movff	TABLAT,var_a+1
TBLRDPOSTINC
movff	TABLAT,var_a
TBLRDPOSTINC
movff	TABLAT,var_a+3
TBLRD
movff	TABLAT,var_a+2
addlw	0x40
movwf	TBLPTRL,0
TBLRDPOSTINC
movff	TABLAT,var2_a+1
TBLRDPOSTINC
movff	TABLAT,var2_a
TBLRDPOSTINC
movff	TABLAT,var2_a+3
TBLRD
movff	TABLAT,var2_a+2
addlw	0x40
movwf	TBLPTRL,0
incf	TBLPTRH,1,0
TBLRDPOSTINC
movff	TABLAT,var_b+1
TBLRDPOSTINC
movff	TABLAT,var_b
TBLRDPOSTINC
movff	TABLAT,var_b+3
TBLRD
movff	TABLAT,var_b+2
addlw	0x40
movwf	TBLPTRL,0
TBLRDPOSTINC
movff	TABLAT,var2_b+1
TBLRDPOSTINC
movff	TABLAT,var2_b
TBLRDPOSTINC
movff	TABLAT,var2_b+3
TBLRD
movff	TABLAT,var2_b+2
addlw	0xC0
movwf	TBLPTRL,0
incf	TBLPTRH,1,0
TBLRDPOSTINC
movff	TABLAT,var_e1min+1
TBLRDPOSTINC
movff	TABLAT,var_e1min
TBLRDPOSTINC
movff	TABLAT,var_e1min+3
TBLRD
movff	TABLAT,var_e1min+2
addlw	0x40
movwf	TBLPTRL,0
TBLRDPOSTINC
movff	TABLAT,var2_e1min+1
TBLRDPOSTINC
movff	TABLAT,var2_e1min
TBLRDPOSTINC
movff	TABLAT,var2_e1min+3
TBLRD
movff	TABLAT,var2_e1min+2
_endasm
// N2
 temp_tissue = (temp_atem - sim_pres_tissue[ci]) * var_e1min;
 temp_tissue_safety();
 sim_pres_tissue[ci] = sim_pres_tissue[ci] + temp_tissue;
// He
 temp_tissue = (temp2_atem - sim_pres_tissue[ci+16]) * var2_e1min;
 temp_tissue_safety();
 sim_pres_tissue[ci+16] = sim_pres_tissue[ci+16] + temp_tissue;
// pressure limit
 temp_tissue = sim_pres_tissue[ci] + sim_pres_tissue[ci+16];
 var_a = (var_a * sim_pres_tissue[ci] + var2_a * sim_pres_tissue[ci+16]) / temp_tissue;
 var_b = (var_b * sim_pres_tissue[ci] + var2_b * sim_pres_tissue[ci+16]) / temp_tissue;
 sim_pres_tissue_limit[ci] = (temp_tissue - var_a) * var_b;

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
} //sim_tissue_1min()

//--------------------
// sim_tissue_10min //
//--------------------

// Attention!! uses var_e1min und var2_e1min to load 10min data !!!
// is identical to sim_tissue_1min routine except for the different load of those variables

// optimized in v.101

void sim_tissue_10min(void)
{
temp_pres_gtissue_limit = 0.0;
temp_gtissue_no = 255;

_asm
lfsr 1, 0x300
movlw	0x01
movwf	TBLPTRU,0
_endasm

for (ci=0;ci<16;ci++)
{
_asm
movlw	0x02
movwf	TBLPTRH,0
movlb	4 // fuer ci
movf ci,0,1
addwf	ci,0,1
addwf	ci,0,1
addwf	ci,0,1
addlw	0x80
movwf	TBLPTRL,0
TBLRDPOSTINC
movff	TABLAT,var_a+1
TBLRDPOSTINC
movff	TABLAT,var_a
TBLRDPOSTINC
movff	TABLAT,var_a+3
TBLRD
movff	TABLAT,var_a+2
addlw	0x40
movwf	TBLPTRL,0
TBLRDPOSTINC
movff	TABLAT,var2_a+1
TBLRDPOSTINC
movff	TABLAT,var2_a
TBLRDPOSTINC
movff	TABLAT,var2_a+3
TBLRD
movff	TABLAT,var2_a+2
addlw	0x40
movwf	TBLPTRL,0
incf	TBLPTRH,1,0
TBLRDPOSTINC
movff	TABLAT,var_b+1
TBLRDPOSTINC
movff	TABLAT,var_b
TBLRDPOSTINC
movff	TABLAT,var_b+3
TBLRD
movff	TABLAT,var_b+2
addlw	0x40
movwf	TBLPTRL,0
TBLRDPOSTINC
movff	TABLAT,var2_b+1
TBLRDPOSTINC
movff	TABLAT,var2_b
TBLRDPOSTINC
movff	TABLAT,var2_b+3
TBLRD
movff	TABLAT,var2_b+2
addlw	0xC0				// different to 1 min
movwf	TBLPTRL,0
incf	TBLPTRH,1,0
incf	TBLPTRH,1,0			// different to 1 min
TBLRDPOSTINC
movff	TABLAT,var_e1min+1
TBLRDPOSTINC
movff	TABLAT,var_e1min
TBLRDPOSTINC
movff	TABLAT,var_e1min+3
TBLRD
movff	TABLAT,var_e1min+2
addlw	0x40
movwf	TBLPTRL,0
//incf	TBLPTRH,1,0			// different to 1 min
TBLRDPOSTINC
movff	TABLAT,var2_e1min+1
TBLRDPOSTINC
movff	TABLAT,var2_e1min
TBLRDPOSTINC
movff	TABLAT,var2_e1min+3
TBLRD
movff	TABLAT,var2_e1min+2
_endasm
// N2
 temp_tissue = (temp_atem - sim_pres_tissue[ci]) * var_e1min;
 temp_tissue_safety();
 sim_pres_tissue[ci] = sim_pres_tissue[ci] + temp_tissue;
// He
 temp_tissue = (temp2_atem - sim_pres_tissue[ci+16]) * var2_e1min;
 temp_tissue_safety();
 sim_pres_tissue[ci+16] = sim_pres_tissue[ci+16] + temp_tissue;
// pressure limit
temp_tissue = sim_pres_tissue[ci] + sim_pres_tissue[ci+16];
 var_a = (var_a * sim_pres_tissue[ci] + var2_a * sim_pres_tissue[ci+16]) / temp_tissue;
 var_b = (var_b * sim_pres_tissue[ci] + var2_b * sim_pres_tissue[ci+16]) / temp_tissue;

sim_pres_tissue_limit[ci] = (temp_tissue - var_a) * var_b;
 if (sim_pres_tissue_limit[ci] < 0)
  sim_pres_tissue_limit[ci] = 0;
 if (sim_pres_tissue_limit[ci] > temp_pres_gtissue_limit)
  {
  temp_pres_gtissue = temp_tissue;
  temp_pres_gtissue_limit = sim_pres_tissue_limit[ci];
  temp_gtissue_no = ci;
  }
} // for
  	temp_pres_gtissue_diff = temp_pres_gtissue_limit - temp_pres_gtissue;							// negative number
	temp_pres_gtissue_limit_GF_low = GF_low * temp_pres_gtissue_diff + temp_pres_gtissue;
  	temp_pres_gtissue_limit_GF_low_below_surface = temp_pres_gtissue_limit_GF_low - pres_surface;
	if (temp_pres_gtissue_limit_GF_low_below_surface < 0)
		temp_pres_gtissue_limit_GF_low_below_surface = 0;
} //sim_tissue_10min()


// ------------------
// clear_decoarray //
// ------------------
// unchanged in v.101

void clear_decoarray(void)
{
char_O_array_decodepth[0] = 0;
char_O_array_decodepth[1] = 0;
char_O_array_decodepth[2] = 0;
char_O_array_decodepth[3] = 0;
char_O_array_decodepth[4] = 0;
char_O_array_decodepth[5] = 0;
char_O_array_decotime[0] = 0;
char_O_array_decotime[1] = 0;
char_O_array_decotime[2] = 0;
char_O_array_decotime[3] = 0;
char_O_array_decotime[4] = 0;
char_O_array_decotime[5] = 0;
char_O_array_decotime[6] = 0;
} // clear_decoarray


// -------------------
// update_decoarray //
// -------------------
// unchanged in v.101

void update_decoarray()
{
	x = 0;
	do
	{
		if (char_O_array_decodepth[x] == temp_depth_limit)
		{
			int_temp = char_O_array_decotime[x] + temp_decotime;
			if (int_temp < 0)
				int_temp = 0;
			if (int_temp > 240)
				int_temp = 240;
 			char_O_array_decotime[x] = int_temp;
			x = 10; // exit
		} // if
		else
 		{
 			if (char_O_array_decodepth[x] == 0)
  			{
  				if (temp_depth_limit > 255)
   					char_O_array_decodepth[x] = 255;
  				else
   					char_O_array_decodepth[x] = (char)temp_depth_limit;
  				int_temp = char_O_array_decotime[x] + temp_decotime;
  				if (int_temp > 240)
   					char_O_array_decotime[x] = 240;
  				else
   					char_O_array_decotime[x] = (char)int_temp;
  				x = 10; // exit
  			} // if
 			else
  				x++;
 		} // else
	} while (x<6);
	if (x == 6)
 	{
 		int_temp = char_O_array_decotime[6] + temp_decotime;
 		if (int_temp > 220)
  			char_O_array_decotime[6] = 220;
 		else
  			char_O_array_decotime[6] = (char)int_temp;
 	} // if x == 6
} // update_decoarray


// -----------------------
// calc_gradient_factor //
// -----------------------
// optimized in v.101 (var_a)
// new code in v.102

void calc_gradient_factor(void)
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
} // calc_gradient

// ---------------------------
// calc_gradient_array_only //
// ---------------------------
// optimized in v.101 (var_a)
// new code in v.102

void calc_gradient_array_only()
{
 pres_respiration = (float)int_I_pres_respiration / 1000.0; // assembler code uses different digit system
for (ci=0;ci<16;ci++)
{
	temp_tissue = pres_tissue[ci] + pres_tissue[ci+16];
	temp1 = temp_tissue - pres_respiration;
	temp2 = temp_tissue - pres_tissue_limit[ci];
	temp2 = temp1/temp2;
	temp2 = temp2 * 200; // because of output in (Double-)percentage
	if (temp2 < 0)
		temp2 = 0;
	if (temp2 > 255)
		temp2 = 255;
	if (temp1 < 0)
 		char_O_array_gradient_weighted[ci] = 0;
	else
 		char_O_array_gradient_weighted[ci] = (char)temp2;
} // for
} // calc_gradient_array_only


// -------------------------
// calc_desaturation_time //
// -------------------------
// FIXED N2_ratio
// unchanged in v.101

void calc_desaturation_time(void)
{
_asm
lfsr 1, 0x300
movlw	0x01
movwf	TBLPTRU,0
_endasm
 N2_ratio = 0.7902; // FIXED sum as stated in b"uhlmann
 pres_surface = (float)int_I_pres_surface / 1000.0;
 temp_atem = N2_ratio * (pres_surface - 0.0627);
 int_O_desaturation_time = 0;
 float_desaturation_multiplier = char_I_desaturation_multiplier / 142.0; // new in v.101	(70,42%/100.=142)

for (ci=0;ci<16;ci++)
{
_asm
movlw	0x04
movwf	TBLPTRH,0
movlb	4 // fuer ci
movf ci,0,1
addwf	ci,0,1
addwf	ci,0,1
addwf	ci,0,1
addlw	0x80
movwf	TBLPTRL,0
TBLRDPOSTINC
movff	TABLAT,var_halftimes+1
TBLRDPOSTINC
movff	TABLAT,var_halftimes
TBLRDPOSTINC
movff	TABLAT,var_halftimes+3
TBLRD
movff	TABLAT,var_halftimes+2
addlw	0x40
movwf	TBLPTRL,0
TBLRDPOSTINC
movff	TABLAT,var2_halftimes+1
TBLRDPOSTINC
movff	TABLAT,var2_halftimes
TBLRDPOSTINC
movff	TABLAT,var2_halftimes+3
TBLRD
movff	TABLAT,var2_halftimes+2
_endasm

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
	temp2 = var_halftimes * temp1 / float_desaturation_multiplier; // time necessary (in minutes ) for complete desaturation (see comment about 10 percent) , new in v.101: float_desaturation_multiplier
	}
 else
	{
	temp1 = 0;
	temp2 = 0;
	}

// He
 temp3 = 0.1 - pres_tissue[ci+16];
if (temp3 >= 0.0)
	{
	temp3 = 0;
	temp4 = 0;
	}
 else
    temp3 = -1.0 * temp3 / pres_tissue[ci+16];
  if (temp3 > 0.0)
	{
	temp3 = log(1.0 - temp3);
	temp3 = temp3 / -0.6931; // temp1 is the multiples of half times necessary.
							 // 0.6931 is ln(2), because the math function log() calculates with a base of e  not 2 as requested.
							 // minus because log is negative
	temp4 = var2_halftimes * temp3 / float_desaturation_multiplier; // time necessary (in minutes ) for "complete" desaturation, new in v.101 float_desaturation_multiplier
	}
 else
	{
	temp3 = 0;
	temp4 = 0;
	}

// saturation_time (for flight)
 if (temp4 > temp2)
	 int_temp = (int)temp4;
 else
	 int_temp = (int)temp2;
 if(int_temp > int_O_desaturation_time)
	int_O_desaturation_time = int_temp;

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
 char_O_tissue_saturation[ci+16] = (char)temp4;
} // for
} // calc_desaturation_time


// --------------------------
// calc_wo_deco_step_1_min //
// --------------------------
// FIXED N2 Ratio
// optimized in v.101 (...saturation_multiplier)
// desaturation slowed down to 70,42%

void calc_wo_deco_step_1_min(void)
{
	if(flag_in_divemode)
	{
		flag_in_divemode = 0;
		set_dbg_end_of_dive();
	}
_asm
 lfsr 1, 0x300
_endasm
 N2_ratio = 0.7902; // FIXED, sum lt. buehlmann
 pres_respiration = (float)int_I_pres_respiration / 1000.0; // assembler code uses different digit system
 pres_surface = (float)int_I_pres_surface / 1000.0;
 temp_atem = N2_ratio * (pres_respiration - 0.0627); // 0.0627 is the extra pressure in the body
 temp2_atem = 0.0;
 temp_surface = pres_surface; // the b"uhlmann formula using temp_surface does not use the N2_ratio
 float_desaturation_multiplier = char_I_desaturation_multiplier / 142.0; // new in v.101	(70,42%/100.=142)
 float_saturation_multiplier = char_I_saturation_multiplier / 100.0;

 calc_tissue_step_1_min();  // update the pressure in the 16 tissues in accordance with the new ambient pressure
 clear_decoarray();
 char_O_deco_status = 0;
 char_O_nullzeit = 0;
 char_O_ascenttime = 0;
 calc_gradient_factor();

} // calc_wo_deco_step_1_min(void)


// -------------------------
// calc_tissue_step_1_min //
// -------------------------
// optimized in v.101

void calc_tissue_step_1_min(void)
{
_asm
lfsr 1, 0x300
movlw	0x01
movwf	TBLPTRU,0
_endasm

 char_O_gtissue_no = 255;
 pres_gtissue_limit = 0.0;

for (ci=0;ci<16;ci++)
{
_asm
movlw	0x02
movwf	TBLPTRH,0
movlb	4 // fuer ci
movf ci,0,1
addwf	ci,0,1
addwf	ci,0,1
addwf	ci,0,1
addlw	0x80
movwf	TBLPTRL,0
TBLRDPOSTINC
movff	TABLAT,var_a+1
TBLRDPOSTINC
movff	TABLAT,var_a
TBLRDPOSTINC
movff	TABLAT,var_a+3
TBLRD
movff	TABLAT,var_a+2
addlw	0x40
movwf	TBLPTRL,0
TBLRDPOSTINC
movff	TABLAT,var2_a+1
TBLRDPOSTINC
movff	TABLAT,var2_a
TBLRDPOSTINC
movff	TABLAT,var2_a+3
TBLRD
movff	TABLAT,var2_a+2
addlw	0x40
movwf	TBLPTRL,0
incf	TBLPTRH,1,0
TBLRDPOSTINC
movff	TABLAT,var_b+1
TBLRDPOSTINC
movff	TABLAT,var_b
TBLRDPOSTINC
movff	TABLAT,var_b+3
TBLRD
movff	TABLAT,var_b+2
addlw	0x40
movwf	TBLPTRL,0
TBLRDPOSTINC
movff	TABLAT,var2_b+1
TBLRDPOSTINC
movff	TABLAT,var2_b
TBLRDPOSTINC
movff	TABLAT,var2_b+3
TBLRD
movff	TABLAT,var2_b+2
addlw	0xC0
movwf	TBLPTRL,0
incf	TBLPTRH,1,0
TBLRDPOSTINC
movff	TABLAT,var_e1min+1
TBLRDPOSTINC
movff	TABLAT,var_e1min
TBLRDPOSTINC
movff	TABLAT,var_e1min+3
TBLRD
movff	TABLAT,var_e1min+2
addlw	0x40
movwf	TBLPTRL,0
TBLRDPOSTINC
movff	TABLAT,var2_e1min+1
TBLRDPOSTINC
movff	TABLAT,var2_e1min
TBLRDPOSTINC
movff	TABLAT,var2_e1min+3
TBLRD
movff	TABLAT,var2_e1min+2
_endasm

// N2 1 min
 temp_tissue = (temp_atem - pres_tissue[ci]) * var_e1min;
 temp_tissue_safety();
 pres_tissue[ci] = pres_tissue[ci] + temp_tissue;

// He 1 min
 temp_tissue = (temp2_atem - pres_tissue[ci+16]) * var2_e1min;
 temp_tissue_safety();
 pres_tissue[ci+16] = pres_tissue[ci+16] + temp_tissue;

 temp_tissue = pres_tissue[ci] + pres_tissue[ci+16];
 var_a = (var_a * pres_tissue[ci] + var2_a * pres_tissue[ci+16]) / temp_tissue;
 var_b = (var_b * pres_tissue[ci] + var2_b * pres_tissue[ci+16]) / temp_tissue;
 pres_tissue_limit[ci] = (temp_tissue - var_a) * var_b;
 if (pres_tissue_limit[ci] < 0)
  pres_tissue_limit[ci] = 0;
 if (pres_tissue_limit[ci] > pres_gtissue_limit)
  {
  pres_gtissue_limit = pres_tissue_limit[ci];
  char_O_gtissue_no = ci;
  }//if

// gradient factor array for graphical display
// display range is 0 to 250! in steps of 5 for 1 pixel
// the display is divided in 6 blocks
// -> double the gradient 100% = 200
// tissue > respiration (entsaettigungsvorgang)
// gradient ist wieviel prozent an limit von tissue aus
// dh. 0% = respiration == tissue
// dh. 100% = respiration == limit
temp1 = temp_tissue - pres_respiration;
temp2 = temp_tissue - pres_tissue_limit[ci];	// changed in v.102
temp2 = temp1/temp2;
temp2 = temp2 * 200; // because of output in (Double-)percentage
if (temp2 < 0)
	temp2 = 0;
if (temp2 > 255)
	temp2 = 255;
if (temp1 < 0)
 char_O_array_gradient_weighted[ci] = 0;
else
 char_O_array_gradient_weighted[ci] = (char)temp2;

} // for
} // calc wo deco 1min

#if 0
// --------
// debug //
// --------
void debug(void)
{
for (ci=0;ci<32;ci++)
{
 int_O_tissue_for_debug[ci] = (unsigned int)(pres_tissue[ci] *1000);
}
} // void debug(void)
#endif

// ----------
// md hash //
// ----------
void hash(void)
{
// init
 for (md_i=0;md_i<16;md_i++)
 {
  md_state[md_i] = 0;
  md_cksum[md_i] = 0;
 } // for md_i 16

_asm
 movlw	0x01
 movwf	TBLPTRU,0
 movlw	0x06
 movwf	TBLPTRH,0
 movlw	0x00
 movwf	TBLPTRL,0
_endasm
 for (md_i=0;md_i<127;md_i++)
 {
_asm
 TBLRDPOSTINC
 movff	TABLAT,md_temp
_endasm
  md_pi_subst[md_i] = md_temp;
 } // for md_i 256
_asm
 TBLRDPOSTINC
 movff	TABLAT,md_temp
_endasm
  md_pi_subst[127] = md_temp;
 for (md_i=0;md_i<127;md_i++)
 {
_asm
 TBLRDPOSTINC
 movff	TABLAT,md_temp
_endasm
  md_pi_subst[md_i+128] = md_temp;
 } // for md_i 256
_asm
 TBLRD
 movff	TABLAT,md_temp
_endasm
  md_pi_subst[255] = md_temp;

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
   md_temp = md_cksum[md_i];
  else
  {
_asm
  TBLRDPOSTINC
  movff	TABLAT,md_temp
_endasm
  } // else
  md_buffer[md_i] = md_temp;
  md_state[md_i+16] = md_buffer[md_i];
  md_state[md_i+32] = (unsigned char)(md_buffer[md_i] ^ md_state[md_i]);
 } // for md_i 16

 for (md_i=0;md_i<18;md_i++)
 {
  for (md_j=0;md_j<48;md_j++)
  {
   md_state[md_j] = (unsigned char)(md_state[md_j] ^ md_pi_subst[md_t]);
   md_t = md_state[md_j];
  } // for md_j 48
  md_t = (unsigned char)(md_t+1);
 } // for md_i 18
 md_t = md_cksum[15];

 for (md_i=0;md_i<16;md_i++)
 {
  md_cksum[md_i] = (unsigned char)(md_cksum[md_i] ^ md_pi_subst[(md_buffer[md_i] ^ md_t)]);
  md_t = md_cksum[md_i];
 } // for md_i 16
} // for md_pointer
} // void hash(void)

// ---------------------
// clear_CNS_fraction //
// ---------------------
// new in v.101

void clear_CNS_fraction(void)
{
 CNS_fraction = 0.0;
 char_O_CNS_fraction = 0;
} // void clear_CNS_fraction(void)


// --------------------
// calc_CNS_fraction //
// --------------------
// new in v.101
// optimized in v.102 : with new variables char_I_actual_ppO2 and actual_ppO2

// Input: char_I_actual_ppO2
// Output: char_O_CNS_fraction
// Uses and Updates: CNS_fraction
// Uses: acutal_ppO2

void calc_CNS_fraction(void)
{
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
} // void calc_CNS_fraction(void)

// --------------------------
// calc_CNS_decrease_15min //
// --------------------------
// new in v.101

// calculates the half time of 90 minutes in 6 steps of 15 min

// Output: char_O_CNS_fraction
// Uses and Updates: CNS_fraction

void calc_CNS_decrease_15min(void)
{
 CNS_fraction =  0.890899 * CNS_fraction;
 char_O_CNS_fraction = (char)((CNS_fraction + 0.005)* 100.0);
}// calc_CNS_decrease_15min(void)


// ------------------
// calc_percentage //
// ------------------
// new in v.101

// calculates int_I_temp * char_I_temp / 100
// output is int_I_temp

void calc_percentage(void)
{
 temp1 = (float)int_I_temp;
 temp2 = (float)char_I_temp / 100.0;
 temp3 = temp1 * temp2;
 int_I_temp = (int)temp3;
}
void push_tissues_to_vault(void)
{
	for (ci=0;ci<32;ci++)
		pres_tissue_vault[ci] = pres_tissue[ci];
}
void pull_tissues_from_vault(void)
{
	for (ci=0;ci<32;ci++)
		pres_tissue[ci] = pres_tissue_vault[ci];
}

void wp_write_command(void)
{
	_asm
		bcf		oled_rs
		movff	wp_command,PORTD
		bcf		oled_rw
		bsf		oled_rw
	_endasm
}

void wp_write_data(void)
{
	wp_data_8bit_one = wp_data_16bit >> 8;
	wp_data_8bit_two = wp_data_16bit;
_asm
	bsf		oled_rs
	movff	wp_data_8bit_one,PORTD
	bcf		oled_rw
	bsf		oled_rw
	movff	wp_data_8bit_two,PORTD
	bcf		oled_rw
	bsf		oled_rw
_endasm
}

void wp_write_black(void)
{
_asm
	movff	wp_black,PORTD
	bcf		oled_rw
	bsf		oled_rw
	bcf		oled_rw
	bsf		oled_rw
_endasm
}

void wp_write_color(void)
{
_asm
	movff	wp_color1,PORTD
	bcf		oled_rw
	bsf		oled_rw
	movff	wp_color2,PORTD
	bcf		oled_rw
	bsf		oled_rw
_endasm
}

void wp_set_window(void)
{
	// x axis start ( 0 - 319)
	wp_command = 0x35;
	wp_write_command();
	wp_data_16bit = ((U16)wp_leftx2) << 1;
	wp_write_data();
	// x axis end ( 0 - 319)
	wp_command = 0x36;
	wp_write_command();
	wp_data_16bit = 319;
	wp_write_data();
	// y axis start + end ( 0 - 239 )
	wp_command = 0x37;
	wp_write_command();
	// the bottom part
	wp_data_16bit = wp_top;
	if(wp_font == 2)
		wp_data_16bit += WP_FONT_LARGE_HEIGHT;
	else if(wp_font == 1)
		wp_data_16bit += WP_FONT_MEDIUM_HEIGHT;
	else
		wp_data_16bit += WP_FONT_SMALL_HEIGHT;
	wp_data_16bit--;
	if(wp_data_16bit > 239)
		wp_data_16bit = 239;
	// the top part
	wp_data_16bit |= ((U16)wp_top) << 8;
	// all together in one 16bit transfer
	wp_write_data();

	// start
	wp_command = 0x20;
	wp_write_command();
	wp_data_16bit = wp_top;
	wp_write_data();

	wp_command = 0x21;
	wp_write_command();
	wp_data_16bit = ((U16)wp_leftx2) << 1;
	wp_write_data();
}

void wp_set_char_font_small(void)
{
	// space is A1
	if (wp_char > 0x7E) // skip space between ~ and ¡
		wp_char -= 34;

	if (wp_char == ' ')
		wp_char = 0xA1;

	if((wp_char < '!') || (wp_char > 0xA1)) // font has 34 chars after ~ // ¾ + 4 chars limit to end of battery at the moment
		wp_char = 0x82;	// ¤

	wp_start = wp_small_table[wp_char - '!'];
	wp_end = wp_small_table[1 + wp_char - '!'];
}

void wp_set_char_font_medium(void)
{
	// space is 3E
	if (wp_char == 0x27) // 0x27 == '
		wp_char = 0x3B;
	if (wp_char == '"')
		wp_char = 0x3C;
	if (wp_char == 'm')
		wp_char = 0x3D;
	if (wp_char == ' ')
		wp_char = 0x3E;

	if((wp_char < '.') || (wp_char > 0x3E))
		wp_char = 0x3E;
	wp_start = wp_medium_table[wp_char - '.'];
	wp_end = wp_medium_table[1 + wp_char - '.'];
}

void wp_set_char_font_large(void)
{
	// space is / = 0x2F
	if (wp_char == ' ')
		wp_char = 0x2F;

	if((wp_char < '.') || (wp_char > '9'))
		wp_char = 0x2F;
	wp_start = wp_large_table[wp_char - '.'];
	wp_end = wp_large_table[1 + wp_char - '.'];
}

void wordprocessor(void)
{
	wp_set_window();

	// access to GRAM
	wp_command = 0x22;
	wp_write_command();
	_asm
		bsf		oled_rs
	_endasm

	wp_txtptr = 0;
	wp_char = wp_stringstore[wp_txtptr];

	while(wp_char)
	{
		if(wp_font == 2)
			wp_set_char_font_large();
		else if(wp_font == 1)
			wp_set_char_font_medium();
		else
			wp_set_char_font_small();

		wp_black = 0;

			for(wp_i = wp_start; wp_i<wp_end;wp_i++)
			{
				if(wp_font == 2)
					wp_data_16bit = wp_large_data[wp_i / 2];
				else if(wp_font == 1)
					wp_data_16bit = wp_medium_data[wp_i / 2];
				else
					wp_data_16bit = wp_small_data[wp_i / 2];
				if(wp_i & 1)
					wp_temp_U8 = wp_data_16bit & 0xFF;
				else
					wp_temp_U8 = wp_data_16bit >> 8;
				if((wp_temp_U8 & 128))
				{
					wp_temp_U8 -= 127;
					if(wp_invert)
					{
						while(wp_temp_U8 > 0)
						{
							wp_temp_U8--;
							wp_write_color();
						}
					}
					else
					{
						_asm
							movff	wp_black,PORTD
						_endasm
						while(wp_temp_U8 > 0)
						{
							wp_temp_U8--;
							_asm
								bcf		oled_rw
								bsf		oled_rw
								bcf		oled_rw
								bsf		oled_rw
							_endasm
						}
					}
				}
				else
				{
					wp_temp_U8++;
					if(wp_invert)
					{
						_asm
							movff	wp_black,PORTD
						_endasm
						while(wp_temp_U8 > 0)
						{
							wp_temp_U8--;
							_asm
								bcf		oled_rw
								bsf		oled_rw
								bcf		oled_rw
								bsf		oled_rw
							_endasm
						}
					}
					else
					{
						while(wp_temp_U8 > 0)
						{
							wp_temp_U8--;
							wp_write_color();
						}
					}
				}
			}
		wp_txtptr++;
		wp_char = wp_stringstore[wp_txtptr];
	}
	wp_command = 0x00;
	wp_write_command();
	wp_top = 0;
	wp_leftx2 = 0;
	wp_font = 0;
	wp_invert = 0;
}

