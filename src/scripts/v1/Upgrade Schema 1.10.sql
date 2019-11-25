/************************************************************
* Tru-Man Trade Control: Management Information and Cash System
* Copyright Tru-Man Industries Ltd 2009. All Rights Reserved.
* Author: Ian Monnox
* Description: Sql Server Upgrade Script - Encrypted Distribution Schema
* Data Version: 1.10
* Release Date: TBC
************************************************************/
GO
CREATE TABLE [dbo].[tbActivityOpType](
	[OpTypeCode] [smallint] NOT NULL,
	[OpType] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tbActivityOpType] PRIMARY KEY CLUSTERED 
(
	[OpTypeCode] ASC
) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT INTO [tbActivityOpType] (OpTypeCode, OpType) VALUES (1, 'Activity'), (2, 'Call-off')
GO
CREATE TABLE [dbo].[tbActivityOp](
	[ActivityCode] [nvarchar](50) NOT NULL,
	[OperationNumber] [smallint] NOT NULL CONSTRAINT [DF_tbActivityOp_OperationNumber]  DEFAULT ((0)),
	[OpTypeCode] [smallint] NOT NULL CONSTRAINT [DF_tbActivityOp_OpTypeCode]  DEFAULT ((1)),
	[Operation] [nvarchar](50) NOT NULL,
	[Duration] [float] NOT NULL CONSTRAINT [DF_tbActivityOp_Duration]  DEFAULT ((0)),
	[OffsetDays] [smallint] NOT NULL CONSTRAINT [DF_tbActivityOp_OffsetDays]  DEFAULT ((0)),
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbActivityOp_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbActivityOp_InsertedOn]  DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbActivityOp_UpdatedBy]  DEFAULT (suser_sname()),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbActivityOp_UpdatedOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_tbActivityOp] PRIMARY KEY CLUSTERED 
(
	[ActivityCode] ASC,
	[OperationNumber] ASC
) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbActivityOp]  WITH CHECK ADD  CONSTRAINT [FK_tbActivityOp_tbActivity] FOREIGN KEY([ActivityCode])
REFERENCES [dbo].[tbActivity] ([ActivityCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbActivityOp] CHECK CONSTRAINT [FK_tbActivityOp_tbActivity]
GO
ALTER TABLE [dbo].[tbActivityOp]  WITH CHECK ADD  CONSTRAINT [FK_tbActivityOp_tbActivityOpType] FOREIGN KEY([OpTypeCode])
REFERENCES [dbo].[tbActivityOpType] ([OpTypeCode])
GO
ALTER TABLE [dbo].[tbActivityOp] CHECK CONSTRAINT [FK_tbActivityOp_tbActivityOpType]
GO
CREATE NONCLUSTERED INDEX [IX_tbActivityOp_Operation] ON [dbo].[tbActivityOp] 
(
	[Operation] ASC
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbTaskOpStatus](
	[OpStatusCode] [smallint] NOT NULL,
	[OpStatus] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tbTaskOpStatus] PRIMARY KEY CLUSTERED 
(
	[OpStatusCode] ASC
) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT INTO tbTaskOpStatus (OpStatusCode, OpStatus) VALUES (1, 'Pending')
INSERT INTO tbTaskOpStatus (OpStatusCode, OpStatus) VALUES (2, 'In-progress')
INSERT INTO tbTaskOpStatus (OpStatusCode, OpStatus) VALUES (3, 'Complete')
GO
CREATE TABLE [dbo].[tbTaskOp](
	[TaskCode] [nvarchar](20) NOT NULL,
	[OperationNumber] [smallint] NOT NULL,
	[OpTypeCode] [smallint] NOT NULL CONSTRAINT [DF_tbTaskOp_OpTypeCode]  DEFAULT ((1)),	
	[OpStatusCode] [smallint] NOT NULL CONSTRAINT [DF_tbTaskOp_OpStatusCode]  DEFAULT ((1)),
	[UserId] [nvarchar](10) NOT NULL,
	[Operation] [nvarchar](50) NOT NULL,
	[Note] [ntext] NULL,
	[StartOn] [datetime] NOT NULL CONSTRAINT [DF_tbTaskOp_StartOn]  DEFAULT (getdate()),
	[EndOn] [datetime] NOT NULL CONSTRAINT [DF_tbTaskOp_EndOn]  DEFAULT (getdate()),
	[Duration] [float] NOT NULL CONSTRAINT [DF_tbTaskOp_Duration]  DEFAULT ((0)),
	[OffsetDays] [smallint] NOT NULL CONSTRAINT [DF_tbTaskOp_OffsetDays]  DEFAULT ((0)),
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbTaskOp_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbTaskOp_InsertedOn]  DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbTaskOp_UpdatedBy]  DEFAULT (suser_sname()),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbTaskOp_UpdatedOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_tbTaskOp] PRIMARY KEY CLUSTERED 
(
	[TaskCode] ASC,
	[OperationNumber] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbTaskQuote]    Script Date: 04/29/2009 12:44:09 ******/
GO
CREATE TABLE [dbo].[tbTaskQuote](
	[TaskCode] [nvarchar](20) NOT NULL,
	[Quantity] [float] NOT NULL CONSTRAINT [DF_tbTaskQuote_Quantity]  DEFAULT ((0)),
	[TotalPrice] [money] NOT NULL CONSTRAINT [DF_tbTaskQuote_TotalPrice]  DEFAULT ((0)),
	[RunOnQuantity] [float] NOT NULL CONSTRAINT [DF_tbTaskQuote_RunOnQuantity]  DEFAULT ((0)),
	[RunOnPrice] [money] NOT NULL CONSTRAINT [DF_tbTaskQuote_RunOnPrice]  DEFAULT ((0)),
	[RunBackQuantity] [float] NOT NULL CONSTRAINT [DF_tbTaskQuote_RunBackQuantity]  DEFAULT ((0)),
	[RunBackPrice] [float] NOT NULL CONSTRAINT [DF_tbTaskQuote_RunBackPrice]  DEFAULT ((0)),
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbTaskQuote_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbTaskQuote_InsertedOn]  DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbTaskQuote_UpdatedBy]  DEFAULT (suser_sname()),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbTaskQuote_UpdatedOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_tbTaskQuote] PRIMARY KEY CLUSTERED 
(
	[TaskCode] ASC,
	[Quantity] ASC
) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbTaskOp_OpStatusCode] ON [dbo].[tbTaskOp] 
(
	[OpStatusCode] ASC,
	[StartOn] ASC
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbTaskOp_UserIdOpStatus] ON [dbo].[tbTaskOp] 
(
	[UserId] ASC,
	[OpStatusCode] ASC,
	[StartOn] ASC
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbTaskOp]  WITH CHECK ADD  CONSTRAINT [FK_tbTaskOp_tbTask] FOREIGN KEY([TaskCode])
REFERENCES [dbo].[tbTask] ([TaskCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbTaskOp] CHECK CONSTRAINT [FK_tbTaskOp_tbTask]
GO
ALTER TABLE [dbo].[tbTaskOp]  WITH CHECK ADD  CONSTRAINT [FK_tbTaskOp_tbTaskOpStatus] FOREIGN KEY([OpStatusCode])
REFERENCES [dbo].[tbTaskOpStatus] ([OpStatusCode])
GO
ALTER TABLE [dbo].[tbTaskOp] CHECK CONSTRAINT [FK_tbTaskOp_tbTaskOpStatus]
GO
ALTER TABLE [dbo].[tbTaskOp]  WITH CHECK ADD  CONSTRAINT [FK_tbTaskOp_tbUser] FOREIGN KEY([UserId])
REFERENCES [dbo].[tbUser] ([UserId])
GO
ALTER TABLE [dbo].[tbTaskOp] CHECK CONSTRAINT [FK_tbTaskOp_tbUser]
GO
ALTER TABLE [dbo].[tbTaskOp]  WITH CHECK ADD  CONSTRAINT [FK_tbTaskOp_tbActivityOpType] FOREIGN KEY([OpTypeCode])
REFERENCES [dbo].[tbActivityOpType] ([OpTypeCode])
GO
ALTER TABLE [dbo].[tbTaskOp] CHECK CONSTRAINT [FK_tbTaskOp_tbActivityOpType]
GO
ALTER TABLE [dbo].[tbTaskQuote]  WITH CHECK ADD  CONSTRAINT [FK_tbTaskQuote_tbTask] FOREIGN KEY([TaskCode])
REFERENCES [dbo].[tbTask] ([TaskCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbTaskQuote] CHECK CONSTRAINT [FK_tbTaskQuote_tbTask]
GO
ALTER VIEW [dbo].[vwTaskProfitOrders]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbTask.ActionOn) AS StartOn, dbo.tbTask.TaskCode, 
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
go

ALTER TRIGGER [dbo].[Trigger_tbTask_Update]
ON [dbo].[tbTask] 
FOR UPDATE
AS
	IF UPDATE (ContactName)
		begin
		if exists (SELECT     ContactName
		           FROM         inserted AS i
		           WHERE     (NOT (ContactName IS NULL)) AND
		                                 (ContactName <> N''))
			begin
			if not exists(SELECT     tbOrgContact.ContactName
			              FROM         inserted AS i INNER JOIN
			                                    tbOrgContact ON i.AccountCode = tbOrgContact.AccountCode AND i.ContactName = tbOrgContact.ContactName)
				begin
				declare @FileAs nvarchar(100)
				declare @ContactName nvarchar(100)
				declare @NickName nvarchar(100)
								
				select TOP 1 @ContactName = isnull(ContactName, '') from inserted	 
				
				if len(@ContactName) > 0
					begin
					set @NickName = left(@ContactName, charindex(' ', @ContactName, 1))
					exec dbo.spOrgContactFileAs @ContactName, @FileAs output
					
					INSERT INTO tbOrgContact
										(AccountCode, ContactName, FileAs, NickName)
					SELECT TOP 1 AccountCode, ContactName, @FileAs AS FileAs, @NickName as NickName
					FROM  inserted
					end
				end                                   
			end		
		
		
		end

	declare @TaskCode nvarchar(20)

	IF UPDATE (TaskStatusCode)
		begin
		declare @TaskStatusCode smallint
		select @TaskCode = TaskCode, @TaskStatusCode = TaskStatusCode from inserted
		if @TaskStatusCode <> 4
			begin
			exec dbo.spTaskSetStatus @TaskCode
			end				
		end
		
	
	if UPDATE (ActionOn)
		begin
		declare @ActionOn datetime
		select @TaskCode = TaskCode, @ActionOn = ActionOn from inserted		
		exec dbo.spTaskScheduleOp @TaskCode, @ActionOn
		end
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
	
	set @CollectOn = GETDATE()
	exec dbo.spTaskDefaultPaymentOn @AccountCode, @InvoicedOn, @CollectOn output
	
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
CREATE PROCEDURE dbo.spSystemAdjustToCalendar
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
ALTER TABLE dbo.tbTask WITH NOCHECK ADD
	SecondReference nvarchar(20) NULL
GO
ALTER VIEW dbo.vwTasks
AS
SELECT     dbo.tbTask.TaskCode, dbo.tbTask.UserId, dbo.tbTask.AccountCode, dbo.tbTask.ContactName, dbo.tbTask.ActivityCode, dbo.tbTask.TaskTitle, 
                      dbo.tbTask.TaskStatusCode, dbo.tbTask.ActionById, dbo.tbTask.ActionOn, dbo.tbTask.ActionedOn, dbo.tbTask.PaymentOn, 
                      dbo.tbTask.SecondReference, dbo.tbTask.TaskNotes, dbo.tbTask.TaxCode, dbo.tbTask.Quantity, dbo.tbTask.UnitCharge, dbo.tbTask.TotalCharge, 
                      dbo.tbTask.AddressCodeFrom, dbo.tbTask.AddressCodeTo, dbo.tbTask.Printed, dbo.tbTask.InsertedBy, dbo.tbTask.InsertedOn, dbo.tbTask.UpdatedBy, 
                      dbo.tbTask.UpdatedOn, dbo.vwTaskBucket.Period, dbo.tbSystemBucket.BucketId, dbo.tbTaskStatus.TaskStatus, dbo.tbTask.CashCode, 
                      dbo.tbCashCode.CashDescription, tbUser_1.UserName AS OwnerName, dbo.tbUser.UserName AS ActionName, dbo.tbOrg.AccountName, 
                      dbo.tbOrgStatus.OrganisationStatus, dbo.tbOrgType.OrganisationType, CASE WHEN tbCashCategory.CategoryCode IS NULL 
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
ALTER PROCEDURE dbo.spTaskCopy
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
                      (TaskCode, UserId, AccountCode, TaskTitle, ContactName, ActivityCode, TaskStatusCode, ActionById, ActionOn, TaskNotes, Quantity, SecondReference, 
                      CashCode, TaxCode, UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, PaymentOn, Printed)
SELECT     @ToTaskCode AS ToTaskCode, UserId, AccountCode, TaskTitle, ContactName, ActivityCode, @TaskStatusCode AS TaskStatus, ActionById, ActionOn, 
                      TaskNotes, Quantity, SecondReference, CashCode, TaxCode, UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, PaymentOn, 
                      @Printed AS Printed
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
	SELECT     @ToTaskCode AS ToTaskCode, OperationNumber, 1 AS OpStatus, UserId, OpTypeCode, Operation, Note, StartOn, EndOn, Duration, OffsetDays
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
CREATE PROCEDURE dbo.spTaskSetOpStatus
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
ALTER PROCEDURE dbo.spTaskSetStatus
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
		
		if @IsOrder = 1
			begin
			UPDATE    tbTask
			SET              TaskStatusCode = @TaskStatusCode
			WHERE     (TaskCode = @ChildTaskCode) AND (TaskStatusCode < 3) AND (NOT (CashCode IS NULL))
			exec dbo.spTaskSetOpStatus @ChildTaskCode, @TaskStatusCode
			end
		else
			begin
			UPDATE    tbTask
			SET              TaskStatusCode = @TaskStatusCode
			WHERE     (TaskCode = @ChildTaskCode) AND (TaskStatusCode < 3) AND (CashCode IS NULL)			
			end		
			
		exec dbo.spTaskSetStatus @ChildTaskCode
		fetch next from curTask into @ChildTaskCode
		end
		
	close curTask
	deallocate curTask
		
	RETURN 
GO
ALTER PROCEDURE dbo.spTaskConfigure 
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
CREATE PROCEDURE dbo.spTaskScheduleOp
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
ALTER  PROCEDURE dbo.spTaskSchedule
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
	
	if exists(SELECT TOP 1 OperationNumber
	          FROM         tbTaskOp
	          WHERE     (TaskCode = @ParentTaskCode))
		begin
		exec dbo.spTaskScheduleOp @ParentTaskCode, @ActionOn
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
ALTER TRIGGER Trigger_tbTask_Update
ON dbo.tbTask 
FOR UPDATE
AS
	IF UPDATE (ContactName)
		begin
		if exists (SELECT     ContactName
		           FROM         inserted AS i
		           WHERE     (NOT (ContactName IS NULL)) AND
		                                 (ContactName <> N''))
			begin
			if not exists(SELECT     tbOrgContact.ContactName
			              FROM         inserted AS i INNER JOIN
			                                    tbOrgContact ON i.AccountCode = tbOrgContact.AccountCode AND i.ContactName = tbOrgContact.ContactName)
				begin
				declare @FileAs nvarchar(100)
				declare @ContactName nvarchar(100)
				declare @NickName nvarchar(100)
								
				select TOP 1 @ContactName = isnull(ContactName, '') from inserted	 
				
				if len(@ContactName) > 0
					begin
					set @NickName = left(@ContactName, charindex(' ', @ContactName, 1))
					exec dbo.spOrgContactFileAs @ContactName, @FileAs output
					
					INSERT INTO tbOrgContact
										(AccountCode, ContactName, FileAs, NickName)
					SELECT TOP 1 AccountCode, ContactName, @FileAs AS FileAs, @NickName as NickName
					FROM  inserted
					end
				end                                   
			end		
		
		
		end

	declare @TaskCode nvarchar(20)

	IF UPDATE (TaskStatusCode)
		begin
		declare @TaskStatusCode smallint
		select @TaskCode = TaskCode, @TaskStatusCode = TaskStatusCode from inserted
		if @TaskStatusCode <> 4
			begin
			exec dbo.spTaskSetStatus @TaskCode
			end				
		end
		
	
	if UPDATE (ActionOn)
		begin
		declare @ActionOn datetime
		select @TaskCode = TaskCode, @ActionOn = ActionOn from inserted		
		exec dbo.spTaskScheduleOp @TaskCode, @ActionOn
		end
GO
CREATE PROCEDURE dbo.spTaskSetActionOn
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
		
	UPDATE tbTask
	SET ActionOn = @ActionOn
	WHERE     (TaskCode = @TaskCode) AND (ActionOn <> @ActionOn)
		
	RETURN
GO
ALTER VIEW [dbo].[vwDocTaskCode]
AS
SELECT     dbo.fnTaskEmailAddress(dbo.tbTask.TaskCode) AS EmailAddress, dbo.tbTask.TaskCode, dbo.tbTask.TaskStatusCode, dbo.tbTaskStatus.TaskStatus, 
                      dbo.tbTask.ContactName, dbo.tbOrgContact.NickName, dbo.tbUser.UserName, dbo.tbOrg.AccountName, dbo.tbOrgAddress.Address AS InvoiceAddress, 
                      tbOrg_1.AccountName AS DeliveryAccountName, tbOrgAddress_1.Address AS DeliveryAddress, tbOrg_2.AccountName AS CollectionAccountName, 
                      tbOrgAddress_2.Address AS CollectionAddress, dbo.tbTask.AccountCode, dbo.tbTask.TaskNotes, dbo.tbTask.ActivityCode, dbo.tbTask.ActionOn, 
                      dbo.tbActivity.UnitOfMeasure, dbo.tbTask.Quantity, dbo.tbSystemTaxCode.TaxCode, dbo.tbSystemTaxCode.TaxRate, dbo.tbTask.UnitCharge, 
                      dbo.tbTask.TotalCharge, dbo.tbUser.MobileNumber, dbo.tbUser.Signature, dbo.tbTask.TaskTitle, dbo.tbTask.PaymentOn, 
                      dbo.tbTask.SecondReference
FROM         dbo.tbOrg AS tbOrg_2 RIGHT OUTER JOIN
                      dbo.tbOrgAddress AS tbOrgAddress_2 ON tbOrg_2.AccountCode = tbOrgAddress_2.AccountCode RIGHT OUTER JOIN
                      dbo.tbTaskStatus INNER JOIN
                      dbo.tbUser INNER JOIN
                      dbo.tbActivity INNER JOIN
                      dbo.tbTask ON dbo.tbActivity.ActivityCode = dbo.tbTask.ActivityCode INNER JOIN
                      dbo.tbOrg ON dbo.tbTask.AccountCode = dbo.tbOrg.AccountCode LEFT OUTER JOIN
                      dbo.tbOrgAddress ON dbo.tbOrg.AddressCode = dbo.tbOrgAddress.AddressCode ON dbo.tbUser.UserId = dbo.tbTask.ActionById ON 
                      dbo.tbTaskStatus.TaskStatusCode = dbo.tbTask.TaskStatusCode LEFT OUTER JOIN
                      dbo.tbOrgAddress AS tbOrgAddress_1 LEFT OUTER JOIN
                      dbo.tbOrg AS tbOrg_1 ON tbOrgAddress_1.AccountCode = tbOrg_1.AccountCode ON dbo.tbTask.AddressCodeTo = tbOrgAddress_1.AddressCode ON 
                      tbOrgAddress_2.AddressCode = dbo.tbTask.AddressCodeFrom LEFT OUTER JOIN
                      dbo.tbOrgContact ON dbo.tbTask.ContactName = dbo.tbOrgContact.ContactName AND 
                      dbo.tbTask.AccountCode = dbo.tbOrgContact.AccountCode LEFT OUTER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbTask.TaxCode = dbo.tbSystemTaxCode.TaxCode
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
CREATE VIEW [dbo].[vwTaskOpBucket]
AS
SELECT     TaskCode, OperationNumber, dbo.fnSystemDateBucket(GETDATE(), EndOn) AS Period
FROM         dbo.tbTaskOp
GO
CREATE VIEW [dbo].[vwTaskOps]
AS
SELECT     dbo.tbTaskOp.TaskCode, dbo.tbTaskOp.OperationNumber, dbo.vwTaskOpBucket.Period, dbo.tbSystemBucket.BucketId, dbo.tbTaskOp.UserId, 
                      dbo.tbTaskOp.OpTypeCode, dbo.tbTaskOp.OpStatusCode, dbo.tbTaskOp.Operation, dbo.tbTaskOp.Note, dbo.tbTaskOp.StartOn, dbo.tbTaskOp.EndOn, 
                      dbo.tbTaskOp.Duration, dbo.tbTaskOp.OffsetDays, dbo.tbTaskOp.InsertedBy, dbo.tbTaskOp.InsertedOn, dbo.tbTaskOp.UpdatedBy, 
                      dbo.tbTaskOp.UpdatedOn, dbo.tbTask.TaskTitle, dbo.tbTaskStatus.TaskStatus, dbo.tbTask.ActionOn, dbo.tbTask.Quantity, 
                      dbo.tbCashCode.CashDescription, dbo.tbTask.TotalCharge, dbo.tbTask.AccountCode, dbo.tbOrg.AccountName
FROM         dbo.tbTaskOp INNER JOIN
                      dbo.tbTask ON dbo.tbTaskOp.TaskCode = dbo.tbTask.TaskCode INNER JOIN
                      dbo.tbOrg ON dbo.tbTask.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbTaskStatus ON dbo.tbTask.TaskStatusCode = dbo.tbTaskStatus.TaskStatusCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.vwTaskOpBucket ON dbo.tbTaskOp.TaskCode = dbo.vwTaskOpBucket.TaskCode AND 
                      dbo.tbTaskOp.OperationNumber = dbo.vwTaskOpBucket.OperationNumber INNER JOIN
                      dbo.tbSystemBucket ON dbo.vwTaskOpBucket.Period = dbo.tbSystemBucket.Period
GO
