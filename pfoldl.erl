-module(pfoldl).
-export([pfoldl/4]).

%% Test functions
-export([test/3, test_foldl/2, test_pfoldl/3]).

pfoldl(Fun, Acc0, List, SplitVal) ->
  divide_and_conquer(Fun, Acc0, List, SplitVal).

divide_and_conquer(Fun, Acc0, List, SplitVal) ->
  DivideList = split_equal_fast(List, SplitVal),
  conquer(Fun, Acc0, DivideList).

conquer(Fun, Acc0, List) ->
  Parent = self(),
  %% Start the child processes
  FunC = fun(X, Acc) ->
    [start_child(Parent, Fun, X)] ++ Acc
  end,
  ChildList = lists:foldl(FunC, [], List),
  %% Loop through the child and collect the results.
  ResultAccFn = fun(P, ResultAcc) ->
    get_result_from(P) ++ ResultAcc
  end,
  ResultList = lists:foldl(ResultAccFn, Acc0, lists:reverse(ChildList)),
  lists:reverse(ResultList).

%% Start Child process & Execute the fn & Send the result back to Parent.
start_child(Parent, Fun, List) ->
  SpawnFn = fun() ->
    FinalRes = lists:foldl(Fun, [], List),
    Parent ! {self(), FinalRes}
  end,
  erlang:spawn(SpawnFn).

%% Retrieve the result from child process.
get_result_from(Child) ->
  receive
    {Child, Result} ->
      Result;
     _ ->
      []
    end.

split_equal_fast(List, Size) ->
  split_equal_fast(List, Size, []).

split_equal_fast([], _, Acc) ->
  %% to preserve order
  lists:reverse(Acc);

split_equal_fast(List, Size, Acc) ->
  {SplitHead, SplitRest} = split(Size, List),
  split_equal_fast(SplitRest, Size, [SplitHead] ++ Acc).

split(Size, List) ->
  split(Size, List, []).

split(_, [], Acc) ->
  {lists:reverse(Acc), []};

split(0, Rest, Acc) ->
  {lists:reverse(Acc), Rest};

split(Size, [H|R], Acc) ->
  split(Size -1, R, [H] ++ Acc).


%%% Test functions
test(Count, SplitCount, TimerVal) ->
  L = lists:seq(1, Count),
  test_foldl(L, TimerVal),
  test_pfoldl(L, SplitCount, TimerVal).

test_foldl(List, TimerVal) ->
  TimeStart = get_current_time_in_ms(),
  Fun = fun(_X, Acc) ->
    do_some_work(_X, TimerVal) ++ Acc
  end,
  _FinalVal = lists:reverse(lists:foldl(Fun, [], List)),
  TimeEnd = get_current_time_in_ms(),
  TimeDiff = TimeEnd - TimeStart,
  io:format("Foldl: TimeDiff in milliSec: ~p~n", [TimeDiff]).

test_pfoldl(List, SplitCount, TimerVal) ->
  TimeStart = get_current_time_in_ms(),
  Fun = fun(_X, Acc) ->
    do_some_work(_X, TimerVal) ++ Acc
  end,
  _FinalVal = pfoldl(Fun, [], List, SplitCount),
  TimeEnd = get_current_time_in_ms(),
  TimeDiff = TimeEnd - TimeStart,
  io:format("pfoldl: TimeDiff in milliSec: ~p~n", [TimeDiff]).

do_some_work(Val, TimerVal) ->
  timer:sleep(TimerVal),
  [Val].

get_current_time_in_ms () ->
  {Mega, Sec, Micro} = os:timestamp(),
  (Mega*1000000 + Sec)*1000 + round(Micro/1000).



