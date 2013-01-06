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
; 2011/01/20: [jDG] Create a common file included in ASM and C code.
; known bugs:
; ToDo:

#DEFINE	softwareversion_x		d'2'		; Software version  XX.YY
#DEFINE	softwareversion_y		d'60'		; Software version  XX.YY

#DEFINE softwareversion_beta 	1 			; (and 0 for release) 

#DEFINE	max_custom_number		d'69'		; Number of last used custom function

; International extension. Selecting messages source:
#DEFINE    ENGLISH                         ; Use english_text.asm
;#DEFINE	FRENCH  						; Use french_text.asm
;#DEFINE	GERMAN							; Use german_text.asm
;#DEFINE	SPANISH							; Use spanish_text.asm
;#DEFINE	RUSSIAN							; Use russian_text.asm
;#DEFINE	TURKISH							; Use turkish_text.asm
;#DEFINE	ITALIAN							; Use italian_text.asm

;#DEFINE	DISPLAY_TEST	; Enables Display-Test in RAW data menu

#DEFINE	logbook_profile_version	0x21        ; Do not touch!
#DEFINE	T0CON_debounce	b'00000000'         ; Timer0 Switch Debounce


; CPU Speed Settings
; Standard 16MHz mode
;	#DEFINE	SPBRG_VALUE 	d'34'
;  	#DEFINE	OSCCON_VALUE  	b'01101100'		; 4MHz (x4 PLL)
;	#DEFINE	SSPSTAT_VALUE	b'00000000'		; with slew rate control (400kHz)
;	#DEFINE	SSPADD_VALUE	d'8'			; 400kHz I2C clock @ 16MHz Fcy
;	#DEFINE	T0CON_VALUE		b'00011111'		; Timer0
; 	#DEFINE	SPEED_16MHz
; Experimental 32MHz mode
	#DEFINE	SPBRG_VALUE 	d'68'
  	#DEFINE	OSCCON_VALUE  	b'01111100'		; 8MHz (x4 PLL)
;	#DEFINE	SSPADD_VALUE	d'16'			; 400kHz I2C clock @ 32MHz Fcy
	#DEFINE	SSPADD_VALUE	d'32'			; 200kHz I2C clock @ 32MHz Fcy
	#DEFINE	SSPSTAT_VALUE	b'00000000'		; with slew rate control
	#DEFINE	T0CON_VALUE 	b'00010000'		; Timer0
 	#DEFINE	SPEED_32MHz

#DEFINE		FT_SMALL		.0
#DEFINE		FT_MEDIUM		.1
#DEFINE		FT_LARGE		.2

; "Better Gas" behavior
; better_gas_window <= minimum_change_depth !
; minimum_change_depth >=5 !
#DEFINE	minimum_change_depth	.3 			; [m]
#DEFINE	better_gas_window		.3			; [m]

; Color Definitions: 8Bit RGB b'RRRGGGBB'
#DEFINE	color_red	    	b'11100000'     ; (7,0,0)
#DEFINE	color_dark_red	    b'10000101'     ; (4,1,1)
#DEFINE	color_violet    	b'11101011'     ; (7,2,3)
#DEFINE	color_blue		    b'11000111'     ; (6,1,3)
#DEFINE	color_green	        b'00011100'     ; (0,7,0)
#DEFINE color_dark_green    b'00111001'     ; (1,6,1)
#DEFINE	color_yellow 	    b'11111101'     ; (7,7,1)
#DEFINE	color_white         b'11111111'     ; (7,7,3)
#DEFINE	color_black         b'00000000'     ; (0,0,0)
#DEFINE	color_deepblue      b'00000010'     ; (0,0,2)
#DEFINE	color_grey	        b'01001010'     ; (2,2,2)
#DEFINE	color_cyan	        b'11011111'     ; (6,7,3)
#DEFINE color_orange        b'11111000'     ; (7,6,0)
#DEFINE color_pink          b'11111010'     ; (7,6,2)

#DEFINE	warn_depth			d'1'
#DEFINE	warn_cns			d'2'
#DEFINE	warn_gf				d'3'
#DEFINE	warn_ppo2			d'4'
#DEFINE warn_velocity		d'5'
#DEFINE warn_ceiling		d'6'
#DEFINE	warn_gas_in_gaslist	d'7'

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

;=============================================================================
; Reserve space for C-code data space. Eg.when calling log.
; Note: overlayed with md_hash temporary space.
c_code_data_stack   EQU 0x800

;=============================================================================
; ACCESS0 data
;
tmp0            udata_acs 0x04C     ; Bank 0 ACCESS area for small tmp data.
tmp             equ       0x04C
                res .20             ; What is left from the C library.

;=============================================================================
; BANK0 data
;
bank0           udata 0x060     ;Bank 0

                global letter, win_color1, win_top, win_leftx2
                global win_font, win_invert
                global win_height, win_width, win_bargraph

letter          res .26         ;letter buffer
win_color1      res 1
win_color2      res 1
win_top         res 1           ; Box/text position (0..239).
win_height      res 1           ; Box/text height (1..240)
win_leftx2      res 1           ; Box/text position (0..159)
win_width       res 1           ; box width (1..160)
win_font        res 1
win_invert      res 1
win_bargraph    res 1           ; PLED_box swicth to black after this position (0..159).
win_flags       res 1           ; flip_screen flag, transparent fonts, etc...

pressureSum     res 2           ; Stabilize surface presure by a long averaging window [mbar]
pressureCount   res 1           ; Count of pressure values.
pressureAvg     res 2           ; save averaged pressure x16, for altimeter_menu
pressureRef     res 2           ; Pressure at sea level [mbar]
altitude        res 2           ; Last computed altitude [m]

;=============================================================================
; BANK1 data
;
bank1 udata 0x100               ;Bank 1

prod_temp       res 2           ;Trashed by isr_mult16x16, for sensor compensations

secs            res 1           ;realtime clock
mins            res 1
hours           res 1
day             res 1
month           res 1
year            res 1

waitms_temp     res 1           ;variables required for wait routines
wait_temp       res 1           ; " + used to copy data to c code + used for temp/testing
                                ; never use wait_temp in interrupt routines (isr) and never call any wait routine in interrupts

textnumber      res 1           ; for textdisplay
textaddress     res 2				

average_depth_hold  res 4       ; Holds Sum of depths (Resettable)
average_depth_hold_total res 4  ; Holds Sum of depths (Non-Resettable)
b0_lo           res 1           ; Temp (calculate_average)
b0_hi           res 1           ; Temp (calculate_average)
average_divesecs    res 2       ; Used for resetable average depth display
surface_interval    res 2       ; Surface Interval [mins]

flag1           res 1           ;Flag register 33
flag2           res 1
flag3           res 1
flag4           res 1
flag5           res 1           ; has to be exacly here, is modified by c-code (no sensor int) 
flag6           res 1
flag7           res 1
flag8           res 1
flag9           res 1
flag10          res 1
flag11          res 1
flag12          res 1
flag13          res 1
flag14          res 1
flag15          res 1

oled1_temp      res 1           ; Temp variables for display output
oled2_temp  	res 1
oled3_temp      res 1
oled4_temp      res 1           ; Used in "Displaytext"

                global hi,lo    ; Make them visible from C-code
lo              res 1           ; bin to dec conversion routine
hi              res 1
lo_temp         res 1
hi_temp         res 1
temp3           res 1           ; used in valconv math
temp4           res 1           ; used in valconv math
ignore_digits   res 1

temp1           res 1           ; Multipurpose Temp variables 	used in valconv math
temp2           res 1           ; used in valconv math

ext_ee_temp1    res 1           ; External EEPROM Temp 1		used in I2C EEPROM
ext_ee_temp2    res 1           ; External EEPROM Temp 2		used in I2C EEPROM

isr1_temp       res 1           ; ISR temp variables

timer1int_counter1  res 1       ;Timer 1 counter
timer1int_counter2  res 1       ;Timer 1 counter

uart1_temp      res 1           ;RS232 temp variables
uart2_temp      res 1           ;70

divA            res 2			;math routines
divB            res 1
xC              res 4
xA              res 2
xB              res 2
sub_c           res 2
sub_a           res 2
sub_b           res 2

dLSB            res 1           ;Pressure sensor interface 
dMSB            res 1
clock_count     res 1
ppO2_setpoint_store res 1       ; Actual setpoint

; Pressure/Temperatuse sensor data
W1              res 2           ; Raw (packed) calibration data
W2              res 2
W3              res 2
W4              res 2	        ; 100
C1              res 2           ; Decoded calibration data
C2              res 2
C3              res 2
C4              res 2
C5              res 2
C6              res 2
D1              res 2           ; raw pressure
D2              res 2           ; raw temperature

isr_divA        res 2           ; Data for ISR math subroutines
isr_divB        res 1
isr_xC          res 4
isr_xA          res 2
isr_xB          res 2

xdT             res 2           ; Tmp for temperature compensation (in ISR)
xdT2            res 2
OFF             res 2
SENS            res 2

amb_pressure_avg res 2          ; ambient pressure summing buffer[mbar]
amb_pressure    res 2           ; ambient pressure [mbar]
rel_pressure    res 2		    ; amb_pressure - surface pressure [mbar]
max_pressure    res 2           ; Max. pressure for the dive [mbar]
avr_rel_pressure res 2          ; Average rel. pressure (Average depth) for the dive [mbar], Resettable
avr_rel_pressure_total res 2    ; Average rel. pressure (Average depth) for the dive [mbar], Non-Resettable
last_pressure   res 2
temperature_avg res 2           ; Temperature summing buffer.
temperature     res 2           ; Final temperature. SIGNED.
last_temperature res 2          ; Last displayed temperature (used to detect changes).

last_surfpressure       res 2   ; Divemode
last_surfpressure_15min res 2
last_surfpressure_30min res 2
divemins                res 2   ; Minutes
divesecs                res 1   ; seconds
samplesecs              res 1   ; counts the seconds until the next sample is stored in divemode
samplesecs_value        res 1   ; holds the CF20 value
decodata                res 2   ; Deco data
mintemp                 res 2   ; min temperature
ProfileFlagByte         res 1   ; stores number of addional bytes per sample
EventByte               res 1   ; Stores the Event type plus flags	
AlarmType               res 1   ; 0= No Alarm
								; 1= SLOW
								; 2= DecoStop missed
								; 3= DeepStop missed
								; 4= ppO2 Low Warning
								; 5= ppO2 High Warning
								; 6= manual marker

divisor_temperature     res 1   ; divisors for profile storage
divisor_deco            res 1
divisor_gf	            res 1
divisor_ppo2            res 1
divisor_deco_debug      res 1
divisor_cns	            res 1

timeout_counter         res 1   ; Timeout counter variables
timeout_counter2        res 1
timeout_counter3        res 1   ; pre-menu timeout counter

menupos                 res 1   ; cursor position
menupos2                res 1
menupos3                res 1   ; used in Logbook, Set Time and divemode

eeprom_address          res 2   ; external EEPROM
eeprom_header_address   res 2

batt_voltage            res 2   ; Battery voltage in mV

i2c_temp                res 1   ; I²C timeout counter
i2c_temp2               res 1   ; 200

sim_pressure            res 2   ; hold simulated pressure in mbar if in Simulator mode

profile_temp            res 2   ; temp variable for profile view
profile_temp2           res 2   ; temp variable for profile view

nofly_time              res 2   ; No Fly time in Minutes (Calculated after Dive)

cf_checker_counter      res 1   ; counts custom functions to check for warning symbol

char_I_O2_ratio         res 1   ; 02 ratio

active_gas              res 1   ; Holds number of active gas (1-5)
active_diluent          res 1   ; Holds number of active diluent (1-5)

debug_char              res 6    ; For debugmode

apnoe_mins              res 1   ; single descent minutes for Apnoe mode
apnoe_secs              res 1   ; single descent seconds for Apnoe mode
apnoe_max_pressure      res 2   ; Max. Pressure in Apnoe mode
apnoe_timeout_counter   res 1   ; counts minutes for apnoe timeout
apnoe_surface_mins      res 1   ; Surface interval mins for Apnoe mode
apnoe_surface_secs      res 1   ; Surface interval secs for Apnoe mode
customfunction_temp1    res 1   ; used in GETCUSTOM8 and GETCUSTOM15

decoplan_page           res 1   ; used in PLED_MultiGF,...
temp10                  res 2   ; used in customview

fatal_error_code        res 1   ; holds error code value 

convert_value_temp      res 3   ; used in menu_battery_state_convert_date
time_correction_value   res 1   ; Adds to Seconds on midnight
gaslist_active          res 1	; Holds flags for active gases
desaturation_time_buffer res 2	; buffer for desat time
total_divetime_seconds	res 2	; counts dive seconds regardless of CF01 (18h max.)

safety_stop_countdown	res 1	; counts seconds of safety stop
better_gas_number		res 1	; number (1-5) of the "better gas" in divemode, =0: no better gas available

marker_depth            res 2   ; rel. pressure [mbar] of last set marker
marker_time             res 3   ; divetime mins:2 and sec of last marker


ASSERT_BANK1    MACRO   tag
    Ifdef   __DEBUG
        local @end
        movlw   1
        xorwf   BSR,W
        bz      @end
        
        movlw   low(tag)
        movff   WREG,temp10+0
        movlw   high(tag)
        movff   WREG,temp10+1
        call    PLED_resetdebugger
@end:
    Endif
    ENDM
;=============================================================================
; C-code Routines
; PART 2
    extern deco_calc_CNS_decrease_15min    
    extern deco_calc_CNS_fraction
    extern deco_calc_desaturation_time
    extern deco_calc_hauptroutine
    extern deco_calc_tissue
    extern deco_calc_percentage
    extern deco_calc_wo_deco_step_1_min
    extern deco_calc_dive_interval
    extern deco_clear_CNS_fraction
    extern deco_calc_CNS_planning
    extern deco_clear_tissue
    extern deco_hash    
    extern deco_pull_tissues_from_vault
    extern deco_push_tissues_to_vault
    extern deco_gas_volumes

;=============================================================================
;I/O Ports (I=Input, O=Output)
;
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

; Bank0 flags
#DEFINE win_flip_screen     win_flags,0 ; 180° rotation of the OLED screen.

; Flags
#DEFINE	tts_extra_time		flag1,0	; Showing "Future TTS" customview
#DEFINE	uart_dump_screen    flag1,1	; Screen copy to USB.
#DEFINE	pre_zero_flag		flag1,2	; leading zeros
#DEFINE neg_flag			flag1,3	; e.g. Sub_16 (sub_c = sub_a - sub_b)
#DEFINE	logbook_format_0x21	flag1,4	; =1: New 0x21 Logbook header format
#DEFINE leading_zeros		flag1,5	; display leading zeros?
#DEFINE	show_last3			flag1,6	; show only three figures
#DEFINE	leftbind			flag1,7	; leftbinded output

#DEFINE	onesecupdate		flag2,0	;=1 after any second
#DEFINE	divemode			flag2,1	;=1 if in divemode
#DEFINE	oneminupdate		flag2,2	;=1 after any minute
#DEFINE	realdive			flag2,3 	; dive was longer then one minute?
#DEFINE	sleepmode			flag2,4	;=1 if in sleepmode
#DEFINE	safety_stop_active	flag2,5	;=1 The safety stop is currently displayed
#DEFINE premenu				flag2,6	; Premenu/Divemenu selected
#DEFINE	menubit				flag2,7	; menu

#DEFINE	menubit2			flag3,0	; menu
#DEFINE	menubit3			flag3,1	; menu
#DEFINE	set_minutes			flag3,2	; set minutes (not hours)
#DEFINE internal_eeprom_write3 flag3,3 ;=1: start routine to access internal EEPROM BANK 2 via the UART
#DEFINE	menubit4			flag3,4	; quit set time 
#DEFINE	display_velocity	flag3,5	; velocity is displayed
#DEFINE	temp_changed		flag3,6	; temperature changed
#DEFINE	pres_changed		flag3,7	; pressure changed

#DEFINE	set_year			flag4,0	; Menu Settime
#DEFINE	use_aGF 			flag4,0	; =1: Use alternative GF in divemode
#DEFINE	set_day				flag4,1	; Menu Settime
#DEFINE	set_month			flag4,2	; Menu Settime
#DEFINE	store_sample		flag4,3	;=1 after any CF20 seconds in divemode
#DEFINE	divemode2			flag4,4	; displayed divetime stopped?
#DEFINE	header_stored		flag4,5	; header already stored
#DEFINE	first_FD			flag4,6	; 1st 0xFD in EEPROM found
#DEFINE	first_FA			flag4,6	; 1st 0xFA in EEPROM found
#DEFINE	second_FD			flag4,7	; 2nd 0xFD in EEPROM found
#DEFINE	second_FA			flag4,7	; 2nd 0xFA in EEPROM found

#DEfINE	timeout_display		flag5,0	; =1: The divemode timeout is displayed
#DEFINE	eeprom_blockwrite	flag5,1	; EEPROM blockwrite active
#DEFINE oled_brightness_high flag5,2	; =1: High brightness, =0: Eco mode
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
#DEFINE	eeprom_switched_b1  flag6,6	;=1: EEPROM read switched to bank1
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
#DEFINE	high_altitude_mode		flag8,6	;=1: Unit was manually turned on with ambient pressure <880mbar
#DEFINE	rs232_recieve_overflow	flag8,7	;=1: An RS232 timeout overflow occoured

#DEFINE	nofly_active			flag9,0	;=1: Do not fly!
#DEFINE	ppO2_display_active		flag9,1	;=1: ppO2 value is displayed
#DEFINE	ppO2_show_value			flag9,2	;=1: show ppO2 value!
#DEFINE	uart_reset_battery_stats flag9,3;=1: Reset the battery statistics (UART String FFF)
#DEFINE	ignore_digit3			flag9,4	;=1: ignores digits 3-5 in valconv
#DEFINE	show_safety_stop		flag9,5	;=1: Show the safety stop
#DEFINE	output_to_postinc_only	flag9,6	;=1: Do not call wordprocessor in output
#DEFINE	uart_send_hash			flag9,7	;=1: Send the MD2 hash via UART

#DEFINE	last_ceiling_gf_shown	flag10,0	;=1: Last stop already shown
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
#DEFINE	decoplan_invalid    	flag11,6	;=1: Decoplan still invalid (After a gas change)
#DEFINE	charge_started			flag11,7	;=1: Charger started in CC mode

#DEFINE	setpoint_changed		flag12,0	;=1: Setpoint was changed in divemode, store in profile
#DEFINE	uart_115200_bootloader	flag12,1	;=1: Look for 115200 Baud bootloader
#DEFINE	debug_mode				flag12,2	;=1: Debugmode active
#DEFINE	neg_flag_isr			flag12,3	;=1: ISR Negative flag (Math)
#DEFINE	select_bailoutgas		flag12,4	;=1: Select Bailout instead of Setpoint in Gaslist
#DEFINE	FLAG_apnoe_mode			flag12,5	;=1: Apnoe mode selected
#DEFINE	uart_send_int_eeprom3	flag12,6	;=1: Send internal EEPROM BANK 2
#DEFINE	uart_send_int_eeprom2	flag12,7	;=1: Send internal EEPROM BANK 1

#DEFINE	internal_eeprom_write2	flag13,0	;=1: start routine to access internal EEPROM BANK 1 via the UART
#DEFINE	button_delay_done		flag13,1	;=1: Button was pressed for more then 500ms, start counting
#DEFINE	display_set_active		flag13,2	;=1: De/Activate gases underwater menu is visible
#DEFINE	deco_mode_changed		flag13,3	;=1: The Decomode was changes, show decomode description!
#DEFINE	pled_velocity_display	flag13,4	;=1: Velocity is displayed 
#DEFINE depth_greater_100m		flag13,5	;=1: Depth is greater then 100m
#DEFINE	display_set_setpoint	flag13,6	;=1: SetPoint list active
#DEFINE	toggle_customview		flag13,7	;=1: Next customview

#DEFINE	enter_error_sleep		flag14,0	;=1: Sleep immediately displaying the error using LED codes
#DEFINE display_set_diluent 	flag14,1	;=1: Diluent list active
#DEFINE	is_bailout				flag14,2	;=1: CC mode, but bailout active!
#DEFINE	standalone_simulator	flag14,3	;=1: Standalone Simulator active
#DEFINE	display_set_simulator	flag14,4	;=1: Show Divemode simulator menu
#DEFINE	displaytext_high		flag14,5	;=1: Show/Use Texts 255-511 in Texttable
#DEFINE	better_gas_available	flag14,6	;=1: A better gas is available and a gas change is advised in divemode
#DEFINE	s_unlock_after_sleep	flag14,7	;=1: Sensor unlocked for divemode and battery history

#DEFINE	restore_deco_data		flag15,0	;=1: Restore Decodata after the dive from 0x380 buffer
#DEFINE	uart_store_tissue_data	flag15,1	;=1: Store tissue data for next simualted dive!
#DEFINE	reset_average_depth 	flag15,2	;=1: Average Depth will be resetted
#DEFINE	blinking_better_gas		flag15,3	;=1: Gas is currently blinking
#DEFINE	menu3_active			flag15,4	;=1: menu entry three in divemode menu is active
#DEFINE no_deco_customviews		flag15,5	;=1: Selected mode is Apnoe or Gauge
#DEFINE	maxdepth_greater_100m	flag15,6	;=1: Max Depth greater>100m
#DEFINE	show_cns_in_logbook		flag15,7	;=1: Show CNS value in logbook (>= V1.84)


