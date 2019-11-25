CREATE VIEW Task.vwProfitToDate
AS
	WITH TaskProfitToDate AS 
		(SELECT        MAX(PaymentOn) AS LastPaymentOn
		 FROM            Task.tbTask)
	SELECT TOP (100) PERCENT App.tbYearPeriod.StartOn, App.tbYear.Description + SPACE(1) + App.tbMonth.MonthName AS Description
	FROM            TaskProfitToDate INNER JOIN
							App.tbYearPeriod INNER JOIN
							App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
							App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber ON DATEADD(m, 1, TaskProfitToDate.LastPaymentOn) > App.tbYearPeriod.StartOn
	WHERE        (App.tbYear.CashStatusCode < 4)
	ORDER BY App.tbYearPeriod.StartOn DESC;
GO
CREATE VIEW Org.vwContacts
AS
	WITH ContactCount AS (SELECT        ContactName, COUNT(TaskCode) AS Tasks
                                                   FROM            Task.tbTask
                                                   WHERE        (TaskStatusCode < 3)
                                                   GROUP BY ContactName
                                                   HAVING         (ContactName IS NOT NULL))
    SELECT TOP (100) PERCENT   Org.tbContact.ContactName, Org.tbOrg.AccountCode, ContactCount_1.Tasks, Org.tbContact.PhoneNumber, Org.tbContact.HomeNumber, Org.tbContact.MobileNumber, Org.tbContact.FaxNumber, 
                              Org.tbContact.EmailAddress, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Org.tbStatus.OrganisationStatus, Org.tbContact.NameTitle, Org.tbContact.NickName, Org.tbContact.JobTitle, 
                              Org.tbContact.Department
     FROM            Org.tbOrg INNER JOIN
                              Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode INNER JOIN
                              Org.tbStatus ON Org.tbOrg.OrganisationStatusCode = Org.tbStatus.OrganisationStatusCode INNER JOIN
                              Org.tbContact ON Org.tbOrg.AccountCode = Org.tbContact.AccountCode LEFT OUTER JOIN
                              ContactCount AS ContactCount_1 ON Org.tbContact.ContactName = ContactCount_1.ContactName
     WHERE        (Org.tbOrg.OrganisationStatusCode < 4)
     ORDER BY Org.tbContact.ContactName;
GO
CREATE VIEW App.vwPeriods
AS
	SELECT        TOP (100) PERCENT App.tbYearPeriod.StartOn, App.tbYear.Description + SPACE(1) + App.tbMonth.MonthName AS Description
	FROM            App.tbYearPeriod INNER JOIN
							 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
							 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
	WHERE        (App.tbYearPeriod.StartOn < DATEADD(d, 1, GETDATE())) AND (App.tbYear.CashStatusCode < 4)
	ORDER BY App.tbYearPeriod.StartOn DESC;
GO
CREATE VIEW Usr.vwMenuItemFormMode
AS
	SELECT        OpenMode, OpenModeDescription
	FROM            Usr.tbMenuOpenMode
	WHERE        (OpenMode < 3);
GO
CREATE VIEW Usr.vwMenuItemReportMode
AS
	SELECT        OpenMode, OpenModeDescription
	FROM            Usr.tbMenuOpenMode
	WHERE        (OpenMode > 2) AND (OpenMode < 6);
GO	
CREATE VIEW App.vwActivePeriod
AS
SELECT App.tbYearPeriod.YearNumber, App.tbYearPeriod.StartOn, App.tbYear.Description, App.tbMonth.MonthName, fnActivePeriod.EndOn
FROM            App.tbYear INNER JOIN
                         App.fnActivePeriod() AS fnActivePeriod INNER JOIN
                         App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber ON fnActivePeriod.StartOn = App.tbYearPeriod.StartOn AND fnActivePeriod.YearNumber = App.tbYearPeriod.YearNumber ON 
                         App.tbYear.YearNumber = App.tbYearPeriod.YearNumber;
GO
CREATE VIEW Usr.vwUserMenus
AS
SELECT Usr.tbMenuUser.MenuId
FROM Usr.vwCredentials INNER JOIN Usr.tbMenuUser ON Usr.vwCredentials.UserId = Usr.tbMenuUser.UserId;
GO
CREATE PROCEDURE Usr.spMenuCleanReferences(@MenuId SMALLINT)
AS

	WITH tbFolderRefs AS 
	(	SELECT        MenuId, EntryId, CAST(Argument AS int) AS FolderIdRef
		FROM            Usr.tbMenuEntry
		WHERE        (Command = 1))
	, tbBadRefs AS
	(
		SELECT        tbFolderRefs.EntryId
		FROM            tbFolderRefs LEFT OUTER JOIN
								Usr.tbMenuEntry AS tbMenuEntry ON tbFolderRefs.FolderIdRef = tbMenuEntry.FolderId AND tbFolderRefs.MenuId = tbMenuEntry.MenuId
		WHERE (tbMenuEntry.MenuId = @MenuId) AND (tbMenuEntry.MenuId IS NULL)
	)
	DELETE FROM Usr.tbMenuEntry
	FROM            Usr.tbMenuEntry INNER JOIN
							 tbFolderRefs ON Usr.tbMenuEntry.EntryId = tbFolderRefs.EntryId;

GO
CREATE VIEW Org.vwInvoiceSummary
AS
	WITH ois AS
	(
		SELECT        AccountCode, StartOn, SUM(InvoiceValue) AS PeriodValue
		FROM            Invoice.vwRegister
		GROUP BY AccountCode, StartOn
	), acc AS
	(
		SELECT Org.tbOrg.AccountCode, App.vwPeriods.StartOn
		FROM Org.tbOrg CROSS JOIN App.vwPeriods
	)
	SELECT TOP (100) PERCENT acc.AccountCode, acc.StartOn, ois.PeriodValue 
	FROM ois RIGHT OUTER JOIN acc ON ois.AccountCode = acc.AccountCode AND ois.StartOn = acc.StartOn
	ORDER BY acc.AccountCode, acc.StartOn;
GO
CREATE VIEW Org.vwListAll
AS
	SELECT TOP (100) PERCENT Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbType.CashModeCode
	FROM Org.tbOrg INNER JOIN Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode
	ORDER BY Org.tbOrg.AccountName;
GO

CREATE VIEW Org.vwListActive
AS
	SELECT        TOP (100) PERCENT Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbType.CashModeCode
	FROM            Org.tbOrg INNER JOIN
							 Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode INNER JOIN
							 Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode
	WHERE        (Task.tbTask.TaskStatusCode = 2 OR
							 Task.tbTask.TaskStatusCode = 3) AND (Task.tbTask.CashCode IS NOT NULL)
	GROUP BY Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbType.CashModeCode
	ORDER BY Org.tbOrg.AccountName;
GO
CREATE FUNCTION Invoice.fnEditTasks (@InvoiceNumber nvarchar(20), @AccountCode nvarchar(10))
RETURNS TABLE
AS
	RETURN 
	(		
		WITH InvoiceEditTasks AS 
		(	SELECT        TaskCode
			FROM            Invoice.tbTask
			WHERE        (InvoiceNumber = @InvoiceNumber)
		)
		SELECT TOP (100) PERCENT Task.tbTask.TaskCode, Task.tbTask.ActivityCode, Task.tbStatus.TaskStatus, Usr.tbUser.UserName, Task.tbTask.ActionOn, Task.tbTask.ActionedOn, Task.tbTask.TaskTitle
		FROM            Usr.tbUser INNER JOIN
								Task.tbTask INNER JOIN
								Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode ON Usr.tbUser.UserId = Task.tbTask.ActionById LEFT OUTER JOIN
								InvoiceEditTasks ON Task.tbTask.TaskCode = InvoiceEditTasks.TaskCode
		WHERE        (Task.tbTask.AccountCode = @AccountCode) AND (Task.tbTask.TaskStatusCode = 2 OR
								Task.tbTask.TaskStatusCode = 3) AND (Task.tbTask.CashCode IS NOT NULL) AND (InvoiceEditTasks.TaskCode IS NULL)
		ORDER BY Task.tbTask.ActionOn DESC
	);
GO
CREATE FUNCTION Invoice.fnEditDebitCandidates (@InvoiceNumber nvarchar(20), @AccountCode nvarchar(10))
RETURNS TABLE
AS
	RETURN 
	(		
		WITH InvoiceEditTasks AS 
		(
			SELECT        TaskCode
			FROM            Invoice.tbTask
			WHERE        (InvoiceNumber = @InvoiceNumber)
		)
		SELECT TOP (100) PERCENT tbInvoiceTask.TaskCode, tbInvoiceTask.InvoiceNumber, tbTask.ActivityCode, Invoice.tbStatus.InvoiceStatus, Usr.tbUser.UserName, Invoice.tbInvoice.InvoicedOn, tbInvoiceTask.InvoiceValue, 
								tbTask.TaskTitle
		FROM            Usr.tbUser INNER JOIN
								Invoice.tbInvoice INNER JOIN
								Invoice.tbTask AS tbInvoiceTask ON Invoice.tbInvoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
								Task.tbTask ON tbInvoiceTask.TaskCode = tbTask.TaskCode INNER JOIN
								Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode ON Usr.tbUser.UserId = Invoice.tbInvoice.UserId LEFT OUTER JOIN
								InvoiceEditTasks  ON tbTask.TaskCode = InvoiceEditTasks.TaskCode
		WHERE        (Invoice.tbInvoice.AccountCode = @AccountCode) AND (Invoice.tbInvoice.InvoiceTypeCode = 3) AND (InvoiceEditTasks.TaskCode IS NULL)
		ORDER BY Invoice.tbInvoice.InvoicedOn DESC
	);
GO
CREATE FUNCTION Invoice.fnEditCreditCandidates (@InvoiceNumber nvarchar(20), @AccountCode nvarchar(10))
RETURNS TABLE
AS
	RETURN 
	(		
		WITH InvoiceEditTasks AS 
		(
			SELECT        TaskCode
			FROM            Invoice.tbTask
			WHERE        (InvoiceNumber = @InvoiceNumber)
		)
		SELECT TOP (100) PERCENT tbInvoiceTask.TaskCode, tbInvoiceTask.InvoiceNumber, tbTask.ActivityCode, Invoice.tbStatus.InvoiceStatus, Usr.tbUser.UserName, Invoice.tbInvoice.InvoicedOn, tbInvoiceTask.InvoiceValue, 
								tbTask.TaskTitle
		FROM            Usr.tbUser INNER JOIN
								Invoice.tbInvoice INNER JOIN
								Invoice.tbTask AS tbInvoiceTask ON Invoice.tbInvoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
								Task.tbTask AS tbTask ON tbInvoiceTask.TaskCode = tbTask.TaskCode INNER JOIN
								Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode ON Usr.tbUser.UserId = Invoice.tbInvoice.UserId LEFT OUTER JOIN
								InvoiceEditTasks AS InvoiceEditTasks ON tbTask.TaskCode = InvoiceEditTasks.TaskCode
		WHERE        (Invoice.tbInvoice.AccountCode = @AccountCode) AND (Invoice.tbInvoice.InvoiceTypeCode = 1) AND (InvoiceEditTasks.TaskCode IS NULL)
		ORDER BY Invoice.tbInvoice.InvoicedOn DESC
	);
GO
CREATE VIEW App.vwDocCreditNote
AS
SELECT        TOP (100) PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.Printed, Invoice.tbInvoice.Spooled, Invoice.tbInvoice.InvoiceStatusCode, Usr.tbUser.UserName, Invoice.tbInvoice.AccountCode, 
                         Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, 
                         Org.tbOrg.EmailAddress
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 2)
ORDER BY Invoice.tbInvoice.InvoiceNumber;
GO
CREATE VIEW App.vwDocDebitNote
AS
SELECT        TOP (100) PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.Printed, Invoice.tbInvoice.Spooled, Invoice.tbInvoice.InvoiceStatusCode, Usr.tbUser.UserName, Invoice.tbInvoice.AccountCode, 
                         Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, 
                         Org.tbOrg.EmailAddress
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 4)
ORDER BY Invoice.tbInvoice.InvoiceNumber;
GO
CREATE VIEW App.vwDocPurchaseEnquiry
AS
SELECT        TOP (100) PERCENT Task.vwTasks.TaskCode, Task.vwTasks.ActionOn, Task.vwTasks.ActivityCode, Task.vwTasks.ActionById, Task.vwTasks.BucketId, Task.vwTasks.TaskTitle, Task.vwTasks.AccountCode, 
                         Task.vwTasks.ContactName, Task.vwTasks.TaskNotes, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, 
                         Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, Org.tbAddress.Address AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
                         Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, Task.vwTasks.ActionName, Task.vwTasks.Period, Task.vwTasks.Printed, Task.vwTasks.Spooled
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 1) AND (Task.vwTasks.TaskStatusCode = 1)
ORDER BY Task.vwTasks.ActionOn;
GO
CREATE VIEW App.vwDocPurchaseOrder
AS
SELECT        TOP (100) PERCENT Task.vwTasks.TaskCode, Task.vwTasks.ActionOn, Task.vwTasks.ActivityCode, Task.vwTasks.ActionById, Task.vwTasks.BucketId, Task.vwTasks.TaskTitle, Task.vwTasks.AccountCode, 
                         Task.vwTasks.ContactName, Task.vwTasks.TaskNotes, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, 
                         Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, Org.tbAddress.Address AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
                         Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, Task.vwTasks.ActionName, Task.vwTasks.Period, Task.vwTasks.Printed, Task.vwTasks.Spooled
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 1) AND (Task.vwTasks.TaskStatusCode > 1)
ORDER BY Task.vwTasks.ActionOn;
GO
CREATE VIEW App.vwDocQuotation
AS
SELECT        TOP (100) PERCENT Task.vwTasks.TaskCode, Task.vwTasks.ActionOn, Task.vwTasks.ActivityCode, Task.vwTasks.ActionById, Task.vwTasks.BucketId, Task.vwTasks.TaskTitle, Task.vwTasks.AccountCode, 
                         Task.vwTasks.ContactName, Task.vwTasks.TaskNotes, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, 
                         Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, Org.tbAddress.Address AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
                         Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, Task.vwTasks.ActionName, Task.vwTasks.Period, Task.vwTasks.Printed, Task.vwTasks.Spooled
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 2) AND (Task.vwTasks.TaskStatusCode = 1)
ORDER BY Task.vwTasks.ActionOn;
GO
CREATE VIEW App.vwDocSalesInvoice
AS
SELECT        TOP (100) PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.Printed, Invoice.tbInvoice.Spooled, Invoice.tbInvoice.InvoiceStatusCode, Usr.tbUser.UserName, Invoice.tbInvoice.AccountCode, 
                         Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, 
                         Org.tbOrg.EmailAddress
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 1)
ORDER BY Invoice.tbInvoice.InvoiceNumber;
GO
CREATE VIEW App.vwDocSalesOrder
AS
SELECT        TOP (100) PERCENT Task.vwTasks.TaskCode, Task.vwTasks.ActionOn, Task.vwTasks.ActivityCode, Task.vwTasks.ActionById, Task.vwTasks.BucketId, Task.vwTasks.AccountCode, Task.vwTasks.TaskTitle, 
                         Task.vwTasks.ContactName, Task.vwTasks.TaskNotes, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, 
                         Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, Org.tbAddress.Address AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
                         Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, Task.vwTasks.ActionName, Task.vwTasks.Period, Task.vwTasks.Printed, Task.vwTasks.Spooled
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 2) AND (Task.vwTasks.TaskStatusCode > 1)
ORDER BY Task.vwTasks.ActionOn;
GO
CREATE VIEW App.vwIdentity
AS
SELECT TOP (1) Org.tbOrg.AccountName, Org.tbAddress.Address, Org.tbOrg.PhoneNumber, Org.tbOrg.FaxNumber, Org.tbOrg.EmailAddress, Org.tbOrg.WebSite, Org.tbOrg.Logo, Usr.tbUser.UserName, Usr.tbUser.LogonName, 
                         Usr.tbUser.Avatar, Org.tbOrg.CompanyNumber, Org.tbOrg.VatNumber
FROM            Org.tbOrg INNER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode INNER JOIN
                         App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode CROSS JOIN
                         Usr.vwCredentials INNER JOIN
                         Usr.tbUser ON Usr.vwCredentials.UserId = Usr.tbUser.UserId;
GO
CREATE VIEW App.vwWarehouseOrg
AS
SELECT TOP (100) PERCENT Org.tbOrg.AccountCode, Org.tbDoc.DocumentName, Org.tbOrg.AccountName, Org.tbDoc.DocumentImage, Org.tbDoc.DocumentDescription, Org.tbDoc.InsertedBy, Org.tbDoc.InsertedOn, Org.tbDoc.UpdatedBy, 
                         Org.tbDoc.UpdatedOn
FROM            Org.tbOrg INNER JOIN
                         Org.tbDoc ON Org.tbOrg.AccountCode = Org.tbDoc.AccountCode
ORDER BY Org.tbDoc.AccountCode, Org.tbDoc.DocumentName;
GO
CREATE VIEW App.vwWarehouseTask
AS
SELECT TOP (100) PERCENT Task.tbDoc.TaskCode, Task.tbDoc.DocumentName, Org.tbOrg.AccountName, Task.tbTask.TaskTitle, Task.tbDoc.DocumentImage, Task.tbDoc.DocumentDescription, Task.tbDoc.InsertedBy, Task.tbDoc.InsertedOn, 
                         Task.tbDoc.UpdatedBy, Task.tbDoc.UpdatedOn
FROM            Org.tbOrg INNER JOIN
                         Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode INNER JOIN
                         Task.tbDoc ON Task.tbTask.TaskCode = Task.tbDoc.TaskCode
ORDER BY Task.tbDoc.TaskCode, Task.tbDoc.DocumentName;
GO
CREATE VIEW App.vwYearPeriod
AS
SELECT TOP (100) PERCENT App.tbYear.Description, App.tbMonth.MonthName, App.tbYearPeriod.CashStatusCode, App.tbYearPeriod.YearNumber, App.tbYearPeriod.StartOn
FROM            App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
ORDER BY App.tbYearPeriod.YearNumber, App.tbYearPeriod.StartOn;
GO
CREATE VIEW Cash.vwNominalEntryData
AS
SELECT TOP 100 PERCENT Cash.tbCode.CashCode, Cash.tbPeriod.StartOn, Cash.tbCode.CashDescription, Cash.tbCode.CategoryCode, Cash.tbMode.CashMode, Cash.tbType.CashType, App.tbTaxCode.TaxRate,  
                         Cash.tbPeriod.ForecastValue, Cash.tbPeriod.ForecastTax, Cash.tbPeriod.Note, Cash.tbMode.CashModeCode, Cash.tbPeriod.InvoiceValue, Cash.tbPeriod.InvoiceTax
FROM            Cash.tbType INNER JOIN
                         Cash.tbMode INNER JOIN
                         Cash.tbPeriod INNER JOIN
                         Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode ON Cash.tbMode.CashModeCode = Cash.tbCategory.CashModeCode ON 
                         Cash.tbType.CashTypeCode = Cash.tbCategory.CashTypeCode INNER JOIN
                         App.tbTaxCode ON Cash.tbCode.TaxCode = App.tbTaxCode.TaxCode
ORDER BY Cash.tbCode.CashCode;
GO
CREATE VIEW Cash.vwNominalForecastData
AS
SELECT TOP 100 PERCENT Cash.tbPeriod.CashCode, Cash.tbPeriod.StartOn, App.tbYearPeriod.YearNumber, App.tbMonth.MonthName, Cash.tbPeriod.ForecastValue, Cash.tbPeriod.ForecastTax, Cash.tbPeriod.Note, 
                         Cash.tbCategory.CashModeCode, App.tbTaxCode.TaxRate
FROM            App.tbYearPeriod INNER JOIN
                         Cash.tbPeriod ON App.tbYearPeriod.StartOn = Cash.tbPeriod.StartOn INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                         Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
                         App.tbTaxCode ON Cash.tbCode.TaxCode = App.tbTaxCode.TaxCode
ORDER BY Cash.tbPeriod.StartOn;
GO
CREATE VIEW Cash.vwNominalForecastProjection
AS
SELECT TOP 100 PERCENT Cash.tbCode.CashCode, Cash.tbPeriod.StartOn, App.tbYearPeriod.YearNumber, Cash.tbCode.CategoryCode, Cash.tbCode.CashDescription, Format(App.tbYearPeriod.StartOn, 'yy-MM') AS Period, 
                         Cash.tbPeriod.ForecastValue AS Value
FROM            Cash.tbPeriod INNER JOIN
                         Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode INNER JOIN
                         App.tbYearPeriod ON Cash.tbPeriod.StartOn = App.tbYearPeriod.StartOn
ORDER BY Cash.tbPeriod.StartOn;
GO
CREATE VIEW Cash.vwNominalInvoiceData
AS
SELECT TOP 100 PERCENT Cash.tbPeriod.CashCode, Cash.tbPeriod.StartOn, App.tbYearPeriod.YearNumber, App.tbMonth.MonthName, Cash.tbPeriod.Note, Cash.tbCategory.CashModeCode, App.tbTaxCode.TaxRate, 
                         Cash.tbPeriod.InvoiceValue, Cash.tbPeriod.InvoiceTax
FROM            App.tbYearPeriod INNER JOIN
                         Cash.tbPeriod ON App.tbYearPeriod.StartOn = Cash.tbPeriod.StartOn INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                         Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
                         App.tbTaxCode ON Cash.tbCode.TaxCode = App.tbTaxCode.TaxCode
ORDER BY Cash.tbPeriod.StartOn;
GO
CREATE VIEW Invoice.vwCandidateCredits
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.UserId, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbInvoice.InvoicedOn, 
                         Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaidValue, Invoice.tbInvoice.PaidTaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, Invoice.tbInvoice.Printed, 
                         Invoice.tbInvoice.CollectOn, Invoice.tbInvoice.Spooled, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.InvoiceType
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 1)
ORDER BY Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoicedOn DESC
GO
CREATE VIEW Invoice.vwCandidateDebits
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.UserId, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbInvoice.InvoicedOn, 
                         Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaidValue, Invoice.tbInvoice.PaidTaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, Invoice.tbInvoice.Printed, 
                         Invoice.tbInvoice.CollectOn, Invoice.tbInvoice.Spooled, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.InvoiceType
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 3)
ORDER BY Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoicedOn DESC
GO
CREATE VIEW Invoice.vwCandidateSales
AS
SELECT TOP 100 PERCENT TaskCode, AccountCode, ContactName, ActivityCode, ActionOn, ActionedOn, TaskTitle, Quantity, UnitCharge, TotalCharge, TaskNotes, CashDescription, ActionName, OwnerName, TaskStatus, InsertedBy, 
                         InsertedOn, UpdatedBy, UpdatedOn, TaskStatusCode
FROM            Task.vwTasks
WHERE        (TaskStatusCode = 2 OR
                         TaskStatusCode = 3) AND (CashModeCode = 2) AND (CashCode IS NOT NULL)
ORDER BY ActionOn;
GO
CREATE VIEW Invoice.vwCandidatePurchases
AS
SELECT TOP 100 PERCENT  TaskCode, AccountCode, ContactName, ActivityCode, ActionOn, ActionedOn, Quantity, UnitCharge, TotalCharge, TaskTitle, TaskNotes, CashDescription, ActionName, OwnerName, TaskStatus, InsertedBy, 
                         InsertedOn, UpdatedBy, UpdatedOn, TaskStatusCode
FROM            Task.vwTasks
WHERE        (TaskStatusCode = 2 OR
                         TaskStatusCode = 3) AND (CashModeCode = 1) AND (CashCode IS NOT NULL)
ORDER BY ActionOn;
GO
CREATE VIEW Invoice.vwRegisterCashCodes
AS
SELECT TOP 100 PERCENT StartOn, CashCode, CashDescription, SUM(InvoiceValue) AS TotalInvoiceValue, SUM(TaxValue) AS TotalTaxValue
FROM            Invoice.vwRegisterDetail
GROUP BY StartOn, CashCode, CashDescription
ORDER BY StartOn, CashCode;
GO
CREATE VIEW Invoice.vwRegisterPurchasesOverdue
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
                         Invoice.tbType.InvoiceType, (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) AS UnpaidValue, 
						DATEDIFF(DD, GETDATE(), Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.CollectOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, 
                         Invoice.tbInvoice.Notes
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
WHERE        (Invoice.tbInvoice.InvoiceTypeCode > 2) AND (Invoice.tbInvoice.InvoiceStatusCode < 4)
ORDER BY Invoice.tbInvoice.CollectOn;
GO
CREATE VIEW Invoice.vwRegisterPurchases
AS
SELECT        StartOn, InvoiceNumber, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Notes, Printed, AccountName, UserName, 
                         InvoiceStatus, CashModeCode, InvoiceType, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS UnpaidValue
FROM            Invoice.vwRegister
WHERE        (InvoiceTypeCode > 2);
GO
CREATE VIEW Invoice.vwRegisterPurchaseTasks
AS
SELECT        StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, 
                         PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, InvoiceType, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS UnpaidValue
FROM            Invoice.vwRegisterDetail
WHERE        (InvoiceTypeCode > 2);
GO
CREATE VIEW Invoice.vwRegisterSalesOverdue
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
                         Invoice.tbType.InvoiceType, (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) AS UnpaidValue, DATEDIFF(DD, GETDATE(), 
                         Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.CollectOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, 
                         Invoice.tbInvoice.Notes
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
WHERE        (Invoice.tbInvoice.InvoiceTypeCode < 3) AND (Invoice.tbInvoice.InvoiceStatusCode < 4)
ORDER BY Invoice.tbInvoice.CollectOn;
GO
CREATE VIEW Invoice.vwRegisterSales
AS
SELECT        StartOn, InvoiceNumber, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Notes, Printed, AccountName, UserName, 
                         InvoiceStatus, CashModeCode, InvoiceType, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS UnpaidValue
FROM            Invoice.vwRegister
WHERE        (InvoiceTypeCode < 3);
GO
CREATE VIEW Invoice.vwRegisterSaleTasks
AS
SELECT        StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, 
                         PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, InvoiceType, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS UnpaidValue
FROM            Invoice.vwRegisterDetail
WHERE        (InvoiceTypeCode < 3);
GO
CREATE VIEW Org.vwInvoiceItems
AS
SELECT        Invoice.tbInvoice.AccountCode, Invoice.tbItem.InvoiceNumber, Invoice.tbItem.CashCode, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbStatus.InvoiceStatus, 
                         Cash.tbCode.CashDescription, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbType.InvoiceType, Invoice.tbItem.TaxCode, Invoice.tbItem.TaxValue, 
                         Invoice.tbItem.InvoiceValue, Invoice.tbItem.PaidValue, Invoice.tbItem.PaidTaxValue, Invoice.tbItem.ItemReference
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Invoice.tbItem ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbItem.InvoiceNumber INNER JOIN
                         Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode
WHERE        (Invoice.tbInvoice.InvoiceStatusCode > 1);
GO
CREATE VIEW Org.vwPurchaseInvoices
AS
SELECT        Invoice.tbInvoice.AccountCode, tbInvoiceTask.InvoiceNumber, tbInvoiceTask.TaskCode, Task.tbTask.ContactName, Invoice.tbInvoice.InvoicedOn, tbInvoiceTask.Quantity, tbInvoiceTask.InvoiceValue, 
                         tbInvoiceTask.TaxValue, tbInvoiceTask.CashCode, tbInvoiceTask.TaxCode, Invoice.tbStatus.InvoiceStatus, Task.tbTask.TaskNotes, Cash.tbCode.CashDescription, Invoice.tbInvoice.InvoiceStatusCode, 
                         Task.tbTask.TaskTitle, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbType.InvoiceType
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbTask AS tbInvoiceTask ON Invoice.tbInvoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
                         Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Cash.tbCode ON tbInvoiceTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE        (Invoice.tbInvoice.InvoiceStatusCode > 1) AND (Invoice.tbInvoice.InvoiceTypeCode > 2);
GO
CREATE VIEW Org.vwSalesInvoices
AS
SELECT        Invoice.tbInvoice.AccountCode, tbInvoiceTask.InvoiceNumber, tbInvoiceTask.TaskCode, Task.tbTask.ContactName, Invoice.tbInvoice.InvoicedOn, tbInvoiceTask.Quantity, tbInvoiceTask.InvoiceValue, 
                         tbInvoiceTask.TaxValue, tbInvoiceTask.CashCode, tbInvoiceTask.TaxCode, Invoice.tbStatus.InvoiceStatus, Task.tbTask.TaskNotes, Cash.tbCode.CashDescription, Invoice.tbInvoice.InvoiceStatusCode, 
                         Task.tbTask.TaskTitle, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbType.InvoiceType, tbInvoiceTask.PaidValue, tbInvoiceTask.PaidTaxValue
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbTask AS tbInvoiceTask ON Invoice.tbInvoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
                         Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Cash.tbCode ON tbInvoiceTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE        (Invoice.tbInvoice.InvoiceStatusCode > 1) AND (Invoice.tbInvoice.InvoiceTypeCode < 3);
GO
CREATE VIEW Org.vwPurchases
AS
SELECT        AccountCode, TaskCode, UserId, ContactName, ActivityCode, TaskTitle, TaskStatusCode, ActionById, ActionOn, ActionedOn, PaymentOn, SecondReference, TaskNotes, TaxCode, Quantity, UnitCharge, TotalCharge, 
                         AddressCodeFrom, AddressCodeTo, Printed, Spooled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, Period, BucketId, TaskStatus, CashCode, CashDescription, OwnerName, ActionName, AccountName, 
                         OrganisationStatus, OrganisationType, CashModeCode
FROM            Task.vwTasks
WHERE        (CashModeCode = 1) AND (CashCode IS NOT NULL);
GO
CREATE VIEW Org.vwSales
AS
SELECT        AccountCode, TaskCode, UserId, ContactName, ActivityCode, TaskTitle, TaskStatusCode, ActionById, ActionOn, ActionedOn, PaymentOn, SecondReference, TaskNotes, TaxCode, Quantity, UnitCharge, TotalCharge, 
                         AddressCodeFrom, AddressCodeTo, Printed, Spooled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, Period, BucketId, TaskStatus, CashCode, CashDescription, OwnerName, ActionName, AccountName, 
                         OrganisationStatus, OrganisationType, CashModeCode
FROM            Task.vwTasks
WHERE        (CashModeCode = 2) AND (CashCode IS NOT NULL);
GO
CREATE VIEW Org.vwPayments
AS
SELECT        Org.tbPayment.AccountCode, Org.tbPayment.PaymentCode, Org.tbPayment.UserId, Org.tbPayment.PaymentStatusCode, Org.tbPayment.CashAccountCode, Org.tbPayment.CashCode, Org.tbPayment.TaxCode, 
                         Org.tbPayment.PaidOn, Org.tbPayment.PaidInValue, Org.tbPayment.PaidOutValue, Org.tbPayment.TaxInValue, Org.tbPayment.TaxOutValue, Org.tbPayment.PaymentReference, Org.tbPayment.InsertedBy, 
                         Org.tbPayment.InsertedOn, Org.tbPayment.UpdatedBy, Org.tbPayment.UpdatedOn, Usr.tbUser.UserName, App.tbTaxCode.TaxDescription, Org.tbAccount.CashAccountName, Cash.tbCode.CashDescription
FROM            Org.tbPayment INNER JOIN
                         Usr.tbUser ON Org.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
                         Org.tbAccount ON Org.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
                         Cash.tbCode ON Org.tbPayment.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
                         App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode
WHERE        (Org.tbPayment.PaymentStatusCode = 2);
GO
CREATE VIEW Org.vwCashAccounts
AS
SELECT        Org.tbAccount.CashAccountCode, Org.tbAccount.CashAccountName, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Org.tbAccount.OpeningBalance, Org.tbAccount.CurrentBalance, Org.tbAccount.SortCode, 
                         Org.tbAccount.AccountNumber, Org.tbAccount.AccountClosed
FROM            Org.tbOrg INNER JOIN
                         Org.tbAccount ON Org.tbOrg.AccountCode = Org.tbAccount.AccountCode INNER JOIN
                         Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode;
GO
CREATE VIEW Org.vwCashAccountsLive
AS
SELECT        Org.tbAccount.CashAccountCode, Org.tbAccount.CashAccountName
FROM            Org.tbAccount INNER JOIN
                         Org.tbOrg ON Org.tbAccount.AccountCode = Org.tbOrg.AccountCode
WHERE        (Org.tbAccount.AccountClosed = 0);
GO
CREATE VIEW Org.vwPaymentsUnposted
AS
SELECT        PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, TaxInValue, TaxOutValue, PaymentReference, InsertedBy, InsertedOn, 
                         UpdatedBy, UpdatedOn
FROM            Org.tbPayment
WHERE        (PaymentStatusCode = 1);
GO
CREATE VIEW Task.vwEditFlow
AS
SELECT        Task.tbFlow.ParentTaskCode, Task.tbFlow.StepNumber, Task.tbFlow.UsedOnQuantity, Task.tbTask.ContactName, Task.tbTask.TaskTitle, Task.tbTask.TaskNotes, Task.tbFlow.OffsetDays, Task.tbFlow.InsertedBy, 
                         Task.tbFlow.InsertedOn, Task.tbFlow.UpdatedBy AS TaskFlowUpdatedBy, Task.tbFlow.UpdatedOn AS TaskFlowUpdatedOn, Task.tbTask.AccountCode, Task.tbTask.ActivityCode, Task.tbTask.TaskStatusCode, 
                         Task.tbTask.ActionById, Task.tbTask.ActionOn, Task.tbTask.UpdatedBy AS TaskUpdatedBy, Task.tbTask.UpdatedOn AS TaskUpdatedOn
FROM            Task.tbFlow INNER JOIN
                         Task.tbTask ON Task.tbFlow.ChildTaskCode = Task.tbTask.TaskCode;
GO
CREATE VIEW Task.vwEdit
AS
SELECT        Task.tbTask.TaskCode, Task.tbTask.UserId, Task.tbTask.AccountCode, Task.tbTask.TaskTitle, Task.tbTask.ContactName, Task.tbTask.ActivityCode, Task.tbTask.TaskStatusCode, Task.tbTask.ActionById, 
                         Task.tbTask.ActionOn, Task.tbTask.ActionedOn, Task.tbTask.TaskNotes, Task.tbTask.Quantity, Task.tbTask.CashCode, Task.tbTask.TaxCode, Task.tbTask.UnitCharge, Task.tbTask.TotalCharge, 
                         Task.tbTask.AddressCodeFrom, Task.tbTask.AddressCodeTo, Task.tbTask.Printed, Task.tbTask.InsertedBy, Task.tbTask.InsertedOn, Task.tbTask.UpdatedBy, Task.tbTask.UpdatedOn, Task.tbTask.PaymentOn, 
                         Task.tbTask.SecondReference, Task.tbTask.Spooled, Activity.tbActivity.UnitOfMeasure, Task.tbStatus.TaskStatus
FROM            Task.tbTask INNER JOIN
                         Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode INNER JOIN
                         Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode;
GO
CREATE VIEW Task.vwFlow
AS
SELECT        Task.tbFlow.ParentTaskCode, Task.tbFlow.StepNumber, Task.tbTask.TaskCode, Task.tbTask.ActivityCode, Task.tbTask.TaskTitle, Task.tbTask.TaskNotes, Task.tbStatus.TaskStatus, Task.tbTask.ActionOn, 
                         Task.tbTask.Quantity, Task.tbTask.ActionedOn, Org.tbOrg.AccountCode, Usr.tbUser.UserName AS Owner, tbUser_1.UserName AS ActionBy, Org.tbOrg.AccountName, Task.tbTask.UnitCharge, 
                         Task.tbTask.TotalCharge, Task.tbTask.InsertedBy, Task.tbTask.InsertedOn, Task.tbTask.UpdatedBy, Task.tbTask.UpdatedOn, Task.tbTask.TaskStatusCode
FROM            Usr.tbUser AS tbUser_1 INNER JOIN
                         Task.tbTask INNER JOIN
                         Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
                         Usr.tbUser ON Task.tbTask.UserId = Usr.tbUser.UserId INNER JOIN
                         Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode ON tbUser_1.UserId = Task.tbTask.ActionById INNER JOIN
                         Task.tbFlow ON Task.tbTask.TaskCode = Task.tbFlow.ChildTaskCode;
GO
CREATE VIEW Task.vwActiveData
AS
SELECT        TaskCode, UserId, AccountCode, ContactName, ActivityCode, TaskTitle, TaskStatusCode, ActionById, ActionOn, ActionedOn, PaymentOn, SecondReference, TaskNotes, TaxCode, Quantity, UnitCharge, TotalCharge, 
                         AddressCodeFrom, AddressCodeTo, Printed, Spooled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, Period, BucketId, TaskStatus, CashCode, CashDescription, OwnerName, ActionName, AccountName, 
                         OrganisationStatus, OrganisationType, CashModeCode
FROM            Task.vwTasks
WHERE        (TaskStatusCode < 3);
GO
CREATE VIEW Task.vwPurchases
AS
SELECT        Task.vwTasks.TaskCode, Task.vwTasks.ActivityCode, Task.vwTasks.TaskStatusCode, Task.vwTasks.ActionOn, Task.vwTasks.ActionById, Task.vwTasks.TaskTitle, Task.vwTasks.Period, Task.vwTasks.BucketId, 
                         Task.vwTasks.AccountCode, Task.vwTasks.ContactName, Task.vwTasks.TaskStatus, Task.vwTasks.TaskNotes, Task.vwTasks.ActionedOn, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, 
                         Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, 
                         Org.tbAddress.Address AS ToAddress, Task.vwTasks.Printed, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, 
                         Task.vwTasks.ActionName, Task.vwTasks.SecondReference
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 1);
GO
CREATE VIEW Task.vwSales
AS
SELECT        Task.vwTasks.TaskCode, Task.vwTasks.ActivityCode, Task.vwTasks.TaskStatusCode, Task.vwTasks.ActionOn, Task.vwTasks.ActionById, Task.vwTasks.TaskTitle, Task.vwTasks.Period, Task.vwTasks.BucketId, 
                         Task.vwTasks.AccountCode, Task.vwTasks.ContactName, Task.vwTasks.TaskStatus, Task.vwTasks.TaskNotes, Task.vwTasks.ActionedOn, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, 
                         Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, 
                         Org.tbAddress.Address AS ToAddress, Task.vwTasks.Printed, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, 
                         Task.vwTasks.ActionName, Task.vwTasks.SecondReference
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 2);
GO
CREATE VIEW Org.vwCompanyHeader
AS
SELECT        TOP (1) Org.tbOrg.AccountName AS CompanyName, Org.tbAddress.Address AS CompanyAddress, Org.tbOrg.PhoneNumber AS CompanyPhoneNumber, Org.tbOrg.FaxNumber AS CompanyFaxNumber, 
                         Org.tbOrg.EmailAddress AS CompanyEmailAddress, Org.tbOrg.WebSite AS CompanyWebsite, Org.tbOrg.CompanyNumber, Org.tbOrg.VatNumber
FROM            Org.tbOrg INNER JOIN
                         App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode LEFT OUTER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode;
GO
CREATE VIEW Org.vwCompanyLogo
AS
SELECT        TOP (1) Org.tbOrg.Logo
FROM            Org.tbOrg INNER JOIN
                         App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode;
GO
CREATE VIEW App.vwPeriodEndListing
AS
SELECT        TOP (100) PERCENT App.tbYear.YearNumber, App.tbYear.Description, App.tbYear.InsertedBy AS YearInsertedBy, App.tbYear.InsertedOn AS YearInsertedOn, App.tbYearPeriod.StartOn, App.tbMonth.MonthName, 
                         App.tbYearPeriod.InsertedBy AS PeriodInsertedBy, App.tbYearPeriod.InsertedOn AS PeriodInsertedOn, Cash.tbStatus.CashStatus
FROM            Cash.tbStatus INNER JOIN
                         App.tbYear INNER JOIN
                         App.tbYearPeriod ON App.tbYear.YearNumber = App.tbYearPeriod.YearNumber INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber ON Cash.tbStatus.CashStatusCode = App.tbYearPeriod.CashStatusCode
ORDER BY App.tbYearPeriod.StartOn;
GO
CREATE VIEW Cash.vwAccountStatementListing
AS
SELECT        App.tbYear.YearNumber, Org.tbOrg.AccountName AS Bank, Org.tbAccount.CashAccountCode, Org.tbAccount.CashAccountName, Org.tbAccount.SortCode, Org.tbAccount.AccountNumber, CONCAT(App.tbYear.Description, SPACE(1), 
                         App.tbMonth.MonthName) AS PeriodName, Cash.vwAccountStatements.StartOn, Cash.vwAccountStatements.EntryNumber, Cash.vwAccountStatements.PaymentCode, Cash.vwAccountStatements.PaidOn, 
                         Cash.vwAccountStatements.AccountName, Cash.vwAccountStatements.PaymentReference, Cash.vwAccountStatements.PaidInValue, Cash.vwAccountStatements.PaidOutValue, 
                         Cash.vwAccountStatements.PaidBalance, Cash.vwAccountStatements.TaxInValue, Cash.vwAccountStatements.TaxOutValue, Cash.vwAccountStatements.TaxedBalance, Cash.vwAccountStatements.CashCode, 
                         Cash.vwAccountStatements.CashDescription, Cash.vwAccountStatements.TaxDescription, Cash.vwAccountStatements.UserName, Cash.vwAccountStatements.AccountCode, 
                         Cash.vwAccountStatements.TaxCode
FROM            App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                         Cash.vwAccountStatements INNER JOIN
                         Org.tbAccount ON Cash.vwAccountStatements.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
                         Org.tbOrg ON Org.tbAccount.AccountCode = Org.tbOrg.AccountCode ON App.tbYearPeriod.StartOn = Cash.vwAccountStatements.StartOn INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber;
GO
CREATE VIEW Invoice.vwVatDetailListing
AS
SELECT        App.tbYearPeriod.YearNumber, App.tbYear.Description, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, Invoice.vwVatSummary.StartOn, 
                         Invoice.vwVatSummary.TaxCode, Invoice.vwVatSummary.HomeSales, Invoice.vwVatSummary.HomePurchases, Invoice.vwVatSummary.ExportSales, Invoice.vwVatSummary.ExportPurchases, 
                         Invoice.vwVatSummary.HomeSalesVat, Invoice.vwVatSummary.HomePurchasesVat, Invoice.vwVatSummary.ExportSalesVat, Invoice.vwVatSummary.ExportPurchasesVat, Invoice.vwVatSummary.VatDue                         
FROM            Invoice.vwVatSummary INNER JOIN
                         App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber ON Invoice.vwVatSummary.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber;
GO

CREATE VIEW Invoice.vwAgedDebtPurchases
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
                         Invoice.tbType.InvoiceType, (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) AS UnpaidValue, DATEDIFF(DD, GETDATE(), 
                         Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.CollectOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, 
                         Invoice.tbInvoice.Notes
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
WHERE        (Invoice.tbInvoice.InvoiceTypeCode > 2) AND (Invoice.tbInvoice.InvoiceStatusCode < 4)
ORDER BY Invoice.tbInvoice.CollectOn;
GO
CREATE VIEW Invoice.vwAgedDebtSales
AS
SELECT TOP 100 PERCENT  Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
                         Invoice.tbType.InvoiceType, (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) AS UnpaidValue, DATEDIFF(DD, GETDATE(), 
                         Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.CollectOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, 
                         Invoice.tbInvoice.Notes
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
WHERE        (Invoice.tbInvoice.InvoiceTypeCode < 3) AND (Invoice.tbInvoice.InvoiceStatusCode < 4)
ORDER BY Invoice.tbInvoice.CollectOn;
GO
CREATE VIEW Invoice.vwCreditNoteSpool
AS
SELECT        credit_note.InvoiceNumber, credit_note.Printed, Invoice.tbType.InvoiceType, credit_note.InvoiceStatusCode, Usr.tbUser.UserName, credit_note.AccountCode, Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, 
                         credit_note.InvoicedOn, credit_note.InvoiceValue AS InvoiceValueTotal, credit_note.TaxValue AS TaxValueTotal, credit_note.PaymentTerms, credit_note.Notes, Org.tbOrg.EmailAddress, 
                         Org.tbAddress.Address AS InvoiceAddress, tbInvoiceTask.TaskCode, Task.tbTask.TaskTitle, Task.tbTask.ActionedOn, tbInvoiceTask.Quantity, Activity.tbActivity.UnitOfMeasure, tbInvoiceTask.TaxCode, 
                         tbInvoiceTask.InvoiceValue, tbInvoiceTask.TaxValue
FROM            Invoice.tbInvoice AS credit_note INNER JOIN
                         Invoice.tbStatus ON credit_note.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON credit_note.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON credit_note.UserId = Usr.tbUser.UserId LEFT OUTER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode INNER JOIN
                         Invoice.tbTask AS tbInvoiceTask ON credit_note.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
                         Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode INNER JOIN
                         Invoice.tbType ON credit_note.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE credit_note.InvoiceTypeCode = 2 
	AND EXISTS (SELECT * FROM App.tbDocSpool AS doc WHERE DocTypeCode = 6 AND UserName = SUSER_SNAME() AND credit_note.InvoiceNumber = doc.DocumentNumber);
GO
CREATE VIEW Invoice.vwDebitNoteSpool
AS
SELECT        debit_note.Printed, debit_note.InvoiceNumber, Invoice.tbType.InvoiceType, debit_note.InvoiceStatusCode, Usr.tbUser.UserName, debit_note.AccountCode, Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, 
                         debit_note.InvoicedOn, debit_note.InvoiceValue AS InvoiceValueTotal, debit_note.TaxValue AS TaxValueTotal, debit_note.PaymentTerms, debit_note.Notes, Org.tbOrg.EmailAddress, 
                         Org.tbAddress.Address AS InvoiceAddress, tbInvoiceTask.TaskCode, Task.tbTask.TaskTitle, Task.tbTask.ActionedOn, tbInvoiceTask.Quantity, Activity.tbActivity.UnitOfMeasure, tbInvoiceTask.TaxCode, 
                         tbInvoiceTask.InvoiceValue, tbInvoiceTask.TaxValue
FROM            Invoice.tbInvoice AS debit_note INNER JOIN
                         Invoice.tbStatus ON debit_note.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON debit_note.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON debit_note.UserId = Usr.tbUser.UserId LEFT OUTER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode INNER JOIN
                         Invoice.tbTask AS tbInvoiceTask ON debit_note.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
                         Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode INNER JOIN
                         Invoice.tbType ON debit_note.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE debit_note.InvoiceTypeCode = 4 AND
	EXISTS (SELECT * FROM App.tbDocSpool AS doc WHERE DocTypeCode = 7 AND UserName = SUSER_SNAME() AND debit_note.InvoiceNumber = doc.DocumentNumber);
GO
CREATE VIEW Invoice.vwHistoryCashCodes
AS
SELECT        App.tbYearPeriod.YearNumber, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS Period, Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.CashCode, 
                         Invoice.vwRegisterDetail.CashDescription, SUM(Invoice.vwRegisterDetail.InvoiceValue) AS TotalInvoiceValue, SUM(Invoice.vwRegisterDetail.TaxValue) AS TotalTaxValue
FROM            Invoice.vwRegisterDetail INNER JOIN
                         App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber ON Invoice.vwRegisterDetail.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
GROUP BY App.tbYearPeriod.YearNumber, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)), Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.CashCode, 
                         Invoice.vwRegisterDetail.CashDescription;
GO
CREATE VIEW Invoice.vwHistoryPurchaseItems
AS
SELECT        CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, App.tbYearPeriod.YearNumber, Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.InvoiceNumber, 
                         Invoice.vwRegisterDetail.TaskCode, Invoice.vwRegisterDetail.CashCode, Invoice.vwRegisterDetail.CashDescription, Invoice.vwRegisterDetail.TaxCode, Invoice.vwRegisterDetail.TaxDescription, 
                         Invoice.vwRegisterDetail.AccountCode, Invoice.vwRegisterDetail.InvoiceTypeCode, Invoice.vwRegisterDetail.InvoiceStatusCode, Invoice.vwRegisterDetail.InvoicedOn, Invoice.vwRegisterDetail.InvoiceValue, 
                         Invoice.vwRegisterDetail.TaxValue, Invoice.vwRegisterDetail.PaidValue, Invoice.vwRegisterDetail.PaidTaxValue, Invoice.vwRegisterDetail.PaymentTerms, Invoice.vwRegisterDetail.Printed, 
                         Invoice.vwRegisterDetail.AccountName, Invoice.vwRegisterDetail.UserName, Invoice.vwRegisterDetail.InvoiceStatus, Invoice.vwRegisterDetail.CashModeCode, Invoice.vwRegisterDetail.InvoiceType, 
                         Invoice.vwRegisterDetail.UnpaidValue
FROM            Invoice.vwRegisterDetail INNER JOIN
                         App.tbYearPeriod ON Invoice.vwRegisterDetail.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
WHERE        (Invoice.vwRegisterDetail.InvoiceTypeCode > 2);
GO
CREATE VIEW Invoice.vwHistoryPurchases
AS
SELECT        App.tbYearPeriod.YearNumber, App.tbYear.Description, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, Invoice.vwRegister.StartOn, 
                         Invoice.vwRegister.InvoiceNumber, Invoice.vwRegister.AccountCode, Invoice.vwRegister.InvoiceTypeCode, Invoice.vwRegister.InvoiceStatusCode, Invoice.vwRegister.InvoicedOn, 
                         Invoice.vwRegister.InvoiceValue, Invoice.vwRegister.TaxValue, Invoice.vwRegister.PaidValue, Invoice.vwRegister.PaidTaxValue, Invoice.vwRegister.PaymentTerms, Invoice.vwRegister.Notes, 
                         Invoice.vwRegister.Printed, Invoice.vwRegister.AccountName, Invoice.vwRegister.UserName, Invoice.vwRegister.InvoiceStatus, Invoice.vwRegister.CashModeCode, Invoice.vwRegister.InvoiceType, 
                         (Invoice.vwRegister.InvoiceValue + Invoice.vwRegister.TaxValue) - (Invoice.vwRegister.PaidValue + Invoice.vwRegister.PaidTaxValue) AS UnpaidValue
FROM            App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                         Invoice.vwRegister ON App.tbYearPeriod.StartOn = Invoice.vwRegister.StartOn
WHERE        (Invoice.vwRegister.InvoiceTypeCode > 2);
GO
CREATE VIEW Invoice.vwHistorySalesItems
AS
SELECT        App.tbYearPeriod.YearNumber, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.InvoiceNumber, 
                         (Invoice.vwRegisterDetail.InvoiceValue + Invoice.vwRegisterDetail.TaxValue) - (Invoice.vwRegisterDetail.PaidValue + Invoice.vwRegisterDetail.PaidTaxValue) AS UnpaidValue, Invoice.vwRegisterDetail.TaskCode, 
                         Invoice.vwRegisterDetail.CashCode, Invoice.vwRegisterDetail.CashDescription, Invoice.vwRegisterDetail.TaxCode, Invoice.vwRegisterDetail.AccountCode, Invoice.vwRegisterDetail.InvoicedOn, 
                         Invoice.vwRegisterDetail.InvoiceValue, Invoice.vwRegisterDetail.TaxValue, Invoice.vwRegisterDetail.PaidValue, Invoice.vwRegisterDetail.PaidTaxValue, Invoice.vwRegisterDetail.PaymentTerms, 
                         Invoice.vwRegisterDetail.AccountName, Invoice.vwRegisterDetail.InvoiceStatus, Invoice.vwRegisterDetail.InvoiceType, Invoice.vwRegisterDetail.InvoiceTypeCode, 
                         Invoice.vwRegisterDetail.InvoiceStatusCode
FROM            Invoice.vwRegisterDetail INNER JOIN
                         App.tbYearPeriod ON Invoice.vwRegisterDetail.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
WHERE        (Invoice.vwRegisterDetail.InvoiceTypeCode < 3);
GO
CREATE VIEW Invoice.vwHistorySales
AS
SELECT        App.tbYearPeriod.YearNumber, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, Invoice.vwRegister.StartOn, 
                         Invoice.vwRegister.InvoiceNumber, Invoice.vwRegister.AccountCode, Invoice.vwRegister.InvoiceTypeCode, Invoice.vwRegister.InvoiceStatusCode, Invoice.vwRegister.InvoicedOn, 
                         Invoice.vwRegister.InvoiceValue, Invoice.vwRegister.TaxValue, Invoice.vwRegister.PaidValue, Invoice.vwRegister.PaidTaxValue, Invoice.vwRegister.PaymentTerms, Invoice.vwRegister.Notes, 
                         Invoice.vwRegister.Printed, Invoice.vwRegister.AccountName, Invoice.vwRegister.UserName, Invoice.vwRegister.InvoiceStatus, Invoice.vwRegister.CashModeCode, Invoice.vwRegister.InvoiceType, 
                         (Invoice.vwRegister.InvoiceValue + Invoice.vwRegister.TaxValue) - (Invoice.vwRegister.PaidValue + Invoice.vwRegister.PaidTaxValue) AS UnpaidValue
FROM            App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                         Invoice.vwRegister ON App.tbYearPeriod.StartOn = Invoice.vwRegister.StartOn
WHERE        (Invoice.vwRegister.InvoiceTypeCode < 3);
GO
CREATE VIEW Invoice.vwItems
AS
SELECT        Invoice.tbItem.InvoiceNumber, Invoice.tbItem.CashCode, Cash.tbCode.CashDescription, Invoice.tbItem.TaxCode, Invoice.tbItem.TaxValue, Invoice.tbItem.InvoiceValue, Invoice.tbItem.ItemReference, 
                         Invoice.tbInvoice.InvoicedOn
FROM            Invoice.tbItem INNER JOIN
                         Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
                         Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode;
GO
CREATE VIEW Invoice.vwSalesInvoiceSpool
AS
SELECT        sales_invoice.InvoiceNumber, Invoice.tbType.InvoiceType, sales_invoice.InvoiceStatusCode, Usr.tbUser.UserName, sales_invoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, 
                         sales_invoice.InvoicedOn, sales_invoice.InvoiceValue AS InvoiceValueTotal, sales_invoice.TaxValue AS TaxValueTotal, sales_invoice.PaymentTerms, sales_invoice.CollectOn, sales_invoice.Notes, 
                         Org.tbOrg.EmailAddress, Org.tbAddress.Address AS InvoiceAddress, tbInvoiceTask.TaskCode, Task.tbTask.TaskTitle, Task.tbTask.ActionedOn, tbInvoiceTask.Quantity, Activity.tbActivity.UnitOfMeasure, 
                         tbInvoiceTask.TaxCode, tbInvoiceTask.InvoiceValue, tbInvoiceTask.TaxValue
FROM            Invoice.tbInvoice AS sales_invoice INNER JOIN
                         Invoice.tbStatus ON sales_invoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON sales_invoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON sales_invoice.UserId = Usr.tbUser.UserId LEFT OUTER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode INNER JOIN
                         Invoice.tbTask AS tbInvoiceTask ON sales_invoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
                         Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode INNER JOIN
                         Invoice.tbType ON sales_invoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE sales_invoice.InvoiceTypeCode = 1 AND
	 EXISTS (SELECT * FROM App.tbDocSpool AS doc WHERE DocTypeCode = 5 AND UserName = SUSER_SNAME() AND sales_invoice.InvoiceNumber = doc.DocumentNumber);
GO
CREATE VIEW Invoice.vwSalesInvoiceSpoolByActivity
AS
WITH invoice AS 
(
	SELECT        sales_invoice.InvoiceNumber, Invoice.tbType.InvoiceType, sales_invoice.InvoiceStatusCode, Usr.tbUser.UserName, sales_invoice.AccountCode, Org.tbOrg.AccountName, 
							Invoice.tbStatus.InvoiceStatus, sales_invoice.InvoicedOn, sales_invoice.InvoiceValue AS InvoiceValueTotal, sales_invoice.TaxValue AS TaxValueTotal, sales_invoice.PaymentTerms, 
							Org.tbOrg.EmailAddress, Org.tbOrg.AddressCode, Activity.tbActivity.ActivityCode, Activity.tbActivity.UnitOfMeasure, MIN(Task.tbTask.ActionedOn) AS FirstActionedOn, 
							SUM(tbInvoiceTask.Quantity) AS ActivityQuantity, tbInvoiceTask.TaxCode, SUM(tbInvoiceTask.InvoiceValue) AS ActivityInvoiceValue, SUM(tbInvoiceTask.TaxValue) AS ActivityTaxValue
	FROM            Invoice.tbInvoice AS sales_invoice INNER JOIN
							Invoice.tbStatus ON sales_invoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							Org.tbOrg ON sales_invoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							Usr.tbUser ON sales_invoice.UserId = Usr.tbUser.UserId INNER JOIN
							Invoice.tbTask AS tbInvoiceTask ON sales_invoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
							Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
							Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode INNER JOIN
							Invoice.tbType ON sales_invoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	WHERE        EXISTS
								(SELECT        UserName, DocTypeCode, DocumentNumber, SpooledOn
									FROM            App.tbDocSpool AS doc
									WHERE        (DocTypeCode = 5) AND (UserName = SUSER_SNAME()) AND (sales_invoice.InvoiceNumber = DocumentNumber))
	GROUP BY sales_invoice.InvoiceNumber, Invoice.tbType.InvoiceType, sales_invoice.InvoiceStatusCode, Usr.tbUser.UserName, sales_invoice.AccountCode, Org.tbOrg.AccountName, 
							Invoice.tbStatus.InvoiceStatus, sales_invoice.InvoicedOn, sales_invoice.InvoiceValue, sales_invoice.TaxValue, sales_invoice.PaymentTerms, Org.tbOrg.EmailAddress, Org.tbOrg.AddressCode, 
							Activity.tbActivity.ActivityCode, Activity.tbActivity.UnitOfMeasure, tbInvoiceTask.TaxCode
)
SELECT        invoice_1.InvoiceNumber, invoice_1.InvoiceType, invoice_1.InvoiceStatusCode, invoice_1.UserName, invoice_1.AccountCode, invoice_1.AccountName, invoice_1.InvoiceStatus, invoice_1.InvoicedOn, 
                        Invoice.tbInvoice.Notes, Org.tbAddress.Address AS InvoiceAddress, invoice_1.InvoiceValueTotal, invoice_1.TaxValueTotal, invoice_1.PaymentTerms, invoice_1.EmailAddress, invoice_1.AddressCode, 
                        invoice_1.ActivityCode, invoice_1.UnitOfMeasure, invoice_1.FirstActionedOn, invoice_1.ActivityQuantity, invoice_1.TaxCode, invoice_1.ActivityInvoiceValue, invoice_1.ActivityTaxValue
FROM            invoice AS invoice_1 INNER JOIN
                        Invoice.tbInvoice ON invoice_1.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber LEFT OUTER JOIN
                        Org.tbAddress ON invoice_1.AddressCode = Org.tbAddress.AddressCode;
GO
CREATE VIEW Org.vwPaymentsListing
AS
SELECT        TOP (100) PERCENT Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Org.tbStatus.OrganisationStatus, Org.tbPayment.PaymentCode, Usr.tbUser.UserName, 
                         App.tbTaxCode.TaxDescription AS PaymentTaxDescription, Org.tbAccount.CashAccountName, Cash.tbCode.CashDescription, Org.tbPayment.UserId, Org.tbPayment.CashAccountCode, Org.tbPayment.CashCode, 
                         Org.tbPayment.TaxCode, CONCAT(YEAR(Org.tbPayment.PaidOn), Format(MONTH(Org.tbPayment.PaidOn), '00')) AS Period, Org.tbPayment.PaidOn, Org.tbPayment.PaidInValue, Org.tbPayment.PaidOutValue, 
                         Org.tbPayment.TaxInValue, Org.tbPayment.TaxOutValue, Org.tbPayment.InsertedBy, Org.tbPayment.InsertedOn, Org.tbPayment.UpdatedBy, Org.tbPayment.UpdatedOn, Org.tbPayment.PaymentReference
FROM            Org.tbPayment INNER JOIN
                         Usr.tbUser ON Org.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
                         Org.tbAccount ON Org.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
                         Cash.tbCode ON Org.tbPayment.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
                         App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
                         Org.tbOrg ON Org.tbPayment.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode INNER JOIN
                         Org.tbStatus ON Org.tbOrg.OrganisationStatusCode = Org.tbStatus.OrganisationStatusCode
WHERE        (Org.tbPayment.PaymentStatusCode = 2) 
ORDER BY Org.tbPayment.AccountCode, Org.tbPayment.PaidOn DESC;
GO
CREATE VIEW Org.vwStatusReport
AS
SELECT        Org.vwDatasheet.AccountCode, Org.vwDatasheet.AccountName, Org.vwDatasheet.OrganisationType, Org.vwDatasheet.OrganisationStatus, Org.vwDatasheet.TaxDescription, Org.vwDatasheet.Address, 
                         Org.vwDatasheet.AreaCode, Org.vwDatasheet.PhoneNumber, Org.vwDatasheet.FaxNumber, Org.vwDatasheet.EmailAddress, Org.vwDatasheet.WebSite, Org.vwDatasheet.IndustrySector, 
                         Org.vwDatasheet.AccountSource, Org.vwDatasheet.PaymentTerms, Org.vwDatasheet.PaymentDays, Org.vwDatasheet.NumberOfEmployees, Org.vwDatasheet.CompanyNumber, Org.vwDatasheet.VatNumber, 
                         Org.vwDatasheet.Turnover, Org.vwDatasheet.StatementDays, Org.vwDatasheet.OpeningBalance, Org.vwDatasheet.CurrentBalance, Org.vwDatasheet.ForeignJurisdiction, Org.vwDatasheet.BusinessDescription, 
                         Org.tbPayment.PaymentCode, Usr.tbUser.UserName, App.tbTaxCode.TaxDescription AS PaymentTaxDescription, Org.tbAccount.CashAccountName, Cash.tbCode.CashDescription, Org.tbPayment.UserId, 
                         Org.tbPayment.CashAccountCode, Org.tbPayment.CashCode, Org.tbPayment.TaxCode, Org.tbPayment.PaidOn, Org.tbPayment.PaidInValue, Org.tbPayment.PaidOutValue, Org.tbPayment.TaxInValue, 
                         Org.tbPayment.TaxOutValue, Org.tbPayment.InsertedBy, Org.tbPayment.InsertedOn, Org.tbPayment.UpdatedBy, Org.tbPayment.UpdatedOn, Org.tbPayment.PaymentReference
FROM            Org.tbPayment INNER JOIN
                         Usr.tbUser ON Org.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
                         Org.tbAccount ON Org.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
                         Cash.tbCode ON Org.tbPayment.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
                         App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
                         Org.vwDatasheet ON Org.tbPayment.AccountCode = Org.vwDatasheet.AccountCode
WHERE        (Org.tbPayment.PaymentStatusCode = 2);
GO
CREATE VIEW Task.vwAttributesForOrder
AS
SELECT        TaskCode, Attribute, PrintOrder, AttributeDescription
FROM            Task.tbAttribute
WHERE        (AttributeTypeCode = 1);
GO
CREATE VIEW Task.vwAttributesForQuote
AS
SELECT        TaskCode, Attribute, PrintOrder, AttributeDescription
FROM            Task.tbAttribute
WHERE        (AttributeTypeCode = 2);
GO
CREATE VIEW Task.vwPurchaseEnquiryDeliverySpool
AS
SELECT        purchase_enquiry.TaskCode, purchase_enquiry.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, Org.tbAddress.Address AS InvoiceAddress, 
                         collection_account.AccountName AS CollectAccount, collection_address.Address AS CollectAddress, delivery_account.AccountName AS DeliveryAccount, delivery_address.Address AS DeliveryAddress, 
                         purchase_enquiry.AccountCode, purchase_enquiry.TaskNotes, purchase_enquiry.ActivityCode, purchase_enquiry.ActionOn, Activity.tbActivity.UnitOfMeasure, purchase_enquiry.Quantity, App.tbTaxCode.TaxCode, 
                         App.tbTaxCode.TaxRate, purchase_enquiry.UnitCharge, purchase_enquiry.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature, purchase_enquiry.TaskTitle
FROM            Org.tbOrg AS delivery_account INNER JOIN
                         Org.tbOrg AS collection_account INNER JOIN
                         Usr.tbUser INNER JOIN
                         Activity.tbActivity INNER JOIN
                         Task.tbTask AS purchase_enquiry ON Activity.tbActivity.ActivityCode = purchase_enquiry.ActivityCode INNER JOIN
                         Org.tbOrg ON purchase_enquiry.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode ON Usr.tbUser.UserId = purchase_enquiry.ActionById INNER JOIN
                         Org.tbAddress AS delivery_address ON purchase_enquiry.AddressCodeTo = delivery_address.AddressCode LEFT OUTER JOIN
                         App.tbTaxCode ON purchase_enquiry.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                         Org.tbContact ON purchase_enquiry.ContactName = Org.tbContact.ContactName AND purchase_enquiry.AccountCode = Org.tbContact.AccountCode INNER JOIN
                         Org.tbAddress AS collection_address ON purchase_enquiry.AddressCodeFrom = collection_address.AddressCode ON collection_account.AccountCode = collection_address.AccountCode ON 
                         delivery_account.AccountCode = delivery_address.AccountCode
WHERE EXISTS (SELECT * FROM App.tbDocSpool AS doc WHERE DocTypeCode = 3 AND UserName = SUSER_SNAME() AND purchase_enquiry.TaskCode = doc.DocumentNumber);
GO
CREATE VIEW Task.vwPurchaseEnquirySpool
AS
SELECT        purchase_enquiry.TaskCode, purchase_enquiry.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, Org.tbAddress.Address AS InvoiceAddress, 
                         Org_tbAddress_1.Address AS DeliveryAddress, purchase_enquiry.AccountCode, purchase_enquiry.TaskNotes, purchase_enquiry.ActivityCode, purchase_enquiry.ActionOn, Activity.tbActivity.UnitOfMeasure, 
                         purchase_enquiry.Quantity, App.tbTaxCode.TaxCode, App.tbTaxCode.TaxRate, purchase_enquiry.UnitCharge, purchase_enquiry.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature, 
                         purchase_enquiry.TaskTitle
FROM            Usr.tbUser INNER JOIN
                         Activity.tbActivity INNER JOIN
                         Task.tbTask AS purchase_enquiry ON Activity.tbActivity.ActivityCode = purchase_enquiry.ActivityCode INNER JOIN
                         Org.tbOrg ON purchase_enquiry.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode ON Usr.tbUser.UserId = purchase_enquiry.ActionById LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON purchase_enquiry.AddressCodeTo = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         App.tbTaxCode ON purchase_enquiry.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                         Org.tbContact ON purchase_enquiry.AccountCode = Org.tbContact.AccountCode AND purchase_enquiry.ContactName = Org.tbContact.ContactName
WHERE EXISTS (SELECT * FROM App.tbDocSpool AS doc WHERE DocTypeCode = 3 AND UserName = SUSER_SNAME() AND purchase_enquiry.TaskCode = doc.DocumentNumber);
GO
CREATE VIEW Task.vwPurchaseOrderSpool
AS
SELECT        purchase_order.TaskCode, purchase_order.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, invoice_address.Address AS InvoiceAddress, 
                         delivery_address.Address AS DeliveryAddress, purchase_order.AccountCode, purchase_order.TaskNotes, purchase_order.ActivityCode, purchase_order.ActionOn, Activity.tbActivity.UnitOfMeasure, 
                         purchase_order.Quantity, App.tbTaxCode.TaxCode, App.tbTaxCode.TaxRate, purchase_order.UnitCharge, purchase_order.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature, 
                         purchase_order.TaskTitle
FROM            Usr.tbUser INNER JOIN
                         Activity.tbActivity INNER JOIN
                         Task.tbTask AS purchase_order ON Activity.tbActivity.ActivityCode = purchase_order.ActivityCode INNER JOIN
                         Org.tbOrg ON purchase_order.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Org.tbAddress AS invoice_address ON Org.tbOrg.AddressCode = invoice_address.AddressCode ON Usr.tbUser.UserId = purchase_order.ActionById LEFT OUTER JOIN
                         Org.tbAddress AS delivery_address ON purchase_order.AddressCodeTo = delivery_address.AddressCode LEFT OUTER JOIN
                         App.tbTaxCode ON purchase_order.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                         Org.tbContact ON purchase_order.AccountCode = Org.tbContact.AccountCode AND purchase_order.ContactName = Org.tbContact.ContactName
WHERE EXISTS (
	SELECT        UserName, DocTypeCode, DocumentNumber, SpooledOn
    FROM            App.tbDocSpool AS doc
    WHERE        (DocTypeCode = 4) AND (UserName = SUSER_SNAME()) AND (purchase_order.TaskCode = DocumentNumber));
GO
CREATE VIEW Task.vwPurchaseOrderDeliverySpool
AS
SELECT        purchase_order.TaskCode, purchase_order.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, invoice_address.Address AS InvoiceAddress, 
                         delivery_account.AccountName AS CollectAccount, delivery_address.Address AS CollectAddress, collection_account.AccountName AS DeliveryAccount, collection_address.Address AS DeliveryAddress, 
                         purchase_order.AccountCode, purchase_order.TaskNotes, purchase_order.ActivityCode, purchase_order.ActionOn, Activity.tbActivity.UnitOfMeasure, purchase_order.Quantity, App.tbTaxCode.TaxCode, 
                         App.tbTaxCode.TaxRate, purchase_order.UnitCharge, purchase_order.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature, purchase_order.TaskTitle
FROM            Org.tbOrg AS collection_account INNER JOIN
                         Org.tbOrg AS delivery_account INNER JOIN
                         Usr.tbUser INNER JOIN
                         Activity.tbActivity INNER JOIN
                         Task.tbTask AS purchase_order ON Activity.tbActivity.ActivityCode = purchase_order.ActivityCode INNER JOIN
                         Org.tbOrg ON purchase_order.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Org.tbAddress AS invoice_address ON Org.tbOrg.AddressCode = invoice_address.AddressCode ON Usr.tbUser.UserId = purchase_order.ActionById INNER JOIN
                         Org.tbAddress AS collection_address ON purchase_order.AddressCodeTo = collection_address.AddressCode LEFT OUTER JOIN
                         App.tbTaxCode ON purchase_order.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                         Org.tbContact ON purchase_order.ContactName = Org.tbContact.ContactName AND purchase_order.AccountCode = Org.tbContact.AccountCode INNER JOIN
                         Org.tbAddress AS delivery_address ON purchase_order.AddressCodeFrom = delivery_address.AddressCode ON delivery_account.AccountCode = delivery_address.AccountCode ON 
                         collection_account.AccountCode = collection_address.AccountCode
WHERE EXISTS (
	SELECT        UserName, DocTypeCode, DocumentNumber, SpooledOn
    FROM            App.tbDocSpool AS doc
    WHERE        (DocTypeCode = 4) AND (UserName = SUSER_SNAME()) AND (purchase_order.TaskCode = DocumentNumber));
GO
CREATE VIEW Task.vwQuotationSpool
AS
SELECT        sales_order.TaskCode, sales_order.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, invoice_address.Address AS InvoiceAddress, 
                         delivery_address.Address AS DeliveryAddress, sales_order.AccountCode, sales_order.TaskNotes, sales_order.ActivityCode, sales_order.ActionOn, Activity.tbActivity.UnitOfMeasure, sales_order.Quantity, 
                         App.tbTaxCode.TaxCode, App.tbTaxCode.TaxRate, sales_order.UnitCharge, sales_order.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature, sales_order.TaskTitle
FROM            Usr.tbUser INNER JOIN
                         Activity.tbActivity INNER JOIN
                         Task.tbTask AS sales_order ON Activity.tbActivity.ActivityCode = sales_order.ActivityCode INNER JOIN
                         Org.tbOrg ON sales_order.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Org.tbAddress AS invoice_address ON Org.tbOrg.AddressCode = invoice_address.AddressCode ON Usr.tbUser.UserId = sales_order.ActionById LEFT OUTER JOIN
                         Org.tbAddress AS delivery_address ON sales_order.AddressCodeTo = delivery_address.AddressCode LEFT OUTER JOIN
                         App.tbTaxCode ON sales_order.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                         Org.tbContact ON sales_order.AccountCode = Org.tbContact.AccountCode AND sales_order.ContactName = Org.tbContact.ContactName
WHERE EXISTS (
	SELECT        UserName, DocTypeCode, DocumentNumber, SpooledOn
    FROM            App.tbDocSpool AS doc
    WHERE        (DocTypeCode = 1) AND (UserName = SUSER_SNAME()) AND (sales_order.TaskCode = DocumentNumber));
GO
CREATE VIEW Task.vwSalesOrderSpool
AS
SELECT        sales_order.TaskCode, sales_order.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, invoice_address.Address AS InvoiceAddress, 
                         delivery_address.Address AS DeliveryAddress, sales_order.AccountCode, sales_order.TaskNotes, sales_order.TaskTitle, sales_order.ActivityCode, sales_order.ActionOn, Activity.tbActivity.UnitOfMeasure, 
                         sales_order.Quantity, App.tbTaxCode.TaxCode, App.tbTaxCode.TaxRate, sales_order.UnitCharge, sales_order.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature
FROM            Usr.tbUser INNER JOIN
                         Activity.tbActivity INNER JOIN
                         Task.tbTask AS sales_order ON Activity.tbActivity.ActivityCode = sales_order.ActivityCode INNER JOIN
                         Org.tbOrg ON sales_order.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Org.tbAddress AS invoice_address ON Org.tbOrg.AddressCode = invoice_address.AddressCode ON Usr.tbUser.UserId = sales_order.ActionById LEFT OUTER JOIN
                         Org.tbAddress AS delivery_address ON sales_order.AddressCodeTo = delivery_address.AddressCode LEFT OUTER JOIN
                         App.tbTaxCode ON sales_order.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                         Org.tbContact ON sales_order.AccountCode = Org.tbContact.AccountCode AND sales_order.ContactName = Org.tbContact.ContactName
WHERE EXISTS (
	SELECT        UserName, DocTypeCode, DocumentNumber, SpooledOn
    FROM            App.tbDocSpool AS doc
    WHERE        (DocTypeCode = 2) AND (UserName = SUSER_SNAME()) AND (sales_order.TaskCode = DocumentNumber));
GO
CREATE VIEW Activity.vwDefaultText
AS
SELECT TOP 100 PERCENT  DefaultText
FROM            Activity.tbAttribute
GROUP BY DefaultText
HAVING        (DefaultText IS NOT NULL)
ORDER BY DefaultText;
GO
CREATE VIEW Activity.vwCandidateCashCodes
AS
SELECT TOP 100 PERCENT Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCategory.Category
FROM            Cash.tbCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
WHERE        (Cash.tbCategory.CashTypeCode = 1) OR
                         (Cash.tbCategory.CashTypeCode = 2)
ORDER BY Cash.tbCode.CashCode;
GO
CREATE VIEW App.vwCandidateHomeAccounts
AS
SELECT        Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Cash.tbMode.CashMode
FROM            Org.tbOrg INNER JOIN
                         Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode INNER JOIN
                         Cash.tbMode ON Org.tbType.CashModeCode = Cash.tbMode.CashModeCode
WHERE        (Org.tbOrg.OrganisationStatusCode < 4);
GO
CREATE VIEW App.vwCandidateNetProfitCodes
AS
SELECT TOP 100 PERCENT CategoryCode, Category
FROM            Cash.tbCategory
WHERE        (CategoryTypeCode = 2)
ORDER BY CategoryCode;
GO
CREATE VIEW App.vwDocOpenModes
AS
SELECT TOP 100 PERCENT OpenMode, OpenModeDescription
FROM            Usr.tbMenuOpenMode
WHERE        (OpenMode > 2)
ORDER BY OpenMode;
GO
CREATE VIEW App.vwGraphTaskActivity
AS
SELECT        CONCAT(Task.tbStatus.TaskStatus, SPACE(1), Cash.tbMode.CashMode) AS Category, SUM(Task.tbTask.TotalCharge) AS SumOfTotalCharge
FROM            Task.tbTask INNER JOIN
                         Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
                         Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
                         Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode
WHERE        (Task.tbTask.TaskStatusCode < 4) AND (Task.tbTask.TaskStatusCode > 1)
GROUP BY CONCAT(Task.tbStatus.TaskStatus, SPACE(1), Cash.tbMode.CashMode);
GO
CREATE VIEW App.vwGraphBankBalance
AS
SELECT        Format(Cash.vwAccountPeriodClosingBalance.StartOn, 'yyyy-MM') AS PeriodOn, SUM(Cash.vwAccountPeriodClosingBalance.ClosingBalance) AS SumOfClosingBalance
FROM            Cash.vwAccountPeriodClosingBalance INNER JOIN
                         Cash.tbCode ON Cash.vwAccountPeriodClosingBalance.CashCode = Cash.tbCode.CashCode
WHERE        (Cash.vwAccountPeriodClosingBalance.StartOn > DATEADD(m, - 6, GETDATE()))
GROUP BY Format(Cash.vwAccountPeriodClosingBalance.StartOn, 'yyyy-MM');
GO
CREATE VIEW Org.vwAccountLookup
AS
SELECT        Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Cash.tbMode.CashMode
FROM            Org.tbOrg INNER JOIN
                         Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode INNER JOIN
                         Cash.tbMode ON Org.tbType.CashModeCode = Cash.tbMode.CashModeCode
WHERE        (Org.tbOrg.OrganisationStatusCode < 4);
GO
CREATE VIEW Cash.vwBankCashCodes
AS
SELECT        Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCode.TaxCode
FROM            Cash.tbCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
WHERE        (Cash.tbCategory.CashTypeCode = 4);
GO
CREATE VIEW Cash.vwCodeLookup
AS
SELECT        Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCategory.Category, Cash.tbMode.CashMode
FROM            Cash.tbCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
                         Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode;
GO
CREATE VIEW Cash.vwExternalCodesLookup
AS
SELECT        Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCategory.Category
FROM            Cash.tbCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
WHERE        (Cash.tbCategory.CashTypeCode = 2);
GO
CREATE VIEW Cash.vwCategoryCodesNominal
AS
SELECT        CategoryCode, Category, DisplayOrder, CategoryTypeCode, CashModeCode, CashTypeCode
FROM            Cash.tbCategory
WHERE        (CategoryTypeCode = 1) AND (CashTypeCode = 3);
GO
CREATE VIEW Cash.vwCategoryCodesTrade
AS
SELECT        CategoryCode, Category, DisplayOrder, CategoryTypeCode, CashModeCode, CashTypeCode
FROM            Cash.tbCategory
WHERE        (CategoryTypeCode = 1) AND (CashTypeCode <> 3);
GO
CREATE VIEW Cash.vwCategoryCodesTotals
AS
SELECT        CategoryCode, Category, DisplayOrder, CategoryTypeCode, CashModeCode, CashTypeCode
FROM            Cash.tbCategory
WHERE        (CategoryTypeCode = 2);
GO
CREATE VIEW Cash.vwCategoryCodesExpressions
AS
SELECT        CategoryCode, Category, DisplayOrder, CategoryTypeCode, CashModeCode, CashTypeCode
FROM            Cash.tbCategory
WHERE        (CategoryTypeCode = 3);
GO
CREATE VIEW Cash.vwCategoryTotalCandidates
AS
SELECT        Cash.tbCategory.CategoryCode, Cash.tbCategory.Category, Cash.tbCategoryType.CategoryType, Cash.tbType.CashType, Cash.tbMode.CashMode
FROM            Cash.tbCategory INNER JOIN
                         Cash.tbCategoryType ON Cash.tbCategory.CategoryTypeCode = Cash.tbCategoryType.CategoryTypeCode INNER JOIN
                         Cash.tbType ON Cash.tbCategory.CashTypeCode = Cash.tbType.CashTypeCode INNER JOIN
                         Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode
WHERE        (Cash.tbCategory.CashTypeCode < 4);
GO
CREATE VIEW Cash.vwCashFlowTypes
AS
SELECT        CashTypeCode, CashType
FROM            Cash.tbType
WHERE        (CashTypeCode < 4);
GO
CREATE VIEW Cash.vwVATCodes
AS
SELECT        TaxCode, TaxDescription
FROM            App.tbTaxCode
WHERE        (TaxTypeCode = 2);
GO
CREATE VIEW App.vwTaxCodes
AS
SELECT        App.tbTaxCode.TaxCode, App.tbTaxCode.TaxDescription, Cash.tbTaxType.TaxType
FROM            App.tbTaxCode INNER JOIN
                         Cash.tbTaxType ON App.tbTaxCode.TaxTypeCode = Cash.tbTaxType.TaxTypeCode;
GO
CREATE VIEW Org.vwDepartments
AS
SELECT        Department
FROM            Org.tbContact
GROUP BY Department
HAVING        (Department IS NOT NULL);
GO
CREATE VIEW Org.vwJobTitles
AS
SELECT        JobTitle
FROM            Org.tbContact
GROUP BY JobTitle
HAVING        (JobTitle IS NOT NULL);
GO
CREATE VIEW Org.vwNameTitles
AS
SELECT        NameTitle
FROM            Org.tbContact
GROUP BY NameTitle
HAVING        (NameTitle IS NOT NULL);
GO
CREATE VIEW Org.vwAccountSources
AS
SELECT        AccountSource
FROM            Org.tbOrg
GROUP BY AccountSource
HAVING        (AccountSource IS NOT NULL);
GO
CREATE VIEW Org.vwAreaCodes
AS
SELECT        AreaCode
FROM            Org.tbOrg
GROUP BY AreaCode
HAVING        (AreaCode IS NOT NULL);
GO
CREATE VIEW Task.vwAttributeDescriptions
AS
SELECT        Attribute, AttributeDescription
FROM            Task.tbAttribute
GROUP BY Attribute, AttributeDescription
HAVING        (AttributeDescription IS NOT NULL);
GO
CREATE VIEW Task.vwTitles
AS
SELECT        ActivityCode, TaskTitle
FROM            Task.tbTask
GROUP BY TaskTitle, ActivityCode
HAVING        (TaskTitle IS NOT NULL);
GO
CREATE VIEW Activity.vwCodes
AS
SELECT        Activity.tbActivity.ActivityCode, Activity.tbActivity.UnitOfMeasure, Activity.tbActivity.CashCode
FROM            Activity.tbActivity LEFT OUTER JOIN
                         Cash.tbCode ON Activity.tbActivity.CashCode = Cash.tbCode.CashCode;
GO
CREATE VIEW Task.vwActiveStatusCodes
AS
SELECT        TaskStatusCode, TaskStatus
FROM            Task.tbStatus
WHERE        (TaskStatusCode < 4);
GO
CREATE VIEW Org.vwTypeLookup
AS
SELECT        Org.tbType.OrganisationTypeCode, Org.tbType.OrganisationType, Cash.tbMode.CashMode
FROM            Org.tbType INNER JOIN
                         Cash.tbMode ON Org.tbType.CashModeCode = Cash.tbMode.CashModeCode;
GO
CREATE VIEW Invoice.vwVatSummary
AS
WITH tbBase AS
(
	SELECT        StartOn, TaxCode, SUM(HomeSales) AS HomeSales, SUM(HomePurchases) AS HomePurchases, SUM(ExportSales) AS ExportSales, SUM(ExportPurchases) AS ExportPurchases, SUM(HomeSalesVat) 
							AS HomeSalesVat, SUM(HomePurchasesVat) AS HomePurchasesVat, SUM(ExportSalesVat) AS ExportSalesVat, SUM(ExportPurchasesVat) AS ExportPurchasesVat
	FROM            Invoice.vwVatDetail
	GROUP BY StartOn, TaxCode
)
SELECT        StartOn, TaxCode, HomeSales, HomePurchases, ExportSales, ExportPurchases, HomeSalesVat, HomePurchasesVat, ExportSalesVat, ExportPurchasesVat, (HomeSalesVat + ExportSalesVat) 
                         - (HomePurchasesVat + ExportPurchasesVat) AS VatDue
FROM tbBase;
GO
ALTER VIEW Invoice.vwRegisterDetail
AS
WITH register AS
(
	SELECT     StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, 
						  InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, 
						  InvoiceType
	FROM         Invoice.vwRegisterTasks
	UNION
	SELECT     StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, 
						  InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, 
						  InvoiceType
	FROM         Invoice.vwRegisterItems
)
SELECT *, ([InvoiceValue])+[TaxValue]-([PaidValue]+[PaidTaxValue]) AS UnpaidValue FROM register;
GO
ALTER VIEW Usr.vwDoc
AS
WITH bank AS 
(
	SELECT TOP (1) App.fnCompanyAccount() AS AccountCode, CONCAT(Org.tbOrg.AccountName, SPACE(1), Org.tbAccount.CashAccountName) AS BankAccount, Org.tbAccount.SortCode AS BankSortCode , Org.tbAccount.AccountNumber AS BankAccountNumber
    FROM            Org.tbAccount INNER JOIN
                            Org.tbOrg ON Org.tbAccount.AccountCode = Org.tbOrg.AccountCode
    WHERE        NOT (Org.tbAccount.CashCode IS NULL)
)
SELECT        TOP (1) company.AccountName AS CompanyName, Org.tbAddress.Address AS CompanyAddress, company.PhoneNumber AS CompanyPhoneNumber, company.FaxNumber AS CompanyFaxNumber, 
                        company.EmailAddress AS CompanyEmailAddress, company.WebSite AS CompanyWebsite, company.CompanyNumber, company.VatNumber, company.Logo, bank_details.BankAccount, bank_details.BankAccountNumber, 
                        bank_details.BankSortCode
FROM            Org.tbOrg AS company INNER JOIN
                        App.tbOptions ON company.AccountCode = App.tbOptions.AccountCode LEFT OUTER JOIN
                        bank AS bank_details ON company.AccountCode = bank_details.AccountCode LEFT OUTER JOIN
                        Org.tbAddress ON company.AddressCode = Org.tbAddress.AddressCode;
GO