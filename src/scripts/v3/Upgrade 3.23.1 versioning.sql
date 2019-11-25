CREATE TABLE App.tbInstall
(
	InstallId INT NOT NULL IDENTITY,
	SQLDataVersion REAL NOT NULL,
	SQLRelease REAL NOT NULL,
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
	SELECT CONCAT(ROUND(SqlDataVersion, 2), '.', SqlRelease) AS VersionString, ROUND(SqlDataVersion, 2) SqlDataVersion, SqlRelease
	FROM App.tbInstall
	WHERE InstallId = (SELECT MAX(InstallId) FROM App.tbInstall)
go
CREATE FUNCTION App.fnVersion()
RETURNS NVARCHAR(10)
AS
BEGIN
	DECLARE @Version NVARCHAR(10) = '0.0.0'
	SELECT @Version = VersionString
	FROM App.vwVersion
	RETURN @Version
END
go
INSERT INTO App.tbInstall (SQLDataVersion, SQLRelease) VALUES (3.23, 1);
go

ALTER TABLE App.tbOptions DROP
	CONSTRAINT DF_App_tbOptions_SQLDataVersion, DF_App_tbOptions_SQLRelease,
	COLUMN SQLDataVersion, SQLRelease

go

CREATE OR ALTER PROCEDURE Usr.proc_AddUser
(
		@UserName NVARCHAR(25) = '<user>', 
		@FullName NVARCHAR(100) = '<firstname> <secondname>',
		@Address NVARCHAR(MAX) = '<home address',
		@EmailAddress NVARCHAR(255) = N'user@business-name.co.uk',
		@MobileNumber NVARCHAR(50) = '00000 000000',
		@CalendarCode NVARCHAR(10) = 'WORKS'
)
AS

	DECLARE @SQL NVARCHAR(MAX);

	SET @SQL = CONCAT('CREATE USER [', @UserName, '] FOR LOGIN [', @UserName, '] WITH DEFAULT_SCHEMA=[dbo];');
	EXECUTE sys.sp_executesql @stmt = @SQL;

	SET @SQL = CONCAT('ALTER ROLE [db_datareader] ADD MEMBER [', @UserName, '];');
	EXECUTE sys.sp_executesql @stmt = @SQL;
	SET @SQL = CONCAT('ALTER ROLE [db_datawriter] ADD MEMBER [', @UserName, '];');
	EXECUTE sys.sp_executesql @stmt = @SQL;


	--Register with client
	DECLARE @UserId NVARCHAR(10) = CONCAT(LEFT(@FullName, 1), SUBSTRING(@FullName, CHARINDEX(' ', @FullName) + 1, 1)); 

	INSERT INTO Usr.tbUser (UserId, UserName, LogonName, IsAdministrator, IsEnabled, CalendarCode, EmailAddress, MobileNumber)
	VALUES (@UserId, @FullName, 	@UserName, 1, 1, @CalendarCode, @EmailAddress, @MobileNumber)

	INSERT INTO Usr.tbMenuUser (UserId, MenuId)
	SELECT @UserId AS UserId, (SELECT MenuId FROM Usr.tbMenu) AS MenuId;

	--Assign full read/write/execute permissions
	DECLARE procs CURSOR FOR
		SELECT CONCAT(SCHEMA_NAME([schema_id]), '.', name) AS proc_name
		FROM sys.procedures;
	DECLARE @Proc NVARCHAR(100);

		OPEN procs
		FETCH NEXT FROM procs INTO @Proc
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @SQL = CONCAT('GRANT EXECUTE ON ', DB_NAME(), '.', @Proc, ' TO [', @UserName, '];');
			EXECUTE sys.sp_executesql @stmt = @SQL 
			FETCH NEXT FROM procs INTO @Proc
		END
		CLOSE procs
		DEALLOCATE procs

	DECLARE funcs CURSOR FOR
		SELECT CONCAT(SCHEMA_NAME([schema_id]), '.', name), type 
		FROM sys.objects where type IN ('TF', 'IF', 'FN');

	DECLARE @Func NVARCHAR(100), @Type CHAR(2);

		OPEN funcs
		FETCH NEXT FROM funcs INTO @Func, @Type
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @Type = 'FN'
				SET @SQL = CONCAT('GRANT EXECUTE ON ', DB_NAME(), '.', @Func, ' TO [', @UserName, '];');
			ELSE
				SET @SQL = CONCAT('GRANT SELECT ON ', DB_NAME(), '.', @Func, ' TO [', @UserName, '];');

			EXECUTE sys.sp_executesql @stmt = @SQL 

			FETCH NEXT FROM funcs INTO @Func, @Type
		END
		CLOSE funcs
		DEALLOCATE funcs
go

