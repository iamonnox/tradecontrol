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
CREATE FUNCTION [dbo].[fnTaskProfitCost]
	(
	@ParentTaskCode nvarchar(20),
	@TotalCost money,
	@InvoicedCost money,
	@InvoicedCostPaid money
	)
RETURNS @tbCost TABLE (	
	TotalCost money,
	InvoicedCost money,
	InvoicedCostPaid money
	)
AS
	BEGIN
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
		WHERE     (tbTaskFlow.ParentTaskCode = @ParentTaskCode)  AND (tbTask.TaskStatusCode < 5)	

	open curFlow
	fetch next from curFlow into @TaskCode, @CashModeCode, @TotalCharge
	while @@FETCH_STATUS = 0
		begin
		
		SELECT  @TotalInvoiced = SUM(CASE WHEN tbInvoiceType.CashModeCode = 1 THEN tbInvoiceTask.InvoiceValue ELSE tbInvoiceTask.InvoiceValue * - 1 END), 
				@TotalPaid = SUM(CASE WHEN tbInvoiceType.CashModeCode = 1 THEN tbInvoiceTask.PaidValue ELSE tbInvoiceTask.PaidValue * - 1 END) 	                      
		FROM         tbInvoiceTask INNER JOIN
							  tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber INNER JOIN
							  tbInvoiceType ON tbInvoice.InvoiceTypeCode = tbInvoiceType.InvoiceTypeCode
		WHERE     (tbInvoiceTask.TaskCode = @TaskCode)

		set @InvoicedCost = @InvoicedCost + isnull(@TotalInvoiced, 0)
		set @InvoicedCostPaid = @InvoicedCostPaid + isnull(@TotalPaid, 0)
		set @TotalCost = @TotalCost + case when @CashModeCode = 1 then @TotalCharge else @TotalCharge * -1 end
		
		SELECT @TotalCost = TotalCost, 
			@InvoicedCost = InvoicedCost, 
			@InvoicedCostPaid = InvoicedCostPaid
		FROM         dbo.fnTaskProfitCost(@TaskCode, @TotalCost, @InvoicedCost, @InvoicedCostPaid) AS fnTaskProfitCost_1	
		
		fetch next from curFlow into @TaskCode, @CashModeCode, @TotalCharge
		end
	
	close curFlow
	deallocate curFlow

	insert into @tbCost (TotalCost, InvoicedCost, InvoicedCostPaid)
	values (@TotalCost, @InvoicedCost, @InvoicedCostPaid)		
	
	
	RETURN
	END
GO
CREATE FUNCTION [dbo].[fnTaskProfitOrder]
	(
	@TaskCode nvarchar(20)
	)
RETURNS @tbOrder TABLE (	
	InvoicedCharge money,
	InvoicedChargePaid money,
	TotalCost money,
	InvoicedCost money,
	InvoicedCostPaid money
	)
AS
	BEGIN
declare @InvoicedCharge money
declare @InvoicedChargePaid money
declare @TotalCost money
declare @InvoicedCost money
declare @InvoicedCostPaid money

	SELECT  @InvoicedCharge = SUM(CASE WHEN tbInvoiceType.CashModeCode = 1 THEN tbInvoiceTask.InvoiceValue * - 1 ELSE tbInvoiceTask.InvoiceValue END), 
	@InvoicedChargePaid = SUM(CASE WHEN tbInvoiceType.CashModeCode = 1 THEN tbInvoiceTask.PaidValue * - 1 ELSE tbInvoiceTask.PaidValue END) 	                      
	FROM         tbInvoiceTask INNER JOIN
	                      tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber INNER JOIN
	                      tbInvoiceType ON tbInvoice.InvoiceTypeCode = tbInvoiceType.InvoiceTypeCode
	WHERE     (tbInvoiceTask.TaskCode = @TaskCode)
	
	SELECT TOP 1 @TotalCost = TotalCost, @InvoicedCost = InvoicedCost, @InvoicedCostPaid = InvoicedCostPaid
	FROM         dbo.fnTaskProfitCost(@TaskCode, 0, 0, 0) AS fnTaskProfitCost_1
	
	insert into @tbOrder (InvoicedCharge, InvoicedChargePaid, TotalCost, InvoicedCost, InvoicedCostPaid)
		values (isnull(@InvoicedCharge, 0), isnull(@InvoicedChargePaid, 0), @TotalCost, @InvoicedCost, @InvoicedCostPaid)
	
	RETURN
	END
GO
CREATE FUNCTION [dbo].[fnTaskProfit]()
RETURNS @tbTaskProfit TABLE (
	TaskCode nvarchar(20),
	StartOn datetime,
	TotalCharge money,
	InvoicedCharge money,
	InvoicedChargePaid money,
	TotalCost money,
	InvoicedCost money,
	InvoicedCostPaid money
	) 
AS
	BEGIN
declare @StartOn datetime
declare @TaskCode nvarchar(20)
declare @TotalCharge money
declare @InvoicedCharge money
declare @InvoicedChargePaid money
declare @TotalCost money
declare @InvoicedCost money
declare @InvoicedCostPaid money


	declare curTasks cursor local for
		SELECT     StartOn, TaskCode, TotalCharge
		FROM         vwTaskProfitOrders
		ORDER BY StartOn

	open curTasks
	fetch next from curTasks into @StartOn, @TaskCode, @TotalCharge
	
	while (@@FETCH_STATUS = 0)
		begin
		set @InvoicedCharge = 0
		set @InvoicedChargePaid = 0
		set @TotalCost = 0
		set @InvoicedCost = 0
		set @InvoicedCostPaid = 0
				
		SELECT   @InvoicedCharge = InvoicedCharge, 
			@InvoicedChargePaid = InvoicedChargePaid, 
			@TotalCost = TotalCost, 
			@InvoicedCost = InvoicedCost, 
			@InvoicedCostPaid = InvoicedCostPaid
		FROM   dbo.fnTaskProfitOrder(@TaskCode) AS fnTaskProfitOrder_1
		
		insert into @tbTaskProfit (TaskCode, StartOn, TotalCharge, InvoicedCharge, InvoicedChargePaid, TotalCost, InvoicedCost, InvoicedCostPaid)
		values (@TaskCode, @StartOn, @TotalCharge, @InvoicedCharge, @InvoicedChargePaid, @TotalCost, @InvoicedCost, @InvoicedCostPaid)
		
		fetch next from curTasks into @StartOn, @TaskCode, @TotalCharge	
		end
	
	close curTasks
	deallocate curTasks
		
	RETURN
	END
GO
CREATE  FUNCTION [dbo].[fnTaxTypeDueDates]
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
CREATE  FUNCTION [dbo].[fnSystemCashCode]
	(
	@TaxTypeCode smallint
	)
RETURNS nvarchar(50)
  AS
	BEGIN
	declare @CashCode nvarchar(50)
	
	SELECT @CashCode = CashCode
	FROM         tbCashTaxType
	WHERE     (TaxTypeCode = @TaxTypeCode)
		
	
	RETURN @CashCode
	END
GO
CREATE FUNCTION [dbo].[fnTaxCorpTotals]
()
RETURNS @tbCorp TABLE 
	(
	StartOn datetime, 
	NetProfit money,
	CorporationTax money
	)
 AS
	BEGIN
	declare @PayOn datetime
	declare @PayFrom datetime
	declare @PayTo datetime
	
	declare curVat cursor local for
		SELECT     PayOn, PayFrom, PayTo
		FROM         fnTaxTypeDueDates(1) fnTaxTypeDueDates
		
	open curVat
	fetch next from curVat into @PayOn, @PayFrom, @PayTo
	while (@@FETCH_STATUS = 0)
		begin
		INSERT INTO @tbCorp (StartOn, NetProfit, CorporationTax)
		SELECT     @PayOn AS PayOn, ISNULL(SUM(NetProfit), 0) AS NetProfit, ISNULL(SUM(CorporationTax), 0) AS CorporationTax
		FROM         vwCorpTaxInvoice
		WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
		
		fetch next from curVat into @PayOn, @PayFrom, @PayTo
		end
	
	close curVat
	deallocate curVat

	
	RETURN
	END
GO
CREATE FUNCTION [dbo].[fnPad]
	(
		@Source nvarchar(25),
		@Length smallint
	)
RETURNS nvarchar(25)
   AS
	BEGIN
	declare @i smallint
	declare @Pad smallint
	declare @Target nvarchar(25)
	
	set @Target = RTRIM(LTRIM(@Source))	
	set @Pad = @Length - LEN(@Target)
	set @i = 0
	
	while @i < @Pad
		begin
		set @Target = '0' + @Target
		set @i = @i + 1
		end
	
	RETURN @Target
	END
GO
CREATE FUNCTION [dbo].[fnSystemAdjustDateToBucket]
	(
	@BucketDay smallint,
	@CurrentDate datetime
	)
RETURNS datetime
  AS
	BEGIN
	declare @CurrentDay smallint
	declare @Offset smallint
	declare @AdjustedDay smallint
	
	set @CurrentDay = datepart(dw, @CurrentDate)
	
	set @AdjustedDay = case when @CurrentDay > (7 - @@DATEFIRST + 1) then
				@CurrentDay - (7 - @@DATEFIRST + 1)
			else
				@CurrentDay + (@@DATEFIRST - 1)
			end

	set @Offset = case when @BucketDay <= @AdjustedDay then
				@BucketDay - @AdjustedDay
			else
				(7 - (@BucketDay - @AdjustedDay)) * -1
			end
	
		
	RETURN dateadd(dd, @Offset, @CurrentDate)
	END
GO
CREATE FUNCTION [dbo].[fnCashCompanyBalance]
	()
RETURNS money
  AS
	BEGIN
	declare @CurrentBalance money
	
	SELECT  @CurrentBalance = SUM(tbOrgAccount.CurrentBalance)
	FROM         tbOrgAccount INNER JOIN
	                      tbCashCode ON tbOrgAccount.CashCode = tbCashCode.CashCode
	WHERE     (tbOrgAccount.AccountClosed = 0)
	
	RETURN isnull(@CurrentBalance, 0)
	END
GO
CREATE FUNCTION [dbo].[fnCashReserveBalance]
	()
RETURNS money
AS
	BEGIN
	declare @CurrentBalance money
	
	SELECT    @CurrentBalance = SUM(tbOrgAccount.CurrentBalance)
	FROM         tbOrgAccount LEFT OUTER JOIN
	                      tbCashCode ON tbOrgAccount.CashCode = tbCashCode.CashCode
	WHERE     (tbOrgAccount.AccountClosed = 0) AND (tbCashCode.CashCode IS NULL)
	
	RETURN isnull(@CurrentBalance, 0)
	END
GO
CREATE FUNCTION [dbo].[fnTaskIsExpense]
	(
	@TaskCode nvarchar(20)
	)
RETURNS bit
AS
	BEGIN
	DECLARE @IsExpense bit
	IF EXISTS (SELECT     tbTask.TaskCode
	           FROM         tbTask INNER JOIN
	                                 tbCashCode ON tbTask.CashCode = tbCashCode.CashCode INNER JOIN
	                                 tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	           WHERE     (tbCashCategory.CashModeCode = 2) AND (tbTask.TaskCode = @TaskCode))
		SET @IsExpense = 0			          
	ELSE IF EXISTS(SELECT     ParentTaskCode
	          FROM         tbTaskFlow
	          WHERE     (ChildTaskCode = @TaskCode))
		BEGIN
		DECLARE @ParentTaskCode nvarchar(20)
		SELECT  @ParentTaskCode = ParentTaskCode
		FROM         tbTaskFlow
		WHERE     (ChildTaskCode = @TaskCode)		
		SET @IsExpense = dbo.fnTaskIsExpense(@ParentTaskCode)		
		END	              
	ELSE
		SET @IsExpense = 1
			
	RETURN @IsExpense
	END
GO
CREATE FUNCTION [dbo].[fnTaskEmailAddress]
	(
	@TaskCode nvarchar(20)
	)
RETURNS nvarchar(255)
AS
	BEGIN
	declare @EmailAddress nvarchar(255)

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
	
	RETURN @EmailAddress
	END
GO
CREATE FUNCTION [dbo].[fnSystemProfileText]
	(
	@TextId int
	)
RETURNS nvarchar(255)
  AS
	BEGIN
	declare @Message nvarchar(255)
	select top 1 @Message = Message from tbProfileText
	where TextId = @TextId
	RETURN @Message
	END
GO
CREATE FUNCTION [dbo].[fnCashAccountStatement]
	(
		@CashAccountCode nvarchar(10)
	)
RETURNS @tbCash TABLE (EntryNumber int, PaymentCode nvarchar(20), PaidOn datetime, PaidBalance money, TaxedBalance money)
  AS
	BEGIN
	declare @EntryNumber int
	declare @PaymentCode nvarchar(20)
	declare @PaidOn datetime
	declare @Paid money
	declare @Taxed money
	declare @PaidBalance money
	declare @TaxedBalance money
		
	SELECT   @PaidBalance = OpeningBalance
	FROM         tbOrgAccount
	WHERE     (CashAccountCode = @CashAccountCode)

	SELECT    @PaidOn = MIN(PaidOn) 
	FROM         tbOrgPayment
	WHERE     (CashAccountCode = @CashAccountCode)
	
	set @EntryNumber = 1
		
	insert into @tbCash (EntryNumber, PaymentCode, PaidOn, PaidBalance, TaxedBalance)
	values (@EntryNumber, dbo.fnSystemProfileText(3005), dateadd(d, -1, @PaidOn), @PaidBalance, 0) 

	set @EntryNumber = @EntryNumber + 1
	set @TaxedBalance = 0
	
	declare curCash cursor local for
		SELECT     PaymentCode, PaidOn, CASE WHEN PaidInValue > 0 THEN PaidInValue ELSE PaidOutValue * - 1 END AS Paid, 
		                      TaxOutValue - TaxInValue AS Taxed
		FROM         tbOrgPayment
		WHERE     (PaymentStatusCode = 2) AND (CashAccountCode = @CashAccountCode)
		ORDER BY PaidOn

	open curCash
	fetch next from curCash into @PaymentCode, @PaidOn, @Paid, @Taxed
	while @@FETCH_STATUS = 0
		begin	
		set @PaidBalance = @PaidBalance + @Paid
		set @TaxedBalance = @TaxedBalance + @Taxed
		insert into @tbCash (EntryNumber, PaymentCode, PaidOn, PaidBalance, TaxedBalance)
		values (@EntryNumber, @PaymentCode, @PaidOn, @PaidBalance, @TaxedBalance) 
		
		set @EntryNumber = @EntryNumber + 1
		fetch next from curCash into @PaymentCode, @PaidOn, @Paid, @Taxed
		end
	
	close curCash
	deallocate curCash
		
	RETURN
	END
GO
/****** Object:  UserDefinedFunction [dbo].[fnTaxVatTotals]    Script Date: 01/11/2012 16:40:04 ******/
GO
CREATE FUNCTION [dbo].[fnTaxVatTotals]
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
CREATE FUNCTION [dbo].[fnTaxVatStatement]
	()
RETURNS @tbVat TABLE 
	(
	StartOn datetime, 
	VatDue money ,
	VatPaid money ,
	Balance money
	)
  AS
	BEGIN
	declare @Balance money
	declare @StartOn datetime
	declare @VatDue money
	declare @VatPaid money
	
	INSERT INTO @tbVat (StartOn, VatDue, VatPaid, Balance)
	SELECT     StartOn, VatDue, 0 As VatPaid, 0 AS Balance
	FROM         fnTaxVatTotals() fnTaxVatTotals	
	
	INSERT INTO @tbVat (StartOn, VatDue, VatPaid, Balance)
	SELECT     tbOrgPayment.PaidOn, 0 As VatDue, (tbOrgPayment.PaidOutValue * -1) + tbOrgPayment.PaidInValue AS VatPaid, 0 As Balance
	FROM         tbOrgPayment INNER JOIN
	                      vwSystemVatCashCode ON tbOrgPayment.CashCode = vwSystemVatCashCode.CashCode	                      

	set @Balance = 0
	
	DECLARE curVS CURSOR LOCAL FOR
		SELECT StartOn, VatDue, VatPaid
		FROM @tbVat
		ORDER BY StartOn, VatDue
	
	OPEN curVS
	FETCH NEXT FROM curVS INTO @StartOn, @VatDue, @VatPaid
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		set @Balance = @Balance + @VatDue + @VatPaid
		UPDATE @tbVat
		SET Balance = @Balance
		WHERE StartOn = @StartOn AND VatDue = @VatDue 
		FETCH NEXT FROM curVS INTO @StartOn, @VatDue, @VatPaid
		END
	
	CLOSE curVS
	DEALLOCATE curVS	
	RETURN
	END
GO
CREATE FUNCTION [dbo].[fnOrgIndustrySectors]
	(
	@AccountCode nvarchar(10)
	)
RETURNS nvarchar(256)
  AS
	BEGIN
	declare @IndustrySector nvarchar(256)
	
	if exists(select IndustrySector from tbOrgSector where AccountCode = @AccountCode)
		begin
		declare @Sector nvarchar(50)
		set @IndustrySector = ''
		declare cur cursor local for
			select IndustrySector from tbOrgSector where AccountCode = @AccountCode
		open cur
		fetch next from cur into @Sector
		while @@FETCH_STATUS = 0
			begin
			if len(@IndustrySector) = 0
				set @IndustrySector = @Sector
			else if len(@IndustrySector) <= 200
				set @IndustrySector = @IndustrySector + ', ' + @Sector
			
			fetch next from cur into @Sector
			end
			
		close cur
		deallocate cur
		
		end	
	
	RETURN @IndustrySector
	END
GO
CREATE FUNCTION [dbo].[fnSystemBuckets]
	(@CurrentDate datetime)
RETURNS  @tbBkn TABLE (Period smallint, StartDate datetime, EndDate datetime)
  AS
	BEGIN
	declare @BucketTypeCode smallint
	declare @UnitOfTimeCode smallint
	declare @Period smallint	
	declare @CurrentPeriod smallint
	declare @Offset smallint
	
	declare @StartDate datetime
	declare @EndDate datetime
	
		
	SELECT     TOP 1 @BucketTypeCode = BucketTypeCode, @UnitOfTimeCode = BucketIntervalCode
	FROM         tbSystemOptions
		
	set @EndDate = 
		case @BucketTypeCode
			when 0 then
				@CurrentDate
			when 8 then
				DATEADD(d, Day(@CurrentDate) * -1 + 1, @CurrentDate)
			else
				dbo.fnSystemAdjustDateToBucket(@BucketTypeCode, @CurrentDate)
		end
			
	set @EndDate = convert(datetime,convert(varchar,@EndDate,1))
	set @StartDate = dateadd(yyyy, -100, @EndDate)
	set @CurrentPeriod = 0
	
	declare curBk cursor for			
		SELECT     Period
		FROM         tbSystemBucket
		ORDER BY Period

	open curBk
	fetch next from curBk into @Period
	while @@FETCH_STATUS = 0
		begin
		if @Period > 0
			begin
			set @StartDate = @EndDate
			set @Offset = @Period - @CurrentPeriod
			set @EndDate = case @UnitOfTimeCode
				when 1 then		--day
					dateadd(d, @Offset, @StartDate) 					
				when 2 then		--week
					dateadd(d, @Offset * 7, @StartDate)
				when 3 then		--month
					dateadd(m, @Offset, @StartDate)
				end
			end
		
		insert into @tbBkn(Period, StartDate, EndDate)
		values (@Period, @StartDate, @EndDate)
		
		set @CurrentPeriod = @Period
		
		fetch next from curBk into @Period
		end
		
			
	RETURN
	END
GO
CREATE FUNCTION [dbo].[fnSystemActivePeriod]
	(
	)
RETURNS @tbSystemYearPeriod TABLE (YearNumber smallint, StartOn datetime, EndOn datetime, MonthName nvarchar(10), Description nvarchar(10), MonthNumber smallint) 
   AS
	BEGIN
	declare @StartOn datetime
	declare @EndOn datetime
	
	if exists (	SELECT     StartOn	FROM tbSystemYearPeriod WHERE (CashStatusCode < 3))
		begin
		SELECT @StartOn = MIN(StartOn)
		FROM         tbSystemYearPeriod
		WHERE     (CashStatusCode < 3)
		
		if exists (select StartOn from tbSystemYearPeriod where StartOn > @StartOn)
			select top 1 @EndOn = StartOn from tbSystemYearPeriod where StartOn > @StartOn order by StartOn
		else
			set @EndOn = dateadd(m, 1, @StartOn)
			
		insert into @tbSystemYearPeriod (YearNumber, StartOn, EndOn, MonthName, Description, MonthNumber)
		SELECT     tbSystemYearPeriod.YearNumber, tbSystemYearPeriod.StartOn, @EndOn, tbSystemMonth.MonthName, tbSystemYear.Description, tbSystemMonth.MonthNumber
		FROM         tbSystemYearPeriod INNER JOIN
		                      tbSystemMonth ON tbSystemYearPeriod.MonthNumber = tbSystemMonth.MonthNumber INNER JOIN
		                      tbSystemYear ON tbSystemYearPeriod.YearNumber = tbSystemYear.YearNumber
		WHERE     (tbSystemYearPeriod.StartOn = @StartOn)
		end	
	RETURN
	END
GO
CREATE FUNCTION [dbo].[fnCashAccountStatements]
()
RETURNS  @tbCashAccount TABLE (CashAccountCode nvarchar(20), EntryNumber int, PaymentCode nvarchar(20), PaidOn datetime, PaidBalance money, TaxedBalance money)
  AS
	BEGIN
	declare @CashAccountCode nvarchar(20)
	declare curAccount cursor local for 
		SELECT     CashAccountCode
		FROM         tbOrgAccount
		WHERE     (AccountClosed = 0)
		ORDER BY CashAccountCode

	open curAccount
	fetch next from curAccount into @CashAccountCode
	while @@FETCH_STATUS = 0
		begin
		insert into @tbCashAccount (CashAccountCode, EntryNumber, PaymentCode, PaidOn, PaidBalance, TaxedBalance)
		SELECT     @CashAccountCode As CashAccountCode, EntryNumber, PaymentCode, PaidOn, PaidBalance, TaxedBalance
		FROM         fnCashAccountStatement(@CashAccountCode) fnCashAccountStatement		
		fetch next from curAccount into @CashAccountCode
		end
	
	close curAccount
	deallocate curAccount
	
	RETURN
	END
GO
CREATE FUNCTION [dbo].[fnTaxCorpStatement]
	()
RETURNS @tbCorp TABLE 
	(
	StartOn datetime, 
	TaxDue money ,
	TaxPaid money ,
	Balance money
	)
  AS
	BEGIN
	declare @Balance money
	declare @StartOn datetime
	declare @TaxDue money
	declare @TaxPaid money
	
	INSERT INTO @tbCorp (StartOn, TaxDue, TaxPaid, Balance)
	SELECT     StartOn, CorporationTax, 0 As TaxPaid, 0 AS Balance
	FROM         fnTaxCorpTotals() fnTaxCorpTotals	
	
	INSERT INTO @tbCorp (StartOn, TaxDue, TaxPaid, Balance)
	SELECT     tbOrgPayment.PaidOn, 0 As TaxDue, (tbOrgPayment.PaidOutValue * -1) + tbOrgPayment.PaidInValue AS TaxPaid, 0 As Balance
	FROM         tbOrgPayment INNER JOIN
	                      vwSystemCorpTaxCashCode ON tbOrgPayment.CashCode = vwSystemCorpTaxCashCode.CashCode	                      

	set @Balance = 0
	
	DECLARE curVS CURSOR LOCAL FOR
		SELECT StartOn, TaxDue, TaxPaid
		FROM @tbCorp
		ORDER BY StartOn, TaxDue
	
	OPEN curVS
	FETCH NEXT FROM curVS INTO @StartOn, @TaxDue, @TaxPaid
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		set @Balance = @Balance + @TaxDue + @TaxPaid
		UPDATE @tbCorp
		SET Balance = @Balance
		WHERE StartOn = @StartOn AND TaxDue = @TaxDue 
		FETCH NEXT FROM curVS INTO @StartOn, @TaxDue, @TaxPaid
		END
	
	CLOSE curVS
	DEALLOCATE curVS	
	RETURN
	END
GO
CREATE  FUNCTION [dbo].[fnSystemVatBalance]
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
CREATE FUNCTION [dbo].[fnSystemActiveStartOn]
	()
RETURNS datetime
  AS
	BEGIN
	declare @StartOn datetime
	select @StartOn = StartOn from dbo.fnSystemActivePeriod()
	RETURN @StartOn
	END
GO
CREATE FUNCTION [dbo].[fnSystemDateBucket]
	(@CurrentDate datetime, @BucketDate datetime)
RETURNS smallint
  AS
	BEGIN
	declare @Period smallint
	SELECT  @Period = Period
	FROM         dbo.fnSystemBuckets(@CurrentDate) fnEnvBuckets
	WHERE     (StartDate <= @BucketDate) AND (EndDate > @BucketDate) 
	RETURN @Period
	END
GO
CREATE FUNCTION [dbo].[fnSystemCorpTaxBalance]
	()
RETURNS money
  AS
	BEGIN
	declare @Balance money
	SELECT  @Balance = SUM(CorporationTax)
	FROM         vwCorpTaxInvoice
	
	SELECT  @Balance = @Balance + ISNULL(SUM(tbOrgPayment.PaidInValue - tbOrgPayment.PaidOutValue), 0)
	FROM         tbOrgPayment INNER JOIN
	                      vwSystemCorpTaxCashCode ON tbOrgPayment.CashCode = vwSystemCorpTaxCashCode.CashCode	                      

	IF @Balance < 0
		SET @Balance = 0
		
	RETURN isnull(@Balance, 0)
	END
GO
CREATE FUNCTION [dbo].[fnStatementReserves] ()
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
	declare @ReferenceCode2 nvarchar(20)
	declare @CashCode nvarchar(50)
	declare @AccountCode nvarchar(10)
	declare @TransactOn datetime
	declare @CashEntryTypeCode smallint
	declare @PayOut money
	declare @PayIn money
	declare @Balance money
	declare @Now datetime

	select @ReferenceCode = dbo.fnSystemProfileText(1219)
	set @Balance = dbo.fnCashReserveBalance()	
	SELECT @TransactOn = MAX(tbOrgPayment.PaidOn)
	FROM         tbOrgAccount INNER JOIN
						  tbOrgPayment ON tbOrgAccount.CashAccountCode = tbOrgPayment.CashAccountCode LEFT OUTER JOIN
						  tbCashCode ON tbOrgAccount.CashCode = tbCashCode.CashCode
	WHERE     (tbCashCode.CashCode IS NULL)

	SELECT TOP 1 @AccountCode = AccountCode FROM tbSystemOptions
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, Balance)
	VALUES (@ReferenceCode, @AccountCode, @TransactOn, 1, 0, 0, @Balance)
	
		set @ReferenceCode = dbo.fnSystemProfileText(1214)	
	SET @TransactOn = DATEADD(d, dbo.fnSystemTaxHorizon(), @TransactOn)
	SELECT @PayOut = dbo.fnSystemCorpTaxBalance()
	SET @CashCode = dbo.fnSystemCashCode(1)
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	VALUES (@ReferenceCode, @AccountCode, @TransactOn, 5, 0, @PayOut, @CashCode)

	set @ReferenceCode2 = dbo.fnSystemProfileText(1215)	
	SET @TransactOn = DATEADD(n, 1, @TransactOn)
	SELECT @PayOut = SUM(CorporationTax)
	FROM         vwCorpTaxConfirmed
	IF @PayOut > 0
		BEGIN
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
		VALUES (@ReferenceCode2, @AccountCode, @TransactOn, 5, 0, @PayOut, @CashCode)
		END	
	
	SET @TransactOn = DATEADD(n, 1, @TransactOn)
	SELECT @PayOut = dbo.fnSystemVatBalance()
	IF @PayOut <> 0
		BEGIN
		IF @PayOut < 0
			BEGIN
			SET @PayIn = ABS(@PayOut)
			SET @PayOut = 0
			END
		ELSE
			SET @PayIn = 0
		SET @CashCode = dbo.fnSystemCashCode(2)
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
		VALUES (@ReferenceCode, @AccountCode, @TransactOn, 6, @PayIn, @PayOut, @CashCode)
		END
		
	SET @TransactOn = DATEADD(n, 1, @TransactOn)
	SELECT @PayOut = SUM(VatValue)
	FROM         vwTaskVatConfirmed
	IF @PayOut <> 0
		BEGIN
		IF @PayOut < 0
			BEGIN
			SET @PayIn = ABS(@PayOut)
			SET @PayOut = 0
			END
		ELSE
			SET @PayIn = 0
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
		VALUES (@ReferenceCode2, @AccountCode, @TransactOn, 6, @PayIn, @PayOut, @CashCode)
		END	

	declare curReserve cursor local for
		select TransactOn, CashEntryTypeCode, ReferenceCode, PayIn, PayOut, CashCode
		from @tbStatement
		order by TransactOn, CashEntryTypeCode, ReferenceCode, CashCode

	open curReserve
	
	fetch next from curReserve into @TransactOn, @CashEntryTypeCode, @ReferenceCode, @PayIn, @PayOut, @CashCode
	
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
		fetch next from curReserve into @TransactOn, @CashEntryTypeCode, @ReferenceCode, @PayIn, @PayOut, @CashCode
		end
	close curReserve
	deallocate curReserve

	RETURN
	END
GO
