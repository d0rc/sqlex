defmodule SQL do
	defrecord :result_packet, Record.extract(:result_packet, from: "deps/emysql/include/emysql.hrl")
	defrecord :field, Record.extract(:field, from: "deps/emysql/include/emysql.hrl")
	defp to_atom(val), do: :erlang.binary_to_atom(val, :utf8)  
	def read sql do
		:result_packet[rows: rows, field_list: fields]  = :emysql.execute :mp, sql
		name_list = lc :field[name: name] inlist fields, do: to_atom name
		lc row inlist rows, do: Enum.zip(name_list, row)
	end

	defp prep_argument(arg) when is_list(arg), do: [[?(| :erlang.binary_to_list Enum.join arg, "," ]|[?)]]
	defp prep_argument(arg) when is_binary(arg), do: [[?'|:erlang.binary_to_list(arg)]|[?']] 
	defp prep_argument(arg) when is_integer(arg), do: :erlang.integer_to_list arg

	defp in_query([], _), do: []
	defp in_query(sql, args) when is_binary(sql), do: in_query(:erlang.binary_to_list(sql), args)
	defp in_query([??|sql], [arg|arg_tail]), do: [prep_argument(arg)|in_query(sql, arg_tail)]
	defp in_query([s|sql], args), do: [s|in_query(sql, args)]

	def query(sql, args), do: :erlang.list_to_binary List.flatten in_query sql, args

	def init_pool do
		:ok = :emysql.add_pool :mp, 5, 'root', '', 'lotod3', 3306, 'bm', :utf8
	end
end
