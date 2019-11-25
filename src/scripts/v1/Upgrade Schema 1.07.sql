/************************************************************
* Tru-Man Trade Control: Information and Cash System
* Copyright Tru-Man Industries Ltd 2008. All Rights Reserved.
* Author: Ian Monnox
* Description: Sql Server Upgrade Script - Encrypted Distribution Schema
* Data Version: 1.07
* Release Date: TBC
************************************************************/

insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (2017,
'There is a problem with this installation.
Components have not been properly registered.
Please re-install the application and contact technical support.

<1>', 1)
GO
DROP INDEX tbInvoiceTask.IX_tbInvoiceTask_CashCode
DROP INDEX tbInvoiceItem.IX_tbInvoiceItem_CashCode
GO
CREATE NONCLUSTERED INDEX [IX_tbInvoiceTask_CashCode] ON [dbo].[tbInvoiceTask] 
(
	[CashCode] ASC,
	[InvoiceNumber] ASC
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbInvoiceItem_CashCode] ON [dbo].[tbInvoiceItem] 
(
	[CashCode] ASC,
	[InvoiceNumber] ASC
) ON [PRIMARY]
GO
UPDATE dbo.tbCashType
   SET CashType = 'EXTERNAL'
 WHERE CashTypeCode = 2
GO
if not exists(select CashEntryTypeCode from tbCashEntryType where CashEntryTypeCode = 7)
	begin
	INSERT INTO [dbo].[tbCashEntryType]
			   ([CashEntryTypeCode]
			   ,[CashEntryType])
		 VALUES
			   (7,
			   'Forecast')
	END
GO
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1214, 'Actual', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1215, 'Calculated', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1216, 'Ok to move forward overdue payments?', 0)

DROP FUNCTION [dbo].[fnCashCodeDefaultAccount]
GO
DROP VIEW [dbo].[vwStatementInvoices]
GO
DROP VIEW [dbo].[vwCorpTaxManualForecasts]
GO
DROP VIEW [dbo].[vwTaxVatManualForecasts]
GO
CREATE VIEW [dbo].[vwTaxVatManualForecasts]
AS
SELECT     dbo.tbCashPeriod.StartOn, 
                      SUM(CASE WHEN CashModeCode = 1 THEN dbo.tbCashPeriod.ForecastValue * dbo.tbSystemTaxCode.TaxRate ELSE dbo.tbCashPeriod.ForecastValue *
                       dbo.tbSystemTaxCode.TaxRate * - 1 END) AS VatCharge
FROM         dbo.tbCashPeriod INNER JOIN
                      dbo.tbCashCode ON dbo.tbCashPeriod.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbCashCode.TaxCode = dbo.tbSystemTaxCode.TaxCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode
WHERE     (dbo.tbCashCategory.ManualForecast <> 0) AND (dbo.tbSystemTaxCode.TaxTypeCode = 2)
GROUP BY dbo.tbCashPeriod.StartOn
HAVING      (dbo.tbCashPeriod.StartOn >= dbo.fnSystemActiveStartOn())
GO
CREATE VIEW [dbo].[vwCorpTaxManualForecasts]
AS
SELECT     dbo.tbCashPeriod.StartOn, dbo.tbSystemYearPeriod.CorporationTaxRate, 
                      SUM(CASE WHEN tbCashCategory.CashModeCode = 1 THEN ForecastValue * - 1 ELSE ForecastValue END) AS NetProfit, 
                      SUM(CASE WHEN tbCashCategory.CashModeCode = 1 THEN ForecastValue * - 1 ELSE ForecastValue END) 
                      * dbo.tbSystemYearPeriod.CorporationTaxRate AS CorporationTax
FROM         dbo.fnNetProfitCashCodes() AS fnNetProfitCashCodes_1 INNER JOIN
                      dbo.tbCashPeriod ON fnNetProfitCashCodes_1.CashCode = dbo.tbCashPeriod.CashCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbCashPeriod.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.tbCashPeriod.StartOn = dbo.tbSystemYearPeriod.StartOn
WHERE     (dbo.tbCashCategory.ManualForecast <> 0)
GROUP BY dbo.tbCashPeriod.StartOn, dbo.tbSystemYearPeriod.CorporationTaxRate
HAVING      (dbo.tbCashPeriod.StartOn >= dbo.fnSystemActiveStartOn())
GO
CREATE FUNCTION [dbo].[fnCashCodeDefaultAccount] 
	(
	@CashCode nvarchar(50)
	)
RETURNS nvarchar(10)
AS
	BEGIN
	declare @AccountCode nvarchar(10)
	if exists(SELECT     CashCode
	          FROM         tbInvoiceTask
	          WHERE     (CashCode = @CashCode))
		begin
		SELECT  @AccountCode = tbInvoice.AccountCode
		FROM         tbInvoiceTask INNER JOIN
		                      tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber
		WHERE     (tbInvoiceTask.CashCode = @CashCode)
		ORDER BY tbInvoice.InvoicedOn DESC		
		end
	else if exists(SELECT     CashCode
	          FROM         tbInvoiceItem
	          WHERE     (CashCode = @CashCode))
		begin
		SELECT  @AccountCode = tbInvoice.AccountCode
		FROM         tbInvoiceItem INNER JOIN
		                      tbInvoice ON tbInvoiceItem.InvoiceNumber = tbInvoice.InvoiceNumber
		WHERE     (tbInvoiceItem.CashCode = @CashCode)		
		ORDER BY tbInvoice.InvoicedOn DESC	
		end
	else
		begin	
		select @AccountCode = AccountCode from tbSystemOptions
		end
		
	RETURN @AccountCode
	END
GO
DROP VIEW [dbo].[vwStatementForecasts]
GO
CREATE VIEW [dbo].[vwStatementForecasts]
AS
SELECT     dbo.tbCashPeriod.CashCode, dbo.fnCashCodeDefaultAccount(dbo.tbCashPeriod.CashCode) AS AccountCode, DATEADD(m, 1, dbo.tbCashPeriod.StartOn) 
                      - 1 AS TransactOn, 7 AS CashEntryTypeCode, CASE WHEN CashModeCode = 2 THEN ForecastValue + ForecastTax ELSE 0 END AS PayIn, 
                      CASE WHEN CashModeCode = 1 THEN ForecastValue + ForecastTax ELSE 0 END AS PayOut
FROM         dbo.tbCashPeriod INNER JOIN
                      dbo.tbCashCode ON dbo.tbCashPeriod.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode
WHERE     (dbo.tbCashCategory.ManualForecast <> 0) AND (dbo.tbCashPeriod.StartOn >= dbo.fnSystemActiveStartOn()) AND (dbo.tbCashPeriod.ForecastValue > 0)
GO
DROP FUNCTION [dbo].[fnStatementCorpTax]
GO
CREATE FUNCTION [dbo].[fnStatementCorpTax]
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
	
	set @ReferenceCode = dbo.fnSystemProfileText(1214)	
	set @CashCode = dbo.fnSystemCashCode(1)
	
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
		if (@Balance <> 0) AND (@TaxDue > 0)
			begin
			insert into @tbCorpTax (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayOut, PayIn, CashCode)
			values (@ReferenceCode, dbo.fnStatementTaxAccount(2), @StartOn, 5, @TaxDue, 0, @CashCode)						
			end
		set @LastBalance = @Balance
		fetch next from curCorpTax into @StartOn, @TaxDue, @Balance	
		end
		
	close curCorpTax
	deallocate curCorpTax
	
	RETURN
	END
GO
DROP FUNCTION [dbo].[fnStatementVat]
GO
CREATE FUNCTION [dbo].[fnStatementVat]
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
	
	set @ReferenceCode = dbo.fnSystemProfileText(1214)	
	set @CashCode = dbo.fnSystemCashCode(1)
	
	if exists(SELECT  MAX(StartOn) AS LastStartOn FROM vwTaxVatStatement)
		begin
		select @LastBalanceOn = MAX(StartOn) FROM vwTaxVatStatement
		SELECT  TOP 1 @VatDueOn = PayOn
		FROM         vwStatementVatDueDate
		
		SELECT @VatDue = Balance
		FROM         vwTaxVatStatement
		WHERE     (StartOn = @LastBalanceOn)		
		
		if (@VatDue <> 0)
			begin
			insert into @tbVat (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayOut, PayIn, CashCode)
			values (@ReferenceCode, dbo.fnStatementTaxAccount(2), @VatDueOn, 6, CASE WHEN @VatDue > 0 THEN @VatDue ELSE 0 END, CASE WHEN @VatDue < 0 THEN ABS(@VatDue) ELSE 0 END, @CashCode)						
			end
		end
	
	RETURN
	END
GO
ALTER FUNCTION [dbo].[fnTaxCorpOrderTotals]
(@IncludeForecasts bit = 0)
RETURNS @tbCorp TABLE 
	(
	CashCode nvarchar(50),
	StartOn datetime, 
	NetProfit money,
	CorporationTax money
	)
AS
	BEGIN
	declare @PayOn datetime
	declare @PayFrom datetime
	declare @PayTo datetime
	
	declare @NetProfit money
	declare @CorporationTax money
	
	declare @CashCode nvarchar(50)
	set @CashCode = dbo.fnSystemCashCode(1)
	
	declare curVat cursor local for
		SELECT     PayOn, PayFrom, PayTo
		FROM         fnTaxTypeDueDates(1) fnTaxTypeDueDates
		
	open curVat
	fetch next from curVat into @PayOn, @PayFrom, @PayTo
	while (@@FETCH_STATUS = 0)
		begin
		if (@IncludeForecasts = 0)
			begin
			INSERT INTO @tbCorp (CashCode, StartOn, NetProfit, CorporationTax)
			SELECT     @CashCode As CashCode, @PayOn AS PayOn, ISNULL(SUM(NetProfit), 0) AS NetProfit, ISNULL(SUM(CorporationTax), 0) AS CorporationTax
			FROM         vwCorpTaxConfirmed
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
			HAVING      (ISNULL(SUM(CorporationTax), 0) > 0)
			end
		else
			begin
			INSERT INTO @tbCorp (CashCode, StartOn, NetProfit, CorporationTax)
			SELECT     @CashCode As CashCode, @PayOn AS PayOn, ISNULL(SUM(NetProfit), 0) AS NetProfit, ISNULL(SUM(CorporationTax), 0) AS CorporationTax
			FROM         vwCorpTaxTasks
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
			HAVING      (ISNULL(SUM(CorporationTax), 0) > 0)
			end	
		
		if exists (select StartOn from @tbCorp where StartOn = @PayOn)
			begin
			SELECT     @NetProfit = ISNULL(SUM(NetProfit), 0), 
				@CorporationTax = ISNULL(SUM(CorporationTax), 0)
			FROM         vwCorpTaxManualForecasts
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
			HAVING      (ISNULL(SUM(CorporationTax), 0) > 0)						
			
			if @@ROWCOUNT > 0
				begin
				UPDATE @tbCorp
				SET NetProfit = NetProfit + @NetProfit, 
					CorporationTax = CorporationTax + @CorporationTax
				WHERE StartOn = @PayOn
				end
			end
		else
			begin
			INSERT INTO @tbCorp (CashCode, StartOn, NetProfit, CorporationTax)
			SELECT     @CashCode As CashCode, @PayOn AS PayOn, ISNULL(SUM(NetProfit), 0) AS NetProfit, ISNULL(SUM(CorporationTax), 0) AS CorporationTax
			FROM         vwCorpTaxManualForecasts
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
			HAVING      (ISNULL(SUM(CorporationTax), 0) > 0)				
			end	
		fetch next from curVat into @PayOn, @PayFrom, @PayTo
		end
	
	close curVat
	deallocate curVat

	
	RETURN
	END
GO
DROP FUNCTION [dbo].[fnStatementCompany]
GO
CREATE FUNCTION [dbo].[fnStatementCompany]
	(
	@IncludeForecasts bit = 0,
	@UseInvoiceDate bit = 0
	)
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
	declare @AccountCode nvarchar(10)
	declare @TransactOn datetime
	declare @CashEntryTypeCode smallint
	declare @PayOut money
	declare @PayIn money
	declare @Balance money

	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	SELECT     CashCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode
	FROM vwStatementForecasts

	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	SELECT     ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode
	FROM         dbo.fnStatementCorpTax()

	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	SELECT     ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode
	FROM         dbo.fnStatementVat()

	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, CashCode, PayIn, PayOut)	
	SELECT     tbInvoiceItem.InvoiceNumber, tbInvoice.AccountCode, case when @UseInvoiceDate = 0 then tbInvoice.CollectOn else tbInvoice.InvoicedOn end As TransactOn, 2 AS CashEntryTypeCode, tbInvoiceItem.CashCode, 
	                      SUM(CASE WHEN InvoiceTypeCode = 1 OR
	                      InvoiceTypeCode = 4 THEN (tbInvoiceItem.InvoiceValue + tbInvoiceItem.TaxValue) - (tbInvoiceItem.PaidValue + tbInvoiceItem.PaidTaxValue) 
	                      ELSE 0 END) AS PayIn, SUM(CASE WHEN InvoiceTypeCode = 2 OR
	                      InvoiceTypeCode = 3 THEN (tbInvoiceItem.InvoiceValue + tbInvoiceItem.TaxValue) - (tbInvoiceItem.PaidValue + tbInvoiceItem.PaidTaxValue) 
	                      ELSE 0 END) AS PayOut
	FROM         tbInvoiceItem INNER JOIN
	                      tbInvoice ON tbInvoiceItem.InvoiceNumber = tbInvoice.InvoiceNumber INNER JOIN
	                      tbCashCode ON tbInvoiceItem.CashCode = tbCashCode.CashCode INNER JOIN
	                      tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE     ((tbInvoiceItem.InvoiceValue + tbInvoiceItem.TaxValue) - (tbInvoiceItem.PaidValue + tbInvoiceItem.PaidTaxValue) > 0) AND 
	                      (tbCashCategory.ManualForecast = 0)
	GROUP BY tbInvoiceItem.InvoiceNumber, tbInvoice.AccountCode, tbInvoice.InvoicedOn, tbInvoice.CollectOn, tbInvoiceItem.CashCode

	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, CashCode, PayIn, PayOut)		
	SELECT     tbInvoiceTask.InvoiceNumber, tbInvoice.AccountCode, case when @UseInvoiceDate = 0 then tbInvoice.CollectOn else tbInvoice.InvoicedOn end As TransactOn, 2 AS CashEntryTypeCode, tbInvoiceTask.CashCode, 
	                      SUM(CASE WHEN InvoiceTypeCode = 1 OR
	                      InvoiceTypeCode = 4 THEN (tbInvoiceTask.InvoiceValue + tbInvoiceTask.TaxValue) - (tbInvoiceTask.PaidValue + tbInvoiceTask.PaidTaxValue) 
	                      ELSE 0 END) AS PayIn, SUM(CASE WHEN InvoiceTypeCode = 2 OR
	                      InvoiceTypeCode = 3 THEN (tbInvoiceTask.InvoiceValue + tbInvoiceTask.TaxValue) - (tbInvoiceTask.PaidValue + tbInvoiceTask.PaidTaxValue) 
	                      ELSE 0 END) AS PayOut
	FROM         tbInvoiceTask INNER JOIN
	                      tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber INNER JOIN
	                      tbCashCode ON tbInvoiceTask.CashCode = tbCashCode.CashCode INNER JOIN
	                      tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE     ((tbInvoiceTask.InvoiceValue + tbInvoiceTask.TaxValue) - (tbInvoiceTask.PaidValue + tbInvoiceTask.PaidTaxValue) > 0) AND 
	                      (tbCashCategory.ManualForecast = 0)
	GROUP BY tbInvoiceTask.InvoiceNumber, tbInvoice.AccountCode, tbInvoice.InvoicedOn, tbInvoice.CollectOn, tbInvoiceTask.CashCode
		
	
	if (@IncludeForecasts = 0)
		begin
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
		SELECT     ReferenceCode, AccountCode, case when @UseInvoiceDate = 0 then PaymentOn else ActionOn end as TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode
		FROM         vwStatementTasksConfirmed			
		end
	else
		begin
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
		SELECT     ReferenceCode, AccountCode, case when @UseInvoiceDate = 0 then PaymentOn else ActionOn end as TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode
		FROM         vwStatementTasksFull	
		end

	set @ReferenceCode = dbo.fnSystemProfileText(1215)	
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	SELECT     @ReferenceCode AS ReferenceCode, dbo.fnStatementTaxAccount(1) AS AccountCode, StartOn, 5, 0, CorporationTax, CashCode
	FROM         fnTaxCorpOrderTotals(@IncludeForecasts) fnTaxCorpOrderTotals_1		

	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	SELECT     @ReferenceCode AS ReferenceCode, dbo.fnStatementTaxAccount(1) AS AccountCode, StartOn, 6 AS Expr1, PayIn, PayOut, dbo.fnSystemCashCode(2)
	FROM         fnTaxVatOrderTotals(@IncludeForecasts) fnTaxVatOrderTotals_1
	WHERE     (PayIn + PayOut <> 0)		


	
	select @ReferenceCode = dbo.fnSystemProfileText(3013)
	set @Balance = dbo.fnCashCompanyBalance()	
	SELECT @TransactOn = DATEADD(d, -1, MIN(TransactOn)) FROM @tbStatement
	SELECT TOP 1 @AccountCode = AccountCode FROM tbSystemOptions
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
	VALUES (@ReferenceCode, @AccountCode, @TransactOn, 1, 0, 0)
	
	declare curSt cursor for
		select TransactOn, CashEntryTypeCode, ReferenceCode, PayIn, PayOut
		from @tbStatement
		order by TransactOn, CashEntryTypeCode, ReferenceCode

	open curSt
	
	fetch next from curSt into @TransactOn, @CashEntryTypeCode, @ReferenceCode, @PayIn, @PayOut
	
	while (@@FETCH_STATUS = 0)
		begin
		set @Balance = @Balance + @PayIn - @PayOut
		update @tbStatement
		set Balance = @Balance
		where TransactOn = @TransactOn and CashEntryTypeCode = @CashEntryTypeCode and ReferenceCode = @ReferenceCode
		
		fetch next from curSt into @TransactOn, @CashEntryTypeCode, @ReferenceCode, @PayIn, @PayOut		
		end
	close curSt
	deallocate curSt
		
	RETURN
	END
GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[spStatementCompany]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[spStatementCompany]
GO
CREATE PROCEDURE [dbo].[spStatementCompany]
	(
		@IncludeForecasts bit = 0,
		@UseInvoiceDate bit = 0
	)
AS
	SELECT     fnStatementCompany.TransactOn, fnStatementCompany.CashEntryTypeCode, fnStatementCompany.ReferenceCode, 
	                      fnStatementCompany.AccountCode, tbOrg.AccountName, tbCashEntryType.CashEntryType, fnStatementCompany.PayOut, fnStatementCompany.PayIn, 
	                      fnStatementCompany.Balance, tbCashCode.CashCode, tbCashCode.CashDescription
	FROM         dbo.fnStatementCompany(@IncludeForecasts, @UseInvoiceDate) AS fnStatementCompany INNER JOIN
	                      tbCashEntryType ON fnStatementCompany.CashEntryTypeCode = tbCashEntryType.CashEntryTypeCode INNER JOIN
	                      tbOrg ON fnStatementCompany.AccountCode = tbOrg.AccountCode LEFT OUTER JOIN
	                      tbCashCode ON fnStatementCompany.CashCode = tbCashCode.CashCode
	ORDER BY fnStatementCompany.TransactOn, fnStatementCompany.CashEntryTypeCode, fnStatementCompany.ReferenceCode
	
	
	RETURN 
GO
DROP VIEW [dbo].[vwStatementTasksConfirmed]
GO
CREATE VIEW [dbo].[vwStatementTasksConfirmed]
AS
SELECT     TOP 100 PERCENT dbo.tbTask.TaskCode AS ReferenceCode, dbo.tbTask.AccountCode, dbo.tbTask.ActionOn, dbo.tbTask.PaymentOn, 
                      3 AS CashEntryTypeCode, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.tbSystemTaxCode.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayOut, 
                      CASE WHEN tbCashCategory.CashModeCode = 2 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.tbSystemTaxCode.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayIn, dbo.tbCashCode.CashCode
FROM         dbo.tbSystemTaxCode INNER JOIN
                      dbo.tbTask ON dbo.tbSystemTaxCode.TaxCode = dbo.tbTask.TaxCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.tbTask.TaskStatusCode > 1) AND (dbo.tbTask.TaskStatusCode < 4) AND 
                      (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0) > 0)
GO
DROP VIEW [dbo].[vwStatementTasksFull]
GO
CREATE VIEW [dbo].[vwStatementTasksFull]
AS
SELECT     TOP 100 PERCENT dbo.tbTask.TaskCode AS ReferenceCode, dbo.tbTask.AccountCode, dbo.tbTask.ActionOn, dbo.tbTask.PaymentOn, 
                      CASE WHEN tbTask.TaskStatusCode = 1 THEN 4 ELSE 3 END AS CashEntryTypeCode, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.tbSystemTaxCode.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayOut, 
                      CASE WHEN tbCashCategory.CashModeCode = 2 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.tbSystemTaxCode.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayIn, dbo.tbCashCode.CashCode
FROM         dbo.tbSystemTaxCode INNER JOIN
                      dbo.tbTask ON dbo.tbSystemTaxCode.TaxCode = dbo.tbTask.TaxCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.tbTask.TaskStatusCode < 4) AND (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0) > 0)
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
			INSERT INTO @tbVat (CashCode, StartOn, PayIn, PayOut)
			SELECT     @CashCode As CashCode, @PayOn AS PayOn, CASE WHEN ISNULL(SUM(VatValue), 0) > 0 THEN ISNULL(SUM(VatValue), 0) ELSE 0 END AS PayIn, 
			                      CASE WHEN ISNULL(SUM(VatValue), 0) < 0 THEN ABS(ISNULL(SUM(VatValue), 0)) ELSE 0 END AS PayOut
			FROM         vwTaskVatConfirmed
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo) AND (VatValue <> 0) 
			end
		else
			begin
			INSERT INTO @tbVat (CashCode, StartOn, PayIn, PayOut)
			SELECT    @CashCode AS CashCode, @PayOn AS PayOn, 
				CASE WHEN ISNULL(SUM(VatValue), 0) > 0 THEN ISNULL(SUM(VatValue), 0) ELSE 0 END AS PayIn, 
				CASE WHEN ISNULL(SUM(VatValue), 0) < 0 THEN ABS(ISNULL(SUM(VatValue), 0)) ELSE 0 END AS PayOut
			FROM         vwTaskVatFull
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo) 
			end
			
		if exists (select StartOn from @tbVat where StartOn = @PayOn)
			begin
			SELECT     @VatCharge = SUM(VatCharge)
			FROM         vwTaxVatManualForecasts
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
			HAVING      (ISNULL(SUM(VatCharge), 0) <> 0)						
			
			if @@ROWCOUNT > 0
				begin
				UPDATE @tbVat
				SET PayIn = PayIn + CASE WHEN @VatCharge > 0 THEN @VatCharge ELSE 0 END, 
					PayOut = PayOut + CASE WHEN @VatCharge < 0 THEN ABS(@VatCharge) ELSE 0 END
				WHERE StartOn = @PayOn
				end
			end
		else
			begin
			INSERT INTO @tbVat (CashCode, StartOn, PayIn, PayOut)
			SELECT     @CashCode As CashCode, @PayOn AS PayOn, 
				CASE WHEN SUM(VatCharge) > 0 THEN SUM(VatCharge) ELSE 0 END,
				CASE WHEN SUM(VatCharge) < 0 THEN ABS(SUM(VatCharge)) ELSE 0 END
			FROM         vwTaxVatManualForecasts
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
			HAVING      (ISNULL(SUM(VatCharge), 0) <> 0)				
			end	
						
		fetch next from curVat into @PayOn, @PayFrom, @PayTo
		end
	
	close curVat
	deallocate curVat

	
	RETURN
	END
GO
ALTER  PROCEDURE [dbo].[spSystemPeriodTransferAll]
AS

	UPDATE tbCashPeriod
	SET InvoiceValue = 0, InvoiceTax = 0, CashValue = 0, CashTax = 0

		
	UPDATE tbCashPeriod
	SET InvoiceValue = vwCashCodeInvoiceSummary.InvoiceValue, 
		InvoiceTax = vwCashCodeInvoiceSummary.TaxValue
	FROM         tbCashPeriod INNER JOIN
	                      vwCashCodeInvoiceSummary ON tbCashPeriod.CashCode = vwCashCodeInvoiceSummary.CashCode AND tbCashPeriod.StartOn = vwCashCodeInvoiceSummary.StartOn	
	
	UPDATE tbCashPeriod
	SET CashValue = vwCashCodePaymentSummary.CashValue, 
		CashTax = vwCashCodePaymentSummary.CashTax
	FROM         tbCashPeriod INNER JOIN
	                      vwCashCodePaymentSummary ON tbCashPeriod.CashCode = vwCashCodePaymentSummary.CashCode AND 
	                      tbCashPeriod.StartOn = vwCashCodePaymentSummary.StartOn

	UPDATE tbCashPeriod
	SET CashValue = vwCashAccountPeriodClosingBalance.ClosingBalance,
		InvoiceValue = vwCashAccountPeriodClosingBalance.ClosingBalance
	FROM         vwCashAccountPeriodClosingBalance INNER JOIN
	                      tbCashPeriod ON vwCashAccountPeriodClosingBalance.CashCode = tbCashPeriod.CashCode AND 
	                      vwCashAccountPeriodClosingBalance.StartOn = tbCashPeriod.StartOn

	RETURN 
GO
ALTER  PROCEDURE [dbo].[spCashFlowInitialise]
AS
declare @StartOn datetime
		
	exec dbo.spCashGeneratePeriods
	
	select @StartOn = StartOn
	from fnSystemActivePeriod() fnSystemActivePeriod	
	
	UPDATE tbCashPeriod
	SET ForecastValue = 0, ForecastTax = 0
	FROM         tbCashPeriod INNER JOIN
	                      tbCashCode ON tbCashPeriod.CashCode = tbCashCode.CashCode INNER JOIN
	                      tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE     (tbCashCategory.ManualForecast = 0) AND (tbCashPeriod.StartOn >= @StartOn)
	
	UPDATE tbCashPeriod
	SET 
		ForecastValue = vwCashCodeForecastSummary.ForecastValue, 
		ForecastTax = vwCashCodeForecastSummary.ForecastTax
	FROM         tbCashPeriod INNER JOIN
	                      vwCashCodeForecastSummary ON tbCashPeriod.CashCode = vwCashCodeForecastSummary.CashCode AND 
	                      tbCashPeriod.StartOn = vwCashCodeForecastSummary.StartOn INNER JOIN
	                      tbCashCode ON tbCashPeriod.CashCode = tbCashCode.CashCode INNER JOIN
	                      tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE     (tbCashPeriod.StartOn >= @StartOn) AND (tbCashCategory.ManualForecast = 0)
	
	
	UPDATE tbCashPeriod
	SET ForecastValue = 0, 
	ForecastTax = 0
	FROM         tbCashPeriod INNER JOIN
	                      tbCashTaxType ON tbCashPeriod.CashCode = tbCashTaxType.CashCode
	WHERE     (tbCashPeriod.StartOn >= @StartOn)

	UPDATE tbCashPeriod
	SET ForecastValue = fnStatementCorpTax_1.PayOut
	FROM         dbo.fnStatementCorpTax() AS fnStatementCorpTax_1 INNER JOIN
	                      tbCashPeriod ON fnStatementCorpTax_1.CashCode = tbCashPeriod.CashCode AND fnStatementCorpTax_1.TransactOn = tbCashPeriod.StartOn
	
	UPDATE tbCashPeriod
	SET ForecastValue = ForecastValue + fnTaxCorpOrderTotals_1.CorporationTax
	FROM         dbo.fnTaxCorpOrderTotals(DEFAULT) AS fnTaxCorpOrderTotals_1 INNER JOIN
	                      tbCashPeriod ON fnTaxCorpOrderTotals_1.CashCode = tbCashPeriod.CashCode AND fnTaxCorpOrderTotals_1.StartOn = tbCashPeriod.StartOn

	UPDATE tbCashPeriod
	SET ForecastValue = CASE WHEN PayIn > 0 THEN PayIn * - 1 ELSE PayOut END
	FROM         dbo.fnStatementVat() AS fnStatementVat_1 INNER JOIN
	                      tbCashPeriod ON fnStatementVat_1.CashCode = tbCashPeriod.CashCode AND fnStatementVat_1.TransactOn = tbCashPeriod.StartOn	

	UPDATE tbCashPeriod
	SET ForecastValue = ForecastValue + CASE WHEN PayIn > 0 THEN PayIn * - 1 ELSE PayOut END
	FROM         dbo.fnTaxVatOrderTotals(DEFAULT) AS fnTaxVatOrderTotals_1 INNER JOIN
	                      tbCashPeriod ON fnTaxVatOrderTotals_1.CashCode = tbCashPeriod.CashCode AND fnTaxVatOrderTotals_1.StartOn = tbCashPeriod.StartOn
	                      	

	UPDATE tbCashPeriod
	SET
		ForecastValue = vwCashFlowNITotals.ForecastNI, 
		CashValue = vwCashFlowNITotals.CashNI, 
		InvoiceValue = vwCashFlowNITotals.InvoiceNI
	FROM         tbCashPeriod INNER JOIN
	                      vwCashFlowNITotals ON tbCashPeriod.StartOn = vwCashFlowNITotals.StartOn
	WHERE     (tbCashPeriod.CashCode = dbo.fnSystemCashCode(3))
	                      
	
	RETURN 
GO
DROP PROCEDURE [dbo].[spStatementRescheduleOverdue]
GO
CREATE PROCEDURE [dbo].[spStatementRescheduleOverdue]
AS
	UPDATE tbTask
	SET tbTask.PaymentOn = CASE WHEN dateadd(d, tbOrg.PaymentDays, tbTask.ActionedOn) > getdate() 
		THEN dateadd(d, tbOrg.PaymentDays, tbTask.ActionedOn) 
		ELSE dateadd(d, tbOrg.PaymentDays, getdate()) 
		END 
	FROM         tbTask INNER JOIN
	                      tbOrg ON tbTask.AccountCode = tbOrg.AccountCode INNER JOIN
	                      tbCashCode ON tbTask.CashCode = tbCashCode.CashCode
	WHERE     (tbTask.PaymentOn < GETDATE()) AND (tbTask.TaskStatusCode = 3)
	

	UPDATE tbTask
	SET tbTask.PaymentOn = CASE WHEN dateadd(d, tbOrg.PaymentDays, tbTask.ActionOn) > getdate() 
		THEN dateadd(d, tbOrg.PaymentDays, tbTask.ActionOn) 
		ELSE dateadd(d, tbOrg.PaymentDays, getdate()) 
		END 
	FROM         tbTask INNER JOIN
	                      tbOrg ON tbTask.AccountCode = tbOrg.AccountCode INNER JOIN
	                      tbCashCode ON tbTask.CashCode = tbCashCode.CashCode
	WHERE     (tbTask.PaymentOn < GETDATE()) AND (tbTask.TaskStatusCode < 3)
	
	UPDATE tbInvoice
	SET CollectOn = CASE WHEN dateadd(d, tbOrg.PaymentDays, tbInvoice.InvoicedOn) > getdate() 
		THEN dateadd(d, tbOrg.PaymentDays, tbInvoice.InvoicedOn) 
		ELSE dateadd(d, tbOrg.PaymentDays, getdate()) 
		END
	FROM         tbInvoice INNER JOIN
	                      tbOrg ON tbInvoice.AccountCode = tbOrg.AccountCode
	WHERE     (tbInvoice.InvoiceStatusCode = 2 OR
	                      tbInvoice.InvoiceStatusCode = 3) AND (tbInvoice.CollectOn < GETDATE())
	
	
	RETURN
GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[spStatementRescheduleOverdue]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[spStatementRescheduleOverdue]
GO
CREATE PROCEDURE [dbo].[spStatementRescheduleOverdue]
AS
	UPDATE tbTask
	SET tbTask.PaymentOn = CASE WHEN dateadd(d, tbOrg.PaymentDays, tbTask.ActionedOn) > getdate() 
		THEN dateadd(d, tbOrg.PaymentDays, tbTask.ActionedOn) 
		ELSE dateadd(d, tbOrg.PaymentDays, getdate()) 
		END 
	FROM         tbTask INNER JOIN
	                      tbOrg ON tbTask.AccountCode = tbOrg.AccountCode INNER JOIN
	                      tbCashCode ON tbTask.CashCode = tbCashCode.CashCode
	WHERE     (tbTask.PaymentOn < GETDATE()) AND (tbTask.TaskStatusCode = 3)
	

	UPDATE tbTask
	SET tbTask.PaymentOn = CASE WHEN dateadd(d, tbOrg.PaymentDays, tbTask.ActionOn) > getdate() 
		THEN dateadd(d, tbOrg.PaymentDays, tbTask.ActionOn) 
		ELSE dateadd(d, tbOrg.PaymentDays, getdate()) 
		END 
	FROM         tbTask INNER JOIN
	                      tbOrg ON tbTask.AccountCode = tbOrg.AccountCode INNER JOIN
	                      tbCashCode ON tbTask.CashCode = tbCashCode.CashCode
	WHERE     (tbTask.PaymentOn < GETDATE()) AND (tbTask.TaskStatusCode < 3)
	
	UPDATE tbInvoice
	SET CollectOn = CASE WHEN dateadd(d, tbOrg.PaymentDays, tbInvoice.InvoicedOn) > getdate() 
		THEN dateadd(d, tbOrg.PaymentDays, tbInvoice.InvoicedOn) 
		ELSE dateadd(d, tbOrg.PaymentDays, getdate()) 
		END
	FROM         tbInvoice INNER JOIN
	                      tbOrg ON tbInvoice.AccountCode = tbOrg.AccountCode
	WHERE     (tbInvoice.InvoiceStatusCode = 2 OR
	                      tbInvoice.InvoiceStatusCode = 3) AND (tbInvoice.CollectOn < GETDATE())
	
	
	RETURN
GO
ALTER PROCEDURE [dbo].[spCashCategoryCashCodes]
	(
	@CategoryCode nvarchar(10)
	)
AS
	SELECT     CashCode, CashDescription
	FROM         tbCashCode
	WHERE     (CategoryCode = @CategoryCode) AND (CashCode <> dbo.fnSystemCashCode(2))
	ORDER BY CashDescription
	RETURN 
GO
CREATE OR ALTER PROCEDURE [dbo].[spPaymentDelete]
	(
	@PaymentCode nvarchar(20)
	)
AS
declare @AccountCode nvarchar(10)
declare @CashAccountCode nvarchar(10)

	SELECT  @AccountCode = AccountCode, @CashAccountCode = CashAccountCode
	FROM         tbOrgPayment
	WHERE     (PaymentCode = @PaymentCode)

	DELETE FROM tbOrgPayment
	WHERE     (PaymentCode = @PaymentCode)
	
	exec dbo.spOrgRebuild @AccountCode
	exec dbo.spCashAccountRebuild @CashAccountCode
	

	RETURN 
GO
ALTER  PROCEDURE [dbo].[spPaymentPostMisc]
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
						(InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, Printed)
	SELECT     @InvoiceNumber AS InvoiceNumber, tbOrgPayment.UserId, tbOrgPayment.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, 
	                      4 AS InvoiceStatusCode, tbOrgPayment.PaidOn, CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + tbSystemTaxCode.TaxRate) 
	                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + tbSystemTaxCode.TaxRate) END AS InvoiceValue, 
	                      CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - ROUND((tbOrgPayment.PaidInValue / (1 + tbSystemTaxCode.TaxRate)), 
	                      2) WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - ROUND((tbOrgPayment.PaidOutValue / (1 + tbSystemTaxCode.TaxRate)), 
	                      2) END AS TaxValue, CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + tbSystemTaxCode.TaxRate) 
	                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + tbSystemTaxCode.TaxRate) END AS PaidValue, 
	                      CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - ROUND((tbOrgPayment.PaidInValue / (1 + tbSystemTaxCode.TaxRate)), 
	                      2) WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - ROUND((tbOrgPayment.PaidOutValue / (1 + tbSystemTaxCode.TaxRate)), 
	                      2) END AS PaidTaxValue, 1 AS Printed
	FROM         tbOrgPayment INNER JOIN
	                      tbSystemTaxCode ON tbOrgPayment.TaxCode = tbSystemTaxCode.TaxCode
	WHERE     (tbOrgPayment.PaymentCode = @PaymentCode)

	INSERT INTO tbInvoiceItem
						(InvoiceNumber, CashCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, TaxCode)
	SELECT     @InvoiceNumber AS InvoiceNumber, tbOrgPayment.CashCode, 
	                      CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + tbSystemTaxCode.TaxRate) 
	                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + tbSystemTaxCode.TaxRate) END AS InvoiceValue, 
	                      CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - ROUND((tbOrgPayment.PaidInValue / (1 + tbSystemTaxCode.TaxRate)), 
	                      2) WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - ROUND((tbOrgPayment.PaidOutValue / (1 + tbSystemTaxCode.TaxRate)), 
	                      2) END AS TaxValue, CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + tbSystemTaxCode.TaxRate) 
	                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + tbSystemTaxCode.TaxRate) END AS PaidValue, 
	                      CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - ROUND((tbOrgPayment.PaidInValue / (1 + tbSystemTaxCode.TaxRate)), 
	                      2) WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - ROUND((tbOrgPayment.PaidOutValue / (1 + tbSystemTaxCode.TaxRate)), 
	                      2) END AS PaidTaxValue, tbOrgPayment.TaxCode
	FROM         tbOrgPayment INNER JOIN
	                      tbSystemTaxCode ON tbOrgPayment.TaxCode = tbSystemTaxCode.TaxCode
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
	                      tbSystemTaxCode ON tbOrgPayment.TaxCode = tbSystemTaxCode.TaxCode
	WHERE     (PaymentCode = @PaymentCode)
	
	RETURN
GO
ALTER PROCEDURE [dbo].[spPaymentPostPaidIn]
	(
	@PaymentCode nvarchar(20),
	@CurrentBalance money output 
	)
AS
--invoice values
declare @InvoiceNumber nvarchar(20)
declare @TaskCode nvarchar(20)
declare @TaxRate real
declare @ItemValue money

--calc values
declare @PaidValue money
declare @PaidTaxValue money

--default payment codes
declare @CashCode nvarchar(50)
declare @TaxCode nvarchar(10)
declare @TaxInValue money
declare @TaxOutValue money

	set @TaxInValue = 0
	set @TaxOutValue = 0
	
	declare curPaidIn cursor local for
		SELECT     vwInvoiceOutstanding.InvoiceNumber, vwInvoiceOutstanding.TaskCode, vwInvoiceOutstanding.CashCode, vwInvoiceOutstanding.TaxCode, 
		                      vwInvoiceOutstanding.TaxRate, vwInvoiceOutstanding.ItemValue
		FROM         vwInvoiceOutstanding INNER JOIN
		                      tbOrgPayment ON vwInvoiceOutstanding.AccountCode = tbOrgPayment.AccountCode
		WHERE     (tbOrgPayment.PaymentCode = @PaymentCode)
		ORDER BY vwInvoiceOutstanding.CashModeCode, vwInvoiceOutstanding.InvoicedOn

	open curPaidIn
	fetch next from curPaidIn into @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue
	while @@FETCH_STATUS = 0 and @CurrentBalance < 0
		begin
		if (@CurrentBalance + @ItemValue) > 0
			set @ItemValue = @CurrentBalance * -1

		set @PaidValue = Abs(@ItemValue) / (1 + @TaxRate)
		set @PaidTaxValue = Abs(@ItemValue) - ROUND((Abs(@ItemValue) / (1 + @TaxRate)), 2)
				
		set @CurrentBalance = @CurrentBalance + @ItemValue
		
		if isnull(@TaskCode, '''') = ''''
			begin
			UPDATE    tbInvoiceItem
			SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (CashCode = @CashCode)
			end
		else
			begin
			UPDATE   tbInvoiceTask
			SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (TaskCode = @TaskCode)				
			end

		exec dbo.spInvoiceTotal @InvoiceNumber
		        		  
		set @TaxInValue = @TaxInValue + CASE WHEN @ItemValue > 0 THEN @PaidTaxValue ELSE 0 END
		set @TaxOutValue = @TaxOutValue + CASE WHEN @ItemValue < 0 THEN @PaidTaxValue ELSE 0 END	
				
		fetch next from curPaidIn into @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue
		end
	
	close curPaidIn
	deallocate curPaidIn
	
	--output new org current balance
	if @CurrentBalance >= 0
		set @CurrentBalance = 0
	else
		set @CurrentBalance = @CurrentBalance * -1

	
	if isnull(@CashCode, '''') != ''''
		begin
		UPDATE    tbOrgPayment
		SET      PaymentStatusCode = 2, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
			CashCode = isnull(@CashCode, tbOrgPayment.CashCode), 
			TaxCode = isnull(@TaxCode, tbOrgPayment.TaxCode)
		WHERE     (PaymentCode = @PaymentCode)
		end

			
	RETURN
GO
ALTER PROCEDURE [dbo].[spPaymentPostPaidOut]
	(
	@PaymentCode nvarchar(20),
	@CurrentBalance money output 
	)
AS
--invoice values
declare @InvoiceNumber nvarchar(20)
declare @TaskCode nvarchar(20)
declare @TaxRate real
declare @ItemValue money

--calc values
declare @PaidValue money
declare @PaidTaxValue money

--default payment codes
declare @CashCode nvarchar(50)
declare @TaxCode nvarchar(10)
declare @TaxInValue money
declare @TaxOutValue money

	set @TaxInValue = 0
	set @TaxOutValue = 0
	
	declare curPaidOut cursor local for
		SELECT     vwInvoiceOutstanding.InvoiceNumber, vwInvoiceOutstanding.TaskCode, vwInvoiceOutstanding.CashCode, vwInvoiceOutstanding.TaxCode, 
		                      vwInvoiceOutstanding.TaxRate, vwInvoiceOutstanding.ItemValue
		FROM         vwInvoiceOutstanding INNER JOIN
		                      tbOrgPayment ON vwInvoiceOutstanding.AccountCode = tbOrgPayment.AccountCode
		WHERE     (tbOrgPayment.PaymentCode = @PaymentCode)
		ORDER BY vwInvoiceOutstanding.CashModeCode DESC, vwInvoiceOutstanding.InvoicedOn

	open curPaidOut
	fetch next from curPaidOut into @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue
	while @@FETCH_STATUS = 0 and @CurrentBalance > 0
		begin
		if (@CurrentBalance + @ItemValue) < 0
			set @ItemValue = @CurrentBalance * -1

		set @PaidValue = Abs(@ItemValue) / (1 + @TaxRate)
		set @PaidTaxValue = Abs(@ItemValue) - ROUND((Abs(@ItemValue) / (1 + @TaxRate)), 2)
				
		set @CurrentBalance = @CurrentBalance + @ItemValue
		
		if isnull(@TaskCode, '''') = ''''
			begin
			UPDATE    tbInvoiceItem
			SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (CashCode = @CashCode)
			end
		else
			begin
			UPDATE   tbInvoiceTask
			SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (TaskCode = @TaskCode)				
			end

		exec dbo.spInvoiceTotal @InvoiceNumber
		        		  
		set @TaxInValue = @TaxInValue + CASE WHEN @ItemValue > 0 THEN @PaidTaxValue ELSE 0 END
		set @TaxOutValue = @TaxOutValue + CASE WHEN @ItemValue < 0 THEN @PaidTaxValue ELSE 0 END	
				
		fetch next from curPaidOut into @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue
		end
		
	close curPaidOut
	deallocate curPaidOut
	
	--output new org current balance
	if @CurrentBalance <= 0
		set @CurrentBalance = 0
	else
		set @CurrentBalance = @CurrentBalance * -1

	if isnull(@CashCode, '''') != ''''
		begin
		UPDATE    tbOrgPayment
		SET      PaymentStatusCode = 2, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
			CashCode = isnull(@CashCode, tbOrgPayment.CashCode), 
			TaxCode = isnull(@TaxCode, tbOrgPayment.TaxCode)
		WHERE     (PaymentCode = @PaymentCode)
		end
	
	RETURN
GO
ALTER PROCEDURE [dbo].[spOrgRebuild]
	(
		@AccountCode nvarchar(10)
	)
AS
declare @PaidBalance money
declare @InvoicedBalance money
declare @Balance money
	
	
declare @CashModeCode smallint	

declare @InvoiceNumber nvarchar(20)
declare @TaskCode nvarchar(20)
declare @CashCode nvarchar(50)
declare @InvoiceValue money
declare @TaxValue money	

declare @PaidValue money
declare @PaidInvoiceValue money
declare @PaidTaxValue money
declare @TaxRate float	

	begin tran OrgRebuild
		
	update tbInvoiceItem
	set TaxValue = ROUND(tbInvoiceItem.InvoiceValue * tbSystemTaxCode.TaxRate, 2),
		PaidValue = tbInvoiceItem.InvoiceValue, 
		PaidTaxValue = ROUND(tbInvoiceItem.InvoiceValue * tbSystemTaxCode.TaxRate, 2)				
	FROM         tbInvoiceItem INNER JOIN
	                      tbSystemTaxCode ON tbInvoiceItem.TaxCode = tbSystemTaxCode.TaxCode INNER JOIN
	                      tbInvoice ON tbInvoiceItem.InvoiceNumber = tbInvoice.InvoiceNumber
	WHERE     (tbInvoice.AccountCode = @AccountCode) AND (tbInvoice.InvoiceStatusCode <> 1)	
                      
	update tbInvoiceTask
	set TaxValue = ROUND(tbInvoiceTask.InvoiceValue * tbSystemTaxCode.TaxRate, 2),
		PaidValue = tbInvoiceTask.InvoiceValue, PaidTaxValue = ROUND(tbInvoiceTask.InvoiceValue * tbSystemTaxCode.TaxRate, 2)
	FROM         tbInvoiceTask INNER JOIN
	                      tbSystemTaxCode ON tbInvoiceTask.TaxCode = tbSystemTaxCode.TaxCode INNER JOIN
	                      tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber
	WHERE     (tbInvoice.AccountCode = @AccountCode) AND (tbInvoice.InvoiceStatusCode <> 1)	
	
	UPDATE tbInvoice
	SET InvoiceValue = 0, TaxValue = 0
	WHERE tbInvoice.AccountCode = @AccountCode
	
	UPDATE tbInvoice
	SET InvoiceValue = fnOrgRebuildInvoiceItems.TotalInvoiceValue, 
		TaxValue = fnOrgRebuildInvoiceItems.TotalTaxValue
	FROM         tbInvoice INNER JOIN
	                      fnOrgRebuildInvoiceItems(@AccountCode) fnOrgRebuildInvoiceItems 
	                      ON tbInvoice.InvoiceNumber = fnOrgRebuildInvoiceItems.InvoiceNumber	
	
	UPDATE tbInvoice
	SET InvoiceValue = InvoiceValue + fnOrgRebuildInvoiceTasks.TotalInvoiceValue, 
		TaxValue = TaxValue + fnOrgRebuildInvoiceTasks.TotalTaxValue
	FROM         tbInvoice INNER JOIN
	                      fnOrgRebuildInvoiceTasks(@AccountCode) fnOrgRebuildInvoiceTasks 
	                      ON tbInvoice.InvoiceNumber = fnOrgRebuildInvoiceTasks.InvoiceNumber
			
	UPDATE    tbInvoice
	SET              PaidValue = InvoiceValue, PaidTaxValue = TaxValue, InvoiceStatusCode = 4
	WHERE     (AccountCode = @AccountCode) AND (InvoiceStatusCode <> 1)		

	
	UPDATE tbOrgPayment
	SET
		TaxInValue = PaidInValue - ROUND((PaidInValue / (1 + TaxRate)), 2), 
		TaxOutValue = PaidOutValue - ROUND((PaidOutValue / (1 + TaxRate)), 2)
	FROM         tbOrgPayment INNER JOIN
	                      tbSystemTaxCode ON tbOrgPayment.TaxCode = tbSystemTaxCode.TaxCode
	WHERE     (tbOrgPayment.AccountCode = @AccountCode)
		

	SELECT  @PaidBalance = SUM(CASE WHEN PaidInValue > 0 THEN PaidInValue * -1 ELSE PaidOutValue  END)
	FROM         tbOrgPayment
	WHERE     (AccountCode = @AccountCode) And (PaymentStatusCode <> 1)
	
	SELECT @PaidBalance = isnull(@PaidBalance, 0) + OpeningBalance
	FROM tbOrg
	WHERE     (AccountCode = @AccountCode)

	SELECT @InvoicedBalance = SUM(CASE tbInvoiceType.CashModeCode WHEN 1 THEN (InvoiceValue + TaxValue) * - 1 WHEN 2 THEN InvoiceValue + TaxValue ELSE 0 END) 
	FROM         tbInvoice INNER JOIN
	                      tbInvoiceType ON tbInvoice.InvoiceTypeCode = tbInvoiceType.InvoiceTypeCode
	WHERE     (tbInvoice.AccountCode = @AccountCode)
	
	set @Balance = isnull(@PaidBalance, 0) + isnull(@InvoicedBalance, 0)
                      
    set @CashModeCode = CASE WHEN @Balance > 0 THEN 2 ELSE 1 END
	set @Balance = Abs(@Balance)	

	declare curInv cursor local for
		SELECT     InvoiceNumber, TaskCode, CashCode, InvoiceValue, TaxValue
		FROM  vwOrgRebuildInvoices
		WHERE     (AccountCode = @AccountCode) And (CashModeCode = @CashModeCode)
		ORDER BY InvoicedOn DESC
	

	open curInv
	fetch next from curInv into @InvoiceNumber, @TaskCode, @CashCode, @InvoiceValue, @TaxValue
	while @@FETCH_STATUS = 0 And (@Balance > 0)
		begin

		if (@Balance - (@InvoiceValue + @TaxValue)) < 0
			begin
			set @PaidValue = (@InvoiceValue + @TaxValue) - @Balance
			set @Balance = 0	
			end
		else
			begin
			set @PaidValue = 0
			set @Balance = @Balance - (@InvoiceValue + @TaxValue)
			end
		
		if @PaidValue > 0
			begin
			set @TaxRate = @TaxValue / @InvoiceValue
			set @PaidInvoiceValue = @PaidValue - (@PaidValue - ROUND((@PaidValue / (1 + @TaxRate)), 2))
			set @PaidTaxValue = ROUND(@PaidInvoiceValue * @TaxRate, 2)
			end
		else
			begin
			set @PaidInvoiceValue = 0
			set @PaidTaxValue = 0
			end
			
		if isnull(@TaskCode, '''') = ''''
			begin
			UPDATE    tbInvoiceItem
			SET              PaidValue = @PaidInvoiceValue, PaidTaxValue = @PaidTaxValue
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (CashCode = @CashCode)
			end
		else
			begin
			UPDATE   tbInvoiceTask
			SET              PaidValue = @PaidInvoiceValue, PaidTaxValue = @PaidTaxValue
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (TaskCode = @TaskCode)				
			end

		fetch next from curInv into @InvoiceNumber, @TaskCode, @CashCode, @InvoiceValue, @TaxValue
		end
	
	close curInv
	deallocate curInv
	
	UPDATE tbInvoice
	SET InvoiceStatusCode = 3,
		PaidValue = vwOrgRebuildInvoiceTotals.TotalPaidValue, 
		PaidTaxValue = vwOrgRebuildInvoiceTotals.TotalPaidTaxValue
	FROM         tbInvoice INNER JOIN
						vwOrgRebuildInvoiceTotals ON tbInvoice.InvoiceNumber = vwOrgRebuildInvoiceTotals.InvoiceNumber
	WHERE     (vwOrgRebuildInvoiceTotals.AccountCode = @AccountCode) AND 
						((vwOrgRebuildInvoiceTotals.TotalInvoiceValue + vwOrgRebuildInvoiceTotals.TotalTaxValue) 
						- (vwOrgRebuildInvoiceTotals.TotalPaidValue + vwOrgRebuildInvoiceTotals.TotalPaidTaxValue) > 0) AND 
						(vwOrgRebuildInvoiceTotals.TotalPaidValue + vwOrgRebuildInvoiceTotals.TotalPaidTaxValue < vwOrgRebuildInvoiceTotals.TotalInvoiceValue + vwOrgRebuildInvoiceTotals.TotalTaxValue)
	
	UPDATE tbInvoice
	SET InvoiceStatusCode = 2,
		PaidValue = 0, 
		PaidTaxValue = 0
	FROM         tbInvoice INNER JOIN
	                      vwOrgRebuildInvoiceTotals ON tbInvoice.InvoiceNumber = vwOrgRebuildInvoiceTotals.InvoiceNumber
	WHERE     (vwOrgRebuildInvoiceTotals.AccountCode = @AccountCode) AND 
	                      (vwOrgRebuildInvoiceTotals.TotalPaidValue + vwOrgRebuildInvoiceTotals.TotalPaidTaxValue = 0) AND 
	                      (vwOrgRebuildInvoiceTotals.TotalInvoiceValue + vwOrgRebuildInvoiceTotals.TotalTaxValue > 0)
	
	
	if (@CashModeCode = 2)
		set @Balance = @Balance * -1
		
	UPDATE    tbOrg
	SET              CurrentBalance = OpeningBalance - @Balance
	WHERE     (AccountCode = @AccountCode)
	
	commit tran OrgRebuild
	

	RETURN 
GO
ALTER  VIEW dbo.vwInvoiceVatTasks
AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoiceTask.InvoiceNumber, dbo.tbInvoice.InvoiceTypeCode, 
                      dbo.tbInvoiceTask.TaxCode, dbo.tbInvoiceTask.InvoiceValue, dbo.tbInvoiceTask.TaxValue, dbo.tbOrg.ForeignJurisdiction
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbInvoiceTask.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 2)
GO
ALTER  VIEW dbo.vwInvoiceVatItems
AS
SELECT     TOP 100 PERCENT dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoice.InvoiceNumber, dbo.tbInvoice.InvoiceTypeCode, 
                      dbo.tbInvoiceItem.TaxCode, dbo.tbInvoiceItem.InvoiceValue, dbo.tbInvoiceItem.TaxValue, dbo.tbOrg.ForeignJurisdiction
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbInvoiceItem.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 2)
ORDER BY dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn)
GO
ALTER  VIEW dbo.vwInvoiceVatBase
AS
SELECT DISTINCT StartOn, InvoiceNumber, InvoiceTypeCode, TaxCode, InvoiceValue, TaxValue, ForeignJurisdiction
FROM         dbo.vwInvoiceVatItems
UNION
SELECT DISTINCT StartOn, InvoiceNumber, InvoiceTypeCode, TaxCode, InvoiceValue, TaxValue, ForeignJurisdiction
FROM         dbo.vwInvoiceVatTasks
GO
ALTER  FUNCTION dbo.fnTaxTypeDueDates
	(@TaxTypeCode smallint)
RETURNS @tbDueDate TABLE (PayOn datetime, PayFrom datetime, PayTo datetime)
AS
	BEGIN
	declare @MonthNumber smallint
	declare @RecurrenceCode smallint
	declare @MonthInterval smallint
	declare @StartOn datetime
	
	select @MonthNumber = MonthNumber, @RecurrenceCode = RecurrenceCode
	from tbCashTaxType
	where TaxTypeCode = @TaxTypeCode
	
	set @MonthInterval = case @RecurrenceCode
		when 1 then 1
		when 2 then 1
		when 3 then 3
		when 4 then 6
		when 5 then 12
		end
				
	SELECT   @StartOn = MIN(StartOn)
	FROM         tbSystemYearPeriod
	WHERE     (MonthNumber = @MonthNumber)
	ORDER BY MIN(StartOn)
	
	insert into @tbDueDate (PayOn) values (@StartOn)
	
	set @MonthNumber = case 
		when (@MonthNumber + @MonthInterval) <= 12 then @MonthNumber + @MonthInterval
		else (@MonthNumber + @MonthInterval) % 12
		end
	
	while exists(SELECT     MonthNumber
	             FROM         tbSystemYearPeriod
	             WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber))
		begin
		SELECT @StartOn = MIN(StartOn)
	    FROM         tbSystemYearPeriod
	    WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber)
		ORDER BY MIN(StartOn)		
		insert into @tbDueDate (PayOn) values (@StartOn)
		
		set @MonthNumber = case 
			when (@MonthNumber + @MonthInterval) <= 12 then @MonthNumber + @MonthInterval
			else (@MonthNumber + @MonthInterval) % 12
			end
		
		end
	
	-- Set PayTo
	declare @PayOn datetime
	declare @PayFrom datetime
		
	if (@TaxTypeCode = 1)
		goto CorporationTax
	else
		goto VatTax
		
	return
	
CorporationTax:

	SELECT @StartOn = MIN(StartOn)
	FROM tbSystemYearPeriod
	ORDER BY MIN(StartOn)
	
	set @PayFrom = @StartOn
	
	SELECT @MonthNumber = MonthNumber
	FROM         tbSystemYearPeriod
	WHERE StartOn = @StartOn

	set @MonthNumber = case 
		when (@MonthNumber + @MonthInterval) <= 12 then @MonthNumber + @MonthInterval
		else (@MonthNumber + @MonthInterval) % 12
		end
	
	while exists(SELECT     MonthNumber
	             FROM         tbSystemYearPeriod
	             WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber))
		begin
		SELECT @StartOn = MIN(StartOn)
	    FROM         tbSystemYearPeriod
	    WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber)
		ORDER BY MIN(StartOn)		
		
		select @PayOn = MIN(PayOn)
		from @tbDueDate
		where PayOn >= @StartOn
		order by min(PayOn)
		
		update @tbDueDate
		set PayTo = @StartOn, PayFrom = @PayFrom
		where PayOn = @PayOn
		
		set @PayFrom = @StartOn
		
		set @MonthNumber = case 
			when (@MonthNumber + @MonthInterval) <= 12 then @MonthNumber + @MonthInterval
			else (@MonthNumber + @MonthInterval) % 12
			end
		
		end

	delete from @tbDueDate where PayTo is null
	
	RETURN

VatTax:

	declare curTemp cursor for
		select PayOn from @tbDueDate
		order by PayOn

	open curTemp
	fetch next from curTemp into @PayOn	
	while @@FETCH_STATUS = 0
		begin
		update @tbDueDate
		set 
			PayFrom = dateadd(m, @MonthInterval * -1, @PayOn),
			PayTo = @PayOn
		where PayOn = @PayOn

		fetch next from curTemp into @PayOn	
		end

	close curTemp
	deallocate curTemp
	
	RETURN
	
	END
GO
ALTER VIEW dbo.vwTaxCorpTotals
AS
SELECT     dbo.tbSystemYear.[Description], dbo.tbSystemMonth.MonthName, dbo.vwCorpTaxInvoice.StartOn, SUM(dbo.vwCorpTaxInvoice.NetProfit) AS NetProfit, 
                      SUM(dbo.vwCorpTaxInvoice.CorporationTax) AS CorporationTax
FROM         dbo.vwCorpTaxInvoice INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.vwCorpTaxInvoice.StartOn = dbo.tbSystemYearPeriod.StartOn INNER JOIN
                      dbo.tbSystemYear ON dbo.tbSystemYearPeriod.YearNumber = dbo.tbSystemYear.YearNumber INNER JOIN
                      dbo.tbSystemMonth ON dbo.tbSystemYearPeriod.MonthNumber = dbo.tbSystemMonth.MonthNumber
GROUP BY dbo.tbSystemYear.[Description], dbo.tbSystemMonth.MonthName, dbo.vwCorpTaxInvoice.StartOn
GO
