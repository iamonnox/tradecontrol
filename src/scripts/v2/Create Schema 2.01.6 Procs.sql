GO
CREATE PROCEDURE [dbo].[spTaskNextAttributeOrder] 
	(
	@TaskCode nvarchar(20),
	@PrintOrder smallint = 10 output
	)
  AS
	if exists(SELECT     TOP 1 PrintOrder
	          FROM         tbTaskAttribute
	          WHERE     (TaskCode = @TaskCode))
		begin
		SELECT  @PrintOrder = MAX(PrintOrder) 
		FROM         tbTaskAttribute
		WHERE     (TaskCode = @TaskCode)
		set @PrintOrder = @PrintOrder - (@PrintOrder % 10) + 10		
		end
	else
		set @PrintOrder = 10
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spActivityNextOperationNumber] 
	(
	@ActivityCode nvarchar(50),
	@OperationNumber smallint = 10 output
	)
  AS
	if exists(SELECT     TOP 1 OperationNumber
	          FROM         tbActivityOp
	          WHERE     (ActivityCode = @ActivityCode))
		begin
		SELECT  @OperationNumber = MAX(OperationNumber) 
		FROM         tbActivityOp
		WHERE     (ActivityCode = @ActivityCode)
		set @OperationNumber = @OperationNumber - (@OperationNumber % 10) + 10		
		end
	else
		set @OperationNumber = 10
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spActivityNextAttributeOrder] 
	(
	@ActivityCode nvarchar(50),
	@PrintOrder smallint = 10 output
	)
  AS
	if exists(SELECT     TOP 1 PrintOrder
	          FROM         tbActivityAttribute
	          WHERE     (ActivityCode = @ActivityCode))
		begin
		SELECT  @PrintOrder = MAX(PrintOrder) 
		FROM         tbActivityAttribute
		WHERE     (ActivityCode = @ActivityCode)
		set @PrintOrder = @PrintOrder - (@PrintOrder % 10) + 10		
		end
	else
		set @PrintOrder = 10
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskNextOperationNumber] 
	(
	@TaskCode nvarchar(20),
	@OperationNumber smallint = 10 output
	)
  AS
	if exists(SELECT     TOP 1 OperationNumber
	          FROM         tbTaskOp
	          WHERE     (TaskCode = @TaskCode))
		begin
		SELECT  @OperationNumber = MAX(OperationNumber) 
		FROM         tbTaskOp
		WHERE     (TaskCode = @TaskCode)
		set @OperationNumber = @OperationNumber - (@OperationNumber % 10) + 10		
		end
	else
		set @OperationNumber = 10
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spOrgContactFileAs] 
	(
	@ContactName nvarchar(100),
	@FileAs nvarchar(100) output
	)
  AS

	if charindex(' ', @ContactName) = 0
		set @FileAs = @ContactName
	else
		begin
		declare @FirstNames nvarchar(100)
		declare @LastName nvarchar(100)
		declare @LastWordPos int
		
		set @LastWordPos = charindex(' ', @ContactName) + 1
		while charindex(' ', @ContactName, @LastWordPos) != 0
			set @LastWordPos = charindex(' ', @ContactName, @LastWordPos) + 1
		
		set @FirstNames = left(@ContactName, @LastWordPos - 2)
		set @LastName = right(@ContactName, len(@ContactName) - @LastWordPos + 1)
		set @FileAs = @LastName + ', ' + @FirstNames
		end

	RETURN
GO
CREATE PROCEDURE [dbo].[spCashCopyForecastToLiveCategory]
	(
	@CategoryCode nvarchar(10),
	@StartOn datetime
	)

   AS
	UPDATE tbCashPeriod
	SET     CashValue = ForecastValue, CashTax = ForecastTax, InvoiceValue = ForecastValue, InvoiceTax = ForecastTax
	FROM         tbCashPeriod INNER JOIN
	                      tbCashCode ON tbCashPeriod.CashCode = tbCashCode.CashCode
	WHERE     (tbCashPeriod.StartOn = @StartOn) AND (tbCashCode.CategoryCode = @CategoryCode)
GO
CREATE PROCEDURE [dbo].[spCashCodeDefaults] 
	(
	@CashCode nvarchar(50)
	)
  AS
	SELECT     tbCashCode.CashCode, tbCashCode.CashDescription, tbCashCode.CategoryCode, tbCashCode.TaxCode, tbCashCode.OpeningBalance, 
	                      ISNULL(tbCashCategory.CashModeCode, 1) AS CashModeCode, tbSystemTaxCode.TaxTypeCode
	FROM         tbCashCode INNER JOIN
	                      tbSystemTaxCode ON tbCashCode.TaxCode = tbSystemTaxCode.TaxCode LEFT OUTER JOIN
	                      tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE     (tbCashCode.CashCode = @CashCode)
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskResetChargedUninvoiced]
AS
	UPDATE tbTask
	SET TaskStatusCode = 3
	FROM         tbCashCode INNER JOIN
	                      tbTask ON tbCashCode.CashCode = tbTask.CashCode LEFT OUTER JOIN
	                      tbInvoiceTask ON tbTask.TaskCode = tbInvoiceTask.TaskCode AND tbTask.TaskCode = tbInvoiceTask.TaskCode
	WHERE     (tbInvoiceTask.InvoiceNumber IS NULL) AND (tbTask.TaskStatusCode = 4)
	RETURN
GO
CREATE PROCEDURE [dbo].[spActivityWorkFlow]
	(
	@ActivityCode nvarchar(50)
	)
  AS
	SELECT     tbActivity.ActivityCode, tbTaskStatus.TaskStatus, tbCashCategory.CashModeCode, tbActivity.UnitOfMeasure, tbActivityFlow.OffsetDays
	FROM         tbActivity INNER JOIN
	                      tbTaskStatus ON tbActivity.TaskStatusCode = tbTaskStatus.TaskStatusCode INNER JOIN
	                      tbActivityFlow ON tbActivity.ActivityCode = tbActivityFlow.ChildCode LEFT OUTER JOIN
	                      tbCashCode ON tbActivity.CashCode = tbCashCode.CashCode LEFT OUTER JOIN
	                      tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE     (tbActivityFlow.ParentCode = @ActivityCode)
	ORDER BY tbActivityFlow.StepNumber	


	RETURN
GO
CREATE PROCEDURE [dbo].[spActivityMode]
	(
	@ActivityCode nvarchar(50)
	)
  AS
	SELECT     tbActivity.ActivityCode, tbActivity.UnitOfMeasure, tbTaskStatus.TaskStatus, tbCashCategory.CashModeCode
	FROM         tbActivity INNER JOIN
	                      tbTaskStatus ON tbActivity.TaskStatusCode = tbTaskStatus.TaskStatusCode LEFT OUTER JOIN
	                      tbCashCode ON tbActivity.CashCode = tbCashCode.CashCode LEFT OUTER JOIN
	                      tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE     (tbActivity.ActivityCode = @ActivityCode)
	RETURN
GO
CREATE PROCEDURE [dbo].[spCashCopyForecastToLiveCashCode]
	(
	@CashCode nvarchar(50),
	@StartOn datetime
	)

   AS
	UPDATE tbCashPeriod
	SET     CashValue = ForecastValue, CashTax = ForecastTax, InvoiceValue = ForecastValue, InvoiceTax = ForecastTax
	FROM         tbCashPeriod
	WHERE     (CashCode = @CashCode) AND (StartOn = @StartOn)
	RETURN
GO
CREATE PROCEDURE [dbo].[spCashCategoryTotals]
	(
	@CashTypeCode smallint,
	@CategoryTypeCode smallint = 2
	)
   AS

	SELECT     tbCashCategory.DisplayOrder, tbCashCategory.Category, tbCashType.CashType, tbCashCategory.CategoryCode
	FROM         tbCashCategory INNER JOIN
	                      tbCashType ON tbCashCategory.CashTypeCode = tbCashType.CashTypeCode
	WHERE     (tbCashCategory.CashTypeCode = @CashTypeCode) AND (tbCashCategory.CategoryTypeCode = @CategoryTypeCode)
	ORDER BY tbCashCategory.DisplayOrder, tbCashCategory.Category
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spInvoiceDefaultDocType]
	(
		@InvoiceNumber nvarchar(20),
		@DocTypeCode smallint OUTPUT
	)
AS
declare @InvoiceType smallint

	SELECT  @InvoiceType = InvoiceTypeCode
	FROM         tbInvoice
	WHERE     (InvoiceNumber = @InvoiceNumber)
	
	set @DocTypeCode = CASE @InvoiceType
							WHEN 1 THEN 5
							WHEN 2 THEN 6							
							WHEN 4 THEN 7
							ELSE 5
							END
							
	RETURN
GO
CREATE PROCEDURE [dbo].[spInvoiceTotal] 
	(
	@InvoiceNumber nvarchar(20)
	)
  AS
declare @InvoiceValue money
declare @TaxValue money
declare @PaidValue money
declare @PaidTaxValue money

	set @InvoiceValue = 0
	set @TaxValue = 0
	set @PaidValue = 0
	set @PaidTaxValue = 0
	
	UPDATE     tbInvoiceTask
	SET TaxValue = ROUND(tbInvoiceTask.InvoiceValue * vwSystemTaxRates.TaxRate, 2)
	FROM         tbInvoiceTask INNER JOIN
	                      vwSystemTaxRates ON tbInvoiceTask.TaxCode = vwSystemTaxRates.TaxCode
	WHERE     (tbInvoiceTask.InvoiceNumber = @InvoiceNumber)

	UPDATE     tbInvoiceItem
	SET TaxValue = CAST(ROUND(tbInvoiceItem.InvoiceValue * CAST(vwSystemTaxRates.TaxRate AS MONEY), 2) AS MONEY)
	FROM         tbInvoiceItem INNER JOIN
	                      vwSystemTaxRates ON tbInvoiceItem.TaxCode = vwSystemTaxRates.TaxCode
	WHERE     (tbInvoiceItem.InvoiceNumber = @InvoiceNumber)

	SELECT  TOP 1 @InvoiceValue = isnull(SUM(InvoiceValue), 0), 
		@TaxValue = isnull(SUM(TaxValue), 0),
		@PaidValue = isnull(SUM(PaidValue), 0), 
		@PaidTaxValue = isnull(SUM(PaidTaxValue), 0)
	FROM         tbInvoiceTask
	GROUP BY InvoiceNumber
	HAVING      (InvoiceNumber = @InvoiceNumber)
	
	SELECT  TOP 1 @InvoiceValue = @InvoiceValue + isnull(SUM(InvoiceValue), 0), 
		@TaxValue = @TaxValue + isnull(SUM(TaxValue), 0),
		@PaidValue = @PaidValue + isnull(SUM(PaidValue), 0), 
		@PaidTaxValue = @PaidTaxValue + isnull(SUM(PaidTaxValue), 0)
	FROM         tbInvoiceItem
	GROUP BY InvoiceNumber
	HAVING      (InvoiceNumber = @InvoiceNumber)
	
	set @InvoiceValue = Round(@InvoiceValue, 2)
	set @TaxValue = Round(@TaxValue, 2)
	set @PaidValue = Round(@PaidValue, 2)
	set @PaidTaxValue = Round(@PaidTaxValue, 2)
	
		
	UPDATE    tbInvoice
	SET              InvoiceValue = isnull(@InvoiceValue, 0), TaxValue = isnull(@TaxValue, 0),
		PaidValue = isnull(@PaidValue, 0), PaidTaxValue = isnull(@PaidTaxValue, 0),
		InvoiceStatusCode = CASE 
				WHEN @PaidValue >= @InvoiceValue THEN 4 
				WHEN @PaidValue > 0 THEN 3 
				ELSE 2 END
	WHERE     (InvoiceNumber = @InvoiceNumber)
	
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spInvoiceAddTask] 
	(
	@InvoiceNumber nvarchar(20),
	@TaskCode nvarchar(20)	
	)
  AS
declare @InvoiceTypeCode smallint
declare @InvoiceQuantity float
declare @QuantityInvoiced float

	if exists(SELECT     InvoiceNumber, TaskCode
	          FROM         tbInvoiceTask
	          WHERE     (InvoiceNumber = @InvoiceNumber) AND (TaskCode = @TaskCode))
		return
		
	SELECT   @InvoiceTypeCode = InvoiceTypeCode
	FROM         tbInvoice
	WHERE     (InvoiceNumber = @InvoiceNumber) 

	if exists(SELECT     SUM(tbInvoiceTask.Quantity) AS QuantityInvoiced
	          FROM         tbInvoiceTask INNER JOIN
	                                tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber
	          WHERE     (tbInvoice.InvoiceTypeCode = 1 OR
	                                tbInvoice.InvoiceTypeCode = 3) AND (tbInvoiceTask.TaskCode = @TaskCode) AND (tbInvoice.InvoiceStatusCode > 1))
		begin
		SELECT TOP 1 @QuantityInvoiced = isnull(SUM(tbInvoiceTask.Quantity), 0)
		FROM         tbInvoiceTask INNER JOIN
				tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber
		WHERE     (tbInvoice.InvoiceTypeCode = 1 OR
				tbInvoice.InvoiceTypeCode = 3) AND (tbInvoiceTask.TaskCode = @TaskCode) AND (tbInvoice.InvoiceStatusCode > 1)				
		end
	else
		set @QuantityInvoiced = 0
		
	if @InvoiceTypeCode = 2 or @InvoiceTypeCode = 4
		begin
		if exists(SELECT     SUM(tbInvoiceTask.Quantity) AS QuantityInvoiced
				  FROM         tbInvoiceTask INNER JOIN
										tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber
				  WHERE     (tbInvoice.InvoiceTypeCode = 2 OR
										tbInvoice.InvoiceTypeCode = 4) AND (tbInvoiceTask.TaskCode = @TaskCode) AND (tbInvoice.InvoiceStatusCode > 1))
			begin
			SELECT TOP 1 @InvoiceQuantity = isnull(@QuantityInvoiced, 0) - isnull(SUM(tbInvoiceTask.Quantity), 0)
			FROM         tbInvoiceTask INNER JOIN
					tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber
			WHERE     (tbInvoice.InvoiceTypeCode = 2 OR
					tbInvoice.InvoiceTypeCode = 4) AND (tbInvoiceTask.TaskCode = @TaskCode) AND (tbInvoice.InvoiceStatusCode > 1)										
			end
		else
			set @InvoiceQuantity = isnull(@QuantityInvoiced, 0)
		end
	else
		begin
		SELECT  @InvoiceQuantity = Quantity - isnull(@QuantityInvoiced, 0)
		FROM         tbTask
		WHERE     (TaskCode = @TaskCode)
		end
			
	if isnull(@InvoiceQuantity, 0) <= 0
		set @InvoiceQuantity = 1
		
	INSERT INTO tbInvoiceTask
	                      (InvoiceNumber, TaskCode, Quantity, InvoiceValue, CashCode, TaxCode)
	SELECT     @InvoiceNumber AS InvoiceNumber, TaskCode, @InvoiceQuantity AS Quantity, UnitCharge * @InvoiceQuantity AS InvoiceValue, CashCode, 
	                      TaxCode
	FROM         tbTask
	WHERE     (TaskCode = @TaskCode)
	
	exec dbo.spInvoiceTotal @InvoiceNumber
			
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskFullyInvoiced]
	(
	@TaskCode nvarchar(20),
	@IsFullyInvoiced bit = 0 output
	)
AS
declare @InvoiceValue money
declare @TotalCharge money

	SELECT @InvoiceValue = SUM(InvoiceValue)
	FROM         tbInvoiceTask
	WHERE     (TaskCode = @TaskCode)
	
	
	SELECT @TotalCharge = SUM(TotalCharge)
	FROM         tbTask
	WHERE     (TaskCode = @TaskCode)
	
	IF (@TotalCharge = @InvoiceValue)
		SET @IsFullyInvoiced = 1
	ELSE
		SET @IsFullyInvoiced = 0
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskReconcileCharge]
	(
	@TaskCode nvarchar(20)
	)
AS
declare @InvoiceValue money

	SELECT @InvoiceValue = SUM(InvoiceValue)
	FROM         tbInvoiceTask
	WHERE     (TaskCode = @TaskCode)

	UPDATE    tbTask
	SET              TotalCharge = @InvoiceValue, UnitCharge = @InvoiceValue / Quantity
	WHERE     (TaskCode = @TaskCode)	
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spOrgAddContact] 
	(
	@AccountCode nvarchar(10),
	@ContactName nvarchar(100)	 
	)
  AS
declare @FileAs nvarchar(10)
declare @RC int
	
	EXECUTE @RC = dbo.spOrgContactFileAs @ContactName, @FileAs OUTPUT	
	
	INSERT INTO tbOrgContact
	                      (AccountCode, ContactName, FileAs, PhoneNumber, EmailAddress)
	SELECT     AccountCode, @ContactName AS ContactName, @FileAs, PhoneNumber, EmailAddress
	FROM         tbOrg
	WHERE AccountCode = @AccountCode
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskEmailAddress] 
	(
	@TaskCode nvarchar(20),
	@EmailAddress nvarchar(255) OUTPUT
	)
  AS
	if exists(SELECT     tbOrgContact.EmailAddress
	          FROM         tbOrgContact INNER JOIN
	                                tbTask ON tbOrgContact.AccountCode = tbTask.AccountCode AND tbOrgContact.ContactName = tbTask.ContactName
	          WHERE     (tbTask.TaskCode = @TaskCode)
	          GROUP BY tbOrgContact.EmailAddress
	          HAVING      (NOT (tbOrgContact.EmailAddress IS NULL)))
		begin
		SELECT    @EmailAddress = tbOrgContact.EmailAddress
		FROM         tbOrgContact INNER JOIN
							tbTask ON tbOrgContact.AccountCode = tbTask.AccountCode AND tbOrgContact.ContactName = tbTask.ContactName
		WHERE     (tbTask.TaskCode = @TaskCode)
		GROUP BY tbOrgContact.EmailAddress
		HAVING      (NOT (tbOrgContact.EmailAddress IS NULL))	
		end
	else
		begin
		SELECT    @EmailAddress =  tbOrg.EmailAddress
		FROM         tbOrg INNER JOIN
							 tbTask ON tbOrg.AccountCode = tbTask.AccountCode
		WHERE     (tbTask.TaskCode = @TaskCode)
		end
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spOrgDefaultAccountCode] 
	(
	@AccountName nvarchar(100),
	@AccountCode nvarchar(10) OUTPUT 
	)
  AS
declare @ParsedName nvarchar(100)
declare @FirstWord nvarchar(100)
declare @SecondWord nvarchar(100)
declare @ValidatedCode nvarchar(10)

declare @c char(1)
declare @ascii smallint
declare @pos int
declare @ok bit

declare @Suffix smallint
declare @Rows int
		
	set @pos = 1
	set @ParsedName = ''

	while @pos <= datalength(@AccountName)
	begin
		set @ascii = ascii(substring(@AccountName, @pos, 1))
		set @ok = case 
			when @ascii = 32 then 1
			when @ascii = 45 then 1
			when (@ascii >= 48 and @ascii <= 57) then 1
			when (@ascii >= 65 and @ascii <= 90) then 1
			when (@ascii >= 97 and @ascii <= 122) then 1
			else 0
		end
		if @ok = 1
			select @ParsedName = @ParsedName + char(ascii(substring(@AccountName, @pos, 1)))
		set @pos = @pos + 1
	end

	print @ParsedName
		
	if charindex(' ', @ParsedName) = 0
		begin
		set @FirstWord = @ParsedName
		set @SecondWord = ''
		end
	else
		begin
		set @FirstWord = left(@ParsedName, charindex(' ', @ParsedName) - 1)
		set @SecondWord = right(@ParsedName, len(@ParsedName) - charindex(' ', @ParsedName))
		if charindex(' ', @SecondWord) > 0
			set @SecondWord = left(@SecondWord, charindex(' ', @SecondWord) - 1)
		end

	if exists(select ExcludedTag from tbSystemCodeExclusion where ExcludedTag = @SecondWord)
		begin
		set @SecondWord = ''
		end

	print @FirstWord
	print @SecondWord

	if len(@SecondWord) > 0
		set @AccountCode = upper(left(@FirstWord, 3)) + upper(left(@SecondWord, 3))		
	else
		set @AccountCode = upper(left(@FirstWord, 6))

	set @ValidatedCode = @AccountCode
	select @rows = count(AccountCode) from tbOrg where AccountCode = @ValidatedCode
	set @Suffix = 0
	
	while @rows > 0
	begin
		set @Suffix = @Suffix + 1
		set @ValidatedCode = @AccountCode + ltrim(str(@Suffix))
		select @rows = count(AccountCode) from tbOrg where AccountCode = @ValidatedCode
	end
	
	set @AccountCode = @ValidatedCode
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spOrgDefaultTaxCode] 
	(
	@AccountCode nvarchar(10),
	@TaxCode nvarchar(10) OUTPUT
	)
  AS
	if exists(SELECT     tbOrg.AccountCode
	          FROM         tbOrg INNER JOIN
	                                tbSystemOptions ON tbOrg.AccountCode = tbSystemOptions.AccountCode)
		begin
		SELECT @TaxCode = tbOrg.TaxCode
	          FROM         tbOrg INNER JOIN
	                                tbSystemOptions ON tbOrg.AccountCode = tbSystemOptions.AccountCode
		
		end	                              
	RETURN
GO
CREATE PROCEDURE [dbo].[spPaymentPostPaidIn]
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
		ORDER BY vwInvoiceOutstanding.CashModeCode, vwInvoiceOutstanding.CollectOn

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
CREATE PROCEDURE [dbo].[spPaymentPostPaidOut]
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
		ORDER BY vwInvoiceOutstanding.CashModeCode DESC, vwInvoiceOutstanding.CollectOn

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
CREATE PROCEDURE [dbo].[spPaymentPostInvoiced]
	(
	@PaymentCode nvarchar(20) 
	)
  AS
declare @AccountCode nvarchar(10)
declare @CashModeCode smallint
declare @CurrentBalance money
declare @PaidValue money
declare @PostValue money

	SELECT   @PaidValue = CASE WHEN PaidInValue = 0 THEN PaidOutValue ELSE PaidInValue END,
		@CurrentBalance = tbOrg.CurrentBalance,
		@AccountCode = tbOrg.AccountCode,
		@CashModeCode = CASE WHEN PaidInValue = 0 THEN 1 ELSE 2 END
	FROM         tbOrgPayment INNER JOIN
	                      tbOrg ON tbOrgPayment.AccountCode = tbOrg.AccountCode
	WHERE     (tbOrgPayment.PaymentCode = @PaymentCode)
	
	if @CashModeCode = 2
		begin
		set @PostValue = @PaidValue
		set @PaidValue = (@PaidValue + @CurrentBalance) * -1			
		exec dbo.spPaymentPostPaidIn @PaymentCode, @PaidValue output
		end
	else
		begin
		set @PostValue = @PaidValue * -1
		set @PaidValue = @PaidValue + (@CurrentBalance * -1)			
		exec dbo.spPaymentPostPaidOut @PaymentCode, @PaidValue output
		end

	update tbOrg
	set CurrentBalance = @PaidValue
	where AccountCode = @AccountCode

	UPDATE  tbOrgAccount
	SET CurrentBalance = tbOrgAccount.CurrentBalance + @PostValue
	FROM         tbOrgAccount INNER JOIN
						  tbOrgPayment ON tbOrgAccount.CashAccountCode = tbOrgPayment.CashAccountCode
	WHERE tbOrgPayment.PaymentCode = @PaymentCode
		
	RETURN
GO
CREATE Procedure [dbo].[spSettingInitialised]
(@Setting bit)
   AS
	if @Setting = 0
		goto InitialisationFailed
	else if exists (SELECT     tbOrg.AccountCode
	                FROM         tbOrg INNER JOIN
	                                      tbSystemOptions ON tbOrg.AccountCode = tbSystemOptions.AccountCode)
		begin
		if exists (SELECT     tbOrgAddress.AddressCode
		           FROM         tbOrg INNER JOIN
		                                 tbSystemOptions ON tbOrg.AccountCode = tbSystemOptions.AccountCode INNER JOIN
		                                 tbOrgAddress ON tbOrg.AddressCode = tbOrgAddress.AddressCode)
			begin
			if exists (SELECT     TOP 1 UserId
			           FROM         tbUser)
				update tbSystemOptions Set Initialised = 1
			else		
				goto InitialisationFailed
			end
		else		                    
			goto InitialisationFailed
		end
	else
		goto InitialisationFailed
			
	return 1
	
InitialisationFailed:
	update tbSystemOptions Set Initialised = 0
	return 0
GO
CREATE PROCEDURE [dbo].[spSystemCompanyName]
	(
	@AccountName nvarchar(255) = null output
	)
  AS
	SELECT top 1 @AccountName = tbOrg.AccountName
	FROM         tbOrg INNER JOIN
	                      tbSystemOptions ON tbOrg.AccountCode = tbSystemOptions.AccountCode
	RETURN
GO
CREATE PROCEDURE [dbo].[spOrgNextAddressCode] 
	(
	@AccountCode nvarchar(10),
	@AddressCode nvarchar(15) OUTPUT
	)
  AS
declare @AddCount int

	SELECT @AddCount = COUNT(AddressCode) 
	FROM         tbOrgAddress
	WHERE     (AccountCode = @AccountCode)
	
	set @AddCount = @AddCount + 1
	set @AddressCode = upper(@AccountCode) + '_' + stuff('000', 4 - len(ltrim(str(@AddCount))), len(ltrim(str(@AddCount))), @AddCount)
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spOrgAddAddress] 
	(
	@AccountCode nvarchar(10),
	@Address ntext
	)
  AS
declare @AddressCode nvarchar(15)
declare @RC int
	
	EXECUTE @RC = dbo.spOrgNextAddressCode @AccountCode, @AddressCode OUTPUT
	
	INSERT INTO tbOrgAddress
	                      (AddressCode, AccountCode, Address)
	VALUES     (@AddressCode, @AccountCode, @Address)
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spPaymentPostMisc]
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
	                      4 AS InvoiceStatusCode, tbOrgPayment.PaidOn, CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate) 
	                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate) END AS InvoiceValue, 
	                      CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - ROUND((tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate)), 
	                      2) WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - ROUND((tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate)), 
	                      2) END AS TaxValue, CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate) 
	                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate) END AS PaidValue, 
	                      CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - ROUND((tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate)), 
	                      2) WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - ROUND((tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate)), 
	                      2) END AS PaidTaxValue, 1 AS Printed
	FROM         tbOrgPayment INNER JOIN
	                      vwSystemTaxRates ON tbOrgPayment.TaxCode = vwSystemTaxRates.TaxCode
	WHERE     (tbOrgPayment.PaymentCode = @PaymentCode)

	INSERT INTO tbInvoiceItem
						(InvoiceNumber, CashCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, TaxCode)
	SELECT     @InvoiceNumber AS InvoiceNumber, tbOrgPayment.CashCode, 
	                      CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate) 
	                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate) END AS InvoiceValue, 
	                      CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - ROUND((tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate)), 
	                      2) WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - ROUND((tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate)), 
	                      2) END AS TaxValue, CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate) 
	                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate) END AS PaidValue, 
	                      CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - ROUND((tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate)), 
	                      2) WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - ROUND((tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate)), 
	                      2) END AS PaidTaxValue, tbOrgPayment.TaxCode
	FROM         tbOrgPayment INNER JOIN
	                      vwSystemTaxRates ON tbOrgPayment.TaxCode = vwSystemTaxRates.TaxCode
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
	                      vwSystemTaxRates ON tbOrgPayment.TaxCode = vwSystemTaxRates.TaxCode
	WHERE     (PaymentCode = @PaymentCode)
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spPaymentPost] 
  AS
declare @PaymentCode nvarchar(20)

	declare curMisc cursor local for
		SELECT     PaymentCode
		FROM         tbOrgPayment
		WHERE     (PaymentStatusCode = 1) AND (NOT (CashCode IS NULL))
		ORDER BY AccountCode, PaidOn

	declare curInv cursor local for
		SELECT     PaymentCode
		FROM         tbOrgPayment
		WHERE     (PaymentStatusCode = 1) AND (CashCode IS NULL)
		ORDER BY AccountCode, PaidOn
		
	begin tran Payment
	open curMisc
	fetch next from curMisc into @PaymentCode
	while @@FETCH_STATUS = 0
		begin
		exec dbo.spPaymentPostMisc @PaymentCode		
		fetch next from curMisc into @PaymentCode	
		end

	close curMisc
	deallocate curMisc
	
	open curInv
	fetch next from curInv into @PaymentCode
	while @@FETCH_STATUS = 0
		begin
		exec dbo.spPaymentPostInvoiced @PaymentCode		
		fetch next from curInv into @PaymentCode	
		end

	close curInv
	deallocate curInv

	commit tran Payment
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskAssignToParent] 
	(
	@ChildTaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20)
	)
  AS
declare @TaskTitle nvarchar(100)
declare @StepNumber smallint

	IF EXISTS (SELECT ParentTaskCode FROM tbTaskFlow WHERE ChildTaskCode = @ChildTaskCode)
		DELETE FROM tbTaskFlow WHERE ChildTaskCode = @ChildTaskCode

	IF EXISTS(SELECT     TOP 1 StepNumber
	          FROM         tbTaskFlow
	          WHERE     (ParentTaskCode = @ParentTaskCode))
		begin
		SELECT  @StepNumber = MAX(StepNumber) 
		FROM         tbTaskFlow
		WHERE     (ParentTaskCode = @ParentTaskCode)
		set @StepNumber = @StepNumber - (@StepNumber % 10) + 10		
		end
	else
		set @StepNumber = 10


	SELECT     @TaskTitle = TaskTitle
	FROM         tbTask
	WHERE     (TaskCode = @ParentTaskCode)		
	
	UPDATE    tbTask
	SET              TaskTitle = @TaskTitle
	WHERE     (TaskCode = @ChildTaskCode) AND ((TaskTitle IS NULL) OR (TaskTitle = ActivityCode))
	
	INSERT INTO tbTaskFlow
	                      (ParentTaskCode, StepNumber, ChildTaskCode)
	VALUES     (@ParentTaskCode, @StepNumber, @ChildTaskCode)
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spMenuInsert]
	(
		@MenuName nvarchar(50),
		@FromMenuId smallint = 0,
		@MenuId smallint = null OUTPUT
	)
     AS

	begin tran trnMenu
	
	insert into tbProfileMenu (MenuName) values (@MenuName)
	select @MenuId = @@IDENTITY
	
	if @FromMenuId = 0
		begin
		insert into tbProfileMenuEntry (MenuId, FolderId, ItemId, ItemText, Command,  Argument)
				values (@MenuId, 1, 0, @MenuName, 0, 'Root')
		end
	else
		begin
		INSERT INTO tbProfileMenuEntry
		                      (MenuId, FolderId, ItemId, OpenMode, Argument, ProjectName, Command, ItemText)
		SELECT     @MenuId AS ToMenuId, FolderId, ItemId, OpenMode, Argument, ProjectName, Command, ItemText
		FROM         tbProfileMenuEntry
		WHERE     (MenuId = @FromMenuId)
		end
	commit tran trnMenu

	RETURN
GO
CREATE PROCEDURE [dbo].[spSettingAddCalDateRange]
	(
		@CalendarCode nvarchar(10),
		@FromDate datetime,
		@ToDate datetime
	)
   AS
declare @UnavailableDate datetime

	select @UnavailableDate = @FromDate
	
	while @UnavailableDate <= @ToDate
	begin
		insert into tbSystemCalendarHoliday (CalendarCode, UnavailableOn)
		values (@CalendarCode, @UnavailableDate)
		select @UnavailableDate = DateAdd(d, 1, @UnavailableDate)
	end

	RETURN
GO
CREATE PROCEDURE [dbo].[spSettingDelCalDateRange]
	(
		@CalendarCode nvarchar(10),
		@FromDate datetime,
		@ToDate datetime
	)
   AS
	DELETE FROM tbSystemCalendarHoliday
		WHERE UnavailableOn >= @FromDate
			AND UnavailableOn <= @ToDate
			AND CalendarCode = @CalendarCode
			
	RETURN 1
GO
CREATE PROCEDURE [dbo].[spSettingLicence]
	(
		@Licence binary (50) = null OUTPUT,
		@LicenceType smallint = null OUTPUT
	)
   AS
	select top 1 @Licence = [Licence], @LicenceType = LicenceType 
	from tbSystemInstall
	where CategoryTypeCode = 0 and ReleaseTypeCode = 0	
	RETURN
GO
CREATE PROCEDURE [dbo].[spSettingLicenceAdd]
	(
		@Licence binary (50),
		@LicenceType smallint
	)
    AS
	update tbSystemInstall
	set 
		[Licence] = @Licence,
		LicenceType = @LicenceType
	where
		CategoryTypeCode = 0
		and ReleaseTypeCode = 0
	
	if @@ROWCOUNT > 0
		RETURN 1
	else
		RETURN 0
GO
CREATE PROCEDURE [dbo].[spSystemYearPeriods]
	(
	@YearNumber int
	)
   AS
	SELECT     tbSystemYear.Description, tbSystemMonth.MonthName
				FROM         tbSystemYearPeriod INNER JOIN
									tbSystemYear ON tbSystemYearPeriod.YearNumber = tbSystemYear.YearNumber INNER JOIN
									tbSystemMonth ON tbSystemYearPeriod.MonthNumber = tbSystemMonth.MonthNumber
				WHERE     (tbSystemYearPeriod.YearNumber = @YearNumber)
				ORDER BY tbSystemYearPeriod.YearNumber, tbSystemYearPeriod.StartOn
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskProject] 
	(
	@TaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20) output
	)
  AS
	set @ParentTaskCode = @TaskCode
	while exists(SELECT     ParentTaskCode
	             FROM         tbTaskFlow
	             WHERE     (ChildTaskCode = @ParentTaskCode))
		select @ParentTaskCode = ParentTaskCode
	             FROM         tbTaskFlow
	             WHERE     (ChildTaskCode = @ParentTaskCode)
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskParent] 
	(
	@TaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20) output
	)
  AS
	set @ParentTaskCode = @TaskCode
	if exists(SELECT     ParentTaskCode
	             FROM         tbTaskFlow
	             WHERE     (ChildTaskCode = @ParentTaskCode))
		select @ParentTaskCode = ParentTaskCode
	             FROM         tbTaskFlow
	             WHERE     (ChildTaskCode = @ParentTaskCode)
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskOp]
	(
	@TaskCode nvarchar(20)
	)
AS
		IF EXISTS (SELECT     TaskCode
	           FROM         tbTaskOp
	           WHERE     (TaskCode = @TaskCode))
	    BEGIN
		SELECT     tbTaskOp.*
		       FROM         tbTaskOp
		       WHERE     (TaskCode = @TaskCode)
		END
	ELSE
		BEGIN
		SELECT     tbTaskOp.*
		       FROM         tbTaskFlow INNER JOIN
		                             tbTaskOp ON tbTaskFlow.ParentTaskCode = tbTaskOp.TaskCode
		       WHERE     (tbTaskFlow.ChildTaskCode = @TaskCode)
		END
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskDelete] 
	(
	@TaskCode nvarchar(20)
	)
  AS

declare @ChildTaskCode nvarchar(20)

	DELETE FROM tbTaskFlow
	WHERE     (ChildTaskCode = @TaskCode)

	declare curFlow cursor local for
		SELECT     ChildTaskCode
		FROM         tbTaskFlow
		WHERE     (ParentTaskCode = @TaskCode)
	
	open curFlow		
	fetch next from curFlow into @ChildTaskCode
	while @@FETCH_STATUS = 0
		begin
		exec dbo.spTaskDelete @ChildTaskCode
		fetch next from curFlow into @ChildTaskCode		
		end
	
	close curFlow
	deallocate curFlow
	
	delete from tbTask
	where (TaskCode = @TaskCode)
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskIsProject] 
	(
	@TaskCode nvarchar(20),
	@IsProject bit = 0 output
	)
  AS
	if exists(SELECT     TOP 1 Attribute
	          FROM         tbTaskAttribute
	          WHERE     (TaskCode = @TaskCode))
		set @IsProject = 1
	else if exists (SELECT     TOP 1 ParentTaskCode, StepNumber
	                FROM         tbTaskFlow
	                WHERE     (ParentTaskCode = @TaskCode))
		set @IsProject = 1
	else
		set @IsProject = 0
	RETURN
GO
CREATE PROCEDURE [dbo].[spSystemReassignUser] 
	(
	@UserId nvarchar(10)
	)
  AS
	UPDATE    tbUser
	SET       LogonName = (SUSER_SNAME())
	WHERE     (UserId = @UserId)
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskSetOpStatus]
	(
		@TaskCode nvarchar(20),
		@TaskStatusCode smallint
	)
AS
declare @OpStatusCode smallint
declare @OperationNumber smallint
	
	set @OpStatusCode = CASE @TaskStatusCode
							WHEN 1 THEN 1
							WHEN 2 THEN 2
							ELSE 3
						END
	
	if exists(SELECT TOP 1 OperationNumber
	          FROM         tbTaskOp
	          WHERE     (TaskCode = @TaskCode))
		begin
		UPDATE    tbTaskOp
		SET              OpStatusCode = @OpStatusCode
		WHERE     (OpTypeCode = 1) AND (TaskCode = @TaskCode)
		
		if exists (SELECT TOP 1 OperationNumber
	          FROM         tbTaskOp
	          WHERE     (TaskCode = @TaskCode) AND (OpTypeCode = 2))
	        begin
			SELECT @OperationNumber = MIN(OperationNumber)
			FROM         tbTaskOp
			WHERE     (OpTypeCode = 2) AND (TaskCode = @TaskCode)	          
				          
			UPDATE    tbTaskOp
			SET              OpStatusCode = @OpStatusCode
			WHERE     (OperationNumber = @OperationNumber) AND (TaskCode = @TaskCode)
	        end
		end
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskSetActionOn]
	(
	@TaskCode nvarchar(20)
	)
AS
declare @OperationNumber smallint
declare @OpTypeCode smallint
declare @ActionOn datetime
		
	SELECT @OperationNumber = MAX(OperationNumber)
	FROM         tbTaskOp
	WHERE     (TaskCode = @TaskCode)
	
	
	SELECT @OpTypeCode = OpTypeCode, @ActionOn = EndOn
	FROM         tbTaskOp
	WHERE     (TaskCode = @TaskCode) AND (OperationNumber = @OperationNumber)

	IF @OpTypeCode = 2
		BEGIN
		SELECT @OperationNumber = MIN(OperationNumber)
		FROM         tbTaskOp
		WHERE     (TaskCode = @TaskCode) AND (OpTypeCode = 2)
		
		SELECT @ActionOn = EndOn
		FROM         tbTaskOp
		WHERE     (TaskCode = @TaskCode) AND (OperationNumber = @OperationNumber)
				
		END
		
	UPDATE    tbTask
	SET              ActionOn = @ActionOn
	WHERE     (TaskCode = @TaskCode) AND (ActionOn <> @ActionOn)

		
	RETURN
GO
CREATE PROCEDURE [dbo].[spActivityParent]
	(
	@ActivityCode nvarchar(50),
	@ParentCode nvarchar(50) = null output
	)
  AS
	if exists(SELECT     ParentCode
	          FROM         tbActivityFlow
	          WHERE     (ChildCode = @ActivityCode))
		SELECT @ParentCode = ParentCode
		FROM         tbActivityFlow
		WHERE     (ChildCode = @ActivityCode)
	else
		set @ParentCode = @ActivityCode
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spActivityNextStepNumber] 
	(
	@ActivityCode nvarchar(50),
	@StepNumber smallint = 10 output
	)
  AS
	if exists(SELECT     TOP 1 StepNumber
	          FROM         tbActivityFlow
	          WHERE     (ParentCode = @ActivityCode))
		begin
		SELECT  @StepNumber = MAX(StepNumber) 
		FROM         tbActivityFlow
		WHERE     (ParentCode = @ActivityCode)
		set @StepNumber = @StepNumber - (@StepNumber % 10) + 10		
		end
	else
		set @StepNumber = 10
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spCashCategoryCodeFromName]
	(
		@Category nvarchar(50),
		@CategoryCode nvarchar(10) output
	)
   AS
	if exists (SELECT CategoryCode
				FROM         tbCashCategory
				WHERE     (Category = @Category))
		SELECT @CategoryCode = CategoryCode
		FROM         tbCashCategory
		WHERE     (Category = @Category)
	else
		set @CategoryCode = 0
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spCashCategoryCashCodes]
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
CREATE PROCEDURE [dbo].[spInvoicePay]
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
DECLARE @CashCode nvarchar(50)

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
	
	SELECT  @TaskOutstanding = SUM(tbInvoiceTask.InvoiceValue + tbInvoiceTask.TaxValue - tbInvoiceTask.PaidValue + tbInvoiceTask.PaidTaxValue),
		@CashCode = MIN(tbInvoiceTask.CashCode)	                      
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
							  (PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, PaidOn, PaidInValue, PaidOutValue, PaymentReference)
		VALUES     (@PaymentCode,@UserId, 1,@AccountCode,@CashAccountCode,@CashCode,@Now,@PaidIn,@PaidOut,@InvoiceNumber)		
		
		EXEC dbo.spPaymentPostInvoiced @PaymentCode			
		END
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spCashGeneratePeriods]
    AS
declare @YearNumber smallint
declare @StartOn datetime
declare @PeriodStartOn datetime
declare @CashStatusCode smallint
declare @Period smallint

	declare curYr cursor for	
		SELECT     YearNumber, CONVERT(datetime, '1/' + STR(StartMonth) + '/' + STR(YearNumber), 103) AS StartOn, CashStatusCode
		FROM         tbSystemYear

	open curYr
	
	fetch next from curYr into @YearNumber, @StartOn, @CashStatusCode
	while @@FETCH_STATUS = 0
		begin
		set @PeriodStartOn = @StartOn
		set @Period = 1
		while @Period < 13
			begin
			if not exists (select MonthNumber from tbSystemYearPeriod where YearNumber = @YearNumber and MonthNumber = datepart(m, @PeriodStartOn))
				begin
				insert into tbSystemYearPeriod (YearNumber, StartOn, MonthNumber, CashStatusCode)
				values (@YearNumber, @PeriodStartOn, datepart(m, @PeriodStartOn), 1)				
				end
			set @PeriodStartOn = dateadd(m, 1, @PeriodStartOn)	
			set @Period = @Period + 1
			end		
				
		fetch next from curYr into @YearNumber, @StartOn, @CashStatusCode
		end
	
	
	close curYr
	deallocate curYr
	
	INSERT INTO tbCashPeriod
	                      (CashCode, StartOn)
	SELECT     vwCashPeriods.CashCode, vwCashPeriods.StartOn
	FROM         vwCashPeriods LEFT OUTER JOIN
	                      tbCashPeriod ON vwCashPeriods.CashCode = tbCashPeriod.CashCode AND vwCashPeriods.StartOn = tbCashPeriod.StartOn
	WHERE     (tbCashPeriod.CashCode IS NULL)
	RETURN
GO
CREATE PROCEDURE [dbo].[spCashCopyLiveToForecastCashCode]
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
declare @CashValue money
declare @CashTax money

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
		SELECT     StartOn, CashValue, CashTax, InvoiceValue, InvoiceTax
		FROM         tbCashPeriod
		WHERE     (StartOn <= @EndPeriod AND StartOn >= @StartPeriod) and (CashCode = @CashCode)
		ORDER BY	CashCode, StartOn	
		
	while @Years > 0
		begin
		open curPe

		fetch next from curPe into @StartPeriod, @CashValue, @CashTax, @InvoiceValue, @InvoiceTax
		while @@FETCH_STATUS = 0
			begin
			if @InvoiceValue = 0
				set @InvoiceValue = @CashValue
			if @InvoiceTax = 0
				set @InvoiceTax = @CashTax
				
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
			fetch next from curPe into @StartPeriod, @CashValue, @CashTax, @InvoiceValue, @InvoiceTax
			end
		
		set @Years = @Years - 1
		close curPe
		end
		
	deallocate curPe
			
	return 

LastMonthCopyMode:
declare @Idx integer

	SELECT TOP 1 @CashValue = CashValue, @CashTax = CashTax, @InvoiceValue = InvoiceValue, @InvoiceTax = InvoiceTax
	FROM         tbCashPeriod
	WHERE     (CashCode = @CashCode) AND (StartOn < @CurPeriod)
	ORDER BY StartOn DESC
	
	if @InvoiceValue = 0
		set @InvoiceValue = @CashValue
	if @InvoiceTax = 0
		set @InvoiceTax = @CashTax
		
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
CREATE  PROCEDURE [dbo].[spSettingNewCompany]
	(
	@FirstNames nvarchar(50),
	@LastName nvarchar(50),
	@CompanyName nvarchar(50),
	@CompanyAddress ntext,
	@AccountCode nvarchar(50),
	@CompanyNumber nvarchar(20) = null,
	@VatNumber nvarchar(50) = null,
	@LandLine nvarchar(20) = null,
	@Fax nvarchar(20) = null,
	@Email nvarchar(50) = null,
	@WebSite nvarchar(128) = null
	)
  AS
declare @UserId nvarchar(10)
declare @CalendarCode nvarchar(10)
declare @MenuId smallint

declare @AppAccountCode nvarchar(10)
declare @TaxCode nvarchar(10)
declare @AddressCode nvarchar(15)

declare @SqlDataVersion real
	
	select top 1 @MenuId = MenuId from tbProfileMenu
	select top 1 @CalendarCode = CalendarCode from tbSystemCalendar 

	set @UserId = upper(left(@FirstNames, 1)) + upper(left(@LastName, 1))
	INSERT INTO tbUser
	                      (UserId, UserName, LogonName, CalendarCode, PhoneNumber, FaxNumber, EmailAddress, Administrator)
	VALUES     (@UserId, @FirstNames + N' ' + @LastName, SUSER_SNAME(), @CalendarCode, @LandLine, @Fax, @Email, 1)

	INSERT INTO tbUserMenu
	                      (UserId, MenuId)
	VALUES     (@UserId, @MenuId)

	set @AppAccountCode = left(@AccountCode, 10)
	set @TaxCode = 'T0'
	
	INSERT INTO tbOrg
	                      (AccountCode, AccountName, OrganisationTypeCode, OrganisationStatusCode, PhoneNumber, FaxNumber, EmailAddress, WebSite, CompanyNumber, 
	                      VatNumber, TaxCode)
	VALUES     (@AppAccountCode, @CompanyName, 8, 2, @LandLine, @Fax, @Email, @Website, @CompanyNumber, @VatNumber, @TaxCode)

	exec dbo.spOrgNextAddressCode @AppAccountCode, @AddressCode output
	
	insert into tbOrgAddress (AddressCode, AccountCode, Address)
	values (@AddressCode, @AppAccountCode, @CompanyAddress)

	INSERT INTO tbOrgContact
	                      (AccountCode, ContactName, FileAs, NickName, PhoneNumber, FaxNumber, EmailAddress)
	VALUES     (@AppAccountCode, @FirstNames + N' ' + @LastName, @LastName + N', ' + @FirstNames, @FirstNames, @LandLine, @Fax, @Email)	 

	SELECT @SqlDataVersion = DataVersion
	FROM         tbSystemInstall
	WHERE     (CategoryTypeCode = 0) AND (ReleaseTypeCode = 0)

	INSERT INTO tbOrgAccount
						(AccountCode, CashAccountCode, CashAccountName)
	VALUES     (@AccountCode, N'CASH', N'Petty Cash')	

	INSERT INTO tbSystemOptions
						(Identifier, Initialised, SQLDataVersion, AccountCode, DefaultPrintMode, BucketTypeCode, BucketIntervalCode, ShowCashGraphs)
	VALUES     (N'TRU', 0, @SQLDataVersion, @AppAccountCode, 2, 1, 2, 1)
	
	update tbCashTaxType
	set CashCode = N'900'
	where TaxTypeCode = 3
	
	update tbCashTaxType
	set CashCode = N'902'
	where TaxTypeCode = 1
	
	update tbCashTaxType
	set CashCode = N'901'
	where TaxTypeCode = 2
	
	update tbCashTaxType
	set CashCode = N'903'
	where TaxTypeCode = 4
	
	RETURN 1
GO
CREATE PROCEDURE [dbo].[spInvoiceAccept] 
	(
	@InvoiceNumber nvarchar(20)
	)
  AS

		if exists(SELECT     InvoiceNumber
	          FROM         tbInvoiceItem
	          WHERE     (InvoiceNumber = @InvoiceNumber)) 
		or exists(SELECT     InvoiceNumber
	          FROM         tbInvoiceTask
	          WHERE     (InvoiceNumber = @InvoiceNumber))
		begin
			begin tran trAcc
			
			exec dbo.spInvoiceTotal @InvoiceNumber
			
			UPDATE    tbInvoice
			SET              InvoiceStatusCode = 2
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (InvoiceStatusCode = 1) 
	
			UPDATE tbTask
			SET TaskStatusCode = 4
			FROM         tbTask INNER JOIN
								vwTaskInvoicedQuantity ON tbTask.TaskCode = vwTaskInvoicedQuantity.TaskCode AND 
								tbTask.Quantity <= vwTaskInvoicedQuantity.InvoiceQuantity INNER JOIN
								tbInvoiceTask ON tbTask.TaskCode = tbInvoiceTask.TaskCode AND tbTask.TaskCode = tbInvoiceTask.TaskCode
			WHERE     (tbInvoiceTask.InvoiceNumber = @InvoiceNumber) And (tbTask.TaskStatusCode < 4)	
			
			commit tran trAcc
		end
			
	RETURN
GO
CREATE PROCEDURE [dbo].[spInvoiceCancel] 
  AS

	UPDATE tbTask
	SET TaskStatusCode = 3
	FROM         tbTask INNER JOIN
	                      tbInvoiceTask ON tbTask.TaskCode = tbInvoiceTask.TaskCode AND tbTask.TaskCode = tbInvoiceTask.TaskCode INNER JOIN
	                      tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber INNER JOIN
	                      vwUserCredentials ON tbInvoice.UserId = vwUserCredentials.UserId
	WHERE     (tbInvoice.InvoiceTypeCode = 1 OR
	                      tbInvoice.InvoiceTypeCode = 3) AND (tbInvoice.InvoiceStatusCode = 1)
	                      
	DELETE tbInvoice
	FROM         tbInvoice INNER JOIN
	                      vwUserCredentials ON tbInvoice.UserId = vwUserCredentials.UserId
	WHERE     (tbInvoice.InvoiceStatusCode = 1)

	
	RETURN
GO
CREATE PROCEDURE [dbo].[spOrgBalanceOutstanding] 
	(
	@AccountCode nvarchar(10),
	@Balance money = 0 OUTPUT
	)
  AS

	if exists(SELECT     tbInvoice.AccountCode
	          FROM         tbInvoice INNER JOIN
	                                tbInvoiceType ON tbInvoice.InvoiceTypeCode = tbInvoiceType.InvoiceTypeCode
	          WHERE     (tbInvoice.AccountCode = @AccountCode) AND (tbInvoice.InvoiceStatusCode > 1 AND tbInvoice.InvoiceStatusCode < 4)
	          GROUP BY tbInvoice.AccountCode)
		begin
		SELECT @Balance = Balance
		FROM         vwOrgBalanceOutstanding
		WHERE     (AccountCode = @AccountCode)		
		end
	else
		set @Balance = 0
		
	if exists(SELECT     AccountCode
	          FROM         tbOrgPayment
	          WHERE     (PaymentStatusCode = 1) AND (AccountCode = @AccountCode)) AND (@Balance <> 0)
		begin
		SELECT  @Balance = @Balance - SUM(PaidInValue - PaidOutValue) 
		FROM         tbOrgPayment
		WHERE     (PaymentStatusCode = 1) AND (AccountCode = @AccountCode)		
		end
		
	SELECT    @Balance = isnull(@Balance, 0) - CurrentBalance
	FROM         tbOrg
	WHERE     (AccountCode = @AccountCode)
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskProfit]
	(
	@ParentTaskCode nvarchar(20),
	@TotalCost money = 0 output,
	@InvoicedCost money = 0 output,
	@InvoicedCostPaid money = 0 output
	)
AS
declare @TaskCode nvarchar(20)
declare @TotalCharge money
declare @TotalInvoiced money
declare @TotalPaid money
declare @CashModeCode smallint

	declare curFlow cursor local for
		SELECT     tbTask.TaskCode, vwTaskCashMode.CashModeCode, tbTask.TotalCharge
		FROM         tbTask INNER JOIN
							  tbTaskFlow ON tbTask.TaskCode = tbTaskFlow.ChildTaskCode INNER JOIN
							  vwTaskCashMode ON tbTask.TaskCode = vwTaskCashMode.TaskCode
		WHERE     (tbTaskFlow.ParentTaskCode = @ParentTaskCode)	

	open curFlow
	fetch next from curFlow into @TaskCode, @CashModeCode, @TotalCharge
	while @@FETCH_STATUS = 0
		begin
		
		SELECT  @TotalInvoiced = SUM(CASE WHEN tbInvoiceType.CashModeCode = 1 THEN tbInvoiceTask.InvoiceValue * - 1 ELSE tbInvoiceTask.InvoiceValue END), 
				@TotalPaid = SUM(CASE WHEN tbInvoiceType.CashModeCode = 1 THEN tbInvoiceTask.PaidValue * - 1 ELSE tbInvoiceTask.PaidValue END) 	                      
		FROM         tbInvoiceTask INNER JOIN
							  tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber INNER JOIN
							  tbInvoiceType ON tbInvoice.InvoiceTypeCode = tbInvoiceType.InvoiceTypeCode
		WHERE     (tbInvoiceTask.TaskCode = @TaskCode)

		set @InvoicedCost = @InvoicedCost + @TotalInvoiced
		set @InvoicedCostPaid = @InvoicedCostPaid + @TotalPaid
		set @TotalCost = @TotalCost + case when @CashModeCode = 1 then @TotalCharge else @TotalCharge * -1 end
			
		exec dbo.spTaskProfit @TaskCode, @TotalCost output, @InvoicedCost output, @InvoicedCostPaid output
		fetch next from curFlow into @TaskCode, @CashModeCode, @TotalCharge
		end
	
	close curFlow
	deallocate curFlow
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskEmailDetail] 
	(
	@TaskCode nvarchar(20)
	)
  AS
declare @NickName nvarchar(100)
declare @EmailAddress nvarchar(255)


	if exists(SELECT     tbOrgContact.ContactName
	          FROM         tbOrgContact INNER JOIN
	                                tbTask ON tbOrgContact.AccountCode = tbTask.AccountCode AND tbOrgContact.ContactName = tbTask.ContactName
	          WHERE     (tbTask.TaskCode = @TaskCode))
		begin
		SELECT  @NickName = case when tbOrgContact.NickName is null then tbOrgContact.ContactName else tbOrgContact.NickName end
					  FROM         tbOrgContact INNER JOIN
											tbTask ON tbOrgContact.AccountCode = tbTask.AccountCode AND tbOrgContact.ContactName = tbTask.ContactName
					  WHERE     (tbTask.TaskCode = @TaskCode)				
		end
	else
		begin
		SELECT @NickName = ContactName
		FROM         tbTask
		WHERE     (TaskCode = @TaskCode)
		end
	
	exec dbo.spTaskEmailAddress	@TaskCode, @EmailAddress output
	
	SELECT     tbTask.TaskCode, tbTask.TaskTitle, tbOrg.AccountCode, tbOrg.AccountName, @NickName AS NickName, @EmailAddress AS EmailAddress, 
	                      tbTask.ActivityCode, tbTaskStatus.TaskStatus, tbTask.TaskNotes
	FROM         tbTask INNER JOIN
	                      tbTaskStatus ON tbTask.TaskStatusCode = tbTaskStatus.TaskStatusCode INNER JOIN
	                      tbOrg ON tbTask.AccountCode = tbOrg.AccountCode
	WHERE     (tbTask.TaskCode = @TaskCode)

	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskEmailFooter] 
  AS
declare @AccountName nvarchar(255)
declare @WebSite nvarchar(255)

	SELECT TOP 1 @AccountName = tbOrg.AccountName, @WebSite = tbOrg.WebSite
	FROM         tbOrg INNER JOIN
	                      tbSystemOptions ON tbOrg.AccountCode = tbSystemOptions.AccountCode
	
	SELECT     tbUser.UserName, tbUser.PhoneNumber, tbUser.MobileNumber, @AccountName AS AccountName, @Website AS Website
	FROM         vwUserCredentials INNER JOIN
	                      tbUser ON vwUserCredentials.UserId = tbUser.UserId
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spOrgStatement]
	(
	@AccountCode nvarchar(10)
	)
  AS
declare @FromDate datetime
	
	SELECT @FromDate = dateadd(d, StatementDays * -1, getdate())
	FROM         tbOrg
	WHERE     (AccountCode = @AccountCode)
	
	SELECT     TransactedOn, OrderBy, Reference, StatementType, Charge, Balance
	FROM         fnOrgStatement(@AccountCode) fnOrgStatement
	WHERE     (TransactedOn >= @FromDate)
	ORDER BY TransactedOn, OrderBy
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spCashAccountRebuild]
	(
	@CashAccountCode nvarchar(10)
	)
  AS
	
	UPDATE tbOrgAccount
	SET CurrentBalance = vwCashAccountRebuild.CurrentBalance
	FROM         vwCashAccountRebuild INNER JOIN
						tbOrgAccount ON vwCashAccountRebuild.CashAccountCode = tbOrgAccount.CashAccountCode
	WHERE vwCashAccountRebuild.CashAccountCode = @CashAccountCode 

	UPDATE tbOrgAccount
	SET CurrentBalance = 0
	FROM         vwCashAccountRebuild RIGHT OUTER JOIN
	                      tbOrgAccount ON vwCashAccountRebuild.CashAccountCode = tbOrgAccount.CashAccountCode
	WHERE     (vwCashAccountRebuild.CashAccountCode IS NULL) AND tbOrgAccount.CashAccountCode = @CashAccountCode
										
	RETURN
GO
CREATE PROCEDURE [dbo].[spCashAccountRebuildAll]
  AS
	
	UPDATE tbOrgAccount
	SET CurrentBalance = vwCashAccountRebuild.CurrentBalance
	FROM         vwCashAccountRebuild INNER JOIN
						tbOrgAccount ON vwCashAccountRebuild.CashAccountCode = tbOrgAccount.CashAccountCode
	
	UPDATE tbOrgAccount
	SET CurrentBalance = 0
	FROM         vwCashAccountRebuild RIGHT OUTER JOIN
	                      tbOrgAccount ON vwCashAccountRebuild.CashAccountCode = tbOrgAccount.CashAccountCode
	WHERE     (vwCashAccountRebuild.CashAccountCode IS NULL)

	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskSetStatus]
	(
		@TaskCode nvarchar(20)
	)
  AS
declare @ChildTaskCode nvarchar(20)
declare @TaskStatusCode smallint
declare @CashCode nvarchar(20)
declare @IsOrder bit

	select @TaskStatusCode = TaskStatusCode, @CashCode = CashCode
	from tbTask
	where TaskCode = @TaskCode
	
	exec dbo.spTaskSetOpStatus @TaskCode, @TaskStatusCode
	
	if @CashCode IS NULL
		set @IsOrder = 0
	else
		set @IsOrder = 1
	
	declare curTask cursor local for
		SELECT     tbTaskFlow.ChildTaskCode
		FROM         tbTaskFlow INNER JOIN
		                      tbTask ON tbTaskFlow.ChildTaskCode = tbTask.TaskCode
		WHERE     (tbTaskFlow.ParentTaskCode = @TaskCode)

	open curTask
	fetch next from curTask into @ChildTaskCode
	while @@FETCH_STATUS = 0
		begin
		
		if @IsOrder = 1 AND @TaskStatusCode <> 6
			begin
			UPDATE    tbTask
			SET              TaskStatusCode = @TaskStatusCode
			WHERE     (TaskCode = @ChildTaskCode) AND (TaskStatusCode < 3) AND (NOT (CashCode IS NULL))
			exec dbo.spTaskSetOpStatus @ChildTaskCode, @TaskStatusCode
			end
		else if @IsOrder = 0
			begin
			UPDATE    tbTask
			SET              TaskStatusCode = @TaskStatusCode
			WHERE     (TaskCode = @ChildTaskCode) AND (TaskStatusCode < 3) AND (CashCode IS NULL)			
			end		
		
		if (@TaskStatusCode <> 4)	
			exec dbo.spTaskSetStatus @ChildTaskCode
		fetch next from curTask into @ChildTaskCode
		end
		
	close curTask
	deallocate curTask
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskScheduleOp]
	(
	@TaskCode nvarchar(20),
	@ActionOn datetime
	)	
AS
declare @OperationNumber smallint
declare @OpStatusCode smallint
declare @CallOffOpNo smallint

declare @EndOn datetime
declare @StartOn datetime
declare @OffsetDays smallint

declare @UserId nvarchar(10)
	
	select @UserId = ActionById
	from tbTask where TaskCode = @TaskCode	
	
	set @EndOn = @ActionOn

	SELECT @CallOffOpNo = MIN(OperationNumber)
	FROM         tbTaskOp
	WHERE     (TaskCode = @TaskCode) AND (OpTypeCode = 2)	
	
	set @CallOffOpNo = isnull(@CallOffOpNo, 0)
	
	declare curOp cursor local for
		SELECT     OperationNumber, OffsetDays, OpStatusCode, EndOn
		FROM         tbTaskOp
		WHERE     (TaskCode = @TaskCode) AND ((OperationNumber <= @CallOffOpNo) OR (@CallOffOpNo = 0)) 
		ORDER BY OperationNumber DESC
	
	open curOp
	fetch next from curOp into @OperationNumber, @OffsetDays, @OpStatusCode, @ActionOn
	while @@FETCH_STATUS = 0
		begin			
		if (@OpStatusCode < 3 ) 
			begin
			set @StartOn = dbo.fnSystemAdjustToCalendar(@UserId, @EndOn, @OffsetDays)
			update tbTaskOp
			set EndOn = @EndOn, StartOn = @StartOn
			where TaskCode = @TaskCode and OperationNumber = @OperationNumber			
			end
		else
			begin			
			set @StartOn = dbo.fnSystemAdjustToCalendar(@UserId, @ActionOn, @OffsetDays)
			end
		set @EndOn = @StartOn			
		fetch next from curOp into @OperationNumber, @OffsetDays, @OpStatusCode, @ActionOn
		end
	close curOp
	deallocate curOp
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskCost] 
	(
	@ParentTaskCode nvarchar(20),
	@TotalCost money = 0 output
	)

  AS
declare @TaskCode nvarchar(20)
declare @TotalCharge money
declare @CashModeCode smallint

	declare curFlow cursor local for
		SELECT     tbTask.TaskCode, vwTaskCashMode.CashModeCode, tbTask.TotalCharge
		FROM         tbTask INNER JOIN
							  tbTaskFlow ON tbTask.TaskCode = tbTaskFlow.ChildTaskCode INNER JOIN
							  vwTaskCashMode ON tbTask.TaskCode = vwTaskCashMode.TaskCode
		WHERE     (tbTaskFlow.ParentTaskCode = @ParentTaskCode) AND (tbTask.TaskStatusCode < 5)

	open curFlow
	fetch next from curFlow into @TaskCode, @CashModeCode, @TotalCharge
	while @@FETCH_STATUS = 0
		begin
		set @TotalCost = @TotalCost + case when @CashModeCode = 1 then @TotalCharge else @TotalCharge * -1 end
		exec dbo.spTaskCost @TaskCode, @TotalCost output
		fetch next from curFlow into @TaskCode, @CashModeCode, @TotalCharge
		end
	
	close curFlow
	deallocate curFlow
	
	RETURN
GO
CREATE  PROCEDURE [dbo].[spTaskNextCode]
	(
		@ActivityCode nvarchar(50),
		@TaskCode nvarchar(20) OUTPUT
	)
  AS
declare @UserId nvarchar(10)
declare @NextTaskNumber int

		SELECT   @UserId = tbUser.UserId, @NextTaskNumber = tbUser.NextTaskNumber
		FROM         vwUserCredentials INNER JOIN
							tbUser ON vwUserCredentials.UserId = tbUser.UserId


	if exists(SELECT     tbSystemRegister.NextNumber
	          FROM         tbActivity INNER JOIN
	                                tbSystemRegister ON tbActivity.RegisterName = tbSystemRegister.RegisterName
	          WHERE     (tbActivity.ActivityCode = @ActivityCode))
		begin
		declare @RegisterName nvarchar(50)
		SELECT @RegisterName = tbSystemRegister.RegisterName, @NextTaskNumber = tbSystemRegister.NextNumber
		FROM         tbActivity INNER JOIN
	                                tbSystemRegister ON tbActivity.RegisterName = tbSystemRegister.RegisterName
	    WHERE     (tbActivity.ActivityCode = @ActivityCode)
			          
		UPDATE    tbSystemRegister
		SET              NextNumber = NextNumber + 1
		WHERE     (RegisterName = @RegisterName)	
		end
	else
		begin
		SELECT   @UserId = tbUser.UserId, @NextTaskNumber = tbUser.NextTaskNumber
		FROM         vwUserCredentials INNER JOIN
							tbUser ON vwUserCredentials.UserId = tbUser.UserId
		                      		
		update dbo.tbUser
		Set NextTaskNumber = NextTaskNumber + 1
		where UserId = @UserId
		end
		                      
	set @TaskCode = @UserId + '_' + dbo.fnPad(ltrim(str(@NextTaskNumber)), 4)
			                      
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskWorkFlow] 
	(
	@TaskCode nvarchar(20)
	)
  AS
	SELECT     tbTaskFlow.ParentTaskCode, tbTaskFlow.StepNumber, tbTask.TaskCode, tbTask.AccountCode, tbTask.ActivityCode, tbTask.TaskStatusCode, 
	                      tbTask.ActionOn, vwTaskCashMode.CashModeCode, tbTaskFlow.OffsetDays
	FROM         tbTask INNER JOIN
	                      tbTaskFlow ON tbTask.TaskCode = tbTaskFlow.ChildTaskCode LEFT OUTER JOIN
	                      vwTaskCashMode ON tbTask.TaskCode = vwTaskCashMode.TaskCode
	WHERE     (tbTaskFlow.ParentTaskCode = @TaskCode)
	ORDER BY tbTaskFlow.StepNumber, tbTaskFlow.ParentTaskCode
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskMode] 
	(
	@TaskCode nvarchar(20)
	)
  AS
	SELECT     tbTask.AccountCode, tbTask.ActivityCode, tbTask.TaskStatusCode, tbTask.ActionOn, vwTaskCashMode.CashModeCode
	FROM         tbTask LEFT OUTER JOIN
	                      vwTaskCashMode ON tbTask.TaskCode = vwTaskCashMode.TaskCode
	WHERE     (tbTask.TaskCode = @TaskCode)
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskDefaultInvoiceType]
	(
		@TaskCode nvarchar(20),
		@InvoiceTypeCode smallint OUTPUT
	)
  AS
declare @CashMode smallint

	if exists(SELECT     CashModeCode
	          FROM         vwTaskCashMode
	          WHERE     (TaskCode = @TaskCode))
		SELECT   @CashMode = CashModeCode
		FROM         vwTaskCashMode
		WHERE     (TaskCode = @TaskCode)			          
	else
		set @CashMode = 2
		
	if @CashMode = 1
		set @InvoiceTypeCode = 3
	else
		set @InvoiceTypeCode = 1
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskDefaultDocType]
	(
		@TaskCode nvarchar(20),
		@DocTypeCode smallint OUTPUT
	)
  AS
declare @CashMode smallint
declare @TaskStatus smallint

	if exists(SELECT     CashModeCode
	          FROM         vwTaskCashMode
	          WHERE     (TaskCode = @TaskCode))
		SELECT   @CashMode = CashModeCode
		FROM         vwTaskCashMode
		WHERE     (TaskCode = @TaskCode)			          
	else
		set @CashMode = 2

	SELECT  @TaskStatus =TaskStatusCode
	FROM         tbTask
	WHERE     (TaskCode = @TaskCode)		
	
	if @CashMode = 1
		set @DocTypeCode = CASE @TaskStatus WHEN 1 THEN 3 ELSE 4 END								
	else
		set @DocTypeCode = CASE @TaskStatus WHEN 1 THEN 1 ELSE 2 END 
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spSystemAdjustToCalendar]
	(
	@SourceDate datetime,
	@OffsetDays int,
	@OutputDate datetime output
	)
AS
declare @UserId nvarchar(10)

	SELECT @UserId = UserId
	FROM         vwUserCredentials	
	
	set @OutputDate = dbo.fnSystemAdjustToCalendar(@UserId, @SourceDate, @OffsetDays)

	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskDefaultTaxCode] 
	(
	@AccountCode nvarchar(10),
	@CashCode nvarchar(50),
	@TaxCode nvarchar(10) OUTPUT
	)
  AS

	set @TaxCode = dbo.fnTaskDefaultTaxCode(@AccountCode, @CashCode)
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskCopy]
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
declare @UserId nvarchar(10)

	SELECT @UserId = UserId FROM vwUserCredentials
	
	SELECT  @TaskStatusCode = tbActivity.TaskStatusCode, @ActivityCode = tbTask.ActivityCode, @Printed = CASE WHEN tbActivity.PrintOrder = 0 THEN 1 ELSE 0 END
	FROM         tbTask INNER JOIN
	                      tbActivity ON tbTask.ActivityCode = tbActivity.ActivityCode
	WHERE     (tbTask.TaskCode = @FromTaskCode)
	
	exec dbo.spTaskNextCode @ActivityCode, @ToTaskCode output

	INSERT INTO tbTask
						  (TaskCode, UserId, AccountCode, TaskTitle, ContactName, ActivityCode, TaskStatusCode, ActionById, ActionOn, ActionedOn, TaskNotes, Quantity, 
						  SecondReference, CashCode, TaxCode, UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, PaymentOn, Printed)
	SELECT     @ToTaskCode AS ToTaskCode, @UserId AS Owner, AccountCode, TaskTitle, ContactName, ActivityCode, @TaskStatusCode AS TaskStatus, 
						  @UserId AS ActionUserId, CONVERT(datetime, CONVERT(varchar, GETDATE(), 1), 1) AS ActionOn, 
						  CASE WHEN @TaskStatusCode > 2 THEN CONVERT(datetime, CONVERT(varchar, GETDATE(), 1), 1) ELSE NULL END AS ActionedOn, TaskNotes, 
						  Quantity, SecondReference, CashCode, TaxCode, UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, 
						  dbo.fnTaskDefaultPaymentOn(AccountCode, CONVERT(datetime, CONVERT(varchar, GETDATE(), 1), 1)) AS Expr1, @Printed AS Printed
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
CREATE  PROCEDURE [dbo].[spTaskConfigure] 
	(
	@ParentTaskCode nvarchar(20)
	)
   AS
declare @StepNumber smallint
declare @TaskCode nvarchar(20)
declare @UserId nvarchar(10)
declare @ActivityCode nvarchar(50)

	if exists (SELECT     ContactName
	           FROM         tbTask
	           WHERE     (TaskCode = @ParentTaskCode) AND (NOT (ContactName IS NULL)) OR
	                                 (TaskCode = @ParentTaskCode) AND (ContactName <> N''))
		begin
		if not exists(SELECT     tbOrgContact.ContactName
					  FROM         tbTask INNER JOIN
											tbOrgContact ON tbTask.AccountCode = tbOrgContact.AccountCode AND tbTask.ContactName = tbOrgContact.ContactName
					  WHERE     (tbTask.TaskCode = @ParentTaskCode))
			begin
			declare @FileAs nvarchar(100)
			declare @ContactName nvarchar(100)
			declare @NickName nvarchar(100)
			
			select @ContactName = ContactName from tbTask	 
			WHERE     (tbTask.TaskCode = @ParentTaskCode)
			
			if len(isnull(@ContactName, '')) > 0
				begin
				set @NickName = left(@ContactName, charindex(' ', @ContactName, 1))
				exec dbo.spOrgContactFileAs @ContactName, @FileAs output
				
				INSERT INTO tbOrgContact
									  (AccountCode, ContactName, FileAs, NickName)
				SELECT     AccountCode, ContactName, @FileAs AS FileAs, @NickName AS NickName
				FROM         tbTask
				WHERE     (TaskCode = @ParentTaskCode)
				end
			end                                   
		end
	
	if exists(SELECT     tbOrg.AccountCode
	          FROM         tbOrg INNER JOIN
	                                tbTask ON tbOrg.AccountCode = tbTask.AccountCode
	          WHERE     (tbTask.TaskCode = @ParentTaskCode) AND (tbOrg.OrganisationStatusCode = 1))
		begin
		UPDATE tbOrg
		SET OrganisationStatusCode = 2
		FROM         tbOrg INNER JOIN
	                                tbTask ON tbOrg.AccountCode = tbTask.AccountCode
	          WHERE     (tbTask.TaskCode = @ParentTaskCode) AND (tbOrg.OrganisationStatusCode = 1)				
		end
	          
	if exists(SELECT     TaskStatusCode
	          FROM         tbTask
	          WHERE     (TaskStatusCode = 3) AND (TaskCode = @ParentTaskCode))
		begin
		UPDATE    tbTask
		SET              ActionedOn = ActionOn
		WHERE     (TaskCode = @ParentTaskCode)
		end	

	if exists(SELECT     TaskCode
	          FROM         tbTask
	          WHERE     (TaskCode = @ParentTaskCode) AND (TaskTitle IS NULL))  
		begin
		UPDATE    tbTask
		SET      TaskTitle = ActivityCode
		WHERE     (TaskCode = @ParentTaskCode)
		end
	                 
	     	
	INSERT INTO tbTaskAttribute
						  (TaskCode, Attribute, AttributeDescription, PrintOrder, AttributeTypeCode)
	SELECT     tbTask.TaskCode, tbActivityAttribute.Attribute, tbActivityAttribute.DefaultText, tbActivityAttribute.PrintOrder, tbActivityAttribute.AttributeTypeCode
	FROM         tbActivityAttribute INNER JOIN
						  tbTask ON tbActivityAttribute.ActivityCode = tbTask.ActivityCode
	WHERE     (tbTask.TaskCode = @ParentTaskCode)
	
	INSERT INTO tbTaskOp
	                      (TaskCode, UserId, OperationNumber, OpTypeCode, Operation, Duration, OffsetDays, StartOn)
	SELECT     tbTask.TaskCode, tbTask.UserId, tbActivityOp.OperationNumber, tbActivityOp.OpTypeCode, tbActivityOp.Operation, tbActivityOp.Duration, 
	                      tbActivityOp.OffsetDays, tbTask.ActionOn
	FROM         tbActivityOp INNER JOIN
	                      tbTask ON tbActivityOp.ActivityCode = tbTask.ActivityCode
	WHERE     (tbTask.TaskCode = @ParentTaskCode)
	                   
	
	select @UserId = UserId from tbTask where tbTask.TaskCode = @ParentTaskCode
	
	declare curAct cursor local for
		SELECT     tbActivityFlow.StepNumber
		FROM         tbActivityFlow INNER JOIN
		                      tbTask ON tbActivityFlow.ParentCode = tbTask.ActivityCode
		WHERE     (tbTask.TaskCode = @ParentTaskCode)
		ORDER BY tbActivityFlow.StepNumber	
	
	open curAct
	fetch next from curAct into @StepNumber
	while @@FETCH_STATUS = 0
		begin
		SELECT  @ActivityCode = tbActivity.ActivityCode
		FROM         tbActivityFlow INNER JOIN
		                      tbActivity ON tbActivityFlow.ChildCode = tbActivity.ActivityCode INNER JOIN
		                      tbTask tbTask_1 ON tbActivityFlow.ParentCode = tbTask_1.ActivityCode
		WHERE     (tbActivityFlow.StepNumber = @StepNumber) AND (tbTask_1.TaskCode = @ParentTaskCode)
		
		exec dbo.spTaskNextCode @ActivityCode, @TaskCode output
		
		INSERT INTO tbTask
							(TaskCode, UserId, AccountCode, ContactName, ActivityCode, TaskStatusCode, ActionById, ActionOn, PaymentOn, TaskNotes, UnitCharge, 
							AddressCodeFrom, AddressCodeTo, CashCode, TaxCode, Printed, TaskTitle)
		SELECT     @TaskCode AS NewTask, tbTask_1.UserId, tbTask_1.AccountCode, tbTask_1.ContactName, tbActivity.ActivityCode, tbActivity.TaskStatusCode, 
							tbTask_1.ActionById, tbTask_1.ActionOn, dbo.fnTaskDefaultPaymentOn(tbTask_1.AccountCode, tbTask_1.ActionOn) 
							AS PaymentOn, tbActivity.DefaultText, tbActivity.UnitCharge, tbOrg.AddressCode AS AddressCodeFrom, tbOrg.AddressCode AS AddressCodeTo, 
							tbActivity.CashCode, dbo.fnTaskDefaultTaxCode(tbTask_1.AccountCode, tbActivity.CashCode) AS TaxCode, 
							CASE WHEN tbActivity.PrintOrder = 0 THEN 1 ELSE 0 END AS Printed, tbTask_1.TaskTitle
		FROM         tbActivityFlow INNER JOIN
							tbActivity ON tbActivityFlow.ChildCode = tbActivity.ActivityCode INNER JOIN
							tbTask tbTask_1 ON tbActivityFlow.ParentCode = tbTask_1.ActivityCode INNER JOIN
							tbOrg ON tbTask_1.AccountCode = tbOrg.AccountCode
		WHERE     (tbActivityFlow.StepNumber = @StepNumber) AND (tbTask_1.TaskCode = @ParentTaskCode)
		
		INSERT INTO tbTaskFlow
		                      (ParentTaskCode, StepNumber, ChildTaskCode, UsedOnQuantity, OffsetDays)
		SELECT     tbTask.TaskCode, tbActivityFlow.StepNumber, @TaskCode AS ChildTaskCode, tbActivityFlow.UsedOnQuantity, tbActivityFlow.OffsetDays
		FROM         tbActivityFlow INNER JOIN
		                      tbTask ON tbActivityFlow.ParentCode = tbTask.ActivityCode
		WHERE     (tbTask.TaskCode = @ParentTaskCode) AND (tbActivityFlow.StepNumber = @StepNumber)
		
		exec dbo.spTaskConfigure @TaskCode
		fetch next from curAct into @StepNumber
		end
	
	close curAct
	deallocate curAct


	RETURN
GO
CREATE PROCEDURE [dbo].[spCashCopyLiveToForecastCategory]
	(
	@CategoryCode nvarchar(10),
	@Years smallint,
	@UseLastPeriod bit = 0
	)

   AS	
declare @CashCode nvarchar(50)

	declare curCc cursor for
	SELECT     CashCode
	FROM         tbCashCode
	WHERE     (CategoryCode = @CategoryCode)
		
	open curCc

	fetch next from curCc into @CashCode
	while @@FETCH_STATUS = 0
		begin
		exec dbo.spCashCopyLiveToForecastCashCode @CashCode, @Years, @UseLastPeriod
		fetch next from curCc into @CashCode
		end
	
	close curCc
		
	deallocate curCc
			
	return
GO
CREATE PROCEDURE [dbo].[spStatementRescheduleOverdue]
 AS
	UPDATE tbTask
	SET tbTask.PaymentOn = dbo.fnTaskDefaultPaymentOn(tbTask.AccountCode, getdate()) 
	FROM         tbTask INNER JOIN
                      tbCashCode ON tbTask.CashCode = tbCashCode.CashCode
	WHERE     (tbTask.PaymentOn < GETDATE()) AND (tbTask.TaskStatusCode = 3)
	

	UPDATE tbTask
	SET tbTask.PaymentOn = dbo.fnTaskDefaultPaymentOn(tbTask.AccountCode, getdate()) 
	FROM         tbTask INNER JOIN
                      tbCashCode ON tbTask.CashCode = tbCashCode.CashCode
	WHERE     (tbTask.PaymentOn < GETDATE()) AND (tbTask.TaskStatusCode < 3)
	
	UPDATE tbInvoice
	SET CollectOn = dbo.fnTaskDefaultPaymentOn(tbInvoice.AccountCode, getdate()) 
	FROM         tbInvoice 
	WHERE     (tbInvoice.InvoiceStatusCode = 2 OR
	                      tbInvoice.InvoiceStatusCode = 3) AND (tbInvoice.CollectOn < GETDATE())
	
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spOrgRebuild]
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
	set TaxValue = ROUND(tbInvoiceItem.InvoiceValue * vwSystemTaxRates.TaxRate, 2),
		PaidValue = tbInvoiceItem.InvoiceValue, 
		PaidTaxValue = ROUND(tbInvoiceItem.InvoiceValue * vwSystemTaxRates.TaxRate, 2)				
	FROM         tbInvoiceItem INNER JOIN
	                      vwSystemTaxRates ON tbInvoiceItem.TaxCode = vwSystemTaxRates.TaxCode INNER JOIN
	                      tbInvoice ON tbInvoiceItem.InvoiceNumber = tbInvoice.InvoiceNumber
	WHERE     (tbInvoice.AccountCode = @AccountCode) AND (tbInvoice.InvoiceStatusCode <> 1)	
                      
	update tbInvoiceTask
	set TaxValue = ROUND(tbInvoiceTask.InvoiceValue * vwSystemTaxRates.TaxRate, 2),
		PaidValue = tbInvoiceTask.InvoiceValue, PaidTaxValue = ROUND(tbInvoiceTask.InvoiceValue * vwSystemTaxRates.TaxRate, 2)
	FROM         tbInvoiceTask INNER JOIN
	                      vwSystemTaxRates ON tbInvoiceTask.TaxCode = vwSystemTaxRates.TaxCode INNER JOIN
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
	                      vwSystemTaxRates ON tbOrgPayment.TaxCode = vwSystemTaxRates.TaxCode
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
		ORDER BY CollectOn DESC
	

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
			
		if isnull(@TaskCode, '''''''') = ''''''''
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
CREATE PROCEDURE [dbo].[spTaskProfitTopLevel]
	(
	@TaskCode nvarchar(20),
	@InvoicedCharge money = 0 output,
	@InvoicedChargePaid money = 0 output,
	@TotalCost money = 0 output,
	@InvoicedCost money = 0 output,
	@InvoicedCostPaid money = 0 output
	)
AS
			
	SELECT  @InvoicedCharge = SUM(CASE WHEN tbInvoiceType.CashModeCode = 1 THEN tbInvoiceTask.InvoiceValue * - 1 ELSE tbInvoiceTask.InvoiceValue END), 
	@InvoicedChargePaid = SUM(CASE WHEN tbInvoiceType.CashModeCode = 1 THEN tbInvoiceTask.PaidValue * - 1 ELSE tbInvoiceTask.PaidValue END) 	                      
	FROM         tbInvoiceTask INNER JOIN
	                      tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber INNER JOIN
	                      tbInvoiceType ON tbInvoice.InvoiceTypeCode = tbInvoiceType.InvoiceTypeCode
	WHERE     (tbInvoiceTask.TaskCode = @TaskCode)
	
	set @TotalCost = 0
	exec dbo.spTaskProfit @TaskCode, @TotalCost output, @InvoicedCost output, @InvoicedCostPaid output	
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spInvoiceCredit]
	(
		@InvoiceNumber nvarchar(20) output
	)
  AS
declare @InvoiceTypeCode smallint
declare @CreditNumber nvarchar(20)
declare @UserId nvarchar(10)
declare @NextNumber int
declare @InvoiceSuffix nvarchar(4)

	select @UserId = UserId from vwUserCredentials
	
	select @InvoiceTypeCode = InvoiceTypeCode from tbInvoice where InvoiceNumber = @InvoiceNumber
	
	set @InvoiceTypeCode = case @InvoiceTypeCode when 1 then 2 when 3 then 4 else 4 end
	
	select @UserId = UserId from vwUserCredentials

	set @InvoiceSuffix = '.' + @UserId
	
	select @NextNumber = NextNumber
	from tbInvoiceType
	where InvoiceTypeCode = @InvoiceTypeCode
	
	select @CreditNumber = dbo.fnPad(@NextNumber, 6) + @InvoiceSuffix
	
	while exists (SELECT     InvoiceNumber
	              FROM         tbInvoice
	              WHERE     (InvoiceNumber = @CreditNumber))
		begin
		set @NextNumber = @NextNumber + 1
		set @CreditNumber = dbo.fnPad(@NextNumber, 6) + @InvoiceSuffix
		end
		
	begin tran Credit
	
	exec dbo.spInvoiceCancel
	
	UPDATE    tbInvoiceType
	SET              NextNumber = @NextNumber + 1
	WHERE     (InvoiceTypeCode = @InvoiceTypeCode)	
	
	INSERT INTO tbInvoice
						(InvoiceNumber, InvoiceStatusCode, AccountCode, InvoiceValue, TaxValue, UserId, InvoiceTypeCode, InvoicedOn)
	SELECT     @CreditNumber AS InvoiceNumber, 1 AS InvoiceStatusCode, AccountCode, InvoiceValue, TaxValue, @UserId AS UserId, 
						@InvoiceTypeCode AS InvoiceTypeCode, GETDATE() AS InvoicedOn
	FROM         tbInvoice
	WHERE     (InvoiceNumber = @InvoiceNumber)
	
	INSERT INTO tbInvoiceItem
	                      (InvoiceNumber, CashCode, TaxCode, InvoiceValue, TaxValue)
	SELECT     @CreditNumber AS InvoiceNumber, CashCode, TaxCode, InvoiceValue, TaxValue
	FROM         tbInvoiceItem
	WHERE     (InvoiceNumber = @InvoiceNumber)
	
	INSERT INTO tbInvoiceTask
	                      (InvoiceNumber, TaskCode, Quantity, InvoiceValue, TaxValue, CashCode, TaxCode)
	SELECT     @CreditNumber AS InvoiceNumber, TaskCode, Quantity, InvoiceValue, TaxValue, CashCode, TaxCode
	FROM         tbInvoiceTask
	WHERE     (InvoiceNumber = @InvoiceNumber)

	set @InvoiceNumber = @CreditNumber
	
	commit tran Credit

	
	RETURN
GO
CREATE PROCEDURE [dbo].[spInvoiceRaiseBlank]
	(
	@AccountCode nvarchar(10),
	@InvoiceTypeCode smallint,
	@InvoiceNumber nvarchar(20) = null output
	)
  AS
declare @UserId nvarchar(10)
declare @NextNumber int
declare @InvoiceSuffix nvarchar(4)

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
		
	begin tran InvoiceBlank
	
	exec dbo.spInvoiceCancel
	
	UPDATE    tbInvoiceType
	SET              NextNumber = @NextNumber + 1
	WHERE     (InvoiceTypeCode = @InvoiceTypeCode)
	
	INSERT INTO tbInvoice
	                      (InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoicedOn, InvoiceStatusCode)
	VALUES     (@InvoiceNumber, @UserId, @AccountCode, @InvoiceTypeCode, GETDATE(), 1)

	
	commit tran InvoiceBlank
	
	RETURN
GO
CREATE  PROCEDURE [dbo].[spInvoiceRaise]
	(
	@TaskCode nvarchar(20),
	@InvoiceTypeCode smallint,
	@InvoicedOn datetime,
	@InvoiceNumber nvarchar(20) = null output
	)
AS
declare @UserId nvarchar(10)
declare @NextNumber int
declare @InvoiceSuffix nvarchar(4)
declare @PaymentDays smallint
declare @CollectOn datetime
declare @AccountCode nvarchar(10)

	set @InvoicedOn = isnull(@InvoicedOn, getdate())
	
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

	SELECT @PaymentDays = tbOrg.PaymentDays, @AccountCode = tbOrg.AccountCode
	FROM         tbTask INNER JOIN
	                      tbOrg ON tbTask.AccountCode = tbOrg.AccountCode
	WHERE     (tbTask.TaskCode = @TaskCode)		
	
	set @CollectOn = dbo.fnTaskDefaultPaymentOn(@AccountCode, @InvoicedOn)
	
	begin tran Invoice
	
	exec dbo.spInvoiceCancel
	
	UPDATE    tbInvoiceType
	SET              NextNumber = @NextNumber + 1
	WHERE     (InvoiceTypeCode = @InvoiceTypeCode)
	
	INSERT INTO tbInvoice
						(InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoicedOn, CollectOn, InvoiceStatusCode, PaymentTerms)
	SELECT     @InvoiceNumber AS InvoiceNumber, @UserId AS UserId, tbTask.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, @InvoicedOn AS InvoicedOn, 
						@CollectOn AS CollectOn, 1 AS InvoiceStatusCode, 
						tbOrg.PaymentTerms
	FROM         tbTask INNER JOIN
						tbOrg ON tbTask.AccountCode = tbOrg.AccountCode
	WHERE     (tbTask.TaskCode = @TaskCode)

	exec dbo.spInvoiceAddTask @InvoiceNumber, @TaskCode
	
	UPDATE    tbTask
	SET              ActionedOn = GETDATE()
	WHERE     (TaskCode = @TaskCode) AND (ActionedOn IS NULL)

	commit tran Invoice
	
	RETURN
GO
CREATE  PROCEDURE [dbo].[spTaskSchedule]
	(
	@ParentTaskCode nvarchar(20),
	@ActionOn datetime = null output
	)
   AS
declare @UserId nvarchar(10)
declare @AccountCode nvarchar(10)
declare @StepNumber smallint
declare @TaskCode nvarchar(20)
declare @OffsetDays smallint
declare @UsedOnQuantity float
declare @Quantity float
declare @PaymentDays smallint
declare @PaymentOn datetime

	if @ActionOn is null
		begin				
		select @ActionOn = ActionOn, @UserId = ActionById 
		from tbTask where TaskCode = @ParentTaskCode
		
		if @ActionOn != dbo.fnSystemAdjustToCalendar(@UserId, @ActionOn, 0)
			begin
			set @ActionOn = dbo.fnSystemAdjustToCalendar(@UserId, @ActionOn, 0)
			update tbTask
			set ActionOn = @ActionOn
			where TaskCode = @ParentTaskCode and TaskStatusCode < 3			
			end
		end
	
	SELECT @PaymentDays = tbOrg.PaymentDays, @PaymentOn = tbTask.PaymentOn, @AccountCode = tbTask.AccountCode
	FROM         tbOrg INNER JOIN
	                      tbTask ON tbOrg.AccountCode = tbTask.AccountCode
	WHERE     (tbTask.TaskCode = @ParentTaskCode)
	
	if (@PaymentOn != dbo.fnTaskDefaultPaymentOn(@AccountCode, @ActionOn))
		begin
		update tbTask
		set PaymentOn = dbo.fnTaskDefaultPaymentOn(AccountCode, ActionOn)
		where TaskCode = @ParentTaskCode and TaskStatusCode < 3
		end
	
	if exists(SELECT TOP 1 OperationNumber
	          FROM         tbTaskOp
	          WHERE     (TaskCode = @ParentTaskCode))
		begin
		exec dbo.spTaskScheduleOp @ParentTaskCode, @ActionOn
		end
	
	Select @Quantity = Quantity from tbTask where TaskCode = @ParentTaskCode
	
	declare curAct cursor local for
		SELECT     tbTaskFlow.StepNumber, tbTaskFlow.ChildTaskCode, tbTask.AccountCode, tbTask.ActionById, tbTaskFlow.OffsetDays, tbTaskFlow.UsedOnQuantity, 
		                      tbOrg.PaymentDays
		FROM         tbTaskFlow INNER JOIN
		                      tbTask ON tbTaskFlow.ChildTaskCode = tbTask.TaskCode INNER JOIN
		                      tbOrg ON tbTask.AccountCode = tbOrg.AccountCode
		WHERE     (tbTaskFlow.ParentTaskCode = @ParentTaskCode)
		ORDER BY tbTaskFlow.StepNumber DESC
	
	open curAct
	fetch next from curAct into @StepNumber, @TaskCode, @AccountCode, @UserId, @OffsetDays, @UsedOnQuantity, @PaymentDays
	while @@FETCH_STATUS = 0
		begin
		set @ActionOn = dbo.fnSystemAdjustToCalendar(@UserId, @ActionOn, @OffsetDays)
		set @PaymentOn = dbo.fnTaskDefaultPaymentOn(@AccountCode, @ActionOn)
		
		update tbTask
		set ActionOn = @ActionOn, 
			PaymentOn = @PaymentOn,
			Quantity = @Quantity * @UsedOnQuantity,
			TotalCharge = case when @UsedOnQuantity = 0 then UnitCharge else UnitCharge * @Quantity * @UsedOnQuantity end,
			UpdatedOn = getdate(),
			UpdatedBy = (suser_sname())
		where TaskCode = @TaskCode and TaskStatusCode < 3
		
		exec dbo.spTaskSchedule @TaskCode, @ActionOn output
		fetch next from curAct into @StepNumber, @TaskCode, @AccountCode, @UserId, @OffsetDays, @UsedOnQuantity, @PaymentDays
		end
	
	close curAct
	deallocate curAct	
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spPaymentMove]
	(
	@PaymentCode nvarchar(20),
	@CashAccountCode nvarchar(10)
	)
  AS
declare @OldAccountCode nvarchar(10)

	SELECT @OldAccountCode = CashAccountCode
	FROM         tbOrgPayment
	WHERE     (PaymentCode = @PaymentCode)
	
	begin tran
	
	update tbOrgPayment 
	set CashAccountCode = @CashAccountCode,
		UpdatedOn = getdate(),
		UpdatedBy = (suser_sname())
	where PaymentCode = @PaymentCode	

	exec spCashAccountRebuild @CashAccountCode
	exec spCashAccountRebuild @OldAccountCode
	
	commit tran
	
	RETURN
GO
CREATE  PROCEDURE [dbo].[spSystemPeriodTransferAll]
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
CREATE PROCEDURE [dbo].[spSystemPeriodClose]
   AS

	if exists(select * from dbo.fnSystemActivePeriod())
		begin
		declare @StartOn datetime
		declare @YearNumber smallint
		
		select @StartOn = StartOn, @YearNumber = YearNumber
		from fnSystemActivePeriod() fnSystemActivePeriod
		 		
		begin tran
		
		exec dbo.spCashGeneratePeriods
		exec dbo.spSystemPeriodTransfer @StartOn
		
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
CREATE PROCEDURE [dbo].[spTaskDefaultPaymentOn]
	(
		@AccountCode nvarchar(10),
		@ActionOn datetime,
		@PaymentOn datetime output
	)
  AS
		
	SET @PaymentOn = dbo.fnTaskDefaultPaymentOn(@AccountCode, @ActionOn)
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spCashVatBalance]
	(
	@Balance money output
	)
  AS
	set @Balance = dbo.fnSystemVatBalance()
	RETURN
GO
CREATE PROCEDURE [dbo].[spCashCodeValues]
	(
	@CashCode nvarchar(50),
	@YearNumber smallint
	)
    AS
	SELECT     vwCashFlowData.CashValue, vwCashFlowData.CashTax, vwCashFlowData.InvoiceValue, vwCashFlowData.InvoiceTax, 
	                      vwCashFlowData.ForecastValue, vwCashFlowData.ForecastTax
	FROM         tbSystemYearPeriod INNER JOIN
	                      vwCashFlowData ON tbSystemYearPeriod.StartOn = vwCashFlowData.StartOn
	WHERE     (tbSystemYearPeriod.YearNumber = @YearNumber) AND (vwCashFlowData.CashCode = @CashCode)
	ORDER BY vwCashFlowData.StartOn
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spPaymentDelete]
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
CREATE PROCEDURE [dbo].[spSystemPeriodTransfer]
	(
		@StartOn datetime
	)
  AS
	
	UPDATE tbCashPeriod
	SET InvoiceValue = vwCashCodeInvoiceSummary.InvoiceValue, 
		InvoiceTax = vwCashCodeInvoiceSummary.TaxValue
	FROM         tbCashPeriod INNER JOIN
	                      vwCashCodeInvoiceSummary ON tbCashPeriod.CashCode = vwCashCodeInvoiceSummary.CashCode AND tbCashPeriod.StartOn = vwCashCodeInvoiceSummary.StartOn	
	WHERE tbCashPeriod.StartOn = @StartOn
	
	UPDATE tbCashPeriod
	SET CashValue = vwCashCodePaymentSummary.CashValue, 
		CashTax = vwCashCodePaymentSummary.CashTax
	FROM         tbCashPeriod INNER JOIN
	                      vwCashCodePaymentSummary ON tbCashPeriod.CashCode = vwCashCodePaymentSummary.CashCode AND 
	                      tbCashPeriod.StartOn = vwCashCodePaymentSummary.StartOn
	WHERE tbCashPeriod.StartOn = @StartOn	                      

	UPDATE tbCashPeriod
	SET CashValue = vwCashAccountPeriodClosingBalance.ClosingBalance
	FROM         vwCashAccountPeriodClosingBalance INNER JOIN
	                      tbCashPeriod ON vwCashAccountPeriodClosingBalance.CashCode = tbCashPeriod.CashCode AND 
	                      vwCashAccountPeriodClosingBalance.StartOn = tbCashPeriod.StartOn
	WHERE     (tbCashPeriod.StartOn = @StartOn)
	
	RETURN
GO
CREATE  PROCEDURE [dbo].[spCashFlowInitialise]
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
