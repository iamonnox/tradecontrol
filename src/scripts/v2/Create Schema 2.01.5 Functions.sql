GO
CREATE FUNCTION [dbo].[fnSystemWeekDay]
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
CREATE FUNCTION [dbo].[fnTaskDefaultTaxCode] 
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
CREATE FUNCTION [dbo].[fnStatementTaxAccount]
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
CREATE FUNCTION [dbo].[fnOrgRebuildInvoiceTasks]
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
CREATE FUNCTION [dbo].[fnOrgRebuildInvoiceItems]
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
CREATE FUNCTION [dbo].[fnCashCodeDefaultAccount] 
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
CREATE FUNCTION [dbo].[fnOrgStatement]
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
CREATE FUNCTION [dbo].[fnSystemAdjustToCalendar]
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
CREATE FUNCTION [dbo].[fnTimestamp]
	(
	@Now datetime
	)
RETURNS NVARCHAR(20)
AS
	BEGIN
	DECLARE @Timestamp NVARCHAR(20)
	SET @Timestamp = LTRIM(STR(Year(@Now))) + '/'
		+ dbo.fnPad(LTRIM(STR(Month(@Now))), 2) + '/'
		+ dbo.fnPad(LTRIM(STR(Day(@Now))), 2) + ' '
		+ dbo.fnPad(LTRIM(STR(DatePart(hh, @Now))), 2) + ':'
		+ dbo.fnPad(LTRIM(STR(DatePart(n, @Now))), 2) + ':'
		+ dbo.fnPad(LTRIM(STR(DatePart(s, @Now))), 2)
	RETURN @Timestamp
	END
GO
CREATE FUNCTION [dbo].[fnTaskDefaultPaymentOn]
	(
		@AccountCode nvarchar(10),
		@ActionOn datetime
	)
RETURNS datetime
AS
	BEGIN
	DECLARE @PaymentOn datetime
	DECLARE @PaymentDays smallint
	DECLARE @UserId nvarchar(10)
	DECLARE @PayDaysFromMonthEnd bit


	SELECT @UserId = UserId FROM dbo.vwUserCredentials
	
	SELECT @PaymentDays = PaymentDays, @PayDaysFromMonthEnd = PayDaysFromMonthEnd
	FROM         tbOrg
	WHERE     (AccountCode = @AccountCode)
	
	IF (@PayDaysFromMonthEnd <> 0)
		set @PaymentOn = dateadd(d, @PaymentDays, dateadd(d, ((day(@ActionOn) - 1) + 1) * -1, dateadd(m, 1, @ActionOn)))
	ELSE
		set @PaymentOn = dateadd(d, @PaymentDays, @ActionOn)
		
	set @PaymentOn = dbo.fnSystemAdjustToCalendar(@UserId, @PaymentOn, 0)	
	
	
	RETURN @PaymentOn
	END
GO
CREATE FUNCTION [dbo].[fnTaskCost]
	(
	@TaskCode nvarchar(20)
	)
RETURNS money
AS
	BEGIN
	
	declare @ChildTaskCode nvarchar(20)
	declare @TotalCharge money
	declare @TotalCost money
	declare @CashModeCode smallint

	declare curFlow cursor local for
		SELECT     tbTask.TaskCode, vwTaskCashMode.CashModeCode, tbTask.TotalCharge
		FROM         tbTask INNER JOIN
							  tbTaskFlow ON tbTask.TaskCode = tbTaskFlow.ChildTaskCode INNER JOIN
							  vwTaskCashMode ON tbTask.TaskCode = vwTaskCashMode.TaskCode
		WHERE     (tbTaskFlow.ParentTaskCode = @TaskCode)	

	open curFlow
	fetch next from curFlow into @ChildTaskCode, @CashModeCode, @TotalCharge
	while @@FETCH_STATUS = 0
		begin
		set @TotalCost = @TotalCost + case when @CashModeCode = 1 then @TotalCharge else @TotalCharge * -1 end
		set @TotalCost = @TotalCost + dbo.fnTaskCost(@ChildTaskCode)
		fetch next from curFlow into @ChildTaskCode, @CashModeCode, @TotalCharge
		end
	
	close curFlow
	deallocate curFlow
	
	RETURN @TotalCost
	END
GO
CREATE FUNCTION [dbo].[fnTaxVatOrderTotals]
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
			INSERT INTO @tbVat (CashCode, StartOn, PayOut, PayIn)
			SELECT     @CashCode As CashCode, @PayOn AS PayOn, CASE WHEN ISNULL(SUM(VatValue), 0) > 0 THEN ISNULL(SUM(VatValue), 0) ELSE 0 END AS PayOut, 
			                      CASE WHEN ISNULL(SUM(VatValue), 0) < 0 THEN ABS(ISNULL(SUM(VatValue), 0)) ELSE 0 END AS PayIn
			FROM         vwTaskVatConfirmed
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo) AND (VatValue <> 0) 
			end
		else
			begin
			INSERT INTO @tbVat (CashCode, StartOn, PayOut, PayIn)
			SELECT    @CashCode AS CashCode, @PayOn AS PayOn, 
				CASE WHEN ISNULL(SUM(VatValue), 0) > 0 THEN ISNULL(SUM(VatValue), 0) ELSE 0 END AS PayOut, 
				CASE WHEN ISNULL(SUM(VatValue), 0) < 0 THEN ABS(ISNULL(SUM(VatValue), 0)) ELSE 0 END AS PayIn
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
CREATE FUNCTION [dbo].[fnStatementVat]
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
	
	declare @AccountCode nvarchar(10)
	
	SET @ReferenceCode = dbo.fnSystemProfileText(1214)	
	SET @CashCode = dbo.fnSystemCashCode(2)
	SET @AccountCode = dbo.fnStatementTaxAccount(2)
	SELECT @VatDue = dbo.fnSystemVatBalance()
	IF (@VatDue <> 0)
		BEGIN
		SELECT  TOP 1 @VatDueOn = PayOn	FROM vwStatementVatDueDate		
		SET @VatDueOn = dbo.fnTaskDefaultPaymentOn(@AccountCode, @VatDueOn)
		insert into @tbVat (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayOut, PayIn, CashCode)
		values (@ReferenceCode, @AccountCode, @VatDueOn, 6, CASE WHEN @VatDue > 0 THEN @VatDue ELSE 0 END, CASE WHEN @VatDue < 0 THEN ABS(@VatDue) ELSE 0 END, @CashCode)									
		END
		
		
	RETURN
	END
GO
CREATE FUNCTION [dbo].[fnTaxCorpOrderTotals]
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
		
		fetch next from curVat into @PayOn, @PayFrom, @PayTo
		end
	
	close curVat
	deallocate curVat

	
	RETURN
	END
GO
CREATE FUNCTION [dbo].[fnStatementCorpTax]
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
	declare @TaxDueOn datetime
	declare @Balance money
	declare @TaxDue money
	
	declare @ReferenceCode nvarchar(20)	
	declare @CashCode nvarchar(50)
	declare @AccountCode nvarchar(10)
	
	SET @ReferenceCode = dbo.fnSystemProfileText(1214)	
	SET @CashCode = dbo.fnSystemCashCode(1)
	SET @AccountCode = dbo.fnStatementTaxAccount(1)
	SET @TaxDue = dbo.fnSystemCorpTaxBalance()
	
	IF @TaxDue > 0
		BEGIN
		SELECT  TOP 1 @TaxDueOn = PayOn	FROM vwStatementCorpTaxDueDate
		--SET @TaxDueOn = dbo.fnTaskDefaultPaymentOn(@AccountCode, @TaxDueOn)
		insert into @tbCorpTax (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayOut, PayIn, CashCode)
		values (@ReferenceCode, @AccountCode, @TaxDueOn, 5, @TaxDue, 0, @CashCode)								
		END
	
	RETURN
	END
GO
