ALTER TABLE [App].[tbEventLog] WITH NOCHECK ADD
	RowVer timestamp NOT NULL;

ALTER TABLE [App].[tbText] WITH NOCHECK ADD
	RowVer timestamp NOT NULL;

ALTER TABLE [Cash].[tbTaxType] WITH NOCHECK ADD
	RowVer timestamp NOT NULL;

ALTER TABLE [Invoice].[tbType] WITH NOCHECK ADD
	RowVer timestamp NOT NULL;

ALTER TABLE [Org].[tbOrg] WITH NOCHECK ADD
	RowVer timestamp NOT NULL;
go
ALTER VIEW [Task].[vwOps]
AS
SELECT        Task.tbOp.TaskCode, Task.tbOp.OperationNumber, Task.vwOpBucket.Period, Task.vwOpBucket.BucketId, Task.tbOp.UserId, Task.tbOp.OpTypeCode, Task.tbOp.OpStatusCode, Task.tbOp.Operation, 
                         Task.tbOp.Note, Task.tbOp.StartOn, Task.tbOp.EndOn, Task.tbOp.Duration, Task.tbOp.OffsetDays, Task.tbOp.InsertedBy, Task.tbOp.InsertedOn, Task.tbOp.UpdatedBy, Task.tbOp.UpdatedOn, Task.tbTask.TaskTitle,
                          Task.tbStatus.TaskStatus, Task.tbTask.ActionOn, Task.tbTask.Quantity, Cash.tbCode.CashDescription, Task.tbTask.TotalCharge, Task.tbTask.AccountCode, Org.tbOrg.AccountName, 
                         Task.tbOp.RowVer AS OpRowVer, Task.tbTask.RowVer AS TaskRowVer
FROM            Task.tbOp INNER JOIN
                         Task.tbTask ON Task.tbOp.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
                         Task.vwOpBucket ON Task.tbOp.TaskCode = Task.vwOpBucket.TaskCode AND Task.tbOp.OperationNumber = Task.vwOpBucket.OperationNumber LEFT OUTER JOIN
                         Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode
GO
ALTER VIEW [Task].[vwTasks]
AS
SELECT        Task.tbTask.TaskCode, Task.tbTask.UserId, Task.tbTask.AccountCode, Task.tbTask.ContactName, Task.tbTask.ActivityCode, Task.tbTask.TaskTitle, Task.tbTask.TaskStatusCode, Task.tbTask.ActionById, 
                         Task.tbTask.ActionOn, Task.tbTask.ActionedOn, Task.tbTask.PaymentOn, Task.tbTask.SecondReference, Task.tbTask.TaskNotes, Task.tbTask.TaxCode, Task.tbTask.Quantity, Task.tbTask.UnitCharge, 
                         Task.tbTask.TotalCharge, Task.tbTask.AddressCodeFrom, Task.tbTask.AddressCodeTo, Task.tbTask.Printed, Task.tbTask.Spooled, Task.tbTask.InsertedBy, Task.tbTask.InsertedOn, Task.tbTask.UpdatedBy, 
                         Task.tbTask.UpdatedOn, Task.vwBucket.Period, Task.vwBucket.BucketId, TaskStatus.TaskStatus, Task.tbTask.CashCode, Cash.tbCode.CashDescription, tbUser_1.UserName AS OwnerName, 
                         Usr.tbUser.UserName AS ActionName, Org.tbOrg.AccountName, OrgStatus.OrganisationStatus, Org.tbType.OrganisationType, CASE WHEN Cash.tbCategory.CategoryCode IS NULL 
                         THEN Org.tbType.CashModeCode ELSE Cash.tbCategory.CashModeCode END AS CashModeCode, Task.tbTask.RowVer
FROM            Usr.tbUser INNER JOIN
                         Task.tbStatus AS TaskStatus INNER JOIN
                         Org.tbType INNER JOIN
                         Org.tbOrg ON Org.tbType.OrganisationTypeCode = Org.tbOrg.OrganisationTypeCode INNER JOIN
                         Org.tbStatus AS OrgStatus ON Org.tbOrg.OrganisationStatusCode = OrgStatus.OrganisationStatusCode INNER JOIN
                         Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode ON TaskStatus.TaskStatusCode = Task.tbTask.TaskStatusCode ON Usr.tbUser.UserId = Task.tbTask.ActionById INNER JOIN
                         Usr.tbUser AS tbUser_1 ON Task.tbTask.UserId = tbUser_1.UserId INNER JOIN
                         Task.vwBucket ON Task.tbTask.TaskCode = Task.vwBucket.TaskCode LEFT OUTER JOIN
                         Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
go
ALTER VIEW [App].[vwDocCreditNote]
AS
SELECT        TOP (100) PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.Printed, Invoice.tbInvoice.Spooled, Invoice.tbInvoice.InvoiceStatusCode, Usr.tbUser.UserName, Invoice.tbInvoice.AccountCode, 
                         Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, 
                         Org.tbOrg.EmailAddress, Invoice.tbInvoice.RowVer
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 1);
go
ALTER VIEW [App].[vwDocDebitNote]
AS
SELECT        TOP (100) PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.Printed, Invoice.tbInvoice.Spooled, Invoice.tbInvoice.InvoiceStatusCode, Usr.tbUser.UserName, Invoice.tbInvoice.AccountCode, 
                         Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, 
                         Org.tbOrg.EmailAddress, Invoice.tbInvoice.RowVer
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 3);
go
ALTER VIEW [App].[vwDocPurchaseEnquiry]
AS
SELECT        TOP (100) PERCENT Task.vwTasks.TaskCode, Task.vwTasks.ActionOn, Task.vwTasks.ActivityCode, Task.vwTasks.ActionById, Task.vwTasks.BucketId, Task.vwTasks.TaskTitle, Task.vwTasks.AccountCode, 
                         Task.vwTasks.ContactName, Task.vwTasks.TaskNotes, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, 
                         Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, Org.tbAddress.Address AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
                         Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, Task.vwTasks.ActionName, Task.vwTasks.Period, Task.vwTasks.Printed, Task.vwTasks.Spooled, Task.vwTasks.RowVer
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 0) AND (Task.vwTasks.TaskStatusCode = 0);
go
ALTER VIEW [App].[vwDocPurchaseOrder]
AS
SELECT        TOP (100) PERCENT Task.vwTasks.TaskCode, Task.vwTasks.ActionOn, Task.vwTasks.ActivityCode, Task.vwTasks.ActionById, Task.vwTasks.BucketId, Task.vwTasks.TaskTitle, Task.vwTasks.AccountCode, 
                         Task.vwTasks.ContactName, Task.vwTasks.TaskNotes, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, 
                         Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, Org.tbAddress.Address AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
                         Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, Task.vwTasks.ActionName, Task.vwTasks.Period, Task.vwTasks.Printed, Task.vwTasks.Spooled, Task.vwTasks.RowVer
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 0) AND (Task.vwTasks.TaskStatusCode > 0);
go
ALTER VIEW [App].[vwDocQuotation]
AS
SELECT        TOP (100) PERCENT Task.vwTasks.TaskCode, Task.vwTasks.ActionOn, Task.vwTasks.ActivityCode, Task.vwTasks.ActionById, Task.vwTasks.BucketId, Task.vwTasks.TaskTitle, Task.vwTasks.AccountCode, 
                         Task.vwTasks.ContactName, Task.vwTasks.TaskNotes, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, 
                         Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, Org.tbAddress.Address AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
                         Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, Task.vwTasks.ActionName, Task.vwTasks.Period, Task.vwTasks.Printed, Task.vwTasks.Spooled, Task.vwTasks.RowVer
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 1) AND (Task.vwTasks.TaskStatusCode = 0);
go
ALTER VIEW [App].[vwDocSalesInvoice]
AS
SELECT        TOP (100) PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.Printed, Invoice.tbInvoice.Spooled, Invoice.tbInvoice.InvoiceStatusCode, Usr.tbUser.UserName, Invoice.tbInvoice.AccountCode, 
                         Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, 
                         Org.tbOrg.EmailAddress, Invoice.tbInvoice.RowVer
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 0);
go
ALTER VIEW [App].[vwDocSalesOrder]
AS
SELECT        TOP (100) PERCENT Task.vwTasks.TaskCode, Task.vwTasks.ActionOn, Task.vwTasks.ActivityCode, Task.vwTasks.ActionById, Task.vwTasks.BucketId, Task.vwTasks.AccountCode, Task.vwTasks.TaskTitle, 
                         Task.vwTasks.ContactName, Task.vwTasks.TaskNotes, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, 
                         Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, Org.tbAddress.Address AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
                         Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, Task.vwTasks.ActionName, Task.vwTasks.Period, Task.vwTasks.Printed, Task.vwTasks.Spooled, Task.vwTasks.RowVer
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 1) AND (Task.vwTasks.TaskStatusCode > 0);
go
ALTER VIEW [App].[vwWarehouseOrg]
AS
SELECT TOP (100) PERCENT Org.tbOrg.AccountCode, Org.tbDoc.DocumentName, Org.tbOrg.AccountName, Org.tbDoc.DocumentImage, Org.tbDoc.DocumentDescription, Org.tbDoc.InsertedBy, Org.tbDoc.InsertedOn, Org.tbDoc.UpdatedBy, 
                         Org.tbDoc.UpdatedOn, Org.tbDoc.RowVer
FROM            Org.tbOrg INNER JOIN
                         Org.tbDoc ON Org.tbOrg.AccountCode = Org.tbDoc.AccountCode
ORDER BY Org.tbDoc.AccountCode, Org.tbDoc.DocumentName;
go
ALTER VIEW [App].[vwWarehouseTask]
AS
SELECT TOP (100) PERCENT Task.tbDoc.TaskCode, Task.tbDoc.DocumentName, Org.tbOrg.AccountName, Task.tbTask.TaskTitle, Task.tbDoc.DocumentImage, Task.tbDoc.DocumentDescription, Task.tbDoc.InsertedBy, Task.tbDoc.InsertedOn, 
                         Task.tbDoc.UpdatedBy, Task.tbDoc.UpdatedOn, Task.tbDoc.RowVer
FROM            Org.tbOrg INNER JOIN
                         Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode INNER JOIN
                         Task.tbDoc ON Task.tbTask.TaskCode = Task.tbDoc.TaskCode
ORDER BY Task.tbDoc.TaskCode, Task.tbDoc.DocumentName;
go
ALTER VIEW [App].[vwPeriods]
AS
	SELECT        TOP (100) PERCENT App.tbYearPeriod.StartOn, App.tbYear.Description + SPACE(1) + App.tbMonth.MonthName AS Description, App.tbYearPeriod.RowVer
	FROM            App.tbYearPeriod INNER JOIN
							 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
							 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
	WHERE        (App.tbYearPeriod.StartOn < DATEADD(d, 1, CURRENT_TIMESTAMP)) AND (App.tbYear.CashStatusCode < 3)
	ORDER BY App.tbYearPeriod.StartOn DESC;
go
ALTER VIEW [App].[vwYearPeriod]
AS
SELECT TOP (100) PERCENT App.tbYear.Description, App.tbMonth.MonthName, App.tbYearPeriod.CashStatusCode, App.tbYearPeriod.YearNumber, App.tbYearPeriod.StartOn, App.tbYearPeriod.RowVer
FROM            App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
ORDER BY App.tbYearPeriod.YearNumber, App.tbYearPeriod.StartOn;
go
ALTER VIEW [Cash].[vwNominalEntryData]
AS
SELECT        TOP (100) PERCENT Cash.tbCode.CashCode, Cash.tbPeriod.StartOn, Cash.tbCode.CashDescription, Cash.tbCode.CategoryCode, Cash.tbMode.CashMode, Cash.tbType.CashType, App.tbTaxCode.TaxRate, 
                         Cash.tbPeriod.ForecastValue, Cash.tbPeriod.ForecastTax, Cash.tbPeriod.Note, Cash.tbMode.CashModeCode, Cash.tbPeriod.InvoiceValue, Cash.tbPeriod.InvoiceTax, Cash.tbPeriod.RowVer
FROM            Cash.tbType INNER JOIN
                         Cash.tbMode INNER JOIN
                         Cash.tbPeriod INNER JOIN
                         Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode ON Cash.tbMode.CashModeCode = Cash.tbCategory.CashModeCode ON 
                         Cash.tbType.CashTypeCode = Cash.tbCategory.CashTypeCode INNER JOIN
                         App.tbTaxCode ON Cash.tbCode.TaxCode = App.tbTaxCode.TaxCode
ORDER BY Cash.tbCode.CashCode;
go
ALTER VIEW [Cash].[vwNominalForecastData]
AS
SELECT TOP 100 PERCENT Cash.tbPeriod.CashCode, Cash.tbPeriod.StartOn, App.tbYearPeriod.YearNumber, App.tbMonth.MonthName, Cash.tbPeriod.ForecastValue, Cash.tbPeriod.ForecastTax, Cash.tbPeriod.Note, 
                         Cash.tbCategory.CashModeCode, App.tbTaxCode.TaxRate, Cash.tbPeriod.RowVer
FROM            App.tbYearPeriod INNER JOIN
                         Cash.tbPeriod ON App.tbYearPeriod.StartOn = Cash.tbPeriod.StartOn INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                         Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
                         App.tbTaxCode ON Cash.tbCode.TaxCode = App.tbTaxCode.TaxCode
ORDER BY Cash.tbPeriod.StartOn;
go
ALTER VIEW [Cash].[vwNominalForecastProjection]
AS
SELECT TOP 100 PERCENT Cash.tbCode.CashCode, Cash.tbPeriod.StartOn, App.tbYearPeriod.YearNumber, Cash.tbCode.CategoryCode, Cash.tbCode.CashDescription, Format(App.tbYearPeriod.StartOn, 'yy-MM') AS Period, 
                         Cash.tbPeriod.ForecastValue AS Value, Cash.tbPeriod.RowVer
FROM            Cash.tbPeriod INNER JOIN
                         Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode INNER JOIN
                         App.tbYearPeriod ON Cash.tbPeriod.StartOn = App.tbYearPeriod.StartOn
ORDER BY Cash.tbPeriod.StartOn;
go
ALTER VIEW [Cash].[vwNominalInvoiceData]
AS
SELECT TOP 100 PERCENT Cash.tbPeriod.CashCode, Cash.tbPeriod.StartOn, App.tbYearPeriod.YearNumber, App.tbMonth.MonthName, Cash.tbPeriod.Note, Cash.tbCategory.CashModeCode, App.tbTaxCode.TaxRate, 
                         Cash.tbPeriod.InvoiceValue, Cash.tbPeriod.InvoiceTax, Cash.tbPeriod.RowVer
FROM            App.tbYearPeriod INNER JOIN
                         Cash.tbPeriod ON App.tbYearPeriod.StartOn = Cash.tbPeriod.StartOn INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                         Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
                         App.tbTaxCode ON Cash.tbCode.TaxCode = App.tbTaxCode.TaxCode
ORDER BY Cash.tbPeriod.StartOn;
go
ALTER VIEW [Org].[vwCashAccounts]
AS
SELECT        Org.tbAccount.CashAccountCode, Org.tbAccount.CashAccountName, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Org.tbAccount.OpeningBalance, Org.tbAccount.CurrentBalance, Org.tbAccount.SortCode, 
                         Org.tbAccount.AccountNumber, Org.tbAccount.AccountClosed, Org.tbAccount.RowVer
FROM            Org.tbOrg INNER JOIN
                         Org.tbAccount ON Org.tbOrg.AccountCode = Org.tbAccount.AccountCode INNER JOIN
                         Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode;
go
ALTER VIEW [Org].[vwCashAccountsLive]
AS
SELECT        Org.tbAccount.CashAccountCode, Org.tbAccount.CashAccountName, Org.tbAccount.RowVer
FROM            Org.tbAccount INNER JOIN
                         Org.tbOrg ON Org.tbAccount.AccountCode = Org.tbOrg.AccountCode
WHERE        (Org.tbAccount.AccountClosed = 0);
go
ALTER VIEW [Org].[vwPaymentsUnposted]
AS
SELECT        PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, TaxInValue, TaxOutValue, PaymentReference, InsertedBy, InsertedOn, 
                         UpdatedBy, UpdatedOn, RowVer
FROM            Org.tbPayment
WHERE        (PaymentStatusCode = 0);
go




