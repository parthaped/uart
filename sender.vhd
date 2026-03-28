library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sender is 
    port (
        clk    : in std_logic;
        en     : in std_logic;
        rst    : in std_logic;
        btn    : in std_logic;
        ready  : in std_logic;
        send   : out std_logic;
        char   : out std_logic_vector(7 downto 0)
    );
end sender;

architecture behavior of sender is 

    type state_type is (idle, busyA, busyB, busyC);
    signal curr : state_type := idle;
    
    constant n : integer := 5; 
    type netid_array is array (0 to n-1) of std_logic_vector(7 downto 0);
    
    -- ASCII Hex values for "jm123" (Change this to your actual NetID!)
    constant NETID : netid_array := (
        x"70", -- 'j'
        x"70", -- 'm'
        x"57", -- '1'
        x"53", -- '2'
        x"53"  -- '3'
    );

    -- Counter to track which character we are on
    signal i : integer range 0 to n-1 := 0;

begin 

    process(clk) 
    begin 
        if rising_edge(clk) then 
            
            -- Synchronous Reset
            if rst = '1' then 
                curr <= idle;
                send <= '0';
                char <= (others => '0');
                i <= 0; -- IMPORTANT: Forces the array back to the 1st letter
                
            -- State Machine transitions on Clock Enable
            elsif en = '1' then 
                
                case curr is 
                    
                    when idle =>
                        if ready = '1' and btn = '1' then
                            send <= '1';
                            char <= NETID(i); -- Output current letter
                            
                            -- Advance array index for the NEXT button press
                            if i < n - 1 then
                                i <= i + 1;
                            else
                                i <= 0; -- Loop back to start if we reached the end
                            end if;
                            
                            curr <= busyA;
                        else
                            send <= '0';
                        end if;
                        
                    when busyA =>
                        curr <= busyB;
                        
                    when busyB =>
                        send <= '0';
                        curr <= busyC;
                        
                    when busyC =>
                        -- Wait here until the user RELEASES the button
                        -- This prevents blasting multiple characters on one press
                        if ready = '1' and btn = '0' then
                            curr <= idle;
                        end if;
                        
                    when others =>
                        curr <= idle;
                        
                end case;
            end if;
        end if;
    end process;

end behavior;