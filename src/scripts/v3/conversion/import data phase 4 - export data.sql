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

print 'Cleardown misTradeControl'
SET NOCOUNT ON;
DELETE FROM misTradeControl.Cash.tbCategoryExp
DELETE FROM misTradeControl.Cash.tbCategoryTotal
DELETE FROM misTradeControl.Cash.tbCategory
DELETE FROM misTradeControl.Cash.tbCode
DELETE FROM misTradeControl.App.tbRegister
DELETE FROM misTradeControl.App.tbUom
DELETE FROM misTradeControl.Activity.tbActivity
DELETE FROM misTradeControl.Activity.tbAttribute
DELETE FROM misTradeControl.Activity.tbFlow
DELETE FROM misTradeControl.Activity.tbOpType
DELETE FROM misTradeControl.Activity.tbOp
DELETE FROM misTradeControl.App.tbYear
DELETE FROM misTradeControl.App.tbYearPeriod
DELETE FROM misTradeControl.App.tbMonth
DELETE FROM misTradeControl.Cash.tbPeriod
DELETE FROM misTradeControl.Org.tbStatus
DELETE FROM misTradeControl.Org.tbType
DELETE FROM misTradeControl.App.tbTaxCode
DELETE FROM misTradeControl.Org.tbOrg
DELETE FROM misTradeControl.Org.tbAccount
DELETE FROM misTradeControl.App.tbRecurrence
DELETE FROM misTradeControl.Cash.tbTaxType
DELETE FROM misTradeControl.Invoice.tbStatus
DELETE FROM misTradeControl.Invoice.tbType
DELETE FROM misTradeControl.Usr.tbMenuUser
DELETE FROM misTradeControl.Usr.tbUser
DELETE FROM misTradeControl.Invoice.tbInvoice
DELETE FROM misTradeControl.Invoice.tbItem
DELETE FROM misTradeControl.Org.tbAddress
DELETE FROM misTradeControl.Task.tbStatus
DELETE FROM misTradeControl.Task.tbTask
DELETE FROM misTradeControl.Invoice.tbTask
DELETE FROM misTradeControl.Org.tbContact
DELETE FROM misTradeControl.Org.tbDoc
DELETE FROM misTradeControl.Org.tbPaymentStatus
DELETE FROM misTradeControl.Org.tbPayment
DELETE FROM misTradeControl.Org.tbSector
DELETE FROM misTradeControl.Usr.tbMenu
DELETE FROM misTradeControl.Usr.tbMenuCommand
DELETE FROM misTradeControl.Usr.tbMenuEntry
DELETE FROM misTradeControl.App.tbText
DELETE FROM misTradeControl.App.tbOptions
DELETE FROM misTradeControl.Task.tbAttribute
DELETE FROM misTradeControl.Task.tbDoc
DELETE FROM misTradeControl.Task.tbFlow
DELETE FROM misTradeControl.Task.tbOpStatus
DELETE FROM misTradeControl.Task.tbOp
DELETE FROM misTradeControl.Task.tbQuote
DELETE FROM misTradeControl.Cash.tbCategoryType
DELETE FROM misTradeControl.Cash.tbMode
DELETE FROM misTradeControl.Cash.tbType
DELETE FROM misTradeControl.Cash.tbEntryType
DELETE FROM misTradeControl.Cash.tbStatus
DELETE FROM misTradeControl.Activity.tbAttributeType
DELETE FROM misTradeControl.App.tbCalendar
DELETE FROM misTradeControl.App.tbBucket
DELETE FROM misTradeControl.App.tbBucketInterval
DELETE FROM misTradeControl.App.tbBucketType
DELETE FROM misTradeControl.App.tbCalendarHoliday
DELETE FROM misTradeControl.App.tbCodeExclusion
DELETE FROM misTradeControl.App.tbDoc
DELETE FROM misTradeControl.App.tbDocType
DELETE FROM misTradeControl.App.tbDocSpool
DELETE FROM misTradeControl.Usr.tbMenuOpenMode
GO
print 'misImportDb to misTradeControl'
print 'tbCashCategoryType'
insert into misTradeControl.Cash.tbCategoryType (CategoryTypeCode, CategoryType)
select sourceTb.CategoryTypeCode, sourceTb.CategoryType
from misImportDb.dbo.tbCashCategoryType sourceTb
left outer join  misTradeControl.Cash.tbCategoryType targetTb
ON targetTb.CategoryTypeCode = sourceTb.CategoryTypeCode
WHERE (targetTb.CategoryTypeCode IS NULL)
GO

print 'tbCashMode'
insert into misTradeControl.Cash.tbMode (CashModeCode, CashMode)
select sourceTb.CashModeCode, sourceTb.CashMode
from misImportDb.dbo.tbCashMode sourceTb
left outer join  misTradeControl.Cash.tbMode targetTb
ON targetTb.CashModeCode = sourceTb.CashModeCode
WHERE (targetTb.CashModeCode IS NULL)
GO

print 'tbCashType'
insert into misTradeControl.Cash.tbType (CashTypeCode, CashType)
select sourceTb.CashTypeCode, sourceTb.CashType
from misImportDb.dbo.tbCashType sourceTb
left outer join  misTradeControl.Cash.tbType targetTb
ON targetTb.CashTypeCode = sourceTb.CashTypeCode
WHERE (targetTb.CashTypeCode IS NULL)
GO

print 'tbCashCategory'
insert into misTradeControl.Cash.tbCategory (CategoryCode, Category, CategoryTypeCode, CashModeCode, CashTypeCode, DisplayOrder, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.CategoryCode, sourceTb.Category, sourceTb.CategoryTypeCode, sourceTb.CashModeCode, sourceTb.CashTypeCode, sourceTb.DisplayOrder, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from misImportDb.dbo.tbCashCategory sourceTb
left outer join  misTradeControl.Cash.tbCategory targetTb
ON targetTb.CategoryCode = sourceTb.CategoryCode
WHERE (targetTb.CategoryCode IS NULL)
GO


print 'tbSystemRegister'
insert into misTradeControl.App.tbRegister (RegisterName, NextNumber)
select sourceTb.RegisterName, sourceTb.NextNumber
from misImportDb.dbo.tbSystemRegister sourceTb
left outer join  misTradeControl.App.tbRegister targetTb
ON targetTb.RegisterName = sourceTb.RegisterName
WHERE (targetTb.RegisterName IS NULL)
GO

print 'tbSystemUom'
insert into misTradeControl.App.tbUom (UnitOfMeasure)
select sourceTb.UnitOfMeasure
from misImportDb.dbo.tbSystemUom sourceTb
left outer join  misTradeControl.App.tbUom targetTb
ON targetTb.UnitOfMeasure = sourceTb.UnitOfMeasure
WHERE (targetTb.UnitOfMeasure IS NULL)
GO

print 'tbCashEntryType'
insert into misTradeControl.Cash.tbEntryType (CashEntryTypeCode, CashEntryType)
select sourceTb.CashEntryTypeCode, sourceTb.CashEntryType
from misImportDb.dbo.tbCashEntryType sourceTb
left outer join  misTradeControl.Cash.tbEntryType targetTb
ON targetTb.CashEntryTypeCode = sourceTb.CashEntryTypeCode
WHERE (targetTb.CashEntryTypeCode IS NULL)
GO

print 'tbCashStatus'
insert into misTradeControl.Cash.tbStatus (CashStatusCode, CashStatus)
select sourceTb.CashStatusCode, sourceTb.CashStatus
from misImportDb.dbo.tbCashStatus sourceTb
left outer join  misTradeControl.Cash.tbStatus targetTb
ON targetTb.CashStatusCode = sourceTb.CashStatusCode
WHERE (targetTb.CashStatusCode IS NULL)
GO


print 'tbSystemTaxCode'
insert into misTradeControl.App.tbTaxCode (TaxCode, TaxRate, TaxDescription, TaxTypeCode, UpdatedBy, UpdatedOn)
select sourceTb.TaxCode, sourceTb.TaxRate, sourceTb.TaxDescription, sourceTb.TaxTypeCode, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from misImportDb.dbo.tbSystemTaxCode sourceTb
left outer join  misTradeControl.App.tbTaxCode targetTb
ON targetTb.TaxCode = sourceTb.TaxCode
WHERE (targetTb.TaxCode IS NULL)
GO

print 'tbCashTaxType'
insert into misTradeControl.Cash.tbTaxType (TaxTypeCode, TaxType, CashCode, MonthNumber, RecurrenceCode, AccountCode, CashAccountCode)
select sourceTb.TaxTypeCode, sourceTb.TaxType, sourceTb.CashCode, sourceTb.MonthNumber, sourceTb.RecurrenceCode, sourceTb.AccountCode, sourceTb.CashAccountCode
from misImportDb.dbo.tbCashTaxType sourceTb
left outer join  misTradeControl.Cash.tbTaxType targetTb
ON targetTb.TaxTypeCode = sourceTb.TaxTypeCode
WHERE (targetTb.TaxTypeCode IS NULL)
GO

print 'tbCashCode'
insert into misTradeControl.Cash.tbCode (CashCode, CashDescription, CategoryCode, TaxCode, OpeningBalance, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.CashCode, sourceTb.CashDescription, sourceTb.CategoryCode, sourceTb.TaxCode, sourceTb.OpeningBalance, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from misImportDb.dbo.tbCashCode sourceTb
left outer join  misTradeControl.Cash.tbCode targetTb
ON targetTb.CashCode = sourceTb.CashCode
WHERE (targetTb.CashCode IS NULL)
GO



print 'tbActivity'
insert into misTradeControl.Activity.tbActivity (ActivityCode, TaskStatusCode, DefaultText, UnitOfMeasure, CashCode, UnitCharge, PrintOrder, RegisterName, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.ActivityCode, sourceTb.TaskStatusCode, sourceTb.DefaultText, sourceTb.UnitOfMeasure, sourceTb.CashCode, sourceTb.UnitCharge, sourceTb.PrintOrder, sourceTb.RegisterName, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from misImportDb.dbo.tbActivity sourceTb
left outer join  misTradeControl.Activity.tbActivity targetTb
ON targetTb.ActivityCode = sourceTb.ActivityCode
WHERE (targetTb.ActivityCode IS NULL)
GO

print 'tbActivityAttributeType'
insert into misTradeControl.Activity.tbAttributeType (AttributeTypeCode, AttributeType)
select sourceTb.AttributeTypeCode, sourceTb.AttributeType
from misImportDb.dbo.tbActivityAttributeType sourceTb
left outer join  misTradeControl.Activity.tbAttributeType targetTb
ON targetTb.AttributeTypeCode = sourceTb.AttributeTypeCode
WHERE (targetTb.AttributeTypeCode IS NULL)
GO

print 'tbActivityAttribute'
insert into misTradeControl.Activity.tbAttribute (ActivityCode, Attribute, PrintOrder, AttributeTypeCode, DefaultText, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.ActivityCode, sourceTb.Attribute, sourceTb.PrintOrder, sourceTb.AttributeTypeCode, sourceTb.DefaultText, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from misImportDb.dbo.tbActivityAttribute sourceTb
left outer join  misTradeControl.Activity.tbAttribute targetTb
ON targetTb.ActivityCode = sourceTb.ActivityCode AND targetTb.Attribute = sourceTb.Attribute
WHERE (targetTb.ActivityCode IS NULL)
GO

print 'tbActivityFlow'
insert into misTradeControl.Activity.tbFlow (ParentCode, StepNumber, ChildCode, OffsetDays, UsedOnQuantity, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.ParentCode, sourceTb.StepNumber, sourceTb.ChildCode, sourceTb.OffsetDays, sourceTb.UsedOnQuantity, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from misImportDb.dbo.tbActivityFlow sourceTb
left outer join  misTradeControl.Activity.tbFlow targetTb
ON targetTb.ParentCode = sourceTb.ParentCode AND targetTb.StepNumber = sourceTb.StepNumber
WHERE (targetTb.ParentCode IS NULL)
GO

print 'tbActivityOpType'
insert into misTradeControl.Activity.tbOpType (OpTypeCode, OpType)
select sourceTb.OpTypeCode, sourceTb.OpType
from misImportDb.dbo.tbActivityOpType sourceTb
left outer join  misTradeControl.Activity.tbOpType targetTb
ON targetTb.OpTypeCode = sourceTb.OpTypeCode
WHERE (targetTb.OpTypeCode IS NULL)
GO

print 'tbActivityOp'
insert into misTradeControl.Activity.tbOp (ActivityCode, OperationNumber, OpTypeCode, Operation, Duration, OffsetDays, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.ActivityCode, sourceTb.OperationNumber, sourceTb.OpTypeCode, sourceTb.Operation, sourceTb.Duration, sourceTb.OffsetDays, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from misImportDb.dbo.tbActivityOp sourceTb
left outer join  misTradeControl.Activity.tbOp targetTb
ON targetTb.ActivityCode = sourceTb.ActivityCode AND targetTb.OperationNumber = sourceTb.OperationNumber
WHERE (targetTb.ActivityCode IS NULL)
GO

print 'tbCashCategoryExp'
insert into misTradeControl.Cash.tbCategoryExp (CategoryCode, Expression, Format)
select sourceTb.CategoryCode, sourceTb.Expression, sourceTb.Format
from misImportDb.dbo.tbCashCategoryExp sourceTb
left outer join  misTradeControl.Cash.tbCategoryExp targetTb
ON targetTb.CategoryCode = sourceTb.CategoryCode
WHERE (targetTb.CategoryCode IS NULL)
GO

print 'tbCashCategoryTotal'
insert into misTradeControl.Cash.tbCategoryTotal (ParentCode, ChildCode)
select sourceTb.ParentCode, sourceTb.ChildCode
from misImportDb.dbo.tbCashCategoryTotal sourceTb
left outer join  misTradeControl.Cash.tbCategoryTotal targetTb
ON targetTb.ParentCode = sourceTb.ParentCode AND targetTb.ChildCode = sourceTb.ChildCode
WHERE (targetTb.ParentCode IS NULL)
GO


print 'tbSystemMonth'
insert into misTradeControl.App.tbMonth (MonthNumber, MonthName)
select sourceTb.MonthNumber, sourceTb.MonthName
from misImportDb.dbo.tbSystemMonth sourceTb
left outer join  misTradeControl.App.tbMonth targetTb
ON targetTb.MonthNumber = sourceTb.MonthNumber
WHERE (targetTb.MonthNumber IS NULL)
GO

print 'tbSystemYear'
insert into misTradeControl.App.tbYear (YearNumber, StartMonth, CashStatusCode, Description, InsertedBy, InsertedOn)
select sourceTb.YearNumber, sourceTb.StartMonth, sourceTb.CashStatusCode, sourceTb.Description, sourceTb.InsertedBy, sourceTb.InsertedOn
from misImportDb.dbo.tbSystemYear sourceTb
left outer join  misTradeControl.App.tbYear targetTb
ON targetTb.YearNumber = sourceTb.YearNumber
WHERE (targetTb.YearNumber IS NULL)
GO

print 'tbSystemYearPeriod'
insert into misTradeControl.App.tbYearPeriod (YearNumber, StartOn, MonthNumber, CashStatusCode, InsertedBy, InsertedOn, CorporationTaxRate, TaxAdjustment, VatAdjustment)
select sourceTb.YearNumber, sourceTb.StartOn, sourceTb.MonthNumber, sourceTb.CashStatusCode, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.CorporationTaxRate, sourceTb.TaxAdjustment, sourceTb.VatAdjustment
from misImportDb.dbo.tbSystemYearPeriod sourceTb
left outer join  misTradeControl.App.tbYearPeriod targetTb
ON targetTb.YearNumber = sourceTb.YearNumber AND targetTb.StartOn = sourceTb.StartOn
WHERE (targetTb.YearNumber IS NULL)
GO

print 'tbCashPeriod'
insert into misTradeControl.Cash.tbPeriod (CashCode, StartOn, ForecastValue, ForecastTax, InvoiceValue, InvoiceTax, Note)
select sourceTb.CashCode, sourceTb.StartOn, sourceTb.ForecastValue, sourceTb.ForecastTax, sourceTb.InvoiceValue, sourceTb.InvoiceTax, sourceTb.Note
from misImportDb.dbo.tbCashPeriod sourceTb
left outer join  misTradeControl.Cash.tbPeriod targetTb
ON targetTb.CashCode = sourceTb.CashCode AND targetTb.StartOn = sourceTb.StartOn
WHERE (targetTb.CashCode IS NULL)
GO

print 'tbOrgStatus'
insert into misTradeControl.Org.tbStatus (OrganisationStatusCode, OrganisationStatus)
select sourceTb.OrganisationStatusCode, sourceTb.OrganisationStatus
from misImportDb.dbo.tbOrgStatus sourceTb
left outer join  misTradeControl.Org.tbStatus targetTb
ON targetTb.OrganisationStatusCode = sourceTb.OrganisationStatusCode
WHERE (targetTb.OrganisationStatusCode IS NULL)
GO

print 'tbOrgType'
insert into misTradeControl.Org.tbType (OrganisationTypeCode, CashModeCode, OrganisationType)
select sourceTb.OrganisationTypeCode, sourceTb.CashModeCode, sourceTb.OrganisationType
from misImportDb.dbo.tbOrgType sourceTb
left outer join  misTradeControl.Org.tbType targetTb
ON targetTb.OrganisationTypeCode = sourceTb.OrganisationTypeCode
WHERE (targetTb.OrganisationTypeCode IS NULL)
GO


print 'tbOrg'
insert into misTradeControl.Org.tbOrg (AccountCode, AccountName, OrganisationTypeCode, OrganisationStatusCode, TaxCode, AddressCode, AreaCode, PhoneNumber, FaxNumber, EmailAddress, WebSite, IndustrySector, AccountSource, PaymentTerms, NumberOfEmployees, CompanyNumber, VatNumber, Turnover, StatementDays, OpeningBalance, CurrentBalance, ForeignJurisdiction, BusinessDescription, Logo, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, PaymentDays, PayDaysFromMonthEnd)
select sourceTb.AccountCode, sourceTb.AccountName, sourceTb.OrganisationTypeCode, sourceTb.OrganisationStatusCode, sourceTb.TaxCode, sourceTb.AddressCode, sourceTb.AreaCode, sourceTb.PhoneNumber, sourceTb.FaxNumber, sourceTb.EmailAddress, sourceTb.WebSite, sourceTb.IndustrySector, sourceTb.AccountSource, sourceTb.PaymentTerms, sourceTb.NumberOfEmployees, sourceTb.CompanyNumber, sourceTb.VatNumber, sourceTb.Turnover, sourceTb.StatementDays, sourceTb.OpeningBalance, sourceTb.CurrentBalance, sourceTb.ForeignJurisdiction, sourceTb.BusinessDescription, sourceTb.Logo, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn, sourceTb.PaymentDays, sourceTb.PayDaysFromMonthEnd
from misImportDb.dbo.tbOrg sourceTb
left outer join  misTradeControl.Org.tbOrg targetTb
ON targetTb.AccountCode = sourceTb.AccountCode
WHERE (targetTb.AccountCode IS NULL)
GO

print 'tbOrgAccount'
insert into misTradeControl.Org.tbAccount (CashAccountCode, AccountCode, CashAccountName, OpeningBalance, CurrentBalance, SortCode, AccountNumber, CashCode, AccountClosed, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.CashAccountCode, sourceTb.AccountCode, sourceTb.CashAccountName, sourceTb.OpeningBalance, sourceTb.CurrentBalance, sourceTb.SortCode, sourceTb.AccountNumber, sourceTb.CashCode, sourceTb.AccountClosed, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from misImportDb.dbo.tbOrgAccount sourceTb
left outer join  misTradeControl.Org.tbAccount targetTb
ON targetTb.CashAccountCode = sourceTb.CashAccountCode
WHERE (targetTb.CashAccountCode IS NULL)
GO

print 'tbSystemRecurrence'
insert into misTradeControl.App.tbRecurrence (RecurrenceCode, Recurrence)
select sourceTb.RecurrenceCode, sourceTb.Recurrence
from misImportDb.dbo.tbSystemRecurrence sourceTb
left outer join  misTradeControl.App.tbRecurrence targetTb
ON targetTb.RecurrenceCode = sourceTb.RecurrenceCode
WHERE (targetTb.RecurrenceCode IS NULL)
GO


print 'tbInvoiceStatus'
insert into misTradeControl.Invoice.tbStatus (InvoiceStatusCode, InvoiceStatus)
select sourceTb.InvoiceStatusCode, sourceTb.InvoiceStatus
from misImportDb.dbo.tbInvoiceStatus sourceTb
left outer join  misTradeControl.Invoice.tbStatus targetTb
ON targetTb.InvoiceStatusCode = sourceTb.InvoiceStatusCode
WHERE (targetTb.InvoiceStatusCode IS NULL)
GO

print 'tbInvoiceType'
insert into misTradeControl.Invoice.tbType (InvoiceTypeCode, InvoiceType, CashModeCode, NextNumber)
select sourceTb.InvoiceTypeCode, sourceTb.InvoiceType, sourceTb.CashModeCode, sourceTb.NextNumber
from misImportDb.dbo.tbInvoiceType sourceTb
left outer join  misTradeControl.Invoice.tbType targetTb
ON targetTb.InvoiceTypeCode = sourceTb.InvoiceTypeCode
WHERE (targetTb.InvoiceTypeCode IS NULL)
GO

print 'tbSystemCalendar'
insert into misTradeControl.App.tbCalendar (CalendarCode, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday)
select sourceTb.CalendarCode, sourceTb.Monday, sourceTb.Tuesday, sourceTb.Wednesday, sourceTb.Thursday, sourceTb.Friday, sourceTb.Saturday, sourceTb.Sunday
from misImportDb.dbo.tbSystemCalendar sourceTb
left outer join  misTradeControl.App.tbCalendar targetTb
ON targetTb.CalendarCode = sourceTb.CalendarCode
WHERE (targetTb.CalendarCode IS NULL)
GO

print 'tbUser'
insert into misTradeControl.Usr.tbUser (UserId, UserName, LogonName, CalendarCode, PhoneNumber, MobileNumber, FaxNumber, EmailAddress, Address, Administrator, Avatar, Signature, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, NextTaskNumber)
select sourceTb.UserId, sourceTb.UserName, sourceTb.LogonName, sourceTb.CalendarCode, sourceTb.PhoneNumber, sourceTb.MobileNumber, sourceTb.FaxNumber, sourceTb.EmailAddress, sourceTb.Address, sourceTb.Administrator, sourceTb.Avatar, sourceTb.Signature, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn, sourceTb.NextTaskNumber
from misImportDb.dbo.tbUser sourceTb
left outer join  misTradeControl.Usr.tbUser targetTb
ON targetTb.UserId = sourceTb.UserId
WHERE (targetTb.UserId IS NULL)
GO

print 'tbInvoice'
insert into misTradeControl.Invoice.tbInvoice (InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Notes, Printed, Spooled, CollectOn)
select sourceTb.InvoiceNumber, sourceTb.UserId, sourceTb.AccountCode, sourceTb.InvoiceTypeCode, sourceTb.InvoiceStatusCode, sourceTb.InvoicedOn, sourceTb.InvoiceValue, sourceTb.TaxValue, sourceTb.PaidValue, sourceTb.PaidTaxValue, sourceTb.PaymentTerms, sourceTb.Notes, sourceTb.Printed, sourceTb.Spooled, sourceTb.CollectOn
from misImportDb.dbo.tbInvoice sourceTb
left outer join  misTradeControl.Invoice.tbInvoice targetTb
ON targetTb.InvoiceNumber = sourceTb.InvoiceNumber
WHERE (targetTb.InvoiceNumber IS NULL)
GO

print 'tbInvoiceItem'
insert into misTradeControl.Invoice.tbItem (InvoiceNumber, CashCode, TaxCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, ItemReference)
select sourceTb.InvoiceNumber, sourceTb.CashCode, sourceTb.TaxCode, sourceTb.InvoiceValue, sourceTb.TaxValue, sourceTb.PaidValue, sourceTb.PaidTaxValue, sourceTb.ItemReference
from misImportDb.dbo.tbInvoiceItem sourceTb
left outer join  misTradeControl.Invoice.tbItem targetTb
ON targetTb.InvoiceNumber = sourceTb.InvoiceNumber AND targetTb.CashCode = sourceTb.CashCode
WHERE (targetTb.InvoiceNumber IS NULL)
GO

print 'tbOrgAddress'
insert into misTradeControl.Org.tbAddress (AddressCode, AccountCode, Address, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.AddressCode, sourceTb.AccountCode, sourceTb.Address, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from misImportDb.dbo.tbOrgAddress sourceTb
left outer join  misTradeControl.Org.tbAddress targetTb
ON targetTb.AddressCode = sourceTb.AddressCode
WHERE (targetTb.AddressCode IS NULL)
GO

print 'tbTaskStatus'
insert into misTradeControl.Task.tbStatus (TaskStatusCode, TaskStatus)
select sourceTb.TaskStatusCode, sourceTb.TaskStatus
from misImportDb.dbo.tbTaskStatus sourceTb
left outer join  misTradeControl.Task.tbStatus targetTb
ON targetTb.TaskStatusCode = sourceTb.TaskStatusCode
WHERE (targetTb.TaskStatusCode IS NULL)
GO

print 'tbTask'
insert into misTradeControl.Task.tbTask (TaskCode, UserId, AccountCode, TaskTitle, ContactName, ActivityCode, TaskStatusCode, ActionById, ActionOn, ActionedOn, PaymentOn, SecondReference, TaskNotes, Quantity, CashCode, TaxCode, UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, Printed, Spooled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.TaskCode, sourceTb.UserId, sourceTb.AccountCode, sourceTb.TaskTitle, sourceTb.ContactName, sourceTb.ActivityCode, sourceTb.TaskStatusCode, sourceTb.ActionById, sourceTb.ActionOn, sourceTb.ActionedOn, sourceTb.PaymentOn, sourceTb.SecondReference, sourceTb.TaskNotes, sourceTb.Quantity, sourceTb.CashCode, sourceTb.TaxCode, sourceTb.UnitCharge, sourceTb.TotalCharge, sourceTb.AddressCodeFrom, sourceTb.AddressCodeTo, sourceTb.Printed, sourceTb.Spooled, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from misImportDb.dbo.tbTask sourceTb
left outer join  misTradeControl.Task.tbTask targetTb
ON targetTb.TaskCode = sourceTb.TaskCode
WHERE (targetTb.TaskCode IS NULL)
GO

print 'tbInvoiceTask'
insert into misTradeControl.Invoice.tbTask (InvoiceNumber, TaskCode, Quantity, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, CashCode, TaxCode)
select sourceTb.InvoiceNumber, sourceTb.TaskCode, sourceTb.Quantity, sourceTb.InvoiceValue, sourceTb.TaxValue, sourceTb.PaidValue, sourceTb.PaidTaxValue, sourceTb.CashCode, sourceTb.TaxCode
from misImportDb.dbo.tbInvoiceTask sourceTb
left outer join  misTradeControl.Invoice.tbTask targetTb
ON targetTb.InvoiceNumber = sourceTb.InvoiceNumber AND targetTb.TaskCode = sourceTb.TaskCode
WHERE (targetTb.InvoiceNumber IS NULL)
GO

print 'tbOrgContact'
insert into misTradeControl.Org.tbContact (AccountCode, ContactName, FileAs, OnMailingList, NameTitle, NickName, JobTitle, PhoneNumber, MobileNumber, FaxNumber, EmailAddress, Hobby, DateOfBirth, Department, SpouseName, Information, Photo, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, HomeNumber)
select sourceTb.AccountCode, sourceTb.ContactName, sourceTb.FileAs, sourceTb.OnMailingList, sourceTb.NameTitle, sourceTb.NickName, sourceTb.JobTitle, sourceTb.PhoneNumber, sourceTb.MobileNumber, sourceTb.FaxNumber, sourceTb.EmailAddress, sourceTb.Hobby, sourceTb.DateOfBirth, sourceTb.Department, sourceTb.SpouseName, sourceTb.Information, sourceTb.Photo, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn, sourceTb.HomeNumber
from misImportDb.dbo.tbOrgContact sourceTb
left outer join  misTradeControl.Org.tbContact targetTb
ON targetTb.AccountCode = sourceTb.AccountCode AND targetTb.ContactName = sourceTb.ContactName
WHERE (targetTb.AccountCode IS NULL)
GO

print 'tbOrgDoc'
insert into misTradeControl.Org.tbDoc (AccountCode, DocumentName, DocumentDescription, DocumentImage, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.AccountCode, sourceTb.DocumentName, sourceTb.DocumentDescription, sourceTb.DocumentImage, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from misImportDb.dbo.tbOrgDoc sourceTb
left outer join  misTradeControl.Org.tbDoc targetTb
ON targetTb.AccountCode = sourceTb.AccountCode AND targetTb.DocumentName = sourceTb.DocumentName
WHERE (targetTb.AccountCode IS NULL)
GO

print 'tbOrgPaymentStatus'
insert into misTradeControl.Org.tbPaymentStatus (PaymentStatusCode, PaymentStatus)
select sourceTb.PaymentStatusCode, sourceTb.PaymentStatus
from misImportDb.dbo.tbOrgPaymentStatus sourceTb
left outer join  misTradeControl.Org.tbPaymentStatus targetTb
ON targetTb.PaymentStatusCode = sourceTb.PaymentStatusCode
WHERE (targetTb.PaymentStatusCode IS NULL)
GO

print 'tbOrgPayment'
insert into misTradeControl.Org.tbPayment (PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, TaxInValue, TaxOutValue, PaymentReference, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.PaymentCode, sourceTb.UserId, sourceTb.PaymentStatusCode, sourceTb.AccountCode, sourceTb.CashAccountCode, sourceTb.CashCode, sourceTb.TaxCode, sourceTb.PaidOn, sourceTb.PaidInValue, sourceTb.PaidOutValue, sourceTb.TaxInValue, sourceTb.TaxOutValue, sourceTb.PaymentReference, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from misImportDb.dbo.tbOrgPayment sourceTb
left outer join  misTradeControl.Org.tbPayment targetTb
ON targetTb.PaymentCode = sourceTb.PaymentCode
WHERE (targetTb.PaymentCode IS NULL)
GO

print 'tbOrgSector'
insert into misTradeControl.Org.tbSector (AccountCode, IndustrySector)
select sourceTb.AccountCode, sourceTb.IndustrySector
from misImportDb.dbo.tbOrgSector sourceTb
left outer join  misTradeControl.Org.tbSector targetTb
ON targetTb.AccountCode = sourceTb.AccountCode AND targetTb.IndustrySector = sourceTb.IndustrySector
WHERE (targetTb.AccountCode IS NULL)
GO

print 'tbProfileMenu'
set identity_insert misTradeControl.Usr.tbMenu on
insert into misTradeControl.Usr.tbMenu (MenuId, MenuName, InsertedOn, InsertedBy)
select sourceTb.MenuId, sourceTb.MenuName, sourceTb.InsertedOn, sourceTb.InsertedBy
from misImportDb.dbo.tbProfileMenu sourceTb
left outer join  misTradeControl.Usr.tbMenu targetTb
ON targetTb.MenuId = sourceTb.MenuId
WHERE (targetTb.MenuId IS NULL)
set identity_insert misTradeControl.Usr.tbMenu off
GO

print 'tbProfileMenuCommand'
insert into misTradeControl.Usr.tbMenuCommand (Command, CommandText)
select sourceTb.Command, sourceTb.CommandText
from misImportDb.dbo.tbProfileMenuCommand sourceTb
left outer join  misTradeControl.Usr.tbMenuCommand targetTb
ON targetTb.Command = sourceTb.Command
WHERE (targetTb.Command IS NULL)
GO

print 'tbProfileMenuOpenMode'
insert into misTradeControl.Usr.tbMenuOpenMode (OpenMode, OpenModeDescription)
select sourceTb.OpenMode, sourceTb.OpenModeDescription
from misImportDb.dbo.tbProfileMenuOpenMode sourceTb
left outer join  misTradeControl.Usr.tbMenuOpenMode targetTb
ON targetTb.OpenMode = sourceTb.OpenMode
WHERE (targetTb.OpenMode IS NULL)
GO

print 'tbProfileMenuEntry'
set identity_insert misTradeControl.Usr.tbMenuEntry on
insert into misTradeControl.Usr.tbMenuEntry (MenuId, EntryId, FolderId, ItemId, ItemText, Command, ProjectName, Argument, OpenMode, UpdatedOn, InsertedOn, UpdatedBy)
select sourceTb.MenuId, sourceTb.EntryId, sourceTb.FolderId, sourceTb.ItemId, sourceTb.ItemText, sourceTb.Command, sourceTb.ProjectName, sourceTb.Argument, sourceTb.OpenMode, sourceTb.UpdatedOn, sourceTb.InsertedOn, sourceTb.UpdatedBy
from misImportDb.dbo.tbProfileMenuEntry sourceTb
left outer join  misTradeControl.Usr.tbMenuEntry targetTb
ON targetTb.MenuId = sourceTb.MenuId AND targetTb.EntryId = sourceTb.EntryId
WHERE (targetTb.MenuId IS NULL)
set identity_insert misTradeControl.Usr.tbMenuEntry off
GO

print 'tbProfileText'
insert into misTradeControl.App.tbText (TextId, Message, Arguments)
select sourceTb.TextId, sourceTb.Message, sourceTb.Arguments
from misImportDb.dbo.tbProfileText sourceTb
left outer join  misTradeControl.App.tbText targetTb
ON targetTb.TextId = sourceTb.TextId
WHERE (targetTb.TextId IS NULL)
GO

print 'tbSystemBucket'
insert into misTradeControl.App.tbBucket (Period, BucketId, BucketDescription, AllowForecasts)
select sourceTb.Period, sourceTb.BucketId, sourceTb.BucketDescription, sourceTb.AllowForecasts
from misImportDb.dbo.tbSystemBucket sourceTb
left outer join  misTradeControl.App.tbBucket targetTb
ON targetTb.Period = sourceTb.Period
WHERE (targetTb.Period IS NULL)
GO

print 'tbSystemBucketInterval'
insert into misTradeControl.App.tbBucketInterval (BucketIntervalCode, BucketInterval)
select sourceTb.BucketIntervalCode, sourceTb.BucketInterval
from misImportDb.dbo.tbSystemBucketInterval sourceTb
left outer join  misTradeControl.App.tbBucketInterval targetTb
ON targetTb.BucketIntervalCode = sourceTb.BucketIntervalCode
WHERE (targetTb.BucketIntervalCode IS NULL)
GO

print 'tbSystemBucketType'
insert into misTradeControl.App.tbBucketType (BucketTypeCode, BucketType)
select sourceTb.BucketTypeCode, sourceTb.BucketType
from misImportDb.dbo.tbSystemBucketType sourceTb
left outer join  misTradeControl.App.tbBucketType targetTb
ON targetTb.BucketTypeCode = sourceTb.BucketTypeCode
WHERE (targetTb.BucketTypeCode IS NULL)
GO

print 'tbSystemCalendarHoliday'
insert into misTradeControl.App.tbCalendarHoliday (CalendarCode, UnavailableOn)
select sourceTb.CalendarCode, sourceTb.UnavailableOn
from misImportDb.dbo.tbSystemCalendarHoliday sourceTb
left outer join  misTradeControl.App.tbCalendarHoliday targetTb
ON targetTb.CalendarCode = sourceTb.CalendarCode AND targetTb.UnavailableOn = sourceTb.UnavailableOn
WHERE (targetTb.CalendarCode IS NULL)
GO

print 'tbSystemCodeExclusion'
insert into misTradeControl.App.tbCodeExclusion (ExcludedTag)
select sourceTb.ExcludedTag
from misImportDb.dbo.tbSystemCodeExclusion sourceTb
left outer join  misTradeControl.App.tbCodeExclusion targetTb
ON targetTb.ExcludedTag = sourceTb.ExcludedTag
WHERE (targetTb.ExcludedTag IS NULL)
GO

print 'tbSystemDoc'
insert into misTradeControl.App.tbDoc (DocTypeCode, ReportName, OpenMode, Description)
select sourceTb.DocTypeCode, sourceTb.ReportName, sourceTb.OpenMode, sourceTb.Description
from misImportDb.dbo.tbSystemDoc sourceTb
left outer join  misTradeControl.App.tbDoc targetTb
ON targetTb.DocTypeCode = sourceTb.DocTypeCode AND targetTb.ReportName = sourceTb.ReportName
WHERE (targetTb.DocTypeCode IS NULL)
GO

print 'tbSystemDocType'
insert into misTradeControl.App.tbDocType (DocTypeCode, DocType)
select sourceTb.DocTypeCode, sourceTb.DocType
from misImportDb.dbo.tbSystemDocType sourceTb
left outer join  misTradeControl.App.tbDocType targetTb
ON targetTb.DocTypeCode = sourceTb.DocTypeCode
WHERE (targetTb.DocTypeCode IS NULL)
GO

print 'tbSystemDocSpool'
insert into misTradeControl.App.tbDocSpool (UserName, DocTypeCode, DocumentNumber, SpooledOn)
select sourceTb.UserName, sourceTb.DocTypeCode, sourceTb.DocumentNumber, sourceTb.SpooledOn
from misImportDb.dbo.tbSystemDocSpool sourceTb
left outer join  misTradeControl.App.tbDocSpool targetTb
ON targetTb.UserName = sourceTb.UserName AND targetTb.DocTypeCode = sourceTb.DocTypeCode AND targetTb.DocumentNumber = sourceTb.DocumentNumber
WHERE (targetTb.UserName IS NULL)
GO

print 'tbSystemOptions'
insert into misTradeControl.App.tbOptions (Identifier, Initialised, SQLDataVersion, AccountCode, DefaultPrintMode, BucketTypeCode, BucketIntervalCode, ShowCashGraphs, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, NetProfitCode, NetProfitTaxCode, ScheduleOps, TaxHorizon)
select sourceTb.Identifier, sourceTb.Initialised, '3.02' AS SQLDataVersion, sourceTb.AccountCode, sourceTb.DefaultPrintMode, sourceTb.BucketTypeCode, sourceTb.BucketIntervalCode, sourceTb.ShowCashGraphs, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn, sourceTb.NetProfitCode, sourceTb.NetProfitTaxCode, sourceTb.ScheduleOps, sourceTb.TaxHorizon
from misImportDb.dbo.tbSystemOptions sourceTb
left outer join  misTradeControl.App.tbOptions targetTb
ON targetTb.Identifier = sourceTb.Identifier
WHERE (targetTb.Identifier IS NULL)
GO

print 'tbTaskAttribute'
insert into misTradeControl.Task.tbAttribute (TaskCode, Attribute, PrintOrder, AttributeTypeCode, AttributeDescription, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.TaskCode, sourceTb.Attribute, sourceTb.PrintOrder, sourceTb.AttributeTypeCode, sourceTb.AttributeDescription, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from misImportDb.dbo.tbTaskAttribute sourceTb
left outer join  misTradeControl.Task.tbAttribute targetTb
ON targetTb.TaskCode = sourceTb.TaskCode AND targetTb.Attribute = sourceTb.Attribute
WHERE (targetTb.TaskCode IS NULL)
GO

print 'tbTaskDoc'
insert into misTradeControl.Task.tbDoc (TaskCode, DocumentName, DocumentDescription, DocumentImage, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.TaskCode, sourceTb.DocumentName, sourceTb.DocumentDescription, sourceTb.DocumentImage, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from misImportDb.dbo.tbTaskDoc sourceTb
left outer join  misTradeControl.Task.tbDoc targetTb
ON targetTb.TaskCode = sourceTb.TaskCode AND targetTb.DocumentName = sourceTb.DocumentName
WHERE (targetTb.TaskCode IS NULL)
GO

print 'tbTaskFlow'
insert into misTradeControl.Task.tbFlow (ParentTaskCode, StepNumber, ChildTaskCode, UsedOnQuantity, OffsetDays, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.ParentTaskCode, sourceTb.StepNumber, sourceTb.ChildTaskCode, sourceTb.UsedOnQuantity, sourceTb.OffsetDays, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from misImportDb.dbo.tbTaskFlow sourceTb
left outer join  misTradeControl.Task.tbFlow targetTb
ON targetTb.ParentTaskCode = sourceTb.ParentTaskCode AND targetTb.StepNumber = sourceTb.StepNumber
WHERE (targetTb.ParentTaskCode IS NULL)
GO

print 'tbTaskOpStatus'
insert into misTradeControl.Task.tbOpStatus (OpStatusCode, OpStatus)
select sourceTb.OpStatusCode, sourceTb.OpStatus
from misImportDb.dbo.tbTaskOpStatus sourceTb
left outer join  misTradeControl.Task.tbOpStatus targetTb
ON targetTb.OpStatusCode = sourceTb.OpStatusCode
WHERE (targetTb.OpStatusCode IS NULL)
GO

print 'tbTaskOp'
insert into misTradeControl.Task.tbOp (TaskCode, OperationNumber, UserId, OpTypeCode, OpStatusCode, Operation, Note, StartOn, EndOn, Duration, OffsetDays, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.TaskCode, sourceTb.OperationNumber, sourceTb.UserId, sourceTb.OpTypeCode, sourceTb.OpStatusCode, sourceTb.Operation, sourceTb.Note, sourceTb.StartOn, sourceTb.EndOn, sourceTb.Duration, sourceTb.OffsetDays, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from misImportDb.dbo.tbTaskOp sourceTb
left outer join  misTradeControl.Task.tbOp targetTb
ON targetTb.TaskCode = sourceTb.TaskCode AND targetTb.OperationNumber = sourceTb.OperationNumber
WHERE (targetTb.TaskCode IS NULL)
GO

print 'tbTaskQuote'
insert into misTradeControl.Task.tbQuote (TaskCode, Quantity, TotalPrice, RunOnQuantity, RunOnPrice, RunBackQuantity, RunBackPrice, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.TaskCode, sourceTb.Quantity, sourceTb.TotalPrice, sourceTb.RunOnQuantity, sourceTb.RunOnPrice, sourceTb.RunBackQuantity, sourceTb.RunBackPrice, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from misImportDb.dbo.tbTaskQuote sourceTb
left outer join  misTradeControl.Task.tbQuote targetTb
ON targetTb.TaskCode = sourceTb.TaskCode AND targetTb.Quantity = sourceTb.Quantity
WHERE (targetTb.TaskCode IS NULL)
GO

print 'tbUserMenu'
insert into misTradeControl.Usr.tbMenuUser (UserId, MenuId)
select sourceTb.UserId, sourceTb.MenuId
from misImportDb.dbo.tbUserMenu sourceTb
left outer join  misTradeControl.Usr.tbMenuUser targetTb
ON targetTb.UserId = sourceTb.UserId AND targetTb.MenuId = sourceTb.MenuId
WHERE (targetTb.UserId IS NULL)
GO
USE misTradeControl;
GO
SET NOCOUNT OFF;

GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Activity_tbAttribute] ON [Activity].[tbAttribute]
(
	[Attribute] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Activity_tbAttribute_DefaultText] ON [Activity].[tbAttribute]
(
	[DefaultText] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Activity_tbAttribute_OrderBy] ON [Activity].[tbAttribute]
(
	[ActivityCode] ASC,
	[PrintOrder] ASC,
	[Attribute] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Activity_tbAttribute_Type_OrderBy] ON [Activity].[tbAttribute]
(
	[ActivityCode] ASC,
	[AttributeTypeCode] ASC,
	[PrintOrder] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IDX_ChildCodeParentCode] ON [Activity].[tbFlow]
(
	[ChildCode] ASC,
	[ParentCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IDX_ParentCodeChildCode] ON [Activity].[tbFlow]
(
	[ParentCode] ASC,
	[ChildCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Activity_tbOp_Operation] ON [Activity].[tbOp]
(
	[Operation] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [RDX_App_tbCalendarHoliday_CalendarCode] ON [App].[tbCalendarHoliday]
(
	[CalendarCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [RDX_App_tbDocSpool_DocTypeCode] ON [App].[tbDocSpool]
(
	[DocTypeCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_App_tbTaxCodeByType] ON [App].[tbTaxCode]
(
	[TaxTypeCode] ASC,
	[TaxCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Cash_tbCategory_DisplayOrder] ON [Cash].[tbCategory]
(
	[DisplayOrder] ASC,
	[Category] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Cash_tbCategory_Name] ON [Cash].[tbCategory]
(
	[Category] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Cash_tbCategory_TypeCategory] ON [Cash].[tbCategory]
(
	[CategoryTypeCode] ASC,
	[Category] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Cash_tbCategory_TypeOrderCategory] ON [Cash].[tbCategory]
(
	[CategoryTypeCode] ASC,
	[DisplayOrder] ASC,
	[Category] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Invoice_tb_AccountCode] ON [Invoice].[tbInvoice]
(
	[AccountCode] ASC,
	[InvoicedOn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Invoice_tb_Status] ON [Invoice].[tbInvoice]
(
	[InvoiceStatusCode] ASC,
	[InvoicedOn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Invoice_tb_UserId] ON [Invoice].[tbInvoice]
(
	[UserId] ASC,
	[InvoiceNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Invoice_tbItem_CashCode] ON [Invoice].[tbItem]
(
	[CashCode] ASC,
	[InvoiceNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Invoice_tbTask_CashCode] ON [Invoice].[tbTask]
(
	[CashCode] ASC,
	[InvoiceNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Invoice_tbTask_TaskCode] ON [Invoice].[tbTask]
(
	[TaskCode] ASC,
	[InvoiceNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Org_tbAccount] ON [Org].[tbAccount]
(
	[AccountCode] ASC,
	[CashAccountCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Org_tbAddress] ON [Org].[tbAddress]
(
	[AccountCode] ASC,
	[AddressCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Org_tbContactDepartment] ON [Org].[tbContact]
(
	[Department] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Org_tbContactJobTitle] ON [Org].[tbContact]
(
	[JobTitle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Org_tbContactNameTitle] ON [Org].[tbContact]
(
	[NameTitle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [tbOrgtbOrgContact] ON [Org].[tbContact]
(
	[AccountCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [DocumentName] ON [Org].[tbDoc]
(
	[DocumentName] ASC,
	[AccountCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [tbOrgtbOrgDoc] ON [Org].[tbDoc]
(
	[AccountCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Org_tb_AccountName] ON [Org].[tbOrg]
(
	[AccountName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Org_tb_AccountSource] ON [Org].[tbOrg]
(
	[AccountSource] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Org_tb_AreaCode] ON [Org].[tbOrg]
(
	[AreaCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Org_tb_IndustrySector] ON [Org].[tbOrg]
(
	[IndustrySector] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Org_tb_OrganisationStatusCode] ON [Org].[tbOrg]
(
	[OrganisationStatusCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Org_tb_OrganisationStatusCodeAccountCode] ON [Org].[tbOrg]
(
	[OrganisationStatusCode] ASC,
	[AccountName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Org_tb_OrganisationTypeCode] ON [Org].[tbOrg]
(
	[OrganisationTypeCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Org_tb_PaymentTerms] ON [Org].[tbOrg]
(
	[PaymentTerms] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Org_tbPayment] ON [Org].[tbPayment]
(
	[PaymentReference] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Org_tbPayment_AccountCode] ON [Org].[tbPayment]
(
	[AccountCode] ASC,
	[PaidOn] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Org_tbPayment_CashAccountCode] ON [Org].[tbPayment]
(
	[CashAccountCode] ASC,
	[PaidOn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Org_tbPayment_CashCode] ON [Org].[tbPayment]
(
	[CashCode] ASC,
	[PaidOn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Org_tbPayment_PaymentStatusCode] ON [Org].[tbPayment]
(
	[PaymentStatusCode] ASC,
	[AccountCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX IDX_tbPayment_TaxCode ON [Org].[tbPayment] 
(
	[TaxCode] ASC
) INCLUDE ([PaidInValue],[PaidOutValue])
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Org_tbSector_IndustrySector] ON [Org].[tbSector]
(
	[IndustrySector] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Task_tbAttribute] ON [Task].[tbAttribute]
(
	[TaskCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Task_tbAttribute_Description] ON [Task].[tbAttribute]
(
	[Attribute] ASC,
	[AttributeDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Task_tbAttribute_OrderBy] ON [Task].[tbAttribute]
(
	[TaskCode] ASC,
	[PrintOrder] ASC,
	[Attribute] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Task_tbAttribute_Type_OrderBy] ON [Task].[tbAttribute]
(
	[TaskCode] ASC,
	[AttributeTypeCode] ASC,
	[PrintOrder] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Task_tbFlow_ChildParent] ON [Task].[tbFlow]
(
	[ChildTaskCode] ASC,
	[ParentTaskCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Task_tbFlow_ParentChild] ON [Task].[tbFlow]
(
	[ParentTaskCode] ASC,
	[ChildTaskCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Task_tbOp_OpStatusCode] ON [Task].[tbOp]
(
	[OpStatusCode] ASC,
	[StartOn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Task_tbOp_UserIdOpStatus] ON [Task].[tbOp]
(
	[UserId] ASC,
	[OpStatusCode] ASC,
	[StartOn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [ActivityStatus] ON [Task].[tbStatus]
(
	[TaskStatus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Task_tb_AccountCode] ON [Task].[tbTask]
(
	[AccountCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Task_tb_AccountCodeByActionOn] ON [Task].[tbTask]
(
	[AccountCode] ASC,
	[ActionOn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Task_tb_AccountCodeByStatus] ON [Task].[tbTask]
(
	[AccountCode] ASC,
	[TaskStatusCode] ASC,
	[ActionOn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Task_tb_ActionBy] ON [Task].[tbTask]
(
	[ActionById] ASC,
	[TaskStatusCode] ASC,
	[ActionOn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Task_tb_ActionById] ON [Task].[tbTask]
(
	[ActionById] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Task_tb_ActionOn] ON [Task].[tbTask]
(
	[ActionOn] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Task_tb_ActionOnStatus] ON [Task].[tbTask]
(
	[TaskStatusCode] ASC,
	[ActionOn] ASC,
	[AccountCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Task_tb_ActivityCode] ON [Task].[tbTask]
(
	[ActivityCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Task_tb_ActivityCodeTaskTitle] ON [Task].[tbTask]
(
	[ActivityCode] ASC,
	[TaskTitle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Task_tb_ActivityStatusCode] ON [Task].[tbTask]
(
	[TaskStatusCode] ASC,
	[ActionOn] ASC,
	[AccountCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Task_tb_CashCode] ON [Task].[tbTask]
(
	[CashCode] ASC,
	[TaskStatusCode] ASC,
	[ActionOn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Task_tb_TaskStatusCode] ON [Task].[tbTask]
(
	[TaskStatusCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_Task_tb_UserId] ON [Task].[tbTask]
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [RDX_Usr_tbMenuEntry_Command] ON [Usr].[tbMenuEntry]
(
	[Command] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [RDX_Usr_tbMenuEntry_OpenMode] ON [Usr].[tbMenuEntry]
(
	[OpenMode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Usr_tb_LogonName] ON [Usr].[tbUser]
(
	[LogonName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [UserName] ON [Usr].[tbUser]
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
ALTER TABLE [Activity].[tbActivity]  WITH CHECK ADD  CONSTRAINT [FK_Activity_tbActivity_App_tbRegister] FOREIGN KEY([RegisterName])
REFERENCES [App].[tbRegister] ([RegisterName])
ON UPDATE CASCADE
GO
ALTER TABLE [Activity].[tbActivity] CHECK CONSTRAINT [FK_Activity_tbActivity_App_tbRegister]
GO
ALTER TABLE [Activity].[tbActivity]  WITH CHECK ADD  CONSTRAINT [FK_Activity_tbActivity_App_tbUom] FOREIGN KEY([UnitOfMeasure])
REFERENCES [App].[tbUom] ([UnitOfMeasure])
GO
ALTER TABLE [Activity].[tbActivity] CHECK CONSTRAINT [FK_Activity_tbActivity_App_tbUom]
GO
ALTER TABLE [Activity].[tbActivity]  WITH CHECK ADD  CONSTRAINT [FK_Activity_tbActivity_Cash_tbCode] FOREIGN KEY([CashCode])
REFERENCES [Cash].[tbCode] ([CashCode])
ON UPDATE CASCADE
GO
ALTER TABLE [Activity].[tbActivity] CHECK CONSTRAINT [FK_Activity_tbActivity_Cash_tbCode]
GO
ALTER TABLE [Activity].[tbAttribute]  WITH CHECK ADD  CONSTRAINT [FK_Activity_tbAttribute_Activity_tbAttributeType] FOREIGN KEY([AttributeTypeCode])
REFERENCES [Activity].[tbAttributeType] ([AttributeTypeCode])
GO
ALTER TABLE [Activity].[tbAttribute] CHECK CONSTRAINT [FK_Activity_tbAttribute_Activity_tbAttributeType]
GO
ALTER TABLE [Activity].[tbAttribute]  WITH CHECK ADD  CONSTRAINT [FK_Activity_tbAttribute_tbActivity] FOREIGN KEY([ActivityCode])
REFERENCES [Activity].[tbActivity] ([ActivityCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Activity].[tbAttribute] CHECK CONSTRAINT [FK_Activity_tbAttribute_tbActivity]
GO
ALTER TABLE [Activity].[tbFlow]  WITH CHECK ADD  CONSTRAINT [FK_Activity_tbFlow_Activity_tbChild] FOREIGN KEY([ChildCode])
REFERENCES [Activity].[tbActivity] ([ActivityCode])
GO
ALTER TABLE [Activity].[tbFlow] CHECK CONSTRAINT [FK_Activity_tbFlow_Activity_tbChild]
GO
ALTER TABLE [Activity].[tbFlow]  WITH CHECK ADD  CONSTRAINT [FK_Activity_tbFlow_tbActivityParent] FOREIGN KEY([ParentCode])
REFERENCES [Activity].[tbActivity] ([ActivityCode])
GO
ALTER TABLE [Activity].[tbFlow] CHECK CONSTRAINT [FK_Activity_tbFlow_tbActivityParent]
GO
ALTER TABLE [Activity].[tbOp]  WITH CHECK ADD  CONSTRAINT [FK_Activity_tbOp_Activity_tbOpType] FOREIGN KEY([OpTypeCode])
REFERENCES [Activity].[tbOpType] ([OpTypeCode])
GO
ALTER TABLE [Activity].[tbOp] CHECK CONSTRAINT [FK_Activity_tbOp_Activity_tbOpType]
GO
ALTER TABLE [Activity].[tbOp]  WITH CHECK ADD  CONSTRAINT [FK_Activity_tbOp_tbActivity] FOREIGN KEY([ActivityCode])
REFERENCES [Activity].[tbActivity] ([ActivityCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Activity].[tbOp] CHECK CONSTRAINT [FK_Activity_tbOp_tbActivity]
GO
ALTER TABLE [App].[tbCalendarHoliday]  WITH CHECK ADD  CONSTRAINT [App_tbCalendarHoliday_FK00] FOREIGN KEY([CalendarCode])
REFERENCES [App].[tbCalendar] ([CalendarCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [App].[tbCalendarHoliday] CHECK CONSTRAINT [App_tbCalendarHoliday_FK00]
GO
ALTER TABLE [App].[tbDoc]  WITH CHECK ADD  CONSTRAINT [FK_App_tbDoc_Usr_tbMenuOpenMode] FOREIGN KEY([OpenMode])
REFERENCES [Usr].[tbMenuOpenMode] ([OpenMode])
GO
ALTER TABLE [App].[tbDoc] CHECK CONSTRAINT [FK_App_tbDoc_Usr_tbMenuOpenMode]
GO
ALTER TABLE [App].[tbDocSpool]  WITH CHECK ADD  CONSTRAINT [FK_App_tbDocSpool_App_tbDocType] FOREIGN KEY([DocTypeCode])
REFERENCES [App].[tbDocType] ([DocTypeCode])
GO
ALTER TABLE [App].[tbDocSpool] CHECK CONSTRAINT [FK_App_tbDocSpool_App_tbDocType]
GO
ALTER TABLE [App].[tbOptions]  WITH CHECK ADD  CONSTRAINT [FK_App_tbOption_Cash_tbCategory] FOREIGN KEY([NetProfitCode])
REFERENCES [Cash].[tbCategory] ([CategoryCode])
GO
ALTER TABLE [App].[tbOptions] CHECK CONSTRAINT [FK_App_tbOption_Cash_tbCategory]
GO
ALTER TABLE [App].[tbOptions]  WITH CHECK ADD  CONSTRAINT [FK_App_tbOptions_App_tbBucketInterval] FOREIGN KEY([BucketIntervalCode])
REFERENCES [App].[tbBucketInterval] ([BucketIntervalCode])
GO
ALTER TABLE [App].[tbOptions] CHECK CONSTRAINT [FK_App_tbOptions_App_tbBucketInterval]
GO
ALTER TABLE [App].[tbOptions]  WITH CHECK ADD  CONSTRAINT [FK_App_tbOptions_App_tbBucketType] FOREIGN KEY([BucketTypeCode])
REFERENCES [App].[tbBucketType] ([BucketTypeCode])
GO
ALTER TABLE [App].[tbOptions] CHECK CONSTRAINT [FK_App_tbOptions_App_tbBucketType]
GO
ALTER TABLE [App].[tbOptions]  WITH CHECK ADD  CONSTRAINT [FK_App_tbRoot_Org_tb] FOREIGN KEY([AccountCode])
REFERENCES [Org].[tbOrg] ([AccountCode])
ON UPDATE CASCADE
GO
ALTER TABLE [App].[tbOptions] CHECK CONSTRAINT [FK_App_tbRoot_Org_tb]
GO
ALTER TABLE [App].[tbTaxCode]  WITH NOCHECK ADD  CONSTRAINT [FK_App_tbTaxCode_Cash_tbTaxType] FOREIGN KEY([TaxTypeCode])
REFERENCES [Cash].[tbTaxType] ([TaxTypeCode])
GO
ALTER TABLE [App].[tbTaxCode] CHECK CONSTRAINT [FK_App_tbTaxCode_Cash_tbTaxType]
GO
ALTER TABLE [App].[tbYear]  WITH CHECK ADD  CONSTRAINT [FK_App_tbYear_App_tbMonth] FOREIGN KEY([StartMonth])
REFERENCES [App].[tbMonth] ([MonthNumber])
GO
ALTER TABLE [App].[tbYear] CHECK CONSTRAINT [FK_App_tbYear_App_tbMonth]
GO
ALTER TABLE [App].[tbYearPeriod]  WITH CHECK ADD  CONSTRAINT [FK_App_tbYearPeriod_App_tbMonth] FOREIGN KEY([MonthNumber])
REFERENCES [App].[tbMonth] ([MonthNumber])
GO
ALTER TABLE [App].[tbYearPeriod] CHECK CONSTRAINT [FK_App_tbYearPeriod_App_tbMonth]
GO
ALTER TABLE [App].[tbYearPeriod]  WITH CHECK ADD  CONSTRAINT [FK_App_tbYearPeriod_App_tbYear] FOREIGN KEY([YearNumber])
REFERENCES [App].[tbYear] ([YearNumber])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [App].[tbYearPeriod] CHECK CONSTRAINT [FK_App_tbYearPeriod_App_tbYear]
GO
ALTER TABLE [App].[tbYearPeriod]  WITH CHECK ADD  CONSTRAINT [FK_App_tbYearPeriod_Cash_tbStatus] FOREIGN KEY([CashStatusCode])
REFERENCES [Cash].[tbStatus] ([CashStatusCode])
GO
ALTER TABLE [App].[tbYearPeriod] CHECK CONSTRAINT [FK_App_tbYearPeriod_Cash_tbStatus]
GO
ALTER TABLE [Cash].[tbCategory]  WITH CHECK ADD  CONSTRAINT [FK_Cash_tbCategory_Cash_tbCategoryType] FOREIGN KEY([CategoryTypeCode])
REFERENCES [Cash].[tbCategoryType] ([CategoryTypeCode])
GO
ALTER TABLE [Cash].[tbCategory] CHECK CONSTRAINT [FK_Cash_tbCategory_Cash_tbCategoryType]
GO
ALTER TABLE [Cash].[tbCategory]  WITH CHECK ADD  CONSTRAINT [FK_Cash_tbCategory_Cash_tbMode] FOREIGN KEY([CashModeCode])
REFERENCES [Cash].[tbMode] ([CashModeCode])
GO
ALTER TABLE [Cash].[tbCategory] CHECK CONSTRAINT [FK_Cash_tbCategory_Cash_tbMode]
GO
ALTER TABLE [Cash].[tbCategory]  WITH CHECK ADD  CONSTRAINT [FK_Cash_tbCategory_Cash_tbType] FOREIGN KEY([CashTypeCode])
REFERENCES [Cash].[tbType] ([CashTypeCode])
GO
ALTER TABLE [Cash].[tbCategory] CHECK CONSTRAINT [FK_Cash_tbCategory_Cash_tbType]
GO
ALTER TABLE [Cash].[tbCategoryExp]  WITH CHECK ADD  CONSTRAINT [FK_Cash_tbCategoryExp_Cash_tbCategory] FOREIGN KEY([CategoryCode])
REFERENCES [Cash].[tbCategory] ([CategoryCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Cash].[tbCategoryExp] CHECK CONSTRAINT [FK_Cash_tbCategoryExp_Cash_tbCategory]
GO
ALTER TABLE [Cash].[tbCategoryTotal]  WITH CHECK ADD  CONSTRAINT [FK_Cash_tbCategoryTotal_Cash_tbCategory_Child] FOREIGN KEY([ChildCode])
REFERENCES [Cash].[tbCategory] ([CategoryCode])
GO
ALTER TABLE [Cash].[tbCategoryTotal] CHECK CONSTRAINT [FK_Cash_tbCategoryTotal_Cash_tbCategory_Child]
GO
ALTER TABLE [Cash].[tbCategoryTotal]  WITH CHECK ADD  CONSTRAINT [FK_Cash_tbCategoryTotal_Cash_tbCategory_Parent] FOREIGN KEY([ParentCode])
REFERENCES [Cash].[tbCategory] ([CategoryCode])
GO
ALTER TABLE [Cash].[tbCategoryTotal] CHECK CONSTRAINT [FK_Cash_tbCategoryTotal_Cash_tbCategory_Parent]
GO
ALTER TABLE [Cash].[tbCode]  WITH NOCHECK ADD  CONSTRAINT [FK_Cash_tbCode_App_tbTaxCode] FOREIGN KEY([TaxCode])
REFERENCES [App].[tbTaxCode] ([TaxCode])
GO
ALTER TABLE [Cash].[tbCode] CHECK CONSTRAINT [FK_Cash_tbCode_App_tbTaxCode]
GO
ALTER TABLE [Cash].[tbCode]  WITH CHECK ADD  CONSTRAINT [FK_Cash_tbCode_Cash_tbCategory1] FOREIGN KEY([CategoryCode])
REFERENCES [Cash].[tbCategory] ([CategoryCode])
ON UPDATE CASCADE
GO
ALTER TABLE [Cash].[tbCode] CHECK CONSTRAINT [FK_Cash_tbCode_Cash_tbCategory1]
GO
ALTER TABLE [Cash].[tbPeriod]  WITH CHECK ADD  CONSTRAINT [FK_Cash_tbPeriod_App_tbYearPeriod] FOREIGN KEY([StartOn])
REFERENCES [App].[tbYearPeriod] ([StartOn])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Cash].[tbPeriod] CHECK CONSTRAINT [FK_Cash_tbPeriod_App_tbYearPeriod]
GO
ALTER TABLE [Cash].[tbPeriod]  WITH CHECK ADD  CONSTRAINT [FK_Cash_tbPeriod_Cash_tbCode] FOREIGN KEY([CashCode])
REFERENCES [Cash].[tbCode] ([CashCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Cash].[tbPeriod] CHECK CONSTRAINT [FK_Cash_tbPeriod_Cash_tbCode]
GO
ALTER TABLE [Cash].[tbTaxType]  WITH CHECK ADD  CONSTRAINT [FK_Cash_tbTaxType_App_tbMonth] FOREIGN KEY([MonthNumber])
REFERENCES [App].[tbMonth] ([MonthNumber])
GO
ALTER TABLE [Cash].[tbTaxType] CHECK CONSTRAINT [FK_Cash_tbTaxType_App_tbMonth]
GO
ALTER TABLE [Cash].[tbTaxType]  WITH CHECK ADD  CONSTRAINT [FK_Cash_tbTaxType_App_tbRecurrence] FOREIGN KEY([RecurrenceCode])
REFERENCES [App].[tbRecurrence] ([RecurrenceCode])
GO
ALTER TABLE [Cash].[tbTaxType] CHECK CONSTRAINT [FK_Cash_tbTaxType_App_tbRecurrence]
GO
ALTER TABLE [Cash].[tbTaxType]  WITH CHECK ADD  CONSTRAINT [FK_Cash_tbTaxType_Cash_tbCode] FOREIGN KEY([CashCode])
REFERENCES [Cash].[tbCode] ([CashCode])
GO
ALTER TABLE [Cash].[tbTaxType] CHECK CONSTRAINT [FK_Cash_tbTaxType_Cash_tbCode]
GO
ALTER TABLE [Cash].[tbTaxType]  WITH CHECK ADD  CONSTRAINT [FK_Cash_tbTaxType_Org_tb] FOREIGN KEY([AccountCode])
REFERENCES [Org].[tbOrg] ([AccountCode])
ON UPDATE CASCADE
GO
ALTER TABLE [Cash].[tbTaxType] CHECK CONSTRAINT [FK_Cash_tbTaxType_Org_tb]
GO
ALTER TABLE [Cash].[tbTaxType]  WITH CHECK ADD  CONSTRAINT [FK_Cash_tbTaxType_Org_tbAccount] FOREIGN KEY([CashAccountCode])
REFERENCES [Org].[tbAccount] ([CashAccountCode])
GO
ALTER TABLE [Cash].[tbTaxType] CHECK CONSTRAINT [FK_Cash_tbTaxType_Org_tbAccount]
GO
ALTER TABLE [Invoice].[tbInvoice]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_tb_Invoice_tbStatus] FOREIGN KEY([InvoiceStatusCode])
REFERENCES [Invoice].[tbStatus] ([InvoiceStatusCode])
GO
ALTER TABLE [Invoice].[tbInvoice] CHECK CONSTRAINT [FK_Invoice_tb_Invoice_tbStatus]
GO
ALTER TABLE [Invoice].[tbInvoice]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_tb_Invoice_tbType] FOREIGN KEY([InvoiceTypeCode])
REFERENCES [Invoice].[tbType] ([InvoiceTypeCode])
GO
ALTER TABLE [Invoice].[tbInvoice] CHECK CONSTRAINT [FK_Invoice_tb_Invoice_tbType]
GO
ALTER TABLE [Invoice].[tbInvoice]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_tb_Org_tb] FOREIGN KEY([AccountCode])
REFERENCES [Org].[tbOrg] ([AccountCode])
GO
ALTER TABLE [Invoice].[tbInvoice] CHECK CONSTRAINT [FK_Invoice_tb_Org_tb]
GO
ALTER TABLE [Invoice].[tbInvoice]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_tb_Usr_tb] FOREIGN KEY([UserId])
REFERENCES [Usr].[tbUser] ([UserId])
ON UPDATE CASCADE
GO
ALTER TABLE [Invoice].[tbInvoice] CHECK CONSTRAINT [FK_Invoice_tb_Usr_tb]
GO
ALTER TABLE [Invoice].[tbItem]  WITH NOCHECK ADD  CONSTRAINT [FK_Invoice_tbItem_App_tbTaxCode] FOREIGN KEY([TaxCode])
REFERENCES [App].[tbTaxCode] ([TaxCode])
GO
ALTER TABLE [Invoice].[tbItem] CHECK CONSTRAINT [FK_Invoice_tbItem_App_tbTaxCode]
GO
ALTER TABLE [Invoice].[tbItem]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_tbItem_Cash_tbCode] FOREIGN KEY([CashCode])
REFERENCES [Cash].[tbCode] ([CashCode])
ON UPDATE CASCADE
GO
ALTER TABLE [Invoice].[tbItem] CHECK CONSTRAINT [FK_Invoice_tbItem_Cash_tbCode]
GO
ALTER TABLE [Invoice].[tbItem]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_tbItem_Invoice_tb] FOREIGN KEY([InvoiceNumber])
REFERENCES [Invoice].[tbInvoice] ([InvoiceNumber])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Invoice].[tbItem] CHECK CONSTRAINT [FK_Invoice_tbItem_Invoice_tb]
GO
ALTER TABLE [Invoice].[tbTask]  WITH NOCHECK ADD  CONSTRAINT [FK_Invoice_tbTask_App_tbTaxCode] FOREIGN KEY([TaxCode])
REFERENCES [App].[tbTaxCode] ([TaxCode])
GO
ALTER TABLE [Invoice].[tbTask] CHECK CONSTRAINT [FK_Invoice_tbTask_App_tbTaxCode]
GO
ALTER TABLE [Invoice].[tbTask]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_tbTask_Cash_tbCode] FOREIGN KEY([CashCode])
REFERENCES [Cash].[tbCode] ([CashCode])
GO
ALTER TABLE [Invoice].[tbTask] CHECK CONSTRAINT [FK_Invoice_tbTask_Cash_tbCode]
GO
ALTER TABLE [Invoice].[tbTask]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_tbTask_Invoice_tb] FOREIGN KEY([InvoiceNumber])
REFERENCES [Invoice].[tbInvoice] ([InvoiceNumber])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Invoice].[tbTask] CHECK CONSTRAINT [FK_Invoice_tbTask_Invoice_tb]
GO
ALTER TABLE [Invoice].[tbTask]  WITH NOCHECK ADD  CONSTRAINT [FK_Invoice_tbTask_Task_tb] FOREIGN KEY([TaskCode])
REFERENCES [Task].[tbTask] ([TaskCode])
GO
ALTER TABLE [Invoice].[tbTask] CHECK CONSTRAINT [FK_Invoice_tbTask_Task_tb]
GO
ALTER TABLE [Invoice].[tbType]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_tbType_Cash_tbMode] FOREIGN KEY([CashModeCode])
REFERENCES [Cash].[tbMode] ([CashModeCode])
GO
ALTER TABLE [Invoice].[tbType] CHECK CONSTRAINT [FK_Invoice_tbType_Cash_tbMode]
GO
ALTER TABLE [Org].[tbAccount]  WITH CHECK ADD  CONSTRAINT [FK_Org_tbAccount_Cash_tbCode] FOREIGN KEY([CashCode])
REFERENCES [Cash].[tbCode] ([CashCode])
GO
ALTER TABLE [Org].[tbAccount] CHECK CONSTRAINT [FK_Org_tbAccount_Cash_tbCode]
GO
ALTER TABLE [Org].[tbAccount]  WITH CHECK ADD  CONSTRAINT [FK_Org_tbAccount_Org_tb] FOREIGN KEY([AccountCode])
REFERENCES [Org].[tbOrg] ([AccountCode])
ON UPDATE CASCADE
GO
ALTER TABLE [Org].[tbAccount] CHECK CONSTRAINT [FK_Org_tbAccount_Org_tb]
GO
ALTER TABLE [Org].[tbAddress]  WITH CHECK ADD  CONSTRAINT [FK_Org_tbAddress_Org_tb] FOREIGN KEY([AccountCode])
REFERENCES [Org].[tbOrg] ([AccountCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Org].[tbAddress] CHECK CONSTRAINT [FK_Org_tbAddress_Org_tb]
GO
ALTER TABLE [Org].[tbContact]  WITH CHECK ADD  CONSTRAINT [tbOrgContact_FK00] FOREIGN KEY([AccountCode])
REFERENCES [Org].[tbOrg] ([AccountCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Org].[tbContact] CHECK CONSTRAINT [tbOrgContact_FK00]
GO
ALTER TABLE [Org].[tbDoc]  WITH CHECK ADD  CONSTRAINT [tbOrgDoc_FK00] FOREIGN KEY([AccountCode])
REFERENCES [Org].[tbOrg] ([AccountCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Org].[tbDoc] CHECK CONSTRAINT [tbOrgDoc_FK00]
GO
ALTER TABLE [Org].[tbOrg]  WITH NOCHECK ADD  CONSTRAINT [FK_Org_tb_App_tbTaxCode] FOREIGN KEY([TaxCode])
REFERENCES [App].[tbTaxCode] ([TaxCode])
ON UPDATE CASCADE
GO
ALTER TABLE [Org].[tbOrg] CHECK CONSTRAINT [FK_Org_tb_App_tbTaxCode]
GO
ALTER TABLE [Org].[tbOrg]  WITH NOCHECK ADD  CONSTRAINT [FK_Org_tb_Org_tbAddress] FOREIGN KEY([AddressCode])
REFERENCES [Org].[tbAddress] ([AddressCode])
NOT FOR REPLICATION 
GO
ALTER TABLE [Org].[tbOrg] NOCHECK CONSTRAINT [FK_Org_tb_Org_tbAddress]
GO
ALTER TABLE [Org].[tbOrg]  WITH CHECK ADD  CONSTRAINT [tbOrg_FK00] FOREIGN KEY([OrganisationStatusCode])
REFERENCES [Org].[tbStatus] ([OrganisationStatusCode])
GO
ALTER TABLE [Org].[tbOrg] CHECK CONSTRAINT [tbOrg_FK00]
GO
ALTER TABLE [Org].[tbOrg]  WITH CHECK ADD  CONSTRAINT [tbOrg_FK01] FOREIGN KEY([OrganisationTypeCode])
REFERENCES [Org].[tbType] ([OrganisationTypeCode])
GO
ALTER TABLE [Org].[tbOrg] CHECK CONSTRAINT [tbOrg_FK01]
GO
ALTER TABLE [Org].[tbPayment]  WITH NOCHECK ADD  CONSTRAINT [FK_Org_tbPayment_App_tbTaxCode] FOREIGN KEY([TaxCode])
REFERENCES [App].[tbTaxCode] ([TaxCode])
GO
ALTER TABLE [Org].[tbPayment] CHECK CONSTRAINT [FK_Org_tbPayment_App_tbTaxCode]
GO
ALTER TABLE [Org].[tbPayment]  WITH CHECK ADD  CONSTRAINT [FK_Org_tbPayment_Cash_tbCode] FOREIGN KEY([CashCode])
REFERENCES [Cash].[tbCode] ([CashCode])
ON UPDATE CASCADE
GO
ALTER TABLE [Org].[tbPayment] CHECK CONSTRAINT [FK_Org_tbPayment_Cash_tbCode]
GO
ALTER TABLE [Org].[tbPayment]  WITH CHECK ADD  CONSTRAINT [FK_Org_tbPayment_Org_tb] FOREIGN KEY([AccountCode])
REFERENCES [Org].[tbOrg] ([AccountCode])
GO
ALTER TABLE [Org].[tbPayment] CHECK CONSTRAINT [FK_Org_tbPayment_Org_tb]
GO
ALTER TABLE [Org].[tbPayment]  WITH CHECK ADD  CONSTRAINT [FK_Org_tbPayment_Org_tbAccount] FOREIGN KEY([CashAccountCode])
REFERENCES [Org].[tbAccount] ([CashAccountCode])
ON UPDATE CASCADE
GO
ALTER TABLE [Org].[tbPayment] CHECK CONSTRAINT [FK_Org_tbPayment_Org_tbAccount]
GO
ALTER TABLE [Org].[tbPayment]  WITH CHECK ADD  CONSTRAINT [FK_Org_tbPayment_Org_tbPaymentStatus] FOREIGN KEY([PaymentStatusCode])
REFERENCES [Org].[tbPaymentStatus] ([PaymentStatusCode])
GO
ALTER TABLE [Org].[tbPayment] CHECK CONSTRAINT [FK_Org_tbPayment_Org_tbPaymentStatus]
GO
ALTER TABLE [Org].[tbPayment]  WITH CHECK ADD  CONSTRAINT [FK_Org_tbPayment_Usr_tb] FOREIGN KEY([UserId])
REFERENCES [Usr].[tbUser] ([UserId])
ON UPDATE CASCADE
GO
ALTER TABLE [Org].[tbPayment] CHECK CONSTRAINT [FK_Org_tbPayment_Usr_tb]
GO
ALTER TABLE [Org].[tbSector]  WITH CHECK ADD  CONSTRAINT [FK_Org_tbSector_Org_tb] FOREIGN KEY([AccountCode])
REFERENCES [Org].[tbOrg] ([AccountCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Org].[tbSector] CHECK CONSTRAINT [FK_Org_tbSector_Org_tb]
GO
ALTER TABLE [Org].[tbType]  WITH CHECK ADD  CONSTRAINT [FK_Org_tbType_Cash_tbMode] FOREIGN KEY([CashModeCode])
REFERENCES [Cash].[tbMode] ([CashModeCode])
GO
ALTER TABLE [Org].[tbType] CHECK CONSTRAINT [FK_Org_tbType_Cash_tbMode]
GO
ALTER TABLE [Task].[tbAttribute]  WITH NOCHECK ADD  CONSTRAINT [FK_Task_tbAttrib_Task_tb] FOREIGN KEY([TaskCode])
REFERENCES [Task].[tbTask] ([TaskCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Task].[tbAttribute] CHECK CONSTRAINT [FK_Task_tbAttrib_Task_tb]
GO
ALTER TABLE [Task].[tbAttribute]  WITH CHECK ADD  CONSTRAINT [FK_Task_tbAttribute_Activity_tbAttributeType] FOREIGN KEY([AttributeTypeCode])
REFERENCES [Activity].[tbAttributeType] ([AttributeTypeCode])
GO
ALTER TABLE [Task].[tbAttribute] CHECK CONSTRAINT [FK_Task_tbAttribute_Activity_tbAttributeType]
GO
ALTER TABLE [Task].[tbDoc]  WITH NOCHECK ADD  CONSTRAINT [FK_Task_tbDoc_Task_tb] FOREIGN KEY([TaskCode])
REFERENCES [Task].[tbTask] ([TaskCode])
GO
ALTER TABLE [Task].[tbDoc] CHECK CONSTRAINT [FK_Task_tbDoc_Task_tb]
GO
ALTER TABLE [Task].[tbFlow]  WITH NOCHECK ADD  CONSTRAINT [FK_Task_tbFlow_Task_tb_Child] FOREIGN KEY([ChildTaskCode])
REFERENCES [Task].[tbTask] ([TaskCode])
GO
ALTER TABLE [Task].[tbFlow] CHECK CONSTRAINT [FK_Task_tbFlow_Task_tb_Child]
GO
ALTER TABLE [Task].[tbFlow]  WITH NOCHECK ADD  CONSTRAINT [FK_Task_tbFlow_Task_tb_Parent] FOREIGN KEY([ParentTaskCode])
REFERENCES [Task].[tbTask] ([TaskCode])
GO
ALTER TABLE [Task].[tbFlow] CHECK CONSTRAINT [FK_Task_tbFlow_Task_tb_Parent]
GO
ALTER TABLE [Task].[tbOp]  WITH CHECK ADD  CONSTRAINT [FK_Task_tbOp_Activity_tbOpType] FOREIGN KEY([OpTypeCode])
REFERENCES [Activity].[tbOpType] ([OpTypeCode])
GO
ALTER TABLE [Task].[tbOp] CHECK CONSTRAINT [FK_Task_tbOp_Activity_tbOpType]
GO
ALTER TABLE [Task].[tbOp]  WITH NOCHECK ADD  CONSTRAINT [FK_Task_tbOp_Task_tb] FOREIGN KEY([TaskCode])
REFERENCES [Task].[tbTask] ([TaskCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Task].[tbOp] CHECK CONSTRAINT [FK_Task_tbOp_Task_tb]
GO
ALTER TABLE [Task].[tbOp]  WITH CHECK ADD  CONSTRAINT [FK_Task_tbOp_Task_tbOpStatus] FOREIGN KEY([OpStatusCode])
REFERENCES [Task].[tbOpStatus] ([OpStatusCode])
GO
ALTER TABLE [Task].[tbOp] CHECK CONSTRAINT [FK_Task_tbOp_Task_tbOpStatus]
GO
ALTER TABLE [Task].[tbOp]  WITH CHECK ADD  CONSTRAINT [FK_Task_tbOp_Usr_tb] FOREIGN KEY([UserId])
REFERENCES [Usr].[tbUser] ([UserId])
GO
ALTER TABLE [Task].[tbOp] CHECK CONSTRAINT [FK_Task_tbOp_Usr_tb]
GO
ALTER TABLE [Task].[tbQuote]  WITH NOCHECK ADD  CONSTRAINT [FK_Task_tbQuote_Task_tb] FOREIGN KEY([TaskCode])
REFERENCES [Task].[tbTask] ([TaskCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Task].[tbQuote] CHECK CONSTRAINT [FK_Task_tbQuote_Task_tb]
GO
ALTER TABLE [Task].[tbTask]  WITH NOCHECK ADD  CONSTRAINT [Activity_tb_FK00] FOREIGN KEY([ActivityCode])
REFERENCES [Activity].[tbActivity] ([ActivityCode])
ON UPDATE CASCADE
GO
ALTER TABLE [Task].[tbTask] CHECK CONSTRAINT [Activity_tb_FK00]
GO
ALTER TABLE [Task].[tbTask]  WITH NOCHECK ADD  CONSTRAINT [Activity_tb_FK01] FOREIGN KEY([TaskStatusCode])
REFERENCES [Task].[tbStatus] ([TaskStatusCode])
GO
ALTER TABLE [Task].[tbTask] CHECK CONSTRAINT [Activity_tb_FK01]
GO
ALTER TABLE [Task].[tbTask]  WITH NOCHECK ADD  CONSTRAINT [Activity_tb_FK02] FOREIGN KEY([AccountCode])
REFERENCES [Org].[tbOrg] ([AccountCode])
ON UPDATE CASCADE
GO
ALTER TABLE [Task].[tbTask] CHECK CONSTRAINT [Activity_tb_FK02]
GO
ALTER TABLE [Task].[tbTask]  WITH NOCHECK ADD  CONSTRAINT [FK_Task_tb_App_tbTaxCode] FOREIGN KEY([TaxCode])
REFERENCES [App].[tbTaxCode] ([TaxCode])
GO
ALTER TABLE [Task].[tbTask] CHECK CONSTRAINT [FK_Task_tb_App_tbTaxCode]
GO
ALTER TABLE [Task].[tbTask]  WITH NOCHECK ADD  CONSTRAINT [FK_Task_tb_Cash_tbCode] FOREIGN KEY([CashCode])
REFERENCES [Cash].[tbCode] ([CashCode])
GO
ALTER TABLE [Task].[tbTask] CHECK CONSTRAINT [FK_Task_tb_Cash_tbCode]
GO
ALTER TABLE [Task].[tbTask]  WITH NOCHECK ADD  CONSTRAINT [FK_Task_tb_Org_tbAddress_From] FOREIGN KEY([AddressCodeFrom])
REFERENCES [Org].[tbAddress] ([AddressCode])
GO
ALTER TABLE [Task].[tbTask] CHECK CONSTRAINT [FK_Task_tb_Org_tbAddress_From]
GO
ALTER TABLE [Task].[tbTask]  WITH NOCHECK ADD  CONSTRAINT [FK_Task_tb_Org_tbAddress_To] FOREIGN KEY([AddressCodeTo])
REFERENCES [Org].[tbAddress] ([AddressCode])
GO
ALTER TABLE [Task].[tbTask] CHECK CONSTRAINT [FK_Task_tb_Org_tbAddress_To]
GO
ALTER TABLE [Task].[tbTask]  WITH NOCHECK ADD  CONSTRAINT [FK_Task_tb_Usr_tb] FOREIGN KEY([UserId])
REFERENCES [Usr].[tbUser] ([UserId])
ON UPDATE CASCADE
GO
ALTER TABLE [Task].[tbTask] CHECK CONSTRAINT [FK_Task_tb_Usr_tb]
GO
ALTER TABLE [Task].[tbTask]  WITH NOCHECK ADD  CONSTRAINT [FK_Task_tb_Usr_tb_ActionById] FOREIGN KEY([ActionById])
REFERENCES [Usr].[tbUser] ([UserId])
GO
ALTER TABLE [Task].[tbTask] CHECK CONSTRAINT [FK_Task_tb_Usr_tb_ActionById]
GO
ALTER TABLE [Usr].[tbMenuEntry]  WITH CHECK ADD  CONSTRAINT [FK_Usr_tbMenuEntry_Usr_tbMenu] FOREIGN KEY([MenuId])
REFERENCES [Usr].[tbMenu] ([MenuId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Usr].[tbMenuEntry] CHECK CONSTRAINT [FK_Usr_tbMenuEntry_Usr_tbMenu]
GO
ALTER TABLE [Usr].[tbMenuEntry]  WITH CHECK ADD  CONSTRAINT [Usr_tbMenuEntry_FK01] FOREIGN KEY([Command])
REFERENCES [Usr].[tbMenuCommand] ([Command])
GO
ALTER TABLE [Usr].[tbMenuEntry] CHECK CONSTRAINT [Usr_tbMenuEntry_FK01]
GO
ALTER TABLE [Usr].[tbMenuEntry]  WITH CHECK ADD  CONSTRAINT [Usr_tbMenuEntry_FK02] FOREIGN KEY([OpenMode])
REFERENCES [Usr].[tbMenuOpenMode] ([OpenMode])
GO
ALTER TABLE [Usr].[tbMenuEntry] CHECK CONSTRAINT [Usr_tbMenuEntry_FK02]
GO
ALTER TABLE [Usr].[tbMenuUser]  WITH CHECK ADD  CONSTRAINT [FK_Usr_tbMenu_Usr_tb] FOREIGN KEY([UserId])
REFERENCES [Usr].[tbUser] ([UserId])
ON UPDATE CASCADE
GO
ALTER TABLE [Usr].[tbMenuUser] CHECK CONSTRAINT [FK_Usr_tbMenu_Usr_tb]
GO
ALTER TABLE [Usr].[tbMenuUser]  WITH CHECK ADD  CONSTRAINT [FK_Usr_tbMenu_Usr_tbMenu] FOREIGN KEY([MenuId])
REFERENCES [Usr].[tbMenu] ([MenuId])
GO
ALTER TABLE [Usr].[tbMenuUser] CHECK CONSTRAINT [FK_Usr_tbMenu_Usr_tbMenu]
GO
ALTER TABLE [Usr].[tbUser]  WITH CHECK ADD  CONSTRAINT [FK_Usr_tb_App_tbCalendar] FOREIGN KEY([CalendarCode])
REFERENCES [App].[tbCalendar] ([CalendarCode])
ON UPDATE CASCADE
GO
ALTER TABLE [Usr].[tbUser] CHECK CONSTRAINT [FK_Usr_tb_App_tbCalendar]
GO
