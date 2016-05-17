--##########################################################################################--
--########### GŁÓWNI AUTORZY KODU DO IMPEMENTACJI: JAKUB OBACZ, MICHAL POPEK ###############--
--############## AUTORZY TESTÓW: MATEUSZ WOLAK, WIKTOR BAJEWSKI, JAKUB OBACZ ###############--
--##########################################################################################--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY blockram_tb IS
END blockram_tb;

ARCHITECTURE behavior OF blockram_tb IS



  component blockram
    port(
      Address: in std_logic_vector(7 downto 0); --adres pamieci
      WriteEnable: in std_logic_vector(1 downto 0); --zapis lub odczyt
      Enable: in std_logic;
      Clock: in std_logic;
      DataIn: in std_logic_vector(15 downto 0);
      DataOut: out std_logic_vector(15 downto 0)
    );
  end component;


  --SYGNALY WEJSCIOWE
  signal Address: std_logic_vector(7 downto 0) := (others => '0');
  signal WriteEnable: std_logic_vector(1 downto 0) := (others => '0');
  signal DataIn: std_logic_vector(15 downto 0) := (others => '0');
  signal Enable: std_logic := '0';

  --SYGNAL WYJSCIOWY
  signal DataOut: std_logic_vector(15 downto 0);

  signal Clock: std_logic; --zegar
  constant clock_period : time := 10 ns;

BEGIN


  uut: blockram PORT MAP (
    Address => Address,
    WriteEnable => WriteEnable,
    Enable => Enable,
    Clock => Clock,
    DataIn => DataIn,
    DataOut => DataOut
  );

  -- definicja procesu zegara
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
    -- wstrzymanie w stanie resetu na 100ns
    Enable <= '1';
    wait for 100 ns;

    wait for clock_period*10;

    --Warunek 1
    WriteEnable(0) <= '0';
    WriteEnable(1) <= '0';
    wait for 10 ns;
    Address <= x"01";
    DataIn <= "1000000000001000";
    WriteEnable(0) <= '1';
    WriteEnable(1) <= '1';
    wait for 10 ns;
    WriteEnable(0) <= '0';
    WriteEnable(1) <= '0';
    wait for 10 ns;
    assert (DataOut="1000000000001000") report "Blad przechowywania" severity error;

     --Warunek 2
    Address <= x"33";
    DataIn <= "1000000000001100";
    WriteEnable(0) <= '1';
    WriteEnable(1) <= '1';
    wait for 10 ns;
    WriteEnable(0) <= '0';
    WriteEnable(1) <= '0';
    wait for 10 ns;
    assert (DataOut="1000000000001100") report "Blad wyboru pami�ci" severity error;

    -- Warunek 3
    Address <= x"01";
    wait for 10 ns;
    assert (DataOut="1000000000001000") report "Blad wyboru pami�ci" severity error;

    --Warunek 4
    Address <= x"11";
    WriteEnable(0) <= '1';
    WriteEnable(1) <= '1';
    DataIn <= x"932F";
    wait for 10 ns;
    WriteEnable(1) <= '0';
    DataIn <= x"165A";
    wait for 10 ns;
    WriteEnable(0) <= '0';
    wait for 10 ns;
    assert (DataOut=x"935A") report "Blad zapisu bajtu szeroko�ci" severity error;





   assert false
   report "Test pamieci zakonczony pomyslnie"
   severity note;

    wait;



    wait;
  end process;


END;
