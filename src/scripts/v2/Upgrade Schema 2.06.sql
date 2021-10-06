CREATE FUNCTION dbo.fnSystemCompanyAccount()
RETURNS NVARCHAR(10)
AS
	BEGIN
	DECLARE @AccountCode NVARCHAR(10)
	SELECT @AccountCode = AccountCode FROM tbSystemOptions
	RETURN @AccountCode
	END
GO
ALTER VIEW dbo.vwInvoiceRegister
AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoice.InvoiceNumber, dbo.tbInvoice.AccountCode, dbo.tbInvoice.InvoiceTypeCode, 
                      dbo.tbInvoice.InvoiceStatusCode, dbo.tbInvoice.InvoicedOn, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoice.InvoiceValue * - 1 ELSE dbo.tbInvoice.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoice.TaxValue * - 1 ELSE dbo.tbInvoice.TaxValue END AS TaxValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoice.PaidValue * - 1 ELSE dbo.tbInvoice.PaidValue END AS PaidValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoice.PaidTaxValue * - 1 ELSE dbo.tbInvoice.PaidTaxValue END AS PaidTaxValue, 
                      dbo.tbInvoice.PaymentTerms, dbo.tbInvoice.Notes, dbo.tbInvoice.Printed, dbo.tbOrg.AccountName, dbo.tbUser.UserName, dbo.tbInvoiceStatus.InvoiceStatus, 
                      dbo.tbInvoiceType.CashModeCode, dbo.tbInvoiceType.InvoiceType
FROM         dbo.tbInvoice INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode INNER JOIN
                      dbo.tbInvoiceStatus ON dbo.tbInvoice.InvoiceStatusCode = dbo.tbInvoiceStatus.InvoiceStatusCode INNER JOIN
                      dbo.tbUser ON dbo.tbInvoice.UserId = dbo.tbUser.UserId
WHERE     (dbo.tbInvoice.AccountCode <> dbo.fnSystemCompanyAccount())
GO
ALTER PROCEDURE [dbo].[spPaymentPostMisc]
	(
	@PaymentCode nvarchar(20) 
	)
AS
declare @InvoiceNumber nvarchar(20)
declare @UserId nvarchar(10)
declare @NextNumber int
declare @InvoiceSuffix nvarchar(4)
declare @InvoiceTypeCode smallint

	SELECT @InvoiceTypeCode = CASE WHEN PaidInValue != 0 THEN 1 ELSE 3 END 
	FROM         tbOrgPayment
	WHERE     (PaymentCode = @PaymentCode)

	select @UserId = UserId from vwUserCredentials

	set @InvoiceSuffix = '.' + @UserId
	
	select @NextNumber = NextNumber
	from tbInvoiceType
	where InvoiceTypeCode = @InvoiceTypeCode
	
	select @InvoiceNumber = dbo.fnPad(@NextNumber, 6) + @InvoiceSuffix
	
	while exists (SELECT     InvoiceNumber
	              FROM         tbInvoice
	              WHERE     (InvoiceNumber = @InvoiceNumber))
		begin
		set @NextNumber = @NextNumber + 1
		set @InvoiceNumber = dbo.fnPad(@NextNumber, 6) + @InvoiceSuffix
		end
		
	
	UPDATE    tbInvoiceType
	SET              NextNumber = @NextNumber + 1
	WHERE     (InvoiceTypeCode = @InvoiceTypeCode)

	INSERT INTO tbInvoice
							 (InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, CollectOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, Printed)
	SELECT        @InvoiceNumber AS InvoiceNumber, tbOrgPayment.UserId, tbOrgPayment.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, 4 AS InvoiceStatusCode, 
							 tbOrgPayment.PaidOn, tbOrgPayment.PaidOn AS CollectOn, CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate) 
							 WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate) END AS InvoiceValue, 
							 CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - ROUND((tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate)), 2) 
							 WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - ROUND((tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate)), 2) 
							 END AS TaxValue, CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate) 
							 WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate) END AS PaidValue, 
							 CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - ROUND((tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate)), 2) 
							 WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - ROUND((tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate)), 2) 
							 END AS PaidTaxValue, 1 AS Printed
	FROM            tbOrgPayment INNER JOIN
							 vwSystemTaxRates ON tbOrgPayment.TaxCode = vwSystemTaxRates.TaxCode
	WHERE        (tbOrgPayment.PaymentCode = @PaymentCode)

	INSERT INTO tbInvoiceItem
						(InvoiceNumber, CashCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, TaxCode)
	SELECT     @InvoiceNumber AS InvoiceNumber, tbOrgPayment.CashCode, 
	                      CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate) 
	                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate) END AS InvoiceValue, 
	                      CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - ROUND((tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate)), 
	                      2) WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - ROUND((tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate)), 
	                      2) END AS TaxValue, CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate) 
	                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate) END AS PaidValue, 
	                      CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - ROUND((tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate)), 
	                      2) WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - ROUND((tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate)), 
	                      2) END AS PaidTaxValue, tbOrgPayment.TaxCode
	FROM         tbOrgPayment INNER JOIN
	                      vwSystemTaxRates ON tbOrgPayment.TaxCode = vwSystemTaxRates.TaxCode
	WHERE     (tbOrgPayment.PaymentCode = @PaymentCode)

	UPDATE  tbOrgAccount
	SET CurrentBalance = CASE WHEN PaidInValue > 0 THEN tbOrgAccount.CurrentBalance + PaidInValue ELSE tbOrgAccount.CurrentBalance - PaidOutValue END
	FROM         tbOrgAccount INNER JOIN
						  tbOrgPayment ON tbOrgAccount.CashAccountCode = tbOrgPayment.CashAccountCode
	WHERE tbOrgPayment.PaymentCode = @PaymentCode

	UPDATE    tbOrgPayment
	SET		PaymentStatusCode = 2,
		TaxInValue = PaidInValue - ROUND((PaidInValue / (1 + TaxRate)), 2), 
		TaxOutValue = PaidOutValue - ROUND((PaidOutValue / (1 + TaxRate)), 2)
	FROM         tbOrgPayment INNER JOIN
	                      vwSystemTaxRates ON tbOrgPayment.TaxCode = vwSystemTaxRates.TaxCode
	WHERE     (PaymentCode = @PaymentCode)
	
	RETURN
GO
ALTER  PROCEDURE [dbo].[spCashFlowInitialise]
AS
declare @CashCode nvarchar(25)
		
	exec dbo.spCashGeneratePeriods
	
	UPDATE       tbCashPeriod
	SET                ForecastValue = 0, ForecastTax = 0, InvoiceValue = 0, InvoiceTax = 0
	FROM            tbCashPeriod INNER JOIN
	                         tbCashCode ON tbCashPeriod.CashCode = tbCashCode.CashCode INNER JOIN
	                         tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE  (tbCashCategory.CashTypeCode <> 3)
	
	UPDATE tbCashPeriod
	SET InvoiceValue = vwCashCodeInvoiceSummary.InvoiceValue, 
		InvoiceTax = vwCashCodeInvoiceSummary.TaxValue
	FROM         tbCashPeriod INNER JOIN
	                      vwCashCodeInvoiceSummary ON tbCashPeriod.CashCode = vwCashCodeInvoiceSummary.CashCode AND tbCashPeriod.StartOn = vwCashCodeInvoiceSummary.StartOn	

	UPDATE tbCashPeriod
	SET 
		InvoiceValue = vwCashAccountPeriodClosingBalance.ClosingBalance
	FROM         vwCashAccountPeriodClosingBalance INNER JOIN
	                      tbCashPeriod ON vwCashAccountPeriodClosingBalance.CashCode = tbCashPeriod.CashCode AND 
	                      vwCashAccountPeriodClosingBalance.StartOn = tbCashPeriod.StartOn
	                      	
	UPDATE       tbCashPeriod
	SET                ForecastValue = vwCashCodeForecastSummary.ForecastValue, ForecastTax = vwCashCodeForecastSummary.ForecastTax
	FROM            tbCashPeriod INNER JOIN
	                         vwCashCodeForecastSummary ON tbCashPeriod.CashCode = vwCashCodeForecastSummary.CashCode AND 
	                         tbCashPeriod.StartOn = vwCashCodeForecastSummary.StartOn

	UPDATE tbCashPeriod
	SET
		InvoiceValue = tbCashPeriod.InvoiceValue + vwCashCodeOrderSummary.InvoiceValue,
		InvoiceTax = tbCashPeriod.InvoiceTax + vwCashCodeOrderSummary.InvoiceTax
	FROM tbCashPeriod INNER JOIN
		vwCashCodeOrderSummary ON tbCashPeriod.CashCode = vwCashCodeOrderSummary.CashCode
			AND tbCashPeriod.StartOn = vwCashCodeOrderSummary.StartOn	
	
	--Corporation Tax
	SELECT   @CashCode = CashCode
	FROM            tbCashTaxType
	WHERE        (TaxTypeCode = 1)
	
	UPDATE       tbCashPeriod
	SET                ForecastValue = 0, ForecastTax = 0, InvoiceValue = 0, InvoiceTax = 0
	FROM            tbCashPeriod
	WHERE CashCode = @CashCode	
	
	UPDATE       tbCashPeriod
	SET                InvoiceValue = vwTaxCorpStatement.TaxDue
	FROM            vwTaxCorpStatement INNER JOIN
	                         tbCashPeriod ON vwTaxCorpStatement.StartOn = tbCashPeriod.StartOn
	WHERE        (vwTaxCorpStatement.TaxDue <> 0) AND (tbCashPeriod.CashCode = @CashCode)
	
	--VAT vwTaxVatStatement		
	SELECT   @CashCode = CashCode
	FROM            tbCashTaxType
	WHERE        (TaxTypeCode = 2)

	UPDATE       tbCashPeriod
	SET                InvoiceValue = vwTaxVatStatement.VatDue
	FROM            vwTaxVatStatement INNER JOIN
	                         tbCashPeriod ON vwTaxVatStatement.StartOn = tbCashPeriod.StartOn
	WHERE        (tbCashPeriod.CashCode = @CashCode) AND (vwTaxVatStatement.VatDue <> 0)

	--**********************************************************************************************	                  	

	UPDATE tbCashPeriod
	SET
		ForecastValue = vwCashFlowNITotals.ForecastNI, 
		InvoiceValue = vwCashFlowNITotals.InvoiceNI
	FROM         tbCashPeriod INNER JOIN
	                      vwCashFlowNITotals ON tbCashPeriod.StartOn = vwCashFlowNITotals.StartOn
	WHERE     (tbCashPeriod.CashCode = dbo.fnSystemCashCode(3))
	                      
	
	RETURN 
GO
