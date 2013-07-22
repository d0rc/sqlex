Code.require_file "test_helper.exs", __DIR__

defmodule SqlexTest do
  use ExUnit.Case

  test "we can start apps" do
  	assert( Enum.all? (lc a inlist [:crypto, :emysql], do: :application.start a), fn r ->
  		{:error, {:already_started, _}} = r
  	end)
	 	 
  end

  test "we can run query" do
  	[row] = SQL.read "select 1 as ok"
  	assert(row[:ok] == 1)
  end

  test "the truth" do
    assert(true)
  end
end
