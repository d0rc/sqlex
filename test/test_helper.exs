lc a inlist [:crypto, :emysql], do: :application.start a
#:ok = :emysql.add_pool :mp, 5, 'root', '', 'lotod3', 3306, 'bm', :utf8
:ok = SQL.init [login: 'root', host: '127.0.0.1', password: '']
ExUnit.start
