--======================================================================
-- 1_bit registers
--======================================================================
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------
entity reg is
port(	I:	in std_logic;
		clock:	in std_logic;
		load:	in std_logic;
		clear:	in std_logic;
		Q:	out std_logic
);
end reg;

----------------------------------------------------

architecture behv of reg is

    signal Q_tmp: std_logic;

begin

    process(I, clock, load, clear)
    begin

	if clear = '0' then
            -- use 'range in signal assigment 
            Q_tmp <= '0';
	elsif (clock='1' and clock'event) then
	    if load = '1' then
		Q_tmp <= I;
	    end if;
	end if;

    end process;

    -- concurrent statement
    Q <= Q_tmp;

end behv;