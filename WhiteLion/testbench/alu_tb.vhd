--##########################################################################################--
--########### GŁÓWNI AUTORZY KODU DO IMPEMENTACJI: JAKUB OBACZ, MICHAL POPEK ###############--
--############## AUTORZY TESTÓW: MATEUSZ WOLAK, WIKTOR BAJEWSKI, JAKUB OBACZ ###############--
--##########################################################################################--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.whitelion.all;

ENTITY alu_tb IS
END alu_tb;

ARCHITECTURE behavior OF alu_tb IS

  component alu is
    port(
    Op: in std_logic_vector(4 downto 0);
    DataIn1, DataIn2: in std_logic_vector(7 downto 0);
    DataOut: out std_logic_vector(7 downto 0);
    FR: out std_logic_vector(2 downto 0)
    );
  end component;

  --wejscia
  signal Op: std_logic_vector(4 downto 0) := "00000";
  signal DataIn1: std_logic_vector(7 downto 0) := "00000000";
  signal DataIn2: std_logic_vector(7 downto 0) := "00000000";

  --wyjscia
  signal DataOut: std_logic_vector(7 downto 0);
  signal FR: std_logic_vector(2 downto 0);

  signal Clock: std_logic;
  constant clock_period : time := 10 ns;

BEGIN

  uut: alu PORT MAP (
    Op => Op,
    DataIn1 => DataIn1,
    DataIn2 => DataIn2,
    DataOut => DataOut,
    FR => FR
  );

  -- Definicja procesu zegara
  clock_process :process
  begin
    Clock <= '0';
    wait for clock_period/2;
    Clock <= '1';
    wait for clock_period/2;
  end process;

  -- Proces symulacji
  stim_proc: process
    variable err_cnt: integer :=0;
  begin
    -- wstrzymaj stan resetu na 20 ns.
    wait for 20 ns;

    -- warunek 1
    Op <= "00000"; --dodawanie
    DataIn1 <= "10000001";
    DataIn2 <= "00011110";
    wait for 10 ns;
		assert (DataOut="10011111") report "Blad operacji dodawania" severity error;

	  Op <= "00001"; --dodawanie2
    DataIn1 <= "10000001";
    DataIn2 <= "11111110";
    wait for 10 ns;
		assert (DataOut="01111111") report "Blad operacji dodawania" severity error;

	  Op <= "00010"; --odejmowanie
    DataIn1 <= "11111111";
    DataIn2 <= "11111110";
    wait for 10 ns;
		assert (DataOut="00000001") report "Blad operacji odejmowania" severity error;


	  Op <= "00011"; --odejmowanie2
    DataIn1 <= "10000001";
    DataIn2 <= "11111110";
    wait for 10 ns;
		assert (DataOut="10000011") report "Blad operacji odejmowania" severity error;

	  Op <= "00100"; --mnozenie
    DataIn1 <= "00000010";
    DataIn2 <= "00000010";
    wait for 10 ns;
		assert (DataOut="00000100") report "Blad operacji mnozenia" severity error;

	  Op <= "00101"; --mnozenie2
    DataIn1 <= "00000001";
    DataIn2 <= "00000010";
    wait for 10 ns;
		assert (DataOut="00000010") report "Blad operacji mnozenia" severity error;

	  Op <= "01000"; --inkrementacja
    DataIn1 <= "00000001";
    wait for 10 ns;
		assert (DataOut="00000010") report "Wystapil blad przy inkrementacji" severity error;

	  Op <= "01001"; --dekrementacja
    DataIn1 <= "00000001";
    wait for 10 ns;
		assert (DataOut="00000000") report "Wystapil blad przy dekrementacji" severity error;

	  Op <= "01010"; --rowne
    DataIn1 <= "10101010";
    DataIn2 <= "10101010";
    wait for 10 ns;
		assert (FR="010") report "Nie jest rowne" severity error;

	  Op <= "01100"; --or
    DataIn1 <= "00000001";
    DataIn2 <= "11111110";
    wait for 10 ns;
		assert (DataOut="11111111") report "Blad operacji or" severity error;

		Op <= "01110"; --and
    DataIn1 <= "00000001";
    DataIn2 <= "11111111";
    wait for 10 ns;
		assert (DataOut="00000001") report "Blad operacji and" severity error;

		Op <= "10000"; --not
    DataIn1 <= "10000001";
    wait for 10 ns;
		assert (DataOut="01111110") report "Blad operacji not" severity error;

		Op <= "10101"; --xor
    DataIn1 <= "10000001";
    DataIn2 <= "11111110";
    wait for 10 ns;
		assert (DataOut="01111111") report "Blad operacji xor" severity error;

		Op <= "10101"; --xor
    DataIn1 <= "10000001";
    DataIn2 <= "11111110";
    wait for 10 ns;
		assert (DataOut="01111111") report "Blad operacji xor" severity error;

    assert false
    report "Test alu zakonczony pomyslnie"
    severity note;

    wait;

    wait;
  end process;


END;
