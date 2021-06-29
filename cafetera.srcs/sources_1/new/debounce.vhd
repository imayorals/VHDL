library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity debounce is
    port( clk : in std_logic; -- 100 MHz
          reset : in std_logic;
          btn_in : in std_logic;
          btn_out : out std_logic
          );
end debounce;

architecture Behavioral of debounce is

    -- Working Parameters
    constant COUNT_MAX : integer := 1500000; -- 15 ms, the higher this is, the more longer time the user has to press the button
    constant BTN_ACTIVE : std_logic := '1'; -- set it '1' if the button creates a high pulse when its pressed, otherwise '0'
    signal count : integer := 1;
    
    -- State Machine
    type state_type is (idle,wait_time);
    signal debounce_state : state_type := idle;

BEGIN
    
    -- RESET Y PASO DE ESTADO
    debounce_btn: process(reset,clk)
    BEGIN
        
        if reset = '1' then
            debounce_state <= idle;
            btn_out <= '0';
            
        -- Asginacion estados
        elsif clk = '1' and clk'event then
            case debounce_state is
            
                WHEN idle =>
                    if btn_in = BTN_ACTIVE then  
                        debounce_state <= wait_time;
                    else
                        debounce_state <= idle; --wait until button is pressed.
                    end if;
                    btn_out <= '0';
                    
                WHEN wait_time =>
                    if count = COUNT_MAX then
                        if btn_in = BTN_ACTIVE then
                            btn_out <= '1';
                            debounce_state <= wait_time;
                        else
                            count <= 1;
                            debounce_state <= idle;
                            --btn_out <= '0';
                        end if;
                    else
                        count <= count + 1;
                        --btn_out <= '0';
                    end if;
                    
                WHEN OTHERS => NULL;
                
            end case;       
        end if;        
    end process;                  
                                                                                
end Behavioral;