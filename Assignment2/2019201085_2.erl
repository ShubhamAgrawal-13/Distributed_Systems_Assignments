-module ('2019201085_2').
-export ([main/1]).
-define(Inf, 9999999).
-import(lists,[min/1]).

read_edges(_, 0, _) -> [];
read_edges(M, M, IFile) -> 
	{ok, Edge} = io:fread(IFile, "", "~d~d~d"),
	[Edge];
	% io:fwrite("Hello ~p ~p\n", [M, M]),

read_edges(I, M, IFile) when I < M ->
	{ok, Edge} = io:fread(IFile, "", "~d~d~d"),
	% io:fwrite("Hello ~p ~p\n", [I, M]),
	List1 = read_edges(I+1, M, IFile),
	[Edge] ++ List1.


% relax(List, Dist)-> 
% 	lists:foreach(fun([U, V, W]) -> Dist[V] = Dist[U] + W  end, List).

% bellmann(N, N, List, Dist) ->
% 	relax(List, Dist).
% bellmann(I, N, List) ->
% 	Dist1 = bellmann(I+1, N, List, Dist),
% 	relax(List, Dist1).

add_row(_, Row, []) -> Row;
add_row(U1, Row, [[U, V, W]|T]) ->
	if 
      U1 == U -> 
        Row1 = maps:put(V, W, Row); 
      true -> 
        Row1 = Row
    end,
    if 
      U1 == V -> 
        Row2 = maps:put(U, W, Row1); 
      true -> 
        Row2 = Row1 
    end,
	add_row(U1, Row2, T).

create_graph(0, Graph, _) -> Graph;
create_graph(I, Graph, List) -> 
	Row = #{},
	Graph1 = maps:put(I, add_row(I, Row, List), Graph),
	create_graph(I-1, Graph1, List).

split_graph(1, _, Graph2) -> [Graph2];
split_graph(P, Size, Graph2) ->
	List2 = lists:split(Size, Graph2),
	% io:format("~p\n", [element(1, List2)]),
	[element(1, List2)] ++ split_graph(P-1, Size, element(2, List2)).


do_calculation([], _, _, _, List1) -> List1;

do_calculation([H | T], List, S, D, List1) -> 
	U = element(1, H),
	W = element(2, H),
	Temp = maps:is_key(U, List),
	if 
		Temp==true ->
			Temp1 = maps:is_key(S, maps:get(U, List)),
			if Temp1==true ->
					% io:format("~p ~p exist~n", S, U),
					Distance = D + maps:get(S, maps:get(U, List)),
					if 
						W > Distance ->
							List2 = maps:put(U, Distance, List1);
						true -> 
							List2 = maps:put(U, W, List1)
					end;
				true -> 
					List2 = maps:put(U, W, List1)
			end;
		true -> 
			List2 = maps:put(U, W, List1)
	end,
	do_calculation(T, List, S, D, List2).


process_request(N, N, _, Mainid, List, Dist) ->
	List1 = #{},
	% io:format("~p, ~p before ~n", [self(), Dist]),
	receive
		{link, S, D} ->
		% io:format("~p ~p receive ~n", [Pid, S]),
		% Dist1 = maps:remove(S, Dist),
		Dist1 = maps:from_list(Dist),
		Dist2 = maps:remove(S, Dist1),
		Dist3 = maps:to_list(Dist2),
		List3 = do_calculation(Dist3, List, S, D, List1)
	end,
	List2 = maps:to_list(List3),
	List5 = [{B, A} || {A, B} <- List2],
	% io:format("~p, ~p,~p after ~n", [self(), List2, List5]),
	if
		length(List2) == 0 ->
			Min = {?Inf+5, 0};
		true ->
			Min = min(List5)
	end,
	Mainid ! {link, element(2, Min), element(1, Min)};

process_request(I, N, Pid, Mainid, List, Dist) -> 
	List1 = #{},
	% io:format("~p, ~p before ~n", [self(), Dist]),
	receive
		{link, S, D} ->
		% io:format("~p ~p ~p |||| ~n", [Pid, S, D]),
		% Dist1 = maps:remove(S, Dist),maps:to_list(Dist1)
		Dist1 = maps:from_list(Dist),
		Dist2 = maps:remove(S, Dist1),
		Dist3 = maps:to_list(Dist2),
		List3 = do_calculation(Dist3, List, S, D, List1)
	end,
	List2 = maps:to_list(List3), %[S, D]
	List5 = [{B, A} || {A, B} <- List2],
	% io:format("~p, ~p,~p after ~n", [self(), List2, List5]),
	% io:format("~p\n", [List2]),
	
	if
		length(List2) == 0 ->
			Min = {?Inf+5, 0};
		true ->
			Min = min(List5)
	end, 
	Mainid ! {link, element(2, Min), element(1, Min)}, %[S, D]
	process_request(I+1, N, Pid, Mainid, List, List2).

proces_handle(Pid, Mainid, List, Dist, N) ->
	% io:format("~p ~p ~p\n", [Pid, List, Dist]),
	Map1 = maps:from_list(List),
	% Map2 = maps:from_list(Dist),
	process_request(1, N, Pid, Mainid, Map1, Dist).

create_process(P, P, Mainid, Lists, Dists, N) ->
	Pid = spawn(fun() -> proces_handle(self(), Mainid, lists:nth(P, Lists), lists:nth(P, Dists), N) end),
	[Pid];
create_process(I, P, Mainid, Lists, Dists, N) ->
	Pid = spawn(fun() -> proces_handle(self(), Mainid, lists:nth(I, Lists), lists:nth(I, Dists), N) end),
	[Pid] ++ create_process(I+1, P, Mainid, Lists, Dists, N).


create_dist_list(N, N, S, Dists) -> 
	if 
      N == S -> 
        Dists1 = maps:put(N, 0, Dists); 
      true -> 
        Dists1 = maps:put(N, ?Inf, Dists)
    end,
    Dists1;

create_dist_list(I, N, S, Dists) -> 
	if
      I == S -> 
        Dists1 = maps:put(I, 0, Dists);
      true -> 
        Dists1 = maps:put(I, ?Inf, Dists)
    end,
	create_dist_list(I+1, N, S, Dists1).


send_each_process([], _, _)-> ok;
send_each_process([H | T], S, D) ->
	% io:format("~p sent~n", [H]),
	H ! {link, S, D},
	send_each_process(T, S, D).


collect(Len, Len) -> 
	Temp = #{},
	receive
		{link, S, D} ->
			% io:format("~p ~p  check\n", [S, D]),
			Temp1 = maps:put(D, S, Temp)
	end,
	maps:to_list(Temp1);

collect(I, Len) -> 
	Temp = #{},
	receive
		{link, S, D} ->
			% io:format("~p ~p  check\n", [S, D]),
			Temp1 = maps:put(D, S, Temp)
	end,
	maps:to_list(Temp1) ++ collect(I+1, Len).


dijkstra(N, N, Pids, S, D, Ans) -> 
	send_each_process(Pids, S, D),
	Len = length(Pids),
	List1 = collect(1, Len),
	% List2 = maps:to_list(List1),
	Min = min(List1),
	% io:format("~p min ~p ~n", [List1, Min]),
	% io:format("~p ~n", [Min]),
	Ans1 = maps:put(element(2, Min), element(1, Min), Ans),
	Ans1;

dijkstra(I, N, Pids, S, D, Ans) ->
	% io:format("~p ~n", [N]),
	send_each_process(Pids, S, D),
	Len = length(Pids),
	List1 = collect(1, Len),
	% List2 = maps:to_list(List1),
	Min = min(List1),
	% io:format("~p min ~p ~n", [List1, Min]),
	Ans1 = maps:put(element(2, Min), element(1, Min), Ans),
	% Min = findMin(List1)
	dijkstra(I+1, N, Pids, element(2, Min), element(1, Min), Ans1).

print_output([], _) -> ok;
print_output([H|T], OFile) ->
	io:format(OFile, "~p ~p~n", [element(1, H), element(2, H)]),
	print_output(T, OFile).


main(Args) ->
	Input=lists:nth(1,Args),
	Output=lists:nth(2,Args),
	% io:format("~p ~p\n", [Input, Output]),
	{ok, IFile} = file:open(Input, [read]),
	{ok, OFile} = file:open(Output, [write]),
	%file:close(OFile),
	{ok, [P]} = io:fread(IFile, "", "~d"),
	{ok, [N]} = io:fread(IFile, "", "~d"),
	{ok, [M]} = io:fread(IFile, "", "~d"),
	% io:fwrite("~p ~p ~p\n", [P, N, M]),
	List = read_edges(1, M, IFile),
	{ok, [S]} = io:fread(IFile, "", "~d"),
	% io:format("~p\n", [S]),
	% lists:foreach(fun([A, B, C]) -> io:format("~p ~p ~p ~n", [A, B, C]) end, List),
	Graph = #{},
	% io:format("~p\n", [Graph]).
	Graph1 = create_graph(N, Graph, List),
	Graph2 = maps:to_list(Graph1),
	% io:format("~p\n", [Graph2]),
	Size = N div P,
	% io:format("~p\n", [Size]),
	Lists = split_graph(P, Size, Graph2),
	% io:format("~p\n", [lists:nth(3, Lists)]),
	Dists = #{},
	Dists1 = create_dist_list(1, N, S, Dists),
	Dists2 = maps:to_list(Dists1),
	% io:format("~p\n", [Dists2]),
	Dists3 = split_graph(P, Size, Dists2),
	Mainid = self(),
	Pids = create_process(1, P, Mainid, Lists, Dists3, N),
	% io:format("~p\n", [Pids]),
	% dijkstra(1, N, Pids, S, 0).
	Ans = #{S=>0},
	Ans1 = dijkstra(1, N-1, Pids, S, 0, Ans),
	Ans2 = maps:to_list(Ans1),
	% io:format("~p output\n", [Ans2]),
	print_output(Ans2, OFile),
	file:close(OFile).
                          
