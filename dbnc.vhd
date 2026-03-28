library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce is
    port (
        clk   : in std_logic;
        btn   : in std_logic;
        dbnce : out std_logic
    );
end debounce;

architecture behavior of debounce is
    -- 22-bit counter gives roughly a 20-30ms delay at 100-125MHz to wait out the bounce
    signal count : unsigned(21 downto 0) := (others => '0');
    signal stable_state : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            -- If the button is currently different from our registered stable state
            if btn /= stable_state then
                count <= count + 1;
                -- If it has remained in this new state long enough, register it
                if count(count'high) = '1' then
                    stable_state <= btn;
                    count <= (others => '0');
                end if;
            else
                count <= (others => '0');
            end if;
        end if;
    end process;
    
    dbnce <= stable_state;
end behavior;