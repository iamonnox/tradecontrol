UPDATE App.tbOptions
SET SQLDataVersion = 3.10
go
ALTER TABLE Invoice.tbTask WITH NOCHECK ADD
	TotalValue money NOT NULL CONSTRAINT DF_Invoice_tbTask_TotalValue DEFAULT (0)
go
ALTER TABLE Invoice.tbItem WITH NOCHECK ADD
	TotalValue money NOT NULL CONSTRAINT DF_Invoice_tbItem_TotalValue DEFAULT (0)
go
UPDATE Invoice.tbTask
SET TotalValue = InvoiceValue + TaxValue;

UPDATE Invoice.tbItem
SET TotalValue = InvoiceValue + TaxValue;
go
CREATE OR ALTER TRIGGER Invoice.Invoice_tbItem_TriggerInsert
ON Invoice.tbItem
FOR INSERT
AS
	SET NOCOUNT ON;

	BEGIN TRY

		UPDATE item
		SET InvoiceValue = ROUND(inserted.TotalValue / (1 + TaxRate), 2)
		FROM inserted 
			INNER JOIN Invoice.tbItem item ON inserted.InvoiceNumber = item.InvoiceNumber 
					AND inserted.CashCode = item.CashCode
				INNER JOIN App.tbTaxCode ON inserted.TaxCode = App.tbTaxCode.TaxCode 
		WHERE inserted.TotalValue <> 0;

		UPDATE item
		SET TaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND(item.InvoiceValue * App.tbTaxCode.TaxRate, 2)
				WHEN 1 THEN ROUND( item.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END
		FROM Invoice.tbItem item 
			INNER JOIN inserted ON inserted.InvoiceNumber = item.InvoiceNumber
					 AND inserted.CashCode = item.CashCode
				INNER JOIN App.tbTaxCode ON item.TaxCode = App.tbTaxCode.TaxCode; 

		UPDATE item
		SET TotalValue = item.InvoiceValue + item.TaxValue
		FROM inserted 
			INNER JOIN Invoice.tbItem item ON inserted.InvoiceNumber = item.InvoiceNumber
				 AND inserted.CashCode = item.CashCode
		WHERE inserted.TotalValue = 0;

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER TRIGGER Invoice.Invoice_tbItem_TriggerUpdate
ON Invoice.tbItem
FOR UPDATE
AS
	SET NOCOUNT ON;

	BEGIN TRY

	IF UPDATE(TotalValue)
		BEGIN
		UPDATE item
		SET InvoiceValue = ROUND(inserted.TotalValue / (1 + TaxRate), 2)
		FROM inserted 
			INNER JOIN Invoice.tbItem item ON inserted.InvoiceNumber = item.InvoiceNumber 
					AND inserted.CashCode = item.CashCode
				INNER JOIN App.tbTaxCode ON inserted.TaxCode = App.tbTaxCode.TaxCode;
		END

	UPDATE item
	SET TaxValue = CASE App.tbTaxCode.RoundingCode 
			WHEN 0 THEN ROUND(item.InvoiceValue * App.tbTaxCode.TaxRate, 2)
			WHEN 1 THEN ROUND( item.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END
	FROM Invoice.tbItem item 
		INNER JOIN inserted ON inserted.InvoiceNumber = item.InvoiceNumber
					AND inserted.CashCode = item.CashCode
			INNER JOIN App.tbTaxCode ON item.TaxCode = App.tbTaxCode.TaxCode; 

	IF UPDATE(InvoiceValue)
		BEGIN
		UPDATE item
		SET TotalValue = item.InvoiceValue + item.TaxValue
		FROM inserted 
			INNER JOIN Invoice.tbItem item ON inserted.InvoiceNumber = item.InvoiceNumber
					AND inserted.CashCode = item.CashCode;
		END

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER TRIGGER Invoice.Invoice_tbTask_TriggerInsert
ON Invoice.tbTask
FOR INSERT
AS
	SET NOCOUNT ON;

	BEGIN TRY

		UPDATE task
		SET InvoiceValue = ROUND(inserted.TotalValue / (1 + TaxRate), 2)
		FROM inserted 
			INNER JOIN Invoice.tbTask task ON inserted.InvoiceNumber = task.InvoiceNumber 
					AND inserted.TaskCode = task.TaskCode
				INNER JOIN App.tbTaxCode ON inserted.TaxCode = App.tbTaxCode.TaxCode 
		WHERE inserted.TotalValue <> 0;

		UPDATE task
		SET TaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND(task.InvoiceValue * App.tbTaxCode.TaxRate, 2)
				WHEN 1 THEN ROUND( task.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END
		FROM Invoice.tbTask task 
			INNER JOIN inserted ON inserted.InvoiceNumber = task.InvoiceNumber
					 AND inserted.TaskCode = task.TaskCode
				INNER JOIN App.tbTaxCode ON task.TaxCode = App.tbTaxCode.TaxCode; 

		UPDATE task
		SET TotalValue = task.InvoiceValue + task.TaxValue
		FROM inserted 
			INNER JOIN Invoice.tbTask task ON inserted.InvoiceNumber = task.InvoiceNumber
				 AND inserted.TaskCode = task.TaskCode
		WHERE inserted.TotalValue = 0;

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER TRIGGER Invoice.Invoice_tbTask_TriggerUpdate
ON Invoice.tbTask
FOR UPDATE
AS
	SET NOCOUNT ON;

	BEGIN TRY

	IF UPDATE(TotalValue)
		BEGIN
		UPDATE task
		SET InvoiceValue = ROUND(inserted.TotalValue / (1 + TaxRate), 2)
		FROM inserted 
			INNER JOIN Invoice.tbTask task ON inserted.InvoiceNumber = task.InvoiceNumber 
					AND inserted.TaskCode = task.TaskCode
				INNER JOIN App.tbTaxCode ON inserted.TaxCode = App.tbTaxCode.TaxCode;
		END

	UPDATE task
	SET TaxValue = CASE App.tbTaxCode.RoundingCode 
			WHEN 0 THEN ROUND(task.InvoiceValue * App.tbTaxCode.TaxRate, 2)
			WHEN 1 THEN ROUND( task.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END
	FROM Invoice.tbTask task 
		INNER JOIN inserted ON inserted.InvoiceNumber = task.InvoiceNumber
					AND inserted.TaskCode = task.TaskCode
			INNER JOIN App.tbTaxCode ON task.TaxCode = App.tbTaxCode.TaxCode; 

	IF UPDATE(InvoiceValue)
		BEGIN
		UPDATE task
		SET TotalValue = task.InvoiceValue + task.TaxValue
		FROM inserted 
			INNER JOIN Invoice.tbTask task ON inserted.InvoiceNumber = task.InvoiceNumber
					AND inserted.TaskCode = task.TaskCode;
		END

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER TRIGGER Invoice.Invoice_tbTask_TriggerDelete
ON Invoice.tbTask
FOR DELETE
AS
	SET NOCOUNT ON;

	BEGIN TRY
		UPDATE Task.tbTask
		SET TaskStatusCode = 2
		FROM deleted JOIN Task.tbTask ON deleted.TaskCode = Task.tbTask.TaskCode
		WHERE TaskStatusCode = 3;		
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

ALTER PROCEDURE [Invoice].[proc_Total] 
	(
	@InvoiceNumber nvarchar(20)
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		WITH totals AS
		(
			SELECT InvoiceNumber, SUM(InvoiceValue) AS InvoiceValue, 
				SUM(TaxValue) AS TaxValue,
				SUM(PaidValue) AS PaidValue, 
				SUM(PaidTaxValue) AS PaidTaxValue
			FROM         Invoice.tbTask
			GROUP BY InvoiceNumber
			HAVING      (InvoiceNumber = @InvoiceNumber)
			UNION
			SELECT InvoiceNumber, SUM(InvoiceValue) AS InvoiceValue, 
				SUM(TaxValue) AS TaxValue,
				SUM(PaidValue) AS PaidValue, 
				SUM(PaidTaxValue) AS PaidTaxValue
			FROM         Invoice.tbItem
			GROUP BY InvoiceNumber
			HAVING      (InvoiceNumber = @InvoiceNumber)
		), grand_total AS
		(
			SELECT InvoiceNumber, ISNULL(SUM(InvoiceValue), 0) AS InvoiceValue, 
				ISNULL(SUM(TaxValue), 0) AS TaxValue, 
				ISNULL(SUM(PaidValue), 0) AS PaidValue, 
				ISNULL(SUM(PaidTaxValue), 0) AS PaidTaxValue
			FROM totals
			GROUP BY InvoiceNumber
		) 
		UPDATE    Invoice.tbInvoice
		SET InvoiceValue = grand_total.InvoiceValue, TaxValue = grand_total.TaxValue,
			PaidValue = grand_total.PaidValue, PaidTaxValue = grand_total.PaidTaxValue,
			InvoiceStatusCode = CASE 
					WHEN grand_total.PaidValue >= grand_total.InvoiceValue THEN 3 
					WHEN grand_total.PaidValue > 0 THEN 2 
					ELSE 1 END
		FROM Invoice.tbInvoice INNER JOIN grand_total ON Invoice.tbInvoice.InvoiceNumber = grand_total.InvoiceNumber;
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

ALTER TABLE [Cash].[tbTaxType]  
	DROP CONSTRAINT [FK_Cash_tbTaxType_Org_tbAccount],
	COLUMN [CashAccountCode]
go
ALTER TABLE Cash.tbTaxType WITH NOCHECK ADD
	OffsetDays SMALLINT NOT NULL CONSTRAINT DF_Cash_tbTaxType_OffsetDays DEFAULT (0)
go
UPDATE Cash.tbTaxType
SET OffsetDays = 31
WHERE TaxTypeCode = 1;
go

ALTER  FUNCTION [Cash].[fnTaxTypeDueDates](@TaxTypeCode smallint)
RETURNS @tbDueDate TABLE (PayOn datetime, PayFrom datetime, PayTo datetime)
 AS
	BEGIN
 	DECLARE @MonthNumber smallint
		, @RecurrenceCode smallint
		, @MonthInterval smallint
		, @StartOn datetime
	
	SELECT @MonthNumber = MonthNumber, @RecurrenceCode = RecurrenceCode
	FROM Cash.tbTaxType
	WHERE TaxTypeCode = @TaxTypeCode
	
	SET @MonthInterval = CASE @RecurrenceCode
		WHEN 0 THEN 1
		WHEN 1 THEN 1
		WHEN 2 THEN 3
		WHEN 3 THEN 6
		WHEN 4 THEN 12
		END
				
	SELECT   @StartOn = MIN(StartOn)
	FROM         App.tbYearPeriod
	WHERE     (MonthNumber = @MonthNumber)
	ORDER BY MIN(StartOn)

	
	INSERT INTO @tbDueDate (PayOn) VALUES (@StartOn)
	
	SET @MonthNumber = CASE 
		WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
		ELSE (@MonthNumber + @MonthInterval) % 12
		END
	
	WHILE EXISTS(SELECT     MonthNumber
	             FROM         App.tbYearPeriod
	             WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber))
		BEGIN
		SELECT @StartOn = MIN(StartOn)
	    FROM         App.tbYearPeriod
	    WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber)
		ORDER BY MIN(StartOn)		
		INSERT INTO @tbDueDate (PayOn) VALUES (@StartOn)
		
		SET @MonthNumber = CASE 
			WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
			ELSE (@MonthNumber + @MonthInterval) % 12
			END
		
		END
		
	--CorporationTax
	IF (@TaxTypeCode = 0)		
		BEGIN
		DECLARE @PayOn datetime, @PayFrom datetime

		SELECT @StartOn = StartOn, @PayFrom = StartOn, @MonthNumber = MonthNumber
		FROM App.tbYearPeriod
		WHERE StartOn = (SELECT MIN(StartOn) FROM App.tbYearPeriod)
	
		SET @MonthNumber = CASE 
			WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
			ELSE (@MonthNumber + @MonthInterval) % 12
			END
	
		WHILE EXISTS(SELECT     MonthNumber
					 FROM         App.tbYearPeriod
					 WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber))
			BEGIN
			SELECT @StartOn = MIN(StartOn)
			FROM         App.tbYearPeriod
			WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber)
			ORDER BY MIN(StartOn)		
		
			SELECT @PayOn = MIN(PayOn)
			FROM @tbDueDate
			WHERE PayOn >= @StartOn
			ORDER BY MIN(PayOn)
		
			UPDATE @tbDueDate
			SET PayTo = @StartOn, PayFrom = @PayFrom
			WHERE PayOn = @PayOn
		
			SET @PayFrom = @StartOn
		
			SET @MonthNumber = CASE 
				WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
				ELSE (@MonthNumber + @MonthInterval) % 12
				END
		
			END

		DELETE FROM @tbDueDate WHERE PayTo IS NULL

		END
	ELSE
		BEGIN

		WITH dd AS
		(
			SELECT PayOn, MIN(PayOn) OVER (ORDER BY PayOn ROWS 1 PRECEDING) AS PayFrom
			FROM @tbDueDate 
		)
		UPDATE @tbDueDate
		SET PayTo = dd.PayOn, PayFrom = dd.PayFrom
		FROM @tbDueDate tbDueDate JOIN dd ON tbDueDate.PayOn = dd.PayOn

		UPDATE @tbDueDate
		SET PayFrom = DATEADD(MONTH, @MonthInterval * -1, PayTo)
		WHERE PayTo = (SELECT MIN(PayTo) FROM @tbDueDate)

		END		
	
	UPDATE @tbDueDate
	SET PayOn = DATEADD(DAY, (SELECT OffsetDays FROM Cash.tbTaxType WHERE TaxTypeCode = @TaxTypeCode), PayOn)

	RETURN	
	END
go

ALTER VIEW [Cash].[vwTaxVatStatement]
AS
	WITH vat_dates AS
	(
		SELECT PayOn, PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(1)
	), vatPeriod AS
	(
		SELECT        StartOn, 
			(SELECT PayTo FROM vat_dates WHERE StartOn >= PayFrom AND StartOn < PayTo) AS VatStartOn, VatAdjustment
		FROM            App.tbYearPeriod 
	), vat_codes AS
	(
		SELECT     CashCode
		FROM         Cash.tbTaxType
		WHERE     (TaxTypeCode = 1)
	)
	, vat_results AS
	(
		SELECT VatStartOn AS StartOn,
			SUM(HomeSales) AS HomeSales, SUM(HomePurchases) AS HomePurchases, SUM(ExportSales) AS ExportSales, SUM(ExportPurchases) AS ExportPurchases, 
			SUM(HomeSalesVat) AS HomeSalesVat, SUM(HomePurchasesVat) AS HomePurchasesVat, 
			SUM(ExportSalesVat) AS ExportSalesVat, SUM(ExportPurchasesVat) AS ExportPurchasesVat, SUM(VatDue) AS VatDue
		FROM Cash.vwTaxVatSummary vatCodeDue JOIN vatPeriod ON vatCodeDue.StartOn = vatPeriod.StartOn
		GROUP BY VatStartOn
	), vat_adjustments AS
	(
		SELECT VatStartOn AS StartOn, SUM(VatAdjustment) AS VatAdjustment
		FROM vatPeriod
		GROUP BY VatStartOn
	), vat_unordered AS
	(
		SELECT vat_dates.PayOn AS StartOn, VatDue - a.VatAdjustment AS VatDue, 0 As VatPaid		
		FROM vat_results r JOIN vat_adjustments a ON r.StartOn = a.StartOn
			JOIN vat_dates ON r.StartOn = vat_dates.PayTo
			UNION
		SELECT     Org.tbPayment.PaidOn AS StartOn, 0 As VatDue, ( Org.tbPayment.PaidOutValue * -1) + Org.tbPayment.PaidInValue AS VatPaid
		FROM         Org.tbPayment INNER JOIN
							  vat_codes ON Org.tbPayment.CashCode = vat_codes.CashCode	
	), vat_ordered AS
	(
		SELECT ROW_NUMBER() OVER (ORDER BY StartOn, VatDue) AS RowNumber,
			StartOn, VatDue, VatPaid
		FROM vat_unordered
	), vat_statement AS
	(
		SELECT RowNumber, StartOn, VatDue, VatPaid,
			SUM(VatDue+VatPaid) OVER (ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
		FROM vat_ordered
	)
	SELECT RowNumber, StartOn, VatDue, VatPaid, Balance
	FROM vat_statement
	WHERE StartOn >= (SELECT MIN(StartOn) FROM App.tbYearPeriod p JOIN App.tbYear y ON p.YearNumber = y.YearNumber  WHERE y.CashStatusCode < 3);


go
DROP VIEW IF EXISTS App.vwNICashCode;
DROP VIEW IF EXISTS App.vwVatCashCode;
go
ALTER   TRIGGER [Org].[Org_tbPayment_TriggerUpdate]
ON [Org].[tbPayment]
FOR UPDATE
AS
	SET NOCOUNT ON;
	BEGIN TRY
		UPDATE Org.tbPayment
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Org.tbPayment INNER JOIN inserted AS i ON tbPayment.PaymentCode = i.PaymentCode;

		IF UPDATE(PaidInValue) OR UPDATE(PaidOutValue)
			BEGIN
			DECLARE @AccountCode NVARCHAR(10)
			DECLARE org CURSOR LOCAL FOR 
				SELECT AccountCode 
				FROM inserted
				GROUP BY AccountCode

			OPEN org
			FETCH NEXT FROM org INTO @AccountCode
			WHILE (@@FETCH_STATUS = 0)
				BEGIN		
				EXEC Org.proc_Rebuild @AccountCode
				FETCH NEXT FROM org INTO @AccountCode
			END

			CLOSE org
			DEALLOCATE org

			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER VIEW Org.vwPaymentCode
AS
	SELECT CONCAT((SELECT UserId FROM Usr.vwCredentials), '_', FORMAT(CURRENT_TIMESTAMP, 'yyyymmdd_hhmmss')) AS PaymentCode
go
CREATE OR ALTER PROCEDURE Org.proc_NextPaymentCode (@PaymentCode NVARCHAR(20) OUTPUT)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SELECT @PaymentCode = PaymentCode FROM Org.vwPaymentCode;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER PROCEDURE Invoice.proc_Pay
	(
	@InvoiceNumber nvarchar(20),
	@PaidOn datetime,
	@Post bit = 1
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
	DECLARE 
		@PaidOut money
		, @PaidIn money
		, @TaskOutstanding money
		, @ItemOutstanding money
		, @CashModeCode smallint
		, @AccountCode nvarchar(10)
		, @CashAccountCode nvarchar(10)
		, @UserId nvarchar(10)
		, @PaymentCode nvarchar(20)

		SELECT @UserId = UserId FROM Usr.vwCredentials	

		SET @PaymentCode = CONCAT(@UserId, '_', FORMAT(@PaidOn, 'yyyymmdd_hhmmss'))

		WHILE EXISTS (SELECT * FROM Org.tbPayment WHERE PaymentCode = @PaymentCode)
			BEGIN
			SET @PaidOn = DATEADD(s, 1, @PaidOn)
			SET @PaymentCode = CONCAT(@UserId, '_', FORMAT(@PaidOn, 'yyyymmdd_hhmmss'))
			END
		
		SELECT @CashModeCode = Invoice.tbType.CashModeCode, @AccountCode = Invoice.tbInvoice.AccountCode
		FROM Invoice.tbInvoice INNER JOIN Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		WHERE     ( Invoice.tbInvoice.InvoiceNumber = @InvoiceNumber)
	
		SELECT  @TaskOutstanding = SUM( Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue - Invoice.tbTask.PaidValue + Invoice.tbTask.PaidTaxValue)
		FROM         Invoice.tbInvoice INNER JOIN
							  Invoice.tbTask ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbTask.InvoiceNumber INNER JOIN
							  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		WHERE     ( Invoice.tbInvoice.InvoiceNumber = @InvoiceNumber)
		GROUP BY Invoice.tbType.CashModeCode


		SELECT @ItemOutstanding = SUM( Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue - Invoice.tbItem.PaidValue + Invoice.tbItem.PaidTaxValue)
		FROM         Invoice.tbInvoice INNER JOIN
							  Invoice.tbItem ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbItem.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceNumber = @InvoiceNumber)
	
		IF @CashModeCode = 0
			BEGIN
			SET @PaidOut = ISNULL(@TaskOutstanding, 0) + ISNULL(@ItemOutstanding, 0)
			SET @PaidIn = 0
			END
		ELSE
			BEGIN
			SET @PaidIn = ISNULL(@TaskOutstanding, 0) + ISNULL(@ItemOutstanding, 0)
			SET @PaidOut = 0
			END
	
		BEGIN TRANSACTION

		IF @PaidIn + @PaidOut > 0
			BEGIN
			SELECT TOP 1 @CashAccountCode = Org.tbAccount.CashAccountCode
			FROM         Org.tbAccount INNER JOIN
								  Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
			WHERE     ( Org.tbAccount.AccountClosed = 0)
			GROUP BY Org.tbAccount.CashAccountCode
		
			INSERT INTO Org.tbPayment
								  (PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, PaidOn, PaidInValue, PaidOutValue, PaymentReference)
			VALUES     (@PaymentCode,@UserId, 0, @AccountCode, @CashAccountCode, @PaidOn, @PaidIn, @PaidOut, @InvoiceNumber)		
		
			IF @Post <> 0
				EXEC Org.proc_PaymentPostInvoiced @PaymentCode			
			END
		
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_Pay (@TaskCode NVARCHAR(20), @Post BIT = 0)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		
		DECLARE 
			@InvoiceTypeCode smallint
			, @InvoiceNumber NVARCHAR(20)
			, @InvoicedOn DATETIME = CAST(CURRENT_TIMESTAMP AS DATE)

		SELECT @InvoiceTypeCode = CASE CashModeCode WHEN 0 THEN 2 ELSE 0 END       
		FROM  Task.tbTask INNER JOIN
				Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
				Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode AND Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode AND 
				Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE Task.tbTask.TaskCode = @TaskCode
		
		EXEC Invoice.proc_Raise @TaskCode = @TaskCode, @InvoiceTypeCode = @InvoiceTypeCode, @InvoicedOn = @InvoicedOn, @InvoiceNumber = @InvoiceNumber OUTPUT
		EXEC Invoice.proc_Accept @InvoiceNumber
		EXEC Invoice.proc_Pay @InvoiceNumber = @InvoiceNumber, @PaidOn = @InvoicedOn, @Post = @Post

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
