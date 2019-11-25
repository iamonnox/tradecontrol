CREATE OR ALTER VIEW Cash.vwAccountStatementBase
AS
	WITH entries AS
	(
		SELECT  payment.CashAccountCode, ROW_NUMBER() OVER (PARTITION BY payment.CashAccountCode ORDER BY PaidOn) AS EntryNumber, PaymentCode, PaidOn, 
			CASE WHEN PaidInValue > 0 THEN PaidInValue ELSE PaidOutValue * - 1 END AS Paid
		FROM         Org.tbPayment payment INNER JOIN Org.tbAccount ON payment.CashAccountCode = Org.tbAccount.CashAccountCode
		WHERE     (PaymentStatusCode = 1) AND (AccountClosed = 0)		
		UNION
		SELECT        Org.tbAccount.CashAccountCode, 0 AS EntryNumber, App.fnProfileText(3005) AS PaymentCode, DATEADD(HOUR, - 1, MIN(Org.tbPayment.PaidOn)) AS PaidOn, Org.tbAccount.OpeningBalance AS PaidBalance
		FROM            Org.tbAccount INNER JOIN
								 Org.tbPayment ON Org.tbAccount.CashAccountCode = Org.tbPayment.CashAccountCode
		WHERE        (Org.tbAccount.AccountClosed = 0)
		GROUP BY Org.tbAccount.CashAccountCode, Org.tbAccount.OpeningBalance
	)
	SELECT CashAccountCode, EntryNumber, PaymentCode, PaidOn, 
		SUM(Paid) OVER (PARTITION BY CashAccountCode ORDER BY EntryNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS PaidBalance
	FROM entries
GO

ALTER VIEW [Cash].[vwAccountStatement]
  AS
	WITH payments AS
	(
		SELECT     Org.tbPayment.PaymentCode, Org.tbPayment.CashAccountCode, Usr.tbUser.UserName, Org.tbPayment.AccountCode, 
							  Org.tbOrg.AccountName, Org.tbPayment.CashCode, Cash.tbCode.CashDescription, App.tbTaxCode.TaxDescription, 
							  Org.tbPayment.PaidInValue, Org.tbPayment.PaidOutValue, Org.tbPayment.TaxInValue, 
							  Org.tbPayment.TaxOutValue, Org.tbPayment.PaymentReference, Org.tbPayment.InsertedBy, Org.tbPayment.InsertedOn, 
							  Org.tbPayment.UpdatedBy, Org.tbPayment.UpdatedOn, Org.tbPayment.TaxCode
		FROM         Org.tbPayment INNER JOIN
							  Usr.tbUser ON Org.tbPayment.UserId = Usr.tbUser.UserId INNER JOIN
							  Org.tbOrg ON Org.tbPayment.AccountCode = Org.tbOrg.AccountCode LEFT OUTER JOIN
							  App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
							  Cash.tbCode ON Org.tbPayment.CashCode = Cash.tbCode.CashCode
	)
	SELECT running_balance.CashAccountCode, (SELECT TOP 1 StartOn FROM App.tbYearPeriod	WHERE (StartOn <= running_balance.PaidOn) ORDER BY StartOn DESC) AS StartOn, 
							running_balance.EntryNumber, running_balance.PaymentCode, running_balance.PaidOn, 
							payments.AccountName, payments.PaymentReference, payments.PaidInValue, 
							payments.PaidOutValue, running_balance.PaidBalance, payments.TaxInValue, 
							payments.TaxOutValue, payments.CashCode, 
							payments.CashDescription, payments.TaxDescription, payments.UserName, 
							payments.AccountCode, payments.TaxCode
	FROM   Cash.vwAccountStatementBase running_balance LEFT OUTER JOIN
							payments ON running_balance.PaymentCode = payments.PaymentCode
	
GO
ALTER VIEW [Cash].[vwAccountStatementListing]
AS
	SELECT        App.tbYear.YearNumber, Org.tbOrg.AccountName AS Bank, Org.tbAccount.CashAccountCode, Org.tbAccount.CashAccountName, Org.tbAccount.SortCode, Org.tbAccount.AccountNumber, CONCAT(App.tbYear.Description, SPACE(1), 
							 App.tbMonth.MonthName) AS PeriodName, Cash.vwAccountStatement.StartOn, Cash.vwAccountStatement.EntryNumber, Cash.vwAccountStatement.PaymentCode, Cash.vwAccountStatement.PaidOn, 
							 Cash.vwAccountStatement.AccountName, Cash.vwAccountStatement.PaymentReference, Cash.vwAccountStatement.PaidInValue, Cash.vwAccountStatement.PaidOutValue, 
							 Cash.vwAccountStatement.PaidBalance, Cash.vwAccountStatement.TaxInValue, Cash.vwAccountStatement.TaxOutValue, Cash.vwAccountStatement.CashCode, 
							 Cash.vwAccountStatement.CashDescription, Cash.vwAccountStatement.TaxDescription, Cash.vwAccountStatement.UserName, Cash.vwAccountStatement.AccountCode, 
							 Cash.vwAccountStatement.TaxCode
	FROM            App.tbYearPeriod INNER JOIN
							 App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber INNER JOIN
							 Cash.vwAccountStatement INNER JOIN
							 Org.tbAccount ON Cash.vwAccountStatement.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
							 Org.tbOrg ON Org.tbAccount.AccountCode = Org.tbOrg.AccountCode ON App.tbYearPeriod.StartOn = Cash.vwAccountStatement.StartOn INNER JOIN
							 App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber;
GO
ALTER VIEW Cash.vwAccountPeriodClosingBalance
AS
	WITH last_entries AS
	(
		SELECT     CashAccountCode, StartOn, MAX(EntryNumber) AS LastEntry
		FROM         Cash.vwAccountStatement
		GROUP BY CashAccountCode, StartOn
		HAVING      (NOT (StartOn IS NULL))
	)
	SELECT        Org.tbAccount.CashCode, last_entries.StartOn, SUM(Cash.vwAccountStatement.PaidBalance) AS ClosingBalance
	FROM            last_entries INNER JOIN
							 Cash.vwAccountStatement ON last_entries.CashAccountCode = Cash.vwAccountStatement.CashAccountCode AND 
							 last_entries.StartOn = Cash.vwAccountStatement.StartOn AND 
							 last_entries.LastEntry = Cash.vwAccountStatement.EntryNumber INNER JOIN
							 Org.tbAccount ON last_entries.CashAccountCode = Org.tbAccount.CashAccountCode
	GROUP BY Org.tbAccount.CashCode, last_entries.StartOn
GO

DROP FUNCTION IF EXISTS [Cash].[fnAccountStatements];
DROP FUNCTION IF EXISTS [Cash].[fnAccountStatement];
DROP VIEW IF EXISTS Cash.vwAccountStatements;
DROP VIEW IF EXISTS Cash.vwAccountLastPeriodEntry;

GO
CREATE TABLE App.tbRounding 
(
	RoundingCode SMALLINT NOT NULL,
	Rounding NVARCHAR(20) NOT NULL,
	CONSTRAINT PK_tbRounding PRIMARY KEY CLUSTERED (RoundingCode) ON [PRIMARY]
);

INSERT App.tbRounding (RoundingCode, Rounding) VALUES (0, 'Round'), (1, 'Truncate');

ALTER TABLE App.tbTaxCode WITH NOCHECK ADD
	RoundingCode SMALLINT NOT NULL CONSTRAINT DF_tbTaxCode_RoundingCode DEFAULT (0);

ALTER TABLE App.tbTaxCode  WITH NOCHECK ADD  CONSTRAINT FK_App_tbTaxCode_App_tbRounding FOREIGN KEY(RoundingCode)
REFERENCES App.tbRounding (RoundingCode);
ALTER TABLE App.tbTaxCode CHECK CONSTRAINT FK_App_tbTaxCode_App_tbRounding;

GO
ALTER PROCEDURE [Org].[proc_Rebuild]
	(
		@AccountCode nvarchar(10)
	)
 AS

	SET NOCOUNT ON;
	BEGIN TRAN OrgRebuild;

	UPDATE Invoice.tbItem
	SET TaxValue = CASE App.tbTaxCode.RoundingCode 
			WHEN 0 THEN FORMAT(Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, '#.00')
			WHEN 1 THEN ROUND( Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END,
		PaidValue = Invoice.tbItem.InvoiceValue, 
		PaidTaxValue = CASE App.tbTaxCode.RoundingCode 
			WHEN 0 THEN FORMAT(Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, '#.00')
			WHEN 1 THEN ROUND( Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END
	FROM         Invoice.tbItem INNER JOIN
	                      App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
	                      Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
	WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND ( Invoice.tbInvoice.AccountCode = @AccountCode);
                      
	UPDATE Invoice.tbTask
	SET TaxValue = CASE App.tbTaxCode.RoundingCode 
			WHEN 0 THEN FORMAT(Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, '#.00')
			WHEN 1 THEN ROUND( Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END,
		PaidValue = Invoice.tbTask.InvoiceValue,
		PaidTaxValue = CASE App.tbTaxCode.RoundingCode 
			WHEN 0 THEN FORMAT(Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, '#.00')
			WHEN 1 THEN ROUND( Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END
	FROM         Invoice.tbTask INNER JOIN
	                      App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
	                      Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
	WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND ( Invoice.tbInvoice.AccountCode = @AccountCode);
	
	UPDATE Invoice.tbInvoice
	SET InvoiceValue = 0, TaxValue = 0
	WHERE     ( Invoice.tbInvoice.InvoiceStatusCode <> 0) AND ( Invoice.tbInvoice.AccountCode = @AccountCode);
	
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
	                      ON Invoice.tbInvoice.InvoiceNumber = items.InvoiceNumber
	WHERE (Invoice.tbInvoice.AccountCode = @AccountCode);	

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
	FROM         Invoice.tbInvoice INNER JOIN tasks ON Invoice.tbInvoice.InvoiceNumber = tasks.InvoiceNumber
	WHERE (Invoice.tbInvoice.AccountCode = @AccountCode);			

	UPDATE    Invoice.tbInvoice
	SET              PaidValue = InvoiceValue, PaidTaxValue = TaxValue, InvoiceStatusCode = 3
	WHERE     (InvoiceStatusCode <> 0) AND (AccountCode = @AccountCode);
	
	UPDATE Org.tbPayment
	SET
		TaxInValue = PaidInValue - CASE App.tbTaxCode.RoundingCode 
			WHEN 0 THEN FORMAT((PaidInValue / (1 + TaxRate)), '#.00')
			WHEN 1 THEN ROUND((PaidInValue / (1 + TaxRate)), 2, 1) END, 
		TaxOutValue = PaidOutValue - CASE App.tbTaxCode.RoundingCode 
			WHEN 0 THEN FORMAT((PaidOutValue / (1 + TaxRate)), '#.00')
			WHEN 1 THEN ROUND((PaidOutValue / (1 + TaxRate)), 2, 1) END
	FROM         Org.tbPayment INNER JOIN
	                      App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode
	WHERE     ( Org.tbPayment.AccountCode = @AccountCode);



/************** replace cursor ********************/
DECLARE @PaidBalance money, @InvoicedBalance money, @Balance money;
DECLARE @CashModeCode smallint, @TaxRate float, @RoundingCode smallint;	
DECLARE @InvoiceNumber nvarchar(20), @TaskCode nvarchar(20), @CashCode nvarchar(50), @InvoiceValue money, @TaxValue money;	
DECLARE @PaidValue money, @PaidInvoiceValue money, @PaidTaxValue money;

	SELECT  @PaidBalance = SUM(CASE WHEN PaidInValue > 0 THEN PaidInValue * -1 ELSE PaidOutValue  END)
	FROM         Org.tbPayment
	WHERE     (AccountCode = @AccountCode) And (PaymentStatusCode <> 0)
	
	SELECT @PaidBalance = ISNULL(@PaidBalance, 0) + OpeningBalance
	FROM Org.tbOrg
	WHERE     (AccountCode = @AccountCode)

	SELECT @InvoicedBalance = SUM(CASE Invoice.tbType.CashModeCode WHEN 0 THEN (InvoiceValue + TaxValue) * - 1 WHEN 1 THEN InvoiceValue + TaxValue ELSE 0 END) 
	FROM         Invoice.tbInvoice INNER JOIN
	                      Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
	WHERE     ( Invoice.tbInvoice.AccountCode = @AccountCode)
	
	SET @Balance = ISNULL(@PaidBalance, 0) + ISNULL(@InvoicedBalance, 0)
                      
    SET @CashModeCode = CASE WHEN @Balance > 0 THEN 1 ELSE 0 END
	SET @Balance = ABS(@Balance)	

	DECLARE curInv cursor local for
		WITH invoice_items AS
		(		
			SELECT        Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.CollectOn, Invoice.tbTask.CashCode, Invoice.tbTask.TaskCode, Invoice.tbTask.InvoiceValue, Invoice.tbTask.TaxValue, Invoice.tbTask.TaxCode
			FROM            Invoice.tbTask INNER JOIN
									 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
			UNION
			SELECT        Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbItem.InvoiceNumber, Invoice.tbInvoice.CollectOn, Invoice.tbItem.CashCode, '' AS TaskCode, Invoice.tbItem.InvoiceValue, Invoice.tbItem.TaxValue, Invoice.tbItem.TaxCode
			FROM            Invoice.tbItem INNER JOIN
									 Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
		)
		SELECT     InvoiceNumber, TaskCode, CashCode, InvoiceValue, TaxValue, TaxRate, RoundingCode
		FROM invoice_items INNER JOIN Invoice.tbType t ON invoice_items.InvoiceTypeCode = t.InvoiceTypeCode
			INNER JOIN App.tbTaxCode ON invoice_items.TaxCode = App.tbTaxCode.TaxCode
		WHERE invoice_items.AccountCode = @AccountCode AND (CashModeCode = @CashModeCode)
		ORDER BY CollectOn DESC;
	

	OPEN curInv
	FETCH NEXT FROM curInv INTO @InvoiceNumber, @TaskCode, @CashCode, @InvoiceValue, @TaxValue, @TaxRate, @RoundingCode
	WHILE @@FETCH_STATUS = 0 And (@Balance > 0)
		BEGIN

		IF (@Balance - (@InvoiceValue + @TaxValue)) < 0
			BEGIN
			SET @PaidValue = (@InvoiceValue + @TaxValue) - @Balance
			SET @Balance = 0	
			END
		ELSE
			BEGIN
			SET @PaidValue = 0
			SET @Balance = @Balance - (@InvoiceValue + @TaxValue)
			END
		
		IF @PaidValue > 0
			BEGIN
			SET @PaidTaxValue = CASE @RoundingCode 
									WHEN 0 THEN FORMAT((@PaidValue - (@PaidValue / (1 + @TaxRate))), '#.00')
									WHEN 1 THEN ROUND((@PaidValue - (@PaidValue / (1 + @TaxRate))), 2, 1)
								END
			SET @PaidInvoiceValue = @PaidValue - @PaidTaxValue
			END
		ELSE
			BEGIN
			SET @PaidInvoiceValue = 0
			SET @PaidTaxValue = 0
			END
			
		IF ISNULL(@TaskCode, '') = ''
			BEGIN
			UPDATE    Invoice.tbItem
			SET              PaidValue = @PaidInvoiceValue, PaidTaxValue = @PaidTaxValue
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (CashCode = @CashCode)
			END
		ELSE
			BEGIN
			UPDATE   Invoice.tbTask
			SET              PaidValue = @PaidInvoiceValue, PaidTaxValue = @PaidTaxValue
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (TaskCode = @TaskCode)				
			END

		FETCH NEXT FROM curInv INTO @InvoiceNumber, @TaskCode, @CashCode, @InvoiceValue, @TaxValue, @TaxRate, @RoundingCode
		END
	
	CLOSE curInv;
	DEALLOCATE curInv;

/**************************************************/
		
	--update invoice paid
	WITH invoices AS
	(
		SELECT        InvoiceNumber, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
		FROM            Invoice.tbTask
		UNION
		SELECT        InvoiceNumber, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
		FROM            Invoice.tbItem
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
						selected ON Invoice.tbInvoice.InvoiceNumber = selected.InvoiceNumber
	WHERE tbInvoice.AccountCode = @AccountCode;

	IF (@CashModeCode = 1)
		SET @Balance = @Balance * -1
		
	UPDATE    Org.tbOrg
	SET              CurrentBalance = OpeningBalance - @Balance
	WHERE     (AccountCode = @AccountCode)
	
	COMMIT TRAN OrgRebuild
	SET NOCOUNT OFF;
GO

DROP VIEW IF EXISTS Org.vwRebuildInvoicedItems;
DROP VIEW IF EXISTS Org.vwRebuildInvoicedTasks;
DROP VIEW IF EXISTS Org.vwRebuildInvoices;
DROP VIEW IF EXISTS Org.vwRebuildInvoiceTotals;
DROP FUNCTION IF EXISTS Org.fnRebuildInvoiceItems;
DROP FUNCTION IF EXISTS Org.fnRebuildInvoiceTasks;
GO

ALTER PROCEDURE [Invoice].[proc_Total] 
	(
	@InvoiceNumber nvarchar(20)
	)
  AS
	UPDATE Invoice.tbItem
	SET TaxValue = CASE App.tbTaxCode.RoundingCode 
			WHEN 0 THEN FORMAT(Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, '#.00')
			WHEN 1 THEN ROUND( Invoice.tbItem.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END
	FROM         Invoice.tbItem INNER JOIN
	                      App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
	                      Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
	WHERE Invoice.tbInvoice.InvoiceNumber = @InvoiceNumber;

	UPDATE Invoice.tbTask
	SET TaxValue = CASE App.tbTaxCode.RoundingCode 
			WHEN 0 THEN FORMAT(Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, '#.00')
			WHEN 1 THEN ROUND( Invoice.tbTask.InvoiceValue * App.tbTaxCode.TaxRate, 2, 1) END
	FROM         Invoice.tbTask INNER JOIN
	                      App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode INNER JOIN
	                      Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber
	WHERE     ( Invoice.tbTask.InvoiceNumber = @InvoiceNumber);

	WITH totals AS
	(
		SELECT InvoiceNumber, SUM(InvoiceValue) AS InvoiceValue, 
			SUM(TaxValue) AS TaxValue,
			SUM(PaidValue) AS PaidValue, 
			SUM(PaidTaxValue) AS PaidTaxValue
		FROM         Invoice.tbTask
		GROUP BY InvoiceNumber
		HAVING      (InvoiceNumber = @InvoiceNumber)
		UNION
		SELECT InvoiceNumber, SUM(InvoiceValue) AS InvoiceValue, 
			SUM(TaxValue) AS TaxValue,
			SUM(PaidValue) AS PaidValue, 
			SUM(PaidTaxValue) AS PaidTaxValue
		FROM         Invoice.tbItem
		GROUP BY InvoiceNumber
		HAVING      (InvoiceNumber = @InvoiceNumber)
	), grand_total AS
	(
		SELECT InvoiceNumber, ISNULL(SUM(InvoiceValue), 0) AS InvoiceValue, 
			ISNULL(SUM(TaxValue), 0) AS TaxValue, 
			ISNULL(SUM(PaidValue), 0) AS PaidValue, 
			ISNULL(SUM(PaidTaxValue), 0) AS PaidTaxValue
		FROM totals
		GROUP BY InvoiceNumber
	) 
	UPDATE    Invoice.tbInvoice
	SET InvoiceValue = grand_total.InvoiceValue, TaxValue = grand_total.TaxValue,
		PaidValue = grand_total.PaidValue, PaidTaxValue = grand_total.PaidTaxValue,
		InvoiceStatusCode = CASE 
				WHEN grand_total.PaidValue >= grand_total.InvoiceValue THEN 3 
				WHEN grand_total.PaidValue > 0 THEN 2 
				ELSE 1 END
	FROM Invoice.tbInvoice INNER JOIN grand_total ON Invoice.tbInvoice.InvoiceNumber = grand_total.InvoiceNumber;
		
	RETURN
GO
ALTER PROCEDURE [Org].[proc_PaymentPostMisc]
	(
	@PaymentCode nvarchar(20) 
	)
 AS
DECLARE 
	@InvoiceNumber nvarchar(20), 
	@NextNumber int, 
	@InvoiceTypeCode smallint;

	SELECT @InvoiceTypeCode = CASE WHEN PaidInValue != 0 THEN 0 ELSE 2 END 
	FROM         Org.tbPayment
	WHERE     (PaymentCode = @PaymentCode)
	
	SELECT @NextNumber = NextNumber
	FROM Invoice.tbType
	WHERE InvoiceTypeCode = @InvoiceTypeCode;
		
	SET @InvoiceNumber = FORMAT(@NextNumber, '000000') + '.' + (SELECT UserId FROM Usr.vwCredentials);

	WHILE EXISTS (SELECT     InvoiceNumber
	              FROM         Invoice.tbInvoice
	              WHERE     (InvoiceNumber = @InvoiceNumber))
		BEGIN
		SET @NextNumber += @NextNumber 
		SET @InvoiceNumber = FORMAT(@NextNumber, '000000') + '.' + (SELECT UserId FROM Usr.vwCredentials);
		END
			
	UPDATE    Invoice.tbType
	SET              NextNumber = @NextNumber + 1
	WHERE     (InvoiceTypeCode = @InvoiceTypeCode)

	UPDATE    Org.tbPayment
	SET		PaymentStatusCode = 1,
		TaxInValue = (CASE App.tbTaxCode.RoundingCode WHEN 0 THEN FORMAT(Org.tbPayment.PaidInValue - ( Org.tbPayment.PaidInValue / (1 + App.tbTaxCode.TaxRate)), '#.00') WHEN 1 THEN ROUND(Org.tbPayment.PaidInValue - ( Org.tbPayment.PaidInValue / (1 + App.tbTaxCode.TaxRate)), 2, 1) END), 
		TaxOutValue = (CASE App.tbTaxCode.RoundingCode WHEN 0 THEN FORMAT(Org.tbPayment.PaidOutValue - ( Org.tbPayment.PaidOutValue / (1 + App.tbTaxCode.TaxRate)), '#.00') WHEN 1 THEN ROUND(Org.tbPayment.PaidOutValue - ( Org.tbPayment.PaidOutValue / (1 + App.tbTaxCode.TaxRate)), 2, 1) END)
	FROM         Org.tbPayment INNER JOIN
	                      App.tbTaxCode ON Org.tbPayment.TaxCode = App.tbTaxCode.TaxCode
	WHERE     (PaymentCode = @PaymentCode)

	INSERT INTO Invoice.tbInvoice
							 (InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, CollectOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, Printed)
	SELECT        @InvoiceNumber AS InvoiceNumber, Org.tbPayment.UserId, Org.tbPayment.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, 3 AS InvoiceStatusCode, 
							Org.tbPayment.PaidOn, Org.tbPayment.PaidOn AS CollectOn, 
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
	WHERE        ( Org.tbPayment.PaymentCode = @PaymentCode);


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
	WHERE     ( Org.tbPayment.PaymentCode = @PaymentCode);

	UPDATE Invoice.tbItem
	SET PaidValue = InvoiceValue, PaidTaxValue = TaxValue
	WHERE InvoiceNumber = @InvoiceNumber;

	UPDATE  Org.tbAccount
	SET CurrentBalance = CASE WHEN PaidInValue > 0 THEN Org.tbAccount.CurrentBalance + PaidInValue ELSE Org.tbAccount.CurrentBalance - PaidOutValue END
	FROM         Org.tbAccount INNER JOIN
						  Org.tbPayment ON Org.tbAccount.CashAccountCode = Org.tbPayment.CashAccountCode
	WHERE Org.tbPayment.PaymentCode = @PaymentCode

	
	RETURN
GO
ALTER VIEW [Invoice].[vwOutstandingTasks]
AS
SELECT        Invoice.tbTask.InvoiceNumber, Invoice.tbTask.TaskCode, Invoice.tbTask.CashCode, Invoice.tbTask.TaxCode, (Invoice.tbTask.InvoiceValue + Invoice.tbTask.TaxValue) 
                         - (Invoice.tbTask.PaidValue + Invoice.tbTask.PaidTaxValue) AS OutstandingValue, CASE WHEN InvoiceValue = 0 THEN 0 ELSE TaxValue / InvoiceValue END AS TaxRate, App.tbTaxCode.RoundingCode
FROM            Invoice.tbTask INNER JOIN
                         App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode
GO
ALTER VIEW [Invoice].[vwOutstandingItems]
AS
SELECT        Invoice.tbItem.InvoiceNumber, '' AS TaskCode, Invoice.tbItem.CashCode, Invoice.tbItem.TaxCode, (Invoice.tbItem.InvoiceValue + Invoice.tbItem.TaxValue) - (Invoice.tbItem.PaidValue + Invoice.tbItem.PaidTaxValue)
                          AS OutstandingValue, CASE WHEN InvoiceValue = 0 THEN 0 ELSE TaxValue / InvoiceValue END AS TaxRate, App.tbTaxCode.RoundingCode
FROM            Invoice.tbItem INNER JOIN
                         App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode
GO
ALTER VIEW [Invoice].[vwOutstandingBase]
AS
SELECT        InvoiceNumber AS InvoiceNumber, TaskCode AS TaskCode, CashCode AS CashCode, TaxCode AS TaxCode, OutstandingValue, TaxRate, RoundingCode
FROM            Invoice.vwOutstandingItems
UNION
SELECT        InvoiceNumber AS InvoiceNumber, TaskCode AS TaskCode, CashCode AS CashCode, TaxCode AS TaxCode, OutstandingValue, TaxRate, RoundingCode
FROM            Invoice.vwOutstandingTasks
GO
ALTER VIEW [Invoice].[vwOutstanding]
AS
SELECT        TOP (100) PERCENT Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.CollectOn, Invoice.tbInvoice.InvoiceNumber, Invoice.vwOutstandingBase.TaskCode, Invoice.tbInvoice.InvoiceStatusCode, 
                         Invoice.tbType.CashModeCode, Invoice.vwOutstandingBase.CashCode, Invoice.vwOutstandingBase.TaxCode, Invoice.vwOutstandingBase.TaxRate, Invoice.vwOutstandingBase.RoundingCode, 
                         CASE WHEN Invoice.tbType.CashModeCode = 0 THEN OutstandingValue * - 1 ELSE OutstandingValue END AS ItemValue
FROM            Invoice.vwOutstandingBase INNER JOIN
                         Invoice.tbInvoice ON Invoice.vwOutstandingBase.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode
WHERE        (Invoice.tbInvoice.InvoiceStatusCode = 1) OR
                         (Invoice.tbInvoice.InvoiceStatusCode = 2)
GO

ALTER PROCEDURE [Org].[proc_PaymentPostPaidIn]
	(
	@PaymentCode nvarchar(20),
	@CurrentBalance money output 
	)
 AS
--invoice valued
DECLARE @InvoiceNumber nvarchar(20)
DECLARE @TaskCode nvarchar(20)
DECLARE @TaxRate real
DECLARE @ItemValue money
DECLARE @RoundingCode smallint

--calc values
DECLARE @PaidValue money
DECLARE @PaidTaxValue money
DECLARE @TaxInValue money = 0
DECLARE @TaxOutValue money = 0

--default payment codes
DECLARE @CashCode nvarchar(50)
DECLARE @TaxCode nvarchar(10)

	
	DECLARE curPaidIn CURSOR LOCAL FOR
		SELECT     Invoice.vwOutstanding.InvoiceNumber, Invoice.vwOutstanding.TaskCode, Invoice.vwOutstanding.CashCode, Invoice.vwOutstanding.TaxCode, 
		                      Invoice.vwOutstanding.TaxRate, Invoice.vwOutstanding.ItemValue, Invoice.vwOutstanding.RoundingCode
		FROM         Invoice.vwOutstanding INNER JOIN
		                      Org.tbPayment ON Invoice.vwOutstanding.AccountCode = Org.tbPayment.AccountCode
		WHERE     ( Org.tbPayment.PaymentCode = @PaymentCode)
		ORDER BY Invoice.vwOutstanding.CashModeCode, Invoice.vwOutstanding.CollectOn

	OPEN curPaidIn
	FETCH NEXT FROM curPaidIn INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode
	WHILE @@FETCH_STATUS = 0 and @CurrentBalance < 0
		BEGIN
		IF (@CurrentBalance + @ItemValue) > 0
			SET @ItemValue = @CurrentBalance * -1

		SET @PaidTaxValue = (CASE @RoundingCode WHEN 0 THEN FORMAT(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), '#.00') WHEN 1 THEN ROUND(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), 2, 1) END)
		SET @PaidValue = ABS(@ItemValue) - @PaidTaxValue
				
		SET @CurrentBalance = @CurrentBalance + @ItemValue
		
		IF @TaskCode IS NULL
			BEGIN
			UPDATE    Invoice.tbItem
			SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (CashCode = @CashCode)
			END
		ELSE
			BEGIN
			UPDATE   Invoice.tbTask
			SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (TaskCode = @TaskCode)				
			END

		EXEC Invoice.proc_Total @InvoiceNumber
		        		  
		SET @TaxInValue += CASE WHEN @ItemValue > 0 THEN @PaidTaxValue ELSE 0 END
		SET @TaxOutValue += CASE WHEN @ItemValue < 0 THEN @PaidTaxValue ELSE 0 END	
				
		FETCH NEXT FROM curPaidIn INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode
		END
	
	CLOSE curPaidIn
	DEALLOCATE curPaidIn
	
	--output new org current balance
	IF @CurrentBalance >= 0
		SET @CurrentBalance = 0
	ELSE
		SET @CurrentBalance = @CurrentBalance * -1

	
	IF NOT @CashCode IS NULL
		BEGIN
		UPDATE    Org.tbPayment
		SET      PaymentStatusCode = 1, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
			CashCode = ISNULL(@CashCode, Org.tbPayment.CashCode), 
			TaxCode = ISNULL(@TaxCode, Org.tbPayment.TaxCode)
		WHERE     (PaymentCode = @PaymentCode)
		END

			
	RETURN

GO


ALTER PROCEDURE [Org].[proc_PaymentPostPaidOut]
	(
	@PaymentCode nvarchar(20),
	@CurrentBalance money output 
	)
 AS
--invoice values
DECLARE @InvoiceNumber nvarchar(20)
DECLARE @TaskCode nvarchar(20)
DECLARE @TaxRate real
DECLARE @ItemValue money
DECLARE @RoundingCode smallint

--calc values
DECLARE @PaidValue money
DECLARE @PaidTaxValue money
DECLARE @TaxInValue money = 0
DECLARE @TaxOutValue money = 0

--default payment codes
DECLARE @CashCode nvarchar(50)
DECLARE @TaxCode nvarchar(10)


	
	DECLARE curPaidOut CURSOR LOCAL FOR
		SELECT     Invoice.vwOutstanding.InvoiceNumber, Invoice.vwOutstanding.TaskCode, Invoice.vwOutstanding.CashCode, Invoice.vwOutstanding.TaxCode, 
		                      Invoice.vwOutstanding.TaxRate, Invoice.vwOutstanding.ItemValue, Invoice.vwOutstanding.RoundingCode
		FROM         Invoice.vwOutstanding INNER JOIN
		                      Org.tbPayment ON Invoice.vwOutstanding.AccountCode = Org.tbPayment.AccountCode
		WHERE     ( Org.tbPayment.PaymentCode = @PaymentCode)
		ORDER BY Invoice.vwOutstanding.CashModeCode DESC, Invoice.vwOutstanding.CollectOn

	OPEN curPaidOut
	FETCH NEXT FROM curPaidOut INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode
	WHILE @@FETCH_STATUS = 0 and @CurrentBalance > 0
		BEGIN
		IF (@CurrentBalance + @ItemValue) < 0
			SET @ItemValue = @CurrentBalance * -1

		SET @PaidTaxValue = (CASE @RoundingCode WHEN 0 THEN FORMAT(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), '#.00') WHEN 1 THEN ROUND(ABS(@ItemValue) - (ABS(@ItemValue) / (1 + @TaxRate)), 2, 1) END)
		SET @PaidValue = ABS(@ItemValue) - @PaidTaxValue
				
		SET @CurrentBalance = @CurrentBalance + @ItemValue
		
		IF @TaskCode IS NULL
			BEGIN
			UPDATE    Invoice.tbItem
			SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (CashCode = @CashCode)
			END
		ELSE
			BEGIN
			UPDATE   Invoice.tbTask
			SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (TaskCode = @TaskCode)				
			END

		EXEC Invoice.proc_Total @InvoiceNumber
		        		  
		SET @TaxInValue += CASE WHEN @ItemValue > 0 THEN @PaidTaxValue ELSE 0 END
		SET @TaxOutValue += CASE WHEN @ItemValue < 0 THEN @PaidTaxValue ELSE 0 END	
				
		FETCH NEXT FROM curPaidOut INTO @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue, @RoundingCode
		END
		
	CLOSE curPaidOut
	DEALLOCATE curPaidOut
	
	--output new org current balance
	IF @CurrentBalance <= 0
		SET @CurrentBalance = 0
	ELSE
		SET @CurrentBalance = @CurrentBalance * -1

	IF NOT @CashCode IS NULL
		BEGIN
		UPDATE    Org.tbPayment
		SET      PaymentStatusCode = 1, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
			CashCode = ISNULL(@CashCode, Org.tbPayment.CashCode), 
			TaxCode = ISNULL(@TaxCode, Org.tbPayment.TaxCode)
		WHERE     (PaymentCode = @PaymentCode)
		END
	
	RETURN

GO

CREATE PROCEDURE Usr.proc_MenuItemDelete( @EntryId int )
AS
	BEGIN TRAN

	DELETE FROM Usr.tbMenuEntry
	WHERE Command = 1 AND Argument = (SELECT FolderId FROM Usr.tbMenuEntry menu WHERE Command = 0 AND menu.EntryId = @EntryId);

	 WITH root_folder AS
	 (
		 SELECT FolderId 
		 FROM Usr.tbMenuEntry menu
		 WHERE Command = 0 AND menu.EntryId = @EntryId
	), child_folders AS
	(
		SELECT CAST(Argument AS smallint) AS FolderId
		FROM Usr.tbMenuEntry sub_folder 
		JOIN root_folder ON sub_folder.FolderId = root_folder.FolderId
		WHERE Command = 1 
		UNION ALL
		SELECT CAST(Argument AS smallint) AS FolderId
		FROM child_folders p 
			JOIN Usr.tbMenuEntry m ON p.FolderId = m.FolderId
		WHERE Command = 1
	), folders AS
	(
		select FolderId from root_folder
		UNION
		select FolderId from child_folders
	)
	DELETE Usr.tbMenuEntry 
	FROM Usr.tbMenuEntry JOIN folders ON Usr.tbMenuEntry.FolderId = folders.FolderId

	DELETE FROM Usr.tbMenuEntry WHERE EntryId = @EntryId;

	COMMIT TRAN

	RETURN
GO


ALTER TABLE Activity.tbActivity WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Activity.tbAttribute WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Activity.tbFlow WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Activity.tbOp WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE App.tbBucket WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE App.tbBucketInterval WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE App.tbCalendar WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE App.tbCalendarHoliday WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE App.tbCodeExclusion WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE App.tbDoc WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE App.tbDocSpool WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE App.tbOptions WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE App.tbRegister WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE App.tbTaxCode WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE App.tbUom WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE App.tbYear WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE App.tbYearPeriod WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Cash.tbCategory WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Cash.tbCategoryExp WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Cash.tbCategoryTotal WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Cash.tbCode WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Cash.tbPeriod WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Invoice.tbInvoice WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Invoice.tbItem WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Invoice.tbTask WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Org.tbAccount WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Org.tbAddress WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Org.tbContact WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Org.tbDoc WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Org.tbPayment WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Org.tbSector WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Org.tbType WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Task.tbAttribute WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Task.tbDoc WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Task.tbFlow WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Task.tbOp WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Task.tbQuote WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Task.tbTask WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Usr.tbMenu WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Usr.tbMenuEntry WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Usr.tbMenuUser WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
ALTER TABLE Usr.tbUser WITH NOCHECK ADD RowVer TIMESTAMP NOT NULL;
GO
DROP TABLE IF EXISTS [dbo].[App.tbDocClass]
GO
CREATE TABLE App.tbDocClass(
	DocClassCode smallint NOT NULL,
	DocClass nvarchar(50) NOT NULL,
 CONSTRAINT PK_App_tbDocClass PRIMARY KEY CLUSTERED 
(
	DocClassCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT INTO App.tbDocClass (DocClassCode, DocClass) VALUES (0, 'Product'), (1, 'Money');
GO
ALTER TABLE App.tbDocType WITH NOCHECK ADD
	DocClassCode smallint NOT NULL CONSTRAINT DF_App_tbDocType_DocClassCode DEFAULT (0);
GO
UPDATE App.tbDocType
SET DocClassCode = CASE WHEN DocTypeCode < 4 THEN 0 ELSE 1 END;
GO
ALTER TABLE App.tbDocType  WITH CHECK ADD  CONSTRAINT FK_App_tbDocType_App_tbDocClass FOREIGN KEY(DocClassCode)
REFERENCES App.tbDocClass (DocClassCode)
GO
ALTER TABLE App.tbDocType CHECK CONSTRAINT FK_App_tbDocType_App_tbDocClass
GO

CREATE NONCLUSTERED INDEX IX_Invoice_tbTask_TaxCode ON [Invoice].[tbTask] ([TaxCode]) INCLUDE ([InvoiceValue],[TaxValue]);
CREATE NONCLUSTERED INDEX IX_Invoice_tbItem_TaxCode ON [Invoice].[tbItem] ([TaxCode]) INCLUDE ([InvoiceValue],[TaxValue]);
GO
/*****************************************/
ALTER TABLE Org.tbPayment DROP CONSTRAINT DF_Org_tbPayment_PaymentStatusCode;
ALTER TABLE Org.tbPayment ADD  CONSTRAINT DF_Org_tbPayment_PaymentStatusCode DEFAULT (0) FOR PaymentStatusCode;
GO
ALTER TABLE Invoice.tbInvoice WITH NOCHECK ADD
	ExpectedOn DATETIME NOT NULL CONSTRAINT DF_Invoice_tbInvoice_ExpectedOn DEFAULT (DATEADD(DAY, 1, CAST(CURRENT_TIMESTAMP AS DATE)));
GO
UPDATE Invoice.tbInvoice SET ExpectedOn = CollectOn;
GO
ALTER TABLE [Invoice].[tbInvoice] DROP CONSTRAINT [DF_Invoice_tb_InvoicedOn];
ALTER TABLE [Invoice].[tbInvoice] DROP CONSTRAINT [DF_Invoice_tb_CollectOn];
ALTER TABLE [Org].[tbPayment] DROP CONSTRAINT [DF_Org_tbPayment_PaidOn];

ALTER TABLE [Invoice].[tbInvoice] ADD  CONSTRAINT [DF_Invoice_tb_InvoicedOn]  DEFAULT (CAST(CURRENT_TIMESTAMP AS DATE)) FOR [InvoicedOn];
ALTER TABLE [Invoice].[tbInvoice] ADD  CONSTRAINT [DF_Invoice_tb_CollectOn]  DEFAULT (DATEADD(DAY, 1, CAST(CURRENT_TIMESTAMP AS DATE))) FOR [CollectOn];
ALTER TABLE [Org].[tbPayment] ADD  CONSTRAINT [DF_Org_tbPayment_PaidOn]  DEFAULT ((CAST(CURRENT_TIMESTAMP AS DATE))) FOR [PaidOn];
GO
CREATE NONCLUSTERED INDEX IX_Invoice_tbInvoice_ExpectedOn ON Invoice.tbInvoice (ExpectedOn, InvoiceTypeCode, InvoiceStatusCode);
GO
ALTER VIEW [Invoice].[vwRegisterPurchasesOverdue]
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
                         Invoice.tbType.InvoiceType, (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) AS UnpaidValue, 
						DATEDIFF(DD, CURRENT_TIMESTAMP, Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.CollectOn, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, 
                         Invoice.tbInvoice.Notes
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
WHERE        (Invoice.tbInvoice.InvoiceTypeCode > 1) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
ORDER BY Invoice.tbInvoice.ExpectedOn;
GO
ALTER VIEW [Invoice].[vwRegisterSalesOverdue]
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
                         Invoice.tbType.InvoiceType, (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) AS UnpaidValue, DATEDIFF(DD, CURRENT_TIMESTAMP, 
                         Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.CollectOn, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, 
                         Invoice.tbInvoice.Notes
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
WHERE        (Invoice.tbInvoice.InvoiceTypeCode < 2) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
ORDER BY Invoice.tbInvoice.ExpectedOn;
GO
ALTER VIEW [Invoice].[vwAgedDebtPurchases]
AS
SELECT TOP 100 PERCENT Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
                         Invoice.tbType.InvoiceType, (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) AS UnpaidValue, DATEDIFF(DD, CURRENT_TIMESTAMP, 
                         Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.CollectOn, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, 
                         Invoice.tbInvoice.Notes
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
WHERE        (Invoice.tbInvoice.InvoiceTypeCode > 1) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
ORDER BY Invoice.tbInvoice.ExpectedOn;
GO
ALTER VIEW [Invoice].[vwAgedDebtSales]
AS
SELECT TOP 100 PERCENT  Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.AccountCode, Org.tbOrg.AccountName, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbInvoice.InvoiceStatusCode, Invoice.tbStatus.InvoiceStatus, 
                         Invoice.tbType.InvoiceType, (Invoice.tbInvoice.InvoiceValue + Invoice.tbInvoice.TaxValue) - (Invoice.tbInvoice.PaidValue + Invoice.tbInvoice.PaidTaxValue) AS UnpaidValue, DATEDIFF(DD, CURRENT_TIMESTAMP, 
                         Invoice.tbInvoice.InvoicedOn) AS UnpaidDays, Invoice.tbInvoice.InvoicedOn, Invoice.tbInvoice.CollectOn, Invoice.tbInvoice.ExpectedOn, Invoice.tbInvoice.InvoiceValue, Invoice.tbInvoice.TaxValue, Invoice.tbInvoice.PaymentTerms, 
                         Invoice.tbInvoice.Notes
FROM            Invoice.tbInvoice INNER JOIN
                         Invoice.tbStatus ON Invoice.tbInvoice.InvoiceStatusCode = Invoice.tbStatus.InvoiceStatusCode INNER JOIN
                         Invoice.tbType ON Invoice.tbInvoice.InvoiceTypeCode = Invoice.tbType.InvoiceTypeCode INNER JOIN
                         Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode
WHERE        (Invoice.tbInvoice.InvoiceTypeCode < 2) AND (Invoice.tbInvoice.InvoiceStatusCode < 3)
ORDER BY Invoice.tbInvoice.ExpectedOn;
GO
ALTER FUNCTION [Cash].[fnStatementCompany]()
RETURNS @tbStatement TABLE (
	ReferenceCode nvarchar(20), 
	AccountCode nvarchar(10),
	TransactOn datetime,
	CashEntryTypeCode smallint,
	PayOut money,
	PayIn money,
	Balance money,
	CashCode nvarchar(50)
	) 
   AS
	BEGIN
	DECLARE @ReferenceCode nvarchar(20) 
	DECLARE @CashCode nvarchar(50)
	DECLARE @AccountCode nvarchar(10)
	DECLARE @TransactOn datetime
	DECLARE @CashEntryTypeCode smallint
	DECLARE @PayOut money
	DECLARE @PayIn money
	DECLARE @Balance money

	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, CashCode, PayIn, PayOut)	
	SELECT     Invoice.tbItem.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.ExpectedOn, 1 AS CashEntryTypeCode, Invoice.tbItem.CashCode, 
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

	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, CashCode, PayIn, PayOut)		
	SELECT     Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.AccountCode, Invoice.tbInvoice.ExpectedOn, 1 AS CashEntryTypeCode, Invoice.tbTask.CashCode, 
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
		
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	SELECT     ReferenceCode, AccountCode, PaymentOn, CashEntryTypeCode, PayIn, PayOut, CashCode
	FROM         Cash.vwStatementTasksConfirmed			
	
	--Corporation Tax
	IF EXISTS (SELECT        Org.tbAccount.CashAccountCode
	           FROM            Cash.tbTaxType INNER JOIN
	                                    Org.tbAccount ON Cash.tbTaxType.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
	                                    Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
	           WHERE        ( Cash.tbTaxType.TaxTypeCode = 0))
		BEGIN
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
		SELECT ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
		FROM Cash.fnStatementTaxEntries(1)
		ORDER BY TransactOn		
		END

	--VAT
	IF EXISTS (SELECT        Org.tbAccount.CashAccountCode
	           FROM            Cash.tbTaxType INNER JOIN
	                                    Org.tbAccount ON Cash.tbTaxType.CashAccountCode = Org.tbAccount.CashAccountCode INNER JOIN
	                                    Cash.tbCode ON Org.tbAccount.CashCode = Cash.tbCode.CashCode
	           WHERE        ( Cash.tbTaxType.TaxTypeCode = 1))
		BEGIN	
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
		SELECT ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
		FROM Cash.fnStatementTaxEntries(2)
		ORDER BY TransactOn		
		END

	SELECT @ReferenceCode = App.fnProfileText(3013)
	SET @Balance = Cash.fnCurrentBalance()	
	SELECT @TransactOn = DATEADD(d, -1, MIN(TransactOn)) FROM @tbStatement
	SELECT TOP 1 @AccountCode = AccountCode FROM App.tbOptions
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, Balance)
	VALUES (@ReferenceCode, @AccountCode, @TransactOn, 1, 0, 0, @Balance)
			
	DECLARE curSt cursor local for
		SELECT TransactOn, CashEntryTypeCode, ReferenceCode, PayIn, PayOut, CashCode
		FROM @tbStatement
		order by TransactOn, CashEntryTypeCode, ReferenceCode, CashCode

	OPEN curSt
	
	FETCH NEXT FROM curSt INTO @TransactOn, @CashEntryTypeCode, @ReferenceCode, @PayIn, @PayOut, @CashCode
	
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		SET @Balance = @Balance + @PayIn - @PayOut
		IF @CashCode IS NULL
			BEGIN
			UPDATE @tbStatement
			SET Balance = @Balance
			WHERE TransactOn = @TransactOn and CashEntryTypeCode = @CashEntryTypeCode and ReferenceCode = @ReferenceCode
			END
		ELSE
			BEGIN
			UPDATE @tbStatement
			SET Balance = @Balance
			WHERE TransactOn = @TransactOn and CashEntryTypeCode = @CashEntryTypeCode and ReferenceCode = @ReferenceCode and CashCode = @CashCode
			END
		FETCH NEXT FROM curSt INTO @TransactOn, @CashEntryTypeCode, @ReferenceCode, @PayIn, @PayOut, @CashCode
		END
	CLOSE curSt
	DEALLOCATE curSt
		
	RETURN
	END
GO
UPDATE App.tbOptions
SET SQLDataVersion = 3.03;
GO