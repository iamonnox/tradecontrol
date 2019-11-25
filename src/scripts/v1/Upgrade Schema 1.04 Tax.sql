GO
ALTER  PROCEDURE dbo.spOrgRebuild
	(
		@AccountCode nvarchar(10)
	)
AS
declare @Balance money
declare @BalanceOutstanding money

declare @InvoiceNumber nvarchar(20)
declare @TaskCode nvarchar(20)
declare @CashCode nvarchar(50)
declare @InvoiceValue money
declare @TaxValue money
declare @CashModeCode smallint
declare @PaidValue money
declare @PaidInvoiceValue money
declare @PaidTaxValue money
declare @TaxRate float
		
	SELECT  @Balance = SUM(CASE WHEN PaidInValue > 0 THEN PaidInValue * -1 ELSE PaidOutValue  END)
	FROM         tbOrgPayment
	WHERE     (AccountCode = @AccountCode) And (PaymentStatusCode <> 1)
	
	SELECT @Balance = isnull(@Balance, 0) + OpeningBalance
	FROM tbOrg
	WHERE     (AccountCode = @AccountCode)

--Recalculate tbInvoiceTax
	update tbInvoiceItem
	set TaxValue = InvoiceValue * tbSystemTaxCode.TaxRate
	FROM         tbInvoiceItem INNER JOIN
                      tbSystemTaxCode ON tbInvoiceItem.TaxCode = tbSystemTaxCode.TaxCode
                      
	update tbInvoiceTask
	set TaxValue = InvoiceValue * tbSystemTaxCode.TaxRate
	FROM         tbInvoiceTask INNER JOIN
                      tbSystemTaxCode ON tbInvoiceTask.TaxCode = tbSystemTaxCode.TaxCode
                      
	declare curInv cursor local for
		SELECT     InvoiceNumber, TaskCode, CashCode, InvoiceValue, TaxValue
		FROM         vwOrgInvoices
		WHERE     (AccountCode = @AccountCode)
		ORDER BY InvoicedOn
	
	set @CashModeCode = CASE WHEN @Balance > 0 THEN 1 ELSE 2 END
		
	begin tran OrgRebuild
	
	update tbOrg
	set CurrentBalance = 0
	where AccountCode = @AccountCode
	
	UPDATE tbOrgPayment
	SET
		TaxInValue = PaidInValue - (PaidInValue / (1 + TaxRate)), 
		TaxOutValue = PaidOutValue - (PaidOutValue / (1 + TaxRate))
	FROM         tbOrgPayment INNER JOIN
	                      tbSystemTaxCode ON tbOrgPayment.TaxCode = tbSystemTaxCode.TaxCode
	WHERE     (tbOrgPayment.AccountCode = @AccountCode)
	
	
	UPDATE    tbInvoice
	SET              PaidValue = 0, PaidTaxValue = 0, InvoiceStatusCode = 2
	WHERE     (AccountCode = @AccountCode) AND (InvoiceStatusCode <> 1)

	UPDATE tbInvoiceItem
	SET PaidValue = 0, PaidTaxValue = 0
	FROM         tbInvoiceItem INNER JOIN
	                      tbInvoice ON tbInvoiceItem.InvoiceNumber = tbInvoice.InvoiceNumber
	WHERE     (tbInvoice.AccountCode = @AccountCode) AND (tbInvoice.InvoiceStatusCode <> 1)	

	UPDATE tbInvoiceTask
	SET PaidValue = 0, PaidTaxValue = 0
	FROM         tbInvoiceTask INNER JOIN
	                      tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber
	WHERE     (tbInvoice.AccountCode = @AccountCode) AND (tbInvoice.InvoiceStatusCode <> 1)		

	open curInv
	fetch next from curInv into @InvoiceNumber, @TaskCode, @CashCode, @InvoiceValue, @TaxValue
	while @@FETCH_STATUS = 0
		begin
		
		print str(@Balance) + ' + ' + str((@InvoiceValue + @TaxValue))
		
		if @CashModeCode = 1		--EXPENSE
			begin
			if @Balance > 0
				if (@Balance + (@InvoiceValue + @TaxValue)) < 0
					set @PaidValue = @Balance
				else
					set @PaidValue = @InvoiceValue + @TaxValue
			else
				set @PaidValue = 0
			end
		else						--SALES
			begin
			if @Balance < 0
				if (@Balance + (@InvoiceValue + @TaxValue)) > 0
					set @PaidValue = @Balance
				else
					set @PaidValue = @InvoiceValue + @TaxValue			
			else
				set @PaidValue = 0
			end
		
		set @PaidValue = Abs(@PaidValue)
		
		set @Balance = @Balance + (@InvoiceValue + @TaxValue)
		
		if @PaidValue > 0
			begin
			set @TaxRate = @TaxValue / @InvoiceValue
			set @PaidInvoiceValue = @PaidValue - (@PaidValue - (@PaidValue / (1 + @TaxRate)))
			set @PaidTaxValue = @PaidInvoiceValue * @TaxRate

			if isnull(@TaskCode, '') = ''
				begin
				UPDATE    tbInvoiceItem
				SET              PaidValue = PaidValue + @PaidInvoiceValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
				WHERE     (InvoiceNumber = @InvoiceNumber) AND (CashCode = @CashCode)
				end
			else
				begin
				UPDATE   tbInvoiceTask
				SET              PaidValue = PaidValue + @PaidInvoiceValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
				WHERE     (InvoiceNumber = @InvoiceNumber) AND (TaskCode = @TaskCode)				
				end

			exec dbo.spInvoiceTotal @InvoiceNumber			
			
			end

		fetch next from curInv into @InvoiceNumber, @TaskCode, @CashCode, @InvoiceValue, @TaxValue
		end
	
	close curInv
	deallocate curInv

	exec dbo.spOrgBalanceOutstanding @AccountCode, @BalanceOutstanding output
	set @Balance = @Balance - @BalanceOutstanding
	
	UPDATE    tbOrg
	SET              CurrentBalance = OpeningBalance - @Balance
	WHERE     (AccountCode = @AccountCode)
		
	commit tran OrgRebuild
	

	RETURN 
GO
ALTER  PROCEDURE dbo.spInvoiceTotal 
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
CREATE TABLE [tbSystemRecurrence] (
	[RecurrenceCode] [smallint] NOT NULL ,
	[Recurrence] [nvarchar] (20) NOT NULL ,
	CONSTRAINT [PK_tbSystemRecurrence] PRIMARY KEY  CLUSTERED 
	(
		[RecurrenceCode]
	)  ON [PRIMARY] 
) ON [PRIMARY]
GO
insert into tbSystemRecurrence (RecurrenceCode, Recurrence) values (1, 'On Demand')
insert into tbSystemRecurrence (RecurrenceCode, Recurrence) values (2, 'Monthly')
insert into tbSystemRecurrence (RecurrenceCode, Recurrence) values (3, 'Quarterly')
insert into tbSystemRecurrence (RecurrenceCode, Recurrence) values (4, 'Bi-annual')
insert into tbSystemRecurrence (RecurrenceCode, Recurrence) values (5, 'Yearly')
GO
UPDATE tbCashTaxType
SET TaxType = 'Corporation Tax'
WHERE TaxTypeCode = 1
GO
ALTER TABLE [tbCashTaxType] WITH NOCHECK ADD
	[CashCode] [nvarchar] (50) NULL ,
	[MonthNumber] [smallint] NOT NULL CONSTRAINT [DF_tbSystemOptions_MonthNumber] DEFAULT (1),
	[RecurrenceCode] [smallint] NOT NULL CONSTRAINT [DF_tbSystemOptions_Recurrence] DEFAULT (1)
GO
ALTER TABLE [dbo].[tbCashTaxType] ADD 
	CONSTRAINT [FK_tbCashTaxType_tbCashCode] FOREIGN KEY 
	(
		[CashCode]
	) REFERENCES [dbo].[tbCashCode] (
		[CashCode]
	),
	CONSTRAINT [FK_tbCashTaxType_tbSystemMonth] FOREIGN KEY 
	(
		[MonthNumber]
	) REFERENCES [dbo].[tbSystemMonth] (
		[MonthNumber]
	),	
	CONSTRAINT [FK_tbCashTaxType_tbSystemRecurrence] FOREIGN KEY 
	(
		[RecurrenceCode]
	) REFERENCES [dbo].[tbSystemRecurrence] (
		[RecurrenceCode]
	)
GO
UPDATE tbCashTaxType
SET CashCode = CorporationTax, RecurrenceCode = 5
FROM         tbCashTaxType CROSS JOIN
                      tbSystemOptions
WHERE     (tbCashTaxType.TaxTypeCode = 1)
GO
UPDATE tbCashTaxType
SET CashCode = EmployersNI, RecurrenceCode = 2
FROM         tbCashTaxType CROSS JOIN
                      tbSystemOptions
WHERE     (tbCashTaxType.TaxTypeCode = 3)
GO
UPDATE tbCashTaxType
SET CashCode = Vat, RecurrenceCode = 3
FROM         tbCashTaxType CROSS JOIN
                      tbSystemOptions
WHERE     (tbCashTaxType.TaxTypeCode = 2)
GO
UPDATE tbCashTaxType
SET CashCode = GeneralTax, RecurrenceCode = 1
FROM         tbCashTaxType CROSS JOIN
                      tbSystemOptions
WHERE     (tbCashTaxType.TaxTypeCode = 4)
GO
ALTER TABLE tbSystemOptions DROP CONSTRAINT [FK_tbSystemRoot_tbCashCode]
GO 
ALTER TABLE tbSystemOptions DROP CONSTRAINT [FK_tbSystemRoot_tbCashCode1]
GO
ALTER TABLE tbSystemOptions DROP CONSTRAINT [FK_tbSystemRoot_tbCashCode2]
GO
ALTER TABLE tbSystemOptions DROP CONSTRAINT [FK_tbSystemRoot_tbCashCode3]
GO
ALTER TABLE tbSystemOptions DROP 
	COLUMN EmployersNI,
	COLUMN Vat,
	COLUMN CorporationTax,
	COLUMN GeneralTax
GO
ALTER TABLE [dbo].[tbSystemYearPeriod] DROP 
	CONSTRAINT [DF_tbSystemYearPeriod_MaterialStoreValue],
	CONSTRAINT [DF_tbSystemYearPeriod_MaterialWipValue],
	CONSTRAINT [DF_tbSystemYearPeriod_ProductionStoreValue],
	CONSTRAINT [DF_tbSystemYearPeriod_ProductionWipValue]
GO
	
ALTER TABLE tbSystemYearPeriod DROP
	COLUMN MaterialStoreValue,
	COLUMN MaterialWipValue,
	COLUMN ProductionStoreValue,
	COLUMN ProductionWipValue
GO
ALTER TABLE tbSystemYearPeriod WITH NOCHECK ADD
	CorporationTaxRate real NOT NULL CONSTRAINT [DF_tbSystemYearPeriod_CorporationTaxRate] DEFAULT (0)
GO
alter table tbSystemOptions with nocheck add
	NetProfitCode nvarchar(10) null
GO
alter table tbSystemOptions add
	CONSTRAINT [FK_tbSystemOption_tbCashCategory] FOREIGN KEY 
	(
		[NetProfitCode]
	) REFERENCES [dbo].[tbCashCategory] (
		[CategoryCode]
	)
GO
CREATE VIEW dbo.vwSystemCorpTaxCashCode
AS
SELECT     CashCode, MonthNumber, RecurrenceCode
FROM         dbo.tbCashTaxType
WHERE     (TaxTypeCode = 1)
GO
CREATE VIEW dbo.vwSystemNICashCode
AS
SELECT     CashCode, MonthNumber, RecurrenceCode
FROM         dbo.tbCashTaxType
WHERE     (TaxTypeCode = 3)
GO
CREATE VIEW dbo.vwSystemVatCashCode
AS
SELECT     CashCode, MonthNumber, RecurrenceCode
FROM         dbo.tbCashTaxType
WHERE     (TaxTypeCode = 2)
GO
alter table tbSystemOptions with nocheck add
	NetProfitTaxCode nvarchar(50) null
GO
CREATE FUNCTION dbo.fnCategoryTotalCashCodes
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
CREATE FUNCTION dbo.fnNetProfitCashCodes
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
CREATE VIEW dbo.vwCorpTaxInvoiceItems
AS
SELECT     TOP 100 PERCENT dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.InvoiceValue * - 1 ELSE dbo.tbInvoiceItem.InvoiceValue END AS InvoiceValue
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.fnNetProfitCashCodes() fnNetProfitCashCodes ON 
                      dbo.tbInvoiceItem.CashCode = fnNetProfitCashCodes.CashCode COLLATE Latin1_General_CI_AS INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
GO
CREATE VIEW dbo.vwCorpTaxInvoiceTasks
AS
SELECT     TOP 100 PERCENT dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.InvoiceValue * - 1 ELSE dbo.tbInvoiceTask.InvoiceValue END AS InvoiceValue
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.fnNetProfitCashCodes() fnNetProfitCashCodes ON 
                      dbo.tbInvoiceTask.CashCode = fnNetProfitCashCodes.CashCode COLLATE Latin1_General_CI_AS INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
GO
CREATE VIEW dbo.vwCorpTaxInvoiceBase
AS
SELECT     StartOn, SUM(InvoiceValue) AS NetProfit
FROM         dbo.vwCorpTaxInvoiceItems
GROUP BY StartOn
UNION
SELECT     StartOn, SUM(InvoiceValue) AS NetProfit
FROM         dbo.vwCorpTaxInvoiceTasks
GROUP BY StartOn
GO
CREATE VIEW dbo.vwCorpTaxInvoice
AS
SELECT     TOP 100 PERCENT dbo.tbSystemYearPeriod.StartOn, dbo.vwCorpTaxInvoiceBase.NetProfit, 
                      dbo.vwCorpTaxInvoiceBase.NetProfit * dbo.tbSystemYearPeriod.CorporationTaxRate AS CorporationTax
FROM         dbo.vwCorpTaxInvoiceBase INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.vwCorpTaxInvoiceBase.StartOn = dbo.tbSystemYearPeriod.StartOn
ORDER BY dbo.tbSystemYearPeriod.StartOn
GO
CREATE FUNCTION dbo.fnSystemCorpTaxBalance
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
ALTER  FUNCTION dbo.fnSystemVatBalance
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
ALTER  VIEW dbo.vwCashSummaryBase
AS
SELECT     ISNULL(SUM(ToCollect), 0) AS Collect, ISNULL(SUM(ToPay), 0) AS Pay, ISNULL(SUM(TaxValue), 0) + dbo.fnSystemVatBalance() 
                      + dbo.fnSystemCorpTaxBalance() AS Tax, dbo.fnCashCompanyBalance() AS CompanyBalance
FROM         dbo.vwCashSummaryInvoices
GO
ALTER  PROCEDURE dbo.spSettingNewCompany
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
CREATE FUNCTION dbo.fnTaxTypeDueDates
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
CREATE FUNCTION dbo.fnTaxVatTotals
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
CREATE VIEW dbo.vwTaxVatTotals
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
CREATE FUNCTION dbo.fnTaxVatStatement
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
CREATE VIEW dbo.vwTaxVatStatement
AS
SELECT     TOP 100 PERCENT *
FROM         dbo.fnTaxVatStatement() fnTaxVatStatement
ORDER BY StartOn, VatDue
GO
CREATE FUNCTION dbo.fnTaxCorpTotals
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
CREATE VIEW dbo.vwTaxCorpTotals
AS
SELECT     dbo.tbSystemYear.Description, dbo.tbSystemMonth.MonthName, dbo.vwCorpTaxInvoice.StartOn, dbo.vwCorpTaxInvoice.NetProfit, 
                      dbo.vwCorpTaxInvoice.CorporationTax
FROM         dbo.vwCorpTaxInvoice INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.vwCorpTaxInvoice.StartOn = dbo.tbSystemYearPeriod.StartOn INNER JOIN
                      dbo.tbSystemYear ON dbo.tbSystemYearPeriod.YearNumber = dbo.tbSystemYear.YearNumber INNER JOIN
                      dbo.tbSystemMonth ON dbo.tbSystemYearPeriod.MonthNumber = dbo.tbSystemMonth.MonthNumber
GO
CREATE FUNCTION dbo.fnTaxCorpStatement
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
ALTER  FUNCTION dbo.fnSystemCashCode
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
ALTER  PROCEDURE dbo.spSystemPeriodTransferAll
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
ALTER  PROCEDURE dbo.spCashFlowInitialise
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
