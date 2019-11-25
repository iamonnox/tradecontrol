UPDATE App.tbOptions
SET SQLDataVersion = 3.04;
GO
/** Alter Invoice.tbInvoice.CollectOn to DueOn */
ALTER TABLE Invoice.tbInvoice WITH NOCHECK ADD
	DueOn DATETIME NOT NULL CONSTRAINT DF_Invoice_tbInvoice_DueOn DEFAULT (DATEADD(DAY, 1, CAST(CURRENT_TIMESTAMP AS DATE)));
GO
UPDATE Invoice.tbInvoice SET DueOn = CollectOn;
GO
ALTER VIEW [Invoice].[vwOutstanding]
AS
SELECT        TOP (100) PERCENT Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.DueOn, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceNumber, Invoice.vwOutstandingBase.TaskCode, Invoice.tbInvoice.InvoiceStatusCode, 
                         Invoice.tbType.CashModeCode, Invoice.vwOutstandingBase.CashCode, Invoice.vwOutstandingBase.TaxCode, Invoice.vwOutstandingBase.TaxRate, Invoice.vwOutstandingBase.RoundingCode, 
                         CASE WHEN Invoice.tbType.CashModeCode = 0 THEN OutstandingValue * - 1 ELSE OutstandingValue END AS ItemValue
FROM            Invoice.vwOutstandingBase INNER JOIN
                         Invoice.tbInvoice ON Invoice.vwOutstandingBase.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE        (Invoice.tbInvoice.InvoiceStatusCode = 1) OR
                         (Invoice.tbInvoice.InvoiceStatusCode = 2)
GO
ALTER VIEW [Invoice].[vwAgedDebtPurchases]
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
                         Invoice.tbType.InvoiceType, (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) AS UnpaidValue, DATEDIFF(DD, CURRENT_TIMESTAMP, 
                         Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.DueOn, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, 
                         Invoice.tbInvoice.Notes
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
WHERE        (Invoice.tbInvoice.InvoiceTypeCode > 1) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
ORDER BY Invoice.tbInvoice.ExpectedOn;
GO
ALTER VIEW [Invoice].[vwAgedDebtSales]
AS
SELECT TOP 100 PERCENT  Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
                         Invoice.tbType.InvoiceType, (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) AS UnpaidValue, DATEDIFF(DD, CURRENT_TIMESTAMP, 
                         Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.DueOn, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, 
                         Invoice.tbInvoice.Notes
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
WHERE        (Invoice.tbInvoice.InvoiceTypeCode < 2) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
ORDER BY Invoice.tbInvoice.ExpectedOn;
GO
ALTER VIEW [Invoice].[vwCandidateCredits]
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.UserId, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbInvoice.InvoicedOn, 
                         Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaidValue, Invoice.tbInvoice.PaidTaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, Invoice.tbInvoice.Printed, 
                         Invoice.tbInvoice.DueOn, Invoice.tbInvoice.Spooled, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.InvoiceType
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 0)
ORDER BY Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoicedOn DESC
GO
ALTER VIEW [Invoice].[vwCandidateDebits]
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.UserId, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbInvoice.InvoicedOn, 
                         Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaidValue, Invoice.tbInvoice.PaidTaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, Invoice.tbInvoice.Printed, 
                         Invoice.tbInvoice.DueOn, Invoice.tbInvoice.Spooled, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.InvoiceType
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 2)
ORDER BY Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoicedOn DESC
GO
ALTER VIEW [Invoice].[vwDoc]
AS
SELECT     Org.tbOrg.EmailAddress, Usr.tbUser.UserName, Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbAddress.Address AS InvoiceAddress, 
                      Invoice.tbInvoice.InvoiceNumber, Invoice.tbType.InvoiceType, Invoice.tbStatus.InvoiceStatus, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.DueOn, 
                      Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes
FROM         Invoice.tbInvoice INNER JOIN
                      Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                      Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId INNER JOIN
                      Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode LEFT OUTER JOIN
                      Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode
GO
ALTER VIEW [Invoice].[vwRegisterPurchasesOverdue]
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
                         Invoice.tbType.InvoiceType, (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) AS UnpaidValue, 
						DATEDIFF(DD, CURRENT_TIMESTAMP, Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.DueOn, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, 
                         Invoice.tbInvoice.Notes
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
WHERE        (Invoice.tbInvoice.InvoiceTypeCode > 1) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
ORDER BY Invoice.tbInvoice.ExpectedOn;
GO
ALTER VIEW [Invoice].[vwRegisterSalesOverdue]
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
                         Invoice.tbType.InvoiceType, (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) AS UnpaidValue, DATEDIFF(DD, CURRENT_TIMESTAMP, 
                         Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.DueOn, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, 
                         Invoice.tbInvoice.Notes
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
WHERE        (Invoice.tbInvoice.InvoiceTypeCode < 2) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
ORDER BY Invoice.tbInvoice.ExpectedOn;
GO
ALTER VIEW [Invoice].[vwSalesInvoiceSpool]
AS
SELECT        sales_invoice.InvoiceNumber, Invoice.tbType.InvoiceType, sales_invoice.InvoiceStatusCode, Usr.tbUser.UserName, sales_invoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, 
                         sales_invoice.InvoicedOn, sales_invoice.InvoiceValue AS InvoiceValueTotal, sales_invoice.TaxValue AS TaxValueTotal, sales_invoice.PaymentTerms, sales_invoice.DueOn, sales_invoice.Notes, 
                         Org.tbOrg.EmailAddress, Org.tbAddress.Address AS InvoiceAddress, tbInvoiceTask.TaskCode, Task.tbTask.TaskTitle, Task.tbTask.ActionedOn, tbInvoiceTask.Quantity, Activity.tbActivity.UnitOfMeasure, 
                         tbInvoiceTask.TaxCode, tbInvoiceTask.InvoiceValue, tbInvoiceTask.TaxValue
FROM            Invoice.tbInvoice AS sales_invoice INNER JOIN
                         Invoice.tbStatus ON sales_invoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON sales_invoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON sales_invoice.UserId = Usr.tbUser.UserId LEFT OUTER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode INNER JOIN
                         Invoice.tbTask AS tbInvoiceTask ON sales_invoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
                         Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode INNER JOIN
                         Invoice.tbType ON sales_invoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE sales_invoice.InvoiceTypeCode = 0 AND
	 EXISTS (SELECT * FROM App.tbDocSpool AS doc WHERE DocTypeCode = 4 AND UserName = SUSER_SNAME() AND sales_invoice.InvoiceNumber = doc.DocumentNumber);
GO
ALTER PROCEDURE [Cash].[proc_StatementRescheduleOverdue]
 AS
	UPDATE Task.tbTask
	SET Task.tbTask.PaymentOn = Task.fnDefaultPaymentOn( Task.tbTask.AccountCode, CURRENT_TIMESTAMP) 
	FROM         Task.tbTask INNER JOIN
                      Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode
	WHERE     ( Task.tbTask.PaymentOn < CURRENT_TIMESTAMP) AND ( Task.tbTask.TaskStatusCode = 2)
	

	UPDATE Task.tbTask
	SET Task.tbTask.PaymentOn = Task.fnDefaultPaymentOn( Task.tbTask.AccountCode, CURRENT_TIMESTAMP) 
	FROM         Task.tbTask INNER JOIN
                      Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode
	WHERE     ( Task.tbTask.PaymentOn < CURRENT_TIMESTAMP) AND ( Task.tbTask.TaskStatusCode < 2)
	
	UPDATE Invoice.tbInvoice
	SET DueOn = Task.fnDefaultPaymentOn( Invoice.tbInvoice.AccountCode, CURRENT_TIMESTAMP) 
	FROM         Invoice.tbInvoice 
	WHERE     ( Invoice.tbInvoice.InvoiceStatusCode = 1 OR
	                      Invoice.tbInvoice.InvoiceStatusCode = 2) AND ( Invoice.tbInvoice.DueOn < CURRENT_TIMESTAMP)	
	RETURN

GO
ALTER PROCEDURE [Cash].[proc_StatementRescheduleOverdue]
 AS
	UPDATE Task.tbTask
	SET Task.tbTask.PaymentOn = Task.fnDefaultPaymentOn( Task.tbTask.AccountCode, CURRENT_TIMESTAMP) 
	FROM         Task.tbTask INNER JOIN
                      Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode
	WHERE     ( Task.tbTask.PaymentOn < CURRENT_TIMESTAMP) AND ( Task.tbTask.TaskStatusCode = 2)
	

	UPDATE Task.tbTask
	SET Task.tbTask.PaymentOn = Task.fnDefaultPaymentOn( Task.tbTask.AccountCode, CURRENT_TIMESTAMP) 
	FROM         Task.tbTask INNER JOIN
                      Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode
	WHERE     ( Task.tbTask.PaymentOn < CURRENT_TIMESTAMP) AND ( Task.tbTask.TaskStatusCode < 2)
	
	UPDATE Invoice.tbInvoice
	SET DueOn = Task.fnDefaultPaymentOn( Invoice.tbInvoice.AccountCode, CURRENT_TIMESTAMP) 
	FROM         Invoice.tbInvoice 
	WHERE     ( Invoice.tbInvoice.InvoiceStatusCode = 1 OR
	                      Invoice.tbInvoice.InvoiceStatusCode = 2) AND ( Invoice.tbInvoice.DueOn < CURRENT_TIMESTAMP)	
	RETURN

GO
ALTER PROCEDURE [Invoice].[proc_Raise]
	(
	@TaskCode nvarchar(20),
	@InvoiceTypeCode smallint,
	@InvoicedOn datetime,
	@InvoiceNumber nvarchar(20) = null output
	)
AS
DECLARE @UserId nvarchar(10)
DECLARE @NextNumber int
DECLARE @InvoiceSuffix nvarchar(4)
DECLARE @PaymentDays smallint
DECLARE @DueOn datetime
DECLARE @AccountCode nvarchar(10)

	SET @InvoicedOn = isnull(@InvoicedOn, CURRENT_TIMESTAMP)
	
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
	
	SET @DueOn = Task.fnDefaultPaymentOn(@AccountCode, @InvoicedOn)
	
	BEGIN TRAN Invoice
	
	EXEC Invoice.proc_Cancel
	
	UPDATE    Invoice.tbType
	SET              NextNumber = @NextNumber + 1
	WHERE     (InvoiceTypeCode = @InvoiceTypeCode)
	
	INSERT INTO Invoice.tbInvoice
						(InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoicedOn, DueOn, ExpectedOn, InvoiceStatusCode, PaymentTerms)
	SELECT     @InvoiceNumber AS InvoiceNumber, @UserId AS UserId, Task.tbTask.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, @InvoicedOn AS InvoicedOn, 
						@DueOn AS DueOn, @DueOn AS ExpectedOn, 0 AS InvoiceStatusCode, 
						Org.tbOrg.PaymentTerms
	FROM         Task.tbTask INNER JOIN
						Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode
	WHERE     ( Task.tbTask.TaskCode = @TaskCode)

	EXEC Invoice.proc_AddTask @InvoiceNumber, @TaskCode
	
	UPDATE    Task.tbTask
	SET              ActionedOn = CURRENT_TIMESTAMP
	WHERE     (TaskCode = @TaskCode) AND (ActionedOn IS NULL)

	COMMIT TRAN Invoice
	
	RETURN
GO
ALTER PROCEDURE [Org].[proc_PaymentPostMisc]
	(
	@PaymentCode nvarchar(20) 
	)
 AS
DECLARE 
	@InvoiceNumber nvarchar(20), 
	@NextNumber int, 
	@InvoiceTypeCode smallint;

	SELECT @InvoiceTypeCode = CASE WHEN PaidInValue != 0 THEN 0 ELSE 2 END 
	FROM         Org.tbPayment
	WHERE     (PaymentCode = @PaymentCode)
	
	SELECT @NextNumber = NextNumber
	FROM Invoice.tbType
	WHERE InvoiceTypeCode = @InvoiceTypeCode;
		
	SET @InvoiceNumber = FORMAT(@NextNumber, '000000') + '.' + (SELECT UserId FROM Usr.vwCredentials);

	WHILE EXISTS (SELECT     InvoiceNumber
	              FROM         Invoice.tbInvoice
	              WHERE     (InvoiceNumber = @InvoiceNumber))
		BEGIN
		SET @NextNumber += @NextNumber 
		SET @InvoiceNumber = FORMAT(@NextNumber, '000000') + '.' + (SELECT UserId FROM Usr.vwCredentials);
		END
			
	UPDATE    Invoice.tbType
	SET              NextNumber = @NextNumber + 1
	WHERE     (InvoiceTypeCode = @InvoiceTypeCode)

	UPDATE    Org.tbPayment
	SET		PaymentStatusCode = 1,
		TaxInValue = (CASE App.tbTaxCode.RoundingCode WHEN 0 THEN FORMAT(Org.tbPayment.PaidInValue - ( Org.tbPayment.PaidInValue / (1 + App.tbTaxCode.TaxRate)), '#.00') WHEN 1 THEN ROUND(Org.tbPayment.PaidInValue - ( Org.tbPayment.PaidInValue / (1 + App.tbTaxCode.TaxRate)), 2, 1) END), 
		TaxOutValue = (CASE App.tbTaxCode.RoundingCode WHEN 0 THEN FORMAT(Org.tbPayment.PaidOutValue - ( Org.tbPayment.PaidOutValue / (1 + App.tbTaxCode.TaxRate)), '#.00') WHEN 1 THEN ROUND(Org.tbPayment.PaidOutValue - ( Org.tbPayment.PaidOutValue / (1 + App.tbTaxCode.TaxRate)), 2, 1) END)
	FROM         Org.tbPayment INNER JOIN
	                      App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode
	WHERE     (PaymentCode = @PaymentCode)

	INSERT INTO Invoice.tbInvoice
							 (InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, DueOn, ExpectedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, Printed)
	SELECT        @InvoiceNumber AS InvoiceNumber, Org.tbPayment.UserId, Org.tbPayment.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, 3 AS InvoiceStatusCode, 
							Org.tbPayment.PaidOn, Org.tbPayment.PaidOn AS DueOn, Org.tbPayment.PaidOn AS ExpectedOn,
							CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
								WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
							END AS InvoiceValue, 
							CASE WHEN Org.tbPayment.PaidInValue > 0 THEN Org.tbPayment.TaxInValue 
								WHEN Org.tbPayment.PaidOutValue > 0 THEN Org.tbPayment.TaxOutValue
							END AS TaxValue, 
							CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
								WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
							END AS PaidValue, 
							CASE WHEN Org.tbPayment.PaidInValue > 0 THEN Org.tbPayment.TaxInValue 
								WHEN Org.tbPayment.PaidOutValue > 0 THEN Org.tbPayment.TaxOutValue
							END AS PaidTaxValue, 
							1 AS Printed
	FROM            Org.tbPayment INNER JOIN
							 App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode
	WHERE        ( Org.tbPayment.PaymentCode = @PaymentCode);


	INSERT INTO Invoice.tbItem
						(InvoiceNumber, CashCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, TaxCode)
	SELECT     @InvoiceNumber AS InvoiceNumber, Org.tbPayment.CashCode, 
							CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
								WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
							END AS InvoiceValue, 
							CASE WHEN Org.tbPayment.PaidInValue > 0 THEN Org.tbPayment.TaxInValue 
								WHEN Org.tbPayment.PaidOutValue > 0 THEN Org.tbPayment.TaxOutValue
							END AS TaxValue, 
							CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
								WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
							END AS PaidValue, 
							CASE WHEN Org.tbPayment.PaidInValue > 0 THEN Org.tbPayment.TaxInValue 
								WHEN Org.tbPayment.PaidOutValue > 0 THEN Org.tbPayment.TaxOutValue
							END AS PaidTaxValue, 
						Org.tbPayment.TaxCode
	FROM         Org.tbPayment INNER JOIN
	                      App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode
	WHERE     ( Org.tbPayment.PaymentCode = @PaymentCode);

	UPDATE Invoice.tbItem
	SET PaidValue = InvoiceValue, PaidTaxValue = TaxValue
	WHERE InvoiceNumber = @InvoiceNumber;

	UPDATE  Org.tbAccount
	SET CurrentBalance = CASE WHEN PaidInValue > 0 THEN Org.tbAccount.CurrentBalance + PaidInValue ELSE Org.tbAccount.CurrentBalance - PaidOutValue END
	FROM         Org.tbAccount INNER JOIN
						  Org.tbPayment ON Org.tbAccount.CashAccountCode = Org.tbPayment.CashAccountCode
	WHERE Org.tbPayment.PaymentCode = @PaymentCode

	
	RETURN
GO
ALTER PROCEDURE [Org].[proc_PaymentPostPaidIn]
	(
	@PaymentCode nvarchar(20),
	@CurrentBalance money output 
	)
 AS
--invoice valued
DECLARE @InvoiceNumber nvarchar(20)
DECLARE @TaskCode nvarchar(20)
DECLARE @TaxRate real
DECLARE @ItemValue money
DECLARE @RoundingCode smallint

--calc values
DECLARE @PaidValue money
DECLARE @PaidTaxValue money
DECLARE @TaxInValue money = 0
DECLARE @TaxOutValue money = 0

--default payment codes
DECLARE @CashCode nvarchar(50)
DECLARE @TaxCode nvarchar(10)

	
	DECLARE curPaidIn CURSOR LOCAL FOR
		SELECT     Invoice.vwOutstanding.InvoiceNumber, Invoice.vwOutstanding.TaskCode, Invoice.vwOutstanding.CashCode, Invoice.vwOutstanding.TaxCode, 
		                      Invoice.vwOutstanding.TaxRate, Invoice.vwOutstanding.ItemValue, Invoice.vwOutstanding.RoundingCode
		FROM         Invoice.vwOutstanding INNER JOIN
		                      Org.tbPayment ON Invoice.vwOutstanding.AccountCode = Org.tbPayment.AccountCode
		WHERE     ( Org.tbPayment.PaymentCode = @PaymentCode)
		ORDER BY Invoice.vwOutstanding.CashModeCode, Invoice.vwOutstanding.ExpectedOn

	OPEN curPaidIn
	FETCH NEXT FROM curPaidIn INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode
	WHILE @@FETCH_STATUS = 0 and @CurrentBalance < 0
		BEGIN
		IF (@CurrentBalance + @ItemValue) > 0
			SET @ItemValue = @CurrentBalance * -1

		SET @PaidTaxValue = (CASE @RoundingCode WHEN 0 THEN FORMAT(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), '#.00') WHEN 1 THEN ROUND(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), 2, 1) END)
		SET @PaidValue = ABS(@ItemValue) - @PaidTaxValue
				
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
		        		  
		SET @TaxInValue += CASE WHEN @ItemValue > 0 THEN @PaidTaxValue ELSE 0 END
		SET @TaxOutValue += CASE WHEN @ItemValue < 0 THEN @PaidTaxValue ELSE 0 END	
				
		FETCH NEXT FROM curPaidIn INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode
		END
	
	CLOSE curPaidIn
	DEALLOCATE curPaidIn
	
	--output new org current balance
	IF @CurrentBalance >= 0
		SET @CurrentBalance = 0
	ELSE
		SET @CurrentBalance = @CurrentBalance * -1

	
	IF NOT @CashCode IS NULL
		BEGIN
		UPDATE    Org.tbPayment
		SET      PaymentStatusCode = 1, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
			CashCode = ISNULL(@CashCode, Org.tbPayment.CashCode), 
			TaxCode = ISNULL(@TaxCode, Org.tbPayment.TaxCode)
		WHERE     (PaymentCode = @PaymentCode)
		END

			
	RETURN

GO
ALTER PROCEDURE [Org].[proc_PaymentPostPaidOut]
	(
	@PaymentCode nvarchar(20),
	@CurrentBalance money output 
	)
 AS
--invoice values
DECLARE @InvoiceNumber nvarchar(20)
DECLARE @TaskCode nvarchar(20)
DECLARE @TaxRate real
DECLARE @ItemValue money
DECLARE @RoundingCode smallint

--calc values
DECLARE @PaidValue money
DECLARE @PaidTaxValue money
DECLARE @TaxInValue money = 0
DECLARE @TaxOutValue money = 0

--default payment codes
DECLARE @CashCode nvarchar(50)
DECLARE @TaxCode nvarchar(10)


	
	DECLARE curPaidOut CURSOR LOCAL FOR
		SELECT     Invoice.vwOutstanding.InvoiceNumber, Invoice.vwOutstanding.TaskCode, Invoice.vwOutstanding.CashCode, Invoice.vwOutstanding.TaxCode, 
		                      Invoice.vwOutstanding.TaxRate, Invoice.vwOutstanding.ItemValue, Invoice.vwOutstanding.RoundingCode
		FROM         Invoice.vwOutstanding INNER JOIN
		                      Org.tbPayment ON Invoice.vwOutstanding.AccountCode = Org.tbPayment.AccountCode
		WHERE     ( Org.tbPayment.PaymentCode = @PaymentCode)
		ORDER BY Invoice.vwOutstanding.CashModeCode DESC, Invoice.vwOutstanding.ExpectedOn

	OPEN curPaidOut
	FETCH NEXT FROM curPaidOut INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode
	WHILE @@FETCH_STATUS = 0 and @CurrentBalance > 0
		BEGIN
		IF (@CurrentBalance + @ItemValue) < 0
			SET @ItemValue = @CurrentBalance * -1

		SET @PaidTaxValue = (CASE @RoundingCode WHEN 0 THEN FORMAT(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), '#.00') WHEN 1 THEN ROUND(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), 2, 1) END)
		SET @PaidValue = ABS(@ItemValue) - @PaidTaxValue
				
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
		        		  
		SET @TaxInValue += CASE WHEN @ItemValue > 0 THEN @PaidTaxValue ELSE 0 END
		SET @TaxOutValue += CASE WHEN @ItemValue < 0 THEN @PaidTaxValue ELSE 0 END	
				
		FETCH NEXT FROM curPaidOut INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode
		END
		
	CLOSE curPaidOut
	DEALLOCATE curPaidOut
	
	--output new org current balance
	IF @CurrentBalance <= 0
		SET @CurrentBalance = 0
	ELSE
		SET @CurrentBalance = @CurrentBalance * -1

	IF NOT @CashCode IS NULL
		BEGIN
		UPDATE    Org.tbPayment
		SET      PaymentStatusCode = 1, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
			CashCode = ISNULL(@CashCode, Org.tbPayment.CashCode), 
			TaxCode = ISNULL(@TaxCode, Org.tbPayment.TaxCode)
		WHERE     (PaymentCode = @PaymentCode)
		END
	
	RETURN

GO
ALTER PROCEDURE [Org].[proc_Rebuild]
	(
		@AccountCode nvarchar(10)
	)
 AS

	SET NOCOUNT ON;
	BEGIN TRAN OrgRebuild;

	UPDATE Invoice.tbItem
	SET TaxValue = CASE App.tbTaxCode.RoundingCode 
			WHEN 0 THEN FORMAT(Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, '#.00')
			WHEN 1 THEN ROUND( Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END,
		PaidValue = Invoice.tbItem.InvoiceValue, 
		PaidTaxValue = CASE App.tbTaxCode.RoundingCode 
			WHEN 0 THEN FORMAT(Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, '#.00')
			WHEN 1 THEN ROUND( Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END
	FROM         Invoice.tbItem INNER JOIN
	                      App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
	                      Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
	WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND ( Invoice.tbInvoice.AccountCode = @AccountCode);
                      
	UPDATE Invoice.tbTask
	SET TaxValue = CASE App.tbTaxCode.RoundingCode 
			WHEN 0 THEN FORMAT(Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, '#.00')
			WHEN 1 THEN ROUND( Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END,
		PaidValue = Invoice.tbTask.InvoiceValue,
		PaidTaxValue = CASE App.tbTaxCode.RoundingCode 
			WHEN 0 THEN FORMAT(Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, '#.00')
			WHEN 1 THEN ROUND( Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END
	FROM         Invoice.tbTask INNER JOIN
	                      App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
	                      Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
	WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND ( Invoice.tbInvoice.AccountCode = @AccountCode);
	
	UPDATE Invoice.tbInvoice
	SET InvoiceValue = 0, TaxValue = 0
	WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND ( Invoice.tbInvoice.AccountCode = @AccountCode);
	
	WITH items AS
	(
		SELECT     Invoice.tbInvoice.InvoiceNumber, SUM( Invoice.tbItem.InvoiceValue) AS TotalInvoiceValue, SUM( Invoice.tbItem.TaxValue) AS TotalTaxValue
		FROM         Invoice.tbItem INNER JOIN
							Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0)
		GROUP BY Invoice.tbItem.InvoiceNumber, Invoice.tbInvoice.InvoiceNumber
	)
	UPDATE Invoice.tbInvoice
	SET InvoiceValue = items.TotalInvoiceValue, 
		TaxValue = items.TotalTaxValue
	FROM         Invoice.tbInvoice INNER JOIN items 
	                      ON Invoice.tbInvoice.InvoiceNumber = items.InvoiceNumber
	WHERE (Invoice.tbInvoice.AccountCode = @AccountCode);	

	WITH tasks AS
	(
		SELECT     Invoice.tbInvoice.InvoiceNumber, SUM( Invoice.tbTask.InvoiceValue) AS TotalInvoiceValue, SUM( Invoice.tbTask.TaxValue) AS TotalTaxValue
	    FROM         Invoice.tbTask INNER JOIN
	                        Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
	    WHERE   ( Invoice.tbInvoice.InvoiceStatusCode <> 0)
	    GROUP BY Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.InvoiceNumber
	)
	UPDATE Invoice.tbInvoice
	SET InvoiceValue = InvoiceValue + tasks.TotalInvoiceValue, 
		TaxValue = TaxValue + tasks.TotalTaxValue
	FROM         Invoice.tbInvoice INNER JOIN tasks ON Invoice.tbInvoice.InvoiceNumber = tasks.InvoiceNumber
	WHERE (Invoice.tbInvoice.AccountCode = @AccountCode);			

	UPDATE    Invoice.tbInvoice
	SET              PaidValue = InvoiceValue, PaidTaxValue = TaxValue, InvoiceStatusCode = 3
	WHERE     (InvoiceStatusCode <> 0) AND (AccountCode = @AccountCode);
	
	UPDATE Org.tbPayment
	SET
		TaxInValue = PaidInValue - CASE App.tbTaxCode.RoundingCode 
			WHEN 0 THEN FORMAT((PaidInValue / (1 + TaxRate)), '#.00')
			WHEN 1 THEN ROUND((PaidInValue / (1 + TaxRate)), 2, 1) END, 
		TaxOutValue = PaidOutValue - CASE App.tbTaxCode.RoundingCode 
			WHEN 0 THEN FORMAT((PaidOutValue / (1 + TaxRate)), '#.00')
			WHEN 1 THEN ROUND((PaidOutValue / (1 + TaxRate)), 2, 1) END
	FROM         Org.tbPayment INNER JOIN
	                      App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode
	WHERE     ( Org.tbPayment.AccountCode = @AccountCode);



/************** replace cursor ********************/
DECLARE @PaidBalance money, @InvoicedBalance money, @Balance money;
DECLARE @CashModeCode smallint, @TaxRate float, @RoundingCode smallint;	
DECLARE @InvoiceNumber nvarchar(20), @TaskCode nvarchar(20), @CashCode nvarchar(50), @InvoiceValue money, @TaxValue money;	
DECLARE @PaidValue money, @PaidInvoiceValue money, @PaidTaxValue money;

	SELECT  @PaidBalance = SUM(CASE WHEN PaidInValue > 0 THEN PaidInValue * -1 ELSE PaidOutValue  END)
	FROM         Org.tbPayment
	WHERE     (AccountCode = @AccountCode) And (PaymentStatusCode <> 0)
	
	SELECT @PaidBalance = ISNULL(@PaidBalance, 0) + OpeningBalance
	FROM Org.tbOrg
	WHERE     (AccountCode = @AccountCode)

	SELECT @InvoicedBalance = SUM(CASE Invoice.tbType.CashModeCode WHEN 0 THEN (InvoiceValue + TaxValue) * - 1 WHEN 1 THEN InvoiceValue + TaxValue ELSE 0 END) 
	FROM         Invoice.tbInvoice INNER JOIN
	                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	WHERE     ( Invoice.tbInvoice.AccountCode = @AccountCode)
	
	SET @Balance = ISNULL(@PaidBalance, 0) + ISNULL(@InvoicedBalance, 0)
                      
    SET @CashModeCode = CASE WHEN @Balance > 0 THEN 1 ELSE 0 END
	SET @Balance = ABS(@Balance)	

	DECLARE curInv cursor local for
		WITH invoice_items AS
		(		
			SELECT        Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.DueOn, Invoice.tbTask.CashCode, Invoice.tbTask.TaskCode, Invoice.tbTask.InvoiceValue, Invoice.tbTask.TaxValue, Invoice.tbTask.TaxCode
			FROM            Invoice.tbTask INNER JOIN
									 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			UNION
			SELECT        Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbItem.InvoiceNumber, Invoice.tbInvoice.DueOn, Invoice.tbItem.CashCode, '' AS TaskCode, Invoice.tbItem.InvoiceValue, Invoice.tbItem.TaxValue, Invoice.tbItem.TaxCode
			FROM            Invoice.tbItem INNER JOIN
									 Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		)
		SELECT     InvoiceNumber, TaskCode, CashCode, InvoiceValue, TaxValue, TaxRate, RoundingCode
		FROM invoice_items INNER JOIN Invoice.tbType t ON invoice_items.InvoiceTypeCode = t.InvoiceTypeCode
			INNER JOIN App.tbTaxCode ON invoice_items.TaxCode = App.tbTaxCode.TaxCode
		WHERE invoice_items.AccountCode = @AccountCode AND (CashModeCode = @CashModeCode)
		ORDER BY DueOn DESC;
	

	OPEN curInv
	FETCH NEXT FROM curInv INTO @InvoiceNumber, @TaskCode, @CashCode, @InvoiceValue, @TaxValue, @TaxRate, @RoundingCode
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
			SET @PaidTaxValue = CASE @RoundingCode 
									WHEN 0 THEN FORMAT((@PaidValue - (@PaidValue / (1 + @TaxRate))), '#.00')
									WHEN 1 THEN ROUND((@PaidValue - (@PaidValue / (1 + @TaxRate))), 2, 1)
								END
			SET @PaidInvoiceValue = @PaidValue - @PaidTaxValue
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

		FETCH NEXT FROM curInv INTO @InvoiceNumber, @TaskCode, @CashCode, @InvoiceValue, @TaxValue, @TaxRate, @RoundingCode
		END
	
	CLOSE curInv;
	DEALLOCATE curInv;

/**************************************************/
		
	--update invoice paid
	WITH invoices AS
	(
		SELECT        InvoiceNumber, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
		FROM            Invoice.tbTask
		UNION
		SELECT        InvoiceNumber, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
		FROM            Invoice.tbItem
	), totals AS
	(
		SELECT        InvoiceNumber, SUM(InvoiceValue) AS TotalInvoiceValue, SUM(TaxValue) AS TotalTaxValue, SUM(PaidValue) AS TotalPaidValue, SUM(PaidTaxValue) AS TotalPaidTaxValue
		FROM            invoices
		GROUP BY InvoiceNumber
	), selected AS
	(
		SELECT InvoiceNumber, 		
			TotalInvoiceValue, TotalTaxValue, TotalPaidValue, TotalPaidTaxValue, 
			(TotalPaidValue + TotalPaidTaxValue) AS TotalPaid
		FROM totals
		WHERE (TotalInvoiceValue + TotalTaxValue) > (TotalPaidValue + TotalPaidTaxValue)
	)
	UPDATE Invoice.tbInvoice
	SET InvoiceStatusCode = CASE WHEN TotalPaid > 0 THEN 2 ELSE 1 END,
		PaidValue = selected.TotalPaidValue, 
		PaidTaxValue = selected.TotalPaidTaxValue
	FROM         Invoice.tbInvoice INNER JOIN
						selected ON Invoice.tbInvoice.InvoiceNumber = selected.InvoiceNumber
	WHERE tbInvoice.AccountCode = @AccountCode;

	IF (@CashModeCode = 1)
		SET @Balance = @Balance * -1
		
	UPDATE    Org.tbOrg
	SET              CurrentBalance = OpeningBalance - @Balance
	WHERE     (AccountCode = @AccountCode)
	
	COMMIT TRAN OrgRebuild
	SET NOCOUNT OFF;
GO
ALTER TABLE Invoice.tbInvoice 
	DROP CONSTRAINT DF_Invoice_tb_CollectOn,
	COLUMN CollectOn;
GO
ALTER PROCEDURE [Invoice].[proc_AddTask] 
	(
	@InvoiceNumber nvarchar(20),
	@TaskCode nvarchar(20)	
	)
  AS
DECLARE @InvoiceTypeCode smallint
DECLARE @InvoiceQuantity float
DECLARE @QuantityInvoiced float

	IF EXISTS(SELECT     InvoiceNumber, TaskCode
	          FROM         Invoice.tbTask
	          WHERE     (InvoiceNumber = @InvoiceNumber) AND (TaskCode = @TaskCode))
		return
		
	SELECT   @InvoiceTypeCode = InvoiceTypeCode
	FROM         Invoice.tbInvoice
	WHERE     (InvoiceNumber = @InvoiceNumber) 

	IF EXISTS(SELECT     SUM( Invoice.tbTask.Quantity) AS QuantityInvoiced
	          FROM         Invoice.tbTask INNER JOIN
	                                Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
	          WHERE     ( Invoice.tbInvoice.InvoiceTypeCode = 0 OR
	                                Invoice.tbInvoice.InvoiceTypeCode = 2) AND ( Invoice.tbTask.TaskCode = @TaskCode) AND ( Invoice.tbInvoice.InvoiceStatusCode > 0))
		BEGIN
		SELECT TOP 1 @QuantityInvoiced = isnull(SUM( Invoice.tbTask.Quantity), 0)
		FROM         Invoice.tbTask INNER JOIN
				tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceTypeCode = 0 OR
				tbInvoice.InvoiceTypeCode = 2) AND ( Invoice.tbTask.TaskCode = @TaskCode) AND ( Invoice.tbInvoice.InvoiceStatusCode > 0)				
		END
	ELSE
		SET @QuantityInvoiced = 0
		
	IF @InvoiceTypeCode = 1 or @InvoiceTypeCode = 3
		BEGIN
		IF EXISTS(SELECT     SUM( Invoice.tbTask.Quantity) AS QuantityInvoiced
				  FROM         Invoice.tbTask INNER JOIN
										tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
				  WHERE     ( Invoice.tbInvoice.InvoiceTypeCode = 1 OR
										tbInvoice.InvoiceTypeCode = 3) AND ( Invoice.tbTask.TaskCode = @TaskCode) AND ( Invoice.tbInvoice.InvoiceStatusCode > 0))
			BEGIN
			SELECT TOP 1 @InvoiceQuantity = isnull(@QuantityInvoiced, 0) - isnull(SUM( Invoice.tbTask.Quantity), 0)
			FROM         Invoice.tbTask INNER JOIN
					tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE     ( Invoice.tbInvoice.InvoiceTypeCode = 1 OR
					tbInvoice.InvoiceTypeCode = 3) AND ( Invoice.tbTask.TaskCode = @TaskCode) AND ( Invoice.tbInvoice.InvoiceStatusCode > 0)										
			END
		ELSE
			SET @InvoiceQuantity = isnull(@QuantityInvoiced, 0)
		END
	ELSE
		BEGIN
		SELECT  @InvoiceQuantity = Quantity - isnull(@QuantityInvoiced, 0)
		FROM         Task.tbTask
		WHERE     (TaskCode = @TaskCode)
		END
			
	IF isnull(@InvoiceQuantity, 0) <= 0
		SET @InvoiceQuantity = 1
		
	INSERT INTO Invoice.tbTask
	                      (InvoiceNumber, TaskCode, Quantity, InvoiceValue, CashCode, TaxCode)
	SELECT     @InvoiceNumber AS InvoiceNumber, TaskCode, @InvoiceQuantity AS Quantity, UnitCharge * @InvoiceQuantity AS InvoiceValue, CashCode, 
	                      TaxCode
	FROM         Task.tbTask
	WHERE     (TaskCode = @TaskCode)

	UPDATE Task.tbTask
	SET ActionedOn = CURRENT_TIMESTAMP
	WHERE TaskCode = @TaskCode;
	
	EXEC Invoice.proc_Total @InvoiceNumber
			
	RETURN
GO
ALTER PROCEDURE [Invoice].[proc_Raise]
	(
	@TaskCode nvarchar(20),
	@InvoiceTypeCode smallint,
	@InvoicedOn datetime,
	@InvoiceNumber nvarchar(20) = null output
	)
AS
DECLARE @UserId nvarchar(10)
DECLARE @NextNumber int
DECLARE @InvoiceSuffix nvarchar(4)
DECLARE @PaymentDays smallint
DECLARE @DueOn datetime
DECLARE @AccountCode nvarchar(10)

	SET @InvoicedOn = isnull(@InvoicedOn, CURRENT_TIMESTAMP)
	
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
	
	SET @DueOn = Task.fnDefaultPaymentOn(@AccountCode, @InvoicedOn)
	
	BEGIN TRAN Invoice
	
	EXEC Invoice.proc_Cancel
	
	UPDATE    Invoice.tbType
	SET              NextNumber = @NextNumber + 1
	WHERE     (InvoiceTypeCode = @InvoiceTypeCode)
	
	INSERT INTO Invoice.tbInvoice
						(InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoicedOn, DueOn, ExpectedOn, InvoiceStatusCode, PaymentTerms)
	SELECT     @InvoiceNumber AS InvoiceNumber, @UserId AS UserId, Task.tbTask.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, @InvoicedOn AS InvoicedOn, 
						@DueOn AS DueOn, @DueOn AS ExpectedOn, 0 AS InvoiceStatusCode, 
						Org.tbOrg.PaymentTerms
	FROM         Task.tbTask INNER JOIN
						Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode
	WHERE     ( Task.tbTask.TaskCode = @TaskCode)

	EXEC Invoice.proc_AddTask @InvoiceNumber, @TaskCode
	
	COMMIT TRAN Invoice
	
	RETURN
GO
DROP FUNCTION IF EXISTS App.fnActiveStartOn;
DROP FUNCTION IF EXISTS App.fnDateBucket;
DROP FUNCTION IF EXISTS Cash.fnCodeDefaultAccount;
DROP FUNCTION IF EXISTS Org.fnStatementTaxAccount;
GO
ALTER PROCEDURE [Task].[proc_NextCode]
	(
		@ActivityCode nvarchar(50),
		@TaskCode nvarchar(20) OUTPUT
	)
  AS
DECLARE @UserId nvarchar(10)
DECLARE @NextTaskNumber int

	SELECT   @UserId = Usr.tbUser.UserId, @NextTaskNumber = Usr.tbUser.NextTaskNumber
	FROM         Usr.vwCredentials INNER JOIN
						Usr.tbUser ON Usr.vwCredentials.UserId = Usr.tbUser.UserId


	IF EXISTS(SELECT     App.tbRegister.NextNumber
	          FROM         Activity.tbActivity INNER JOIN
	                                App.tbRegister ON Activity.tbActivity.RegisterName = App.tbRegister.RegisterName
	          WHERE     ( Activity.tbActivity.ActivityCode = @ActivityCode))
		BEGIN
		DECLARE @RegisterName nvarchar(50)
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
		UPDATE Usr.tbUser
		Set NextTaskNumber = NextTaskNumber + 1
		WHERE UserId = @UserId
		END
		                      
	SET @TaskCode = @UserId + '_' + FORMAT(@NextTaskNumber, '0000')
			                      
	RETURN 
GO




