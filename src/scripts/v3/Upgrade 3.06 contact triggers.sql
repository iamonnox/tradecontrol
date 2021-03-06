CREATE OR ALTER FUNCTION Org.fnContactFileAs(@ContactName nvarchar(100))
RETURNS NVARCHAR(100)
AS
BEGIN
	DECLARE @FileAs nvarchar(100)
		, @FirstNames nvarchar(100)
		, @LastName nvarchar(100)
		, @LastWordPos int;

	IF CHARINDEX(' ', @ContactName) = 0
		SET @FileAs = @ContactName
	ELSE
		BEGIN		
		SET @LastWordPos = CHARINDEX(' ', @ContactName) + 1
		WHILE CHARINDEX(' ', @ContactName, @LastWordPos) != 0
			SET @LastWordPos = CHARINDEX(' ', @ContactName, @LastWordPos) + 1
		
		SET @FirstNames = LEFT(@ContactName, @LastWordPos - 2)
		SET @LastName = RIGHT(@ContactName, LEN(@ContactName) - @LastWordPos + 1)
		SET @FileAs = @LastName + ', ' + @FirstNames
		END

	RETURN @FileAs
END
go
DROP PROCEDURE IF EXISTS [Org].[proc_ContactFileAs];
go
CREATE OR ALTER TRIGGER Org.Org_tbContact_TriggerInsert 
   ON  Org.tbContact
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
	
		UPDATE Org.tbContact
		SET 
			NickName = CASE 
				WHEN LEN(ISNULL(i.NickName, '')) > 0 THEN i.NickName
				WHEN CHARINDEX(' ', tbContact.ContactName, 0) = 0 THEN tbContact.ContactName 
				ELSE LEFT(tbContact.ContactName, CHARINDEX(' ', tbContact.ContactName, 0)) END,
			FileAs = Org.fnContactFileAs(tbContact.ContactName)
		FROM Org.tbContact INNER JOIN inserted AS i ON tbContact.AccountCode = i.AccountCode AND tbContact.ContactName = i.ContactName;

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC App.proc_ErrorLog;
		THROW;
	END CATCH
END
go

ALTER TRIGGER [Task].[Task_tbTask_TriggerInsert]
ON [Task].[tbTask]
FOR INSERT
AS
	SET NOCOUNT ON;
	BEGIN TRY
	INSERT INTO Org.tbContact (AccountCode, ContactName)
	SELECT AccountCode, ContactName 
	FROM inserted
	WHERE EXISTS (SELECT     ContactName
				FROM         inserted AS i
				WHERE     (NOT (ContactName IS NULL)) AND
										(ContactName <> N''))
		AND NOT EXISTS(SELECT     Org.tbContact.ContactName
						FROM         inserted AS i INNER JOIN
											Org.tbContact ON i.AccountCode = Org.tbContact.AccountCode AND i.ContactName = Org.tbContact.ContactName)
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC App.proc_ErrorLog;
		THROW;
	END CATCH
go
ALTER   TRIGGER [Task].[Task_tbTask_TriggerUpdate]
ON [Task].[tbTask]
FOR UPDATE
AS
	SET NOCOUNT ON;
	BEGIN TRY
		IF UPDATE (Spooled)
			BEGIN
			INSERT INTO App.tbDocSpool (DocTypeCode, DocumentNumber)
			SELECT CASE 
					WHEN CashModeCode = 0 THEN		--Expense
						CASE WHEN TaskStatusCode = 0 THEN 2	ELSE 4 END	--Enquiry								
					WHEN CashModeCode = 1 THEN		--Income
						CASE WHEN TaskStatusCode = 0 THEN 0	ELSE 2 END	--Quote
					END AS DocTypeCode, task.TaskCode
			FROM   inserted task INNER JOIN
									 Cash.tbCode ON task.CashCode = Cash.tbCode.CashCode INNER JOIN
									 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			WHERE (task.Spooled <> 0)

				
			DELETE App.tbDocSpool
			FROM         inserted i INNER JOIN
								  App.tbDocSpool ON i.TaskCode = App.tbDocSpool.DocumentNumber
			WHERE    (i.Spooled = 0) AND ( App.tbDocSpool.DocTypeCode <= 3)
			END

		IF UPDATE (ContactName)
			BEGIN
			INSERT INTO Org.tbContact (AccountCode, ContactName)
			SELECT AccountCode, ContactName FROM inserted
			WHERE EXISTS (SELECT     ContactName
						FROM         inserted AS i
						WHERE     (NOT (ContactName IS NULL)) AND
												(ContactName <> N''))
				AND NOT EXISTS(SELECT     Org.tbContact.ContactName
								FROM         inserted AS i INNER JOIN
													Org.tbContact ON i.AccountCode = Org.tbContact.AccountCode AND i.ContactName = Org.tbContact.ContactName)
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
ALTER   PROCEDURE [Org].[proc_AddContact] 
	(
	@AccountCode nvarchar(10),
	@ContactName nvarchar(100)	 
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
	
		INSERT INTO Org.tbContact
								(AccountCode, ContactName, PhoneNumber, EmailAddress)
		SELECT     AccountCode, @ContactName AS ContactName, PhoneNumber, EmailAddress
		FROM         Org.tbOrg
		WHERE AccountCode = @AccountCode
	
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER PROCEDURE [Task].[proc_Configure] 
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
			AND NOT EXISTS(SELECT     Org.tbContact.ContactName
						  FROM         Task.tbTask INNER JOIN
												Org.tbContact ON Task.tbTask.AccountCode = Org.tbContact.AccountCode AND Task.tbTask.ContactName = Org.tbContact.ContactName
						  WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode))
			BEGIN			
			INSERT INTO Org.tbContact
									 (AccountCode, ContactName, FileAs, PhoneNumber, FaxNumber, EmailAddress)
			SELECT        Task.tbTask.AccountCode, Task.tbTask.ContactName, Task.tbTask.ContactName AS NickName, Org.tbOrg.PhoneNumber, Org.tbOrg.FaxNumber, Org.tbOrg.EmailAddress
			FROM            Task.tbTask INNER JOIN
									 Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode
			WHERE        (Task.tbTask.TaskCode = @ParentTaskCode)
					
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


