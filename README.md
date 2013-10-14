# Sqlex

Easy to use mysql wrapper for emysql.


```elixir
SQL.init_pool [size: 100, host: 'db.local', db: 'mydb']
SQL.run "select * from table where id in ? and status = ?", [[1,2,3], "o'k"]
```


Now supporting transactions, in sense that if there an error transaction will rollback.
