/************************************************************
* Tru-Man Trade Control: Information and Cash System
* Copyright Trade Control Ltd 2012. All Rights Reserved.
* Author: Ian Monnox
* Description: Sql Server Upgrade Script - Encrypted Distribution Schema
* Data Version: 2.02
* Release Date: 1.02.12
************************************************************/

DELETE FROM tbProfileText
WHERE TextId = 3008
GO
ALTER PROCEDURE [dbo].[spCashCopyForecastToLiveCashCode]
	(
	@CashCode nvarchar(50),
	@StartOn datetime
	)

AS
	UPDATE tbCashPeriod
	SET     InvoiceValue = ForecastValue, InvoiceTax = ForecastTax
	FROM         tbCashPeriod
	WHERE     (CashCode = @CashCode) AND (StartOn = @StartOn)
	RETURN 
GO
ALTER PROCEDURE dbo.spCashCopyForecastToLiveCategory
	(
	@CategoryCode nvarchar(10),
	@StartOn datetime
	)

AS
	UPDATE tbCashPeriod
	SET     InvoiceValue = ForecastValue, InvoiceTax = ForecastTax
	FROM         tbCashPeriod INNER JOIN
	                      tbCashCode ON tbCashPeriod.CashCode = tbCashCode.CashCode
	WHERE     (tbCashPeriod.StartOn = @StartOn) AND (tbCashCode.CategoryCode = @CategoryCode)
GO
ALTER PROCEDURE dbo.spCashCopyLiveToForecastCashCode
	(
	@CashCode nvarchar(50),
	@Years smallint,
	@UseLastPeriod bit = 0
	)

AS
declare @SystemStartOn datetime
declare @EndPeriod datetime
declare @StartPeriod datetime
declare @CurPeriod datetime
	
declare @InvoiceValue money
declare @InvoiceTax money

	SELECT @CurPeriod = StartOn
	FROM         fnSystemActivePeriod() fnSystemActivePeriod
	
	set @EndPeriod = dateadd(m, -1, @CurPeriod)
	set @StartPeriod = dateadd(m, -11, @EndPeriod)	
	
	SELECT @SystemStartOn = MIN(StartOn)
	FROM         tbSystemYearPeriod
	
	if @StartPeriod < @SystemStartOn 
		set @UseLastPeriod = 1

	if @UseLastPeriod = 0
		goto YearCopyMode
	else
		goto LastMonthCopyMode
		
	return
		
	
YearCopyMode:

	declare curPe cursor for
		SELECT     StartOn, InvoiceValue, InvoiceTax
		FROM         tbCashPeriod
		WHERE     (StartOn <= @EndPeriod AND StartOn >= @StartPeriod) and (CashCode = @CashCode)
		ORDER BY	CashCode, StartOn	
		
	while @Years > 0
		begin
		open curPe

		fetch next from curPe into @StartPeriod, @InvoiceValue, @InvoiceTax
		while @@FETCH_STATUS = 0
			begin				
			UPDATE tbCashPeriod
			SET
				ForecastValue = @InvoiceValue, 
				ForecastTax = @InvoiceTax
			FROM         tbCashPeriod
			WHERE     (CashCode = @CashCode) AND (StartOn = @CurPeriod)

			SELECT TOP 1 @CurPeriod = StartOn
			FROM tbCashPeriod
			WHERE     (CashCode = @CashCode) AND (StartOn > @CurPeriod)
			ORDER BY StartOn	
			fetch next from curPe into @StartPeriod, @InvoiceValue, @InvoiceTax
			end
		
		set @Years = @Years - 1
		close curPe
		end
		
	deallocate curPe
			
	return 

LastMonthCopyMode:
declare @Idx integer

	SELECT TOP 1 @InvoiceValue = InvoiceValue, @InvoiceTax = InvoiceTax
	FROM         tbCashPeriod
	WHERE     (CashCode = @CashCode) AND (StartOn < @CurPeriod)
	ORDER BY StartOn DESC
		
	while @Years > 0
		begin
		set @Idx = 1
		while @Idx <= 12
			begin
			UPDATE tbCashPeriod
			SET
				ForecastValue = @InvoiceValue, 
				ForecastTax = @InvoiceTax
			FROM         tbCashPeriod
			WHERE     (CashCode = @CashCode) AND (StartOn = @CurPeriod)

			SELECT TOP 1 @CurPeriod = StartOn
			FROM tbCashPeriod
			WHERE     (CashCode = @CashCode) AND (StartOn > @CurPeriod)
			ORDER BY StartOn			

			set @Idx = @Idx + 1
			end			
	
		set @Years = @Years - 1
		end


	return
GO
ALTER VIEW dbo.vwCashCodeForecastSummary
AS
SELECT        dbo.tbTask.CashCode, dbo.fnAccountPeriod(dbo.tbTask.ActionOn) AS StartOn, SUM(dbo.tbTask.TotalCharge) AS ForecastValue, 
                         SUM(dbo.tbTask.TotalCharge * ISNULL(dbo.vwSystemTaxRates.TaxRate, 0)) AS ForecastTax
FROM            dbo.tbTask INNER JOIN
                         dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                         dbo.tbInvoiceTask ON dbo.tbTask.TaskCode = dbo.tbInvoiceTask.TaskCode AND dbo.tbTask.TaskCode = dbo.tbInvoiceTask.TaskCode LEFT OUTER JOIN
                         dbo.vwSystemTaxRates ON dbo.tbTask.TaxCode = dbo.vwSystemTaxRates.TaxCode
GROUP BY dbo.tbTask.CashCode, dbo.fnAccountPeriod(dbo.tbTask.ActionOn)
GO
ALTER VIEW dbo.vwCashCodeInvoiceSummary
AS
SELECT     dbo.vwInvoiceRegisterDetail.CashCode, dbo.vwInvoiceRegisterDetail.StartOn, ABS(SUM(dbo.vwInvoiceRegisterDetail.InvoiceValue)) AS InvoiceValue, 
                      ABS(SUM(dbo.vwInvoiceRegisterDetail.TaxValue)) AS TaxValue
FROM         dbo.vwInvoiceRegisterDetail INNER JOIN
                      dbo.tbCashCode ON dbo.vwInvoiceRegisterDetail.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode
WHERE     (dbo.tbCashCategory.CashTypeCode = 1)
GROUP BY dbo.vwInvoiceRegisterDetail.StartOn, dbo.vwInvoiceRegisterDetail.CashCode
GO
CREATE VIEW dbo.vwTaskInvoiceValue
AS
SELECT        TaskCode, SUM(InvoiceValue) AS InvoiceValue, SUM(TaxValue) AS InvoiceTax
FROM            dbo.tbInvoiceTask
GROUP BY TaskCode
GO
CREATE VIEW dbo.vwCashCodeOrderSummary
AS
SELECT        dbo.tbTask.CashCode, dbo.fnAccountPeriod(dbo.tbTask.ActionOn) AS StartOn, SUM(dbo.tbTask.TotalCharge) - ISNULL(dbo.vwTaskInvoiceValue.InvoiceValue, 0) 
                         AS InvoiceValue, SUM(dbo.tbTask.TotalCharge * ISNULL(dbo.vwSystemTaxRates.TaxRate, 0)) - ISNULL(dbo.vwTaskInvoiceValue.InvoiceTax, 0) AS InvoiceTax
FROM            dbo.tbTask INNER JOIN
                         dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode LEFT OUTER JOIN
                         dbo.vwTaskInvoiceValue ON dbo.tbTask.TaskCode = dbo.vwTaskInvoiceValue.TaskCode LEFT OUTER JOIN
                         dbo.vwSystemTaxRates ON dbo.tbTask.TaxCode = dbo.vwSystemTaxRates.TaxCode
WHERE        (dbo.tbTask.TaskStatusCode = 2) OR
                         (dbo.tbTask.TaskStatusCode = 3)
GROUP BY dbo.tbTask.CashCode, dbo.fnAccountPeriod(dbo.tbTask.ActionOn), dbo.vwTaskInvoiceValue.InvoiceValue, dbo.vwTaskInvoiceValue.InvoiceTax
GO
ALTER PROCEDURE dbo.spSystemPeriodClose
AS

	if exists(select * from dbo.fnSystemActivePeriod())
		begin
		declare @StartOn datetime
		declare @YearNumber smallint
		
		select @StartOn = StartOn, @YearNumber = YearNumber
		from fnSystemActivePeriod() fnSystemActivePeriod
		 		
		begin tran	
		UPDATE tbSystemYearPeriod
		SET CashStatusCode = 3
		WHERE StartOn = @StartOn			
		
		if not exists (SELECT     CashStatusCode
					FROM         tbSystemYearPeriod
					WHERE     (YearNumber = @YearNumber) AND (CashStatusCode < 3)) 
			begin
			update tbSystemYear
			SET CashStatusCode = 3
			where YearNumber = @YearNumber	
			end
		if exists(select * from dbo.fnSystemActivePeriod())
			begin
			update tbSystemYearPeriod
			SET CashStatusCode = 2
			FROM fnSystemActivePeriod() fnSystemActivePeriod INNER JOIN
								tbSystemYearPeriod ON fnSystemActivePeriod.YearNumber = tbSystemYearPeriod.YearNumber AND fnSystemActivePeriod.MonthNumber = tbSystemYearPeriod.MonthNumber
			
			end		
		if exists(select * from dbo.fnSystemActivePeriod())
			begin
			update tbSystemYear
			SET CashStatusCode = 2
			FROM fnSystemActivePeriod() fnSystemActivePeriod INNER JOIN
								tbSystemYear ON fnSystemActivePeriod.YearNumber = tbSystemYear.YearNumber  
			end
		commit tran
		end
					
	RETURN
GO
ALTER VIEW dbo.vwCashFlowNITotals
AS
SELECT        dbo.tbCashPeriod.StartOn, SUM(dbo.tbCashPeriod.ForecastTax) AS ForecastNI, SUM(dbo.tbCashPeriod.InvoiceTax) AS InvoiceNI
FROM            dbo.tbCashPeriod INNER JOIN
                         dbo.tbCashCode ON dbo.tbCashPeriod.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                         dbo.tbSystemTaxCode ON dbo.tbCashCode.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE        (dbo.tbSystemTaxCode.TaxTypeCode = 3)
GROUP BY dbo.tbCashPeriod.StartOn
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
ALTER VIEW dbo.vwCashPolarData
AS
SELECT        dbo.tbCashPeriod.CashCode, dbo.tbCashCategory.CashTypeCode, dbo.tbCashPeriod.StartOn, dbo.tbCashPeriod.ForecastValue, dbo.tbCashPeriod.ForecastTax, 
                         dbo.tbCashPeriod.InvoiceValue, dbo.tbCashPeriod.InvoiceTax
FROM            dbo.tbCashPeriod INNER JOIN
                         dbo.tbCashCode ON dbo.tbCashPeriod.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                         dbo.tbSystemYearPeriod ON dbo.tbCashPeriod.StartOn = dbo.tbSystemYearPeriod.StartOn INNER JOIN
                         dbo.tbSystemYear ON dbo.tbSystemYearPeriod.YearNumber = dbo.tbSystemYear.YearNumber INNER JOIN
                         dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode
WHERE        (dbo.tbSystemYear.CashStatusCode < 4)
GO
ALTER VIEW [dbo].[vwCashFlowData]
AS
SELECT        dbo.tbSystemYearPeriod.YearNumber, dbo.tbSystemYearPeriod.StartOn, dbo.vwCashPolarData.CashCode, dbo.vwCashPolarData.InvoiceValue, 
                         dbo.vwCashPolarData.InvoiceTax, dbo.vwCashPolarData.ForecastValue, dbo.vwCashPolarData.ForecastTax
FROM            dbo.tbSystemYearPeriod INNER JOIN
                         dbo.vwCashPolarData ON dbo.tbSystemYearPeriod.StartOn = dbo.vwCashPolarData.StartOn
GO
DROP VIEW [dbo].[vwCashFlowForecastData]
DROP VIEW dbo.vwCashFlowActualData
GO
ALTER PROCEDURE [dbo].[spCashCodeValues]
	(
	@CashCode nvarchar(50),
	@YearNumber smallint
	)
AS
	SELECT        vwCashFlowData.StartOn, vwCashFlowData.InvoiceValue, vwCashFlowData.InvoiceTax, vwCashFlowData.ForecastValue, vwCashFlowData.ForecastTax
	FROM            tbSystemYearPeriod INNER JOIN
	                         vwCashFlowData ON tbSystemYearPeriod.StartOn = vwCashFlowData.StartOn
	WHERE        (tbSystemYearPeriod.YearNumber = @YearNumber) AND (vwCashFlowData.CashCode = @CashCode)
	ORDER BY vwCashFlowData.StartOn
	
	RETURN 
GO
ALTER PROCEDURE [dbo].[spCashCategoryCashCodes]
	(
	@CategoryCode nvarchar(10)
	)
AS
	SELECT     CashCode, CashDescription
	FROM         tbCashCode
	WHERE     (CategoryCode = @CategoryCode)
	ORDER BY CashDescription
	RETURN 
GO
DROP PROCEDURE dbo.spSystemPeriodTransferAll
DROP PROCEDURE dbo.spSystemPeriodTransfer
DROP VIEW dbo.vwCashCodePaymentSummary
DROP VIEW dbo.vwCashEmployerNITotals
DROP VIEW dbo.vwCashFlowVatTotals
DROP VIEW dbo.vwCashFlowVatTotalsBase
GO
ALTER TABLE dbo.tbCashPeriod DROP 
	CONSTRAINT [DF_tbCashPeriod_ActualTax], [DF_tbCashPeriod_ActualValue],
	COLUMN CashValue, CashTax
GO 
