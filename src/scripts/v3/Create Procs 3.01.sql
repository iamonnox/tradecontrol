/*****************************************************
Stored Procedures
*****************************************************/

CREATE PROCEDURE Activity.proc_Mode
	(
	@ActivityCode NVARCHAR(50)
	)
  AS
	SELECT     Activity.tbActivity.ActivityCode, Activity.tbActivity.UnitOfMeasure, Task.tbStatus.TaskStatus, Cash.tbCategory.CashModeCode
	FROM         Activity.tbActivity INNER JOIN
	                      Task.tbStatus ON Activity.tbActivity.TaskStatusCode = Task.tbStatus.TaskStatusCode LEFT OUTER JOIN
	                      Cash.tbCode ON Activity.tbActivity.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
	                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE     ( Activity.tbActivity.ActivityCode = @ActivityCode)
	RETURN 
GO
CREATE PROCEDURE Activity.proc_NextAttributeOrder 
	(
	@ActivityCode NVARCHAR(50),
	@PrintOrder SMALLINT = 10 OUTPUT
	)
  AS
	IF EXISTS(SELECT     TOP 1 PrintOrder
	          FROM         Activity.tbAttribute
	          WHERE     (ActivityCode = @ActivityCode))
		BEGIN
		SELECT  @PrintOrder = MAX(PrintOrder) 
		FROM         Activity.tbAttribute
		WHERE     (ActivityCode = @ActivityCode)
		SET @PrintOrder = @PrintOrder - (@PrintOrder % 10) + 10		
		END
	ELSE
		SET @PrintOrder = 10
		
	RETURN
GO
CREATE PROCEDURE Activity.proc_NextOperationNumber 
	(
	@ActivityCode NVARCHAR(50),
	@OperationNumber SMALLINT = 10 OUTPUT
	)
  AS
	IF EXISTS(SELECT     TOP 1 OperationNumber
	          FROM         Activity.tbOp
	          WHERE     (ActivityCode = @ActivityCode))
		BEGIN
		SELECT  @OperationNumber = MAX(OperationNumber) 
		FROM         Activity.tbOp
		WHERE     (ActivityCode = @ActivityCode)
		SET @OperationNumber = @OperationNumber - (@OperationNumber % 10) + 10		
		END
	ELSE
		SET @OperationNumber = 10
		
	RETURN
GO
CREATE PROCEDURE Activity.proc_NextStepNumber 
	(
	@ActivityCode NVARCHAR(50),
	@StepNumber SMALLINT = 10 OUTPUT
	)
  AS
	IF EXISTS(SELECT     TOP 1 StepNumber
	          FROM         Activity.tbFlow
	          WHERE     (ParentCode = @ActivityCode))
		BEGIN
		SELECT  @StepNumber = MAX(StepNumber) 
		FROM         Activity.tbFlow
		WHERE     (ParentCode = @ActivityCode)
		SET @StepNumber = @StepNumber - (@StepNumber % 10) + 10		
		END
	ELSE
		SET @StepNumber = 10
		
	RETURN
GO
CREATE PROCEDURE Activity.proc_Parent
	(
	@ActivityCode NVARCHAR(50),
	@ParentCode NVARCHAR(50) = null OUTPUT
	)
  AS
	IF EXISTS(SELECT     ParentCode
	          FROM         Activity.tbFlow
	          WHERE     (ChildCode = @ActivityCode))
		SELECT @ParentCode = ParentCode
		FROM         Activity.tbFlow
		WHERE     (ChildCode = @ActivityCode)
	ELSE
		SET @ParentCode = @ActivityCode
		
	RETURN 
GO
CREATE PROCEDURE Activity.proc_WorkFlow
	(
	@ActivityCode NVARCHAR(50)
	)
  AS
	SELECT     Activity.tbActivity.ActivityCode, Task.tbStatus.TaskStatus, Cash.tbCategory.CashModeCode, Activity.tbActivity.UnitOfMeasure, Activity.tbFlow.OffSETDays
	FROM         Activity.tbActivity INNER JOIN
	                      Task.tbStatus ON Activity.tbActivity.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
	                      Activity.tbFlow ON Activity.tbActivity.ActivityCode = Activity.tbFlow.ChildCode LEFT OUTER JOIN
	                      Cash.tbCode ON Activity.tbActivity.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
	                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE     ( Activity.tbFlow.ParentCode = @ActivityCode)
	ORDER BY Activity.tbFlow.StepNumber	


	RETURN 
GO
CREATE PROCEDURE Cash.proc_AccountRebuild
	(
	@CashAccountCode NVARCHAR(10)
	)
  AS
	
	UPDATE Org.tbAccount
	SET CurrentBalance = Cash.vwAccountRebuild.CurrentBalance
	FROM         Cash.vwAccountRebuild INNER JOIN
						Org.tbAccount ON Cash.vwAccountRebuild.CashAccountCode = Org.tbAccount.CashAccountCode
	WHERE Cash.vwAccountRebuild.CashAccountCode = @CashAccountCode 

	UPDATE Org.tbAccount
	SET CurrentBalance = 0
	FROM         Cash.vwAccountRebuild RIGHT OUTER JOIN
	                      Org.tbAccount ON Cash.vwAccountRebuild.CashAccountCode = Org.tbAccount.CashAccountCode
	WHERE     (Cash.vwAccountRebuild.CashAccountCode IS NULL) AND Org.tbAccount.CashAccountCode = @CashAccountCode
										
	RETURN 
GO
CREATE PROCEDURE Cash.proc_AccountRebuildAll
  AS
	
	UPDATE Org.tbAccount
	SET CurrentBalance = Cash.vwAccountRebuild.CurrentBalance
	FROM         Cash.vwAccountRebuild INNER JOIN
						Org.tbAccount ON Cash.vwAccountRebuild.CashAccountCode = Org.tbAccount.CashAccountCode
	
	UPDATE Org.tbAccount
	SET CurrentBalance = 0
	FROM         Cash.vwAccountRebuild RIGHT OUTER JOIN
	                      Org.tbAccount ON Cash.vwAccountRebuild.CashAccountCode = Org.tbAccount.CashAccountCode
	WHERE     (Cash.vwAccountRebuild.CashAccountCode IS NULL)

	RETURN
GO
CREATE PROCEDURE Cash.proc_CategoryCashCodes
	(
	@CategoryCode NVARCHAR(10)
	)
   AS
	SELECT     CashCode, CashDescription
	FROM         Cash.tbCode
	WHERE     (CategoryCode = @CategoryCode)
	ORDER BY CashDescription
	RETURN 
GO
CREATE PROCEDURE Cash.proc_CategoryCodeFromName
	(
		@Category NVARCHAR(50),
		@CategoryCode NVARCHAR(10) OUTPUT
	)
   AS
	IF EXISTS (SELECT CategoryCode
				FROM         Cash.tbCategory
				WHERE     (Category = @Category))
		SELECT @CategoryCode = CategoryCode
		FROM         Cash.tbCategory
		WHERE     (Category = @Category)
	ELSE
		SET @CategoryCode = 0
		
	RETURN 
GO
CREATE PROCEDURE Cash.proc_CategoryTotals
	(
	@CashTypeCode SMALLINT,
	@CategoryTypeCode SMALLINT = 2
	)
   AS

	SELECT     Cash.tbCategory.DisplayOrder, Cash.tbCategory.Category, Cash.tbType.CashType, Cash.tbCategory.CategoryCode
	FROM         Cash.tbCategory INNER JOIN
	                      Cash.tbType ON Cash.tbCategory.CashTypeCode = Cash.tbType.CashTypeCode
	WHERE     ( Cash.tbCategory.CashTypeCode = @CashTypeCode) AND ( Cash.tbCategory.CategoryTypeCode = @CategoryTypeCode)
	ORDER BY Cash.tbCategory.DisplayOrder, Cash.tbCategory.Category
	
	RETURN 
GO
CREATE PROCEDURE Cash.proc_CodeDefaults 
	(
	@CashCode NVARCHAR(50)
	)
  AS
	SELECT     Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCode.CategoryCode, Cash.tbCode.TaxCode, Cash.tbCode.OpeningBalance, 
	                      ISNULL( Cash.tbCategory.CashModeCode, 1) AS CashModeCode, App.tbTaxCode.TaxTypeCode
	FROM         Cash.tbCode INNER JOIN
	                      App.tbTaxCode ON Cash.tbCode.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
	                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE     ( Cash.tbCode.CashCode = @CashCode)
	
	RETURN
GO
CREATE PROCEDURE Cash.proc_CodeValues
	(
	@CashCode NVARCHAR(50),
	@YearNumber SMALLINT
	)
    AS
	SELECT        Cash.vwFlowData.StartOn, Cash.vwFlowData.InvoiceValue, Cash.vwFlowData.InvoiceTax, Cash.vwFlowData.ForecastValue, Cash.vwFlowData.ForecastTax
	FROM            App.tbYearPeriod INNER JOIN
	                         Cash.vwFlowData ON App.tbYearPeriod.StartOn = Cash.vwFlowData.StartOn
	WHERE        ( App.tbYearPeriod.YearNumber = @YearNumber) AND (Cash.vwFlowData.CashCode = @CashCode)
	ORDER BY Cash.vwFlowData.StartOn
	
	RETURN 

GO
CREATE PROCEDURE Cash.proc_CopyForecastToLiveCashCode
	(
	@CashCode NVARCHAR(50),
	@StartOn DATETIME
	)

   AS
	UPDATE Cash.tbPeriod
	SET     InvoiceValue = ForecastValue, InvoiceTax = ForecastTax
	FROM         Cash.tbPeriod
	WHERE     (CashCode = @CashCode) AND (StartOn = @StartOn)
	RETURN 
GO
CREATE PROCEDURE Cash.proc_CopyForecastToLiveCategory
	(
	@CategoryCode NVARCHAR(10),
	@StartOn DATETIME
	)

   AS
	UPDATE Cash.tbPeriod
	SET     InvoiceValue = ForecastValue, InvoiceTax = ForecastTax
	FROM         Cash.tbPeriod INNER JOIN
	                      Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode
	WHERE     ( Cash.tbPeriod.StartOn = @StartOn) AND ( Cash.tbCode.CategoryCode = @CategoryCode)
GO
CREATE PROCEDURE Cash.proc_CopyLiveToForecastCashCode
	(
	@CashCode NVARCHAR(50),
	@Years SMALLINT,
	@UseLastPeriod BIT = 0
	)

   AS
DECLARE @SystemStartOn DATETIME
DECLARE @EndPeriod DATETIME
DECLARE @StartPeriod DATETIME
DECLARE @CurPeriod DATETIME
	
DECLARE @InvoiceValue MONEY
DECLARE @InvoiceTax MONEY

	SELECT @CurPeriod = StartOn
	FROM         App.fnActivePeriod() 
	
	SET @EndPeriod = DATEADD(m, -1, @CurPeriod)
	SET @StartPeriod = DATEADD(m, -11, @EndPeriod)	
	
	SELECT @SystemStartOn = MIN(StartOn)
	FROM         App.tbYearPeriod
	
	IF @StartPeriod < @SystemStartOn 
		SET @UseLastPeriod = 1

	IF @UseLastPeriod = 0
		GOTO YearCopyMode
	ELSE
		GOTO LastMonthCopyMode
		
	RETURN
		
	
YearCopyMode:

	DECLARE curPe CURSOR FOR
		SELECT     StartOn, InvoiceValue, InvoiceTax
		FROM         Cash.tbPeriod
		WHERE     (StartOn <= @EndPeriod AND StartOn >= @StartPeriod) and (CashCode = @CashCode)
		ORDER BY	CashCode, StartOn	
		
	WHILE @Years > 0
		BEGIN
		OPEN curPe

		FETCH NEXT FROM curPe INTO @StartPeriod, @InvoiceValue, @InvoiceTax
		WHILE @@FETCH_STATUS = 0
			BEGIN				
			UPDATE Cash.tbPeriod
			SET
				ForecastValue = @InvoiceValue, 
				ForecastTax = @InvoiceTax
			FROM         Cash.tbPeriod
			WHERE     (CashCode = @CashCode) AND (StartOn = @CurPeriod)

			SELECT TOP 1 @CurPeriod = StartOn
			FROM Cash.tbPeriod
			WHERE     (CashCode = @CashCode) AND (StartOn > @CurPeriod)
			ORDER BY StartOn	
			FETCH NEXT FROM curPe INTO @StartPeriod, @InvoiceValue, @InvoiceTax
			END
		
		SET @Years = @Years - 1
		CLOSE curPe
		END
		
	DEALLOCATE curPe
			
	RETURN 

LastMonthCopyMode:
DECLARE @Idx INTEGER

	SELECT TOP 1 @InvoiceValue = InvoiceValue, @InvoiceTax = InvoiceTax
	FROM         Cash.tbPeriod
	WHERE     (CashCode = @CashCode) AND (StartOn < @CurPeriod)
	ORDER BY StartOn DESC
		
	WHILE @Years > 0
		BEGIN
		SET @Idx = 1
		WHILE @Idx <= 12
			BEGIN
			UPDATE Cash.tbPeriod
			SET
				ForecastValue = @InvoiceValue, 
				ForecastTax = @InvoiceTax
			FROM         Cash.tbPeriod
			WHERE     (CashCode = @CashCode) AND (StartOn = @CurPeriod)

			SELECT TOP 1 @CurPeriod = StartOn
			FROM Cash.tbPeriod
			WHERE     (CashCode = @CashCode) AND (StartOn > @CurPeriod)
			ORDER BY StartOn			

			SET @Idx = @Idx + 1
			END			
	
		SET @Years = @Years - 1
		END


	RETURN
GO
CREATE PROCEDURE Cash.proc_CopyLiveToForecastCategory
	(
	@CategoryCode NVARCHAR(10),
	@Years SMALLINT,
	@UseLastPeriod BIT = 0
	)

   AS	
DECLARE @CashCode NVARCHAR(50)

	DECLARE curCc CURSOR FOR
	SELECT     CashCode
	FROM         Cash.tbCode
	WHERE     (CategoryCode = @CategoryCode)
		
	OPEN curCc

	FETCH NEXT FROM curCc INTO @CashCode
	WHILE @@FETCH_STATUS = 0
		BEGIN
		EXEC Cash.proc_CopyLiveToForecastCashCode @CashCode, @Years, @UseLastPeriod
		FETCH NEXT FROM curCc INTO @CashCode
		END
	
	CLOSE curCc
		
	DEALLOCATE curCc
			
	RETURN
GO
CREATE PROCEDURE Cash.proc_GeneratePeriods
    AS
DECLARE @YearNumber SMALLINT
DECLARE @StartOn DATETIME
DECLARE @PeriodStartOn DATETIME
DECLARE @CashStatusCode SMALLINT
DECLARE @Period SMALLINT

	DECLARE curYr CURSOR FOR	
		SELECT     YearNumber, CONVERT(DATETIME, '1/' + STR(StartMonth) + '/' + STR(YearNumber), 103) AS StartOn, CashStatusCode
		FROM         App.tbYear

	OPEN curYr
	
	FETCH NEXT FROM curYr INTO @YearNumber, @StartOn, @CashStatusCode
	WHILE @@FETCH_STATUS = 0
		BEGIN
		SET @PeriodStartOn = @StartOn
		SET @Period = 1
		WHILE @Period < 13
			BEGIN
			IF NOT EXISTS (SELECT MonthNumber FROM App.tbYearPeriod WHERE YearNumber = @YearNumber and MonthNumber = datepart(m, @PeriodStartOn))
				BEGIN
				INSERT INTO App.tbYearPeriod (YearNumber, StartOn, MonthNumber, CashStatusCode)
				VALUES (@YearNumber, @PeriodStartOn, datepart(m, @PeriodStartOn), 1)				
				END
			SET @PeriodStartOn = DATEADD(m, 1, @PeriodStartOn)	
			SET @Period = @Period + 1
			END		
				
		FETCH NEXT FROM curYr INTO @YearNumber, @StartOn, @CashStatusCode
		END
	
	
	CLOSE curYr
	DEALLOCATE curYr
	
	INSERT INTO Cash.tbPeriod
	                      (CashCode, StartOn)
	SELECT     Cash.vwPeriods.CashCode, Cash.vwPeriods.StartOn
	FROM         Cash.vwPeriods LEFT OUTER JOIN
	                      Cash.tbPeriod ON Cash.vwPeriods.CashCode = Cash.tbPeriod.CashCode AND Cash.vwPeriods.StartOn = Cash.tbPeriod.StartOn
	WHERE     ( Cash.tbPeriod.CashCode IS NULL)
	RETURN 
GO
CREATE PROCEDURE Cash.proc_FlowInitialise
   AS
DECLARE @CashCode NVARCHAR(25)
		
	EXEC Cash.proc_GeneratePeriods
	
	UPDATE       Cash.tbPeriod
	SET                ForecastValue = 0, ForecastTax = 0, InvoiceValue = 0, InvoiceTax = 0
	FROM            Cash.tbPeriod INNER JOIN
	                         Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode INNER JOIN
	                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE  ( Cash.tbCategory.CashTypeCode <> 3)
	
	UPDATE Cash.tbPeriod
	SET InvoiceValue = Cash.vwCodeInvoiceSummary.InvoiceValue, 
		InvoiceTax = Cash.vwCodeInvoiceSummary.TaxValue
	FROM         Cash.tbPeriod INNER JOIN
	                      Cash.vwCodeInvoiceSummary ON Cash.tbPeriod.CashCode = Cash.vwCodeInvoiceSummary.CashCode AND Cash.tbPeriod.StartOn = Cash.vwCodeInvoiceSummary.StartOn	

	UPDATE Cash.tbPeriod
	SET 
		InvoiceValue = Cash.vwAccountPeriodClosingBalance.ClosingBalance
	FROM         Cash.vwAccountPeriodClosingBalance INNER JOIN
	                      Cash.tbPeriod ON Cash.vwAccountPeriodClosingBalance.CashCode = Cash.tbPeriod.CashCode AND 
	                      Cash.vwAccountPeriodClosingBalance.StartOn = Cash.tbPeriod.StartOn
	                      	
	UPDATE       Cash.tbPeriod
	SET                ForecastValue = Cash.vwCodeForecastSummary.ForecastValue, ForecastTax = Cash.vwCodeForecastSummary.ForecastTax
	FROM            Cash.tbPeriod INNER JOIN
	                         Cash.vwCodeForecastSummary ON Cash.tbPeriod.CashCode = Cash.vwCodeForecastSummary.CashCode AND 
	                         Cash.tbPeriod.StartOn = Cash.vwCodeForecastSummary.StartOn

	UPDATE Cash.tbPeriod
	SET
		InvoiceValue = Cash.tbPeriod.InvoiceValue + Cash.vwCodeOrderSummary.InvoiceValue,
		InvoiceTax = Cash.tbPeriod.InvoiceTax + Cash.vwCodeOrderSummary.InvoiceTax
	FROM Cash.tbPeriod INNER JOIN
		Cash.vwCodeOrderSummary ON Cash.tbPeriod.CashCode = Cash.vwCodeOrderSummary.CashCode
			AND Cash.tbPeriod.StartOn = Cash.vwCodeOrderSummary.StartOn	
	
	--Corporation Tax
	SELECT   @CashCode = CashCode
	FROM            Cash.tbTaxType
	WHERE        (TaxTypeCode = 1)
	
	UPDATE       Cash.tbPeriod
	SET                ForecastValue = 0, ForecastTax = 0, InvoiceValue = 0, InvoiceTax = 0
	FROM            Cash.tbPeriod
	WHERE CashCode = @CashCode	
	
	UPDATE       Cash.tbPeriod
	SET                InvoiceValue = vwTaxCorpStatement.TaxDue
	FROM            vwTaxCorpStatement INNER JOIN
	                         Cash.tbPeriod ON vwTaxCorpStatement.StartOn = Cash.tbPeriod.StartOn
	WHERE        (vwTaxCorpStatement.TaxDue <> 0) AND ( Cash.tbPeriod.CashCode = @CashCode)
	
	--VAT 		
	SELECT   @CashCode = CashCode
	FROM            Cash.tbTaxType
	WHERE        (TaxTypeCode = 2)

	UPDATE       Cash.tbPeriod
	SET                InvoiceValue = Cash.vwTaxVatStatement.VatDue
	FROM            Cash.vwTaxVatStatement INNER JOIN
	                         Cash.tbPeriod ON Cash.vwTaxVatStatement.StartOn = Cash.tbPeriod.StartOn
	WHERE        ( Cash.tbPeriod.CashCode = @CashCode) AND (Cash.vwTaxVatStatement.VatDue <> 0)

	--**********************************************************************************************	                  	

	UPDATE Cash.tbPeriod
	SET
		ForecastValue = Cash.vwFlowNITotals.ForecastNI, 
		InvoiceValue = Cash.vwFlowNITotals.InvoiceNI
	FROM         Cash.tbPeriod INNER JOIN
	                      Cash.vwFlowNITotals ON Cash.tbPeriod.StartOn = Cash.vwFlowNITotals.StartOn
	WHERE     ( Cash.tbPeriod.CashCode = App.fnCashCode(3))
	                      
	
	RETURN 
GO
CREATE PROCEDURE Cash.proc_VatBalance
	(
	@Balance MONEY OUTPUT
	)
  AS
	SET @Balance = App.fnVatBalance()
	RETURN 
GO
CREATE PROCEDURE Invoice.proc_Total 
	(
	@InvoiceNumber NVARCHAR(20)
	)
  AS
DECLARE @InvoiceValue MONEY
DECLARE @TaxValue MONEY
DECLARE @PaidValue MONEY
DECLARE @PaidTaxValue MONEY

	SET @InvoiceValue = 0
	SET @TaxValue = 0
	SET @PaidValue = 0
	SET @PaidTaxValue = 0
	
	UPDATE     Invoice.tbTask
	SET TaxValue = ROUND( Invoice.tbTask.InvoiceValue * App.vwTaxRates.TaxRate, 2)
	FROM         Invoice.tbTask INNER JOIN
	                      App.vwTaxRates ON Invoice.tbTask.TaxCode = App.vwTaxRates.TaxCode
	WHERE     ( Invoice.tbTask.InvoiceNumber = @InvoiceNumber)

	UPDATE     Invoice.tbItem
	SET TaxValue = CAST(ROUND( Invoice.tbItem.InvoiceValue * CAST(App.vwTaxRates.TaxRate AS MONEY), 2) AS MONEY)
	FROM         Invoice.tbItem INNER JOIN
	                      App.vwTaxRates ON Invoice.tbItem.TaxCode = App.vwTaxRates.TaxCode
	WHERE     ( Invoice.tbItem.InvoiceNumber = @InvoiceNumber)

	SELECT  TOP 1 @InvoiceValue = ISNULL(SUM(InvoiceValue), 0), 
		@TaxValue = ISNULL(SUM(TaxValue), 0),
		@PaidValue = ISNULL(SUM(PaidValue), 0), 
		@PaidTaxValue = ISNULL(SUM(PaidTaxValue), 0)
	FROM         Invoice.tbTask
	GROUP BY InvoiceNumber
	HAVING      (InvoiceNumber = @InvoiceNumber)
	
	SELECT  TOP 1 @InvoiceValue = @InvoiceValue + ISNULL(SUM(InvoiceValue), 0), 
		@TaxValue = @TaxValue + ISNULL(SUM(TaxValue), 0),
		@PaidValue = @PaidValue + ISNULL(SUM(PaidValue), 0), 
		@PaidTaxValue = @PaidTaxValue + ISNULL(SUM(PaidTaxValue), 0)
	FROM         Invoice.tbItem
	GROUP BY InvoiceNumber
	HAVING      (InvoiceNumber = @InvoiceNumber)
	
	SET @InvoiceValue = Round(@InvoiceValue, 2)
	SET @TaxValue = Round(@TaxValue, 2)
	SET @PaidValue = Round(@PaidValue, 2)
	SET @PaidTaxValue = Round(@PaidTaxValue, 2)
	
		
	UPDATE    Invoice.tbInvoice
	SET              InvoiceValue = ISNULL(@InvoiceValue, 0), TaxValue = ISNULL(@TaxValue, 0),
		PaidValue = ISNULL(@PaidValue, 0), PaidTaxValue = ISNULL(@PaidTaxValue, 0),
		InvoiceStatusCode = CASE 
				WHEN @PaidValue >= @InvoiceValue THEN 4 
				WHEN @PaidValue > 0 THEN 3 
				ELSE 2 END
	WHERE     (InvoiceNumber = @InvoiceNumber)
		
	RETURN
GO
CREATE PROCEDURE Invoice.proc_Accept 
	(
	@InvoiceNumber NVARCHAR(20)
	)
  AS

		IF EXISTS(SELECT     InvoiceNumber
	          FROM         Invoice.tbItem
	          WHERE     (InvoiceNumber = @InvoiceNumber)) 
		or EXISTS(SELECT     InvoiceNumber
	          FROM         Invoice.tbTask
	          WHERE     (InvoiceNumber = @InvoiceNumber))
		BEGIN
			BEGIN TRAN trAcc
			
			EXEC Invoice.proc_Total @InvoiceNumber
			
			UPDATE    Invoice.tbInvoice
			SET              InvoiceStatusCode = 2
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (InvoiceStatusCode = 1) 
	
			UPDATE       Task
			SET                TaskStatusCode = 4
			FROM            Task.tbTask AS Task INNER JOIN
									 Task.vwInvoicedQuantity ON Task.TaskCode = Task.vwInvoicedQuantity.TaskCode AND Task.Quantity <= Task.vwInvoicedQuantity.InvoiceQuantity INNER JOIN
									 Invoice.tbTask AS InvoiceTask ON Task.TaskCode = InvoiceTask.TaskCode AND Task.TaskCode = InvoiceTask.TaskCode
			WHERE        (InvoiceTask.InvoiceNumber = @InvoiceNumber) AND (Task.TaskStatusCode < 4)
			
			COMMIT TRAN trAcc
		END
			
	RETURN
GO
CREATE PROCEDURE Invoice.proc_AddTask 
	(
	@InvoiceNumber NVARCHAR(20),
	@TaskCode NVARCHAR(20)	
	)
  AS
DECLARE @InvoiceTypeCode SMALLINT
DECLARE @InvoiceQuantity FLOAT
DECLARE @QuantityInvoiced FLOAT

	IF EXISTS(SELECT     InvoiceNumber, TaskCode
	          FROM         Invoice.tbTask
	          WHERE     (InvoiceNumber = @InvoiceNumber) AND (TaskCode = @TaskCode))
		RETURN
		
	SELECT   @InvoiceTypeCode = InvoiceTypeCode
	FROM         Invoice.tbInvoice
	WHERE     (InvoiceNumber = @InvoiceNumber) 

	IF EXISTS(SELECT     SUM( Invoice.tbTask.Quantity) AS QuantityInvoiced
	          FROM         Invoice.tbTask INNER JOIN
	                                Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
	          WHERE     ( Invoice.tbInvoice.InvoiceTypeCode = 1 OR
	                                Invoice.tbInvoice.InvoiceTypeCode = 3) AND ( Invoice.tbTask.TaskCode = @TaskCode) AND ( Invoice.tbInvoice.InvoiceStatusCode > 1))
		BEGIN
		SELECT TOP 1 @QuantityInvoiced = ISNULL(SUM( Invoice.tbTask.Quantity), 0)
		FROM         Invoice.tbTask INNER JOIN
				tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceTypeCode = 1 OR
				tbInvoice.InvoiceTypeCode = 3) AND ( Invoice.tbTask.TaskCode = @TaskCode) AND ( Invoice.tbInvoice.InvoiceStatusCode > 1)				
		END
	ELSE
		SET @QuantityInvoiced = 0
		
	IF @InvoiceTypeCode = 2 or @InvoiceTypeCode = 4
		BEGIN
		IF EXISTS(SELECT     SUM( Invoice.tbTask.Quantity) AS QuantityInvoiced
				  FROM         Invoice.tbTask INNER JOIN
										tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
				  WHERE     ( Invoice.tbInvoice.InvoiceTypeCode = 2 OR
										tbInvoice.InvoiceTypeCode = 4) AND ( Invoice.tbTask.TaskCode = @TaskCode) AND ( Invoice.tbInvoice.InvoiceStatusCode > 1))
			BEGIN
			SELECT TOP 1 @InvoiceQuantity = ISNULL(@QuantityInvoiced, 0) - ISNULL(SUM( Invoice.tbTask.Quantity), 0)
			FROM         Invoice.tbTask INNER JOIN
					tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE     ( Invoice.tbInvoice.InvoiceTypeCode = 2 OR
					tbInvoice.InvoiceTypeCode = 4) AND ( Invoice.tbTask.TaskCode = @TaskCode) AND ( Invoice.tbInvoice.InvoiceStatusCode > 1)										
			END
		ELSE
			SET @InvoiceQuantity = ISNULL(@QuantityInvoiced, 0)
		END
	ELSE
		BEGIN
		SELECT  @InvoiceQuantity = Quantity - ISNULL(@QuantityInvoiced, 0)
		FROM         Task.tbTask
		WHERE     (TaskCode = @TaskCode)
		END
			
	IF ISNULL(@InvoiceQuantity, 0) <= 0
		SET @InvoiceQuantity = 1
		
	INSERT INTO Invoice.tbTask
	                      (InvoiceNumber, TaskCode, Quantity, InvoiceValue, CashCode, TaxCode)
	SELECT     @InvoiceNumber AS InvoiceNumber, TaskCode, @InvoiceQuantity AS Quantity, UnitCharge * @InvoiceQuantity AS InvoiceValue, CashCode, 
	                      TaxCode
	FROM         Task.tbTask
	WHERE     (TaskCode = @TaskCode)
	
	EXEC Invoice.proc_Total @InvoiceNumber
			
	RETURN
GO
CREATE PROCEDURE Invoice.proc_Cancel 
  AS

UPDATE       Task
SET                TaskStatusCode = 3
FROM            Task.tbTask AS Task INNER JOIN
                         Invoice.tbTask AS InvoiceTask ON Task.TaskCode = InvoiceTask.TaskCode AND Task.TaskCode = InvoiceTask.TaskCode INNER JOIN
                         Invoice.tbInvoice ON InvoiceTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
                         Usr.vwCredentials ON Invoice.tbInvoice.UserId = Usr.vwCredentials.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 1 OR
                         Invoice.tbInvoice.InvoiceTypeCode = 3) AND (Invoice.tbInvoice.InvoiceStatusCode = 1)
	                      
	DELETE Invoice.tbInvoice
	FROM         Invoice.tbInvoice INNER JOIN
	                      Usr.vwCredentials ON Invoice.tbInvoice.UserId = Usr.vwCredentials.UserId
	WHERE     ( Invoice.tbInvoice.InvoiceStatusCode = 1)

	
	RETURN
GO
CREATE PROCEDURE Invoice.proc_Credit
	(
		@InvoiceNumber NVARCHAR(20) OUTPUT
	)
  AS
DECLARE @InvoiceTypeCode SMALLINT
DECLARE @CreditNumber NVARCHAR(20)
DECLARE @UserId NVARCHAR(10)
DECLARE @NextNumber INT
DECLARE @InvoiceSuffix NVARCHAR(4)

	SELECT @UserId = UserId FROM Usr.vwCredentials
	
	SELECT @InvoiceTypeCode = InvoiceTypeCode FROM Invoice.tbInvoice WHERE InvoiceNumber = @InvoiceNumber
	
	SET @InvoiceTypeCode = CASE @InvoiceTypeCode WHEN 1 then 2 WHEN 3 then 4 ELSE 4 END
	
	SELECT @UserId = UserId FROM Usr.vwCredentials

	SET @InvoiceSuffix = '.' + @UserId
	
	SELECT @NextNumber = NextNumber
	FROM Invoice.tbType
	WHERE InvoiceTypeCode = @InvoiceTypeCode
	
	SELECT @CreditNumber = FORMAT(@NextNumber, '000000') + @InvoiceSuffix
	
	WHILE EXISTS (SELECT     InvoiceNumber
	              FROM         Invoice.tbInvoice
	              WHERE     (InvoiceNumber = @CreditNumber))
		BEGIN
		SET @NextNumber = @NextNumber + 1
		SET @CreditNumber = FORMAT(@NextNumber, '000000') + @InvoiceSuffix
		END
		
	BEGIN TRAN Credit
	
	EXEC Invoice.proc_Cancel
	
	UPDATE    Invoice.tbType
	SET              NextNumber = @NextNumber + 1
	WHERE     (InvoiceTypeCode = @InvoiceTypeCode)	
	
	INSERT INTO Invoice.tbInvoice	
						(InvoiceNumber, InvoiceStatusCode, AccountCode, InvoiceValue, TaxValue, UserId, InvoiceTypeCode, InvoicedOn)
	SELECT     @CreditNumber AS InvoiceNumber, 1 AS InvoiceStatusCode, AccountCode, InvoiceValue, TaxValue, @UserId AS UserId, 
						@InvoiceTypeCode AS InvoiceTypeCode, SYSDATETIME() AS InvoicedOn
	FROM         Invoice.tbInvoice
	WHERE     (InvoiceNumber = @InvoiceNumber)
	
	INSERT INTO Invoice.tbItem
	                      (InvoiceNumber, CashCode, TaxCode, InvoiceValue, TaxValue)
	SELECT     @CreditNumber AS InvoiceNumber, CashCode, TaxCode, InvoiceValue, TaxValue
	FROM         Invoice.tbItem
	WHERE     (InvoiceNumber = @InvoiceNumber)
	
	INSERT INTO Invoice.tbTask
	                      (InvoiceNumber, TaskCode, Quantity, InvoiceValue, TaxValue, CashCode, TaxCode)
	SELECT     @CreditNumber AS InvoiceNumber, TaskCode, Quantity, InvoiceValue, TaxValue, CashCode, TaxCode
	FROM         Invoice.tbTask
	WHERE     (InvoiceNumber = @InvoiceNumber)

	SET @InvoiceNumber = @CreditNumber
	
	COMMIT TRAN Credit

	
	RETURN 
GO
CREATE PROCEDURE Invoice.proc_DefaultDocType
	(
		@InvoiceNumber NVARCHAR(20),
		@DocTypeCode SMALLINT OUTPUT
	)
AS
DECLARE @InvoiceType SMALLINT

	SELECT  @InvoiceType = InvoiceTypeCode
	FROM         Invoice.tbInvoice
	WHERE     (InvoiceNumber = @InvoiceNumber)
	
	SET @DocTypeCode = CASE @InvoiceType
							WHEN 1 THEN 5
							WHEN 2 THEN 6							
							WHEN 4 THEN 7
							ELSE 5
							END
							
	RETURN

GO
CREATE PROCEDURE Org.proc_PaymentPostPaidIn
	(
	@PaymentCode NVARCHAR(20),
	@CurrentBalance MONEY OUTPUT 
	)
 AS
--invoice VALUES
DECLARE @InvoiceNumber NVARCHAR(20)
DECLARE @TaskCode NVARCHAR(20)
DECLARE @TaxRate real
DECLARE @ItemValue MONEY

--calc VALUES
DECLARE @PaidValue MONEY
DECLARE @PaidTaxValue MONEY

--default payment codes
DECLARE @CashCode NVARCHAR(50)
DECLARE @TaxCode NVARCHAR(10)
DECLARE @TaxInValue MONEY
DECLARE @TaxOutValue MONEY

	SET @TaxInValue = 0
	SET @TaxOutValue = 0
	
	DECLARE curPaidIn CURSOR LOCAL FOR
		SELECT     Invoice.vwOutstanding.InvoiceNumber, Invoice.vwOutstanding.TaskCode, Invoice.vwOutstanding.CashCode, Invoice.vwOutstanding.TaxCode, 
		                      Invoice.vwOutstanding.TaxRate, Invoice.vwOutstanding.ItemValue
		FROM         Invoice.vwOutstanding INNER JOIN
		                      Org.tbPayment ON Invoice.vwOutstanding.AccountCode = Org.tbPayment.AccountCode
		WHERE     ( Org.tbPayment.PaymentCode = @PaymentCode)
		ORDER BY Invoice.vwOutstanding.CashModeCode, Invoice.vwOutstanding.CollectOn

	OPEN curPaidIn
	FETCH NEXT FROM curPaidIn INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue
	WHILE @@FETCH_STATUS = 0 and @CurrentBalance < 0
		BEGIN
		IF (@CurrentBalance + @ItemValue) > 0
			SET @ItemValue = @CurrentBalance * -1

		SET @PaidValue = Abs(@ItemValue) / (1 + @TaxRate)
		SET @PaidTaxValue = Abs(@ItemValue) - ROUND((Abs(@ItemValue) / (1 + @TaxRate)), 2)
				
		SET @CurrentBalance = @CurrentBalance + @ItemValue
		
		IF @TaskCode IS NULL
			BEGIN
			UPDATE    Invoice.tbItem
			SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (CashCode = @CashCode)
			END
		ELSE
			BEGIN
			UPDATE   Invoice.tbTask
			SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (TaskCode = @TaskCode)				
			END

		EXEC Invoice.proc_Total @InvoiceNumber
		        		  
		SET @TaxInValue = @TaxInValue + CASE WHEN @ItemValue > 0 THEN @PaidTaxValue ELSE 0 END
		SET @TaxOutValue = @TaxOutValue + CASE WHEN @ItemValue < 0 THEN @PaidTaxValue ELSE 0 END	
				
		FETCH NEXT FROM curPaidIn INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue
		END
	
	CLOSE curPaidIn
	DEALLOCATE curPaidIn
	
	--OUTPUT new org current balance
	IF @CurrentBalance >= 0
		SET @CurrentBalance = 0
	ELSE
		SET @CurrentBalance = @CurrentBalance * -1

	
	IF NOT @CashCode IS NULL
		BEGIN
		UPDATE    Org.tbPayment
		SET      PaymentStatusCode = 2, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
			CashCode = ISNULL(@CashCode, Org.tbPayment.CashCode), 
			TaxCode = ISNULL(@TaxCode, Org.tbPayment.TaxCode)
		WHERE     (PaymentCode = @PaymentCode)
		END

			
	RETURN

GO
CREATE PROCEDURE Org.proc_PaymentPostPaidOut
	(
	@PaymentCode NVARCHAR(20),
	@CurrentBalance MONEY OUTPUT 
	)
 AS
--invoice VALUES
DECLARE @InvoiceNumber NVARCHAR(20)
DECLARE @TaskCode NVARCHAR(20)
DECLARE @TaxRate real
DECLARE @ItemValue MONEY

--calc VALUES
DECLARE @PaidValue MONEY
DECLARE @PaidTaxValue MONEY

--default payment codes
DECLARE @CashCode NVARCHAR(50)
DECLARE @TaxCode NVARCHAR(10)
DECLARE @TaxInValue MONEY
DECLARE @TaxOutValue MONEY

	SET @TaxInValue = 0
	SET @TaxOutValue = 0
	
	DECLARE curPaidOut CURSOR LOCAL FOR
		SELECT     Invoice.vwOutstanding.InvoiceNumber, Invoice.vwOutstanding.TaskCode, Invoice.vwOutstanding.CashCode, Invoice.vwOutstanding.TaxCode, 
		                      Invoice.vwOutstanding.TaxRate, Invoice.vwOutstanding.ItemValue
		FROM         Invoice.vwOutstanding INNER JOIN
		                      Org.tbPayment ON Invoice.vwOutstanding.AccountCode = Org.tbPayment.AccountCode
		WHERE     ( Org.tbPayment.PaymentCode = @PaymentCode)
		ORDER BY Invoice.vwOutstanding.CashModeCode DESC, Invoice.vwOutstanding.CollectOn

	OPEN curPaidOut
	FETCH NEXT FROM curPaidOut INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue
	WHILE @@FETCH_STATUS = 0 and @CurrentBalance > 0
		BEGIN
		IF (@CurrentBalance + @ItemValue) < 0
			SET @ItemValue = @CurrentBalance * -1

		SET @PaidValue = Abs(@ItemValue) / (1 + @TaxRate)
		SET @PaidTaxValue = Abs(@ItemValue) - ROUND((Abs(@ItemValue) / (1 + @TaxRate)), 2)
				
		SET @CurrentBalance = @CurrentBalance + @ItemValue
		
		IF @TaskCode IS NULL
			BEGIN
			UPDATE    Invoice.tbItem
			SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (CashCode = @CashCode)
			END
		ELSE
			BEGIN
			UPDATE   Invoice.tbTask
			SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (TaskCode = @TaskCode)				
			END

		EXEC Invoice.proc_Total @InvoiceNumber
		        		  
		SET @TaxInValue = @TaxInValue + CASE WHEN @ItemValue > 0 THEN @PaidTaxValue ELSE 0 END
		SET @TaxOutValue = @TaxOutValue + CASE WHEN @ItemValue < 0 THEN @PaidTaxValue ELSE 0 END	
				
		FETCH NEXT FROM curPaidOut INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue
		END
		
	CLOSE curPaidOut
	DEALLOCATE curPaidOut
	
	--OUTPUT new org current balance
	IF @CurrentBalance <= 0
		SET @CurrentBalance = 0
	ELSE
		SET @CurrentBalance = @CurrentBalance * -1

	IF NOT @CashCode IS NULL
		BEGIN
		UPDATE    Org.tbPayment
		SET      PaymentStatusCode = 2, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
			CashCode = ISNULL(@CashCode, Org.tbPayment.CashCode), 
			TaxCode = ISNULL(@TaxCode, Org.tbPayment.TaxCode)
		WHERE     (PaymentCode = @PaymentCode)
		END
	
	RETURN

GO
CREATE PROCEDURE Org.proc_PaymentPostInvoiced
	(
	@PaymentCode NVARCHAR(20) 
	)
  AS
DECLARE @AccountCode NVARCHAR(10)
DECLARE @CashModeCode SMALLINT
DECLARE @CurrentBalance MONEY
DECLARE @PaidValue MONEY
DECLARE @PostValue MONEY

	SELECT   @PaidValue = CASE WHEN PaidInValue = 0 THEN PaidOutValue ELSE PaidInValue END,
		@CurrentBalance = Org.tbOrg.CurrentBalance,
		@AccountCode = Org.tbOrg.AccountCode,
		@CashModeCode = CASE WHEN PaidInValue = 0 THEN 1 ELSE 2 END
	FROM         Org.tbPayment INNER JOIN
	                      Org.tbOrg ON Org.tbPayment.AccountCode = Org.tbOrg.AccountCode
	WHERE     ( Org.tbPayment.PaymentCode = @PaymentCode)
	
	IF @CashModeCode = 2
		BEGIN
		SET @PostValue = @PaidValue
		SET @PaidValue = (@PaidValue + @CurrentBalance) * -1			
		EXEC Org.proc_PaymentPostPaidIn @PaymentCode, @PaidValue OUTPUT
		END
	ELSE
		BEGIN
		SET @PostValue = @PaidValue * -1
		SET @PaidValue = @PaidValue + (@CurrentBalance * -1)			
		EXEC Org.proc_PaymentPostPaidOut @PaymentCode, @PaidValue OUTPUT
		END

	UPDATE Org.tbOrg
	SET CurrentBalance = @PaidValue
	WHERE AccountCode = @AccountCode

	UPDATE  Org.tbAccount
	SET CurrentBalance = Org.tbAccount.CurrentBalance + @PostValue
	FROM         Org.tbAccount INNER JOIN
						  Org.tbPayment ON Org.tbAccount.CashAccountCode = Org.tbPayment.CashAccountCode
	WHERE Org.tbPayment.PaymentCode = @PaymentCode
		
	RETURN
GO
CREATE PROCEDURE Invoice.proc_Pay
	(
	@InvoiceNumber NVARCHAR(20),
	@Now DATETIME
	)
AS
DECLARE @PaidOut MONEY
DECLARE @PaidIn MONEY
DECLARE @TaskOutstanding MONEY
DECLARE @ItemOutstanding MONEY
DECLARE @CashModeCode SMALLINT
DECLARE @CashCode NVARCHAR(50)

DECLARE @AccountCode NVARCHAR(10)
DECLARE @CashAccountCode NVARCHAR(10)
DECLARE @UserId NVARCHAR(10)
DECLARE @PaymentCode NVARCHAR(20)

	SELECT @UserId = UserId FROM Usr.vwCredentials
	
	SET @PaymentCode = @UserId + '_' + FORMAT(Year(@Now), '0000')
		+ FORMAT(Month(@Now), '00')
		+ FORMAT(DAY(@Now), '00')
		+ FORMAT(DatePart(hh, @Now), '00')
		+ FORMAT(DatePart(n, @Now), '00')
		+ FORMAT(DatePart(s, @Now), '00')
	
	WHILE EXISTS (SELECT PaymentCode FROM Org.tbPayment WHERE PaymentCode = @PaymentCode)
		BEGIN
		SET @Now = DATEADD(s, 1, @Now)
		SET @PaymentCode = @UserId + '_' + FORMAT(Year(@Now), '0000')
			+ FORMAT(Month(@Now), '00')
			+ FORMAT(DAY(@Now), '00')
			+ FORMAT(DatePart(hh, @Now), '00')
			+ FORMAT(DatePart(n, @Now), '00')
			+ FORMAT(DatePart(s, @Now), '00')
		END
		
	SELECT @CashModeCode = Invoice.tbType.CashModeCode, @AccountCode = Invoice.tbInvoice.AccountCode
	FROM Invoice.tbInvoice INNER JOIN Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	WHERE     ( Invoice.tbInvoice.InvoiceNumber = @InvoiceNumber)
	
	SELECT  @TaskOutstanding = SUM( Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue - Invoice.tbTask.PaidValue + Invoice.tbTask.PaidTaxValue),
		@CashCode = MIN( Invoice.tbTask.CashCode)	                      
	FROM         Invoice.tbInvoice INNER JOIN
	                      Invoice.tbTask ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbTask.InvoiceNumber INNER JOIN
	                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	WHERE     ( Invoice.tbInvoice.InvoiceNumber = @InvoiceNumber)
	GROUP BY Invoice.tbType.CashModeCode


	SELECT @ItemOutstanding = SUM( Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue - Invoice.tbItem.PaidValue + Invoice.tbItem.PaidTaxValue)
	FROM         Invoice.tbInvoice INNER JOIN
	                      Invoice.tbItem ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbItem.InvoiceNumber
	WHERE     ( Invoice.tbInvoice.InvoiceNumber = @InvoiceNumber)
	
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
		SELECT TOP 1 @CashAccountCode = Org.tbAccount.CashAccountCode
		FROM         Org.tbAccount INNER JOIN
		                      Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
		WHERE     ( Org.tbAccount.AccountClosed = 0)
		GROUP BY Org.tbAccount.CashAccountCode
		
		INSERT INTO Org.tbPayment
							  (PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, PaidOn, PaidInValue, PaidOutValue, PaymentReference)
		VALUES     (@PaymentCode,@UserId, 1,@AccountCode,@CashAccountCode,@CashCode,@Now,@PaidIn,@PaidOut,@InvoiceNumber)		
		
		EXEC Org.proc_PaymentPostInvoiced @PaymentCode			
		END
		
	RETURN
GO
CREATE PROCEDURE Invoice.proc_Raise
	(
	@TaskCode NVARCHAR(20),
	@InvoiceTypeCode SMALLINT,
	@InvoicedOn DATETIME,
	@InvoiceNumber NVARCHAR(20) = null OUTPUT
	)
AS
DECLARE @UserId NVARCHAR(10)
DECLARE @NextNumber INT
DECLARE @InvoiceSuffix NVARCHAR(4)
DECLARE @PaymentDays SMALLINT
DECLARE @CollectOn DATETIME
DECLARE @AccountCode NVARCHAR(10)

	SET @InvoicedOn = ISNULL(@InvoicedOn, SYSDATETIME())
	
	SELECT @UserId = UserId FROM Usr.vwCredentials

	SET @InvoiceSuffix = '.' + @UserId
	
	SELECT @NextNumber = NextNumber
	FROM Invoice.tbType
	WHERE InvoiceTypeCode = @InvoiceTypeCode
	
	SELECT @InvoiceNumber = FORMAT(@NextNumber, '000000') + @InvoiceSuffix
	
	WHILE EXISTS (SELECT     InvoiceNumber
	              FROM         Invoice.tbInvoice
	              WHERE     (InvoiceNumber = @InvoiceNumber))
		BEGIN
		SET @NextNumber = @NextNumber + 1
		SET @InvoiceNumber = FORMAT(@NextNumber, '000000') + @InvoiceSuffix
		END

	SELECT @PaymentDays = Org.tbOrg.PaymentDays, @AccountCode = Org.tbOrg.AccountCode
	FROM         Task.tbTask INNER JOIN
	                      Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode
	WHERE     ( Task.tbTask.TaskCode = @TaskCode)		
	
	SET @CollectOn = Task.fnDefaultPaymentOn(@AccountCode, @InvoicedOn)
	
	BEGIN TRAN Invoice
	
	EXEC Invoice.proc_Cancel
	
	UPDATE    Invoice.tbType
	SET              NextNumber = @NextNumber + 1
	WHERE     (InvoiceTypeCode = @InvoiceTypeCode)
	
	INSERT INTO Invoice.tbInvoice
						(InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoicedOn, CollectOn, InvoiceStatusCode, PaymentTerms)
	SELECT     @InvoiceNumber AS InvoiceNumber, @UserId AS UserId, Task.tbTask.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, @InvoicedOn AS InvoicedOn, 
						@CollectOn AS CollectOn, 1 AS InvoiceStatusCode, 
						Org.tbOrg.PaymentTerms
	FROM         Task.tbTask INNER JOIN
						Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode
	WHERE     ( Task.tbTask.TaskCode = @TaskCode)

	EXEC Invoice.proc_AddTask @InvoiceNumber, @TaskCode
	
	UPDATE    Task.tbTask
	SET              ActionedOn = SYSDATETIME()
	WHERE     (TaskCode = @TaskCode) AND (ActionedOn IS NULL)

	COMMIT TRAN Invoice
	
	RETURN
GO
CREATE PROCEDURE Invoice.proc_RaiseBlank
	(
	@AccountCode NVARCHAR(10),
	@InvoiceTypeCode SMALLINT,
	@InvoiceNumber NVARCHAR(20) = null OUTPUT
	)
  AS
DECLARE @UserId NVARCHAR(10)
DECLARE @NextNumber INT
DECLARE @InvoiceSuffix NVARCHAR(4)

	SELECT @UserId = UserId FROM Usr.vwCredentials

	SET @InvoiceSuffix = '.' + @UserId
	
	SELECT @NextNumber = NextNumber
	FROM Invoice.tbType
	WHERE InvoiceTypeCode = @InvoiceTypeCode
	
	SELECT @InvoiceNumber = FORMAT(@NextNumber, '000000') + @InvoiceSuffix
	
	WHILE EXISTS (SELECT     InvoiceNumber
	              FROM         Invoice.tbInvoice
	              WHERE     (InvoiceNumber = @InvoiceNumber))
		BEGIN
		SET @NextNumber = @NextNumber + 1
		SET @InvoiceNumber = FORMAT(@NextNumber, '000000') + @InvoiceSuffix
		END
		
	BEGIN TRAN InvoiceBlank
	
	EXEC Invoice.proc_Cancel
	
	UPDATE    Invoice.tbType
	SET              NextNumber = @NextNumber + 1
	WHERE     (InvoiceTypeCode = @InvoiceTypeCode)
	
	INSERT INTO Invoice.tbInvoice
	                      (InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoicedOn, InvoiceStatusCode)
	VALUES     (@InvoiceNumber, @UserId, @AccountCode, @InvoiceTypeCode, SYSDATETIME(), 1)

	
	COMMIT TRAN InvoiceBlank
	
	RETURN
GO
CREATE PROCEDURE Usr.proc_MenuInsert
	(
		@MenuName NVARCHAR(50),
		@FromMenuId SMALLINT = 0,
		@MenuId SMALLINT = null OUTPUT
	)
     AS

	BEGIN TRAN trnMenu
	
	INSERT INTO Usr.tbMenu (MenuName) VALUES (@MenuName)
	SELECT @MenuId = @@IDENTITY
	
	IF @FromMenuId = 0
		BEGIN
		INSERT INTO Usr.tbMenuEntry (MenuId, FolderId, ItemId, ItemText, Command,  Argument)
				VALUES (@MenuId, 1, 0, @MenuName, 0, 'Root')
		END
	ELSE
		BEGIN
		INSERT INTO Usr.tbMenuEntry
		                      (MenuId, FolderId, ItemId, OpenMode, Argument, ProjectName, Command, ItemText)
		SELECT     @MenuId AS ToMenuId, FolderId, ItemId, OpenMode, Argument, ProjectName, Command, ItemText
		FROM         Usr.tbMenuEntry
		WHERE     (MenuId = @FromMenuId)
		END
	COMMIT TRAN trnMenu

	RETURN 
GO
CREATE PROCEDURE Org.proc_NextAddressCode 
	(
	@AccountCode NVARCHAR(10),
	@AddressCode NVARCHAR(15) OUTPUT
	)
  AS
DECLARE @AddCount INT

	SELECT @AddCount = COUNT(AddressCode) 
	FROM         Org.tbAddress
	WHERE     (AccountCode = @AccountCode)
	
	SET @AddCount = @AddCount + 1
	SET @AddressCode = upper(@AccountCode) + '_' + stuff('000', 4 - LEN(ltrim(str(@AddCount))), LEN(ltrim(str(@AddCount))), @AddCount)
	
	RETURN
GO
CREATE PROCEDURE Org.proc_AddAddress 
	(
	@AccountCode NVARCHAR(10),
	@Address NTEXT
	)
  AS
DECLARE @AddressCode NVARCHAR(15)
DECLARE @RC INT
	
	EXECUTE @RC = Org.proc_NextAddressCode @AccountCode, @AddressCode OUTPUT
	
	INSERT INTO Org.tbAddress
	                      (AddressCode, AccountCode, Address)
	VALUES     (@AddressCode, @AccountCode, @Address)
	
	RETURN
GO
CREATE PROCEDURE Org.proc_ContactFileAs 
	(
	@ContactName NVARCHAR(100),
	@FileAs NVARCHAR(100) OUTPUT
	)
  AS

	IF CHARINDEX(' ', @ContactName) = 0
		SET @FileAs = @ContactName
	ELSE
		BEGIN
		DECLARE @FirstNames NVARCHAR(100)
		DECLARE @LastName NVARCHAR(100)
		DECLARE @LastWordPos INT
		
		SET @LastWordPos = CHARINDEX(' ', @ContactName) + 1
		WHILE CHARINDEX(' ', @ContactName, @LastWordPos) != 0
			SET @LastWordPos = CHARINDEX(' ', @ContactName, @LastWordPos) + 1
		
		SET @FirstNames = left(@ContactName, @LastWordPos - 2)
		SET @LastName = right(@ContactName, LEN(@ContactName) - @LastWordPos + 1)
		SET @FileAs = @LastName + ', ' + @FirstNames
		END

	RETURN
GO
CREATE PROCEDURE Org.proc_AddContact 
	(
	@AccountCode NVARCHAR(10),
	@ContactName NVARCHAR(100)	 
	)
  AS
DECLARE @FileAs NVARCHAR(10)
DECLARE @RC INT
	
	EXECUTE @RC = Org.proc_ContactFileAs @ContactName, @FileAs OUTPUT	
	
	INSERT INTO Org.tbContact
	                      (AccountCode, ContactName, FileAs, PhoneNumber, EmailAddress)
	SELECT     AccountCode, @ContactName AS ContactName, @FileAs, PhoneNumber, EmailAddress
	FROM         Org.tbOrg
	WHERE AccountCode = @AccountCode
	
	RETURN
GO
CREATE PROCEDURE Org.proc_BalanceOutstanding 
	(
	@AccountCode NVARCHAR(10),
	@Balance MONEY = 0 OUTPUT
	)
  AS

	IF EXISTS(SELECT     Invoice.tbInvoice.AccountCode
	          FROM         Invoice.tbInvoice INNER JOIN
	                                Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	          WHERE     ( Invoice.tbInvoice.AccountCode = @AccountCode) AND ( Invoice.tbInvoice.InvoiceStatusCode > 1 AND Invoice.tbInvoice.InvoiceStatusCode < 4)
	          GROUP BY Invoice.tbInvoice.AccountCode)
		BEGIN
		SELECT @Balance = Balance
		FROM         Org.vwBalanceOutstanding
		WHERE     (AccountCode = @AccountCode)		
		END
	ELSE
		SET @Balance = 0
		
	IF EXISTS(SELECT     AccountCode
	          FROM         Org.tbPayment
	          WHERE     (PaymentStatusCode = 1) AND (AccountCode = @AccountCode)) AND (@Balance <> 0)
		BEGIN
		SELECT  @Balance = @Balance - SUM(PaidInValue - PaidOutValue) 
		FROM         Org.tbPayment
		WHERE     (PaymentStatusCode = 1) AND (AccountCode = @AccountCode)		
		END
		
	SELECT    @Balance = ISNULL(@Balance, 0) - CurrentBalance
	FROM         Org.tbOrg
	WHERE     (AccountCode = @AccountCode)
		
	RETURN
GO
CREATE PROCEDURE Org.proc_DefaultAccountCode 
	(
	@AccountName NVARCHAR(100),
	@AccountCode NVARCHAR(10) OUTPUT 
	)
  AS
DECLARE @ParsedName NVARCHAR(100)
DECLARE @FirstWord NVARCHAR(100)
DECLARE @SecondWord NVARCHAR(100)
DECLARE @ValidatedCode NVARCHAR(10)

DECLARE @c char(1)
DECLARE @ASCII SMALLINT
DECLARE @pos INT
DECLARE @ok BIT

DECLARE @Suffix SMALLINT
DECLARE @Rows INT
		
	SET @pos = 1
	SET @ParsedName = ''

	WHILE @pos <= DATALENGTH(@AccountName)
	BEGIN
		SET @ASCII = ASCII(SUBSTRING(@AccountName, @pos, 1))
		SET @ok = CASE 
			WHEN @ASCII = 32 then 1
			WHEN @ASCII = 45 then 1
			WHEN (@ASCII >= 48 and @ASCII <= 57) then 1
			WHEN (@ASCII >= 65 and @ASCII <= 90) then 1
			WHEN (@ASCII >= 97 and @ASCII <= 122) then 1
			ELSE 0
		END
		IF @ok = 1
			SELECT @ParsedName = @ParsedName + char(ASCII(SUBSTRING(@AccountName, @pos, 1)))
		SET @pos = @pos + 1
	END

	print @ParsedName
		
	IF CHARINDEX(' ', @ParsedName) = 0
		BEGIN
		SET @FirstWord = @ParsedName
		SET @SecondWord = ''
		END
	ELSE
		BEGIN
		SET @FirstWord = left(@ParsedName, CHARINDEX(' ', @ParsedName) - 1)
		SET @SecondWord = right(@ParsedName, LEN(@ParsedName) - CHARINDEX(' ', @ParsedName))
		IF CHARINDEX(' ', @SecondWord) > 0
			SET @SecondWord = left(@SecondWord, CHARINDEX(' ', @SecondWord) - 1)
		END

	IF EXISTS(SELECT ExcludedTag FROM App.tbCodeExclusion WHERE ExcludedTag = @SecondWord)
		BEGIN
		SET @SecondWord = ''
		END

	--print @FirstWord
	--print @SecondWord

	IF LEN(@SecondWord) > 0
		SET @AccountCode = upper(left(@FirstWord, 3)) + upper(left(@SecondWord, 3))		
	ELSE
		SET @AccountCode = upper(left(@FirstWord, 6))

	SET @ValidatedCode = @AccountCode
	SELECT @rows = count(AccountCode) FROM Org.tbOrg WHERE AccountCode = @ValidatedCode
	SET @Suffix = 0
	
	WHILE @rows > 0
	BEGIN
		SET @Suffix = @Suffix + 1
		SET @ValidatedCode = @AccountCode + ltrim(str(@Suffix))
		SELECT @rows = count(AccountCode) FROM Org.tbOrg WHERE AccountCode = @ValidatedCode
	END
	
	SET @AccountCode = @ValidatedCode
	
	RETURN
GO
CREATE PROCEDURE Org.proc_DefaultTaxCode 
	(
	@AccountCode NVARCHAR(10),
	@TaxCode NVARCHAR(10) OUTPUT
	)
  AS
	IF EXISTS(SELECT     Org.tbOrg.AccountCode
	          FROM         Org.tbOrg INNER JOIN
	                                App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode)
		BEGIN
		SELECT @TaxCode = Org.tbOrg.TaxCode
	          FROM         Org.tbOrg INNER JOIN
	                                App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode
		
		END	                              
	RETURN
GO
CREATE PROCEDURE Org.proc_Rebuild
	(
		@AccountCode NVARCHAR(10)
	)
 AS
DECLARE @PaidBalance MONEY
DECLARE @InvoicedBalance MONEY
DECLARE @Balance MONEY

DECLARE @CashModeCode SMALLINT	

DECLARE @InvoiceNumber NVARCHAR(20)
DECLARE @TaskCode NVARCHAR(20)
DECLARE @CashCode NVARCHAR(50)
DECLARE @InvoiceValue MONEY
DECLARE @TaxValue MONEY	

DECLARE @PaidValue MONEY
DECLARE @PaidInvoiceValue MONEY
DECLARE @PaidTaxValue MONEY
DECLARE @TaxRate FLOAT	

	BEGIN TRAN OrgRebuild
		
	UPDATE Invoice.tbItem
	SET TaxValue = ROUND( Invoice.tbItem.InvoiceValue * App.vwTaxRates.TaxRate, 2),
		PaidValue = Invoice.tbItem.InvoiceValue, 
		PaidTaxValue = ROUND( Invoice.tbItem.InvoiceValue * App.vwTaxRates.TaxRate, 2)				
	FROM         Invoice.tbItem INNER JOIN
	                      App.vwTaxRates ON Invoice.tbItem.TaxCode = App.vwTaxRates.TaxCode INNER JOIN
	                      Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
	WHERE     ( Invoice.tbInvoice.AccountCode = @AccountCode) AND ( Invoice.tbInvoice.InvoiceStatusCode <> 1)	
                      
	UPDATE Invoice.tbTask
	SET TaxValue = ROUND( Invoice.tbTask.InvoiceValue * App.vwTaxRates.TaxRate, 2),
		PaidValue = Invoice.tbTask.InvoiceValue, PaidTaxValue = ROUND( Invoice.tbTask.InvoiceValue * App.vwTaxRates.TaxRate, 2)
	FROM         Invoice.tbTask INNER JOIN
	                      App.vwTaxRates ON Invoice.tbTask.TaxCode = App.vwTaxRates.TaxCode INNER JOIN
	                      Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
	WHERE     ( Invoice.tbInvoice.AccountCode = @AccountCode) AND ( Invoice.tbInvoice.InvoiceStatusCode <> 1)	
	
	UPDATE Invoice.tbInvoice
	SET InvoiceValue = 0, TaxValue = 0
	WHERE Invoice.tbInvoice.AccountCode = @AccountCode
	
	UPDATE Invoice.tbInvoice
	SET InvoiceValue = fnOrgRebuildInvoiceItems.TotalInvoiceValue, 
		TaxValue = fnOrgRebuildInvoiceItems.TotalTaxValue
	FROM         Invoice.tbInvoice INNER JOIN
	                      Org.fnRebuildInvoiceItems(@AccountCode) fnOrgRebuildInvoiceItems 
	                      ON Invoice.tbInvoice.InvoiceNumber = fnOrgRebuildInvoiceItems.InvoiceNumber	
	
	UPDATE Invoice.tbInvoice
	SET InvoiceValue = InvoiceValue + fnOrgRebuildInvoiceTasks.TotalInvoiceValue, 
		TaxValue = TaxValue + fnOrgRebuildInvoiceTasks.TotalTaxValue
	FROM         Invoice.tbInvoice INNER JOIN
	                      Org.fnRebuildInvoiceTasks(@AccountCode) fnOrgRebuildInvoiceTasks 
	                      ON Invoice.tbInvoice.InvoiceNumber = fnOrgRebuildInvoiceTasks.InvoiceNumber
			
	UPDATE    Invoice.tbInvoice
	SET              PaidValue = InvoiceValue, PaidTaxValue = TaxValue, InvoiceStatusCode = 4
	WHERE     (AccountCode = @AccountCode) AND (InvoiceStatusCode <> 1)		

	
	UPDATE Org.tbPayment
	SET
		TaxInValue = PaidInValue - ROUND((PaidInValue / (1 + TaxRate)), 2), 
		TaxOutValue = PaidOutValue - ROUND((PaidOutValue / (1 + TaxRate)), 2)
	FROM         Org.tbPayment INNER JOIN
	                      App.vwTaxRates ON Org.tbPayment.TaxCode = App.vwTaxRates.TaxCode
	WHERE     ( Org.tbPayment.AccountCode = @AccountCode)
		

	SELECT  @PaidBalance = SUM(CASE WHEN PaidInValue > 0 THEN PaidInValue * -1 ELSE PaidOutValue  END)
	FROM         Org.tbPayment
	WHERE     (AccountCode = @AccountCode) And (PaymentStatusCode <> 1)
	
	SELECT @PaidBalance = ISNULL(@PaidBalance, 0) + OpeningBalance
	FROM Org.tbOrg
	WHERE     (AccountCode = @AccountCode)

	SELECT @InvoicedBalance = SUM(CASE Invoice.tbType.CashModeCode WHEN 1 THEN (InvoiceValue + TaxValue) * - 1 WHEN 2 THEN InvoiceValue + TaxValue ELSE 0 END) 
	FROM         Invoice.tbInvoice INNER JOIN
	                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	WHERE     ( Invoice.tbInvoice.AccountCode = @AccountCode)
	
	SET @Balance = ISNULL(@PaidBalance, 0) + ISNULL(@InvoicedBalance, 0)
                      
    SET @CashModeCode = CASE WHEN @Balance > 0 THEN 2 ELSE 1 END
	SET @Balance = Abs(@Balance)	

	DECLARE curInv CURSOR LOCAL FOR
		SELECT     InvoiceNumber, TaskCode, CashCode, InvoiceValue, TaxValue
		FROM  Org.vwRebuildInvoices
		WHERE     (AccountCode = @AccountCode) And (CashModeCode = @CashModeCode)
		ORDER BY CollectOn DESC
	

	OPEN curInv
	FETCH NEXT FROM curInv INTO @InvoiceNumber, @TaskCode, @CashCode, @InvoiceValue, @TaxValue
	WHILE @@FETCH_STATUS = 0 And (@Balance > 0)
		BEGIN

		IF (@Balance - (@InvoiceValue + @TaxValue)) < 0
			BEGIN
			SET @PaidValue = (@InvoiceValue + @TaxValue) - @Balance
			SET @Balance = 0	
			END
		ELSE
			BEGIN
			SET @PaidValue = 0
			SET @Balance = @Balance - (@InvoiceValue + @TaxValue)
			END
		
		IF @PaidValue > 0
			BEGIN
			SET @TaxRate = @TaxValue / @InvoiceValue
			SET @PaidInvoiceValue = @PaidValue - (@PaidValue - ROUND((@PaidValue / (1 + @TaxRate)), 2))
			SET @PaidTaxValue = ROUND(@PaidInvoiceValue * @TaxRate, 2)
			END
		ELSE
			BEGIN
			SET @PaidInvoiceValue = 0
			SET @PaidTaxValue = 0
			END
			
		IF ISNULL(@TaskCode, '') = ''
			BEGIN
			UPDATE    Invoice.tbItem
			SET              PaidValue = @PaidInvoiceValue, PaidTaxValue = @PaidTaxValue
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (CashCode = @CashCode)
			END
		ELSE
			BEGIN
			UPDATE   Invoice.tbTask
			SET              PaidValue = @PaidInvoiceValue, PaidTaxValue = @PaidTaxValue
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (TaskCode = @TaskCode)				
			END

		FETCH NEXT FROM curInv INTO @InvoiceNumber, @TaskCode, @CashCode, @InvoiceValue, @TaxValue
		END
	
	CLOSE curInv
	DEALLOCATE curInv
	
	UPDATE Invoice.tbInvoice
	SET InvoiceStatusCode = 3,
		PaidValue = Org.vwRebuildInvoiceTotals.TotalPaidValue, 
		PaidTaxValue = Org.vwRebuildInvoiceTotals.TotalPaidTaxValue
	FROM         Invoice.tbInvoice INNER JOIN
						Org.vwRebuildInvoiceTotals ON Invoice.tbInvoice.InvoiceNumber = Org.vwRebuildInvoiceTotals.InvoiceNumber
	WHERE     (Org.vwRebuildInvoiceTotals.AccountCode = @AccountCode) AND 
						((Org.vwRebuildInvoiceTotals.TotalInvoiceValue + Org.vwRebuildInvoiceTotals.TotalTaxValue) 
						- (Org.vwRebuildInvoiceTotals.TotalPaidValue + Org.vwRebuildInvoiceTotals.TotalPaidTaxValue) > 0) AND 
						(Org.vwRebuildInvoiceTotals.TotalPaidValue + Org.vwRebuildInvoiceTotals.TotalPaidTaxValue < Org.vwRebuildInvoiceTotals.TotalInvoiceValue + Org.vwRebuildInvoiceTotals.TotalTaxValue)
	
	UPDATE Invoice.tbInvoice
	SET InvoiceStatusCode = 2,
		PaidValue = 0, 
		PaidTaxValue = 0
	FROM         Invoice.tbInvoice INNER JOIN
	                      Org.vwRebuildInvoiceTotals ON Invoice.tbInvoice.InvoiceNumber = Org.vwRebuildInvoiceTotals.InvoiceNumber
	WHERE     (Org.vwRebuildInvoiceTotals.AccountCode = @AccountCode) AND 
	                      (Org.vwRebuildInvoiceTotals.TotalPaidValue + Org.vwRebuildInvoiceTotals.TotalPaidTaxValue = 0) AND 
	                      (Org.vwRebuildInvoiceTotals.TotalInvoiceValue + Org.vwRebuildInvoiceTotals.TotalTaxValue > 0)
	
	
	IF (@CashModeCode = 2)
		SET @Balance = @Balance * -1
		
	UPDATE    Org.tbOrg
	SET              CurrentBalance = OpeningBalance - @Balance
	WHERE     (AccountCode = @AccountCode)
	
	COMMIT TRAN OrgRebuild
	

	RETURN 

GO
CREATE PROCEDURE Org.proc_Statement
	(
	@AccountCode NVARCHAR(10)
	)
  AS
DECLARE @FromDate DATETIME
	
	SELECT @FromDate = DATEADD(d, StatementDays * -1, SYSDATETIME())
	FROM         Org.tbOrg
	WHERE     (AccountCode = @AccountCode)
	
	SELECT     TransactedOn, OrderBy, Reference, StatementType, Charge, Balance
	FROM         Org.fnStatement(@AccountCode) fnOrgStatement
	WHERE     (TransactedOn >= @FromDate)
	ORDER BY TransactedOn, OrderBy
	
	RETURN 
GO
CREATE PROCEDURE Org.proc_PaymentDelete
	(
	@PaymentCode NVARCHAR(20)
	)
 AS
DECLARE @AccountCode NVARCHAR(10)
DECLARE @CashAccountCode NVARCHAR(10)

	SELECT  @AccountCode = AccountCode, @CashAccountCode = CashAccountCode
	FROM         Org.tbPayment
	WHERE     (PaymentCode = @PaymentCode)

	DELETE FROM Org.tbPayment
	WHERE     (PaymentCode = @PaymentCode)
	
	EXEC Org.proc_Rebuild @AccountCode
	EXEC Cash.proc_AccountRebuild @CashAccountCode
	

	RETURN 
GO
CREATE PROCEDURE Org.proc_PaymentMove
	(
	@PaymentCode NVARCHAR(20),
	@CashAccountCode NVARCHAR(10)
	)
  AS
DECLARE @OldAccountCode NVARCHAR(10)

	SELECT @OldAccountCode = CashAccountCode
	FROM         Org.tbPayment
	WHERE     (PaymentCode = @PaymentCode)
	
	BEGIN TRAN
	
	UPDATE Org.tbPayment 
	SET CashAccountCode = @CashAccountCode,
		UpdatedOn = SYSDATETIME(),
		UpdatedBy = (SUSER_SNAME())
	WHERE PaymentCode = @PaymentCode	

	EXEC Cash.proc_AccountRebuild @CashAccountCode
	EXEC Cash.proc_AccountRebuild @OldAccountCode
	
	COMMIT TRAN
	
	RETURN 
GO
CREATE PROCEDURE Org.proc_PaymentPostMisc
	(
	@PaymentCode NVARCHAR(20) 
	)
 AS
DECLARE @InvoiceNumber NVARCHAR(20)
DECLARE @UserId NVARCHAR(10)
DECLARE @NextNumber INT
DECLARE @InvoiceSuffix NVARCHAR(4)
DECLARE @InvoiceTypeCode SMALLINT

	SELECT @InvoiceTypeCode = CASE WHEN PaidInValue != 0 THEN 1 ELSE 3 END 
	FROM         Org.tbPayment
	WHERE     (PaymentCode = @PaymentCode)

	SELECT @UserId = UserId FROM Usr.vwCredentials

	SET @InvoiceSuffix = '.' + @UserId
	
	SELECT @NextNumber = NextNumber
	FROM Invoice.tbType
	WHERE InvoiceTypeCode = @InvoiceTypeCode
	
	SELECT @InvoiceNumber = FORMAT(@NextNumber, '000000') + @InvoiceSuffix
	
	WHILE EXISTS (SELECT     InvoiceNumber
	              FROM         Invoice.tbInvoice
	              WHERE     (InvoiceNumber = @InvoiceNumber))
		BEGIN
		SET @NextNumber = @NextNumber + 1
		SET @InvoiceNumber = FORMAT(@NextNumber, '000000') + @InvoiceSuffix
		END
		
	
	UPDATE    Invoice.tbType
	SET              NextNumber = @NextNumber + 1
	WHERE     (InvoiceTypeCode = @InvoiceTypeCode)

	INSERT INTO Invoice.tbInvoice
							 (InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, CollectOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, Printed)
	SELECT        @InvoiceNumber AS InvoiceNumber, Org.tbPayment.UserId, Org.tbPayment.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, 4 AS InvoiceStatusCode, 
							 Org.tbPayment.PaidOn, Org.tbPayment.PaidOn AS CollectOn, CASE WHEN PaidInValue > 0 THEN Org.tbPayment.PaidInValue / (1 + App.vwTaxRates.TaxRate) 
							 WHEN PaidOutValue > 0 THEN Org.tbPayment.PaidOutValue / (1 + App.vwTaxRates.TaxRate) END AS InvoiceValue, 
							 CASE WHEN Org.tbPayment.PaidInValue > 0 THEN Org.tbPayment.PaidInValue - ROUND(( Org.tbPayment.PaidInValue / (1 + App.vwTaxRates.TaxRate)), 2) 
							 WHEN Org.tbPayment.PaidOutValue > 0 THEN Org.tbPayment.PaidOutValue - ROUND(( Org.tbPayment.PaidOutValue / (1 + App.vwTaxRates.TaxRate)), 2) 
							 END AS TaxValue, CASE WHEN Org.tbPayment.PaidInValue > 0 THEN Org.tbPayment.PaidInValue / (1 + App.vwTaxRates.TaxRate) 
							 WHEN PaidOutValue > 0 THEN Org.tbPayment.PaidOutValue / (1 + App.vwTaxRates.TaxRate) END AS PaidValue, 
							 CASE WHEN Org.tbPayment.PaidInValue > 0 THEN Org.tbPayment.PaidInValue - ROUND(( Org.tbPayment.PaidInValue / (1 + App.vwTaxRates.TaxRate)), 2) 
							 WHEN Org.tbPayment.PaidOutValue > 0 THEN Org.tbPayment.PaidOutValue - ROUND(( Org.tbPayment.PaidOutValue / (1 + App.vwTaxRates.TaxRate)), 2) 
							 END AS PaidTaxValue, 1 AS Printed
	FROM            Org.tbPayment INNER JOIN
							 App.vwTaxRates ON Org.tbPayment.TaxCode = App.vwTaxRates.TaxCode
	WHERE        ( Org.tbPayment.PaymentCode = @PaymentCode)

	INSERT INTO Invoice.tbItem
						(InvoiceNumber, CashCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, TaxCode)
	SELECT     @InvoiceNumber AS InvoiceNumber, Org.tbPayment.CashCode, 
	                      CASE WHEN PaidInValue > 0 THEN Org.tbPayment.PaidInValue / (1 + App.vwTaxRates.TaxRate) 
	                      WHEN PaidOutValue > 0 THEN Org.tbPayment.PaidOutValue / (1 + App.vwTaxRates.TaxRate) END AS InvoiceValue, 
	                      CASE WHEN Org.tbPayment.PaidInValue > 0 THEN Org.tbPayment.PaidInValue - ROUND(( Org.tbPayment.PaidInValue / (1 + App.vwTaxRates.TaxRate)), 
	                      2) WHEN Org.tbPayment.PaidOutValue > 0 THEN Org.tbPayment.PaidOutValue - ROUND(( Org.tbPayment.PaidOutValue / (1 + App.vwTaxRates.TaxRate)), 
	                      2) END AS TaxValue, CASE WHEN Org.tbPayment.PaidInValue > 0 THEN Org.tbPayment.PaidInValue / (1 + App.vwTaxRates.TaxRate) 
	                      WHEN PaidOutValue > 0 THEN Org.tbPayment.PaidOutValue / (1 + App.vwTaxRates.TaxRate) END AS PaidValue, 
	                      CASE WHEN Org.tbPayment.PaidInValue > 0 THEN Org.tbPayment.PaidInValue - ROUND(( Org.tbPayment.PaidInValue / (1 + App.vwTaxRates.TaxRate)), 
	                      2) WHEN Org.tbPayment.PaidOutValue > 0 THEN Org.tbPayment.PaidOutValue - ROUND(( Org.tbPayment.PaidOutValue / (1 + App.vwTaxRates.TaxRate)), 
	                      2) END AS PaidTaxValue, Org.tbPayment.TaxCode
	FROM         Org.tbPayment INNER JOIN
	                      App.vwTaxRates ON Org.tbPayment.TaxCode = App.vwTaxRates.TaxCode
	WHERE     ( Org.tbPayment.PaymentCode = @PaymentCode)

	UPDATE  Org.tbAccount
	SET CurrentBalance = CASE WHEN PaidInValue > 0 THEN Org.tbAccount.CurrentBalance + PaidInValue ELSE Org.tbAccount.CurrentBalance - PaidOutValue END
	FROM         Org.tbAccount INNER JOIN
						  Org.tbPayment ON Org.tbAccount.CashAccountCode = Org.tbPayment.CashAccountCode
	WHERE Org.tbPayment.PaymentCode = @PaymentCode

	UPDATE    Org.tbPayment
	SET		PaymentStatusCode = 2,
		TaxInValue = PaidInValue - ROUND((PaidInValue / (1 + TaxRate)), 2), 
		TaxOutValue = PaidOutValue - ROUND((PaidOutValue / (1 + TaxRate)), 2)
	FROM         Org.tbPayment INNER JOIN
	                      App.vwTaxRates ON Org.tbPayment.TaxCode = App.vwTaxRates.TaxCode
	WHERE     (PaymentCode = @PaymentCode)
	
	RETURN
GO
CREATE PROCEDURE Org.proc_PaymentPost 
  AS
DECLARE @PaymentCode NVARCHAR(20)

	DECLARE curMisc CURSOR LOCAL FOR
		SELECT     PaymentCode
		FROM         Org.tbPayment
		WHERE     (PaymentStatusCode = 1) AND (NOT (CashCode IS NULL))
		ORDER BY AccountCode, PaidOn

	DECLARE curInv CURSOR LOCAL FOR
		SELECT     PaymentCode
		FROM         Org.tbPayment
		WHERE     (PaymentStatusCode = 1) AND (CashCode IS NULL)
		ORDER BY AccountCode, PaidOn
		
	BEGIN TRAN Payment
	OPEN curMisc
	FETCH NEXT FROM curMisc INTO @PaymentCode
	WHILE @@FETCH_STATUS = 0
		BEGIN
		EXEC Org.proc_PaymentPostMisc @PaymentCode		
		FETCH NEXT FROM curMisc INTO @PaymentCode	
		END

	CLOSE curMisc
	DEALLOCATE curMisc
	
	OPEN curInv
	FETCH NEXT FROM curInv INTO @PaymentCode
	WHILE @@FETCH_STATUS = 0
		BEGIN
		EXEC Org.proc_PaymentPostInvoiced @PaymentCode		
		FETCH NEXT FROM curInv INTO @PaymentCode	
		END

	CLOSE curInv
	DEALLOCATE curInv

	COMMIT TRAN Payment
	
	RETURN
GO
CREATE PROCEDURE App.proc_AddCalDateRange
	(
		@CalENDarCode NVARCHAR(10),
		@FromDate DATETIME,
		@ToDate DATETIME
	)
   AS
DECLARE @UnavailableDate DATETIME

	SELECT @UnavailableDate = @FromDate
	
	WHILE @UnavailableDate <= @ToDate
	BEGIN
		INSERT INTO App.tbCalENDarHoliday (CalENDarCode, UnavailableOn)
		VALUES (@CalENDarCode, @UnavailableDate)
		SELECT @UnavailableDate = DateAdd(d, 1, @UnavailableDate)
	END

	RETURN
GO
CREATE PROCEDURE App.proc_DelCalDateRange
	(
		@CalENDarCode NVARCHAR(10),
		@FromDate DATETIME,
		@ToDate DATETIME
	)
   AS
	DELETE FROM App.tbCalENDarHoliday
		WHERE UnavailableOn >= @FromDate
			AND UnavailableOn <= @ToDate
			AND CalENDarCode = @CalENDarCode
			
	RETURN
GO
CREATE Procedure App.proc_Initialised
(@Setting BIT)
   AS
	IF @Setting = 1
		AND (EXISTS (SELECT     Org.tbOrg.AccountCode
	                FROM         Org.tbOrg INNER JOIN
	                                      App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode)
		OR EXISTS (SELECT     Org.tbAddress.AddressCode
					   FROM         Org.tbOrg INNER JOIN
											 App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode INNER JOIN
											 Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode)
		OR EXISTS (SELECT     TOP 1 UserId
						   FROM         Usr.tbUser))
		BEGIN
		UPDATE App.tbOptions Set Initialised = 1
		RETURN
		END
	ELSE
		BEGIN
		UPDATE App.tbOptions Set Initialised = 0
		RETURN 1
		END

GO
CREATE PROCEDURE App.proc_Licence
	(
		@Licence binary (50) = null OUTPUT,
		@LicenceType SMALLINT = null OUTPUT
	)
   AS
	SELECT top 1 @Licence = Licence, @LicenceType = LicenceType 
	FROM App.tbInstall
	WHERE CategoryTypeCode = 0 and ReleaseTypeCode = 0	
	RETURN 
GO
CREATE PROCEDURE App.proc_LicenceAdd
	(
		@Licence binary (50),
		@LicenceType SMALLINT
	)
    AS
	UPDATE App.tbInstall
	SET 
		Licence = @Licence,
		LicenceType = @LicenceType
	WHERE
		CategoryTypeCode = 0
		and ReleaseTypeCode = 0
	
	IF @@ROWCOUNT > 0
		RETURN
	ELSE
		RETURN 1
GO
CREATE  PROCEDURE App.proc_NewCompany
	(
	@FirstNames NVARCHAR(50),
	@LastName NVARCHAR(50),
	@CompanyName NVARCHAR(50),
	@CompanyAddress NTEXT,
	@AccountCode NVARCHAR(50),
	@CompanyNumber NVARCHAR(20) = null,
	@VatNumber NVARCHAR(50) = null,
	@LandLine NVARCHAR(20) = null,
	@Fax NVARCHAR(20) = null,
	@Email NVARCHAR(50) = null,
	@WebSite NVARCHAR(128) = null
	)
  AS
DECLARE @UserId NVARCHAR(10)
DECLARE @CalENDarCode NVARCHAR(10)
DECLARE @MenuId SMALLINT

DECLARE @AppAccountCode NVARCHAR(10)
DECLARE @TaxCode NVARCHAR(10)
DECLARE @AddressCode NVARCHAR(15)

DECLARE @SqlDataVersion real
	
	SELECT top 1 @MenuId = MenuId FROM Usr.tbMenu
	SELECT top 1 @CalENDarCode = CalENDarCode FROM App.tbCalENDar 

	SET @UserId = upper(left(@FirstNames, 1)) + upper(left(@LastName, 1))
	INSERT INTO Usr.tbUser
	                      (UserId, UserName, LogonName, CalENDarCode, PhoneNumber, FaxNumber, EmailAddress, Administrator)
	VALUES     (@UserId, @FirstNames + N' ' + @LastName, SUSER_SNAME(), @CalENDarCode, @LandLine, @Fax, @Email, 1)

	INSERT INTO Usr.tbMenuUser
	                      (UserId, MenuId)
	VALUES     (@UserId, @MenuId)

	SET @AppAccountCode = left(@AccountCode, 10)
	SET @TaxCode = 'T0'
	
	INSERT INTO Org.tbOrg
	                      (AccountCode, AccountName, OrganisationTypeCode, OrganisationStatusCode, PhoneNumber, FaxNumber, EmailAddress, WebSite, CompanyNumber, 
	                      VatNumber, TaxCode)
	VALUES     (@AppAccountCode, @CompanyName, 8, 2, @LandLine, @Fax, @Email, @Website, @CompanyNumber, @VatNumber, @TaxCode)

	EXEC Org.proc_NextAddressCode @AppAccountCode, @AddressCode OUTPUT
	
	INSERT INTO Org.tbAddress (AddressCode, AccountCode, Address)
	VALUES (@AddressCode, @AppAccountCode, @CompanyAddress)

	INSERT INTO Org.tbContact
	                      (AccountCode, ContactName, FileAs, NickName, PhoneNumber, FaxNumber, EmailAddress)
	VALUES     (@AppAccountCode, @FirstNames + N' ' + @LastName, @LastName + N', ' + @FirstNames, @FirstNames, @LandLine, @Fax, @Email)	 

	SELECT @SqlDataVersion = DataVersion
	FROM         App.tbInstall
	WHERE     (CategoryTypeCode = 0) AND (ReleaseTypeCode = 0)

	INSERT INTO Org.tbAccount
						(AccountCode, CashAccountCode, CashAccountName)
	VALUES     (@AccountCode, N'CASH', N'Petty Cash')	

	INSERT INTO App.tbOptions
						(IdentIFier, Initialised, SQLDataVersion, AccountCode, DefaultPrintMode, BucketTypeCode, BucketIntervalCode, ShowCashGraphs)
	VALUES     (N'TC', 0, @SQLDataVersion, @AppAccountCode, 2, 1, 2, 1)
	
	UPDATE Cash.tbTaxType
	SET CashCode = N'900'
	WHERE TaxTypeCode = 3
	
	UPDATE Cash.tbTaxType
	SET CashCode = N'902'
	WHERE TaxTypeCode = 1
	
	UPDATE Cash.tbTaxType
	SET CashCode = N'901'
	WHERE TaxTypeCode = 2
	
	UPDATE Cash.tbTaxType
	SET CashCode = N'903'
	WHERE TaxTypeCode = 4
	
	RETURN
GO
CREATE PROCEDURE Cash.proc_StatementRescheduleOverdue
 AS
	UPDATE Task.tbTask
	SET Task.tbTask.PaymentOn = Task.fnDefaultPaymentOn( Task.tbTask.AccountCode, SYSDATETIME()) 
	FROM         Task.tbTask INNER JOIN
                      Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode
	WHERE     ( Task.tbTask.PaymentOn < SYSDATETIME()) AND ( Task.tbTask.TaskStatusCode = 3)
	

	UPDATE Task.tbTask
	SET Task.tbTask.PaymentOn = Task.fnDefaultPaymentOn( Task.tbTask.AccountCode, SYSDATETIME()) 
	FROM         Task.tbTask INNER JOIN
                      Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode
	WHERE     ( Task.tbTask.PaymentOn < SYSDATETIME()) AND ( Task.tbTask.TaskStatusCode < 3)
	
	UPDATE Invoice.tbInvoice
	SET CollectOn = Task.fnDefaultPaymentOn( Invoice.tbInvoice.AccountCode, SYSDATETIME()) 
	FROM         Invoice.tbInvoice 
	WHERE     ( Invoice.tbInvoice.InvoiceStatusCode = 2 OR
	                      Invoice.tbInvoice.InvoiceStatusCode = 3) AND ( Invoice.tbInvoice.CollectOn < SYSDATETIME())
	
	
	RETURN


GO
CREATE PROCEDURE App.proc_AdjustToCalENDar
	(
	@SourceDate DATETIME,
	@OffSETDays INT,
	@OutputDate DATETIME OUTPUT
	)
AS
DECLARE @UserId NVARCHAR(10)

	SELECT @UserId = UserId
	FROM         Usr.vwCredentials	
	
	SET @OutputDate = App.fnAdjustToCalendar(@UserId, @SourceDate, @OffSETDays)

	RETURN
GO
CREATE PROCEDURE App.proc_CompanyName
	(
	@AccountName NVARCHAR(255) = null OUTPUT
	)
  AS
	SELECT top 1 @AccountName = Org.tbOrg.AccountName
	FROM         Org.tbOrg INNER JOIN
	                      App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode
	RETURN 
GO
CREATE PROCEDURE App.proc_DocDespool
	(
	@DocTypeCode SMALLINT
	)
AS
	IF @DocTypeCode = 1
		GOTO Quotations
	ELSE IF @DocTypeCode = 2
		GOTO SalesOrder
	ELSE IF @DocTypeCode = 3
		GOTO PurchaseEnquiry
	ELSE IF @DocTypeCode = 4
		GOTO PurchaseOrder
	ELSE IF @DocTypeCode = 5
		GOTO SalesInvoice
	ELSE IF @DocTypeCode = 6
		GOTO CreditNote
	ELSE IF @DocTypeCode = 7
		GOTO DebitNote
		
	RETURN
	
Quotations:
	UPDATE       Task.tbTask
	SET           Spooled = 0, Printed = 1
	FROM            Task.tbTask INNER JOIN
							 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
							 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE        ( Task.tbTask.TaskStatusCode = 1) AND ( Cash.tbCategory.CashModeCode = 2) AND ( Task.tbTask.Spooled <> 0)
	RETURN
	
SalesOrder:
	UPDATE       Task.tbTask
	SET           Spooled = 0, Printed = 1
	FROM            Task.tbTask INNER JOIN
							 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
							 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE        ( Task.tbTask.TaskStatusCode > 1) AND ( Cash.tbCategory.CashModeCode = 2) AND ( Task.tbTask.Spooled <> 0)
	RETURN
	
PurchaseEnquiry:
	UPDATE       Task.tbTask
	SET           Spooled = 0, Printed = 1
	FROM            Task.tbTask INNER JOIN
							 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
							 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE        ( Task.tbTask.TaskStatusCode = 1) AND ( Cash.tbCategory.CashModeCode = 1) AND ( Task.tbTask.Spooled <> 0)	
	RETURN
	
PurchaseOrder:
	UPDATE       Task.tbTask
	SET           Spooled = 0, Printed = 1
	FROM            Task.tbTask INNER JOIN
							 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
							 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE        ( Task.tbTask.TaskStatusCode > 1) AND ( Cash.tbCategory.CashModeCode = 1) AND ( Task.tbTask.Spooled <> 0)
	RETURN
	
SalesInvoice:
	UPDATE       Invoice.tbInvoice
	SET                Spooled = 0, Printed = 1
	WHERE        (InvoiceTypeCode = 1) AND (Spooled <> 0)

	RETURN
	
CreditNote:
	UPDATE       Invoice.tbInvoice
	SET                Spooled = 0, Printed = 1
	WHERE        (InvoiceTypeCode = 2) AND (Spooled <> 0)
	RETURN
	
DebitNote:
	UPDATE       Invoice.tbInvoice
	SET                Spooled = 0, Printed = 1
	WHERE        (InvoiceTypeCode = 4) AND (Spooled <> 0)
	RETURN
GO
CREATE PROCEDURE App.proc_PeriodClose
   AS

	IF EXISTS(SELECT * FROM App.fnActivePeriod())
		BEGIN
		DECLARE @StartOn DATETIME
		DECLARE @YearNumber SMALLINT
		
		SELECT @StartOn = StartOn, @YearNumber = YearNumber
		FROM App.fnActivePeriod() fnSystemActivePeriod
		 		
		BEGIN TRAN
	
		UPDATE App.tbYearPeriod
		SET CashStatusCode = 3
		WHERE StartOn = @StartOn			
		
		IF NOT EXISTS (SELECT     CashStatusCode
					FROM         App.tbYearPeriod
					WHERE     (YearNumber = @YearNumber) AND (CashStatusCode < 3)) 
			BEGIN
			UPDATE App.tbYear
			SET CashStatusCode = 3
			WHERE YearNumber = @YearNumber	
			END
		IF EXISTS(SELECT * FROM App.fnActivePeriod())
			BEGIN
			UPDATE App.tbYearPeriod
			SET CashStatusCode = 2
			FROM App.fnActivePeriod() fnSystemActivePeriod INNER JOIN
								App.tbYearPeriod ON fnSystemActivePeriod.YearNumber = App.tbYearPeriod.YearNumber AND fnSystemActivePeriod.MonthNumber = App.tbYearPeriod.MonthNumber
			
			END		
		IF EXISTS(SELECT * FROM App.fnActivePeriod())
			BEGIN
			UPDATE App.tbYear
			SET CashStatusCode = 2
			FROM App.fnActivePeriod() fnSystemActivePeriod INNER JOIN
								App.tbYear ON fnSystemActivePeriod.YearNumber = App.tbYear.YearNumber  
			END
		COMMIT TRAN
		END
					
	RETURN
GO
CREATE PROCEDURE App.proc_PeriodGetYear
	(
	@StartOn DATETIME,
	@YearNumber INTEGER OUTPUT
	)
AS
	SELECT @YearNumber = YearNumber
	FROM            App.tbYearPeriod
	WHERE        (StartOn = @StartOn)
	
	IF @YearNumber IS NULL
		SELECT @YearNumber = YearNumber FROM App.fnActivePeriod()
		
	RETURN
GO
CREATE PROCEDURE App.proc_ReassignUser 
	(
	@UserId NVARCHAR(10)
	)
  AS
	UPDATE    Usr.tbUser
	SET       LogonName = (SUSER_SNAME())
	WHERE     (UserId = @UserId)
	
	RETURN
GO
CREATE PROCEDURE App.proc_YearPeriods
	(
	@YearNumber INT
	)
   AS
	SELECT     App.tbYear.Description, App.tbMonth.MonthName
				FROM         App.tbYearPeriod INNER JOIN
									App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
									App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
				WHERE     ( App.tbYearPeriod.YearNumber = @YearNumber)
				ORDER BY App.tbYearPeriod.YearNumber, App.tbYearPeriod.StartOn
	RETURN 
GO
CREATE PROCEDURE Task.proc_AssignToParent 
	(
	@ChildTaskCode NVARCHAR(20),
	@ParentTaskCode NVARCHAR(20)
	)
  AS
DECLARE @TaskTitle NVARCHAR(100)
DECLARE @StepNumber SMALLINT

	IF EXISTS (SELECT ParentTaskCode FROM Task.tbFlow WHERE ChildTaskCode = @ChildTaskCode)
		DELETE FROM Task.tbFlow WHERE ChildTaskCode = @ChildTaskCode

	IF EXISTS(SELECT     TOP 1 StepNumber
	          FROM         Task.tbFlow
	          WHERE     (ParentTaskCode = @ParentTaskCode))
		BEGIN
		SELECT  @StepNumber = MAX(StepNumber) 
		FROM         Task.tbFlow
		WHERE     (ParentTaskCode = @ParentTaskCode)
		SET @StepNumber = @StepNumber - (@StepNumber % 10) + 10		
		END
	ELSE
		SET @StepNumber = 10


	SELECT     @TaskTitle = TaskTitle
	FROM         Task.tbTask
	WHERE     (TaskCode = @ParentTaskCode)		
	
	UPDATE    Task.tbTask
	SET              TaskTitle = @TaskTitle
	WHERE     (TaskCode = @ChildTaskCode) AND ((TaskTitle IS NULL) OR (TaskTitle = ActivityCode))
	
	INSERT INTO Task.tbFlow
	                      (ParentTaskCode, StepNumber, ChildTaskCode)
	VALUES     (@ParentTaskCode, @StepNumber, @ChildTaskCode)
	
	RETURN
GO
CREATE PROCEDURE Task.proc_NextCode
	(
		@ActivityCode NVARCHAR(50),
		@TaskCode NVARCHAR(20) OUTPUT
	)
  AS
DECLARE @UserId NVARCHAR(10)
DECLARE @NextTaskNumber INT

	SELECT   @UserId = Usr.tbUser.UserId, @NextTaskNumber = Usr.tbUser.NextTaskNumber
	FROM         Usr.vwCredentials INNER JOIN
						Usr.tbUser ON Usr.vwCredentials.UserId = Usr.tbUser.UserId


	IF EXISTS(SELECT     App.tbRegister.NextNumber
	          FROM         Activity.tbActivity INNER JOIN
	                                App.tbRegister ON Activity.tbActivity.RegisterName = App.tbRegister.RegisterName
	          WHERE     ( Activity.tbActivity.ActivityCode = @ActivityCode))
		BEGIN
		DECLARE @RegisterName NVARCHAR(50)
		SELECT @RegisterName = App.tbRegister.RegisterName, @NextTaskNumber = App.tbRegister.NextNumber
		FROM         Activity.tbActivity INNER JOIN
	                                App.tbRegister ON Activity.tbActivity.RegisterName = App.tbRegister.RegisterName
	    WHERE     ( Activity.tbActivity.ActivityCode = @ActivityCode)
			          
		UPDATE    App.tbRegister
		SET              NextNumber = NextNumber + 1
		WHERE     (RegisterName = @RegisterName)	
		END
	ELSE
		BEGIN
		SELECT   @UserId = Usr.tbUser.UserId, @NextTaskNumber = Usr.tbUser.NextTaskNumber
		FROM         Usr.vwCredentials INNER JOIN
							Usr.tbUser ON Usr.vwCredentials.UserId = Usr.tbUser.UserId
		                      		
		UPDATE Usr.tbUser
		Set NextTaskNumber = NextTaskNumber + 1
		WHERE UserId = @UserId
		END
		                      
	SET @TaskCode = @UserId + '_' + FORMAT(@NextTaskNumber, '0000')
			                      
	RETURN 
GO
CREATE  PROCEDURE Task.proc_Configure 
	(
	@ParentTaskCode NVARCHAR(20)
	)
   AS
DECLARE @StepNumber SMALLINT
DECLARE @TaskCode NVARCHAR(20)
DECLARE @UserId NVARCHAR(10)
DECLARE @ActivityCode NVARCHAR(50)

	IF EXISTS (SELECT     ContactName
	           FROM         Task.tbTask
	           WHERE     (TaskCode = @ParentTaskCode) AND (NOT (ContactName IS NULL)) OR
	                                 (TaskCode = @ParentTaskCode) AND (ContactName <> N''))
		BEGIN
		IF NOT EXISTS(SELECT     Org.tbContact.ContactName
					  FROM         Task.tbTask INNER JOIN
											Org.tbContact ON Task.tbTask.AccountCode = Org.tbContact.AccountCode AND Task.tbTask.ContactName = Org.tbContact.ContactName
					  WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode))
			BEGIN
			DECLARE @FileAs NVARCHAR(100)
			DECLARE @ContactName NVARCHAR(100)
			DECLARE @NickName NVARCHAR(100)
			
			SELECT @ContactName = ContactName FROM Task.tbTask	 
			WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode)
			
			IF LEN(ISNULL(@ContactName, '')) > 0
				BEGIN
				SET @NickName = left(@ContactName, CHARINDEX(' ', @ContactName, 1))
				EXEC Org.proc_ContactFileAs @ContactName, @FileAs OUTPUT
				
				INSERT INTO Org.tbContact
									  (AccountCode, ContactName, FileAs, NickName)
				SELECT     AccountCode, ContactName, @FileAs AS FileAs, @NickName AS NickName
				FROM         Task.tbTask
				WHERE     (TaskCode = @ParentTaskCode)
				END
			END                                   
		END
	
	IF EXISTS(SELECT     Org.tbOrg.AccountCode
	          FROM         Org.tbOrg INNER JOIN
	                                Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode
	          WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode) AND ( Org.tbOrg.OrganisationStatusCode = 1))
		BEGIN
		UPDATE Org.tbOrg
		SET OrganisationStatusCode = 2
		FROM         Org.tbOrg INNER JOIN
	                                Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode
	          WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode) AND ( Org.tbOrg.OrganisationStatusCode = 1)				
		END
	          
	IF EXISTS(SELECT     TaskStatusCode
	          FROM         Task.tbTask
	          WHERE     (TaskStatusCode = 3) AND (TaskCode = @ParentTaskCode))
		BEGIN
		UPDATE    Task.tbTask
		SET              ActionedOn = ActionOn
		WHERE     (TaskCode = @ParentTaskCode)
		END	

	IF EXISTS(SELECT     TaskCode
	          FROM         Task.tbTask
	          WHERE     (TaskCode = @ParentTaskCode) AND (TaskTitle IS NULL))  
		BEGIN
		UPDATE    Task.tbTask
		SET      TaskTitle = ActivityCode
		WHERE     (TaskCode = @ParentTaskCode)
		END
	                 
	     	
	INSERT INTO Task.tbAttribute
						  (TaskCode, Attribute, AttributeDescription, PrintOrder, AttributeTypeCode)
	SELECT     Task.tbTask.TaskCode, Activity.tbAttribute.Attribute, Activity.tbAttribute.DefaultText, Activity.tbAttribute.PrintOrder, Activity.tbAttribute.AttributeTypeCode
	FROM         Activity.tbAttribute INNER JOIN
						  Task.tbTask ON Activity.tbAttribute.ActivityCode = Task.tbTask.ActivityCode
	WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode)
	
	INSERT INTO Task.tbOp
	                      (TaskCode, UserId, OperationNumber, OpTypeCode, Operation, Duration, OffSETDays, StartOn)
	SELECT     Task.tbTask.TaskCode, Task.tbTask.UserId, Activity.tbOp.OperationNumber, Activity.tbOp.OpTypeCode, Activity.tbOp.Operation, Activity.tbOp.Duration, 
	                      Activity.tbOp.OffSETDays, Task.tbTask.ActionOn
	FROM         Activity.tbOp INNER JOIN
	                      Task.tbTask ON Activity.tbOp.ActivityCode = Task.tbTask.ActivityCode
	WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode)
	                   
	
	SELECT @UserId = UserId FROM Task.tbTask WHERE Task.tbTask.TaskCode = @ParentTaskCode
	
	DECLARE curAct CURSOR LOCAL FOR
		SELECT     Activity.tbFlow.StepNumber
		FROM         Activity.tbFlow INNER JOIN
		                      Task.tbTask ON Activity.tbFlow.ParentCode = Task.tbTask.ActivityCode
		WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode)
		ORDER BY Activity.tbFlow.StepNumber	
	
	OPEN curAct
	FETCH NEXT FROM curAct INTO @StepNumber
	WHILE @@FETCH_STATUS = 0
		BEGIN
		SELECT  @ActivityCode = Activity.tbActivity.ActivityCode
		FROM         Activity.tbFlow INNER JOIN
		                      Activity.tbActivity ON Activity.tbFlow.ChildCode = Activity.tbActivity.ActivityCode INNER JOIN
		                      Task.tbTask AS Task_tb1 ON Activity.tbFlow.ParentCode = Task_tb1.ActivityCode
		WHERE     ( Activity.tbFlow.StepNumber = @StepNumber) AND ( Task_tb1.TaskCode = @ParentTaskCode)
		
		EXEC Task.proc_NextCode @ActivityCode, @TaskCode OUTPUT
		
		INSERT INTO Task.tbTask
							(TaskCode, UserId, AccountCode, ContactName, ActivityCode, TaskStatusCode, ActionById, ActionOn, PaymentOn, TaskNotes, UnitCharge, 
							AddressCodeFrom, AddressCodeTo, CashCode, TaxCode, Printed, TaskTitle)
		SELECT     @TaskCode AS NewTask, Task_tb1.UserId, Task_tb1.AccountCode, Task_tb1.ContactName, Activity.tbActivity.ActivityCode, Activity.tbActivity.TaskStatusCode, 
							Task_tb1.ActionById, Task_tb1.ActionOn, Task.fnDefaultPaymentOn( Task_tb1.AccountCode, Task_tb1.ActionOn) 
							AS PaymentOn, Activity.tbActivity.DefaultText, Activity.tbActivity.UnitCharge, Org.tbOrg.AddressCode AS AddressCodeFrom, Org.tbOrg.AddressCode AS AddressCodeTo, 
							tbActivity.CashCode, Task.fnDefaultTaxCode( Task_tb1.AccountCode, Activity.tbActivity.CashCode) AS TaxCode, 
							CASE WHEN Activity.tbActivity.PrintOrder = 0 THEN 1 ELSE 0 END AS Printed, Task_tb1.TaskTitle
		FROM         Activity.tbFlow INNER JOIN
							Activity.tbActivity ON Activity.tbFlow.ChildCode = Activity.tbActivity.ActivityCode INNER JOIN
							Task.tbTask Task_tb1 ON Activity.tbFlow.ParentCode = Task_tb1.ActivityCode INNER JOIN
							Org.tbOrg ON Task_tb1.AccountCode = Org.tbOrg.AccountCode
		WHERE     ( Activity.tbFlow.StepNumber = @StepNumber) AND ( Task_tb1.TaskCode = @ParentTaskCode)
		
		INSERT INTO Task.tbFlow
		                      (ParentTaskCode, StepNumber, ChildTaskCode, UsedOnQuantity, OffSETDays)
		SELECT     Task.tbTask.TaskCode, Activity.tbFlow.StepNumber, @TaskCode AS ChildTaskCode, Activity.tbFlow.UsedOnQuantity, Activity.tbFlow.OffSETDays
		FROM         Activity.tbFlow INNER JOIN
		                      Task.tbTask ON Activity.tbFlow.ParentCode = Task.tbTask.ActivityCode
		WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode) AND ( Activity.tbFlow.StepNumber = @StepNumber)
		
		EXEC Task.proc_Configure @TaskCode
		FETCH NEXT FROM curAct INTO @StepNumber
		END
	
	CLOSE curAct
	DEALLOCATE curAct


	RETURN
GO
CREATE PROCEDURE Task.proc_Copy
	(
	@FromTaskCode NVARCHAR(20),
	@ParentTaskCode NVARCHAR(20) = null,
	@ToTaskCode NVARCHAR(20) = null OUTPUT
	)
AS
DECLARE @ActivityCode NVARCHAR(50)
DECLARE @Printed BIT
DECLARE @ChildTaskCode NVARCHAR(20)
DECLARE @TaskStatusCode SMALLINT
DECLARE @StepNumber SMALLINT
DECLARE @UserId NVARCHAR(10)

	SELECT @UserId = UserId FROM Usr.vwCredentials
	
	SELECT  @TaskStatusCode = Activity.tbActivity.TaskStatusCode, @ActivityCode = Task.tbTask.ActivityCode, @Printed = CASE WHEN Activity.tbActivity.PrintOrder = 0 THEN 1 ELSE 0 END
	FROM         Task.tbTask INNER JOIN
	                      Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode
	WHERE     ( Task.tbTask.TaskCode = @FromTaskCode)
	
	EXEC Task.proc_NextCode @ActivityCode, @ToTaskCode OUTPUT

	INSERT INTO Task.tbTask
						  (TaskCode, UserId, AccountCode, TaskTitle, ContactName, ActivityCode, TaskStatusCode, ActionById, ActionOn, ActionedOn, TaskNotes, Quantity, 
						  SecondReference, CashCode, TaxCode, UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, PaymentOn, Printed)
	SELECT     @ToTaskCode AS ToTaskCode, @UserId AS Owner, AccountCode, TaskTitle, ContactName, ActivityCode, @TaskStatusCode AS TaskStatus, 
						  @UserId AS ActionUserId, CONVERT(DATETIME, CONVERT(varchar, SYSDATETIME(), 1), 1) AS ActionOn, 
						  CASE WHEN @TaskStatusCode > 2 THEN CONVERT(DATETIME, CONVERT(varchar, SYSDATETIME(), 1), 1) ELSE NULL END AS ActionedOn, TaskNotes, 
						  Quantity, SecondReference, CashCode, TaxCode, UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, 
						  Task.fnDefaultPaymentOn(AccountCode, CONVERT(DATETIME, CONVERT(varchar, SYSDATETIME(), 1), 1)) AS Expr1, @Printed AS Printed
	FROM         Task.tbTask AS Task_tb1
	WHERE     (TaskCode = @FromTaskCode)
	
	INSERT INTO Task.tbAttribute
	                      (TaskCode, Attribute, PrintOrder, AttributeTypeCode, AttributeDescription)
	SELECT     @ToTaskCode AS ToTaskCode, Attribute, PrintOrder, AttributeTypeCode, AttributeDescription
	FROM         Task.tbAttribute 
	WHERE     (TaskCode = @FromTaskCode)
	
	INSERT INTO Task.tbQuote
	                      (TaskCode, Quantity, TotalPrice, RunOnQuantity, RunOnPrice, RunBackQuantity, RunBackPrice)
	SELECT     @ToTaskCode AS ToTaskCode, Quantity, TotalPrice, RunOnQuantity, RunOnPrice, RunBackQuantity, RunBackPrice
	FROM         Task.tbQuote 
	WHERE     (TaskCode = @FromTaskCode)
	
	INSERT INTO Task.tbOp
						  (TaskCode, OperationNumber, OpStatusCode, UserId, OpTypeCode, Operation, Note, StartOn, EndOn, Duration, OffSETDays)
	SELECT     @ToTaskCode AS ToTaskCode, OperationNumber, 1 AS OpStatus, UserId, OpTypeCode, Operation, Note, CONVERT(DATETIME, CONVERT(varchar, 
						  SYSDATETIME(), 1), 1) AS StartOn, CONVERT(DATETIME, CONVERT(varchar, SYSDATETIME(), 1), 1) AS EndOn, Duration, OffSETDays
	FROM         Task.tbOp 
	WHERE     (TaskCode = @FromTaskCode)
	
	IF (ISNULL(@ParentTaskCode, '') = '')
		BEGIN
		IF EXISTS(SELECT     ParentTaskCode
				FROM         Task.tbFlow
				WHERE     (ChildTaskCode = @FromTaskCode))
			BEGIN
			SELECT @ParentTaskCode = ParentTaskCode
			FROM         Task.tbFlow
			WHERE     (ChildTaskCode = @FromTaskCode)

			SELECT @StepNumber = MAX(StepNumber)
			FROM         Task.tbFlow
			WHERE     (ParentTaskCode = @ParentTaskCode)
			GROUP BY ParentTaskCode
				
			SET @StepNumber = @StepNumber - (@StepNumber % 10) + 10	
						
			INSERT INTO Task.tbFlow
			(ParentTaskCode, StepNumber, ChildTaskCode, UsedOnQuantity, OffSETDays)
			SELECT TOP 1 ParentTaskCode, @StepNumber AS Step, @ToTaskCode AS ChildTask, UsedOnQuantity, OffSETDays
			FROM         Task.tbFlow
			WHERE     (ChildTaskCode = @FromTaskCode)
			END
		END
	ELSE
		BEGIN
		
		INSERT INTO Task.tbFlow
		(ParentTaskCode, StepNumber, ChildTaskCode, UsedOnQuantity, OffSETDays)
		SELECT TOP 1 @ParentTaskCode As ParentTask, StepNumber, @ToTaskCode AS ChildTask, UsedOnQuantity, OffSETDays
		FROM         Task.tbFlow 
		WHERE     (ChildTaskCode = @FromTaskCode)		
		END
	
	DECLARE curTask CURSOR LOCAL FOR			
		SELECT     ChildTaskCode
		FROM         Task.tbFlow
		WHERE     (ParentTaskCode = @FromTaskCode)
	
	OPEN curTask
	
	FETCH NEXT FROM curTask INTO @ChildTaskCode
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		EXEC Task.proc_Copy @ChildTaskCode, @ToTaskCode
		FETCH NEXT FROM curTask INTO @ChildTaskCode
		END
		
	CLOSE curTask
	DEALLOCATE curTask
		
	RETURN

GO
CREATE PROCEDURE Task.proc_Cost 
	(
	@ParentTaskCode NVARCHAR(20),
	@TotalCost MONEY = 0 OUTPUT
	)

  AS
DECLARE @TaskCode NVARCHAR(20)
DECLARE @TotalCharge MONEY
DECLARE @CashModeCode SMALLINT

	DECLARE curFlow CURSOR LOCAL FOR
		SELECT     Task.tbTask.TaskCode, Task.vwCashMode.CashModeCode, Task.tbTask.TotalCharge
		FROM         Task.tbTask INNER JOIN
							  Task.tbFlow ON Task.tbTask.TaskCode = Task.tbFlow.ChildTaskCode INNER JOIN
							  Task.vwCashMode ON Task.tbTask.TaskCode = Task.vwCashMode.TaskCode
		WHERE     ( Task.tbFlow.ParentTaskCode = @ParentTaskCode) AND ( Task.tbTask.TaskStatusCode < 5)

	OPEN curFlow
	FETCH NEXT FROM curFlow INTO @TaskCode, @CashModeCode, @TotalCharge
	WHILE @@FETCH_STATUS = 0
		BEGIN
		SET @TotalCost = @TotalCost + CASE WHEN @CashModeCode = 1 then @TotalCharge ELSE @TotalCharge * -1 END
		EXEC Task.proc_Cost @TaskCode, @TotalCost OUTPUT
		FETCH NEXT FROM curFlow INTO @TaskCode, @CashModeCode, @TotalCharge
		END
	
	CLOSE curFlow
	DEALLOCATE curFlow
	
	RETURN
GO
CREATE PROCEDURE Task.proc_DefaultDocType
	(
		@TaskCode NVARCHAR(20),
		@DocTypeCode SMALLINT OUTPUT
	)
  AS
DECLARE @CashMode SMALLINT
DECLARE @TaskStatus SMALLINT

	IF EXISTS(SELECT     CashModeCode
	          FROM         Task.vwCashMode
	          WHERE     (TaskCode = @TaskCode))
		SELECT   @CashMode = CashModeCode
		FROM         Task.vwCashMode
		WHERE     (TaskCode = @TaskCode)			          
	ELSE
		SET @CashMode = 2

	SELECT  @TaskStatus =TaskStatusCode
	FROM         Task.tbTask
	WHERE     (TaskCode = @TaskCode)		
	
	IF @CashMode = 1
		SET @DocTypeCode = CASE @TaskStatus WHEN 1 THEN 3 ELSE 4 END								
	ELSE
		SET @DocTypeCode = CASE @TaskStatus WHEN 1 THEN 1 ELSE 2 END 
		
	RETURN 

GO
CREATE PROCEDURE Task.proc_DefaultInvoiceType
	(
		@TaskCode NVARCHAR(20),
		@InvoiceTypeCode SMALLINT OUTPUT
	)
  AS
DECLARE @CashMode SMALLINT

	IF EXISTS(SELECT     CashModeCode
	          FROM         Task.vwCashMode
	          WHERE     (TaskCode = @TaskCode))
		SELECT   @CashMode = CashModeCode
		FROM         Task.vwCashMode
		WHERE     (TaskCode = @TaskCode)			          
	ELSE
		SET @CashMode = 2
		
	IF @CashMode = 1
		SET @InvoiceTypeCode = 3
	ELSE
		SET @InvoiceTypeCode = 1
		
	RETURN 
GO
CREATE PROCEDURE Task.proc_DefaultPaymentOn
	(
		@AccountCode NVARCHAR(10),
		@ActionOn DATETIME,
		@PaymentOn DATETIME OUTPUT
	)
  AS
		
	SET @PaymentOn = Task.fnDefaultPaymentOn(@AccountCode, @ActionOn)
	
	RETURN 
GO
CREATE PROCEDURE Task.proc_DefaultTaxCode 
	(
	@AccountCode NVARCHAR(10),
	@CashCode NVARCHAR(50),
	@TaxCode NVARCHAR(10) OUTPUT
	)
  AS

	SET @TaxCode = Task.fnDefaultTaxCode(@AccountCode, @CashCode)
		
	RETURN
GO
CREATE PROCEDURE Task.proc_Delete 
	(
	@TaskCode NVARCHAR(20)
	)
  AS

DECLARE @ChildTaskCode NVARCHAR(20)

	DELETE FROM Task.tbFlow
	WHERE     (ChildTaskCode = @TaskCode)

	DECLARE curFlow CURSOR LOCAL FOR
		SELECT     ChildTaskCode
		FROM         Task.tbFlow
		WHERE     (ParentTaskCode = @TaskCode)
	
	OPEN curFlow		
	FETCH NEXT FROM curFlow INTO @ChildTaskCode
	WHILE @@FETCH_STATUS = 0
		BEGIN
		EXEC Task.proc_Delete @ChildTaskCode
		FETCH NEXT FROM curFlow INTO @ChildTaskCode		
		END
	
	CLOSE curFlow
	DEALLOCATE curFlow
	
	DELETE FROM Task.tbTask
	WHERE (TaskCode = @TaskCode)
	
	RETURN
GO
CREATE PROCEDURE Task.proc_EmailAddress 
	(
	@TaskCode NVARCHAR(20),
	@EmailAddress NVARCHAR(255) OUTPUT
	)
  AS
	IF EXISTS(SELECT     Org.tbContact.EmailAddress
	          FROM         Org.tbContact INNER JOIN
	                                Task.tbTask ON Org.tbContact.AccountCode = Task.tbTask.AccountCode AND Org.tbContact.ContactName = Task.tbTask.ContactName
	          WHERE     ( Task.tbTask.TaskCode = @TaskCode)
	          GROUP BY Org.tbContact.EmailAddress
	          HAVING      (NOT ( Org.tbContact.EmailAddress IS NULL)))
		BEGIN
		SELECT    @EmailAddress = Org.tbContact.EmailAddress
		FROM         Org.tbContact INNER JOIN
							tbTask ON Org.tbContact.AccountCode = Task.tbTask.AccountCode AND Org.tbContact.ContactName = Task.tbTask.ContactName
		WHERE     ( Task.tbTask.TaskCode = @TaskCode)
		GROUP BY Org.tbContact.EmailAddress
		HAVING      (NOT ( Org.tbContact.EmailAddress IS NULL))	
		END
	ELSE
		BEGIN
		SELECT    @EmailAddress =  Org.tbOrg.EmailAddress
		FROM         Org.tbOrg INNER JOIN
							 Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode
		WHERE     ( Task.tbTask.TaskCode = @TaskCode)
		END
		
	RETURN
GO
CREATE PROCEDURE Task.proc_EmailDetail 
	(
	@TaskCode NVARCHAR(20)
	)
  AS
DECLARE @NickName NVARCHAR(100)
DECLARE @EmailAddress NVARCHAR(255)


	IF EXISTS(SELECT     Org.tbContact.ContactName
	          FROM         Org.tbContact INNER JOIN
	                                Task.tbTask ON Org.tbContact.AccountCode = Task.tbTask.AccountCode AND Org.tbContact.ContactName = Task.tbTask.ContactName
	          WHERE     ( Task.tbTask.TaskCode = @TaskCode))
		BEGIN
		SELECT  @NickName = CASE WHEN Org.tbContact.NickName is null then Org.tbContact.ContactName ELSE Org.tbContact.NickName END
					  FROM         Org.tbContact INNER JOIN
											tbTask ON Org.tbContact.AccountCode = Task.tbTask.AccountCode AND Org.tbContact.ContactName = Task.tbTask.ContactName
					  WHERE     ( Task.tbTask.TaskCode = @TaskCode)				
		END
	ELSE
		BEGIN
		SELECT @NickName = ContactName
		FROM         Task.tbTask
		WHERE     (TaskCode = @TaskCode)
		END
	
	EXEC Task.proc_EmailAddress	@TaskCode, @EmailAddress OUTPUT
	
	SELECT     Task.tbTask.TaskCode, Task.tbTask.TaskTitle, Org.tbOrg.AccountCode, Org.tbOrg.AccountName, @NickName AS NickName, @EmailAddress AS EmailAddress, 
	                      Task.tbTask.ActivityCode, Task.tbStatus.TaskStatus, Task.tbTask.TaskNotes
	FROM         Task.tbTask INNER JOIN
	                      Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
	                      Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode
	WHERE     ( Task.tbTask.TaskCode = @TaskCode)

	RETURN
GO
CREATE PROCEDURE Task.proc_EmailFooter 
  AS
DECLARE @AccountName NVARCHAR(255)
DECLARE @WebSite NVARCHAR(255)

	SELECT TOP 1 @AccountName = Org.tbOrg.AccountName, @WebSite = Org.tbOrg.WebSite
	FROM         Org.tbOrg INNER JOIN
	                      App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode
	
	SELECT     Usr.tbUser.UserName, Usr.tbUser.PhoneNumber, Usr.tbUser.MobileNumber, @AccountName AS AccountName, @Website AS Website
	FROM         Usr.vwCredentials INNER JOIN
	                      Usr.tbUser ON Usr.vwCredentials.UserId = Usr.tbUser.UserId
	
	RETURN
GO
CREATE PROCEDURE Task.proc_FullyInvoiced
	(
	@TaskCode NVARCHAR(20),
	@IsFullyInvoiced BIT = 0 OUTPUT
	)
AS
DECLARE @InvoiceValue MONEY
DECLARE @TotalCharge MONEY

	SELECT @InvoiceValue = SUM(InvoiceValue)
	FROM         Invoice.tbTask
	WHERE     (TaskCode = @TaskCode)
	
	
	SELECT @TotalCharge = SUM(TotalCharge)
	FROM         Task.tbTask
	WHERE     (TaskCode = @TaskCode)
	
	IF (@TotalCharge = @InvoiceValue)
		SET @IsFullyInvoiced = 1
	ELSE
		SET @IsFullyInvoiced = 0
		
	RETURN
GO
CREATE PROCEDURE Task.proc_IsProject 
	(
	@TaskCode NVARCHAR(20),
	@IsProject BIT = 0 OUTPUT
	)
  AS
	IF EXISTS(SELECT     TOP 1 Attribute
	          FROM         Task.tbAttribute
	          WHERE     (TaskCode = @TaskCode))
		SET @IsProject = 1
	ELSE IF EXISTS (SELECT     TOP 1 ParentTaskCode, StepNumber
	                FROM         Task.tbFlow
	                WHERE     (ParentTaskCode = @TaskCode))
		SET @IsProject = 1
	ELSE
		SET @IsProject = 0
	RETURN
GO
CREATE PROCEDURE Task.proc_Mode 
	(
	@TaskCode NVARCHAR(20)
	)
  AS
	SELECT     Task.tbTask.AccountCode, Task.tbTask.ActivityCode, Task.tbTask.TaskStatusCode, Task.tbTask.ActionOn, Task.vwCashMode.CashModeCode
	FROM         Task.tbTask LEFT OUTER JOIN
	                      Task.vwCashMode ON Task.tbTask.TaskCode = Task.vwCashMode.TaskCode
	WHERE     ( Task.tbTask.TaskCode = @TaskCode)
	RETURN
GO
CREATE PROCEDURE Task.proc_NextAttributeOrder 
	(
	@TaskCode NVARCHAR(20),
	@PrintOrder SMALLINT = 10 OUTPUT
	)
  AS
	IF EXISTS(SELECT     TOP 1 PrintOrder
	          FROM         Task.tbAttribute
	          WHERE     (TaskCode = @TaskCode))
		BEGIN
		SELECT  @PrintOrder = MAX(PrintOrder) 
		FROM         Task.tbAttribute
		WHERE     (TaskCode = @TaskCode)
		SET @PrintOrder = @PrintOrder - (@PrintOrder % 10) + 10		
		END
	ELSE
		SET @PrintOrder = 10
		
	RETURN
GO
CREATE PROCEDURE Task.proc_NextOperationNumber 
	(
	@TaskCode NVARCHAR(20),
	@OperationNumber SMALLINT = 10 OUTPUT
	)
  AS
	IF EXISTS(SELECT     TOP 1 OperationNumber
	          FROM         Task.tbOp
	          WHERE     (TaskCode = @TaskCode))
		BEGIN
		SELECT  @OperationNumber = MAX(OperationNumber) 
		FROM         Task.tbOp
		WHERE     (TaskCode = @TaskCode)
		SET @OperationNumber = @OperationNumber - (@OperationNumber % 10) + 10		
		END
	ELSE
		SET @OperationNumber = 10
		
	RETURN
GO
CREATE PROCEDURE Task.proc_Op
	(
	@TaskCode NVARCHAR(20)
	)
AS
		IF EXISTS (SELECT     TaskCode
	           FROM         Task.tbOp
	           WHERE     (TaskCode = @TaskCode))
	    BEGIN
		SELECT     Task.tbOp.*
		       FROM         Task.tbOp
		       WHERE     (TaskCode = @TaskCode)
		END
	ELSE
		BEGIN
		SELECT     Task.tbOp.*
		       FROM         Task.tbFlow INNER JOIN
		                             Task.tbOp ON Task.tbFlow.ParentTaskCode = Task.tbOp.TaskCode
		       WHERE     ( Task.tbFlow.ChildTaskCode = @TaskCode)
		END
		
	RETURN
GO
CREATE PROCEDURE Task.proc_Parent 
	(
	@TaskCode NVARCHAR(20),
	@ParentTaskCode NVARCHAR(20) OUTPUT
	)
  AS
	SET @ParentTaskCode = @TaskCode
	IF EXISTS(SELECT     ParentTaskCode
	             FROM         Task.tbFlow
	             WHERE     (ChildTaskCode = @ParentTaskCode))
		SELECT @ParentTaskCode = ParentTaskCode
	             FROM         Task.tbFlow
	             WHERE     (ChildTaskCode = @ParentTaskCode)
		
	RETURN
GO
CREATE PROCEDURE Task.proc_Profit
	(
	@ParentTaskCode NVARCHAR(20),
	@TotalCost MONEY = 0 OUTPUT,
	@InvoicedCost MONEY = 0 OUTPUT,
	@InvoicedCostPaid MONEY = 0 OUTPUT
	)
AS
DECLARE @TaskCode NVARCHAR(20)
DECLARE @TotalCharge MONEY
DECLARE @TotalInvoiced MONEY
DECLARE @TotalPaid MONEY
DECLARE @CashModeCode SMALLINT

	DECLARE curFlow CURSOR LOCAL FOR
		SELECT     Task.tbTask.TaskCode, Task.vwCashMode.CashModeCode, Task.tbTask.TotalCharge
		FROM         Task.tbTask INNER JOIN
							  Task.tbFlow ON Task.tbTask.TaskCode = Task.tbFlow.ChildTaskCode INNER JOIN
							  Task.vwCashMode ON Task.tbTask.TaskCode = Task.vwCashMode.TaskCode
		WHERE     ( Task.tbFlow.ParentTaskCode = @ParentTaskCode)	

	OPEN curFlow
	FETCH NEXT FROM curFlow INTO @TaskCode, @CashModeCode, @TotalCharge
	WHILE @@FETCH_STATUS = 0
		BEGIN
		
		SELECT  @TotalInvoiced = SUM(CASE WHEN Invoice.tbType.CashModeCode = 1 THEN Invoice.tbTask.InvoiceValue * - 1 ELSE Invoice.tbTask.InvoiceValue END), 
				@TotalPaid = SUM(CASE WHEN Invoice.tbType.CashModeCode = 1 THEN Invoice.tbTask.PaidValue * - 1 ELSE Invoice.tbTask.PaidValue END) 	                      
		FROM         Invoice.tbTask INNER JOIN
							  Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		WHERE     ( Invoice.tbTask.TaskCode = @TaskCode)

		SET @InvoicedCost = @InvoicedCost + @TotalInvoiced
		SET @InvoicedCostPaid = @InvoicedCostPaid + @TotalPaid
		SET @TotalCost = @TotalCost + CASE WHEN @CashModeCode = 1 then @TotalCharge ELSE @TotalCharge * -1 END
			
		EXEC Task.proc_Profit @TaskCode, @TotalCost OUTPUT, @InvoicedCost OUTPUT, @InvoicedCostPaid OUTPUT
		FETCH NEXT FROM curFlow INTO @TaskCode, @CashModeCode, @TotalCharge
		END
	
	CLOSE curFlow
	DEALLOCATE curFlow
	RETURN

GO
CREATE PROCEDURE Task.proc_ProfitTopLevel
	(
	@TaskCode NVARCHAR(20),
	@InvoicedCharge MONEY = 0 OUTPUT,
	@InvoicedChargePaid MONEY = 0 OUTPUT,
	@TotalCost MONEY = 0 OUTPUT,
	@InvoicedCost MONEY = 0 OUTPUT,
	@InvoicedCostPaid MONEY = 0 OUTPUT
	)
AS
			
	SELECT  @InvoicedCharge = SUM(CASE WHEN Invoice.tbType.CashModeCode = 1 THEN Invoice.tbTask.InvoiceValue * - 1 ELSE Invoice.tbTask.InvoiceValue END), 
	@InvoicedChargePaid = SUM(CASE WHEN Invoice.tbType.CashModeCode = 1 THEN Invoice.tbTask.PaidValue * - 1 ELSE Invoice.tbTask.PaidValue END) 	                      
	FROM         Invoice.tbTask INNER JOIN
	                      Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
	                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	WHERE     ( Invoice.tbTask.TaskCode = @TaskCode)
	
	SET @TotalCost = 0
	EXEC Task.proc_Profit @TaskCode, @TotalCost OUTPUT, @InvoicedCost OUTPUT, @InvoicedCostPaid OUTPUT	
	
	RETURN

GO
CREATE PROCEDURE Task.proc_Project 
	(
	@TaskCode NVARCHAR(20),
	@ParentTaskCode NVARCHAR(20) OUTPUT
	)
  AS
	SET @ParentTaskCode = @TaskCode
	WHILE EXISTS(SELECT     ParentTaskCode
	             FROM         Task.tbFlow
	             WHERE     (ChildTaskCode = @ParentTaskCode))
		SELECT @ParentTaskCode = ParentTaskCode
	             FROM         Task.tbFlow
	             WHERE     (ChildTaskCode = @ParentTaskCode)
		
	RETURN
GO
CREATE PROCEDURE Task.proc_ReconcileCharge
	(
	@TaskCode NVARCHAR(20)
	)
AS
DECLARE @InvoiceValue MONEY

	SELECT @InvoiceValue = SUM(InvoiceValue)
	FROM         Invoice.tbTask
	WHERE     (TaskCode = @TaskCode)

	UPDATE    Task.tbTask
	SET              TotalCharge = @InvoiceValue, UnitCharge = @InvoiceValue / Quantity
	WHERE     (TaskCode = @TaskCode)	
	
	RETURN
GO
CREATE PROCEDURE Task.proc_ReSETChargedUninvoiced
AS
	UPDATE       Task
	SET                TaskStatusCode = 3
	FROM            Cash.tbCode INNER JOIN
							 Task.tbTask AS Task ON Cash.tbCode.CashCode = Task.CashCode LEFT OUTER JOIN
							 Invoice.tbTask AS InvoiceTask ON Task.TaskCode = InvoiceTask.TaskCode AND Task.TaskCode = InvoiceTask.TaskCode
	WHERE        (InvoiceTask.InvoiceNumber IS NULL) AND (Task.TaskStatusCode = 4)
	RETURN
GO
CREATE PROCEDURE Task.proc_ScheduleOp
	(
	@TaskCode NVARCHAR(20),
	@ActionOn DATETIME
	)	
AS
DECLARE @OperationNumber SMALLINT
DECLARE @OpStatusCode SMALLINT
DECLARE @CallOffOpNo SMALLINT

DECLARE @EndOn DATETIME
DECLARE @StartOn DATETIME
DECLARE @OffSETDays SMALLINT

DECLARE @UserId NVARCHAR(10)
	
	SELECT @UserId = ActionById
	FROM Task.tbTask WHERE TaskCode = @TaskCode	
	
	SET @EndOn = @ActionOn

	SELECT @CallOffOpNo = MIN(OperationNumber)
	FROM         Task.tbOp
	WHERE     (TaskCode = @TaskCode) AND (OpTypeCode = 2)	
	
	SET @CallOffOpNo = ISNULL(@CallOffOpNo, 0)
	
	DECLARE curOp CURSOR LOCAL FOR
		SELECT     OperationNumber, OffSETDays, OpStatusCode, EndOn
		FROM         Task.tbOp
		WHERE     (TaskCode = @TaskCode) AND ((OperationNumber <= @CallOffOpNo) OR (@CallOffOpNo = 0)) 
		ORDER BY OperationNumber DESC
	
	OPEN curOp
	FETCH NEXT FROM curOp INTO @OperationNumber, @OffSETDays, @OpStatusCode, @ActionOn
	WHILE @@FETCH_STATUS = 0
		BEGIN			
		IF (@OpStatusCode < 3 ) 
			BEGIN
			SET @StartOn = App.fnAdjustToCalendar(@UserId, @EndOn, @OffSETDays)
			UPDATE Task.tbOp
			SET EndOn = @EndOn, StartOn = @StartOn
			WHERE TaskCode = @TaskCode and OperationNumber = @OperationNumber			
			END
		ELSE
			BEGIN			
			SET @StartOn = App.fnAdjustToCalendar(@UserId, @ActionOn, @OffSETDays)
			END
		SET @EndOn = @StartOn			
		FETCH NEXT FROM curOp INTO @OperationNumber, @OffSETDays, @OpStatusCode, @ActionOn
		END
	CLOSE curOp
	DEALLOCATE curOp
	
	RETURN
GO
CREATE  PROCEDURE Task.proc_Schedule
	(
	@ParentTaskCode NVARCHAR(20),
	@ActionOn DATETIME = null OUTPUT
	)
   AS
DECLARE @UserId NVARCHAR(10)
DECLARE @AccountCode NVARCHAR(10)
DECLARE @StepNumber SMALLINT
DECLARE @TaskCode NVARCHAR(20)
DECLARE @OffSETDays SMALLINT
DECLARE @UsedOnQuantity FLOAT
DECLARE @Quantity FLOAT
DECLARE @PaymentDays SMALLINT
DECLARE @PaymentOn DATETIME

	IF @ActionOn is null
		BEGIN				
		SELECT @ActionOn = ActionOn, @UserId = ActionById 
		FROM Task.tbTask WHERE TaskCode = @ParentTaskCode
		
		IF @ActionOn != App.fnAdjustToCalendar(@UserId, @ActionOn, 0)
			BEGIN
			SET @ActionOn = App.fnAdjustToCalendar(@UserId, @ActionOn, 0)
			UPDATE Task.tbTask
			SET ActionOn = @ActionOn
			WHERE TaskCode = @ParentTaskCode and TaskStatusCode < 3			
			END
		END
	
	SELECT @PaymentDays = Org.tbOrg.PaymentDays, @PaymentOn = Task.tbTask.PaymentOn, @AccountCode = Task.tbTask.AccountCode
	FROM         Org.tbOrg INNER JOIN
	                      Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode
	WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode)
	
	IF (@PaymentOn != Task.fnDefaultPaymentOn(@AccountCode, @ActionOn))
		BEGIN
		UPDATE Task.tbTask
		SET PaymentOn = Task.fnDefaultPaymentOn(AccountCode, ActionOn)
		WHERE TaskCode = @ParentTaskCode and TaskStatusCode < 3
		END
	
	IF EXISTS(SELECT TOP 1 OperationNumber
	          FROM         Task.tbOp
	          WHERE     (TaskCode = @ParentTaskCode))
		BEGIN
		EXEC Task.proc_ScheduleOp @ParentTaskCode, @ActionOn
		END
	
	Select @Quantity = Quantity FROM Task.tbTask WHERE TaskCode = @ParentTaskCode
	
	DECLARE curAct CURSOR LOCAL FOR
		SELECT     Task.tbFlow.StepNumber, Task.tbFlow.ChildTaskCode, Task.tbTask.AccountCode, Task.tbTask.ActionById, Task.tbFlow.OffSETDays, Task.tbFlow.UsedOnQuantity, 
		                      Org.tbOrg.PaymentDays
		FROM         Task.tbFlow INNER JOIN
		                      Task.tbTask ON Task.tbFlow.ChildTaskCode = Task.tbTask.TaskCode INNER JOIN
		                      Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode
		WHERE     ( Task.tbFlow.ParentTaskCode = @ParentTaskCode)
		ORDER BY Task.tbFlow.StepNumber DESC
	
	OPEN curAct
	FETCH NEXT FROM curAct INTO @StepNumber, @TaskCode, @AccountCode, @UserId, @OffSETDays, @UsedOnQuantity, @PaymentDays
	WHILE @@FETCH_STATUS = 0
		BEGIN
		SET @ActionOn = App.fnAdjustToCalendar(@UserId, @ActionOn, @OffSETDays)
		SET @PaymentOn = Task.fnDefaultPaymentOn(@AccountCode, @ActionOn)
		
		UPDATE Task.tbTask
		SET ActionOn = @ActionOn, 
			PaymentOn = @PaymentOn,
			Quantity = @Quantity * @UsedOnQuantity,
			TotalCharge = CASE WHEN @UsedOnQuantity = 0 then UnitCharge ELSE UnitCharge * @Quantity * @UsedOnQuantity END,
			UpdatedOn = SYSDATETIME(),
			UpdatedBy = (SUSER_SNAME())
		WHERE TaskCode = @TaskCode and TaskStatusCode < 3
		
		EXEC Task.proc_Schedule @TaskCode, @ActionOn OUTPUT
		FETCH NEXT FROM curAct INTO @StepNumber, @TaskCode, @AccountCode, @UserId, @OffSETDays, @UsedOnQuantity, @PaymentDays
		END
	
	CLOSE curAct
	DEALLOCATE curAct	
	
	RETURN
GO
CREATE PROCEDURE Task.proc_SetActionOn
	(
	@TaskCode NVARCHAR(20)
	)
AS
DECLARE @OperationNumber SMALLINT
DECLARE @OpTypeCode SMALLINT
DECLARE @ActionOn DATETIME
		
	SELECT @OperationNumber = MAX(OperationNumber)
	FROM         Task.tbOp
	WHERE     (TaskCode = @TaskCode)
	
	
	SELECT @OpTypeCode = OpTypeCode, @ActionOn = EndOn
	FROM         Task.tbOp
	WHERE     (TaskCode = @TaskCode) AND (OperationNumber = @OperationNumber)

	IF @OpTypeCode = 2
		BEGIN
		SELECT @OperationNumber = MIN(OperationNumber)
		FROM         Task.tbOp
		WHERE     (TaskCode = @TaskCode) AND (OpTypeCode = 2)
		
		SELECT @ActionOn = EndOn
		FROM         Task.tbOp
		WHERE     (TaskCode = @TaskCode) AND (OperationNumber = @OperationNumber)
				
		END
		
	UPDATE    Task.tbTask
	SET              ActionOn = @ActionOn
	WHERE     (TaskCode = @TaskCode) AND (ActionOn <> @ActionOn)

		
	RETURN
GO
CREATE PROCEDURE Task.proc_SetOpStatus
	(
		@TaskCode NVARCHAR(20),
		@TaskStatusCode SMALLINT
	)
AS
DECLARE @OpStatusCode SMALLINT
DECLARE @OperationNumber SMALLINT
	
	SET @OpStatusCode = CASE @TaskStatusCode
							WHEN 1 THEN 1
							WHEN 2 THEN 2
							ELSE 3
						END
	
	IF EXISTS(SELECT TOP 1 OperationNumber
	          FROM         Task.tbOp
	          WHERE     (TaskCode = @TaskCode))
		BEGIN
		UPDATE    Task.tbOp
		SET              OpStatusCode = @OpStatusCode
		WHERE     (OpTypeCode = 1) AND (TaskCode = @TaskCode)
		
		IF EXISTS (SELECT TOP 1 OperationNumber
	          FROM         Task.tbOp
	          WHERE     (TaskCode = @TaskCode) AND (OpTypeCode = 2))
	        BEGIN
			SELECT @OperationNumber = MIN(OperationNumber)
			FROM         Task.tbOp
			WHERE     (OpTypeCode = 2) AND (TaskCode = @TaskCode)	          
				          
			UPDATE    Task.tbOp
			SET              OpStatusCode = @OpStatusCode
			WHERE     (OperationNumber = @OperationNumber) AND (TaskCode = @TaskCode)
	        END
		END
		
	RETURN
GO
CREATE PROCEDURE Task.proc_SetStatus
	(
		@TaskCode NVARCHAR(20)
	)
  AS
DECLARE @ChildTaskCode NVARCHAR(20)
DECLARE @TaskStatusCode SMALLINT
DECLARE @CashCode NVARCHAR(20)
DECLARE @IsOrder BIT

	SELECT @TaskStatusCode = TaskStatusCode, @CashCode = CashCode
	FROM Task.tbTask
	WHERE TaskCode = @TaskCode
	
	EXEC Task.proc_SetOpStatus @TaskCode, @TaskStatusCode
	
	IF @CashCode IS NULL
		SET @IsOrder = 0
	ELSE
		SET @IsOrder = 1
	
	DECLARE curTask CURSOR LOCAL FOR
		SELECT     Task.tbFlow.ChildTaskCode
		FROM         Task.tbFlow INNER JOIN
		                      Task.tbTask ON Task.tbFlow.ChildTaskCode = Task.tbTask.TaskCode
		WHERE     ( Task.tbFlow.ParentTaskCode = @TaskCode)

	OPEN curTask
	FETCH NEXT FROM curTask INTO @ChildTaskCode
	WHILE @@FETCH_STATUS = 0
		BEGIN
		
		IF @IsOrder = 1 AND @TaskStatusCode <> 6
			BEGIN
			UPDATE    Task.tbTask
			SET              TaskStatusCode = @TaskStatusCode
			WHERE     (TaskCode = @ChildTaskCode) AND (TaskStatusCode < 3) AND (NOT (CashCode IS NULL))
			EXEC Task.proc_SetOpStatus @ChildTaskCode, @TaskStatusCode
			END
		ELSE IF @IsOrder = 0
			BEGIN
			UPDATE    Task.tbTask
			SET              TaskStatusCode = @TaskStatusCode
			WHERE     (TaskCode = @ChildTaskCode) AND (TaskStatusCode < 3) AND (CashCode IS NULL)			
			END		
		
		IF (@TaskStatusCode <> 4)	
			EXEC Task.proc_SetStatus @ChildTaskCode
		FETCH NEXT FROM curTask INTO @ChildTaskCode
		END
		
	CLOSE curTask
	DEALLOCATE curTask
		
	RETURN 
GO
CREATE PROCEDURE Task.proc_WorkFlow 
	(
	@TaskCode NVARCHAR(20)
	)
  AS
	SELECT     Task.tbFlow.ParentTaskCode, Task.tbFlow.StepNumber, Task.tbTask.TaskCode, Task.tbTask.AccountCode, Task.tbTask.ActivityCode, Task.tbTask.TaskStatusCode, 
	                      Task.tbTask.ActionOn, Task.vwCashMode.CashModeCode, Task.tbFlow.OffSETDays
	FROM         Task.tbTask INNER JOIN
	                      Task.tbFlow ON Task.tbTask.TaskCode = Task.tbFlow.ChildTaskCode LEFT OUTER JOIN
	                      Task.vwCashMode ON Task.tbTask.TaskCode = Task.vwCashMode.TaskCode
	WHERE     ( Task.tbFlow.ParentTaskCode = @TaskCode)
	ORDER BY Task.tbFlow.StepNumber, Task.tbFlow.ParentTaskCode
	RETURN
GO
