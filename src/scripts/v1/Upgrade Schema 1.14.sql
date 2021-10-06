/************************************************************
* Tru-Man Trade Control: Management Information and Cash System
* Copyright Tru-Man Industries Ltd 2010. All Rights Reserved.
* Author: Ian Monnox
* Description: Sql Server Upgrade Script - Encrypted Distribution Schema
* Data Version: 1.14
* Release Date: 2 June 2010
************************************************************/
GO
CREATE FUNCTION [dbo].[fnTaskIsExpense]
	(
	@TaskCode nvarchar(20)
	)
RETURNS bit
AS
	BEGIN
	DECLARE @IsExpense bit
	IF EXISTS (SELECT     tbTask.TaskCode
	           FROM         tbTask INNER JOIN
	                                 tbCashCode ON tbTask.CashCode = tbCashCode.CashCode INNER JOIN
	                                 tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	           WHERE     (tbCashCategory.CashModeCode = 2) AND (tbTask.TaskCode = @TaskCode))
		SET @IsExpense = 0			          
	ELSE IF EXISTS(SELECT     ParentTaskCode
	          FROM         tbTaskFlow
	          WHERE     (ChildTaskCode = @TaskCode))
		BEGIN
		DECLARE @ParentTaskCode nvarchar(20)
		SELECT  @ParentTaskCode = ParentTaskCode
		FROM         tbTaskFlow
		WHERE     (ChildTaskCode = @TaskCode)		
		SET @IsExpense = dbo.fnTaskIsExpense(@ParentTaskCode)		
		END	              
	ELSE
		SET @IsExpense = 1
			
	RETURN @IsExpense
	END
GO
CREATE VIEW [dbo].[vwInvoiceRegisterExpenses]
AS
SELECT     StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, 
                      InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, 
                      InvoiceType, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS UnpaidValue
FROM         dbo.vwInvoiceRegisterTasks
WHERE     (dbo.fnTaskIsExpense(TaskCode) = 1)
GO
