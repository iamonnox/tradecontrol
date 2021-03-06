ALTER VIEW [Cash].[vwCategoriesTrade]
AS
	SELECT        TOP (100) PERCENT CategoryCode, Category, CategoryTypeCode, CashModeCode, CashTypeCode, DisplayOrder, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, RowVer
	FROM            Cash.tbCategory
	WHERE        (CategoryTypeCode = 0)
go
ALTER PROCEDURE [Cash].[proc_GeneratePeriods]
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
					VALUES (@YearNumber, @PeriodStartOn, DATEPART(m, @PeriodStartOn), 0)				
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

ALTER PROCEDURE [Task].[proc_ScheduleOp]
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
				EXEC App.proc_AdjustToCalendar @EndOn, @OffsetDays, @AdjustedOn OUTPUT
				SET @StartOn = @AdjustedOn
				UPDATE Task.tbOp
				SET EndOn = @EndOn, StartOn = @StartOn
				WHERE TaskCode = @TaskCode and OperationNumber = @OperationNumber			
				END
			ELSE
				BEGIN		
				EXEC App.proc_AdjustToCalendar @ActionOn, @OffsetDays, @AdjustedOn OUTPUT	
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
ALTER VIEW [Org].[vwSalesInvoices]
AS
SELECT        Invoice.tbInvoice.AccountCode, tbInvoiceTask.InvoiceNumber, tbInvoiceTask.TaskCode, Task.tbTask.ContactName, Invoice.tbInvoice.InvoicedOn, tbInvoiceTask.Quantity, tbInvoiceTask.InvoiceValue, 
                         tbInvoiceTask.TaxValue, tbInvoiceTask.CashCode, tbInvoiceTask.TaxCode, Invoice.tbStatus.InvoiceStatus, Task.tbTask.TaskNotes, Cash.tbCode.CashDescription, Invoice.tbInvoice.InvoiceStatusCode, 
                         Task.tbTask.TaskTitle, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbType.InvoiceType, tbInvoiceTask.PaidValue, tbInvoiceTask.PaidTaxValue
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbTask AS tbInvoiceTask ON Invoice.tbInvoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
                         Task.tbTask ON tbInvoiceTask.TaskCode = Task.tbTask.TaskCode INNER JOIN
                         Cash.tbCode ON tbInvoiceTask.CashCode = Cash.tbCode.CashCode INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE        (Invoice.tbInvoice.InvoiceStatusCode > 0) AND (Invoice.tbInvoice.InvoiceTypeCode = 0);
go
