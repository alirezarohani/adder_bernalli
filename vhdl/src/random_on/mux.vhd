
--======================================================================
-- multiplexer
--======================================================================
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;


-------------------------------------------------

entity mux is
port(	
	I0: 	in std_logic;
	I1: 	in std_logic;
	sel:	in std_logic;
	z:		out std_logic);
end mux;  

-------------------------------------------------

architecture beh of mux is
begin
    process(I0,I1,sel)
    begin
    
        -- use case statement
        case sel is
			when '0' =>	z <= I0;
			when '1' =>	z <= I1;
			when others =>	
			null;
	end case;

    end process;
end beh;
--------------------------------------------------