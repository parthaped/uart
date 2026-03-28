library ieee;
use ieee.std_logic_1164.all;

entity top_module is
    port (
        clk : in std_logic;
        btn : in std_logic_vector(1 downto 0);
        
        -- Physical PMOD pins
        TXD : in std_logic;  -- From Adapter's TX (so it's an Input here)
        RXD : out std_logic; -- To Adapter's RX (so it's an Output here)
        CTS : out std_logic;
        RTS : out std_logic
    );
end top_module;

architecture structural of top_module is

    -- Component Declarations
    component debounce is
        port (
            clk   : in std_logic;
            btn   : in std_logic;
            dbnce : out std_logic
        );
    end component;

    component clock_div is
        port (
            clk : in std_logic;
            div : out std_logic
        );
    end component;

    component sender is
        port (
            clk   : in std_logic;
            en    : in std_logic;
            rst   : in std_logic;
            btn   : in std_logic;
            ready : in std_logic;
            send  : out std_logic;
            char  : out std_logic_vector(7 downto 0)
        );
    end component;

    component uart is
        port (
            clk      : in std_logic;
            en       : in std_logic;
            rx       : in std_logic;
            rst      : in std_logic;
            send     : in std_logic;
            charSend : in std_logic_vector(7 downto 0);
            ready    : out std_logic;
            tx       : out std_logic
            -- Note: charRec and newChar exist in uart but are left unconnected per the lab block diagram for this step.
        );
    end component;

    -- Interconnecting Signals
    signal dbnce_btn0 : std_logic;
    signal dbnce_rst  : std_logic;
    signal en_pulse   : std_logic;
    
    signal uart_ready  : std_logic;
    signal sender_send : std_logic;
    signal sender_char : std_logic_vector(7 downto 0);

begin

    -- Drive unused flow control signals low per the manual
    CTS <= '0';
    RTS <= '0';

    -- u1: Debounce for the main action button
    u1: debounce
        port map (
            clk   => clk,
            btn   => btn(0),
            dbnce => dbnce_btn0
        );

    -- u2: Debounce for the reset button
    u2: debounce
        port map (
            clk   => clk,
            btn   => btn(1),
            dbnce => dbnce_rst
        );

    -- u3: Clock divider to generate the baud rate enable pulse
    u3: clock_div
        port map (
            clk => clk,
            div => en_pulse
        );

    -- u4: Sender FSM
    u4: sender
        port map (
            clk   => clk,
            en    => en_pulse,
            rst   => dbnce_rst,
            btn   => dbnce_btn0,
            ready => uart_ready,
            send  => sender_send,
            char  => sender_char
        );

    -- u5: UART component
    -- IMPORTANT: 'TXD' pin connects to 'rx', 'RXD' pin connects to 'tx'
    u5: uart
        port map (
            clk      => clk,
            en       => en_pulse,
            rst      => dbnce_rst,
            rx       => TXD,         -- Adapter TX -> FPGA RX
            send     => sender_send,
            charSend => sender_char,
            ready    => uart_ready,
            tx       => RXD          -- FPGA TX -> Adapter RX
        );

end structural;