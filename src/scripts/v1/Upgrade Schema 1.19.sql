ALTER PROCEDURE dbo.spInvoicePay
	(
	@InvoiceNumber nvarchar(20),
	@Now datetime
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

	SELECT @UserId = UserId FROM dbo.vwUserCredentials
	

	SET @PaymentCode = @UserId + '_' + LTRIM(STR(Year(@Now)))
		+ dbo.fnPad(LTRIM(STR(Month(@Now))), 2)
		+ dbo.fnPad(LTRIM(STR(Day(@Now))), 2)
		+ dbo.fnPad(LTRIM(STR(DatePart(hh, @Now))), 2)
		+ dbo.fnPad(LTRIM(STR(DatePart(n, @Now))), 2)
		+ dbo.fnPad(LTRIM(STR(DatePart(s, @Now))), 2)
	
	WHILE EXISTS (SELECT PaymentCode FROM tbOrgPayment WHERE PaymentCode = @PaymentCode)
		BEGIN
		SET @Now = DATEADD(s, 1, @Now)
		SET @PaymentCode = @UserId + '_' + LTRIM(STR(Year(@Now)))
			+ dbo.fnPad(LTRIM(STR(Month(@Now))), 2)
			+ dbo.fnPad(LTRIM(STR(Day(@Now))), 2)
			+ dbo.fnPad(LTRIM(STR(DatePart(hh, @Now))), 2)
			+ dbo.fnPad(LTRIM(STR(DatePart(n, @Now))), 2)
			+ dbo.fnPad(LTRIM(STR(DatePart(s, @Now))), 2)
		END
		
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
