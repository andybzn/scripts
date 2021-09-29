/*-------------------------------------------------------------
	
	SCRIPT:  SQL Server Quick Configure.sql
	AUTHOR:  dark-coffee (github.com/dark-coffee)
	VERSION:  1.2
	MODIFIED: 2021-04-12
	NOTES:
		Modifies SQL Server instance config to my
        preferred defaults with *extreme* prejudice.
        These are intended for lightweight SQL Servers, 
        anything heavier will require a bit of tweaking.
        YMMV.

-------------------------------------------------------------*/

/* enable advanced options */
/* config id: 518*/
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE
GO

/* set the minimum server memory */
/* config id: 1543 */
EXEC sp_configure 'min server memory (MB)', 2048;
RECONFIGURE
GO

/* set the maximum server memory to 3/4 available physical memory */
/* config id: 1544 
DECLARE @TargetMaxMemory INT;
SET @TargetMaxMemory = (SELECT ((total_physical_memory_kb/1024)/4)*3 FROM sys.dm_os_sys_memory);
EXEC sp_configure 'max server memory (MB)', @TargetMaxMemory;
RECONFIGURE
GO
*/

/* set ctfp to 50 */
/* config id: 1538 */
EXEC sp_configure 'cost threshold for parallelism', 50;
RECONFIGURE
GO

/* set maxdop to 0 */
/* config id: 1539 */
EXEC sp_configure 'max degree of parallelism', 0;
RECONFIGURE
GO

/* enable backup compression */
/* config id: 1579 */
EXEC sp_configure 'backup compression default', 1;
RECONFIGURE
GO

/* set fill factor to 100% */
/* config id: 109 */
EXEC sp_configure 'fill factor (%)', 100;
RECONFIGURE
GO

/* enable sql server agent */
/* config id: 16384 */
EXEC sp_configure 'Agent XPs', 1;
RECONFIGURE
GO

/* enable database mail */
/* config id: 16386 */
EXEC sp_configure 'Database Mail XPs', 1;
RECONFIGURE
GO

/* configure priority boost */
/* config id: 1517 */
EXEC sp_configure 'priority boost', 0;
RECONFIGURE
GO

/* configure affinity mask */
/* config id: 1535 */
EXEC sp_configure 'affinity mask', 0;
RECONFIGURE
GO

/* configure query governor cost limit */
/* config id: 1545 */
EXEC sp_configure 'query governor cost limit', 0;
RECONFIGURE
GO

/* enable clr */
/* config id: 1562 */
EXEC sp_configure 'clr enabled', 1;
RECONFIGURE
GO

/* disable clr strict security */
/* config id: 1587 */
EXEC sp_configure 'clr strict security', 0;
RECONFIGURE
GO

/* enable xp_cmdshell */
/* config id: 16390 */
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE
GO