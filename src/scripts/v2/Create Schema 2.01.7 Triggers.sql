/****** Object:  Trigger [tbOrgAddress_TriggerInsert]    Script Date: 01/11/2012 13:37:03 ******/
GO
CREATE TRIGGER [dbo].[tbOrgAddress_TriggerInsert]
ON [dbo].[tbOrgAddress] 
FOR INSERT
AS
	If exists(SELECT     tbOrg.AddressCode, tbOrg.AccountCode
	          FROM         tbOrg INNER JOIN
	                                inserted AS i ON tbOrg.AccountCode = i.AccountCode
	          WHERE     (tbOrg.AddressCode IS NULL))
		begin
		UPDATE tbOrg
		SET AddressCode = i.AddressCode
		FROM         tbOrg INNER JOIN
	                                inserted AS i ON tbOrg.AccountCode = i.AccountCode
	          WHERE     (tbOrg.AddressCode IS NULL)
		end
GO
/****** Object:  Trigger [tbOrgPayment_TriggerUpdate]    Script Date: 01/11/2012 13:37:03 ******/
GO
CREATE TRIGGER [dbo].[tbOrgPayment_TriggerUpdate]
ON [dbo].[tbOrgPayment]
FOR UPDATE
AS
	IF UPDATE(PaidInValue) OR UPDATE(PaidOutValue)
		begin
		declare @AccountCode nvarchar(10)
		
		select @AccountCode = AccountCode from inserted
		
		exec dbo.spOrgRebuild @AccountCode
		exec dbo.spCashAccountRebuildAll
		
		end
GO
/****** Object:  Trigger [Trigger_tbTask_Update]    Script Date: 01/11/2012 13:37:03 ******/
GO
CREATE TRIGGER [dbo].[Trigger_tbTask_Update]
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
			exec dbo.spTaskSetStatus @TaskCode
		else
			exec dbo.spTaskSetOpStatus @TaskCode, @TaskStatusCode
					
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
