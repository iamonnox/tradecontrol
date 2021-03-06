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

USE master;
DROP DATABASE IF EXISTS misTradeControl;
GO
CREATE DATABASE misTradeControl;
GO
USE misTradeControl;
GO

GO

GO
USE misTradeControl
GO
CREATE SCHEMA [Activity]; 
GO
CREATE SCHEMA [App]; 
GO
CREATE SCHEMA [Cash]; 
GO
CREATE SCHEMA [Invoice]; 
GO
CREATE SCHEMA [Org]; 
GO
CREATE SCHEMA [Task]; 
GO
CREATE SCHEMA [Usr]; 
GO

GO

GO
CREATE TABLE [Activity].[tbActivity](
	[ActivityCode] [nvarchar](50) NOT NULL,
	[TaskStatusCode] [smallint] NOT NULL,
	[DefaultText] [ntext] NULL,
	[UnitOfMeasure] [nvarchar](15) NOT NULL,
	[CashCode] [nvarchar](50) NULL,
	[UnitCharge] [money] NOT NULL,
	[PrintOrder] [bit] NOT NULL,
	[RegisterName] [nvarchar](50) NULL,
	[InsertedBy] [nvarchar](50) NOT NULL,
	[InsertedOn] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](50) NOT NULL,
	[UpdatedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_Activity_tbActivityCode] PRIMARY KEY NONCLUSTERED 
(
	[ActivityCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Activity].[tbAttribute](
	[ActivityCode] [nvarchar](50) NOT NULL,
	[Attribute] [nvarchar](50) NOT NULL,
	[PrintOrder] [smallint] NOT NULL,
	[AttributeTypeCode] [smallint] NOT NULL,
	[DefaultText] [nvarchar](400) NULL,
	[InsertedBy] [nvarchar](50) NOT NULL,
	[InsertedOn] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](50) NOT NULL,
	[UpdatedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_Activity_tbAttribute] PRIMARY KEY CLUSTERED 
(
	[ActivityCode] ASC,
	[Attribute] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Activity].[tbAttributeType](
	[AttributeTypeCode] [smallint] NOT NULL,
	[AttributeType] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_Activity_tbAttributeType] PRIMARY KEY CLUSTERED 
(
	[AttributeTypeCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Activity].[tbFlow](
	[ParentCode] [nvarchar](50) NOT NULL,
	[StepNumber] [smallint] NOT NULL,
	[ChildCode] [nvarchar](50) NOT NULL,
	[OffsetDays] [smallint] NOT NULL,
	[UsedOnQuantity] [float] NOT NULL,
	[InsertedBy] [nvarchar](50) NOT NULL,
	[InsertedOn] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](50) NOT NULL,
	[UpdatedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_Activity_tbFlow] PRIMARY KEY NONCLUSTERED 
(
	[ParentCode] ASC,
	[StepNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Activity].[tbOp](
	[ActivityCode] [nvarchar](50) NOT NULL,
	[OperationNumber] [smallint] NOT NULL,
	[OpTypeCode] [smallint] NOT NULL,
	[Operation] [nvarchar](50) NOT NULL,
	[Duration] [float] NOT NULL,
	[OffsetDays] [smallint] NOT NULL,
	[InsertedBy] [nvarchar](50) NOT NULL,
	[InsertedOn] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](50) NOT NULL,
	[UpdatedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_Activity_tbOp] PRIMARY KEY CLUSTERED 
(
	[ActivityCode] ASC,
	[OperationNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Activity].[tbOpType](
	[OpTypeCode] [smallint] NOT NULL,
	[OpType] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Activity_tbOpType] PRIMARY KEY CLUSTERED 
(
	[OpTypeCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [App].[tbBucket](
	[Period] [smallint] NOT NULL,
	[BucketId] [nvarchar](10) NOT NULL,
	[BucketDescription] [nvarchar](50) NULL,
	[AllowForecasts] [bit] NOT NULL,
 CONSTRAINT [PK_App_tbBucket] PRIMARY KEY CLUSTERED 
(
	[Period] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [App].[tbBucketInterval](
	[BucketIntervalCode] [smallint] NOT NULL,
	[BucketInterval] [nvarchar](15) NOT NULL,
 CONSTRAINT [PK_App_tbBucketInterval] PRIMARY KEY CLUSTERED 
(
	[BucketIntervalCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [App].[tbBucketType](
	[BucketTypeCode] [smallint] NOT NULL,
	[BucketType] [nvarchar](25) NOT NULL,
 CONSTRAINT [PK_App_tbBucketType] PRIMARY KEY CLUSTERED 
(
	[BucketTypeCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [App].[tbCalendar](
	[CalendarCode] [nvarchar](10) NOT NULL,
	[Monday] [bit] NOT NULL,
	[Tuesday] [bit] NOT NULL,
	[Wednesday] [bit] NOT NULL,
	[Thursday] [bit] NOT NULL,
	[Friday] [bit] NOT NULL,
	[Saturday] [bit] NOT NULL,
	[Sunday] [bit] NOT NULL,
 CONSTRAINT [PK_App_tbCalendar] PRIMARY KEY CLUSTERED 
(
	[CalendarCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [App].[tbCalendarHoliday](
	[CalendarCode] [nvarchar](10) NOT NULL,
	[UnavailableOn] [datetime] NOT NULL,
 CONSTRAINT [PK_App_tbCalendarHoliday] PRIMARY KEY CLUSTERED 
(
	[CalendarCode] ASC,
	[UnavailableOn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [App].[tbCodeExclusion](
	[ExcludedTag] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_App_tbCodeExclusion] PRIMARY KEY CLUSTERED 
(
	[ExcludedTag] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [App].[tbDoc](
	[DocTypeCode] [smallint] NOT NULL,
	[ReportName] [nvarchar](50) NOT NULL,
	[OpenMode] [smallint] NOT NULL,
	[Description] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_App_tbDoc] PRIMARY KEY CLUSTERED 
(
	[DocTypeCode] ASC,
	[ReportName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [App].[tbDocSpool](
	[UserName] [nvarchar](50) NOT NULL,
	[DocTypeCode] [smallint] NOT NULL,
	[DocumentNumber] [nvarchar](25) NOT NULL,
	[SpooledOn] [datetime] NOT NULL,
 CONSTRAINT [PK_App_tbDocSpool] PRIMARY KEY CLUSTERED 
(
	[UserName] ASC,
	[DocTypeCode] ASC,
	[DocumentNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [App].[tbDocType](
	[DocTypeCode] [smallint] NOT NULL,
	[DocType] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_App_tbDocType] PRIMARY KEY CLUSTERED 
(
	[DocTypeCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [App].[tbMonth](
	[MonthNumber] [smallint] NOT NULL,
	[MonthName] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_App_tbMonth] PRIMARY KEY CLUSTERED 
(
	[MonthNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [App].[tbOptions](
	[Identifier] [nvarchar](4) NOT NULL,
	[Initialised] [bit] NOT NULL,
	[SQLDataVersion] [real] NOT NULL,
	[AccountCode] [nvarchar](10) NOT NULL,
	[DefaultPrintMode] [smallint] NOT NULL,
	[BucketTypeCode] [smallint] NOT NULL,
	[BucketIntervalCode] [smallint] NOT NULL,
	[ShowCashGraphs] [bit] NOT NULL,
	[NetProfitCode] [nvarchar](10) NULL,
	[NetProfitTaxCode] [nvarchar](50) NULL,
	[ScheduleOps] [bit] NOT NULL,
	[TaxHorizon] [smallint] NOT NULL,
	[InsertedBy] [nvarchar](50) NOT NULL,
	[InsertedOn] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](50) NOT NULL,
	[UpdatedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_App_tbRoot] PRIMARY KEY CLUSTERED 
(
	[Identifier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [App].[tbRecurrence](
	[RecurrenceCode] [smallint] NOT NULL,
	[Recurrence] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_App_tbRecurrence] PRIMARY KEY CLUSTERED 
(
	[RecurrenceCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [App].[tbRegister](
	[RegisterName] [nvarchar](50) NOT NULL,
	[NextNumber] [int] NOT NULL,
 CONSTRAINT [PK_App_tbRegister] PRIMARY KEY CLUSTERED 
(
	[RegisterName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [App].[tbTaxCode](
	[TaxCode] [nvarchar](10) NOT NULL,
	[TaxRate] [float] NOT NULL,
	[TaxDescription] [nvarchar](50) NOT NULL,
	[TaxTypeCode] [smallint] NOT NULL,
	[UpdatedBy] [nvarchar](50) NOT NULL,
	[UpdatedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_App_tbVatCode] PRIMARY KEY CLUSTERED 
(
	[TaxCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [App].[tbText](
	[TextId] [int] NOT NULL,
	[Message] [ntext] NOT NULL,
	[Arguments] [smallint] NOT NULL,
 CONSTRAINT [PK_App_tbText] PRIMARY KEY CLUSTERED 
(
	[TextId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

GO

GO
CREATE TABLE [App].[tbUom](
	[UnitOfMeasure] [nvarchar](15) NOT NULL,
 CONSTRAINT [PK_App_tbUom] PRIMARY KEY CLUSTERED 
(
	[UnitOfMeasure] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [App].[tbYear](
	[YearNumber] [smallint] NOT NULL,
	[StartMonth] [smallint] NOT NULL,
	[CashStatusCode] [smallint] NOT NULL,
	[Description] [nvarchar](10) NOT NULL,
	[InsertedBy] [nvarchar](50) NOT NULL,
	[InsertedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_App_tbYear] PRIMARY KEY CLUSTERED 
(
	[YearNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [App].[tbYearPeriod](
	[YearNumber] [smallint] NOT NULL,
	[StartOn] [datetime] NOT NULL,
	[MonthNumber] [smallint] NOT NULL,
	[CashStatusCode] [smallint] NOT NULL,
	[InsertedBy] [nvarchar](50) NOT NULL,
	[InsertedOn] [datetime] NOT NULL,
	[CorporationTaxRate] [real] NOT NULL,
	[TaxAdjustment] [money] NOT NULL,
	[VatAdjustment] [money] NOT NULL,
 CONSTRAINT [PK_App_tbYearPeriod] PRIMARY KEY CLUSTERED 
(
	[YearNumber] ASC,
	[StartOn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY],
 CONSTRAINT [IX_App_tbYearPeriod_StartOn] UNIQUE NONCLUSTERED 
(
	[StartOn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY],
 CONSTRAINT [IX_App_tbYearPeriod_Year_MonthNumber] UNIQUE NONCLUSTERED 
(
	[YearNumber] ASC,
	[MonthNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Cash].[tbCategory](
	[CategoryCode] [nvarchar](10) NOT NULL,
	[Category] [nvarchar](50) NOT NULL,
	[CategoryTypeCode] [smallint] NOT NULL,
	[CashModeCode] [smallint] NULL,
	[CashTypeCode] [smallint] NULL,
	[DisplayOrder] [smallint] NOT NULL,
	[InsertedBy] [nvarchar](50) NOT NULL,
	[InsertedOn] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](50) NOT NULL,
	[UpdatedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_Cash_tbCategory] PRIMARY KEY CLUSTERED 
(
	[CategoryCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Cash].[tbCategoryExp](
	[CategoryCode] [nvarchar](10) NOT NULL,
	[Expression] [nvarchar](256) NOT NULL,
	[Format] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_Cash_tbCategoryExp] PRIMARY KEY CLUSTERED 
(
	[CategoryCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Cash].[tbCategoryTotal](
	[ParentCode] [nvarchar](10) NOT NULL,
	[ChildCode] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_Cash_tbCategoryTotal] PRIMARY KEY CLUSTERED 
(
	[ParentCode] ASC,
	[ChildCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Cash].[tbCategoryType](
	[CategoryTypeCode] [smallint] NOT NULL,
	[CategoryType] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_Cash_tbCategoryType] PRIMARY KEY CLUSTERED 
(
	[CategoryTypeCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Cash].[tbCode](
	[CashCode] [nvarchar](50) NOT NULL,
	[CashDescription] [nvarchar](100) NOT NULL,
	[CategoryCode] [nvarchar](10) NOT NULL,
	[TaxCode] [nvarchar](10) NOT NULL,
	[OpeningBalance] [money] NOT NULL,
	[InsertedBy] [nvarchar](50) NOT NULL,
	[InsertedOn] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](50) NOT NULL,
	[UpdatedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_Cash_tbCode] PRIMARY KEY CLUSTERED 
(
	[CashCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY],
 CONSTRAINT [IX_Cash_tbCodeDescription] UNIQUE NONCLUSTERED 
(
	[CashDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Cash].[tbEntryType](
	[CashEntryTypeCode] [smallint] NOT NULL,
	[CashEntryType] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_Cash_tbEntryType] PRIMARY KEY CLUSTERED 
(
	[CashEntryTypeCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Cash].[tbMode](
	[CashModeCode] [smallint] NOT NULL,
	[CashMode] [nvarchar](10) NULL,
 CONSTRAINT [PK_Cash_tbMode] PRIMARY KEY CLUSTERED 
(
	[CashModeCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Cash].[tbPeriod](
	[CashCode] [nvarchar](50) NOT NULL,
	[StartOn] [datetime] NOT NULL,
	[ForecastValue] [money] NOT NULL,
	[ForecastTax] [money] NOT NULL,
	[InvoiceValue] [money] NOT NULL,
	[InvoiceTax] [money] NOT NULL,
	[Note] [ntext] NULL,
 CONSTRAINT [PK_Cash_tbPeriod] PRIMARY KEY CLUSTERED 
(
	[CashCode] ASC,
	[StartOn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Cash].[tbStatus](
	[CashStatusCode] [smallint] NOT NULL,
	[CashStatus] [nvarchar](15) NOT NULL,
 CONSTRAINT [PK_Cash_tbStatus] PRIMARY KEY CLUSTERED 
(
	[CashStatusCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Cash].[tbTaxType](
	[TaxTypeCode] [smallint] NOT NULL,
	[TaxType] [nvarchar](20) NOT NULL,
	[CashCode] [nvarchar](50) NULL,
	[MonthNumber] [smallint] NOT NULL,
	[RecurrenceCode] [smallint] NOT NULL,
	[AccountCode] [nvarchar](10) NULL,
	[CashAccountCode] [nvarchar](10) NULL,
 CONSTRAINT [PK_Cash_tbTaxType] PRIMARY KEY CLUSTERED 
(
	[TaxTypeCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Cash].[tbType](
	[CashTypeCode] [smallint] NOT NULL,
	[CashType] [nvarchar](25) NULL,
 CONSTRAINT [PK_Cash_tbType] PRIMARY KEY CLUSTERED 
(
	[CashTypeCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Invoice].[tbInvoice](
	[InvoiceNumber] [nvarchar](20) NOT NULL,
	[UserId] [nvarchar](10) NOT NULL,
	[AccountCode] [nvarchar](10) NOT NULL,
	[InvoiceTypeCode] [smallint] NOT NULL,
	[InvoiceStatusCode] [smallint] NOT NULL,
	[InvoicedOn] [datetime] NOT NULL,
	[InvoiceValue] [money] NOT NULL,
	[TaxValue] [money] NOT NULL,
	[PaidValue] [money] NOT NULL,
	[PaidTaxValue] [money] NOT NULL,
	[PaymentTerms] [nvarchar](100) NULL,
	[Notes] [ntext] NULL,
	[Printed] [bit] NOT NULL,
	[CollectOn] [datetime] NOT NULL,
	[Spooled] [bit] NOT NULL,
 CONSTRAINT [PK_Invoice_tbInvoicePK] PRIMARY KEY CLUSTERED 
(
	[InvoiceNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Invoice].[tbItem](
	[InvoiceNumber] [nvarchar](20) NOT NULL,
	[CashCode] [nvarchar](50) NOT NULL,
	[TaxCode] [nvarchar](10) NULL,
	[InvoiceValue] [money] NOT NULL,
	[TaxValue] [money] NOT NULL,
	[PaidValue] [money] NOT NULL,
	[PaidTaxValue] [money] NOT NULL,
	[ItemReference] [ntext] NULL,
 CONSTRAINT [PK_Invoice_tbItem] PRIMARY KEY CLUSTERED 
(
	[InvoiceNumber] ASC,
	[CashCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Invoice].[tbStatus](
	[InvoiceStatusCode] [smallint] NOT NULL,
	[InvoiceStatus] [nvarchar](50) NULL,
 CONSTRAINT [PK_Invoice_tbStatus] PRIMARY KEY NONCLUSTERED 
(
	[InvoiceStatusCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Invoice].[tbTask](
	[InvoiceNumber] [nvarchar](20) NOT NULL,
	[TaskCode] [nvarchar](20) NOT NULL,
	[Quantity] [float] NOT NULL,
	[InvoiceValue] [money] NOT NULL,
	[TaxValue] [money] NOT NULL,
	[PaidValue] [money] NOT NULL,
	[PaidTaxValue] [money] NOT NULL,
	[CashCode] [nvarchar](50) NOT NULL,
	[TaxCode] [nvarchar](10) NULL,
 CONSTRAINT [PK_Invoice_tbTask] PRIMARY KEY CLUSTERED 
(
	[InvoiceNumber] ASC,
	[TaskCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Invoice].[tbType](
	[InvoiceTypeCode] [smallint] NOT NULL,
	[InvoiceType] [nvarchar](20) NOT NULL,
	[CashModeCode] [smallint] NOT NULL,
	[NextNumber] [int] NOT NULL,
 CONSTRAINT [PK_Invoice_tbType] PRIMARY KEY CLUSTERED 
(
	[InvoiceTypeCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Org].[tbAccount](
	[CashAccountCode] [nvarchar](10) NOT NULL,
	[AccountCode] [nvarchar](10) NOT NULL,
	[CashAccountName] [nvarchar](50) NOT NULL,
	[OpeningBalance] [money] NOT NULL,
	[CurrentBalance] [money] NOT NULL,
	[SortCode] [nvarchar](10) NULL,
	[AccountNumber] [nvarchar](20) NULL,
	[CashCode] [nvarchar](50) NULL,
	[AccountClosed] [bit] NOT NULL,
	[InsertedBy] [nvarchar](50) NOT NULL,
	[InsertedOn] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](50) NOT NULL,
	[UpdatedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_Org_tbAccount] PRIMARY KEY CLUSTERED 
(
	[CashAccountCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Org].[tbAddress](
	[AddressCode] [nvarchar](15) NOT NULL,
	[AccountCode] [nvarchar](10) NOT NULL,
	[Address] [ntext] NOT NULL,
	[InsertedBy] [nvarchar](50) NOT NULL,
	[InsertedOn] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](50) NOT NULL,
	[UpdatedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_Org_tbAddress] PRIMARY KEY CLUSTERED 
(
	[AddressCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Org].[tbContact](
	[AccountCode] [nvarchar](10) NOT NULL,
	[ContactName] [nvarchar](100) NOT NULL,
	[FileAs] [nvarchar](100) NULL,
	[OnMailingList] [bit] NOT NULL,
	[NameTitle] [nvarchar](25) NULL,
	[NickName] [nvarchar](100) NULL,
	[JobTitle] [nvarchar](100) NULL,
	[PhoneNumber] [nvarchar](50) NULL,
	[MobileNumber] [nvarchar](50) NULL,
	[FaxNumber] [nvarchar](50) NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[Hobby] [nvarchar](50) NULL,
	[DateOfBirth] [datetime] NULL,
	[Department] [nvarchar](50) NULL,
	[SpouseName] [nvarchar](50) NULL,
	[HomeNumber] [nvarchar](50) NULL,
	[Information] [ntext] NULL,
	[Photo] [image] NULL,
	[InsertedBy] [nvarchar](50) NOT NULL,
	[InsertedOn] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](50) NOT NULL,
	[UpdatedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_Org_tbContact] PRIMARY KEY NONCLUSTERED 
(
	[AccountCode] ASC,
	[ContactName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Org].[tbDoc](
	[AccountCode] [nvarchar](10) NOT NULL,
	[DocumentName] [nvarchar](255) NOT NULL,
	[DocumentDescription] [ntext] NULL,
	[DocumentImage] [image] NULL,
	[InsertedBy] [nvarchar](50) NOT NULL,
	[InsertedOn] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](50) NOT NULL,
	[UpdatedOn] [datetime] NOT NULL,
 CONSTRAINT PK_Org_tbDoc PRIMARY KEY NONCLUSTERED 
(
	[AccountCode] ASC,
	[DocumentName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Org].[tbOrg](
	[AccountCode] [nvarchar](10) NOT NULL,
	[AccountName] [nvarchar](255) NOT NULL,
	[OrganisationTypeCode] [smallint] NOT NULL,
	[OrganisationStatusCode] [smallint] NOT NULL,
	[TaxCode] [nvarchar](10) NULL,
	[AddressCode] [nvarchar](15) NULL,
	[AreaCode] [nvarchar](50) NULL,
	[PhoneNumber] [nvarchar](50) NULL,
	[FaxNumber] [nvarchar](50) NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[WebSite] [nvarchar](255) NULL,
	[IndustrySector] [nvarchar](255) NULL,
	[AccountSource] [nvarchar](100) NULL,
	[PaymentTerms] [nvarchar](100) NULL,
	[NumberOfEmployees] [int] NOT NULL,
	[CompanyNumber] [nvarchar](20) NULL,
	[VatNumber] [nvarchar](50) NULL,
	[Turnover] [money] NOT NULL,
	[StatementDays] [smallint] NOT NULL,
	[OpeningBalance] [money] NOT NULL,
	[CurrentBalance] [money] NOT NULL,
	[ForeignJurisdiction] [bit] NOT NULL,
	[BusinessDescription] [ntext] NULL,
	[Logo] [image] NULL,
	[InsertedBy] [nvarchar](50) NOT NULL,
	[InsertedOn] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](50) NOT NULL,
	[UpdatedOn] [datetime] NOT NULL,
	[PaymentDays] [smallint] NOT NULL,
	[PayDaysFromMonthEnd] [bit] NOT NULL,
 CONSTRAINT PK_Org_tbOrg PRIMARY KEY NONCLUSTERED 
(
	[AccountCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Org].[tbPayment](
	[PaymentCode] [nvarchar](20) NOT NULL,
	[UserId] [nvarchar](10) NOT NULL,
	[PaymentStatusCode] [smallint] NOT NULL,
	[AccountCode] [nvarchar](10) NOT NULL,
	[CashAccountCode] [nvarchar](10) NOT NULL,
	[CashCode] [nvarchar](50) NULL,
	[TaxCode] [nvarchar](10) NULL,
	[PaidOn] [datetime] NOT NULL,
	[PaidInValue] [money] NOT NULL,
	[PaidOutValue] [money] NOT NULL,
	[TaxInValue] [money] NOT NULL,
	[TaxOutValue] [money] NOT NULL,
	[PaymentReference] [nvarchar](50) NULL,
	[InsertedBy] [nvarchar](50) NOT NULL,
	[InsertedOn] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](50) NOT NULL,
	[UpdatedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_Org_tbPayment] PRIMARY KEY CLUSTERED 
(
	[PaymentCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Org].[tbPaymentStatus](
	[PaymentStatusCode] [smallint] NOT NULL,
	[PaymentStatus] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_Org_tbPaymentStatus] PRIMARY KEY CLUSTERED 
(
	[PaymentStatusCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Org].[tbSector](
	[AccountCode] [nvarchar](10) NOT NULL,
	[IndustrySector] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Org_tbSector] PRIMARY KEY CLUSTERED 
(
	[AccountCode] ASC,
	[IndustrySector] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Org].[tbStatus](
	[OrganisationStatusCode] [smallint] NOT NULL,
	[OrganisationStatus] [nvarchar](255) NULL,
 CONSTRAINT PK_Org_tbStatus PRIMARY KEY NONCLUSTERED 
(
	[OrganisationStatusCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Org].[tbType](
	[OrganisationTypeCode] [smallint] NOT NULL,
	[CashModeCode] [smallint] NOT NULL,
	[OrganisationType] [nvarchar](50) NOT NULL,
 CONSTRAINT PK_Org_tbType PRIMARY KEY NONCLUSTERED 
(
	[OrganisationTypeCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Task].[tbAttribute](
	[TaskCode] [nvarchar](20) NOT NULL,
	[Attribute] [nvarchar](50) NOT NULL,
	[PrintOrder] [smallint] NOT NULL,
	[AttributeTypeCode] [smallint] NOT NULL,
	[AttributeDescription] [nvarchar](400) NULL,
	[InsertedBy] [nvarchar](50) NOT NULL,
	[InsertedOn] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](50) NOT NULL,
	[UpdatedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_Task_tbTaskAttribute] PRIMARY KEY CLUSTERED 
(
	[TaskCode] ASC,
	[Attribute] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Task].[tbDoc](
	[TaskCode] [nvarchar](20) NOT NULL,
	[DocumentName] [nvarchar](255) NOT NULL,
	[DocumentDescription] [ntext] NULL,
	[DocumentImage] [image] NOT NULL,
	[InsertedBy] [nvarchar](50) NOT NULL,
	[InsertedOn] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](50) NOT NULL,
	[UpdatedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_Task_tbDoc] PRIMARY KEY CLUSTERED 
(
	[TaskCode] ASC,
	[DocumentName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Task].[tbFlow](
	[ParentTaskCode] [nvarchar](20) NOT NULL,
	[StepNumber] [smallint] NOT NULL,
	[ChildTaskCode] [nvarchar](20) NULL,
	[UsedOnQuantity] [float] NOT NULL,
	[OffsetDays] [real] NOT NULL,
	[InsertedBy] [nvarchar](50) NOT NULL,
	[InsertedOn] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](50) NOT NULL,
	[UpdatedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_Task_tbFlow] PRIMARY KEY CLUSTERED 
(
	[ParentTaskCode] ASC,
	[StepNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Task].[tbOp](
	[TaskCode] [nvarchar](20) NOT NULL,
	[OperationNumber] [smallint] NOT NULL,
	[OpTypeCode] [smallint] NOT NULL,
	[OpStatusCode] [smallint] NOT NULL,
	[UserId] [nvarchar](10) NOT NULL,
	[Operation] [nvarchar](50) NOT NULL,
	[Note] [ntext] NULL,
	[StartOn] [datetime] NOT NULL,
	[EndOn] [datetime] NOT NULL,
	[Duration] [float] NOT NULL,
	[OffsetDays] [smallint] NOT NULL,
	[InsertedBy] [nvarchar](50) NOT NULL,
	[InsertedOn] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](50) NOT NULL,
	[UpdatedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_Task_tbOp] PRIMARY KEY CLUSTERED 
(
	[TaskCode] ASC,
	[OperationNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Task].[tbOpStatus](
	[OpStatusCode] [smallint] NOT NULL,
	[OpStatus] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Task_tbOpStatus] PRIMARY KEY CLUSTERED 
(
	[OpStatusCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Task].[tbQuote](
	[TaskCode] [nvarchar](20) NOT NULL,
	[Quantity] [float] NOT NULL,
	[TotalPrice] [money] NOT NULL,
	[RunOnQuantity] [float] NOT NULL,
	[RunOnPrice] [money] NOT NULL,
	[RunBackQuantity] [float] NOT NULL,
	[RunBackPrice] [float] NOT NULL,
	[InsertedBy] [nvarchar](50) NOT NULL,
	[InsertedOn] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](50) NOT NULL,
	[UpdatedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_Task_tbQuote] PRIMARY KEY CLUSTERED 
(
	[TaskCode] ASC,
	[Quantity] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Task].[tbStatus](
	[TaskStatusCode] [smallint] NOT NULL,
	[TaskStatus] [nvarchar](100) NOT NULL,
 CONSTRAINT PK_Task_tbStatus PRIMARY KEY NONCLUSTERED 
(
	[TaskStatusCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Task].[tbTask](
	[TaskCode] [nvarchar](20) NOT NULL,
	[UserId] [nvarchar](10) NOT NULL,
	[AccountCode] [nvarchar](10) NOT NULL,
	[TaskTitle] [nvarchar](100) NULL,
	[ContactName] [nvarchar](100) NULL,
	[ActivityCode] [nvarchar](50) NOT NULL,
	[TaskStatusCode] [smallint] NOT NULL,
	[ActionById] [nvarchar](10) NOT NULL,
	[ActionOn] [datetime] NOT NULL,
	[ActionedOn] [datetime] NULL,
	[TaskNotes] [nvarchar](255) NULL,
	[Quantity] [float] NOT NULL,
	[CashCode] [nvarchar](50) NULL,
	[TaxCode] [nvarchar](10) NULL,
	[UnitCharge] [float] NOT NULL,
	[TotalCharge] [money] NOT NULL,
	[AddressCodeFrom] [nvarchar](15) NULL,
	[AddressCodeTo] [nvarchar](15) NULL,
	[Printed] [bit] NOT NULL,
	[InsertedBy] [nvarchar](50) NOT NULL,
	[InsertedOn] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](50) NOT NULL,
	[UpdatedOn] [datetime] NOT NULL,
	[PaymentOn] [datetime] NOT NULL,
	[SecondReference] [nvarchar](20) NULL,
	[Spooled] [bit] NOT NULL,
 CONSTRAINT [PK_Task_tbTask] PRIMARY KEY CLUSTERED 
(
	[TaskCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Usr].[tbMenu](
	[MenuId] [smallint] IDENTITY(1,1) NOT NULL,
	[MenuName] [nvarchar](50) NOT NULL,
	[InsertedOn] [datetime] NOT NULL,
	[InsertedBy] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Usr_tbMenu] PRIMARY KEY CLUSTERED 
(
	[MenuId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY],
 CONSTRAINT [IX_Usr_tbMenu] UNIQUE NONCLUSTERED 
(
	[MenuName] ASC,
	[MenuId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Usr].[tbMenuCommand](
	[Command] [smallint] NOT NULL,
	[CommandText] [nvarchar](50) NULL,
 CONSTRAINT [PK_Usr_tbMenuCommand] PRIMARY KEY CLUSTERED 
(
	[Command] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Usr].[tbMenuEntry](
	[MenuId] [smallint] NOT NULL,
	[EntryId] [int] IDENTITY(1,1) NOT NULL,
	[FolderId] [smallint] NOT NULL,
	[ItemId] [smallint] NOT NULL,
	[ItemText] [nvarchar](255) NULL,
	[Command] [smallint] NULL,
	[ProjectName] [nvarchar](50) NULL,
	[Argument] [nvarchar](50) NULL,
	[OpenMode] [smallint] NULL,
	[UpdatedOn] [datetime] NOT NULL,
	[InsertedOn] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Usr_tbMenuEntry] PRIMARY KEY CLUSTERED 
(
	[MenuId] ASC,
	[EntryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY],
 CONSTRAINT [IX_Usr_tbMenuEntry_MenuFolderItem] UNIQUE NONCLUSTERED 
(
	[MenuId] ASC,
	[FolderId] ASC,
	[ItemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Usr].[tbMenuOpenMode](
	[OpenMode] [smallint] NOT NULL,
	[OpenModeDescription] [nvarchar](20) NULL,
 CONSTRAINT [PK_Usr_tbMenuOpenMode] PRIMARY KEY CLUSTERED 
(
	[OpenMode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Usr].[tbMenuUser](
	[UserId] [nvarchar](10) NOT NULL,
	[MenuId] [smallint] NOT NULL,
 CONSTRAINT [PK_Usr_tbMenuUser] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[MenuId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

GO

GO
CREATE TABLE [Usr].[tbUser](
	[UserId] [nvarchar](10) NOT NULL,
	[UserName] [nvarchar](50) NOT NULL,
	[LogonName] [nvarchar](50) NOT NULL,
	[CalendarCode] [nvarchar](10) NULL,
	[PhoneNumber] [nvarchar](50) NULL,
	[MobileNumber] [nvarchar](50) NULL,
	[FaxNumber] [nvarchar](50) NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[Address] [ntext] NULL,
	[Administrator] [bit] NOT NULL,
	[Avatar] [image] NULL,
	[Signature] [image] NULL,
	[InsertedBy] [nvarchar](50) NOT NULL,
	[InsertedOn] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](50) NOT NULL,
	[UpdatedOn] [datetime] NOT NULL,
	[NextTaskNumber] [int] NOT NULL,
 CONSTRAINT [PK_Usr_tbUser] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Activity].[tbActivity] ADD  CONSTRAINT [DF_Activity_tbActivity_TaskStatusCode]  DEFAULT ((1)) FOR [TaskStatusCode]
GO
ALTER TABLE [Activity].[tbActivity] ADD  CONSTRAINT [DF_Activity_tbActivity_UnitCharge]  DEFAULT ((0)) FOR [UnitCharge]
GO
ALTER TABLE [Activity].[tbActivity] ADD  CONSTRAINT [DF_Activity_tbActivity_PrintOrder]  DEFAULT ((0)) FOR [PrintOrder]
GO
ALTER TABLE [Activity].[tbActivity] ADD  CONSTRAINT [DF_Activity_tbActivity_InsertedBy]  DEFAULT (SUSER_SNAME()) FOR [InsertedBy]
GO
ALTER TABLE [Activity].[tbActivity] ADD  CONSTRAINT [DF_Activity_tbActivity_InsertedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [InsertedOn]
GO
ALTER TABLE [Activity].[tbActivity] ADD  CONSTRAINT [DF_Activity_tbActivity_UpdatedBy]  DEFAULT (SUSER_SNAME()) FOR [UpdatedBy]
GO
ALTER TABLE [Activity].[tbActivity] ADD  CONSTRAINT [DF_Activity_tbActivity_UpdatedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [UpdatedOn]
GO
ALTER TABLE [Activity].[tbAttribute] ADD  CONSTRAINT [DF_Activity_tbAttribute_OrderBy]  DEFAULT ((10)) FOR [PrintOrder]
GO
ALTER TABLE [Activity].[tbAttribute] ADD  CONSTRAINT [DF_Activity_tbAttribute_AttributeTypeCode]  DEFAULT ((1)) FOR [AttributeTypeCode]
GO
ALTER TABLE [Activity].[tbAttribute] ADD  CONSTRAINT [DF_tbTemplateAttribute_InsertedBy]  DEFAULT (SUSER_SNAME()) FOR [InsertedBy]
GO
ALTER TABLE [Activity].[tbAttribute] ADD  CONSTRAINT [DF_tbTemplateAttribute_InsertedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [InsertedOn]
GO
ALTER TABLE [Activity].[tbAttribute] ADD  CONSTRAINT [DF_tbTemplateAttribute_UpdatedBy]  DEFAULT (SUSER_SNAME()) FOR [UpdatedBy]
GO
ALTER TABLE [Activity].[tbAttribute] ADD  CONSTRAINT [DF_tbTemplateAttribute_UpdatedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [UpdatedOn]
GO
ALTER TABLE [Activity].[tbFlow] ADD  CONSTRAINT [DF_Activity_tbFlow_StepNumber]  DEFAULT ((10)) FOR [StepNumber]
GO
ALTER TABLE [Activity].[tbFlow] ADD  CONSTRAINT [DF_Activity_tbFlow_OffsetDays]  DEFAULT ((0)) FOR [OffsetDays]
GO
ALTER TABLE [Activity].[tbFlow] ADD  CONSTRAINT [DF_Activity_tbCodeFlow_Quantity]  DEFAULT ((0)) FOR [UsedOnQuantity]
GO
ALTER TABLE [Activity].[tbFlow] ADD  CONSTRAINT [DF_tbTemplateActivity_InsertedBy]  DEFAULT (SUSER_SNAME()) FOR [InsertedBy]
GO
ALTER TABLE [Activity].[tbFlow] ADD  CONSTRAINT [DF_tbTemplateActivity_InsertedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [InsertedOn]
GO
ALTER TABLE [Activity].[tbFlow] ADD  CONSTRAINT [DF_tbTemplateActivity_UpdatedBy]  DEFAULT (SUSER_SNAME()) FOR [UpdatedBy]
GO
ALTER TABLE [Activity].[tbFlow] ADD  CONSTRAINT [DF_tbTemplateActivity_UpdatedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [UpdatedOn]
GO
ALTER TABLE [Activity].[tbOp] ADD  CONSTRAINT [DF_Activity_tbOp_OperationNumber]  DEFAULT ((0)) FOR [OperationNumber]
GO
ALTER TABLE [Activity].[tbOp] ADD  CONSTRAINT [DF_Activity_tbOp_OpTypeCode]  DEFAULT ((1)) FOR [OpTypeCode]
GO
ALTER TABLE [Activity].[tbOp] ADD  CONSTRAINT [DF_Activity_tbOp_Duration]  DEFAULT ((0)) FOR [Duration]
GO
ALTER TABLE [Activity].[tbOp] ADD  CONSTRAINT [DF_Activity_tbOp_OffsetDays]  DEFAULT ((0)) FOR [OffsetDays]
GO
ALTER TABLE [Activity].[tbOp] ADD  CONSTRAINT [DF_Activity_tbOp_InsertedBy]  DEFAULT (SUSER_SNAME()) FOR [InsertedBy]
GO
ALTER TABLE [Activity].[tbOp] ADD  CONSTRAINT [DF_Activity_tbOp_InsertedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [InsertedOn]
GO
ALTER TABLE [Activity].[tbOp] ADD  CONSTRAINT [DF_Activity_tbOp_UpdatedBy]  DEFAULT (SUSER_SNAME()) FOR [UpdatedBy]
GO
ALTER TABLE [Activity].[tbOp] ADD  CONSTRAINT [DF_Activity_tbOp_UpdatedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [UpdatedOn]
GO
ALTER TABLE [App].[tbCalendar] ADD  CONSTRAINT [DF_App_tbCalendar_Monday]  DEFAULT ((1)) FOR [Monday]
GO
ALTER TABLE [App].[tbCalendar] ADD  CONSTRAINT [DF_App_tbCalendar_Tuesday]  DEFAULT ((1)) FOR [Tuesday]
GO
ALTER TABLE [App].[tbCalendar] ADD  CONSTRAINT [DF_App_tbCalendar_Wednesday]  DEFAULT ((1)) FOR [Wednesday]
GO
ALTER TABLE [App].[tbCalendar] ADD  CONSTRAINT [DF_App_tbCalendar_Thursday]  DEFAULT ((1)) FOR [Thursday]
GO
ALTER TABLE [App].[tbCalendar] ADD  CONSTRAINT [DF_App_tbCalendar_Friday]  DEFAULT ((1)) FOR [Friday]
GO
ALTER TABLE [App].[tbCalendar] ADD  CONSTRAINT [DF_App_tbCalendar_Saturday]  DEFAULT ((0)) FOR [Saturday]
GO
ALTER TABLE [App].[tbCalendar] ADD  CONSTRAINT [DF_App_tbCalendar_Sunday]  DEFAULT ((0)) FOR [Sunday]
GO
ALTER TABLE [App].[tbDoc] ADD  CONSTRAINT [DF_App_tbDoc_OpenMode]  DEFAULT ((1)) FOR [OpenMode]
GO
ALTER TABLE [App].[tbDocSpool] ADD  CONSTRAINT [DF_App_tbDocSpool_UserName]  DEFAULT (SUSER_SNAME()) FOR [UserName]
GO
ALTER TABLE [App].[tbDocSpool] ADD  CONSTRAINT [DF_App_tbDocSpool_DocTypeCode]  DEFAULT ((1)) FOR [DocTypeCode]
GO
ALTER TABLE [App].[tbDocSpool] ADD  CONSTRAINT [DF_App_tbDocSpool_SpooledOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [SpooledOn]
GO
ALTER TABLE [App].[tbOptions] ADD  CONSTRAINT [DF_App_tbRoot_Initialised]  DEFAULT ((0)) FOR [Initialised]
GO
ALTER TABLE [App].[tbOptions] ADD  CONSTRAINT [DF_App_tbRoot_SQLDataVersion]  DEFAULT ((1)) FOR [SQLDataVersion]
GO
ALTER TABLE [App].[tbOptions] ADD  CONSTRAINT [DF_App_tbRoot_DefaultPrintMode]  DEFAULT ((2)) FOR [DefaultPrintMode]
GO
ALTER TABLE [App].[tbOptions] ADD  CONSTRAINT [DF_App_tbOptions_BucketTypeCode]  DEFAULT ((1)) FOR [BucketTypeCode]
GO
ALTER TABLE [App].[tbOptions] ADD  CONSTRAINT [DF_App_tbOptions_BucketIntervalCode]  DEFAULT ((1)) FOR [BucketIntervalCode]
GO
ALTER TABLE [App].[tbOptions] ADD  CONSTRAINT [DF_App_tbOptions_ShowCashGraphs]  DEFAULT ((1)) FOR [ShowCashGraphs]
GO
ALTER TABLE [App].[tbOptions] ADD  CONSTRAINT [DF_App_tbOptions_ScheduleOps]  DEFAULT ((1)) FOR [ScheduleOps]
GO
ALTER TABLE [App].[tbOptions] ADD  CONSTRAINT [DF_App_tbOptions_TaxHorizon]  DEFAULT ((90)) FOR [TaxHorizon]
GO
ALTER TABLE [App].[tbOptions] ADD  CONSTRAINT [DF_App_tbOptions_InsertedBy]  DEFAULT (SUSER_SNAME()) FOR [InsertedBy]
GO
ALTER TABLE [App].[tbOptions] ADD  CONSTRAINT [DF_App_tbOptions_InsertedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [InsertedOn]
GO
ALTER TABLE [App].[tbOptions] ADD  CONSTRAINT [DF_App_tbOptions_UpdatedBy]  DEFAULT (SUSER_SNAME()) FOR [UpdatedBy]
GO
ALTER TABLE [App].[tbOptions] ADD  CONSTRAINT [DF_App_tbOptions_UpdatedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [UpdatedOn]
GO
ALTER TABLE [App].[tbRegister] ADD  CONSTRAINT [DF_App_tbRegister_NextNumber]  DEFAULT ((1)) FOR [NextNumber]
GO
ALTER TABLE [App].[tbTaxCode] ADD  CONSTRAINT [DF_App_tbVatCode_VatRate]  DEFAULT ((0)) FOR [TaxRate]
GO
ALTER TABLE [App].[tbTaxCode] ADD  CONSTRAINT [DF_App_tbTaxCode_TaxTypeCode]  DEFAULT ((2)) FOR [TaxTypeCode]
GO
ALTER TABLE [App].[tbTaxCode] ADD  CONSTRAINT [DF_App_tbTaxCode_UpdatedBy]  DEFAULT (SUSER_SNAME()) FOR [UpdatedBy]
GO
ALTER TABLE [App].[tbTaxCode] ADD  CONSTRAINT [DF_App_tbTaxCode_UpdatedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [UpdatedOn]
GO
ALTER TABLE [App].[tbYear] ADD  CONSTRAINT [DF_App_tbYear_StartMonth]  DEFAULT ((1)) FOR [StartMonth]
GO
ALTER TABLE [App].[tbYear] ADD  CONSTRAINT [DF_App_tbYear_CashStatusCode]  DEFAULT ((1)) FOR [CashStatusCode]
GO
ALTER TABLE [App].[tbYear] ADD  CONSTRAINT [DF_App_tbYear_InsertedBy]  DEFAULT (SUSER_SNAME()) FOR [InsertedBy]
GO
ALTER TABLE [App].[tbYear] ADD  CONSTRAINT [DF_App_tbYear_InsertedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [InsertedOn]
GO
ALTER TABLE [App].[tbYearPeriod] ADD  CONSTRAINT [DF_App_tbYearPeriod_CashStatusCode]  DEFAULT ((1)) FOR [CashStatusCode]
GO
ALTER TABLE [App].[tbYearPeriod] ADD  CONSTRAINT [DF_App_tbYearPeriod_InsertedBy]  DEFAULT (SUSER_SNAME()) FOR [InsertedBy]
GO
ALTER TABLE [App].[tbYearPeriod] ADD  CONSTRAINT [DF_App_tbYearPeriod_InsertedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [InsertedOn]
GO
ALTER TABLE [App].[tbYearPeriod] ADD  CONSTRAINT [DF_App_tbYearPeriod_CorporationTaxRate]  DEFAULT ((0)) FOR [CorporationTaxRate]
GO
ALTER TABLE [App].[tbYearPeriod] ADD  CONSTRAINT [DF_App_tbYearPeriod_TaxAdjustment]  DEFAULT ((0)) FOR [TaxAdjustment]
GO
ALTER TABLE [App].[tbYearPeriod] ADD  CONSTRAINT [DF_App_tbYearPeriod_VatAdjustment]  DEFAULT ((0)) FOR [VatAdjustment]
GO
ALTER TABLE [Cash].[tbCategory] ADD  CONSTRAINT [DF_Cash_tbCategory_CategoryTypeCode]  DEFAULT ((1)) FOR [CategoryTypeCode]
GO
ALTER TABLE [Cash].[tbCategory] ADD  CONSTRAINT [DF_Cash_tbCategory_CashModeCode]  DEFAULT ((1)) FOR [CashModeCode]
GO
ALTER TABLE [Cash].[tbCategory] ADD  CONSTRAINT [DF_Cash_tbCategory_CashTypeCode]  DEFAULT ((1)) FOR [CashTypeCode]
GO
ALTER TABLE [Cash].[tbCategory] ADD  CONSTRAINT [DF_Cash_tbCategory_DisplayOrder]  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [Cash].[tbCategory] ADD  CONSTRAINT [DF_Cash_tbCategory_InsertedBy]  DEFAULT (SUSER_SNAME()) FOR [InsertedBy]
GO
ALTER TABLE [Cash].[tbCategory] ADD  CONSTRAINT [DF_Cash_tbCategory_InsertedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [InsertedOn]
GO
ALTER TABLE [Cash].[tbCategory] ADD  CONSTRAINT [DF_Cash_tbCategory_UpdatedBy]  DEFAULT (SUSER_SNAME()) FOR [UpdatedBy]
GO
ALTER TABLE [Cash].[tbCategory] ADD  CONSTRAINT [DF_Cash_tbCategory_UpdatedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [UpdatedOn]
GO
ALTER TABLE [Cash].[tbCode] ADD  CONSTRAINT [DF_Cash_tbCode_OpeningBalance]  DEFAULT ((0)) FOR [OpeningBalance]
GO
ALTER TABLE [Cash].[tbCode] ADD  CONSTRAINT [DF_Cash_tbCode_InsertedBy]  DEFAULT (SUSER_SNAME()) FOR [InsertedBy]
GO
ALTER TABLE [Cash].[tbCode] ADD  CONSTRAINT [DF_Cash_tbCode_InsertedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [InsertedOn]
GO
ALTER TABLE [Cash].[tbCode] ADD  CONSTRAINT [DF_Cash_tbCode_UpdatedBy]  DEFAULT (SUSER_SNAME()) FOR [UpdatedBy]
GO
ALTER TABLE [Cash].[tbCode] ADD  CONSTRAINT [DF_Cash_tbCode_UpdatedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [UpdatedOn]
GO
ALTER TABLE [Cash].[tbPeriod] ADD  CONSTRAINT [DF_Cash_tbPeriod_ForecastValue]  DEFAULT ((0)) FOR [ForecastValue]
GO
ALTER TABLE [Cash].[tbPeriod] ADD  CONSTRAINT [DF_Cash_tbPeriod_ForecastTax]  DEFAULT ((0)) FOR [ForecastTax]
GO
ALTER TABLE [Cash].[tbPeriod] ADD  CONSTRAINT [DF_Cash_tbPeriod_InvoiceValue]  DEFAULT ((0)) FOR [InvoiceValue]
GO
ALTER TABLE [Cash].[tbPeriod] ADD  CONSTRAINT [DF_Cash_tbPeriod_InvoiceTax]  DEFAULT ((0)) FOR [InvoiceTax]
GO
ALTER TABLE [Cash].[tbTaxType] ADD  CONSTRAINT [DF_App_tbOptions_MonthNumber]  DEFAULT ((1)) FOR [MonthNumber]
GO
ALTER TABLE [Cash].[tbTaxType] ADD  CONSTRAINT [DF_App_tbOptions_Recurrence]  DEFAULT ((1)) FOR [RecurrenceCode]
GO
ALTER TABLE [Invoice].[tbInvoice] ADD  CONSTRAINT [DF_Invoice_tb_InvoicedOn]  DEFAULT (CAST(CURRENT_TIMESTAMP AS DATE)) FOR [InvoicedOn]
GO
ALTER TABLE [Invoice].[tbInvoice] ADD  CONSTRAINT [DF_Invoice_tb_InvoiceValue]  DEFAULT ((0)) FOR [InvoiceValue]
GO
ALTER TABLE [Invoice].[tbInvoice] ADD  CONSTRAINT [DF_Invoice_tb_TaxValue]  DEFAULT ((0)) FOR [TaxValue]
GO
ALTER TABLE [Invoice].[tbInvoice] ADD  CONSTRAINT [DF_Invoice_tb_PaidValue]  DEFAULT ((0)) FOR [PaidValue]
GO
ALTER TABLE [Invoice].[tbInvoice] ADD  CONSTRAINT [DF_Invoice_tb_PaidTaxValue]  DEFAULT ((0)) FOR [PaidTaxValue]
GO
ALTER TABLE [Invoice].[tbInvoice] ADD  CONSTRAINT [DF_Invoice_tb_Printed]  DEFAULT ((0)) FOR [Printed]
GO
ALTER TABLE [Invoice].[tbInvoice] ADD  CONSTRAINT [DF_Invoice_tb_CollectOn]  DEFAULT (DATEADD(DAY, 1, CAST(CURRENT_TIMESTAMP AS DATE))) FOR [CollectOn]
GO
ALTER TABLE [Invoice].[tbInvoice] ADD  CONSTRAINT [DF_Invoice_tb_Spooled]  DEFAULT ((0)) FOR [Spooled]
GO
ALTER TABLE [Invoice].[tbItem] ADD  CONSTRAINT [DF_Invoice_tbItem_InvoiceValue]  DEFAULT ((0)) FOR [InvoiceValue]
GO
ALTER TABLE [Invoice].[tbItem] ADD  CONSTRAINT [DF_Invoice_tbItem_TaxValue]  DEFAULT ((0)) FOR [TaxValue]
GO
ALTER TABLE [Invoice].[tbItem] ADD  CONSTRAINT [DF_Invoice_tbItem_PaidValue]  DEFAULT ((0)) FOR [PaidValue]
GO
ALTER TABLE [Invoice].[tbItem] ADD  CONSTRAINT [DF_Invoice_tbItem_PaidTaxValue]  DEFAULT ((0)) FOR [PaidTaxValue]
GO
ALTER TABLE [Invoice].[tbTask] ADD  CONSTRAINT [DF_Invoice_tbTask_Quantity]  DEFAULT ((0)) FOR [Quantity]
GO
ALTER TABLE [Invoice].[tbTask] ADD  CONSTRAINT [DF_Invoice_tbActivity_InvoiceValue]  DEFAULT ((0)) FOR [InvoiceValue]
GO
ALTER TABLE [Invoice].[tbTask] ADD  CONSTRAINT [DF_Invoice_tbActivity_TaxValue]  DEFAULT ((0)) FOR [TaxValue]
GO
ALTER TABLE [Invoice].[tbTask] ADD  CONSTRAINT [DF_Invoice_tbTask_PaidValue]  DEFAULT ((0)) FOR [PaidValue]
GO
ALTER TABLE [Invoice].[tbTask] ADD  CONSTRAINT [DF_Invoice_tbTask_PaidTaxValue]  DEFAULT ((0)) FOR [PaidTaxValue]
GO
ALTER TABLE [Invoice].[tbType] ADD  CONSTRAINT [DF_Invoice_tbType_NextNumber]  DEFAULT ((1000)) FOR [NextNumber]
GO
ALTER TABLE [Org].[tbAccount] ADD  CONSTRAINT [DF_Org_tbAccount_OpeningBalance]  DEFAULT ((0)) FOR [OpeningBalance]
GO
ALTER TABLE [Org].[tbAccount] ADD  CONSTRAINT [DF_Org_tbAccount_CurrentBalance]  DEFAULT ((0)) FOR [CurrentBalance]
GO
ALTER TABLE [Org].[tbAccount] ADD  CONSTRAINT [DF_Org_tbAccount_AccountClosed]  DEFAULT ((0)) FOR [AccountClosed]
GO
ALTER TABLE [Org].[tbAccount] ADD  CONSTRAINT [DF_Org_tbAccount_InsertedBy]  DEFAULT (SUSER_SNAME()) FOR [InsertedBy]
GO
ALTER TABLE [Org].[tbAccount] ADD  CONSTRAINT [DF_Org_tbAccount_InsertedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [InsertedOn]
GO
ALTER TABLE [Org].[tbAccount] ADD  CONSTRAINT [DF_Org_tbAccount_UpdatedBy]  DEFAULT (SUSER_SNAME()) FOR [UpdatedBy]
GO
ALTER TABLE [Org].[tbAccount] ADD  CONSTRAINT [DF_Org_tbAccount_UpdatedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [UpdatedOn]
GO
ALTER TABLE [Org].[tbAddress] ADD  CONSTRAINT [DF_Org_tbAddress_InsertedBy]  DEFAULT (SUSER_SNAME()) FOR [InsertedBy]
GO
ALTER TABLE [Org].[tbAddress] ADD  CONSTRAINT [DF_Org_tbAddress_InsertedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [InsertedOn]
GO
ALTER TABLE [Org].[tbAddress] ADD  CONSTRAINT [DF_Org_tbAddress_UpdatedBy]  DEFAULT (SUSER_SNAME()) FOR [UpdatedBy]
GO
ALTER TABLE [Org].[tbAddress] ADD  CONSTRAINT [DF_Org_tbAddress_UpdatedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [UpdatedOn]
GO
ALTER TABLE [Org].[tbContact] ADD  CONSTRAINT [DF_Org_tbContact_OnMailingList]  DEFAULT ((1)) FOR [OnMailingList]
GO
ALTER TABLE [Org].[tbContact] ADD  CONSTRAINT [DF_Org_tbContact_InsertedBy]  DEFAULT (SUSER_SNAME()) FOR [InsertedBy]
GO
ALTER TABLE [Org].[tbContact] ADD  CONSTRAINT [DF_Org_tbContact_InsertedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [InsertedOn]
GO
ALTER TABLE [Org].[tbContact] ADD  CONSTRAINT [DF_Org_tbContact_UpdatedBy]  DEFAULT (SUSER_SNAME()) FOR [UpdatedBy]
GO
ALTER TABLE [Org].[tbContact] ADD  CONSTRAINT [DF_Org_tbContact_UpdatedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [UpdatedOn]
GO
ALTER TABLE [Org].[tbDoc] ADD  CONSTRAINT [DF_Org_tbDoc_InsertedBy]  DEFAULT (SUSER_SNAME()) FOR [InsertedBy]
GO
ALTER TABLE [Org].[tbDoc] ADD  CONSTRAINT [DF_Org_tbDoc_InsertedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [InsertedOn]
GO
ALTER TABLE [Org].[tbDoc] ADD  CONSTRAINT [DF_Org_tbDoc_UpdatedBy]  DEFAULT (SUSER_SNAME()) FOR [UpdatedBy]
GO
ALTER TABLE [Org].[tbDoc] ADD  CONSTRAINT [DF_Org_tbDoc_UpdatedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [UpdatedOn]
GO
ALTER TABLE [Org].[tbOrg] ADD  CONSTRAINT [DF_Org_tb_OrganisationTypeCode]  DEFAULT ((1)) FOR [OrganisationTypeCode]
GO
ALTER TABLE [Org].[tbOrg] ADD  CONSTRAINT [DF_Org_tb_OrganisationStatusCode]  DEFAULT ((1)) FOR [OrganisationStatusCode]
GO
ALTER TABLE [Org].[tbOrg] ADD  CONSTRAINT [DF_Org_tb_NumberOfEmployees]  DEFAULT ((0)) FOR [NumberOfEmployees]
GO
ALTER TABLE [Org].[tbOrg] ADD  CONSTRAINT [DF_Org_tb_Turnover]  DEFAULT ((0)) FOR [Turnover]
GO
ALTER TABLE [Org].[tbOrg] ADD  CONSTRAINT [DF_Org_tb_StatementDays]  DEFAULT ((365)) FOR [StatementDays]
GO
ALTER TABLE [Org].[tbOrg] ADD  CONSTRAINT [DF_Org_tb_OpeningBalance]  DEFAULT ((0)) FOR [OpeningBalance]
GO
ALTER TABLE [Org].[tbOrg] ADD  CONSTRAINT [DF_Org_tb_CurrentBalance]  DEFAULT ((0)) FOR [CurrentBalance]
GO
ALTER TABLE [Org].[tbOrg] ADD  CONSTRAINT [DF_Org_tb_ForeignJurisdiction]  DEFAULT ((0)) FOR [ForeignJurisdiction]
GO
ALTER TABLE [Org].[tbOrg] ADD  CONSTRAINT [DF_Org_tb_InsertedBy]  DEFAULT (SUSER_SNAME()) FOR [InsertedBy]
GO
ALTER TABLE [Org].[tbOrg] ADD  CONSTRAINT [DF_Org_tb_InsertedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [InsertedOn]
GO
ALTER TABLE [Org].[tbOrg] ADD  CONSTRAINT [DF_Org_tb_UpdatedBy]  DEFAULT (SUSER_SNAME()) FOR [UpdatedBy]
GO
ALTER TABLE [Org].[tbOrg] ADD  CONSTRAINT [DF_Org_tb_UpdatedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [UpdatedOn]
GO
ALTER TABLE [Org].[tbOrg] ADD  CONSTRAINT [DF_Org_tb_PaymentDays]  DEFAULT ((0)) FOR [PaymentDays]
GO
ALTER TABLE [Org].[tbOrg] ADD  CONSTRAINT [DF_Org_tb_PayDaysFromMonthEnd]  DEFAULT ((0)) FOR [PayDaysFromMonthEnd]
GO
ALTER TABLE [Org].[tbPayment] ADD  CONSTRAINT [DF_Org_tbPayment_PaymentStatusCode]  DEFAULT ((1)) FOR [PaymentStatusCode]
GO
ALTER TABLE [Org].[tbPayment] ADD  CONSTRAINT [DF_Org_tbPayment_PaidOn]  DEFAULT ((CAST(CURRENT_TIMESTAMP AS DATE))) FOR [PaidOn]
GO
ALTER TABLE [Org].[tbPayment] ADD  CONSTRAINT [DF_Org_tbPayment_PaidInValue]  DEFAULT ((0)) FOR [PaidInValue]
GO
ALTER TABLE [Org].[tbPayment] ADD  CONSTRAINT [DF_Org_tbPayment_PaidOutValue]  DEFAULT ((0)) FOR [PaidOutValue]
GO
ALTER TABLE [Org].[tbPayment] ADD  CONSTRAINT [DF_Org_tbPayment_TaxInValue]  DEFAULT ((0)) FOR [TaxInValue]
GO
ALTER TABLE [Org].[tbPayment] ADD  CONSTRAINT [DF_Org_tbPayment_TaxOutValue]  DEFAULT ((0)) FOR [TaxOutValue]
GO
ALTER TABLE [Org].[tbPayment] ADD  CONSTRAINT [DF_Org_tbPayment_InsertedBy]  DEFAULT (SUSER_SNAME()) FOR [InsertedBy]
GO
ALTER TABLE [Org].[tbPayment] ADD  CONSTRAINT [DF_Org_tbPayment_InsertedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [InsertedOn]
GO
ALTER TABLE [Org].[tbPayment] ADD  CONSTRAINT [DF_Org_tbPayment_UpdatedBy]  DEFAULT (SUSER_SNAME()) FOR [UpdatedBy]
GO
ALTER TABLE [Org].[tbPayment] ADD  CONSTRAINT [DF_Org_tbPayment_UpdatedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [UpdatedOn]
GO
ALTER TABLE [Org].[tbStatus] ADD  CONSTRAINT [DF_Org_tbStatus_OrganisationStatusCode]  DEFAULT ((1)) FOR [OrganisationStatusCode]
GO
ALTER TABLE [Org].[tbType] ADD  CONSTRAINT [DF_Org_tbType_OrganisationTypeCode]  DEFAULT ((1)) FOR [OrganisationTypeCode]
GO
ALTER TABLE [Task].[tbAttribute] ADD  CONSTRAINT [DF_Task_tbAttribute_OrderBy]  DEFAULT ((10)) FOR [PrintOrder]
GO
ALTER TABLE [Task].[tbAttribute] ADD  CONSTRAINT [DF_Task_tbAttribute_AttributeTypeCode]  DEFAULT ((1)) FOR [AttributeTypeCode]
GO
ALTER TABLE [Task].[tbAttribute] ADD  CONSTRAINT [DF_tbJobAttribute_InsertedBy]  DEFAULT (SUSER_SNAME()) FOR [InsertedBy]
GO
ALTER TABLE [Task].[tbAttribute] ADD  CONSTRAINT [DF_tbJobAttribute_InsertedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [InsertedOn]
GO
ALTER TABLE [Task].[tbAttribute] ADD  CONSTRAINT [DF_tbJobAttribute_UpdatedBy]  DEFAULT (SUSER_SNAME()) FOR [UpdatedBy]
GO
ALTER TABLE [Task].[tbAttribute] ADD  CONSTRAINT [DF_tbJobAttribute_UpdatedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [UpdatedOn]
GO
ALTER TABLE [Task].[tbDoc] ADD  CONSTRAINT [DF_Task_tbDoc_InsertedBy]  DEFAULT (SUSER_SNAME()) FOR [InsertedBy]
GO
ALTER TABLE [Task].[tbDoc] ADD  CONSTRAINT [DF_Task_tbDoc_InsertedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [InsertedOn]
GO
ALTER TABLE [Task].[tbDoc] ADD  CONSTRAINT [DF_Task_tbDoc_UpdatedBy]  DEFAULT (SUSER_SNAME()) FOR [UpdatedBy]
GO
ALTER TABLE [Task].[tbDoc] ADD  CONSTRAINT [DF_Task_tbDoc_UpdatedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [UpdatedOn]
GO
ALTER TABLE [Task].[tbFlow] ADD  CONSTRAINT [DF_Task_tbFlow_StepNumber]  DEFAULT ((10)) FOR [StepNumber]
GO
ALTER TABLE [Task].[tbFlow] ADD  CONSTRAINT [DF_Task_tbFlow_UsedOnQuantity]  DEFAULT ((1)) FOR [UsedOnQuantity]
GO
ALTER TABLE [Task].[tbFlow] ADD  CONSTRAINT [DF_Task_tbFlow_OffsetDays]  DEFAULT ((0)) FOR [OffsetDays]
GO
ALTER TABLE [Task].[tbFlow] ADD  CONSTRAINT [DF_Task_tbFlow_InsertedBy]  DEFAULT (SUSER_SNAME()) FOR [InsertedBy]
GO
ALTER TABLE [Task].[tbFlow] ADD  CONSTRAINT [DF_Task_tbFlow_InsertedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [InsertedOn]
GO
ALTER TABLE [Task].[tbFlow] ADD  CONSTRAINT [DF_Task_tbFlow_UpdatedBy]  DEFAULT (SUSER_SNAME()) FOR [UpdatedBy]
GO
ALTER TABLE [Task].[tbFlow] ADD  CONSTRAINT [DF_Task_tbFlow_UpdatedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [UpdatedOn]
GO
ALTER TABLE [Task].[tbOp] ADD  CONSTRAINT [DF_Task_tbOp_OpTypeCode]  DEFAULT ((1)) FOR [OpTypeCode]
GO
ALTER TABLE [Task].[tbOp] ADD  CONSTRAINT [DF_Task_tbOp_OpStatusCode]  DEFAULT ((1)) FOR [OpStatusCode]
GO
ALTER TABLE [Task].[tbOp] ADD  CONSTRAINT [DF_Task_tbOp_StartOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [StartOn]
GO
ALTER TABLE [Task].[tbOp] ADD  CONSTRAINT [DF_Task_tbOp_EndOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [EndOn]
GO
ALTER TABLE [Task].[tbOp] ADD  CONSTRAINT [DF_Task_tbOp_Duration]  DEFAULT ((0)) FOR [Duration]
GO
ALTER TABLE [Task].[tbOp] ADD  CONSTRAINT [DF_Task_tbOp_OffsetDays]  DEFAULT ((0)) FOR [OffsetDays]
GO
ALTER TABLE [Task].[tbOp] ADD  CONSTRAINT [DF_Task_tbOp_InsertedBy]  DEFAULT (SUSER_SNAME()) FOR [InsertedBy]
GO
ALTER TABLE [Task].[tbOp] ADD  CONSTRAINT [DF_Task_tbOp_InsertedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [InsertedOn]
GO
ALTER TABLE [Task].[tbOp] ADD  CONSTRAINT [DF_Task_tbOp_UpdatedBy]  DEFAULT (SUSER_SNAME()) FOR [UpdatedBy]
GO
ALTER TABLE [Task].[tbOp] ADD  CONSTRAINT [DF_Task_tbOp_UpdatedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [UpdatedOn]
GO
ALTER TABLE [Task].[tbQuote] ADD  CONSTRAINT [DF_Task_tbQuote_Quantity]  DEFAULT ((0)) FOR [Quantity]
GO
ALTER TABLE [Task].[tbQuote] ADD  CONSTRAINT [DF_Task_tbQuote_TotalPrice]  DEFAULT ((0)) FOR [TotalPrice]
GO
ALTER TABLE [Task].[tbQuote] ADD  CONSTRAINT [DF_Task_tbQuote_RunOnQuantity]  DEFAULT ((0)) FOR [RunOnQuantity]
GO
ALTER TABLE [Task].[tbQuote] ADD  CONSTRAINT [DF_Task_tbQuote_RunOnPrice]  DEFAULT ((0)) FOR [RunOnPrice]
GO
ALTER TABLE [Task].[tbQuote] ADD  CONSTRAINT [DF_Task_tbQuote_RunBackQuantity]  DEFAULT ((0)) FOR [RunBackQuantity]
GO
ALTER TABLE [Task].[tbQuote] ADD  CONSTRAINT [DF_Task_tbQuote_RunBackPrice]  DEFAULT ((0)) FOR [RunBackPrice]
GO
ALTER TABLE [Task].[tbQuote] ADD  CONSTRAINT [DF_Task_tbQuote_InsertedBy]  DEFAULT (SUSER_SNAME()) FOR [InsertedBy]
GO
ALTER TABLE [Task].[tbQuote] ADD  CONSTRAINT [DF_Task_tbQuote_InsertedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [InsertedOn]
GO
ALTER TABLE [Task].[tbQuote] ADD  CONSTRAINT [DF_Task_tbQuote_UpdatedBy]  DEFAULT (SUSER_SNAME()) FOR [UpdatedBy]
GO
ALTER TABLE [Task].[tbQuote] ADD  CONSTRAINT [DF_Task_tbQuote_UpdatedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [UpdatedOn]
GO
ALTER TABLE [Task].[tbTask] ADD  CONSTRAINT [DF_Task_tbTask_ActionOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [ActionOn]
GO
ALTER TABLE [Task].[tbTask] ADD  CONSTRAINT [DF_Task_tbTask_Quantity]  DEFAULT ((0)) FOR [Quantity]
GO
ALTER TABLE [Task].[tbTask] ADD  CONSTRAINT [DF_Task_tb_UnitCharge]  DEFAULT ((0)) FOR [UnitCharge]
GO
ALTER TABLE [Task].[tbTask] ADD  CONSTRAINT [DF_Task_tb_TotalCharge]  DEFAULT ((0)) FOR [TotalCharge]
GO
ALTER TABLE [Task].[tbTask] ADD  CONSTRAINT [DF_Task_tb_Printed]  DEFAULT ((0)) FOR [Printed]
GO
ALTER TABLE [Task].[tbTask] ADD  CONSTRAINT [DF_Task_tb_InsertedBy]  DEFAULT (SUSER_SNAME()) FOR [InsertedBy]
GO
ALTER TABLE [Task].[tbTask] ADD  CONSTRAINT [DF_Task_tb_InsertedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [InsertedOn]
GO
ALTER TABLE [Task].[tbTask] ADD  CONSTRAINT [DF_Task_tb_UpdatedBy]  DEFAULT (SUSER_SNAME()) FOR [UpdatedBy]
GO
ALTER TABLE [Task].[tbTask] ADD  CONSTRAINT [DF_Task_tb_UpdatedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [UpdatedOn]
GO
ALTER TABLE [Task].[tbTask] ADD  CONSTRAINT [DF_Task_tb_PaymentOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [PaymentOn]
GO
ALTER TABLE [Task].[tbTask] ADD  CONSTRAINT [DF_Task_tb_Spooled]  DEFAULT ((0)) FOR [Spooled]
GO
ALTER TABLE [Usr].[tbMenu] ADD  CONSTRAINT [DF_Usr_tbMenu_InsertedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [InsertedOn]
GO
ALTER TABLE [Usr].[tbMenu] ADD  CONSTRAINT [DF_Usr_tbMenu_InsertedBy]  DEFAULT (SUSER_SNAME()) FOR [InsertedBy]
GO
ALTER TABLE [Usr].[tbMenuCommand] ADD  CONSTRAINT [DF_Usr_tbMenuCommand_Command]  DEFAULT ((0)) FOR [Command]
GO
ALTER TABLE [Usr].[tbMenuEntry] ADD  CONSTRAINT [DF_Usr_tbMenuEntry_MenuId]  DEFAULT ((0)) FOR [MenuId]
GO
ALTER TABLE [Usr].[tbMenuEntry] ADD  CONSTRAINT [DF_Usr_tbMenuEntry_FolderId]  DEFAULT ((0)) FOR [FolderId]
GO
ALTER TABLE [Usr].[tbMenuEntry] ADD  CONSTRAINT [DF_Usr_tbMenuEntry_ItemId]  DEFAULT ((0)) FOR [ItemId]
GO
ALTER TABLE [Usr].[tbMenuEntry] ADD  CONSTRAINT [DF_Usr_tbMenuEntry_Command]  DEFAULT ((0)) FOR [Command]
GO
ALTER TABLE [Usr].[tbMenuEntry] ADD  CONSTRAINT [DF_Usr_tbMenuEntry_OpenMode]  DEFAULT ((1)) FOR [OpenMode]
GO
ALTER TABLE [Usr].[tbMenuEntry] ADD  CONSTRAINT [DF_Usr_tbMenuEntry_UpdatedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [UpdatedOn]
GO
ALTER TABLE [Usr].[tbMenuEntry] ADD  CONSTRAINT [DF_Usr_tbMenuEntry_InsertedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [InsertedOn]
GO
ALTER TABLE [Usr].[tbMenuEntry] ADD  CONSTRAINT [DF_Usr_tbMenuEntry_UpdatedBy]  DEFAULT (SUSER_SNAME()) FOR [UpdatedBy]
GO
ALTER TABLE [Usr].[tbMenuOpenMode] ADD  CONSTRAINT [DF_Usr_tbMenuOpenMode_OpenMode]  DEFAULT ((0)) FOR [OpenMode]
GO
ALTER TABLE [Usr].[tbUser] ADD  CONSTRAINT [DF_Usr_tb_LogonName]  DEFAULT (SUSER_SNAME()) FOR [LogonName]
GO
ALTER TABLE [Usr].[tbUser] ADD  CONSTRAINT [DF_Usr_tb_Administrator]  DEFAULT ((0)) FOR [Administrator]
GO
ALTER TABLE [Usr].[tbUser] ADD  CONSTRAINT [DF_Usr_tb_InsertedBy]  DEFAULT (SUSER_SNAME()) FOR [InsertedBy]
GO
ALTER TABLE [Usr].[tbUser] ADD  CONSTRAINT [DF_Usr_tb_InsertedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [InsertedOn]
GO
ALTER TABLE [Usr].[tbUser] ADD  CONSTRAINT [DF_Usr_tb_UpdatedBy]  DEFAULT (SUSER_SNAME()) FOR [UpdatedBy]
GO
ALTER TABLE [Usr].[tbUser] ADD  CONSTRAINT [DF_Usr_tb_UpdatedOn]  DEFAULT (CURRENT_TIMESTAMP) FOR [UpdatedOn]
GO
ALTER TABLE [Usr].[tbUser] ADD  CONSTRAINT [DF_Usr_tb_NextTaskNumber]  DEFAULT ((1)) FOR [NextTaskNumber]
GO

