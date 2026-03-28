library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is 
    port(
         clk, en, send, rst   : in std_logic;
         char               : in std_logic_vector(7 downto 0); 
         ready, tx          : out std_logic 
    ); 
end uart_tx;

architecture fsm of uart_tx is 

    type state is (idle, start, data, stop);
    signal curr : state := idle; 
    
    -- Register to hold the data so it doesn't change during transmission
    signal d : std_logic_vector (7 downto 0) := (others => '0');
    
    signal count : std_logic_vector(2 downto 0) := (others => '0');
    
    signal tx_reg : std_logic := '1';

begin 
    
    -- Concurrent assignment to output
    tx <= tx_reg;
    
    process(clk) begin 
        if rising_edge(clk) then 
    
            -- Synchronous Reset
            if rst = '1' then 
                curr <= idle; 
                d <= (others => '0');
                count <= (others => '0');
                tx_reg <= '1'; 
                ready <= '1';
            
            -- State Machine transitions only on Clock Enable (Baud tick)
            elsif en = '1' then 
        
                case curr is 
                    
                    when idle =>
                        tx_reg <= '1';
                        ready <= '1';
                        
                        if send = '1' then
                            d <= char;         -- Latch the incoming data
                            ready <= '0';      -- Immediately indicate we are busy
                            curr <= start;     -- Move to start state
                        end if;
                        
                    when start =>
                        tx_reg <= '0';         -- Drive line low for Start Bit
                        count <= (others => '0'); -- Reset bit counter
                        curr <= data;          -- Unconditional transition
                        
                    when data =>
                        tx_reg <= d(0);        -- Output the Least Significant Bit
                        
                        if unsigned(count) < 7 then
                            -- Shift the register right by 1 to prep the next bit
                            d <= '0' & d(7 downto 1); 
                            count <= std_logic_vector(unsigned(count) + 1);
                        else
                            curr <= stop;      -- All 8 bits sent, move to stop
                        end if;
                        
                    when stop =>
                        tx_reg <= '1';         -- Drive line high for Stop Bit
                        curr <= idle;          -- Unconditional transition back to idle

                    when others =>
                        curr <= idle;          -- Failsafe
                        
                end case;
            end if; -- end en
        end if; -- end clk
    end process;

end fsm;