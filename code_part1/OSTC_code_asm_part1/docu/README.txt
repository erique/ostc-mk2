To recompile the OSTC code you will need to install the following:
------------------------------------------------------------------

 - A Mercurial client, to download the source code and updates easily.
   TortoiseHg is free, and works well.

 - The Microchip MPLab IDE. This is free, and enable to recompile
   all the assembly code, link, and produce a .hex file.

 - If you want to modify the decompression algorithm, you will also
   need the MPLab C18 compiler. There is a demo free for the first
   30 days.
   If you don't modify p2_deco.c, you don't need the C18 compiler,
   see below.

 - The Tiny bootloader for windows, see the HW site.


Creating a working project:
---------------------------

 - Launch the MPLab IDE.

 - Create a new project (Project > Project Wizard...)
   - Choose device PIC18F4685
   - Select Microchip C18 Toolsuite   (if you installed the C18 compiler)
     or     Microchip MPASM Toolsuite (if not)
     --> Make sure the paths are corect.
   - Choose a name and a directoty.

   - Add the following files:
     <my_source_path>/code_part1/OSTC_code_asm_part1/18f4685_ostc_mkII.lkr
     <my_source_path>/code_part1/OSTC_code_asm_part1/MAIN.ASM
     <my_source_path>/code_part1/OSTC_code_c_part2/p2_deco.o

     (or use the .c instead of the .o if you have the C18 compiler)

   - If you want to compile C code, configure it:
     Project > Build Options... > Project > MPLab C18
         General: Default storage = Overlay (-sco)
         Optimization: Enable all

 - Hit F10 to recompile everything.
   --> You should get a .hex file where you saved your project.


Installing the new firmware
---------------------------

 - Get the .hew file you want to flash onto the OSTC.

 - Connect the OSTC, wake it up.

 - Launch the Tiny bootloader. It should work for some time, trying to open
   the communication port.

 - Once it is ready, Click Browse to select the .hex file
   ==> DO NOT HIT Write Flash YET !

 - On the OSTC, go to the reset menu, select Reboot OSTC
   ==> DO NOT CONFIRM YET !

 - Click "Write Flash" button. Now you have 10sec to confirm on OSTC too.

 - The bootloader should say it found a PIC18F6485 device, and start uploading.
   The OSTC should have the blue and red led blinking rapidly.
   The upload time is ~ 1 minute.

 - Once done, the OSTC finishes its reboot.

 - If you OSTC is stuck in some bad code, you can do the magic magnet reset
   instead of choosing the reboot menu, during the 10sec timeslot after
   starting bootloader write flash.



