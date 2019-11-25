/************************************************************
* Tru-Man Trade Control: Information and Cash System
* Copyright Tru-Man Industries Ltd 2008. All Rights Reserved.
* Author: Ian Monnox
* Description: Sql Server Upgrade Script - Encrypted Distribution Schema
* Data Version: 1.05
* Release Date: 18/6/8
************************************************************/


CREATE TABLE [tbCashEntryType] (
	[CashEntryTypeCode] [smallint] NOT NULL ,
	[CashEntryType] [nvarchar] (20) NOT NULL ,
	CONSTRAINT [PK_tbCashEntryType] PRIMARY KEY  CLUSTERED 
	(
		[CashEntryTypeCode]
	)  ON [PRIMARY] 
) ON [PRIMARY]
GO
INSERT INTO dbo.tbCashEntryType(CashEntryTypeCode, CashEntryType) VALUES(1, 'Payment')
INSERT INTO dbo.tbCashEntryType(CashEntryTypeCode, CashEntryType) VALUES(2, 'Invoice')
INSERT INTO dbo.tbCashEntryType(CashEntryTypeCode, CashEntryType) VALUES(3, 'Order')
INSERT INTO dbo.tbCashEntryType(CashEntryTypeCode, CashEntryType) VALUES(4, 'Quote')
INSERT INTO dbo.tbCashEntryType(CashEntryTypeCode, CashEntryType) VALUES(5, 'Corporation Tax')
INSERT INTO dbo.tbCashEntryType(CashEntryTypeCode, CashEntryType) VALUES(6, 'Vat')
GO
ALTER TABLE dbo.tbInvoice WITH NOCHECK ADD
	CollectOn datetime NOT NULL CONSTRAINT DF_tbInvoice_CollectOn DEFAULT ((getdate()))
GO
UPDATE tbInvoice
SET CollectOn = InvoicedOn
GO
ALTER TABLE tbCashTaxType WITH NOCHECK ADD
	AccountCode nvarchar(10) NULL
GO
ALTER TABLE [dbo].[tbCashTaxType]  WITH CHECK ADD  CONSTRAINT [FK_tbCashTaxType_tbOrg] FOREIGN KEY([AccountCode])
REFERENCES [dbo].[tbOrg] ([AccountCode])
ON UPDATE CASCADE
GO
INSERT INTO dbo.tbProfileText (TextId, Message, Arguments) VALUES (3013, 'Current Balance', 0)
GO
INSERT INTO dbo.tbProfileText (TextId, Message, Arguments) VALUES (3014, 'This entry cannot be rescheduled', 0)
GO
ALTER TABLE dbo.tbOrg WITH NOCHECK ADD
	PaymentDays smallint NOT NULL CONSTRAINT DF_tbOrg_PaymentDays DEFAULT (0)
GO
ALTER TABLE dbo.tbTask WITH NOCHECK ADD
	PaymentOn datetime NOT NULL CONSTRAINT DF_tbTask_PaymentOn DEFAULT ((getdate()))
GO
UPDATE tbTask
SET PaymentOn = ActionOn
GO
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'PaymentOn', 8, 'Pay On', '', '', 0, 1, 'Medium Date')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'PaymentDays', 2, 'Pay On', '', '', 0, 1, '0 days')
GO
ALTER  VIEW dbo.vwOrgDatasheet
AS
SELECT     dbo.tbOrg.AccountCode, dbo.tbOrg.AccountName, ISNULL(dbo.vwOrgTaskCount.TaskCount, 0) AS Tasks, dbo.tbOrg.OrganisationTypeCode, 
                      dbo.tbOrgType.OrganisationType, dbo.tbOrgType.CashModeCode, dbo.tbOrg.OrganisationStatusCode, dbo.tbOrgStatus.OrganisationStatus, 
                      dbo.tbOrgAddress.Address, dbo.tbSystemTaxCode.TaxDescription, dbo.tbOrg.TaxCode, dbo.tbOrg.AddressCode, dbo.tbOrg.AreaCode, 
                      dbo.tbOrg.PhoneNumber, dbo.tbOrg.FaxNumber, dbo.tbOrg.EmailAddress, dbo.tbOrg.WebSite, dbo.fnOrgIndustrySectors(dbo.tbOrg.AccountCode) 
                      AS IndustrySector, dbo.tbOrg.AccountSource, dbo.tbOrg.PaymentTerms, dbo.tbOrg.PaymentDays, dbo.tbOrg.NumberOfEmployees, 
                      dbo.tbOrg.CompanyNumber, dbo.tbOrg.VatNumber, dbo.tbOrg.Turnover, dbo.tbOrg.StatementDays, dbo.tbOrg.OpeningBalance, 
                      dbo.tbOrg.CurrentBalance, dbo.tbOrg.ForeignJurisdiction, dbo.tbOrg.BusinessDescription, dbo.tbOrg.InsertedBy, dbo.tbOrg.InsertedOn, 
                      dbo.tbOrg.UpdatedBy, dbo.tbOrg.UpdatedOn
FROM         dbo.tbOrg INNER JOIN
                      dbo.tbOrgStatus ON dbo.tbOrg.OrganisationStatusCode = dbo.tbOrgStatus.OrganisationStatusCode INNER JOIN
                      dbo.tbOrgType ON dbo.tbOrg.OrganisationTypeCode = dbo.tbOrgType.OrganisationTypeCode LEFT OUTER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbOrg.TaxCode = dbo.tbSystemTaxCode.TaxCode LEFT OUTER JOIN
                      dbo.tbOrgAddress ON dbo.tbOrg.AddressCode = dbo.tbOrgAddress.AddressCode LEFT OUTER JOIN
                      dbo.vwOrgTaskCount ON dbo.tbOrg.AccountCode = dbo.vwOrgTaskCount.AccountCode
GO
CREATE OR ALTER VIEW dbo.vwCorpTaxConfirmedBase
AS
SELECT     TOP 100 PERCENT dbo.fnAccountPeriod(dbo.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * - 1 ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) END AS OrderValue
FROM         dbo.vwTaskInvoicedQuantity RIGHT OUTER JOIN
                      dbo.fnNetProfitCashCodes() fnNetProfitCashCodes INNER JOIN
                      dbo.tbCashCategory INNER JOIN
                      dbo.tbCashCode ON dbo.tbCashCategory.CategoryCode = dbo.tbCashCode.CategoryCode ON 
                      fnNetProfitCashCodes.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbTask ON fnNetProfitCashCodes.CashCode = dbo.tbTask.CashCode ON dbo.vwTaskInvoicedQuantity.TaskCode = dbo.tbTask.TaskCode
WHERE     (dbo.tbTask.TaskStatusCode > 1) AND (dbo.tbTask.TaskStatusCode < 4) AND 
                      (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0) > 0)
GO
CREATE OR ALTER VIEW dbo.vwCorpTaxConfirmed
AS
SELECT     dbo.vwCorpTaxConfirmedBase.StartOn, SUM(dbo.vwCorpTaxConfirmedBase.OrderValue) AS NetProfit, 
                      SUM(dbo.vwCorpTaxConfirmedBase.OrderValue * dbo.tbSystemYearPeriod.CorporationTaxRate) AS CorporationTax
FROM         dbo.vwCorpTaxConfirmedBase INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.vwCorpTaxConfirmedBase.StartOn = dbo.tbSystemYearPeriod.StartOn
GROUP BY dbo.vwCorpTaxConfirmedBase.StartOn
GO
CREATE OR ALTER VIEW dbo.vwCorpTaxTasksBase
AS
SELECT     TOP 100 PERCENT dbo.fnAccountPeriod(dbo.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * - 1 ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) END AS OrderValue
FROM         dbo.vwTaskInvoicedQuantity RIGHT OUTER JOIN
                      dbo.fnNetProfitCashCodes() fnNetProfitCashCodes INNER JOIN
                      dbo.tbCashCategory INNER JOIN
                      dbo.tbCashCode ON dbo.tbCashCategory.CategoryCode = dbo.tbCashCode.CategoryCode ON 
                      fnNetProfitCashCodes.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbTask ON fnNetProfitCashCodes.CashCode = dbo.tbTask.CashCode ON dbo.vwTaskInvoicedQuantity.TaskCode = dbo.tbTask.TaskCode
WHERE     (dbo.tbTask.TaskStatusCode < 4) AND (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0) > 0)
GO
CREATE OR ALTER VIEW dbo.vwCorpTaxTasks
AS
SELECT     dbo.vwCorpTaxTasksBase.StartOn, SUM(dbo.vwCorpTaxTasksBase.OrderValue) AS NetProfit, 
                      dbo.vwCorpTaxTasksBase.OrderValue * dbo.tbSystemYearPeriod.CorporationTaxRate AS CorporationTax
FROM         dbo.vwCorpTaxTasksBase INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.vwCorpTaxTasksBase.StartOn = dbo.tbSystemYearPeriod.StartOn
GROUP BY dbo.vwCorpTaxTasksBase.StartOn, dbo.vwCorpTaxTasksBase.OrderValue * dbo.tbSystemYearPeriod.CorporationTaxRate
GO
CREATE OR ALTER FUNCTION dbo.fnStatementTaxAccount
	(
	@TaxTypeCode smallint
	)
RETURNS nvarchar(10)
AS
	BEGIN
	declare @AccountCode nvarchar(10)
	if exists (SELECT     AccountCode
		FROM         tbCashTaxType
		WHERE     (TaxTypeCode = @TaxTypeCode) AND (NOT (AccountCode IS NULL)))
		begin
		SELECT @AccountCode = AccountCode
		FROM         tbCashTaxType
		WHERE     (TaxTypeCode = @TaxTypeCode) AND (NOT (AccountCode IS NULL))
		end
	else
		begin
		SELECT TOP 1 @AccountCode = AccountCode
		FROM         tbSystemOptions		
		end
			
	
	RETURN @AccountCode
	END
GO
CREATE OR ALTER FUNCTION dbo.fnStatementVat
	()
RETURNS @tbVat TABLE (
	ReferenceCode nvarchar(20), 
	AccountCode nvarchar(10),
	TransactOn datetime,
	CashEntryTypeCode int,
	PayOut money,
	PayIn money
	)
AS
	BEGIN
	declare @LastBalanceOn datetime
	declare @VatDueOn datetime
	declare @VatDue money
	

	if exists(SELECT  MAX(StartOn) AS LastStartOn FROM vwTaxVatStatement)
		begin
		select @LastBalanceOn = MAX(StartOn) FROM vwTaxVatStatement
		SELECT  TOP 1 @VatDueOn = PayOn
		FROM         vwStatementVatDueDate
		
		SELECT @VatDue = Balance
		FROM         vwTaxVatStatement
		WHERE     (StartOn = @LastBalanceOn)		
		
		if (@VatDue <> 0)
			begin
			insert into @tbVat (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayOut, PayIn)
			values ('-', dbo.fnStatementTaxAccount(2), @VatDueOn, 6, CASE WHEN @VatDue > 0 THEN @VatDue ELSE 0 END, CASE WHEN @VatDue < 0 THEN @VatDue ELSE 0 END)						
			end
		end
	
	RETURN
	END
GO
CREATE OR ALTER VIEW dbo.vwStatementCorpTax
AS
SELECT     '-' AS ReferenceCode, dbo.fnStatementTaxAccount(1) AS AccountCode, StartOn AS TransactOn, 5 AS CashEntryTypeCode, 
                      CASE WHEN TaxDue - TaxPaid < 0 THEN Abs(TaxDue - TaxPaid) ELSE 0 END AS PayIn, 
                      CASE WHEN TaxDue - TaxPaid >= 0 THEN Abs(TaxDue - TaxPaid) ELSE 0 END AS PayOut
FROM         dbo.vwTaxCorpStatement
WHERE     (TaxDue - TaxPaid <> 0)
GO
CREATE OR ALTER FUNCTION dbo.fnStatementCompany
	(
	@IncludeForecasts bit = 0
	)
RETURNS @tbStatement TABLE (
	ReferenceCode nvarchar(20), 
	AccountCode nvarchar(10),
	TransactOn datetime,
	CashEntryTypeCode smallint,
	PayOut money,
	PayIn money,
	Balance money
	) 
AS
	BEGIN
	declare @ReferenceCode nvarchar(20) 
	declare @AccountCode nvarchar(10)
	declare @TransactOn datetime
	declare @CashEntryTypeCode smallint
	declare @PayOut money
	declare @PayIn money
	declare @Balance money

	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
	SELECT     ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
	FROM         vwStatementCorpTax

	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
	SELECT     ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
	FROM         dbo.fnStatementVat()
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
	SELECT     ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
	FROM         vwStatementInvoices
	
	if (@IncludeForecasts = 0)
		begin
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
		SELECT     ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
		FROM         vwStatementTasksConfirmed			
		end
	else
		begin
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
		SELECT     ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
		FROM         vwStatementTasksFull	
		end

	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
	SELECT     '*' AS ReferenceCode, dbo.fnStatementTaxAccount(1) AS AccountCode, StartOn, 5, 0, CorporationTax
	FROM         fnTaxCorpOrderTotals(@IncludeForecasts) fnTaxCorpOrderTotals_1		

	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
	SELECT     '*' AS ReferenceCode, dbo.fnStatementTaxAccount(1) AS AccountCode, StartOn, 6 AS Expr1, PayIn, PayOut
	FROM         fnTaxVatOrderTotals(@IncludeForecasts) fnTaxVatOrderTotals_1
	WHERE     (PayIn + PayOut <> 0)		

	
	select @ReferenceCode = dbo.fnSystemProfileText(3013)
	set @Balance = dbo.fnCashCompanyBalance()	
	SELECT @TransactOn = DATEADD(d, -1, MIN(TransactOn)) FROM @tbStatement
	SELECT TOP 1 @AccountCode = AccountCode FROM tbSystemOptions
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
	VALUES (@ReferenceCode, @AccountCode, @TransactOn, 1, 0, 0)
	
	declare curSt cursor for
		select TransactOn, CashEntryTypeCode, ReferenceCode, PayIn, PayOut
		from @tbStatement
		order by TransactOn, CashEntryTypeCode, ReferenceCode

	open curSt
	
	fetch next from curSt into @TransactOn, @CashEntryTypeCode, @ReferenceCode, @PayIn, @PayOut
	
	while (@@FETCH_STATUS = 0)
		begin
		set @Balance = @Balance + @PayIn - @PayOut
		update @tbStatement
		set Balance = @Balance
		where TransactOn = @TransactOn and CashEntryTypeCode = @CashEntryTypeCode and ReferenceCode = @ReferenceCode
		
		fetch next from curSt into @TransactOn, @CashEntryTypeCode, @ReferenceCode, @PayIn, @PayOut		
		end
	close curSt
	deallocate curSt
		
	RETURN
	END
GO
CREATE OR ALTER VIEW dbo.vwStatementInvoices
AS
SELECT     TOP 100 PERCENT dbo.vwCashSummaryInvoices.InvoiceNumber AS ReferenceCode, dbo.tbInvoice.AccountCode, 
                      dbo.tbInvoice.CollectOn AS TransactOn, 2 AS CashEntryTypeCode, dbo.vwCashSummaryInvoices.ToCollect AS PayIn, 
                      dbo.vwCashSummaryInvoices.ToPay AS PayOut
FROM         dbo.vwCashSummaryInvoices INNER JOIN
                      dbo.tbInvoice ON dbo.vwCashSummaryInvoices.InvoiceNumber = dbo.tbInvoice.InvoiceNumber
ORDER BY dbo.tbInvoice.CollectOn, 2
GO
CREATE OR ALTER VIEW dbo.vwStatementTasksConfirmed
AS
SELECT     TOP 100 PERCENT dbo.tbTask.TaskCode AS ReferenceCode, dbo.tbTask.AccountCode, dbo.tbTask.PaymentOn AS TransactOn, 3 AS CashEntryTypeCode, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.tbSystemTaxCode.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayOut, 
                      CASE WHEN tbCashCategory.CashModeCode = 2 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.tbSystemTaxCode.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayIn
FROM         dbo.tbSystemTaxCode INNER JOIN
                      dbo.tbTask ON dbo.tbSystemTaxCode.TaxCode = dbo.tbTask.TaxCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.tbTask.TaskStatusCode > 1) AND (dbo.tbTask.TaskStatusCode < 4) AND 
                      (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0) > 0)
ORDER BY dbo.tbTask.PaymentOn
GO
CREATE OR ALTER VIEW dbo.vwStatementTasksFull
AS
SELECT     TOP 100 PERCENT dbo.tbTask.TaskCode AS ReferenceCode, dbo.tbTask.AccountCode, dbo.tbTask.PaymentOn AS TransactOn, 
                      CASE WHEN tbTask.TaskStatusCode = 1 THEN 4 ELSE 3 END AS CashEntryTypeCode, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.tbSystemTaxCode.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayOut, 
                      CASE WHEN tbCashCategory.CashModeCode = 2 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.tbSystemTaxCode.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayIn
FROM         dbo.tbSystemTaxCode INNER JOIN
                      dbo.tbTask ON dbo.tbSystemTaxCode.TaxCode = dbo.tbTask.TaxCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.tbTask.TaskStatusCode < 4) AND (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0) > 0)
ORDER BY dbo.tbTask.PaymentOn, CASE WHEN tbTask.TaskStatusCode = 1 THEN 4 ELSE 3 END
GO
CREATE OR ALTER VIEW dbo.vwStatementVatDueDate
AS
SELECT     TOP 1 PayOn
FROM         dbo.fnTaxTypeDueDates(2) fnTaxTypeDueDates
WHERE     (PayOn > GETDATE())
GO
CREATE OR ALTER VIEW dbo.vwTaskVatConfirmed
AS
SELECT     dbo.fnAccountPeriod(dbo.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * tbSystemTaxCode.TaxRate ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) 
                      * tbSystemTaxCode.TaxRate * - 1 END AS VatValue
FROM         dbo.tbTask INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbTask.TaxCode = dbo.tbSystemTaxCode.TaxCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 2) AND (dbo.tbTask.TaskStatusCode > 1) AND (dbo.tbTask.TaskStatusCode < 4) AND 
                      (CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * tbSystemTaxCode.TaxRate ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) 
                      * tbSystemTaxCode.TaxRate * - 1 END <> 0)
GO
CREATE OR ALTER VIEW dbo.vwTaskVatFull
AS
SELECT     dbo.fnAccountPeriod(dbo.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * tbSystemTaxCode.TaxRate ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) 
                      * tbSystemTaxCode.TaxRate * - 1 END AS VatValue
FROM         dbo.tbTask INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbTask.TaxCode = dbo.tbSystemTaxCode.TaxCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 2) AND (dbo.tbTask.TaskStatusCode < 4) AND 
                      (CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * tbSystemTaxCode.TaxRate ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) 
                      * tbSystemTaxCode.TaxRate * - 1 END <> 0)
GO
CREATE OR ALTER FUNCTION dbo.fnTaxCorpOrderTotals
(@IncludeForecasts bit = 0)
RETURNS @tbCorp TABLE 
	(
	StartOn datetime, 
	NetProfit money,
	CorporationTax money
	)
AS
	BEGIN
	declare @PayOn datetime
	declare @PayFrom datetime
	declare @PayTo datetime
	
	declare curVat cursor local for
		SELECT     PayOn, PayFrom, PayTo
		FROM         fnTaxTypeDueDates(1) fnTaxTypeDueDates
		
	open curVat
	fetch next from curVat into @PayOn, @PayFrom, @PayTo
	while (@@FETCH_STATUS = 0)
		begin
		if (@IncludeForecasts = 0)
			begin
			INSERT INTO @tbCorp (StartOn, NetProfit, CorporationTax)
			SELECT     @PayOn AS PayOn, ISNULL(SUM(NetProfit), 0) AS NetProfit, ISNULL(SUM(CorporationTax), 0) AS CorporationTax
			FROM         vwCorpTaxConfirmed
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
			HAVING      (ISNULL(SUM(CorporationTax), 0) > 0)
			end
		else
			begin
			INSERT INTO @tbCorp (StartOn, NetProfit, CorporationTax)
			SELECT     @PayOn AS PayOn, ISNULL(SUM(NetProfit), 0) AS NetProfit, ISNULL(SUM(CorporationTax), 0) AS CorporationTax
			FROM         vwCorpTaxTasks
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
			HAVING      (ISNULL(SUM(CorporationTax), 0) > 0)
			end		
		fetch next from curVat into @PayOn, @PayFrom, @PayTo
		end
	
	close curVat
	deallocate curVat

	
	RETURN
	END
GO
CREATE OR ALTER FUNCTION dbo.fnTaxVatOrderTotals
	(@IncludeForecasts bit = 0)
RETURNS @tbVat TABLE 
	(
	StartOn datetime, 
	PayIn money,
	PayOut money
	)
AS
	BEGIN
	declare @PayOn datetime
	declare @PayFrom datetime
	declare @PayTo datetime
	
	declare curVat cursor local for
		SELECT     PayOn, PayFrom, PayTo
		FROM         fnTaxTypeDueDates(2) fnTaxTypeDueDates
		
	open curVat
	fetch next from curVat into @PayOn, @PayFrom, @PayTo
	while (@@FETCH_STATUS = 0)
		begin
		if (@IncludeForecasts = 0)
			begin
			INSERT INTO @tbVat (StartOn, PayIn, PayOut)
			SELECT     @PayOn AS PayOn, CASE WHEN ISNULL(SUM(VatValue), 0) > 0 THEN ISNULL(SUM(VatValue), 0) ELSE 0 END AS PayIn, 
			                      CASE WHEN ISNULL(SUM(VatValue), 0) < 0 THEN ABS(ISNULL(SUM(VatValue), 0)) ELSE 0 END AS PayOut
			FROM         vwTaskVatConfirmed
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo) AND (VatValue <> 0) 
			end
		else
			begin
			INSERT INTO @tbVat (StartOn, PayIn, PayOut)
			SELECT     @PayOn AS PayOn, 
				CASE WHEN ISNULL(SUM(VatValue), 0) > 0 THEN ISNULL(SUM(VatValue), 0) ELSE 0 END AS PayIn, 
				CASE WHEN ISNULL(SUM(VatValue), 0) < 0 THEN ABS(ISNULL(SUM(VatValue), 0)) ELSE 0 END AS PayOut
			FROM         vwTaskVatFull
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo) 
			end
			
		fetch next from curVat into @PayOn, @PayFrom, @PayTo
		end
	
	close curVat
	deallocate curVat

	
	RETURN
	END
GO
CREATE OR ALTER PROCEDURE dbo.spStatementCompany
	(
		@IncludeForecasts bit = 0
	)
AS
	SELECT     fnStatementCompany.TransactOn, fnStatementCompany.CashEntryTypeCode, fnStatementCompany.ReferenceCode, 
	                      fnStatementCompany.AccountCode, tbOrg.AccountName, tbCashEntryType.CashEntryType, fnStatementCompany.PayOut, fnStatementCompany.PayIn, 
	                      fnStatementCompany.Balance
	FROM         fnStatementCompany(@IncludeForecasts) fnStatementCompany INNER JOIN
	                      tbCashEntryType ON fnStatementCompany.CashEntryTypeCode = tbCashEntryType.CashEntryTypeCode INNER JOIN
	                      tbOrg ON fnStatementCompany.AccountCode = tbOrg.AccountCode
	ORDER BY fnStatementCompany.TransactOn, fnStatementCompany.CashEntryTypeCode, fnStatementCompany.ReferenceCode
	
	
	RETURN 
GO
CREATE OR ALTER  PROCEDURE dbo.spTaskSchedule
	(
	@ParentTaskCode nvarchar(20),
	@ActionOn datetime = null output
	)
AS
declare @UserId nvarchar(10)
declare @StepNumber smallint
declare @TaskCode nvarchar(20)
declare @OffsetDays smallint
declare @UsedOnQuantity float
declare @Quantity float
declare @PaymentDays smallint
declare @PaymentOn datetime

	if @ActionOn is null
		begin
		select @ActionOn = ActionOn, @UserId = ActionById 
		from tbTask where TaskCode = @ParentTaskCode
		
		if @ActionOn != dbo.fnSystemAdjustToCalendar(@UserId, @ActionOn, 0)
			begin
			set @ActionOn = dbo.fnSystemAdjustToCalendar(@UserId, @ActionOn, 0)
			update tbTask
			set ActionOn = @ActionOn
			where TaskCode = @ParentTaskCode and TaskStatusCode < 3			
			end
		end
	
	SELECT @PaymentDays = tbOrg.PaymentDays, @PaymentOn = tbTask.PaymentOn, @UserId = tbTask.UserId
	FROM         tbOrg INNER JOIN
	                      tbTask ON tbOrg.AccountCode = tbTask.AccountCode
	WHERE     (tbTask.TaskCode = @ParentTaskCode)
	
	if (@PaymentOn != dbo.fnSystemAdjustToCalendar(@UserId, dateadd(d, @PaymentDays, @ActionOn), 0))
		begin
		update tbTask
		set PaymentOn = dbo.fnSystemAdjustToCalendar(@UserId, dateadd(d, @PaymentDays, @ActionOn), 0)
		where TaskCode = @ParentTaskCode and TaskStatusCode < 3
		end
	
	
	Select @Quantity = Quantity from tbTask where TaskCode = @ParentTaskCode
	
	declare curAct cursor local for
		SELECT     tbTaskFlow.StepNumber, tbTaskFlow.ChildTaskCode, tbTask.ActionById, tbTaskFlow.OffsetDays, tbTaskFlow.UsedOnQuantity, 
		                      tbOrg.PaymentDays
		FROM         tbTaskFlow INNER JOIN
		                      tbTask ON tbTaskFlow.ChildTaskCode = tbTask.TaskCode INNER JOIN
		                      tbOrg ON tbTask.AccountCode = tbOrg.AccountCode
		WHERE     (tbTaskFlow.ParentTaskCode = @ParentTaskCode)
		ORDER BY tbTaskFlow.StepNumber DESC
	
	open curAct
	fetch next from curAct into @StepNumber, @TaskCode, @UserId, @OffsetDays, @UsedOnQuantity, @PaymentDays
	while @@FETCH_STATUS = 0
		begin
		set @ActionOn = dbo.fnSystemAdjustToCalendar(@UserId, @ActionOn, @OffsetDays)
		set @PaymentOn = dbo.fnSystemAdjustToCalendar(@UserId, dateadd(d, @PaymentDays, @ActionOn), 0)
		
		update tbTask
		set ActionOn = @ActionOn, 
			PaymentOn = @PaymentOn,
			Quantity = @Quantity * @UsedOnQuantity,
			TotalCharge = case when @UsedOnQuantity = 0 then UnitCharge else UnitCharge * @Quantity * @UsedOnQuantity end,
			UpdatedOn = getdate(),
			UpdatedBy = (suser_sname())
		where TaskCode = @TaskCode and TaskStatusCode < 3
		
		exec dbo.spTaskSchedule @TaskCode, @ActionOn output
		fetch next from curAct into @StepNumber, @TaskCode, @UserId, @OffsetDays, @UsedOnQuantity, @PaymentDays
		end
	
	close curAct
	deallocate curAct	
	
	RETURN
GO
CREATE OR ALTER  PROCEDURE dbo.spTaskConfigure 
	(
	@ParentTaskCode nvarchar(20)
	)
AS
declare @StepNumber smallint
declare @TaskCode nvarchar(20)
declare @UserId nvarchar(10)
declare @ActivityCode nvarchar(50)

	if exists (SELECT     ContactName
	           FROM         tbTask
	           WHERE     (TaskCode = @ParentTaskCode) AND (NOT (ContactName IS NULL)) OR
	                                 (TaskCode = @ParentTaskCode) AND (ContactName <> N''))
		begin
		if not exists(SELECT     tbOrgContact.ContactName
					  FROM         tbTask INNER JOIN
											tbOrgContact ON tbTask.AccountCode = tbOrgContact.AccountCode AND tbTask.ContactName = tbOrgContact.ContactName
					  WHERE     (tbTask.TaskCode = @ParentTaskCode))
			begin
			declare @FileAs nvarchar(100)
			declare @ContactName nvarchar(100)
			declare @NickName nvarchar(100)
			
			select @ContactName = ContactName from tbTask	 
			WHERE     (tbTask.TaskCode = @ParentTaskCode)
			
			set @NickName = left(@ContactName, charindex(' ', @ContactName, 1))
			exec dbo.spOrgContactFileAs @ContactName, @FileAs output
			
			INSERT INTO tbOrgContact
								  (AccountCode, ContactName, FileAs, NickName)
			SELECT     AccountCode, ContactName, @FileAs AS FileAs, @NickName AS NickName
			FROM         tbTask
			WHERE     (TaskCode = @ParentTaskCode)
			end                                   
		end
	
	if exists(SELECT     tbOrg.AccountCode
	          FROM         tbOrg INNER JOIN
	                                tbTask ON tbOrg.AccountCode = tbTask.AccountCode
	          WHERE     (tbTask.TaskCode = @ParentTaskCode) AND (tbOrg.OrganisationStatusCode = 1))
		begin
		UPDATE tbOrg
		SET OrganisationStatusCode = 2
		FROM         tbOrg INNER JOIN
	                                tbTask ON tbOrg.AccountCode = tbTask.AccountCode
	          WHERE     (tbTask.TaskCode = @ParentTaskCode) AND (tbOrg.OrganisationStatusCode = 1)				
		end
	          
	if exists(SELECT     TaskStatusCode
	          FROM         tbTask
	          WHERE     (TaskStatusCode = 3) AND (TaskCode = @ParentTaskCode))
		begin
		UPDATE    tbTask
		SET              ActionedOn = GETDATE()
		WHERE     (TaskCode = @ParentTaskCode)
		end	

	if exists(SELECT     TaskCode
	          FROM         tbTask
	          WHERE     (TaskCode = @ParentTaskCode) AND (TaskTitle IS NULL))  
		begin
		UPDATE    tbTask
		SET      TaskTitle = ActivityCode
		WHERE     (TaskCode = @ParentTaskCode)
		end
	                 
	     	
	INSERT INTO tbTaskAttribute
						  (TaskCode, Attribute, AttributeDescription, PrintOrder, AttributeTypeCode)
	SELECT     tbTask.TaskCode, tbActivityAttribute.Attribute, tbActivityAttribute.DefaultText, tbActivityAttribute.PrintOrder, tbActivityAttribute.AttributeTypeCode
	FROM         tbActivityAttribute INNER JOIN
						  tbTask ON tbActivityAttribute.ActivityCode = tbTask.ActivityCode
	WHERE     (tbTask.TaskCode = @ParentTaskCode)
	
	select @UserId = UserId from tbTask where tbTask.TaskCode = @ParentTaskCode
	
	declare curAct cursor local for
		SELECT     tbActivityFlow.StepNumber
		FROM         tbActivityFlow INNER JOIN
		                      tbTask ON tbActivityFlow.ParentCode = tbTask.ActivityCode
		WHERE     (tbTask.TaskCode = @ParentTaskCode)
		ORDER BY tbActivityFlow.StepNumber	
	
	open curAct
	fetch next from curAct into @StepNumber
	while @@FETCH_STATUS = 0
		begin
		SELECT  @ActivityCode = tbActivity.ActivityCode
		FROM         tbActivityFlow INNER JOIN
		                      tbActivity ON tbActivityFlow.ChildCode = tbActivity.ActivityCode INNER JOIN
		                      tbTask tbTask_1 ON tbActivityFlow.ParentCode = tbTask_1.ActivityCode
		WHERE     (tbActivityFlow.StepNumber = @StepNumber) AND (tbTask_1.TaskCode = @ParentTaskCode)
		
		exec dbo.spTaskNextCode @ActivityCode, @TaskCode output
		
		INSERT INTO tbTask
							(TaskCode, UserId, AccountCode, ContactName, ActivityCode, TaskStatusCode, ActionById, ActionOn, PaymentOn, TaskNotes, UnitCharge, 
							AddressCodeFrom, AddressCodeTo, CashCode, TaxCode, Printed, TaskTitle)
		SELECT     @TaskCode AS NewTask, tbTask_1.UserId, tbTask_1.AccountCode, tbTask_1.ContactName, tbActivity.ActivityCode, tbActivity.TaskStatusCode, 
							tbTask_1.ActionById, tbTask_1.ActionOn, dbo.fnSystemAdjustToCalendar(tbTask_1.UserId, DATEADD(d, tbOrg.PaymentDays, tbTask_1.ActionOn), 0) 
							AS PaymentOn, tbActivity.DefaultText, tbActivity.UnitCharge, tbOrg.AddressCode AS AddressCodeFrom, tbOrg.AddressCode AS AddressCodeTo, 
							tbActivity.CashCode, dbo.fnTaskDefaultTaxCode(tbTask_1.AccountCode, tbActivity.CashCode) AS TaxCode, 
							CASE WHEN tbActivity.PrintOrder = 0 THEN 1 ELSE 0 END AS Printed, tbTask_1.TaskTitle
		FROM         tbActivityFlow INNER JOIN
							tbActivity ON tbActivityFlow.ChildCode = tbActivity.ActivityCode INNER JOIN
							tbTask tbTask_1 ON tbActivityFlow.ParentCode = tbTask_1.ActivityCode INNER JOIN
							tbOrg ON tbTask_1.AccountCode = tbOrg.AccountCode
		WHERE     (tbActivityFlow.StepNumber = @StepNumber) AND (tbTask_1.TaskCode = @ParentTaskCode)
		
		INSERT INTO tbTaskFlow
		                      (ParentTaskCode, StepNumber, ChildTaskCode, UsedOnQuantity, OffsetDays)
		SELECT     tbTask.TaskCode, tbActivityFlow.StepNumber, @TaskCode AS ChildTaskCode, tbActivityFlow.UsedOnQuantity, tbActivityFlow.OffsetDays
		FROM         tbActivityFlow INNER JOIN
		                      tbTask ON tbActivityFlow.ParentCode = tbTask.ActivityCode
		WHERE     (tbTask.TaskCode = @ParentTaskCode) AND (tbActivityFlow.StepNumber = @StepNumber)
		
		exec dbo.spTaskConfigure @TaskCode
		fetch next from curAct into @StepNumber
		end
	
	close curAct
	deallocate curAct


	RETURN
GO
CREATE OR ALTER PROCEDURE dbo.spTaskDefaultPaymentOn
	(
		@AccountCode nvarchar(10),
		@ActionOn datetime,
		@PaymentOn datetime output
	)
AS
declare @PaymentDays smallint
declare @UserId nvarchar(10)

	select @UserId = UserId from dbo.vwUserCredentials
	SELECT @PaymentDays = PaymentDays
	FROM         tbOrg
	WHERE     (AccountCode = @AccountCode)
	
	set @PaymentOn = dbo.fnSystemAdjustToCalendar(@UserId, dateadd(d, @PaymentDays, @ActionOn), 0)
	
	RETURN 
GO
ALTER  PROCEDURE dbo.spInvoiceRaise
	(
	@TaskCode nvarchar(20),
	@InvoiceTypeCode smallint,
	@InvoiceNumber nvarchar(20) = null output
	)
AS
declare @UserId nvarchar(10)
declare @NextNumber int
declare @InvoiceSuffix nvarchar(4)
declare @PaymentDays smallint
declare @CollectOn datetime
declare @AccountCode nvarchar(10)

	select @UserId = UserId from vwUserCredentials

	set @InvoiceSuffix = '.' + @UserId
	
	select @NextNumber = NextNumber
	from tbInvoiceType
	where InvoiceTypeCode = @InvoiceTypeCode
	
	select @InvoiceNumber = dbo.fnPad(@NextNumber, 6) + @InvoiceSuffix
	
	while exists (SELECT     InvoiceNumber
	              FROM         tbInvoice
	              WHERE     (InvoiceNumber = @InvoiceNumber))
		begin
		set @NextNumber = @NextNumber + 1
		set @InvoiceNumber = dbo.fnPad(@NextNumber, 6) + @InvoiceSuffix
		end

	SELECT @PaymentDays = tbOrg.PaymentDays, @AccountCode = tbOrg.AccountCode
	FROM         tbTask INNER JOIN
	                      tbOrg ON tbTask.AccountCode = tbOrg.AccountCode
	WHERE     (tbTask.TaskCode = @TaskCode)		
	
	set @CollectOn = DATEADD(d, @PaymentDays, GETDATE())
	exec dbo.spTaskDefaultPaymentOn @AccountCode, @CollectOn, @CollectOn output
	
	begin tran Invoice
	
	exec dbo.spInvoiceCancel
	
	UPDATE    tbInvoiceType
	SET              NextNumber = @NextNumber + 1
	WHERE     (InvoiceTypeCode = @InvoiceTypeCode)
	
	INSERT INTO tbInvoice
						(InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoicedOn, CollectOn, InvoiceStatusCode, PaymentTerms)
	SELECT     @InvoiceNumber AS InvoiceNumber, @UserId AS UserId, tbTask.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, GETDATE() AS InvoicedOn, 
						@CollectOn AS CollectOn, 1 AS InvoiceStatusCode, 
						tbOrg.PaymentTerms
	FROM         tbTask INNER JOIN
						tbOrg ON tbTask.AccountCode = tbOrg.AccountCode
	WHERE     (tbTask.TaskCode = @TaskCode)
	exec dbo.spInvoiceAddTask @InvoiceNumber, @TaskCode
	
	commit tran Invoice
	
	RETURN
GO
