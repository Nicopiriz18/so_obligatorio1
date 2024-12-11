with Ada.Text_IO; use Ada.Text_IO;

procedure Main is

   task type Semaforo is
      entry Wait;
      entry Signal;
      entry Init(Value : Integer);
   end Semaforo;

   task body Semaforo is
      Counter : Integer := 0;  -- inicia en 0 por default
   begin
      loop
         select
            when Counter > 0 =>
               accept Wait do
                  Counter := Counter - 1;
               end Wait;
         or
            accept Signal do
               Counter := Counter + 1;
            end Signal;
         or
            accept Init(Value : Integer) do
               Counter := Value;
            end Init;
         end select;
      end loop;
   end Semaforo;

   -- array de 16 semaforos
   type Semaforos_Array is array (0 .. 15) of Semaforo;
   Semaforos : Semaforos_Array;

   -- operaciones de semaforos
   procedure SEMINIT(ID : Integer; Valor : Integer) is
   begin
      Semaforos(ID).Init(Valor);
   end SEMINIT;

   procedure SEMWAIT(ID : Integer) is
   begin
      Semaforos(ID).Wait;
   end SEMWAIT;

   procedure SEMSIGNAL(ID : Integer) is
   begin
      Semaforos(ID).Signal;
   end SEMSIGNAL;

   -- memoria compartida
   type Mem_Array is array (0 .. 127) of Integer;
   Memoria : Mem_Array := (others => 0);

   -- Semaforo para memoria, usamos el semaforo de id 2
   MemSemaphoreID : constant Integer := 2;

   procedure Leer(Direccion : Integer; Valor : out Integer) is
   begin
      SEMWAIT(MemSemaphoreID);
      Valor := Memoria(Direccion);
      SEMSIGNAL(MemSemaphoreID);
   end Leer;

   procedure Escribir(Direccion : Integer; Valor : Integer) is
   begin
      SEMWAIT(MemSemaphoreID);
      Memoria(Direccion) := Valor;
      SEMSIGNAL(MemSemaphoreID);
   end Escribir;

   task type CPU is
      entry Iniciar(CPU_ID : Integer);
   end CPU;

   task body CPU is
      Ac : Integer := 0;  -- Acumulador
      IP : Integer := 0;  -- Instruction Pointer
      ID : Integer := -1; -- Id de la cpu
   begin
      accept Iniciar(CPU_ID : Integer) do
         ID := CPU_ID;
      end Iniciar;

      loop
         declare
            Instruccion : Integer;
         begin
            Leer(IP, Instruccion);

            case Instruccion is
               -- LOAD [dir]
               when 2 =>
                  declare
                     Dir, Val : Integer;
                  begin
                     Leer(IP+1, Dir); -- La direccion de memoria que hay que leer esta despues de la instruccion actual
                     Leer(Dir, Val); -- LLeemos el valor de la direccion encontrada arriba y lo asignamos a Val
                     Ac := Val; -- Asignamos el valor leido a Ac
                     IP := IP + 2; -- Aumentamos el IP acorde a las operaciones hechas
                  end;

               -- STORE [dir]
               when 3 =>
                  declare
                     Dir : Integer;
                  begin
                     Leer(IP+1, Dir); -- La direccion de memoria dada la obtenemos en la instruccion siguiente al ip. Leemos y guardamos la direccion en Dir
                     Escribir(Dir, Ac); -- Escribimos el valor del acumulador en la direccion de memoria que obtubimos arriba
                     IP := IP + 2; -- Cambiamos el ip acorde a las operaciones de la cpu
                  end;

               -- ADD [dir]
               when 4 =>
                  declare
                     Dir, Val : Integer;
                  begin
                     Leer(IP+1, Dir); -- recibimos la direccion de memoria en Dir
                     Leer(Dir, Val); -- Leemos el valor de la direccion Dir y lo guardamos en Val
                     Ac := Ac + Val; -- Sumamos Val al Acumulador
                     IP := IP + 2;
                  end;

               -- SUB [dir]
               when 5 =>
                  declare
                     Dir, Val : Integer;
                  begin
                     Leer(IP+1, Dir); -- leemos la direccion
                     Leer(Dir, Val); -- guardamos el valor que tiene esa direccion en Val
                     Ac := Ac - Val; -- Le restamos Val al Acumulador
                     IP := IP + 2;
                  end;

               -- BRCPU [CPU_ID, NewIP]
               when 6 =>
                  declare
                     CheckID, JumpPos : Integer;
                  begin
                     Leer(IP+1, CheckID); -- recibimos el id
                     Leer(IP+2, JumpPos); -- recibimos la posicion
                     if CheckID = ID then -- si el id de la cpu actual es igual al id que recibimos, saltamos al ip recibido
                        IP := JumpPos;
                     else
                        IP := IP + 3;
                     end if;
                  end;

               -- SEMWAIT [SemID]
               when 7 =>
                  declare
                     S_ID : Integer;
                  begin
                     Leer(IP+1, S_ID); -- recibimos el id del semaforo a esperar
                     SEMWAIT(S_ID); -- esperamos al semaforo de id igual al recibido
                     IP := IP + 2;
                  end;

               -- SEMSIGNAL [SemID]
               when 8 =>
                  declare
                     S_ID : Integer;
                  begin
                     Leer(IP+1, S_ID); -- recibimos el id del semaforo a realizar la señal
                     SEMSIGNAL(S_ID);
                     IP := IP + 2;
                  end;

               -- SEMINIT [SemID, Valor]
               when 9 =>
                  declare
                     S_ID, IniVal : Integer;
                  begin
                     Leer(IP+1, S_ID); -- recibimos el id del semaforo y abajo el valor inicial
                     Leer(IP+2, IniVal);
                     SEMINIT(S_ID, IniVal); -- inicializamos el semaforo de id igual al recibido con el valor inicial
                     IP := IP + 3;
                  end;

               -- OUT para imprimir el valor del acumulador
               when 10 =>
                  begin
                     Put_Line("CPU" & Integer'Image(ID) & " - Resultado: " & Integer'Image(Ac));
                     IP := IP + 1;
                  end;

               -- cualquier otra instrucción
               when others =>
                  exit;
            end case;
         end;
      end loop;
   end CPU;

   -- las dos cpu
   CPU0 : CPU;
   CPU1 : CPU;

begin
   -- Inicializamos semaforos
   SEMINIT(0, 1);
   SEMINIT(1, 1);
   SEMINIT(2, 1);  -- para la memoria

   -- Instrucciones iniciales
   -- SEMINIT(0,1)
   Escribir(0,9); -- hacemos un seminit (operacion 9)
   Escribir(1,0); -- id del semaforo 0
   Escribir(2,1); -- valor inicial 1

   -- SEMINIT(1,0)
   Escribir(3,9); -- hacemos un seminit (operacion 9)
   Escribir(4,1); -- id del semaforo 1
   Escribir(5,0); -- valor inicial 0

   -- BRCPU(0,20)
   Escribir(6,6); -- hacemos un brcpu (operacion 6). Si la cpu actual es 0, vamos al programa 20
   Escribir(7,0);
   Escribir(8,20);

   -- BRCPU(1,40)
   Escribir(9,6); -- hacemos un brcpu (operacion 6). Si la cpu actual es 1, vamos al programa 40
   Escribir(10,1);
   Escribir(11,40);




   -- codigo del cpu0. Empieza en el programa 20
   -- SEMWAIT(0)
   Escribir(20,7);
   Escribir(21,0);

   -- LOAD 100
   Escribir(22,2); -- hacemos un load (operacion 2) de lo que hay en la direccion 100 (el 8)
   Escribir(23,100);

   -- ADD 101 (sumar 13)
   Escribir(24,4); -- hacemos un add (operacion 4) de lo que hay en la direccion 101 (el 13)
   Escribir(25,101);

   -- STORE 100
   Escribir(26,3); -- guardamos el resultado en memoria
   Escribir(27,100);

   -- SEMSIGNAL(0) - Liberamos acceso
   Escribir(28,8);
   Escribir(29,0);

   -- SEMWAIT(1) esperamos que la cpu1 termine
   Escribir(30,7);
   Escribir(31,1);

   -- LOAD 100 - Cargamos el valor final
   Escribir(32,2);
   Escribir(33,100);

   -- OUT - Imprimimos
   Escribir(34,10);




   -- Codigo cpu1. Empieza en el programa 40
   -- SEMWAIT(0)
   Escribir(40,7);
   Escribir(41,0);
   -- LOAD 100
   Escribir(42,2);
   Escribir(43,100);
   -- ADD 102 (sumar 27)
   Escribir(44,4);
   Escribir(45,102);
   -- STORE 100
   Escribir(46,3);
   Escribir(47,100);
   -- SEMSIGNAL(0)
   Escribir(48,8);
   Escribir(49,0);
   -- SEMSIGNAL(1) liberar CPU0
   Escribir(50,8);
   Escribir(51,1);

   -- Datos en memoria
   Escribir(100,8);
   Escribir(101,13);
   Escribir(102,27);

   -- Iniciar CPUs
   CPU0.Iniciar(0);
   CPU1.Iniciar(1);

end Main;



-- semaforo 0 lo usamos para exclusion mutua para acceder a la direccion 100
-- semaforo 1 lo usamos para que la CPU1 espere a que la CPU0 termine
-- semaforo 2 lo usamos para exclusion mutua para la memoria
