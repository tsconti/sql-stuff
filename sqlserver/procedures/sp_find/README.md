# sp_find

Searches the current database for every object whose name contains a string. It can also search
inside the code of procedures, views, functions and triggers.

It matches tables, views, procedures, functions, triggers, constraints, synonyms, sequences,
columns, parameters, indexes, schemas and user-defined types. System (`is_ms_shipped`) objects are
excluded.

## Install

Run `sp_find.sql` in the target database. It uses `CREATE OR ALTER`, so rerunning it updates the
procedure.

To call it from any database, you can instead install it in `master` and mark it as a system
object. The steps are in the comment block at the end of `sp_find.sql`. This needs `sysadmin` and
uses the undocumented `sys.sp_MS_marksystemobject`.

## Parameters

| Parameter            | Type            | Default | Description                                                              |
|----------------------|-----------------|---------|--------------------------------------------------------------------------|
| `@Search`            | `NVARCHAR(128)` | —       | Text to look for in names. Matched literally: `%`, `_` and `[` are not wildcards. |
| `@SearchDefinitions` | `BIT`           | `0`     | `1` also searches the code of procedures, views, functions and triggers. |

## Output

One row per match, ordered by `MatchType, SchemaName, ObjectName, SubObjectName`.

| Column           | Description                                                                 |
|------------------|-----------------------------------------------------------------------------|
| `MatchType`      | `OBJECT`, `COLUMN`, `PARAMETER`, `INDEX`, `SCHEMA`, `TYPE` or `DEFINITION`. |
| `SchemaName`     | Schema of the match.                                                        |
| `ObjectName`     | Object that matched, or that owns the matching column, parameter or index.  |
| `SubObjectName`  | Column, parameter or index name. `NULL` for other match types.              |
| `ObjectTypeDesc` | Object type. Columns and parameters include their data type.                |
| `Created`        | Object's `create_date` (`NULL` for schemas and types).                      |
| `Modified`       | Object's `modify_date` (`NULL` for schemas and types).                      |

See [`examples.sql`](examples.sql) for sample calls.
