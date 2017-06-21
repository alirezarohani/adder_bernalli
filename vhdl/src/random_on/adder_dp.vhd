--======================================================================
-- 4_bit adder
--======================================================================
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------

entity adder_dp is 
generic (
        num_bits: integer := 32);
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
    rn1b_1      : in std_logic;
    rn1b_2      : in std_logic;
    --sel_rand : in std_logic;
    load_s_1: in std_logic_vector(num_bits  downto 0);
    load_s_2: in std_logic_vector(num_bits  downto 0);
    load_s_3: in std_logic_vector(num_bits  downto 0);
    load_c_1: in std_logic_vector(num_bits  downto 0);
    load_c_2: in std_logic_vector(num_bits  downto 0);
    load_c_3: in std_logic_vector(num_bits  downto 0);
    sel_z   : in std_logic;
    s: out std_logic_vector(num_bits-1  downto 0);
    c_out: out std_logic);
end entity adder_dp;
    
architecture str of adder_dp is

    component ha
        port(
        x1 : in std_logic;
        x2 : in std_logic;
        x3 : in std_logic;
        y1 : in std_logic;
        y2 : in std_logic;
        y3 : in std_logic;
        z_in_1  : in std_logic;
        z_in_2  : in std_logic;
        c1 : out std_logic;
        c2 : out std_logic;
        c3 : out std_logic;
        s1 : out std_logic;
        s2 : out std_logic;
        s3 : out std_logic);
    end component ha;
    
    component reg 
        port(   
        I:  in std_logic;
        clock:  in std_logic;
        load:   in std_logic;
        clear:  in std_logic;
        Q:  out std_logic);
    end component reg;
    
    component mux
        port(   
        I0:     in std_logic;
        I1:     in std_logic;
        sel:    in std_logic;
        z:  out std_logic);
    end component mux;  
    
    signal tmp1x,tmp2x,tmp3x,tmp1y,tmp2y,tmp3y: std_logic_vector(num_bits  downto 0);
    signal tmp_c_1,tmp_c_2,tmp_c_3, tmp_s_1, tmp_s_2,tmp_s_3: std_logic_vector(num_bits  downto 0);
    signal s_1_out, s_2_out,s_3_out : std_logic_vector(num_bits  downto 0);
    signal c_1_out, c_2_out,c_3_out : std_logic_vector(num_bits  downto 0);
    signal x_in_1, x_in_2,x_in_3 : std_logic_vector(num_bits  downto 0);
    signal y_in_1, y_in_2,y_in_3 : std_logic_vector(num_bits  downto 0);
    --signal mux_i_1_z, mux_i_2_z,mux_i_3_z,mux_i_4_z : std_logic_vector(num_bits-1  downto 0);
    -- generating random value for z
    --signal z_in_t: std_logic;
    signal c_out_t: std_logic;
    signal mux_z_output_1,mux_z_output_2 : std_logic;

    
    begin

    --------------------------------------------------------------
    
    -- 32 mux to select between external random number or the output of previous round. sel_input alternates the inputs
    -- MUX_INPUT: for i in 0 to num_bits-1 generate
            -- mux_input_1:mux port map(rn32b_1(i),s_1_out(i),sel_rand,mux_i_1_z(i));
            -- mux_input_2:mux port map(rn32b_2(i),s_2_out(i),sel_rand,mux_i_2_z(i));
            -- mux_input_3:mux port map(rn32b_3(i),s_2_out(i),sel_rand,mux_i_3_z(i));
            -- mux_input_4:mux port map(rn32b_4(i),s_3_out(i),sel_rand,mux_i_4_z(i));
    -- end generate;
    
    --MUX_INPUT_1bit: mux port map(rn1b,c_out_t,sel_rand,z_in_t);
    
    
    
    ---------------------------------------------------------------
    --to select one random bit from outside or from last half-adder (tmp2y and tmp2y)
    mux_z_1:mux port map(rn1b_1,tmp_s_1(num_bits-1),sel_z,mux_z_output_1);
    mux_z_2:mux port map(rn1b_2,tmp_s_2(num_bits-1),sel_z,mux_z_output_2);
    
    
    ---------------------------------------------------------------
    
    --- all the shares are coming from outside (UART)
    x_share: for i in 0 to num_bits-1 generate
            x_in_1(i) <= rn32b_1(i);
            x_in_2(i) <= rn32b_2(i);
            x_in_3(i) <= x(i);
            --x_in_3(i) <= x_in_1(i) xor x_in_2(i) xor x(i);
    
            y_in_1(i) <= rn32b_3(i);
            y_in_2(i) <= rn32b_4(i);
            y_in_3(i) <= y(i);
            --y_in_3(i) <= y_in_1(i) xor y_in_2(i) xor y(i);
        
            --z_in_t <= mux_i_1_z(0);
    end generate;
    
    -- one extra layer added to computer C_out
    x_in_1(num_bits) <= '0';
    x_in_2(num_bits) <= '0';
    x_in_3(num_bits) <= '0';
    
    y_in_1(num_bits) <= '0';
    y_in_2(num_bits) <= '0';
    y_in_3(num_bits) <= '0';
    
    --------------------------------------------------------- mux in front of half adders
    --three sets of mux to share x  
    -- for the first share of x
    MUX_x_1: for i in 0 to num_bits generate
            mux_x_1_first:if i=0 generate
                mux_1: mux port map (x_in_1(i),'0',sel,tmp1x(i));
            end generate;
            mux_x_1_nexts:if i>=1 generate
                mux_1n: mux port map (x_in_1(i),c_1_out(i-1),sel,tmp1x(i));
            end generate;
    end generate;
    
    -- for the second share of x
    MUX_x_2: for i in 0 to num_bits generate
            mux_x_2_first:if i=0 generate
                mux_2: mux port map (x_in_2(i),'0',sel,tmp2x(i));
            end generate;
            mux_x_2_nexts:if i>=1 generate
                mux_2n: mux port map (x_in_2(i),c_2_out(i-1),sel,tmp2x(i));
             end generate;
    end generate;
    
    -- for the third share of x
    MUX_x_3: for i in 0 to num_bits generate
            mux_x_3_first:if i=0 generate
                mux_3: mux port map (x_in_3(i),'0',sel,tmp3x(i));
            end generate;
            mux_x_3_nexts:if i>=1 generate
                mux_3n: mux port map (x_in_3(i),c_3_out(i-1),sel,tmp3x(i));
            end generate;
    end generate;
    
    --three sets of mux to share y  
    -- for the first share of y
    MUX_y_1: for i in 0 to num_bits generate
            mux_y_1_first:if i=0 generate
                mux_y: mux port map (y_in_1(i),s_1_out(i),sel,tmp1y(i));
            end generate;
            mux_y_1_nexts:if i>=1 generate
                mux_1n: mux port map (y_in_1(i),s_1_out(i),sel,tmp1y(i));
            end generate;
    end generate;
    
    -- for the second share of y
    MUX_y_2: for i in 0 to num_bits generate
            mux_y_2_first:if i=0 generate
                mux_2: mux port map (y_in_2(i),s_2_out(i),sel,tmp2y(i));
            end generate;
            mux_y_2_nexts:if i>=1 generate
                mux_2n: mux port map (y_in_2(i),s_2_out(i),sel,tmp2y(i));
            end generate;
    end generate;
    
    -- for the third share of y
    MUX_y_3: for i in 0 to num_bits generate
            mux_y_3_first:if i=0 generate
                mux_3: mux port map (y_in_3(i),s_3_out(i),sel,tmp3y(i));
            end generate;
            mux_y_3_nexts:if i>=1 generate
                mux_3n: mux port map (y_in_3(i),s_3_out(i),sel,tmp3y(i));
            end generate;
    end generate;
    
    
    ---------------------------------------------------------------------------------------
    ---- Half adders -- one more to preserve carry out
    
    HALF_ADDERS: for i in 0 to num_bits  generate
            first_ha: if i=0 generate
                first:ha port map (tmp1x(i),tmp2x(i),tmp3x(i),tmp1y(i),tmp2y(i),tmp3y(i),mux_z_output_1,mux_z_output_2,tmp_c_1(i),tmp_c_2(i),tmp_c_3(i),tmp_s_1(i),tmp_s_2(i),tmp_s_3(i));
                end generate;
                
            next_ha: if 1<=i and i<=num_bits generate
                half_adders: ha port map (tmp1x(i),tmp2x(i),tmp3x(i),tmp1y(i),tmp2y(i),tmp3y(i), tmp_s_1(i-1),tmp_s_2(i-1),tmp_c_1(i),tmp_c_2(i),tmp_c_3(i),tmp_s_1(i),tmp_s_2(i),tmp_s_3(i));
                end generate;
                    
    end generate HALF_ADDERS;
    
    
    ----------------------------------------------------------------------------------------------
    -- three 33-bit registers to keep three shares of of S
    S_1_regs:for i in 0 to num_bits generate
        s_1:reg port map(tmp_s_1(i),clk,load_s_1(i),rst_n,s_1_out(i));
    end generate S_1_regs;
    
    S_2_regs:for i in 0 to num_bits generate
        s_2:reg port map(tmp_s_2(i),clk,load_s_2(i),rst_n,s_2_out(i));
    end generate S_2_regs;
    
    S_3_regs:for i in 0 to num_bits generate
        s_3:reg port map(tmp_s_3(i),clk,load_s_3(i),rst_n,s_3_out(i));
    end generate S_3_regs;
    
    
    -- three 32-bit registers to keep three shares of of C
    C_1_regs: for i in 0 to num_bits generate
        c_1: reg port map(tmp_c_1(i),clk,load_c_1(i),rst_n, c_1_out(i));
    end generate C_1_regs;
    
    C_2_regs: for i in 0 to num_bits generate
        c_2: reg port map(tmp_c_2(i),clk,load_c_2(i),rst_n,c_2_out(i));
    end generate C_2_regs;
    
    C_3_regs: for i in 0 to num_bits generate
        c_3: reg port map(tmp_c_3(i),clk,load_c_3(i),rst_n,c_3_out(i));
    end generate C_3_regs;
    
    ------------------------------------------------------------------------------------------------
    --mixing three shares again
    adds: for i in 0 to num_bits-1 generate
        adders: s(i) <= s_1_out(i) xor s_2_out(i) xor s_3_out(i);
    end generate;
    
    c_out_t <= s_1_out(num_bits) xor s_2_out(num_bits)  xor s_3_out(num_bits);
    c_out <= c_out_t;
    
    
end architecture str;
    
    
    