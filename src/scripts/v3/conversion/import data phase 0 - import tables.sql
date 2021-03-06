/*********************************************************
Trade Control
Import Data from the Version 2 Schema
Release: 3.02.1

Date: 7/5/2018
Author: IaM

Trade Control by Trade Control Ltd is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License. 

You may obtain a copy of the License at

	http://creativecommons.org/licenses/by-sa/4.0/

*********************************************************/

USE master;
DROP DATABASE IF EXISTS misImportDb;
GO
CREATE DATABASE misImportDb;
GO
USE misImportDb;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbActivity(
	ActivityCode nvarchar(50) NOT NULL,
	TaskStatusCode smallint NOT NULL,
	DefaultText ntext NULL,
	UnitOfMeasure nvarchar(15) NOT NULL,
	CashCode nvarchar(50) NULL,
	UnitCharge money NOT NULL,
	PrintOrder bit NOT NULL,
	RegisterName nvarchar(50) NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
 CONSTRAINT aaaaatbActivityCode_PK PRIMARY KEY NONCLUSTERED 
(
	ActivityCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbActivityAttribute(
	ActivityCode nvarchar(50) NOT NULL,
	Attribute nvarchar(50) NOT NULL,
	PrintOrder smallint NOT NULL,
	AttributeTypeCode smallint NOT NULL,
	DefaultText nvarchar(400) NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
 CONSTRAINT PK_tbActivityCodeAttrib PRIMARY KEY CLUSTERED 
(
	ActivityCode ASC,
	Attribute ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbActivityAttributeType(
	AttributeTypeCode smallint NOT NULL,
	AttributeType nvarchar(20) NOT NULL,
 CONSTRAINT PK_tbActivityAttributeType PRIMARY KEY CLUSTERED 
(
	AttributeTypeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbActivityFlow(
	ParentCode nvarchar(50) NOT NULL,
	StepNumber smallint NOT NULL,
	ChildCode nvarchar(50) NOT NULL,
	OffsetDays smallint NOT NULL,
	UsedOnQuantity float NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
 CONSTRAINT aaaaatbActivityCodeFlow_PK PRIMARY KEY NONCLUSTERED 
(
	ParentCode ASC,
	StepNumber ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbActivityOp(
	ActivityCode nvarchar(50) NOT NULL,
	OperationNumber smallint NOT NULL,
	OpTypeCode smallint NOT NULL,
	Operation nvarchar(50) NOT NULL,
	Duration float NOT NULL,
	OffsetDays smallint NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
 CONSTRAINT PK_tbActivityOp PRIMARY KEY CLUSTERED 
(
	ActivityCode ASC,
	OperationNumber ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbActivityOpType(
	OpTypeCode smallint NOT NULL,
	OpType nvarchar(50) NOT NULL,
 CONSTRAINT PK_tbActivityOpType PRIMARY KEY CLUSTERED 
(
	OpTypeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbCashCategory(
	CategoryCode nvarchar(10) NOT NULL,
	Category nvarchar(50) NOT NULL,
	CategoryTypeCode smallint NOT NULL,
	CashModeCode smallint NULL,
	CashTypeCode smallint NULL,
	DisplayOrder smallint NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
 CONSTRAINT PK_tbCashCategory PRIMARY KEY CLUSTERED 
(
	CategoryCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbCashCategoryExp(
	CategoryCode nvarchar(10) NOT NULL,
	Expression nvarchar(256) NOT NULL,
	Format nvarchar(100) NOT NULL,
 CONSTRAINT PK_tbCashCategoryExp PRIMARY KEY CLUSTERED 
(
	CategoryCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbCashCategoryTotal(
	ParentCode nvarchar(10) NOT NULL,
	ChildCode nvarchar(10) NOT NULL,
 CONSTRAINT PK_tbCashCategoryTotal PRIMARY KEY CLUSTERED 
(
	ParentCode ASC,
	ChildCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbCashCategoryType(
	CategoryTypeCode smallint NOT NULL,
	CategoryType nvarchar(20) NOT NULL,
 CONSTRAINT PK_tbCashCategoryType PRIMARY KEY CLUSTERED 
(
	CategoryTypeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbCashCode(
	CashCode nvarchar(50) NOT NULL,
	CashDescription nvarchar(100) NOT NULL,
	CategoryCode nvarchar(10) NOT NULL,
	TaxCode nvarchar(10) NOT NULL,
	OpeningBalance money NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
 CONSTRAINT PK_tbCashCode PRIMARY KEY CLUSTERED 
(
	CashCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbCashEntryType(
	CashEntryTypeCode smallint NOT NULL,
	CashEntryType nvarchar(20) NOT NULL,
 CONSTRAINT PK_tbCashEntryType PRIMARY KEY CLUSTERED 
(
	CashEntryTypeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbCashMode(
	CashModeCode smallint NOT NULL,
	CashMode nvarchar(10) NULL,
 CONSTRAINT PK_tbCashMode PRIMARY KEY CLUSTERED 
(
	CashModeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbCashPeriod(
	CashCode nvarchar(50) NOT NULL,
	StartOn datetime NOT NULL,
	ForecastValue money NOT NULL,
	ForecastTax money NOT NULL,
	InvoiceValue money NOT NULL,
	InvoiceTax money NOT NULL,
	Note ntext NULL,
 CONSTRAINT PK_tbCashPeriod PRIMARY KEY CLUSTERED 
(
	CashCode ASC,
	StartOn ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbCashStatus(
	CashStatusCode smallint NOT NULL,
	CashStatus nvarchar(15) NOT NULL,
 CONSTRAINT PK_tbCashStatus PRIMARY KEY CLUSTERED 
(
	CashStatusCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbCashTaxType(
	TaxTypeCode smallint NOT NULL,
	TaxType nvarchar(20) NOT NULL,
	CashCode nvarchar(50) NULL,
	MonthNumber smallint NOT NULL,
	RecurrenceCode smallint NOT NULL,
	AccountCode nvarchar(10) NULL,
	CashAccountCode nvarchar(10) NULL,
 CONSTRAINT PK_tbCashTaxType PRIMARY KEY CLUSTERED 
(
	TaxTypeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbCashType(
	CashTypeCode smallint NOT NULL,
	CashType nvarchar(25) NULL,
 CONSTRAINT PK_tbCashType PRIMARY KEY CLUSTERED 
(
	CashTypeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbInvoice(
	InvoiceNumber nvarchar(20) NOT NULL,
	UserId nvarchar(10) NOT NULL,
	AccountCode nvarchar(10) NOT NULL,
	InvoiceTypeCode smallint NOT NULL,
	InvoiceStatusCode smallint NOT NULL,
	InvoicedOn datetime NOT NULL,
	InvoiceValue money NOT NULL,
	TaxValue money NOT NULL,
	PaidValue money NOT NULL,
	PaidTaxValue money NOT NULL,
	PaymentTerms nvarchar(100) NULL,
	Notes ntext NULL,
	Printed bit NOT NULL,
	Spooled bit NOT NULL,
	CollectOn datetime NOT NULL,
 CONSTRAINT PK_tbInvoice PRIMARY KEY CLUSTERED 
(
	InvoiceNumber ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbInvoiceItem(
	InvoiceNumber nvarchar(20) NOT NULL,
	CashCode nvarchar(50) NOT NULL,
	TaxCode nvarchar(10) NULL,
	InvoiceValue money NOT NULL,
	TaxValue money NOT NULL,
	PaidValue money NOT NULL,
	PaidTaxValue money NOT NULL,
	ItemReference ntext NULL,
 CONSTRAINT PK_tbInvoiceItem PRIMARY KEY CLUSTERED 
(
	InvoiceNumber ASC,
	CashCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbInvoiceStatus(
	InvoiceStatusCode smallint NOT NULL,
	InvoiceStatus nvarchar(50) NULL,
 CONSTRAINT aaaaatbInvoiceStatus_PK PRIMARY KEY NONCLUSTERED 
(
	InvoiceStatusCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbInvoiceTask(
	InvoiceNumber nvarchar(20) NOT NULL,
	TaskCode nvarchar(20) NOT NULL,
	Quantity float NOT NULL,
	InvoiceValue money NOT NULL,
	TaxValue money NOT NULL,
	PaidValue money NOT NULL,
	PaidTaxValue money NOT NULL,
	CashCode nvarchar(50) NOT NULL,
	TaxCode nvarchar(10) NULL,
 CONSTRAINT PK_tbInvoiceTask PRIMARY KEY CLUSTERED 
(
	InvoiceNumber ASC,
	TaskCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbInvoiceType(
	InvoiceTypeCode smallint NOT NULL,
	InvoiceType nvarchar(20) NOT NULL,
	CashModeCode smallint NOT NULL,
	NextNumber int NOT NULL,
 CONSTRAINT PK_tbInvoiceType PRIMARY KEY CLUSTERED 
(
	InvoiceTypeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbOrg(
	AccountCode nvarchar(10) NOT NULL,
	AccountName nvarchar(255) NOT NULL,
	OrganisationTypeCode smallint NOT NULL,
	OrganisationStatusCode smallint NOT NULL,
	TaxCode nvarchar(10) NULL,
	AddressCode nvarchar(15) NULL,
	AreaCode nvarchar(50) NULL,
	PhoneNumber nvarchar(50) NULL,
	FaxNumber nvarchar(50) NULL,
	EmailAddress nvarchar(255) NULL,
	WebSite nvarchar(255) NULL,
	IndustrySector nvarchar(255) NULL,
	AccountSource nvarchar(100) NULL,
	PaymentTerms nvarchar(100) NULL,
	NumberOfEmployees int NOT NULL,
	CompanyNumber nvarchar(20) NULL,
	VatNumber nvarchar(50) NULL,
	Turnover money NOT NULL,
	StatementDays smallint NOT NULL,
	OpeningBalance money NOT NULL,
	CurrentBalance money NOT NULL,
	ForeignJurisdiction bit NOT NULL,
	BusinessDescription ntext NULL,
	Logo image NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	PaymentDays smallint NOT NULL,
	PayDaysFromMonthEnd bit NOT NULL,
 CONSTRAINT aaaaatbOrg_PK PRIMARY KEY NONCLUSTERED 
(
	AccountCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbOrgAccount(
	CashAccountCode nvarchar(10) NOT NULL,
	AccountCode nvarchar(10) NOT NULL,
	CashAccountName nvarchar(50) NOT NULL,
	OpeningBalance money NOT NULL,
	CurrentBalance money NOT NULL,
	SortCode nvarchar(10) NULL,
	AccountNumber nvarchar(20) NULL,
	CashCode nvarchar(50) NULL,
	AccountClosed bit NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
 CONSTRAINT PK_tbOrgAccount PRIMARY KEY CLUSTERED 
(
	CashAccountCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbOrgAddress(
	AddressCode nvarchar(15) NOT NULL,
	AccountCode nvarchar(10) NOT NULL,
	Address ntext NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
 CONSTRAINT PK_tbOrgAddress PRIMARY KEY CLUSTERED 
(
	AddressCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbOrgContact(
	AccountCode nvarchar(10) NOT NULL,
	ContactName nvarchar(100) NOT NULL,
	FileAs nvarchar(100) NULL,
	OnMailingList bit NOT NULL,
	NameTitle nvarchar(25) NULL,
	NickName nvarchar(100) NULL,
	JobTitle nvarchar(100) NULL,
	PhoneNumber nvarchar(50) NULL,
	MobileNumber nvarchar(50) NULL,
	FaxNumber nvarchar(50) NULL,
	EmailAddress nvarchar(255) NULL,
	Hobby nvarchar(50) NULL,
	DateOfBirth datetime NULL,
	Department nvarchar(50) NULL,
	SpouseName nvarchar(50) NULL,
	Information ntext NULL,
	Photo image NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	HomeNumber nvarchar(50) NULL,
 CONSTRAINT aaaaatbOrgContact_PK PRIMARY KEY NONCLUSTERED 
(
	AccountCode ASC,
	ContactName ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbOrgDoc(
	AccountCode nvarchar(10) NOT NULL,
	DocumentName nvarchar(255) NOT NULL,
	DocumentDescription ntext NULL,
	DocumentImage image NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
 CONSTRAINT aaaaatbOrgDoc_PK PRIMARY KEY NONCLUSTERED 
(
	AccountCode ASC,
	DocumentName ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbOrgPayment(
	PaymentCode nvarchar(20) NOT NULL,
	UserId nvarchar(10) NOT NULL,
	PaymentStatusCode smallint NOT NULL,
	AccountCode nvarchar(10) NOT NULL,
	CashAccountCode nvarchar(10) NOT NULL,
	CashCode nvarchar(50) NULL,
	TaxCode nvarchar(10) NULL,
	PaidOn datetime NOT NULL,
	PaidInValue money NOT NULL,
	PaidOutValue money NOT NULL,
	TaxInValue money NOT NULL,
	TaxOutValue money NOT NULL,
	PaymentReference nvarchar(50) NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
 CONSTRAINT PK_tbOrgPayment PRIMARY KEY CLUSTERED 
(
	PaymentCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbOrgPaymentStatus(
	PaymentStatusCode smallint NOT NULL,
	PaymentStatus nvarchar(20) NOT NULL,
 CONSTRAINT PK_tbOrgPaymentStatus PRIMARY KEY CLUSTERED 
(
	PaymentStatusCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbOrgSector(
	AccountCode nvarchar(10) NOT NULL,
	IndustrySector nvarchar(50) NOT NULL,
 CONSTRAINT PK_tbOrgSector PRIMARY KEY CLUSTERED 
(
	AccountCode ASC,
	IndustrySector ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbOrgStatus(
	OrganisationStatusCode smallint NOT NULL,
	OrganisationStatus nvarchar(255) NULL,
 CONSTRAINT aaaaatbOrgStatus_PK PRIMARY KEY NONCLUSTERED 
(
	OrganisationStatusCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbOrgType(
	OrganisationTypeCode smallint NOT NULL,
	CashModeCode smallint NOT NULL,
	OrganisationType nvarchar(50) NOT NULL,
 CONSTRAINT aaaaatbOrgType_PK PRIMARY KEY NONCLUSTERED 
(
	OrganisationTypeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbProfileMenu(
	MenuId smallint IDENTITY(1,1) NOT NULL,
	MenuName nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
 CONSTRAINT PK_tbProfileMenu PRIMARY KEY CLUSTERED 
(
	MenuId ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbProfileMenuCommand(
	Command smallint NOT NULL,
	CommandText nvarchar(50) NULL,
 CONSTRAINT PK_tbProfileMenuCommand PRIMARY KEY CLUSTERED 
(
	Command ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbProfileMenuEntry(
	MenuId smallint NOT NULL,
	EntryId int IDENTITY(1,1) NOT NULL,
	FolderId smallint NOT NULL,
	ItemId smallint NOT NULL,
	ItemText nvarchar(255) NULL,
	Command smallint NULL,
	ProjectName nvarchar(50) NULL,
	Argument nvarchar(50) NULL,
	OpenMode smallint NULL,
	UpdatedOn datetime NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
 CONSTRAINT PK_tbProfileMenuEntry PRIMARY KEY CLUSTERED 
(
	MenuId ASC,
	EntryId ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbProfileMenuOpenMode(
	OpenMode smallint NOT NULL,
	OpenModeDescription nvarchar(20) NULL,
 CONSTRAINT PK_tbProfileMenuOpenMode PRIMARY KEY CLUSTERED 
(
	OpenMode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbProfileText(
	TextId int NOT NULL,
	Message ntext NOT NULL,
	Arguments smallint NOT NULL,
 CONSTRAINT PK_tbProfileText PRIMARY KEY CLUSTERED 
(
	TextId ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbSystemBucket(
	Period smallint NOT NULL,
	BucketId nvarchar(10) NOT NULL,
	BucketDescription nvarchar(50) NULL,
	AllowForecasts bit NOT NULL,
 CONSTRAINT PK_tbSystemBucket PRIMARY KEY CLUSTERED 
(
	Period ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbSystemBucketInterval(
	BucketIntervalCode smallint NOT NULL,
	BucketInterval nvarchar(15) NOT NULL,
 CONSTRAINT PK_tbSystemBucketInterval PRIMARY KEY CLUSTERED 
(
	BucketIntervalCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbSystemBucketType(
	BucketTypeCode smallint NOT NULL,
	BucketType nvarchar(25) NOT NULL,
 CONSTRAINT PK_tbSystemBucketType PRIMARY KEY CLUSTERED 
(
	BucketTypeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbSystemCalendar(
	CalendarCode nvarchar(10) NOT NULL,
	Monday bit NOT NULL,
	Tuesday bit NOT NULL,
	Wednesday bit NOT NULL,
	Thursday bit NOT NULL,
	Friday bit NOT NULL,
	Saturday bit NOT NULL,
	Sunday bit NOT NULL,
 CONSTRAINT PK_tbSystemCalendar PRIMARY KEY CLUSTERED 
(
	CalendarCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbSystemCalendarHoliday(
	CalendarCode nvarchar(10) NOT NULL,
	UnavailableOn datetime NOT NULL,
 CONSTRAINT PK_tbSystemCalendarHoliday PRIMARY KEY CLUSTERED 
(
	CalendarCode ASC,
	UnavailableOn ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbSystemCodeExclusion(
	ExcludedTag nvarchar(100) NOT NULL,
 CONSTRAINT PK_tbSystemCodeExclusion PRIMARY KEY CLUSTERED 
(
	ExcludedTag ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbSystemDoc(
	DocTypeCode smallint NOT NULL,
	ReportName nvarchar(50) NOT NULL,
	OpenMode smallint NOT NULL,
	Description nvarchar(50) NOT NULL,
 CONSTRAINT PK_tbSystemDoc PRIMARY KEY CLUSTERED 
(
	DocTypeCode ASC,
	ReportName ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbSystemDocSpool(
	UserName nvarchar(50) NOT NULL,
	DocTypeCode smallint NOT NULL,
	DocumentNumber nvarchar(25) NOT NULL,
	SpooledOn datetime NOT NULL,
 CONSTRAINT PK_tbSystemDocSpool PRIMARY KEY CLUSTERED 
(
	UserName ASC,
	DocTypeCode ASC,
	DocumentNumber ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbSystemDocType(
	DocTypeCode smallint NOT NULL,
	DocType nvarchar(50) NOT NULL,
 CONSTRAINT PK_tbSystemDocType PRIMARY KEY CLUSTERED 
(
	DocTypeCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbSystemInstall(
	InstallId int IDENTITY(1,1) NOT NULL,
	InstalledOn datetime NOT NULL,
	InstalledBy nvarchar(50) NOT NULL,
	DataVersion float NOT NULL,
	CategoryId smallint NOT NULL,
	CategoryTypeCode smallint NOT NULL,
	ReleaseTypeCode smallint NOT NULL,
	Licence binary(50) NULL,
	LicenceType smallint NULL,
 CONSTRAINT PK_tbSystemInstall PRIMARY KEY CLUSTERED 
(
	InstallId ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbSystemMonth(
	MonthNumber smallint NOT NULL,
	MonthName nvarchar(10) NOT NULL,
 CONSTRAINT PK_tbSystemMonth PRIMARY KEY CLUSTERED 
(
	MonthNumber ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbSystemOptions(
	Identifier nvarchar(4) NOT NULL,
	Initialised bit NOT NULL,
	SQLDataVersion real NOT NULL,
	AccountCode nvarchar(10) NOT NULL,
	DefaultPrintMode smallint NOT NULL,
	BucketTypeCode smallint NOT NULL,
	BucketIntervalCode smallint NOT NULL,
	ShowCashGraphs bit NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	NetProfitCode nvarchar(10) NULL,
	NetProfitTaxCode nvarchar(50) NULL,
	ScheduleOps bit NOT NULL,
	TaxHorizon smallint NOT NULL,
 CONSTRAINT PK_tbSystemRoot PRIMARY KEY CLUSTERED 
(
	Identifier ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbSystemRecurrence(
	RecurrenceCode smallint NOT NULL,
	Recurrence nvarchar(20) NOT NULL,
 CONSTRAINT PK_tbSystemRecurrence PRIMARY KEY CLUSTERED 
(
	RecurrenceCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbSystemRegister(
	RegisterName nvarchar(50) NOT NULL,
	NextNumber int NOT NULL,
 CONSTRAINT PK_tbSystemRegister PRIMARY KEY CLUSTERED 
(
	RegisterName ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbSystemTaxCode(
	TaxCode nvarchar(10) NOT NULL,
	TaxRate float NOT NULL,
	TaxDescription nvarchar(50) NOT NULL,
	TaxTypeCode smallint NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
 CONSTRAINT PK_tbSystemVatCode PRIMARY KEY CLUSTERED 
(
	TaxCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbSystemUom(
	UnitOfMeasure nvarchar(15) NOT NULL,
 CONSTRAINT PK_tbSystemUom PRIMARY KEY CLUSTERED 
(
	UnitOfMeasure ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbSystemYear(
	YearNumber smallint NOT NULL,
	StartMonth smallint NOT NULL,
	CashStatusCode smallint NOT NULL,
	Description nvarchar(10) NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
 CONSTRAINT PK_tbSystemYear PRIMARY KEY CLUSTERED 
(
	YearNumber ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbSystemYearPeriod(
	YearNumber smallint NOT NULL,
	StartOn datetime NOT NULL,
	MonthNumber smallint NOT NULL,
	CashStatusCode smallint NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	CorporationTaxRate real NOT NULL,
	TaxAdjustment money NOT NULL,
	VatAdjustment money NOT NULL,
 CONSTRAINT PK_tbSystemYearPeriod PRIMARY KEY CLUSTERED 
(
	YearNumber ASC,
	StartOn ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbTask(
	TaskCode nvarchar(20) NOT NULL,
	UserId nvarchar(10) NOT NULL,
	AccountCode nvarchar(10) NOT NULL,
	TaskTitle nvarchar(100) NULL,
	ContactName nvarchar(100) NULL,
	ActivityCode nvarchar(50) NOT NULL,
	TaskStatusCode smallint NOT NULL,
	ActionById nvarchar(10) NOT NULL,
	ActionOn datetime NOT NULL,
	ActionedOn datetime NULL,
	PaymentOn datetime NOT NULL,
	SecondReference nvarchar(20) NULL,
	TaskNotes ntext NULL,
	Quantity float NOT NULL,
	CashCode nvarchar(50) NULL,
	TaxCode nvarchar(10) NULL,
	UnitCharge float NOT NULL,
	TotalCharge money NOT NULL,
	AddressCodeFrom nvarchar(15) NULL,
	AddressCodeTo nvarchar(15) NULL,
	Printed bit NOT NULL,
	Spooled bit NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
 CONSTRAINT PK_tbTask PRIMARY KEY CLUSTERED 
(
	TaskCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbTaskAttribute(
	TaskCode nvarchar(20) NOT NULL,
	Attribute nvarchar(50) NOT NULL,
	PrintOrder smallint NOT NULL,
	AttributeTypeCode smallint NOT NULL,
	AttributeDescription nvarchar(400) NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
 CONSTRAINT PK_tbTaskAttrib_1 PRIMARY KEY CLUSTERED 
(
	TaskCode ASC,
	Attribute ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbTaskDoc(
	TaskCode nvarchar(20) NOT NULL,
	DocumentName nvarchar(255) NOT NULL,
	DocumentDescription ntext NULL,
	DocumentImage image NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
 CONSTRAINT PK_tbTaskDoc PRIMARY KEY CLUSTERED 
(
	TaskCode ASC,
	DocumentName ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbTaskFlow(
	ParentTaskCode nvarchar(20) NOT NULL,
	StepNumber smallint NOT NULL,
	ChildTaskCode nvarchar(20) NULL,
	UsedOnQuantity float NOT NULL,
	OffsetDays real NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
 CONSTRAINT PK_tbTaskFlow PRIMARY KEY CLUSTERED 
(
	ParentTaskCode ASC,
	StepNumber ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbTaskOp(
	TaskCode nvarchar(20) NOT NULL,
	OperationNumber smallint NOT NULL,
	UserId nvarchar(10) NOT NULL,
	OpTypeCode smallint NOT NULL,
	OpStatusCode smallint NOT NULL,
	Operation nvarchar(50) NOT NULL,
	Note ntext NULL,
	StartOn datetime NOT NULL,
	EndOn datetime NOT NULL,
	Duration float NOT NULL,
	OffsetDays smallint NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
 CONSTRAINT PK_tbTaskOp PRIMARY KEY CLUSTERED 
(
	TaskCode ASC,
	OperationNumber ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbTaskOpStatus(
	OpStatusCode smallint NOT NULL,
	OpStatus nvarchar(50) NOT NULL,
 CONSTRAINT PK_tbTaskOpStatus PRIMARY KEY CLUSTERED 
(
	OpStatusCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbTaskQuote(
	TaskCode nvarchar(20) NOT NULL,
	Quantity float NOT NULL,
	TotalPrice money NOT NULL,
	RunOnQuantity float NOT NULL,
	RunOnPrice money NOT NULL,
	RunBackQuantity float NOT NULL,
	RunBackPrice float NOT NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
 CONSTRAINT PK_tbTaskQuote PRIMARY KEY CLUSTERED 
(
	TaskCode ASC,
	Quantity ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbTaskStatus(
	TaskStatusCode smallint NOT NULL,
	TaskStatus nvarchar(100) NOT NULL,
 CONSTRAINT aaaaatbActivityStatus_PK PRIMARY KEY NONCLUSTERED 
(
	TaskStatusCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbUser(
	UserId nvarchar(10) NOT NULL,
	UserName nvarchar(50) NOT NULL,
	LogonName nvarchar(50) NOT NULL,
	CalendarCode nvarchar(10) NULL,
	PhoneNumber nvarchar(50) NULL,
	MobileNumber nvarchar(50) NULL,
	FaxNumber nvarchar(50) NULL,
	EmailAddress nvarchar(255) NULL,
	Address ntext NULL,
	Administrator bit NOT NULL,
	Avatar image NULL,
	Signature image NULL,
	InsertedBy nvarchar(50) NOT NULL,
	InsertedOn datetime NOT NULL,
	UpdatedBy nvarchar(50) NOT NULL,
	UpdatedOn datetime NOT NULL,
	NextTaskNumber int NOT NULL,
 CONSTRAINT PK_tbUser PRIMARY KEY CLUSTERED 
(
	UserId ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.tbUserMenu(
	UserId nvarchar(10) NOT NULL,
	MenuId smallint NOT NULL,
 CONSTRAINT PK_tbUserMenu PRIMARY KEY CLUSTERED 
(
	UserId ASC,
	MenuId ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE dbo.tbActivity ADD  CONSTRAINT DF_tbActivity_TaskStatusCode  DEFAULT ((1)) FOR TaskStatusCode
GO
ALTER TABLE dbo.tbActivity ADD  CONSTRAINT DF_tbActivity_UnitCharge_1  DEFAULT ((0)) FOR UnitCharge
GO
ALTER TABLE dbo.tbActivity ADD  CONSTRAINT DF_tbActivity_PrintOrder  DEFAULT ((0)) FOR PrintOrder
GO
ALTER TABLE dbo.tbActivity ADD  CONSTRAINT DF_tbActivityCode_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
GO
ALTER TABLE dbo.tbActivity ADD  CONSTRAINT DF_tbActivityCode_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
GO
ALTER TABLE dbo.tbActivity ADD  CONSTRAINT DF_tbActivityCode_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
GO
ALTER TABLE dbo.tbActivity ADD  CONSTRAINT DF_tbActivityCode_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
GO
ALTER TABLE dbo.tbActivityAttribute ADD  CONSTRAINT DF_tbActivityAttribute_OrderBy  DEFAULT ((10)) FOR PrintOrder
GO
ALTER TABLE dbo.tbActivityAttribute ADD  CONSTRAINT DF_tbActivityAttribute_AttributeTypeCode  DEFAULT ((1)) FOR AttributeTypeCode
GO
ALTER TABLE dbo.tbActivityAttribute ADD  CONSTRAINT DF_tbTemplateAttribute_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
GO
ALTER TABLE dbo.tbActivityAttribute ADD  CONSTRAINT DF_tbTemplateAttribute_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
GO
ALTER TABLE dbo.tbActivityAttribute ADD  CONSTRAINT DF_tbTemplateAttribute_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
GO
ALTER TABLE dbo.tbActivityAttribute ADD  CONSTRAINT DF_tbTemplateAttribute_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
GO
ALTER TABLE dbo.tbActivityFlow ADD  CONSTRAINT DF__tbTemplat__JobOr__48CFD27E  DEFAULT ((10)) FOR StepNumber
GO
ALTER TABLE dbo.tbActivityFlow ADD  CONSTRAINT DF__tbTemplat__Offse__49C3F6B7  DEFAULT ((0)) FOR OffsetDays
GO
ALTER TABLE dbo.tbActivityFlow ADD  CONSTRAINT DF_tbActivityCodeFlow_Quantity  DEFAULT ((0)) FOR UsedOnQuantity
GO
ALTER TABLE dbo.tbActivityFlow ADD  CONSTRAINT DF_tbTemplateActivity_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
GO
ALTER TABLE dbo.tbActivityFlow ADD  CONSTRAINT DF_tbTemplateActivity_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
GO
ALTER TABLE dbo.tbActivityFlow ADD  CONSTRAINT DF_tbTemplateActivity_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
GO
ALTER TABLE dbo.tbActivityFlow ADD  CONSTRAINT DF_tbTemplateActivity_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
GO
ALTER TABLE dbo.tbActivityOp ADD  CONSTRAINT DF_tbActivityOp_OperationNumber  DEFAULT ((0)) FOR OperationNumber
GO
ALTER TABLE dbo.tbActivityOp ADD  CONSTRAINT DF_tbActivityOp_OpTypeCode  DEFAULT ((1)) FOR OpTypeCode
GO
ALTER TABLE dbo.tbActivityOp ADD  CONSTRAINT DF_tbActivityOp_Duration  DEFAULT ((0)) FOR Duration
GO
ALTER TABLE dbo.tbActivityOp ADD  CONSTRAINT DF_tbActivityOp_OffsetDays  DEFAULT ((0)) FOR OffsetDays
GO
ALTER TABLE dbo.tbActivityOp ADD  CONSTRAINT DF_tbActivityOp_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
GO
ALTER TABLE dbo.tbActivityOp ADD  CONSTRAINT DF_tbActivityOp_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
GO
ALTER TABLE dbo.tbActivityOp ADD  CONSTRAINT DF_tbActivityOp_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
GO
ALTER TABLE dbo.tbActivityOp ADD  CONSTRAINT DF_tbActivityOp_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
GO
ALTER TABLE dbo.tbCashCategory ADD  CONSTRAINT DF_tbCashCategory_CategoryTypeCode  DEFAULT ((1)) FOR CategoryTypeCode
GO
ALTER TABLE dbo.tbCashCategory ADD  CONSTRAINT DF_tbCashCategory_CashModeCode  DEFAULT ((1)) FOR CashModeCode
GO
ALTER TABLE dbo.tbCashCategory ADD  CONSTRAINT DF_tbCashCategory_CashTypeCode  DEFAULT ((1)) FOR CashTypeCode
GO
ALTER TABLE dbo.tbCashCategory ADD  CONSTRAINT DF_tbCashCategory_DisplayOrder  DEFAULT ((0)) FOR DisplayOrder
GO
ALTER TABLE dbo.tbCashCategory ADD  CONSTRAINT DF_tbCashCategory_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
GO
ALTER TABLE dbo.tbCashCategory ADD  CONSTRAINT DF_tbCashCategory_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
GO
ALTER TABLE dbo.tbCashCategory ADD  CONSTRAINT DF_tbCashCategory_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
GO
ALTER TABLE dbo.tbCashCategory ADD  CONSTRAINT DF_tbCashCategory_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
GO
ALTER TABLE dbo.tbCashCode ADD  CONSTRAINT DF_tbCashCode_OpeningBalance  DEFAULT ((0)) FOR OpeningBalance
GO
ALTER TABLE dbo.tbCashCode ADD  CONSTRAINT DF_tbCashCode_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
GO
ALTER TABLE dbo.tbCashCode ADD  CONSTRAINT DF_tbCashCode_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
GO
ALTER TABLE dbo.tbCashCode ADD  CONSTRAINT DF_tbCashCode_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
GO
ALTER TABLE dbo.tbCashCode ADD  CONSTRAINT DF_tbCashCode_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
GO
ALTER TABLE dbo.tbCashPeriod ADD  CONSTRAINT DF_tbCashPeriod_ForecastValue  DEFAULT ((0)) FOR ForecastValue
GO
ALTER TABLE dbo.tbCashPeriod ADD  CONSTRAINT DF_tbCashPeriod_ForecastTax  DEFAULT ((0)) FOR ForecastTax
GO
ALTER TABLE dbo.tbCashPeriod ADD  CONSTRAINT DF_tbCashPeriod_InvoiceValue  DEFAULT ((0)) FOR InvoiceValue
GO
ALTER TABLE dbo.tbCashPeriod ADD  CONSTRAINT DF_tbCashPeriod_InvoiceTax  DEFAULT ((0)) FOR InvoiceTax
GO
ALTER TABLE dbo.tbCashTaxType ADD  CONSTRAINT DF_tbSystemOptions_MonthNumber  DEFAULT ((1)) FOR MonthNumber
GO
ALTER TABLE dbo.tbCashTaxType ADD  CONSTRAINT DF_tbSystemOptions_Recurrence  DEFAULT ((1)) FOR RecurrenceCode
GO
ALTER TABLE dbo.tbInvoice ADD  CONSTRAINT DF__tbInvoice__Invoi__1273C1CD  DEFAULT (CONVERT(datetime,CONVERT(varchar,getdate(),(1)),(1))) FOR InvoicedOn
GO
ALTER TABLE dbo.tbInvoice ADD  CONSTRAINT DF__tbInvoice__Invoi__1367E606  DEFAULT ((0)) FOR InvoiceValue
GO
ALTER TABLE dbo.tbInvoice ADD  CONSTRAINT DF__tbInvoice__TaxVa__145C0A3F  DEFAULT ((0)) FOR TaxValue
GO
ALTER TABLE dbo.tbInvoice ADD  CONSTRAINT DF__tbInvoice__PaidV__15502E78  DEFAULT ((0)) FOR PaidValue
GO
ALTER TABLE dbo.tbInvoice ADD  CONSTRAINT DF__tbInvoice__PaidT__164452B1  DEFAULT ((0)) FOR PaidTaxValue
GO
ALTER TABLE dbo.tbInvoice ADD  CONSTRAINT DF_tbInvoice_Printed  DEFAULT ((0)) FOR Printed
GO
ALTER TABLE dbo.tbInvoice ADD  CONSTRAINT DF_tbInvoice_Spooled  DEFAULT ((0)) FOR Spooled
GO
ALTER TABLE dbo.tbInvoice ADD  CONSTRAINT DF_tbInvoice_CollectOn  DEFAULT (getdate()) FOR CollectOn
GO
ALTER TABLE dbo.tbInvoiceItem ADD  CONSTRAINT DF_tbInvoiceItem_InvoiceValue  DEFAULT ((0)) FOR InvoiceValue
GO
ALTER TABLE dbo.tbInvoiceItem ADD  CONSTRAINT DF_tbInvoiceItem_TaxValue  DEFAULT ((0)) FOR TaxValue
GO
ALTER TABLE dbo.tbInvoiceItem ADD  CONSTRAINT DF_tbInvoiceItem_PaidValue  DEFAULT ((0)) FOR PaidValue
GO
ALTER TABLE dbo.tbInvoiceItem ADD  CONSTRAINT DF_tbInvoiceItem_PaidTaxValue  DEFAULT ((0)) FOR PaidTaxValue
GO
ALTER TABLE dbo.tbInvoiceTask ADD  CONSTRAINT DF_tbInvoiceTask_Quantity  DEFAULT ((0)) FOR Quantity
GO
ALTER TABLE dbo.tbInvoiceTask ADD  CONSTRAINT DF_tbInvoiceActivity_InvoiceValue  DEFAULT ((0)) FOR InvoiceValue
GO
ALTER TABLE dbo.tbInvoiceTask ADD  CONSTRAINT DF_tbInvoiceActivity_TaxValue  DEFAULT ((0)) FOR TaxValue
GO
ALTER TABLE dbo.tbInvoiceTask ADD  CONSTRAINT DF_tbInvoiceTask_PaidValue  DEFAULT ((0)) FOR PaidValue
GO
ALTER TABLE dbo.tbInvoiceTask ADD  CONSTRAINT DF_tbInvoiceTask_PaidTaxValue  DEFAULT ((0)) FOR PaidTaxValue
GO
ALTER TABLE dbo.tbInvoiceType ADD  CONSTRAINT DF_tbInvoiceType_NextNumber  DEFAULT ((1000)) FOR NextNumber
GO
ALTER TABLE dbo.tbOrg ADD  CONSTRAINT DF__tbOrg__Organisat__7C8480AE  DEFAULT ((1)) FOR OrganisationTypeCode
GO
ALTER TABLE dbo.tbOrg ADD  CONSTRAINT DF__tbOrg__Organisat__7D78A4E7  DEFAULT ((1)) FOR OrganisationStatusCode
GO
ALTER TABLE dbo.tbOrg ADD  CONSTRAINT DF_tbOrg_NumberOfEmployees  DEFAULT ((0)) FOR NumberOfEmployees
GO
ALTER TABLE dbo.tbOrg ADD  CONSTRAINT DF_tbOrg_Turnover  DEFAULT ((0)) FOR Turnover
GO
ALTER TABLE dbo.tbOrg ADD  CONSTRAINT DF_tbOrg_StatementDays  DEFAULT ((90)) FOR StatementDays
GO
ALTER TABLE dbo.tbOrg ADD  CONSTRAINT DF_tbOrg_OpeningBalance  DEFAULT ((0)) FOR OpeningBalance
GO
ALTER TABLE dbo.tbOrg ADD  CONSTRAINT DF_tbOrg_CurrentBalance  DEFAULT ((0)) FOR CurrentBalance
GO
ALTER TABLE dbo.tbOrg ADD  CONSTRAINT DF_tbOrg_ForeignJurisdiction  DEFAULT ((0)) FOR ForeignJurisdiction
GO
ALTER TABLE dbo.tbOrg ADD  CONSTRAINT DF_tbOrg_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
GO
ALTER TABLE dbo.tbOrg ADD  CONSTRAINT DF_tbOrg_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
GO
ALTER TABLE dbo.tbOrg ADD  CONSTRAINT DF_tbOrg_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
GO
ALTER TABLE dbo.tbOrg ADD  CONSTRAINT DF_tbOrg_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
GO
ALTER TABLE dbo.tbOrg ADD  CONSTRAINT DF_tbOrg_PaymentDays  DEFAULT ((0)) FOR PaymentDays
GO
ALTER TABLE dbo.tbOrg ADD  CONSTRAINT DF_tbOrg_PayDaysFromMonthEnd  DEFAULT ((0)) FOR PayDaysFromMonthEnd
GO
ALTER TABLE dbo.tbOrgAccount ADD  CONSTRAINT DF_tbOrgAccount_OpeningBalance  DEFAULT ((0)) FOR OpeningBalance
GO
ALTER TABLE dbo.tbOrgAccount ADD  CONSTRAINT DF_tbOrgAccount_CurrentBalance  DEFAULT ((0)) FOR CurrentBalance
GO
ALTER TABLE dbo.tbOrgAccount ADD  CONSTRAINT DF_tbOrgAccount_AccountClosed  DEFAULT ((0)) FOR AccountClosed
GO
ALTER TABLE dbo.tbOrgAccount ADD  CONSTRAINT DF_tbOrgAccount_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
GO
ALTER TABLE dbo.tbOrgAccount ADD  CONSTRAINT DF_tbOrgAccount_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
GO
ALTER TABLE dbo.tbOrgAccount ADD  CONSTRAINT DF_tbOrgAccount_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
GO
ALTER TABLE dbo.tbOrgAccount ADD  CONSTRAINT DF_tbOrgAccount_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
GO
ALTER TABLE dbo.tbOrgAddress ADD  CONSTRAINT DF_tbOrgAddress_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
GO
ALTER TABLE dbo.tbOrgAddress ADD  CONSTRAINT DF_tbOrgAddress_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
GO
ALTER TABLE dbo.tbOrgAddress ADD  CONSTRAINT DF_tbOrgAddress_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
GO
ALTER TABLE dbo.tbOrgAddress ADD  CONSTRAINT DF_tbOrgAddress_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
GO
ALTER TABLE dbo.tbOrgContact ADD  CONSTRAINT DF_tbOrgContact_OnMailingList  DEFAULT ((1)) FOR OnMailingList
GO
ALTER TABLE dbo.tbOrgContact ADD  CONSTRAINT DF_tbOrgContact_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
GO
ALTER TABLE dbo.tbOrgContact ADD  CONSTRAINT DF_tbOrgContact_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
GO
ALTER TABLE dbo.tbOrgContact ADD  CONSTRAINT DF_tbOrgContact_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
GO
ALTER TABLE dbo.tbOrgContact ADD  CONSTRAINT DF_tbOrgContact_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
GO
ALTER TABLE dbo.tbOrgDoc ADD  CONSTRAINT DF_tbOrgDoc_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
GO
ALTER TABLE dbo.tbOrgDoc ADD  CONSTRAINT DF_tbOrgDoc_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
GO
ALTER TABLE dbo.tbOrgDoc ADD  CONSTRAINT DF_tbOrgDoc_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
GO
ALTER TABLE dbo.tbOrgDoc ADD  CONSTRAINT DF_tbOrgDoc_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
GO
ALTER TABLE dbo.tbOrgPayment ADD  CONSTRAINT DF_tbOrgPayment_PaymentStatusCode  DEFAULT ((1)) FOR PaymentStatusCode
GO
ALTER TABLE dbo.tbOrgPayment ADD  CONSTRAINT DF_tbOrgPayment_PaidOn  DEFAULT (CONVERT(datetime,CONVERT(varchar,getdate(),(1)),(1))) FOR PaidOn
GO
ALTER TABLE dbo.tbOrgPayment ADD  CONSTRAINT DF_tbOrgPayment_PaidValue  DEFAULT ((0)) FOR PaidInValue
GO
ALTER TABLE dbo.tbOrgPayment ADD  CONSTRAINT DF_tbOrgPayment_PaidTaxValue  DEFAULT ((0)) FOR PaidOutValue
GO
ALTER TABLE dbo.tbOrgPayment ADD  CONSTRAINT DF_tbOrgPayment_PaidInValue1  DEFAULT ((0)) FOR TaxInValue
GO
ALTER TABLE dbo.tbOrgPayment ADD  CONSTRAINT DF_tbOrgPayment_PaidOutValue1  DEFAULT ((0)) FOR TaxOutValue
GO
ALTER TABLE dbo.tbOrgPayment ADD  CONSTRAINT DF_tbOrgPayment_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
GO
ALTER TABLE dbo.tbOrgPayment ADD  CONSTRAINT DF_tbOrgPayment_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
GO
ALTER TABLE dbo.tbOrgPayment ADD  CONSTRAINT DF_tbOrgPayment_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
GO
ALTER TABLE dbo.tbOrgPayment ADD  CONSTRAINT DF_tbOrgPayment_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
GO
ALTER TABLE dbo.tbOrgStatus ADD  CONSTRAINT DF__tbOrgStat__Organ__07C12930  DEFAULT ((1)) FOR OrganisationStatusCode
GO
ALTER TABLE dbo.tbOrgType ADD  CONSTRAINT DF__tbOrgType__Organ__3F466844  DEFAULT ((1)) FOR OrganisationTypeCode
GO
ALTER TABLE dbo.tbProfileMenu ADD  CONSTRAINT DF_tbProfileMenu_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
GO
ALTER TABLE dbo.tbProfileMenu ADD  CONSTRAINT DF_tbProfileMenu_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
GO
ALTER TABLE dbo.tbProfileMenuCommand ADD  CONSTRAINT DF_tbProfileMenuCommand_Command  DEFAULT ((0)) FOR Command
GO
ALTER TABLE dbo.tbProfileMenuEntry ADD  CONSTRAINT DF_tbProfileMenuEntry_MenuId  DEFAULT ((0)) FOR MenuId
GO
ALTER TABLE dbo.tbProfileMenuEntry ADD  CONSTRAINT DF_tbProfileMenuEntry_FolderId  DEFAULT ((0)) FOR FolderId
GO
ALTER TABLE dbo.tbProfileMenuEntry ADD  CONSTRAINT DF_tbProfileMenuEntry_ItemId  DEFAULT ((0)) FOR ItemId
GO
ALTER TABLE dbo.tbProfileMenuEntry ADD  CONSTRAINT DF_tbProfileMenuEntry_Command  DEFAULT ((0)) FOR Command
GO
ALTER TABLE dbo.tbProfileMenuEntry ADD  CONSTRAINT DF_tbProfileMenuEntry_OpenMode  DEFAULT ((1)) FOR OpenMode
GO
ALTER TABLE dbo.tbProfileMenuEntry ADD  CONSTRAINT DF_tbProfileMenuEntry_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
GO
ALTER TABLE dbo.tbProfileMenuEntry ADD  CONSTRAINT DF_tbProfileMenuEntry_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
GO
ALTER TABLE dbo.tbProfileMenuEntry ADD  CONSTRAINT DF_tbProfileMenuEntry_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
GO
ALTER TABLE dbo.tbProfileMenuOpenMode ADD  CONSTRAINT DF_tbProfileMenuOpenMode_OpenMode  DEFAULT ((0)) FOR OpenMode
GO
ALTER TABLE dbo.tbSystemCalendar ADD  CONSTRAINT DF_tbSystemCalendar_Monday  DEFAULT ((1)) FOR Monday
GO
ALTER TABLE dbo.tbSystemCalendar ADD  CONSTRAINT DF_tbSystemCalendar_Tuesday  DEFAULT ((1)) FOR Tuesday
GO
ALTER TABLE dbo.tbSystemCalendar ADD  CONSTRAINT DF_tbSystemCalendar_Wednesday  DEFAULT ((1)) FOR Wednesday
GO
ALTER TABLE dbo.tbSystemCalendar ADD  CONSTRAINT DF_tbSystemCalendar_Thursday  DEFAULT ((1)) FOR Thursday
GO
ALTER TABLE dbo.tbSystemCalendar ADD  CONSTRAINT DF_tbSystemCalendar_Friday  DEFAULT ((1)) FOR Friday
GO
ALTER TABLE dbo.tbSystemCalendar ADD  CONSTRAINT DF_tbSystemCalendar_Saturday  DEFAULT ((0)) FOR Saturday
GO
ALTER TABLE dbo.tbSystemCalendar ADD  CONSTRAINT DF_tbSystemCalendar_Sunday  DEFAULT ((0)) FOR Sunday
GO
ALTER TABLE dbo.tbSystemDoc ADD  CONSTRAINT DF_tbSystemDoc_OpenMode  DEFAULT ((1)) FOR OpenMode
GO
ALTER TABLE dbo.tbSystemDocSpool ADD  CONSTRAINT DF_tbSystemDocSpool_UserName  DEFAULT (suser_sname()) FOR UserName
GO
ALTER TABLE dbo.tbSystemDocSpool ADD  CONSTRAINT DF_tbSystemDocSpool_DocTypeCode  DEFAULT ((1)) FOR DocTypeCode
GO
ALTER TABLE dbo.tbSystemDocSpool ADD  CONSTRAINT DF_tbSystemDocSpool_SpooledOn  DEFAULT (getdate()) FOR SpooledOn
GO
ALTER TABLE dbo.tbSystemInstall ADD  CONSTRAINT DF_tbSystemInstall_InstalledOn  DEFAULT (getdate()) FOR InstalledOn
GO
ALTER TABLE dbo.tbSystemInstall ADD  CONSTRAINT DF_tbSystemInstall_InstalledBy  DEFAULT (suser_sname()) FOR InstalledBy
GO
ALTER TABLE dbo.tbSystemInstall ADD  CONSTRAINT DF_tbSystemInstall_CategoryId  DEFAULT ((0)) FOR CategoryId
GO
ALTER TABLE dbo.tbSystemOptions ADD  CONSTRAINT DF_tbSystemRoot_Initialised  DEFAULT ((0)) FOR Initialised
GO
ALTER TABLE dbo.tbSystemOptions ADD  CONSTRAINT DF_tbSystemRoot_SQLDataVersion  DEFAULT ((1)) FOR SQLDataVersion
GO
ALTER TABLE dbo.tbSystemOptions ADD  CONSTRAINT DF_tbSystemRoot_DefaultPrintMode  DEFAULT ((2)) FOR DefaultPrintMode
GO
ALTER TABLE dbo.tbSystemOptions ADD  CONSTRAINT DF_tbSystemOptions_BucketTypeCode  DEFAULT ((1)) FOR BucketTypeCode
GO
ALTER TABLE dbo.tbSystemOptions ADD  CONSTRAINT DF_tbSystemOptions_BucketIntervalCode  DEFAULT ((1)) FOR BucketIntervalCode
GO
ALTER TABLE dbo.tbSystemOptions ADD  CONSTRAINT DF_tbSystemOptions_ShowCashGraphs  DEFAULT ((1)) FOR ShowCashGraphs
GO
ALTER TABLE dbo.tbSystemOptions ADD  CONSTRAINT DF_tbSystemOptions_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
GO
ALTER TABLE dbo.tbSystemOptions ADD  CONSTRAINT DF_tbSystemOptions_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
GO
ALTER TABLE dbo.tbSystemOptions ADD  CONSTRAINT DF_tbSystemOptions_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
GO
ALTER TABLE dbo.tbSystemOptions ADD  CONSTRAINT DF_tbSystemOptions_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
GO
ALTER TABLE dbo.tbSystemOptions ADD  CONSTRAINT DF_tbSystemOptions_ScheduleOps  DEFAULT ((1)) FOR ScheduleOps
GO
ALTER TABLE dbo.tbSystemOptions ADD  CONSTRAINT DF_tbSystemOptions_TaxHorizon  DEFAULT ((90)) FOR TaxHorizon
GO
ALTER TABLE dbo.tbSystemRegister ADD  CONSTRAINT DF_tbSystemRegister_NextNumber  DEFAULT ((1)) FOR NextNumber
GO
ALTER TABLE dbo.tbSystemTaxCode ADD  CONSTRAINT DF_tbSystemVatCode_VatRate  DEFAULT ((0)) FOR TaxRate
GO
ALTER TABLE dbo.tbSystemTaxCode ADD  CONSTRAINT DF_tbSystemTaxCode_TaxTypeCode  DEFAULT ((2)) FOR TaxTypeCode
GO
ALTER TABLE dbo.tbSystemTaxCode ADD  CONSTRAINT DF_tbSystemTaxCode_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
GO
ALTER TABLE dbo.tbSystemTaxCode ADD  CONSTRAINT DF_tbSystemTaxCode_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
GO
ALTER TABLE dbo.tbSystemYear ADD  CONSTRAINT DF_tbSystemYear_StartMonth  DEFAULT ((1)) FOR StartMonth
GO
ALTER TABLE dbo.tbSystemYear ADD  CONSTRAINT DF_tbSystemYear_CashStatusCode  DEFAULT ((1)) FOR CashStatusCode
GO
ALTER TABLE dbo.tbSystemYear ADD  CONSTRAINT DF_tbSystemYear_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
GO
ALTER TABLE dbo.tbSystemYear ADD  CONSTRAINT DF_tbSystemYear_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
GO
ALTER TABLE dbo.tbSystemYearPeriod ADD  CONSTRAINT DF_tbSystemYearPeriod_CashStatusCode  DEFAULT ((1)) FOR CashStatusCode
GO
ALTER TABLE dbo.tbSystemYearPeriod ADD  CONSTRAINT DF_tbSystemYearPeriod_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
GO
ALTER TABLE dbo.tbSystemYearPeriod ADD  CONSTRAINT DF_tbSystemYearPeriod_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
GO
ALTER TABLE dbo.tbSystemYearPeriod ADD  CONSTRAINT DF_tbSystemYearPeriod_CorporationTaxRate  DEFAULT ((0)) FOR CorporationTaxRate
GO
ALTER TABLE dbo.tbSystemYearPeriod ADD  CONSTRAINT DF_tbSystemYearPeriod_TaxAdjustment  DEFAULT ((0)) FOR TaxAdjustment
GO
ALTER TABLE dbo.tbSystemYearPeriod ADD  CONSTRAINT DF_tbSystemYearPeriod_VatAdjustment  DEFAULT ((0)) FOR VatAdjustment
GO
ALTER TABLE dbo.tbTask ADD  CONSTRAINT DF__tbActivit__Actio__1FCDBCEB  DEFAULT (getdate()) FOR ActionOn
GO
ALTER TABLE dbo.tbTask ADD  CONSTRAINT DF_tbTask_PaymentOn  DEFAULT (getdate()) FOR PaymentOn
GO
ALTER TABLE dbo.tbTask ADD  CONSTRAINT DF_tbActivity_Quantity  DEFAULT ((0)) FOR Quantity
GO
ALTER TABLE dbo.tbTask ADD  CONSTRAINT DF_tbTask_UnitCharge  DEFAULT ((0)) FOR UnitCharge
GO
ALTER TABLE dbo.tbTask ADD  CONSTRAINT DF_tbTask_TotalCharge  DEFAULT ((0)) FOR TotalCharge
GO
ALTER TABLE dbo.tbTask ADD  CONSTRAINT DF_tbTask_Printed  DEFAULT ((0)) FOR Printed
GO
ALTER TABLE dbo.tbTask ADD  CONSTRAINT DF_tbTask_Spooled  DEFAULT ((0)) FOR Spooled
GO
ALTER TABLE dbo.tbTask ADD  CONSTRAINT DF_tbTask_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
GO
ALTER TABLE dbo.tbTask ADD  CONSTRAINT DF_tbTask_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
GO
ALTER TABLE dbo.tbTask ADD  CONSTRAINT DF_tbTask_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
GO
ALTER TABLE dbo.tbTask ADD  CONSTRAINT DF_tbTask_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
GO
ALTER TABLE dbo.tbTaskAttribute ADD  CONSTRAINT DF_tbTaskAttribute_OrderBy  DEFAULT ((10)) FOR PrintOrder
GO
ALTER TABLE dbo.tbTaskAttribute ADD  CONSTRAINT DF_tbTaskAttribute_AttributeTypeCode  DEFAULT ((1)) FOR AttributeTypeCode
GO
ALTER TABLE dbo.tbTaskAttribute ADD  CONSTRAINT DF_tbJobAttribute_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
GO
ALTER TABLE dbo.tbTaskAttribute ADD  CONSTRAINT DF_tbJobAttribute_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
GO
ALTER TABLE dbo.tbTaskAttribute ADD  CONSTRAINT DF_tbJobAttribute_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
GO
ALTER TABLE dbo.tbTaskAttribute ADD  CONSTRAINT DF_tbJobAttribute_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
GO
ALTER TABLE dbo.tbTaskDoc ADD  CONSTRAINT DF_tbActivityDoc_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
GO
ALTER TABLE dbo.tbTaskDoc ADD  CONSTRAINT DF_tbActivityDoc_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
GO
ALTER TABLE dbo.tbTaskDoc ADD  CONSTRAINT DF_tbActivityDoc_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
GO
ALTER TABLE dbo.tbTaskDoc ADD  CONSTRAINT DF_tbActivityDoc_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
GO
ALTER TABLE dbo.tbTaskFlow ADD  CONSTRAINT DF_tbTaskFlow_StepNumber  DEFAULT ((10)) FOR StepNumber
GO
ALTER TABLE dbo.tbTaskFlow ADD  CONSTRAINT DF_tbTaskFlow_UsedOnQuantity  DEFAULT ((1)) FOR UsedOnQuantity
GO
ALTER TABLE dbo.tbTaskFlow ADD  CONSTRAINT DF_tbTaskFlow_OffsetDays  DEFAULT ((0)) FOR OffsetDays
GO
ALTER TABLE dbo.tbTaskFlow ADD  CONSTRAINT DF_tbTaskFlow_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
GO
ALTER TABLE dbo.tbTaskFlow ADD  CONSTRAINT DF_tbTaskFlow_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
GO
ALTER TABLE dbo.tbTaskFlow ADD  CONSTRAINT DF_tbTaskFlow_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
GO
ALTER TABLE dbo.tbTaskFlow ADD  CONSTRAINT DF_tbTaskFlow_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
GO
ALTER TABLE dbo.tbTaskOp ADD  CONSTRAINT DF_tbTaskOp_OperationNumber  DEFAULT ((0)) FOR OperationNumber
GO
ALTER TABLE dbo.tbTaskOp ADD  CONSTRAINT DF_tbTaskOp_OpTypeCode  DEFAULT ((1)) FOR OpTypeCode
GO
ALTER TABLE dbo.tbTaskOp ADD  CONSTRAINT DF_tbTaskOp_OpStatusCode  DEFAULT ((1)) FOR OpStatusCode
GO
ALTER TABLE dbo.tbTaskOp ADD  CONSTRAINT DF_tbTaskOp_StartOn  DEFAULT (getdate()) FOR StartOn
GO
ALTER TABLE dbo.tbTaskOp ADD  CONSTRAINT DF_tbTaskOp_EndOn  DEFAULT (getdate()) FOR EndOn
GO
ALTER TABLE dbo.tbTaskOp ADD  CONSTRAINT DF_tbTaskOp_Duration  DEFAULT ((0)) FOR Duration
GO
ALTER TABLE dbo.tbTaskOp ADD  CONSTRAINT DF_tbTaskOp_OffsetDays  DEFAULT ((0)) FOR OffsetDays
GO
ALTER TABLE dbo.tbTaskOp ADD  CONSTRAINT DF_tbTaskOp_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
GO
ALTER TABLE dbo.tbTaskOp ADD  CONSTRAINT DF_tbTaskOp_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
GO
ALTER TABLE dbo.tbTaskOp ADD  CONSTRAINT DF_tbTaskOp_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
GO
ALTER TABLE dbo.tbTaskOp ADD  CONSTRAINT DF_tbTaskOp_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
GO
ALTER TABLE dbo.tbTaskQuote ADD  CONSTRAINT DF_tbTaskQuote_Quantity  DEFAULT ((0)) FOR Quantity
GO
ALTER TABLE dbo.tbTaskQuote ADD  CONSTRAINT DF_tbTaskQuote_TotalPrice  DEFAULT ((0)) FOR TotalPrice
GO
ALTER TABLE dbo.tbTaskQuote ADD  CONSTRAINT DF_tbTaskQuote_RunOnQuantity  DEFAULT ((0)) FOR RunOnQuantity
GO
ALTER TABLE dbo.tbTaskQuote ADD  CONSTRAINT DF_tbTaskQuote_RunOnPrice  DEFAULT ((0)) FOR RunOnPrice
GO
ALTER TABLE dbo.tbTaskQuote ADD  CONSTRAINT DF_tbTaskQuote_RunBackQuantity  DEFAULT ((0)) FOR RunBackQuantity
GO
ALTER TABLE dbo.tbTaskQuote ADD  CONSTRAINT DF_tbTaskQuote_RunBackPrice  DEFAULT ((0)) FOR RunBackPrice
GO
ALTER TABLE dbo.tbTaskQuote ADD  CONSTRAINT DF_tbTaskQuote_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
GO
ALTER TABLE dbo.tbTaskQuote ADD  CONSTRAINT DF_tbTaskQuote_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
GO
ALTER TABLE dbo.tbTaskQuote ADD  CONSTRAINT DF_tbTaskQuote_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
GO
ALTER TABLE dbo.tbTaskQuote ADD  CONSTRAINT DF_tbTaskQuote_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
GO
ALTER TABLE dbo.tbUser ADD  CONSTRAINT DF_tbUser_LogonName  DEFAULT (suser_sname()) FOR LogonName
GO
ALTER TABLE dbo.tbUser ADD  CONSTRAINT DF_tbUser_Administrator  DEFAULT ((0)) FOR Administrator
GO
ALTER TABLE dbo.tbUser ADD  CONSTRAINT DF_tbUser_InsertedBy  DEFAULT (suser_sname()) FOR InsertedBy
GO
ALTER TABLE dbo.tbUser ADD  CONSTRAINT DF_tbUser_InsertedOn  DEFAULT (getdate()) FOR InsertedOn
GO
ALTER TABLE dbo.tbUser ADD  CONSTRAINT DF_tbUser_UpdatedBy  DEFAULT (suser_sname()) FOR UpdatedBy
GO
ALTER TABLE dbo.tbUser ADD  CONSTRAINT DF_tbUser_UpdatedOn  DEFAULT (getdate()) FOR UpdatedOn
GO
ALTER TABLE dbo.tbUser ADD  CONSTRAINT DF_tbUser_NextTaskNumber  DEFAULT ((1)) FOR NextTaskNumber
GO
