with Ada.Text_IO; use Ada.Text_IO;

procedure Main is

   ----------------------------------------------------------------
   -- Definición del tipo de tarea Semáforo y su cuerpo
   ----------------------------------------------------------------
   task type Semaforo is
      entry Wait;
      entry Signal;
      entry Init(Value : Integer);
   end Semaforo;

   task body Semaforo is
      Counter : Integer := 0;  -- Semáforo inicia en 0 por defecto
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

   ----------------------------------------------------------------
   -- Arreglo global de 16 semáforos
   ----------------------------------------------------------------
   type Semaforos_Array is array (0 .. 15) of Semaforo;
   Semaforos : Semaforos_Array;

   -- Operaciones sobre semáforos
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

   ----------------------------------------------------------------
   -- Módulo Memoria Compartida como secciones declarativas
   -- Usamos semáforos para exclusión mutua
   ----------------------------------------------------------------
   type Mem_Array is array (0 .. 127) of Integer;
   Memoria : Mem_Array := (others => 0);

   -- Semáforo para memoria (por ejemplo, el #2)
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

   ----------------------------------------------------------------
   -- Definición de la CPU como tarea tipo
   ----------------------------------------------------------------
   task type CPU is
      entry Iniciar(CPU_ID : Integer);
   end CPU;

   task body CPU is
      Ac : Integer := 0;  -- Acumulador
      IP : Integer := 0;  -- Instruction Pointer
      ID : Integer := -1; -- Identificador de la CPU
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
                     Leer(IP+1, Dir);
                     Leer(Dir, Val);
                     Ac := Val;
                     IP := IP + 2;
                  end;

               -- STORE [dir]
               when 3 =>
                  declare
                     Dir : Integer;
                  begin
                     Leer(IP+1, Dir);
                     Escribir(Dir, Ac);
                     IP := IP + 2;
                  end;

               -- ADD [dir]
               when 4 =>
                  declare
                     Dir, Val : Integer;
                  begin
                     Leer(IP+1, Dir);
                     Leer(Dir, Val);
                     Ac := Ac + Val;
                     IP := IP + 2;
                  end;

               -- SUB [dir]
               when 5 =>
                  declare
                     Dir, Val : Integer;
                  begin
                     Leer(IP+1, Dir);
                     Leer(Dir, Val);
                     Ac := Ac - Val;
                     IP := IP + 2;
                  end;

               -- BRCPU [CPU_ID, NewIP]
               when 6 =>
                  declare
                     CheckID, JumpPos : Integer;
                  begin
                     Leer(IP+1, CheckID);
                     Leer(IP+2, JumpPos);
                     if CheckID = ID then
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
                     Leer(IP+1, S_ID);
                     SEMWAIT(S_ID);
                     IP := IP + 2;
                  end;

               -- SEMSIGNAL [SemID]
               when 8 =>
                  declare
                     S_ID : Integer;
                  begin
                     Leer(IP+1, S_ID);
                     SEMSIGNAL(S_ID);
                     IP := IP + 2;
                  end;

               -- SEMINIT [SemID, Valor]
               when 9 =>
                  declare
                     S_ID, IniVal : Integer;
                  begin
                     Leer(IP+1, S_ID);
                     Leer(IP+2, IniVal);
                     SEMINIT(S_ID, IniVal);
                     IP := IP + 3;
                  end;

               -- OUT (imprimir valor Ac)
               when 10 =>
                  begin
                     Put_Line("CPU" & Integer'Image(ID) & " - Resultado: " & Integer'Image(Ac));
                     IP := IP + 1;
                  end;

               -- HALT u otra instrucción no reconocida
               when others =>
                  exit;
            end case;
         end;
      end loop;
   end CPU;

   ----------------------------------------------------------------
   -- Instancias de CPU
   ----------------------------------------------------------------
   CPU0 : CPU;
   CPU1 : CPU;

begin
   -- Inicializar semáforos
   SEMINIT(0, 1);
   SEMINIT(1, 1);
   SEMINIT(2, 1);  -- para la memoria

   -- Cargamos las instrucciones y datos en memoria
   -- Instrucciones iniciales
   -- SEMINIT(0,1)
   Escribir(0,9);
   Escribir(1,0);
   Escribir(2,1);

   -- SEMINIT(1,0)
   Escribir(3,9);
   Escribir(4,1);
   Escribir(5,0);

   -- BRCPU(0,20)
   Escribir(6,6);
   Escribir(7,0);
   Escribir(8,20);

   -- BRCPU(1,40)
   Escribir(9,6);
   Escribir(10,1);
   Escribir(11,40);

   -- Código CPU0 (inicio en 20):
   -- SEMWAIT(0)
   Escribir(20,7);
   Escribir(21,0);
   -- LOAD 100
   Escribir(22,2);
   Escribir(23,100);
   -- ADD 101 (sumar 13)
   Escribir(24,4);
   Escribir(25,101);
   -- STORE 100
   Escribir(26,3);
   Escribir(27,100);
   -- SEMSIGNAL(0)
   Escribir(28,8);
   Escribir(29,0);
   -- SEMWAIT(1) espera que CPU1 termine
   Escribir(30,7);
   Escribir(31,1);
   -- LOAD 100
   Escribir(32,2);
   Escribir(33,100);
   -- OUT
   Escribir(34,10);

   -- Código CPU1 (inicio en 40):
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

   -- Al llegar aquí, las CPUs se ejecutan en paralelo.
   -- El programa termina cuando ambas CPUs finalicen su ejecución (cuando topen con un others => exit;).
end Main;