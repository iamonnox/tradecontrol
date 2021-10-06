ALTER VIEW [Cash].[vwAccountRebuild]
  AS
SELECT     Org.tbPayment.CashAccountCode, Org.tbAccount.OpeningBalance, 
                      Org.tbAccount.OpeningBalance + SUM(Org.tbPayment.PaidInValue - Org.tbPayment.PaidOutValue) AS CurrentBalance
FROM         Org.tbPayment INNER JOIN
                      Org.tbAccount ON Org.tbPayment.CashAccountCode = Org.tbAccount.CashAccountCode
WHERE     (Org.tbPayment.PaymentStatusCode = 1) 
GROUP BY Org.tbPayment.CashAccountCode, Org.tbAccount.OpeningBalance
go
ALTER VIEW [Task].[vwActiveData]
AS
SELECT        TaskCode, UserId, AccountCode, ContactName, ActivityCode, TaskTitle, TaskStatusCode, ActionById, ActionOn, ActionedOn, PaymentOn, SecondReference, TaskNotes, TaxCode, Quantity, UnitCharge, TotalCharge, 
                         AddressCodeFrom, AddressCodeTo, Printed, Spooled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, Period, BucketId, TaskStatus, CashCode, CashDescription, OwnerName, ActionName, AccountName, 
                         OrganisationStatus, OrganisationType, CashModeCode
FROM            Task.vwTasks
WHERE        (TaskStatusCode = 1);
go
ALTER VIEW [Org].[vwDatasheet]
AS
	With task_count AS
	(
		SELECT        AccountCode, COUNT(TaskCode) AS TaskCount
		FROM            Task.tbTask
		WHERE        (TaskStatusCode = 1)
		GROUP BY AccountCode
	)
	SELECT        o.AccountCode, o.AccountName, ISNULL(task_count.TaskCount, 0) AS Tasks, o.OrganisationTypeCode, Org.tbType.OrganisationType, Org.tbType.CashModeCode, o.OrganisationStatusCode, 
							 Org.tbStatus.OrganisationStatus, Org.tbAddress.Address, App.tbTaxCode.TaxDescription, o.TaxCode, o.AddressCode, o.AreaCode, o.PhoneNumber, o.FaxNumber, o.EmailAddress, o.WebSite,
								 (SELECT        TOP (1) IndustrySector
								   FROM            Org.tbSector AS sector
								   WHERE        (AccountCode = o.AccountCode)) AS IndustrySector, o.AccountSource, o.PaymentTerms, o.PaymentDays, o.NumberOfEmployees, o.CompanyNumber, o.VatNumber, o.Turnover, o.StatementDays, 
							 o.OpeningBalance, o.ForeignJurisdiction, o.BusinessDescription, o.InsertedBy, o.InsertedOn, o.UpdatedBy, o.UpdatedOn, o.PayDaysFromMonthEnd
	FROM            Org.tbOrg AS o INNER JOIN
							 Org.tbStatus ON o.OrganisationStatusCode = Org.tbStatus.OrganisationStatusCode INNER JOIN
							 Org.tbType ON o.OrganisationTypeCode = Org.tbType.OrganisationTypeCode LEFT OUTER JOIN
							 App.tbTaxCode ON o.TaxCode = App.tbTaxCode.TaxCode LEFT OUTER JOIN
							 Org.tbAddress ON o.AddressCode = Org.tbAddress.AddressCode LEFT OUTER JOIN
							 task_count ON o.AccountCode = task_count.AccountCode
GO


DROP VIEW IF EXISTS Org.vwTaskCount;
go
ALTER TRIGGER [Org].[Org_tbPayment_TriggerUpdate]
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
ALTER TRIGGER [Org].[Org_tbPayment_TriggerInsert]
ON [Org].[tbPayment]
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
		WHERE category.CashTypeCode = 2 AND inserted.PaymentStatusCode = 0

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

go


ALTER   TRIGGER [Org].[Org_tbContact_TriggerInsert] 
   ON  [Org].[tbContact]
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
	
		UPDATE Org.tbContact
		SET 
			NickName = RTRIM(CASE 
				WHEN LEN(ISNULL(i.NickName, '')) > 0 THEN i.NickName
				WHEN CHARINDEX(' ', tbContact.ContactName, 0) = 0 THEN tbContact.ContactName 
				ELSE LEFT(tbContact.ContactName, CHARINDEX(' ', tbContact.ContactName, 0)) END),
			FileAs = Org.fnContactFileAs(tbContact.ContactName)
		FROM Org.tbContact INNER JOIN inserted AS i ON tbContact.AccountCode = i.AccountCode AND tbContact.ContactName = i.ContactName;

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC App.proc_ErrorLog;
		THROW;
	END CATCH
END
go

ALTER PROCEDURE [Org].[proc_NextAddressCode] 
	(
	@AccountCode nvarchar(10),
	@AddressCode nvarchar(15) OUTPUT
	)
  AS
   	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @AddCount int

		SELECT @AddCount = ISNULL(COUNT(AddressCode), 0) 
		FROM         Org.tbAddress
		WHERE     (AccountCode = @AccountCode)
	
		SET @AddCount += 1
		SET @AddressCode = CONCAT(UPPER(@AccountCode), '_', FORMAT(@AddCount, '000'))
	
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
ALTER VIEW [Cash].[vwTaxVatTotals]
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
	SELECT a.YearNumber, a.[Description], m.[MonthName] AS [Period], r.StartOn, HomeSales, HomePurchases, ExportSales, ExportPurchases, HomeSalesVat, HomePurchasesVat, ExportSalesVat, ExportPurchasesVat,
		a.VatAdjustment, VatDue - a.VatAdjustment AS VatDue
	FROM vat_results r JOIN vat_adjustments a ON r.StartOn = a.StartOn
		JOIN App.tbMonth m ON a.MonthNumber = m.MonthNumber;
go
ALTER PROCEDURE [Task].[proc_DefaultPaymentOn]
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
					DATEADD(d, -1, DATEADD(m, 1, CONCAT(FORMAT(DATEADD(d, org.PaymentDays, @ActionOn), 'yyyyMM'), '01')))												
				ELSE
					DATEADD(d, org.PaymentDays, @ActionOn)	
				END
		FROM Org.tbOrg org 
		WHERE org.AccountCode = @AccountCode

		PRINT @ActionOn

		SELECT @PaymentOn = App.fnAdjustToCalendar(@ActionOn, 0) 					
	 
  	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
go
