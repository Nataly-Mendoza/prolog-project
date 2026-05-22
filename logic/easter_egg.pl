:- dynamic completado/1.

% COMPLETADO: los 6 perks en orden correcto
que_hacer(instruccion("¡EASTER EGG COMPLETADO! El portal de escape se ha abierto.")) :-
    completado(juggernog),
    completado(speed_cola),
    completado(staminup),
    completado(quick_revive),
    completado(electric_cherry),
    completado(widows_wine), !.

% PASO 6: los primeros 5 correctos, falta Widow's Wine
que_hacer(instruccion("Paso 6: Codigo recibido. Ingresa la secuencia en la computadora principal.")) :-
    completado(juggernog),
    completado(speed_cola),
    completado(staminup),
    completado(quick_revive),
    completado(electric_cherry),
    \+ completado(widows_wine), !.

% PASO 5: los primeros 4 correctos, falta Electric Cherry
que_hacer(instruccion("Paso 5: Radio activada. Sobrevive la ronda especial de perros para obtener el codigo.")) :-
    completado(juggernog),
    completado(speed_cola),
    completado(staminup),
    completado(quick_revive),
    \+ completado(electric_cherry), !.

% PASO 4: los primeros 3 correctos, falta Quick Revive
que_hacer(instruccion("Paso 4: Llave lista. Corre hacia la torre de radio antes de que termine el tiempo.")) :-
    completado(juggernog),
    completado(speed_cola),
    completado(staminup),
    \+ completado(quick_revive), !.

% PASO 3: los primeros 2 correctos, falta Stamin-Up
que_hacer(instruccion("Paso 3: Piezas obtenidas. Forja la llave maestra en la mesa de crafteo.")) :-
    completado(juggernog),
    completado(speed_cola),
    \+ completado(staminup), !.

% PASO 2: solo Juggernog, falta Speed Cola
que_hacer(instruccion("Paso 2: La energia fluye. Recolecta 3 piezas de metal alrededor del mapa.")) :-
    completado(juggernog),
    \+ completado(speed_cola), !.

% PASO 1: nadie completado aun
que_hacer(instruccion("Paso 1: Activa la corriente electrica en el bunker.")) :-
    \+ completado(_), !.

% ORDEN INCORRECTO: tiene algo pero no en el orden correcto
que_hacer(instruccion("¡Orden incorrecto! Deshaz los perks y sigue el orden: Juggernog -> Speed Cola -> Stamin-Up -> Quick Revive -> Electric Cherry -> Widow's Wine.")).
