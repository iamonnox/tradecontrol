UPDATE App.tbOptions
SET SQLDataVersion = 3.05;
go
INSERT INTO App.tbRegister (RegisterName, NextNumber) VALUES ('Log', 1);
go

CREATE TABLE App.tbEventType (
	EventTypeCode SMALLINT NOT NULL,
	EventType NVARCHAR(15) NOT NULL,
	CONSTRAINT PK_tbFeedLogEventCode PRIMARY KEY CLUSTERED (EventTypeCode ASC)
) 
go

INSERT INTO App.tbEventType (EventTypeCode, EventType) 
VALUES (0, 'Error'), (1, 'Warning'), (2, 'Information');
go

CREATE TABLE App.tbEventLog 
(
	LogCode NVARCHAR(20),
	LoggedOn DATETIME NOT NULL CONSTRAINT DF_App_tbLog_LoggedOn DEFAULT (CURRENT_TIMESTAMP),
	EventTypeCode SMALLINT NOT NULL REFERENCES App.tbEventType (EventTypeCode) CONSTRAINT DF_App_tbLog_EventTypeCode DEFAULT (2),
	EventMessage NVARCHAR(MAX),
	InsertedBy NVARCHAR(50) NOT NULL CONSTRAINT DF_App_tbLog_InsertedBy DEFAULT (SUSER_SNAME())
	CONSTRAINT PK_App_tbEventLog_LogCode PRIMARY KEY (LogCode)
);
go	
CREATE NONCLUSTERED INDEX IDX_App_tbEventLog_LoggedOn ON App.tbEventLog (LoggedOn DESC)
CREATE NONCLUSTERED INDEX IDX_App_tbEventLog_EventType ON App.tbEventLog (EventTypeCode, LoggedOn)
go
CREATE VIEW App.vwEventLog
AS
	SELECT        App.tbEventLog.LogCode, App.tbEventLog.LoggedOn, App.tbEventLog.EventTypeCode, App.tbEventType.EventType, App.tbEventLog.EventMessage, App.tbEventLog.InsertedBy, App.tbEventLog.RowVer
	FROM            App.tbEventLog INNER JOIN
							 App.tbEventType ON App.tbEventLog.EventTypeCode = App.tbEventType.EventTypeCode
go
INSERT INTO Usr.tbMenuEntry
                         (MenuId, FolderId, ItemId, ItemText, Command, ProjectName, Argument, OpenMode)
VALUES        (1, 2, 4, N'Service Event Log', 2, N'Trader', N'App_EventLog', 1);
go
CREATE OR ALTER PROCEDURE App.proc_ErrorLog 
AS
DECLARE 
	@ErrorMessage NVARCHAR(MAX)
	, @ErrorSeverity TINYINT
	, @ErrorState TINYINT
	, @MessagePrefix nvarchar(4) = '*** ';
	
	IF @@TRANCOUNT > 0 
		ROLLBACK TRANSACTION;

	SET @ErrorSeverity = ERROR_SEVERITY();
	SET @ErrorState = ERROR_STATE();
	SET @ErrorMessage = ERROR_MESSAGE();

	IF @ErrorMessage NOT LIKE CONCAT(@MessagePrefix, '%')
		BEGIN
		SET @ErrorMessage = CONCAT(@MessagePrefix, ERROR_NUMBER(), ': ', QUOTENAME(ERROR_PROCEDURE()) + '.' + FORMAT(ERROR_LINE(), '0'),
			' Severity ', @ErrorSeverity, ', State ', @ErrorState, ' => ' + LEFT(ERROR_MESSAGE(), 1500));		

		EXEC App.proc_EventLog @ErrorMessage;
		END

	RAISERROR ('%s', @ErrorSeverity, @ErrorState, @ErrorMessage);
go
CREATE OR ALTER PROCEDURE [App].[proc_EventLog] (@EventMessage NVARCHAR(MAX), @EventTypeCode SMALLINT = 0, @LogCode NVARCHAR(20) = NULL OUTPUT)
AS
	SET XACT_ABORT, NOCOUNT ON;

	BEGIN TRY

		DECLARE 
			@UserId nvarchar(10)
			, @LogNumber INT
			, @RegisterName nvarchar(50) = 'Log';
	
		SET @UserId = (SELECT TOP 1 Usr.tbUser.UserId FROM Usr.vwCredentials c INNER JOIN
								Usr.tbUser ON c.UserId = Usr.tbUser.UserId);

		BEGIN TRANSACTION;
		
		WHILE (1 = 1)
			BEGIN
			SET @LogNumber = FORMAT((SELECT TOP 1 r.NextNumber
						FROM App.tbRegister r
						WHERE r.RegisterName = @RegisterName), '00000');
				
			UPDATE App.tbRegister
			SET NextNumber += 1
			WHERE RegisterName = @RegisterName;

			SET @LogCode = CONCAT(@UserId, @LogNumber);

			IF NOT EXISTS (SELECT * FROM App.tbEventLog WHERE LogCode = @LogCode)
				BREAK;
			END

		INSERT INTO App.tbEventLog (LogCode, EventTypeCode, EventMessage)
		VALUES (@LogCode, @EventTypeCode, @EventMessage);

		COMMIT TRANSACTION;

		RETURN;
					
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION;
		THROW;
	END CATCH

go
/**** TRIGGERS ***/
CREATE OR ALTER TRIGGER Activity.Activity_tbActivity_TriggerUpdate 
   ON  Activity.tbActivity
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
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
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

END
go
CREATE OR ALTER TRIGGER Activity.Activity_tbAttribute_TriggerUpdate 
   ON  Activity.tbAttribute
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		UPDATE Activity.tbAttribute
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Activity.tbAttribute INNER JOIN inserted AS i ON tbAttribute.ActivityCode = i.ActivityCode AND tbAttribute.Attribute = i.Attribute;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE OR ALTER TRIGGER Activity.Activity_tbFlow_TriggerUpdate 
   ON  Activity.tbFlow
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY		
		UPDATE Activity.tbFlow
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Activity.tbFlow INNER JOIN inserted AS i ON tbFlow.ParentCode = i.ParentCode AND tbFlow.StepNumber = i.StepNumber;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE OR ALTER TRIGGER Activity.Activity_tbOp_TriggerUpdate 
   ON  Activity.tbOp 
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		UPDATE Activity.tbOp
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Activity.tbOp INNER JOIN inserted AS i ON tbOp.ActivityCode = i.ActivityCode AND tbOp.OperationNumber = i.OperationNumber;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE OR ALTER TRIGGER App.App_tbCalendar_TriggerUpdate 
   ON  App.tbCalendar
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(CalendarCode) = 0)
			BEGIN
			DECLARE @Msg NVARCHAR(MAX) = App.fnProfileText(2004);
			RAISERROR (@Msg, 10, 1)
			ROLLBACK
			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE OR ALTER TRIGGER App.App_tbOptions_TriggerUpdate 
   ON  App.tbOptions
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		UPDATE App.tbOptions
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM App.tbOptions INNER JOIN inserted AS i ON tbOptions.Identifier = i.Identifier;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE OR ALTER TRIGGER App.App_tbTaxCode_TriggerUpdate 
   ON  App.tbTaxCode
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
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
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE OR ALTER TRIGGER App.App_tbUom_TriggerUpdate 
   ON  App.tbUom
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(UnitOfMeasure) = 0)
			BEGIN
			DECLARE @Msg NVARCHAR(MAX) = App.fnProfileText(2004);
			RAISERROR (@Msg, 10, 1)
			ROLLBACK
			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
ALTER TABLE App.tbUom ENABLE TRIGGER App_tbUom_TriggerUpdate
go

go

go
CREATE OR ALTER TRIGGER Cash.App_tbCategory_TriggerUpdate 
   ON  Cash.tbCategory
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(CategoryCode) = 0)
			BEGIN
			DECLARE @Msg NVARCHAR(MAX) = App.fnProfileText(2004);
			RAISERROR (@Msg, 10, 1)
			ROLLBACK
			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE OR ALTER TRIGGER Cash.Cash_tbCategory_TriggerUpdate 
   ON  Cash.tbCategory
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		UPDATE Cash.tbCategory
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Cash.tbCategory INNER JOIN inserted AS i ON tbCategory.CategoryCode = i.CategoryCode;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE OR ALTER TRIGGER Cash.Cash_tbCode_TriggerUpdate 
   ON  Cash.tbCode
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		
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
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE OR ALTER TRIGGER Invoice.Invoice_tbInvoice_TriggerUpdate
ON Invoice.tbInvoice
FOR UPDATE
AS
	SET NOCOUNT ON;

	BEGIN TRY
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
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER TRIGGER Org.Org_tbAccount_TriggerUpdate 
   ON  Org.tbAccount
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
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
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE OR ALTER TRIGGER Org.Org_tbAddress_TriggerInsert
ON Org.tbAddress 
FOR INSERT
AS
	SET NOCOUNT ON;
	BEGIN TRY
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
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go
CREATE OR ALTER TRIGGER Org.Org_tbAddress_TriggerUpdate 
   ON  Org.tbAddress
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		UPDATE Org.tbAddress
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Org.tbAddress INNER JOIN inserted AS i ON tbAddress.AddressCode = i.AddressCode;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE OR ALTER TRIGGER Org.Org_tbContact_TriggerUpdate 
   ON  Org.tbContact
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		UPDATE Org.tbContact
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Org.tbContact INNER JOIN inserted AS i ON tbContact.AccountCode = i.AccountCode AND tbContact.ContactName = i.ContactName;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE OR ALTER TRIGGER Org.Org_tbDoc_TriggerUpdate 
   ON  Org.tbDoc
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		UPDATE Org.tbDoc
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Org.tbDoc INNER JOIN inserted AS i ON tbDoc.AccountCode = i.AccountCode AND tbDoc.DocumentName = i.DocumentName;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE OR ALTER TRIGGER Org.Org_tbOrg_TriggerUpdate 
   ON  Org.tbOrg
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
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
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE OR ALTER TRIGGER Org.Org_tbPayment_TriggerUpdate
ON Org.tbPayment
FOR UPDATE
AS
	SET NOCOUNT ON;
	BEGIN TRY
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
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
	
go
CREATE OR ALTER TRIGGER Task.Task_tbAttribute_TriggerUpdate 
   ON  Task.tbAttribute
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		UPDATE Task.tbAttribute
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Task.tbAttribute INNER JOIN inserted AS i ON tbAttribute.TaskCode = i.TaskCode AND tbAttribute.Attribute = i.Attribute;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE OR ALTER TRIGGER Task.Task_tbDoc_TriggerUpdate 
   ON  Task.tbDoc
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		UPDATE Task.tbDoc
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Task.tbDoc INNER JOIN inserted AS i ON tbDoc.TaskCode = i.TaskCode AND tbDoc.DocumentName = i.DocumentName;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE OR ALTER TRIGGER Task.Task_tbFlow_TriggerUpdate 
   ON  Task.tbFlow
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		UPDATE Task.tbFlow
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Task.tbFlow INNER JOIN inserted AS i ON tbFlow.ParentTaskCode = i.ParentTaskCode AND tbFlow.StepNumber = i.StepNumber;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE OR ALTER TRIGGER Task.Task_tbOp_TriggerUpdate 
   ON  Task.tbOp 
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		UPDATE Task.tbOp
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Task.tbOp INNER JOIN inserted AS i ON tbOp.TaskCode = i.TaskCode AND tbOp.OperationNumber = i.OperationNumber;

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE OR ALTER TRIGGER Task.Task_tbQuote_TriggerUpdate 
   ON  Task.tbQuote
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		UPDATE Task.tbQuote
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Task.tbQuote INNER JOIN inserted AS i ON tbQuote.TaskCode = i.TaskCode AND tbQuote.Quantity = i.Quantity;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE OR ALTER TRIGGER Task.Task_tbTask_TriggerInsert
ON Task.tbTask
FOR INSERT
AS
	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @AccountCode NVARCHAR(10), @ContactName NVARCHAR(100), @NickName NVARCHAR(100), @FileAs NVARCHAR(100)

		DECLARE contacts CURSOR LOCAL FOR
			SELECT AccountCode, ContactName FROM inserted
			WHERE EXISTS (SELECT     ContactName
						FROM         inserted AS i
						WHERE     (NOT (ContactName IS NULL)) AND
												(ContactName <> N''))
				AND NOT EXISTS(SELECT     Org.tbContact.ContactName
								FROM         inserted AS i INNER JOIN
													Org.tbContact ON i.AccountCode = Org.tbContact.AccountCode AND i.ContactName = Org.tbContact.ContactName)
				
		OPEN contacts
		FETCH NEXT FROM contacts INTO @AccountCode, @ContactName

		WHILE (@@FETCH_STATUS = 0)
			BEGIN
			SET @NickName = LEFT(@ContactName, CHARINDEX(' ', @ContactName, 1))
			EXEC Org.proc_ContactFileAs @ContactName, @FileAs OUTPUT
					
			INSERT INTO Org.tbContact (AccountCode, ContactName, FileAs, NickName)
			VALUES (@AccountCode, @ContactName, @FileAs, @NickName)

			FETCH NEXT FROM contacts INTO @AccountCode, @ContactName
			END					
		
		CLOSE contacts
		DEALLOCATE contacts
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go
CREATE OR ALTER TRIGGER Task.Task_tbTask_TriggerUpdate
ON Task.tbTask
FOR UPDATE
AS
	SET NOCOUNT ON;
	BEGIN TRY
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

			DECLARE @AccountCode NVARCHAR(10), @ContactName NVARCHAR(100), @NickName NVARCHAR(100), @FileAs NVARCHAR(100)
				
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
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go
CREATE OR ALTER TRIGGER Usr.Usr_tbMenuEntry_TriggerUpdate 
   ON  Usr.tbMenuEntry
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		UPDATE Usr.tbMenuEntry
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Usr.tbMenuEntry INNER JOIN inserted AS i ON tbMenuEntry.EntryId = i.EntryId AND tbMenuEntry.EntryId = i.EntryId;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE OR ALTER TRIGGER Usr.Usr_tbUser_TriggerUpdate 
   ON  Usr.tbUser
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		UPDATE Usr.tbUser
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Usr.tbUser INNER JOIN inserted AS i ON tbUser.UserId = i.UserId;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go

/********** STORED PROCEDURES *****************/
CREATE OR ALTER PROCEDURE Activity.proc_Mode
	(
	@ActivityCode nvarchar(50)
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SELECT     Activity.tbActivity.ActivityCode, Activity.tbActivity.UnitOfMeasure, Task.tbStatus.TaskStatus, Cash.tbCategory.CashModeCode
		FROM         Activity.tbActivity INNER JOIN
							  Task.tbStatus ON Activity.tbActivity.TaskStatusCode = Task.tbStatus.TaskStatusCode LEFT OUTER JOIN
							  Cash.tbCode ON Activity.tbActivity.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
							  Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE     ( Activity.tbActivity.ActivityCode = @ActivityCode)
		 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Activity.proc_NextAttributeOrder 
	(
	@ActivityCode nvarchar(50),
	@PrintOrder smallint = 10 output
	)
  AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
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
		
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE OR ALTER PROCEDURE Activity.proc_NextOperationNumber 
	(
	@ActivityCode nvarchar(50),
	@OperationNumber smallint = 10 output
	)
AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
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
		
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Activity.proc_NextStepNumber 
	(
	@ActivityCode nvarchar(50),
	@StepNumber smallint = 10 output
	)
AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
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
		
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Activity.proc_Parent
	(
	@ActivityCode nvarchar(50),
	@ParentCode nvarchar(50) = null output
	)
AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF EXISTS(SELECT     ParentCode
				  FROM         Activity.tbFlow
				  WHERE     (ChildCode = @ActivityCode))
			SELECT @ParentCode = ParentCode
			FROM         Activity.tbFlow
			WHERE     (ChildCode = @ActivityCode)
		ELSE
			SET @ParentCode = @ActivityCode
		
		 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Activity.proc_WorkFlow
	(
	@ActivityCode nvarchar(50)
	)
AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SELECT     Activity.tbActivity.ActivityCode, Task.tbStatus.TaskStatus, Cash.tbCategory.CashModeCode, Activity.tbActivity.UnitOfMeasure, Activity.tbFlow.OffsetDays
		FROM         Activity.tbActivity INNER JOIN
							  Task.tbStatus ON Activity.tbActivity.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
							  Activity.tbFlow ON Activity.tbActivity.ActivityCode = Activity.tbFlow.ChildCode LEFT OUTER JOIN
							  Cash.tbCode ON Activity.tbActivity.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
							  Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE     ( Activity.tbFlow.ParentCode = @ActivityCode)
		ORDER BY Activity.tbFlow.StepNumber	

		 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE App.proc_AddCalDateRange
	(
		@CalendarCode nvarchar(10),
		@FromDate datetime,
		@ToDate datetime
	)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @UnavailableDate datetime

		SELECT @UnavailableDate = @FromDate
	
		BEGIN TRANSACTION

		WHILE @UnavailableDate <= @ToDate
		BEGIN
			INSERT INTO App.tbCalendarHoliday (CalendarCode, UnavailableOn)
			VALUES (@CalendarCode, @UnavailableDate)
			SELECT @UnavailableDate = DateAdd(d, 1, @UnavailableDate)
		END

		COMMIT TRANSACTION

		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE App.proc_AdjustToCalendar
	(
	@SourceDate datetime,
	@OffsetDays int,
	@OutputDate datetime output
	)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@CalendarCode nvarchar(10)
			, @WorkingDay bit
			, @UserId nvarchar(10)
	
		DECLARE
			 @CurrentDay smallint
			, @Monday smallint
			, @Tuesday smallint
			, @Wednesday smallint
			, @Thursday smallint
			, @Friday smallint
			, @Saturday smallint
			, @Sunday smallint
		
		SELECT @UserId = UserId
		FROM         Usr.vwCredentials	

		SET @OutputDate = @SourceDate

		SELECT     @CalendarCode = App.tbCalendar.CalendarCode, @Monday = Monday, @Tuesday = Tuesday, @Wednesday = Wednesday, @Thursday = Thursday, @Friday = Friday, @Saturday = Saturday, @Sunday = Sunday
		FROM         App.tbCalendar INNER JOIN
							  Usr.tbUser ON App.tbCalendar.CalendarCode = Usr.tbUser.CalendarCode
		WHERE UserId = @UserId
	
		WHILE @OffsetDays > -1
			BEGIN
			SET @CurrentDay = App.fnWeekDay(@OutputDate)
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
				IF NOT EXISTS(SELECT     UnavailableOn
							FROM         App.tbCalendarHoliday
							WHERE     (CalendarCode = @CalendarCode) AND (UnavailableOn = @OutputDate))
					SET @OffsetDays -= 1
				END
			
			IF @OffsetDays > -1
				SET @OutputDate = DATEADD(d, -1, @OutputDate)
			END
					
		

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go

CREATE OR ALTER PROCEDURE App.proc_CompanyName
	(
	@AccountName nvarchar(255) = null output
	)
  AS
	SELECT TOP 1 @AccountName = Org.tbOrg.AccountName
	FROM         Org.tbOrg INNER JOIN
	                      App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode
	 
go 

CREATE OR ALTER PROCEDURE App.proc_DelCalDateRange
	(
		@CalendarCode nvarchar(10),
		@FromDate datetime,
		@ToDate datetime
	)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DELETE FROM App.tbCalendarHoliday
			WHERE UnavailableOn >= @FromDate
				AND UnavailableOn <= @ToDate
				AND CalendarCode = @CalendarCode
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE App.proc_DocDespool
	(
	@DocTypeCode SMALLINT
	)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF @DocTypeCode = 0
		--Quotations:
			UPDATE       Task.tbTask
			SET           Spooled = 0, Printed = 1
			FROM            Task.tbTask INNER JOIN
									 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
									 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			WHERE        ( Task.tbTask.TaskStatusCode = 0) AND ( Cash.tbCategory.CashModeCode = 1) AND ( Task.tbTask.Spooled <> 0)
		ELSE IF @DocTypeCode = 1
		--SalesOrder:
			UPDATE       Task.tbTask
			SET           Spooled = 0, Printed = 1
			FROM            Task.tbTask INNER JOIN
									 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
									 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			WHERE        ( Task.tbTask.TaskStatusCode > 0) AND ( Cash.tbCategory.CashModeCode = 1) AND ( Task.tbTask.Spooled <> 0)
		ELSE IF @DocTypeCode = 2
		--PurchaseEnquiry:
			UPDATE       Task.tbTask
			SET           Spooled = 0, Printed = 1
			FROM            Task.tbTask INNER JOIN
									 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
									 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			WHERE        ( Task.tbTask.TaskStatusCode = 0) AND ( Cash.tbCategory.CashModeCode = 0) AND ( Task.tbTask.Spooled <> 0)	
		ELSE IF @DocTypeCode = 3
		--PurchaseOrder:
			UPDATE       Task.tbTask
			SET           Spooled = 0, Printed = 1
			FROM            Task.tbTask INNER JOIN
									 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
									 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			WHERE        ( Task.tbTask.TaskStatusCode > 0) AND ( Cash.tbCategory.CashModeCode = 0) AND ( Task.tbTask.Spooled <> 0)
		ELSE IF @DocTypeCode = 4
		--SalesInvoice:
			UPDATE       Invoice.tbInvoice
			SET                Spooled = 0, Printed = 1
			WHERE        (InvoiceTypeCode = 0) AND (Spooled <> 0)
		ELSE IF @DocTypeCode = 5
		--CreditNote:
			UPDATE       Invoice.tbInvoice
			SET                Spooled = 0, Printed = 1
			WHERE        (InvoiceTypeCode = 1) AND (Spooled <> 0)
		ELSE IF @DocTypeCode = 6
		--DebitNote:
			UPDATE       Invoice.tbInvoice
			SET                Spooled = 0, Printed = 1
			WHERE        (InvoiceTypeCode = 3) AND (Spooled <> 0)
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE App.proc_Initialised
(@Setting bit)
  AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
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
			RETURN
			END
		ELSE
			BEGIN
			UPDATE App.tbOptions Set Initialised = 0
			RETURN 1
			END
 	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE App.proc_NewCompany
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
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
	DECLARE 
		@UserId nvarchar(10)
		, @CalendarCode nvarchar(10)
		, @MenuId smallint

		, @AppAccountCode nvarchar(10)
		, @TaxCode nvarchar(10)
		, @AddressCode nvarchar(15)


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
	
 	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
 
go
CREATE OR ALTER PROCEDURE App.proc_PeriodClose
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF EXISTS(SELECT * FROM App.fnActivePeriod())
			BEGIN
			DECLARE @StartOn datetime, @YearNumber smallint
		
			SELECT @StartOn = StartOn, @YearNumber = YearNumber
			FROM App.fnActivePeriod() fnSystemActivePeriod
		 		
			BEGIN TRAN
	
			UPDATE App.tbYearPeriod
			SET CashStatusCode = 2
			WHERE StartOn = @StartOn			
		
			IF NOT EXISTS (SELECT     CashStatusCode
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
					
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE App.proc_PeriodGetYear
	(
	@StartOn DATETIME,
	@YearNumber INTEGER OUTPUT
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SELECT @YearNumber = YearNumber
		FROM            App.tbYearPeriod
		WHERE        (StartOn = @StartOn)
	
		IF @YearNumber IS NULL
			SELECT @YearNumber = YearNumber FROM App.fnActivePeriod()
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH	 
go

CREATE OR ALTER PROCEDURE App.proc_ReassignUser 
	(
	@UserId nvarchar(10)
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		UPDATE    Usr.tbUser
		SET       LogonName = (SUSER_SNAME())
		WHERE     (UserId = @UserId)
	
   	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE App.proc_YearPeriods
	(
	@YearNumber int
	)
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SELECT     App.tbYear.Description, App.tbMonth.MonthName
					FROM         App.tbYearPeriod INNER JOIN
										App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber INNER JOIN
										App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber
					WHERE     ( App.tbYearPeriod.YearNumber = @YearNumber)
					ORDER BY App.tbYearPeriod.YearNumber, App.tbYearPeriod.StartOn
    END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE OR ALTER PROCEDURE Cash.proc_AccountRebuild
	(
	@CashAccountCode nvarchar(10)
	)
  AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		
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
    END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH 
go
CREATE OR ALTER PROCEDURE Cash.proc_AccountRebuildAll
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		
		BEGIN TRANSACTION	
		UPDATE Org.tbAccount
		SET CurrentBalance = Cash.vwAccountRebuild.CurrentBalance
		FROM         Cash.vwAccountRebuild INNER JOIN
							Org.tbAccount ON Cash.vwAccountRebuild.CashAccountCode = Org.tbAccount.CashAccountCode
	
		UPDATE Org.tbAccount
		SET CurrentBalance = 0
		FROM         Cash.vwAccountRebuild RIGHT OUTER JOIN
							  Org.tbAccount ON Cash.vwAccountRebuild.CashAccountCode = Org.tbAccount.CashAccountCode
		WHERE     (Cash.vwAccountRebuild.CashAccountCode IS NULL)
		
 		COMMIT TRANSACTION
    END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH 
go
CREATE OR ALTER PROCEDURE Cash.proc_CategoryCashCodes
	(
	@CategoryCode nvarchar(10)
	)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY		
		SELECT     CashCode, CashDescription
		FROM         Cash.tbCode
		WHERE     (CategoryCode = @CategoryCode)
		ORDER BY CashDescription		 
    END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH  
 
go
CREATE OR ALTER PROCEDURE Cash.proc_CategoryCodeFromName
	(
		@Category nvarchar(50),
		@CategoryCode nvarchar(10) output
	)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF EXISTS (SELECT CategoryCode
					FROM         Cash.tbCategory
					WHERE     (Category = @Category))
			SELECT @CategoryCode = CategoryCode
			FROM         Cash.tbCategory
			WHERE     (Category = @Category)
		ELSE
			SET @CategoryCode = 0 
    END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH  
go
CREATE OR ALTER PROCEDURE Cash.proc_CategoryTotals
	(
	@CashTypeCode smallint,
	@CategoryTypeCode smallint = 1
	)
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SELECT     Cash.tbCategory.DisplayOrder, Cash.tbCategory.Category, Cash.tbType.CashType, Cash.tbCategory.CategoryCode
		FROM         Cash.tbCategory INNER JOIN
							  Cash.tbType ON Cash.tbCategory.CashTypeCode = Cash.tbType.CashTypeCode
		WHERE     ( Cash.tbCategory.CashTypeCode = @CashTypeCode) AND ( Cash.tbCategory.CategoryTypeCode = @CategoryTypeCode)
		ORDER BY Cash.tbCategory.DisplayOrder, Cash.tbCategory.Category 
    END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH  
go 
CREATE OR ALTER PROCEDURE Cash.proc_CodeDefaults 
	(
	@CashCode nvarchar(50)
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		SELECT     Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCode.CategoryCode, Cash.tbCode.TaxCode, Cash.tbCode.OpeningBalance, 
							  ISNULL( Cash.tbCategory.CashModeCode, 0) AS CashModeCode, App.tbTaxCode.TaxTypeCode
		FROM         Cash.tbCode INNER JOIN
							  App.tbTaxCode ON Cash.tbCode.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
							  Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE     ( Cash.tbCode.CashCode = @CashCode)
    END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH 
go
CREATE OR ALTER PROCEDURE Cash.proc_CodeValues
	(
	@CashCode nvarchar(50),
	@YearNumber smallint
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		SELECT        Cash.vwFlowData.StartOn, Cash.vwFlowData.InvoiceValue, Cash.vwFlowData.InvoiceTax, Cash.vwFlowData.ForecastValue, Cash.vwFlowData.ForecastTax
		FROM            App.tbYearPeriod INNER JOIN
								 Cash.vwFlowData ON App.tbYearPeriod.StartOn = Cash.vwFlowData.StartOn
		WHERE        ( App.tbYearPeriod.YearNumber = @YearNumber) AND (Cash.vwFlowData.CashCode = @CashCode)
		ORDER BY Cash.vwFlowData.StartOn 
    END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH 
go
CREATE OR ALTER PROCEDURE Cash.proc_CopyForecastToLiveCashCode
	(
	@CashCode nvarchar(50),
	@StartOn datetime
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		UPDATE Cash.tbPeriod
		SET     InvoiceValue = ForecastValue, InvoiceTax = ForecastTax
		FROM         Cash.tbPeriod
		WHERE     (CashCode = @CashCode) AND (StartOn = @StartOn) 
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH 
go
CREATE OR ALTER PROCEDURE Cash.proc_CopyForecastToLiveCategory
	(
	@CategoryCode nvarchar(10),
	@StartOn datetime
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		UPDATE Cash.tbPeriod
		SET     InvoiceValue = ForecastValue, InvoiceTax = ForecastTax
		FROM         Cash.tbPeriod INNER JOIN
							  Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode
		WHERE     ( Cash.tbPeriod.StartOn = @StartOn) AND ( Cash.tbCode.CategoryCode = @CategoryCode) 
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH 
go
CREATE OR ALTER PROCEDURE Cash.proc_CopyLiveToForecastCashCode
	(
	@CashCode nvarchar(50),
	@Years smallint,
	@UseLastPeriod bit = 0
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
	DECLARE 
		@SystemStartOn datetime
		, @EndPeriod datetime
		, @StartPeriod datetime
		, @CurPeriod datetime
	
		, @InvoiceValue money
		, @InvoiceTax money

		BEGIN TRANSACTION

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
		
		COMMIT TRANSACTION

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

			COMMIT TRANSACTION
			RETURN

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH 
go


CREATE OR ALTER PROCEDURE Cash.proc_CopyLiveToForecastCategory
	(
	@CategoryCode nvarchar(10),
	@Years smallint,
	@UseLastPeriod bit = 0
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @CashCode nvarchar(50)

		DECLARE curCc CURSOR FOR
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
			
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH 
go
CREATE OR ALTER PROCEDURE Cash.proc_FlowInitialise
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @CashCode nvarchar(25)
		
		BEGIN TRANSACTION

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
	                      
		COMMIT TRANSACTION	 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Cash.proc_GeneratePeriods
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
	DECLARE 
		@YearNumber smallint
		, @StartOn datetime
		, @PeriodStartOn datetime
		, @CashStatusCode smallint
		, @Period smallint
	
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
		 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Cash.proc_StatementRescheduleOverdue
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRANSACTION	
		DECLARE 
			@TaskCode NVARCHAR(20)
			, @AccountCode NVARCHAR(10)
			, @PaymentOn DATETIME
			, @InvoiceNumber NVARCHAR(20)

		DECLARE tasks CURSOR LOCAL FOR
			SELECT TaskCode, AccountCode
			FROM         Task.tbTask INNER JOIN
								Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode
			WHERE     ( Task.tbTask.PaymentOn < CURRENT_TIMESTAMP) AND ( Task.tbTask.TaskStatusCode <= 2)

		OPEN tasks
		FETCH NEXT FROM tasks INTO @TaskCode, @AccountCode
	
		WHILE @@FETCH_STATUS = 0
			BEGIN
		
			SET @PaymentOn = CURRENT_TIMESTAMP
			EXEC Task.proc_DefaultPaymentOn @AccountCode, @PaymentOn, @PaymentOn OUTPUT

			UPDATE Task.tbTask
			SET PaymentOn = @PaymentOn
			WHERE Task.tbTask.TaskCode = @TaskCode

			FETCH NEXT FROM tasks INTO @TaskCode, @AccountCode
			END

		CLOSE tasks
		DEALLOCATE tasks

		DECLARE invoices CURSOR LOCAL FOR
			SELECT InvoiceNumber, AccountCode
			FROM         Invoice.tbInvoice 
			WHERE     ( Invoice.tbInvoice.InvoiceStatusCode = 1 OR
								  Invoice.tbInvoice.InvoiceStatusCode = 2) AND ( Invoice.tbInvoice.ExpectedOn < CURRENT_TIMESTAMP)	

		OPEN invoices
		FETCH NEXT FROM invoices INTO @InvoiceNumber, @AccountCode
	
		WHILE @@FETCH_STATUS = 0
			BEGIN
		
			SET @PaymentOn = CURRENT_TIMESTAMP
			EXEC Task.proc_DefaultPaymentOn @AccountCode, @PaymentOn, @PaymentOn OUTPUT

			UPDATE Invoice.tbInvoice
			SET ExpectedOn = @PaymentOn
			WHERE InvoiceNumber = @InvoiceNumber

			FETCH NEXT FROM invoices INTO @InvoiceNumber, @AccountCode
			END

		CLOSE invoices
		DEALLOCATE invoices

		COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Cash.proc_VatBalance
	(
	@Balance money output
	)
 AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		SELECT  @Balance = SUM(HomeSalesVat - HomePurchasesVat + ExportSalesVat - ExportPurchasesVat)
		FROM         Invoice.vwVatSummary
	
		SELECT  @Balance = @Balance + ISNULL(SUM( Org.tbPayment.PaidInValue - Org.tbPayment.PaidOutValue), 0)
		FROM         Org.tbPayment INNER JOIN
							  App.vwVatCashCode ON Org.tbPayment.CashCode = App.vwVatCashCode.CashCode	                      

		SELECT @Balance = @Balance + SUM(VatAdjustment)
		FROM App.tbYearPeriod

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Invoice.proc_Accept 
	(
	@InvoiceNumber nvarchar(20)
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF EXISTS(SELECT     InvoiceNumber
	          FROM         Invoice.tbItem
	          WHERE     (InvoiceNumber = @InvoiceNumber)) 
		or EXISTS(SELECT     InvoiceNumber
	          FROM         Invoice.tbTask
	          WHERE     (InvoiceNumber = @InvoiceNumber))
		BEGIN
			BEGIN TRANSACTION
			
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
			
			COMMIT TRANSACTION
		END
			
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Invoice.proc_AddTask 
	(
	@InvoiceNumber nvarchar(20),
	@TaskCode nvarchar(20)	
	)
 AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
	DECLARE 
		@InvoiceTypeCode smallint
		, @InvoiceQuantity float
		, @QuantityInvoiced float

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

		UPDATE Task.tbTask
		SET ActionedOn = CURRENT_TIMESTAMP
		WHERE TaskCode = @TaskCode;
	
		EXEC Invoice.proc_Total @InvoiceNumber	

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Invoice.proc_Cancel 
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
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
	
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Invoice.proc_Credit
	(
		@InvoiceNumber nvarchar(20) output
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
	DECLARE 
		@InvoiceTypeCode smallint
		, @CreditNumber nvarchar(20)
		, @UserId nvarchar(10)
		, @NextNumber int
		, @InvoiceSuffix nvarchar(4)

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

		BEGIN TRANSACTION

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
	
		COMMIT TRANSACTION
	 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Invoice.proc_DefaultDocType
	(
		@InvoiceNumber nvarchar(20),
		@DocTypeCode smallint OUTPUT
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
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
							
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Invoice.proc_Pay
	(
	@InvoiceNumber nvarchar(20),
	@Now datetime
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
	DECLARE 
		@PaidOut money
		, @PaidIn money
		, @TaskOutstanding money
		, @ItemOutstanding money
		, @CashModeCode smallint
		, @CashCode nvarchar(50)
		, @AccountCode nvarchar(10)
		, @CashAccountCode nvarchar(10)
		, @UserId nvarchar(10)
		, @PaymentCode nvarchar(20)

		SELECT @UserId = UserId FROM Usr.vwCredentials	

		SET @PaymentCode = @UserId + '_' + FORMAT(Year(@Now), '0000')
			+ FORMAT(Month(@Now), '00')
			+ FORMAT(Day(@Now), '00')
			+ FORMAT(DatePart(hh, @Now), '00')
			+ FORMAT(DatePart(n, @Now), '00')
			+ FORMAT(DatePart(s, @Now), '00')
	
		WHILE EXISTS (SELECT * FROM Org.tbPayment WHERE PaymentCode = @PaymentCode)
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
	
		BEGIN TRANSACTION

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
		
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Invoice.proc_Raise
	(
	@TaskCode nvarchar(20),
	@InvoiceTypeCode smallint,
	@InvoicedOn datetime,
	@InvoiceNumber nvarchar(20) = null output
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
	DECLARE 
		@UserId nvarchar(10)
		, @NextNumber int
		, @InvoiceSuffix nvarchar(4)
		, @PaymentDays smallint
		, @DueOn datetime
		, @AccountCode nvarchar(10)

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
	
		EXEC Task.proc_DefaultPaymentOn @AccountCode, @InvoicedOn, @DueOn OUTPUT

		BEGIN TRANSACTION
	
		EXEC Invoice.proc_Cancel
	
		UPDATE    Invoice.tbType
		SET              NextNumber = @NextNumber + 1
		WHERE     (InvoiceTypeCode = @InvoiceTypeCode)
	
		INSERT INTO Invoice.tbInvoice
							(InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoicedOn, DueOn, ExpectedOn, InvoiceStatusCode, PaymentTerms)
		SELECT     @InvoiceNumber AS InvoiceNumber, @UserId AS UserId, Task.tbTask.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, @InvoicedOn AS InvoicedOn, 
							@DueOn AS DueOn, @DueOn AS ExpectedOn, 0 AS InvoiceStatusCode, 
							Org.tbOrg.PaymentTerms
		FROM         Task.tbTask INNER JOIN
							Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode
		WHERE     ( Task.tbTask.TaskCode = @TaskCode)

		EXEC Invoice.proc_AddTask @InvoiceNumber, @TaskCode
	
		IF @@TRANCOUNT > 0		
			COMMIT TRANSACTION
	
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

go
CREATE OR ALTER PROCEDURE Invoice.proc_RaiseBlank
	(
	@AccountCode nvarchar(10),
	@InvoiceTypeCode smallint,
	@InvoiceNumber nvarchar(20) = null output
	)
  AS
  SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		DECLARE 
			@UserId nvarchar(10)
			, @NextNumber int
			, @InvoiceSuffix nvarchar(4)

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
		
		BEGIN TRANSACTION
	
		EXEC Invoice.proc_Cancel
	
		UPDATE    Invoice.tbType
		SET              NextNumber = @NextNumber + 1
		WHERE     (InvoiceTypeCode = @InvoiceTypeCode)
	
		INSERT INTO Invoice.tbInvoice
								(InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoicedOn, InvoiceStatusCode)
		VALUES     (@InvoiceNumber, @UserId, @AccountCode, @InvoiceTypeCode, CURRENT_TIMESTAMP, 0)
	
		COMMIT TRANSACTION
	
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog
	END CATCH

go
CREATE OR ALTER PROCEDURE Invoice.proc_Total 
	(
	@InvoiceNumber nvarchar(20)
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		UPDATE Invoice.tbItem
		SET TaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND(Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, 2)
				WHEN 1 THEN ROUND( Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END
		FROM         Invoice.tbItem INNER JOIN
							  App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
							  Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE Invoice.tbInvoice.InvoiceNumber = @InvoiceNumber;

		UPDATE Invoice.tbTask
		SET TaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND(Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, 2)
				WHEN 1 THEN ROUND( Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END
		FROM         Invoice.tbTask INNER JOIN
							  App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
							  Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbTask.InvoiceNumber = @InvoiceNumber);

		WITH totals AS
		(
			SELECT InvoiceNumber, SUM(InvoiceValue) AS InvoiceValue, 
				SUM(TaxValue) AS TaxValue,
				SUM(PaidValue) AS PaidValue, 
				SUM(PaidTaxValue) AS PaidTaxValue
			FROM         Invoice.tbTask
			GROUP BY InvoiceNumber
			HAVING      (InvoiceNumber = @InvoiceNumber)
			UNION
			SELECT InvoiceNumber, SUM(InvoiceValue) AS InvoiceValue, 
				SUM(TaxValue) AS TaxValue,
				SUM(PaidValue) AS PaidValue, 
				SUM(PaidTaxValue) AS PaidTaxValue
			FROM         Invoice.tbItem
			GROUP BY InvoiceNumber
			HAVING      (InvoiceNumber = @InvoiceNumber)
		), grand_total AS
		(
			SELECT InvoiceNumber, ISNULL(SUM(InvoiceValue), 0) AS InvoiceValue, 
				ISNULL(SUM(TaxValue), 0) AS TaxValue, 
				ISNULL(SUM(PaidValue), 0) AS PaidValue, 
				ISNULL(SUM(PaidTaxValue), 0) AS PaidTaxValue
			FROM totals
			GROUP BY InvoiceNumber
		) 
		UPDATE    Invoice.tbInvoice
		SET InvoiceValue = grand_total.InvoiceValue, TaxValue = grand_total.TaxValue,
			PaidValue = grand_total.PaidValue, PaidTaxValue = grand_total.PaidTaxValue,
			InvoiceStatusCode = CASE 
					WHEN grand_total.PaidValue >= grand_total.InvoiceValue THEN 3 
					WHEN grand_total.PaidValue > 0 THEN 2 
					ELSE 1 END
		FROM Invoice.tbInvoice INNER JOIN grand_total ON Invoice.tbInvoice.InvoiceNumber = grand_total.InvoiceNumber;
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Org.proc_AddAddress 
	(
	@AccountCode nvarchar(10),
	@Address ntext
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @AddressCode nvarchar(15)
	
		EXECUTE Org.proc_NextAddressCode @AccountCode, @AddressCode OUTPUT
	
		INSERT INTO Org.tbAddress
							  (AddressCode, AccountCode, Address)
		VALUES     (@AddressCode, @AccountCode, @Address)
	
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Org.proc_AddContact 
	(
	@AccountCode nvarchar(10),
	@ContactName nvarchar(100)	 
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @FileAs nvarchar(10)
	
		EXECUTE Org.proc_ContactFileAs @ContactName, @FileAs OUTPUT	
	
		INSERT INTO Org.tbContact
								(AccountCode, ContactName, FileAs, PhoneNumber, EmailAddress)
		SELECT     AccountCode, @ContactName AS ContactName, @FileAs, PhoneNumber, EmailAddress
		FROM         Org.tbOrg
		WHERE AccountCode = @AccountCode
	
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Org.proc_BalanceOutstanding 
	(
	@AccountCode nvarchar(10),
	@Balance money = 0 OUTPUT
	)
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
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
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Org.proc_ContactFileAs 
	(
	@ContactName nvarchar(100),
	@FileAs nvarchar(100) output
	)
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

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

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Org.proc_DefaultAccountCode 
	(
	@AccountName nvarchar(100),
	@AccountCode nvarchar(10) OUTPUT 
	)
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@ParsedName nvarchar(100)
			, @FirstWord nvarchar(100)
			, @SecondWord nvarchar(100)
			, @ValidatedCode nvarchar(10)
			, @c char(1)
			, @ASCII smallint
			, @pos int
			, @ok bit
			, @Suffix smallint
			, @Rows int
		
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
	
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Org.proc_DefaultTaxCode 
	(
	@AccountCode nvarchar(10),
	@TaxCode nvarchar(10) OUTPUT
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF EXISTS(SELECT     Org.tbOrg.AccountCode
				  FROM         Org.tbOrg INNER JOIN
										App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode)
			BEGIN
			SELECT @TaxCode = Org.tbOrg.TaxCode
				  FROM         Org.tbOrg INNER JOIN
										App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode
		
			END	                              

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Org.proc_NextAddressCode 
	(
	@AccountCode nvarchar(10),
	@AddressCode nvarchar(15) OUTPUT
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @AddCount int

		SELECT @AddCount = COUNT(AddressCode) 
		FROM         Org.tbAddress
		WHERE     (AccountCode = @AccountCode)
	
		SET @AddCount += @AddCount
		SET @AddressCode = CONCAT(UPPER(@AccountCode), '_', FORMAT(@AddCount, '000'))
	
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Org.proc_PaymentDelete
	(
	@PaymentCode nvarchar(20)
	)
 AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@AccountCode nvarchar(10)
			, @CashAccountCode nvarchar(10)

		SELECT  @AccountCode = AccountCode, @CashAccountCode = CashAccountCode
		FROM         Org.tbPayment
		WHERE     (PaymentCode = @PaymentCode)

		DELETE FROM Org.tbPayment
		WHERE     (PaymentCode = @PaymentCode)
	
		EXEC Org.proc_Rebuild @AccountCode

		BEGIN TRANSACTION
		EXEC Cash.proc_AccountRebuild @CashAccountCode
		COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE OR ALTER PROCEDURE Org.proc_PaymentMove
	(
	@PaymentCode nvarchar(20),
	@CashAccountCode nvarchar(10)
	)
  AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @OldAccountCode nvarchar(10)

		SELECT @OldAccountCode = CashAccountCode
		FROM         Org.tbPayment
		WHERE     (PaymentCode = @PaymentCode)
	
		BEGIN TRANSACTION
	
		UPDATE Org.tbPayment 
		SET CashAccountCode = @CashAccountCode,
			UpdatedOn = CURRENT_TIMESTAMP,
			UpdatedBy = (suser_sname())
		WHERE PaymentCode = @PaymentCode	

		EXEC Cash.proc_AccountRebuild @CashAccountCode
		EXEC Cash.proc_AccountRebuild @OldAccountCode
	
		COMMIT TRANSACTION
	 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Org.proc_PaymentPost 
AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
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
		
		BEGIN TRANSACTION

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

		COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Org.proc_PaymentPostInvoiced
	(
	@PaymentCode nvarchar(20) 
	)
 AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@AccountCode nvarchar(10)
			, @CashModeCode smallint
			, @CurrentBalance money
			, @PaidValue money
			, @PostValue money

		SELECT   @PaidValue = CASE WHEN PaidInValue = 0 THEN PaidOutValue ELSE PaidInValue END,
			@CurrentBalance = Org.tbOrg.CurrentBalance,
			@AccountCode = Org.tbOrg.AccountCode,
			@CashModeCode = CASE WHEN PaidInValue = 0 THEN 0 ELSE 1 END
		FROM         Org.tbPayment INNER JOIN
							  Org.tbOrg ON Org.tbPayment.AccountCode = Org.tbOrg.AccountCode
		WHERE     ( Org.tbPayment.PaymentCode = @PaymentCode)
	
		BEGIN TRANSACTION

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
		
		COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Org.proc_PaymentPostMisc
	(
	@PaymentCode nvarchar(20) 
	)
 AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@InvoiceNumber nvarchar(20), 
			@NextNumber int, 
			@InvoiceTypeCode smallint;

		SELECT @InvoiceTypeCode = CASE WHEN PaidInValue != 0 THEN 0 ELSE 2 END 
		FROM         Org.tbPayment
		WHERE     (PaymentCode = @PaymentCode)
	
		SELECT @NextNumber = NextNumber
		FROM Invoice.tbType
		WHERE InvoiceTypeCode = @InvoiceTypeCode;
		
		SET @InvoiceNumber = FORMAT(@NextNumber, '000000') + '.' + (SELECT UserId FROM Usr.vwCredentials);

		WHILE EXISTS (SELECT     InvoiceNumber
					  FROM         Invoice.tbInvoice
					  WHERE     (InvoiceNumber = @InvoiceNumber))
			BEGIN
			SET @NextNumber += @NextNumber 
			SET @InvoiceNumber = FORMAT(@NextNumber, '000000') + '.' + (SELECT UserId FROM Usr.vwCredentials);
			END
		
		BEGIN TRANSACTION

		UPDATE    Invoice.tbType
		SET              NextNumber = @NextNumber + 1
		WHERE     (InvoiceTypeCode = @InvoiceTypeCode)

		UPDATE    Org.tbPayment
		SET		PaymentStatusCode = 1,
			TaxInValue = (CASE App.tbTaxCode.RoundingCode WHEN 0 THEN ROUND(Org.tbPayment.PaidInValue - ( Org.tbPayment.PaidInValue / (1 + App.tbTaxCode.TaxRate)), 2) WHEN 1 THEN ROUND(Org.tbPayment.PaidInValue - ( Org.tbPayment.PaidInValue / (1 + App.tbTaxCode.TaxRate)), 2, 1) END), 
			TaxOutValue = (CASE App.tbTaxCode.RoundingCode WHEN 0 THEN ROUND(Org.tbPayment.PaidOutValue - ( Org.tbPayment.PaidOutValue / (1 + App.tbTaxCode.TaxRate)), 2) WHEN 1 THEN ROUND(Org.tbPayment.PaidOutValue - ( Org.tbPayment.PaidOutValue / (1 + App.tbTaxCode.TaxRate)), 2, 1) END)
		FROM         Org.tbPayment INNER JOIN
							  App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode
		WHERE     (PaymentCode = @PaymentCode)

		INSERT INTO Invoice.tbInvoice
								 (InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, DueOn, ExpectedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, Printed)
		SELECT        @InvoiceNumber AS InvoiceNumber, Org.tbPayment.UserId, Org.tbPayment.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, 3 AS InvoiceStatusCode, 
								Org.tbPayment.PaidOn, Org.tbPayment.PaidOn AS DueOn, Org.tbPayment.PaidOn AS ExpectedOn,
								CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
									WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
								END AS InvoiceValue, 
								CASE WHEN Org.tbPayment.PaidInValue > 0 THEN Org.tbPayment.TaxInValue 
									WHEN Org.tbPayment.PaidOutValue > 0 THEN Org.tbPayment.TaxOutValue
								END AS TaxValue, 
								CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
									WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
								END AS PaidValue, 
								CASE WHEN Org.tbPayment.PaidInValue > 0 THEN Org.tbPayment.TaxInValue 
									WHEN Org.tbPayment.PaidOutValue > 0 THEN Org.tbPayment.TaxOutValue
								END AS PaidTaxValue, 
								1 AS Printed
		FROM            Org.tbPayment INNER JOIN
								 App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode
		WHERE        ( Org.tbPayment.PaymentCode = @PaymentCode);


		INSERT INTO Invoice.tbItem
							(InvoiceNumber, CashCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, TaxCode)
		SELECT     @InvoiceNumber AS InvoiceNumber, Org.tbPayment.CashCode, 
								CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
									WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
								END AS InvoiceValue, 
								CASE WHEN Org.tbPayment.PaidInValue > 0 THEN Org.tbPayment.TaxInValue 
									WHEN Org.tbPayment.PaidOutValue > 0 THEN Org.tbPayment.TaxOutValue
								END AS TaxValue, 
								CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
									WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
								END AS PaidValue, 
								CASE WHEN Org.tbPayment.PaidInValue > 0 THEN Org.tbPayment.TaxInValue 
									WHEN Org.tbPayment.PaidOutValue > 0 THEN Org.tbPayment.TaxOutValue
								END AS PaidTaxValue, 
							Org.tbPayment.TaxCode
		FROM         Org.tbPayment INNER JOIN
							  App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode
		WHERE     ( Org.tbPayment.PaymentCode = @PaymentCode);

		UPDATE Invoice.tbItem
		SET PaidValue = InvoiceValue, PaidTaxValue = TaxValue
		WHERE InvoiceNumber = @InvoiceNumber;

		UPDATE  Org.tbAccount
		SET CurrentBalance = CASE WHEN PaidInValue > 0 THEN Org.tbAccount.CurrentBalance + PaidInValue ELSE Org.tbAccount.CurrentBalance - PaidOutValue END
		FROM         Org.tbAccount INNER JOIN
							  Org.tbPayment ON Org.tbAccount.CashAccountCode = Org.tbPayment.CashAccountCode
		WHERE Org.tbPayment.PaymentCode = @PaymentCode

		COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Org.proc_PaymentPostPaidIn
	(
	@PaymentCode nvarchar(20),
	@CurrentBalance money output 
	)
 AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@InvoiceNumber nvarchar(20)	--invoice valued
			, @TaskCode nvarchar(20)
			, @TaxRate real
			, @ItemValue money
			, @RoundingCode smallint
			, @PaidValue money	--calc values
			, @PaidTaxValue money
			, @TaxInValue money = 0
			, @TaxOutValue money = 0
			, @CashCode nvarchar(50)	--default payment codes
			, @TaxCode nvarchar(10)

	
		DECLARE curPaidIn CURSOR LOCAL FOR
			SELECT     Invoice.vwOutstanding.InvoiceNumber, Invoice.vwOutstanding.TaskCode, Invoice.vwOutstanding.CashCode, Invoice.vwOutstanding.TaxCode, 
								  Invoice.vwOutstanding.TaxRate, Invoice.vwOutstanding.ItemValue, Invoice.vwOutstanding.RoundingCode
			FROM         Invoice.vwOutstanding INNER JOIN
								  Org.tbPayment ON Invoice.vwOutstanding.AccountCode = Org.tbPayment.AccountCode
			WHERE     ( Org.tbPayment.PaymentCode = @PaymentCode)
			ORDER BY Invoice.vwOutstanding.CashModeCode, Invoice.vwOutstanding.ExpectedOn

		OPEN curPaidIn
		FETCH NEXT FROM curPaidIn INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode
		WHILE @@FETCH_STATUS = 0 and @CurrentBalance < 0
			BEGIN
			IF (@CurrentBalance + @ItemValue) > 0
				SET @ItemValue = @CurrentBalance * -1

			SET @PaidTaxValue = (CASE @RoundingCode WHEN 0 THEN ROUND(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), 2) WHEN 1 THEN ROUND(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), 2, 1) END)
			SET @PaidValue = ABS(@ItemValue) - @PaidTaxValue
				
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
		        		  
			SET @TaxInValue += CASE WHEN @ItemValue > 0 THEN @PaidTaxValue ELSE 0 END
			SET @TaxOutValue += CASE WHEN @ItemValue < 0 THEN @PaidTaxValue ELSE 0 END	
				
			FETCH NEXT FROM curPaidIn INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode
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
				CashCode = ISNULL(@CashCode, Org.tbPayment.CashCode), 
				TaxCode = ISNULL(@TaxCode, Org.tbPayment.TaxCode)
			WHERE     (PaymentCode = @PaymentCode)
			END	
			
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Org.proc_PaymentPostPaidOut
	(
	@PaymentCode nvarchar(20),
	@CurrentBalance money output 
	)
 AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@InvoiceNumber nvarchar(20)	--invoice valued
			, @TaskCode nvarchar(20)
			, @TaxRate real
			, @ItemValue money
			, @RoundingCode smallint
			, @PaidValue money	--calc values
			, @PaidTaxValue money
			, @TaxInValue money = 0
			, @TaxOutValue money = 0
			, @CashCode nvarchar(50)	--default payment codes
			, @TaxCode nvarchar(10)


		DECLARE curPaidOut CURSOR LOCAL FOR
			SELECT     Invoice.vwOutstanding.InvoiceNumber, Invoice.vwOutstanding.TaskCode, Invoice.vwOutstanding.CashCode, Invoice.vwOutstanding.TaxCode, 
								  Invoice.vwOutstanding.TaxRate, Invoice.vwOutstanding.ItemValue, Invoice.vwOutstanding.RoundingCode
			FROM         Invoice.vwOutstanding INNER JOIN
								  Org.tbPayment ON Invoice.vwOutstanding.AccountCode = Org.tbPayment.AccountCode
			WHERE     ( Org.tbPayment.PaymentCode = @PaymentCode)
			ORDER BY Invoice.vwOutstanding.CashModeCode DESC, Invoice.vwOutstanding.ExpectedOn

		OPEN curPaidOut
		FETCH NEXT FROM curPaidOut INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode
		WHILE @@FETCH_STATUS = 0 and @CurrentBalance > 0
			BEGIN
			IF (@CurrentBalance + @ItemValue) < 0
				SET @ItemValue = @CurrentBalance * -1

			SET @PaidTaxValue = (CASE @RoundingCode WHEN 0 THEN ROUND(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), 2) WHEN 1 THEN ROUND(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), 2, 1) END)
			SET @PaidValue = ABS(@ItemValue) - @PaidTaxValue
				
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
		        		  
			SET @TaxInValue += CASE WHEN @ItemValue > 0 THEN @PaidTaxValue ELSE 0 END
			SET @TaxOutValue += CASE WHEN @ItemValue < 0 THEN @PaidTaxValue ELSE 0 END	
				
			FETCH NEXT FROM curPaidOut INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode
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
				CashCode = ISNULL(@CashCode, Org.tbPayment.CashCode), 
				TaxCode = ISNULL(@TaxCode, Org.tbPayment.TaxCode)
			WHERE     (PaymentCode = @PaymentCode)
			END
	
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Org.proc_Rebuild
	(
		@AccountCode nvarchar(10)
	)
 AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

		UPDATE Invoice.tbItem
		SET TaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND(Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, 2)
				WHEN 1 THEN ROUND( Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END,
			PaidValue = Invoice.tbItem.InvoiceValue, 
			PaidTaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND(Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, 2)
				WHEN 1 THEN ROUND( Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END
		FROM         Invoice.tbItem INNER JOIN
							  App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
							  Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND ( Invoice.tbInvoice.AccountCode = @AccountCode);
                      
		UPDATE Invoice.tbTask
		SET TaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND(Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, 2)
				WHEN 1 THEN ROUND( Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END,
			PaidValue = Invoice.tbTask.InvoiceValue,
			PaidTaxValue = CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND(Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, 2)
				WHEN 1 THEN ROUND( Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END
		FROM         Invoice.tbTask INNER JOIN
							  App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
							  Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND ( Invoice.tbInvoice.AccountCode = @AccountCode);
	
		UPDATE Invoice.tbInvoice
		SET InvoiceValue = 0, TaxValue = 0
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND ( Invoice.tbInvoice.AccountCode = @AccountCode);
	
		WITH items AS
		(
			SELECT     Invoice.tbInvoice.InvoiceNumber, SUM( Invoice.tbItem.InvoiceValue) AS TotalInvoiceValue, SUM( Invoice.tbItem.TaxValue) AS TotalTaxValue
			FROM         Invoice.tbItem INNER JOIN
								Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0)
			GROUP BY Invoice.tbItem.InvoiceNumber, Invoice.tbInvoice.InvoiceNumber
		)
		UPDATE Invoice.tbInvoice
		SET InvoiceValue = items.TotalInvoiceValue, 
			TaxValue = items.TotalTaxValue
		FROM         Invoice.tbInvoice INNER JOIN items 
							  ON Invoice.tbInvoice.InvoiceNumber = items.InvoiceNumber
		WHERE (Invoice.tbInvoice.AccountCode = @AccountCode);	

		WITH tasks AS
		(
			SELECT     Invoice.tbInvoice.InvoiceNumber, SUM( Invoice.tbTask.InvoiceValue) AS TotalInvoiceValue, SUM( Invoice.tbTask.TaxValue) AS TotalTaxValue
			FROM         Invoice.tbTask INNER JOIN
								Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			WHERE   ( Invoice.tbInvoice.InvoiceStatusCode <> 0)
			GROUP BY Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.InvoiceNumber
		)
		UPDATE Invoice.tbInvoice
		SET InvoiceValue = InvoiceValue + tasks.TotalInvoiceValue, 
			TaxValue = TaxValue + tasks.TotalTaxValue
		FROM         Invoice.tbInvoice INNER JOIN tasks ON Invoice.tbInvoice.InvoiceNumber = tasks.InvoiceNumber
		WHERE (Invoice.tbInvoice.AccountCode = @AccountCode);			

		UPDATE    Invoice.tbInvoice
		SET              PaidValue = InvoiceValue, PaidTaxValue = TaxValue, InvoiceStatusCode = 3
		WHERE     (InvoiceStatusCode <> 0) AND (AccountCode = @AccountCode);
	
		UPDATE Org.tbPayment
		SET
			TaxInValue = PaidInValue - CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND((PaidInValue / (1 + TaxRate)), 2)
				WHEN 1 THEN ROUND((PaidInValue / (1 + TaxRate)), 2, 1) END, 
			TaxOutValue = PaidOutValue - CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND((PaidOutValue / (1 + TaxRate)), 2)
				WHEN 1 THEN ROUND((PaidOutValue / (1 + TaxRate)), 2, 1) END
		FROM         Org.tbPayment INNER JOIN
							  App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode
		WHERE     ( Org.tbPayment.AccountCode = @AccountCode);



	/************** replace cursor ********************/
	DECLARE 
		@PaidBalance money
		, @InvoicedBalance money
		, @Balance money
		, @CashModeCode smallint
		, @TaxRate float
		, @RoundingCode smallint
		, @InvoiceNumber nvarchar(20)
		, @TaskCode nvarchar(20)
		, @CashCode nvarchar(50)
		, @InvoiceValue money
		, @TaxValue money
		, @PaidValue money
		, @PaidInvoiceValue money
		, @PaidTaxValue money

		SELECT  @PaidBalance = SUM(CASE WHEN PaidInValue > 0 THEN PaidInValue * -1 ELSE PaidOutValue  END)
		FROM         Org.tbPayment
		WHERE     (AccountCode = @AccountCode) And (PaymentStatusCode <> 0)
	
		SELECT @PaidBalance = ISNULL(@PaidBalance, 0) + OpeningBalance
		FROM Org.tbOrg
		WHERE     (AccountCode = @AccountCode)

		SELECT @InvoicedBalance = SUM(CASE Invoice.tbType.CashModeCode WHEN 0 THEN (InvoiceValue + TaxValue) * - 1 WHEN 1 THEN InvoiceValue + TaxValue ELSE 0 END) 
		FROM         Invoice.tbInvoice INNER JOIN
							  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		WHERE     ( Invoice.tbInvoice.AccountCode = @AccountCode)
	
		SET @Balance = ISNULL(@PaidBalance, 0) + ISNULL(@InvoicedBalance, 0)
                      
		SET @CashModeCode = CASE WHEN @Balance > 0 THEN 1 ELSE 0 END
		SET @Balance = ABS(@Balance)	

		DECLARE curInv cursor local for
			WITH invoice_items AS
			(		
				SELECT        Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.DueOn, Invoice.tbTask.CashCode, Invoice.tbTask.TaskCode, Invoice.tbTask.InvoiceValue, Invoice.tbTask.TaxValue, Invoice.tbTask.TaxCode
				FROM            Invoice.tbTask INNER JOIN
										 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
				UNION
				SELECT        Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbItem.InvoiceNumber, Invoice.tbInvoice.DueOn, Invoice.tbItem.CashCode, '' AS TaskCode, Invoice.tbItem.InvoiceValue, Invoice.tbItem.TaxValue, Invoice.tbItem.TaxCode
				FROM            Invoice.tbItem INNER JOIN
										 Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			)
			SELECT     InvoiceNumber, TaskCode, CashCode, InvoiceValue, TaxValue, TaxRate, RoundingCode
			FROM invoice_items INNER JOIN Invoice.tbType t ON invoice_items.InvoiceTypeCode = t.InvoiceTypeCode
				INNER JOIN App.tbTaxCode ON invoice_items.TaxCode = App.tbTaxCode.TaxCode
			WHERE invoice_items.AccountCode = @AccountCode AND (CashModeCode = @CashModeCode)
			ORDER BY DueOn DESC;
	

		OPEN curInv
		FETCH NEXT FROM curInv INTO @InvoiceNumber, @TaskCode, @CashCode, @InvoiceValue, @TaxValue, @TaxRate, @RoundingCode
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
				SET @PaidTaxValue = CASE @RoundingCode 
										WHEN 0 THEN ROUND((@PaidValue - (@PaidValue / (1 + @TaxRate))), 2)
										WHEN 1 THEN ROUND((@PaidValue - (@PaidValue / (1 + @TaxRate))), 2, 1)
									END
				SET @PaidInvoiceValue = @PaidValue - @PaidTaxValue
				END
			ELSE
				BEGIN
				SET @PaidInvoiceValue = 0
				SET @PaidTaxValue = 0
				END
			
			IF ISNULL(@TaskCode, '') = ''
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

			FETCH NEXT FROM curInv INTO @InvoiceNumber, @TaskCode, @CashCode, @InvoiceValue, @TaxValue, @TaxRate, @RoundingCode
			END
	
		CLOSE curInv;
		DEALLOCATE curInv;

	/**************************************************/
		
		--update invoice paid
		WITH invoices AS
		(
			SELECT        InvoiceNumber, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
			FROM            Invoice.tbTask
			UNION
			SELECT        InvoiceNumber, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
			FROM            Invoice.tbItem
		), totals AS
		(
			SELECT        InvoiceNumber, SUM(InvoiceValue) AS TotalInvoiceValue, SUM(TaxValue) AS TotalTaxValue, SUM(PaidValue) AS TotalPaidValue, SUM(PaidTaxValue) AS TotalPaidTaxValue
			FROM            invoices
			GROUP BY InvoiceNumber
		), selected AS
		(
			SELECT InvoiceNumber, 		
				TotalInvoiceValue, TotalTaxValue, TotalPaidValue, TotalPaidTaxValue, 
				(TotalPaidValue + TotalPaidTaxValue) AS TotalPaid
			FROM totals
			WHERE (TotalInvoiceValue + TotalTaxValue) > (TotalPaidValue + TotalPaidTaxValue)
		)
		UPDATE Invoice.tbInvoice
		SET InvoiceStatusCode = CASE WHEN TotalPaid > 0 THEN 2 ELSE 1 END,
			PaidValue = selected.TotalPaidValue, 
			PaidTaxValue = selected.TotalPaidTaxValue
		FROM         Invoice.tbInvoice INNER JOIN
							selected ON Invoice.tbInvoice.InvoiceNumber = selected.InvoiceNumber
		WHERE tbInvoice.AccountCode = @AccountCode;

		IF (@CashModeCode = 1)
			SET @Balance = @Balance * -1
		
		UPDATE    Org.tbOrg
		SET              CurrentBalance = OpeningBalance - @Balance
		WHERE     (AccountCode = @AccountCode)
	
		COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Org.proc_Statement
	(
	@AccountCode nvarchar(10)
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @FromDate datetime
	
		SELECT @FromDate = DATEADD(d, StatementDays * -1, CURRENT_TIMESTAMP)
		FROM         Org.tbOrg
		WHERE     (AccountCode = @AccountCode)
	
		SELECT     TransactedOn, OrderBy, Reference, StatementType, Charge, Balance
		FROM         Org.fnStatement(@AccountCode) fnOrgStatement
		WHERE     (TransactedOn >= @FromDate)
		ORDER BY TransactedOn, OrderBy
	 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_AssignToParent 
	(
	@ChildTaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20)
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@TaskTitle nvarchar(100)
			, @StepNumber smallint

		BEGIN TRANSACTION
		
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
	
		COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_Configure 
	(
	@ParentTaskCode nvarchar(20)
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@StepNumber smallint
			, @TaskCode nvarchar(20)
			, @UserId nvarchar(10)
			, @ActivityCode nvarchar(50)
			, @AccountCode nvarchar(10)
			, @PaymentOn datetime
			, @TaxCode nvarchar(10)

		IF @@NESTLEVEL = 1
			BEGIN TRANSACTION

		IF EXISTS (SELECT     ContactName
				   FROM         Task.tbTask
				   WHERE     (TaskCode = @ParentTaskCode) AND (NOT (ContactName IS NULL)) OR
										 (TaskCode = @ParentTaskCode) AND (ContactName <> N''))
			BEGIN
			IF NOT EXISTS(SELECT     Org.tbContact.ContactName
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
			SELECT  
				@ActivityCode = Activity.tbActivity.ActivityCode, 
				@AccountCode = Task.tbTask.AccountCode,
				@PaymentOn = Task.tbTask.ActionOn
			FROM         Activity.tbFlow INNER JOIN
								  Activity.tbActivity ON Activity.tbFlow.ChildCode = Activity.tbActivity.ActivityCode INNER JOIN
								  Task.tbTask ON Activity.tbFlow.ParentCode = Task.tbTask.ActivityCode
			WHERE     ( Activity.tbFlow.StepNumber = @StepNumber) AND ( Task.tbTask.TaskCode = @ParentTaskCode)
		
			EXEC Task.proc_NextCode @ActivityCode, @TaskCode output
			EXEC Task.proc_DefaultPaymentOn @AccountCode, @PaymentOn, @PaymentOn OUTPUT

			INSERT INTO Task.tbTask
								(TaskCode, UserId, AccountCode, ContactName, ActivityCode, TaskStatusCode, ActionById, ActionOn, PaymentOn, TaskNotes, UnitCharge, 
								AddressCodeFrom, AddressCodeTo, CashCode, Printed, TaskTitle)
			SELECT     @TaskCode AS NewTask, Task_tb1.UserId, Task_tb1.AccountCode, Task_tb1.ContactName, Activity.tbActivity.ActivityCode, Activity.tbActivity.TaskStatusCode, 
								Task_tb1.ActionById, Task_tb1.ActionOn, @PaymentOn 
								AS PaymentOn, Activity.tbActivity.DefaultText, Activity.tbActivity.UnitCharge, Org.tbOrg.AddressCode AS AddressCodeFrom, Org.tbOrg.AddressCode AS AddressCodeTo, 
								tbActivity.CashCode, CASE WHEN Activity.tbActivity.PrintOrder = 0 THEN 1 ELSE 0 END AS Printed, Task_tb1.TaskTitle
			FROM         Activity.tbFlow INNER JOIN
								Activity.tbActivity ON Activity.tbFlow.ChildCode = Activity.tbActivity.ActivityCode INNER JOIN
								Task.tbTask Task_tb1 ON Activity.tbFlow.ParentCode = Task_tb1.ActivityCode INNER JOIN
								Org.tbOrg ON Task_tb1.AccountCode = Org.tbOrg.AccountCode
			WHERE     ( Activity.tbFlow.StepNumber = @StepNumber) AND ( Task_tb1.TaskCode = @ParentTaskCode)

			IF EXISTS (SELECT * FROM Task.tbTask INNER JOIN 
						Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode INNER JOIN 
						App.tbTaxCode ON Org.tbOrg.TaxCode = App.tbTaxCode.TaxCode AND Org.tbOrg.TaxCode = App.tbTaxCode.TaxCode)
				BEGIN
				UPDATE Task.tbTask
				SET TaxCode = App.tbTaxCode.TaxCode
				FROM Task.tbTask INNER JOIN 
					Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode INNER JOIN 
					App.tbTaxCode ON Org.tbOrg.TaxCode = App.tbTaxCode.TaxCode AND Org.tbOrg.TaxCode = App.tbTaxCode.TaxCode
				WHERE        (Task.tbTask.TaskCode = @TaskCode)
				END
			ELSE
				BEGIN
				UPDATE Task.tbTask
				SET TaxCode = Cash.tbCode.TaxCode
				FROM            Task.tbTask INNER JOIN
											Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode
				WHERE        (Task.tbTask.TaskCode = @TaskCode)
				END			
			
					
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
		
		IF @@NESTLEVEL = 1
			COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go
CREATE OR ALTER PROCEDURE [Task].[proc_Copy]
	(
	@FromTaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20) = null,
	@ToTaskCode nvarchar(20) = null output
	)
AS
	SET NOCOUNT, XACT_ABORT ON
	BEGIN TRY
		DECLARE 
			@ActivityCode nvarchar(50)
			, @Printed bit
			, @ChildTaskCode nvarchar(20)
			, @TaskStatusCode smallint
			, @StepNumber smallint
			, @UserId nvarchar(10)
			, @PaymentOn datetime
			, @AccountCode nvarchar(10)

		SELECT @UserId = UserId FROM Usr.vwCredentials
	
		SELECT  
			@AccountCode = Task.tbTask.AccountCode,
			@TaskStatusCode = Activity.tbActivity.TaskStatusCode, 
			@ActivityCode = Task.tbTask.ActivityCode, 
			@Printed = CASE WHEN Activity.tbActivity.PrintOrder = 0 THEN 1 ELSE 0 END
		FROM         Task.tbTask INNER JOIN
							  Activity.tbActivity ON Task.tbTask.ActivityCode = Activity.tbActivity.ActivityCode
		WHERE     ( Task.tbTask.TaskCode = @FromTaskCode)
	
		EXEC Task.proc_NextCode @ActivityCode, @ToTaskCode output

		IF @@NESTLEVEL = 1
			BEGIN TRANSACTION;

		SET @PaymentOn = CAST(CURRENT_TIMESTAMP AS date)
		EXEC Task.proc_DefaultPaymentOn @AccountCode, @PaymentOn, @PaymentOn OUTPUT

		INSERT INTO Task.tbTask
							  (TaskCode, UserId, AccountCode, TaskTitle, ContactName, ActivityCode, TaskStatusCode, ActionById, ActionOn, ActionedOn, TaskNotes, Quantity, 
							  SecondReference, CashCode, TaxCode, UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, PaymentOn, Printed)
		SELECT     @ToTaskCode AS ToTaskCode, @UserId AS Owner, AccountCode, TaskTitle, ContactName, ActivityCode, @TaskStatusCode AS TaskStatus, 
							  @UserId AS ActionUserId, CAST(CURRENT_TIMESTAMP AS date) AS ActionOn, 
							  CASE WHEN @TaskStatusCode > 1 THEN CAST(CURRENT_TIMESTAMP AS date) ELSE NULL END AS ActionedOn, TaskNotes, 
							  Quantity, SecondReference, CashCode, TaxCode, UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, 
							  @PaymentOn AS PaymentOn, @Printed AS Printed
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
		
		IF @@NESTLEVEL = 1
			COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go
CREATE OR ALTER PROCEDURE Task.proc_Cost 
	(
	@ParentTaskCode nvarchar(20),
	@TotalCost money = 0 output
	)

AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@TaskCode nvarchar(20)
			, @TotalCharge money
			, @CashModeCode smallint

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
	
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_DefaultDocType
	(
		@TaskCode nvarchar(20),
		@DocTypeCode smallint OUTPUT
	)
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@CashModeCode smallint
			, @TaskStatusCode smallint

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
		 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_DefaultInvoiceType
	(
		@TaskCode nvarchar(20),
		@InvoiceTypeCode smallint OUTPUT
	)
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

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
		 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_DefaultPaymentOn
	(
		@AccountCode nvarchar(10),
		@ActionOn datetime,
		@PaymentOn datetime output
	)
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@PaymentDays smallint
			, @UserId nvarchar(10)
			, @PayDaysFromMonthEnd bit
	
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
	
		EXEC App.proc_AdjustToCalendar @PaymentOn, 0, @PaymentOn OUTPUT
	 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_DefaultTaxCode 
	(
	@AccountCode nvarchar(10),
	@CashCode nvarchar(50),
	@TaxCode nvarchar(10) OUTPUT
	)
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY		
		IF (NOT @AccountCode IS NULL) and (NOT @CashCode IS NULL)
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
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE OR ALTER PROCEDURE Task.proc_Delete 
	(
	@TaskCode nvarchar(20)
	)
AS
--mod replace with CTE union all

   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @ChildTaskCode nvarchar(20)

		IF @@NESTLEVEL = 1
			BEGIN TRANSACTION

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
	
		IF @@NESTLEVEL = 1
			COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_EmailAddress 
	(
	@TaskCode nvarchar(20),
	@EmailAddress nvarchar(255) OUTPUT
	)
AS
SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
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
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_EmailDetail 
	(
	@TaskCode nvarchar(20)
	)
AS
SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@NickName nvarchar(100)
			, @EmailAddress nvarchar(255)

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

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE OR ALTER PROCEDURE Task.proc_EmailFooter 
AS
--mod replace with view

	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SELECT        u.UserName, u.PhoneNumber, u.MobileNumber, o.AccountName, o.WebSite
		FROM            Usr.vwCredentials AS c INNER JOIN
								 Usr.tbUser AS u ON c.UserId = u.UserId 
			CROSS JOIN
			(SELECT        TOP (1) Org.tbOrg.AccountName, Org.tbOrg.WebSite
			FROM            Org.tbOrg INNER JOIN
										App.tbOptions ON Org.tbOrg.AccountCode = App.tbOptions.AccountCode) AS o

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_FullyInvoiced
	(
	@TaskCode nvarchar(20),
	@IsFullyInvoiced bit = 0 output
	)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@InvoiceValue money
			, @TotalCharge money

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
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_IsProject 
	(
	@TaskCode nvarchar(20),
	@IsProject bit = 0 output
	)
  AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
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
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH	
go
CREATE OR ALTER PROCEDURE Task.proc_Mode 
	(
	@TaskCode nvarchar(20)
	)
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SELECT     Task.tbTask.AccountCode, Task.tbTask.ActivityCode, Task.tbTask.TaskStatusCode, Task.tbTask.ActionOn, Task.vwCashMode.CashModeCode
		FROM         Task.tbTask LEFT OUTER JOIN
							  Task.vwCashMode ON Task.tbTask.TaskCode = Task.vwCashMode.TaskCode
		WHERE     ( Task.tbTask.TaskCode = @TaskCode)
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_NextAttributeOrder 
	(
	@TaskCode nvarchar(20),
	@PrintOrder smallint = 10 output
	)
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

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
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_NextCode
	(
		@ActivityCode nvarchar(50),
		@TaskCode nvarchar(20) OUTPUT
	)
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@UserId nvarchar(10)
			, @NextTaskNumber int

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
			UPDATE Usr.tbUser
			Set NextTaskNumber = NextTaskNumber + 1
			WHERE UserId = @UserId
			END
		                      
		SET @TaskCode = @UserId + '_' + FORMAT(@NextTaskNumber, '0000')
			                      
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_NextOperationNumber 
	(
	@TaskCode nvarchar(20),
	@OperationNumber smallint = 10 output
	)
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
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
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_Op
	(
	@TaskCode nvarchar(20)
	)
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
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
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
 CREATE OR ALTER PROCEDURE Task.proc_Parent 
	(
	@TaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20) output
	)
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SET @ParentTaskCode = @TaskCode
		IF EXISTS(SELECT     ParentTaskCode
					 FROM         Task.tbFlow
					 WHERE     (ChildTaskCode = @ParentTaskCode))
			SELECT @ParentTaskCode = ParentTaskCode
					 FROM         Task.tbFlow
					 WHERE     (ChildTaskCode = @ParentTaskCode)
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH


go
CREATE OR ALTER PROCEDURE Task.proc_Profit
	(
	@ParentTaskCode nvarchar(20),
	@TotalCost money = 0 output,
	@InvoicedCost money = 0 output,
	@InvoicedCostPaid money = 0 output
	)
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@TaskCode nvarchar(20)
			, @TotalCharge money
			, @TotalInvoiced money
			, @TotalPaid money
			, @CashModeCode smallint

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

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go
CREATE OR ALTER PROCEDURE Task.proc_ProfitTopLevel
	(
	@TaskCode nvarchar(20),
	@InvoicedCharge money = 0 output,
	@InvoicedChargePaid money = 0 output,
	@TotalCost money = 0 output,
	@InvoicedCost money = 0 output,
	@InvoicedCostPaid money = 0 output
	)
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SELECT  @InvoicedCharge = SUM(CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.InvoiceValue * - 1 ELSE Invoice.tbTask.InvoiceValue END), 
		@InvoicedChargePaid = SUM(CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.PaidValue * - 1 ELSE Invoice.tbTask.PaidValue END) 	                      
		FROM         Invoice.tbTask INNER JOIN
							  Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		WHERE     ( Invoice.tbTask.TaskCode = @TaskCode)
	
		SET @TotalCost = 0
		EXEC Task.proc_Profit @TaskCode, @TotalCost output, @InvoicedCost output, @InvoicedCostPaid output	
	
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_Project 
	(
	@TaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20) output
	)
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SET @ParentTaskCode = @TaskCode
		WHILE EXISTS(SELECT     ParentTaskCode
					 FROM         Task.tbFlow
					 WHERE     (ChildTaskCode = @ParentTaskCode))
			SELECT @ParentTaskCode = ParentTaskCode
					 FROM         Task.tbFlow
					 WHERE     (ChildTaskCode = @ParentTaskCode)
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_ReconcileCharge
	(
	@TaskCode nvarchar(20)
	)
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @InvoiceValue money

		SELECT @InvoiceValue = SUM(InvoiceValue)
		FROM         Invoice.tbTask
		WHERE     (TaskCode = @TaskCode)

		UPDATE    Task.tbTask
		SET              TotalCharge = @InvoiceValue, UnitCharge = @InvoiceValue / Quantity
		WHERE     (TaskCode = @TaskCode)	
	
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_ResetChargedUninvoiced
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		UPDATE       Task
		SET                TaskStatusCode = 2
		FROM            Cash.tbCode INNER JOIN
								 Task.tbTask AS Task ON Cash.tbCode.CashCode = Task.CashCode LEFT OUTER JOIN
								 Invoice.tbTask AS InvoiceTask ON Task.TaskCode = InvoiceTask.TaskCode AND Task.TaskCode = InvoiceTask.TaskCode
		WHERE        (InvoiceTask.InvoiceNumber IS NULL) AND (Task.TaskStatusCode = 3)
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_Schedule
	(
	@ParentTaskCode nvarchar(20),
	@ActionOn datetime = null output
	)
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@UserId nvarchar(10)
			, @AccountCode nvarchar(10)
			, @StepNumber smallint
			, @TaskCode nvarchar(20)
			, @OffsetDays smallint
			, @UsedOnQuantity float
			, @Quantity float
			, @PaymentDays smallint
			, @PaymentOn datetime
			, @DefaultPaymentOn datetime
			, @AdjustedOn datetime

		IF @@NESTLEVEL = 1
			BEGIN TRANSACTION

		IF @ActionOn is null
			BEGIN				
			SELECT @ActionOn = ActionOn, @UserId = ActionById 
			FROM Task.tbTask WHERE TaskCode = @ParentTaskCode
		
			EXEC App.proc_AdjustToCalendar @ActionOn, 0, @AdjustedOn OUTPUT

			IF @ActionOn != @AdjustedOn
				BEGIN
				SET @ActionOn = @AdjustedOn
				UPDATE Task.tbTask
				SET ActionOn = @ActionOn
				WHERE TaskCode = @ParentTaskCode and TaskStatusCode < 2			
				END
			END
	
		SELECT @PaymentDays = Org.tbOrg.PaymentDays, @PaymentOn = Task.tbTask.PaymentOn, @AccountCode = Task.tbTask.AccountCode
		FROM         Org.tbOrg INNER JOIN
							  Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode
		WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode)
	
		EXEC Task.proc_DefaultPaymentOn @AccountCode, @ActionOn, @DefaultPaymentOn OUTPUT
		IF (@PaymentOn != @DefaultPaymentOn)
			BEGIN
			UPDATE Task.tbTask
			SET PaymentOn = @DefaultPaymentOn
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
			EXEC App.proc_AdjustToCalendar @ActionOn, @OffsetDays, @AdjustedOn OUTPUT
			SET @ActionOn = @AdjustedOn

			EXEC Task.proc_DefaultPaymentOn @AccountCode, @ActionOn, @PaymentOn OUTPUT
		
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

		IF @@NESTLEVEL = 1
			COMMIT TRANSACTION
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_ScheduleOp
	(
	@TaskCode nvarchar(20),
	@ActionOn datetime
	)	
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@OperationNumber smallint
			, @OpStatusCode smallint
			, @CallOffOpNo smallint
			, @EndOn datetime
			, @StartOn datetime
			, @OffsetDays smallint
			, @AdjustedOn datetime
			, @UserId nvarchar(10)
	
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
				EXEC App.proc_AdjustToCalendar @EndOn, @OffsetDays, @AdjustedOn
				SET @StartOn = @AdjustedOn
				UPDATE Task.tbOp
				SET EndOn = @EndOn, StartOn = @StartOn
				WHERE TaskCode = @TaskCode and OperationNumber = @OperationNumber			
				END
			ELSE
				BEGIN		
				EXEC App.proc_AdjustToCalendar @ActionOn, @OffsetDays, @AdjustedOn	
				SET @StartOn = @AdjustedOn
				END
			SET @EndOn = @StartOn			
			FETCH NEXT FROM curOp INTO @OperationNumber, @OffsetDays, @OpStatusCode, @ActionOn
			END
		CLOSE curOp
		DEALLOCATE curOp
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_SetActionOn
	(
	@TaskCode nvarchar(20)
	)
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@OperationNumber smallint
			, @OpTypeCode smallint
			, @ActionOn datetime
		
		BEGIN TRANSACTION

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

		COMMIT TRANSACTION
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_SetOpStatus
	(
		@TaskCode nvarchar(20),
		@TaskStatusCode smallint
	)
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@OpStatusCode smallint
			, @OperationNumber smallint
	
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

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_SetStatus
	(
		@TaskCode nvarchar(20)
	)
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@ChildTaskCode nvarchar(20)
			, @TaskStatusCode smallint
			, @CashCode nvarchar(20)
			, @IsOrder bit

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
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_WorkFlow 
	(
	@TaskCode nvarchar(20)
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SELECT     Task.tbFlow.ParentTaskCode, Task.tbFlow.StepNumber, Task.tbTask.TaskCode, Task.tbTask.AccountCode, Task.tbTask.ActivityCode, Task.tbTask.TaskStatusCode, 
							  Task.tbTask.ActionOn, Task.vwCashMode.CashModeCode, Task.tbFlow.OffsetDays
		FROM         Task.tbTask INNER JOIN
							  Task.tbFlow ON Task.tbTask.TaskCode = Task.tbFlow.ChildTaskCode LEFT OUTER JOIN
							  Task.vwCashMode ON Task.tbTask.TaskCode = Task.vwCashMode.TaskCode
		WHERE     ( Task.tbFlow.ParentTaskCode = @TaskCode)
		ORDER BY Task.tbFlow.StepNumber, Task.tbFlow.ParentTaskCode
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Usr.proc_MenuCleanReferences(@MenuId SMALLINT)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
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

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Usr.proc_MenuInsert
	(
		@MenuName nvarchar(50),
		@FromMenuId smallint = 0,
		@MenuId smallint = null OUTPUT
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRANSACTION
	
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

		COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Usr.proc_MenuItemDelete( @EntryId int )
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRANSACTION

		DELETE FROM Usr.tbMenuEntry
		WHERE Command = 1 AND Argument = (SELECT FolderId FROM Usr.tbMenuEntry menu WHERE Command = 0 AND menu.EntryId = @EntryId);

		 WITH root_folder AS
		 (
			 SELECT FolderId 
			 FROM Usr.tbMenuEntry menu
			 WHERE Command = 0 AND menu.EntryId = @EntryId
		), child_folders AS
		(
			SELECT CAST(Argument AS smallint) AS FolderId
			FROM Usr.tbMenuEntry sub_folder 
			JOIN root_folder ON sub_folder.FolderId = root_folder.FolderId
			WHERE Command = 1 
			UNION ALL
			SELECT CAST(Argument AS smallint) AS FolderId
			FROM child_folders p 
				JOIN Usr.tbMenuEntry m ON p.FolderId = m.FolderId
			WHERE Command = 1
		), folders AS
		(
			select FolderId from root_folder
			UNION
			select FolderId from child_folders
		)
		DELETE Usr.tbMenuEntry 
		FROM Usr.tbMenuEntry JOIN folders ON Usr.tbMenuEntry.FolderId = folders.FolderId

		DELETE FROM Usr.tbMenuEntry WHERE EntryId = @EntryId;

		COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Org.proc_RebuildAll
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @AccountCode NVARCHAR(10)
		DECLARE orgs CURSOR FOR
			SELECT AccountCode FROM Org.tbOrg
			ORDER BY AccountCode

		OPEN orgs
		FETCH NEXT FROM orgs INTO @AccountCode
		WHILE @@FETCH_STATUS = 0
			BEGIN
			EXEC Org.proc_Rebuild @AccountCode
			FETCH NEXT FROM orgs INTO @AccountCode
			END
		CLOSE orgs
		DEALLOCATE orgs

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_WorkFlowSelected 
	(
	@ChildTaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20) = NULL
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF NOT (@ParentTaskCode IS NULL)
			SELECT        Task.tbTask.AccountCode, Task.tbTask.ActivityCode, Task.tbTask.TaskStatusCode, Task.tbTask.ActionOn, Task.vwCashMode.CashModeCode, Task.tbFlow.OffsetDays
			FROM            Task.tbTask INNER JOIN
									 Task.tbFlow ON Task.tbTask.TaskCode = Task.tbFlow.ChildTaskCode LEFT OUTER JOIN
									 Task.vwCashMode ON Task.tbTask.TaskCode = Task.vwCashMode.TaskCode
			WHERE        (Task.tbFlow.ParentTaskCode = @ParentTaskCode) AND (Task.tbFlow.ChildTaskCode = @ChildTaskCode)
		ELSE
			SELECT        Task.tbTask.AccountCode, Task.tbTask.ActivityCode, Task.tbTask.TaskStatusCode, Task.tbTask.ActionOn, Task.vwCashMode.CashModeCode, 0 AS OffsetDays
			FROM            Task.tbTask LEFT OUTER JOIN
									 Task.vwCashMode ON Task.tbTask.TaskCode = Task.vwCashMode.TaskCode
			WHERE        (Task.tbTask.TaskCode = @ChildTaskCode)
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go














