/************************************************************
* Tru-Man Trade Control: Management Information and Cash System
* Copyright Tru-Man Industries Ltd 2009. All Rights Reserved.
* Author: Ian Monnox
* Description: Sql Server Upgrade Script - Encrypted Distribution Schema
* Data Version: 1.12
* Release Date: 19 Feb 2010
************************************************************/
CREATE OR ALTER FUNCTION dbo.fnTaskDefaultPaymentOn
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

ALTER TABLE tbSystemOptions WITH NOCHECK ADD
	ScheduleOps bit NOT NULL CONSTRAINT DF_tbSystemOptions_ScheduleOps DEFAULT (1)
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
		declare @ScheduleOps bit		
		SELECT @ScheduleOps = ScheduleOps FROM tbSystemOptions
		IF (@ScheduleOps <> 0)
			BEGIN
			declare @ActionOn datetime
			select @TaskCode = TaskCode, @ActionOn = ActionOn from inserted		
			exec dbo.spTaskScheduleOp @TaskCode, @ActionOn
			END
		end
GO
