
CREATE OR ALTER VIEW [dbo].[vwDocInvoice]
AS
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
CREATE OR ALTER VIEW [dbo].[vwDocTaskCode]
AS
SELECT     dbo.fnTaskEmailAddress(dbo.tbTask.TaskCode) AS EmailAddress, dbo.tbTask.TaskCode, dbo.tbTask.TaskStatusCode, dbo.tbTaskStatus.TaskStatus, 
                      dbo.tbTask.ContactName, dbo.tbOrgContact.NickName, dbo.tbUser.UserName, dbo.tbOrg.AccountName, dbo.tbOrgAddress.Address AS InvoiceAddress, 
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
