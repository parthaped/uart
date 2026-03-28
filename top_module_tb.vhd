library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_tb is
end top_tb;

architecture behavior of top_tb is

    component top_module is
        port (
            clk : in std_logic;
            btn : in std_logic_vector(1 downto 0);
            TXD : in std_logic;  
            RXD : out std_logic; 
            CTS : out std_logic;
            RTS : out std_logic
        );
    end component;

    component uart_rx is 
        port ( 
            clk, en, rx, rst    : in std_logic; 
            newChar             : out std_logic; 
            char                : out std_logic_vector (7 downto 0) 
        ); 
    end component;

    signal clk : std_logic := '0';
    signal btn : std_logic_vector(1 downto 0) := "00";
    signal TXD : std_logic := '1'; 
    signal RXD : std_logic;
    signal CTS : std_logic;
    signal RTS : std_logic;

    signal tb_en       : std_logic := '0';
    signal tb_newChar  : std_logic;
    signal tb_charRec  : std_logic_vector(7 downto 0);
    signal baud_cnt    : integer range 0 to 1085 := 0;
    
    signal tb_char_ascii : character;
    constant clk_period : time := 8 ns;

begin

    UUT: top_module 
        port map (clk => clk, btn => btn, TXD => TXD, RXD => RXD, CTS => CTS, RTS => RTS);

    Virtual_Monitor: uart_rx
        port map (clk => clk, en => tb_en, rx => RXD, rst => btn(1), newChar => tb_newChar, char => tb_charRec);

    -- Convert hex to ASCII text for the waveform viewer
    process(tb_charRec)
    begin
        if not is_X(tb_charRec) then
            tb_char_ascii <= character'val(to_integer(unsigned(tb_charRec)));
        else
            tb_char_ascii <= NUL;
        end if;
    end process;

    clk_process :process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    baud_process :process(clk)
    begin
        if rising_edge(clk) then
            if baud_cnt = 1084 then
                baud_cnt <= 0; tb_en <= '1';
            else
                baud_cnt <= baud_cnt + 1; tb_en <= '0';
            end if;
        end if;
    end process;

    -- Stimulus process
-- Stimulus process
    stim_proc: process
    begin		
        -----------------------------------------------------------
        -- INITIAL RESET
        -----------------------------------------------------------
        btn(1) <= '1'; wait for 2 ms; 
        btn(1) <= '0'; wait for 2 ms;

        -----------------------------------------------------------
        -- PRESS 1: Should send NetID[0]
        -----------------------------------------------------------
        btn(0) <= '1'; wait for 30 ms; -- Wait for debounce to register PRESS
        btn(0) <= '0'; wait for 30 ms; -- Wait for debounce to register RELEASE

        -----------------------------------------------------------
        -- PRESS 2: Should send NetID[1]
        -----------------------------------------------------------
        btn(0) <= '1'; wait for 30 ms; 
        btn(0) <= '0'; wait for 30 ms; 

        -----------------------------------------------------------
        -- PRESS 3: Should send NetID[2]
        -----------------------------------------------------------
        btn(0) <= '1'; wait for 30 ms; 
        btn(0) <= '0'; wait for 30 ms; 

        -----------------------------------------------------------
        -- MID-CYCLE RESET: Forces array index back to 0
        -----------------------------------------------------------
        btn(1) <= '1'; wait for 2 ms; 
        btn(1) <= '0'; wait for 30 ms;

        -----------------------------------------------------------
        -- PRESS 4: Should send NetID[0] again!
        -----------------------------------------------------------
        btn(0) <= '1'; wait for 30 ms; 
        btn(0) <= '0'; wait for 30 ms; 

        -----------------------------------------------------------
        -- PRESS 5: Should send NetID[1] again!
        -----------------------------------------------------------
        btn(0) <= '1'; wait for 30 ms; 
        btn(0) <= '0'; wait for 30 ms; 

        assert false report "Simulation Finished cleanly!" severity failure;
        wait;
    end process;

end behavior;