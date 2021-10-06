CREATE TABLE App.tbInstall
(
	InstallId INT NOT NULL IDENTITY,
	SQLDataVersion REAL NOT NULL,
	SQLRelease INT NOT NULL,
	InsertedBy nvarchar(50) NOT NULL CONSTRAINT DF_App_tbInstall_InsertedBy DEFAULT (SUSER_SNAME()),
	InsertedOn datetime NOT NULL CONSTRAINT DF_App_tbInstall_InsertedOn DEFAULT (GETDATE()),
	UpdatedBy nvarchar(50) NOT NULL CONSTRAINT DF_App_tbInstall_UpdatedBy DEFAULT (SUSER_SNAME()),
	UpdatedOn datetime NOT NULL CONSTRAINT DF_App_tbInstall_UpdatedOn DEFAULT (GETDATE()),
	CONSTRAINT PK_App_tbInstall PRIMARY KEY CLUSTERED 
	(
		InstallId ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY];
go
CREATE OR ALTER VIEW App.vwVersion
AS
	SELECT CONCAT(ROUND(SqlDataVersion, 4), '.', SqlRelease) AS VersionString, ROUND(SqlDataVersion, 2) SqlDataVersion, SqlRelease
	FROM App.tbInstall
	WHERE InstallId = (SELECT MAX(InstallId) FROM App.tbInstall)
go
CREATE OR ALTER FUNCTION App.fnVersion()
RETURNS NVARCHAR(10)
AS
BEGIN
	DECLARE @Version NVARCHAR(10) = '0.0.0'
	SELECT @Version = VersionString
	FROM App.vwVersion
	RETURN @Version
END
go
INSERT INTO App.tbInstall (SQLDataVersion, SQLRelease) VALUES (3.24, 1);
go

ALTER TABLE App.tbOptions DROP
	CONSTRAINT DF_App_tbOptions_SQLDataVersion, DF_App_tbOptions_SQLRelease,
	COLUMN SQLDataVersion, SQLRelease

go

CREATE OR ALTER PROCEDURE Usr.proc_AddUser
(
	@UserName NVARCHAR(25), 
	@FullName NVARCHAR(100),
	@HomeAddress NVARCHAR(MAX),
	@EmailAddress NVARCHAR(255),
	@MobileNumber NVARCHAR(50),
	@CalendarCode NVARCHAR(10),
	@IsAdministrator BIT = 0
)
AS

	DECLARE @SQL NVARCHAR(MAX);
	DECLARE @ObjectName NVARCHAR(100);

	SET @SQL = CONCAT('CREATE USER [', @UserName, '] FOR LOGIN [', @UserName, '] WITH DEFAULT_SCHEMA=[dbo];');
	EXECUTE sys.sp_executesql @stmt = @SQL;

	SET @SQL = CONCAT('ALTER ROLE [db_datareader] ADD MEMBER [', @UserName, '];');
	EXECUTE sys.sp_executesql @stmt = @SQL;
	SET @SQL = CONCAT('ALTER ROLE [db_datawriter] ADD MEMBER [', @UserName, '];');
	EXECUTE sys.sp_executesql @stmt = @SQL;


	--Register with client
	DECLARE @UserId NVARCHAR(10) = CONCAT(LEFT(@FullName, 1), SUBSTRING(@FullName, CHARINDEX(' ', @FullName) + 1, 1)); 

	INSERT INTO Usr.tbUser (UserId, UserName, LogonName, IsAdministrator, IsEnabled, CalendarCode, EmailAddress, MobileNumber, [Address])
	VALUES (@UserId, @FullName, @UserName, @IsAdministrator, 1, @CalendarCode, @EmailAddress, @MobileNumber, @HomeAddress)

	INSERT INTO Usr.tbMenuUser (UserId, MenuId)
	SELECT @UserId AS UserId, (SELECT MenuId FROM Usr.tbMenu) AS MenuId;

	--Deny insert, delete and update permission on sys tables
	DECLARE tbs CURSOR FOR
		WITH tbnames AS
		(
			SELECT SCHEMA_NAME(schema_id) AS SchemaName, CONCAT(SCHEMA_NAME(schema_id), '.', [name]) AS TableName
			FROM sys.tables
			WHERE type = 'U' AND SCHEMA_NAME(schema_id) <> 'dbo' 
		)
		SELECT TableName
		FROM tbnames
		WHERE (SchemaName = 'Usr')
			OR (TableName like '%Status%' or TableName like '%Type%')
			OR (TableName = 'App.tbDocClass')
			OR (TableName = 'App.tbEventLog')
			OR (TableName = 'App.tbInstall')
			OR (TableName = 'App.tbRecurrence')
			OR (TableName = 'App.tbRounding')
			OR (TableName = 'App.tbText')
			OR (TableName = 'Cash.tbMode');

		OPEN tbs
		FETCH NEXT FROM tbs INTO @ObjectName
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @SQL = CONCAT('DENY DELETE ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, ']')
			EXECUTE sys.sp_executesql @stmt = @SQL
			SET @SQL = CONCAT('DENY INSERT ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, ']')
			EXECUTE sys.sp_executesql @stmt = @SQL
			SET @SQL = CONCAT('DENY UPDATE ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, ']')
			EXECUTE sys.sp_executesql @stmt = @SQL
			SET @SQL = CONCAT('GRANT SELECT ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, ']')
			EXECUTE sys.sp_executesql @stmt = @SQL
			 
			FETCH NEXT FROM tbs INTO @ObjectName
		END
		CLOSE tbs
		DEALLOCATE tbs

	--Assign full read/write/execute permissions
	DECLARE procs CURSOR FOR
		SELECT CONCAT(SCHEMA_NAME([schema_id]), '.', name) AS proc_name
		FROM sys.procedures;
	
		OPEN procs
		FETCH NEXT FROM procs INTO @ObjectName
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @SQL = CONCAT('GRANT EXECUTE ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, '];');
			EXECUTE sys.sp_executesql @stmt = @SQL 
			FETCH NEXT FROM procs INTO @ObjectName
		END
		CLOSE procs
		DEALLOCATE procs

	DECLARE funcs CURSOR FOR
		SELECT CONCAT(SCHEMA_NAME([schema_id]), '.', name), type 
		FROM sys.objects where type IN ('TF', 'IF', 'FN');

	DECLARE @Type CHAR(2);

		OPEN funcs
		FETCH NEXT FROM funcs INTO @ObjectName, @Type
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @Type = 'FN'
				SET @SQL = CONCAT('GRANT EXECUTE ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, '];');
			ELSE
				SET @SQL = CONCAT('GRANT SELECT ON ', DB_NAME(), '.', @ObjectName, ' TO [', @UserName, '];');

			EXECUTE sys.sp_executesql @stmt = @SQL 

			FETCH NEXT FROM funcs INTO @ObjectName, @Type
		END
		CLOSE funcs
		DEALLOCATE funcs
go
