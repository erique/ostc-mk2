// **************************************************************
// ** main code for simulation / tests without assembler code  **
// ** This is NOT a part of the OSTC                           **
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
// history:
// 12/25/10 v110: [jDG] split in three files (deco.c, main.c, definitions.h)

#include <p18f4685.h>
#include <stdlib.h>

#include "p2_definitions.h"

// **************************************************
// ** Make sure to freeze ram banks used elsewhere **
// **************************************************

#pragma udata bank0=0x060
static const unsigned char keep_free_bank0[0xA0];   // used by the assembler code

#pragma udata bank1=0x100
static const unsigned char keep_free_bank1[256];    // used by the assembler code

#pragma udata bank7=0x700
const unsigned char keep_free_bank7[256];           // used by the assembler code (DD font2display)

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

// *************************
// ** P R O T O T Y P E S **
// *************************

void main(void);

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

#pragma code main = 0x9000
#pragma udata
void main(void)
{
    static unsigned int i;
    static unsigned int debug_temp;
   
#if 1
// new main to test DR-5

char_I_deco_model = 0;

char_I_GF_Low_percentage = 100;
char_I_GF_High_percentage = 100;

deco_clear_CNS_fraction();
//char_I_const_ppO2 = 100;
//for (i=0;i<255;i++)
//{
//calc_CNS_fraction();
//} //for

int_I_pres_respiration = 1000;//980;
int_I_pres_surface = 1000;//980;
char_I_N2_ratio = 79; //38;
char_I_He_ratio = 0; //50;
char_I_deco_distance = 10; // 10 = 1 meter
char_I_depth_last_deco = 3;	// values below 3 (meter) are ignored

char_I_const_ppO2 = 0;
char_I_deco_ppO2_change = 0; // [dm] 10 = 1 meter
char_I_deco_ppO2 = 0;

char_I_deco_gas_change = 20; // [m] 1 = 1 meter
char_I_deco_N2_ratio = 50;
char_I_deco_He_ratio = 0;

char_I_deco_gas_change2 = 6; // [m] 1 = 1 meter
char_I_deco_N2_ratio2 = 0;
char_I_deco_He_ratio2 = 0;

char_I_deco_gas_change3 = 0; // [m] 1 = 1 meter
char_I_deco_gas_change4 = 0; // [m] 1 = 1 meter
char_I_deco_gas_change5 = 0; // [m] 1 = 1 meter

//char_I_actual_ppO2;					// 0x507
char_I_GF_High_percentage = 100;			// 0x514	new in v.102
char_I_GF_Low_percentage = 100;			// 0x515	new in v.102

char_I_saturation_multiplier = 110;
char_I_desaturation_multiplier = 90;
calc_hauptroutine_data_input();

deco_clear_tissue();

char_I_step_is_1min = 1;
int_I_pres_respiration = 4500 + int_I_pres_surface;

for (i=0;i<29;i++)
{
    deco_calc_hauptroutine();
}

char_I_step_is_1min = 0;
char_O_deco_status = 255;
while (char_O_deco_status)
	deco_calc_hauptroutine();
_asm
nop
_endasm

char_O_deco_status = 255;
while (char_O_deco_status)
	deco_calc_hauptroutine();
_asm
nop
_endasm

int_I_pres_respiration = 10000;
for (i=0;i<1500;i++)
{
    deco_calc_hauptroutine();
}

_asm
nop
_endasm


int_I_pres_respiration = 3000;
for (i=0;i<150;i++)
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
for (i=0;i<debug_temp;i++)
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
for (i=0;i<debug_temp;i++)
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
