-module ('2019201085_1').
-export ([main/1]).

print(Sid, Rid, T, OFile) ->
	{ok, Fout} = file:open(OFile, [write, append]),
	io:fwrite(Fout, "Process ~p received token ~p from process ~p.\n", [Rid, T, Sid]),
	file:close(Fout).

process_request(Pname, _, Nextname, Nextid, T, OFile) ->
	receive
		{link, T} ->
		print(Pname, Nextname, T, OFile)
	end,
  	Nextid ! {link, T}.

process_handle(Pname, Pid, OFile) ->
  receive
    {link, Nextname, Nextid, T} ->
    process_request(Pname, Pid, Nextname, Nextid, T, OFile)
  end.

create_process(_, 0, _, Root, _)-> Root;

create_process(N, N, T, Root, OFile) ->
	Current = spawn(fun() -> process_handle(N, self(), OFile) end),
	Current ! {link, 0, Root, T},
 	Current;

create_process(I, N, T, Root, OFile) ->
	Current = spawn(fun() -> process_handle(I, self(), OFile) end),
	Next = create_process(I+1, N, T, Root, OFile),
	Current ! {link, I+1, Next, T},
	Current.

main(Args) ->
    % io:format("Args: ~p\n", [Args]),
	Input=lists:nth(1,Args),
	Output=lists:nth(2,Args),
	% io:format("~p ~p\n", [Input, Output]),
	{ok, IFile} = file:open(Input, [read]),
	{ok, OFile} = file:open(Output, [write]),
	file:close(OFile),
	{ok, Data} = io:fread(IFile, "", "~d~d"),
	% Data = [10, 20],
	% io:fwrite("~p ~p\n", Data).
	N=lists:nth(1,Data),
	T=lists:nth(2,Data),
	% io:fwrite("~p ~p\n", [N, T]),
	Root = spawn(fun() -> process_handle(0, self(), Output) end),
	Next = create_process(1, N-1, T, Root, Output),
	Root ! {link, 1, Next, T},
	Root ! {link, T},
    Root.
	% io:fwrite("~p\n", [self()]).



