-- Autorzy:
-- Hanna Banasiak  193078
-- Michał Pawiłojć 193159

-- Symulacja polega na prowadzeniu pizzerii jednopiecowej.
-- Dostawcy dostarczają składniki potrzebne do przygotowania pizzy.
-- Klienci zamawiają różne pizze.
--    1. Gdy nie ma składników do przygotowania pizzy, wychodzą.
--    2. Gdy składniki są, pizza jest przygotowywana.
--    3. Gdy składniki są, lecz inna pizza jest w trakcie przygotowywania, czekają Max_Czas_Czekania_Na_Pizze,
--       w przypadku przekroczenia czasu oczekiwania, klient wychodzi.
-- (Dla lepszej czytelności wydarzenia klientów oznaczone zostały '###' na początku komunikatu)
-- Pizzeria_Magazyn odpowiedzialna jest za obsługę składników: przyjęcie do magazynu i przygotowanie do zamówienia.
-- Pizzeria_Piec odpowiedzialna jest za pieczenie pizzy.
-- (Piec jest jeden, co pozwala na pieczenie tylko jednej pizzy naraz)


with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Numerics.Discrete_Random;


procedure Simulation is

   ---STAŁE-------------------------------------------------------------------------------------
   Number_Of_Products: constant Integer := 5;
   Number_Of_Assemblies: constant Integer := 3;
   Number_Of_Consumers: constant Integer := 2;
   Czas_Pieczenia_Pizzy: constant Integer := 8;
   Max_Czas_Czekania_Na_Pizze: constant Duration := 4.0;

   subtype Product_Type is Integer range 1 .. Number_Of_Products;
   subtype Assembly_Type is Integer range 1 .. Number_Of_Assemblies;
   subtype Consumer_Type is Integer range 1 .. Number_Of_Consumers;

   Product_Name: constant array (Product_Type) of String(1 .. 6)
     := ("Oliwki", "Szynka", "Grzyby", "Salami", "Cebula");
   Assembly_Name: constant array (Assembly_Type) of String(1 .. 10)
     := ("KingOfMeat", "Willagersa", "Wegetarino");

   package Random_Assembly is new
     Ada.Numerics.Discrete_Random(Assembly_Type);
   type My_Str is new String(1 .. 256);

   ---DEKLARACJE----------------------------------------------------------------------------------
   task type Dostawcy is
      entry Start(Product: in Product_Type; Production_Time: in Integer);
   end Dostawcy;

   task type Klient is
      entry Start(Consumer_Number: in Consumer_Type;
                  Consumption_Time: in Integer);
   end Klient;

   task type Pizzeria_Magazyn is
      entry Wez_do_magazynu(Product: in Product_Type; Number: in Integer);
      entry Zbierz_skladniki(Assembly: in Assembly_Type; Number: out Integer);
   end Pizzeria_Magazyn;

   task type Pizzeria_Piec is
      entry Pieczenie_Pizzy;
   end Pizzeria_Piec;

   P: array ( 1 .. Number_Of_Products ) of Dostawcy;
   K: array ( 1 .. Number_Of_Consumers ) of Klient;
   PM: Pizzeria_Magazyn;
   PP: Pizzeria_Piec;

   ---DEFINICJE-------------------------------------------------------------------------------------


   ---DEFINICJE--PRODUCER---------------------------------------------------------------------------
   task body Dostawcy is

      subtype Production_Time_Range is Integer range 3 .. 6;
      package Random_Production is new Ada.Numerics.Discrete_Random(Production_Time_Range);
      G: Random_Production.Generator;
      Product_Type_Number: Integer;
      Product_Count: Integer;
      Production: Integer;

   begin -- KONSTRUKTOR

      accept Start(Product: in Product_Type; Production_Time: in Integer) do
         Random_Production.Reset(G);
         Product_Count := 1;
         Product_Type_Number := Product;
         Production := Production_Time;
      end Start;
      Put_Line("Zatrudnienie dostawcy produktu: " & Product_Name(Product_Type_Number));
      loop
         delay Duration(Random_Production.Random(G));
         Put_Line("Przygotowano do transportu produkt: " & Product_Name(Product_Type_Number));
         PM.Wez_do_magazynu(Product_Type_Number, Product_Count);
         Product_Count := Product_Count + 1;
      end loop;

   end Dostawcy;

   ---DEFINICJE--CONSUMER---------------------------------------------------------------------------
   task body Klient is

      subtype Consumption_Time_Range is Integer range 4 .. 8;
      package Random_Consumption is new Ada.Numerics.Discrete_Random(Consumption_Time_Range);
      G: Random_Consumption.Generator;
      G2: Random_Assembly.Generator;
      Consumer_Nb: Consumer_Type;
      Assembly_Number: Integer;
      Consumption: Integer;
      Assembly_Type: Integer;
      Consumer_Name: constant array (1 .. Number_Of_Consumers)
        of String(1 .. 5)
        := ("Bilas", "Hania");

   begin

      accept Start(Consumer_Number: in Consumer_Type;
                   Consumption_Time: in Integer) do
         Random_Consumption.Reset(G);
         Random_Assembly.Reset(G2);
         Consumer_Nb := Consumer_Number;
         Consumption := Consumption_Time;
      end Start;
      Put_Line("Powstał klient " & Consumer_Name(Consumer_Nb));
      loop
         delay Duration(Random_Consumption.Random(G));
         Assembly_Type := Random_Assembly.Random(G2);

         Put_Line("### Klient " & Consumer_Name(Consumer_Nb) & " zamówił pizze " & Assembly_Name(Assembly_Type));
         PM.Zbierz_skladniki(Assembly_Type, Assembly_Number);

         if Assembly_Number /= 0 then -- sprawdzamy, czy nie zwrócono 0 -> brak możliwości stworzenia zestawu

            select -- 1.Są składniki, pizza wstawiona do pieca
               PP.Pieczenie_Pizzy;
               Put_Line("### Klient " & Consumer_Name(Consumer_Nb) & " odebrał pizze " & Assembly_Name(Assembly_Type));
            or delay Max_Czas_Czekania_Na_Pizze; -- 2. Są składniki, ale piec jest zbyt długo zajęty
               Put_Line("### " & Consumer_Name(Consumer_Nb) & ": Idę sobie, za długo robicie moją pizze");
            end select;

         else -- 3. Nie ma składników
            Put_Line("### " & Consumer_Name(Consumer_Nb) & ": Nie możecie zrobić mojej pizzy, to wychodę.");
         end if;
      end loop;

   end Klient;

   ---DEFINICJE--BUFFER---------------------------------------------------------------------------
   task body Pizzeria_Magazyn is

      Storage_Capacity: constant Integer := 30;
      type Storage_type is array (Product_Type) of Integer;
      Storage: Storage_type
        := (0, 0, 0, 0, 0);
      Assembly_Content: array(Assembly_Type, Product_Type) of Integer
        := ((0, 2, 0, 2, 0),
            (1, 1, 1, 1, 1),
            (2, 0, 2, 0, 2)); -- SKŁADNIKI (ILOŚĆ)
      Max_Assembly_Content: array(Product_Type) of Integer;
      Assembly_Number: array(Assembly_Type) of Integer
        := (1, 1, 1);
      Items_In_Storage_Count: Integer := 0;

      procedure Setup_Variables is
      begin
         for W in Product_Type loop
            Max_Assembly_Content(W) := 0;
            for Z in Assembly_Type loop
               if Assembly_Content(Z, W) > Max_Assembly_Content(W) then
                  Max_Assembly_Content(W) := Assembly_Content(Z, W);
               end if;
            end loop;
         end loop;
      end Setup_Variables;

      function Czy_jest_miejsce(Product: Product_Type) return Boolean is
         FreeRoomInStorage: Integer;		        -- free room in the storage
         Needed: array(Product_Type) of Integer; -- how many products are needed for production of arbitrary assembly
         Needed_room: Integer;                   -- how much room is needed in storage to produce arbitrary assembly
         MP: Boolean;			                     -- can accept
      begin

         if Items_In_Storage_Count >= Storage_Capacity then
            return False;
         end if; -- There is free room in the storage

         FreeRoomInStorage := Storage_Capacity - Items_In_Storage_Count;
         MP := True;

         for W in Product_Type loop
            if Storage(W) < Max_Assembly_Content(W) then
               MP := False;
            end if;
         end loop;

         if MP then
            return True;		--  storage has products for arbitrary assembly
         end if;

         if Integer'Max(0, Max_Assembly_Content(Product) - Storage(Product)) > 0 then -- exactly this product lacks
            return True;
         end if;

         Needed_room := 1;			--  insert current product

         for W in Product_Type loop
            Needed(W) := Integer'Max(0, Max_Assembly_Content(W) - Storage(W));
            Needed_room := Needed_room + Needed(W);
         end loop;

         if FreeRoomInStorage >= Needed_room then
            -- there is enough room in storage for arbitrary assembly
            return True;
         else -- no room for this product
            return False;
         end if;

      end Czy_jest_miejsce;

      function Czy_sa_skladniki(Assembly: Assembly_Type) return Boolean is
      begin
         for W in Product_Type loop
            if Storage(W) < Assembly_Content(Assembly, W) then
               return False;
            end if;
         end loop;
         return True;
      end Czy_sa_skladniki;

      procedure Zawartosc_Magazynu is
      begin
         Put_Line("---------------------------------------------");
         for W in Product_Type loop
            Put_Line("Zawartość magazynu: " & Integer'Image(Storage(W)) & " "
                     & Product_Name(W));
         end loop;
         Put_Line("---------------------------------------------");
      end Zawartosc_Magazynu;


   begin -- "KONSTRUKTOR"

      Put_Line("Otwarto pizzerię");
      Setup_Variables;

      loop
         select
            accept Wez_do_magazynu(Product: in Product_Type; Number: in Integer) do
               if Czy_jest_miejsce(Product) then
                  Put_Line("Dostarczono produkt " & Product_Name(Product) & " do magazynu.");
                  Storage(Product) := Storage(Product) + 1;
                  Items_In_Storage_Count := Items_In_Storage_Count + 1;
                  Zawartosc_Magazynu;
               end if;
            end Wez_do_magazynu;
         or

            accept Zbierz_skladniki(Assembly: in Assembly_Type; Number: out Integer) do
               if Czy_sa_skladniki(Assembly) then
                  Put_Line("Zabrano składniki na pizze " & Assembly_Name(Assembly));
                  for W in Product_Type loop
                     Storage(W) := Storage(W) - Assembly_Content(Assembly, W);
                     Items_In_Storage_Count := Items_In_Storage_Count - Assembly_Content(Assembly, W);
                  end loop;
                  Number := Assembly_Number(Assembly);
                  Assembly_Number(Assembly) := Assembly_Number(Assembly) + 1;
                  Zawartosc_Magazynu;
               else
                  -- Jeśli nie można zebrać składników, zwraca kod 0
                  Number := 0;
               end if;

            end Zbierz_skladniki;

         end select;
      end loop;

   end Pizzeria_Magazyn;

   task body Pizzeria_Piec is
   begin

      loop
         accept Pieczenie_Pizzy do
            for n in 1..Czas_Pieczenia_Pizzy loop
               Put_Line("Pizza się piecze, pozostało " & Integer'Image(Czas_Pieczenia_Pizzy - n + 1) & " minut");
               delay 1.0;
            end loop;
         end Pieczenie_Pizzy;
      end loop;
   end Pizzeria_Piec;

   ---DEFINICJE--MAIN---------------------------------------------------------------------------
begin
   for I in 1 .. Number_Of_Products loop
      P(I).Start(I, 10);
   end loop;
   for J in 1 .. Number_Of_Consumers loop
      K(J).Start(J,12);
   end loop;


end Simulation;
