program Palapasabra;

{El programa es una implementación del juego Pasapalabra o Rosco. Conceptualmente mantiene
información de un conjunto de jugadores con la cantidad de partidas que ha ganado cada uno 
y cada partida consistirá en una contienda entre dos jugadores de los cuales uno ganará
El juego tendrá el siguiente menú de opciones:
1.Agregar un jugador.
2.Ver lista de jugadores.
3.Jugar
4.Salir}

const
    MinArreglo = 0;
    MaxArreglo = 1;

type
    Reg_Jugadores = Record
        Nombre: String[20];
        PartidasGanadas: Integer;
    end;
    Arch_Jugadores = File of Reg_Jugadores;
    
    Reg_Palabras = Record
        Nro_Set: Integer;
        Letra: Char;
        Palabra: String;
        Consigna: String;
    end;
    Arch_Palabras = File of Reg_Palabras;
    
    PuntArbol = ^NodoArbol;
    NodoArbol = Record
        Nombre: String[20];
        PartidasGanadas: Integer;
        Menores, Mayores: PuntArbol;
    end;
    
    EstadoRtas = (Pendiente, Acertada, Errada);
    
    PuntListaCircular = ^NodoLista;
    NodoLista = Record
        Letra: Char;
        Palabra: String;
        Consigna: String;
        RtaJugador: EstadoRtas;
        Sig: PuntListaCircular;
    end;
    
    Arr_Partida = Record
        Nombre: String[20];
        Rosco: PuntListaCircular;
    end;
    TArreglo = Array [MinArreglo..MaxArreglo] of Arr_Partida;
    
    
//----------INTERFAZ----------//
procedure PantallaPrincipio;
    begin
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------- BIENVENIDO -----------------------------------');
        Writeln ('-------------------------------------- A ---------------------------------------');
        Writeln ('--------------------------------- PALAPASABRA ----------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln;
    end;


//----------MODULOS DE CARGA----------//

procedure AbrirArchivo (var Jugadores_dat: Arch_Jugadores);
{Abre el archivo Jugadores_dat.}
    begin
        {$I-}
        Reset (Jugadores_dat);
        {$I+}
        if (IOResult <> 0) then
            Rewrite (Jugadores_dat);
    end;

procedure CargarArchivo (var Jugadores_dat: Arch_Jugadores);
{Se da la opción de borrar los datos del archivo y se cargan los nombres y cantidad 
de partidas ganadas (en 0) de cada jugador según lo que ingrese el usuario por teclado.}
    var
        Borrar, Nombre: String;
        Cantidad, Ingresados, Longitud: Integer;
        FicheroJugadores: Reg_Jugadores;
    
    begin
        Ingresados := 0;
        Writeln ('¿Desea borrar los jugadores previamente cargados? (Si/No)');
        Readln (Borrar);
        Borrar := LowerCase (Borrar);
        if (Borrar = 'si') then
            Rewrite (Jugadores_dat)
        else
            if (Borrar = 'no') then
                Seek (Jugadores_dat, FileSize (Jugadores_dat))
            else
                while (Borrar <> 'si') and (Borrar <> 'no') do
                    begin
                        Writeln ('Por favor ingrese Si o No');
                        Readln (Borrar);
                        Borrar := LowerCase (Borrar);
                    end;
        Writeln;
        Writeln ('¿Cuantos jugadores desea ingresar?');
        Readln (Cantidad);
        if (Cantidad < 0) then
            while (Cantidad < 0) do
                begin
                    Writeln ('Ingrese una cantidad valida');
                    Readln (Cantidad);
                end
        else
            if (Cantidad > 0) then
                Writeln ('Ingrese los datos de los jugadores');
        Writeln;
        while (Ingresados < Cantidad) do
            begin
                Writeln ('Nombre:  (Hasta 20 caracteres)');
                Readln (Nombre);
                Nombre := LowerCase (Nombre);
                Longitud := Length (Nombre);
                if (Longitud <> 0) then
                    begin
                        if (Longitud > 20) then     //solo le advierto al usuario, pero permito su agregado de todas formas
                            begin
                                Writeln ('Ingreso un nombre con mayor cantidad de caracteres,');
                                Writeln ('por lo tanto solo se tomaran los primeros 20');
                            end;
                        FicheroJugadores.Nombre := Nombre;
                        FicheroJugadores.PartidasGanadas := 0;  //al principio todos tienen 0 partidas ganadas
                        Ingresados := Ingresados + 1;
                        Write (Jugadores_dat, FicheroJugadores);
                        Writeln;
                    end
                else    //si la longitud es igual a 0, es porque se ingreso un espacio en blanco
                    begin
                        Writeln ('Nombre no valido, intente nuevamente');
                        Writeln;
                    end;
            end;
    end;

function NuevoNodoArbol (Nombre: String; PartidasGanadas: Integer): PuntArbol;
{Se crea un nuevo nodo para el árbol de Jugadores.}
    var
        NuevoNodo: PuntArbol;
        
    begin
        New (NuevoNodo);
        NuevoNodo^.Nombre := Nombre;
        NuevoNodo^.PartidasGanadas := PartidasGanadas;
        NuevoNodo^.Menores := Nil;
        NuevoNodo^.Mayores := Nil;
        NuevoNodoArbol := NuevoNodo;
    end;

procedure InsertarOrdenadoEnArbol (var Jugadores: PuntArbol; NuevoNodo: PuntArbol);
{Inserta un nodo de manera ordenada ascendente en el árbol de Jugadores.}
    begin
        if (Jugadores = Nil) then
            Jugadores := NuevoNodo
        else
            begin
                if (Jugadores^.Nombre = NuevoNodo^.Nombre) then
                    Writeln ('El jugador ya existe')
                else
                    if (Jugadores^.Nombre < NuevoNodo^.Nombre) then     //si es menor, entonces voy por mayores
                        InsertarOrdenadoEnArbol (Jugadores^.Mayores, NuevoNodo)
                    else
                        if (Jugadores^.Nombre > NuevoNodo^.Nombre) then     //si es mayor, entonces voy por menores
                            InsertarOrdenadoEnArbol (Jugadores^.Menores, NuevoNodo);
            end;
    end;

procedure CrearArbol (var Jugadores: PuntArbol; var Jugadores_dat: Arch_Jugadores);
{Crea el árbol de Jugadores a partir de los datos del archivo Jugadores_dat.}
    var
        FicheroJugadores: Reg_Jugadores;
        NuevoNodo: PuntArbol;
    
    begin
        Seek (Jugadores_dat, 0);
        while (not Eof (Jugadores_dat)) do  //recorro todo el archivo para cargar el arbol
            begin
                Read (Jugadores_dat, FicheroJugadores);
                NuevoNodo := NuevoNodoArbol (FicheroJugadores.Nombre, FicheroJugadores.PartidasGanadas);
                InsertarOrdenadoEnArbol (Jugadores, NuevoNodo);
            end;
    end;


//----------1. AGREGAR UN JUGADOR----------//

function JugadorEnArchivo (var Jugadores_dat: Arch_Jugadores; NuevoJugador: String): Integer;
{Función que me devuelve la posición del Jugador en el archivo Jugadores_dat. 
Si el Jugador no se encuentra en el archivo, devuelve -1.}
    var
        Referencia, Posicion: Integer;
        FicheroJugadores: Reg_Jugadores;
    
    begin
        Posicion := -1;
        Referencia := 0;    //variable auxiliar que va a avanzar para contar las posiciones avanzadas
        while (not Eof (Jugadores_dat)) and (Posicion = -1) do
            begin
                Seek (Jugadores_dat, Referencia);
                Read (Jugadores_dat, FicheroJugadores);
                if (FicheroJugadores.Nombre = NuevoJugador) then
                    Posicion := Referencia  //se le asigna la posicion que tiene en el archivo y llega a una de las condiciones de corte
                else
                    Referencia := Referencia + 1;   
            end;
        JugadorEnArchivo := Posicion;
    end;

procedure AgregarJugadorArchivo (var Jugadores_dat: Arch_Jugadores; JugadorAAgregar: String);
{Agrega un nuevo Jugador al final del archivo Jugadores_dat.}
    var
        NuevoJugador: Reg_Jugadores;
    
    begin
        Seek (Jugadores_dat, 0);
        if (JugadorEnArchivo (Jugadores_dat, JugadorAAgregar) = -1) then    //si el jugador no se esta en el archivo
            begin
                Seek (Jugadores_dat, FileSize (Jugadores_dat));     //me ubico al final del archivo
                NuevoJugador.Nombre := JugadorAAgregar;
                NuevoJugador.PartidasGanadas := 0;
                Write (Jugadores_dat, NuevoJugador);    //agrego el jugador al archivo
            end;
    end;

procedure AgregarJugadorArbol (var Jugadores: PuntArbol; JugadorAAgregar: String);
{Agrega un nuevo Jugador manteniendo el orden ascendente en el árbol Jugadores.}
    var
        NuevoNodo: PuntArbol;
    
    begin
        NuevoNodo := NuevoNodoArbol (JugadorAAgregar, 0);   //se va a iniciar con 0 partidas ganadas
        InsertarOrdenadoEnArbol (Jugadores, NuevoNodo);
    end;

procedure AgregarJugador (var Jugadores: PuntArbol; var Jugadores_dat: Arch_Jugadores);
{Agrega un nuevo Jugador el cual fue ingresado por teclado en el árbol Jugadores y 
en el archivo Jugadores_dat.}
    var
        JugadorAAgregar: String;
        Longitud: Integer;
    
    begin
        Writeln ('Ingrese el nombre del jugador');
        Readln (JugadorAAgregar);
        JugadorAAgregar := LowerCase (JugadorAAgregar);
        Longitud := Length (JugadorAAgregar);
        if (Longitud <> 0) then
            begin
                if (Longitud > 20) then     //solo le advierto al usuario, pero permito su agregado de todas formas
                    begin
                        Writeln ('Ingreso un nombre con mayor cantidad de caracteres,');
                        Writeln ('por lo tanto solo se tomaran los primeros 20');
                    end;
                AgregarJugadorArbol (Jugadores, JugadorAAgregar);
                AgregarJugadorArchivo (Jugadores_dat, JugadorAAgregar);
            end
        else    //si la longitud es igual a 0, es porque se ingreso un espacio en blanco
            begin
                Writeln ('Nombre no valido, intente nuevamente');
                Writeln;
            end;
    end;
    
    
//----------2. VER LISTA DE JUGADORES----------//

procedure ImprimirArbolJugadores (Jugadores: PuntArbol);
{A partir del recorrido in-order del árbol Jugadores, muestra todos los 
existentes con la cantidad de partidas ganadas por cada uno.}
    begin
        if (Jugadores <> Nil) then
            begin
                ImprimirArbolJugadores (Jugadores^.Menores);    //imprimo primero los menores
                Writeln ('Jugador: ', Jugadores^.Nombre, ' | ', 'Partidas ganadas: ', Jugadores^.PartidasGanadas);
                ImprimirArbolJugadores (Jugadores^.Mayores);    //luego imprimo los mayores (in order ascendente)
            end;
    end;

procedure MostrarListaJugadores (Jugadores: PuntArbol);
{Verifica que el árbol tenga Jugadores para mostrar. Si los tiene, imprime el 
árbol Jugadores, si no muestra un mensaje por pantalla al usuario.}
    begin
        if (Jugadores <> Nil) then
            ImprimirArbolJugadores (Jugadores)
        else
            Writeln ('No hay jugadores para mostrar');
    end;


//----------3. JUGAR----------//

function JugadorEnArbol (Jugadores: PuntArbol; NuevoJugador: String): PuntArbol;
{Función que devuelve un puntero apuntando al nodo que contiene el nombre del Jugador 
en el árbol Jugadores. Si el Jugador no existe en el árbol, devuelve Nil.}
    begin
        if (Jugadores = Nil) then
            JugadorEnArbol := Nil   //no se encontro el jugador
        else
            if (Jugadores^.Nombre = NuevoJugador) then
                JugadorEnArbol := Jugadores
            else
                if (Jugadores^.Nombre < NuevoJugador) then
                    JugadorEnArbol := JugadorEnArbol (Jugadores^.Mayores, NuevoJugador)     //si es menor, voy por mayores
                else
                    JugadorEnArbol := JugadorEnArbol (Jugadores^.Menores, NuevoJugador);    //si es mayor, voy por menores
    end;

procedure ControlJugadores (Jugadores: PuntArbol; var Jugador1, Jugador2: String);
{Verifica que los dos Jugadores que se le pasan por parámetro existan en el árbol 
Jugadores y que sean distintos entre ellos. Si alguno de ellos debe ser cambiado 
por lo mencionado anteriormente, se devuelve modificado.}
    begin
        if (JugadorEnArbol (Jugadores, Jugador1) = Nil) then    //si no esta en el arbol
            while (JugadorEnArbol (Jugadores, Jugador1) = Nil) do
                begin
                    Writeln ('El primer jugador que ingresó no existe');
                    Writeln ('Ingrese el nombre del primer jugador: ');
                    Readln (Jugador1);
                    Jugador1 := LowerCase (Jugador1);
                    Writeln;
                end;
        if (JugadorEnArbol (Jugadores, Jugador2) = Nil) then    //si no esta en el arbol
            while (JugadorEnArbol (Jugadores, Jugador2) = Nil) do
                begin
                    Writeln ('El segundo jugador que ingresó no existe');
                    Writeln ('Ingrese el nombre del segundo jugador: ');
                    Readln (Jugador2);
                    Jugador2 := LowerCase (Jugador2);
                    Writeln;
                end;
        if (Jugador1 = Jugador2) then
            while (Jugador1 = Jugador2) do
                begin
                    Writeln ('Ingresó dos veces el mismo jugador');
                    Writeln ('Ingrese otro nombre: ');
                    Readln (Jugador2);
                    Jugador2 := LowerCase (Jugador2);
                    while (JugadorEnArbol (Jugadores, Jugador2) = Nil) do
                        begin
                            Writeln ('El segundo jugador que ingresó no existe');
                            Writeln ('Ingrese el nombre del segundo jugador: ');
                            Readln (Jugador2);
                            Jugador2 := LowerCase (Jugador2);
                            Writeln;
                        end;
                    Writeln;
                end;
    end;

function NuevoNodoRosco (FicheroPalabras: Reg_Palabras): PuntListaCircular;
{Se crea un nuevo nodo para la lista circular Rosco.}
    var
        NuevoNodo: PuntListaCircular;
        
    begin
        New (NuevoNodo);
        NuevoNodo^.Letra := FicheroPalabras.Letra;
        NuevoNodo^.Palabra := FicheroPalabras.Palabra;
        NuevoNodo^.Consigna := FicheroPalabras.Consigna;
        NuevoNodo^.RtaJugador := Pendiente;     //al principio, todas las preguntas van a estar como pendientes
        NuevoNodo^.Sig := Nil;
        NuevoNodoRosco := NuevoNodo;
    end;

function Posicion (var Palabras_dat: Arch_Palabras; Nro_Set: Integer): Integer;
{Función que devuelve la posición en la que se encuentra un número de 
set en el archivo Palabras_dat.}
    var
        Pos: Integer;
        FicheroPalabras: Reg_Palabras;
    
    begin
        Pos := 0;
        Seek (Palabras_dat, 0);
        Read (Palabras_dat, FicheroPalabras);
        while (not Eof (Palabras_dat)) and (FicheroPalabras.Nro_Set <> Nro_Set) do  //hasta que no llegue al nro_set que deseo llegar, avanzo
            begin
                Read (Palabras_dat, FicheroPalabras);
                Pos := Pos + 1;
            end;
        Posicion := Pos;
    end;
        
procedure CargarRosco (var Rosco: PuntListaCircular; var Palabras_dat: Arch_Palabras; Nro_Set: Integer);
{Crea la lista circular Rosco con los datos del archivo Palabras_dat.}
    var
        NuevoNodo: PuntListaCircular;
        FicheroPalabras: Reg_Palabras;
        Cortar: Boolean;
    
    begin
        Cortar := False;
        NuevoNodo := Nil;
        Seek (Palabras_dat, Posicion (Palabras_dat, Nro_Set));  //me posiciono donde arranca el nro_set que voy a usar
        Read (Palabras_dat, FicheroPalabras);
        Rosco := NuevoNodoRosco (FicheroPalabras);  //creo el primer nodo
        NuevoNodo := Rosco;
        while (not Eof (Palabras_dat)) and (not Cortar) do
            begin
                Read (Palabras_dat, FicheroPalabras);
                if (FicheroPalabras.Nro_Set = Nro_Set) then
                    begin
                        NuevoNodo^.Sig := NuevoNodoRosco (FicheroPalabras);     //creo los nodos que siguen hasta completar el set
                        NuevoNodo := NuevoNodo^.Sig;
                    end
                else
                    Cortar := True;     //corto cuando se llega a un numero de set distinto al que estoy
            end;
        NuevoNodo^.Sig := Rosco;    //cierro la lista para que se vuelva una lista circular
    end;
    
procedure CargarArregloPartida (var Partida: TArreglo; Jugador1, Jugador2: String);
{Le asigna a los dos elementos del arreglo Partida el nombre de un jugador y una lista circular 
Rosco. Los Rosco se asignan a partir de los números de set que deben ser distintos.}
    var
        Nro_Set, Nro_Set_Utilizado: Integer;
        Palabras_dat: Arch_Palabras;
    
    begin
        Randomize;
        Assign (Palabras_dat, '/ip2/palabras.dat');
        Reset (Palabras_dat);
        Partida[MinArreglo].Nombre := Jugador1;     //asigno al primer elemento del arreglo, el nombre del Jugador1
        Partida[MaxArreglo].Nombre := Jugador2;     //asigno al segundo elemento del arreglo, el nombre del Jugador2
        Nro_Set := Random (5) + 1;      //quiero obtener un valor aleatorio de set
        CargarRosco (Partida[MinArreglo].Rosco, Palabras_dat, Nro_Set);     //cargo el rosco del primer jugador
        Nro_Set_Utilizado := Nro_Set;
        Nro_Set := Random (5) + 1;
        if (Nro_Set = Nro_Set_Utilizado) then   //verifico que los nro de set no sean iguales
            while (Nro_Set = Nro_Set_Utilizado) do
                Nro_Set := Random (5) + 1;
        CargarRosco (Partida[MaxArreglo].Rosco, Palabras_dat, Nro_Set);     //cargo el rosco del segundo jugador
        Close (Palabras_dat);
    end;

function PreguntaPendiente (Rosco: PuntListaCircular): PuntListaCircular;
{Función que devuelve un puntero apuntando hacia la próxima pregunta pendiente que tiene el 
Rosco pasado por parámetro. Si no encuentra ninguna pregunta pendiente, devuelve Nil.}
    var
        Inicio: Char;
        Cortar: Boolean;
    
    begin
        Cortar := False;
        if (Rosco^.RtaJugador = Pendiente) then
            Cortar := True
        else
            begin
                Inicio := Rosco^.Letra;     //fijo un inicio para saber cuando termine de recorrer toda la lista
                Rosco := Rosco^.Sig;
                while (Rosco^.Letra <> Inicio) and (not Cortar) do
                    begin
                        if (Rosco^.RtaJugador = Pendiente) then     //si encuentro la proxima pregunta pendiente, corto
                            Cortar := True
                        else
                            Rosco := Rosco^.Sig;    //si no avanzo
                    end;
            end;
        if (Cortar) then    //si encontre una pregunta pendiente, le asigno el puntero
            PreguntaPendiente := Rosco
        else    //si no encontre pregunta pendiente, ya se completaron todas
            PreguntaPendiente := Nil;
    end;

procedure JugarTurno (var Rosco: PuntListaCircular; var CantRtas: Integer);
{Muestra la Letra, la Consigna y se queda esperando el ingreso de la respuesta del jugador. 
Si el jugador responde “pp”, queda la palabra como Pendiente y se termina el turno de ese jugador. 
De lo contrario, se compara el texto ingresado con la palabra buscada. Si es igual, significa Acertada 
y continúa jugando ese jugador. Si es distinta, significa Errada y termina su turno.}
    var
        Rta: String;
        
    begin
        Writeln;
        if (Rosco <> Nil) then  //es necesario preguntar si es distinto de Nil por el caso de que se le asigne Nil por la funcion PreguntaPendiente
            begin
                Writeln (Rosco^.Letra, ': ', Rosco^.Consigna);
                Readln (Rta);
                Rta := LowerCase (Rta);
                if (Rta <> 'pp') then
                    if (Rta = Rosco^.Palabra) then
                        begin
                            Rosco^.RtaJugador := Acertada;
                            CantRtas := CantRtas + 1;
                            Rosco := PreguntaPendiente (Rosco^.Sig);    //avanzo el puntero a la siguiente pregunta pendiente
                            JugarTurno (Rosco, CantRtas);   //vuelve a jugar el mismo jugador
                        end
                    else
                        begin
                            Rosco^.RtaJugador := Errada;
                            Rosco := PreguntaPendiente (Rosco^.Sig);    //avanzo el puntero a la siguiente pregunta pendiente
                        end
                else    //si contesto pasapalabra, avanzo el puntero a la siguiente pregunta pendiente
                    Rosco := PreguntaPendiente (Rosco^.Sig);
            end;
    end;
    
procedure ActualizarPartidasGanadas (var Jugadores: PuntArbol; var Jugadores_dat: Arch_Jugadores; Jugador: String);
{Actualiza la cantidad de Partidas Ganadas del Jugador pasado como parámetro tanto en el archivo 
Jugadores_dat como en el árbol Jugadores.}
    var
        GanadorArbol: PuntArbol;
        GanadorArchivo: Integer;
        FicheroJugadores: Reg_Jugadores;
    
    begin
        Writeln ('Felicitaciones ', Jugador, '!', ' Ganaste la partida!');
        GanadorArbol := JugadorEnArbol (Jugadores, Jugador);    //busco el nombre del jugador en el arbol
        GanadorArbol^.PartidasGanadas := GanadorArbol^.PartidasGanadas + 1;
        GanadorArchivo := JugadorEnArchivo (Jugadores_dat, Jugador);    //busco la posicion del jugador en el archivo
        Seek (Jugadores_dat, GanadorArchivo);   //me ubico en la posicion buscada
        Read (Jugadores_dat, FicheroJugadores);
        FicheroJugadores.PartidasGanadas := FicheroJugadores.PartidasGanadas + 1;
        Seek (Jugadores_dat, FilePos (Jugadores_dat) - 1);  //como el read me avanzo una posicion, me posiciono en la anterior
        Write (Jugadores_dat, FicheroJugadores);    
    end;

procedure Jugar (var Jugadores: PuntArbol; var Jugadores_dat: Arch_Jugadores);
{Permite el desarrollo de la partida. El usuario ingresa dos nombres de los Jugadores con los 
cuales se llevará a cabo el proceso, se cargan sus respectivos arreglos Partida con el nombre 
de cada uno y su lista circular Rosco. Luego se alternan los turnos entre los Jugadores. La 
partida finaliza cuando uno de los Jugadores se queda sin Preguntas Pendientes. Finalmente 
se actualizan la Cantidad de Partidas Ganadas del Jugador vencedor, si es que hubo uno.}
    var
        Jugador1, Jugador2: String;
        Partida: TArreglo;
        CantRtas1, CantRtas2: Integer;

    begin
        Seek (Jugadores_dat, 0);
        if (FileSize (Jugadores_dat) < 2) then  //verifico que haya suficiente cantidad de jugadores cargados en el arbol para poder jugar
            begin
                Writeln ('No es posible jugar porque no hay suficiente jugadores cargados');
                Writeln ('Por favor agregue jugadores y vuelva a intentarlo');
            end
        else
            begin
                Writeln ('Ingrese el nombre del primer jugador: ');
                Readln (Jugador1);
                Jugador1 := LowerCase (Jugador1);
                Writeln;
                Writeln ('Ingrese el nombre del segundo jugador: ');
                Readln (Jugador2);
                Jugador2 := LowerCase (Jugador2);
                Writeln;
                ControlJugadores (Jugadores, Jugador1, Jugador2);
                CargarArregloPartida (Partida, Jugador1, Jugador2);
                CantRtas1 := 0;
                CantRtas2 := 0;
                Writeln;
                while (Partida[MinArreglo].Rosco <> Nil) and (Partida[MaxArreglo].Rosco <> Nil) do  //cuando sea Nil, va a ser por la asignacion de la funcion PreguntaPendiente
                    begin                                                                           //que se le hizo en JugarTurno, es decir, corta cuando no tiene Preguntas Pendientes
                        Writeln (Jugador1, ', es tu turno');
                        JugarTurno (Partida[MinArreglo].Rosco, CantRtas1);
                        Writeln;
                        Writeln (Jugador2, ', es tu turno');
                        JugarTurno (Partida[MaxArreglo].Rosco, CantRtas2);
                        Writeln;
                    end;
                Writeln (Jugador1, ': tuviste ', CantRtas1, ' respuestas correctas');
                Writeln;
                Writeln (Jugador2, ': tuviste ', CantRtas2, ' respuestas correctas');
                Writeln;
                if (CantRtas1 > CantRtas2) then
                    ActualizarPartidasGanadas (Jugadores, Jugadores_dat, Jugador1)
                else
                    if (CantRtas2 > CantRtas1) then
                        ActualizarPartidasGanadas (Jugadores, Jugadores_dat, Jugador2)
                    else
                        Writeln ('Hubo un empate');
            end;
    end;


//----------4. SALIR DEL JUEGO----------//

procedure SalirDelJuego (var Salir: Boolean);
{Permite salir del juego a través de la modificación de una variable booleana.}
    begin
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('------------------------------------- FIN --------------------------------------');
        Writeln ('------------------------------------- DEL --------------------------------------');
        Writeln ('------------------------------------ JUEGO -------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Writeln ('--------------------------------------------------------------------------------');
        Salir := True;
    end;


//----------MENU----------//
    
function MenuDelJuego: ShortString;
    var
        Opcion: String[1];
    
    begin
        Writeln;
        Writeln ('-------MENU PRINCIPAL-------');
        Writeln;
        Writeln ('(1) Agregar un jugador');
        Writeln ('(2) Ver lista de jugadores');
        Writeln ('(3) Jugar');
        Writeln ('(4) Salir');
        Writeln;
        Readln (Opcion);
        Writeln;
        MenuDelJuego := Opcion;
    end;
    
    
//----------PROGRAMA PRINCIPAL----------//
var
   Jugadores_dat: Arch_Jugadores;
   Jugadores: PuntArbol;
   Salir: Boolean;
   
begin
    Salir := False;
    PantallaPrincipio;
    Assign (Jugadores_dat, '/ip2/XimenaElgart-250130-Jugadores.dat');
    AbrirArchivo (Jugadores_dat);
    CargarArchivo (Jugadores_dat);
    CrearArbol (Jugadores, Jugadores_dat);
    while (not Salir) do
        Case MenuDelJuego of
            '1': AgregarJugador (Jugadores, Jugadores_dat);
            '2': MostrarListaJugadores (Jugadores);
            '3': Jugar (Jugadores, Jugadores_dat);
            '4': SalirDelJuego (Salir);
        end;
    Close (Jugadores_dat);
end.