--MODUL CORE
--modul dekodujacy i laczacy podlegajace mu komponenty takie jak registerfile,fetcher,alu


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.whitelion.all;

entity core is
  port(
  
    --interfejs pamieci
    MemAddr: out std_logic_vector(15 downto 0); --adres pamieci przechowywany w postaci bajtowej
    MemWW: out std_logic;
    MemWE: out std_logic;
    MemIn: in std_logic_vector(15 downto 0);
    MemOut: out std_logic_vector(15 downto 0);

	 --glowny interfejs
    Clock: in std_logic;
    Reset: in std_logic; --kiedy przypiszemy 1 do RESET wszystko zostanie zresetowane podczas 1 cyklu zegarowego
    Hold: in std_logic; --kiedy przypiszemy 1 (stan wysoki) to inne bloki moga pobierac dane z pamieci
    HoldAck: out std_logic;

    -- PORTY DO DEBUGOWANIA
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
end core;

architecture Behavioral of core is
  component fetch is
    port(
      Enable: in std_logic;
      AddressIn: in std_logic_vector(15 downto 0);
      Clock: in std_logic;
      DataIn: in std_logic_vector(15 downto 0); --pobranie danych z pamieci
      IROut: out std_logic_vector(15 downto 0);
      AddressOut: out std_logic_vector(15 downto 0) --zapis do pamieci
    );
  end component;

  component alu is
    port(
      Op: in std_logic_vector(4 downto 0);
      DataIn1: in std_logic_vector(7 downto 0);
      DataIn2: in std_logic_vector(7 downto 0);
      DataOut: out std_logic_vector(7 downto 0);
      FR: out std_logic_vector(2 downto 0)
    );
  end component;

  component registerfile is
	  port(
		 WriteEnable: in regwritetype;
		 DataIn: in regdatatype;
		 Clock: in std_logic;
		 DataOut: out regdatatype
	  );
  end component;

  constant REGIP: integer := 7;

  type ProcessorState is (
    ResetProcessor,
    FirstFetch1, -- Fetcher potrzebuje dwoch cykli zegarowcyh aby przechwycic instrukcje
    FirstFetch2,
    Firstfetch3,
    Execute,
    WaitForMemory,
    HoldMemory,
    WaitForAlu --  stan w ktorym czekamy az alu skonczy wykonywac zadania
  );
  -- SYGNALY STANOW PROCESORA
  signal state: ProcessorState;
  signal HeldState: ProcessorState;
  -- SYGNALY IP oraz SP
  signal IPAddend: std_logic_vector(7 downto 0);


  -- SYGNALY REJESTROW
  signal regWE:regwritetype;
  signal regIn: regdatatype;
  signal regOut: regdatatype;

  -- SYGNALY FETCHERA
  signal fetchEN: std_logic;
  signal IR: std_logic_vector(15 downto 0);

  -- SYGNALY ALU
  signal AluOp: std_logic_vector(4 downto 0);
  signal AluIn1: std_logic_vector(7 downto 0);
  signal AluIn2: std_logic_vector(7 downto 0);
  signal AluOut: std_logic_vector(7 downto 0);
  signal AluFR: std_logic_vector(2 downto 0);
  signal FR: std_logic_vector(2 downto 0);
  signal FRData: std_logic_vector(2 downto 0);
  signal UseAluFR: std_logic_vector(2 downto 0);

  -- SYGNALY KONTROLUJACE
  signal InReset: std_logic;
  signal OpAddress: std_logic_vector(15 downto 0); --sygnal ktory przechowuje adres ktory zostaje wykorzystywany do obslugi instrukcji
  signal OpDataIn: std_logic_vector(15 downto 0);
  signal OpDataOut: std_logic_vector(15 downto 0);
  signal OpWW: std_logic;
  signal OpWE: std_logic;
  signal OpDestReg1: std_logic_vector(3 downto 0);
  signal OpUseReg2: std_logic;
  signal OpDestReg2: std_logic_vector(3 downto 0);

  -- SYGNALY INSTRUKCJI
  signal opmain: std_logic_vector(4 downto 0);
  signal opimmd: std_logic_vector(7 downto 0);
  signal opreg1: std_logic_vector(2 downto 0);
  signal opreg2: std_logic_vector(2 downto 0);

  signal regbank: std_logic;

  signal fetcheraddress: std_logic_vector(15 downto 0);
	-- SYGNALY Z BANKU REJESTROW
  signal bankreg1: std_logic_vector(2 downto 0);
  signal bankreg2: std_logic_vector(2 downto 0);
  signal FetchMemAddr: std_logic_vector(15 downto 0);

  signal AluRegOut: std_logic_vector(2 downto 0);
begin

  reg: registerfile port map( -- przypisanie portow z core i registerfile
    WriteEnable => regWE,
    DataIn => regIn,
    Clock => Clock,
    DataOut => regOut
  );

  fetcher: fetch port map( -- przypisanie portow z core i fetchera
    Enable => fetchEN,
    AddressIn => fetcheraddress,
    Clock => Clock,
    DataIn => MemIn,
    IROut => IR,
    AddressOut => FetchMemAddr
  );

  cpualu: alu port map( -- przypisanie portow z core i alu
    Op => AluOp,
    DataIn1 => AluIn1,
    DataIn2 => AluIn2,
    DataOut => AluOut,
    FR => AluFR
  );

  fetcheraddress <= "00000001" & regIn(REGIP);
  MemAddr <= OpAddress when state=WaitForMemory else FetchMemAddr;
  MemOut <= OpDataOut when (state=WaitForMemory and OpWE='1') else "ZZZZZZZZZZZZZZZZ" when state=HoldMemory else x"0000";
  MemWE <= OpWE when state=WaitForMemory else 'Z' when state=HoldMemory else '0';
  MemWW <= OpWW when state=WaitForMemory else 'Z' when state=HoldMEmory else '0';
  OpDataIn <= MemIn;

  -- POSZCZEGOLNE SYGNALY W INSTRUKCJI, NAJPIERW KOD INSTRUKCJI, NASTEPNIE REJESTR, NASTEPNIE STALA LUB REJESTR
  opmain <= IR(15 downto 11);
  opimmd <= IR(7 downto 0);
  opreg1 <= IR(10 downto 8);
  opreg2 <= IR(7 downto 5);


  -- PORTY DO DEBUGOWANIA CS, IP ORAZ REJESTROW
  DebugA <= regOut(0);
  DebugB <= regOut(1);
  DebugR0 <= regOut(2);
  DebugR1 <= regOut(3);
  DebugR2 <= regOut(4);
  DebugR3 <= regOut(5);
  
  DebugIP <= regOut(REGIP);
  DebugIR <= IR;
  DebugFR <= FR;
	-- PORTY Z BANKU REJESTROW
  bankreg1 <= opreg1;
  bankreg2 <= opreg2;

  FR <= AluFR;

  foo: process(Clock, Hold, state, IR, inreset, reset, regin, regout)
  begin
    if rising_edge(Clock) then
    --STANY
      if reset='1' and hold='0' then
        InReset <= '1';
        state <= ResetProcessor;
        HoldAck <= '0';
		  
        regWE <= (others => '1'); 
        regIn <= (others => "00000000"); --resetowanie rejestrów
		  regIn(REGIP) <= (others => '0'); -- resetowanie instruction pointera
        regWE(REGIP) <= '1';
		  AluOp <= "11111"; -- resetowanie rejestru flagowego w ALU
		  
        regbank <= '0';
        fetchEN <= '1';
        OpDataOut <= "ZZZZZZZZZZZZZZZZ";
        OpAddress <= x"0000";
        OpWE <= '0';
        opWW <= '0';
        FRData <= "000";
        UseAluFR <= "000";
        OpDestReg1<= x"0";
        OpDestReg2 <= x"0";
        OpUseReg2 <= '0';
        --zakoncz przypisywanie
		  
      elsif InReset='1' and reset='0' and Hold='0' then --Jezli w InReset 1 zacznij wykonywac dzialania
        InReset <= '0';
        fetchEN <= '1';
        state <= FirstFetch1;
		  
      elsif Hold = '1' and (state=HoldMemory or state=Execute or state=ResetProcessor) then
        state <= HoldMemory;
        HoldAck <= '1';
        FetchEN <= '0';
		  
      elsif Hold='0' and state=HoldMemory then
        if reset='1' or InReset='1' then
          state <= ResetProcessor;
        else
          state <= Execute;
        end if;
        FetchEN <= '1';
      
		elsif state=FirstFetch1 then --trzeba pozwolic rejestrowi instrukcji zaladowac sie przed tym jak przejdziemy do wykonywania czynnosci
        regWE <= (others => '0');
        fetchEN <= '1';
        regWE <= (others => '0');	
        RegWE <= (others => '0');
        regIn(REGIP) <= std_logic_vector(unsigned(regIn(REGIP))+2);
        regWE(REGIP) <= '1';
        state <= Execute;
      
		elsif state=FirstFetch2 then
        state <= FirstFetch3;
      
		elsif state=FirstFetch3 then
        state <= Execute;
      
		elsif state=WaitForMemory then
        state <= Execute;
        FetchEn <= '1';
        if OpWE='0' then
          regIn(to_integer(unsigned(OpDestReg1))) <= OpDataIn(7 downto 0);
          regWE(to_integer(unsigned(OpDestReg1))) <= '1';
          if OpUseReg2='1' then
            regIn(to_integer(unsigned(OpDestReg2))) <= OpDataIn(15 downto 8);
            regWE(to_integer(unsigned(OpDestReg2))) <= '1';
          end if;
        end if;
      
		elsif state=WaitForAlu then
        state <= Execute;
        regIn(to_integer(unsigned(AluRegOut))) <= AluOut;  -- zapis wyniku operacji do rejestru
        regWE(to_integer(unsigned(AluRegOut))) <= '1';	-- WRITE ENABLE
        FetchEN <= '1';

      end if;

-- STAN EXECUTE - WYKONYWANIE INSTRUKCJI

		if state=Execute then
        fetchEN <= '1';
 
        RegWE <= (others => '0');

		  regIn(REGIP) <= std_logic_vector(unsigned(regIn(REGIP))+2);
		  regWE(REGIP) <= '1';

        OpUseReg2 <= '0';
        OpAddress <= "ZZZZZZZZZZZZZZZZ";

        if UseAluFR="111" then
          UseAluFR<="000";
        end if;

-- DEKODOWANIE KODU OPERACJI
		  case opmain is
				when "00000" => --add reg, imm
					State <= WaitForAlu;
					AluOp <= "00000";
					AluIn1 <= regOut(to_integer(unsigned(bankreg1)));
					AluIn2 <= opimmd;
					AluRegOut <= bankreg1;

				when "00001" => --add reg, reg
					State <= WaitForAlu;
					AluOp <= "00001";
					AluIn1 <= regOut(to_integer(unsigned(bankreg1)));
					AluIn2 <= regOut(to_integer(unsigned(bankreg2)));
					AluRegOut <= bankreg1;

				when "00010" => --sub reg, imm
					State <= WaitForAlu;
					AluOp <= "00010";
					AluIn1 <= regOut(to_integer(unsigned(bankreg1)));
					AluIn2 <= opimmd;
					AluRegOut <= bankreg1;

				when "00011" => --sub reg, reg
					State <= WaitForAlu;
					AluOp <= "00011";
					AluIn1 <= regOut(to_integer(unsigned(bankreg1)));
					AluIn2 <= regOut(to_integer(unsigned(bankreg2)));
					AluRegOut <= bankreg1;

				when "00100" => --mul reg, imm
					State <= WaitForAlu;
					AluOp <= "00100";
					AluIn1 <= regOut(to_integer(unsigned(bankreg1)));
					AluIn2 <= opimmd;
					AluRegOut <= bankreg1;

				when "00101" => --mul reg, reg
					State <= WaitForAlu;
					AluOp <= "00101";
					AluIn1 <= regOut(to_integer(unsigned(bankreg1)));
					AluIn2 <= regOut(to_integer(unsigned(bankreg2)));
					AluRegOut <= bankreg1;

				when "00110" => --mov reg,imm
					regIn(to_integer(unsigned(bankreg1))) <= opimmd;
					regWE(to_integer(unsigned(bankreg1))) <= '1';

				when "00111" => --mov reg, reg
					regIn(to_integer(unsigned(bankreg1))) <= regOut(to_integer(unsigned(bankreg2)));
					regWE(to_integer(unsigned(bankreg1))) <= '1';

				when "01000" => --inc reg
					State <= WaitForAlu;
					AluOp <= "01000";
					AluIn1 <= regOut(to_integer(unsigned(bankreg1)));
					AluRegOut <= bankreg1;

				when "01001" => --dec reg
					State <= WaitForAlu;
					AluOp <= "01001";
					AluIn1 <= regOut(to_integer(unsigned(bankreg1)));
					AluRegOut <= bankreg1;

				when "01010" => --cmp reg, imm
					AluOp <= "01010";
					AluIn1 <= regOut(to_integer(unsigned(bankreg1)));
					AluIn2 <= opimmd;

				when "01011" => --cmp reg, reg
					AluOp <= "01011";
					AluIn1 <= regOut(to_integer(unsigned(bankreg1)));
					AluIn2 <= regOut(to_integer(unsigned(bankreg2)));

				when "01100" => --OR reg, imm
					State <= WaitForAlu;
					AluOp <= "01100";
					AluIn1 <= regOut(to_integer(unsigned(bankreg1)));
					AluIn2 <= opimmd;
					AluRegOut <= bankreg1;

				when "01101" => --OR reg, reg
					State <= WaitForAlu;
					AluOp <= "01101";
					AluIn1 <= regOut(to_integer(unsigned(bankreg1)));
					AluIn2 <= regOut(to_integer(unsigned(bankreg2)));
					AluRegOut <= bankreg1;

			 	when "01110" => --AND  reg, imm
					State <= WaitForAlu;
					AluOp <= "01110";
					AluIn1 <= regOut(to_integer(unsigned(bankreg1)));
					AluIn2 <= opimmd;
					AluRegOut <= bankreg1;

				when "01111" => --AND reg, reg
					State <= WaitForAlu;
					AluOp <= "01111";
					AluIn1 <= regOut(to_integer(unsigned(bankreg1)));
					AluIn2 <= regOut(to_integer(unsigned(bankreg2)));
					AluRegOut <= bankreg1;

				when "10000" => --NOT imm
					State <= WaitForAlu;
					AluOp <= "10000";
					AluIn1 <= opimmd;
					AluRegOut <= bankreg1;

				when "10001" => --NOT reg
					State <= WaitForAlu;
					AluOp <= "10001";
					AluIn1 <= regOut(to_integer(unsigned(bankreg1)));
					AluRegOut <= bankreg1;

				when "10010" => --JUMP
					regIn(REGIP) <= opimmd;
					regWE(REGIP) <= '1';
					
				when "11001" => --JW
					if(AluFR = "100") then
						regIn(REGIP) <= opimmd;
						regWE(REGIP) <= '1';
					end if;
					
				when "11010" => --JR
					if(AluFR = "010") then
						regIn(REGIP) <= opimmd;
						regWE(REGIP) <= '1';	
					end if;
					
				when "11000" => --JM
					if(AluFR = "001") then
						regIn(REGIP) <= opimmd;
						regWE(REGIP) <= '1';
					end if;
					
				when "10011" => --NOP

				when "10101" => --XOR  reg, imm
					State <= WaitForAlu;
					AluOp <= "10101";
					AluIn1 <= regOut(to_integer(unsigned(bankreg1)));
					AluIn2 <= opimmd;
					AluRegOut <= bankreg1;

				when "10110" => --XOR reg, reg
					State <= WaitForAlu;
					AluOp <= "01110";
					AluIn1 <= regOut(to_integer(unsigned(bankreg1)));
					AluIn2 <= regOut(to_integer(unsigned(bankreg2)));
					AluRegOut <= bankreg1;
				when others =>
					report "Instrukcja o podanym kodzie nie zostala zdefiniowana" severity error;
			end case;
       end if;
     end if;
  end process;
end Behavioral;
