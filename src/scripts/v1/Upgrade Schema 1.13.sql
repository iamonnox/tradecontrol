/************************************************************
* Tru-Man Trade Control: Management Information and Cash System
* Copyright Tru-Man Industries Ltd 2010. All Rights Reserved.
* Author: Ian Monnox
* Description: Sql Server Upgrade Script - Encrypted Distribution Schema
* Data Version: 1.13
* Release Date: 28 May 2010
************************************************************/

CREATE OR ALTER VIEW dbo.vwCorpTaxInvoiceValue
AS
SELECT     StartOn, SUM(InvoiceValue) AS NetProfit
FROM         dbo.vwCorpTaxInvoiceItems
GROUP BY StartOn
UNION
SELECT     StartOn, SUM(InvoiceValue) AS NetProfit
FROM         dbo.vwCorpTaxInvoiceTasks
GROUP BY StartOn
GO
CREATE OR ALTER VIEW [dbo].[vwCorpTaxInvoiceBase]
AS
SELECT     StartOn, SUM(NetProfit) AS NetProfit
FROM         dbo.vwCorpTaxInvoiceValue
GROUP BY StartOn
GO
ALTER TABLE [dbo].[tbSystemYearPeriod] WITH NOCHECK ADD
	[VatAdjustment] [money] NOT NULL CONSTRAINT [DF_tbSystemYearPeriod_VatAdjustment]  DEFAULT ((0))
GO
ALTER VIEW [dbo].[vwInvoiceVatSummary]
AS
SELECT     StartOn, TaxCode, SUM(HomeSales) AS HomeSales, SUM(HomePurchases) AS HomePurchases, SUM(ExportSales) AS ExportSales, 
                      SUM(ExportPurchases) AS ExportPurchases, SUM(HomeSalesVat) AS HomeSalesVat, SUM(HomePurchasesVat) AS HomePurchasesVat, 
                      SUM(ExportSalesVat) AS ExportSalesVat, SUM(ExportPurchasesVat) AS ExportPurchasesVat
FROM         dbo.vwInvoiceVatDetail
GROUP BY StartOn, TaxCode
GO
ALTER FUNCTION dbo.fnTaxVatTotals
	()
RETURNS @tbVat TABLE 
	(
	StartOn datetime, 
	HomeSales money,
	HomePurchases money,
	ExportSales money,
	ExportPurchases money,
	HomeSalesVat money,
	HomePurchasesVat money,
	ExportSalesVat money,
	ExportPurchasesVat money,
	VatAdjustment money,
	VatDue money
	)
  AS
	BEGIN
	declare @PayOn datetime
	declare @PayFrom datetime
	declare @PayTo datetime
	
	declare curVat cursor local for
		SELECT     PayOn, PayFrom, PayTo
		FROM         fnTaxTypeDueDates(2) fnTaxTypeDueDates
		
	open curVat
	fetch next from curVat into @PayOn, @PayFrom, @PayTo
	while (@@FETCH_STATUS = 0)
		begin
		INSERT INTO @tbVat (StartOn, HomeSales, HomePurchases, ExportSales, ExportPurchases, HomeSalesVat, HomePurchasesVat, ExportSalesVat, ExportPurchasesVat)
		SELECT     @PayOn AS PayOn, ISNULL(SUM(HomeSales), 0) AS HomeSales, ISNULL(SUM(HomePurchases), 0) AS HomePurchases, ISNULL(SUM(ExportSales), 0) AS ExportSales, 
		                      ISNULL(SUM(ExportPurchases), 0) AS ExportPurchases, ISNULL(SUM(HomeSalesVat), 0) AS HomeSalesVat, ISNULL(SUM(HomePurchasesVat), 0) AS HomePurchasesVat, 
		                      ISNULL(SUM(ExportSalesVat), 0) AS ExportSalesVat, ISNULL(SUM(ExportPurchasesVat), 0) AS ExportPurchasesVat
		FROM         vwInvoiceVatSummary
		WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
		
		fetch next from curVat into @PayOn, @PayFrom, @PayTo
		end
	
	close curVat
	deallocate curVat

	UPDATE @tbVat
	SET VatAdjustment = tbSystemYearPeriod.VatAdjustment
	FROM @tbVat AS tb INNER JOIN
	                      tbSystemYearPeriod ON tb.StartOn = tbSystemYearPeriod.StartOn
	
	update @tbVat
	set VatDue = (HomeSalesVat + ExportSalesVat) - (HomePurchasesVat + ExportPurchasesVat) + VatAdjustment
	
	RETURN
	END
GO
ALTER VIEW [dbo].[vwTaxVatTotals]
AS
SELECT     TOP 100 PERCENT dbo.tbSystemYear.YearNumber, dbo.tbSystemYear.Description, dbo.tbSystemMonth.MonthName, fnTaxVatTotals.StartOn, 
                      fnTaxVatTotals.HomeSales, fnTaxVatTotals.HomePurchases, fnTaxVatTotals.ExportSales, fnTaxVatTotals.ExportPurchases, 
                      fnTaxVatTotals.HomeSalesVat, fnTaxVatTotals.HomePurchasesVat, fnTaxVatTotals.ExportSalesVat, fnTaxVatTotals.ExportPurchasesVat, 
                      fnTaxVatTotals.VatAdjustment, fnTaxVatTotals.VatDue
FROM         dbo.fnTaxVatTotals() AS fnTaxVatTotals INNER JOIN
                      dbo.tbSystemYearPeriod ON fnTaxVatTotals.StartOn = dbo.tbSystemYearPeriod.StartOn INNER JOIN
                      dbo.tbSystemMonth ON dbo.tbSystemYearPeriod.MonthNumber = dbo.tbSystemMonth.MonthNumber INNER JOIN
                      dbo.tbSystemYear ON dbo.tbSystemYearPeriod.YearNumber = dbo.tbSystemYear.YearNumber
ORDER BY fnTaxVatTotals.StartOn
GO
ALTER  FUNCTION [dbo].[fnSystemVatBalance]
	()
RETURNS money
AS
	BEGIN
	declare @Balance money
	SELECT  @Balance = SUM(HomeSalesVat - HomePurchasesVat + ExportSalesVat - ExportPurchasesVat)
	FROM         vwInvoiceVatSummary
	
	SELECT  @Balance = @Balance + ISNULL(SUM(tbOrgPayment.PaidInValue - tbOrgPayment.PaidOutValue), 0)
	FROM         tbOrgPayment INNER JOIN
	                      vwSystemVatCashCode ON tbOrgPayment.CashCode = vwSystemVatCashCode.CashCode	                      

	SELECT @Balance = @Balance + SUM(VatAdjustment)
	FROM tbSystemYearPeriod

	RETURN isnull(@Balance, 0)
	END
GO
ALTER PROCEDURE [dbo].[spTaskCopy]
	(
	@FromTaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20) = null,
	@ToTaskCode nvarchar(20) = null output
	)
AS
declare @ActivityCode nvarchar(50)
declare @Printed bit
declare @ChildTaskCode nvarchar(20)
declare @TaskStatusCode smallint
declare @StepNumber smallint

	SELECT  @TaskStatusCode = tbActivity.TaskStatusCode, @ActivityCode = tbTask.ActivityCode, @Printed = CASE WHEN tbActivity.PrintOrder = 0 THEN 1 ELSE 0 END
	FROM         tbTask INNER JOIN
	                      tbActivity ON tbTask.ActivityCode = tbActivity.ActivityCode
	WHERE     (tbTask.TaskCode = @FromTaskCode)
	
	exec dbo.spTaskNextCode @ActivityCode, @ToTaskCode output

	INSERT INTO tbTask
						  (TaskCode, UserId, AccountCode, TaskTitle, ContactName, ActivityCode, TaskStatusCode, ActionById, ActionOn, TaskNotes, Quantity, SecondReference, 
						  CashCode, TaxCode, UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, PaymentOn, Printed)
	SELECT     @ToTaskCode AS ToTaskCode, UserId, AccountCode, TaskTitle, ContactName, ActivityCode, @TaskStatusCode AS TaskStatus, ActionById, 
						  CONVERT(datetime, CONVERT(varchar, GETDATE(), 1), 1) AS ActionOn, TaskNotes, Quantity, SecondReference, CashCode, TaxCode, UnitCharge, 
						  TotalCharge, AddressCodeFrom, AddressCodeTo, dbo.fnTaskDefaultPaymentOn(AccountCode, CONVERT(datetime, CONVERT(varchar, GETDATE(), 1), 1)), @Printed AS Printed
	FROM         tbTask AS tbTask_1
	WHERE     (TaskCode = @FromTaskCode)
	
	INSERT INTO tbTaskAttribute
	                      (TaskCode, Attribute, PrintOrder, AttributeTypeCode, AttributeDescription)
	SELECT     @ToTaskCode AS ToTaskCode, Attribute, PrintOrder, AttributeTypeCode, AttributeDescription
	FROM         tbTaskAttribute AS tbTaskAttribute_1
	WHERE     (TaskCode = @FromTaskCode)
	
	INSERT INTO tbTaskQuote
	                      (TaskCode, Quantity, TotalPrice, RunOnQuantity, RunOnPrice, RunBackQuantity, RunBackPrice)
	SELECT     @ToTaskCode AS ToTaskCode, Quantity, TotalPrice, RunOnQuantity, RunOnPrice, RunBackQuantity, RunBackPrice
	FROM         tbTaskQuote AS tbTaskQuote_1
	WHERE     (TaskCode = @FromTaskCode)
	
	INSERT INTO tbTaskOp
						  (TaskCode, OperationNumber, OpStatusCode, UserId, OpTypeCode, Operation, Note, StartOn, EndOn, Duration, OffsetDays)
	SELECT     @ToTaskCode AS ToTaskCode, OperationNumber, 1 AS OpStatus, UserId, OpTypeCode, Operation, Note, CONVERT(datetime, CONVERT(varchar, 
						  GETDATE(), 1), 1) AS StartOn, CONVERT(datetime, CONVERT(varchar, GETDATE(), 1), 1) AS EndOn, Duration, OffsetDays
	FROM         tbTaskOp AS tbTaskOp_1
	WHERE     (TaskCode = @FromTaskCode)
	
	IF (ISNULL(@ParentTaskCode, '') = '')
		BEGIN
		IF EXISTS(SELECT     ParentTaskCode
				FROM         tbTaskFlow
				WHERE     (ChildTaskCode = @FromTaskCode))
			BEGIN
			SELECT @ParentTaskCode = ParentTaskCode
			FROM         tbTaskFlow
			WHERE     (ChildTaskCode = @FromTaskCode)

			SELECT @StepNumber = MAX(StepNumber)
			FROM         tbTaskFlow
			WHERE     (ParentTaskCode = @ParentTaskCode)
			GROUP BY ParentTaskCode
				
			SET @StepNumber = @StepNumber - (@StepNumber % 10) + 10	
						
			INSERT INTO tbTaskFlow
			(ParentTaskCode, StepNumber, ChildTaskCode, UsedOnQuantity, OffsetDays)
			SELECT TOP 1 ParentTaskCode, @StepNumber AS Step, @ToTaskCode AS ChildTask, UsedOnQuantity, OffsetDays
			FROM         tbTaskFlow
			WHERE     (ChildTaskCode = @FromTaskCode)
			END
		END
	ELSE
		BEGIN
		
		INSERT INTO tbTaskFlow
		(ParentTaskCode, StepNumber, ChildTaskCode, UsedOnQuantity, OffsetDays)
		SELECT TOP 1 @ParentTaskCode As ParentTask, StepNumber, @ToTaskCode AS ChildTask, UsedOnQuantity, OffsetDays
		FROM         tbTaskFlow AS tbTaskFlow_1
		WHERE     (ChildTaskCode = @FromTaskCode)		
		END
	
	declare curTask cursor local for			
		SELECT     ChildTaskCode
		FROM         tbTaskFlow
		WHERE     (ParentTaskCode = @FromTaskCode)
	
	open curTask
	
	fetch next from curTask into @ChildTaskCode
	while (@@FETCH_STATUS = 0)
		begin
		exec dbo.spTaskCopy @ChildTaskCode, @ToTaskCode
		fetch next from curTask into @ChildTaskCode
		end
		
	close curTask
	deallocate curTask
		
	RETURN
GO
UPDATE tbProfileMenuEntry
SET ItemText = 'Nominal Accounts'
WHERE EntryId = 17 or EntryId = 18

UPDATE tbProfileMenuEntry
SET ItemText = 'Nominal Forecast', Argument = 'NominalForecast'
WHERE EntryId = 19

UPDATE tbProfileMenuEntry
SET ItemText = 'Nominal Entry', Argument = 'NominalEntry'
WHERE EntryId = 22
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
						
		fetch next from curVat into @PayOn, @PayFrom, @PayTo
		end
	
	close curVat
	deallocate curVat

	
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
		
		fetch next from curVat into @PayOn, @PayFrom, @PayTo
		end
	
	close curVat
	deallocate curVat

	
	RETURN
	END
GO
ALTER FUNCTION [dbo].[fnStatementCompany]
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
	WHERE     ((tbInvoiceItem.InvoiceValue + tbInvoiceItem.TaxValue) - (tbInvoiceItem.PaidValue + tbInvoiceItem.PaidTaxValue) > 0)
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
	WHERE     ((tbInvoiceTask.InvoiceValue + tbInvoiceTask.TaxValue) - (tbInvoiceTask.PaidValue + tbInvoiceTask.PaidTaxValue) > 0)
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


	SET @AccountCode = dbo.fnStatementTaxAccount(2)
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	SELECT     @ReferenceCode AS ReferenceCode, @AccountCode AS AccountCode, dbo.fnTaskDefaultPaymentOn(@AccountCode, StartOn), 6 AS Expr1, PayIn, PayOut, dbo.fnSystemCashCode(2)
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
	WHERE     (tbCashPeriod.StartOn >= @StartOn)
	
	UPDATE tbCashPeriod
	SET 
		ForecastValue = vwCashCodeForecastSummary.ForecastValue, 
		ForecastTax = vwCashCodeForecastSummary.ForecastTax
	FROM         tbCashPeriod INNER JOIN
	                      vwCashCodeForecastSummary ON tbCashPeriod.CashCode = vwCashCodeForecastSummary.CashCode AND 
	                      tbCashPeriod.StartOn = vwCashCodeForecastSummary.StartOn INNER JOIN
	                      tbCashCode ON tbCashPeriod.CashCode = tbCashCode.CashCode INNER JOIN
	                      tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE     (tbCashPeriod.StartOn >= @StartOn)
	
	
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
ALTER TABLE [tbCashCategory]
	DROP CONSTRAINT [DF_tbCashCategory_ManualForecast],
	COLUMN ManualForecast
GO
DROP VIEW [dbo].[vwStatementForecasts]
GO
DROP VIEW [dbo].[vwCorpTaxManualForecasts]
GO
DROP VIEW [dbo].[vwTaxVatManualForecasts]
GO
INSERT INTO tbTaskStatus
(TaskStatusCode, TaskStatus)
VALUES (6, 'Archive')
GO
ALTER TRIGGER Trigger_tbTask_Update
ON dbo.tbTask 
FOR UPDATE
AS
	IF UPDATE (ContactName)
		begin
		if exists (SELECT     ContactName
		           FROM         inserted AS i
		           WHERE     (NOT (ContactName IS NULL)) AND
		                                 (ContactName <> N''))
			begin
			if not exists(SELECT     tbOrgContact.ContactName
			              FROM         inserted AS i INNER JOIN
			                                    tbOrgContact ON i.AccountCode = tbOrgContact.AccountCode AND i.ContactName = tbOrgContact.ContactName)
				begin
				declare @FileAs nvarchar(100)
				declare @ContactName nvarchar(100)
				declare @NickName nvarchar(100)
								
				select TOP 1 @ContactName = isnull(ContactName, '') from inserted	 
				
				if len(@ContactName) > 0
					begin
					set @NickName = left(@ContactName, charindex(' ', @ContactName, 1))
					exec dbo.spOrgContactFileAs @ContactName, @FileAs output
					
					INSERT INTO tbOrgContact
										(AccountCode, ContactName, FileAs, NickName)
					SELECT TOP 1 AccountCode, ContactName, @FileAs AS FileAs, @NickName as NickName
					FROM  inserted
					end
				end                                   
			end		
		
		
		end

	declare @TaskCode nvarchar(20)

	IF UPDATE (TaskStatusCode)
		begin
		declare @TaskStatusCode smallint
		select @TaskCode = TaskCode, @TaskStatusCode = TaskStatusCode from inserted
		if @TaskStatusCode <> 4
			exec dbo.spTaskSetStatus @TaskCode
		else
			exec dbo.spTaskSetOpStatus @TaskCode, @TaskStatusCode			
		end
		
	
	if UPDATE (ActionOn)
		begin
		declare @ScheduleOps bit		
		SELECT @ScheduleOps = ScheduleOps FROM tbSystemOptions
		IF (@ScheduleOps <> 0)
			BEGIN
			declare @ActionOn datetime
			select @TaskCode = TaskCode, @ActionOn = ActionOn from inserted		
			exec dbo.spTaskScheduleOp @TaskCode, @ActionOn
			END
		end
GO
UPDATE    tbTaskOp
SET              OpStatusCode = 3
FROM         tbTaskOp INNER JOIN
                      tbTask ON tbTaskOp.TaskCode = tbTask.TaskCode
WHERE     (tbTask.TaskStatusCode > 2) AND (tbTaskOp.OpStatusCode < 3)
GO
