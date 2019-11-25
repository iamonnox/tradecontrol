/************************************************************
VIEWS
************************************************************/

CREATE VIEW Invoice.vwRegisterItems
  AS
SELECT     App.fnAccountPeriod(Invoice.tbInvoice.InvoicedOn) AS StartOn, Invoice.tbInvoice.InvoiceNumber, Invoice.tbItem.CashCode AS TaskCode, 
                      Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Invoice.tbItem.TaxCode, App.tbTaxCode.TaxDescription, 
                      Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbInvoice.InvoicedOn, 
                      CASE WHEN Invoice.tbType.CashModeCode = 1 THEN Invoice.tbItem.InvoiceValue * - 1 ELSE Invoice.tbItem.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN Invoice.tbType.CashModeCode = 1 THEN Invoice.tbItem.TaxValue * - 1 ELSE Invoice.tbItem.TaxValue END AS TaxValue, 
                      CASE WHEN Invoice.tbType.CashModeCode = 1 THEN Invoice.tbItem.PaidValue * - 1 ELSE Invoice.tbItem.PaidValue END AS PaidValue, 
                      CASE WHEN Invoice.tbType.CashModeCode = 1 THEN Invoice.tbItem.PaidTaxValue * - 1 ELSE Invoice.tbItem.PaidTaxValue END AS PaidTaxValue,
                       Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Printed, Org.tbOrg.AccountName, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, 
                      Invoice.tbType.CashModeCode, Invoice.tbType.InvoiceType
FROM         Invoice.tbInvoice INNER JOIN
                      Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                      Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                      Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId INNER JOIN
                      Invoice.tbItem ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbItem.InvoiceNumber INNER JOIN
                      Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
                      App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode



GO
ALTER AUTHORIZATION ON Invoice.vwRegisterItems TO  SCHEMA OWNER 
GO
CREATE VIEW Invoice.vwRegisterTasks
AS
SELECT        App.fnAccountPeriod(Invoice.tbInvoice.InvoicedOn) AS StartOn, Invoice.tbInvoice.InvoiceNumber, InvoiceTask.TaskCode, Task.TaskTitle, Cash.tbCode.CashCode, Cash.tbCode.CashDescription, 
                         InvoiceTask.TaxCode, App.tbTaxCode.TaxDescription, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbInvoice.InvoicedOn, 
                         CASE WHEN Invoice.tbType.CashModeCode = 1 THEN InvoiceTask.InvoiceValue * - 1 ELSE InvoiceTask.InvoiceValue END AS InvoiceValue, 
                         CASE WHEN Invoice.tbType.CashModeCode = 1 THEN InvoiceTask.TaxValue * - 1 ELSE InvoiceTask.TaxValue END AS TaxValue, 
                         CASE WHEN Invoice.tbType.CashModeCode = 1 THEN InvoiceTask.PaidValue * - 1 ELSE InvoiceTask.PaidValue END AS PaidValue, 
                         CASE WHEN Invoice.tbType.CashModeCode = 1 THEN InvoiceTask.PaidTaxValue * - 1 ELSE InvoiceTask.PaidTaxValue END AS PaidTaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Printed, 
                         Org.tbOrg.AccountName, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.CashModeCode, Invoice.tbType.InvoiceType
FROM            Invoice.tbInvoice INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId INNER JOIN
                         Invoice.tbTask AS InvoiceTask ON Invoice.tbInvoice.InvoiceNumber = InvoiceTask.InvoiceNumber INNER JOIN
                         Cash.tbCode ON InvoiceTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Task.tbTask AS Task ON InvoiceTask.TaskCode = Task.TaskCode AND InvoiceTask.TaskCode = Task.TaskCode LEFT OUTER JOIN
                         App.tbTaxCode ON InvoiceTask.TaxCode = App.tbTaxCode.TaxCode

GO
ALTER AUTHORIZATION ON Invoice.vwRegisterTasks TO  SCHEMA OWNER 
GO
CREATE VIEW Invoice.vwRegisterDetail
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
ALTER AUTHORIZATION ON Invoice.vwRegisterDetail TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwCodeInvoiceSummary
AS
SELECT        Invoice.vwRegisterDetail.CashCode, Invoice.vwRegisterDetail.StartOn, ABS(SUM(Invoice.vwRegisterDetail.InvoiceValue)) AS InvoiceValue, 
                         ABS(SUM(Invoice.vwRegisterDetail.TaxValue)) AS TaxValue
FROM            Invoice.vwRegisterDetail INNER JOIN
                         Cash.tbCode ON Invoice.vwRegisterDetail.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
GROUP BY Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.CashCode

GO
ALTER AUTHORIZATION ON Cash.vwCodeInvoiceSummary TO  SCHEMA OWNER 
GO
CREATE VIEW Org.vwRebuildInvoicedItems
AS
SELECT     Invoice.tbInvoice.AccountCode, Invoice.tbType.CashModeCode, Invoice.tbInvoice.CollectOn, Invoice.tbItem.InvoiceNumber, 
                      Invoice.tbItem.CashCode, '' AS TaskCode, Invoice.tbItem.InvoiceValue, Invoice.tbItem.TaxValue, Invoice.tbItem.PaidValue, 
                      Invoice.tbItem.PaidTaxValue
FROM         Invoice.tbItem INNER JOIN
                      Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode

GO
ALTER AUTHORIZATION ON Org.vwRebuildInvoicedItems TO  SCHEMA OWNER 
GO
CREATE VIEW Org.vwRebuildInvoicedTasks
AS
SELECT     Invoice.tbInvoice.AccountCode, Invoice.tbType.CashModeCode, Invoice.tbInvoice.CollectOn, Invoice.tbTask.InvoiceNumber, 
                      Invoice.tbTask.CashCode, Invoice.tbTask.TaskCode, Invoice.tbTask.InvoiceValue, Invoice.tbTask.TaxValue, 
                      Invoice.tbTask.PaidValue, Invoice.tbTask.PaidTaxValue
FROM         Invoice.tbTask INNER JOIN
                      Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode

GO
ALTER AUTHORIZATION ON Org.vwRebuildInvoicedTasks TO  SCHEMA OWNER 
GO
CREATE VIEW Org.vwRebuildInvoices
AS
SELECT     AccountCode, CashModeCode, CollectOn, InvoiceNumber, CashCode, TaskCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
FROM         Org.vwRebuildInvoicedTasks
UNION
SELECT     AccountCode, CashModeCode, CollectOn, InvoiceNumber, CashCode, TaskCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
FROM         Org.vwRebuildInvoicedItems

GO
ALTER AUTHORIZATION ON Org.vwRebuildInvoices TO  SCHEMA OWNER 
GO
CREATE VIEW Org.vwRebuildInvoiceTotals
AS
SELECT     AccountCode, InvoiceNumber, SUM(InvoiceValue) AS TotalInvoiceValue, SUM(TaxValue) AS TotalTaxValue, SUM(PaidValue) AS TotalPaidValue, 
                      SUM(PaidTaxValue) AS TotalPaidTaxValue
FROM         Org.vwRebuildInvoices
GROUP BY AccountCode, InvoiceNumber
GO
ALTER AUTHORIZATION ON Org.vwRebuildInvoiceTotals TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwPolarData
AS
SELECT        Cash.tbPeriod.CashCode, Cash.tbCategory.CashTypeCode, Cash.tbPeriod.StartOn, Cash.tbPeriod.ForecastValue, Cash.tbPeriod.ForecastTax, 
                         Cash.tbPeriod.InvoiceValue, Cash.tbPeriod.InvoiceTax
FROM            Cash.tbPeriod INNER JOIN
                         Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode INNER JOIN
                         App.tbYearPeriod ON Cash.tbPeriod.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
WHERE        (App.tbYear.CashStatusCode < 4)

GO
ALTER AUTHORIZATION ON Cash.vwPolarData TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwFlowData
AS
SELECT        App.tbYearPeriod.YearNumber, App.tbYearPeriod.StartOn, Cash.vwPolarData.CashCode, Cash.vwPolarData.InvoiceValue, 
                         Cash.vwPolarData.InvoiceTax, Cash.vwPolarData.ForecastValue, Cash.vwPolarData.ForecastTax
FROM            App.tbYearPeriod INNER JOIN
                         Cash.vwPolarData ON App.tbYearPeriod.StartOn = Cash.vwPolarData.StartOn

GO
ALTER AUTHORIZATION ON Cash.vwFlowData TO  SCHEMA OWNER 
GO
CREATE VIEW Invoice.vwOutstandingItems
  AS
SELECT     InvoiceNumber, '' AS TaskCode, CashCode, TaxCode, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS OutstandingValue, 
                      CASE WHEN InvoiceValue = 0 THEN 0 ELSE TaxValue / InvoiceValue END AS TaxRate
FROM         Invoice.tbItem
GO
ALTER AUTHORIZATION ON Invoice.vwOutstandingItems TO  SCHEMA OWNER 
GO
CREATE VIEW Invoice.vwOutstandingTasks
  AS
SELECT     InvoiceNumber, TaskCode, CashCode, TaxCode, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS OutstandingValue, 
                      CASE WHEN InvoiceValue = 0 THEN 0 ELSE TaxValue / InvoiceValue END AS TaxRate
FROM         Invoice.tbTask
GO
ALTER AUTHORIZATION ON Invoice.vwOutstandingTasks TO  SCHEMA OWNER 
GO
CREATE VIEW Invoice.vwOutstandingBase
  AS
SELECT     InvoiceNumber AS InvoiceNumber, TaskCode AS TaskCode, 
                      CashCode AS CashCode, TaxCode AS TaxCode, OutstandingValue, TaxRate
FROM         Invoice.vwOutstandingItems
UNION
SELECT     InvoiceNumber AS InvoiceNumber, TaskCode AS TaskCode, 
                      CashCode AS CashCode, TaxCode AS TaxCode, OutstandingValue, TaxRate
FROM         Invoice.vwOutstandingTasks
GO
ALTER AUTHORIZATION ON Invoice.vwOutstandingBase TO  SCHEMA OWNER 
GO
CREATE VIEW Invoice.vwOutstanding
AS
SELECT     TOP (100) PERCENT Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.CollectOn, Invoice.tbInvoice.InvoiceNumber, Invoice.vwOutstandingBase.TaskCode, 
                      Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbType.CashModeCode, Invoice.vwOutstandingBase.CashCode, 
                      Invoice.vwOutstandingBase.TaxCode, Invoice.vwOutstandingBase.TaxRate, 
                      CASE WHEN Invoice.tbType.CashModeCode = 1 THEN OutstandingValue * - 1 ELSE OutstandingValue END AS ItemValue
FROM         Invoice.vwOutstandingBase INNER JOIN
                      Invoice.tbInvoice ON Invoice.vwOutstandingBase.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE     (Invoice.tbInvoice.InvoiceStatusCode = 2) OR
                      (Invoice.tbInvoice.InvoiceStatusCode = 3)

GO
ALTER AUTHORIZATION ON Invoice.vwOutstanding TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwStatementTasksFull
 AS
SELECT     TOP (100) PERCENT Task.tbTask.TaskCode AS ReferenceCode, Task.tbTask.AccountCode, Task.tbTask.ActionOn, Task.tbTask.PaymentOn, 
                      CASE WHEN Task.tbTask.TaskStatusCode = 1 THEN 4 ELSE 3 END AS CashEntryTypeCode, 
                      CASE WHEN Cash.tbCategory.CashModeCode = 1 THEN (Task.tbTask.UnitCharge + Task.tbTask.UnitCharge * App.vwTaxRates.TaxRate) 
                      * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayOut, 
                      CASE WHEN Cash.tbCategory.CashModeCode = 2 THEN (Task.tbTask.UnitCharge + Task.tbTask.UnitCharge * App.vwTaxRates.TaxRate) 
                      * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayIn, Cash.tbCode.CashCode
FROM         App.vwTaxRates INNER JOIN
                      Task.tbTask ON App.vwTaxRates.TaxCode = Task.tbTask.TaxCode INNER JOIN
                      Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode LEFT OUTER JOIN
                      Task.vwInvoicedQuantity ON Task.tbTask.TaskCode = Task.vwInvoicedQuantity.TaskCode
WHERE     (Task.tbTask.TaskStatusCode < 4) AND (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0) > 0)

GO
ALTER AUTHORIZATION ON Cash.vwStatementTasksFull TO  SCHEMA OWNER 
GO
CREATE VIEW Invoice.vwSummaryTasks
AS
SELECT     App.fnAccountPeriod(Invoice.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN Invoice.tbInvoice.InvoiceTypeCode = 2 THEN 1 ELSE CASE WHEN Invoice.tbInvoice.InvoiceTypeCode = 4 THEN 3 ELSE Invoice.tbInvoice.InvoiceTypeCode END END AS InvoiceTypeCode,
                       CASE WHEN Invoice.tbType.CashModeCode = 1 THEN Invoice.tbTask.InvoiceValue * - 1 ELSE Invoice.tbTask.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN Invoice.tbType.CashModeCode = 1 THEN Invoice.tbTask.TaxValue * - 1 ELSE Invoice.tbTask.TaxValue END AS TaxValue
FROM         Invoice.tbTask INNER JOIN
                      Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE     (Invoice.tbInvoice.InvoicedOn >= App.fnHistoryStartOn())

GO
ALTER AUTHORIZATION ON Invoice.vwSummaryTasks TO  SCHEMA OWNER 
GO
CREATE VIEW Invoice.vwSummaryItems
AS
SELECT     App.fnAccountPeriod(Invoice.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN Invoice.tbInvoice.InvoiceTypeCode = 2 THEN 1 ELSE CASE WHEN Invoice.tbInvoice.InvoiceTypeCode = 4 THEN 3 ELSE Invoice.tbInvoice.InvoiceTypeCode END END AS InvoiceTypeCode,
                       CASE WHEN Invoice.tbType.CashModeCode = 1 THEN Invoice.tbItem.InvoiceValue * - 1 ELSE Invoice.tbItem.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN Invoice.tbType.CashModeCode = 1 THEN Invoice.tbItem.TaxValue * - 1 ELSE Invoice.tbItem.TaxValue END AS TaxValue
FROM         Invoice.tbItem INNER JOIN
                      Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE     (Invoice.tbInvoice.InvoicedOn >= App.fnHistoryStartOn())

GO
ALTER AUTHORIZATION ON Invoice.vwSummaryItems TO  SCHEMA OWNER 
GO
CREATE VIEW Invoice.vwSummaryBase
AS
SELECT     StartOn, InvoiceTypeCode, InvoiceValue, TaxValue
FROM         Invoice.vwSummaryItems
UNION
SELECT     StartOn, InvoiceTypeCode, InvoiceValue, TaxValue
FROM         Invoice.vwSummaryTasks

GO
ALTER AUTHORIZATION ON Invoice.vwSummaryBase TO  SCHEMA OWNER 
GO
CREATE VIEW Invoice.vwSummaryTotals
  AS
SELECT     Invoice.vwSummaryBase.StartOn, Invoice.vwSummaryBase.InvoiceTypeCode, Invoice.tbType.InvoiceType, 
                      SUM(Invoice.vwSummaryBase.InvoiceValue) AS TotalInvoiceValue, SUM(Invoice.vwSummaryBase.TaxValue) AS TotalTaxValue
FROM         Invoice.vwSummaryBase INNER JOIN
                      Invoice.tbType ON Invoice.vwSummaryBase.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
GROUP BY Invoice.vwSummaryBase.StartOn, Invoice.vwSummaryBase.InvoiceTypeCode, Invoice.tbType.InvoiceType
GO
ALTER AUTHORIZATION ON Invoice.vwSummaryTotals TO  SCHEMA OWNER 
GO
CREATE VIEW Invoice.vwSummaryMargin
  AS
SELECT     StartOn, 5 AS InvoiceTypeCode, App.fnProfileText(3004) AS InvoiceType, SUM(TotalInvoiceValue) AS TotalInvoiceValue, SUM(TotalTaxValue) 
                      AS TotalTaxValue
FROM         Invoice.vwSummaryTotals
GROUP BY StartOn
GO
ALTER AUTHORIZATION ON Invoice.vwSummaryMargin TO  SCHEMA OWNER 
GO
CREATE VIEW Invoice.vwSummary
AS
SELECT     DATENAME(yyyy, StartOn) + '/' + FORMAT(MONTH(StartOn), '00') AS PeriodOn, StartOn, InvoiceTypeCode, InvoiceType AS InvoiceType, 
                      ABS(TotalInvoiceValue) AS TotalInvoiceValue, ABS(TotalTaxValue) AS TotalTaxValue
FROM         Invoice.vwSummaryTotals
UNION
SELECT     DATENAME(yyyy, StartOn) + '/' + FORMAT(MONTH(StartOn), '00') AS PeriodOn, StartOn, InvoiceTypeCode, InvoiceType AS InvoiceType, 
                      TotalInvoiceValue, TotalTaxValue
FROM         Invoice.vwSummaryMargin

GO
ALTER AUTHORIZATION ON Invoice.vwSummary TO  SCHEMA OWNER 
GO

GO

GO


CREATE VIEW Invoice.vwTaxBase
  AS
SELECT     InvoiceNumber, TaxCode, SUM(InvoiceValue) AS InvoiceValueTotal, SUM(TaxValue) AS TaxValueTotal
FROM         Invoice.tbItem
GROUP BY InvoiceNumber, TaxCode
HAVING      (NOT (TaxCode IS NULL))
UNION
SELECT     InvoiceNumber, TaxCode, SUM(InvoiceValue) AS InvoiceValueTotal, SUM(TaxValue) AS TaxValueTotal
FROM         Invoice.tbTask
GROUP BY InvoiceNumber, TaxCode
HAVING      (NOT (TaxCode IS NULL))
GO
ALTER AUTHORIZATION ON Invoice.vwTaxBase TO  SCHEMA OWNER 
GO
CREATE VIEW Invoice.vwTaxSummary
  AS
SELECT     InvoiceNumber, TaxCode, SUM(InvoiceValueTotal) AS InvoiceValueTotal, SUM(TaxValueTotal) AS TaxValueTotal, SUM(TaxValueTotal) 
                      / SUM(InvoiceValueTotal) AS TaxRate
FROM         Invoice.vwTaxBase
GROUP BY InvoiceNumber, TaxCode
GO
ALTER AUTHORIZATION ON Invoice.vwTaxSummary TO  SCHEMA OWNER 
GO
CREATE VIEW Org.vwMailContacts
  AS
SELECT     AccountCode, ContactName, NickName, NameTitle + N' ' + ContactName AS FormalName, JobTitle, Department
FROM         Org.tbContact
WHERE     (OnMailingList <> 0)
GO
ALTER AUTHORIZATION ON Org.vwMailContacts TO  SCHEMA OWNER 
GO
CREATE VIEW Org.vwAddresses
  AS
SELECT     TOP 100 PERCENT Org.tbOrg.AccountName, Org.tbAddress.[Address], Org.tbOrg.OrganisationTypeCode, Org.tbOrg.OrganisationStatusCode, 
                      Org.tbType.OrganisationType, Org.tbStatus.OrganisationStatus, Org.vwMailContacts.ContactName, Org.vwMailContacts.NickName, 
                      Org.vwMailContacts.FormalName, Org.vwMailContacts.JobTitle, Org.vwMailContacts.Department
FROM         Org.tbOrg INNER JOIN
                      Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode INNER JOIN
                      Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode INNER JOIN
                      Org.tbStatus ON Org.tbOrg.OrganisationStatusCode = Org.tbStatus.OrganisationStatusCode LEFT OUTER JOIN
                      Org.vwMailContacts ON Org.tbOrg.AccountCode = Org.vwMailContacts.AccountCode
ORDER BY Org.tbOrg.AccountName
GO
ALTER AUTHORIZATION ON Org.vwAddresses TO  SCHEMA OWNER 
GO
CREATE VIEW Org.vwTaskCount
  AS
SELECT     AccountCode, COUNT(TaskCode) AS TaskCount
FROM         Task.tbTask
WHERE     (TaskStatusCode < 3)
GROUP BY AccountCode
GO
ALTER AUTHORIZATION ON Org.vwTaskCount TO  SCHEMA OWNER 
GO
CREATE VIEW Org.vwDatasheet
AS
SELECT     Org.tbOrg.AccountCode, Org.tbOrg.AccountName, ISNULL(Org.vwTaskCount.TaskCount, 0) AS Tasks, Org.tbOrg.OrganisationTypeCode, 
                      Org.tbType.OrganisationType, Org.tbType.CashModeCode, Org.tbOrg.OrganisationStatusCode, Org.tbStatus.OrganisationStatus, 
                      Org.tbAddress.[Address], App.tbTaxCode.TaxDescription, Org.tbOrg.TaxCode, Org.tbOrg.AddressCode, Org.tbOrg.AreaCode, 
                      Org.tbOrg.PhoneNumber, Org.tbOrg.FaxNumber, Org.tbOrg.EmailAddress, Org.tbOrg.WebSite, Org.fnIndustrySectors(Org.tbOrg.AccountCode) 
                      AS IndustrySector, Org.tbOrg.AccountSource, Org.tbOrg.PaymentTerms, Org.tbOrg.PaymentDays, Org.tbOrg.NumberOfEmployees, 
                      Org.tbOrg.CompanyNumber, Org.tbOrg.VatNumber, Org.tbOrg.Turnover, Org.tbOrg.StatementDays, Org.tbOrg.OpeningBalance, 
                      Org.tbOrg.CurrentBalance, Org.tbOrg.ForeignJurisdiction, Org.tbOrg.BusinessDescription, Org.tbOrg.InsertedBy, Org.tbOrg.InsertedOn, 
                      Org.tbOrg.UpdatedBy, Org.tbOrg.UpdatedOn, Org.tbOrg.PayDaysFromMonthEnd
FROM         Org.tbOrg INNER JOIN
                      Org.tbStatus ON Org.tbOrg.OrganisationStatusCode = Org.tbStatus.OrganisationStatusCode INNER JOIN
                      Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode LEFT OUTER JOIN
                      App.tbTaxCode ON Org.tbOrg.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                      Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode LEFT OUTER JOIN
                      Org.vwTaskCount ON Org.tbOrg.AccountCode = Org.vwTaskCount.AccountCode

GO
ALTER AUTHORIZATION ON Org.vwDatasheet TO  SCHEMA OWNER 
GO
CREATE VIEW Task.vwOpBucket
AS
SELECT        op.TaskCode, op.OperationNumber, op.EndOn, buckets.Period, buckets.BucketId
FROM            Task.tbOp AS op CROSS APPLY
			(	SELECT  buckets.Period, buckets.BucketId
				FROM        App.fnBuckets(SYSDATETIME()) buckets 
				WHERE     (StartDate <= op.EndOn) AND (EndDate > op.EndOn)) AS buckets

GO
ALTER AUTHORIZATION ON Task.vwOpBucket TO  SCHEMA OWNER 
GO
CREATE VIEW Task.vwOps
AS
SELECT        Task.tbOp.TaskCode, Task.tbOp.OperationNumber, Task.vwOpBucket.Period, Task.vwOpBucket.BucketId, Task.tbOp.UserId, Task.tbOp.OpTypeCode, Task.tbOp.OpStatusCode, Task.tbOp.Operation, 
                         Task.tbOp.Note, Task.tbOp.StartOn, Task.tbOp.EndOn, Task.tbOp.Duration, Task.tbOp.OffsetDays, Task.tbOp.InsertedBy, Task.tbOp.InsertedOn, Task.tbOp.UpdatedBy, Task.tbOp.UpdatedOn, Task.tbTask.TaskTitle,
                          Task.tbStatus.TaskStatus, Task.tbTask.ActionOn, Task.tbTask.Quantity, Cash.tbCode.CashDescription, Task.tbTask.TotalCharge, Task.tbTask.AccountCode, Org.tbOrg.AccountName
FROM            Task.tbOp INNER JOIN
                         Task.tbTask ON Task.tbOp.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
                         Task.vwOpBucket ON Task.tbOp.TaskCode = Task.vwOpBucket.TaskCode AND Task.tbOp.OperationNumber = Task.vwOpBucket.OperationNumber LEFT OUTER JOIN
                         Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode

GO
ALTER AUTHORIZATION ON Task.vwOps TO  SCHEMA OWNER 
GO
CREATE VIEW Task.vwBucket
  AS
	SELECT        task.TaskCode, task.ActionOn, buckets.Period, buckets.BucketId
	FROM            Task.tbTask AS task CROSS APPLY
				(	SELECT  buckets.Period, buckets.BucketId
					FROM        App.fnBuckets(SYSDATETIME()) buckets 
					WHERE     (StartDate <= task.ActionOn) AND (EndDate > task.ActionOn)) AS buckets
GO
ALTER AUTHORIZATION ON Task.vwBucket TO  SCHEMA OWNER 
GO
CREATE VIEW Task.vwTasks
AS
SELECT        Task.tbTask.TaskCode, Task.tbTask.UserId, Task.tbTask.AccountCode, Task.tbTask.ContactName, Task.tbTask.ActivityCode, Task.tbTask.TaskTitle, Task.tbTask.TaskStatusCode, Task.tbTask.ActionById, 
                         Task.tbTask.ActionOn, Task.tbTask.ActionedOn, Task.tbTask.PaymentOn, Task.tbTask.SecondReference, Task.tbTask.TaskNotes, Task.tbTask.TaxCode, Task.tbTask.Quantity, Task.tbTask.UnitCharge, 
                         Task.tbTask.TotalCharge, Task.tbTask.AddressCodeFrom, Task.tbTask.AddressCodeTo, Task.tbTask.Printed, Task.tbTask.Spooled, Task.tbTask.InsertedBy, Task.tbTask.InsertedOn, Task.tbTask.UpdatedBy, 
                         Task.tbTask.UpdatedOn, Task.vwBucket.Period, Task.vwBucket.BucketId, TaskStatus.TaskStatus, Task.tbTask.CashCode, Cash.tbCode.CashDescription, tbUser_1.UserName AS OwnerName, 
                         Usr.tbUser.UserName AS ActionName, Org.tbOrg.AccountName, OrgStatus.OrganisationStatus, Org.tbType.OrganisationType, CASE WHEN Cash.tbCategory.CategoryCode IS NULL 
                         THEN Org.tbType.CashModeCode ELSE Cash.tbCategory.CashModeCode END AS CashModeCode
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

GO
ALTER AUTHORIZATION ON Task.vwTasks TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwTaxCorpTotals
AS
SELECT        TOP (100) PERCENT Cash.vwCorpTaxInvoice.StartOn, YEAR(App.tbYearPeriod.StartOn) AS PeriodYear, App.tbYear.[Description], CONCAT(App.tbMonth.[MonthName], SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS Period, App.tbYearPeriod.CorporationTaxRate, App.tbYearPeriod.TaxAdjustment, SUM(Cash.vwCorpTaxInvoice.NetProfit) AS NetProfit, SUM(Cash.vwCorpTaxInvoice.CorporationTax) AS CorporationTax
FROM            Cash.vwCorpTaxInvoice INNER JOIN
                         App.tbYearPeriod ON Cash.vwCorpTaxInvoice.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
WHERE        (App.tbYear.CashStatusCode = 2) OR
                         (App.tbYear.CashStatusCode = 3)
GROUP BY App.tbYear.[Description], App.tbMonth.[MonthName], Cash.vwCorpTaxInvoice.StartOn, YEAR(App.tbYearPeriod.StartOn), App.tbYearPeriod.CorporationTaxRate, App.tbYearPeriod.TaxAdjustment
ORDER BY Cash.vwCorpTaxInvoice.StartOn
GO
ALTER AUTHORIZATION ON Cash.vwTaxCorpTotals TO  SCHEMA OWNER 
GO
CREATE VIEW Invoice.vwRegisterExpenses
 AS
SELECT     Invoice.vwRegisterTasks.StartOn, Invoice.vwRegisterTasks.InvoiceNumber, Invoice.vwRegisterTasks.TaskCode, App.tbYearPeriod.YearNumber, 
                      App.tbYear.[Description], CONCAT(App.tbMonth.[MonthName], SPACE(1), YEAR( App.tbYearPeriod.StartOn)) AS Period, Invoice.vwRegisterTasks.TaskTitle, 
                      Invoice.vwRegisterTasks.CashCode, Invoice.vwRegisterTasks.CashDescription, Invoice.vwRegisterTasks.TaxCode, Invoice.vwRegisterTasks.TaxDescription, 
                      Invoice.vwRegisterTasks.AccountCode, Invoice.vwRegisterTasks.InvoiceTypeCode, Invoice.vwRegisterTasks.InvoiceStatusCode, Invoice.vwRegisterTasks.InvoicedOn, 
                      Invoice.vwRegisterTasks.InvoiceValue, Invoice.vwRegisterTasks.TaxValue, Invoice.vwRegisterTasks.PaidValue, Invoice.vwRegisterTasks.PaidTaxValue, 
                      Invoice.vwRegisterTasks.PaymentTerms, Invoice.vwRegisterTasks.Printed, Invoice.vwRegisterTasks.AccountName, Invoice.vwRegisterTasks.UserName, 
                      Invoice.vwRegisterTasks.InvoiceStatus, Invoice.vwRegisterTasks.CashModeCode, Invoice.vwRegisterTasks.InvoiceType, 
                      (Invoice.vwRegisterTasks.InvoiceValue + Invoice.vwRegisterTasks.TaxValue) - (Invoice.vwRegisterTasks.PaidValue + Invoice.vwRegisterTasks.PaidTaxValue) 
                      AS UnpaidValue
FROM         Invoice.vwRegisterTasks INNER JOIN
                      App.tbYearPeriod ON Invoice.vwRegisterTasks.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                      App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                      App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
WHERE     (Task.fnIsExpense(Invoice.vwRegisterTasks.TaskCode) = 1)

GO
ALTER AUTHORIZATION ON Invoice.vwRegisterExpenses TO  SCHEMA OWNER 
GO
CREATE VIEW Task.vwInvoiceValue
AS
SELECT        TaskCode, SUM(InvoiceValue) AS InvoiceValue, SUM(TaxValue) AS InvoiceTax
FROM            Invoice.tbTask
GROUP BY TaskCode
GO
ALTER AUTHORIZATION ON Task.vwInvoiceValue TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwCodeOrderSummary
AS
SELECT        Task.tbTask.CashCode, App.fnAccountPeriod(Task.tbTask.ActionOn) AS StartOn, SUM(Task.tbTask.TotalCharge) - ISNULL(Task.vwInvoiceValue.InvoiceValue, 0) 
                         AS InvoiceValue, SUM(Task.tbTask.TotalCharge * ISNULL(App.vwTaxRates.TaxRate, 0)) - ISNULL(Task.vwInvoiceValue.InvoiceTax, 0) AS InvoiceTax
FROM            Task.tbTask INNER JOIN
                         Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
                         Task.vwInvoiceValue ON Task.tbTask.TaskCode = Task.vwInvoiceValue.TaskCode LEFT OUTER JOIN
                         App.vwTaxRates ON Task.tbTask.TaxCode = App.vwTaxRates.TaxCode
WHERE        (Task.tbTask.TaskStatusCode = 2) OR
                         (Task.tbTask.TaskStatusCode = 3)
GROUP BY Task.tbTask.CashCode, App.fnAccountPeriod(Task.tbTask.ActionOn), Task.vwInvoiceValue.InvoiceValue, Task.vwInvoiceValue.InvoiceTax

GO
ALTER AUTHORIZATION ON Cash.vwCodeOrderSummary TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwSummaryInvoices
  AS
SELECT     Invoice.tbInvoice.InvoiceNumber, CASE Invoice.tbInvoice.InvoiceTypeCode WHEN 1 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) 
                      WHEN 4 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) ELSE 0 END AS ToCollect, 
                      CASE Invoice.tbInvoice.InvoiceTypeCode WHEN 2 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) WHEN 3 THEN (InvoiceValue + TaxValue) 
                      - (PaidValue + PaidTaxValue) ELSE 0 END AS ToPay, CASE Invoice.tbType.CashModeCode WHEN 1 THEN (TaxValue - PaidTaxValue) 
                      * - 1 WHEN 2 THEN TaxValue - PaidTaxValue END AS TaxValue
FROM         Invoice.tbInvoice INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE     (Invoice.tbInvoice.InvoiceStatusCode = 2) OR
                      (Invoice.tbInvoice.InvoiceStatusCode = 3)
GO
ALTER AUTHORIZATION ON Cash.vwSummaryInvoices TO  SCHEMA OWNER 
GO
CREATE  VIEW Cash.vwSummaryBase
  AS
SELECT     ISNULL(SUM(ToCollect), 0) AS Collect, ISNULL(SUM(ToPay), 0) AS Pay, ISNULL(SUM(TaxValue), 0) + App.fnVatBalance() 
                      + App.fnCorpTaxBalance() AS Tax, Cash.fnCompanyBalance() AS CompanyBalance
FROM         Cash.vwSummaryInvoices
GO
ALTER AUTHORIZATION ON Cash.vwSummaryBase TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwSummary
  AS
SELECT     SYSDATETIME() AS [Timestamp], Collect, Pay, Tax, CompanyBalance AS Cash, CompanyBalance + Collect - Pay - Tax AS Balance
FROM         Cash.vwSummaryBase
GO
ALTER AUTHORIZATION ON Cash.vwSummary TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwAccountStatement
  AS
SELECT     Org.tbPayment.PaymentCode, Org.tbPayment.CashAccountCode, Usr.tbUser.UserName, Org.tbPayment.AccountCode, 
                      Org.tbOrg.AccountName, Org.tbPayment.CashCode, Cash.tbCode.CashDescription, App.tbTaxCode.TaxDescription, 
                      Org.tbPayment.PaidOn, Org.tbPayment.PaidInValue, Org.tbPayment.PaidOutValue, Org.tbPayment.TaxInValue, 
                      Org.tbPayment.TaxOutValue, Org.tbPayment.PaymentReference, Org.tbPayment.InsertedBy, Org.tbPayment.InsertedOn, 
                      Org.tbPayment.UpdatedBy, Org.tbPayment.UpdatedOn, Org.tbPayment.TaxCode
FROM         Org.tbPayment INNER JOIN
                      Usr.tbUser ON Org.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
                      Org.tbOrg ON Org.tbPayment.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                      App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                      Cash.tbCode ON Org.tbPayment.CashCode = Cash.tbCode.CashCode
GO
ALTER AUTHORIZATION ON Cash.vwAccountStatement TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwAccountStatements
  AS
SELECT     TOP 100 PERCENT fnCashAccountStatements.CashAccountCode, App.fnAccountPeriod(fnCashAccountStatements.PaidOn) AS StartOn, 
                      fnCashAccountStatements.EntryNumber, fnCashAccountStatements.PaymentCode, fnCashAccountStatements.PaidOn, 
                      Cash.vwAccountStatement.AccountName, Cash.vwAccountStatement.PaymentReference, Cash.vwAccountStatement.PaidInValue, 
                      Cash.vwAccountStatement.PaidOutValue, fnCashAccountStatements.PaidBalance, Cash.vwAccountStatement.TaxInValue, 
                      Cash.vwAccountStatement.TaxOutValue, fnCashAccountStatements.TaxedBalance, Cash.vwAccountStatement.CashCode, 
                      Cash.vwAccountStatement.CashDescription, Cash.vwAccountStatement.TaxDescription, Cash.vwAccountStatement.UserName, 
                      Cash.vwAccountStatement.AccountCode, Cash.vwAccountStatement.TaxCode
FROM         Cash.fnAccountStatements() fnCashAccountStatements LEFT OUTER JOIN
                      Cash.vwAccountStatement ON fnCashAccountStatements.PaymentCode = Cash.vwAccountStatement.PaymentCode
ORDER BY fnCashAccountStatements.CashAccountCode, fnCashAccountStatements.EntryNumber
GO
ALTER AUTHORIZATION ON Cash.vwAccountStatements TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwAccountLastPeriodEntry
  AS
SELECT     CashAccountCode, StartOn, MAX(EntryNumber) AS LastEntry
FROM         Cash.vwAccountStatements
GROUP BY CashAccountCode, StartOn
HAVING      (NOT (StartOn IS NULL))
GO
ALTER AUTHORIZATION ON Cash.vwAccountLastPeriodEntry TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwAccountPeriodClosingBalance
AS
SELECT        Org.tbAccount.CashCode, Cash.vwAccountLastPeriodEntry.StartOn, SUM(Cash.vwAccountStatements.PaidBalance) 
                         + SUM(Cash.vwAccountStatements.TaxedBalance) AS ClosingBalance
FROM            Cash.vwAccountLastPeriodEntry INNER JOIN
                         Cash.vwAccountStatements ON Cash.vwAccountLastPeriodEntry.CashAccountCode = Cash.vwAccountStatements.CashAccountCode AND 
                         Cash.vwAccountLastPeriodEntry.StartOn = Cash.vwAccountStatements.StartOn AND 
                         Cash.vwAccountLastPeriodEntry.LastEntry = Cash.vwAccountStatements.EntryNumber INNER JOIN
                         Org.tbAccount ON Cash.vwAccountLastPeriodEntry.CashAccountCode = Org.tbAccount.CashAccountCode
GROUP BY Org.tbAccount.CashCode, Cash.vwAccountLastPeriodEntry.StartOn
GO
ALTER AUTHORIZATION ON Cash.vwAccountPeriodClosingBalance TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwCodeForecastSummary
AS
SELECT        Task.tbTask.CashCode, App.fnAccountPeriod(Task.tbTask.ActionOn) AS StartOn, SUM(Task.tbTask.TotalCharge) AS ForecastValue, SUM(Task.tbTask.TotalCharge * ISNULL(App.vwTaxRates.TaxRate, 0)) 
                         AS ForecastTax
FROM            Task.tbTask INNER JOIN
                         Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Invoice.tbTask AS InvoiceTask ON Task.tbTask.TaskCode = InvoiceTask.TaskCode AND Task.tbTask.TaskCode = InvoiceTask.TaskCode LEFT OUTER JOIN
                         App.vwTaxRates ON Task.tbTask.TaxCode = App.vwTaxRates.TaxCode
GROUP BY Task.tbTask.CashCode, App.fnAccountPeriod(Task.tbTask.ActionOn)

GO
ALTER AUTHORIZATION ON Cash.vwCodeForecastSummary TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwAccountRebuild
  AS
SELECT     Org.tbPayment.CashAccountCode, Org.tbAccount.OpeningBalance, 
                      Org.tbAccount.OpeningBalance + SUM(Org.tbPayment.PaidInValue - Org.tbPayment.PaidOutValue) AS CurrentBalance
FROM         Org.tbPayment INNER JOIN
                      Org.tbAccount ON Org.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode
WHERE     (Org.tbPayment.PaymentStatusCode > 1)
GROUP BY Org.tbPayment.CashAccountCode, Org.tbAccount.OpeningBalance
GO
ALTER AUTHORIZATION ON Cash.vwAccountRebuild TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwActiveYears
   AS
SELECT     TOP 100 PERCENT App.tbYear.YearNumber, App.tbYear.[Description], Cash.tbStatus.CashStatus
FROM         App.tbYear INNER JOIN
                      Cash.tbStatus ON App.tbYear.CashStatusCode = Cash.tbStatus.CashStatusCode
WHERE     (App.tbYear.CashStatusCode < 4)
ORDER BY App.tbYear.YearNumber
GO
ALTER AUTHORIZATION ON Cash.vwActiveYears TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwAnalysisCodes
   AS
SELECT     TOP 100 PERCENT Cash.tbCategory.CategoryCode, Cash.tbCategory.Category, Cash.tbCategoryExp.Expression, 
                      Cash.tbCategoryExp.[Format]
FROM         Cash.tbCategory INNER JOIN
                      Cash.tbCategoryExp ON Cash.tbCategory.CategoryCode = Cash.tbCategoryExp.CategoryCode
WHERE     (Cash.tbCategory.CategoryTypeCode = 3)
ORDER BY Cash.tbCategory.DisplayOrder
GO
ALTER AUTHORIZATION ON Cash.vwAnalysisCodes TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwCategoriesBank
   AS
SELECT     TOP 100 PERCENT CategoryCode, Category, CashModeCode
FROM         Cash.tbCategory
WHERE     (CashTypeCode = 4) AND (CategoryTypeCode = 1)
GROUP BY CategoryCode, Category, DisplayOrder, CashModeCode
ORDER BY DisplayOrder, Category
GO
ALTER AUTHORIZATION ON Cash.vwCategoriesBank TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwCategoriesNominal
   AS
SELECT     TOP 100 PERCENT CategoryCode, Category, CashModeCode
FROM         Cash.tbCategory
WHERE     (CashTypeCode = 3) AND (CategoryTypeCode = 1)
GROUP BY CategoryCode, Category, DisplayOrder, CashModeCode
ORDER BY DisplayOrder, Category
GO
ALTER AUTHORIZATION ON Cash.vwCategoriesNominal TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwCategoriesTax
AS
SELECT        TOP (100) PERCENT CategoryCode, Category, CashModeCode
FROM            Cash.tbCategory
WHERE        (CashTypeCode = 2) AND (CategoryTypeCode = 1)
GROUP BY CategoryCode, Category, DisplayOrder, CashModeCode
ORDER BY DisplayOrder, Category
GO
ALTER AUTHORIZATION ON Cash.vwCategoriesTax TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwCategoriesTotals
   AS
SELECT     TOP 100 PERCENT CategoryCode, CashModeCode, CashTypeCode, DisplayOrder, Category
FROM         Cash.tbCategory
WHERE     (CategoryTypeCode = 2)
ORDER BY CashTypeCode, CategoryCode
GO
ALTER AUTHORIZATION ON Cash.vwCategoriesTotals TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwCategoriesTrade
   AS
SELECT     TOP 100 PERCENT CategoryCode, Category, CashModeCode
FROM         Cash.tbCategory
WHERE     (CashTypeCode = 1) AND (CategoryTypeCode = 1)
GROUP BY CategoryCode, Category, DisplayOrder, CashModeCode
ORDER BY DisplayOrder, Category
GO
ALTER AUTHORIZATION ON Cash.vwCategoriesTrade TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwFlowNITotals
AS
SELECT        Cash.tbPeriod.StartOn, SUM(Cash.tbPeriod.ForecastTax) AS ForecastNI, SUM(Cash.tbPeriod.InvoiceTax) AS InvoiceNI
FROM            Cash.tbPeriod INNER JOIN
                         Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode INNER JOIN
                         App.tbTaxCode ON Cash.tbCode.TaxCode = App.tbTaxCode.TaxCode
WHERE        (App.tbTaxCode.TaxTypeCode = 3)
GROUP BY Cash.tbPeriod.StartOn
GO
ALTER AUTHORIZATION ON Cash.vwFlowNITotals TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwMonthList
  AS
SELECT DISTINCT 
                      TOP 100 PERCENT CAST(App.tbYearPeriod.StartOn AS float) AS StartOn, App.tbMonth.[MonthName], 
                      App.tbYearPeriod.MonthNumber
FROM         App.tbYearPeriod INNER JOIN
                      App.fnActivePeriod() AS fnSystemActivePeriod ON App.tbYearPeriod.YearNumber = fnSystemActivePeriod.YearNumber INNER JOIN
                      App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
ORDER BY StartOn
GO
ALTER AUTHORIZATION ON Cash.vwMonthList TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwPeriods
   AS
SELECT     Cash.tbCode.CashCode, App.tbYearPeriod.StartOn
FROM         App.tbYearPeriod CROSS JOIN
                      Cash.tbCode
GO
ALTER AUTHORIZATION ON Cash.vwPeriods TO  SCHEMA OWNER 
GO
CREATE VIEW Usr.vwDoc
AS
SELECT     Org.tbOrg.AccountName AS CompanyName, Org.tbAddress.[Address] AS CompanyAddress, Org.tbOrg.PhoneNumber AS CompanyPhoneNumber, 
                      Org.tbOrg.FaxNumber AS CompanyFaxNumber, Org.tbOrg.EmailAddress AS CompanyEmailAddress, Org.tbOrg.WebSite AS CompanyWebsite, 
                      Org.tbOrg.CompanyNumber, Org.tbOrg.VatNumber, Org.tbOrg.Logo
FROM         Org.tbOrg INNER JOIN
                      App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode LEFT OUTER JOIN
                      Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode
GO
ALTER AUTHORIZATION ON Usr.vwDoc TO  SCHEMA OWNER 
GO

CREATE VIEW Invoice.vwDoc
AS
SELECT     Org.tbOrg.EmailAddress, Usr.tbUser.UserName, Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbAddress.[Address] AS InvoiceAddress, 
                      Invoice.tbInvoice.InvoiceNumber, Invoice.tbType.InvoiceType, Invoice.tbStatus.InvoiceStatus, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.CollectOn, 
                      Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes
FROM         Invoice.tbInvoice INNER JOIN
                      Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                      Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId INNER JOIN
                      Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode LEFT OUTER JOIN
                      Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode
GO
ALTER AUTHORIZATION ON Invoice.vwDoc TO  SCHEMA OWNER 
GO
CREATE VIEW Invoice.vwDocItem
AS
SELECT     Invoice.tbItem.InvoiceNumber, Invoice.tbItem.CashCode, Cash.tbCode.CashDescription, Invoice.tbInvoice.InvoicedOn AS ActionedOn, 
                      Invoice.tbItem.TaxCode, Invoice.tbItem.InvoiceValue, Invoice.tbItem.TaxValue, Invoice.tbItem.ItemReference
FROM         Invoice.tbItem INNER JOIN
                      Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode INNER JOIN
                      Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
GO
ALTER AUTHORIZATION ON Invoice.vwDocItem TO  SCHEMA OWNER 
GO
CREATE VIEW Invoice.vwDocTask
AS
SELECT        tbTaskInvoice.InvoiceNumber, tbTaskInvoice.TaskCode, Task.tbTask.TaskTitle, Task.tbTask.ActivityCode, tbTaskInvoice.CashCode, Cash.tbCode.CashDescription, Task.tbTask.ActionedOn, tbTaskInvoice.Quantity, 
                         Activity.tbActivity.UnitOfMeasure, tbTaskInvoice.InvoiceValue, tbTaskInvoice.TaxValue, tbTaskInvoice.TaxCode, Task.tbTask.SecondReference
FROM            Invoice.tbTask AS tbTaskInvoice INNER JOIN
                         Task.tbTask ON tbTaskInvoice.TaskCode = Task.tbTask.TaskCode AND tbTaskInvoice.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Cash.tbCode ON tbTaskInvoice.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode
GO
ALTER AUTHORIZATION ON Invoice.vwDocTask TO  SCHEMA OWNER 
GO
CREATE VIEW Task.vwDoc
AS
SELECT     Task.fnEmailAddress(Task.tbTask.TaskCode) AS EmailAddress, Task.tbTask.TaskCode, Task.tbTask.TaskStatusCode, Task.tbStatus.TaskStatus, 
                      Task.tbTask.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, Org.tbAddress.[Address] AS InvoiceAddress, 
                      Org_tb1.AccountName AS DeliveryAccountName, Org_tbAddress1.[Address] AS DeliveryAddress, Org_tb2.AccountName AS CollectionAccountName, 
                      Org_tbAddress2.[Address] AS CollectionAddress, Task.tbTask.AccountCode, Task.tbTask.TaskNotes, Task.tbTask.ActivityCode, Task.tbTask.ActionOn, 
                      Activity.tbActivity.UnitOfMeasure, Task.tbTask.Quantity, App.tbTaxCode.TaxCode, App.tbTaxCode.TaxRate, Task.tbTask.UnitCharge, Task.tbTask.TotalCharge, 
                      Usr.tbUser.MobileNumber, Usr.tbUser.Signature, Task.tbTask.TaskTitle, Task.tbTask.PaymentOn, Task.tbTask.SecondReference, Org.tbOrg.PaymentTerms
FROM         Org.tbOrg AS Org_tb2 RIGHT OUTER JOIN
                      Org.tbAddress AS Org_tbAddress2 ON Org_tb2.AccountCode = Org_tbAddress2.AccountCode RIGHT OUTER JOIN
                      Task.tbStatus INNER JOIN
                      Usr.tbUser INNER JOIN
                      Activity.tbActivity INNER JOIN
                      Task.tbTask ON Activity.tbActivity.ActivityCode = Task.tbTask.ActivityCode INNER JOIN
                      Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                      Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode ON Usr.tbUser.UserId = Task.tbTask.ActionById ON 
                      Task.tbStatus.TaskStatusCode = Task.tbTask.TaskStatusCode LEFT OUTER JOIN
                      Org.tbAddress AS Org_tbAddress1 LEFT OUTER JOIN
                      Org.tbOrg AS Org_tb1 ON Org_tbAddress1.AccountCode = Org_tb1.AccountCode ON Task.tbTask.AddressCodeTo = Org_tbAddress1.AddressCode ON 
                      Org_tbAddress2.AddressCode = Task.tbTask.AddressCodeFrom LEFT OUTER JOIN
                      Org.tbContact ON Task.tbTask.ContactName = Org.tbContact.ContactName AND Task.tbTask.AccountCode = Org.tbContact.AccountCode LEFT OUTER JOIN
                      App.tbTaxCode ON Task.tbTask.TaxCode = App.tbTaxCode.TaxCode
GO
ALTER AUTHORIZATION ON Task.vwDoc TO  SCHEMA OWNER 
GO
CREATE VIEW Invoice.vwRegister
AS
SELECT     App.fnAccountPeriod(Invoice.tbInvoice.InvoicedOn) AS StartOn, Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, 
                      Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbInvoice.InvoicedOn, 
                      CASE WHEN Invoice.tbType.CashModeCode = 1 THEN Invoice.tbInvoice.InvoiceValue * - 1 ELSE Invoice.tbInvoice.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN Invoice.tbType.CashModeCode = 1 THEN Invoice.tbInvoice.TaxValue * - 1 ELSE Invoice.tbInvoice.TaxValue END AS TaxValue, 
                      CASE WHEN Invoice.tbType.CashModeCode = 1 THEN Invoice.tbInvoice.PaidValue * - 1 ELSE Invoice.tbInvoice.PaidValue END AS PaidValue, 
                      CASE WHEN Invoice.tbType.CashModeCode = 1 THEN Invoice.tbInvoice.PaidTaxValue * - 1 ELSE Invoice.tbInvoice.PaidTaxValue END AS PaidTaxValue, 
                      Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, Invoice.tbInvoice.Printed, Org.tbOrg.AccountName, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, 
                      Invoice.tbType.CashModeCode, Invoice.tbType.InvoiceType
FROM         Invoice.tbInvoice INNER JOIN
                      Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                      Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                      Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE     (Invoice.tbInvoice.AccountCode <> App.fnCompanyAccount())
GO
ALTER AUTHORIZATION ON Invoice.vwRegister TO  SCHEMA OWNER 
GO
CREATE VIEW Org.vwBalanceOutstanding
  AS
SELECT     Invoice.tbInvoice.AccountCode, SUM(CASE Invoice.tbType.CashModeCode WHEN 1 THEN ((InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue)) 
                      * - 1 WHEN 2 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) END) AS Balance
FROM         Invoice.tbInvoice INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE     (Invoice.tbInvoice.InvoiceStatusCode > 1 AND Invoice.tbInvoice.InvoiceStatusCode < 4)
GROUP BY Invoice.tbInvoice.AccountCode
GO
ALTER AUTHORIZATION ON Org.vwBalanceOutstanding TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwStatement
AS
SELECT     TOP (100) PERCENT fnStatementCompany.TransactOn, fnStatementCompany.CashEntryTypeCode, fnStatementCompany.ReferenceCode, 
                      fnStatementCompany.AccountCode, Org.tbOrg.AccountName, Cash.tbEntryType.CashEntryType, fnStatementCompany.PayOut, 
                      fnStatementCompany.PayIn, fnStatementCompany.Balance, Cash.tbCode.CashCode, Cash.tbCode.CashDescription
FROM         Cash.fnStatementCompany() AS fnStatementCompany INNER JOIN
                      Cash.tbEntryType ON fnStatementCompany.CashEntryTypeCode = Cash.tbEntryType.CashEntryTypeCode INNER JOIN
                      Org.tbOrg ON fnStatementCompany.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                      Cash.tbCode ON fnStatementCompany.CashCode = Cash.tbCode.CashCode
ORDER BY fnStatementCompany.TransactOn, fnStatementCompany.CashEntryTypeCode, fnStatementCompany.ReferenceCode, fnStatementCompany.CashCode
GO
ALTER AUTHORIZATION ON Cash.vwStatement TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwStatementCorpTaxDueDate
AS
SELECT        PayOn
FROM            Cash.fnTaxTypeDueDates(1) AS fnTaxTypeDueDates
WHERE        (PayOn > SYSDATETIME())
GO
ALTER AUTHORIZATION ON Cash.vwStatementCorpTaxDueDate TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwStatementReserves
AS
SELECT     TOP 100 PERCENT fnStatementReserves.TransactOn, fnStatementReserves.CashEntryTypeCode, fnStatementReserves.ReferenceCode, 
                      fnStatementReserves.AccountCode, Org.tbOrg.AccountName, Cash.tbEntryType.CashEntryType, fnStatementReserves.PayOut, 
                      fnStatementReserves.PayIn, fnStatementReserves.Balance, Cash.tbCode.CashCode, Cash.tbCode.CashDescription
FROM         Cash.fnStatementReserves() AS fnStatementReserves INNER JOIN
                      Cash.tbEntryType ON fnStatementReserves.CashEntryTypeCode = Cash.tbEntryType.CashEntryTypeCode INNER JOIN
                      Org.tbOrg ON fnStatementReserves.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                      Cash.tbCode ON fnStatementReserves.CashCode = Cash.tbCode.CashCode
ORDER BY fnStatementReserves.TransactOn, fnStatementReserves.CashEntryTypeCode, fnStatementReserves.ReferenceCode, fnStatementReserves.CashCode
GO
ALTER AUTHORIZATION ON Cash.vwStatementReserves TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwStatementVatDueDate
  AS
SELECT     TOP 1 PayOn
FROM         Cash.fnTaxTypeDueDates(2) fnTaxTypeDueDates
WHERE     (PayOn > SYSDATETIME())
GO
ALTER AUTHORIZATION ON Cash.vwStatementVatDueDate TO  SCHEMA OWNER 
GO
CREATE VIEW App.vwDocSpool
 AS
SELECT     DocTypeCode, DocumentNumber
FROM         App.tbDocSpool
WHERE     (UserName = SUSER_SNAME())
GO
ALTER AUTHORIZATION ON App.vwDocSpool TO  SCHEMA OWNER 
GO
CREATE VIEW App.vwNICashCode
  AS
SELECT     CashCode, MonthNumber, RecurrenceCode
FROM         Cash.tbTaxType
WHERE     (TaxTypeCode = 3)
GO
ALTER AUTHORIZATION ON App.vwNICashCode TO  SCHEMA OWNER 
GO
CREATE VIEW Cash.vwTaxVatTotals
AS
SELECT     TOP (100) PERCENT App.tbYear.YearNumber, App.tbYear.[Description], 
                      CONCAT(App.tbMonth.[MonthName], SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS Period, fnTaxVatTotals.StartOn, fnTaxVatTotals.HomeSales, 
                      fnTaxVatTotals.HomePurchases, fnTaxVatTotals.ExportSales, fnTaxVatTotals.ExportPurchases, fnTaxVatTotals.HomeSalesVat, fnTaxVatTotals.HomePurchasesVat, 
                      fnTaxVatTotals.ExportSalesVat, fnTaxVatTotals.ExportPurchasesVat, fnTaxVatTotals.VatAdjustment, fnTaxVatTotals.VatDue
FROM         Cash.fnTaxVatTotals() AS fnTaxVatTotals INNER JOIN
                      App.tbYearPeriod ON fnTaxVatTotals.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                      App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                      App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
WHERE     (App.tbYear.CashStatusCode = 2) OR
                      (App.tbYear.CashStatusCode = 3)
ORDER BY fnTaxVatTotals.StartOn
GO
ALTER AUTHORIZATION ON Cash.vwTaxVatTotals TO  SCHEMA OWNER 
GO
CREATE VIEW Usr.vwCredentials
  AS
SELECT     UserId, UserName, LogonName, Administrator
FROM         Usr.tbUser
WHERE     (LogonName = SUSER_SNAME())
GO
ALTER AUTHORIZATION ON Usr.vwCredentials TO  SCHEMA OWNER 
GO
CREATE VIEW Task.vwProfitToDate
AS
	WITH TaskProfitToDate AS 
		(SELECT        MAX(PaymentOn) AS LastPaymentOn
		 FROM            Task.tbTask)
	SELECT TOP (100) PERCENT App.tbYearPeriod.StartOn, CONCAT(App.tbYear.[Description], SPACE(1), App.tbMonth.[MonthName]) AS Description
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
	SELECT        TOP (100) PERCENT App.tbYearPeriod.StartOn, CONCAT(App.tbYear.[Description], SPACE(1), App.tbMonth.[MonthName]) AS Description
	FROM            App.tbYearPeriod INNER JOIN
							 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
							 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
	WHERE        (App.tbYearPeriod.StartOn < DATEADD(d, 1, SYSDATETIME())) AND (App.tbYear.CashStatusCode < 4)
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
SELECT App.tbYearPeriod.YearNumber, App.tbYearPeriod.StartOn, App.tbYear.[Description], App.tbMonth.[MonthName], fnActivePeriod.EndOn
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
CREATE FUNCTION Invoice.fnEditTasks (@InvoiceNumber NVARCHAR(20), @AccountCode NVARCHAR(10))
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
CREATE FUNCTION Invoice.fnEditDebitCandidates (@InvoiceNumber NVARCHAR(20), @AccountCode NVARCHAR(10))
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
CREATE FUNCTION Invoice.fnEditCreditCandidates (@InvoiceNumber NVARCHAR(20), @AccountCode NVARCHAR(10))
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
                         Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.[Address] AS FromAddress, Org.tbAddress.[Address] AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
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
                         Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.[Address] AS FromAddress, Org.tbAddress.[Address] AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
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
                         Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.[Address] AS FromAddress, Org.tbAddress.[Address] AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
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
                         Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.[Address] AS FromAddress, Org.tbAddress.[Address] AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
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
SELECT TOP (1) Org.tbOrg.AccountName, Org.tbAddress.[Address], Org.tbOrg.PhoneNumber, Org.tbOrg.FaxNumber, Org.tbOrg.EmailAddress, Org.tbOrg.WebSite, Org.tbOrg.Logo, Usr.tbUser.UserName, Usr.tbUser.LogonName, 
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
SELECT TOP (100) PERCENT App.tbYear.[Description], App.tbMonth.[MonthName], App.tbYearPeriod.CashStatusCode, App.tbYearPeriod.YearNumber, App.tbYearPeriod.StartOn
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
SELECT TOP 100 PERCENT Cash.tbPeriod.CashCode, Cash.tbPeriod.StartOn, App.tbYearPeriod.YearNumber, App.tbMonth.[MonthName], Cash.tbPeriod.ForecastValue, Cash.tbPeriod.ForecastTax, Cash.tbPeriod.Note, 
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
SELECT TOP 100 PERCENT Cash.tbPeriod.CashCode, Cash.tbPeriod.StartOn, App.tbYearPeriod.YearNumber, App.tbMonth.[MonthName], Cash.tbPeriod.Note, Cash.tbCategory.CashModeCode, App.tbTaxCode.TaxRate, 
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
						DATEDIFF(DD, SYSDATETIME(), Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.CollectOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, 
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
                         Invoice.tbType.InvoiceType, (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) AS UnpaidValue, DATEDIFF(DD, SYSDATETIME(), 
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
                         Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.[Address] AS FromAddress, 
                         Org.tbAddress.[Address] AS ToAddress, Task.vwTasks.Printed, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, 
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
                         Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.[Address] AS FromAddress, 
                         Org.tbAddress.[Address] AS ToAddress, Task.vwTasks.Printed, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, 
                         Task.vwTasks.ActionName, Task.vwTasks.SecondReference
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 2);
GO
CREATE VIEW Org.vwCompanyHeader
AS
SELECT        TOP (1) Org.tbOrg.AccountName AS CompanyName, Org.tbAddress.[Address] AS CompanyAddress, Org.tbOrg.PhoneNumber AS CompanyPhoneNumber, Org.tbOrg.FaxNumber AS CompanyFaxNumber, 
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
SELECT        TOP (100) PERCENT App.tbYear.YearNumber, App.tbYear.[Description], App.tbYear.InsertedBy AS YearInsertedBy, App.tbYear.InsertedOn AS YearInsertedOn, App.tbYearPeriod.StartOn, App.tbMonth.[MonthName], 
                         App.tbYearPeriod.InsertedBy AS PeriodInsertedBy, App.tbYearPeriod.InsertedOn AS PeriodInsertedOn, Cash.tbStatus.CashStatus
FROM            Cash.tbStatus INNER JOIN
                         App.tbYear INNER JOIN
                         App.tbYearPeriod ON App.tbYear.YearNumber = App.tbYearPeriod.YearNumber INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber ON Cash.tbStatus.CashStatusCode = App.tbYearPeriod.CashStatusCode
ORDER BY App.tbYearPeriod.StartOn;
GO
CREATE VIEW Cash.vwAccountStatementListing
AS
SELECT        App.tbYear.YearNumber, Org.tbOrg.AccountName AS Bank, Org.tbAccount.CashAccountCode, Org.tbAccount.CashAccountName, Org.tbAccount.SortCode, Org.tbAccount.AccountNumber, CONCAT(App.tbYear.[Description], SPACE(1), 
                         App.tbMonth.[MonthName]) AS PeriodName, Cash.vwAccountStatements.StartOn, Cash.vwAccountStatements.EntryNumber, Cash.vwAccountStatements.PaymentCode, Cash.vwAccountStatements.PaidOn, 
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
CREATE VIEW Invoice.vwVatDetailListing
AS
SELECT        App.tbYearPeriod.YearNumber, App.tbYear.[Description], CONCAT(App.tbMonth.[MonthName], SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, Invoice.vwVatSummary.StartOn, 
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
                         Invoice.tbType.InvoiceType, (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) AS UnpaidValue, DATEDIFF(DD, SYSDATETIME(), 
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
                         Invoice.tbType.InvoiceType, (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) AS UnpaidValue, DATEDIFF(DD, SYSDATETIME(), 
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
                         Org.tbAddress.[Address] AS InvoiceAddress, tbInvoiceTask.TaskCode, Task.tbTask.TaskTitle, Task.tbTask.ActionedOn, tbInvoiceTask.Quantity, Activity.tbActivity.UnitOfMeasure, tbInvoiceTask.TaxCode, 
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
                         Org.tbAddress.[Address] AS InvoiceAddress, tbInvoiceTask.TaskCode, Task.tbTask.TaskTitle, Task.tbTask.ActionedOn, tbInvoiceTask.Quantity, Activity.tbActivity.UnitOfMeasure, tbInvoiceTask.TaxCode, 
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
SELECT        App.tbYearPeriod.YearNumber, CONCAT(App.tbMonth.[MonthName], SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS Period, Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.CashCode, 
                         Invoice.vwRegisterDetail.CashDescription, SUM(Invoice.vwRegisterDetail.InvoiceValue) AS TotalInvoiceValue, SUM(Invoice.vwRegisterDetail.TaxValue) AS TotalTaxValue
FROM            Invoice.vwRegisterDetail INNER JOIN
                         App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber ON Invoice.vwRegisterDetail.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
GROUP BY App.tbYearPeriod.YearNumber, CONCAT(App.tbMonth.[MonthName], SPACE(1), YEAR(App.tbYearPeriod.StartOn)), Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.CashCode, 
                         Invoice.vwRegisterDetail.CashDescription;
GO
CREATE VIEW Invoice.vwHistoryPurchaseItems
AS
SELECT        CONCAT(App.tbMonth.[MonthName], SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, App.tbYearPeriod.YearNumber, Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.InvoiceNumber, 
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
SELECT        App.tbYearPeriod.YearNumber, App.tbYear.[Description], CONCAT(App.tbMonth.[MonthName], SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, Invoice.vwRegister.StartOn, 
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
SELECT        App.tbYearPeriod.YearNumber, CONCAT(App.tbMonth.[MonthName], SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.InvoiceNumber, 
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
SELECT        App.tbYearPeriod.YearNumber, CONCAT(App.tbMonth.[MonthName], SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, Invoice.vwRegister.StartOn, 
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
                         Org.tbOrg.EmailAddress, Org.tbAddress.[Address] AS InvoiceAddress, tbInvoiceTask.TaskCode, Task.tbTask.TaskTitle, Task.tbTask.ActionedOn, tbInvoiceTask.Quantity, Activity.tbActivity.UnitOfMeasure, 
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
                        Invoice.tbInvoice.Notes, Org.tbAddress.[Address] AS InvoiceAddress, invoice_1.InvoiceValueTotal, invoice_1.TaxValueTotal, invoice_1.PaymentTerms, invoice_1.EmailAddress, invoice_1.AddressCode, 
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
SELECT        Org.vwDatasheet.AccountCode, Org.vwDatasheet.AccountName, Org.vwDatasheet.OrganisationType, Org.vwDatasheet.OrganisationStatus, Org.vwDatasheet.TaxDescription, Org.vwDatasheet.[Address], 
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
SELECT        purchase_enquiry.TaskCode, purchase_enquiry.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, Org.tbAddress.[Address] AS InvoiceAddress, 
                         collection_account.AccountName AS CollectAccount, collection_address.[Address] AS CollectAddress, delivery_account.AccountName AS DeliveryAccount, delivery_address.[Address] AS DeliveryAddress, 
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
SELECT        purchase_enquiry.TaskCode, purchase_enquiry.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, Org.tbAddress.[Address] AS InvoiceAddress, 
                         Org_tbAddress_1.[Address] AS DeliveryAddress, purchase_enquiry.AccountCode, purchase_enquiry.TaskNotes, purchase_enquiry.ActivityCode, purchase_enquiry.ActionOn, Activity.tbActivity.UnitOfMeasure, 
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
SELECT        purchase_order.TaskCode, purchase_order.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, invoice_address.[Address] AS InvoiceAddress, 
                         delivery_address.[Address] AS DeliveryAddress, purchase_order.AccountCode, purchase_order.TaskNotes, purchase_order.ActivityCode, purchase_order.ActionOn, Activity.tbActivity.UnitOfMeasure, 
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
SELECT        purchase_order.TaskCode, purchase_order.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, invoice_address.[Address] AS InvoiceAddress, 
                         delivery_account.AccountName AS CollectAccount, delivery_address.[Address] AS CollectAddress, collection_account.AccountName AS DeliveryAccount, collection_address.[Address] AS DeliveryAddress, 
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
SELECT        sales_order.TaskCode, sales_order.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, invoice_address.[Address] AS InvoiceAddress, 
                         delivery_address.[Address] AS DeliveryAddress, sales_order.AccountCode, sales_order.TaskNotes, sales_order.ActivityCode, sales_order.ActionOn, Activity.tbActivity.UnitOfMeasure, sales_order.Quantity, 
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
SELECT        sales_order.TaskCode, sales_order.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, invoice_address.[Address] AS InvoiceAddress, 
                         delivery_address.[Address] AS DeliveryAddress, sales_order.AccountCode, sales_order.TaskNotes, sales_order.TaskTitle, sales_order.ActivityCode, sales_order.ActionOn, Activity.tbActivity.UnitOfMeasure, 
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
WHERE        (Cash.vwAccountPeriodClosingBalance.StartOn > DATEADD(m, - 6, SYSDATETIME()))
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
