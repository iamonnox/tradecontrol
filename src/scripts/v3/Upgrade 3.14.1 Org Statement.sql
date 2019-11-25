UPDATE App.tbOptions
SET SQLDataVersion = 3.14;
go
DROP VIEW IF EXISTS [Org].[vwStatementPayments]

DROP FUNCTION IF EXISTS [Org].[fnStatement]
DROP VIEW IF EXISTS [Org].[vwStatementBase]
DROP VIEW IF EXISTS [Org].[vwStatementInvoices]
DROP VIEW IF EXISTS [Org].[vwStatementPaymentBase]
go
ALTER VIEW [Org].[vwDatasheet]
AS
	With task_count AS
	(
		SELECT        AccountCode, COUNT(TaskCode) AS TaskCount
		FROM            Task.tbTask
		WHERE        (TaskStatusCode = 1)
		GROUP BY AccountCode
	)
	SELECT        o.AccountCode, o.AccountName, ISNULL(task_count.TaskCount, 0) AS Tasks, o.OrganisationTypeCode, Org.tbType.OrganisationType, Org.tbType.CashModeCode, o.OrganisationStatusCode, 
							 Org.tbStatus.OrganisationStatus, Org.tbAddress.Address, App.tbTaxCode.TaxDescription, o.TaxCode, o.AddressCode, o.AreaCode, o.PhoneNumber, o.FaxNumber, o.EmailAddress, o.WebSite,
								 (SELECT        TOP (1) IndustrySector
								   FROM            Org.tbSector AS sector
								   WHERE        (AccountCode = o.AccountCode)) AS IndustrySector, o.AccountSource, o.PaymentTerms, o.PaymentDays, o.NumberOfEmployees, o.CompanyNumber, o.VatNumber, o.Turnover, 
							 o.OpeningBalance, o.ForeignJurisdiction, o.BusinessDescription, o.InsertedBy, o.InsertedOn, o.UpdatedBy, o.UpdatedOn, o.PayDaysFromMonthEnd
	FROM            Org.tbOrg AS o INNER JOIN
							 Org.tbStatus ON o.OrganisationStatusCode = Org.tbStatus.OrganisationStatusCode INNER JOIN
							 Org.tbType ON o.OrganisationTypeCode = Org.tbType.OrganisationTypeCode LEFT OUTER JOIN
							 App.tbTaxCode ON o.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
							 Org.tbAddress ON o.AddressCode = Org.tbAddress.AddressCode LEFT OUTER JOIN
							 task_count ON o.AccountCode = task_count.AccountCode
go
ALTER VIEW [Org].[vwStatusReport]
AS
SELECT        Org.vwDatasheet.AccountCode, Org.vwDatasheet.AccountName, Org.vwDatasheet.OrganisationType, Org.vwDatasheet.OrganisationStatus, Org.vwDatasheet.TaxDescription, Org.vwDatasheet.Address, 
                         Org.vwDatasheet.AreaCode, Org.vwDatasheet.PhoneNumber, Org.vwDatasheet.FaxNumber, Org.vwDatasheet.EmailAddress, Org.vwDatasheet.WebSite, Org.vwDatasheet.IndustrySector, 
                         Org.vwDatasheet.AccountSource, Org.vwDatasheet.PaymentTerms, Org.vwDatasheet.PaymentDays, Org.vwDatasheet.NumberOfEmployees, Org.vwDatasheet.CompanyNumber, Org.vwDatasheet.VatNumber, 
                         Org.vwDatasheet.Turnover, Org.vwDatasheet.OpeningBalance, Org.vwDatasheet.ForeignJurisdiction, Org.vwDatasheet.BusinessDescription, 
                         Org.tbPayment.PaymentCode, Usr.tbUser.UserName, App.tbTaxCode.TaxDescription AS PaymentTaxDescription, Org.tbAccount.CashAccountName, Cash.tbCode.CashDescription, Org.tbPayment.UserId, 
                         Org.tbPayment.CashAccountCode, Org.tbPayment.CashCode, Org.tbPayment.TaxCode, Org.tbPayment.PaidOn, Org.tbPayment.PaidInValue, Org.tbPayment.PaidOutValue, Org.tbPayment.TaxInValue, 
                         Org.tbPayment.TaxOutValue, Org.tbPayment.InsertedBy, Org.tbPayment.InsertedOn, Org.tbPayment.UpdatedBy, Org.tbPayment.UpdatedOn, Org.tbPayment.PaymentReference
FROM            Org.tbPayment INNER JOIN
                         Usr.tbUser ON Org.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
                         Org.tbAccount ON Org.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
                         Cash.tbCode ON Org.tbPayment.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
                         App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
                         Org.vwDatasheet ON Org.tbPayment.AccountCode = Org.vwDatasheet.AccountCode
WHERE        (Org.tbPayment.PaymentStatusCode = 1);
go
ALTER TABLE Org.tbOrg DROP 
	CONSTRAINT DF_Org_tb_StatementDays,
	COLUMN StatementDays;
go	
CREATE OR ALTER VIEW Org.vwStatement 
AS
	WITH payment_data AS
	(
		SELECT Org.tbPayment.AccountCode, Org.tbPayment.PaidOn AS TransactedOn, 2 AS OrderBy, 
							  Org.tbPayment.PaymentReference AS Reference, Org.tbPaymentStatus.PaymentStatus AS StatementType, 
							  CASE WHEN PaidInValue > 0 THEN PaidInValue ELSE PaidOutValue * - 1 END AS Charge
		FROM         Org.tbPayment INNER JOIN
							  Org.tbPaymentStatus ON Org.tbPayment.PaymentStatusCode = Org.tbPaymentStatus.PaymentStatusCode
	), payments AS
	(
		SELECT     AccountCode, TransactedOn, OrderBy, Reference, StatementType, SUM(Charge) AS Charge
		FROM     payment_data
		GROUP BY AccountCode, TransactedOn, OrderBy, Reference, StatementType
	), invoices AS
	(
		SELECT Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoicedOn AS TransactedOn, 1 AS OrderBy, Invoice.tbInvoice.InvoiceNumber AS Reference, 
							  Invoice.tbType.InvoiceType AS StatementType, 
							  CASE CashModeCode WHEN 0 THEN Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue WHEN 1 THEN (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue)
							   * - 1 END AS Charge
		FROM         Invoice.tbInvoice INNER JOIN
							  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	), transactions_union AS
	(
		SELECT     AccountCode, TransactedOn, OrderBy, Reference, StatementType, Charge
		FROM         payments
		UNION
		SELECT     AccountCode, TransactedOn, OrderBy, Reference, StatementType, Charge
		FROM         invoices
	), transactions AS
	(
		SELECT AccountCode, ROW_NUMBER() OVER (PARTITION BY AccountCode ORDER BY TransactedOn, OrderBy) AS RowNumber, TransactedOn, OrderBy, Reference, StatementType, Charge 
		FROM transactions_union
	), opening_balance AS
	(
		SELECT AccountCode, 0 AS RowNumber, InsertedOn AS TransactedOn, 0 AS OrderBy, NULL AS Reference, 
			(SELECT CAST([Message] AS NVARCHAR) FROM App.tbText WHERE TextId = 3005) AS StatementType, OpeningBalance AS Charge
		FROM Org.tbOrg org
	), statement_data AS
	( 
		SELECT AccountCode, RowNumber, TransactedOn, OrderBy, Reference, StatementType, Charge FROM transactions
		UNION
		SELECT AccountCode, RowNumber, TransactedOn, OrderBy, Reference, StatementType, Charge FROM opening_balance
	)
		SELECT AccountCode, CAST(RowNumber AS INT) AS RowNumber, TransactedOn, OrderBy, Reference, StatementType, Charge,
			SUM(Charge) OVER (PARTITION BY AccountCode ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
		FROM statement_data;
go

CREATE OR ALTER PROCEDURE [Org].[proc_Statement] (@AccountCode NVARCHAR(10))
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		SELECT *
		FROM Org.vwStatement
		WHERE AccountCode = @AccountCode
		ORDER BY RowNumber DESC

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog
	END CATCH
go