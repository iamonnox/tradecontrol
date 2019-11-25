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


print 'Cleardown misImportDb'
SET NOCOUNT ON;
DELETE FROM misImportDb.dbo.tbCashCategoryExp
DELETE FROM misImportDb.dbo.tbCashCategoryTotal
DELETE FROM misImportDb.dbo.tbCashCategory
DELETE FROM misImportDb.dbo.tbCashCode
DELETE FROM misImportDb.dbo.tbSystemRegister
DELETE FROM misImportDb.dbo.tbSystemUom
DELETE FROM misImportDb.dbo.tbActivity

DELETE FROM misImportDb.dbo.tbActivityAttribute
DELETE FROM misImportDb.dbo.tbActivityFlow
DELETE FROM misImportDb.dbo.tbActivityOpType
DELETE FROM misImportDb.dbo.tbActivityOp

DELETE FROM misImportDb.dbo.tbSystemYear
DELETE FROM misImportDb.dbo.tbSystemYearPeriod
DELETE FROM misImportDb.dbo.tbSystemMonth
DELETE FROM misImportDb.dbo.tbCashPeriod
DELETE FROM misImportDb.dbo.tbOrgStatus
DELETE FROM misImportDb.dbo.tbOrgType
DELETE FROM misImportDb.dbo.tbSystemTaxCode
DELETE FROM misImportDb.dbo.tbOrg
DELETE FROM misImportDb.dbo.tbOrgAccount
DELETE FROM misImportDb.dbo.tbSystemRecurrence
DELETE FROM misImportDb.dbo.tbCashTaxType
DELETE FROM misImportDb.dbo.tbInvoiceStatus
DELETE FROM misImportDb.dbo.tbInvoiceType
DELETE FROM misImportDb.dbo.tbUserMenu
DELETE FROM misImportDb.dbo.tbUser
DELETE FROM misImportDb.dbo.tbInvoice
DELETE FROM misImportDb.dbo.tbInvoiceItem
DELETE FROM misImportDb.dbo.tbOrgAddress
DELETE FROM misImportDb.dbo.tbTaskStatus
DELETE FROM misImportDb.dbo.tbTask
DELETE FROM misImportDb.dbo.tbInvoiceTask
DELETE FROM misImportDb.dbo.tbOrgContact
DELETE FROM misImportDb.dbo.tbOrgDoc
DELETE FROM misImportDb.dbo.tbOrgPaymentStatus
DELETE FROM misImportDb.dbo.tbOrgPayment
DELETE FROM misImportDb.dbo.tbOrgSector
DELETE FROM misImportDb.dbo.tbProfileMenu
DELETE FROM misImportDb.dbo.tbProfileMenuCommand
DELETE FROM misImportDb.dbo.tbProfileMenuEntry
DELETE FROM misImportDb.dbo.tbProfileText
DELETE FROM misImportDb.dbo.tbSystemOptions
DELETE FROM misImportDb.dbo.tbTaskAttribute
DELETE FROM misImportDb.dbo.tbTaskDoc
DELETE FROM misImportDb.dbo.tbTaskFlow
DELETE FROM misImportDb.dbo.tbTaskOpStatus
DELETE FROM misImportDb.dbo.tbTaskOp
DELETE FROM misImportDb.dbo.tbTaskQuote
DELETE FROM misImportDb.dbo.tbCashCategoryType
DELETE FROM misImportDb.dbo.tbCashMode
DELETE FROM misImportDb.dbo.tbCashType
DELETE FROM misImportDb.dbo.tbCashEntryType
DELETE FROM misImportDb.dbo.tbCashStatus
DELETE FROM misImportDb.dbo.tbActivityAttributeType
DELETE FROM misImportDb.dbo.tbSystemCalendar
DELETE FROM misImportDb.dbo.tbSystemBucket
DELETE FROM misImportDb.dbo.tbSystemBucketInterval
DELETE FROM misImportDb.dbo.tbSystemBucketType
DELETE FROM misImportDb.dbo.tbSystemCalendarHoliday
DELETE FROM misImportDb.dbo.tbSystemCodeExclusion
DELETE FROM misImportDb.dbo.tbSystemDoc
DELETE FROM misImportDb.dbo.tbSystemDocType
DELETE FROM misImportDb.dbo.tbSystemDocSpool
DELETE FROM misImportDb.dbo.tbProfileMenuOpenMode
GO

print 'TradeControlMIS to misImportDb'
print 'tbCashCategoryType'
insert into misImportDb.dbo.tbCashCategoryType (CategoryTypeCode, CategoryType)
select sourceTb.CategoryTypeCode, sourceTb.CategoryType
from TradeControlMIS.dbo.tbCashCategoryType sourceTb
left outer join  misImportDb.dbo.tbCashCategoryType targetTb
ON targetTb.CategoryTypeCode = sourceTb.CategoryTypeCode
WHERE (targetTb.CategoryTypeCode IS NULL)
GO

print 'tbCashMode'
insert into misImportDb.dbo.tbCashMode (CashModeCode, CashMode)
select sourceTb.CashModeCode, sourceTb.CashMode
from TradeControlMIS.dbo.tbCashMode sourceTb
left outer join  misImportDb.dbo.tbCashMode targetTb
ON targetTb.CashModeCode = sourceTb.CashModeCode
WHERE (targetTb.CashModeCode IS NULL)
GO

print 'tbCashType'
insert into misImportDb.dbo.tbCashType (CashTypeCode, CashType)
select sourceTb.CashTypeCode, sourceTb.CashType
from TradeControlMIS.dbo.tbCashType sourceTb
left outer join  misImportDb.dbo.tbCashType targetTb
ON targetTb.CashTypeCode = sourceTb.CashTypeCode
WHERE (targetTb.CashTypeCode IS NULL)
GO

print 'tbCashCategory'
insert into misImportDb.dbo.tbCashCategory (CategoryCode, Category, CategoryTypeCode, CashModeCode, CashTypeCode, DisplayOrder, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.CategoryCode, sourceTb.Category, sourceTb.CategoryTypeCode, sourceTb.CashModeCode, sourceTb.CashTypeCode, sourceTb.DisplayOrder, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from TradeControlMIS.dbo.tbCashCategory sourceTb
left outer join  misImportDb.dbo.tbCashCategory targetTb
ON targetTb.CategoryCode = sourceTb.CategoryCode
WHERE (targetTb.CategoryCode IS NULL)
GO


print 'tbSystemRegister'
insert into misImportDb.dbo.tbSystemRegister (RegisterName, NextNumber)
select sourceTb.RegisterName, sourceTb.NextNumber
from TradeControlMIS.dbo.tbSystemRegister sourceTb
left outer join  misImportDb.dbo.tbSystemRegister targetTb
ON targetTb.RegisterName = sourceTb.RegisterName
WHERE (targetTb.RegisterName IS NULL)
GO

print 'tbSystemUom'
insert into misImportDb.dbo.tbSystemUom (UnitOfMeasure)
select sourceTb.UnitOfMeasure
from TradeControlMIS.dbo.tbSystemUom sourceTb
left outer join  misImportDb.dbo.tbSystemUom targetTb
ON targetTb.UnitOfMeasure = sourceTb.UnitOfMeasure
WHERE (targetTb.UnitOfMeasure IS NULL)
GO

print 'tbCashEntryType'
insert into misImportDb.dbo.tbCashEntryType (CashEntryTypeCode, CashEntryType)
select sourceTb.CashEntryTypeCode, sourceTb.CashEntryType
from TradeControlMIS.dbo.tbCashEntryType sourceTb
left outer join  misImportDb.dbo.tbCashEntryType targetTb
ON targetTb.CashEntryTypeCode = sourceTb.CashEntryTypeCode
WHERE (targetTb.CashEntryTypeCode IS NULL)
GO

print 'tbCashStatus'
insert into misImportDb.dbo.tbCashStatus (CashStatusCode, CashStatus)
select sourceTb.CashStatusCode, sourceTb.CashStatus
from TradeControlMIS.dbo.tbCashStatus sourceTb
left outer join  misImportDb.dbo.tbCashStatus targetTb
ON targetTb.CashStatusCode = sourceTb.CashStatusCode
WHERE (targetTb.CashStatusCode IS NULL)
GO


print 'tbSystemTaxCode'
insert into misImportDb.dbo.tbSystemTaxCode (TaxCode, TaxRate, TaxDescription, TaxTypeCode, UpdatedBy, UpdatedOn)
select sourceTb.TaxCode, sourceTb.TaxRate, sourceTb.TaxDescription, sourceTb.TaxTypeCode, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from TradeControlMIS.dbo.tbSystemTaxCode sourceTb
left outer join  misImportDb.dbo.tbSystemTaxCode targetTb
ON targetTb.TaxCode = sourceTb.TaxCode
WHERE (targetTb.TaxCode IS NULL)
GO

print 'tbCashTaxType'
insert into misImportDb.dbo.tbCashTaxType (TaxTypeCode, TaxType, CashCode, MonthNumber, RecurrenceCode, AccountCode, CashAccountCode)
select sourceTb.TaxTypeCode, sourceTb.TaxType, sourceTb.CashCode, sourceTb.MonthNumber, sourceTb.RecurrenceCode, sourceTb.AccountCode, sourceTb.CashAccountCode
from TradeControlMIS.dbo.tbCashTaxType sourceTb
left outer join  misImportDb.dbo.tbCashTaxType targetTb
ON targetTb.TaxTypeCode = sourceTb.TaxTypeCode
WHERE (targetTb.TaxTypeCode IS NULL)
GO

print 'tbCashCode'
insert into misImportDb.dbo.tbCashCode (CashCode, CashDescription, CategoryCode, TaxCode, OpeningBalance, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.CashCode, sourceTb.CashDescription, sourceTb.CategoryCode, sourceTb.TaxCode, sourceTb.OpeningBalance, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from TradeControlMIS.dbo.tbCashCode sourceTb
left outer join  misImportDb.dbo.tbCashCode targetTb
ON targetTb.CashCode = sourceTb.CashCode
WHERE (targetTb.CashCode IS NULL)
GO



print 'tbActivity'
insert into misImportDb.dbo.tbActivity (ActivityCode, TaskStatusCode, DefaultText, UnitOfMeasure, CashCode, UnitCharge, PrintOrder, RegisterName, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.ActivityCode, sourceTb.TaskStatusCode, sourceTb.DefaultText, sourceTb.UnitOfMeasure, sourceTb.CashCode, sourceTb.UnitCharge, sourceTb.PrintOrder, sourceTb.RegisterName, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from TradeControlMIS.dbo.tbActivity sourceTb
left outer join  misImportDb.dbo.tbActivity targetTb
ON targetTb.ActivityCode = sourceTb.ActivityCode
WHERE (targetTb.ActivityCode IS NULL)
GO

print 'tbActivityAttributeType'
insert into misImportDb.dbo.tbActivityAttributeType (AttributeTypeCode, AttributeType)
select sourceTb.AttributeTypeCode, sourceTb.AttributeType
from TradeControlMIS.dbo.tbActivityAttributeType sourceTb
left outer join  misImportDb.dbo.tbActivityAttributeType targetTb
ON targetTb.AttributeTypeCode = sourceTb.AttributeTypeCode
WHERE (targetTb.AttributeTypeCode IS NULL)
GO

print 'tbActivityAttribute'
insert into misImportDb.dbo.tbActivityAttribute (ActivityCode, Attribute, PrintOrder, AttributeTypeCode, DefaultText, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.ActivityCode, sourceTb.Attribute, sourceTb.PrintOrder, sourceTb.AttributeTypeCode, sourceTb.DefaultText, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from TradeControlMIS.dbo.tbActivityAttribute sourceTb
left outer join  misImportDb.dbo.tbActivityAttribute targetTb
ON targetTb.ActivityCode = sourceTb.ActivityCode AND targetTb.Attribute = sourceTb.Attribute
WHERE (targetTb.ActivityCode IS NULL)
GO

print 'tbActivityFlow'
insert into misImportDb.dbo.tbActivityFlow (ParentCode, StepNumber, ChildCode, OffsetDays, UsedOnQuantity, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.ParentCode, sourceTb.StepNumber, sourceTb.ChildCode, sourceTb.OffsetDays, sourceTb.UsedOnQuantity, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from TradeControlMIS.dbo.tbActivityFlow sourceTb
left outer join  misImportDb.dbo.tbActivityFlow targetTb
ON targetTb.ParentCode = sourceTb.ParentCode AND targetTb.StepNumber = sourceTb.StepNumber
WHERE (targetTb.ParentCode IS NULL)
GO

print 'tbActivityOpType'
insert into misImportDb.dbo.tbActivityOpType (OpTypeCode, OpType)
select sourceTb.OpTypeCode, sourceTb.OpType
from TradeControlMIS.dbo.tbActivityOpType sourceTb
left outer join  misImportDb.dbo.tbActivityOpType targetTb
ON targetTb.OpTypeCode = sourceTb.OpTypeCode
WHERE (targetTb.OpTypeCode IS NULL)
GO

print 'tbActivityOp'
insert into misImportDb.dbo.tbActivityOp (ActivityCode, OperationNumber, OpTypeCode, Operation, Duration, OffsetDays, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.ActivityCode, sourceTb.OperationNumber, sourceTb.OpTypeCode, sourceTb.Operation, sourceTb.Duration, sourceTb.OffsetDays, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from TradeControlMIS.dbo.tbActivityOp sourceTb
left outer join  misImportDb.dbo.tbActivityOp targetTb
ON targetTb.ActivityCode = sourceTb.ActivityCode AND targetTb.OperationNumber = sourceTb.OperationNumber
WHERE (targetTb.ActivityCode IS NULL)
GO

print 'tbCashCategoryExp'
insert into misImportDb.dbo.tbCashCategoryExp (CategoryCode, Expression, Format)
select sourceTb.CategoryCode, sourceTb.Expression, sourceTb.Format
from TradeControlMIS.dbo.tbCashCategoryExp sourceTb
left outer join  misImportDb.dbo.tbCashCategoryExp targetTb
ON targetTb.CategoryCode = sourceTb.CategoryCode
WHERE (targetTb.CategoryCode IS NULL)
GO

print 'tbCashCategoryTotal'
insert into misImportDb.dbo.tbCashCategoryTotal (ParentCode, ChildCode)
select sourceTb.ParentCode, sourceTb.ChildCode
from TradeControlMIS.dbo.tbCashCategoryTotal sourceTb
left outer join  misImportDb.dbo.tbCashCategoryTotal targetTb
ON targetTb.ParentCode = sourceTb.ParentCode AND targetTb.ChildCode = sourceTb.ChildCode
WHERE (targetTb.ParentCode IS NULL)
GO


print 'tbSystemMonth'
insert into misImportDb.dbo.tbSystemMonth (MonthNumber, MonthName)
select sourceTb.MonthNumber, sourceTb.MonthName
from TradeControlMIS.dbo.tbSystemMonth sourceTb
left outer join  misImportDb.dbo.tbSystemMonth targetTb
ON targetTb.MonthNumber = sourceTb.MonthNumber
WHERE (targetTb.MonthNumber IS NULL)
GO

print 'tbSystemYear'
insert into misImportDb.dbo.tbSystemYear (YearNumber, StartMonth, CashStatusCode, Description, InsertedBy, InsertedOn)
select sourceTb.YearNumber, sourceTb.StartMonth, sourceTb.CashStatusCode, sourceTb.Description, sourceTb.InsertedBy, sourceTb.InsertedOn
from TradeControlMIS.dbo.tbSystemYear sourceTb
left outer join  misImportDb.dbo.tbSystemYear targetTb
ON targetTb.YearNumber = sourceTb.YearNumber
WHERE (targetTb.YearNumber IS NULL)
GO

print 'tbSystemYearPeriod'
insert into misImportDb.dbo.tbSystemYearPeriod (YearNumber, StartOn, MonthNumber, CashStatusCode, InsertedBy, InsertedOn, CorporationTaxRate, TaxAdjustment, VatAdjustment)
select sourceTb.YearNumber, sourceTb.StartOn, sourceTb.MonthNumber, sourceTb.CashStatusCode, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.CorporationTaxRate, sourceTb.TaxAdjustment, sourceTb.VatAdjustment
from TradeControlMIS.dbo.tbSystemYearPeriod sourceTb
left outer join  misImportDb.dbo.tbSystemYearPeriod targetTb
ON targetTb.YearNumber = sourceTb.YearNumber AND targetTb.StartOn = sourceTb.StartOn
WHERE (targetTb.YearNumber IS NULL)
GO

print 'tbCashPeriod'
insert into misImportDb.dbo.tbCashPeriod (CashCode, StartOn, ForecastValue, ForecastTax, InvoiceValue, InvoiceTax, Note)
select sourceTb.CashCode, sourceTb.StartOn, sourceTb.ForecastValue, sourceTb.ForecastTax, sourceTb.InvoiceValue, sourceTb.InvoiceTax, sourceTb.Note
from TradeControlMIS.dbo.tbCashPeriod sourceTb
left outer join  misImportDb.dbo.tbCashPeriod targetTb
ON targetTb.CashCode = sourceTb.CashCode AND targetTb.StartOn = sourceTb.StartOn
WHERE (targetTb.CashCode IS NULL)
GO

print 'tbOrgStatus'
insert into misImportDb.dbo.tbOrgStatus (OrganisationStatusCode, OrganisationStatus)
select sourceTb.OrganisationStatusCode, sourceTb.OrganisationStatus
from TradeControlMIS.dbo.tbOrgStatus sourceTb
left outer join  misImportDb.dbo.tbOrgStatus targetTb
ON targetTb.OrganisationStatusCode = sourceTb.OrganisationStatusCode
WHERE (targetTb.OrganisationStatusCode IS NULL)
GO

print 'tbOrgType'
insert into misImportDb.dbo.tbOrgType (OrganisationTypeCode, CashModeCode, OrganisationType)
select sourceTb.OrganisationTypeCode, sourceTb.CashModeCode, sourceTb.OrganisationType
from TradeControlMIS.dbo.tbOrgType sourceTb
left outer join  misImportDb.dbo.tbOrgType targetTb
ON targetTb.OrganisationTypeCode = sourceTb.OrganisationTypeCode
WHERE (targetTb.OrganisationTypeCode IS NULL)
GO


print 'tbOrg'
insert into misImportDb.dbo.tbOrg (AccountCode, AccountName, OrganisationTypeCode, OrganisationStatusCode, TaxCode, AddressCode, AreaCode, PhoneNumber, FaxNumber, EmailAddress, WebSite, IndustrySector, AccountSource, PaymentTerms, NumberOfEmployees, CompanyNumber, VatNumber, Turnover, StatementDays, OpeningBalance, CurrentBalance, ForeignJurisdiction, BusinessDescription, Logo, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, PaymentDays, PayDaysFromMonthEnd)
select sourceTb.AccountCode, sourceTb.AccountName, sourceTb.OrganisationTypeCode, sourceTb.OrganisationStatusCode, sourceTb.TaxCode, sourceTb.AddressCode, sourceTb.AreaCode, sourceTb.PhoneNumber, sourceTb.FaxNumber, sourceTb.EmailAddress, sourceTb.WebSite, sourceTb.IndustrySector, sourceTb.AccountSource, sourceTb.PaymentTerms, sourceTb.NumberOfEmployees, sourceTb.CompanyNumber, sourceTb.VatNumber, sourceTb.Turnover, sourceTb.StatementDays, sourceTb.OpeningBalance, sourceTb.CurrentBalance, sourceTb.ForeignJurisdiction, sourceTb.BusinessDescription, sourceTb.Logo, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn, sourceTb.PaymentDays, sourceTb.PayDaysFromMonthEnd
from TradeControlMIS.dbo.tbOrg sourceTb
left outer join  misImportDb.dbo.tbOrg targetTb
ON targetTb.AccountCode = sourceTb.AccountCode
WHERE (targetTb.AccountCode IS NULL)
GO

print 'tbOrgAccount'
insert into misImportDb.dbo.tbOrgAccount (CashAccountCode, AccountCode, CashAccountName, OpeningBalance, CurrentBalance, SortCode, AccountNumber, CashCode, AccountClosed, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.CashAccountCode, sourceTb.AccountCode, sourceTb.CashAccountName, sourceTb.OpeningBalance, sourceTb.CurrentBalance, sourceTb.SortCode, sourceTb.AccountNumber, sourceTb.CashCode, sourceTb.AccountClosed, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from TradeControlMIS.dbo.tbOrgAccount sourceTb
left outer join  misImportDb.dbo.tbOrgAccount targetTb
ON targetTb.CashAccountCode = sourceTb.CashAccountCode
WHERE (targetTb.CashAccountCode IS NULL)
GO

print 'tbSystemRecurrence'
insert into misImportDb.dbo.tbSystemRecurrence (RecurrenceCode, Recurrence)
select sourceTb.RecurrenceCode, sourceTb.Recurrence
from TradeControlMIS.dbo.tbSystemRecurrence sourceTb
left outer join  misImportDb.dbo.tbSystemRecurrence targetTb
ON targetTb.RecurrenceCode = sourceTb.RecurrenceCode
WHERE (targetTb.RecurrenceCode IS NULL)
GO


print 'tbInvoiceStatus'
insert into misImportDb.dbo.tbInvoiceStatus (InvoiceStatusCode, InvoiceStatus)
select sourceTb.InvoiceStatusCode, sourceTb.InvoiceStatus
from TradeControlMIS.dbo.tbInvoiceStatus sourceTb
left outer join  misImportDb.dbo.tbInvoiceStatus targetTb
ON targetTb.InvoiceStatusCode = sourceTb.InvoiceStatusCode
WHERE (targetTb.InvoiceStatusCode IS NULL)
GO

print 'tbInvoiceType'
insert into misImportDb.dbo.tbInvoiceType (InvoiceTypeCode, InvoiceType, CashModeCode, NextNumber)
select sourceTb.InvoiceTypeCode, sourceTb.InvoiceType, sourceTb.CashModeCode, sourceTb.NextNumber
from TradeControlMIS.dbo.tbInvoiceType sourceTb
left outer join  misImportDb.dbo.tbInvoiceType targetTb
ON targetTb.InvoiceTypeCode = sourceTb.InvoiceTypeCode
WHERE (targetTb.InvoiceTypeCode IS NULL)
GO

print 'tbSystemCalendar'
insert into misImportDb.dbo.tbSystemCalendar (CalendarCode, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday)
select sourceTb.CalendarCode, sourceTb.Monday, sourceTb.Tuesday, sourceTb.Wednesday, sourceTb.Thursday, sourceTb.Friday, sourceTb.Saturday, sourceTb.Sunday
from TradeControlMIS.dbo.tbSystemCalendar sourceTb
left outer join  misImportDb.dbo.tbSystemCalendar targetTb
ON targetTb.CalendarCode = sourceTb.CalendarCode
WHERE (targetTb.CalendarCode IS NULL)
GO

print 'tbUser'
insert into misImportDb.dbo.tbUser (UserId, UserName, LogonName, CalendarCode, PhoneNumber, MobileNumber, FaxNumber, EmailAddress, Address, Administrator, Avatar, Signature, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, NextTaskNumber)
select sourceTb.UserId, sourceTb.UserName, sourceTb.LogonName, sourceTb.CalendarCode, sourceTb.PhoneNumber, sourceTb.MobileNumber, sourceTb.FaxNumber, sourceTb.EmailAddress, sourceTb.Address, sourceTb.Administrator, sourceTb.Avatar, sourceTb.Signature, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn, sourceTb.NextTaskNumber
from TradeControlMIS.dbo.tbUser sourceTb
left outer join  misImportDb.dbo.tbUser targetTb
ON targetTb.UserId = sourceTb.UserId
WHERE (targetTb.UserId IS NULL)
GO

print 'tbInvoice'
insert into misImportDb.dbo.tbInvoice (InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Notes, Printed, Spooled, CollectOn)
select sourceTb.InvoiceNumber, sourceTb.UserId, sourceTb.AccountCode, sourceTb.InvoiceTypeCode, sourceTb.InvoiceStatusCode, sourceTb.InvoicedOn, sourceTb.InvoiceValue, sourceTb.TaxValue, sourceTb.PaidValue, sourceTb.PaidTaxValue, sourceTb.PaymentTerms, sourceTb.Notes, sourceTb.Printed, sourceTb.Spooled, sourceTb.CollectOn
from TradeControlMIS.dbo.tbInvoice sourceTb
left outer join  misImportDb.dbo.tbInvoice targetTb
ON targetTb.InvoiceNumber = sourceTb.InvoiceNumber
WHERE (targetTb.InvoiceNumber IS NULL)
GO

print 'tbInvoiceItem'
insert into misImportDb.dbo.tbInvoiceItem (InvoiceNumber, CashCode, TaxCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, ItemReference)
select sourceTb.InvoiceNumber, sourceTb.CashCode, sourceTb.TaxCode, sourceTb.InvoiceValue, sourceTb.TaxValue, sourceTb.PaidValue, sourceTb.PaidTaxValue, sourceTb.ItemReference
from TradeControlMIS.dbo.tbInvoiceItem sourceTb
left outer join  misImportDb.dbo.tbInvoiceItem targetTb
ON targetTb.InvoiceNumber = sourceTb.InvoiceNumber AND targetTb.CashCode = sourceTb.CashCode
WHERE (targetTb.InvoiceNumber IS NULL)
GO

print 'tbOrgAddress'
insert into misImportDb.dbo.tbOrgAddress (AddressCode, AccountCode, Address, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.AddressCode, sourceTb.AccountCode, sourceTb.Address, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from TradeControlMIS.dbo.tbOrgAddress sourceTb
left outer join  misImportDb.dbo.tbOrgAddress targetTb
ON targetTb.AddressCode = sourceTb.AddressCode
WHERE (targetTb.AddressCode IS NULL)
GO

print 'tbTaskStatus'
insert into misImportDb.dbo.tbTaskStatus (TaskStatusCode, TaskStatus)
select sourceTb.TaskStatusCode, sourceTb.TaskStatus
from TradeControlMIS.dbo.tbTaskStatus sourceTb
left outer join  misImportDb.dbo.tbTaskStatus targetTb
ON targetTb.TaskStatusCode = sourceTb.TaskStatusCode
WHERE (targetTb.TaskStatusCode IS NULL)
GO

print 'tbTask'
insert into misImportDb.dbo.tbTask (TaskCode, UserId, AccountCode, TaskTitle, ContactName, ActivityCode, TaskStatusCode, ActionById, ActionOn, ActionedOn, PaymentOn, SecondReference, TaskNotes, Quantity, CashCode, TaxCode, UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, Printed, Spooled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.TaskCode, sourceTb.UserId, sourceTb.AccountCode, sourceTb.TaskTitle, sourceTb.ContactName, sourceTb.ActivityCode, sourceTb.TaskStatusCode, sourceTb.ActionById, sourceTb.ActionOn, sourceTb.ActionedOn, sourceTb.PaymentOn, sourceTb.SecondReference, sourceTb.TaskNotes, sourceTb.Quantity, sourceTb.CashCode, sourceTb.TaxCode, sourceTb.UnitCharge, sourceTb.TotalCharge, sourceTb.AddressCodeFrom, sourceTb.AddressCodeTo, sourceTb.Printed, sourceTb.Spooled, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from TradeControlMIS.dbo.tbTask sourceTb
left outer join  misImportDb.dbo.tbTask targetTb
ON targetTb.TaskCode = sourceTb.TaskCode
WHERE (targetTb.TaskCode IS NULL)
GO

print 'tbInvoiceTask'
insert into misImportDb.dbo.tbInvoiceTask (InvoiceNumber, TaskCode, Quantity, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, CashCode, TaxCode)
select sourceTb.InvoiceNumber, sourceTb.TaskCode, sourceTb.Quantity, sourceTb.InvoiceValue, sourceTb.TaxValue, sourceTb.PaidValue, sourceTb.PaidTaxValue, sourceTb.CashCode, sourceTb.TaxCode
from TradeControlMIS.dbo.tbInvoiceTask sourceTb
left outer join  misImportDb.dbo.tbInvoiceTask targetTb
ON targetTb.InvoiceNumber = sourceTb.InvoiceNumber AND targetTb.TaskCode = sourceTb.TaskCode
WHERE (targetTb.InvoiceNumber IS NULL)
GO

print 'tbOrgContact'
insert into misImportDb.dbo.tbOrgContact (AccountCode, ContactName, FileAs, OnMailingList, NameTitle, NickName, JobTitle, PhoneNumber, MobileNumber, FaxNumber, EmailAddress, Hobby, DateOfBirth, Department, SpouseName, Information, Photo, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, HomeNumber)
select sourceTb.AccountCode, sourceTb.ContactName, sourceTb.FileAs, sourceTb.OnMailingList, sourceTb.NameTitle, sourceTb.NickName, sourceTb.JobTitle, sourceTb.PhoneNumber, sourceTb.MobileNumber, sourceTb.FaxNumber, sourceTb.EmailAddress, sourceTb.Hobby, sourceTb.DateOfBirth, sourceTb.Department, sourceTb.SpouseName, sourceTb.Information, sourceTb.Photo, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn, sourceTb.HomeNumber
from TradeControlMIS.dbo.tbOrgContact sourceTb
left outer join  misImportDb.dbo.tbOrgContact targetTb
ON targetTb.AccountCode = sourceTb.AccountCode AND targetTb.ContactName = sourceTb.ContactName
WHERE (targetTb.AccountCode IS NULL)
GO

print 'tbOrgDoc'
insert into misImportDb.dbo.tbOrgDoc (AccountCode, DocumentName, DocumentDescription, DocumentImage, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.AccountCode, sourceTb.DocumentName, sourceTb.DocumentDescription, sourceTb.DocumentImage, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from TradeControlMIS.dbo.tbOrgDoc sourceTb
left outer join  misImportDb.dbo.tbOrgDoc targetTb
ON targetTb.AccountCode = sourceTb.AccountCode AND targetTb.DocumentName = sourceTb.DocumentName
WHERE (targetTb.AccountCode IS NULL)
GO

print 'tbOrgPaymentStatus'
insert into misImportDb.dbo.tbOrgPaymentStatus (PaymentStatusCode, PaymentStatus)
select sourceTb.PaymentStatusCode, sourceTb.PaymentStatus
from TradeControlMIS.dbo.tbOrgPaymentStatus sourceTb
left outer join  misImportDb.dbo.tbOrgPaymentStatus targetTb
ON targetTb.PaymentStatusCode = sourceTb.PaymentStatusCode
WHERE (targetTb.PaymentStatusCode IS NULL)
GO

print 'tbOrgPayment'
insert into misImportDb.dbo.tbOrgPayment (PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, TaxCode, PaidOn, PaidInValue, PaidOutValue, TaxInValue, TaxOutValue, PaymentReference, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.PaymentCode, sourceTb.UserId, sourceTb.PaymentStatusCode, sourceTb.AccountCode, sourceTb.CashAccountCode, sourceTb.CashCode, sourceTb.TaxCode, sourceTb.PaidOn, sourceTb.PaidInValue, sourceTb.PaidOutValue, sourceTb.TaxInValue, sourceTb.TaxOutValue, sourceTb.PaymentReference, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from TradeControlMIS.dbo.tbOrgPayment sourceTb
left outer join  misImportDb.dbo.tbOrgPayment targetTb
ON targetTb.PaymentCode = sourceTb.PaymentCode
WHERE (targetTb.PaymentCode IS NULL)
GO

print 'tbOrgSector'
insert into misImportDb.dbo.tbOrgSector (AccountCode, IndustrySector)
select sourceTb.AccountCode, sourceTb.IndustrySector
from TradeControlMIS.dbo.tbOrgSector sourceTb
left outer join  misImportDb.dbo.tbOrgSector targetTb
ON targetTb.AccountCode = sourceTb.AccountCode AND targetTb.IndustrySector = sourceTb.IndustrySector
WHERE (targetTb.AccountCode IS NULL)
GO

print 'tbProfileMenu'
set identity_insert misImportDb.dbo.tbProfileMenu on
insert into misImportDb.dbo.tbProfileMenu (MenuId, MenuName, InsertedOn, InsertedBy)
select sourceTb.MenuId, sourceTb.MenuName, sourceTb.InsertedOn, sourceTb.InsertedBy
from TradeControlMIS.dbo.tbProfileMenu sourceTb
left outer join  misImportDb.dbo.tbProfileMenu targetTb
ON targetTb.MenuId = sourceTb.MenuId
WHERE (targetTb.MenuId IS NULL)
set identity_insert misImportDb.dbo.tbProfileMenu off
GO

print 'tbProfileMenuCommand'
insert into misImportDb.dbo.tbProfileMenuCommand (Command, CommandText)
select sourceTb.Command, sourceTb.CommandText
from TradeControlMIS.dbo.tbProfileMenuCommand sourceTb
left outer join  misImportDb.dbo.tbProfileMenuCommand targetTb
ON targetTb.Command = sourceTb.Command
WHERE (targetTb.Command IS NULL)
GO

print 'tbProfileMenuOpenMode'
insert into misImportDb.dbo.tbProfileMenuOpenMode (OpenMode, OpenModeDescription)
select sourceTb.OpenMode, sourceTb.OpenModeDescription
from TradeControlMIS.dbo.tbProfileMenuOpenMode sourceTb
left outer join  misImportDb.dbo.tbProfileMenuOpenMode targetTb
ON targetTb.OpenMode = sourceTb.OpenMode
WHERE (targetTb.OpenMode IS NULL)
GO

print 'tbProfileMenuEntry'
set identity_insert misImportDb.dbo.tbProfileMenuEntry on
insert into misImportDb.dbo.tbProfileMenuEntry (MenuId, EntryId, FolderId, ItemId, ItemText, Command, ProjectName, Argument, OpenMode, UpdatedOn, InsertedOn, UpdatedBy)
select sourceTb.MenuId, sourceTb.EntryId, sourceTb.FolderId, sourceTb.ItemId, sourceTb.ItemText, sourceTb.Command, sourceTb.ProjectName, sourceTb.Argument, sourceTb.OpenMode, sourceTb.UpdatedOn, sourceTb.InsertedOn, sourceTb.UpdatedBy
from TradeControlMIS.dbo.tbProfileMenuEntry sourceTb
left outer join  misImportDb.dbo.tbProfileMenuEntry targetTb
ON targetTb.MenuId = sourceTb.MenuId AND targetTb.EntryId = sourceTb.EntryId
WHERE (targetTb.MenuId IS NULL)
set identity_insert misImportDb.dbo.tbProfileMenuEntry off
GO

print 'tbProfileText'
insert into misImportDb.dbo.tbProfileText (TextId, Message, Arguments)
select sourceTb.TextId, sourceTb.Message, sourceTb.Arguments
from TradeControlMIS.dbo.tbProfileText sourceTb
left outer join  misImportDb.dbo.tbProfileText targetTb
ON targetTb.TextId = sourceTb.TextId
WHERE (targetTb.TextId IS NULL)
GO

print 'tbSystemBucket'
insert into misImportDb.dbo.tbSystemBucket (Period, BucketId, BucketDescription, AllowForecasts)
select sourceTb.Period, sourceTb.BucketId, sourceTb.BucketDescription, sourceTb.AllowForecasts
from TradeControlMIS.dbo.tbSystemBucket sourceTb
left outer join  misImportDb.dbo.tbSystemBucket targetTb
ON targetTb.Period = sourceTb.Period
WHERE (targetTb.Period IS NULL)
GO

print 'tbSystemBucketInterval'
insert into misImportDb.dbo.tbSystemBucketInterval (BucketIntervalCode, BucketInterval)
select sourceTb.BucketIntervalCode, sourceTb.BucketInterval
from TradeControlMIS.dbo.tbSystemBucketInterval sourceTb
left outer join  misImportDb.dbo.tbSystemBucketInterval targetTb
ON targetTb.BucketIntervalCode = sourceTb.BucketIntervalCode
WHERE (targetTb.BucketIntervalCode IS NULL)
GO

print 'tbSystemBucketType'
insert into misImportDb.dbo.tbSystemBucketType (BucketTypeCode, BucketType)
select sourceTb.BucketTypeCode, sourceTb.BucketType
from TradeControlMIS.dbo.tbSystemBucketType sourceTb
left outer join  misImportDb.dbo.tbSystemBucketType targetTb
ON targetTb.BucketTypeCode = sourceTb.BucketTypeCode
WHERE (targetTb.BucketTypeCode IS NULL)
GO

print 'tbSystemCalendarHoliday'
insert into misImportDb.dbo.tbSystemCalendarHoliday (CalendarCode, UnavailableOn)
select sourceTb.CalendarCode, sourceTb.UnavailableOn
from TradeControlMIS.dbo.tbSystemCalendarHoliday sourceTb
left outer join  misImportDb.dbo.tbSystemCalendarHoliday targetTb
ON targetTb.CalendarCode = sourceTb.CalendarCode AND targetTb.UnavailableOn = sourceTb.UnavailableOn
WHERE (targetTb.CalendarCode IS NULL)
GO

print 'tbSystemCodeExclusion'
insert into misImportDb.dbo.tbSystemCodeExclusion (ExcludedTag)
select sourceTb.ExcludedTag
from TradeControlMIS.dbo.tbSystemCodeExclusion sourceTb
left outer join  misImportDb.dbo.tbSystemCodeExclusion targetTb
ON targetTb.ExcludedTag = sourceTb.ExcludedTag
WHERE (targetTb.ExcludedTag IS NULL)
GO

print 'tbSystemDoc'
insert into misImportDb.dbo.tbSystemDoc (DocTypeCode, ReportName, OpenMode, Description)
select sourceTb.DocTypeCode, sourceTb.ReportName, sourceTb.OpenMode, sourceTb.Description
from TradeControlMIS.dbo.tbSystemDoc sourceTb
left outer join  misImportDb.dbo.tbSystemDoc targetTb
ON targetTb.DocTypeCode = sourceTb.DocTypeCode AND targetTb.ReportName = sourceTb.ReportName
WHERE (targetTb.DocTypeCode IS NULL)
GO

print 'tbSystemDocType'
insert into misImportDb.dbo.tbSystemDocType (DocTypeCode, DocType)
select sourceTb.DocTypeCode, sourceTb.DocType
from TradeControlMIS.dbo.tbSystemDocType sourceTb
left outer join  misImportDb.dbo.tbSystemDocType targetTb
ON targetTb.DocTypeCode = sourceTb.DocTypeCode
WHERE (targetTb.DocTypeCode IS NULL)
GO

print 'tbSystemDocSpool'
insert into misImportDb.dbo.tbSystemDocSpool (UserName, DocTypeCode, DocumentNumber, SpooledOn)
select sourceTb.UserName, sourceTb.DocTypeCode, sourceTb.DocumentNumber, sourceTb.SpooledOn
from TradeControlMIS.dbo.tbSystemDocSpool sourceTb
left outer join  misImportDb.dbo.tbSystemDocSpool targetTb
ON targetTb.UserName = sourceTb.UserName AND targetTb.DocTypeCode = sourceTb.DocTypeCode AND targetTb.DocumentNumber = sourceTb.DocumentNumber
WHERE (targetTb.UserName IS NULL)
GO

print 'tbSystemOptions'
insert into misImportDb.dbo.tbSystemOptions (Identifier, Initialised, SQLDataVersion, AccountCode, DefaultPrintMode, BucketTypeCode, BucketIntervalCode, ShowCashGraphs, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, NetProfitCode, NetProfitTaxCode, ScheduleOps, TaxHorizon)
select sourceTb.Identifier, sourceTb.Initialised, sourceTb.SQLDataVersion, sourceTb.AccountCode, sourceTb.DefaultPrintMode, sourceTb.BucketTypeCode, sourceTb.BucketIntervalCode, sourceTb.ShowCashGraphs, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn, sourceTb.NetProfitCode, sourceTb.NetProfitTaxCode, sourceTb.ScheduleOps, sourceTb.TaxHorizon
from TradeControlMIS.dbo.tbSystemOptions sourceTb
left outer join  misImportDb.dbo.tbSystemOptions targetTb
ON targetTb.Identifier = sourceTb.Identifier
WHERE (targetTb.Identifier IS NULL)
GO

print 'tbTaskAttribute'
insert into misImportDb.dbo.tbTaskAttribute (TaskCode, Attribute, PrintOrder, AttributeTypeCode, AttributeDescription, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.TaskCode, sourceTb.Attribute, sourceTb.PrintOrder, sourceTb.AttributeTypeCode, sourceTb.AttributeDescription, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from TradeControlMIS.dbo.tbTaskAttribute sourceTb
left outer join  misImportDb.dbo.tbTaskAttribute targetTb
ON targetTb.TaskCode = sourceTb.TaskCode AND targetTb.Attribute = sourceTb.Attribute
WHERE (targetTb.TaskCode IS NULL)
GO

print 'tbTaskDoc'
insert into misImportDb.dbo.tbTaskDoc (TaskCode, DocumentName, DocumentDescription, DocumentImage, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.TaskCode, sourceTb.DocumentName, sourceTb.DocumentDescription, sourceTb.DocumentImage, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from TradeControlMIS.dbo.tbTaskDoc sourceTb
left outer join  misImportDb.dbo.tbTaskDoc targetTb
ON targetTb.TaskCode = sourceTb.TaskCode AND targetTb.DocumentName = sourceTb.DocumentName
WHERE (targetTb.TaskCode IS NULL)
GO

print 'tbTaskFlow'
insert into misImportDb.dbo.tbTaskFlow (ParentTaskCode, StepNumber, ChildTaskCode, UsedOnQuantity, OffsetDays, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.ParentTaskCode, sourceTb.StepNumber, sourceTb.ChildTaskCode, sourceTb.UsedOnQuantity, sourceTb.OffsetDays, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from TradeControlMIS.dbo.tbTaskFlow sourceTb
left outer join  misImportDb.dbo.tbTaskFlow targetTb
ON targetTb.ParentTaskCode = sourceTb.ParentTaskCode AND targetTb.StepNumber = sourceTb.StepNumber
WHERE (targetTb.ParentTaskCode IS NULL)
GO

print 'tbTaskOpStatus'
insert into misImportDb.dbo.tbTaskOpStatus (OpStatusCode, OpStatus)
select sourceTb.OpStatusCode, sourceTb.OpStatus
from TradeControlMIS.dbo.tbTaskOpStatus sourceTb
left outer join  misImportDb.dbo.tbTaskOpStatus targetTb
ON targetTb.OpStatusCode = sourceTb.OpStatusCode
WHERE (targetTb.OpStatusCode IS NULL)
GO

print 'tbTaskOp'
insert into misImportDb.dbo.tbTaskOp (TaskCode, OperationNumber, UserId, OpTypeCode, OpStatusCode, Operation, Note, StartOn, EndOn, Duration, OffsetDays, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.TaskCode, sourceTb.OperationNumber, sourceTb.UserId, sourceTb.OpTypeCode, sourceTb.OpStatusCode, sourceTb.Operation, sourceTb.Note, sourceTb.StartOn, sourceTb.EndOn, sourceTb.Duration, sourceTb.OffsetDays, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from TradeControlMIS.dbo.tbTaskOp sourceTb
left outer join  misImportDb.dbo.tbTaskOp targetTb
ON targetTb.TaskCode = sourceTb.TaskCode AND targetTb.OperationNumber = sourceTb.OperationNumber
WHERE (targetTb.TaskCode IS NULL)
GO

print 'tbTaskQuote'
insert into misImportDb.dbo.tbTaskQuote (TaskCode, Quantity, TotalPrice, RunOnQuantity, RunOnPrice, RunBackQuantity, RunBackPrice, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn)
select sourceTb.TaskCode, sourceTb.Quantity, sourceTb.TotalPrice, sourceTb.RunOnQuantity, sourceTb.RunOnPrice, sourceTb.RunBackQuantity, sourceTb.RunBackPrice, sourceTb.InsertedBy, sourceTb.InsertedOn, sourceTb.UpdatedBy, sourceTb.UpdatedOn
from TradeControlMIS.dbo.tbTaskQuote sourceTb
left outer join  misImportDb.dbo.tbTaskQuote targetTb
ON targetTb.TaskCode = sourceTb.TaskCode AND targetTb.Quantity = sourceTb.Quantity
WHERE (targetTb.TaskCode IS NULL)
GO

print 'tbUserMenu'
insert into misImportDb.dbo.tbUserMenu (UserId, MenuId)
select sourceTb.UserId, sourceTb.MenuId
from TradeControlMIS.dbo.tbUserMenu sourceTb
left outer join  misImportDb.dbo.tbUserMenu targetTb
ON targetTb.UserId = sourceTb.UserId AND targetTb.MenuId = sourceTb.MenuId
WHERE (targetTb.UserId IS NULL)
GO

SET NOCOUNT OFF;