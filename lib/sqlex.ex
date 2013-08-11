defmodule FindFile do
	def find(target, root // ".") do
		case inner_find(target, root) |> List.flatten |> Enum.filter(fn({true,_}) -> true;(_) -> false end) do
			[{true, path}|_] -> path
			_				 -> nil
		end
	end
	defp inner_find(target, root // ".") do
		{:ok, list} = File.ls root
		list |> Enum.map(fn(file) ->
			full_path = "#{root}/#{file}"
			case file do
				^target  -> {true, full_path}
				_       -> 
					case File.regular? full_path do
						true  -> full_path
						false -> inner_find(target, full_path)
					end
			end
		end)
	end
end

defmodule SQL do
	require FindFile
	
	defrecord :result_packet, Record.extract(:result_packet, from: FindFile.find "emysql.hrl")
	defrecord :field, Record.extract(:field, from: FindFile.find "emysql.hrl")
	defp to_atom(val), do: :erlang.binary_to_atom(val, :utf8)  
	

	defp set_defaults(dict, defaults), do: set_defaults(dict, defaults, Dict.keys(defaults))
	
	defp set_defaults(dict, _, []), do:	dict
	defp set_defaults(dict, defaults, [k|keys]) do 
		case dict[k] do
			nil -> set_defaults (Dict.put dict, k, defaults[k]), defaults, keys
			_   -> set_defaults dict, defaults, keys
		end
	end

	def read sql do
		:result_packet[rows: rows, field_list: fields]  = :emysql.execute :mp, sql
		name_list = lc :field[name: name] inlist fields, do: to_atom name
		lc row inlist rows, do: Enum.zip(name_list, row)
	end

	defp escape([]), do: []
	defp escape([?'|str]), do: [92,?'|escape(str)]
	defp escape([c|str]), do: [c|escape(str)]

	defp prep_argument(arg) when is_list(arg), do: [[?(| :erlang.binary_to_list Enum.join arg, "," ]|[?)]]
	defp prep_argument(arg) when is_binary(arg), do: [[?'|escape(:erlang.binary_to_list(arg))]|[?']] 
	defp prep_argument(arg) when is_integer(arg), do: :erlang.integer_to_list arg

	defp in_query([], _), do: []
	defp in_query(sql, args) when is_binary(sql), do: in_query(:erlang.binary_to_list(sql), args)
	defp in_query([??|sql], [arg|arg_tail]), do: [prep_argument(arg)|in_query(sql, arg_tail)]
	defp in_query([s|sql], args), do: [s|in_query(sql, args)]

	def query(sql, args), do: :erlang.list_to_binary List.flatten in_query sql, args

	def run(sql, args), do: read query sql, args

	def init_pool args_original do
		defaults = [pool: :mp, size: 5, login: 'root', password: '', host: 'localhost', port: 3306, db: 'test']
		args = set_defaults args_original, defaults
		:ok = :emysql.add_pool args[:pool], args[:size], args[:login], args[:password], args[:host], args[:port], args[:db], :utf8
	end
end
