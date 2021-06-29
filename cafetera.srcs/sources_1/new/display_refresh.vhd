library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity display_refresh is
    PORT( clk : in STD_LOGIC; -- 400 Hz
          reset : in STD_LOGIC;
          segment_ud : in STD_LOGIC_VECTOR (6 downto 0); -- numero unidad
          segment_dc : in STD_LOGIC_VECTOR (6 downto 0); -- numero decimal
          segment_ml : in STD_LOGIC_VECTOR (6 downto 0); -- temperatura leche
          segment_lc : in STD_LOGIC_VECTOR (6 downto 0); -- letra L leche
          segment_sg_1 : in STD_LOGIC_VECTOR (6 downto 0); -- nivel azucar 1
          segment_sg_2 : in STD_LOGIC_VECTOR (6 downto 0); -- nivel azucar 2
          segment_sg_3 : in STD_LOGIC_VECTOR (6 downto 0); -- nivel azucar 3
          segment_sg_4 : in STD_LOGIC_VECTOR (6 downto 0); -- nivel azucar 4
          display_select : out STD_LOGIC_VECTOR (7 downto 0); -- seleccionado display
          display_number : out STD_LOGIC_VECTOR (6 downto 0) -- numero display
          );
end display_refresh;

architecture Behavioral of display_refresh is

    signal segment_select_reset : STD_LOGIC_VECTOR (7 downto 0) := "11111111"; -- displays anodos apagados con reset on
    signal segment_number_reset : STD_LOGIC_VECTOR (6 downto 0) := "1111111"; -- displays sin numero con reset on
    
BEGIN
    
    -- REFRESCO DE DISPLAYS
    displays_refresh: process (clk,reset,segment_select_reset,segment_number_reset,segment_ud,segment_dc,segment_ml,segment_lc,segment_sg_1,segment_sg_2,segment_sg_3,segment_sg_4)
    variable refresh_counter : integer range 0 to 7;
    
    BEGIN
        
        display_select <= "11111111"; -- para quitar latch
        display_number <= "1111111"; -- para quitar latch
        
        if reset = '1' then
            display_select <= segment_select_reset; -- displays apagados
            display_number <= segment_number_reset; -- sin numero
            refresh_counter := 0;
            
        elsif clk = '1' and clk'event then
            if refresh_counter = 7 then
                refresh_counter := 0;
            else
                refresh_counter := refresh_counter + 1;
            end if;
            
            case refresh_counter is
            
                    WHEN 0 => display_select <= "11111110";
                              display_number <= segment_ud; -- unidades
                    
                    WHEN 1 => display_select <= "11111101";
                              display_number <= segment_dc; -- decenas
                    
                    WHEN 2 => display_select <= "11111011";
                              display_number <= segment_ml; -- leche temperatura
                    
                    WHEN 3 => display_select <= "11110111";
                              display_number <= segment_lc; -- letra L de leche
                              
                    WHEN 4 => display_select <= "11101111";
                              display_number <= segment_sg_1; -- azucar nivel 1
                              
                    WHEN 5 => display_select <= "11011111";
                              display_number <= segment_sg_2; -- azucar nivel 2
                              
                    WHEN 6 => display_select <= "10111111";
                              display_number <= segment_sg_3; -- azucar nivel 3
                              
                    WHEN 7 => display_select <= "01111111";
                              display_number <= segment_sg_4; -- azucar nivel 4
                              
                    WHEN OTHERS => NULL;
                              
            end case;
        end if;
    end process;
    
end Behavioral;