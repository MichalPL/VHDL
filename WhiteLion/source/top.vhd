--##########################################################################################--
--########### GŁÓWNI AUTORZY KODU DO IMPEMENTACJI: JAKUB OBACZ, MICHAL POPEK ###############--
--############## AUTORZY TESTÓW: MATEUSZ WOLAK, WIKTOR BAJEWSKI, JAKUB OBACZ ###############--
--##########################################################################################--


--Komponent zarzadzania pamiecia
--oraz zarzadzania komponentami takimi jak core
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
  port(
    Reset: in std_logic;
    Hold: in std_logic;
    HoldAck: out std_logic;
    Clock: in std_logic;
    DMA: in std_logic;  -- kiedy stan jest wysoki "1" porty Address, Data, oraz WriteEnable sa polaczone blokiem pamieci
    Address: in std_logic_vector(15 downto 0); --adres pamieci przechowywany w postaci bajtowej
    WriteEnable: in std_logic;
    Data: inout std_logic_vector(15 downto 0);
    Port0: inout std_logic_vector(7 downto 0);
    --port debugujacy
    DebugA: out std_logic_vector(7 downto 0);
    DebugB: out std_logic_vector(7 downto 0);
    DebugR0: out std_logic_vector(7 downto 0);
    DebugR1: out std_logic_vector(7 downto 0);
    DebugR2: out std_logic_vector(7 downto 0);
    DebugR3: out std_logic_vector(7 downto 0);
    DebugFR: out std_logic_vector(2 downto 0);
	 LED: out std_logic_vector (7 downto 0)
	 --LCD_DI: out std_logic_vector (3 downto 0)

);


end top;




architecture Behavioral of top is
---type LED_Array_Port: std_logic_vector ( 7 downto 0);
  component memory is
    port(
      Address: in std_logic_vector(15 downto 0); --adres pamieci przechowywany w postaci bajtowej
      WriteWord: in std_logic; -- jeeli stan jest wysoki zostanie zapisane 16 bitowe slowo, ostatni bit musi byc bitem zerowym
      WriteEnable: in std_logic;
      Clock: in std_logic; --zegar
      DataIn: in std_logic_vector(15 downto 0);
      DataOut: out std_logic_vector(15 downto 0);
      Port0: inout std_logic_vector(7 downto 0)
    );
  end component;

  component core is
    port(
      --interfejs pamieci
      MemAddr: out std_logic_vector(15 downto 0); --adres pamieci przechowywany w postaci bajtowej
      MemWW: out std_logic;
      MemWE: out std_logic;
      MemIn: in std_logic_vector(15 downto 0);
      MemOut: out std_logic_vector(15 downto 0);
      --interfejs ogolny
      Clock: in std_logic;
      Reset: in std_logic; --reset

      Hold: in std_logic; --kiedy przypiszemy 1 (stan wysoki) to inne bloki moga pobierac dane z pamieci
      HoldAck: out std_logic;
      --porty sluzace do debugowania
      DebugIR: out std_logic_vector(15 downto 0); --aktualnie wykonywana instrukcja
      DebugIP: out std_logic_vector(7 downto 0); --akutalna wartosc IP
      DebugFR: out std_logic_vector (2 downto 0); --akuralna wartosc rejestru flagowego
      DebugA: out std_logic_vector(7 downto 0);
      DebugB: out std_logic_vector(7 downto 0);
      DebugR0: out std_logic_vector(7 downto 0);
      DebugR1: out std_logic_vector(7 downto 0);
      DebugR2: out std_logic_vector(7 downto 0);
      DebugR3: out std_logic_vector(7 downto 0)
    );
  end component;
  component bootrom is
    port(
        CLK : in std_logic;
        EN : in std_logic;
        ADDR : in std_logic_vector(4 downto 0);
        DATA : out std_logic_vector(15 downto 0)
    );
  end component;
  signal cpuaddr: std_logic_vector(15 downto 0);
  signal cpuww: std_logic;
  signal cpuwe: std_logic;
  signal cpumemin: std_logic_vector(15 downto 0);
  signal cpumemout: std_logic_vector(15 downto 0);
  signal debugir: std_logic_vector(15 downto 0);
  signal debugip: std_logic_vector(7 downto 0);
--  signal debugfr: std_logic_vector (2 downto 0);
 -- SYGNALY PAMIECI
  signal MemAddress: std_logic_vector(15 downto 0); --adres pamieci przechowywany w postaci bajtowe
  signal MemWriteWord: std_logic; -- jezli stan jest wysoki zostanie zapisane 16 bitowe slowo, ostatni bit musi byc bitem zerowym
  signal MemWriteEnable: std_logic;
  signal MemDataIn: std_logic_vector(15 downto 0);
  signal MemDataOut: std_logic_vector(15 downto 0);
  -- SYGNALY BOOTROM
  signal BootAddress: std_logic_vector(4 downto 0);
  signal BootMemAddress: std_logic_vector(15 downto 0);
  signal BootDataIn: std_logic_vector(15 downto 0);
  signal BootDataOut: std_logic_vector(15 downto 0);
  signal BootDone: std_logic;
  signal BootFirst: std_logic;
  constant ROMSIZE: integer := 64; -- stala wielkosc pamieci ROM
  signal counter: std_logic_vector(4 downto 0);
begin
  cpu: core port map ( -- przyporzadkowanie portow z bloku top i core
    MemAddr => cpuaddr,
    MemWW => cpuww,
    MemWE => cpuwe,
    MemIn => cpumemin,
    MemOut => cpumemout,
    Clock => Clock,
    Reset => Reset,
    Hold => Hold,
    HoldAck => HoldAck,
    DebugIR => DebugIR,
    DebugIP => DebugIP,
    DebugFR => DebugFR,
    DebugA => DebugA,
	 --DebugA => LED,
    DebugB => DebugB,
    DebugR0 => DebugR0,
    DebugR1 => DebugR1,
    DebugR2 => DebugR2,
    DebugR3 => DebugR3
  );
  mem: memory port map( -- przyporzadkowanie portow z bloku top i memory
    Address => MemAddress,
    WriteWord => MemWriteWord,
    WriteEnable => MemWriteEnable,
    Clock => Clock,
    DataIn => MemDataIn,
    DataOut => MemDataOut,
    Port0 => Port0
  );
  rom: bootrom port map( -- przyporzadkowanie portow z bloku top i bootrom
    clk => clock,
    EN => '1',
    Addr => BootAddress,
    Data => BootDataOut
  );
  MemAddress <= cpuaddr when (DMA='0' and Reset='0') else BootMemAddress when (Reset='1' and DMA='0') else Address; -- zapis do MemAddress
  MemWriteWord <= cpuww when DMA='0' and Reset='0' else '1' when Reset='1'  and DMA='0' else '1'; -- zapis do MemWriteWord
  MemWriteEnable <= cpuwe when DMA='0' and Reset='0' else'1'  when Reset='1' and DMA='0' else WriteEnable; -- zapis do MemWriteEnable
  MemDataIn <= cpumemout when DMA='0' and Reset='0' else Data when WriteEnable='1' else BootDataIn when Reset='1' and DMA='0' else  "ZZZZZZZZZZZZZZZZ"; -- zapis do MemDataIn
  cpumemin <= MemDataOut;
  Data <= MemDataOut when DMA='1' and Reset='0' and WriteEnable='0' else "ZZZZZZZZZZZZZZZZ";
  bootload: process(Clock, Reset)
  begin
    if rising_edge(clock) then
      if Reset='0' then
        counter <= "00000";
        BootDone <= '0';
        BootAddress <= "00000";
		  LED<= b"10101010";
		  --LCD_D<= b"1010";
        BootDataIn <= BootDataOut;
        BootFirst <= '1';
      elsif Reset='1' and BootFirst='1' then
        BootMemAddress <= "00000001000" & "00000";
        BootAddress <= "00001";
        counter <= "00001";
        BootFirst <= '0';
      elsif Reset='1' and BootDone='0' then
        BootMemAddress <= "0000000100" & std_logic_vector(unsigned(counter)-1) & "0";
        BootAddress <= std_logic_vector(unsigned(counter) + 1);
        BootDataIn <= BootDataOut;
        counter <= std_logic_vector(unsigned(counter) + 1);
        if to_integer(unsigned(counter))>=(ROMSIZE/2-2) then
          BootDone <= '1';
        end if;
      else

      end if;
    end if;
  end process;
end Behavioral;
