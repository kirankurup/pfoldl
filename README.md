# pfoldl
Parallel version of lists:foldl

## Background
Many a time one will be performing actions on a list of items, using foldl, which eventually performs the action in a serial manner, thereby maintaining the order of elements in the original list. Say, for example a series of db reads on a list of time ordered Key list, to retrieve respective values in the same order as Keys are..  
What if, if you can achieve the same order by letting a group of processes acting on a different sublist (part of the original list), there by reducing the actual execution time. Good isn't it.

### Exported Functions
1. pfoldl  
   Takes 4 arguments, First 3 are same as lists:foldl. 4th argument being the Split Size Count. Original list will be divided into sublists each containing "SplitCount" elements.

### Run
Erlang/OTP 19 [erts-8.1] [source] [64-bit] [async-threads:10] [kernel-poll:false]

Eshell V8.1  (abort with ^G)  
1> c(pfoldl).  
{ok,pfoldl}  
2> pfoldl:test(10000, 100, 2).  
Foldl: TimeDiff in milliSec: 30294  
pfoldl: TimeDiff in milliSec: 303  
ok  

** Test Arguments **  
1st Arg -> Number of elements in the list.  
2nd Arg -> Split Count, number of elements in each sublist. (used in pfoldl)  
3rd Arg -> Sleep timer val. There is a sample function, which just sleeps for this time period  


