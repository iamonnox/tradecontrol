DROP PROCEDURE IF EXISTS Task.proc_ProfitTopLevel;
DROP PROCEDURE IF EXISTS Task.proc_Profit;
go
ALTER PROCEDURE [Task].[proc_Cost] 
	(
	@ParentTaskCode nvarchar(20),
	@TotalCost money = 0 output
	)

AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		WITH task_flow AS
		(
			SELECT parent_task.TaskCode, child.ParentTaskCode, child.ChildTaskCode, 
				CASE WHEN child.UsedOnQuantity <> 0 THEN parent_task.Quantity * child.UsedOnQuantity ELSE child_task.Quantity END AS Quantity, 
				1 AS Depth,
				CASE category.CashModeCode WHEN 0 THEN child_task.UnitCharge * -1 ELSE child_task.UnitCharge END AS UnitCharge
			FROM Task.tbFlow child 
				JOIN Task.tbTask parent_task ON child.ParentTaskCode = parent_task.TaskCode
				JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
				JOIN Cash.tbCode cashcode ON cashcode.CashCode = child_task.CashCode 
				JOIN Cash.tbCategory category ON category.CategoryCode = cashcode.CategoryCode
			WHERE parent_task.TaskCode = @ParentTaskCode

			UNION ALL

			SELECT parent.TaskCode, child.ParentTaskCode, child.ChildTaskCode, 
				CASE WHEN child.UsedOnQuantity <> 0 THEN parent.Quantity * child.UsedOnQuantity ELSE child_task.Quantity END AS Quantity, 
				parent.Depth + 1 AS Depth,
				CASE category.CashModeCode WHEN 0 THEN child_task.UnitCharge * -1 ELSE child_task.UnitCharge END AS UnitCharge
			FROM Task.tbFlow child 
				JOIN task_flow parent ON child.ParentTaskCode = parent.ChildTaskCode
				JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
				JOIN Cash.tbCode cashcode ON cashcode.CashCode = child_task.CashCode 
				JOIN Cash.tbCategory category ON category.CategoryCode = cashcode.CategoryCode
		), results AS
		(
			SELECT TaskCode, SUM(Quantity * UnitCharge) AS TotalCost
			FROM task_flow
			GROUP BY TaskCode
		)
		SELECT @TotalCost = TotalCost
		FROM results;
		
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go


WITH uoq AS
(
	SELECT        Task.tbFlow.ParentTaskCode, Task.tbFlow.ChildTaskCode, child_task.Quantity, parent_task.Quantity * Task.tbFlow.UsedOnQuantity AS CalcQuantity,
		Task.tbFlow.UsedOnQuantity, CASE WHEN parent_task.Quantity = 0 THEN 0 ELSE child_task.Quantity /  parent_task.Quantity END AS CalcUOQ
	FROM            Task.tbTask AS child_task INNER JOIN
							 Task.tbFlow ON child_task.TaskCode = Task.tbFlow.ChildTaskCode INNER JOIN
							 Task.tbTask AS parent_task ON Task.tbFlow.ParentTaskCode = parent_task.TaskCode
), flow AS
(
	SELECT Task.tbFlow.ParentTaskCode, Task.tbFlow.ChildTaskCode FROM Task.tbFlow JOIN uoq ON Task.tbFlow.ParentTaskCode = uoq.ParentTaskCode AND Task.tbFlow.ChildTaskCode = uoq.ChildTaskCode
	WHERE uoq.UsedOnQuantity <> uoq.CalcUOQ
)
UPDATE Task.tbFlow
SET UsedOnQuantity = 0
FROM Task.tbFlow JOIN flow ON Task.tbFlow.ParentTaskCode = flow.ParentTaskCode AND Task.tbFlow.ChildTaskCode = flow.ChildTaskCode;
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
			WHERE EXISTS (SELECT     *
						FROM         inserted AS i
						WHERE     (NOT (ContactName IS NULL)) AND
												(ContactName <> N''))
				AND NOT EXISTS(SELECT  *
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

		IF UPDATE (Quantity)
			BEGIN
			WITH uoq AS
			(
				SELECT        flow.ParentTaskCode, flow.ChildTaskCode, flow.UsedOnQuantity, 
					CASE WHEN parent_task.Quantity = 0 THEN 0 ELSE child_task.Quantity / parent_task.Quantity END AS CalcUOQ
				FROM            inserted AS child_task INNER JOIN
										 Task.tbFlow AS flow ON child_task.TaskCode = flow.ChildTaskCode INNER JOIN
										 Task.tbTask AS parent_task ON flow.ParentTaskCode = parent_task.TaskCode
			)
			UPDATE Task.tbFlow
			SET UsedOnQuantity = uoq.CalcUOQ
			FROM Task.tbFlow JOIN uoq 
			ON Task.tbFlow.ParentTaskCode = uoq.ParentTaskCode AND Task.tbFlow.ChildTaskCode = uoq.ChildTaskCode
			WHERE uoq.CalcUOQ <> uoq.UsedOnQuantity AND uoq.UsedOnQuantity <> 0;
			END

		UPDATE Task.tbTask
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Task.tbTask INNER JOIN inserted AS i ON tbTask.TaskCode = i.TaskCode;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go


