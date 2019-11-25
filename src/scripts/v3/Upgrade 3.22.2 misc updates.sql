CREATE OR ALTER PROCEDURE Invoice.proc_Accept 
	(
	@InvoiceNumber nvarchar(20)
	)
AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		IF EXISTS(SELECT     InvoiceNumber
	          FROM         Invoice.tbItem
	          WHERE     (InvoiceNumber = @InvoiceNumber)) 
		or EXISTS(SELECT     InvoiceNumber
	          FROM         Invoice.tbTask
	          WHERE     (InvoiceNumber = @InvoiceNumber))
		BEGIN
			BEGIN TRANSACTION
			
			EXEC Invoice.proc_Total @InvoiceNumber
			
			UPDATE    Invoice.tbInvoice
			SET              InvoiceStatusCode = 1
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (InvoiceStatusCode = 0); 
	
			WITH invoiced_quantity AS
			(
				SELECT        Invoice.tbTask.TaskCode, SUM(Invoice.tbTask.Quantity) AS InvoiceQuantity
				FROM            Invoice.tbTask INNER JOIN
										 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
				WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 0) OR
										 (Invoice.tbInvoice.InvoiceTypeCode = 2)
				GROUP BY Invoice.tbTask.TaskCode
			)
			UPDATE       Task
			SET                TaskStatusCode = 3
			FROM            Task.tbTask AS Task INNER JOIN
									 invoiced_quantity ON Task.TaskCode = invoiced_quantity.TaskCode AND Task.Quantity <= invoiced_quantity.InvoiceQuantity INNER JOIN
									 Invoice.tbTask AS InvoiceTask ON Task.TaskCode = InvoiceTask.TaskCode AND Task.TaskCode = InvoiceTask.TaskCode
			WHERE        (InvoiceTask.InvoiceNumber = @InvoiceNumber) AND (Task.TaskStatusCode < 3);
			
			COMMIT TRANSACTION
		END
	ELSE
		UPDATE Invoice.tbInvoice
		SET InvoiceValue = 0, PaidValue = 0, TaxValue = 0, PaidTaxValue = 0, InvoiceStatusCode = 0
		WHERE InvoiceNumber = @InvoiceNumber;
			
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Invoice.proc_Cancel 
AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		BEGIN TRAN

		UPDATE       Task
		SET                TaskStatusCode = 2
		FROM            Task.tbTask AS Task INNER JOIN
								 Invoice.tbTask AS InvoiceTask ON Task.TaskCode = InvoiceTask.TaskCode AND Task.TaskCode = InvoiceTask.TaskCode INNER JOIN
								 Invoice.tbInvoice ON InvoiceTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Usr.vwCredentials ON Invoice.tbInvoice.UserId = Usr.vwCredentials.UserId
		WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 0 OR
								 Invoice.tbInvoice.InvoiceTypeCode = 2) AND (Invoice.tbInvoice.InvoiceStatusCode = 0)
	                      
		DELETE Invoice.tbInvoice
		FROM         Invoice.tbInvoice INNER JOIN
							  Usr.vwCredentials ON Invoice.tbInvoice.UserId = Usr.vwCredentials.UserId
		WHERE     ( Invoice.tbInvoice.InvoiceStatusCode = 0)
		
		COMMIT TRAN

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
