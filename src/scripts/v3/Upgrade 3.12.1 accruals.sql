UPDATE App.tbOptions
SET SQLDataVersion = 3.12;
go
UPDATE Org.tbPaymentStatus
SET PaymentStatus = 'Transfer'
WHERE PaymentStatusCode = 2;
go
ALTER PROCEDURE [Org].[proc_PaymentPost] 
AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @PaymentCode nvarchar(20)

		DECLARE curMisc cursor local for
			SELECT        Org.tbPayment.PaymentCode
			FROM            Org.tbPayment INNER JOIN
									 Cash.tbCode ON Org.tbPayment.CashCode = Cash.tbCode.CashCode INNER JOIN
									 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			WHERE        (Org.tbPayment.PaymentStatusCode = 0) 
				AND Org.tbPayment.UserId = (SELECT UserId FROM Usr.vwCredentials)
			ORDER BY Org.tbPayment.AccountCode, Org.tbPayment.PaidOn

		DECLARE curInv cursor local for
			SELECT     PaymentCode
			FROM         Org.tbPayment
			WHERE     (PaymentStatusCode = 0) AND (CashCode IS NULL)
				AND Org.tbPayment.UserId = (SELECT UserId FROM Usr.vwCredentials)
			ORDER BY AccountCode, PaidOn
		
		BEGIN TRANSACTION

		OPEN curMisc
		FETCH NEXT FROM curMisc INTO @PaymentCode
		WHILE @@FETCH_STATUS = 0
			BEGIN
			EXEC Org.proc_PaymentPostMisc @PaymentCode		
			FETCH NEXT FROM curMisc INTO @PaymentCode	
			END

		CLOSE curMisc
		DEALLOCATE curMisc
	
		OPEN curInv
		FETCH NEXT FROM curInv INTO @PaymentCode
		WHILE @@FETCH_STATUS = 0
			BEGIN
			EXEC Org.proc_PaymentPostInvoiced @PaymentCode		
			FETCH NEXT FROM curInv INTO @PaymentCode	
			END

		CLOSE curInv
		DEALLOCATE curInv

		COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER PROCEDURE Cash.proc_PayAccrual (@PaymentCode NVARCHAR(20))
AS
    SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		
		IF EXISTS (	SELECT        *
					FROM            Org.tbPayment 
					WHERE        (PaymentStatusCode = 2) 
						AND UserId = (SELECT UserId FROM Usr.vwCredentials))
			BEGIN

			BEGIN TRANSACTION
			EXEC Org.proc_PaymentPostMisc @PaymentCode	
			COMMIT TRANSACTION
			
			END

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER   TRIGGER [Org].[Org_tbPayment_TriggerUpdate]
ON [Org].[tbPayment]
FOR UPDATE
AS
	SET NOCOUNT ON;
	BEGIN TRY
		UPDATE Org.tbPayment
		SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
		FROM Org.tbPayment INNER JOIN inserted AS i ON tbPayment.PaymentCode = i.PaymentCode;

		IF UPDATE(PaidInValue) OR UPDATE(PaidOutValue)
			BEGIN
			DECLARE @AccountCode NVARCHAR(10)
			DECLARE org CURSOR LOCAL FOR 
				SELECT AccountCode 
				FROM inserted
				WHERE PaymentStatusCode = 1

			OPEN org
			FETCH NEXT FROM org INTO @AccountCode
			WHILE (@@FETCH_STATUS = 0)
				BEGIN		
				EXEC Org.proc_Rebuild @AccountCode
				FETCH NEXT FROM org INTO @AccountCode
			END

			CLOSE org
			DEALLOCATE org

			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER TRIGGER Org.Org_tbPayment_TriggerInsert
ON Org.tbPayment
FOR INSERT
AS
	SET NOCOUNT ON;
	BEGIN TRY

		UPDATE payment
		SET PaymentStatusCode = 2
		FROM inserted
			JOIN Org.tbPayment payment ON inserted.PaymentCode = payment.PaymentCode
			JOIN Cash.tbCode ON inserted.CashCode = Cash.tbCode.CashCode 
			JOIN Cash.tbCategory category ON Cash.tbCode.CategoryCode = category.CategoryCode
		WHERE category.CashTypeCode = 3 AND inserted.PaymentStatusCode = 0

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
CREATE OR ALTER VIEW Cash.vwTransfersUnposted
AS
	SELECT        PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, TaxInValue, TaxOutValue, PaymentReference, InsertedBy, InsertedOn, 
							 UpdatedBy, UpdatedOn, RowVer
	FROM            Org.tbPayment
	WHERE        (PaymentStatusCode = 2)
go
IF NOT EXISTS (SELECT * FROM App.tbText WHERE TextId = 3017)
	INSERT INTO App.tbText (TextId, Message, Arguments) VALUES (3017, 'Cash codes must be of catagory type BANK', 0);
go
ALTER   PROCEDURE [Cash].[proc_CodeDefaults] 
	(
	@CashCode nvarchar(50)
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY

		SELECT     Cash.tbCode.CashCode, Cash.tbCode.CashDescription, Cash.tbCode.CategoryCode, Cash.tbCode.TaxCode, 
				App.tbTaxCode.TaxTypeCode, Cash.tbCode.OpeningBalance, 
							  ISNULL( Cash.tbCategory.CashModeCode, 0) AS CashModeCode, ISNULL(Cash.tbCategory.CashTypeCode, 0) AS CashTypeCode
		FROM         Cash.tbCode INNER JOIN
							  App.tbTaxCode ON Cash.tbCode.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
							  Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE     ( Cash.tbCode.CashCode = @CashCode)
    END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH 
go
ALTER PROCEDURE [Org].[proc_PaymentPostMisc]
	(
	@PaymentCode nvarchar(20) 
	)
 AS
 	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE 
			@InvoiceNumber nvarchar(20), 
			@NextNumber int, 
			@InvoiceTypeCode smallint;

		IF NOT EXISTS (SELECT        Org.tbPayment.PaymentCode
						FROM            Org.tbPayment INNER JOIN
												 Cash.tbCode ON Org.tbPayment.CashCode = Cash.tbCode.CashCode INNER JOIN
												 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
						WHERE        (Org.tbPayment.PaymentStatusCode <> 1) 
							AND Org.tbPayment.UserId = (SELECT UserId FROM Usr.vwCredentials))
			RETURN 

		SELECT @InvoiceTypeCode = CASE WHEN PaidInValue != 0 THEN 0 ELSE 2 END 
		FROM         Org.tbPayment
		WHERE     (PaymentCode = @PaymentCode)
	
		SELECT @NextNumber = NextNumber
		FROM Invoice.tbType
		WHERE InvoiceTypeCode = @InvoiceTypeCode;
		
		SET @InvoiceNumber = FORMAT(@NextNumber, '000000') + '.' + (SELECT UserId FROM Usr.vwCredentials)

		WHILE EXISTS (SELECT     InvoiceNumber
					  FROM         Invoice.tbInvoice
					  WHERE     (InvoiceNumber = @InvoiceNumber))
			BEGIN
			SET @NextNumber += @NextNumber 
			SET @InvoiceNumber = FORMAT(@NextNumber, '000000') + '.' + (SELECT UserId FROM Usr.vwCredentials)
			END
		
		BEGIN TRANSACTION

		UPDATE    Invoice.tbType
		SET              NextNumber = @NextNumber + 1
		WHERE     (InvoiceTypeCode = @InvoiceTypeCode)

		UPDATE    Org.tbPayment
		SET		PaymentStatusCode = 1,
			TaxInValue = (CASE App.tbTaxCode.RoundingCode WHEN 0 THEN ROUND(Org.tbPayment.PaidInValue - ( Org.tbPayment.PaidInValue / (1 + App.tbTaxCode.TaxRate)), 2) WHEN 1 THEN ROUND(Org.tbPayment.PaidInValue - ( Org.tbPayment.PaidInValue / (1 + App.tbTaxCode.TaxRate)), 2, 1) END), 
			TaxOutValue = (CASE App.tbTaxCode.RoundingCode WHEN 0 THEN ROUND(Org.tbPayment.PaidOutValue - ( Org.tbPayment.PaidOutValue / (1 + App.tbTaxCode.TaxRate)), 2) WHEN 1 THEN ROUND(Org.tbPayment.PaidOutValue - ( Org.tbPayment.PaidOutValue / (1 + App.tbTaxCode.TaxRate)), 2, 1) END)
		FROM         Org.tbPayment INNER JOIN
							  App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode
		WHERE     (PaymentCode = @PaymentCode)

		INSERT INTO Invoice.tbInvoice
								 (InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, DueOn, ExpectedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, Printed)
		SELECT        @InvoiceNumber AS InvoiceNumber, Org.tbPayment.UserId, Org.tbPayment.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, 3 AS InvoiceStatusCode, 
								Org.tbPayment.PaidOn, Org.tbPayment.PaidOn AS DueOn, Org.tbPayment.PaidOn AS ExpectedOn,
								CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
									WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
								END AS InvoiceValue, 
								CASE WHEN Org.tbPayment.PaidInValue > 0 THEN Org.tbPayment.TaxInValue 
									WHEN Org.tbPayment.PaidOutValue > 0 THEN Org.tbPayment.TaxOutValue
								END AS TaxValue, 
								CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
									WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
								END AS PaidValue, 
								CASE WHEN Org.tbPayment.PaidInValue > 0 THEN Org.tbPayment.TaxInValue 
									WHEN Org.tbPayment.PaidOutValue > 0 THEN Org.tbPayment.TaxOutValue
								END AS PaidTaxValue, 
								1 AS Printed
		FROM            Org.tbPayment INNER JOIN
								 App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode
		WHERE        ( Org.tbPayment.PaymentCode = @PaymentCode)


		INSERT INTO Invoice.tbItem
							(InvoiceNumber, CashCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, TaxCode)
		SELECT     @InvoiceNumber AS InvoiceNumber, Org.tbPayment.CashCode, 
								CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
									WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
								END AS InvoiceValue, 
								CASE WHEN Org.tbPayment.PaidInValue > 0 THEN Org.tbPayment.TaxInValue 
									WHEN Org.tbPayment.PaidOutValue > 0 THEN Org.tbPayment.TaxOutValue
								END AS TaxValue, 
								CASE WHEN PaidInValue > 0 THEN PaidInValue - TaxInValue
									WHEN PaidOutValue > 0 THEN PaidOutValue - TaxOutValue
								END AS PaidValue, 
								CASE WHEN Org.tbPayment.PaidInValue > 0 THEN Org.tbPayment.TaxInValue 
									WHEN Org.tbPayment.PaidOutValue > 0 THEN Org.tbPayment.TaxOutValue
								END AS PaidTaxValue, 
							Org.tbPayment.TaxCode
		FROM         Org.tbPayment INNER JOIN
							  App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode
		WHERE     ( Org.tbPayment.PaymentCode = @PaymentCode)

		UPDATE Invoice.tbItem
		SET PaidValue = InvoiceValue, PaidTaxValue = TaxValue
		WHERE InvoiceNumber = @InvoiceNumber

		UPDATE  Org.tbAccount
		SET CurrentBalance = CASE WHEN PaidInValue > 0 THEN Org.tbAccount.CurrentBalance + PaidInValue ELSE Org.tbAccount.CurrentBalance - PaidOutValue END
		FROM         Org.tbAccount INNER JOIN
							  Org.tbPayment ON Org.tbAccount.CashAccountCode = Org.tbPayment.CashAccountCode
		WHERE Org.tbPayment.PaymentCode = @PaymentCode

		COMMIT TRANSACTION

  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
UPDATE Usr.tbMenuEntry
SET ItemText = 'Expenses'
WHERE MenuId = 1 AND FolderId = 5 AND ItemId = 6 AND ItemText <> 'Expenses';

IF NOT EXISTS (SELECT * FROM Usr.tbMenuEntry WHERE MenuId = 1 AND FolderId = 5 AND ItemId = 5)
	INSERT INTO Usr.tbMenuEntry
			(MenuId, FolderId, ItemId, ItemText, Command, ProjectName, Argument, OpenMode)
	VALUES	(1, 5, 5, 'Transfers', 4, 'Trader', 'Cash_Transfer', 0);

UPDATE Usr.tbMenuEntry
SET FolderId = 4, ItemId = 4
WHERE MenuId = 1 AND FolderId = 2 AND ItemId = 3;
go
ALTER   PROCEDURE [Cash].[proc_ReserveAccount](@CashAccountCode NVARCHAR(10) OUTPUT)
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		SELECT  @CashAccountCode = Org.tbAccount.CashAccountCode
		FROM            Org.tbAccount LEFT OUTER JOIN
								 Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode 
		WHERE (Cash.tbCode.CashCode IS NULL) AND (Org.tbAccount.DummyAccount = 0);
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
	UPDATE App.tbText
	SET [Message] = 'Reserve Balance'
	WHERE TextId = 1219;
go
ALTER VIEW [Cash].[vwStatementReserves]
AS
	WITH reserve_account AS
	(
		SELECT  Org.tbAccount.CashAccountCode, Org.tbAccount.CashAccountName, Org.tbAccount.CurrentBalance
		FROM            Org.tbAccount LEFT OUTER JOIN
								 Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode 
		WHERE        (Org.tbAccount.AccountCode <> (SELECT AccountCode FROM App.tbOptions))
			AND (Cash.tbCode.CashCode IS NULL) AND (Org.tbAccount.DummyAccount = 0)
	), last_payment AS
	(
		SELECT MAX( payments.PaidOn) AS TransactOn
		FROM reserve_account JOIN Org.tbPayment payments 
						ON reserve_account.CashAccountCode = payments.CashAccountCode 
		WHERE payments.PaymentStatusCode = 1
	
	), opening_balance AS
	(
		SELECT 	
			(SELECT AccountCode FROM App.tbOptions) AS AccountCode,		
			(SELECT TransactOn FROM last_payment) AS TransactOn,
			0 AS CashEntryTypeCode,
			(SELECT CAST([Message] AS NVARCHAR) FROM App.tbText WHERE TextId = 1219) AS ReferenceCode,
			CASE WHEN SUM(CurrentBalance) > 0 THEN SUM(CurrentBalance) ELSE 0 END AS PayIn, 
			CASE WHEN SUM(CurrentBalance) < 0 THEN SUM(CurrentBalance) ELSE 0 END  AS PayOut
		FROM reserve_account 

	), unbalanced_reserves AS
	(
		SELECT  0 AS RowNumber, org.AccountCode, org.AccountName, TransactOn, CashEntryTypeCode, ReferenceCode, 
					PayOut, PayIn, NULL AS CashCode, NULL AS CashDescription
		FROM opening_balance
			JOIN Org.tbOrg org ON opening_balance.AccountCode = org.AccountCode

		UNION
	
		SELECT ROW_NUMBER() OVER (ORDER BY payments.PaidOn) AS RowNumber, reserve_account.CashAccountCode AS AccountCode,
			reserve_account.CashAccountName AS AccountName,
			payments.PaidOn AS TransactOn, 6 AS CashEntryTypeCode, payments.PaymentCode AS ReferenceCode,  
			payments.PaidOutValue, payments.PaidInValue, payments.CashCode, cash_code.CashDescription 
		FROM reserve_account 
			JOIN Org.tbPayment payments ON reserve_account.CashAccountCode = payments.CashAccountCode
			JOIN Cash.tbCode cash_code ON payments.CashCode = cash_code.CashCode
		WHERE payments.PaymentStatusCode = 2
	)
	SELECT RowNumber, TransactOn, entry_type.CashEntryTypeCode, entry_type.CashEntryType, ReferenceCode, unbalanced_reserves.AccountCode, unbalanced_reserves.AccountName,
		PayOut, PayIn,
		SUM(PayIn + (PayOut * -1)) OVER (ORDER BY RowNumber) AS Balance,
		CashCode, CashDescription
	FROM unbalanced_reserves 
		JOIN Cash.tbEntryType entry_type ON unbalanced_reserves.CashEntryTypeCode = entry_type.CashEntryTypeCode
go

ALTER VIEW [Cash].[vwStatement]
AS
	--invoiced taxes
	WITH corp_taxcode AS
	(
		SELECT TOP (1) AccountCode, CashCode 
		FROM Cash.tbTaxType WHERE (TaxTypeCode = 0)
	), corptax_invoiced_entries AS
	(
		SELECT AccountCode, CashCode, StartOn, TaxDue, Balance,
			ROW_NUMBER() OVER (ORDER BY StartOn) AS RowNumber 
		FROM Cash.vwTaxCorpStatement CROSS JOIN corp_taxcode
		WHERE (TaxDue > 0) AND (Balance <> 0) AND (StartOn >= (SELECT MIN(StartOn) FROM App.tbYearPeriod WHERE CashStatusCode < 2))
	), corptax_invoiced_owing AS
	(
		SELECT AccountCode, CashCode, StartOn AS TransactOn, 4 AS CashEntryTypeCode, 
			(SELECT CAST([Message] AS NVARCHAR) FROM App.tbText WHERE TextId = 1214) ReferenceCode, 0 AS PayIn,
			CASE RowNumber WHEN 1 THEN Balance ELSE TaxDue END AS PayOut
		FROM corptax_invoiced_entries
	), vat_taxcode AS
	(
		SELECT TOP (1) AccountCode, CashCode 
		FROM Cash.tbTaxType WHERE (TaxTypeCode = 1)
	), vat_invoiced_entries AS
	(
		SELECT AccountCode, CashCode, StartOn AS TransactOn, VatDue, Balance, 
			ROW_NUMBER() OVER(ORDER BY StartOn) AS RowNumber   
		FROM Cash.vwTaxVatStatement CROSS JOIN vat_taxcode
		WHERE (vatDue > 0) AND (Balance <> 0) AND (StartOn >= (SELECT MIN(StartOn) FROM App.tbYearPeriod WHERE CashStatusCode < 2))
	), vat_invoiced_owing AS
	(
		SELECT AccountCode, CashCode, TransactOn, 5 AS CashEntryTypeCode, 
			(SELECT CAST([Message] AS NVARCHAR) FROM App.tbText WHERE TextId = 1214) ReferenceCode, 0 AS PayIn,
			CASE RowNumber WHEN 1 THEN Balance ELSE VatDue END AS PayOut
		FROM vat_invoiced_entries
	)
	--uninvoiced taxes
	, task_invoiced_quantity AS
	(
		SELECT        Invoice.tbTask.TaskCode, SUM(Invoice.tbTask.Quantity) AS InvoiceQuantity
		FROM            Invoice.tbTask INNER JOIN
								 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		WHERE        (Invoice.tbInvoice.InvoiceTypeCode = 0) OR
								 (Invoice.tbInvoice.InvoiceTypeCode = 2)
		GROUP BY Invoice.tbTask.TaskCode
	), corptax_ordered_confirmed AS
	(
		SELECT (SELECT TOP (1) StartOn FROM App.tbYearPeriod WHERE (StartOn <= Task.tbTask.PaymentOn) ORDER BY StartOn DESC) AS StartOn, 
					CASE WHEN Cash.tbCategory.CashModeCode = 0 
						THEN (Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0))) * - 1 
						ELSE Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0)) 
					END AS OrderValue
		FROM            task_invoiced_quantity RIGHT OUTER JOIN
								 App.vwCorpTaxCashCodes AS CashCodes INNER JOIN
								 Cash.tbCategory INNER JOIN
								 Cash.tbCode ON Cash.tbCategory.CategoryCode = Cash.tbCode.CategoryCode ON CashCodes.CashCode = Cash.tbCode.CashCode INNER JOIN
								 Task.tbTask ON CashCodes.CashCode = Task.tbTask.CashCode ON task_invoiced_quantity.TaskCode = Task.tbTask.TaskCode
		WHERE        (Task.tbTask.TaskStatusCode > 0) AND (Task.tbTask.TaskStatusCode < 3) AND (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0) > 0) 
				AND (Task.tbTask.PaymentOn <= (SELECT DATEADD(d, TaxHorizon, CURRENT_TIMESTAMP) AS HorizonOn FROM App.tbOptions))
	), corptax_ordered AS
	(
		SELECT        orders.StartOn, SUM(orders.OrderValue * App.tbYearPeriod.CorporationTaxRate) AS TaxDue
		FROM            corptax_ordered_confirmed orders INNER JOIN
								 App.tbYearPeriod ON orders.StartOn = App.tbYearPeriod.StartOn
		GROUP BY orders.StartOn
	), corptax_dates AS
	(
		SELECT PayOn, PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(0)
	), corptax_order_totals AS
	(
		SELECT (SELECT PayOn FROM corptax_dates WHERE totals.StartOn >= PayFrom AND totals.StartOn < PayTo) AS StartOn, TaxDue
		FROM corptax_ordered totals
	), corptax_ordered_entries AS
	(
		SELECT StartOn, SUM(TaxDue) AS TaxDue
		FROM corptax_order_totals
		GROUP BY StartOn
	), corptax_ordered_owing AS
	(	
		SELECT AccountCode, CashCode, StartOn AS TransactOn, 4 AS CashEntryTypeCode, 
				(SELECT CAST([Message] AS NVARCHAR) FROM App.tbText WHERE TextId = 1215) ReferenceCode, 0 AS PayIn, 
				TaxDue AS PayOut
		FROM corptax_ordered_entries CROSS JOIN corp_taxcode
	), vat_ordered AS
	(
		SELECT  (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Task.tbTask.PaymentOn) ORDER BY p.StartOn DESC) AS StartOn,  
				 CASE WHEN Cash.tbCategory.CashModeCode = 0 
					THEN (Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0))) * App.tbTaxCode.TaxRate * - 1 
					ELSE Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0)) * App.tbTaxCode.TaxRate 
				END AS TaxDue
		FROM            Task.tbTask INNER JOIN
								 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
								 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode INNER JOIN
								 App.tbTaxCode ON Task.tbTask.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
								 task_invoiced_quantity ON Task.tbTask.TaskCode = task_invoiced_quantity.TaskCode
		WHERE        (App.tbTaxCode.TaxTypeCode = 1) AND (Task.tbTask.TaskStatusCode > 0) AND (Task.tbTask.TaskStatusCode < 3) AND 
								 (CASE WHEN Cash.tbCategory.CashModeCode = 0 THEN (Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0))) 
								 * App.tbTaxCode.TaxRate ELSE Task.tbTask.UnitCharge * (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0)) * App.tbTaxCode.TaxRate * - 1 END <> 0) AND 
								 (Task.tbTask.PaymentOn <= (SELECT DATEADD(d, TaxHorizon, CURRENT_TIMESTAMP) FROM App.tbOptions))
	), vat_dates AS
	(
		SELECT PayOn, PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(1)
	), vat_order_totals AS
	(
		SELECT (SELECT PayOn FROM vat_dates WHERE totals.StartOn >= PayFrom AND totals.StartOn < PayTo) AS StartOn, TaxDue
		FROM vat_ordered totals
	), vat_ordered_entries AS	
	(
		SELECT StartOn, SUM(TaxDue) AS TaxDue
		FROM vat_order_totals
		GROUP BY StartOn
	), vat_ordered_owing AS
	(	
		SELECT AccountCode, CashCode, StartOn AS TransactOn, 5 AS CashEntryTypeCode, 
				(SELECT CAST([Message] AS NVARCHAR) FROM App.tbText WHERE TextId = 1215) ReferenceCode, 0 AS PayIn,
				TaxDue AS PayOut
		FROM vat_ordered_entries CROSS JOIN vat_taxcode
	)
	--unpaid invoices
	, invoices_unpaid_items AS
	(
		SELECT     Invoice.tbInvoice.AccountCode, Invoice.tbItem.CashCode, Invoice.tbInvoice.ExpectedOn AS TransactOn, 1 AS CashEntryTypeCode, Invoice.tbItem.InvoiceNumber AS ReferenceCode, 
							  SUM(CASE WHEN InvoiceTypeCode = 0 OR
							  InvoiceTypeCode = 3 THEN ( Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue) - ( Invoice.tbItem.PaidValue + Invoice.tbItem.PaidTaxValue) 
							  ELSE 0 END) AS PayIn, SUM(CASE WHEN InvoiceTypeCode = 1 OR
							  InvoiceTypeCode = 2 THEN ( Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue) - ( Invoice.tbItem.PaidValue + Invoice.tbItem.PaidTaxValue) 
							  ELSE 0 END) AS PayOut
		FROM         Invoice.tbItem INNER JOIN
							  Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							  Cash.tbCode ON Invoice.tbItem.CashCode = Cash.tbCode.CashCode INNER JOIN
							  Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE  (InvoiceStatusCode < 3) AND (( Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue) - ( Invoice.tbItem.PaidValue + Invoice.tbItem.PaidTaxValue) > 0)
		GROUP BY Invoice.tbItem.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.ExpectedOn, Invoice.tbItem.CashCode
	), invoices_unpaid_tasks AS
	(
		SELECT     Invoice.tbInvoice.AccountCode, Invoice.tbTask.CashCode, Invoice.tbInvoice.ExpectedOn AS TransactOn, 1 AS CashEntryTypeCode, Invoice.tbTask.InvoiceNumber AS ReferenceCode, 
							  SUM(CASE WHEN InvoiceTypeCode = 0 OR
							  InvoiceTypeCode = 3 THEN ( Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue) - ( Invoice.tbTask.PaidValue + Invoice.tbTask.PaidTaxValue) 
							  ELSE 0 END) AS PayIn, SUM(CASE WHEN InvoiceTypeCode = 1 OR
							  InvoiceTypeCode = 2 THEN ( Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue) - ( Invoice.tbTask.PaidValue + Invoice.tbTask.PaidTaxValue) 
							  ELSE 0 END) AS PayOut
		FROM         Invoice.tbTask INNER JOIN
							  Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
							  Cash.tbCode ON Invoice.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
							  Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE  (InvoiceStatusCode < 3) AND  (( Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue) - ( Invoice.tbTask.PaidValue + Invoice.tbTask.PaidTaxValue) > 0)
		GROUP BY Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.ExpectedOn, Invoice.tbTask.CashCode
	), tasks_confirmed AS
	(
		SELECT        TOP (100) PERCENT Task.tbTask.TaskCode AS ReferenceCode, Task.tbTask.AccountCode, Task.tbTask.PaymentOn AS TransactOn, Task.tbTask.PaymentOn, 2 AS CashEntryTypeCode, 
								 CASE WHEN Cash.tbCategory.CashModeCode = 0 THEN (Task.tbTask.UnitCharge + Task.tbTask.UnitCharge * App.tbTaxCode.TaxRate) * (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 
								 0)) ELSE 0 END AS PayOut, CASE WHEN Cash.tbCategory.CashModeCode = 1 THEN (Task.tbTask.UnitCharge + Task.tbTask.UnitCharge * App.tbTaxCode.TaxRate) 
								 * (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0)) ELSE 0 END AS PayIn, Cash.tbCode.CashCode
		FROM            App.tbTaxCode INNER JOIN
								 Task.tbTask ON App.tbTaxCode.TaxCode = Task.tbTask.TaxCode INNER JOIN
								 Cash.tbCode ON Task.tbTask.CashCode = Cash.tbCode.CashCode INNER JOIN
								 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode LEFT OUTER JOIN
								 task_invoiced_quantity ON Task.tbTask.TaskCode = task_invoiced_quantity.TaskCode
		WHERE        (Task.tbTask.TaskStatusCode > 0) AND (Task.tbTask.TaskStatusCode < 3) AND (Task.tbTask.Quantity - ISNULL(task_invoiced_quantity.InvoiceQuantity, 0) > 0)
	)
	--interbank transfers
	, current_account AS
	(
		SELECT        Org.tbAccount.CashAccountCode
		FROM            Org.tbAccount INNER JOIN
								 Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode INNER JOIN
								 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode AND Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE        (Cash.tbCategory.CashTypeCode = 3)
	), accruals AS
	(
		SELECT        Org.tbPayment.AccountCode, Org.tbPayment.CashCode, Org.tbPayment.PaidOn AS TransactOn, Org.tbPayment.PaymentCode AS ReferenceCode, 
			6 AS CashEntryTypeCode, Org.tbPayment.PaidInValue AS PayIn, Org.tbPayment.PaidOutValue AS PayOut
		FROM            current_account INNER JOIN
								 Org.tbPayment ON current_account.CashAccountCode = Org.tbPayment.CashAccountCode
		WHERE        (Org.tbPayment.PaymentStatusCode = 2)
	)
	, statement_unsorted AS
	(
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM corptax_invoiced_owing
		UNION
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM vat_invoiced_owing
		UNION
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM corptax_ordered_owing
		UNION
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM vat_ordered_owing
		UNION
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM invoices_unpaid_items
		UNION 
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM invoices_unpaid_tasks
		UNION 
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM tasks_confirmed
		UNION
		SELECT AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM accruals
	), statement_sorted AS
	(
		SELECT ROW_NUMBER() OVER(ORDER BY TransactOn, CashEntryTypeCode) AS RowNumber,
		 AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM statement_unsorted			
	), opening_balance AS
	(	
		SELECT SUM( Org.tbAccount.CurrentBalance) AS OpeningBalance
		FROM         Org.tbAccount INNER JOIN
							  Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
		WHERE     ( Org.tbAccount.AccountClosed = 0) AND (Org.tbAccount.DummyAccount = 0)
	), statement_data AS
	(
		SELECT 
			0 AS RowNumber,
			(SELECT TOP (1) AccountCode FROM App.tbOptions) AS AccountCode,
			NULL AS CashCode,
			NULL AS TransactOn,    
			(SELECT CAST([Message] AS NVARCHAR) FROM App.tbText WHERE TextId = 3013) AS ReferenceCode,	
			1 AS CashEntryTypeCode,
			PayIn = (SELECT OpeningBalance FROM opening_balance),
			0 AS PayOut
		UNION 
		SELECT RowNumber, AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut FROM statement_sorted
	), company_statement AS
	(
		SELECT RowNumber, AccountCode, CashCode, TransactOn, ReferenceCode, CashEntryTypeCode, PayIn, PayOut,
			SUM(PayIn + (PayOut * -1)) OVER (ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
		FROM statement_data
	)
	SELECT RowNumber, cs.AccountCode, org.AccountName, cs.CashCode, cc.CashDescription,
		 TransactOn, ReferenceCode, cs.CashEntryTypeCode, et.CashEntryType, PayIn, PayOut, Balance
	FROM company_statement cs 
		JOIN Org.tbOrg org ON cs.AccountCode = org.AccountCode
		JOIN Cash.tbEntryType et ON cs.CashEntryTypeCode = et.CashEntryTypeCode
		LEFT OUTER JOIN Cash.tbCode cc ON cs.CashCode = cc.CashCode;

GO


