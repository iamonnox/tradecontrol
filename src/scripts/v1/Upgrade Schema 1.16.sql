/************************************************************
* Tru-Man Trade Control: Management Information and Cash System
* Copyright Tru-Man Industries Ltd 2010. All Rights Reserved.
* Author: Ian Monnox
* Description: Sql Server Upgrade Script - Encrypted Distribution Schema
* Data Version: 1.16
* Release Date: 1 August 2010
************************************************************/


CREATE OR ALTER FUNCTION dbo.fnSystemCorpTaxBalance
	()
RETURNS money
AS
	BEGIN
	declare @Balance money
	SELECT  @Balance = SUM(CorporationTax)
	FROM         vwCorpTaxInvoice
	
	SELECT  @Balance = @Balance + ISNULL(SUM(tbOrgPayment.PaidInValue - tbOrgPayment.PaidOutValue), 0)
	FROM         tbOrgPayment INNER JOIN
	                      vwSystemCorpTaxCashCode ON tbOrgPayment.CashCode = vwSystemCorpTaxCashCode.CashCode	                      

	IF @Balance < 0
		SET @Balance = 0
		
	RETURN isnull(@Balance, 0)
	END
GO
CREATE OR ALTER FUNCTION dbo.fnCashReserveBalance
	()
RETURNS money
AS
	BEGIN
	declare @CurrentBalance money
	
	SELECT    @CurrentBalance = SUM(tbOrgAccount.CurrentBalance)
	FROM         tbOrgAccount LEFT OUTER JOIN
	                      tbCashCode ON tbOrgAccount.CashCode = tbCashCode.CashCode
	WHERE     (tbOrgAccount.AccountClosed = 0) AND (tbCashCode.CashCode IS NULL)
	
	RETURN isnull(@CurrentBalance, 0)
	END
GO
CREATE OR ALTER FUNCTION dbo.fnCashCompanyBalance
	()
RETURNS money
  AS
	BEGIN
	declare @CurrentBalance money
	
	SELECT  @CurrentBalance = SUM(tbOrgAccount.CurrentBalance)
	FROM         tbOrgAccount INNER JOIN
	                      tbCashCode ON tbOrgAccount.CashCode = tbCashCode.CashCode
	WHERE     (tbOrgAccount.AccountClosed = 0)
	
	RETURN isnull(@CurrentBalance, 0)
	END
GO
CREATE OR ALTER VIEW dbo.vwTaskVatConfirmed
AS
SELECT     dbo.fnAccountPeriod(dbo.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * tbSystemTaxCode.TaxRate * - 1 ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) 
                      * tbSystemTaxCode.TaxRate END AS VatValue
FROM         dbo.tbTask INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbTask.TaxCode = dbo.tbSystemTaxCode.TaxCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 2) AND (dbo.tbTask.TaskStatusCode > 1) AND (dbo.tbTask.TaskStatusCode < 4) AND 
                      (CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * tbSystemTaxCode.TaxRate ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) 
                      * tbSystemTaxCode.TaxRate * - 1 END <> 0)
GO
CREATE OR ALTER FUNCTION [dbo].[fnStatementCompany]()
RETURNS @tbStatement TABLE (
	ReferenceCode nvarchar(20), 
	AccountCode nvarchar(10),
	TransactOn datetime,
	CashEntryTypeCode smallint,
	PayOut money,
	PayIn money,
	Balance money,
	CashCode nvarchar(50)
	) 
   AS
	BEGIN
	declare @ReferenceCode nvarchar(20) 
	declare @ReferenceCode2 nvarchar(20)
	declare @CashCode nvarchar(50)
	declare @AccountCode nvarchar(10)
	declare @TransactOn datetime
	declare @CashEntryTypeCode smallint
	declare @PayOut money
	declare @PayIn money
	declare @Balance money
	declare @TaxAccrual money

	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, CashCode, PayIn, PayOut)	
	SELECT     tbInvoiceItem.InvoiceNumber, tbInvoice.AccountCode, tbInvoice.CollectOn, 2 AS CashEntryTypeCode, tbInvoiceItem.CashCode, 
	                      SUM(CASE WHEN InvoiceTypeCode = 1 OR
	                      InvoiceTypeCode = 4 THEN (tbInvoiceItem.InvoiceValue + tbInvoiceItem.TaxValue) - (tbInvoiceItem.PaidValue + tbInvoiceItem.PaidTaxValue) 
	                      ELSE 0 END) AS PayIn, SUM(CASE WHEN InvoiceTypeCode = 2 OR
	                      InvoiceTypeCode = 3 THEN (tbInvoiceItem.InvoiceValue + tbInvoiceItem.TaxValue) - (tbInvoiceItem.PaidValue + tbInvoiceItem.PaidTaxValue) 
	                      ELSE 0 END) AS PayOut
	FROM         tbInvoiceItem INNER JOIN
	                      tbInvoice ON tbInvoiceItem.InvoiceNumber = tbInvoice.InvoiceNumber INNER JOIN
	                      tbCashCode ON tbInvoiceItem.CashCode = tbCashCode.CashCode INNER JOIN
	                      tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE     ((tbInvoiceItem.InvoiceValue + tbInvoiceItem.TaxValue) - (tbInvoiceItem.PaidValue + tbInvoiceItem.PaidTaxValue) > 0)
	GROUP BY tbInvoiceItem.InvoiceNumber, tbInvoice.AccountCode, tbInvoice.InvoicedOn, tbInvoice.CollectOn, tbInvoiceItem.CashCode

	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, CashCode, PayIn, PayOut)		
	SELECT     tbInvoiceTask.InvoiceNumber, tbInvoice.AccountCode, tbInvoice.CollectOn, 2 AS CashEntryTypeCode, tbInvoiceTask.CashCode, 
	                      SUM(CASE WHEN InvoiceTypeCode = 1 OR
	                      InvoiceTypeCode = 4 THEN (tbInvoiceTask.InvoiceValue + tbInvoiceTask.TaxValue) - (tbInvoiceTask.PaidValue + tbInvoiceTask.PaidTaxValue) 
	                      ELSE 0 END) AS PayIn, SUM(CASE WHEN InvoiceTypeCode = 2 OR
	                      InvoiceTypeCode = 3 THEN (tbInvoiceTask.InvoiceValue + tbInvoiceTask.TaxValue) - (tbInvoiceTask.PaidValue + tbInvoiceTask.PaidTaxValue) 
	                      ELSE 0 END) AS PayOut
	FROM         tbInvoiceTask INNER JOIN
	                      tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber INNER JOIN
	                      tbCashCode ON tbInvoiceTask.CashCode = tbCashCode.CashCode INNER JOIN
	                      tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE     ((tbInvoiceTask.InvoiceValue + tbInvoiceTask.TaxValue) - (tbInvoiceTask.PaidValue + tbInvoiceTask.PaidTaxValue) > 0)
	GROUP BY tbInvoiceTask.InvoiceNumber, tbInvoice.AccountCode, tbInvoice.InvoicedOn, tbInvoice.CollectOn, tbInvoiceTask.CashCode
		
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	SELECT     ReferenceCode, AccountCode, PaymentOn, CashEntryTypeCode, PayIn, PayOut, CashCode
	FROM         vwStatementTasksConfirmed			
	
	select @ReferenceCode = dbo.fnSystemProfileText(3013)
	set @Balance = dbo.fnCashCompanyBalance()	
	SELECT @TransactOn = DATEADD(d, -1, MIN(TransactOn)) FROM @tbStatement
	SELECT TOP 1 @AccountCode = AccountCode FROM tbSystemOptions
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, Balance)
	VALUES (@ReferenceCode, @AccountCode, @TransactOn, 1, 0, 0, @Balance)

	
	
	set @ReferenceCode = dbo.fnSystemProfileText(1214)	
	SET @TransactOn = DATEADD(n, 1, @TransactOn)
	SELECT @PayOut = dbo.fnSystemCorpTaxBalance()
	SET @TaxAccrual = @PayOut
	SET @CashCode = dbo.fnSystemCashCode(1)
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	VALUES (@ReferenceCode, @AccountCode, @TransactOn, 5, 0, @PayOut, @CashCode)

	set @ReferenceCode2 = dbo.fnSystemProfileText(1215)	
	SET @TransactOn = DATEADD(n, 1, @TransactOn)
	SELECT @PayOut = SUM(CorporationTax)
	FROM         vwCorpTaxConfirmed
	IF @PayOut > 0
		BEGIN
		SET @TaxAccrual = @TaxAccrual + @PayOut
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
		VALUES (@ReferenceCode2, @AccountCode, @TransactOn, 5, 0, @PayOut, @CashCode)
		END	
	
	SET @TransactOn = DATEADD(n, 1, @TransactOn)
	SELECT @PayOut = dbo.fnSystemVatBalance()
	IF @PayOut <> 0
		BEGIN
		SET @TaxAccrual = @TaxAccrual + @PayOut
		IF @PayOut < 0
			BEGIN
			SET @PayIn = ABS(@PayOut)
			SET @PayOut = 0
			END
		ELSE
			SET @PayIn = 0
		SET @CashCode = dbo.fnSystemCashCode(2)
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
		VALUES (@ReferenceCode, @AccountCode, @TransactOn, 6, @PayIn, @PayOut, @CashCode)
		END
		
	SET @TransactOn = DATEADD(n, 1, @TransactOn)
	SELECT @PayOut = SUM(VatValue)
	FROM         vwTaskVatConfirmed
	IF @PayOut <> 0
		BEGIN
		SET @TaxAccrual = @TaxAccrual + @PayOut
		IF @PayOut < 0
			BEGIN
			SET @PayIn = ABS(@PayOut)
			SET @PayOut = 0
			END
		ELSE
			SET @PayIn = 0
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
		VALUES (@ReferenceCode2, @AccountCode, @TransactOn, 6, @PayIn, @PayOut, @CashCode)
		END	
	
	IF @TaxAccrual > 0
		BEGIN
		SET @ReferenceCode = dbo.fnSystemProfileText(1219)	
		SET @TransactOn = DATEADD(n, 1, @TransactOn)
		SET @PayIn = dbo.fnCashReserveBalance()
		IF @PayIn - @TaxAccrual > 0
			SET @PayIn = @TaxAccrual	
		IF @PayIn > 0
			BEGIN	
			INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
			VALUES (@ReferenceCode, @AccountCode, @TransactOn, 1, @PayIn, 0)
			END
		END
			
	declare curSt cursor for
		select TransactOn, CashEntryTypeCode, ReferenceCode, PayIn, PayOut, CashCode
		from @tbStatement
		order by TransactOn, CashEntryTypeCode, ReferenceCode, CashCode

	open curSt
	
	fetch next from curSt into @TransactOn, @CashEntryTypeCode, @ReferenceCode, @PayIn, @PayOut, @CashCode
	
	while (@@FETCH_STATUS = 0)
		begin
		set @Balance = @Balance + @PayIn - @PayOut
		if @CashCode IS NULL
			BEGIN
			update @tbStatement
			set Balance = @Balance
			where TransactOn = @TransactOn and CashEntryTypeCode = @CashEntryTypeCode and ReferenceCode = @ReferenceCode
			END
		ELSE
			BEGIN
			update @tbStatement
			set Balance = @Balance
			where TransactOn = @TransactOn and CashEntryTypeCode = @CashEntryTypeCode and ReferenceCode = @ReferenceCode and CashCode = @CashCode
			END
		fetch next from curSt into @TransactOn, @CashEntryTypeCode, @ReferenceCode, @PayIn, @PayOut, @CashCode
		end
	close curSt
	deallocate curSt
		
	RETURN
	END
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
INSERT INTO tbProfileText
                      (TextId, Message, Arguments)
VALUES     (1219, 'Reserve Account', 0)
INSERT INTO tbProfileText
                      (TextId, Message, Arguments)
VALUES     (1218, 'Raise invoice and pay expenses now?', 0)
GO
CREATE PROCEDURE dbo.spInvoicePay
	(
	@InvoiceNumber nvarchar(20)
	)
AS
DECLARE @PaidOut money
DECLARE @PaidIn money
DECLARE @TaskOutstanding money
DECLARE @ItemOutstanding money
DECLARE @CashModeCode smallint

DECLARE @AccountCode nvarchar(10)
DECLARE @CashAccountCode nvarchar(10)
DECLARE @UserId nvarchar(10)
DECLARE @PaymentCode nvarchar(20)
DECLARE @Now datetime


	SET @Now = getdate()
	SELECT @UserId = UserId FROM dbo.vwUserCredentials
	SET @PaymentCode = @UserId + '_' + LTRIM(STR(Year(@Now)))
		+ dbo.fnPad(LTRIM(STR(Month(@Now))), 2)
		+ dbo.fnPad(LTRIM(STR(Day(@Now))), 2)
		+ dbo.fnPad(LTRIM(STR(DatePart(hh, @Now))), 2)
		+ dbo.fnPad(LTRIM(STR(DatePart(n, @Now))), 2)
		+ dbo.fnPad(LTRIM(STR(DatePart(s, @Now))), 2)
	
	SELECT @CashModeCode = tbInvoiceType.CashModeCode, @AccountCode = tbInvoice.AccountCode
	FROM tbInvoice INNER JOIN tbInvoiceType ON tbInvoice.InvoiceTypeCode = tbInvoiceType.InvoiceTypeCode
	WHERE     (tbInvoice.InvoiceNumber = @InvoiceNumber)
	
	SELECT  @TaskOutstanding = SUM(tbInvoiceTask.InvoiceValue + tbInvoiceTask.TaxValue - tbInvoiceTask.PaidValue + tbInvoiceTask.PaidTaxValue)	                      
	FROM         tbInvoice INNER JOIN
	                      tbInvoiceTask ON tbInvoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
	                      tbInvoiceType ON tbInvoice.InvoiceTypeCode = tbInvoiceType.InvoiceTypeCode
	WHERE     (tbInvoice.InvoiceNumber = @InvoiceNumber)
	GROUP BY tbInvoiceType.CashModeCode


	SELECT @ItemOutstanding = SUM(tbInvoiceItem.InvoiceValue + tbInvoiceItem.TaxValue - tbInvoiceItem.PaidValue + tbInvoiceItem.PaidTaxValue)
	FROM         tbInvoice INNER JOIN
	                      tbInvoiceItem ON tbInvoice.InvoiceNumber = tbInvoiceItem.InvoiceNumber
	WHERE     (tbInvoice.InvoiceNumber = @InvoiceNumber)
	
	IF @CashModeCode = 1
		BEGIN
		SET @PaidOut = ISNULL(@TaskOutstanding, 0) + ISNULL(@ItemOutstanding, 0)
		SET @PaidIn = 0
		END
	ELSE
		BEGIN
		SET @PaidIn = ISNULL(@TaskOutstanding, 0) + ISNULL(@ItemOutstanding, 0)
		SET @PaidOut = 0
		END
	
	IF @PaidIn + @PaidOut > 0
		BEGIN
		SELECT TOP 1 @CashAccountCode = tbOrgAccount.CashAccountCode
		FROM         tbOrgAccount INNER JOIN
		                      tbCashCode ON tbOrgAccount.CashCode = tbCashCode.CashCode
		WHERE     (tbOrgAccount.AccountClosed = 0)
		GROUP BY tbOrgAccount.CashAccountCode
		
		INSERT INTO tbOrgPayment
		                      (PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, PaidOn, PaidInValue, PaidOutValue, PaymentReference)
		VALUES     (@PaymentCode,@UserId, 1,@AccountCode,@CashAccountCode,@Now,@PaidIn,@PaidOut,@InvoiceNumber)				
		exec dbo.spPaymentPostInvoiced @PaymentCode			
		END
		
	RETURN
GO
