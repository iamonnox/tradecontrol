ALTER TABLE Org.tbPayment DROP CONSTRAINT [DF_Org_tbPayment_PaidOn];
ALTER TABLE [Org].[tbPayment] ADD  CONSTRAINT [DF_Org_tbPayment_PaidOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [PaidOn]
go
CREATE NONCLUSTERED INDEX IX_Org_tbPayment_Status
ON [Org].[tbPayment] ([PaymentStatusCode])
INCLUDE ([CashAccountCode],[CashCode],[PaidOn],[PaidInValue],[PaidOutValue])
go
ALTER VIEW [Cash].[vwAccountStatement]
  AS
	WITH entries AS
	(
		SELECT  payment.CashAccountCode, payment.CashCode, ROW_NUMBER() OVER (PARTITION BY payment.CashAccountCode ORDER BY PaidOn, PaymentCode) AS EntryNumber, PaymentCode, PaidOn, 
			CASE WHEN PaidInValue > 0 THEN PaidInValue ELSE PaidOutValue * - 1 END AS Paid
		FROM         Org.tbPayment payment INNER JOIN Org.tbAccount ON payment.CashAccountCode = Org.tbAccount.CashAccountCode
		WHERE     (PaymentStatusCode = 1) AND (AccountClosed = 0)		

		UNION

		SELECT        
			CashAccountCode, 
			(SELECT TOP 1  Cash.tbCode.CashCode
				FROM            Cash.tbCode JOIN Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
				WHERE        (Cash.tbCategory.CashModeCode = 1) AND (Cash.tbCategory.CashTypeCode = 2)) AS CashCode, 
			0 AS EntryNumber, 
			(SELECT CAST(Message AS NVARCHAR(30)) FROM App.tbText WHERE TextId = 3005) AS PaymentCode, 
			DATEADD(HOUR, - 1, (SELECT MIN(payment.PaidOn) FROM Org.tbPayment payment WHERE payment.CashAccountCode = cash_account.CashAccountCode)) AS PaidOn, 
			OpeningBalance AS Paid
		FROM            Org.tbAccount cash_account
		WHERE        (AccountClosed = 0)
		GROUP BY CashAccountCode, OpeningBalance
	), running_balance AS
	(
		SELECT CashAccountCode, CashCode, EntryNumber, PaymentCode, PaidOn, 
			SUM(Paid) OVER (PARTITION BY CashAccountCode ORDER BY EntryNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS PaidBalance
		FROM entries
	), payments AS
	(
		SELECT     Org.tbPayment.PaymentCode, Org.tbPayment.CashAccountCode, Usr.tbUser.UserName, Org.tbPayment.AccountCode, 
							  Org.tbOrg.AccountName, Org.tbPayment.CashCode, Cash.tbCode.CashDescription, App.tbTaxCode.TaxDescription, 
							  Org.tbPayment.PaidInValue, Org.tbPayment.PaidOutValue, Org.tbPayment.TaxInValue, 
							  Org.tbPayment.TaxOutValue, Org.tbPayment.PaymentReference, Org.tbPayment.InsertedBy, Org.tbPayment.InsertedOn, 
							  Org.tbPayment.UpdatedBy, Org.tbPayment.UpdatedOn, Org.tbPayment.TaxCode
		FROM         Org.tbPayment INNER JOIN
							  Usr.tbUser ON Org.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
							  Org.tbOrg ON Org.tbPayment.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
							  App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
							  Cash.tbCode ON Org.tbPayment.CashCode = Cash.tbCode.CashCode
	)
	SELECT running_balance.CashAccountCode, (SELECT TOP 1 StartOn FROM App.tbYearPeriod	WHERE (StartOn <= running_balance.PaidOn) ORDER BY StartOn DESC) AS StartOn, 
							running_balance.EntryNumber, running_balance.PaymentCode, running_balance.PaidOn, 
							payments.AccountName, payments.PaymentReference, payments.PaidInValue, 
							payments.PaidOutValue, running_balance.PaidBalance, payments.TaxInValue, 
							payments.TaxOutValue, payments.CashCode, 
							payments.CashDescription, payments.TaxDescription, payments.UserName, 
							payments.AccountCode, payments.TaxCode
	FROM   running_balance LEFT OUTER JOIN
							payments ON running_balance.PaymentCode = payments.PaymentCode
							
	ORDER BY CashAccountCode, EntryNumber;	
go




