GO
CREATE FUNCTION [dbo].[fnStatementCompany]()
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
	
	set @ReferenceCode = dbo.fnSystemProfileText(1215)	
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	SELECT     @ReferenceCode AS ReferenceCode, dbo.fnStatementTaxAccount(1) AS AccountCode, StartOn, 5, 0, CorporationTax, CashCode
	FROM         fnTaxCorpOrderTotals(0) fnTaxCorpOrderTotals_1		

	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	SELECT     ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode
	FROM         dbo.fnStatementVat()

	SET @AccountCode = dbo.fnStatementTaxAccount(2)
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	SELECT     @ReferenceCode AS ReferenceCode, @AccountCode AS AccountCode, dbo.fnTaskDefaultPaymentOn(@AccountCode, StartOn), 6 AS Expr1, PayIn, PayOut, dbo.fnSystemCashCode(2)
	FROM         fnTaxVatOrderTotals(0) fnTaxVatOrderTotals_1
	WHERE     (PayIn + PayOut <> 0)		
	/**************************************/	
	
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
CREATE FUNCTION [dbo].[fnAccountPeriod]
	(
	@TransactedOn datetime
	)
RETURNS datetime
 AS
	BEGIN
	declare @StartOn datetime
	SELECT TOP 1 @StartOn = StartOn
	FROM         tbSystemYearPeriod
	WHERE     (StartOn <= @TransactedOn)
	ORDER BY StartOn DESC
	
	RETURN @StartOn
	END
GO
CREATE VIEW [dbo].[vwTaskCashMode]
  AS
SELECT     dbo.tbTask.TaskCode, CASE WHEN tbCashCategory.CategoryCode IS NULL 
                      THEN tbOrgType.CashModeCode ELSE tbCashCategory.CashModeCode END AS CashModeCode
FROM         dbo.tbTask INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode INNER JOIN
                      dbo.tbOrg ON dbo.tbTask.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbOrgType ON dbo.tbOrg.OrganisationTypeCode = dbo.tbOrgType.OrganisationTypeCode
GO
CREATE VIEW [dbo].[vwTaskProfitOrders]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbTask.ActionOn) AS StartOn, dbo.tbTask.TaskCode, 
                      CASE WHEN dbo.tbCashCategory.CashModeCode = 1 THEN dbo.tbTask.TotalCharge * - 1 ELSE dbo.tbTask.TotalCharge END AS TotalCharge
FROM         dbo.tbCashCode INNER JOIN
                      dbo.tbTask ON dbo.tbCashCode.CashCode = dbo.tbTask.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode LEFT OUTER JOIN
                      dbo.tbTask AS tbTask_1 RIGHT OUTER JOIN
                      dbo.tbTaskFlow ON tbTask_1.TaskCode = dbo.tbTaskFlow.ParentTaskCode ON dbo.tbTask.TaskCode = dbo.tbTaskFlow.ChildTaskCode
WHERE     (dbo.tbTask.TaskStatusCode > 1) AND (dbo.tbTaskFlow.ParentTaskCode IS NULL) AND (tbTask_1.CashCode IS NULL) AND 
                      (dbo.tbTask.TaskStatusCode < 5) OR
                      (dbo.tbTask.TaskStatusCode > 1) AND (tbTask_1.CashCode IS NULL) AND (dbo.tbTask.TaskStatusCode < 5)
GO
CREATE FUNCTION [dbo].[fnNetProfitCashCodes]
	()
RETURNS @tbCashCode TABLE (CashCode nvarchar(50))
  AS
	BEGIN
	declare @CategoryCode nvarchar(10)
	select @CategoryCode = NetProfitCode from tbSystemOptions	
	set @CategoryCode = isnull(@CategoryCode, '')
	if (@CategoryCode != '')
		begin
		insert into @tbCashCode (CashCode)
		select CashCode from dbo.fnCategoryTotalCashCodes(@CategoryCode)
		end
	RETURN
	END
GO
CREATE VIEW [dbo].[vwCorpTaxInvoiceItems]
AS
SELECT     TOP (100) PERCENT dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.InvoiceValue * - 1 ELSE dbo.tbInvoiceItem.InvoiceValue END AS InvoiceValue
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.fnNetProfitCashCodes() AS fnNetProfitCashCodes ON dbo.tbInvoiceItem.CashCode = fnNetProfitCashCodes.CashCode INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
ORDER BY StartOn
GO
CREATE VIEW [dbo].[vwCorpTaxInvoiceTasks]
AS
SELECT     TOP (100) PERCENT dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.InvoiceValue * - 1 ELSE dbo.tbInvoiceTask.InvoiceValue END AS InvoiceValue
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.fnNetProfitCashCodes() AS fnNetProfitCashCodes ON dbo.tbInvoiceTask.CashCode = fnNetProfitCashCodes.CashCode INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
ORDER BY StartOn
GO
CREATE VIEW [dbo].[vwCorpTaxInvoiceValue]
AS
SELECT     StartOn, SUM(InvoiceValue) AS NetProfit
FROM         dbo.vwCorpTaxInvoiceItems
GROUP BY StartOn
UNION
SELECT     StartOn, SUM(InvoiceValue) AS NetProfit
FROM         dbo.vwCorpTaxInvoiceTasks
GROUP BY StartOn
GO
CREATE VIEW [dbo].[vwCorpTaxInvoiceBase]
AS
SELECT     StartOn, SUM(NetProfit) AS NetProfit
FROM         dbo.vwCorpTaxInvoiceValue
GROUP BY StartOn
GO
CREATE VIEW [dbo].[vwCorpTaxInvoice]
AS
SELECT     TOP (100) PERCENT dbo.tbSystemYearPeriod.StartOn, dbo.vwCorpTaxInvoiceBase.NetProfit, 
                      dbo.vwCorpTaxInvoiceBase.NetProfit * dbo.tbSystemYearPeriod.CorporationTaxRate + dbo.tbSystemYearPeriod.TaxAdjustment AS CorporationTax, 
                      dbo.tbSystemYearPeriod.TaxAdjustment
FROM         dbo.vwCorpTaxInvoiceBase INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.vwCorpTaxInvoiceBase.StartOn = dbo.tbSystemYearPeriod.StartOn
ORDER BY dbo.tbSystemYearPeriod.StartOn
GO
CREATE  VIEW [dbo].[vwInvoiceVatItems]
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
CREATE  VIEW [dbo].[vwInvoiceVatTasks]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoiceTask.InvoiceNumber, dbo.tbInvoice.InvoiceTypeCode, 
                      dbo.tbInvoiceTask.TaxCode, dbo.tbInvoiceTask.InvoiceValue, dbo.tbInvoiceTask.TaxValue, dbo.tbOrg.ForeignJurisdiction
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbInvoiceTask.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 2)
GO
CREATE  VIEW [dbo].[vwInvoiceVatBase]
AS
SELECT DISTINCT StartOn, InvoiceNumber, InvoiceTypeCode, TaxCode, InvoiceValue, TaxValue, ForeignJurisdiction
FROM         dbo.vwInvoiceVatItems
UNION
SELECT DISTINCT StartOn, InvoiceNumber, InvoiceTypeCode, TaxCode, InvoiceValue, TaxValue, ForeignJurisdiction
FROM         dbo.vwInvoiceVatTasks
GO
CREATE VIEW [dbo].[vwInvoiceVatDetail]
  AS
SELECT     StartOn, TaxCode, 
                      CASE WHEN vwInvoiceVatBase.ForeignJurisdiction = 0 THEN CASE vwInvoiceVatBase.InvoiceTypeCode WHEN 1 THEN vwInvoiceVatBase.InvoiceValue
                       WHEN 2 THEN vwInvoiceVatBase.InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomeSales, 
                      CASE WHEN vwInvoiceVatBase.ForeignJurisdiction = 0 THEN CASE vwInvoiceVatBase.InvoiceTypeCode WHEN 3 THEN vwInvoiceVatBase.InvoiceValue
                       WHEN 4 THEN vwInvoiceVatBase.InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomePurchases, 
                      CASE WHEN vwInvoiceVatBase.ForeignJurisdiction != 0 THEN CASE vwInvoiceVatBase.InvoiceTypeCode WHEN 1 THEN vwInvoiceVatBase.InvoiceValue
                       WHEN 2 THEN vwInvoiceVatBase.InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportSales, 
                      CASE WHEN vwInvoiceVatBase.ForeignJurisdiction != 0 THEN CASE vwInvoiceVatBase.InvoiceTypeCode WHEN 3 THEN vwInvoiceVatBase.InvoiceValue
                       WHEN 4 THEN vwInvoiceVatBase.InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportPurchases, 
                      CASE WHEN vwInvoiceVatBase.ForeignJurisdiction = 0 THEN CASE vwInvoiceVatBase.InvoiceTypeCode WHEN 1 THEN vwInvoiceVatBase.TaxValue WHEN
                       2 THEN vwInvoiceVatBase.TaxValue * - 1 ELSE 0 END ELSE 0 END AS HomeSalesVat, 
                      CASE WHEN vwInvoiceVatBase.ForeignJurisdiction = 0 THEN CASE vwInvoiceVatBase.InvoiceTypeCode WHEN 3 THEN vwInvoiceVatBase.TaxValue WHEN
                       4 THEN vwInvoiceVatBase.TaxValue * - 1 ELSE 0 END ELSE 0 END AS HomePurchasesVat, 
                      CASE WHEN vwInvoiceVatBase.ForeignJurisdiction != 0 THEN CASE vwInvoiceVatBase.InvoiceTypeCode WHEN 1 THEN vwInvoiceVatBase.TaxValue WHEN
                       2 THEN vwInvoiceVatBase.TaxValue * - 1 ELSE 0 END ELSE 0 END AS ExportSalesVat, 
                      CASE WHEN vwInvoiceVatBase.ForeignJurisdiction != 0 THEN CASE vwInvoiceVatBase.InvoiceTypeCode WHEN 3 THEN vwInvoiceVatBase.TaxValue WHEN
                       4 THEN vwInvoiceVatBase.TaxValue * - 1 ELSE 0 END ELSE 0 END AS ExportPurchasesVat
FROM         dbo.vwInvoiceVatBase
GO
CREATE VIEW [dbo].[vwInvoiceVatSummary]
AS
SELECT     StartOn, TaxCode, SUM(HomeSales) AS HomeSales, SUM(HomePurchases) AS HomePurchases, SUM(ExportSales) AS ExportSales, 
                      SUM(ExportPurchases) AS ExportPurchases, SUM(HomeSalesVat) AS HomeSalesVat, SUM(HomePurchasesVat) AS HomePurchasesVat, 
                      SUM(ExportSalesVat) AS ExportSalesVat, SUM(ExportPurchasesVat) AS ExportPurchasesVat
FROM         dbo.vwInvoiceVatDetail
GROUP BY StartOn, TaxCode
GO
CREATE VIEW [dbo].[vwSystemVatCashCode]
  AS
SELECT     CashCode, MonthNumber, RecurrenceCode
FROM         dbo.tbCashTaxType
WHERE     (TaxTypeCode = 2)
GO
CREATE VIEW [dbo].[vwSystemCorpTaxCashCode]
  AS
SELECT     CashCode, MonthNumber, RecurrenceCode
FROM         dbo.tbCashTaxType
WHERE     (TaxTypeCode = 1)
GO
CREATE FUNCTION [dbo].[fnCategoryTotalCashCodes]
	(
	@CategoryCode nvarchar(10)
	)
RETURNS @tbCashCode TABLE (CashCode nvarchar(50))
  AS
	BEGIN
	INSERT INTO @tbCashCode (CashCode)
	SELECT     tbCashCode.CashCode
	FROM         tbCashCategoryTotal INNER JOIN
	                      tbCashCategory ON tbCashCategoryTotal.ChildCode = tbCashCategory.CategoryCode INNER JOIN
	                      tbCashCode ON tbCashCategory.CategoryCode = tbCashCode.CategoryCode
	WHERE     (tbCashCategoryTotal.ParentCode = @CategoryCode)
	
	declare @ChildCode nvarchar(10)
	
	declare curCat cursor local for
		SELECT     tbCashCategory.CategoryCode
		FROM         tbCashCategory INNER JOIN
		                      tbCashCategoryTotal ON tbCashCategory.CategoryCode = tbCashCategoryTotal.ChildCode
		WHERE     (tbCashCategory.CategoryTypeCode = 2) AND (tbCashCategoryTotal.ParentCode = @CategoryCode)
	
	open curCat
	fetch next from curCat into @ChildCode
	while (@@FETCH_STATUS = 0)
		begin
		insert into @tbCashCode(CashCode)
		select CashCode from dbo.fnCategoryTotalCashCodes(@ChildCode)
		fetch next from curCat into @ChildCode
		end
	
	close curCat
	deallocate curCat
	
	RETURN
	END
GO
CREATE VIEW [dbo].[vwTaskInvoicedQuantity]
  AS
SELECT     dbo.tbInvoiceTask.TaskCode, SUM(dbo.tbInvoiceTask.Quantity) AS InvoiceQuantity
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber
WHERE     (dbo.tbInvoice.InvoiceTypeCode = 1) OR
                      (dbo.tbInvoice.InvoiceTypeCode = 3)
GROUP BY dbo.tbInvoiceTask.TaskCode
GO
CREATE FUNCTION [dbo].[fnSystemTaxHorizon]	()
RETURNS SMALLINT
AS
	BEGIN
	DECLARE @TaxHorizon SMALLINT
	SELECT @TaxHorizon = TaxHorizon FROM tbSystemOptions
	RETURN @TaxHorizon
	END
GO
CREATE VIEW [dbo].[vwCorpTaxConfirmedBase]
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
CREATE VIEW [dbo].[vwCorpTaxConfirmed]
  AS
SELECT     dbo.vwCorpTaxConfirmedBase.StartOn, SUM(dbo.vwCorpTaxConfirmedBase.OrderValue) AS NetProfit, 
                      SUM(dbo.vwCorpTaxConfirmedBase.OrderValue * dbo.tbSystemYearPeriod.CorporationTaxRate) AS CorporationTax
FROM         dbo.vwCorpTaxConfirmedBase INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.vwCorpTaxConfirmedBase.StartOn = dbo.tbSystemYearPeriod.StartOn
GROUP BY dbo.vwCorpTaxConfirmedBase.StartOn
GO
CREATE VIEW [dbo].[vwSystemTaxRates]
AS
SELECT     TaxCode, CAST(TaxRate AS MONEY) AS TaxRate, TaxTypeCode
FROM         tbSystemTaxCode
GO
CREATE VIEW [dbo].[vwTaskVatConfirmed]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * vwSystemTaxRates.TaxRate * - 1 ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) 
                      * vwSystemTaxRates.TaxRate END AS VatValue
FROM         dbo.tbTask INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode INNER JOIN
                      dbo.vwSystemTaxRates ON dbo.tbTask.TaxCode = dbo.vwSystemTaxRates.TaxCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.vwSystemTaxRates.TaxTypeCode = 2) AND (dbo.tbTask.TaskStatusCode > 1) AND (dbo.tbTask.TaskStatusCode < 4) AND 
                      (CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * vwSystemTaxRates.TaxRate ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) 
                      * vwSystemTaxRates.TaxRate * - 1 END <> 0) AND (dbo.tbTask.PaymentOn <= DATEADD(d, dbo.fnSystemTaxHorizon(), GETDATE()))
GO
