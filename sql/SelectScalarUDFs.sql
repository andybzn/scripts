SELECT OBJECT_NAME([object_id]), definition, is_inlineable
  FROM sys.sql_modules
 WHERE is_inlineable = 1
