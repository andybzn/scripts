/*-------------------------------------------------------------
	
	SCRIPT:  sp_DropExchLogins.sql
	AUTHOR:  andybzn (github.com/andybzn)
	VERSION:  1
	MODIFIED: 2021-03-17
	NOTES:
		Locates and drops the Exchequer logins for a
        particular database.
        
-------------------------------------------------------------*/
/*------Procedure Creation-----------------------------------*/


-- Force database: master
USE master;
GO


-- Drop the procedure if it exists
DROP PROC IF EXISTS sp_DropExchLogins;
GO


-- Create the procedure
CREATE PROCEDURE sp_DropExchLogins
    @Database AS VARCHAR(MAX)
AS


    /*-------------------------------------------------------------
	
	    SCRIPT:  sp_DropExchLogins.sql
	    AUTHOR:  andybzn (github.com/andybzn)
	    VERSION:  1
	    MODIFIED: 2021-03-17
	    NOTES:
		    Locates and drops the Exchequer logins for a
            particular database.
        USAGE: sp_DropExchLogins @Database = 'DatabaseName'

    -------------------------------------------------------------*/ 



    -- Set NOCOUNT
    SET NOCOUNT ON;



    -- Sanity Check Input
    -- Ensure database variable <> NULL
    IF @Database IS NULL
        RAISERROR ('Database not specified', 16,1);

    -- Ensure database exists
    IF NOT EXISTS (
        SELECT 0 FROM sys.databases WHERE name = @Database
    )
    BEGIN
        RAISERROR ('Database specified does not exist', 11,1);
    END



    -- Procedure Logic
    -- Temptable removal
    -- Temptable: Instance logins
    IF OBJECT_ID('tempdb..#sp_DropExchLogins_InstanceLogins') IS NOT NULL
    BEGIN
        PRINT '#sp_DropExchLogins_InstanceLogins already exists. Dropping Table.'
        DROP TABLE #sp_DropExchLogins_InstanceLogins;
        PRINT 'Dropped.'
    END
    
    -- Temptable: Database logins
    IF OBJECT_ID('tempdb..#sp_DropExchLogins_DatabaseLogins') IS NOT NULL
    BEGIN
        PRINT '#sp_DropExchLogins_DatabaseLogins already exists. Dropping Table.'
        DROP TABLE #sp_DropExchLogins_DatabaseLogins;
        PRINT 'Dropped.'
    END


    -- Temptable creation
    -- Temptable: Instance logins
    CREATE TABLE #sp_DropExchLogins_InstanceLogins(
        name VARCHAR(MAX),
        principal_id INT,
        type VARCHAR(1),
        type_desc VARCHAR(25)
    );

    -- Temptable: Instance logins
    CREATE TABLE #sp_DropExchLogins_DatabaseLogins(
        name VARCHAR(MAX),
        principal_id INT,
        type VARCHAR(1),
        type_desc VARCHAR(25)
    );


    -- Collect instance logins
    INSERT INTO #sp_DropExchLogins_InstanceLogins
    SELECT name,
           principal_id
    FROM master.sys.server_principals
    WHERE 
        type = 'S'
    AND name LIKE 'ADM%'
    OR  name LIKE 'REP%'


    -- Collect database logins
    -- Declare variable to hold our statement
    DECLARE @sp_DropExchLogins_CollectDatabaseLogins NVARCHAR(MAX);

    -- Set SQL statement
    SET @sp_DropExchLogins_CollectDatabaseLogins = 
    'INSERT INTO #sp_DropExchLogins_DatabaseLogins
    SELECT name,
           principal_id
    FROM ' + @Database + '.sys.database_principals
    WHERE 
        type = ''S''
    AND name LIKE ''ADM%''
    OR  name LIKE ''REP%''';

    -- Execute statement
    EXEC sp_executesql @sp_DropExchLogins_CollectDatabaseLogins;


    -- Select statement to display the logins
    /*SELECT
        TIL.name, 
        TIL.principal_id
    FROM #sp_DropExchLogins_InstanceLogins TIL
    JOIN #sp_DropExchLogins_DatabaseLogins TDL 
        ON TIL.name = TDL.name;*/


    -- Cursor to drop the logins
    -- Declare the variable we'll be using
    DECLARE @sp_DropExchLogins_LoginToDrop VARCHAR(MAX);

    -- Declare the cursor
    DECLARE sp_DropExchLogins_Cursor CURSOR FOR

        SELECT TIL.name
        FROM #sp_DropExchLogins_InstanceLogins TIL
        JOIN #sp_DropExchLogins_DatabaseLogins TDL 
            ON TIL.name = TDL.name;

    -- Open the cursor
    OPEN sp_DropExchLogins_Cursor;

    -- Load the cursor
    FETCH NEXT FROM sp_DropExchLogins_Cursor
    INTO @sp_DropExchLogins_LoginToDrop;

    -- Cursor action
    WHILE @@FETCH_STATUS = 0
    BEGIN

        -- Feedback to the user
        PRINT 'Login Found: ' + @sp_DropExchLogins_LoginToDrop
        PRINT 'Dropping Login.'

        -- Declare variable for SQL Statement, and set the statement
        DECLARE @sp_DropExchLogins_SQLToExecute NVARCHAR(MAX);
        SET @sp_DropExchLogins_SQLToExecute = 'DROP LOGIN ' + @sp_DropExchLogins_LoginToDrop;

        -- Execute the statement
        EXEC sp_executesql @sp_DropExchLogins_SQLToExecute;

        -- Feedback to the user
        PRINT 'Login Dropped.'

        -- Load the cursor
        FETCH NEXT FROM sp_DropExchLogins_Cursor
        INTO @sp_DropExchLogins_LoginToDrop;

    END



    -- Cleanup
    -- Close and deallocare the cursor
    CLOSE sp_DropExchLogins_Cursor;
    DEALLOCATE sp_DropExchLogins_Cursor;
    GO
    


-- Procedure end
GO


/*-----------------------------------------------------------
        End Script;
-------------------------------------------------------------*/
