-- Sample calls for sp_find

-- Every object, column, parameter, index, schema or type whose name contains "order"
EXEC dbo.sp_find 'order';

-- Same, plus procedures, views, functions and triggers whose code mentions "order"
EXEC dbo.sp_find 'order', @SearchDefinitions = 1;

-- Wildcard characters are matched literally: this finds names containing "_id",
-- not any character followed by "id"
EXEC dbo.sp_find '_id';

-- Find everything that references a table before changing or dropping it
EXEC dbo.sp_find 'Customers', @SearchDefinitions = 1;
