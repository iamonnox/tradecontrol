

IF NOT EXISTS (SELECT * FROM Activity.tbOpType WHERE OpTypeCode = 2)
	BEGIN
	INSERT INTO Activity.tbOpType (OpTypeCode, OpType)	VALUES (2, 'CALL-OFF');
	UPDATE Activity.tbOpType SET OpType = 'SYNC' WHERE OpTypeCode = 0;
	UPDATE Activity.tbOpType SET OpType = 'ASYNC' WHERE OpTypeCode = 1;
	UPDATE Activity.tbOp SET OpTypeCode = 2 WHERE OpTypeCode = 1;
	UPDATE Task.tbOp SET  OpTypeCode = 2 WHERE OpTypeCode = 1;
	END
go
BEGIN TRY
ALTER TABLE App.tbOptions 
	DROP CONSTRAINT DF_App_tbOptions_ScheduleOps,
	COLUMN ScheduleOps;
END TRY
BEGIN CATCH
	PRINT 'Options Updated'
END CATCH
go 

ALTER FUNCTION [App].[fnAdjustToCalendar]
	(
	@SourceDate datetime,
	@OffsetDays int
	)
RETURNS DATETIME
AS
BEGIN
	
	DECLARE 
		  @OutputDate datetime = @SourceDate
		, @CalendarCode nvarchar(10)
		, @WorkingDay bit
		, @CurrentDay smallint
		, @Monday smallint
		, @Tuesday smallint
		, @Wednesday smallint
		, @Thursday smallint
		, @Friday smallint
		, @Saturday smallint
		, @Sunday smallint
			

	SELECT     @CalendarCode = App.tbCalendar.CalendarCode, @Monday = Monday, @Tuesday = Tuesday, @Wednesday = Wednesday, @Thursday = Thursday, @Friday = Friday, @Saturday = Saturday, @Sunday = Sunday
	FROM         App.tbCalendar INNER JOIN
							Usr.tbUser ON App.tbCalendar.CalendarCode = Usr.tbUser.CalendarCode
	WHERE UserId = (SELECT TOP (1) UserId FROM Usr.vwCredentials)
	
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
	
	RETURN @OutputDate				
END
go
CREATE OR ALTER FUNCTION App.fnOffsetDays(@StartOn DATE, @EndOn DATE)
RETURNS SMALLINT
AS
BEGIN

	DECLARE 
		@OffsetDays SMALLINT = 0		  
		, @CalendarCode nvarchar(10)
		, @WorkingDay bit
		, @CurrentDay smallint
		, @Monday smallint
		, @Tuesday smallint
		, @Wednesday smallint
		, @Thursday smallint
		, @Friday smallint
		, @Saturday smallint
		, @Sunday smallint
			
	
	IF DATEDIFF(DAY, @StartOn, @EndOn) <= 0
		RETURN 0

	SELECT     @CalendarCode = App.tbCalendar.CalendarCode, @Monday = Monday, @Tuesday = Tuesday, @Wednesday = Wednesday, @Thursday = Thursday, @Friday = Friday, @Saturday = Saturday, @Sunday = Sunday
	FROM         App.tbCalendar INNER JOIN
							Usr.tbUser ON App.tbCalendar.CalendarCode = Usr.tbUser.CalendarCode
	WHERE UserId = (SELECT TOP (1) UserId FROM Usr.vwCredentials)
	
	WHILE @EndOn <> @StartOn
		BEGIN
		
		SET @CurrentDay = App.fnWeekDay(@EndOn)
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
						WHERE     (CalendarCode = @CalendarCode) AND (UnavailableOn = @EndOn))
				SET @OffsetDays += 1
			END
			
		SET @EndOn = DATEADD(d, -1, @EndOn)
		END

	
	RETURN @OffsetDays

END
go
ALTER PROCEDURE Task.proc_DefaultPaymentOn
	(
		@AccountCode nvarchar(10),
		@ActionOn datetime,
		@PaymentOn datetime output
	)
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		SELECT @PaymentOn = 
					App.fnAdjustToCalendar(	CASE WHEN org.PayDaysFromMonthEnd <> 0 THEN 
												DATEADD(d, org.PaymentDays, DATEADD(d, DAY(@ActionOn) * -1, DATEADD(m, 1, @ActionOn)))
											ELSE
												DATEADD(d, org.PaymentDays, @ActionOn)	
											END, 0) 					
		FROM Org.tbOrg org 
		WHERE org.AccountCode = @AccountCode
	 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER TRIGGER [Task].[Task_tbTask_TriggerInsert]
ON [Task].[tbTask]
FOR INSERT
AS
	SET NOCOUNT ON;
	BEGIN TRY

	UPDATE task
	SET task.ActionOn = CAST(task.ActionOn AS DATE)
	FROM Task.tbTask task JOIN inserted i ON task.TaskCode = i.TaskCode
	WHERE DATEDIFF(SECOND, CAST(i.ActionOn AS DATE), i.ActionOn) <> 0;

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
ALTER TRIGGER [Task].[Task_tbTask_TriggerUpdate]
ON [Task].[tbTask]
FOR UPDATE
AS
	SET NOCOUNT ON;
	BEGIN TRY

		UPDATE task
		SET task.ActionOn = CAST(task.ActionOn AS DATE)
		FROM Task.tbTask task JOIN inserted i ON task.TaskCode = i.TaskCode
		WHERE DATEDIFF(SECOND, CAST(i.ActionOn AS DATE), i.ActionOn) <> 0;

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

		IF UPDATE(ActionOn)
			BEGIN
			WITH parent_task AS
			(
				SELECT        ParentTaskCode
				FROM            Task.tbFlow flow
					JOIN Task.tbTask task ON flow.ParentTaskCode = task.TaskCode
					JOIN Cash.tbCode cash ON task.CashCode = cash.CashCode
					JOIN inserted ON flow.ChildTaskCode = inserted.TaskCode
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
			END

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
ALTER TABLE [Task].[tbOp] DROP CONSTRAINT [DF_Task_tbOp_OpTypeCode];
ALTER TABLE [Task].[tbOp] ADD  CONSTRAINT [DF_Task_tbOp_OpTypeCode] DEFAULT (2) FOR [OpTypeCode];
ALTER TABLE [Task].[tbOp] DROP CONSTRAINT [DF_Task_tbOp_OpStatusCode];
ALTER TABLE [Task].[tbOp] ADD  CONSTRAINT [DF_Task_tbOp_OpStatusCode]  DEFAULT (0) FOR [OpStatusCode];
go
IF NOT EXISTS (SELECT * FROM App.tbText WHERE TextId = 3016)
	INSERT INTO App.tbText (TextId, [Message], Arguments) VALUES (3016, 'Operations cannot end before they have been started', 0);

go
ALTER   TRIGGER [Task].[Task_tbOp_TriggerUpdate] 
   ON  [Task].[tbOp] 
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
			SELECT @Msg = [Message] FROM App.tbText WHERE TextId = 3016;
			RAISERROR (@Msg, 16, 1);
			END;

		WITH tasks AS
		(
			SELECT TaskCode FROM inserted GROUP BY TaskCode
		), op_sequence AS
		(
			SELECT        ops.TaskCode, ops.OperationNumber, ops.EndOn,
					LAG(ops.EndOn, 1, ops.EndOn) OVER (PARTITION BY ops.TaskCode ORDER BY ops.OperationNumber) AS PrevEndOn
			FROM Task.tbOp ops JOIN tasks ON ops.TaskCode = tasks.TaskCode			
		), ops_disordered AS
		(
			SELECT TaskCode 
			FROM op_sequence
			WHERE EndOn < PrevEndOn
			GROUP BY TaskCode
		), ops_ordered AS
		(
			SELECT ops.TaskCode, ops.OperationNumber,
				ROW_NUMBER() OVER (PARTITION BY ops.TaskCode ORDER BY ops.EndOn, ops.OperationNumber) * 10 AS NewOperationNumber
		
			FROM ops_disordered
				JOIN Task.tbOp ops ON ops_disordered.TaskCode = ops.TaskCode
		)
		UPDATE ops
		SET
			OperationNumber = ops_ordered.NewOperationNumber
		FROM ops_ordered
		JOIN Task.tbOp ops ON ops_ordered.TaskCode = ops.TaskCode AND ops_ordered.OperationNumber = ops.OperationNumber;

		WITH tasks AS
		(
			SELECT TaskCode FROM inserted GROUP BY TaskCode
		), last_calloff AS
		(
			SELECT ops.TaskCode, MAX(OperationNumber) AS OperationNumber
			FROM Task.tbOp ops JOIN tasks ON ops.TaskCode = tasks.TaskCode	
			WHERE OpTypeCode = 2 
			GROUP BY ops.TaskCode
		), calloff AS
		(
			SELECT inserted.TaskCode, inserted.EndOn FROM inserted 
			JOIN last_calloff ON inserted.TaskCode = last_calloff.TaskCode AND inserted.OperationNumber = last_calloff.OperationNumber
			WHERE OpTypeCode = 2
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
CREATE OR ALTER PROCEDURE Task.proc_Schedule (@ParentTaskCode nvarchar(20))
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

		WITH task_flow AS
		(
			SELECT parent_task.TaskCode, child.ParentTaskCode, child.ChildTaskCode, 
				CASE WHEN child.UsedOnQuantity <> 0 THEN parent_task.Quantity * child.UsedOnQuantity ELSE child_task.Quantity END AS Quantity, 
				App.fnAdjustToCalendar(parent_task.ActionOn, SUM(child.OffsetDays) OVER (PARTITION BY child.ParentTaskCode ORDER BY child.StepNumber DESC)) AS ActionOn, 
				CASE WHEN parent_task.TaskStatusCode < 3 AND child_task.TaskStatusCode < parent_task.TaskStatusCode 
					THEN parent_task.TaskStatusCode 
					ELSE child_task.TaskStatusCode 
					END AS TaskStatusCode
				--,1 AS Depth
			FROM Task.tbFlow child 
				JOIN Task.tbTask parent_task ON child.ParentTaskCode = parent_task.TaskCode
				JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
			WHERE parent_task.TaskCode = @ParentTaskCode	

			UNION ALL

			SELECT parent_task.TaskCode, child.ParentTaskCode, child.ChildTaskCode, 
				CASE WHEN child.UsedOnQuantity <> 0 THEN parent_task.Quantity * child.UsedOnQuantity ELSE child_task.Quantity END AS Quantity, 
				App.fnAdjustToCalendar(parent_task.ActionOn, SUM(child.OffsetDays) OVER (PARTITION BY child.ParentTaskCode ORDER BY child.StepNumber DESC)) AS ActionOn, 
				CASE WHEN parent_task.TaskStatusCode < 3 AND child_task.TaskStatusCode < parent_task.TaskStatusCode 
					THEN parent_task.TaskStatusCode 
					ELSE child_task.TaskStatusCode 
					END AS TaskStatusCode
				--,Depth + 1 AS Depth
			FROM Task.tbFlow child 
				JOIN task_flow parent_task ON child.ParentTaskCode = parent_task.ChildTaskCode
				JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
		), task_edits AS
		(
			SELECT task_flow.ChildTaskCode AS TaskCode, task_flow.TaskStatusCode, task_flow.Quantity, task_flow.ActionOn, 
				CASE WHEN task_flow.TaskStatusCode < 3 THEN
					App.fnAdjustToCalendar(CASE WHEN org.PayDaysFromMonthEnd <> 0 
											THEN 						
												DATEADD(d, org.PaymentDays, DATEADD(d, ((day(task_flow.ActionOn) - 1) + 1) * -1, DATEADD(m, 1, task_flow.ActionOn)))
											ELSE
												DATEADD(d, org.PaymentDays, task_flow.ActionOn)	
											END, 0) 
					ELSE task.PaymentOn END			
					AS PaymentOn
			FROM task_flow JOIN Task.tbTask task ON task_flow.ChildTaskCode = task.TaskCode
				JOIN Org.tbOrg org on task.AccountCode = org.AccountCode
		)
		UPDATE task
		SET 
			TaskStatusCode = task_edits.TaskStatusCode,
			Quantity = task_edits.Quantity,
			ActionOn = task_edits.ActionOn,
			PaymentOn = task_edits.PaymentOn,
			UpdatedBy = SUSER_SNAME(), 
			UpdatedOn = CURRENT_TIMESTAMP
		FROM Task.tbTask task JOIN task_edits ON task.TaskCode = task_edits.TaskCode;


		WITH ops_top_level AS
		(
			SELECT task.TaskCode, ops.OperationNumber, ops.OffsetDays, task.ActionOn, ops.StartOn, ops.EndOn, task.TaskStatusCode, ops.OpStatusCode, ops.OpTypeCode
			FROM Task.tbOp ops JOIN Task.tbTask task ON ops.TaskCode = task.TaskCode
			WHERE task.TaskCode = @ParentTaskCode
		), task_flow AS
		(
			SELECT parent_task.TaskCode, child.ParentTaskCode, child.ChildTaskCode, 
				child_task.ActionOn, child_task.TaskStatusCode
			FROM Task.tbFlow child 
				JOIN Task.tbTask parent_task ON child.ParentTaskCode = parent_task.TaskCode
				JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
			WHERE parent_task.TaskCode = @ParentTaskCode	

			UNION ALL

			SELECT parent_task.TaskCode, child.ParentTaskCode, child.ChildTaskCode, 
				child_task.ActionOn, child_task.TaskStatusCode
			FROM Task.tbFlow child 
				JOIN task_flow parent_task ON child.ParentTaskCode = parent_task.ChildTaskCode
				JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
		), ops_lower_level AS
		(
			SELECT ops.TaskCode, ops.OperationNumber, ops.OffsetDays, task_flow.ActionOn, ops.StartOn, ops.EndOn, task_flow.TaskStatusCode, ops.OpStatusCode, ops.OpTypeCode 
			FROM task_flow
				CROSS APPLY (SELECT op.* FROM Task.tbOp op where op.TaskCode = task_flow.ChildTaskCode) ops
		), ops_unsorted AS
		(
			SELECT * FROM ops_top_level
			UNION
			SELECT * FROM ops_lower_level
		), ops_candidates AS
		(
			SELECT *,
				ROW_NUMBER() OVER (PARTITION BY TaskCode ORDER BY TaskCode, OperationNumber DESC) AS LastOpRow,
				ROW_NUMBER() OVER (PARTITION BY TaskCode ORDER BY TaskCode, OperationNumber) AS FirstOpRow
			FROM ops_unsorted
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
				CASE OpTypeCode WHEN 1 THEN 0 ELSE OffsetDays END AS AsyncOffsetDays
			FROM ops_candidates
		)
		, ops_unscheduled2 AS
		(
			SELECT TaskCode, OperationNumber, OpStatusCode, LastOpRow,
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

			
		COMMIT TRANSACTION;


  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER PROCEDURE [Task].[proc_Copy]
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
			BEGIN
			COMMIT TRANSACTION
			EXEC Task.proc_Schedule @ToTaskCode
			END

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

CREATE OR ALTER PROCEDURE App.proc_SystemRebuild
AS
  	SET NOCOUNT, XACT_ABORT ON;

	DECLARE @tbPartialInvoice TABLE (
			AccountCode NVARCHAR(10), 
			InvoiceNumber NVARCHAR(10),
			RefType SMALLINT,
			RefCode NVARCHAR(20),
			TotalPaidValue MONEY
			);

	BEGIN TRY
		BEGIN TRANSACTION;

		UPDATE Task.tbFlow
		SET UsedOnQuantity = task.Quantity / parent_task.Quantity
		FROM            Task.tbFlow AS flow 
			JOIN Task.tbTask AS task ON flow.ChildTaskCode = task.TaskCode 
			JOIN Task.tbTask AS parent_task ON flow.ParentTaskCode = parent_task.TaskCode
			JOIN Cash.tbCode ON parent_task.CashCode = Cash.tbCode.CashCode
		WHERE        (flow.UsedOnQuantity <> 0) AND (task.Quantity <> 0) 
			AND (task.Quantity / parent_task.Quantity <> flow.UsedOnQuantity);

		WITH parent_task AS
		(
			SELECT        ParentTaskCode
			FROM            Task.tbFlow flow
				JOIN Task.tbTask task ON flow.ParentTaskCode = task.TaskCode
				JOIN Cash.tbCode cash ON task.CashCode = cash.CashCode
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

		--tTask.tbFlow Offset Days
		--UPDATE Task.tbFlow
		--SET OffsetDays = App.fnOffsetDays(child_task.ActionOn, parent_task.ActionOn)
		--				- ISNULL((SELECT SUM(OffsetDays) FROM Task.tbFlow sub_flow WHERE sub_flow.ParentTaskCode = flow.ParentTaskCode AND sub_flow.StepNumber > flow.StepNumber), 0)
		--FROM Task.tbFlow AS flow 
		--	JOIN Task.tbTask child_task ON flow.ChildTaskCode = child_task.TaskCode 
		--	JOIN Task.tbTask AS parent_task ON flow.ParentTaskCode = parent_task.TaskCode
		--	JOIN Cash.tbCode ON parent_task.CashCode = Cash.tbCode.CashCode;

		--tbOp Offset days

		UPDATE Org.tbPayment
		SET
			TaxInValue = PaidInValue - CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND((PaidInValue / (1 + TaxRate)), 2)
				WHEN 1 THEN ROUND((PaidInValue / (1 + TaxRate)), 2, 1) END, 
			TaxOutValue = PaidOutValue - CASE App.tbTaxCode.RoundingCode 
				WHEN 0 THEN ROUND((PaidOutValue / (1 + TaxRate)), 2)
				WHEN 1 THEN ROUND((PaidOutValue / (1 + TaxRate)), 2, 1) END
		FROM         Org.tbPayment INNER JOIN
								App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode;

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
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0);
                      
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
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0);
	
		UPDATE Invoice.tbInvoice
		SET InvoiceValue = 0, TaxValue = 0
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0);
	
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
								ON Invoice.tbInvoice.InvoiceNumber = items.InvoiceNumber;

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
		FROM         Invoice.tbInvoice INNER JOIN tasks ON Invoice.tbInvoice.InvoiceNumber = tasks.InvoiceNumber;

		UPDATE    Invoice.tbInvoice
		SET              PaidValue = InvoiceValue, PaidTaxValue = TaxValue, InvoiceStatusCode = 3;
	
		WITH paid_balance AS
		(
			SELECT  AccountCode, SUM(PaidInValue + (PaidOutValue * -1)) AS PaidBalance
			FROM         Org.tbPayment
			WHERE     (PaymentStatusCode <> 0)
			GROUP BY AccountCode
		), invoice_balance AS
		(
			SELECT AccountCode, SUM(CASE Invoice.tbType.CashModeCode WHEN 0 THEN (InvoiceValue + TaxValue) * - 1 WHEN 1 THEN InvoiceValue + TaxValue ELSE 0 END) AS InvoicedBalance
			FROM         Invoice.tbInvoice INNER JOIN
								  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
			GROUP BY AccountCode
		), account_balance AS
		(
			SELECT paid_balance.AccountCode, PaidBalance, InvoicedBalance, PaidBalance - InvoicedBalance AS CurrentBalance
			FROM paid_balance JOIN invoice_balance ON paid_balance.AccountCode = invoice_balance.AccountCode
		)
		UPDATE Org.tbOrg
		SET CurrentBalance = ROUND(OpeningBalance + account_balance.CurrentBalance, 2)
		FROM Org.tbOrg JOIN
			account_balance ON Org.tbOrg.AccountCode = account_balance.AccountCode;

		--unpaid invoices
		WITH closing_balance AS
		(
			SELECT AccountCode, 0 AS RowNumber,
				CurrentBalance,
					CASE WHEN CurrentBalance < 0 THEN 0 
						WHEN CurrentBalance > 0 THEN 1
						ELSE 2 END AS CashModeCode
			FROM Org.tbOrg
			WHERE ROUND(CurrentBalance, 0) <> 0 
		), invoice_entries AS
		(
			SELECT        Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceNumber, Invoice.tbTask.TaskCode AS RefCode, 1 AS RefType, 
				CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.InvoiceValue * -1 ELSE Invoice.tbTask.InvoiceValue END AS InvoiceValue, 
				CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbTask.TaxValue * -1 ELSE Invoice.tbTask.TaxValue END AS TaxValue, Invoice.tbType.CashModeCode
			FROM   closing_balance JOIN Invoice.tbInvoice ON closing_balance.AccountCode = Invoice.tbInvoice.AccountCode
				JOIN  Invoice.tbTask ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
				JOIN Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
			UNION
			SELECT        Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceNumber, CashCode AS RefCode, 2 AS RefType,
				CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.InvoiceValue * -1 ELSE Invoice.tbItem.InvoiceValue END AS InvoiceValue, 
				CASE WHEN Invoice.tbType.CashModeCode = 0 THEN Invoice.tbItem.TaxValue * -1 ELSE Invoice.tbItem.TaxValue END AS TaxValue, Invoice.tbType.CashModeCode
			FROM   closing_balance JOIN Invoice.tbInvoice ON closing_balance.AccountCode = Invoice.tbInvoice.AccountCode
				JOIN Invoice.tbItem ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
				JOIN Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
		), invoices AS
		(
			SELECT AccountCode, ROW_NUMBER() OVER (PARTITION BY AccountCode ORDER BY ExpectedOn DESC, CashModeCode DESC) AS RowNumber, 
				InvoiceNumber, RefCode, RefType, (InvoiceValue + TaxValue) AS ValueToPay
			FROM invoice_entries
		), invoices_and_cb AS
		( 
			SELECT AccountCode, RowNumber, '' AS InvoiceNumber, '' AS RefCode, 0 AS RefType, CurrentBalance AS ValueToPay
			FROM closing_balance
			UNION
			SELECT AccountCode, RowNumber, InvoiceNumber, RefCode, RefType, ValueToPay
			FROM invoices	
		), unbalanced_cashmode AS
		(
			SELECT invoices_and_cb.AccountCode, invoices_and_cb.RowNumber, invoices_and_cb.InvoiceNumber, invoices_and_cb.RefCode, 
				invoices_and_cb.RefType, invoices_and_cb.ValueToPay, closing_balance.CashModeCode
			FROM invoices_and_cb JOIN closing_balance ON invoices_and_cb.AccountCode = closing_balance.AccountCode
		), invoice_balances AS
		(
			SELECT AccountCode, RowNumber, InvoiceNumber, RefCode, RefType, ValueToPay, CashModeCode, 
				SUM(ValueToPay) OVER (PARTITION BY AccountCode ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
			FROM unbalanced_cashmode
		), selected_row AS
		(
			SELECT AccountCode, MIN(RowNumber) AS RowNumber
			FROM invoice_balances
			WHERE (CashModeCode = 0 AND Balance >= 0) OR (CashModeCode = 1 AND Balance <= 0)
			GROUP BY AccountCode
		), result_set AS
		(
			SELECT invoice_unpaid.AccountCode, invoice_unpaid.InvoiceNumber, invoice_unpaid.RefType, invoice_unpaid.RefCode, 
				CASE WHEN CashModeCode = 0 THEN
						CASE WHEN Balance < 0 THEN 0 ELSE Balance END
					WHEN CashModeCode = 1 THEN
						CASE WHEN Balance > 0 THEN 0 ELSE ABS(Balance) END
					END AS TotalPaidValue
			FROM selected_row
				CROSS APPLY (SELECT invoice_balances.*
							FROM invoice_balances
							WHERE invoice_balances.AccountCode = selected_row.AccountCode
								AND invoice_balances.RowNumber <= selected_row.RowNumber
								AND invoice_balances.RefType > 0) AS invoice_unpaid
		)
		INSERT INTO @tbPartialInvoice
			(AccountCode, InvoiceNumber, RefType, RefCode, TotalPaidValue)
		SELECT AccountCode, InvoiceNumber, RefType, RefCode, TotalPaidValue
		FROM result_set;

		UPDATE task
		SET PaidValue = 0, PaidTaxValue = 0
		FROM @tbPartialInvoice unpaid_task
			JOIN Invoice.tbTask task ON unpaid_task.InvoiceNumber = task.InvoiceNumber
				AND unpaid_task.RefCode = task.TaskCode	
		WHERE unpaid_task.RefType = 1 AND unpaid_task.TotalPaidValue = 0;

		UPDATE task
		SET 
			PaidTaxValue = CASE RoundingCode 
								WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2)
								WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2, 1)
							END,
			PaidValue = TotalPaidValue -
							CASE RoundingCode 
								WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2)
								WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2, 1)
							END
		FROM @tbPartialInvoice unpaid_task
			JOIN Invoice.tbTask task ON unpaid_task.InvoiceNumber = task.InvoiceNumber
				AND unpaid_task.RefCode = task.TaskCode	
			JOIN App.tbTaxCode tax ON tax.TaxCode = task.TaxCode
		WHERE unpaid_task.RefType = 1 AND unpaid_task.TotalPaidValue <> 0;

		UPDATE item
		SET PaidValue = 0, PaidTaxValue = 0
		FROM @tbPartialInvoice unpaid_task
			JOIN Invoice.tbItem item ON unpaid_task.InvoiceNumber = item.InvoiceNumber
				AND unpaid_task.RefCode = item.CashCode
		WHERE unpaid_task.RefType = 1 AND unpaid_task.TotalPaidValue = 0;

		UPDATE item
		SET 
			PaidTaxValue = CASE RoundingCode 
								WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2)
								WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2, 1)
							END,
			PaidValue = TotalPaidValue -
							CASE RoundingCode 
								WHEN 0 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2)
								WHEN 1 THEN ROUND((TotalPaidValue - (TotalPaidValue / (1 + TaxRate))), 2, 1)
							END
		FROM @tbPartialInvoice unpaid_item
			JOIN Invoice.tbItem item ON unpaid_item.InvoiceNumber = item.InvoiceNumber
				AND unpaid_item.RefCode = item.CashCode	
			JOIN App.tbTaxCode tax ON tax.TaxCode = item.TaxCode
		WHERE unpaid_item.RefType = 1 AND unpaid_item.TotalPaidValue <> 0;

		WITH invoices AS
		(
			SELECT        task.InvoiceNumber, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
			FROM       @tbPartialInvoice unpaid_task
			JOIN Invoice.tbTask task ON unpaid_task.InvoiceNumber = task.InvoiceNumber
				AND unpaid_task.RefCode = task.TaskCode	
			UNION
			SELECT        item.InvoiceNumber, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
			FROM @tbPartialInvoice unpaid_item
				JOIN Invoice.tbItem item ON unpaid_item.InvoiceNumber = item.InvoiceNumber
					AND unpaid_item.RefCode = item.CashCode
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
							selected ON Invoice.tbInvoice.InvoiceNumber = selected.InvoiceNumber;

		--cash accounts
		UPDATE Org.tbAccount
		SET CurrentBalance = Cash.vwAccountRebuild.CurrentBalance
		FROM         Cash.vwAccountRebuild INNER JOIN
							Org.tbAccount ON Cash.vwAccountRebuild.CashAccountCode = Org.tbAccount.CashAccountCode;
	
		UPDATE Org.tbAccount
		SET CurrentBalance = 0
		FROM         Cash.vwAccountRebuild RIGHT OUTER JOIN
							  Org.tbAccount ON Cash.vwAccountRebuild.CashAccountCode = Org.tbAccount.CashAccountCode
		WHERE     (Cash.vwAccountRebuild.CashAccountCode IS NULL);

		COMMIT TRANSACTION

		--log successful rebuild
		DECLARE @Msg NVARCHAR(MAX);
		SELECT @Msg = [Message] FROM App.tbText WHERE TextId = 3006;
		EXEC App.proc_EventLog @EventMessage = @Msg, @EventTypeCode = 2;

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go

DROP PROCEDURE IF EXISTS Task.proc_ScheduleOp;
DROP PROCEDURE IF EXISTS Task.proc_SetStatus;
DROP PROCEDURE IF EXISTS Task.proc_SetOpStatus;
DROP PROCEDURE IF EXISTS Task.proc_SetActionOn;
go

--Adjust offset days in Task.tbOp UPDATE trigger
--Adjust offset days in Task.tbFlow tbTask UPDATE trigger

--ALTER TABLE App.tbOptions 
--	DROP CONSTRAINT [DF_App_tbOptions_ScheduleOps],
--	COLUMN ScheduleOps
--go 

--App.proc_SystemRebuild: include UOQ and OffsetDays