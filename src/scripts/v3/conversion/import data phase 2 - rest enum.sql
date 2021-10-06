/*********************************************************
Trade Control
Import Data from the Version 2 Schema
Release: 3.02.1

Date: 7/5/2018
Author: IaM

Trade Control by Trade Control Ltd is licensed under GNU General Public License v3.0. 

You may obtain a copy of the License at

	https://www.gnu.org/licenses/gpl-3.0.en.html

*********************************************************/

USE misImportDb;
GO
UPDATE dbo.tbActivityAttributeType SET AttributeTypeCode -= 1;
UPDATE tbActivityAttribute SET AttributeTypeCode -= 1;
UPDATE tbTaskAttribute SET AttributeTypeCode -= 1;

UPDATE dbo.tbActivityOpType SET OpTypeCode -= 1;
UPDATE dbo.tbActivityOp SET OpTypeCode -= 1;
UPDATE dbo.tbTaskOp SET OpTypeCode -= 1;

UPDATE dbo.tbCashCategoryType SET CategoryTypeCode -= 1;
UPDATE dbo.tbCashCategory SET CategoryTypeCode -= 1;
UPDATE dbo.tbSystemInstall SET CategoryTypeCode -= 1;

UPDATE dbo.tbCashEntryType SET CashEntryTypeCode -= 1;

UPDATE dbo.tbCashMode SET CashModeCode -= 1;
UPDATE dbo.tbCashCategory SET CashModeCode -= 1;
UPDATE dbo.tbInvoiceType SET CashModeCode -= 1;
UPDATE dbo.tbOrgType SET CashModeCode -= 1;

UPDATE dbo.tbCashStatus SET CashStatusCode -= 1;
UPDATE dbo.tbSystemYear SET CashStatusCode -= 1;
UPDATE dbo.tbSystemYearPeriod SET CashStatusCode -= 1;

UPDATE dbo.tbCashTaxType SET TaxTypeCode -= 1;
UPDATE dbo.tbSystemTaxCode SET TaxTypeCode -= 1;

UPDATE dbo.tbCashType SET CashTypeCode -= 1;
UPDATE dbo.tbCashCategory SET CashTypeCode -= 1;

UPDATE dbo.tbInvoiceStatus SET InvoiceStatusCode -= 1;
UPDATE dbo.tbInvoice SET InvoiceStatusCode -= 1;

UPDATE dbo.tbInvoiceType SET InvoiceTypeCode -= 1;
UPDATE dbo.tbInvoice SET InvoiceTypeCode -= 1;

UPDATE dbo.tbOrgPaymentStatus SET PaymentStatusCode -= 1;
UPDATE dbo.tbOrgPayment SET PaymentStatusCode -= 1;

UPDATE dbo.tbOrgStatus SET OrganisationStatusCode -= 1;
UPDATE dbo.tbOrg SET OrganisationStatusCode -= 1;

UPDATE dbo.tbOrgType SET OrganisationTypeCode -= 1;
UPDATE dbo.tbOrg SET OrganisationTypeCode -= 1;

UPDATE dbo.tbProfileMenuOpenMode SET OpenMode -= 1;
UPDATE dbo.tbProfileMenuEntry SET OpenMode -= 1;
UPDATE dbo.tbSystemDoc SET OpenMode -= 1;

UPDATE dbo.tbSystemBucketInterval SET BucketIntervalCode -= 1;
UPDATE dbo.tbSystemOptions SET BucketIntervalCode -= 1;

UPDATE dbo.tbSystemDocType SET DocTypeCode -= 1;
UPDATE dbo.tbSystemDocSpool SET DocTypeCode -= 1;
UPDATE dbo.tbSystemDoc SET DocTypeCode -= 1;

UPDATE dbo.tbSystemRecurrence SET RecurrenceCode -= 1;
UPDATE dbo.tbCashTaxType SET RecurrenceCode -= 1;

UPDATE dbo.tbTaskOpStatus SET OpStatusCode -= 1;
UPDATE dbo.tbTaskOp SET OpStatusCode -= 1;

UPDATE dbo.tbTaskStatus SET TaskStatusCode -= 1;
UPDATE dbo.tbTask SET TaskStatusCode -= 1;


