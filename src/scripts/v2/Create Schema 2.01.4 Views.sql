GO
CREATE VIEW [dbo].[vwInvoiceSummaryTasks]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN tbInvoice.InvoiceTypeCode = 2 THEN 1 ELSE CASE WHEN tbInvoice.InvoiceTypeCode = 4 THEN 3 ELSE tbInvoice.InvoiceTypeCode END END
                       AS InvoiceTypeCode, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.InvoiceValue * - 1 ELSE dbo.tbInvoiceTask.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.TaxValue * - 1 ELSE dbo.tbInvoiceTask.TaxValue END AS TaxValue
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
GO
CREATE VIEW [dbo].[vwInvoiceSummaryItems]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN tbInvoice.InvoiceTypeCode = 2 THEN 1 ELSE CASE WHEN tbInvoice.InvoiceTypeCode = 4 THEN 3 ELSE tbInvoice.InvoiceTypeCode END END
                       AS InvoiceTypeCode, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.InvoiceValue * - 1 ELSE dbo.tbInvoiceItem.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.TaxValue * - 1 ELSE dbo.tbInvoiceItem.TaxValue END AS TaxValue
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
GO
CREATE VIEW [dbo].[vwInvoiceSummaryBase]
AS
SELECT     StartOn, InvoiceTypeCode, InvoiceValue, TaxValue
FROM         dbo.vwInvoiceSummaryItems
UNION
SELECT     StartOn, InvoiceTypeCode, InvoiceValue, TaxValue
FROM         dbo.vwInvoiceSummaryTasks
GO
CREATE VIEW [dbo].[vwInvoiceSummaryTotals]
  AS
SELECT     dbo.vwInvoiceSummaryBase.StartOn, dbo.vwInvoiceSummaryBase.InvoiceTypeCode, dbo.tbInvoiceType.InvoiceType, 
                      SUM(dbo.vwInvoiceSummaryBase.InvoiceValue) AS TotalInvoiceValue, SUM(dbo.vwInvoiceSummaryBase.TaxValue) AS TotalTaxValue
FROM         dbo.vwInvoiceSummaryBase INNER JOIN
                      dbo.tbInvoiceType ON dbo.vwInvoiceSummaryBase.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
GROUP BY dbo.vwInvoiceSummaryBase.StartOn, dbo.vwInvoiceSummaryBase.InvoiceTypeCode, dbo.tbInvoiceType.InvoiceType
GO
CREATE VIEW [dbo].[vwOrgRebuildInvoicedItems]
AS
SELECT     dbo.tbInvoice.AccountCode, dbo.tbInvoiceType.CashModeCode, dbo.tbInvoice.CollectOn, dbo.tbInvoiceItem.InvoiceNumber, 
                      dbo.tbInvoiceItem.CashCode, '' AS TaskCode, dbo.tbInvoiceItem.InvoiceValue, dbo.tbInvoiceItem.TaxValue, dbo.tbInvoiceItem.PaidValue, 
                      dbo.tbInvoiceItem.PaidTaxValue
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
GO
CREATE VIEW [dbo].[vwOrgRebuildInvoicedTasks]
AS
SELECT     dbo.tbInvoice.AccountCode, dbo.tbInvoiceType.CashModeCode, dbo.tbInvoice.CollectOn, dbo.tbInvoiceTask.InvoiceNumber, 
                      dbo.tbInvoiceTask.CashCode, dbo.tbInvoiceTask.TaskCode, dbo.tbInvoiceTask.InvoiceValue, dbo.tbInvoiceTask.TaxValue, 
                      dbo.tbInvoiceTask.PaidValue, dbo.tbInvoiceTask.PaidTaxValue
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
GO
CREATE VIEW [dbo].[vwOrgRebuildInvoices]
AS
SELECT     AccountCode, CashModeCode, CollectOn, InvoiceNumber, CashCode, TaskCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
FROM         dbo.vwOrgRebuildInvoicedTasks
UNION
SELECT     AccountCode, CashModeCode, CollectOn, InvoiceNumber, CashCode, TaskCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
FROM         dbo.vwOrgRebuildInvoicedItems
GO
CREATE VIEW [dbo].[vwOrgRebuildInvoiceTotals]
AS
SELECT     AccountCode, InvoiceNumber, SUM(InvoiceValue) AS TotalInvoiceValue, SUM(TaxValue) AS TotalTaxValue, SUM(PaidValue) AS TotalPaidValue, 
                      SUM(PaidTaxValue) AS TotalPaidTaxValue
FROM         dbo.vwOrgRebuildInvoices
GROUP BY AccountCode, InvoiceNumber
GO
CREATE VIEW [dbo].[vwInvoiceRegisterItems]
  AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoice.InvoiceNumber, dbo.tbInvoiceItem.CashCode AS TaskCode, 
                      dbo.tbCashCode.CashCode, dbo.tbCashCode.CashDescription, dbo.tbInvoiceItem.TaxCode, dbo.tbSystemTaxCode.TaxDescription, 
                      dbo.tbInvoice.AccountCode, dbo.tbInvoice.InvoiceTypeCode, dbo.tbInvoice.InvoiceStatusCode, dbo.tbInvoice.InvoicedOn, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.InvoiceValue * - 1 ELSE dbo.tbInvoiceItem.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.TaxValue * - 1 ELSE dbo.tbInvoiceItem.TaxValue END AS TaxValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.PaidValue * - 1 ELSE dbo.tbInvoiceItem.PaidValue END AS PaidValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.PaidTaxValue * - 1 ELSE dbo.tbInvoiceItem.PaidTaxValue END AS PaidTaxValue,
                       dbo.tbInvoice.PaymentTerms, dbo.tbInvoice.Printed, dbo.tbOrg.AccountName, dbo.tbUser.UserName, dbo.tbInvoiceStatus.InvoiceStatus, 
                      dbo.tbInvoiceType.CashModeCode, dbo.tbInvoiceType.InvoiceType
FROM         dbo.tbInvoice INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode INNER JOIN
                      dbo.tbInvoiceStatus ON dbo.tbInvoice.InvoiceStatusCode = dbo.tbInvoiceStatus.InvoiceStatusCode INNER JOIN
                      dbo.tbUser ON dbo.tbInvoice.UserId = dbo.tbUser.UserId INNER JOIN
                      dbo.tbInvoiceItem ON dbo.tbInvoice.InvoiceNumber = dbo.tbInvoiceItem.InvoiceNumber INNER JOIN
                      dbo.tbCashCode ON dbo.tbInvoiceItem.CashCode = dbo.tbCashCode.CashCode LEFT OUTER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbInvoiceItem.TaxCode = dbo.tbSystemTaxCode.TaxCode
GO
CREATE VIEW [dbo].[vwInvoiceRegisterTasks]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoice.InvoiceNumber, dbo.tbInvoiceTask.TaskCode, dbo.tbTask.TaskTitle, 
                      dbo.tbCashCode.CashCode, dbo.tbCashCode.CashDescription, dbo.tbInvoiceTask.TaxCode, dbo.tbSystemTaxCode.TaxDescription, 
                      dbo.tbInvoice.AccountCode, dbo.tbInvoice.InvoiceTypeCode, dbo.tbInvoice.InvoiceStatusCode, dbo.tbInvoice.InvoicedOn, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.InvoiceValue * - 1 ELSE dbo.tbInvoiceTask.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.TaxValue * - 1 ELSE dbo.tbInvoiceTask.TaxValue END AS TaxValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.PaidValue * - 1 ELSE dbo.tbInvoiceTask.PaidValue END AS PaidValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.PaidTaxValue * - 1 ELSE dbo.tbInvoiceTask.PaidTaxValue END AS PaidTaxValue,
                       dbo.tbInvoice.PaymentTerms, dbo.tbInvoice.Printed, dbo.tbOrg.AccountName, dbo.tbUser.UserName, dbo.tbInvoiceStatus.InvoiceStatus, 
                      dbo.tbInvoiceType.CashModeCode, dbo.tbInvoiceType.InvoiceType
FROM         dbo.tbInvoice INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode INNER JOIN
                      dbo.tbInvoiceStatus ON dbo.tbInvoice.InvoiceStatusCode = dbo.tbInvoiceStatus.InvoiceStatusCode INNER JOIN
                      dbo.tbUser ON dbo.tbInvoice.UserId = dbo.tbUser.UserId INNER JOIN
                      dbo.tbInvoiceTask ON dbo.tbInvoice.InvoiceNumber = dbo.tbInvoiceTask.InvoiceNumber INNER JOIN
                      dbo.tbCashCode ON dbo.tbInvoiceTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbTask ON dbo.tbInvoiceTask.TaskCode = dbo.tbTask.TaskCode AND dbo.tbInvoiceTask.TaskCode = dbo.tbTask.TaskCode LEFT OUTER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbInvoiceTask.TaxCode = dbo.tbSystemTaxCode.TaxCode
GO
CREATE VIEW [dbo].[vwInvoiceRegisterDetail]
AS
SELECT     StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, 
                      InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, 
                      InvoiceType
FROM         dbo.vwInvoiceRegisterTasks
UNION
SELECT     StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, 
                      InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, 
                      InvoiceType
FROM         dbo.vwInvoiceRegisterItems
GO
CREATE VIEW [dbo].[vwCashCodeInvoiceSummary]
  AS
SELECT     CashCode, StartOn, ABS(SUM(InvoiceValue)) AS InvoiceValue, ABS(SUM(TaxValue)) AS TaxValue
FROM         dbo.vwInvoiceRegisterDetail
GROUP BY StartOn, CashCode
GO
CREATE VIEW [dbo].[vwOrgTaskCount]
  AS
SELECT     AccountCode, COUNT(TaskCode) AS TaskCount
FROM         dbo.tbTask
WHERE     (TaskStatusCode < 3)
GROUP BY AccountCode
GO
CREATE VIEW [dbo].[vwStatementVatDueDate]
  AS
SELECT     TOP 1 PayOn
FROM         dbo.fnTaxTypeDueDates(2) fnTaxTypeDueDates
WHERE     (PayOn > GETDATE())
GO
CREATE VIEW [dbo].[vwCashAnalysisCodes]
   AS
SELECT     TOP 100 PERCENT dbo.tbCashCategory.CategoryCode, dbo.tbCashCategory.Category, dbo.tbCashCategoryExp.Expression, 
                      dbo.tbCashCategoryExp.Format
FROM         dbo.tbCashCategory INNER JOIN
                      dbo.tbCashCategoryExp ON dbo.tbCashCategory.CategoryCode = dbo.tbCashCategoryExp.CategoryCode
WHERE     (dbo.tbCashCategory.CategoryTypeCode = 3)
ORDER BY dbo.tbCashCategory.DisplayOrder
GO
CREATE VIEW [dbo].[vwCashAccountStatement]
  AS
SELECT     dbo.tbOrgPayment.PaymentCode, dbo.tbOrgPayment.CashAccountCode, dbo.tbUser.UserName, dbo.tbOrgPayment.AccountCode, 
                      dbo.tbOrg.AccountName, dbo.tbOrgPayment.CashCode, dbo.tbCashCode.CashDescription, dbo.tbSystemTaxCode.TaxDescription, 
                      dbo.tbOrgPayment.PaidOn, dbo.tbOrgPayment.PaidInValue, dbo.tbOrgPayment.PaidOutValue, dbo.tbOrgPayment.TaxInValue, 
                      dbo.tbOrgPayment.TaxOutValue, dbo.tbOrgPayment.PaymentReference, dbo.tbOrgPayment.InsertedBy, dbo.tbOrgPayment.InsertedOn, 
                      dbo.tbOrgPayment.UpdatedBy, dbo.tbOrgPayment.UpdatedOn, dbo.tbOrgPayment.TaxCode
FROM         dbo.tbOrgPayment INNER JOIN
                      dbo.tbUser ON dbo.tbOrgPayment.UserId = dbo.tbUser.UserId INNER JOIN
                      dbo.tbOrg ON dbo.tbOrgPayment.AccountCode = dbo.tbOrg.AccountCode LEFT OUTER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbOrgPayment.TaxCode = dbo.tbSystemTaxCode.TaxCode LEFT OUTER JOIN
                      dbo.tbCashCode ON dbo.tbOrgPayment.CashCode = dbo.tbCashCode.CashCode
GO
CREATE VIEW [dbo].[vwTaskProfit]
AS
SELECT     TOP (100) PERCENT fnTaskProfit_1.StartOn, dbo.tbOrg.AccountCode, dbo.tbTask.TaskCode, dbo.tbTask.ActivityCode, dbo.tbCashCode.CashCode, 
                      dbo.tbTask.TaskTitle, dbo.tbOrg.AccountName, dbo.tbCashCode.CashDescription, dbo.tbTaskStatus.TaskStatus, fnTaskProfit_1.TotalCharge, 
                      fnTaskProfit_1.InvoicedCharge, fnTaskProfit_1.InvoicedChargePaid, fnTaskProfit_1.TotalCost, fnTaskProfit_1.InvoicedCost, 
                      fnTaskProfit_1.InvoicedCostPaid, fnTaskProfit_1.TotalCharge - fnTaskProfit_1.TotalCost AS Profit, 
                      fnTaskProfit_1.TotalCharge - fnTaskProfit_1.InvoicedCharge AS UninvoicedCharge, 
                      fnTaskProfit_1.InvoicedCharge - fnTaskProfit_1.InvoicedChargePaid AS UnpaidCharge, 
                      fnTaskProfit_1.TotalCost - fnTaskProfit_1.InvoicedCost AS UninvoicedCost, 
                      fnTaskProfit_1.InvoicedCost - fnTaskProfit_1.InvoicedCostPaid AS UnpaidCost, dbo.tbTask.ActionOn, dbo.tbTask.ActionedOn, 
                      dbo.tbTask.PaymentOn
FROM         dbo.tbTask INNER JOIN
                      dbo.fnTaskProfit() AS fnTaskProfit_1 ON dbo.tbTask.TaskCode = fnTaskProfit_1.TaskCode INNER JOIN
                      dbo.tbTaskStatus ON dbo.tbTask.TaskStatusCode = dbo.tbTaskStatus.TaskStatusCode INNER JOIN
                      dbo.tbOrg ON dbo.tbTask.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode
WHERE     (dbo.tbCashCategory.CashModeCode = 2)
ORDER BY fnTaskProfit_1.StartOn
GO
CREATE VIEW [dbo].[vwDocInvoiceItem]
AS
SELECT     dbo.tbInvoiceItem.InvoiceNumber, dbo.tbInvoiceItem.CashCode, dbo.tbCashCode.CashDescription, dbo.tbInvoice.InvoicedOn AS ActionedOn, 
                      dbo.tbInvoiceItem.TaxCode, dbo.tbInvoiceItem.InvoiceValue, dbo.tbInvoiceItem.TaxValue, dbo.tbInvoiceItem.ItemReference
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.tbCashCode ON dbo.tbInvoiceItem.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber
GO
CREATE VIEW [dbo].[vwStatement]
AS
SELECT     TOP (100) PERCENT fnStatementCompany.TransactOn, fnStatementCompany.CashEntryTypeCode, fnStatementCompany.ReferenceCode, 
                      fnStatementCompany.AccountCode, dbo.tbOrg.AccountName, dbo.tbCashEntryType.CashEntryType, fnStatementCompany.PayOut, 
                      fnStatementCompany.PayIn, fnStatementCompany.Balance, dbo.tbCashCode.CashCode, dbo.tbCashCode.CashDescription
FROM         dbo.fnStatementCompany() AS fnStatementCompany INNER JOIN
                      dbo.tbCashEntryType ON fnStatementCompany.CashEntryTypeCode = dbo.tbCashEntryType.CashEntryTypeCode INNER JOIN
                      dbo.tbOrg ON fnStatementCompany.AccountCode = dbo.tbOrg.AccountCode LEFT OUTER JOIN
                      dbo.tbCashCode ON fnStatementCompany.CashCode = dbo.tbCashCode.CashCode
ORDER BY fnStatementCompany.TransactOn, fnStatementCompany.CashEntryTypeCode, fnStatementCompany.ReferenceCode, fnStatementCompany.CashCode
GO
CREATE VIEW [dbo].[vwDocInvoiceTask]
AS
SELECT     dbo.tbInvoiceTask.InvoiceNumber, dbo.tbInvoiceTask.TaskCode, dbo.tbTask.TaskTitle, dbo.tbTask.ActivityCode, dbo.tbInvoiceTask.CashCode, 
                      dbo.tbCashCode.CashDescription, dbo.tbTask.ActionedOn, dbo.tbInvoiceTask.Quantity, dbo.tbActivity.UnitOfMeasure, dbo.tbInvoiceTask.InvoiceValue, 
                      dbo.tbInvoiceTask.TaxValue, dbo.tbInvoiceTask.TaxCode, dbo.tbTask.SecondReference
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbTask ON dbo.tbInvoiceTask.TaskCode = dbo.tbTask.TaskCode AND dbo.tbInvoiceTask.TaskCode = dbo.tbTask.TaskCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbInvoiceTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbActivity ON dbo.tbTask.ActivityCode = dbo.tbActivity.ActivityCode
GO
CREATE VIEW [dbo].[vwCashPolarData]
   AS
SELECT     dbo.tbCashPeriod.CashCode, dbo.tbCashCategory.CashTypeCode, dbo.tbCashPeriod.StartOn, dbo.tbCashPeriod.ForecastValue, 
                      dbo.tbCashPeriod.ForecastTax, dbo.tbCashPeriod.CashValue, dbo.tbCashPeriod.CashTax, dbo.tbCashPeriod.InvoiceValue, 
                      dbo.tbCashPeriod.InvoiceTax
FROM         dbo.tbCashPeriod INNER JOIN
                      dbo.tbCashCode ON dbo.tbCashPeriod.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.tbCashPeriod.StartOn = dbo.tbSystemYearPeriod.StartOn INNER JOIN
                      dbo.tbSystemYear ON dbo.tbSystemYearPeriod.YearNumber = dbo.tbSystemYear.YearNumber INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode
WHERE     (dbo.tbSystemYear.CashStatusCode < 4)
GO
CREATE VIEW [dbo].[vwCashFlowVatTotalsBase]
  AS
SELECT     dbo.tbCashPeriod.StartOn, dbo.tbCashCategory.CashModeCode, 
                      CASE WHEN tbCashCategory.CashModeCode = 2 THEN SUM(dbo.tbCashPeriod.ForecastTax) ELSE SUM(dbo.tbCashPeriod.ForecastTax) 
                      * - 1 END AS ForecastVat, CASE WHEN tbCashCategory.CashModeCode = 2 THEN SUM(dbo.tbCashPeriod.CashTax) 
                      ELSE SUM(dbo.tbCashPeriod.CashTax) * - 1 END AS CashVat, 
                      CASE WHEN tbCashCategory.CashModeCode = 2 THEN SUM(dbo.tbCashPeriod.InvoiceTax) ELSE SUM(dbo.tbCashPeriod.InvoiceTax) 
                      * - 1 END AS InvoiceVat
FROM         dbo.tbCashPeriod INNER JOIN
                      dbo.tbCashCode ON dbo.tbCashPeriod.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbCashCode.TaxCode = dbo.tbSystemTaxCode.TaxCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 2)
GROUP BY dbo.tbCashPeriod.StartOn, dbo.tbCashCategory.CashModeCode
GO
CREATE VIEW [dbo].[vwCashFlowNITotals]
  AS
SELECT     dbo.tbCashPeriod.StartOn, SUM(dbo.tbCashPeriod.ForecastTax) AS ForecastNI, SUM(dbo.tbCashPeriod.CashTax) AS CashNI, 
                      SUM(dbo.tbCashPeriod.InvoiceTax) AS InvoiceNI
FROM         dbo.tbCashPeriod INNER JOIN
                      dbo.tbCashCode ON dbo.tbCashPeriod.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbCashCode.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 3)
GROUP BY dbo.tbCashPeriod.StartOn
GO
CREATE VIEW [dbo].[vwCashPeriods]
   AS
SELECT     dbo.tbCashCode.CashCode, dbo.tbSystemYearPeriod.StartOn
FROM         dbo.tbSystemYearPeriod CROSS JOIN
                      dbo.tbCashCode
GO
CREATE VIEW [dbo].[vwCashActiveYears]
   AS
SELECT     TOP 100 PERCENT dbo.tbSystemYear.YearNumber, dbo.tbSystemYear.Description, dbo.tbCashStatus.CashStatus
FROM         dbo.tbSystemYear INNER JOIN
                      dbo.tbCashStatus ON dbo.tbSystemYear.CashStatusCode = dbo.tbCashStatus.CashStatusCode
WHERE     (dbo.tbSystemYear.CashStatusCode < 4)
ORDER BY dbo.tbSystemYear.YearNumber
GO
CREATE VIEW [dbo].[vwSystemNICashCode]
  AS
SELECT     CashCode, MonthNumber, RecurrenceCode
FROM         dbo.tbCashTaxType
WHERE     (TaxTypeCode = 3)
GO
CREATE VIEW [dbo].[vwOrgBalanceOutstanding]
  AS
SELECT     dbo.tbInvoice.AccountCode, SUM(CASE dbo.tbInvoiceType.CashModeCode WHEN 1 THEN ((InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue)) 
                      * - 1 WHEN 2 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) END) AS Balance
FROM         dbo.tbInvoice INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
WHERE     (dbo.tbInvoice.InvoiceStatusCode > 1 AND dbo.tbInvoice.InvoiceStatusCode < 4)
GROUP BY dbo.tbInvoice.AccountCode
GO
CREATE VIEW [dbo].[vwDocInvoice]
AS
SELECT     dbo.tbOrg.EmailAddress, dbo.tbUser.UserName, dbo.tbOrg.AccountCode, dbo.tbOrg.AccountName, dbo.tbOrgAddress.Address AS InvoiceAddress, 
                      dbo.tbInvoice.InvoiceNumber, dbo.tbInvoiceType.InvoiceType, dbo.tbInvoiceStatus.InvoiceStatus, dbo.tbInvoice.InvoicedOn, dbo.tbInvoice.CollectOn, 
                      dbo.tbInvoice.InvoiceValue, dbo.tbInvoice.TaxValue, dbo.tbInvoice.PaymentTerms, dbo.tbInvoice.Notes
FROM         dbo.tbInvoice INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode INNER JOIN
                      dbo.tbUser ON dbo.tbInvoice.UserId = dbo.tbUser.UserId INNER JOIN
                      dbo.tbInvoiceStatus ON dbo.tbInvoice.InvoiceStatusCode = dbo.tbInvoiceStatus.InvoiceStatusCode LEFT OUTER JOIN
                      dbo.tbOrgAddress ON dbo.tbOrg.AddressCode = dbo.tbOrgAddress.AddressCode
GO
CREATE VIEW [dbo].[vwCashSummaryInvoices]
  AS
SELECT     dbo.tbInvoice.InvoiceNumber, CASE dbo.tbInvoice.InvoiceTypeCode WHEN 1 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) 
                      WHEN 4 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) ELSE 0 END AS ToCollect, 
                      CASE dbo.tbInvoice.InvoiceTypeCode WHEN 2 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) WHEN 3 THEN (InvoiceValue + TaxValue) 
                      - (PaidValue + PaidTaxValue) ELSE 0 END AS ToPay, CASE dbo.tbInvoiceType.CashModeCode WHEN 1 THEN (TaxValue - PaidTaxValue) 
                      * - 1 WHEN 2 THEN TaxValue - PaidTaxValue END AS TaxValue
FROM         dbo.tbInvoice INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
WHERE     (dbo.tbInvoice.InvoiceStatusCode = 2) OR
                      (dbo.tbInvoice.InvoiceStatusCode = 3)
GO
CREATE VIEW [dbo].[vwAccountStatementInvoices]
  AS
SELECT     TOP 100 PERCENT dbo.tbInvoice.AccountCode, dbo.tbInvoice.InvoicedOn AS TransactedOn, 1 AS OrderBy, dbo.tbInvoice.InvoiceNumber AS Reference, 
                      dbo.tbInvoiceType.InvoiceType AS StatementType, 
                      CASE CashModeCode WHEN 1 THEN dbo.tbInvoice.InvoiceValue + dbo.tbInvoice.TaxValue WHEN 2 THEN (dbo.tbInvoice.InvoiceValue + dbo.tbInvoice.TaxValue)
                       * - 1 END AS Charge
FROM         dbo.tbInvoice INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
ORDER BY dbo.tbInvoice.AccountCode, dbo.tbInvoice.InvoicedOn
GO
CREATE VIEW [dbo].[vwInvoiceOutstandingItems]
  AS
SELECT     InvoiceNumber, '' AS TaskCode, CashCode, TaxCode, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS OutstandingValue, 
                      CASE WHEN InvoiceValue = 0 THEN 0 ELSE TaxValue / InvoiceValue END AS TaxRate
FROM         dbo.tbInvoiceItem
GO
CREATE VIEW [dbo].[vwInvoiceTaxBase]
  AS
SELECT     InvoiceNumber, TaxCode, SUM(InvoiceValue) AS InvoiceValueTotal, SUM(TaxValue) AS TaxValueTotal
FROM         dbo.tbInvoiceItem
GROUP BY InvoiceNumber, TaxCode
HAVING      (NOT (TaxCode IS NULL))
UNION
SELECT     InvoiceNumber, TaxCode, SUM(InvoiceValue) AS InvoiceValueTotal, SUM(TaxValue) AS TaxValueTotal
FROM         dbo.tbInvoiceTask
GROUP BY InvoiceNumber, TaxCode
HAVING      (NOT (TaxCode IS NULL))
GO
CREATE VIEW [dbo].[vwInvoiceOutstandingTasks]
  AS
SELECT     InvoiceNumber, TaskCode, CashCode, TaxCode, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS OutstandingValue, 
                      CASE WHEN InvoiceValue = 0 THEN 0 ELSE TaxValue / InvoiceValue END AS TaxRate
FROM         dbo.tbInvoiceTask
GO
CREATE VIEW [dbo].[vwOrgMailContacts]
  AS
SELECT     AccountCode, ContactName, NickName, NameTitle + N' ' + ContactName AS FormalName, JobTitle, Department
FROM         dbo.tbOrgContact
WHERE     (OnMailingList <> 0)
GO
CREATE VIEW [dbo].[vwDocCompany]
AS
SELECT     dbo.tbOrg.AccountName AS CompanyName, dbo.tbOrgAddress.Address AS CompanyAddress, dbo.tbOrg.PhoneNumber AS CompanyPhoneNumber, 
                      dbo.tbOrg.FaxNumber AS CompanyFaxNumber, dbo.tbOrg.EmailAddress AS CompanyEmailAddress, dbo.tbOrg.WebSite AS CompanyWebsite, 
                      dbo.tbOrg.CompanyNumber, dbo.tbOrg.VatNumber, dbo.tbOrg.Logo
FROM         dbo.tbOrg INNER JOIN
                      dbo.tbSystemOptions ON dbo.tbOrg.AccountCode = dbo.tbSystemOptions.AccountCode LEFT OUTER JOIN
                      dbo.tbOrgAddress ON dbo.tbOrg.AddressCode = dbo.tbOrgAddress.AddressCode
GO
CREATE VIEW [dbo].[vwCashAccountRebuild]
  AS
SELECT     dbo.tbOrgPayment.CashAccountCode, dbo.tbOrgAccount.OpeningBalance, 
                      dbo.tbOrgAccount.OpeningBalance + SUM(dbo.tbOrgPayment.PaidInValue - dbo.tbOrgPayment.PaidOutValue) AS CurrentBalance
FROM         dbo.tbOrgPayment INNER JOIN
                      dbo.tbOrgAccount ON dbo.tbOrgPayment.CashAccountCode = dbo.tbOrgAccount.CashAccountCode
WHERE     (dbo.tbOrgPayment.PaymentStatusCode > 1)
GROUP BY dbo.tbOrgPayment.CashAccountCode, dbo.tbOrgAccount.OpeningBalance
GO
CREATE VIEW [dbo].[vwAccountStatementPayments]
  AS
SELECT     TOP 100 PERCENT dbo.tbOrgPayment.AccountCode, dbo.tbOrgPayment.PaidOn AS TransactedOn, 2 AS OrderBy, 
                      dbo.tbOrgPayment.PaymentReference AS Reference, dbo.tbOrgPaymentStatus.PaymentStatus AS StatementType, 
                      CASE WHEN PaidInValue > 0 THEN PaidInValue ELSE PaidOutValue * - 1 END AS Charge
FROM         dbo.tbOrgPayment INNER JOIN
                      dbo.tbOrgPaymentStatus ON dbo.tbOrgPayment.PaymentStatusCode = dbo.tbOrgPaymentStatus.PaymentStatusCode
ORDER BY dbo.tbOrgPayment.AccountCode, dbo.tbOrgPayment.PaidOn
GO
CREATE VIEW [dbo].[vwTaxVatTotals]
AS
SELECT     TOP (100) PERCENT dbo.tbSystemYear.YearNumber, dbo.tbSystemYear.Description, dbo.tbSystemMonth.MonthName, fnTaxVatTotals.StartOn, 
                      fnTaxVatTotals.HomeSales, fnTaxVatTotals.HomePurchases, fnTaxVatTotals.ExportSales, fnTaxVatTotals.ExportPurchases, 
                      fnTaxVatTotals.HomeSalesVat, fnTaxVatTotals.HomePurchasesVat, fnTaxVatTotals.ExportSalesVat, fnTaxVatTotals.ExportPurchasesVat, 
                      fnTaxVatTotals.VatAdjustment, fnTaxVatTotals.VatDue
FROM         dbo.fnTaxVatTotals() AS fnTaxVatTotals INNER JOIN
                      dbo.tbSystemYearPeriod ON fnTaxVatTotals.StartOn = dbo.tbSystemYearPeriod.StartOn INNER JOIN
                      dbo.tbSystemMonth ON dbo.tbSystemYearPeriod.MonthNumber = dbo.tbSystemMonth.MonthNumber INNER JOIN
                      dbo.tbSystemYear ON dbo.tbSystemYearPeriod.YearNumber = dbo.tbSystemYear.YearNumber
ORDER BY fnTaxVatTotals.StartOn
GO
CREATE VIEW [dbo].[vwTaxCorpTotals]
AS
SELECT     TOP (100) PERCENT dbo.vwCorpTaxInvoice.StartOn, YEAR(dbo.tbSystemYearPeriod.StartOn) AS PeriodYear, dbo.tbSystemYear.Description, 
                      dbo.tbSystemMonth.MonthName, SUM(dbo.vwCorpTaxInvoice.NetProfit) AS NetProfit, SUM(dbo.vwCorpTaxInvoice.CorporationTax) 
                      AS CorporationTax
FROM         dbo.vwCorpTaxInvoice INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.vwCorpTaxInvoice.StartOn = dbo.tbSystemYearPeriod.StartOn INNER JOIN
                      dbo.tbSystemYear ON dbo.tbSystemYearPeriod.YearNumber = dbo.tbSystemYear.YearNumber INNER JOIN
                      dbo.tbSystemMonth ON dbo.tbSystemYearPeriod.MonthNumber = dbo.tbSystemMonth.MonthNumber
GROUP BY dbo.tbSystemYear.Description, dbo.tbSystemMonth.MonthName, dbo.vwCorpTaxInvoice.StartOn, YEAR(dbo.tbSystemYearPeriod.StartOn)
ORDER BY dbo.vwCorpTaxInvoice.StartOn
GO
CREATE VIEW [dbo].[vwUserCredentials]
  AS
SELECT     UserId, UserName, LogonName, Administrator
FROM         dbo.tbUser
WHERE     (LogonName = SUSER_SNAME())
GO
CREATE VIEW [dbo].[vwCashCategoriesBank]
   AS
SELECT     TOP 100 PERCENT CategoryCode, Category, CashModeCode
FROM         dbo.tbCashCategory
WHERE     (CashTypeCode = 4) AND (CategoryTypeCode = 1)
GROUP BY CategoryCode, Category, DisplayOrder, CashModeCode
ORDER BY DisplayOrder, Category
GO
CREATE VIEW [dbo].[vwCashCategoriesNominal]
   AS
SELECT     TOP 100 PERCENT CategoryCode, Category, CashModeCode
FROM         dbo.tbCashCategory
WHERE     (CashTypeCode = 3) AND (CategoryTypeCode = 1)
GROUP BY CategoryCode, Category, DisplayOrder, CashModeCode
ORDER BY DisplayOrder, Category
GO
CREATE VIEW [dbo].[vwCashCategoriesTax]
   AS
SELECT     TOP 100 PERCENT CategoryCode, Category, CashModeCode
FROM         dbo.tbCashCategory
WHERE     (CashTypeCode = 2) AND (CategoryTypeCode = 1)
GROUP BY CategoryCode, Category, DisplayOrder, CashModeCode
ORDER BY DisplayOrder, Category
GO
CREATE VIEW [dbo].[vwCashCategoriesTotals]
   AS
SELECT     TOP 100 PERCENT CategoryCode, CashModeCode, CashTypeCode, DisplayOrder, Category
FROM         dbo.tbCashCategory
WHERE     (CategoryTypeCode = 2)
ORDER BY CashTypeCode, CategoryCode
GO
CREATE VIEW [dbo].[vwCashCategoriesTrade]
   AS
SELECT     TOP 100 PERCENT CategoryCode, Category, CashModeCode
FROM         dbo.tbCashCategory
WHERE     (CashTypeCode = 1) AND (CategoryTypeCode = 1)
GROUP BY CategoryCode, Category, DisplayOrder, CashModeCode
ORDER BY DisplayOrder, Category
GO
CREATE VIEW [dbo].[vwStatementTasksFull]
 AS
SELECT     TOP (100) PERCENT dbo.tbTask.TaskCode AS ReferenceCode, dbo.tbTask.AccountCode, dbo.tbTask.ActionOn, dbo.tbTask.PaymentOn, 
                      CASE WHEN tbTask.TaskStatusCode = 1 THEN 4 ELSE 3 END AS CashEntryTypeCode, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.vwSystemTaxRates.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayOut, 
                      CASE WHEN tbCashCategory.CashModeCode = 2 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.vwSystemTaxRates.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayIn, dbo.tbCashCode.CashCode
FROM         dbo.vwSystemTaxRates INNER JOIN
                      dbo.tbTask ON dbo.vwSystemTaxRates.TaxCode = dbo.tbTask.TaxCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.tbTask.TaskStatusCode < 4) AND (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0) > 0)
GO
CREATE VIEW [dbo].[vwStatementTasksConfirmed]
 AS
SELECT     TOP (100) PERCENT dbo.tbTask.TaskCode AS ReferenceCode, dbo.tbTask.AccountCode, dbo.tbTask.ActionOn, dbo.tbTask.PaymentOn, 
                      3 AS CashEntryTypeCode, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.vwSystemTaxRates.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayOut, 
                      CASE WHEN tbCashCategory.CashModeCode = 2 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.vwSystemTaxRates.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayIn, dbo.tbCashCode.CashCode
FROM         dbo.vwSystemTaxRates INNER JOIN
                      dbo.tbTask ON dbo.vwSystemTaxRates.TaxCode = dbo.tbTask.TaxCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.tbTask.TaskStatusCode > 1) AND (dbo.tbTask.TaskStatusCode < 4) AND 
                      (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0) > 0)
GO
CREATE VIEW [dbo].[vwTaskVatFull]
  AS
SELECT     dbo.fnAccountPeriod(dbo.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * vwSystemTaxRates.TaxRate ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) 
                      * vwSystemTaxRates.TaxRate * - 1 END AS VatValue
FROM         dbo.tbTask INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode INNER JOIN
                      dbo.vwSystemTaxRates ON dbo.tbTask.TaxCode = dbo.vwSystemTaxRates.TaxCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.vwSystemTaxRates.TaxTypeCode = 2) AND (dbo.tbTask.TaskStatusCode < 4) AND 
                      (CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * vwSystemTaxRates.TaxRate ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) 
                      * vwSystemTaxRates.TaxRate * - 1 END <> 0)
GO
CREATE VIEW [dbo].[vwCashFlowForecastData]
    AS
SELECT     dbo.vwCashPolarData.CashCode, dbo.vwCashPolarData.CashTypeCode, dbo.vwCashPolarData.StartOn, dbo.vwCashPolarData.ForecastValue, 
                      dbo.vwCashPolarData.ForecastTax
FROM         dbo.vwCashPolarData INNER JOIN
                      dbo.fnSystemActivePeriod() fnSystemActivePeriod ON dbo.vwCashPolarData.StartOn >= fnSystemActivePeriod.StartOn
GO
CREATE VIEW [dbo].[vwCashFlowActualData]
   AS
SELECT     dbo.vwCashPolarData.CashCode, dbo.vwCashPolarData.CashTypeCode, dbo.vwCashPolarData.StartOn, dbo.vwCashPolarData.CashValue, 
                      dbo.vwCashPolarData.CashTax, dbo.vwCashPolarData.InvoiceValue, dbo.vwCashPolarData.InvoiceTax, dbo.vwCashPolarData.ForecastValue, 
                      dbo.vwCashPolarData.ForecastTax
FROM         dbo.vwCashPolarData INNER JOIN
                      dbo.fnSystemActivePeriod() fnSystemActivePeriod ON dbo.vwCashPolarData.StartOn < fnSystemActivePeriod.StartOn
GO
CREATE VIEW [dbo].[vwInvoiceRegister]
  AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoice.InvoiceNumber, dbo.tbInvoice.AccountCode, dbo.tbInvoice.InvoiceTypeCode, 
                      dbo.tbInvoice.InvoiceStatusCode, dbo.tbInvoice.InvoicedOn, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoice.InvoiceValue * - 1 ELSE dbo.tbInvoice.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoice.TaxValue * - 1 ELSE dbo.tbInvoice.TaxValue END AS TaxValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoice.PaidValue * - 1 ELSE dbo.tbInvoice.PaidValue END AS PaidValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoice.PaidTaxValue * - 1 ELSE dbo.tbInvoice.PaidTaxValue END AS PaidTaxValue, 
                      dbo.tbInvoice.PaymentTerms, dbo.tbInvoice.Notes, dbo.tbInvoice.Printed, dbo.tbOrg.AccountName, dbo.tbUser.UserName, 
                      dbo.tbInvoiceStatus.InvoiceStatus, dbo.tbInvoiceType.CashModeCode, dbo.tbInvoiceType.InvoiceType
FROM         dbo.tbInvoice INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode INNER JOIN
                      dbo.tbInvoiceStatus ON dbo.tbInvoice.InvoiceStatusCode = dbo.tbInvoiceStatus.InvoiceStatusCode INNER JOIN
                      dbo.tbUser ON dbo.tbInvoice.UserId = dbo.tbUser.UserId
GO
CREATE VIEW [dbo].[vwCashFlowVatTotals]
  AS
SELECT     StartOn, SUM(ForecastVat) AS ForecastVat, SUM(CashVat) AS CashVat, SUM(InvoiceVat) AS InvoiceVat
FROM         dbo.vwCashFlowVatTotalsBase
GROUP BY StartOn
GO
CREATE VIEW [dbo].[vwDocTaskCode]
 AS
SELECT     dbo.fnTaskEmailAddress(dbo.tbTask.TaskCode) AS EmailAddress, dbo.tbTask.TaskCode, dbo.tbTask.TaskStatusCode, dbo.tbTaskStatus.TaskStatus, 
                      dbo.tbTask.ContactName, dbo.tbOrgContact.NickName, dbo.tbUser.UserName, dbo.tbOrg.AccountName, dbo.tbOrgAddress.Address AS InvoiceAddress, 
                      tbOrg_1.AccountName AS DeliveryAccountName, tbOrgAddress_1.Address AS DeliveryAddress, tbOrg_2.AccountName AS CollectionAccountName, 
                      tbOrgAddress_2.Address AS CollectionAddress, dbo.tbTask.AccountCode, dbo.tbTask.TaskNotes, dbo.tbTask.ActivityCode, dbo.tbTask.ActionOn, 
                      dbo.tbActivity.UnitOfMeasure, dbo.tbTask.Quantity, dbo.tbSystemTaxCode.TaxCode, dbo.tbSystemTaxCode.TaxRate, dbo.tbTask.UnitCharge, 
                      dbo.tbTask.TotalCharge, dbo.tbUser.MobileNumber, dbo.tbUser.Signature, dbo.tbTask.TaskTitle, dbo.tbTask.PaymentOn, 
                      dbo.tbTask.SecondReference
FROM         dbo.tbOrg AS tbOrg_2 RIGHT OUTER JOIN
                      dbo.tbOrgAddress AS tbOrgAddress_2 ON tbOrg_2.AccountCode = tbOrgAddress_2.AccountCode RIGHT OUTER JOIN
                      dbo.tbTaskStatus INNER JOIN
                      dbo.tbUser INNER JOIN
                      dbo.tbActivity INNER JOIN
                      dbo.tbTask ON dbo.tbActivity.ActivityCode = dbo.tbTask.ActivityCode INNER JOIN
                      dbo.tbOrg ON dbo.tbTask.AccountCode = dbo.tbOrg.AccountCode LEFT OUTER JOIN
                      dbo.tbOrgAddress ON dbo.tbOrg.AddressCode = dbo.tbOrgAddress.AddressCode ON dbo.tbUser.UserId = dbo.tbTask.ActionById ON 
                      dbo.tbTaskStatus.TaskStatusCode = dbo.tbTask.TaskStatusCode LEFT OUTER JOIN
                      dbo.tbOrgAddress AS tbOrgAddress_1 LEFT OUTER JOIN
                      dbo.tbOrg AS tbOrg_1 ON tbOrgAddress_1.AccountCode = tbOrg_1.AccountCode ON dbo.tbTask.AddressCodeTo = tbOrgAddress_1.AddressCode ON 
                      tbOrgAddress_2.AddressCode = dbo.tbTask.AddressCodeFrom LEFT OUTER JOIN
                      dbo.tbOrgContact ON dbo.tbTask.ContactName = dbo.tbOrgContact.ContactName AND 
                      dbo.tbTask.AccountCode = dbo.tbOrgContact.AccountCode LEFT OUTER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbTask.TaxCode = dbo.tbSystemTaxCode.TaxCode
GO
CREATE VIEW [dbo].[vwOrgAddresses]
  AS
SELECT     TOP 100 PERCENT dbo.tbOrg.AccountName, dbo.tbOrgAddress.Address, dbo.tbOrg.OrganisationTypeCode, dbo.tbOrg.OrganisationStatusCode, 
                      dbo.tbOrgType.OrganisationType, dbo.tbOrgStatus.OrganisationStatus, dbo.vwOrgMailContacts.ContactName, dbo.vwOrgMailContacts.NickName, 
                      dbo.vwOrgMailContacts.FormalName, dbo.vwOrgMailContacts.JobTitle, dbo.vwOrgMailContacts.Department
FROM         dbo.tbOrg INNER JOIN
                      dbo.tbOrgAddress ON dbo.tbOrg.AddressCode = dbo.tbOrgAddress.AddressCode INNER JOIN
                      dbo.tbOrgType ON dbo.tbOrg.OrganisationTypeCode = dbo.tbOrgType.OrganisationTypeCode INNER JOIN
                      dbo.tbOrgStatus ON dbo.tbOrg.OrganisationStatusCode = dbo.tbOrgStatus.OrganisationStatusCode LEFT OUTER JOIN
                      dbo.vwOrgMailContacts ON dbo.tbOrg.AccountCode = dbo.vwOrgMailContacts.AccountCode
ORDER BY dbo.tbOrg.AccountName
GO
CREATE VIEW [dbo].[vwOrgDatasheet]
AS
SELECT     dbo.tbOrg.AccountCode, dbo.tbOrg.AccountName, ISNULL(dbo.vwOrgTaskCount.TaskCount, 0) AS Tasks, dbo.tbOrg.OrganisationTypeCode, 
                      dbo.tbOrgType.OrganisationType, dbo.tbOrgType.CashModeCode, dbo.tbOrg.OrganisationStatusCode, dbo.tbOrgStatus.OrganisationStatus, 
                      dbo.tbOrgAddress.Address, dbo.tbSystemTaxCode.TaxDescription, dbo.tbOrg.TaxCode, dbo.tbOrg.AddressCode, dbo.tbOrg.AreaCode, 
                      dbo.tbOrg.PhoneNumber, dbo.tbOrg.FaxNumber, dbo.tbOrg.EmailAddress, dbo.tbOrg.WebSite, dbo.fnOrgIndustrySectors(dbo.tbOrg.AccountCode) 
                      AS IndustrySector, dbo.tbOrg.AccountSource, dbo.tbOrg.PaymentTerms, dbo.tbOrg.PaymentDays, dbo.tbOrg.NumberOfEmployees, 
                      dbo.tbOrg.CompanyNumber, dbo.tbOrg.VatNumber, dbo.tbOrg.Turnover, dbo.tbOrg.StatementDays, dbo.tbOrg.OpeningBalance, 
                      dbo.tbOrg.CurrentBalance, dbo.tbOrg.ForeignJurisdiction, dbo.tbOrg.BusinessDescription, dbo.tbOrg.InsertedBy, dbo.tbOrg.InsertedOn, 
                      dbo.tbOrg.UpdatedBy, dbo.tbOrg.UpdatedOn, dbo.tbOrg.PayDaysFromMonthEnd
FROM         dbo.tbOrg INNER JOIN
                      dbo.tbOrgStatus ON dbo.tbOrg.OrganisationStatusCode = dbo.tbOrgStatus.OrganisationStatusCode INNER JOIN
                      dbo.tbOrgType ON dbo.tbOrg.OrganisationTypeCode = dbo.tbOrgType.OrganisationTypeCode LEFT OUTER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbOrg.TaxCode = dbo.tbSystemTaxCode.TaxCode LEFT OUTER JOIN
                      dbo.tbOrgAddress ON dbo.tbOrg.AddressCode = dbo.tbOrgAddress.AddressCode LEFT OUTER JOIN
                      dbo.vwOrgTaskCount ON dbo.tbOrg.AccountCode = dbo.vwOrgTaskCount.AccountCode
GO
CREATE VIEW [dbo].[vwCashCodePaymentSummary]
  AS
SELECT     CashCode, dbo.fnAccountPeriod(PaidOn) AS StartOn, SUM(PaidInValue + PaidOutValue) AS CashValue, SUM(TaxInValue + TaxOutValue) 
                      AS CashTax
FROM         dbo.tbOrgPayment
GROUP BY CashCode, dbo.fnAccountPeriod(PaidOn)
GO
CREATE VIEW [dbo].[vwInvoiceOutstandingBase]
  AS
SELECT     InvoiceNumber AS InvoiceNumber, TaskCode AS TaskCode, 
                      CashCode AS CashCode, TaxCode AS TaxCode, OutstandingValue, TaxRate
FROM         dbo.vwInvoiceOutstandingItems
UNION
SELECT     InvoiceNumber AS InvoiceNumber, TaskCode AS TaskCode, 
                      CashCode AS CashCode, TaxCode AS TaxCode, OutstandingValue, TaxRate
FROM         dbo.vwInvoiceOutstandingTasks
GO
CREATE VIEW [dbo].[vwInvoiceSummaryMargin]
  AS
SELECT     StartOn, 5 AS InvoiceTypeCode, dbo.fnSystemProfileText(3004) AS InvoiceType, SUM(TotalInvoiceValue) AS TotalInvoiceValue, SUM(TotalTaxValue) 
                      AS TotalTaxValue
FROM         dbo.vwInvoiceSummaryTotals
GROUP BY StartOn
GO
CREATE VIEW [dbo].[vwInvoiceTaxSummary]
  AS
SELECT     InvoiceNumber, TaxCode, SUM(InvoiceValueTotal) AS InvoiceValueTotal, SUM(TaxValueTotal) AS TaxValueTotal, SUM(TaxValueTotal) 
                      / SUM(InvoiceValueTotal) AS TaxRate
FROM         dbo.vwInvoiceTaxBase
GROUP BY InvoiceNumber, TaxCode
GO
CREATE VIEW [dbo].[vwCashMonthList]
  AS
SELECT DISTINCT 
                      TOP 100 PERCENT CAST(dbo.tbSystemYearPeriod.StartOn AS float) AS StartOn, dbo.tbSystemMonth.MonthName, 
                      dbo.tbSystemYearPeriod.MonthNumber
FROM         dbo.tbSystemYearPeriod INNER JOIN
                      dbo.fnSystemActivePeriod() AS fnSystemActivePeriod ON dbo.tbSystemYearPeriod.YearNumber = fnSystemActivePeriod.YearNumber INNER JOIN
                      dbo.tbSystemMonth ON dbo.tbSystemYearPeriod.MonthNumber = dbo.tbSystemMonth.MonthNumber
ORDER BY StartOn
GO
CREATE VIEW [dbo].[vwTaxVatStatement]
AS
SELECT     TOP (100) PERCENT StartOn, VatDue, VatPaid, Balance
FROM         dbo.fnTaxVatStatement() AS fnTaxVatStatement
ORDER BY StartOn, VatDue
GO
CREATE VIEW [dbo].[vwStatementCorpTaxDueDate]
AS
SELECT     TOP (1) PayOn
FROM         dbo.fnTaxTypeDueDates(1) AS fnTaxTypeDueDates
WHERE     (PayOn > GETDATE())
GO
CREATE VIEW [dbo].[vwAccountStatementPaymentBase]
  AS
SELECT     AccountCode, TransactedOn, OrderBy, Reference, StatementType, SUM(Charge) AS Charge
FROM         dbo.vwAccountStatementPayments
GROUP BY AccountCode, TransactedOn, OrderBy, Reference, StatementType
GO
CREATE VIEW [dbo].[vwCorpTaxTasksBase]
  AS
SELECT     TOP 100 PERCENT dbo.fnAccountPeriod(dbo.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * - 1 ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) END AS OrderValue
FROM         dbo.vwTaskInvoicedQuantity RIGHT OUTER JOIN
                      dbo.fnNetProfitCashCodes() fnNetProfitCashCodes INNER JOIN
                      dbo.tbCashCategory INNER JOIN
                      dbo.tbCashCode ON dbo.tbCashCategory.CategoryCode = dbo.tbCashCode.CategoryCode ON 
                      fnNetProfitCashCodes.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbTask ON fnNetProfitCashCodes.CashCode = dbo.tbTask.CashCode ON dbo.vwTaskInvoicedQuantity.TaskCode = dbo.tbTask.TaskCode
WHERE     (dbo.tbTask.TaskStatusCode < 4) AND (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0) > 0)
GO
CREATE VIEW [dbo].[vwCashCodeForecastSummary]
  AS
SELECT     dbo.tbTask.CashCode, dbo.fnAccountPeriod(dbo.tbTask.ActionOn) AS StartOn, SUM(dbo.tbTask.TotalCharge) AS ForecastValue, 
                      SUM(dbo.tbTask.TotalCharge * ISNULL(dbo.vwSystemTaxRates.TaxRate, 0)) AS ForecastTax
FROM         dbo.tbTask INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode LEFT OUTER JOIN
                      dbo.vwSystemTaxRates ON dbo.tbTask.TaxCode = dbo.vwSystemTaxRates.TaxCode
WHERE     (dbo.tbTask.ActionOn >= dbo.fnSystemActiveStartOn())
GROUP BY dbo.tbTask.CashCode, dbo.fnAccountPeriod(dbo.tbTask.ActionOn)
GO
CREATE VIEW [dbo].[vwCashFlowData]
   AS
SELECT     CashCode, CashTypeCode, StartOn, CashValue, CashTax, InvoiceValue, InvoiceTax, ForecastValue, ForecastTax
FROM         dbo.vwCashFlowActualData
UNION
SELECT     CashCode, CashTypeCode, StartOn, ForecastValue AS CashValue, ForecastTax AS CashTax, ForecastValue AS InvoiceValue, 
                      ForecastTax AS InvoiceTax, ForecastValue, ForecastTax
FROM         dbo.vwCashFlowForecastData
GO
CREATE VIEW [dbo].[vwInvoiceOutstanding]
AS
SELECT     TOP (100) PERCENT dbo.tbInvoice.AccountCode, dbo.tbInvoice.CollectOn, dbo.tbInvoice.InvoiceNumber, dbo.vwInvoiceOutstandingBase.TaskCode, 
                      dbo.tbInvoice.InvoiceStatusCode, dbo.tbInvoiceType.CashModeCode, dbo.vwInvoiceOutstandingBase.CashCode, 
                      dbo.vwInvoiceOutstandingBase.TaxCode, dbo.vwInvoiceOutstandingBase.TaxRate, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN OutstandingValue * - 1 ELSE OutstandingValue END AS ItemValue
FROM         dbo.vwInvoiceOutstandingBase INNER JOIN
                      dbo.tbInvoice ON dbo.vwInvoiceOutstandingBase.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
WHERE     (dbo.tbInvoice.InvoiceStatusCode = 2) OR
                      (dbo.tbInvoice.InvoiceStatusCode = 3)
GO
CREATE VIEW [dbo].[vwInvoiceSummary]
  AS
SELECT     DATENAME(yyyy, StartOn) + '/' + CAST(dbo.fnPad(MONTH(StartOn), 2) AS nvarchar) AS PeriodOn, StartOn, 
                      InvoiceTypeCode, InvoiceType AS InvoiceType, ABS(TotalInvoiceValue) AS TotalInvoiceValue, ABS(TotalTaxValue) AS TotalTaxValue
FROM         dbo.vwInvoiceSummaryTotals
UNION
SELECT     DATENAME(yyyy, StartOn) + '/' + CAST(dbo.fnPad(MONTH(StartOn), 2) AS nvarchar) AS PeriodOn, StartOn, 
                      InvoiceTypeCode, InvoiceType AS InvoiceType, ABS(TotalInvoiceValue) AS TotalInvoiceValue, ABS(TotalTaxValue) AS TotalTaxValue
FROM         dbo.vwInvoiceSummaryMargin
GO
CREATE VIEW [dbo].[vwTaxCorpStatement]
  AS
SELECT     TOP 100 PERCENT fnTaxCorpStatement.*
FROM         dbo.fnTaxCorpStatement() fnTaxCorpStatement
ORDER BY StartOn, TaxDue
GO
CREATE VIEW [dbo].[vwInvoiceRegisterExpenses]
AS
SELECT     StartOn, InvoiceNumber, TaskCode, TaskTitle, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, 
                      InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, 
                      CashModeCode, InvoiceType, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS UnpaidValue
FROM         dbo.vwInvoiceRegisterTasks
WHERE     (dbo.fnTaskIsExpense(TaskCode) = 1)
GO
CREATE VIEW [dbo].[vwCashAccountStatements]
  AS
SELECT     TOP 100 PERCENT fnCashAccountStatements.CashAccountCode, dbo.fnAccountPeriod(fnCashAccountStatements.PaidOn) AS StartOn, 
                      fnCashAccountStatements.EntryNumber, fnCashAccountStatements.PaymentCode, fnCashAccountStatements.PaidOn, 
                      dbo.vwCashAccountStatement.AccountName, dbo.vwCashAccountStatement.PaymentReference, dbo.vwCashAccountStatement.PaidInValue, 
                      dbo.vwCashAccountStatement.PaidOutValue, fnCashAccountStatements.PaidBalance, dbo.vwCashAccountStatement.TaxInValue, 
                      dbo.vwCashAccountStatement.TaxOutValue, fnCashAccountStatements.TaxedBalance, dbo.vwCashAccountStatement.CashCode, 
                      dbo.vwCashAccountStatement.CashDescription, dbo.vwCashAccountStatement.TaxDescription, dbo.vwCashAccountStatement.UserName, 
                      dbo.vwCashAccountStatement.AccountCode, dbo.vwCashAccountStatement.TaxCode
FROM         dbo.fnCashAccountStatements() fnCashAccountStatements LEFT OUTER JOIN
                      dbo.vwCashAccountStatement ON fnCashAccountStatements.PaymentCode = dbo.vwCashAccountStatement.PaymentCode
ORDER BY fnCashAccountStatements.CashAccountCode, fnCashAccountStatements.EntryNumber
GO
CREATE VIEW [dbo].[vwTaskOpBucket]
AS
SELECT     TaskCode, OperationNumber, dbo.fnSystemDateBucket(GETDATE(), EndOn) AS Period
FROM         dbo.tbTaskOp
GO
CREATE VIEW [dbo].[vwTaskBucket]
  AS
SELECT     TaskCode, dbo.fnSystemDateBucket(GETDATE(), ActionOn) AS Period
FROM         dbo.tbTask
GO
CREATE VIEW [dbo].[vwAccountStatementBase]
  AS
SELECT     TOP 100 PERCENT AccountCode, TransactedOn, OrderBy, Reference, StatementType, Charge
FROM         dbo.vwAccountStatementPaymentBase
UNION
SELECT     TOP 100 PERCENT AccountCode, TransactedOn, OrderBy, Reference, StatementType, Charge
FROM         dbo.vwAccountStatementInvoices
GO
CREATE VIEW [dbo].[vwTasks]
AS
SELECT     dbo.tbTask.TaskCode, dbo.tbTask.UserId, dbo.tbTask.AccountCode, dbo.tbTask.ContactName, dbo.tbTask.ActivityCode, dbo.tbTask.TaskTitle, 
                      dbo.tbTask.TaskStatusCode, dbo.tbTask.ActionById, dbo.tbTask.ActionOn, dbo.tbTask.ActionedOn, dbo.tbTask.PaymentOn, 
                      dbo.tbTask.SecondReference, dbo.tbTask.TaskNotes, dbo.tbTask.TaxCode, dbo.tbTask.Quantity, dbo.tbTask.UnitCharge, dbo.tbTask.TotalCharge, 
                      dbo.tbTask.AddressCodeFrom, dbo.tbTask.AddressCodeTo, dbo.tbTask.Printed, dbo.tbTask.InsertedBy, dbo.tbTask.InsertedOn, dbo.tbTask.UpdatedBy, 
                      dbo.tbTask.UpdatedOn, dbo.vwTaskBucket.Period, dbo.tbSystemBucket.BucketId, dbo.tbTaskStatus.TaskStatus, dbo.tbTask.CashCode, 
                      dbo.tbCashCode.CashDescription, tbUser_1.UserName AS OwnerName, dbo.tbUser.UserName AS ActionName, dbo.tbOrg.AccountName, 
                      dbo.tbOrgStatus.OrganisationStatus, dbo.tbOrgType.OrganisationType, CASE WHEN tbCashCategory.CategoryCode IS NULL 
                      THEN tbOrgType.CashModeCode ELSE tbCashCategory.CashModeCode END AS CashModeCode
FROM         dbo.tbUser INNER JOIN
                      dbo.tbTaskStatus INNER JOIN
                      dbo.tbOrgType INNER JOIN
                      dbo.tbOrg ON dbo.tbOrgType.OrganisationTypeCode = dbo.tbOrg.OrganisationTypeCode INNER JOIN
                      dbo.tbOrgStatus ON dbo.tbOrg.OrganisationStatusCode = dbo.tbOrgStatus.OrganisationStatusCode INNER JOIN
                      dbo.tbTask ON dbo.tbOrg.AccountCode = dbo.tbTask.AccountCode ON dbo.tbTaskStatus.TaskStatusCode = dbo.tbTask.TaskStatusCode ON 
                      dbo.tbUser.UserId = dbo.tbTask.ActionById INNER JOIN
                      dbo.tbUser AS tbUser_1 ON dbo.tbTask.UserId = tbUser_1.UserId INNER JOIN
                      dbo.vwTaskBucket ON dbo.tbTask.TaskCode = dbo.vwTaskBucket.TaskCode INNER JOIN
                      dbo.tbSystemBucket ON dbo.vwTaskBucket.Period = dbo.tbSystemBucket.Period LEFT OUTER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode LEFT OUTER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode
GO
CREATE VIEW [dbo].[vwTaskOps]
AS
SELECT     dbo.tbTaskOp.TaskCode, dbo.tbTaskOp.OperationNumber, dbo.vwTaskOpBucket.Period, dbo.tbSystemBucket.BucketId, dbo.tbTaskOp.UserId, 
                      dbo.tbTaskOp.OpTypeCode, dbo.tbTaskOp.OpStatusCode, dbo.tbTaskOp.Operation, dbo.tbTaskOp.Note, dbo.tbTaskOp.StartOn, dbo.tbTaskOp.EndOn, 
                      dbo.tbTaskOp.Duration, dbo.tbTaskOp.OffsetDays, dbo.tbTaskOp.InsertedBy, dbo.tbTaskOp.InsertedOn, dbo.tbTaskOp.UpdatedBy, 
                      dbo.tbTaskOp.UpdatedOn, dbo.tbTask.TaskTitle, dbo.tbTaskStatus.TaskStatus, dbo.tbTask.ActionOn, dbo.tbTask.Quantity, 
                      dbo.tbCashCode.CashDescription, dbo.tbTask.TotalCharge, dbo.tbTask.AccountCode, dbo.tbOrg.AccountName
FROM         dbo.tbTaskOp INNER JOIN
                      dbo.tbTask ON dbo.tbTaskOp.TaskCode = dbo.tbTask.TaskCode INNER JOIN
                      dbo.tbOrg ON dbo.tbTask.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbTaskStatus ON dbo.tbTask.TaskStatusCode = dbo.tbTaskStatus.TaskStatusCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.vwTaskOpBucket ON dbo.tbTaskOp.TaskCode = dbo.vwTaskOpBucket.TaskCode AND 
                      dbo.tbTaskOp.OperationNumber = dbo.vwTaskOpBucket.OperationNumber INNER JOIN
                      dbo.tbSystemBucket ON dbo.vwTaskOpBucket.Period = dbo.tbSystemBucket.Period
GO
CREATE VIEW [dbo].[vwCashEmployerNITotals]
  AS
SELECT     dbo.vwCashFlowData.StartOn, SUM(dbo.vwCashFlowData.CashTax) AS CashTaxNI, SUM(dbo.vwCashFlowData.InvoiceTax) AS InvoiceTaxNI
FROM         dbo.vwCashFlowData INNER JOIN
                      dbo.tbCashCode ON dbo.vwCashFlowData.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbCashCode.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 3)
GROUP BY dbo.vwCashFlowData.StartOn
GO
CREATE VIEW [dbo].[vwCorpTaxTasks]
  AS
SELECT     dbo.vwCorpTaxTasksBase.StartOn, SUM(dbo.vwCorpTaxTasksBase.OrderValue) AS NetProfit, 
                      dbo.vwCorpTaxTasksBase.OrderValue * dbo.tbSystemYearPeriod.CorporationTaxRate AS CorporationTax
FROM         dbo.vwCorpTaxTasksBase INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.vwCorpTaxTasksBase.StartOn = dbo.tbSystemYearPeriod.StartOn
GROUP BY dbo.vwCorpTaxTasksBase.StartOn, dbo.vwCorpTaxTasksBase.OrderValue * dbo.tbSystemYearPeriod.CorporationTaxRate
GO
CREATE VIEW [dbo].[vwCashAccountLastPeriodEntry]
  AS
SELECT     CashAccountCode, StartOn, MAX(EntryNumber) AS LastEntry
FROM         dbo.vwCashAccountStatements
GROUP BY CashAccountCode, StartOn
HAVING      (NOT (StartOn IS NULL))
GO
CREATE VIEW [dbo].[vwCashAccountPeriodClosingBalance]
  AS
SELECT     dbo.tbOrgAccount.CashCode, dbo.vwCashAccountLastPeriodEntry.StartOn, SUM(dbo.vwCashAccountStatements.PaidBalance) 
                      + SUM(dbo.vwCashAccountStatements.TaxedBalance) AS ClosingBalance
FROM         dbo.vwCashAccountLastPeriodEntry INNER JOIN
                      dbo.vwCashAccountStatements ON dbo.vwCashAccountLastPeriodEntry.CashAccountCode = dbo.vwCashAccountStatements.CashAccountCode AND 
                      dbo.vwCashAccountLastPeriodEntry.StartOn = dbo.vwCashAccountStatements.StartOn AND 
                      dbo.vwCashAccountLastPeriodEntry.LastEntry = dbo.vwCashAccountStatements.EntryNumber INNER JOIN
                      dbo.tbOrgAccount ON dbo.vwCashAccountLastPeriodEntry.CashAccountCode = dbo.tbOrgAccount.CashAccountCode 
GROUP BY dbo.tbOrgAccount.CashCode, dbo.vwCashAccountLastPeriodEntry.StartOn
GO
CREATE  VIEW [dbo].[vwCashSummaryBase]
  AS
SELECT     ISNULL(SUM(ToCollect), 0) AS Collect, ISNULL(SUM(ToPay), 0) AS Pay, ISNULL(SUM(TaxValue), 0) + dbo.fnSystemVatBalance() 
                      + dbo.fnSystemCorpTaxBalance() AS Tax, dbo.fnCashCompanyBalance() AS CompanyBalance
FROM         dbo.vwCashSummaryInvoices
GO
CREATE VIEW [dbo].[vwStatementReserves]
AS
SELECT     TOP 100 PERCENT fnStatementReserves.TransactOn, fnStatementReserves.CashEntryTypeCode, fnStatementReserves.ReferenceCode, 
                      fnStatementReserves.AccountCode, dbo.tbOrg.AccountName, dbo.tbCashEntryType.CashEntryType, fnStatementReserves.PayOut, 
                      fnStatementReserves.PayIn, fnStatementReserves.Balance, dbo.tbCashCode.CashCode, dbo.tbCashCode.CashDescription
FROM         dbo.fnStatementReserves() AS fnStatementReserves INNER JOIN
                      dbo.tbCashEntryType ON fnStatementReserves.CashEntryTypeCode = dbo.tbCashEntryType.CashEntryTypeCode INNER JOIN
                      dbo.tbOrg ON fnStatementReserves.AccountCode = dbo.tbOrg.AccountCode LEFT OUTER JOIN
                      dbo.tbCashCode ON fnStatementReserves.CashCode = dbo.tbCashCode.CashCode
ORDER BY fnStatementReserves.TransactOn, fnStatementReserves.CashEntryTypeCode, fnStatementReserves.ReferenceCode, fnStatementReserves.CashCode
GO
CREATE VIEW [dbo].[vwCashSummary]
  AS
SELECT     GETDATE() AS Timstamp, Collect, Pay, Tax, CompanyBalance AS Cash, CompanyBalance + Collect - Pay - Tax AS Balance
FROM         dbo.vwCashSummaryBase
GO
