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

-- x and y are also random shares
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
    rand_1bit_1 : in std_logic_vector(num_bits-1 downto 0);
    rand_1bit_2 : in std_logic_vector(num_bits-1 downto 0);
    adder_en: in std_logic;
    clk : in std_logic;
    data_out_valid: out std_logic;
    s: out std_logic_vector(num_bits-1 downto 0);
    c_out: out std_logic_vector(7 downto 0));
end component adder;

signal x_t,y_t,s_t : std_logic_vector(num_bits-1 downto 0);
signal rst_n_t,adder_en_t,data_out_valid_t: std_logic;
signal clk_t:std_logic;
signal x_real, y_real,rand_1_t,rand_2_t,rand_3_t,rand_4_t:std_logic_vector(num_bits-1 downto 0);
signal rand1b_t_1, rand1b_t_2: std_logic_vector(31 downto 0);
signal c_out_t : std_logic_vector(7 downto 0);
signal num_random: std_logic_vector (31 downto 0);

begin
adder_tb: adder port map(x_t,y_t,rst_n_t,rand_1_t,rand_2_t,rand_3_t,rand_4_t,rand1b_t_1,rand1b_t_2,adder_en_t,clk_t,data_out_valid_t,s_t,c_out_t);
process
    begin
    clk_T <= '0';
    wait for 5 ns;
    clk_T <= '1';
    wait for 5 ns;
    end process;
    
    process(x_real,y_real)
    begin
    x_t <= rand_1_t xor rand_2_t xor x_real;
    y_t <= rand_3_t xor rand_4_t xor y_real;
    end process;
    
    process 
    
    begin
    rst_n_t <='0';
    wait for 10 ns;
    rst_n_t <='1';
    wait for 10 ns;
    adder_en_t <= '1';
    rand_1_t <= x"100da202";
    rand_2_t <=  x"2f4e4310";
    x_real <= x"a206a206";
    rand_3_t <=  x"243dacb2";
    rand_4_t <=  x"ab32a201";
    y_real <= x"a206a206";
    rand1b_t_1 <= x"00000002";
    rand1b_t_2 <= x"00000001";
    
    wait for 10 ns;
    adder_en_t <= '0';
    wait for 5000 ns;
    adder_en_t <= '1';
    rand_1_t <= x"125f810e";
    rand_2_t <=  x"ef709ff8";
    x_real <= x"80000000";
    rand_3_t <=  x"950ef649";
    rand_4_t <=  x"809f6309";
    y_real <= x"80000000";
    rand1b_t_1 <= x"00000002";
    rand1b_t_2 <= x"00000001";
    
    wait for 10 ns;
    adder_en_t <= '0';
    wait for 5000 ns;
    adder_en_t <= '1';
    rand_1_t <= x"fe87f908";
    rand_2_t <=  x"5026fab9";
    x_real <= x"54205420";
    rand_3_t <=  x"5f2970fe";
    rand_4_t <=  x"63084bae";
    y_real <= x"de5fde5f";
    rand1b_t_1 <= x"00000002";
    rand1b_t_2 <= x"00000001";
    
    
    wait for 10 ns;
    adder_en_t <= '0';
    wait for 5000 ns;
    adder_en_t <= '1';
    rand_1_t <= x"efab8905";
    rand_2_t <=  x"23894000";
    x_real <= x"109f109f";
    rand_3_t <=  x"eef87501";
    rand_4_t <=  x"5603298e";
    y_real <= x"09460946";
    rand1b_t_1 <= x"00000002";
    rand1b_t_2 <= x"00000001";
    
    wait for 10 ns;
    adder_en_t <= '0';
    wait for 5000 ns;
    adder_en_t <= '1';
    rand_1_t <= x"6530feba";
    rand_2_t <=  x"bba68790";
    x_real <= x"ffffffff";
    rand_3_t <=  x"fba26894";
    rand_4_t <=  x"890ef569";
    y_real <= x"00000001";
    rand1b_t_1 <= x"00000002";
    rand1b_t_2 <= x"00000001";
    
    wait for 10 ns;
    adder_en_t <= '0';
    wait for 5000 ns;
    adder_en_t <= '1';
    x_real <= x"afffafff";
    y_real <= x"a00110de";
    wait for 10 ns;
    adder_en_t <= '0';
    wait for 5000 ns;
    adder_en_t <= '1';
    x_real <= x"a2074502";
    y_real <= x"a216ffef";
    wait for 10 ns;
    adder_en_t <= '0';
    wait;   
    end process;
    
end architecture;