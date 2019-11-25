/*********************************************************
Trade Control
Import Data from the Version 2 Schema
Release: 3.02.1

Date: 7/5/2018
Author: IaM

Trade Control by Trade Control Ltd is licensed under GNU General Public License v3.0. 

You may obtain a copy of the License at

	https://www.gnu.org/licenses/gpl-3.0.en.html

*********************************************************/

--USE master;
--DROP DATABASE IF EXISTS misTradeControl;
--GO
USE misTradeControl
GO

/****** Object:  UserDefinedFunction [App].[fnAccountPeriod]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO

CREATE FUNCTION [App].[fnAccountPeriod]
	(
	@TransactedOn datetime
	)
RETURNS datetime
 AS
	BEGIN
	DECLARE @StartOn datetime
	SELECT TOP 1 @StartOn = StartOn
	FROM         App.tbYearPeriod
	WHERE     (StartOn <= @TransactedOn)
	ORDER BY StartOn DESC
	
	RETURN @StartOn
	END
GO

/****** Object:  UserDefinedFunction [App].[fnActiveStartOn]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO

CREATE FUNCTION [App].[fnActiveStartOn]
	()
RETURNS datetime
  AS
	BEGIN
	DECLARE @StartOn datetime
	SELECT @StartOn = StartOn FROM App.fnActivePeriod()
	RETURN @StartOn
	END
GO

/****** Object:  UserDefinedFunction [App].[fnAdjustDateToBucket]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO

/*****************************************
SCALAR FUNCTIONS
*****************************************/
--Dependent objects
CREATE FUNCTION [App].[fnAdjustDateToBucket]
	(
	@BucketDay smallint,
	@CurrentDate datetime
	)
RETURNS datetime
  AS
	BEGIN
	DECLARE @CurrentDay smallint
	DECLARE @Offset smallint
	DECLARE @AdjustedDay smallint
	
	SET @CurrentDay = DATEPART(dw, @CurrentDate)
	
	SET @AdjustedDay = CASE WHEN @CurrentDay > (7 - @@DATEFIRST + 1) THEN
				@CurrentDay - (7 - @@DATEFIRST + 1)
			ELSE
				@CurrentDay + (@@DATEFIRST - 1)
			END

	SET @Offset = CASE WHEN @BucketDay <= @AdjustedDay THEN
				@BucketDay - @AdjustedDay
			ELSE
				(7 - (@BucketDay - @AdjustedDay)) * -1
			END
	
		
	RETURN DATEADD(dd, @Offset, @CurrentDate)
	END
GO

/****** Object:  UserDefinedFunction [App].[fnAdjustToCalendar]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO


CREATE FUNCTION [App].[fnAdjustToCalendar]
	(
	@UserId nvarchar(10),
	@SourceDate datetime,
	@Days int
	)
RETURNS datetime
    AS
	BEGIN
	DECLARE @CalendarCode nvarchar(10)
	DECLARE @TargetDate datetime
	DECLARE @WorkingDay bit
	
	DECLARE @CurrentDay smallint
	DECLARE @Monday smallint
	DECLARE @Tuesday smallint
	DECLARE @Wednesday smallint
	DECLARE @Thursday smallint
	DECLARE @Friday smallint
	DECLARE @Saturday smallint
	DECLARE @Sunday smallint
		
	SET @TargetDate = @SourceDate

	SELECT     @CalendarCode = App.tbCalendar.CalendarCode, @Monday = Monday, @Tuesday = Tuesday, @Wednesday = Wednesday, @Thursday = Thursday, @Friday = Friday, @Saturday = Saturday, @Sunday = Sunday
	FROM         App.tbCalendar INNER JOIN
	                      Usr.tbUser ON App.tbCalendar.CalendarCode = Usr.tbUser.CalendarCode
	WHERE UserId = @UserId
	
	WHILE @Days > -1
		BEGIN
		SET @CurrentDay = App.fnWeekDay(@TargetDate)
		IF @CurrentDay = 1				
			SET @WorkingDay = CASE WHEN @Monday != 0 THEN 1 ELSE 0 END
		ELSE IF @CurrentDay = 2
			SET @WorkingDay = CASE WHEN @Tuesday != 0 THEN 1 ELSE 0 END
		ELSE IF @CurrentDay = 3
			SET @WorkingDay = CASE WHEN @Wednesday != 0 THEN 1 ELSE 0 END
		ELSE IF @CurrentDay = 4
			SET @WorkingDay = CASE WHEN @Thursday != 0 THEN 1 ELSE 0 END
		ELSE IF @CurrentDay = 5
			SET @WorkingDay = CASE WHEN @Friday != 0 THEN 1 ELSE 0 END
		ELSE IF @CurrentDay = 6
			SET @WorkingDay = CASE WHEN @Saturday != 0 THEN 1 ELSE 0 END
		ELSE IF @CurrentDay = 7
			SET @WorkingDay = CASE WHEN @Sunday != 0 THEN 1 ELSE 0 END
		
		IF @WorkingDay = 1
			BEGIN
			IF not EXISTS(SELECT     UnavailableOn
				        FROM         App.tbCalendarHoliday
				        WHERE     (CalendarCode = @CalendarCode) AND (UnavailableOn = @TargetDate))
				SET @Days = @Days - 1
			END
			
		IF @Days > -1
			SET @TargetDate = DATEADD(d, -1, @TargetDate)
		END
		

	RETURN @TargetDate
	END
GO

/****** Object:  UserDefinedFunction [App].[fnCashCode]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO

CREATE  FUNCTION [App].[fnCashCode]
	(
	@TaxTypeCode smallint
	)
RETURNS nvarchar(50)
  AS
	BEGIN
	DECLARE @CashCode nvarchar(50)
	
	SELECT @CashCode = CashCode
	FROM         Cash.tbTaxType
	WHERE     (TaxTypeCode = @TaxTypeCode)
		
	
	RETURN @CashCode
	END
GO

/****** Object:  UserDefinedFunction [Cash].[fnCodeDefaultAccount]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO

CREATE FUNCTION [Cash].[fnCodeDefaultAccount] 
	(
	@CashCode nvarchar(50)
	)
RETURNS nvarchar(10)
 AS
	BEGIN
	DECLARE @AccountCode nvarchar(10)
	IF EXISTS(SELECT     CashCode
	          FROM         Invoice.tbTask
	          WHERE     (CashCode = @CashCode))
		BEGIN
		SELECT  @AccountCode = Invoice.tbInvoice.AccountCode
		FROM         Invoice.tbTask INNER JOIN
		                      Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbTask.CashCode = @CashCode)
		ORDER BY Invoice.tbInvoice.InvoicedOn DESC		
		END
	ELSE IF EXISTS(SELECT     CashCode
	          FROM         Invoice.tbItem
	          WHERE     (CashCode = @CashCode))
		BEGIN
		SELECT  @AccountCode = Invoice.tbInvoice.AccountCode
		FROM         Invoice.tbItem INNER JOIN
		                      Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbItem.CashCode = @CashCode)		
		ORDER BY Invoice.tbInvoice.InvoicedOn DESC	
		END
	ELSE
		BEGIN	
		SELECT @AccountCode = AccountCode FROM App.tbOptions
		END
		
	RETURN @AccountCode
	END

GO

/****** Object:  UserDefinedFunction [App].[fnCompanyAccount]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO


CREATE FUNCTION [App].[fnCompanyAccount]()
RETURNS NVARCHAR(10)
AS
	BEGIN
	DECLARE @AccountCode NVARCHAR(10)
	SELECT @AccountCode = AccountCode FROM App.tbOptions
	RETURN @AccountCode
	END

GO

/****** Object:  UserDefinedFunction [Cash].[fnCompanyBalance]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO

CREATE FUNCTION [Cash].[fnCompanyBalance]
	()
RETURNS MONEY
  AS
	BEGIN
	DECLARE @CurrentBalance MONEY
	
	SELECT  @CurrentBalance = SUM( Org.tbAccount.CurrentBalance)
	FROM         Org.tbAccount 
	WHERE     ( Org.tbAccount.AccountClosed = 0)
	
	RETURN ISNULL(@CurrentBalance, 0)
	END
GO

/****** Object:  UserDefinedFunction [App].[fnCorpTaxBalance]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO

CREATE FUNCTION [App].[fnCorpTaxBalance]
	()
RETURNS money
  AS
	BEGIN
	DECLARE @Balance money
	SELECT  @Balance = SUM(CorporationTax)
	FROM         Cash.vwCorpTaxInvoice
	
	SELECT  @Balance = @Balance + ISNULL(SUM( Org.tbPayment.PaidInValue - Org.tbPayment.PaidOutValue), 0)
	FROM         Org.tbPayment INNER JOIN
	                      App.vwCorpTaxCashCode ON Org.tbPayment.CashCode = App.vwCorpTaxCashCode.CashCode	                      

	IF @Balance < 0
		SET @Balance = 0
		
	RETURN isnull(@Balance, 0)
	END
GO

/****** Object:  UserDefinedFunction [Task].[fnCost]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO

CREATE FUNCTION [Task].[fnCost]
	(
	@TaskCode nvarchar(20)
	)
RETURNS money
AS
	BEGIN
	
	DECLARE @ChildTaskCode nvarchar(20)
	DECLARE @TotalCharge money
	DECLARE @TotalCost money
	DECLARE @CashModeCode smallint

	DECLARE curFlow cursor local for
		SELECT     Task.tbTask.TaskCode, Task.vwCashMode.CashModeCode, Task.tbTask.TotalCharge
		FROM         Task.tbTask INNER JOIN
							  Task.tbFlow ON Task.tbTask.TaskCode = Task.tbFlow.ChildTaskCode INNER JOIN
							  Task.vwCashMode ON Task.tbTask.TaskCode = Task.vwCashMode.TaskCode
		WHERE     ( Task.tbFlow.ParentTaskCode = @TaskCode)	

	OPEN curFlow
	FETCH NEXT FROM curFlow INTO @ChildTaskCode, @CashModeCode, @TotalCharge
	WHILE @@FETCH_STATUS = 0
		BEGIN
		SET @TotalCost = @TotalCost + CASE WHEN @CashModeCode = 0 THEN @TotalCharge ELSE @TotalCharge * -1 END
		SET @TotalCost = @TotalCost + Task.fnCost(@ChildTaskCode)
		FETCH NEXT FROM curFlow INTO @ChildTaskCode, @CashModeCode, @TotalCharge
		END
	
	CLOSE curFlow
	DEALLOCATE curFlow
	
	RETURN @TotalCost
	END
GO

/****** Object:  UserDefinedFunction [Cash].[fnCurrentBalance]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO

CREATE FUNCTION [Cash].[fnCurrentBalance]
	()
RETURNS money
AS
	BEGIN
	DECLARE @CurrentBalance money
	
	SELECT    @CurrentBalance = SUM( Org.tbAccount.CurrentBalance)
	FROM         Org.tbAccount INNER JOIN
	                      Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
	WHERE     ( Org.tbAccount.AccountClosed = 0)
	
	RETURN ISNULL(@CurrentBalance, 0)
	END
GO

/****** Object:  UserDefinedFunction [App].[fnDateBucket]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO

CREATE FUNCTION [App].[fnDateBucket]
	(@CurrentDate datetime, @BucketDate datetime)
RETURNS smallint
  AS
	BEGIN
	DECLARE @Period smallint
	SELECT  @Period = Period
	FROM         App.fnBuckets(@CurrentDate) fnEnvBuckets
	WHERE     (StartDate <= @BucketDate) AND (EndDate > @BucketDate) 
	RETURN @Period
	END
GO

/****** Object:  UserDefinedFunction [Task].[fnDefaultPaymentOn]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO

CREATE FUNCTION [Task].[fnDefaultPaymentOn]
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
	
	SELECT @UserId =  UserId
	FROM         Usr.tbUser
	WHERE     (LogonName = SUSER_SNAME())

	SELECT @PaymentDays = PaymentDays, @PayDaysFromMonthEnd = PayDaysFromMonthEnd
	FROM         Org.tbOrg
	WHERE     (AccountCode = @AccountCode)
	
	IF (@PayDaysFromMonthEnd <> 0)
		SET @PaymentOn = DATEADD(d, @PaymentDays, DATEADD(d, ((day(@ActionOn) - 1) + 1) * -1, DATEADD(m, 1, @ActionOn)))
	ELSE
		SET @PaymentOn = DATEADD(d, @PaymentDays, @ActionOn)
		
	SET @PaymentOn = App.fnAdjustToCalendar(@UserId, @PaymentOn, 0)	
	
	
	RETURN @PaymentOn
	END

GO

/****** Object:  UserDefinedFunction [Task].[fnDefaultTaxCode]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO

CREATE FUNCTION [Task].[fnDefaultTaxCode] 
	(
	@AccountCode nvarchar(10),
	@CashCode nvarchar(50)
	)
RETURNS nvarchar(10)
  AS
	BEGIN
	DECLARE @TaxCode nvarchar(10)
	
	IF (not @AccountCode is null) and (not @CashCode is null)
		BEGIN
		IF EXISTS(SELECT     TaxCode
			  FROM         Org.tbOrg
			  WHERE     (AccountCode = @AccountCode) AND (NOT (TaxCode IS NULL)))
			BEGIN
			SELECT    @TaxCode = TaxCode
			FROM         Org.tbOrg
			WHERE     (AccountCode = @AccountCode) AND (NOT (TaxCode IS NULL))
			END
		ELSE
			BEGIN
			SELECT    @TaxCode =  TaxCode
			FROM         Cash.tbCode
			WHERE     (CashCode = @CashCode)		
			END
		END
	ELSE
		SET @TaxCode = null
				
	RETURN @TaxCode
	END
GO

/****** Object:  UserDefinedFunction [App].[fnDocInvoiceType]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO

CREATE FUNCTION [App].[fnDocInvoiceType]
	(
	@InvoiceTypeCode SMALLINT
	)
RETURNS SMALLINT
AS
	BEGIN
	DECLARE @DocTypeCode SMALLINT
	
	SET @DocTypeCode = CASE @InvoiceTypeCode
		WHEN 0 THEN 4		--sales invoice
		WHEN 1 THEN 5		--credit note
		WHEN 3 THEN 6		--debit note
		ELSE 8				--error
		END
	
	RETURN @DocTypeCode
	END

GO

/****** Object:  UserDefinedFunction [App].[fnDocTaskType]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO

CREATE FUNCTION [App].[fnDocTaskType]
	(
	@TaskCode NVARCHAR(20)
	)
RETURNS SMALLINT
AS
	BEGIN
	DECLARE @DocTypeCode SMALLINT
	DECLARE @TaskStatusCode SMALLINT
	DECLARE @CashModeCode SMALLINT
	
	SELECT    @CashModeCode = Cash.tbCategory.CashModeCode, @TaskStatusCode = Task.tbTask.TaskStatusCode
	FROM            Task.tbTask INNER JOIN
	                         Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
	                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE TaskCode = @TaskCode
	
	SET @DocTypeCode = CASE 
		WHEN @CashModeCode = 0 THEN						--Expense
			CASE WHEN @TaskStatusCode = 0 THEN 2		--Enquiry
				ELSE 4 END			
		WHEN @CashModeCode = 1 THEN						--Income
			CASE WHEN @TaskStatusCode = 0 THEN 0		--Quote
				ELSE 2 END
		END
				
	RETURN @DocTypeCode
	END

GO

/****** Object:  UserDefinedFunction [Task].[fnEmailAddress]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO

CREATE FUNCTION [Task].[fnEmailAddress]
	(
	@TaskCode nvarchar(20)
	)
RETURNS nvarchar(255)
AS
	BEGIN
	DECLARE @EmailAddress nvarchar(255)

	IF EXISTS(SELECT     Org.tbContact.EmailAddress
		  FROM         Org.tbContact INNER JOIN
								tbTask ON Org.tbContact.AccountCode = Task.tbTask.AccountCode AND Org.tbContact.ContactName = Task.tbTask.ContactName
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
	
	RETURN @EmailAddress
	END

GO

/****** Object:  UserDefinedFunction [App].[fnHistoryStartOn]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO

CREATE FUNCTION [App].[fnHistoryStartOn]()
RETURNS DATETIME
AS
	BEGIN
	DECLARE @StartOn DATETIME
	SELECT  @StartOn = MIN( App.tbYearPeriod.StartOn)
	FROM            App.tbYear INNER JOIN
	                         App.tbYearPeriod ON App.tbYear.YearNumber = App.tbYearPeriod.YearNumber
	WHERE        ( App.tbYear.CashStatusCode < 3)
	
	RETURN @StartOn
	END

GO

/****** Object:  UserDefinedFunction [Org].[fnIndustrySectors]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO

CREATE FUNCTION [Org].[fnIndustrySectors]
	(
	@AccountCode nvarchar(10)
	)
RETURNS nvarchar(256)
  AS
	BEGIN
	DECLARE @IndustrySector nvarchar(256)
	
	IF EXISTS(SELECT IndustrySector FROM Org.tbSector WHERE AccountCode = @AccountCode)
		BEGIN
		DECLARE @Sector nvarchar(50)
		SET @IndustrySector = ''
		DECLARE cur cursor local for
			SELECT IndustrySector FROM Org.tbSector WHERE AccountCode = @AccountCode
		OPEN cur
		FETCH NEXT FROM cur INTO @Sector
		WHILE @@FETCH_STATUS = 0
			BEGIN
			IF LEN(@IndustrySector) = 0
				SET @IndustrySector = @Sector
			ELSE IF LEN(@IndustrySector) <= 200
				SET @IndustrySector = @IndustrySector + ', ' + @Sector
			
			FETCH NEXT FROM cur INTO @Sector
			END
			
		CLOSE cur
		DEALLOCATE cur
		
		END	
	
	RETURN @IndustrySector
	END
GO

/****** Object:  UserDefinedFunction [Task].[fnIsExpense]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO

CREATE FUNCTION [Task].[fnIsExpense]
	(
	@TaskCode nvarchar(20)
	)
RETURNS bit
AS
	BEGIN
	/* An expense is a task assigned to an outgoing cash code that is not linked to a sale */
	DECLARE @IsExpense bit
	IF EXISTS (SELECT     Task.tbTask.TaskCode
	           FROM         Task.tbTask INNER JOIN
	                                 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
	                                 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	           WHERE     ( Cash.tbCategory.CashModeCode = 1) AND ( Task.tbTask.TaskCode = @TaskCode))
		SET @IsExpense = 0			          
	ELSE IF EXISTS(SELECT     ParentTaskCode
	          FROM         Task.tbFlow
	          WHERE     (ChildTaskCode = @TaskCode))
		BEGIN
		DECLARE @ParentTaskCode nvarchar(20)
		SELECT  @ParentTaskCode = ParentTaskCode
		FROM         Task.tbFlow
		WHERE     (ChildTaskCode = @TaskCode)		
		SET @IsExpense = Task.fnIsExpense(@ParentTaskCode)		
		END	              
	ELSE
		SET @IsExpense = 1
			
	RETURN @IsExpense
	END

GO

/****** Object:  UserDefinedFunction [App].[fnParsePrimaryKey]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO

CREATE FUNCTION [App].[fnParsePrimaryKey](@PK NVARCHAR(50)) RETURNS BIT
AS
	BEGIN
		DECLARE @ParseOk BIT = 0;

		SET @ParseOk = CASE		
				WHEN CHARINDEX('"', @PK) > 0 THEN 0	
				WHEN CHARINDEX('''', @PK) > 0 THEN 0	
				WHEN CHARINDEX(',', @PK) > 0 THEN 0	
				WHEN CHARINDEX('<', @PK) > 0 THEN 0	
				WHEN CHARINDEX('>', @PK) > 0 THEN 0	
				WHEN CHARINDEX('@', @PK) > 0 THEN 0	
				WHEN CHARINDEX(':', @PK) > 0 THEN 0	
				WHEN CHARINDEX('*', @PK) > 0 THEN 0	
				WHEN CHARINDEX('[', @PK) > 0 THEN 0	
				WHEN CHARINDEX(']', @PK) > 0 THEN 0	
				WHEN CHARINDEX('{', @PK) > 0 THEN 0	
				WHEN CHARINDEX('}', @PK) > 0 THEN 0	
				--WHEN CHARINDEX('_', @PK) > 0 THEN 0	
				--WHEN CHARINDEX('&', @PK) > 0 THEN 0	
				--WHEN CHARINDEX('/', @PK) > 0 THEN 0	
				--WHEN CHARINDEX('\', @PK) > 0 THEN 0	
				--WHEN CHARINDEX(' ', @PK) > 0 THEN 0	
				--WHEN CHARINDEX('(', @PK) > 0 THEN 0	
				--WHEN CHARINDEX(')', @PK) > 0 THEN 0	
				ELSE 1 END;

		RETURN @ParseOk;
	END
GO

/****** Object:  UserDefinedFunction [App].[fnProfileText]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO

CREATE FUNCTION [App].[fnProfileText]
	(
	@TextId int
	)
RETURNS nvarchar(255)
  AS
	BEGIN
	DECLARE @Message nvarchar(255)
	SELECT TOP 1 @Message = Message FROM App.tbText
	WHERE TextId = @TextId
	RETURN @Message
	END
GO

/****** Object:  UserDefinedFunction [Cash].[fnReserveBalance]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO

CREATE FUNCTION [Cash].[fnReserveBalance]
	()
RETURNS money
AS
	BEGIN
	DECLARE @CurrentBalance money
	
	SELECT    @CurrentBalance = SUM( Org.tbAccount.CurrentBalance)
	FROM         Org.tbAccount LEFT OUTER JOIN
	                      Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
	WHERE     ( Org.tbAccount.AccountClosed = 0) AND ( Cash.tbCode.CashCode IS NULL)
	
	RETURN isnull(@CurrentBalance, 0)
	END
GO

/****** Object:  UserDefinedFunction [Org].[fnStatementTaxAccount]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO

CREATE FUNCTION [Org].[fnStatementTaxAccount]
	(
	@TaxTypeCode smallint
	)
RETURNS nvarchar(10)
  AS
	BEGIN
	DECLARE @AccountCode nvarchar(10)
	IF EXISTS (SELECT     AccountCode
		FROM         Cash.tbTaxType
		WHERE     (TaxTypeCode = @TaxTypeCode) AND (NOT (AccountCode IS NULL)))
		BEGIN
		SELECT @AccountCode = AccountCode
		FROM         Cash.tbTaxType
		WHERE     (TaxTypeCode = @TaxTypeCode) AND (NOT (AccountCode IS NULL))
		END
	ELSE
		BEGIN
		SELECT TOP 1 @AccountCode = AccountCode
		FROM         App.tbOptions		
		END
			
	
	RETURN @AccountCode
	END
GO

/****** Object:  UserDefinedFunction [App].[fnTaxHorizon]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO

CREATE FUNCTION [App].[fnTaxHorizon]	()
RETURNS SMALLINT
AS
	BEGIN
	DECLARE @TaxHorizon SMALLINT
	SELECT @TaxHorizon = TaxHorizon FROM App.tbOptions
	RETURN @TaxHorizon
	END

GO

/****** Object:  UserDefinedFunction [App].[fnVatBalance]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO

CREATE  FUNCTION [App].[fnVatBalance]
	()
RETURNS money
  AS
	BEGIN
	DECLARE @Balance money
	SELECT  @Balance = SUM(HomeSalesVat - HomePurchasesVat + ExportSalesVat - ExportPurchasesVat)
	FROM         Invoice.vwVatSummary
	
	SELECT  @Balance = @Balance + ISNULL(SUM( Org.tbPayment.PaidInValue - Org.tbPayment.PaidOutValue), 0)
	FROM         Org.tbPayment INNER JOIN
	                      App.vwVatCashCode ON Org.tbPayment.CashCode = App.vwVatCashCode.CashCode	                      

	SELECT @Balance = @Balance + SUM(VatAdjustment)
	FROM App.tbYearPeriod

	RETURN isnull(@Balance, 0)
	END
GO

/****** Object:  UserDefinedFunction [App].[fnWeekDay]    Script Date: 18/06/2018 18:07:09 ******/

GO


GO

CREATE FUNCTION [App].[fnWeekDay]
	(
	@Date datetime
	)
RETURNS smallint
    AS
	BEGIN
	DECLARE @CurrentDay smallint
	SET @CurrentDay = DATEPART(dw, @Date)
	RETURN 	CASE WHEN @CurrentDay > (7 - @@DATEFIRST + 1) THEN
				@CurrentDay - (7 - @@DATEFIRST + 1)
			ELSE
				@CurrentDay + (@@DATEFIRST - 1)
			END
	END
GO

/****** Object:  UserDefinedFunction [App].[fnActivePeriod]    Script Date: 18/06/2018 18:08:08 ******/

GO


GO


CREATE FUNCTION [App].[fnActivePeriod]
	(
	)
RETURNS @tbSystemYearPeriod TABLE (YearNumber smallint, StartOn datetime, EndOn datetime, MonthName nvarchar(10), Description nvarchar(10), MonthNumber smallint) 
   AS
	BEGIN
	DECLARE @StartOn datetime
	DECLARE @EndOn datetime
	
	IF EXISTS (	SELECT     StartOn	FROM App.tbYearPeriod WHERE (CashStatusCode < 2))
		BEGIN
		SELECT @StartOn = MIN(StartOn)
		FROM         App.tbYearPeriod
		WHERE     (CashStatusCode < 2)
		
		IF EXISTS (SELECT StartOn FROM App.tbYearPeriod WHERE StartOn > @StartOn)
			SELECT TOP 1 @EndOn = StartOn FROM App.tbYearPeriod WHERE StartOn > @StartOn order by StartOn
		ELSE
			SET @EndOn = DATEADD(m, 1, @StartOn)
			
		INSERT INTO @tbSystemYearPeriod (YearNumber, StartOn, EndOn, MonthName, Description, MonthNumber)
		SELECT     App.tbYearPeriod.YearNumber, App.tbYearPeriod.StartOn, @EndOn, App.tbMonth.MonthName, App.tbYear.Description, App.tbMonth.MonthNumber
		FROM         App.tbYearPeriod INNER JOIN
		                      App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
		                      App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE     ( App.tbYearPeriod.StartOn = @StartOn)
		END	
	RETURN
	END
GO

/****** Object:  UserDefinedFunction [App].[fnBuckets]    Script Date: 18/06/2018 18:08:08 ******/

GO


GO

CREATE FUNCTION [App].[fnBuckets]
	(@CurrentDate datetime)
RETURNS  @tbBkn TABLE (Period smallint, BucketId nvarchar(10), StartDate datetime, EndDate datetime)
  AS
	BEGIN
	DECLARE @BucketTypeCode smallint
	DECLARE @UnitOfTimeCode smallint
	DECLARE @Period smallint	
	DECLARE @CurrentPeriod smallint
	DECLARE @Offset smallint
	
	DECLARE @StartDate datetime
	DECLARE @EndDate datetime
	DECLARE @BucketId nvarchar(10)
		
	SELECT     TOP 1 @BucketTypeCode = BucketTypeCode, @UnitOfTimeCode = BucketIntervalCode
	FROM         App.tbOptions
		
	SET @EndDate = 
		CASE @BucketTypeCode
			WHEN 0 THEN
				@CurrentDate
			WHEN 8 THEN
				DATEADD(d, Day(@CurrentDate) * -1 + 1, @CurrentDate)
			ELSE
				App.fnAdjustDateToBucket(@BucketTypeCode, @CurrentDate)
		END
			
	SET @EndDate = CAST(@EndDate AS date)
	SET @StartDate = DATEADD(yyyy, -100, @EndDate)
	SET @CurrentPeriod = 0
	
	DECLARE curBk cursor for			
		SELECT     Period, BucketId
		FROM         App.tbBucket
		ORDER BY Period

	OPEN curBk
	FETCH NEXT FROM curBk INTO @Period, @BucketId
	WHILE @@FETCH_STATUS = 0
		BEGIN
		IF @Period > 0
			BEGIN
			SET @StartDate = @EndDate
			SET @Offset = @Period - @CurrentPeriod
			SET @EndDate = CASE @UnitOfTimeCode
				WHEN 1 THEN		--day
					DATEADD(d, @Offset, @StartDate) 					
				WHEN 2 THEN		--week
					DATEADD(d, @Offset * 7, @StartDate)
				WHEN 3 THEN		--month
					DATEADD(m, @Offset, @StartDate)
				END
			END
		
		INSERT INTO @tbBkn(Period, BucketId, StartDate, EndDate)
		VALUES (@Period, @BucketId, @StartDate, @EndDate)
		
		SET @CurrentPeriod = @Period
		
		FETCH NEXT FROM curBk INTO @Period, @BucketId
		END
		
			
	RETURN
	END

GO

/****** Object:  UserDefinedFunction [Cash].[fnAccountStatement]    Script Date: 18/06/2018 18:08:08 ******/

GO


GO



--Table-valued functions
CREATE FUNCTION [Cash].[fnAccountStatement]
	(
		@CashAccountCode nvarchar(10)
	)
RETURNS @tbCash TABLE (EntryNumber int, PaymentCode nvarchar(20), PaidOn datetime, PaidBalance money, TaxedBalance money)
  AS
	BEGIN
	DECLARE @EntryNumber int
	DECLARE @PaymentCode nvarchar(20)
	DECLARE @PaidOn datetime
	DECLARE @Paid money
	DECLARE @Taxed money
	DECLARE @PaidBalance money
	DECLARE @TaxedBalance money
		
	SELECT   @PaidBalance = OpeningBalance
	FROM         Org.tbAccount
	WHERE     (CashAccountCode = @CashAccountCode)

	SELECT    @PaidOn = MIN(PaidOn) 
	FROM         Org.tbPayment
	WHERE     (CashAccountCode = @CashAccountCode)
	
	SET @EntryNumber = 1
		
	INSERT INTO @tbCash (EntryNumber, PaymentCode, PaidOn, PaidBalance, TaxedBalance)
	VALUES (@EntryNumber, App.fnProfileText(3005), DATEADD(d, -1, @PaidOn), @PaidBalance, 0) 

	SET @EntryNumber = @EntryNumber + 1
	SET @TaxedBalance = 0
	
	DECLARE curCash cursor local for
		SELECT     PaymentCode, PaidOn, CASE WHEN PaidInValue > 0 THEN PaidInValue ELSE PaidOutValue * - 1 END AS Paid, 
		                      TaxOutValue - TaxInValue AS Taxed
		FROM         Org.tbPayment
		WHERE     (PaymentStatusCode = 1) AND (CashAccountCode = @CashAccountCode)
		ORDER BY PaidOn

	OPEN curCash
	FETCH NEXT FROM curCash INTO @PaymentCode, @PaidOn, @Paid, @Taxed
	WHILE @@FETCH_STATUS = 0
		BEGIN	
		SET @PaidBalance = @PaidBalance + @Paid
		SET @TaxedBalance = @TaxedBalance + @Taxed
		INSERT INTO @tbCash (EntryNumber, PaymentCode, PaidOn, PaidBalance, TaxedBalance)
		VALUES (@EntryNumber, @PaymentCode, @PaidOn, @PaidBalance, @TaxedBalance) 
		
		SET @EntryNumber = @EntryNumber + 1
		FETCH NEXT FROM curCash INTO @PaymentCode, @PaidOn, @Paid, @Taxed
		END
	
	CLOSE curCash
	DEALLOCATE curCash
		
	RETURN
	END



GO

/****** Object:  UserDefinedFunction [Cash].[fnAccountStatements]    Script Date: 18/06/2018 18:08:08 ******/

GO


GO

CREATE FUNCTION [Cash].[fnAccountStatements]
()
RETURNS  @tbCashAccount TABLE (CashAccountCode nvarchar(20), EntryNumber int, PaymentCode nvarchar(20), PaidOn datetime, PaidBalance money, TaxedBalance money)
  AS
	BEGIN
	DECLARE @CashAccountCode nvarchar(20)
	DECLARE curAccount cursor local for 
		SELECT     CashAccountCode
		FROM         Org.tbAccount
		WHERE     (AccountClosed = 0)
		ORDER BY CashAccountCode

	OPEN curAccount
	FETCH NEXT FROM curAccount INTO @CashAccountCode
	WHILE @@FETCH_STATUS = 0
		BEGIN
		INSERT INTO @tbCashAccount (CashAccountCode, EntryNumber, PaymentCode, PaidOn, PaidBalance, TaxedBalance)
		SELECT     @CashAccountCode As CashAccountCode, EntryNumber, PaymentCode, PaidOn, PaidBalance, TaxedBalance
		FROM         Cash.fnAccountStatement(@CashAccountCode) fnCashAccountStatement		
		FETCH NEXT FROM curAccount INTO @CashAccountCode
		END
	
	CLOSE curAccount
	DEALLOCATE curAccount
	
	RETURN
	END
GO

/****** Object:  UserDefinedFunction [Cash].[fnCategoryCashCodes]    Script Date: 18/06/2018 18:08:08 ******/

GO


GO

CREATE FUNCTION [Cash].[fnCategoryCashCodes]
	(
	@CategoryCode nvarchar(10)
	)
RETURNS @tbCashCode TABLE (CashCode nvarchar(50))
  AS
	BEGIN
	INSERT INTO @tbCashCode (CashCode)
	SELECT     Cash.tbCode.CashCode
	FROM         Cash.tbCategoryTotal INNER JOIN
	                      Cash.tbCategory ON Cash.tbCategoryTotal.ChildCode = Cash.tbCategory.CategoryCode INNER JOIN
	                      Cash.tbCode ON Cash.tbCategory.CategoryCode = Cash.tbCode.CategoryCode
	WHERE     ( Cash.tbCategoryTotal.ParentCode = @CategoryCode)
	
	DECLARE @ChildCode nvarchar(10)
	
	DECLARE curCat cursor local for
		SELECT     Cash.tbCategory.CategoryCode
		FROM         Cash.tbCategory INNER JOIN
		                      Cash.tbCategoryTotal ON Cash.tbCategory.CategoryCode = Cash.tbCategoryTotal.ChildCode
		WHERE     ( Cash.tbCategory.CategoryTypeCode = 1) AND ( Cash.tbCategoryTotal.ParentCode = @CategoryCode)
	
	OPEN curCat
	FETCH NEXT FROM curCat INTO @ChildCode
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		INSERT INTO @tbCashCode(CashCode)
		SELECT CashCode FROM Cash.fnCategoryCashCodes(@ChildCode)
		FETCH NEXT FROM curCat INTO @ChildCode
		END
	
	CLOSE curCat
	DEALLOCATE curCat
	
	RETURN
	END
GO

/****** Object:  UserDefinedFunction [Cash].[fnCorpTaxCashCodes]    Script Date: 18/06/2018 18:08:08 ******/

GO


GO

CREATE FUNCTION [Cash].[fnCorpTaxCashCodes]
	()
RETURNS @tbCashCode TABLE (CashCode nvarchar(50))
  AS
	BEGIN
	DECLARE @CategoryCode nvarchar(10)
	SELECT @CategoryCode = NetProfitCode FROM App.tbOptions	
	SET @CategoryCode = isnull(@CategoryCode, '')
	IF (@CategoryCode != '')
		BEGIN
		INSERT INTO @tbCashCode (CashCode)
		SELECT CashCode FROM Cash.fnCategoryCashCodes(@CategoryCode)
		END
	RETURN
	END
GO

/****** Object:  UserDefinedFunction [Cash].[fnStatementCompany]    Script Date: 18/06/2018 18:08:08 ******/

GO


GO

CREATE FUNCTION [Cash].[fnStatementCompany]()
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
	DECLARE @ReferenceCode nvarchar(20) 
	DECLARE @CashCode nvarchar(50)
	DECLARE @AccountCode nvarchar(10)
	DECLARE @TransactOn datetime
	DECLARE @CashEntryTypeCode smallint
	DECLARE @PayOut money
	DECLARE @PayIn money
	DECLARE @Balance money

	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, CashCode, PayIn, PayOut)	
	SELECT     Invoice.tbItem.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.CollectOn, 1 AS CashEntryTypeCode, Invoice.tbItem.CashCode, 
	                      SUM(CASE WHEN InvoiceTypeCode = 0 OR
	                      InvoiceTypeCode = 3 THEN ( Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue) - ( Invoice.tbItem.PaidValue + Invoice.tbItem.PaidTaxValue) 
	                      ELSE 0 END) AS PayIn, SUM(CASE WHEN InvoiceTypeCode = 2 OR
	                      InvoiceTypeCode = 2 THEN ( Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue) - ( Invoice.tbItem.PaidValue + Invoice.tbItem.PaidTaxValue) 
	                      ELSE 0 END) AS PayOut
	FROM         Invoice.tbItem INNER JOIN
	                      Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
	                      Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode INNER JOIN
	                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE     (( Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue) - ( Invoice.tbItem.PaidValue + Invoice.tbItem.PaidTaxValue) > 0)
	GROUP BY Invoice.tbItem.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.CollectOn, Invoice.tbItem.CashCode

	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, CashCode, PayIn, PayOut)		
	SELECT     Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.CollectOn, 1 AS CashEntryTypeCode, Invoice.tbTask.CashCode, 
	                      SUM(CASE WHEN InvoiceTypeCode = 0 OR
	                      InvoiceTypeCode = 3 THEN ( Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue) - ( Invoice.tbTask.PaidValue + Invoice.tbTask.PaidTaxValue) 
	                      ELSE 0 END) AS PayIn, SUM(CASE WHEN InvoiceTypeCode = 1 OR
	                      InvoiceTypeCode = 2 THEN ( Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue) - ( Invoice.tbTask.PaidValue + Invoice.tbTask.PaidTaxValue) 
	                      ELSE 0 END) AS PayOut
	FROM         Invoice.tbTask INNER JOIN
	                      Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
	                      Cash.tbCode ON Invoice.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
	                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE     (( Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue) - ( Invoice.tbTask.PaidValue + Invoice.tbTask.PaidTaxValue) > 0)
	GROUP BY Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.CollectOn, Invoice.tbTask.CashCode
		
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	SELECT     ReferenceCode, AccountCode, PaymentOn, CashEntryTypeCode, PayIn, PayOut, CashCode
	FROM         Cash.vwStatementTasksConfirmed			
	
	--Corporation Tax
	IF EXISTS (SELECT        Org.tbAccount.CashAccountCode
	           FROM            Cash.tbTaxType INNER JOIN
	                                    Org.tbAccount ON Cash.tbTaxType.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
	                                    Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
	           WHERE        ( Cash.tbTaxType.TaxTypeCode = 0))
		BEGIN
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
		SELECT ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
		FROM Cash.fnStatementTaxEntries(1)
		ORDER BY TransactOn		
		END

	--VAT
	IF EXISTS (SELECT        Org.tbAccount.CashAccountCode
	           FROM            Cash.tbTaxType INNER JOIN
	                                    Org.tbAccount ON Cash.tbTaxType.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
	                                    Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
	           WHERE        ( Cash.tbTaxType.TaxTypeCode = 1))
		BEGIN	
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
		SELECT ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
		FROM Cash.fnStatementTaxEntries(2)
		ORDER BY TransactOn		
		END

	SELECT @ReferenceCode = App.fnProfileText(3013)
	SET @Balance = Cash.fnCurrentBalance()	
	SELECT @TransactOn = DATEADD(d, -1, MIN(TransactOn)) FROM @tbStatement
	SELECT TOP 1 @AccountCode = AccountCode FROM App.tbOptions
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, Balance)
	VALUES (@ReferenceCode, @AccountCode, @TransactOn, 1, 0, 0, @Balance)
			
	DECLARE curSt cursor local for
		SELECT TransactOn, CashEntryTypeCode, ReferenceCode, PayIn, PayOut, CashCode
		FROM @tbStatement
		order by TransactOn, CashEntryTypeCode, ReferenceCode, CashCode

	OPEN curSt
	
	FETCH NEXT FROM curSt INTO @TransactOn, @CashEntryTypeCode, @ReferenceCode, @PayIn, @PayOut, @CashCode
	
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		SET @Balance = @Balance + @PayIn - @PayOut
		IF @CashCode IS NULL
			BEGIN
			UPDATE @tbStatement
			SET Balance = @Balance
			WHERE TransactOn = @TransactOn and CashEntryTypeCode = @CashEntryTypeCode and ReferenceCode = @ReferenceCode
			END
		ELSE
			BEGIN
			UPDATE @tbStatement
			SET Balance = @Balance
			WHERE TransactOn = @TransactOn and CashEntryTypeCode = @CashEntryTypeCode and ReferenceCode = @ReferenceCode and CashCode = @CashCode
			END
		FETCH NEXT FROM curSt INTO @TransactOn, @CashEntryTypeCode, @ReferenceCode, @PayIn, @PayOut, @CashCode
		END
	CLOSE curSt
	DEALLOCATE curSt
		
	RETURN
	END


GO

/****** Object:  UserDefinedFunction [Cash].[fnStatementReserves]    Script Date: 18/06/2018 18:08:08 ******/

GO


GO

CREATE FUNCTION [Cash].[fnStatementReserves] ()
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
	DECLARE @ReferenceCode nvarchar(20) 
	DECLARE @ReferenceCode2 nvarchar(20)
	DECLARE @CashCode nvarchar(50)
	DECLARE @AccountCode nvarchar(10)
	DECLARE @TransactOn datetime
	DECLARE @CashEntryTypeCode smallint
	DECLARE @PayOut money
	DECLARE @PayIn money
	DECLARE @Balance money
	DECLARE @Now datetime

	SELECT @ReferenceCode = App.fnProfileText(1219)
	SET @Balance = Cash.fnReserveBalance()	
	SELECT @TransactOn = MAX( Org.tbPayment.PaidOn)
	FROM         Org.tbAccount INNER JOIN
						  Org.tbPayment ON Org.tbAccount.CashAccountCode = Org.tbPayment.CashAccountCode LEFT OUTER JOIN
						  Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
	WHERE     ( Cash.tbCode.CashCode IS NULL)

	SELECT TOP 1 @AccountCode = AccountCode FROM App.tbOptions
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, Balance)
	VALUES (@ReferenceCode, @AccountCode, @TransactOn, 0, 0, 0, @Balance)

	--Corporation Tax
	IF EXISTS (SELECT        Org.tbAccount.CashAccountCode
		FROM            Cash.tbTaxType INNER JOIN
								 Org.tbAccount ON Cash.tbTaxType.CashAccountCode = Org.tbAccount.CashAccountCode LEFT OUTER JOIN
								 Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
		WHERE        ( Cash.tbTaxType.TaxTypeCode = 0) AND ( Cash.tbCode.CashCode IS NULL))
		BEGIN
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
		SELECT ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
		FROM Cash.fnStatementTaxEntries(1)
		ORDER BY TransactOn		
		END

	--VAT
	IF EXISTS (SELECT        Org.tbAccount.CashAccountCode
		FROM            Cash.tbTaxType INNER JOIN
								 Org.tbAccount ON Cash.tbTaxType.CashAccountCode = Org.tbAccount.CashAccountCode LEFT OUTER JOIN
								 Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
		WHERE        ( Cash.tbTaxType.TaxTypeCode = 1) AND ( Cash.tbCode.CashCode IS NULL))
		BEGIN	
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
		SELECT ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
		FROM Cash.fnStatementTaxEntries(2)
		ORDER BY TransactOn		
		END
			
	DECLARE curReserve cursor local for
		SELECT TransactOn, CashEntryTypeCode, ReferenceCode, PayIn, PayOut, CashCode
		FROM @tbStatement
		order by TransactOn, CashEntryTypeCode, ReferenceCode, CashCode

	OPEN curReserve
	
	FETCH NEXT FROM curReserve INTO @TransactOn, @CashEntryTypeCode, @ReferenceCode, @PayIn, @PayOut, @CashCode
	
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		SET @Balance = @Balance + @PayIn - @PayOut
		IF @CashCode IS NULL
			BEGIN
			UPDATE @tbStatement
			SET Balance = @Balance
			WHERE TransactOn = @TransactOn and CashEntryTypeCode = @CashEntryTypeCode and ReferenceCode = @ReferenceCode
			END
		ELSE
			BEGIN
			UPDATE @tbStatement
			SET Balance = @Balance
			WHERE TransactOn = @TransactOn and CashEntryTypeCode = @CashEntryTypeCode and ReferenceCode = @ReferenceCode and CashCode = @CashCode
			END
		FETCH NEXT FROM curReserve INTO @TransactOn, @CashEntryTypeCode, @ReferenceCode, @PayIn, @PayOut, @CashCode
		END
	CLOSE curReserve
	DEALLOCATE curReserve

	RETURN
	END
GO

/****** Object:  UserDefinedFunction [Cash].[fnStatementTaxEntries]    Script Date: 18/06/2018 18:08:08 ******/

GO


GO

CREATE FUNCTION [Cash].[fnStatementTaxEntries](@TaxTypeCode smallint)
RETURNS @tbTax TABLE (
	AccountCode nvarchar(10),
	CashCode nvarchar(50),
	TransactOn datetime,
	CashEntryTypeCode smallint,
	ReferenceCode nvarchar(20),
	PayIn money,
	PayOut money	 
	)
AS
	BEGIN
	DECLARE @AccountCode nvarchar(10)
	DECLARE @CashCode nvarchar(50)
	DECLARE @TransactOn datetime
	DECLARE @InvoiceReferenceCode nvarchar(20) 
	DECLARE @OrderReferenceCode nvarchar(20)
	DECLARE @CashEntryTypeCode smallint
	DECLARE @PayOut money
	DECLARE @PayIn money
	DECLARE @Balance money
	
	SET @InvoiceReferenceCode = App.fnProfileText(1214)	
	SET @OrderReferenceCode = App.fnProfileText(1215)	

	IF @TaxTypeCode = 0
		GOTO CorporationTax
	ELSE IF @TaxTypeCode = 1
		GOTO VatTax

	RETURN

CorporationTax:

	SELECT @AccountCode = AccountCode FROM Cash.tbTaxType WHERE (TaxTypeCode = 0) 
	SET @CashCode = App.fnCashCode(0)
	
	DECLARE curCorp CURSOR LOCAL FOR
		SELECT     StartOn, ROUND(TaxDue, 0) AS PayOut, ROUND(TaxPaid, 0) AS PayIn, Balance
		FROM         Cash.vwTaxCorpStatement
		ORDER BY StartOn DESC
	
	OPEN curCorp
	FETCH NEXT FROM curCorp INTO @TransactOn, @PayOut, @PayIn, @Balance
	WHILE (@@FETCH_STATUS = 0 AND ROUND(@Balance, 0) != 0)
		BEGIN		
		IF @PayOut > 0
			BEGIN
			INSERT INTO @tbTax (AccountCode, CashCode, TransactOn, CashEntryTypeCode, ReferenceCode, PayOut, PayIn)
			VALUES (@AccountCode, @CashCode, @TransactOn, 4, @InvoiceReferenceCode, @PayOut, 0)
			END
		ELSE	
			BEGIN	
			SET @PayIn = @PayIn * -1
			INSERT INTO @tbTax (AccountCode, CashCode, TransactOn, CashEntryTypeCode, ReferenceCode, PayOut, PayIn)
			VALUES (@AccountCode, @CashCode, @TransactOn, 4, @InvoiceReferenceCode, 0, @PayIn)			
			END
			
		FETCH NEXT FROM curCorp INTO @TransactOn, @PayOut, @PayIn, @Balance
		END	

	CLOSE curCorp
	DEALLOCATE curCorp
	
	INSERT INTO @tbTax (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)	
	SELECT     @OrderReferenceCode, @AccountCode, StartOn, 4, 0, CorporationTax, @CashCode
	FROM Cash.fnTaxCorpOrderTotals(0)
	WHERE CorporationTax > 0	
	
	RETURN

VatTax:

	SELECT @AccountCode = AccountCode FROM Cash.tbTaxType WHERE (TaxTypeCode = 1) 
	SET @CashCode = App.fnCashCode(1)

	DECLARE curVat CURSOR LOCAL FOR
		SELECT     StartOn, ROUND(VatDue, 0) AS PayOut, ROUND(VatPaid, 0) AS PayIn, Balance
		FROM         Cash.vwTaxVatStatement
		ORDER BY StartOn DESC
	
	OPEN curVat
	FETCH NEXT FROM curVat INTO @TransactOn, @PayOut, @PayIn, @Balance
	WHILE (@@FETCH_STATUS = 0 AND ROUND(@Balance, 2) != 0)
		BEGIN		
		IF @PayOut != 0
			BEGIN
			INSERT INTO @tbTax (AccountCode, CashCode, TransactOn, CashEntryTypeCode, ReferenceCode, PayOut, PayIn)
			VALUES (@AccountCode, @CashCode, @TransactOn, 5, @InvoiceReferenceCode, @PayOut, 0)
			END
		ELSE	
			BEGIN	
			SET @PayIn = @PayIn * -1
			INSERT INTO @tbTax (AccountCode, CashCode, TransactOn, CashEntryTypeCode, ReferenceCode, PayOut, PayIn)
			VALUES (@AccountCode, @CashCode, @TransactOn, 5, @InvoiceReferenceCode, 0, @PayIn)			
			END
		FETCH NEXT FROM curVat INTO @TransactOn, @PayOut, @PayIn, @Balance
		END	

	CLOSE curVat
	DEALLOCATE curVat	
	
	INSERT INTO @tbTax (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)	
	SELECT     @OrderReferenceCode, @AccountCode, StartOn, 5, PayIn, PayOut, @CashCode
	FROM Cash.fnTaxVatOrderTotals(0)
	WHERE PayIn + PayOut > 0
		
	RETURN
	END

GO

/****** Object:  UserDefinedFunction [Cash].[fnTaxCorpOrderTotals]    Script Date: 18/06/2018 18:08:08 ******/

GO


GO


CREATE FUNCTION [Cash].[fnTaxCorpOrderTotals]
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
	DECLARE @PayOn datetime
	DECLARE @PayFrom datetime
	DECLARE @PayTo datetime
	
	DECLARE @NetProfit money
	DECLARE @CorporationTax money
	
	DECLARE @CashCode nvarchar(50)
	SET @CashCode = App.fnCashCode(0)
	
	DECLARE curVat cursor local for
		SELECT     PayOn, PayFrom, PayTo
		FROM         Cash.fnTaxTypeDueDates(0) fnTaxTypeDueDates
		
	OPEN curVat
	FETCH NEXT FROM curVat INTO @PayOn, @PayFrom, @PayTo
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		IF (@IncludeForecasts = 0)
			BEGIN
			INSERT INTO @tbCorp (CashCode, StartOn, NetProfit, CorporationTax)
			SELECT     @CashCode As CashCode, @PayOn AS PayOn, ISNULL(SUM(NetProfit), 0) AS NetProfit, ISNULL(SUM(CorporationTax), 0) AS CorporationTax
			FROM         Cash.vwCorpTaxConfirmed
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
			HAVING      (ISNULL(SUM(CorporationTax), 0) > 0)
			END
		ELSE
			BEGIN
			INSERT INTO @tbCorp (CashCode, StartOn, NetProfit, CorporationTax)
			SELECT     @CashCode As CashCode, @PayOn AS PayOn, ISNULL(SUM(NetProfit), 0) AS NetProfit, ISNULL(SUM(CorporationTax), 0) AS CorporationTax
			FROM         Cash.vwCorpTaxTasks
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
			HAVING      (ISNULL(SUM(CorporationTax), 0) > 0)
			END	
		
		FETCH NEXT FROM curVat INTO @PayOn, @PayFrom, @PayTo
		END
	
	CLOSE curVat
	DEALLOCATE curVat

	
	RETURN
	END
GO

/****** Object:  UserDefinedFunction [Cash].[fnTaxCorpStatement]    Script Date: 18/06/2018 18:08:08 ******/

GO


GO

CREATE FUNCTION [Cash].[fnTaxCorpStatement]()
RETURNS @tbCorp TABLE 
	(
	StartOn datetime, 
	TaxDue money ,
	TaxPaid money ,
	Balance money
	)
  AS
	BEGIN
	DECLARE @Balance money
	DECLARE @StartOn datetime
	DECLARE @TaxDue money
	DECLARE @TaxPaid money
	
	INSERT INTO @tbCorp (StartOn, TaxDue, TaxPaid, Balance)
	SELECT     StartOn, ROUND(CorporationTax, 2), 0 As TaxPaid, 0 AS Balance
	FROM         Cash.fnTaxCorpTotals() fnTaxCorpTotals		
	
	INSERT INTO @tbCorp (StartOn, TaxDue, TaxPaid, Balance)
	SELECT     Org.tbPayment.PaidOn, 0 As TaxDue, ( Org.tbPayment.PaidOutValue * -1) + Org.tbPayment.PaidInValue AS TaxPaid, 0 As Balance
	FROM         Org.tbPayment INNER JOIN
	                      App.vwCorpTaxCashCode ON Org.tbPayment.CashCode = App.vwCorpTaxCashCode.CashCode	                      

	SET @Balance = 0
	
	DECLARE curVS CURSOR LOCAL FOR
		SELECT StartOn, TaxDue, TaxPaid
		FROM @tbCorp
		ORDER BY StartOn, TaxDue
	
	OPEN curVS
	FETCH NEXT FROM curVS INTO @StartOn, @TaxDue, @TaxPaid
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		SET @Balance = @Balance + @TaxDue + @TaxPaid
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

/****** Object:  UserDefinedFunction [Cash].[fnTaxCorpTotals]    Script Date: 18/06/2018 18:08:08 ******/

GO


GO

CREATE FUNCTION [Cash].[fnTaxCorpTotals]
()
RETURNS @tbCorp TABLE 
	(
	StartOn datetime, 
	NetProfit money,
	CorporationTax money
	)
 AS
	BEGIN
	DECLARE @PayOn datetime
	DECLARE @PayFrom datetime
	DECLARE @PayTo datetime
	
	DECLARE curVat cursor local for
		SELECT     PayOn, PayFrom, PayTo
		FROM         Cash.fnTaxTypeDueDates(0) fnTaxTypeDueDates
		
	OPEN curVat
	FETCH NEXT FROM curVat INTO @PayOn, @PayFrom, @PayTo
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		INSERT INTO @tbCorp (StartOn, NetProfit, CorporationTax)
		SELECT     @PayOn AS PayOn, ISNULL(SUM(NetProfit), 0) AS NetProfit, ISNULL(SUM(CorporationTax), 0) AS CorporationTax
		FROM         Cash.vwCorpTaxInvoice
		WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
		
		FETCH NEXT FROM curVat INTO @PayOn, @PayFrom, @PayTo
		END
	
	CLOSE curVat
	DEALLOCATE curVat

	
	RETURN
	END
GO

/****** Object:  UserDefinedFunction [Cash].[fnTaxTypeDueDates]    Script Date: 18/06/2018 18:08:08 ******/

GO


GO

CREATE  FUNCTION [Cash].[fnTaxTypeDueDates](@TaxTypeCode smallint)
RETURNS @tbDueDate TABLE (PayOn datetime, PayFrom datetime, PayTo datetime)
 AS
	BEGIN
	DECLARE @MonthNumber smallint
	DECLARE @RecurrenceCode smallint
	DECLARE @MonthInterval smallint
	DECLARE @StartOn datetime
	
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
	
	-- Set PayTo
	DECLARE @PayOn datetime
	DECLARE @PayFrom datetime
		
	IF (@TaxTypeCode = 0)
		goto CorporationTax
	ELSE
		goto VatTax
		
	RETURN
	
CorporationTax:

	SELECT @StartOn = MIN(StartOn)
	FROM App.tbYearPeriod
	ORDER BY MIN(StartOn)
	
	SET @PayFrom = @StartOn
	
	SELECT @MonthNumber = MonthNumber
	FROM         App.tbYearPeriod
	WHERE StartOn = @StartOn

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
		order by min(PayOn)
		
		UPDATE @tbDueDate
		SET PayTo = @StartOn, PayFrom = @PayFrom
		WHERE PayOn = @PayOn
		
		SET @PayFrom = @StartOn
		
		SET @MonthNumber = CASE 
			WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
			ELSE (@MonthNumber + @MonthInterval) % 12
			END
		
		END

	DELETE FROM @tbDueDate WHERE PayTo is null
	
	RETURN

VatTax:

	DECLARE curTemp cursor for
		SELECT PayOn FROM @tbDueDate
		order by PayOn

	OPEN curTemp
	FETCH NEXT FROM curTemp INTO @PayOn	
	WHILE @@FETCH_STATUS = 0
		BEGIN
		UPDATE @tbDueDate
		SET 
			PayFrom = DATEADD(m, @MonthInterval * -1, @PayOn),
			PayTo = @PayOn
		WHERE PayOn = @PayOn

		FETCH NEXT FROM curTemp INTO @PayOn	
		END

	CLOSE curTemp
	DEALLOCATE curTemp
	
	RETURN
	
	END
GO

/****** Object:  UserDefinedFunction [Cash].[fnTaxVatOrderTotals]    Script Date: 18/06/2018 18:08:08 ******/

GO


GO

CREATE FUNCTION [Cash].[fnTaxVatOrderTotals]
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
	DECLARE @PayOn datetime
	DECLARE @PayFrom datetime
	DECLARE @PayTo datetime
	
	DECLARE @VatCharge money
	
	DECLARE @CashCode nvarchar(50)
	SET @CashCode = App.fnCashCode(1)
	
	DECLARE curVat cursor local for
		SELECT     PayOn, PayFrom, PayTo
		FROM         Cash.fnTaxTypeDueDates(1) fnTaxTypeDueDates
		
	OPEN curVat
	FETCH NEXT FROM curVat INTO @PayOn, @PayFrom, @PayTo
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		IF (@IncludeForecasts = 0)
			BEGIN
			INSERT INTO @tbVat (CashCode, StartOn, PayOut, PayIn)
			SELECT     @CashCode As CashCode, @PayOn AS PayOn, CASE WHEN ISNULL(SUM(VatValue), 0) > 0 THEN ISNULL(SUM(VatValue), 0) ELSE 0 END AS PayOut, 
			                      CASE WHEN ISNULL(SUM(VatValue), 0) < 0 THEN ABS(ISNULL(SUM(VatValue), 0)) ELSE 0 END AS PayIn
			FROM         Task.vwVatConfirmed
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo) AND (VatValue <> 0) 
			END
		ELSE
			BEGIN
			INSERT INTO @tbVat (CashCode, StartOn, PayOut, PayIn)
			SELECT    @CashCode AS CashCode, @PayOn AS PayOn, 
				CASE WHEN ISNULL(SUM(VatValue), 0) > 0 THEN ISNULL(SUM(VatValue), 0) ELSE 0 END AS PayOut, 
				CASE WHEN ISNULL(SUM(VatValue), 0) < 0 THEN ABS(ISNULL(SUM(VatValue), 0)) ELSE 0 END AS PayIn
			FROM         Task.vwVatFull
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo) 
			END		
						
		FETCH NEXT FROM curVat INTO @PayOn, @PayFrom, @PayTo
		END
	
	CLOSE curVat
	DEALLOCATE curVat

	
	RETURN
	END
GO

/****** Object:  UserDefinedFunction [Cash].[fnTaxVatStatement]    Script Date: 18/06/2018 18:08:08 ******/

GO


GO

CREATE FUNCTION [Cash].[fnTaxVatStatement]()
RETURNS @tbVat TABLE 
	(
	StartOn datetime, 
	VatDue money ,
	VatPaid money ,
	Balance money
	)
  AS
	BEGIN
	DECLARE @Balance money
	DECLARE @StartOn datetime
	DECLARE @VatDue money
	DECLARE @VatPaid money
	
	INSERT INTO @tbVat (StartOn, VatDue, VatPaid, Balance)
	SELECT     StartOn, VatDue, 0 As VatPaid, 0 AS Balance
	FROM         Cash.fnTaxVatTotals() fnTaxVatTotals	
	
	INSERT INTO @tbVat (StartOn, VatDue, VatPaid, Balance)
	SELECT     Org.tbPayment.PaidOn, 0 As VatDue, ( Org.tbPayment.PaidOutValue * -1) + Org.tbPayment.PaidInValue AS VatPaid, 0 As Balance
	FROM         Org.tbPayment INNER JOIN
	                      App.vwVatCashCode ON Org.tbPayment.CashCode = App.vwVatCashCode.CashCode	                      

	SET @Balance = 0
	
	DECLARE curVS CURSOR LOCAL FOR
		SELECT StartOn, VatDue, VatPaid
		FROM @tbVat
		ORDER BY StartOn, VatDue
	
	OPEN curVS
	FETCH NEXT FROM curVS INTO @StartOn, @VatDue, @VatPaid
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		SET @Balance = @Balance + @VatDue + @VatPaid
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

/****** Object:  UserDefinedFunction [Cash].[fnTaxVatTotals]    Script Date: 18/06/2018 18:08:08 ******/

GO


GO


CREATE FUNCTION [Cash].[fnTaxVatTotals]
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
	DECLARE @PayOn datetime
	DECLARE @PayFrom datetime
	DECLARE @PayTo datetime
	
	DECLARE curVat cursor local for
		SELECT     PayOn, PayFrom, PayTo
		FROM         Cash.fnTaxTypeDueDates(1) fnTaxTypeDueDates
		
	OPEN curVat
	FETCH NEXT FROM curVat INTO @PayOn, @PayFrom, @PayTo
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		INSERT INTO @tbVat (StartOn, HomeSales, HomePurchases, ExportSales, ExportPurchases, HomeSalesVat, HomePurchasesVat, ExportSalesVat, ExportPurchasesVat)
		SELECT     @PayOn AS PayOn, ISNULL(SUM(HomeSales), 0) AS HomeSales, ISNULL(SUM(HomePurchases), 0) AS HomePurchases, ISNULL(SUM(ExportSales), 0) AS ExportSales, 
		                      ISNULL(SUM(ExportPurchases), 0) AS ExportPurchases, ISNULL(SUM(HomeSalesVat), 0) AS HomeSalesVat, ISNULL(SUM(HomePurchasesVat), 0) AS HomePurchasesVat, 
		                      ISNULL(SUM(ExportSalesVat), 0) AS ExportSalesVat, ISNULL(SUM(ExportPurchasesVat), 0) AS ExportPurchasesVat
		FROM         Invoice.vwVatSummary
		WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
		
		FETCH NEXT FROM curVat INTO @PayOn, @PayFrom, @PayTo
		END
	
	CLOSE curVat
	DEALLOCATE curVat

	UPDATE @tbVat
	SET VatAdjustment = App.tbYearPeriod.VatAdjustment
	FROM @tbVat AS tb INNER JOIN
	                      App.tbYearPeriod ON tb.StartOn = App.tbYearPeriod.StartOn
	
	UPDATE @tbVat
	SET VatDue = (HomeSalesVat + ExportSalesVat) - (HomePurchasesVat + ExportPurchasesVat) + VatAdjustment
	
	RETURN
	END
GO

/****** Object:  UserDefinedFunction [Org].[fnStatement]    Script Date: 18/06/2018 18:08:08 ******/

GO


GO

CREATE FUNCTION [Org].[fnStatement]
	(
	@AccountCode nvarchar(10)
	)
RETURNS @tbStatement TABLE (TransactedOn datetime, OrderBy smallint, Reference nvarchar(50), StatementType nvarchar(20), Charge money, Balance money)
  AS
	BEGIN
	DECLARE @TransactedOn datetime
	DECLARE @OrderBy smallint
	DECLARE @Reference nvarchar(50)
	DECLARE @StatementType nvarchar(20)
	DECLARE @Charge money
	DECLARE @Balance money
	
	SELECT @StatementType = App.fnProfileText(3005)
	SELECT @Balance = OpeningBalance FROM Org.tbOrg WHERE AccountCode = @AccountCode
	
	SELECT   @TransactedOn = MIN(TransactedOn) 
	FROM         Org.vwStatementBase
	WHERE     (AccountCode = @AccountCode)
	
	INSERT INTO @tbStatement (TransactedOn, OrderBy, StatementType, Charge, Balance)
	VALUES (DATEADD(d, -1, @TransactedOn), 0, @StatementType, @Balance, @Balance)
	 
	DECLARE curAc cursor local for
		SELECT     TransactedOn, OrderBy, Reference, StatementType, Charge
		FROM         Org.vwStatementBase
		WHERE     (AccountCode = @AccountCode)
		ORDER BY TransactedOn, OrderBy

	OPEN curAc
	FETCH NEXT FROM curAc INTO @TransactedOn, @OrderBy, @Reference, @StatementType, @Charge
	WHILE @@FETCH_STATUS = 0
		BEGIN
		SET @Balance = @Balance + @Charge
		INSERT INTO @tbStatement (TransactedOn, OrderBy, Reference, StatementType, Charge, Balance)
		VALUES (@TransactedOn, @OrderBy, @Reference, @StatementType, @Charge, @Balance)
		
		FETCH NEXT FROM curAc INTO @TransactedOn, @OrderBy, @Reference, @StatementType, @Charge
		END
	
	CLOSE curAc
	DEALLOCATE curAc
		
	RETURN
	END


GO

/****** Object:  UserDefinedFunction [Task].[fnProfit]    Script Date: 18/06/2018 18:08:08 ******/

GO


GO

CREATE FUNCTION [Task].[fnProfit]()
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
DECLARE @StartOn datetime
DECLARE @TaskCode nvarchar(20)
DECLARE @TotalCharge money
DECLARE @InvoicedCharge money
DECLARE @InvoicedChargePaid money
DECLARE @TotalCost money
DECLARE @InvoicedCost money
DECLARE @InvoicedCostPaid money


	DECLARE curTasks cursor local for
		SELECT     StartOn, TaskCode, TotalCharge
		FROM         Task.vwProfitOrders
		ORDER BY StartOn

	OPEN curTasks
	FETCH NEXT FROM curTasks INTO @StartOn, @TaskCode, @TotalCharge
	
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		SET @InvoicedCharge = 0
		SET @InvoicedChargePaid = 0
		SET @TotalCost = 0
		SET @InvoicedCost = 0
		SET @InvoicedCostPaid = 0
				
		SELECT   @InvoicedCharge = InvoicedCharge, 
			@InvoicedChargePaid = InvoicedChargePaid, 
			@TotalCost = TotalCost, 
			@InvoicedCost = InvoicedCost, 
			@InvoicedCostPaid = InvoicedCostPaid
		FROM   Task.fnProfitOrder(@TaskCode) AS fnTaskProfitOrder_1
		
		INSERT INTO @tbTaskProfit (TaskCode, StartOn, TotalCharge, InvoicedCharge, InvoicedChargePaid, TotalCost, InvoicedCost, InvoicedCostPaid)
		VALUES (@TaskCode, @StartOn, @TotalCharge, @InvoicedCharge, @InvoicedChargePaid, @TotalCost, @InvoicedCost, @InvoicedCostPaid)
		
		FETCH NEXT FROM curTasks INTO @StartOn, @TaskCode, @TotalCharge	
		END
	
	CLOSE curTasks
	DEALLOCATE curTasks
		
	RETURN
	END
GO

/****** Object:  UserDefinedFunction [Task].[fnProfitCost]    Script Date: 18/06/2018 18:08:08 ******/

GO


GO

CREATE FUNCTION [Task].[fnProfitCost]
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
DECLARE @TaskCode nvarchar(20)
DECLARE @TotalCharge money
DECLARE @TotalInvoiced money
DECLARE @TotalPaid money
DECLARE @CashModeCode smallint

	DECLARE curFlow cursor local for
		SELECT     Task.tbTask.TaskCode, Task.vwCashMode.CashModeCode, Task.tbTask.TotalCharge
		FROM         Task.tbTask INNER JOIN
							  Task.tbFlow ON Task.tbTask.TaskCode = Task.tbFlow.ChildTaskCode INNER JOIN
							  Task.vwCashMode ON Task.tbTask.TaskCode = Task.vwCashMode.TaskCode
		WHERE     ( Task.tbFlow.ParentTaskCode = @ParentTaskCode)  AND ( Task.tbTask.TaskStatusCode < 4)	

	OPEN curFlow
	FETCH NEXT FROM curFlow INTO @TaskCode, @CashModeCode, @TotalCharge
	WHILE @@FETCH_STATUS = 0
		BEGIN
		
		SELECT  @TotalInvoiced = SUM(CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.InvoiceValue ELSE Invoice.tbTask.InvoiceValue * - 1 END), 
				@TotalPaid = SUM(CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.PaidValue ELSE Invoice.tbTask.PaidValue * - 1 END) 	                      
		FROM         Invoice.tbTask INNER JOIN
							  Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		WHERE     ( Invoice.tbTask.TaskCode = @TaskCode)

		SET @InvoicedCost = @InvoicedCost + isnull(@TotalInvoiced, 0)
		SET @InvoicedCostPaid = @InvoicedCostPaid + isnull(@TotalPaid, 0)
		SET @TotalCost = @TotalCost + CASE WHEN @CashModeCode = 0 THEN @TotalCharge ELSE @TotalCharge * -1 END
		
		SELECT @TotalCost = TotalCost, 
			@InvoicedCost = InvoicedCost, 
			@InvoicedCostPaid = InvoicedCostPaid
		FROM         Task.fnProfitCost(@TaskCode, @TotalCost, @InvoicedCost, @InvoicedCostPaid) AS fnTaskProfitCost_1	
		
		FETCH NEXT FROM curFlow INTO @TaskCode, @CashModeCode, @TotalCharge
		END
	
	CLOSE curFlow
	DEALLOCATE curFlow

	INSERT INTO @tbCost (TotalCost, InvoicedCost, InvoicedCostPaid)
	VALUES (@TotalCost, @InvoicedCost, @InvoicedCostPaid)		
	
	
	RETURN
	END

GO

/****** Object:  UserDefinedFunction [Task].[fnProfitOrder]    Script Date: 18/06/2018 18:08:08 ******/

GO


GO


CREATE FUNCTION [Task].[fnProfitOrder]
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
DECLARE @InvoicedCharge money
DECLARE @InvoicedChargePaid money
DECLARE @TotalCost money
DECLARE @InvoicedCost money
DECLARE @InvoicedCostPaid money

	SELECT  @InvoicedCharge = SUM(CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.InvoiceValue * - 1 ELSE Invoice.tbTask.InvoiceValue END), 
	@InvoicedChargePaid = SUM(CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.PaidValue * - 1 ELSE Invoice.tbTask.PaidValue END) 	                      
	FROM         Invoice.tbTask INNER JOIN
	                      Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
	                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	WHERE     ( Invoice.tbTask.TaskCode = @TaskCode)
	
	SELECT TOP 1 @TotalCost = TotalCost, @InvoicedCost = InvoicedCost, @InvoicedCostPaid = InvoicedCostPaid
	FROM         Task.fnProfitCost(@TaskCode, 0, 0, 0) AS fnTaskProfitCost_1
	
	INSERT INTO @tbOrder (InvoicedCharge, InvoicedChargePaid, TotalCost, InvoicedCost, InvoicedCostPaid)
		VALUES (isnull(@InvoicedCharge, 0), isnull(@InvoicedChargePaid, 0), @TotalCost, @InvoicedCost, @InvoicedCostPaid)
	
	RETURN
	END

GO

/****** Object:  UserDefinedFunction [Invoice].[fnEditCreditCandidates]    Script Date: 18/06/2018 18:08:08 ******/

GO


GO

CREATE FUNCTION [Invoice].[fnEditCreditCandidates] (@InvoiceNumber nvarchar(20), @AccountCode nvarchar(10))
RETURNS TABLE
AS
	RETURN 
	(		
		WITH InvoiceEditTasks AS 
		(
			SELECT        TaskCode
			FROM            Invoice.tbTask
			WHERE        (InvoiceNumber = @InvoiceNumber)
		)
		SELECT TOP (100) PERCENT tbInvoiceTask.TaskCode, tbInvoiceTask.InvoiceNumber, tbTask.ActivityCode, Invoice.tbStatus.InvoiceStatus, Usr.tbUser.UserName, Invoice.tbInvoice.InvoicedOn, tbInvoiceTask.InvoiceValue, 
								tbTask.TaskTitle
		FROM            Usr.tbUser INNER JOIN
								Invoice.tbInvoice INNER JOIN
								Invoice.tbTask AS tbInvoiceTask ON Invoice.tbInvoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
								Task.tbTask AS tbTask ON tbInvoiceTask.TaskCode = tbTask.TaskCode INNER JOIN
								Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode ON Usr.tbUser.UserId = Invoice.tbInvoice.UserId LEFT OUTER JOIN
								InvoiceEditTasks AS InvoiceEditTasks ON tbTask.TaskCode = InvoiceEditTasks.TaskCode
		WHERE        (Invoice.tbInvoice.AccountCode = @AccountCode) AND (Invoice.tbInvoice.InvoiceTypeCode = 0) AND (InvoiceEditTasks.TaskCode IS NULL)
		ORDER BY Invoice.tbInvoice.InvoicedOn DESC
	);
GO

/****** Object:  UserDefinedFunction [Invoice].[fnEditDebitCandidates]    Script Date: 18/06/2018 18:08:08 ******/

GO


GO

CREATE FUNCTION [Invoice].[fnEditDebitCandidates] (@InvoiceNumber nvarchar(20), @AccountCode nvarchar(10))
RETURNS TABLE
AS
	RETURN 
	(		
		WITH InvoiceEditTasks AS 
		(
			SELECT        TaskCode
			FROM            Invoice.tbTask
			WHERE        (InvoiceNumber = @InvoiceNumber)
		)
		SELECT TOP (100) PERCENT tbInvoiceTask.TaskCode, tbInvoiceTask.InvoiceNumber, tbTask.ActivityCode, Invoice.tbStatus.InvoiceStatus, Usr.tbUser.UserName, Invoice.tbInvoice.InvoicedOn, tbInvoiceTask.InvoiceValue, 
								tbTask.TaskTitle
		FROM            Usr.tbUser INNER JOIN
								Invoice.tbInvoice INNER JOIN
								Invoice.tbTask AS tbInvoiceTask ON Invoice.tbInvoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
								Task.tbTask ON tbInvoiceTask.TaskCode = tbTask.TaskCode INNER JOIN
								Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode ON Usr.tbUser.UserId = Invoice.tbInvoice.UserId LEFT OUTER JOIN
								InvoiceEditTasks  ON tbTask.TaskCode = InvoiceEditTasks.TaskCode
		WHERE        (Invoice.tbInvoice.AccountCode = @AccountCode) AND (Invoice.tbInvoice.InvoiceTypeCode = 2) AND (InvoiceEditTasks.TaskCode IS NULL)
		ORDER BY Invoice.tbInvoice.InvoicedOn DESC
	);
GO

/****** Object:  UserDefinedFunction [Invoice].[fnEditTasks]    Script Date: 18/06/2018 18:08:08 ******/

GO


GO


CREATE FUNCTION [Invoice].[fnEditTasks] (@InvoiceNumber nvarchar(20), @AccountCode nvarchar(10))
RETURNS TABLE
AS
	RETURN 
	(		
		WITH InvoiceEditTasks AS 
		(	SELECT        TaskCode
			FROM            Invoice.tbTask
			WHERE        (InvoiceNumber = @InvoiceNumber)
		)
		SELECT TOP (100) PERCENT Task.tbTask.TaskCode, Task.tbTask.ActivityCode, Task.tbStatus.TaskStatus, Usr.tbUser.UserName, Task.tbTask.ActionOn, Task.tbTask.ActionedOn, Task.tbTask.TaskTitle
		FROM            Usr.tbUser INNER JOIN
								Task.tbTask INNER JOIN
								Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode ON Usr.tbUser.UserId = Task.tbTask.ActionById LEFT OUTER JOIN
								InvoiceEditTasks ON Task.tbTask.TaskCode = InvoiceEditTasks.TaskCode
		WHERE        (Task.tbTask.AccountCode = @AccountCode) AND (Task.tbTask.TaskStatusCode = 1 OR
								Task.tbTask.TaskStatusCode = 2) AND (Task.tbTask.CashCode IS NOT NULL) AND (InvoiceEditTasks.TaskCode IS NULL)
		ORDER BY Task.tbTask.ActionOn DESC
	);
GO

/****** Object:  UserDefinedFunction [Org].[fnRebuildInvoiceItems]    Script Date: 18/06/2018 18:08:08 ******/

GO


GO

CREATE FUNCTION [Org].[fnRebuildInvoiceItems]
	(
	@AccountCode nvarchar(10)
	)
RETURNS TABLE
 AS
	RETURN ( SELECT     Invoice.tbInvoice.InvoiceNumber, ROUND(SUM( Invoice.tbItem.InvoiceValue), 2) AS TotalInvoiceValue, ROUND(SUM( Invoice.tbItem.TaxValue), 2) 
	                               AS TotalTaxValue
	         FROM         Invoice.tbItem INNER JOIN
	                               Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
	         WHERE     ( Invoice.tbInvoice.AccountCode = @AccountCode) AND ( Invoice.tbInvoice.InvoiceStatusCode <> 0)
	         GROUP BY Invoice.tbItem.InvoiceNumber, Invoice.tbInvoice.InvoiceNumber )

GO

/****** Object:  UserDefinedFunction [Org].[fnRebuildInvoiceTasks]    Script Date: 18/06/2018 18:08:08 ******/

GO


GO

CREATE FUNCTION [Org].[fnRebuildInvoiceTasks]
	(
	@AccountCode nvarchar(10)
	)
RETURNS TABLE
 AS
	RETURN ( SELECT     Invoice.tbInvoice.InvoiceNumber, ROUND(SUM( Invoice.tbTask.InvoiceValue), 2) AS TotalInvoiceValue, ROUND(SUM( Invoice.tbTask.TaxValue), 2) 
	                               AS TotalTaxValue
	         FROM         Invoice.tbTask INNER JOIN
	                               Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
	         WHERE     ( Invoice.tbInvoice.AccountCode = @AccountCode) AND ( Invoice.tbInvoice.InvoiceStatusCode <> 0)
	         GROUP BY Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.InvoiceNumber )
GO
/****** Object:  View [Task].[vwBucket]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwBucket]
AS
SELECT        task.TaskCode, task.ActionOn, buckets.Period, buckets.BucketId
FROM            Task.tbTask AS task CROSS APPLY
			(	SELECT  buckets.Period, buckets.BucketId
				FROM        App.fnBuckets(CURRENT_TIMESTAMP) buckets 
				WHERE     (StartDate <= task.ActionOn) AND (EndDate > task.ActionOn)) AS buckets
GO

/****** Object:  View [Task].[vwTasks]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwTasks]
AS
SELECT        Task.tbTask.TaskCode, Task.tbTask.UserId, Task.tbTask.AccountCode, Task.tbTask.ContactName, Task.tbTask.ActivityCode, Task.tbTask.TaskTitle, Task.tbTask.TaskStatusCode, Task.tbTask.ActionById, 
                         Task.tbTask.ActionOn, Task.tbTask.ActionedOn, Task.tbTask.PaymentOn, Task.tbTask.SecondReference, Task.tbTask.TaskNotes, Task.tbTask.TaxCode, Task.tbTask.Quantity, Task.tbTask.UnitCharge, 
                         Task.tbTask.TotalCharge, Task.tbTask.AddressCodeFrom, Task.tbTask.AddressCodeTo, Task.tbTask.Printed, Task.tbTask.Spooled, Task.tbTask.InsertedBy, Task.tbTask.InsertedOn, Task.tbTask.UpdatedBy, 
                         Task.tbTask.UpdatedOn, Task.vwBucket.Period, Task.vwBucket.BucketId, TaskStatus.TaskStatus, Task.tbTask.CashCode, Cash.tbCode.CashDescription, tbUser_1.UserName AS OwnerName, 
                         Usr.tbUser.UserName AS ActionName, Org.tbOrg.AccountName, OrgStatus.OrganisationStatus, Org.tbType.OrganisationType, CASE WHEN Cash.tbCategory.CategoryCode IS NULL 
                         THEN Org.tbType.CashModeCode ELSE Cash.tbCategory.CashModeCode END AS CashModeCode
FROM            Usr.tbUser INNER JOIN
                         Task.tbStatus AS TaskStatus INNER JOIN
                         Org.tbType INNER JOIN
                         Org.tbOrg ON Org.tbType.OrganisationTypeCode = Org.tbOrg.OrganisationTypeCode INNER JOIN
                         Org.tbStatus AS OrgStatus ON Org.tbOrg.OrganisationStatusCode = OrgStatus.OrganisationStatusCode INNER JOIN
                         Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode ON TaskStatus.TaskStatusCode = Task.tbTask.TaskStatusCode ON Usr.tbUser.UserId = Task.tbTask.ActionById INNER JOIN
                         Usr.tbUser AS tbUser_1 ON Task.tbTask.UserId = tbUser_1.UserId INNER JOIN
                         Task.vwBucket ON Task.tbTask.TaskCode = Task.vwBucket.TaskCode LEFT OUTER JOIN
                         Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
GO

/****** Object:  View [Invoice].[vwCandidateSales]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwCandidateSales]
AS
SELECT TOP 100 PERCENT TaskCode, AccountCode, ContactName, ActivityCode, ActionOn, ActionedOn, TaskTitle, Quantity, UnitCharge, TotalCharge, TaskNotes, CashDescription, ActionName, OwnerName, TaskStatus, InsertedBy, 
                         InsertedOn, UpdatedBy, UpdatedOn, TaskStatusCode
FROM            Task.vwTasks
WHERE        (TaskStatusCode = 1 OR
                         TaskStatusCode = 2) AND (CashModeCode = 1) AND (CashCode IS NOT NULL)
ORDER BY ActionOn;
GO

/****** Object:  View [Invoice].[vwCandidatePurchases]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO


CREATE VIEW [Invoice].[vwCandidatePurchases]
AS
SELECT TOP 100 PERCENT  TaskCode, AccountCode, ContactName, ActivityCode, ActionOn, ActionedOn, Quantity, UnitCharge, TotalCharge, TaskTitle, TaskNotes, CashDescription, ActionName, OwnerName, TaskStatus, InsertedBy, 
                         InsertedOn, UpdatedBy, UpdatedOn, TaskStatusCode
FROM            Task.vwTasks
WHERE        (TaskStatusCode = 1 OR
                         TaskStatusCode = 2) AND (CashModeCode = 0) AND (CashCode IS NOT NULL)
ORDER BY ActionOn;
GO

/****** Object:  View [Invoice].[vwRegisterItems]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

/************************************************************
VIEWS
************************************************************/

CREATE VIEW [Invoice].[vwRegisterItems]
  AS
SELECT     App.fnAccountPeriod(Invoice.tbInvoice.InvoicedOn) AS StartOn, Invoice.tbInvoice.InvoiceNumber, Invoice.tbItem.CashCode AS TaskCode, 
                      Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Invoice.tbItem.TaxCode, App.tbTaxCode.TaxDescription, 
                      Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbInvoice.InvoicedOn, 
                      CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.InvoiceValue * - 1 ELSE Invoice.tbItem.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.TaxValue * - 1 ELSE Invoice.tbItem.TaxValue END AS TaxValue, 
                      CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.PaidValue * - 1 ELSE Invoice.tbItem.PaidValue END AS PaidValue, 
                      CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.PaidTaxValue * - 1 ELSE Invoice.tbItem.PaidTaxValue END AS PaidTaxValue,
                       Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Printed, Org.tbOrg.AccountName, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, 
                      Invoice.tbType.CashModeCode, Invoice.tbType.InvoiceType
FROM         Invoice.tbInvoice INNER JOIN
                      Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                      Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                      Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId INNER JOIN
                      Invoice.tbItem ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbItem.InvoiceNumber INNER JOIN
                      Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
                      App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode



GO

/****** Object:  View [Invoice].[vwRegisterTasks]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwRegisterTasks]
AS
SELECT        App.fnAccountPeriod(Invoice.tbInvoice.InvoicedOn) AS StartOn, Invoice.tbInvoice.InvoiceNumber, InvoiceTask.TaskCode, Task.TaskTitle, Cash.tbCode.CashCode, Cash.tbCode.CashDescription, 
                         InvoiceTask.TaxCode, App.tbTaxCode.TaxDescription, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbInvoice.InvoicedOn, 
                         CASE WHEN Invoice.tbType.CashModeCode = 0 THEN InvoiceTask.InvoiceValue * - 1 ELSE InvoiceTask.InvoiceValue END AS InvoiceValue, 
                         CASE WHEN Invoice.tbType.CashModeCode = 0 THEN InvoiceTask.TaxValue * - 1 ELSE InvoiceTask.TaxValue END AS TaxValue, 
                         CASE WHEN Invoice.tbType.CashModeCode = 0 THEN InvoiceTask.PaidValue * - 1 ELSE InvoiceTask.PaidValue END AS PaidValue, 
                         CASE WHEN Invoice.tbType.CashModeCode = 0 THEN InvoiceTask.PaidTaxValue * - 1 ELSE InvoiceTask.PaidTaxValue END AS PaidTaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Printed, 
                         Org.tbOrg.AccountName, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.CashModeCode, Invoice.tbType.InvoiceType
FROM            Invoice.tbInvoice INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId INNER JOIN
                         Invoice.tbTask AS InvoiceTask ON Invoice.tbInvoice.InvoiceNumber = InvoiceTask.InvoiceNumber INNER JOIN
                         Cash.tbCode ON InvoiceTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Task.tbTask AS Task ON InvoiceTask.TaskCode = Task.TaskCode AND InvoiceTask.TaskCode = Task.TaskCode LEFT OUTER JOIN
                         App.tbTaxCode ON InvoiceTask.TaxCode = App.tbTaxCode.TaxCode

GO

/****** Object:  View [Invoice].[vwRegisterDetail]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwRegisterDetail]
AS
WITH register AS
(
	SELECT     StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, 
						  InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, 
						  InvoiceType
	FROM         Invoice.vwRegisterTasks
	UNION
	SELECT     StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, 
						  InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, 
						  InvoiceType
	FROM         Invoice.vwRegisterItems
)
SELECT *, ([InvoiceValue])+[TaxValue]-([PaidValue]+[PaidTaxValue]) AS UnpaidValue FROM register;
GO

/****** Object:  View [Invoice].[vwRegisterCashCodes]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwRegisterCashCodes]
AS
SELECT TOP 100 PERCENT StartOn, CashCode, CashDescription, SUM(InvoiceValue) AS TotalInvoiceValue, SUM(TaxValue) AS TotalTaxValue
FROM            Invoice.vwRegisterDetail
GROUP BY StartOn, CashCode, CashDescription
ORDER BY StartOn, CashCode;
GO

/****** Object:  View [Invoice].[vwRegister]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwRegister]
AS
SELECT     App.fnAccountPeriod(Invoice.tbInvoice.InvoicedOn) AS StartOn, Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, 
                      Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbInvoice.InvoicedOn, 
                      CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbInvoice.InvoiceValue * - 1 ELSE Invoice.tbInvoice.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbInvoice.TaxValue * - 1 ELSE Invoice.tbInvoice.TaxValue END AS TaxValue, 
                      CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbInvoice.PaidValue * - 1 ELSE Invoice.tbInvoice.PaidValue END AS PaidValue, 
                      CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbInvoice.PaidTaxValue * - 1 ELSE Invoice.tbInvoice.PaidTaxValue END AS PaidTaxValue, 
                      Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, Invoice.tbInvoice.Printed, Org.tbOrg.AccountName, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, 
                      Invoice.tbType.CashModeCode, Invoice.tbType.InvoiceType
FROM         Invoice.tbInvoice INNER JOIN
                      Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                      Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                      Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE     (Invoice.tbInvoice.AccountCode <> App.fnCompanyAccount())
GO

/****** Object:  View [Invoice].[vwRegisterPurchases]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwRegisterPurchases]
AS
SELECT        StartOn, InvoiceNumber, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Notes, Printed, AccountName, UserName, 
                         InvoiceStatus, CashModeCode, InvoiceType, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS UnpaidValue
FROM            Invoice.vwRegister
WHERE        (InvoiceTypeCode > 1);
GO

/****** Object:  View [Invoice].[vwRegisterPurchaseTasks]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwRegisterPurchaseTasks]
AS
SELECT        StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, 
                         PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, InvoiceType, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS UnpaidValue
FROM            Invoice.vwRegisterDetail
WHERE        (InvoiceTypeCode > 1);
GO

/****** Object:  View [Task].[vwInvoicedQuantity]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwInvoicedQuantity]
  AS
SELECT     Invoice.tbTask.TaskCode, SUM(Invoice.tbTask.Quantity) AS InvoiceQuantity
FROM         Invoice.tbTask INNER JOIN
                      Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
WHERE     (Invoice.tbInvoice.InvoiceTypeCode = 0) OR
                      (Invoice.tbInvoice.InvoiceTypeCode = 2)
GROUP BY Invoice.tbTask.TaskCode
GO

/****** Object:  View [App].[vwTaxRates]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [App].[vwTaxRates]
AS
SELECT     TaxCode, CAST(TaxRate AS MONEY) AS TaxRate, TaxTypeCode
FROM         App.tbTaxCode
GO

/****** Object:  View [Cash].[vwStatementTasksConfirmed]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO


CREATE VIEW [Cash].[vwStatementTasksConfirmed]
 AS
SELECT     TOP (100) PERCENT Task.tbTask.TaskCode AS ReferenceCode, Task.tbTask.AccountCode, Task.tbTask.ActionOn, Task.tbTask.PaymentOn, 
                      2 AS CashEntryTypeCode, 
                      CASE WHEN Cash.tbCategory.CashModeCode = 0 THEN (Task.tbTask.UnitCharge + Task.tbTask.UnitCharge * App.vwTaxRates.TaxRate) 
                      * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayOut, 
                      CASE WHEN Cash.tbCategory.CashModeCode = 1 THEN (Task.tbTask.UnitCharge + Task.tbTask.UnitCharge * App.vwTaxRates.TaxRate) 
                      * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayIn, Cash.tbCode.CashCode
FROM         App.vwTaxRates INNER JOIN
                      Task.tbTask ON App.vwTaxRates.TaxCode = Task.tbTask.TaxCode INNER JOIN
                      Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode LEFT OUTER JOIN
                      Task.vwInvoicedQuantity ON Task.tbTask.TaskCode = Task.vwInvoicedQuantity.TaskCode
WHERE     (Task.tbTask.TaskStatusCode > 0) AND (Task.tbTask.TaskStatusCode < 3) AND 
                      (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0) > 0)
GO

/****** Object:  View [Invoice].[vwRegisterSales]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwRegisterSales]
AS
SELECT        StartOn, InvoiceNumber, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Notes, Printed, AccountName, UserName, 
                         InvoiceStatus, CashModeCode, InvoiceType, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS UnpaidValue
FROM            Invoice.vwRegister
WHERE        (InvoiceTypeCode < 2);
GO

/****** Object:  View [Invoice].[vwRegisterSaleTasks]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwRegisterSaleTasks]
AS
SELECT        StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, 
                         PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, InvoiceType, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS UnpaidValue
FROM            Invoice.vwRegisterDetail
WHERE        (InvoiceTypeCode < 2);
GO

/****** Object:  View [Org].[vwStatementPayments]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwStatementPayments]
  AS
SELECT     TOP 100 PERCENT Org.tbPayment.AccountCode, Org.tbPayment.PaidOn AS TransactedOn, 2 AS OrderBy, 
                      Org.tbPayment.PaymentReference AS Reference, Org.tbPaymentStatus.PaymentStatus AS StatementType, 
                      CASE WHEN PaidInValue > 0 THEN PaidInValue ELSE PaidOutValue * - 1 END AS Charge
FROM         Org.tbPayment INNER JOIN
                      Org.tbPaymentStatus ON Org.tbPayment.PaymentStatusCode = Org.tbPaymentStatus.PaymentStatusCode
ORDER BY Org.tbPayment.AccountCode, Org.tbPayment.PaidOn
GO

/****** Object:  View [Org].[vwStatementPaymentBase]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwStatementPaymentBase]
  AS
SELECT     AccountCode, TransactedOn, OrderBy, Reference, StatementType, SUM(Charge) AS Charge
FROM         Org.vwStatementPayments
GROUP BY AccountCode, TransactedOn, OrderBy, Reference, StatementType
GO

/****** Object:  View [Org].[vwStatementInvoices]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwStatementInvoices]
  AS
SELECT     TOP 100 PERCENT Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoicedOn AS TransactedOn, 1 AS OrderBy, Invoice.tbInvoice.InvoiceNumber AS Reference, 
                      Invoice.tbType.InvoiceType AS StatementType, 
                      CASE CashModeCode WHEN 0 THEN Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue WHEN 1 THEN (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue)
                       * - 1 END AS Charge
FROM         Invoice.tbInvoice INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
ORDER BY Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoicedOn
GO

/****** Object:  View [Org].[vwStatementBase]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwStatementBase]
  AS
SELECT     TOP 100 PERCENT AccountCode, TransactedOn, OrderBy, Reference, StatementType, Charge
FROM         Org.vwStatementPaymentBase
UNION
SELECT     TOP 100 PERCENT AccountCode, TransactedOn, OrderBy, Reference, StatementType, Charge
FROM         Org.vwStatementInvoices
GO

/****** Object:  View [Org].[vwPurchases]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwPurchases]
AS
SELECT        AccountCode, TaskCode, UserId, ContactName, ActivityCode, TaskTitle, TaskStatusCode, ActionById, ActionOn, ActionedOn, PaymentOn, SecondReference, TaskNotes, TaxCode, Quantity, UnitCharge, TotalCharge, 
                         AddressCodeFrom, AddressCodeTo, Printed, Spooled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, Period, BucketId, TaskStatus, CashCode, CashDescription, OwnerName, ActionName, AccountName, 
                         OrganisationStatus, OrganisationType, CashModeCode
FROM            Task.vwTasks
WHERE        (CashModeCode = 0) AND (CashCode IS NOT NULL);
GO

/****** Object:  View [Org].[vwSales]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwSales]
AS
SELECT        AccountCode, TaskCode, UserId, ContactName, ActivityCode, TaskTitle, TaskStatusCode, ActionById, ActionOn, ActionedOn, PaymentOn, SecondReference, TaskNotes, TaxCode, Quantity, UnitCharge, TotalCharge, 
                         AddressCodeFrom, AddressCodeTo, Printed, Spooled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, Period, BucketId, TaskStatus, CashCode, CashDescription, OwnerName, ActionName, AccountName, 
                         OrganisationStatus, OrganisationType, CashModeCode
FROM            Task.vwTasks
WHERE        (CashModeCode = 1) AND (CashCode IS NOT NULL);
GO

/****** Object:  View [Cash].[vwCodeInvoiceSummary]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwCodeInvoiceSummary]
AS
SELECT        Invoice.vwRegisterDetail.CashCode, Invoice.vwRegisterDetail.StartOn, ABS(SUM(Invoice.vwRegisterDetail.InvoiceValue)) AS InvoiceValue, 
                         ABS(SUM(Invoice.vwRegisterDetail.TaxValue)) AS TaxValue
FROM            Invoice.vwRegisterDetail INNER JOIN
                         Cash.tbCode ON Invoice.vwRegisterDetail.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
GROUP BY Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.CashCode

GO

/****** Object:  View [Task].[vwOrgActivity]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwOrgActivity]
AS
SELECT AccountCode, TaskStatusCode, ActionOn, TaskTitle, ActivityCode, ActionById, TaskCode, Period, BucketId, ContactName, TaskStatus, TaskNotes, ActionedOn, OwnerName, CashCode, CashDescription, Quantity, 
                         UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, Printed, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, AccountName, ActionName
FROM            Task.vwTasks
WHERE        (TaskStatusCode < 2);

GO

/****** Object:  View [Task].[vwActiveData]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwActiveData]
AS
SELECT        TaskCode, UserId, AccountCode, ContactName, ActivityCode, TaskTitle, TaskStatusCode, ActionById, ActionOn, ActionedOn, PaymentOn, SecondReference, TaskNotes, TaxCode, Quantity, UnitCharge, TotalCharge, 
                         AddressCodeFrom, AddressCodeTo, Printed, Spooled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, Period, BucketId, TaskStatus, CashCode, CashDescription, OwnerName, ActionName, AccountName, 
                         OrganisationStatus, OrganisationType, CashModeCode
FROM            Task.vwTasks
WHERE        (TaskStatusCode < 2);

GO

/****** Object:  View [Task].[vwPurchases]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwPurchases]
AS
SELECT        Task.vwTasks.TaskCode, Task.vwTasks.ActivityCode, Task.vwTasks.TaskStatusCode, Task.vwTasks.ActionOn, Task.vwTasks.ActionById, Task.vwTasks.TaskTitle, Task.vwTasks.Period, Task.vwTasks.BucketId, 
                         Task.vwTasks.AccountCode, Task.vwTasks.ContactName, Task.vwTasks.TaskStatus, Task.vwTasks.TaskNotes, Task.vwTasks.ActionedOn, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, 
                         Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, 
                         Org.tbAddress.Address AS ToAddress, Task.vwTasks.Printed, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, 
                         Task.vwTasks.ActionName, Task.vwTasks.SecondReference
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 0);
GO

/****** Object:  View [Org].[vwRebuildInvoicedItems]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwRebuildInvoicedItems]
AS
SELECT     Invoice.tbInvoice.AccountCode, Invoice.tbType.CashModeCode, Invoice.tbInvoice.CollectOn, Invoice.tbItem.InvoiceNumber, 
                      Invoice.tbItem.CashCode, '' AS TaskCode, Invoice.tbItem.InvoiceValue, Invoice.tbItem.TaxValue, Invoice.tbItem.PaidValue, 
                      Invoice.tbItem.PaidTaxValue
FROM         Invoice.tbItem INNER JOIN
                      Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode

GO

/****** Object:  View [Org].[vwRebuildInvoicedTasks]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwRebuildInvoicedTasks]
AS
SELECT     Invoice.tbInvoice.AccountCode, Invoice.tbType.CashModeCode, Invoice.tbInvoice.CollectOn, Invoice.tbTask.InvoiceNumber, 
                      Invoice.tbTask.CashCode, Invoice.tbTask.TaskCode, Invoice.tbTask.InvoiceValue, Invoice.tbTask.TaxValue, 
                      Invoice.tbTask.PaidValue, Invoice.tbTask.PaidTaxValue
FROM         Invoice.tbTask INNER JOIN
                      Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode

GO

/****** Object:  View [Org].[vwRebuildInvoices]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwRebuildInvoices]
AS
SELECT     AccountCode, CashModeCode, CollectOn, InvoiceNumber, CashCode, TaskCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
FROM         Org.vwRebuildInvoicedTasks
UNION
SELECT     AccountCode, CashModeCode, CollectOn, InvoiceNumber, CashCode, TaskCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
FROM         Org.vwRebuildInvoicedItems

GO

/****** Object:  View [Task].[vwSales]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwSales]
AS
SELECT        Task.vwTasks.TaskCode, Task.vwTasks.ActivityCode, Task.vwTasks.TaskStatusCode, Task.vwTasks.ActionOn, Task.vwTasks.ActionById, Task.vwTasks.TaskTitle, Task.vwTasks.Period, Task.vwTasks.BucketId, 
                         Task.vwTasks.AccountCode, Task.vwTasks.ContactName, Task.vwTasks.TaskStatus, Task.vwTasks.TaskNotes, Task.vwTasks.ActionedOn, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, 
                         Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, 
                         Org.tbAddress.Address AS ToAddress, Task.vwTasks.Printed, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, 
                         Task.vwTasks.ActionName, Task.vwTasks.SecondReference
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 1);
GO

/****** Object:  View [Org].[vwRebuildInvoiceTotals]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwRebuildInvoiceTotals]
AS
SELECT     AccountCode, InvoiceNumber, SUM(InvoiceValue) AS TotalInvoiceValue, SUM(TaxValue) AS TotalTaxValue, SUM(PaidValue) AS TotalPaidValue, 
                      SUM(PaidTaxValue) AS TotalPaidTaxValue
FROM         Org.vwRebuildInvoices
GROUP BY AccountCode, InvoiceNumber
GO

/****** Object:  View [Cash].[vwPolarData]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwPolarData]
AS
SELECT        Cash.tbPeriod.CashCode, Cash.tbCategory.CashTypeCode, Cash.tbPeriod.StartOn, Cash.tbPeriod.ForecastValue, Cash.tbPeriod.ForecastTax, 
                         Cash.tbPeriod.InvoiceValue, Cash.tbPeriod.InvoiceTax
FROM            Cash.tbPeriod INNER JOIN
                         Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode INNER JOIN
                         App.tbYearPeriod ON Cash.tbPeriod.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
WHERE        (App.tbYear.CashStatusCode < 3)

GO

/****** Object:  View [Cash].[vwFlowData]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwFlowData]
AS
SELECT        App.tbYearPeriod.YearNumber, App.tbYearPeriod.StartOn, Cash.vwPolarData.CashCode, Cash.vwPolarData.InvoiceValue, 
                         Cash.vwPolarData.InvoiceTax, Cash.vwPolarData.ForecastValue, Cash.vwPolarData.ForecastTax
FROM            App.tbYearPeriod INNER JOIN
                         Cash.vwPolarData ON App.tbYearPeriod.StartOn = Cash.vwPolarData.StartOn

GO

/****** Object:  View [Cash].[vwAccountStatement]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO


CREATE VIEW [Cash].[vwAccountStatement]
  AS
SELECT     Org.tbPayment.PaymentCode, Org.tbPayment.CashAccountCode, Usr.tbUser.UserName, Org.tbPayment.AccountCode, 
                      Org.tbOrg.AccountName, Org.tbPayment.CashCode, Cash.tbCode.CashDescription, App.tbTaxCode.TaxDescription, 
                      Org.tbPayment.PaidOn, Org.tbPayment.PaidInValue, Org.tbPayment.PaidOutValue, Org.tbPayment.TaxInValue, 
                      Org.tbPayment.TaxOutValue, Org.tbPayment.PaymentReference, Org.tbPayment.InsertedBy, Org.tbPayment.InsertedOn, 
                      Org.tbPayment.UpdatedBy, Org.tbPayment.UpdatedOn, Org.tbPayment.TaxCode
FROM         Org.tbPayment INNER JOIN
                      Usr.tbUser ON Org.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
                      Org.tbOrg ON Org.tbPayment.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                      App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                      Cash.tbCode ON Org.tbPayment.CashCode = Cash.tbCode.CashCode



GO

/****** Object:  View [Cash].[vwAccountStatements]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO



CREATE VIEW [Cash].[vwAccountStatements]
  AS
SELECT     TOP 100 PERCENT fnCashAccountStatements.CashAccountCode, App.fnAccountPeriod(fnCashAccountStatements.PaidOn) AS StartOn, 
                      fnCashAccountStatements.EntryNumber, fnCashAccountStatements.PaymentCode, fnCashAccountStatements.PaidOn, 
                      Cash.vwAccountStatement.AccountName, Cash.vwAccountStatement.PaymentReference, Cash.vwAccountStatement.PaidInValue, 
                      Cash.vwAccountStatement.PaidOutValue, fnCashAccountStatements.PaidBalance, Cash.vwAccountStatement.TaxInValue, 
                      Cash.vwAccountStatement.TaxOutValue, fnCashAccountStatements.TaxedBalance, Cash.vwAccountStatement.CashCode, 
                      Cash.vwAccountStatement.CashDescription, Cash.vwAccountStatement.TaxDescription, Cash.vwAccountStatement.UserName, 
                      Cash.vwAccountStatement.AccountCode, Cash.vwAccountStatement.TaxCode
FROM         Cash.fnAccountStatements() fnCashAccountStatements LEFT OUTER JOIN
                      Cash.vwAccountStatement ON fnCashAccountStatements.PaymentCode = Cash.vwAccountStatement.PaymentCode
ORDER BY fnCashAccountStatements.CashAccountCode, fnCashAccountStatements.EntryNumber



GO

/****** Object:  View [Cash].[vwAccountStatementListing]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwAccountStatementListing]
AS
SELECT        App.tbYear.YearNumber, Org.tbOrg.AccountName AS Bank, Org.tbAccount.CashAccountCode, Org.tbAccount.CashAccountName, Org.tbAccount.SortCode, Org.tbAccount.AccountNumber, CONCAT(App.tbYear.Description, SPACE(1), 
                         App.tbMonth.MonthName) AS PeriodName, Cash.vwAccountStatements.StartOn, Cash.vwAccountStatements.EntryNumber, Cash.vwAccountStatements.PaymentCode, Cash.vwAccountStatements.PaidOn, 
                         Cash.vwAccountStatements.AccountName, Cash.vwAccountStatements.PaymentReference, Cash.vwAccountStatements.PaidInValue, Cash.vwAccountStatements.PaidOutValue, 
                         Cash.vwAccountStatements.PaidBalance, Cash.vwAccountStatements.TaxInValue, Cash.vwAccountStatements.TaxOutValue, Cash.vwAccountStatements.TaxedBalance, Cash.vwAccountStatements.CashCode, 
                         Cash.vwAccountStatements.CashDescription, Cash.vwAccountStatements.TaxDescription, Cash.vwAccountStatements.UserName, Cash.vwAccountStatements.AccountCode, 
                         Cash.vwAccountStatements.TaxCode
FROM            App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                         Cash.vwAccountStatements INNER JOIN
                         Org.tbAccount ON Cash.vwAccountStatements.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
                         Org.tbOrg ON Org.tbAccount.AccountCode = Org.tbOrg.AccountCode ON App.tbYearPeriod.StartOn = Cash.vwAccountStatements.StartOn INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber;
GO

/****** Object:  View [Invoice].[vwOutstandingItems]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwOutstandingItems]
  AS
SELECT     InvoiceNumber, '' AS TaskCode, CashCode, TaxCode, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS OutstandingValue, 
                      CASE WHEN InvoiceValue = 0 THEN 0 ELSE TaxValue / InvoiceValue END AS TaxRate
FROM         Invoice.tbItem
GO

/****** Object:  View [Invoice].[vwOutstandingTasks]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwOutstandingTasks]
  AS
SELECT     InvoiceNumber, TaskCode, CashCode, TaxCode, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS OutstandingValue, 
                      CASE WHEN InvoiceValue = 0 THEN 0 ELSE TaxValue / InvoiceValue END AS TaxRate
FROM         Invoice.tbTask
GO

/****** Object:  View [Invoice].[vwOutstandingBase]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwOutstandingBase]
  AS
SELECT     InvoiceNumber AS InvoiceNumber, TaskCode AS TaskCode, 
                      CashCode AS CashCode, TaxCode AS TaxCode, OutstandingValue, TaxRate
FROM         Invoice.vwOutstandingItems
UNION
SELECT     InvoiceNumber AS InvoiceNumber, TaskCode AS TaskCode, 
                      CashCode AS CashCode, TaxCode AS TaxCode, OutstandingValue, TaxRate
FROM         Invoice.vwOutstandingTasks
GO

/****** Object:  View [Invoice].[vwVatItems]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO


CREATE VIEW [Invoice].[vwVatItems]
AS
SELECT     TOP (100) PERCENT App.fnAccountPeriod(Invoice.tbInvoice.InvoicedOn) AS StartOn, Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.InvoiceTypeCode, 
                      Invoice.tbItem.TaxCode, Invoice.tbItem.InvoiceValue, Invoice.tbItem.TaxValue, Org.tbOrg.ForeignJurisdiction, 
                      Invoice.tbItem.CashCode AS IdentityCode
FROM         Invoice.tbItem INNER JOIN
                      Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
                      Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                      App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode
WHERE     (App.tbTaxCode.TaxTypeCode = 1)
ORDER BY StartOn
GO

/****** Object:  View [Invoice].[vwVatTasks]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwVatTasks]
AS
SELECT     TOP (100) PERCENT App.fnAccountPeriod(Invoice.tbInvoice.InvoicedOn) AS StartOn, Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.InvoiceTypeCode, 
                      Invoice.tbTask.TaxCode, Invoice.tbTask.InvoiceValue, Invoice.tbTask.TaxValue, Org.tbOrg.ForeignJurisdiction, 
                      Invoice.tbTask.TaskCode AS IdentityCode
FROM         Invoice.tbTask INNER JOIN
                      Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
                      Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                      App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode
WHERE     (App.tbTaxCode.TaxTypeCode = 1)
ORDER BY StartOn

GO

/****** Object:  View [Invoice].[vwVatBase]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwVatBase]
AS
SELECT     StartOn, InvoiceNumber, InvoiceTypeCode, TaxCode, InvoiceValue, TaxValue, ForeignJurisdiction, IdentityCode
FROM         Invoice.vwVatItems
UNION
SELECT     StartOn, InvoiceNumber, InvoiceTypeCode, TaxCode, InvoiceValue, TaxValue, ForeignJurisdiction, IdentityCode
FROM         Invoice.vwVatTasks

GO

/****** Object:  View [Invoice].[vwVatDetail]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwVatDetail]
AS
SELECT        StartOn, TaxCode, 
                         CASE WHEN ForeignJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 0 THEN InvoiceValue WHEN 1 THEN
                          InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomeSales, 
                         CASE WHEN ForeignJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 2 THEN InvoiceValue WHEN 3 THEN
                          InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomePurchases, 
                         CASE WHEN ForeignJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 0 THEN InvoiceValue WHEN 1 THEN
                          InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportSales, 
                         CASE WHEN ForeignJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 2 THEN InvoiceValue WHEN 3 THEN
                          InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportPurchases, 
                         CASE WHEN ForeignJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 0 THEN TaxValue WHEN 1 THEN TaxValue
                          * - 1 ELSE 0 END ELSE 0 END AS HomeSalesVat, 
                         CASE WHEN ForeignJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 2 THEN TaxValue WHEN 3 THEN TaxValue
                          * - 1 ELSE 0 END ELSE 0 END AS HomePurchasesVat, 
                         CASE WHEN ForeignJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 0 THEN TaxValue WHEN 1 THEN TaxValue
                          * - 1 ELSE 0 END ELSE 0 END AS ExportSalesVat, 
                         CASE WHEN ForeignJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 2 THEN TaxValue WHEN 3 THEN TaxValue
                          * - 1 ELSE 0 END ELSE 0 END AS ExportPurchasesVat
FROM            Invoice.vwVatBase

GO

/****** Object:  View [Invoice].[vwVatSummary]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwVatSummary]
AS
WITH tbBase AS
(
	SELECT        StartOn, TaxCode, SUM(HomeSales) AS HomeSales, SUM(HomePurchases) AS HomePurchases, SUM(ExportSales) AS ExportSales, SUM(ExportPurchases) AS ExportPurchases, SUM(HomeSalesVat) 
							AS HomeSalesVat, SUM(HomePurchasesVat) AS HomePurchasesVat, SUM(ExportSalesVat) AS ExportSalesVat, SUM(ExportPurchasesVat) AS ExportPurchasesVat
	FROM            Invoice.vwVatDetail
	GROUP BY StartOn, TaxCode
)
SELECT        StartOn, TaxCode, HomeSales, HomePurchases, ExportSales, ExportPurchases, HomeSalesVat, HomePurchasesVat, ExportSalesVat, ExportPurchasesVat, (HomeSalesVat + ExportSalesVat) 
                         - (HomePurchasesVat + ExportPurchasesVat) AS VatDue
FROM tbBase;
GO

/****** Object:  View [Invoice].[vwVatDetailListing]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwVatDetailListing]
AS
SELECT        App.tbYearPeriod.YearNumber, App.tbYear.Description, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, Invoice.vwVatSummary.StartOn, 
                         Invoice.vwVatSummary.TaxCode, Invoice.vwVatSummary.HomeSales, Invoice.vwVatSummary.HomePurchases, Invoice.vwVatSummary.ExportSales, Invoice.vwVatSummary.ExportPurchases, 
                         Invoice.vwVatSummary.HomeSalesVat, Invoice.vwVatSummary.HomePurchasesVat, Invoice.vwVatSummary.ExportSalesVat, Invoice.vwVatSummary.ExportPurchasesVat, Invoice.vwVatSummary.VatDue                         
FROM            Invoice.vwVatSummary INNER JOIN
                         App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber ON Invoice.vwVatSummary.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber;
GO

/****** Object:  View [Invoice].[vwOutstanding]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwOutstanding]
AS
SELECT     TOP (100) PERCENT Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.CollectOn, Invoice.tbInvoice.InvoiceNumber, Invoice.vwOutstandingBase.TaskCode, 
                      Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbType.CashModeCode, Invoice.vwOutstandingBase.CashCode, 
                      Invoice.vwOutstandingBase.TaxCode, Invoice.vwOutstandingBase.TaxRate, 
                      CASE WHEN Invoice.tbType.CashModeCode = 0 THEN OutstandingValue * - 1 ELSE OutstandingValue END AS ItemValue
FROM         Invoice.vwOutstandingBase INNER JOIN
                      Invoice.tbInvoice ON Invoice.vwOutstandingBase.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE     (Invoice.tbInvoice.InvoiceStatusCode = 1) OR
                      (Invoice.tbInvoice.InvoiceStatusCode = 2)

GO

/****** Object:  View [Cash].[vwStatementTasksFull]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwStatementTasksFull]
 AS
SELECT     TOP (100) PERCENT Task.tbTask.TaskCode AS ReferenceCode, Task.tbTask.AccountCode, Task.tbTask.ActionOn, Task.tbTask.PaymentOn, 
                      CASE WHEN Task.tbTask.TaskStatusCode = 0 THEN 3 ELSE 2 END AS CashEntryTypeCode, 
                      CASE WHEN Cash.tbCategory.CashModeCode = 0 THEN (Task.tbTask.UnitCharge + Task.tbTask.UnitCharge * App.vwTaxRates.TaxRate) 
                      * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayOut, 
                      CASE WHEN Cash.tbCategory.CashModeCode = 1 THEN (Task.tbTask.UnitCharge + Task.tbTask.UnitCharge * App.vwTaxRates.TaxRate) 
                      * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayIn, Cash.tbCode.CashCode
FROM         App.vwTaxRates INNER JOIN
                      Task.tbTask ON App.vwTaxRates.TaxCode = Task.tbTask.TaxCode INNER JOIN
                      Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode LEFT OUTER JOIN
                      Task.vwInvoicedQuantity ON Task.tbTask.TaskCode = Task.vwInvoicedQuantity.TaskCode
WHERE     (Task.tbTask.TaskStatusCode < 3) AND (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0) > 0)

GO

/****** Object:  View [Invoice].[vwSummaryTasks]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwSummaryTasks]
AS
SELECT     App.fnAccountPeriod(Invoice.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE 
						WHEN Invoice.tbInvoice.InvoiceTypeCode = 1 THEN 0 ELSE CASE WHEN Invoice.tbInvoice.InvoiceTypeCode = 3 THEN 2 ELSE Invoice.tbInvoice.InvoiceTypeCode END END AS InvoiceTypeCode,
                       CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.InvoiceValue * - 1 ELSE Invoice.tbTask.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.TaxValue * - 1 ELSE Invoice.tbTask.TaxValue END AS TaxValue
FROM         Invoice.tbTask INNER JOIN
                      Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE     (Invoice.tbInvoice.InvoicedOn >= App.fnHistoryStartOn())

GO

/****** Object:  View [Invoice].[vwSummaryItems]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwSummaryItems]
AS
SELECT     App.fnAccountPeriod(Invoice.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN Invoice.tbInvoice.InvoiceTypeCode = 1 THEN 0 ELSE CASE WHEN Invoice.tbInvoice.InvoiceTypeCode = 3 THEN 2 ELSE Invoice.tbInvoice.InvoiceTypeCode END END AS InvoiceTypeCode,
                       CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.InvoiceValue * - 1 ELSE Invoice.tbItem.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.TaxValue * - 1 ELSE Invoice.tbItem.TaxValue END AS TaxValue
FROM         Invoice.tbItem INNER JOIN
                      Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE     (Invoice.tbInvoice.InvoicedOn >= App.fnHistoryStartOn())

GO

/****** Object:  View [Invoice].[vwSummaryBase]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwSummaryBase]
AS
SELECT     StartOn, InvoiceTypeCode, InvoiceValue, TaxValue
FROM         Invoice.vwSummaryItems
UNION
SELECT     StartOn, InvoiceTypeCode, InvoiceValue, TaxValue
FROM         Invoice.vwSummaryTasks

GO

/****** Object:  View [Invoice].[vwSummaryTotals]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwSummaryTotals]
  AS
SELECT     Invoice.vwSummaryBase.StartOn, Invoice.vwSummaryBase.InvoiceTypeCode, Invoice.tbType.InvoiceType, 
                      SUM(Invoice.vwSummaryBase.InvoiceValue) AS TotalInvoiceValue, SUM(Invoice.vwSummaryBase.TaxValue) AS TotalTaxValue
FROM         Invoice.vwSummaryBase INNER JOIN
                      Invoice.tbType ON Invoice.vwSummaryBase.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
GROUP BY Invoice.vwSummaryBase.StartOn, Invoice.vwSummaryBase.InvoiceTypeCode, Invoice.tbType.InvoiceType
GO

/****** Object:  View [Invoice].[vwHistoryCashCodes]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwHistoryCashCodes]
AS
SELECT        App.tbYearPeriod.YearNumber, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS Period, Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.CashCode, 
                         Invoice.vwRegisterDetail.CashDescription, SUM(Invoice.vwRegisterDetail.InvoiceValue) AS TotalInvoiceValue, SUM(Invoice.vwRegisterDetail.TaxValue) AS TotalTaxValue
FROM            Invoice.vwRegisterDetail INNER JOIN
                         App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber ON Invoice.vwRegisterDetail.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
GROUP BY App.tbYearPeriod.YearNumber, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)), Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.CashCode, 
                         Invoice.vwRegisterDetail.CashDescription;
GO

/****** Object:  View [Invoice].[vwSummaryMargin]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwSummaryMargin]
  AS
SELECT     StartOn, 4 AS InvoiceTypeCode, App.fnProfileText(3004) AS InvoiceType, SUM(TotalInvoiceValue) AS TotalInvoiceValue, SUM(TotalTaxValue) 
                      AS TotalTaxValue
FROM         Invoice.vwSummaryTotals
GROUP BY StartOn
GO

/****** Object:  View [Invoice].[vwHistoryPurchaseItems]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwHistoryPurchaseItems]
AS
SELECT        CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, App.tbYearPeriod.YearNumber, Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.InvoiceNumber, 
                         Invoice.vwRegisterDetail.TaskCode, Invoice.vwRegisterDetail.CashCode, Invoice.vwRegisterDetail.CashDescription, Invoice.vwRegisterDetail.TaxCode, Invoice.vwRegisterDetail.TaxDescription, 
                         Invoice.vwRegisterDetail.AccountCode, Invoice.vwRegisterDetail.InvoiceTypeCode, Invoice.vwRegisterDetail.InvoiceStatusCode, Invoice.vwRegisterDetail.InvoicedOn, Invoice.vwRegisterDetail.InvoiceValue, 
                         Invoice.vwRegisterDetail.TaxValue, Invoice.vwRegisterDetail.PaidValue, Invoice.vwRegisterDetail.PaidTaxValue, Invoice.vwRegisterDetail.PaymentTerms, Invoice.vwRegisterDetail.Printed, 
                         Invoice.vwRegisterDetail.AccountName, Invoice.vwRegisterDetail.UserName, Invoice.vwRegisterDetail.InvoiceStatus, Invoice.vwRegisterDetail.CashModeCode, Invoice.vwRegisterDetail.InvoiceType, 
                         Invoice.vwRegisterDetail.UnpaidValue
FROM            Invoice.vwRegisterDetail INNER JOIN
                         App.tbYearPeriod ON Invoice.vwRegisterDetail.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
WHERE        (Invoice.vwRegisterDetail.InvoiceTypeCode > 1);
GO

/****** Object:  View [Invoice].[vwSummary]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwSummary]
AS
SELECT     CONCAT(DATENAME(yyyy, StartOn), '/', FORMAT(MONTH(StartOn), '00')) AS PeriodOn, StartOn, InvoiceTypeCode, InvoiceType AS InvoiceType, 
                      ABS(TotalInvoiceValue) AS TotalInvoiceValue, ABS(TotalTaxValue) AS TotalTaxValue
FROM         Invoice.vwSummaryTotals
UNION
SELECT     CONCAT(DATENAME(yyyy, StartOn), '/', FORMAT(MONTH(StartOn), '00')) AS PeriodOn, StartOn, InvoiceTypeCode, InvoiceType AS InvoiceType, 
                      TotalInvoiceValue, TotalTaxValue
FROM         Invoice.vwSummaryMargin

GO

/****** Object:  View [Invoice].[vwHistoryPurchases]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwHistoryPurchases]
AS
SELECT        App.tbYearPeriod.YearNumber, App.tbYear.Description, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, Invoice.vwRegister.StartOn, 
                         Invoice.vwRegister.InvoiceNumber, Invoice.vwRegister.AccountCode, Invoice.vwRegister.InvoiceTypeCode, Invoice.vwRegister.InvoiceStatusCode, Invoice.vwRegister.InvoicedOn, 
                         Invoice.vwRegister.InvoiceValue, Invoice.vwRegister.TaxValue, Invoice.vwRegister.PaidValue, Invoice.vwRegister.PaidTaxValue, Invoice.vwRegister.PaymentTerms, Invoice.vwRegister.Notes, 
                         Invoice.vwRegister.Printed, Invoice.vwRegister.AccountName, Invoice.vwRegister.UserName, Invoice.vwRegister.InvoiceStatus, Invoice.vwRegister.CashModeCode, Invoice.vwRegister.InvoiceType, 
                         (Invoice.vwRegister.InvoiceValue + Invoice.vwRegister.TaxValue) - (Invoice.vwRegister.PaidValue + Invoice.vwRegister.PaidTaxValue) AS UnpaidValue
FROM            App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                         Invoice.vwRegister ON App.tbYearPeriod.StartOn = Invoice.vwRegister.StartOn
WHERE        (Invoice.vwRegister.InvoiceTypeCode > 1);
GO

/****** Object:  View [Invoice].[vwHistorySalesItems]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwHistorySalesItems]
AS
SELECT        App.tbYearPeriod.YearNumber, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.InvoiceNumber, 
                         (Invoice.vwRegisterDetail.InvoiceValue + Invoice.vwRegisterDetail.TaxValue) - (Invoice.vwRegisterDetail.PaidValue + Invoice.vwRegisterDetail.PaidTaxValue) AS UnpaidValue, Invoice.vwRegisterDetail.TaskCode, 
                         Invoice.vwRegisterDetail.CashCode, Invoice.vwRegisterDetail.CashDescription, Invoice.vwRegisterDetail.TaxCode, Invoice.vwRegisterDetail.AccountCode, Invoice.vwRegisterDetail.InvoicedOn, 
                         Invoice.vwRegisterDetail.InvoiceValue, Invoice.vwRegisterDetail.TaxValue, Invoice.vwRegisterDetail.PaidValue, Invoice.vwRegisterDetail.PaidTaxValue, Invoice.vwRegisterDetail.PaymentTerms, 
                         Invoice.vwRegisterDetail.AccountName, Invoice.vwRegisterDetail.InvoiceStatus, Invoice.vwRegisterDetail.InvoiceType, Invoice.vwRegisterDetail.InvoiceTypeCode, 
                         Invoice.vwRegisterDetail.InvoiceStatusCode
FROM            Invoice.vwRegisterDetail INNER JOIN
                         App.tbYearPeriod ON Invoice.vwRegisterDetail.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
WHERE        (Invoice.vwRegisterDetail.InvoiceTypeCode < 2);
GO

/****** Object:  View [Invoice].[vwTaxBase]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO



CREATE VIEW [Invoice].[vwTaxBase]
  AS
SELECT     InvoiceNumber, TaxCode, SUM(InvoiceValue) AS InvoiceValueTotal, SUM(TaxValue) AS TaxValueTotal
FROM         Invoice.tbItem
GROUP BY InvoiceNumber, TaxCode
HAVING      (NOT (TaxCode IS NULL))
UNION
SELECT     InvoiceNumber, TaxCode, SUM(InvoiceValue) AS InvoiceValueTotal, SUM(TaxValue) AS TaxValueTotal
FROM         Invoice.tbTask
GROUP BY InvoiceNumber, TaxCode
HAVING      (NOT (TaxCode IS NULL))





GO

/****** Object:  View [Invoice].[vwTaxSummary]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO





CREATE VIEW [Invoice].[vwTaxSummary]
  AS
SELECT     InvoiceNumber, TaxCode, SUM(InvoiceValueTotal) AS InvoiceValueTotal, SUM(TaxValueTotal) AS TaxValueTotal, SUM(TaxValueTotal) 
                      / SUM(InvoiceValueTotal) AS TaxRate
FROM         Invoice.vwTaxBase
GROUP BY InvoiceNumber, TaxCode





GO

/****** Object:  View [Invoice].[vwHistorySales]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwHistorySales]
AS
SELECT        App.tbYearPeriod.YearNumber, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, Invoice.vwRegister.StartOn, 
                         Invoice.vwRegister.InvoiceNumber, Invoice.vwRegister.AccountCode, Invoice.vwRegister.InvoiceTypeCode, Invoice.vwRegister.InvoiceStatusCode, Invoice.vwRegister.InvoicedOn, 
                         Invoice.vwRegister.InvoiceValue, Invoice.vwRegister.TaxValue, Invoice.vwRegister.PaidValue, Invoice.vwRegister.PaidTaxValue, Invoice.vwRegister.PaymentTerms, Invoice.vwRegister.Notes, 
                         Invoice.vwRegister.Printed, Invoice.vwRegister.AccountName, Invoice.vwRegister.UserName, Invoice.vwRegister.InvoiceStatus, Invoice.vwRegister.CashModeCode, Invoice.vwRegister.InvoiceType, 
                         (Invoice.vwRegister.InvoiceValue + Invoice.vwRegister.TaxValue) - (Invoice.vwRegister.PaidValue + Invoice.vwRegister.PaidTaxValue) AS UnpaidValue
FROM            App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                         Invoice.vwRegister ON App.tbYearPeriod.StartOn = Invoice.vwRegister.StartOn
WHERE        (Invoice.vwRegister.InvoiceTypeCode < 2);
GO

/****** Object:  View [Org].[vwMailContacts]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO



CREATE VIEW [Org].[vwMailContacts]
  AS
SELECT     AccountCode, ContactName, NickName, NameTitle + N' ' + ContactName AS FormalName, JobTitle, Department
FROM         Org.tbContact
WHERE     (OnMailingList <> 0)



GO

/****** Object:  View [Org].[vwAddresses]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO



CREATE VIEW [Org].[vwAddresses]
  AS
SELECT     TOP 100 PERCENT Org.tbOrg.AccountName, Org.tbAddress.Address, Org.tbOrg.OrganisationTypeCode, Org.tbOrg.OrganisationStatusCode, 
                      Org.tbType.OrganisationType, Org.tbStatus.OrganisationStatus, Org.vwMailContacts.ContactName, Org.vwMailContacts.NickName, 
                      Org.vwMailContacts.FormalName, Org.vwMailContacts.JobTitle, Org.vwMailContacts.Department
FROM         Org.tbOrg INNER JOIN
                      Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode INNER JOIN
                      Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode INNER JOIN
                      Org.tbStatus ON Org.tbOrg.OrganisationStatusCode = Org.tbStatus.OrganisationStatusCode LEFT OUTER JOIN
                      Org.vwMailContacts ON Org.tbOrg.AccountCode = Org.vwMailContacts.AccountCode
ORDER BY Org.tbOrg.AccountName



GO

/****** Object:  View [Org].[vwTaskCount]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO



CREATE VIEW [Org].[vwTaskCount]
  AS
SELECT     AccountCode, COUNT(TaskCode) AS TaskCount
FROM         Task.tbTask
WHERE     (TaskStatusCode < 2)
GROUP BY AccountCode



GO

/****** Object:  View [Org].[vwDatasheet]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwDatasheet]
AS
SELECT     Org.tbOrg.AccountCode, Org.tbOrg.AccountName, ISNULL(Org.vwTaskCount.TaskCount, 0) AS Tasks, Org.tbOrg.OrganisationTypeCode, 
                      Org.tbType.OrganisationType, Org.tbType.CashModeCode, Org.tbOrg.OrganisationStatusCode, Org.tbStatus.OrganisationStatus, 
                      Org.tbAddress.Address, App.tbTaxCode.TaxDescription, Org.tbOrg.TaxCode, Org.tbOrg.AddressCode, Org.tbOrg.AreaCode, 
                      Org.tbOrg.PhoneNumber, Org.tbOrg.FaxNumber, Org.tbOrg.EmailAddress, Org.tbOrg.WebSite, Org.fnIndustrySectors(Org.tbOrg.AccountCode) 
                      AS IndustrySector, Org.tbOrg.AccountSource, Org.tbOrg.PaymentTerms, Org.tbOrg.PaymentDays, Org.tbOrg.NumberOfEmployees, 
                      Org.tbOrg.CompanyNumber, Org.tbOrg.VatNumber, Org.tbOrg.Turnover, Org.tbOrg.StatementDays, Org.tbOrg.OpeningBalance, 
                      Org.tbOrg.CurrentBalance, Org.tbOrg.ForeignJurisdiction, Org.tbOrg.BusinessDescription, Org.tbOrg.InsertedBy, Org.tbOrg.InsertedOn, 
                      Org.tbOrg.UpdatedBy, Org.tbOrg.UpdatedOn, Org.tbOrg.PayDaysFromMonthEnd
FROM         Org.tbOrg INNER JOIN
                      Org.tbStatus ON Org.tbOrg.OrganisationStatusCode = Org.tbStatus.OrganisationStatusCode INNER JOIN
                      Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode LEFT OUTER JOIN
                      App.tbTaxCode ON Org.tbOrg.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                      Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode LEFT OUTER JOIN
                      Org.vwTaskCount ON Org.tbOrg.AccountCode = Org.vwTaskCount.AccountCode

GO

/****** Object:  View [Task].[vwOpBucket]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwOpBucket]
AS
SELECT        op.TaskCode, op.OperationNumber, op.EndOn, buckets.Period, buckets.BucketId
FROM            Task.tbOp AS op CROSS APPLY
			(	SELECT  buckets.Period, buckets.BucketId
				FROM        App.fnBuckets(CURRENT_TIMESTAMP) buckets 
				WHERE     (StartDate <= op.EndOn) AND (EndDate > op.EndOn)) AS buckets
GO

/****** Object:  View [Task].[vwOps]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwOps]
AS
SELECT        Task.tbOp.TaskCode, Task.tbOp.OperationNumber, Task.vwOpBucket.Period, Task.vwOpBucket.BucketId, Task.tbOp.UserId, Task.tbOp.OpTypeCode, Task.tbOp.OpStatusCode, Task.tbOp.Operation, 
                         Task.tbOp.Note, Task.tbOp.StartOn, Task.tbOp.EndOn, Task.tbOp.Duration, Task.tbOp.OffsetDays, Task.tbOp.InsertedBy, Task.tbOp.InsertedOn, Task.tbOp.UpdatedBy, Task.tbOp.UpdatedOn, Task.tbTask.TaskTitle,
                          Task.tbStatus.TaskStatus, Task.tbTask.ActionOn, Task.tbTask.Quantity, Cash.tbCode.CashDescription, Task.tbTask.TotalCharge, Task.tbTask.AccountCode, Org.tbOrg.AccountName
FROM            Task.tbOp INNER JOIN
                         Task.tbTask ON Task.tbOp.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
                         Task.vwOpBucket ON Task.tbOp.TaskCode = Task.vwOpBucket.TaskCode AND Task.tbOp.OperationNumber = Task.vwOpBucket.OperationNumber LEFT OUTER JOIN
                         Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode
GO

/****** Object:  View [Org].[vwStatusReport]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwStatusReport]
AS
SELECT        Org.vwDatasheet.AccountCode, Org.vwDatasheet.AccountName, Org.vwDatasheet.OrganisationType, Org.vwDatasheet.OrganisationStatus, Org.vwDatasheet.TaxDescription, Org.vwDatasheet.Address, 
                         Org.vwDatasheet.AreaCode, Org.vwDatasheet.PhoneNumber, Org.vwDatasheet.FaxNumber, Org.vwDatasheet.EmailAddress, Org.vwDatasheet.WebSite, Org.vwDatasheet.IndustrySector, 
                         Org.vwDatasheet.AccountSource, Org.vwDatasheet.PaymentTerms, Org.vwDatasheet.PaymentDays, Org.vwDatasheet.NumberOfEmployees, Org.vwDatasheet.CompanyNumber, Org.vwDatasheet.VatNumber, 
                         Org.vwDatasheet.Turnover, Org.vwDatasheet.StatementDays, Org.vwDatasheet.OpeningBalance, Org.vwDatasheet.CurrentBalance, Org.vwDatasheet.ForeignJurisdiction, Org.vwDatasheet.BusinessDescription, 
                         Org.tbPayment.PaymentCode, Usr.tbUser.UserName, App.tbTaxCode.TaxDescription AS PaymentTaxDescription, Org.tbAccount.CashAccountName, Cash.tbCode.CashDescription, Org.tbPayment.UserId, 
                         Org.tbPayment.CashAccountCode, Org.tbPayment.CashCode, Org.tbPayment.TaxCode, Org.tbPayment.PaidOn, Org.tbPayment.PaidInValue, Org.tbPayment.PaidOutValue, Org.tbPayment.TaxInValue, 
                         Org.tbPayment.TaxOutValue, Org.tbPayment.InsertedBy, Org.tbPayment.InsertedOn, Org.tbPayment.UpdatedBy, Org.tbPayment.UpdatedOn, Org.tbPayment.PaymentReference
FROM            Org.tbPayment INNER JOIN
                         Usr.tbUser ON Org.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
                         Org.tbAccount ON Org.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
                         Cash.tbCode ON Org.tbPayment.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
                         App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
                         Org.vwDatasheet ON Org.tbPayment.AccountCode = Org.vwDatasheet.AccountCode
WHERE        (Org.tbPayment.PaymentStatusCode = 1);
GO

/****** Object:  View [Cash].[vwCorpTaxInvoiceItems]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO


CREATE VIEW [Cash].[vwCorpTaxInvoiceItems]
AS
SELECT     TOP (100) PERCENT App.fnAccountPeriod(Invoice.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.InvoiceValue * - 1 ELSE Invoice.tbItem.InvoiceValue END AS InvoiceValue
FROM         Invoice.tbItem INNER JOIN
                      Cash.fnCorpTaxCashCodes() AS fnNetProfitCashCodes ON Invoice.tbItem.CashCode = fnNetProfitCashCodes.CashCode INNER JOIN
                      Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
ORDER BY StartOn

GO

/****** Object:  View [Cash].[vwCorpTaxInvoiceTasks]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwCorpTaxInvoiceTasks]
AS
SELECT     TOP (100) PERCENT App.fnAccountPeriod(Invoice.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.InvoiceValue * - 1 ELSE Invoice.tbTask.InvoiceValue END AS InvoiceValue
FROM         Invoice.tbTask INNER JOIN
                      Cash.fnCorpTaxCashCodes() AS fnNetProfitCashCodes ON Invoice.tbTask.CashCode = fnNetProfitCashCodes.CashCode INNER JOIN
                      Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
ORDER BY StartOn

GO

/****** Object:  View [Cash].[vwCorpTaxInvoiceValue]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwCorpTaxInvoiceValue]
AS
SELECT     StartOn, SUM(InvoiceValue) AS NetProfit
FROM         Cash.vwCorpTaxInvoiceItems
GROUP BY StartOn
UNION
SELECT     StartOn, SUM(InvoiceValue) AS NetProfit
FROM         Cash.vwCorpTaxInvoiceTasks
GROUP BY StartOn
GO

/****** Object:  View [Cash].[vwCorpTaxInvoiceBase]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwCorpTaxInvoiceBase]
AS
SELECT     StartOn, SUM(NetProfit) AS NetProfit
FROM         Cash.vwCorpTaxInvoiceValue
GROUP BY StartOn

GO

/****** Object:  View [Cash].[vwCorpTaxInvoice]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwCorpTaxInvoice]
AS
SELECT     TOP (100) PERCENT App.tbYearPeriod.StartOn, Cash.vwCorpTaxInvoiceBase.NetProfit, 
                      Cash.vwCorpTaxInvoiceBase.NetProfit * App.tbYearPeriod.CorporationTaxRate + App.tbYearPeriod.TaxAdjustment AS CorporationTax, 
                      App.tbYearPeriod.TaxAdjustment
FROM         Cash.vwCorpTaxInvoiceBase INNER JOIN
                      App.tbYearPeriod ON Cash.vwCorpTaxInvoiceBase.StartOn = App.tbYearPeriod.StartOn
ORDER BY App.tbYearPeriod.StartOn

GO

/****** Object:  View [Cash].[vwTaxCorpTotals]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwTaxCorpTotals]
AS
SELECT     TOP (100) PERCENT Cash.vwCorpTaxInvoice.StartOn, YEAR(App.tbYearPeriod.StartOn) AS PeriodYear, App.tbYear.Description, 
                      App.tbMonth.MonthName + ' ' + LTRIM(STR(YEAR(App.tbYearPeriod.StartOn))) AS Period, App.tbYearPeriod.CorporationTaxRate, 
                      App.tbYearPeriod.TaxAdjustment, SUM(Cash.vwCorpTaxInvoice.NetProfit) AS NetProfit, SUM(Cash.vwCorpTaxInvoice.CorporationTax) AS CorporationTax
FROM         Cash.vwCorpTaxInvoice INNER JOIN
                      App.tbYearPeriod ON Cash.vwCorpTaxInvoice.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                      App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                      App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
WHERE     (App.tbYear.CashStatusCode = 2) OR
                      (App.tbYear.CashStatusCode = 3)
GROUP BY App.tbYear.Description, App.tbMonth.MonthName, Cash.vwCorpTaxInvoice.StartOn, YEAR(App.tbYearPeriod.StartOn), 
                      App.tbYearPeriod.CorporationTaxRate, App.tbYearPeriod.TaxAdjustment
ORDER BY Cash.vwCorpTaxInvoice.StartOn

GO

/****** Object:  View [Invoice].[vwRegisterExpenses]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwRegisterExpenses]
 AS
SELECT     Invoice.vwRegisterTasks.StartOn, Invoice.vwRegisterTasks.InvoiceNumber, Invoice.vwRegisterTasks.TaskCode, App.tbYearPeriod.YearNumber, 
                      App.tbYear.Description, App.tbMonth.MonthName + ' ' + LTRIM(STR(YEAR( App.tbYearPeriod.StartOn))) AS Period, Invoice.vwRegisterTasks.TaskTitle, 
                      Invoice.vwRegisterTasks.CashCode, Invoice.vwRegisterTasks.CashDescription, Invoice.vwRegisterTasks.TaxCode, Invoice.vwRegisterTasks.TaxDescription, 
                      Invoice.vwRegisterTasks.AccountCode, Invoice.vwRegisterTasks.InvoiceTypeCode, Invoice.vwRegisterTasks.InvoiceStatusCode, Invoice.vwRegisterTasks.InvoicedOn, 
                      Invoice.vwRegisterTasks.InvoiceValue, Invoice.vwRegisterTasks.TaxValue, Invoice.vwRegisterTasks.PaidValue, Invoice.vwRegisterTasks.PaidTaxValue, 
                      Invoice.vwRegisterTasks.PaymentTerms, Invoice.vwRegisterTasks.Printed, Invoice.vwRegisterTasks.AccountName, Invoice.vwRegisterTasks.UserName, 
                      Invoice.vwRegisterTasks.InvoiceStatus, Invoice.vwRegisterTasks.CashModeCode, Invoice.vwRegisterTasks.InvoiceType, 
                      (Invoice.vwRegisterTasks.InvoiceValue + Invoice.vwRegisterTasks.TaxValue) - (Invoice.vwRegisterTasks.PaidValue + Invoice.vwRegisterTasks.PaidTaxValue) 
                      AS UnpaidValue
FROM         Invoice.vwRegisterTasks INNER JOIN
                      App.tbYearPeriod ON Invoice.vwRegisterTasks.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                      App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                      App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
WHERE     (Task.fnIsExpense(Invoice.vwRegisterTasks.TaskCode) = 1)

GO

/****** Object:  View [Task].[vwInvoiceValue]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwInvoiceValue]
AS
SELECT        TaskCode, SUM(InvoiceValue) AS InvoiceValue, SUM(TaxValue) AS InvoiceTax
FROM            Invoice.tbTask
GROUP BY TaskCode

GO

/****** Object:  View [Cash].[vwCodeOrderSummary]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwCodeOrderSummary]
AS
SELECT        Task.tbTask.CashCode, App.fnAccountPeriod(Task.tbTask.ActionOn) AS StartOn, SUM(Task.tbTask.TotalCharge) - ISNULL(Task.vwInvoiceValue.InvoiceValue, 0) 
                         AS InvoiceValue, SUM(Task.tbTask.TotalCharge * ISNULL(App.vwTaxRates.TaxRate, 0)) - ISNULL(Task.vwInvoiceValue.InvoiceTax, 0) AS InvoiceTax
FROM            Task.tbTask INNER JOIN
                         Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
                         Task.vwInvoiceValue ON Task.tbTask.TaskCode = Task.vwInvoiceValue.TaskCode LEFT OUTER JOIN
                         App.vwTaxRates ON Task.tbTask.TaxCode = App.vwTaxRates.TaxCode
WHERE        (Task.tbTask.TaskStatusCode = 1) OR
                         (Task.tbTask.TaskStatusCode = 2)
GROUP BY Task.tbTask.CashCode, App.fnAccountPeriod(Task.tbTask.ActionOn), Task.vwInvoiceValue.InvoiceValue, Task.vwInvoiceValue.InvoiceTax

GO

/****** Object:  View [Cash].[vwSummaryInvoices]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO



CREATE VIEW [Cash].[vwSummaryInvoices]
  AS
SELECT     Invoice.tbInvoice.InvoiceNumber, CASE Invoice.tbInvoice.InvoiceTypeCode WHEN 0 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) 
                      WHEN 3 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) ELSE 0 END AS ToCollect, 
                      CASE Invoice.tbInvoice.InvoiceTypeCode WHEN 1 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) WHEN 2 THEN (InvoiceValue + TaxValue) 
                      - (PaidValue + PaidTaxValue) ELSE 0 END AS ToPay, CASE Invoice.tbType.CashModeCode WHEN 0 THEN (TaxValue - PaidTaxValue) 
                      * - 1 WHEN 1 THEN TaxValue - PaidTaxValue END AS TaxValue
FROM         Invoice.tbInvoice INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE     (Invoice.tbInvoice.InvoiceStatusCode = 1) OR
                      (Invoice.tbInvoice.InvoiceStatusCode = 2)



GO

/****** Object:  View [Cash].[vwSummaryBase]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO



CREATE  VIEW [Cash].[vwSummaryBase]
  AS
SELECT     ISNULL(SUM(ToCollect), 0) AS Collect, ISNULL(SUM(ToPay), 0) AS Pay, ISNULL(SUM(TaxValue), 0) + App.fnVatBalance() 
                      + App.fnCorpTaxBalance() AS Tax, Cash.fnCompanyBalance() AS CompanyBalance
FROM         Cash.vwSummaryInvoices



GO

/****** Object:  View [Cash].[vwSummary]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwSummary]
AS
SELECT        CURRENT_TIMESTAMP AS Timestamp, Collect, Pay, Tax, CompanyBalance AS Cash, CompanyBalance + Collect - Pay - Tax AS Balance
FROM            Cash.vwSummaryBase
GO

/****** Object:  View [Cash].[vwAccountLastPeriodEntry]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO



CREATE VIEW [Cash].[vwAccountLastPeriodEntry]
  AS
SELECT     CashAccountCode, StartOn, MAX(EntryNumber) AS LastEntry
FROM         Cash.vwAccountStatements
GROUP BY CashAccountCode, StartOn
HAVING      (NOT (StartOn IS NULL))



GO

/****** Object:  View [Cash].[vwAccountPeriodClosingBalance]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwAccountPeriodClosingBalance]
AS
SELECT        Org.tbAccount.CashCode, Cash.vwAccountLastPeriodEntry.StartOn, SUM(Cash.vwAccountStatements.PaidBalance) 
                         + SUM(Cash.vwAccountStatements.TaxedBalance) AS ClosingBalance
FROM            Cash.vwAccountLastPeriodEntry INNER JOIN
                         Cash.vwAccountStatements ON Cash.vwAccountLastPeriodEntry.CashAccountCode = Cash.vwAccountStatements.CashAccountCode AND 
                         Cash.vwAccountLastPeriodEntry.StartOn = Cash.vwAccountStatements.StartOn AND 
                         Cash.vwAccountLastPeriodEntry.LastEntry = Cash.vwAccountStatements.EntryNumber INNER JOIN
                         Org.tbAccount ON Cash.vwAccountLastPeriodEntry.CashAccountCode = Org.tbAccount.CashAccountCode
GROUP BY Org.tbAccount.CashCode, Cash.vwAccountLastPeriodEntry.StartOn

GO

/****** Object:  View [Cash].[vwCodeForecastSummary]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwCodeForecastSummary]
AS
SELECT        Task.tbTask.CashCode, App.fnAccountPeriod(Task.tbTask.ActionOn) AS StartOn, SUM(Task.tbTask.TotalCharge) AS ForecastValue, SUM(Task.tbTask.TotalCharge * ISNULL(App.vwTaxRates.TaxRate, 0)) 
                         AS ForecastTax
FROM            Task.tbTask INNER JOIN
                         Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Invoice.tbTask AS InvoiceTask ON Task.tbTask.TaskCode = InvoiceTask.TaskCode AND Task.tbTask.TaskCode = InvoiceTask.TaskCode LEFT OUTER JOIN
                         App.vwTaxRates ON Task.tbTask.TaxCode = App.vwTaxRates.TaxCode
GROUP BY Task.tbTask.CashCode, App.fnAccountPeriod(Task.tbTask.ActionOn)

GO

/****** Object:  View [App].[vwGraphBankBalance]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [App].[vwGraphBankBalance]
AS
SELECT        Format(Cash.vwAccountPeriodClosingBalance.StartOn, 'yyyy-MM') AS PeriodOn, SUM(Cash.vwAccountPeriodClosingBalance.ClosingBalance) AS SumOfClosingBalance
FROM            Cash.vwAccountPeriodClosingBalance INNER JOIN
                         Cash.tbCode ON Cash.vwAccountPeriodClosingBalance.CashCode = Cash.tbCode.CashCode
WHERE        (Cash.vwAccountPeriodClosingBalance.StartOn > DATEADD(m, - 6, CURRENT_TIMESTAMP))
GROUP BY Format(Cash.vwAccountPeriodClosingBalance.StartOn, 'yyyy-MM');
GO

/****** Object:  View [Usr].[vwCredentials]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Usr].[vwCredentials]
  AS
SELECT     UserId, UserName, LogonName, Administrator
FROM         Usr.tbUser
WHERE     (LogonName = SUSER_SNAME())
GO

/****** Object:  View [Usr].[vwUserMenus]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Usr].[vwUserMenus]
AS
SELECT Usr.tbMenuUser.MenuId
FROM Usr.vwCredentials INNER JOIN Usr.tbMenuUser ON Usr.vwCredentials.UserId = Usr.tbMenuUser.UserId;
GO

/****** Object:  View [App].[vwPeriods]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [App].[vwPeriods]
AS
	SELECT        TOP (100) PERCENT App.tbYearPeriod.StartOn, App.tbYear.Description + SPACE(1) + App.tbMonth.MonthName AS Description
	FROM            App.tbYearPeriod INNER JOIN
							 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
							 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
	WHERE        (App.tbYearPeriod.StartOn < DATEADD(d, 1, CURRENT_TIMESTAMP)) AND (App.tbYear.CashStatusCode < 3)
	ORDER BY App.tbYearPeriod.StartOn DESC;
GO

/****** Object:  View [Org].[vwInvoiceSummary]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwInvoiceSummary]
AS
	WITH ois AS
	(
		SELECT        AccountCode, StartOn, SUM(InvoiceValue) AS PeriodValue
		FROM            Invoice.vwRegister
		GROUP BY AccountCode, StartOn
	), acc AS
	(
		SELECT Org.tbOrg.AccountCode, App.vwPeriods.StartOn
		FROM Org.tbOrg CROSS JOIN App.vwPeriods
	)
	SELECT TOP (100) PERCENT acc.AccountCode, acc.StartOn, ois.PeriodValue 
	FROM ois RIGHT OUTER JOIN acc ON ois.AccountCode = acc.AccountCode AND ois.StartOn = acc.StartOn
	ORDER BY acc.AccountCode, acc.StartOn;
GO

/****** Object:  View [App].[vwDocPurchaseEnquiry]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [App].[vwDocPurchaseEnquiry]
AS
SELECT        TOP (100) PERCENT Task.vwTasks.TaskCode, Task.vwTasks.ActionOn, Task.vwTasks.ActivityCode, Task.vwTasks.ActionById, Task.vwTasks.BucketId, Task.vwTasks.TaskTitle, Task.vwTasks.AccountCode, 
                         Task.vwTasks.ContactName, Task.vwTasks.TaskNotes, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, 
                         Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, Org.tbAddress.Address AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
                         Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, Task.vwTasks.ActionName, Task.vwTasks.Period, Task.vwTasks.Printed, Task.vwTasks.Spooled
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 0) AND (Task.vwTasks.TaskStatusCode = 0)
ORDER BY Task.vwTasks.ActionOn;
GO

/****** Object:  View [App].[vwDocPurchaseOrder]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [App].[vwDocPurchaseOrder]
AS
SELECT        TOP (100) PERCENT Task.vwTasks.TaskCode, Task.vwTasks.ActionOn, Task.vwTasks.ActivityCode, Task.vwTasks.ActionById, Task.vwTasks.BucketId, Task.vwTasks.TaskTitle, Task.vwTasks.AccountCode, 
                         Task.vwTasks.ContactName, Task.vwTasks.TaskNotes, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, 
                         Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, Org.tbAddress.Address AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
                         Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, Task.vwTasks.ActionName, Task.vwTasks.Period, Task.vwTasks.Printed, Task.vwTasks.Spooled
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 0) AND (Task.vwTasks.TaskStatusCode > 0)
ORDER BY Task.vwTasks.ActionOn;
GO

/****** Object:  View [App].[vwDocQuotation]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [App].[vwDocQuotation]
AS
SELECT        TOP (100) PERCENT Task.vwTasks.TaskCode, Task.vwTasks.ActionOn, Task.vwTasks.ActivityCode, Task.vwTasks.ActionById, Task.vwTasks.BucketId, Task.vwTasks.TaskTitle, Task.vwTasks.AccountCode, 
                         Task.vwTasks.ContactName, Task.vwTasks.TaskNotes, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, 
                         Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, Org.tbAddress.Address AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
                         Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, Task.vwTasks.ActionName, Task.vwTasks.Period, Task.vwTasks.Printed, Task.vwTasks.Spooled
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 1) AND (Task.vwTasks.TaskStatusCode = 0)
ORDER BY Task.vwTasks.ActionOn;
GO

/****** Object:  View [App].[vwDocSalesOrder]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [App].[vwDocSalesOrder]
AS
SELECT        TOP (100) PERCENT Task.vwTasks.TaskCode, Task.vwTasks.ActionOn, Task.vwTasks.ActivityCode, Task.vwTasks.ActionById, Task.vwTasks.BucketId, Task.vwTasks.AccountCode, Task.vwTasks.TaskTitle, 
                         Task.vwTasks.ContactName, Task.vwTasks.TaskNotes, Task.vwTasks.OwnerName, Task.vwTasks.CashCode, Task.vwTasks.CashDescription, Task.vwTasks.Quantity, Activity.tbActivity.UnitOfMeasure, 
                         Task.vwTasks.UnitCharge, Task.vwTasks.TotalCharge, Org_tbAddress_1.Address AS FromAddress, Org.tbAddress.Address AS ToAddress, Task.vwTasks.InsertedBy, Task.vwTasks.InsertedOn, 
                         Task.vwTasks.UpdatedBy, Task.vwTasks.UpdatedOn, Task.vwTasks.AccountName, Task.vwTasks.ActionName, Task.vwTasks.Period, Task.vwTasks.Printed, Task.vwTasks.Spooled
FROM            Task.vwTasks LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON Task.vwTasks.AddressCodeFrom = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         Org.tbAddress ON Task.vwTasks.AddressCodeTo = Org.tbAddress.AddressCode INNER JOIN
                         Activity.tbActivity ON Task.vwTasks.ActivityCode = Activity.tbActivity.ActivityCode
WHERE        (Task.vwTasks.CashCode IS NOT NULL) AND (Task.vwTasks.CashModeCode = 1) AND (Task.vwTasks.TaskStatusCode > 0)
ORDER BY Task.vwTasks.ActionOn;
GO

/****** Object:  View [App].[vwIdentity]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [App].[vwIdentity]
AS
SELECT TOP (1) Org.tbOrg.AccountName, Org.tbAddress.Address, Org.tbOrg.PhoneNumber, Org.tbOrg.FaxNumber, Org.tbOrg.EmailAddress, Org.tbOrg.WebSite, Org.tbOrg.Logo, Usr.tbUser.UserName, Usr.tbUser.LogonName, 
                         Usr.tbUser.Avatar, Org.tbOrg.CompanyNumber, Org.tbOrg.VatNumber
FROM            Org.tbOrg INNER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode INNER JOIN
                         App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode CROSS JOIN
                         Usr.vwCredentials INNER JOIN
                         Usr.tbUser ON Usr.vwCredentials.UserId = Usr.tbUser.UserId;
GO

/****** Object:  View [Task].[vwVatConfirmed]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwVatConfirmed]
AS
SELECT     App.fnAccountPeriod(Task.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN Cash.tbCategory.CashModeCode = 0 THEN (Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity,
                       0))) * App.vwTaxRates.TaxRate * - 1 ELSE Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) 
                      * App.vwTaxRates.TaxRate END AS VatValue
FROM         Task.tbTask INNER JOIN
                      Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
                      App.vwTaxRates ON Task.tbTask.TaxCode = App.vwTaxRates.TaxCode LEFT OUTER JOIN
                      Task.vwInvoicedQuantity ON Task.tbTask.TaskCode = Task.vwInvoicedQuantity.TaskCode
WHERE     (App.vwTaxRates.TaxTypeCode = 1) AND (Task.tbTask.TaskStatusCode > 0) AND (Task.tbTask.TaskStatusCode < 3) AND 
                      (CASE WHEN Cash.tbCategory.CashModeCode = 0 THEN (Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity,
                       0))) * App.vwTaxRates.TaxRate ELSE Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) 
                      * App.vwTaxRates.TaxRate * - 1 END <> 0) AND (Task.tbTask.PaymentOn <= DATEADD(d, App.fnTaxHorizon(), CURRENT_TIMESTAMP))

GO

/****** Object:  View [Task].[vwVatFull]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO


CREATE VIEW [Task].[vwVatFull]
  AS
SELECT     App.fnAccountPeriod(Task.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN Cash.tbCategory.CashModeCode = 0 THEN (Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity,
                       0))) * App.vwTaxRates.TaxRate ELSE Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) 
                      * App.vwTaxRates.TaxRate * - 1 END AS VatValue
FROM         Task.tbTask INNER JOIN
                      Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
                      App.vwTaxRates ON Task.tbTask.TaxCode = App.vwTaxRates.TaxCode LEFT OUTER JOIN
                      Task.vwInvoicedQuantity ON Task.tbTask.TaskCode = Task.vwInvoicedQuantity.TaskCode
WHERE     (App.vwTaxRates.TaxTypeCode = 1) AND (Task.tbTask.TaskStatusCode < 3) AND 
                      (CASE WHEN Cash.tbCategory.CashModeCode = 0 THEN (Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity,
                       0))) * App.vwTaxRates.TaxRate ELSE Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) 
                      * App.vwTaxRates.TaxRate * - 1 END <> 0)

GO

/****** Object:  View [Cash].[vwCorpTaxTasksBase]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO


CREATE VIEW [Cash].[vwCorpTaxTasksBase]
AS
SELECT     TOP 100 PERCENT Task.tbTask.TaskCode, Task.tbStatus.TaskStatus, App.fnAccountPeriod(Task.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN Cash.tbCategory.CashModeCode = 0 THEN (Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0))) 
                      * - 1 ELSE Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) END AS OrderValue
FROM         Task.tbStatus INNER JOIN
                      Cash.fnCorpTaxCashCodes() AS fnNetProfitCashCodes INNER JOIN
                      Cash.tbCategory INNER JOIN
                      Cash.tbCode ON Cash.tbCategory.CategoryCode = Cash.tbCode.CategoryCode ON 
                      fnNetProfitCashCodes.CashCode = Cash.tbCode.CashCode INNER JOIN
                      Task.tbTask ON fnNetProfitCashCodes.CashCode = Task.tbTask.CashCode ON Task.tbStatus.TaskStatusCode = Task.tbTask.TaskStatusCode LEFT OUTER JOIN
                      Task.vwInvoicedQuantity ON Task.tbTask.TaskCode = Task.vwInvoicedQuantity.TaskCode
WHERE     (Task.tbTask.TaskStatusCode < 3) AND (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0) > 0)

GO

/****** Object:  View [Cash].[vwCorpTaxTasks]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwCorpTaxTasks]
  AS
SELECT     Cash.vwCorpTaxTasksBase.StartOn, SUM(Cash.vwCorpTaxTasksBase.OrderValue) AS NetProfit, 
                      Cash.vwCorpTaxTasksBase.OrderValue * App.tbYearPeriod.CorporationTaxRate AS CorporationTax
FROM         Cash.vwCorpTaxTasksBase INNER JOIN
                      App.tbYearPeriod ON Cash.vwCorpTaxTasksBase.StartOn = App.tbYearPeriod.StartOn
GROUP BY Cash.vwCorpTaxTasksBase.StartOn, Cash.vwCorpTaxTasksBase.OrderValue * App.tbYearPeriod.CorporationTaxRate
GO

/****** Object:  View [Cash].[vwCorpTaxConfirmedBase]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwCorpTaxConfirmedBase]
AS
SELECT        TOP (100) PERCENT App.fnAccountPeriod(Task.tbTask.PaymentOn) AS StartOn, 
                         CASE WHEN Cash.tbCategory.CashModeCode = 0 THEN (Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0))) 
                         * - 1 ELSE Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0)) END AS OrderValue
FROM            Task.vwInvoicedQuantity RIGHT OUTER JOIN
                         Cash.fnCorpTaxCashCodes() AS fnNetProfitCashCodes INNER JOIN
                         Cash.tbCategory INNER JOIN
                         Cash.tbCode ON Cash.tbCategory.CategoryCode = Cash.tbCode.CategoryCode ON 
                         fnNetProfitCashCodes.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Task.tbTask ON fnNetProfitCashCodes.CashCode = Task.tbTask.CashCode ON Task.vwInvoicedQuantity.TaskCode = Task.tbTask.TaskCode
WHERE        (Task.tbTask.TaskStatusCode > 0) AND (Task.tbTask.TaskStatusCode < 3) AND (Task.tbTask.Quantity - ISNULL(Task.vwInvoicedQuantity.InvoiceQuantity, 0) > 0) AND 
                         (Task.tbTask.PaymentOn <= DATEADD(d, App.fnTaxHorizon(), CURRENT_TIMESTAMP))

GO

/****** Object:  View [Cash].[vwCorpTaxConfirmed]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwCorpTaxConfirmed]
AS
SELECT        Cash.vwCorpTaxConfirmedBase.StartOn, SUM(Cash.vwCorpTaxConfirmedBase.OrderValue) AS NetProfit, 
                         SUM(Cash.vwCorpTaxConfirmedBase.OrderValue * App.tbYearPeriod.CorporationTaxRate) AS CorporationTax
FROM            Cash.vwCorpTaxConfirmedBase INNER JOIN
                         App.tbYearPeriod ON Cash.vwCorpTaxConfirmedBase.StartOn = App.tbYearPeriod.StartOn
GROUP BY Cash.vwCorpTaxConfirmedBase.StartOn

GO

/****** Object:  View [Org].[vwAccountLookup]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwAccountLookup]
AS
SELECT        Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Cash.tbMode.CashMode
FROM            Org.tbOrg INNER JOIN
                         Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode INNER JOIN
                         Cash.tbMode ON Org.tbType.CashModeCode = Cash.tbMode.CashModeCode
WHERE        (Org.tbOrg.OrganisationStatusCode < 3);
GO

/****** Object:  View [Cash].[vwAccountRebuild]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwAccountRebuild]
  AS
SELECT     Org.tbPayment.CashAccountCode, Org.tbAccount.OpeningBalance, 
                      Org.tbAccount.OpeningBalance + SUM(Org.tbPayment.PaidInValue - Org.tbPayment.PaidOutValue) AS CurrentBalance
FROM         Org.tbPayment INNER JOIN
                      Org.tbAccount ON Org.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode
WHERE     (Org.tbPayment.PaymentStatusCode > 0)
GROUP BY Org.tbPayment.CashAccountCode, Org.tbAccount.OpeningBalance
GO

/****** Object:  View [Org].[vwAccountSources]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwAccountSources]
AS
SELECT        AccountSource
FROM            Org.tbOrg
GROUP BY AccountSource
HAVING        (AccountSource IS NOT NULL);
GO

/****** Object:  View [App].[vwActivePeriod]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [App].[vwActivePeriod]
AS
SELECT App.tbYearPeriod.YearNumber, App.tbYearPeriod.StartOn, App.tbYear.Description, App.tbMonth.MonthName, fnActivePeriod.EndOn
FROM            App.tbYear INNER JOIN
                         App.fnActivePeriod() AS fnActivePeriod INNER JOIN
                         App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber ON fnActivePeriod.StartOn = App.tbYearPeriod.StartOn AND fnActivePeriod.YearNumber = App.tbYearPeriod.YearNumber ON 
                         App.tbYear.YearNumber = App.tbYearPeriod.YearNumber;
GO

/****** Object:  View [Task].[vwActiveStatusCodes]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwActiveStatusCodes]
AS
SELECT        TaskStatusCode, TaskStatus
FROM            Task.tbStatus
WHERE        (TaskStatusCode < 3);
GO

/****** Object:  View [Cash].[vwActiveYears]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwActiveYears]
   AS
SELECT     TOP 100 PERCENT App.tbYear.YearNumber, App.tbYear.Description, Cash.tbStatus.CashStatus
FROM         App.tbYear INNER JOIN
                      Cash.tbStatus ON App.tbYear.CashStatusCode = Cash.tbStatus.CashStatusCode
WHERE     (App.tbYear.CashStatusCode < 3)
ORDER BY App.tbYear.YearNumber
GO

/****** Object:  View [Invoice].[vwAgedDebtPurchases]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwAgedDebtPurchases]
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
                         Invoice.tbType.InvoiceType, (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) AS UnpaidValue, DATEDIFF(DD, CURRENT_TIMESTAMP, 
                         Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.CollectOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, 
                         Invoice.tbInvoice.Notes
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
WHERE        (Invoice.tbInvoice.InvoiceTypeCode > 1) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
ORDER BY Invoice.tbInvoice.CollectOn;
GO

/****** Object:  View [Invoice].[vwAgedDebtSales]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwAgedDebtSales]
AS
SELECT TOP 100 PERCENT  Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
                         Invoice.tbType.InvoiceType, (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) AS UnpaidValue, DATEDIFF(DD, CURRENT_TIMESTAMP, 
                         Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.CollectOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, 
                         Invoice.tbInvoice.Notes
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
WHERE        (Invoice.tbInvoice.InvoiceTypeCode < 2) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
ORDER BY Invoice.tbInvoice.CollectOn;
GO

/****** Object:  View [Cash].[vwAnalysisCodes]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwAnalysisCodes]
   AS
SELECT     TOP 100 PERCENT Cash.tbCategory.CategoryCode, Cash.tbCategory.Category, Cash.tbCategoryExp.Expression, 
                      Cash.tbCategoryExp.Format
FROM         Cash.tbCategory INNER JOIN
                      Cash.tbCategoryExp ON Cash.tbCategory.CategoryCode = Cash.tbCategoryExp.CategoryCode
WHERE     (Cash.tbCategory.CategoryTypeCode = 2)
ORDER BY Cash.tbCategory.DisplayOrder
GO

/****** Object:  View [Org].[vwAreaCodes]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwAreaCodes]
AS
SELECT        AreaCode
FROM            Org.tbOrg
GROUP BY AreaCode
HAVING        (AreaCode IS NOT NULL);
GO

/****** Object:  View [Task].[vwAttributeDescriptions]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwAttributeDescriptions]
AS
SELECT        Attribute, AttributeDescription
FROM            Task.tbAttribute
GROUP BY Attribute, AttributeDescription
HAVING        (AttributeDescription IS NOT NULL);
GO

/****** Object:  View [Task].[vwAttributesForOrder]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwAttributesForOrder]
AS
SELECT        TaskCode, Attribute, PrintOrder, AttributeDescription
FROM            Task.tbAttribute
WHERE        (AttributeTypeCode = 0);
GO

/****** Object:  View [Task].[vwAttributesForQuote]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwAttributesForQuote]
AS
SELECT        TaskCode, Attribute, PrintOrder, AttributeDescription
FROM            Task.tbAttribute
WHERE        (AttributeTypeCode = 1);
GO

/****** Object:  View [Org].[vwBalanceOutstanding]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwBalanceOutstanding]
  AS
SELECT     Invoice.tbInvoice.AccountCode, SUM(CASE Invoice.tbType.CashModeCode WHEN 0 THEN ((InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue)) 
                      * - 1 WHEN 1 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) END) AS Balance
FROM         Invoice.tbInvoice INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE     (Invoice.tbInvoice.InvoiceStatusCode > 0 AND Invoice.tbInvoice.InvoiceStatusCode < 3)
GROUP BY Invoice.tbInvoice.AccountCode
GO

/****** Object:  View [Cash].[vwBankCashCodes]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwBankCashCodes]
AS
SELECT        Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCode.TaxCode
FROM            Cash.tbCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
WHERE        (Cash.tbCategory.CashTypeCode = 3);
GO

/****** Object:  View [Activity].[vwCandidateCashCodes]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Activity].[vwCandidateCashCodes]
AS
SELECT TOP 100 PERCENT Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCategory.Category
FROM            Cash.tbCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
WHERE        (Cash.tbCategory.CashTypeCode = 0) OR
                         (Cash.tbCategory.CashTypeCode = 1)
ORDER BY Cash.tbCode.CashCode;
GO

/****** Object:  View [Invoice].[vwCandidateCredits]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwCandidateCredits]
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.UserId, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbInvoice.InvoicedOn, 
                         Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaidValue, Invoice.tbInvoice.PaidTaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, Invoice.tbInvoice.Printed, 
                         Invoice.tbInvoice.CollectOn, Invoice.tbInvoice.Spooled, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.InvoiceType
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 0)
ORDER BY Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoicedOn DESC
GO

/****** Object:  View [Invoice].[vwCandidateDebits]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwCandidateDebits]
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.UserId, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbInvoice.InvoicedOn, 
                         Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaidValue, Invoice.tbInvoice.PaidTaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, Invoice.tbInvoice.Printed, 
                         Invoice.tbInvoice.CollectOn, Invoice.tbInvoice.Spooled, Usr.tbUser.UserName, Invoice.tbStatus.InvoiceStatus, Invoice.tbType.InvoiceType
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 2)
ORDER BY Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoicedOn DESC
GO

/****** Object:  View [App].[vwCandidateHomeAccounts]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [App].[vwCandidateHomeAccounts]
AS
SELECT        Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Cash.tbMode.CashMode
FROM            Org.tbOrg INNER JOIN
                         Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode INNER JOIN
                         Cash.tbMode ON Org.tbType.CashModeCode = Cash.tbMode.CashModeCode
WHERE        (Org.tbOrg.OrganisationStatusCode < 3);
GO

/****** Object:  View [App].[vwCandidateNetProfitCodes]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [App].[vwCandidateNetProfitCodes]
AS
SELECT TOP 100 PERCENT CategoryCode, Category
FROM            Cash.tbCategory
WHERE        (CategoryTypeCode = 1)
ORDER BY CategoryCode;
GO

/****** Object:  View [Org].[vwCashAccounts]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwCashAccounts]
AS
SELECT        Org.tbAccount.CashAccountCode, Org.tbAccount.CashAccountName, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Org.tbAccount.OpeningBalance, Org.tbAccount.CurrentBalance, Org.tbAccount.SortCode, 
                         Org.tbAccount.AccountNumber, Org.tbAccount.AccountClosed
FROM            Org.tbOrg INNER JOIN
                         Org.tbAccount ON Org.tbOrg.AccountCode = Org.tbAccount.AccountCode INNER JOIN
                         Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode;
GO

/****** Object:  View [Org].[vwCashAccountsLive]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwCashAccountsLive]
AS
SELECT        Org.tbAccount.CashAccountCode, Org.tbAccount.CashAccountName
FROM            Org.tbAccount INNER JOIN
                         Org.tbOrg ON Org.tbAccount.AccountCode = Org.tbOrg.AccountCode
WHERE        (Org.tbAccount.AccountClosed = 0);
GO

/****** Object:  View [Cash].[vwCashFlowTypes]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwCashFlowTypes]
AS
SELECT        CashTypeCode, CashType
FROM            Cash.tbType
WHERE        (CashTypeCode < 3);
GO

/****** Object:  View [Task].[vwCashMode]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwCashMode]
  AS
SELECT     Task.tbTask.TaskCode, CASE WHEN Cash.tbCategory.CategoryCode IS NULL 
                      THEN Org.tbType.CashModeCode ELSE Cash.tbCategory.CashModeCode END AS CashModeCode
FROM         Task.tbTask INNER JOIN
                      Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
                      Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                      Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode
GO

/****** Object:  View [Cash].[vwCategoriesBank]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwCategoriesBank]
   AS
SELECT     TOP 100 PERCENT CategoryCode, Category, CashModeCode
FROM         Cash.tbCategory
WHERE     (CashTypeCode = 3) AND (CategoryTypeCode = 0)
GROUP BY CategoryCode, Category, DisplayOrder, CashModeCode
ORDER BY DisplayOrder, Category
GO

/****** Object:  View [Cash].[vwCategoriesNominal]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwCategoriesNominal]
   AS
SELECT     TOP 100 PERCENT CategoryCode, Category, CashModeCode
FROM         Cash.tbCategory
WHERE     (CashTypeCode = 2) AND (CategoryTypeCode = 0)
GROUP BY CategoryCode, Category, DisplayOrder, CashModeCode
ORDER BY DisplayOrder, Category
GO

/****** Object:  View [Cash].[vwCategoriesTax]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwCategoriesTax]
AS
SELECT        TOP (100) PERCENT CategoryCode, Category, CashModeCode
FROM            Cash.tbCategory
WHERE        (CashTypeCode = 1) AND (CategoryTypeCode = 0)
GROUP BY CategoryCode, Category, DisplayOrder, CashModeCode
ORDER BY DisplayOrder, Category
GO

/****** Object:  View [Cash].[vwCategoriesTotals]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwCategoriesTotals]
   AS
SELECT     TOP 100 PERCENT CategoryCode, CashModeCode, CashTypeCode, DisplayOrder, Category
FROM         Cash.tbCategory
WHERE     (CategoryTypeCode = 1)
ORDER BY CashTypeCode, CategoryCode
GO

/****** Object:  View [Cash].[vwCategoriesTrade]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwCategoriesTrade]
   AS
SELECT     TOP 100 PERCENT CategoryCode, Category, CashModeCode
FROM         Cash.tbCategory
WHERE     (CashTypeCode = 0) AND (CategoryTypeCode = 0)
GROUP BY CategoryCode, Category, DisplayOrder, CashModeCode
ORDER BY DisplayOrder, Category
GO

/****** Object:  View [Cash].[vwCategoryCodesExpressions]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwCategoryCodesExpressions]
AS
SELECT        CategoryCode, Category, DisplayOrder, CategoryTypeCode, CashModeCode, CashTypeCode
FROM            Cash.tbCategory
WHERE        (CategoryTypeCode = 2);
GO

/****** Object:  View [Cash].[vwCategoryCodesNominal]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwCategoryCodesNominal]
AS
SELECT        CategoryCode, Category, DisplayOrder, CategoryTypeCode, CashModeCode, CashTypeCode
FROM            Cash.tbCategory
WHERE        (CategoryTypeCode = 0) AND (CashTypeCode = 2);
GO

/****** Object:  View [Cash].[vwCategoryCodesTotals]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwCategoryCodesTotals]
AS
SELECT        CategoryCode, Category, DisplayOrder, CategoryTypeCode, CashModeCode, CashTypeCode
FROM            Cash.tbCategory
WHERE        (CategoryTypeCode = 1);
GO

/****** Object:  View [Cash].[vwCategoryCodesTrade]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwCategoryCodesTrade]
AS
SELECT        CategoryCode, Category, DisplayOrder, CategoryTypeCode, CashModeCode, CashTypeCode
FROM            Cash.tbCategory
WHERE        (CategoryTypeCode = 0) AND (CashTypeCode <> 2);
GO

/****** Object:  View [Cash].[vwCategoryTotalCandidates]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwCategoryTotalCandidates]
AS
SELECT        Cash.tbCategory.CategoryCode, Cash.tbCategory.Category, Cash.tbCategoryType.CategoryType, Cash.tbType.CashType, Cash.tbMode.CashMode
FROM            Cash.tbCategory INNER JOIN
                         Cash.tbCategoryType ON Cash.tbCategory.CategoryTypeCode = Cash.tbCategoryType.CategoryTypeCode INNER JOIN
                         Cash.tbType ON Cash.tbCategory.CashTypeCode = Cash.tbType.CashTypeCode INNER JOIN
                         Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode
WHERE        (Cash.tbCategory.CashTypeCode < 3);
GO

/****** Object:  View [Cash].[vwCodeLookup]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwCodeLookup]
AS
SELECT        Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCategory.Category, Cash.tbMode.CashMode
FROM            Cash.tbCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
                         Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode;

GO

/****** Object:  View [Activity].[vwCodes]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Activity].[vwCodes]
AS
SELECT        Activity.tbActivity.ActivityCode, Activity.tbActivity.UnitOfMeasure, Activity.tbActivity.CashCode
FROM            Activity.tbActivity LEFT OUTER JOIN
                         Cash.tbCode ON Activity.tbActivity.CashCode = Cash.tbCode.CashCode;
GO

/****** Object:  View [Org].[vwCompanyHeader]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwCompanyHeader]
AS
SELECT        TOP (1) Org.tbOrg.AccountName AS CompanyName, Org.tbAddress.Address AS CompanyAddress, Org.tbOrg.PhoneNumber AS CompanyPhoneNumber, Org.tbOrg.FaxNumber AS CompanyFaxNumber, 
                         Org.tbOrg.EmailAddress AS CompanyEmailAddress, Org.tbOrg.WebSite AS CompanyWebsite, Org.tbOrg.CompanyNumber, Org.tbOrg.VatNumber
FROM            Org.tbOrg INNER JOIN
                         App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode LEFT OUTER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode;
GO

/****** Object:  View [Org].[vwCompanyLogo]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwCompanyLogo]
AS
SELECT        TOP (1) Org.tbOrg.Logo
FROM            Org.tbOrg INNER JOIN
                         App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode;
GO

/****** Object:  View [Org].[vwContacts]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwContacts]
AS
	WITH ContactCount AS (SELECT        ContactName, COUNT(TaskCode) AS Tasks
                                                   FROM            Task.tbTask
                                                   WHERE        (TaskStatusCode < 2)
                                                   GROUP BY ContactName
                                                   HAVING         (ContactName IS NOT NULL))
    SELECT TOP (100) PERCENT   Org.tbContact.ContactName, Org.tbOrg.AccountCode, ContactCount_1.Tasks, Org.tbContact.PhoneNumber, Org.tbContact.HomeNumber, Org.tbContact.MobileNumber, Org.tbContact.FaxNumber, 
                              Org.tbContact.EmailAddress, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Org.tbStatus.OrganisationStatus, Org.tbContact.NameTitle, Org.tbContact.NickName, Org.tbContact.JobTitle, 
                              Org.tbContact.Department
     FROM            Org.tbOrg INNER JOIN
                              Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode INNER JOIN
                              Org.tbStatus ON Org.tbOrg.OrganisationStatusCode = Org.tbStatus.OrganisationStatusCode INNER JOIN
                              Org.tbContact ON Org.tbOrg.AccountCode = Org.tbContact.AccountCode LEFT OUTER JOIN
                              ContactCount AS ContactCount_1 ON Org.tbContact.ContactName = ContactCount_1.ContactName
     WHERE        (Org.tbOrg.OrganisationStatusCode < 3)
     ORDER BY Org.tbContact.ContactName;
GO

/****** Object:  View [App].[vwCorpTaxCashCode]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO


CREATE VIEW [App].[vwCorpTaxCashCode]
  AS
SELECT     CashCode, MonthNumber, RecurrenceCode
FROM         Cash.tbTaxType
WHERE     (TaxTypeCode = 0)
GO

/****** Object:  View [Invoice].[vwCreditNoteSpool]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwCreditNoteSpool]
AS
SELECT        credit_note.InvoiceNumber, credit_note.Printed, Invoice.tbType.InvoiceType, credit_note.InvoiceStatusCode, Usr.tbUser.UserName, credit_note.AccountCode, Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, 
                         credit_note.InvoicedOn, credit_note.InvoiceValue AS InvoiceValueTotal, credit_note.TaxValue AS TaxValueTotal, credit_note.PaymentTerms, credit_note.Notes, Org.tbOrg.EmailAddress, 
                         Org.tbAddress.Address AS InvoiceAddress, tbInvoiceTask.TaskCode, Task.tbTask.TaskTitle, Task.tbTask.ActionedOn, tbInvoiceTask.Quantity, Activity.tbActivity.UnitOfMeasure, tbInvoiceTask.TaxCode, 
                         tbInvoiceTask.InvoiceValue, tbInvoiceTask.TaxValue
FROM            Invoice.tbInvoice AS credit_note INNER JOIN
                         Invoice.tbStatus ON credit_note.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON credit_note.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON credit_note.UserId = Usr.tbUser.UserId LEFT OUTER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode INNER JOIN
                         Invoice.tbTask AS tbInvoiceTask ON credit_note.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
                         Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode INNER JOIN
                         Invoice.tbType ON credit_note.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE credit_note.InvoiceTypeCode = 1 
	AND EXISTS (SELECT * FROM App.tbDocSpool AS doc WHERE DocTypeCode = 5 AND UserName = SUSER_SNAME() AND credit_note.InvoiceNumber = doc.DocumentNumber);
GO

/****** Object:  View [Invoice].[vwDebitNoteSpool]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwDebitNoteSpool]
AS
SELECT        debit_note.Printed, debit_note.InvoiceNumber, Invoice.tbType.InvoiceType, debit_note.InvoiceStatusCode, Usr.tbUser.UserName, debit_note.AccountCode, Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, 
                         debit_note.InvoicedOn, debit_note.InvoiceValue AS InvoiceValueTotal, debit_note.TaxValue AS TaxValueTotal, debit_note.PaymentTerms, debit_note.Notes, Org.tbOrg.EmailAddress, 
                         Org.tbAddress.Address AS InvoiceAddress, tbInvoiceTask.TaskCode, Task.tbTask.TaskTitle, Task.tbTask.ActionedOn, tbInvoiceTask.Quantity, Activity.tbActivity.UnitOfMeasure, tbInvoiceTask.TaxCode, 
                         tbInvoiceTask.InvoiceValue, tbInvoiceTask.TaxValue
FROM            Invoice.tbInvoice AS debit_note INNER JOIN
                         Invoice.tbStatus ON debit_note.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON debit_note.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON debit_note.UserId = Usr.tbUser.UserId LEFT OUTER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode INNER JOIN
                         Invoice.tbTask AS tbInvoiceTask ON debit_note.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
                         Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode INNER JOIN
                         Invoice.tbType ON debit_note.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE debit_note.InvoiceTypeCode = 3 AND
	EXISTS (SELECT * FROM App.tbDocSpool AS doc WHERE DocTypeCode = 6 AND UserName = SUSER_SNAME() AND debit_note.InvoiceNumber = doc.DocumentNumber);
GO

/****** Object:  View [Activity].[vwDefaultText]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Activity].[vwDefaultText]
AS
SELECT TOP 100 PERCENT  DefaultText
FROM            Activity.tbAttribute
GROUP BY DefaultText
HAVING        (DefaultText IS NOT NULL)
ORDER BY DefaultText;
GO

/****** Object:  View [Org].[vwDepartments]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwDepartments]
AS
SELECT        Department
FROM            Org.tbContact
GROUP BY Department
HAVING        (Department IS NOT NULL);
GO

/****** Object:  View [Task].[vwDoc]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwDoc]
AS
SELECT     Task.fnEmailAddress(Task.tbTask.TaskCode) AS EmailAddress, Task.tbTask.TaskCode, Task.tbTask.TaskStatusCode, Task.tbStatus.TaskStatus, 
                      Task.tbTask.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, Org.tbAddress.Address AS InvoiceAddress, 
                      Org_tb1.AccountName AS DeliveryAccountName, Org_tbAddress1.Address AS DeliveryAddress, Org_tb2.AccountName AS CollectionAccountName, 
                      Org_tbAddress2.Address AS CollectionAddress, Task.tbTask.AccountCode, Task.tbTask.TaskNotes, Task.tbTask.ActivityCode, Task.tbTask.ActionOn, 
                      Activity.tbActivity.UnitOfMeasure, Task.tbTask.Quantity, App.tbTaxCode.TaxCode, App.tbTaxCode.TaxRate, Task.tbTask.UnitCharge, Task.tbTask.TotalCharge, 
                      Usr.tbUser.MobileNumber, Usr.tbUser.Signature, Task.tbTask.TaskTitle, Task.tbTask.PaymentOn, Task.tbTask.SecondReference, Org.tbOrg.PaymentTerms
FROM         Org.tbOrg AS Org_tb2 RIGHT OUTER JOIN
                      Org.tbAddress AS Org_tbAddress2 ON Org_tb2.AccountCode = Org_tbAddress2.AccountCode RIGHT OUTER JOIN
                      Task.tbStatus INNER JOIN
                      Usr.tbUser INNER JOIN
                      Activity.tbActivity INNER JOIN
                      Task.tbTask ON Activity.tbActivity.ActivityCode = Task.tbTask.ActivityCode INNER JOIN
                      Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                      Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode ON Usr.tbUser.UserId = Task.tbTask.ActionById ON 
                      Task.tbStatus.TaskStatusCode = Task.tbTask.TaskStatusCode LEFT OUTER JOIN
                      Org.tbAddress AS Org_tbAddress1 LEFT OUTER JOIN
                      Org.tbOrg AS Org_tb1 ON Org_tbAddress1.AccountCode = Org_tb1.AccountCode ON Task.tbTask.AddressCodeTo = Org_tbAddress1.AddressCode ON 
                      Org_tbAddress2.AddressCode = Task.tbTask.AddressCodeFrom LEFT OUTER JOIN
                      Org.tbContact ON Task.tbTask.ContactName = Org.tbContact.ContactName AND Task.tbTask.AccountCode = Org.tbContact.AccountCode LEFT OUTER JOIN
                      App.tbTaxCode ON Task.tbTask.TaxCode = App.tbTaxCode.TaxCode
GO

/****** Object:  View [Invoice].[vwDoc]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO


CREATE VIEW [Invoice].[vwDoc]
AS
SELECT     Org.tbOrg.EmailAddress, Usr.tbUser.UserName, Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbAddress.Address AS InvoiceAddress, 
                      Invoice.tbInvoice.InvoiceNumber, Invoice.tbType.InvoiceType, Invoice.tbStatus.InvoiceStatus, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.CollectOn, 
                      Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes
FROM         Invoice.tbInvoice INNER JOIN
                      Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                      Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId INNER JOIN
                      Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode LEFT OUTER JOIN
                      Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode
GO

/****** Object:  View [Usr].[vwDoc]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Usr].[vwDoc]
AS
WITH bank AS 
(
	SELECT TOP (1) App.fnCompanyAccount() AS AccountCode, CONCAT(Org.tbOrg.AccountName, SPACE(1), Org.tbAccount.CashAccountName) AS BankAccount, Org.tbAccount.SortCode AS BankSortCode , Org.tbAccount.AccountNumber AS BankAccountNumber
    FROM            Org.tbAccount INNER JOIN
                            Org.tbOrg ON Org.tbAccount.AccountCode = Org.tbOrg.AccountCode
    WHERE        NOT (Org.tbAccount.CashCode IS NULL)
)
SELECT        TOP (1) company.AccountName AS CompanyName, Org.tbAddress.Address AS CompanyAddress, company.PhoneNumber AS CompanyPhoneNumber, company.FaxNumber AS CompanyFaxNumber, 
                        company.EmailAddress AS CompanyEmailAddress, company.WebSite AS CompanyWebsite, company.CompanyNumber, company.VatNumber, company.Logo, bank_details.BankAccount, bank_details.BankAccountNumber, 
                        bank_details.BankSortCode
FROM            Org.tbOrg AS company INNER JOIN
                        App.tbOptions ON company.AccountCode = App.tbOptions.AccountCode LEFT OUTER JOIN
                        bank AS bank_details ON company.AccountCode = bank_details.AccountCode LEFT OUTER JOIN
                        Org.tbAddress ON company.AddressCode = Org.tbAddress.AddressCode;
GO

/****** Object:  View [App].[vwDocCreditNote]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [App].[vwDocCreditNote]
AS
SELECT        TOP (100) PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.Printed, Invoice.tbInvoice.Spooled, Invoice.tbInvoice.InvoiceStatusCode, Usr.tbUser.UserName, Invoice.tbInvoice.AccountCode, 
                         Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, 
                         Org.tbOrg.EmailAddress
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 1)
ORDER BY Invoice.tbInvoice.InvoiceNumber;
GO

/****** Object:  View [App].[vwDocDebitNote]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [App].[vwDocDebitNote]
AS
SELECT        TOP (100) PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.Printed, Invoice.tbInvoice.Spooled, Invoice.tbInvoice.InvoiceStatusCode, Usr.tbUser.UserName, Invoice.tbInvoice.AccountCode, 
                         Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, 
                         Org.tbOrg.EmailAddress
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 3)
ORDER BY Invoice.tbInvoice.InvoiceNumber;
GO

/****** Object:  View [Invoice].[vwDocItem]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwDocItem]
AS
SELECT     Invoice.tbItem.InvoiceNumber, Invoice.tbItem.CashCode, Cash.tbCode.CashDescription, Invoice.tbInvoice.InvoicedOn AS ActionedOn, 
                      Invoice.tbItem.TaxCode, Invoice.tbItem.InvoiceValue, Invoice.tbItem.TaxValue, Invoice.tbItem.ItemReference
FROM         Invoice.tbItem INNER JOIN
                      Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode INNER JOIN
                      Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
GO

/****** Object:  View [App].[vwDocOpenModes]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [App].[vwDocOpenModes]
AS
SELECT TOP 100 PERCENT OpenMode, OpenModeDescription
FROM            Usr.tbMenuOpenMode
WHERE        (OpenMode > 1)
ORDER BY OpenMode;
GO

/****** Object:  View [App].[vwDocSalesInvoice]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [App].[vwDocSalesInvoice]
AS
SELECT        TOP (100) PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.Printed, Invoice.tbInvoice.Spooled, Invoice.tbInvoice.InvoiceStatusCode, Usr.tbUser.UserName, Invoice.tbInvoice.AccountCode, 
                         Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, Invoice.tbInvoice.Notes, 
                         Org.tbOrg.EmailAddress
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Usr.tbUser ON Invoice.tbInvoice.UserId = Usr.tbUser.UserId
WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 0)
ORDER BY Invoice.tbInvoice.InvoiceNumber;
GO

/****** Object:  View [App].[vwDocSpool]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [App].[vwDocSpool]
 AS
SELECT     DocTypeCode, DocumentNumber
FROM         App.tbDocSpool
WHERE     (UserName = SUSER_SNAME())
GO

/****** Object:  View [Invoice].[vwDocTask]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwDocTask]
AS
SELECT        tbTaskInvoice.InvoiceNumber, tbTaskInvoice.TaskCode, Task.tbTask.TaskTitle, Task.tbTask.ActivityCode, tbTaskInvoice.CashCode, Cash.tbCode.CashDescription, Task.tbTask.ActionedOn, tbTaskInvoice.Quantity, 
                         Activity.tbActivity.UnitOfMeasure, tbTaskInvoice.InvoiceValue, tbTaskInvoice.TaxValue, tbTaskInvoice.TaxCode, Task.tbTask.SecondReference
FROM            Invoice.tbTask AS tbTaskInvoice INNER JOIN
                         Task.tbTask ON tbTaskInvoice.TaskCode = Task.tbTask.TaskCode AND tbTaskInvoice.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Cash.tbCode ON tbTaskInvoice.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode
GO

/****** Object:  View [Task].[vwEdit]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwEdit]
AS
SELECT        Task.tbTask.TaskCode, Task.tbTask.UserId, Task.tbTask.AccountCode, Task.tbTask.TaskTitle, Task.tbTask.ContactName, Task.tbTask.ActivityCode, Task.tbTask.TaskStatusCode, Task.tbTask.ActionById, 
                         Task.tbTask.ActionOn, Task.tbTask.ActionedOn, Task.tbTask.TaskNotes, Task.tbTask.Quantity, Task.tbTask.CashCode, Task.tbTask.TaxCode, Task.tbTask.UnitCharge, Task.tbTask.TotalCharge, 
                         Task.tbTask.AddressCodeFrom, Task.tbTask.AddressCodeTo, Task.tbTask.Printed, Task.tbTask.InsertedBy, Task.tbTask.InsertedOn, Task.tbTask.UpdatedBy, Task.tbTask.UpdatedOn, Task.tbTask.PaymentOn, 
                         Task.tbTask.SecondReference, Task.tbTask.Spooled, Activity.tbActivity.UnitOfMeasure, Task.tbStatus.TaskStatus
FROM            Task.tbTask INNER JOIN
                         Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode INNER JOIN
                         Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode;



GO

/****** Object:  View [Cash].[vwExternalCodesLookup]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwExternalCodesLookup]
AS
SELECT        Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCategory.Category
FROM            Cash.tbCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
WHERE        (Cash.tbCategory.CashTypeCode = 1);
GO

/****** Object:  View [Task].[vwFlow]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwFlow]
AS
SELECT        Task.tbFlow.ParentTaskCode, Task.tbFlow.StepNumber, Task.tbTask.TaskCode, Task.tbTask.ActivityCode, Task.tbTask.TaskTitle, Task.tbTask.TaskNotes, Task.tbStatus.TaskStatus, Task.tbTask.ActionOn, 
                         Task.tbTask.Quantity, Task.tbTask.ActionedOn, Org.tbOrg.AccountCode, Usr.tbUser.UserName AS Owner, tbUser_1.UserName AS ActionBy, Org.tbOrg.AccountName, Task.tbTask.UnitCharge, 
                         Task.tbTask.TotalCharge, Task.tbTask.InsertedBy, Task.tbTask.InsertedOn, Task.tbTask.UpdatedBy, Task.tbTask.UpdatedOn, Task.tbTask.TaskStatusCode
FROM            Usr.tbUser AS tbUser_1 INNER JOIN
                         Task.tbTask INNER JOIN
                         Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
                         Usr.tbUser ON Task.tbTask.UserId = Usr.tbUser.UserId INNER JOIN
                         Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode ON tbUser_1.UserId = Task.tbTask.ActionById INNER JOIN
                         Task.tbFlow ON Task.tbTask.TaskCode = Task.tbFlow.ChildTaskCode;
GO

/****** Object:  View [Cash].[vwFlowNITotals]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwFlowNITotals]
AS
SELECT        Cash.tbPeriod.StartOn, SUM(Cash.tbPeriod.ForecastTax) AS ForecastNI, SUM(Cash.tbPeriod.InvoiceTax) AS InvoiceNI
FROM            Cash.tbPeriod INNER JOIN
                         Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode INNER JOIN
                         App.tbTaxCode ON Cash.tbCode.TaxCode = App.tbTaxCode.TaxCode
WHERE        (App.tbTaxCode.TaxTypeCode = 2)
GROUP BY Cash.tbPeriod.StartOn
GO

/****** Object:  View [App].[vwGraphTaskActivity]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [App].[vwGraphTaskActivity]
AS
SELECT        CONCAT(Task.tbStatus.TaskStatus, SPACE(1), Cash.tbMode.CashMode) AS Category, SUM(Task.tbTask.TotalCharge) AS SumOfTotalCharge
FROM            Task.tbTask INNER JOIN
                         Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
                         Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
                         Cash.tbMode ON Cash.tbCategory.CashModeCode = Cash.tbMode.CashModeCode
WHERE        (Task.tbTask.TaskStatusCode < 3) AND (Task.tbTask.TaskStatusCode > 0)
GROUP BY CONCAT(Task.tbStatus.TaskStatus, SPACE(1), Cash.tbMode.CashMode);
GO

/****** Object:  View [Org].[vwInvoiceItems]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwInvoiceItems]
AS
SELECT        Invoice.tbInvoice.AccountCode, Invoice.tbItem.InvoiceNumber, Invoice.tbItem.CashCode, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbStatus.InvoiceStatus, 
                         Cash.tbCode.CashDescription, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbType.InvoiceType, Invoice.tbItem.TaxCode, Invoice.tbItem.TaxValue, 
                         Invoice.tbItem.InvoiceValue, Invoice.tbItem.PaidValue, Invoice.tbItem.PaidTaxValue, Invoice.tbItem.ItemReference
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Invoice.tbItem ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbItem.InvoiceNumber INNER JOIN
                         Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode
WHERE        (Invoice.tbInvoice.InvoiceStatusCode > 0);
GO

/****** Object:  View [Invoice].[vwItems]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwItems]
AS
SELECT        Invoice.tbItem.InvoiceNumber, Invoice.tbItem.CashCode, Cash.tbCode.CashDescription, Invoice.tbItem.TaxCode, Invoice.tbItem.TaxValue, Invoice.tbItem.InvoiceValue, Invoice.tbItem.ItemReference, 
                         Invoice.tbInvoice.InvoicedOn
FROM            Invoice.tbItem INNER JOIN
                         Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
                         Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode;
GO

/****** Object:  View [Org].[vwJobTitles]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwJobTitles]
AS
SELECT        JobTitle
FROM            Org.tbContact
GROUP BY JobTitle
HAVING        (JobTitle IS NOT NULL);
GO

/****** Object:  View [Org].[vwListActive]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO


CREATE VIEW [Org].[vwListActive]
AS
	SELECT        TOP (100) PERCENT Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbType.CashModeCode
	FROM            Org.tbOrg INNER JOIN
							 Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode INNER JOIN
							 Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode
	WHERE        (Task.tbTask.TaskStatusCode = 1 OR
							 Task.tbTask.TaskStatusCode = 2) AND (Task.tbTask.CashCode IS NOT NULL)
	GROUP BY Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbType.CashModeCode
	ORDER BY Org.tbOrg.AccountName;
GO

/****** Object:  View [Org].[vwListAll]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwListAll]
AS
	SELECT TOP (100) PERCENT Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbType.CashModeCode
	FROM Org.tbOrg INNER JOIN Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode
	ORDER BY Org.tbOrg.AccountName;
GO

/****** Object:  View [Usr].[vwMenuItemFormMode]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Usr].[vwMenuItemFormMode]
AS
	SELECT        OpenMode, OpenModeDescription
	FROM            Usr.tbMenuOpenMode
	WHERE        (OpenMode < 2);
GO

/****** Object:  View [Usr].[vwMenuItemReportMode]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Usr].[vwMenuItemReportMode]
AS
	SELECT        OpenMode, OpenModeDescription
	FROM            Usr.tbMenuOpenMode
	WHERE        (OpenMode > 1) AND (OpenMode < 5);
GO

/****** Object:  View [Cash].[vwMonthList]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwMonthList]
  AS
SELECT DISTINCT 
                      TOP 100 PERCENT CAST(App.tbYearPeriod.StartOn AS float) AS StartOn, App.tbMonth.MonthName, 
                      App.tbYearPeriod.MonthNumber
FROM         App.tbYearPeriod INNER JOIN
                      App.fnActivePeriod() AS fnSystemActivePeriod ON App.tbYearPeriod.YearNumber = fnSystemActivePeriod.YearNumber INNER JOIN
                      App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
ORDER BY StartOn
GO

/****** Object:  View [Org].[vwNameTitles]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwNameTitles]
AS
SELECT        NameTitle
FROM            Org.tbContact
GROUP BY NameTitle
HAVING        (NameTitle IS NOT NULL);
GO

/****** Object:  View [App].[vwNICashCode]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [App].[vwNICashCode]
  AS
SELECT     CashCode, MonthNumber, RecurrenceCode
FROM         Cash.tbTaxType
WHERE     (TaxTypeCode = 2)
GO

/****** Object:  View [Cash].[vwNominalEntryData]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwNominalEntryData]
AS
SELECT TOP 100 PERCENT Cash.tbCode.CashCode, Cash.tbPeriod.StartOn, Cash.tbCode.CashDescription, Cash.tbCode.CategoryCode, Cash.tbMode.CashMode, Cash.tbType.CashType, App.tbTaxCode.TaxRate,  
                         Cash.tbPeriod.ForecastValue, Cash.tbPeriod.ForecastTax, Cash.tbPeriod.Note, Cash.tbMode.CashModeCode, Cash.tbPeriod.InvoiceValue, Cash.tbPeriod.InvoiceTax
FROM            Cash.tbType INNER JOIN
                         Cash.tbMode INNER JOIN
                         Cash.tbPeriod INNER JOIN
                         Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode ON Cash.tbMode.CashModeCode = Cash.tbCategory.CashModeCode ON 
                         Cash.tbType.CashTypeCode = Cash.tbCategory.CashTypeCode INNER JOIN
                         App.tbTaxCode ON Cash.tbCode.TaxCode = App.tbTaxCode.TaxCode
ORDER BY Cash.tbCode.CashCode;
GO

/****** Object:  View [Cash].[vwNominalForecastData]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwNominalForecastData]
AS
SELECT TOP 100 PERCENT Cash.tbPeriod.CashCode, Cash.tbPeriod.StartOn, App.tbYearPeriod.YearNumber, App.tbMonth.MonthName, Cash.tbPeriod.ForecastValue, Cash.tbPeriod.ForecastTax, Cash.tbPeriod.Note, 
                         Cash.tbCategory.CashModeCode, App.tbTaxCode.TaxRate
FROM            App.tbYearPeriod INNER JOIN
                         Cash.tbPeriod ON App.tbYearPeriod.StartOn = Cash.tbPeriod.StartOn INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                         Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
                         App.tbTaxCode ON Cash.tbCode.TaxCode = App.tbTaxCode.TaxCode
ORDER BY Cash.tbPeriod.StartOn;
GO

/****** Object:  View [Cash].[vwNominalForecastProjection]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwNominalForecastProjection]
AS
SELECT TOP 100 PERCENT Cash.tbCode.CashCode, Cash.tbPeriod.StartOn, App.tbYearPeriod.YearNumber, Cash.tbCode.CategoryCode, Cash.tbCode.CashDescription, Format(App.tbYearPeriod.StartOn, 'yy-MM') AS Period, 
                         Cash.tbPeriod.ForecastValue AS Value
FROM            Cash.tbPeriod INNER JOIN
                         Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode INNER JOIN
                         App.tbYearPeriod ON Cash.tbPeriod.StartOn = App.tbYearPeriod.StartOn
ORDER BY Cash.tbPeriod.StartOn;
GO

/****** Object:  View [Cash].[vwNominalInvoiceData]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwNominalInvoiceData]
AS
SELECT TOP 100 PERCENT Cash.tbPeriod.CashCode, Cash.tbPeriod.StartOn, App.tbYearPeriod.YearNumber, App.tbMonth.MonthName, Cash.tbPeriod.Note, Cash.tbCategory.CashModeCode, App.tbTaxCode.TaxRate, 
                         Cash.tbPeriod.InvoiceValue, Cash.tbPeriod.InvoiceTax
FROM            App.tbYearPeriod INNER JOIN
                         Cash.tbPeriod ON App.tbYearPeriod.StartOn = Cash.tbPeriod.StartOn INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                         Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
                         App.tbTaxCode ON Cash.tbCode.TaxCode = App.tbTaxCode.TaxCode
ORDER BY Cash.tbPeriod.StartOn;
GO

/****** Object:  View [Org].[vwPayments]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwPayments]
AS
SELECT        Org.tbPayment.AccountCode, Org.tbPayment.PaymentCode, Org.tbPayment.UserId, Org.tbPayment.PaymentStatusCode, Org.tbPayment.CashAccountCode, Org.tbPayment.CashCode, Org.tbPayment.TaxCode, 
                         Org.tbPayment.PaidOn, Org.tbPayment.PaidInValue, Org.tbPayment.PaidOutValue, Org.tbPayment.TaxInValue, Org.tbPayment.TaxOutValue, Org.tbPayment.PaymentReference, Org.tbPayment.InsertedBy, 
                         Org.tbPayment.InsertedOn, Org.tbPayment.UpdatedBy, Org.tbPayment.UpdatedOn, Usr.tbUser.UserName, App.tbTaxCode.TaxDescription, Org.tbAccount.CashAccountName, Cash.tbCode.CashDescription
FROM            Org.tbPayment INNER JOIN
                         Usr.tbUser ON Org.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
                         Org.tbAccount ON Org.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
                         Cash.tbCode ON Org.tbPayment.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
                         App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode
WHERE        (Org.tbPayment.PaymentStatusCode = 1);
GO

/****** Object:  View [Org].[vwPaymentsListing]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwPaymentsListing]
AS
SELECT        TOP (100) PERCENT Org.tbOrg.AccountCode, Org.tbOrg.AccountName, Org.tbType.OrganisationType, Org.tbStatus.OrganisationStatus, Org.tbPayment.PaymentCode, Usr.tbUser.UserName, 
                         App.tbTaxCode.TaxDescription AS PaymentTaxDescription, Org.tbAccount.CashAccountName, Cash.tbCode.CashDescription, Org.tbPayment.UserId, Org.tbPayment.CashAccountCode, Org.tbPayment.CashCode, 
                         Org.tbPayment.TaxCode, CONCAT(YEAR(Org.tbPayment.PaidOn), Format(MONTH(Org.tbPayment.PaidOn), '00')) AS Period, Org.tbPayment.PaidOn, Org.tbPayment.PaidInValue, Org.tbPayment.PaidOutValue, 
                         Org.tbPayment.TaxInValue, Org.tbPayment.TaxOutValue, Org.tbPayment.InsertedBy, Org.tbPayment.InsertedOn, Org.tbPayment.UpdatedBy, Org.tbPayment.UpdatedOn, Org.tbPayment.PaymentReference
FROM            Org.tbPayment INNER JOIN
                         Usr.tbUser ON Org.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
                         Org.tbAccount ON Org.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
                         Cash.tbCode ON Org.tbPayment.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
                         App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
                         Org.tbOrg ON Org.tbPayment.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Org.tbType ON Org.tbOrg.OrganisationTypeCode = Org.tbType.OrganisationTypeCode INNER JOIN
                         Org.tbStatus ON Org.tbOrg.OrganisationStatusCode = Org.tbStatus.OrganisationStatusCode
WHERE        (Org.tbPayment.PaymentStatusCode = 1) 
ORDER BY Org.tbPayment.AccountCode, Org.tbPayment.PaidOn DESC;
GO

/****** Object:  View [Org].[vwPaymentsUnposted]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwPaymentsUnposted]
AS
SELECT        PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, TaxInValue, TaxOutValue, PaymentReference, InsertedBy, InsertedOn, 
                         UpdatedBy, UpdatedOn
FROM            Org.tbPayment
WHERE        (PaymentStatusCode = 0);
GO

/****** Object:  View [Org].[vwPaymentTerms]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwPaymentTerms]
AS
SELECT        PaymentTerms
FROM            Org.tbOrg
GROUP BY PaymentTerms
HAVING         LEN(ISNULL(PaymentTerms, '')) > 0;
GO

/****** Object:  View [App].[vwPeriodEndListing]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [App].[vwPeriodEndListing]
AS
SELECT        TOP (100) PERCENT App.tbYear.YearNumber, App.tbYear.Description, App.tbYear.InsertedBy AS YearInsertedBy, App.tbYear.InsertedOn AS YearInsertedOn, App.tbYearPeriod.StartOn, App.tbMonth.MonthName, 
                         App.tbYearPeriod.InsertedBy AS PeriodInsertedBy, App.tbYearPeriod.InsertedOn AS PeriodInsertedOn, Cash.tbStatus.CashStatus
FROM            Cash.tbStatus INNER JOIN
                         App.tbYear INNER JOIN
                         App.tbYearPeriod ON App.tbYear.YearNumber = App.tbYearPeriod.YearNumber INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber ON Cash.tbStatus.CashStatusCode = App.tbYearPeriod.CashStatusCode
ORDER BY App.tbYearPeriod.StartOn;
GO

/****** Object:  View [Cash].[vwPeriods]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwPeriods]
   AS
SELECT     Cash.tbCode.CashCode, App.tbYearPeriod.StartOn
FROM         App.tbYearPeriod CROSS JOIN
                      Cash.tbCode
GO

/****** Object:  View [Task].[vwProfit]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwProfit]
AS
SELECT     TOP (100) PERCENT fnTaskProfit_1.StartOn, Org.tbOrg.AccountCode, Task.tbTask.TaskCode, App.tbYearPeriod.YearNumber, App.tbYear.Description, 
                      App.tbMonth.MonthName + ' ' + LTRIM(STR(YEAR(App.tbYearPeriod.StartOn))) AS Period, Task.tbTask.ActivityCode, Cash.tbCode.CashCode, 
                      Task.tbTask.TaskTitle, Org.tbOrg.AccountName, Cash.tbCode.CashDescription, Task.tbStatus.TaskStatus, fnTaskProfit_1.TotalCharge, 
                      fnTaskProfit_1.InvoicedCharge, fnTaskProfit_1.InvoicedChargePaid, fnTaskProfit_1.TotalCost, fnTaskProfit_1.InvoicedCost, fnTaskProfit_1.InvoicedCostPaid, 
                      fnTaskProfit_1.TotalCharge - fnTaskProfit_1.TotalCost AS Profit, fnTaskProfit_1.TotalCharge - fnTaskProfit_1.InvoicedCharge AS UninvoicedCharge, 
                      fnTaskProfit_1.InvoicedCharge - fnTaskProfit_1.InvoicedChargePaid AS UnpaidCharge, fnTaskProfit_1.TotalCost - fnTaskProfit_1.InvoicedCost AS UninvoicedCost, 
                      fnTaskProfit_1.InvoicedCost - fnTaskProfit_1.InvoicedCostPaid AS UnpaidCost, Task.tbTask.ActionOn, Task.tbTask.ActionedOn, Task.tbTask.PaymentOn
FROM         Task.tbTask INNER JOIN
                      Task.fnProfit() AS fnTaskProfit_1 ON Task.tbTask.TaskCode = fnTaskProfit_1.TaskCode INNER JOIN
                      Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
                      Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                      Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
                      App.tbYearPeriod ON fnTaskProfit_1.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                      App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
                      App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
WHERE     (Cash.tbCategory.CashModeCode = 1)
ORDER BY fnTaskProfit_1.StartOn

GO

/****** Object:  View [Task].[vwProfitOrders]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO


CREATE VIEW [Task].[vwProfitOrders]
AS
SELECT     App.fnAccountPeriod(Task.tbTask.ActionOn) AS StartOn, Task.tbTask.TaskCode, 
                      CASE WHEN Cash.tbCategory.CashModeCode = 0 THEN Task.tbTask.TotalCharge * - 1 ELSE Task.tbTask.TotalCharge END AS TotalCharge
FROM         Cash.tbCode INNER JOIN
                      Task.tbTask ON Cash.tbCode.CashCode = Task.tbTask.CashCode INNER JOIN
                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode LEFT OUTER JOIN
                      Task.tbTask AS Task_tb1 RIGHT OUTER JOIN
                      Task.tbFlow ON Task_tb1.TaskCode = Task.tbFlow.ParentTaskCode ON Task.tbTask.TaskCode = Task.tbFlow.ChildTaskCode
WHERE     (Task.tbTask.TaskStatusCode > 0) AND (Task.tbFlow.ParentTaskCode IS NULL) AND ( Task_tb1.CashCode IS NULL) AND (Task.tbTask.TaskStatusCode < 4) AND 
                      (Task.tbTask.ActionOn >= App.fnHistoryStartOn()) OR
                      (Task.tbTask.TaskStatusCode > 0) AND ( Task_tb1.CashCode IS NULL) AND (Task.tbTask.TaskStatusCode < 4) AND (Task.tbTask.ActionOn >= App.fnHistoryStartOn())

GO

/****** Object:  View [Task].[vwProfitToDate]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwProfitToDate]
AS
	WITH TaskProfitToDate AS 
		(SELECT        MAX(PaymentOn) AS LastPaymentOn
		 FROM            Task.tbTask)
	SELECT TOP (100) PERCENT App.tbYearPeriod.StartOn, App.tbYear.Description + SPACE(1) + App.tbMonth.MonthName AS Description
	FROM            TaskProfitToDate INNER JOIN
							App.tbYearPeriod INNER JOIN
							App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
							App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber ON DATEADD(m, 1, TaskProfitToDate.LastPaymentOn) > App.tbYearPeriod.StartOn
	WHERE        (App.tbYear.CashStatusCode < 3)
	ORDER BY App.tbYearPeriod.StartOn DESC;
GO

/****** Object:  View [Task].[vwPurchaseEnquiryDeliverySpool]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwPurchaseEnquiryDeliverySpool]
AS
SELECT        purchase_enquiry.TaskCode, purchase_enquiry.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, Org.tbAddress.Address AS InvoiceAddress, 
                         collection_account.AccountName AS CollectAccount, collection_address.Address AS CollectAddress, delivery_account.AccountName AS DeliveryAccount, delivery_address.Address AS DeliveryAddress, 
                         purchase_enquiry.AccountCode, purchase_enquiry.TaskNotes, purchase_enquiry.ActivityCode, purchase_enquiry.ActionOn, Activity.tbActivity.UnitOfMeasure, purchase_enquiry.Quantity, App.tbTaxCode.TaxCode, 
                         App.tbTaxCode.TaxRate, purchase_enquiry.UnitCharge, purchase_enquiry.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature, purchase_enquiry.TaskTitle
FROM            Org.tbOrg AS delivery_account INNER JOIN
                         Org.tbOrg AS collection_account INNER JOIN
                         Usr.tbUser INNER JOIN
                         Activity.tbActivity INNER JOIN
                         Task.tbTask AS purchase_enquiry ON Activity.tbActivity.ActivityCode = purchase_enquiry.ActivityCode INNER JOIN
                         Org.tbOrg ON purchase_enquiry.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode ON Usr.tbUser.UserId = purchase_enquiry.ActionById INNER JOIN
                         Org.tbAddress AS delivery_address ON purchase_enquiry.AddressCodeTo = delivery_address.AddressCode LEFT OUTER JOIN
                         App.tbTaxCode ON purchase_enquiry.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                         Org.tbContact ON purchase_enquiry.ContactName = Org.tbContact.ContactName AND purchase_enquiry.AccountCode = Org.tbContact.AccountCode INNER JOIN
                         Org.tbAddress AS collection_address ON purchase_enquiry.AddressCodeFrom = collection_address.AddressCode ON collection_account.AccountCode = collection_address.AccountCode ON 
                         delivery_account.AccountCode = delivery_address.AccountCode
WHERE EXISTS (SELECT * FROM App.tbDocSpool AS doc WHERE DocTypeCode = 2 AND UserName = SUSER_SNAME() AND purchase_enquiry.TaskCode = doc.DocumentNumber);
GO

/****** Object:  View [Task].[vwPurchaseEnquirySpool]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwPurchaseEnquirySpool]
AS
SELECT        purchase_enquiry.TaskCode, purchase_enquiry.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, Org.tbAddress.Address AS InvoiceAddress, 
                         Org_tbAddress_1.Address AS DeliveryAddress, purchase_enquiry.AccountCode, purchase_enquiry.TaskNotes, purchase_enquiry.ActivityCode, purchase_enquiry.ActionOn, Activity.tbActivity.UnitOfMeasure, 
                         purchase_enquiry.Quantity, App.tbTaxCode.TaxCode, App.tbTaxCode.TaxRate, purchase_enquiry.UnitCharge, purchase_enquiry.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature, 
                         purchase_enquiry.TaskTitle
FROM            Usr.tbUser INNER JOIN
                         Activity.tbActivity INNER JOIN
                         Task.tbTask AS purchase_enquiry ON Activity.tbActivity.ActivityCode = purchase_enquiry.ActivityCode INNER JOIN
                         Org.tbOrg ON purchase_enquiry.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Org.tbAddress ON Org.tbOrg.AddressCode = Org.tbAddress.AddressCode ON Usr.tbUser.UserId = purchase_enquiry.ActionById LEFT OUTER JOIN
                         Org.tbAddress AS Org_tbAddress_1 ON purchase_enquiry.AddressCodeTo = Org_tbAddress_1.AddressCode LEFT OUTER JOIN
                         App.tbTaxCode ON purchase_enquiry.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                         Org.tbContact ON purchase_enquiry.AccountCode = Org.tbContact.AccountCode AND purchase_enquiry.ContactName = Org.tbContact.ContactName
WHERE EXISTS (SELECT * FROM App.tbDocSpool AS doc WHERE DocTypeCode = 2 AND UserName = SUSER_SNAME() AND purchase_enquiry.TaskCode = doc.DocumentNumber);
GO

/****** Object:  View [Org].[vwPurchaseInvoices]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwPurchaseInvoices]
AS
SELECT        Invoice.tbInvoice.AccountCode, tbInvoiceTask.InvoiceNumber, tbInvoiceTask.TaskCode, Task.tbTask.ContactName, Invoice.tbInvoice.InvoicedOn, tbInvoiceTask.Quantity, tbInvoiceTask.InvoiceValue, 
                         tbInvoiceTask.TaxValue, tbInvoiceTask.CashCode, tbInvoiceTask.TaxCode, Invoice.tbStatus.InvoiceStatus, Task.tbTask.TaskNotes, Cash.tbCode.CashDescription, Invoice.tbInvoice.InvoiceStatusCode, 
                         Task.tbTask.TaskTitle, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbType.InvoiceType
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbTask AS tbInvoiceTask ON Invoice.tbInvoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
                         Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Cash.tbCode ON tbInvoiceTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE        (Invoice.tbInvoice.InvoiceStatusCode > 0) AND (Invoice.tbInvoice.InvoiceTypeCode > 1);
GO

/****** Object:  View [Task].[vwPurchaseOrderDeliverySpool]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwPurchaseOrderDeliverySpool]
AS
SELECT        purchase_order.TaskCode, purchase_order.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, invoice_address.Address AS InvoiceAddress, 
                         delivery_account.AccountName AS CollectAccount, delivery_address.Address AS CollectAddress, collection_account.AccountName AS DeliveryAccount, collection_address.Address AS DeliveryAddress, 
                         purchase_order.AccountCode, purchase_order.TaskNotes, purchase_order.ActivityCode, purchase_order.ActionOn, Activity.tbActivity.UnitOfMeasure, purchase_order.Quantity, App.tbTaxCode.TaxCode, 
                         App.tbTaxCode.TaxRate, purchase_order.UnitCharge, purchase_order.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature, purchase_order.TaskTitle
FROM            Org.tbOrg AS collection_account INNER JOIN
                         Org.tbOrg AS delivery_account INNER JOIN
                         Usr.tbUser INNER JOIN
                         Activity.tbActivity INNER JOIN
                         Task.tbTask AS purchase_order ON Activity.tbActivity.ActivityCode = purchase_order.ActivityCode INNER JOIN
                         Org.tbOrg ON purchase_order.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Org.tbAddress AS invoice_address ON Org.tbOrg.AddressCode = invoice_address.AddressCode ON Usr.tbUser.UserId = purchase_order.ActionById INNER JOIN
                         Org.tbAddress AS collection_address ON purchase_order.AddressCodeTo = collection_address.AddressCode LEFT OUTER JOIN
                         App.tbTaxCode ON purchase_order.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                         Org.tbContact ON purchase_order.ContactName = Org.tbContact.ContactName AND purchase_order.AccountCode = Org.tbContact.AccountCode INNER JOIN
                         Org.tbAddress AS delivery_address ON purchase_order.AddressCodeFrom = delivery_address.AddressCode ON delivery_account.AccountCode = delivery_address.AccountCode ON 
                         collection_account.AccountCode = collection_address.AccountCode
WHERE EXISTS (
	SELECT        UserName, DocTypeCode, DocumentNumber, SpooledOn
    FROM            App.tbDocSpool AS doc
    WHERE        (DocTypeCode = 3) AND (UserName = SUSER_SNAME()) AND (purchase_order.TaskCode = DocumentNumber));
GO

/****** Object:  View [Task].[vwPurchaseOrderSpool]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwPurchaseOrderSpool]
AS
SELECT        purchase_order.TaskCode, purchase_order.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, invoice_address.Address AS InvoiceAddress, 
                         delivery_address.Address AS DeliveryAddress, purchase_order.AccountCode, purchase_order.TaskNotes, purchase_order.ActivityCode, purchase_order.ActionOn, Activity.tbActivity.UnitOfMeasure, 
                         purchase_order.Quantity, App.tbTaxCode.TaxCode, App.tbTaxCode.TaxRate, purchase_order.UnitCharge, purchase_order.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature, 
                         purchase_order.TaskTitle
FROM            Usr.tbUser INNER JOIN
                         Activity.tbActivity INNER JOIN
                         Task.tbTask AS purchase_order ON Activity.tbActivity.ActivityCode = purchase_order.ActivityCode INNER JOIN
                         Org.tbOrg ON purchase_order.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Org.tbAddress AS invoice_address ON Org.tbOrg.AddressCode = invoice_address.AddressCode ON Usr.tbUser.UserId = purchase_order.ActionById LEFT OUTER JOIN
                         Org.tbAddress AS delivery_address ON purchase_order.AddressCodeTo = delivery_address.AddressCode LEFT OUTER JOIN
                         App.tbTaxCode ON purchase_order.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                         Org.tbContact ON purchase_order.AccountCode = Org.tbContact.AccountCode AND purchase_order.ContactName = Org.tbContact.ContactName
WHERE EXISTS (SELECT * FROM App.tbDocSpool AS doc WHERE DocTypeCode = 3 AND UserName = SUSER_SNAME() AND purchase_order.TaskCode = doc.DocumentNumber);
GO

/****** Object:  View [Task].[vwQuotationSpool]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwQuotationSpool]
AS
SELECT        sales_order.TaskCode, sales_order.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, invoice_address.Address AS InvoiceAddress, 
                         delivery_address.Address AS DeliveryAddress, sales_order.AccountCode, sales_order.TaskNotes, sales_order.ActivityCode, sales_order.ActionOn, Activity.tbActivity.UnitOfMeasure, sales_order.Quantity, 
                         App.tbTaxCode.TaxCode, App.tbTaxCode.TaxRate, sales_order.UnitCharge, sales_order.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature, sales_order.TaskTitle
FROM            Usr.tbUser INNER JOIN
                         Activity.tbActivity INNER JOIN
                         Task.tbTask AS sales_order ON Activity.tbActivity.ActivityCode = sales_order.ActivityCode INNER JOIN
                         Org.tbOrg ON sales_order.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Org.tbAddress AS invoice_address ON Org.tbOrg.AddressCode = invoice_address.AddressCode ON Usr.tbUser.UserId = sales_order.ActionById LEFT OUTER JOIN
                         Org.tbAddress AS delivery_address ON sales_order.AddressCodeTo = delivery_address.AddressCode LEFT OUTER JOIN
                         App.tbTaxCode ON sales_order.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                         Org.tbContact ON sales_order.AccountCode = Org.tbContact.AccountCode AND sales_order.ContactName = Org.tbContact.ContactName
WHERE EXISTS (
	SELECT        UserName, DocTypeCode, DocumentNumber, SpooledOn
    FROM            App.tbDocSpool AS doc
    WHERE        (DocTypeCode = 0) AND (UserName = SUSER_SNAME()) AND (sales_order.TaskCode = DocumentNumber));
GO

/****** Object:  View [Invoice].[vwRegisterPurchasesOverdue]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwRegisterPurchasesOverdue]
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
                         Invoice.tbType.InvoiceType, (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) AS UnpaidValue, 
						DATEDIFF(DD, CURRENT_TIMESTAMP, Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.CollectOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, 
                         Invoice.tbInvoice.Notes
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
WHERE        (Invoice.tbInvoice.InvoiceTypeCode > 1) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
ORDER BY Invoice.tbInvoice.CollectOn;
GO

/****** Object:  View [Invoice].[vwRegisterSalesOverdue]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwRegisterSalesOverdue]
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
                         Invoice.tbType.InvoiceType, (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) AS UnpaidValue, DATEDIFF(DD, CURRENT_TIMESTAMP, 
                         Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.CollectOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, 
                         Invoice.tbInvoice.Notes
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
WHERE        (Invoice.tbInvoice.InvoiceTypeCode < 2) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
ORDER BY Invoice.tbInvoice.CollectOn;
GO

/****** Object:  View [Org].[vwSalesInvoices]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwSalesInvoices]
AS
SELECT        Invoice.tbInvoice.AccountCode, tbInvoiceTask.InvoiceNumber, tbInvoiceTask.TaskCode, Task.tbTask.ContactName, Invoice.tbInvoice.InvoicedOn, tbInvoiceTask.Quantity, tbInvoiceTask.InvoiceValue, 
                         tbInvoiceTask.TaxValue, tbInvoiceTask.CashCode, tbInvoiceTask.TaxCode, Invoice.tbStatus.InvoiceStatus, Task.tbTask.TaskNotes, Cash.tbCode.CashDescription, Invoice.tbInvoice.InvoiceStatusCode, 
                         Task.tbTask.TaskTitle, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbType.InvoiceType, tbInvoiceTask.PaidValue, tbInvoiceTask.PaidTaxValue
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbTask AS tbInvoiceTask ON Invoice.tbInvoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
                         Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Cash.tbCode ON tbInvoiceTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE        (Invoice.tbInvoice.InvoiceStatusCode > 1) AND (Invoice.tbInvoice.InvoiceTypeCode < 1);
GO

/****** Object:  View [Invoice].[vwSalesInvoiceSpool]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwSalesInvoiceSpool]
AS
SELECT        sales_invoice.InvoiceNumber, Invoice.tbType.InvoiceType, sales_invoice.InvoiceStatusCode, Usr.tbUser.UserName, sales_invoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbStatus.InvoiceStatus, 
                         sales_invoice.InvoicedOn, sales_invoice.InvoiceValue AS InvoiceValueTotal, sales_invoice.TaxValue AS TaxValueTotal, sales_invoice.PaymentTerms, sales_invoice.CollectOn, sales_invoice.Notes, 
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

/****** Object:  View [Invoice].[vwSalesInvoiceSpoolByActivity]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Invoice].[vwSalesInvoiceSpoolByActivity]
AS
WITH invoice AS 
(
	SELECT        sales_invoice.InvoiceNumber, Invoice.tbType.InvoiceType, sales_invoice.InvoiceStatusCode, Usr.tbUser.UserName, sales_invoice.AccountCode, Org.tbOrg.AccountName, 
							Invoice.tbStatus.InvoiceStatus, sales_invoice.InvoicedOn, sales_invoice.InvoiceValue AS InvoiceValueTotal, sales_invoice.TaxValue AS TaxValueTotal, sales_invoice.PaymentTerms, 
							Org.tbOrg.EmailAddress, Org.tbOrg.AddressCode, Activity.tbActivity.ActivityCode, Activity.tbActivity.UnitOfMeasure, MIN(Task.tbTask.ActionedOn) AS FirstActionedOn, 
							SUM(tbInvoiceTask.Quantity) AS ActivityQuantity, tbInvoiceTask.TaxCode, SUM(tbInvoiceTask.InvoiceValue) AS ActivityInvoiceValue, SUM(tbInvoiceTask.TaxValue) AS ActivityTaxValue
	FROM            Invoice.tbInvoice AS sales_invoice INNER JOIN
							Invoice.tbStatus ON sales_invoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
							Org.tbOrg ON sales_invoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
							Usr.tbUser ON sales_invoice.UserId = Usr.tbUser.UserId INNER JOIN
							Invoice.tbTask AS tbInvoiceTask ON sales_invoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
							Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
							Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode INNER JOIN
							Invoice.tbType ON sales_invoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	WHERE        EXISTS
								(SELECT        UserName, DocTypeCode, DocumentNumber, SpooledOn
									FROM            App.tbDocSpool AS doc
									WHERE        (DocTypeCode = 4) AND (UserName = SUSER_SNAME()) AND (sales_invoice.InvoiceNumber = DocumentNumber))
	GROUP BY sales_invoice.InvoiceNumber, Invoice.tbType.InvoiceType, sales_invoice.InvoiceStatusCode, Usr.tbUser.UserName, sales_invoice.AccountCode, Org.tbOrg.AccountName, 
							Invoice.tbStatus.InvoiceStatus, sales_invoice.InvoicedOn, sales_invoice.InvoiceValue, sales_invoice.TaxValue, sales_invoice.PaymentTerms, Org.tbOrg.EmailAddress, Org.tbOrg.AddressCode, 
							Activity.tbActivity.ActivityCode, Activity.tbActivity.UnitOfMeasure, tbInvoiceTask.TaxCode
)
SELECT        invoice_1.InvoiceNumber, invoice_1.InvoiceType, invoice_1.InvoiceStatusCode, invoice_1.UserName, invoice_1.AccountCode, invoice_1.AccountName, invoice_1.InvoiceStatus, invoice_1.InvoicedOn, 
                        Invoice.tbInvoice.Notes, Org.tbAddress.Address AS InvoiceAddress, invoice_1.InvoiceValueTotal, invoice_1.TaxValueTotal, invoice_1.PaymentTerms, invoice_1.EmailAddress, invoice_1.AddressCode, 
                        invoice_1.ActivityCode, invoice_1.UnitOfMeasure, invoice_1.FirstActionedOn, invoice_1.ActivityQuantity, invoice_1.TaxCode, invoice_1.ActivityInvoiceValue, invoice_1.ActivityTaxValue
FROM            invoice AS invoice_1 INNER JOIN
                        Invoice.tbInvoice ON invoice_1.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber LEFT OUTER JOIN
                        Org.tbAddress ON invoice_1.AddressCode = Org.tbAddress.AddressCode;
GO

/****** Object:  View [Task].[vwSalesOrderSpool]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwSalesOrderSpool]
AS
SELECT        sales_order.TaskCode, sales_order.ContactName, Org.tbContact.NickName, Usr.tbUser.UserName, Org.tbOrg.AccountName, invoice_address.Address AS InvoiceAddress, 
                         delivery_address.Address AS DeliveryAddress, sales_order.AccountCode, sales_order.TaskNotes, sales_order.TaskTitle, sales_order.ActivityCode, sales_order.ActionOn, Activity.tbActivity.UnitOfMeasure, 
                         sales_order.Quantity, App.tbTaxCode.TaxCode, App.tbTaxCode.TaxRate, sales_order.UnitCharge, sales_order.TotalCharge, Usr.tbUser.MobileNumber, Usr.tbUser.Signature
FROM            Usr.tbUser INNER JOIN
                         Activity.tbActivity INNER JOIN
                         Task.tbTask AS sales_order ON Activity.tbActivity.ActivityCode = sales_order.ActivityCode INNER JOIN
                         Org.tbOrg ON sales_order.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Org.tbAddress AS invoice_address ON Org.tbOrg.AddressCode = invoice_address.AddressCode ON Usr.tbUser.UserId = sales_order.ActionById LEFT OUTER JOIN
                         Org.tbAddress AS delivery_address ON sales_order.AddressCodeTo = delivery_address.AddressCode LEFT OUTER JOIN
                         App.tbTaxCode ON sales_order.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
                         Org.tbContact ON sales_order.AccountCode = Org.tbContact.AccountCode AND sales_order.ContactName = Org.tbContact.ContactName
WHERE EXISTS (
	SELECT        UserName, DocTypeCode, DocumentNumber, SpooledOn
    FROM            App.tbDocSpool AS doc
    WHERE        (DocTypeCode = 1) AND (UserName = SUSER_SNAME()) AND (sales_order.TaskCode = DocumentNumber));
GO

/****** Object:  View [Cash].[vwStatement]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwStatement]
AS
SELECT        TOP (100) PERCENT fnStatementCompany.TransactOn, fnStatementCompany.CashEntryTypeCode, fnStatementCompany.ReferenceCode, fnStatementCompany.AccountCode, Org.tbOrg.AccountName, 
                         Cash.tbEntryType.CashEntryType, fnStatementCompany.PayOut, fnStatementCompany.PayIn, fnStatementCompany.Balance, Cash.tbCode.CashCode, Cash.tbCode.CashDescription
FROM            Cash.fnStatementCompany() AS fnStatementCompany INNER JOIN
                         Cash.tbEntryType ON fnStatementCompany.CashEntryTypeCode = Cash.tbEntryType.CashEntryTypeCode INNER JOIN
                         Org.tbOrg ON fnStatementCompany.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                         Cash.tbCode ON fnStatementCompany.CashCode = Cash.tbCode.CashCode
ORDER BY fnStatementCompany.TransactOn, fnStatementCompany.CashEntryTypeCode, fnStatementCompany.ReferenceCode, fnStatementCompany.CashCode
GO

/****** Object:  View [Cash].[vwStatementCorpTaxDueDate]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwStatementCorpTaxDueDate]
AS
SELECT        PayOn
FROM            Cash.fnTaxTypeDueDates(0) AS fnTaxTypeDueDates
WHERE        (PayOn > CURRENT_TIMESTAMP)
GO

/****** Object:  View [Cash].[vwStatementReserves]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwStatementReserves]
AS
SELECT     TOP 100 PERCENT fnStatementReserves.TransactOn, fnStatementReserves.CashEntryTypeCode, fnStatementReserves.ReferenceCode, 
                      fnStatementReserves.AccountCode, Org.tbOrg.AccountName, Cash.tbEntryType.CashEntryType, fnStatementReserves.PayOut, 
                      fnStatementReserves.PayIn, fnStatementReserves.Balance, Cash.tbCode.CashCode, Cash.tbCode.CashDescription
FROM         Cash.fnStatementReserves() AS fnStatementReserves INNER JOIN
                      Cash.tbEntryType ON fnStatementReserves.CashEntryTypeCode = Cash.tbEntryType.CashEntryTypeCode INNER JOIN
                      Org.tbOrg ON fnStatementReserves.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
                      Cash.tbCode ON fnStatementReserves.CashCode = Cash.tbCode.CashCode
ORDER BY fnStatementReserves.TransactOn, fnStatementReserves.CashEntryTypeCode, fnStatementReserves.ReferenceCode, fnStatementReserves.CashCode
GO

/****** Object:  View [Cash].[vwStatementVatDueDate]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwStatementVatDueDate]
  AS
SELECT     TOP 1 PayOn
FROM         Cash.fnTaxTypeDueDates(1) fnTaxTypeDueDates
WHERE     (PayOn > CURRENT_TIMESTAMP)
GO

/****** Object:  View [App].[vwTaxCodes]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [App].[vwTaxCodes]
AS
SELECT        App.tbTaxCode.TaxCode, App.tbTaxCode.TaxDescription, Cash.tbTaxType.TaxType
FROM            App.tbTaxCode INNER JOIN
                         Cash.tbTaxType ON App.tbTaxCode.TaxTypeCode = Cash.tbTaxType.TaxTypeCode;
GO

/****** Object:  View [App].[vwTaxCodeTypes]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [App].[vwTaxCodeTypes]
AS
SELECT        TaxTypeCode, TaxType
FROM            Cash.tbTaxType
WHERE        (TaxTypeCode > 0);
GO

/****** Object:  View [Cash].[vwTaxCorpStatement]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO


CREATE VIEW [Cash].[vwTaxCorpStatement]
AS
SELECT     TOP (100) PERCENT StartOn, TaxDue, TaxPaid, Balance
FROM         Cash.fnTaxCorpStatement() AS fnTaxCorpStatement
WHERE     (StartOn > App.fnHistoryStartOn())
ORDER BY StartOn, TaxDue

GO

/****** Object:  View [Cash].[vwTaxVatStatement]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO


CREATE VIEW [Cash].[vwTaxVatStatement]
AS
SELECT        TOP (100) PERCENT StartOn, VatDue, VatPaid, Balance
FROM            Cash.fnTaxVatStatement() AS fnTaxVatStatement
WHERE        (StartOn > App.fnHistoryStartOn())
ORDER BY StartOn, VatDue
GO

/****** Object:  View [Cash].[vwTaxVatTotals]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwTaxVatTotals]
AS
SELECT     TOP (100) PERCENT App.tbYear.YearNumber, App.tbYear.Description, 
                      App.tbMonth.MonthName + ' ' + LTRIM(STR(YEAR(App.tbYearPeriod.StartOn))) AS Period, fnTaxVatTotals.StartOn, fnTaxVatTotals.HomeSales, 
                      fnTaxVatTotals.HomePurchases, fnTaxVatTotals.ExportSales, fnTaxVatTotals.ExportPurchases, fnTaxVatTotals.HomeSalesVat, fnTaxVatTotals.HomePurchasesVat, 
                      fnTaxVatTotals.ExportSalesVat, fnTaxVatTotals.ExportPurchasesVat, fnTaxVatTotals.VatAdjustment, fnTaxVatTotals.VatDue
FROM         Cash.fnTaxVatTotals() AS fnTaxVatTotals INNER JOIN
                      App.tbYearPeriod ON fnTaxVatTotals.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                      App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                      App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
WHERE     (App.tbYear.CashStatusCode = 1) OR
                      (App.tbYear.CashStatusCode = 2)
ORDER BY fnTaxVatTotals.StartOn
GO

/****** Object:  View [Task].[vwTitles]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Task].[vwTitles]
AS
SELECT        ActivityCode, TaskTitle
FROM            Task.tbTask
GROUP BY TaskTitle, ActivityCode
HAVING        (TaskTitle IS NOT NULL);
GO

/****** Object:  View [Org].[vwTypeLookup]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Org].[vwTypeLookup]
AS
SELECT        Org.tbType.OrganisationTypeCode, Org.tbType.OrganisationType, Cash.tbMode.CashMode
FROM            Org.tbType INNER JOIN
                         Cash.tbMode ON Org.tbType.CashModeCode = Cash.tbMode.CashModeCode;
GO

/****** Object:  View [App].[vwVatCashCode]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

/************************************************************
TABLE VALUED FUNCTIONS
************************************************************/

--Dependent objects
CREATE VIEW [App].[vwVatCashCode]
  AS
SELECT     CashCode, MonthNumber, RecurrenceCode
FROM         Cash.tbTaxType
WHERE     (TaxTypeCode = 1)
GO

/****** Object:  View [Cash].[vwVATCodes]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [Cash].[vwVATCodes]
AS
SELECT        TaxCode, TaxDescription
FROM            App.tbTaxCode
WHERE        (TaxTypeCode = 1);
GO

/****** Object:  View [App].[vwWarehouseOrg]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [App].[vwWarehouseOrg]
AS
SELECT TOP (100) PERCENT Org.tbOrg.AccountCode, Org.tbDoc.DocumentName, Org.tbOrg.AccountName, Org.tbDoc.DocumentImage, Org.tbDoc.DocumentDescription, Org.tbDoc.InsertedBy, Org.tbDoc.InsertedOn, Org.tbDoc.UpdatedBy, 
                         Org.tbDoc.UpdatedOn
FROM            Org.tbOrg INNER JOIN
                         Org.tbDoc ON Org.tbOrg.AccountCode = Org.tbDoc.AccountCode
ORDER BY Org.tbDoc.AccountCode, Org.tbDoc.DocumentName;
GO

/****** Object:  View [App].[vwWarehouseTask]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [App].[vwWarehouseTask]
AS
SELECT TOP (100) PERCENT Task.tbDoc.TaskCode, Task.tbDoc.DocumentName, Org.tbOrg.AccountName, Task.tbTask.TaskTitle, Task.tbDoc.DocumentImage, Task.tbDoc.DocumentDescription, Task.tbDoc.InsertedBy, Task.tbDoc.InsertedOn, 
                         Task.tbDoc.UpdatedBy, Task.tbDoc.UpdatedOn
FROM            Org.tbOrg INNER JOIN
                         Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode INNER JOIN
                         Task.tbDoc ON Task.tbTask.TaskCode = Task.tbDoc.TaskCode
ORDER BY Task.tbDoc.TaskCode, Task.tbDoc.DocumentName;
GO

/****** Object:  View [App].[vwYearPeriod]    Script Date: 18/06/2018 18:08:31 ******/

GO


GO

CREATE VIEW [App].[vwYearPeriod]
AS
SELECT TOP (100) PERCENT App.tbYear.Description, App.tbMonth.MonthName, App.tbYearPeriod.CashStatusCode, App.tbYearPeriod.YearNumber, App.tbYearPeriod.StartOn
FROM            App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
ORDER BY App.tbYearPeriod.YearNumber, App.tbYearPeriod.StartOn;
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[30] 4[31] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbOp (Task)"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 224
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbTask (Task)"
            Begin Extent = 
               Top = 6
               Left = 262
               Bottom = 136
               Right = 449
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbOrg (Org)"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 255
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbStatus (Task)"
            Begin Extent = 
               Top = 246
               Left = 357
               Bottom = 342
               Right = 530
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "vwOpBucket (Task)"
            Begin Extent = 
               Top = 11
               Left = 504
               Bottom = 124
               Right = 690
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbCode (Cash)"
            Begin Extent = 
               Top = 248
               Left = 748
               Bottom = 378
               Right = 924
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
 ' , @level0type=N'SCHEMA',@level0name=N'Task', @level1type=N'VIEW',@level1name=N'vwOps'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'        Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'Task', @level1type=N'VIEW',@level1name=N'vwOps'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'Task', @level1type=N'VIEW',@level1name=N'vwOps'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "fnStatementCompany"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 234
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbEntryType (Cash)"
            Begin Extent = 
               Top = 216
               Left = 345
               Bottom = 312
               Right = 541
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbOrg (Org)"
            Begin Extent = 
               Top = 74
               Left = 344
               Bottom = 204
               Right = 561
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbCode (Cash)"
            Begin Extent = 
               Top = 217
               Left = 118
               Bottom = 347
               Right = 294
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'Cash', @level1type=N'VIEW',@level1name=N'vwStatement'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'Cash', @level1type=N'VIEW',@level1name=N'vwStatement'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "vwSummaryBase (Cash)"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 220
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 1890
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'Cash', @level1type=N'VIEW',@level1name=N'vwSummary'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'Cash', @level1type=N'VIEW',@level1name=N'vwSummary'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[51] 4[10] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbUser (Usr)"
            Begin Extent = 
               Top = 283
               Left = 682
               Bottom = 413
               Right = 863
            End
            DisplayFlags = 344
            TopColumn = 0
         End
         Begin Table = "TaskStatus"
            Begin Extent = 
               Top = 211
               Left = 676
               Bottom = 307
               Right = 849
            End
            DisplayFlags = 344
            TopColumn = 0
         End
         Begin Table = "tbType (Org)"
            Begin Extent = 
               Top = 117
               Left = 1060
               Bottom = 230
               Right = 1271
            End
            DisplayFlags = 344
            TopColumn = 0
         End
         Begin Table = "tbOrg (Org)"
            Begin Extent = 
               Top = 65
               Left = 792
               Bottom = 195
               Right = 1009
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "OrgStatus"
            Begin Extent = 
               Top = 259
               Left = 1044
               Bottom = 355
               Right = 1261
            End
            DisplayFlags = 344
            TopColumn = 0
         End
         Begin Table = "tbTask (Task)"
            Begin Extent = 
               Top = 14
               Left = 438
               Bottom = 246
               Right = 625
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbUser_1"
            Begin Extent = 
               Top = 15
               Left = 750
               Bottom = 188
               Right = 931
            E' , @level0type=N'SCHEMA',@level0name=N'Task', @level1type=N'VIEW',@level1name=N'vwTasks'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'nd
            DisplayFlags = 344
            TopColumn = 0
         End
         Begin Table = "vwBucket (Task)"
            Begin Extent = 
               Top = 15
               Left = 229
               Bottom = 140
               Right = 399
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbCode (Cash)"
            Begin Extent = 
               Top = 199
               Left = 230
               Bottom = 329
               Right = 406
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbCategory (Cash)"
            Begin Extent = 
               Top = 284
               Left = 39
               Bottom = 414
               Right = 230
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 37
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'Task', @level1type=N'VIEW',@level1name=N'vwTasks'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'Task', @level1type=N'VIEW',@level1name=N'vwTasks'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbBase"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 246
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'Invoice', @level1type=N'VIEW',@level1name=N'vwVatSummary'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'Invoice', @level1type=N'VIEW',@level1name=N'vwVatSummary'
GO

/****** Object:  StoredProcedure [Invoice].[proc_Accept]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Invoice].[proc_Accept] 
	(
	@InvoiceNumber nvarchar(20)
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
			SET              InvoiceStatusCode = 1
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (InvoiceStatusCode = 0) 
	
			UPDATE       Task
			SET                TaskStatusCode = 3
			FROM            Task.tbTask AS Task INNER JOIN
									 Task.vwInvoicedQuantity ON Task.TaskCode = Task.vwInvoicedQuantity.TaskCode AND Task.Quantity <= Task.vwInvoicedQuantity.InvoiceQuantity INNER JOIN
									 Invoice.tbTask AS InvoiceTask ON Task.TaskCode = InvoiceTask.TaskCode AND Task.TaskCode = InvoiceTask.TaskCode
			WHERE        (InvoiceTask.InvoiceNumber = @InvoiceNumber) AND (Task.TaskStatusCode < 3)
			
			COMMIT TRAN trAcc
		END
			
	RETURN
GO

/****** Object:  StoredProcedure [Cash].[proc_AccountRebuild]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Cash].[proc_AccountRebuild]
	(
	@CashAccountCode nvarchar(10)
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

/****** Object:  StoredProcedure [Cash].[proc_AccountRebuildAll]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Cash].[proc_AccountRebuildAll]
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

/****** Object:  StoredProcedure [Org].[proc_AddAddress]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Org].[proc_AddAddress] 
	(
	@AccountCode nvarchar(10),
	@Address ntext
	)
  AS
DECLARE @AddressCode nvarchar(15)
DECLARE @RC int
	
	EXECUTE @RC = Org.proc_NextAddressCode @AccountCode, @AddressCode OUTPUT
	
	INSERT INTO Org.tbAddress
	                      (AddressCode, AccountCode, Address)
	VALUES     (@AddressCode, @AccountCode, @Address)
	
	RETURN
GO

/****** Object:  StoredProcedure [App].[proc_AddCalDateRange]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [App].[proc_AddCalDateRange]
	(
		@CalendarCode nvarchar(10),
		@FromDate datetime,
		@ToDate datetime
	)
   AS
DECLARE @UnavailableDate datetime

	SELECT @UnavailableDate = @FromDate
	
	WHILE @UnavailableDate <= @ToDate
	BEGIN
		INSERT INTO App.tbCalendarHoliday (CalendarCode, UnavailableOn)
		VALUES (@CalendarCode, @UnavailableDate)
		SELECT @UnavailableDate = DateAdd(d, 1, @UnavailableDate)
	END

	RETURN
GO

/****** Object:  StoredProcedure [Org].[proc_AddContact]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Org].[proc_AddContact] 
	(
	@AccountCode nvarchar(10),
	@ContactName nvarchar(100)	 
	)
  AS
DECLARE @FileAs nvarchar(10)
DECLARE @RC int
	
	EXECUTE @RC = Org.proc_ContactFileAs @ContactName, @FileAs OUTPUT	
	
	INSERT INTO Org.tbContact
	                      (AccountCode, ContactName, FileAs, PhoneNumber, EmailAddress)
	SELECT     AccountCode, @ContactName AS ContactName, @FileAs, PhoneNumber, EmailAddress
	FROM         Org.tbOrg
	WHERE AccountCode = @AccountCode
	
	RETURN
GO

/****** Object:  StoredProcedure [Invoice].[proc_AddTask]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Invoice].[proc_AddTask] 
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
		RETURN
		
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
	
	EXEC Invoice.proc_Total @InvoiceNumber
			
	RETURN
GO

/****** Object:  StoredProcedure [App].[proc_AdjustToCalendar]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [App].[proc_AdjustToCalendar]
	(
	@SourceDate datetime,
	@OffsetDays int,
	@OutputDate datetime output
	)
AS
DECLARE @UserId nvarchar(10)

	SELECT @UserId = UserId
	FROM         Usr.vwCredentials	
	
	SET @OutputDate = App.fnAdjustToCalendar(@UserId, @SourceDate, @OffsetDays)

	RETURN
GO

/****** Object:  StoredProcedure [Task].[proc_AssignToParent]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_AssignToParent] 
	(
	@ChildTaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20)
	)
  AS
DECLARE @TaskTitle nvarchar(100)
DECLARE @StepNumber smallint

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

/****** Object:  StoredProcedure [Org].[proc_BalanceOutstanding]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Org].[proc_BalanceOutstanding] 
	(
	@AccountCode nvarchar(10),
	@Balance money = 0 OUTPUT
	)
  AS

	IF EXISTS(SELECT     Invoice.tbInvoice.AccountCode
	          FROM         Invoice.tbInvoice INNER JOIN
	                                Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	          WHERE     ( Invoice.tbInvoice.AccountCode = @AccountCode) AND ( Invoice.tbInvoice.InvoiceStatusCode > 0 AND Invoice.tbInvoice.InvoiceStatusCode < 3)
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
	          WHERE     (PaymentStatusCode = 0) AND (AccountCode = @AccountCode)) AND (@Balance <> 0)
		BEGIN
		SELECT  @Balance = @Balance - SUM(PaidInValue - PaidOutValue) 
		FROM         Org.tbPayment
		WHERE     (PaymentStatusCode = 0) AND (AccountCode = @AccountCode)		
		END
		
	SELECT    @Balance = isnull(@Balance, 0) - CurrentBalance
	FROM         Org.tbOrg
	WHERE     (AccountCode = @AccountCode)
		
	RETURN
GO

/****** Object:  StoredProcedure [Invoice].[proc_Cancel]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Invoice].[proc_Cancel] 
  AS

	UPDATE       Task
	SET                TaskStatusCode = 2
	FROM            Task.tbTask AS Task INNER JOIN
							 Invoice.tbTask AS InvoiceTask ON Task.TaskCode = InvoiceTask.TaskCode AND Task.TaskCode = InvoiceTask.TaskCode INNER JOIN
							 Invoice.tbInvoice ON InvoiceTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							 Usr.vwCredentials ON Invoice.tbInvoice.UserId = Usr.vwCredentials.UserId
	WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 0 OR
							 Invoice.tbInvoice.InvoiceTypeCode = 2) AND (Invoice.tbInvoice.InvoiceStatusCode = 0)
	                      
	DELETE Invoice.tbInvoice
	FROM         Invoice.tbInvoice INNER JOIN
	                      Usr.vwCredentials ON Invoice.tbInvoice.UserId = Usr.vwCredentials.UserId
	WHERE     ( Invoice.tbInvoice.InvoiceStatusCode = 0)

	
	RETURN
GO

/****** Object:  StoredProcedure [Cash].[proc_CategoryCashCodes]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Cash].[proc_CategoryCashCodes]
	(
	@CategoryCode nvarchar(10)
	)
   AS
	SELECT     CashCode, CashDescription
	FROM         Cash.tbCode
	WHERE     (CategoryCode = @CategoryCode)
	ORDER BY CashDescription
	RETURN 
GO

/****** Object:  StoredProcedure [Cash].[proc_CategoryCodeFromName]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Cash].[proc_CategoryCodeFromName]
	(
		@Category nvarchar(50),
		@CategoryCode nvarchar(10) output
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

/****** Object:  StoredProcedure [Cash].[proc_CategoryTotals]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Cash].[proc_CategoryTotals]
	(
	@CashTypeCode smallint,
	@CategoryTypeCode smallint = 1
	)
   AS

	SELECT     Cash.tbCategory.DisplayOrder, Cash.tbCategory.Category, Cash.tbType.CashType, Cash.tbCategory.CategoryCode
	FROM         Cash.tbCategory INNER JOIN
	                      Cash.tbType ON Cash.tbCategory.CashTypeCode = Cash.tbType.CashTypeCode
	WHERE     ( Cash.tbCategory.CashTypeCode = @CashTypeCode) AND ( Cash.tbCategory.CategoryTypeCode = @CategoryTypeCode)
	ORDER BY Cash.tbCategory.DisplayOrder, Cash.tbCategory.Category
	
	RETURN 
GO

/****** Object:  StoredProcedure [Cash].[proc_CodeDefaults]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Cash].[proc_CodeDefaults] 
	(
	@CashCode nvarchar(50)
	)
  AS
	SELECT     Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCode.CategoryCode, Cash.tbCode.TaxCode, Cash.tbCode.OpeningBalance, 
	                      ISNULL( Cash.tbCategory.CashModeCode, 0) AS CashModeCode, App.tbTaxCode.TaxTypeCode
	FROM         Cash.tbCode INNER JOIN
	                      App.tbTaxCode ON Cash.tbCode.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
	                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE     ( Cash.tbCode.CashCode = @CashCode)
	
	RETURN
GO

/****** Object:  StoredProcedure [Cash].[proc_CodeValues]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Cash].[proc_CodeValues]
	(
	@CashCode nvarchar(50),
	@YearNumber smallint
	)
    AS
	SELECT        Cash.vwFlowData.StartOn, Cash.vwFlowData.InvoiceValue, Cash.vwFlowData.InvoiceTax, Cash.vwFlowData.ForecastValue, Cash.vwFlowData.ForecastTax
	FROM            App.tbYearPeriod INNER JOIN
	                         Cash.vwFlowData ON App.tbYearPeriod.StartOn = Cash.vwFlowData.StartOn
	WHERE        ( App.tbYearPeriod.YearNumber = @YearNumber) AND (Cash.vwFlowData.CashCode = @CashCode)
	ORDER BY Cash.vwFlowData.StartOn
	
	RETURN 

GO

/****** Object:  StoredProcedure [App].[proc_CompanyName]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [App].[proc_CompanyName]
	(
	@AccountName nvarchar(255) = null output
	)
  AS
	SELECT TOP 1 @AccountName = Org.tbOrg.AccountName
	FROM         Org.tbOrg INNER JOIN
	                      App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode
	RETURN 
GO

/****** Object:  StoredProcedure [Task].[proc_Configure]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE  PROCEDURE [Task].[proc_Configure] 
	(
	@ParentTaskCode nvarchar(20)
	)
   AS
DECLARE @StepNumber smallint
DECLARE @TaskCode nvarchar(20)
DECLARE @UserId nvarchar(10)
DECLARE @ActivityCode nvarchar(50)

	IF EXISTS (SELECT     ContactName
	           FROM         Task.tbTask
	           WHERE     (TaskCode = @ParentTaskCode) AND (NOT (ContactName IS NULL)) OR
	                                 (TaskCode = @ParentTaskCode) AND (ContactName <> N''))
		BEGIN
		IF not EXISTS(SELECT     Org.tbContact.ContactName
					  FROM         Task.tbTask INNER JOIN
											Org.tbContact ON Task.tbTask.AccountCode = Org.tbContact.AccountCode AND Task.tbTask.ContactName = Org.tbContact.ContactName
					  WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode))
			BEGIN
			DECLARE @FileAs nvarchar(100)
			DECLARE @ContactName nvarchar(100)
			DECLARE @NickName nvarchar(100)
			
			SELECT @ContactName = ContactName FROM Task.tbTask	 
			WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode)
			
			IF LEN(isnull(@ContactName, '')) > 0
				BEGIN
				SET @NickName = left(@ContactName, CHARINDEX(' ', @ContactName, 1))
				EXEC Org.proc_ContactFileAs @ContactName, @FileAs output
				
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
	          WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode) AND ( Org.tbOrg.OrganisationStatusCode = 0))
		BEGIN
		UPDATE Org.tbOrg
		SET OrganisationStatusCode = 1
		FROM         Org.tbOrg INNER JOIN
	                                Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode
	          WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode) AND ( Org.tbOrg.OrganisationStatusCode = 0)				
		END
	          
	IF EXISTS(SELECT     TaskStatusCode
	          FROM         Task.tbTask
	          WHERE     (TaskStatusCode = 2) AND (TaskCode = @ParentTaskCode))
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
	                      (TaskCode, UserId, OperationNumber, OpTypeCode, Operation, Duration, OffsetDays, StartOn)
	SELECT     Task.tbTask.TaskCode, Task.tbTask.UserId, Activity.tbOp.OperationNumber, Activity.tbOp.OpTypeCode, Activity.tbOp.Operation, Activity.tbOp.Duration, 
	                      Activity.tbOp.OffsetDays, Task.tbTask.ActionOn
	FROM         Activity.tbOp INNER JOIN
	                      Task.tbTask ON Activity.tbOp.ActivityCode = Task.tbTask.ActivityCode
	WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode)
	                   
	
	SELECT @UserId = UserId FROM Task.tbTask WHERE Task.tbTask.TaskCode = @ParentTaskCode
	
	DECLARE curAct cursor local for
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
		
		EXEC Task.proc_NextCode @ActivityCode, @TaskCode output
		
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
		                      (ParentTaskCode, StepNumber, ChildTaskCode, UsedOnQuantity, OffsetDays)
		SELECT     Task.tbTask.TaskCode, Activity.tbFlow.StepNumber, @TaskCode AS ChildTaskCode, Activity.tbFlow.UsedOnQuantity, Activity.tbFlow.OffsetDays
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

/****** Object:  StoredProcedure [Org].[proc_ContactFileAs]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Org].[proc_ContactFileAs] 
	(
	@ContactName nvarchar(100),
	@FileAs nvarchar(100) output
	)
  AS

	IF CHARINDEX(' ', @ContactName) = 0
		SET @FileAs = @ContactName
	ELSE
		BEGIN
		DECLARE @FirstNames nvarchar(100)
		DECLARE @LastName nvarchar(100)
		DECLARE @LastWordPos int
		
		SET @LastWordPos = CHARINDEX(' ', @ContactName) + 1
		WHILE CHARINDEX(' ', @ContactName, @LastWordPos) != 0
			SET @LastWordPos = CHARINDEX(' ', @ContactName, @LastWordPos) + 1
		
		SET @FirstNames = left(@ContactName, @LastWordPos - 2)
		SET @LastName = right(@ContactName, LEN(@ContactName) - @LastWordPos + 1)
		SET @FileAs = @LastName + ', ' + @FirstNames
		END

	RETURN
GO

/****** Object:  StoredProcedure [Task].[proc_Copy]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_Copy]
	(
	@FromTaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20) = null,
	@ToTaskCode nvarchar(20) = null output
	)
AS
DECLARE @ActivityCode nvarchar(50)
DECLARE @Printed bit
DECLARE @ChildTaskCode nvarchar(20)
DECLARE @TaskStatusCode smallint
DECLARE @StepNumber smallint
DECLARE @UserId nvarchar(10)

	SELECT @UserId = UserId FROM Usr.vwCredentials
	
	SELECT  @TaskStatusCode = Activity.tbActivity.TaskStatusCode, @ActivityCode = Task.tbTask.ActivityCode, @Printed = CASE WHEN Activity.tbActivity.PrintOrder = 0 THEN 1 ELSE 0 END
	FROM         Task.tbTask INNER JOIN
	                      Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode
	WHERE     ( Task.tbTask.TaskCode = @FromTaskCode)
	
	EXEC Task.proc_NextCode @ActivityCode, @ToTaskCode output

	INSERT INTO Task.tbTask
						  (TaskCode, UserId, AccountCode, TaskTitle, ContactName, ActivityCode, TaskStatusCode, ActionById, ActionOn, ActionedOn, TaskNotes, Quantity, 
						  SecondReference, CashCode, TaxCode, UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, PaymentOn, Printed)
	SELECT     @ToTaskCode AS ToTaskCode, @UserId AS Owner, AccountCode, TaskTitle, ContactName, ActivityCode, @TaskStatusCode AS TaskStatus, 
						  @UserId AS ActionUserId, CAST(CURRENT_TIMESTAMP AS date) AS ActionOn, 
						  CASE WHEN @TaskStatusCode > 1 THEN CAST(CURRENT_TIMESTAMP AS date) ELSE NULL END AS ActionedOn, TaskNotes, 
						  Quantity, SecondReference, CashCode, TaxCode, UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, 
						  Task.fnDefaultPaymentOn(AccountCode, CAST(CURRENT_TIMESTAMP AS date)) AS PaymentOn, @Printed AS Printed
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
						  (TaskCode, OperationNumber, OpStatusCode, UserId, OpTypeCode, Operation, Note, StartOn, EndOn, Duration, OffsetDays)
	SELECT     @ToTaskCode AS ToTaskCode, OperationNumber, 0 AS OpStatusCode, UserId, OpTypeCode, Operation, Note, 
		CAST(CURRENT_TIMESTAMP AS date) AS StartOn, CAST(CURRENT_TIMESTAMP AS date) AS EndOn, Duration, OffsetDays
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
			(ParentTaskCode, StepNumber, ChildTaskCode, UsedOnQuantity, OffsetDays)
			SELECT TOP 1 ParentTaskCode, @StepNumber AS Step, @ToTaskCode AS ChildTask, UsedOnQuantity, OffsetDays
			FROM         Task.tbFlow
			WHERE     (ChildTaskCode = @FromTaskCode)
			END
		END
	ELSE
		BEGIN
		
		INSERT INTO Task.tbFlow
		(ParentTaskCode, StepNumber, ChildTaskCode, UsedOnQuantity, OffsetDays)
		SELECT TOP 1 @ParentTaskCode As ParentTask, StepNumber, @ToTaskCode AS ChildTask, UsedOnQuantity, OffsetDays
		FROM         Task.tbFlow 
		WHERE     (ChildTaskCode = @FromTaskCode)		
		END
	
	DECLARE curTask cursor local for			
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

/****** Object:  StoredProcedure [Cash].[proc_CopyForecastToLiveCashCode]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Cash].[proc_CopyForecastToLiveCashCode]
	(
	@CashCode nvarchar(50),
	@StartOn datetime
	)

   AS
	UPDATE Cash.tbPeriod
	SET     InvoiceValue = ForecastValue, InvoiceTax = ForecastTax
	FROM         Cash.tbPeriod
	WHERE     (CashCode = @CashCode) AND (StartOn = @StartOn)
	RETURN 
GO

/****** Object:  StoredProcedure [Cash].[proc_CopyForecastToLiveCategory]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Cash].[proc_CopyForecastToLiveCategory]
	(
	@CategoryCode nvarchar(10),
	@StartOn datetime
	)

   AS
	UPDATE Cash.tbPeriod
	SET     InvoiceValue = ForecastValue, InvoiceTax = ForecastTax
	FROM         Cash.tbPeriod INNER JOIN
	                      Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode
	WHERE     ( Cash.tbPeriod.StartOn = @StartOn) AND ( Cash.tbCode.CategoryCode = @CategoryCode)
GO

/****** Object:  StoredProcedure [Cash].[proc_CopyLiveToForecastCashCode]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Cash].[proc_CopyLiveToForecastCashCode]
	(
	@CashCode nvarchar(50),
	@Years smallint,
	@UseLastPeriod bit = 0
	)

   AS
DECLARE @SystemStartOn datetime
DECLARE @EndPeriod datetime
DECLARE @StartPeriod datetime
DECLARE @CurPeriod datetime
	
DECLARE @InvoiceValue money
DECLARE @InvoiceTax money

	SELECT @CurPeriod = StartOn
	FROM         App.fnActivePeriod() 
	
	SET @EndPeriod = DATEADD(m, -1, @CurPeriod)
	SET @StartPeriod = DATEADD(m, -11, @EndPeriod)	
	
	SELECT @SystemStartOn = MIN(StartOn)
	FROM         App.tbYearPeriod
	
	IF @StartPeriod < @SystemStartOn 
		SET @UseLastPeriod = 1

	IF @UseLastPeriod = 0
		goto YearCopyMode
	ELSE
		goto LastMonthCopyMode
		
	RETURN
		
	
YearCopyMode:

	DECLARE curPe cursor for
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
DECLARE @Idx integer

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

/****** Object:  StoredProcedure [Cash].[proc_CopyLiveToForecastCategory]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Cash].[proc_CopyLiveToForecastCategory]
	(
	@CategoryCode nvarchar(10),
	@Years smallint,
	@UseLastPeriod bit = 0
	)

   AS	
DECLARE @CashCode nvarchar(50)

	DECLARE curCc cursor for
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

/****** Object:  StoredProcedure [Task].[proc_Cost]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_Cost] 
	(
	@ParentTaskCode nvarchar(20),
	@TotalCost money = 0 output
	)

  AS
DECLARE @TaskCode nvarchar(20)
DECLARE @TotalCharge money
DECLARE @CashModeCode smallint

	DECLARE curFlow cursor local for
		SELECT     Task.tbTask.TaskCode, Task.vwCashMode.CashModeCode, Task.tbTask.TotalCharge
		FROM         Task.tbTask INNER JOIN
							  Task.tbFlow ON Task.tbTask.TaskCode = Task.tbFlow.ChildTaskCode INNER JOIN
							  Task.vwCashMode ON Task.tbTask.TaskCode = Task.vwCashMode.TaskCode
		WHERE     ( Task.tbFlow.ParentTaskCode = @ParentTaskCode) AND ( Task.tbTask.TaskStatusCode < 4)

	OPEN curFlow
	FETCH NEXT FROM curFlow INTO @TaskCode, @CashModeCode, @TotalCharge
	WHILE @@FETCH_STATUS = 0
		BEGIN
		SET @TotalCost = @TotalCost + CASE WHEN @CashModeCode = 0 THEN @TotalCharge ELSE @TotalCharge * -1 END
		EXEC Task.proc_Cost @TaskCode, @TotalCost output
		FETCH NEXT FROM curFlow INTO @TaskCode, @CashModeCode, @TotalCharge
		END
	
	CLOSE curFlow
	DEALLOCATE curFlow
	
	RETURN
GO

/****** Object:  StoredProcedure [Invoice].[proc_Credit]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Invoice].[proc_Credit]
	(
		@InvoiceNumber nvarchar(20) output
	)
  AS
DECLARE @InvoiceTypeCode smallint
DECLARE @CreditNumber nvarchar(20)
DECLARE @UserId nvarchar(10)
DECLARE @NextNumber int
DECLARE @InvoiceSuffix nvarchar(4)

	SELECT @UserId = UserId FROM Usr.vwCredentials
	
	SELECT @InvoiceTypeCode =	CASE InvoiceTypeCode 
									WHEN 0 THEN 1 
									WHEN 2 THEN 3 
									ELSE 3 
								END 
	FROM Invoice.tbInvoice WHERE InvoiceNumber = @InvoiceNumber
	
	
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
	SELECT     @CreditNumber AS InvoiceNumber, 0 AS InvoiceStatusCode, AccountCode, InvoiceValue, TaxValue, @UserId AS UserId, 
						@InvoiceTypeCode AS InvoiceTypeCode, CURRENT_TIMESTAMP AS InvoicedOn
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

/****** Object:  StoredProcedure [Org].[proc_DefaultAccountCode]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Org].[proc_DefaultAccountCode] 
	(
	@AccountName nvarchar(100),
	@AccountCode nvarchar(10) OUTPUT 
	)
  AS
DECLARE @ParsedName nvarchar(100)
DECLARE @FirstWord nvarchar(100)
DECLARE @SecondWord nvarchar(100)
DECLARE @ValidatedCode nvarchar(10)

DECLARE @c char(1)
DECLARE @ASCII smallint
DECLARE @pos int
DECLARE @ok bit

DECLARE @Suffix smallint
DECLARE @Rows int
		
	SET @pos = 1
	SET @ParsedName = ''

	WHILE @pos <= datalength(@AccountName)
	BEGIN
		SET @ASCII = ASCII(SUBSTRING(@AccountName, @pos, 1))
		SET @ok = CASE 
			WHEN @ASCII = 32 THEN 1
			WHEN @ASCII = 45 THEN 1
			WHEN (@ASCII >= 48 and @ASCII <= 57) THEN 1
			WHEN (@ASCII >= 65 and @ASCII <= 90) THEN 1
			WHEN (@ASCII >= 97 and @ASCII <= 122) THEN 1
			ELSE 0
		END
		IF @ok = 1
			SELECT @ParsedName = @ParsedName + char(ASCII(SUBSTRING(@AccountName, @pos, 1)))
		SET @pos = @pos + 1
	END

	--print @ParsedName
		
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
		SET @AccountCode = UPPER(left(@FirstWord, 3)) + UPPER(left(@SecondWord, 3))		
	ELSE
		SET @AccountCode = UPPER(left(@FirstWord, 6))

	SET @ValidatedCode = @AccountCode
	SELECT @rows = COUNT(AccountCode) FROM Org.tbOrg WHERE AccountCode = @ValidatedCode
	SET @Suffix = 0
	
	WHILE @rows > 0
	BEGIN
		SET @Suffix = @Suffix + 1
		SET @ValidatedCode = @AccountCode + LTRIM(STR(@Suffix))
		SELECT @rows = COUNT(AccountCode) FROM Org.tbOrg WHERE AccountCode = @ValidatedCode
	END
	
	SET @AccountCode = @ValidatedCode
	
	RETURN
GO

/****** Object:  StoredProcedure [Invoice].[proc_DefaultDocType]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Invoice].[proc_DefaultDocType]
	(
		@InvoiceNumber nvarchar(20),
		@DocTypeCode smallint OUTPUT
	)
AS
DECLARE @InvoiceTypeCode smallint

	SELECT  @InvoiceTypeCode = InvoiceTypeCode
	FROM         Invoice.tbInvoice
	WHERE     (InvoiceNumber = @InvoiceNumber)
	
	SET @DocTypeCode = CASE @InvoiceTypeCode
							WHEN 0 THEN 4
							WHEN 1 THEN 5							
							WHEN 3 THEN 6
							ELSE 4
							END
							
	RETURN

GO

/****** Object:  StoredProcedure [Task].[proc_DefaultDocType]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_DefaultDocType]
	(
		@TaskCode nvarchar(20),
		@DocTypeCode smallint OUTPUT
	)
  AS
DECLARE @CashModeCode smallint
DECLARE @TaskStatusCode smallint

	IF EXISTS(SELECT     CashModeCode
	          FROM         Task.vwCashMode
	          WHERE     (TaskCode = @TaskCode))
		SELECT   @CashModeCode = CashModeCode
		FROM         Task.vwCashMode
		WHERE     (TaskCode = @TaskCode)			          
	ELSE
		SET @CashModeCode = 1

	SELECT  @TaskStatusCode =TaskStatusCode
	FROM         Task.tbTask
	WHERE     (TaskCode = @TaskCode)		
	
	IF @CashModeCode = 0
		SET @DocTypeCode = CASE @TaskStatusCode WHEN 0 THEN 2 ELSE 3 END								
	ELSE
		SET @DocTypeCode = CASE @TaskStatusCode WHEN 0 THEN 0 ELSE 1 END 
		
	RETURN 

GO

/****** Object:  StoredProcedure [Task].[proc_DefaultInvoiceType]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_DefaultInvoiceType]
	(
		@TaskCode nvarchar(20),
		@InvoiceTypeCode smallint OUTPUT
	)
  AS
DECLARE @CashModeCode smallint

	IF EXISTS(SELECT     CashModeCode
	          FROM         Task.vwCashMode
	          WHERE     (TaskCode = @TaskCode))
		SELECT   @CashModeCode = CashModeCode
		FROM         Task.vwCashMode
		WHERE     (TaskCode = @TaskCode)			          
	ELSE
		SET @CashModeCode = 1
		
	IF @CashModeCode = 0
		SET @InvoiceTypeCode = 2
	ELSE
		SET @InvoiceTypeCode = 0
		
	RETURN 
GO

/****** Object:  StoredProcedure [Task].[proc_DefaultPaymentOn]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_DefaultPaymentOn]
	(
		@AccountCode nvarchar(10),
		@ActionOn datetime,
		@PaymentOn datetime output
	)
  AS
		
	SET @PaymentOn = Task.fnDefaultPaymentOn(@AccountCode, @ActionOn)
	
	RETURN 
GO

/****** Object:  StoredProcedure [Task].[proc_DefaultTaxCode]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_DefaultTaxCode] 
	(
	@AccountCode nvarchar(10),
	@CashCode nvarchar(50),
	@TaxCode nvarchar(10) OUTPUT
	)
  AS

	SET @TaxCode = Task.fnDefaultTaxCode(@AccountCode, @CashCode)
		
	RETURN
GO

/****** Object:  StoredProcedure [Org].[proc_DefaultTaxCode]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Org].[proc_DefaultTaxCode] 
	(
	@AccountCode nvarchar(10),
	@TaxCode nvarchar(10) OUTPUT
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

/****** Object:  StoredProcedure [App].[proc_DelCalDateRange]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [App].[proc_DelCalDateRange]
	(
		@CalendarCode nvarchar(10),
		@FromDate datetime,
		@ToDate datetime
	)
   AS
	DELETE FROM App.tbCalendarHoliday
		WHERE UnavailableOn >= @FromDate
			AND UnavailableOn <= @ToDate
			AND CalendarCode = @CalendarCode
			
	RETURN
GO

/****** Object:  StoredProcedure [Task].[proc_Delete]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_Delete] 
	(
	@TaskCode nvarchar(20)
	)
  AS

DECLARE @ChildTaskCode nvarchar(20)

	DELETE FROM Task.tbFlow
	WHERE     (ChildTaskCode = @TaskCode)

	DECLARE curFlow cursor local for
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

/****** Object:  StoredProcedure [App].[proc_DocDespool]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [App].[proc_DocDespool]
	(
	@DocTypeCode SMALLINT
	)
AS
	IF @DocTypeCode = 0
		GOTO Quotations
	ELSE IF @DocTypeCode = 1
		GOTO SalesOrder
	ELSE IF @DocTypeCode = 2
		GOTO PurchaseEnquiry
	ELSE IF @DocTypeCode = 3
		GOTO PurchaseOrder
	ELSE IF @DocTypeCode = 4
		GOTO SalesInvoice
	ELSE IF @DocTypeCode = 5
		GOTO CreditNote
	ELSE IF @DocTypeCode = 6
		GOTO DebitNote
		
	RETURN
	
Quotations:
	UPDATE       Task.tbTask
	SET           Spooled = 0, Printed = 1
	FROM            Task.tbTask INNER JOIN
							 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
							 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE        ( Task.tbTask.TaskStatusCode = 0) AND ( Cash.tbCategory.CashModeCode = 1) AND ( Task.tbTask.Spooled <> 0)
	RETURN
	
SalesOrder:
	UPDATE       Task.tbTask
	SET           Spooled = 0, Printed = 1
	FROM            Task.tbTask INNER JOIN
							 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
							 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE        ( Task.tbTask.TaskStatusCode > 0) AND ( Cash.tbCategory.CashModeCode = 1) AND ( Task.tbTask.Spooled <> 0)
	RETURN
	
PurchaseEnquiry:
	UPDATE       Task.tbTask
	SET           Spooled = 0, Printed = 1
	FROM            Task.tbTask INNER JOIN
							 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
							 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE        ( Task.tbTask.TaskStatusCode = 0) AND ( Cash.tbCategory.CashModeCode = 0) AND ( Task.tbTask.Spooled <> 0)	
	RETURN
	
PurchaseOrder:
	UPDATE       Task.tbTask
	SET           Spooled = 0, Printed = 1
	FROM            Task.tbTask INNER JOIN
							 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
							 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE        ( Task.tbTask.TaskStatusCode > 0) AND ( Cash.tbCategory.CashModeCode = 0) AND ( Task.tbTask.Spooled <> 0)
	RETURN
	
SalesInvoice:
	UPDATE       Invoice.tbInvoice
	SET                Spooled = 0, Printed = 1
	WHERE        (InvoiceTypeCode = 0) AND (Spooled <> 0)

	RETURN
	
CreditNote:
	UPDATE       Invoice.tbInvoice
	SET                Spooled = 0, Printed = 1
	WHERE        (InvoiceTypeCode = 1) AND (Spooled <> 0)
	RETURN
	
DebitNote:
	UPDATE       Invoice.tbInvoice
	SET                Spooled = 0, Printed = 1
	WHERE        (InvoiceTypeCode = 3) AND (Spooled <> 0)
	RETURN
GO

/****** Object:  StoredProcedure [Task].[proc_EmailAddress]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_EmailAddress] 
	(
	@TaskCode nvarchar(20),
	@EmailAddress nvarchar(255) OUTPUT
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

/****** Object:  StoredProcedure [Task].[proc_EmailDetail]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_EmailDetail] 
	(
	@TaskCode nvarchar(20)
	)
  AS
DECLARE @NickName nvarchar(100)
DECLARE @EmailAddress nvarchar(255)


	IF EXISTS(SELECT     Org.tbContact.ContactName
	          FROM         Org.tbContact INNER JOIN
	                                Task.tbTask ON Org.tbContact.AccountCode = Task.tbTask.AccountCode AND Org.tbContact.ContactName = Task.tbTask.ContactName
	          WHERE     ( Task.tbTask.TaskCode = @TaskCode))
		BEGIN
		SELECT  @NickName = CASE WHEN Org.tbContact.NickName is null THEN Org.tbContact.ContactName ELSE Org.tbContact.NickName END
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
	
	EXEC Task.proc_EmailAddress	@TaskCode, @EmailAddress output
	
	SELECT     Task.tbTask.TaskCode, Task.tbTask.TaskTitle, Org.tbOrg.AccountCode, Org.tbOrg.AccountName, @NickName AS NickName, @EmailAddress AS EmailAddress, 
	                      Task.tbTask.ActivityCode, Task.tbStatus.TaskStatus, Task.tbTask.TaskNotes
	FROM         Task.tbTask INNER JOIN
	                      Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
	                      Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode
	WHERE     ( Task.tbTask.TaskCode = @TaskCode)

	RETURN
GO

/****** Object:  StoredProcedure [Task].[proc_EmailFooter]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_EmailFooter] 
  AS
DECLARE @AccountName nvarchar(255)
DECLARE @WebSite nvarchar(255)

	SELECT TOP 1 @AccountName = Org.tbOrg.AccountName, @WebSite = Org.tbOrg.WebSite
	FROM         Org.tbOrg INNER JOIN
	                      App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode
	
	SELECT     Usr.tbUser.UserName, Usr.tbUser.PhoneNumber, Usr.tbUser.MobileNumber, @AccountName AS AccountName, @Website AS Website
	FROM         Usr.vwCredentials INNER JOIN
	                      Usr.tbUser ON Usr.vwCredentials.UserId = Usr.tbUser.UserId
	
	RETURN
GO

/****** Object:  StoredProcedure [Cash].[proc_FlowInitialise]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE  PROCEDURE [Cash].[proc_FlowInitialise]
   AS
DECLARE @CashCode nvarchar(25)
		
	EXEC Cash.proc_GeneratePeriods
	
	UPDATE       Cash.tbPeriod
	SET                ForecastValue = 0, ForecastTax = 0, InvoiceValue = 0, InvoiceTax = 0
	FROM            Cash.tbPeriod INNER JOIN
	                         Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode INNER JOIN
	                         Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE  ( Cash.tbCategory.CashTypeCode <> 2)
	
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
	WHERE        (TaxTypeCode = 0)
	
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
	WHERE        (TaxTypeCode = 1)

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
	WHERE     ( Cash.tbPeriod.CashCode = App.fnCashCode(2))
	                      
	
	RETURN 
GO

/****** Object:  StoredProcedure [Task].[proc_FullyInvoiced]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_FullyInvoiced]
	(
	@TaskCode nvarchar(20),
	@IsFullyInvoiced bit = 0 output
	)
AS
DECLARE @InvoiceValue money
DECLARE @TotalCharge money

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

/****** Object:  StoredProcedure [Cash].[proc_GeneratePeriods]    Script Date: 18/06/2018 18:10:32 ******/

GO


GO

CREATE PROCEDURE [Cash].[proc_GeneratePeriods]
    AS
DECLARE @YearNumber smallint
DECLARE @StartOn datetime
DECLARE @PeriodStartOn datetime
DECLARE @CashStatusCode smallint
DECLARE @Period smallint

	DECLARE curYr cursor for	
		SELECT     YearNumber, CAST(CONCAT(FORMAT(YearNumber, '0000'), FORMAT(StartMonth, '00'), FORMAT(1, '00')) AS DATE) AS StartOn, CashStatusCode
		FROM         App.tbYear

	OPEN curYr
	
	FETCH NEXT FROM curYr INTO @YearNumber, @StartOn, @CashStatusCode
	WHILE @@FETCH_STATUS = 0
		BEGIN
		SET @PeriodStartOn = @StartOn
		SET @Period = 1
		WHILE @Period < 13
			BEGIN
			IF not EXISTS (SELECT MonthNumber FROM App.tbYearPeriod WHERE YearNumber = @YearNumber and MonthNumber = DATEPART(m, @PeriodStartOn))
				BEGIN
				INSERT INTO App.tbYearPeriod (YearNumber, StartOn, MonthNumber, CashStatusCode)
				VALUES (@YearNumber, @PeriodStartOn, DATEPART(m, @PeriodStartOn), 1)				
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

/****** Object:  StoredProcedure [App].[proc_Initialised]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [App].[proc_Initialised]
(@Setting bit)
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
		RETURN 0
		END
	ELSE
		BEGIN
		UPDATE App.tbOptions Set Initialised = 0
		RETURN 1
		END

GO

/****** Object:  StoredProcedure [Task].[proc_IsProject]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_IsProject] 
	(
	@TaskCode nvarchar(20),
	@IsProject bit = 0 output
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

/****** Object:  StoredProcedure [Usr].[proc_MenuCleanReferences]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Usr].[proc_MenuCleanReferences](@MenuId SMALLINT)
AS

	WITH tbFolderRefs AS 
	(	SELECT        MenuId, EntryId, CAST(Argument AS int) AS FolderIdRef
		FROM            Usr.tbMenuEntry
		WHERE        (Command = 1))
	, tbBadRefs AS
	(
		SELECT        tbFolderRefs.EntryId
		FROM            tbFolderRefs LEFT OUTER JOIN
								Usr.tbMenuEntry AS tbMenuEntry ON tbFolderRefs.FolderIdRef = tbMenuEntry.FolderId AND tbFolderRefs.MenuId = tbMenuEntry.MenuId
		WHERE (tbMenuEntry.MenuId = @MenuId) AND (tbMenuEntry.MenuId IS NULL)
	)
	DELETE FROM Usr.tbMenuEntry
	FROM            Usr.tbMenuEntry INNER JOIN
							 tbBadRefs ON Usr.tbMenuEntry.EntryId = tbBadRefs.EntryId;
GO

/****** Object:  StoredProcedure [Usr].[proc_MenuInsert]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Usr].[proc_MenuInsert]
	(
		@MenuName nvarchar(50),
		@FromMenuId smallint = 0,
		@MenuId smallint = null OUTPUT
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

/****** Object:  StoredProcedure [Task].[proc_Mode]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_Mode] 
	(
	@TaskCode nvarchar(20)
	)
  AS
	SELECT     Task.tbTask.AccountCode, Task.tbTask.ActivityCode, Task.tbTask.TaskStatusCode, Task.tbTask.ActionOn, Task.vwCashMode.CashModeCode
	FROM         Task.tbTask LEFT OUTER JOIN
	                      Task.vwCashMode ON Task.tbTask.TaskCode = Task.vwCashMode.TaskCode
	WHERE     ( Task.tbTask.TaskCode = @TaskCode)
	RETURN
GO

/****** Object:  StoredProcedure [Activity].[proc_Mode]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

/*****************************************************
Stored Procedures
*****************************************************/

CREATE PROCEDURE [Activity].[proc_Mode]
	(
	@ActivityCode nvarchar(50)
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

/****** Object:  StoredProcedure [App].[proc_NewCompany]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE OR ALTER PROCEDURE [App].[proc_NewCompany]
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
	@WebSite nvarchar(128) = null,
	@SqlDataVersion real
	)
  AS
DECLARE @UserId nvarchar(10)
DECLARE @CalendarCode nvarchar(10)
DECLARE @MenuId smallint

DECLARE @AppAccountCode nvarchar(10)
DECLARE @TaxCode nvarchar(10)
DECLARE @AddressCode nvarchar(15)
	
	SELECT TOP 1 @MenuId = MenuId FROM Usr.tbMenu
	SELECT TOP 1 @CalendarCode = CalendarCode FROM App.tbCalendar 

	SET @UserId = UPPER(left(@FirstNames, 1)) + UPPER(left(@LastName, 1))
	INSERT INTO Usr.tbUser
	                      (UserId, UserName, LogonName, CalendarCode, PhoneNumber, FaxNumber, EmailAddress, Administrator)
	VALUES     (@UserId, @FirstNames + N' ' + @LastName, SUSER_SNAME(), @CalendarCode, @LandLine, @Fax, @Email, 1)

	INSERT INTO Usr.tbMenuUser
	                      (UserId, MenuId)
	VALUES     (@UserId, @MenuId)

	SET @AppAccountCode = left(@AccountCode, 10)
	SET @TaxCode = 'T0'
	
	INSERT INTO Org.tbOrg
	                      (AccountCode, AccountName, OrganisationTypeCode, OrganisationStatusCode, PhoneNumber, FaxNumber, EmailAddress, WebSite, CompanyNumber, 
	                      VatNumber, TaxCode)
	VALUES     (@AppAccountCode, @CompanyName, 8, 1, @LandLine, @Fax, @Email, @Website, @CompanyNumber, @VatNumber, @TaxCode)

	EXEC Org.proc_NextAddressCode @AppAccountCode, @AddressCode output
	
	INSERT INTO Org.tbAddress (AddressCode, AccountCode, Address)
	VALUES (@AddressCode, @AppAccountCode, @CompanyAddress)

	INSERT INTO Org.tbContact
	                      (AccountCode, ContactName, FileAs, NickName, PhoneNumber, FaxNumber, EmailAddress)
	VALUES     (@AppAccountCode, @FirstNames + N' ' + @LastName, @LastName + N', ' + @FirstNames, @FirstNames, @LandLine, @Fax, @Email)	 

	INSERT INTO Org.tbAccount
						(AccountCode, CashAccountCode, CashAccountName)
	VALUES     (@AccountCode, N'CASH', N'Petty Cash')	

	INSERT INTO App.tbOptions
						(Identifier, Initialised, SQLDataVersion, AccountCode, DefaultPrintMode, BucketTypeCode, BucketIntervalCode, ShowCashGraphs)
	VALUES     (N'TC', 0, @SQLDataVersion, @AppAccountCode, 2, 1, 1, 1)
	
	UPDATE Cash.tbTaxType
	SET CashCode = N'900'
	WHERE TaxTypeCode = 2
	
	UPDATE Cash.tbTaxType
	SET CashCode = N'902'
	WHERE TaxTypeCode = 0
	
	UPDATE Cash.tbTaxType
	SET CashCode = N'901'
	WHERE TaxTypeCode = 1
	
	UPDATE Cash.tbTaxType
	SET CashCode = N'903'
	WHERE TaxTypeCode = 3
	
	RETURN
GO

/****** Object:  StoredProcedure [Org].[proc_NextAddressCode]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Org].[proc_NextAddressCode] 
	(
	@AccountCode nvarchar(10),
	@AddressCode nvarchar(15) OUTPUT
	)
  AS
DECLARE @AddCount int

	SELECT @AddCount = COUNT(AddressCode) 
	FROM         Org.tbAddress
	WHERE     (AccountCode = @AccountCode)
	
	SET @AddCount += @AddCount
	SET @AddressCode = CONCAT(UPPER(@AccountCode), '_', FORMAT(@AddCount, '000'))
	
	RETURN
GO

/****** Object:  StoredProcedure [Task].[proc_NextAttributeOrder]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_NextAttributeOrder] 
	(
	@TaskCode nvarchar(20),
	@PrintOrder smallint = 10 output
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

/****** Object:  StoredProcedure [Activity].[proc_NextAttributeOrder]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Activity].[proc_NextAttributeOrder] 
	(
	@ActivityCode nvarchar(50),
	@PrintOrder smallint = 10 output
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

/****** Object:  StoredProcedure [Task].[proc_NextCode]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_NextCode]
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

/****** Object:  StoredProcedure [Task].[proc_NextOperationNumber]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_NextOperationNumber] 
	(
	@TaskCode nvarchar(20),
	@OperationNumber smallint = 10 output
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

/****** Object:  StoredProcedure [Activity].[proc_NextOperationNumber]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Activity].[proc_NextOperationNumber] 
	(
	@ActivityCode nvarchar(50),
	@OperationNumber smallint = 10 output
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

/****** Object:  StoredProcedure [Activity].[proc_NextStepNumber]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Activity].[proc_NextStepNumber] 
	(
	@ActivityCode nvarchar(50),
	@StepNumber smallint = 10 output
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

/****** Object:  StoredProcedure [Task].[proc_Op]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_Op]
	(
	@TaskCode nvarchar(20)
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

/****** Object:  StoredProcedure [Activity].[proc_Parent]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Activity].[proc_Parent]
	(
	@ActivityCode nvarchar(50),
	@ParentCode nvarchar(50) = null output
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

/****** Object:  StoredProcedure [Task].[proc_Parent]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_Parent] 
	(
	@TaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20) output
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

/****** Object:  StoredProcedure [Invoice].[proc_Pay]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Invoice].[proc_Pay]
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

	SELECT @UserId = UserId FROM Usr.vwCredentials	

	SET @PaymentCode = @UserId + '_' + FORMAT(Year(@Now), '0000')
		+ FORMAT(Month(@Now), '00')
		+ FORMAT(Day(@Now), '00')
		+ FORMAT(DatePart(hh, @Now), '00')
		+ FORMAT(DatePart(n, @Now), '00')
		+ FORMAT(DatePart(s, @Now), '00')
	
	WHILE EXISTS (SELECT PaymentCode FROM Org.tbPayment WHERE PaymentCode = @PaymentCode)
		BEGIN
		SET @Now = DATEADD(s, 1, @Now)
		SET @PaymentCode = @UserId + '_' + FORMAT(Year(@Now), '0000')
			+ FORMAT(Month(@Now), '00')
			+ FORMAT(Day(@Now), '00')
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
	
	IF @PaidIn + @PaidOut > 0
		BEGIN
		SELECT TOP 1 @CashAccountCode = Org.tbAccount.CashAccountCode
		FROM         Org.tbAccount INNER JOIN
		                      Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
		WHERE     ( Org.tbAccount.AccountClosed = 0)
		GROUP BY Org.tbAccount.CashAccountCode
		
		INSERT INTO Org.tbPayment
							  (PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, PaidOn, PaidInValue, PaidOutValue, PaymentReference)
		VALUES     (@PaymentCode,@UserId, 0, @AccountCode, @CashAccountCode, @CashCode, @Now, @PaidIn, @PaidOut, @InvoiceNumber)		
		
		EXEC Org.proc_PaymentPostInvoiced @PaymentCode			
		END
		
	RETURN
GO

/****** Object:  StoredProcedure [Org].[proc_PaymentDelete]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Org].[proc_PaymentDelete]
	(
	@PaymentCode nvarchar(20)
	)
 AS
DECLARE @AccountCode nvarchar(10)
DECLARE @CashAccountCode nvarchar(10)

	SELECT  @AccountCode = AccountCode, @CashAccountCode = CashAccountCode
	FROM         Org.tbPayment
	WHERE     (PaymentCode = @PaymentCode)

	DELETE FROM Org.tbPayment
	WHERE     (PaymentCode = @PaymentCode)
	
	EXEC Org.proc_Rebuild @AccountCode
	EXEC Cash.proc_AccountRebuild @CashAccountCode
	

	RETURN 
GO

/****** Object:  StoredProcedure [Org].[proc_PaymentMove]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Org].[proc_PaymentMove]
	(
	@PaymentCode nvarchar(20),
	@CashAccountCode nvarchar(10)
	)
  AS
DECLARE @OldAccountCode nvarchar(10)

	SELECT @OldAccountCode = CashAccountCode
	FROM         Org.tbPayment
	WHERE     (PaymentCode = @PaymentCode)
	
	BEGIN TRAN
	
	UPDATE Org.tbPayment 
	SET CashAccountCode = @CashAccountCode,
		UpdatedOn = CURRENT_TIMESTAMP,
		UpdatedBy = (suser_sname())
	WHERE PaymentCode = @PaymentCode	

	EXEC Cash.proc_AccountRebuild @CashAccountCode
	EXEC Cash.proc_AccountRebuild @OldAccountCode
	
	COMMIT TRAN
	
	RETURN 
GO

/****** Object:  StoredProcedure [Org].[proc_PaymentPost]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Org].[proc_PaymentPost] 
  AS
DECLARE @PaymentCode nvarchar(20)

	DECLARE curMisc cursor local for
		SELECT     PaymentCode
		FROM         Org.tbPayment
		WHERE     (PaymentStatusCode = 0) AND (NOT (CashCode IS NULL))
		ORDER BY AccountCode, PaidOn

	DECLARE curInv cursor local for
		SELECT     PaymentCode
		FROM         Org.tbPayment
		WHERE     (PaymentStatusCode = 0) AND (CashCode IS NULL)
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

/****** Object:  StoredProcedure [Org].[proc_PaymentPostInvoiced]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Org].[proc_PaymentPostInvoiced]
	(
	@PaymentCode nvarchar(20) 
	)
  AS
DECLARE @AccountCode nvarchar(10)
DECLARE @CashModeCode smallint
DECLARE @CurrentBalance money
DECLARE @PaidValue money
DECLARE @PostValue money

	SELECT   @PaidValue = CASE WHEN PaidInValue = 0 THEN PaidOutValue ELSE PaidInValue END,
		@CurrentBalance = Org.tbOrg.CurrentBalance,
		@AccountCode = Org.tbOrg.AccountCode,
		@CashModeCode = CASE WHEN PaidInValue = 0 THEN 0 ELSE 1 END
	FROM         Org.tbPayment INNER JOIN
	                      Org.tbOrg ON Org.tbPayment.AccountCode = Org.tbOrg.AccountCode
	WHERE     ( Org.tbPayment.PaymentCode = @PaymentCode)
	
	IF @CashModeCode = 1
		BEGIN
		SET @PostValue = @PaidValue
		SET @PaidValue = (@PaidValue + @CurrentBalance) * -1			
		EXEC Org.proc_PaymentPostPaidIn @PaymentCode, @PaidValue output
		END
	ELSE
		BEGIN
		SET @PostValue = @PaidValue * -1
		SET @PaidValue = @PaidValue + (@CurrentBalance * -1)			
		EXEC Org.proc_PaymentPostPaidOut @PaymentCode, @PaidValue output
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

/****** Object:  StoredProcedure [Org].[proc_PaymentPostMisc]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Org].[proc_PaymentPostMisc]
	(
	@PaymentCode nvarchar(20) 
	)
 AS
DECLARE @InvoiceNumber nvarchar(20)
DECLARE @UserId nvarchar(10)
DECLARE @NextNumber int
DECLARE @InvoiceSuffix nvarchar(4)
DECLARE @InvoiceTypeCode smallint

	SELECT @InvoiceTypeCode = CASE WHEN PaidInValue != 0 THEN 0 ELSE 2 END 
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
	SELECT        @InvoiceNumber AS InvoiceNumber, Org.tbPayment.UserId, Org.tbPayment.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, 3 AS InvoiceStatusCode, 
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
	SET		PaymentStatusCode = 1,
		TaxInValue = PaidInValue - ROUND((PaidInValue / (1 + TaxRate)), 2), 
		TaxOutValue = PaidOutValue - ROUND((PaidOutValue / (1 + TaxRate)), 2)
	FROM         Org.tbPayment INNER JOIN
	                      App.vwTaxRates ON Org.tbPayment.TaxCode = App.vwTaxRates.TaxCode
	WHERE     (PaymentCode = @PaymentCode)
	
	RETURN

GO

/****** Object:  StoredProcedure [Org].[proc_PaymentPostPaidIn]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Org].[proc_PaymentPostPaidIn]
	(
	@PaymentCode nvarchar(20),
	@CurrentBalance money output 
	)
 AS
--invoice VALUES
DECLARE @InvoiceNumber nvarchar(20)
DECLARE @TaskCode nvarchar(20)
DECLARE @TaxRate real
DECLARE @ItemValue money

--calc VALUES
DECLARE @PaidValue money
DECLARE @PaidTaxValue money

--default payment codes
DECLARE @CashCode nvarchar(50)
DECLARE @TaxCode nvarchar(10)
DECLARE @TaxInValue money
DECLARE @TaxOutValue money

	SET @TaxInValue = 0
	SET @TaxOutValue = 0
	
	DECLARE curPaidIn cursor local for
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
	
	--output new org current balance
	IF @CurrentBalance >= 0
		SET @CurrentBalance = 0
	ELSE
		SET @CurrentBalance = @CurrentBalance * -1

	
	IF NOT @CashCode IS NULL
		BEGIN
		UPDATE    Org.tbPayment
		SET      PaymentStatusCode = 1, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
			CashCode = isnull(@CashCode, Org.tbPayment.CashCode), 
			TaxCode = isnull(@TaxCode, Org.tbPayment.TaxCode)
		WHERE     (PaymentCode = @PaymentCode)
		END

			
	RETURN

GO

/****** Object:  StoredProcedure [Org].[proc_PaymentPostPaidOut]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Org].[proc_PaymentPostPaidOut]
	(
	@PaymentCode nvarchar(20),
	@CurrentBalance money output 
	)
 AS
--invoice VALUES
DECLARE @InvoiceNumber nvarchar(20)
DECLARE @TaskCode nvarchar(20)
DECLARE @TaxRate real
DECLARE @ItemValue money

--calc VALUES
DECLARE @PaidValue money
DECLARE @PaidTaxValue money

--default payment codes
DECLARE @CashCode nvarchar(50)
DECLARE @TaxCode nvarchar(10)
DECLARE @TaxInValue money
DECLARE @TaxOutValue money

	SET @TaxInValue = 0
	SET @TaxOutValue = 0
	
	DECLARE curPaidOut cursor local for
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
	
	--output new org current balance
	IF @CurrentBalance <= 0
		SET @CurrentBalance = 0
	ELSE
		SET @CurrentBalance = @CurrentBalance * -1

	IF NOT @CashCode IS NULL
		BEGIN
		UPDATE    Org.tbPayment
		SET      PaymentStatusCode = 1, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
			CashCode = isnull(@CashCode, Org.tbPayment.CashCode), 
			TaxCode = isnull(@TaxCode, Org.tbPayment.TaxCode)
		WHERE     (PaymentCode = @PaymentCode)
		END
	
	RETURN

GO

/****** Object:  StoredProcedure [App].[proc_PeriodClose]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [App].[proc_PeriodClose]
   AS

	IF EXISTS(SELECT * FROM App.fnActivePeriod())
		BEGIN
		DECLARE @StartOn datetime
		DECLARE @YearNumber smallint
		
		SELECT @StartOn = StartOn, @YearNumber = YearNumber
		FROM App.fnActivePeriod() fnSystemActivePeriod
		 		
		BEGIN TRAN
	
		UPDATE App.tbYearPeriod
		SET CashStatusCode = 2
		WHERE StartOn = @StartOn			
		
		IF not EXISTS (SELECT     CashStatusCode
					FROM         App.tbYearPeriod
					WHERE     (YearNumber = @YearNumber) AND (CashStatusCode < 2)) 
			BEGIN
			UPDATE App.tbYear
			SET CashStatusCode = 2
			WHERE YearNumber = @YearNumber	
			END
		IF EXISTS(SELECT * FROM App.fnActivePeriod())
			BEGIN
			UPDATE App.tbYearPeriod
			SET CashStatusCode = 1
			FROM App.fnActivePeriod() fnSystemActivePeriod INNER JOIN
								App.tbYearPeriod ON fnSystemActivePeriod.YearNumber = App.tbYearPeriod.YearNumber AND fnSystemActivePeriod.MonthNumber = App.tbYearPeriod.MonthNumber
			
			END		
		IF EXISTS(SELECT * FROM App.fnActivePeriod())
			BEGIN
			UPDATE App.tbYear
			SET CashStatusCode = 1
			FROM App.fnActivePeriod() fnSystemActivePeriod INNER JOIN
								App.tbYear ON fnSystemActivePeriod.YearNumber = App.tbYear.YearNumber  
			END
		COMMIT TRAN
		END
					
	RETURN
GO

/****** Object:  StoredProcedure [App].[proc_PeriodGetYear]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [App].[proc_PeriodGetYear]
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

/****** Object:  StoredProcedure [Task].[proc_Profit]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_Profit]
	(
	@ParentTaskCode nvarchar(20),
	@TotalCost money = 0 output,
	@InvoicedCost money = 0 output,
	@InvoicedCostPaid money = 0 output
	)
AS
DECLARE @TaskCode nvarchar(20)
DECLARE @TotalCharge money
DECLARE @TotalInvoiced money
DECLARE @TotalPaid money
DECLARE @CashModeCode smallint

	DECLARE curFlow cursor local for
		SELECT     Task.tbTask.TaskCode, Task.vwCashMode.CashModeCode, Task.tbTask.TotalCharge
		FROM         Task.tbTask INNER JOIN
							  Task.tbFlow ON Task.tbTask.TaskCode = Task.tbFlow.ChildTaskCode INNER JOIN
							  Task.vwCashMode ON Task.tbTask.TaskCode = Task.vwCashMode.TaskCode
		WHERE     ( Task.tbFlow.ParentTaskCode = @ParentTaskCode)	

	OPEN curFlow
	FETCH NEXT FROM curFlow INTO @TaskCode, @CashModeCode, @TotalCharge
	WHILE @@FETCH_STATUS = 0
		BEGIN
		
		SELECT  @TotalInvoiced = SUM(CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.InvoiceValue * - 1 ELSE Invoice.tbTask.InvoiceValue END), 
				@TotalPaid = SUM(CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.PaidValue * - 1 ELSE Invoice.tbTask.PaidValue END) 	                      
		FROM         Invoice.tbTask INNER JOIN
							  Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		WHERE     ( Invoice.tbTask.TaskCode = @TaskCode)

		SET @InvoicedCost = @InvoicedCost + @TotalInvoiced
		SET @InvoicedCostPaid = @InvoicedCostPaid + @TotalPaid
		SET @TotalCost = @TotalCost + CASE WHEN @CashModeCode = 0 THEN @TotalCharge ELSE @TotalCharge * -1 END
			
		EXEC Task.proc_Profit @TaskCode, @TotalCost output, @InvoicedCost output, @InvoicedCostPaid output
		FETCH NEXT FROM curFlow INTO @TaskCode, @CashModeCode, @TotalCharge
		END
	
	CLOSE curFlow
	DEALLOCATE curFlow
	RETURN

GO

/****** Object:  StoredProcedure [Task].[proc_ProfitTopLevel]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_ProfitTopLevel]
	(
	@TaskCode nvarchar(20),
	@InvoicedCharge money = 0 output,
	@InvoicedChargePaid money = 0 output,
	@TotalCost money = 0 output,
	@InvoicedCost money = 0 output,
	@InvoicedCostPaid money = 0 output
	)
AS
			
	SELECT  @InvoicedCharge = SUM(CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.InvoiceValue * - 1 ELSE Invoice.tbTask.InvoiceValue END), 
	@InvoicedChargePaid = SUM(CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.PaidValue * - 1 ELSE Invoice.tbTask.PaidValue END) 	                      
	FROM         Invoice.tbTask INNER JOIN
	                      Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
	                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	WHERE     ( Invoice.tbTask.TaskCode = @TaskCode)
	
	SET @TotalCost = 0
	EXEC Task.proc_Profit @TaskCode, @TotalCost output, @InvoicedCost output, @InvoicedCostPaid output	
	
	RETURN

GO

/****** Object:  StoredProcedure [Task].[proc_Project]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_Project] 
	(
	@TaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20) output
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

/****** Object:  StoredProcedure [Invoice].[proc_Raise]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Invoice].[proc_Raise]
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
DECLARE @CollectOn datetime
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
	
	SET @CollectOn = Task.fnDefaultPaymentOn(@AccountCode, @InvoicedOn)
	
	BEGIN TRAN Invoice
	
	EXEC Invoice.proc_Cancel
	
	UPDATE    Invoice.tbType
	SET              NextNumber = @NextNumber + 1
	WHERE     (InvoiceTypeCode = @InvoiceTypeCode)
	
	INSERT INTO Invoice.tbInvoice
						(InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoicedOn, CollectOn, InvoiceStatusCode, PaymentTerms)
	SELECT     @InvoiceNumber AS InvoiceNumber, @UserId AS UserId, Task.tbTask.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, @InvoicedOn AS InvoicedOn, 
						@CollectOn AS CollectOn, 0 AS InvoiceStatusCode, 
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

/****** Object:  StoredProcedure [Invoice].[proc_RaiseBlank]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Invoice].[proc_RaiseBlank]
	(
	@AccountCode nvarchar(10),
	@InvoiceTypeCode smallint,
	@InvoiceNumber nvarchar(20) = null output
	)
  AS
DECLARE @UserId nvarchar(10)
DECLARE @NextNumber int
DECLARE @InvoiceSuffix nvarchar(4)

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
	VALUES     (@InvoiceNumber, @UserId, @AccountCode, @InvoiceTypeCode, CURRENT_TIMESTAMP, 0)

	
	COMMIT TRAN InvoiceBlank
	
	RETURN
GO

/****** Object:  StoredProcedure [App].[proc_ReassignUser]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [App].[proc_ReassignUser] 
	(
	@UserId nvarchar(10)
	)
  AS
	UPDATE    Usr.tbUser
	SET       LogonName = (SUSER_SNAME())
	WHERE     (UserId = @UserId)
	
	RETURN
GO

/****** Object:  StoredProcedure [Org].[proc_Rebuild]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Org].[proc_Rebuild]
	(
		@AccountCode nvarchar(10)
	)
 AS
DECLARE @PaidBalance money
DECLARE @InvoicedBalance money
DECLARE @Balance money

DECLARE @CashModeCode smallint	

DECLARE @InvoiceNumber nvarchar(20)
DECLARE @TaskCode nvarchar(20)
DECLARE @CashCode nvarchar(50)
DECLARE @InvoiceValue money
DECLARE @TaxValue money	

DECLARE @PaidValue money
DECLARE @PaidInvoiceValue money
DECLARE @PaidTaxValue money
DECLARE @TaxRate float	

	BEGIN TRAN OrgRebuild
		
	UPDATE Invoice.tbItem
	SET TaxValue = ROUND( Invoice.tbItem.InvoiceValue * App.vwTaxRates.TaxRate, 2),
		PaidValue = Invoice.tbItem.InvoiceValue, 
		PaidTaxValue = ROUND( Invoice.tbItem.InvoiceValue * App.vwTaxRates.TaxRate, 2)				
	FROM         Invoice.tbItem INNER JOIN
	                      App.vwTaxRates ON Invoice.tbItem.TaxCode = App.vwTaxRates.TaxCode INNER JOIN
	                      Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
	WHERE     ( Invoice.tbInvoice.AccountCode = @AccountCode) AND ( Invoice.tbInvoice.InvoiceStatusCode <> 0)	
                      
	UPDATE Invoice.tbTask
	SET TaxValue = ROUND( Invoice.tbTask.InvoiceValue * App.vwTaxRates.TaxRate, 2),
		PaidValue = Invoice.tbTask.InvoiceValue, PaidTaxValue = ROUND( Invoice.tbTask.InvoiceValue * App.vwTaxRates.TaxRate, 2)
	FROM         Invoice.tbTask INNER JOIN
	                      App.vwTaxRates ON Invoice.tbTask.TaxCode = App.vwTaxRates.TaxCode INNER JOIN
	                      Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
	WHERE     ( Invoice.tbInvoice.AccountCode = @AccountCode) AND ( Invoice.tbInvoice.InvoiceStatusCode <> 0)	
	
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
	SET              PaidValue = InvoiceValue, PaidTaxValue = TaxValue, InvoiceStatusCode = 3
	WHERE     (AccountCode = @AccountCode) AND (InvoiceStatusCode <> 0)		

	
	UPDATE Org.tbPayment
	SET
		TaxInValue = PaidInValue - ROUND((PaidInValue / (1 + TaxRate)), 2), 
		TaxOutValue = PaidOutValue - ROUND((PaidOutValue / (1 + TaxRate)), 2)
	FROM         Org.tbPayment INNER JOIN
	                      App.vwTaxRates ON Org.tbPayment.TaxCode = App.vwTaxRates.TaxCode
	WHERE     ( Org.tbPayment.AccountCode = @AccountCode)
		

	SELECT  @PaidBalance = SUM(CASE WHEN PaidInValue > 0 THEN PaidInValue * -1 ELSE PaidOutValue  END)
	FROM         Org.tbPayment
	WHERE     (AccountCode = @AccountCode) And (PaymentStatusCode <> 0)
	
	SELECT @PaidBalance = isnull(@PaidBalance, 0) + OpeningBalance
	FROM Org.tbOrg
	WHERE     (AccountCode = @AccountCode)

	SELECT @InvoicedBalance = SUM(CASE Invoice.tbType.CashModeCode WHEN 0 THEN (InvoiceValue + TaxValue) * - 1 WHEN 1 THEN InvoiceValue + TaxValue ELSE 0 END) 
	FROM         Invoice.tbInvoice INNER JOIN
	                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	WHERE     ( Invoice.tbInvoice.AccountCode = @AccountCode)
	
	SET @Balance = isnull(@PaidBalance, 0) + isnull(@InvoicedBalance, 0)
                      
    SET @CashModeCode = CASE WHEN @Balance > 0 THEN 1 ELSE 0 END
	SET @Balance = Abs(@Balance)	

	DECLARE curInv cursor local for
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
			
		IF isnull(@TaskCode, '') = ''
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
	SET InvoiceStatusCode = 2,
		PaidValue = Org.vwRebuildInvoiceTotals.TotalPaidValue, 
		PaidTaxValue = Org.vwRebuildInvoiceTotals.TotalPaidTaxValue
	FROM         Invoice.tbInvoice INNER JOIN
						Org.vwRebuildInvoiceTotals ON Invoice.tbInvoice.InvoiceNumber = Org.vwRebuildInvoiceTotals.InvoiceNumber
	WHERE     (Org.vwRebuildInvoiceTotals.AccountCode = @AccountCode) AND 
						((Org.vwRebuildInvoiceTotals.TotalInvoiceValue + Org.vwRebuildInvoiceTotals.TotalTaxValue) 
						- (Org.vwRebuildInvoiceTotals.TotalPaidValue + Org.vwRebuildInvoiceTotals.TotalPaidTaxValue) > 0) AND 
						(Org.vwRebuildInvoiceTotals.TotalPaidValue + Org.vwRebuildInvoiceTotals.TotalPaidTaxValue < Org.vwRebuildInvoiceTotals.TotalInvoiceValue + Org.vwRebuildInvoiceTotals.TotalTaxValue)
	
	UPDATE Invoice.tbInvoice
	SET InvoiceStatusCode = 1,
		PaidValue = 0, 
		PaidTaxValue = 0
	FROM         Invoice.tbInvoice INNER JOIN
	                      Org.vwRebuildInvoiceTotals ON Invoice.tbInvoice.InvoiceNumber = Org.vwRebuildInvoiceTotals.InvoiceNumber
	WHERE     (Org.vwRebuildInvoiceTotals.AccountCode = @AccountCode) AND 
	                      (Org.vwRebuildInvoiceTotals.TotalPaidValue + Org.vwRebuildInvoiceTotals.TotalPaidTaxValue = 0) AND 
	                      (Org.vwRebuildInvoiceTotals.TotalInvoiceValue + Org.vwRebuildInvoiceTotals.TotalTaxValue > 0)
	
	
	IF (@CashModeCode = 1)
		SET @Balance = @Balance * -1
		
	UPDATE    Org.tbOrg
	SET              CurrentBalance = OpeningBalance - @Balance
	WHERE     (AccountCode = @AccountCode)
	
	COMMIT TRAN OrgRebuild
	

	RETURN 

GO

/****** Object:  StoredProcedure [Task].[proc_ReconcileCharge]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_ReconcileCharge]
	(
	@TaskCode nvarchar(20)
	)
AS
DECLARE @InvoiceValue money

	SELECT @InvoiceValue = SUM(InvoiceValue)
	FROM         Invoice.tbTask
	WHERE     (TaskCode = @TaskCode)

	UPDATE    Task.tbTask
	SET              TotalCharge = @InvoiceValue, UnitCharge = @InvoiceValue / Quantity
	WHERE     (TaskCode = @TaskCode)	
	
	RETURN
GO

/****** Object:  StoredProcedure [Task].[proc_ResetChargedUninvoiced]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_ResetChargedUninvoiced]
AS
	UPDATE       Task
	SET                TaskStatusCode = 2
	FROM            Cash.tbCode INNER JOIN
							 Task.tbTask AS Task ON Cash.tbCode.CashCode = Task.CashCode LEFT OUTER JOIN
							 Invoice.tbTask AS InvoiceTask ON Task.TaskCode = InvoiceTask.TaskCode AND Task.TaskCode = InvoiceTask.TaskCode
	WHERE        (InvoiceTask.InvoiceNumber IS NULL) AND (Task.TaskStatusCode = 3)
	RETURN
GO

/****** Object:  StoredProcedure [Task].[proc_Schedule]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE  PROCEDURE [Task].[proc_Schedule]
	(
	@ParentTaskCode nvarchar(20),
	@ActionOn datetime = null output
	)
   AS
DECLARE @UserId nvarchar(10)
DECLARE @AccountCode nvarchar(10)
DECLARE @StepNumber smallint
DECLARE @TaskCode nvarchar(20)
DECLARE @OffsetDays smallint
DECLARE @UsedOnQuantity float
DECLARE @Quantity float
DECLARE @PaymentDays smallint
DECLARE @PaymentOn datetime

	IF @ActionOn is null
		BEGIN				
		SELECT @ActionOn = ActionOn, @UserId = ActionById 
		FROM Task.tbTask WHERE TaskCode = @ParentTaskCode
		
		IF @ActionOn != App.fnAdjustToCalendar(@UserId, @ActionOn, 0)
			BEGIN
			SET @ActionOn = App.fnAdjustToCalendar(@UserId, @ActionOn, 0)
			UPDATE Task.tbTask
			SET ActionOn = @ActionOn
			WHERE TaskCode = @ParentTaskCode and TaskStatusCode < 2			
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
		WHERE TaskCode = @ParentTaskCode and TaskStatusCode < 2
		END
	
	IF EXISTS(SELECT TOP 1 OperationNumber
	          FROM         Task.tbOp
	          WHERE     (TaskCode = @ParentTaskCode))
		BEGIN
		EXEC Task.proc_ScheduleOp @ParentTaskCode, @ActionOn
		END
	
	Select @Quantity = Quantity FROM Task.tbTask WHERE TaskCode = @ParentTaskCode
	
	DECLARE curAct cursor local for
		SELECT     Task.tbFlow.StepNumber, Task.tbFlow.ChildTaskCode, Task.tbTask.AccountCode, Task.tbTask.ActionById, Task.tbFlow.OffsetDays, Task.tbFlow.UsedOnQuantity, 
		                      Org.tbOrg.PaymentDays
		FROM         Task.tbFlow INNER JOIN
		                      Task.tbTask ON Task.tbFlow.ChildTaskCode = Task.tbTask.TaskCode INNER JOIN
		                      Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode
		WHERE     ( Task.tbFlow.ParentTaskCode = @ParentTaskCode)
		ORDER BY Task.tbFlow.StepNumber DESC
	
	OPEN curAct
	FETCH NEXT FROM curAct INTO @StepNumber, @TaskCode, @AccountCode, @UserId, @OffsetDays, @UsedOnQuantity, @PaymentDays
	WHILE @@FETCH_STATUS = 0
		BEGIN
		SET @ActionOn = App.fnAdjustToCalendar(@UserId, @ActionOn, @OffsetDays)
		SET @PaymentOn = Task.fnDefaultPaymentOn(@AccountCode, @ActionOn)
		
		UPDATE Task.tbTask
		SET ActionOn = @ActionOn, 
			PaymentOn = @PaymentOn,
			Quantity = @Quantity * @UsedOnQuantity,
			TotalCharge = CASE WHEN @UsedOnQuantity = 0 THEN UnitCharge ELSE UnitCharge * @Quantity * @UsedOnQuantity END,
			UpdatedOn = CURRENT_TIMESTAMP,
			UpdatedBy = (suser_sname())
		WHERE TaskCode = @TaskCode and TaskStatusCode < 2
		
		EXEC Task.proc_Schedule @TaskCode, @ActionOn output
		FETCH NEXT FROM curAct INTO @StepNumber, @TaskCode, @AccountCode, @UserId, @OffsetDays, @UsedOnQuantity, @PaymentDays
		END
	
	CLOSE curAct
	DEALLOCATE curAct	
	
	RETURN
GO

/****** Object:  StoredProcedure [Task].[proc_ScheduleOp]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_ScheduleOp]
	(
	@TaskCode nvarchar(20),
	@ActionOn datetime
	)	
AS
DECLARE @OperationNumber smallint
DECLARE @OpStatusCode smallint
DECLARE @CallOffOpNo smallint

DECLARE @EndOn datetime
DECLARE @StartOn datetime
DECLARE @OffsetDays smallint

DECLARE @UserId nvarchar(10)
	
	SELECT @UserId = ActionById
	FROM Task.tbTask WHERE TaskCode = @TaskCode	
	
	SET @EndOn = @ActionOn

	SELECT @CallOffOpNo = MIN(OperationNumber)
	FROM         Task.tbOp
	WHERE     (TaskCode = @TaskCode) AND (OpTypeCode = 1)	
	
	SET @CallOffOpNo = isnull(@CallOffOpNo, 0)
	
	DECLARE curOp cursor local for
		SELECT     OperationNumber, OffsetDays, OpStatusCode, EndOn
		FROM         Task.tbOp
		WHERE     (TaskCode = @TaskCode) AND ((OperationNumber <= @CallOffOpNo) OR (@CallOffOpNo = 0)) 
		ORDER BY OperationNumber DESC
	
	OPEN curOp
	FETCH NEXT FROM curOp INTO @OperationNumber, @OffsetDays, @OpStatusCode, @ActionOn
	WHILE @@FETCH_STATUS = 0
		BEGIN			
		IF (@OpStatusCode < 2 ) 
			BEGIN
			SET @StartOn = App.fnAdjustToCalendar(@UserId, @EndOn, @OffsetDays)
			UPDATE Task.tbOp
			SET EndOn = @EndOn, StartOn = @StartOn
			WHERE TaskCode = @TaskCode and OperationNumber = @OperationNumber			
			END
		ELSE
			BEGIN			
			SET @StartOn = App.fnAdjustToCalendar(@UserId, @ActionOn, @OffsetDays)
			END
		SET @EndOn = @StartOn			
		FETCH NEXT FROM curOp INTO @OperationNumber, @OffsetDays, @OpStatusCode, @ActionOn
		END
	CLOSE curOp
	DEALLOCATE curOp
	
	RETURN
GO

/****** Object:  StoredProcedure [Task].[proc_SetActionOn]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_SetActionOn]
	(
	@TaskCode nvarchar(20)
	)
AS
DECLARE @OperationNumber smallint
DECLARE @OpTypeCode smallint
DECLARE @ActionOn datetime
		
	SELECT @OperationNumber = MAX(OperationNumber)
	FROM         Task.tbOp
	WHERE     (TaskCode = @TaskCode)
	
	
	SELECT @OpTypeCode = OpTypeCode, @ActionOn = EndOn
	FROM         Task.tbOp
	WHERE     (TaskCode = @TaskCode) AND (OperationNumber = @OperationNumber)

	IF @OpTypeCode = 1
		BEGIN
		SELECT @OperationNumber = MIN(OperationNumber)
		FROM         Task.tbOp
		WHERE     (TaskCode = @TaskCode) AND (OpTypeCode = 1)
		
		SELECT @ActionOn = EndOn
		FROM         Task.tbOp
		WHERE     (TaskCode = @TaskCode) AND (OperationNumber = @OperationNumber)
				
		END
		
	UPDATE    Task.tbTask
	SET              ActionOn = @ActionOn
	WHERE     (TaskCode = @TaskCode) AND (ActionOn <> @ActionOn)

		
	RETURN
GO

/****** Object:  StoredProcedure [Task].[proc_SetOpStatus]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_SetOpStatus]
	(
		@TaskCode nvarchar(20),
		@TaskStatusCode smallint
	)
AS
DECLARE @OpStatusCode smallint
DECLARE @OperationNumber smallint
	
	SET @OpStatusCode = CASE @TaskStatusCode
							WHEN 0 THEN 0
							WHEN 1 THEN 1
							ELSE 2
						END
	
	IF EXISTS(SELECT TOP 1 OperationNumber
	          FROM         Task.tbOp
	          WHERE     (TaskCode = @TaskCode))
		BEGIN
		UPDATE    Task.tbOp
		SET              OpStatusCode = @OpStatusCode
		WHERE     (OpTypeCode = 0) AND (TaskCode = @TaskCode)
		
		IF EXISTS (SELECT TOP 1 OperationNumber
	          FROM         Task.tbOp
	          WHERE     (TaskCode = @TaskCode) AND (OpTypeCode = 1))
	        BEGIN
			SELECT @OperationNumber = MIN(OperationNumber)
			FROM         Task.tbOp
			WHERE     (OpTypeCode = 1) AND (TaskCode = @TaskCode)	          
				          
			UPDATE    Task.tbOp
			SET              OpStatusCode = @OpStatusCode
			WHERE     (OperationNumber = @OperationNumber) AND (TaskCode = @TaskCode)
	        END
		END
		
	RETURN
GO

/****** Object:  StoredProcedure [Task].[proc_SetStatus]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_SetStatus]
	(
		@TaskCode nvarchar(20)
	)
  AS
DECLARE @ChildTaskCode nvarchar(20)
DECLARE @TaskStatusCode smallint
DECLARE @CashCode nvarchar(20)
DECLARE @IsOrder bit

	SELECT @TaskStatusCode = TaskStatusCode, @CashCode = CashCode
	FROM Task.tbTask
	WHERE TaskCode = @TaskCode
	
	EXEC Task.proc_SetOpStatus @TaskCode, @TaskStatusCode
	
	IF @CashCode IS NULL
		SET @IsOrder = 0
	ELSE
		SET @IsOrder = 1
	
	DECLARE curTask cursor local for
		SELECT     Task.tbFlow.ChildTaskCode
		FROM         Task.tbFlow INNER JOIN
		                      Task.tbTask ON Task.tbFlow.ChildTaskCode = Task.tbTask.TaskCode
		WHERE     ( Task.tbFlow.ParentTaskCode = @TaskCode)

	OPEN curTask
	FETCH NEXT FROM curTask INTO @ChildTaskCode
	WHILE @@FETCH_STATUS = 0
		BEGIN
		
		IF @IsOrder = 1 AND @TaskStatusCode <> 5
			BEGIN
			UPDATE    Task.tbTask
			SET              TaskStatusCode = @TaskStatusCode
			WHERE     (TaskCode = @ChildTaskCode) AND (TaskStatusCode < 2) AND (NOT (CashCode IS NULL))
			EXEC Task.proc_SetOpStatus @ChildTaskCode, @TaskStatusCode
			END
		ELSE IF @IsOrder = 0
			BEGIN
			UPDATE    Task.tbTask
			SET              TaskStatusCode = @TaskStatusCode
			WHERE     (TaskCode = @ChildTaskCode) AND (TaskStatusCode < 2) AND (CashCode IS NULL)			
			END		
		
		IF (@TaskStatusCode <> 3)	
			EXEC Task.proc_SetStatus @ChildTaskCode
		FETCH NEXT FROM curTask INTO @ChildTaskCode
		END
		
	CLOSE curTask
	DEALLOCATE curTask
		
	RETURN 
GO

/****** Object:  StoredProcedure [Org].[proc_Statement]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Org].[proc_Statement]
	(
	@AccountCode nvarchar(10)
	)
  AS
DECLARE @FromDate datetime
	
	SELECT @FromDate = DATEADD(d, StatementDays * -1, CURRENT_TIMESTAMP)
	FROM         Org.tbOrg
	WHERE     (AccountCode = @AccountCode)
	
	SELECT     TransactedOn, OrderBy, Reference, StatementType, Charge, Balance
	FROM         Org.fnStatement(@AccountCode) fnOrgStatement
	WHERE     (TransactedOn >= @FromDate)
	ORDER BY TransactedOn, OrderBy
	
	RETURN 
GO

/****** Object:  StoredProcedure [Cash].[proc_StatementRescheduleOverdue]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Cash].[proc_StatementRescheduleOverdue]
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
	SET CollectOn = Task.fnDefaultPaymentOn( Invoice.tbInvoice.AccountCode, CURRENT_TIMESTAMP) 
	FROM         Invoice.tbInvoice 
	WHERE     ( Invoice.tbInvoice.InvoiceStatusCode = 1 OR
	                      Invoice.tbInvoice.InvoiceStatusCode = 2) AND ( Invoice.tbInvoice.CollectOn < CURRENT_TIMESTAMP)
	
	
	RETURN


GO

/****** Object:  StoredProcedure [Invoice].[proc_Total]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Invoice].[proc_Total] 
	(
	@InvoiceNumber nvarchar(20)
	)
  AS
DECLARE @InvoiceValue money
DECLARE @TaxValue money
DECLARE @PaidValue money
DECLARE @PaidTaxValue money

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

	SELECT  TOP 1 @InvoiceValue = isnull(SUM(InvoiceValue), 0), 
		@TaxValue = isnull(SUM(TaxValue), 0),
		@PaidValue = isnull(SUM(PaidValue), 0), 
		@PaidTaxValue = isnull(SUM(PaidTaxValue), 0)
	FROM         Invoice.tbTask
	GROUP BY InvoiceNumber
	HAVING      (InvoiceNumber = @InvoiceNumber)
	
	SELECT  TOP 1 @InvoiceValue = @InvoiceValue + isnull(SUM(InvoiceValue), 0), 
		@TaxValue = @TaxValue + isnull(SUM(TaxValue), 0),
		@PaidValue = @PaidValue + isnull(SUM(PaidValue), 0), 
		@PaidTaxValue = @PaidTaxValue + isnull(SUM(PaidTaxValue), 0)
	FROM         Invoice.tbItem
	GROUP BY InvoiceNumber
	HAVING      (InvoiceNumber = @InvoiceNumber)
	
	SET @InvoiceValue = Round(@InvoiceValue, 2)
	SET @TaxValue = Round(@TaxValue, 2)
	SET @PaidValue = Round(@PaidValue, 2)
	SET @PaidTaxValue = Round(@PaidTaxValue, 2)
	
		
	UPDATE    Invoice.tbInvoice
	SET              InvoiceValue = isnull(@InvoiceValue, 0), TaxValue = isnull(@TaxValue, 0),
		PaidValue = isnull(@PaidValue, 0), PaidTaxValue = isnull(@PaidTaxValue, 0),
		InvoiceStatusCode = CASE 
				WHEN @PaidValue >= @InvoiceValue THEN 3 
				WHEN @PaidValue > 0 THEN 2 
				ELSE 1 END
	WHERE     (InvoiceNumber = @InvoiceNumber)
		
	RETURN
GO

/****** Object:  StoredProcedure [Cash].[proc_VatBalance]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Cash].[proc_VatBalance]
	(
	@Balance money output
	)
  AS
	SET @Balance = App.fnVatBalance()
	RETURN 
GO

/****** Object:  StoredProcedure [Activity].[proc_WorkFlow]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Activity].[proc_WorkFlow]
	(
	@ActivityCode nvarchar(50)
	)
  AS
	SELECT     Activity.tbActivity.ActivityCode, Task.tbStatus.TaskStatus, Cash.tbCategory.CashModeCode, Activity.tbActivity.UnitOfMeasure, Activity.tbFlow.OffsetDays
	FROM         Activity.tbActivity INNER JOIN
	                      Task.tbStatus ON Activity.tbActivity.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
	                      Activity.tbFlow ON Activity.tbActivity.ActivityCode = Activity.tbFlow.ChildCode LEFT OUTER JOIN
	                      Cash.tbCode ON Activity.tbActivity.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
	                      Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
	WHERE     ( Activity.tbFlow.ParentCode = @ActivityCode)
	ORDER BY Activity.tbFlow.StepNumber	


	RETURN 
GO

/****** Object:  StoredProcedure [Task].[proc_WorkFlow]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [Task].[proc_WorkFlow] 
	(
	@TaskCode nvarchar(20)
	)
  AS
	SELECT     Task.tbFlow.ParentTaskCode, Task.tbFlow.StepNumber, Task.tbTask.TaskCode, Task.tbTask.AccountCode, Task.tbTask.ActivityCode, Task.tbTask.TaskStatusCode, 
	                      Task.tbTask.ActionOn, Task.vwCashMode.CashModeCode, Task.tbFlow.OffsetDays
	FROM         Task.tbTask INNER JOIN
	                      Task.tbFlow ON Task.tbTask.TaskCode = Task.tbFlow.ChildTaskCode LEFT OUTER JOIN
	                      Task.vwCashMode ON Task.tbTask.TaskCode = Task.vwCashMode.TaskCode
	WHERE     ( Task.tbFlow.ParentTaskCode = @TaskCode)
	ORDER BY Task.tbFlow.StepNumber, Task.tbFlow.ParentTaskCode
	RETURN
GO

/****** Object:  StoredProcedure [App].[proc_YearPeriods]    Script Date: 18/06/2018 18:10:33 ******/

GO


GO

CREATE PROCEDURE [App].[proc_YearPeriods]
	(
	@YearNumber int
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


GO

GO
CREATE TRIGGER [Activity].[Activity_tbActivity_TriggerUpdate] 
   ON  [Activity].[tbActivity]
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	
	IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(ActivityCode) = 0)
		BEGIN
		DECLARE @Msg NVARCHAR(MAX) = App.fnProfileText(2004);
		RAISERROR (@Msg, 10, 1)
		ROLLBACK
		END
	ELSE
		BEGIN
		UPDATE Activity.tbActivity
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Activity.tbActivity INNER JOIN inserted AS i ON tbActivity.ActivityCode = i.ActivityCode;
		END

	SET NOCOUNT OFF;
END
GO
ALTER TABLE [Activity].[tbActivity] ENABLE TRIGGER [Activity_tbActivity_TriggerUpdate]
GO

GO

GO
CREATE TRIGGER [Activity].[Activity_tbAttribute_TriggerUpdate] 
   ON  [Activity].[tbAttribute]
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Activity.tbAttribute
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
	FROM Activity.tbAttribute INNER JOIN inserted AS i ON tbAttribute.ActivityCode = i.ActivityCode AND tbAttribute.Attribute = i.Attribute;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE [Activity].[tbAttribute] ENABLE TRIGGER [Activity_tbAttribute_TriggerUpdate]
GO

GO

GO
CREATE TRIGGER [Activity].[Activity_tbFlow_TriggerUpdate] 
   ON  [Activity].[tbFlow]
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Activity.tbFlow
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
	FROM Activity.tbFlow INNER JOIN inserted AS i ON tbFlow.ParentCode = i.ParentCode AND tbFlow.StepNumber = i.StepNumber;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE [Activity].[tbFlow] ENABLE TRIGGER [Activity_tbFlow_TriggerUpdate]
GO

GO

GO
CREATE TRIGGER [Activity].[Activity_tbOp_TriggerUpdate] 
   ON  [Activity].[tbOp] 
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	UPDATE Activity.tbOp
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
	FROM Activity.tbOp INNER JOIN inserted AS i ON tbOp.ActivityCode = i.ActivityCode AND tbOp.OperationNumber = i.OperationNumber;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE [Activity].[tbOp] ENABLE TRIGGER [Activity_tbOp_TriggerUpdate]
GO

GO

GO
CREATE TRIGGER [App].[App_tbCalendar_TriggerUpdate] 
   ON  [App].[tbCalendar]
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;

	IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(CalendarCode) = 0)
		BEGIN
		DECLARE @Msg NVARCHAR(MAX) = App.fnProfileText(2004);
		RAISERROR (@Msg, 10, 1)
		ROLLBACK
		END

	SET NOCOUNT OFF;
END
GO
ALTER TABLE [App].[tbCalendar] ENABLE TRIGGER [App_tbCalendar_TriggerUpdate]
GO

GO

GO
CREATE TRIGGER [App].[App_tbOptions_TriggerUpdate] 
   ON  [App].[tbOptions]
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE App.tbOptions
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
	FROM App.tbOptions INNER JOIN inserted AS i ON tbOptions.Identifier = i.Identifier;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE [App].[tbOptions] ENABLE TRIGGER [App_tbOptions_TriggerUpdate]
GO

GO

GO
CREATE TRIGGER [App].[App_tbTaxCode_TriggerUpdate] 
   ON  [App].[tbTaxCode]
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	
	IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(TaxCode) = 0)
		BEGIN
		DECLARE @Msg NVARCHAR(MAX) = App.fnProfileText(2004);
		RAISERROR (@Msg, 10, 1)
		ROLLBACK
		END
	ELSE
		BEGIN
		UPDATE App.tbTaxCode
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM App.tbTaxCode INNER JOIN inserted AS i ON tbTaxCode.TaxCode = i.TaxCode;
		END

	SET NOCOUNT OFF;
END
GO
ALTER TABLE [App].[tbTaxCode] ENABLE TRIGGER [App_tbTaxCode_TriggerUpdate]
GO

GO

GO
CREATE TRIGGER [App].[App_tbUom_TriggerUpdate] 
   ON  [App].[tbUom]
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	
	IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(UnitOfMeasure) = 0)
		BEGIN
		DECLARE @Msg NVARCHAR(MAX) = App.fnProfileText(2004);
		RAISERROR (@Msg, 10, 1)
		ROLLBACK
		END

	SET NOCOUNT OFF;
END
GO
ALTER TABLE [App].[tbUom] ENABLE TRIGGER [App_tbUom_TriggerUpdate]
GO

GO

GO
CREATE TRIGGER [Cash].[App_tbCategory_TriggerUpdate] 
   ON  [Cash].[tbCategory]
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;

	IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(CategoryCode) = 0)
		BEGIN
		DECLARE @Msg NVARCHAR(MAX) = App.fnProfileText(2004);
		RAISERROR (@Msg, 10, 1)
		ROLLBACK
		END

	SET NOCOUNT OFF;
END
GO
ALTER TABLE [Cash].[tbCategory] ENABLE TRIGGER [App_tbCategory_TriggerUpdate]
GO

GO

GO
CREATE TRIGGER [Cash].[Cash_tbCategory_TriggerUpdate] 
   ON  [Cash].[tbCategory]
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Cash.tbCategory
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
	FROM Cash.tbCategory INNER JOIN inserted AS i ON tbCategory.CategoryCode = i.CategoryCode;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE [Cash].[tbCategory] ENABLE TRIGGER [Cash_tbCategory_TriggerUpdate]
GO

GO

GO
CREATE TRIGGER [Cash].[Cash_tbCode_TriggerUpdate] 
   ON  [Cash].[tbCode]
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	
	IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(CashCode) = 0)
		BEGIN
		DECLARE @Msg NVARCHAR(MAX) = App.fnProfileText(2004);
		RAISERROR (@Msg, 10, 1)
		ROLLBACK
		END
	ELSE
		BEGIN
		UPDATE Cash.tbCode
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Cash.tbCode INNER JOIN inserted AS i ON tbCode.CashCode = i.CashCode;
		END

	SET NOCOUNT OFF;
END
GO
ALTER TABLE [Cash].[tbCode] ENABLE TRIGGER [Cash_tbCode_TriggerUpdate]
GO

GO

GO
CREATE TRIGGER [Invoice].[Invoice_tbInvoice_TriggerUpdate]
ON [Invoice].[tbInvoice]
FOR UPDATE
AS
	IF UPDATE (Spooled)
		BEGIN
		INSERT INTO App.tbDocSpool (DocTypeCode, DocumentNumber)
		SELECT     App.fnDocInvoiceType(i.InvoiceTypeCode) AS DocTypeCode, i.InvoiceNumber
		FROM         inserted i 
		WHERE     (i.Spooled <> 0)

				
		DELETE App.tbDocSpool
		FROM         inserted i INNER JOIN
		                      App.tbDocSpool ON i.InvoiceNumber = App.tbDocSpool.DocumentNumber
		WHERE    (i.Spooled = 0) AND ( App.tbDocSpool.DocTypeCode > 3)
		END

GO
ALTER TABLE [Invoice].[tbInvoice] ENABLE TRIGGER [Invoice_tbInvoice_TriggerUpdate]
GO

GO

GO

CREATE TRIGGER [Org].[Org_tbAccount_TriggerUpdate] 
   ON  [Org].[tbAccount]
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;

	IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(CashAccountCode) = 0)
		BEGIN
		DECLARE @Msg NVARCHAR(MAX) = App.fnProfileText(2004);
		RAISERROR (@Msg, 10, 1)
		ROLLBACK
		END
	ELSE
		BEGIN	
		UPDATE Org.tbAccount
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Org.tbAccount INNER JOIN inserted AS i ON tbAccount.CashAccountCode = i.CashAccountCode;
		END

	SET NOCOUNT OFF;
END
GO
ALTER TABLE [Org].[tbAccount] ENABLE TRIGGER [Org_tbAccount_TriggerUpdate]
GO

GO

GO
CREATE TRIGGER [Org].[Org_tbAddress_TriggerInsert]
ON [Org].[tbAddress] 
FOR INSERT
AS
	If EXISTS(SELECT     Org.tbOrg.AddressCode, Org.tbOrg.AccountCode
	          FROM         Org.tbOrg INNER JOIN
	                                inserted AS i ON Org.tbOrg.AccountCode = i.AccountCode
	          WHERE     ( Org.tbOrg.AddressCode IS NULL))
		BEGIN
		UPDATE Org.tbOrg
		SET AddressCode = i.AddressCode
		FROM         Org.tbOrg INNER JOIN
	                                inserted AS i ON Org.tbOrg.AccountCode = i.AccountCode
	          WHERE     ( Org.tbOrg.AddressCode IS NULL)
		END


GO
ALTER TABLE [Org].[tbAddress] ENABLE TRIGGER [Org_tbAddress_TriggerInsert]
GO

GO

GO
CREATE TRIGGER [Org].[Org_tbAddress_TriggerUpdate] 
   ON  [Org].[tbAddress]
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Org.tbAddress
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
	FROM Org.tbAddress INNER JOIN inserted AS i ON tbAddress.AddressCode = i.AddressCode;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE [Org].[tbAddress] ENABLE TRIGGER [Org_tbAddress_TriggerUpdate]
GO

GO

GO
CREATE TRIGGER [Org].[Org_tbContact_TriggerUpdate] 
   ON  [Org].[tbContact]
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Org.tbContact
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
	FROM Org.tbContact INNER JOIN inserted AS i ON tbContact.AccountCode = i.AccountCode AND tbContact.ContactName = i.ContactName;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE [Org].[tbContact] ENABLE TRIGGER [Org_tbContact_TriggerUpdate]
GO

GO

GO
CREATE TRIGGER [Org].[Org_tbDoc_TriggerUpdate] 
   ON  [Org].[tbDoc]
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Org.tbDoc
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
	FROM Org.tbDoc INNER JOIN inserted AS i ON tbDoc.AccountCode = i.AccountCode AND tbDoc.DocumentName = i.DocumentName;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE [Org].[tbDoc] ENABLE TRIGGER [Org_tbDoc_TriggerUpdate]
GO

GO

GO
CREATE TRIGGER [Org].[Org_tbOrg_TriggerUpdate] 
   ON  [Org].[tbOrg]
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;

	IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(AccountCode) = 0)
		BEGIN
		DECLARE @Msg NVARCHAR(MAX) = App.fnProfileText(2004);
		RAISERROR (@Msg, 10, 1)
		ROLLBACK
		END
	ELSE
		BEGIN
		UPDATE Org.tbOrg
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Org.tbOrg INNER JOIN inserted AS i ON tbOrg.AccountCode = i.AccountCode;
		END

	SET NOCOUNT OFF;
END
GO
ALTER TABLE [Org].[tbOrg] ENABLE TRIGGER [Org_tbOrg_TriggerUpdate]
GO

GO

GO
CREATE TRIGGER [Org].[Org_tbPayment_TriggerUpdate]
ON [Org].[tbPayment]
FOR UPDATE
AS
	SET NOCOUNT ON;
	
	UPDATE Org.tbPayment
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
	FROM Org.tbPayment INNER JOIN inserted AS i ON tbPayment.PaymentCode = i.PaymentCode;

	IF UPDATE(PaidInValue) OR UPDATE(PaidOutValue)
		BEGIN
		DECLARE @AccountCode NVARCHAR(10)
		DECLARE org CURSOR LOCAL FOR 
			SELECT AccountCode FROM inserted

		OPEN org
		FETCH NEXT FROM org INTO @AccountCode
		WHILE (@@FETCH_STATUS = 0)
			BEGIN		
			EXEC Org.proc_Rebuild @AccountCode
			FETCH NEXT FROM org INTO @AccountCode
		END

		CLOSE org
		DEALLOCATE org

		EXEC Cash.proc_AccountRebuildAll

		END

	SET NOCOUNT OFF;
GO
ALTER TABLE [Org].[tbPayment] ENABLE TRIGGER [Org_tbPayment_TriggerUpdate]
GO

GO

GO
CREATE TRIGGER [Task].[Task_tbAttribute_TriggerUpdate] 
   ON  [Task].[tbAttribute]
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Task.tbAttribute
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
	FROM Task.tbAttribute INNER JOIN inserted AS i ON tbAttribute.TaskCode = i.TaskCode AND tbAttribute.Attribute = i.Attribute;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE [Task].[tbAttribute] ENABLE TRIGGER [Task_tbAttribute_TriggerUpdate]
GO

GO

GO
CREATE TRIGGER [Task].[Task_tbDoc_TriggerUpdate] 
   ON  [Task].[tbDoc]
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Task.tbDoc
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
	FROM Task.tbDoc INNER JOIN inserted AS i ON tbDoc.TaskCode = i.TaskCode AND tbDoc.DocumentName = i.DocumentName;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE [Task].[tbDoc] ENABLE TRIGGER [Task_tbDoc_TriggerUpdate]
GO

GO

GO
CREATE TRIGGER [Task].[Task_tbFlow_TriggerUpdate] 
   ON  [Task].[tbFlow]
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Task.tbFlow
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
	FROM Task.tbFlow INNER JOIN inserted AS i ON tbFlow.ParentTaskCode = i.ParentTaskCode AND tbFlow.StepNumber = i.StepNumber;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE [Task].[tbFlow] ENABLE TRIGGER [Task_tbFlow_TriggerUpdate]
GO

GO

GO
CREATE TRIGGER [Task].[Task_tbOp_TriggerUpdate] 
   ON  [Task].[tbOp] 
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Task.tbOp
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
	FROM Task.tbOp INNER JOIN inserted AS i ON tbOp.TaskCode = i.TaskCode AND tbOp.OperationNumber = i.OperationNumber;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE [Task].[tbOp] ENABLE TRIGGER [Task_tbOp_TriggerUpdate]
GO

GO

GO
CREATE TRIGGER [Task].[Task_tbQuote_TriggerUpdate] 
   ON  [Task].[tbQuote]
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Task.tbQuote
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
	FROM Task.tbQuote INNER JOIN inserted AS i ON tbQuote.TaskCode = i.TaskCode AND tbQuote.Quantity = i.Quantity;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE [Task].[tbQuote] ENABLE TRIGGER [Task_tbQuote_TriggerUpdate]
GO

GO

GO

CREATE TRIGGER [Task].[Task_tbTask_TriggerInsert]
ON [Task].[tbTask]
FOR INSERT
AS
	SET NOCOUNT ON;

	DECLARE contacts CURSOR LOCAL FOR
		SELECT AccountCode, ContactName FROM inserted
		WHERE EXISTS (SELECT     ContactName
					FROM         inserted AS i
					WHERE     (NOT (ContactName IS NULL)) AND
											(ContactName <> N''))
			AND NOT EXISTS(SELECT     Org.tbContact.ContactName
							FROM         inserted AS i INNER JOIN
												Org.tbContact ON i.AccountCode = Org.tbContact.AccountCode AND i.ContactName = Org.tbContact.ContactName)

	DECLARE @AccountCode NVARCHAR(10)
	DECLARE @ContactName NVARCHAR(100)

	DECLARE @FileAs NVARCHAR(100)
	DECLARE @NickName NVARCHAR(100)
				
	OPEN contacts
	FETCH NEXT FROM contacts INTO @AccountCode, @ContactName

	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		SET @NickName = left(@ContactName, CHARINDEX(' ', @ContactName, 1))
		EXEC Org.proc_ContactFileAs @ContactName, @FileAs OUTPUT
					
		INSERT INTO Org.tbContact (AccountCode, ContactName, FileAs, NickName)
		VALUES (@AccountCode, @ContactName, @FileAs, @NickName)

		FETCH NEXT FROM contacts INTO @AccountCode, @ContactName
		END					
		
	CLOSE contacts
	DEALLOCATE contacts

	SET NOCOUNT OFF;
GO
ALTER TABLE [Task].[tbTask] ENABLE TRIGGER [Task_tbTask_TriggerInsert]
GO

GO

GO

CREATE TRIGGER [Task].[Task_tbTask_TriggerUpdate]
ON [Task].[tbTask]
FOR UPDATE
AS
	SET NOCOUNT ON;

	IF UPDATE (Spooled)
		BEGIN
		INSERT INTO App.tbDocSpool (DocTypeCode, DocumentNumber)
		SELECT     App.fnDocTaskType(i.TaskCode) AS DocTypeCode, i.TaskCode
		FROM         inserted i 
		WHERE     (i.Spooled <> 0)

				
		DELETE App.tbDocSpool
		FROM         inserted i INNER JOIN
		                      App.tbDocSpool ON i.TaskCode = App.tbDocSpool.DocumentNumber
		WHERE    (i.Spooled = 0) AND ( App.tbDocSpool.DocTypeCode <= 3)
		END


	IF UPDATE (ContactName)
		BEGIN
		DECLARE contacts CURSOR LOCAL FOR
			SELECT AccountCode, ContactName FROM inserted
			WHERE EXISTS (SELECT     ContactName
					   FROM         inserted AS i
					   WHERE     (NOT (ContactName IS NULL)) AND
											 (ContactName <> N''))
				AND NOT EXISTS(SELECT     Org.tbContact.ContactName
							  FROM         inserted AS i INNER JOIN
													Org.tbContact ON i.AccountCode = Org.tbContact.AccountCode AND i.ContactName = Org.tbContact.ContactName)

		DECLARE @AccountCode NVARCHAR(10)
		DECLARE @ContactName NVARCHAR(100)

		DECLARE @FileAs NVARCHAR(100)
		DECLARE @NickName NVARCHAR(100)
				
		OPEN contacts
		FETCH NEXT FROM contacts INTO @AccountCode, @ContactName

		WHILE (@@FETCH_STATUS = 0)
			BEGIN
			SET @NickName = left(@ContactName, CHARINDEX(' ', @ContactName, 1))
			EXEC Org.proc_ContactFileAs @ContactName, @FileAs OUTPUT
					
			INSERT INTO Org.tbContact (AccountCode, ContactName, FileAs, NickName)
			VALUES (@AccountCode, @ContactName, @FileAs, @NickName)

			FETCH NEXT FROM contacts INTO @AccountCode, @ContactName
			END					
		
		CLOSE contacts
		DEALLOCATE contacts
		END


	DECLARE @TaskCode NVARCHAR(20)


	IF UPDATE (TaskStatusCode)
		BEGIN
		DECLARE tasks CURSOR LOCAL FOR
			SELECT        i.TaskCode, i.TaskStatusCode
			FROM  inserted AS i INNER JOIN Task.tbTask AS t ON i.TaskCode = t.TaskCode AND i.TaskStatusCode <> t.TaskStatusCode 

		DECLARE @TaskStatusCode smallint

		OPEN tasks
		FETCH NEXT FROM tasks INTO @TaskCode, @TaskStatusCode

		WHILE (@@FETCH_STATUS = 0)
			BEGIN
			IF @TaskStatusCode <> 3
				EXEC Task.proc_SetStatus @TaskCode
			ELSE
				EXEC Task.proc_SetOpStatus @TaskCode, @TaskStatusCode

			FETCH NEXT FROM tasks INTO @TaskCode, @TaskStatusCode
			END

		CLOSE tasks
		DEALLOCATE tasks			
		END
		
	
	IF UPDATE (ActionOn) AND EXISTS (SELECT * FROM App.tbOptions WHERE ScheduleOps <> 0)
		BEGIN
		DECLARE ops CURSOR LOCAL FOR
			SELECT TaskCode, ActionOn FROM inserted
		
		DECLARE @ActionOn datetime

		OPEN ops
		FETCH NEXT FROM ops INTO @TaskCode, @ActionOn

		WHILE (@@FETCH_STATUS = 0)
			BEGIN
			EXEC Task.proc_ScheduleOp @TaskCode, @ActionOn
			FETCH NEXT FROM ops INTO @TaskCode, @ActionOn
			END

		CLOSE ops
		DEALLOCATE ops
		END	

	UPDATE Task.tbTask
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
	FROM Task.tbTask INNER JOIN inserted AS i ON tbTask.TaskCode = i.TaskCode;

	SET NOCOUNT OFF;
GO
ALTER TABLE [Task].[tbTask] ENABLE TRIGGER [Task_tbTask_TriggerUpdate]
GO

GO

GO
CREATE TRIGGER [Usr].[Usr_tbMenuEntry_TriggerUpdate] 
   ON  [Usr].[tbMenuEntry]
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Usr.tbMenuEntry
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
	FROM Usr.tbMenuEntry INNER JOIN inserted AS i ON tbMenuEntry.EntryId = i.EntryId AND tbMenuEntry.EntryId = i.EntryId;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE [Usr].[tbMenuEntry] ENABLE TRIGGER [Usr_tbMenuEntry_TriggerUpdate]
GO

GO

GO
CREATE TRIGGER [Usr].[Usr_tbUser_TriggerUpdate] 
   ON  [Usr].[tbUser]
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Usr.tbUser
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
	FROM Usr.tbUser INNER JOIN inserted AS i ON tbUser.UserId = i.UserId;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE [Usr].[tbUser] ENABLE TRIGGER [Usr_tbUser_TriggerUpdate]
GO

