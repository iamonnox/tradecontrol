ALTER PROCEDURE [Cash].[proc_FlowInitialise]
AS
	SET NOCOUNT, XACT_ABORT ON;
	BEGIN TRY
		BEGIN TRANSACTION

		EXEC Cash.proc_GeneratePeriods

		UPDATE       Cash.tbPeriod
		SET                ForecastValue = 0, ForecastTax = 0, InvoiceValue = 0, InvoiceTax = 0
		FROM            Cash.tbPeriod INNER JOIN
								 Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode INNER JOIN
								 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
		WHERE  ( Cash.tbCategory.CashTypeCode <> 2);
	
		WITH invoice_summary AS
		(
			SELECT        Invoice.vwRegisterDetail.CashCode, Invoice.vwRegisterDetail.StartOn, ABS(SUM(Invoice.vwRegisterDetail.InvoiceValue)) AS InvoiceValue, ABS(SUM(Invoice.vwRegisterDetail.TaxValue)) AS TaxValue
			FROM            Invoice.vwRegisterDetail INNER JOIN
									 Cash.tbCode ON Invoice.vwRegisterDetail.CashCode = Cash.tbCode.CashCode INNER JOIN
									 Cash.tbCategory ON Cash.tbCode.CategoryCode = Cash.tbCategory.CategoryCode
			GROUP BY Invoice.vwRegisterDetail.StartOn, Invoice.vwRegisterDetail.CashCode
		)
		UPDATE Cash.tbPeriod
		SET InvoiceValue = invoice_summary.InvoiceValue, 
			InvoiceTax = invoice_summary.TaxValue
		FROM    Cash.tbPeriod INNER JOIN
				invoice_summary ON Cash.tbPeriod.CashCode = invoice_summary.CashCode AND Cash.tbPeriod.StartOn = invoice_summary.StartOn;

		UPDATE Cash.tbPeriod
		SET 
			InvoiceValue = Cash.vwAccountPeriodClosingBalance.ClosingBalance
		FROM         Cash.vwAccountPeriodClosingBalance INNER JOIN
							  Cash.tbPeriod ON Cash.vwAccountPeriodClosingBalance.CashCode = Cash.tbPeriod.CashCode AND 
							  Cash.vwAccountPeriodClosingBalance.StartOn = Cash.tbPeriod.StartOn;

		WITH forecasts AS
		(
			SELECT task.CashCode, (SELECT TOP 1 StartOn FROM App.tbYearPeriod WHERE StartOn <= task.ActionOn ORDER BY StartOn DESC) AS StartOn,
				task.TotalCharge, ISNULL(tax.TaxRate, 0) AS TaxRate
			FROM Task.tbTask task INNER JOIN
									 Cash.tbCode ON task.CashCode = Cash.tbCode.CashCode INNER JOIN
									 Invoice.tbTask AS InvoiceTask ON task.TaskCode = InvoiceTask.TaskCode AND task.TaskCode = InvoiceTask.TaskCode LEFT OUTER JOIN
									 App.tbTaxCode tax ON task.TaxCode = tax.TaxCode
		), forecast_summary AS
		(
			SELECT CashCode, StartOn, 
				SUM(TotalCharge) AS ForecastValue,
				SUM(TotalCharge * TaxRate) AS ForecastTax
			FROM forecasts
			GROUP BY CashCode, StartOn	                      	
		)
		UPDATE       Cash.tbPeriod
		SET                ForecastValue = forecast_summary.ForecastValue, ForecastTax = forecast_summary.ForecastTax
		FROM            Cash.tbPeriod INNER JOIN
								 forecast_summary ON Cash.tbPeriod.CashCode = forecast_summary.CashCode AND 
								 Cash.tbPeriod.StartOn = forecast_summary.StartOn;

		WITH order_invoice_value AS
		(
			SELECT        TaskCode, SUM(InvoiceValue) AS InvoiceValue, SUM(TaxValue) AS InvoiceTax
			FROM            Invoice.tbTask
			GROUP BY TaskCode	
		), tasks AS
		(
			SELECT        task.CashCode,
										 (SELECT        TOP (1) StartOn
										   FROM            App.tbYearPeriod
										   WHERE        (StartOn <= task.ActionOn)
										   ORDER BY StartOn DESC) AS StartOn, task.TotalCharge, ISNULL(order_invoice_value.InvoiceValue, 0) AS InvoiceValue, 
											ISNULL(order_invoice_value.InvoiceTax, 0) AS InvoiceTax, ISNULL(tax.TaxRate, 0) AS TaxRate
			FROM            Task.tbTask AS task INNER JOIN
									 Cash.tbCode AS cash ON task.CashCode = cash.CashCode LEFT OUTER JOIN
									 order_invoice_value ON task.TaskCode = order_invoice_value.TaskCode LEFT OUTER JOIN
									 App.tbTaxCode AS tax ON task.TaxCode = tax.TaxCode
			WHERE        (task.TaskStatusCode = 1) OR
									 (task.TaskStatusCode = 2)
		), order_summary AS
		(
			SELECT CashCode, StartOn, 
				SUM(TotalCharge - InvoiceValue) AS InvoiceValue,
				SUM((TotalCharge * TaxRate)-InvoiceTax) AS InvoiceTax
			FROM tasks
			GROUP BY CashCode, StartOn
		)
		UPDATE Cash.tbPeriod
		SET
			InvoiceValue = Cash.tbPeriod.InvoiceValue + order_summary.InvoiceValue,
			InvoiceTax = Cash.tbPeriod.InvoiceTax + order_summary.InvoiceTax
		FROM Cash.tbPeriod INNER JOIN
			order_summary ON Cash.tbPeriod.CashCode = order_summary.CashCode
				AND Cash.tbPeriod.StartOn = order_summary.StartOn;	
	
		--Corporation Tax		
		UPDATE       Cash.tbPeriod
		SET                ForecastValue = 0, ForecastTax = 0, InvoiceValue = 0, InvoiceTax = 0
		FROM            Cash.tbPeriod
		WHERE CashCode = (SELECT CashCode FROM Cash.tbTaxType WHERE (TaxTypeCode = 0));
	
		UPDATE       Cash.tbPeriod
		SET                InvoiceValue = vwTaxCorpStatement.TaxDue
		FROM            Cash.vwTaxCorpStatement INNER JOIN
								 Cash.tbPeriod ON vwTaxCorpStatement.StartOn = Cash.tbPeriod.StartOn
		WHERE        (vwTaxCorpStatement.TaxDue <> 0) 
			AND ( Cash.tbPeriod.CashCode = (SELECT CashCode FROM Cash.tbTaxType WHERE (TaxTypeCode = 0)));
	
		--VAT 	
		UPDATE       Cash.tbPeriod
		SET                InvoiceValue = Cash.vwTaxVatStatement.VatDue
		FROM            Cash.vwTaxVatStatement INNER JOIN
								 Cash.tbPeriod ON Cash.vwTaxVatStatement.StartOn = Cash.tbPeriod.StartOn
		WHERE        ( Cash.tbPeriod.CashCode = (SELECT CashCode FROM Cash.tbTaxType WHERE (TaxTypeCode = 1))) AND (Cash.vwTaxVatStatement.VatDue <> 0);

		--**********************************************************************************************	                  	

		WITH ni_totals AS
		(
			SELECT        Cash.tbPeriod.StartOn, SUM(Cash.tbPeriod.ForecastTax) AS ForecastNI, SUM(Cash.tbPeriod.InvoiceTax) AS InvoiceNI
			FROM            Cash.tbPeriod INNER JOIN
									 Cash.tbCode ON Cash.tbPeriod.CashCode = Cash.tbCode.CashCode INNER JOIN
									 App.tbTaxCode ON Cash.tbCode.TaxCode = App.tbTaxCode.TaxCode
			WHERE        (App.tbTaxCode.TaxTypeCode = 2)
			GROUP BY Cash.tbPeriod.StartOn
		)
		UPDATE Cash.tbPeriod
		SET
			ForecastValue = ni_totals.ForecastNI, 
			InvoiceValue = ni_totals.InvoiceNI
		FROM         Cash.tbPeriod INNER JOIN
							  ni_totals ON Cash.tbPeriod.StartOn = ni_totals.StartOn
		WHERE     ( Cash.tbPeriod.CashCode = (SELECT CashCode FROM Cash.tbTaxType WHERE (TaxTypeCode = 2)));
	            
		COMMIT TRANSACTION	 
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
DROP VIEW IF EXISTS Cash.vwCodeForecastSummary;
DROP VIEW IF EXISTS Cash.vwCodeOrderSummary;
DROP VIEW IF EXISTS Cash.vwCodeInvoiceSummary;
DROP VIEW IF EXISTS Cash.vwFlowNITotals;