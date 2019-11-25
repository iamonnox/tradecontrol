CREATE TRIGGER Invoice_tbInvoice_TriggerUpdate
ON Invoice.tbInvoice
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
		WHERE    (i.Spooled = 0) AND ( App.tbDocSpool.DocTypeCode > 4)
		END

GO
ALTER TABLE Invoice.tbInvoice ENABLE TRIGGER Invoice_tbInvoice_TriggerUpdate
GO
CREATE TRIGGER Org_tbAddress_TriggerInsert
ON Org.tbAddress 
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
ALTER TABLE Org.tbAddress ENABLE TRIGGER Org_tbAddress_TriggerInsert
GO
CREATE TRIGGER Org.Org_tbPayment_TriggerUpdate
ON Org.tbPayment
FOR UPDATE
AS
	SET NOCOUNT ON;
	
	UPDATE Org.tbPayment
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = SYSDATETIME()
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
ALTER TABLE Org.tbPayment ENABLE TRIGGER Org_tbPayment_TriggerUpdate
GO
CREATE TRIGGER Task.Task_tbTask_TriggerInsert
ON Task.tbTask
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
ALTER TABLE Task.tbTask ENABLE TRIGGER Task_tbTask_TriggerInsert
GO
CREATE TRIGGER Task.Task_tbTask_TriggerUpdate
ON Task.tbTask
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
		WHERE    (i.Spooled = 0) AND ( App.tbDocSpool.DocTypeCode <= 4)
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
			IF @TaskStatusCode <> 4
				EXEC Task.proc_SetStatus @TaskCode
			ELSE
				EXEC Task.proc_SetOpStatus @TaskCode, @TaskStatusCode

			FETCH NEXT FROM tasks INTO @TaskCode, @TaskStatusCode
			END

		CLOSE tasks
		DEALLOCATE tasks			
		END
		
	
	if UPDATE (ActionOn) AND EXISTS (SELECT * FROM App.tbOptions WHERE ScheduleOps <> 0)
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
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = SYSDATETIME()
	FROM Task.tbTask INNER JOIN inserted AS i ON tbTask.TaskCode = i.TaskCode;

	SET NOCOUNT OFF;
GO
ALTER TABLE Task.tbTask ENABLE TRIGGER Task_tbTask_TriggerUpdate
GO
CREATE TRIGGER Activity_tbOp_TriggerUpdate 
   ON  Activity.tbOp 
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	UPDATE Activity.tbOp
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = SYSDATETIME()
	FROM Activity.tbOp INNER JOIN inserted AS i ON tbOp.ActivityCode = i.ActivityCode AND tbOp.OperationNumber = i.OperationNumber;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE Activity.tbOp ENABLE TRIGGER Activity_tbOp_TriggerUpdate;
GO
CREATE TRIGGER Task_tbOp_TriggerUpdate 
   ON  Task.tbOp 
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Task.tbOp
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = SYSDATETIME()
	FROM Task.tbOp INNER JOIN inserted AS i ON tbOp.TaskCode = i.TaskCode AND tbOp.OperationNumber = i.OperationNumber;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE Task.tbOp ENABLE TRIGGER Task_tbOp_TriggerUpdate;
GO
CREATE TRIGGER Usr_tbMenuEntry_TriggerUpdate 
   ON  Usr.tbMenuEntry
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Usr.tbMenuEntry
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = SYSDATETIME()
	FROM Usr.tbMenuEntry INNER JOIN inserted AS i ON tbMenuEntry.EntryId = i.EntryId AND tbMenuEntry.EntryId = i.EntryId;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE Usr.tbMenuEntry ENABLE TRIGGER Usr_tbMenuEntry_TriggerUpdate;
GO
CREATE TRIGGER Org_tbOrg_TriggerUpdate 
   ON  Org.tbOrg
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
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = SYSDATETIME()
		FROM Org.tbOrg INNER JOIN inserted AS i ON tbOrg.AccountCode = i.AccountCode;
		END

	SET NOCOUNT OFF;
END
GO
ALTER TABLE Org.tbOrg ENABLE TRIGGER Org_tbOrg_TriggerUpdate;
GO
CREATE TRIGGER Usr_tbUser_TriggerUpdate 
   ON  Usr.tbUser
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Usr.tbUser
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = SYSDATETIME()
	FROM Usr.tbUser INNER JOIN inserted AS i ON tbUser.UserId = i.UserId;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE Usr.tbUser ENABLE TRIGGER Usr_tbUser_TriggerUpdate;
GO
CREATE TRIGGER Org_tbAddress_TriggerUpdate 
   ON  Org.tbAddress
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Org.tbAddress
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = SYSDATETIME()
	FROM Org.tbAddress INNER JOIN inserted AS i ON tbAddress.AddressCode = i.AddressCode;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE Org.tbAddress ENABLE TRIGGER Org_tbAddress_TriggerUpdate;
GO
CREATE TRIGGER App_tbOptions_TriggerUpdate 
   ON  App.tbOptions
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE App.tbOptions
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = SYSDATETIME()
	FROM App.tbOptions INNER JOIN inserted AS i ON tbOptions.Identifier = i.Identifier;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE App.tbOptions ENABLE TRIGGER App_tbOptions_TriggerUpdate;
GO
CREATE TRIGGER Activity.Activity_tbActivity_TriggerUpdate 
   ON  Activity.tbActivity
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
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = SYSDATETIME()
		FROM Activity.tbActivity INNER JOIN inserted AS i ON tbActivity.ActivityCode = i.ActivityCode;
		END

	SET NOCOUNT OFF;
END
GO
ALTER TABLE Activity.tbActivity ENABLE TRIGGER Activity_tbActivity_TriggerUpdate;
GO
CREATE TRIGGER Cash_tbCategory_TriggerUpdate 
   ON  Cash.tbCategory
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Cash.tbCategory
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = SYSDATETIME()
	FROM Cash.tbCategory INNER JOIN inserted AS i ON tbCategory.CategoryCode = i.CategoryCode;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE Cash.tbCategory ENABLE TRIGGER Cash_tbCategory_TriggerUpdate;
GO
CREATE TRIGGER Cash.Cash_tbCode_TriggerUpdate 
   ON  Cash.tbCode
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
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = SYSDATETIME()
		FROM Cash.tbCode INNER JOIN inserted AS i ON tbCode.CashCode = i.CashCode;
		END

	SET NOCOUNT OFF;
END
GO
ALTER TABLE Cash.tbCode ENABLE TRIGGER Cash_tbCode_TriggerUpdate;
GO
CREATE TRIGGER Org_tbContact_TriggerUpdate 
   ON  Org.tbContact
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Org.tbContact
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = SYSDATETIME()
	FROM Org.tbContact INNER JOIN inserted AS i ON tbContact.AccountCode = i.AccountCode AND tbContact.ContactName = i.ContactName;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE Org.tbContact ENABLE TRIGGER Org_tbContact_TriggerUpdate;
GO
CREATE TRIGGER Org_tbDoc_TriggerUpdate 
   ON  Org.tbDoc
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Org.tbDoc
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = SYSDATETIME()
	FROM Org.tbDoc INNER JOIN inserted AS i ON tbDoc.AccountCode = i.AccountCode AND tbDoc.DocumentName = i.DocumentName;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE Org.tbDoc ENABLE TRIGGER Org_tbDoc_TriggerUpdate;
GO
CREATE TRIGGER Activity_tbFlow_TriggerUpdate 
   ON  Activity.tbFlow
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Activity.tbFlow
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = SYSDATETIME()
	FROM Activity.tbFlow INNER JOIN inserted AS i ON tbFlow.ParentCode = i.ParentCode AND tbFlow.StepNumber = i.StepNumber;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE Activity.tbFlow ENABLE TRIGGER Activity_tbFlow_TriggerUpdate;
GO
CREATE TRIGGER Org.Org_tbAccount_TriggerUpdate 
   ON  Org.tbAccount
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
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = SYSDATETIME()
		FROM Org.tbAccount INNER JOIN inserted AS i ON tbAccount.CashAccountCode = i.CashAccountCode;
		END

	SET NOCOUNT OFF;
END
GO
ALTER TABLE Org.tbAccount ENABLE TRIGGER Org_tbAccount_TriggerUpdate;
GO
CREATE TRIGGER Task_tbAttribute_TriggerUpdate 
   ON  Task.tbAttribute
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Task.tbAttribute
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = SYSDATETIME()
	FROM Task.tbAttribute INNER JOIN inserted AS i ON tbAttribute.TaskCode = i.TaskCode AND tbAttribute.Attribute = i.Attribute;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE Task.tbAttribute ENABLE TRIGGER Task_tbAttribute_TriggerUpdate;
GO
CREATE TRIGGER Activity_tbAttribute_TriggerUpdate 
   ON  Activity.tbAttribute
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Activity.tbAttribute
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = SYSDATETIME()
	FROM Activity.tbAttribute INNER JOIN inserted AS i ON tbAttribute.ActivityCode = i.ActivityCode AND tbAttribute.Attribute = i.Attribute;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE Activity.tbAttribute ENABLE TRIGGER Activity_tbAttribute_TriggerUpdate;
GO
CREATE TRIGGER Task_tbDoc_TriggerUpdate 
   ON  Task.tbDoc
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Task.tbDoc
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = SYSDATETIME()
	FROM Task.tbDoc INNER JOIN inserted AS i ON tbDoc.TaskCode = i.TaskCode AND tbDoc.DocumentName = i.DocumentName;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE Task.tbDoc ENABLE TRIGGER Task_tbDoc_TriggerUpdate;
GO
CREATE TRIGGER Task_tbFlow_TriggerUpdate 
   ON  Task.tbFlow
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Task.tbFlow
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = SYSDATETIME()
	FROM Task.tbFlow INNER JOIN inserted AS i ON tbFlow.ParentTaskCode = i.ParentTaskCode AND tbFlow.StepNumber = i.StepNumber;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE Task.tbFlow ENABLE TRIGGER Task_tbFlow_TriggerUpdate;
GO
CREATE TRIGGER Task_tbQuote_TriggerUpdate 
   ON  Task.tbQuote
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Task.tbQuote
	SET UpdatedBy = SUSER_SNAME(), UpdatedOn = SYSDATETIME()
	FROM Task.tbQuote INNER JOIN inserted AS i ON tbQuote.TaskCode = i.TaskCode AND tbQuote.Quantity = i.Quantity;

	SET NOCOUNT OFF;
END
GO
ALTER TABLE Task.tbQuote ENABLE TRIGGER Task_tbQuote_TriggerUpdate;
GO
CREATE TRIGGER App.App_tbTaxCode_TriggerUpdate 
   ON  App.tbTaxCode
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
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = SYSDATETIME()
		FROM App.tbTaxCode INNER JOIN inserted AS i ON tbTaxCode.TaxCode = i.TaxCode;
		END

	SET NOCOUNT OFF;
END
GO
ALTER TABLE App.tbTaxCode ENABLE TRIGGER App_tbTaxCode_TriggerUpdate;
GO
CREATE TRIGGER App_tbCalendar_TriggerUpdate 
   ON  App.tbCalendar
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
CREATE TRIGGER App_tbCategory_TriggerUpdate 
   ON  Cash.tbCategory
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
CREATE TRIGGER App.App_tbUom_TriggerUpdate 
   ON  App.tbUom
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
