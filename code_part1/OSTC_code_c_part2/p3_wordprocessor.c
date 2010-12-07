/*
 * 		OSTC - diving computer code
 *		===========================
 *		PART 3 :  word processor
 *
 * 		p3_wordprocessor.c for OSTC Mk.2
 *  	Created on: 17.09.2009
 *      Author: christian.w @ heinrichsweikamp.com
 *
 *		#include "ostc28.drx.txt"
 *      #include "ostc28.tbl.txt"
 *      #include "ostc48.tbl.txt"
 *      #include "ostc48.drx.txt"
 *      #include "ostc90.drx.txt"
 *      #include "ostc90.tbl.txt"
 */

// 		Copyright (C) 2009 HeinrichsWeikamp GbR

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
//
// summary:
// display routines
// for the OSTC experimental project
// written by Christian Weikamp
// last revision __________
// comments added _________
//
// additional files:
// #include "ostc28.drx.txt"
// #include "ostc28.tbl.txt"
// #include "ostc48.tbl.txt"
// #include "ostc48.drx.txt"
// #include "ostc90.drx.txt"
// #include "ostc90.tbl.txt"
// assembler code (PART 1) for working OSTC experimental plattform
// C code (PART 2) for working OSTC experimental plattform
//
// history:
// 2010-12-1 : jDG Cleanups to a tighter code.


// *********************
// ** I N C L U D E S **
// *********************
 #include <p18f4685.h>

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

#define	WP_FONT_SMALL_HEIGHT	 24
#define	WP_FONT_MEDIUM_HEIGHT	 32
#define	WP_FONT_LARGE_HEIGHT	 58
#define oled_rw	PORTA,2,0
#define oled_rs	PORTE,0,0

// ***********************
// ** V A R I A B L E S **
// ***********************

#pragma udata bank0a=0x060
// input
volatile unsigned char wp_stringstore[26];
volatile unsigned int  wp_color;
volatile unsigned char wp_top;
volatile unsigned char wp_leftx2;
volatile unsigned char wp_font;
volatile unsigned char wp_invert;
// internal
volatile unsigned char wp_temp_U8;
volatile unsigned char wp_txtptr;
volatile unsigned char wp_char;
volatile unsigned char	wp_command;
volatile unsigned int	wp_data_16bit;
volatile unsigned int	wp_start;
volatile unsigned int	wp_end;
volatile unsigned int	wp_i;
volatile unsigned char	wp_debug_U8;

// Temporary used only inside the wordprocessor.c module
static unsigned int wp_string_width = 0;


// *************************
// ** P R O T O T Y P E S **
// *************************
void main(void);

void main_calc_wordprocessor(void);

void wp_write_command(void);
void wp_write_data(void);
void wp_set_window(void);
void wp_set_char_font_small(void);
void wp_set_char_font_medium(void);
void wp_set_char_font_large(void);
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
	wp_top = 10;
	wp_leftx2 = 10;
	wp_color  = 0xFFFF;
	wp_font   = 0;
	wp_invert = 0;
	wp_stringstore[0] = ' ';
	wp_stringstore[1] = '!';
	wp_stringstore[2] = '"';
	wp_stringstore[3] = ':';
	wp_stringstore[4] = 0;
	wordprocessor();
}

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
rom const rom unsigned int wp_large_data[] =
{
#include "ostc90.drx.txt" // length 0x59A
};
#pragma romdata font_table_large = 0x09FA0
rom const rom unsigned int wp_large_table[] =
{
#include "ostc90.tbl.txt" // length 0x18
};
#pragma romdata font_table_medium = 0x0A000
rom const rom unsigned int wp_medium_table[] =
{
#include "ostc48.tbl.txt" // length 0x22
};
#pragma romdata font_data_medium = 0x0A024
rom const rom unsigned int wp_medium_data[] =
{
#include "ostc48.drx.txt" // length 0x374 // geht bis einschl. 0xA398
};
#pragma romdata font_table_small = 0x0A39A
rom const rom unsigned int wp_small_table[] =
{
#include "ostc28.tbl.txt" // length 0xE8
};
#pragma romdata font_data_small = 0x0A488
rom const rom unsigned int wp_small_data[] =
{
#include "ostc28.drx.txt"
};

// **********************
// **********************
// ** THE JUMP-IN CODE **
// ** for the asm code **
// **********************
// **********************
#pragma code main_wordprocessor = 0x0B468
void main_wordprocessor(void)
{
	_asm
	goto	wordprocessor
	_endasm
}

// *********************
// *********************
// ** THE SUBROUTINES **
// *********************
// *********************

#pragma code subroutines2 = 0x0B470	// can be adapted to fit the romdata tables ahead

// ------------
// write new //
// ------------

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
_asm
	bsf		oled_rs
	movff	wp_data_16bit+1,PORTD	// OLED commands are big endian...
	bcf		oled_rw
	bsf		oled_rw
	movff	wp_data_16bit+0,PORTD
	bcf		oled_rw
	bsf		oled_rw
_endasm
}

//////////////////////////////////////////////////////////////////////////////

void wp_char_width(void)
{
	wp_string_width = 0;
	for(wp_txtptr = 0; wp_txtptr < 26; wp_txtptr++)
	{
		wp_char = wp_stringstore[wp_txtptr];
		if( wp_char == 0 ) break;

		if(wp_font == 2)
			wp_set_char_font_large();
		else if(wp_font == 1)
			wp_set_char_font_medium();
		else
			wp_set_char_font_small();

		for(wp_i = wp_start; wp_i<wp_end;wp_i++)
		{
			wp_data_16bit = wp_i ^ 1;
			if(wp_font == 2)
				wp_temp_U8 = ((rom unsigned char*)wp_large_data)[wp_data_16bit];
			else if(wp_font == 1)
				wp_temp_U8 = ((rom unsigned char*)wp_medium_data)[wp_data_16bit];
			else
				wp_temp_U8 = ((rom unsigned char*)wp_small_data)[wp_data_16bit];

			wp_temp_U8 = 1 + (wp_temp_U8 & 127);
			wp_string_width += wp_temp_U8;
		}
	}

	if(wp_font == 2)
		wp_string_width /= WP_FONT_LARGE_HEIGHT;
	else if(wp_font == 1)
		wp_string_width /= WP_FONT_MEDIUM_HEIGHT;
	else
		wp_string_width /= WP_FONT_SMALL_HEIGHT;
}

//////////////////////////////////////////////////////////////////////////////

void wp_set_window(void)
{
	// Compute string width (in pixels)
	wp_char_width();

	// x axis start ( 0 - 319)
	wp_command = 0x35;
	wp_write_command();
	wp_data_16bit = ((unsigned int)wp_leftx2) << 1;
	wp_write_data();
	// x axis end ( 0 - 319)
	wp_command = 0x36;
	wp_write_command();
	wp_data_16bit = wp_data_16bit + wp_string_width -1;
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
	wp_data_16bit |= ((unsigned int)wp_top) << 8;
	// all together in one 16bit transfer
	wp_write_data();
	// start
	wp_command = 0x20;
	wp_write_command();
	wp_data_16bit = wp_top;
	wp_write_data();
	wp_command = 0x21;
	wp_write_command();
	wp_data_16bit = ((unsigned int)wp_leftx2) << 1;
	wp_write_data();
}

void wp_set_char_font_small(void)
{
	if(wp_char == ' ')
		wp_char = '¶';
	if (wp_char > 0x7E) // skip space between ~ and ¡
		wp_char -= 34;
	if((wp_char < '!') || (wp_char > 0xA3)) // font has 34 chars after ~ // ¾ + 4 chars limit to end of battery at the moment
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
#define TOPLIMIT 230
#define LEFTLIMIT 155

	if(wp_top > TOPLIMIT)
		wp_top = TOPLIMIT;
	if(wp_leftx2 > LEFTLIMIT)
		wp_leftx2 = LEFTLIMIT;

	// FIX C18 Bug: avoid crash if TBLPTRU was set somewhere...
	// Should be called once before first PROM read, ie. font
	// definition access...
	_asm
	clrf TBLPTRU, ACCESS
	_endasm

	wp_set_window();

	// access to GRAM
	wp_command = 0x22;
	wp_write_command();
	_asm
		bsf		oled_rs
	_endasm

	wp_txtptr = 0;
	wp_char = wp_stringstore[wp_txtptr];

	while( wp_char && (wp_txtptr < 26) )
	{
		if(wp_font == 2)
			wp_set_char_font_large();
		else if(wp_font == 1)
			wp_set_char_font_medium();
		else
			wp_set_char_font_small();

			for(wp_i = wp_start; wp_i<wp_end;wp_i++)
			{
			wp_data_16bit = wp_i ^ 1;
				if(wp_font == 2)
				wp_temp_U8 = ((rom unsigned char*)wp_large_data)[wp_data_16bit];
				else if(wp_font == 1)
				wp_temp_U8 = ((rom unsigned char*)wp_medium_data)[wp_data_16bit];
				else
				wp_temp_U8 = ((rom unsigned char*)wp_small_data)[wp_data_16bit];

			// Manage to get color (or black) into data_16:
			if( wp_invert ) wp_temp_U8 ^= 128;
			if( wp_temp_U8 & 128 )
				wp_data_16bit = 0;
				else
				wp_data_16bit = wp_color;

			// Then send that to screen
			wp_temp_U8 = 1 + (wp_temp_U8 & 127);
			while(wp_temp_U8-- > 0)
					{
						_asm
					// wp selected color
					movff 	wp_data_16bit+1,PORTD	// OLED is big endian. PIC is not.
								bcf		oled_rw
								bsf		oled_rw
					movff 	wp_data_16bit+0,PORTD
								bcf		oled_rw
								bsf		oled_rw
							_endasm
						}
					}

		wp_txtptr++;
		wp_char = wp_stringstore[wp_txtptr];
	}
	wp_command = 0x00;
	wp_write_command();
}
