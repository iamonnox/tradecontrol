UPDATE App.tbOptions SET SQLDataVersion = 3.19;
go
--*************************************************************

CREATE TABLE Activity.tbFlowType(
	FlowTypeCode smallint NOT NULL,
	FlowType nvarchar(50) NOT NULL,
 CONSTRAINT PK_Activity_tbFlowType PRIMARY KEY CLUSTERED 
(
	FlowTypeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
go
INSERT INTO Activity.tbFlowType (FlowTypeCode, FlowType)
VALUES (0, 'SYNC'), (1, 'ASYNC'), (2, 'CALL-OFF');
go
ALTER TABLE Activity.tbFlow WITH NOCHECK ADD
	FlowTypeCode smallint NOT NULL CONSTRAINT DF_Activity_tbFlow_FlowTypeCode DEFAULT (0);
go
ALTER TABLE Activity.tbFlow  WITH CHECK ADD  CONSTRAINT FK_Activity_tbFlow_Activity_tbFlowType FOREIGN KEY(FlowTypeCode)
REFERENCES Activity.tbFlowType (FlowTypeCode)
go
ALTER TABLE Activity.tbFlow CHECK CONSTRAINT FK_Activity_tbFlow_Activity_tbFlowType
go

ALTER TABLE Task.tbFlow WITH NOCHECK ADD
	FlowTypeCode smallint NOT NULL CONSTRAINT DF_Task_tbFlow_FlowTypeCode DEFAULT (0);
go
ALTER TABLE Task.tbFlow  WITH CHECK ADD  CONSTRAINT FK_Task_tbFlow_Activity_tbFlowType FOREIGN KEY(FlowTypeCode)
REFERENCES Activity.tbFlowType (FlowTypeCode)
go
ALTER TABLE Task.tbFlow CHECK CONSTRAINT FK_Task_tbFlow_Activity_tbFlowType
go
--********************************************************************
ALTER VIEW [App].[vwPeriods]
AS
	SELECT        TOP (100) PERCENT App.tbYear.YearNumber, App.tbYearPeriod.StartOn, App.tbYear.Description + SPACE(1) + App.tbMonth.MonthName AS Description, App.tbYearPeriod.RowVer
	FROM            App.tbYearPeriod INNER JOIN
							 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
							 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
	WHERE        (App.tbYear.CashStatusCode < 3) AND (App.tbYearPeriod.CashStatusCode < 3)
go
CREATE OR ALTER VIEW [Cash].[vwFlowVatPeriodAccruals]
AS
	WITH active_periods AS
	(
		SELECT App.tbYear.YearNumber, App.tbYearPeriod.StartOn
		FROM            App.tbYearPeriod INNER JOIN
								 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
								 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE        (App.tbYear.CashStatusCode < 3)
	),	 vat_accruals AS
	(
		SELECT   active_periods.YearNumber, active_periods.StartOn, ISNULL(SUM(vat_audit.HomeSales), 0) AS HomeSales, ISNULL(SUM(vat_audit.HomePurchases), 0) AS HomePurchases, ISNULL(SUM(vat_audit.ExportSales), 0) AS ExportSales, ISNULL(SUM(vat_audit.ExportPurchases), 0) 
								 AS ExportPurchases, ISNULL(SUM(vat_audit.HomeSalesVat), 0) AS HomeSalesVat, ISNULL(SUM(vat_audit.HomePurchasesVat), 0) AS HomePurchasesVat, ISNULL(SUM(vat_audit.ExportSalesVat), 0) AS ExportSalesVat, 
								 ISNULL(SUM(vat_audit.ExportPurchasesVat), 0) AS ExportPurchasesVat
		FROM            Cash.vwTaxVatAuditAccruals AS vat_audit RIGHT OUTER JOIN
								 active_periods ON active_periods.StartOn = vat_audit.StartOn
		GROUP BY active_periods.YearNumber, active_periods.StartOn
	)
	SELECT YearNumber, StartOn, HomeSales, HomePurchases, ExportSales, ExportPurchases, HomeSalesVat, HomePurchasesVat, ExportSalesVat, ExportPurchasesVat,
		 (HomeSalesVat + ExportSalesVat) - (HomePurchasesVat + ExportPurchasesVat) AS VatDue
	FROM vat_accruals;
go
CREATE OR ALTER VIEW [Cash].[vwFlowVatRecurrenceAccruals]
AS	
	WITH active_periods AS
	(
		SELECT App.tbYear.YearNumber, App.tbYearPeriod.StartOn
		FROM            App.tbYearPeriod INNER JOIN
								 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
								 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE        (App.tbYear.CashStatusCode < 3)
	),	vat_dates AS
	(
		SELECT PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(1)
	), vatPeriod AS
	(
		SELECT        StartOn, y.YearNumber, p.MonthNumber,
			(SELECT PayTo FROM vat_dates WHERE p.StartOn >= PayFrom AND p.StartOn < PayTo) AS VatStartOn, VatAdjustment
		FROM            App.tbYearPeriod AS p JOIN App.tbYear AS y ON p.YearNumber = y.YearNumber 
	)
	, vat_accruals AS
	(
		SELECT  vatPeriod.VatStartOn AS StartOn,
				SUM(HomeSales) AS HomeSales, SUM(HomePurchases) AS HomePurchases, SUM(ExportSales) AS ExportSales, SUM(ExportPurchases) AS ExportPurchases, 
				SUM(HomeSalesVat) AS HomeSalesVat, SUM(HomePurchasesVat) AS HomePurchasesVat, 
				SUM(ExportSalesVat) AS ExportSalesVat, SUM(ExportPurchasesVat) AS ExportPurchasesVat, SUM(VatDue) AS VatDue
		FROM Cash.vwFlowVatPeriodAccruals accruals JOIN vatPeriod ON accruals.StartOn = vatPeriod.StartOn
		GROUP BY vatPeriod.VatStartOn
	)
	SELECT active_periods.YearNumber, active_periods.StartOn, ISNULL(HomeSales, 0) AS HomeSales, ISNULL(HomePurchases, 0) AS HomePurchases, ISNULL(ExportSales, 0) AS ExportSales, ISNULL(ExportPurchases, 0) AS ExportPurchases, ISNULL(HomeSalesVat, 0) AS HomeSalesVat, ISNULL(HomePurchasesVat, 0) AS HomePurchasesVat, ISNULL(ExportSalesVat, 0) AS ExportSalesVat, ISNULL(ExportPurchasesVat, 0) AS ExportPurchasesVat, ISNULL(VatDue, 0) AS VatDue 
	FROM vat_accruals 
		RIGHT OUTER JOIN active_periods ON active_periods.StartOn = vat_accruals.StartOn;		
go
CREATE OR ALTER VIEW [Cash].[vwFlowVatPeriodTotals]
AS
	WITH active_periods AS
	(
		SELECT App.tbYear.YearNumber, App.tbYearPeriod.StartOn
		FROM            App.tbYearPeriod INNER JOIN
								 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
								 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE        (App.tbYear.CashStatusCode < 3)
	)
	SELECT     active_periods.YearNumber, active_periods.StartOn, ISNULL(SUM(vat.HomeSales), 0) AS HomeSales, ISNULL(SUM(vat.HomePurchases), 0) AS HomePurchases, ISNULL(SUM(vat.ExportSales), 0) AS ExportSales, ISNULL(SUM(vat.ExportPurchases), 0) AS ExportPurchases, 
							 ISNULL(SUM(vat.HomeSalesVat), 0) AS HomeSalesVat, ISNULL(SUM(vat.HomePurchasesVat), 0) AS HomePurchasesVat, ISNULL(SUM(vat.ExportSalesVat), 0) AS ExportSalesVat, ISNULL(SUM(vat.ExportPurchasesVat), 0) AS ExportPurchasesVat, 
							 ISNULL(SUM(vat.VatDue), 0) AS VatDue
	FROM            active_periods LEFT OUTER JOIN
							 Cash.vwTaxVatSummary AS vat ON active_periods.StartOn = vat.StartOn
	GROUP BY active_periods.YearNumber, active_periods.StartOn;
go
CREATE OR ALTER VIEW [Cash].[vwFlowVatRecurrence]
AS
		WITH active_periods AS
	(
		SELECT App.tbYear.YearNumber, App.tbYearPeriod.StartOn
		FROM            App.tbYearPeriod INNER JOIN
								 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
								 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber
		WHERE        (App.tbYear.CashStatusCode < 3)
	)
	SELECT        active_periods.YearNumber, active_periods.StartOn, ISNULL(SUM(vat.HomeSales), 0) AS HomeSales, ISNULL(SUM(vat.HomePurchases), 0) AS HomePurchases, ISNULL(SUM(vat.ExportSales), 0) AS ExportSales, ISNULL(SUM(vat.ExportPurchases), 0) AS ExportPurchases, 
							 ISNULL(SUM(vat.HomeSalesVat), 0) AS HomeSalesVat, ISNULL(SUM(vat.HomePurchasesVat), 0) AS HomePurchasesVat, ISNULL(SUM(vat.ExportSalesVat), 0) AS ExportSalesVat, ISNULL(SUM(vat.ExportPurchasesVat), 0) AS ExportPurchasesVat, 
							 ISNULL(SUM(vat.VatAdjustment), 0) AS VatAdjustment, ISNULL(SUM(vat.VatDue), 0) AS VatDue
	FROM            active_periods LEFT OUTER JOIN
							 Cash.vwTaxVatTotals AS vat ON active_periods.StartOn = vat.StartOn
	GROUP BY active_periods.YearNumber, active_periods.StartOn;
go

ALTER PROCEDURE [Org].[proc_AddAddress] 
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
	
		IF NOT EXISTS (SELECT * FROM Org.tbOrg org JOIN Org.tbAddress org_addr ON org.AddressCode = org_addr.AddressCode WHERE org.AccountCode = @AccountCode)
		BEGIN
			UPDATE Org.tbOrg
			SET AddressCode = @AddressCode
			WHERE Org.tbOrg.AccountCode = @AccountCode
		END

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER TABLE App.tbOptions 
	DROP COLUMN NetProfitTaxCode
go
ALTER PROCEDURE [Activity].[proc_Parent]
	(
	@ActivityCode nvarchar(50),
	@ParentCode nvarchar(50) = null output
	)
AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SET @ParentCode = @ActivityCode;
		
		IF EXISTS(SELECT ParentCode FROM Activity.tbFlow WHERE (ParentCode = @ActivityCode))
			OR NOT EXISTS(SELECT COUNT(*) FROM Activity.tbFlow WHERE ChildCode = @ActivityCode GROUP BY ChildCode HAVING COUNT(*) > 1)
		BEGIN		
			WHILE EXISTS (SELECT COUNT(*) FROM Activity.tbFlow WHERE ChildCode = @ParentCode GROUP BY ChildCode HAVING COUNT(*) = 1)
				SELECT @ParentCode = ParentCode, @ActivityCode = ParentCode 
				FROM Activity.tbFlow		
				WHERE ChildCode = @ActivityCode;	 
		END
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER PROCEDURE [Activity].[proc_Mode]
	(
	@ActivityCode nvarchar(50)
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SELECT     Activity.tbActivity.ActivityCode, Activity.tbActivity.UnitOfMeasure, Task.tbStatus.TaskStatus, ISNULL(Cash.tbCategory.CashModeCode, 2) AS CashModeCode
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
CREATE OR ALTER PROCEDURE [Activity].[proc_WorkFlow]
	(
	@ParentActivityCode nvarchar(50),
	@ActivityCode nvarchar(50)
	)
AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		IF EXISTS(SELECT * FROM Activity.tbFlow WHERE (ParentCode = @ParentActivityCode))
			AND NOT EXISTS(SELECT COUNT(*) FROM Activity.tbFlow WHERE ChildCode = @ParentActivityCode GROUP BY ChildCode HAVING COUNT(*) > 1)			
		BEGIN
			SELECT     Activity.tbActivity.ActivityCode, Task.tbStatus.TaskStatus, ISNULL(Cash.tbCategory.CashModeCode, 2) AS CashModeCode, Activity.tbActivity.UnitOfMeasure, Activity.tbFlow.OffsetDays, Activity.tbFlow.UsedOnQuantity
			FROM         Activity.tbActivity INNER JOIN
								  Task.tbStatus ON Activity.tbActivity.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
								  Activity.tbFlow ON Activity.tbActivity.ActivityCode = Activity.tbFlow.ChildCode LEFT OUTER JOIN
								  Cash.tbCode ON Activity.tbActivity.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
								  Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			WHERE     ( Activity.tbFlow.ParentCode = @ActivityCode)
			ORDER BY Activity.tbFlow.StepNumber	
		END
		ELSE
		BEGIN
			SELECT     Activity.tbActivity.ActivityCode, Task.tbStatus.TaskStatus, ISNULL(Cash.tbCategory.CashModeCode, 2) AS CashModeCode, Activity.tbActivity.UnitOfMeasure, Activity.tbFlow.OffsetDays, Activity.tbFlow.UsedOnQuantity
			FROM         Activity.tbActivity INNER JOIN
								  Task.tbStatus ON Activity.tbActivity.TaskStatusCode = Task.tbStatus.TaskStatusCode INNER JOIN
								  Activity.tbFlow ON Activity.tbActivity.ActivityCode = Activity.tbFlow.ParentCode LEFT OUTER JOIN
								  Cash.tbCode ON Activity.tbActivity.CashCode = Cash.tbCode.CashCode LEFT OUTER JOIN
								  Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			WHERE     ( Activity.tbFlow.ChildCode = @ActivityCode)
			ORDER BY Activity.tbFlow.StepNumber	
		END
			 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE [Activity].[proc_WorkFlowMultiLevel]
	(
	@ActivityCode nvarchar(50)
	)
AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		IF EXISTS(SELECT * FROM Activity.tbFlow WHERE (ParentCode = @ActivityCode))
		BEGIN
			WITH workflow AS
			(
				SELECT  parent_flow.ParentCode, parent_flow.ChildCode, parent_flow.OffsetDays, parent_flow.UsedOnQuantity, 1 AS Depth
				FROM Activity.tbFlow parent_flow
				WHERE (parent_flow.ParentCode = @ActivityCode)

				UNION ALL

				SELECT  child_flow.ParentCode, child_flow.ChildCode, child_flow.OffsetDays, child_flow.UsedOnQuantity, workflow.Depth + 1 AS Depth
				FROM workflow 
					JOIN Activity.tbFlow child_flow ON workflow.ChildCode = child_flow.ParentCode
			)
			SELECT workflow.ParentCode, workflow.ChildCode,
						task_status.TaskStatus, ISNULL(cash_category.CashModeCode, 2) AS CashModeCode,
						activity.UnitOfMeasure, workflow.OffsetDays, workflow.UsedOnQuantity, Depth
			FROM workflow
					JOIN Activity.tbActivity activity ON workflow.ChildCode = activity.ActivityCode
					JOIN Task.tbStatus task_status ON activity.TaskStatusCode = task_status.TaskStatusCode 
					LEFT OUTER JOIN Cash.tbCode cash_code ON activity.CashCode = cash_code.CashCode 
					LEFT OUTER JOIN Cash.tbCategory cash_category ON cash_code.CategoryCode = cash_category.CategoryCode
			ORDER BY Depth, ParentCode, ChildCode;
		END
		ELSE
		BEGIN
			WITH workflow AS
			(
				SELECT  child_flow.ParentCode, child_flow.ChildCode, child_flow.OffsetDays, child_flow.UsedOnQuantity, -1 AS Depth
				FROM Activity.tbFlow child_flow
				WHERE (child_flow.ChildCode = @ActivityCode)

				UNION ALL

				SELECT  parent_flow.ParentCode, parent_flow.ChildCode, parent_flow.OffsetDays, parent_flow.UsedOnQuantity, workflow.Depth - 1 AS Depth
				FROM workflow 
					JOIN Activity.tbFlow parent_flow ON workflow.ParentCode = parent_flow.ChildCode
			)
			SELECT workflow.ChildCode AS ParentCode, workflow.ParentCode AS ChildCode, 
						task_status.TaskStatus, ISNULL(cash_category.CashModeCode, 2) AS CashModeCode,
						activity.UnitOfMeasure, workflow.OffsetDays, workflow.UsedOnQuantity, Depth
			FROM workflow
					JOIN Activity.tbActivity activity ON workflow.ParentCode = activity.ActivityCode
					JOIN Task.tbStatus task_status ON activity.TaskStatusCode = task_status.TaskStatusCode 
					LEFT OUTER JOIN Cash.tbCode cash_code ON activity.CashCode = cash_code.CashCode 
					LEFT OUTER JOIN Cash.tbCategory cash_category ON cash_code.CategoryCode = cash_category.CategoryCode
			ORDER BY Depth DESC, ParentCode, ChildCode;		
		END
			 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER PROCEDURE [Task].[proc_Cost] 
	(
	@ParentTaskCode nvarchar(20),
	@TotalCost money = 0 OUTPUT
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		WITH task_flow AS
		(
			SELECT parent_task.TaskCode, child.ParentTaskCode, child.ChildTaskCode, 
				CASE WHEN child.UsedOnQuantity <> 0 THEN parent_task.Quantity * child.UsedOnQuantity ELSE child_task.Quantity END AS Quantity, 
				1 AS Depth				
			FROM Task.tbFlow child 
				JOIN Task.tbTask parent_task ON child.ParentTaskCode = parent_task.TaskCode
				JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
			WHERE parent_task.TaskCode = @ParentTaskCode

			UNION ALL

			SELECT parent.TaskCode, child.ParentTaskCode, child.ChildTaskCode, 
				CASE WHEN child.UsedOnQuantity <> 0 THEN parent.Quantity * child.UsedOnQuantity ELSE child_task.Quantity END AS Quantity, 
				parent.Depth + 1 AS Depth
			FROM Task.tbFlow child 
				JOIN task_flow parent ON child.ParentTaskCode = parent.ChildTaskCode
				JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
		)
		, tasks AS
		(
			SELECT task_flow.TaskCode, task.Quantity,
				CASE category.CashModeCode 
					WHEN NULL THEN 0 
					WHEN 0 THEN task.UnitCharge * -1 
					ELSE task.UnitCharge 
				END AS UnitCharge
			FROM task_flow
				JOIN Task.tbTask task ON task_flow.ChildTaskCode = task.TaskCode
				LEFT OUTER JOIN Cash.tbCode cashcode ON cashcode.CashCode = task.CashCode 
				LEFT OUTER JOIN Cash.tbCategory category ON category.CategoryCode = cashcode.CategoryCode
		), task_costs AS
		(
			SELECT TaskCode, SUM(Quantity * UnitCharge) AS TotalCost
			FROM tasks
			GROUP BY TaskCode
		)
		SELECT @TotalCost = TotalCost
		FROM task_costs;		

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
			SELECT task.TaskCode, ops.OperationNumber, ops.OffsetDays, task.ActionOn, ops.StartOn, ops.EndOn, task.TaskStatusCode, ops.OpStatusCode, ops.OpTypeCode
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
				CASE OpTypeCode WHEN 1 THEN 0 ELSE OffsetDays END AS AsyncOffsetDays
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
				CASE FlowTypeCode WHEN 2 THEN parent_task.ActionOn ELSE parent_task.EndOn END AS EndOn, 
				parent_task.ActionOn,
				CASE FlowTypeCode WHEN 0 THEN 0 ELSE OffsetDays END  AS OffsetDays,
				CASE FlowTypeCode WHEN 1 THEN 0 ELSE OffsetDays END AS AsyncOffsetDays,
				FlowTypeCode
			FROM parent_task 
				JOIN Task.tbFlow work_flow ON parent_task.TaskCode = work_flow.ParentTaskCode
				JOIN Task.tbTask child_task ON work_flow.ChildTaskCode = child_task.TaskCode
				
		), calloff_tasks_lag AS
		(
			SELECT ParentTaskCode, ChildTaskCode, StepNumber, Quantity, TaskStatusCode, ActionOn EndOn, OffsetDays, 
					LAG(AsyncOffsetDays, 1, 0) OVER (PARTITION BY ParentTaskCode ORDER BY StepNumber DESC) AS AsyncOffsetDays, 2FlowTypeCode	 
			FROM task_flow
			WHERE EXISTS(SELECT * FROM task_flow WHERE FlowTypeCode = 2)
				AND (StepNumber > (SELECT TOP 1 StepNumber FROM task_flow WHERE FlowTypeCode = 0 ORDER BY StepNumber DESC)
					OR NOT EXISTS (SELECT * FROM task_flow WHERE FlowTypeCode = 0))
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
				OR NOT EXISTS (SELECT * FROM task_flow WHERE FlowTypeCode = 2)
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
ALTER VIEW [Task].[vwProfit] 
AS
	WITH orders AS
	(
		SELECT        task.TaskCode, task.Quantity, task.UnitCharge,
									 (SELECT        TOP (1) StartOn
									   FROM            App.tbYearPeriod AS p
									   WHERE        (StartOn <= task.ActionOn)
									   ORDER BY StartOn DESC) AS StartOn
		FROM            Task.tbFlow RIGHT OUTER JOIN
								 Task.tbTask ON Task.tbFlow.ParentTaskCode = Task.tbTask.TaskCode AND Task.tbFlow.ParentTaskCode = Task.tbTask.TaskCode AND Task.tbFlow.ParentTaskCode = Task.tbTask.TaskCode RIGHT OUTER JOIN
								 Task.tbTask AS task INNER JOIN
								 Cash.tbCode AS cashcode ON task.CashCode = cashcode.CashCode INNER JOIN
								 Cash.tbCategory AS category ON category.CategoryCode = cashcode.CategoryCode ON Task.tbFlow.ChildTaskCode = task.TaskCode AND Task.tbFlow.ChildTaskCode = task.TaskCode
		WHERE        (category.CashModeCode = 1) AND (task.TaskStatusCode BETWEEN 1 AND 3) AND 
			(task.ActionOn >= (SELECT        MIN(StartOn)
											FROM            App.tbYearPeriod p JOIN
																	  App.tbYear y ON p.YearNumber = y.YearNumber
											WHERE        y.CashStatusCode < 3)) AND	
			((Task.tbFlow.ParentTaskCode IS NULL) OR (Task.tbTask.CashCode IS NULL))

	), invoices AS
	(
		SELECT tasks.TaskCode, ISNULL(invoice.InvoiceValue, 0) AS InvoiceValue, ISNULL(invoice.InvoicePaid, 0) AS InvoicePaid 
		FROM Task.tbTask tasks LEFT OUTER JOIN 
			(
				SELECT Invoice.tbTask.TaskCode, 
					 SUM(CASE CashModeCode WHEN 0 THEN Invoice.tbTask.InvoiceValue * -1 ELSE Invoice.tbTask.InvoiceValue END) AS InvoiceValue, 
					 SUM(CASE CashModeCode WHEN 0 THEN Invoice.tbTask.PaidValue * -1 ELSE Invoice.tbTask.PaidValue END) AS InvoicePaid
				FROM Invoice.tbTask 
					INNER JOIN Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
					INNER JOIN Invoice.tbType ON Invoice.tbType.InvoiceTypeCode = Invoice.tbInvoice.InvoiceTypeCode 
				GROUP BY Invoice.tbTask.TaskCode
			) invoice 
		ON tasks.TaskCode = invoice.TaskCode
	), task_flow AS
	(
		SELECT orders.TaskCode, child.ParentTaskCode, child.ChildTaskCode, 
			CASE WHEN child.UsedOnQuantity <> 0 THEN orders.Quantity * child.UsedOnQuantity ELSE task.Quantity END AS Quantity
			--, 1 AS Depth
		FROM Task.tbFlow child 
			JOIN orders ON child.ParentTaskCode = orders.TaskCode
			JOIN Task.tbTask task ON child.ChildTaskCode = task.TaskCode

		UNION ALL

		SELECT parent.TaskCode, child.ParentTaskCode, child.ChildTaskCode, 
			CASE WHEN child.UsedOnQuantity <> 0 THEN parent.Quantity * child.UsedOnQuantity ELSE task.Quantity END AS Quantity
			--, parent.Depth + 1 AS Depth
		FROM Task.tbFlow child 
			JOIN task_flow parent ON child.ParentTaskCode = parent.ChildTaskCode
			JOIN Task.tbTask task ON child.ChildTaskCode = task.TaskCode

	), tasks AS
	(
		SELECT task_flow.TaskCode, task.Quantity,
				CASE category.CashModeCode 
					WHEN NULL THEN 0 
					WHEN 0 THEN task.UnitCharge * -1 
					ELSE task.UnitCharge 
				END AS UnitCharge,
				invoices.InvoiceValue, invoices.InvoicePaid
		FROM task_flow
			JOIN Task.tbTask task ON task_flow.ChildTaskCode = task.TaskCode
			JOIN invoices ON invoices.TaskCode = task.TaskCode
			LEFT OUTER JOIN Cash.tbCode cashcode ON cashcode.CashCode = task.CashCode 
			LEFT OUTER JOIN Cash.tbCategory category ON category.CategoryCode = cashcode.CategoryCode
	)
	, task_costs AS
	(
		SELECT TaskCode, ROUND(SUM(Quantity * UnitCharge), 2) AS TotalCost, 
				ROUND(SUM(InvoiceValue), 2) AS InvoicedCost, ROUND(SUM(InvoicePaid), 2) AS InvoicedCostPaid
		FROM tasks
		GROUP BY TaskCode
		UNION
		SELECT TaskCode, 0 AS TotalCost, 0 AS InvoicedCost, 0 AS InvoicedCostPaid
		FROM orders LEFT OUTER JOIN Task.tbFlow AS flow ON orders.TaskCode = flow.ParentTaskCode
		WHERE (flow.ParentTaskCode IS NULL)
	)
	SELECT orders.StartOn, task.AccountCode, orders.TaskCode, 
		yearperiod.YearNumber, yr.[Description], 
		CONCAT(mn.[MonthName], ' ', YEAR(yearperiod.StartOn)) AS [Period],
		task.ActivityCode, cashcode.CashCode, task.TaskTitle, org.AccountName, cashcode.CashDescription,
		taskstatus.TaskStatus, task.TotalCharge, invoices.InvoiceValue AS InvoicedCharge,
		invoices.InvoicePaid AS InvoicedChargePaid,
		task_costs.TotalCost, task_costs.InvoicedCost, task_costs.InvoicedCostPaid,
		task.TotalCharge + task_costs.TotalCost AS Profit,
		task.TotalCharge - invoices.InvoiceValue AS UninvoicedCharge,
		invoices.InvoiceValue - invoices.InvoicePaid AS UnpaidCharge,
		task_costs.TotalCost - task_costs.InvoicedCost AS UninvoicedCost,
		task_costs.InvoicedCost - task_costs.InvoicedCostPaid AS UnpaidCost,
		task.ActionOn, task.ActionedOn, task.PaymentOn
	FROM orders 
		JOIN Task.tbTask task ON task.TaskCode = orders.TaskCode
		JOIN invoices ON invoices.TaskCode = task.TaskCode
		JOIN task_costs ON orders.TaskCode = task_costs.TaskCode	
		JOIN Cash.tbCode cashcode ON task.CashCode = cashcode.CashCode
		JOIN Task.tbStatus taskstatus ON taskstatus.TaskStatusCode = task.TaskStatusCode
		JOIN Org.tbOrg org ON org.AccountCode = task.AccountCode
		JOIN App.tbYearPeriod yearperiod ON yearperiod.StartOn = orders.StartOn
		JOIN App.tbYear yr ON yr.YearNumber = yearperiod.YearNumber
		JOIN App.tbMonth mn ON mn.MonthNumber = yearperiod.MonthNumber;

go
CREATE OR ALTER TRIGGER Task.Task_tbTask_TriggerInsert
ON Task.tbTask
FOR INSERT
AS
	SET NOCOUNT ON;
	BEGIN TRY

	UPDATE task
	SET task.ActionOn = CAST(task.ActionOn AS DATE)
	FROM Task.tbTask task JOIN inserted i ON task.TaskCode = i.TaskCode
	WHERE DATEDIFF(SECOND, CAST(i.ActionOn AS DATE), i.ActionOn) <> 0;

	UPDATE task
	SET task.TotalCharge = i.UnitCharge * i.Quantity
	FROM Task.tbTask task JOIN inserted i ON task.TaskCode = i.TaskCode
	WHERE i.TotalCharge = 0 

	UPDATE task
	SET task.UnitCharge = i.TotalCharge / i.Quantity
	FROM Task.tbTask task JOIN inserted i ON task.TaskCode = i.TaskCode
	WHERE i.UnitCharge = 0 AND i.Quantity > 0;

	UPDATE task
	SET PaymentOn = App.fnAdjustToCalendar(CASE WHEN org.PayDaysFromMonthEnd <> 0 
											THEN 
												DATEADD(d, -1, DATEADD(m, 1, CONCAT(FORMAT(DATEADD(d, org.PaymentDays + org.ExpectedDays, task.ActionOn), 'yyyyMM'), '01')))												
											ELSE
												DATEADD(d, org.PaymentDays + org.ExpectedDays, task.ActionOn)	
											END, 0) 
	FROM Task.tbTask task
		JOIN Org.tbOrg org ON task.AccountCode = org.AccountCode
		JOIN inserted i ON task.TaskCode = i.TaskCode
	WHERE NOT task.CashCode IS NULL 

	INSERT INTO Org.tbContact (AccountCode, ContactName)
	SELECT DISTINCT AccountCode, ContactName 
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
CREATE OR ALTER TRIGGER [Task].[Task_tbTask_TriggerUpdate]
ON [Task].[tbTask]
FOR UPDATE
AS
	--SET NOCOUNT ON;
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
				SELECT ops.TaskCode, ops.OperationNumber, ops.OpTypeCode,
					LEAD(ops.OperationNumber) OVER (PARTITION BY ops.TaskCode ORDER BY ops.OperationNumber) AS NextOpNo
				FROM inserted i JOIN Task.tbOp ops ON i.TaskCode = ops.TaskCode 
			), async_ops AS
			(
				SELECT first_ops.TaskCode, first_ops.OperationNumber, next_ops.NextOpNo
				FROM first_ops JOIN next_ops ON first_ops.TaskCode = next_ops.TaskCode AND first_ops.OperationNumber = next_ops.OperationNumber

				UNION ALL

				SELECT next_ops.TaskCode, next_ops.OperationNumber, next_ops.NextOpNo
				FROM next_ops JOIN async_ops ON next_ops.TaskCode = async_ops.TaskCode AND next_ops.OperationNumber = async_ops.NextOpNo
				WHERE next_ops.OpTypeCode = 1

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
								  (ParentTaskCode, StepNumber, ChildTaskCode, FlowTypeCode, UsedOnQuantity, OffsetDays)
			SELECT     Task.tbTask.TaskCode, Activity.tbFlow.StepNumber, @TaskCode AS ChildTaskCode, Activity.tbFlow.FlowTypeCode, Activity.tbFlow.UsedOnQuantity, Activity.tbFlow.OffsetDays
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
				(ParentTaskCode, StepNumber, ChildTaskCode, FlowTypeCode, UsedOnQuantity, OffsetDays)
				SELECT TOP 1 ParentTaskCode, @StepNumber AS Step, @ToTaskCode AS ChildTask, FlowTypeCode, UsedOnQuantity, OffsetDays
				FROM         Task.tbFlow
				WHERE     (ChildTaskCode = @FromTaskCode)
				END
			END
		ELSE
			BEGIN		
			INSERT INTO Task.tbFlow
			(ParentTaskCode, StepNumber, ChildTaskCode, FlowTypeCode, UsedOnQuantity, OffsetDays)
			SELECT TOP 1 @ParentTaskCode As ParentTask, StepNumber, @ToTaskCode AS ChildTask, FlowTypeCode, UsedOnQuantity, OffsetDays
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
		, @AccountCode nvarchar(10)
	
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

		SET @InvoicedOn = isnull(CAST(@InvoicedOn AS DATE), CAST(CURRENT_TIMESTAMP AS DATE))
		SELECT @AccountCode = AccountCode FROM Task.tbTask WHERE TaskCode = @TaskCode


		BEGIN TRANSACTION
	
		EXEC Invoice.proc_Cancel
	
		UPDATE    Invoice.tbType
		SET              NextNumber = @NextNumber + 1
		WHERE     (InvoiceTypeCode = @InvoiceTypeCode)
	
		INSERT INTO Invoice.tbInvoice
							(InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoicedOn, InvoiceStatusCode, PaymentTerms)
		SELECT     @InvoiceNumber AS InvoiceNumber, @UserId AS UserId, Task.tbTask.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, @InvoicedOn AS InvoicedOn, 
							0 AS InvoiceStatusCode, Org.tbOrg.PaymentTerms
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
			, @InvoicedOn datetime

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
		
		SET @InvoicedOn = isnull(CAST(@InvoicedOn AS DATE), CAST(CURRENT_TIMESTAMP AS DATE))

		BEGIN TRANSACTION
	
		EXEC Invoice.proc_Cancel
	
		UPDATE    Invoice.tbType
		SET              NextNumber = @NextNumber + 1
		WHERE     (InvoiceTypeCode = @InvoiceTypeCode)
	
		INSERT INTO Invoice.tbInvoice
								(InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoicedOn, InvoiceStatusCode)
		VALUES     (@InvoiceNumber, @UserId, @AccountCode, @InvoiceTypeCode, @InvoicedOn, 0)
	
		COMMIT TRANSACTION
	
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog
	END CATCH

go
DROP PROCEDURE IF EXISTS Cash.proc_StatementRescheduleOverdue
go
DELETE FROM App.tbText WHERE TextId = 1216;
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


		IF UPDATE (InvoicedOn)
		BEGIN
			UPDATE invoice
			SET DueOn = App.fnAdjustToCalendar(CASE WHEN org.PayDaysFromMonthEnd <> 0 
													THEN 
														DATEADD(d, -1, DATEADD(m, 1, CONCAT(FORMAT(DATEADD(d, org.PaymentDays + org.ExpectedDays, i.InvoicedOn), 'yyyyMM'), '01')))												
													ELSE
														DATEADD(d, org.PaymentDays + org.ExpectedDays, invoice.InvoicedOn)	
													END, 0) 
			FROM Invoice.tbInvoice invoice
				JOIN inserted i ON i.InvoiceNumber = invoice.InvoiceNumber
				JOIN Org.tbOrg org ON i.AccountCode = org.AccountCode
		END		
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER TRIGGER Invoice.Invoice_tbInvoice_TriggerInsert
ON Invoice.tbInvoice
FOR INSERT
AS
	SET NOCOUNT ON;

	BEGIN TRY
		UPDATE invoice
		SET DueOn = App.fnAdjustToCalendar(CASE WHEN org.PayDaysFromMonthEnd <> 0 
												THEN 
													DATEADD(d, -1, DATEADD(m, 1, CONCAT(FORMAT(DATEADD(d, org.PaymentDays, i.InvoicedOn), 'yyyyMM'), '01')))												
												ELSE
													DATEADD(d, org.PaymentDays + org.ExpectedDays, invoice.InvoicedOn)	
												END, 0),
			ExpectedOn = App.fnAdjustToCalendar(CASE WHEN org.PayDaysFromMonthEnd <> 0 
												THEN 
													DATEADD(d, -1, DATEADD(m, 1, CONCAT(FORMAT(DATEADD(d, org.PaymentDays + org.ExpectedDays, i.InvoicedOn), 'yyyyMM'), '01')))												
												ELSE
													DATEADD(d, org.PaymentDays + org.ExpectedDays, invoice.InvoicedOn)	
												END, 0)				 
		FROM Invoice.tbInvoice invoice
			JOIN inserted i ON i.InvoiceNumber = invoice.InvoiceNumber
			JOIN Org.tbOrg org ON i.AccountCode = org.AccountCode
			
		UPDATE invoice
		SET ExpectedOn = invoice.DueOn
		FROM Invoice.tbInvoice invoice
			JOIN inserted i ON i.InvoiceNumber = invoice.InvoiceNumber
							
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER TABLE Task.tbFlow DROP CONSTRAINT DF_Task_tbFlow_UsedOnQuantity ;
ALTER TABLE Task.tbFlow ADD CONSTRAINT DF_Task_tbFlow_UsedOnQuantity  DEFAULT ((0)) FOR UsedOnQuantity;
go
CREATE OR ALTER FUNCTION Cash.fnTaxTypeDueDates(@TaxTypeCode smallint)
RETURNS @tbDueDate TABLE (PayOn datetime, PayFrom datetime, PayTo datetime)
 AS
	BEGIN
	DECLARE @MonthNumber smallint
			, @TaxMonth smallint
			, @MonthInterval smallint
			, @StartOn datetime
	
		SELECT 
			@TaxMonth = MonthNumber, 
			@MonthInterval = CASE RecurrenceCode
								WHEN 0 THEN 1
								WHEN 1 THEN 1
								WHEN 2 THEN 3
								WHEN 3 THEN 6
								WHEN 4 THEN 12
							END
		FROM Cash.tbTaxType
		WHERE TaxTypeCode = @TaxTypeCode
				
		IF @TaxTypeCode = 0
			GOTO CorporationTax;
		ELSE
			GOTO DefaultTaxType;

	Finalise:

		UPDATE @tbDueDate
		SET PayOn = DATEADD(DAY, (SELECT OffsetDays FROM Cash.tbTaxType WHERE TaxTypeCode = @TaxTypeCode), PayOn)

		RETURN;

	DefaultTaxType:
	
		SET @MonthNumber = @TaxMonth

		SELECT   @StartOn = MIN(StartOn)
		FROM         App.tbYearPeriod
		WHERE     (MonthNumber = @MonthNumber)

		INSERT INTO @tbDueDate (PayOn) VALUES (@StartOn)
	
		SET @MonthNumber = CASE 
			WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
			ELSE (@MonthNumber + @MonthInterval) % 12
			END
	
		WHILE EXISTS(SELECT     *
					 FROM         App.tbYearPeriod
					 WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber))
		BEGIN
			SELECT @StartOn = MIN(StartOn)
			FROM         App.tbYearPeriod
			WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber)
			ORDER BY MIN(StartOn)		
			INSERT INTO @tbDueDate (PayOn) VALUES (@StartOn)
		
			SET @MonthNumber = CASE WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
									ELSE (@MonthNumber + @MonthInterval) % 12 END;	
		END;

		WITH dd AS
		(
			SELECT PayOn, LAG(PayOn) OVER (ORDER BY PayOn) AS PayFrom
			FROM @tbDueDate 
		)
		UPDATE @tbDueDate
		SET PayTo = dd.PayOn, PayFrom = dd.PayFrom
		FROM @tbDueDate tbDueDate JOIN dd ON tbDueDate.PayOn = dd.PayOn;

		UPDATE @tbDueDate
		SET PayFrom = DATEADD(MONTH, @MonthInterval * -1, PayTo)
		WHERE PayTo = (SELECT MIN(PayTo) FROM @tbDueDate);

		GOTO Finalise

	CorporationTax:

		SELECT   @StartOn = StartOn, @MonthNumber = MonthNumber
		FROM         App.tbYearPeriod
		WHERE StartOn = (SELECT MIN(StartOn) FROM App.tbYearPeriod)

		INSERT INTO @tbDueDate (PayFrom) VALUES (@StartOn)

		SET @MonthNumber = CASE 
			WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
			ELSE (@MonthNumber + @MonthInterval) % 12
			END
	
		WHILE EXISTS(SELECT     *
					 FROM         App.tbYearPeriod
					 WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber))
		BEGIN
			SELECT @StartOn = MIN(StartOn)
			FROM         App.tbYearPeriod
			WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber)
			ORDER BY MIN(StartOn)		
			INSERT INTO @tbDueDate (PayFrom) VALUES (@StartOn)
		
			SET @MonthNumber = CASE WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
									ELSE (@MonthNumber + @MonthInterval) % 12 END;	
		END;

		WITH dd AS
		(
			SELECT PayFrom, LEAD(PayFrom) OVER (ORDER BY PayFrom) AS PayTo
			FROM @tbDueDate 
		)
		UPDATE @tbDueDate
		SET PayTo = dd.PayTo
		FROM @tbDueDate tbDueDate JOIN dd ON tbDueDate.PayFrom = dd.PayFrom;

		DELETE FROM @tbDueDate WHERE PayTo IS NULL;

		SET @StartOn = (SELECT MIN(PayFrom) FROM @tbDueDate)		
		SELECT @MonthNumber = DATEDIFF(MONTH, @StartOn, MIN(StartOn)) FROM App.tbYearPeriod
		WHERE MonthNumber = @TaxMonth AND StartOn >= @StartOn

		UPDATE @tbDueDate
		SET PayOn = DATEADD(MONTH, @MonthNumber, PayTo)

		GOTO Finalise
	RETURN	
	END
go

CREATE OR ALTER TRIGGER Org.Org_tbContact_TriggerUpdate 
   ON  Org.tbContact
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	

		IF UPDATE(ContactName)
		BEGIN
			UPDATE Org.tbContact
			SET 
				FileAs = Org.fnContactFileAs(tbContact.ContactName)
			FROM Org.tbContact INNER JOIN inserted AS i ON tbContact.AccountCode = i.AccountCode AND tbContact.ContactName = i.ContactName;
		END

		UPDATE Org.tbContact
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Org.tbContact INNER JOIN inserted AS i ON tbContact.AccountCode = i.AccountCode AND tbContact.ContactName = i.ContactName;

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
go
