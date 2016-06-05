LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY memory_tb IS
END memory_tb;

ARCHITECTURE behavior OF memory_tb IS


  component memory
    port(
      Address: in std_logic_vector(15 downto 0); --adres pamieci w postaci bajtowej
      WriteWord: in std_logic;							-- 1- zapisujemy 16-bitow, 0- zapisujemy 8-bitow
      WriteEnable: in std_logic;							-- 1-zapis, 0-odczyt
      Clock: in std_logic;
      DataIn: in std_logic_vector(15 downto 0);
      DataOut: out std_logic_vector(15 downto 0);
      Port0: inout std_logic_vector(7 downto 0)
    );
  end component;


  --WEJ�CIA
  signal Address: std_logic_vector(15 downto 0) := (others => '0');
  signal WriteWord: std_logic := '0';
  signal WriteEnable: std_logic := '0';
  signal DataIn: std_logic_vector(15 downto 0) := (others => '0');

  --WYJ�CIA
  signal DataOut: std_logic_vector(15 downto 0);

  --WEJ�CIA
  signal Port0: std_logic_vector(7 downto 0);

  signal Clock: std_logic;
  constant clock_period : time := 10 ns;

BEGIN


  uut: memory PORT MAP (
    Address => Address,
    WriteWord => WriteWord,
    WriteEnable => WriteEnable,
    Clock => Clock,
    DataIn => DataIn,
    DataOut => DataOut,
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
    wait for 50 ns;


    Address <= x"0100";		--ustawiamy adres '0100'
    WriteWord <= '1';		--ustawiamy mozliwosc zapisu calego 16-bitowego slowa, zamiast bajtu
    WriteEnable <='1';		--ustawiamy mozliwosc zapisu
    DataIn <= x"1234";		--wrzucamy '1234'
    wait for 10 ns;
    WriteWord <= '0';		--odczytujemy cale 16-bitowe slowo
    WriteEnable <= '0';		--ustawiamy na odczyt
    wait for 10 ns;
    assert (DataOut = x"1234") report "Awaria przechowania" severity error;		--sprawdzamy czy odczytujemy to co zapisalismy

    Address <= x"0122";		--zmieniamy adres na inny
    WriteWord <= '1';		--znow staramy sie zapisac cale 16-bitowe slowo wrzucajac wartosc '5215'
    WriteEnable <= '1';
    DataIn <= x"5215";
    wait for 10 ns;			--nie zmienilismy mozliwosci odczytu dla adresu '0122', wiec wciaz nam sprawdza wartosc pod adresem '0100' 
    assert (DataOut = x"1234") report "Brak zmiany, awaria bloku RAM" severity error;
    WriteWord <= '0';		--ustawiamy mozliwosc odczytu, lecz zmieniamy znow na adres '0100',
    WriteEnable <= '0';		--sprawdzajac czy dalej jest tam ta sama wartosc, jesli nie to awaria pamieci
    Address <= x"0100";
    wait for 10 ns;
    assert( DataOut = x"1234") report "Awaria pamieci" severity error;
    Address <= x"0122";		--zmieniamy adres na '0122' i jako, ze mamy mozlwiosc odczytu to
    wait for 10 ns;			--sprawdzamy czy jest nasza wartosc '5215' i czy odpowiednio szybko porusza sie po komorkach pamieci
    assert( DataOut = x"5215") report "Taktowanie pamieci jest za wolne" severity error;

    Address <= x"0110";		--ustawiamy adres na '0110' i dajemy mozliwosc zapisu + zapisu calego 16-bitowego slowa
    WriteWord <= '1';
    WriteEnable <= '1';
    DataIn <= x"1234";		--wrzucamy wartosc '1234'
    wait for 10 ns;
    WriteWord <= '0';		--mozliwosc odczytu calego slowa, ale ustawiamy adres na '0111',
    WriteEnable <= '0';		--czyli na starsza czesc naszej wartosci
    Address <= x"0111";		--wiec z liczby '1234' powinna znalezc sie tylko '12'
    wait for 10 ns;
    assert (DataOut = x"0012") report "Niezestrojona pamiec, zly odczyt" severity error;
    WriteWord <='0';		--ustawiamy mozliwosc zapisu, teraz jednak korzystamy tylko z zapisu bajtu (8 bitow)
    WriteEnable <= '1';
    DataIn <= x"0056";		--wrzucamy '56'
    wait for 10 ns;
    WriteEnable <= '0';		--ustawiamy odczyt i sprawdzamy czy jest nasza wartosc '56'
    wait for 10 ns;
    assert (DataOut = x"0056") report "Niezestrojona pamiec, zly zapis, zly odczyt" severity error;
    Address <= x"0110";		--ustawiamy na adres '0110' i jako, ze sprawdzamy 2 bajty pamieci, czyli od '0110' do '0111'
    wait for 10 ns;			-- i wczesniej do '0111' wrzucilismy '56' to odczytujac te dwie komorki powinnismy otrzymac
    assert (DataOut = x"5634") report "Niezestrojona pamiec, blad zapisu" severity error;		--zlepek dwoch 'wrzucen' czyli '56' i z wczesniejszego ('1234') tylko '34'
    WriteEnable <= '1';		--zapis bajtu i wartosci '78'
    DataIn <= x"0078";
    wait for 10 ns;
    WriteEnable <= '0';		--odczyt czy zmienila sie tylko koncowka, czyli czy '34' zmienilo sie na '78'
    wait for 10 ns;
    assert (DataOut = x"5678") report "Niezestrojona pamiec, blad zapisu" severity error;

    Address <= x"0001";		--ustawiamy adres '0001', ktory jest przeznaczony dla portu0,
    Port0 <= "ZZZZZZ1Z";	--ustawiajac tam wartosc 'ZZZZZZ1Z'
    WriteWord<='0';			
    WriteEnable <= '1';		--ustawiamy mozliwosc zapisu tylko bajtu i wrzucamy wartosc '1'
    DataIn <= x"0001";		
    wait for 10 ns;
    WriteEnable <= '0';		--manipulujemy odczytem/zapisem i zmiana adresu i czekamy
    Address <= x"1234";
    wait for 20 ns;		
    WriteEnable <= '1';		--zmieniamy na mozliwosc zapisu
    Address <= x"0000";		--zmieniamy na adres '0000', ktory jest tez przeznaczony dla portu0, czyli manipulujemy na wartosciach portu
    DataIn <= x"0001";		--i ustawiamy '1'

    wait for 10 ns;
    WriteEnable <= '0';		--teraz ustawiajac na odczyt w dataout i port0 na dwoch najmlodszych bitach powinny byc '1' a na reszcie slowa bajtowego 'Z'
    assert(Port0(0)='1') report "blad port0" severity error;
    wait for 10 ns;
    assert(DataOut(1)='1') report "blad port0" severity error;


    wait for 10 ns;
    Address <= x"0001";		--ustawiamy adres na '0001' przeznaczony dla portu0
    WriteWord <= '0';		--mozliwosc tylko zapisu bajtu i wrzucamy wartosc '00000000_0011_1000'
    WriteEnable <= '1';		--czyli w rezultacie wsadzamy '00111000'
    DataIn <= b"00000000_0011_1000";
    wait for 10 ns;
    Address <= x"0000";		--zmieniamy na adres '0000' 
    Port0 <= "10ZZZ101";	--port0 ustawiamy na wartosc '10ZZZ101'
    DataIn <= x"00" & b"00_101_011";	--sprawdzamy mozliwosc zapisu dwojakiego laczonego, heksadymalnie dwa zera a reszta bajtowo,
    wait for 10 ns;							--czyli w rezultacie powinno byc w datain '0000000000101011'
    WriteEnable <= '0';						--ustawiamy na odczyt
    wait for 10 ns;		--po zlaczeniach datain i portu0, w porcie0 i dataout powinna teraz znalezc sie wartosc '10101101'/'x"00" & b"10101101"'
    assert(Port0 = "10101101") report "Zmapowane porty nie dzialaja poprawinie" severity error;
    assert(DataOut = x"00" & "10101101") report "Zmapowane porty nie dzialaja poprawinie" severity error;


   assert false
   report "Test pamieci zakonczono pomyslnie!"
   severity note;

    wait;



    wait;
  end process;


END;
