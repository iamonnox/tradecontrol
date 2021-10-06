/************************************************************
* Tru-Man Trade Control: Information and Cash System
* Copyright Trade Control Ltd 2012. All Rights Reserved.
* Author: Ian Monnox
* Description: Sql Server Upgrade Script - Encrypted Distribution Schema
* Data Version: 2.05
* Release Date: 7.03.12
************************************************************/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbProfileCustom]') AND type in (N'U'))
DROP TABLE [dbo].[tbProfileCustom]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbProfileLink]') AND type in (N'U'))
DROP TABLE [dbo].[tbProfileLink]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[tbProfileObject_FK01]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbProfileObject]'))
ALTER TABLE [dbo].[tbProfileObject] DROP CONSTRAINT [tbProfileObject_FK01]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbProfileObjectDetail_tbProfileObject]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbProfileObjectDetail]'))
ALTER TABLE [dbo].[tbProfileObjectDetail] DROP CONSTRAINT [FK_tbProfileObjectDetail_tbProfileObject]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[tbProfileObjectDetail_FK01]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbProfileObjectDetail]'))
ALTER TABLE [dbo].[tbProfileObjectDetail] DROP CONSTRAINT [tbProfileObjectDetail_FK01]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbProfileItemType]') AND type in (N'U'))
DROP TABLE [dbo].[tbProfileItemType]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbProfileObject]') AND type in (N'U'))
DROP TABLE [dbo].[tbProfileObject]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbProfileObjectDetail]') AND type in (N'U'))
DROP TABLE [dbo].[tbProfileObjectDetail]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbProfileObjectType]') AND type in (N'U'))
DROP TABLE [dbo].[tbProfileObjectType]
GO
ALTER FUNCTION dbo.fnTaxCorpStatement
	()
RETURNS @tbCorp TABLE 
	(
	StartOn datetime, 
	TaxDue money ,
	TaxPaid money ,
	Balance money
	)
AS
	BEGIN
	declare @Balance money
	declare @StartOn datetime
	declare @TaxDue money
	declare @TaxPaid money
	
	INSERT INTO @tbCorp (StartOn, TaxDue, TaxPaid, Balance)
	SELECT     StartOn, ROUND(CorporationTax, 2), 0 As TaxPaid, 0 AS Balance
	FROM         fnTaxCorpTotals() fnTaxCorpTotals		
	
	INSERT INTO @tbCorp (StartOn, TaxDue, TaxPaid, Balance)
	SELECT     tbOrgPayment.PaidOn, 0 As TaxDue, (tbOrgPayment.PaidOutValue * -1) + tbOrgPayment.PaidInValue AS TaxPaid, 0 As Balance
	FROM         tbOrgPayment INNER JOIN
	                      vwSystemCorpTaxCashCode ON tbOrgPayment.CashCode = vwSystemCorpTaxCashCode.CashCode	                      

	set @Balance = 0
	
	DECLARE curVS CURSOR LOCAL FOR
		SELECT StartOn, TaxDue, TaxPaid
		FROM @tbCorp
		ORDER BY StartOn, TaxDue
	
	OPEN curVS
	FETCH NEXT FROM curVS INTO @StartOn, @TaxDue, @TaxPaid
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		set @Balance = @Balance + @TaxDue + @TaxPaid
		UPDATE @tbCorp
		SET Balance = @Balance
		WHERE StartOn = @StartOn AND TaxDue = @TaxDue 
		FETCH NEXT FROM curVS INTO @StartOn, @TaxDue, @TaxPaid
		END
	
	CLOSE curVS
	DEALLOCATE curVS	
	RETURN
	END
GO
ALTER VIEW [dbo].[vwDocTaskCode]
AS
SELECT     dbo.fnTaskEmailAddress(dbo.tbTask.TaskCode) AS EmailAddress, dbo.tbTask.TaskCode, dbo.tbTask.TaskStatusCode, dbo.tbTaskStatus.TaskStatus, 
                      dbo.tbTask.ContactName, dbo.tbOrgContact.NickName, dbo.tbUser.UserName, dbo.tbOrg.AccountName, dbo.tbOrgAddress.Address AS InvoiceAddress, 
                      tbOrg_1.AccountName AS DeliveryAccountName, tbOrgAddress_1.Address AS DeliveryAddress, tbOrg_2.AccountName AS CollectionAccountName, 
                      tbOrgAddress_2.Address AS CollectionAddress, dbo.tbTask.AccountCode, dbo.tbTask.TaskNotes, dbo.tbTask.ActivityCode, dbo.tbTask.ActionOn, 
                      dbo.tbActivity.UnitOfMeasure, dbo.tbTask.Quantity, dbo.tbSystemTaxCode.TaxCode, dbo.tbSystemTaxCode.TaxRate, dbo.tbTask.UnitCharge, dbo.tbTask.TotalCharge, 
                      dbo.tbUser.MobileNumber, dbo.tbUser.Signature, dbo.tbTask.TaskTitle, dbo.tbTask.PaymentOn, dbo.tbTask.SecondReference, dbo.tbOrg.PaymentTerms
FROM         dbo.tbOrg AS tbOrg_2 RIGHT OUTER JOIN
                      dbo.tbOrgAddress AS tbOrgAddress_2 ON tbOrg_2.AccountCode = tbOrgAddress_2.AccountCode RIGHT OUTER JOIN
                      dbo.tbTaskStatus INNER JOIN
                      dbo.tbUser INNER JOIN
                      dbo.tbActivity INNER JOIN
                      dbo.tbTask ON dbo.tbActivity.ActivityCode = dbo.tbTask.ActivityCode INNER JOIN
                      dbo.tbOrg ON dbo.tbTask.AccountCode = dbo.tbOrg.AccountCode LEFT OUTER JOIN
                      dbo.tbOrgAddress ON dbo.tbOrg.AddressCode = dbo.tbOrgAddress.AddressCode ON dbo.tbUser.UserId = dbo.tbTask.ActionById ON 
                      dbo.tbTaskStatus.TaskStatusCode = dbo.tbTask.TaskStatusCode LEFT OUTER JOIN
                      dbo.tbOrgAddress AS tbOrgAddress_1 LEFT OUTER JOIN
                      dbo.tbOrg AS tbOrg_1 ON tbOrgAddress_1.AccountCode = tbOrg_1.AccountCode ON dbo.tbTask.AddressCodeTo = tbOrgAddress_1.AddressCode ON 
                      tbOrgAddress_2.AddressCode = dbo.tbTask.AddressCodeFrom LEFT OUTER JOIN
                      dbo.tbOrgContact ON dbo.tbTask.ContactName = dbo.tbOrgContact.ContactName AND dbo.tbTask.AccountCode = dbo.tbOrgContact.AccountCode LEFT OUTER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbTask.TaxCode = dbo.tbSystemTaxCode.TaxCode
GO
