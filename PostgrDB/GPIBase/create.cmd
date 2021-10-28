copy _create.sql _INIT_DB\publish\
copy _drop.sql _INIT_DB\publish\

copy Table\*.* _INIT_DB\publish\
copy Sequence\*.* _INIT_DB\publish\
copy Function\*.* _INIT_DB\publish\
copy Trigger\*.* _INIT_DB\publish\
copy Procedure\*.* _INIT_DB\publish\
copy Data\*.* _INIT_DB\publish\

"C:\Program Files\PostgreSQL\12\bin\psql.exe" -U postgres -d odshub -f _INIT_DB\publish\_create.sql