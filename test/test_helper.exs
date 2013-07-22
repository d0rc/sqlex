lc a inlist [:crypto, :emysql], do: :application.start a
#:ok = :emysql.add_pool :mp, 5, 'root', '', 'lotod3', 3306, 'bm', :utf8
:ok = SQL.init_pool [login: 'root', host: 'lotod3', password: '']
ExUnit.start
