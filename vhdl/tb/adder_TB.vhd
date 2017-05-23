--======================================================================
-- adder_4btit TB
--======================================================================
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity adder_TB is
	generic (num_bits : integer := 32);
end entity;

architecture tb of adder_TB is

component adder 
	generic (
		num_bits : integer := 32);
	port(
	x: in std_logic_vector(num_bits-1 downto 0);
	y: in std_logic_vector(num_bits-1 downto 0);
	rst_n : in std_logic;
	rand_1   : in std_logic_vector(num_bits-1 downto 0);
	rand_2   : in std_logic_vector(num_bits-1 downto 0);
	rand_3   : in std_logic_vector(num_bits-1 downto 0);
	rand_4   : in std_logic_vector(num_bits-1 downto 0);
	rand_1bit : in std_logic_vector(num_bits-1 downto 0);
	adder_en: in std_logic;
	clk	: in std_logic;
	data_out_valid: out std_logic;
	s: out std_logic_vector(num_bits-1 downto 0);
	c_out: out std_logic_vector(7 downto 0));
end component adder;

signal x_t,y_t,s_t : std_logic_vector(num_bits-1 downto 0);
signal rst_n_t,adder_en_t,data_out_valid_t: std_logic;
signal clk_t:std_logic;
signal seed_DV_t:std_logic;
signal rand_1_t,rand_2_t,rand_3_t,rand_4_t:std_logic_vector(num_bits-1 downto 0);
signal rand1b_t : std_logic_vector(31 downto 0);
signal c_out_t : std_logic_vector(7 downto 0);

begin
adder_tb: adder port map(x_t,y_t,rst_n_t,rand_1_t,rand_2_t,rand_3_t,rand_4_t,rand1b_t,adder_en_t,clk_t,data_out_valid_t,s_t,c_out_t);
process
    begin
 	clk_T <= '0';
 	wait for 5 ns;
	clk_T <= '1';
	wait for 5 ns;
    end process;
	
	process	
	
	begin
    rst_n_t <='0';
    wait for 10 ns;
    rst_n_t <='1';
	wait for 10 ns;
	adder_en_t <= '1';
	rand_1_t <= x"100da202";
	rand_2_t <=  x"100da202";
	rand_3_t <=  x"243dacb2";
	rand_4_t <=  x"ab32a201";
	rand1b_t <= x"00000002";
	x_t <= x"a206a206";
	y_t <= x"a206a206";
	wait for 10 ns;
	adder_en_t <= '0';
	wait for 500 ns;
	adder_en_t <= '1';
	x_t <= x"80000000";
	y_t <= x"80000000";
	rand_1_t <= (others => 'Z');
	rand_2_t <=  (others => 'Z');
	rand_3_t <=  (others => 'Z');
	rand_4_t <= (others => 'Z');
	rand1b_t <= (others => 'Z');
	wait for 10 ns;
	adder_en_t <= '0';
	wait for 500 ns;
	adder_en_t <= '1';
	x_t <= x"54205420";
	y_t <= x"de5fde5f";
	wait for 10 ns;
	adder_en_t <= '0';
	wait for 500 ns;
	adder_en_t <= '1';
	x_t <= x"109f109f";
	y_t <= x"09460946";
	wait for 10 ns;
	adder_en_t <= '0';
	wait for 500 ns;
	adder_en_t <= '1';
	x_t <= x"ffffffff";
	y_t <= x"00000001";
	wait for 10 ns;
	adder_en_t <= '0';
	wait for 500 ns;
	adder_en_t <= '1';
	x_t <= x"afffafff";
	y_t <= x"a00110de";
	wait for 10 ns;
	adder_en_t <= '0';
	wait for 500 ns;
	adder_en_t <= '1';
	x_t <= x"a2074502";
	y_t <= x"a216ffef";
	wait for 10 ns;
	adder_en_t <= '0';
	wait;	
    end process;
	
end architecture;