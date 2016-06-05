LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.whitelion.all;

ENTITY registerfile_tb IS
END registerfile_tb;

ARCHITECTURE behavior OF registerfile_tb IS



  component registerfile
  port(
    WriteEnable: in regwritetype;
    DataIn: in regdatatype;
    Clock: in std_logic;
    DataOut: out regdatatype
  );
  end component;


  --WEJSCIA
  signal WriteEnable : regwritetype := (others => '0');
  signal DataIn: regdatatype := (others => "00000000");

  --WYJSCIA
  signal DataOut: regdatatype := (others => "00000000");

  signal Clock: std_logic;
  constant clock_period : time := 10 ns;

BEGIN


  uut: registerfile PORT MAP (
    WriteEnable => WriteEnable,
    DataIn => DataIn,
    Clock => Clock,
    DataOut => DataOut
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
   -- zatrzymanie w stanie resetu na 100ns
    wait for 100 ns;

    wait for clock_period*10;

    -- Warunek 1
    WriteEnable(1) <= '1';
    DataIn(1) <= "11110000";
    wait for 10 ns;
    WriteEnable(1) <= '0';
    wait for 10 ns;
    assert (DataOut(1)="11110000") report "Blad przechowywania" severity error;

    -- Warunek 2
    WriteEnable(5) <= '1';
    DataIn(5) <= "11110001";
    wait for 10 ns;
    WriteEnable(5) <= '0';
    wait for 10 ns;
    assert (DataOut(5)="11110001") report "Blad przechowywania" severity error;

    -- Warunek 3;
    wait for 10 ns;
    assert (DataOut(1)="11110000") report "Blad przechowywania" severity error;

    --Warunek 4
    DataIn(0) <= x"12";
    DataIn(1) <= x"34";
    WriteEnable(0) <= '1';
    WriteEnable(1) <= '1';
    wait for 10 ns;
    DataIn(0) <= x"90";
    WriteEnable(0) <= '0';
    WriteEnable(1) <= '0';
    wait for 10 ns;
    assert (DataOut(0)=x"12" and DataOut(1)=x"34") report "Blad jednoczesnego zapisu i odczytu" severity error;

    --Warunek 5
    DataIn(0) <= x"55";
    WriteEnable(0) <= '1';
    wait for 10 ns;
    DataIn(0) <= x"77";
    assert (DataOut(0)=x"55") report "Zapis podczas odczytu, blad" severity error;
    wait for 10 ns;

    assert false
    report "Test registerfile zakonczony pomyslnie!"
    severity note;

    wait;
    wait;
	 
  end process;


END;
