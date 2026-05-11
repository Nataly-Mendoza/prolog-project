% Declaramos que 'completado' es dinámico para que Python pueda usar assertz/retract
:- dynamic completado/1.

% REGLA FINAL (Prioridad máxima): 
% Si ya se completó el último paso, no importa qué más haya.
que_hacer(instruccion("¡EASTER EGG COMPLETADO! El portal de escape se ha abierto.")) :- 
    completado(widows_wine), !.

% PASO 6: Requiere Electric Cherry pero NO Widow's Wine
que_hacer(instruccion("Paso 6: Código recibido. Ingresa la secuencia en la computadora principal.")) :- 
    completado(electric_cherry), 
    \+ completado(widows_wine), !.

% PASO 5: Requiere Quick Revive pero NO Electric Cherry
que_hacer(instruccion("Paso 5: Radio activada. Sobrevive a la ronda especial de perros para obtener el código.")) :- 
    completado(quick_revive), 
    \+ completado(electric_cherry), !.

% PASO 4: Requiere Stamin-Up pero NO Quick Revive
que_hacer(instruccion("Paso 4: Llave lista. Corre hacia la torre de radio antes de que termine el tiempo.")) :- 
    completado(staminup), 
    \+ completado(quick_revive), !.

% PASO 3: Requiere Speed Cola pero NO Stamin-Up
que_hacer(instruccion("Paso 3: Piezas obtenidas. Forja la llave maestra en la mesa de crafteo.")) :- 
    completado(speed_cola), 
    \+ completado(staminup), !.

% PASO 2: Requiere Juggernog pero NO Speed Cola
que_hacer(instruccion("Paso 2: La energía fluye. Recolecta 3 piezas de metal alrededor del mapa.")) :- 
    completado(juggernog), 
    \+ completado(speed_cola), !.

% PASO 1: Estado inicial (No hay nada completado)
que_hacer(instruccion("Paso 1: Activa la corriente eléctrica en el búnker.")) :- 
    \+ completado(_).