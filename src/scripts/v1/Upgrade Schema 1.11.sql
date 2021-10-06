/************************************************************
* Tru-Man Trade Control: Management Information and Cash System
* Copyright Tru-Man Industries Ltd 2009. All Rights Reserved.
* Author: Ian Monnox
* Description: Sql Server Upgrade Script - Encrypted Distribution Schema
* Data Version: 1.11
* Release Date: TBC
************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[spTaskCost] 
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
ALTER FUNCTION dbo.fnTaskProfitCost
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
ALTER TABLE dbo.tbOrg WITH NOCHECK ADD
	PayDaysFromMonthEnd bit NOT NULL CONSTRAINT DF_tbOrg_PayDaysFromMonthEnd DEFAULT (0)
GO
ALTER VIEW [dbo].[vwOrgDatasheet]
AS
SELECT     dbo.tbOrg.AccountCode, dbo.tbOrg.AccountName, ISNULL(dbo.vwOrgTaskCount.TaskCount, 0) AS Tasks, dbo.tbOrg.OrganisationTypeCode, 
                      dbo.tbOrgType.OrganisationType, dbo.tbOrgType.CashModeCode, dbo.tbOrg.OrganisationStatusCode, dbo.tbOrgStatus.OrganisationStatus, 
                      dbo.tbOrgAddress.Address, dbo.tbSystemTaxCode.TaxDescription, dbo.tbOrg.TaxCode, dbo.tbOrg.AddressCode, dbo.tbOrg.AreaCode, 
                      dbo.tbOrg.PhoneNumber, dbo.tbOrg.FaxNumber, dbo.tbOrg.EmailAddress, dbo.tbOrg.WebSite, dbo.fnOrgIndustrySectors(dbo.tbOrg.AccountCode) 
                      AS IndustrySector, dbo.tbOrg.AccountSource, dbo.tbOrg.PaymentTerms, dbo.tbOrg.PaymentDays, dbo.tbOrg.NumberOfEmployees, 
                      dbo.tbOrg.CompanyNumber, dbo.tbOrg.VatNumber, dbo.tbOrg.Turnover, dbo.tbOrg.StatementDays, dbo.tbOrg.OpeningBalance, 
                      dbo.tbOrg.CurrentBalance, dbo.tbOrg.ForeignJurisdiction, dbo.tbOrg.BusinessDescription, dbo.tbOrg.InsertedBy, dbo.tbOrg.InsertedOn, 
                      dbo.tbOrg.UpdatedBy, dbo.tbOrg.UpdatedOn, dbo.tbOrg.PayDaysFromMonthEnd
FROM         dbo.tbOrg INNER JOIN
                      dbo.tbOrgStatus ON dbo.tbOrg.OrganisationStatusCode = dbo.tbOrgStatus.OrganisationStatusCode INNER JOIN
                      dbo.tbOrgType ON dbo.tbOrg.OrganisationTypeCode = dbo.tbOrgType.OrganisationTypeCode LEFT OUTER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbOrg.TaxCode = dbo.tbSystemTaxCode.TaxCode LEFT OUTER JOIN
                      dbo.tbOrgAddress ON dbo.tbOrg.AddressCode = dbo.tbOrgAddress.AddressCode LEFT OUTER JOIN
                      dbo.vwOrgTaskCount ON dbo.tbOrg.AccountCode = dbo.vwOrgTaskCount.AccountCode
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
		set @PaymentOn = dateadd(d, @PaymentDays, dateadd(d, (day(@ActionOn) - 1) * -1, dateadd(m, 1, @ActionOn)))
	ELSE
		set @PaymentOn = dateadd(d, @PaymentDays, @ActionOn)
		
	set @PaymentOn = dbo.fnSystemAdjustToCalendar(@UserId, @PaymentOn, 0)	
	
	
	RETURN @PaymentOn
	END
GO
ALTER PROCEDURE [dbo].[spTaskDefaultPaymentOn]
	(
		@AccountCode nvarchar(10),
		@ActionOn datetime,
		@PaymentOn datetime output
	)
AS

	SET @PaymentOn = dbo.fnTaskDefaultPaymentOn(@AccountCode, @ActionOn)
	
	RETURN
GO
ALTER  PROCEDURE [dbo].[spTaskConfigure] 
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
ALTER  PROCEDURE dbo.spTaskSchedule
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
ALTER  PROCEDURE dbo.spInvoiceRaise
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
declare @InvoicedOn datetime

	set @InvoicedOn = getdate()
	
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
	
	set @CollectOn = dbo.fnTaskDefaultPaymentOn(@AccountCode, GETDATE())
	
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
ALTER PROCEDURE [dbo].[spStatementRescheduleOverdue]
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
ALTER FUNCTION [dbo].[fnStatementVat]
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
	
	set @ReferenceCode = dbo.fnSystemProfileText(1214)	
	set @CashCode = dbo.fnSystemCashCode(2)
	set @AccountCode = dbo.fnStatementTaxAccount(2)
	
	if exists(SELECT  MAX(StartOn) AS LastStartOn FROM vwTaxVatStatement)
		begin
		select @LastBalanceOn = MAX(StartOn) FROM vwTaxVatStatement
		SELECT  TOP 1 @VatDueOn = PayOn
		FROM         vwStatementVatDueDate
		
		SET @VatDueOn = dbo.fnTaskDefaultPaymentOn(@AccountCode, @VatDueOn)
		
		SELECT @VatDue = Balance
		FROM         vwTaxVatStatement
		WHERE     (StartOn = @LastBalanceOn)		
		
		if (@VatDue <> 0)
			begin
			insert into @tbVat (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayOut, PayIn, CashCode)
			values (@ReferenceCode, @AccountCode, @VatDueOn, 6, CASE WHEN @VatDue > 0 THEN @VatDue ELSE 0 END, CASE WHEN @VatDue < 0 THEN ABS(@VatDue) ELSE 0 END, @CashCode)						
			end
		end
	
	RETURN
	END
GO
ALTER FUNCTION [dbo].[fnStatementCompany]
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


	SET @AccountCode = dbo.fnStatementTaxAccount(2)
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	SELECT     @ReferenceCode AS ReferenceCode, @AccountCode AS AccountCode, dbo.fnTaskDefaultPaymentOn(@AccountCode, StartOn), 6 AS Expr1, PayIn, PayOut, dbo.fnSystemCashCode(2)
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
ALTER TABLE dbo.tbSystemYearPeriod WITH NOCHECK ADD
	TaxAdjustment money NOT NULL CONSTRAINT DF_tbSystemYearPeriod_TaxAdjustment DEFAULT (0)
GO
ALTER VIEW [dbo].[vwTaxCorpTotals]
AS
SELECT     TOP 100 PERCENT dbo.vwCorpTaxInvoice.StartOn, YEAR(dbo.tbSystemYearPeriod.StartOn) AS PeriodYear, dbo.tbSystemYear.Description, 
                      dbo.tbSystemMonth.MonthName, SUM(dbo.vwCorpTaxInvoice.NetProfit) AS NetProfit, SUM(dbo.vwCorpTaxInvoice.CorporationTax) 
                      AS CorporationTax
FROM         dbo.vwCorpTaxInvoice INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.vwCorpTaxInvoice.StartOn = dbo.tbSystemYearPeriod.StartOn INNER JOIN
                      dbo.tbSystemYear ON dbo.tbSystemYearPeriod.YearNumber = dbo.tbSystemYear.YearNumber INNER JOIN
                      dbo.tbSystemMonth ON dbo.tbSystemYearPeriod.MonthNumber = dbo.tbSystemMonth.MonthNumber
GROUP BY dbo.tbSystemYear.Description, dbo.tbSystemMonth.MonthName, dbo.vwCorpTaxInvoice.StartOn, YEAR(dbo.tbSystemYearPeriod.StartOn)
ORDER BY dbo.vwCorpTaxInvoice.StartOn
GO
ALTER VIEW [dbo].[vwCorpTaxInvoice]
AS
SELECT     TOP 100 PERCENT dbo.tbSystemYearPeriod.StartOn, dbo.vwCorpTaxInvoiceBase.NetProfit, 
                      dbo.vwCorpTaxInvoiceBase.NetProfit * dbo.tbSystemYearPeriod.CorporationTaxRate + dbo.tbSystemYearPeriod.TaxAdjustment AS CorporationTax
FROM         dbo.vwCorpTaxInvoiceBase INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.vwCorpTaxInvoiceBase.StartOn = dbo.tbSystemYearPeriod.StartOn
ORDER BY dbo.tbSystemYearPeriod.StartOn
GO
ALTER FUNCTION [dbo].[fnStatementCorpTax]
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
	declare @AccountCode nvarchar(10)
	
	set @ReferenceCode = dbo.fnSystemProfileText(1214)	
	set @CashCode = dbo.fnSystemCashCode(1)
	set @AccountCode = dbo.fnStatementTaxAccount(1)
	
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
			values (@ReferenceCode, @AccountCode, @StartOn, 5, @TaxDue, 0, @CashCode)						
			end
		set @LastBalance = @Balance
		fetch next from curCorpTax into @StartOn, @TaxDue, @Balance	
		end
		
	close curCorpTax
	deallocate curCorpTax
	
	RETURN
	END
GO
CREATE PROCEDURE dbo.spTaskFullyInvoiced
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
CREATE PROCEDURE dbo.spTaskReconcileCharge
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
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1217, 'Order charge differs from the invoice. Reconcile <1>?', 1)
GO
ALTER VIEW [dbo].[vwOrgRebuildInvoicedItems]
AS
SELECT     dbo.tbInvoice.AccountCode, dbo.tbInvoiceType.CashModeCode, dbo.tbInvoice.CollectOn, dbo.tbInvoiceItem.InvoiceNumber, 
                      dbo.tbInvoiceItem.CashCode, '' AS TaskCode, dbo.tbInvoiceItem.InvoiceValue, dbo.tbInvoiceItem.TaxValue, dbo.tbInvoiceItem.PaidValue, 
                      dbo.tbInvoiceItem.PaidTaxValue
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
GO
ALTER VIEW [dbo].[vwOrgRebuildInvoicedTasks]
AS
SELECT     dbo.tbInvoice.AccountCode, dbo.tbInvoiceType.CashModeCode, dbo.tbInvoice.CollectOn, dbo.tbInvoiceTask.InvoiceNumber, 
                      dbo.tbInvoiceTask.CashCode, dbo.tbInvoiceTask.TaskCode, dbo.tbInvoiceTask.InvoiceValue, dbo.tbInvoiceTask.TaxValue, 
                      dbo.tbInvoiceTask.PaidValue, dbo.tbInvoiceTask.PaidTaxValue
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
GO
ALTER VIEW [dbo].[vwOrgRebuildInvoices]
AS
SELECT     AccountCode, CashModeCode, CollectOn, InvoiceNumber, CashCode, TaskCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
FROM         dbo.vwOrgRebuildInvoicedTasks
UNION
SELECT     AccountCode, CashModeCode, CollectOn, InvoiceNumber, CashCode, TaskCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
FROM         dbo.vwOrgRebuildInvoicedItems
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
ALTER VIEW [dbo].[vwInvoiceOutstanding]
AS
SELECT     TOP 100 PERCENT dbo.tbInvoice.AccountCode, dbo.tbInvoice.CollectOn, dbo.tbInvoice.InvoiceNumber, dbo.vwInvoiceOutstandingBase.TaskCode, 
                      dbo.tbInvoice.InvoiceStatusCode, dbo.tbInvoiceType.CashModeCode, dbo.vwInvoiceOutstandingBase.CashCode, 
                      dbo.vwInvoiceOutstandingBase.TaxCode, dbo.vwInvoiceOutstandingBase.TaxRate, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN OutstandingValue * - 1 ELSE OutstandingValue END AS ItemValue
FROM         dbo.vwInvoiceOutstandingBase INNER JOIN
                      dbo.tbInvoice ON dbo.vwInvoiceOutstandingBase.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
WHERE     (dbo.tbInvoice.InvoiceStatusCode = 2) OR
                      (dbo.tbInvoice.InvoiceStatusCode = 3)
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
ALTER VIEW [dbo].[vwDocInvoiceTask]
AS
SELECT     dbo.tbInvoiceTask.InvoiceNumber, dbo.tbInvoiceTask.TaskCode, dbo.tbTask.TaskTitle, dbo.tbTask.ActivityCode, dbo.tbInvoiceTask.CashCode, 
                      dbo.tbCashCode.CashDescription, dbo.tbTask.ActionedOn, dbo.tbInvoiceTask.Quantity, dbo.tbActivity.UnitOfMeasure, dbo.tbInvoiceTask.InvoiceValue, 
                      dbo.tbInvoiceTask.TaxValue, dbo.tbInvoiceTask.TaxCode, dbo.tbTask.SecondReference
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbTask ON dbo.tbInvoiceTask.TaskCode = dbo.tbTask.TaskCode AND dbo.tbInvoiceTask.TaskCode = dbo.tbTask.TaskCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbInvoiceTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbActivity ON dbo.tbTask.ActivityCode = dbo.tbActivity.ActivityCode
GO
