--======================================================================
-- TI half-adder
--======================================================================
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

-------

entity ha is 
port(
	x1 : in std_logic;
	x2 : in std_logic;
	x3 : in std_logic;
	y1 : in std_logic;
	y2 : in std_logic;
	y3 : in std_logic;
	z_in  : in std_logic;
	c1 : out std_logic;
	c2 : out std_logic;
	c3 : out std_logic;
	s1 : out std_logic;
	s2 : out std_logic;
	s3 : out std_logic);
end entity ha;

architecture str of ha is
begin
	s1 <= x2 xor y2;
	s2 <= x3 xor y3;
	s3 <= x1 xor y1;
	c1 <= (x2 and y2) xor (x2 and y3) xor (x3 and y2) xor z_in;
	c2 <= (x3 and y3) xor (x1 and y3) xor (x3 and y1) xor (x1 and z_in) xor (y1 and z_in);
	c3 <= (x1 and y1) xor (x1 and y2) xor (x2 and y1) xor (x1 and z_in) xor (y1 and z_in) xor z_in;
end architecture str;
	
			
		
	