library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- *Description of system and code*

-- This code was written by Celine Karam and Gaelle Zgheib for project 17 of the microprocessors course.
-- It implements a conveyor system that sorts 3 different sizes of boxes:
-- 1 (small) ,2 (medium), 3 (large) by relying on their height.
-- Users can interact with the system through switches and buttons.

-- *Steps*

-- 1) The user-defines the operational mode with KEY0 button: automatic or manual.

-- 2) Introduction of boxes of varied sizes (small, medium, large) onto the conveyor.

-- 3) Automatic Sorting mode:
--		a) The sensors detect box sizes.
--		b) The sorter rotates to align with the appropriate lane of the detected box size.
--       LEDs and HEX displays showcase the box size.

-- 4) Manual Sorting Mode:
--		a) The operator employs the 2 switches to guide the sorter based on the box size the operator sees.
--		b) The sorter rotates to align with the appropriate lane selected by the user.
--    LEDs and HEX displays showcase the lane the box is directed to.


-- *Sorter*

-- A “High Speed Steerable Wheel Sorter” will be used to sort the boxes on the 3 lanes.
-- The “sorter” has rollers that can rotate around their axis.
-- In addition, the axis of the rollers can steer (rotate around a vertical axis) by +/- 90 degrees relative to the forward direction.
-- The sorter takes 2 bits: 00 (power off), 01 (left: lane 1), 10 (right: lane 2), 11 (forward: lane 3).

-- *LEDs*

-- LEDR3 TO LEDR0 will turn on for their respective lanes. 
-- In case of error or invalid input, all the 4 LEDs will turn on.

-- *Mode of operation*

-- The button KEY0 is used to select the mode: 0 for automatic (sensors) or 1 for manual (switches).

-- *Automatic mode*

-- The reflective sensor measures the time between submission of signal and its reception. 
-- d: distance between sensor and reflector, c: velocity of light.
-- If no box is between the sensor and reflector, the time of reception is 2*d/c, the sensor gives ‘0’.
-- So, if time of reception < 2d/c, then a box is detected and the sensor gives '1'.

-- 3 reflective sensors will be used to detect the different heights of the boxes. 
-- The upper (S3), middle (S2), and lower (S1) sensors will be fixed on a support and positioned such that:
-- The box of size 1 will be detected by the lower sensor only, so S3 & S2 & S1 = “001”.
-- The box of size 2 will be detected by both the lower and the middle sensor, so S3 & S2 & S1 = “011”.
-- The box of size 3 will be detected by the 3 sensors, so S3 & S2 & S1 = “111”.
-- If S3 & S2 & S1 = “000”, no box is detected and the outputs won't change (transition phase).

-- In case of any other value, there's an error:
-- (i.e.: one sensor is deteriorated; a technician placed his hand that was detected by S3).

-- The large box (size 3) will be transferred forward on the same lane because it’s the biggest:
-- (it will be more difficult to steer it than the other smaller ones).
-- HEX5 to HEX0 will display one of the following messages, “error”, “size 1”, “size 2”, “size 3”.

-- *Manual mode*

-- The 2 switches SW1, SW0 are used to direct the sorter to a certain lane:
-- SW1 & SW0 = 00 forward (lane 3), or 01 left (lane 1), or 10 right (lane 2) or 11 (invalid input).
-- HEX5 to HEX0 will display one of the following messages, “lane1”, “lane2”, “lane3”.

-- *Assumptions*

-- The conveyor is continuously moving at same speed.
-- The boxes can reflect the light emitted by reflective sensors. 
-- The gap between 2 consecutive boxes is enough for each box to be transferred each at a time:
-- There is time between a box being transferred to its lane and the following box to face the sensors.

entity Project_17 is
 port (
  -- Inputs  
  KEY0         : in  std_logic; -- pushbutton
  SW1, SW0     : in  std_logic; -- switches 
  S3, S2, S1   : in  std_logic; -- sensors
  -- Outputs
  sorter     : out std_logic_vector(1 downto 0);
  LEDR3, LEDR2, LEDR1, LEDR0: out std_logic; -- LEDs
  HEX5, HEX4, HEX3, HEX2, HEX1, HEX0 : out std_logic_vector(6 downto 0) -- HEX displays
 );
end Project_17;

architecture Behavioral of Project_17 is
 
 signal Sensors  : std_logic_vector(2 downto 0);
 signal Switches : std_logic_vector(1 downto 0);
 signal Leds     : std_logic_vector(3 downto 0);

begin

 Sensors <= S3 & S2 & S1; -- Concatenate sensor signals into a 3-bit vector
 Switches <= SW1 & SW0;   -- Concatenate switch signals into a 2-bit vector

 process (KEY0, sensors, switches) 
 -- The process will wake up if there is a variation in the inputs from:
 -- the push button, sensors, or switches
 begin
			
	if (KEY0 = '0') then -- automatic (rely on sensors)
		 
		 if Sensors = "010" or Sensors = "100" or Sensors = "101" or Sensors = "110" then -- error
		 
			  Leds <= "1111"; -- all LEDs are ON to signal an error
			  HEX4 <= "0000100"; -- e
			  HEX3 <= "1001110"; -- r
			  HEX2 <= "1001110"; -- r
			  HEX1 <= "1000000"; -- o
			  HEX0 <= "1001110"; -- r
			  -- Display: "error"
			  sorter <= "00";   -- The sorter will be turned off
		 
		 elsif Sensors = "001" then-- box of size 1 detected
		 
			  Leds <= "0001"; -- the 1st LED is ON to signal that the box of size 1 is detected
			  HEX4 <= "0010010"; -- s
			  HEX3 <= "1111001"; -- i
			  HEX2 <= "0100100"; -- z
			  HEX1 <= "0000100"; -- e
			  HEX0 <= "1111001"; -- 1
			  -- Display: "size1"
			  sorter <= "01";   -- The sorter will align its rollers with lane 1
		 
		 elsif Sensors = "011" then-- box of size 2 detected
		 
		 	  Leds <= "0010"; -- the 2nd LED is ON to signal that the box of size 2 is detected
			  HEX4 <= "0010010"; -- s
			  HEX3 <= "1111001"; -- i
			  HEX2 <= "0100100"; -- z
			  HEX1 <= "0000100"; -- e
			  HEX0 <= "0100100"; -- 2
			  -- Display: "size2"
			  sorter <= "10";   -- The sorter will align its rollers with lane 2
		 
		 elsif Sensors = "111" then -- box of size 3 detected
			  
			  Leds <= "0100"; -- the 3rd LED is ON to signal that the box of size 3 is detected
			  HEX4 <= "0010010"; -- s
			  HEX3 <= "1111001"; -- i
			  HEX2 <= "0100100"; -- z
			  HEX1 <= "0000100"; -- e
			  HEX0 <= "0110000"; -- 3
			  -- Display: "size3"
			  sorter <= "11";  -- The sorter will align its rollers with lane 3	  
		 
		 -- There is no condition for Sensors = "000" (when no box is detected)
		 -- It's because it's a transition phase: 
		 -- The outputs should stay as they were for the previously detected box
		 
		 end if;
	
	else -- manual (rely on switches)
		 
		 case Switches is
			  
			  when "00" =>
					
					Leds <= "0100";
					-- 3rd LED is ON to signal that the box will be transferred forward to lane 3
					HEX4 <= "1111001"; -- l
					HEX3 <= "0100000"; -- a
					HEX2 <= "0101011"; -- n
					HEX1 <= "0000100"; -- e
					HEX0 <= "0110000"; -- 3
					-- Display: "lane3"
					sorter <= "11";
					-- The sorter will align its rollers with the direction of lane 3
			  
			  when "01" =>
					
					Leds <= "0001"; 
					-- 1st LED is ON to signal that the box will be transferred left to lane 1
					HEX4 <= "1111001"; -- l
					HEX3 <= "0100000"; -- a
					HEX2 <= "0101011"; -- n
					HEX1 <= "0000100"; -- e
					HEX0 <= "1111001"; -- 1
					-- Display: "lane1"
					sorter <= "01";   
					-- The sorter will align its rollers with the direction of lane 1
			  
			  when "10" =>
					
					Leds <= "0010"; 
					-- 2nd LED is ON to signal that the the box will be transferred right to lane 2
					HEX4 <= "1111001"; -- l
					HEX3 <= "0100000"; -- a
					HEX2 <= "0101011"; -- n
					HEX1 <= "0000100"; -- e
					HEX0 <= "0100100"; -- 2
					-- Display: "lane2"
					sorter <= "10";   
					-- The sorter will align its rollers with the direction of lane 2
			  
			  when others => -- 11
					
					Leds <= "1111"; -- no valid switch input: all LEDs are on
					HEX4 <= "1111001"; -- l
					HEX3 <= "0100000"; -- a
					HEX2 <= "0101011"; -- n
					HEX1 <= "0000100"; -- e
					HEX0 <= "0110000"; -- 3
					-- Display: "lane3"
					sorter <= "11";   -- The sorter will be directed forward by default
		 
		 end case;
	
	end if;
	
	LEDR3 <= Leds(3);
	LEDR2 <= Leds(2);
	LEDR1 <= Leds(1);
	LEDR0 <= Leds(0);

end process;

end Behavioral;
