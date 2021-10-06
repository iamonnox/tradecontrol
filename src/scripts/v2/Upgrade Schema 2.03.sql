/************************************************************
* Tru-Man Trade Control: Information and Cash System
* Copyright Trade Control Ltd 2012. All Rights Reserved.
* Author: Ian Monnox
* Description: Sql Server Upgrade Script - Encrypted Distribution Schema
* Data Version: 2.03
* Release Date: 20.02.12
************************************************************/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwInvoiceVatItems]'))
	DROP VIEW dbo.[vwInvoiceVatItems]
GO
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwInvoiceVatTasks]'))
	DROP VIEW dbo.[vwInvoiceVatTasks]
GO
CREATE VIEW [dbo].[vwInvoiceVatItems]
AS
SELECT     TOP 100 PERCENT dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoice.InvoiceNumber, dbo.tbInvoice.InvoiceTypeCode, 
                      dbo.tbInvoiceItem.TaxCode, dbo.tbInvoiceItem.InvoiceValue, dbo.tbInvoiceItem.TaxValue, dbo.tbOrg.ForeignJurisdiction, 
                      dbo.tbInvoiceItem.CashCode AS IdentityCode
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbInvoiceItem.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 2)
ORDER BY StartOn
GO
CREATE VIEW [dbo].[vwInvoiceVatTasks]
AS
SELECT  TOP 100 PERCENT dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoiceTask.InvoiceNumber, dbo.tbInvoice.InvoiceTypeCode, dbo.tbInvoiceTask.TaxCode, 
                      dbo.tbInvoiceTask.InvoiceValue, dbo.tbInvoiceTask.TaxValue, dbo.tbOrg.ForeignJurisdiction, dbo.tbInvoiceTask.TaskCode AS IdentityCode
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbInvoiceTask.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 2)
ORDER BY StartOn
GO
ALTER VIEW [dbo].[vwInvoiceVatBase]
AS
SELECT     StartOn, InvoiceNumber, InvoiceTypeCode, TaxCode, InvoiceValue, TaxValue, ForeignJurisdiction, IdentityCode
FROM         dbo.vwInvoiceVatItems
UNION
SELECT     StartOn, InvoiceNumber, InvoiceTypeCode, TaxCode, InvoiceValue, TaxValue, ForeignJurisdiction, IdentityCode
FROM         dbo.vwInvoiceVatTasks
GO
ALTER VIEW [dbo].[vwCashCodeInvoiceSummary]
AS
SELECT        dbo.vwInvoiceRegisterDetail.CashCode, dbo.vwInvoiceRegisterDetail.StartOn, ABS(SUM(dbo.vwInvoiceRegisterDetail.InvoiceValue)) AS InvoiceValue, 
                         ABS(SUM(dbo.vwInvoiceRegisterDetail.TaxValue)) AS TaxValue
FROM            dbo.vwInvoiceRegisterDetail INNER JOIN
                         dbo.tbCashCode ON dbo.vwInvoiceRegisterDetail.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                         dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode
GROUP BY dbo.vwInvoiceRegisterDetail.StartOn, dbo.vwInvoiceRegisterDetail.CashCode
GO
ALTER TABLE tbCashTaxType WITH NOCHECK ADD
	CashAccountCode NVARCHAR(10) NULL
GO
ALTER TABLE [dbo].[tbCashTaxType]  WITH CHECK ADD  CONSTRAINT [FK_tbCashTaxType_tbOrgAccount] FOREIGN KEY([CashAccountCode])
REFERENCES [dbo].[tbOrgAccount] ([CashAccountCode])
GO
ALTER TABLE [dbo].[tbCashTaxType] CHECK CONSTRAINT [FK_tbCashTaxType_tbOrgAccount]
GO
ALTER FUNCTION dbo.fnCashCompanyBalance
	()
RETURNS MONEY
AS
	BEGIN
	DECLARE @CurrentBalance MONEY
	
	SELECT  @CurrentBalance = SUM(tbOrgAccount.CurrentBalance)
	FROM         tbOrgAccount 
	WHERE     (tbOrgAccount.AccountClosed = 0)
	
	RETURN ISNULL(@CurrentBalance, 0)
	END
GO
CREATE FUNCTION dbo.fnStatementTaxEntries(@TaxTypeCode smallint)
RETURNS @tbTax TABLE (
	AccountCode nvarchar(10),
	CashCode nvarchar(50),
	TransactOn datetime,
	CashEntryTypeCode smallint,
	ReferenceCode nvarchar(20),
	PayIn money,
	PayOut money	 
	)
AS
	BEGIN
	declare @AccountCode nvarchar(10)
	declare @CashCode nvarchar(50)
	declare @TransactOn datetime
	declare @InvoiceReferenceCode nvarchar(20) 
	declare @OrderReferenceCode nvarchar(20)
	declare @CashEntryTypeCode smallint
	declare @PayOut money
	declare @PayIn money
	declare @Balance money
	
	SET @InvoiceReferenceCode = dbo.fnSystemProfileText(1214)	
	SET @OrderReferenceCode = dbo.fnSystemProfileText(1215)	

	IF @TaxTypeCode = 1
		GOTO CorporationTax
	ELSE IF @TaxTypeCode = 2
		GOTO VatTax

	RETURN

CorporationTax:

	SELECT @AccountCode = AccountCode FROM tbCashTaxType WHERE (TaxTypeCode = 1) 
	SET @CashCode = dbo.fnSystemCashCode(1)
	
	DECLARE curCorp CURSOR LOCAL FOR
		SELECT     StartOn, ROUND(TaxDue, 0) AS PayOut, ROUND(TaxPaid, 0) AS PayIn, Balance
		FROM         vwTaxCorpStatement
		ORDER BY StartOn DESC
	
	OPEN curCorp
	FETCH NEXT FROM curCorp INTO @TransactOn, @PayOut, @PayIn, @Balance
	WHILE (@@FETCH_STATUS = 0 AND ROUND(@Balance, 0) != 0)
		BEGIN		
		IF @PayOut > 0
			BEGIN
			INSERT INTO @tbTax (AccountCode, CashCode, TransactOn, CashEntryTypeCode, ReferenceCode, PayOut, PayIn)
			VALUES (@AccountCode, @CashCode, @TransactOn, 5, @InvoiceReferenceCode, @PayOut, 0)
			END
		ELSE	
			BEGIN	
			SET @PayIn = @PayIn * -1
			INSERT INTO @tbTax (AccountCode, CashCode, TransactOn, CashEntryTypeCode, ReferenceCode, PayOut, PayIn)
			VALUES (@AccountCode, @CashCode, @TransactOn, 5, @InvoiceReferenceCode, 0, @PayIn)			
			END
			
		FETCH NEXT FROM curCorp INTO @TransactOn, @PayOut, @PayIn, @Balance
		END	

	CLOSE curCorp
	DEALLOCATE curCorp
	
	INSERT INTO @tbTax (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)	
	SELECT     @OrderReferenceCode, @AccountCode, StartOn, 5, 0, CorporationTax, @CashCode
	FROM [dbo].[fnTaxCorpOrderTotals](0)
	WHERE CorporationTax > 0	
	
	RETURN

VatTax:

	SELECT @AccountCode = AccountCode FROM tbCashTaxType WHERE (TaxTypeCode = 2) 
	SET @CashCode = dbo.fnSystemCashCode(2)

	DECLARE curVat CURSOR LOCAL FOR
		SELECT     StartOn, ROUND(VatDue, 0) AS PayOut, ROUND(VatPaid, 0) AS PayIn, Balance
		FROM         vwTaxVatStatement
		ORDER BY StartOn DESC
	
	OPEN curVat
	FETCH NEXT FROM curVat INTO @TransactOn, @PayOut, @PayIn, @Balance
	WHILE (@@FETCH_STATUS = 0 AND ROUND(@Balance, 2) != 0)
		BEGIN		
		IF @PayOut != 0
			BEGIN
			INSERT INTO @tbTax (AccountCode, CashCode, TransactOn, CashEntryTypeCode, ReferenceCode, PayOut, PayIn)
			VALUES (@AccountCode, @CashCode, @TransactOn, 6, @InvoiceReferenceCode, @PayOut, 0)
			END
		ELSE	
			BEGIN	
			SET @PayIn = @PayIn * -1
			INSERT INTO @tbTax (AccountCode, CashCode, TransactOn, CashEntryTypeCode, ReferenceCode, PayOut, PayIn)
			VALUES (@AccountCode, @CashCode, @TransactOn, 6, @InvoiceReferenceCode, 0, @PayIn)			
			END
		FETCH NEXT FROM curVat INTO @TransactOn, @PayOut, @PayIn, @Balance
		END	

	CLOSE curVat
	DEALLOCATE curVat	
	
	INSERT INTO @tbTax (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)	
	SELECT     @OrderReferenceCode, @AccountCode, StartOn, 6, PayIn, PayOut, @CashCode
	FROM [dbo].[fnTaxVatOrderTotals](0)
	WHERE PayIn + PayOut > 0
		
	RETURN
	END
GO
ALTER FUNCTION dbo.fnStatementReserves ()
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
	declare @ReferenceCode2 nvarchar(20)
	declare @CashCode nvarchar(50)
	declare @AccountCode nvarchar(10)
	declare @TransactOn datetime
	declare @CashEntryTypeCode smallint
	declare @PayOut money
	declare @PayIn money
	declare @Balance money
	declare @Now datetime

	SELECT @ReferenceCode = dbo.fnSystemProfileText(1219)
	SET @Balance = dbo.fnCashReserveBalance()	
	SELECT @TransactOn = MAX(tbOrgPayment.PaidOn)
	FROM         tbOrgAccount INNER JOIN
						  tbOrgPayment ON tbOrgAccount.CashAccountCode = tbOrgPayment.CashAccountCode LEFT OUTER JOIN
						  tbCashCode ON tbOrgAccount.CashCode = tbCashCode.CashCode
	WHERE     (tbCashCode.CashCode IS NULL)

	SELECT TOP 1 @AccountCode = AccountCode FROM tbSystemOptions
	
	IF @Balance > 0
		BEGIN
		SET @PayOut = 0
		SET @PayIn = @Balance
		END
	ELSE
		BEGIN
		SET @PayOut = @Balance
		SET @PayIn = 0
		END
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, Balance)
	VALUES (@ReferenceCode, @AccountCode, @TransactOn, 1, @PayIn, @PayOut, @Balance)
	
	SET @Balance = 0

	--Corporation Tax
	IF EXISTS (SELECT        tbOrgAccount.CashAccountCode
		FROM            tbCashTaxType INNER JOIN
								 tbOrgAccount ON tbCashTaxType.CashAccountCode = tbOrgAccount.CashAccountCode LEFT OUTER JOIN
								 tbCashCode ON tbOrgAccount.CashCode = tbCashCode.CashCode
		WHERE        (tbCashTaxType.TaxTypeCode = 1) AND (tbCashCode.CashCode IS NULL))
		BEGIN
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
		SELECT ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
		FROM dbo.fnStatementTaxEntries(1)
		ORDER BY TransactOn		
		END

	--VAT
	IF EXISTS (SELECT        tbOrgAccount.CashAccountCode
		FROM            tbCashTaxType INNER JOIN
								 tbOrgAccount ON tbCashTaxType.CashAccountCode = tbOrgAccount.CashAccountCode LEFT OUTER JOIN
								 tbCashCode ON tbOrgAccount.CashCode = tbCashCode.CashCode
		WHERE        (tbCashTaxType.TaxTypeCode = 2) AND (tbCashCode.CashCode IS NULL))
		BEGIN	
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
		SELECT ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
		FROM dbo.fnStatementTaxEntries(2)
		ORDER BY TransactOn		
		END	
	
	declare curReserve cursor local for
		select TransactOn, CashEntryTypeCode, ReferenceCode, PayIn, PayOut, CashCode
		from @tbStatement
		order by TransactOn, CashEntryTypeCode, ReferenceCode, CashCode

	open curReserve
	
	fetch next from curReserve into @TransactOn, @CashEntryTypeCode, @ReferenceCode, @PayIn, @PayOut, @CashCode
	
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
		fetch next from curReserve into @TransactOn, @CashEntryTypeCode, @ReferenceCode, @PayIn, @PayOut, @CashCode
		end
	close curReserve
	deallocate curReserve

	RETURN
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
	set @Balance = dbo.fnCashCompanyBalance()	
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
DROP VIEW dbo.vwStatementCorpTaxDueDate
DROP FUNCTION dbo.fnStatementCorpTax
DROP FUNCTION dbo.fnStatementVat
GO
