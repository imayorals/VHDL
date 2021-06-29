library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Cafetera is
    PORT (
           clk : in STD_LOGIC; -- 100 MHz
           reset : in STD_LOGIC;
           encendido : in STD_LOGIC;
           corto : in STD_LOGIC;
           doble : in STD_LOGIC;
           largo : in STD_LOGIC;
           milk : in STD_LOGIC;
           leche_caliente : in STD_LOGIC;
           leche_fria : in STD_LOGIC;
           sugar : in STD_LOGIC;
           more_sugar: in STD_LOGIC;
           less_sugar : in STD_LOGIC;
           start : in STD_LOGIC;
           encendido_led : out STD_LOGIC;
           corto_led : out STD_LOGIC;
           doble_led : out STD_LOGIC;
           largo_led : out STD_LOGIC;
           milk_led : out STD_LOGIC;
           milk_led_red : out STD_LOGIC;
           milk_led_blue : out STD_LOGIC;
           sugar_led : out STD_LOGIC;
           bomba_led_red : out STD_LOGIC;           
           done_led_green : out STD_LOGIC;
           apagado_led : out STD_LOGIC;
           display_select : out STD_LOGIC_VECTOR (7 downto 0);
           display_number : out STD_LOGIC_VECTOR (6 downto 0)
           );
end Cafetera;

architecture Behavioral of Cafetera is

    COMPONENT debounce
    PORT ( clk : in STD_LOGIC; -- 100 MHz
           reset : in STD_LOGIC;
           btn_in : in std_logic;
           btn_out : out std_logic
           );
    END COMPONENT;
    
    COMPONENT clk_divider
	generic ( relacion : integer := 10000000);
    PORT ( clk : in STD_LOGIC; -- 100 MHz
           reset : in STD_LOGIC;
           clk_out : out STD_LOGIC
           );
	END COMPONENT;
	
	COMPONENT maquina_estados
	PORT( clk : in STD_LOGIC; -- 1 Hz
	      reset : in STD_LOGIC;
          encendido : in STD_LOGIC;
          corto : in STD_LOGIC;
          doble : in STD_LOGIC;
          largo : in STD_LOGIC;
          milk : in STD_LOGIC;
          leche_caliente : in STD_LOGIC;
          leche_fria : in STD_LOGIC;
          sugar : in STD_LOGIC;
          more_sugar: in STD_LOGIC;
          less_sugar : in STD_LOGIC;
          start : in STD_LOGIC;
          encendido_led : out STD_LOGIC;
          corto_led : out STD_LOGIC;
          doble_led : out STD_LOGIC;
          largo_led : out STD_LOGIC;
          milk_led : out STD_LOGIC;
          milk_led_red : out STD_LOGIC;
          milk_led_blue : out STD_LOGIC;
          sugar_led : out STD_LOGIC;
          bomba_led_red : out STD_LOGIC;
          done_led_green : out STD_LOGIC;
          apagado_led : out STD_LOGIC;
          ud : out STD_LOGIC_VECTOR (3 downto 0);
          dc : out STD_LOGIC_VECTOR (3 downto 0);
          ml : out STD_LOGIC_VECTOR (3 downto 0);
          lc : out STD_LOGIC_VECTOR (3 downto 0);
          az_1 : out STD_LOGIC_VECTOR (3 downto 0);
          az_2 : out STD_LOGIC_VECTOR (3 downto 0);
          az_3 : out STD_LOGIC_VECTOR (3 downto 0);
          az_4 : out STD_LOGIC_VECTOR (3 downto 0)

          );
	END COMPONENT;
	
	COMPONENT decoder
	PORT( code : in STD_LOGIC_VECTOR (3 downto 0);
	      led : out STD_LOGIC_VECTOR (6 downto 0)
	      );
	END COMPONENT;
	
	COMPONENT display_refresh
	PORT( clk : in STD_LOGIC; -- 400 Hz
	      reset : in STD_LOGIC;
	      segment_ud : in STD_LOGIC_VECTOR(6 downto 0);
	      segment_dc : in STD_LOGIC_VECTOR(6 downto 0);
	      segment_ml : in STD_LOGIC_VECTOR(6 downto 0);
          segment_lc : in STD_LOGIC_VECTOR(6 downto 0);
          segment_sg_1 : in STD_LOGIC_VECTOR(6 downto 0);
          segment_sg_2 : in STD_LOGIC_VECTOR(6 downto 0);
          segment_sg_3 : in STD_LOGIC_VECTOR(6 downto 0);
          segment_sg_4 : in STD_LOGIC_VECTOR(6 downto 0);
          display_select : out STD_LOGIC_VECTOR(7 downto 0);
          display_number : out STD_LOGIC_VECTOR(6 downto 0)
          );
	END COMPONENT;

    -- SENIALES INTERMEDIAS PARA PATILLAS
    signal clk_fsm, clk_display : STD_LOGIC;
    signal leche_caliente_debounce, leche_fria_debounce, more_sugar_debounce, less_sugar_debounce, start_debounce : STD_LOGIC;
    signal unidad, decenas, leche, leche_L, azucar_1, azucar_2, azucar_3, azucar_4 : STD_LOGIC_VECTOR (3 downto 0);
    signal segmen_UD, segmen_DC, segmen_ML, segmen_LC, segmen_SG_1, segmen_SG_2, segmen_SG_3, segmen_SG_4 : STD_LOGIC_VECTOR (6 downto 0);
    
    -- INSTANCIACION COMPONENTES

BEGIN
                   
    inst_clk_divider_fsm_1Hz: clk_divider
        GENERIC MAP( relacion => 50000000) -- 1 Hz a fsm
        PORT MAP(
            -- in
            clk => clk, -- 100 MHz
            reset => reset,
            -- out
            clk_out => clk_fsm -- 1 Hz
            );
            
    inst_clk_divider_displays_400Hz: clk_divider
		GENERIC MAP( relacion => 125000) -- 400 Hz a displays
		PORT MAP(
		    -- in
			clk => clk, -- 100 MHz
    		reset => reset,
    		-- out
		    clk_out => clk_display -- 400 Hz
		    );
		    
    inst_debounce_leche_caliente: debounce
        PORT MAP(
            -- in
            clk => clk, -- 100 MHz
            reset => reset,
            btn_in => leche_caliente,
            -- out
            btn_out => leche_caliente_debounce
            );
            
    inst_debounce_leche_fria: debounce
        PORT MAP(
            -- in
            clk => clk, -- 100 MHz
            reset => reset,
            btn_in => leche_fria,
            -- out
            btn_out => leche_fria_debounce
            );
		    
    inst_debounce_more_sugar: debounce
        PORT MAP(
            -- in
            clk => clk, -- 100 MHz
            reset => reset,
            btn_in => more_sugar,
            -- out
            btn_out => more_sugar_debounce
            );
                    
    inst_debounce_less_sugar: debounce
        PORT MAP(
            -- in
            clk => clk, -- 100 MHz
            reset => reset,
            btn_in => less_sugar,
            -- out
            btn_out => less_sugar_debounce
            );
                    
    inst_debounce_start: debounce
        PORT MAP(
            -- in
            clk => clk, -- 100 MHz
            reset => reset,
            btn_in => start,
            -- out
            btn_out => start_debounce
            );
            
    inst_fsm: maquina_estados
        PORT MAP(
            -- in
            clk  => clk_fsm, -- 1 Hz
            reset => reset,
            encendido => encendido,
            corto => corto,
            doble => doble,
            largo => largo,
            milk => milk,
            leche_caliente => leche_caliente_debounce,
            leche_fria => leche_fria_debounce,
            sugar => sugar,
            more_sugar => more_sugar_debounce,
            less_sugar => less_sugar_debounce,
            start => start_debounce,
            -- out
            encendido_led => encendido_led,
            corto_led => corto_led,
            doble_led => doble_led,
            largo_led => largo_led,
            milk_led => milk_led,
            milk_led_red => milk_led_red,
            milk_led_blue => milk_led_blue,
            sugar_led => sugar_led,
            bomba_led_red => bomba_led_red,
            done_led_green => done_led_green,
            apagado_led => apagado_led,
            ud => unidad,
            dc => decenas,
            ml => leche,
            lc => leche_L,
            az_1 => azucar_1,
            az_2 => azucar_2,
            az_3 => azucar_3,
            az_4 => azucar_4
            );
			
    inst_decoder_unidades: decoder
        PORT MAP(
            -- in
            code => unidad,
            -- out
            led => segmen_UD -- primer display
            );
			
    inst_decoder_decenas: decoder
        PORT MAP(
            -- in
            code => decenas,
            -- out
            led =>  segmen_DC -- segundo display
            );
            
    inst_decoder_leche: decoder
        PORT MAP(
            -- in
            code => leche,
            -- out
            led =>  segmen_ML -- tercer display
            );
            
    inst_decoder_L_leche: decoder
        PORT MAP(
            -- in
            code => leche_L,
            -- out
            led =>  segmen_LC -- cuarto display
            );
            
    inst_decoder_sugar_1: decoder
        PORT MAP(
            -- in
            code => azucar_1, -- nivel 1 azucar
            -- out
            led =>  segmen_SG_1 -- quinto display
            );
            
    inst_decoder_sugar_2: decoder
        PORT MAP(
            -- in
            code => azucar_2, -- nivel 2 azucar
            -- out
            led =>  segmen_SG_2 -- sexto display
            );
            
    inst_decoder_sugar_3: decoder
        PORT MAP(
            -- in
            code => azucar_3, -- nivel 3 azucar
            -- out
            led =>  segmen_SG_3 -- septimo display
            );
            
    inst_decoder_sugar_4: decoder
        PORT MAP(
            -- in
            code => azucar_4, -- nivel 4 azucar
            -- out
            led =>  segmen_SG_4 -- octavo display
            );
            
	inst_display: display_refresh
        PORT MAP(
            -- in
            clk => clk_display, -- 400 Hz
            reset => reset,
            segment_ud => segmen_UD,
            segment_dc => segmen_DC,
            segment_ml => segmen_ML,
            segment_lc => segmen_LC,
            segment_sg_1 => segmen_SG_1,
            segment_sg_2 => segmen_SG_2,
            segment_sg_3 => segmen_SG_3,
            segment_sg_4 => segmen_SG_4,
            -- out
            display_select => display_select,
            display_number => display_number
            );

end Behavioral;