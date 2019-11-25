ALTER TABLE App.tbOptions WITH NOCHECK ADD
 IsAutoOffsetDays bit NOT NULL CONSTRAINT DF_App_tbOptions_IsAutoOffsetDays DEFAULT ((0));
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
				FROM Task.tbFlow child 
					JOIN cascade_status ON child.ParentTaskCode = cascade_status.TaskCode
					JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
				WHERE CashCode IS NULL

				UNION ALL

				SELECT parent.ParentStatusCode, child.ParentTaskCode, child.ChildTaskCode, child_task.TaskStatusCode
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
				FROM Task.tbFlow child 
					JOIN cascade_status ON child.ParentTaskCode = cascade_status.TaskCode
					JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode
				WHERE CashCode IS NULL

				UNION ALL

				SELECT parent.ParentStatusCode, child.ParentTaskCode, child.ChildTaskCode, child_task.TaskStatusCode
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
			
			IF EXISTS(SELECT * FROM App.tbOptions WHERE IsAutoOffsetDays <> 0)
			BEGIN
				UPDATE flow
				SET OffsetDays = App.fnOffsetDays(inserted.ActionOn, parent_task.ActionOn)
									- ISNULL((SELECT SUM(OffsetDays) FROM Task.tbFlow sub_flow WHERE sub_flow.ParentTaskCode = flow.ParentTaskCode AND sub_flow.StepNumber > flow.StepNumber), 0)
				FROM Task.tbFlow AS flow 
					JOIN inserted ON flow.ChildTaskCode = inserted.TaskCode 
					JOIN Task.tbTask AS parent_task ON flow.ParentTaskCode = parent_task.TaskCode
					JOIN Cash.tbCode ON parent_task.CashCode = Cash.tbCode.CashCode
				WHERE (SELECT SUM(UsedOnQuantity) FROM inserted JOIN Task.tbFlow ON inserted.TaskCode = Task.tbFlow.ChildTaskCode) = 0
			END

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
				SELECT cascade_title_change.TaskTitle AS ProjectTitle, cascade_title_change.PreviousTitle, child.ParentTaskCode, child.ChildTaskCode, child_task.TaskTitle
				FROM Task.tbFlow child 
					JOIN cascade_title_change ON child.ParentTaskCode = cascade_title_change.TaskCode
					JOIN Task.tbTask child_task ON child.ChildTaskCode = child_task.TaskCode

				UNION ALL

				SELECT parent.ProjectTitle, parent.PreviousTitle, child.ParentTaskCode, child.ChildTaskCode, child_task.TaskTitle
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
CREATE OR ALTER PROCEDURE Invoice.proc_Pay
	(
	@InvoiceNumber nvarchar(20),
	@PaidOn datetime,
	@Post bit = 1,
	@PaymentCode nvarchar(20) NULL OUTPUT
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
	DECLARE 
		@PaidOut money = 0
		, @PaidIn money = 0
		, @BalanceOutstanding money = 0
		, @TaskOutstanding money = 0
		, @ItemOutstanding money = 0
		, @CashModeCode smallint
		, @AccountCode nvarchar(10)
		, @CashAccountCode nvarchar(10)
		, @InvoiceStatusCode smallint
		, @UserId nvarchar(10)
		, @PaymentReference nvarchar(20)
		, @PayBalance BIT

		SELECT 
			@CashModeCode = Invoice.tbType.CashModeCode, 
			@AccountCode = Invoice.tbInvoice.AccountCode, 
			@PayBalance = Org.tbOrg.PayBalance,
			@InvoiceStatusCode = Invoice.tbInvoice.InvoiceStatusCode
		FROM Invoice.tbInvoice 
			INNER JOIN Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
			INNER JOIN Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
		WHERE     ( Invoice.tbInvoice.InvoiceNumber = @InvoiceNumber)
	
		EXEC Org.proc_BalanceOutstanding @AccountCode, @BalanceOutstanding OUTPUT
		IF @BalanceOutstanding = 0 OR @InvoiceStatusCode > 2
			RETURN 1

		SELECT @UserId = UserId FROM Usr.vwCredentials	
		SET @PaidOn = CAST(@PaidOn AS DATE)

		SET @PaymentCode = CONCAT(@UserId, '_', FORMAT(@PaidOn, 'yyyymmdd_hhmmss'))

		WHILE EXISTS (SELECT * FROM Org.tbPayment WHERE PaymentCode = @PaymentCode)
			BEGIN
			SET @PaidOn = DATEADD(s, 1, @PaidOn)
			SET @PaymentCode = CONCAT(@UserId, '_', FORMAT(@PaidOn, 'yyyymmdd_hhmmss'))
			END
			
		IF @PayBalance = 0
			BEGIN	
			SET @PaymentReference = @InvoiceNumber
															
			SELECT  @TaskOutstanding = SUM( Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue - Invoice.tbTask.PaidValue - Invoice.tbTask.PaidTaxValue)
			FROM         Invoice.tbInvoice INNER JOIN
								  Invoice.tbTask ON Invoice.tbInvoice.InvoiceNumber = Invoice.tbTask.InvoiceNumber INNER JOIN
								  Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
			WHERE     ( Invoice.tbInvoice.InvoiceNumber = @InvoiceNumber)
			GROUP BY Invoice.tbType.CashModeCode


			SELECT @ItemOutstanding = SUM( Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue - Invoice.tbItem.PaidValue - Invoice.tbItem.PaidTaxValue)
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
			END
		ELSE
			BEGIN
			SET @PaidIn = CASE WHEN @BalanceOutstanding > 0 THEN @BalanceOutstanding ELSE 0 END
			SET @PaidOut = CASE WHEN @BalanceOutstanding < 0 THEN ABS(@BalanceOutstanding) ELSE 0 END
			END
	
		EXEC Cash.proc_CurrentAccount @CashAccountCode OUTPUT

		BEGIN TRANSACTION

		IF @PaidIn + @PaidOut > 0
			BEGIN			

			INSERT INTO Org.tbPayment
								  (PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, PaidOn, PaidInValue, PaidOutValue, PaymentReference)
			VALUES     (@PaymentCode,@UserId, 0, @AccountCode, @CashAccountCode, @PaidOn, @PaidIn, @PaidOut, @PaymentReference)		
		
			IF @Post <> 0
				EXEC Org.proc_PaymentPostInvoiced @PaymentCode			
			END
		
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Task.proc_Pay (@TaskCode NVARCHAR(20), @Post BIT = 0,	@PaymentCode nvarchar(20) NULL OUTPUT)
AS
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		
		DECLARE 
			@InvoiceTypeCode smallint
			, @InvoiceNumber NVARCHAR(20)
			, @InvoicedOn DATETIME = CURRENT_TIMESTAMP

		SELECT @InvoiceTypeCode = CASE CashModeCode WHEN 0 THEN 2 ELSE 0 END       
		FROM  Task.tbTask INNER JOIN
				Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
				Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode AND Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode AND 
				Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE Task.tbTask.TaskCode = @TaskCode
		
		EXEC Invoice.proc_Raise @TaskCode = @TaskCode, @InvoiceTypeCode = @InvoiceTypeCode, @InvoicedOn = @InvoicedOn, @InvoiceNumber = @InvoiceNumber OUTPUT
		EXEC Invoice.proc_Accept @InvoiceNumber
		EXEC Invoice.proc_Pay @InvoiceNumber = @InvoiceNumber, @PaidOn = @InvoicedOn, @Post = @Post, @PaymentCode = @PaymentCode OUTPUT

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER VIEW Cash.vwTaxVatTotals
AS
	WITH vat_dates AS
	(
		SELECT PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(1)
	), vatPeriod AS
	(
		SELECT        StartOn, y.YearNumber, p.MonthNumber,
			(SELECT PayTo FROM vat_dates WHERE p.StartOn >= PayFrom AND p.StartOn < PayTo) AS VatStartOn, VatAdjustment
		FROM            App.tbYearPeriod AS p JOIN App.tbYear AS y ON p.YearNumber = y.YearNumber 
		WHERE     (y.CashStatusCode = 1) OR (y.CashStatusCode = 2)
	), vat_results AS
	(
		SELECT VatStartOn AS PayTo, DATEADD(MONTH, -1, VatStartOn) AS PostOn,
			SUM(HomeSales) AS HomeSales, SUM(HomePurchases) AS HomePurchases, SUM(ExportSales) AS ExportSales, SUM(ExportPurchases) AS ExportPurchases, 
			SUM(HomeSalesVat) AS HomeSalesVat, SUM(HomePurchasesVat) AS HomePurchasesVat, 
			SUM(ExportSalesVat) AS ExportSalesVat, SUM(ExportPurchasesVat) AS ExportPurchasesVat, SUM(VatDue) AS VatDue
		FROM Cash.vwTaxVatSummary vatCodeDue JOIN vatPeriod ON vatCodeDue.StartOn = vatPeriod.StartOn
		GROUP BY VatStartOn
	), vat_adjustments AS
	(
		SELECT VatStartOn AS PayTo, SUM(VatAdjustment) AS VatAdjustment
		FROM vatPeriod p 
		GROUP BY VatStartOn
	)
	SELECT active_year.YearNumber, active_year.Description, active_month.MonthName AS Period, vat_results.PostOn AS StartOn, HomeSales, HomePurchases, ExportSales, ExportPurchases, HomeSalesVat, HomePurchasesVat, ExportSalesVat, ExportPurchasesVat,
		vat_adjustments.VatAdjustment, VatDue - vat_adjustments.VatAdjustment AS VatDue
	FROM vat_results JOIN vat_adjustments ON vat_results.PayTo = vat_adjustments.PayTo
		JOIN App.tbYearPeriod year_period ON vat_results.PostOn = year_period.StartOn
		JOIN App.tbMonth active_month ON year_period.MonthNumber = active_month.MonthNumber
		JOIN App.tbYear active_year ON year_period.YearNumber = active_year.YearNumber;
go
CREATE OR ALTER PROCEDURE Usr.proc_MenuItemDelete( @EntryId int )
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRANSACTION

		DECLARE @MenuId SMALLINT = (SELECT MenuId FROM Usr.tbMenuEntry menu WHERE menu.EntryId = @EntryId);

		DELETE FROM Usr.tbMenuEntry
		WHERE Command = 1 
			AND MenuId = @MenuId
			AND Argument = (SELECT FolderId FROM Usr.tbMenuEntry menu WHERE Command = 0 AND menu.EntryId = @EntryId);

		 WITH root_folder AS
		 (
			 SELECT FolderId, MenuId 
			 FROM Usr.tbMenuEntry menu
			 WHERE Command = 0 AND menu.EntryId = @EntryId
		), child_folders AS
		(
			SELECT CAST(Argument AS smallint) AS FolderId, root_folder.MenuId
			FROM Usr.tbMenuEntry sub_folder 
			JOIN root_folder ON sub_folder.FolderId = root_folder.FolderId
			WHERE Command = 1 AND sub_folder.MenuId = @MenuId

			UNION ALL

			SELECT CAST(Argument AS smallint) AS FolderId, p.MenuId
			FROM child_folders p 
				JOIN Usr.tbMenuEntry m ON p.FolderId = m.FolderId
			WHERE Command = 1 AND m.MenuId = p.MenuId
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
CREATE OR ALTER PROCEDURE Task.proc_DefaultPaymentOn
	(
		@AccountCode nvarchar(10),
		@ActionOn datetime,
		@PaymentOn datetime output
	)
AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		SELECT @ActionOn = CASE WHEN org.PayDaysFromMonthEnd <> 0 
				THEN 
					DATEADD(d, -1, DATEADD(d,  org.ExpectedDays, DATEADD(m, 1, CONCAT(FORMAT(DATEADD(d, org.PaymentDays, @ActionOn), 'yyyyMM'), '01'))))												
				ELSE
					DATEADD(d, org.PaymentDays + org.ExpectedDays, @ActionOn)	
				END
		FROM Org.tbOrg org 
		WHERE org.AccountCode = @AccountCode

		SELECT @PaymentOn = App.fnAdjustToCalendar(@ActionOn, 0) 					
	 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
INSERT INTO App.tbInstall (SQLDataVersion, SQLRelease) VALUES (3.23, 3);
go