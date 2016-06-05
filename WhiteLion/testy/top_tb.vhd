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

  stim_proc: process
    variable err_cnt: integer :=0;
  begin
    Port0 <= "ZZZZZZZZ";
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
    Data <= b"0011000001110000"; -- mov a, 112
    wait for 10 ns;
	 
	 Address <= b"0000000100000110";
    Data <= b"0011000101001000"; -- mov b, 72
    wait for 10 ns;
    
	 Address <= b"0000000100001000";
    Data <= b"0101100100000000"; -- cmpx a, b
    wait for 10 ns;
	 
	 Address <= b"0000000100001100";
    Data <= b"1100000100011010"; -- JM
    wait for 10 ns;
	 
	 Address <= b"0000000100001110";
    Data <= b"1100100100010100"; -- JW
    wait for 10 ns;
	 
	 Address <= b"0000000100010000";
    Data <= b"1101000000100010"; -- JR - jump koniec
    wait for 10 ns;
	 
	 Address <= b"0000000100010100";
	 Data <= b"0001100100000000"; -- subx b, a
    wait for 10 ns;
	 
	 Address <= b"0000000100011000";
    Data <= b"1001000000001000"; -- jmp petla
    wait for 10 ns;
	 	 
	 Address <= b"0000000100011010";
    Data <= b"0001100000000001"; -- subx a, b
    wait for 10 ns;

	 Address <= b"0000000100011110";
    Data <= b"1001000000001000"; -- jmp petla
    wait for 10 ns;
 
	 Address <= b"0000000100100010";
    Data <= b"0011101100000000"; -- movx r1, a  -- przeniesienie koncowego wyniku do r1
    wait for 10 ns;
	

    --poczekaj 10 ns	
    DMA <= '0';
    wait for 10 ns;
    Hold <= '0';
    wait for 10 ns;

		Reset <= '0';
    --uruchom procesor
    wait for 30 ns; --zaczekaj 3 cykle zegara zanim CPU zacznie wykonywac instrukcje
    wait for 20 ns; --zaczekaj 2 cykle zegara aby zdekodowal instrukcje

   assert false
   report "Test top zakonczony pomyelnie!"
   severity note;

    wait;
    wait;
  end process;


END;
