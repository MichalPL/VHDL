--##########################################################################################--
--########### GŁÓWNI AUTORZY KODU DO IMPEMENTACJI: JAKUB OBACZ, MICHAL POPEK ###############--
--############## AUTORZY TESTÓW: MATEUSZ WOLAK, WIKTOR BAJEWSKI, JAKUB OBACZ ###############--
--##########################################################################################--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.whitelion.all;

ENTITY core_tb IS
END core_tb;

ARCHITECTURE behavior OF core_tb IS

  component core is
    port(

		--interfejs pamieci
      MemAddr: out std_logic_vector(15 downto 0); --adres pamieci przechowywany w postaci bajtowej
      MemWW: out std_logic;
      MemWE: out std_logic;
      MemIn: in std_logic_vector(15 downto 0);
      MemOut: out std_logic_vector(15 downto 0);

		--glowny interfejs
      Clock: in std_logic;
      Reset: in std_logic;--kiedy przypiszemy 1 do RESET wszystko zostanie zresetowane podczas 1 cyklu zegarowego
      Hold: in std_logic; --kiedy przypiszemy 1 (stan wysoki) to inne bloki mogl pobierac dane z pamieci
      HoldAck: out std_logic;

      --PORTY DEBUGUJACE
      DebugIR: out std_logic_vector(15 downto 0);
      DebugIP: out std_logic_vector(7 downto 0);
      DebugFR: out std_logic_vector(2 downto 0);

		DebugA: out std_logic_vector(7 downto 0);
		DebugB: out std_logic_vector(7 downto 0);
      DebugR0: out std_logic_vector(7 downto 0);
		DebugR1: out std_logic_vector(7 downto 0);
		DebugR2: out std_logic_vector(7 downto 0);
		DebugR3: out std_logic_vector(7 downto 0)

    );
  end component;

  --interjest pamieci
  signal MemAddr: std_logic_vector(15 downto 0); --adres pamieci przechowywany w postaci bajtowej
  signal MemWW: std_logic;
  signal MemWE: std_logic;
  signal MemOut: std_logic_vector(15 downto 0);
  signal MemIn: std_logic_vector(15 downto 0):=x"0000";

  --glowny interfejs
  signal Reset: std_logic:='0'; --kiedy przypiszemy 1 do RESET wszystko zostanie zresetowane podczas 1 cyklu zegarowego
  signal Hold: std_logic:='0';
  signal HoldAck: std_logic;

  --SYGNALY DEBUGUJACE
  signal DebugIR: std_logic_vector(15 downto 0);
  signal DebugIP: std_logic_vector(7 downto 0);
  signal DebugFR: std_logic_vector(2 downto 0);

  signal DebugA: std_logic_vector(7 downto 0);
  signal DebugB: std_logic_vector(7 downto 0);
  signal DebugR0: std_logic_vector(7 downto 0);
  signal DebugR1: std_logic_vector(7 downto 0);
  signal DebugR2: std_logic_vector(7 downto 0);
  signal DebugR3: std_logic_vector(7 downto 0);

  signal Clock: std_logic;
  constant clock_period : time := 10 ns;

BEGIN


  uut: core PORT MAP (
    MemAddr => MemAddr,
    MemWW => MemWW,
    MemWE => MemWE,
    MemOut => MemOut,
    MemIn => MemIn,
    Clock => Clock,
    Reset => Reset,
    Hold => Hold,
    HoldAck => HoldAck,
    DebugIR => DebugIR,
    DebugIP => DebugIP,
    DebugFR => DebugFR,
	 DebugA => DebugA,
	 DebugB => DebugB,
    DebugR0 => DebugR0,
	 DebugR1 => DebugR1,
	 DebugR2 => DebugR2,
	 DebugR3 => DebugR3
  );

  -- definicje zegara
  clock_process :process
  begin
    Clock <= '0';
    wait for clock_period/2;
    Clock <= '1';
    wait for clock_period/2;
  end process;

  --proces symulacji
  stim_proc: process
    variable err_cnt: integer :=0;
  begin
    Reset <= '1';
    wait for 20 ns;

    --stany testow:
    Hold <= '1';
    wait for 10 ns;
    assert(HoldAck = '1') report "Stan zatrzymania nie zostal potwierdzony" severity error;
    Hold <= '0';
    wait for 10 ns;
    assert(HoldAck = '0') report "Stan zatrzymania trwa dluzej niz powinien" severity error;

    Reset <= '0';
	 wait for 20 ns;




	 MemIn <= b"0011000011111111";
    wait for 20 ns; --fetcher potrzebuje 20ns aby zadzialac
    assert(DebugR0 = b"11111111") report "Zaladowanie '11111111' do R0 nie jest poprawne" severity error;

	 MemIn <= b"0011000011110000";
    wait for 20 ns;
	 assert(DebugR0 = b"11110000") report "Zaladowanie '11110000' do R0 nie jest poprawne" severity error;


	 MemIn <= b"0011000000000111"; -- mov a, 111
    wait for 20 ns;
	 assert(DebugR0 = b"00000111") report "Zaladowanie '111' do R0 nie jest poprawne" severity error;

	 MemIn <= b"0011000100000111"; -- mov b, 0
    wait for 20 ns;
	 assert(DebugR1 = b"00000111") report "Zaladowanie '111' do R1 nie jest poprawne" severity error;

	 MemIn <= b"0011001000000111"; -- mov r0, 0
    wait for 20 ns;
	 assert(DebugR2 = b"00000111") report "Zaladowanie '111' do R2 nie jest poprawne" severity error;

	 MemIn <= b"0011001100000111"; -- mov r1, 0
    wait for 20 ns;
	 assert(DebugR3 = b"00000111") report "Zaladowanie '111' do R3 nie jest poprawne" severity error;

	 MemIn <= b"0011000000000100"; -- mov a, 100
    wait for 20 ns;
	 assert(DebugR0 = b"00000100") report "Zaladowanie 100' do R0 nie jest poprawne" severity error;

	 MemIn <= b"0011000100000110"; -- mov b, 110
    wait for 20 ns;
	 assert(DebugR1 = b"00000110") report "Zaladowanie '110' do R1 nie jest poprawne" severity error;

	 MemIn <= b"0011001000000111"; -- mov r0, 111
    wait for 20 ns;
	 assert(DebugR2 = b"00000111") report "Zaladowanie '111' do R2 nie jest poprawne" severity error;

	 MemIn <= b"0011001100000001"; -- mov r1, 001
    wait for 20 ns;
	 assert(DebugR3 = b"00000001") report "Zaladowanie '001' do R3 nie jest poprawne" severity error;

	 MemIn <= b"0000101001100000"; --add r0, r3
    wait for 20 ns;
	 assert(DebugR2 = b"00001000") report "Dodanie R3 do R2 nie jest poprawne" severity error;

	  MemIn <= b"0000000000000011"; --add 11
    wait for 20 ns;
	 assert(DebugR0 = b"00000111") report "Dodanie '11' do R0 nie jest poprawne" severity error;

	  MemIn <= b"0100000000000000"; --inc r0
    wait for 20 ns;
	 assert(DebugR0 = b"00001000") report "Zwiekszenie R0 o 1 nie jest poprawne" severity error;

	  MemIn <= b"0100000100000000"; --inc r1
    wait for 20 ns;
	 assert(DebugR1 = b"00000111") report "Zwiekszenie R1 o 1 nie jest poprawne" severity error;

	 MemIn <= b"1001000000000001"; -- jump do 1 instrukcji
	 wait for 20 ns;
	 assert(DebugIP = b"00000001") report "Skok do 1 instrukcji nie jest poprawny" severity error;

	  MemIn <= b"0011000000101111"; -- mov a, 101111
    wait for 20 ns;
	 assert(DebugR0 = b"00101111") report "Zaladowanie 101111 do R0 nie jest poprawne" severity error;

	 MemIn <= b"0011000100101111"; -- mov b, 101111
    wait for 20 ns;
	 assert(DebugR1 = b"00101111") report "Zaladowanie 101111 do R1 nie jest poprawne" severity error;

	 MemIn <= b"0101000100101111"; -- cmp b, 101111
	 wait for 20 ns;
	 assert(DebugFR = b"010") report "CMP nie jest poprawne" severity error;

	 MemIn <= b"1101000000000001"; -- jump rowny
	 wait for 20 ns;
	 assert(DebugIP = b"00000001") report "Skok nie jest poprawny" severity error;

    assert false
    report "Test core zakonczony pomyslnie!"
    severity note;

    wait;



    wait;
  end process;


END;
