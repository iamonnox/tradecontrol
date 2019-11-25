/************************************************************
* Tru-Man Trade Control: Management Information and Cash System
* Copyright Tru-Man Industries Ltd 2008. All Rights Reserved.
* Author: Ian Monnox
* Description: Sql Server Upgrade Script - Encrypted Distribution Schema
* Data Version: 1.09
* Release Date: TBC
* Confidential Information
************************************************************/


/****** Object:  StoredProcedure [dbo].[spTaskDefaultDocType]    Script Date: 02/13/2009 11:54:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskDefaultDocType]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTaskDefaultDocType]
GO
/****** Object:  StoredProcedure [dbo].[spTaskDefaultDocType]    Script Date: 02/13/2009 11:54:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spInvoiceDefaultDocType]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spInvoiceDefaultDocType]
GO
/****** Object:  View [dbo].[vwDocInvoiceItem]    Script Date: 02/13/2009 11:55:40 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwDocInvoiceItem]'))
DROP VIEW [dbo].[vwDocInvoiceItem]
GO
/****** Object:  View [dbo].[vwDocInvoiceTask]    Script Date: 02/13/2009 11:56:05 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwDocInvoiceTask]'))
DROP VIEW [dbo].[vwDocInvoiceTask]
GO
/****** Object:  View [dbo].[vwDocInvoice]    Script Date: 02/13/2009 11:57:45 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwDocInvoice]'))
DROP VIEW [dbo].[vwDocInvoice]
GO
/****** Object:  View [dbo].[vwDocTaskCode]    Script Date: 02/13/2009 11:59:43 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwDocTaskCode]'))
DROP VIEW [dbo].[vwDocTaskCode]
GO
/****** Object:  UserDefinedFunction [dbo].[fnTaskEmailAddress]    Script Date: 02/13/2009 11:58:26 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnTaskEmailAddress]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fnTaskEmailAddress]
GO
/****** Object:  View [dbo].[vwDocCompany]    Script Date: 02/13/2009 11:57:45 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwDocCompany]'))
DROP VIEW [dbo].[vwDocCompany]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.spInvoiceDefaultDocType
	(
		@InvoiceNumber nvarchar(20),
		@DocTypeCode smallint OUTPUT
	)
WITH ENCRYPTION AS
declare @InvoiceType smallint

	SELECT  @InvoiceType = InvoiceTypeCode
	FROM         tbInvoice
	WHERE     (InvoiceNumber = @InvoiceNumber)
	
	set @DocTypeCode = CASE @InvoiceType
							WHEN 1 THEN 5
							WHEN 2 THEN 6							
							WHEN 4 THEN 7
							ELSE 5
							END
							
	RETURN
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.spTaskDefaultDocType
	(
		@TaskCode nvarchar(20),
		@DocTypeCode smallint OUTPUT
	)
WITH ENCRYPTION AS
declare @CashMode smallint
declare @TaskStatus smallint

	if exists(SELECT     CashModeCode
	          FROM         vwTaskCashMode
	          WHERE     (TaskCode = @TaskCode))
		SELECT   @CashMode = CashModeCode
		FROM         vwTaskCashMode
		WHERE     (TaskCode = @TaskCode)			          
	else
		set @CashMode = 2

	SELECT  @TaskStatus =TaskStatusCode
	FROM         tbTask
	WHERE     (TaskCode = @TaskCode)		
	
	if @CashMode = 1
		set @DocTypeCode = CASE @TaskStatus WHEN 1 THEN 3 ELSE 4 END								
	else
		set @DocTypeCode = CASE @TaskStatus WHEN 1 THEN 1 ELSE 2 END 
		
	RETURN 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwDocCompany]
WITH ENCRYPTION AS
SELECT     dbo.tbOrg.AccountName AS CompanyName, dbo.tbOrgAddress.Address AS CompanyAddress, dbo.tbOrg.PhoneNumber AS CompanyPhoneNumber, 
                      dbo.tbOrg.FaxNumber AS CompanyFaxNumber, dbo.tbOrg.EmailAddress AS CompanyEmailAddress, dbo.tbOrg.WebSite AS CompanyWebsite, 
                      dbo.tbOrg.CompanyNumber, dbo.tbOrg.VatNumber, dbo.tbOrg.Logo
FROM         dbo.tbOrg INNER JOIN
                      dbo.tbSystemOptions ON dbo.tbOrg.AccountCode = dbo.tbSystemOptions.AccountCode LEFT OUTER JOIN
                      dbo.tbOrgAddress ON dbo.tbOrg.AddressCode = dbo.tbOrgAddress.AddressCode

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnTaskEmailAddress]
	(
	@TaskCode nvarchar(20)
	)
RETURNS nvarchar(255)
WITH ENCRYPTION AS
	BEGIN
	declare @EmailAddress nvarchar(255)

	if exists(SELECT     tbOrgContact.EmailAddress
		  FROM         tbOrgContact INNER JOIN
								tbTask ON tbOrgContact.AccountCode = tbTask.AccountCode AND tbOrgContact.ContactName = tbTask.ContactName
		  WHERE     (tbTask.TaskCode = @TaskCode)
		  GROUP BY tbOrgContact.EmailAddress
		  HAVING      (NOT (tbOrgContact.EmailAddress IS NULL)))
		begin
		SELECT    @EmailAddress = tbOrgContact.EmailAddress
		FROM         tbOrgContact INNER JOIN
							tbTask ON tbOrgContact.AccountCode = tbTask.AccountCode AND tbOrgContact.ContactName = tbTask.ContactName
		WHERE     (tbTask.TaskCode = @TaskCode)
		GROUP BY tbOrgContact.EmailAddress
		HAVING      (NOT (tbOrgContact.EmailAddress IS NULL))	
		end
	else
		begin
		SELECT    @EmailAddress =  tbOrg.EmailAddress
		FROM         tbOrg INNER JOIN
							 tbTask ON tbOrg.AccountCode = tbTask.AccountCode
		WHERE     (tbTask.TaskCode = @TaskCode)
		end
	
	RETURN @EmailAddress
	END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwDocTaskCode]
WITH ENCRYPTION AS
SELECT     dbo.fnTaskEmailAddress(dbo.tbTask.TaskCode) AS EmailAddress, dbo.tbTask.TaskCode, dbo.tbTaskStatus.TaskStatus, dbo.tbTask.ContactName, 
                      dbo.tbOrgContact.NickName, dbo.tbUser.UserName, dbo.tbOrg.AccountName, dbo.tbOrgAddress.Address AS InvoiceAddress, 
                      tbOrg_1.AccountName AS DeliveryAccountName, tbOrgAddress_1.Address AS DeliveryAddress, tbOrg_2.AccountName AS CollectionAccountName, 
                      tbOrgAddress_2.Address AS CollectionAddress, dbo.tbTask.AccountCode, dbo.tbTask.TaskNotes, dbo.tbTask.ActivityCode, dbo.tbTask.ActionOn, 
                      dbo.tbActivity.UnitOfMeasure, dbo.tbTask.Quantity, dbo.tbSystemTaxCode.TaxCode, dbo.tbSystemTaxCode.TaxRate, dbo.tbTask.UnitCharge, 
                      dbo.tbTask.TotalCharge, dbo.tbUser.MobileNumber, dbo.tbUser.Signature, dbo.tbTask.TaskTitle
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
                      dbo.tbOrgContact ON dbo.tbTask.ContactName = dbo.tbOrgContact.ContactName AND 
                      dbo.tbTask.AccountCode = dbo.tbOrgContact.AccountCode LEFT OUTER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbTask.TaxCode = dbo.tbSystemTaxCode.TaxCode
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwDocInvoice]
WITH ENCRYPTION AS
SELECT     dbo.tbOrg.EmailAddress, dbo.tbUser.UserName, dbo.tbOrg.AccountCode, dbo.tbOrg.AccountName, dbo.tbOrgAddress.Address AS InvoiceAddress, 
                      dbo.tbInvoice.InvoiceNumber, dbo.tbInvoiceType.InvoiceType, dbo.tbInvoiceStatus.InvoiceStatus, dbo.tbInvoice.InvoicedOn, dbo.tbInvoice.CollectOn, 
                      dbo.tbInvoice.InvoiceValue, dbo.tbInvoice.TaxValue, dbo.tbInvoice.PaymentTerms, dbo.tbInvoice.Notes
FROM         dbo.tbInvoice INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode INNER JOIN
                      dbo.tbUser ON dbo.tbInvoice.UserId = dbo.tbUser.UserId INNER JOIN
                      dbo.tbInvoiceStatus ON dbo.tbInvoice.InvoiceStatusCode = dbo.tbInvoiceStatus.InvoiceStatusCode LEFT OUTER JOIN
                      dbo.tbOrgAddress ON dbo.tbOrg.AddressCode = dbo.tbOrgAddress.AddressCode

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwDocInvoiceTask]
WITH ENCRYPTION AS
SELECT     dbo.tbInvoiceTask.InvoiceNumber, dbo.tbInvoiceTask.TaskCode, dbo.tbTask.TaskTitle, dbo.tbTask.ActivityCode, dbo.tbInvoiceTask.CashCode, 
                      dbo.tbCashCode.CashDescription, dbo.tbTask.ActionedOn, dbo.tbInvoiceTask.Quantity, dbo.tbActivity.UnitOfMeasure, dbo.tbInvoiceTask.InvoiceValue, 
                      dbo.tbInvoiceTask.TaxValue, dbo.tbInvoiceTask.TaxCode
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbTask ON dbo.tbInvoiceTask.TaskCode = dbo.tbTask.TaskCode AND dbo.tbInvoiceTask.TaskCode = dbo.tbTask.TaskCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbInvoiceTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbActivity ON dbo.tbTask.ActivityCode = dbo.tbActivity.ActivityCode
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwDocInvoiceItem]
WITH ENCRYPTION AS
SELECT     dbo.tbInvoiceItem.InvoiceNumber, dbo.tbInvoiceItem.CashCode, dbo.tbCashCode.CashDescription, dbo.tbInvoice.InvoicedOn AS ActionedOn, 
                      dbo.tbInvoiceItem.TaxCode, dbo.tbInvoiceItem.InvoiceValue, dbo.tbInvoiceItem.TaxValue, dbo.tbInvoiceItem.ItemReference
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.tbCashCode ON dbo.tbInvoiceItem.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber
GO
