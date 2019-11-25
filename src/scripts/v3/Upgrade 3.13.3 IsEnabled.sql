BEGIN TRY
	ALTER TABLE Usr.tbUser WITH NOCHECK ADD
		IsEnabled SMALLINT NOT NULL CONSTRAINT DF_Usr_tbUser_IsEnabled DEFAULT (1)
END TRY
BEGIN CATCH
	PRINT 'Usr IsEnabled Added'
END CATCH
go
DROP INDEX IF EXISTS IX_Usr_tb_LogonName ON Usr.tbUser;
DROP INDEX IF EXISTS IX_Usr_tbUser_LogonName ON Usr.tbUser;
DROP INDEX IF EXISTS IX_Usr_tbUser_IsEnabled_LogonName ON Usr.tbUser;
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Usr_tbUser_LogonName ON Usr.tbUser
(
	LogonName ASC	
);
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Usr_tbUser_IsEnabled_LogonName ON Usr.tbUser
(
	IsEnabled ASC,
	LogonName ASC	
);
go
DROP INDEX IF EXISTS UserName ON Usr.tbUser;
DROP INDEX IF EXISTS IX_Usr_tbUser_UserName ON Usr.tbUser;
DROP INDEX IF EXISTS IX_Usr_tbUser_IsEnabled_UserName ON Usr.tbUser;
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Usr_tbUser_UserName ON Usr.tbUser
(
	UserName ASC	
);
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Usr_tbUser_IsEnabled_UserName ON Usr.tbUser
(
	IsEnabled ASC,
	UserName ASC	
);
go
ALTER TABLE Usr.tbUser
	DROP 
		CONSTRAINT [DF_Usr_tb_Administrator],
		COLUMN Administrator;
go
ALTER TABLE Usr.tbUser ADD
	IsAdministrator BIT NOT NULL CONSTRAINT DF_Usr_tbUser_IsAdministrator DEFAULT (0)
go
ALTER VIEW [Usr].[vwCredentials]
  AS
SELECT     UserId, UserName, LogonName, IsAdministrator
FROM         Usr.tbUser
WHERE     (LogonName = SUSER_SNAME()) AND (IsEnabled <> 0)
go
DROP PROCEDURE IF EXISTS App.proc_NewCompany
go

ALTER TABLE App.tbOptions
	DROP CONSTRAINT [DF_App_tbRoot_Initialised],
		COLUMN Initialised
go
ALTER TABLE App.tbOptions WITH NOCHECK ADD
	IsInitialised BIT NOT NULL CONSTRAINT DF_App_tbOptions_IsIntialised DEFAULT (0)
go
CREATE OR ALTER PROCEDURE [App].[proc_Initialised]
(@Setting bit)
  AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF @Setting = 1
			AND (EXISTS (SELECT     Org.tbOrg.AccountCode
						FROM         Org.tbOrg INNER JOIN
											  App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode)
			OR EXISTS (SELECT     Org.tbAddress.AddressCode
						   FROM         Org.tbOrg INNER JOIN
												 App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode INNER JOIN
												 Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode)
			OR EXISTS (SELECT     TOP 1 UserId
							   FROM         Usr.tbUser))
			BEGIN
			UPDATE App.tbOptions Set IsInitialised = 1
			RETURN
			END
		ELSE
			BEGIN
			UPDATE App.tbOptions Set IsInitialised = 0
			RETURN 1
			END
 	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go


ALTER TABLE Cash.tbCode WITH NOCHECK ADD
	IsEnabled SMALLINT NOT NULL CONSTRAINT DF_Cash_tbCode_IsEnabled DEFAULT (1);

CREATE UNIQUE NONCLUSTERED INDEX IX_Cash_tbCode_IsEnabled_Code ON Cash.tbCode (IsEnabled, CashCode);
CREATE UNIQUE NONCLUSTERED INDEX IX_Cash_tbCode_Category_IsEnabled_Code ON Cash.tbCode (CategoryCode, IsEnabled, CashCode);
CREATE UNIQUE NONCLUSTERED INDEX IX_Cash_tbCode_IsEnabled_Description ON Cash.tbCode (IsEnabled, CashDescription);
go

ALTER TABLE Cash.tbCategory WITH NOCHECK ADD
	IsEnabled SMALLINT NOT NULL CONSTRAINT DF_Cash_tbCategory_IsEnabled DEFAULT (1);

CREATE UNIQUE NONCLUSTERED INDEX IX_Cash_tbCategory_IsEnabled_CategoryCode ON Cash.tbCategory (IsEnabled, CategoryCode);
CREATE UNIQUE NONCLUSTERED INDEX IX_Cash_tbCategory_IsEnabled_Category ON Cash.tbCategory (IsEnabled, Category);
go
ALTER TRIGGER [Cash].[Cash_tbCategory_TriggerUpdate] 
   ON  [Cash].[tbCategory]
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(CategoryCode) = 0)
			BEGIN
			DECLARE @Msg NVARCHAR(MAX);
			SELECT @Msg = [Message] FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1)
			ROLLBACK
			END
		ELSE

			IF UPDATE (IsEnabled)
				BEGIN
				UPDATE  Cash.tbCode
				SET     IsEnabled = 0
				FROM        inserted INNER JOIN
										 Cash.tbCode ON inserted.CategoryCode = Cash.tbCode.CategoryCode
				WHERE        (inserted.IsEnabled = 0) AND (Cash.tbCode.IsEnabled <> 0)

				END
			UPDATE Cash.tbCategory
			SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
			FROM Cash.tbCategory INNER JOIN inserted AS i ON tbCategory.CategoryCode = i.CategoryCode;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER VIEW Cash.vwCategoryTrade
AS
	SELECT CategoryCode, Category, CategoryTypeCode, CashModeCode, CashTypeCode, DisplayOrder, IsEnabled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, RowVer
	FROM            Cash.tbCategory
	WHERE        (CategoryTypeCode = 0)
go
ALTER VIEW Cash.vwCategoryBank
AS
	SELECT CategoryCode, Category, CategoryTypeCode, CashModeCode, CashTypeCode, DisplayOrder, IsEnabled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, RowVer
	FROM         Cash.tbCategory
	WHERE     (CashTypeCode = 3) AND (CategoryTypeCode = 0)
go
ALTER VIEW Cash.vwCategoryTotals
AS
	SELECT CategoryCode, Category, CategoryTypeCode, CashModeCode, CashTypeCode, DisplayOrder, IsEnabled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, RowVer
	FROM            Cash.tbCategory
	WHERE       (CategoryTypeCode = 1)
go
ALTER VIEW Cash.vwCategoryTax
AS
	SELECT CategoryCode, Category, CategoryTypeCode, CashModeCode, CashTypeCode, DisplayOrder, IsEnabled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, RowVer
	FROM            Cash.tbCategory
	WHERE      (CashTypeCode = 1) AND (CategoryTypeCode = 0)
go
ALTER  VIEW Cash.vwCategoryBudget
AS
	SELECT CategoryCode, Category, CategoryTypeCode, CashModeCode, CashTypeCode, DisplayOrder, IsEnabled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, RowVer
	FROM            Cash.tbCategory
	WHERE        (CategoryTypeCode = 0) AND (CashTypeCode = 0) AND (IsEnabled <> 0)
go
ALTER VIEW [Cash].[vwCategoryTotalCandidates]
AS
SELECT        Cash.tbCategory.CategoryCode, Cash.tbCategory.Category, Cash.tbCategoryType.CategoryType, Cash.tbType.CashType, Cash.tbMode.CashMode
FROM            Cash.tbCategory INNER JOIN
                         Cash.tbCategoryType ON Cash.tbCategory.CategoryTypeCode = Cash.tbCategoryType.CategoryTypeCode INNER JOIN
                         Cash.tbType ON Cash.tbCategory.CashTypeCode = Cash.tbType.CashTypeCode INNER JOIN
                         Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode
WHERE        (Cash.tbCategory.CashTypeCode < 2) AND (Cash.tbCategory.IsEnabled <> 0);
go

ALTER VIEW [Cash].[vwCodeLookup]
AS
SELECT        Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCategory.Category, Cash.tbMode.CashMode, Cash.tbCode.TaxCode
FROM            Cash.tbCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
                         Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode
WHERE (Cash.tbCode.IsEnabled <> 0) AND (Cash.tbCategory.IsEnabled <> 0);
go
CREATE OR ALTER VIEW [Cash].[vwTransferCodeLookup]
AS
SELECT        Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCategory.Category, Cash.tbMode.CashMode
FROM            Cash.tbCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
                         Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode
WHERE (Cash.tbCode.IsEnabled <> 0) AND (Cash.tbCategory.IsEnabled <> 0) AND (Cash.tbCategory.CashTypeCode = 2);
go
ALTER VIEW [Activity].[vwCandidateCashCodes]
AS
SELECT TOP 100 PERCENT Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCategory.Category
FROM            Cash.tbCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
WHERE        (Cash.tbCategory.CashTypeCode < 2)  AND (Cash.tbCategory.IsEnabled <> 0) AND (Cash.tbCode.IsEnabled <> 0)
ORDER BY Cash.tbCode.CashCode;
go

