LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.whitelion.all;

ENTITY fetch_tb IS
END fetch_tb;

ARCHITECTURE behavior OF fetch_tb IS



  component fetch is
    port(
      Enable: in std_logic;
      AddressIn: in std_logic_vector(15 downto 0);
      Clock: in std_logic;
      DataIn: in std_logic_vector(15 downto 0); -- port pobierajacy dane z pamieci
      IROut: out std_logic_vector(15 downto 0);
      AddressOut: out std_logic_vector(15 downto 0) --port zapisujacy dane do pamieci
    );
  end component;



  signal Enable: std_logic := '0';
  signal AddressIn: std_logic_vector(15 downto 0) := x"0000";
  signal DataIn: std_logic_vector(15 downto 0) := x"0000";

  signal IROut: std_logic_vector(15 downto 0);
  signal AddressOut: std_logic_vector(15 downto 0);

  signal Clock: std_logic;
  constant clock_period : time := 10 ns;

BEGIN


  uut: fetch PORT MAP (
    Enable => Enable,
    AddressIn => AddressIn,
    Clock => Clock,
    DataIn => DataIn,
    IROut => IROut,
    AddressOut => AddressOut
  );

  -- definicje zegara
  clock_process :process
  begin
    Clock <= '0';
    wait for clock_period/2;
    Clock <= '1';
    wait for clock_period/2;
  end process;


  -- proces symulacji
  stim_proc: process
    variable err_cnt: integer :=0;
  begin
    -- zatrzymanie w stanie resetu na 20ns
    wait for 10 ns;

    Enable<= '1';
    wait for 10 ns;

    Enable <= '1';
    AddressIn <= x"1234";
    DataIn <= x"5321";
    wait for 10 ns;
    assert (IROut = x"5321" and AddressOut = x"1234") report "blad podstawowej operacji" severity error;

    assert false
    report "Test fetchera zakonczony pomyslnie"
    severity note;

    wait;



    wait;
  end process;


END;
