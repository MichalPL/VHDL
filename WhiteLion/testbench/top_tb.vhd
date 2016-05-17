LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY top_tb IS
END top_tb;

ARCHITECTURE behavior OF top_tb IS

-- Deklaracja komponentu do testu

  component top is
    port(
      Reset: in std_logic;
      Hold: in std_logic;
      HoldAck: out std_logic;
      Clock: in std_logic;
      DMA: in std_logic; -- kiedy stan jest wysoki "1" porty Address, Data, oraz WriteEnable sa polaczone blokiem pamieci
      Address: in std_logic_vector(15 downto 0); --adres pamieci przechowywany w postaci bajtowej
      WriteEnable: in std_logic;
      Data: inout std_logic_vector(15 downto 0);
      Port0: inout std_logic_vector(7 downto 0);
      --PORT DEBUGUJACY
		 DebugA: out std_logic_vector(7 downto 0);
		 DebugB: out std_logic_vector(7 downto 0);
		 DebugR0: out std_logic_vector(7 downto 0);
		 DebugR1: out std_logic_vector(7 downto 0);
		 DebugR2: out std_logic_vector(7 downto 0);
		 DebugR3: out std_logic_vector(7 downto 0);
		 DebugFR: out std_logic_vector(2 downto 0)
    );
  end component;


  signal Reset:std_logic:='0';
  signal Hold: std_logic:='0';
  signal HoldAck: std_logic;
  signal DMA: std_logic:='0'; -- kiedy stan jest wysoki "1" porty Address, Data, oraz WriteEnable sa polaczone blokiem pamieci
  signal Address: std_logic_vector(15 downto 0):=x"0000"; --adres pamieci przechowywany w postaci bajtowej
  signal WriteEnable: std_logic:='0';
  signal Data: std_logic_vector(15 downto 0):=x"0000";
  signal Port0: std_logic_vector(7 downto 0);
  --SYGNAL DEBUGUJACY
  signal DebugA: std_logic_vector(7 downto 0);
  signal DebugB: std_logic_vector(7 downto 0);
  signal DebugR0: std_logic_vector(7 downto 0);
  signal DebugR1: std_logic_vector(7 downto 0);
  signal DebugR2: std_logic_vector(7 downto 0);
  signal DebugR3: std_logic_vector(7 downto 0);
  signal DebugFR: std_logic_vector(2 downto 0);

  signal Clock: std_logic; --zegar
  constant clock_period : time := 10 ns;

BEGIN


  uut: top PORT MAP (
    Reset => Reset,
    Hold => Hold,
    HoldAck => HoldAck,
    Clock => Clock,
    DMA => DMA,
    Address => Address,
    WriteEnable => WriteEnable,
    Data => Data,
    DebugA => DebugA,
    DebugB => DebugB,
    DebugR0 => DebugR0,
    DebugR1 => DebugR1,
    DebugR2 => DebugR2,
    DebugR3 => DebugR3,
    DebugFR => DebugFR,
    Port0 => Port0
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
    Port0 <= "ZZZZZZZZ";
    -- zatrzymanie w stanie resetu na 100ns
    Reset <= '0';
    wait for 10 ns;
    Reset <= '1';
    wait for 200 ns;
    Reset <= '0';
    wait for 50 ns;
    --Port0(1) <= '1';
    --wait for 200 ns;
    --assert(Port0(0)='1') report "Przelacznik nie dziala" severity error;
    --wait for 10 ns;
    --Port0(1) <= '0';
    --wait for 200 ns;
    --assert(Port0(0)='0') report "Przelacznik nie dziala" severity error;


    Reset <= '1';
    wait for 100 ns;
    wait for 10 ns;
    Hold <= '1';
    wait for 10 ns;
    assert (HoldAck ='1') report "HoldAck nie jest w stanie wysokim" severity error;
    
	 
	 
	 --zaladowanie kodow operacji do pamieci
    DMA <= '1';
    WriteEnable <= '1';

    Address <= b"0000000100000100";
    Data <= b"0011000000000001"; -- mov a, 1
    wait for 10 ns;
	 
	 Address <= b"0000000100000110";
    Data <= b"0011000000000011"; -- mov a, 11
    wait for 10 ns;
    
	 Address <= b"0000000100001000";
    Data <= b"0011000000000111"; -- mov a, 111
    wait for 10 ns;
	 
	  Address <= b"0000000100001010";
    Data <= b"0011000000001111"; -- mov a, 1111
    wait for 10 ns;
	 
	  Address <= b"0000000100001110";
    Data <= b"0011000000011111"; -- mov a, 11111
    wait for 10 ns;
	 
	 Address <= b"0000000100010000";
    Data <= b"0011000000111111"; -- mov a, 111111
    wait for 10 ns;
	 
	 Address <= b"0000000100010010";
    Data <= b"0011000001111111"; -- mov a, 1111111
    wait for 10 ns;
	
	
	Address <= b"0000000100010100";
    Data <= b"0101000001111111"; -- cmp a, 1111111
    wait for 10 ns;
	 
	 Address <= b"0000000100010110";
    Data <= b"1101000000000010"; -- jump jezeli rowne
    wait for 10 ns;

	

    --poczekaj 10 ns	
    DMA <= '0';
    wait for 10 ns;
    Hold <= '0';
    wait for 10 ns;

    --uruchom procesor
	 
    Reset <= '0';
    wait for 30 ns; --zaczekaj 3 cykle zegara zanim CPU zacznie wykonywac instrukcje
    wait for 20 ns; --zaczekaj 2 cykle zegara aby zdekodowal instrukcje
    assert(Debugr0 = b"00000001") report "R0 nie jest prawidlowo zaladowany dla pierwszej instrukcji" severity error;
    wait for 20 ns;
    assert(DebugR0 = b"00000011") report "R0 nie jest prawidlowo zaladowany dla drugiej instrukcji" severity error;


   assert false
   report "Test top zakonczony pomyelnie!"
   severity note;

    wait;

	
    wait;
  end process;


END;
