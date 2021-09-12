/*-------------------------------------------------------------
	
	SCRIPT:  AdhocQueryPercentageCheck.sql
	AUTHOR:  dark-coffee (github.com/dark-coffee)
	VERSION:  1
	MODIFIED: 2020-11-23
	NOTES:
		Selects the adhoc query percentage.
        The query to do this varies by version, so this
            script caters for that.

-------------------------------------------------------------*/
/*------Setup Area-------------------------------------------*/


-- Select SQLServerVersion as variable.
DECLARE @SQLServerVersion VARCHAR(2);
SET @SQLServerVersion = CONVERT(VARCHAR,(SELECT value_data FROM sys.dm_server_registry WHERE value_name = 'CurrentVersion'));


-- Declare the TotalCacheMB variable.
DECLARE @TotalCacheMB VARCHAR(14);


-- Set the TotalCacheMB variable.
IF @SQLServerVersion <= 12
    -- SQL2014 and below.
    SET @TotalCacheMB = 'Total_CacheMB';
ELSE 
    -- All other versions.
    SET @TotalCacheMB = 'Total_Cache_MB';


/*-----------------------------------------------------------*/
/*------Query Area-------------------------------------------*/


-- Declare and set the query.
DECLARE @AdHocPlanQuery NVARCHAR(MAX);
SET @AdHocPlanQuery = '
    SELECT
        AdHoc_Plan_MB, '+ @TotalCacheMB +',
        AdHoc_Plan_MB*100.0 / '+ @TotalCacheMB +' AS ''AdHoc %''
    FROM (
    SELECT SUM(CASE
    WHEN objtype = ''adhoc''
            THEN CONVERT(BIGINT,size_in_bytes)
    ELSE 0 END) / 1048576.0 AdHoc_Plan_MB,
            SUM(CONVERT(BIGINT,size_in_bytes)) / 1048576.0 '+ @TotalCacheMB +'
    FROM sys.dm_exec_cached_plans) T
';


-- Execute the query.
EXEC sp_executesql @AdHocPlanQuery;


/*-----------------------------------------------------------
        End Script;
-------------------------------------------------------------*/