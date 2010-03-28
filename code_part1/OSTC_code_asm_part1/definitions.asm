; OSTC - diving computer code
; Copyright (C) 2008 HeinrichsWeikamp GbR

;    This program is free software: you can redistribute it and/or modifyn 3 of the License, or
;    (at your option) any later version.

;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.

;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <http://www.gnu.org/licenses/>.


; Defines, I/O Ports and variables
; written by: Matthias Heinrichs, info@heinrichsweikamp.com
; written: 10/30/05
; last updated: 01/23/08
; known bugs:
; ToDo:

;#DEFINE		NO_SENSOR_MODE			; uses Dummy values

#DEFINE	softwareversion_x		d'1'		; Software version  XX.YY
#DEFINE	softwareversion_y		d'54'		; Software version  XX.YY

#DEFINE	max_custom_number		d'41'		; Number of last used custom function

#DEFINE	logbook_profile_version	0x20		; Do not touch!

#DEFINE	T0CON_debounce	b'00000000'					; Timer0 Switch Debounce

#DEFINE		FT_SMALL		.0
#DEFINE		FT_MEDIUM		.1
#DEFINE		FT_LARGE		.2

; Define max. 5 Binary Custom Functions here (add more in menu_custom.asm)
#DEFINE	binary_cf1				d'31'
#DEFINE	binary_cf2				d'38'
#DEFINE	binary_cf3				d'39'
#DEFINE	binary_cf4				d'40'
#DEFINE	binary_cf5				d'41'

#DEFINE wp_fontwidth  .14
#DEFINE wp_fontheight .24

; Color Definitions: 8Bit RGB b'RRRGGGBB'
;#DEFINE	color_red	b'11100000'
#DEFINE	color_blue	b'00000011'
#DEFINE	color_green	b'00011100'
;#DEFINE	color_white b'11111111'
#DEFINE	color_black b'00000000'
#DEFINE	color_deepblue b'00000001'
#DEFINE	color_grey	d'73'

#DEFINE	plus_time_correction	d'42'


;Configuration bits
	CONFIG	OSC = IRCIO67        ;Internal oscillator block, port function on RA6 and RA7
	CONFIG	FCMEN = OFF          ;Fail-Safe Clock Monitor disabled
	CONFIG	IESO = OFF           ;Oscillator Switchover mode disabled

	CONFIG	PWRT = ON            ;PWRT enabled
	CONFIG	BOREN = OFF          ;Brown-out Reset disabled in hardware and software

	CONFIG	WDT = OFF            ;WDT disabled
	CONFIG	WDTPS = 128          ;1:128

	CONFIG	MCLRE = ON           ;MCLR pin enabled; RE3 input pin disabled
	CONFIG	LPT1OSC = OFF        ;Timer1 configured for higher power operation
	CONFIG	PBADEN = OFF         ;PORTB<4> and PORTB<1:0> Configured as Digital I/O Pins on Reset

	CONFIG	DEBUG = OFF          ;Background debugger disabled, RB6 and RB7 configured as general purpose I/O pins
	CONFIG	XINST = OFF          ;Instruction set extension and Indexed Addressing mode disabled (Legacy mode)
	CONFIG	LVP = OFF            ;Single-Supply ICSP disabled
	CONFIG	STVREN = OFF         ;Stack full/underflow will not cause Reset


;Variable definitions
; arrays are in hex size!! 20 = .032

	CBLOCK	0x060				;Bank 0
	letter:.026					;letter buffer
	win_color1
	win_color2
	win_top
	win_leftx2
	win_font
	win_invert
	wp_temp
	ENDC
; the following is used by the C-code up to 0x0E0!!
	CBLOCK	0x0E0				;Bank 0
	ENDC

	CBLOCK	0x100				;Bank 1
	wreg_temp					;variables used for context saving during ISR 
	status_temp					
	bsr_temp					

	secs						;realtime clock
	mins
	hours
	day
	month
	year

	waitms_temp					;variables required for wait routines
	wait_temp				 	; " + used to copy data to c code + used for temp/testing
								; never use wait_temp in interrupt routines (isr) and never call any wait routine in interrupts

	textnumber					;for textdisplay and textlookup
	textlength					
	textaddress:2				

	LastSetRow 
	LastSetColumn
	average_depth_hold:4		; Holds Sum of depths
	b0_lo						; Temp (calculate_average)
	b0_hi						; Temp (calculate_average)
	average_divesecs:2			; Used for resetable average depth display
	surface_interval:2			; Surface Interval [mins]
	grayvalue					; 4 Bit Greyvalue

	draw_box_temp1
	draw_box_temp2
	draw_box_temp3
	
	flag1 						;Flag register 
	flag2 
	flag3 
	flag4 
	flag5 ; has to be exacly here, is modified by c-code (no sensor int) 
	flag6 
	flag7 
	flag8
	flag9
	flag10
	flag11
	flag12
	flag13
	flag14
	flag15

	oled1_temp					;Temp variables for display output
	oled2_temp		
	oled3_temp	
	oled4_temp					; Used in "Displaytext"

	lo							;bin to dec conversion routine
	hi
	lo_temp
	hi_temp
	temp3						;								used in valconv math
	temp4						;								used in valconv math
	ignore_digits

	temp1						;Multipurpose Temp variables 	used in valconv math
	temp2						;								used in valconv math

	ext_ee_temp1				; External EEPROM Temp 1		used in I2C EEPROM
	ext_ee_temp2				; External EEPROM Temp 2		used in I2C EEPROM

	isr1_temp					;ISR temp variables
	isr2_temp	
  	isr3_temp:2

	timer1int_counter1			;Timer 1 counter
	timer1int_counter2 			;Timer 1 counter

	uart1_temp					;RS232 temp variables
	uart2_temp

  	divA:2						;math routines
  	divB
	xC:4
	xA:2
	xB:2
  	sub_c:2
  	sub_a:2
  	sub_b:2

	dLSB						;Pressure sensor interface 
	dMSB
	clock_count
	ppO2_setpoint_store			; Actual setpoint
;	temperature_correction		; additional temperature correction value
	W1:2
	W2:2
	W3:2
	W4:2
	C1:2
	C2:2
	C3:2
	C3_temp:2
	C4:2
	C5:2
	C6:2
	D1:2
	D2:2

  	isr_divA:2
 	isr_divB
	isr_xC:4
	isr_xA:2
	isr_xB:2
  	isr_sub_c:2
  	isr_sub_a:2
  	isr_sub_b:2

  	xdT:2
  	xdT2:2
  	OFF:2
  	SENS:2
   	amb_pressure:2					; ambient pressure [mBar]
   	rel_pressure:2					; amb_pressure - surface pressure [mBar]
   	max_pressure:2					; Max. pressure for the dive [mBar]
	avr_rel_pressure:2				; Average rel. pressure (Average depth) for the dive [mBar]
   	last_pressure:2
  	temperature:2
  	last_temperature:2
  	temperature_temp:2
  	Dx:2

	last_surfpressure:2			;Divemode
	last_surfpressure_15min:2
	last_surfpressure_30min:2
	divemins:2					;Minutes
	divesecs					;seconds
	samplesecs					; counts the seconds until the next sample is stored in divemode
	samplesecs_value			; holds the CF20 value
	decodata:2					;Deco data
	mintemp:2					;min temperature
	ProfileFlagByte				; stores number of addional bytes per sample
	EventByte					; Stores the Event type plus flags	
	AlarmType					; 0= No Alarm
								; 1= SLOW
								; 2= DecoStop missed
								; 3= DeepStop missed
								; 4= ppO2 Low Warning
								; 5= ppO2 High Warning
								; 6= manual marker

	divisor_temperature			; divisors for profile storage
	divisor_deco
	divisor_tank
	divisor_ppo2
	divisor_deco_debug
	divisor_nuy2

	timeout_counter				;Timeout counter variables
	timeout_counter2
	timeout_counter3			;pre-menu timeout counter

	menupos						;cursor position
	menupos2
	menupos3

	eeprom_address:2			;external EEPROM
	eeprom_header_address:2

	divenumber					;Logbook

	batt_voltage:2				;Battery voltage in mV

	i2c_temp					;I²C timeout counter
	i2c_temp2

	sim_pressure:2				; hold simulated pressure in mBar if in Simulator mode

	profile_temp:2				; temp variable for profile view
	profile_temp2:2				; temp variable for profile view
	
	nofly_time:2				; No Fly time in Minutes (Calculated after Dive)
	
	deco_status					; =0 if decompression calculation done

	cf_checker_counter			; counts custom functions to check for warning symbol
	
	char_I_O2_ratio				; 02 ratio

	active_gas					; Holds number of active gas
		
	last_diluent				; backup of diluent percentage in const ppO2 mode
	last_cns					; backup of last cns value
	last_ppO2_value				; last calculated ppO2 value

;	ontime_since_last_charge:2	; Ontime in minutes since last complete charge cycle
;	sleeptime_since_last_charge:2; Sleeptime in hours since last complete charge

	debug_char:6				; For debugmode
	debug_temp					; For debugmode
	
	apnoe_mins					; single descent minutes for Apnoe mode
	apnoe_secs					; single descent seconds for Apnoe mode
	apnoe_max_pressure:2		; Max. Pressure in Apnoe mode
	apnoe_timeout_counter		; counts minutes for apnoe timeout
	apnoe_surface_mins			; Surface interval mins for Apnoe mode
	apnoe_surface_secs			; Surface interval secs for Apnoe mode
	customfunction_temp1		; start of custom function descriptors 
	customfunction_temp2		; used in GETCUSTOM8 and GETCUSTOM15
	
	switch_timeout				; used for hold-down count function
	
	temp5						; used in PLED_MultiGF,...
	temp6						; used in PLED_MultiGF,...
	char_last_pointer			; for MultiGF
	MultiGF_seconds				; Counter for seconds in Multi-GF mode

	fatal_error_code			; holds error code value 

	logbook_temp1				; Temp used in logbook display&Divemode
	logbook_temp2				; Temp used in logbook display&Divemode
	logbook_temp3				; Temp used in logbook display&Divemode
	logbook_temp4				; Temp used in logbook display&Divemode
	logbook_temp5				; Temp used in logbook display&Divemode
	logbook_temp6				; Temp used in logbook display&Divemode
	
	convert_value_temp:3		; used in menu_battery_state_convert_date
	box_temp:5
	win_color1_temp
	win_color2_temp				; Backup color registers
	
	ENDC

	CBLOCK	0x200				;Bank 2
 int_O_tissue_for_debug:.32		; deco_main_debug copies pressure of tissue to this variable
 int_O_GF_spare____:2;					// 0x240
 int_O_GF_step:2;							// 0x242
 int_O_gtissue_limit:2;					// 0x244
 int_O_gtissue_press:2;					// 0x246
 int_O_limit_GF_low:2;					// 0x248
 int_O_gtissue_press_at_GF_low:2;			// 0x24A
	ENDC
	CBLOCK	0x24E				;Bank 2
 char_O_GF_low_pointer;					// 0x24E
 char_O_actual_pointer;					// 0x24F
	ENDC
	CBLOCK	0x250				;Bank 2
 char_IO_deco_table:.32;				// 0x250
	ENDC
	CBLOCK	0x270				;Bank 2
 char_I_table_deco_done:.32;			// 0x270
	ENDC
	CBLOCK	0x290				;Bank 2
 int_O_calc_tissue_call_counter:2
	ENDC
	CBLOCK	0x380				;Bank 3
	; some used in C code!
	ENDC
								
	CBLOCK	0x500
; used by deco_main c-code for data transfer with the asm code
; input of c-code
 int_I_pres_respiration:2;			; 0x500
 int_I_pres_surface:2;				; 0x502
 int_I_temp:2;						; 0x504
 char_I_temp;						; 0x506
 char_I_actual_ppO2;				; 0x507
 int_I_spare_3:2;
 int_I_spare_4:2;
 int_I_spare_5:2;
 int_I_spare_6:2;
 char_I_N2_ratio;					; 0x510
 char_I_He_ratio;					; 0x511
 char_I_saturation_multiplier;		; for conservatism/safety values 1.0 (no conservatism) to 1.5 (50% faster saturation
 char_I_desaturation_multiplier;	; for conservatism/safety values 0.66 (50% slower desaturation) to 1.0 (no conservatism); consveratism used in calc_tissue(), calc_tissue_step_1_min() and sim_tissue_1min()
 char_I_GF_Hi_percentage;			; 0x514
 char_I_GF_Lo_percentage;			; 0x515
 char_I_GF_Spare;				; 0x516
 char_I_deco_distance;				; 0x517
 char_I_const_ppO2;					; 0x518	new in v.101 (C-Code), new in v109 (asm)
 char_I_deco_ppO2_change;			; 0x519	new in v.101
 char_I_deco_ppO2;					; 0x51A	new in v.101
 char_I_deco_gas_change;			; 0x51B	new in v.101
 char_I_deco_N2_ratio;				; 0x51C	new in v.101
 char_I_deco_He_ratio;				; 0x51D	new in v.101
 char_I_depth_last_deco;			; 0x51E	new in v.101
 char_I_deco_model;					; 0x51F	new in v.102
; output of c-code:
 int_O_desaturation_time:2;			; 0x520
 char_O_nullzeit;					; 0x522
 char_O_deco_status;				; 0x523
 char_O_array_decotime:7;			; 0x524
 char_O_array_decodepth:6;			; 0x52B
 char_O_ascenttime;					; 0x531
 char_O_gradient_factor;			; 0x532
 char_O_tissue_saturation:.32;		; 0x533, He starts at 0x543
 char_O_array_gradient_weighted:.16 ; 0x553
 char_O_gtissue_no;					; 0x563
 char_O_diluent;					; 0x564 new in v.101 (C-Code), new in v109 (asm)
 char_O_CNS_fraction;				; 0x565	new in v.101
 char_O_relative_gradient_GF;		; 0x566	new in v.102

	ENDC

	CBLOCK	0x700				;Bank 7
; variables used exclusively in dd:
	dd_temp_BSR ; has to be first in bank7
	temp_pointer_row
	temp_pointer_column
	temp2_pointer_row
	temp2_pointer_column
	temp_selected_char
	temp_font_HIGH
	temp_font_LOW
	temp_font_height
	temp2_font_height
	temp_font_width
	temp2_font_width
	temp_diff_font_width
	temp2_diff_font_width
	temp_font_offset_left
	temp_font_offset_right
	temp_pos
	DDflag
	dd_oled_brightness_offset		; value will be subtracted from "dd_grayvalue" in dd_font2display_vxxx.asm
	dd_grayvalue
	dd2_temp
	dd3_temp
	dd_pos_decpoint
	dd_grayvalue_temp
	dd_grayvalue_temp2
	ENDC

	CBLOCK	0x94A				;Bank 9
	char_O_hash:.16			; MD2 hash values = d'16'
	ENDC


; C-code Routines
; PART 3
;#DEFINE main_wordprocessor					0x0B410
#DEFINE main_wordprocessor					0x0B468

; C-code Routines
; PART 2
#DEFINE deco_main_calc_hauptroutine			0x10000
#DEFINE deco_main_calc_without_deco			0x10020
#DEFINE main_clear_CNS_fraction 			0x10030
#DEFINE main_calc_CNS_decrease_15min		0x10034
#DEFINE main_calc_percentage				0x10038
#DEFINE deco_main_clear_tissue				0x10040
#DEFINE main_calc_CNS_fraction				0x10050
#DEFINE deco_main_calc_desaturation_time	0x10060
#DEFINE deco_main_calc_wo_deco_step_1_m		0x10080
#DEFINE deco_main_debug						0x100A0
#DEFINE main_DD2_write_incon42				0x100B0
#DEFINE main_DD2_write_incon24				0x100B4

#DEFINE deco_main_gradient_array			0x100C0
#DEFINE deco_main_hash						0x100E0
#DEFINE main_push_tissues_to_vault			0x100C4
#DEFINE main_pull_tissues_from_vault		0x100C8	

;I/O Ports (I=Input, O=Output)
#DEFINE	sensor_SDO			PORTA,1 ;O
#DEFINE	oled_rw				PORTA,2 ;0
#DEFINE	oled_hv				PORTA,3 ;O
#DEFINE	sensor_SDI			PORTA,4 ;I
#DEFINE	oled_cs				PORTA,5 ;O
#DEFINE	sensor_CLK			PORTA,7 ;O

#DEFINE	SWITCH2				PORTB,0 ;I  (Right)
#DEFINE	SWITCH1				PORTB,1 ;I  (Left)
#DEFINE	oled_vdd			PORTB,2 ;O
#DEFINE	LED_blue			PORTB,3 ;0
#DEFINE	LED_red				PORTB,4 ;O

#DEFINE	CHRG_OUT			PORTC,1 ;O
#DEFINE	CHRG_IN				PORTC,2 ;I

#DEFINE	oled_d1				PORTD,0 ;O
#DEFINE	oled_d2				PORTD,1 ;O
#DEFINE	oled_d3				PORTD,2 ;O
#DEFINE	oled_d4				PORTD,3 ;O
#DEFINE	oled_d5				PORTD,4 ;O
#DEFINE	oled_d6				PORTD,5 ;O
#DEFINE	oled_d7				PORTD,6 ;O
#DEFINE	oled_d8				PORTD,7 ;O

#DEFINE	oled_rs				PORTE,0 ;0
#DEFINE	oled_nreset			PORTE,1 ;0
#DEFINE	oled_e_nwr			PORTE,2 ;0

; Flags
#DEFINE	FLAG_scale			flag1,0	; Wordprocessor
#DEFINE	FLAG_truncated		flag1,1	; Wordprocessor
#DEFINE	pre_zero_flag		flag1,2	; leading zeros
#DEFINE neg_flag			flag1,3	; e.g. Sub_16 (sub_c = sub_a - sub_b)
#DEFINE	FLAG_row_prime		flag1,4	; Wordproceesor
#DEFINE leading_zeros		flag1,5	; display leading zeros?
#DEFINE	show_last3			flag1,6	; show only three figures
#DEFINE	leftbind			flag1,7	; leftbinded output

#DEFINE	onesecupdate		flag2,0	;=1 after any second
#DEFINE	divemode			flag2,1	;=1 if in divemode
#DEFINE	oneminupdate		flag2,2	;=1 after any minute
#DEFINE	realdive			flag2,3 	; dive was longer then one minute?
#DEFINE	sleepmode			flag2,4	;=1 if in sleepmode
#DEFINE	same_row			flag2,5	;=1 if pixel pair is in same row (display_profile)
#DEFINE premenu				flag2,6	; Premenu/Divemenu selected
#DEFINE	menubit				flag2,7	; menu

#DEFINE	menubit2			flag3,0	; menu
#DEFINE	menubit3			flag3,1	; menu
#DEFINE	set_minutes			flag3,2	; set minutes (not hours)
#DEFINE cursor				flag3,3	; display cursor
#DEFINE	menubit4			flag3,4	; quit set time 
#DEFINE	display_velocity	flag3,5	; velocity is displayed
#DEFINE	temp_changed		flag3,6	; temperature changed
#DEFINE	pres_changed		flag3,7	; pressure changed

#DEFINE	set_year			flag4,0	; Menu Settime
#DEFINE	set_day				flag4,1	; Menu Settime
#DEFINE	set_month			flag4,2	; Menu Settime
#DEFINE	store_sample		flag4,3	;=1 after any CF20 seconds in divemode
#DEFINE	divemode2			flag4,4	; displayed divetime stopped?
#DEFINE	header_stored		flag4,5	; header already stored
#DEFINE	first_FD			flag4,6	; 1st 0xFD in EEPROM found
#DEFINE	first_FA			flag4,6	; 1st 0xFA in EEPROM found
#DEFINE	second_FD			flag4,7	; 2nd 0xFD in EEPROM found
#DEFINE	second_FA			flag4,7	; 2nd 0xFA in EEPROM found

#DEfINE	eeprom_overflow		flag5,0	; EEPROM overflowed (>32KB)
#DEFINE	eeprom_blockwrite	flag5,1	; EEPROM blockwrite active
#DEFINE neg_flag_xdT		flag5,2	; xdT negative (2nd order temperature calculation)
#DEFINE	low_battery_state	flag5,3	;=1 if battery low
#DEFINE	DP_done				flag5,4	; valconv
#DEFINE	DP_done2			flag5,5	; valconv
#DEFINE	pressure_refresh	flag5,6	; Pressure and temperature refreshed
#DEFINE	no_sensor_int		flag5,7	; block any further access to pressure sensor

#DEFINE	cc_active			flag6,0	;=1: Constant Current mode aktive (Charger)
#DEFINE	cv_active			flag6,1	;=1: Constant Voltage mode aktive (Charger)
#DEFINE	ignore_digit5		flag6,2	;=1: ignores digit 5 in valconv
#DEFINE	switch_left			flag6,3	;=1: left switch pressed
#DEFINE	switch_right		flag6,4	;=1: right switch pressed
#DEFINE	uart_settime		flag6,5	;=1: enter time sync routine
#DEFINE	neg_temp			flag6,6	;=1: temperature below zero
#DEFINE	twosecupdate		flag6,7	;=1: after any two seconds

#DEFINE	dekostop_active			flag7,0	;=1: in deocompression mode
#DEFINE	all_dives_shown			flag7,1	;=1: all dives in loogbook shown, abort further scanning
#DEFINE	return_from_profileview flag7,2	;=1: set cursor to same position again
#DEFINE	logbook_profile_view 	flag7,3	;=1: Show details/profile in logbook
#DEFINE	logbook_page_not_empty 	flag7,4	;=1: actual logbook page is not empty
#DEFINE	dump_external_eeprom 	flag7,5	;=1: enter download-routine
#DEFINE	simulatormode_active	flag7,6	;=1: Simulator mode active, override pressure sensor readings
#DEFINE	all_zeros_flag			flag7,7	;=1: display all zeros from here (valconv_v2.asm)

#DEFINE	internal_eeprom_write	flag8,0	;=1: start routine to access internal EEPROM BANK 0 via the UART
#DEFINE	update_divetime			flag8,1	;=1: update divetime display
#DEFINE	display_set_xgas		flag8,2	;=1: Display Set Gas menu in Divemode
#DEFINE	FLAG_active_descent		flag8,3	;=1: A Descent in Apnoe mode is active
#DEFINE	display_see_deco		flag8,4	;=1: Display decoplan in Divemode
#DEFINE	display_set_gas			flag8,5	;=1: Display Gaslist menu in Divemode
#DEFINE	display_set_graphs		flag8,6	;=1: Display "Display Menu" in Divemode
#DEFINE	rs232_recieve_overflow	flag8,7	;=1: An RS232 timeout overflow occoured

#DEFINE	nofly_active			flag9,0	;=1: Do not fly!
#DEFINE	ppO2_display_active		flag9,1	;=1: ppO2 value is displayed
#DEFINE	ppO2_show_value			flag9,2	;=1: show ppO2 value!
#DEFINE	show_startup_screen		flag9,3	;=1: Show startup screen with MD2 hash
#DEFINE	ignore_digit3			flag9,4	;=1: ignores digits 3-5 in valconv
#DEFINE	ppO2_warn_value			flag9,5	;=1: warn about ppO2!
#DEFINE	output_to_postinc_only	flag9,6	;=1: Do not call wordprocessor in output
#DEFINE	uart_send_hash			flag9,7	;=1: Send the MD2 hash via UART

#DEFINE	uart_compensate_temp	flag10,0	;=1: Enter Temperature compensation routine
#DEFINE	uart_send_int_eeprom	flag10,1	;=1: Send internal EEPROM BANK 0
#DEFINE	uart_reset_decodata		flag10,2	;=1: Reset deco data 
#DEFINE	manual_gas_changed		flag10,3	;=1: Manual Gas changed during dive
#DEFINE	stored_gas_changed		flag10,4	;=1: Stored Gas changed during dive
#DEFINE	event_occured			flag10,5	;=1: An Event has occured during the current sample interval
#DEFINE	new_profile_format		flag10,6	;=1: Current Dive in Logbook uses new ProfileFormat
#DEFINE	gauge_mode				flag10,7	;=1: Gauge mode active

#DEFINE FLAG_const_ppO2_mode	flag11,0	;=1: const ppO2 mode active
#DEFINE	gas_setup_page2			flag11,1	;=1: page two of gassetup active
#DEFINE logbook_header_drawn	flag11,2	;=1: The "Logbook" Header in the List view is already drawn
#DEFINE	ignore_digit4			flag11,3	;=1: Ignores digits 4-5 in valconv
#DEFINE	charge_done				flag11,4	;=1: Complete charge cycle done
#DEFINE	initialize_battery1		flag11,5	;=1: Battery memory need to be initialised
#DEFINE	initialize_battery2		flag11,6	;=1: Battery memory need to be initialised
#DEFINE	charge_started			flag11,7	;=1: Charger started in CC mode

#DEFINE	switch_left_isr			flag12,0	;=1: left switch pressed (Only modified in ISR!)
#DEFINE	switch_right_isr		flag12,1	;=1: right switch pressed (Only modified in ISR!)
#DEFINE	debug_mode				flag12,2	;=1: Debugmode active
#DEFINE	neg_flag_isr			flag12,3	;=1: ISR Negative flag (Math)
#DEFINE	select_bailoutgas		flag12,4	;=1: Select Bailout instead of Setpoint in Gaslist
#DEFINE	FLAG_apnoe_mode			flag12,5	;=1: Apnoe mode selected
#DEFINE	customfunction_page		flag12,6	;=1: Use 2nd Page of Custom Functions
#DEFINE	uart_send_int_eeprom2	flag12,7	;=1: Send internal EEPROM BANK 1

#DEFINE	internal_eeprom_write2	flag13,0	;=1: start routine to access internal EEPROM BANK 1 via the UART
#DEFINE	button_delay_done		flag13,1	;=1: Button was pressed for more then 500ms, start counting
#DEFINE	multi_gf_display		flag13,2	;=1: Display the Multi-GF screen instead of normal divemode screen
#DEFINE	deco_mode_changed		flag13,3	;=1: The Decomode was changes, show decomode description!
#DEFINE	pled_velocity_display	flag13,4	;=1: Velocity is displayed 
#DEFINE depth_greater_100m		flag13,5	;=1: Depth is greater then 100m
#DEFINE	display_set_setpoint	flag13,6	;=1: SetPoint list active
#DEFINE	divemode_menu_page		flag13,7	;=1: Use 2nd Page of Divemode Menu

#DEFINE	enter_error_sleep		flag14,0	;=1: Sleep immediately displaying the error using LED codes
#DEFINE	stopwatch_active		flag14,1	;=1: Show Stopwatch in Divemode
#DEFINE	is_bailout				flag14,2	;=1: CC mode, but bailout active!
#DEFINE	standalone_simulator	flag14,3	;=1: Standalone Simulator active
#DEFINE	display_set_simulator	flag14,4	;=1: Show Divemode simulator menu
#DEFINE	displaytext_high		flag14,5	;=1: Show/Use Texts 255-511 in Texttable
#DEFINE	better_gas_available	flag14,6	;=1: A better gas is available and a gas change is advised in divemode
#DEFINE	displaytext_invert		flag14,7	;=1: inverts word prozessor output

#DEFINE	restore_deco_data		flag15,0	;=1: Restore Decodata after the dive from 0x380 buffer
#DEFINE	uart_store_tissue_data	flag15,1	;=1: Store tissue data for next simualted dive!
#DEFINE	pre_dive_screen			flag15,2	;=1: Show predive screen instead of graphs
;free
#DEFINE	display_see_l_tissue	flag15,4	;=1: Leading Tissue details are now displayed
;free
;free
#DEFINE	show_interval			flag15,7	;=1: Show Interval, =0: Show Clock in Surfacemode

