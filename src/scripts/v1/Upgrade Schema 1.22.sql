
ALTER PROCEDURE [dbo].[spInvoiceTotal] 
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
ALTER VIEW [dbo].[vwStatementTasksFull]
AS
SELECT     TOP (100) PERCENT dbo.tbTask.TaskCode AS ReferenceCode, dbo.tbTask.AccountCode, dbo.tbTask.ActionOn, dbo.tbTask.PaymentOn, 
                      CASE WHEN tbTask.TaskStatusCode = 1 THEN 4 ELSE 3 END AS CashEntryTypeCode, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.vwSystemTaxRates.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayOut, 
                      CASE WHEN tbCashCategory.CashModeCode = 2 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.vwSystemTaxRates.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayIn, dbo.tbCashCode.CashCode
FROM         dbo.vwSystemTaxRates INNER JOIN
                      dbo.tbTask ON dbo.vwSystemTaxRates.TaxCode = dbo.tbTask.TaxCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.tbTask.TaskStatusCode < 4) AND (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0) > 0)
GO
ALTER VIEW [dbo].[vwStatementTasksConfirmed]
AS
SELECT     TOP (100) PERCENT dbo.tbTask.TaskCode AS ReferenceCode, dbo.tbTask.AccountCode, dbo.tbTask.ActionOn, dbo.tbTask.PaymentOn, 
                      3 AS CashEntryTypeCode, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.vwSystemTaxRates.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayOut, 
                      CASE WHEN tbCashCategory.CashModeCode = 2 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.vwSystemTaxRates.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayIn, dbo.tbCashCode.CashCode
FROM         dbo.vwSystemTaxRates INNER JOIN
                      dbo.tbTask ON dbo.vwSystemTaxRates.TaxCode = dbo.tbTask.TaxCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.tbTask.TaskStatusCode > 1) AND (dbo.tbTask.TaskStatusCode < 4) AND 
                      (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0) > 0)
GO
ALTER VIEW [dbo].[vwTaskVatConfirmed]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * vwSystemTaxRates.TaxRate * - 1 ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) 
                      * vwSystemTaxRates.TaxRate END AS VatValue
FROM         dbo.tbTask INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode INNER JOIN
                      dbo.vwSystemTaxRates ON dbo.tbTask.TaxCode = dbo.vwSystemTaxRates.TaxCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.vwSystemTaxRates.TaxTypeCode = 2) AND (dbo.tbTask.TaskStatusCode > 1) AND (dbo.tbTask.TaskStatusCode < 4) AND 
                      (CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * vwSystemTaxRates.TaxRate ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) 
                      * vwSystemTaxRates.TaxRate * - 1 END <> 0) AND (dbo.tbTask.PaymentOn <= DATEADD(d, dbo.fnSystemTaxHorizon(), GETDATE()))
GO
ALTER VIEW [dbo].[vwTaskVatFull]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * vwSystemTaxRates.TaxRate ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) 
                      * vwSystemTaxRates.TaxRate * - 1 END AS VatValue
FROM         dbo.tbTask INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode INNER JOIN
                      dbo.vwSystemTaxRates ON dbo.tbTask.TaxCode = dbo.vwSystemTaxRates.TaxCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.vwSystemTaxRates.TaxTypeCode = 2) AND (dbo.tbTask.TaskStatusCode < 4) AND 
                      (CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * vwSystemTaxRates.TaxRate ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) 
                      * vwSystemTaxRates.TaxRate * - 1 END <> 0)
GO
ALTER PROCEDURE [dbo].[spPaymentPostMisc]
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
ALTER VIEW [dbo].[vwCashCodeForecastSummary]
AS
SELECT     dbo.tbTask.CashCode, dbo.fnAccountPeriod(dbo.tbTask.ActionOn) AS StartOn, SUM(dbo.tbTask.TotalCharge) AS ForecastValue, 
                      SUM(dbo.tbTask.TotalCharge * ISNULL(dbo.vwSystemTaxRates.TaxRate, 0)) AS ForecastTax
FROM         dbo.tbTask INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode LEFT OUTER JOIN
                      dbo.vwSystemTaxRates ON dbo.tbTask.TaxCode = dbo.vwSystemTaxRates.TaxCode
WHERE     (dbo.tbTask.ActionOn >= dbo.fnSystemActiveStartOn())
GROUP BY dbo.tbTask.CashCode, dbo.fnAccountPeriod(dbo.tbTask.ActionOn)
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
ALTER VIEW [dbo].[vwInvoiceRegisterDetail]
AS
SELECT     StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, 
                      InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, 
                      InvoiceType
FROM         dbo.vwInvoiceRegisterTasks
UNION
SELECT     StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, 
                      InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, 
                      InvoiceType
FROM         dbo.vwInvoiceRegisterItems
GO
ALTER  PROCEDURE dbo.spInvoiceRaise
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
