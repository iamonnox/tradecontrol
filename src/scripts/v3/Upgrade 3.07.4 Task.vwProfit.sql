ALTER VIEW Task.vwProfit 
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
			CASE WHEN child.UsedOnQuantity <> 0 THEN orders.Quantity * child.UsedOnQuantity ELSE task.Quantity END AS Quantity, 
			1 AS Depth,
			CASE category.CashModeCode WHEN 0 THEN task.UnitCharge * -1 ELSE task.UnitCharge END AS UnitCharge,
			invoices.InvoiceValue, invoices.InvoicePaid
		FROM Task.tbFlow child 
			JOIN orders ON child.ParentTaskCode = orders.TaskCode
			JOIN Task.tbTask task ON child.ChildTaskCode = task.TaskCode
			JOIN Cash.tbCode cashcode ON cashcode.CashCode = task.CashCode 
			JOIN Cash.tbCategory category ON category.CategoryCode = cashcode.CategoryCode
			JOIN invoices ON invoices.TaskCode = task.TaskCode

		UNION ALL

		SELECT parent.TaskCode, child.ParentTaskCode, child.ChildTaskCode, 
			CASE WHEN child.UsedOnQuantity <> 0 THEN parent.Quantity * child.UsedOnQuantity ELSE task.Quantity END AS Quantity, 
			parent.Depth + 1 AS Depth,
			CASE category.CashModeCode WHEN 0 THEN task.UnitCharge * -1 ELSE task.UnitCharge END AS UnitCharge,
			invoices.InvoiceValue, invoices.InvoicePaid
		FROM Task.tbFlow child 
			JOIN task_flow parent ON child.ParentTaskCode = parent.ChildTaskCode
			JOIN Task.tbTask task ON child.ChildTaskCode = task.TaskCode
			JOIN Cash.tbCode cashcode ON cashcode.CashCode = task.CashCode 
			JOIN Cash.tbCategory category ON category.CategoryCode = cashcode.CategoryCode
			JOIN invoices ON invoices.TaskCode = task.TaskCode	

	), task_costs AS
	(
		SELECT TaskCode, ROUND(SUM(Quantity * UnitCharge), 2) AS TotalCost, 
				ROUND(SUM(InvoiceValue), 2) AS InvoicedCost, ROUND(SUM(InvoicePaid), 2) AS InvoicedCostPaid
		FROM task_flow
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
DROP FUNCTION IF EXISTS [Task].[fnProfitCost];
DROP FUNCTION IF EXISTS [Task].[fnProfitOrder];
DROP VIEW IF EXISTS [Task].[vwProfitOrders];
DROP FUNCTION IF EXISTS [Task].[fnProfit];
go
CREATE NONCLUSTERED INDEX IX_Task_tbTask_ActionOn_TaskCode_CashCode ON Task.tbTask
(
	ActionOn ASC,
	TaskCode ASC,
	CashCode ASC,
	TaskStatusCode ASC,
	AccountCode ASC
)
INCLUDE ( 	TaskTitle,
	ActivityCode,
	ActionedOn,
	Quantity,
	UnitCharge,
	TotalCharge,
	PaymentOn) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX IX_Task_tbTask_TaskCode_CashCode ON Task.tbTask
(
	TaskCode ASC,
	CashCode ASC
)
INCLUDE ( 	Quantity,
	UnitCharge) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX IX_Task_tbTask_ActionOn_Status_CashCode ON Task.tbTask
(
	ActionOn ASC,
	TaskStatusCode ASC,
	CashCode ASC,
	TaskCode ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE STATISTICS STAT_Task_tbTask_ActionOn_CashCode_TaskCode ON Task.tbTask(ActionOn, CashCode, TaskCode)
go

CREATE STATISTICS STAT_Task_tbTask_CashCode_TaskCode_Status ON Task.tbTask(CashCode, TaskCode, TaskStatusCode, ActionOn, AccountCode)
go