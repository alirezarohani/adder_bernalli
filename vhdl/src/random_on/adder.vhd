--======================================================================
-- adder_4btit
--======================================================================
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
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
    clk : in std_logic;
    data_out_valid: out std_logic;
    s: out std_logic_vector(num_bits-1 downto 0);
    c_out: out std_logic_vector(7 downto 0));
end entity adder;

architecture str of adder is

--data path
component  adder_dp 
    generic( num_bits : integer := 32);
    port(
    x: in std_logic_vector(num_bits-1 downto 0);
    y: in std_logic_vector(num_bits-1  downto 0);
    rst_n : in std_logic;
    clk : in std_logic;
    sel: in std_logic;
    rn32b_1   : in std_logic_vector(num_bits-1  downto 0);
    rn32b_2   : in std_logic_vector(num_bits-1  downto 0);
    rn32b_3   : in std_logic_vector(num_bits-1  downto 0);
    rn32b_4   : in std_logic_vector(num_bits-1  downto 0);
    rn1b      : in std_logic;
    --sel_rand : in std_logic;
    load_s_1: in std_logic_vector(num_bits  downto 0);
    load_s_2: in std_logic_vector(num_bits  downto 0);
    load_s_3: in std_logic_vector(num_bits  downto 0);
    load_c_1: in std_logic_vector(num_bits  downto 0);
    load_c_2: in std_logic_vector(num_bits  downto 0);
    load_c_3: in std_logic_vector(num_bits  downto 0);
    sel_z   : in std_logic_vector(num_bits downto 1);
    s: out std_logic_vector(num_bits-1  downto 0);
    c_out: out std_logic);
    end component adder_dp;

--controller
component adder_ctrl generic (
            num_bits : integer := 32);
    port(
        clk: in std_logic;
        reset_n : in std_logic;
        adder_en: in std_logic;
        
        --sel_rand : out std_logic;
        load_s_1: out std_logic_vector(num_bits downto 0);
        load_s_2: out std_logic_vector(num_bits downto 0);
        load_s_3: out std_logic_vector(num_bits downto 0);
        load_c_1: out std_logic_vector(num_bits downto 0);
        load_c_2: out std_logic_vector(num_bits downto 0);
        load_c_3: out std_logic_vector(num_bits downto 0);
        sel_z   : out std_logic_vector(num_bits downto 1);
        sel : out std_logic;
        
        data_out_valid: out std_logic);
        
    end component adder_ctrl;

signal sel_t:std_logic;
signal load_s_1_t,load_s_2_t,load_s_3_t,load_c_1_t,load_c_2_t,load_c_3_t : std_logic_vector(num_bits downto 0);
signal sel_z_t: std_logic_vector(num_bits downto 1);
signal c_out_t: std_logic_vector(7 downto 0) := (others => '0'); 

begin
adder_datapath:adder_dp port map(x,y,rst_n,clk,sel_t,rand_1,rand_2,rand_3,rand_4,rand_1bit(0),load_s_1_t,load_s_2_t,load_s_3_t,load_c_1_t,load_c_2_t,load_c_3_t,sel_z_t,s,c_out_t(0));
adder_controller:adder_ctrl port map(clk,rst_n,adder_en,load_s_1_t,load_s_2_t,load_s_3_t,load_c_1_t,load_c_2_t,load_c_3_t,sel_z_t,sel_t,data_out_valid);
c_out <= c_out_t;

end architecture str;

