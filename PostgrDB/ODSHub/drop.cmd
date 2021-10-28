copy _drop.sql _INIT_DB\publish\

"C:\Program Files\PostgreSQL\12\bin\psql.exe" -U postgres -d odshub -f _INIT_DB\publish\_drop.sql