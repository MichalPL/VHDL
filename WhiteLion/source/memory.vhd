--komponent zarzadzania pamiecia
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory is
  port(
    Address: in std_logic_vector(15 downto 0); --adres pamieci w postaci bajtowej
    WriteWord: in std_logic;
    WriteEnable: in std_logic;
    Clock: in std_logic;
    DataIn: in std_logic_vector(15 downto 0);
    DataOut: out std_logic_vector(15 downto 0);

    Port0: inout std_logic_vector(7 downto 0)

  );
end memory;

architecture Behavioral of memory is

  component blockram
    port(
      Address: in std_logic_vector(7 downto 0); --adres pamieci
      WriteEnable: in std_logic_vector(1 downto 0); --wczytywanie lub zapisywanie
      Enable: in std_logic;
      Clock: in std_logic; --zegar
      DataIn: in std_logic_vector(15 downto 0); --dane wejsciowe
      DataOut: out std_logic_vector(15 downto 0) --dane wyjsciowe
    );
  end component;

  constant R1START: integer := 15;
  constant R1END: integer := 1023+15;
  signal addr: std_logic_vector(15 downto 0) := (others => '0');
  signal R1addr: std_logic_vector(7 downto 0);
  signal we: std_logic_vector(1 downto 0);
  signal datawrite: std_logic_vector(15 downto 0);
  signal dataread: std_logic_vector(15 downto 0);
  signal R1we: std_logic_vector(1 downto 0);
  signal R1en: std_logic;
  signal R1in: std_logic_vector(15 downto 0);
  signal R1out: std_logic_vector(15 downto 0);

  signal port0we: std_logic_vector(7 downto 0);
  signal port0temp: std_logic_vector(7 downto 0);
begin
  R1: blockram port map (R1addr, R1we, R1en, Clock, R1in, R1out);
  addrwe: process(Address, WriteWord, WriteEnable, DataIn)
  begin
    addr <= Address(15 downto 1) & '0';
    if WriteEnable='1' then
      if WriteWord='1' then
        we <= "11";
        datawrite <= DataIn;
      else
        if Address(0)='0' then
          we <= "01";
          datawrite <= x"00" & DataIn(7 downto 0);
        else
          we <= "10";
          datawrite <= DataIn(7 downto 0) & x"00";
        end if;
      end if;
    else
      datawrite <= x"0000";
      we <= "00";
    end if;
  end process;

  assignram: process (we, datawrite, addr, r1out, port0, WriteEnable, Address, Clock, port0temp, port0we, DataIn)
  variable tmp: integer;
  variable tmp2: integer;
  variable found: boolean := false;
  begin
    tmp := to_integer(unsigned(addr));
    tmp2 := to_integer(unsigned(Address));
    if tmp2 <= 15 then --rejestry wewnetrzne/obsluga wejscia/wyjscia
      if rising_edge(Clock) then
        if WriteWord='0' then
          if tmp2=0 then

            gen: for I in 0 to 7 loop
              if WriteEnable='1' then
                if port0we(I)='1' then --1 bitowy port ustawiany do trybu zapisu

                  Port0(I) <= DataIn(I);
                  if I=0 then
                  end if;
                  port0temp(I) <= DataIn(I);

                else
                  port0(I) <= 'Z';
                  port0temp(I) <= '0';

                end if;
              else
                if port0we(I)='0' then --1 bitowy port ustawiany do trybu odczytu
                else

                end if;
              end if;
            end loop gen;
          elsif tmp2=1 then

            if WriteEnable='1' then
              port0we <= DataIn(7 downto 0);

              setwe: for I in 0 to 7 loop
                if DataIn(I)='0' then
                  port0(I) <= 'Z';
                end if;
              end loop setwe;
            else

            end if;
          else

            report "Poza pamiecia " severity warning;

          end if;

        else

          report "Nie mozna wykonac " severity warning;

        end if;
      end if;
      dataread <= x"0000";
      outgen: for I in 0 to 7 loop
        if tmp2=0 then
          if port0we(I)='1' then
            if WriteEnable='1' then
              dataread(I) <= DataIn(I);
            else
              dataread(I) <= port0temp(I);
            end if;
          else
            dataread(I) <= port0(I);
          end if;
        elsif tmp2=0 then
          if WriteEnable='1' then
            dataread(I) <= DataIn(I);
          else
            dataread(I) <= port0we(I);
          end if;
        else
          dataread(I) <= '0';
        end if;
      end loop outgen;
      R1en <= '0';
      R1we <= "00";
      R1in <= x"0000";
      R1addr <= x"00";
    elsif tmp >= R1START and tmp <= R1END then --RAM bank1
      --przypisz do R1
      found := true;
      R1en <= '1';
      R1we <= we;
      R1in <= datawrite;
      dataread <= R1out;
      R1addr <= addr(8 downto 1);
    else
      R1en <= '0';
      R1we <= "00";
      R1in <= x"0000";
      R1addr <= x"00";
      dataread <= x"0000";
    end if;
  end process;

  readdata: process(Address, dataread)
  begin
    if to_integer(unsigned(Address))>15 then
      if Address(0) = '0' then
        DataOut <= dataread;
      else
        DataOut <= x"00" & dataread(15 downto 8);
      end if;
    else
      DataOut <= x"00" & dataread(7 downto 0);
    end if;
  end process;
end Behavioral;
