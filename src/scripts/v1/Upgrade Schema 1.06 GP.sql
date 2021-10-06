/************************************************************
* Tru-Man Trade Control: Information and Cash System
* Copyright Tru-Man Industries Ltd 2008. All Rights Reserved.
* Author: Ian Monnox
* Description: Sql Server Upgrade Script - Encrypted Distribution Schema
* Data Version: 1.06
* Release Date: 11/7/2008
************************************************************/

CREATE OR ALTER  FUNCTION dbo.fnOrgRebuildInvoiceItems
	(
	@AccountCode nvarchar(10)
	)
RETURNS TABLE
AS
	RETURN ( SELECT     tbInvoice.InvoiceNumber, ROUND(SUM(tbInvoiceItem.InvoiceValue), 2) AS TotalInvoiceValue, ROUND(SUM(tbInvoiceItem.TaxValue), 2) 
	                               AS TotalTaxValue
	         FROM         tbInvoiceItem INNER JOIN
	                               tbInvoice ON tbInvoiceItem.InvoiceNumber = tbInvoice.InvoiceNumber
	         WHERE     (tbInvoice.AccountCode = @AccountCode) AND (tbInvoice.InvoiceStatusCode <> 1)
	         GROUP BY tbInvoiceItem.InvoiceNumber, tbInvoice.InvoiceNumber )
GO
CREATE OR ALTER  FUNCTION dbo.fnOrgRebuildInvoiceTasks
	(
	@AccountCode nvarchar(10)
	)
RETURNS TABLE
AS
	RETURN ( SELECT     tbInvoice.InvoiceNumber, ROUND(SUM(tbInvoiceTask.InvoiceValue), 2) AS TotalInvoiceValue, ROUND(SUM(tbInvoiceTask.TaxValue), 2) 
	                               AS TotalTaxValue
	         FROM         tbInvoiceTask INNER JOIN
	                               tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber
	         WHERE     (tbInvoice.AccountCode = @AccountCode) AND (tbInvoice.InvoiceStatusCode <> 1)
	         GROUP BY tbInvoiceTask.InvoiceNumber, tbInvoice.InvoiceNumber )
GO
CREATE OR ALTER  FUNCTION [dbo].[fnAccountPeriod]
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
CREATE OR ALTER  FUNCTION dbo.fnTaxVatStatement
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
CREATE OR ALTER  FUNCTION dbo.fnTaxTypeDueDates
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
	END
GO
CREATE OR ALTER  FUNCTION dbo.fnCashAccountStatement
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
CREATE OR ALTER  FUNCTION dbo.fnCashAccountStatements
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
CREATE OR ALTER  FUNCTION dbo.fnCashCompanyBalance
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
CREATE OR ALTER  FUNCTION dbo.fnCategoryTotalCashCodes
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
CREATE OR ALTER  FUNCTION dbo.fnNetProfitCashCodes
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
CREATE OR ALTER  FUNCTION dbo.fnOrgIndustrySectors
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
CREATE OR ALTER  FUNCTION dbo.fnOrgStatement
	(
	@AccountCode nvarchar(10)
	)
RETURNS @tbStatement TABLE (TransactedOn datetime, OrderBy smallint, Reference nvarchar(50), StatementType nvarchar(20), Charge money, Balance money)
 AS
	BEGIN
	declare @TransactedOn datetime
	declare @OrderBy smallint
	declare @Reference nvarchar(50)
	declare @StatementType nvarchar(20)
	declare @Charge money
	declare @Balance money
	
	select @StatementType = dbo.fnSystemProfileText(3005)
	select @Balance = OpeningBalance from tbOrg where AccountCode = @AccountCode
	
	SELECT   @TransactedOn = MIN(TransactedOn) 
	FROM         vwAccountStatementBase
	WHERE     (AccountCode = @AccountCode)
	
	insert into @tbStatement (TransactedOn, OrderBy, StatementType, Charge, Balance)
	values (dateadd(d, -1, @TransactedOn), 0, @StatementType, @Balance, @Balance)
	 
	declare curAc cursor local for
		SELECT     TransactedOn, OrderBy, Reference, StatementType, Charge
		FROM         vwAccountStatementBase
		WHERE     (AccountCode = @AccountCode)
		ORDER BY TransactedOn, OrderBy

	open curAc
	fetch next from curAc into @TransactedOn, @OrderBy, @Reference, @StatementType, @Charge
	while @@FETCH_STATUS = 0
		begin
		set @Balance = @Balance + @Charge
		insert into @tbStatement (TransactedOn, OrderBy, Reference, StatementType, Charge, Balance)
		values (@TransactedOn, @OrderBy, @Reference, @StatementType, @Charge, @Balance)
		
		fetch next from curAc into @TransactedOn, @OrderBy, @Reference, @StatementType, @Charge
		end
	
	close curAc
	deallocate curAc
		
	RETURN
	END
GO
CREATE OR ALTER  FUNCTION [dbo].[fnPad]
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
CREATE OR ALTER  FUNCTION dbo.fnStatementTaxAccount
	(
	@TaxTypeCode smallint
	)
RETURNS nvarchar(10)
 AS
	BEGIN
	declare @AccountCode nvarchar(10)
	if exists (SELECT     AccountCode
		FROM         tbCashTaxType
		WHERE     (TaxTypeCode = @TaxTypeCode) AND (NOT (AccountCode IS NULL)))
		begin
		SELECT @AccountCode = AccountCode
		FROM         tbCashTaxType
		WHERE     (TaxTypeCode = @TaxTypeCode) AND (NOT (AccountCode IS NULL))
		end
	else
		begin
		SELECT TOP 1 @AccountCode = AccountCode
		FROM         tbSystemOptions		
		end
			
	
	RETURN @AccountCode
	END
GO
CREATE OR ALTER  FUNCTION dbo.fnStatementVat
	()
RETURNS @tbVat TABLE (
	ReferenceCode nvarchar(20), 
	AccountCode nvarchar(10),
	TransactOn datetime,
	CashEntryTypeCode int,
	PayOut money,
	PayIn money
	)
 AS
	BEGIN
	declare @LastBalanceOn datetime
	declare @VatDueOn datetime
	declare @VatDue money
	

	if exists(SELECT  MAX(StartOn) AS LastStartOn FROM vwTaxVatStatement)
		begin
		select @LastBalanceOn = MAX(StartOn) FROM vwTaxVatStatement
		SELECT  TOP 1 @VatDueOn = PayOn
		FROM         vwStatementVatDueDate
		
		SELECT @VatDue = Balance
		FROM         vwTaxVatStatement
		WHERE     (StartOn = @LastBalanceOn)		
		
		if (@VatDue <> 0)
			begin
			insert into @tbVat (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayOut, PayIn)
			values ('-', dbo.fnStatementTaxAccount(2), @VatDueOn, 6, CASE WHEN @VatDue > 0 THEN @VatDue ELSE 0 END, CASE WHEN @VatDue < 0 THEN ABS(@VatDue) ELSE 0 END)						
			end
		end
	
	RETURN
	END
GO
CREATE OR ALTER  FUNCTION [dbo].[fnSystemActivePeriod]
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
CREATE OR ALTER  FUNCTION dbo.fnSystemActiveStartOn
	()
RETURNS datetime
 AS
	BEGIN
	declare @StartOn datetime
	select @StartOn = StartOn from dbo.fnSystemActivePeriod()
	RETURN @StartOn
	END
GO
CREATE OR ALTER  FUNCTION dbo.fnSystemAdjustDateToBucket
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
CREATE OR ALTER  FUNCTION dbo.fnSystemAdjustToCalendar
	(
	@UserId nvarchar(10),
	@SourceDate datetime,
	@Days int
	)
RETURNS datetime
   AS
	BEGIN
	declare @CalendarCode nvarchar(10)
	declare @TargetDate datetime
	declare @WorkingDay bit
	
	declare @CurrentDay smallint
	declare @Monday smallint
	declare @Tuesday smallint
	declare @Wednesday smallint
	declare @Thursday smallint
	declare @Friday smallint
	declare @Saturday smallint
	declare @Sunday smallint
		
	set @TargetDate = @SourceDate

	SELECT     @CalendarCode = tbSystemCalendar.CalendarCode, @Monday = Monday, @Tuesday = Tuesday, @Wednesday = Wednesday, @Thursday = Thursday, @Friday = Friday, @Saturday = Saturday, @Sunday = Sunday
	FROM         tbSystemCalendar INNER JOIN
	                      tbUser ON tbSystemCalendar.CalendarCode = tbUser.CalendarCode
	WHERE UserId = @UserId
	
	while @Days > -1
		begin
		set @CurrentDay = dbo.fnSystemWeekDay(@TargetDate)
		if @CurrentDay = 1				
			set @WorkingDay = case when @Monday != 0 then 1 else 0 end
		else if @CurrentDay = 2
			set @WorkingDay = case when @Tuesday != 0 then 1 else 0 end
		else if @CurrentDay = 3
			set @WorkingDay = case when @Wednesday != 0 then 1 else 0 end
		else if @CurrentDay = 4
			set @WorkingDay = case when @Thursday != 0 then 1 else 0 end
		else if @CurrentDay = 5
			set @WorkingDay = case when @Friday != 0 then 1 else 0 end
		else if @CurrentDay = 6
			set @WorkingDay = case when @Saturday != 0 then 1 else 0 end
		else if @CurrentDay = 7
			set @WorkingDay = case when @Sunday != 0 then 1 else 0 end
		
		if @WorkingDay = 1
			begin
			if not exists(SELECT     UnavailableOn
				        FROM         tbSystemCalendarHoliday
				        WHERE     (CalendarCode = @CalendarCode) AND (UnavailableOn = @TargetDate))
				set @Days = @Days - 1
			end
			
		if @Days > -1
			set @TargetDate = dateadd(d, -1, @TargetDate)
		end
		

	RETURN @TargetDate
	END
GO
CREATE OR ALTER  FUNCTION dbo.fnSystemBuckets
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
CREATE OR ALTER   FUNCTION dbo.fnSystemCashCode
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
CREATE OR ALTER  FUNCTION dbo.fnSystemCorpTaxBalance
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

	RETURN isnull(@Balance, 0)
	END
GO
CREATE OR ALTER  FUNCTION [dbo].[fnSystemDateBucket]
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
CREATE OR ALTER  FUNCTION [dbo].[fnSystemProfileText]
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
CREATE OR ALTER   FUNCTION dbo.fnSystemVatBalance
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

	RETURN isnull(@Balance, 0)
	END
GO
CREATE OR ALTER  FUNCTION [dbo].[fnSystemWeekDay]
	(
	@Date datetime
	)
RETURNS smallint
   AS
	BEGIN
	declare @CurrentDay smallint
	set @CurrentDay = datepart(dw, @Date)
	RETURN 	case when @CurrentDay > (7 - @@DATEFIRST + 1) then
				@CurrentDay - (7 - @@DATEFIRST + 1)
			else
				@CurrentDay + (@@DATEFIRST - 1)
			end
	END
GO
CREATE OR ALTER  FUNCTION [dbo].[fnTaskDefaultTaxCode] 
	(
	@AccountCode nvarchar(10),
	@CashCode nvarchar(50)
	)
RETURNS nvarchar(10)
 AS
	BEGIN
	declare @TaxCode nvarchar(10)
	
	if (not @AccountCode is null) and (not @CashCode is null)
		begin
		if exists(SELECT     TaxCode
			  FROM         tbOrg
			  WHERE     (AccountCode = @AccountCode) AND (NOT (TaxCode IS NULL)))
			begin
			SELECT    @TaxCode = TaxCode
			FROM         tbOrg
			WHERE     (AccountCode = @AccountCode) AND (NOT (TaxCode IS NULL))
			end
		else
			begin
			SELECT    @TaxCode =  TaxCode
			FROM         tbCashCode
			WHERE     (CashCode = @CashCode)		
			end
		end
	else
		set @TaxCode = null
				
	RETURN @TaxCode
	END
GO
CREATE OR ALTER  FUNCTION dbo.fnTaxCorpOrderTotals
(@IncludeForecasts bit = 0)
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
		if (@IncludeForecasts = 0)
			begin
			INSERT INTO @tbCorp (StartOn, NetProfit, CorporationTax)
			SELECT     @PayOn AS PayOn, ISNULL(SUM(NetProfit), 0) AS NetProfit, ISNULL(SUM(CorporationTax), 0) AS CorporationTax
			FROM         vwCorpTaxConfirmed
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
			HAVING      (ISNULL(SUM(CorporationTax), 0) > 0)
			end
		else
			begin
			INSERT INTO @tbCorp (StartOn, NetProfit, CorporationTax)
			SELECT     @PayOn AS PayOn, ISNULL(SUM(NetProfit), 0) AS NetProfit, ISNULL(SUM(CorporationTax), 0) AS CorporationTax
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
CREATE OR ALTER  FUNCTION dbo.fnTaxVatOrderTotals
	(@IncludeForecasts bit = 0)
RETURNS @tbVat TABLE 
	(
	StartOn datetime, 
	PayIn money,
	PayOut money
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
		if (@IncludeForecasts = 0)
			begin
			INSERT INTO @tbVat (StartOn, PayIn, PayOut)
			SELECT     @PayOn AS PayOn, CASE WHEN ISNULL(SUM(VatValue), 0) > 0 THEN ISNULL(SUM(VatValue), 0) ELSE 0 END AS PayIn, 
			                      CASE WHEN ISNULL(SUM(VatValue), 0) < 0 THEN ABS(ISNULL(SUM(VatValue), 0)) ELSE 0 END AS PayOut
			FROM         vwTaskVatConfirmed
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo) AND (VatValue <> 0) 
			end
		else
			begin
			INSERT INTO @tbVat (StartOn, PayIn, PayOut)
			SELECT     @PayOn AS PayOn, 
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
CREATE OR ALTER  FUNCTION dbo.fnTaxVatTotals
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

	update @tbVat
	set VatDue = (HomeSalesVat + ExportSalesVat) - (HomePurchasesVat + ExportPurchasesVat)
	
	RETURN
	END
GO
CREATE OR ALTER  VIEW dbo.vwCashSummaryInvoices
 AS
SELECT     dbo.tbInvoice.InvoiceNumber, CASE dbo.tbInvoice.InvoiceTypeCode WHEN 1 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) 
                      WHEN 4 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) ELSE 0 END AS ToCollect, 
                      CASE dbo.tbInvoice.InvoiceTypeCode WHEN 2 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) WHEN 3 THEN (InvoiceValue + TaxValue) 
                      - (PaidValue + PaidTaxValue) ELSE 0 END AS ToPay, CASE dbo.tbInvoiceType.CashModeCode WHEN 1 THEN (TaxValue - PaidTaxValue) 
                      * - 1 WHEN 2 THEN TaxValue - PaidTaxValue END AS TaxValue
FROM         dbo.tbInvoice INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
WHERE     (dbo.tbInvoice.InvoiceStatusCode = 2) OR
                      (dbo.tbInvoice.InvoiceStatusCode = 3)
GO
CREATE OR ALTER   VIEW dbo.vwCashSummaryBase
 AS
SELECT     ISNULL(SUM(ToCollect), 0) AS Collect, ISNULL(SUM(ToPay), 0) AS Pay, ISNULL(SUM(TaxValue), 0) + dbo.fnSystemVatBalance() 
                      + dbo.fnSystemCorpTaxBalance() AS Tax, dbo.fnCashCompanyBalance() AS CompanyBalance
FROM         dbo.vwCashSummaryInvoices
GO
CREATE OR ALTER  VIEW dbo.vwCashSummary
 AS
SELECT     GETDATE() AS Timstamp, Collect, Pay, Tax, CompanyBalance AS Cash, CompanyBalance + Collect - Pay - Tax AS Balance
FROM         dbo.vwCashSummaryBase
GO
CREATE OR ALTER  VIEW [dbo].[vwCashActiveYears]
  AS
SELECT     TOP 100 PERCENT dbo.tbSystemYear.YearNumber, dbo.tbSystemYear.Description, dbo.tbCashStatus.CashStatus
FROM         dbo.tbSystemYear INNER JOIN
                      dbo.tbCashStatus ON dbo.tbSystemYear.CashStatusCode = dbo.tbCashStatus.CashStatusCode
WHERE     (dbo.tbSystemYear.CashStatusCode < 4)
ORDER BY dbo.tbSystemYear.YearNumber
GO
CREATE OR ALTER  VIEW [dbo].[vwCashCategoriesBank]
  AS
SELECT     TOP 100 PERCENT CategoryCode, Category, CashModeCode
FROM         dbo.tbCashCategory
WHERE     (CashTypeCode = 4) AND (CategoryTypeCode = 1)
GROUP BY CategoryCode, Category, DisplayOrder, CashModeCode
ORDER BY DisplayOrder, Category
GO
CREATE OR ALTER  VIEW [dbo].[vwCashCategoriesNominal]
  AS
SELECT     TOP 100 PERCENT CategoryCode, Category, CashModeCode
FROM         dbo.tbCashCategory
WHERE     (CashTypeCode = 3) AND (CategoryTypeCode = 1)
GROUP BY CategoryCode, Category, DisplayOrder, CashModeCode
ORDER BY DisplayOrder, Category
GO
CREATE OR ALTER  VIEW [dbo].[vwCashCategoriesTax]
  AS
SELECT     TOP 100 PERCENT CategoryCode, Category, CashModeCode
FROM         dbo.tbCashCategory
WHERE     (CashTypeCode = 2) AND (CategoryTypeCode = 1)
GROUP BY CategoryCode, Category, DisplayOrder, CashModeCode
ORDER BY DisplayOrder, Category
GO
CREATE OR ALTER  VIEW [dbo].[vwCashCategoriesTotals]
  AS
SELECT     TOP 100 PERCENT CategoryCode, CashModeCode, CashTypeCode, DisplayOrder, Category
FROM         dbo.tbCashCategory
WHERE     (CategoryTypeCode = 2)
ORDER BY CashTypeCode, CategoryCode
GO
CREATE OR ALTER  VIEW [dbo].[vwCashCategoriesTrade]
  AS
SELECT     TOP 100 PERCENT CategoryCode, Category, CashModeCode
FROM         dbo.tbCashCategory
WHERE     (CashTypeCode = 1) AND (CategoryTypeCode = 1)
GROUP BY CategoryCode, Category, DisplayOrder, CashModeCode
ORDER BY DisplayOrder, Category
GO
CREATE OR ALTER  VIEW [dbo].[vwUserCredentials]
 AS
SELECT     UserId, UserName, LogonName, Administrator
FROM         dbo.tbUser
WHERE     (LogonName = SUSER_SNAME())
GO
CREATE OR ALTER  VIEW [dbo].[vwCashAnalysisCodes]
  AS
SELECT     TOP 100 PERCENT dbo.tbCashCategory.CategoryCode, dbo.tbCashCategory.Category, dbo.tbCashCategoryExp.Expression, 
                      dbo.tbCashCategoryExp.Format
FROM         dbo.tbCashCategory INNER JOIN
                      dbo.tbCashCategoryExp ON dbo.tbCashCategory.CategoryCode = dbo.tbCashCategoryExp.CategoryCode
WHERE     (dbo.tbCashCategory.CategoryTypeCode = 3)
ORDER BY dbo.tbCashCategory.DisplayOrder
GO
CREATE OR ALTER  VIEW [dbo].[vwCashMonthList]
 AS
SELECT DISTINCT 
                      TOP 100 PERCENT CAST(dbo.tbSystemYearPeriod.StartOn AS float) AS StartOn, dbo.tbSystemMonth.MonthName, 
                      dbo.tbSystemYearPeriod.MonthNumber
FROM         dbo.tbSystemYearPeriod INNER JOIN
                      dbo.fnSystemActivePeriod() AS fnSystemActivePeriod ON dbo.tbSystemYearPeriod.YearNumber = fnSystemActivePeriod.YearNumber INNER JOIN
                      dbo.tbSystemMonth ON dbo.tbSystemYearPeriod.MonthNumber = dbo.tbSystemMonth.MonthNumber
ORDER BY StartOn
GO
CREATE OR ALTER  VIEW dbo.vwAccountStatementInvoices
 AS
SELECT     TOP 100 PERCENT dbo.tbInvoice.AccountCode, dbo.tbInvoice.InvoicedOn AS TransactedOn, 1 AS OrderBy, dbo.tbInvoice.InvoiceNumber AS Reference, 
                      dbo.tbInvoiceType.InvoiceType AS StatementType, 
                      CASE CashModeCode WHEN 1 THEN dbo.tbInvoice.InvoiceValue + dbo.tbInvoice.TaxValue WHEN 2 THEN (dbo.tbInvoice.InvoiceValue + dbo.tbInvoice.TaxValue)
                       * - 1 END AS Charge
FROM         dbo.tbInvoice INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
ORDER BY dbo.tbInvoice.AccountCode, dbo.tbInvoice.InvoicedOn
GO
CREATE OR ALTER  VIEW dbo.vwAccountStatementPayments
 AS
SELECT     TOP 100 PERCENT dbo.tbOrgPayment.AccountCode, dbo.tbOrgPayment.PaidOn AS TransactedOn, 2 AS OrderBy, 
                      dbo.tbOrgPayment.PaymentReference AS Reference, dbo.tbOrgPaymentStatus.PaymentStatus AS StatementType, 
                      CASE WHEN PaidInValue > 0 THEN PaidInValue ELSE PaidOutValue * - 1 END AS Charge
FROM         dbo.tbOrgPayment INNER JOIN
                      dbo.tbOrgPaymentStatus ON dbo.tbOrgPayment.PaymentStatusCode = dbo.tbOrgPaymentStatus.PaymentStatusCode
ORDER BY dbo.tbOrgPayment.AccountCode, dbo.tbOrgPayment.PaidOn
GO
CREATE OR ALTER  VIEW dbo.vwAccountStatementPaymentBase
 AS
SELECT     AccountCode, TransactedOn, OrderBy, Reference, StatementType, SUM(Charge) AS Charge
FROM         dbo.vwAccountStatementPayments
GROUP BY AccountCode, TransactedOn, OrderBy, Reference, StatementType
GO
CREATE OR ALTER  VIEW dbo.vwAccountStatementBase
 AS
SELECT     TOP 100 PERCENT AccountCode, TransactedOn, OrderBy, Reference, StatementType, Charge
FROM         dbo.vwAccountStatementPaymentBase
UNION
SELECT     TOP 100 PERCENT AccountCode, TransactedOn, OrderBy, Reference, StatementType, Charge
FROM         dbo.vwAccountStatementInvoices
GO
CREATE OR ALTER  VIEW dbo.vwCashAccountStatement
 AS
SELECT     dbo.tbOrgPayment.PaymentCode, dbo.tbOrgPayment.CashAccountCode, dbo.tbUser.UserName, dbo.tbOrgPayment.AccountCode, 
                      dbo.tbOrg.AccountName, dbo.tbOrgPayment.CashCode, dbo.tbCashCode.CashDescription, dbo.tbSystemTaxCode.TaxDescription, 
                      dbo.tbOrgPayment.PaidOn, dbo.tbOrgPayment.PaidInValue, dbo.tbOrgPayment.PaidOutValue, dbo.tbOrgPayment.TaxInValue, 
                      dbo.tbOrgPayment.TaxOutValue, dbo.tbOrgPayment.PaymentReference, dbo.tbOrgPayment.InsertedBy, dbo.tbOrgPayment.InsertedOn, 
                      dbo.tbOrgPayment.UpdatedBy, dbo.tbOrgPayment.UpdatedOn, dbo.tbOrgPayment.TaxCode
FROM         dbo.tbOrgPayment INNER JOIN
                      dbo.tbUser ON dbo.tbOrgPayment.UserId = dbo.tbUser.UserId INNER JOIN
                      dbo.tbOrg ON dbo.tbOrgPayment.AccountCode = dbo.tbOrg.AccountCode LEFT OUTER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbOrgPayment.TaxCode = dbo.tbSystemTaxCode.TaxCode LEFT OUTER JOIN
                      dbo.tbCashCode ON dbo.tbOrgPayment.CashCode = dbo.tbCashCode.CashCode
GO
CREATE OR ALTER  VIEW dbo.vwCashAccountStatements
 AS
SELECT     TOP 100 PERCENT fnCashAccountStatements.CashAccountCode, dbo.fnAccountPeriod(fnCashAccountStatements.PaidOn) AS StartOn, 
                      fnCashAccountStatements.EntryNumber, fnCashAccountStatements.PaymentCode, fnCashAccountStatements.PaidOn, 
                      dbo.vwCashAccountStatement.AccountName, dbo.vwCashAccountStatement.PaymentReference, dbo.vwCashAccountStatement.PaidInValue, 
                      dbo.vwCashAccountStatement.PaidOutValue, fnCashAccountStatements.PaidBalance, dbo.vwCashAccountStatement.TaxInValue, 
                      dbo.vwCashAccountStatement.TaxOutValue, fnCashAccountStatements.TaxedBalance, dbo.vwCashAccountStatement.CashCode, 
                      dbo.vwCashAccountStatement.CashDescription, dbo.vwCashAccountStatement.TaxDescription, dbo.vwCashAccountStatement.UserName, 
                      dbo.vwCashAccountStatement.AccountCode, dbo.vwCashAccountStatement.TaxCode
FROM         dbo.fnCashAccountStatements() fnCashAccountStatements LEFT OUTER JOIN
                      dbo.vwCashAccountStatement ON fnCashAccountStatements.PaymentCode = dbo.vwCashAccountStatement.PaymentCode
ORDER BY fnCashAccountStatements.CashAccountCode, fnCashAccountStatements.EntryNumber
GO
CREATE OR ALTER  VIEW dbo.vwCashAccountLastPeriodEntry
 AS
SELECT     CashAccountCode, StartOn, MAX(EntryNumber) AS LastEntry
FROM         dbo.vwCashAccountStatements
GROUP BY CashAccountCode, StartOn
HAVING      (NOT (StartOn IS NULL))
GO
CREATE OR ALTER  VIEW dbo.vwCashAccountPeriodClosingBalance
 AS
SELECT     dbo.tbOrgAccount.CashCode, dbo.vwCashAccountLastPeriodEntry.StartOn, SUM(dbo.vwCashAccountStatements.PaidBalance) 
                      + SUM(dbo.vwCashAccountStatements.TaxedBalance) AS ClosingBalance
FROM         dbo.vwCashAccountLastPeriodEntry INNER JOIN
                      dbo.vwCashAccountStatements ON dbo.vwCashAccountLastPeriodEntry.CashAccountCode = dbo.vwCashAccountStatements.CashAccountCode AND 
                      dbo.vwCashAccountLastPeriodEntry.StartOn = dbo.vwCashAccountStatements.StartOn AND 
                      dbo.vwCashAccountLastPeriodEntry.LastEntry = dbo.vwCashAccountStatements.EntryNumber INNER JOIN
                      dbo.tbOrgAccount ON dbo.vwCashAccountLastPeriodEntry.CashAccountCode = dbo.tbOrgAccount.CashAccountCode 
GROUP BY dbo.tbOrgAccount.CashCode, dbo.vwCashAccountLastPeriodEntry.StartOn
GO
CREATE OR ALTER  VIEW dbo.vwCashAccountRebuild
 AS
SELECT     dbo.tbOrgPayment.CashAccountCode, dbo.tbOrgAccount.OpeningBalance, 
                      dbo.tbOrgAccount.OpeningBalance + SUM(dbo.tbOrgPayment.PaidInValue - dbo.tbOrgPayment.PaidOutValue) AS CurrentBalance
FROM         dbo.tbOrgPayment INNER JOIN
                      dbo.tbOrgAccount ON dbo.tbOrgPayment.CashAccountCode = dbo.tbOrgAccount.CashAccountCode
WHERE     (dbo.tbOrgPayment.PaymentStatusCode > 1)
GROUP BY dbo.tbOrgPayment.CashAccountCode, dbo.tbOrgAccount.OpeningBalance
GO
CREATE OR ALTER  VIEW dbo.vwCashCodeForecastSummary
 AS
SELECT     dbo.tbTask.CashCode, dbo.fnAccountPeriod(dbo.tbTask.ActionOn) AS StartOn, SUM(dbo.tbTask.TotalCharge) AS ForecastValue, 
                      SUM(dbo.tbTask.TotalCharge * ISNULL(dbo.tbSystemTaxCode.TaxRate, 0)) AS ForecastTax
FROM         dbo.tbTask INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode LEFT OUTER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbTask.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE     (dbo.tbTask.ActionOn >= dbo.fnSystemActiveStartOn())
GROUP BY dbo.tbTask.CashCode, dbo.fnAccountPeriod(dbo.tbTask.ActionOn)
GO
CREATE OR ALTER  VIEW dbo.vwInvoiceRegisterItems
 AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoice.InvoiceNumber, dbo.tbInvoiceItem.CashCode AS TaskCode, 
                      dbo.tbCashCode.CashCode, dbo.tbCashCode.CashDescription, dbo.tbInvoiceItem.TaxCode, dbo.tbSystemTaxCode.TaxDescription, 
                      dbo.tbInvoice.AccountCode, dbo.tbInvoice.InvoiceTypeCode, dbo.tbInvoice.InvoiceStatusCode, dbo.tbInvoice.InvoicedOn, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.InvoiceValue * - 1 ELSE dbo.tbInvoiceItem.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.TaxValue * - 1 ELSE dbo.tbInvoiceItem.TaxValue END AS TaxValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.PaidValue * - 1 ELSE dbo.tbInvoiceItem.PaidValue END AS PaidValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.PaidTaxValue * - 1 ELSE dbo.tbInvoiceItem.PaidTaxValue END AS PaidTaxValue,
                       dbo.tbInvoice.PaymentTerms, dbo.tbInvoice.Printed, dbo.tbOrg.AccountName, dbo.tbUser.UserName, dbo.tbInvoiceStatus.InvoiceStatus, 
                      dbo.tbInvoiceType.CashModeCode, dbo.tbInvoiceType.InvoiceType
FROM         dbo.tbInvoice INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode INNER JOIN
                      dbo.tbInvoiceStatus ON dbo.tbInvoice.InvoiceStatusCode = dbo.tbInvoiceStatus.InvoiceStatusCode INNER JOIN
                      dbo.tbUser ON dbo.tbInvoice.UserId = dbo.tbUser.UserId INNER JOIN
                      dbo.tbInvoiceItem ON dbo.tbInvoice.InvoiceNumber = dbo.tbInvoiceItem.InvoiceNumber INNER JOIN
                      dbo.tbCashCode ON dbo.tbInvoiceItem.CashCode = dbo.tbCashCode.CashCode LEFT OUTER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbInvoiceItem.TaxCode = dbo.tbSystemTaxCode.TaxCode
GO
CREATE OR ALTER  VIEW dbo.vwInvoiceRegisterTasks
 AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoice.InvoiceNumber, dbo.tbInvoiceTask.TaskCode, dbo.tbCashCode.CashCode, 
                      dbo.tbCashCode.CashDescription, dbo.tbInvoiceTask.TaxCode, dbo.tbSystemTaxCode.TaxDescription, dbo.tbInvoice.AccountCode, 
                      dbo.tbInvoice.InvoiceTypeCode, dbo.tbInvoice.InvoiceStatusCode, dbo.tbInvoice.InvoicedOn, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.InvoiceValue * - 1 ELSE dbo.tbInvoiceTask.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.TaxValue * - 1 ELSE dbo.tbInvoiceTask.TaxValue END AS TaxValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.PaidValue * - 1 ELSE dbo.tbInvoiceTask.PaidValue END AS PaidValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.PaidTaxValue * - 1 ELSE dbo.tbInvoiceTask.PaidTaxValue END AS PaidTaxValue,
                       dbo.tbInvoice.PaymentTerms, dbo.tbInvoice.Printed, dbo.tbOrg.AccountName, dbo.tbUser.UserName, dbo.tbInvoiceStatus.InvoiceStatus, 
                      dbo.tbInvoiceType.CashModeCode, dbo.tbInvoiceType.InvoiceType
FROM         dbo.tbInvoice INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode INNER JOIN
                      dbo.tbInvoiceStatus ON dbo.tbInvoice.InvoiceStatusCode = dbo.tbInvoiceStatus.InvoiceStatusCode INNER JOIN
                      dbo.tbUser ON dbo.tbInvoice.UserId = dbo.tbUser.UserId INNER JOIN
                      dbo.tbInvoiceTask ON dbo.tbInvoice.InvoiceNumber = dbo.tbInvoiceTask.InvoiceNumber INNER JOIN
                      dbo.tbCashCode ON dbo.tbInvoiceTask.CashCode = dbo.tbCashCode.CashCode LEFT OUTER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbInvoiceTask.TaxCode = dbo.tbSystemTaxCode.TaxCode
GO
CREATE OR ALTER  VIEW dbo.vwInvoiceRegisterDetail
 AS
SELECT     *
FROM         vwInvoiceRegisterTasks
UNION
SELECT     *
FROM         vwInvoiceRegisterItems
GO
CREATE OR ALTER  VIEW dbo.vwCashCodeInvoiceSummary
 AS
SELECT     CashCode, StartOn, ABS(SUM(InvoiceValue)) AS InvoiceValue, ABS(SUM(TaxValue)) AS TaxValue
FROM         dbo.vwInvoiceRegisterDetail
GROUP BY StartOn, CashCode
GO
CREATE OR ALTER  VIEW dbo.vwCashCodePaymentSummary
 AS
SELECT     CashCode, dbo.fnAccountPeriod(PaidOn) AS StartOn, SUM(PaidInValue + PaidOutValue) AS CashValue, SUM(TaxInValue + TaxOutValue) 
                      AS CashTax
FROM         dbo.tbOrgPayment
GROUP BY CashCode, dbo.fnAccountPeriod(PaidOn)
GO
CREATE OR ALTER  VIEW [dbo].[vwCashPolarData]
  AS
SELECT     dbo.tbCashPeriod.CashCode, dbo.tbCashCategory.CashTypeCode, dbo.tbCashPeriod.StartOn, dbo.tbCashPeriod.ForecastValue, 
                      dbo.tbCashPeriod.ForecastTax, dbo.tbCashPeriod.CashValue, dbo.tbCashPeriod.CashTax, dbo.tbCashPeriod.InvoiceValue, 
                      dbo.tbCashPeriod.InvoiceTax
FROM         dbo.tbCashPeriod INNER JOIN
                      dbo.tbCashCode ON dbo.tbCashPeriod.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.tbCashPeriod.StartOn = dbo.tbSystemYearPeriod.StartOn INNER JOIN
                      dbo.tbSystemYear ON dbo.tbSystemYearPeriod.YearNumber = dbo.tbSystemYear.YearNumber INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode
WHERE     (dbo.tbSystemYear.CashStatusCode < 4)
GO
CREATE OR ALTER  VIEW [dbo].[vwCashFlowForecastData]
   AS
SELECT     dbo.vwCashPolarData.CashCode, dbo.vwCashPolarData.CashTypeCode, dbo.vwCashPolarData.StartOn, dbo.vwCashPolarData.ForecastValue, 
                      dbo.vwCashPolarData.ForecastTax
FROM         dbo.vwCashPolarData INNER JOIN
                      dbo.fnSystemActivePeriod() fnSystemActivePeriod ON dbo.vwCashPolarData.StartOn >= fnSystemActivePeriod.StartOn
GO
CREATE OR ALTER  VIEW [dbo].[vwCashFlowActualData]
  AS
SELECT     dbo.vwCashPolarData.CashCode, dbo.vwCashPolarData.CashTypeCode, dbo.vwCashPolarData.StartOn, dbo.vwCashPolarData.CashValue, 
                      dbo.vwCashPolarData.CashTax, dbo.vwCashPolarData.InvoiceValue, dbo.vwCashPolarData.InvoiceTax, dbo.vwCashPolarData.ForecastValue, 
                      dbo.vwCashPolarData.ForecastTax
FROM         dbo.vwCashPolarData INNER JOIN
                      dbo.fnSystemActivePeriod() fnSystemActivePeriod ON dbo.vwCashPolarData.StartOn < fnSystemActivePeriod.StartOn
GO
CREATE OR ALTER  VIEW [dbo].[vwCashFlowData]
  AS
SELECT     CashCode, CashTypeCode, StartOn, CashValue, CashTax, InvoiceValue, InvoiceTax, ForecastValue, ForecastTax
FROM         dbo.vwCashFlowActualData
UNION
SELECT     CashCode, CashTypeCode, StartOn, ForecastValue AS CashValue, ForecastTax AS CashTax, ForecastValue AS InvoiceValue, 
                      ForecastTax AS InvoiceTax, ForecastValue, ForecastTax
FROM         dbo.vwCashFlowForecastData
GO
CREATE OR ALTER  VIEW [dbo].[vwCashEmployerNITotals]
 AS
SELECT     dbo.vwCashFlowData.StartOn, SUM(dbo.vwCashFlowData.CashTax) AS CashTaxNI, SUM(dbo.vwCashFlowData.InvoiceTax) AS InvoiceTaxNI
FROM         dbo.vwCashFlowData INNER JOIN
                      dbo.tbCashCode ON dbo.vwCashFlowData.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbCashCode.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 3)
GROUP BY dbo.vwCashFlowData.StartOn
GO
CREATE OR ALTER  VIEW dbo.vwCashFlowNITotals
 AS
SELECT     dbo.tbCashPeriod.StartOn, SUM(dbo.tbCashPeriod.ForecastTax) AS ForecastNI, SUM(dbo.tbCashPeriod.CashTax) AS CashNI, 
                      SUM(dbo.tbCashPeriod.InvoiceTax) AS InvoiceNI
FROM         dbo.tbCashPeriod INNER JOIN
                      dbo.tbCashCode ON dbo.tbCashPeriod.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbCashCode.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 3)
GROUP BY dbo.tbCashPeriod.StartOn
GO
CREATE OR ALTER  VIEW dbo.vwCashFlowVatTotalsBase
 AS
SELECT     dbo.tbCashPeriod.StartOn, dbo.tbCashCategory.CashModeCode, 
                      CASE WHEN tbCashCategory.CashModeCode = 2 THEN SUM(dbo.tbCashPeriod.ForecastTax) ELSE SUM(dbo.tbCashPeriod.ForecastTax) 
                      * - 1 END AS ForecastVat, CASE WHEN tbCashCategory.CashModeCode = 2 THEN SUM(dbo.tbCashPeriod.CashTax) 
                      ELSE SUM(dbo.tbCashPeriod.CashTax) * - 1 END AS CashVat, 
                      CASE WHEN tbCashCategory.CashModeCode = 2 THEN SUM(dbo.tbCashPeriod.InvoiceTax) ELSE SUM(dbo.tbCashPeriod.InvoiceTax) 
                      * - 1 END AS InvoiceVat
FROM         dbo.tbCashPeriod INNER JOIN
                      dbo.tbCashCode ON dbo.tbCashPeriod.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbCashCode.TaxCode = dbo.tbSystemTaxCode.TaxCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 2)
GROUP BY dbo.tbCashPeriod.StartOn, dbo.tbCashCategory.CashModeCode
GO
CREATE OR ALTER  VIEW dbo.vwCashFlowVatTotals
 AS
SELECT     StartOn, SUM(ForecastVat) AS ForecastVat, SUM(CashVat) AS CashVat, SUM(InvoiceVat) AS InvoiceVat
FROM         dbo.vwCashFlowVatTotalsBase
GROUP BY StartOn
GO
CREATE OR ALTER  VIEW [dbo].[vwCashPeriods]
  AS
SELECT     dbo.tbCashCode.CashCode, dbo.tbSystemYearPeriod.StartOn
FROM         dbo.tbSystemYearPeriod CROSS JOIN
                      dbo.tbCashCode
GO
CREATE OR ALTER  VIEW [dbo].[vwTaskInvoicedQuantity]
 AS
SELECT     dbo.tbInvoiceTask.TaskCode, SUM(dbo.tbInvoiceTask.Quantity) AS InvoiceQuantity
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber
WHERE     (dbo.tbInvoice.InvoiceTypeCode = 1) OR
                      (dbo.tbInvoice.InvoiceTypeCode = 3)
GROUP BY dbo.tbInvoiceTask.TaskCode
GO
CREATE OR ALTER  VIEW dbo.vwCorpTaxConfirmedBase
 AS
SELECT     TOP 100 PERCENT dbo.fnAccountPeriod(dbo.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * - 1 ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) END AS OrderValue
FROM         dbo.vwTaskInvoicedQuantity RIGHT OUTER JOIN
                      dbo.fnNetProfitCashCodes() fnNetProfitCashCodes INNER JOIN
                      dbo.tbCashCategory INNER JOIN
                      dbo.tbCashCode ON dbo.tbCashCategory.CategoryCode  = dbo.tbCashCode.CategoryCode  ON 
                      fnNetProfitCashCodes.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbTask ON fnNetProfitCashCodes.CashCode = dbo.tbTask.CashCode ON dbo.vwTaskInvoicedQuantity.TaskCode = dbo.tbTask.TaskCode
WHERE     (dbo.tbTask.TaskStatusCode > 1) AND (dbo.tbTask.TaskStatusCode < 4) AND 
                      (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0) > 0)
GO
CREATE OR ALTER  VIEW dbo.vwCorpTaxConfirmed
 AS
SELECT     dbo.vwCorpTaxConfirmedBase.StartOn, SUM(dbo.vwCorpTaxConfirmedBase.OrderValue) AS NetProfit, 
                      SUM(dbo.vwCorpTaxConfirmedBase.OrderValue * dbo.tbSystemYearPeriod.CorporationTaxRate) AS CorporationTax
FROM         dbo.vwCorpTaxConfirmedBase INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.vwCorpTaxConfirmedBase.StartOn = dbo.tbSystemYearPeriod.StartOn
GROUP BY dbo.vwCorpTaxConfirmedBase.StartOn
GO
CREATE OR ALTER  VIEW dbo.vwCorpTaxInvoiceItems
 AS
SELECT     TOP 100 PERCENT dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.InvoiceValue * - 1 ELSE dbo.tbInvoiceItem.InvoiceValue END AS InvoiceValue
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.fnNetProfitCashCodes() fnNetProfitCashCodes ON 
                      dbo.tbInvoiceItem.CashCode = fnNetProfitCashCodes.CashCode INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
GO
CREATE OR ALTER  VIEW dbo.vwCorpTaxInvoiceTasks
 AS
SELECT     TOP 100 PERCENT dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.InvoiceValue * - 1 ELSE dbo.tbInvoiceTask.InvoiceValue END AS InvoiceValue
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.fnNetProfitCashCodes() fnNetProfitCashCodes ON 
                      dbo.tbInvoiceTask.CashCode = fnNetProfitCashCodes.CashCode INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
GO
CREATE OR ALTER  VIEW dbo.vwCorpTaxInvoiceBase
 AS
SELECT     StartOn, SUM(InvoiceValue) AS NetProfit
FROM         dbo.vwCorpTaxInvoiceItems
GROUP BY StartOn
UNION
SELECT     StartOn, SUM(InvoiceValue) AS NetProfit
FROM         dbo.vwCorpTaxInvoiceTasks
GROUP BY StartOn
GO
CREATE OR ALTER  VIEW dbo.vwCorpTaxInvoice
 AS
SELECT     TOP 100 PERCENT dbo.tbSystemYearPeriod.StartOn, dbo.vwCorpTaxInvoiceBase.NetProfit, 
                      dbo.vwCorpTaxInvoiceBase.NetProfit * dbo.tbSystemYearPeriod.CorporationTaxRate AS CorporationTax
FROM         dbo.vwCorpTaxInvoiceBase INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.vwCorpTaxInvoiceBase.StartOn = dbo.tbSystemYearPeriod.StartOn
ORDER BY dbo.tbSystemYearPeriod.StartOn
GO
CREATE OR ALTER  VIEW dbo.vwCorpTaxTasksBase
 AS
SELECT     TOP 100 PERCENT dbo.fnAccountPeriod(dbo.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * - 1 ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) END AS OrderValue
FROM         dbo.vwTaskInvoicedQuantity RIGHT OUTER JOIN
                      dbo.fnNetProfitCashCodes() fnNetProfitCashCodes INNER JOIN
                      dbo.tbCashCategory INNER JOIN
                      dbo.tbCashCode ON dbo.tbCashCategory.CategoryCode = dbo.tbCashCode.CategoryCode ON 
                      fnNetProfitCashCodes.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbTask ON fnNetProfitCashCodes.CashCode = dbo.tbTask.CashCode ON dbo.vwTaskInvoicedQuantity.TaskCode = dbo.tbTask.TaskCode
WHERE     (dbo.tbTask.TaskStatusCode < 4) AND (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0) > 0)
GO
CREATE OR ALTER  VIEW dbo.vwCorpTaxTasks
 AS
SELECT     dbo.vwCorpTaxTasksBase.StartOn, SUM(dbo.vwCorpTaxTasksBase.OrderValue) AS NetProfit, 
                      dbo.vwCorpTaxTasksBase.OrderValue * dbo.tbSystemYearPeriod.CorporationTaxRate AS CorporationTax
FROM         dbo.vwCorpTaxTasksBase INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.vwCorpTaxTasksBase.StartOn = dbo.tbSystemYearPeriod.StartOn
GROUP BY dbo.vwCorpTaxTasksBase.StartOn, dbo.vwCorpTaxTasksBase.OrderValue * dbo.tbSystemYearPeriod.CorporationTaxRate
GO
CREATE OR ALTER  VIEW dbo.vwInvoiceOutstandingItems
 AS
SELECT     InvoiceNumber, '' AS TaskCode, CashCode, TaxCode, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS OutstandingValue, 
                      CASE WHEN InvoiceValue = 0 THEN 0 ELSE TaxValue / InvoiceValue END AS TaxRate
FROM         dbo.tbInvoiceItem
GO
CREATE OR ALTER  VIEW dbo.vwInvoiceOutstandingTasks
 AS
SELECT     InvoiceNumber, TaskCode, CashCode, TaxCode, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS OutstandingValue, 
                      CASE WHEN InvoiceValue = 0 THEN 0 ELSE TaxValue / InvoiceValue END AS TaxRate
FROM         dbo.tbInvoiceTask
GO
CREATE OR ALTER  VIEW dbo.vwInvoiceOutstandingBase
 AS
SELECT     InvoiceNumber AS InvoiceNumber, TaskCode AS TaskCode, 
                      CashCode AS CashCode, TaxCode AS TaxCode, OutstandingValue, TaxRate
FROM         dbo.vwInvoiceOutstandingItems
UNION
SELECT     InvoiceNumber AS InvoiceNumber, TaskCode AS TaskCode, 
                      CashCode AS CashCode, TaxCode AS TaxCode, OutstandingValue, TaxRate
FROM         dbo.vwInvoiceOutstandingTasks
GO
CREATE OR ALTER  VIEW dbo.vwInvoiceOutstanding
 AS
SELECT     TOP 100 PERCENT dbo.tbInvoice.AccountCode, dbo.tbInvoice.InvoicedOn, dbo.tbInvoice.InvoiceNumber, dbo.vwInvoiceOutstandingBase.TaskCode, 
                      dbo.tbInvoice.InvoiceStatusCode, dbo.tbInvoiceType.CashModeCode, dbo.vwInvoiceOutstandingBase.CashCode, 
                      dbo.vwInvoiceOutstandingBase.TaxCode, dbo.vwInvoiceOutstandingBase.TaxRate, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN OutstandingValue * - 1 ELSE OutstandingValue END AS ItemValue
FROM         dbo.vwInvoiceOutstandingBase INNER JOIN
                      dbo.tbInvoice ON dbo.vwInvoiceOutstandingBase.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
WHERE     (dbo.tbInvoice.InvoiceStatusCode = 2 OR
                      dbo.tbInvoice.InvoiceStatusCode = 3)
GO
CREATE OR ALTER  VIEW [dbo].[vwInvoiceRegister]
 AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoice.InvoiceNumber, dbo.tbInvoice.AccountCode, dbo.tbInvoice.InvoiceTypeCode, 
                      dbo.tbInvoice.InvoiceStatusCode, dbo.tbInvoice.InvoicedOn, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoice.InvoiceValue * - 1 ELSE dbo.tbInvoice.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoice.TaxValue * - 1 ELSE dbo.tbInvoice.TaxValue END AS TaxValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoice.PaidValue * - 1 ELSE dbo.tbInvoice.PaidValue END AS PaidValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoice.PaidTaxValue * - 1 ELSE dbo.tbInvoice.PaidTaxValue END AS PaidTaxValue, 
                      dbo.tbInvoice.PaymentTerms, dbo.tbInvoice.Notes, dbo.tbInvoice.Printed, dbo.tbOrg.AccountName, dbo.tbUser.UserName, 
                      dbo.tbInvoiceStatus.InvoiceStatus, dbo.tbInvoiceType.CashModeCode, dbo.tbInvoiceType.InvoiceType
FROM         dbo.tbInvoice INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode INNER JOIN
                      dbo.tbInvoiceStatus ON dbo.tbInvoice.InvoiceStatusCode = dbo.tbInvoiceStatus.InvoiceStatusCode INNER JOIN
                      dbo.tbUser ON dbo.tbInvoice.UserId = dbo.tbUser.UserId
GO
CREATE OR ALTER  VIEW [dbo].[vwInvoiceVatTasks]
 AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoice.InvoiceTypeCode, dbo.tbInvoiceTask.TaxCode, 
                      dbo.tbInvoiceTask.InvoiceValue, dbo.tbInvoiceTask.TaxValue, dbo.tbOrg.ForeignJurisdiction
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbInvoiceTask.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 2)
GO
CREATE OR ALTER  VIEW dbo.vwInvoiceVatItems
 AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoice.InvoiceTypeCode, dbo.tbInvoiceItem.TaxCode, 
                      dbo.tbInvoiceItem.InvoiceValue, dbo.tbInvoiceItem.TaxValue, dbo.tbOrg.ForeignJurisdiction
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbInvoiceItem.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 2)
GO
CREATE OR ALTER  VIEW [dbo].[vwInvoiceVatBase]
 AS
SELECT     *
FROM         dbo.vwInvoiceVatTasks
UNION
SELECT     *
FROM         dbo.vwInvoiceVatItems
GO
CREATE OR ALTER  VIEW [dbo].[vwInvoiceSummaryTasks]
 AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN tbInvoice.InvoiceTypeCode = 2 THEN 1 ELSE CASE WHEN tbInvoice.InvoiceTypeCode = 4 THEN 3 ELSE tbInvoice.InvoiceTypeCode END END
                       AS InvoiceTypeCode, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.InvoiceValue * - 1 ELSE dbo.tbInvoiceTask.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.TaxValue * - 1 ELSE dbo.tbInvoiceTask.TaxValue END AS TaxValue
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
GO
CREATE OR ALTER  VIEW [dbo].[vwInvoiceSummaryItems]
 AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN tbInvoice.InvoiceTypeCode = 2 THEN 1 ELSE CASE WHEN tbInvoice.InvoiceTypeCode = 4 THEN 3 ELSE tbInvoice.InvoiceTypeCode END END
                       AS InvoiceTypeCode, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.InvoiceValue * - 1 ELSE dbo.tbInvoiceItem.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.TaxValue * - 1 ELSE dbo.tbInvoiceItem.TaxValue END AS TaxValue
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
GO
CREATE OR ALTER  VIEW [dbo].[vwInvoiceSummaryBase]
 AS
SELECT  *   
FROM   dbo.vwInvoiceSummaryTasks
UNION
SELECT *
FROM dbo.vwInvoiceSummaryItems   
GO
CREATE OR ALTER  VIEW [dbo].[vwInvoiceSummaryTotals]
 AS
SELECT     dbo.vwInvoiceSummaryBase.StartOn, dbo.vwInvoiceSummaryBase.InvoiceTypeCode, dbo.tbInvoiceType.InvoiceType, 
                      SUM(dbo.vwInvoiceSummaryBase.InvoiceValue) AS TotalInvoiceValue, SUM(dbo.vwInvoiceSummaryBase.TaxValue) AS TotalTaxValue
FROM         dbo.vwInvoiceSummaryBase INNER JOIN
                      dbo.tbInvoiceType ON dbo.vwInvoiceSummaryBase.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
GROUP BY dbo.vwInvoiceSummaryBase.StartOn, dbo.vwInvoiceSummaryBase.InvoiceTypeCode, dbo.tbInvoiceType.InvoiceType
GO
CREATE OR ALTER  VIEW [dbo].[vwInvoiceSummaryMargin]
 AS
SELECT     StartOn, 5 AS InvoiceTypeCode, dbo.fnSystemProfileText(3004) AS InvoiceType, SUM(TotalInvoiceValue) AS TotalInvoiceValue, SUM(TotalTaxValue) 
                      AS TotalTaxValue
FROM         dbo.vwInvoiceSummaryTotals
GROUP BY StartOn
GO
CREATE OR ALTER  VIEW [dbo].[vwInvoiceSummary]
 AS
SELECT     DATENAME(yyyy, StartOn) + '/' + CAST(dbo.fnPad(MONTH(StartOn), 2) AS nvarchar) AS PeriodOn, StartOn, 
                      InvoiceTypeCode, InvoiceType AS InvoiceType, ABS(TotalInvoiceValue) AS TotalInvoiceValue, ABS(TotalTaxValue) AS TotalTaxValue
FROM         dbo.vwInvoiceSummaryTotals
UNION
SELECT     DATENAME(yyyy, StartOn) + '/' + CAST(dbo.fnPad(MONTH(StartOn), 2) AS nvarchar) AS PeriodOn, StartOn, 
                      InvoiceTypeCode, InvoiceType AS InvoiceType, ABS(TotalInvoiceValue) AS TotalInvoiceValue, ABS(TotalTaxValue) AS TotalTaxValue
FROM         dbo.vwInvoiceSummaryMargin
GO
CREATE OR ALTER  VIEW [dbo].[vwInvoiceTaxBase]
 AS
SELECT     InvoiceNumber, TaxCode, SUM(InvoiceValue) AS InvoiceValueTotal, SUM(TaxValue) AS TaxValueTotal
FROM         dbo.tbInvoiceItem
GROUP BY InvoiceNumber, TaxCode
HAVING      (NOT (TaxCode IS NULL))
UNION
SELECT     InvoiceNumber, TaxCode, SUM(InvoiceValue) AS InvoiceValueTotal, SUM(TaxValue) AS TaxValueTotal
FROM         dbo.tbInvoiceTask
GROUP BY InvoiceNumber, TaxCode
HAVING      (NOT (TaxCode IS NULL))
GO
CREATE OR ALTER  VIEW [dbo].[vwInvoiceTaxSummary]
 AS
SELECT     InvoiceNumber, TaxCode, SUM(InvoiceValueTotal) AS InvoiceValueTotal, SUM(TaxValueTotal) AS TaxValueTotal, SUM(TaxValueTotal) 
                      / SUM(InvoiceValueTotal) AS TaxRate
FROM         dbo.vwInvoiceTaxBase
GROUP BY InvoiceNumber, TaxCode
GO
CREATE OR ALTER  VIEW [dbo].[vwInvoiceVatDetail]
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
CREATE OR ALTER  VIEW [dbo].[vwInvoiceVatSummary]
 AS
SELECT     StartOn, TaxCode, SUM(HomeSales) AS HomeSales, SUM(HomePurchases) AS HomePurchases, SUM(ExportSales) AS ExportSales, 
                      SUM(ExportPurchases) AS ExportPurchases, SUM(HomeSalesVat) AS HomeSalesVat, SUM(HomePurchasesVat) AS HomePurchasesVat, 
                      SUM(ExportSalesVat) AS ExportSalesVat, SUM(ExportPurchasesVat) AS ExportPurchasesVat
FROM         dbo.vwInvoiceVatDetail
GROUP BY StartOn, TaxCode
GO
CREATE OR ALTER  VIEW dbo.vwOrgMailContacts
 AS
SELECT     AccountCode, ContactName, NickName, NameTitle + N' ' + ContactName AS FormalName, JobTitle, Department
FROM         dbo.tbOrgContact
WHERE     (OnMailingList <> 0)
GO
CREATE OR ALTER  VIEW dbo.vwOrgAddresses
 AS
SELECT     TOP 100 PERCENT dbo.tbOrg.AccountName, dbo.tbOrgAddress.Address, dbo.tbOrg.OrganisationTypeCode, dbo.tbOrg.OrganisationStatusCode, 
                      dbo.tbOrgType.OrganisationType, dbo.tbOrgStatus.OrganisationStatus, dbo.vwOrgMailContacts.ContactName, dbo.vwOrgMailContacts.NickName, 
                      dbo.vwOrgMailContacts.FormalName, dbo.vwOrgMailContacts.JobTitle, dbo.vwOrgMailContacts.Department
FROM         dbo.tbOrg INNER JOIN
                      dbo.tbOrgAddress ON dbo.tbOrg.AddressCode = dbo.tbOrgAddress.AddressCode INNER JOIN
                      dbo.tbOrgType ON dbo.tbOrg.OrganisationTypeCode = dbo.tbOrgType.OrganisationTypeCode INNER JOIN
                      dbo.tbOrgStatus ON dbo.tbOrg.OrganisationStatusCode = dbo.tbOrgStatus.OrganisationStatusCode LEFT OUTER JOIN
                      dbo.vwOrgMailContacts ON dbo.tbOrg.AccountCode = dbo.vwOrgMailContacts.AccountCode
ORDER BY dbo.tbOrg.AccountName
GO
CREATE OR ALTER  VIEW [dbo].[vwOrgBalanceOutstanding]
 AS
SELECT     dbo.tbInvoice.AccountCode, SUM(CASE dbo.tbInvoiceType.CashModeCode WHEN 1 THEN ((InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue)) 
                      * - 1 WHEN 2 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) END) AS Balance
FROM         dbo.tbInvoice INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
WHERE     (dbo.tbInvoice.InvoiceStatusCode > 1 AND dbo.tbInvoice.InvoiceStatusCode < 4)
GROUP BY dbo.tbInvoice.AccountCode
GO
CREATE OR ALTER  VIEW dbo.vwOrgTaskCount
 AS
SELECT     AccountCode, COUNT(TaskCode) AS TaskCount
FROM         dbo.tbTask
WHERE     (TaskStatusCode < 3)
GROUP BY AccountCode
GO
CREATE OR ALTER   VIEW dbo.vwOrgDatasheet
 AS
SELECT     dbo.tbOrg.AccountCode, dbo.tbOrg.AccountName, ISNULL(dbo.vwOrgTaskCount.TaskCount, 0) AS Tasks, dbo.tbOrg.OrganisationTypeCode, 
                      dbo.tbOrgType.OrganisationType, dbo.tbOrgType.CashModeCode, dbo.tbOrg.OrganisationStatusCode, dbo.tbOrgStatus.OrganisationStatus, 
                      dbo.tbOrgAddress.Address, dbo.tbSystemTaxCode.TaxDescription, dbo.tbOrg.TaxCode, dbo.tbOrg.AddressCode, dbo.tbOrg.AreaCode, 
                      dbo.tbOrg.PhoneNumber, dbo.tbOrg.FaxNumber, dbo.tbOrg.EmailAddress, dbo.tbOrg.WebSite, dbo.fnOrgIndustrySectors(dbo.tbOrg.AccountCode) 
                      AS IndustrySector, dbo.tbOrg.AccountSource, dbo.tbOrg.PaymentTerms, dbo.tbOrg.PaymentDays, dbo.tbOrg.NumberOfEmployees, 
                      dbo.tbOrg.CompanyNumber, dbo.tbOrg.VatNumber, dbo.tbOrg.Turnover, dbo.tbOrg.StatementDays, dbo.tbOrg.OpeningBalance, 
                      dbo.tbOrg.CurrentBalance, dbo.tbOrg.ForeignJurisdiction, dbo.tbOrg.BusinessDescription, dbo.tbOrg.InsertedBy, dbo.tbOrg.InsertedOn, 
                      dbo.tbOrg.UpdatedBy, dbo.tbOrg.UpdatedOn
FROM         dbo.tbOrg INNER JOIN
                      dbo.tbOrgStatus ON dbo.tbOrg.OrganisationStatusCode = dbo.tbOrgStatus.OrganisationStatusCode INNER JOIN
                      dbo.tbOrgType ON dbo.tbOrg.OrganisationTypeCode = dbo.tbOrgType.OrganisationTypeCode LEFT OUTER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbOrg.TaxCode = dbo.tbSystemTaxCode.TaxCode LEFT OUTER JOIN
                      dbo.tbOrgAddress ON dbo.tbOrg.AddressCode = dbo.tbOrgAddress.AddressCode LEFT OUTER JOIN
                      dbo.vwOrgTaskCount ON dbo.tbOrg.AccountCode = dbo.vwOrgTaskCount.AccountCode
GO
CREATE OR ALTER  VIEW dbo.vwOrgRebuildInvoicedItems
AS
SELECT     dbo.tbInvoice.AccountCode, dbo.tbInvoiceType.CashModeCode, dbo.tbInvoice.InvoicedOn, dbo.tbInvoiceItem.InvoiceNumber, 
                      dbo.tbInvoiceItem.CashCode, '' AS TaskCode, dbo.tbInvoiceItem.InvoiceValue, dbo.tbInvoiceItem.TaxValue, dbo.tbInvoiceItem.PaidValue, 
                      dbo.tbInvoiceItem.PaidTaxValue
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
GO
CREATE OR ALTER  VIEW dbo.vwOrgRebuildInvoicedTasks
AS
SELECT     dbo.tbInvoice.AccountCode, dbo.tbInvoiceType.CashModeCode, dbo.tbInvoice.InvoicedOn, dbo.tbInvoiceTask.InvoiceNumber, 
                      dbo.tbInvoiceTask.CashCode, dbo.tbInvoiceTask.TaskCode, dbo.tbInvoiceTask.InvoiceValue, dbo.tbInvoiceTask.TaxValue, 
                      dbo.tbInvoiceTask.PaidValue, dbo.tbInvoiceTask.PaidTaxValue
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
GO
CREATE OR ALTER  VIEW dbo.vwOrgRebuildInvoices
AS
SELECT     dbo.vwOrgRebuildInvoicedTasks.*
FROM         dbo.vwOrgRebuildInvoicedTasks
UNION
SELECT     dbo.vwOrgRebuildInvoicedItems.*
FROM         dbo.vwOrgRebuildInvoicedItems
GO
CREATE OR ALTER  VIEW dbo.vwOrgRebuildInvoiceTotals
AS
SELECT     AccountCode, InvoiceNumber, SUM(InvoiceValue) AS TotalInvoiceValue, SUM(TaxValue) AS TotalTaxValue, SUM(PaidValue) AS TotalPaidValue, 
                      SUM(PaidTaxValue) AS TotalPaidTaxValue
FROM         dbo.vwOrgRebuildInvoices
GROUP BY AccountCode, InvoiceNumber
GO
CREATE OR ALTER  VIEW dbo.vwStatementInvoices
 AS
SELECT     TOP 100 PERCENT dbo.vwCashSummaryInvoices.InvoiceNumber AS ReferenceCode, dbo.tbInvoice.AccountCode, 
                      dbo.tbInvoice.CollectOn AS TransactOn, 2 AS CashEntryTypeCode, ABS(dbo.vwCashSummaryInvoices.ToCollect) AS PayIn, 
                      ABS(dbo.vwCashSummaryInvoices.ToPay) AS PayOut
FROM         dbo.vwCashSummaryInvoices INNER JOIN
                      dbo.tbInvoice ON dbo.vwCashSummaryInvoices.InvoiceNumber = dbo.tbInvoice.InvoiceNumber
ORDER BY dbo.tbInvoice.CollectOn, dbo.tbInvoice.AccountCode
GO
CREATE OR ALTER  VIEW dbo.vwStatementTasksConfirmed
 AS
SELECT     TOP 100 PERCENT dbo.tbTask.TaskCode AS ReferenceCode, dbo.tbTask.AccountCode, dbo.tbTask.PaymentOn AS TransactOn, 3 AS CashEntryTypeCode, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.tbSystemTaxCode.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayOut, 
                      CASE WHEN tbCashCategory.CashModeCode = 2 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.tbSystemTaxCode.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayIn
FROM         dbo.tbSystemTaxCode INNER JOIN
                      dbo.tbTask ON dbo.tbSystemTaxCode.TaxCode = dbo.tbTask.TaxCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.tbTask.TaskStatusCode > 1) AND (dbo.tbTask.TaskStatusCode < 4) AND 
                      (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0) > 0)
ORDER BY dbo.tbTask.PaymentOn
GO
CREATE OR ALTER  VIEW dbo.vwStatementTasksFull
 AS
SELECT     TOP 100 PERCENT dbo.tbTask.TaskCode AS ReferenceCode, dbo.tbTask.AccountCode, dbo.tbTask.PaymentOn AS TransactOn, 
                      CASE WHEN tbTask.TaskStatusCode = 1 THEN 4 ELSE 3 END AS CashEntryTypeCode, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.tbSystemTaxCode.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayOut, 
                      CASE WHEN tbCashCategory.CashModeCode = 2 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.tbSystemTaxCode.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayIn
FROM         dbo.tbSystemTaxCode INNER JOIN
                      dbo.tbTask ON dbo.tbSystemTaxCode.TaxCode = dbo.tbTask.TaxCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.tbTask.TaskStatusCode < 4) AND (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0) > 0)
ORDER BY dbo.tbTask.PaymentOn, CASE WHEN tbTask.TaskStatusCode = 1 THEN 4 ELSE 3 END
GO
CREATE OR ALTER  VIEW dbo.vwStatementVatDueDate
 AS
SELECT     TOP 1 PayOn
FROM         dbo.fnTaxTypeDueDates(2) fnTaxTypeDueDates
WHERE     (PayOn > GETDATE())
GO
CREATE OR ALTER  VIEW dbo.vwSystemCorpTaxCashCode
 AS
SELECT     CashCode, MonthNumber, RecurrenceCode
FROM         dbo.tbCashTaxType
WHERE     (TaxTypeCode = 1)
GO
CREATE OR ALTER  VIEW dbo.vwSystemNICashCode
 AS
SELECT     CashCode, MonthNumber, RecurrenceCode
FROM         dbo.tbCashTaxType
WHERE     (TaxTypeCode = 3)
GO
CREATE OR ALTER  VIEW dbo.vwSystemVatCashCode
 AS
SELECT     CashCode, MonthNumber, RecurrenceCode
FROM         dbo.tbCashTaxType
WHERE     (TaxTypeCode = 2)
GO
CREATE OR ALTER  VIEW [dbo].[vwTaskBucket]
 AS
SELECT     TaskCode, dbo.fnSystemDateBucket(GETDATE(), ActionOn) AS Period
FROM         dbo.tbTask
GO
CREATE OR ALTER  VIEW [dbo].[vwTaskCashMode]
 AS
SELECT     dbo.tbTask.TaskCode, CASE WHEN tbCashCategory.CategoryCode IS NULL 
                      THEN tbOrgType.CashModeCode ELSE tbCashCategory.CashModeCode END AS CashModeCode
FROM         dbo.tbTask INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode INNER JOIN
                      dbo.tbOrg ON dbo.tbTask.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbOrgType ON dbo.tbOrg.OrganisationTypeCode = dbo.tbOrgType.OrganisationTypeCode
GO
CREATE OR ALTER  VIEW dbo.vwTaskVatConfirmed
 AS
SELECT     dbo.fnAccountPeriod(dbo.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * tbSystemTaxCode.TaxRate ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) 
                      * tbSystemTaxCode.TaxRate * - 1 END AS VatValue
FROM         dbo.tbTask INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbTask.TaxCode = dbo.tbSystemTaxCode.TaxCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 2) AND (dbo.tbTask.TaskStatusCode > 1) AND (dbo.tbTask.TaskStatusCode < 4) AND 
                      (CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * tbSystemTaxCode.TaxRate ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) 
                      * tbSystemTaxCode.TaxRate * - 1 END <> 0)
GO
CREATE OR ALTER  VIEW dbo.vwTaskVatFull
 AS
SELECT     dbo.fnAccountPeriod(dbo.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * tbSystemTaxCode.TaxRate ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) 
                      * tbSystemTaxCode.TaxRate * - 1 END AS VatValue
FROM         dbo.tbTask INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbTask.TaxCode = dbo.tbSystemTaxCode.TaxCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 2) AND (dbo.tbTask.TaskStatusCode < 4) AND 
                      (CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * tbSystemTaxCode.TaxRate ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) 
                      * tbSystemTaxCode.TaxRate * - 1 END <> 0)
GO
CREATE OR ALTER   VIEW [dbo].[vwTasks]
 AS
SELECT     dbo.tbTask.TaskCode, dbo.tbTask.UserId, dbo.tbTask.AccountCode, dbo.tbTask.ContactName, dbo.tbTask.ActivityCode, dbo.tbTask.TaskTitle, 
                      dbo.tbTask.TaskStatusCode, dbo.tbTask.ActionById, dbo.tbTask.ActionOn, dbo.tbTask.ActionedOn, dbo.tbTask.TaskNotes, dbo.tbTask.Quantity, 
                      dbo.tbTask.UnitCharge, dbo.tbTask.TotalCharge, dbo.tbTask.AddressCodeFrom, dbo.tbTask.AddressCodeTo, dbo.tbTask.Printed, 
                      dbo.tbTask.InsertedBy, dbo.tbTask.InsertedOn, dbo.tbTask.UpdatedBy, dbo.tbTask.UpdatedOn, dbo.vwTaskBucket.Period, 
                      dbo.tbSystemBucket.BucketId, dbo.tbTaskStatus.TaskStatus, dbo.tbTask.CashCode, dbo.tbCashCode.CashDescription, 
                      tbUser_1.UserName AS OwnerName, dbo.tbUser.UserName AS ActionName, dbo.tbOrg.AccountName, dbo.tbOrgStatus.OrganisationStatus, 
                      dbo.tbOrgType.OrganisationType, CASE WHEN tbCashCategory.CategoryCode IS NULL 
                      THEN tbOrgType.CashModeCode ELSE tbCashCategory.CashModeCode END AS CashModeCode
FROM         dbo.tbUser INNER JOIN
                      dbo.tbTaskStatus INNER JOIN
                      dbo.tbOrgType INNER JOIN
                      dbo.tbOrg ON dbo.tbOrgType.OrganisationTypeCode = dbo.tbOrg.OrganisationTypeCode INNER JOIN
                      dbo.tbOrgStatus ON dbo.tbOrg.OrganisationStatusCode = dbo.tbOrgStatus.OrganisationStatusCode INNER JOIN
                      dbo.tbTask ON dbo.tbOrg.AccountCode = dbo.tbTask.AccountCode ON dbo.tbTaskStatus.TaskStatusCode = dbo.tbTask.TaskStatusCode ON 
                      dbo.tbUser.UserId = dbo.tbTask.ActionById INNER JOIN
                      dbo.tbUser AS tbUser_1 ON dbo.tbTask.UserId = tbUser_1.UserId INNER JOIN
                      dbo.vwTaskBucket ON dbo.tbTask.TaskCode = dbo.vwTaskBucket.TaskCode INNER JOIN
                      dbo.tbSystemBucket ON dbo.vwTaskBucket.Period = dbo.tbSystemBucket.Period LEFT OUTER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode LEFT OUTER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode
GO
CREATE OR ALTER  FUNCTION dbo.fnTaxCorpTotals
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
CREATE OR ALTER  FUNCTION dbo.fnTaxCorpStatement
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
CREATE OR ALTER  VIEW dbo.vwTaxCorpStatement
 AS
SELECT     TOP 100 PERCENT fnTaxCorpStatement.*
FROM         dbo.fnTaxCorpStatement() fnTaxCorpStatement
ORDER BY StartOn, TaxDue
GO
CREATE OR ALTER  FUNCTION dbo.fnStatementCorpTax
	()
RETURNS @tbCorpTax TABLE (
	ReferenceCode nvarchar(20), 
	AccountCode nvarchar(10),
	TransactOn datetime,
	CashEntryTypeCode int,
	PayOut money,
	PayIn money
	)
 AS
	BEGIN
	declare @StartOn datetime
	declare @Balance money
	declare @TaxDue money
	
	declare curCorpTax cursor for
		SELECT     StartOn, TaxDue, Balance
		FROM         vwTaxCorpStatement
		WHERE TaxDue > 0
		ORDER BY StartOn DESC

	open curCorpTax
	
	fetch next from curCorpTax into @StartOn, @TaxDue, @Balance
	
	set @Balance = isnull(@Balance, 0)
	
	while ((@@FETCH_STATUS = 0) AND (@Balance > 0)) 
		begin					
		if (@TaxDue <> 0)
			begin
			insert into @tbCorpTax (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayOut, PayIn)
			values ('-', dbo.fnStatementTaxAccount(2), @StartOn, 5, @TaxDue, 0)						
			end

		fetch next from curCorpTax into @StartOn, @TaxDue, @Balance	
		end
		
	close curCorpTax
	deallocate curCorpTax
	
	RETURN
	END
GO
CREATE OR ALTER  VIEW dbo.vwTaxCorpTotals
 AS
SELECT     dbo.tbSystemYear.Description, dbo.tbSystemMonth.MonthName, dbo.vwCorpTaxInvoice.StartOn, dbo.vwCorpTaxInvoice.NetProfit, 
                      dbo.vwCorpTaxInvoice.CorporationTax
FROM         dbo.vwCorpTaxInvoice INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.vwCorpTaxInvoice.StartOn = dbo.tbSystemYearPeriod.StartOn INNER JOIN
                      dbo.tbSystemYear ON dbo.tbSystemYearPeriod.YearNumber = dbo.tbSystemYear.YearNumber INNER JOIN
                      dbo.tbSystemMonth ON dbo.tbSystemYearPeriod.MonthNumber = dbo.tbSystemMonth.MonthNumber
GO
CREATE OR ALTER  VIEW dbo.vwTaxVatStatement
 AS
SELECT     TOP 100 PERCENT *
FROM         dbo.fnTaxVatStatement() fnTaxVatStatement
ORDER BY StartOn, VatDue
GO
CREATE OR ALTER  VIEW dbo.vwTaxVatTotals
 AS
SELECT     TOP 100 PERCENT dbo.tbSystemYear.YearNumber, dbo.tbSystemYear.[Description], dbo.tbSystemMonth.MonthName, fnTaxVatTotals.StartOn, fnTaxVatTotals.HomeSales, 
                      fnTaxVatTotals.HomePurchases, fnTaxVatTotals.ExportSales, fnTaxVatTotals.ExportPurchases, fnTaxVatTotals.HomeSalesVat, 
                      fnTaxVatTotals.HomePurchasesVat, fnTaxVatTotals.ExportSalesVat, fnTaxVatTotals.ExportPurchasesVat, fnTaxVatTotals.VatDue
FROM         dbo.fnTaxVatTotals() fnTaxVatTotals INNER JOIN
                      dbo.tbSystemYearPeriod ON fnTaxVatTotals.StartOn = dbo.tbSystemYearPeriod.StartOn INNER JOIN
                      dbo.tbSystemMonth ON dbo.tbSystemYearPeriod.MonthNumber = dbo.tbSystemMonth.MonthNumber INNER JOIN
                      dbo.tbSystemYear ON dbo.tbSystemYearPeriod.YearNumber = dbo.tbSystemYear.YearNumber
ORDER BY fnTaxVatTotals.StartOn
GO
CREATE OR ALTER  PROCEDURE dbo.spActivityMode
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
CREATE OR ALTER  PROCEDURE [dbo].[spActivityNextAttributeOrder] 
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
CREATE OR ALTER  PROCEDURE [dbo].[spActivityNextStepNumber] 
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
CREATE OR ALTER  PROCEDURE dbo.spActivityParent
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
CREATE OR ALTER  PROCEDURE dbo.spActivityWorkFlow
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
CREATE OR ALTER  PROCEDURE dbo.spCashAccountRebuild
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
CREATE OR ALTER  PROCEDURE dbo.spCashAccountRebuildAll
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
CREATE OR ALTER  PROCEDURE dbo.spCashCategoryCashCodes
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
CREATE OR ALTER  PROCEDURE dbo.spCashCategoryCodeFromName
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
CREATE OR ALTER  PROCEDURE [dbo].[spCashCategoryTotals]
	(
	@CashTypeCode smallint
	)
  AS

	SELECT     tbCashCategory.DisplayOrder, tbCashCategory.Category, tbCashType.CashType, tbCashCategory.CategoryCode
	FROM         tbCashCategory INNER JOIN
	                      tbCashType ON tbCashCategory.CashTypeCode = tbCashType.CashTypeCode
	WHERE     (tbCashCategory.CashTypeCode = @CashTypeCode) AND (tbCashCategory.CategoryTypeCode = 2)
	ORDER BY tbCashCategory.DisplayOrder, tbCashCategory.Category
	
	RETURN 
GO
CREATE OR ALTER  PROCEDURE dbo.spCashCodeDefaults 
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
CREATE OR ALTER  PROCEDURE [dbo].[spCashCodeValues]
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
CREATE OR ALTER  PROCEDURE [dbo].[spCashCopyForecastToLiveCashCode]
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
CREATE OR ALTER  PROCEDURE dbo.spCashCopyForecastToLiveCategory
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
CREATE OR ALTER  PROCEDURE dbo.spCashCopyLiveToForecastCashCode
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
CREATE OR ALTER  PROCEDURE dbo.spCashCopyLiveToForecastCategory
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
CREATE OR ALTER   PROCEDURE dbo.spCashFlowInitialise
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
	WHERE     (tbCashCategory.ManualForecast = 0) AND (tbCashPeriod.StartOn >= @StartOn)
	
	UPDATE tbCashPeriod
	SET 
		ForecastValue = vwCashCodeForecastSummary.ForecastValue, 
		ForecastTax = vwCashCodeForecastSummary.ForecastTax
	FROM         tbCashPeriod INNER JOIN
	                      vwCashCodeForecastSummary ON tbCashPeriod.CashCode = vwCashCodeForecastSummary.CashCode AND 
	                      tbCashPeriod.StartOn = vwCashCodeForecastSummary.StartOn INNER JOIN
	                      tbCashCode ON tbCashPeriod.CashCode = tbCashCode.CashCode INNER JOIN
	                      tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE     (tbCashPeriod.StartOn >= @StartOn) AND (tbCashCategory.ManualForecast = 0)
	
	
	UPDATE tbCashPeriod
	SET ForecastValue = 0, 
	ForecastTax = 0, 
	CashValue = 0, 
	CashTax = 0, 
	InvoiceValue = 0, 
	InvoiceTax = 0
	FROM         tbCashPeriod INNER JOIN
	                      tbCashTaxType ON tbCashPeriod.CashCode = tbCashTaxType.CashCode


	UPDATE tbCashPeriod
	SET
		ForecastValue = vwCashFlowVatTotals.ForecastVat, 
		CashValue = vwCashFlowVatTotals.CashVat, 
		InvoiceValue = vwCashFlowVatTotals.InvoiceVat
	FROM         tbCashPeriod INNER JOIN
	                      vwCashFlowVatTotals ON tbCashPeriod.StartOn = vwCashFlowVatTotals.StartOn
	WHERE     (tbCashPeriod.CashCode = dbo.fnSystemCashCode(2))
	                      	

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
CREATE OR ALTER  PROCEDURE dbo.spCashGeneratePeriods
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
CREATE OR ALTER  PROCEDURE dbo.spCashVatBalance
	(
	@Balance money output
	)
 AS
	set @Balance = dbo.fnSystemVatBalance()
	RETURN 
GO
CREATE OR ALTER  PROCEDURE [dbo].[spInvoiceAccept] 
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
CREATE OR ALTER  PROCEDURE [dbo].[spInvoiceAddTask] 
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
CREATE OR ALTER  PROCEDURE [dbo].[spInvoiceCancel] 
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
CREATE OR ALTER  PROCEDURE dbo.spInvoiceCredit
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
CREATE OR ALTER   PROCEDURE dbo.spInvoiceRaise
	(
	@TaskCode nvarchar(20),
	@InvoiceTypeCode smallint,
	@InvoiceNumber nvarchar(20) = null output
	)
 AS
declare @UserId nvarchar(10)
declare @NextNumber int
declare @InvoiceSuffix nvarchar(4)
declare @PaymentDays smallint
declare @CollectOn datetime
declare @AccountCode nvarchar(10)

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
	
	set @CollectOn = DATEADD(d, @PaymentDays, GETDATE())
	exec dbo.spTaskDefaultPaymentOn @AccountCode, @CollectOn, @CollectOn output
	
	begin tran Invoice
	
	exec dbo.spInvoiceCancel
	
	UPDATE    tbInvoiceType
	SET              NextNumber = @NextNumber + 1
	WHERE     (InvoiceTypeCode = @InvoiceTypeCode)
	
	INSERT INTO tbInvoice
						(InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoicedOn, CollectOn, InvoiceStatusCode, PaymentTerms)
	SELECT     @InvoiceNumber AS InvoiceNumber, @UserId AS UserId, tbTask.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, GETDATE() AS InvoicedOn, 
						@CollectOn AS CollectOn, 1 AS InvoiceStatusCode, 
						tbOrg.PaymentTerms
	FROM         tbTask INNER JOIN
						tbOrg ON tbTask.AccountCode = tbOrg.AccountCode
	WHERE     (tbTask.TaskCode = @TaskCode)
	exec dbo.spInvoiceAddTask @InvoiceNumber, @TaskCode
	
	commit tran Invoice
	
	RETURN
GO
CREATE OR ALTER  PROCEDURE dbo.spInvoiceRaiseBlank
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
CREATE OR ALTER   PROCEDURE dbo.spInvoiceTotal 
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
	SET TaxValue = tbInvoiceTask.InvoiceValue * tbSystemTaxCode.TaxRate
	FROM         tbInvoiceTask INNER JOIN
	                      tbSystemTaxCode ON tbInvoiceTask.TaxCode = tbSystemTaxCode.TaxCode
	WHERE     (tbInvoiceTask.InvoiceNumber = @InvoiceNumber)

	UPDATE     tbInvoiceItem
	SET TaxValue = tbInvoiceItem.InvoiceValue * tbSystemTaxCode.TaxRate
	FROM         tbInvoiceItem INNER JOIN
	                      tbSystemTaxCode ON tbInvoiceItem.TaxCode = tbSystemTaxCode.TaxCode
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
CREATE OR ALTER  PROCEDURE [dbo].[spMenuInsert]
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
CREATE OR ALTER  PROCEDURE [dbo].[spOrgAddAddress] 
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
CREATE OR ALTER  PROCEDURE [dbo].[spOrgAddContact] 
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
CREATE OR ALTER  PROCEDURE dbo.spOrgBalanceOutstanding 
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
CREATE OR ALTER  PROCEDURE [dbo].[spOrgContactFileAs] 
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
CREATE OR ALTER  PROCEDURE [dbo].[spOrgDefaultAccountCode] 
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
CREATE OR ALTER  PROCEDURE [dbo].[spOrgDefaultTaxCode] 
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
CREATE OR ALTER  PROCEDURE [dbo].[spOrgNextAddressCode] 
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
CREATE OR ALTER  PROCEDURE dbo.spOrgRebuild
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
	set TaxValue = ROUND(tbInvoiceItem.InvoiceValue * tbSystemTaxCode.TaxRate, 2),
		PaidValue = tbInvoiceItem.InvoiceValue, 
		PaidTaxValue = ROUND(tbInvoiceItem.InvoiceValue * tbSystemTaxCode.TaxRate, 2)				
	FROM         tbInvoiceItem INNER JOIN
	                      tbSystemTaxCode ON tbInvoiceItem.TaxCode = tbSystemTaxCode.TaxCode INNER JOIN
	                      tbInvoice ON tbInvoiceItem.InvoiceNumber = tbInvoice.InvoiceNumber
	WHERE     (tbInvoice.AccountCode = @AccountCode) AND (tbInvoice.InvoiceStatusCode <> 1)	
                      
	update tbInvoiceTask
	set TaxValue = ROUND(tbInvoiceTask.InvoiceValue * tbSystemTaxCode.TaxRate, 2),
		PaidValue = tbInvoiceTask.InvoiceValue, PaidTaxValue = ROUND(tbInvoiceTask.InvoiceValue * tbSystemTaxCode.TaxRate, 2)
	FROM         tbInvoiceTask INNER JOIN
	                      tbSystemTaxCode ON tbInvoiceTask.TaxCode = tbSystemTaxCode.TaxCode INNER JOIN
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
		TaxInValue = PaidInValue - (PaidInValue / (1 + TaxRate)), 
		TaxOutValue = PaidOutValue - (PaidOutValue / (1 + TaxRate))
	FROM         tbOrgPayment INNER JOIN
	                      tbSystemTaxCode ON tbOrgPayment.TaxCode = tbSystemTaxCode.TaxCode
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
		ORDER BY InvoicedOn DESC
	

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
			set @PaidInvoiceValue = @PaidValue - (@PaidValue - (@PaidValue / (1 + @TaxRate)))
			set @PaidTaxValue = @PaidInvoiceValue * @TaxRate
			end
		else
			begin
			set @PaidInvoiceValue = 0
			set @PaidTaxValue = 0
			end
			
		if isnull(@TaskCode, '') = ''
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
CREATE OR ALTER  PROCEDURE dbo.spOrgStatement
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
CREATE OR ALTER  PROCEDURE dbo.spPaymentMove
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
CREATE OR ALTER  PROCEDURE dbo.spPaymentPost 
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
CREATE OR ALTER  PROCEDURE dbo.spPaymentPostInvoiced
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
CREATE OR ALTER   PROCEDURE dbo.spPaymentPostMisc
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
						4 AS InvoiceStatusCode, tbOrgPayment.PaidOn, 
												CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + tbSystemTaxCode.TaxRate) 
						WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + tbSystemTaxCode.TaxRate) END AS InvoiceValue, 
						CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - (tbOrgPayment.PaidInValue / (1 + tbSystemTaxCode.TaxRate)) 
						WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - (tbOrgPayment.PaidOutValue / (1 + tbSystemTaxCode.TaxRate)) 
						END AS TaxValue, CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + tbSystemTaxCode.TaxRate) 
						WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + tbSystemTaxCode.TaxRate) END AS PaidValue, 
						CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - (tbOrgPayment.PaidInValue / (1 + tbSystemTaxCode.TaxRate)) 
						WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - (tbOrgPayment.PaidOutValue / (1 + tbSystemTaxCode.TaxRate)) 
						END AS PaidTaxValue,
						1 AS Printed
	FROM         tbOrgPayment INNER JOIN
						tbSystemTaxCode ON tbOrgPayment.TaxCode = tbSystemTaxCode.TaxCode
	WHERE     (tbOrgPayment.PaymentCode = @PaymentCode)

	INSERT INTO tbInvoiceItem
						(InvoiceNumber, CashCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, TaxCode)
	SELECT     @InvoiceNumber AS InvoiceNumber, tbOrgPayment.CashCode, 
						CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + tbSystemTaxCode.TaxRate) 
						WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + tbSystemTaxCode.TaxRate) END AS InvoiceValue, 
						CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - (tbOrgPayment.PaidInValue / (1 + tbSystemTaxCode.TaxRate)) 
						WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - (tbOrgPayment.PaidOutValue / (1 + tbSystemTaxCode.TaxRate)) 
						END AS TaxValue, CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + tbSystemTaxCode.TaxRate) 
						WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + tbSystemTaxCode.TaxRate) END AS PaidValue, 
						CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - (tbOrgPayment.PaidInValue / (1 + tbSystemTaxCode.TaxRate)) 
						WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - (tbOrgPayment.PaidOutValue / (1 + tbSystemTaxCode.TaxRate)) 
						END AS PaidTaxValue, tbOrgPayment.TaxCode
	FROM         tbOrgPayment INNER JOIN
						tbSystemTaxCode ON tbOrgPayment.TaxCode = tbSystemTaxCode.TaxCode
	WHERE     (tbOrgPayment.PaymentCode = @PaymentCode)

	UPDATE  tbOrgAccount
	SET CurrentBalance = CASE WHEN PaidInValue > 0 THEN tbOrgAccount.CurrentBalance + PaidInValue ELSE tbOrgAccount.CurrentBalance - PaidOutValue END
	FROM         tbOrgAccount INNER JOIN
						  tbOrgPayment ON tbOrgAccount.CashAccountCode = tbOrgPayment.CashAccountCode
	WHERE tbOrgPayment.PaymentCode = @PaymentCode

	UPDATE    tbOrgPayment
	SET		PaymentStatusCode = 2,
		TaxInValue = PaidInValue - (PaidInValue / (1 + TaxRate)), 
		TaxOutValue = PaidOutValue - (PaidOutValue / (1 + TaxRate))
	FROM         tbOrgPayment INNER JOIN
	                      tbSystemTaxCode ON tbOrgPayment.TaxCode = tbSystemTaxCode.TaxCode
	WHERE     (PaymentCode = @PaymentCode)
	
	RETURN
GO
CREATE OR ALTER  PROCEDURE dbo.spPaymentPostPaidIn
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
		ORDER BY vwInvoiceOutstanding.CashModeCode, vwInvoiceOutstanding.InvoicedOn

	open curPaidIn
	fetch next from curPaidIn into @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue
	while @@FETCH_STATUS = 0 and @CurrentBalance < 0
		begin
		if (@CurrentBalance + @ItemValue) > 0
			set @ItemValue = @CurrentBalance * -1

		set @PaidValue = Abs(@ItemValue) / (1 + @TaxRate)
		set @PaidTaxValue = Abs(@ItemValue) - (Abs(@ItemValue) / (1 + @TaxRate))
				
		set @CurrentBalance = @CurrentBalance + @ItemValue
		
		if isnull(@TaskCode, '') = ''
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

	
	if isnull(@CashCode, '') != ''
		begin
		UPDATE    tbOrgPayment
		SET      PaymentStatusCode = 2, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
			CashCode = isnull(@CashCode, tbOrgPayment.CashCode), 
			TaxCode = isnull(@TaxCode, tbOrgPayment.TaxCode)
		WHERE     (PaymentCode = @PaymentCode)
		end

			
	RETURN
GO
CREATE OR ALTER  PROCEDURE dbo.spPaymentPostPaidOut
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
		ORDER BY vwInvoiceOutstanding.CashModeCode DESC, vwInvoiceOutstanding.InvoicedOn

	open curPaidOut
	fetch next from curPaidOut into @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue
	while @@FETCH_STATUS = 0 and @CurrentBalance > 0
		begin
		if (@CurrentBalance + @ItemValue) < 0
			set @ItemValue = @CurrentBalance * -1

		set @PaidValue = Abs(@ItemValue) / (1 + @TaxRate)
		set @PaidTaxValue = Abs(@ItemValue) - (Abs(@ItemValue) / (1 + @TaxRate))
				
		set @CurrentBalance = @CurrentBalance + @ItemValue
		
		if isnull(@TaskCode, '') = ''
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

	if isnull(@CashCode, '') != ''
		begin
		UPDATE    tbOrgPayment
		SET      PaymentStatusCode = 2, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
			CashCode = isnull(@CashCode, tbOrgPayment.CashCode), 
			TaxCode = isnull(@TaxCode, tbOrgPayment.TaxCode)
		WHERE     (PaymentCode = @PaymentCode)
		end
	
	RETURN
GO
CREATE OR ALTER  PROCEDURE [dbo].[spSettingAddCalDateRange]
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
CREATE OR ALTER  PROCEDURE [dbo].[spSettingDelCalDateRange]
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
CREATE OR ALTER  Procedure [dbo].[spSettingInitialised]
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
CREATE OR ALTER  PROCEDURE [dbo].[spSettingLicence]
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
CREATE OR ALTER  PROCEDURE [dbo].[spSettingLicenceAdd]
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
CREATE OR ALTER   PROCEDURE dbo.spSettingNewCompany
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
CREATE OR ALTER  FUNCTION dbo.fnStatementCompany
	(
	@IncludeForecasts bit = 0
	)
RETURNS @tbStatement TABLE (
	ReferenceCode nvarchar(20), 
	AccountCode nvarchar(10),
	TransactOn datetime,
	CashEntryTypeCode smallint,
	PayOut money,
	PayIn money,
	Balance money
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

	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
	SELECT     ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
	FROM         dbo.fnStatementCorpTax()

	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
	SELECT     ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
	FROM         dbo.fnStatementVat()
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
	SELECT     ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
	FROM         vwStatementInvoices
	
	if (@IncludeForecasts = 0)
		begin
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
		SELECT     ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
		FROM         vwStatementTasksConfirmed			
		end
	else
		begin
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
		SELECT     ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
		FROM         vwStatementTasksFull	
		end

	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
	SELECT     '*' AS ReferenceCode, dbo.fnStatementTaxAccount(1) AS AccountCode, StartOn, 5, 0, CorporationTax
	FROM         fnTaxCorpOrderTotals(@IncludeForecasts) fnTaxCorpOrderTotals_1		

	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
	SELECT     '*' AS ReferenceCode, dbo.fnStatementTaxAccount(1) AS AccountCode, StartOn, 6 AS Expr1, PayIn, PayOut
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
CREATE OR ALTER  PROCEDURE dbo.spStatementCompany
	(
		@IncludeForecasts bit = 0
	)
 AS
	SELECT     fnStatementCompany.TransactOn, fnStatementCompany.CashEntryTypeCode, fnStatementCompany.ReferenceCode, 
	                      fnStatementCompany.AccountCode, tbOrg.AccountName, tbCashEntryType.CashEntryType, fnStatementCompany.PayOut, fnStatementCompany.PayIn, 
	                      fnStatementCompany.Balance
	FROM         fnStatementCompany(@IncludeForecasts) fnStatementCompany INNER JOIN
	                      tbCashEntryType ON fnStatementCompany.CashEntryTypeCode = tbCashEntryType.CashEntryTypeCode INNER JOIN
	                      tbOrg ON fnStatementCompany.AccountCode = tbOrg.AccountCode 
	ORDER BY fnStatementCompany.TransactOn, fnStatementCompany.CashEntryTypeCode, fnStatementCompany.ReferenceCode
	
	
	RETURN 
GO
CREATE OR ALTER  PROCEDURE dbo.spSystemCompanyName
	(
	@AccountName nvarchar(255) = null output
	)
 AS
	SELECT top 1 @AccountName = tbOrg.AccountName
	FROM         tbOrg INNER JOIN
	                      tbSystemOptions ON tbOrg.AccountCode = tbSystemOptions.AccountCode
	RETURN 
GO
CREATE OR ALTER  PROCEDURE dbo.spSystemPeriodClose
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
CREATE OR ALTER  PROCEDURE dbo.spSystemPeriodTransfer
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
CREATE OR ALTER   PROCEDURE dbo.spSystemPeriodTransferAll
 AS

	UPDATE tbCashPeriod
	SET InvoiceValue = 0, InvoiceTax = 0, CashValue = 0, CashTax = 0, ForecastValue = 0, ForecastTax = 0
		
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
CREATE OR ALTER  PROCEDURE dbo.spSystemReassignUser 
	(
	@UserId nvarchar(10)
	)
 AS
	UPDATE    tbUser
	SET       LogonName = (SUSER_SNAME())
	WHERE     (UserId = @UserId)
	
	RETURN
GO
CREATE OR ALTER  PROCEDURE [dbo].[spSystemYearPeriods]
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
CREATE OR ALTER  PROCEDURE [dbo].[spTaskAssignToParent] 
	(
	@ChildTaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20)
	)
 AS
declare @TaskTitle nvarchar(100)
declare @StepNumber smallint

	if exists(SELECT     TOP 1 StepNumber
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
	SET      TaskTitle = @TaskTitle
	WHERE     (TaskCode = @ChildTaskCode)
	
	INSERT INTO tbTaskFlow
	                      (ParentTaskCode, StepNumber, ChildTaskCode)
	VALUES     (@ParentTaskCode,@StepNumber,@ChildTaskCode)
	
	RETURN
GO
CREATE OR ALTER   PROCEDURE dbo.spTaskConfigure 
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
			
			set @NickName = left(@ContactName, charindex(' ', @ContactName, 1))
			exec dbo.spOrgContactFileAs @ContactName, @FileAs output
			
			INSERT INTO tbOrgContact
								  (AccountCode, ContactName, FileAs, NickName)
			SELECT     AccountCode, ContactName, @FileAs AS FileAs, @NickName AS NickName
			FROM         tbTask
			WHERE     (TaskCode = @ParentTaskCode)
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
		SET              ActionedOn = GETDATE()
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
							tbTask_1.ActionById, tbTask_1.ActionOn, dbo.fnSystemAdjustToCalendar(tbTask_1.UserId, DATEADD(d, tbOrg.PaymentDays, tbTask_1.ActionOn), 0) 
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
CREATE OR ALTER  PROCEDURE dbo.spTaskCost 
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
		WHERE     (tbTaskFlow.ParentTaskCode = @ParentTaskCode)	

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
CREATE OR ALTER  PROCEDURE dbo.spTaskDefaultInvoiceType
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
CREATE OR ALTER  PROCEDURE dbo.spTaskDefaultPaymentOn
	(
		@AccountCode nvarchar(10),
		@ActionOn datetime,
		@PaymentOn datetime output
	)
 AS
declare @PaymentDays smallint
declare @UserId nvarchar(10)

	select @UserId = UserId from dbo.vwUserCredentials
	SELECT @PaymentDays = PaymentDays
	FROM         tbOrg
	WHERE     (AccountCode = @AccountCode)
	
	set @PaymentOn = dbo.fnSystemAdjustToCalendar(@UserId, dateadd(d, @PaymentDays, @ActionOn), 0)
	
	RETURN 
GO
CREATE OR ALTER  PROCEDURE [dbo].[spTaskDefaultTaxCode] 
	(
	@AccountCode nvarchar(10),
	@CashCode nvarchar(50),
	@TaxCode nvarchar(10) OUTPUT
	)
 AS

	set @TaxCode = dbo.fnTaskDefaultTaxCode(@AccountCode, @CashCode)
		
	RETURN
GO
CREATE OR ALTER  PROCEDURE [dbo].[spTaskDelete] 
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
CREATE OR ALTER  PROCEDURE [dbo].[spTaskEmailAddress] 
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
CREATE OR ALTER  PROCEDURE [dbo].[spTaskEmailDetail] 
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
CREATE OR ALTER  PROCEDURE [dbo].[spTaskEmailFooter] 
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
CREATE OR ALTER  PROCEDURE [dbo].[spTaskIsProject] 
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
CREATE OR ALTER  PROCEDURE [dbo].[spTaskMode] 
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
CREATE OR ALTER  PROCEDURE [dbo].[spTaskNextAttributeOrder] 
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
CREATE OR ALTER   PROCEDURE dbo.spTaskNextCode
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
CREATE OR ALTER  PROCEDURE [dbo].[spTaskProject] 
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
CREATE OR ALTER   PROCEDURE dbo.spTaskSchedule
	(
	@ParentTaskCode nvarchar(20),
	@ActionOn datetime = null output
	)
  AS
declare @UserId nvarchar(10)
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
	
	SELECT @PaymentDays = tbOrg.PaymentDays, @PaymentOn = tbTask.PaymentOn, @UserId = tbTask.UserId
	FROM         tbOrg INNER JOIN
	                      tbTask ON tbOrg.AccountCode = tbTask.AccountCode
	WHERE     (tbTask.TaskCode = @ParentTaskCode)
	
	if (@PaymentOn != dbo.fnSystemAdjustToCalendar(@UserId, dateadd(d, @PaymentDays, @ActionOn), 0))
		begin
		update tbTask
		set PaymentOn = dbo.fnSystemAdjustToCalendar(@UserId, dateadd(d, @PaymentDays, @ActionOn), 0)
		where TaskCode = @ParentTaskCode and TaskStatusCode < 3
		end
	
	
	Select @Quantity = Quantity from tbTask where TaskCode = @ParentTaskCode
	
	declare curAct cursor local for
		SELECT     tbTaskFlow.StepNumber, tbTaskFlow.ChildTaskCode, tbTask.ActionById, tbTaskFlow.OffsetDays, tbTaskFlow.UsedOnQuantity, 
		                      tbOrg.PaymentDays
		FROM         tbTaskFlow INNER JOIN
		                      tbTask ON tbTaskFlow.ChildTaskCode = tbTask.TaskCode INNER JOIN
		                      tbOrg ON tbTask.AccountCode = tbOrg.AccountCode
		WHERE     (tbTaskFlow.ParentTaskCode = @ParentTaskCode)
		ORDER BY tbTaskFlow.StepNumber DESC
	
	open curAct
	fetch next from curAct into @StepNumber, @TaskCode, @UserId, @OffsetDays, @UsedOnQuantity, @PaymentDays
	while @@FETCH_STATUS = 0
		begin
		set @ActionOn = dbo.fnSystemAdjustToCalendar(@UserId, @ActionOn, @OffsetDays)
		set @PaymentOn = dbo.fnSystemAdjustToCalendar(@UserId, dateadd(d, @PaymentDays, @ActionOn), 0)
		
		update tbTask
		set ActionOn = @ActionOn, 
			PaymentOn = @PaymentOn,
			Quantity = @Quantity * @UsedOnQuantity,
			TotalCharge = case when @UsedOnQuantity = 0 then UnitCharge else UnitCharge * @Quantity * @UsedOnQuantity end,
			UpdatedOn = getdate(),
			UpdatedBy = (suser_sname())
		where TaskCode = @TaskCode and TaskStatusCode < 3
		
		exec dbo.spTaskSchedule @TaskCode, @ActionOn output
		fetch next from curAct into @StepNumber, @TaskCode, @UserId, @OffsetDays, @UsedOnQuantity, @PaymentDays
		end
	
	close curAct
	deallocate curAct	
	
	RETURN
GO
CREATE OR ALTER  PROCEDURE dbo.spTaskSetStatus
	(
		@TaskCode nvarchar(20)
	)

 AS
declare @ChildTaskCode nvarchar(20)
declare @TaskStatusCode smallint

	select @TaskStatusCode = TaskStatusCode
	from tbTask
	where TaskCode = @TaskCode
	
	declare curTask cursor local for
		SELECT     tbTaskFlow.ChildTaskCode
		FROM         tbTaskFlow INNER JOIN
		                      tbTask ON tbTaskFlow.ChildTaskCode = tbTask.TaskCode
		WHERE     (tbTaskFlow.ParentTaskCode = @TaskCode)

	open curTask
	fetch next from curTask into @ChildTaskCode
	while @@FETCH_STATUS = 0
		begin
		UPDATE    tbTask
		SET              TaskStatusCode = @TaskStatusCode
		WHERE     (TaskCode = @ChildTaskCode) and TaskStatusCode < 3
		
		exec dbo.spTaskSetStatus @ChildTaskCode
		fetch next from curTask into @ChildTaskCode
		end
		
	close curTask
	deallocate curTask
		
	RETURN 
GO
CREATE OR ALTER  PROCEDURE [dbo].[spTaskWorkFlow] 
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
UPDATE dbo.tbCashType
   SET CashType = 'EXTERNAL'
 WHERE CashTypeCode = 2
GO
--1.07
GO
CREATE OR ALTER  VIEW [dbo].[vwTaxVatManualForecasts]
 AS
SELECT     dbo.tbCashPeriod.StartOn, 
                      SUM(CASE WHEN CashModeCode = 1 THEN dbo.tbCashPeriod.ForecastValue * dbo.tbSystemTaxCode.TaxRate ELSE dbo.tbCashPeriod.ForecastValue *
                       dbo.tbSystemTaxCode.TaxRate * - 1 END) AS VatCharge
FROM         dbo.tbCashPeriod INNER JOIN
                      dbo.tbCashCode ON dbo.tbCashPeriod.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbCashCode.TaxCode = dbo.tbSystemTaxCode.TaxCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode
WHERE     (dbo.tbCashCategory.ManualForecast <> 0) AND (dbo.tbSystemTaxCode.TaxTypeCode = 2)
GROUP BY dbo.tbCashPeriod.StartOn
HAVING      (dbo.tbCashPeriod.StartOn >= dbo.fnSystemActiveStartOn())
GO
CREATE OR ALTER  VIEW [dbo].[vwCorpTaxManualForecasts]
 AS
SELECT     dbo.tbCashPeriod.StartOn, dbo.tbSystemYearPeriod.CorporationTaxRate, 
                      SUM(CASE WHEN tbCashCategory.CashModeCode = 1 THEN ForecastValue * - 1 ELSE ForecastValue END) AS NetProfit, 
                      SUM(CASE WHEN tbCashCategory.CashModeCode = 1 THEN ForecastValue * - 1 ELSE ForecastValue END) 
                      * dbo.tbSystemYearPeriod.CorporationTaxRate AS CorporationTax
FROM         dbo.fnNetProfitCashCodes() AS fnNetProfitCashCodes_1 INNER JOIN
                      dbo.tbCashPeriod ON fnNetProfitCashCodes_1.CashCode = dbo.tbCashPeriod.CashCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbCashPeriod.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.tbCashPeriod.StartOn = dbo.tbSystemYearPeriod.StartOn
WHERE     (dbo.tbCashCategory.ManualForecast <> 0)
GROUP BY dbo.tbCashPeriod.StartOn, dbo.tbSystemYearPeriod.CorporationTaxRate
HAVING      (dbo.tbCashPeriod.StartOn >= dbo.fnSystemActiveStartOn())
GO
CREATE OR ALTER  FUNCTION [dbo].[fnCashCodeDefaultAccount] 
	(
	@CashCode nvarchar(50)
	)
RETURNS nvarchar(10)
 AS
	BEGIN
	declare @AccountCode nvarchar(10)
	if exists(SELECT     CashCode
	          FROM         tbInvoiceTask
	          WHERE     (CashCode = @CashCode))
		begin
		SELECT  @AccountCode = tbInvoice.AccountCode
		FROM         tbInvoiceTask INNER JOIN
		                      tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber
		WHERE     (tbInvoiceTask.CashCode = @CashCode)
		ORDER BY tbInvoice.InvoicedOn DESC		
		end
	else if exists(SELECT     CashCode
	          FROM         tbInvoiceItem
	          WHERE     (CashCode = @CashCode))
		begin
		SELECT  @AccountCode = tbInvoice.AccountCode
		FROM         tbInvoiceItem INNER JOIN
		                      tbInvoice ON tbInvoiceItem.InvoiceNumber = tbInvoice.InvoiceNumber
		WHERE     (tbInvoiceItem.CashCode = @CashCode)		
		ORDER BY tbInvoice.InvoicedOn DESC	
		end
	else
		begin	
		select @AccountCode = AccountCode from tbSystemOptions
		end
		
	RETURN @AccountCode
	END
GO
CREATE OR ALTER  VIEW [dbo].[vwStatementForecasts]
 AS
SELECT     dbo.tbCashPeriod.CashCode, dbo.fnCashCodeDefaultAccount(dbo.tbCashPeriod.CashCode) AS AccountCode, DATEADD(m, 1, dbo.tbCashPeriod.StartOn) 
                      - 1 AS TransactOn, 7 AS CashEntryTypeCode, CASE WHEN CashModeCode = 2 THEN ForecastValue + ForecastTax ELSE 0 END AS PayIn, 
                      CASE WHEN CashModeCode = 1 THEN ForecastValue + ForecastTax ELSE 0 END AS PayOut
FROM         dbo.tbCashPeriod INNER JOIN
                      dbo.tbCashCode ON dbo.tbCashPeriod.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode
WHERE     (dbo.tbCashCategory.ManualForecast <> 0) AND (dbo.tbCashPeriod.StartOn >= dbo.fnSystemActiveStartOn()) AND (dbo.tbCashPeriod.ForecastValue > 0)
GO
CREATE OR ALTER  FUNCTION [dbo].[fnStatementCorpTax]
	()
RETURNS @tbCorpTax TABLE (
	ReferenceCode nvarchar(20), 
	AccountCode nvarchar(10),
	TransactOn datetime,
	CashEntryTypeCode int,
	PayOut money,
	PayIn money,
	CashCode nvarchar(50)
	
	)
  AS
	BEGIN
	declare @StartOn datetime
	declare @Balance money
	declare @LastBalance money
	declare @TaxDue money
	
	declare @ReferenceCode nvarchar(20)	
	declare @CashCode nvarchar(50)
	
	set @ReferenceCode = dbo.fnSystemProfileText(1214)	
	set @CashCode = dbo.fnSystemCashCode(1)
	
	declare curCorpTax cursor for
		SELECT     StartOn, TaxDue, Balance
		FROM         vwTaxCorpStatement
		ORDER BY StartOn DESC

	open curCorpTax
	
	fetch next from curCorpTax into @StartOn, @TaxDue, @Balance
	
	set @Balance = isnull(@Balance, 0)
	set @LastBalance = @Balance + 1
	
	while ((@@FETCH_STATUS = 0) AND (@Balance > 0) AND (@Balance < @LastBalance)) 
		begin					
		if (@Balance <> 0) AND (@TaxDue > 0)
			begin
			insert into @tbCorpTax (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayOut, PayIn, CashCode)
			values (@ReferenceCode, dbo.fnStatementTaxAccount(2), @StartOn, 5, @TaxDue, 0, @CashCode)						
			end
		set @LastBalance = @Balance
		fetch next from curCorpTax into @StartOn, @TaxDue, @Balance	
		end
		
	close curCorpTax
	deallocate curCorpTax
	
	RETURN
	END
GO
CREATE OR ALTER  FUNCTION [dbo].[fnStatementVat]
	()
RETURNS @tbVat TABLE (
	ReferenceCode nvarchar(20), 
	AccountCode nvarchar(10),
	TransactOn datetime,
	CashEntryTypeCode int,
	PayOut money,
	PayIn money,
	CashCode nvarchar(50)
	)
   AS
	BEGIN
	declare @LastBalanceOn datetime
	declare @VatDueOn datetime
	declare @VatDue money
	
	declare @ReferenceCode nvarchar(20)	
	declare @CashCode nvarchar(50)
	
	set @ReferenceCode = dbo.fnSystemProfileText(1214)	
	set @CashCode = dbo.fnSystemCashCode(1)
	
	if exists(SELECT  MAX(StartOn) AS LastStartOn FROM vwTaxVatStatement)
		begin
		select @LastBalanceOn = MAX(StartOn) FROM vwTaxVatStatement
		SELECT  TOP 1 @VatDueOn = PayOn
		FROM         vwStatementVatDueDate
		
		SELECT @VatDue = Balance
		FROM         vwTaxVatStatement
		WHERE     (StartOn = @LastBalanceOn)		
		
		if (@VatDue <> 0)
			begin
			insert into @tbVat (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayOut, PayIn, CashCode)
			values (@ReferenceCode, dbo.fnStatementTaxAccount(2), @VatDueOn, 6, CASE WHEN @VatDue > 0 THEN @VatDue ELSE 0 END, CASE WHEN @VatDue < 0 THEN ABS(@VatDue) ELSE 0 END, @CashCode)						
			end
		end
	
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
		
		if exists (select StartOn from @tbCorp where StartOn = @PayOn)
			begin
			SELECT     @NetProfit = ISNULL(SUM(NetProfit), 0), 
				@CorporationTax = ISNULL(SUM(CorporationTax), 0)
			FROM         vwCorpTaxManualForecasts
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
			HAVING      (ISNULL(SUM(CorporationTax), 0) > 0)						
			
			if @@ROWCOUNT > 0
				begin
				UPDATE @tbCorp
				SET NetProfit = NetProfit + @NetProfit, 
					CorporationTax = CorporationTax + @CorporationTax
				WHERE StartOn = @PayOn
				end
			end
		else
			begin
			INSERT INTO @tbCorp (CashCode, StartOn, NetProfit, CorporationTax)
			SELECT     @CashCode As CashCode, @PayOn AS PayOn, ISNULL(SUM(NetProfit), 0) AS NetProfit, ISNULL(SUM(CorporationTax), 0) AS CorporationTax
			FROM         vwCorpTaxManualForecasts
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
CREATE OR ALTER  FUNCTION [dbo].[fnStatementCompany]
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
	SELECT     CashCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode
	FROM vwStatementForecasts

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
	WHERE     ((tbInvoiceItem.InvoiceValue + tbInvoiceItem.TaxValue) - (tbInvoiceItem.PaidValue + tbInvoiceItem.PaidTaxValue) > 0) AND 
	                      (tbCashCategory.ManualForecast = 0)
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
	WHERE     ((tbInvoiceTask.InvoiceValue + tbInvoiceTask.TaxValue) - (tbInvoiceTask.PaidValue + tbInvoiceTask.PaidTaxValue) > 0) AND 
	                      (tbCashCategory.ManualForecast = 0)
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

	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	SELECT     @ReferenceCode AS ReferenceCode, dbo.fnStatementTaxAccount(1) AS AccountCode, StartOn, 6 AS Expr1, PayIn, PayOut, dbo.fnSystemCashCode(2)
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
CREATE OR ALTER  PROCEDURE [dbo].[spStatementCompany]
	(
		@IncludeForecasts bit = 0,
		@UseInvoiceDate bit = 0
	)
   AS
	SELECT     fnStatementCompany.TransactOn, fnStatementCompany.CashEntryTypeCode, fnStatementCompany.ReferenceCode, 
	                      fnStatementCompany.AccountCode, tbOrg.AccountName, tbCashEntryType.CashEntryType, fnStatementCompany.PayOut, fnStatementCompany.PayIn, 
	                      fnStatementCompany.Balance, tbCashCode.CashCode, tbCashCode.CashDescription
	FROM         dbo.fnStatementCompany(@IncludeForecasts, @UseInvoiceDate) AS fnStatementCompany INNER JOIN
	                      tbCashEntryType ON fnStatementCompany.CashEntryTypeCode = tbCashEntryType.CashEntryTypeCode INNER JOIN
	                      tbOrg ON fnStatementCompany.AccountCode = tbOrg.AccountCode LEFT OUTER JOIN
	                      tbCashCode ON fnStatementCompany.CashCode = tbCashCode.CashCode
	ORDER BY fnStatementCompany.TransactOn, fnStatementCompany.CashEntryTypeCode, fnStatementCompany.ReferenceCode
	
	
	RETURN 
GO
CREATE OR ALTER  VIEW [dbo].[vwStatementTasksConfirmed]
 AS
SELECT     TOP 100 PERCENT dbo.tbTask.TaskCode AS ReferenceCode, dbo.tbTask.AccountCode, dbo.tbTask.ActionOn, dbo.tbTask.PaymentOn, 
                      3 AS CashEntryTypeCode, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.tbSystemTaxCode.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayOut, 
                      CASE WHEN tbCashCategory.CashModeCode = 2 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.tbSystemTaxCode.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayIn, dbo.tbCashCode.CashCode
FROM         dbo.tbSystemTaxCode INNER JOIN
                      dbo.tbTask ON dbo.tbSystemTaxCode.TaxCode = dbo.tbTask.TaxCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.tbTask.TaskStatusCode > 1) AND (dbo.tbTask.TaskStatusCode < 4) AND 
                      (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0) > 0)
GO
CREATE OR ALTER  VIEW [dbo].[vwStatementTasksFull]
 AS
SELECT     TOP 100 PERCENT dbo.tbTask.TaskCode AS ReferenceCode, dbo.tbTask.AccountCode, dbo.tbTask.ActionOn, dbo.tbTask.PaymentOn, 
                      CASE WHEN tbTask.TaskStatusCode = 1 THEN 4 ELSE 3 END AS CashEntryTypeCode, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.tbSystemTaxCode.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayOut, 
                      CASE WHEN tbCashCategory.CashModeCode = 2 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.tbSystemTaxCode.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayIn, dbo.tbCashCode.CashCode
FROM         dbo.tbSystemTaxCode INNER JOIN
                      dbo.tbTask ON dbo.tbSystemTaxCode.TaxCode = dbo.tbTask.TaxCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.tbTask.TaskStatusCode < 4) AND (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0) > 0)
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
			
		if exists (select StartOn from @tbVat where StartOn = @PayOn)
			begin
			SELECT     @VatCharge = SUM(VatCharge)
			FROM         vwTaxVatManualForecasts
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
			HAVING      (ISNULL(SUM(VatCharge), 0) <> 0)						
			
			if @@ROWCOUNT > 0
				begin
				UPDATE @tbVat
				SET PayIn = PayIn + CASE WHEN @VatCharge > 0 THEN @VatCharge ELSE 0 END, 
					PayOut = PayOut + CASE WHEN @VatCharge < 0 THEN ABS(@VatCharge) ELSE 0 END
				WHERE StartOn = @PayOn
				end
			end
		else
			begin
			INSERT INTO @tbVat (CashCode, StartOn, PayIn, PayOut)
			SELECT     @CashCode As CashCode, @PayOn AS PayOn, 
				CASE WHEN SUM(VatCharge) > 0 THEN SUM(VatCharge) ELSE 0 END,
				CASE WHEN SUM(VatCharge) < 0 THEN ABS(SUM(VatCharge)) ELSE 0 END
			FROM         vwTaxVatManualForecasts
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
			HAVING      (ISNULL(SUM(VatCharge), 0) <> 0)				
			end	
						
		fetch next from curVat into @PayOn, @PayFrom, @PayTo
		end
	
	close curVat
	deallocate curVat

	
	RETURN
	END
GO
ALTER  PROCEDURE [dbo].[spSystemPeriodTransferAll]
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
	WHERE     (tbCashCategory.ManualForecast = 0) AND (tbCashPeriod.StartOn >= @StartOn)
	
	UPDATE tbCashPeriod
	SET 
		ForecastValue = vwCashCodeForecastSummary.ForecastValue, 
		ForecastTax = vwCashCodeForecastSummary.ForecastTax
	FROM         tbCashPeriod INNER JOIN
	                      vwCashCodeForecastSummary ON tbCashPeriod.CashCode = vwCashCodeForecastSummary.CashCode AND 
	                      tbCashPeriod.StartOn = vwCashCodeForecastSummary.StartOn INNER JOIN
	                      tbCashCode ON tbCashPeriod.CashCode = tbCashCode.CashCode INNER JOIN
	                      tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE     (tbCashPeriod.StartOn >= @StartOn) AND (tbCashCategory.ManualForecast = 0)
	
	
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
CREATE OR ALTER PROCEDURE [dbo].[spStatementRescheduleOverdue]
 AS
	UPDATE tbTask
	SET tbTask.PaymentOn = CASE WHEN dateadd(d, tbOrg.PaymentDays, tbTask.ActionedOn) > getdate() 
		THEN dateadd(d, tbOrg.PaymentDays, tbTask.ActionedOn) 
		ELSE dateadd(d, tbOrg.PaymentDays, getdate()) 
		END 
	FROM         tbTask INNER JOIN
	                      tbOrg ON tbTask.AccountCode = tbOrg.AccountCode INNER JOIN
	                      tbCashCode ON tbTask.CashCode = tbCashCode.CashCode
	WHERE     (tbTask.PaymentOn < GETDATE()) AND (tbTask.TaskStatusCode = 3)
	

	UPDATE tbTask
	SET tbTask.PaymentOn = CASE WHEN dateadd(d, tbOrg.PaymentDays, tbTask.ActionOn) > getdate() 
		THEN dateadd(d, tbOrg.PaymentDays, tbTask.ActionOn) 
		ELSE dateadd(d, tbOrg.PaymentDays, getdate()) 
		END 
	FROM         tbTask INNER JOIN
	                      tbOrg ON tbTask.AccountCode = tbOrg.AccountCode INNER JOIN
	                      tbCashCode ON tbTask.CashCode = tbCashCode.CashCode
	WHERE     (tbTask.PaymentOn < GETDATE()) AND (tbTask.TaskStatusCode < 3)
	
	UPDATE tbInvoice
	SET CollectOn = CASE WHEN dateadd(d, tbOrg.PaymentDays, tbInvoice.InvoicedOn) > getdate() 
		THEN dateadd(d, tbOrg.PaymentDays, tbInvoice.InvoicedOn) 
		ELSE dateadd(d, tbOrg.PaymentDays, getdate()) 
		END
	FROM         tbInvoice INNER JOIN
	                      tbOrg ON tbInvoice.AccountCode = tbOrg.AccountCode
	WHERE     (tbInvoice.InvoiceStatusCode = 2 OR
	                      tbInvoice.InvoiceStatusCode = 3) AND (tbInvoice.CollectOn < GETDATE())
	
	
	RETURN
GO
CREATE OR ALTER PROCEDURE [dbo].[spStatementRescheduleOverdue]
 AS
	UPDATE tbTask
	SET tbTask.PaymentOn = CASE WHEN dateadd(d, tbOrg.PaymentDays, tbTask.ActionedOn) > getdate() 
		THEN dateadd(d, tbOrg.PaymentDays, tbTask.ActionedOn) 
		ELSE dateadd(d, tbOrg.PaymentDays, getdate()) 
		END 
	FROM         tbTask INNER JOIN
	                      tbOrg ON tbTask.AccountCode = tbOrg.AccountCode INNER JOIN
	                      tbCashCode ON tbTask.CashCode = tbCashCode.CashCode
	WHERE     (tbTask.PaymentOn < GETDATE()) AND (tbTask.TaskStatusCode = 3)
	

	UPDATE tbTask
	SET tbTask.PaymentOn = CASE WHEN dateadd(d, tbOrg.PaymentDays, tbTask.ActionOn) > getdate() 
		THEN dateadd(d, tbOrg.PaymentDays, tbTask.ActionOn) 
		ELSE dateadd(d, tbOrg.PaymentDays, getdate()) 
		END 
	FROM         tbTask INNER JOIN
	                      tbOrg ON tbTask.AccountCode = tbOrg.AccountCode INNER JOIN
	                      tbCashCode ON tbTask.CashCode = tbCashCode.CashCode
	WHERE     (tbTask.PaymentOn < GETDATE()) AND (tbTask.TaskStatusCode < 3)
	
	UPDATE tbInvoice
	SET CollectOn = CASE WHEN dateadd(d, tbOrg.PaymentDays, tbInvoice.InvoicedOn) > getdate() 
		THEN dateadd(d, tbOrg.PaymentDays, tbInvoice.InvoicedOn) 
		ELSE dateadd(d, tbOrg.PaymentDays, getdate()) 
		END
	FROM         tbInvoice INNER JOIN
	                      tbOrg ON tbInvoice.AccountCode = tbOrg.AccountCode
	WHERE     (tbInvoice.InvoiceStatusCode = 2 OR
	                      tbInvoice.InvoiceStatusCode = 3) AND (tbInvoice.CollectOn < GETDATE())
	
	
	RETURN
GO
CREATE OR ALTER PROCEDURE [dbo].[spCashCategoryCashCodes]
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
CREATE OR ALTER PROCEDURE [dbo].[spPaymentDelete]
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
ALTER  PROCEDURE [dbo].[spPaymentPostMisc]
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
	                      4 AS InvoiceStatusCode, tbOrgPayment.PaidOn, CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + tbSystemTaxCode.TaxRate) 
	                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + tbSystemTaxCode.TaxRate) END AS InvoiceValue, 
	                      CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - ROUND((tbOrgPayment.PaidInValue / (1 + tbSystemTaxCode.TaxRate)), 
	                      2) WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - ROUND((tbOrgPayment.PaidOutValue / (1 + tbSystemTaxCode.TaxRate)), 
	                      2) END AS TaxValue, CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + tbSystemTaxCode.TaxRate) 
	                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + tbSystemTaxCode.TaxRate) END AS PaidValue, 
	                      CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - ROUND((tbOrgPayment.PaidInValue / (1 + tbSystemTaxCode.TaxRate)), 
	                      2) WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - ROUND((tbOrgPayment.PaidOutValue / (1 + tbSystemTaxCode.TaxRate)), 
	                      2) END AS PaidTaxValue, 1 AS Printed
	FROM         tbOrgPayment INNER JOIN
	                      tbSystemTaxCode ON tbOrgPayment.TaxCode = tbSystemTaxCode.TaxCode
	WHERE     (tbOrgPayment.PaymentCode = @PaymentCode)

	INSERT INTO tbInvoiceItem
						(InvoiceNumber, CashCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, TaxCode)
	SELECT     @InvoiceNumber AS InvoiceNumber, tbOrgPayment.CashCode, 
	                      CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + tbSystemTaxCode.TaxRate) 
	                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + tbSystemTaxCode.TaxRate) END AS InvoiceValue, 
	                      CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - ROUND((tbOrgPayment.PaidInValue / (1 + tbSystemTaxCode.TaxRate)), 
	                      2) WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - ROUND((tbOrgPayment.PaidOutValue / (1 + tbSystemTaxCode.TaxRate)), 
	                      2) END AS TaxValue, CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + tbSystemTaxCode.TaxRate) 
	                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + tbSystemTaxCode.TaxRate) END AS PaidValue, 
	                      CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - ROUND((tbOrgPayment.PaidInValue / (1 + tbSystemTaxCode.TaxRate)), 
	                      2) WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - ROUND((tbOrgPayment.PaidOutValue / (1 + tbSystemTaxCode.TaxRate)), 
	                      2) END AS PaidTaxValue, tbOrgPayment.TaxCode
	FROM         tbOrgPayment INNER JOIN
	                      tbSystemTaxCode ON tbOrgPayment.TaxCode = tbSystemTaxCode.TaxCode
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
	                      tbSystemTaxCode ON tbOrgPayment.TaxCode = tbSystemTaxCode.TaxCode
	WHERE     (PaymentCode = @PaymentCode)
	
	RETURN
GO
ALTER PROCEDURE [dbo].[spPaymentPostPaidIn]
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
		ORDER BY vwInvoiceOutstanding.CashModeCode, vwInvoiceOutstanding.InvoicedOn

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
ALTER PROCEDURE [dbo].[spPaymentPostPaidOut]
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
		ORDER BY vwInvoiceOutstanding.CashModeCode DESC, vwInvoiceOutstanding.InvoicedOn

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
ALTER PROCEDURE [dbo].[spOrgRebuild]
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
	set TaxValue = ROUND(tbInvoiceItem.InvoiceValue * tbSystemTaxCode.TaxRate, 2),
		PaidValue = tbInvoiceItem.InvoiceValue, 
		PaidTaxValue = ROUND(tbInvoiceItem.InvoiceValue * tbSystemTaxCode.TaxRate, 2)				
	FROM         tbInvoiceItem INNER JOIN
	                      tbSystemTaxCode ON tbInvoiceItem.TaxCode = tbSystemTaxCode.TaxCode INNER JOIN
	                      tbInvoice ON tbInvoiceItem.InvoiceNumber = tbInvoice.InvoiceNumber
	WHERE     (tbInvoice.AccountCode = @AccountCode) AND (tbInvoice.InvoiceStatusCode <> 1)	
                      
	update tbInvoiceTask
	set TaxValue = ROUND(tbInvoiceTask.InvoiceValue * tbSystemTaxCode.TaxRate, 2),
		PaidValue = tbInvoiceTask.InvoiceValue, PaidTaxValue = ROUND(tbInvoiceTask.InvoiceValue * tbSystemTaxCode.TaxRate, 2)
	FROM         tbInvoiceTask INNER JOIN
	                      tbSystemTaxCode ON tbInvoiceTask.TaxCode = tbSystemTaxCode.TaxCode INNER JOIN
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
	                      tbSystemTaxCode ON tbOrgPayment.TaxCode = tbSystemTaxCode.TaxCode
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
		ORDER BY InvoicedOn DESC
	

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
			
		if isnull(@TaskCode, '''') = ''''
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
