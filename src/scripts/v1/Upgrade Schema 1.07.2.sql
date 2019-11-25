/************************************************************
* Tru-Man Trade Control: Information and Cash System
* Copyright Tru-Man Industries Ltd 2008. All Rights Reserved.
* Author: Ian Monnox
* Description: Sql Server Upgrade Script - Encrypted Distribution Schema
* Data Version: 1.07.2
* Release Date: TBC
************************************************************/
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
ALTER  VIEW dbo.vwInvoiceVatTasks
AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoiceTask.InvoiceNumber, dbo.tbInvoice.InvoiceTypeCode, 
                      dbo.tbInvoiceTask.TaxCode, dbo.tbInvoiceTask.InvoiceValue, dbo.tbInvoiceTask.TaxValue, dbo.tbOrg.ForeignJurisdiction
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbInvoiceTask.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 2)
GO
ALTER  VIEW dbo.vwInvoiceVatItems
AS
SELECT     TOP 100 PERCENT dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoice.InvoiceNumber, dbo.tbInvoice.InvoiceTypeCode, 
                      dbo.tbInvoiceItem.TaxCode, dbo.tbInvoiceItem.InvoiceValue, dbo.tbInvoiceItem.TaxValue, dbo.tbOrg.ForeignJurisdiction
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbInvoiceItem.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 2)
ORDER BY dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn)
GO
ALTER  VIEW dbo.vwInvoiceVatBase
AS
SELECT DISTINCT StartOn, InvoiceNumber, InvoiceTypeCode, TaxCode, InvoiceValue, TaxValue, ForeignJurisdiction
FROM         dbo.vwInvoiceVatItems
UNION
SELECT DISTINCT StartOn, InvoiceNumber, InvoiceTypeCode, TaxCode, InvoiceValue, TaxValue, ForeignJurisdiction
FROM         dbo.vwInvoiceVatTasks
GO
ALTER  FUNCTION dbo.fnTaxTypeDueDates
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
ALTER VIEW dbo.vwTaxCorpTotals
AS
SELECT     dbo.tbSystemYear.[Description], dbo.tbSystemMonth.MonthName, dbo.vwCorpTaxInvoice.StartOn, SUM(dbo.vwCorpTaxInvoice.NetProfit) AS NetProfit, 
                      SUM(dbo.vwCorpTaxInvoice.CorporationTax) AS CorporationTax
FROM         dbo.vwCorpTaxInvoice INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.vwCorpTaxInvoice.StartOn = dbo.tbSystemYearPeriod.StartOn INNER JOIN
                      dbo.tbSystemYear ON dbo.tbSystemYearPeriod.YearNumber = dbo.tbSystemYear.YearNumber INNER JOIN
                      dbo.tbSystemMonth ON dbo.tbSystemYearPeriod.MonthNumber = dbo.tbSystemMonth.MonthNumber
GROUP BY dbo.tbSystemYear.[Description], dbo.tbSystemMonth.MonthName, dbo.vwCorpTaxInvoice.StartOn
GO
