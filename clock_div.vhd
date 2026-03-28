library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_div is 
    port (
        clk : in std_logic;
        div : out std_logic
    );
end clock_div;

architecture behavior of clock_div is 
    -- Assuming a 125 MHz system clock (standard Zybo). 
    -- 125,000,000 / 115,200 = ~1085
    constant MAX_COUNT : integer := 1085; 
    signal count : integer range 0 to MAX_COUNT := 0;
begin 
    process(clk) 
    begin 
        if rising_edge(clk) then 
            if count = (MAX_COUNT - 1) then 
                count <= 0;
                div <= '1'; -- Generate a single clock-cycle pulse
            else 
                count <= count + 1;
                div <= '0';
            end if;
        end if;
    end process;
end behavior;