--======================================================================
-- adder_4btit controller
--======================================================================
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder_ctrl is 
    generic (
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
        sel_z   : out std_logic;
        sel : out std_logic;
        
        data_out_valid: out std_logic);
        
end entity adder_ctrl;

architecture fsm of adder_ctrl is 
    type state_type is (initial, initial_next,s0,s1,final, dummy, dummy_3);
    signal next_state, current_state: state_type;
    signal count, next_count: INTEGER RANGE 0 to 33;
    signal count_dummy, next_count_dummy: INTEGER RANGE 0 to 21;
    
    begin   
    
        state_reg: process(clk, reset_n)
        begin   
            if (reset_n = '0') then 
                    current_state <= initial;
            elsif (clk'event and clk='1') then
                current_state <= next_state;
            end if;
        end process;
        
        add_count: process(clk, reset_n)
        begin   
            if (reset_n = '0') then 
                    count <= 0;
                    count_dummy <= 0;
            elsif (clk'event and clk='1') then
                count <= next_count;
                count_dummy <= next_count_dummy;
            end if;
        end process;
        
        comb_logic: process(current_state,adder_en,count,count_dummy)
        begin   
        load_s_1 <= (others => '0');
        load_s_2 <= (others => '0');
        load_s_3 <= (others => '0');
        load_c_1 <= (others => '0');
        load_c_2 <= (others => '0');
        load_c_3 <= (others => '0');
        sel_z   <= '0';
        sel <= '0';
        data_out_valid <= '0';
        next_count <= 0;
        next_count_dummy <= 0;
        --sel_rand <= '0';
        
        case current_state is
            when initial =>
                if adder_en = '1' then
                    next_state <= dummy;
                else
                    next_state <= initial;
                end if;
                
            when dummy =>
                next_count_dummy <= count_dummy + 1;
                if count_dummy  <20 then
                    next_state <= dummy;
                else
                    next_state <= s0;
                end if;
                    
                
            when s0 =>
                load_s_1 <= (others => '1');
                load_s_2 <= (others => '1');
                load_s_3 <= (others => '1');
                load_c_1 <= (others => '1');
                load_c_2 <= (others => '1');
                load_c_3 <= (others => '1');
                sel <= '0';         
                next_state <= s1;
                next_count <= count + 1;
        
                
            when s1 =>
                
                load_s_1(num_bits downto count) <=  (others => '1');
                load_s_1(count-1 downto 0) <=  (others => '0');
                
                load_s_2(num_bits downto count) <=  (others => '1');
                load_s_2(count-1 downto 0) <=  (others => '0');
                
                load_s_3(num_bits downto count) <=  (others => '1');
                load_s_3(count-1 downto 0) <=  (others => '0');
                
             
                
                
                load_c_1(num_bits downto count) <=  (others => '1');
                load_c_1(count-1 downto 0) <=  (others => '0');
                
                load_c_2(num_bits downto count) <=  (others => '1');
                load_c_2(count-1 downto 0) <=  (others => '0');
                
                load_c_3(num_bits downto count) <=  (others => '1');
                load_c_3(count-1 downto 0) <=  (others => '0');
                
                -- to get the Z from the last S
                sel_z <= '1';
                
                sel <= '1';
                --en_lfsr <= '0';   
                
                next_count <= count + 1;
                
                if count  <= num_bits-1 then
                    next_state <= s1;
                elsif count > num_bits-1 then
                    next_state <= dummy_3;
                end if;
                
            when dummy_3 =>
                next_count_dummy  <= count_dummy + 1;
                if count_dummy  <20 then
                    next_state <= dummy_3;
                else
                    next_state <= final;
                end if;
                
                
            when final =>
                load_s_1(num_bits) <=  '1';
                load_s_1(num_bits-1 downto 0) <=  (others => '0');
                
                load_s_2(num_bits) <=  '1';
                load_s_2(num_bits-1 downto 0) <=  (others => '0');
                
                load_s_3(num_bits) <=  '1';
                load_s_3(num_bits-1 downto 0) <=  (others => '0');
               
                
                load_c_1(num_bits) <=  '1';
                load_c_1(num_bits-2 downto 0) <=  (others => '0');
                
                load_c_2(num_bits) <=  '1';
                load_c_2(num_bits-1 downto 0) <=  (others => '0');
                
                load_c_3(num_bits) <=  '1';
                load_c_3(num_bits-1 downto 0) <=  (others => '0');
            
                sel <= '1';
                sel_z <= '1';
                data_out_valid <= '1';
                --en_lfsr <= '1';   
                next_state <= initial;

            when others =>
                next_state <= initial;
                
            end case;
        end process;
    end architecture;
                