-- Librerias

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library WORK;
use WORK.VGA_PKG.ALL;

entity sincroVGA is
    Port ( 
        clk: in std_logic;
        rst:in std_logic;        
        visible:out std_logic;
        hsinc:out std_logic;
        vsinc:out std_logic;        
        col:out std_logic_vector(9 downto 0);
        fila:out std_logic_vector(9 downto 0)        
    );
end sincroVGA;

architecture Behavioral of sincroVGA is

    component contador is 
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
    end component;    

    
    signal cont_clk, new_pxl, cont_pxl, hsynch, vsynch, visible_pxl, new_line, cont_line, visible_line: std_logic;
    signal cols, fils: std_logic_vector(9 downto 0);
    
begin

    P_cont_clk: contador
        generic map (
            N_BITS => 2,
            END_COUNT => 4 
        )
        port map (
            clk =>clk,
            reset =>rst,
            enable =>'1',
            ud_count => '1',
            fcount => cont_clk,
            count =>OPEN          
        );
        
     new_pxl<= cont_clk; 

    P_cont_pxl: contador
        generic map (
            N_BITS => 10, 
            END_COUNT => 800
        )
        port map (
            clk =>clk,
            reset =>rst,
            enable =>new_pxl,
            ud_count => '1',
            fcount => cont_pxl,
            count =>cols          
        );
        
        hsynch <= '1' when unsigned(cols) < to_unsigned(640+16, 10) or unsigned(cols) > to_unsigned(640+16+96-1, 10)
              else '0';

        visible_pxl <= '1' when unsigned(cols) < to_unsigned(640, 10) else '0';
                        
        new_line <=  cont_pxl and new_pxl;       
    
    P_cont_line: contador               

        generic map (
            N_BITS => 10,
            END_COUNT => 525
        )
        port map (
            clk =>clk,
            reset =>rst,
            enable =>new_line,
            ud_count => '1',
            fcount => cont_line,
            count =>fils         
        );             
        
        vsynch <= '1' when unsigned(fils) < to_unsigned(480+10-1, 10) or unsigned(fils) > to_unsigned(480+10+2-1-1, 10)
                else '0';

        visible_line <= '1' when unsigned(fils) < to_unsigned(480, 10) else '0'; 
    
    
    visible <= visible_pxl and visible_line;
    col<= cols;
    fila<=fils;
    hsinc<=hsynch;
    vsinc<=vsynch;       
  

end Behavioral;
