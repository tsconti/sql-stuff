/*
    sp_find - searches the current database for every object whose name contains a string.

    Usage:
        EXEC dbo.sp_find 'order';                          -- names only
        EXEC dbo.sp_find 'order', @SearchDefinitions = 1;  -- also search inside procs/views/functions/triggers code

    Matches tables, views, procedures, functions, triggers, constraints, synonyms, sequences,
    columns, parameters, indexes, schemas and user-defined types.
    The search string is matched literally (%, _ and [ are not treated as wildcards).
*/
CREATE OR ALTER PROCEDURE dbo.sp_find
    @Search             NVARCHAR(128),
    @SearchDefinitions  BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Pattern NVARCHAR(400) =
        N'%' + REPLACE(REPLACE(REPLACE(@Search, N'[', N'[[]'), N'%', N'[%]'), N'_', N'[_]') + N'%';

    SELECT MatchType, SchemaName, ObjectName, SubObjectName, ObjectTypeDesc, Created, Modified
    FROM (
        -- Tables, views, procedures, functions, triggers, constraints, synonyms, sequences...
        SELECT  MatchType      = N'OBJECT',
                SchemaName     = s.name,
                ObjectName     = o.name,
                SubObjectName  = CAST(NULL AS SYSNAME),
                ObjectTypeDesc = o.type_desc,
                Created        = o.create_date,
                Modified       = o.modify_date
        FROM sys.objects o
        JOIN sys.schemas s ON s.schema_id = o.schema_id
        WHERE o.is_ms_shipped = 0
          AND o.name LIKE @Pattern

        UNION ALL

        -- Columns of tables, views and table-valued functions
        SELECT  N'COLUMN', s.name, o.name, c.name,
                o.type_desc + N' COLUMN (' + TYPE_NAME(c.user_type_id) + N')',
                o.create_date, o.modify_date
        FROM sys.columns c
        JOIN sys.objects o ON o.object_id = c.object_id
        JOIN sys.schemas s ON s.schema_id = o.schema_id
        WHERE o.is_ms_shipped = 0
          AND c.name LIKE @Pattern

        UNION ALL

        -- Parameters of procedures and functions
        SELECT  N'PARAMETER', s.name, o.name, p.name,
                o.type_desc + N' PARAMETER (' + TYPE_NAME(p.user_type_id) + N')',
                o.create_date, o.modify_date
        FROM sys.parameters p
        JOIN sys.objects o ON o.object_id = p.object_id
        JOIN sys.schemas s ON s.schema_id = o.schema_id
        WHERE o.is_ms_shipped = 0
          AND p.parameter_id > 0
          AND p.name LIKE @Pattern

        UNION ALL

        -- Indexes (PK / unique constraints already show up as objects)
        SELECT  N'INDEX', s.name, o.name, i.name,
                i.type_desc + N' INDEX',
                o.create_date, o.modify_date
        FROM sys.indexes i
        JOIN sys.objects o ON o.object_id = i.object_id
        JOIN sys.schemas s ON s.schema_id = o.schema_id
        WHERE o.is_ms_shipped = 0
          AND i.name IS NOT NULL
          AND i.is_primary_key = 0
          AND i.is_unique_constraint = 0
          AND i.name LIKE @Pattern

        UNION ALL

        -- Schemas
        SELECT  N'SCHEMA', s.name, NULL, NULL, N'SCHEMA', NULL, NULL
        FROM sys.schemas s
        WHERE s.name LIKE @Pattern

        UNION ALL

        -- User-defined types (alias and table types)
        SELECT  N'TYPE', s.name, t.name, NULL,
                CASE WHEN t.is_table_type = 1 THEN N'USER_TABLE_TYPE' ELSE N'USER_ALIAS_TYPE' END,
                NULL, NULL
        FROM sys.types t
        JOIN sys.schemas s ON s.schema_id = t.schema_id
        WHERE t.is_user_defined = 1
          AND t.name LIKE @Pattern

        UNION ALL

        -- Code of procedures, views, functions and triggers that mentions the string
        SELECT  N'DEFINITION', s.name, o.name, NULL, o.type_desc,
                o.create_date, o.modify_date
        FROM sys.sql_modules m
        JOIN sys.objects o ON o.object_id = m.object_id
        JOIN sys.schemas s ON s.schema_id = o.schema_id
        WHERE @SearchDefinitions = 1
          AND o.is_ms_shipped = 0
          AND m.definition LIKE @Pattern
    ) r
    ORDER BY MatchType, SchemaName, ObjectName, SubObjectName;
END
GO

/*
    OPTIONAL: install once in master so it can be called from ANY database
    (it will search the catalog of the database you are connected to).
    sys.sp_MS_marksystemobject is undocumented and requires sysadmin, use at your own discretion.

    USE master;
    GO
    -- run the CREATE OR ALTER PROCEDURE above here (the "sp_" prefix is required)
    EXEC sys.sp_MS_marksystemobject 'sp_find';
    GO
    -- then, from any database:
    USE MyDatabase;
    EXEC sp_find 'order';
*/
