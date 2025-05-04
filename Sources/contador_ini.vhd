library IEEE;  -- Librerias
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity contador is
    generic (N_BITS : integer := 10;   -- Numero de bits necesarios para que el contador alcance el valor deseado 
             END_COUNT : integer := 1024  -- Valor hasta el que debe contar el contador
    );
    port(
        clk     : in  STD_LOGIC;  
        reset   : in  STD_LOGIC;
        enable  : in  STD_LOGIC;
        ud_count: in  STD_LOGIC;  -- Indica si el contador es ascendente('1') o descendente ('0')
        fcount  : out STD_LOGIC;  -- Otorga '1' al final de cuenta
        count   : out STD_LOGIC_VECTOR(N_BITS-1 downto 0) -- Indica cual es el valor de cuenta
    );
end contador;

architecture Behavioral of contador is


        -- Señales intermedias 
        
    signal count_reg  : STD_LOGIC_VECTOR(N_BITS-1 downto 0);  
    signal fcount_reg : STD_LOGIC; 
    
begin
    process(clk, reset)
    begin
        if reset = '1' then
            count_reg <= (others => '0');    -- Cuando se resetea a todos los valores se le asigna '0'
        elsif rising_edge(clk) then
            if enable = '1' then  -- Cuando el contador se activa
                if fcount_reg = '1' and ud_count = '1'  then    -- En el caso de que se llegue al valor de cuenta deseado y el contador sea ascendente
                    count_reg <= (others => '0');                     
                elsif fcount_reg = '1' and ud_count = '0' then  -- En el caso de que se llegue al valor de cuenta deseado y el contador sea descendente                               
                    count_reg <= std_logic_vector(to_unsigned(END_COUNT-1, N_BITS));-- Esta funcion pasa de decimal a binario, sirve para indicar el valor maximo en el que empieza la cuenta descendente 
                else
                    if ud_count = '1' then                        
                            count_reg <= count_reg + 1;     -- El contador ascendente se incrementa                       
                    else                        
                            count_reg <= count_reg - 1;      -- El contador descendente se disminuye                                                               
                    end if;
                end if;
            end if;
        end if;
    end process;

    fcount_reg <= '1' when (count_reg = END_COUNT-1 and ud_count = '1') or -- Indica cuando se llega al valor de cuenta en contador ascendente
                          (count_reg = 0 and ud_count = '0') else '0';     -- Indica cuando se llega al valor de cuenta en contador descendente

    count  <= count_reg;
    fcount <= fcount_reg;

end Behavioral;
