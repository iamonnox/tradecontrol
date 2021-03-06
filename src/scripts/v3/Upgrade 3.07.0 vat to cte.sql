--VAT TAX RE-WRITE
go
ALTER  FUNCTION Cash.fnTaxTypeDueDates(@TaxTypeCode smallint)
RETURNS @tbDueDate TABLE (PayOn datetime, PayFrom datetime, PayTo datetime)
 AS
	BEGIN
 	DECLARE @MonthNumber smallint
		, @RecurrenceCode smallint
		, @MonthInterval smallint
		, @StartOn datetime
	
	SELECT @MonthNumber = MonthNumber, @RecurrenceCode = RecurrenceCode
	FROM Cash.tbTaxType
	WHERE TaxTypeCode = @TaxTypeCode
	
	SET @MonthInterval = CASE @RecurrenceCode
		WHEN 0 THEN 1
		WHEN 1 THEN 1
		WHEN 2 THEN 3
		WHEN 3 THEN 6
		WHEN 4 THEN 12
		END
				
	SELECT   @StartOn = MIN(StartOn)
	FROM         App.tbYearPeriod
	WHERE     (MonthNumber = @MonthNumber)
	ORDER BY MIN(StartOn)

	
	INSERT INTO @tbDueDate (PayOn) VALUES (@StartOn)
	
	SET @MonthNumber = CASE 
		WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
		ELSE (@MonthNumber + @MonthInterval) % 12
		END
	
	WHILE EXISTS(SELECT     MonthNumber
	             FROM         App.tbYearPeriod
	             WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber))
		BEGIN
		SELECT @StartOn = MIN(StartOn)
	    FROM         App.tbYearPeriod
	    WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber)
		ORDER BY MIN(StartOn)		
		INSERT INTO @tbDueDate (PayOn) VALUES (@StartOn)
		
		SET @MonthNumber = CASE 
			WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
			ELSE (@MonthNumber + @MonthInterval) % 12
			END
		
		END
		
	IF (@TaxTypeCode = 0)
		--CorporationTax
		BEGIN
		DECLARE @PayOn datetime, @PayFrom datetime

		SELECT @StartOn = StartOn, @PayFrom = StartOn, @MonthNumber = MonthNumber
		FROM App.tbYearPeriod
		WHERE StartOn = (SELECT MIN(StartOn) FROM App.tbYearPeriod)
	
		SET @MonthNumber = CASE 
			WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
			ELSE (@MonthNumber + @MonthInterval) % 12
			END
	
		WHILE EXISTS(SELECT     MonthNumber
					 FROM         App.tbYearPeriod
					 WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber))
			BEGIN
			SELECT @StartOn = MIN(StartOn)
			FROM         App.tbYearPeriod
			WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber)
			ORDER BY MIN(StartOn)		
		
			SELECT @PayOn = MIN(PayOn)
			FROM @tbDueDate
			WHERE PayOn >= @StartOn
			ORDER BY MIN(PayOn)
		
			UPDATE @tbDueDate
			SET PayTo = @StartOn, PayFrom = @PayFrom
			WHERE PayOn = @PayOn
		
			SET @PayFrom = @StartOn
		
			SET @MonthNumber = CASE 
				WHEN (@MonthNumber + @MonthInterval) <= 12 THEN @MonthNumber + @MonthInterval
				ELSE (@MonthNumber + @MonthInterval) % 12
				END
		
			END

		DELETE FROM @tbDueDate WHERE PayTo IS NULL

		END
	ELSE
		BEGIN

		WITH dd AS
		(
			SELECT PayOn, MIN(PayOn) OVER (ORDER BY PayOn ROWS 1 PRECEDING) AS PayFrom
			FROM @tbDueDate 
		)
		UPDATE @tbDueDate
		SET PayTo = dd.PayOn, PayFrom = dd.PayFrom
		FROM @tbDueDate tbDueDate JOIN dd ON tbDueDate.PayOn = dd.PayOn;

		UPDATE @tbDueDate
		SET PayFrom = DATEADD(MONTH, @MonthInterval * -1, PayTo)
		WHERE PayTo = (SELECT MIN(PayTo) FROM @tbDueDate);

		END		
	
	RETURN	
	END
go
CREATE OR ALTER VIEW Cash.vwTaxVatSummary
AS
	WITH vat_transactions AS
	(	
		SELECT  (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
				Invoice.tbInvoice.InvoiceNumber, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbItem.TaxCode, Invoice.tbItem.InvoiceValue, 
								 Invoice.tbItem.TaxValue, Org.tbOrg.ForeignJurisdiction, Invoice.tbItem.CashCode AS IdentityCode
		FROM            Invoice.tbItem INNER JOIN
								 Invoice.tbInvoice ON Invoice.tbItem.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
								 App.tbTaxCode ON Invoice.tbItem.TaxCode = App.tbTaxCode.TaxCode
		WHERE        (App.tbTaxCode.TaxTypeCode = 1)
		UNION
		SELECT  (SELECT TOP (1) p.StartOn FROM App.tbYearPeriod p WHERE (p.StartOn <= Invoice.tbInvoice.InvoicedOn) ORDER BY p.StartOn DESC) AS StartOn,  
					Invoice.tbTask.InvoiceNumber, Invoice.tbInvoice.InvoiceTypeCode, Invoice.tbTask.TaxCode, Invoice.tbTask.InvoiceValue, 
								 Invoice.tbTask.TaxValue, Org.tbOrg.ForeignJurisdiction, Invoice.tbTask.TaskCode AS IdentityCode
		FROM            Invoice.tbTask INNER JOIN
								 Invoice.tbInvoice ON Invoice.tbTask.InvoiceNumber = Invoice.tbInvoice.InvoiceNumber INNER JOIN
								 Org.tbOrg ON Invoice.tbInvoice.AccountCode = Org.tbOrg.AccountCode INNER JOIN
								 App.tbTaxCode ON Invoice.tbTask.TaxCode = App.tbTaxCode.TaxCode
		WHERE        (App.tbTaxCode.TaxTypeCode = 1)
	), vat_detail AS
	(
		SELECT        StartOn, TaxCode, 
								 CASE WHEN ForeignJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 0 THEN InvoiceValue WHEN 1 THEN
								  InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomeSales, 
								 CASE WHEN ForeignJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 2 THEN InvoiceValue WHEN 3 THEN
								  InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomePurchases, 
								 CASE WHEN ForeignJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 0 THEN InvoiceValue WHEN 1 THEN
								  InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportSales, 
								 CASE WHEN ForeignJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 2 THEN InvoiceValue WHEN 3 THEN
								  InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportPurchases, 
								 CASE WHEN ForeignJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 0 THEN TaxValue WHEN 1 THEN TaxValue
								  * - 1 ELSE 0 END ELSE 0 END AS HomeSalesVat, 
								 CASE WHEN ForeignJurisdiction = 0 THEN CASE InvoiceTypeCode WHEN 2 THEN TaxValue WHEN 3 THEN TaxValue
								  * - 1 ELSE 0 END ELSE 0 END AS HomePurchasesVat, 
								 CASE WHEN ForeignJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 0 THEN TaxValue WHEN 1 THEN TaxValue
								  * - 1 ELSE 0 END ELSE 0 END AS ExportSalesVat, 
								 CASE WHEN ForeignJurisdiction != 0 THEN CASE InvoiceTypeCode WHEN 2 THEN TaxValue WHEN 3 THEN TaxValue
								  * - 1 ELSE 0 END ELSE 0 END AS ExportPurchasesVat
		FROM  vat_transactions
	), vatcode_summary AS
	(
		SELECT        StartOn, TaxCode, SUM(HomeSales) AS HomeSales, SUM(HomePurchases) AS HomePurchases, SUM(ExportSales) AS ExportSales, SUM(ExportPurchases) AS ExportPurchases, SUM(HomeSalesVat) 
								AS HomeSalesVat, SUM(HomePurchasesVat) AS HomePurchasesVat, SUM(ExportSalesVat) AS ExportSalesVat, SUM(ExportPurchasesVat) AS ExportPurchasesVat
		FROM            vat_detail
		GROUP BY StartOn, TaxCode
	)
	SELECT   StartOn, 
		TaxCode, HomeSales, HomePurchases, ExportSales, ExportPurchases, HomeSalesVat, HomePurchasesVat, ExportSalesVat, ExportPurchasesVat
			, (HomeSalesVat + ExportSalesVat) - (HomePurchasesVat + ExportPurchasesVat) AS VatDue
	FROM vatcode_summary s;
go

ALTER VIEW Cash.vwTaxVatTotals
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
		SELECT VatStartOn AS StartOn,
			SUM(HomeSales) AS HomeSales, SUM(HomePurchases) AS HomePurchases, SUM(ExportSales) AS ExportSales, SUM(ExportPurchases) AS ExportPurchases, 
			SUM(HomeSalesVat) AS HomeSalesVat, SUM(HomePurchasesVat) AS HomePurchasesVat, 
			SUM(ExportSalesVat) AS ExportSalesVat, SUM(ExportPurchasesVat) AS ExportPurchasesVat, SUM(VatDue) AS VatDue
		FROM Cash.vwTaxVatSummary vatCodeDue JOIN vatPeriod ON vatCodeDue.StartOn = vatPeriod.StartOn
		GROUP BY VatStartOn
	), vat_adjustments AS
	(
		SELECT y.YearNumber, y.[Description], 
			VatStartOn AS StartOn, MAX(MonthNumber) AS MonthNumber, SUM(VatAdjustment) AS VatAdjustment
		FROM vatPeriod p JOIN App.tbYear y ON p.YearNumber = y.YearNumber 
		GROUP BY y.YearNumber, y.[Description], VatStartOn
	)
	SELECT a.YearNumber, a.[Description], CONCAT(m.[MonthName], ' ', FORMAT(YEAR(r.StartOn), '0')) AS [Period], r.StartOn, HomeSales, HomePurchases, ExportSales, ExportPurchases, HomeSalesVat, HomePurchasesVat, ExportSalesVat, ExportPurchasesVat,
		a.VatAdjustment, VatDue - a.VatAdjustment AS VatDue
	FROM vat_results r JOIN vat_adjustments a ON r.StartOn = a.StartOn
		JOIN App.tbMonth m ON a.MonthNumber = m.MonthNumber;
go	
ALTER VIEW [Cash].[vwTaxVatStatement]
AS
	WITH vat_dates AS
	(
		SELECT PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(1)
	), vatPeriod AS
	(
		SELECT        StartOn, 
			(SELECT PayTo FROM vat_dates WHERE StartOn >= PayFrom AND StartOn < PayTo) AS VatStartOn, VatAdjustment
		FROM            App.tbYearPeriod 
	), vat_results AS
	(
		SELECT VatStartOn AS StartOn,
			SUM(HomeSales) AS HomeSales, SUM(HomePurchases) AS HomePurchases, SUM(ExportSales) AS ExportSales, SUM(ExportPurchases) AS ExportPurchases, 
			SUM(HomeSalesVat) AS HomeSalesVat, SUM(HomePurchasesVat) AS HomePurchasesVat, 
			SUM(ExportSalesVat) AS ExportSalesVat, SUM(ExportPurchasesVat) AS ExportPurchasesVat, SUM(VatDue) AS VatDue
		FROM Cash.vwTaxVatSummary vatCodeDue JOIN vatPeriod ON vatCodeDue.StartOn = vatPeriod.StartOn
		GROUP BY VatStartOn
	), vat_adjustments AS
	(
		SELECT VatStartOn AS StartOn, SUM(VatAdjustment) AS VatAdjustment
		FROM vatPeriod
		GROUP BY VatStartOn
	), vat_unordered AS
	(
		SELECT r.StartOn, VatDue - a.VatAdjustment AS VatDue, 0 As VatPaid		
		FROM vat_results r JOIN vat_adjustments a ON r.StartOn = a.StartOn
			UNION
		SELECT     Org.tbPayment.PaidOn, 0 As VatDue, ( Org.tbPayment.PaidOutValue * -1) + Org.tbPayment.PaidInValue AS VatPaid
		FROM         Org.tbPayment INNER JOIN
							  App.vwVatCashCode ON Org.tbPayment.CashCode = App.vwVatCashCode.CashCode	
	), vat_ordered AS
	(
		SELECT ROW_NUMBER() OVER (ORDER BY StartOn, VatDue) AS RowNumber,
			StartOn, VatDue, VatPaid
		FROM vat_unordered
	), vat_statement AS
	(
		SELECT RowNumber, StartOn, VatDue, VatPaid,
			SUM(VatDue+VatPaid) OVER (ORDER BY RowNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
		FROM vat_ordered
	)
	SELECT RowNumber, StartOn, VatDue, VatPaid, Balance
	FROM vat_statement
	WHERE StartOn >= (SELECT MIN(StartOn) FROM App.tbYearPeriod p JOIN App.tbYear y ON p.YearNumber = y.YearNumber  WHERE y.CashStatusCode < 3);
go
CREATE OR ALTER VIEW Cash.vwTaxVatDetails
AS
SELECT        App.tbYearPeriod.YearNumber, App.tbYear.Description, CONCAT(App.tbMonth.MonthName, SPACE(1), YEAR(App.tbYearPeriod.StartOn)) AS PeriodName, Cash.vwTaxVatSummary.StartOn, 
                         Cash.vwTaxVatSummary.TaxCode, Cash.vwTaxVatSummary.HomeSales, Cash.vwTaxVatSummary.HomePurchases, Cash.vwTaxVatSummary.ExportSales, Cash.vwTaxVatSummary.ExportPurchases, 
                         Cash.vwTaxVatSummary.HomeSalesVat, Cash.vwTaxVatSummary.HomePurchasesVat, Cash.vwTaxVatSummary.ExportSalesVat, Cash.vwTaxVatSummary.ExportPurchasesVat, Cash.vwTaxVatSummary.VatDue                         
FROM            Cash.vwTaxVatSummary INNER JOIN
                         App.tbYearPeriod INNER JOIN
                         App.tbMonth ON App.tbYearPeriod.MonthNumber = App.tbMonth.MonthNumber ON Cash.vwTaxVatSummary.StartOn = App.tbYearPeriod.StartOn INNER JOIN
                         App.tbYear ON App.tbYearPeriod.YearNumber = App.tbYear.YearNumber;
go
ALTER PROCEDURE Cash.proc_VatBalance(@Balance money output)
 AS
  	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		SELECT TOP (1)  @Balance = Balance FROM Cash.vwTaxVatStatement ORDER BY StartOn DESC, VatDue DESC
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go


DROP VIEW IF EXISTS Invoice.vwVatDetail;
DROP VIEW IF EXISTS Invoice.vwVatBase;
DROP VIEW IF EXISTS Invoice.vwVatItems;
DROP VIEW IF EXISTS Invoice.vwVatTasks;
DROP FUNCTION IF EXISTS Cash.fnTaxVatTotals;
DROP VIEW IF EXISTS Invoice.vwVatDetailListing;
DROP VIEW IF EXISTS Invoice.vwVatSummary;
DROP FUNCTION IF EXISTS Cash.fnTaxVatStatement;
go

UPDATE App.tbOptions
SET SQLDataVersion = 3.07;
go


