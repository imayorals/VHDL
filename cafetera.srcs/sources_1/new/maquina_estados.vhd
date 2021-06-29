library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity maquina_estados is
    PORT ( clk : in STD_LOGIC; -- 1 Hz
           reset : in STD_LOGIC;
           encendido : in STD_LOGIC;
           corto : in STD_LOGIC;
           doble : in STD_LOGIC;
           largo : in STD_LOGIC;
           milk : in STD_LOGIC;
           leche_caliente : in STD_LOGIC;
           leche_fria : in STD_LOGIC;
           sugar : in STD_LOGIC;
           more_sugar : in STD_LOGIC;
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
end maquina_estados;

architecture Behavioral of maquina_estados is
    
    -- Estados cafetera
    type state is (inicio,standby,sirviendo);
	signal current_state, next_state : state := inicio;
	
	-- LEDs cafetera
	signal encendido_led_i, apagado_led_i : STD_LOGIC := '0'; -- LEDs encendida/apagada la maquina y cafe listo
	signal corto_led_i, corto_led_i_next, doble_led_i, doble_led_i_next, largo_led_i, largo_led_i_next : STD_LOGIC := '0'; -- LEDs largo y corto
	signal bomba_led_red_i, bomba_led_red_i_next ,done_led_green_i ,done_led_green_i_next : STD_LOGIC := '0'; -- LED parpadeante activado bomba presi?n
	signal coffee_done : STD_LOGIC := '0'; -- LED indica cafe listo
    
	-- Tipo, tiempo y contador de tipos de cafe
	type type_coffee is (select_cafe,cafe_corto,cafe_doble,cafe_largo); -- estados leche
    signal coffee_time, coffee_time_next : type_coffee := select_cafe; -- tiempo de preparado
	signal count : integer range 0 to 20 := 0; -- contador de cafe
    signal unidad, decena : integer range 0 to 10 := 10; -- primer y segundo displays
    
    -- Leche
    signal milk_led_i, milk_led_i_next : STD_LOGIC := '0'; -- LED leche
    type state_milk is (init_milk,select_milk); -- estados leche
    signal current_state_milk, next_state_milk : state_milk := init_milk; -- estados encendido display temperatura leche
    signal temperatura_leche, temperatura_leche_next : integer range 0 to 3 := 0; -- display temperatura leche
    signal milk_led_red_i, milk_led_red_i_next, milk_led_blue_i, milk_led_blue_i_next  : STD_LOGIC := '0'; -- LEDs RGB temperatura leche
    signal letra_L_leche, letra_L_leche_next : STD_LOGIC := '0'; -- display temperatura leche
    
    -- Azucar
	signal sugar_led_i, sugar_led_i_next : STD_LOGIC := '0'; -- LED azucar
	type state_sugar is (init_sugar,select_sugar); -- estados azucar
	signal current_state_sugar, next_state_sugar : state_sugar := init_sugar; -- estados encendido display nivel azucar
	signal level_sugar, level_sugar_next : integer range 0 to 4 := 0; -- displays nivel azucar
	
    -- Binarios hacia decodificadores
	signal binarioD : STD_LOGIC_VECTOR (3 downto 0) := "1011"; -- salida decimal
	signal binarioU : STD_LOGIC_VECTOR (3 downto 0) := "1011"; -- salida unidad
	signal binarioM : STD_LOGIC_VECTOR (3 downto 0) := "1011"; -- salida temperatura leche
	signal binarioL : STD_LOGIC_VECTOR (3 downto 0) := "1011"; -- salida letra L leche
    signal binarioS_1 : STD_LOGIC_VECTOR (3 downto 0) := "1011"; -- salida nivel azucar
    signal binarioS_2 : STD_LOGIC_VECTOR (3 downto 0) := "1011"; -- salida nivel azucar
    signal binarioS_3 : STD_LOGIC_VECTOR (3 downto 0) := "1011"; -- salida nivel azucar
    signal binarioS_4 : STD_LOGIC_VECTOR (3 downto 0) := "1011"; -- salida nivel azucar
    
BEGIN

    -- RESET Y PASO DE ESTADO
	state_register :process (reset,clk,encendido)
	BEGIN
        if reset = '1' or encendido = '0' then
	        current_state <= inicio;
	        corto_led_i <= '0';
	        doble_led_i <= '0';
            largo_led_i <= '0';
            coffee_time <= select_cafe;
            milk_led_i <= '0';
            current_state_milk <= init_milk;
            temperatura_leche <= 0;
            milk_led_red_i <= '0';
            milk_led_blue_i <= '0';
            letra_L_leche <= '0';
	        sugar_led_i <= '0';
	        current_state_sugar <= init_sugar;
            level_sugar <= 0;
            bomba_led_red_i <= '0';
            done_led_green_i <= '0';
        elsif clk = '0' and clk'event then
		    current_state <= next_state;
	        corto_led_i <= corto_led_i_next;
	        doble_led_i <= doble_led_i_next;
            largo_led_i <= largo_led_i_next;
		    coffee_time <= coffee_time_next;
		    milk_led_i <= milk_led_i_next;
		    current_state_milk <= next_state_milk;
            temperatura_leche <= temperatura_leche_next;
            milk_led_red_i <= milk_led_red_i_next;
		    milk_led_blue_i <= milk_led_blue_i_next;
            letra_L_leche <= letra_L_leche_next;
		    sugar_led_i <= sugar_led_i_next;
            current_state_sugar <= next_state_sugar;
		    level_sugar <= level_sugar_next;
		    bomba_led_red_i <= bomba_led_red_i_next;
		    done_led_green_i <= done_led_green_i_next;
        end if;
	end process;
	
    -- ASIGNCION ESTADOS
    next_state_decod : process (reset,current_state,encendido,corto,doble,largo,coffee_time,coffee_time_next,start,coffee_done)
    BEGIN
    
        -- Para quitar latch
        next_state <= current_state;
        coffee_time_next <= coffee_time;
        
        case current_state is
        
            WHEN inicio =>
                if reset = '0' and encendido = '1' then
                    next_state <= standby;
                end if;
                
            WHEN standby =>
                if start = '0' then
                    if corto = '1' and doble = '0' and largo = '0' then
                        coffee_time_next <= cafe_corto;
                    elsif corto = '0' and doble = '1' and largo = '0' then
                        coffee_time_next <= cafe_doble;
                    elsif corto = '0' and doble = '0' and largo = '1' then
                        coffee_time_next <= cafe_largo;
                    else
                        coffee_time_next <= select_cafe;
                    end if;
                elsif start = '1' then
                    if coffee_time_next /= select_cafe then
                        next_state <= sirviendo;
                    end if;
                end if;
                
            WHEN sirviendo =>
                if coffee_done = '1' then -- senal de la cuenta atras
                    coffee_time_next <= select_cafe;
                    if start = '0' then
                        next_state <= standby;
                    end if;
                end if;
                
            WHEN OTHERS => NULL;
            
        end case;    
    end process;
	
    -- ASIGNACION SALIDAS A ESTADOS
	output_decod : process (clk,current_state,corto,doble,largo,corto_led_i,doble_led_i,largo_led_i,milk,milk_led_i,current_state_milk,next_state_milk,temperatura_leche,temperatura_leche_next,leche_caliente,leche_fria,milk_led_red_i,milk_led_blue_i,letra_L_leche,sugar,sugar_led_i,current_state_sugar,next_state_sugar,more_sugar,less_sugar,level_sugar,level_sugar_next,bomba_led_red_i,coffee_done,done_led_green_i)
	BEGIN
	
	    -- Para quitar latch
	    encendido_led_i <= '0';
        corto_led_i_next <= corto_led_i;
        doble_led_i_next <= doble_led_i;
        largo_led_i_next <= largo_led_i;
        milk_led_i_next <= milk_led_i;
        next_state_milk <= current_state_milk;
        temperatura_leche_next <= temperatura_leche;
        milk_led_red_i_next <= milk_led_red_i;
        milk_led_blue_i_next <= milk_led_blue_i;
        sugar_led_i_next <= sugar_led_i;
        next_state_sugar <= current_state_sugar;
        level_sugar_next <= level_sugar;
        letra_L_leche_next <= letra_L_leche;
        bomba_led_red_i_next <= bomba_led_red_i;
        done_led_green_i_next <= done_led_green_i;
        apagado_led_i <= '0';
        
        case current_state is
        
			WHEN inicio =>
                encendido_led_i <= '0';
                corto_led_i_next <= '0';
                doble_led_i_next <= '0';
                largo_led_i_next <= '0';
                milk_led_i_next <= '0';
                sugar_led_i_next <= '0';
                bomba_led_red_i_next <= '0';
                done_led_green_i_next <= '0';
                apagado_led_i <= '1';
                
            WHEN standby =>
                encendido_led_i <= '1';
                bomba_led_red_i_next <= '0';
                done_led_green_i_next <= '0';
				apagado_led_i <= '0';
				
                -- Cafe corto LED
                if corto = '1' then
                    corto_led_i_next <= '1';
                else
                    corto_led_i_next <= '0';                                    
                end if;
                
                -- Cafe doble LED
                if doble = '1' then
                    doble_led_i_next <= '1';
                else
                    doble_led_i_next <= '0';                                    
                end if;
                
                -- Cafe largo LED
                if largo = '1' then
                    largo_led_i_next <= '1';
                else
                    largo_led_i_next <= '0';
                end if;
				
				-- Milk LED
				if milk = '1' then
                    milk_led_i_next <= '1';
                    letra_L_leche_next <= '1';
                    -- Estados Leche
                    case current_state_milk is
                        
                        WHEN init_milk =>
                            temperatura_leche_next <= 3;
                            milk_led_red_i_next <= '0';
                            milk_led_blue_i_next <= '0';
                            next_state_milk <= select_milk;
                            
                        WHEN select_milk =>
                            -- Temperatura Leche
                            if leche_caliente = '1' and leche_fria = '0' then
                                temperatura_leche_next <= 1;
                                milk_led_red_i_next <= '1';
                                milk_led_blue_i_next <= '0';
                            elsif leche_fria = '1' and leche_caliente = '0' then
                                temperatura_leche_next <= 2;
                                milk_led_red_i_next <= '0';
                                milk_led_blue_i_next <= '1';
                            end if;
                            
                        WHEN OTHERS => NULL;
                        
                    end case;  
                else
                    milk_led_i_next <= '0';
                    letra_L_leche_next <= '0';
                    temperatura_leche_next <= 0;
                    milk_led_red_i_next <= '0';
                    milk_led_blue_i_next <= '0';
                    next_state_milk <= init_milk;
                end if;
                
                -- Sugar LED
                if sugar = '1' then
                    sugar_led_i_next <= '1';
                    -- Estados Azucar
                    case current_state_sugar is
                        
                        WHEN init_sugar =>
                            level_sugar_next <= 1;
                            next_state_sugar <= select_sugar;
                            
                        WHEN select_sugar =>
                            -- Nivel Azucar
                            if more_sugar = '1' and less_sugar = '0' then
                                if level_sugar = 1 then
                                    level_sugar_next <= 2;
                                elsif level_sugar = 2 then
                                    level_sugar_next <= 3;
                                elsif level_sugar = 3 then
                                    level_sugar_next <= 4;
                                end if;
                            elsif less_sugar = '1' and more_sugar = '0' then
                                if level_sugar = 4 then
                                    level_sugar_next <= 3;
                                elsif level_sugar = 3 then
                                    level_sugar_next <= 2;
                                elsif level_sugar = 2 then
                                    level_sugar_next <= 1;
                                end if;
                            end if;
                            
                        WHEN OTHERS => NULL;
                        
                    end case;
                else
                    sugar_led_i_next <= '0';
                    level_sugar_next <= 0;
                    next_state_sugar <= init_sugar;
                end if;
                
			WHEN sirviendo =>
				encendido_led_i <= '1';
				apagado_led_i <= '0';
				
				if coffee_done = '1' then
				    bomba_led_red_i_next <= '0';
                    done_led_green_i_next <= '1';
                    next_state_milk <= init_milk;
                    next_state_sugar <= init_sugar;
                else
                    -- Blinking bomba LED
                    case bomba_led_red_i is
                                            
                        WHEN '0' =>
                            bomba_led_red_i_next <= '1';
                                
                        WHEN '1' =>
                            bomba_led_red_i_next <= '0';
                                
                        WHEN OTHERS => NULL;
                            
                    end case;
                end if; 
                
            WHEN OTHERS => NULL;
            
		end case;
	end process;
	
	encendido_led <= encendido_led_i;
    corto_led <= corto_led_i;
    doble_led <= doble_led_i;
    largo_led <= largo_led_i;
	milk_led <= milk_led_i;
	milk_led_red <= milk_led_red_i;
	milk_led_blue <= milk_led_blue_i;
	sugar_led <= sugar_led_i;
    bomba_led_red <= bomba_led_red_i;
    done_led_green <= done_led_green_i;
    apagado_led <= apagado_led_i;
	
    -- CONTADOR, ASIGNACION TIEMPOS TIPO CAFE Y CAFE LISTO
    contador: process (clk,current_state,next_state,coffee_time,count,coffee_done)
    BEGIN
    
            if current_state = standby then
                coffee_done <= '0';
                case coffee_time is
                    WHEN select_cafe =>
                    count <= 0;
                    WHEN cafe_corto =>
                    count <= 10;
                    WHEN cafe_doble =>
                    count <= 15;
                    WHEN cafe_largo =>
                    count <= 20;
                    WHEN OTHERS => NULL;
                end case;
                
            elsif current_state = sirviendo then
                if clk = '0' and clk'event then
                    count <= count - 1;
                    coffee_done <= '0';
                    if count = 2 then -- para sincronizar delays por cambios de estado
                        coffee_done <= '1';
                    elsif count <= 0 then
                        count <= 0;
                    end if;
                end if;
            end if;
    end process;
    
    -- UNIDADES Y DECENAS
    asigancion_unidades_decena : process (current_state,count,decena)
    BEGIN
    
        if current_state = standby or current_state = sirviendo then
            decena <= count / 10;
            unidad <= count rem 10;
        else
            decena <= 10;
            unidad <= 10;
        end if;
    end process;
    
    -- TRADUCCION DECIMAL A BINARIO
    decimal_BCD : process (unidad,decena,temperatura_leche,letra_L_leche,level_sugar)
    BEGIN
    
        -- Para quitar latch
        binarioU <= "1011";
        binarioD <= "1011";
        binarioM <= "1011";
        binarioL <= "1011";
        binarioS_1 <= "1011";
        binarioS_2 <= "1011";
        binarioS_3 <= "1011";
        binarioS_4 <= "1011";
        
        case unidad is
            WHEN 0 => binarioU <= "0000"; -- "0"
            WHEN 1 => binarioU <= "0001"; -- "1"
            WHEN 2 => binarioU <= "0010"; -- "2"
            WHEN 3 => binarioU <= "0011"; -- "3"
            WHEN 4 => binarioU <= "0100"; -- "4"
            WHEN 5 => binarioU <= "0101"; -- "5"
            WHEN 6 => binarioU <= "0110"; -- "6"
            WHEN 7 => binarioU <= "0111"; -- "7"
            WHEN 8 => binarioU <= "1000"; -- "8"
            WHEN 9 => binarioU <= "1001"; -- "9"
            WHEN 10 => binarioU <= "1011"; -- " "
            WHEN OTHERS => NULL;
        end case unidad;
        
        case decena is
            WHEN 0 => binarioD <= "0000"; -- "0"
            WHEN 1 => binarioD <= "0001"; -- "1"
            WHEN 2 => binarioD <= "0010"; -- "2"
            WHEN 3 => binarioD <= "0011"; -- "3"
            WHEN 4 => binarioD <= "0100"; -- "4"
            WHEN 5 => binarioD <= "0101"; -- "5"
            WHEN 6 => binarioD <= "0110"; -- "6"
            WHEN 7 => binarioD <= "0111"; -- "7"
            WHEN 8 => binarioD <= "1000"; -- "8"
            WHEN 9 => binarioD <= "1001"; -- "9"
            WHEN 10 => binarioD <= "1011"; -- " "
            WHEN OTHERS => NULL;
        end case;
        
        case temperatura_leche is
            WHEN 0 => binarioM <= "1011"; -- " "
            WHEN 1 => binarioM <= "1100"; -- "C"
            WHEN 2 => binarioM <= "1111"; -- "F"
            WHEN 3 => binarioM <= "1010"; -- "-"
            WHEN OTHERS => NULL;
        end case;
        
        case letra_L_leche is
            WHEN '0' => binarioL <= "1011"; -- " "
            WHEN '1' => binarioL <= "1101"; -- "L"
            WHEN OTHERS => NULL;
        end case;
        
        case level_sugar is
            WHEN 0 => binarioS_1 <= "1011"; -- " "
                      binarioS_2 <= "1011"; -- " "
                      binarioS_3 <= "1011"; -- " "
                      binarioS_4 <= "1011"; -- " "
                  
            WHEN 1 => binarioS_1 <= "0001"; -- "1"
                      binarioS_2 <= "1011"; -- " "
                      binarioS_3 <= "1011"; -- " "
                      binarioS_4 <= "1011"; -- " "
                      
            WHEN 2 => binarioS_1 <= "0001"; -- "1"
                      binarioS_2 <= "0001"; -- "1"
                      binarioS_3 <= "1011"; -- " "
                      binarioS_4 <= "1011"; -- " "
                      
            WHEN 3 => binarioS_1 <= "0001"; -- "1"
                      binarioS_2 <= "0001"; -- "1"
                      binarioS_3 <= "0001"; -- "1"
                      binarioS_4 <= "1011"; -- " "
                      
            WHEN 4 => binarioS_1 <= "0001"; -- "1"
                      binarioS_2 <= "0001"; -- "1"
                      binarioS_3 <= "0001"; -- "1"
                      binarioS_4 <= "0001"; -- "1"
            WHEN OTHERS => NULL;
        end case;
    end process;
    
    ud <= binarioU;
    dc <= binarioD;
    ml <= binarioM;
    lc <= binarioL;
    az_1 <= binarioS_1;
    az_2 <= binarioS_2;
    az_3 <= binarioS_3;
    az_4 <= binarioS_4;
    
end Behavioral;