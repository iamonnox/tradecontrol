ALTER VIEW [Invoice].[vwOutstanding]
AS
	WITH invoiced_items AS
	(
		SELECT        Invoice.tbItem.InvoiceNumber, '' AS TaskCode, Invoice.tbItem.CashCode, Invoice.tbItem.TaxCode, (Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue) - (Invoice.tbItem.PaidValue + Invoice.tbItem.PaidTaxValue)
								  AS OutstandingValue, CASE WHEN InvoiceValue = 0 THEN 0 ELSE TaxValue / InvoiceValue END AS TaxRate, App.tbTaxCode.RoundingCode
		FROM            Invoice.tbItem INNER JOIN
								 App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode
	), invoiced_tasks AS
	(
		SELECT        Invoice.tbTask.InvoiceNumber, Invoice.tbTask.TaskCode, Invoice.tbTask.CashCode, Invoice.tbTask.TaxCode, (Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue) 
								 - (Invoice.tbTask.PaidValue + Invoice.tbTask.PaidTaxValue) AS OutstandingValue, CASE WHEN InvoiceValue = 0 THEN 0 ELSE TaxValue / InvoiceValue END AS TaxRate, App.tbTaxCode.RoundingCode
		FROM            Invoice.tbTask INNER JOIN
								 App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode
	), invoices_outstanding AS
	(
		SELECT        InvoiceNumber AS InvoiceNumber, TaskCode AS TaskCode, CashCode AS CashCode, TaxCode AS TaxCode, OutstandingValue, TaxRate, RoundingCode
		FROM            invoiced_items
		UNION
		SELECT        InvoiceNumber AS InvoiceNumber, TaskCode AS TaskCode, CashCode AS CashCode, TaxCode AS TaxCode, OutstandingValue, TaxRate, RoundingCode
		FROM            invoiced_tasks
	)
	SELECT Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.DueOn, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceNumber, invoices_outstanding.TaskCode, Invoice.tbInvoice.InvoiceStatusCode, 
							 Invoice.tbType.CashModeCode, invoices_outstanding.CashCode, invoices_outstanding.TaxCode, invoices_outstanding.TaxRate, invoices_outstanding.RoundingCode, 
							 CASE WHEN Invoice.tbType.CashModeCode = 0 THEN OutstandingValue * - 1 ELSE OutstandingValue END AS ItemValue
	FROM            invoices_outstanding INNER JOIN
							 Invoice.tbInvoice ON invoices_outstanding.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							 Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	WHERE        (Invoice.tbInvoice.InvoiceStatusCode = 1) OR
							 (Invoice.tbInvoice.InvoiceStatusCode = 2);
go
DROP VIEW IF EXISTS Invoice.vwOutstandingBase;
DROP VIEW IF EXISTS Invoice.vwOutstandingItems;
DROP VIEW IF EXISTS Invoice.vwOutstandingTasks;
go
ALTER PROCEDURE [Org].[proc_PaymentPostInvoiced] (@PaymentCode nvarchar(20))
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@AccountCode nvarchar(10)
			, @CashModeCode smallint
			, @PostValue money

		SELECT   @PostValue = CASE WHEN PaidInValue = 0 THEN PaidOutValue ELSE PaidInValue * -1 END,
			@AccountCode = Org.tbOrg.AccountCode,
			@CashModeCode = CASE WHEN PaidInValue = 0 THEN 0 ELSE 1 END
		FROM         Org.tbPayment INNER JOIN
							  Org.tbOrg ON Org.tbPayment.AccountCode = Org.tbOrg.AccountCode
		WHERE     ( Org.tbPayment.PaymentCode = @PaymentCode);

		BEGIN TRANSACTION

		IF @CashModeCode = 1
			EXEC Org.proc_PaymentPostPaidIn @PaymentCode, @PostValue 
		ELSE
			EXEC Org.proc_PaymentPostPaidOut @PaymentCode, @PostValue

		UPDATE  Org.tbAccount
		SET CurrentBalance = Org.tbAccount.CurrentBalance + @PostValue
		FROM         Org.tbAccount INNER JOIN
							  Org.tbPayment ON Org.tbAccount.CashAccountCode = Org.tbPayment.CashAccountCode
		WHERE Org.tbPayment.PaymentCode = @PaymentCode
		
		COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER   PROCEDURE [Org].[proc_PaymentPostPaidIn]
	(
	@PaymentCode nvarchar(20),
	@PostValue money  
	)
 AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@InvoiceNumber nvarchar(20)
			, @TaskCode nvarchar(20)
			, @TaxRate real
			, @ItemValue money
			, @RoundingCode smallint
			, @PaidValue money	
			, @PaidTaxValue money
			, @TaxInValue money = 0
			, @TaxOutValue money = 0
			, @CashCode nvarchar(50)	
			, @TaxCode nvarchar(10)

	
		DECLARE curPaidIn CURSOR LOCAL FOR
			SELECT     Invoice.vwOutstanding.InvoiceNumber, Invoice.vwOutstanding.TaskCode, Invoice.vwOutstanding.CashCode, Invoice.vwOutstanding.TaxCode, 
								  Invoice.vwOutstanding.TaxRate, Invoice.vwOutstanding.ItemValue, Invoice.vwOutstanding.RoundingCode
			FROM         Invoice.vwOutstanding INNER JOIN
								  Org.tbPayment ON Invoice.vwOutstanding.AccountCode = Org.tbPayment.AccountCode
			WHERE     ( Org.tbPayment.PaymentCode = @PaymentCode)
			ORDER BY Invoice.vwOutstanding.CashModeCode, Invoice.vwOutstanding.ExpectedOn

		OPEN curPaidIn
		FETCH NEXT FROM curPaidIn INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode
		WHILE @@FETCH_STATUS = 0 and @PostValue < 0
			BEGIN
			IF (@PostValue + @ItemValue) > 0
				SET @ItemValue = @PostValue * -1

			SET @PaidTaxValue = (CASE @RoundingCode WHEN 0 THEN ROUND(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), 2) WHEN 1 THEN ROUND(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), 2, 1) END)
			SET @PaidValue = ABS(@ItemValue) - @PaidTaxValue
				
			SET @PostValue = @PostValue + @ItemValue
		
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
		        		  
			SET @TaxInValue += CASE WHEN @ItemValue > 0 THEN @PaidTaxValue ELSE 0 END
			SET @TaxOutValue += CASE WHEN @ItemValue < 0 THEN @PaidTaxValue ELSE 0 END	
				
			FETCH NEXT FROM curPaidIn INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode
			END
	
		CLOSE curPaidIn
		DEALLOCATE curPaidIn
	
	
		IF NOT @CashCode IS NULL
			BEGIN
			UPDATE    Org.tbPayment
			SET      PaymentStatusCode = 1, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
				CashCode = ISNULL(@CashCode, Org.tbPayment.CashCode), 
				TaxCode = ISNULL(@TaxCode, Org.tbPayment.TaxCode)
			WHERE     (PaymentCode = @PaymentCode)
			END	
			
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER   PROCEDURE [Org].[proc_PaymentPostPaidOut]
	(
	@PaymentCode nvarchar(20),
	@PostValue money  
	)
 AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@InvoiceNumber nvarchar(20)	
			, @TaskCode nvarchar(20)
			, @TaxRate real
			, @ItemValue money
			, @RoundingCode smallint
			, @PaidValue money	
			, @PaidTaxValue money
			, @TaxInValue money = 0
			, @TaxOutValue money = 0
			, @CashCode nvarchar(50)	
			, @TaxCode nvarchar(10)


		DECLARE curPaidOut CURSOR LOCAL FOR
			SELECT     Invoice.vwOutstanding.InvoiceNumber, Invoice.vwOutstanding.TaskCode, Invoice.vwOutstanding.CashCode, Invoice.vwOutstanding.TaxCode, 
								  Invoice.vwOutstanding.TaxRate, Invoice.vwOutstanding.ItemValue, Invoice.vwOutstanding.RoundingCode
			FROM         Invoice.vwOutstanding INNER JOIN
								  Org.tbPayment ON Invoice.vwOutstanding.AccountCode = Org.tbPayment.AccountCode
			WHERE     ( Org.tbPayment.PaymentCode = @PaymentCode)
			ORDER BY Invoice.vwOutstanding.CashModeCode DESC, Invoice.vwOutstanding.ExpectedOn

		OPEN curPaidOut
		FETCH NEXT FROM curPaidOut INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode
		WHILE @@FETCH_STATUS = 0 and @PostValue > 0
			BEGIN
			IF (@PostValue + @ItemValue) < 0
				SET @ItemValue = @PostValue * -1

			SET @PaidTaxValue = (CASE @RoundingCode WHEN 0 THEN ROUND(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), 2) WHEN 1 THEN ROUND(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), 2, 1) END)
			SET @PaidValue = ABS(@ItemValue) - @PaidTaxValue
				
			SET @PostValue = @PostValue + @ItemValue
		
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
		        		  
			SET @TaxInValue += CASE WHEN @ItemValue > 0 THEN @PaidTaxValue ELSE 0 END
			SET @TaxOutValue += CASE WHEN @ItemValue < 0 THEN @PaidTaxValue ELSE 0 END	
				
			FETCH NEXT FROM curPaidOut INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode
			END
		
		CLOSE curPaidOut
		DEALLOCATE curPaidOut

		IF NOT @CashCode IS NULL
			BEGIN
			UPDATE    Org.tbPayment
			SET      PaymentStatusCode = 1, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
				CashCode = ISNULL(@CashCode, Org.tbPayment.CashCode), 
				TaxCode = ISNULL(@TaxCode, Org.tbPayment.TaxCode)
			WHERE     (PaymentCode = @PaymentCode)
			END
	
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
