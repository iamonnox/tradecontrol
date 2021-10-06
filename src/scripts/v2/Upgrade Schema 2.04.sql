/************************************************************
* Tru-Man Trade Control: Information and Cash System
* Copyright Trade Control Ltd 2012. All Rights Reserved.
* Author: Ian Monnox
* Description: Sql Server Upgrade Script - Encrypted Distribution Schema
* Data Version: 2.04
* Release Date: 27.02.12
************************************************************/
ALTER TABLE tbInvoice WITH NOCHECK ADD
	Spooled BIT NOT NULL CONSTRAINT DF_tbInvoice_Spooled DEFAULT (0)
GO
ALTER TABLE tbTask WITH NOCHECK ADD
	Spooled BIT NOT NULL CONSTRAINT DF_tbTask_Spooled DEFAULT (0)
GO
CREATE TABLE [dbo].[tbSystemDocSpool](
	[UserName] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbSystemDocSpool_UserName]  DEFAULT (suser_sname()),
	[DocTypeCode] [smallint] NOT NULL CONSTRAINT [DF_tbSystemDocSpool_DocTypeCode]  DEFAULT (1),
	[DocumentNumber] [nvarchar](25) NOT NULL,
	[SpooledOn] [datetime] NOT NULL CONSTRAINT [DF_tbSystemDocSpool_SpooledOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_tbSystemDocSpool] PRIMARY KEY CLUSTERED 
(
	[UserName] ASC,
	[DocTypeCode] ASC,
	[DocumentNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [RDX_tbSystemDocSpool_DocTypeCode] ON [dbo].[tbSystemDocSpool] 
(
	[DocTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbSystemDocSpool]  WITH CHECK ADD  CONSTRAINT [tbSystemDocSpool_FK00] FOREIGN KEY([DocTypeCode])
REFERENCES [dbo].[tbSystemDocType] ([DocTypeCode])
GO
ALTER TABLE [dbo].[tbSystemDocSpool] CHECK CONSTRAINT [tbSystemDocSpool_FK00]
GO
CREATE FUNCTION dbo.fnSystemDocInvoiceType
	(
	@InvoiceTypeCode SMALLINT
	)
RETURNS SMALLINT
AS
	BEGIN
	DECLARE @DocTypeCode SMALLINT
	
	SET @DocTypeCode = CASE @InvoiceTypeCode
		WHEN 1 THEN 5		--sales invoice
		WHEN 2 THEN 6		--credit note
		WHEN 4 THEN 7		--debit note
		ELSE 8				--error
		END
	
	RETURN @DocTypeCode
	END
GO
CREATE TRIGGER [dbo].[tbInvoice_TriggerUpdate]
ON [dbo].[tbInvoice]
FOR UPDATE
AS
	IF UPDATE (Spooled)
		BEGIN
		INSERT INTO tbSystemDocSpool (DocTypeCode, DocumentNumber)
		SELECT     dbo.fnSystemDocInvoiceType(i.InvoiceTypeCode) AS DocTypeCode, i.InvoiceNumber
		FROM         inserted i 
		WHERE     (i.Spooled <> 0)

				
		DELETE tbSystemDocSpool
		FROM         inserted i INNER JOIN
		                      tbSystemDocSpool ON i.InvoiceNumber = tbSystemDocSpool.DocumentNumber
		WHERE    (i.Spooled = 0) AND (tbSystemDocSpool.DocTypeCode > 4)
		END
GO
CREATE FUNCTION dbo.fnSystemDocTaskType
	(
	@TaskCode NVARCHAR(20)
	)
RETURNS SMALLINT
AS
	BEGIN
	DECLARE @DocTypeCode SMALLINT
	DECLARE @TaskStatusCode SMALLINT
	DECLARE @CashModeCode SMALLINT
	
	SELECT    @CashModeCode = tbCashCategory.CashModeCode, @TaskStatusCode = tbTask.TaskStatusCode
	FROM            tbTask INNER JOIN
	                         tbCashCode ON tbTask.CashCode = tbCashCode.CashCode INNER JOIN
	                         tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE TaskCode = @TaskCode
	
	SET @DocTypeCode = CASE 
		WHEN @CashModeCode = 1 THEN						--Expense
			CASE WHEN @TaskStatusCode = 1 THEN 3		--Enquiry
				ELSE 4 END			
		WHEN @CashModeCode = 2 THEN						--Income
			CASE WHEN @TaskStatusCode = 1 THEN 1		--Quote
				ELSE 2 END
		END
				
	RETURN @DocTypeCode
	END
GO
CREATE TRIGGER [dbo].[tbTask_TriggerUpdate]
ON [dbo].[tbTask]
FOR UPDATE
AS
	IF UPDATE (Spooled)
		BEGIN
		INSERT INTO tbSystemDocSpool (DocTypeCode, DocumentNumber)
		SELECT     dbo.fnSystemDocTaskType(i.TaskCode) AS DocTypeCode, i.TaskCode
		FROM         inserted i 
		WHERE     (i.Spooled <> 0)

				
		DELETE tbSystemDocSpool
		FROM         inserted i INNER JOIN
		                      tbSystemDocSpool ON i.TaskCode = tbSystemDocSpool.DocumentNumber
		WHERE    (i.Spooled = 0) AND (tbSystemDocSpool.DocTypeCode <= 4)
		END
GO
ALTER VIEW dbo.vwTasks
AS
SELECT     dbo.tbTask.TaskCode, dbo.tbTask.UserId, dbo.tbTask.AccountCode, dbo.tbTask.ContactName, dbo.tbTask.ActivityCode, dbo.tbTask.TaskTitle, 
                      dbo.tbTask.TaskStatusCode, dbo.tbTask.ActionById, dbo.tbTask.ActionOn, dbo.tbTask.ActionedOn, dbo.tbTask.PaymentOn, dbo.tbTask.SecondReference, 
                      dbo.tbTask.TaskNotes, dbo.tbTask.TaxCode, dbo.tbTask.Quantity, dbo.tbTask.UnitCharge, dbo.tbTask.TotalCharge, dbo.tbTask.AddressCodeFrom, 
                      dbo.tbTask.AddressCodeTo, dbo.tbTask.Printed, dbo.tbTask.Spooled, dbo.tbTask.InsertedBy, dbo.tbTask.InsertedOn, dbo.tbTask.UpdatedBy, dbo.tbTask.UpdatedOn, 
                      dbo.vwTaskBucket.Period, dbo.tbSystemBucket.BucketId, dbo.tbTaskStatus.TaskStatus, dbo.tbTask.CashCode, dbo.tbCashCode.CashDescription, 
                      tbUser_1.UserName AS OwnerName, dbo.tbUser.UserName AS ActionName, dbo.tbOrg.AccountName, dbo.tbOrgStatus.OrganisationStatus, 
                      dbo.tbOrgType.OrganisationType, CASE WHEN tbCashCategory.CategoryCode IS NULL 
                      THEN tbOrgType.CashModeCode ELSE tbCashCategory.CashModeCode END AS CashModeCode
FROM         dbo.tbUser INNER JOIN
                      dbo.tbTaskStatus INNER JOIN
                      dbo.tbOrgType INNER JOIN
                      dbo.tbOrg ON dbo.tbOrgType.OrganisationTypeCode = dbo.tbOrg.OrganisationTypeCode INNER JOIN
                      dbo.tbOrgStatus ON dbo.tbOrg.OrganisationStatusCode = dbo.tbOrgStatus.OrganisationStatusCode INNER JOIN
                      dbo.tbTask ON dbo.tbOrg.AccountCode = dbo.tbTask.AccountCode ON dbo.tbTaskStatus.TaskStatusCode = dbo.tbTask.TaskStatusCode ON 
                      dbo.tbUser.UserId = dbo.tbTask.ActionById INNER JOIN
                      dbo.tbUser AS tbUser_1 ON dbo.tbTask.UserId = tbUser_1.UserId INNER JOIN
                      dbo.vwTaskBucket ON dbo.tbTask.TaskCode = dbo.vwTaskBucket.TaskCode INNER JOIN
                      dbo.tbSystemBucket ON dbo.vwTaskBucket.Period = dbo.tbSystemBucket.Period LEFT OUTER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode LEFT OUTER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode
GO
CREATE VIEW dbo.vwSystemDocSpool
AS
SELECT     DocTypeCode, DocumentNumber
FROM         tbSystemDocSpool
WHERE     (UserName = SUSER_SNAME())
GO
UPDATE    tbInvoice
SET              Spooled = 0, Printed = 1
UPDATE    tbTask
SET              Spooled = 0, Printed = 1
GO
CREATE PROCEDURE dbo.spSystemDocDespool
	(
	@DocTypeCode SMALLINT
	)
AS
	IF @DocTypeCode = 1
		GOTO Quotations
	ELSE IF @DocTypeCode = 2
		GOTO SalesOrder
	ELSE IF @DocTypeCode = 3
		GOTO PurchaseEnquiry
	ELSE IF @DocTypeCode = 4
		GOTO PurchaseOrder
	ELSE IF @DocTypeCode = 5
		GOTO SalesInvoice
	ELSE IF @DocTypeCode = 6
		GOTO CreditNote
	ELSE IF @DocTypeCode = 7
		GOTO DebitNote
		
	RETURN
	
Quotations:
	UPDATE       tbTask
	SET           Spooled = 0, Printed = 1
	FROM            tbTask INNER JOIN
							 tbCashCode ON tbTask.CashCode = tbCashCode.CashCode INNER JOIN
							 tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE        (tbTask.TaskStatusCode = 1) AND (tbCashCategory.CashModeCode = 2) AND (tbTask.Spooled <> 0)
	RETURN
	
SalesOrder:
	UPDATE       tbTask
	SET           Spooled = 0, Printed = 1
	FROM            tbTask INNER JOIN
							 tbCashCode ON tbTask.CashCode = tbCashCode.CashCode INNER JOIN
							 tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE        (tbTask.TaskStatusCode > 1) AND (tbCashCategory.CashModeCode = 2) AND (tbTask.Spooled <> 0)
	RETURN
	
PurchaseEnquiry:
	UPDATE       tbTask
	SET           Spooled = 0, Printed = 1
	FROM            tbTask INNER JOIN
							 tbCashCode ON tbTask.CashCode = tbCashCode.CashCode INNER JOIN
							 tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE        (tbTask.TaskStatusCode = 1) AND (tbCashCategory.CashModeCode = 1) AND (tbTask.Spooled <> 0)	
	RETURN
	
PurchaseOrder:
	UPDATE       tbTask
	SET           Spooled = 0, Printed = 1
	FROM            tbTask INNER JOIN
							 tbCashCode ON tbTask.CashCode = tbCashCode.CashCode INNER JOIN
							 tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE        (tbTask.TaskStatusCode > 1) AND (tbCashCategory.CashModeCode = 1) AND (tbTask.Spooled <> 0)
	RETURN
	
SalesInvoice:
	UPDATE       tbInvoice
	SET                Spooled = 0, Printed = 1
	WHERE        (InvoiceTypeCode = 1) AND (Spooled <> 0)

	RETURN
	
CreditNote:
	UPDATE       tbInvoice
	SET                Spooled = 0, Printed = 1
	WHERE        (InvoiceTypeCode = 2) AND (Spooled <> 0)
	RETURN
	
DebitNote:
	UPDATE       tbInvoice
	SET                Spooled = 0, Printed = 1
	WHERE        (InvoiceTypeCode = 4) AND (Spooled <> 0)
	RETURN
GO
CREATE PROCEDURE dbo.spSystemPeriodGetYear
	(
	@StartOn DATETIME,
	@YearNumber INTEGER OUTPUT
	)
AS
	SELECT @YearNumber = YearNumber
	FROM            tbSystemYearPeriod
	WHERE        (StartOn = @StartOn)
	
	IF @YearNumber IS NULL
		SELECT @YearNumber = YearNumber FROM dbo.fnSystemActivePeriod()
		
	RETURN
GO
ALTER VIEW [dbo].[vwTaskOps]
AS
SELECT        dbo.tbTaskOp.TaskCode, dbo.tbTaskOp.OperationNumber, dbo.vwTaskOpBucket.Period, dbo.tbSystemBucket.BucketId, dbo.tbTaskOp.UserId, 
                         dbo.tbTaskOp.OpTypeCode, dbo.tbTaskOp.OpStatusCode, dbo.tbTaskOp.Operation, dbo.tbTaskOp.Note, dbo.tbTaskOp.StartOn, dbo.tbTaskOp.EndOn, 
                         dbo.tbTaskOp.Duration, dbo.tbTaskOp.OffsetDays, dbo.tbTaskOp.InsertedBy, dbo.tbTaskOp.InsertedOn, dbo.tbTaskOp.UpdatedBy, dbo.tbTaskOp.UpdatedOn, 
                         dbo.tbTask.TaskTitle, dbo.tbTaskStatus.TaskStatus, dbo.tbTask.ActionOn, dbo.tbTask.Quantity, dbo.tbCashCode.CashDescription, dbo.tbTask.TotalCharge, 
                         dbo.tbTask.AccountCode, dbo.tbOrg.AccountName
FROM            dbo.tbTaskOp INNER JOIN
                         dbo.tbTask ON dbo.tbTaskOp.TaskCode = dbo.tbTask.TaskCode INNER JOIN
                         dbo.tbOrg ON dbo.tbTask.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                         dbo.tbTaskStatus ON dbo.tbTask.TaskStatusCode = dbo.tbTaskStatus.TaskStatusCode INNER JOIN
                         dbo.vwTaskOpBucket ON dbo.tbTaskOp.TaskCode = dbo.vwTaskOpBucket.TaskCode AND 
                         dbo.tbTaskOp.OperationNumber = dbo.vwTaskOpBucket.OperationNumber INNER JOIN
                         dbo.tbSystemBucket ON dbo.vwTaskOpBucket.Period = dbo.tbSystemBucket.Period LEFT OUTER JOIN
                         dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode
GO
DELETE FROM tbProfileText WHERE TextId = 1207
GO
CREATE FUNCTION dbo.fnCashCurrentBalance
	()
RETURNS money
AS
	BEGIN
	declare @CurrentBalance money
	
	SELECT    @CurrentBalance = SUM(tbOrgAccount.CurrentBalance)
	FROM         tbOrgAccount INNER JOIN
	                      tbCashCode ON tbOrgAccount.CashCode = tbCashCode.CashCode
	WHERE     (tbOrgAccount.AccountClosed = 0)
	
	RETURN ISNULL(@CurrentBalance, 0)
	END
GO
ALTER FUNCTION [dbo].[fnStatementCompany]()
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
	declare @ReferenceCode nvarchar(20) 
	declare @CashCode nvarchar(50)
	declare @AccountCode nvarchar(10)
	declare @TransactOn datetime
	declare @CashEntryTypeCode smallint
	declare @PayOut money
	declare @PayIn money
	declare @Balance money

	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, CashCode, PayIn, PayOut)	
	SELECT     tbInvoiceItem.InvoiceNumber, tbInvoice.AccountCode, tbInvoice.CollectOn, 2 AS CashEntryTypeCode, tbInvoiceItem.CashCode, 
	                      SUM(CASE WHEN InvoiceTypeCode = 1 OR
	                      InvoiceTypeCode = 4 THEN (tbInvoiceItem.InvoiceValue + tbInvoiceItem.TaxValue) - (tbInvoiceItem.PaidValue + tbInvoiceItem.PaidTaxValue) 
	                      ELSE 0 END) AS PayIn, SUM(CASE WHEN InvoiceTypeCode = 2 OR
	                      InvoiceTypeCode = 3 THEN (tbInvoiceItem.InvoiceValue + tbInvoiceItem.TaxValue) - (tbInvoiceItem.PaidValue + tbInvoiceItem.PaidTaxValue) 
	                      ELSE 0 END) AS PayOut
	FROM         tbInvoiceItem INNER JOIN
	                      tbInvoice ON tbInvoiceItem.InvoiceNumber = tbInvoice.InvoiceNumber INNER JOIN
	                      tbCashCode ON tbInvoiceItem.CashCode = tbCashCode.CashCode INNER JOIN
	                      tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE     ((tbInvoiceItem.InvoiceValue + tbInvoiceItem.TaxValue) - (tbInvoiceItem.PaidValue + tbInvoiceItem.PaidTaxValue) > 0)
	GROUP BY tbInvoiceItem.InvoiceNumber, tbInvoice.AccountCode, tbInvoice.InvoicedOn, tbInvoice.CollectOn, tbInvoiceItem.CashCode

	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, CashCode, PayIn, PayOut)		
	SELECT     tbInvoiceTask.InvoiceNumber, tbInvoice.AccountCode, tbInvoice.CollectOn, 2 AS CashEntryTypeCode, tbInvoiceTask.CashCode, 
	                      SUM(CASE WHEN InvoiceTypeCode = 1 OR
	                      InvoiceTypeCode = 4 THEN (tbInvoiceTask.InvoiceValue + tbInvoiceTask.TaxValue) - (tbInvoiceTask.PaidValue + tbInvoiceTask.PaidTaxValue) 
	                      ELSE 0 END) AS PayIn, SUM(CASE WHEN InvoiceTypeCode = 2 OR
	                      InvoiceTypeCode = 3 THEN (tbInvoiceTask.InvoiceValue + tbInvoiceTask.TaxValue) - (tbInvoiceTask.PaidValue + tbInvoiceTask.PaidTaxValue) 
	                      ELSE 0 END) AS PayOut
	FROM         tbInvoiceTask INNER JOIN
	                      tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber INNER JOIN
	                      tbCashCode ON tbInvoiceTask.CashCode = tbCashCode.CashCode INNER JOIN
	                      tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE     ((tbInvoiceTask.InvoiceValue + tbInvoiceTask.TaxValue) - (tbInvoiceTask.PaidValue + tbInvoiceTask.PaidTaxValue) > 0)
	GROUP BY tbInvoiceTask.InvoiceNumber, tbInvoice.AccountCode, tbInvoice.InvoicedOn, tbInvoice.CollectOn, tbInvoiceTask.CashCode
		
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	SELECT     ReferenceCode, AccountCode, PaymentOn, CashEntryTypeCode, PayIn, PayOut, CashCode
	FROM         vwStatementTasksConfirmed			
	
	--Corporation Tax
	IF EXISTS (SELECT        tbOrgAccount.CashAccountCode
	           FROM            tbCashTaxType INNER JOIN
	                                    tbOrgAccount ON tbCashTaxType.CashAccountCode = tbOrgAccount.CashAccountCode INNER JOIN
	                                    tbCashCode ON tbOrgAccount.CashCode = tbCashCode.CashCode
	           WHERE        (tbCashTaxType.TaxTypeCode = 1))
		BEGIN
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
		SELECT ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
		FROM dbo.fnStatementTaxEntries(1)
		ORDER BY TransactOn		
		END

	--VAT
	IF EXISTS (SELECT        tbOrgAccount.CashAccountCode
	           FROM            tbCashTaxType INNER JOIN
	                                    tbOrgAccount ON tbCashTaxType.CashAccountCode = tbOrgAccount.CashAccountCode INNER JOIN
	                                    tbCashCode ON tbOrgAccount.CashCode = tbCashCode.CashCode
	           WHERE        (tbCashTaxType.TaxTypeCode = 2))
		BEGIN	
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
		SELECT ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
		FROM dbo.fnStatementTaxEntries(2)
		ORDER BY TransactOn		
		END

	select @ReferenceCode = dbo.fnSystemProfileText(3013)
	set @Balance = dbo.fnCashCurrentBalance()	
	SELECT @TransactOn = DATEADD(d, -1, MIN(TransactOn)) FROM @tbStatement
	SELECT TOP 1 @AccountCode = AccountCode FROM tbSystemOptions
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, Balance)
	VALUES (@ReferenceCode, @AccountCode, @TransactOn, 1, 0, 0, @Balance)
			
	declare curSt cursor local for
		select TransactOn, CashEntryTypeCode, ReferenceCode, PayIn, PayOut, CashCode
		from @tbStatement
		order by TransactOn, CashEntryTypeCode, ReferenceCode, CashCode

	open curSt
	
	fetch next from curSt into @TransactOn, @CashEntryTypeCode, @ReferenceCode, @PayIn, @PayOut, @CashCode
	
	while (@@FETCH_STATUS = 0)
		begin
		set @Balance = @Balance + @PayIn - @PayOut
		if @CashCode IS NULL
			BEGIN
			update @tbStatement
			set Balance = @Balance
			where TransactOn = @TransactOn and CashEntryTypeCode = @CashEntryTypeCode and ReferenceCode = @ReferenceCode
			END
		ELSE
			BEGIN
			update @tbStatement
			set Balance = @Balance
			where TransactOn = @TransactOn and CashEntryTypeCode = @CashEntryTypeCode and ReferenceCode = @ReferenceCode and CashCode = @CashCode
			END
		fetch next from curSt into @TransactOn, @CashEntryTypeCode, @ReferenceCode, @PayIn, @PayOut, @CashCode
		end
	close curSt
	deallocate curSt
		
	RETURN
	END
GO
ALTER VIEW [dbo].[vwTaxVatTotals]
AS
SELECT     TOP 100 PERCENT dbo.tbSystemYear.YearNumber, dbo.tbSystemYear.Description, 
                      dbo.tbSystemMonth.MonthName + ' ' + LTRIM(STR(YEAR(dbo.tbSystemYearPeriod.StartOn))) AS Period, fnTaxVatTotals.StartOn, fnTaxVatTotals.HomeSales, 
                      fnTaxVatTotals.HomePurchases, fnTaxVatTotals.ExportSales, fnTaxVatTotals.ExportPurchases, fnTaxVatTotals.HomeSalesVat, fnTaxVatTotals.HomePurchasesVat, 
                      fnTaxVatTotals.ExportSalesVat, fnTaxVatTotals.ExportPurchasesVat, fnTaxVatTotals.VatAdjustment, fnTaxVatTotals.VatDue
FROM         dbo.fnTaxVatTotals() AS fnTaxVatTotals INNER JOIN
                      dbo.tbSystemYearPeriod ON fnTaxVatTotals.StartOn = dbo.tbSystemYearPeriod.StartOn INNER JOIN
                      dbo.tbSystemMonth ON dbo.tbSystemYearPeriod.MonthNumber = dbo.tbSystemMonth.MonthNumber INNER JOIN
                      dbo.tbSystemYear ON dbo.tbSystemYearPeriod.YearNumber = dbo.tbSystemYear.YearNumber
WHERE     (dbo.tbSystemYear.CashStatusCode = 2) OR
                      (dbo.tbSystemYear.CashStatusCode = 3)
ORDER BY fnTaxVatTotals.StartOn
GO
CREATE FUNCTION dbo.fnSystemHistoryStartOn()
RETURNS DATETIME
AS
	BEGIN
	DECLARE @StartOn DATETIME
	SELECT  @StartOn = MIN(tbSystemYearPeriod.StartOn)
	FROM            tbSystemYear INNER JOIN
	                         tbSystemYearPeriod ON tbSystemYear.YearNumber = tbSystemYearPeriod.YearNumber
	WHERE        (tbSystemYear.CashStatusCode < 4)
	
	RETURN @StartOn
	END
GO
ALTER VIEW [dbo].[vwTaxVatStatement]
AS
SELECT        TOP 100 PERCENT StartOn, VatDue, VatPaid, Balance
FROM            dbo.fnTaxVatStatement() AS fnTaxVatStatement
WHERE        (StartOn > dbo.fnSystemHistoryStartOn())
ORDER BY StartOn, VatDue
GO
ALTER VIEW [dbo].[vwTaxCorpTotals]
AS
SELECT     TOP 100 PERCENT vwCorpTaxInvoice.StartOn, YEAR(tbSystemYearPeriod.StartOn) AS PeriodYear, tbSystemYear.Description, 
                      tbSystemMonth.MonthName + ' ' + LTRIM(STR(YEAR(tbSystemYearPeriod.StartOn))) AS Period, tbSystemYearPeriod.CorporationTaxRate, 
                      tbSystemYearPeriod.TaxAdjustment, SUM(vwCorpTaxInvoice.NetProfit) AS NetProfit, SUM(vwCorpTaxInvoice.CorporationTax) AS CorporationTax
FROM         vwCorpTaxInvoice INNER JOIN
                      tbSystemYearPeriod ON vwCorpTaxInvoice.StartOn = tbSystemYearPeriod.StartOn INNER JOIN
                      tbSystemYear ON tbSystemYearPeriod.YearNumber = tbSystemYear.YearNumber INNER JOIN
                      tbSystemMonth ON tbSystemYearPeriod.MonthNumber = tbSystemMonth.MonthNumber
WHERE     (tbSystemYear.CashStatusCode = 2) OR
                      (tbSystemYear.CashStatusCode = 3)
GROUP BY tbSystemYear.Description, tbSystemMonth.MonthName, vwCorpTaxInvoice.StartOn, YEAR(tbSystemYearPeriod.StartOn), tbSystemYearPeriod.CorporationTaxRate, 
                      tbSystemYearPeriod.TaxAdjustment
ORDER BY vwCorpTaxInvoice.StartOn
GO
ALTER VIEW [dbo].[vwTaxCorpStatement]
AS
SELECT     TOP 100 PERCENT StartOn, TaxDue, TaxPaid, Balance
FROM         dbo.fnTaxCorpStatement() AS fnTaxCorpStatement
WHERE     (StartOn > dbo.fnSystemHistoryStartOn())
ORDER BY StartOn, TaxDue
GO
ALTER VIEW [dbo].[vwInvoiceSummaryItems]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN tbInvoice.InvoiceTypeCode = 2 THEN 1 ELSE CASE WHEN tbInvoice.InvoiceTypeCode = 4 THEN 3 ELSE tbInvoice.InvoiceTypeCode END END AS InvoiceTypeCode,
                       CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.InvoiceValue * - 1 ELSE dbo.tbInvoiceItem.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.TaxValue * - 1 ELSE dbo.tbInvoiceItem.TaxValue END AS TaxValue
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
WHERE     (dbo.tbInvoice.InvoicedOn >= dbo.fnSystemHistoryStartOn())
GO
ALTER VIEW [dbo].[vwInvoiceSummaryTasks]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN tbInvoice.InvoiceTypeCode = 2 THEN 1 ELSE CASE WHEN tbInvoice.InvoiceTypeCode = 4 THEN 3 ELSE tbInvoice.InvoiceTypeCode END END AS InvoiceTypeCode,
                       CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.InvoiceValue * - 1 ELSE dbo.tbInvoiceTask.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.TaxValue * - 1 ELSE dbo.tbInvoiceTask.TaxValue END AS TaxValue
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
WHERE     (dbo.tbInvoice.InvoicedOn >= dbo.fnSystemHistoryStartOn())
GO
ALTER VIEW [dbo].[vwInvoiceSummary]
AS
SELECT     DATENAME(yyyy, StartOn) + '/' + CAST(dbo.fnPad(MONTH(StartOn), 2) AS nvarchar) AS PeriodOn, StartOn, InvoiceTypeCode, InvoiceType AS InvoiceType, 
                      ABS(TotalInvoiceValue) AS TotalInvoiceValue, ABS(TotalTaxValue) AS TotalTaxValue
FROM         dbo.vwInvoiceSummaryTotals
UNION
SELECT     DATENAME(yyyy, StartOn) + '/' + CAST(dbo.fnPad(MONTH(StartOn), 2) AS nvarchar) AS PeriodOn, StartOn, InvoiceTypeCode, InvoiceType AS InvoiceType, 
                      TotalInvoiceValue, TotalTaxValue
FROM         dbo.vwInvoiceSummaryMargin
GO
ALTER VIEW [dbo].[vwInvoiceRegisterExpenses]
AS
SELECT     vwInvoiceRegisterTasks.StartOn, vwInvoiceRegisterTasks.InvoiceNumber, vwInvoiceRegisterTasks.TaskCode, tbSystemYearPeriod.YearNumber, 
                      tbSystemYear.Description, tbSystemMonth.MonthName + ' ' + LTRIM(STR(YEAR(tbSystemYearPeriod.StartOn))) AS Period, vwInvoiceRegisterTasks.TaskTitle, 
                      vwInvoiceRegisterTasks.CashCode, vwInvoiceRegisterTasks.CashDescription, vwInvoiceRegisterTasks.TaxCode, vwInvoiceRegisterTasks.TaxDescription, 
                      vwInvoiceRegisterTasks.AccountCode, vwInvoiceRegisterTasks.InvoiceTypeCode, vwInvoiceRegisterTasks.InvoiceStatusCode, vwInvoiceRegisterTasks.InvoicedOn, 
                      vwInvoiceRegisterTasks.InvoiceValue, vwInvoiceRegisterTasks.TaxValue, vwInvoiceRegisterTasks.PaidValue, vwInvoiceRegisterTasks.PaidTaxValue, 
                      vwInvoiceRegisterTasks.PaymentTerms, vwInvoiceRegisterTasks.Printed, vwInvoiceRegisterTasks.AccountName, vwInvoiceRegisterTasks.UserName, 
                      vwInvoiceRegisterTasks.InvoiceStatus, vwInvoiceRegisterTasks.CashModeCode, vwInvoiceRegisterTasks.InvoiceType, 
                      (vwInvoiceRegisterTasks.InvoiceValue + vwInvoiceRegisterTasks.TaxValue) - (vwInvoiceRegisterTasks.PaidValue + vwInvoiceRegisterTasks.PaidTaxValue) 
                      AS UnpaidValue
FROM         vwInvoiceRegisterTasks INNER JOIN
                      tbSystemYearPeriod ON vwInvoiceRegisterTasks.StartOn = tbSystemYearPeriod.StartOn INNER JOIN
                      tbSystemYear ON tbSystemYearPeriod.YearNumber = tbSystemYear.YearNumber INNER JOIN
                      tbSystemMonth ON tbSystemYearPeriod.MonthNumber = tbSystemMonth.MonthNumber
WHERE     (dbo.fnTaskIsExpense(vwInvoiceRegisterTasks.TaskCode) = 1)
GO
ALTER VIEW [dbo].[vwTaskProfitOrders]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbTask.ActionOn) AS StartOn, dbo.tbTask.TaskCode, 
                      CASE WHEN dbo.tbCashCategory.CashModeCode = 1 THEN dbo.tbTask.TotalCharge * - 1 ELSE dbo.tbTask.TotalCharge END AS TotalCharge
FROM         dbo.tbCashCode INNER JOIN
                      dbo.tbTask ON dbo.tbCashCode.CashCode = dbo.tbTask.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode LEFT OUTER JOIN
                      dbo.tbTask AS tbTask_1 RIGHT OUTER JOIN
                      dbo.tbTaskFlow ON tbTask_1.TaskCode = dbo.tbTaskFlow.ParentTaskCode ON dbo.tbTask.TaskCode = dbo.tbTaskFlow.ChildTaskCode
WHERE     (dbo.tbTask.TaskStatusCode > 1) AND (dbo.tbTaskFlow.ParentTaskCode IS NULL) AND (tbTask_1.CashCode IS NULL) AND (dbo.tbTask.TaskStatusCode < 5) AND 
                      (dbo.tbTask.ActionOn >= dbo.fnSystemHistoryStartOn()) OR
                      (dbo.tbTask.TaskStatusCode > 1) AND (tbTask_1.CashCode IS NULL) AND (dbo.tbTask.TaskStatusCode < 5) AND (dbo.tbTask.ActionOn >= dbo.fnSystemHistoryStartOn())
GO
ALTER VIEW [dbo].[vwTaskProfit]
AS
SELECT     TOP 100 PERCENT fnTaskProfit_1.StartOn, dbo.tbOrg.AccountCode, dbo.tbTask.TaskCode, dbo.tbSystemYearPeriod.YearNumber, dbo.tbSystemYear.Description, 
                      dbo.tbSystemMonth.MonthName + ' ' + LTRIM(STR(YEAR(dbo.tbSystemYearPeriod.StartOn))) AS Period, dbo.tbTask.ActivityCode, dbo.tbCashCode.CashCode, 
                      dbo.tbTask.TaskTitle, dbo.tbOrg.AccountName, dbo.tbCashCode.CashDescription, dbo.tbTaskStatus.TaskStatus, fnTaskProfit_1.TotalCharge, 
                      fnTaskProfit_1.InvoicedCharge, fnTaskProfit_1.InvoicedChargePaid, fnTaskProfit_1.TotalCost, fnTaskProfit_1.InvoicedCost, fnTaskProfit_1.InvoicedCostPaid, 
                      fnTaskProfit_1.TotalCharge - fnTaskProfit_1.TotalCost AS Profit, fnTaskProfit_1.TotalCharge - fnTaskProfit_1.InvoicedCharge AS UninvoicedCharge, 
                      fnTaskProfit_1.InvoicedCharge - fnTaskProfit_1.InvoicedChargePaid AS UnpaidCharge, fnTaskProfit_1.TotalCost - fnTaskProfit_1.InvoicedCost AS UninvoicedCost, 
                      fnTaskProfit_1.InvoicedCost - fnTaskProfit_1.InvoicedCostPaid AS UnpaidCost, dbo.tbTask.ActionOn, dbo.tbTask.ActionedOn, dbo.tbTask.PaymentOn
FROM         dbo.tbTask INNER JOIN
                      dbo.fnTaskProfit() AS fnTaskProfit_1 ON dbo.tbTask.TaskCode = fnTaskProfit_1.TaskCode INNER JOIN
                      dbo.tbTaskStatus ON dbo.tbTask.TaskStatusCode = dbo.tbTaskStatus.TaskStatusCode INNER JOIN
                      dbo.tbOrg ON dbo.tbTask.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode INNER JOIN
                      dbo.tbSystemYearPeriod ON fnTaskProfit_1.StartOn = dbo.tbSystemYearPeriod.StartOn INNER JOIN
                      dbo.tbSystemYear ON dbo.tbSystemYearPeriod.YearNumber = dbo.tbSystemYear.YearNumber INNER JOIN
                      dbo.tbSystemMonth ON dbo.tbSystemYearPeriod.MonthNumber = dbo.tbSystemMonth.MonthNumber
WHERE     (dbo.tbCashCategory.CashModeCode = 2)
ORDER BY fnTaskProfit_1.StartOn
GO
