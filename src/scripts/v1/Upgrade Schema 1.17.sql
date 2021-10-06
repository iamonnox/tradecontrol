/************************************************************
* Tru-Man Trade Control: Management Information and Cash System
* Copyright Tru-Man Industries Ltd 2010. All Rights Reserved.
* Author: Ian Monnox
* Description: Sql Server Upgrade Script - Encrypted Distribution Schema
* Data Version: 1.17
* Release Date: 30 July 2010
************************************************************/

ALTER TABLE dbo.tbSystemOptions WITH NOCHECK ADD
	TaxHorizon SMALLINT NOT NULL CONSTRAINT DF_tbSystemOptions_TaxHorizon DEFAULT (90)
GO
CREATE FUNCTION dbo.fnSystemTaxHorizon	()
RETURNS SMALLINT
AS
	BEGIN
	DECLARE @TaxHorizon SMALLINT
	SELECT @TaxHorizon = TaxHorizon FROM tbSystemOptions
	RETURN @TaxHorizon
	END
GO
UPDATE tbProfileText
SET [Message] = 'Invoiced'
WHERE TextId = 1214

UPDATE tbProfileText
SET [Message] = 'Ordered'
WHERE TextId = 1215
GO
ALTER VIEW [dbo].[vwCorpTaxConfirmedBase]
AS
SELECT     TOP 100 PERCENT dbo.fnAccountPeriod(dbo.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * - 1 ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) END AS OrderValue
FROM         dbo.vwTaskInvoicedQuantity RIGHT OUTER JOIN
                      dbo.fnNetProfitCashCodes() AS fnNetProfitCashCodes INNER JOIN
                      dbo.tbCashCategory INNER JOIN
                      dbo.tbCashCode ON dbo.tbCashCategory.CategoryCode = dbo.tbCashCode.CategoryCode ON 
                      fnNetProfitCashCodes.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbTask ON fnNetProfitCashCodes.CashCode = dbo.tbTask.CashCode ON dbo.vwTaskInvoicedQuantity.TaskCode = dbo.tbTask.TaskCode
WHERE     (dbo.tbTask.TaskStatusCode > 1) AND (dbo.tbTask.TaskStatusCode < 4) AND 
                      (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0) > 0) AND (dbo.tbTask.PaymentOn <= DATEADD(d, 
                      dbo.fnSystemTaxHorizon(), GETDATE()))
GO
ALTER VIEW [dbo].[vwTaskVatConfirmed]
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
                      * tbSystemTaxCode.TaxRate * - 1 END <> 0) AND (dbo.tbTask.PaymentOn <= DATEADD(d, dbo.fnSystemTaxHorizon(), GETDATE()))
GO
CREATE FUNCTION dbo.fnStatementReserves ()
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
	declare @Now datetime

	select @ReferenceCode = dbo.fnSystemProfileText(1219)
	set @Balance = dbo.fnCashReserveBalance()	
	SELECT @TransactOn = MAX(tbOrgPayment.PaidOn)
	FROM         tbOrgAccount INNER JOIN
						  tbOrgPayment ON tbOrgAccount.CashAccountCode = tbOrgPayment.CashAccountCode LEFT OUTER JOIN
						  tbCashCode ON tbOrgAccount.CashCode = tbCashCode.CashCode
	WHERE     (tbCashCode.CashCode IS NULL)

	SELECT TOP 1 @AccountCode = AccountCode FROM tbSystemOptions
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, Balance)
	VALUES (@ReferenceCode, @AccountCode, @TransactOn, 1, 0, 0, @Balance)
	
		set @ReferenceCode = dbo.fnSystemProfileText(1214)	
	SET @TransactOn = DATEADD(d, dbo.fnSystemTaxHorizon(), @TransactOn)
	SELECT @PayOut = dbo.fnSystemCorpTaxBalance()
	SET @CashCode = dbo.fnSystemCashCode(1)
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	VALUES (@ReferenceCode, @AccountCode, @TransactOn, 5, 0, @PayOut, @CashCode)

	set @ReferenceCode2 = dbo.fnSystemProfileText(1215)	
	SET @TransactOn = DATEADD(n, 1, @TransactOn)
	SELECT @PayOut = SUM(CorporationTax)
	FROM         vwCorpTaxConfirmed
	IF @PayOut > 0
		BEGIN
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
		VALUES (@ReferenceCode2, @AccountCode, @TransactOn, 5, 0, @PayOut, @CashCode)
		END	
	
	SET @TransactOn = DATEADD(n, 1, @TransactOn)
	SELECT @PayOut = dbo.fnSystemVatBalance()
	IF @PayOut <> 0
		BEGIN
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

	declare curReserve cursor local for
		select TransactOn, CashEntryTypeCode, ReferenceCode, PayIn, PayOut, CashCode
		from @tbStatement
		order by TransactOn, CashEntryTypeCode, ReferenceCode, CashCode

	open curReserve
	
	fetch next from curReserve into @TransactOn, @CashEntryTypeCode, @ReferenceCode, @PayIn, @PayOut, @CashCode
	
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
		fetch next from curReserve into @TransactOn, @CashEntryTypeCode, @ReferenceCode, @PayIn, @PayOut, @CashCode
		end
	close curReserve
	deallocate curReserve

	RETURN
	END
GO
CREATE VIEW dbo.vwStatementReserves
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
ALTER FUNCTION [dbo].[fnStatementCompany]()
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
	declare @CashCode nvarchar(50)
	declare @AccountCode nvarchar(10)
	declare @TransactOn datetime
	declare @CashEntryTypeCode smallint
	declare @PayOut money
	declare @PayIn money
	declare @Balance money

	
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
	
	/**************************************/
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	SELECT     ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode
	FROM         dbo.fnStatementCorpTax()
	
	/* OMIT CORPORATION TAX FORECASTING
	set @ReferenceCode = dbo.fnSystemProfileText(1215)	
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	SELECT     @ReferenceCode AS ReferenceCode, dbo.fnStatementTaxAccount(1) AS AccountCode, StartOn, 5, 0, CorporationTax, CashCode
	FROM         fnTaxCorpOrderTotals(0) fnTaxCorpOrderTotals_1		
	*/

	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	SELECT     ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode
	FROM         dbo.fnStatementVat()


	SET @ReferenceCode = dbo.fnSystemProfileText(1215)	
	SET @AccountCode = dbo.fnStatementTaxAccount(2)
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	SELECT     @ReferenceCode AS ReferenceCode, @AccountCode AS AccountCode, dbo.fnTaskDefaultPaymentOn(@AccountCode, StartOn), 6 AS Expr1, PayIn, PayOut, dbo.fnSystemCashCode(2)
	FROM         fnTaxVatOrderTotals(0) fnTaxVatOrderTotals_1
	WHERE     (PayIn + PayOut <> 0)		

	
	select @ReferenceCode = dbo.fnSystemProfileText(3013)
	set @Balance = dbo.fnCashCompanyBalance()	
	SELECT @TransactOn = DATEADD(d, -1, MIN(TransactOn)) FROM @tbStatement
	SELECT TOP 1 @AccountCode = AccountCode FROM tbSystemOptions
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, Balance)
	VALUES (@ReferenceCode, @AccountCode, @TransactOn, 1, 0, 0, @Balance)

	
	
			
	declare curSt cursor local for
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
	declare @StartOn datetime
	declare @Balance money
	declare @LastBalance money
	declare @TaxDue money
	
	declare @ReferenceCode nvarchar(20)	
	declare @CashCode nvarchar(50)
	declare @AccountCode nvarchar(10)
	
	set @ReferenceCode = dbo.fnSystemProfileText(1214)	
	set @CashCode = dbo.fnSystemCashCode(1)
	set @AccountCode = dbo.fnStatementTaxAccount(1)
	
	declare curCorpTax cursor for
		SELECT     StartOn, TaxDue, Balance
		FROM         vwTaxCorpStatement
		ORDER BY StartOn DESC

	open curCorpTax
	
	fetch next from curCorpTax into @StartOn, @TaxDue, @Balance
	
	set @Balance = isnull(@Balance, 0)
	set @LastBalance = @Balance + 1
	
	while ((@@FETCH_STATUS = 0) AND (@Balance > 0) AND (@Balance < @LastBalance)) 
		begin					
		if (@Balance < 0) AND (@TaxDue > 0)
			begin
			insert into @tbCorpTax (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayOut, PayIn, CashCode)
			values (@ReferenceCode, @AccountCode, @StartOn, 5, @Balance, 0, @CashCode)						
			end
		set @LastBalance = @Balance
		fetch next from curCorpTax into @StartOn, @TaxDue, @Balance	
		end
		
	close curCorpTax
	deallocate curCorpTax
	
	RETURN
	END
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
	
	if exists(SELECT  MAX(StartOn) AS LastStartOn FROM vwTaxVatStatement)
		begin
		select @LastBalanceOn = MAX(StartOn) FROM vwTaxVatStatement
		SELECT  TOP 1 @VatDueOn = PayOn
		FROM         vwStatementVatDueDate
		
		SET @VatDueOn = dbo.fnTaskDefaultPaymentOn(@AccountCode, @VatDueOn)
		
		SELECT @VatDue = Balance
		FROM         vwTaxVatStatement
		WHERE     (StartOn = @LastBalanceOn)		
		
		if (@VatDue <> 0)
			begin
			insert into @tbVat (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayOut, PayIn, CashCode)
			values (@ReferenceCode, @AccountCode, @VatDueOn, 6, CASE WHEN @VatDue > 0 THEN @VatDue ELSE 0 END, CASE WHEN @VatDue < 0 THEN ABS(@VatDue) ELSE 0 END, @CashCode)						
			end
		end
	
	RETURN
	END
GO
ALTER FUNCTION [dbo].[fnTaxVatOrderTotals]
	(@IncludeForecasts bit = 0)
RETURNS @tbVat TABLE 
	(
	CashCode nvarchar(50),
	StartOn datetime, 
	PayIn money,
	PayOut money
	)
AS
	BEGIN
	declare @PayOn datetime
	declare @PayFrom datetime
	declare @PayTo datetime
	
	declare @VatCharge money
	
	declare @CashCode nvarchar(50)
	set @CashCode = dbo.fnSystemCashCode(2)
	
	declare curVat cursor local for
		SELECT     PayOn, PayFrom, PayTo
		FROM         fnTaxTypeDueDates(2) fnTaxTypeDueDates
		
	open curVat
	fetch next from curVat into @PayOn, @PayFrom, @PayTo
	while (@@FETCH_STATUS = 0)
		begin
		if (@IncludeForecasts = 0)
			begin
			INSERT INTO @tbVat (CashCode, StartOn, PayOut, PayIn)
			SELECT     @CashCode As CashCode, @PayOn AS PayOn, CASE WHEN ISNULL(SUM(VatValue), 0) > 0 THEN ISNULL(SUM(VatValue), 0) ELSE 0 END AS PayOut, 
			                      CASE WHEN ISNULL(SUM(VatValue), 0) < 0 THEN ABS(ISNULL(SUM(VatValue), 0)) ELSE 0 END AS PayIn
			FROM         vwTaskVatConfirmed
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo) AND (VatValue <> 0) 
			end
		else
			begin
			INSERT INTO @tbVat (CashCode, StartOn, PayOut, PayIn)
			SELECT    @CashCode AS CashCode, @PayOn AS PayOn, 
				CASE WHEN ISNULL(SUM(VatValue), 0) > 0 THEN ISNULL(SUM(VatValue), 0) ELSE 0 END AS PayOut, 
				CASE WHEN ISNULL(SUM(VatValue), 0) < 0 THEN ABS(ISNULL(SUM(VatValue), 0)) ELSE 0 END AS PayIn
			FROM         vwTaskVatFull
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo) 
			end		
						
		fetch next from curVat into @PayOn, @PayFrom, @PayTo
		end
	
	close curVat
	deallocate curVat

	
	RETURN
	END
GO
