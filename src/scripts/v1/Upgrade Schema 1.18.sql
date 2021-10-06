/************************************************************
* Tru-Man Trade Control: Management Information and Cash System
* Copyright Tru-Man Industries Ltd 2010. All Rights Reserved.
* Author: Ian Monnox
* Description: Sql Server Upgrade Script - Encrypted Distribution Schema
* Data Version: 1.18
* Release Date: 3 August 2010
************************************************************/
GO
ALTER FUNCTION [dbo].[fnStatementVat]
	()
RETURNS @tbVat TABLE (
	ReferenceCode nvarchar(20), 
	AccountCode nvarchar(10),
	TransactOn datetime,
	CashEntryTypeCode int,
	PayOut money,
	PayIn money,
	CashCode nvarchar(50)
	)
AS
	BEGIN
	declare @LastBalanceOn datetime
	declare @VatDueOn datetime
	declare @VatDue money
	
	declare @ReferenceCode nvarchar(20)	
	declare @CashCode nvarchar(50)
	
	declare @AccountCode nvarchar(10)
	
	set @ReferenceCode = dbo.fnSystemProfileText(1214)	
	set @CashCode = dbo.fnSystemCashCode(2)
	set @AccountCode = dbo.fnStatementTaxAccount(2)
	SELECT @VatDue = dbo.fnSystemVatBalance()
	IF (@VatDue <> 0)
		BEGIN
		SELECT  TOP 1 @VatDueOn = PayOn	FROM vwStatementVatDueDate		
		SET @VatDueOn = dbo.fnTaskDefaultPaymentOn(@AccountCode, @VatDueOn)
		insert into @tbVat (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayOut, PayIn, CashCode)
		values (@ReferenceCode, @AccountCode, @VatDueOn, 6, CASE WHEN @VatDue > 0 THEN @VatDue ELSE 0 END, CASE WHEN @VatDue < 0 THEN ABS(@VatDue) ELSE 0 END, @CashCode)									
		END
		
		
	RETURN
	END
GO
CREATE VIEW [dbo].[vwStatementCorpTaxDueDate]
AS
SELECT     TOP 1 PayOn
FROM         dbo.fnTaxTypeDueDates(1) AS fnTaxTypeDueDates
WHERE     (PayOn > GETDATE())
GO
ALTER FUNCTION [dbo].[fnStatementCorpTax]
	()
RETURNS @tbCorpTax TABLE (
	ReferenceCode nvarchar(20), 
	AccountCode nvarchar(10),
	TransactOn datetime,
	CashEntryTypeCode int,
	PayOut money,
	PayIn money,
	CashCode nvarchar(50)	
	)
AS
	BEGIN
	declare @TaxDueOn datetime
	declare @Balance money
	declare @TaxDue money
	
	declare @ReferenceCode nvarchar(20)	
	declare @CashCode nvarchar(50)
	declare @AccountCode nvarchar(10)
	
	SET @ReferenceCode = dbo.fnSystemProfileText(1214)	
	SET @CashCode = dbo.fnSystemCashCode(1)
	SET @AccountCode = dbo.fnStatementTaxAccount(1)
	SET @TaxDue = dbo.fnSystemCorpTaxBalance()
	
	IF @TaxDue > 0
		BEGIN
		SELECT  TOP 1 @TaxDueOn = PayOn	FROM vwStatementCorpTaxDueDate
		--SET @TaxDueOn = dbo.fnTaskDefaultPaymentOn(@AccountCode, @TaxDueOn)
		insert into @tbCorpTax (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayOut, PayIn, CashCode)
		values (@ReferenceCode, @AccountCode, @TaxDueOn, 5, @TaxDue, 0, @CashCode)								
		END
	
	RETURN
	END
GO
ALTER VIEW [dbo].[vwTaskProfit]
AS
SELECT     TOP 100 PERCENT fnTaskProfit_1.StartOn, dbo.tbOrg.AccountCode, dbo.tbTask.TaskCode, dbo.tbTask.ActivityCode, dbo.tbCashCode.CashCode, 
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
