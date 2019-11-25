/************************************************************
* Tru-Man Trade Control: Information and Cash System
* Copyright Tru-Man Industries Ltd 2008. All Rights Reserved.
* Author: Ian Monnox
* Description: Sql Server Upgrade Script - Encrypted Distribution Schema
* Data Version: 1.03
* Release Date: 8/5/8
************************************************************/

ALTER PROCEDURE dbo.spTaskCost 
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
alter table dbo.tbOrgContact with nocheck add
	HomeNumber nvarchar(50) null
GO
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'HomeNumber', 1, 'Home No.', '', '', 50, 1, '')
GO
ALTER TRIGGER Trigger_tbTask_Update
ON dbo.tbTask 
FOR UPDATE
AS
	IF UPDATE (ContactName)
		begin
		if exists (SELECT     ContactName
		           FROM         inserted AS i
		           WHERE     (NOT (ContactName IS NULL)) OR
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

	IF UPDATE (TaskStatusCode)
		begin
		declare @TaskStatusCode smallint
		declare @TaskCode nvarchar(20)
		select @TaskCode = TaskCode, @TaskStatusCode = TaskStatusCode from inserted
		if @TaskStatusCode <> 4
			begin
			exec dbo.spTaskSetStatus @TaskCode
			end
		
		
		end
GO
ALTER TABLE [dbo].[tbOrgSector] DROP CONSTRAINT FK_tbOrgSector_tbSystemSector
GO
DROP TABLE [dbo].[tbOrgSector]
GO
CREATE TABLE [dbo].[tbOrgSector] (
	[AccountCode] [nvarchar] (10) NOT NULL ,
	[IndustrySector] [nvarchar] (50) NOT NULL 
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbOrgSector] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbOrgSector] PRIMARY KEY  CLUSTERED 
	(
		[AccountCode],
		[IndustrySector]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbOrgSector] ADD 
	CONSTRAINT [FK_tbOrgSector_tbOrg] FOREIGN KEY 
	(
		[AccountCode]
	) REFERENCES [dbo].[tbOrg] (
		[AccountCode]
	) ON DELETE CASCADE  ON UPDATE CASCADE 
GO
 CREATE  INDEX [IX_tbOrgSector_IndustrySector] ON [dbo].[tbOrgSector]([IndustrySector]) ON [PRIMARY]
GO
INSERT INTO tbOrgSector
                      (AccountCode, IndustrySector)
SELECT     AccountCode, IndustrySector
FROM         tbOrg
WHERE     (NOT (IndustrySector IS NULL))
GO
CREATE FUNCTION dbo.fnOrgIndustrySectors
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
drop view [dbo].[vwOrgTaskCount]
GO
drop view [dbo].[vwOrgDatasheet]
GO
CREATE VIEW dbo.vwOrgTaskCount
AS
SELECT     AccountCode, COUNT(TaskCode) AS TaskCount
FROM         dbo.tbTask
WHERE     (TaskStatusCode < 3)
GROUP BY AccountCode
GO
CREATE VIEW dbo.vwOrgDatasheet
AS
SELECT     dbo.tbOrg.AccountCode, dbo.tbOrg.AccountName, ISNULL(dbo.vwOrgTaskCount.TaskCount, 0) AS Tasks, dbo.tbOrg.OrganisationTypeCode, 
                      dbo.tbOrgType.OrganisationType, dbo.tbOrgType.CashModeCode, dbo.tbOrg.OrganisationStatusCode, dbo.tbOrgStatus.OrganisationStatus, 
                      dbo.tbOrgAddress.Address, dbo.tbSystemTaxCode.TaxDescription, dbo.tbOrg.TaxCode, dbo.tbOrg.AddressCode, dbo.tbOrg.AreaCode, 
                      dbo.tbOrg.PhoneNumber, dbo.tbOrg.FaxNumber, dbo.tbOrg.EmailAddress, dbo.tbOrg.WebSite, dbo.fnOrgIndustrySectors(dbo.tbOrg.AccountCode) 
                      AS IndustrySector, dbo.tbOrg.AccountSource, dbo.tbOrg.PaymentTerms, dbo.tbOrg.NumberOfEmployees, dbo.tbOrg.CompanyNumber, 
                      dbo.tbOrg.VatNumber, dbo.tbOrg.Turnover, dbo.tbOrg.StatementDays, dbo.tbOrg.OpeningBalance, dbo.tbOrg.CurrentBalance, 
                      dbo.tbOrg.ForeignJurisdiction, dbo.tbOrg.BusinessDescription, dbo.tbOrg.InsertedBy, dbo.tbOrg.InsertedOn, dbo.tbOrg.UpdatedBy, 
                      dbo.tbOrg.UpdatedOn
FROM         dbo.tbOrg INNER JOIN
                      dbo.tbOrgStatus ON dbo.tbOrg.OrganisationStatusCode = dbo.tbOrgStatus.OrganisationStatusCode INNER JOIN
                      dbo.tbOrgType ON dbo.tbOrg.OrganisationTypeCode = dbo.tbOrgType.OrganisationTypeCode LEFT OUTER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbOrg.TaxCode = dbo.tbSystemTaxCode.TaxCode LEFT OUTER JOIN
                      dbo.tbOrgAddress ON dbo.tbOrg.AddressCode = dbo.tbOrgAddress.AddressCode LEFT OUTER JOIN
                      dbo.vwOrgTaskCount ON dbo.tbOrg.AccountCode = dbo.vwOrgTaskCount.AccountCode
GO
/*****************************
User Id Changes
****/


ALTER TABLE [dbo].[tbInvoice] DROP CONSTRAINT FK_tbInvoice_tbUser1
GO
ALTER TABLE [dbo].[tbOrgPayment] DROP CONSTRAINT FK_tbOrgPayment_tbUser1
GO
ALTER TABLE [dbo].[tbTask] DROP CONSTRAINT FK_tbTask_tbUser
GO
ALTER TABLE [dbo].[tbTask] DROP CONSTRAINT FK_tbTask_tbUser1
GO
ALTER TABLE [dbo].[tbUserMenu] DROP CONSTRAINT FK_tbUserMenu_tbUser1
GO
alter table dbo.tbUser 
	drop constraint aaaaatbUser_PK
GO
alter table dbo.tbUser
	alter column UserId nvarchar(10) not null
GO
alter table dbo.tbUser WITH NOCHECK ADD 
	NextTaskNumber int NOT NULL CONSTRAINT [DF_tbUser_NextTaskNumber]  DEFAULT ((1))
	CONSTRAINT [PK_tbUser] PRIMARY KEY  CLUSTERED 
	(
		UserId
	)  ON [PRIMARY] 
GO
alter table dbo.tbUserMenu
	drop constraint PK_tbUserMenu
GO
alter table dbo.tbUserMenu
	alter column UserId nvarchar(10) not null
GO
alter table dbo.tbUserMenu WITH NOCHECK ADD 
	CONSTRAINT [PK_tbUserMenu] PRIMARY KEY  CLUSTERED 
	(
		UserId,
		MenuId
	)  ON [PRIMARY] 
GO
drop index dbo.tbInvoice.IX_tbInvoice_UserId
GO
alter table dbo.tbInvoice
	alter column UserId nvarchar(10) not null
GO
CREATE  INDEX [IX_tbInvoice_UserId] ON [dbo].[tbInvoice]([UserId], [InvoiceNumber]) ON [PRIMARY]
GO
alter table dbo.tbOrgPayment
	alter column UserId nvarchar(10) not null
GO
drop index dbo.tbTask.IX_tbTask_UserId
GO
drop index dbo.tbTask.IX_tbTask_ActionBy
GO
drop index dbo.tbTask.IX_tbTask_ActionById
GO
alter table dbo.tbTask
	alter column UserId nvarchar(10) not null
GO
alter table dbo.tbTask
	alter column ActionById nvarchar(10) not null
GO
 CREATE  INDEX [IX_tbTask_UserId] ON [dbo].[tbTask]([UserId]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbTask_ActionBy] ON [dbo].[tbTask]([ActionById], [TaskStatusCode], [ActionOn]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbTask_ActionById] ON [dbo].[tbTask]([ActionById]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbInvoice] ADD 
	CONSTRAINT [FK_tbInvoice_tbUser1] FOREIGN KEY 
	(
		[UserId]
	) REFERENCES [dbo].[tbUser] (
		[UserId]
	) ON UPDATE CASCADE 
GO
ALTER TABLE [dbo].[tbOrgPayment] ADD 
	CONSTRAINT [FK_tbOrgPayment_tbUser1] FOREIGN KEY 
	(
		[UserId]
	) REFERENCES [dbo].[tbUser] (
		[UserId]
	) ON UPDATE CASCADE 
GO
ALTER TABLE [dbo].[tbUserMenu] ADD 
	CONSTRAINT [FK_tbUserMenu_tbUser1] FOREIGN KEY 
	(
		[UserId]
	) REFERENCES [dbo].[tbUser] (
		[UserId]
	) ON UPDATE CASCADE 
GO
ALTER TABLE [dbo].[tbTask] ADD 
	CONSTRAINT [FK_tbTask_tbUser] FOREIGN KEY 
	(
		[UserId]
	) REFERENCES [dbo].[tbUser] (
		[UserId]
	) ON UPDATE CASCADE ,
	CONSTRAINT [FK_tbTask_tbUser1] FOREIGN KEY 
	(
		[ActionById]
	) REFERENCES [dbo].[tbUser] (
		[UserId]
	)
GO
ALTER FUNCTION dbo.fnSystemAdjustToCalendar
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
ALTER PROCEDURE dbo.spInvoiceCredit
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
ALTER PROCEDURE dbo.spInvoiceRaiseBlank
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
ALTER PROCEDURE dbo.spInvoiceRaise
	(
	@TaskCode nvarchar(20),
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
		
	begin tran Invoice
	
	exec dbo.spInvoiceCancel
	
	UPDATE    tbInvoiceType
	SET              NextNumber = @NextNumber + 1
	WHERE     (InvoiceTypeCode = @InvoiceTypeCode)
	
	INSERT INTO tbInvoice
						  (InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoicedOn, InvoiceStatusCode, PaymentTerms)
	SELECT     @InvoiceNumber AS InvoiceNumber, @UserId AS UserId, tbTask.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, GETDATE() AS InvoicedOn, 
						  1 AS InvoiceStatusCode, tbOrg.PaymentTerms
	FROM         tbTask INNER JOIN
						  tbOrg ON tbTask.AccountCode = tbOrg.AccountCode
	WHERE     (tbTask.TaskCode = @TaskCode)
	
	exec dbo.spInvoiceAddTask @InvoiceNumber, @TaskCode
	
	commit tran Invoice
	
	RETURN
GO
ALTER PROCEDURE dbo.spPaymentPostMisc
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
	                      4 AS InvoiceStatusCode, tbOrgPayment.PaidOn, CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue * (1 - tbSystemTaxCode.TaxRate) 
	                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue * (1 - tbSystemTaxCode.TaxRate) END AS InvoiceValue, 
	                      CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue * tbSystemTaxCode.TaxRate WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue
	                       * tbSystemTaxCode.TaxRate END AS TaxValue, CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue * (1 - tbSystemTaxCode.TaxRate) 
	                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue * (1 - tbSystemTaxCode.TaxRate) END AS PaidValue, 
	                      CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue * tbSystemTaxCode.TaxRate WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue
	                       * tbSystemTaxCode.TaxRate END AS PaidTaxValue, 1 AS Printed
	FROM         tbOrgPayment INNER JOIN
	                      tbSystemTaxCode ON tbOrgPayment.TaxCode = tbSystemTaxCode.TaxCode
	WHERE PaymentCode = @PaymentCode


INSERT INTO tbInvoiceItem
                      (InvoiceNumber, CashCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, TaxCode)
SELECT     @InvoiceNumber AS InvoiceNumber, tbOrgPayment.CashCode, 
                      CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue * (1 - tbSystemTaxCode.TaxRate) 
                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue * (1 - tbSystemTaxCode.TaxRate) END AS InvoiceValue, 
                      CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue * tbSystemTaxCode.TaxRate WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue
                       * tbSystemTaxCode.TaxRate END AS TaxValue, CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue * (1 - tbSystemTaxCode.TaxRate) 
                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue * (1 - tbSystemTaxCode.TaxRate) END AS PaidValue, 
                      CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue * tbSystemTaxCode.TaxRate WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue
                       * tbSystemTaxCode.TaxRate END AS PaidTaxValue, tbOrgPayment.TaxCode
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
			TaxInValue = TaxInValue + (PaidInValue * TaxRate),
			TaxOutValue = TaxOutValue + (PaidOutValue * TaxRate)
	FROM         tbOrgPayment INNER JOIN
	                      tbSystemTaxCode ON tbOrgPayment.TaxCode = tbSystemTaxCode.TaxCode
	WHERE     (PaymentCode = @PaymentCode)
	
	RETURN
GO
ALTER PROCEDURE dbo.spSystemReassignUser 
	(
	@UserId nvarchar(10)
	)
AS
	UPDATE    tbUser
	SET       LogonName = (SUSER_SNAME())
	WHERE     (UserId = @UserId)
	
	RETURN
GO
CREATE PROCEDURE dbo.spTaskNextCode
	(
		@TaskCode nvarchar(20) OUTPUT
	)
AS
declare @UserId nvarchar(10)
declare @NextTaskNumber int

	SELECT   @UserId = tbUser.UserId, @NextTaskNumber = tbUser.NextTaskNumber
	FROM         vwUserCredentials INNER JOIN
	                      tbUser ON vwUserCredentials.UserId = tbUser.UserId
	                      
	set @TaskCode = @UserId + '_' + dbo.fnPad(ltrim(str(@NextTaskNumber)), 4)
	update dbo.tbUser
	Set NextTaskNumber = NextTaskNumber + 1
	where UserId = @UserId
		                      
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
		exec dbo.spTaskNextCode @TaskCode output
		
		INSERT INTO tbTask
							  (TaskCode, UserId, AccountCode, ContactName, ActivityCode, TaskStatusCode, ActionById, ActionOn, TaskNotes, UnitCharge, AddressCodeFrom, 
							  AddressCodeTo, CashCode, TaxCode, Printed, TaskTitle)
		SELECT     @TaskCode AS NewTask, tbTask_1.UserId, tbTask_1.AccountCode, tbTask_1.ContactName, tbActivity.ActivityCode, tbActivity.TaskStatusCode, 
							  tbTask_1.ActionById, tbTask_1.ActionOn, tbActivity.DefaultText, tbActivity.UnitCharge, tbOrg.AddressCode AS AddressCodeFrom, 
							  tbOrg.AddressCode AS AddressCodeTo, tbActivity.CashCode, dbo.fnTaskDefaultTaxCode(tbTask_1.AccountCode, tbActivity.CashCode) AS TaxCode, 
							  CASE WHEN tbActivity.PrintOrder = 0 THEN 1 ELSE 0 END AS Printed, tbTask_1.TaskTitle
		FROM         tbActivityFlow INNER JOIN
							  tbActivity ON tbActivityFlow.ChildCode = tbActivity.ActivityCode INNER JOIN
							  tbTask AS tbTask_1 ON tbActivityFlow.ParentCode = tbTask_1.ActivityCode INNER JOIN
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
ALTER PROCEDURE dbo.spTaskSchedule
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

	if @ActionOn is null
		begin
		select @ActionOn = ActionOn, @UserId = ActionById 
		from tbTask where TaskCode = @ParentTaskCode
		
		if @ActionOn != dbo.fnSystemAdjustToCalendar(@UserId, @ActionOn, 0)
			begin
			update tbTask
			set ActionOn = dbo.fnSystemAdjustToCalendar(@UserId, @ActionOn, 0)
			where TaskCode = @ParentTaskCode and TaskStatusCode < 3			
			end
		end
	
	Select @Quantity = Quantity from tbTask where TaskCode = @ParentTaskCode
	
	declare curAct cursor local for
		SELECT     tbTaskFlow.StepNumber, tbTaskFlow.ChildTaskCode, tbTask.ActionById, tbTaskFlow.OffsetDays, tbTaskFlow.UsedOnQuantity
		FROM         tbTaskFlow INNER JOIN
		                      tbTask ON tbTaskFlow.ChildTaskCode = tbTask.TaskCode
		WHERE     (tbTaskFlow.ParentTaskCode = @ParentTaskCode)
		ORDER BY tbTaskFlow.StepNumber DESC
	
	open curAct
	fetch next from curAct into @StepNumber, @TaskCode, @UserId, @OffsetDays, @UsedOnQuantity
	while @@FETCH_STATUS = 0
		begin
		set @ActionOn = dbo.fnSystemAdjustToCalendar(@UserId, @ActionOn, @OffsetDays)
		
		update tbTask
		set ActionOn = @ActionOn, 
			Quantity = @Quantity * @UsedOnQuantity,
			TotalCharge = case when @UsedOnQuantity = 0 then UnitCharge else UnitCharge * @Quantity * @UsedOnQuantity end,
			UpdatedOn = getdate(),
			UpdatedBy = (suser_sname())
		where TaskCode = @TaskCode and TaskStatusCode < 3
		
		exec dbo.spTaskSchedule @TaskCode, @ActionOn output
		fetch next from curAct into @StepNumber, @TaskCode, @UserId, @OffsetDays, @UsedOnQuantity
		end
	
	close curAct
	deallocate curAct	
	
	RETURN
GO
ALTER PROCEDURE dbo.spSettingNewCompany
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
						(Identifier, Initialised, SQLDataVersion, AccountCode, DefaultPrintMode, BucketTypeCode, BucketIntervalCode, ShowCashGraphs, EmployersNI, 
						CorporationTax, Vat, GeneralTax)
	VALUES     (N'TRU', 0, @SQLDataVersion, @AppAccountCode, 2, 1, 2, 1, N'900', N'902', N'901', N'903')

	RETURN 1 
GO
drop view [dbo].[vwUserCredentials]
GO
CREATE VIEW [dbo].[vwUserCredentials]
AS
SELECT     UserId, UserName, LogonName, Administrator
FROM         dbo.tbUser
WHERE     (LogonName = SUSER_SNAME())
GO
ALTER  VIEW [dbo].[vwTasks]
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
