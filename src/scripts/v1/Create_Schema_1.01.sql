/************************************************************
* Tru-Man Trade Control: Information and Cash System
* Copyright Tru-Man Industries Ltd 2008. All Rights Reserved.
* Author: Ian Monnox
* Description: Sql Server Creation Script - Encrypted Distribution Schema
* Data Version: 1.01
* Release Date: 19.03.08
************************************************************/

CREATE TABLE [dbo].[tbActivity] (
	[ActivityCode] [nvarchar] (50) NOT NULL ,
	[TaskStatusCode] [smallint] NOT NULL ,
	[DefaultText] [ntext] NULL ,
	[UnitOfMeasure] [nvarchar] (15) NOT NULL ,
	[CashCode] [nvarchar] (50) NULL ,
	[UnitCharge] [money] NOT NULL ,
	[PrintOrder] [bit] NOT NULL ,
	[InsertedBy] [nvarchar] (50) NOT NULL ,
	[InsertedOn] [datetime] NOT NULL ,
	[UpdatedBy] [nvarchar] (50) NOT NULL ,
	[UpdatedOn] [datetime] NOT NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbActivityAttribute] (
	[ActivityCode] [nvarchar] (50) NOT NULL ,
	[Attribute] [nvarchar] (50) NOT NULL ,
	[PrintOrder] [smallint] NOT NULL ,
	[AttributeTypeCode] [smallint] NOT NULL ,
	[DefaultText] [nvarchar] (255) NULL ,
	[InsertedBy] [nvarchar] (50) NOT NULL ,
	[InsertedOn] [datetime] NOT NULL ,
	[UpdatedBy] [nvarchar] (50) NOT NULL ,
	[UpdatedOn] [datetime] NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbActivityAttributeType] (
	[AttributeTypeCode] [smallint] NOT NULL ,
	[AttributeType] [nvarchar] (20) NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbActivityFlow] (
	[ParentCode] [nvarchar] (50) NOT NULL ,
	[StepNumber] [smallint] NOT NULL ,
	[ChildCode] [nvarchar] (50) NOT NULL ,
	[OffsetDays] [smallint] NOT NULL ,
	[UsedOnQuantity] [float] NOT NULL ,
	[InsertedBy] [nvarchar] (50) NOT NULL ,
	[InsertedOn] [datetime] NOT NULL ,
	[UpdatedBy] [nvarchar] (50) NOT NULL ,
	[UpdatedOn] [datetime] NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbCashCategory] (
	[CategoryCode] [nvarchar] (10) NOT NULL ,
	[Category] [nvarchar] (50) NOT NULL ,
	[CategoryTypeCode] [smallint] NOT NULL ,
	[CashModeCode] [smallint] NULL ,
	[CashTypeCode] [smallint] NULL ,
	[DisplayOrder] [smallint] NOT NULL ,
	[ManualForecast] [bit] NOT NULL ,
	[InsertedBy] [nvarchar] (50) NOT NULL ,
	[InsertedOn] [datetime] NOT NULL ,
	[UpdatedBy] [nvarchar] (50) NOT NULL ,
	[UpdatedOn] [datetime] NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbCashCategoryExp] (
	[CategoryCode] [nvarchar] (10) NOT NULL ,
	[Expression] [nvarchar] (256) NOT NULL ,
	[Format] [nvarchar] (100) NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbCashCategoryTotal] (
	[ParentCode] [nvarchar] (10) NOT NULL ,
	[ChildCode] [nvarchar] (10) NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbCashCategoryType] (
	[CategoryTypeCode] [smallint] NOT NULL ,
	[CategoryType] [nvarchar] (20) NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbCashCode] (
	[CashCode] [nvarchar] (50) NOT NULL ,
	[CashDescription] [nvarchar] (100) NOT NULL ,
	[CategoryCode] [nvarchar] (10) NOT NULL ,
	[TaxCode] [nvarchar] (10) NOT NULL ,
	[OpeningBalance] [money] NOT NULL ,
	[InsertedBy] [nvarchar] (50) NOT NULL ,
	[InsertedOn] [datetime] NOT NULL ,
	[UpdatedBy] [nvarchar] (50) NOT NULL ,
	[UpdatedOn] [datetime] NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbCashMode] (
	[CashModeCode] [smallint] NOT NULL ,
	[CashMode] [nvarchar] (10) NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbCashPeriod] (
	[CashCode] [nvarchar] (50) NOT NULL ,
	[StartOn] [datetime] NOT NULL ,
	[ForecastValue] [money] NOT NULL ,
	[ForecastTax] [money] NOT NULL ,
	[CashValue] [money] NOT NULL ,
	[CashTax] [money] NOT NULL ,
	[InvoiceValue] [money] NOT NULL ,
	[InvoiceTax] [money] NOT NULL ,
	[Note] [ntext] NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbCashStatus] (
	[CashStatusCode] [smallint] NOT NULL ,
	[CashStatus] [nvarchar] (15) NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbCashTaxType] (
	[TaxTypeCode] [smallint] NOT NULL ,
	[TaxType] [nvarchar] (20) NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbCashType] (
	[CashTypeCode] [smallint] NOT NULL ,
	[CashType] [nvarchar] (25) NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbInvoice] (
	[InvoiceNumber] [nvarchar] (20) NOT NULL ,
	[UserId] [smallint] NOT NULL ,
	[AccountCode] [nvarchar] (10) NOT NULL ,
	[InvoiceTypeCode] [smallint] NOT NULL ,
	[InvoiceStatusCode] [smallint] NOT NULL ,
	[InvoicedOn] [datetime] NOT NULL ,
	[InvoiceValue] [money] NOT NULL ,
	[TaxValue] [money] NOT NULL ,
	[PaidValue] [money] NOT NULL ,
	[PaidTaxValue] [money] NOT NULL ,
	[PaymentTerms] [nvarchar] (100) NULL ,
	[Notes] [ntext] NULL ,
	[Printed] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbInvoiceItem] (
	[InvoiceNumber] [nvarchar] (20) NOT NULL ,
	[CashCode] [nvarchar] (50) NOT NULL ,
	[TaxCode] [nvarchar] (10) NULL ,
	[InvoiceValue] [money] NOT NULL ,
	[TaxValue] [money] NOT NULL ,
	[PaidValue] [money] NOT NULL ,
	[PaidTaxValue] [money] NOT NULL ,
	[ItemReference] [ntext] NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbInvoiceStatus] (
	[InvoiceStatusCode] [smallint] NOT NULL ,
	[InvoiceStatus] [nvarchar] (50) NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbInvoiceTask] (
	[InvoiceNumber] [nvarchar] (20) NOT NULL ,
	[TaskCode] [nvarchar] (20) NOT NULL ,
	[Quantity] [float] NOT NULL ,
	[InvoiceValue] [money] NOT NULL ,
	[TaxValue] [money] NOT NULL ,
	[PaidValue] [money] NOT NULL ,
	[PaidTaxValue] [money] NOT NULL ,
	[CashCode] [nvarchar] (50) NOT NULL ,
	[TaxCode] [nvarchar] (10) NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbInvoiceType] (
	[InvoiceTypeCode] [smallint] NOT NULL ,
	[InvoiceType] [nvarchar] (20) NOT NULL ,
	[CashModeCode] [smallint] NOT NULL ,
	[NextNumber] [int] NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbOrg] (
	[AccountCode] [nvarchar] (10) NOT NULL ,
	[AccountName] [nvarchar] (255) NOT NULL ,
	[OrganisationTypeCode] [smallint] NOT NULL ,
	[OrganisationStatusCode] [smallint] NOT NULL ,
	[TaxCode] [nvarchar] (10) NULL ,
	[AddressCode] [nvarchar] (15) NULL ,
	[AreaCode] [nvarchar] (50) NULL ,
	[PhoneNumber] [nvarchar] (50) NULL ,
	[FaxNumber] [nvarchar] (50) NULL ,
	[EmailAddress] [nvarchar] (255) NULL ,
	[WebSite] [nvarchar] (255) NULL ,
	[IndustrySector] [nvarchar] (255) NULL ,
	[AccountSource] [nvarchar] (100) NULL ,
	[PaymentTerms] [nvarchar] (100) NULL ,
	[NumberOfEmployees] [int] NOT NULL ,
	[CompanyNumber] [nvarchar] (20) NULL ,
	[VatNumber] [nvarchar] (50) NULL ,
	[Turnover] [money] NOT NULL ,
	[StatementDays] [smallint] NOT NULL ,
	[OpeningBalance] [money] NOT NULL ,
	[CurrentBalance] [money] NOT NULL ,
	[ForeignJurisdiction] [bit] NOT NULL ,
	[BusinessDescription] [ntext] NULL ,
	[Logo] [image] NULL ,
	[InsertedBy] [nvarchar] (50) NOT NULL ,
	[InsertedOn] [datetime] NOT NULL ,
	[UpdatedBy] [nvarchar] (50) NOT NULL ,
	[UpdatedOn] [datetime] NOT NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbOrgAccount] (
	[CashAccountCode] [nvarchar] (10) NOT NULL ,
	[AccountCode] [nvarchar] (10) NOT NULL ,
	[CashAccountName] [nvarchar] (50) NOT NULL ,
	[OpeningBalance] [money] NOT NULL ,
	[CurrentBalance] [money] NOT NULL ,
	[SortCode] [nvarchar] (10) NULL ,
	[AccountNumber] [nvarchar] (20) NULL ,
	[CashCode] [nvarchar] (50) NULL ,
	[AccountClosed] [bit] NOT NULL ,
	[InsertedBy] [nvarchar] (50) NOT NULL ,
	[InsertedOn] [datetime] NOT NULL ,
	[UpdatedBy] [nvarchar] (50) NOT NULL ,
	[UpdatedOn] [datetime] NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbOrgAddress] (
	[AddressCode] [nvarchar] (15) NOT NULL ,
	[AccountCode] [nvarchar] (10) NOT NULL ,
	[Address] [ntext] NOT NULL ,
	[InsertedBy] [nvarchar] (50) NOT NULL ,
	[InsertedOn] [datetime] NOT NULL ,
	[UpdatedBy] [nvarchar] (50) NOT NULL ,
	[UpdatedOn] [datetime] NOT NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbOrgContact] (
	[AccountCode] [nvarchar] (10) NOT NULL ,
	[ContactName] [nvarchar] (100) NOT NULL ,
	[FileAs] [nvarchar] (100) NULL ,
	[OnMailingList] [bit] NOT NULL ,
	[NameTitle] [nvarchar] (25) NULL ,
	[NickName] [nvarchar] (100) NULL ,
	[JobTitle] [nvarchar] (100) NULL ,
	[PhoneNumber] [nvarchar] (50) NULL ,
	[MobileNumber] [nvarchar] (50) NULL ,
	[FaxNumber] [nvarchar] (50) NULL ,
	[EmailAddress] [nvarchar] (255) NULL ,
	[Hobby] [nvarchar] (50) NULL ,
	[DateOfBirth] [datetime] NULL ,
	[Department] [nvarchar] (50) NULL ,
	[SpouseName] [nvarchar] (50) NULL ,
	[Information] [ntext] NULL ,
	[Photo] [image] NULL ,
	[InsertedBy] [nvarchar] (50) NOT NULL ,
	[InsertedOn] [datetime] NOT NULL ,
	[UpdatedBy] [nvarchar] (50) NOT NULL ,
	[UpdatedOn] [datetime] NOT NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbOrgDoc] (
	[AccountCode] [nvarchar] (10) NOT NULL ,
	[DocumentName] [nvarchar] (255) NOT NULL ,
	[DocumentDescription] [ntext] NULL ,
	[DocumentImage] [image] NULL ,
	[InsertedBy] [nvarchar] (50) NOT NULL ,
	[InsertedOn] [datetime] NOT NULL ,
	[UpdatedBy] [nvarchar] (50) NOT NULL ,
	[UpdatedOn] [datetime] NOT NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbOrgPayment] (
	[PaymentCode] [nvarchar] (20) NOT NULL ,
	[UserId] [smallint] NOT NULL ,
	[PaymentStatusCode] [smallint] NOT NULL ,
	[AccountCode] [nvarchar] (10) NOT NULL ,
	[CashAccountCode] [nvarchar] (10) NOT NULL ,
	[CashCode] [nvarchar] (50) NULL ,
	[TaxCode] [nvarchar] (10) NULL ,
	[PaidOn] [datetime] NOT NULL ,
	[PaidInValue] [money] NOT NULL ,
	[PaidOutValue] [money] NOT NULL ,
	[TaxInValue] [money] NOT NULL ,
	[TaxOutValue] [money] NOT NULL ,
	[PaymentReference] [nvarchar] (50) NULL ,
	[InsertedBy] [nvarchar] (50) NOT NULL ,
	[InsertedOn] [datetime] NOT NULL ,
	[UpdatedBy] [nvarchar] (50) NOT NULL ,
	[UpdatedOn] [datetime] NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbOrgPaymentStatus] (
	[PaymentStatusCode] [smallint] NOT NULL ,
	[PaymentStatus] [nvarchar] (20) NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbOrgStatus] (
	[OrganisationStatusCode] [smallint] NOT NULL ,
	[OrganisationStatus] [nvarchar] (255) NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbOrgType] (
	[OrganisationTypeCode] [smallint] NOT NULL ,
	[CashModeCode] [smallint] NOT NULL ,
	[OrganisationType] [nvarchar] (50) NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbProfileCustom] (
	[SectionCode] [nvarchar] (20) NOT NULL ,
	[SectionContent] [nvarchar] (255) NULL ,
	[ValidateClient] [bit] NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbProfileItemType] (
	[ItemTypeCode] [smallint] NOT NULL ,
	[ItemType] [nvarchar] (50) NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbProfileLink] (
	[LinkName] [nvarchar] (100) NOT NULL ,
	[SqlView] [nvarchar] (50) NULL ,
	[SqlIndex] [nvarchar] (150) NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbProfileMenu] (
	[MenuId] [smallint] IDENTITY (1, 1) NOT NULL ,
	[MenuName] [nvarchar] (50) NOT NULL ,
	[InsertedOn] [datetime] NOT NULL ,
	[InsertedBy] [nvarchar] (50) NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbProfileMenuCommand] (
	[Command] [smallint] NOT NULL ,
	[CommandText] [nvarchar] (50) NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbProfileMenuEntry] (
	[MenuId] [smallint] NOT NULL ,
	[EntryId] [int] IDENTITY (1, 1) NOT NULL ,
	[FolderId] [smallint] NOT NULL ,
	[ItemId] [smallint] NOT NULL ,
	[ItemText] [nvarchar] (255) NULL ,
	[Command] [smallint] NULL ,
	[ProjectName] [nvarchar] (50) NULL ,
	[Argument] [nvarchar] (50) NULL ,
	[OpenMode] [smallint] NULL ,
	[UpdatedOn] [datetime] NOT NULL ,
	[InsertedOn] [datetime] NOT NULL ,
	[UpdatedBy] [nvarchar] (50) NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbProfileMenuOpenMode] (
	[OpenMode] [smallint] NOT NULL ,
	[OpenModeDescription] [nvarchar] (20) NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbProfileObject] (
	[ObjectTypeCode] [smallint] NOT NULL ,
	[ObjectName] [nvarchar] (50) NOT NULL ,
	[ProjectName] [nvarchar] (50) NULL ,
	[Caption] [ntext] NULL ,
	[SubObject] [bit] NOT NULL ,
	[UpdatedOn] [datetime] NOT NULL ,
	[InsertedOn] [datetime] NOT NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbProfileObjectDetail] (
	[ObjectTypeCode] [smallint] NOT NULL ,
	[ObjectName] [nvarchar] (50) NOT NULL ,
	[ItemName] [nvarchar] (100) NOT NULL ,
	[ItemTypeCode] [smallint] NULL ,
	[Caption] [ntext] NULL ,
	[StatusBarText] [ntext] NULL ,
	[ControlTipText] [ntext] NULL ,
	[CharLength] [int] NOT NULL ,
	[Visible] [bit] NOT NULL ,
	[FormatString] [nvarchar] (20) NULL ,
	[UpdatedOn] [datetime] NOT NULL ,
	[InsertedOn] [datetime] NOT NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbProfileObjectType] (
	[ObjectTypeCode] [smallint] NOT NULL ,
	[ObjectType] [nvarchar] (50) NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbProfileText] (
	[TextId] [int] NOT NULL ,
	[Message] [ntext] NOT NULL ,
	[Arguments] [smallint] NOT NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbSystemBucket] (
	[Period] [smallint] NOT NULL ,
	[BucketId] [nvarchar] (10) NOT NULL ,
	[BucketDescription] [nvarchar] (50) NULL ,
	[AllowForecasts] [bit] NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbSystemBucketInterval] (
	[BucketIntervalCode] [smallint] NOT NULL ,
	[BucketInterval] [nvarchar] (15) NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbSystemBucketType] (
	[BucketTypeCode] [smallint] NOT NULL ,
	[BucketType] [nvarchar] (25) NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbSystemCalendar] (
	[CalendarCode] [nvarchar] (10) NOT NULL ,
	[Monday] [bit] NOT NULL ,
	[Tuesday] [bit] NOT NULL ,
	[Wednesday] [bit] NOT NULL ,
	[Thursday] [bit] NOT NULL ,
	[Friday] [bit] NOT NULL ,
	[Saturday] [bit] NOT NULL ,
	[Sunday] [bit] NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbSystemCalendarHoliday] (
	[CalendarCode] [nvarchar] (10) NOT NULL ,
	[UnavailableOn] [datetime] NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbSystemCodeExclusion] (
	[ExcludedTag] [nvarchar] (100) NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbSystemDoc] (
	[DocTypeCode] [smallint] NOT NULL ,
	[ReportName] [nvarchar] (50) NOT NULL ,
	[OpenMode] [smallint] NOT NULL ,
	[Description] [nvarchar] (50) NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbSystemDocType] (
	[DocTypeCode] [smallint] NOT NULL ,
	[DocType] [nvarchar] (50) NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbSystemInstall] (
	[InstallId] [int] IDENTITY (1, 1) NOT NULL ,
	[InstalledOn] [datetime] NOT NULL ,
	[InstalledBy] [nvarchar] (50) NOT NULL ,
	[DataVersion] [float] NOT NULL ,
	[CategoryId] [smallint] NOT NULL ,
	[CategoryTypeCode] [smallint] NOT NULL ,
	[ReleaseTypeCode] [smallint] NOT NULL ,
	[Licence] [binary] (50) NULL ,
	[LicenceType] [smallint] NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbSystemMonth] (
	[MonthNumber] [smallint] NOT NULL ,
	[MonthName] [nvarchar] (10) NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbSystemOptions] (
	[Identifier] [nvarchar] (4) NOT NULL ,
	[Initialised] [bit] NOT NULL ,
	[SQLDataVersion] [real] NOT NULL ,
	[AccountCode] [nvarchar] (10) NOT NULL ,
	[DefaultPrintMode] [smallint] NOT NULL ,
	[EmployersNI] [nvarchar] (50) NULL ,
	[CorporationTax] [nvarchar] (50) NULL ,
	[Vat] [nvarchar] (50) NULL ,
	[GeneralTax] [nvarchar] (50) NULL ,
	[BucketTypeCode] [smallint] NOT NULL ,
	[BucketIntervalCode] [smallint] NOT NULL ,
	[ShowCashGraphs] [bit] NOT NULL ,
	[InsertedBy] [nvarchar] (50) NOT NULL ,
	[InsertedOn] [datetime] NOT NULL ,
	[UpdatedBy] [nvarchar] (50) NOT NULL ,
	[UpdatedOn] [datetime] NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbSystemTaxCode] (
	[TaxCode] [nvarchar] (10) NOT NULL ,
	[TaxRate] [float] NOT NULL ,
	[TaxDescription] [nvarchar] (50) NOT NULL ,
	[TaxTypeCode] [smallint] NOT NULL ,
	[UpdatedBy] [nvarchar] (50) NOT NULL ,
	[UpdatedOn] [datetime] NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbSystemUom] (
	[UnitOfMeasure] [nvarchar] (15) NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbSystemYear] (
	[YearNumber] [smallint] NOT NULL ,
	[StartMonth] [smallint] NOT NULL ,
	[CashStatusCode] [smallint] NOT NULL ,
	[Description] [nvarchar] (10) NOT NULL ,
	[InsertedBy] [nvarchar] (50) NOT NULL ,
	[InsertedOn] [datetime] NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbSystemYearPeriod] (
	[YearNumber] [smallint] NOT NULL ,
	[StartOn] [datetime] NOT NULL ,
	[MonthNumber] [smallint] NOT NULL ,
	[CashStatusCode] [smallint] NOT NULL ,
	[MaterialStoreValue] [money] NOT NULL ,
	[MaterialWipValue] [money] NOT NULL ,
	[ProductionStoreValue] [money] NOT NULL ,
	[ProductionWipValue] [money] NOT NULL ,
	[InsertedBy] [nvarchar] (50) NOT NULL ,
	[InsertedOn] [datetime] NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbTask] (
	[TaskCode] [nvarchar] (20) NOT NULL ,
	[UserId] [smallint] NOT NULL ,
	[AccountCode] [nvarchar] (10) NOT NULL ,
	[TaskTitle] [nvarchar] (100) NULL ,
	[ContactName] [nvarchar] (100) NULL ,
	[ActivityCode] [nvarchar] (50) NOT NULL ,
	[TaskStatusCode] [smallint] NOT NULL ,
	[ActionById] [smallint] NOT NULL ,
	[ActionOn] [datetime] NOT NULL ,
	[ActionedOn] [datetime] NULL ,
	[TaskNotes] [ntext] NULL ,
	[Quantity] [float] NOT NULL ,
	[CashCode] [nvarchar] (50) NULL ,
	[TaxCode] [nvarchar] (10) NULL ,
	[UnitCharge] [float] NOT NULL ,
	[TotalCharge] [money] NOT NULL ,
	[AddressCodeFrom] [nvarchar] (15) NULL ,
	[AddressCodeTo] [nvarchar] (15) NULL ,
	[Printed] [bit] NOT NULL ,
	[InsertedBy] [nvarchar] (50) NOT NULL ,
	[InsertedOn] [datetime] NOT NULL ,
	[UpdatedBy] [nvarchar] (50) NOT NULL ,
	[UpdatedOn] [datetime] NOT NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbTaskAttribute] (
	[TaskCode] [nvarchar] (20) NOT NULL ,
	[Attribute] [nvarchar] (50) NOT NULL ,
	[PrintOrder] [smallint] NOT NULL ,
	[AttributeTypeCode] [smallint] NOT NULL ,
	[AttributeDescription] [nvarchar] (255) NULL ,
	[InsertedBy] [nvarchar] (50) NOT NULL ,
	[InsertedOn] [datetime] NOT NULL ,
	[UpdatedBy] [nvarchar] (50) NOT NULL ,
	[UpdatedOn] [datetime] NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbTaskDoc] (
	[TaskCode] [nvarchar] (20) NOT NULL ,
	[DocumentName] [nvarchar] (255) NOT NULL ,
	[DocumentDescription] [ntext] NULL ,
	[DocumentImage] [image] NOT NULL ,
	[InsertedBy] [nvarchar] (50) NOT NULL ,
	[InsertedOn] [datetime] NOT NULL ,
	[UpdatedBy] [nvarchar] (50) NOT NULL ,
	[UpdatedOn] [datetime] NOT NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbTaskFlow] (
	[ParentTaskCode] [nvarchar] (20) NOT NULL ,
	[StepNumber] [smallint] NOT NULL ,
	[ChildTaskCode] [nvarchar] (20) NULL ,
	[UsedOnQuantity] [float] NOT NULL ,
	[OffsetDays] [real] NOT NULL ,
	[InsertedBy] [nvarchar] (50) NOT NULL ,
	[InsertedOn] [datetime] NOT NULL ,
	[UpdatedBy] [nvarchar] (50) NOT NULL ,
	[UpdatedOn] [datetime] NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbTaskStatus] (
	[TaskStatusCode] [smallint] NOT NULL ,
	[TaskStatus] [nvarchar] (100) NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbUser] (
	[UserId] [smallint] NOT NULL ,
	[UserName] [nvarchar] (50) NOT NULL ,
	[LogonName] [nvarchar] (50) NOT NULL ,
	[CalendarCode] [nvarchar] (10) NULL ,
	[PhoneNumber] [nvarchar] (50) NULL ,
	[MobileNumber] [nvarchar] (50) NULL ,
	[FaxNumber] [nvarchar] (50) NULL ,
	[EmailAddress] [nvarchar] (255) NULL ,
	[Address] [ntext] NULL ,
	[Administrator] [bit] NOT NULL ,
	[Avatar] [image] NULL ,
	[Signature] [image] NULL ,
	[InsertedBy] [nvarchar] (50) NOT NULL ,
	[InsertedOn] [datetime] NOT NULL ,
	[UpdatedBy] [nvarchar] (50) NOT NULL ,
	[UpdatedOn] [datetime] NOT NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [dbo].[tbUserMenu] (
	[UserId] [smallint] NOT NULL ,
	[MenuId] [smallint] NOT NULL 
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbActivityAttribute] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbActivityCodeAttrib] PRIMARY KEY  CLUSTERED 
	(
		[ActivityCode],
		[Attribute]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbActivityAttributeType] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbActivityAttributeType] PRIMARY KEY  CLUSTERED 
	(
		[AttributeTypeCode]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbCashCategory] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbCashCategory] PRIMARY KEY  CLUSTERED 
	(
		[CategoryCode]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbCashCategoryExp] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbCashCategoryExp] PRIMARY KEY  CLUSTERED 
	(
		[CategoryCode]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbCashCategoryTotal] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbCashCategoryTotal] PRIMARY KEY  CLUSTERED 
	(
		[ParentCode],
		[ChildCode]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbCashCategoryType] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbCashCategoryType] PRIMARY KEY  CLUSTERED 
	(
		[CategoryTypeCode]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbCashCode] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbCashCode] PRIMARY KEY  CLUSTERED 
	(
		[CashCode]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbCashMode] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbCashMode] PRIMARY KEY  CLUSTERED 
	(
		[CashModeCode]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbCashPeriod] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbCashPeriod] PRIMARY KEY  CLUSTERED 
	(
		[CashCode],
		[StartOn]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbCashStatus] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbCashStatus] PRIMARY KEY  CLUSTERED 
	(
		[CashStatusCode]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbCashTaxType] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbCashTaxType] PRIMARY KEY  CLUSTERED 
	(
		[TaxTypeCode]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbCashType] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbCashType] PRIMARY KEY  CLUSTERED 
	(
		[CashTypeCode]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbInvoice] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbInvoice] PRIMARY KEY  CLUSTERED 
	(
		[InvoiceNumber]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbInvoiceItem] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbInvoiceItem] PRIMARY KEY  CLUSTERED 
	(
		[InvoiceNumber],
		[CashCode]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbInvoiceTask] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbInvoiceTask] PRIMARY KEY  CLUSTERED 
	(
		[InvoiceNumber],
		[TaskCode]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbInvoiceType] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbInvoiceType] PRIMARY KEY  CLUSTERED 
	(
		[InvoiceTypeCode]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbOrgAccount] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbOrgAccount] PRIMARY KEY  CLUSTERED 
	(
		[CashAccountCode]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbOrgAddress] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbOrgAddress] PRIMARY KEY  CLUSTERED 
	(
		[AddressCode]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbOrgPayment] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbOrgPayment] PRIMARY KEY  CLUSTERED 
	(
		[PaymentCode]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbOrgPaymentStatus] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbOrgPaymentStatus] PRIMARY KEY  CLUSTERED 
	(
		[PaymentStatusCode]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbProfileItemType] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbProfileItemType] PRIMARY KEY  CLUSTERED 
	(
		[ItemTypeCode]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbProfileLink] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbProfileLink] PRIMARY KEY  CLUSTERED 
	(
		[LinkName]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbProfileMenu] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbProfileMenu] PRIMARY KEY  CLUSTERED 
	(
		[MenuId]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbProfileMenuCommand] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbProfileMenuCommand] PRIMARY KEY  CLUSTERED 
	(
		[Command]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbProfileMenuEntry] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbProfileMenuEntry] PRIMARY KEY  CLUSTERED 
	(
		[MenuId],
		[EntryId]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbProfileMenuOpenMode] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbProfileMenuOpenMode] PRIMARY KEY  CLUSTERED 
	(
		[OpenMode]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbProfileObject] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbProfileObject] PRIMARY KEY  CLUSTERED 
	(
		[ObjectTypeCode],
		[ObjectName]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbProfileObjectDetail] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbProfileObjectDetail] PRIMARY KEY  CLUSTERED 
	(
		[ObjectTypeCode],
		[ObjectName],
		[ItemName]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbProfileObjectType] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbProfileObjectType] PRIMARY KEY  CLUSTERED 
	(
		[ObjectTypeCode]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbProfileText] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbProfileText] PRIMARY KEY  CLUSTERED 
	(
		[TextId]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbSystemBucket] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbSystemBucket] PRIMARY KEY  CLUSTERED 
	(
		[Period]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbSystemBucketInterval] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbSystemBucketInterval] PRIMARY KEY  CLUSTERED 
	(
		[BucketIntervalCode]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbSystemBucketType] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbSystemBucketType] PRIMARY KEY  CLUSTERED 
	(
		[BucketTypeCode]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbSystemCalendar] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbSystemCalendar] PRIMARY KEY  CLUSTERED 
	(
		[CalendarCode]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbSystemCalendarHoliday] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbSystemCalendarHoliday] PRIMARY KEY  CLUSTERED 
	(
		[CalendarCode],
		[UnavailableOn]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbSystemCodeExclusion] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbSystemCodeExclusion] PRIMARY KEY  CLUSTERED 
	(
		[ExcludedTag]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbSystemDoc] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbSystemDoc] PRIMARY KEY  CLUSTERED 
	(
		[DocTypeCode],
		[ReportName]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbSystemDocType] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbSystemDocType] PRIMARY KEY  CLUSTERED 
	(
		[DocTypeCode]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbSystemInstall] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbSystemInstall] PRIMARY KEY  CLUSTERED 
	(
		[InstallId]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbSystemMonth] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbSystemMonth] PRIMARY KEY  CLUSTERED 
	(
		[MonthNumber]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbSystemOptions] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbSystemRoot] PRIMARY KEY  CLUSTERED 
	(
		[Identifier]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbSystemTaxCode] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbSystemVatCode] PRIMARY KEY  CLUSTERED 
	(
		[TaxCode]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbSystemUom] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbSystemUom] PRIMARY KEY  CLUSTERED 
	(
		[UnitOfMeasure]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbSystemYear] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbSystemYear] PRIMARY KEY  CLUSTERED 
	(
		[YearNumber]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbSystemYearPeriod] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbSystemYearPeriod] PRIMARY KEY  CLUSTERED 
	(
		[YearNumber],
		[StartOn]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbTask] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbTask] PRIMARY KEY  CLUSTERED 
	(
		[TaskCode]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbTaskAttribute] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbTaskAttrib_1] PRIMARY KEY  CLUSTERED 
	(
		[TaskCode],
		[Attribute]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbTaskDoc] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbTaskDoc] PRIMARY KEY  CLUSTERED 
	(
		[TaskCode],
		[DocumentName]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbTaskFlow] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbTaskFlow] PRIMARY KEY  CLUSTERED 
	(
		[ParentTaskCode],
		[StepNumber]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbUserMenu] WITH NOCHECK ADD 
	CONSTRAINT [PK_tbUserMenu] PRIMARY KEY  CLUSTERED 
	(
		[UserId],
		[MenuId]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbActivity] ADD 
	CONSTRAINT [DF_tbActivity_TaskStatusCode] DEFAULT (1) FOR [TaskStatusCode],
	CONSTRAINT [DF_tbActivity_UnitCharge_1] DEFAULT (0) FOR [UnitCharge],
	CONSTRAINT [DF_tbActivity_PrintOrder] DEFAULT (0) FOR [PrintOrder],
	CONSTRAINT [DF_tbActivityCode_InsertedBy] DEFAULT (suser_sname()) FOR [InsertedBy],
	CONSTRAINT [DF_tbActivityCode_InsertedOn] DEFAULT (getdate()) FOR [InsertedOn],
	CONSTRAINT [DF_tbActivityCode_UpdatedBy] DEFAULT (suser_sname()) FOR [UpdatedBy],
	CONSTRAINT [DF_tbActivityCode_UpdatedOn] DEFAULT (getdate()) FOR [UpdatedOn],
	CONSTRAINT [aaaaatbActivityCode_PK] PRIMARY KEY  NONCLUSTERED 
	(
		[ActivityCode]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbActivityAttribute] ADD 
	CONSTRAINT [DF_tbActivityAttribute_OrderBy] DEFAULT (10) FOR [PrintOrder],
	CONSTRAINT [DF_tbActivityAttribute_AttributeTypeCode] DEFAULT (1) FOR [AttributeTypeCode],
	CONSTRAINT [DF_tbTemplateAttribute_InsertedBy] DEFAULT (suser_sname()) FOR [InsertedBy],
	CONSTRAINT [DF_tbTemplateAttribute_InsertedOn] DEFAULT (getdate()) FOR [InsertedOn],
	CONSTRAINT [DF_tbTemplateAttribute_UpdatedBy] DEFAULT (suser_sname()) FOR [UpdatedBy],
	CONSTRAINT [DF_tbTemplateAttribute_UpdatedOn] DEFAULT (getdate()) FOR [UpdatedOn]
GO
 CREATE  INDEX [IX_tbActivityAttribute] ON [dbo].[tbActivityAttribute]([Attribute]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbActivityAttribute_OrderBy] ON [dbo].[tbActivityAttribute]([ActivityCode], [PrintOrder], [Attribute]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbActivityAttribute_Type_OrderBy] ON [dbo].[tbActivityAttribute]([ActivityCode], [AttributeTypeCode], [PrintOrder]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbActivityAttribute_DefaultText] ON [dbo].[tbActivityAttribute]([DefaultText]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbActivityFlow] ADD 
	CONSTRAINT [DF__tbTemplat__JobOr__48CFD27E] DEFAULT (10) FOR [StepNumber],
	CONSTRAINT [DF__tbTemplat__Offse__49C3F6B7] DEFAULT (0) FOR [OffsetDays],
	CONSTRAINT [DF_tbActivityCodeFlow_Quantity] DEFAULT (0) FOR [UsedOnQuantity],
	CONSTRAINT [DF_tbTemplateActivity_InsertedBy] DEFAULT (suser_sname()) FOR [InsertedBy],
	CONSTRAINT [DF_tbTemplateActivity_InsertedOn] DEFAULT (getdate()) FOR [InsertedOn],
	CONSTRAINT [DF_tbTemplateActivity_UpdatedBy] DEFAULT (suser_sname()) FOR [UpdatedBy],
	CONSTRAINT [DF_tbTemplateActivity_UpdatedOn] DEFAULT (getdate()) FOR [UpdatedOn],
	CONSTRAINT [aaaaatbActivityCodeFlow_PK] PRIMARY KEY  NONCLUSTERED 
	(
		[ParentCode],
		[StepNumber]
	)  ON [PRIMARY] 
GO
 CREATE  INDEX [IDX_ChildCodeParentCode] ON [dbo].[tbActivityFlow]([ChildCode], [ParentCode]) ON [PRIMARY]
GO
 CREATE  INDEX [IDX_ParentCodeChildCode] ON [dbo].[tbActivityFlow]([ParentCode], [ChildCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbCashCategory] ADD 
	CONSTRAINT [DF_tbCashCategory_CategoryTypeCode] DEFAULT (1) FOR [CategoryTypeCode],
	CONSTRAINT [DF_tbCashCategory_CashModeCode] DEFAULT (1) FOR [CashModeCode],
	CONSTRAINT [DF_tbCashCategory_CashTypeCode] DEFAULT (1) FOR [CashTypeCode],
	CONSTRAINT [DF_tbCashCategory_DisplayOrder] DEFAULT (0) FOR [DisplayOrder],
	CONSTRAINT [DF_tbCashCategory_ManualForecast] DEFAULT (0) FOR [ManualForecast],
	CONSTRAINT [DF_tbCashCategory_InsertedBy] DEFAULT (suser_sname()) FOR [InsertedBy],
	CONSTRAINT [DF_tbCashCategory_InsertedOn] DEFAULT (getdate()) FOR [InsertedOn],
	CONSTRAINT [DF_tbCashCategory_UpdatedBy] DEFAULT (suser_sname()) FOR [UpdatedBy],
	CONSTRAINT [DF_tbCashCategory_UpdatedOn] DEFAULT (getdate()) FOR [UpdatedOn]
GO
CREATE INDEX [IX_tbCashCategory_Name] ON [dbo].[tbCashCategory]([Category]) WITH  FILLFACTOR = 90 ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbCashCategory_DisplayOrder] ON [dbo].[tbCashCategory]([DisplayOrder], [Category]) WITH  FILLFACTOR = 90 ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbCashCategory_TypeCategory] ON [dbo].[tbCashCategory]([CategoryTypeCode], [Category]) WITH  FILLFACTOR = 90 ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbCashCategory_TypeOrderCategory] ON [dbo].[tbCashCategory]([CategoryTypeCode], [DisplayOrder], [Category]) WITH  FILLFACTOR = 90 ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbCashCode] ADD 
	CONSTRAINT [DF_tbCashCode_OpeningBalance] DEFAULT (0) FOR [OpeningBalance],
	CONSTRAINT [DF_tbCashCode_InsertedBy] DEFAULT (suser_sname()) FOR [InsertedBy],
	CONSTRAINT [DF_tbCashCode_InsertedOn] DEFAULT (getdate()) FOR [InsertedOn],
	CONSTRAINT [DF_tbCashCode_UpdatedBy] DEFAULT (suser_sname()) FOR [UpdatedBy],
	CONSTRAINT [DF_tbCashCode_UpdatedOn] DEFAULT (getdate()) FOR [UpdatedOn],
	CONSTRAINT [IX_tbCashCodeDescription] UNIQUE  NONCLUSTERED 
	(
		[CashDescription]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbCashPeriod] ADD 
	CONSTRAINT [DF_tbCashPeriod_ForecastValue] DEFAULT (0) FOR [ForecastValue],
	CONSTRAINT [DF_tbCashPeriod_ForecastTax] DEFAULT (0) FOR [ForecastTax],
	CONSTRAINT [DF_tbCashPeriod_ActualValue] DEFAULT (0) FOR [CashValue],
	CONSTRAINT [DF_tbCashPeriod_ActualTax] DEFAULT (0) FOR [CashTax],
	CONSTRAINT [DF_tbCashPeriod_InvoiceValue] DEFAULT (0) FOR [InvoiceValue],
	CONSTRAINT [DF_tbCashPeriod_InvoiceTax] DEFAULT (0) FOR [InvoiceTax]
GO
ALTER TABLE [dbo].[tbInvoice] ADD 
	CONSTRAINT [DF__tbInvoice__Invoi__1273C1CD] DEFAULT (convert(datetime,convert(varchar,getdate(),1),1)) FOR [InvoicedOn],
	CONSTRAINT [DF__tbInvoice__Invoi__1367E606] DEFAULT (0) FOR [InvoiceValue],
	CONSTRAINT [DF__tbInvoice__TaxVa__145C0A3F] DEFAULT (0) FOR [TaxValue],
	CONSTRAINT [DF__tbInvoice__PaidV__15502E78] DEFAULT (0) FOR [PaidValue],
	CONSTRAINT [DF__tbInvoice__PaidT__164452B1] DEFAULT (0) FOR [PaidTaxValue],
	CONSTRAINT [DF_tbInvoice_Printed] DEFAULT (0) FOR [Printed]
GO
 CREATE  INDEX [IX_tbInvoice_AccountCode] ON [dbo].[tbInvoice]([AccountCode], [InvoicedOn]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbInvoice_Status] ON [dbo].[tbInvoice]([InvoiceStatusCode], [InvoicedOn]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbInvoice_UserId] ON [dbo].[tbInvoice]([UserId], [InvoiceNumber]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbInvoiceItem] ADD 
	CONSTRAINT [DF_tbInvoiceItem_InvoiceValue] DEFAULT (0) FOR [InvoiceValue],
	CONSTRAINT [DF_tbInvoiceItem_TaxValue] DEFAULT (0) FOR [TaxValue],
	CONSTRAINT [DF_tbInvoiceItem_PaidValue] DEFAULT (0) FOR [PaidValue],
	CONSTRAINT [DF_tbInvoiceItem_PaidTaxValue] DEFAULT (0) FOR [PaidTaxValue]
GO
ALTER TABLE [dbo].[tbInvoiceStatus] ADD 
	CONSTRAINT [aaaaatbInvoiceStatus_PK] PRIMARY KEY  NONCLUSTERED 
	(
		[InvoiceStatusCode]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbInvoiceTask] ADD 
	CONSTRAINT [DF_tbInvoiceTask_Quantity] DEFAULT (0) FOR [Quantity],
	CONSTRAINT [DF_tbInvoiceActivity_InvoiceValue] DEFAULT (0) FOR [InvoiceValue],
	CONSTRAINT [DF_tbInvoiceActivity_TaxValue] DEFAULT (0) FOR [TaxValue],
	CONSTRAINT [DF_tbInvoiceTask_PaidValue] DEFAULT (0) FOR [PaidValue],
	CONSTRAINT [DF_tbInvoiceTask_PaidTaxValue] DEFAULT (0) FOR [PaidTaxValue]
GO
 CREATE  INDEX [IX_tbInvoiceTask_TaskCode] ON [dbo].[tbInvoiceTask]([TaskCode], [InvoiceNumber]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbInvoiceType] ADD 
	CONSTRAINT [DF_tbInvoiceType_NextNumber] DEFAULT (1000) FOR [NextNumber]
GO
ALTER TABLE [dbo].[tbOrg] ADD 
	CONSTRAINT [DF__tbOrg__Organisat__7C8480AE] DEFAULT (1) FOR [OrganisationTypeCode],
	CONSTRAINT [DF__tbOrg__Organisat__7D78A4E7] DEFAULT (1) FOR [OrganisationStatusCode],
	CONSTRAINT [DF_tbOrg_NumberOfEmployees] DEFAULT (0) FOR [NumberOfEmployees],
	CONSTRAINT [DF_tbOrg_Turnover] DEFAULT (0) FOR [Turnover],
	CONSTRAINT [DF_tbOrg_StatementDays] DEFAULT (365) FOR [StatementDays],
	CONSTRAINT [DF_tbOrg_OpeningBalance] DEFAULT (0) FOR [OpeningBalance],
	CONSTRAINT [DF_tbOrg_CurrentBalance] DEFAULT (0) FOR [CurrentBalance],
	CONSTRAINT [DF_tbOrg_ForeignJurisdiction] DEFAULT (0) FOR [ForeignJurisdiction],
	CONSTRAINT [DF_tbOrg_InsertedBy] DEFAULT (suser_sname()) FOR [InsertedBy],
	CONSTRAINT [DF_tbOrg_InsertedOn] DEFAULT (getdate()) FOR [InsertedOn],
	CONSTRAINT [DF_tbOrg_UpdatedBy] DEFAULT (suser_sname()) FOR [UpdatedBy],
	CONSTRAINT [DF_tbOrg_UpdatedOn] DEFAULT (getdate()) FOR [UpdatedOn],
	CONSTRAINT [aaaaatbOrg_PK] PRIMARY KEY  NONCLUSTERED 
	(
		[AccountCode]
	)  ON [PRIMARY] 
GO
 CREATE  UNIQUE  INDEX [IX_tbOrg_AccountName] ON [dbo].[tbOrg]([AccountName]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbOrg_AccountSource] ON [dbo].[tbOrg]([AccountSource]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbOrg_AreaCode] ON [dbo].[tbOrg]([AreaCode]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbOrg_IndustrySector] ON [dbo].[tbOrg]([IndustrySector]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbOrg_OrganisationStatusCode] ON [dbo].[tbOrg]([OrganisationStatusCode]) ON [PRIMARY]
GO
 CREATE  UNIQUE  INDEX [IX_tbOrg_OrganisationStatusCodeAccountCode] ON [dbo].[tbOrg]([OrganisationStatusCode], [AccountName]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbOrg_OrganisationTypeCode] ON [dbo].[tbOrg]([OrganisationTypeCode]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbOrg_PaymentTerms] ON [dbo].[tbOrg]([PaymentTerms]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbOrgAccount] ADD 
	CONSTRAINT [DF_tbOrgAccount_OpeningBalance] DEFAULT (0) FOR [OpeningBalance],
	CONSTRAINT [DF_tbOrgAccount_CurrentBalance] DEFAULT (0) FOR [CurrentBalance],
	CONSTRAINT [DF_tbOrgAccount_AccountClosed] DEFAULT (0) FOR [AccountClosed],
	CONSTRAINT [DF_tbOrgAccount_InsertedBy] DEFAULT (suser_sname()) FOR [InsertedBy],
	CONSTRAINT [DF_tbOrgAccount_InsertedOn] DEFAULT (getdate()) FOR [InsertedOn],
	CONSTRAINT [DF_tbOrgAccount_UpdatedBy] DEFAULT (suser_sname()) FOR [UpdatedBy],
	CONSTRAINT [DF_tbOrgAccount_UpdatedOn] DEFAULT (getdate()) FOR [UpdatedOn]
GO
 CREATE  UNIQUE  INDEX [IX_tbOrgAccount] ON [dbo].[tbOrgAccount]([AccountCode], [CashAccountCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbOrgAddress] ADD 
	CONSTRAINT [DF_tbOrgAddress_InsertedBy] DEFAULT (suser_sname()) FOR [InsertedBy],
	CONSTRAINT [DF_tbOrgAddress_InsertedOn] DEFAULT (getdate()) FOR [InsertedOn],
	CONSTRAINT [DF_tbOrgAddress_UpdatedBy] DEFAULT (suser_sname()) FOR [UpdatedBy],
	CONSTRAINT [DF_tbOrgAddress_UpdatedOn] DEFAULT (getdate()) FOR [UpdatedOn]
GO
 CREATE  UNIQUE  INDEX [IX_tbOrgAddress] ON [dbo].[tbOrgAddress]([AccountCode], [AddressCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbOrgContact] ADD 
	CONSTRAINT [DF_tbOrgContact_OnMailingList] DEFAULT (1) FOR [OnMailingList],
	CONSTRAINT [DF_tbOrgContact_InsertedBy] DEFAULT (suser_sname()) FOR [InsertedBy],
	CONSTRAINT [DF_tbOrgContact_InsertedOn] DEFAULT (getdate()) FOR [InsertedOn],
	CONSTRAINT [DF_tbOrgContact_UpdatedBy] DEFAULT (suser_sname()) FOR [UpdatedBy],
	CONSTRAINT [DF_tbOrgContact_UpdatedOn] DEFAULT (getdate()) FOR [UpdatedOn],
	CONSTRAINT [aaaaatbOrgContact_PK] PRIMARY KEY  NONCLUSTERED 
	(
		[AccountCode],
		[ContactName]
	)  ON [PRIMARY] 
GO
 CREATE  INDEX [IX_tbOrgContactDepartment] ON [dbo].[tbOrgContact]([Department]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbOrgContactJobTitle] ON [dbo].[tbOrgContact]([JobTitle]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbOrgContactNameTitle] ON [dbo].[tbOrgContact]([NameTitle]) ON [PRIMARY]
GO
 CREATE  INDEX [tbOrgtbOrgContact] ON [dbo].[tbOrgContact]([AccountCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbOrgDoc] ADD 
	CONSTRAINT [DF_tbOrgDoc_InsertedBy] DEFAULT (suser_sname()) FOR [InsertedBy],
	CONSTRAINT [DF_tbOrgDoc_InsertedOn] DEFAULT (getdate()) FOR [InsertedOn],
	CONSTRAINT [DF_tbOrgDoc_UpdatedBy] DEFAULT (suser_sname()) FOR [UpdatedBy],
	CONSTRAINT [DF_tbOrgDoc_UpdatedOn] DEFAULT (getdate()) FOR [UpdatedOn],
	CONSTRAINT [aaaaatbOrgDoc_PK] PRIMARY KEY  NONCLUSTERED 
	(
		[AccountCode],
		[DocumentName]
	)  ON [PRIMARY] 
GO
 CREATE  UNIQUE  INDEX [DocumentName] ON [dbo].[tbOrgDoc]([DocumentName], [AccountCode]) ON [PRIMARY]
GO
 CREATE  INDEX [tbOrgtbOrgDoc] ON [dbo].[tbOrgDoc]([AccountCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbOrgPayment] ADD 
	CONSTRAINT [DF_tbOrgPayment_PaymentStatusCode] DEFAULT (1) FOR [PaymentStatusCode],
	CONSTRAINT [DF_tbOrgPayment_PaidOn] DEFAULT (convert(datetime,convert(varchar,getdate(),1),1)) FOR [PaidOn],
	CONSTRAINT [DF_tbOrgPayment_PaidValue] DEFAULT (0) FOR [PaidInValue],
	CONSTRAINT [DF_tbOrgPayment_PaidTaxValue] DEFAULT (0) FOR [PaidOutValue],
	CONSTRAINT [DF_tbOrgPayment_PaidInValue1] DEFAULT (0) FOR [TaxInValue],
	CONSTRAINT [DF_tbOrgPayment_PaidOutValue1] DEFAULT (0) FOR [TaxOutValue],
	CONSTRAINT [DF_tbOrgPayment_InsertedBy] DEFAULT (suser_sname()) FOR [InsertedBy],
	CONSTRAINT [DF_tbOrgPayment_InsertedOn] DEFAULT (getdate()) FOR [InsertedOn],
	CONSTRAINT [DF_tbOrgPayment_UpdatedBy] DEFAULT (suser_sname()) FOR [UpdatedBy],
	CONSTRAINT [DF_tbOrgPayment_UpdatedOn] DEFAULT (getdate()) FOR [UpdatedOn]
GO
 CREATE  INDEX [IX_tbOrgPayment] ON [dbo].[tbOrgPayment]([PaymentReference]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbOrgPayment_AccountCode] ON [dbo].[tbOrgPayment]([AccountCode], [PaidOn] DESC ) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbOrgPayment_CashAccountCode] ON [dbo].[tbOrgPayment]([CashAccountCode], [PaidOn]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbOrgPayment_CashCode] ON [dbo].[tbOrgPayment]([CashCode], [PaidOn]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbOrgPayment_PaymentStatusCode] ON [dbo].[tbOrgPayment]([PaymentStatusCode], [AccountCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbOrgStatus] ADD 
	CONSTRAINT [DF__tbOrgStat__Organ__07C12930] DEFAULT (1) FOR [OrganisationStatusCode],
	CONSTRAINT [aaaaatbOrgStatus_PK] PRIMARY KEY  NONCLUSTERED 
	(
		[OrganisationStatusCode]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbOrgType] ADD 
	CONSTRAINT [DF__tbOrgType__Organ__3F466844] DEFAULT (1) FOR [OrganisationTypeCode],
	CONSTRAINT [aaaaatbOrgType_PK] PRIMARY KEY  NONCLUSTERED 
	(
		[OrganisationTypeCode]
	)  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbProfileCustom] ADD 
	CONSTRAINT [DF_tbProfileCustom_ValidateProperty] DEFAULT (0) FOR [ValidateClient],
	CONSTRAINT [aaaaatbLocalCustomisation_PK] PRIMARY KEY  NONCLUSTERED 
	(
		[SectionCode]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbProfileItemType] ADD 
	CONSTRAINT [DF_tbProfileItemType_ItemTypeCode] DEFAULT (0) FOR [ItemTypeCode]
GO
ALTER TABLE [dbo].[tbProfileMenu] ADD 
	CONSTRAINT [DF_tbProfileMenu_InsertedOn] DEFAULT (getdate()) FOR [InsertedOn],
	CONSTRAINT [DF_tbProfileMenu_InsertedBy] DEFAULT (suser_sname()) FOR [InsertedBy],
	CONSTRAINT [IX_tbProfileMenu] UNIQUE  NONCLUSTERED 
	(
		[MenuName],
		[MenuId]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbProfileMenuCommand] ADD 
	CONSTRAINT [DF_tbProfileMenuCommand_Command] DEFAULT (0) FOR [Command]
GO
ALTER TABLE [dbo].[tbProfileMenuEntry] ADD 
	CONSTRAINT [DF_tbProfileMenuEntry_MenuId] DEFAULT (0) FOR [MenuId],
	CONSTRAINT [DF_tbProfileMenuEntry_FolderId] DEFAULT (0) FOR [FolderId],
	CONSTRAINT [DF_tbProfileMenuEntry_ItemId] DEFAULT (0) FOR [ItemId],
	CONSTRAINT [DF_tbProfileMenuEntry_Command] DEFAULT (0) FOR [Command],
	CONSTRAINT [DF_tbProfileMenuEntry_OpenMode] DEFAULT (1) FOR [OpenMode],
	CONSTRAINT [DF_tbProfileMenuEntry_UpdatedOn] DEFAULT (getdate()) FOR [UpdatedOn],
	CONSTRAINT [DF_tbProfileMenuEntry_InsertedOn] DEFAULT (getdate()) FOR [InsertedOn],
	CONSTRAINT [DF_tbProfileMenuEntry_UpdatedBy] DEFAULT (suser_sname()) FOR [UpdatedBy],
	CONSTRAINT [IX_tbProfileMenuEntry_MenuFolderItem] UNIQUE  NONCLUSTERED 
	(
		[MenuId],
		[FolderId],
		[ItemId]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
 CREATE  INDEX [RDX_tbProfileMenuEntry_Command] ON [dbo].[tbProfileMenuEntry]([Command]) WITH  FILLFACTOR = 90 ON [PRIMARY]
GO
 CREATE  INDEX [RDX_tbProfileMenuEntry_OpenMode] ON [dbo].[tbProfileMenuEntry]([OpenMode]) WITH  FILLFACTOR = 90 ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbProfileMenuOpenMode] ADD 
	CONSTRAINT [DF_tbProfileMenuOpenMode_OpenMode] DEFAULT (0) FOR [OpenMode]
GO
ALTER TABLE [dbo].[tbProfileObject] ADD 
	CONSTRAINT [DF_tbProfileObject_ObjectTypeCode] DEFAULT (2) FOR [ObjectTypeCode],
	CONSTRAINT [DF_tbProfileObject_SubObject] DEFAULT (0) FOR [SubObject],
	CONSTRAINT [DF_tbProfileObject_UpdatedOn] DEFAULT (getdate()) FOR [UpdatedOn],
	CONSTRAINT [DF_tbProfileObject_InsertedOn] DEFAULT (getdate()) FOR [InsertedOn]
GO
 CREATE  INDEX [RDX_tbProfileObject_ObjectTypeCode] ON [dbo].[tbProfileObject]([ObjectTypeCode]) WITH  FILLFACTOR = 90 ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbProfileObjectDetail] ADD 
	CONSTRAINT [DF_tbProfileObjectDetail_ObjectTypeCode] DEFAULT (2) FOR [ObjectTypeCode],
	CONSTRAINT [DF_tbProfileObjectDetail_ItemTypeCode] DEFAULT (100) FOR [ItemTypeCode],
	CONSTRAINT [DF_tbProfileObjectDetail_ItemWidth] DEFAULT (0) FOR [CharLength],
	CONSTRAINT [DF_tbProfileObjectDetail_Visible] DEFAULT (1) FOR [Visible],
	CONSTRAINT [DF_tbProfileObjectDetail_UpdatedOn] DEFAULT (getdate()) FOR [UpdatedOn],
	CONSTRAINT [DF_tbProfileObjectDetail_InsertedOn] DEFAULT (getdate()) FOR [InsertedOn]
GO
 CREATE  INDEX [RDX_tbProfileObjectDetail_ItemTypeCode] ON [dbo].[tbProfileObjectDetail]([ItemTypeCode]) WITH  FILLFACTOR = 90 ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbProfileObjectType] ADD 
	CONSTRAINT [DF_tbProfileObjectType_ObjectTypeCode] DEFAULT (0) FOR [ObjectTypeCode]
GO
ALTER TABLE [dbo].[tbSystemCalendar] ADD 
	CONSTRAINT [DF_tbSystemCalendar_Monday] DEFAULT (1) FOR [Monday],
	CONSTRAINT [DF_tbSystemCalendar_Tuesday] DEFAULT (1) FOR [Tuesday],
	CONSTRAINT [DF_tbSystemCalendar_Wednesday] DEFAULT (1) FOR [Wednesday],
	CONSTRAINT [DF_tbSystemCalendar_Thursday] DEFAULT (1) FOR [Thursday],
	CONSTRAINT [DF_tbSystemCalendar_Friday] DEFAULT (1) FOR [Friday],
	CONSTRAINT [DF_tbSystemCalendar_Saturday] DEFAULT (0) FOR [Saturday],
	CONSTRAINT [DF_tbSystemCalendar_Sunday] DEFAULT (0) FOR [Sunday]
GO
 CREATE  INDEX [RDX_tbSystemCalendarHoliday_CalendarCode] ON [dbo].[tbSystemCalendarHoliday]([CalendarCode]) WITH  FILLFACTOR = 90 ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbSystemDoc] ADD 
	CONSTRAINT [DF_tbSystemDoc_OpenMode] DEFAULT (1) FOR [OpenMode]
GO
ALTER TABLE [dbo].[tbSystemInstall] ADD 
	CONSTRAINT [DF_tbSystemInstall_InstalledOn] DEFAULT (getdate()) FOR [InstalledOn],
	CONSTRAINT [DF_tbSystemInstall_InstalledBy] DEFAULT (suser_sname()) FOR [InstalledBy],
	CONSTRAINT [DF_tbSystemInstall_CategoryId] DEFAULT (0) FOR [CategoryId]
GO
ALTER TABLE [dbo].[tbSystemOptions] ADD 
	CONSTRAINT [DF_tbSystemRoot_Initialised] DEFAULT (0) FOR [Initialised],
	CONSTRAINT [DF_tbSystemRoot_SQLDataVersion] DEFAULT (1) FOR [SQLDataVersion],
	CONSTRAINT [DF_tbSystemRoot_DefaultPrintMode] DEFAULT (2) FOR [DefaultPrintMode],
	CONSTRAINT [DF_tbSystemOptions_BucketTypeCode] DEFAULT (1) FOR [BucketTypeCode],
	CONSTRAINT [DF_tbSystemOptions_BucketIntervalCode] DEFAULT (1) FOR [BucketIntervalCode],
	CONSTRAINT [DF_tbSystemOptions_ShowCashGraphs] DEFAULT (1) FOR [ShowCashGraphs],
	CONSTRAINT [DF_tbSystemOptions_InsertedBy] DEFAULT (suser_sname()) FOR [InsertedBy],
	CONSTRAINT [DF_tbSystemOptions_InsertedOn] DEFAULT (getdate()) FOR [InsertedOn],
	CONSTRAINT [DF_tbSystemOptions_UpdatedBy] DEFAULT (suser_sname()) FOR [UpdatedBy],
	CONSTRAINT [DF_tbSystemOptions_UpdatedOn] DEFAULT (getdate()) FOR [UpdatedOn]
GO
ALTER TABLE [dbo].[tbSystemTaxCode] ADD 
	CONSTRAINT [DF_tbSystemVatCode_VatRate] DEFAULT (0) FOR [TaxRate],
	CONSTRAINT [DF_tbSystemTaxCode_TaxTypeCode] DEFAULT (2) FOR [TaxTypeCode],
	CONSTRAINT [DF_tbSystemTaxCode_UpdatedBy] DEFAULT (suser_sname()) FOR [UpdatedBy],
	CONSTRAINT [DF_tbSystemTaxCode_UpdatedOn] DEFAULT (getdate()) FOR [UpdatedOn]
GO
 CREATE  INDEX [IX_tbSystemTaxCodeByType] ON [dbo].[tbSystemTaxCode]([TaxTypeCode], [TaxCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbSystemYear] ADD 
	CONSTRAINT [DF_tbSystemYear_StartMonth] DEFAULT (1) FOR [StartMonth],
	CONSTRAINT [DF_tbSystemYear_CashStatusCode] DEFAULT (1) FOR [CashStatusCode],
	CONSTRAINT [DF_tbSystemYear_InsertedBy] DEFAULT (suser_sname()) FOR [InsertedBy],
	CONSTRAINT [DF_tbSystemYear_InsertedOn] DEFAULT (getdate()) FOR [InsertedOn]
GO
ALTER TABLE [dbo].[tbSystemYearPeriod] ADD 
	CONSTRAINT [DF_tbSystemYearPeriod_CashStatusCode] DEFAULT (1) FOR [CashStatusCode],
	CONSTRAINT [DF_tbSystemYearPeriod_MaterialStoreValue] DEFAULT (0) FOR [MaterialStoreValue],
	CONSTRAINT [DF_tbSystemYearPeriod_MaterialWipValue] DEFAULT (0) FOR [MaterialWipValue],
	CONSTRAINT [DF_tbSystemYearPeriod_ProductionStoreValue] DEFAULT (0) FOR [ProductionStoreValue],
	CONSTRAINT [DF_tbSystemYearPeriod_ProductionWipValue] DEFAULT (0) FOR [ProductionWipValue],
	CONSTRAINT [DF_tbSystemYearPeriod_InsertedBy] DEFAULT (suser_sname()) FOR [InsertedBy],
	CONSTRAINT [DF_tbSystemYearPeriod_InsertedOn] DEFAULT (getdate()) FOR [InsertedOn],
	CONSTRAINT [IX_tbSystemYearPeriod_StartOn] UNIQUE  NONCLUSTERED 
	(
		[StartOn]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] ,
	CONSTRAINT [IX_tbSystemYearPeriod_Year_MonthNumber] UNIQUE  NONCLUSTERED 
	(
		[YearNumber],
		[MonthNumber]
	) WITH  FILLFACTOR = 90  ON [PRIMARY] 
GO
ALTER TABLE [dbo].[tbTask] ADD 
	CONSTRAINT [DF__tbActivit__Actio__1FCDBCEB] DEFAULT (getdate()) FOR [ActionOn],
	CONSTRAINT [DF_tbActivity_Quantity] DEFAULT (0) FOR [Quantity],
	CONSTRAINT [DF_tbTask_UnitCharge] DEFAULT (0) FOR [UnitCharge],
	CONSTRAINT [DF_tbTask_TotalCharge] DEFAULT (0) FOR [TotalCharge],
	CONSTRAINT [DF_tbTask_Printed] DEFAULT (0) FOR [Printed],
	CONSTRAINT [DF_tbTask_InsertedBy] DEFAULT (suser_sname()) FOR [InsertedBy],
	CONSTRAINT [DF_tbTask_InsertedOn] DEFAULT (getdate()) FOR [InsertedOn],
	CONSTRAINT [DF_tbTask_UpdatedBy] DEFAULT (suser_sname()) FOR [UpdatedBy],
	CONSTRAINT [DF_tbTask_UpdatedOn] DEFAULT (getdate()) FOR [UpdatedOn]
GO
 CREATE  INDEX [IX_tbTask_AccountCode] ON [dbo].[tbTask]([AccountCode]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbTask_AccountCodeByActionOn] ON [dbo].[tbTask]([AccountCode], [ActionOn]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbTask_AccountCodeByStatus] ON [dbo].[tbTask]([AccountCode], [TaskStatusCode], [ActionOn]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbTask_ActionBy] ON [dbo].[tbTask]([ActionById], [TaskStatusCode], [ActionOn]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbTask_ActionById] ON [dbo].[tbTask]([ActionById]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbTask_ActionOn] ON [dbo].[tbTask]([ActionOn] DESC ) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbTask_ActionOnStatus] ON [dbo].[tbTask]([TaskStatusCode], [ActionOn], [AccountCode]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbTask_ActivityCode] ON [dbo].[tbTask]([ActivityCode]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbTask_ActivityCodeTaskTitle] ON [dbo].[tbTask]([ActivityCode], [TaskTitle]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbTask_ActivityStatusCode] ON [dbo].[tbTask]([TaskStatusCode], [ActionOn], [AccountCode]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbTask_CashCode] ON [dbo].[tbTask]([CashCode], [TaskStatusCode], [ActionOn]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbTask_TaskStatusCode] ON [dbo].[tbTask]([TaskStatusCode]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbTask_UserId] ON [dbo].[tbTask]([UserId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbTaskAttribute] ADD 
	CONSTRAINT [DF_tbTaskAttribute_OrderBy] DEFAULT (10) FOR [PrintOrder],
	CONSTRAINT [DF_tbTaskAttribute_AttributeTypeCode] DEFAULT (1) FOR [AttributeTypeCode],
	CONSTRAINT [DF_tbJobAttribute_InsertedBy] DEFAULT (suser_sname()) FOR [InsertedBy],
	CONSTRAINT [DF_tbJobAttribute_InsertedOn] DEFAULT (getdate()) FOR [InsertedOn],
	CONSTRAINT [DF_tbJobAttribute_UpdatedBy] DEFAULT (suser_sname()) FOR [UpdatedBy],
	CONSTRAINT [DF_tbJobAttribute_UpdatedOn] DEFAULT (getdate()) FOR [UpdatedOn]
GO
 CREATE  INDEX [IX_tbTaskAttribute_OrderBy] ON [dbo].[tbTaskAttribute]([TaskCode], [PrintOrder], [Attribute]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbTaskAttribute_Type_OrderBy] ON [dbo].[tbTaskAttribute]([TaskCode], [AttributeTypeCode], [PrintOrder]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbTaskAttribute] ON [dbo].[tbTaskAttribute]([TaskCode]) ON [PRIMARY]
GO
 CREATE  INDEX [IX_tbTaskAttribute_Description] ON [dbo].[tbTaskAttribute]([Attribute], [AttributeDescription]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbTaskDoc] ADD 
	CONSTRAINT [DF_tbActivityDoc_InsertedBy] DEFAULT (suser_sname()) FOR [InsertedBy],
	CONSTRAINT [DF_tbActivityDoc_InsertedOn] DEFAULT (getdate()) FOR [InsertedOn],
	CONSTRAINT [DF_tbActivityDoc_UpdatedBy] DEFAULT (suser_sname()) FOR [UpdatedBy],
	CONSTRAINT [DF_tbActivityDoc_UpdatedOn] DEFAULT (getdate()) FOR [UpdatedOn]
GO
ALTER TABLE [dbo].[tbTaskFlow] ADD 
	CONSTRAINT [DF_tbTaskFlow_StepNumber] DEFAULT (10) FOR [StepNumber],
	CONSTRAINT [DF_tbTaskFlow_UsedOnQuantity] DEFAULT (1) FOR [UsedOnQuantity],
	CONSTRAINT [DF_tbTaskFlow_OffsetDays] DEFAULT (0) FOR [OffsetDays],
	CONSTRAINT [DF_tbTaskFlow_InsertedBy] DEFAULT (suser_sname()) FOR [InsertedBy],
	CONSTRAINT [DF_tbTaskFlow_InsertedOn] DEFAULT (getdate()) FOR [InsertedOn],
	CONSTRAINT [DF_tbTaskFlow_UpdatedBy] DEFAULT (suser_sname()) FOR [UpdatedBy],
	CONSTRAINT [DF_tbTaskFlow_UpdatedOn] DEFAULT (getdate()) FOR [UpdatedOn]
GO
 CREATE  UNIQUE  INDEX [IX_tbTaskFlow_ChildParent] ON [dbo].[tbTaskFlow]([ChildTaskCode], [ParentTaskCode]) ON [PRIMARY]
GO
 CREATE  UNIQUE  INDEX [IX_tbTaskFlow_ParentChild] ON [dbo].[tbTaskFlow]([ParentTaskCode], [ChildTaskCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbTaskStatus] ADD 
	CONSTRAINT [aaaaatbActivityStatus_PK] PRIMARY KEY  NONCLUSTERED 
	(
		[TaskStatusCode]
	)  ON [PRIMARY] 
GO
 CREATE  UNIQUE  INDEX [ActivityStatus] ON [dbo].[tbTaskStatus]([TaskStatus]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbUser] ADD 
	CONSTRAINT [DF_tbUser_LogonName] DEFAULT (suser_sname()) FOR [LogonName],
	CONSTRAINT [DF_tbUser_Administrator] DEFAULT (0) FOR [Administrator],
	CONSTRAINT [DF_tbUser_InsertedBy] DEFAULT (suser_sname()) FOR [InsertedBy],
	CONSTRAINT [DF_tbUser_InsertedOn] DEFAULT (getdate()) FOR [InsertedOn],
	CONSTRAINT [DF_tbUser_UpdatedBy] DEFAULT (suser_sname()) FOR [UpdatedBy],
	CONSTRAINT [DF_tbUser_UpdatedOn] DEFAULT (getdate()) FOR [UpdatedOn],
	CONSTRAINT [aaaaatbUser_PK] PRIMARY KEY  NONCLUSTERED 
	(
		[UserId]
	)  ON [PRIMARY] 
GO
 CREATE  UNIQUE  INDEX [IX_tbUser] ON [dbo].[tbUser]([LogonName]) ON [PRIMARY]
GO
 CREATE  UNIQUE  INDEX [UserName] ON [dbo].[tbUser]([UserName]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbActivity] ADD 
	CONSTRAINT [FK_tbActivityCode_tbCashCode] FOREIGN KEY 
	(
		[CashCode]
	) REFERENCES [dbo].[tbCashCode] (
		[CashCode]
	) ON UPDATE CASCADE ,
	CONSTRAINT [FK_tbActivityCode_tbSystemUom] FOREIGN KEY 
	(
		[UnitOfMeasure]
	) REFERENCES [dbo].[tbSystemUom] (
		[UnitOfMeasure]
	)
GO
ALTER TABLE [dbo].[tbActivityAttribute] ADD 
	CONSTRAINT [FK_tbActivityAttribute_tbActivity] FOREIGN KEY 
	(
		[ActivityCode]
	) REFERENCES [dbo].[tbActivity] (
		[ActivityCode]
	) ON DELETE CASCADE  ON UPDATE CASCADE ,
	CONSTRAINT [FK_tbActivityAttribute_tbActivityAttributeType] FOREIGN KEY 
	(
		[AttributeTypeCode]
	) REFERENCES [dbo].[tbActivityAttributeType] (
		[AttributeTypeCode]
	)
GO
ALTER TABLE [dbo].[tbActivityFlow] ADD 
	CONSTRAINT [FK_tbActivityFlow_tbActivity] FOREIGN KEY 
	(
		[ParentCode]
	) REFERENCES [dbo].[tbActivity] (
		[ActivityCode]
	),
	CONSTRAINT [FK_tbActivityFlow_tbActivity1] FOREIGN KEY 
	(
		[ChildCode]
	) REFERENCES [dbo].[tbActivity] (
		[ActivityCode]
	)
GO
ALTER TABLE [dbo].[tbCashCategory] ADD 
	CONSTRAINT [FK_tbCashCategory_tbCashCategoryType] FOREIGN KEY 
	(
		[CategoryTypeCode]
	) REFERENCES [dbo].[tbCashCategoryType] (
		[CategoryTypeCode]
	),
	CONSTRAINT [FK_tbCashCategory_tbCashMode] FOREIGN KEY 
	(
		[CashModeCode]
	) REFERENCES [dbo].[tbCashMode] (
		[CashModeCode]
	),
	CONSTRAINT [FK_tbCashCategory_tbCashType] FOREIGN KEY 
	(
		[CashTypeCode]
	) REFERENCES [dbo].[tbCashType] (
		[CashTypeCode]
	)
GO
ALTER TABLE [dbo].[tbCashCategoryExp] ADD 
	CONSTRAINT [FK_tbCashCategoryExp_tbCashCategory] FOREIGN KEY 
	(
		[CategoryCode]
	) REFERENCES [dbo].[tbCashCategory] (
		[CategoryCode]
	) ON DELETE CASCADE  ON UPDATE CASCADE 
GO
ALTER TABLE [dbo].[tbCashCategoryTotal] ADD 
	CONSTRAINT [FK_tbCashCategoryTotal_tbCashCategory1] FOREIGN KEY 
	(
		[ParentCode]
	) REFERENCES [dbo].[tbCashCategory] (
		[CategoryCode]
	),
	CONSTRAINT [FK_tbCashCategoryTotal_tbCashCategory2] FOREIGN KEY 
	(
		[ChildCode]
	) REFERENCES [dbo].[tbCashCategory] (
		[CategoryCode]
	)
GO
ALTER TABLE [dbo].[tbCashCode] ADD 
	CONSTRAINT [FK_tbCashCode_tbCashCategory1] FOREIGN KEY 
	(
		[CategoryCode]
	) REFERENCES [dbo].[tbCashCategory] (
		[CategoryCode]
	) ON UPDATE CASCADE ,
	CONSTRAINT [FK_tbCashCode_tbSystemTaxCode] FOREIGN KEY 
	(
		[TaxCode]
	) REFERENCES [dbo].[tbSystemTaxCode] (
		[TaxCode]
	)
GO
ALTER TABLE [dbo].[tbCashPeriod] ADD 
	CONSTRAINT [FK_tbCashPeriod_tbCashCode] FOREIGN KEY 
	(
		[CashCode]
	) REFERENCES [dbo].[tbCashCode] (
		[CashCode]
	) ON DELETE CASCADE  ON UPDATE CASCADE ,
	CONSTRAINT [FK_tbCashPeriod_tbSystemYearPeriod] FOREIGN KEY 
	(
		[StartOn]
	) REFERENCES [dbo].[tbSystemYearPeriod] (
		[StartOn]
	) ON DELETE CASCADE  ON UPDATE CASCADE 
GO
ALTER TABLE [dbo].[tbInvoice] ADD 
	CONSTRAINT [FK_tbInvoice_tbInvoiceStatus] FOREIGN KEY 
	(
		[InvoiceStatusCode]
	) REFERENCES [dbo].[tbInvoiceStatus] (
		[InvoiceStatusCode]
	),
	CONSTRAINT [FK_tbInvoice_tbInvoiceType] FOREIGN KEY 
	(
		[InvoiceTypeCode]
	) REFERENCES [dbo].[tbInvoiceType] (
		[InvoiceTypeCode]
	),
	CONSTRAINT [FK_tbInvoice_tbOrg] FOREIGN KEY 
	(
		[AccountCode]
	) REFERENCES [dbo].[tbOrg] (
		[AccountCode]
	),
	CONSTRAINT [FK_tbInvoice_tbUser1] FOREIGN KEY 
	(
		[UserId]
	) REFERENCES [dbo].[tbUser] (
		[UserId]
	) ON UPDATE CASCADE 
GO
ALTER TABLE [dbo].[tbInvoiceItem] ADD 
	CONSTRAINT [FK_tbInvoiceItem_tbCashCode] FOREIGN KEY 
	(
		[CashCode]
	) REFERENCES [dbo].[tbCashCode] (
		[CashCode]
	) ON UPDATE CASCADE ,
	CONSTRAINT [FK_tbInvoiceItem_tbInvoice] FOREIGN KEY 
	(
		[InvoiceNumber]
	) REFERENCES [dbo].[tbInvoice] (
		[InvoiceNumber]
	) ON DELETE CASCADE  ON UPDATE CASCADE ,
	CONSTRAINT [FK_tbInvoiceItem_tbSystemTaxCode] FOREIGN KEY 
	(
		[TaxCode]
	) REFERENCES [dbo].[tbSystemTaxCode] (
		[TaxCode]
	)
GO
ALTER TABLE [dbo].[tbInvoiceTask] ADD 
	CONSTRAINT [FK_tbInvoiceActivity_tbCashCode] FOREIGN KEY 
	(
		[CashCode]
	) REFERENCES [dbo].[tbCashCode] (
		[CashCode]
	),
	CONSTRAINT [FK_tbInvoiceActivity_tbSystemTaxCode] FOREIGN KEY 
	(
		[TaxCode]
	) REFERENCES [dbo].[tbSystemTaxCode] (
		[TaxCode]
	),
	CONSTRAINT [FK_tbInvoiceTask_tbInvoice] FOREIGN KEY 
	(
		[InvoiceNumber]
	) REFERENCES [dbo].[tbInvoice] (
		[InvoiceNumber]
	) ON DELETE CASCADE  ON UPDATE CASCADE ,
	CONSTRAINT [FK_tbInvoiceTask_tbTask] FOREIGN KEY 
	(
		[TaskCode]
	) REFERENCES [dbo].[tbTask] (
		[TaskCode]
	),
	CONSTRAINT [FK_tbInvoiceTask_tbTask1] FOREIGN KEY 
	(
		[TaskCode]
	) REFERENCES [dbo].[tbTask] (
		[TaskCode]
	)
GO
ALTER TABLE [dbo].[tbInvoiceType] ADD 
	CONSTRAINT [FK_tbInvoiceType_tbCashMode] FOREIGN KEY 
	(
		[CashModeCode]
	) REFERENCES [dbo].[tbCashMode] (
		[CashModeCode]
	)
GO
ALTER TABLE [dbo].[tbOrg] ADD 
	CONSTRAINT [FK_tbOrg_tbOrgAddress] FOREIGN KEY 
	(
		[AddressCode]
	) REFERENCES [dbo].[tbOrgAddress] (
		[AddressCode]
	) NOT FOR REPLICATION ,
	CONSTRAINT [FK_tbOrg_tbSystemTaxCode] FOREIGN KEY 
	(
		[TaxCode]
	) REFERENCES [dbo].[tbSystemTaxCode] (
		[TaxCode]
	) ON UPDATE CASCADE ,
	CONSTRAINT [tbOrg_FK00] FOREIGN KEY 
	(
		[OrganisationStatusCode]
	) REFERENCES [dbo].[tbOrgStatus] (
		[OrganisationStatusCode]
	),
	CONSTRAINT [tbOrg_FK01] FOREIGN KEY 
	(
		[OrganisationTypeCode]
	) REFERENCES [dbo].[tbOrgType] (
		[OrganisationTypeCode]
	)
GO
alter table [dbo].[tbOrg] nocheck constraint [FK_tbOrg_tbOrgAddress]
GO
ALTER TABLE [dbo].[tbOrgAccount] ADD 
	CONSTRAINT [FK_tbOrgAccount_tbCashCode] FOREIGN KEY 
	(
		[CashCode]
	) REFERENCES [dbo].[tbCashCode] (
		[CashCode]
	),
	CONSTRAINT [FK_tbOrgAccount_tbOrg] FOREIGN KEY 
	(
		[AccountCode]
	) REFERENCES [dbo].[tbOrg] (
		[AccountCode]
	) ON UPDATE CASCADE 
GO
ALTER TABLE [dbo].[tbOrgAddress] ADD 
	CONSTRAINT [FK_tbOrgAddress_tbOrg] FOREIGN KEY 
	(
		[AccountCode]
	) REFERENCES [dbo].[tbOrg] (
		[AccountCode]
	) ON DELETE CASCADE  ON UPDATE CASCADE 
GO
ALTER TABLE [dbo].[tbOrgContact] ADD 
	CONSTRAINT [tbOrgContact_FK00] FOREIGN KEY 
	(
		[AccountCode]
	) REFERENCES [dbo].[tbOrg] (
		[AccountCode]
	) ON DELETE CASCADE  ON UPDATE CASCADE 
GO
ALTER TABLE [dbo].[tbOrgDoc] ADD 
	CONSTRAINT [tbOrgDoc_FK00] FOREIGN KEY 
	(
		[AccountCode]
	) REFERENCES [dbo].[tbOrg] (
		[AccountCode]
	) ON DELETE CASCADE  ON UPDATE CASCADE 
GO
ALTER TABLE [dbo].[tbOrgPayment] ADD 
	CONSTRAINT [FK_tbOrgPayment_tbCashCode] FOREIGN KEY 
	(
		[CashCode]
	) REFERENCES [dbo].[tbCashCode] (
		[CashCode]
	) ON UPDATE CASCADE ,
	CONSTRAINT [FK_tbOrgPayment_tbOrg] FOREIGN KEY 
	(
		[AccountCode]
	) REFERENCES [dbo].[tbOrg] (
		[AccountCode]
	),
	CONSTRAINT [FK_tbOrgPayment_tbOrgAccount] FOREIGN KEY 
	(
		[CashAccountCode]
	) REFERENCES [dbo].[tbOrgAccount] (
		[CashAccountCode]
	) ON UPDATE CASCADE ,
	CONSTRAINT [FK_tbOrgPayment_tbOrgPaymentStatus] FOREIGN KEY 
	(
		[PaymentStatusCode]
	) REFERENCES [dbo].[tbOrgPaymentStatus] (
		[PaymentStatusCode]
	),
	CONSTRAINT [FK_tbOrgPayment_tbSystemTaxCode] FOREIGN KEY 
	(
		[TaxCode]
	) REFERENCES [dbo].[tbSystemTaxCode] (
		[TaxCode]
	),
	CONSTRAINT [FK_tbOrgPayment_tbUser1] FOREIGN KEY 
	(
		[UserId]
	) REFERENCES [dbo].[tbUser] (
		[UserId]
	) ON UPDATE CASCADE 
GO
ALTER TABLE [dbo].[tbOrgType] ADD 
	CONSTRAINT [FK_tbOrgType_tbCashMode] FOREIGN KEY 
	(
		[CashModeCode]
	) REFERENCES [dbo].[tbCashMode] (
		[CashModeCode]
	)
GO
ALTER TABLE [dbo].[tbProfileMenuEntry] ADD 
	CONSTRAINT [FK_tbProfileMenuEntry_tbProfileMenu] FOREIGN KEY 
	(
		[MenuId]
	) REFERENCES [dbo].[tbProfileMenu] (
		[MenuId]
	) ON DELETE CASCADE  ON UPDATE CASCADE ,
	CONSTRAINT [tbProfileMenuEntry_FK01] FOREIGN KEY 
	(
		[Command]
	) REFERENCES [dbo].[tbProfileMenuCommand] (
		[Command]
	),
	CONSTRAINT [tbProfileMenuEntry_FK02] FOREIGN KEY 
	(
		[OpenMode]
	) REFERENCES [dbo].[tbProfileMenuOpenMode] (
		[OpenMode]
	)
GO
ALTER TABLE [dbo].[tbProfileObject] ADD 
	CONSTRAINT [tbProfileObject_FK01] FOREIGN KEY 
	(
		[ObjectTypeCode]
	) REFERENCES [dbo].[tbProfileObjectType] (
		[ObjectTypeCode]
	)
GO
ALTER TABLE [dbo].[tbProfileObjectDetail] ADD 
	CONSTRAINT [FK_tbProfileObjectDetail_tbProfileObject] FOREIGN KEY 
	(
		[ObjectTypeCode],
		[ObjectName]
	) REFERENCES [dbo].[tbProfileObject] (
		[ObjectTypeCode],
		[ObjectName]
	) ON DELETE CASCADE  ON UPDATE CASCADE ,
	CONSTRAINT [tbProfileObjectDetail_FK01] FOREIGN KEY 
	(
		[ItemTypeCode]
	) REFERENCES [dbo].[tbProfileItemType] (
		[ItemTypeCode]
	)
GO
ALTER TABLE [dbo].[tbSystemCalendarHoliday] ADD 
	CONSTRAINT [tbSystemCalendarHoliday_FK00] FOREIGN KEY 
	(
		[CalendarCode]
	) REFERENCES [dbo].[tbSystemCalendar] (
		[CalendarCode]
	) ON DELETE CASCADE  ON UPDATE CASCADE 
GO
ALTER TABLE [dbo].[tbSystemDoc] ADD 
	CONSTRAINT [FK_tbSystemDoc_tbProfileMenuOpenMode] FOREIGN KEY 
	(
		[OpenMode]
	) REFERENCES [dbo].[tbProfileMenuOpenMode] (
		[OpenMode]
	)
GO
ALTER TABLE [dbo].[tbSystemOptions] ADD 
	CONSTRAINT [FK_tbSystemOptions_tbSystemBucketInterval] FOREIGN KEY 
	(
		[BucketIntervalCode]
	) REFERENCES [dbo].[tbSystemBucketInterval] (
		[BucketIntervalCode]
	),
	CONSTRAINT [FK_tbSystemOptions_tbSystemBucketType] FOREIGN KEY 
	(
		[BucketTypeCode]
	) REFERENCES [dbo].[tbSystemBucketType] (
		[BucketTypeCode]
	),
	CONSTRAINT [FK_tbSystemRoot_tbCashCode] FOREIGN KEY 
	(
		[EmployersNI]
	) REFERENCES [dbo].[tbCashCode] (
		[CashCode]
	),
	CONSTRAINT [FK_tbSystemRoot_tbCashCode1] FOREIGN KEY 
	(
		[EmployersNI]
	) REFERENCES [dbo].[tbCashCode] (
		[CashCode]
	) ON UPDATE CASCADE ,
	CONSTRAINT [FK_tbSystemRoot_tbCashCode2] FOREIGN KEY 
	(
		[Vat]
	) REFERENCES [dbo].[tbCashCode] (
		[CashCode]
	),
	CONSTRAINT [FK_tbSystemRoot_tbCashCode3] FOREIGN KEY 
	(
		[GeneralTax]
	) REFERENCES [dbo].[tbCashCode] (
		[CashCode]
	),
	CONSTRAINT [FK_tbSystemRoot_tbOrg] FOREIGN KEY 
	(
		[AccountCode]
	) REFERENCES [dbo].[tbOrg] (
		[AccountCode]
	) ON UPDATE CASCADE 
GO
ALTER TABLE [dbo].[tbSystemTaxCode] ADD 
	CONSTRAINT [FK_tbSystemTaxCode_tbCashTaxType] FOREIGN KEY 
	(
		[TaxTypeCode]
	) REFERENCES [dbo].[tbCashTaxType] (
		[TaxTypeCode]
	)
GO
ALTER TABLE [dbo].[tbSystemYear] ADD 
	CONSTRAINT [FK_tbSystemYear_tbSystemMonth] FOREIGN KEY 
	(
		[StartMonth]
	) REFERENCES [dbo].[tbSystemMonth] (
		[MonthNumber]
	)
GO
ALTER TABLE [dbo].[tbSystemYearPeriod] ADD 
	CONSTRAINT [FK_tbSystemYearPeriod_tbCashStatus] FOREIGN KEY 
	(
		[CashStatusCode]
	) REFERENCES [dbo].[tbCashStatus] (
		[CashStatusCode]
	),
	CONSTRAINT [FK_tbSystemYearPeriod_tbSystemMonth] FOREIGN KEY 
	(
		[MonthNumber]
	) REFERENCES [dbo].[tbSystemMonth] (
		[MonthNumber]
	),
	CONSTRAINT [FK_tbSystemYearPeriod_tbSystemYear] FOREIGN KEY 
	(
		[YearNumber]
	) REFERENCES [dbo].[tbSystemYear] (
		[YearNumber]
	) ON DELETE CASCADE  ON UPDATE CASCADE 
GO
ALTER TABLE [dbo].[tbTask] ADD 
	CONSTRAINT [FK_tbTask_tbCashCode] FOREIGN KEY 
	(
		[CashCode]
	) REFERENCES [dbo].[tbCashCode] (
		[CashCode]
	),
	CONSTRAINT [FK_tbTask_tbOrgAddress] FOREIGN KEY 
	(
		[AddressCodeFrom]
	) REFERENCES [dbo].[tbOrgAddress] (
		[AddressCode]
	),
	CONSTRAINT [FK_tbTask_tbOrgAddress1] FOREIGN KEY 
	(
		[AddressCodeTo]
	) REFERENCES [dbo].[tbOrgAddress] (
		[AddressCode]
	),
	CONSTRAINT [FK_tbTask_tbSystemTaxCode] FOREIGN KEY 
	(
		[TaxCode]
	) REFERENCES [dbo].[tbSystemTaxCode] (
		[TaxCode]
	),
	CONSTRAINT [FK_tbTask_tbUser] FOREIGN KEY 
	(
		[UserId]
	) REFERENCES [dbo].[tbUser] (
		[UserId]
	) ON UPDATE CASCADE ,
	CONSTRAINT [FK_tbTask_tbUser1] FOREIGN KEY 
	(
		[ActionById]
	) REFERENCES [dbo].[tbUser] (
		[UserId]
	),
	CONSTRAINT [tbActivity_FK00] FOREIGN KEY 
	(
		[ActivityCode]
	) REFERENCES [dbo].[tbActivity] (
		[ActivityCode]
	) ON UPDATE CASCADE ,
	CONSTRAINT [tbActivity_FK01] FOREIGN KEY 
	(
		[TaskStatusCode]
	) REFERENCES [dbo].[tbTaskStatus] (
		[TaskStatusCode]
	),
	CONSTRAINT [tbActivity_FK02] FOREIGN KEY 
	(
		[AccountCode]
	) REFERENCES [dbo].[tbOrg] (
		[AccountCode]
	) ON UPDATE CASCADE 
GO
ALTER TABLE [dbo].[tbTaskAttribute] ADD 
	CONSTRAINT [FK_tbTaskAttrib_tbTask1] FOREIGN KEY 
	(
		[TaskCode]
	) REFERENCES [dbo].[tbTask] (
		[TaskCode]
	) ON DELETE CASCADE  ON UPDATE CASCADE ,
	CONSTRAINT [FK_tbTaskAttribute_tbActivityAttributeType] FOREIGN KEY 
	(
		[AttributeTypeCode]
	) REFERENCES [dbo].[tbActivityAttributeType] (
		[AttributeTypeCode]
	)
GO
ALTER TABLE [dbo].[tbTaskDoc] ADD 
	CONSTRAINT [FK_tbTaskDoc_tbTask] FOREIGN KEY 
	(
		[TaskCode]
	) REFERENCES [dbo].[tbTask] (
		[TaskCode]
	)
GO
ALTER TABLE [dbo].[tbTaskFlow] ADD 
	CONSTRAINT [FK_tbTaskFlow_tbTask] FOREIGN KEY 
	(
		[ParentTaskCode]
	) REFERENCES [dbo].[tbTask] (
		[TaskCode]
	),
	CONSTRAINT [FK_tbTaskFlow_tbTask1] FOREIGN KEY 
	(
		[ChildTaskCode]
	) REFERENCES [dbo].[tbTask] (
		[TaskCode]
	)
GO
ALTER TABLE [dbo].[tbUser] ADD 
	CONSTRAINT [FK_tbUser_tbSystemCalendar] FOREIGN KEY 
	(
		[CalendarCode]
	) REFERENCES [dbo].[tbSystemCalendar] (
		[CalendarCode]
	) ON UPDATE CASCADE 
GO
ALTER TABLE [dbo].[tbUserMenu] ADD 
	CONSTRAINT [FK_tbUserMenu_tbProfileMenu] FOREIGN KEY 
	(
		[MenuId]
	) REFERENCES [dbo].[tbProfileMenu] (
		[MenuId]
	),
	CONSTRAINT [FK_tbUserMenu_tbUser1] FOREIGN KEY 
	(
		[UserId]
	) REFERENCES [dbo].[tbUser] (
		[UserId]
	) ON UPDATE CASCADE 
GO
CREATE TRIGGER [dbo].[tbOrgAddress_TriggerInsert]
ON [dbo].[tbOrgAddress] 
FOR INSERT
AS
	If exists(SELECT     tbOrg.AddressCode, tbOrg.AccountCode
	          FROM         tbOrg INNER JOIN
	                                inserted AS i ON tbOrg.AccountCode = i.AccountCode
	          WHERE     (tbOrg.AddressCode IS NULL))
		begin
		UPDATE tbOrg
		SET AddressCode = i.AddressCode
		FROM         tbOrg INNER JOIN
	                                inserted AS i ON tbOrg.AccountCode = i.AccountCode
	          WHERE     (tbOrg.AddressCode IS NULL)
		end
GO
CREATE TRIGGER tbOrgPayment_TriggerUpdate
ON dbo.tbOrgPayment
FOR UPDATE
AS
	IF UPDATE(PaidInValue) OR UPDATE(PaidOutValue)
		begin
		declare @AccountCode nvarchar(10)
		
		select @AccountCode = AccountCode from inserted
		
		exec dbo.spOrgRebuild @AccountCode
		exec dbo.spCashAccountRebuildAll
		
		end 
GO
CREATE TRIGGER Trigger_tbTask_Update
ON dbo.tbTask 
FOR UPDATE
AS
	IF UPDATE (ContactName)
		begin
		if exists (SELECT     ContactName
		           FROM         inserted AS i
		           WHERE     (NOT (ContactName IS NULL)) OR
		                                 (ContactName <> N''))
			begin
			if not exists(SELECT     tbOrgContact.ContactName
			              FROM         inserted AS i INNER JOIN
			                                    tbOrgContact ON i.AccountCode = tbOrgContact.AccountCode AND i.ContactName = tbOrgContact.ContactName)
				begin
				declare @FileAs nvarchar(100)
				declare @ContactName nvarchar(100)
				declare @NickName nvarchar(100)
								
				select TOP 1 @ContactName = ContactName from inserted	 
				
				set @NickName = left(@ContactName, charindex(' ', @ContactName, 1))
				exec dbo.spOrgContactFileAs @ContactName, @FileAs output
				
				INSERT INTO tbOrgContact
									  (AccountCode, ContactName, FileAs, NickName)
				SELECT TOP 1 AccountCode, ContactName, @FileAs AS FileAs, @NickName as NickName
				FROM  inserted
				end                                   
			end		
		
		
		end

	IF UPDATE (TaskStatusCode)
		begin
		declare @TaskStatusCode smallint
		declare @TaskCode nvarchar(20)
		select @TaskCode = TaskCode, @TaskStatusCode = TaskStatusCode from inserted
		if @TaskStatusCode <> 4
			begin
			exec dbo.spTaskSetStatus @TaskCode
			end
		
		
		end
GO
drop function [dbo].[fnAccountPeriod]
GO
drop function [dbo].[fnCashAccountStatement]
GO
drop function [dbo].[fnCashAccountStatements]
GO
drop function [dbo].[fnCashCompanyBalance]
GO
drop function [dbo].[fnOrgStatement]
GO
drop function [dbo].[fnPad]
GO
drop function [dbo].[fnSystemActivePeriod]
GO
drop function [dbo].[fnSystemActiveStartOn]
GO
drop function [dbo].[fnSystemAdjustDateToBucket]
GO
drop function [dbo].[fnSystemAdjustToCalendar]
GO
drop function [dbo].[fnSystemBuckets]
GO
drop function [dbo].[fnSystemCashCode]
GO
drop function [dbo].[fnSystemDateBucket]
GO
drop function [dbo].[fnSystemProfileText]
GO
drop function [dbo].[fnSystemVatBalance]
GO
drop function [dbo].[fnSystemWeekDay]
GO
drop function [dbo].[fnTaskDefaultTaxCode]
GO
drop procedure [dbo].[spActivityNextAttributeOrder]
GO
drop procedure [dbo].[spActivityNextStepNumber]
GO
drop procedure [dbo].[spCashAccountRebuild]
GO
drop procedure [dbo].[spCashAccountRebuildAll]
GO
drop procedure [dbo].[spCashCategoryCashCodes]
GO
drop procedure [dbo].[spCashCategoryCodeFromName]
GO
drop procedure [dbo].[spCashCategoryTotals]
GO
drop procedure [dbo].[spCashCodeDefaults]
GO
drop procedure [dbo].[spCashCodeValues]
GO
drop procedure [dbo].[spCashCopyForecastToLiveCashCode]
GO
drop procedure [dbo].[spCashCopyForecastToLiveCategory]
GO
drop procedure [dbo].[spCashCopyLiveToForecastCashCode]
GO
drop procedure [dbo].[spCashCopyLiveToForecastCategory]
GO
drop procedure [dbo].[spCashFlowInitialise]
GO
drop procedure [dbo].[spCashGeneratePeriods]
GO
drop procedure [dbo].[spCashVatBalance]
GO
drop procedure [dbo].[spInvoiceAccept]
GO
drop procedure [dbo].[spInvoiceAddTask]
GO
drop procedure [dbo].[spInvoiceCancel]
GO
drop procedure [dbo].[spInvoiceRaise]
GO
drop procedure [dbo].[spInvoiceTotal]
GO
drop procedure [dbo].[spMenuInsert]
GO
drop procedure [dbo].[spOrgAddAddress]
GO
drop procedure [dbo].[spOrgAddContact]
GO
drop procedure [dbo].[spOrgBalanceOutstanding]
GO
drop procedure [dbo].[spOrgContactFileAs]
GO
drop procedure [dbo].[spOrgDefaultAccountCode]
GO
drop procedure [dbo].[spOrgDefaultTaxCode]
GO
drop procedure [dbo].[spOrgNextAddressCode]
GO
drop procedure [dbo].[spOrgRebuild]
GO
drop procedure [dbo].[spOrgStatement]
GO
drop procedure [dbo].[spPaymentMove]
GO
drop procedure [dbo].[spPaymentPost]
GO
drop procedure [dbo].[spPaymentPostInvoiced]
GO
drop procedure [dbo].[spPaymentPostMisc]
GO
drop procedure [dbo].[spPaymentPostPaidIn]
GO
drop procedure [dbo].[spPaymentPostPaidOut]
GO
drop procedure [dbo].[spSettingAddCalDateRange]
GO
drop procedure [dbo].[spSettingDelCalDateRange]
GO
drop procedure [dbo].[spSettingInitialised]
GO
drop procedure [dbo].[spSettingLicence]
GO
drop procedure [dbo].[spSettingLicenceAdd]
GO
drop procedure [dbo].[spSystemCompanyName]
GO
drop procedure [dbo].[spSystemPeriodClose]
GO
drop procedure [dbo].[spSystemPeriodTransfer]
GO
drop procedure [dbo].[spSystemPeriodTransferAll]
GO
drop procedure [dbo].[spSystemReassignUser]
GO
drop procedure [dbo].[spSystemYearPeriods]
GO
drop procedure [dbo].[spTaskAssignToParent]
GO
drop procedure [dbo].[spTaskConfigure]
GO
drop procedure [dbo].[spTaskCost]
GO
drop procedure [dbo].[spTaskDefaultTaxCode]
GO
drop procedure [dbo].[spTaskDelete]
GO
drop procedure [dbo].[spTaskEmailAddress]
GO
drop procedure [dbo].[spTaskEmailDetail]
GO
drop procedure [dbo].[spTaskEmailFooter]
GO
drop procedure [dbo].[spTaskIsProject]
GO
drop procedure [dbo].[spTaskMode]
GO
drop procedure [dbo].[spTaskNextAttributeOrder]
GO
drop procedure [dbo].[spTaskProject]
GO
drop procedure [dbo].[spTaskSchedule]
GO
drop procedure [dbo].[spTaskSetStatus]
GO
drop procedure [dbo].[spTaskWorkFlow]
GO
drop procedure [dbo].[spInvoiceCredit]
GO
drop procedure [dbo].[spInvoiceRaiseBlank]
GO
drop view [dbo].[vwCashAccountLastPeriodEntry]
GO
drop view [dbo].[vwCashAccountPeriodClosingBalance]
GO
drop view [dbo].[vwCashAccountRebuild]
GO
drop view [dbo].[vwCashAccountStatement]
GO
drop view [dbo].[vwCashAccountStatements]
GO
drop view [dbo].[vwCashCodeForecastSummary]
GO
drop view [dbo].[vwCashCodeInvoiceSummary]
GO
drop view [dbo].[vwCashCodePaymentSummary]
GO
drop view [dbo].[vwCashSummaryBase]
GO
drop view [dbo].[vwCashSummaryInvoices]
GO
drop view [dbo].[vwInvoiceOutstanding]
GO
drop view [dbo].[vwInvoiceOutstandingBase]
GO
drop view [dbo].[vwInvoiceOutstandingItems]
GO
drop view [dbo].[vwInvoiceOutstandingTasks]
GO
drop view [dbo].[vwInvoiceRegisterDetail]
GO
drop view [dbo].[vwInvoiceRegisterItems]
GO
drop view [dbo].[vwInvoiceRegisterTasks]
GO
drop view [dbo].[vwInvoiceSummary]
GO
drop view [dbo].[vwInvoiceSummaryBase]
GO
drop view [dbo].[vwInvoiceSummaryItems]
GO
drop view [dbo].[vwInvoiceSummaryMargin]
GO
drop view [dbo].[vwInvoiceSummaryTasks]
GO
drop view [dbo].[vwInvoiceSummaryTotals]
GO
drop view [dbo].[vwInvoiceTaxBase]
GO
drop view [dbo].[vwInvoiceTaxSummary]
GO
drop view [dbo].[vwInvoiceVatBase]
GO
drop view [dbo].[vwInvoiceVatDetail]
GO
drop view [dbo].[vwInvoiceVatItems]
GO
drop view [dbo].[vwInvoiceVatSummary]
GO
drop view [dbo].[vwInvoiceVatTasks]
GO
drop view [dbo].[vwTaskInvoicedQuantity]
GO
drop view [dbo].[vwCashEmployerNITotals]
GO
drop view [dbo].[vwCashFlowData]
GO
drop view [dbo].[vwCashFlowActualData]
GO
drop view [dbo].[vwCashFlowForecastData]
GO
drop view [dbo].[vwCashFlowVatTotals]
GO
drop view [dbo].[vwCashFlowNITotals]
GO
drop view [dbo].[vwCashFlowVatTotalsBase]
GO
drop view [dbo].[vwCashMonthList]
GO
drop view [dbo].[vwCashPolarData]
GO
drop view [dbo].[vwInvoiceRegister]
GO
drop view [dbo].[vwCashPeriods]
GO
drop view [dbo].[vwAccountStatementBase]
GO
drop view [dbo].[vwAccountStatementPaymentBase]
GO
drop view [dbo].[vwCashActiveYears]
GO
drop view [dbo].[vwTaskCashMode]
GO
drop view [dbo].[vwTasks]
GO
drop view [dbo].[vwAccountStatementPayments]
GO
drop view [dbo].[vwTaskBucket]
GO
drop view [dbo].[vwAccountStatementInvoices]
GO
drop view [dbo].[vwCashAnalysisCodes]
GO
drop view [dbo].[vwCashCategoriesBank]
GO
drop view [dbo].[vwCashCategoriesNominal]
GO
drop view [dbo].[vwCashCategoriesTax]
GO
drop view [dbo].[vwCashCategoriesTotals]
GO
drop view [dbo].[vwCashCategoriesTrade]
GO
drop view [dbo].[vwCashSummary]
GO
drop view [dbo].[vwOrgBalanceOutstanding]
GO
drop view [dbo].[vwUserCredentials]
GO
drop view [dbo].[vwOrgInvoiceItems]
GO
drop view [dbo].[vwOrgInvoiceTasks]
GO
drop view [dbo].[vwOrgInvoices]
GO
drop view [dbo].[vwOrgAddresses]
GO
drop view [dbo].[vwOrgMailContacts]
GO
CREATE FUNCTION [dbo].[fnAccountPeriod]
	(
	@TransactedOn datetime
	)
RETURNS datetime
AS
	BEGIN
	declare @StartOn datetime
	SELECT TOP 1 @StartOn = StartOn
	FROM         tbSystemYearPeriod
	WHERE     (StartOn <= @TransactedOn)
	ORDER BY StartOn DESC
	
	RETURN @StartOn
	END
GO
CREATE FUNCTION dbo.fnCashAccountStatement
	(
		@CashAccountCode nvarchar(10)
	)
RETURNS @tbCash TABLE (EntryNumber int, PaymentCode nvarchar(20), PaidOn datetime, PaidBalance money, TaxedBalance money)
AS
	BEGIN
	declare @EntryNumber int
	declare @PaymentCode nvarchar(20)
	declare @PaidOn datetime
	declare @Paid money
	declare @Taxed money
	declare @PaidBalance money
	declare @TaxedBalance money
		
	SELECT   @PaidBalance = OpeningBalance
	FROM         tbOrgAccount
	WHERE     (CashAccountCode = @CashAccountCode)

	SELECT    @PaidOn = MIN(PaidOn) 
	FROM         tbOrgPayment
	WHERE     (CashAccountCode = @CashAccountCode)
	
	set @EntryNumber = 1
		
	insert into @tbCash (EntryNumber, PaymentCode, PaidOn, PaidBalance, TaxedBalance)
	values (@EntryNumber, dbo.fnSystemProfileText(3005), dateadd(d, -1, @PaidOn), @PaidBalance, 0) 

	set @EntryNumber = @EntryNumber + 1
	set @TaxedBalance = 0
	
	declare curCash cursor local for
		SELECT     PaymentCode, PaidOn, CASE WHEN PaidInValue > 0 THEN PaidInValue ELSE PaidOutValue * - 1 END AS Paid, 
		                      TaxOutValue - TaxInValue AS Taxed
		FROM         tbOrgPayment
		WHERE     (PaymentStatusCode = 2) AND (CashAccountCode = @CashAccountCode)
		ORDER BY PaidOn

	open curCash
	fetch next from curCash into @PaymentCode, @PaidOn, @Paid, @Taxed
	while @@FETCH_STATUS = 0
		begin	
		set @PaidBalance = @PaidBalance + @Paid
		set @TaxedBalance = @TaxedBalance + @Taxed
		insert into @tbCash (EntryNumber, PaymentCode, PaidOn, PaidBalance, TaxedBalance)
		values (@EntryNumber, @PaymentCode, @PaidOn, @PaidBalance, @TaxedBalance) 
		
		set @EntryNumber = @EntryNumber + 1
		fetch next from curCash into @PaymentCode, @PaidOn, @Paid, @Taxed
		end
	
	close curCash
	deallocate curCash
		
	RETURN
	END
GO
CREATE FUNCTION dbo.fnCashAccountStatements
()
RETURNS  @tbCashAccount TABLE (CashAccountCode nvarchar(20), EntryNumber int, PaymentCode nvarchar(20), PaidOn datetime, PaidBalance money, TaxedBalance money)
AS
	BEGIN
	declare @CashAccountCode nvarchar(20)
	declare curAccount cursor local for 
		SELECT     CashAccountCode
		FROM         tbOrgAccount
		WHERE     (AccountClosed = 0)
		ORDER BY CashAccountCode

	open curAccount
	fetch next from curAccount into @CashAccountCode
	while @@FETCH_STATUS = 0
		begin
		insert into @tbCashAccount (CashAccountCode, EntryNumber, PaymentCode, PaidOn, PaidBalance, TaxedBalance)
		SELECT     @CashAccountCode As CashAccountCode, EntryNumber, PaymentCode, PaidOn, PaidBalance, TaxedBalance
		FROM         fnCashAccountStatement(@CashAccountCode) fnCashAccountStatement		
		fetch next from curAccount into @CashAccountCode
		end
	
	close curAccount
	deallocate curAccount
	
	RETURN
	END
GO
CREATE FUNCTION dbo.fnCashCompanyBalance
	()
RETURNS money
AS
	BEGIN
	declare @CurrentBalance money
	
	SELECT @CurrentBalance = SUM(CurrentBalance) 
	FROM         tbOrgAccount
	WHERE     (AccountClosed = 0)
	
	RETURN isnull(@CurrentBalance, 0)
	END
GO
CREATE VIEW dbo.vwAccountStatementPayments
AS
SELECT     TOP 100 PERCENT dbo.tbOrgPayment.AccountCode, dbo.tbOrgPayment.PaidOn AS TransactedOn, 2 AS OrderBy, 
                      dbo.tbOrgPayment.PaymentReference AS Reference, dbo.tbOrgPaymentStatus.PaymentStatus AS StatementType, 
                      CASE WHEN PaidInValue > 0 THEN PaidInValue ELSE PaidOutValue * - 1 END AS Charge
FROM         dbo.tbOrgPayment INNER JOIN
                      dbo.tbOrgPaymentStatus ON dbo.tbOrgPayment.PaymentStatusCode = dbo.tbOrgPaymentStatus.PaymentStatusCode
ORDER BY dbo.tbOrgPayment.AccountCode, dbo.tbOrgPayment.PaidOn
GO
CREATE VIEW dbo.vwAccountStatementPaymentBase
AS
SELECT     AccountCode, TransactedOn, OrderBy, Reference, StatementType, SUM(Charge) AS Charge
FROM         dbo.vwAccountStatementPayments
GROUP BY AccountCode, TransactedOn, OrderBy, Reference, StatementType
GO
CREATE VIEW dbo.vwAccountStatementInvoices
AS
SELECT     TOP 100 PERCENT dbo.tbInvoice.AccountCode, dbo.tbInvoice.InvoicedOn AS TransactedOn, 1 AS OrderBy, dbo.tbInvoice.InvoiceNumber AS Reference, 
                      dbo.tbInvoiceType.InvoiceType AS StatementType, 
                      CASE CashModeCode WHEN 1 THEN dbo.tbInvoice.InvoiceValue + dbo.tbInvoice.TaxValue WHEN 2 THEN (dbo.tbInvoice.InvoiceValue + dbo.tbInvoice.TaxValue)
                       * - 1 END AS Charge
FROM         dbo.tbInvoice INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
ORDER BY dbo.tbInvoice.AccountCode, dbo.tbInvoice.InvoicedOn
GO
CREATE VIEW dbo.vwAccountStatementBase
AS
SELECT     TOP 100 PERCENT AccountCode, TransactedOn, OrderBy, Reference, StatementType, Charge
FROM         dbo.vwAccountStatementPaymentBase
UNION
SELECT     TOP 100 PERCENT AccountCode, TransactedOn, OrderBy, Reference, StatementType, Charge
FROM         dbo.vwAccountStatementInvoices
GO
CREATE FUNCTION dbo.fnOrgStatement
	(
	@AccountCode nvarchar(10)
	)
RETURNS @tbStatement TABLE (TransactedOn datetime, OrderBy smallint, Reference nvarchar(50), StatementType nvarchar(20), Charge money, Balance money)
AS
	BEGIN
	declare @TransactedOn datetime
	declare @OrderBy smallint
	declare @Reference nvarchar(50)
	declare @StatementType nvarchar(20)
	declare @Charge money
	declare @Balance money
	
	select @StatementType = dbo.fnSystemProfileText(3005)
	select @Balance = OpeningBalance from tbOrg where AccountCode = @AccountCode
	
	SELECT   @TransactedOn = MIN(TransactedOn) 
	FROM         vwAccountStatementBase
	WHERE     (AccountCode = @AccountCode)
	
	insert into @tbStatement (TransactedOn, OrderBy, StatementType, Charge, Balance)
	values (dateadd(d, -1, @TransactedOn), 0, @StatementType, @Balance, @Balance)
	 
	declare curAc cursor local for
		SELECT     TransactedOn, OrderBy, Reference, StatementType, Charge
		FROM         vwAccountStatementBase
		WHERE     (AccountCode = @AccountCode)
		ORDER BY TransactedOn, OrderBy

	open curAc
	fetch next from curAc into @TransactedOn, @OrderBy, @Reference, @StatementType, @Charge
	while @@FETCH_STATUS = 0
		begin
		set @Balance = @Balance + @Charge
		insert into @tbStatement (TransactedOn, OrderBy, Reference, StatementType, Charge, Balance)
		values (@TransactedOn, @OrderBy, @Reference, @StatementType, @Charge, @Balance)
		
		fetch next from curAc into @TransactedOn, @OrderBy, @Reference, @StatementType, @Charge
		end
	
	close curAc
	deallocate curAc
		
	RETURN
	END
GO
CREATE FUNCTION [dbo].[fnPad]
	(
		@Source nvarchar(25),
		@Length smallint
	)
RETURNS nvarchar(25)
AS
	BEGIN
	declare @i smallint
	declare @Pad smallint
	declare @Target nvarchar(25)
	
	set @Target = RTRIM(LTRIM(@Source))	
	set @Pad = @Length - LEN(@Target)
	set @i = 0
	
	while @i < @Pad
		begin
		set @Target = '0' + @Target
		set @i = @i + 1
		end
	
	RETURN @Target
	END
GO
CREATE FUNCTION [dbo].[fnSystemActivePeriod]
	(
	)
RETURNS @tbSystemYearPeriod TABLE (YearNumber smallint, StartOn datetime, EndOn datetime, MonthName nvarchar(10), Description nvarchar(10), MonthNumber smallint) 
AS
	BEGIN
	declare @StartOn datetime
	declare @EndOn datetime
	
	if exists (	SELECT     StartOn	FROM tbSystemYearPeriod WHERE (CashStatusCode < 3))
		begin
		SELECT @StartOn = MIN(StartOn)
		FROM         tbSystemYearPeriod
		WHERE     (CashStatusCode < 3)
		
		if exists (select StartOn from tbSystemYearPeriod where StartOn > @StartOn)
			select top 1 @EndOn = StartOn from tbSystemYearPeriod where StartOn > @StartOn order by StartOn
		else
			set @EndOn = dateadd(m, 1, @StartOn)
			
		insert into @tbSystemYearPeriod (YearNumber, StartOn, EndOn, MonthName, Description, MonthNumber)
		SELECT     tbSystemYearPeriod.YearNumber, tbSystemYearPeriod.StartOn, @EndOn, tbSystemMonth.MonthName, tbSystemYear.Description, tbSystemMonth.MonthNumber
		FROM         tbSystemYearPeriod INNER JOIN
		                      tbSystemMonth ON tbSystemYearPeriod.MonthNumber = tbSystemMonth.MonthNumber INNER JOIN
		                      tbSystemYear ON tbSystemYearPeriod.YearNumber = tbSystemYear.YearNumber
		WHERE     (tbSystemYearPeriod.StartOn = @StartOn)
		end	
	RETURN
	END
GO
CREATE FUNCTION dbo.fnSystemActiveStartOn
	()
RETURNS datetime
AS
	BEGIN
	declare @StartOn datetime
	select @StartOn = StartOn from dbo.fnSystemActivePeriod()
	RETURN @StartOn
	END
GO
CREATE FUNCTION dbo.fnSystemAdjustDateToBucket
	(
	@BucketDay smallint,
	@CurrentDate datetime
	)
RETURNS datetime
AS
	BEGIN
	declare @CurrentDay smallint
	declare @Offset smallint
	declare @AdjustedDay smallint
	
	set @CurrentDay = datepart(dw, @CurrentDate)
	
	set @AdjustedDay = case when @CurrentDay > (7 - @@DATEFIRST + 1) then
				@CurrentDay - (7 - @@DATEFIRST + 1)
			else
				@CurrentDay + (@@DATEFIRST - 1)
			end

	set @Offset = case when @BucketDay <= @AdjustedDay then
				@BucketDay - @AdjustedDay
			else
				(7 - (@BucketDay - @AdjustedDay)) * -1
			end
	
		
	RETURN dateadd(dd, @Offset, @CurrentDate)
	END
GO
CREATE FUNCTION dbo.fnSystemAdjustToCalendar
	(
	@UserId smallint,
	@SourceDate datetime,
	@Days int
	)
RETURNS datetime
AS
	BEGIN
	declare @CalendarCode nvarchar(10)
	declare @TargetDate datetime
	declare @WorkingDay bit
	
	declare @CurrentDay smallint
	declare @Monday smallint
	declare @Tuesday smallint
	declare @Wednesday smallint
	declare @Thursday smallint
	declare @Friday smallint
	declare @Saturday smallint
	declare @Sunday smallint
		
	set @TargetDate = @SourceDate

	SELECT     @CalendarCode = tbSystemCalendar.CalendarCode, @Monday = Monday, @Tuesday = Tuesday, @Wednesday = Wednesday, @Thursday = Thursday, @Friday = Friday, @Saturday = Saturday, @Sunday = Sunday
	FROM         tbSystemCalendar INNER JOIN
	                      tbUser ON tbSystemCalendar.CalendarCode = tbUser.CalendarCode
	WHERE UserId = @UserId
	
	while @Days > -1
		begin
		set @CurrentDay = dbo.fnSystemWeekDay(@TargetDate)
		if @CurrentDay = 1				
			set @WorkingDay = case when @Monday != 0 then 1 else 0 end
		else if @CurrentDay = 2
			set @WorkingDay = case when @Tuesday != 0 then 1 else 0 end
		else if @CurrentDay = 3
			set @WorkingDay = case when @Wednesday != 0 then 1 else 0 end
		else if @CurrentDay = 4
			set @WorkingDay = case when @Thursday != 0 then 1 else 0 end
		else if @CurrentDay = 5
			set @WorkingDay = case when @Friday != 0 then 1 else 0 end
		else if @CurrentDay = 6
			set @WorkingDay = case when @Saturday != 0 then 1 else 0 end
		else if @CurrentDay = 7
			set @WorkingDay = case when @Sunday != 0 then 1 else 0 end
		
		if @WorkingDay = 1
			begin
			if not exists(SELECT     UnavailableOn
				        FROM         tbSystemCalendarHoliday
				        WHERE     (CalendarCode = @CalendarCode) AND (UnavailableOn = @TargetDate))
				set @Days = @Days - 1
			end
			
		if @Days > -1
			set @TargetDate = dateadd(d, -1, @TargetDate)
		end
		

	RETURN @TargetDate
	END
GO
CREATE FUNCTION dbo.fnSystemBuckets
	(@CurrentDate datetime)
RETURNS  @tbBkn TABLE (Period smallint, StartDate datetime, EndDate datetime)
AS
	BEGIN
	declare @BucketTypeCode smallint
	declare @UnitOfTimeCode smallint
	declare @Period smallint	
	declare @CurrentPeriod smallint
	declare @Offset smallint
	
	declare @StartDate datetime
	declare @EndDate datetime
	
		
	SELECT     TOP 1 @BucketTypeCode = BucketTypeCode, @UnitOfTimeCode = BucketIntervalCode
	FROM         tbSystemOptions
		
	set @EndDate = 
		case @BucketTypeCode
			when 0 then
				@CurrentDate
			when 8 then
				DATEADD(d, Day(@CurrentDate) * -1 + 1, @CurrentDate)
			else
				dbo.fnSystemAdjustDateToBucket(@BucketTypeCode, @CurrentDate)
		end
			
	set @EndDate = convert(datetime,convert(varchar,@EndDate,1))
	set @StartDate = dateadd(yyyy, -100, @EndDate)
	set @CurrentPeriod = 0
	
	declare curBk cursor for			
		SELECT     Period
		FROM         tbSystemBucket
		ORDER BY Period

	open curBk
	fetch next from curBk into @Period
	while @@FETCH_STATUS = 0
		begin
		if @Period > 0
			begin
			set @StartDate = @EndDate
			set @Offset = @Period - @CurrentPeriod
			set @EndDate = case @UnitOfTimeCode
				when 1 then		--day
					dateadd(d, @Offset, @StartDate) 					
				when 2 then		--week
					dateadd(d, @Offset * 7, @StartDate)
				when 3 then		--month
					dateadd(m, @Offset, @StartDate)
				end
			end
		
		insert into @tbBkn(Period, StartDate, EndDate)
		values (@Period, @StartDate, @EndDate)
		
		set @CurrentPeriod = @Period
		
		fetch next from curBk into @Period
		end
		
			
	RETURN
	END
GO
CREATE FUNCTION dbo.fnSystemCashCode
	(
	@TaxTypeCode smallint
	)
RETURNS nvarchar(50)
AS
	BEGIN
	declare @CashCode nvarchar(50)
	
	if @TaxTypeCode = 2
		select @CashCode = Vat from tbSystemOptions
	else if @TaxTypeCode = 3
		select @CashCode = EmployersNI from tbSystemOptions
		
	
	RETURN @CashCode
	END
GO
CREATE FUNCTION [dbo].[fnSystemDateBucket]
	(@CurrentDate datetime, @BucketDate datetime)
RETURNS smallint
AS
	BEGIN
	declare @Period smallint
	SELECT  @Period = Period
	FROM         dbo.fnSystemBuckets(@CurrentDate) fnEnvBuckets
	WHERE     (StartDate <= @BucketDate) AND (EndDate > @BucketDate) 
	RETURN @Period
	END
GO
CREATE FUNCTION [dbo].[fnSystemProfileText]
	(
	@TextId int
	)
RETURNS nvarchar(255)
AS
	BEGIN
	declare @Message nvarchar(255)
	select top 1 @Message = Message from tbProfileText
	where TextId = @TextId
	RETURN @Message
	END
GO
CREATE FUNCTION dbo.fnSystemVatBalance
	()
RETURNS money
AS
	BEGIN
	declare @Balance money
	SELECT  @Balance = SUM(HomeSalesVat - HomePurchasesVat + ExportSalesVat - ExportPurchasesVat)
	FROM         vwInvoiceVatSummary
	
	SELECT  @Balance = @Balance + ISNULL(SUM(tbOrgPayment.PaidInValue - tbOrgPayment.PaidOutValue), 0)
	FROM         tbSystemOptions INNER JOIN
	                      tbOrgPayment ON tbSystemOptions.Vat = tbOrgPayment.CashCode	
	                      
	RETURN isnull(@Balance, 0)
	END
GO
CREATE FUNCTION [dbo].[fnSystemWeekDay]
	(
	@Date datetime
	)
RETURNS smallint
AS
	BEGIN
	declare @CurrentDay smallint
	set @CurrentDay = datepart(dw, @Date)
	RETURN 	case when @CurrentDay > (7 - @@DATEFIRST + 1) then
				@CurrentDay - (7 - @@DATEFIRST + 1)
			else
				@CurrentDay + (@@DATEFIRST - 1)
			end
	END
GO
CREATE FUNCTION [dbo].[fnTaskDefaultTaxCode] 
	(
	@AccountCode nvarchar(10),
	@CashCode nvarchar(50)
	)
RETURNS nvarchar(10)
AS
	BEGIN
	declare @TaxCode nvarchar(10)
	
	if (not @AccountCode is null) and (not @CashCode is null)
		begin
		if exists(SELECT     TaxCode
			  FROM         tbOrg
			  WHERE     (AccountCode = @AccountCode) AND (NOT (TaxCode IS NULL)))
			begin
			SELECT    @TaxCode = TaxCode
			FROM         tbOrg
			WHERE     (AccountCode = @AccountCode) AND (NOT (TaxCode IS NULL))
			end
		else
			begin
			SELECT    @TaxCode =  TaxCode
			FROM         tbCashCode
			WHERE     (CashCode = @CashCode)		
			end
		end
	else
		set @TaxCode = null
				
	RETURN @TaxCode
	END
GO
CREATE VIEW [dbo].[vwCashAnalysisCodes]
AS
SELECT     TOP 100 PERCENT dbo.tbCashCategory.CategoryCode, dbo.tbCashCategory.Category, dbo.tbCashCategoryExp.Expression, 
                      dbo.tbCashCategoryExp.Format
FROM         dbo.tbCashCategory INNER JOIN
                      dbo.tbCashCategoryExp ON dbo.tbCashCategory.CategoryCode = dbo.tbCashCategoryExp.CategoryCode
WHERE     (dbo.tbCashCategory.CategoryTypeCode = 3)
ORDER BY dbo.tbCashCategory.DisplayOrder
GO
CREATE VIEW [dbo].[vwCashCategoriesBank]
AS
SELECT     TOP 100 PERCENT CategoryCode, Category, CashModeCode
FROM         dbo.tbCashCategory
WHERE     (CashTypeCode = 4) AND (CategoryTypeCode = 1)
GROUP BY CategoryCode, Category, DisplayOrder, CashModeCode
ORDER BY DisplayOrder, Category
GO
CREATE VIEW [dbo].[vwCashCategoriesNominal]
AS
SELECT     TOP 100 PERCENT CategoryCode, Category, CashModeCode
FROM         dbo.tbCashCategory
WHERE     (CashTypeCode = 3) AND (CategoryTypeCode = 1)
GROUP BY CategoryCode, Category, DisplayOrder, CashModeCode
ORDER BY DisplayOrder, Category
GO
CREATE VIEW [dbo].[vwCashCategoriesTax]
AS
SELECT     TOP 100 PERCENT CategoryCode, Category, CashModeCode
FROM         dbo.tbCashCategory
WHERE     (CashTypeCode = 2) AND (CategoryTypeCode = 1)
GROUP BY CategoryCode, Category, DisplayOrder, CashModeCode
ORDER BY DisplayOrder, Category
GO
CREATE VIEW [dbo].[vwCashCategoriesTotals]
AS
SELECT     TOP 100 PERCENT CategoryCode, CashModeCode, CashTypeCode, DisplayOrder, Category
FROM         dbo.tbCashCategory
WHERE     (CategoryTypeCode = 2)
ORDER BY CashTypeCode, CategoryCode
GO
CREATE VIEW [dbo].[vwCashCategoriesTrade]
AS
SELECT     TOP 100 PERCENT CategoryCode, Category, CashModeCode
FROM         dbo.tbCashCategory
WHERE     (CashTypeCode = 1) AND (CategoryTypeCode = 1)
GROUP BY CategoryCode, Category, DisplayOrder, CashModeCode
ORDER BY DisplayOrder, Category
GO
CREATE VIEW dbo.vwCashSummaryInvoices
AS
SELECT     dbo.tbInvoice.InvoiceNumber, CASE dbo.tbInvoice.InvoiceTypeCode WHEN 1 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) 
                      WHEN 4 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) ELSE 0 END AS ToCollect, 
                      CASE dbo.tbInvoice.InvoiceTypeCode WHEN 2 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) WHEN 3 THEN (InvoiceValue + TaxValue) 
                      - (PaidValue + PaidTaxValue) ELSE 0 END AS ToPay, CASE dbo.tbInvoiceType.CashModeCode WHEN 1 THEN (TaxValue - PaidTaxValue) 
                      * - 1 WHEN 2 THEN TaxValue - PaidTaxValue END AS TaxValue
FROM         dbo.tbInvoice INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
WHERE     (dbo.tbInvoice.InvoiceStatusCode = 2) OR
                      (dbo.tbInvoice.InvoiceStatusCode = 3)
GO
CREATE VIEW dbo.vwCashSummaryBase
AS
SELECT     ISNULL(SUM(ToCollect), 0) AS Collect, ISNULL(SUM(ToPay), 0) AS Pay, ISNULL(SUM(TaxValue), 0) + dbo.fnSystemVatBalance() AS Tax, 
                      dbo.fnCashCompanyBalance() AS CompanyBalance
FROM         dbo.vwCashSummaryInvoices
GO
CREATE VIEW dbo.vwCashSummary
AS
SELECT     GETDATE() AS Timstamp, Collect, Pay, Tax, CompanyBalance AS Cash, CompanyBalance + Collect - Pay - Tax AS Balance
FROM         dbo.vwCashSummaryBase
GO
CREATE VIEW dbo.vwOrgMailContacts
AS
SELECT     AccountCode, ContactName, NickName, NameTitle + N' ' + ContactName AS FormalName, JobTitle, Department
FROM         dbo.tbOrgContact
WHERE     (OnMailingList <> 0)
GO
CREATE VIEW dbo.vwOrgAddresses
AS
SELECT     TOP 100 PERCENT dbo.tbOrg.AccountName, dbo.tbOrgAddress.Address, dbo.tbOrg.OrganisationTypeCode, dbo.tbOrg.OrganisationStatusCode, 
                      dbo.tbOrgType.OrganisationType, dbo.tbOrgStatus.OrganisationStatus, dbo.vwOrgMailContacts.ContactName, dbo.vwOrgMailContacts.NickName, 
                      dbo.vwOrgMailContacts.FormalName, dbo.vwOrgMailContacts.JobTitle, dbo.vwOrgMailContacts.Department
FROM         dbo.tbOrg INNER JOIN
                      dbo.tbOrgAddress ON dbo.tbOrg.AddressCode = dbo.tbOrgAddress.AddressCode INNER JOIN
                      dbo.tbOrgType ON dbo.tbOrg.OrganisationTypeCode = dbo.tbOrgType.OrganisationTypeCode INNER JOIN
                      dbo.tbOrgStatus ON dbo.tbOrg.OrganisationStatusCode = dbo.tbOrgStatus.OrganisationStatusCode LEFT OUTER JOIN
                      dbo.vwOrgMailContacts ON dbo.tbOrg.AccountCode = dbo.vwOrgMailContacts.AccountCode
ORDER BY dbo.tbOrg.AccountName
GO
CREATE VIEW [dbo].[vwOrgBalanceOutstanding]
AS
SELECT     dbo.tbInvoice.AccountCode, SUM(CASE dbo.tbInvoiceType.CashModeCode WHEN 1 THEN ((InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue)) 
                      * - 1 WHEN 2 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) END) AS Balance
FROM         dbo.tbInvoice INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
WHERE     (dbo.tbInvoice.InvoiceStatusCode > 1 AND dbo.tbInvoice.InvoiceStatusCode < 4)
GROUP BY dbo.tbInvoice.AccountCode
GO
CREATE VIEW [dbo].[vwUserCredentials]
AS
SELECT     UserId, UserName, LogonName, Administrator
FROM         dbo.tbUser
WHERE     (LogonName = SUSER_SNAME())
GO
CREATE VIEW [dbo].[vwTaskBucket]
AS
SELECT     TaskCode, dbo.fnSystemDateBucket(GETDATE(), ActionOn) AS Period
FROM         dbo.tbTask
GO
CREATE VIEW [dbo].[vwCashActiveYears]
AS
SELECT     TOP 100 PERCENT dbo.tbSystemYear.YearNumber, dbo.tbSystemYear.Description, dbo.tbCashStatus.CashStatus
FROM         dbo.tbSystemYear INNER JOIN
                      dbo.tbCashStatus ON dbo.tbSystemYear.CashStatusCode = dbo.tbCashStatus.CashStatusCode
WHERE     (dbo.tbSystemYear.CashStatusCode < 4)
ORDER BY dbo.tbSystemYear.YearNumber
GO
CREATE VIEW [dbo].[vwTaskCashMode]
AS
SELECT     dbo.tbTask.TaskCode, CASE WHEN tbCashCategory.CategoryCode IS NULL 
                      THEN tbOrgType.CashModeCode ELSE tbCashCategory.CashModeCode END AS CashModeCode
FROM         dbo.tbTask INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode INNER JOIN
                      dbo.tbOrg ON dbo.tbTask.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbOrgType ON dbo.tbOrg.OrganisationTypeCode = dbo.tbOrgType.OrganisationTypeCode
GO
CREATE VIEW [dbo].[vwTasks]
AS
SELECT     dbo.tbTask.TaskCode, dbo.tbTask.UserId, dbo.tbTask.AccountCode, dbo.tbTask.ContactName, dbo.tbTask.ActivityCode, dbo.tbTask.TaskTitle, 
                      dbo.tbTask.TaskStatusCode, dbo.tbTask.ActionById, dbo.tbTask.ActionOn, dbo.tbTask.ActionedOn, dbo.tbTask.TaskNotes, dbo.tbTask.Quantity, 
                      dbo.tbTask.UnitCharge, dbo.tbTask.TotalCharge, dbo.tbTask.AddressCodeFrom, dbo.tbTask.AddressCodeTo, dbo.tbTask.Printed, 
                      dbo.tbTask.InsertedBy, dbo.tbTask.InsertedOn, dbo.tbTask.UpdatedBy, dbo.tbTask.UpdatedOn, dbo.vwTaskBucket.Period, 
                      dbo.tbSystemBucket.BucketId, dbo.tbTaskStatus.TaskStatus, dbo.tbTask.CashCode, dbo.tbCashCode.CashDescription, 
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
CREATE VIEW [dbo].[vwCashPeriods]
AS
SELECT     dbo.tbCashCode.CashCode, dbo.tbSystemYearPeriod.StartOn
FROM         dbo.tbSystemYearPeriod CROSS JOIN
                      dbo.tbCashCode
GO
CREATE VIEW dbo.vwCashFlowNITotals
AS
SELECT     dbo.tbCashPeriod.StartOn, SUM(dbo.tbCashPeriod.ForecastTax) AS ForecastNI, SUM(dbo.tbCashPeriod.CashTax) AS CashNI, 
                      SUM(dbo.tbCashPeriod.InvoiceTax) AS InvoiceNI
FROM         dbo.tbCashPeriod INNER JOIN
                      dbo.tbCashCode ON dbo.tbCashPeriod.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbCashCode.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 3)
GROUP BY dbo.tbCashPeriod.StartOn
GO
CREATE VIEW dbo.vwCashFlowVatTotalsBase
AS
SELECT     dbo.tbCashPeriod.StartOn, dbo.tbCashCategory.CashModeCode, 
                      CASE WHEN tbCashCategory.CashModeCode = 2 THEN SUM(dbo.tbCashPeriod.ForecastTax) ELSE SUM(dbo.tbCashPeriod.ForecastTax) 
                      * - 1 END AS ForecastVat, CASE WHEN tbCashCategory.CashModeCode = 2 THEN SUM(dbo.tbCashPeriod.CashTax) 
                      ELSE SUM(dbo.tbCashPeriod.CashTax) * - 1 END AS CashVat, 
                      CASE WHEN tbCashCategory.CashModeCode = 2 THEN SUM(dbo.tbCashPeriod.InvoiceTax) ELSE SUM(dbo.tbCashPeriod.InvoiceTax) 
                      * - 1 END AS InvoiceVat
FROM         dbo.tbCashPeriod INNER JOIN
                      dbo.tbCashCode ON dbo.tbCashPeriod.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbCashCode.TaxCode = dbo.tbSystemTaxCode.TaxCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 2)
GROUP BY dbo.tbCashPeriod.StartOn, dbo.tbCashCategory.CashModeCode
GO
CREATE VIEW [dbo].[vwCashMonthList]
AS
SELECT DISTINCT 
                      TOP 100 PERCENT CAST(dbo.tbSystemYearPeriod.StartOn AS float) AS StartOn, dbo.tbSystemMonth.MonthName, 
                      dbo.tbSystemYearPeriod.MonthNumber
FROM         dbo.tbSystemYearPeriod INNER JOIN
                      dbo.fnSystemActivePeriod() AS fnSystemActivePeriod ON dbo.tbSystemYearPeriod.YearNumber = fnSystemActivePeriod.YearNumber INNER JOIN
                      dbo.tbSystemMonth ON dbo.tbSystemYearPeriod.MonthNumber = dbo.tbSystemMonth.MonthNumber
ORDER BY StartOn
GO
CREATE VIEW [dbo].[vwCashPolarData]
AS
SELECT     dbo.tbCashPeriod.CashCode, dbo.tbCashCategory.CashTypeCode, dbo.tbCashPeriod.StartOn, dbo.tbCashPeriod.ForecastValue, 
                      dbo.tbCashPeriod.ForecastTax, dbo.tbCashPeriod.CashValue, dbo.tbCashPeriod.CashTax, dbo.tbCashPeriod.InvoiceValue, 
                      dbo.tbCashPeriod.InvoiceTax
FROM         dbo.tbCashPeriod INNER JOIN
                      dbo.tbCashCode ON dbo.tbCashPeriod.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.tbCashPeriod.StartOn = dbo.tbSystemYearPeriod.StartOn INNER JOIN
                      dbo.tbSystemYear ON dbo.tbSystemYearPeriod.YearNumber = dbo.tbSystemYear.YearNumber INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode
WHERE     (dbo.tbSystemYear.CashStatusCode < 4)
GO
CREATE VIEW [dbo].[vwInvoiceRegister]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoice.InvoiceNumber, dbo.tbInvoice.AccountCode, dbo.tbInvoice.InvoiceTypeCode, 
                      dbo.tbInvoice.InvoiceStatusCode, dbo.tbInvoice.InvoicedOn, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoice.InvoiceValue * - 1 ELSE dbo.tbInvoice.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoice.TaxValue * - 1 ELSE dbo.tbInvoice.TaxValue END AS TaxValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoice.PaidValue * - 1 ELSE dbo.tbInvoice.PaidValue END AS PaidValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoice.PaidTaxValue * - 1 ELSE dbo.tbInvoice.PaidTaxValue END AS PaidTaxValue, 
                      dbo.tbInvoice.PaymentTerms, dbo.tbInvoice.Notes, dbo.tbInvoice.Printed, dbo.tbOrg.AccountName, dbo.tbUser.UserName, 
                      dbo.tbInvoiceStatus.InvoiceStatus, dbo.tbInvoiceType.CashModeCode, dbo.tbInvoiceType.InvoiceType
FROM         dbo.tbInvoice INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode INNER JOIN
                      dbo.tbInvoiceStatus ON dbo.tbInvoice.InvoiceStatusCode = dbo.tbInvoiceStatus.InvoiceStatusCode INNER JOIN
                      dbo.tbUser ON dbo.tbInvoice.UserId = dbo.tbUser.UserId
GO
CREATE VIEW [dbo].[vwCashFlowActualData]
AS
SELECT     dbo.vwCashPolarData.CashCode, dbo.vwCashPolarData.CashTypeCode, dbo.vwCashPolarData.StartOn, dbo.vwCashPolarData.CashValue, 
                      dbo.vwCashPolarData.CashTax, dbo.vwCashPolarData.InvoiceValue, dbo.vwCashPolarData.InvoiceTax, dbo.vwCashPolarData.ForecastValue, 
                      dbo.vwCashPolarData.ForecastTax
FROM         dbo.vwCashPolarData INNER JOIN
                      dbo.fnSystemActivePeriod() fnSystemActivePeriod ON dbo.vwCashPolarData.StartOn < fnSystemActivePeriod.StartOn
GO
CREATE VIEW [dbo].[vwCashFlowForecastData]
AS
SELECT     dbo.vwCashPolarData.CashCode, dbo.vwCashPolarData.CashTypeCode, dbo.vwCashPolarData.StartOn, dbo.vwCashPolarData.ForecastValue, 
                      dbo.vwCashPolarData.ForecastTax
FROM         dbo.vwCashPolarData INNER JOIN
                      dbo.fnSystemActivePeriod() fnSystemActivePeriod ON dbo.vwCashPolarData.StartOn >= fnSystemActivePeriod.StartOn
GO
CREATE VIEW dbo.vwCashFlowVatTotals
AS
SELECT     StartOn, SUM(ForecastVat) AS ForecastVat, SUM(CashVat) AS CashVat, SUM(InvoiceVat) AS InvoiceVat
FROM         dbo.vwCashFlowVatTotalsBase
GROUP BY StartOn
GO
CREATE VIEW [dbo].[vwCashFlowData]
AS
SELECT     CashCode, CashTypeCode, StartOn, CashValue, CashTax, InvoiceValue, InvoiceTax, ForecastValue, ForecastTax
FROM         dbo.vwCashFlowActualData
UNION
SELECT     CashCode, CashTypeCode, StartOn, ForecastValue AS CashValue, ForecastTax AS CashTax, ForecastValue AS InvoiceValue, 
                      ForecastTax AS InvoiceTax, ForecastValue, ForecastTax
FROM         dbo.vwCashFlowForecastData
GO
CREATE VIEW [dbo].[vwCashEmployerNITotals]
AS
SELECT     dbo.vwCashFlowData.StartOn, SUM(dbo.vwCashFlowData.CashTax) AS CashTaxNI, SUM(dbo.vwCashFlowData.InvoiceTax) AS InvoiceTaxNI
FROM         dbo.vwCashFlowData INNER JOIN
                      dbo.tbCashCode ON dbo.vwCashFlowData.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbCashCode.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 3)
GROUP BY dbo.vwCashFlowData.StartOn
GO
CREATE VIEW dbo.vwCashAccountStatement
AS
SELECT     dbo.tbOrgPayment.PaymentCode, dbo.tbOrgPayment.CashAccountCode, dbo.tbUser.UserName, dbo.tbOrgPayment.AccountCode, 
                      dbo.tbOrg.AccountName, dbo.tbOrgPayment.CashCode, dbo.tbCashCode.CashDescription, dbo.tbSystemTaxCode.TaxDescription, 
                      dbo.tbOrgPayment.PaidOn, dbo.tbOrgPayment.PaidInValue, dbo.tbOrgPayment.PaidOutValue, dbo.tbOrgPayment.TaxInValue, 
                      dbo.tbOrgPayment.TaxOutValue, dbo.tbOrgPayment.PaymentReference, dbo.tbOrgPayment.InsertedBy, dbo.tbOrgPayment.InsertedOn, 
                      dbo.tbOrgPayment.UpdatedBy, dbo.tbOrgPayment.UpdatedOn, dbo.tbOrgPayment.TaxCode
FROM         dbo.tbOrgPayment INNER JOIN
                      dbo.tbUser ON dbo.tbOrgPayment.UserId = dbo.tbUser.UserId INNER JOIN
                      dbo.tbOrg ON dbo.tbOrgPayment.AccountCode = dbo.tbOrg.AccountCode LEFT OUTER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbOrgPayment.TaxCode = dbo.tbSystemTaxCode.TaxCode LEFT OUTER JOIN
                      dbo.tbCashCode ON dbo.tbOrgPayment.CashCode = dbo.tbCashCode.CashCode
GO
CREATE VIEW dbo.vwCashAccountStatements
AS
SELECT     TOP 100 PERCENT fnCashAccountStatements.CashAccountCode, dbo.fnAccountPeriod(fnCashAccountStatements.PaidOn) AS StartOn, 
                      fnCashAccountStatements.EntryNumber, fnCashAccountStatements.PaymentCode, fnCashAccountStatements.PaidOn, 
                      dbo.vwCashAccountStatement.AccountName, dbo.vwCashAccountStatement.PaymentReference, dbo.vwCashAccountStatement.PaidInValue, 
                      dbo.vwCashAccountStatement.PaidOutValue, fnCashAccountStatements.PaidBalance, dbo.vwCashAccountStatement.TaxInValue, 
                      dbo.vwCashAccountStatement.TaxOutValue, fnCashAccountStatements.TaxedBalance, dbo.vwCashAccountStatement.CashCode, 
                      dbo.vwCashAccountStatement.CashDescription, dbo.vwCashAccountStatement.TaxDescription, dbo.vwCashAccountStatement.UserName, 
                      dbo.vwCashAccountStatement.AccountCode, dbo.vwCashAccountStatement.TaxCode
FROM         dbo.fnCashAccountStatements() fnCashAccountStatements LEFT OUTER JOIN
                      dbo.vwCashAccountStatement ON fnCashAccountStatements.PaymentCode = dbo.vwCashAccountStatement.PaymentCode
ORDER BY fnCashAccountStatements.CashAccountCode, fnCashAccountStatements.EntryNumber
GO
CREATE VIEW dbo.vwCashAccountLastPeriodEntry
AS
SELECT     CashAccountCode, StartOn, MAX(EntryNumber) AS LastEntry
FROM         dbo.vwCashAccountStatements
GROUP BY CashAccountCode, StartOn
HAVING      (NOT (StartOn IS NULL))
GO
CREATE VIEW dbo.vwCashAccountPeriodClosingBalance
AS
SELECT     dbo.tbOrgAccount.CashCode, dbo.vwCashAccountLastPeriodEntry.StartOn, SUM(dbo.vwCashAccountStatements.PaidBalance) 
                      + SUM(dbo.vwCashAccountStatements.TaxedBalance) AS ClosingBalance
FROM         dbo.vwCashAccountLastPeriodEntry INNER JOIN
                      dbo.vwCashAccountStatements ON dbo.vwCashAccountLastPeriodEntry.CashAccountCode = dbo.vwCashAccountStatements.CashAccountCode AND 
                      dbo.vwCashAccountLastPeriodEntry.StartOn = dbo.vwCashAccountStatements.StartOn AND 
                      dbo.vwCashAccountLastPeriodEntry.LastEntry = dbo.vwCashAccountStatements.EntryNumber INNER JOIN
                      dbo.tbOrgAccount ON dbo.vwCashAccountLastPeriodEntry.CashAccountCode = dbo.tbOrgAccount.CashAccountCode
GROUP BY dbo.tbOrgAccount.CashCode, dbo.vwCashAccountLastPeriodEntry.StartOn
GO
CREATE VIEW dbo.vwCashAccountRebuild
AS
SELECT     dbo.tbOrgPayment.CashAccountCode, dbo.tbOrgAccount.OpeningBalance, 
                      dbo.tbOrgAccount.OpeningBalance + SUM(dbo.tbOrgPayment.PaidInValue - dbo.tbOrgPayment.PaidOutValue) AS CurrentBalance
FROM         dbo.tbOrgPayment INNER JOIN
                      dbo.tbOrgAccount ON dbo.tbOrgPayment.CashAccountCode = dbo.tbOrgAccount.CashAccountCode
WHERE     (dbo.tbOrgPayment.PaymentStatusCode > 1)
GROUP BY dbo.tbOrgPayment.CashAccountCode, dbo.tbOrgAccount.OpeningBalance
GO
CREATE VIEW dbo.vwCashCodeForecastSummary
AS
SELECT     dbo.tbTask.CashCode, dbo.fnAccountPeriod(dbo.tbTask.ActionOn) AS StartOn, SUM(dbo.tbTask.TotalCharge) AS ForecastValue, 
                      SUM(dbo.tbTask.TotalCharge * ISNULL(dbo.tbSystemTaxCode.TaxRate, 0)) AS ForecastTax
FROM         dbo.tbTask INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode LEFT OUTER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbTask.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE     (dbo.tbTask.ActionOn >= dbo.fnSystemActiveStartOn())
GROUP BY dbo.tbTask.CashCode, dbo.fnAccountPeriod(dbo.tbTask.ActionOn)
GO
CREATE VIEW dbo.vwInvoiceRegisterTasks
AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoice.InvoiceNumber, dbo.tbInvoiceTask.TaskCode, dbo.tbCashCode.CashCode, 
                      dbo.tbCashCode.CashDescription, dbo.tbInvoiceTask.TaxCode, dbo.tbSystemTaxCode.TaxDescription, dbo.tbInvoice.AccountCode, 
                      dbo.tbInvoice.InvoiceTypeCode, dbo.tbInvoice.InvoiceStatusCode, dbo.tbInvoice.InvoicedOn, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.InvoiceValue * - 1 ELSE dbo.tbInvoiceTask.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.TaxValue * - 1 ELSE dbo.tbInvoiceTask.TaxValue END AS TaxValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.PaidValue * - 1 ELSE dbo.tbInvoiceTask.PaidValue END AS PaidValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.PaidTaxValue * - 1 ELSE dbo.tbInvoiceTask.PaidTaxValue END AS PaidTaxValue,
                       dbo.tbInvoice.PaymentTerms, dbo.tbInvoice.Printed, dbo.tbOrg.AccountName, dbo.tbUser.UserName, dbo.tbInvoiceStatus.InvoiceStatus, 
                      dbo.tbInvoiceType.CashModeCode, dbo.tbInvoiceType.InvoiceType
FROM         dbo.tbInvoice INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode INNER JOIN
                      dbo.tbInvoiceStatus ON dbo.tbInvoice.InvoiceStatusCode = dbo.tbInvoiceStatus.InvoiceStatusCode INNER JOIN
                      dbo.tbUser ON dbo.tbInvoice.UserId = dbo.tbUser.UserId INNER JOIN
                      dbo.tbInvoiceTask ON dbo.tbInvoice.InvoiceNumber = dbo.tbInvoiceTask.InvoiceNumber INNER JOIN
                      dbo.tbCashCode ON dbo.tbInvoiceTask.CashCode = dbo.tbCashCode.CashCode LEFT OUTER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbInvoiceTask.TaxCode = dbo.tbSystemTaxCode.TaxCode
GO
CREATE VIEW dbo.vwInvoiceRegisterItems
AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoice.InvoiceNumber, dbo.tbInvoiceItem.CashCode AS TaskCode, 
                      dbo.tbCashCode.CashCode, dbo.tbCashCode.CashDescription, dbo.tbInvoiceItem.TaxCode, dbo.tbSystemTaxCode.TaxDescription, 
                      dbo.tbInvoice.AccountCode, dbo.tbInvoice.InvoiceTypeCode, dbo.tbInvoice.InvoiceStatusCode, dbo.tbInvoice.InvoicedOn, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.InvoiceValue * - 1 ELSE dbo.tbInvoiceItem.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.TaxValue * - 1 ELSE dbo.tbInvoiceItem.TaxValue END AS TaxValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.PaidValue * - 1 ELSE dbo.tbInvoiceItem.PaidValue END AS PaidValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.PaidTaxValue * - 1 ELSE dbo.tbInvoiceItem.PaidTaxValue END AS PaidTaxValue,
                       dbo.tbInvoice.PaymentTerms, dbo.tbInvoice.Printed, dbo.tbOrg.AccountName, dbo.tbUser.UserName, dbo.tbInvoiceStatus.InvoiceStatus, 
                      dbo.tbInvoiceType.CashModeCode, dbo.tbInvoiceType.InvoiceType
FROM         dbo.tbInvoice INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode INNER JOIN
                      dbo.tbInvoiceStatus ON dbo.tbInvoice.InvoiceStatusCode = dbo.tbInvoiceStatus.InvoiceStatusCode INNER JOIN
                      dbo.tbUser ON dbo.tbInvoice.UserId = dbo.tbUser.UserId INNER JOIN
                      dbo.tbInvoiceItem ON dbo.tbInvoice.InvoiceNumber = dbo.tbInvoiceItem.InvoiceNumber INNER JOIN
                      dbo.tbCashCode ON dbo.tbInvoiceItem.CashCode = dbo.tbCashCode.CashCode LEFT OUTER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbInvoiceItem.TaxCode = dbo.tbSystemTaxCode.TaxCode
GO
CREATE VIEW dbo.vwInvoiceRegisterDetail
AS
SELECT     *
FROM         vwInvoiceRegisterTasks
UNION
SELECT     *
FROM         vwInvoiceRegisterItems
GO
CREATE VIEW dbo.vwOrgInvoiceItems
AS
SELECT     dbo.tbInvoice.AccountCode, dbo.tbInvoiceItem.CashCode, dbo.tbInvoice.InvoicedOn, dbo.tbInvoiceItem.InvoiceNumber, '' AS TaskCode, 
                      CASE WHEN InvoiceTypeCode = 1 OR
                      InvoiceTypeCode = 4 THEN tbInvoiceItem.InvoiceValue ELSE tbInvoiceItem.InvoiceValue * - 1 END AS InvoiceValue, 
                      CASE WHEN InvoiceTypeCode = 1 OR
                      InvoiceTypeCode = 4 THEN tbInvoiceItem.TaxValue ELSE tbInvoiceItem.TaxValue * - 1 END AS TaxValue
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber
GO
CREATE VIEW dbo.vwOrgInvoiceTasks
AS
SELECT     dbo.tbInvoice.AccountCode, dbo.tbInvoiceTask.CashCode, dbo.tbInvoice.InvoicedOn, dbo.tbInvoiceTask.InvoiceNumber, 
                      dbo.tbInvoiceTask.TaskCode AS TaskCode, CASE WHEN InvoiceTypeCode = 1 OR
                      InvoiceTypeCode = 4 THEN tbInvoiceTask.InvoiceValue ELSE tbInvoiceTask.InvoiceValue * - 1 END AS InvoiceValue, 
                      CASE WHEN InvoiceTypeCode = 1 OR
                      InvoiceTypeCode = 4 THEN tbInvoiceTask.TaxValue ELSE tbInvoiceTask.TaxValue * - 1 END AS TaxValue
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber
GO
CREATE VIEW dbo.vwOrgInvoices
AS
SELECT     AccountCode, CashCode, InvoicedOn, InvoiceNumber, TaskCode, InvoiceValue, TaxValue
FROM         dbo.vwOrgInvoiceTasks
UNION
SELECT     AccountCode, CashCode, InvoicedOn, InvoiceNumber, TaskCode, InvoiceValue, TaxValue
FROM         dbo.vwOrgInvoiceItems
GO
CREATE VIEW dbo.vwCashCodeInvoiceSummary
AS
SELECT     CashCode, StartOn, ABS(SUM(InvoiceValue)) AS InvoiceValue, ABS(SUM(TaxValue)) AS TaxValue
FROM         dbo.vwInvoiceRegisterDetail
GROUP BY StartOn, CashCode
GO
CREATE VIEW dbo.vwCashCodePaymentSummary
AS
SELECT     CashCode, dbo.fnAccountPeriod(PaidOn) AS StartOn, SUM(PaidInValue + PaidOutValue) AS CashValue, SUM(TaxInValue + TaxOutValue) 
                      AS CashTax
FROM         dbo.tbOrgPayment
GROUP BY CashCode, dbo.fnAccountPeriod(PaidOn)
GO
CREATE VIEW dbo.vwInvoiceOutstandingItems
AS
SELECT     InvoiceNumber, '' AS TaskCode, CashCode, TaxCode, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS OutstandingValue, 
                      CASE WHEN InvoiceValue = 0 THEN 0 ELSE TaxValue / InvoiceValue END AS TaxRate
FROM         dbo.tbInvoiceItem
GO
CREATE VIEW dbo.vwInvoiceOutstandingTasks
AS
SELECT     InvoiceNumber, TaskCode, CashCode, TaxCode, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS OutstandingValue, 
                      CASE WHEN InvoiceValue = 0 THEN 0 ELSE TaxValue / InvoiceValue END AS TaxRate
FROM         dbo.tbInvoiceTask
GO
CREATE VIEW dbo.vwInvoiceOutstandingBase
AS
SELECT     *
FROM         dbo.vwInvoiceOutstandingItems
UNION
SELECT     *
FROM         dbo.vwInvoiceOutstandingTasks
GO
CREATE VIEW dbo.vwInvoiceOutstanding
AS
SELECT     TOP 100 PERCENT dbo.tbInvoice.AccountCode, dbo.tbInvoice.InvoicedOn, dbo.tbInvoice.InvoiceNumber, dbo.vwInvoiceOutstandingBase.TaskCode, 
                      dbo.tbInvoice.InvoiceStatusCode, dbo.tbInvoiceType.CashModeCode, dbo.vwInvoiceOutstandingBase.CashCode, 
                      dbo.vwInvoiceOutstandingBase.TaxCode, dbo.vwInvoiceOutstandingBase.TaxRate, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN OutstandingValue * - 1 ELSE OutstandingValue END AS ItemValue
FROM         dbo.vwInvoiceOutstandingBase INNER JOIN
                      dbo.tbInvoice ON dbo.vwInvoiceOutstandingBase.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
WHERE     (dbo.tbInvoice.InvoiceStatusCode = 2 OR
                      dbo.tbInvoice.InvoiceStatusCode = 3)
GO
CREATE VIEW [dbo].[vwInvoiceSummaryItems]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN tbInvoice.InvoiceTypeCode = 2 THEN 1 ELSE CASE WHEN tbInvoice.InvoiceTypeCode = 4 THEN 3 ELSE tbInvoice.InvoiceTypeCode END END
                       AS InvoiceTypeCode, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.InvoiceValue * - 1 ELSE dbo.tbInvoiceItem.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.TaxValue * - 1 ELSE dbo.tbInvoiceItem.TaxValue END AS TaxValue
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
GO
CREATE VIEW [dbo].[vwInvoiceSummaryTasks]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN tbInvoice.InvoiceTypeCode = 2 THEN 1 ELSE CASE WHEN tbInvoice.InvoiceTypeCode = 4 THEN 3 ELSE tbInvoice.InvoiceTypeCode END END
                       AS InvoiceTypeCode, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.InvoiceValue * - 1 ELSE dbo.tbInvoiceTask.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.TaxValue * - 1 ELSE dbo.tbInvoiceTask.TaxValue END AS TaxValue
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
GO
CREATE VIEW [dbo].[vwInvoiceSummaryBase]
AS
SELECT  *   
FROM   dbo.vwInvoiceSummaryTasks
UNION
SELECT *
FROM dbo.vwInvoiceSummaryItems   
GO
CREATE VIEW [dbo].[vwInvoiceSummaryTotals]
AS
SELECT     dbo.vwInvoiceSummaryBase.StartOn, dbo.vwInvoiceSummaryBase.InvoiceTypeCode, dbo.tbInvoiceType.InvoiceType, 
                      SUM(dbo.vwInvoiceSummaryBase.InvoiceValue) AS TotalInvoiceValue, SUM(dbo.vwInvoiceSummaryBase.TaxValue) AS TotalTaxValue
FROM         dbo.vwInvoiceSummaryBase INNER JOIN
                      dbo.tbInvoiceType ON dbo.vwInvoiceSummaryBase.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
GROUP BY dbo.vwInvoiceSummaryBase.StartOn, dbo.vwInvoiceSummaryBase.InvoiceTypeCode, dbo.tbInvoiceType.InvoiceType
GO
CREATE VIEW [dbo].[vwInvoiceSummaryMargin]
AS
SELECT     StartOn, 5 AS InvoiceTypeCode, dbo.fnSystemProfileText(3004) AS InvoiceType, SUM(TotalInvoiceValue) AS TotalInvoiceValue, SUM(TotalTaxValue) 
                      AS TotalTaxValue
FROM         dbo.vwInvoiceSummaryTotals
GROUP BY StartOn
GO
CREATE VIEW [dbo].[vwInvoiceSummary]
AS
SELECT     DATENAME(yyyy, StartOn) + '/' + CAST(dbo.fnPad(MONTH(StartOn), 2) AS nvarchar) AS PeriodOn, StartOn, InvoiceTypeCode, InvoiceType, 
                      ABS(TotalInvoiceValue) AS TotalInvoiceValue, ABS(TotalTaxValue) AS TotalTaxValue
FROM         dbo.vwInvoiceSummaryTotals
UNION
SELECT     DATENAME(yyyy, StartOn) + '/' + CAST(dbo.fnPad(MONTH(StartOn), 2) AS nvarchar) AS PeriodOn, StartOn, InvoiceTypeCode, InvoiceType, TotalInvoiceValue, 
                      TotalTaxValue
FROM         dbo.vwInvoiceSummaryMargin
GO
CREATE VIEW [dbo].[vwInvoiceTaxBase]
AS
SELECT     InvoiceNumber, TaxCode, SUM(InvoiceValue) AS InvoiceValueTotal, SUM(TaxValue) AS TaxValueTotal
FROM         dbo.tbInvoiceItem
GROUP BY InvoiceNumber, TaxCode
HAVING      (NOT (TaxCode IS NULL))
UNION
SELECT     InvoiceNumber, TaxCode, SUM(InvoiceValue) AS InvoiceValueTotal, SUM(TaxValue) AS TaxValueTotal
FROM         dbo.tbInvoiceTask
GROUP BY InvoiceNumber, TaxCode
HAVING      (NOT (TaxCode IS NULL))
GO
CREATE VIEW [dbo].[vwInvoiceTaxSummary]
AS
SELECT     InvoiceNumber, TaxCode, SUM(InvoiceValueTotal) AS InvoiceValueTotal, SUM(TaxValueTotal) AS TaxValueTotal, SUM(TaxValueTotal) 
                      / SUM(InvoiceValueTotal) AS TaxRate
FROM         dbo.vwInvoiceTaxBase
GROUP BY InvoiceNumber, TaxCode
GO
CREATE VIEW dbo.vwInvoiceVatItems
AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoice.InvoiceTypeCode, dbo.tbInvoiceItem.TaxCode, 
                      dbo.tbInvoiceItem.InvoiceValue, dbo.tbInvoiceItem.TaxValue, dbo.tbOrg.ForeignJurisdiction
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbInvoiceItem.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 2)
GO
CREATE VIEW [dbo].[vwInvoiceVatTasks]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoice.InvoiceTypeCode, dbo.tbInvoiceTask.TaxCode, 
                      dbo.tbInvoiceTask.InvoiceValue, dbo.tbInvoiceTask.TaxValue, dbo.tbOrg.ForeignJurisdiction
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbInvoiceTask.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 2)
GO
CREATE VIEW [dbo].[vwInvoiceVatBase]
AS
SELECT     *
FROM         dbo.vwInvoiceVatTasks
UNION
SELECT     *
FROM         dbo.vwInvoiceVatItems
GO
CREATE VIEW [dbo].[vwInvoiceVatDetail]
AS
SELECT     StartOn, TaxCode, 
                      CASE WHEN vwInvoiceVatBase.ForeignJurisdiction = 0 THEN CASE vwInvoiceVatBase.InvoiceTypeCode WHEN 1 THEN vwInvoiceVatBase.InvoiceValue
                       WHEN 2 THEN vwInvoiceVatBase.InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomeSales, 
                      CASE WHEN vwInvoiceVatBase.ForeignJurisdiction = 0 THEN CASE vwInvoiceVatBase.InvoiceTypeCode WHEN 3 THEN vwInvoiceVatBase.InvoiceValue
                       WHEN 4 THEN vwInvoiceVatBase.InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomePurchases, 
                      CASE WHEN vwInvoiceVatBase.ForeignJurisdiction != 0 THEN CASE vwInvoiceVatBase.InvoiceTypeCode WHEN 1 THEN vwInvoiceVatBase.InvoiceValue
                       WHEN 2 THEN vwInvoiceVatBase.InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportSales, 
                      CASE WHEN vwInvoiceVatBase.ForeignJurisdiction != 0 THEN CASE vwInvoiceVatBase.InvoiceTypeCode WHEN 3 THEN vwInvoiceVatBase.InvoiceValue
                       WHEN 4 THEN vwInvoiceVatBase.InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportPurchases, 
                      CASE WHEN vwInvoiceVatBase.ForeignJurisdiction = 0 THEN CASE vwInvoiceVatBase.InvoiceTypeCode WHEN 1 THEN vwInvoiceVatBase.TaxValue WHEN
                       2 THEN vwInvoiceVatBase.TaxValue * - 1 ELSE 0 END ELSE 0 END AS HomeSalesVat, 
                      CASE WHEN vwInvoiceVatBase.ForeignJurisdiction = 0 THEN CASE vwInvoiceVatBase.InvoiceTypeCode WHEN 3 THEN vwInvoiceVatBase.TaxValue WHEN
                       4 THEN vwInvoiceVatBase.TaxValue * - 1 ELSE 0 END ELSE 0 END AS HomePurchasesVat, 
                      CASE WHEN vwInvoiceVatBase.ForeignJurisdiction != 0 THEN CASE vwInvoiceVatBase.InvoiceTypeCode WHEN 1 THEN vwInvoiceVatBase.TaxValue WHEN
                       2 THEN vwInvoiceVatBase.TaxValue * - 1 ELSE 0 END ELSE 0 END AS ExportSalesVat, 
                      CASE WHEN vwInvoiceVatBase.ForeignJurisdiction != 0 THEN CASE vwInvoiceVatBase.InvoiceTypeCode WHEN 3 THEN vwInvoiceVatBase.TaxValue WHEN
                       4 THEN vwInvoiceVatBase.TaxValue * - 1 ELSE 0 END ELSE 0 END AS ExportPurchasesVat
FROM         dbo.vwInvoiceVatBase
GO
CREATE VIEW [dbo].[vwInvoiceVatSummary]
AS
SELECT     StartOn, TaxCode, SUM(HomeSales) AS HomeSales, SUM(HomePurchases) AS HomePurchases, SUM(ExportSales) AS ExportSales, 
                      SUM(ExportPurchases) AS ExportPurchases, SUM(HomeSalesVat) AS HomeSalesVat, SUM(HomePurchasesVat) AS HomePurchasesVat, 
                      SUM(ExportSalesVat) AS ExportSalesVat, SUM(ExportPurchasesVat) AS ExportPurchasesVat
FROM         dbo.vwInvoiceVatDetail
GROUP BY StartOn, TaxCode
GO
CREATE VIEW [dbo].[vwTaskInvoicedQuantity]
AS
SELECT     dbo.tbInvoiceTask.TaskCode, SUM(dbo.tbInvoiceTask.Quantity) AS InvoiceQuantity
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber
WHERE     (dbo.tbInvoice.InvoiceTypeCode = 1) OR
                      (dbo.tbInvoice.InvoiceTypeCode = 3)
GROUP BY dbo.tbInvoiceTask.TaskCode
GO
CREATE PROCEDURE [dbo].[spActivityNextAttributeOrder] 
	(
	@ActivityCode nvarchar(50),
	@PrintOrder smallint = 10 output
	)
AS
	if exists(SELECT     TOP 1 PrintOrder
	          FROM         tbActivityAttribute
	          WHERE     (ActivityCode = @ActivityCode))
		begin
		SELECT  @PrintOrder = MAX(PrintOrder) 
		FROM         tbActivityAttribute
		WHERE     (ActivityCode = @ActivityCode)
		set @PrintOrder = @PrintOrder - (@PrintOrder % 10) + 10		
		end
	else
		set @PrintOrder = 10
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spActivityNextStepNumber] 
	(
	@ActivityCode nvarchar(50),
	@StepNumber smallint = 10 output
	)
AS
	if exists(SELECT     TOP 1 StepNumber
	          FROM         tbActivityFlow
	          WHERE     (ParentCode = @ActivityCode))
		begin
		SELECT  @StepNumber = MAX(StepNumber) 
		FROM         tbActivityFlow
		WHERE     (ParentCode = @ActivityCode)
		set @StepNumber = @StepNumber - (@StepNumber % 10) + 10		
		end
	else
		set @StepNumber = 10
		
	RETURN
GO
CREATE PROCEDURE dbo.spCashAccountRebuild
	(
	@CashAccountCode nvarchar(10)
	)
AS
	
	UPDATE tbOrgAccount
	SET CurrentBalance = vwCashAccountRebuild.CurrentBalance
	FROM         vwCashAccountRebuild INNER JOIN
						tbOrgAccount ON vwCashAccountRebuild.CashAccountCode = tbOrgAccount.CashAccountCode
	WHERE vwCashAccountRebuild.CashAccountCode = @CashAccountCode 

	UPDATE tbOrgAccount
	SET CurrentBalance = 0
	FROM         vwCashAccountRebuild RIGHT OUTER JOIN
	                      tbOrgAccount ON vwCashAccountRebuild.CashAccountCode = tbOrgAccount.CashAccountCode
	WHERE     (vwCashAccountRebuild.CashAccountCode IS NULL) AND tbOrgAccount.CashAccountCode = @CashAccountCode
										
	RETURN 
GO
CREATE PROCEDURE dbo.spCashAccountRebuildAll
AS
	
	UPDATE tbOrgAccount
	SET CurrentBalance = vwCashAccountRebuild.CurrentBalance
	FROM         vwCashAccountRebuild INNER JOIN
						tbOrgAccount ON vwCashAccountRebuild.CashAccountCode = tbOrgAccount.CashAccountCode
	
	UPDATE tbOrgAccount
	SET CurrentBalance = 0
	FROM         vwCashAccountRebuild RIGHT OUTER JOIN
	                      tbOrgAccount ON vwCashAccountRebuild.CashAccountCode = tbOrgAccount.CashAccountCode
	WHERE     (vwCashAccountRebuild.CashAccountCode IS NULL)

	RETURN
GO
CREATE PROCEDURE dbo.spCashCategoryCashCodes
	(
	@CategoryCode nvarchar(10)
	)
AS
	SELECT     CashCode, CashDescription
	FROM         tbCashCode
	WHERE     (CategoryCode = @CategoryCode)
	ORDER BY CashDescription
	RETURN 
GO
CREATE PROCEDURE dbo.spCashCategoryCodeFromName
	(
		@Category nvarchar(50),
		@CategoryCode nvarchar(10) output
	)
AS
	if exists (SELECT CategoryCode
				FROM         tbCashCategory
				WHERE     (Category = @Category))
		SELECT @CategoryCode = CategoryCode
		FROM         tbCashCategory
		WHERE     (Category = @Category)
	else
		set @CategoryCode = 0
		
	RETURN 
GO
CREATE PROCEDURE [dbo].[spCashCategoryTotals]
	(
	@CashTypeCode smallint
	)
AS

	SELECT     tbCashCategory.DisplayOrder, tbCashCategory.Category, tbCashType.CashType, tbCashCategory.CategoryCode
	FROM         tbCashCategory INNER JOIN
	                      tbCashType ON tbCashCategory.CashTypeCode = tbCashType.CashTypeCode
	WHERE     (tbCashCategory.CashTypeCode = @CashTypeCode) AND (tbCashCategory.CategoryTypeCode = 2)
	ORDER BY tbCashCategory.DisplayOrder, tbCashCategory.Category
	
	RETURN 
GO
CREATE PROCEDURE dbo.spCashCodeDefaults 
	(
	@CashCode nvarchar(50)
	)
AS
	SELECT     tbCashCode.CashCode, tbCashCode.CashDescription, tbCashCode.CategoryCode, tbCashCode.TaxCode, tbCashCode.OpeningBalance, 
	                      ISNULL(tbCashCategory.CashModeCode, 1) AS CashModeCode, tbSystemTaxCode.TaxTypeCode
	FROM         tbCashCode INNER JOIN
	                      tbSystemTaxCode ON tbCashCode.TaxCode = tbSystemTaxCode.TaxCode LEFT OUTER JOIN
	                      tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE     (tbCashCode.CashCode = @CashCode)
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spCashCodeValues]
	(
	@CashCode nvarchar(50),
	@YearNumber smallint
	)
AS
	SELECT     vwCashFlowData.CashValue, vwCashFlowData.CashTax, vwCashFlowData.InvoiceValue, vwCashFlowData.InvoiceTax, 
	                      vwCashFlowData.ForecastValue, vwCashFlowData.ForecastTax
	FROM         tbSystemYearPeriod INNER JOIN
	                      vwCashFlowData ON tbSystemYearPeriod.StartOn = vwCashFlowData.StartOn
	WHERE     (tbSystemYearPeriod.YearNumber = @YearNumber) AND (vwCashFlowData.CashCode = @CashCode)
	ORDER BY vwCashFlowData.StartOn
	
	RETURN 
GO
CREATE PROCEDURE [dbo].[spCashCopyForecastToLiveCashCode]
	(
	@CashCode nvarchar(50),
	@StartOn datetime
	)

AS
	UPDATE tbCashPeriod
	SET     CashValue = ForecastValue, CashTax = ForecastTax, InvoiceValue = ForecastValue, InvoiceTax = ForecastTax
	FROM         tbCashPeriod
	WHERE     (CashCode = @CashCode) AND (StartOn = @StartOn)
	RETURN 
GO
CREATE PROCEDURE dbo.spCashCopyForecastToLiveCategory
	(
	@CategoryCode nvarchar(10),
	@StartOn datetime
	)

AS
	UPDATE tbCashPeriod
	SET     CashValue = ForecastValue, CashTax = ForecastTax, InvoiceValue = ForecastValue, InvoiceTax = ForecastTax
	FROM         tbCashPeriod INNER JOIN
	                      tbCashCode ON tbCashPeriod.CashCode = tbCashCode.CashCode
	WHERE     (tbCashPeriod.StartOn = @StartOn) AND (tbCashCode.CategoryCode = @CategoryCode)
GO
CREATE PROCEDURE dbo.spCashCopyLiveToForecastCashCode
	(
	@CashCode nvarchar(50),
	@Years smallint,
	@UseLastPeriod bit = 0
	)

AS
declare @SystemStartOn datetime
declare @EndPeriod datetime
declare @StartPeriod datetime
declare @CurPeriod datetime
	
declare @InvoiceValue money
declare @InvoiceTax money
declare @CashValue money
declare @CashTax money

	SELECT @CurPeriod = StartOn
	FROM         fnSystemActivePeriod() fnSystemActivePeriod
	
	set @EndPeriod = dateadd(m, -1, @CurPeriod)
	set @StartPeriod = dateadd(m, -11, @EndPeriod)	
	
	SELECT @SystemStartOn = MIN(StartOn)
	FROM         tbSystemYearPeriod
	
	if @StartPeriod < @SystemStartOn 
		set @UseLastPeriod = 1

	if @UseLastPeriod = 0
		goto YearCopyMode
	else
		goto LastMonthCopyMode
		
	return
		
	
YearCopyMode:

	declare curPe cursor for
		SELECT     StartOn, CashValue, CashTax, InvoiceValue, InvoiceTax
		FROM         tbCashPeriod
		WHERE     (StartOn <= @EndPeriod AND StartOn >= @StartPeriod) and (CashCode = @CashCode)
		ORDER BY	CashCode, StartOn	
		
	while @Years > 0
		begin
		open curPe

		fetch next from curPe into @StartPeriod, @CashValue, @CashTax, @InvoiceValue, @InvoiceTax
		while @@FETCH_STATUS = 0
			begin
			if @InvoiceValue = 0
				set @InvoiceValue = @CashValue
			if @InvoiceTax = 0
				set @InvoiceTax = @CashTax
				
			UPDATE tbCashPeriod
			SET
				ForecastValue = @InvoiceValue, 
				ForecastTax = @InvoiceTax
			FROM         tbCashPeriod
			WHERE     (CashCode = @CashCode) AND (StartOn = @CurPeriod)

			SELECT TOP 1 @CurPeriod = StartOn
			FROM tbCashPeriod
			WHERE     (CashCode = @CashCode) AND (StartOn > @CurPeriod)
			ORDER BY StartOn	
			fetch next from curPe into @StartPeriod, @CashValue, @CashTax, @InvoiceValue, @InvoiceTax
			end
		
		set @Years = @Years - 1
		close curPe
		end
		
	deallocate curPe
			
	return 

LastMonthCopyMode:
declare @Idx integer

	SELECT TOP 1 @CashValue = CashValue, @CashTax = CashTax, @InvoiceValue = InvoiceValue, @InvoiceTax = InvoiceTax
	FROM         tbCashPeriod
	WHERE     (CashCode = @CashCode) AND (StartOn < @CurPeriod)
	ORDER BY StartOn DESC
	
	if @InvoiceValue = 0
		set @InvoiceValue = @CashValue
	if @InvoiceTax = 0
		set @InvoiceTax = @CashTax
		
	while @Years > 0
		begin
		set @Idx = 1
		while @Idx <= 12
			begin
			UPDATE tbCashPeriod
			SET
				ForecastValue = @InvoiceValue, 
				ForecastTax = @InvoiceTax
			FROM         tbCashPeriod
			WHERE     (CashCode = @CashCode) AND (StartOn = @CurPeriod)

			SELECT TOP 1 @CurPeriod = StartOn
			FROM tbCashPeriod
			WHERE     (CashCode = @CashCode) AND (StartOn > @CurPeriod)
			ORDER BY StartOn			

			set @Idx = @Idx + 1
			end			
	
		set @Years = @Years - 1
		end


	return
GO
CREATE PROCEDURE dbo.spCashCopyLiveToForecastCategory
	(
	@CategoryCode nvarchar(10),
	@Years smallint,
	@UseLastPeriod bit = 0
	)

AS
declare @CashCode nvarchar(50)

	declare curCc cursor for
	SELECT     CashCode
	FROM         tbCashCode
	WHERE     (CategoryCode = @CategoryCode)
		
	open curCc

	fetch next from curCc into @CashCode
	while @@FETCH_STATUS = 0
		begin
		exec dbo.spCashCopyLiveToForecastCashCode @CashCode, @Years, @UseLastPeriod
		fetch next from curCc into @CashCode
		end
	
	close curCc
		
	deallocate curCc
			
	return 
GO
CREATE PROCEDURE dbo.spCashGeneratePeriods
AS
declare @YearNumber smallint
declare @StartOn datetime
declare @PeriodStartOn datetime
declare @CashStatusCode smallint
declare @Period smallint

	declare curYr cursor for	
		SELECT     YearNumber, CONVERT(datetime, '1/' + STR(StartMonth) + '/' + STR(YearNumber), 103) AS StartOn, CashStatusCode
		FROM         tbSystemYear

	open curYr
	
	fetch next from curYr into @YearNumber, @StartOn, @CashStatusCode
	while @@FETCH_STATUS = 0
		begin
		set @PeriodStartOn = @StartOn
		set @Period = 1
		while @Period < 13
			begin
			if not exists (select MonthNumber from tbSystemYearPeriod where YearNumber = @YearNumber and MonthNumber = datepart(m, @PeriodStartOn))
				begin
				insert into tbSystemYearPeriod (YearNumber, StartOn, MonthNumber, CashStatusCode)
				values (@YearNumber, @PeriodStartOn, datepart(m, @PeriodStartOn), 1)				
				end
			set @PeriodStartOn = dateadd(m, 1, @PeriodStartOn)	
			set @Period = @Period + 1
			end		
				
		fetch next from curYr into @YearNumber, @StartOn, @CashStatusCode
		end
	
	
	close curYr
	deallocate curYr
	
	INSERT INTO tbCashPeriod
	                      (CashCode, StartOn)
	SELECT     vwCashPeriods.CashCode, vwCashPeriods.StartOn
	FROM         vwCashPeriods LEFT OUTER JOIN
	                      tbCashPeriod ON vwCashPeriods.CashCode = tbCashPeriod.CashCode AND vwCashPeriods.StartOn = tbCashPeriod.StartOn
	WHERE     (tbCashPeriod.CashCode IS NULL)
	RETURN 
GO
CREATE PROCEDURE dbo.spCashFlowInitialise
AS
declare @StartOn datetime
		
	exec dbo.spCashGeneratePeriods
	
	select @StartOn = StartOn
	from fnSystemActivePeriod() fnSystemActivePeriod	
	
	UPDATE tbCashPeriod
	SET ForecastValue = 0, ForecastTax = 0
	FROM         tbCashPeriod INNER JOIN
	                      tbCashCode ON tbCashPeriod.CashCode = tbCashCode.CashCode INNER JOIN
	                      tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE     (tbCashCategory.ManualForecast = 0) AND (tbCashPeriod.StartOn >= @StartOn)
	
	UPDATE tbCashPeriod
	SET 
		ForecastValue = vwCashCodeForecastSummary.ForecastValue, 
		ForecastTax = vwCashCodeForecastSummary.ForecastTax
	FROM         tbCashPeriod INNER JOIN
	                      vwCashCodeForecastSummary ON tbCashPeriod.CashCode = vwCashCodeForecastSummary.CashCode AND 
	                      tbCashPeriod.StartOn = vwCashCodeForecastSummary.StartOn INNER JOIN
	                      tbCashCode ON tbCashPeriod.CashCode = tbCashCode.CashCode INNER JOIN
	                      tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE     (tbCashPeriod.StartOn >= @StartOn) AND (tbCashCategory.ManualForecast = 0)
	
	UPDATE tbCashPeriod
	SET ForecastValue = 0, 
	ForecastTax = 0, 
	CashValue = 0, 
	CashTax = 0, 
	InvoiceValue = 0, 
	InvoiceTax = 0
	FROM         tbCashPeriod INNER JOIN
	                      tbSystemOptions ON tbCashPeriod.CashCode = tbSystemOptions.Vat

	UPDATE tbCashPeriod
	SET
		ForecastValue = vwCashFlowVatTotals.ForecastVat, 
		CashValue = vwCashFlowVatTotals.CashVat, 
		InvoiceValue = vwCashFlowVatTotals.InvoiceVat
	FROM         tbCashPeriod INNER JOIN
	                      vwCashFlowVatTotals ON tbCashPeriod.StartOn = vwCashFlowVatTotals.StartOn
	WHERE     (tbCashPeriod.CashCode = dbo.fnSystemCashCode(2))
	
	UPDATE tbCashPeriod
	SET ForecastValue = 0, 
	ForecastTax = 0, 
	CashValue = 0, 
	CashTax = 0, 
	InvoiceValue = 0, 
	InvoiceTax = 0
	FROM         tbCashPeriod INNER JOIN
	                      tbSystemOptions ON tbCashPeriod.CashCode = tbSystemOptions.EmployersNI
	                      	

	UPDATE tbCashPeriod
	SET
		ForecastValue = vwCashFlowNITotals.ForecastNI, 
		CashValue = vwCashFlowNITotals.CashNI, 
		InvoiceValue = vwCashFlowNITotals.InvoiceNI
	FROM         tbCashPeriod INNER JOIN
	                      vwCashFlowNITotals ON tbCashPeriod.StartOn = vwCashFlowNITotals.StartOn
	WHERE     (tbCashPeriod.CashCode = dbo.fnSystemCashCode(3))
	                      
	
	RETURN 
GO
CREATE PROCEDURE dbo.spCashVatBalance
	(
	@Balance money output
	)
AS
	set @Balance = dbo.fnSystemVatBalance()
	RETURN 
GO
CREATE PROCEDURE dbo.spInvoiceCredit
	(
		@InvoiceNumber nvarchar(20) output
	)
AS
declare @InvoiceTypeCode smallint
declare @CreditNumber nvarchar(20)
declare @UserId smallint
declare @NextNumber int
declare @InvoiceSuffix nvarchar(4)

	select @UserId = UserId from vwUserCredentials
	
	select @InvoiceTypeCode = InvoiceTypeCode from tbInvoice where InvoiceNumber = @InvoiceNumber
	
	set @InvoiceTypeCode = case @InvoiceTypeCode when 1 then 2 when 3 then 4 else 4 end
	
	select @UserId = UserId from vwUserCredentials

	set @InvoiceSuffix = '.' + dbo.fnPad(ltrim(str(@UserId)), 3)
	
	select @NextNumber = NextNumber
	from tbInvoiceType
	where InvoiceTypeCode = @InvoiceTypeCode
	
	select @CreditNumber = dbo.fnPad(@NextNumber, 6) + @InvoiceSuffix
	
	while exists (SELECT     InvoiceNumber
	              FROM         tbInvoice
	              WHERE     (InvoiceNumber = @CreditNumber))
		begin
		set @NextNumber = @NextNumber + 1
		set @CreditNumber = dbo.fnPad(@NextNumber, 6) + @InvoiceSuffix
		end
		
	begin tran Credit
	
	exec dbo.spInvoiceCancel
	
	UPDATE    tbInvoiceType
	SET              NextNumber = @NextNumber + 1
	WHERE     (InvoiceTypeCode = @InvoiceTypeCode)	
	
	INSERT INTO tbInvoice
						(InvoiceNumber, InvoiceStatusCode, AccountCode, InvoiceValue, TaxValue, UserId, InvoiceTypeCode, InvoicedOn)
	SELECT     @CreditNumber AS InvoiceNumber, 1 AS InvoiceStatusCode, AccountCode, InvoiceValue, TaxValue, @UserId AS UserId, 
						@InvoiceTypeCode AS InvoiceTypeCode, GETDATE() AS InvoicedOn
	FROM         tbInvoice
	WHERE     (InvoiceNumber = @InvoiceNumber)
	
	INSERT INTO tbInvoiceItem
	                      (InvoiceNumber, CashCode, TaxCode, InvoiceValue, TaxValue)
	SELECT     @CreditNumber AS InvoiceNumber, CashCode, TaxCode, InvoiceValue, TaxValue
	FROM         tbInvoiceItem
	WHERE     (InvoiceNumber = @InvoiceNumber)
	
	INSERT INTO tbInvoiceTask
	                      (InvoiceNumber, TaskCode, Quantity, InvoiceValue, TaxValue, CashCode, TaxCode)
	SELECT     @CreditNumber AS InvoiceNumber, TaskCode, Quantity, InvoiceValue, TaxValue, CashCode, TaxCode
	FROM         tbInvoiceTask
	WHERE     (InvoiceNumber = @InvoiceNumber)

	set @InvoiceNumber = @CreditNumber
	
	commit tran Credit

	
	RETURN 
GO
CREATE PROCEDURE dbo.spInvoiceRaiseBlank
	(
	@AccountCode nvarchar(10),
	@InvoiceTypeCode smallint,
	@InvoiceNumber nvarchar(20) = null output
	)
AS
declare @UserId smallint
declare @NextNumber int
declare @InvoiceSuffix nvarchar(4)

	select @UserId = UserId from vwUserCredentials

	set @InvoiceSuffix = '.' + dbo.fnPad(ltrim(str(@UserId)), 3)
	
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
		
	begin tran InvoiceBlank
	
	exec dbo.spInvoiceCancel
	
	UPDATE    tbInvoiceType
	SET              NextNumber = @NextNumber + 1
	WHERE     (InvoiceTypeCode = @InvoiceTypeCode)
	
	INSERT INTO tbInvoice
	                      (InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoicedOn, InvoiceStatusCode)
	VALUES     (@InvoiceNumber, @UserId, @AccountCode, @InvoiceTypeCode, GETDATE(), 1)

	
	commit tran InvoiceBlank
	
	RETURN
GO
CREATE PROCEDURE dbo.spInvoiceTotal 
	(
	@InvoiceNumber nvarchar(20)
	)
AS
declare @InvoiceValue money
declare @TaxValue money
declare @PaidValue money
declare @PaidTaxValue money

	set @InvoiceValue = 0
	set @TaxValue = 0
	set @PaidValue = 0
	set @PaidTaxValue = 0
	
	UPDATE     tbInvoiceTask
	SET TaxValue = tbInvoiceTask.InvoiceValue * tbSystemTaxCode.TaxRate
	FROM         tbInvoiceTask INNER JOIN
	                      tbSystemTaxCode ON tbInvoiceTask.TaxCode = tbSystemTaxCode.TaxCode
	WHERE     (tbInvoiceTask.InvoiceNumber = @InvoiceNumber)

	UPDATE     tbInvoiceItem
	SET TaxValue = tbInvoiceItem.InvoiceValue * tbSystemTaxCode.TaxRate
	FROM         tbInvoiceItem INNER JOIN
	                      tbSystemTaxCode ON tbInvoiceItem.TaxCode = tbSystemTaxCode.TaxCode
	WHERE     (tbInvoiceItem.InvoiceNumber = @InvoiceNumber)

	SELECT  TOP 1 @InvoiceValue = isnull(SUM(InvoiceValue), 0), 
		@TaxValue = isnull(SUM(TaxValue), 0),
		@PaidValue = isnull(SUM(PaidValue), 0), 
		@PaidTaxValue = isnull(SUM(PaidTaxValue), 0)
	FROM         tbInvoiceTask
	GROUP BY InvoiceNumber
	HAVING      (InvoiceNumber = @InvoiceNumber)
	
	SELECT  TOP 1 @InvoiceValue = @InvoiceValue + isnull(SUM(InvoiceValue), 0), 
		@TaxValue = @TaxValue + isnull(SUM(TaxValue), 0),
		@PaidValue = @PaidValue + isnull(SUM(PaidValue), 0), 
		@PaidTaxValue = @PaidTaxValue + isnull(SUM(PaidTaxValue), 0)
	FROM         tbInvoiceItem
	GROUP BY InvoiceNumber
	HAVING      (InvoiceNumber = @InvoiceNumber)
	
	
	UPDATE    tbInvoice
	SET              InvoiceValue = isnull(@InvoiceValue, 0), TaxValue = isnull(@TaxValue, 0),
		PaidValue = isnull(@PaidValue, 0), PaidTaxValue = isnull(@PaidTaxValue, 0),
		InvoiceStatusCode = CASE 
				WHEN @PaidValue >= @InvoiceValue THEN 4 
				WHEN @PaidValue > 0 THEN 3 
				ELSE 2 END
	WHERE     (InvoiceNumber = @InvoiceNumber)
	
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spInvoiceAccept] 
	(
	@InvoiceNumber nvarchar(20)
	)
AS

		if exists(SELECT     InvoiceNumber
	          FROM         tbInvoiceItem
	          WHERE     (InvoiceNumber = @InvoiceNumber)) 
		or exists(SELECT     InvoiceNumber
	          FROM         tbInvoiceTask
	          WHERE     (InvoiceNumber = @InvoiceNumber))
		begin
			begin tran trAcc
			
			exec dbo.spInvoiceTotal @InvoiceNumber
			
			UPDATE    tbInvoice
			SET              InvoiceStatusCode = 2
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (InvoiceStatusCode = 1) 
	
			UPDATE tbTask
			SET TaskStatusCode = 4
			FROM         tbTask INNER JOIN
								vwTaskInvoicedQuantity ON tbTask.TaskCode = vwTaskInvoicedQuantity.TaskCode AND 
								tbTask.Quantity <= vwTaskInvoicedQuantity.InvoiceQuantity INNER JOIN
								tbInvoiceTask ON tbTask.TaskCode = tbInvoiceTask.TaskCode AND tbTask.TaskCode = tbInvoiceTask.TaskCode
			WHERE     (tbInvoiceTask.InvoiceNumber = @InvoiceNumber) And (tbTask.TaskStatusCode < 4)	
			
			commit tran trAcc
		end
			
	RETURN
GO
CREATE PROCEDURE [dbo].[spInvoiceAddTask] 
	(
	@InvoiceNumber nvarchar(20),
	@TaskCode nvarchar(20)	
	)
AS
declare @InvoiceTypeCode smallint
declare @InvoiceQuantity float
declare @QuantityInvoiced float

	if exists(SELECT     InvoiceNumber, TaskCode
	          FROM         tbInvoiceTask
	          WHERE     (InvoiceNumber = @InvoiceNumber) AND (TaskCode = @TaskCode))
		return
		
	SELECT   @InvoiceTypeCode = InvoiceTypeCode
	FROM         tbInvoice
	WHERE     (InvoiceNumber = @InvoiceNumber) 

	if exists(SELECT     SUM(tbInvoiceTask.Quantity) AS QuantityInvoiced
	          FROM         tbInvoiceTask INNER JOIN
	                                tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber
	          WHERE     (tbInvoice.InvoiceTypeCode = 1 OR
	                                tbInvoice.InvoiceTypeCode = 3) AND (tbInvoiceTask.TaskCode = @TaskCode) AND (tbInvoice.InvoiceStatusCode > 1))
		begin
		SELECT TOP 1 @QuantityInvoiced = isnull(SUM(tbInvoiceTask.Quantity), 0)
		FROM         tbInvoiceTask INNER JOIN
				tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber
		WHERE     (tbInvoice.InvoiceTypeCode = 1 OR
				tbInvoice.InvoiceTypeCode = 3) AND (tbInvoiceTask.TaskCode = @TaskCode) AND (tbInvoice.InvoiceStatusCode > 1)				
		end
	else
		set @QuantityInvoiced = 0
		
	if @InvoiceTypeCode = 2 or @InvoiceTypeCode = 4
		begin
		if exists(SELECT     SUM(tbInvoiceTask.Quantity) AS QuantityInvoiced
				  FROM         tbInvoiceTask INNER JOIN
										tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber
				  WHERE     (tbInvoice.InvoiceTypeCode = 2 OR
										tbInvoice.InvoiceTypeCode = 4) AND (tbInvoiceTask.TaskCode = @TaskCode) AND (tbInvoice.InvoiceStatusCode > 1))
			begin
			SELECT TOP 1 @InvoiceQuantity = isnull(@QuantityInvoiced, 0) - isnull(SUM(tbInvoiceTask.Quantity), 0)
			FROM         tbInvoiceTask INNER JOIN
					tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber
			WHERE     (tbInvoice.InvoiceTypeCode = 2 OR
					tbInvoice.InvoiceTypeCode = 4) AND (tbInvoiceTask.TaskCode = @TaskCode) AND (tbInvoice.InvoiceStatusCode > 1)										
			end
		else
			set @InvoiceQuantity = isnull(@QuantityInvoiced, 0)
		end
	else
		begin
		SELECT  @InvoiceQuantity = Quantity - isnull(@QuantityInvoiced, 0)
		FROM         tbTask
		WHERE     (TaskCode = @TaskCode)
		end
			
	if isnull(@InvoiceQuantity, 0) <= 0
		set @InvoiceQuantity = 1
		
	INSERT INTO tbInvoiceTask
	                      (InvoiceNumber, TaskCode, Quantity, InvoiceValue, CashCode, TaxCode)
	SELECT     @InvoiceNumber AS InvoiceNumber, TaskCode, @InvoiceQuantity AS Quantity, UnitCharge * @InvoiceQuantity AS InvoiceValue, CashCode, 
	                      TaxCode
	FROM         tbTask
	WHERE     (TaskCode = @TaskCode)
	
	exec dbo.spInvoiceTotal @InvoiceNumber
			
	RETURN
GO
CREATE PROCEDURE [dbo].[spInvoiceCancel] 
AS

	UPDATE tbTask
	SET TaskStatusCode = 3
	FROM         tbTask INNER JOIN
	                      tbInvoiceTask ON tbTask.TaskCode = tbInvoiceTask.TaskCode AND tbTask.TaskCode = tbInvoiceTask.TaskCode INNER JOIN
	                      tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber INNER JOIN
	                      vwUserCredentials ON tbInvoice.UserId = vwUserCredentials.UserId
	WHERE     (tbInvoice.InvoiceTypeCode = 1 OR
	                      tbInvoice.InvoiceTypeCode = 3) AND (tbInvoice.InvoiceStatusCode = 1)
	                      
	DELETE tbInvoice
	FROM         tbInvoice INNER JOIN
	                      vwUserCredentials ON tbInvoice.UserId = vwUserCredentials.UserId
	WHERE     (tbInvoice.InvoiceStatusCode = 1)

	
	RETURN
GO
CREATE PROCEDURE dbo.spInvoiceRaise
	(
	@TaskCode nvarchar(20),
	@InvoiceTypeCode smallint,
	@InvoiceNumber nvarchar(20) = null output
	)
AS
declare @UserId smallint
declare @NextNumber int
declare @InvoiceSuffix nvarchar(4)

	select @UserId = UserId from vwUserCredentials

	set @InvoiceSuffix = '.' + dbo.fnPad(ltrim(str(@UserId)), 3)
	
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
		
	begin tran Invoice
	
	exec dbo.spInvoiceCancel
	
	UPDATE    tbInvoiceType
	SET              NextNumber = @NextNumber + 1
	WHERE     (InvoiceTypeCode = @InvoiceTypeCode)
	
	INSERT INTO tbInvoice
						  (InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoicedOn, InvoiceStatusCode, PaymentTerms)
	SELECT     @InvoiceNumber AS InvoiceNumber, @UserId AS UserId, tbTask.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, GETDATE() AS InvoicedOn, 
						  1 AS InvoiceStatusCode, tbOrg.PaymentTerms
	FROM         tbTask INNER JOIN
						  tbOrg ON tbTask.AccountCode = tbOrg.AccountCode
	WHERE     (tbTask.TaskCode = @TaskCode)
	
	exec dbo.spInvoiceAddTask @InvoiceNumber, @TaskCode
	
	commit tran Invoice
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spMenuInsert]
	(
		@MenuName nvarchar(50),
		@FromMenuId smallint = 0,
		@MenuId smallint = null OUTPUT
	)
AS

	begin tran trnMenu
	
	insert into tbProfileMenu (MenuName) values (@MenuName)
	select @MenuId = @@IDENTITY
	
	if @FromMenuId = 0
		begin
		insert into tbProfileMenuEntry (MenuId, FolderId, ItemId, ItemText, Command,  Argument)
				values (@MenuId, 1, 0, @MenuName, 0, 'Root')
		end
	else
		begin
		INSERT INTO tbProfileMenuEntry
		                      (MenuId, FolderId, ItemId, OpenMode, Argument, ProjectName, Command, ItemText)
		SELECT     @MenuId AS ToMenuId, FolderId, ItemId, OpenMode, Argument, ProjectName, Command, ItemText
		FROM         tbProfileMenuEntry
		WHERE     (MenuId = @FromMenuId)
		end
	commit tran trnMenu

	RETURN 
GO
CREATE PROCEDURE [dbo].[spOrgNextAddressCode] 
	(
	@AccountCode nvarchar(10),
	@AddressCode nvarchar(15) OUTPUT
	)
AS
declare @AddCount int

	SELECT @AddCount = COUNT(AddressCode) 
	FROM         tbOrgAddress
	WHERE     (AccountCode = @AccountCode)
	
	set @AddCount = @AddCount + 1
	set @AddressCode = upper(@AccountCode) + '_' + stuff('000', 4 - len(ltrim(str(@AddCount))), len(ltrim(str(@AddCount))), @AddCount)
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spOrgAddAddress] 
	(
	@AccountCode nvarchar(10),
	@Address ntext
	)
AS
declare @AddressCode nvarchar(15)
declare @RC int
	
	EXECUTE @RC = dbo.spOrgNextAddressCode @AccountCode, @AddressCode OUTPUT
	
	INSERT INTO tbOrgAddress
	                      (AddressCode, AccountCode, Address)
	VALUES     (@AddressCode, @AccountCode, @Address)
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spOrgContactFileAs] 
	(
	@ContactName nvarchar(100),
	@FileAs nvarchar(100) output
	)
AS

	if charindex(' ', @ContactName) = 0
		set @FileAs = @ContactName
	else
		begin
		declare @FirstNames nvarchar(100)
		declare @LastName nvarchar(100)
		declare @LastWordPos int
		
		set @LastWordPos = charindex(' ', @ContactName) + 1
		while charindex(' ', @ContactName, @LastWordPos) != 0
			set @LastWordPos = charindex(' ', @ContactName, @LastWordPos) + 1
		
		set @FirstNames = left(@ContactName, @LastWordPos - 2)
		set @LastName = right(@ContactName, len(@ContactName) - @LastWordPos + 1)
		set @FileAs = @LastName + ', ' + @FirstNames
		end

	RETURN
GO
CREATE PROCEDURE [dbo].[spOrgAddContact] 
	(
	@AccountCode nvarchar(10),
	@ContactName nvarchar(100)	 
	)
AS
declare @FileAs nvarchar(10)
declare @RC int
	
	EXECUTE @RC = dbo.spOrgContactFileAs @ContactName, @FileAs OUTPUT	
	
	INSERT INTO tbOrgContact
	                      (AccountCode, ContactName, FileAs, PhoneNumber, EmailAddress)
	SELECT     AccountCode, @ContactName AS ContactName, @FileAs, PhoneNumber, EmailAddress
	FROM         tbOrg
	WHERE AccountCode = @AccountCode
	
	RETURN
GO
CREATE PROCEDURE dbo.spOrgBalanceOutstanding 
	(
	@AccountCode nvarchar(10),
	@Balance money = 0 OUTPUT
	)
AS

	if exists(SELECT     tbInvoice.AccountCode
	          FROM         tbInvoice INNER JOIN
	                                tbInvoiceType ON tbInvoice.InvoiceTypeCode = tbInvoiceType.InvoiceTypeCode
	          WHERE     (tbInvoice.AccountCode = @AccountCode) AND (tbInvoice.InvoiceStatusCode > 1 AND tbInvoice.InvoiceStatusCode < 4)
	          GROUP BY tbInvoice.AccountCode)
		begin
		SELECT @Balance = Balance
		FROM         vwOrgBalanceOutstanding
		WHERE     (AccountCode = @AccountCode)		
		end
	else
		set @Balance = 0
		
	if exists(SELECT     AccountCode
	          FROM         tbOrgPayment
	          WHERE     (PaymentStatusCode = 1) AND (AccountCode = @AccountCode)) AND (@Balance <> 0)
		begin
		SELECT  @Balance = @Balance - SUM(PaidInValue - PaidOutValue) 
		FROM         tbOrgPayment
		WHERE     (PaymentStatusCode = 1) AND (AccountCode = @AccountCode)		
		end
		
	SELECT    @Balance = isnull(@Balance, 0) - CurrentBalance
	FROM         tbOrg
	WHERE     (AccountCode = @AccountCode)
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spOrgDefaultAccountCode] 
	(
	@AccountName nvarchar(100),
	@AccountCode nvarchar(10) OUTPUT 
	)
AS
declare @ParsedName nvarchar(100)
declare @FirstWord nvarchar(100)
declare @SecondWord nvarchar(100)
declare @ValidatedCode nvarchar(10)

declare @c char(1)
declare @ascii smallint
declare @pos int
declare @ok bit

declare @Suffix smallint
declare @Rows int
		
	set @pos = 1
	set @ParsedName = ''

	while @pos <= datalength(@AccountName)
	begin
		set @ascii = ascii(substring(@AccountName, @pos, 1))
		set @ok = case 
			when @ascii = 32 then 1
			when @ascii = 45 then 1
			when (@ascii >= 48 and @ascii <= 57) then 1
			when (@ascii >= 65 and @ascii <= 90) then 1
			when (@ascii >= 97 and @ascii <= 122) then 1
			else 0
		end
		if @ok = 1
			select @ParsedName = @ParsedName + char(ascii(substring(@AccountName, @pos, 1)))
		set @pos = @pos + 1
	end

	print @ParsedName
		
	if charindex(' ', @ParsedName) = 0
		begin
		set @FirstWord = @ParsedName
		set @SecondWord = ''
		end
	else
		begin
		set @FirstWord = left(@ParsedName, charindex(' ', @ParsedName) - 1)
		set @SecondWord = right(@ParsedName, len(@ParsedName) - charindex(' ', @ParsedName))
		if charindex(' ', @SecondWord) > 0
			set @SecondWord = left(@SecondWord, charindex(' ', @SecondWord) - 1)
		end

	if exists(select ExcludedTag from tbSystemCodeExclusion where ExcludedTag = @SecondWord)
		begin
		set @SecondWord = ''
		end

	print @FirstWord
	print @SecondWord

	if len(@SecondWord) > 0
		set @AccountCode = upper(left(@FirstWord, 3)) + upper(left(@SecondWord, 3))		
	else
		set @AccountCode = upper(left(@FirstWord, 6))

	set @ValidatedCode = @AccountCode
	select @rows = count(AccountCode) from tbOrg where AccountCode = @ValidatedCode
	set @Suffix = 0
	
	while @rows > 0
	begin
		set @Suffix = @Suffix + 1
		set @ValidatedCode = @AccountCode + ltrim(str(@Suffix))
		select @rows = count(AccountCode) from tbOrg where AccountCode = @ValidatedCode
	end
	
	set @AccountCode = @ValidatedCode
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spOrgDefaultTaxCode] 
	(
	@AccountCode nvarchar(10),
	@TaxCode nvarchar(10) OUTPUT
	)
AS
	if exists(SELECT     tbOrg.AccountCode
	          FROM         tbOrg INNER JOIN
	                                tbSystemOptions ON tbOrg.AccountCode = tbSystemOptions.AccountCode)
		begin
		SELECT @TaxCode = tbOrg.TaxCode
	          FROM         tbOrg INNER JOIN
	                                tbSystemOptions ON tbOrg.AccountCode = tbSystemOptions.AccountCode
		
		end	                              
	RETURN
GO
CREATE PROCEDURE dbo.spPaymentPostPaidIn
	(
	@PaymentCode nvarchar(20),
	@CurrentBalance money output 
	)
AS
--invoice values
declare @InvoiceNumber nvarchar(20)
declare @TaskCode nvarchar(20)
declare @TaxRate real
declare @ItemValue money

--calc values
declare @PaidValue money
declare @PaidTaxValue money

--default payment codes
declare @CashCode nvarchar(50)
declare @TaxCode nvarchar(10)
declare @TaxInValue money
declare @TaxOutValue money

	set @TaxInValue = 0
	set @TaxOutValue = 0
	
	declare curPaidIn cursor local for
		SELECT     vwInvoiceOutstanding.InvoiceNumber, vwInvoiceOutstanding.TaskCode, vwInvoiceOutstanding.CashCode, vwInvoiceOutstanding.TaxCode, 
		                      vwInvoiceOutstanding.TaxRate, vwInvoiceOutstanding.ItemValue
		FROM         vwInvoiceOutstanding INNER JOIN
		                      tbOrgPayment ON vwInvoiceOutstanding.AccountCode = tbOrgPayment.AccountCode
		WHERE     (tbOrgPayment.PaymentCode = @PaymentCode)
		ORDER BY vwInvoiceOutstanding.CashModeCode, vwInvoiceOutstanding.InvoicedOn

	open curPaidIn
	fetch next from curPaidIn into @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue
	while @@FETCH_STATUS = 0 and @CurrentBalance < 0
		begin
		if (@CurrentBalance + @ItemValue) > 0
			set @ItemValue = @CurrentBalance * -1

		set @PaidValue = Abs(@ItemValue) / (1 + @TaxRate)
		set @PaidTaxValue = Abs(@ItemValue) - (Abs(@ItemValue) / (1 + @TaxRate))
				
		set @CurrentBalance = @CurrentBalance + @ItemValue
		
		if isnull(@TaskCode, '') = ''
			begin
			UPDATE    tbInvoiceItem
			SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (CashCode = @CashCode)
			end
		else
			begin
			UPDATE   tbInvoiceTask
			SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (TaskCode = @TaskCode)				
			end

		exec dbo.spInvoiceTotal @InvoiceNumber
		        		  
		set @TaxInValue = @TaxInValue + CASE WHEN @ItemValue > 0 THEN @PaidTaxValue ELSE 0 END
		set @TaxOutValue = @TaxOutValue + CASE WHEN @ItemValue < 0 THEN @PaidTaxValue ELSE 0 END	
				
		fetch next from curPaidIn into @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue
		end
	
	close curPaidIn
	deallocate curPaidIn
	
	--output new org current balance
	if @CurrentBalance >= 0
		set @CurrentBalance = 0
	else
		set @CurrentBalance = @CurrentBalance * -1

	
	if isnull(@CashCode, '') != ''
		begin
		UPDATE    tbOrgPayment
		SET      PaymentStatusCode = 2, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
			CashCode = isnull(@CashCode, tbOrgPayment.CashCode), 
			TaxCode = isnull(@TaxCode, tbOrgPayment.TaxCode)
		WHERE     (PaymentCode = @PaymentCode)
		end

			
	RETURN
GO
CREATE PROCEDURE dbo.spPaymentPostPaidOut
	(
	@PaymentCode nvarchar(20),
	@CurrentBalance money output 
	)
AS
--invoice values
declare @InvoiceNumber nvarchar(20)
declare @TaskCode nvarchar(20)
declare @TaxRate real
declare @ItemValue money

--calc values
declare @PaidValue money
declare @PaidTaxValue money

--default payment codes
declare @CashCode nvarchar(50)
declare @TaxCode nvarchar(10)
declare @TaxInValue money
declare @TaxOutValue money

	set @TaxInValue = 0
	set @TaxOutValue = 0
	
	declare curPaidOut cursor local for
		SELECT     vwInvoiceOutstanding.InvoiceNumber, vwInvoiceOutstanding.TaskCode, vwInvoiceOutstanding.CashCode, vwInvoiceOutstanding.TaxCode, 
		                      vwInvoiceOutstanding.TaxRate, vwInvoiceOutstanding.ItemValue
		FROM         vwInvoiceOutstanding INNER JOIN
		                      tbOrgPayment ON vwInvoiceOutstanding.AccountCode = tbOrgPayment.AccountCode
		WHERE     (tbOrgPayment.PaymentCode = @PaymentCode)
		ORDER BY vwInvoiceOutstanding.CashModeCode DESC, vwInvoiceOutstanding.InvoicedOn

	open curPaidOut
	fetch next from curPaidOut into @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue
	while @@FETCH_STATUS = 0 and @CurrentBalance > 0
		begin
		if (@CurrentBalance + @ItemValue) < 0
			set @ItemValue = @CurrentBalance * -1

		set @PaidValue = Abs(@ItemValue) / (1 + @TaxRate)
		set @PaidTaxValue = Abs(@ItemValue) - (Abs(@ItemValue) / (1 + @TaxRate))
				
		set @CurrentBalance = @CurrentBalance + @ItemValue
		
		if isnull(@TaskCode, '') = ''
			begin
			UPDATE    tbInvoiceItem
			SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (CashCode = @CashCode)
			end
		else
			begin
			UPDATE   tbInvoiceTask
			SET              PaidValue = PaidValue + @PaidValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (TaskCode = @TaskCode)				
			end

		exec dbo.spInvoiceTotal @InvoiceNumber
		        		  
		set @TaxInValue = @TaxInValue + CASE WHEN @ItemValue > 0 THEN @PaidTaxValue ELSE 0 END
		set @TaxOutValue = @TaxOutValue + CASE WHEN @ItemValue < 0 THEN @PaidTaxValue ELSE 0 END	
				
		fetch next from curPaidOut into @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue
		end
		
	close curPaidOut
	deallocate curPaidOut
	
	--output new org current balance
	if @CurrentBalance <= 0
		set @CurrentBalance = 0
	else
		set @CurrentBalance = @CurrentBalance * -1

	if isnull(@CashCode, '') != ''
		begin
		UPDATE    tbOrgPayment
		SET      PaymentStatusCode = 2, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
			CashCode = isnull(@CashCode, tbOrgPayment.CashCode), 
			TaxCode = isnull(@TaxCode, tbOrgPayment.TaxCode)
		WHERE     (PaymentCode = @PaymentCode)
		end
	
	RETURN
GO
CREATE PROCEDURE dbo.spPaymentPostInvoiced
	(
	@PaymentCode nvarchar(20) 
	)
AS
declare @AccountCode nvarchar(10)
declare @CashModeCode smallint
declare @CurrentBalance money
declare @PaidValue money
declare @PostValue money

	SELECT   @PaidValue = CASE WHEN PaidInValue = 0 THEN PaidOutValue ELSE PaidInValue END,
		@CurrentBalance = tbOrg.CurrentBalance,
		@AccountCode = tbOrg.AccountCode,
		@CashModeCode = CASE WHEN PaidInValue = 0 THEN 1 ELSE 2 END
	FROM         tbOrgPayment INNER JOIN
	                      tbOrg ON tbOrgPayment.AccountCode = tbOrg.AccountCode
	WHERE     (tbOrgPayment.PaymentCode = @PaymentCode)
	
	if @CashModeCode = 2
		begin
		set @PostValue = @PaidValue
		set @PaidValue = (@PaidValue + @CurrentBalance) * -1			
		exec dbo.spPaymentPostPaidIn @PaymentCode, @PaidValue output
		end
	else
		begin
		set @PostValue = @PaidValue * -1
		set @PaidValue = @PaidValue + (@CurrentBalance * -1)			
		exec dbo.spPaymentPostPaidOut @PaymentCode, @PaidValue output
		end

	update tbOrg
	set CurrentBalance = @PaidValue
	where AccountCode = @AccountCode

	UPDATE  tbOrgAccount
	SET CurrentBalance = tbOrgAccount.CurrentBalance + @PostValue
	FROM         tbOrgAccount INNER JOIN
						  tbOrgPayment ON tbOrgAccount.CashAccountCode = tbOrgPayment.CashAccountCode
	WHERE tbOrgPayment.PaymentCode = @PaymentCode
		
	RETURN
GO
CREATE PROCEDURE dbo.spOrgRebuild
	(
		@AccountCode nvarchar(10)
	)
AS
declare @Balance money
declare @BalanceOutstanding money

declare @InvoiceNumber nvarchar(20)
declare @TaskCode nvarchar(20)
declare @CashCode nvarchar(50)
declare @InvoiceValue money
declare @TaxValue money
declare @CashModeCode smallint
declare @PaidValue money
declare @PaidInvoiceValue money
declare @PaidTaxValue money
declare @TaxRate float
		
	SELECT  @Balance = SUM(CASE WHEN PaidInValue > 0 THEN PaidInValue * -1 ELSE PaidOutValue  END)
	FROM         tbOrgPayment
	WHERE     (AccountCode = @AccountCode) And (PaymentStatusCode <> 1)
	
	SELECT @Balance = isnull(@Balance, 0) + OpeningBalance
	FROM tbOrg
	WHERE     (AccountCode = @AccountCode)

	declare curInv cursor local for
		SELECT     InvoiceNumber, TaskCode, CashCode, InvoiceValue, TaxValue
		FROM         vwOrgInvoices
		WHERE     (AccountCode = @AccountCode)
		ORDER BY InvoicedOn
	
	set @CashModeCode = CASE WHEN @Balance > 0 THEN 1 ELSE 2 END
		
	begin tran OrgRebuild
	
	update tbOrg
	set CurrentBalance = 0
	where AccountCode = @AccountCode
	
	UPDATE tbOrgPayment
	SET
		TaxInValue = PaidInValue * TaxRate, 
		TaxOutValue = PaidOutValue * TaxRate
	FROM         tbOrgPayment INNER JOIN
	                      tbSystemTaxCode ON tbOrgPayment.TaxCode = tbSystemTaxCode.TaxCode
	WHERE     (tbOrgPayment.AccountCode = @AccountCode)
	
	
	UPDATE    tbInvoice
	SET              PaidValue = 0, PaidTaxValue = 0, InvoiceStatusCode = 2
	WHERE     (AccountCode = @AccountCode) AND (InvoiceStatusCode <> 1)

	UPDATE tbInvoiceItem
	SET PaidValue = 0, PaidTaxValue = 0
	FROM         tbInvoiceItem INNER JOIN
	                      tbInvoice ON tbInvoiceItem.InvoiceNumber = tbInvoice.InvoiceNumber
	WHERE     (tbInvoice.AccountCode = @AccountCode) AND (tbInvoice.InvoiceStatusCode <> 1)	

	UPDATE tbInvoiceTask
	SET PaidValue = 0, PaidTaxValue = 0
	FROM         tbInvoiceTask INNER JOIN
	                      tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber
	WHERE     (tbInvoice.AccountCode = @AccountCode) AND (tbInvoice.InvoiceStatusCode <> 1)		

	open curInv
	fetch next from curInv into @InvoiceNumber, @TaskCode, @CashCode, @InvoiceValue, @TaxValue
	while @@FETCH_STATUS = 0
		begin
		
		print str(@Balance) + ' + ' + str((@InvoiceValue + @TaxValue))
		
		if @CashModeCode = 1		--EXPENSE
			begin
			if @Balance > 0
				if (@Balance + (@InvoiceValue + @TaxValue)) < 0
					set @PaidValue = @Balance
				else
					set @PaidValue = @InvoiceValue + @TaxValue
			else
				set @PaidValue = 0
			end
		else						--SALES
			begin
			if @Balance < 0
				if (@Balance + (@InvoiceValue + @TaxValue)) > 0
					set @PaidValue = @Balance
				else
					set @PaidValue = @InvoiceValue + @TaxValue			
			else
				set @PaidValue = 0
			end
		
		set @PaidValue = Abs(@PaidValue)
		
		set @Balance = @Balance + (@InvoiceValue + @TaxValue)
		
		if @PaidValue > 0
			begin
			set @TaxRate = @TaxValue / @InvoiceValue
			set @PaidInvoiceValue = @PaidValue * (1 - @TaxRate)
			set @PaidTaxValue = @PaidValue * @TaxRate

			if isnull(@TaskCode, '') = ''
				begin
				UPDATE    tbInvoiceItem
				SET              PaidValue = PaidValue + @PaidInvoiceValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
				WHERE     (InvoiceNumber = @InvoiceNumber) AND (CashCode = @CashCode)
				end
			else
				begin
				UPDATE   tbInvoiceTask
				SET              PaidValue = PaidValue + @PaidInvoiceValue, PaidTaxValue = PaidTaxValue + @PaidTaxValue
				WHERE     (InvoiceNumber = @InvoiceNumber) AND (TaskCode = @TaskCode)				
				end

			exec dbo.spInvoiceTotal @InvoiceNumber			
			
			end

		fetch next from curInv into @InvoiceNumber, @TaskCode, @CashCode, @InvoiceValue, @TaxValue
		end
	
	close curInv
	deallocate curInv

	exec dbo.spOrgBalanceOutstanding @AccountCode, @BalanceOutstanding output
	set @Balance = @Balance - @BalanceOutstanding
	
	UPDATE    tbOrg
	SET              CurrentBalance = OpeningBalance - @Balance
	WHERE     (AccountCode = @AccountCode)
		
	commit tran OrgRebuild
	

	RETURN 
GO
CREATE PROCEDURE dbo.spOrgStatement
	(
	@AccountCode nvarchar(10)
	)
AS
declare @FromDate datetime
	
	SELECT @FromDate = dateadd(d, StatementDays * -1, getdate())
	FROM         tbOrg
	WHERE     (AccountCode = @AccountCode)
	
	SELECT     TransactedOn, OrderBy, Reference, StatementType, Charge, Balance
	FROM         fnOrgStatement(@AccountCode) fnOrgStatement
	WHERE     (TransactedOn >= @FromDate)
	ORDER BY TransactedOn, OrderBy
	
	RETURN 
GO
CREATE PROCEDURE dbo.spPaymentMove
	(
	@PaymentCode nvarchar(20),
	@CashAccountCode nvarchar(10)
	)
AS
declare @OldAccountCode nvarchar(10)

	SELECT @OldAccountCode = CashAccountCode
	FROM         tbOrgPayment
	WHERE     (PaymentCode = @PaymentCode)
	
	begin tran
	
	update tbOrgPayment 
	set CashAccountCode = @CashAccountCode,
		UpdatedOn = getdate(),
		UpdatedBy = (suser_sname())
	where PaymentCode = @PaymentCode	

	exec spCashAccountRebuild @CashAccountCode
	exec spCashAccountRebuild @OldAccountCode
	
	commit tran
	
	RETURN 
GO
CREATE PROCEDURE dbo.spPaymentPostMisc
	(
	@PaymentCode nvarchar(20) 
	)
AS
declare @InvoiceNumber nvarchar(20)
declare @UserId smallint
declare @NextNumber int
declare @InvoiceSuffix nvarchar(4)
declare @InvoiceTypeCode smallint

	SELECT @InvoiceTypeCode = CASE WHEN PaidInValue != 0 THEN 1 ELSE 3 END 
	FROM         tbOrgPayment
	WHERE     (PaymentCode = @PaymentCode)

	select @UserId = UserId from vwUserCredentials

	set @InvoiceSuffix = '.' + dbo.fnPad(ltrim(str(@UserId)), 3)
	
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
		
	
	UPDATE    tbInvoiceType
	SET              NextNumber = @NextNumber + 1
	WHERE     (InvoiceTypeCode = @InvoiceTypeCode)

	INSERT INTO tbInvoice
	                      (InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, Printed)
	SELECT     @InvoiceNumber AS InvoiceNumber, tbOrgPayment.UserId, tbOrgPayment.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, 
	                      4 AS InvoiceStatusCode, tbOrgPayment.PaidOn, CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue * (1 - tbSystemTaxCode.TaxRate) 
	                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue * (1 - tbSystemTaxCode.TaxRate) END AS InvoiceValue, 
	                      CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue * tbSystemTaxCode.TaxRate WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue
	                       * tbSystemTaxCode.TaxRate END AS TaxValue, CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue * (1 - tbSystemTaxCode.TaxRate) 
	                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue * (1 - tbSystemTaxCode.TaxRate) END AS PaidValue, 
	                      CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue * tbSystemTaxCode.TaxRate WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue
	                       * tbSystemTaxCode.TaxRate END AS PaidTaxValue, 1 AS Printed
	FROM         tbOrgPayment INNER JOIN
	                      tbSystemTaxCode ON tbOrgPayment.TaxCode = tbSystemTaxCode.TaxCode
	WHERE PaymentCode = @PaymentCode


INSERT INTO tbInvoiceItem
                      (InvoiceNumber, CashCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, TaxCode)
SELECT     @InvoiceNumber AS InvoiceNumber, tbOrgPayment.CashCode, 
                      CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue * (1 - tbSystemTaxCode.TaxRate) 
                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue * (1 - tbSystemTaxCode.TaxRate) END AS InvoiceValue, 
                      CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue * tbSystemTaxCode.TaxRate WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue
                       * tbSystemTaxCode.TaxRate END AS TaxValue, CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue * (1 - tbSystemTaxCode.TaxRate) 
                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue * (1 - tbSystemTaxCode.TaxRate) END AS PaidValue, 
                      CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue * tbSystemTaxCode.TaxRate WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue
                       * tbSystemTaxCode.TaxRate END AS PaidTaxValue, tbOrgPayment.TaxCode
FROM         tbOrgPayment INNER JOIN
                      tbSystemTaxCode ON tbOrgPayment.TaxCode = tbSystemTaxCode.TaxCode
WHERE     (tbOrgPayment.PaymentCode = @PaymentCode)

	UPDATE  tbOrgAccount
	SET CurrentBalance = CASE WHEN PaidInValue > 0 THEN tbOrgAccount.CurrentBalance + PaidInValue ELSE tbOrgAccount.CurrentBalance - PaidOutValue END
	FROM         tbOrgAccount INNER JOIN
						  tbOrgPayment ON tbOrgAccount.CashAccountCode = tbOrgPayment.CashAccountCode
	WHERE tbOrgPayment.PaymentCode = @PaymentCode

	UPDATE    tbOrgPayment
	SET		PaymentStatusCode = 2,
			TaxInValue = TaxInValue + (PaidInValue * TaxRate),
			TaxOutValue = TaxOutValue + (PaidOutValue * TaxRate)
	FROM         tbOrgPayment INNER JOIN
	                      tbSystemTaxCode ON tbOrgPayment.TaxCode = tbSystemTaxCode.TaxCode
	WHERE     (PaymentCode = @PaymentCode)
	
	RETURN
GO
CREATE PROCEDURE dbo.spPaymentPost 
AS
declare @PaymentCode nvarchar(20)

	declare curMisc cursor local for
		SELECT     PaymentCode
		FROM         tbOrgPayment
		WHERE     (PaymentStatusCode = 1) AND (NOT (CashCode IS NULL))
		ORDER BY AccountCode, PaidOn

	declare curInv cursor local for
		SELECT     PaymentCode
		FROM         tbOrgPayment
		WHERE     (PaymentStatusCode = 1) AND (CashCode IS NULL)
		ORDER BY AccountCode, PaidOn
		
	begin tran Payment
	open curMisc
	fetch next from curMisc into @PaymentCode
	while @@FETCH_STATUS = 0
		begin
		exec dbo.spPaymentPostMisc @PaymentCode		
		fetch next from curMisc into @PaymentCode	
		end

	close curMisc
	deallocate curMisc
	
	open curInv
	fetch next from curInv into @PaymentCode
	while @@FETCH_STATUS = 0
		begin
		exec dbo.spPaymentPostInvoiced @PaymentCode		
		fetch next from curInv into @PaymentCode	
		end

	close curInv
	deallocate curInv

	commit tran Payment
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spSettingAddCalDateRange]
	(
		@CalendarCode nvarchar(10),
		@FromDate datetime,
		@ToDate datetime
	)
AS
declare @UnavailableDate datetime

	select @UnavailableDate = @FromDate
	
	while @UnavailableDate <= @ToDate
	begin
		insert into tbSystemCalendarHoliday (CalendarCode, UnavailableOn)
		values (@CalendarCode, @UnavailableDate)
		select @UnavailableDate = DateAdd(d, 1, @UnavailableDate)
	end

	RETURN
GO
CREATE PROCEDURE [dbo].[spSettingDelCalDateRange]
	(
		@CalendarCode nvarchar(10),
		@FromDate datetime,
		@ToDate datetime
	)
AS
	DELETE FROM tbSystemCalendarHoliday
		WHERE UnavailableOn >= @FromDate
			AND UnavailableOn <= @ToDate
			AND CalendarCode = @CalendarCode
			
	RETURN 1
GO
CREATE Procedure [dbo].[spSettingInitialised]
(@Setting bit)
AS
	if @Setting = 0
		goto InitialisationFailed
	else if exists (SELECT     tbOrg.AccountCode
	                FROM         tbOrg INNER JOIN
	                                      tbSystemOptions ON tbOrg.AccountCode = tbSystemOptions.AccountCode)
		begin
		if exists (SELECT     tbOrgAddress.AddressCode
		           FROM         tbOrg INNER JOIN
		                                 tbSystemOptions ON tbOrg.AccountCode = tbSystemOptions.AccountCode INNER JOIN
		                                 tbOrgAddress ON tbOrg.AddressCode = tbOrgAddress.AddressCode)
			begin
			if exists (SELECT     TOP 1 UserId
			           FROM         tbUser)
				update tbSystemOptions Set Initialised = 1
			else		
				goto InitialisationFailed
			end
		else		                    
			goto InitialisationFailed
		end
	else
		goto InitialisationFailed
			
	return 1
	
InitialisationFailed:
	update tbSystemOptions Set Initialised = 0
	return 0
GO
CREATE PROCEDURE [dbo].[spSettingLicence]
	(
		@Licence binary (50) = null OUTPUT,
		@LicenceType smallint = null OUTPUT
	)
AS
	select top 1 @Licence = [Licence], @LicenceType = LicenceType 
	from tbSystemInstall
	where CategoryTypeCode = 0 and ReleaseTypeCode = 0	
	RETURN 
GO
CREATE PROCEDURE [dbo].[spSettingLicenceAdd]
	(
		@Licence binary (50),
		@LicenceType smallint
	)
AS
	update tbSystemInstall
	set 
		[Licence] = @Licence,
		LicenceType = @LicenceType
	where
		CategoryTypeCode = 0
		and ReleaseTypeCode = 0
	
	if @@ROWCOUNT > 0
		RETURN 1
	else
		RETURN 0
GO
CREATE PROCEDURE dbo.spSystemCompanyName
	(
	@AccountName nvarchar(255) = null output
	)
AS
	SELECT top 1 @AccountName = tbOrg.AccountName
	FROM         tbOrg INNER JOIN
	                      tbSystemOptions ON tbOrg.AccountCode = tbSystemOptions.AccountCode
	RETURN 
GO
CREATE PROCEDURE dbo.spSystemPeriodTransfer
	(
		@StartOn datetime
	)
AS
	
	UPDATE tbCashPeriod
	SET InvoiceValue = vwCashCodeInvoiceSummary.InvoiceValue, 
		InvoiceTax = vwCashCodeInvoiceSummary.TaxValue
	FROM         tbCashPeriod INNER JOIN
	                      vwCashCodeInvoiceSummary ON tbCashPeriod.CashCode = vwCashCodeInvoiceSummary.CashCode AND tbCashPeriod.StartOn = vwCashCodeInvoiceSummary.StartOn	
	WHERE tbCashPeriod.StartOn = @StartOn
	
	UPDATE tbCashPeriod
	SET CashValue = vwCashCodePaymentSummary.CashValue, 
		CashTax = vwCashCodePaymentSummary.CashTax
	FROM         tbCashPeriod INNER JOIN
	                      vwCashCodePaymentSummary ON tbCashPeriod.CashCode = vwCashCodePaymentSummary.CashCode AND 
	                      tbCashPeriod.StartOn = vwCashCodePaymentSummary.StartOn
	WHERE tbCashPeriod.StartOn = @StartOn	                      

	UPDATE tbCashPeriod
	SET CashValue = vwCashAccountPeriodClosingBalance.ClosingBalance
	FROM         vwCashAccountPeriodClosingBalance INNER JOIN
	                      tbCashPeriod ON vwCashAccountPeriodClosingBalance.CashCode = tbCashPeriod.CashCode AND 
	                      vwCashAccountPeriodClosingBalance.StartOn = tbCashPeriod.StartOn
	WHERE     (tbCashPeriod.StartOn = @StartOn)
	
	RETURN 
GO
CREATE PROCEDURE dbo.spSystemPeriodClose
AS

	if exists(select * from dbo.fnSystemActivePeriod())
		begin
		declare @StartOn datetime
		declare @YearNumber smallint
		
		select @StartOn = StartOn, @YearNumber = YearNumber
		from fnSystemActivePeriod() fnSystemActivePeriod
		 		
		begin tran
		
		exec dbo.spCashGeneratePeriods
		exec dbo.spSystemPeriodTransfer @StartOn
		
		UPDATE tbSystemYearPeriod
		SET CashStatusCode = 3
		WHERE StartOn = @StartOn			
		
		if not exists (SELECT     CashStatusCode
					FROM         tbSystemYearPeriod
					WHERE     (YearNumber = @YearNumber) AND (CashStatusCode < 3)) 
			begin
			update tbSystemYear
			SET CashStatusCode = 3
			where YearNumber = @YearNumber	
			end
		if exists(select * from dbo.fnSystemActivePeriod())
			begin
			update tbSystemYearPeriod
			SET CashStatusCode = 2
			FROM fnSystemActivePeriod() fnSystemActivePeriod INNER JOIN
								tbSystemYearPeriod ON fnSystemActivePeriod.YearNumber = tbSystemYearPeriod.YearNumber AND fnSystemActivePeriod.MonthNumber = tbSystemYearPeriod.MonthNumber
			
			end		
		if exists(select * from dbo.fnSystemActivePeriod())
			begin
			update tbSystemYear
			SET CashStatusCode = 2
			FROM fnSystemActivePeriod() fnSystemActivePeriod INNER JOIN
								tbSystemYear ON fnSystemActivePeriod.YearNumber = tbSystemYear.YearNumber  
			end
		commit tran
		end
					
	RETURN
GO
CREATE PROCEDURE dbo.spSystemPeriodTransferAll
AS
	
	UPDATE tbCashPeriod
	SET InvoiceValue = vwCashCodeInvoiceSummary.InvoiceValue, 
		InvoiceTax = vwCashCodeInvoiceSummary.TaxValue
	FROM         tbCashPeriod INNER JOIN
	                      vwCashCodeInvoiceSummary ON tbCashPeriod.CashCode = vwCashCodeInvoiceSummary.CashCode AND tbCashPeriod.StartOn = vwCashCodeInvoiceSummary.StartOn	
	
	UPDATE tbCashPeriod
	SET CashValue = vwCashCodePaymentSummary.CashValue, 
		CashTax = vwCashCodePaymentSummary.CashTax
	FROM         tbCashPeriod INNER JOIN
	                      vwCashCodePaymentSummary ON tbCashPeriod.CashCode = vwCashCodePaymentSummary.CashCode AND 
	                      tbCashPeriod.StartOn = vwCashCodePaymentSummary.StartOn

	UPDATE tbCashPeriod
	SET CashValue = vwCashAccountPeriodClosingBalance.ClosingBalance,
		InvoiceValue = vwCashAccountPeriodClosingBalance.ClosingBalance
	FROM         vwCashAccountPeriodClosingBalance INNER JOIN
	                      tbCashPeriod ON vwCashAccountPeriodClosingBalance.CashCode = tbCashPeriod.CashCode AND 
	                      vwCashAccountPeriodClosingBalance.StartOn = tbCashPeriod.StartOn

	RETURN 
GO
CREATE PROCEDURE dbo.spSystemReassignUser 
	(
	@UserId smallint
	)
AS
	UPDATE    tbUser
	SET       LogonName = (SUSER_SNAME())
	WHERE     (UserId = @UserId)
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spSystemYearPeriods]
	(
	@YearNumber int
	)
AS
	SELECT     tbSystemYear.Description, tbSystemMonth.MonthName
				FROM         tbSystemYearPeriod INNER JOIN
									tbSystemYear ON tbSystemYearPeriod.YearNumber = tbSystemYear.YearNumber INNER JOIN
									tbSystemMonth ON tbSystemYearPeriod.MonthNumber = tbSystemMonth.MonthNumber
				WHERE     (tbSystemYearPeriod.YearNumber = @YearNumber)
				ORDER BY tbSystemYearPeriod.YearNumber, tbSystemYearPeriod.StartOn
	RETURN 
GO
CREATE PROCEDURE [dbo].[spTaskAssignToParent] 
	(
	@ChildTaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20)
	)
AS
declare @TaskTitle nvarchar(100)
declare @StepNumber smallint

	if exists(SELECT     TOP 1 StepNumber
	          FROM         tbTaskFlow
	          WHERE     (ParentTaskCode = @ParentTaskCode))
		begin
		SELECT  @StepNumber = MAX(StepNumber) 
		FROM         tbTaskFlow
		WHERE     (ParentTaskCode = @ParentTaskCode)
		set @StepNumber = @StepNumber - (@StepNumber % 10) + 10		
		end
	else
		set @StepNumber = 10


	SELECT     @TaskTitle = TaskTitle
	FROM         tbTask
	WHERE     (TaskCode = @ParentTaskCode)		
	
	UPDATE    tbTask
	SET      TaskTitle = @TaskTitle
	WHERE     (TaskCode = @ChildTaskCode)
	
	INSERT INTO tbTaskFlow
	                      (ParentTaskCode, StepNumber, ChildTaskCode)
	VALUES     (@ParentTaskCode,@StepNumber,@ChildTaskCode)
	
	RETURN
GO
CREATE PROCEDURE dbo.spTaskConfigure 
	(
	@ParentTaskCode nvarchar(20),
	@TimeStamp datetime = null output
	)
AS
declare @StepNumber smallint

declare @TaskCode nvarchar(20)
declare @UserId smallint
declare @TaskPrefix nvarchar(4)

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
	set @TaskPrefix = dbo.fnPad(ltrim(str(@UserId)), 3) + '_'
	if @TimeStamp is null
		set @TimeStamp = getdate()
	
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
		set @TimeStamp = dateadd(s, 1, @TimeStamp)
		set @TaskCode =	@TaskPrefix +
							+ ltrim(str(datepart(yyyy, @Timestamp)))
							+ dbo.fnPad(ltrim(str(datepart(mm, @Timestamp))), 2)
							+ dbo.fnPad(ltrim(str(datepart(dd, @Timestamp))), 2)
							+ dbo.fnPad(ltrim(str(datepart(hh, @Timestamp))), 2)
							+ dbo.fnPad(ltrim(str(datepart(mm, @Timestamp))), 2)
							+ dbo.fnPad(ltrim(str(datepart(ss, @Timestamp))), 2)
		
		INSERT INTO tbTask
							  (TaskCode, UserId, AccountCode, ContactName, ActivityCode, TaskStatusCode, ActionById, ActionOn, TaskNotes, UnitCharge, AddressCodeFrom, 
							  AddressCodeTo, CashCode, TaxCode, Printed, TaskTitle)
		SELECT     @TaskCode AS NewTask, tbTask_1.UserId, tbTask_1.AccountCode, tbTask_1.ContactName, tbActivity.ActivityCode, tbActivity.TaskStatusCode, 
							  tbTask_1.ActionById, tbTask_1.ActionOn, tbActivity.DefaultText, tbActivity.UnitCharge, tbOrg.AddressCode AS AddressCodeFrom, 
							  tbOrg.AddressCode AS AddressCodeTo, tbActivity.CashCode, dbo.fnTaskDefaultTaxCode(tbTask_1.AccountCode, tbActivity.CashCode) AS TaxCode, 
							  CASE WHEN tbActivity.PrintOrder = 0 THEN 1 ELSE 0 END AS Printed, tbTask_1.TaskTitle
		FROM         tbActivityFlow INNER JOIN
							  tbActivity ON tbActivityFlow.ChildCode = tbActivity.ActivityCode INNER JOIN
							  tbTask AS tbTask_1 ON tbActivityFlow.ParentCode = tbTask_1.ActivityCode INNER JOIN
							  tbOrg ON tbTask_1.AccountCode = tbOrg.AccountCode
		WHERE     (tbActivityFlow.StepNumber = @StepNumber) AND (tbTask_1.TaskCode = @ParentTaskCode)	
		
		INSERT INTO tbTaskFlow
		                      (ParentTaskCode, StepNumber, ChildTaskCode, UsedOnQuantity, OffsetDays)
		SELECT     tbTask.TaskCode, tbActivityFlow.StepNumber, @TaskCode AS ChildTaskCode, tbActivityFlow.UsedOnQuantity, tbActivityFlow.OffsetDays
		FROM         tbActivityFlow INNER JOIN
		                      tbTask ON tbActivityFlow.ParentCode = tbTask.ActivityCode
		WHERE     (tbTask.TaskCode = @ParentTaskCode) AND (tbActivityFlow.StepNumber = @StepNumber)
		
		exec dbo.spTaskConfigure @TaskCode, @TimeStamp output
		fetch next from curAct into @StepNumber
		end
	
	close curAct
	deallocate curAct


	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskCost] 
	(
	@ParentTaskCode nvarchar(20),
	@TotalCost money = 0 output
	)

AS
declare @TaskCode nvarchar(20)
declare @TotalCharge money
declare @CashModeCode smallint

	declare curFlow cursor local for
		SELECT     tbTask.TaskCode, vwTaskCashMode.CashModeCode, tbTask.TotalCharge
		FROM         tbTask INNER JOIN
							  tbTaskFlow ON tbTask.TaskCode = tbTaskFlow.ChildTaskCode INNER JOIN
							  vwTaskCashMode ON tbTask.TaskCode = vwTaskCashMode.TaskCode
		WHERE     (tbTaskFlow.ParentTaskCode = @ParentTaskCode)	

	open curFlow
	fetch next from curFlow into @TaskCode, @CashModeCode, @TotalCharge
	while @@FETCH_STATUS = 0
		begin
		set @TotalCost = @TotalCost + case when @CashModeCode = 1 then @TotalCharge else @TotalCharge * -1 end
		exec dbo.spTaskCost @TaskCode, @TotalCost
		fetch next from curFlow into @TaskCode, @CashModeCode, @TotalCharge
		end
	
	close curFlow
	deallocate curFlow
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskDefaultTaxCode] 
	(
	@AccountCode nvarchar(10),
	@CashCode nvarchar(50),
	@TaxCode nvarchar(10) OUTPUT
	)
AS

	set @TaxCode = dbo.fnTaskDefaultTaxCode(@AccountCode, @CashCode)
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskDelete] 
	(
	@TaskCode nvarchar(20)
	)
AS
declare @ChildTaskCode nvarchar(20)

	DELETE FROM tbTaskFlow
	WHERE     (ChildTaskCode = @TaskCode)

	declare curFlow cursor local for
		SELECT     ChildTaskCode
		FROM         tbTaskFlow
		WHERE     (ParentTaskCode = @TaskCode)
	
	open curFlow		
	fetch next from curFlow into @ChildTaskCode
	while @@FETCH_STATUS = 0
		begin
		exec dbo.spTaskDelete @ChildTaskCode
		fetch next from curFlow into @ChildTaskCode		
		end
	
	close curFlow
	deallocate curFlow
	
	delete from tbTask
	where (TaskCode = @TaskCode)
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskEmailAddress] 
	(
	@TaskCode nvarchar(20),
	@EmailAddress nvarchar(255) OUTPUT
	)
AS
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
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskEmailDetail] 
	(
	@TaskCode nvarchar(20)
	)
AS
declare @NickName nvarchar(100)
declare @EmailAddress nvarchar(255)


	if exists(SELECT     tbOrgContact.ContactName
	          FROM         tbOrgContact INNER JOIN
	                                tbTask ON tbOrgContact.AccountCode = tbTask.AccountCode AND tbOrgContact.ContactName = tbTask.ContactName
	          WHERE     (tbTask.TaskCode = @TaskCode))
		begin
		SELECT  @NickName = case when tbOrgContact.NickName is null then tbOrgContact.ContactName else tbOrgContact.NickName end
					  FROM         tbOrgContact INNER JOIN
											tbTask ON tbOrgContact.AccountCode = tbTask.AccountCode AND tbOrgContact.ContactName = tbTask.ContactName
					  WHERE     (tbTask.TaskCode = @TaskCode)				
		end
	else
		begin
		SELECT @NickName = ContactName
		FROM         tbTask
		WHERE     (TaskCode = @TaskCode)
		end
	
	exec dbo.spTaskEmailAddress	@TaskCode, @EmailAddress output
	
	SELECT     tbTask.TaskCode, tbTask.TaskTitle, tbOrg.AccountCode, tbOrg.AccountName, @NickName AS NickName, @EmailAddress AS EmailAddress, 
	                      tbTask.ActivityCode, tbTaskStatus.TaskStatus, tbTask.TaskNotes
	FROM         tbTask INNER JOIN
	                      tbTaskStatus ON tbTask.TaskStatusCode = tbTaskStatus.TaskStatusCode INNER JOIN
	                      tbOrg ON tbTask.AccountCode = tbOrg.AccountCode
	WHERE     (tbTask.TaskCode = @TaskCode)

	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskEmailFooter] 
AS
declare @AccountName nvarchar(255)
declare @WebSite nvarchar(255)

	SELECT TOP 1 @AccountName = tbOrg.AccountName, @WebSite = tbOrg.WebSite
	FROM         tbOrg INNER JOIN
	                      tbSystemOptions ON tbOrg.AccountCode = tbSystemOptions.AccountCode
	
	SELECT     tbUser.UserName, tbUser.PhoneNumber, tbUser.MobileNumber, @AccountName AS AccountName, @Website AS Website
	FROM         vwUserCredentials INNER JOIN
	                      tbUser ON vwUserCredentials.UserId = tbUser.UserId
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskIsProject] 
	(
	@TaskCode nvarchar(20),
	@IsProject bit = 0 output
	)
AS
	if exists(SELECT     TOP 1 Attribute
	          FROM         tbTaskAttribute
	          WHERE     (TaskCode = @TaskCode))
		set @IsProject = 1
	else if exists (SELECT     TOP 1 ParentTaskCode, StepNumber
	                FROM         tbTaskFlow
	                WHERE     (ParentTaskCode = @TaskCode))
		set @IsProject = 1
	else
		set @IsProject = 0
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskMode] 
	(
	@TaskCode nvarchar(20)
	)
AS
	SELECT     tbTask.AccountCode, tbTask.ActivityCode, tbTask.TaskStatusCode, tbTask.ActionOn, vwTaskCashMode.CashModeCode
	FROM         tbTask LEFT OUTER JOIN
	                      vwTaskCashMode ON tbTask.TaskCode = vwTaskCashMode.TaskCode
	WHERE     (tbTask.TaskCode = @TaskCode)
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskNextAttributeOrder] 
	(
	@TaskCode nvarchar(20),
	@PrintOrder smallint = 10 output
	)
AS
	if exists(SELECT     TOP 1 PrintOrder
	          FROM         tbTaskAttribute
	          WHERE     (TaskCode = @TaskCode))
		begin
		SELECT  @PrintOrder = MAX(PrintOrder) 
		FROM         tbTaskAttribute
		WHERE     (TaskCode = @TaskCode)
		set @PrintOrder = @PrintOrder - (@PrintOrder % 10) + 10		
		end
	else
		set @PrintOrder = 10
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskProject] 
	(
	@TaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20) output
	)
AS
	set @ParentTaskCode = @TaskCode
	while exists(SELECT     ParentTaskCode
	             FROM         tbTaskFlow
	             WHERE     (ChildTaskCode = @ParentTaskCode))
		select @ParentTaskCode = ParentTaskCode
	             FROM         tbTaskFlow
	             WHERE     (ChildTaskCode = @ParentTaskCode)
		
	RETURN
GO
CREATE PROCEDURE dbo.spTaskSchedule
	(
	@ParentTaskCode nvarchar(20),
	@ActionOn datetime = null output
	)
AS
declare @UserId smallint
declare @StepNumber smallint
declare @TaskCode nvarchar(20)
declare @OffsetDays smallint
declare @UsedOnQuantity float
declare @Quantity float

	if @ActionOn is null
		begin
		select @ActionOn = ActionOn, @UserId = ActionById 
		from tbTask where TaskCode = @ParentTaskCode
		
		if @ActionOn != dbo.fnSystemAdjustToCalendar(@UserId, @ActionOn, 0)
			begin
			update tbTask
			set ActionOn = dbo.fnSystemAdjustToCalendar(@UserId, @ActionOn, 0)
			where TaskCode = @ParentTaskCode and TaskStatusCode < 3			
			end
		end
	
	Select @Quantity = Quantity from tbTask where TaskCode = @ParentTaskCode
	
	declare curAct cursor local for
		SELECT     tbTaskFlow.StepNumber, tbTaskFlow.ChildTaskCode, tbTask.ActionById, tbTaskFlow.OffsetDays, tbTaskFlow.UsedOnQuantity
		FROM         tbTaskFlow INNER JOIN
		                      tbTask ON tbTaskFlow.ChildTaskCode = tbTask.TaskCode
		WHERE     (tbTaskFlow.ParentTaskCode = @ParentTaskCode)
		ORDER BY tbTaskFlow.StepNumber DESC
	
	open curAct
	fetch next from curAct into @StepNumber, @TaskCode, @UserId, @OffsetDays, @UsedOnQuantity
	while @@FETCH_STATUS = 0
		begin
		set @ActionOn = dbo.fnSystemAdjustToCalendar(@UserId, @ActionOn, @OffsetDays)
		
		update tbTask
		set ActionOn = @ActionOn, 
			Quantity = @Quantity * @UsedOnQuantity,
			TotalCharge = case when @UsedOnQuantity = 0 then UnitCharge else UnitCharge * @Quantity * @UsedOnQuantity end,
			UpdatedOn = getdate(),
			UpdatedBy = (suser_sname())
		where TaskCode = @TaskCode and TaskStatusCode < 3
		
		exec dbo.spTaskSchedule @TaskCode, @ActionOn output
		fetch next from curAct into @StepNumber, @TaskCode, @UserId, @OffsetDays, @UsedOnQuantity
		end
	
	close curAct
	deallocate curAct	
	
	RETURN
GO
CREATE PROCEDURE dbo.spTaskSetStatus
	(
		@TaskCode nvarchar(20)
	)

AS
declare @ChildTaskCode nvarchar(20)
declare @TaskStatusCode smallint

	select @TaskStatusCode = TaskStatusCode
	from tbTask
	where TaskCode = @TaskCode
	
	declare curTask cursor local for
		SELECT     tbTaskFlow.ChildTaskCode
		FROM         tbTaskFlow INNER JOIN
		                      tbTask ON tbTaskFlow.ChildTaskCode = tbTask.TaskCode
		WHERE     (tbTaskFlow.ParentTaskCode = @TaskCode)

	open curTask
	fetch next from curTask into @ChildTaskCode
	while @@FETCH_STATUS = 0
		begin
		UPDATE    tbTask
		SET              TaskStatusCode = @TaskStatusCode
		WHERE     (TaskCode = @ChildTaskCode) and TaskStatusCode < 3
		
		exec dbo.spTaskSetStatus @ChildTaskCode
		fetch next from curTask into @ChildTaskCode
		end
		
	close curTask
	deallocate curTask
		
	RETURN 
GO
CREATE PROCEDURE [dbo].[spTaskWorkFlow] 
	(
	@TaskCode nvarchar(20)
	)
AS
	SELECT     tbTaskFlow.ParentTaskCode, tbTaskFlow.StepNumber, tbTask.TaskCode, tbTask.AccountCode, tbTask.ActivityCode, tbTask.TaskStatusCode, 
	                      tbTask.ActionOn, vwTaskCashMode.CashModeCode, tbTaskFlow.OffsetDays
	FROM         tbTask INNER JOIN
	                      tbTaskFlow ON tbTask.TaskCode = tbTaskFlow.ChildTaskCode LEFT OUTER JOIN
	                      vwTaskCashMode ON tbTask.TaskCode = vwTaskCashMode.TaskCode
	WHERE     (tbTaskFlow.ParentTaskCode = @TaskCode)
	ORDER BY tbTaskFlow.StepNumber, tbTaskFlow.ParentTaskCode
	RETURN
GO
CREATE OR ALTER  PROCEDURE dbo.spActivityMode
	(
	@ActivityCode nvarchar(50)
	)
AS
	SELECT     tbActivity.ActivityCode, tbActivity.UnitOfMeasure, tbTaskStatus.TaskStatus, tbCashCategory.CashModeCode
	FROM         tbActivity INNER JOIN
	                      tbTaskStatus ON tbActivity.TaskStatusCode = tbTaskStatus.TaskStatusCode LEFT OUTER JOIN
	                      tbCashCode ON tbActivity.CashCode = tbCashCode.CashCode LEFT OUTER JOIN
	                      tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE     (tbActivity.ActivityCode = @ActivityCode)
	RETURN 
GO
CREATE OR ALTER  PROCEDURE dbo.spActivityParent
	(
	@ActivityCode nvarchar(50),
	@ParentCode nvarchar(50) = null output
	)
AS
	if exists(SELECT     ParentCode
	          FROM         tbActivityFlow
	          WHERE     (ChildCode = @ActivityCode))
		SELECT @ParentCode = ParentCode
		FROM         tbActivityFlow
		WHERE     (ChildCode = @ActivityCode)
	else
		set @ParentCode = @ActivityCode
		
	RETURN 
GO
CREATE OR ALTER  PROCEDURE dbo.spActivityWorkFlow
	(
	@ActivityCode nvarchar(50)
	)
AS
	SELECT     tbActivity.ActivityCode, tbTaskStatus.TaskStatus, tbCashCategory.CashModeCode, tbActivity.UnitOfMeasure, tbActivityFlow.OffsetDays
	FROM         tbActivity INNER JOIN
	                      tbTaskStatus ON tbActivity.TaskStatusCode = tbTaskStatus.TaskStatusCode INNER JOIN
	                      tbActivityFlow ON tbActivity.ActivityCode = tbActivityFlow.ChildCode LEFT OUTER JOIN
	                      tbCashCode ON tbActivity.CashCode = tbCashCode.CashCode LEFT OUTER JOIN
	                      tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE     (tbActivityFlow.ParentCode = @ActivityCode)
	ORDER BY tbActivityFlow.StepNumber	


	RETURN 
GO
CREATE OR ALTER  PROCEDURE dbo.spTaskDefaultInvoiceType
	(
		@TaskCode nvarchar(20),
		@InvoiceTypeCode smallint OUTPUT
	)
AS
declare @CashMode smallint

	if exists(SELECT     CashModeCode
	          FROM         vwTaskCashMode
	          WHERE     (TaskCode = @TaskCode))
		SELECT   @CashMode = CashModeCode
		FROM         vwTaskCashMode
		WHERE     (TaskCode = @TaskCode)			          
	else
		set @CashMode = 2
		
	if @CashMode = 1
		set @InvoiceTypeCode = 3
	else
		set @InvoiceTypeCode = 1
		
	RETURN 
GO
CREATE OR ALTER  PROCEDURE dbo.spSettingNewCompany
	(
	@FirstNames nvarchar(50),
	@LastName nvarchar(50),
	@CompanyName nvarchar(50),
	@CompanyAddress ntext,
	@AccountCode nvarchar(50),
	@CompanyNumber nvarchar(20) = null,
	@VatNumber nvarchar(50) = null,
	@LandLine nvarchar(20) = null,
	@Fax nvarchar(20) = null,
	@Email nvarchar(50) = null,
	@WebSite nvarchar(128) = null
	)
AS
declare @UserId smallint
declare @CalendarCode nvarchar(10)
declare @MenuId smallint

declare @AppAccountCode nvarchar(10)
declare @TaxCode nvarchar(10)
declare @AddressCode nvarchar(15)

declare @SqlDataVersion real
	
	select top 1 @MenuId = MenuId from tbProfileMenu
	select top 1 @CalendarCode = CalendarCode from tbSystemCalendar 

	set @UserId = 1
	INSERT INTO tbUser
	                      (UserId, UserName, LogonName, CalendarCode, PhoneNumber, FaxNumber, EmailAddress, Administrator)
	VALUES     (@UserId, @FirstNames + N' ' + @LastName, SUSER_SNAME(), @CalendarCode, @LandLine, @Fax, @Email, 1)

	INSERT INTO tbUserMenu
	                      (UserId, MenuId)
	VALUES     (@UserId, @MenuId)

	set @AppAccountCode = left(@AccountCode, 10)
	set @TaxCode = 'T0'
	
	INSERT INTO tbOrg
	                      (AccountCode, AccountName, OrganisationTypeCode, OrganisationStatusCode, PhoneNumber, FaxNumber, EmailAddress, WebSite, CompanyNumber, 
	                      VatNumber, TaxCode)
	VALUES     (@AppAccountCode, @CompanyName, 8, 2, @LandLine, @Fax, @Email, @Website, @CompanyNumber, @VatNumber, @TaxCode)

	exec dbo.spOrgNextAddressCode @AppAccountCode, @AddressCode output
	
	insert into tbOrgAddress (AddressCode, AccountCode, Address)
	values (@AddressCode, @AppAccountCode, @CompanyAddress)

	INSERT INTO tbOrgContact
	                      (AccountCode, ContactName, FileAs, NickName, PhoneNumber, FaxNumber, EmailAddress)
	VALUES     (@AppAccountCode, @FirstNames + N' ' + @LastName, @LastName + N', ' + @FirstNames, @FirstNames, @LandLine, @Fax, @Email)	 

	SELECT @SqlDataVersion = DataVersion
	FROM         tbSystemInstall
	WHERE     (CategoryTypeCode = 0) AND (ReleaseTypeCode = 0)

	INSERT INTO tbOrgAccount
						(AccountCode, CashAccountCode, CashAccountName)
	VALUES     (@AccountCode, N'CASH', N'Petty Cash')	

	INSERT INTO tbSystemOptions
						(Identifier, Initialised, SQLDataVersion, AccountCode, DefaultPrintMode, BucketTypeCode, BucketIntervalCode, ShowCashGraphs, EmployersNI, 
						CorporationTax, Vat, GeneralTax)
	VALUES     (N'TRU', 0, @SQLDataVersion, @AppAccountCode, 2, 1, 2, 1, N'900', N'902', N'901', N'903')

	RETURN 1 
GO
/*********************************************************
 * Sql Data Creation Script
 * Source  (local)\TMTrader
 * Version 1.1.1
 *
 * Date    19/03/2008 17:18:58
 ********************************************************/


-- tbActivityAttributeType
insert into [tbActivityAttributeType] ([AttributeTypeCode], [AttributeType]) values (1, 'Order')
insert into [tbActivityAttributeType] ([AttributeTypeCode], [AttributeType]) values (2, 'Quote')

-- tbCashCategoryType
insert into [tbCashCategoryType] ([CategoryTypeCode], [CategoryType]) values (1, 'Cash Code')
insert into [tbCashCategoryType] ([CategoryTypeCode], [CategoryType]) values (2, 'Total')
insert into [tbCashCategoryType] ([CategoryTypeCode], [CategoryType]) values (3, 'Expression')

-- tbCashMode
insert into [tbCashMode] ([CashModeCode], [CashMode]) values (1, 'Expense')
insert into [tbCashMode] ([CashModeCode], [CashMode]) values (2, 'Income')
insert into [tbCashMode] ([CashModeCode], [CashMode]) values (3, 'Neutral')

-- tbCashTaxType
insert into [tbCashTaxType] ([TaxTypeCode], [TaxType]) values (1, 'Not applicable')
insert into [tbCashTaxType] ([TaxTypeCode], [TaxType]) values (2, 'Vat')
insert into [tbCashTaxType] ([TaxTypeCode], [TaxType]) values (3, 'N.I.')
insert into [tbCashTaxType] ([TaxTypeCode], [TaxType]) values (4, 'General')

-- tbCashStatus
insert into [tbCashStatus] ([CashStatusCode], [CashStatus]) values (1, 'Forecast')
insert into [tbCashStatus] ([CashStatusCode], [CashStatus]) values (2, 'Current')
insert into [tbCashStatus] ([CashStatusCode], [CashStatus]) values (3, 'Closed')
insert into [tbCashStatus] ([CashStatusCode], [CashStatus]) values (4, 'Archived')

-- tbCashType
insert into [tbCashType] ([CashTypeCode], [CashType]) values (1, 'TRADE')
insert into [tbCashType] ([CashTypeCode], [CashType]) values (2, 'TAX')
insert into [tbCashType] ([CashTypeCode], [CashType]) values (3, 'NOMINAL')
insert into [tbCashType] ([CashTypeCode], [CashType]) values (4, 'BANK')

-- tbInvoiceStatus
insert into [tbInvoiceStatus] ([InvoiceStatusCode], [InvoiceStatus]) values (2, 'Invoiced')
insert into [tbInvoiceStatus] ([InvoiceStatusCode], [InvoiceStatus]) values (3, 'Partially Paid')
insert into [tbInvoiceStatus] ([InvoiceStatusCode], [InvoiceStatus]) values (4, 'Paid')
insert into [tbInvoiceStatus] ([InvoiceStatusCode], [InvoiceStatus]) values (1, 'Pending')

-- tbInvoiceType
insert into [tbInvoiceType] ([InvoiceTypeCode], [InvoiceType], [CashModeCode], [NextNumber]) values (1, 'Sales Invoice', 2, 1060)
insert into [tbInvoiceType] ([InvoiceTypeCode], [InvoiceType], [CashModeCode], [NextNumber]) values (2, 'Credit Note', 1, 5004)
insert into [tbInvoiceType] ([InvoiceTypeCode], [InvoiceType], [CashModeCode], [NextNumber]) values (3, 'Purchase Invoice', 1, 3022)
insert into [tbInvoiceType] ([InvoiceTypeCode], [InvoiceType], [CashModeCode], [NextNumber]) values (4, 'Debit Note', 2, 4001)

-- tbOrgPaymentStatus
insert into [tbOrgPaymentStatus] ([PaymentStatusCode], [PaymentStatus]) values (1, 'Unposted')
insert into [tbOrgPaymentStatus] ([PaymentStatusCode], [PaymentStatus]) values (2, 'Payment')
insert into [tbOrgPaymentStatus] ([PaymentStatusCode], [PaymentStatus]) values (3, 'Cancelled')

-- tbOrgStatus
insert into [tbOrgStatus] ([OrganisationStatusCode], [OrganisationStatus]) values (1, 'Pending')
insert into [tbOrgStatus] ([OrganisationStatusCode], [OrganisationStatus]) values (2, 'Active')
insert into [tbOrgStatus] ([OrganisationStatusCode], [OrganisationStatus]) values (3, 'Hot')
insert into [tbOrgStatus] ([OrganisationStatusCode], [OrganisationStatus]) values (4, 'Dead')

-- tbOrgType
insert into [tbOrgType] ([OrganisationTypeCode], [CashModeCode], [OrganisationType]) values (1, 2, 'Prospect')
insert into [tbOrgType] ([OrganisationTypeCode], [CashModeCode], [OrganisationType]) values (2, 2, 'Customer')
insert into [tbOrgType] ([OrganisationTypeCode], [CashModeCode], [OrganisationType]) values (3, 1, 'Supplier')
insert into [tbOrgType] ([OrganisationTypeCode], [CashModeCode], [OrganisationType]) values (4, 1, 'Contractor')
insert into [tbOrgType] ([OrganisationTypeCode], [CashModeCode], [OrganisationType]) values (5, 2, 'Distributor')
insert into [tbOrgType] ([OrganisationTypeCode], [CashModeCode], [OrganisationType]) values (6, 1, 'Bank')
insert into [tbOrgType] ([OrganisationTypeCode], [CashModeCode], [OrganisationType]) values (7, 1, 'State')
insert into [tbOrgType] ([OrganisationTypeCode], [CashModeCode], [OrganisationType]) values (8, 2, 'Company')

-- tbProfileItemType
insert into [tbProfileItemType] ([ItemTypeCode], [ItemType]) values (1, 'Text')
insert into [tbProfileItemType] ([ItemTypeCode], [ItemType]) values (2, 'Integer')
insert into [tbProfileItemType] ([ItemTypeCode], [ItemType]) values (3, 'Long Integer')
insert into [tbProfileItemType] ([ItemTypeCode], [ItemType]) values (4, 'Single')
insert into [tbProfileItemType] ([ItemTypeCode], [ItemType]) values (5, 'Double')
insert into [tbProfileItemType] ([ItemTypeCode], [ItemType]) values (6, 'Currency')
insert into [tbProfileItemType] ([ItemTypeCode], [ItemType]) values (7, 'Boolean')
insert into [tbProfileItemType] ([ItemTypeCode], [ItemType]) values (8, 'DateTime')
insert into [tbProfileItemType] ([ItemTypeCode], [ItemType]) values (9, 'Memo')
insert into [tbProfileItemType] ([ItemTypeCode], [ItemType]) values (100, 'Label')
insert into [tbProfileItemType] ([ItemTypeCode], [ItemType]) values (103, 'Image')
insert into [tbProfileItemType] ([ItemTypeCode], [ItemType]) values (104, 'Command Button')
insert into [tbProfileItemType] ([ItemTypeCode], [ItemType]) values (105, 'Option Button')
insert into [tbProfileItemType] ([ItemTypeCode], [ItemType]) values (106, 'Check Box')
insert into [tbProfileItemType] ([ItemTypeCode], [ItemType]) values (107, 'Option Group')
insert into [tbProfileItemType] ([ItemTypeCode], [ItemType]) values (108, 'Bound Object Frame')
insert into [tbProfileItemType] ([ItemTypeCode], [ItemType]) values (109, 'Text Box')
insert into [tbProfileItemType] ([ItemTypeCode], [ItemType]) values (110, 'List Box')
insert into [tbProfileItemType] ([ItemTypeCode], [ItemType]) values (111, 'Combo Box')
insert into [tbProfileItemType] ([ItemTypeCode], [ItemType]) values (112, 'Sub Form')
insert into [tbProfileItemType] ([ItemTypeCode], [ItemType]) values (114, 'Object Frame')
insert into [tbProfileItemType] ([ItemTypeCode], [ItemType]) values (122, 'Toggle Button')
insert into [tbProfileItemType] ([ItemTypeCode], [ItemType]) values (123, 'Tab Control')
insert into [tbProfileItemType] ([ItemTypeCode], [ItemType]) values (124, 'Page')

-- tbProfileMenuCommand
insert into [tbProfileMenuCommand] ([Command], [CommandText]) values (0, 'Folder')
insert into [tbProfileMenuCommand] ([Command], [CommandText]) values (1, 'Link')
insert into [tbProfileMenuCommand] ([Command], [CommandText]) values (2, 'Form In Read Mode')
insert into [tbProfileMenuCommand] ([Command], [CommandText]) values (3, 'Form In Add Mode')
insert into [tbProfileMenuCommand] ([Command], [CommandText]) values (4, 'Form In Edit Mode')
insert into [tbProfileMenuCommand] ([Command], [CommandText]) values (5, 'Report')

-- tbProfileMenuOpenMode
insert into [tbProfileMenuOpenMode] ([OpenMode], [OpenModeDescription]) values (1, 'Normal')
insert into [tbProfileMenuOpenMode] ([OpenMode], [OpenModeDescription]) values (2, 'Datasheet')
insert into [tbProfileMenuOpenMode] ([OpenMode], [OpenModeDescription]) values (3, 'Default Printing')
insert into [tbProfileMenuOpenMode] ([OpenMode], [OpenModeDescription]) values (4, 'Direct Printing')
insert into [tbProfileMenuOpenMode] ([OpenMode], [OpenModeDescription]) values (5, 'Print Preview')
insert into [tbProfileMenuOpenMode] ([OpenMode], [OpenModeDescription]) values (6, 'Email RTF')
insert into [tbProfileMenuOpenMode] ([OpenMode], [OpenModeDescription]) values (7, 'Email HTML')
insert into [tbProfileMenuOpenMode] ([OpenMode], [OpenModeDescription]) values (8, 'Email Snapshot')
insert into [tbProfileMenuOpenMode] ([OpenMode], [OpenModeDescription]) values (9, 'Email PDF')

-- tbProfileObjectType
insert into [tbProfileObjectType] ([ObjectTypeCode], [ObjectType]) values (1, 'Schema')
insert into [tbProfileObjectType] ([ObjectTypeCode], [ObjectType]) values (2, 'Form')
insert into [tbProfileObjectType] ([ObjectTypeCode], [ObjectType]) values (3, 'Report')
insert into [tbProfileObjectType] ([ObjectTypeCode], [ObjectType]) values (4, 'Dialog')
insert into [tbProfileObjectType] ([ObjectTypeCode], [ObjectType]) values (5, 'Text')
insert into [tbProfileObjectType] ([ObjectTypeCode], [ObjectType]) values (6, 'Substitutes')

-- tbProfileText
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1003, 'Enter new menu name', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1004, 'Team Menu', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1005, 'Ok to delete <1>', 1)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1006, 'Documents cannot be converted into folders.
Either delete the document or create a new folder elsewhere on the menu.
Press esc key to undo changes.', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1007, '<Menu Item Text>', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1008, 'Documents cannot have other menu items added to them.
Please select a folder then try again.', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1009, 'The root cannot be deleted.
Please modify the text or remove the menu itself.', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1189, 'Error <1>', 1)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1190, '<1>
Source: <2>  (err <3>)
<4>', 4)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1192, 'Server error listing:', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1193, 'days', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1194, 'Ok to delete the selected task and all tasks upon which it depends?', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1207, 'Application Quit
You are about to exit the system.
Press Yes to continue with this operation.', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1208, 'Hello <1>

A/N: <3>
Job: <2>
Ref: <4>

<5>

{Status <6>}

<7>', 7)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1209, 'Best Regards,

<1>
<2>

T: <3>
M: <4>
W: <5>', 5)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1210, 'Okay to cancel invoice <1>?', 1)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1211, 'Invoice <1> cannot be cancelled because there are payments assigned to it.  Use the debit/credit facility if this account is not properly reconciled.', 1)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1212, 'Invoices are outstanding against account <1>
By specifying a cash code, invoices will not be matched.
Cash codes should only be entered for miscellaneous charges.', 1)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1213, 'Account <1> has no invoices outstanding for this payment and therefore cannot be posted.
Please specify a cash code so that one can be automatically generated.', 1)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (2002, 'Only administrators have access to the system configuration features of this application.', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (2003, 'You are not a registered user of this system.
Please contact the Administrator if you believe you should have access.', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (2004, 'The primary key you have entered contains invalid characters.
Digits and letters should be used for these keys.
Please amend accordingly or press Esc to cancel.', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (2018, 'The licence for this company is not valid.
Please contact your supplier to obtain a new licence key.', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (2019, 'Trial Version. Days Left: <1>', 1)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (2020, 'Licence Type: Full. Registered on <1>', 1)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (2021, 'Thank you for using the trial version. Please note: <1> day(s) left until you will need to obtain a full licence from your supplier.', 1)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (2136, 'You have attempted to execute an Application.Run command with an invalid string.
The run string is <1>
The error is <2>', 2)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (2188, '<1>', 1)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (2206, 'Reminder: You are due for a period end close down.  Please follow the relevant procedures to complete this task. Once all financial data has been consolidated, use the Administrator to move onto the next period.', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (2312, 'The system is not setup correctly.
Make sure you have completed the initialisation procedures then try again.', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (3002, 'Periods not generated successfully.
Contact support.', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (3003, 'Okay to close down the active period?
Before proceeding make sure that you have entered and checked your cash details.
All invoices and cash transactions will be transferred into the Cash Flow analysis module.', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (3004, 'Margin', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (3005, 'Opening Balance', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (3006, 'Rebuilding Accounts...', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (3007, 'Ok to rebuild cash accounts?
Make sure no transactions are being processed, as this will re-set and update all your invoices.', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (3008, 'Ok to rebuild cash flow history?
This would normally be required when payments or invoices have been retrospectively revised, or opening balances altered.', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (3009, 'Charged', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (3010, 'Service', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (3011, 'Ok to rebuild cash flow history for account <1>?
This would normally be required when payments or invoices have been retrospectively revised, or opening balances altered.', 1)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (3012, 'Ok to raise an invoice for this task?
Use the Invoicing program to create specific invoice types with multiple tasks and additional charges.', 0)

-- tbSystemBucketType
insert into [tbSystemBucketType] ([BucketTypeCode], [BucketType]) values (0, 'Default')
insert into [tbSystemBucketType] ([BucketTypeCode], [BucketType]) values (1, 'Sunday')
insert into [tbSystemBucketType] ([BucketTypeCode], [BucketType]) values (2, 'Monday')
insert into [tbSystemBucketType] ([BucketTypeCode], [BucketType]) values (3, 'Tuesday')
insert into [tbSystemBucketType] ([BucketTypeCode], [BucketType]) values (4, 'Wednesday')
insert into [tbSystemBucketType] ([BucketTypeCode], [BucketType]) values (5, 'Thursday')
insert into [tbSystemBucketType] ([BucketTypeCode], [BucketType]) values (6, 'Friday')
insert into [tbSystemBucketType] ([BucketTypeCode], [BucketType]) values (7, 'Saturday')
insert into [tbSystemBucketType] ([BucketTypeCode], [BucketType]) values (8, 'Month')

-- tbSystemBucketInterval
insert into [tbSystemBucketInterval] ([BucketIntervalCode], [BucketInterval]) values (1, 'Day')
insert into [tbSystemBucketInterval] ([BucketIntervalCode], [BucketInterval]) values (2, 'Week')
insert into [tbSystemBucketInterval] ([BucketIntervalCode], [BucketInterval]) values (3, 'Month')

-- tbSystemBucket
insert into [tbSystemBucket] ([Period], [BucketId], [BucketDescription], [AllowForecasts]) values (0, 'Overdue', 'Overdue Orders', 0)
insert into [tbSystemBucket] ([Period], [BucketId], [BucketDescription], [AllowForecasts]) values (1, 'Current', 'Current Week', 0)
insert into [tbSystemBucket] ([Period], [BucketId], [BucketDescription], [AllowForecasts]) values (2, 'Week 2', 'Week Two', 0)
insert into [tbSystemBucket] ([Period], [BucketId], [BucketDescription], [AllowForecasts]) values (3, 'Week 3', 'Week Three', 0)
insert into [tbSystemBucket] ([Period], [BucketId], [BucketDescription], [AllowForecasts]) values (4, 'Week 4', 'Week Four', 0)
insert into [tbSystemBucket] ([Period], [BucketId], [BucketDescription], [AllowForecasts]) values (8, 'Next Month', 'Next Month', 0)
insert into [tbSystemBucket] ([Period], [BucketId], [BucketDescription], [AllowForecasts]) values (16, '2 Months', '2 Months', 1)
insert into [tbSystemBucket] ([Period], [BucketId], [BucketDescription], [AllowForecasts]) values (52, 'Forward', 'Forward Orders', 1)

-- tbSystemDocType
insert into [tbSystemDocType] ([DocTypeCode], [DocType]) values (1, 'Quotation')
insert into [tbSystemDocType] ([DocTypeCode], [DocType]) values (2, 'Sales Order')
insert into [tbSystemDocType] ([DocTypeCode], [DocType]) values (3, 'Enquiry')
insert into [tbSystemDocType] ([DocTypeCode], [DocType]) values (4, 'Purchase Order')
insert into [tbSystemDocType] ([DocTypeCode], [DocType]) values (5, 'Sales Invoice')
insert into [tbSystemDocType] ([DocTypeCode], [DocType]) values (6, 'Credit Note')
insert into [tbSystemDocType] ([DocTypeCode], [DocType]) values (7, 'Debit Note')

-- tbSystemDoc
insert into [tbSystemDoc] ([DocTypeCode], [ReportName], [OpenMode], [Description]) values (1, 'QuotationStandard', 3, 'Standard Quotation')
insert into [tbSystemDoc] ([DocTypeCode], [ReportName], [OpenMode], [Description]) values (1, 'QuotationTextual', 3, 'Textual Quotation')
insert into [tbSystemDoc] ([DocTypeCode], [ReportName], [OpenMode], [Description]) values (2, 'SalesOrder', 8, 'Standard Sales Order')
insert into [tbSystemDoc] ([DocTypeCode], [ReportName], [OpenMode], [Description]) values (3, 'PurchaseEnquiryDeliveryStandard', 3, 'Standard Transport Enquiry')
insert into [tbSystemDoc] ([DocTypeCode], [ReportName], [OpenMode], [Description]) values (3, 'PurchaseEnquiryDeliveryTextual', 3, 'Textual Transport Enquiry')
insert into [tbSystemDoc] ([DocTypeCode], [ReportName], [OpenMode], [Description]) values (3, 'PurchaseEnquiryStandard', 8, 'Standard Purchase Enquiry')
insert into [tbSystemDoc] ([DocTypeCode], [ReportName], [OpenMode], [Description]) values (3, 'PurchaseEnquiryTextual', 3, 'Textual Purchase Enquiry')
insert into [tbSystemDoc] ([DocTypeCode], [ReportName], [OpenMode], [Description]) values (4, 'PurchaseOrder', 8, 'Standard Purchase Order')
insert into [tbSystemDoc] ([DocTypeCode], [ReportName], [OpenMode], [Description]) values (4, 'PurchaseOrderDelivery', 8, 'Purchase Order for Delivery')
insert into [tbSystemDoc] ([DocTypeCode], [ReportName], [OpenMode], [Description]) values (5, 'SalesInvoice', 3, 'Standard Sales Invoice')
insert into [tbSystemDoc] ([DocTypeCode], [ReportName], [OpenMode], [Description]) values (5, 'SalesInvoiceLetterhead', 3, 'Sales Invoice for Letterhead Paper')
insert into [tbSystemDoc] ([DocTypeCode], [ReportName], [OpenMode], [Description]) values (6, 'CreditNote', 3, 'Standard Credit Note')
insert into [tbSystemDoc] ([DocTypeCode], [ReportName], [OpenMode], [Description]) values (6, 'CreditNoteLetterhead', 3, 'Credit Note for Letterhead Paper')
insert into [tbSystemDoc] ([DocTypeCode], [ReportName], [OpenMode], [Description]) values (7, 'DebitNote', 3, 'Standard Debit Note')
insert into [tbSystemDoc] ([DocTypeCode], [ReportName], [OpenMode], [Description]) values (7, 'DebitNoteLetterhead', 3, 'Debit Note for Letterhead Paper')

-- tbSystemMonth
insert into [tbSystemMonth] ([MonthNumber], [MonthName]) values (1, 'JAN')
insert into [tbSystemMonth] ([MonthNumber], [MonthName]) values (2, 'FEB')
insert into [tbSystemMonth] ([MonthNumber], [MonthName]) values (3, 'MAR')
insert into [tbSystemMonth] ([MonthNumber], [MonthName]) values (4, 'APR')
insert into [tbSystemMonth] ([MonthNumber], [MonthName]) values (5, 'MAY')
insert into [tbSystemMonth] ([MonthNumber], [MonthName]) values (6, 'JUN')
insert into [tbSystemMonth] ([MonthNumber], [MonthName]) values (7, 'JUL')
insert into [tbSystemMonth] ([MonthNumber], [MonthName]) values (8, 'AUG')
insert into [tbSystemMonth] ([MonthNumber], [MonthName]) values (9, 'SEP')
insert into [tbSystemMonth] ([MonthNumber], [MonthName]) values (10, 'OCT')
insert into [tbSystemMonth] ([MonthNumber], [MonthName]) values (11, 'NOV')
insert into [tbSystemMonth] ([MonthNumber], [MonthName]) values (12, 'DEC')

-- tbTaskStatus
insert into [tbTaskStatus] ([TaskStatusCode], [TaskStatus]) values (1, 'Pending')
insert into [tbTaskStatus] ([TaskStatusCode], [TaskStatus]) values (2, 'Open')
insert into [tbTaskStatus] ([TaskStatusCode], [TaskStatus]) values (3, 'Closed')
insert into [tbTaskStatus] ([TaskStatusCode], [TaskStatus]) values (4, 'Charged')
insert into [tbTaskStatus] ([TaskStatusCode], [TaskStatus]) values (5, 'Cancelled')

-- tbSystemTaxCode
insert into [tbSystemTaxCode] ([TaxCode], [TaxRate], [TaxDescription], [TaxTypeCode]) values ('CORP', 0, 'Corporation Tax', 4)
insert into [tbSystemTaxCode] ([TaxCode], [TaxRate], [TaxDescription], [TaxTypeCode]) values ('INTEREST', 0, 'Interest Tax', 4)
insert into [tbSystemTaxCode] ([TaxCode], [TaxRate], [TaxDescription], [TaxTypeCode]) values ('N/A', 0, 'Untaxed', 1)
insert into [tbSystemTaxCode] ([TaxCode], [TaxRate], [TaxDescription], [TaxTypeCode]) values ('NI1', 0.121, 'Directors National Insurance', 3)
insert into [tbSystemTaxCode] ([TaxCode], [TaxRate], [TaxDescription], [TaxTypeCode]) values ('NI2', 0.121, 'Employees National Insurance', 3)
insert into [tbSystemTaxCode] ([TaxCode], [TaxRate], [TaxDescription], [TaxTypeCode]) values ('T0', 0, 'Zero Rated VAT', 2)
insert into [tbSystemTaxCode] ([TaxCode], [TaxRate], [TaxDescription], [TaxTypeCode]) values ('T1', 0.175, 'Standard Rate VAT', 2)
insert into [tbSystemTaxCode] ([TaxCode], [TaxRate], [TaxDescription], [TaxTypeCode]) values ('T2', 0, 'Tax Exemption', 2)

-- tbSystemUom
insert into [tbSystemUom] ([UnitOfMeasure]) values ('Each')
insert into [tbSystemUom] ([UnitOfMeasure]) values ('Hrs')
insert into [tbSystemUom] ([UnitOfMeasure]) values ('Kilo')
insert into [tbSystemUom] ([UnitOfMeasure]) values ('Mins')
insert into [tbSystemUom] ([UnitOfMeasure]) values ('Pallets')

-- tbProfileMenu
SET IDENTITY_INSERT [tbProfileMenu] ON
insert into [tbProfileMenu] ([MenuId], [MenuName]) values (1, 'Administrator')
SET IDENTITY_INSERT [tbProfileMenu] OFF

-- tbProfileMenuEntry
SET IDENTITY_INSERT [tbProfileMenuEntry] ON
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 1, 1, 0, 'Administrator', 0, '', 'Root', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 2, 2, 0, 'Settings', 0, 'Trader', '', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 3, 1, 1, 'Settings', 1, '', '2', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 4, 2, 1, 'Administration', 4, 'Trader', 'Admin', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 5, 2, 2, 'Sql Connect', 4, 'Trader', 'sysConnect', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 16, 2, 3, 'Data Definitions', 4, 'Trader', 'AdminDefinition', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 17, 3, 0, 'Cash Flow', 0, 'Trader', '', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 18, 1, 2, 'Cash Flow', 1, '', '3', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 19, 3, 1, 'Cash Forecast', 4, 'Trader', 'CashForecast', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 22, 3, 4, 'Manual Period End Recording', 4, 'Trader', 'CashPeriod', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 23, 4, 0, 'Maintenance', 0, 'Trader', '', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 24, 1, 3, 'Maintenance', 1, '', '4', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 25, 4, 1, 'Organisations', 4, 'Trader', 'OrgMaintenance', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 29, 4, 2, 'Activities and Workflow Definitions', 4, 'Trader', 'ActivityEdit', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 30, 5, 0, 'Work Flow', 0, 'Trader', '', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 31, 1, 4, 'Work Flow', 1, '', '5', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 32, 5, 1, 'Task Explorer', 4, 'Trader', 'TaskExplorer', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 33, 5, 2, 'Document Manager', 4, 'Trader', 'DocManager', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 34, 5, 3, 'Raise Invoices', 4, 'Trader', 'Invoicing', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 35, 6, 0, 'Information', 0, 'Trader', '', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 36, 1, 5, 'Information', 1, '', '6', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 37, 6, 1, 'Organisation Enquiry', 2, 'Trader', 'OrgEnquiry', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 38, 6, 2, 'Invoice Register', 4, 'Trader', 'InvoiceRegister', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 39, 5, 4, 'Payment Entry', 4, 'Trader', 'PaymentEntry', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 40, 6, 3, 'Cash Statements', 4, 'Trader', 'PaymentAccount', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 41, 6, 4, 'Data Warehouse', 4, 'Trader', 'Warehouse', 1)
SET IDENTITY_INSERT [tbProfileMenuEntry] OFF

-- tbCashCategory
insert into [tbCashCategory] ([CategoryCode], [Category], [CategoryTypeCode], [CashModeCode], [CashTypeCode], [DisplayOrder], [ManualForecast]) values ('1', 'Sales', 1, 2, 1, 1, 0)
insert into [tbCashCategory] ([CategoryCode], [Category], [CategoryTypeCode], [CashModeCode], [CashTypeCode], [DisplayOrder], [ManualForecast]) values ('10', 'Gross Profit Margin', 3, 3, 1, 1, 0)
insert into [tbCashCategory] ([CategoryCode], [Category], [CategoryTypeCode], [CashModeCode], [CashTypeCode], [DisplayOrder], [ManualForecast]) values ('11', 'Net Profit Margin', 3, 3, 1, 2, 0)
insert into [tbCashCategory] ([CategoryCode], [Category], [CategoryTypeCode], [CashModeCode], [CashTypeCode], [DisplayOrder], [ManualForecast]) values ('12', 'Investments', 1, 2, 1, 5, 0)
insert into [tbCashCategory] ([CategoryCode], [Category], [CategoryTypeCode], [CashModeCode], [CashTypeCode], [DisplayOrder], [ManualForecast]) values ('3', 'Direct Costs', 1, 1, 1, 2, 0)
insert into [tbCashCategory] ([CategoryCode], [Category], [CategoryTypeCode], [CashModeCode], [CashTypeCode], [DisplayOrder], [ManualForecast]) values ('4', 'Fixed Costs', 1, 1, 1, 4, 0)
insert into [tbCashCategory] ([CategoryCode], [Category], [CategoryTypeCode], [CashModeCode], [CashTypeCode], [DisplayOrder], [ManualForecast]) values ('5', 'Salaries', 1, 1, 1, 3, 1)
insert into [tbCashCategory] ([CategoryCode], [Category], [CategoryTypeCode], [CashModeCode], [CashTypeCode], [DisplayOrder], [ManualForecast]) values ('6', 'Inland Revenue', 1, 1, 2, 4, 0)
insert into [tbCashCategory] ([CategoryCode], [Category], [CategoryTypeCode], [CashModeCode], [CashTypeCode], [DisplayOrder], [ManualForecast]) values ('7', 'Depreciation', 1, 1, 3, 5, 1)
insert into [tbCashCategory] ([CategoryCode], [Category], [CategoryTypeCode], [CashModeCode], [CashTypeCode], [DisplayOrder], [ManualForecast]) values ('8', 'Current Assets', 1, 1, 3, 6, 0)
insert into [tbCashCategory] ([CategoryCode], [Category], [CategoryTypeCode], [CashModeCode], [CashTypeCode], [DisplayOrder], [ManualForecast]) values ('9', 'Bank Accounts', 1, 3, 4, 7, 0)
insert into [tbCashCategory] ([CategoryCode], [Category], [CategoryTypeCode], [CashModeCode], [CashTypeCode], [DisplayOrder], [ManualForecast]) values ('13', 'Costs', 2, 3, 1, 3, 0)
insert into [tbCashCategory] ([CategoryCode], [Category], [CategoryTypeCode], [CashModeCode], [CashTypeCode], [DisplayOrder], [ManualForecast]) values ('14', 'Gross Profit', 2, 3, 1, 1, 0)
insert into [tbCashCategory] ([CategoryCode], [Category], [CategoryTypeCode], [CashModeCode], [CashTypeCode], [DisplayOrder], [ManualForecast]) values ('15', 'Net Profit', 2, 3, 1, 2, 0)

-- tbCashCode
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('100', 'Sales Home', '1', 'T0')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('101', 'Sales Export', '1', 'T0')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('102', 'Carriage Charged', '1', 'T0')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('103', 'Installations', '1', 'T0')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('104', 'Company Loan', '12', 'T0')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('105', 'Interest', '1', 'N/A')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('200', 'Direct Materials', '3', 'T0')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('201', 'Labour', '3', 'T0')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('202', 'Subcontraction', '3', 'T0')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('203', 'Carriage', '3', 'T0')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('204', 'Postage and Packing', '4', 'T0')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('205', 'Web Costs', '4', 'T0')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('206', 'Hardware', '4', 'T0')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('207', 'Software', '4', 'T0')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('300', 'General Expenses', '4', 'T0')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('301', 'Communications', '4', 'T0')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('302', 'Professional Fees', '4', 'T0')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('400', 'Directors Salaries', '5', 'NI1')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('401', 'Employee Salaries', '5', 'NI2')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('402', 'Pensions', '5', 'N/A')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('500', 'Finished Goods', '8', 'N/A')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('501', 'Materials', '8', 'N/A')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('502', 'Office Equipment', '7', 'N/A')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('503', 'Plant', '7', 'N/A')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('600', 'Company Cash', '9', 'N/A')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('900', 'Employers N.I.', '6', 'N/A')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('901', 'Value Added Tax', '6', 'N/A')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('902', 'Corporation Tax', '6', 'N/A')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('903', 'General Taxes', '6', 'N/A')

-- tbCashCategoryExp
insert into [tbCashCategoryExp] ([CategoryCode], [Expression], [Format]) values ('10', 'IF([Sales]=0, 0, [Gross Profit]/[Sales])', '0%')
insert into [tbCashCategoryExp] ([CategoryCode], [Expression], [Format]) values ('11', 'IF([Sales]=0, 0, [Net Profit]/[Sales])', '0%')

-- tbCashCategoryTotal
insert into [tbCashCategoryTotal] ([ParentCode], [ChildCode]) values ('13', '3')
insert into [tbCashCategoryTotal] ([ParentCode], [ChildCode]) values ('13', '4')
insert into [tbCashCategoryTotal] ([ParentCode], [ChildCode]) values ('14', '1')
insert into [tbCashCategoryTotal] ([ParentCode], [ChildCode]) values ('14', '3')
insert into [tbCashCategoryTotal] ([ParentCode], [ChildCode]) values ('15', '1')
insert into [tbCashCategoryTotal] ([ParentCode], [ChildCode]) values ('15', '3')
insert into [tbCashCategoryTotal] ([ParentCode], [ChildCode]) values ('15', '4')
insert into [tbCashCategoryTotal] ([ParentCode], [ChildCode]) values ('15', '5')

-- tbSystemCalendar
insert into [tbSystemCalendar] ([CalendarCode], [Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday]) values ('OFFICE', 1, 1, 1, 1, 1, 0, 0)

-- tbSystemCodeExclusion
insert into [tbSystemCodeExclusion] ([ExcludedTag]) values ('Limited')
insert into [tbSystemCodeExclusion] ([ExcludedTag]) values ('Ltd')
insert into [tbSystemCodeExclusion] ([ExcludedTag]) values ('PLC')


-- tbActivity
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Consultation', 1, null, 'Hrs', '100', 0, 1)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Site Installation', 1, null, 'Each', '103', 0, 0)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Trial Installation', 1, null, 'Each', '103', 0, 1)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Support Call', 3, null, 'Mins', '100', 0, 0)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Support Response', 2, null, 'Mins', '100', 0, 0)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Training', 1, null, 'Hrs', '100', 0, 1)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Purchasing', 1, null, 'Each', '200', 0, 1)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Delivery', 1, null, 'Pallets', '203', 0, 1)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Material Purchase', 1, null, 'Kilo', '200', 0, 1)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Request for Comment', 1, null, 'Hrs', null, 0, 0)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Action', 1, null, 'Mins', null, 0, 0)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Site Visit', 1, '<div><strong><u>Visit Report</u></strong></div>', 'Hrs', null, 0, 0)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Telephone Call', 3, null, 'Mins', null, 0, 0)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Urgent Call Back', 2, null, 'Mins', null, 0, 0)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Email Response', 3, null, 'Mins', null, 0, 0)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Visitor', 1, null, 'Hrs', null, 0, 0)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Send By Post', 3, null, 'Hrs', null, 0, 0)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Quotation', 3, null, 'Hrs', null, 0, 0)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Progress', 2, null, 'Hrs', null, 0, 0)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Meeting', 2, null, 'Hrs', null, 0, 0)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Cold Call', 3, null, 'Hrs', null, 0, 0)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Non-urgent Call Back', 1, null, 'Hrs', null, 0, 0)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Literature Sent', 1, null, 'Hrs', null, 0, 0)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Request for Change', 1, null, 'Hrs', null, 0, 0)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Sales Campaign', 1, null, 'Each', null, 0, 0)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Follow Up', 1, null, 'Hrs', null, 0, 0)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Demonstration', 1, null, 'Hrs', null, 0, 0)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Telephone Call for Response', 2, null, 'Mins', null, 0, 0)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Project', 1, null, 'Each', '100', 0, 1)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Production', 1, null, 'Each', '202', 0, 1)
insert into [tbActivity] ([ActivityCode], [TaskStatusCode], [DefaultText], [UnitOfMeasure], [CashCode], [UnitCharge], [PrintOrder]) values ('Design', 1, null, 'Each', '202', 0, 1)


-- tbActivityFlow
insert into [tbActivityFlow] ([ParentCode], [StepNumber], [ChildCode], [OffsetDays], [UsedOnQuantity]) values ('Support Call', 1, 'Support Response', 0, 0)
insert into [tbActivityFlow] ([ParentCode], [StepNumber], [ChildCode], [OffsetDays], [UsedOnQuantity]) values ('Project', 10, 'Design', 5, 0)
insert into [tbActivityFlow] ([ParentCode], [StepNumber], [ChildCode], [OffsetDays], [UsedOnQuantity]) values ('Project', 30, 'Production', 5, 1)
insert into [tbActivityFlow] ([ParentCode], [StepNumber], [ChildCode], [OffsetDays], [UsedOnQuantity]) values ('Project', 40, 'Delivery', 0, 1)
insert into [tbActivityFlow] ([ParentCode], [StepNumber], [ChildCode], [OffsetDays], [UsedOnQuantity]) values ('Production', 1, 'Material Purchase', 10, 0.0002)
insert into [tbActivityFlow] ([ParentCode], [StepNumber], [ChildCode], [OffsetDays], [UsedOnQuantity]) values ('Trial Installation', 1, 'Site Visit', 0, 1)
insert into [tbActivityFlow] ([ParentCode], [StepNumber], [ChildCode], [OffsetDays], [UsedOnQuantity]) values ('Site Installation', 1, 'Site Visit', 0, 1)
insert into [tbActivityFlow] ([ParentCode], [StepNumber], [ChildCode], [OffsetDays], [UsedOnQuantity]) values ('Sales Campaign', 1, 'Literature Sent', 5, 1)
insert into [tbActivityFlow] ([ParentCode], [StepNumber], [ChildCode], [OffsetDays], [UsedOnQuantity]) values ('Sales Campaign', 2, 'Follow Up', 5, 1)
insert into [tbActivityFlow] ([ParentCode], [StepNumber], [ChildCode], [OffsetDays], [UsedOnQuantity]) values ('Sales Campaign', 3, 'Demonstration', 5, 1)
insert into [tbActivityFlow] ([ParentCode], [StepNumber], [ChildCode], [OffsetDays], [UsedOnQuantity]) values ('Sales Campaign', 4, 'Follow Up', 5, 1)
insert into [tbActivityFlow] ([ParentCode], [StepNumber], [ChildCode], [OffsetDays], [UsedOnQuantity]) values ('Sales Campaign', 5, 'Trial Installation', 0, 2)

-- tbProfileObject
insert into [tbProfileObject] ([ObjectTypeCode], [ObjectName], [ProjectName], [Caption], [SubObject]) values (1, 'System Fields', 'Trader', '', 0)

-- tbProfileObjectDetail
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'AccountClosed', 7, 'Closed?', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'AccountCode', 1, 'Ac/Cd', '', '', 10, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'AccountName', 1, 'Account Name', '', '', 255, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'AccountNumber', 1, 'Ac/No', '', '', 20, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'AccountSource', 1, 'Source', '', '', 100, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ActionById', 2, 'Action By Id', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ActionedOn', 8, 'Actioned On', '', '', 0, 1, 'Medium Date')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ActionName', 1, 'Action', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ActionOn', 8, 'Action On', '', '', 0, 1, 'Medium Date')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ActivityCode', 1, 'Activity Code', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Address', 9, 'Address', '', '', 1073741823, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'AddressCode', 1, 'Address Code', '', '', 15, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'AddressCodeFrom', 1, 'Address From', '', '', 15, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'AddressCodeTo', 1, 'Address To', '', '', 15, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Administrator', 7, 'Administrator?', '', '', 0, 1, 'Yes/No')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'AllowForecasts', 7, 'Forecasts?', '', '', 0, 1, 'Yes/No')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'AreaCode', 1, 'Area Code', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Argument', 1, 'Argument', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Arguments', 2, 'Arguments', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Attribute', 1, 'Attribute', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'AttributeDescription', 1, 'Description', '', '', 255, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'AttributeType', 1, 'Type', '', '', 20, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'AttributeTypeCode', 2, 'Type Code', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Avatar', 9, 'Avatar', '', '', 2147483647, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Balance', 6, 'Balance', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'BucketDescription', 1, 'Description', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'BucketId', 1, 'Id', '', '', 10, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'BucketInterval', 1, 'Interval', '', '', 15, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'BucketIntervalCode', 2, 'Interval/Cd', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'BucketType', 1, 'Type', '', '', 25, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'BucketTypeCode', 2, 'Type/Cd', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'BusinessDescription', 9, 'Business', '', '', 1073741823, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CalendarCode', 1, 'Cal/Cd', '', '', 10, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Caption', 9, 'Caption', '', '', 1073741823, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Cash', 6, 'Cash', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CashAccountCode', 1, 'Cash Ac/Cd', '', '', 10, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CashAccountName', 1, 'Cash Ac/Name', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CashCode', 1, 'Cash Code', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CashDescription', 1, 'Cash Description', '', '', 100, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CashMode', 1, 'Polarity', '', '', 10, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CashModeCode', 2, 'Polarity/Cd', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CashNI', 6, 'Cash NI', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CashStatus', 1, 'Status', '', '', 15, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CashStatusCode', 2, 'Status/Cd', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CashTax', 6, 'Cash Tax', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CashTaxNI', 6, 'Cash Tax NI', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CashType', 1, 'Type', '', '', 25, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CashTypeCode', 2, 'Type/Cd', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CashValue', 6, 'Cash Value', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CashVat', 6, 'Cash Vat', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Category', 1, 'Category', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CategoryCode', 1, 'Cat/Cd', '', '', 10, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CategoryId', 2, 'Category Id', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CategoryType', 1, 'Type', '', '', 20, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CategoryTypeCode', 2, 'Type/Cd', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Charge', 6, 'Charge', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CharLength', 3, 'Char Length', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ChildCode', 1, 'Code', '', '', 10, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ChildTaskCode', 1, 'Child Task/Cd', '', '', 20, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ClosingBalance', 6, 'Closing Balance', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Collect', 6, 'Collect', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ColumnName', 1, 'Column', '', '', 128, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Command', 2, 'Command', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CommandText', 1, 'Command Text', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CompanyBalance', 6, 'Company Balance', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CompanyNumber', 1, 'Company No', '', '', 20, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ContactName', 1, 'Contact', '', '', 100, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ControlTipText', 9, 'Control Tip Text', '', '', 1073741823, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CorporationTax', 1, 'Corp. Tax', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'CurrentBalance', 6, 'Current Balance', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'DataType', 1, 'DataType', '', '', 128, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'DataVersion', 5, 'Data Version', '', '', 0, 1, 'General Number')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'DateOfBirth', 8, 'D.O.B', '', '', 0, 1, 'Medium Date')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'DefaultPrintMode', 2, 'Print Mode', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'DefaultText', 1, 'Default Text', '', '', 255, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Department', 1, 'Department', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Description', 1, 'Description', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'DisplayOrder', 2, 'Display Order', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'DocType', 1, 'Doc Type', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'DocTypeCode', 2, 'Doc Type/Cd', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'DocumentDescription', 9, 'Description', '', '', 1073741823, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'DocumentImage', 9, 'Document', '', '', 2147483647, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'DocumentName', 1, 'Document Name', '', '', 255, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'EmailAddress', 1, 'Email', '', '', 255, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'EmployersNI', 1, 'Employers NI', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'EntryId', 3, 'Entry Id', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'EntryNumber', 3, 'Entry No', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ExcludedTag', 1, 'Excluded Tag', '', '', 100, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ExportPurchases', 6, 'Export Purchases', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ExportPurchasesVat', 6, 'Export Purchases Vat', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ExportSales', 6, 'Export Sales', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ExportSalesVat', 6, 'Export Sales Vat', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Expression', 1, 'Expression', '', '', 256, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'FaxNumber', 1, 'Fax No', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'FileAs', 1, 'File As', '', '', 100, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'FolderId', 2, 'Folder Id', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ForecastNI', 6, 'Forecast NI', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ForecastTax', 6, 'Forecast Tax', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ForecastValue', 6, 'Forecast Value', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ForecastVat', 6, 'Forecast Vat', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ForeignJurisdiction', 7, 'Foreign?', '', '', 0, 1, 'Yes/No')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Format', 1, 'Format', '', '', 100, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'FormatString', 1, 'Format Str', '', '', 20, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Friday', 7, 'Friday?', '', '', 0, 1, 'Yes/No')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'GeneralTax', 1, 'General Tax', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Hobby', 1, 'Hobby', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'HomePurchases', 6, 'Hom ePurchases', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'HomePurchasesVat', 6, 'Home Purchases Vat', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'HomeSales', 6, 'Home Sales', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'HomeSalesVat', 6, 'Home Sales Vat', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Id', 3, 'Id', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Identifier', 1, 'Identifier', '', '', 4, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'IndustrySector', 1, 'Sector', '', '', 255, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Information', 9, 'Information', '', '', 1073741823, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Initialised', 7, 'Initialised?', '', '', 0, 1, 'Yes/No')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'InsertedBy', 1, 'Inserted By', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'InsertedOn', 8, 'Inserted On', '', '', 0, 1, 'Medium Date')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'InstalledBy', 1, 'Installed By', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'InstalledOn', 8, 'Installed On', '', '', 0, 1, 'Medium Date')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'InstallId', 3, 'Install Id', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'InvoicedOn', 8, 'Invoiced On', '', '', 0, 1, 'Medium Date')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'InvoiceNI', 6, 'Invoice NI', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'InvoiceNumber', 1, 'Invoice No', '', '', 20, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'InvoiceQuantity', 5, 'Invoice Qty', '', '', 0, 1, 'General Number')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'InvoiceStatus', 1, 'Status', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'InvoiceStatusCode', 2, 'Status/Cd', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'InvoiceTax', 6, 'Invoice Tax', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'InvoiceTaxNI', 6, 'Invoice Tax NI', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'InvoiceType', 1, 'Type', '', '', 20, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'InvoiceTypeCode', 2, 'Type/Cd', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'InvoiceValue', 6, 'Invoice Value', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'InvoiceValueTotal', 6, 'Invoice Value Total', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'InvoiceVat', 6, 'Invoice Vat', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ItemId', 2, 'Item Id', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ItemName', 1, 'Item Name', '', '', 100, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ItemReference', 9, 'Reference', '', '', 1073741823, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ItemText', 1, 'Item Text', '', '', 255, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ItemType', 1, 'Item Type', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ItemTypeCode', 2, 'Type/Cd', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ItemValue', 6, 'Item Value', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'JobTitle', 1, 'Job Title', '', '', 100, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'LastEntry', 3, 'Last Entry', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Length', 3, 'Length', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Licence', 1, 'Licence', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'LicenceType', 2, 'Licence Type', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'LinkName', 1, 'Link Name', '', '', 100, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Logo', 9, 'Logo', '', '', 2147483647, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'LogonName', 1, 'Logon Name', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ManualForecast', 7, 'Manual Forecast?', '', '', 0, 1, 'Yes/No')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'MaterialStoreValue', 6, 'Material Store Value', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'MaterialWipValue', 6, 'Material Wip Value', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'MenuId', 2, 'Menu Id', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'MenuName', 1, 'Menu Name', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Message', 9, 'Message', '', '', 1073741823, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'MobileNumber', 1, 'Mobile No', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Monday', 7, 'Monday?', '', '', 0, 1, 'Yes/No')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'MonthName', 1, 'Month', '', '', 10, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'MonthNumber', 2, 'Month No', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'NameTitle', 1, 'Title', '', '', 25, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'NextNumber', 3, 'Next No.', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'NickName', 1, 'Nick Name', '', '', 100, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Note', 9, 'Note', '', '', 1073741823, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Notes', 9, 'Notes', '', '', 1073741823, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'NumberOfEmployees', 3, 'Employees', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ObjectName', 1, 'Object Name', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ObjectType', 1, 'Object Type', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ObjectTypeCode', 2, 'Type/Cd', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'OffsetDays', 2, 'Offset', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'OpeningBalance', 6, 'Opening Balance', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'OpenMode', 2, 'Open Mode', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'OpenModeDescription', 1, 'Open Mode', '', '', 20, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'OrderBy', 3, 'Order By', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'OrganisationStatus', 1, 'Status', '', '', 255, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'OrganisationStatusCode', 2, 'Status/Cd', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'OrganisationType', 1, 'Type', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'OrganisationTypeCode', 2, 'Type/Cd', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'OutstandingValue', 6, 'Outstanding Value', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Owner', 1, 'Owner', '', '', 128, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'OwnerName', 1, 'Owner', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'PaidBalance', 6, 'Paid Balance', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'PaidInValue', 6, 'Paid In Value', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'PaidOn', 8, 'Paid On', '', '', 0, 1, 'Medium Date')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'PaidOutValue', 6, 'Paid Out Value', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'PaidTaxValue', 6, 'Paid Tax Value', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'PaidValue', 6, 'Paid Value', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ParentCode', 1, 'Parent/Cd', '', '', 10, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ParentTaskCode', 1, 'Parent Task/Cd', '', '', 20, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Pay', 6, 'Pay', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'PaymentCode', 1, 'Pay/Cd', '', '', 20, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'PaymentReference', 1, 'Pay/Ref', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'PaymentStatus', 1, 'Status', '', '', 20, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'PaymentStatusCode', 2, 'Status/Cd', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'PaymentTerms', 1, 'Terms', '', '', 100, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Period', 2, 'Period', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'PeriodOn', 1, 'Period On', '', '', 61, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'PhoneNumber', 1, 'Phone No', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Photo', 9, 'Photo', '', '', 2147483647, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Precision', 2, 'Precision', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Printed', 7, 'Printed?', '', '', 0, 1, 'Yes/No')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'PrintOrder', 2, 'Print Order', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ProductionStoreValue', 6, 'Production Store Value', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ProductionWipValue', 6, 'Production Wip Value', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ProjectName', 1, 'Project Name', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Quantity', 5, 'Qty', '', '', 0, 1, 'General Number')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Reference', 1, 'Reference', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ReleaseTypeCode', 2, 'Type/Cd', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ReportName', 1, 'Report Name', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Saturday', 7, 'Saturday?', '', '', 0, 1, 'Yes/No')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'SectionCode', 1, 'Section Code', '', '', 20, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'SectionContent', 1, 'Section Content', '', '', 255, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ShowCashGraphs', 7, 'Show Cash Graphs?', '', '', 0, 1, 'Yes/No')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Signature', 9, 'Signature', '', '', 2147483647, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'SortCode', 1, 'Sort Code', '', '', 10, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'SpouseName', 1, 'Spouses Name', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'SQLDataVersion', 4, 'Data Version', '', '', 0, 1, 'General Number')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'SqlIndex', 1, 'Sql Index', '', '', 150, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'SqlView', 1, 'Sql View', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'StartMonth', 2, 'Start Month', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'StartOn', 8, 'Start On', '', '', 0, 1, 'Medium Date')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'StatementDays', 2, 'Statement', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'StatementType', 1, 'Statement Type', '', '', 20, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'StatusBarText', 9, 'Status BarText', '', '', 1073741823, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'StepNumber', 2, 'Step No', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'SubObject', 7, 'SubObject?', '', '', 0, 1, 'Yes/No')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Sunday', 7, 'Sunday?', '', '', 0, 1, 'Yes/No')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'TableName', 1, 'Table Name', '', '', 128, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'TaskCode', 1, 'Task Code', '', '', 20, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'TaskNotes', 9, 'Task Notes', '', '', 1073741823, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'TaskStatus', 1, 'Task Status', '', '', 100, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'TaskStatusCode', 2, 'Status/Cd', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'TaskTitle', 1, 'Title', '', '', 100, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Tax', 6, 'Tax', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'TaxCode', 1, 'Tax Code', '', '', 10, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'TaxDescription', 1, 'Tax Description', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'TaxedBalance', 6, 'Taxed Balance', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'TaxInValue', 6, 'Tax In Value', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'TaxOutValue', 6, 'Tax Out Value', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'TaxRate', 5, 'Tax Rate', '', '', 0, 1, 'General Number')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'TaxType', 1, 'Tax Type', '', '', 20, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'TaxTypeCode', 2, 'Type/Cd', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'TaxValue', 6, 'Tax Value', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'TaxValueTotal', 6, 'Tax Value Total', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'TextId', 3, 'Text Id', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Thursday', 7, 'Thursday?', '', '', 0, 1, 'Yes/No')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Timstamp', 8, 'Timstamp', '', '', 0, 1, 'Medium Date')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ToCollect', 6, 'To Collect', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ToPay', 6, 'To Pay', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'TotalCharge', 6, 'Total Charge', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'TotalInvoiceValue', 6, 'Total Invoice Value', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'TotalTaxValue', 6, 'Total Tax Value', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'TransactedOn', 8, 'Transacted On', '', '', 0, 1, 'Medium Date')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Tuesday', 7, 'Tuesday?', '', '', 0, 1, 'Yes/No')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Turnover', 6, 'Turnover', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'UnavailableOn', 8, 'Unavailable On', '', '', 0, 1, 'Medium Date')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'UnitCharge', 6, 'Unit Charge', '', '', 0, 1, 'Currency')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'UnitOfMeasure', 1, 'U.O.M.', '', '', 15, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'UpdatedBy', 1, 'Updated By', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'UpdatedOn', 8, 'Updated On', '', '', 0, 1, 'Medium Date')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'UsedOnQuantity', 5, 'U.O.Q.', '', '', 0, 1, 'General Number')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'UserId', 2, 'User Id', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'UserName', 1, 'User Name', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'ValidateClient', 7, 'Validate Client?', '', '', 0, 1, 'Yes/No')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Vat', 1, 'Vat', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'VatNumber', 1, 'Vat No', '', '', 50, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Visible', 7, 'Visible?', '', '', 0, 1, 'Yes/No')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'WebSite', 1, 'Web Site', '', '', 255, 1, '')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'Wednesday', 7, 'Wednesday?', '', '', 0, 1, 'Yes/No')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'YearNumber', 2, 'Year No', '', '', 0, 1, '0')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'OnMailingList', 7, 'Mail List?', '', '', 0, 1, 'Yes/No')
GO
