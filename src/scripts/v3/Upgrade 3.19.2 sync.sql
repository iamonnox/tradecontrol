CREATE TABLE Activity.tbSyncType(
	SyncTypeCode smallint NOT NULL,
	SyncType nvarchar(50) NOT NULL,
 CONSTRAINT PK_Activity_tbSyncType PRIMARY KEY CLUSTERED 
(
	SyncTypeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go
INSERT INTO [Activity].[tbSyncType] ([SyncTypeCode], [SyncType])
VALUES (0, 'SYNC'), (1, 'ASYNC'), (2, 'CALL-OFF');
go

ALTER TABLE Activity.tbFlow ADD
	SyncTypeCode smallint NOT NULL CONSTRAINT DF_Activity_tbFlow_SyncTypeCode DEFAULT(0)
go
ALTER TABLE Activity.tbOp ADD
	SyncTypeCode smallint NOT NULL CONSTRAINT DF_Activity_tbOp_SyncTypeCode DEFAULT(0);

ALTER TABLE Task.tbFlow  ADD
	SyncTypeCode smallint NOT NULL CONSTRAINT DF_Task_tbFlow_SyncTypeCode DEFAULT(0);

ALTER TABLE Task.tbOp ADD
	SyncTypeCode smallint NOT NULL CONSTRAINT DF_Task_tbOp_SyncTypeCode DEFAULT(0);
GO
ALTER TABLE Task.tbOp DISABLE TRIGGER Task_tbOp_TriggerUpdate
ALTER TABLE Task.tbFlow DISABLE TRIGGER Task_tbFlow_TriggerUpdate
GO

UPDATE Activity.tbFlow SET SyncTypeCode = FlowTypeCode
UPDATE Task.tbFlow SET SyncTypeCode = FlowTypeCode
UPDATE Activity.tbOp SET SyncTypeCode = OpTypeCode
UPDATE Task.tbOp SET SyncTypeCode = OpTypeCode
go

ALTER TABLE Task.tbOp ENABLE TRIGGER Task_tbOp_TriggerUpdate
ALTER TABLE Task.tbFlow ENABLE TRIGGER Task_tbFlow_TriggerUpdate
GO

ALTER TABLE Activity.tbFlow  WITH CHECK ADD  CONSTRAINT FK_Activity_tbFlow_Activity_tbSyncType FOREIGN KEY(SyncTypeCode)
REFERENCES Activity.tbSyncType (SyncTypeCode)
go
ALTER TABLE Activity.tbFlow CHECK CONSTRAINT FK_Activity_tbFlow_Activity_tbSyncType
go
ALTER TABLE Activity.tbOp  WITH CHECK ADD  CONSTRAINT FK_Activity_tbOp_Activity_tbSyncType FOREIGN KEY(SyncTypeCode)
REFERENCES Activity.tbSyncType (SyncTypeCode)
go
ALTER TABLE Activity.tbOp CHECK CONSTRAINT FK_Activity_tbOp_Activity_tbSyncType
go
ALTER TABLE Task.tbFlow  WITH CHECK ADD  CONSTRAINT FK_Task_tbFlow_Activity_tbSyncType FOREIGN KEY(SyncTypeCode)
REFERENCES Activity.tbSyncType (SyncTypeCode)
go
ALTER TABLE Task.tbFlow CHECK CONSTRAINT FK_Task_tbFlow_Activity_tbSyncType
go
ALTER TABLE Task.tbOp  WITH CHECK ADD  CONSTRAINT FK_Task_tbOp_Activity_tbSyncType FOREIGN KEY(SyncTypeCode)
REFERENCES Activity.tbSyncType (SyncTypeCode)
go
ALTER TABLE Task.tbOp CHECK CONSTRAINT FK_Task_tbOp_Activity_tbSyncType
go


--**************************************************************************************
CREATE OR ALTER VIEW Task.vwOps
AS
SELECT        Task.tbOp.TaskCode, Task.tbOp.OperationNumber, Task.vwOpBucket.Period, Task.vwOpBucket.BucketId, Task.tbOp.UserId, Task.tbOp.SyncTypeCode, Task.tbOp.OpStatusCode, Task.tbOp.Operation, 
                         Task.tbOp.Note, Task.tbOp.StartOn, Task.tbOp.EndOn, Task.tbOp.Duration, Task.tbOp.OffsetDays, Task.tbOp.InsertedBy, Task.tbOp.InsertedOn, Task.tbOp.UpdatedBy, Task.tbOp.UpdatedOn, 
						 Task.tbTask.TaskTitle, Task.tbTask.TaskStatusCode, Task.tbStatus.TaskStatus, Task.tbTask.ActionOn, Task.tbTask.Quantity, Cash.tbCode.CashDescription, Task.tbTask.TotalCharge, Task.tbTask.AccountCode, Org.tbOrg.AccountName, 
                         Task.tbOp.RowVer AS OpRowVer, Task.tbTask.RowVer AS TaskRowVer
FROM            Task.tbOp INNER JOIN
                         Task.tbTask ON Task.tbOp.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Task.tbStatus ON Task.tbTask.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
                         Task.vwOpBucket ON Task.tbOp.TaskCode = Task.vwOpBucket.TaskCode AND Task.tbOp.OperationNumber = Task.vwOpBucket.OperationNumber LEFT OUTER JOIN
                         Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode
go
CREATE OR ALTER PROCEDURE [Task].[proc_Configure] 
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
			, @TaxCode nvarchar(10)

		IF @@NESTLEVEL = 1
			BEGIN TRANSACTION

		INSERT INTO Org.tbContact
									(AccountCode, ContactName, FileAs, PhoneNumber, FaxNumber, EmailAddress)
		SELECT        Task.tbTask.AccountCode, Task.tbTask.ContactName, Task.tbTask.ContactName AS NickName, Org.tbOrg.PhoneNumber, Org.tbOrg.FaxNumber, Org.tbOrg.EmailAddress
		FROM            Task.tbTask INNER JOIN
									Org.tbOrg ON Task.tbTask.AccountCode = Org.tbOrg.AccountCode
		WHERE        (Task.tbTask.TaskCode = @ParentTaskCode)
					AND EXISTS (SELECT     *
								FROM         Task.tbTask
								WHERE     (TaskCode = @ParentTaskCode) AND (NOT (ContactName IS NULL)) OR
														(TaskCode = @ParentTaskCode) AND (ContactName <> N''))
				AND NOT EXISTS(SELECT     *
								FROM         Task.tbTask INNER JOIN
													Org.tbContact ON Task.tbTask.AccountCode = Org.tbContact.AccountCode AND Task.tbTask.ContactName = Org.tbContact.ContactName
								WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode))
	
		UPDATE Org.tbOrg
		SET OrganisationStatusCode = 1
		FROM         Org.tbOrg INNER JOIN
									Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode
		WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode) AND ( Org.tbOrg.OrganisationStatusCode = 0)				
			AND EXISTS(SELECT     *
				FROM         Org.tbOrg INNER JOIN
									Task.tbTask ON Org.tbOrg.AccountCode = Task.tbTask.AccountCode
				WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode) AND ( Org.tbOrg.OrganisationStatusCode = 0))
	          
		UPDATE    Task.tbTask
		SET              ActionedOn = ActionOn
		WHERE     (TaskCode = @ParentTaskCode)
			AND EXISTS(SELECT     *
					  FROM         Task.tbTask
					  WHERE     (TaskStatusCode = 2) AND (TaskCode = @ParentTaskCode))

		UPDATE    Task.tbTask
		SET      TaskTitle = ActivityCode
		WHERE     (TaskCode = @ParentTaskCode)
			AND EXISTS(SELECT     *
				  FROM         Task.tbTask
				  WHERE     (TaskCode = @ParentTaskCode) AND (TaskTitle IS NULL))  	 				              
	     	
		INSERT INTO Task.tbAttribute
							  (TaskCode, Attribute, AttributeDescription, PrintOrder, AttributeTypeCode)
		SELECT     Task.tbTask.TaskCode, Activity.tbAttribute.Attribute, Activity.tbAttribute.DefaultText, Activity.tbAttribute.PrintOrder, Activity.tbAttribute.AttributeTypeCode
		FROM         Activity.tbAttribute INNER JOIN
							  Task.tbTask ON Activity.tbAttribute.ActivityCode = Task.tbTask.ActivityCode
		WHERE     ( Task.tbTask.TaskCode = @ParentTaskCode)
	
		INSERT INTO Task.tbOp
							  (TaskCode, UserId, OperationNumber, SyncTypeCode, Operation, Duration, OffsetDays, StartOn)
		SELECT     Task.tbTask.TaskCode, Task.tbTask.UserId, Activity.tbOp.OperationNumber, Activity.tbOp.SyncTypeCode, Activity.tbOp.Operation, Activity.tbOp.Duration, 
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
				@AccountCode = Task.tbTask.AccountCode
			FROM         Activity.tbFlow INNER JOIN
								  Activity.tbActivity ON Activity.tbFlow.ChildCode = Activity.tbActivity.ActivityCode INNER JOIN
								  Task.tbTask ON Activity.tbFlow.ParentCode = Task.tbTask.ActivityCode
			WHERE     ( Activity.tbFlow.StepNumber = @StepNumber) AND ( Task.tbTask.TaskCode = @ParentTaskCode)
		
			EXEC Task.proc_NextCode @ActivityCode, @TaskCode output

			INSERT INTO Task.tbTask
								(TaskCode, UserId, AccountCode, ContactName, ActivityCode, TaskStatusCode, ActionById, ActionOn, TaskNotes, Quantity, UnitCharge,
								AddressCodeFrom, AddressCodeTo, CashCode, Printed, TaskTitle)
			SELECT     @TaskCode AS NewTask, Task_tb1.UserId, Task_tb1.AccountCode, Task_tb1.ContactName, Activity.tbActivity.ActivityCode, Activity.tbActivity.TaskStatusCode, 
								Task_tb1.ActionById, Task_tb1.ActionOn, Activity.tbActivity.DefaultText, Task_tb1.Quantity * Activity.tbFlow.UsedOnQuantity AS Quantity,
								Activity.tbActivity.UnitCharge, Org.tbOrg.AddressCode AS AddressCodeFrom, Org.tbOrg.AddressCode AS AddressCodeTo, 
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
								  (ParentTaskCode, StepNumber, ChildTaskCode, SyncTypeCode, UsedOnQuantity, OffsetDays)
			SELECT     Task.tbTask.TaskCode, Activity.tbFlow.StepNumber, @TaskCode AS ChildTaskCode, Activity.tbFlow.SyncTypeCode, Activity.tbFlow.UsedOnQuantity, Activity.tbFlow.OffsetDays
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
CREATE OR ALTER PROCEDURE Task.proc_Schedule (@ParentTaskCode nvarchar(20))
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF @@NESTLEVEL = 1
			BEGIN TRANSACTION;

		WITH ops_top_level AS
		(
			SELECT task.TaskCode, ops.OperationNumber, ops.OffsetDays, task.ActionOn, ops.StartOn, ops.EndOn, task.TaskStatusCode, ops.OpStatusCode, ops.SyncTypeCode
			FROM Task.tbOp ops JOIN Task.tbTask task ON ops.TaskCode = task.TaskCode
			WHERE task.TaskCode = @ParentTaskCode
		), ops_candidates AS
		(
			SELECT *,
				ROW_NUMBER() OVER (PARTITION BY TaskCode ORDER BY TaskCode, OperationNumber DESC) AS LastOpRow,
				ROW_NUMBER() OVER (PARTITION BY TaskCode ORDER BY TaskCode, OperationNumber) AS FirstOpRow
			FROM ops_top_level
		), ops_unscheduled1 AS
		(
			SELECT TaskCode, OperationNumber,
				CASE TaskStatusCode 
					WHEN 0 THEN 0 
					WHEN 1 THEN 
						CASE WHEN FirstOpRow = 1 AND OpStatusCode < 1 THEN 1 ELSE OpStatusCode END				
					ELSE 2
					END AS OpStatusCode,
				CASE WHEN LastOpRow = 1 THEN App.fnAdjustToCalendar(ActionOn, OffsetDays) ELSE StartOn END AS StartOn,
				CASE WHEN LastOpRow = 1 THEN ActionOn ELSE EndOn END AS EndOn,
				LastOpRow,
				OffsetDays,
				CASE SyncTypeCode WHEN 1 THEN 0 ELSE OffsetDays END AS AsyncOffsetDays
			FROM ops_candidates
		)
		, ops_unscheduled2 AS
		(
			SELECT TaskCode, OperationNumber, OpStatusCode, 
				FIRST_VALUE(EndOn) OVER (PARTITION BY TaskCode ORDER BY OperationNumber DESC) AS ActionOn, 
				LAG(AsyncOffsetDays, 1, 0) OVER (PARTITION BY TaskCode ORDER BY OperationNumber DESC) AS AsyncOffsetDays,
				OffsetDays
			FROM ops_unscheduled1
		), ops_scheduled AS
		(
			SELECT TaskCode, OperationNumber, OpStatusCode,
				App.fnAdjustToCalendar(ActionOn, SUM(AsyncOffsetDays) OVER (PARTITION BY TaskCode ORDER BY OperationNumber DESC)) AS EndOn,
				App.fnAdjustToCalendar(ActionOn, SUM(AsyncOffsetDays) OVER (PARTITION BY TaskCode ORDER BY OperationNumber DESC) + OffsetDays) AS StartOn
			FROM ops_unscheduled2
		)
		UPDATE op
		SET OpStatusCode = ops_scheduled.OpStatusCode,
			StartOn = ops_scheduled.StartOn, EndOn = ops_scheduled.EndOn
		FROM Task.tbOp op JOIN ops_scheduled 
			ON op.TaskCode = ops_scheduled.TaskCode AND op.OperationNumber = ops_scheduled.OperationNumber;

		WITH first_op AS
		(
			SELECT Task.tbOp.TaskCode, MIN(Task.tbOp.StartOn) EndOn
			FROM Task.tbOp
			WHERE  (Task.tbOp.TaskCode = @ParentTaskCode)
			GROUP BY Task.tbOp.TaskCode
		), parent_task AS
		(
			SELECT  Task.tbTask.TaskCode, TaskStatusCode, Quantity, ISNULL(EndOn, Task.tbTask.ActionOn) AS EndOn, Task.tbTask.ActionOn
			FROM Task.tbTask LEFT OUTER JOIN first_op ON first_op.TaskCode = Task.tbTask.TaskCode
			WHERE  (Task.tbTask.TaskCode = @ParentTaskCode)	
		), task_flow AS
		(
			SELECT work_flow.ParentTaskCode, work_flow.ChildTaskCode, work_flow.StepNumber,
				CASE WHEN work_flow.UsedOnQuantity <> 0 THEN parent_task.Quantity * work_flow.UsedOnQuantity ELSE child_task.Quantity END AS Quantity, 
				CASE WHEN parent_task.TaskStatusCode < 3 AND child_task.TaskStatusCode < parent_task.TaskStatusCode 
					THEN parent_task.TaskStatusCode 
					ELSE child_task.TaskStatusCode 
					END AS TaskStatusCode,
				CASE SyncTypeCode WHEN 2 THEN parent_task.ActionOn ELSE parent_task.EndOn END AS EndOn, 
				parent_task.ActionOn,
				CASE SyncTypeCode WHEN 0 THEN 0 ELSE OffsetDays END  AS OffsetDays,
				CASE SyncTypeCode WHEN 1 THEN 0 ELSE OffsetDays END AS AsyncOffsetDays,
				SyncTypeCode
			FROM parent_task 
				JOIN Task.tbFlow work_flow ON parent_task.TaskCode = work_flow.ParentTaskCode
				JOIN Task.tbTask child_task ON work_flow.ChildTaskCode = child_task.TaskCode
				
		), calloff_tasks_lag AS
		(
			SELECT ParentTaskCode, ChildTaskCode, StepNumber, Quantity, TaskStatusCode, ActionOn EndOn, OffsetDays, 
					LAG(AsyncOffsetDays, 1, 0) OVER (PARTITION BY ParentTaskCode ORDER BY StepNumber DESC) AS AsyncOffsetDays, 2SyncTypeCode	 
			FROM task_flow
			WHERE EXISTS(SELECT * FROM task_flow WHERE SyncTypeCode = 2)
				AND (StepNumber > (SELECT TOP 1 StepNumber FROM task_flow WHERE SyncTypeCode = 0 ORDER BY StepNumber DESC)
					OR NOT EXISTS (SELECT * FROM task_flow WHERE SyncTypeCode = 0))
		), calloff_tasks AS
		(
			SELECT ParentTaskCode, ChildTaskCode, StepNumber, Quantity, TaskStatusCode, EndOn, OffsetDays, 
				SUM(AsyncOffsetDays) OVER (PARTITION BY ParentTaskCode ORDER BY StepNumber DESC) AS AsyncOffsetDays
			FROM calloff_tasks_lag
		), servicing_tasks_lag AS
		(
			SELECT ParentTaskCode, ChildTaskCode, StepNumber, Quantity, TaskStatusCode, EndOn, OffsetDays, 
					LAG(AsyncOffsetDays, 1, 0) OVER (PARTITION BY ParentTaskCode ORDER BY StepNumber DESC) AS AsyncOffsetDays
			FROM task_flow
			WHERE (StepNumber < (SELECT MIN(StepNumber) FROM calloff_tasks_lag))
				OR NOT EXISTS (SELECT * FROM task_flow WHERE SyncTypeCode = 2)
		), servicing_tasks AS
		(
			SELECT ParentTaskCode, ChildTaskCode, StepNumber, Quantity, TaskStatusCode, EndOn, OffsetDays, 
				SUM(AsyncOffsetDays) OVER (PARTITION BY ParentTaskCode ORDER BY StepNumber DESC) AS AsyncOffsetDays
			FROM servicing_tasks_lag
		), schedule AS
		(
			SELECT ChildTaskCode AS TaskCode, Quantity, TaskStatusCode, 
				DATEADD(DAY, (AsyncOffsetDays + OffsetDays) * -1, EndOn) AS ActionOn
			FROM calloff_tasks
			UNION
			SELECT ChildTaskCode AS TaskCode, Quantity, TaskStatusCode, 
				DATEADD(DAY, (AsyncOffsetDays + OffsetDays) * -1, EndOn) AS ActionOn
			FROM servicing_tasks
		)
		UPDATE task
		SET
			Quantity = schedule.Quantity,
			ActionOn = schedule.ActionOn,
			TaskStatusCode = schedule.TaskStatusCode
		FROM Task.tbTask task
			JOIN schedule ON task.TaskCode = schedule.TaskCode;

		DECLARE child_tasks CURSOR LOCAL FOR
			SELECT ChildTaskCode FROM Task.tbFlow WHERE ParentTaskCode = @ParentTaskCode;

		DECLARE @ChildTaskCode NVARCHAR(20);

		OPEN child_tasks;

		FETCH NEXT FROM child_tasks INTO @ChildTaskCode
		
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			EXEC Task.proc_Schedule @ChildTaskCode
			FETCH NEXT FROM child_tasks INTO @ChildTaskCode
		END

		CLOSE child_tasks;
		DEALLOCATE child_tasks;

		IF @@NESTLEVEL = 1
			COMMIT TRANSACTION;

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

		INSERT INTO Task.tbTask
							  (TaskCode, UserId, AccountCode, TaskTitle, ContactName, ActivityCode, TaskStatusCode, ActionById, ActionOn, ActionedOn, TaskNotes, Quantity, 
							  SecondReference, CashCode, TaxCode, UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, Printed)
		SELECT     @ToTaskCode AS ToTaskCode, @UserId AS Owner, AccountCode, TaskTitle, ContactName, ActivityCode, @TaskStatusCode AS TaskStatus, 
							  @UserId AS ActionUserId, CAST(CURRENT_TIMESTAMP AS date) AS ActionOn, 
							  CASE WHEN @TaskStatusCode > 1 THEN CAST(CURRENT_TIMESTAMP AS date) ELSE NULL END AS ActionedOn, TaskNotes, 
							  Quantity, SecondReference, CashCode, TaxCode, UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, @Printed AS Printed
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
							  (TaskCode, OperationNumber, OpStatusCode, UserId, SyncTypeCode, Operation, Note, StartOn, EndOn, Duration, OffsetDays)
		SELECT     @ToTaskCode AS ToTaskCode, OperationNumber, 0 AS OpStatusCode, UserId, SyncTypeCode, Operation, Note, 
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
				(ParentTaskCode, StepNumber, ChildTaskCode, SyncTypeCode, UsedOnQuantity, OffsetDays)
				SELECT TOP 1 ParentTaskCode, @StepNumber AS Step, @ToTaskCode AS ChildTask, SyncTypeCode, UsedOnQuantity, OffsetDays
				FROM         Task.tbFlow
				WHERE     (ChildTaskCode = @FromTaskCode)
				END
			END
		ELSE
			BEGIN		
			INSERT INTO Task.tbFlow
			(ParentTaskCode, StepNumber, ChildTaskCode, SyncTypeCode, UsedOnQuantity, OffsetDays)
			SELECT TOP 1 @ParentTaskCode As ParentTask, StepNumber, @ToTaskCode AS ChildTask, SyncTypeCode, UsedOnQuantity, OffsetDays
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
			BEGIN
			COMMIT TRANSACTION
			EXEC Task.proc_Schedule @ToTaskCode
			END

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER TRIGGER Task.Task_tbOp_TriggerUpdate 
   ON  Task.tbOp 
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @Msg NVARCHAR(MAX);

		UPDATE ops
		SET StartOn = CAST(ops.StartOn AS DATE), EndOn = CAST(ops.EndOn AS DATE)
		FROM Task.tbOp ops JOIN inserted i ON ops.TaskCode = i.TaskCode AND ops.OperationNumber = i.OperationNumber
		WHERE (DATEDIFF(SECOND, CAST(i.StartOn AS DATE), i.StartOn) <> 0 
				OR DATEDIFF(SECOND, CAST(i.EndOn AS DATE), i.EndOn) <> 0);
					
		IF EXISTS (	SELECT *
				FROM inserted
					JOIN Task.tbOp ops ON inserted.TaskCode = ops.TaskCode AND inserted.OperationNumber = ops.OperationNumber
				WHERE inserted.StartOn > inserted.EndOn)
			BEGIN
			SELECT @Msg = Message FROM App.tbText WHERE TextId = 3016;
			RAISERROR (@Msg, 16, 1);
			END;

		WITH tasks AS
		(
			SELECT TaskCode FROM inserted GROUP BY TaskCode
		), last_calloff AS
		(
			SELECT ops.TaskCode, MAX(OperationNumber) AS OperationNumber
			FROM Task.tbOp ops JOIN tasks ON ops.TaskCode = tasks.TaskCode	
			WHERE SyncTypeCode = 2 
			GROUP BY ops.TaskCode
		), calloff AS
		(
			SELECT inserted.TaskCode, inserted.EndOn FROM inserted 
			JOIN last_calloff ON inserted.TaskCode = last_calloff.TaskCode AND inserted.OperationNumber = last_calloff.OperationNumber
			WHERE SyncTypeCode = 2
		)
		UPDATE task
		SET ActionOn = calloff.EndOn
		FROM Task.tbTask task
		JOIN calloff ON task.TaskCode = calloff.TaskCode
		WHERE calloff.EndOn <> task.ActionOn AND task.TaskStatusCode < 3;

		UPDATE Task.tbOp
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Task.tbOp INNER JOIN inserted AS i ON tbOp.TaskCode = i.TaskCode AND tbOp.OperationNumber = i.OperationNumber;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
CREATE OR ALTER TRIGGER Task.Task_tbTask_TriggerUpdate
ON Task.tbTask
FOR UPDATE
AS
	SET NOCOUNT ON;

	BEGIN TRY

		UPDATE task
		SET task.ActionOn = CAST(task.ActionOn AS DATE)
		FROM Task.tbTask task JOIN inserted i ON task.TaskCode = i.TaskCode
		WHERE DATEDIFF(SECOND, CAST(i.ActionOn AS DATE), i.ActionOn) <> 0;

		IF UPDATE(TaskStatusCode)
			BEGIN
			UPDATE ops
			SET OpStatusCode = 2
			FROM inserted JOIN Task.tbOp ops ON inserted.TaskCode = ops.TaskCode
			WHERE TaskStatusCode > 1 AND OpStatusCode < 2;

			WITH first_ops AS
			(
				SELECT ops.TaskCode, MIN(ops.OperationNumber) AS OperationNumber
				FROM inserted i JOIN Task.tbOp ops ON i.TaskCode = ops.TaskCode 
				WHERE i.TaskStatusCode = 1		
				GROUP BY ops.TaskCode		
			), next_ops AS
			(
				SELECT ops.TaskCode, ops.OperationNumber, ops.SyncTypeCode,
					LEAD(ops.OperationNumber) OVER (PARTITION BY ops.TaskCode ORDER BY ops.OperationNumber) AS NextOpNo
				FROM inserted i JOIN Task.tbOp ops ON i.TaskCode = ops.TaskCode 
			), async_ops AS
			(
				SELECT first_ops.TaskCode, first_ops.OperationNumber, next_ops.NextOpNo
				FROM first_ops JOIN next_ops ON first_ops.TaskCode = next_ops.TaskCode AND first_ops.OperationNumber = next_ops.OperationNumber

				UNION ALL

				SELECT next_ops.TaskCode, next_ops.OperationNumber, next_ops.NextOpNo
				FROM next_ops JOIN async_ops ON next_ops.TaskCode = async_ops.TaskCode AND next_ops.OperationNumber = async_ops.NextOpNo
				WHERE next_ops.SyncTypeCode = 1

			)
			UPDATE ops
			SET OpStatusCode = 1
			FROM async_ops JOIN Task.tbOp ops ON async_ops.TaskCode = ops.TaskCode
				AND async_ops.OperationNumber = ops.OperationNumber;
			
			WITH cascade_status AS
			(
				SELECT TaskCode, TaskStatusCode
				FROM Task.tbTask inserted
				WHERE NOT CashCode IS NULL AND TaskStatusCode > 1
			), task_flow AS
			(
				SELECT cascade_status.TaskStatusCode ParentStatusCode, child.ParentTaskCode, child.ChildTaskCode, child_task.TaskStatusCode
					, 1 AS Depth				
				FROM Task.tbFlow child 
					JOIN cascade_status ON child.ParentTaskCode = cascade_status.TaskCode
					JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
				WHERE CashCode IS NULL

				UNION ALL

				SELECT parent.ParentStatusCode, child.ParentTaskCode, child.ChildTaskCode, child_task.TaskStatusCode
					, parent.Depth + 1 AS Depth
				FROM Task.tbFlow child 
					JOIN task_flow parent ON child.ParentTaskCode = parent.ChildTaskCode
					JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
				WHERE CashCode IS NULL
			)
			UPDATE task
			SET TaskStatusCode = CASE task_flow.ParentStatusCode WHEN 3 THEN 2 ELSE task_flow.ParentStatusCode END
			FROM Task.tbTask task JOIN task_flow ON task_flow.ChildTaskCode = task.TaskCode
			WHERE task.TaskStatusCode < 2;

			--not triggering fix
			WITH cascade_status AS
			(
				SELECT TaskCode, TaskStatusCode
				FROM Task.tbTask inserted
				WHERE NOT CashCode IS NULL AND TaskStatusCode > 1
			), task_flow AS
			(
				SELECT cascade_status.TaskStatusCode ParentStatusCode, child.ParentTaskCode, child.ChildTaskCode, child_task.TaskStatusCode
					, 1 AS Depth				
				FROM Task.tbFlow child 
					JOIN cascade_status ON child.ParentTaskCode = cascade_status.TaskCode
					JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
				WHERE CashCode IS NULL

				UNION ALL

				SELECT parent.ParentStatusCode, child.ParentTaskCode, child.ChildTaskCode, child_task.TaskStatusCode
					, parent.Depth + 1 AS Depth
				FROM Task.tbFlow child 
					JOIN task_flow parent ON child.ParentTaskCode = parent.ChildTaskCode
					JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
				WHERE CashCode IS NULL
			)
			UPDATE ops
			SET OpStatusCode = 2
			FROM Task.tbOp ops JOIN task_flow ON task_flow.ChildTaskCode = ops.TaskCode
			WHERE ops.OpStatusCode < 2;

			END

		IF UPDATE(Quantity)
			BEGIN
			UPDATE flow
			SET UsedOnQuantity = inserted.Quantity / parent_task.Quantity
			FROM Task.tbFlow AS flow 
				JOIN inserted ON flow.ChildTaskCode = inserted.TaskCode 
				JOIN Task.tbTask AS parent_task ON flow.ParentTaskCode = parent_task.TaskCode
				JOIN Cash.tbCode ON parent_task.CashCode = Cash.tbCode.CashCode
			WHERE (flow.UsedOnQuantity <> 0) AND (inserted.Quantity <> 0) 
				AND (inserted.Quantity / parent_task.Quantity <> flow.UsedOnQuantity)
			END

		IF UPDATE(Quantity) OR UPDATE(UnitCharge)
			BEGIN
			UPDATE task
			SET task.TotalCharge = i.Quantity * i.UnitCharge
			FROM Task.tbTask task JOIN inserted i ON task.TaskCode = i.TaskCode
			END

		IF UPDATE(TotalCharge)
			BEGIN
			UPDATE task
			SET task.UnitCharge = CASE i.TotalCharge + i.Quantity WHEN 0 THEN 0 ELSE i.TotalCharge / i.Quantity END
			FROM Task.tbTask task JOIN inserted i ON task.TaskCode = i.TaskCode			
			END

		IF UPDATE(ActionOn)
			BEGIN			
			WITH parent_task AS
			(
				SELECT        ParentTaskCode
				FROM            Task.tbFlow flow
					JOIN Task.tbTask task ON flow.ParentTaskCode = task.TaskCode
					JOIN Cash.tbCode cash ON task.CashCode = cash.CashCode
					JOIN inserted ON flow.ChildTaskCode = inserted.TaskCode
				--manual scheduling only
				WHERE (SELECT SUM(UsedOnQuantity) FROM inserted JOIN Task.tbFlow ON inserted.TaskCode = Task.tbFlow.ChildTaskCode) = 0	
			), task_flow AS
			(
				SELECT        flow.ParentTaskCode, flow.StepNumber, task.ActionOn,
						LAG(task.ActionOn, 1, task.ActionOn) OVER (PARTITION BY flow.ParentTaskCode ORDER BY StepNumber) AS PrevActionOn
				FROM Task.tbFlow flow
					JOIN Task.tbTask task ON flow.ChildTaskCode = task.TaskCode
					JOIN parent_task ON flow.ParentTaskCode = parent_task.ParentTaskCode
			), step_disordered AS
			(
				SELECT ParentTaskCode 
				FROM task_flow
				WHERE ActionOn < PrevActionOn
				GROUP BY ParentTaskCode
			), step_ordered AS
			(
				SELECT flow.ParentTaskCode, flow.ChildTaskCode,
					ROW_NUMBER() OVER (PARTITION BY flow.ParentTaskCode ORDER BY task.ActionOn, flow.StepNumber) * 10 AS StepNumber 
				FROM step_disordered
					JOIN Task.tbFlow flow ON step_disordered.ParentTaskCode = flow.ParentTaskCode
					JOIN Task.tbTask task ON flow.ChildTaskCode = task.TaskCode
			)
			UPDATE flow
			SET
				StepNumber = step_ordered.StepNumber
			FROM Task.tbFlow flow
				JOIN step_ordered ON flow.ParentTaskCode = step_ordered.ParentTaskCode AND flow.ChildTaskCode = step_ordered.ChildTaskCode;

			UPDATE flow
			SET OffsetDays = App.fnOffsetDays(inserted.ActionOn, parent_task.ActionOn)
								- ISNULL((SELECT SUM(OffsetDays) FROM Task.tbFlow sub_flow WHERE sub_flow.ParentTaskCode = flow.ParentTaskCode AND sub_flow.StepNumber > flow.StepNumber), 0)
			FROM Task.tbFlow AS flow 
				JOIN inserted ON flow.ChildTaskCode = inserted.TaskCode 
				JOIN Task.tbTask AS parent_task ON flow.ParentTaskCode = parent_task.TaskCode
				JOIN Cash.tbCode ON parent_task.CashCode = Cash.tbCode.CashCode
			WHERE (SELECT SUM(UsedOnQuantity) FROM inserted JOIN Task.tbFlow ON inserted.TaskCode = Task.tbFlow.ChildTaskCode) = 0

			UPDATE task
			SET PaymentOn = App.fnAdjustToCalendar(CASE WHEN org.PayDaysFromMonthEnd <> 0 
													THEN 
														DATEADD(d, -1, DATEADD(m, 1, CONCAT(FORMAT(DATEADD(d, org.PaymentDays + org.ExpectedDays, i.ActionOn), 'yyyyMM'), '01')))												
													ELSE
														DATEADD(d, org.PaymentDays + org.ExpectedDays, i.ActionOn)	
													END, 0) 
			FROM Task.tbTask task
				JOIN inserted i ON task.TaskCode = i.TaskCode
				JOIN Org.tbOrg org ON i.AccountCode = org.AccountCode				
			WHERE NOT task.CashCode IS NULL 
			END

		IF UPDATE (TaskTitle)
		BEGIN
			WITH cascade_title_change AS
			(
				SELECT inserted.TaskCode, inserted.TaskTitle AS TaskTitle, deleted.TaskTitle AS PreviousTitle 				
				FROM inserted
					JOIN deleted ON inserted.TaskCode = deleted.TaskCode
			), task_flow AS
			(
				SELECT cascade_title_change.TaskTitle AS ProjectTitle, cascade_title_change.PreviousTitle, child.ParentTaskCode, child.ChildTaskCode, child_task.TaskTitle,
					1 AS Depth				
				FROM Task.tbFlow child 
					JOIN cascade_title_change ON child.ParentTaskCode = cascade_title_change.TaskCode
					JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode

				UNION ALL

				SELECT parent.ProjectTitle, parent.PreviousTitle, child.ParentTaskCode, child.ChildTaskCode, child_task.TaskTitle,
					parent.Depth + 1 AS Depth
				FROM Task.tbFlow child 
					JOIN task_flow parent ON child.ParentTaskCode = parent.ChildTaskCode
					JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
			)
			UPDATE task
			SET TaskTitle = ProjectTitle
			FROM Task.tbTask task JOIN task_flow ON task.TaskCode = task_flow.ChildTaskCode
			WHERE task_flow.PreviousTitle = task_flow.TaskTitle;
		END

		IF UPDATE (Spooled)
		BEGIN
			INSERT INTO App.tbDocSpool (DocTypeCode, DocumentNumber)
			SELECT CASE 
					WHEN CashModeCode = 0 THEN		--Expense
						CASE WHEN TaskStatusCode = 0 THEN 2	ELSE 3 END	--Enquiry								
					WHEN CashModeCode = 1 THEN		--Income
						CASE WHEN TaskStatusCode = 0 THEN 0	ELSE 1 END	--Quote
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
			SELECT DISTINCT AccountCode, ContactName FROM inserted
			WHERE EXISTS (SELECT     *
						FROM         inserted AS i
						WHERE     (NOT (ContactName IS NULL)) AND
												(ContactName <> N''))
				AND NOT EXISTS(SELECT  *
								FROM         inserted AS i INNER JOIN
													Org.tbContact ON i.AccountCode = Org.tbContact.AccountCode AND i.ContactName = Org.tbContact.ContactName)
		END
		
		UPDATE Task.tbTask
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Task.tbTask INNER JOIN inserted AS i ON tbTask.TaskCode = i.TaskCode;

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

--**************************************************************************************

ALTER TABLE [Task].[tbFlow] DROP 
	CONSTRAINT [FK_Task_tbFlow_Activity_tbFlowType], DF_Task_tbFlow_FlowTypeCode,
	COLUMN FlowTypeCode;

ALTER TABLE [Activity].[tbFlow] DROP 
	CONSTRAINT [FK_Activity_tbFlow_Activity_tbFlowType], DF_Activity_tbFlow_FlowTypeCode,
	COLUMN FlowTypeCode;

ALTER TABLE [Activity].[tbOp] DROP 
	CONSTRAINT [FK_Activity_tbOp_Activity_tbOpType], DF_Activity_tbOp_OpTypeCode,
	COLUMN OpTypeCode;
	
ALTER TABLE [Task].[tbOp] DROP 
	CONSTRAINT [FK_Task_tbOp_Activity_tbOpType], DF_Task_tbOp_OpTypeCode,
	COLUMN OpTypeCode;
go


	