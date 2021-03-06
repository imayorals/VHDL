library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity decoder is
    PORT( code : in STD_LOGIC_VECTOR (3 downto 0);
		  led : out STD_LOGIC_VECTOR (6 downto 0)
		  );
end decoder;

architecture Behavioral of decoder is

    signal segmento : STD_LOGIC_VECTOR (6 downto 0);

BEGIN

    with code select
        -- GFEDCBA LED Order
        segmento <=  "1000000" WHEN "0000", -- "0"
					 "1111001" WHEN "0001", -- "1"
					 "0100100" WHEN "0010", -- "2"
					 "0110000" WHEN "0011", -- "3"
					 "0011001" WHEN "0100", -- "4"
					 "0010010" WHEN "0101", -- "5"
					 "0000010" WHEN "0110", -- "6"
					 "1111000" WHEN "0111", -- "7"
					 "0000000" WHEN "1000", -- "8"
					 "0010000" WHEN "1001", -- "9"
					 "0111111" WHEN "1010", -- "-"
					 "1111111" WHEN "1011", -- " "
					 "1000111" WHEN "1101", -- "L"
                     "1000110" WHEN "1100", -- "C"
                     "0001110" WHEN "1111", -- "F"
					 "0111111" WHEN OTHERS;
					 
        led <= segmento;
                
end Behavioral;