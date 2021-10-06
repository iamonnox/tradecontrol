/************************************************************
* Tru-Man Trade Control: Management Information and Cash System
* Copyright Tru-Man Industries Ltd 2008. All Rights Reserved.
* Author: Ian Monnox
* Description: Sql Server Upgrade Script - Encrypted Distribution Schema
* Data Version: 1.08
* Release Date: TBC
************************************************************/

CREATE VIEW [dbo].[vwTaskProfitOrders]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbTask.PaymentOn) AS StartOn, dbo.tbTask.TaskCode, 
                      CASE WHEN dbo.tbCashCategory.CashModeCode = 1 THEN dbo.tbTask.TotalCharge * - 1 ELSE dbo.tbTask.TotalCharge END AS TotalCharge
FROM         dbo.tbCashCode INNER JOIN
                      dbo.tbTask ON dbo.tbCashCode.CashCode = dbo.tbTask.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode LEFT OUTER JOIN
                      dbo.tbTask AS tbTask_1 RIGHT OUTER JOIN
                      dbo.tbTaskFlow ON tbTask_1.TaskCode = dbo.tbTaskFlow.ParentTaskCode ON dbo.tbTask.TaskCode = dbo.tbTaskFlow.ChildTaskCode
WHERE     (dbo.tbTask.TaskStatusCode > 1) AND (dbo.tbTaskFlow.ParentTaskCode IS NULL) AND (tbTask_1.CashCode IS NULL) AND 
                      (dbo.tbTask.TaskStatusCode < 5) OR
                      (dbo.tbTask.TaskStatusCode > 1) AND (tbTask_1.CashCode IS NULL) AND (dbo.tbTask.TaskStatusCode < 5)
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
		WHERE     (tbTaskFlow.ParentTaskCode = @ParentTaskCode)	

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
CREATE VIEW [dbo].[vwTaskProfit]
AS
SELECT     TOP 100 PERCENT fnTaskProfit_1.StartOn, dbo.tbOrg.AccountCode, dbo.tbTask.TaskCode, dbo.tbTask.ActivityCode, dbo.tbCashCode.CashCode, 
                      dbo.tbTask.TaskTitle, dbo.tbOrg.AccountName, dbo.tbCashCode.CashDescription, dbo.tbTaskStatus.TaskStatus, fnTaskProfit_1.TotalCharge, 
                      fnTaskProfit_1.InvoicedCharge, fnTaskProfit_1.InvoicedChargePaid, fnTaskProfit_1.TotalCost, fnTaskProfit_1.InvoicedCost, 
                      fnTaskProfit_1.InvoicedCostPaid, fnTaskProfit_1.TotalCharge - fnTaskProfit_1.TotalCost AS Profit, 
                      fnTaskProfit_1.TotalCharge - fnTaskProfit_1.InvoicedCharge AS UninvoicedCharge, 
                      fnTaskProfit_1.InvoicedCharge - fnTaskProfit_1.InvoicedChargePaid AS UnpaidCharge, 
                      fnTaskProfit_1.TotalCost - fnTaskProfit_1.InvoicedCost AS UninvoicedCost, 
                      fnTaskProfit_1.InvoicedCost - fnTaskProfit_1.InvoicedCostPaid AS UnpaidCost, dbo.tbTask.ActionOn, dbo.tbTask.ActionedOn, 
                      dbo.tbTask.PaymentOn
FROM         dbo.tbTask INNER JOIN
                      dbo.fnTaskProfit() AS fnTaskProfit_1 ON dbo.tbTask.TaskCode = fnTaskProfit_1.TaskCode INNER JOIN
                      dbo.tbTaskStatus ON dbo.tbTask.TaskStatusCode = dbo.tbTaskStatus.TaskStatusCode INNER JOIN
                      dbo.tbOrg ON dbo.tbTask.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode
ORDER BY fnTaskProfit_1.StartOn
GO
CREATE PROCEDURE dbo.spTaskCopy
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

	SELECT  @TaskStatusCode = tbActivity.TaskStatusCode, @ActivityCode = tbTask.ActivityCode, @Printed = CASE WHEN tbActivity.PrintOrder = 0 THEN 1 ELSE 0 END
	FROM         tbTask INNER JOIN
	                      tbActivity ON tbTask.ActivityCode = tbActivity.ActivityCode
	WHERE     (tbTask.TaskCode = @FromTaskCode)
	
	exec dbo.spTaskNextCode @ActivityCode, @ToTaskCode output

	INSERT INTO tbTask
	                      (TaskCode, UserId, AccountCode, TaskTitle, ContactName, ActivityCode, TaskStatusCode, ActionById, ActionOn, TaskNotes, Quantity, CashCode, 
	                      TaxCode, UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, PaymentOn, Printed)
	SELECT     @ToTaskCode AS ToTaskCode, UserId, AccountCode, TaskTitle, ContactName, ActivityCode, @TaskStatusCode As TaskStatus, ActionById, ActionOn, TaskNotes, 
	                      Quantity, CashCode, TaxCode, UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, PaymentOn, @Printed AS Printed
	FROM         tbTask AS tbTask_1
	WHERE TaskCode = @FromTaskCode
	
	INSERT INTO tbTaskAttribute
	                      (TaskCode, Attribute, PrintOrder, AttributeTypeCode, AttributeDescription)
	SELECT     @ToTaskCode AS ToTaskCode, Attribute, PrintOrder, AttributeTypeCode, AttributeDescription
	FROM         tbTaskAttribute AS tbTaskAttribute_1
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
DROP INDEX [tbActivityAttribute].[IX_tbActivityAttribute_DefaultText]
GO
DROP INDEX [tbTaskAttribute].[IX_tbTaskAttribute_Description]
GO
ALTER TABLE tbActivityAttribute
	ALTER COLUMN DefaultText nvarchar(400)
GO
CREATE  INDEX [IX_tbActivityAttribute_DefaultText] ON [dbo].[tbActivityAttribute]([DefaultText]) WITH  FILLFACTOR = 90 ON [PRIMARY]
GO
ALTER TABLE tbTaskAttribute
	ALTER COLUMN AttributeDescription nvarchar(400)
GO
 CREATE  INDEX [IX_tbTaskAttribute_Description] ON [dbo].[tbTaskAttribute]([Attribute], [AttributeDescription]) WITH  FILLFACTOR = 90 ON [PRIMARY]
GO
