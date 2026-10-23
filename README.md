# sql-stuff

Reusable SQL for SQL Server and Postgres: procedures, functions, views, scripts and snippets.

## Layout

```
sqlserver/            T-SQL
  procedures/<name>/  one folder per procedure: <name>.sql, README.md, examples.sql
  functions/
  views/
  scripts/            ad-hoc admin and diagnostic queries
  snippets/           small reusable fragments
postgres/             same structure, PL/pgSQL
docs/                 cross-engine notes and conventions
```

## Conventions

- Folder and file names match the object name exactly (`sp_find/sp_find.sql`).
- Definitions can be rerun (`CREATE OR ALTER` / `CREATE OR REPLACE`). To deploy a change, run the file again.

## Contents

| Engine     | Object    | Description                     |
|------------|-----------|---------------------------------|
| SQL Server | `sp_find` | Finds objects in the database.  |
