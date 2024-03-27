--[[
*****************************************************************************************
* Program Script Name	:	A319.opencockpits_rmp_cpt
*
* Author Name			:	xpl11 
*
*   Revisions:
*   -- DATE --	--- REV NO ---		--- DESCRIPTION ---
*                   v1.00			
*
*
*   Opencockpits A320 Usb Radiomodule Cpt.Side for Toliss A319. Use with
*   Ocusbmapper Plugin from Pikitanga
*****************************************************************************************
--]]



--*************************************************************************************--
--** 					              XLUA GLOBALS              				     **--
--*************************************************************************************--

--[[

SIM_PERIOD - this contains the duration of the current frame in seconds (so it is alway a
fraction).  Use this to normalize rates,  e.g. to add 3 units of fuel per second in a
per-frame callback you’d do fuel = fuel + 3 * SIM_PERIOD.

IN_REPLAY - evaluates to 0 if replay is off, 1 if replay mode is on

--]]


--*************************************************************************************--
--** 					               CONSTANTS                    				 **--
--*************************************************************************************--

--*************************************************************************************--
--**                                                                                 **--
--** DEVICE_ARM = Rmp Cpt.Side = 0     Rmp Fo Side = 1                               **--
--** DISPLAY_BRIGHTNESS = (1 - 99)                                                   **--
--**                                                                                 **--
--*************************************************************************************--


DEVICE_ARM = 0
DISPLAY_BRIGHTNESS = 50



--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--

local Power = 0
local rem4 = 0
local rem3 = 0
local rem2 = 0
local rem1 = 0
local rem0 = 0
local x    = 0
local swap = 0
local Vhf1_act = 0
local Vhf2_act = 0
local Light_test_sw = 0
local Rmp2 = 0


--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               FIND X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--

A319_Pk_Rmp_sw          = find_dataref("pikitanga/ocusbmapper/arm/input/switch")
A319_Pk_dspl_act        = find_dataref("pikitanga/ocusbmapper/arm" .. DEVICE_ARM .."/output/dspl/active")
A319_Pk_dspl_stby       = find_dataref("pikitanga/ocusbmapper/arm" .. DEVICE_ARM .."/output/dspl/standby")
A319_Pk_dspl_dec        = find_dataref("pikitanga/ocusbmapper/arm/output/dspl/decimal")
A319_Pk_Rmp_led_adf     = find_dataref("pikitanga/ocusbmapper/arm/output/led/adf")
A319_Pk_Rmp_led_bfo     = find_dataref("pikitanga/ocusbmapper/arm/output/led/bfo")
A319_Pk_Rmp_led_ils     = find_dataref("pikitanga/ocusbmapper/arm/output/led/ils")
A319_Pk_Rmp_led_nav     = find_dataref("pikitanga/ocusbmapper/arm/output/led/nav")
A319_Pk_Rmp_led_sel     = find_dataref("pikitanga/ocusbmapper/arm/output/led/sel")
A319_Pk_Rmp_led_vhf1    = find_dataref("pikitanga/ocusbmapper/arm/output/led/vhf1")
A319_Pk_Rmp_led_vhf2    = find_dataref("pikitanga/ocusbmapper/arm/output/led/vhf2")
A319_Pk_Rmp_led_vor     = find_dataref("pikitanga/ocusbmapper/arm/output/led/vor")
A319_Pk_Rmp_enc_lrg     = find_dataref("pikitanga/ocusbmapper/arm/input/encoder/large")
A319_Pk_Rmp_enc_sml     = find_dataref("pikitanga/ocusbmapper/arm/input/encoder/small")
A319_Pk_Rmp_button_tfr  = find_dataref("pikitanga/ocusbmapper/arm/input/button/tfr")
A319_Pk_Rmp_button_vhf1 = find_dataref("pikitanga/ocusbmapper/arm/input/button/vhf1")
A319_Pk_Rmp_button_vhf2 = find_dataref("pikitanga/ocusbmapper/arm/input/button/vhf2")
A319_Pk_Rmp_dspl_bright = find_dataref("pikitanga/ocusbmapper/arm/output/dspl/brightness")

A319_Bus_powered        = find_dataref("AirbusFBW/ElecConnectors")
A319_Rmp_sw             = find_dataref("AirbusFBW/RMP1Switch")
A319_Ann_light_test     = find_dataref("AirbusFBW/AnnunMode")
A319_Rmp_stby_freq1     = find_dataref("sim/cockpit2/radios/actuators/com1_standby_frequency_hz_833")
A319_Rmp_act_freq1      = find_dataref("sim/cockpit2/radios/actuators/com1_frequency_hz_833")
A319_Rmp_stby_freq2     = find_dataref("sim/cockpit2/radios/actuators/com2_standby_frequency_hz_833")
A319_Rmp_act_freq2      = find_dataref("sim/cockpit2/radios/actuators/com2_frequency_hz_833")


--*************************************************************************************--
--** 				              FIND CUSTOM COMMANDS              			     **--
--*************************************************************************************--

A319_Rmp_enc_lrg_down   = find_command("AirbusFBW/RMP1FreqDownLrg")
A319_Rmp_enc_lrg_up     = find_command("AirbusFBW/RMP1FreqUpLrg")
A319_Rmp_enc_sml_down   = find_command("AirbusFBW/RMP1FreqDownSml")
A319_Rmp_enc_sml_up     = find_command("AirbusFBW/RMP1FreqUpSml")
A319_Rmp_button_tfr     = find_command("AirbusFBW/RMPSwapCapt")
A319_Rmp_button_vhf1    = find_command("AirbusFBW/VHF1Capt")
A319_Rmp_button_vhf2    = find_command("AirbusFBW/VHF2Capt")



--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--



--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             CUSTOM COMMAND HANDLERS            			     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				              CREATE CUSTOM COMMANDS              			     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             X-PLANE COMMAND HANDLERS               	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             REPLACE X-PLANE COMMANDS                  	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				              WRAP X-PLANE COMMANDS                  	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					           OBJECT CONSTRUCTORS         		        		 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                  CREATE OBJECTS              	     			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                 SYSTEM FUNCTIONS           	    			 **--
--*************************************************************************************--

function Dspl_Bright()
   
     A319_Pk_Rmp_dspl_bright[DEVICE_ARM] = DISPLAY_BRIGHTNESS
	 
end

function Rmp_Process()

   if A319_Bus_powered[0] == 1 or A319_Bus_powered[1] == 1 or A319_Bus_powered[2] == 1 or A319_Bus_powered[3] == 1 then
      A319_Rmp_sw = A319_Pk_Rmp_sw[DEVICE_ARM]		
      
      if A319_Rmp_sw == 1 then
	 
         if A319_Ann_light_test == 2 then
            A319_Pk_Rmp_led_adf[DEVICE_ARM]  = 1
            A319_Pk_Rmp_led_bfo[DEVICE_ARM]  = 1
            A319_Pk_Rmp_led_ils[DEVICE_ARM]  = 1
            A319_Pk_Rmp_led_nav[DEVICE_ARM]  = 1
            A319_Pk_Rmp_led_sel[DEVICE_ARM]  = 1
            A319_Pk_Rmp_led_vhf1[DEVICE_ARM] = 1
            A319_Pk_Rmp_led_vhf2[DEVICE_ARM] = 1
            A319_Pk_Rmp_led_vor[DEVICE_ARM]  = 1
            A319_Pk_dspl_stby[5]             = 8
            A319_Pk_dspl_stby[4]             = 8
            A319_Pk_dspl_stby[3]             = 8
            A319_Pk_dspl_stby[2]             = 8
            A319_Pk_dspl_stby[1]             = 8
            A319_Pk_dspl_stby[0]             = 8
            A319_Pk_dspl_act[5]              = 8
            A319_Pk_dspl_act[4]              = 8
            A319_Pk_dspl_act[3]              = 8
            A319_Pk_dspl_act[2]              = 8
            A319_Pk_dspl_act[1]              = 8
            A319_Pk_dspl_act[0]              = 8
            Light_test_sw = 1
         else
            if Light_test_sw == 1 then
               A319_Pk_Rmp_led_adf[DEVICE_ARM]  = 0
               A319_Pk_Rmp_led_bfo[DEVICE_ARM]  = 0
               A319_Pk_Rmp_led_ils[DEVICE_ARM]  = 0
               A319_Pk_Rmp_led_nav[DEVICE_ARM]  = 0
               A319_Pk_Rmp_led_sel[DEVICE_ARM]  = 0
               A319_Pk_Rmp_led_vhf1[DEVICE_ARM] = 0
               A319_Pk_Rmp_led_vhf2[DEVICE_ARM] = 0
               A319_Pk_Rmp_led_vor[DEVICE_ARM]  = 0
               A319_Pk_dspl_stby[5]             = 0
               A319_Pk_dspl_stby[4]             = 0
               A319_Pk_dspl_stby[3]             = 0
               A319_Pk_dspl_stby[2]             = 0
               A319_Pk_dspl_stby[1]             = 0
               A319_Pk_dspl_stby[0]             = 0
               A319_Pk_dspl_act[5]              = 0
               A319_Pk_dspl_act[4]              = 0
               A319_Pk_dspl_act[3]              = 0
               A319_Pk_dspl_act[2]              = 0
               A319_Pk_dspl_act[1]              = 0
               A319_Pk_dspl_act[0]              = 0
               Vhf1_act                         = 0
               Vhf2_act                         = 0
               Light_test_sw = 0
            end
            
         end
         
         if Vhf1_act == 0 and Vhf2_act == 0 then
            A319_Rmp_button_vhf1:once()
            Vhf1_act = 1
            Vhf2_act = 0
            A319_Pk_Rmp_led_vhf1[DEVICE_ARM] = 1
            A319_Pk_Rmp_led_vhf2[DEVICE_ARM] = 0
         end
	 
         if A319_Pk_Rmp_button_vhf1[DEVICE_ARM] == 1 then
            A319_Rmp_button_vhf1:once()
            Vhf1_act = 1
            Vhf2_act = 0
            A319_Pk_Rmp_led_vhf1[DEVICE_ARM] = 1
            A319_Pk_Rmp_led_vhf2[DEVICE_ARM] = 0
         end
	 
         if A319_Pk_Rmp_button_vhf2[DEVICE_ARM] == 1 then
            A319_Rmp_button_vhf2:once()
            Vhf1_act = 0
            Vhf2_act = 1
            A319_Pk_Rmp_led_vhf1[DEVICE_ARM] = 0
            A319_Pk_Rmp_led_vhf2[DEVICE_ARM] = 1
         end
         
         if A319_Pk_Rmp_button_vhf1[1] == 1 then
            Rmp2 = 1
         end
         if A319_Pk_Rmp_button_vhf2[1] == 1 then
            Rmp2 = 0
         end
         
         A319_Pk_dspl_dec[DEVICE_ARM] = 10
         if A319_Pk_Rmp_enc_lrg[DEVICE_ARM] == 1 then
            A319_Rmp_enc_lrg_up:once()
         end
         if A319_Pk_Rmp_enc_lrg[DEVICE_ARM] == -1 then
            A319_Rmp_enc_lrg_down:once()
         end
         if A319_Pk_Rmp_enc_sml[DEVICE_ARM] == 1 then
            A319_Rmp_enc_sml_up:once()
         end
         if A319_Pk_Rmp_enc_sml[DEVICE_ARM] == -1 then
            A319_Rmp_enc_sml_down:once()
         end
         
         rem4 = 0
         rem3 = 0
         rem2 = 0
         rem1 = 0
         rem0 = 0
         

         x = A319_Rmp_stby_freq1
         
         if Light_test_sw < 1 then	
            A319_Pk_dspl_stby[5] = math.floor(x / 100000)
            rem4                 = x % 100000
            A319_Pk_dspl_stby[4] = math.floor(rem4 / 10000)
            rem3                 = rem4 % 10000
            A319_Pk_dspl_stby[3] = math.floor(rem3 / 1000)
            rem2                 = rem3 % 1000
            A319_Pk_dspl_stby[2] = math.floor(rem2 / 100)
            rem1                 = rem2 % 100
            A319_Pk_dspl_stby[1] = math.floor(rem1 / 10)
            rem0                 = rem1 % 10
            A319_Pk_dspl_stby[0] = rem0
         end	
         
         rem4 = 0
         rem3 = 0
         rem2 = 0
         rem1 = 0
         rem0 = 0
         
         if Vhf1_act == 1 then
            x = A319_Rmp_act_freq1
            if Rmp2 == 1 and A319_Pk_Rmp_sw[1] == 1 then
               A319_Pk_Rmp_led_sel[DEVICE_ARM] = 1
            else
               A319_Pk_Rmp_led_sel[DEVICE_ARM] = 0
            end
         else
            x = A319_Rmp_act_freq2
            A319_Pk_Rmp_led_sel[DEVICE_ARM] = 1
            if A319_Pk_Rmp_sw[1] == 1 and A319_Pk_Rmp_sw[DEVICE_ARM] == 1 then
               A319_Pk_Rmp_led_sel[1] = 1
            end		  
         end   

         if Light_test_sw < 1 then
            A319_Pk_dspl_act[5] = math.floor(x / 100000)
            rem4                 = x % 100000
            A319_Pk_dspl_act[4] = math.floor(rem4 / 10000)
            rem3                 = rem4 % 10000
            A319_Pk_dspl_act[3] = math.floor(rem3 / 1000)
            rem2                 = rem3 % 1000
            A319_Pk_dspl_act[2] = math.floor(rem2 / 100)
            rem1                 = rem2 % 100
            A319_Pk_dspl_act[1] = math.floor(rem1 / 10)
            rem0                 = rem1 % 10
            A319_Pk_dspl_act[0] = rem0
         end	
         
         if A319_Pk_Rmp_button_tfr[DEVICE_ARM] == 1 and swap == 0 then
            A319_Rmp_button_tfr:once()
            swap = 1
         else
            if A319_Pk_Rmp_button_tfr[DEVICE_ARM] == 0 then
               swap = 0
            end			 
         end
         
      else
         power = 0
         while power < 6 do
            A319_Pk_dspl_act[power] = 10
            A319_Pk_dspl_stby[power] = 10
            power = power + 1
         end
         A319_Pk_dspl_dec[DEVICE_ARM] = 0
         A319_Pk_Rmp_led_adf[DEVICE_ARM]  = 0
         A319_Pk_Rmp_led_bfo[DEVICE_ARM]  = 0
         A319_Pk_Rmp_led_ils[DEVICE_ARM]  = 0
         A319_Pk_Rmp_led_nav[DEVICE_ARM]  = 0
         A319_Pk_Rmp_led_sel[DEVICE_ARM]  = 0
         A319_Pk_Rmp_led_vhf1[DEVICE_ARM] = 0
         A319_Pk_Rmp_led_vhf2[DEVICE_ARM] = 0
         A319_Pk_Rmp_led_vor[DEVICE_ARM]  = 0
         Vhf1_act = 0
         Vhf2_act = 0		
      end
      
   else
      power = 0
      while power < 6 do
         A319_Pk_dspl_act[power] = 10
         A319_Pk_dspl_stby[power] = 10
         power = power + 1
      end
      A319_Pk_dspl_dec[DEVICE_ARM] = 0
      A319_Pk_Rmp_led_adf[DEVICE_ARM]  = 0
      A319_Pk_Rmp_led_bfo[DEVICE_ARM]  = 0
      A319_Pk_Rmp_led_ils[DEVICE_ARM]  = 0
      A319_Pk_Rmp_led_nav[DEVICE_ARM]  = 0
      A319_Pk_Rmp_led_sel[DEVICE_ARM]  = 0
      A319_Pk_Rmp_led_vhf1[DEVICE_ARM] = 0
      A319_Pk_Rmp_led_vhf2[DEVICE_ARM] = 0
      A319_Pk_Rmp_led_vor[DEVICE_ARM]  = 0
      A319_Pk_Rmp_led_sel[DEVICE_ARM]  = 0
   end	
   
end




--*************************************************************************************--
--** 				               XLUA EVENT CALLBACKS       	        			 **--
--*************************************************************************************--

--function aircraft_load() end

--function aircraft_unload() end

--function flight_crash() end

function flight_start()

   Dspl_Bright()

end

function before_physics()


   Rmp_Process()

end

--function after_physics() end

--function after_replay() end

--*************************************************************************************--
--** 				               SUB-MODULE PROCESSING       	        			 **--
--*************************************************************************************--

-- dofile("")
