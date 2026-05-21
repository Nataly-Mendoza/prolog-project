:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).

:- consult('easter_egg.pl').

:- http_handler('/que_hacer',  handler_que_hacer,  []).
:- http_handler('/completar',  handler_completar,  []).
:- http_handler('/retroceder', handler_retroceder, []).

handler_que_hacer(_Request) :-
    ( que_hacer(instruccion(X)) -> true ; X = "Paso 1: Activa la corriente electrica." ),
    format("Content-type: text/plain; charset=utf-8~n~n~w", [X]).

handler_completar(Request) :-
    http_parameters(Request, [item(Item, [atom])]),
    ( completado(Item) -> true ; assertz(completado(Item)) ),
    ( que_hacer(instruccion(X)) -> true ; X = "Easter Egg completado!" ),
    format("Content-type: text/plain; charset=utf-8~n~n~w", [X]).

handler_retroceder(Request) :-
    http_parameters(Request, [item(Item, [atom])]),
    ( retract(completado(Item)) -> true ; true ),
    ( que_hacer(instruccion(X)) -> true ; X = "Regresando al inicio..." ),
    format("Content-type: text/plain; charset=utf-8~n~n~w", [X]).

:- initialization(
    http_server(http_dispatch, [port(8000)]),
    main
).
