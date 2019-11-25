/************************************************************
* Tru-Man Trade Control: Management Information and Cash System
* Copyright Tru-Man Industries Ltd 2010. All Rights Reserved.
* Author: Ian Monnox
* Description: Sql Server Upgrade Script - Encrypted Distribution Schema
* Data Version: 1.15
* Release Date: 14 June 2010
************************************************************/

CREATE OR ALTER PROCEDURE dbo.spTaskCopy
	(
	@FromTaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20) = null,
	@ToTaskCode nvarchar(20) = null output
	)
AS
declare @ActivityCode nvarchar(50)
declare @Printed bit
declare @ChildTaskCode nvarchar(20)
declare @TaskStatusCode smallint
declare @StepNumber smallint
declare @UserId nvarchar(10)

	SELECT @UserId = UserId FROM vwUserCredentials
	
	SELECT  @TaskStatusCode = tbActivity.TaskStatusCode, @ActivityCode = tbTask.ActivityCode, @Printed = CASE WHEN tbActivity.PrintOrder = 0 THEN 1 ELSE 0 END
	FROM         tbTask INNER JOIN
	                      tbActivity ON tbTask.ActivityCode = tbActivity.ActivityCode
	WHERE     (tbTask.TaskCode = @FromTaskCode)
	
	exec dbo.spTaskNextCode @ActivityCode, @ToTaskCode output

	INSERT INTO tbTask
						  (TaskCode, UserId, AccountCode, TaskTitle, ContactName, ActivityCode, TaskStatusCode, ActionById, ActionOn, ActionedOn, TaskNotes, Quantity, 
						  SecondReference, CashCode, TaxCode, UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, PaymentOn, Printed)
	SELECT     @ToTaskCode AS ToTaskCode, @UserId AS Owner, AccountCode, TaskTitle, ContactName, ActivityCode, @TaskStatusCode AS TaskStatus, 
						  @UserId AS ActionUserId, CONVERT(datetime, CONVERT(varchar, GETDATE(), 1), 1) AS ActionOn, 
						  CASE WHEN @TaskStatusCode > 2 THEN CONVERT(datetime, CONVERT(varchar, GETDATE(), 1), 1) ELSE NULL END AS ActionedOn, TaskNotes, 
						  Quantity, SecondReference, CashCode, TaxCode, UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, 
						  dbo.fnTaskDefaultPaymentOn(AccountCode, CONVERT(datetime, CONVERT(varchar, GETDATE(), 1), 1)) AS Expr1, @Printed AS Printed
	FROM         tbTask AS tbTask_1
	WHERE     (TaskCode = @FromTaskCode)
	
	INSERT INTO tbTaskAttribute
	                      (TaskCode, Attribute, PrintOrder, AttributeTypeCode, AttributeDescription)
	SELECT     @ToTaskCode AS ToTaskCode, Attribute, PrintOrder, AttributeTypeCode, AttributeDescription
	FROM         tbTaskAttribute AS tbTaskAttribute_1
	WHERE     (TaskCode = @FromTaskCode)
	
	INSERT INTO tbTaskQuote
	                      (TaskCode, Quantity, TotalPrice, RunOnQuantity, RunOnPrice, RunBackQuantity, RunBackPrice)
	SELECT     @ToTaskCode AS ToTaskCode, Quantity, TotalPrice, RunOnQuantity, RunOnPrice, RunBackQuantity, RunBackPrice
	FROM         tbTaskQuote AS tbTaskQuote_1
	WHERE     (TaskCode = @FromTaskCode)
	
	INSERT INTO tbTaskOp
						  (TaskCode, OperationNumber, OpStatusCode, UserId, OpTypeCode, Operation, Note, StartOn, EndOn, Duration, OffsetDays)
	SELECT     @ToTaskCode AS ToTaskCode, OperationNumber, 1 AS OpStatus, UserId, OpTypeCode, Operation, Note, CONVERT(datetime, CONVERT(varchar, 
						  GETDATE(), 1), 1) AS StartOn, CONVERT(datetime, CONVERT(varchar, GETDATE(), 1), 1) AS EndOn, Duration, OffsetDays
	FROM         tbTaskOp AS tbTaskOp_1
	WHERE     (TaskCode = @FromTaskCode)
	
	IF (ISNULL(@ParentTaskCode, '') = '')
		BEGIN
		IF EXISTS(SELECT     ParentTaskCode
				FROM         tbTaskFlow
				WHERE     (ChildTaskCode = @FromTaskCode))
			BEGIN
			SELECT @ParentTaskCode = ParentTaskCode
			FROM         tbTaskFlow
			WHERE     (ChildTaskCode = @FromTaskCode)

			SELECT @StepNumber = MAX(StepNumber)
			FROM         tbTaskFlow
			WHERE     (ParentTaskCode = @ParentTaskCode)
			GROUP BY ParentTaskCode
				
			SET @StepNumber = @StepNumber - (@StepNumber % 10) + 10	
						
			INSERT INTO tbTaskFlow
			(ParentTaskCode, StepNumber, ChildTaskCode, UsedOnQuantity, OffsetDays)
			SELECT TOP 1 ParentTaskCode, @StepNumber AS Step, @ToTaskCode AS ChildTask, UsedOnQuantity, OffsetDays
			FROM         tbTaskFlow
			WHERE     (ChildTaskCode = @FromTaskCode)
			END
		END
	ELSE
		BEGIN
		
		INSERT INTO tbTaskFlow
		(ParentTaskCode, StepNumber, ChildTaskCode, UsedOnQuantity, OffsetDays)
		SELECT TOP 1 @ParentTaskCode As ParentTask, StepNumber, @ToTaskCode AS ChildTask, UsedOnQuantity, OffsetDays
		FROM         tbTaskFlow AS tbTaskFlow_1
		WHERE     (ChildTaskCode = @FromTaskCode)		
		END
	
	declare curTask cursor local for			
		SELECT     ChildTaskCode
		FROM         tbTaskFlow
		WHERE     (ParentTaskCode = @FromTaskCode)
	
	open curTask
	
	fetch next from curTask into @ChildTaskCode
	while (@@FETCH_STATUS = 0)
		begin
		exec dbo.spTaskCopy @ChildTaskCode, @ToTaskCode
		fetch next from curTask into @ChildTaskCode
		end
		
	close curTask
	deallocate curTask
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskParent] 
	(
	@TaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20) output
	)
AS
	set @ParentTaskCode = @TaskCode
	if exists(SELECT     ParentTaskCode
	             FROM         tbTaskFlow
	             WHERE     (ChildTaskCode = @ParentTaskCode))
		select @ParentTaskCode = ParentTaskCode
	             FROM         tbTaskFlow
	             WHERE     (ChildTaskCode = @ParentTaskCode)
		
	RETURN
GO
ALTER PROCEDURE [dbo].[spTaskAssignToParent] 
	(
	@ChildTaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20)
	)
AS
declare @TaskTitle nvarchar(100)
declare @StepNumber smallint

	IF EXISTS (SELECT ParentTaskCode FROM tbTaskFlow WHERE ChildTaskCode = @ChildTaskCode)
		DELETE FROM tbTaskFlow WHERE ChildTaskCode = @ChildTaskCode

	IF EXISTS(SELECT     TOP 1 StepNumber
	          FROM         tbTaskFlow
	          WHERE     (ParentTaskCode = @ParentTaskCode))
		begin
		SELECT  @StepNumber = MAX(StepNumber) 
		FROM         tbTaskFlow
		WHERE     (ParentTaskCode = @ParentTaskCode)
		set @StepNumber = @StepNumber - (@StepNumber % 10) + 10		
		end
	else
		set @StepNumber = 10


	SELECT     @TaskTitle = TaskTitle
	FROM         tbTask
	WHERE     (TaskCode = @ParentTaskCode)		
	
	UPDATE    tbTask
	SET              TaskTitle = @TaskTitle
	WHERE     (TaskCode = @ChildTaskCode) AND (TaskTitle IS NULL)
	
	INSERT INTO tbTaskFlow
	                      (ParentTaskCode, StepNumber, ChildTaskCode)
	VALUES     (@ParentTaskCode, @StepNumber, @ChildTaskCode)
	
	RETURN
GO
