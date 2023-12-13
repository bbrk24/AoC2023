:- module day12star1.

:- interface.

:- pred f(string::in, int::out) is semidet.

:- implementation.

:- import_module list.
:- import_module string.
:- import_module int.

:- pred separate_last(list(T)::in, list(T)::out, T::out) is semidet.

separate_last([X|Xs], Init, Last) :-
    ( Xs = [] ->
        Last = X,
        Init = []
    ;
        separate_last(Xs, Rest, Last),
        Init = [X|Rest]
    ).

:- pred begin_appropriate(string::in, list(int)::in, int::out) is semidet.
:- pred end_appropriate(string::in, list(int)::in, int::out) is semidet.
:- pred count_solutions(string::in, list(int)::in, int::out) is semidet.

begin_appropriate(Str, [First|Rest], SolCount) :-
    % Get a substring of length First and ensure it has no dots
    length(Str, Length),
    Length >= First,
    between(Str, 0, First, BeginStr),
    \+ contains_char(BeginStr, '.'),
    % Remove the first bit
    remove_prefix(BeginStr, Str, EndStr),
    \+ prefix(EndStr, "#"),
    % If EndStr starts with a question mark, shave that off too
    ( remove_prefix("?", EndStr, TrueEndStr) ->
        count_solutions(TrueEndStr, Rest, SolCount)
    ;
        count_solutions(EndStr, Rest, SolCount)
    ).

% Str = "###????"
% Nums = [3]
end_appropriate(Str, Nums, SolCount) :-
    separate_last(Nums, Init, Last),
    % Get a substring of length Last and ensure it has no dots
    length(Str, Length),
    StartIndex is Length - Last,
    StartIndex >= 0,
    between(Str, StartIndex, Length, EndStr),
    \+ contains_char(EndStr, '.'),
    % Remove the last bit
    remove_suffix(Str, EndStr, BeginStr),
    \+ suffix(BeginStr, "#"),
    % If BeginStr ends with a question mark, shave that off too
    ( remove_suffix(BeginStr, "?", TrueBeginStr) ->
        count_solutions(TrueBeginStr, Init, SolCount)
    ;
        count_solutions(BeginStr, Init, SolCount)
    ).

count_solutions(Str, Nums, SolCount) :-
    ( Nums = [] ->
        \+ contains_char(Str, '#'),
        SolCount is 1
    ; remove_prefix(".", Str, NewStr) ->
        count_solutions(NewStr, Nums, SolCount)
    ; remove_suffix(Str, ".", NewStr) ->
        count_solutions(NewStr, Nums, SolCount)
    ; remove_prefix("?", Str, NewStr) ->
        ( begin_appropriate(Str, Nums, NotRemovedCount) ->
            ( count_solutions(NewStr, Nums, RemovedCount) ->
                SolCount is RemovedCount + NotRemovedCount
            ;
                SolCount is NotRemovedCount
            )
        ;
            count_solutions(NewStr, Nums, SolCount)
        )
    ; remove_suffix(Str, "?", NewStr) ->
        ( end_appropriate(Str, Nums, NotRemovedCount) ->
            ( count_solutions(NewStr, Nums, RemovedCount) ->
                SolCount is RemovedCount + NotRemovedCount
            ;
                SolCount is NotRemovedCount
            )
        ;
            count_solutions(NewStr, Nums, SolCount)
        )   
    ; begin_appropriate(Str, Nums, X) ->
        SolCount is X
    ;
        end_appropriate(Str, Nums, X),
        SolCount is X
    ).

:- pred strs_to_nums(list(string)::in, list(int)::out) is semidet.

strs_to_nums([], []).
strs_to_nums([X|Xs], [First|Rest]) :-
    to_int(X, First),
    strs_to_nums(Xs, Rest).

:- pred process_row(string::in, int::out) is semidet.
:- pred process_list(list(string)::in, int::out) is semidet.

process_row(Str, Num) :-
    [Row, UnprocessedNums] = split_at_string(" ", Str),
    NumStrList = split_at_string(",", UnprocessedNums),
    strs_to_nums(NumStrList, Nums),
    count_solutions(Row, Nums, Num).

process_list([], 0).
process_list([X|Xs], Num) :-
    process_row(X, First),
    process_list(Xs, Others),
    Num is First + Others.

f(Str, Num) :-
    List = split_at_string("\n", Str),
    process_list(List, Num).