/************************************************************
* Tru-Man Trade Control: Information and Cash System
* Copyright Trade Control Ltd 2008. All Rights Reserved.
* Author: Ian Monnox
* Description: Sql Server Creation Script - Encrypted Distribution Schema
* Data Version: 2.01
* Release Date: 12.01.12
************************************************************/

/****** Object:  Table [dbo].[tbCashCategoryType]    Script Date: 01/11/2012 13:35:40 ******/
GO
CREATE TABLE [dbo].[tbCashCategoryType](
	[CategoryTypeCode] [smallint] NOT NULL,
	[CategoryType] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_tbCashCategoryType] PRIMARY KEY CLUSTERED 
(
	[CategoryTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbCashMode]    Script Date: 01/11/2012 13:35:43 ******/
GO
CREATE TABLE [dbo].[tbCashMode](
	[CashModeCode] [smallint] NOT NULL,
	[CashMode] [nvarchar](10) NULL,
 CONSTRAINT [PK_tbCashMode] PRIMARY KEY CLUSTERED 
(
	[CashModeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbCashStatus]    Script Date: 01/11/2012 13:35:45 ******/
GO
CREATE TABLE [dbo].[tbCashStatus](
	[CashStatusCode] [smallint] NOT NULL,
	[CashStatus] [nvarchar](15) NOT NULL,
 CONSTRAINT [PK_tbCashStatus] PRIMARY KEY CLUSTERED 
(
	[CashStatusCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbCashType]    Script Date: 01/11/2012 13:35:47 ******/
GO
CREATE TABLE [dbo].[tbCashType](
	[CashTypeCode] [smallint] NOT NULL,
	[CashType] [nvarchar](25) NULL,
 CONSTRAINT [PK_tbCashType] PRIMARY KEY CLUSTERED 
(
	[CashTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbInvoiceStatus]    Script Date: 01/11/2012 13:35:52 ******/
GO
CREATE TABLE [dbo].[tbInvoiceStatus](
	[InvoiceStatusCode] [smallint] NOT NULL,
	[InvoiceStatus] [nvarchar](50) NULL,
 CONSTRAINT [aaaaatbInvoiceStatus_PK] PRIMARY KEY NONCLUSTERED 
(
	[InvoiceStatusCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbOrgPaymentStatus]    Script Date: 01/11/2012 13:36:14 ******/
GO
CREATE TABLE [dbo].[tbOrgPaymentStatus](
	[PaymentStatusCode] [smallint] NOT NULL,
	[PaymentStatus] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_tbOrgPaymentStatus] PRIMARY KEY CLUSTERED 
(
	[PaymentStatusCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbOrgStatus]    Script Date: 01/11/2012 13:36:15 ******/
GO
CREATE TABLE [dbo].[tbOrgStatus](
	[OrganisationStatusCode] [smallint] NOT NULL CONSTRAINT [DF__tbOrgStat__Organ__07C12930]  DEFAULT ((1)),
	[OrganisationStatus] [nvarchar](255) NULL,
 CONSTRAINT [aaaaatbOrgStatus_PK] PRIMARY KEY NONCLUSTERED 
(
	[OrganisationStatusCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbProfileCustom]    Script Date: 01/11/2012 13:36:16 ******/
GO
CREATE TABLE [dbo].[tbProfileCustom](
	[SectionCode] [nvarchar](20) NOT NULL,
	[SectionContent] [nvarchar](255) NULL,
	[ValidateClient] [bit] NOT NULL CONSTRAINT [DF_tbProfileCustom_ValidateProperty]  DEFAULT ((0)),
 CONSTRAINT [aaaaatbLocalCustomisation_PK] PRIMARY KEY NONCLUSTERED 
(
	[SectionCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbProfileItemType]    Script Date: 01/11/2012 13:36:16 ******/
GO
CREATE TABLE [dbo].[tbProfileItemType](
	[ItemTypeCode] [smallint] NOT NULL CONSTRAINT [DF_tbProfileItemType_ItemTypeCode]  DEFAULT ((0)),
	[ItemType] [nvarchar](50) NULL,
 CONSTRAINT [PK_tbProfileItemType] PRIMARY KEY CLUSTERED 
(
	[ItemTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbProfileLink]    Script Date: 01/11/2012 13:36:17 ******/
GO
CREATE TABLE [dbo].[tbProfileLink](
	[LinkName] [nvarchar](100) NOT NULL,
	[SqlView] [nvarchar](50) NULL,
	[SqlIndex] [nvarchar](150) NULL,
 CONSTRAINT [PK_tbProfileLink] PRIMARY KEY CLUSTERED 
(
	[LinkName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbProfileMenu]    Script Date: 01/11/2012 13:36:18 ******/
GO
CREATE TABLE [dbo].[tbProfileMenu](
	[MenuId] [smallint] IDENTITY(1,1) NOT NULL,
	[MenuName] [nvarchar](50) NOT NULL,
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbProfileMenu_InsertedOn]  DEFAULT (getdate()),
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbProfileMenu_InsertedBy]  DEFAULT (suser_sname()),
 CONSTRAINT [PK_tbProfileMenu] PRIMARY KEY CLUSTERED 
(
	[MenuId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY],
 CONSTRAINT [IX_tbProfileMenu] UNIQUE NONCLUSTERED 
(
	[MenuName] ASC,
	[MenuId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbProfileMenuCommand]    Script Date: 01/11/2012 13:36:18 ******/
GO
CREATE TABLE [dbo].[tbProfileMenuCommand](
	[Command] [smallint] NOT NULL CONSTRAINT [DF_tbProfileMenuCommand_Command]  DEFAULT ((0)),
	[CommandText] [nvarchar](50) NULL,
 CONSTRAINT [PK_tbProfileMenuCommand] PRIMARY KEY CLUSTERED 
(
	[Command] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbProfileMenuOpenMode]    Script Date: 01/11/2012 13:36:21 ******/
GO
CREATE TABLE [dbo].[tbProfileMenuOpenMode](
	[OpenMode] [smallint] NOT NULL CONSTRAINT [DF_tbProfileMenuOpenMode_OpenMode]  DEFAULT ((0)),
	[OpenModeDescription] [nvarchar](20) NULL,
 CONSTRAINT [PK_tbProfileMenuOpenMode] PRIMARY KEY CLUSTERED 
(
	[OpenMode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbProfileObjectType]    Script Date: 01/11/2012 13:36:26 ******/
GO
CREATE TABLE [dbo].[tbProfileObjectType](
	[ObjectTypeCode] [smallint] NOT NULL CONSTRAINT [DF_tbProfileObjectType_ObjectTypeCode]  DEFAULT ((0)),
	[ObjectType] [nvarchar](50) NULL,
 CONSTRAINT [PK_tbProfileObjectType] PRIMARY KEY CLUSTERED 
(
	[ObjectTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbProfileText]    Script Date: 01/11/2012 13:36:26 ******/
GO
CREATE TABLE [dbo].[tbProfileText](
	[TextId] [int] NOT NULL,
	[Message] [ntext] NOT NULL,
	[Arguments] [smallint] NOT NULL,
 CONSTRAINT [PK_tbProfileText] PRIMARY KEY CLUSTERED 
(
	[TextId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbSystemBucket]    Script Date: 01/11/2012 13:36:27 ******/
GO
CREATE TABLE [dbo].[tbSystemBucket](
	[Period] [smallint] NOT NULL,
	[BucketId] [nvarchar](10) NOT NULL,
	[BucketDescription] [nvarchar](50) NULL,
	[AllowForecasts] [bit] NOT NULL,
 CONSTRAINT [PK_tbSystemBucket] PRIMARY KEY CLUSTERED 
(
	[Period] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbSystemBucketInterval]    Script Date: 01/11/2012 13:36:27 ******/
GO
CREATE TABLE [dbo].[tbSystemBucketInterval](
	[BucketIntervalCode] [smallint] NOT NULL,
	[BucketInterval] [nvarchar](15) NOT NULL,
 CONSTRAINT [PK_tbSystemBucketInterval] PRIMARY KEY CLUSTERED 
(
	[BucketIntervalCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbSystemBucketType]    Script Date: 01/11/2012 13:36:28 ******/
GO
CREATE TABLE [dbo].[tbSystemBucketType](
	[BucketTypeCode] [smallint] NOT NULL,
	[BucketType] [nvarchar](25) NOT NULL,
 CONSTRAINT [PK_tbSystemBucketType] PRIMARY KEY CLUSTERED 
(
	[BucketTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbSystemCalendar]    Script Date: 01/11/2012 13:36:29 ******/
GO
CREATE TABLE [dbo].[tbSystemCalendar](
	[CalendarCode] [nvarchar](10) NOT NULL,
	[Monday] [bit] NOT NULL CONSTRAINT [DF_tbSystemCalendar_Monday]  DEFAULT ((1)),
	[Tuesday] [bit] NOT NULL CONSTRAINT [DF_tbSystemCalendar_Tuesday]  DEFAULT ((1)),
	[Wednesday] [bit] NOT NULL CONSTRAINT [DF_tbSystemCalendar_Wednesday]  DEFAULT ((1)),
	[Thursday] [bit] NOT NULL CONSTRAINT [DF_tbSystemCalendar_Thursday]  DEFAULT ((1)),
	[Friday] [bit] NOT NULL CONSTRAINT [DF_tbSystemCalendar_Friday]  DEFAULT ((1)),
	[Saturday] [bit] NOT NULL CONSTRAINT [DF_tbSystemCalendar_Saturday]  DEFAULT ((0)),
	[Sunday] [bit] NOT NULL CONSTRAINT [DF_tbSystemCalendar_Sunday]  DEFAULT ((0)),
 CONSTRAINT [PK_tbSystemCalendar] PRIMARY KEY CLUSTERED 
(
	[CalendarCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbTaskOpStatus]    Script Date: 01/11/2012 13:36:57 ******/
GO
CREATE TABLE [dbo].[tbTaskOpStatus](
	[OpStatusCode] [smallint] NOT NULL,
	[OpStatus] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tbTaskOpStatus] PRIMARY KEY CLUSTERED 
(
	[OpStatusCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbSystemDocType]    Script Date: 01/11/2012 13:36:31 ******/
GO
CREATE TABLE [dbo].[tbSystemDocType](
	[DocTypeCode] [smallint] NOT NULL,
	[DocType] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tbSystemDocType] PRIMARY KEY CLUSTERED 
(
	[DocTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbSystemInstall]    Script Date: 01/11/2012 13:36:33 ******/
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbSystemInstall](
	[InstallId] [int] IDENTITY(1,1) NOT NULL,
	[InstalledOn] [datetime] NOT NULL CONSTRAINT [DF_tbSystemInstall_InstalledOn]  DEFAULT (getdate()),
	[InstalledBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbSystemInstall_InstalledBy]  DEFAULT (suser_sname()),
	[DataVersion] [float] NOT NULL,
	[CategoryId] [smallint] NOT NULL CONSTRAINT [DF_tbSystemInstall_CategoryId]  DEFAULT ((0)),
	[CategoryTypeCode] [smallint] NOT NULL,
	[ReleaseTypeCode] [smallint] NOT NULL,
	[Licence] [binary](50) NULL,
	[LicenceType] [smallint] NULL,
 CONSTRAINT [PK_tbSystemInstall] PRIMARY KEY CLUSTERED 
(
	[InstallId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbSystemRecurrence]    Script Date: 01/11/2012 13:36:37 ******/
GO
CREATE TABLE [dbo].[tbSystemRecurrence](
	[RecurrenceCode] [smallint] NOT NULL,
	[Recurrence] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_tbSystemRecurrence] PRIMARY KEY CLUSTERED 
(
	[RecurrenceCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbSystemMonth]    Script Date: 01/11/2012 13:36:33 ******/
GO
CREATE TABLE [dbo].[tbSystemMonth](
	[MonthNumber] [smallint] NOT NULL,
	[MonthName] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_tbSystemMonth] PRIMARY KEY CLUSTERED 
(
	[MonthNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbSystemRegister]    Script Date: 01/11/2012 13:36:37 ******/
GO
CREATE TABLE [dbo].[tbSystemRegister](
	[RegisterName] [nvarchar](50) NOT NULL,
	[NextNumber] [int] NOT NULL CONSTRAINT [DF_tbSystemRegister_NextNumber]  DEFAULT ((1)),
 CONSTRAINT [PK_tbSystemRegister] PRIMARY KEY CLUSTERED 
(
	[RegisterName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbSystemCodeExclusion]    Script Date: 01/11/2012 13:36:30 ******/
GO
CREATE TABLE [dbo].[tbSystemCodeExclusion](
	[ExcludedTag] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_tbSystemCodeExclusion] PRIMARY KEY CLUSTERED 
(
	[ExcludedTag] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbSystemUom]    Script Date: 01/11/2012 13:36:39 ******/
GO
CREATE TABLE [dbo].[tbSystemUom](
	[UnitOfMeasure] [nvarchar](15) NOT NULL,
 CONSTRAINT [PK_tbSystemUom] PRIMARY KEY CLUSTERED 
(
	[UnitOfMeasure] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbTaskStatus]    Script Date: 01/11/2012 13:37:00 ******/
GO
CREATE TABLE [dbo].[tbTaskStatus](
	[TaskStatusCode] [smallint] NOT NULL,
	[TaskStatus] [nvarchar](100) NOT NULL,
 CONSTRAINT [aaaaatbActivityStatus_PK] PRIMARY KEY NONCLUSTERED 
(
	[TaskStatusCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ActivityStatus] ON [dbo].[tbTaskStatus] 
(
	[TaskStatus] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbCashEntryType]    Script Date: 01/11/2012 13:35:42 ******/
GO
CREATE TABLE [dbo].[tbCashEntryType](
	[CashEntryTypeCode] [smallint] NOT NULL,
	[CashEntryType] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_tbCashEntryType] PRIMARY KEY CLUSTERED 
(
	[CashEntryTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbActivityOpType]    Script Date: 01/11/2012 13:35:36 ******/
GO
CREATE TABLE [dbo].[tbActivityOpType](
	[OpTypeCode] [smallint] NOT NULL,
	[OpType] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tbActivityOpType] PRIMARY KEY CLUSTERED 
(
	[OpTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbActivityAttributeType]    Script Date: 01/11/2012 13:35:31 ******/
GO
CREATE TABLE [dbo].[tbActivityAttributeType](
	[AttributeTypeCode] [smallint] NOT NULL,
	[AttributeType] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_tbActivityAttributeType] PRIMARY KEY CLUSTERED 
(
	[AttributeTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbCashCategory]    Script Date: 01/11/2012 13:35:38 ******/
GO
CREATE TABLE [dbo].[tbCashCategory](
	[CategoryCode] [nvarchar](10) NOT NULL,
	[Category] [nvarchar](50) NOT NULL,
	[CategoryTypeCode] [smallint] NOT NULL CONSTRAINT [DF_tbCashCategory_CategoryTypeCode]  DEFAULT ((1)),
	[CashModeCode] [smallint] NULL CONSTRAINT [DF_tbCashCategory_CashModeCode]  DEFAULT ((1)),
	[CashTypeCode] [smallint] NULL CONSTRAINT [DF_tbCashCategory_CashTypeCode]  DEFAULT ((1)),
	[DisplayOrder] [smallint] NOT NULL CONSTRAINT [DF_tbCashCategory_DisplayOrder]  DEFAULT ((0)),
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbCashCategory_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbCashCategory_InsertedOn]  DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbCashCategory_UpdatedBy]  DEFAULT (suser_sname()),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbCashCategory_UpdatedOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_tbCashCategory] PRIMARY KEY CLUSTERED 
(
	[CategoryCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbCashCategory_DisplayOrder] ON [dbo].[tbCashCategory] 
(
	[DisplayOrder] ASC,
	[Category] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbCashCategory_Name] ON [dbo].[tbCashCategory] 
(
	[Category] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbCashCategory_TypeCategory] ON [dbo].[tbCashCategory] 
(
	[CategoryTypeCode] ASC,
	[Category] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbCashCategory_TypeOrderCategory] ON [dbo].[tbCashCategory] 
(
	[CategoryTypeCode] ASC,
	[DisplayOrder] ASC,
	[Category] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbActivity]    Script Date: 01/11/2012 13:35:28 ******/
GO
CREATE TABLE [dbo].[tbActivity](
	[ActivityCode] [nvarchar](50) NOT NULL,
	[TaskStatusCode] [smallint] NOT NULL CONSTRAINT [DF_tbActivity_TaskStatusCode]  DEFAULT ((1)),
	[DefaultText] [ntext] NULL,
	[UnitOfMeasure] [nvarchar](15) NOT NULL,
	[CashCode] [nvarchar](50) NULL,
	[UnitCharge] [money] NOT NULL CONSTRAINT [DF_tbActivity_UnitCharge_1]  DEFAULT ((0)),
	[PrintOrder] [bit] NOT NULL CONSTRAINT [DF_tbActivity_PrintOrder]  DEFAULT ((0)),
	[RegisterName] [nvarchar](50) NULL,
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbActivityCode_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbActivityCode_InsertedOn]  DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbActivityCode_UpdatedBy]  DEFAULT (suser_sname()),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbActivityCode_UpdatedOn]  DEFAULT (getdate()),
 CONSTRAINT [aaaaatbActivityCode_PK] PRIMARY KEY NONCLUSTERED 
(
	[ActivityCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbTask]    Script Date: 01/11/2012 13:36:47 ******/
GO
CREATE TABLE [dbo].[tbTask](
	[TaskCode] [nvarchar](20) NOT NULL,
	[UserId] [nvarchar](10) NOT NULL,
	[AccountCode] [nvarchar](10) NOT NULL,
	[TaskTitle] [nvarchar](100) NULL,
	[ContactName] [nvarchar](100) NULL,
	[ActivityCode] [nvarchar](50) NOT NULL,
	[TaskStatusCode] [smallint] NOT NULL,
	[ActionById] [nvarchar](10) NOT NULL,
	[ActionOn] [datetime] NOT NULL CONSTRAINT [DF__tbActivit__Actio__1FCDBCEB]  DEFAULT (getdate()),
	[ActionedOn] [datetime] NULL,
	[PaymentOn] [datetime] NOT NULL CONSTRAINT [DF_tbTask_PaymentOn]  DEFAULT (getdate()),
	[SecondReference] [nvarchar](20) NULL,
	[TaskNotes] [ntext] NULL,
	[Quantity] [float] NOT NULL CONSTRAINT [DF_tbActivity_Quantity]  DEFAULT ((0)),
	[CashCode] [nvarchar](50) NULL,
	[TaxCode] [nvarchar](10) NULL,
	[UnitCharge] [float] NOT NULL CONSTRAINT [DF_tbTask_UnitCharge]  DEFAULT ((0)),
	[TotalCharge] [money] NOT NULL CONSTRAINT [DF_tbTask_TotalCharge]  DEFAULT ((0)),
	[AddressCodeFrom] [nvarchar](15) NULL,
	[AddressCodeTo] [nvarchar](15) NULL,
	[Printed] [bit] NOT NULL CONSTRAINT [DF_tbTask_Printed]  DEFAULT ((0)),
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbTask_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbTask_InsertedOn]  DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbTask_UpdatedBy]  DEFAULT (suser_sname()),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbTask_UpdatedOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_tbTask] PRIMARY KEY CLUSTERED 
(
	[TaskCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbTask_AccountCode] ON [dbo].[tbTask] 
(
	[AccountCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbTask_AccountCodeByActionOn] ON [dbo].[tbTask] 
(
	[AccountCode] ASC,
	[ActionOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbTask_AccountCodeByStatus] ON [dbo].[tbTask] 
(
	[AccountCode] ASC,
	[TaskStatusCode] ASC,
	[ActionOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbTask_ActionBy] ON [dbo].[tbTask] 
(
	[ActionById] ASC,
	[TaskStatusCode] ASC,
	[ActionOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbTask_ActionById] ON [dbo].[tbTask] 
(
	[ActionById] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbTask_ActionOn] ON [dbo].[tbTask] 
(
	[ActionOn] DESC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbTask_ActionOnStatus] ON [dbo].[tbTask] 
(
	[TaskStatusCode] ASC,
	[ActionOn] ASC,
	[AccountCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbTask_ActivityCode] ON [dbo].[tbTask] 
(
	[ActivityCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbTask_ActivityCodeTaskTitle] ON [dbo].[tbTask] 
(
	[ActivityCode] ASC,
	[TaskTitle] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbTask_ActivityStatusCode] ON [dbo].[tbTask] 
(
	[TaskStatusCode] ASC,
	[ActionOn] ASC,
	[AccountCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbTask_CashCode] ON [dbo].[tbTask] 
(
	[CashCode] ASC,
	[TaskStatusCode] ASC,
	[ActionOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbTask_TaskStatusCode] ON [dbo].[tbTask] 
(
	[TaskStatusCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbTask_UserId] ON [dbo].[tbTask] 
(
	[UserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbOrgPayment]    Script Date: 01/11/2012 13:36:13 ******/
GO
CREATE TABLE [dbo].[tbOrgPayment](
	[PaymentCode] [nvarchar](20) NOT NULL,
	[UserId] [nvarchar](10) NOT NULL,
	[PaymentStatusCode] [smallint] NOT NULL CONSTRAINT [DF_tbOrgPayment_PaymentStatusCode]  DEFAULT ((1)),
	[AccountCode] [nvarchar](10) NOT NULL,
	[CashAccountCode] [nvarchar](10) NOT NULL,
	[CashCode] [nvarchar](50) NULL,
	[TaxCode] [nvarchar](10) NULL,
	[PaidOn] [datetime] NOT NULL CONSTRAINT [DF_tbOrgPayment_PaidOn]  DEFAULT (CONVERT([datetime],CONVERT([varchar],getdate(),(1)),(1))),
	[PaidInValue] [money] NOT NULL CONSTRAINT [DF_tbOrgPayment_PaidValue]  DEFAULT ((0)),
	[PaidOutValue] [money] NOT NULL CONSTRAINT [DF_tbOrgPayment_PaidTaxValue]  DEFAULT ((0)),
	[TaxInValue] [money] NOT NULL CONSTRAINT [DF_tbOrgPayment_PaidInValue1]  DEFAULT ((0)),
	[TaxOutValue] [money] NOT NULL CONSTRAINT [DF_tbOrgPayment_PaidOutValue1]  DEFAULT ((0)),
	[PaymentReference] [nvarchar](50) NULL,
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbOrgPayment_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbOrgPayment_InsertedOn]  DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbOrgPayment_UpdatedBy]  DEFAULT (suser_sname()),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbOrgPayment_UpdatedOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_tbOrgPayment] PRIMARY KEY CLUSTERED 
(
	[PaymentCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbOrgPayment] ON [dbo].[tbOrgPayment] 
(
	[PaymentReference] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbOrgPayment_AccountCode] ON [dbo].[tbOrgPayment] 
(
	[AccountCode] ASC,
	[PaidOn] DESC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbOrgPayment_CashAccountCode] ON [dbo].[tbOrgPayment] 
(
	[CashAccountCode] ASC,
	[PaidOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbOrgPayment_CashCode] ON [dbo].[tbOrgPayment] 
(
	[CashCode] ASC,
	[PaidOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbOrgPayment_PaymentStatusCode] ON [dbo].[tbOrgPayment] 
(
	[PaymentStatusCode] ASC,
	[AccountCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbInvoiceTask]    Script Date: 01/11/2012 13:35:53 ******/
GO
CREATE TABLE [dbo].[tbInvoiceTask](
	[InvoiceNumber] [nvarchar](20) NOT NULL,
	[TaskCode] [nvarchar](20) NOT NULL,
	[Quantity] [float] NOT NULL CONSTRAINT [DF_tbInvoiceTask_Quantity]  DEFAULT ((0)),
	[InvoiceValue] [money] NOT NULL CONSTRAINT [DF_tbInvoiceActivity_InvoiceValue]  DEFAULT ((0)),
	[TaxValue] [money] NOT NULL CONSTRAINT [DF_tbInvoiceActivity_TaxValue]  DEFAULT ((0)),
	[PaidValue] [money] NOT NULL CONSTRAINT [DF_tbInvoiceTask_PaidValue]  DEFAULT ((0)),
	[PaidTaxValue] [money] NOT NULL CONSTRAINT [DF_tbInvoiceTask_PaidTaxValue]  DEFAULT ((0)),
	[CashCode] [nvarchar](50) NOT NULL,
	[TaxCode] [nvarchar](10) NULL,
 CONSTRAINT [PK_tbInvoiceTask] PRIMARY KEY CLUSTERED 
(
	[InvoiceNumber] ASC,
	[TaskCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbInvoiceTask_CashCode] ON [dbo].[tbInvoiceTask] 
(
	[CashCode] ASC,
	[InvoiceNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbInvoiceTask_TaskCode] ON [dbo].[tbInvoiceTask] 
(
	[TaskCode] ASC,
	[InvoiceNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbCashPeriod]    Script Date: 01/11/2012 13:35:44 ******/
GO
CREATE TABLE [dbo].[tbCashPeriod](
	[CashCode] [nvarchar](50) NOT NULL,
	[StartOn] [datetime] NOT NULL,
	[ForecastValue] [money] NOT NULL CONSTRAINT [DF_tbCashPeriod_ForecastValue]  DEFAULT ((0)),
	[ForecastTax] [money] NOT NULL CONSTRAINT [DF_tbCashPeriod_ForecastTax]  DEFAULT ((0)),
	[CashValue] [money] NOT NULL CONSTRAINT [DF_tbCashPeriod_ActualValue]  DEFAULT ((0)),
	[CashTax] [money] NOT NULL CONSTRAINT [DF_tbCashPeriod_ActualTax]  DEFAULT ((0)),
	[InvoiceValue] [money] NOT NULL CONSTRAINT [DF_tbCashPeriod_InvoiceValue]  DEFAULT ((0)),
	[InvoiceTax] [money] NOT NULL CONSTRAINT [DF_tbCashPeriod_InvoiceTax]  DEFAULT ((0)),
	[Note] [ntext] NULL,
 CONSTRAINT [PK_tbCashPeriod] PRIMARY KEY CLUSTERED 
(
	[CashCode] ASC,
	[StartOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbInvoiceItem]    Script Date: 01/11/2012 13:35:51 ******/
GO
CREATE TABLE [dbo].[tbInvoiceItem](
	[InvoiceNumber] [nvarchar](20) NOT NULL,
	[CashCode] [nvarchar](50) NOT NULL,
	[TaxCode] [nvarchar](10) NULL,
	[InvoiceValue] [money] NOT NULL CONSTRAINT [DF_tbInvoiceItem_InvoiceValue]  DEFAULT ((0)),
	[TaxValue] [money] NOT NULL CONSTRAINT [DF_tbInvoiceItem_TaxValue]  DEFAULT ((0)),
	[PaidValue] [money] NOT NULL CONSTRAINT [DF_tbInvoiceItem_PaidValue]  DEFAULT ((0)),
	[PaidTaxValue] [money] NOT NULL CONSTRAINT [DF_tbInvoiceItem_PaidTaxValue]  DEFAULT ((0)),
	[ItemReference] [ntext] NULL,
 CONSTRAINT [PK_tbInvoiceItem] PRIMARY KEY CLUSTERED 
(
	[InvoiceNumber] ASC,
	[CashCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbInvoiceItem_CashCode] ON [dbo].[tbInvoiceItem] 
(
	[CashCode] ASC,
	[InvoiceNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbOrgAccount]    Script Date: 01/11/2012 13:36:02 ******/
GO
CREATE TABLE [dbo].[tbOrgAccount](
	[CashAccountCode] [nvarchar](10) NOT NULL,
	[AccountCode] [nvarchar](10) NOT NULL,
	[CashAccountName] [nvarchar](50) NOT NULL,
	[OpeningBalance] [money] NOT NULL CONSTRAINT [DF_tbOrgAccount_OpeningBalance]  DEFAULT ((0)),
	[CurrentBalance] [money] NOT NULL CONSTRAINT [DF_tbOrgAccount_CurrentBalance]  DEFAULT ((0)),
	[SortCode] [nvarchar](10) NULL,
	[AccountNumber] [nvarchar](20) NULL,
	[CashCode] [nvarchar](50) NULL,
	[AccountClosed] [bit] NOT NULL CONSTRAINT [DF_tbOrgAccount_AccountClosed]  DEFAULT ((0)),
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbOrgAccount_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbOrgAccount_InsertedOn]  DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbOrgAccount_UpdatedBy]  DEFAULT (suser_sname()),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbOrgAccount_UpdatedOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_tbOrgAccount] PRIMARY KEY CLUSTERED 
(
	[CashAccountCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tbOrgAccount] ON [dbo].[tbOrgAccount] 
(
	[AccountCode] ASC,
	[CashAccountCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbCashTaxType]    Script Date: 01/11/2012 13:35:46 ******/
GO
CREATE TABLE [dbo].[tbCashTaxType](
	[TaxTypeCode] [smallint] NOT NULL,
	[TaxType] [nvarchar](20) NOT NULL,
	[CashCode] [nvarchar](50) NULL,
	[MonthNumber] [smallint] NOT NULL CONSTRAINT [DF_tbSystemOptions_MonthNumber]  DEFAULT ((1)),
	[RecurrenceCode] [smallint] NOT NULL CONSTRAINT [DF_tbSystemOptions_Recurrence]  DEFAULT ((1)),
	[AccountCode] [nvarchar](10) NULL,
 CONSTRAINT [PK_tbCashTaxType] PRIMARY KEY CLUSTERED 
(
	[TaxTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbInvoiceType]    Script Date: 01/11/2012 13:35:54 ******/
GO
CREATE TABLE [dbo].[tbInvoiceType](
	[InvoiceTypeCode] [smallint] NOT NULL,
	[InvoiceType] [nvarchar](20) NOT NULL,
	[CashModeCode] [smallint] NOT NULL,
	[NextNumber] [int] NOT NULL CONSTRAINT [DF_tbInvoiceType_NextNumber]  DEFAULT ((1000)),
 CONSTRAINT [PK_tbInvoiceType] PRIMARY KEY CLUSTERED 
(
	[InvoiceTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbOrgType]    Script Date: 01/11/2012 13:36:15 ******/
GO
CREATE TABLE [dbo].[tbOrgType](
	[OrganisationTypeCode] [smallint] NOT NULL CONSTRAINT [DF__tbOrgType__Organ__3F466844]  DEFAULT ((1)),
	[CashModeCode] [smallint] NOT NULL,
	[OrganisationType] [nvarchar](50) NOT NULL,
 CONSTRAINT [aaaaatbOrgType_PK] PRIMARY KEY NONCLUSTERED 
(
	[OrganisationTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbSystemYearPeriod]    Script Date: 01/11/2012 13:36:42 ******/
GO
CREATE TABLE [dbo].[tbSystemYearPeriod](
	[YearNumber] [smallint] NOT NULL,
	[StartOn] [datetime] NOT NULL,
	[MonthNumber] [smallint] NOT NULL,
	[CashStatusCode] [smallint] NOT NULL CONSTRAINT [DF_tbSystemYearPeriod_CashStatusCode]  DEFAULT ((1)),
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbSystemYearPeriod_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbSystemYearPeriod_InsertedOn]  DEFAULT (getdate()),
	[CorporationTaxRate] [real] NOT NULL CONSTRAINT [DF_tbSystemYearPeriod_CorporationTaxRate]  DEFAULT ((0)),
	[TaxAdjustment] [money] NOT NULL CONSTRAINT [DF_tbSystemYearPeriod_TaxAdjustment]  DEFAULT ((0)),
	[VatAdjustment] [money] NOT NULL CONSTRAINT [DF_tbSystemYearPeriod_VatAdjustment]  DEFAULT ((0)),
 CONSTRAINT [PK_tbSystemYearPeriod] PRIMARY KEY CLUSTERED 
(
	[YearNumber] ASC,
	[StartOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY],
 CONSTRAINT [IX_tbSystemYearPeriod_StartOn] UNIQUE NONCLUSTERED 
(
	[StartOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY],
 CONSTRAINT [IX_tbSystemYearPeriod_Year_MonthNumber] UNIQUE NONCLUSTERED 
(
	[YearNumber] ASC,
	[MonthNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbSystemTaxCode]    Script Date: 01/11/2012 13:36:38 ******/
GO
CREATE TABLE [dbo].[tbSystemTaxCode](
	[TaxCode] [nvarchar](10) NOT NULL,
	[TaxRate] [float] NOT NULL CONSTRAINT [DF_tbSystemVatCode_VatRate]  DEFAULT ((0)),
	[TaxDescription] [nvarchar](50) NOT NULL,
	[TaxTypeCode] [smallint] NOT NULL CONSTRAINT [DF_tbSystemTaxCode_TaxTypeCode]  DEFAULT ((2)),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbSystemTaxCode_UpdatedBy]  DEFAULT (suser_sname()),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbSystemTaxCode_UpdatedOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_tbSystemVatCode] PRIMARY KEY CLUSTERED 
(
	[TaxCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbSystemTaxCodeByType] ON [dbo].[tbSystemTaxCode] 
(
	[TaxTypeCode] ASC,
	[TaxCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbInvoice]    Script Date: 01/11/2012 13:35:49 ******/
GO
CREATE TABLE [dbo].[tbInvoice](
	[InvoiceNumber] [nvarchar](20) NOT NULL,
	[UserId] [nvarchar](10) NOT NULL,
	[AccountCode] [nvarchar](10) NOT NULL,
	[InvoiceTypeCode] [smallint] NOT NULL,
	[InvoiceStatusCode] [smallint] NOT NULL,
	[InvoicedOn] [datetime] NOT NULL CONSTRAINT [DF__tbInvoice__Invoi__1273C1CD]  DEFAULT (CONVERT([datetime],CONVERT([varchar],getdate(),(1)),(1))),
	[InvoiceValue] [money] NOT NULL CONSTRAINT [DF__tbInvoice__Invoi__1367E606]  DEFAULT ((0)),
	[TaxValue] [money] NOT NULL CONSTRAINT [DF__tbInvoice__TaxVa__145C0A3F]  DEFAULT ((0)),
	[PaidValue] [money] NOT NULL CONSTRAINT [DF__tbInvoice__PaidV__15502E78]  DEFAULT ((0)),
	[PaidTaxValue] [money] NOT NULL CONSTRAINT [DF__tbInvoice__PaidT__164452B1]  DEFAULT ((0)),
	[PaymentTerms] [nvarchar](100) NULL,
	[Notes] [ntext] NULL,
	[Printed] [bit] NOT NULL CONSTRAINT [DF_tbInvoice_Printed]  DEFAULT ((0)),
	[CollectOn] [datetime] NOT NULL CONSTRAINT [DF_tbInvoice_CollectOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_tbInvoice] PRIMARY KEY CLUSTERED 
(
	[InvoiceNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbInvoice_AccountCode] ON [dbo].[tbInvoice] 
(
	[AccountCode] ASC,
	[InvoicedOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbInvoice_Status] ON [dbo].[tbInvoice] 
(
	[InvoiceStatusCode] ASC,
	[InvoicedOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbInvoice_UserId] ON [dbo].[tbInvoice] 
(
	[UserId] ASC,
	[InvoiceNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbOrgContact]    Script Date: 01/11/2012 13:36:08 ******/
GO
CREATE TABLE [dbo].[tbOrgContact](
	[AccountCode] [nvarchar](10) NOT NULL,
	[ContactName] [nvarchar](100) NOT NULL,
	[FileAs] [nvarchar](100) NULL,
	[OnMailingList] [bit] NOT NULL CONSTRAINT [DF_tbOrgContact_OnMailingList]  DEFAULT ((1)),
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
	[Information] [ntext] NULL,
	[Photo] [image] NULL,
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbOrgContact_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbOrgContact_InsertedOn]  DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbOrgContact_UpdatedBy]  DEFAULT (suser_sname()),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbOrgContact_UpdatedOn]  DEFAULT (getdate()),
	[HomeNumber] [nvarchar](50) NULL,
 CONSTRAINT [aaaaatbOrgContact_PK] PRIMARY KEY NONCLUSTERED 
(
	[AccountCode] ASC,
	[ContactName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbOrgContactDepartment] ON [dbo].[tbOrgContact] 
(
	[Department] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbOrgContactJobTitle] ON [dbo].[tbOrgContact] 
(
	[JobTitle] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbOrgContactNameTitle] ON [dbo].[tbOrgContact] 
(
	[NameTitle] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tbOrgtbOrgContact] ON [dbo].[tbOrgContact] 
(
	[AccountCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbOrgAddress]    Script Date: 01/11/2012 13:36:04 ******/
GO
CREATE TABLE [dbo].[tbOrgAddress](
	[AddressCode] [nvarchar](15) NOT NULL,
	[AccountCode] [nvarchar](10) NOT NULL,
	[Address] [ntext] NOT NULL,
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbOrgAddress_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbOrgAddress_InsertedOn]  DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbOrgAddress_UpdatedBy]  DEFAULT (suser_sname()),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbOrgAddress_UpdatedOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_tbOrgAddress] PRIMARY KEY CLUSTERED 
(
	[AddressCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tbOrgAddress] ON [dbo].[tbOrgAddress] 
(
	[AccountCode] ASC,
	[AddressCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbOrgDoc]    Script Date: 01/11/2012 13:36:09 ******/
GO
CREATE TABLE [dbo].[tbOrgDoc](
	[AccountCode] [nvarchar](10) NOT NULL,
	[DocumentName] [nvarchar](255) NOT NULL,
	[DocumentDescription] [ntext] NULL,
	[DocumentImage] [image] NULL,
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbOrgDoc_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbOrgDoc_InsertedOn]  DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbOrgDoc_UpdatedBy]  DEFAULT (suser_sname()),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbOrgDoc_UpdatedOn]  DEFAULT (getdate()),
 CONSTRAINT [aaaaatbOrgDoc_PK] PRIMARY KEY NONCLUSTERED 
(
	[AccountCode] ASC,
	[DocumentName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [DocumentName] ON [dbo].[tbOrgDoc] 
(
	[DocumentName] ASC,
	[AccountCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tbOrgtbOrgDoc] ON [dbo].[tbOrgDoc] 
(
	[AccountCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbOrgSector]    Script Date: 01/11/2012 13:36:14 ******/
GO
CREATE TABLE [dbo].[tbOrgSector](
	[AccountCode] [nvarchar](10) NOT NULL,
	[IndustrySector] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tbOrgSector] PRIMARY KEY CLUSTERED 
(
	[AccountCode] ASC,
	[IndustrySector] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbOrgSector_IndustrySector] ON [dbo].[tbOrgSector] 
(
	[IndustrySector] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbSystemOptions]    Script Date: 01/11/2012 13:36:36 ******/
GO
CREATE TABLE [dbo].[tbSystemOptions](
	[Identifier] [nvarchar](4) NOT NULL,
	[Initialised] [bit] NOT NULL CONSTRAINT [DF_tbSystemRoot_Initialised]  DEFAULT ((0)),
	[SQLDataVersion] [real] NOT NULL CONSTRAINT [DF_tbSystemRoot_SQLDataVersion]  DEFAULT ((1)),
	[AccountCode] [nvarchar](10) NOT NULL,
	[DefaultPrintMode] [smallint] NOT NULL CONSTRAINT [DF_tbSystemRoot_DefaultPrintMode]  DEFAULT ((2)),
	[BucketTypeCode] [smallint] NOT NULL CONSTRAINT [DF_tbSystemOptions_BucketTypeCode]  DEFAULT ((1)),
	[BucketIntervalCode] [smallint] NOT NULL CONSTRAINT [DF_tbSystemOptions_BucketIntervalCode]  DEFAULT ((1)),
	[ShowCashGraphs] [bit] NOT NULL CONSTRAINT [DF_tbSystemOptions_ShowCashGraphs]  DEFAULT ((1)),
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbSystemOptions_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbSystemOptions_InsertedOn]  DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbSystemOptions_UpdatedBy]  DEFAULT (suser_sname()),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbSystemOptions_UpdatedOn]  DEFAULT (getdate()),
	[NetProfitCode] [nvarchar](10) NULL,
	[NetProfitTaxCode] [nvarchar](50) NULL,
	[ScheduleOps] [bit] NOT NULL CONSTRAINT [DF_tbSystemOptions_ScheduleOps]  DEFAULT ((1)),
	[TaxHorizon] [smallint] NOT NULL CONSTRAINT [DF_tbSystemOptions_TaxHorizon]  DEFAULT ((90)),
 CONSTRAINT [PK_tbSystemRoot] PRIMARY KEY CLUSTERED 
(
	[Identifier] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbOrg]    Script Date: 01/11/2012 13:36:00 ******/
GO
CREATE TABLE [dbo].[tbOrg](
	[AccountCode] [nvarchar](10) NOT NULL,
	[AccountName] [nvarchar](255) NOT NULL,
	[OrganisationTypeCode] [smallint] NOT NULL CONSTRAINT [DF__tbOrg__Organisat__7C8480AE]  DEFAULT ((1)),
	[OrganisationStatusCode] [smallint] NOT NULL CONSTRAINT [DF__tbOrg__Organisat__7D78A4E7]  DEFAULT ((1)),
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
	[NumberOfEmployees] [int] NOT NULL CONSTRAINT [DF_tbOrg_NumberOfEmployees]  DEFAULT ((0)),
	[CompanyNumber] [nvarchar](20) NULL,
	[VatNumber] [nvarchar](50) NULL,
	[Turnover] [money] NOT NULL CONSTRAINT [DF_tbOrg_Turnover]  DEFAULT ((0)),
	[StatementDays] [smallint] NOT NULL CONSTRAINT [DF_tbOrg_StatementDays]  DEFAULT ((90)),
	[OpeningBalance] [money] NOT NULL CONSTRAINT [DF_tbOrg_OpeningBalance]  DEFAULT ((0)),
	[CurrentBalance] [money] NOT NULL CONSTRAINT [DF_tbOrg_CurrentBalance]  DEFAULT ((0)),
	[ForeignJurisdiction] [bit] NOT NULL CONSTRAINT [DF_tbOrg_ForeignJurisdiction]  DEFAULT ((0)),
	[BusinessDescription] [ntext] NULL,
	[Logo] [image] NULL,
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbOrg_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbOrg_InsertedOn]  DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbOrg_UpdatedBy]  DEFAULT (suser_sname()),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbOrg_UpdatedOn]  DEFAULT (getdate()),
	[PaymentDays] [smallint] NOT NULL CONSTRAINT [DF_tbOrg_PaymentDays]  DEFAULT ((0)),
	[PayDaysFromMonthEnd] [bit] NOT NULL CONSTRAINT [DF_tbOrg_PayDaysFromMonthEnd]  DEFAULT ((0)),
 CONSTRAINT [aaaaatbOrg_PK] PRIMARY KEY NONCLUSTERED 
(
	[AccountCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tbOrg_AccountName] ON [dbo].[tbOrg] 
(
	[AccountName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbOrg_AccountSource] ON [dbo].[tbOrg] 
(
	[AccountSource] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbOrg_AreaCode] ON [dbo].[tbOrg] 
(
	[AreaCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbOrg_IndustrySector] ON [dbo].[tbOrg] 
(
	[IndustrySector] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbOrg_OrganisationStatusCode] ON [dbo].[tbOrg] 
(
	[OrganisationStatusCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tbOrg_OrganisationStatusCodeAccountCode] ON [dbo].[tbOrg] 
(
	[OrganisationStatusCode] ASC,
	[AccountName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbOrg_OrganisationTypeCode] ON [dbo].[tbOrg] 
(
	[OrganisationTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbOrg_PaymentTerms] ON [dbo].[tbOrg] 
(
	[PaymentTerms] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbTaskQuote]    Script Date: 01/11/2012 13:36:59 ******/
GO
CREATE TABLE [dbo].[tbTaskQuote](
	[TaskCode] [nvarchar](20) NOT NULL,
	[Quantity] [float] NOT NULL CONSTRAINT [DF_tbTaskQuote_Quantity]  DEFAULT ((0)),
	[TotalPrice] [money] NOT NULL CONSTRAINT [DF_tbTaskQuote_TotalPrice]  DEFAULT ((0)),
	[RunOnQuantity] [float] NOT NULL CONSTRAINT [DF_tbTaskQuote_RunOnQuantity]  DEFAULT ((0)),
	[RunOnPrice] [money] NOT NULL CONSTRAINT [DF_tbTaskQuote_RunOnPrice]  DEFAULT ((0)),
	[RunBackQuantity] [float] NOT NULL CONSTRAINT [DF_tbTaskQuote_RunBackQuantity]  DEFAULT ((0)),
	[RunBackPrice] [float] NOT NULL CONSTRAINT [DF_tbTaskQuote_RunBackPrice]  DEFAULT ((0)),
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbTaskQuote_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbTaskQuote_InsertedOn]  DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbTaskQuote_UpdatedBy]  DEFAULT (suser_sname()),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbTaskQuote_UpdatedOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_tbTaskQuote] PRIMARY KEY CLUSTERED 
(
	[TaskCode] ASC,
	[Quantity] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbTaskAttribute]    Script Date: 01/11/2012 13:36:50 ******/
GO
CREATE TABLE [dbo].[tbTaskAttribute](
	[TaskCode] [nvarchar](20) NOT NULL,
	[Attribute] [nvarchar](50) NOT NULL,
	[PrintOrder] [smallint] NOT NULL CONSTRAINT [DF_tbTaskAttribute_OrderBy]  DEFAULT ((10)),
	[AttributeTypeCode] [smallint] NOT NULL CONSTRAINT [DF_tbTaskAttribute_AttributeTypeCode]  DEFAULT ((1)),
	[AttributeDescription] [nvarchar](400) NULL,
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbJobAttribute_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbJobAttribute_InsertedOn]  DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbJobAttribute_UpdatedBy]  DEFAULT (suser_sname()),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbJobAttribute_UpdatedOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_tbTaskAttrib_1] PRIMARY KEY CLUSTERED 
(
	[TaskCode] ASC,
	[Attribute] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbTaskAttribute] ON [dbo].[tbTaskAttribute] 
(
	[TaskCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbTaskAttribute_Description] ON [dbo].[tbTaskAttribute] 
(
	[Attribute] ASC,
	[AttributeDescription] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbTaskAttribute_OrderBy] ON [dbo].[tbTaskAttribute] 
(
	[TaskCode] ASC,
	[PrintOrder] ASC,
	[Attribute] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbTaskAttribute_Type_OrderBy] ON [dbo].[tbTaskAttribute] 
(
	[TaskCode] ASC,
	[AttributeTypeCode] ASC,
	[PrintOrder] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbTaskDoc]    Script Date: 01/11/2012 13:36:52 ******/
GO
CREATE TABLE [dbo].[tbTaskDoc](
	[TaskCode] [nvarchar](20) NOT NULL,
	[DocumentName] [nvarchar](255) NOT NULL,
	[DocumentDescription] [ntext] NULL,
	[DocumentImage] [image] NOT NULL,
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbActivityDoc_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbActivityDoc_InsertedOn]  DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbActivityDoc_UpdatedBy]  DEFAULT (suser_sname()),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbActivityDoc_UpdatedOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_tbTaskDoc] PRIMARY KEY CLUSTERED 
(
	[TaskCode] ASC,
	[DocumentName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbTaskFlow]    Script Date: 01/11/2012 13:36:54 ******/
GO
CREATE TABLE [dbo].[tbTaskFlow](
	[ParentTaskCode] [nvarchar](20) NOT NULL,
	[StepNumber] [smallint] NOT NULL CONSTRAINT [DF_tbTaskFlow_StepNumber]  DEFAULT ((10)),
	[ChildTaskCode] [nvarchar](20) NULL,
	[UsedOnQuantity] [float] NOT NULL CONSTRAINT [DF_tbTaskFlow_UsedOnQuantity]  DEFAULT ((1)),
	[OffsetDays] [real] NOT NULL CONSTRAINT [DF_tbTaskFlow_OffsetDays]  DEFAULT ((0)),
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbTaskFlow_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbTaskFlow_InsertedOn]  DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbTaskFlow_UpdatedBy]  DEFAULT (suser_sname()),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbTaskFlow_UpdatedOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_tbTaskFlow] PRIMARY KEY CLUSTERED 
(
	[ParentTaskCode] ASC,
	[StepNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tbTaskFlow_ChildParent] ON [dbo].[tbTaskFlow] 
(
	[ChildTaskCode] ASC,
	[ParentTaskCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tbTaskFlow_ParentChild] ON [dbo].[tbTaskFlow] 
(
	[ParentTaskCode] ASC,
	[ChildTaskCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbTaskOp]    Script Date: 01/11/2012 13:36:56 ******/
GO
CREATE TABLE [dbo].[tbTaskOp](
	[TaskCode] [nvarchar](20) NOT NULL,
	[OperationNumber] [smallint] NOT NULL CONSTRAINT [DF_tbTaskOp_OperationNumber]  DEFAULT ((0)),
	[UserId] [nvarchar](10) NOT NULL,
	[OpTypeCode] [smallint] NOT NULL CONSTRAINT [DF_tbTaskOp_OpTypeCode]  DEFAULT ((1)),
	[OpStatusCode] [smallint] NOT NULL CONSTRAINT [DF_tbTaskOp_OpStatusCode]  DEFAULT ((1)),
	[Operation] [nvarchar](50) NOT NULL,
	[Note] [ntext] NULL,
	[StartOn] [datetime] NOT NULL CONSTRAINT [DF_tbTaskOp_StartOn]  DEFAULT (getdate()),
	[EndOn] [datetime] NOT NULL CONSTRAINT [DF_tbTaskOp_EndOn]  DEFAULT (getdate()),
	[Duration] [float] NOT NULL CONSTRAINT [DF_tbTaskOp_Duration]  DEFAULT ((0)),
	[OffsetDays] [smallint] NOT NULL CONSTRAINT [DF_tbTaskOp_OffsetDays]  DEFAULT ((0)),
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbTaskOp_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbTaskOp_InsertedOn]  DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbTaskOp_UpdatedBy]  DEFAULT (suser_sname()),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbTaskOp_UpdatedOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_tbTaskOp] PRIMARY KEY CLUSTERED 
(
	[TaskCode] ASC,
	[OperationNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbTaskOp_OpStatusCode] ON [dbo].[tbTaskOp] 
(
	[OpStatusCode] ASC,
	[StartOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbTaskOp_UserIdOpStatus] ON [dbo].[tbTaskOp] 
(
	[UserId] ASC,
	[OpStatusCode] ASC,
	[StartOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbProfileObjectDetail]    Script Date: 01/11/2012 13:36:25 ******/
GO
CREATE TABLE [dbo].[tbProfileObjectDetail](
	[ObjectTypeCode] [smallint] NOT NULL CONSTRAINT [DF_tbProfileObjectDetail_ObjectTypeCode]  DEFAULT ((2)),
	[ObjectName] [nvarchar](50) NOT NULL,
	[ItemName] [nvarchar](100) NOT NULL,
	[ItemTypeCode] [smallint] NULL CONSTRAINT [DF_tbProfileObjectDetail_ItemTypeCode]  DEFAULT ((100)),
	[Caption] [ntext] NULL,
	[StatusBarText] [ntext] NULL,
	[ControlTipText] [ntext] NULL,
	[CharLength] [int] NOT NULL CONSTRAINT [DF_tbProfileObjectDetail_ItemWidth]  DEFAULT ((0)),
	[Visible] [bit] NOT NULL CONSTRAINT [DF_tbProfileObjectDetail_Visible]  DEFAULT ((1)),
	[FormatString] [nvarchar](20) NULL,
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbProfileObjectDetail_UpdatedOn]  DEFAULT (getdate()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbProfileObjectDetail_InsertedOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_tbProfileObjectDetail] PRIMARY KEY CLUSTERED 
(
	[ObjectTypeCode] ASC,
	[ObjectName] ASC,
	[ItemName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [RDX_tbProfileObjectDetail_ItemTypeCode] ON [dbo].[tbProfileObjectDetail] 
(
	[ItemTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbProfileMenuEntry]    Script Date: 01/11/2012 13:36:21 ******/
GO
CREATE TABLE [dbo].[tbProfileMenuEntry](
	[MenuId] [smallint] NOT NULL CONSTRAINT [DF_tbProfileMenuEntry_MenuId]  DEFAULT ((0)),
	[EntryId] [int] IDENTITY(1,1) NOT NULL,
	[FolderId] [smallint] NOT NULL CONSTRAINT [DF_tbProfileMenuEntry_FolderId]  DEFAULT ((0)),
	[ItemId] [smallint] NOT NULL CONSTRAINT [DF_tbProfileMenuEntry_ItemId]  DEFAULT ((0)),
	[ItemText] [nvarchar](255) NULL,
	[Command] [smallint] NULL CONSTRAINT [DF_tbProfileMenuEntry_Command]  DEFAULT ((0)),
	[ProjectName] [nvarchar](50) NULL,
	[Argument] [nvarchar](50) NULL,
	[OpenMode] [smallint] NULL CONSTRAINT [DF_tbProfileMenuEntry_OpenMode]  DEFAULT ((1)),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbProfileMenuEntry_UpdatedOn]  DEFAULT (getdate()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbProfileMenuEntry_InsertedOn]  DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbProfileMenuEntry_UpdatedBy]  DEFAULT (suser_sname()),
 CONSTRAINT [PK_tbProfileMenuEntry] PRIMARY KEY CLUSTERED 
(
	[MenuId] ASC,
	[EntryId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY],
 CONSTRAINT [IX_tbProfileMenuEntry_MenuFolderItem] UNIQUE NONCLUSTERED 
(
	[MenuId] ASC,
	[FolderId] ASC,
	[ItemId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [RDX_tbProfileMenuEntry_Command] ON [dbo].[tbProfileMenuEntry] 
(
	[Command] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [RDX_tbProfileMenuEntry_OpenMode] ON [dbo].[tbProfileMenuEntry] 
(
	[OpenMode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbUserMenu]    Script Date: 01/11/2012 13:37:03 ******/
GO
CREATE TABLE [dbo].[tbUserMenu](
	[UserId] [nvarchar](10) NOT NULL,
	[MenuId] [smallint] NOT NULL,
 CONSTRAINT [PK_tbUserMenu] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[MenuId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbSystemDoc]    Script Date: 01/11/2012 13:36:31 ******/
GO
CREATE TABLE [dbo].[tbSystemDoc](
	[DocTypeCode] [smallint] NOT NULL,
	[ReportName] [nvarchar](50) NOT NULL,
	[OpenMode] [smallint] NOT NULL CONSTRAINT [DF_tbSystemDoc_OpenMode]  DEFAULT ((1)),
	[Description] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tbSystemDoc] PRIMARY KEY CLUSTERED 
(
	[DocTypeCode] ASC,
	[ReportName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbProfileObject]    Script Date: 01/11/2012 13:36:23 ******/
GO
CREATE TABLE [dbo].[tbProfileObject](
	[ObjectTypeCode] [smallint] NOT NULL CONSTRAINT [DF_tbProfileObject_ObjectTypeCode]  DEFAULT ((2)),
	[ObjectName] [nvarchar](50) NOT NULL,
	[ProjectName] [nvarchar](50) NULL,
	[Caption] [ntext] NULL,
	[SubObject] [bit] NOT NULL CONSTRAINT [DF_tbProfileObject_SubObject]  DEFAULT ((0)),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbProfileObject_UpdatedOn]  DEFAULT (getdate()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbProfileObject_InsertedOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_tbProfileObject] PRIMARY KEY CLUSTERED 
(
	[ObjectTypeCode] ASC,
	[ObjectName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [RDX_tbProfileObject_ObjectTypeCode] ON [dbo].[tbProfileObject] 
(
	[ObjectTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbUser]    Script Date: 01/11/2012 13:37:03 ******/
GO
CREATE TABLE [dbo].[tbUser](
	[UserId] [nvarchar](10) NOT NULL,
	[UserName] [nvarchar](50) NOT NULL,
	[LogonName] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbUser_LogonName]  DEFAULT (suser_sname()),
	[CalendarCode] [nvarchar](10) NULL,
	[PhoneNumber] [nvarchar](50) NULL,
	[MobileNumber] [nvarchar](50) NULL,
	[FaxNumber] [nvarchar](50) NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[Address] [ntext] NULL,
	[Administrator] [bit] NOT NULL CONSTRAINT [DF_tbUser_Administrator]  DEFAULT ((0)),
	[Avatar] [image] NULL,
	[Signature] [image] NULL,
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbUser_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbUser_InsertedOn]  DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbUser_UpdatedBy]  DEFAULT (suser_sname()),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbUser_UpdatedOn]  DEFAULT (getdate()),
	[NextTaskNumber] [int] NOT NULL CONSTRAINT [DF_tbUser_NextTaskNumber]  DEFAULT ((1)),
 CONSTRAINT [PK_tbUser] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tbUser] ON [dbo].[tbUser] 
(
	[LogonName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UserName] ON [dbo].[tbUser] 
(
	[UserName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbSystemCalendarHoliday]    Script Date: 01/11/2012 13:36:30 ******/
GO
CREATE TABLE [dbo].[tbSystemCalendarHoliday](
	[CalendarCode] [nvarchar](10) NOT NULL,
	[UnavailableOn] [datetime] NOT NULL,
 CONSTRAINT [PK_tbSystemCalendarHoliday] PRIMARY KEY CLUSTERED 
(
	[CalendarCode] ASC,
	[UnavailableOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [RDX_tbSystemCalendarHoliday_CalendarCode] ON [dbo].[tbSystemCalendarHoliday] 
(
	[CalendarCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbSystemYear]    Script Date: 01/11/2012 13:36:40 ******/
GO
CREATE TABLE [dbo].[tbSystemYear](
	[YearNumber] [smallint] NOT NULL,
	[StartMonth] [smallint] NOT NULL CONSTRAINT [DF_tbSystemYear_StartMonth]  DEFAULT ((1)),
	[CashStatusCode] [smallint] NOT NULL CONSTRAINT [DF_tbSystemYear_CashStatusCode]  DEFAULT ((1)),
	[Description] [nvarchar](10) NOT NULL,
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbSystemYear_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbSystemYear_InsertedOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_tbSystemYear] PRIMARY KEY CLUSTERED 
(
	[YearNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbCashCode]    Script Date: 01/11/2012 13:35:42 ******/
GO
CREATE TABLE [dbo].[tbCashCode](
	[CashCode] [nvarchar](50) NOT NULL,
	[CashDescription] [nvarchar](100) NOT NULL,
	[CategoryCode] [nvarchar](10) NOT NULL,
	[TaxCode] [nvarchar](10) NOT NULL,
	[OpeningBalance] [money] NOT NULL CONSTRAINT [DF_tbCashCode_OpeningBalance]  DEFAULT ((0)),
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbCashCode_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbCashCode_InsertedOn]  DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbCashCode_UpdatedBy]  DEFAULT (suser_sname()),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbCashCode_UpdatedOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_tbCashCode] PRIMARY KEY CLUSTERED 
(
	[CashCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY],
 CONSTRAINT [IX_tbCashCodeDescription] UNIQUE NONCLUSTERED 
(
	[CashDescription] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbActivityOp]    Script Date: 01/11/2012 13:35:35 ******/
GO
CREATE TABLE [dbo].[tbActivityOp](
	[ActivityCode] [nvarchar](50) NOT NULL,
	[OperationNumber] [smallint] NOT NULL CONSTRAINT [DF_tbActivityOp_OperationNumber]  DEFAULT ((0)),
	[OpTypeCode] [smallint] NOT NULL CONSTRAINT [DF_tbActivityOp_OpTypeCode]  DEFAULT ((1)),
	[Operation] [nvarchar](50) NOT NULL,
	[Duration] [float] NOT NULL CONSTRAINT [DF_tbActivityOp_Duration]  DEFAULT ((0)),
	[OffsetDays] [smallint] NOT NULL CONSTRAINT [DF_tbActivityOp_OffsetDays]  DEFAULT ((0)),
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbActivityOp_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbActivityOp_InsertedOn]  DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbActivityOp_UpdatedBy]  DEFAULT (suser_sname()),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbActivityOp_UpdatedOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_tbActivityOp] PRIMARY KEY CLUSTERED 
(
	[ActivityCode] ASC,
	[OperationNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbActivityOp_Operation] ON [dbo].[tbActivityOp] 
(
	[Operation] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbActivityAttribute]    Script Date: 01/11/2012 13:35:31 ******/
GO
CREATE TABLE [dbo].[tbActivityAttribute](
	[ActivityCode] [nvarchar](50) NOT NULL,
	[Attribute] [nvarchar](50) NOT NULL,
	[PrintOrder] [smallint] NOT NULL CONSTRAINT [DF_tbActivityAttribute_OrderBy]  DEFAULT ((10)),
	[AttributeTypeCode] [smallint] NOT NULL CONSTRAINT [DF_tbActivityAttribute_AttributeTypeCode]  DEFAULT ((1)),
	[DefaultText] [nvarchar](400) NULL,
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbTemplateAttribute_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbTemplateAttribute_InsertedOn]  DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbTemplateAttribute_UpdatedBy]  DEFAULT (suser_sname()),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbTemplateAttribute_UpdatedOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_tbActivityCodeAttrib] PRIMARY KEY CLUSTERED 
(
	[ActivityCode] ASC,
	[Attribute] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbActivityAttribute] ON [dbo].[tbActivityAttribute] 
(
	[Attribute] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbActivityAttribute_DefaultText] ON [dbo].[tbActivityAttribute] 
(
	[DefaultText] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbActivityAttribute_OrderBy] ON [dbo].[tbActivityAttribute] 
(
	[ActivityCode] ASC,
	[PrintOrder] ASC,
	[Attribute] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbActivityAttribute_Type_OrderBy] ON [dbo].[tbActivityAttribute] 
(
	[ActivityCode] ASC,
	[AttributeTypeCode] ASC,
	[PrintOrder] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbActivityFlow]    Script Date: 01/11/2012 13:35:33 ******/
GO
CREATE TABLE [dbo].[tbActivityFlow](
	[ParentCode] [nvarchar](50) NOT NULL,
	[StepNumber] [smallint] NOT NULL CONSTRAINT [DF__tbTemplat__JobOr__48CFD27E]  DEFAULT ((10)),
	[ChildCode] [nvarchar](50) NOT NULL,
	[OffsetDays] [smallint] NOT NULL CONSTRAINT [DF__tbTemplat__Offse__49C3F6B7]  DEFAULT ((0)),
	[UsedOnQuantity] [float] NOT NULL CONSTRAINT [DF_tbActivityCodeFlow_Quantity]  DEFAULT ((0)),
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbTemplateActivity_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbTemplateActivity_InsertedOn]  DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbTemplateActivity_UpdatedBy]  DEFAULT (suser_sname()),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbTemplateActivity_UpdatedOn]  DEFAULT (getdate()),
 CONSTRAINT [aaaaatbActivityCodeFlow_PK] PRIMARY KEY NONCLUSTERED 
(
	[ParentCode] ASC,
	[StepNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ChildCodeParentCode] ON [dbo].[tbActivityFlow] 
(
	[ChildCode] ASC,
	[ParentCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ParentCodeChildCode] ON [dbo].[tbActivityFlow] 
(
	[ParentCode] ASC,
	[ChildCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbCashCategoryExp]    Script Date: 01/11/2012 13:35:39 ******/
GO
CREATE TABLE [dbo].[tbCashCategoryExp](
	[CategoryCode] [nvarchar](10) NOT NULL,
	[Expression] [nvarchar](256) NOT NULL,
	[Format] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_tbCashCategoryExp] PRIMARY KEY CLUSTERED 
(
	[CategoryCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbCashCategoryTotal]    Script Date: 01/11/2012 13:35:39 ******/
GO
CREATE TABLE [dbo].[tbCashCategoryTotal](
	[ParentCode] [nvarchar](10) NOT NULL,
	[ChildCode] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_tbCashCategoryTotal] PRIMARY KEY CLUSTERED 
(
	[ParentCode] ASC,
	[ChildCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  ForeignKey [FK_tbActivity_tbSystemRegister]    Script Date: 01/11/2012 13:35:28 ******/
ALTER TABLE [dbo].[tbActivity]  WITH CHECK ADD  CONSTRAINT [FK_tbActivity_tbSystemRegister] FOREIGN KEY([RegisterName])
REFERENCES [dbo].[tbSystemRegister] ([RegisterName])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbActivity] CHECK CONSTRAINT [FK_tbActivity_tbSystemRegister]
GO
/****** Object:  ForeignKey [FK_tbActivityCode_tbCashCode]    Script Date: 01/11/2012 13:35:29 ******/
ALTER TABLE [dbo].[tbActivity]  WITH CHECK ADD  CONSTRAINT [FK_tbActivityCode_tbCashCode] FOREIGN KEY([CashCode])
REFERENCES [dbo].[tbCashCode] ([CashCode])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbActivity] CHECK CONSTRAINT [FK_tbActivityCode_tbCashCode]
GO
/****** Object:  ForeignKey [FK_tbActivityCode_tbSystemUom]    Script Date: 01/11/2012 13:35:29 ******/
ALTER TABLE [dbo].[tbActivity]  WITH CHECK ADD  CONSTRAINT [FK_tbActivityCode_tbSystemUom] FOREIGN KEY([UnitOfMeasure])
REFERENCES [dbo].[tbSystemUom] ([UnitOfMeasure])
GO
ALTER TABLE [dbo].[tbActivity] CHECK CONSTRAINT [FK_tbActivityCode_tbSystemUom]
GO
/****** Object:  ForeignKey [FK_tbActivityAttribute_tbActivity]    Script Date: 01/11/2012 13:35:31 ******/
ALTER TABLE [dbo].[tbActivityAttribute]  WITH CHECK ADD  CONSTRAINT [FK_tbActivityAttribute_tbActivity] FOREIGN KEY([ActivityCode])
REFERENCES [dbo].[tbActivity] ([ActivityCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbActivityAttribute] CHECK CONSTRAINT [FK_tbActivityAttribute_tbActivity]
GO
/****** Object:  ForeignKey [FK_tbActivityAttribute_tbActivityAttributeType]    Script Date: 01/11/2012 13:35:31 ******/
ALTER TABLE [dbo].[tbActivityAttribute]  WITH CHECK ADD  CONSTRAINT [FK_tbActivityAttribute_tbActivityAttributeType] FOREIGN KEY([AttributeTypeCode])
REFERENCES [dbo].[tbActivityAttributeType] ([AttributeTypeCode])
GO
ALTER TABLE [dbo].[tbActivityAttribute] CHECK CONSTRAINT [FK_tbActivityAttribute_tbActivityAttributeType]
GO
/****** Object:  ForeignKey [FK_tbActivityFlow_tbActivity]    Script Date: 01/11/2012 13:35:33 ******/
ALTER TABLE [dbo].[tbActivityFlow]  WITH CHECK ADD  CONSTRAINT [FK_tbActivityFlow_tbActivity] FOREIGN KEY([ParentCode])
REFERENCES [dbo].[tbActivity] ([ActivityCode])
GO
ALTER TABLE [dbo].[tbActivityFlow] CHECK CONSTRAINT [FK_tbActivityFlow_tbActivity]
GO
/****** Object:  ForeignKey [FK_tbActivityFlow_tbActivity1]    Script Date: 01/11/2012 13:35:33 ******/
ALTER TABLE [dbo].[tbActivityFlow]  WITH CHECK ADD  CONSTRAINT [FK_tbActivityFlow_tbActivity1] FOREIGN KEY([ChildCode])
REFERENCES [dbo].[tbActivity] ([ActivityCode])
GO
ALTER TABLE [dbo].[tbActivityFlow] CHECK CONSTRAINT [FK_tbActivityFlow_tbActivity1]
GO
/****** Object:  ForeignKey [FK_tbActivityOp_tbActivity]    Script Date: 01/11/2012 13:35:35 ******/
ALTER TABLE [dbo].[tbActivityOp]  WITH CHECK ADD  CONSTRAINT [FK_tbActivityOp_tbActivity] FOREIGN KEY([ActivityCode])
REFERENCES [dbo].[tbActivity] ([ActivityCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbActivityOp] CHECK CONSTRAINT [FK_tbActivityOp_tbActivity]
GO
/****** Object:  ForeignKey [FK_tbActivityOp_tbActivityOpType]    Script Date: 01/11/2012 13:35:35 ******/
ALTER TABLE [dbo].[tbActivityOp]  WITH CHECK ADD  CONSTRAINT [FK_tbActivityOp_tbActivityOpType] FOREIGN KEY([OpTypeCode])
REFERENCES [dbo].[tbActivityOpType] ([OpTypeCode])
GO
ALTER TABLE [dbo].[tbActivityOp] CHECK CONSTRAINT [FK_tbActivityOp_tbActivityOpType]
GO
/****** Object:  ForeignKey [FK_tbCashCategory_tbCashCategoryType]    Script Date: 01/11/2012 13:35:38 ******/
ALTER TABLE [dbo].[tbCashCategory]  WITH CHECK ADD  CONSTRAINT [FK_tbCashCategory_tbCashCategoryType] FOREIGN KEY([CategoryTypeCode])
REFERENCES [dbo].[tbCashCategoryType] ([CategoryTypeCode])
GO
ALTER TABLE [dbo].[tbCashCategory] CHECK CONSTRAINT [FK_tbCashCategory_tbCashCategoryType]
GO
/****** Object:  ForeignKey [FK_tbCashCategory_tbCashMode]    Script Date: 01/11/2012 13:35:38 ******/
ALTER TABLE [dbo].[tbCashCategory]  WITH CHECK ADD  CONSTRAINT [FK_tbCashCategory_tbCashMode] FOREIGN KEY([CashModeCode])
REFERENCES [dbo].[tbCashMode] ([CashModeCode])
GO
ALTER TABLE [dbo].[tbCashCategory] CHECK CONSTRAINT [FK_tbCashCategory_tbCashMode]
GO
/****** Object:  ForeignKey [FK_tbCashCategory_tbCashType]    Script Date: 01/11/2012 13:35:38 ******/
ALTER TABLE [dbo].[tbCashCategory]  WITH CHECK ADD  CONSTRAINT [FK_tbCashCategory_tbCashType] FOREIGN KEY([CashTypeCode])
REFERENCES [dbo].[tbCashType] ([CashTypeCode])
GO
ALTER TABLE [dbo].[tbCashCategory] CHECK CONSTRAINT [FK_tbCashCategory_tbCashType]
GO
/****** Object:  ForeignKey [FK_tbCashCategoryExp_tbCashCategory]    Script Date: 01/11/2012 13:35:39 ******/
ALTER TABLE [dbo].[tbCashCategoryExp]  WITH CHECK ADD  CONSTRAINT [FK_tbCashCategoryExp_tbCashCategory] FOREIGN KEY([CategoryCode])
REFERENCES [dbo].[tbCashCategory] ([CategoryCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbCashCategoryExp] CHECK CONSTRAINT [FK_tbCashCategoryExp_tbCashCategory]
GO
/****** Object:  ForeignKey [FK_tbCashCategoryTotal_tbCashCategory1]    Script Date: 01/11/2012 13:35:39 ******/
ALTER TABLE [dbo].[tbCashCategoryTotal]  WITH CHECK ADD  CONSTRAINT [FK_tbCashCategoryTotal_tbCashCategory1] FOREIGN KEY([ParentCode])
REFERENCES [dbo].[tbCashCategory] ([CategoryCode])
GO
ALTER TABLE [dbo].[tbCashCategoryTotal] CHECK CONSTRAINT [FK_tbCashCategoryTotal_tbCashCategory1]
GO
/****** Object:  ForeignKey [FK_tbCashCategoryTotal_tbCashCategory2]    Script Date: 01/11/2012 13:35:39 ******/
ALTER TABLE [dbo].[tbCashCategoryTotal]  WITH CHECK ADD  CONSTRAINT [FK_tbCashCategoryTotal_tbCashCategory2] FOREIGN KEY([ChildCode])
REFERENCES [dbo].[tbCashCategory] ([CategoryCode])
GO
ALTER TABLE [dbo].[tbCashCategoryTotal] CHECK CONSTRAINT [FK_tbCashCategoryTotal_tbCashCategory2]
GO
/****** Object:  ForeignKey [FK_tbCashCode_tbCashCategory1]    Script Date: 01/11/2012 13:35:42 ******/
ALTER TABLE [dbo].[tbCashCode]  WITH CHECK ADD  CONSTRAINT [FK_tbCashCode_tbCashCategory1] FOREIGN KEY([CategoryCode])
REFERENCES [dbo].[tbCashCategory] ([CategoryCode])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbCashCode] CHECK CONSTRAINT [FK_tbCashCode_tbCashCategory1]
GO
/****** Object:  ForeignKey [FK_tbCashCode_tbSystemTaxCode]    Script Date: 01/11/2012 13:35:42 ******/
ALTER TABLE [dbo].[tbCashCode]  WITH CHECK ADD  CONSTRAINT [FK_tbCashCode_tbSystemTaxCode] FOREIGN KEY([TaxCode])
REFERENCES [dbo].[tbSystemTaxCode] ([TaxCode])
GO
ALTER TABLE [dbo].[tbCashCode] CHECK CONSTRAINT [FK_tbCashCode_tbSystemTaxCode]
GO
/****** Object:  ForeignKey [FK_tbCashPeriod_tbCashCode]    Script Date: 01/11/2012 13:35:44 ******/
ALTER TABLE [dbo].[tbCashPeriod]  WITH CHECK ADD  CONSTRAINT [FK_tbCashPeriod_tbCashCode] FOREIGN KEY([CashCode])
REFERENCES [dbo].[tbCashCode] ([CashCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbCashPeriod] CHECK CONSTRAINT [FK_tbCashPeriod_tbCashCode]
GO
/****** Object:  ForeignKey [FK_tbCashPeriod_tbSystemYearPeriod]    Script Date: 01/11/2012 13:35:44 ******/
ALTER TABLE [dbo].[tbCashPeriod]  WITH CHECK ADD  CONSTRAINT [FK_tbCashPeriod_tbSystemYearPeriod] FOREIGN KEY([StartOn])
REFERENCES [dbo].[tbSystemYearPeriod] ([StartOn])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbCashPeriod] CHECK CONSTRAINT [FK_tbCashPeriod_tbSystemYearPeriod]
GO
/****** Object:  ForeignKey [FK_tbCashTaxType_tbCashCode]    Script Date: 01/11/2012 13:35:46 ******/
ALTER TABLE [dbo].[tbCashTaxType]  WITH CHECK ADD  CONSTRAINT [FK_tbCashTaxType_tbCashCode] FOREIGN KEY([CashCode])
REFERENCES [dbo].[tbCashCode] ([CashCode])
GO
ALTER TABLE [dbo].[tbCashTaxType] CHECK CONSTRAINT [FK_tbCashTaxType_tbCashCode]
GO
/****** Object:  ForeignKey [FK_tbCashTaxType_tbOrg]    Script Date: 01/11/2012 13:35:46 ******/
ALTER TABLE [dbo].[tbCashTaxType]  WITH CHECK ADD  CONSTRAINT [FK_tbCashTaxType_tbOrg] FOREIGN KEY([AccountCode])
REFERENCES [dbo].[tbOrg] ([AccountCode])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbCashTaxType] CHECK CONSTRAINT [FK_tbCashTaxType_tbOrg]
GO
/****** Object:  ForeignKey [FK_tbCashTaxType_tbSystemMonth]    Script Date: 01/11/2012 13:35:46 ******/
ALTER TABLE [dbo].[tbCashTaxType]  WITH CHECK ADD  CONSTRAINT [FK_tbCashTaxType_tbSystemMonth] FOREIGN KEY([MonthNumber])
REFERENCES [dbo].[tbSystemMonth] ([MonthNumber])
GO
ALTER TABLE [dbo].[tbCashTaxType] CHECK CONSTRAINT [FK_tbCashTaxType_tbSystemMonth]
GO
/****** Object:  ForeignKey [FK_tbCashTaxType_tbSystemRecurrence]    Script Date: 01/11/2012 13:35:46 ******/
ALTER TABLE [dbo].[tbCashTaxType]  WITH CHECK ADD  CONSTRAINT [FK_tbCashTaxType_tbSystemRecurrence] FOREIGN KEY([RecurrenceCode])
REFERENCES [dbo].[tbSystemRecurrence] ([RecurrenceCode])
GO
ALTER TABLE [dbo].[tbCashTaxType] CHECK CONSTRAINT [FK_tbCashTaxType_tbSystemRecurrence]
GO
/****** Object:  ForeignKey [FK_tbInvoice_tbInvoiceStatus]    Script Date: 01/11/2012 13:35:49 ******/
ALTER TABLE [dbo].[tbInvoice]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoice_tbInvoiceStatus] FOREIGN KEY([InvoiceStatusCode])
REFERENCES [dbo].[tbInvoiceStatus] ([InvoiceStatusCode])
GO
ALTER TABLE [dbo].[tbInvoice] CHECK CONSTRAINT [FK_tbInvoice_tbInvoiceStatus]
GO
/****** Object:  ForeignKey [FK_tbInvoice_tbInvoiceType]    Script Date: 01/11/2012 13:35:49 ******/
ALTER TABLE [dbo].[tbInvoice]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoice_tbInvoiceType] FOREIGN KEY([InvoiceTypeCode])
REFERENCES [dbo].[tbInvoiceType] ([InvoiceTypeCode])
GO
ALTER TABLE [dbo].[tbInvoice] CHECK CONSTRAINT [FK_tbInvoice_tbInvoiceType]
GO
/****** Object:  ForeignKey [FK_tbInvoice_tbOrg]    Script Date: 01/11/2012 13:35:49 ******/
ALTER TABLE [dbo].[tbInvoice]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoice_tbOrg] FOREIGN KEY([AccountCode])
REFERENCES [dbo].[tbOrg] ([AccountCode])
GO
ALTER TABLE [dbo].[tbInvoice] CHECK CONSTRAINT [FK_tbInvoice_tbOrg]
GO
/****** Object:  ForeignKey [FK_tbInvoice_tbUser1]    Script Date: 01/11/2012 13:35:49 ******/
ALTER TABLE [dbo].[tbInvoice]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoice_tbUser1] FOREIGN KEY([UserId])
REFERENCES [dbo].[tbUser] ([UserId])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbInvoice] CHECK CONSTRAINT [FK_tbInvoice_tbUser1]
GO
/****** Object:  ForeignKey [FK_tbInvoiceItem_tbCashCode]    Script Date: 01/11/2012 13:35:51 ******/
ALTER TABLE [dbo].[tbInvoiceItem]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoiceItem_tbCashCode] FOREIGN KEY([CashCode])
REFERENCES [dbo].[tbCashCode] ([CashCode])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbInvoiceItem] CHECK CONSTRAINT [FK_tbInvoiceItem_tbCashCode]
GO
/****** Object:  ForeignKey [FK_tbInvoiceItem_tbInvoice]    Script Date: 01/11/2012 13:35:51 ******/
ALTER TABLE [dbo].[tbInvoiceItem]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoiceItem_tbInvoice] FOREIGN KEY([InvoiceNumber])
REFERENCES [dbo].[tbInvoice] ([InvoiceNumber])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbInvoiceItem] CHECK CONSTRAINT [FK_tbInvoiceItem_tbInvoice]
GO
/****** Object:  ForeignKey [FK_tbInvoiceItem_tbSystemTaxCode]    Script Date: 01/11/2012 13:35:51 ******/
ALTER TABLE [dbo].[tbInvoiceItem]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoiceItem_tbSystemTaxCode] FOREIGN KEY([TaxCode])
REFERENCES [dbo].[tbSystemTaxCode] ([TaxCode])
GO
ALTER TABLE [dbo].[tbInvoiceItem] CHECK CONSTRAINT [FK_tbInvoiceItem_tbSystemTaxCode]
GO
/****** Object:  ForeignKey [FK_tbInvoiceActivity_tbCashCode]    Script Date: 01/11/2012 13:35:53 ******/
ALTER TABLE [dbo].[tbInvoiceTask]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoiceActivity_tbCashCode] FOREIGN KEY([CashCode])
REFERENCES [dbo].[tbCashCode] ([CashCode])
GO
ALTER TABLE [dbo].[tbInvoiceTask] CHECK CONSTRAINT [FK_tbInvoiceActivity_tbCashCode]
GO
/****** Object:  ForeignKey [FK_tbInvoiceActivity_tbSystemTaxCode]    Script Date: 01/11/2012 13:35:53 ******/
ALTER TABLE [dbo].[tbInvoiceTask]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoiceActivity_tbSystemTaxCode] FOREIGN KEY([TaxCode])
REFERENCES [dbo].[tbSystemTaxCode] ([TaxCode])
GO
ALTER TABLE [dbo].[tbInvoiceTask] CHECK CONSTRAINT [FK_tbInvoiceActivity_tbSystemTaxCode]
GO
/****** Object:  ForeignKey [FK_tbInvoiceTask_tbInvoice]    Script Date: 01/11/2012 13:35:54 ******/
ALTER TABLE [dbo].[tbInvoiceTask]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoiceTask_tbInvoice] FOREIGN KEY([InvoiceNumber])
REFERENCES [dbo].[tbInvoice] ([InvoiceNumber])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbInvoiceTask] CHECK CONSTRAINT [FK_tbInvoiceTask_tbInvoice]
GO
/****** Object:  ForeignKey [FK_tbInvoiceTask_tbTask]    Script Date: 01/11/2012 13:35:54 ******/
ALTER TABLE [dbo].[tbInvoiceTask]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoiceTask_tbTask] FOREIGN KEY([TaskCode])
REFERENCES [dbo].[tbTask] ([TaskCode])
GO
ALTER TABLE [dbo].[tbInvoiceTask] CHECK CONSTRAINT [FK_tbInvoiceTask_tbTask]
GO
/****** Object:  ForeignKey [FK_tbInvoiceTask_tbTask1]    Script Date: 01/11/2012 13:35:54 ******/
ALTER TABLE [dbo].[tbInvoiceTask]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoiceTask_tbTask1] FOREIGN KEY([TaskCode])
REFERENCES [dbo].[tbTask] ([TaskCode])
GO
ALTER TABLE [dbo].[tbInvoiceTask] CHECK CONSTRAINT [FK_tbInvoiceTask_tbTask1]
GO
/****** Object:  ForeignKey [FK_tbInvoiceType_tbCashMode]    Script Date: 01/11/2012 13:35:55 ******/
ALTER TABLE [dbo].[tbInvoiceType]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoiceType_tbCashMode] FOREIGN KEY([CashModeCode])
REFERENCES [dbo].[tbCashMode] ([CashModeCode])
GO
ALTER TABLE [dbo].[tbInvoiceType] CHECK CONSTRAINT [FK_tbInvoiceType_tbCashMode]
GO
/****** Object:  ForeignKey [FK_tbOrg_tbOrgAddress]    Script Date: 01/11/2012 13:36:00 ******/
ALTER TABLE [dbo].[tbOrg]  WITH NOCHECK ADD  CONSTRAINT [FK_tbOrg_tbOrgAddress] FOREIGN KEY([AddressCode])
REFERENCES [dbo].[tbOrgAddress] ([AddressCode])
NOT FOR REPLICATION
GO
ALTER TABLE [dbo].[tbOrg] NOCHECK CONSTRAINT [FK_tbOrg_tbOrgAddress]
GO
/****** Object:  ForeignKey [FK_tbOrg_tbSystemTaxCode]    Script Date: 01/11/2012 13:36:00 ******/
ALTER TABLE [dbo].[tbOrg]  WITH CHECK ADD  CONSTRAINT [FK_tbOrg_tbSystemTaxCode] FOREIGN KEY([TaxCode])
REFERENCES [dbo].[tbSystemTaxCode] ([TaxCode])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbOrg] CHECK CONSTRAINT [FK_tbOrg_tbSystemTaxCode]
GO
/****** Object:  ForeignKey [tbOrg_FK00]    Script Date: 01/11/2012 13:36:00 ******/
ALTER TABLE [dbo].[tbOrg]  WITH CHECK ADD  CONSTRAINT [tbOrg_FK00] FOREIGN KEY([OrganisationStatusCode])
REFERENCES [dbo].[tbOrgStatus] ([OrganisationStatusCode])
GO
ALTER TABLE [dbo].[tbOrg] CHECK CONSTRAINT [tbOrg_FK00]
GO
/****** Object:  ForeignKey [tbOrg_FK01]    Script Date: 01/11/2012 13:36:00 ******/
ALTER TABLE [dbo].[tbOrg]  WITH CHECK ADD  CONSTRAINT [tbOrg_FK01] FOREIGN KEY([OrganisationTypeCode])
REFERENCES [dbo].[tbOrgType] ([OrganisationTypeCode])
GO
ALTER TABLE [dbo].[tbOrg] CHECK CONSTRAINT [tbOrg_FK01]
GO
/****** Object:  ForeignKey [FK_tbOrgAccount_tbCashCode]    Script Date: 01/11/2012 13:36:02 ******/
ALTER TABLE [dbo].[tbOrgAccount]  WITH CHECK ADD  CONSTRAINT [FK_tbOrgAccount_tbCashCode] FOREIGN KEY([CashCode])
REFERENCES [dbo].[tbCashCode] ([CashCode])
GO
ALTER TABLE [dbo].[tbOrgAccount] CHECK CONSTRAINT [FK_tbOrgAccount_tbCashCode]
GO
/****** Object:  ForeignKey [FK_tbOrgAccount_tbOrg]    Script Date: 01/11/2012 13:36:03 ******/
ALTER TABLE [dbo].[tbOrgAccount]  WITH CHECK ADD  CONSTRAINT [FK_tbOrgAccount_tbOrg] FOREIGN KEY([AccountCode])
REFERENCES [dbo].[tbOrg] ([AccountCode])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbOrgAccount] CHECK CONSTRAINT [FK_tbOrgAccount_tbOrg]
GO
/****** Object:  ForeignKey [FK_tbOrgAddress_tbOrg]    Script Date: 01/11/2012 13:36:04 ******/
ALTER TABLE [dbo].[tbOrgAddress]  WITH CHECK ADD  CONSTRAINT [FK_tbOrgAddress_tbOrg] FOREIGN KEY([AccountCode])
REFERENCES [dbo].[tbOrg] ([AccountCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbOrgAddress] CHECK CONSTRAINT [FK_tbOrgAddress_tbOrg]
GO
/****** Object:  ForeignKey [tbOrgContact_FK00]    Script Date: 01/11/2012 13:36:08 ******/
ALTER TABLE [dbo].[tbOrgContact]  WITH CHECK ADD  CONSTRAINT [tbOrgContact_FK00] FOREIGN KEY([AccountCode])
REFERENCES [dbo].[tbOrg] ([AccountCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbOrgContact] CHECK CONSTRAINT [tbOrgContact_FK00]
GO
/****** Object:  ForeignKey [tbOrgDoc_FK00]    Script Date: 01/11/2012 13:36:09 ******/
ALTER TABLE [dbo].[tbOrgDoc]  WITH CHECK ADD  CONSTRAINT [tbOrgDoc_FK00] FOREIGN KEY([AccountCode])
REFERENCES [dbo].[tbOrg] ([AccountCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbOrgDoc] CHECK CONSTRAINT [tbOrgDoc_FK00]
GO
/****** Object:  ForeignKey [FK_tbOrgPayment_tbCashCode]    Script Date: 01/11/2012 13:36:13 ******/
ALTER TABLE [dbo].[tbOrgPayment]  WITH CHECK ADD  CONSTRAINT [FK_tbOrgPayment_tbCashCode] FOREIGN KEY([CashCode])
REFERENCES [dbo].[tbCashCode] ([CashCode])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbOrgPayment] CHECK CONSTRAINT [FK_tbOrgPayment_tbCashCode]
GO
/****** Object:  ForeignKey [FK_tbOrgPayment_tbOrg]    Script Date: 01/11/2012 13:36:13 ******/
ALTER TABLE [dbo].[tbOrgPayment]  WITH CHECK ADD  CONSTRAINT [FK_tbOrgPayment_tbOrg] FOREIGN KEY([AccountCode])
REFERENCES [dbo].[tbOrg] ([AccountCode])
GO
ALTER TABLE [dbo].[tbOrgPayment] CHECK CONSTRAINT [FK_tbOrgPayment_tbOrg]
GO
/****** Object:  ForeignKey [FK_tbOrgPayment_tbOrgAccount]    Script Date: 01/11/2012 13:36:13 ******/
ALTER TABLE [dbo].[tbOrgPayment]  WITH CHECK ADD  CONSTRAINT [FK_tbOrgPayment_tbOrgAccount] FOREIGN KEY([CashAccountCode])
REFERENCES [dbo].[tbOrgAccount] ([CashAccountCode])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbOrgPayment] CHECK CONSTRAINT [FK_tbOrgPayment_tbOrgAccount]
GO
/****** Object:  ForeignKey [FK_tbOrgPayment_tbOrgPaymentStatus]    Script Date: 01/11/2012 13:36:13 ******/
ALTER TABLE [dbo].[tbOrgPayment]  WITH CHECK ADD  CONSTRAINT [FK_tbOrgPayment_tbOrgPaymentStatus] FOREIGN KEY([PaymentStatusCode])
REFERENCES [dbo].[tbOrgPaymentStatus] ([PaymentStatusCode])
GO
ALTER TABLE [dbo].[tbOrgPayment] CHECK CONSTRAINT [FK_tbOrgPayment_tbOrgPaymentStatus]
GO
/****** Object:  ForeignKey [FK_tbOrgPayment_tbSystemTaxCode]    Script Date: 01/11/2012 13:36:13 ******/
ALTER TABLE [dbo].[tbOrgPayment]  WITH CHECK ADD  CONSTRAINT [FK_tbOrgPayment_tbSystemTaxCode] FOREIGN KEY([TaxCode])
REFERENCES [dbo].[tbSystemTaxCode] ([TaxCode])
GO
ALTER TABLE [dbo].[tbOrgPayment] CHECK CONSTRAINT [FK_tbOrgPayment_tbSystemTaxCode]
GO
/****** Object:  ForeignKey [FK_tbOrgPayment_tbUser1]    Script Date: 01/11/2012 13:36:13 ******/
ALTER TABLE [dbo].[tbOrgPayment]  WITH CHECK ADD  CONSTRAINT [FK_tbOrgPayment_tbUser1] FOREIGN KEY([UserId])
REFERENCES [dbo].[tbUser] ([UserId])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbOrgPayment] CHECK CONSTRAINT [FK_tbOrgPayment_tbUser1]
GO
/****** Object:  ForeignKey [FK_tbOrgSector_tbOrg]    Script Date: 01/11/2012 13:36:14 ******/
ALTER TABLE [dbo].[tbOrgSector]  WITH CHECK ADD  CONSTRAINT [FK_tbOrgSector_tbOrg] FOREIGN KEY([AccountCode])
REFERENCES [dbo].[tbOrg] ([AccountCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbOrgSector] CHECK CONSTRAINT [FK_tbOrgSector_tbOrg]
GO
/****** Object:  ForeignKey [FK_tbOrgType_tbCashMode]    Script Date: 01/11/2012 13:36:15 ******/
ALTER TABLE [dbo].[tbOrgType]  WITH CHECK ADD  CONSTRAINT [FK_tbOrgType_tbCashMode] FOREIGN KEY([CashModeCode])
REFERENCES [dbo].[tbCashMode] ([CashModeCode])
GO
ALTER TABLE [dbo].[tbOrgType] CHECK CONSTRAINT [FK_tbOrgType_tbCashMode]
GO
/****** Object:  ForeignKey [FK_tbProfileMenuEntry_tbProfileMenu]    Script Date: 01/11/2012 13:36:21 ******/
ALTER TABLE [dbo].[tbProfileMenuEntry]  WITH CHECK ADD  CONSTRAINT [FK_tbProfileMenuEntry_tbProfileMenu] FOREIGN KEY([MenuId])
REFERENCES [dbo].[tbProfileMenu] ([MenuId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbProfileMenuEntry] CHECK CONSTRAINT [FK_tbProfileMenuEntry_tbProfileMenu]
GO
/****** Object:  ForeignKey [tbProfileMenuEntry_FK01]    Script Date: 01/11/2012 13:36:21 ******/
ALTER TABLE [dbo].[tbProfileMenuEntry]  WITH CHECK ADD  CONSTRAINT [tbProfileMenuEntry_FK01] FOREIGN KEY([Command])
REFERENCES [dbo].[tbProfileMenuCommand] ([Command])
GO
ALTER TABLE [dbo].[tbProfileMenuEntry] CHECK CONSTRAINT [tbProfileMenuEntry_FK01]
GO
/****** Object:  ForeignKey [tbProfileMenuEntry_FK02]    Script Date: 01/11/2012 13:36:21 ******/
ALTER TABLE [dbo].[tbProfileMenuEntry]  WITH CHECK ADD  CONSTRAINT [tbProfileMenuEntry_FK02] FOREIGN KEY([OpenMode])
REFERENCES [dbo].[tbProfileMenuOpenMode] ([OpenMode])
GO
ALTER TABLE [dbo].[tbProfileMenuEntry] CHECK CONSTRAINT [tbProfileMenuEntry_FK02]
GO
/****** Object:  ForeignKey [tbProfileObject_FK01]    Script Date: 01/11/2012 13:36:23 ******/
ALTER TABLE [dbo].[tbProfileObject]  WITH CHECK ADD  CONSTRAINT [tbProfileObject_FK01] FOREIGN KEY([ObjectTypeCode])
REFERENCES [dbo].[tbProfileObjectType] ([ObjectTypeCode])
GO
ALTER TABLE [dbo].[tbProfileObject] CHECK CONSTRAINT [tbProfileObject_FK01]
GO
/****** Object:  ForeignKey [FK_tbProfileObjectDetail_tbProfileObject]    Script Date: 01/11/2012 13:36:25 ******/
ALTER TABLE [dbo].[tbProfileObjectDetail]  WITH CHECK ADD  CONSTRAINT [FK_tbProfileObjectDetail_tbProfileObject] FOREIGN KEY([ObjectTypeCode], [ObjectName])
REFERENCES [dbo].[tbProfileObject] ([ObjectTypeCode], [ObjectName])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbProfileObjectDetail] CHECK CONSTRAINT [FK_tbProfileObjectDetail_tbProfileObject]
GO
/****** Object:  ForeignKey [tbProfileObjectDetail_FK01]    Script Date: 01/11/2012 13:36:25 ******/
ALTER TABLE [dbo].[tbProfileObjectDetail]  WITH CHECK ADD  CONSTRAINT [tbProfileObjectDetail_FK01] FOREIGN KEY([ItemTypeCode])
REFERENCES [dbo].[tbProfileItemType] ([ItemTypeCode])
GO
ALTER TABLE [dbo].[tbProfileObjectDetail] CHECK CONSTRAINT [tbProfileObjectDetail_FK01]
GO
/****** Object:  ForeignKey [tbSystemCalendarHoliday_FK00]    Script Date: 01/11/2012 13:36:30 ******/
ALTER TABLE [dbo].[tbSystemCalendarHoliday]  WITH CHECK ADD  CONSTRAINT [tbSystemCalendarHoliday_FK00] FOREIGN KEY([CalendarCode])
REFERENCES [dbo].[tbSystemCalendar] ([CalendarCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbSystemCalendarHoliday] CHECK CONSTRAINT [tbSystemCalendarHoliday_FK00]
GO
/****** Object:  ForeignKey [FK_tbSystemDoc_tbProfileMenuOpenMode]    Script Date: 01/11/2012 13:36:31 ******/
ALTER TABLE [dbo].[tbSystemDoc]  WITH CHECK ADD  CONSTRAINT [FK_tbSystemDoc_tbProfileMenuOpenMode] FOREIGN KEY([OpenMode])
REFERENCES [dbo].[tbProfileMenuOpenMode] ([OpenMode])
GO
ALTER TABLE [dbo].[tbSystemDoc] CHECK CONSTRAINT [FK_tbSystemDoc_tbProfileMenuOpenMode]
GO
/****** Object:  ForeignKey [FK_tbSystemOption_tbCashCategory]    Script Date: 01/11/2012 13:36:36 ******/
ALTER TABLE [dbo].[tbSystemOptions]  WITH CHECK ADD  CONSTRAINT [FK_tbSystemOption_tbCashCategory] FOREIGN KEY([NetProfitCode])
REFERENCES [dbo].[tbCashCategory] ([CategoryCode])
GO
ALTER TABLE [dbo].[tbSystemOptions] CHECK CONSTRAINT [FK_tbSystemOption_tbCashCategory]
GO
/****** Object:  ForeignKey [FK_tbSystemOptions_tbSystemBucketInterval]    Script Date: 01/11/2012 13:36:36 ******/
ALTER TABLE [dbo].[tbSystemOptions]  WITH CHECK ADD  CONSTRAINT [FK_tbSystemOptions_tbSystemBucketInterval] FOREIGN KEY([BucketIntervalCode])
REFERENCES [dbo].[tbSystemBucketInterval] ([BucketIntervalCode])
GO
ALTER TABLE [dbo].[tbSystemOptions] CHECK CONSTRAINT [FK_tbSystemOptions_tbSystemBucketInterval]
GO
/****** Object:  ForeignKey [FK_tbSystemOptions_tbSystemBucketType]    Script Date: 01/11/2012 13:36:36 ******/
ALTER TABLE [dbo].[tbSystemOptions]  WITH CHECK ADD  CONSTRAINT [FK_tbSystemOptions_tbSystemBucketType] FOREIGN KEY([BucketTypeCode])
REFERENCES [dbo].[tbSystemBucketType] ([BucketTypeCode])
GO
ALTER TABLE [dbo].[tbSystemOptions] CHECK CONSTRAINT [FK_tbSystemOptions_tbSystemBucketType]
GO
/****** Object:  ForeignKey [FK_tbSystemRoot_tbOrg]    Script Date: 01/11/2012 13:36:36 ******/
ALTER TABLE [dbo].[tbSystemOptions]  WITH CHECK ADD  CONSTRAINT [FK_tbSystemRoot_tbOrg] FOREIGN KEY([AccountCode])
REFERENCES [dbo].[tbOrg] ([AccountCode])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbSystemOptions] CHECK CONSTRAINT [FK_tbSystemRoot_tbOrg]
GO
/****** Object:  ForeignKey [FK_tbSystemTaxCode_tbCashTaxType]    Script Date: 01/11/2012 13:36:39 ******/
ALTER TABLE [dbo].[tbSystemTaxCode]  WITH CHECK ADD  CONSTRAINT [FK_tbSystemTaxCode_tbCashTaxType] FOREIGN KEY([TaxTypeCode])
REFERENCES [dbo].[tbCashTaxType] ([TaxTypeCode])
GO
ALTER TABLE [dbo].[tbSystemTaxCode] CHECK CONSTRAINT [FK_tbSystemTaxCode_tbCashTaxType]
GO
/****** Object:  ForeignKey [FK_tbSystemYear_tbSystemMonth]    Script Date: 01/11/2012 13:36:40 ******/
ALTER TABLE [dbo].[tbSystemYear]  WITH CHECK ADD  CONSTRAINT [FK_tbSystemYear_tbSystemMonth] FOREIGN KEY([StartMonth])
REFERENCES [dbo].[tbSystemMonth] ([MonthNumber])
GO
ALTER TABLE [dbo].[tbSystemYear] CHECK CONSTRAINT [FK_tbSystemYear_tbSystemMonth]
GO
/****** Object:  ForeignKey [FK_tbSystemYearPeriod_tbCashStatus]    Script Date: 01/11/2012 13:36:42 ******/
ALTER TABLE [dbo].[tbSystemYearPeriod]  WITH CHECK ADD  CONSTRAINT [FK_tbSystemYearPeriod_tbCashStatus] FOREIGN KEY([CashStatusCode])
REFERENCES [dbo].[tbCashStatus] ([CashStatusCode])
GO
ALTER TABLE [dbo].[tbSystemYearPeriod] CHECK CONSTRAINT [FK_tbSystemYearPeriod_tbCashStatus]
GO
/****** Object:  ForeignKey [FK_tbSystemYearPeriod_tbSystemMonth]    Script Date: 01/11/2012 13:36:42 ******/
ALTER TABLE [dbo].[tbSystemYearPeriod]  WITH CHECK ADD  CONSTRAINT [FK_tbSystemYearPeriod_tbSystemMonth] FOREIGN KEY([MonthNumber])
REFERENCES [dbo].[tbSystemMonth] ([MonthNumber])
GO
ALTER TABLE [dbo].[tbSystemYearPeriod] CHECK CONSTRAINT [FK_tbSystemYearPeriod_tbSystemMonth]
GO
/****** Object:  ForeignKey [FK_tbSystemYearPeriod_tbSystemYear]    Script Date: 01/11/2012 13:36:42 ******/
ALTER TABLE [dbo].[tbSystemYearPeriod]  WITH CHECK ADD  CONSTRAINT [FK_tbSystemYearPeriod_tbSystemYear] FOREIGN KEY([YearNumber])
REFERENCES [dbo].[tbSystemYear] ([YearNumber])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbSystemYearPeriod] CHECK CONSTRAINT [FK_tbSystemYearPeriod_tbSystemYear]
GO
/****** Object:  ForeignKey [FK_tbTask_tbCashCode]    Script Date: 01/11/2012 13:36:47 ******/
ALTER TABLE [dbo].[tbTask]  WITH CHECK ADD  CONSTRAINT [FK_tbTask_tbCashCode] FOREIGN KEY([CashCode])
REFERENCES [dbo].[tbCashCode] ([CashCode])
GO
ALTER TABLE [dbo].[tbTask] CHECK CONSTRAINT [FK_tbTask_tbCashCode]
GO
/****** Object:  ForeignKey [FK_tbTask_tbOrgAddress]    Script Date: 01/11/2012 13:36:47 ******/
ALTER TABLE [dbo].[tbTask]  WITH CHECK ADD  CONSTRAINT [FK_tbTask_tbOrgAddress] FOREIGN KEY([AddressCodeFrom])
REFERENCES [dbo].[tbOrgAddress] ([AddressCode])
GO
ALTER TABLE [dbo].[tbTask] CHECK CONSTRAINT [FK_tbTask_tbOrgAddress]
GO
/****** Object:  ForeignKey [FK_tbTask_tbOrgAddress1]    Script Date: 01/11/2012 13:36:48 ******/
ALTER TABLE [dbo].[tbTask]  WITH CHECK ADD  CONSTRAINT [FK_tbTask_tbOrgAddress1] FOREIGN KEY([AddressCodeTo])
REFERENCES [dbo].[tbOrgAddress] ([AddressCode])
GO
ALTER TABLE [dbo].[tbTask] CHECK CONSTRAINT [FK_tbTask_tbOrgAddress1]
GO
/****** Object:  ForeignKey [FK_tbTask_tbSystemTaxCode]    Script Date: 01/11/2012 13:36:48 ******/
ALTER TABLE [dbo].[tbTask]  WITH CHECK ADD  CONSTRAINT [FK_tbTask_tbSystemTaxCode] FOREIGN KEY([TaxCode])
REFERENCES [dbo].[tbSystemTaxCode] ([TaxCode])
GO
ALTER TABLE [dbo].[tbTask] CHECK CONSTRAINT [FK_tbTask_tbSystemTaxCode]
GO
/****** Object:  ForeignKey [FK_tbTask_tbUser]    Script Date: 01/11/2012 13:36:48 ******/
ALTER TABLE [dbo].[tbTask]  WITH CHECK ADD  CONSTRAINT [FK_tbTask_tbUser] FOREIGN KEY([UserId])
REFERENCES [dbo].[tbUser] ([UserId])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbTask] CHECK CONSTRAINT [FK_tbTask_tbUser]
GO
/****** Object:  ForeignKey [FK_tbTask_tbUser1]    Script Date: 01/11/2012 13:36:48 ******/
ALTER TABLE [dbo].[tbTask]  WITH CHECK ADD  CONSTRAINT [FK_tbTask_tbUser1] FOREIGN KEY([ActionById])
REFERENCES [dbo].[tbUser] ([UserId])
GO
ALTER TABLE [dbo].[tbTask] CHECK CONSTRAINT [FK_tbTask_tbUser1]
GO
/****** Object:  ForeignKey [tbActivity_FK00]    Script Date: 01/11/2012 13:36:48 ******/
ALTER TABLE [dbo].[tbTask]  WITH CHECK ADD  CONSTRAINT [tbActivity_FK00] FOREIGN KEY([ActivityCode])
REFERENCES [dbo].[tbActivity] ([ActivityCode])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbTask] CHECK CONSTRAINT [tbActivity_FK00]
GO
/****** Object:  ForeignKey [tbActivity_FK01]    Script Date: 01/11/2012 13:36:48 ******/
ALTER TABLE [dbo].[tbTask]  WITH CHECK ADD  CONSTRAINT [tbActivity_FK01] FOREIGN KEY([TaskStatusCode])
REFERENCES [dbo].[tbTaskStatus] ([TaskStatusCode])
GO
ALTER TABLE [dbo].[tbTask] CHECK CONSTRAINT [tbActivity_FK01]
GO
/****** Object:  ForeignKey [tbActivity_FK02]    Script Date: 01/11/2012 13:36:48 ******/
ALTER TABLE [dbo].[tbTask]  WITH CHECK ADD  CONSTRAINT [tbActivity_FK02] FOREIGN KEY([AccountCode])
REFERENCES [dbo].[tbOrg] ([AccountCode])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbTask] CHECK CONSTRAINT [tbActivity_FK02]
GO
/****** Object:  ForeignKey [FK_tbTaskAttrib_tbTask1]    Script Date: 01/11/2012 13:36:50 ******/
ALTER TABLE [dbo].[tbTaskAttribute]  WITH CHECK ADD  CONSTRAINT [FK_tbTaskAttrib_tbTask1] FOREIGN KEY([TaskCode])
REFERENCES [dbo].[tbTask] ([TaskCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbTaskAttribute] CHECK CONSTRAINT [FK_tbTaskAttrib_tbTask1]
GO
/****** Object:  ForeignKey [FK_tbTaskAttribute_tbActivityAttributeType]    Script Date: 01/11/2012 13:36:50 ******/
ALTER TABLE [dbo].[tbTaskAttribute]  WITH CHECK ADD  CONSTRAINT [FK_tbTaskAttribute_tbActivityAttributeType] FOREIGN KEY([AttributeTypeCode])
REFERENCES [dbo].[tbActivityAttributeType] ([AttributeTypeCode])
GO
ALTER TABLE [dbo].[tbTaskAttribute] CHECK CONSTRAINT [FK_tbTaskAttribute_tbActivityAttributeType]
GO
/****** Object:  ForeignKey [FK_tbTaskDoc_tbTask]    Script Date: 01/11/2012 13:36:52 ******/
ALTER TABLE [dbo].[tbTaskDoc]  WITH CHECK ADD  CONSTRAINT [FK_tbTaskDoc_tbTask] FOREIGN KEY([TaskCode])
REFERENCES [dbo].[tbTask] ([TaskCode])
GO
ALTER TABLE [dbo].[tbTaskDoc] CHECK CONSTRAINT [FK_tbTaskDoc_tbTask]
GO
/****** Object:  ForeignKey [FK_tbTaskFlow_tbTask]    Script Date: 01/11/2012 13:36:54 ******/
ALTER TABLE [dbo].[tbTaskFlow]  WITH CHECK ADD  CONSTRAINT [FK_tbTaskFlow_tbTask] FOREIGN KEY([ParentTaskCode])
REFERENCES [dbo].[tbTask] ([TaskCode])
GO
ALTER TABLE [dbo].[tbTaskFlow] CHECK CONSTRAINT [FK_tbTaskFlow_tbTask]
GO
/****** Object:  ForeignKey [FK_tbTaskFlow_tbTask1]    Script Date: 01/11/2012 13:36:54 ******/
ALTER TABLE [dbo].[tbTaskFlow]  WITH CHECK ADD  CONSTRAINT [FK_tbTaskFlow_tbTask1] FOREIGN KEY([ChildTaskCode])
REFERENCES [dbo].[tbTask] ([TaskCode])
GO
ALTER TABLE [dbo].[tbTaskFlow] CHECK CONSTRAINT [FK_tbTaskFlow_tbTask1]
GO
/****** Object:  ForeignKey [FK_tbTaskOp_tbActivityOpType]    Script Date: 01/11/2012 13:36:57 ******/
ALTER TABLE [dbo].[tbTaskOp]  WITH CHECK ADD  CONSTRAINT [FK_tbTaskOp_tbActivityOpType] FOREIGN KEY([OpTypeCode])
REFERENCES [dbo].[tbActivityOpType] ([OpTypeCode])
GO
ALTER TABLE [dbo].[tbTaskOp] CHECK CONSTRAINT [FK_tbTaskOp_tbActivityOpType]
GO
/****** Object:  ForeignKey [FK_tbTaskOp_tbTask]    Script Date: 01/11/2012 13:36:57 ******/
ALTER TABLE [dbo].[tbTaskOp]  WITH CHECK ADD  CONSTRAINT [FK_tbTaskOp_tbTask] FOREIGN KEY([TaskCode])
REFERENCES [dbo].[tbTask] ([TaskCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbTaskOp] CHECK CONSTRAINT [FK_tbTaskOp_tbTask]
GO
/****** Object:  ForeignKey [FK_tbTaskOp_tbTaskOpStatus]    Script Date: 01/11/2012 13:36:57 ******/
ALTER TABLE [dbo].[tbTaskOp]  WITH CHECK ADD  CONSTRAINT [FK_tbTaskOp_tbTaskOpStatus] FOREIGN KEY([OpStatusCode])
REFERENCES [dbo].[tbTaskOpStatus] ([OpStatusCode])
GO
ALTER TABLE [dbo].[tbTaskOp] CHECK CONSTRAINT [FK_tbTaskOp_tbTaskOpStatus]
GO
/****** Object:  ForeignKey [FK_tbTaskOp_tbUser]    Script Date: 01/11/2012 13:36:57 ******/
ALTER TABLE [dbo].[tbTaskOp]  WITH CHECK ADD  CONSTRAINT [FK_tbTaskOp_tbUser] FOREIGN KEY([UserId])
REFERENCES [dbo].[tbUser] ([UserId])
GO
ALTER TABLE [dbo].[tbTaskOp] CHECK CONSTRAINT [FK_tbTaskOp_tbUser]
GO
/****** Object:  ForeignKey [FK_tbTaskQuote_tbTask]    Script Date: 01/11/2012 13:36:59 ******/
ALTER TABLE [dbo].[tbTaskQuote]  WITH CHECK ADD  CONSTRAINT [FK_tbTaskQuote_tbTask] FOREIGN KEY([TaskCode])
REFERENCES [dbo].[tbTask] ([TaskCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbTaskQuote] CHECK CONSTRAINT [FK_tbTaskQuote_tbTask]
GO
/****** Object:  ForeignKey [FK_tbUser_tbSystemCalendar]    Script Date: 01/11/2012 13:37:03 ******/
ALTER TABLE [dbo].[tbUser]  WITH CHECK ADD  CONSTRAINT [FK_tbUser_tbSystemCalendar] FOREIGN KEY([CalendarCode])
REFERENCES [dbo].[tbSystemCalendar] ([CalendarCode])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbUser] CHECK CONSTRAINT [FK_tbUser_tbSystemCalendar]
GO
/****** Object:  ForeignKey [FK_tbUserMenu_tbProfileMenu]    Script Date: 01/11/2012 13:37:03 ******/
ALTER TABLE [dbo].[tbUserMenu]  WITH CHECK ADD  CONSTRAINT [FK_tbUserMenu_tbProfileMenu] FOREIGN KEY([MenuId])
REFERENCES [dbo].[tbProfileMenu] ([MenuId])
GO
ALTER TABLE [dbo].[tbUserMenu] CHECK CONSTRAINT [FK_tbUserMenu_tbProfileMenu]
GO
/****** Object:  ForeignKey [FK_tbUserMenu_tbUser1]    Script Date: 01/11/2012 13:37:03 ******/
ALTER TABLE [dbo].[tbUserMenu]  WITH CHECK ADD  CONSTRAINT [FK_tbUserMenu_tbUser1] FOREIGN KEY([UserId])
REFERENCES [dbo].[tbUser] ([UserId])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbUserMenu] CHECK CONSTRAINT [FK_tbUserMenu_tbUser1]
GO
CREATE FUNCTION [dbo].[fnStatementCompany]()
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
	
	/**************************************/
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	SELECT     ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode
	FROM         dbo.fnStatementCorpTax()
	
	set @ReferenceCode = dbo.fnSystemProfileText(1215)	
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	SELECT     @ReferenceCode AS ReferenceCode, dbo.fnStatementTaxAccount(1) AS AccountCode, StartOn, 5, 0, CorporationTax, CashCode
	FROM         fnTaxCorpOrderTotals(0) fnTaxCorpOrderTotals_1		

	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	SELECT     ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode
	FROM         dbo.fnStatementVat()

	SET @AccountCode = dbo.fnStatementTaxAccount(2)
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	SELECT     @ReferenceCode AS ReferenceCode, @AccountCode AS AccountCode, dbo.fnTaskDefaultPaymentOn(@AccountCode, StartOn), 6 AS Expr1, PayIn, PayOut, dbo.fnSystemCashCode(2)
	FROM         fnTaxVatOrderTotals(0) fnTaxVatOrderTotals_1
	WHERE     (PayIn + PayOut <> 0)		
	/**************************************/	
	
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
CREATE VIEW [dbo].[vwTaskProfitOrders]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbTask.ActionOn) AS StartOn, dbo.tbTask.TaskCode, 
                      CASE WHEN dbo.tbCashCategory.CashModeCode = 1 THEN dbo.tbTask.TotalCharge * - 1 ELSE dbo.tbTask.TotalCharge END AS TotalCharge
FROM         dbo.tbCashCode INNER JOIN
                      dbo.tbTask ON dbo.tbCashCode.CashCode = dbo.tbTask.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode LEFT OUTER JOIN
                      dbo.tbTask AS tbTask_1 RIGHT OUTER JOIN
                      dbo.tbTaskFlow ON tbTask_1.TaskCode = dbo.tbTaskFlow.ParentTaskCode ON dbo.tbTask.TaskCode = dbo.tbTaskFlow.ChildTaskCode
WHERE     (dbo.tbTask.TaskStatusCode > 1) AND (dbo.tbTaskFlow.ParentTaskCode IS NULL) AND (tbTask_1.CashCode IS NULL) AND 
                      (dbo.tbTask.TaskStatusCode < 5) OR
                      (dbo.tbTask.TaskStatusCode > 1) AND (tbTask_1.CashCode IS NULL) AND (dbo.tbTask.TaskStatusCode < 5)
GO
CREATE FUNCTION [dbo].[fnNetProfitCashCodes]
	()
RETURNS @tbCashCode TABLE (CashCode nvarchar(50))
AS
	BEGIN
	declare @CategoryCode nvarchar(10)
	select @CategoryCode = NetProfitCode from tbSystemOptions	
	set @CategoryCode = isnull(@CategoryCode, '')
	if (@CategoryCode != '')
		begin
		insert into @tbCashCode (CashCode)
		select CashCode from dbo.fnCategoryTotalCashCodes(@CategoryCode)
		end
	RETURN
	END
GO
CREATE VIEW [dbo].[vwCorpTaxInvoiceItems]
AS
SELECT     TOP (100) PERCENT dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.InvoiceValue * - 1 ELSE dbo.tbInvoiceItem.InvoiceValue END AS InvoiceValue
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.fnNetProfitCashCodes() AS fnNetProfitCashCodes ON dbo.tbInvoiceItem.CashCode = fnNetProfitCashCodes.CashCode INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
ORDER BY StartOn
GO
CREATE VIEW [dbo].[vwCorpTaxInvoiceTasks]
AS
SELECT     TOP (100) PERCENT dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.InvoiceValue * - 1 ELSE dbo.tbInvoiceTask.InvoiceValue END AS InvoiceValue
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.fnNetProfitCashCodes() AS fnNetProfitCashCodes ON dbo.tbInvoiceTask.CashCode = fnNetProfitCashCodes.CashCode INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
ORDER BY StartOn
GO
CREATE VIEW [dbo].[vwCorpTaxInvoiceValue]
AS
SELECT     StartOn, SUM(InvoiceValue) AS NetProfit
FROM         dbo.vwCorpTaxInvoiceItems
GROUP BY StartOn
UNION
SELECT     StartOn, SUM(InvoiceValue) AS NetProfit
FROM         dbo.vwCorpTaxInvoiceTasks
GROUP BY StartOn
GO
CREATE VIEW [dbo].[vwCorpTaxInvoiceBase]
AS
SELECT     StartOn, SUM(NetProfit) AS NetProfit
FROM         dbo.vwCorpTaxInvoiceValue
GROUP BY StartOn
GO
CREATE VIEW [dbo].[vwCorpTaxInvoice]
AS
SELECT     TOP 100 PERCENT dbo.tbSystemYearPeriod.StartOn, dbo.vwCorpTaxInvoiceBase.NetProfit, 
                      dbo.vwCorpTaxInvoiceBase.NetProfit * dbo.tbSystemYearPeriod.CorporationTaxRate + dbo.tbSystemYearPeriod.TaxAdjustment AS CorporationTax, 
                      dbo.tbSystemYearPeriod.TaxAdjustment
FROM         dbo.vwCorpTaxInvoiceBase INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.vwCorpTaxInvoiceBase.StartOn = dbo.tbSystemYearPeriod.StartOn
ORDER BY dbo.tbSystemYearPeriod.StartOn
GO
CREATE  VIEW [dbo].[vwInvoiceVatItems]
AS
SELECT     TOP 100 PERCENT dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoice.InvoiceNumber, dbo.tbInvoice.InvoiceTypeCode, 
                      dbo.tbInvoiceItem.TaxCode, dbo.tbInvoiceItem.InvoiceValue, dbo.tbInvoiceItem.TaxValue, dbo.tbOrg.ForeignJurisdiction
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbInvoiceItem.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 2)
ORDER BY dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn)
GO
CREATE  VIEW [dbo].[vwInvoiceVatTasks]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoiceTask.InvoiceNumber, dbo.tbInvoice.InvoiceTypeCode, 
                      dbo.tbInvoiceTask.TaxCode, dbo.tbInvoiceTask.InvoiceValue, dbo.tbInvoiceTask.TaxValue, dbo.tbOrg.ForeignJurisdiction
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbInvoiceTask.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 2)
GO
CREATE  VIEW [dbo].[vwInvoiceVatBase]
AS
SELECT DISTINCT StartOn, InvoiceNumber, InvoiceTypeCode, TaxCode, InvoiceValue, TaxValue, ForeignJurisdiction
FROM         dbo.vwInvoiceVatItems
UNION
SELECT DISTINCT StartOn, InvoiceNumber, InvoiceTypeCode, TaxCode, InvoiceValue, TaxValue, ForeignJurisdiction
FROM         dbo.vwInvoiceVatTasks
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
CREATE VIEW [dbo].[vwSystemVatCashCode]
AS
SELECT     CashCode, MonthNumber, RecurrenceCode
FROM         dbo.tbCashTaxType
WHERE     (TaxTypeCode = 2)
GO
CREATE VIEW [dbo].[vwSystemCorpTaxCashCode]
AS
SELECT     CashCode, MonthNumber, RecurrenceCode
FROM         dbo.tbCashTaxType
WHERE     (TaxTypeCode = 1)
GO
CREATE FUNCTION [dbo].[fnCategoryTotalCashCodes]
	(
	@CategoryCode nvarchar(10)
	)
RETURNS @tbCashCode TABLE (CashCode nvarchar(50))
AS
	BEGIN
	INSERT INTO @tbCashCode (CashCode)
	SELECT     tbCashCode.CashCode
	FROM         tbCashCategoryTotal INNER JOIN
	                      tbCashCategory ON tbCashCategoryTotal.ChildCode = tbCashCategory.CategoryCode INNER JOIN
	                      tbCashCode ON tbCashCategory.CategoryCode = tbCashCode.CategoryCode
	WHERE     (tbCashCategoryTotal.ParentCode = @CategoryCode)
	
	declare @ChildCode nvarchar(10)
	
	declare curCat cursor local for
		SELECT     tbCashCategory.CategoryCode
		FROM         tbCashCategory INNER JOIN
		                      tbCashCategoryTotal ON tbCashCategory.CategoryCode = tbCashCategoryTotal.ChildCode
		WHERE     (tbCashCategory.CategoryTypeCode = 2) AND (tbCashCategoryTotal.ParentCode = @CategoryCode)
	
	open curCat
	fetch next from curCat into @ChildCode
	while (@@FETCH_STATUS = 0)
		begin
		insert into @tbCashCode(CashCode)
		select CashCode from dbo.fnCategoryTotalCashCodes(@ChildCode)
		fetch next from curCat into @ChildCode
		end
	
	close curCat
	deallocate curCat
	
	RETURN
	END
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
CREATE FUNCTION [dbo].[fnSystemTaxHorizon]	()
RETURNS SMALLINT
AS
	BEGIN
	DECLARE @TaxHorizon SMALLINT
	SELECT @TaxHorizon = TaxHorizon FROM tbSystemOptions
	RETURN @TaxHorizon
	END
GO
CREATE VIEW [dbo].[vwCorpTaxConfirmedBase]
AS
SELECT     TOP 100 PERCENT dbo.fnAccountPeriod(dbo.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * - 1 ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) END AS OrderValue
FROM         dbo.vwTaskInvoicedQuantity RIGHT OUTER JOIN
                      dbo.fnNetProfitCashCodes() AS fnNetProfitCashCodes INNER JOIN
                      dbo.tbCashCategory INNER JOIN
                      dbo.tbCashCode ON dbo.tbCashCategory.CategoryCode = dbo.tbCashCode.CategoryCode ON 
                      fnNetProfitCashCodes.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbTask ON fnNetProfitCashCodes.CashCode = dbo.tbTask.CashCode ON dbo.vwTaskInvoicedQuantity.TaskCode = dbo.tbTask.TaskCode
WHERE     (dbo.tbTask.TaskStatusCode > 1) AND (dbo.tbTask.TaskStatusCode < 4) AND 
                      (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0) > 0) AND (dbo.tbTask.PaymentOn <= DATEADD(d, 
                      dbo.fnSystemTaxHorizon(), GETDATE()))
GO
CREATE VIEW [dbo].[vwCorpTaxConfirmed]
AS
SELECT     dbo.vwCorpTaxConfirmedBase.StartOn, SUM(dbo.vwCorpTaxConfirmedBase.OrderValue) AS NetProfit, 
                      SUM(dbo.vwCorpTaxConfirmedBase.OrderValue * dbo.tbSystemYearPeriod.CorporationTaxRate) AS CorporationTax
FROM         dbo.vwCorpTaxConfirmedBase INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.vwCorpTaxConfirmedBase.StartOn = dbo.tbSystemYearPeriod.StartOn
GROUP BY dbo.vwCorpTaxConfirmedBase.StartOn
GO
CREATE VIEW [dbo].[vwSystemTaxRates]
AS
SELECT     TaxCode, CAST(TaxRate AS MONEY) AS TaxRate, TaxTypeCode
FROM         tbSystemTaxCode
GO
CREATE VIEW [dbo].[vwTaskVatConfirmed]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * vwSystemTaxRates.TaxRate * - 1 ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) 
                      * vwSystemTaxRates.TaxRate END AS VatValue
FROM         dbo.tbTask INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode INNER JOIN
                      dbo.vwSystemTaxRates ON dbo.tbTask.TaxCode = dbo.vwSystemTaxRates.TaxCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.vwSystemTaxRates.TaxTypeCode = 2) AND (dbo.tbTask.TaskStatusCode > 1) AND (dbo.tbTask.TaskStatusCode < 4) AND 
                      (CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * vwSystemTaxRates.TaxRate ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) 
                      * vwSystemTaxRates.TaxRate * - 1 END <> 0) AND (dbo.tbTask.PaymentOn <= DATEADD(d, dbo.fnSystemTaxHorizon(), GETDATE()))
GO
CREATE FUNCTION [dbo].[fnTaskProfitCost]
	(
	@ParentTaskCode nvarchar(20),
	@TotalCost money,
	@InvoicedCost money,
	@InvoicedCostPaid money
	)
RETURNS @tbCost TABLE (	
	TotalCost money,
	InvoicedCost money,
	InvoicedCostPaid money
	)
AS
	BEGIN
declare @TaskCode nvarchar(20)
declare @TotalCharge money
declare @TotalInvoiced money
declare @TotalPaid money
declare @CashModeCode smallint

	declare curFlow cursor local for
		SELECT     tbTask.TaskCode, vwTaskCashMode.CashModeCode, tbTask.TotalCharge
		FROM         tbTask INNER JOIN
							  tbTaskFlow ON tbTask.TaskCode = tbTaskFlow.ChildTaskCode INNER JOIN
							  vwTaskCashMode ON tbTask.TaskCode = vwTaskCashMode.TaskCode
		WHERE     (tbTaskFlow.ParentTaskCode = @ParentTaskCode)  AND (tbTask.TaskStatusCode < 5)	

	open curFlow
	fetch next from curFlow into @TaskCode, @CashModeCode, @TotalCharge
	while @@FETCH_STATUS = 0
		begin
		
		SELECT  @TotalInvoiced = SUM(CASE WHEN tbInvoiceType.CashModeCode = 1 THEN tbInvoiceTask.InvoiceValue ELSE tbInvoiceTask.InvoiceValue * - 1 END), 
				@TotalPaid = SUM(CASE WHEN tbInvoiceType.CashModeCode = 1 THEN tbInvoiceTask.PaidValue ELSE tbInvoiceTask.PaidValue * - 1 END) 	                      
		FROM         tbInvoiceTask INNER JOIN
							  tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber INNER JOIN
							  tbInvoiceType ON tbInvoice.InvoiceTypeCode = tbInvoiceType.InvoiceTypeCode
		WHERE     (tbInvoiceTask.TaskCode = @TaskCode)

		set @InvoicedCost = @InvoicedCost + isnull(@TotalInvoiced, 0)
		set @InvoicedCostPaid = @InvoicedCostPaid + isnull(@TotalPaid, 0)
		set @TotalCost = @TotalCost + case when @CashModeCode = 1 then @TotalCharge else @TotalCharge * -1 end
		
		SELECT @TotalCost = TotalCost, 
			@InvoicedCost = InvoicedCost, 
			@InvoicedCostPaid = InvoicedCostPaid
		FROM         dbo.fnTaskProfitCost(@TaskCode, @TotalCost, @InvoicedCost, @InvoicedCostPaid) AS fnTaskProfitCost_1	
		
		fetch next from curFlow into @TaskCode, @CashModeCode, @TotalCharge
		end
	
	close curFlow
	deallocate curFlow

	insert into @tbCost (TotalCost, InvoicedCost, InvoicedCostPaid)
	values (@TotalCost, @InvoicedCost, @InvoicedCostPaid)		
	
	
	RETURN
	END
GO
CREATE FUNCTION [dbo].[fnTaskProfitOrder]
	(
	@TaskCode nvarchar(20)
	)
RETURNS @tbOrder TABLE (	
	InvoicedCharge money,
	InvoicedChargePaid money,
	TotalCost money,
	InvoicedCost money,
	InvoicedCostPaid money
	)
AS
	BEGIN
declare @InvoicedCharge money
declare @InvoicedChargePaid money
declare @TotalCost money
declare @InvoicedCost money
declare @InvoicedCostPaid money

	SELECT  @InvoicedCharge = SUM(CASE WHEN tbInvoiceType.CashModeCode = 1 THEN tbInvoiceTask.InvoiceValue * - 1 ELSE tbInvoiceTask.InvoiceValue END), 
	@InvoicedChargePaid = SUM(CASE WHEN tbInvoiceType.CashModeCode = 1 THEN tbInvoiceTask.PaidValue * - 1 ELSE tbInvoiceTask.PaidValue END) 	                      
	FROM         tbInvoiceTask INNER JOIN
	                      tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber INNER JOIN
	                      tbInvoiceType ON tbInvoice.InvoiceTypeCode = tbInvoiceType.InvoiceTypeCode
	WHERE     (tbInvoiceTask.TaskCode = @TaskCode)
	
	SELECT TOP 1 @TotalCost = TotalCost, @InvoicedCost = InvoicedCost, @InvoicedCostPaid = InvoicedCostPaid
	FROM         dbo.fnTaskProfitCost(@TaskCode, 0, 0, 0) AS fnTaskProfitCost_1
	
	insert into @tbOrder (InvoicedCharge, InvoicedChargePaid, TotalCost, InvoicedCost, InvoicedCostPaid)
		values (isnull(@InvoicedCharge, 0), isnull(@InvoicedChargePaid, 0), @TotalCost, @InvoicedCost, @InvoicedCostPaid)
	
	RETURN
	END
GO
CREATE FUNCTION [dbo].[fnTaskProfit]()
RETURNS @tbTaskProfit TABLE (
	TaskCode nvarchar(20),
	StartOn datetime,
	TotalCharge money,
	InvoicedCharge money,
	InvoicedChargePaid money,
	TotalCost money,
	InvoicedCost money,
	InvoicedCostPaid money
	) 
AS
	BEGIN
declare @StartOn datetime
declare @TaskCode nvarchar(20)
declare @TotalCharge money
declare @InvoicedCharge money
declare @InvoicedChargePaid money
declare @TotalCost money
declare @InvoicedCost money
declare @InvoicedCostPaid money


	declare curTasks cursor local for
		SELECT     StartOn, TaskCode, TotalCharge
		FROM         vwTaskProfitOrders
		ORDER BY StartOn

	open curTasks
	fetch next from curTasks into @StartOn, @TaskCode, @TotalCharge
	
	while (@@FETCH_STATUS = 0)
		begin
		set @InvoicedCharge = 0
		set @InvoicedChargePaid = 0
		set @TotalCost = 0
		set @InvoicedCost = 0
		set @InvoicedCostPaid = 0
				
		SELECT   @InvoicedCharge = InvoicedCharge, 
			@InvoicedChargePaid = InvoicedChargePaid, 
			@TotalCost = TotalCost, 
			@InvoicedCost = InvoicedCost, 
			@InvoicedCostPaid = InvoicedCostPaid
		FROM   dbo.fnTaskProfitOrder(@TaskCode) AS fnTaskProfitOrder_1
		
		insert into @tbTaskProfit (TaskCode, StartOn, TotalCharge, InvoicedCharge, InvoicedChargePaid, TotalCost, InvoicedCost, InvoicedCostPaid)
		values (@TaskCode, @StartOn, @TotalCharge, @InvoicedCharge, @InvoicedChargePaid, @TotalCost, @InvoicedCost, @InvoicedCostPaid)
		
		fetch next from curTasks into @StartOn, @TaskCode, @TotalCharge	
		end
	
	close curTasks
	deallocate curTasks
		
	RETURN
	END
GO
CREATE  FUNCTION [dbo].[fnTaxTypeDueDates]
	(@TaxTypeCode smallint)
RETURNS @tbDueDate TABLE (PayOn datetime, PayFrom datetime, PayTo datetime)
AS
	BEGIN
	declare @MonthNumber smallint
	declare @RecurrenceCode smallint
	declare @MonthInterval smallint
	declare @StartOn datetime
	
	select @MonthNumber = MonthNumber, @RecurrenceCode = RecurrenceCode
	from tbCashTaxType
	where TaxTypeCode = @TaxTypeCode
	
	set @MonthInterval = case @RecurrenceCode
		when 1 then 1
		when 2 then 1
		when 3 then 3
		when 4 then 6
		when 5 then 12
		end
				
	SELECT   @StartOn = MIN(StartOn)
	FROM         tbSystemYearPeriod
	WHERE     (MonthNumber = @MonthNumber)
	ORDER BY MIN(StartOn)
	
	insert into @tbDueDate (PayOn) values (@StartOn)
	
	set @MonthNumber = case 
		when (@MonthNumber + @MonthInterval) <= 12 then @MonthNumber + @MonthInterval
		else (@MonthNumber + @MonthInterval) % 12
		end
	
	while exists(SELECT     MonthNumber
	             FROM         tbSystemYearPeriod
	             WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber))
		begin
		SELECT @StartOn = MIN(StartOn)
	    FROM         tbSystemYearPeriod
	    WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber)
		ORDER BY MIN(StartOn)		
		insert into @tbDueDate (PayOn) values (@StartOn)
		
		set @MonthNumber = case 
			when (@MonthNumber + @MonthInterval) <= 12 then @MonthNumber + @MonthInterval
			else (@MonthNumber + @MonthInterval) % 12
			end
		
		end
	
	-- Set PayTo
	declare @PayOn datetime
	declare @PayFrom datetime
		
	if (@TaxTypeCode = 1)
		goto CorporationTax
	else
		goto VatTax
		
	return
	
CorporationTax:

	SELECT @StartOn = MIN(StartOn)
	FROM tbSystemYearPeriod
	ORDER BY MIN(StartOn)
	
	set @PayFrom = @StartOn
	
	SELECT @MonthNumber = MonthNumber
	FROM         tbSystemYearPeriod
	WHERE StartOn = @StartOn

	set @MonthNumber = case 
		when (@MonthNumber + @MonthInterval) <= 12 then @MonthNumber + @MonthInterval
		else (@MonthNumber + @MonthInterval) % 12
		end
	
	while exists(SELECT     MonthNumber
	             FROM         tbSystemYearPeriod
	             WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber))
		begin
		SELECT @StartOn = MIN(StartOn)
	    FROM         tbSystemYearPeriod
	    WHERE     (StartOn > @StartOn) AND (MonthNumber = @MonthNumber)
		ORDER BY MIN(StartOn)		
		
		select @PayOn = MIN(PayOn)
		from @tbDueDate
		where PayOn >= @StartOn
		order by min(PayOn)
		
		update @tbDueDate
		set PayTo = @StartOn, PayFrom = @PayFrom
		where PayOn = @PayOn
		
		set @PayFrom = @StartOn
		
		set @MonthNumber = case 
			when (@MonthNumber + @MonthInterval) <= 12 then @MonthNumber + @MonthInterval
			else (@MonthNumber + @MonthInterval) % 12
			end
		
		end

	delete from @tbDueDate where PayTo is null
	
	RETURN

VatTax:

	declare curTemp cursor for
		select PayOn from @tbDueDate
		order by PayOn

	open curTemp
	fetch next from curTemp into @PayOn	
	while @@FETCH_STATUS = 0
		begin
		update @tbDueDate
		set 
			PayFrom = dateadd(m, @MonthInterval * -1, @PayOn),
			PayTo = @PayOn
		where PayOn = @PayOn

		fetch next from curTemp into @PayOn	
		end

	close curTemp
	deallocate curTemp
	
	RETURN
	
	END
GO
CREATE  FUNCTION [dbo].[fnSystemCashCode]
	(
	@TaxTypeCode smallint
	)
RETURNS nvarchar(50)
AS
	BEGIN
	declare @CashCode nvarchar(50)
	
	SELECT @CashCode = CashCode
	FROM         tbCashTaxType
	WHERE     (TaxTypeCode = @TaxTypeCode)
		
	
	RETURN @CashCode
	END
GO
CREATE FUNCTION [dbo].[fnTaxCorpTotals]
()
RETURNS @tbCorp TABLE 
	(
	StartOn datetime, 
	NetProfit money,
	CorporationTax money
	)
AS
	BEGIN
	declare @PayOn datetime
	declare @PayFrom datetime
	declare @PayTo datetime
	
	declare curVat cursor local for
		SELECT     PayOn, PayFrom, PayTo
		FROM         fnTaxTypeDueDates(1) fnTaxTypeDueDates
		
	open curVat
	fetch next from curVat into @PayOn, @PayFrom, @PayTo
	while (@@FETCH_STATUS = 0)
		begin
		INSERT INTO @tbCorp (StartOn, NetProfit, CorporationTax)
		SELECT     @PayOn AS PayOn, ISNULL(SUM(NetProfit), 0) AS NetProfit, ISNULL(SUM(CorporationTax), 0) AS CorporationTax
		FROM         vwCorpTaxInvoice
		WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
		
		fetch next from curVat into @PayOn, @PayFrom, @PayTo
		end
	
	close curVat
	deallocate curVat

	
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
CREATE FUNCTION [dbo].[fnSystemAdjustDateToBucket]
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
CREATE FUNCTION [dbo].[fnCashCompanyBalance]
	()
RETURNS money
AS
	BEGIN
	declare @CurrentBalance money
	
	SELECT  @CurrentBalance = SUM(tbOrgAccount.CurrentBalance)
	FROM         tbOrgAccount INNER JOIN
	                      tbCashCode ON tbOrgAccount.CashCode = tbCashCode.CashCode
	WHERE     (tbOrgAccount.AccountClosed = 0)
	
	RETURN isnull(@CurrentBalance, 0)
	END
GO
CREATE FUNCTION [dbo].[fnCashReserveBalance]
	()
RETURNS money
AS
	BEGIN
	declare @CurrentBalance money
	
	SELECT    @CurrentBalance = SUM(tbOrgAccount.CurrentBalance)
	FROM         tbOrgAccount LEFT OUTER JOIN
	                      tbCashCode ON tbOrgAccount.CashCode = tbCashCode.CashCode
	WHERE     (tbOrgAccount.AccountClosed = 0) AND (tbCashCode.CashCode IS NULL)
	
	RETURN isnull(@CurrentBalance, 0)
	END
GO
CREATE FUNCTION [dbo].[fnTaskIsExpense]
	(
	@TaskCode nvarchar(20)
	)
RETURNS bit
AS
	BEGIN
	DECLARE @IsExpense bit
	IF EXISTS (SELECT     tbTask.TaskCode
	           FROM         tbTask INNER JOIN
	                                 tbCashCode ON tbTask.CashCode = tbCashCode.CashCode INNER JOIN
	                                 tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	           WHERE     (tbCashCategory.CashModeCode = 2) AND (tbTask.TaskCode = @TaskCode))
		SET @IsExpense = 0			          
	ELSE IF EXISTS(SELECT     ParentTaskCode
	          FROM         tbTaskFlow
	          WHERE     (ChildTaskCode = @TaskCode))
		BEGIN
		DECLARE @ParentTaskCode nvarchar(20)
		SELECT  @ParentTaskCode = ParentTaskCode
		FROM         tbTaskFlow
		WHERE     (ChildTaskCode = @TaskCode)		
		SET @IsExpense = dbo.fnTaskIsExpense(@ParentTaskCode)		
		END	              
	ELSE
		SET @IsExpense = 1
			
	RETURN @IsExpense
	END
GO
CREATE FUNCTION [dbo].[fnTaskEmailAddress]
	(
	@TaskCode nvarchar(20)
	)
RETURNS nvarchar(255)
AS
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
CREATE FUNCTION [dbo].[fnCashAccountStatement]
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
/****** Object:  UserDefinedFunction [dbo].[fnTaxVatTotals]    Script Date: 01/11/2012 16:40:04 ******/
GO
CREATE FUNCTION [dbo].[fnTaxVatTotals]
	()
RETURNS @tbVat TABLE 
	(
	StartOn datetime, 
	HomeSales money,
	HomePurchases money,
	ExportSales money,
	ExportPurchases money,
	HomeSalesVat money,
	HomePurchasesVat money,
	ExportSalesVat money,
	ExportPurchasesVat money,
	VatAdjustment money,
	VatDue money
	)
AS
	BEGIN
	declare @PayOn datetime
	declare @PayFrom datetime
	declare @PayTo datetime
	
	declare curVat cursor local for
		SELECT     PayOn, PayFrom, PayTo
		FROM         fnTaxTypeDueDates(2) fnTaxTypeDueDates
		
	open curVat
	fetch next from curVat into @PayOn, @PayFrom, @PayTo
	while (@@FETCH_STATUS = 0)
		begin
		INSERT INTO @tbVat (StartOn, HomeSales, HomePurchases, ExportSales, ExportPurchases, HomeSalesVat, HomePurchasesVat, ExportSalesVat, ExportPurchasesVat)
		SELECT     @PayOn AS PayOn, ISNULL(SUM(HomeSales), 0) AS HomeSales, ISNULL(SUM(HomePurchases), 0) AS HomePurchases, ISNULL(SUM(ExportSales), 0) AS ExportSales, 
		                      ISNULL(SUM(ExportPurchases), 0) AS ExportPurchases, ISNULL(SUM(HomeSalesVat), 0) AS HomeSalesVat, ISNULL(SUM(HomePurchasesVat), 0) AS HomePurchasesVat, 
		                      ISNULL(SUM(ExportSalesVat), 0) AS ExportSalesVat, ISNULL(SUM(ExportPurchasesVat), 0) AS ExportPurchasesVat
		FROM         vwInvoiceVatSummary
		WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
		
		fetch next from curVat into @PayOn, @PayFrom, @PayTo
		end
	
	close curVat
	deallocate curVat

	UPDATE @tbVat
	SET VatAdjustment = tbSystemYearPeriod.VatAdjustment
	FROM @tbVat AS tb INNER JOIN
	                      tbSystemYearPeriod ON tb.StartOn = tbSystemYearPeriod.StartOn
	
	update @tbVat
	set VatDue = (HomeSalesVat + ExportSalesVat) - (HomePurchasesVat + ExportPurchasesVat) + VatAdjustment
	
	RETURN
	END
GO
CREATE FUNCTION [dbo].[fnTaxVatStatement]
	()
RETURNS @tbVat TABLE 
	(
	StartOn datetime, 
	VatDue money ,
	VatPaid money ,
	Balance money
	)
AS
	BEGIN
	declare @Balance money
	declare @StartOn datetime
	declare @VatDue money
	declare @VatPaid money
	
	INSERT INTO @tbVat (StartOn, VatDue, VatPaid, Balance)
	SELECT     StartOn, VatDue, 0 As VatPaid, 0 AS Balance
	FROM         fnTaxVatTotals() fnTaxVatTotals	
	
	INSERT INTO @tbVat (StartOn, VatDue, VatPaid, Balance)
	SELECT     tbOrgPayment.PaidOn, 0 As VatDue, (tbOrgPayment.PaidOutValue * -1) + tbOrgPayment.PaidInValue AS VatPaid, 0 As Balance
	FROM         tbOrgPayment INNER JOIN
	                      vwSystemVatCashCode ON tbOrgPayment.CashCode = vwSystemVatCashCode.CashCode	                      

	set @Balance = 0
	
	DECLARE curVS CURSOR LOCAL FOR
		SELECT StartOn, VatDue, VatPaid
		FROM @tbVat
		ORDER BY StartOn, VatDue
	
	OPEN curVS
	FETCH NEXT FROM curVS INTO @StartOn, @VatDue, @VatPaid
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
		set @Balance = @Balance + @VatDue + @VatPaid
		UPDATE @tbVat
		SET Balance = @Balance
		WHERE StartOn = @StartOn AND VatDue = @VatDue 
		FETCH NEXT FROM curVS INTO @StartOn, @VatDue, @VatPaid
		END
	
	CLOSE curVS
	DEALLOCATE curVS	
	RETURN
	END
GO
CREATE FUNCTION [dbo].[fnOrgIndustrySectors]
	(
	@AccountCode nvarchar(10)
	)
RETURNS nvarchar(256)
AS
	BEGIN
	declare @IndustrySector nvarchar(256)
	
	if exists(select IndustrySector from tbOrgSector where AccountCode = @AccountCode)
		begin
		declare @Sector nvarchar(50)
		set @IndustrySector = ''
		declare cur cursor local for
			select IndustrySector from tbOrgSector where AccountCode = @AccountCode
		open cur
		fetch next from cur into @Sector
		while @@FETCH_STATUS = 0
			begin
			if len(@IndustrySector) = 0
				set @IndustrySector = @Sector
			else if len(@IndustrySector) <= 200
				set @IndustrySector = @IndustrySector + ', ' + @Sector
			
			fetch next from cur into @Sector
			end
			
		close cur
		deallocate cur
		
		end	
	
	RETURN @IndustrySector
	END
GO
CREATE FUNCTION [dbo].[fnSystemBuckets]
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
CREATE FUNCTION [dbo].[fnCashAccountStatements]
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
CREATE FUNCTION [dbo].[fnTaxCorpStatement]
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
	SELECT     StartOn, CorporationTax, 0 As TaxPaid, 0 AS Balance
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
CREATE  FUNCTION [dbo].[fnSystemVatBalance]
	()
RETURNS money
AS
	BEGIN
	declare @Balance money
	SELECT  @Balance = SUM(HomeSalesVat - HomePurchasesVat + ExportSalesVat - ExportPurchasesVat)
	FROM         vwInvoiceVatSummary
	
	SELECT  @Balance = @Balance + ISNULL(SUM(tbOrgPayment.PaidInValue - tbOrgPayment.PaidOutValue), 0)
	FROM         tbOrgPayment INNER JOIN
	                      vwSystemVatCashCode ON tbOrgPayment.CashCode = vwSystemVatCashCode.CashCode	                      

	SELECT @Balance = @Balance + SUM(VatAdjustment)
	FROM tbSystemYearPeriod

	RETURN isnull(@Balance, 0)
	END
GO
CREATE FUNCTION [dbo].[fnSystemActiveStartOn]
	()
RETURNS datetime
AS
	BEGIN
	declare @StartOn datetime
	select @StartOn = StartOn from dbo.fnSystemActivePeriod()
	RETURN @StartOn
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
CREATE FUNCTION [dbo].[fnSystemCorpTaxBalance]
	()
RETURNS money
AS
	BEGIN
	declare @Balance money
	SELECT  @Balance = SUM(CorporationTax)
	FROM         vwCorpTaxInvoice
	
	SELECT  @Balance = @Balance + ISNULL(SUM(tbOrgPayment.PaidInValue - tbOrgPayment.PaidOutValue), 0)
	FROM         tbOrgPayment INNER JOIN
	                      vwSystemCorpTaxCashCode ON tbOrgPayment.CashCode = vwSystemCorpTaxCashCode.CashCode	                      

	IF @Balance < 0
		SET @Balance = 0
		
	RETURN isnull(@Balance, 0)
	END
GO
CREATE FUNCTION [dbo].[fnStatementReserves] ()
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

	select @ReferenceCode = dbo.fnSystemProfileText(1219)
	set @Balance = dbo.fnCashReserveBalance()	
	SELECT @TransactOn = MAX(tbOrgPayment.PaidOn)
	FROM         tbOrgAccount INNER JOIN
						  tbOrgPayment ON tbOrgAccount.CashAccountCode = tbOrgPayment.CashAccountCode LEFT OUTER JOIN
						  tbCashCode ON tbOrgAccount.CashCode = tbCashCode.CashCode
	WHERE     (tbCashCode.CashCode IS NULL)

	SELECT TOP 1 @AccountCode = AccountCode FROM tbSystemOptions
	
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, Balance)
	VALUES (@ReferenceCode, @AccountCode, @TransactOn, 1, 0, 0, @Balance)
	
		set @ReferenceCode = dbo.fnSystemProfileText(1214)	
	SET @TransactOn = DATEADD(d, dbo.fnSystemTaxHorizon(), @TransactOn)
	SELECT @PayOut = dbo.fnSystemCorpTaxBalance()
	SET @CashCode = dbo.fnSystemCashCode(1)
	INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
	VALUES (@ReferenceCode, @AccountCode, @TransactOn, 5, 0, @PayOut, @CashCode)

	set @ReferenceCode2 = dbo.fnSystemProfileText(1215)	
	SET @TransactOn = DATEADD(n, 1, @TransactOn)
	SELECT @PayOut = SUM(CorporationTax)
	FROM         vwCorpTaxConfirmed
	IF @PayOut > 0
		BEGIN
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
		VALUES (@ReferenceCode2, @AccountCode, @TransactOn, 5, 0, @PayOut, @CashCode)
		END	
	
	SET @TransactOn = DATEADD(n, 1, @TransactOn)
	SELECT @PayOut = dbo.fnSystemVatBalance()
	IF @PayOut <> 0
		BEGIN
		IF @PayOut < 0
			BEGIN
			SET @PayIn = ABS(@PayOut)
			SET @PayOut = 0
			END
		ELSE
			SET @PayIn = 0
		SET @CashCode = dbo.fnSystemCashCode(2)
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
		VALUES (@ReferenceCode, @AccountCode, @TransactOn, 6, @PayIn, @PayOut, @CashCode)
		END
		
	SET @TransactOn = DATEADD(n, 1, @TransactOn)
	SELECT @PayOut = SUM(VatValue)
	FROM         vwTaskVatConfirmed
	IF @PayOut <> 0
		BEGIN
		IF @PayOut < 0
			BEGIN
			SET @PayIn = ABS(@PayOut)
			SET @PayOut = 0
			END
		ELSE
			SET @PayIn = 0
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)
		VALUES (@ReferenceCode2, @AccountCode, @TransactOn, 6, @PayIn, @PayOut, @CashCode)
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
CREATE VIEW [dbo].[vwInvoiceSummaryBase]
AS
SELECT     StartOn, InvoiceTypeCode, InvoiceValue, TaxValue
FROM         dbo.vwInvoiceSummaryItems
UNION
SELECT     StartOn, InvoiceTypeCode, InvoiceValue, TaxValue
FROM         dbo.vwInvoiceSummaryTasks
GO
CREATE VIEW [dbo].[vwInvoiceSummaryTotals]
AS
SELECT     dbo.vwInvoiceSummaryBase.StartOn, dbo.vwInvoiceSummaryBase.InvoiceTypeCode, dbo.tbInvoiceType.InvoiceType, 
                      SUM(dbo.vwInvoiceSummaryBase.InvoiceValue) AS TotalInvoiceValue, SUM(dbo.vwInvoiceSummaryBase.TaxValue) AS TotalTaxValue
FROM         dbo.vwInvoiceSummaryBase INNER JOIN
                      dbo.tbInvoiceType ON dbo.vwInvoiceSummaryBase.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
GROUP BY dbo.vwInvoiceSummaryBase.StartOn, dbo.vwInvoiceSummaryBase.InvoiceTypeCode, dbo.tbInvoiceType.InvoiceType
GO
CREATE VIEW [dbo].[vwOrgRebuildInvoicedItems]
AS
SELECT     dbo.tbInvoice.AccountCode, dbo.tbInvoiceType.CashModeCode, dbo.tbInvoice.CollectOn, dbo.tbInvoiceItem.InvoiceNumber, 
                      dbo.tbInvoiceItem.CashCode, '' AS TaskCode, dbo.tbInvoiceItem.InvoiceValue, dbo.tbInvoiceItem.TaxValue, dbo.tbInvoiceItem.PaidValue, 
                      dbo.tbInvoiceItem.PaidTaxValue
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
GO
CREATE VIEW [dbo].[vwOrgRebuildInvoicedTasks]
AS
SELECT     dbo.tbInvoice.AccountCode, dbo.tbInvoiceType.CashModeCode, dbo.tbInvoice.CollectOn, dbo.tbInvoiceTask.InvoiceNumber, 
                      dbo.tbInvoiceTask.CashCode, dbo.tbInvoiceTask.TaskCode, dbo.tbInvoiceTask.InvoiceValue, dbo.tbInvoiceTask.TaxValue, 
                      dbo.tbInvoiceTask.PaidValue, dbo.tbInvoiceTask.PaidTaxValue
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
GO
CREATE VIEW [dbo].[vwOrgRebuildInvoices]
AS
SELECT     AccountCode, CashModeCode, CollectOn, InvoiceNumber, CashCode, TaskCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
FROM         dbo.vwOrgRebuildInvoicedTasks
UNION
SELECT     AccountCode, CashModeCode, CollectOn, InvoiceNumber, CashCode, TaskCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
FROM         dbo.vwOrgRebuildInvoicedItems
GO
CREATE VIEW [dbo].[vwOrgRebuildInvoiceTotals]
AS
SELECT     AccountCode, InvoiceNumber, SUM(InvoiceValue) AS TotalInvoiceValue, SUM(TaxValue) AS TotalTaxValue, SUM(PaidValue) AS TotalPaidValue, 
                      SUM(PaidTaxValue) AS TotalPaidTaxValue
FROM         dbo.vwOrgRebuildInvoices
GROUP BY AccountCode, InvoiceNumber
GO
CREATE VIEW [dbo].[vwInvoiceRegisterItems]
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
CREATE VIEW [dbo].[vwInvoiceRegisterTasks]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoice.InvoiceNumber, dbo.tbInvoiceTask.TaskCode, dbo.tbTask.TaskTitle, 
                      dbo.tbCashCode.CashCode, dbo.tbCashCode.CashDescription, dbo.tbInvoiceTask.TaxCode, dbo.tbSystemTaxCode.TaxDescription, 
                      dbo.tbInvoice.AccountCode, dbo.tbInvoice.InvoiceTypeCode, dbo.tbInvoice.InvoiceStatusCode, dbo.tbInvoice.InvoicedOn, 
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
                      dbo.tbCashCode ON dbo.tbInvoiceTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbTask ON dbo.tbInvoiceTask.TaskCode = dbo.tbTask.TaskCode AND dbo.tbInvoiceTask.TaskCode = dbo.tbTask.TaskCode LEFT OUTER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbInvoiceTask.TaxCode = dbo.tbSystemTaxCode.TaxCode
GO
CREATE VIEW [dbo].[vwInvoiceRegisterDetail]
AS
SELECT     StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, 
                      InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, 
                      InvoiceType
FROM         dbo.vwInvoiceRegisterTasks
UNION
SELECT     StartOn, InvoiceNumber, TaskCode, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, InvoiceStatusCode, 
                      InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, CashModeCode, 
                      InvoiceType
FROM         dbo.vwInvoiceRegisterItems
GO
CREATE VIEW [dbo].[vwCashCodeInvoiceSummary]
AS
SELECT     CashCode, StartOn, ABS(SUM(InvoiceValue)) AS InvoiceValue, ABS(SUM(TaxValue)) AS TaxValue
FROM         dbo.vwInvoiceRegisterDetail
GROUP BY StartOn, CashCode
GO
CREATE VIEW [dbo].[vwOrgTaskCount]
AS
SELECT     AccountCode, COUNT(TaskCode) AS TaskCount
FROM         dbo.tbTask
WHERE     (TaskStatusCode < 3)
GROUP BY AccountCode
GO
CREATE VIEW [dbo].[vwStatementVatDueDate]
AS
SELECT     TOP 1 PayOn
FROM         dbo.fnTaxTypeDueDates(2) fnTaxTypeDueDates
WHERE     (PayOn > GETDATE())
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
CREATE VIEW [dbo].[vwCashAccountStatement]
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
CREATE VIEW [dbo].[vwTaskProfit]
AS
SELECT     TOP (100) PERCENT fnTaskProfit_1.StartOn, dbo.tbOrg.AccountCode, dbo.tbTask.TaskCode, dbo.tbTask.ActivityCode, dbo.tbCashCode.CashCode, 
                      dbo.tbTask.TaskTitle, dbo.tbOrg.AccountName, dbo.tbCashCode.CashDescription, dbo.tbTaskStatus.TaskStatus, fnTaskProfit_1.TotalCharge, 
                      fnTaskProfit_1.InvoicedCharge, fnTaskProfit_1.InvoicedChargePaid, fnTaskProfit_1.TotalCost, fnTaskProfit_1.InvoicedCost, 
                      fnTaskProfit_1.InvoicedCostPaid, fnTaskProfit_1.TotalCharge - fnTaskProfit_1.TotalCost AS Profit, 
                      fnTaskProfit_1.TotalCharge - fnTaskProfit_1.InvoicedCharge AS UninvoicedCharge, 
                      fnTaskProfit_1.InvoicedCharge - fnTaskProfit_1.InvoicedChargePaid AS UnpaidCharge, 
                      fnTaskProfit_1.TotalCost - fnTaskProfit_1.InvoicedCost AS UninvoicedCost, 
                      fnTaskProfit_1.InvoicedCost - fnTaskProfit_1.InvoicedCostPaid AS UnpaidCost, dbo.tbTask.ActionOn, dbo.tbTask.ActionedOn, 
                      dbo.tbTask.PaymentOn
FROM         dbo.tbTask INNER JOIN
                      dbo.fnTaskProfit() AS fnTaskProfit_1 ON dbo.tbTask.TaskCode = fnTaskProfit_1.TaskCode INNER JOIN
                      dbo.tbTaskStatus ON dbo.tbTask.TaskStatusCode = dbo.tbTaskStatus.TaskStatusCode INNER JOIN
                      dbo.tbOrg ON dbo.tbTask.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode
WHERE     (dbo.tbCashCategory.CashModeCode = 2)
ORDER BY fnTaskProfit_1.StartOn
GO
CREATE VIEW [dbo].[vwDocInvoiceItem]
AS
SELECT     dbo.tbInvoiceItem.InvoiceNumber, dbo.tbInvoiceItem.CashCode, dbo.tbCashCode.CashDescription, dbo.tbInvoice.InvoicedOn AS ActionedOn, 
                      dbo.tbInvoiceItem.TaxCode, dbo.tbInvoiceItem.InvoiceValue, dbo.tbInvoiceItem.TaxValue, dbo.tbInvoiceItem.ItemReference
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.tbCashCode ON dbo.tbInvoiceItem.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber
GO
CREATE VIEW [dbo].[vwStatement]
AS
SELECT     TOP (100) PERCENT fnStatementCompany.TransactOn, fnStatementCompany.CashEntryTypeCode, fnStatementCompany.ReferenceCode, 
                      fnStatementCompany.AccountCode, dbo.tbOrg.AccountName, dbo.tbCashEntryType.CashEntryType, fnStatementCompany.PayOut, 
                      fnStatementCompany.PayIn, fnStatementCompany.Balance, dbo.tbCashCode.CashCode, dbo.tbCashCode.CashDescription
FROM         dbo.fnStatementCompany() AS fnStatementCompany INNER JOIN
                      dbo.tbCashEntryType ON fnStatementCompany.CashEntryTypeCode = dbo.tbCashEntryType.CashEntryTypeCode INNER JOIN
                      dbo.tbOrg ON fnStatementCompany.AccountCode = dbo.tbOrg.AccountCode LEFT OUTER JOIN
                      dbo.tbCashCode ON fnStatementCompany.CashCode = dbo.tbCashCode.CashCode
ORDER BY fnStatementCompany.TransactOn, fnStatementCompany.CashEntryTypeCode, fnStatementCompany.ReferenceCode, fnStatementCompany.CashCode
GO
CREATE VIEW [dbo].[vwDocInvoiceTask]
AS
SELECT     dbo.tbInvoiceTask.InvoiceNumber, dbo.tbInvoiceTask.TaskCode, dbo.tbTask.TaskTitle, dbo.tbTask.ActivityCode, dbo.tbInvoiceTask.CashCode, 
                      dbo.tbCashCode.CashDescription, dbo.tbTask.ActionedOn, dbo.tbInvoiceTask.Quantity, dbo.tbActivity.UnitOfMeasure, dbo.tbInvoiceTask.InvoiceValue, 
                      dbo.tbInvoiceTask.TaxValue, dbo.tbInvoiceTask.TaxCode, dbo.tbTask.SecondReference
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbTask ON dbo.tbInvoiceTask.TaskCode = dbo.tbTask.TaskCode AND dbo.tbInvoiceTask.TaskCode = dbo.tbTask.TaskCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbInvoiceTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbActivity ON dbo.tbTask.ActivityCode = dbo.tbActivity.ActivityCode
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
CREATE VIEW [dbo].[vwCashFlowVatTotalsBase]
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
CREATE VIEW [dbo].[vwCashFlowNITotals]
AS
SELECT     dbo.tbCashPeriod.StartOn, SUM(dbo.tbCashPeriod.ForecastTax) AS ForecastNI, SUM(dbo.tbCashPeriod.CashTax) AS CashNI, 
                      SUM(dbo.tbCashPeriod.InvoiceTax) AS InvoiceNI
FROM         dbo.tbCashPeriod INNER JOIN
                      dbo.tbCashCode ON dbo.tbCashPeriod.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbCashCode.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 3)
GROUP BY dbo.tbCashPeriod.StartOn
GO
CREATE VIEW [dbo].[vwCashPeriods]
AS
SELECT     dbo.tbCashCode.CashCode, dbo.tbSystemYearPeriod.StartOn
FROM         dbo.tbSystemYearPeriod CROSS JOIN
                      dbo.tbCashCode
GO
CREATE VIEW [dbo].[vwCashActiveYears]
AS
SELECT     TOP 100 PERCENT dbo.tbSystemYear.YearNumber, dbo.tbSystemYear.Description, dbo.tbCashStatus.CashStatus
FROM         dbo.tbSystemYear INNER JOIN
                      dbo.tbCashStatus ON dbo.tbSystemYear.CashStatusCode = dbo.tbCashStatus.CashStatusCode
WHERE     (dbo.tbSystemYear.CashStatusCode < 4)
ORDER BY dbo.tbSystemYear.YearNumber
GO
CREATE VIEW [dbo].[vwSystemNICashCode]
AS
SELECT     CashCode, MonthNumber, RecurrenceCode
FROM         dbo.tbCashTaxType
WHERE     (TaxTypeCode = 3)
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
CREATE VIEW [dbo].[vwDocInvoice]
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
CREATE VIEW [dbo].[vwCashSummaryInvoices]
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
CREATE VIEW [dbo].[vwAccountStatementInvoices]
AS
SELECT     TOP 100 PERCENT dbo.tbInvoice.AccountCode, dbo.tbInvoice.InvoicedOn AS TransactedOn, 1 AS OrderBy, dbo.tbInvoice.InvoiceNumber AS Reference, 
                      dbo.tbInvoiceType.InvoiceType AS StatementType, 
                      CASE CashModeCode WHEN 1 THEN dbo.tbInvoice.InvoiceValue + dbo.tbInvoice.TaxValue WHEN 2 THEN (dbo.tbInvoice.InvoiceValue + dbo.tbInvoice.TaxValue)
                       * - 1 END AS Charge
FROM         dbo.tbInvoice INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
ORDER BY dbo.tbInvoice.AccountCode, dbo.tbInvoice.InvoicedOn
GO
CREATE VIEW [dbo].[vwInvoiceOutstandingItems]
AS
SELECT     InvoiceNumber, '' AS TaskCode, CashCode, TaxCode, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS OutstandingValue, 
                      CASE WHEN InvoiceValue = 0 THEN 0 ELSE TaxValue / InvoiceValue END AS TaxRate
FROM         dbo.tbInvoiceItem
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
CREATE VIEW [dbo].[vwInvoiceOutstandingTasks]
AS
SELECT     InvoiceNumber, TaskCode, CashCode, TaxCode, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS OutstandingValue, 
                      CASE WHEN InvoiceValue = 0 THEN 0 ELSE TaxValue / InvoiceValue END AS TaxRate
FROM         dbo.tbInvoiceTask
GO
CREATE VIEW [dbo].[vwOrgMailContacts]
AS
SELECT     AccountCode, ContactName, NickName, NameTitle + N' ' + ContactName AS FormalName, JobTitle, Department
FROM         dbo.tbOrgContact
WHERE     (OnMailingList <> 0)
GO
CREATE VIEW [dbo].[vwDocCompany]
AS
SELECT     dbo.tbOrg.AccountName AS CompanyName, dbo.tbOrgAddress.Address AS CompanyAddress, dbo.tbOrg.PhoneNumber AS CompanyPhoneNumber, 
                      dbo.tbOrg.FaxNumber AS CompanyFaxNumber, dbo.tbOrg.EmailAddress AS CompanyEmailAddress, dbo.tbOrg.WebSite AS CompanyWebsite, 
                      dbo.tbOrg.CompanyNumber, dbo.tbOrg.VatNumber, dbo.tbOrg.Logo
FROM         dbo.tbOrg INNER JOIN
                      dbo.tbSystemOptions ON dbo.tbOrg.AccountCode = dbo.tbSystemOptions.AccountCode LEFT OUTER JOIN
                      dbo.tbOrgAddress ON dbo.tbOrg.AddressCode = dbo.tbOrgAddress.AddressCode
GO
CREATE VIEW [dbo].[vwCashAccountRebuild]
AS
SELECT     dbo.tbOrgPayment.CashAccountCode, dbo.tbOrgAccount.OpeningBalance, 
                      dbo.tbOrgAccount.OpeningBalance + SUM(dbo.tbOrgPayment.PaidInValue - dbo.tbOrgPayment.PaidOutValue) AS CurrentBalance
FROM         dbo.tbOrgPayment INNER JOIN
                      dbo.tbOrgAccount ON dbo.tbOrgPayment.CashAccountCode = dbo.tbOrgAccount.CashAccountCode
WHERE     (dbo.tbOrgPayment.PaymentStatusCode > 1)
GROUP BY dbo.tbOrgPayment.CashAccountCode, dbo.tbOrgAccount.OpeningBalance
GO
CREATE VIEW [dbo].[vwAccountStatementPayments]
AS
SELECT     TOP 100 PERCENT dbo.tbOrgPayment.AccountCode, dbo.tbOrgPayment.PaidOn AS TransactedOn, 2 AS OrderBy, 
                      dbo.tbOrgPayment.PaymentReference AS Reference, dbo.tbOrgPaymentStatus.PaymentStatus AS StatementType, 
                      CASE WHEN PaidInValue > 0 THEN PaidInValue ELSE PaidOutValue * - 1 END AS Charge
FROM         dbo.tbOrgPayment INNER JOIN
                      dbo.tbOrgPaymentStatus ON dbo.tbOrgPayment.PaymentStatusCode = dbo.tbOrgPaymentStatus.PaymentStatusCode
ORDER BY dbo.tbOrgPayment.AccountCode, dbo.tbOrgPayment.PaidOn
GO
CREATE VIEW [dbo].[vwTaxVatTotals]
AS
SELECT     TOP (100) PERCENT dbo.tbSystemYear.YearNumber, dbo.tbSystemYear.Description, dbo.tbSystemMonth.MonthName, fnTaxVatTotals.StartOn, 
                      fnTaxVatTotals.HomeSales, fnTaxVatTotals.HomePurchases, fnTaxVatTotals.ExportSales, fnTaxVatTotals.ExportPurchases, 
                      fnTaxVatTotals.HomeSalesVat, fnTaxVatTotals.HomePurchasesVat, fnTaxVatTotals.ExportSalesVat, fnTaxVatTotals.ExportPurchasesVat, 
                      fnTaxVatTotals.VatAdjustment, fnTaxVatTotals.VatDue
FROM         dbo.fnTaxVatTotals() AS fnTaxVatTotals INNER JOIN
                      dbo.tbSystemYearPeriod ON fnTaxVatTotals.StartOn = dbo.tbSystemYearPeriod.StartOn INNER JOIN
                      dbo.tbSystemMonth ON dbo.tbSystemYearPeriod.MonthNumber = dbo.tbSystemMonth.MonthNumber INNER JOIN
                      dbo.tbSystemYear ON dbo.tbSystemYearPeriod.YearNumber = dbo.tbSystemYear.YearNumber
ORDER BY fnTaxVatTotals.StartOn
GO
CREATE VIEW [dbo].[vwTaxCorpTotals]
AS
SELECT     TOP (100) PERCENT dbo.vwCorpTaxInvoice.StartOn, YEAR(dbo.tbSystemYearPeriod.StartOn) AS PeriodYear, dbo.tbSystemYear.Description, 
                      dbo.tbSystemMonth.MonthName, SUM(dbo.vwCorpTaxInvoice.NetProfit) AS NetProfit, SUM(dbo.vwCorpTaxInvoice.CorporationTax) 
                      AS CorporationTax
FROM         dbo.vwCorpTaxInvoice INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.vwCorpTaxInvoice.StartOn = dbo.tbSystemYearPeriod.StartOn INNER JOIN
                      dbo.tbSystemYear ON dbo.tbSystemYearPeriod.YearNumber = dbo.tbSystemYear.YearNumber INNER JOIN
                      dbo.tbSystemMonth ON dbo.tbSystemYearPeriod.MonthNumber = dbo.tbSystemMonth.MonthNumber
GROUP BY dbo.tbSystemYear.Description, dbo.tbSystemMonth.MonthName, dbo.vwCorpTaxInvoice.StartOn, YEAR(dbo.tbSystemYearPeriod.StartOn)
ORDER BY dbo.vwCorpTaxInvoice.StartOn
GO
CREATE VIEW [dbo].[vwUserCredentials]
AS
SELECT     UserId, UserName, LogonName, Administrator
FROM         dbo.tbUser
WHERE     (LogonName = SUSER_SNAME())
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
CREATE VIEW [dbo].[vwStatementTasksFull]
AS
SELECT     TOP (100) PERCENT dbo.tbTask.TaskCode AS ReferenceCode, dbo.tbTask.AccountCode, dbo.tbTask.ActionOn, dbo.tbTask.PaymentOn, 
                      CASE WHEN tbTask.TaskStatusCode = 1 THEN 4 ELSE 3 END AS CashEntryTypeCode, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.vwSystemTaxRates.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayOut, 
                      CASE WHEN tbCashCategory.CashModeCode = 2 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.vwSystemTaxRates.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayIn, dbo.tbCashCode.CashCode
FROM         dbo.vwSystemTaxRates INNER JOIN
                      dbo.tbTask ON dbo.vwSystemTaxRates.TaxCode = dbo.tbTask.TaxCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.tbTask.TaskStatusCode < 4) AND (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0) > 0)
GO
CREATE VIEW [dbo].[vwStatementTasksConfirmed]
AS
SELECT     TOP (100) PERCENT dbo.tbTask.TaskCode AS ReferenceCode, dbo.tbTask.AccountCode, dbo.tbTask.ActionOn, dbo.tbTask.PaymentOn, 
                      3 AS CashEntryTypeCode, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.vwSystemTaxRates.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayOut, 
                      CASE WHEN tbCashCategory.CashModeCode = 2 THEN (dbo.tbTask.UnitCharge + dbo.tbTask.UnitCharge * dbo.vwSystemTaxRates.TaxRate) 
                      * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) ELSE 0 END AS PayIn, dbo.tbCashCode.CashCode
FROM         dbo.vwSystemTaxRates INNER JOIN
                      dbo.tbTask ON dbo.vwSystemTaxRates.TaxCode = dbo.tbTask.TaxCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.tbTask.TaskStatusCode > 1) AND (dbo.tbTask.TaskStatusCode < 4) AND 
                      (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0) > 0)
GO
CREATE VIEW [dbo].[vwTaskVatFull]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * vwSystemTaxRates.TaxRate ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) 
                      * vwSystemTaxRates.TaxRate * - 1 END AS VatValue
FROM         dbo.tbTask INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode INNER JOIN
                      dbo.vwSystemTaxRates ON dbo.tbTask.TaxCode = dbo.vwSystemTaxRates.TaxCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.vwSystemTaxRates.TaxTypeCode = 2) AND (dbo.tbTask.TaskStatusCode < 4) AND 
                      (CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * vwSystemTaxRates.TaxRate ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) 
                      * vwSystemTaxRates.TaxRate * - 1 END <> 0)
GO
CREATE VIEW [dbo].[vwCashFlowForecastData]
AS
SELECT     dbo.vwCashPolarData.CashCode, dbo.vwCashPolarData.CashTypeCode, dbo.vwCashPolarData.StartOn, dbo.vwCashPolarData.ForecastValue, 
                      dbo.vwCashPolarData.ForecastTax
FROM         dbo.vwCashPolarData INNER JOIN
                      dbo.fnSystemActivePeriod() fnSystemActivePeriod ON dbo.vwCashPolarData.StartOn >= fnSystemActivePeriod.StartOn
GO
CREATE VIEW [dbo].[vwCashFlowActualData]
AS
SELECT     dbo.vwCashPolarData.CashCode, dbo.vwCashPolarData.CashTypeCode, dbo.vwCashPolarData.StartOn, dbo.vwCashPolarData.CashValue, 
                      dbo.vwCashPolarData.CashTax, dbo.vwCashPolarData.InvoiceValue, dbo.vwCashPolarData.InvoiceTax, dbo.vwCashPolarData.ForecastValue, 
                      dbo.vwCashPolarData.ForecastTax
FROM         dbo.vwCashPolarData INNER JOIN
                      dbo.fnSystemActivePeriod() fnSystemActivePeriod ON dbo.vwCashPolarData.StartOn < fnSystemActivePeriod.StartOn
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
CREATE VIEW [dbo].[vwCashFlowVatTotals]
AS
SELECT     StartOn, SUM(ForecastVat) AS ForecastVat, SUM(CashVat) AS CashVat, SUM(InvoiceVat) AS InvoiceVat
FROM         dbo.vwCashFlowVatTotalsBase
GROUP BY StartOn
GO
CREATE VIEW [dbo].[vwDocTaskCode]
AS
SELECT     dbo.fnTaskEmailAddress(dbo.tbTask.TaskCode) AS EmailAddress, dbo.tbTask.TaskCode, dbo.tbTask.TaskStatusCode, dbo.tbTaskStatus.TaskStatus, 
                      dbo.tbTask.ContactName, dbo.tbOrgContact.NickName, dbo.tbUser.UserName, dbo.tbOrg.AccountName, dbo.tbOrgAddress.Address AS InvoiceAddress, 
                      tbOrg_1.AccountName AS DeliveryAccountName, tbOrgAddress_1.Address AS DeliveryAddress, tbOrg_2.AccountName AS CollectionAccountName, 
                      tbOrgAddress_2.Address AS CollectionAddress, dbo.tbTask.AccountCode, dbo.tbTask.TaskNotes, dbo.tbTask.ActivityCode, dbo.tbTask.ActionOn, 
                      dbo.tbActivity.UnitOfMeasure, dbo.tbTask.Quantity, dbo.tbSystemTaxCode.TaxCode, dbo.tbSystemTaxCode.TaxRate, dbo.tbTask.UnitCharge, 
                      dbo.tbTask.TotalCharge, dbo.tbUser.MobileNumber, dbo.tbUser.Signature, dbo.tbTask.TaskTitle, dbo.tbTask.PaymentOn, 
                      dbo.tbTask.SecondReference
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
CREATE VIEW [dbo].[vwOrgAddresses]
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
CREATE VIEW [dbo].[vwOrgDatasheet]
AS
SELECT     dbo.tbOrg.AccountCode, dbo.tbOrg.AccountName, ISNULL(dbo.vwOrgTaskCount.TaskCount, 0) AS Tasks, dbo.tbOrg.OrganisationTypeCode, 
                      dbo.tbOrgType.OrganisationType, dbo.tbOrgType.CashModeCode, dbo.tbOrg.OrganisationStatusCode, dbo.tbOrgStatus.OrganisationStatus, 
                      dbo.tbOrgAddress.Address, dbo.tbSystemTaxCode.TaxDescription, dbo.tbOrg.TaxCode, dbo.tbOrg.AddressCode, dbo.tbOrg.AreaCode, 
                      dbo.tbOrg.PhoneNumber, dbo.tbOrg.FaxNumber, dbo.tbOrg.EmailAddress, dbo.tbOrg.WebSite, dbo.fnOrgIndustrySectors(dbo.tbOrg.AccountCode) 
                      AS IndustrySector, dbo.tbOrg.AccountSource, dbo.tbOrg.PaymentTerms, dbo.tbOrg.PaymentDays, dbo.tbOrg.NumberOfEmployees, 
                      dbo.tbOrg.CompanyNumber, dbo.tbOrg.VatNumber, dbo.tbOrg.Turnover, dbo.tbOrg.StatementDays, dbo.tbOrg.OpeningBalance, 
                      dbo.tbOrg.CurrentBalance, dbo.tbOrg.ForeignJurisdiction, dbo.tbOrg.BusinessDescription, dbo.tbOrg.InsertedBy, dbo.tbOrg.InsertedOn, 
                      dbo.tbOrg.UpdatedBy, dbo.tbOrg.UpdatedOn, dbo.tbOrg.PayDaysFromMonthEnd
FROM         dbo.tbOrg INNER JOIN
                      dbo.tbOrgStatus ON dbo.tbOrg.OrganisationStatusCode = dbo.tbOrgStatus.OrganisationStatusCode INNER JOIN
                      dbo.tbOrgType ON dbo.tbOrg.OrganisationTypeCode = dbo.tbOrgType.OrganisationTypeCode LEFT OUTER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbOrg.TaxCode = dbo.tbSystemTaxCode.TaxCode LEFT OUTER JOIN
                      dbo.tbOrgAddress ON dbo.tbOrg.AddressCode = dbo.tbOrgAddress.AddressCode LEFT OUTER JOIN
                      dbo.vwOrgTaskCount ON dbo.tbOrg.AccountCode = dbo.vwOrgTaskCount.AccountCode
GO
CREATE VIEW [dbo].[vwCashCodePaymentSummary]
AS
SELECT     CashCode, dbo.fnAccountPeriod(PaidOn) AS StartOn, SUM(PaidInValue + PaidOutValue) AS CashValue, SUM(TaxInValue + TaxOutValue) 
                      AS CashTax
FROM         dbo.tbOrgPayment
GROUP BY CashCode, dbo.fnAccountPeriod(PaidOn)
GO
CREATE VIEW [dbo].[vwInvoiceOutstandingBase]
AS
SELECT     InvoiceNumber AS InvoiceNumber, TaskCode AS TaskCode, 
                      CashCode AS CashCode, TaxCode AS TaxCode, OutstandingValue, TaxRate
FROM         dbo.vwInvoiceOutstandingItems
UNION
SELECT     InvoiceNumber AS InvoiceNumber, TaskCode AS TaskCode, 
                      CashCode AS CashCode, TaxCode AS TaxCode, OutstandingValue, TaxRate
FROM         dbo.vwInvoiceOutstandingTasks
GO
CREATE VIEW [dbo].[vwInvoiceSummaryMargin]
AS
SELECT     StartOn, 5 AS InvoiceTypeCode, dbo.fnSystemProfileText(3004) AS InvoiceType, SUM(TotalInvoiceValue) AS TotalInvoiceValue, SUM(TotalTaxValue) 
                      AS TotalTaxValue
FROM         dbo.vwInvoiceSummaryTotals
GROUP BY StartOn
GO
CREATE VIEW [dbo].[vwInvoiceTaxSummary]
AS
SELECT     InvoiceNumber, TaxCode, SUM(InvoiceValueTotal) AS InvoiceValueTotal, SUM(TaxValueTotal) AS TaxValueTotal, SUM(TaxValueTotal) 
                      / SUM(InvoiceValueTotal) AS TaxRate
FROM         dbo.vwInvoiceTaxBase
GROUP BY InvoiceNumber, TaxCode
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
CREATE VIEW [dbo].[vwTaxVatStatement]
AS
SELECT     TOP (100) PERCENT StartOn, VatDue, VatPaid, Balance
FROM         dbo.fnTaxVatStatement() AS fnTaxVatStatement
ORDER BY StartOn, VatDue
GO
CREATE VIEW [dbo].[vwStatementCorpTaxDueDate]
AS
SELECT     TOP (1) PayOn
FROM         dbo.fnTaxTypeDueDates(1) AS fnTaxTypeDueDates
WHERE     (PayOn > GETDATE())
GO
CREATE VIEW [dbo].[vwAccountStatementPaymentBase]
AS
SELECT     AccountCode, TransactedOn, OrderBy, Reference, StatementType, SUM(Charge) AS Charge
FROM         dbo.vwAccountStatementPayments
GROUP BY AccountCode, TransactedOn, OrderBy, Reference, StatementType
GO
CREATE VIEW [dbo].[vwCorpTaxTasksBase]
AS
SELECT     TOP 100 PERCENT dbo.fnAccountPeriod(dbo.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity,
                       0))) * - 1 ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) END AS OrderValue
FROM         dbo.vwTaskInvoicedQuantity RIGHT OUTER JOIN
                      dbo.fnNetProfitCashCodes() fnNetProfitCashCodes INNER JOIN
                      dbo.tbCashCategory INNER JOIN
                      dbo.tbCashCode ON dbo.tbCashCategory.CategoryCode = dbo.tbCashCode.CategoryCode ON 
                      fnNetProfitCashCodes.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbTask ON fnNetProfitCashCodes.CashCode = dbo.tbTask.CashCode ON dbo.vwTaskInvoicedQuantity.TaskCode = dbo.tbTask.TaskCode
WHERE     (dbo.tbTask.TaskStatusCode < 4) AND (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0) > 0)
GO
CREATE VIEW [dbo].[vwCashCodeForecastSummary]
AS
SELECT     dbo.tbTask.CashCode, dbo.fnAccountPeriod(dbo.tbTask.ActionOn) AS StartOn, SUM(dbo.tbTask.TotalCharge) AS ForecastValue, 
                      SUM(dbo.tbTask.TotalCharge * ISNULL(dbo.vwSystemTaxRates.TaxRate, 0)) AS ForecastTax
FROM         dbo.tbTask INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode LEFT OUTER JOIN
                      dbo.vwSystemTaxRates ON dbo.tbTask.TaxCode = dbo.vwSystemTaxRates.TaxCode
WHERE     (dbo.tbTask.ActionOn >= dbo.fnSystemActiveStartOn())
GROUP BY dbo.tbTask.CashCode, dbo.fnAccountPeriod(dbo.tbTask.ActionOn)
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
CREATE VIEW [dbo].[vwInvoiceOutstanding]
AS
SELECT     TOP (100) PERCENT dbo.tbInvoice.AccountCode, dbo.tbInvoice.CollectOn, dbo.tbInvoice.InvoiceNumber, dbo.vwInvoiceOutstandingBase.TaskCode, 
                      dbo.tbInvoice.InvoiceStatusCode, dbo.tbInvoiceType.CashModeCode, dbo.vwInvoiceOutstandingBase.CashCode, 
                      dbo.vwInvoiceOutstandingBase.TaxCode, dbo.vwInvoiceOutstandingBase.TaxRate, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN OutstandingValue * - 1 ELSE OutstandingValue END AS ItemValue
FROM         dbo.vwInvoiceOutstandingBase INNER JOIN
                      dbo.tbInvoice ON dbo.vwInvoiceOutstandingBase.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
WHERE     (dbo.tbInvoice.InvoiceStatusCode = 2) OR
                      (dbo.tbInvoice.InvoiceStatusCode = 3)
GO
CREATE VIEW [dbo].[vwInvoiceSummary]
AS
SELECT     DATENAME(yyyy, StartOn) + '/' + CAST(dbo.fnPad(MONTH(StartOn), 2) AS nvarchar) AS PeriodOn, StartOn, 
                      InvoiceTypeCode, InvoiceType AS InvoiceType, ABS(TotalInvoiceValue) AS TotalInvoiceValue, ABS(TotalTaxValue) AS TotalTaxValue
FROM         dbo.vwInvoiceSummaryTotals
UNION
SELECT     DATENAME(yyyy, StartOn) + '/' + CAST(dbo.fnPad(MONTH(StartOn), 2) AS nvarchar) AS PeriodOn, StartOn, 
                      InvoiceTypeCode, InvoiceType AS InvoiceType, ABS(TotalInvoiceValue) AS TotalInvoiceValue, ABS(TotalTaxValue) AS TotalTaxValue
FROM         dbo.vwInvoiceSummaryMargin
GO
CREATE VIEW [dbo].[vwTaxCorpStatement]
AS
SELECT     TOP 100 PERCENT fnTaxCorpStatement.*
FROM         dbo.fnTaxCorpStatement() fnTaxCorpStatement
ORDER BY StartOn, TaxDue
GO
CREATE VIEW [dbo].[vwInvoiceRegisterExpenses]
AS
SELECT     StartOn, InvoiceNumber, TaskCode, TaskTitle, CashCode, CashDescription, TaxCode, TaxDescription, AccountCode, InvoiceTypeCode, 
                      InvoiceStatusCode, InvoicedOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, PaymentTerms, Printed, AccountName, UserName, InvoiceStatus, 
                      CashModeCode, InvoiceType, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS UnpaidValue
FROM         dbo.vwInvoiceRegisterTasks
WHERE     (dbo.fnTaskIsExpense(TaskCode) = 1)
GO
CREATE VIEW [dbo].[vwCashAccountStatements]
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
CREATE VIEW [dbo].[vwTaskOpBucket]
AS
SELECT     TaskCode, OperationNumber, dbo.fnSystemDateBucket(GETDATE(), EndOn) AS Period
FROM         dbo.tbTaskOp
GO
CREATE VIEW [dbo].[vwTaskBucket]
AS
SELECT     TaskCode, dbo.fnSystemDateBucket(GETDATE(), ActionOn) AS Period
FROM         dbo.tbTask
GO
CREATE VIEW [dbo].[vwAccountStatementBase]
AS
SELECT     TOP 100 PERCENT AccountCode, TransactedOn, OrderBy, Reference, StatementType, Charge
FROM         dbo.vwAccountStatementPaymentBase
UNION
SELECT     TOP 100 PERCENT AccountCode, TransactedOn, OrderBy, Reference, StatementType, Charge
FROM         dbo.vwAccountStatementInvoices
GO
CREATE VIEW [dbo].[vwTasks]
AS
SELECT     dbo.tbTask.TaskCode, dbo.tbTask.UserId, dbo.tbTask.AccountCode, dbo.tbTask.ContactName, dbo.tbTask.ActivityCode, dbo.tbTask.TaskTitle, 
                      dbo.tbTask.TaskStatusCode, dbo.tbTask.ActionById, dbo.tbTask.ActionOn, dbo.tbTask.ActionedOn, dbo.tbTask.PaymentOn, 
                      dbo.tbTask.SecondReference, dbo.tbTask.TaskNotes, dbo.tbTask.TaxCode, dbo.tbTask.Quantity, dbo.tbTask.UnitCharge, dbo.tbTask.TotalCharge, 
                      dbo.tbTask.AddressCodeFrom, dbo.tbTask.AddressCodeTo, dbo.tbTask.Printed, dbo.tbTask.InsertedBy, dbo.tbTask.InsertedOn, dbo.tbTask.UpdatedBy, 
                      dbo.tbTask.UpdatedOn, dbo.vwTaskBucket.Period, dbo.tbSystemBucket.BucketId, dbo.tbTaskStatus.TaskStatus, dbo.tbTask.CashCode, 
                      dbo.tbCashCode.CashDescription, tbUser_1.UserName AS OwnerName, dbo.tbUser.UserName AS ActionName, dbo.tbOrg.AccountName, 
                      dbo.tbOrgStatus.OrganisationStatus, dbo.tbOrgType.OrganisationType, CASE WHEN tbCashCategory.CategoryCode IS NULL 
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
CREATE VIEW [dbo].[vwTaskOps]
AS
SELECT     dbo.tbTaskOp.TaskCode, dbo.tbTaskOp.OperationNumber, dbo.vwTaskOpBucket.Period, dbo.tbSystemBucket.BucketId, dbo.tbTaskOp.UserId, 
                      dbo.tbTaskOp.OpTypeCode, dbo.tbTaskOp.OpStatusCode, dbo.tbTaskOp.Operation, dbo.tbTaskOp.Note, dbo.tbTaskOp.StartOn, dbo.tbTaskOp.EndOn, 
                      dbo.tbTaskOp.Duration, dbo.tbTaskOp.OffsetDays, dbo.tbTaskOp.InsertedBy, dbo.tbTaskOp.InsertedOn, dbo.tbTaskOp.UpdatedBy, 
                      dbo.tbTaskOp.UpdatedOn, dbo.tbTask.TaskTitle, dbo.tbTaskStatus.TaskStatus, dbo.tbTask.ActionOn, dbo.tbTask.Quantity, 
                      dbo.tbCashCode.CashDescription, dbo.tbTask.TotalCharge, dbo.tbTask.AccountCode, dbo.tbOrg.AccountName
FROM         dbo.tbTaskOp INNER JOIN
                      dbo.tbTask ON dbo.tbTaskOp.TaskCode = dbo.tbTask.TaskCode INNER JOIN
                      dbo.tbOrg ON dbo.tbTask.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbTaskStatus ON dbo.tbTask.TaskStatusCode = dbo.tbTaskStatus.TaskStatusCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.vwTaskOpBucket ON dbo.tbTaskOp.TaskCode = dbo.vwTaskOpBucket.TaskCode AND 
                      dbo.tbTaskOp.OperationNumber = dbo.vwTaskOpBucket.OperationNumber INNER JOIN
                      dbo.tbSystemBucket ON dbo.vwTaskOpBucket.Period = dbo.tbSystemBucket.Period
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
CREATE VIEW [dbo].[vwCorpTaxTasks]
AS
SELECT     dbo.vwCorpTaxTasksBase.StartOn, SUM(dbo.vwCorpTaxTasksBase.OrderValue) AS NetProfit, 
                      dbo.vwCorpTaxTasksBase.OrderValue * dbo.tbSystemYearPeriod.CorporationTaxRate AS CorporationTax
FROM         dbo.vwCorpTaxTasksBase INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.vwCorpTaxTasksBase.StartOn = dbo.tbSystemYearPeriod.StartOn
GROUP BY dbo.vwCorpTaxTasksBase.StartOn, dbo.vwCorpTaxTasksBase.OrderValue * dbo.tbSystemYearPeriod.CorporationTaxRate
GO
CREATE VIEW [dbo].[vwCashAccountLastPeriodEntry]
AS
SELECT     CashAccountCode, StartOn, MAX(EntryNumber) AS LastEntry
FROM         dbo.vwCashAccountStatements
GROUP BY CashAccountCode, StartOn
HAVING      (NOT (StartOn IS NULL))
GO
CREATE VIEW [dbo].[vwCashAccountPeriodClosingBalance]
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
CREATE  VIEW [dbo].[vwCashSummaryBase]
AS
SELECT     ISNULL(SUM(ToCollect), 0) AS Collect, ISNULL(SUM(ToPay), 0) AS Pay, ISNULL(SUM(TaxValue), 0) + dbo.fnSystemVatBalance() 
                      + dbo.fnSystemCorpTaxBalance() AS Tax, dbo.fnCashCompanyBalance() AS CompanyBalance
FROM         dbo.vwCashSummaryInvoices
GO
CREATE VIEW [dbo].[vwStatementReserves]
AS
SELECT     TOP 100 PERCENT fnStatementReserves.TransactOn, fnStatementReserves.CashEntryTypeCode, fnStatementReserves.ReferenceCode, 
                      fnStatementReserves.AccountCode, dbo.tbOrg.AccountName, dbo.tbCashEntryType.CashEntryType, fnStatementReserves.PayOut, 
                      fnStatementReserves.PayIn, fnStatementReserves.Balance, dbo.tbCashCode.CashCode, dbo.tbCashCode.CashDescription
FROM         dbo.fnStatementReserves() AS fnStatementReserves INNER JOIN
                      dbo.tbCashEntryType ON fnStatementReserves.CashEntryTypeCode = dbo.tbCashEntryType.CashEntryTypeCode INNER JOIN
                      dbo.tbOrg ON fnStatementReserves.AccountCode = dbo.tbOrg.AccountCode LEFT OUTER JOIN
                      dbo.tbCashCode ON fnStatementReserves.CashCode = dbo.tbCashCode.CashCode
ORDER BY fnStatementReserves.TransactOn, fnStatementReserves.CashEntryTypeCode, fnStatementReserves.ReferenceCode, fnStatementReserves.CashCode
GO
CREATE VIEW [dbo].[vwCashSummary]
AS
SELECT     GETDATE() AS Timstamp, Collect, Pay, Tax, CompanyBalance AS Cash, CompanyBalance + Collect - Pay - Tax AS Balance
FROM         dbo.vwCashSummaryBase
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
CREATE FUNCTION [dbo].[fnStatementTaxAccount]
	(
	@TaxTypeCode smallint
	)
RETURNS nvarchar(10)
AS
	BEGIN
	declare @AccountCode nvarchar(10)
	if exists (SELECT     AccountCode
		FROM         tbCashTaxType
		WHERE     (TaxTypeCode = @TaxTypeCode) AND (NOT (AccountCode IS NULL)))
		begin
		SELECT @AccountCode = AccountCode
		FROM         tbCashTaxType
		WHERE     (TaxTypeCode = @TaxTypeCode) AND (NOT (AccountCode IS NULL))
		end
	else
		begin
		SELECT TOP 1 @AccountCode = AccountCode
		FROM         tbSystemOptions		
		end
			
	
	RETURN @AccountCode
	END
GO
CREATE FUNCTION [dbo].[fnOrgRebuildInvoiceTasks]
	(
	@AccountCode nvarchar(10)
	)
RETURNS TABLE
AS
	RETURN ( SELECT     tbInvoice.InvoiceNumber, ROUND(SUM(tbInvoiceTask.InvoiceValue), 2) AS TotalInvoiceValue, ROUND(SUM(tbInvoiceTask.TaxValue), 2) 
	                               AS TotalTaxValue
	         FROM         tbInvoiceTask INNER JOIN
	                               tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber
	         WHERE     (tbInvoice.AccountCode = @AccountCode) AND (tbInvoice.InvoiceStatusCode <> 1)
	         GROUP BY tbInvoiceTask.InvoiceNumber, tbInvoice.InvoiceNumber )
GO
CREATE FUNCTION [dbo].[fnOrgRebuildInvoiceItems]
	(
	@AccountCode nvarchar(10)
	)
RETURNS TABLE
AS
	RETURN ( SELECT     tbInvoice.InvoiceNumber, ROUND(SUM(tbInvoiceItem.InvoiceValue), 2) AS TotalInvoiceValue, ROUND(SUM(tbInvoiceItem.TaxValue), 2) 
	                               AS TotalTaxValue
	         FROM         tbInvoiceItem INNER JOIN
	                               tbInvoice ON tbInvoiceItem.InvoiceNumber = tbInvoice.InvoiceNumber
	         WHERE     (tbInvoice.AccountCode = @AccountCode) AND (tbInvoice.InvoiceStatusCode <> 1)
	         GROUP BY tbInvoiceItem.InvoiceNumber, tbInvoice.InvoiceNumber )
GO
CREATE FUNCTION [dbo].[fnCashCodeDefaultAccount] 
	(
	@CashCode nvarchar(50)
	)
RETURNS nvarchar(10)
AS
	BEGIN
	declare @AccountCode nvarchar(10)
	if exists(SELECT     CashCode
	          FROM         tbInvoiceTask
	          WHERE     (CashCode = @CashCode))
		begin
		SELECT  @AccountCode = tbInvoice.AccountCode
		FROM         tbInvoiceTask INNER JOIN
		                      tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber
		WHERE     (tbInvoiceTask.CashCode = @CashCode)
		ORDER BY tbInvoice.InvoicedOn DESC		
		end
	else if exists(SELECT     CashCode
	          FROM         tbInvoiceItem
	          WHERE     (CashCode = @CashCode))
		begin
		SELECT  @AccountCode = tbInvoice.AccountCode
		FROM         tbInvoiceItem INNER JOIN
		                      tbInvoice ON tbInvoiceItem.InvoiceNumber = tbInvoice.InvoiceNumber
		WHERE     (tbInvoiceItem.CashCode = @CashCode)		
		ORDER BY tbInvoice.InvoicedOn DESC	
		end
	else
		begin	
		select @AccountCode = AccountCode from tbSystemOptions
		end
		
	RETURN @AccountCode
	END
GO
CREATE FUNCTION [dbo].[fnOrgStatement]
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
CREATE FUNCTION [dbo].[fnSystemAdjustToCalendar]
	(
	@UserId nvarchar(10),
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
CREATE FUNCTION [dbo].[fnTimestamp]
	(
	@Now datetime
	)
RETURNS NVARCHAR(20)
AS
	BEGIN
	DECLARE @Timestamp NVARCHAR(20)
	SET @Timestamp = LTRIM(STR(Year(@Now))) + '/'
		+ dbo.fnPad(LTRIM(STR(Month(@Now))), 2) + '/'
		+ dbo.fnPad(LTRIM(STR(Day(@Now))), 2) + ' '
		+ dbo.fnPad(LTRIM(STR(DatePart(hh, @Now))), 2) + ':'
		+ dbo.fnPad(LTRIM(STR(DatePart(n, @Now))), 2) + ':'
		+ dbo.fnPad(LTRIM(STR(DatePart(s, @Now))), 2)
	RETURN @Timestamp
	END
GO
CREATE FUNCTION [dbo].[fnTaskDefaultPaymentOn]
	(
		@AccountCode nvarchar(10),
		@ActionOn datetime
	)
RETURNS datetime
AS
	BEGIN
	DECLARE @PaymentOn datetime
	DECLARE @PaymentDays smallint
	DECLARE @UserId nvarchar(10)
	DECLARE @PayDaysFromMonthEnd bit


	SELECT @UserId = UserId FROM dbo.vwUserCredentials
	
	SELECT @PaymentDays = PaymentDays, @PayDaysFromMonthEnd = PayDaysFromMonthEnd
	FROM         tbOrg
	WHERE     (AccountCode = @AccountCode)
	
	IF (@PayDaysFromMonthEnd <> 0)
		set @PaymentOn = dateadd(d, @PaymentDays, dateadd(d, ((day(@ActionOn) - 1) + 1) * -1, dateadd(m, 1, @ActionOn)))
	ELSE
		set @PaymentOn = dateadd(d, @PaymentDays, @ActionOn)
		
	set @PaymentOn = dbo.fnSystemAdjustToCalendar(@UserId, @PaymentOn, 0)	
	
	
	RETURN @PaymentOn
	END
GO
CREATE FUNCTION [dbo].[fnTaskCost]
	(
	@TaskCode nvarchar(20)
	)
RETURNS money
AS
	BEGIN
	
	declare @ChildTaskCode nvarchar(20)
	declare @TotalCharge money
	declare @TotalCost money
	declare @CashModeCode smallint

	declare curFlow cursor local for
		SELECT     tbTask.TaskCode, vwTaskCashMode.CashModeCode, tbTask.TotalCharge
		FROM         tbTask INNER JOIN
							  tbTaskFlow ON tbTask.TaskCode = tbTaskFlow.ChildTaskCode INNER JOIN
							  vwTaskCashMode ON tbTask.TaskCode = vwTaskCashMode.TaskCode
		WHERE     (tbTaskFlow.ParentTaskCode = @TaskCode)	

	open curFlow
	fetch next from curFlow into @ChildTaskCode, @CashModeCode, @TotalCharge
	while @@FETCH_STATUS = 0
		begin
		set @TotalCost = @TotalCost + case when @CashModeCode = 1 then @TotalCharge else @TotalCharge * -1 end
		set @TotalCost = @TotalCost + dbo.fnTaskCost(@ChildTaskCode)
		fetch next from curFlow into @ChildTaskCode, @CashModeCode, @TotalCharge
		end
	
	close curFlow
	deallocate curFlow
	
	RETURN @TotalCost
	END
GO
CREATE FUNCTION [dbo].[fnTaxVatOrderTotals]
	(@IncludeForecasts bit = 0)
RETURNS @tbVat TABLE 
	(
	CashCode nvarchar(50),
	StartOn datetime, 
	PayIn money,
	PayOut money
	)
AS
	BEGIN
	declare @PayOn datetime
	declare @PayFrom datetime
	declare @PayTo datetime
	
	declare @VatCharge money
	
	declare @CashCode nvarchar(50)
	set @CashCode = dbo.fnSystemCashCode(2)
	
	declare curVat cursor local for
		SELECT     PayOn, PayFrom, PayTo
		FROM         fnTaxTypeDueDates(2) fnTaxTypeDueDates
		
	open curVat
	fetch next from curVat into @PayOn, @PayFrom, @PayTo
	while (@@FETCH_STATUS = 0)
		begin
		if (@IncludeForecasts = 0)
			begin
			INSERT INTO @tbVat (CashCode, StartOn, PayOut, PayIn)
			SELECT     @CashCode As CashCode, @PayOn AS PayOn, CASE WHEN ISNULL(SUM(VatValue), 0) > 0 THEN ISNULL(SUM(VatValue), 0) ELSE 0 END AS PayOut, 
			                      CASE WHEN ISNULL(SUM(VatValue), 0) < 0 THEN ABS(ISNULL(SUM(VatValue), 0)) ELSE 0 END AS PayIn
			FROM         vwTaskVatConfirmed
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo) AND (VatValue <> 0) 
			end
		else
			begin
			INSERT INTO @tbVat (CashCode, StartOn, PayOut, PayIn)
			SELECT    @CashCode AS CashCode, @PayOn AS PayOn, 
				CASE WHEN ISNULL(SUM(VatValue), 0) > 0 THEN ISNULL(SUM(VatValue), 0) ELSE 0 END AS PayOut, 
				CASE WHEN ISNULL(SUM(VatValue), 0) < 0 THEN ABS(ISNULL(SUM(VatValue), 0)) ELSE 0 END AS PayIn
			FROM         vwTaskVatFull
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo) 
			end		
						
		fetch next from curVat into @PayOn, @PayFrom, @PayTo
		end
	
	close curVat
	deallocate curVat

	
	RETURN
	END
GO
CREATE FUNCTION [dbo].[fnStatementVat]
	()
RETURNS @tbVat TABLE (
	ReferenceCode nvarchar(20), 
	AccountCode nvarchar(10),
	TransactOn datetime,
	CashEntryTypeCode int,
	PayOut money,
	PayIn money,
	CashCode nvarchar(50)
	)
AS
	BEGIN
	declare @LastBalanceOn datetime
	declare @VatDueOn datetime
	declare @VatDue money
	
	declare @ReferenceCode nvarchar(20)	
	declare @CashCode nvarchar(50)
	
	declare @AccountCode nvarchar(10)
	
	SET @ReferenceCode = dbo.fnSystemProfileText(1214)	
	SET @CashCode = dbo.fnSystemCashCode(2)
	SET @AccountCode = dbo.fnStatementTaxAccount(2)
	SELECT @VatDue = dbo.fnSystemVatBalance()
	IF (@VatDue <> 0)
		BEGIN
		SELECT  TOP 1 @VatDueOn = PayOn	FROM vwStatementVatDueDate		
		SET @VatDueOn = dbo.fnTaskDefaultPaymentOn(@AccountCode, @VatDueOn)
		insert into @tbVat (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayOut, PayIn, CashCode)
		values (@ReferenceCode, @AccountCode, @VatDueOn, 6, CASE WHEN @VatDue > 0 THEN @VatDue ELSE 0 END, CASE WHEN @VatDue < 0 THEN ABS(@VatDue) ELSE 0 END, @CashCode)									
		END
		
		
	RETURN
	END
GO
CREATE FUNCTION [dbo].[fnTaxCorpOrderTotals]
(@IncludeForecasts bit = 0)
RETURNS @tbCorp TABLE 
	(
	CashCode nvarchar(50),
	StartOn datetime, 
	NetProfit money,
	CorporationTax money
	)
AS
	BEGIN
	declare @PayOn datetime
	declare @PayFrom datetime
	declare @PayTo datetime
	
	declare @NetProfit money
	declare @CorporationTax money
	
	declare @CashCode nvarchar(50)
	set @CashCode = dbo.fnSystemCashCode(1)
	
	declare curVat cursor local for
		SELECT     PayOn, PayFrom, PayTo
		FROM         fnTaxTypeDueDates(1) fnTaxTypeDueDates
		
	open curVat
	fetch next from curVat into @PayOn, @PayFrom, @PayTo
	while (@@FETCH_STATUS = 0)
		begin
		if (@IncludeForecasts = 0)
			begin
			INSERT INTO @tbCorp (CashCode, StartOn, NetProfit, CorporationTax)
			SELECT     @CashCode As CashCode, @PayOn AS PayOn, ISNULL(SUM(NetProfit), 0) AS NetProfit, ISNULL(SUM(CorporationTax), 0) AS CorporationTax
			FROM         vwCorpTaxConfirmed
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
			HAVING      (ISNULL(SUM(CorporationTax), 0) > 0)
			end
		else
			begin
			INSERT INTO @tbCorp (CashCode, StartOn, NetProfit, CorporationTax)
			SELECT     @CashCode As CashCode, @PayOn AS PayOn, ISNULL(SUM(NetProfit), 0) AS NetProfit, ISNULL(SUM(CorporationTax), 0) AS CorporationTax
			FROM         vwCorpTaxTasks
			WHERE     (StartOn >= @PayFrom) AND (StartOn < @PayTo)
			HAVING      (ISNULL(SUM(CorporationTax), 0) > 0)
			end	
		
		fetch next from curVat into @PayOn, @PayFrom, @PayTo
		end
	
	close curVat
	deallocate curVat

	
	RETURN
	END
GO
CREATE FUNCTION [dbo].[fnStatementCorpTax]
	()
RETURNS @tbCorpTax TABLE (
	ReferenceCode nvarchar(20), 
	AccountCode nvarchar(10),
	TransactOn datetime,
	CashEntryTypeCode int,
	PayOut money,
	PayIn money,
	CashCode nvarchar(50)	
	)
AS
	BEGIN
	declare @TaxDueOn datetime
	declare @Balance money
	declare @TaxDue money
	
	declare @ReferenceCode nvarchar(20)	
	declare @CashCode nvarchar(50)
	declare @AccountCode nvarchar(10)
	
	SET @ReferenceCode = dbo.fnSystemProfileText(1214)	
	SET @CashCode = dbo.fnSystemCashCode(1)
	SET @AccountCode = dbo.fnStatementTaxAccount(1)
	SET @TaxDue = dbo.fnSystemCorpTaxBalance()
	
	IF @TaxDue > 0
		BEGIN
		SELECT  TOP 1 @TaxDueOn = PayOn	FROM vwStatementCorpTaxDueDate
		--SET @TaxDueOn = dbo.fnTaskDefaultPaymentOn(@AccountCode, @TaxDueOn)
		insert into @tbCorpTax (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayOut, PayIn, CashCode)
		values (@ReferenceCode, @AccountCode, @TaxDueOn, 5, @TaxDue, 0, @CashCode)								
		END
	
	RETURN
	END
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
CREATE PROCEDURE [dbo].[spActivityNextOperationNumber] 
	(
	@ActivityCode nvarchar(50),
	@OperationNumber smallint = 10 output
	)
AS
	if exists(SELECT     TOP 1 OperationNumber
	          FROM         tbActivityOp
	          WHERE     (ActivityCode = @ActivityCode))
		begin
		SELECT  @OperationNumber = MAX(OperationNumber) 
		FROM         tbActivityOp
		WHERE     (ActivityCode = @ActivityCode)
		set @OperationNumber = @OperationNumber - (@OperationNumber % 10) + 10		
		end
	else
		set @OperationNumber = 10
		
	RETURN
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
CREATE PROCEDURE [dbo].[spTaskNextOperationNumber] 
	(
	@TaskCode nvarchar(20),
	@OperationNumber smallint = 10 output
	)
AS
	if exists(SELECT     TOP 1 OperationNumber
	          FROM         tbTaskOp
	          WHERE     (TaskCode = @TaskCode))
		begin
		SELECT  @OperationNumber = MAX(OperationNumber) 
		FROM         tbTaskOp
		WHERE     (TaskCode = @TaskCode)
		set @OperationNumber = @OperationNumber - (@OperationNumber % 10) + 10		
		end
	else
		set @OperationNumber = 10
		
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
CREATE PROCEDURE [dbo].[spCashCopyForecastToLiveCategory]
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
CREATE PROCEDURE [dbo].[spCashCodeDefaults] 
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
CREATE PROCEDURE [dbo].[spTaskResetChargedUninvoiced]
AS
	UPDATE tbTask
	SET TaskStatusCode = 3
	FROM         tbCashCode INNER JOIN
	                      tbTask ON tbCashCode.CashCode = tbTask.CashCode LEFT OUTER JOIN
	                      tbInvoiceTask ON tbTask.TaskCode = tbInvoiceTask.TaskCode AND tbTask.TaskCode = tbInvoiceTask.TaskCode
	WHERE     (tbInvoiceTask.InvoiceNumber IS NULL) AND (tbTask.TaskStatusCode = 4)
	RETURN
GO
CREATE PROCEDURE [dbo].[spActivityWorkFlow]
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
CREATE PROCEDURE [dbo].[spActivityMode]
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
CREATE PROCEDURE [dbo].[spCashCategoryTotals]
	(
	@CashTypeCode smallint,
	@CategoryTypeCode smallint = 2
	)
AS

	SELECT     tbCashCategory.DisplayOrder, tbCashCategory.Category, tbCashType.CashType, tbCashCategory.CategoryCode
	FROM         tbCashCategory INNER JOIN
	                      tbCashType ON tbCashCategory.CashTypeCode = tbCashType.CashTypeCode
	WHERE     (tbCashCategory.CashTypeCode = @CashTypeCode) AND (tbCashCategory.CategoryTypeCode = @CategoryTypeCode)
	ORDER BY tbCashCategory.DisplayOrder, tbCashCategory.Category
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spInvoiceDefaultDocType]
	(
		@InvoiceNumber nvarchar(20),
		@DocTypeCode smallint OUTPUT
	)
AS
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
CREATE PROCEDURE [dbo].[spInvoiceTotal] 
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
	SET TaxValue = ROUND(tbInvoiceTask.InvoiceValue * vwSystemTaxRates.TaxRate, 2)
	FROM         tbInvoiceTask INNER JOIN
	                      vwSystemTaxRates ON tbInvoiceTask.TaxCode = vwSystemTaxRates.TaxCode
	WHERE     (tbInvoiceTask.InvoiceNumber = @InvoiceNumber)

	UPDATE     tbInvoiceItem
	SET TaxValue = CAST(ROUND(tbInvoiceItem.InvoiceValue * CAST(vwSystemTaxRates.TaxRate AS MONEY), 2) AS MONEY)
	FROM         tbInvoiceItem INNER JOIN
	                      vwSystemTaxRates ON tbInvoiceItem.TaxCode = vwSystemTaxRates.TaxCode
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
	
	set @InvoiceValue = Round(@InvoiceValue, 2)
	set @TaxValue = Round(@TaxValue, 2)
	set @PaidValue = Round(@PaidValue, 2)
	set @PaidTaxValue = Round(@PaidTaxValue, 2)
	
		
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
CREATE PROCEDURE [dbo].[spTaskFullyInvoiced]
	(
	@TaskCode nvarchar(20),
	@IsFullyInvoiced bit = 0 output
	)
AS
declare @InvoiceValue money
declare @TotalCharge money

	SELECT @InvoiceValue = SUM(InvoiceValue)
	FROM         tbInvoiceTask
	WHERE     (TaskCode = @TaskCode)
	
	
	SELECT @TotalCharge = SUM(TotalCharge)
	FROM         tbTask
	WHERE     (TaskCode = @TaskCode)
	
	IF (@TotalCharge = @InvoiceValue)
		SET @IsFullyInvoiced = 1
	ELSE
		SET @IsFullyInvoiced = 0
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskReconcileCharge]
	(
	@TaskCode nvarchar(20)
	)
AS
declare @InvoiceValue money

	SELECT @InvoiceValue = SUM(InvoiceValue)
	FROM         tbInvoiceTask
	WHERE     (TaskCode = @TaskCode)

	UPDATE    tbTask
	SET              TotalCharge = @InvoiceValue, UnitCharge = @InvoiceValue / Quantity
	WHERE     (TaskCode = @TaskCode)	
	
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
CREATE PROCEDURE [dbo].[spPaymentPostPaidIn]
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
		ORDER BY vwInvoiceOutstanding.CashModeCode, vwInvoiceOutstanding.CollectOn

	open curPaidIn
	fetch next from curPaidIn into @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue
	while @@FETCH_STATUS = 0 and @CurrentBalance < 0
		begin
		if (@CurrentBalance + @ItemValue) > 0
			set @ItemValue = @CurrentBalance * -1

		set @PaidValue = Abs(@ItemValue) / (1 + @TaxRate)
		set @PaidTaxValue = Abs(@ItemValue) - ROUND((Abs(@ItemValue) / (1 + @TaxRate)), 2)
				
		set @CurrentBalance = @CurrentBalance + @ItemValue
		
		if isnull(@TaskCode, '''') = ''''
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

	
	if isnull(@CashCode, '''') != ''''
		begin
		UPDATE    tbOrgPayment
		SET      PaymentStatusCode = 2, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
			CashCode = isnull(@CashCode, tbOrgPayment.CashCode), 
			TaxCode = isnull(@TaxCode, tbOrgPayment.TaxCode)
		WHERE     (PaymentCode = @PaymentCode)
		end

			
	RETURN
GO
CREATE PROCEDURE [dbo].[spPaymentPostPaidOut]
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
		ORDER BY vwInvoiceOutstanding.CashModeCode DESC, vwInvoiceOutstanding.CollectOn

	open curPaidOut
	fetch next from curPaidOut into @InvoiceNumber, @TaskCode, @CashCode, @TaxCode, @TaxRate, @ItemValue
	while @@FETCH_STATUS = 0 and @CurrentBalance > 0
		begin
		if (@CurrentBalance + @ItemValue) < 0
			set @ItemValue = @CurrentBalance * -1

		set @PaidValue = Abs(@ItemValue) / (1 + @TaxRate)
		set @PaidTaxValue = Abs(@ItemValue) - ROUND((Abs(@ItemValue) / (1 + @TaxRate)), 2)
				
		set @CurrentBalance = @CurrentBalance + @ItemValue
		
		if isnull(@TaskCode, '''') = ''''
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

	if isnull(@CashCode, '''') != ''''
		begin
		UPDATE    tbOrgPayment
		SET      PaymentStatusCode = 2, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
			CashCode = isnull(@CashCode, tbOrgPayment.CashCode), 
			TaxCode = isnull(@TaxCode, tbOrgPayment.TaxCode)
		WHERE     (PaymentCode = @PaymentCode)
		end
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spPaymentPostInvoiced]
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
CREATE PROCEDURE [dbo].[spSystemCompanyName]
	(
	@AccountName nvarchar(255) = null output
	)
AS
	SELECT top 1 @AccountName = tbOrg.AccountName
	FROM         tbOrg INNER JOIN
	                      tbSystemOptions ON tbOrg.AccountCode = tbSystemOptions.AccountCode
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
CREATE PROCEDURE [dbo].[spPaymentPostMisc]
	(
	@PaymentCode nvarchar(20) 
	)
AS
declare @InvoiceNumber nvarchar(20)
declare @UserId nvarchar(10)
declare @NextNumber int
declare @InvoiceSuffix nvarchar(4)
declare @InvoiceTypeCode smallint

	SELECT @InvoiceTypeCode = CASE WHEN PaidInValue != 0 THEN 1 ELSE 3 END 
	FROM         tbOrgPayment
	WHERE     (PaymentCode = @PaymentCode)

	select @UserId = UserId from vwUserCredentials

	set @InvoiceSuffix = '.' + @UserId
	
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
	                      4 AS InvoiceStatusCode, tbOrgPayment.PaidOn, CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate) 
	                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate) END AS InvoiceValue, 
	                      CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - ROUND((tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate)), 
	                      2) WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - ROUND((tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate)), 
	                      2) END AS TaxValue, CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate) 
	                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate) END AS PaidValue, 
	                      CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - ROUND((tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate)), 
	                      2) WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - ROUND((tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate)), 
	                      2) END AS PaidTaxValue, 1 AS Printed
	FROM         tbOrgPayment INNER JOIN
	                      vwSystemTaxRates ON tbOrgPayment.TaxCode = vwSystemTaxRates.TaxCode
	WHERE     (tbOrgPayment.PaymentCode = @PaymentCode)

	INSERT INTO tbInvoiceItem
						(InvoiceNumber, CashCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, TaxCode)
	SELECT     @InvoiceNumber AS InvoiceNumber, tbOrgPayment.CashCode, 
	                      CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate) 
	                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate) END AS InvoiceValue, 
	                      CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - ROUND((tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate)), 
	                      2) WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - ROUND((tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate)), 
	                      2) END AS TaxValue, CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate) 
	                      WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate) END AS PaidValue, 
	                      CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - ROUND((tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate)), 
	                      2) WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - ROUND((tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate)), 
	                      2) END AS PaidTaxValue, tbOrgPayment.TaxCode
	FROM         tbOrgPayment INNER JOIN
	                      vwSystemTaxRates ON tbOrgPayment.TaxCode = vwSystemTaxRates.TaxCode
	WHERE     (tbOrgPayment.PaymentCode = @PaymentCode)

	UPDATE  tbOrgAccount
	SET CurrentBalance = CASE WHEN PaidInValue > 0 THEN tbOrgAccount.CurrentBalance + PaidInValue ELSE tbOrgAccount.CurrentBalance - PaidOutValue END
	FROM         tbOrgAccount INNER JOIN
						  tbOrgPayment ON tbOrgAccount.CashAccountCode = tbOrgPayment.CashAccountCode
	WHERE tbOrgPayment.PaymentCode = @PaymentCode

	UPDATE    tbOrgPayment
	SET		PaymentStatusCode = 2,
		TaxInValue = PaidInValue - ROUND((PaidInValue / (1 + TaxRate)), 2), 
		TaxOutValue = PaidOutValue - ROUND((PaidOutValue / (1 + TaxRate)), 2)
	FROM         tbOrgPayment INNER JOIN
	                      vwSystemTaxRates ON tbOrgPayment.TaxCode = vwSystemTaxRates.TaxCode
	WHERE     (PaymentCode = @PaymentCode)
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spPaymentPost] 
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
CREATE PROCEDURE [dbo].[spTaskAssignToParent] 
	(
	@ChildTaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20)
	)
AS
declare @TaskTitle nvarchar(100)
declare @StepNumber smallint

	IF EXISTS (SELECT ParentTaskCode FROM tbTaskFlow WHERE ChildTaskCode = @ChildTaskCode)
		DELETE FROM tbTaskFlow WHERE ChildTaskCode = @ChildTaskCode

	IF EXISTS(SELECT     TOP 1 StepNumber
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
	SET              TaskTitle = @TaskTitle
	WHERE     (TaskCode = @ChildTaskCode) AND ((TaskTitle IS NULL) OR (TaskTitle = ActivityCode))
	
	INSERT INTO tbTaskFlow
	                      (ParentTaskCode, StepNumber, ChildTaskCode)
	VALUES     (@ParentTaskCode, @StepNumber, @ChildTaskCode)
	
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
CREATE PROCEDURE [dbo].[spTaskParent] 
	(
	@TaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20) output
	)
AS
	set @ParentTaskCode = @TaskCode
	if exists(SELECT     ParentTaskCode
	             FROM         tbTaskFlow
	             WHERE     (ChildTaskCode = @ParentTaskCode))
		select @ParentTaskCode = ParentTaskCode
	             FROM         tbTaskFlow
	             WHERE     (ChildTaskCode = @ParentTaskCode)
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskOp]
	(
	@TaskCode nvarchar(20)
	)
AS
		IF EXISTS (SELECT     TaskCode
	           FROM         tbTaskOp
	           WHERE     (TaskCode = @TaskCode))
	    BEGIN
		SELECT     tbTaskOp.*
		       FROM         tbTaskOp
		       WHERE     (TaskCode = @TaskCode)
		END
	ELSE
		BEGIN
		SELECT     tbTaskOp.*
		       FROM         tbTaskFlow INNER JOIN
		                             tbTaskOp ON tbTaskFlow.ParentTaskCode = tbTaskOp.TaskCode
		       WHERE     (tbTaskFlow.ChildTaskCode = @TaskCode)
		END
		
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
CREATE PROCEDURE [dbo].[spSystemReassignUser] 
	(
	@UserId nvarchar(10)
	)
AS
	UPDATE    tbUser
	SET       LogonName = (SUSER_SNAME())
	WHERE     (UserId = @UserId)
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskSetOpStatus]
	(
		@TaskCode nvarchar(20),
		@TaskStatusCode smallint
	)
AS
declare @OpStatusCode smallint
declare @OperationNumber smallint
	
	set @OpStatusCode = CASE @TaskStatusCode
							WHEN 1 THEN 1
							WHEN 2 THEN 2
							ELSE 3
						END
	
	if exists(SELECT TOP 1 OperationNumber
	          FROM         tbTaskOp
	          WHERE     (TaskCode = @TaskCode))
		begin
		UPDATE    tbTaskOp
		SET              OpStatusCode = @OpStatusCode
		WHERE     (OpTypeCode = 1) AND (TaskCode = @TaskCode)
		
		if exists (SELECT TOP 1 OperationNumber
	          FROM         tbTaskOp
	          WHERE     (TaskCode = @TaskCode) AND (OpTypeCode = 2))
	        begin
			SELECT @OperationNumber = MIN(OperationNumber)
			FROM         tbTaskOp
			WHERE     (OpTypeCode = 2) AND (TaskCode = @TaskCode)	          
				          
			UPDATE    tbTaskOp
			SET              OpStatusCode = @OpStatusCode
			WHERE     (OperationNumber = @OperationNumber) AND (TaskCode = @TaskCode)
	        end
		end
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskSetActionOn]
	(
	@TaskCode nvarchar(20)
	)
AS
declare @OperationNumber smallint
declare @OpTypeCode smallint
declare @ActionOn datetime
		
	SELECT @OperationNumber = MAX(OperationNumber)
	FROM         tbTaskOp
	WHERE     (TaskCode = @TaskCode)
	
	
	SELECT @OpTypeCode = OpTypeCode, @ActionOn = EndOn
	FROM         tbTaskOp
	WHERE     (TaskCode = @TaskCode) AND (OperationNumber = @OperationNumber)

	IF @OpTypeCode = 2
		BEGIN
		SELECT @OperationNumber = MIN(OperationNumber)
		FROM         tbTaskOp
		WHERE     (TaskCode = @TaskCode) AND (OpTypeCode = 2)
		
		SELECT @ActionOn = EndOn
		FROM         tbTaskOp
		WHERE     (TaskCode = @TaskCode) AND (OperationNumber = @OperationNumber)
				
		END
		
	UPDATE    tbTask
	SET              ActionOn = @ActionOn
	WHERE     (TaskCode = @TaskCode) AND (ActionOn <> @ActionOn)

		
	RETURN
GO
CREATE PROCEDURE [dbo].[spActivityParent]
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
CREATE PROCEDURE [dbo].[spCashCategoryCodeFromName]
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
CREATE PROCEDURE [dbo].[spCashCategoryCashCodes]
	(
	@CategoryCode nvarchar(10)
	)
AS
	SELECT     CashCode, CashDescription
	FROM         tbCashCode
	WHERE     (CategoryCode = @CategoryCode) AND (CashCode <> dbo.fnSystemCashCode(2))
	ORDER BY CashDescription
	RETURN
GO
CREATE PROCEDURE [dbo].[spInvoicePay]
	(
	@InvoiceNumber nvarchar(20),
	@Now datetime
	)
AS
DECLARE @PaidOut money
DECLARE @PaidIn money
DECLARE @TaskOutstanding money
DECLARE @ItemOutstanding money
DECLARE @CashModeCode smallint
DECLARE @CashCode nvarchar(50)

DECLARE @AccountCode nvarchar(10)
DECLARE @CashAccountCode nvarchar(10)
DECLARE @UserId nvarchar(10)
DECLARE @PaymentCode nvarchar(20)

	SELECT @UserId = UserId FROM dbo.vwUserCredentials
	

	SET @PaymentCode = @UserId + '_' + LTRIM(STR(Year(@Now)))
		+ dbo.fnPad(LTRIM(STR(Month(@Now))), 2)
		+ dbo.fnPad(LTRIM(STR(Day(@Now))), 2)
		+ dbo.fnPad(LTRIM(STR(DatePart(hh, @Now))), 2)
		+ dbo.fnPad(LTRIM(STR(DatePart(n, @Now))), 2)
		+ dbo.fnPad(LTRIM(STR(DatePart(s, @Now))), 2)
	
	WHILE EXISTS (SELECT PaymentCode FROM tbOrgPayment WHERE PaymentCode = @PaymentCode)
		BEGIN
		SET @Now = DATEADD(s, 1, @Now)
		SET @PaymentCode = @UserId + '_' + LTRIM(STR(Year(@Now)))
			+ dbo.fnPad(LTRIM(STR(Month(@Now))), 2)
			+ dbo.fnPad(LTRIM(STR(Day(@Now))), 2)
			+ dbo.fnPad(LTRIM(STR(DatePart(hh, @Now))), 2)
			+ dbo.fnPad(LTRIM(STR(DatePart(n, @Now))), 2)
			+ dbo.fnPad(LTRIM(STR(DatePart(s, @Now))), 2)
		END
		
	SELECT @CashModeCode = tbInvoiceType.CashModeCode, @AccountCode = tbInvoice.AccountCode
	FROM tbInvoice INNER JOIN tbInvoiceType ON tbInvoice.InvoiceTypeCode = tbInvoiceType.InvoiceTypeCode
	WHERE     (tbInvoice.InvoiceNumber = @InvoiceNumber)
	
	SELECT  @TaskOutstanding = SUM(tbInvoiceTask.InvoiceValue + tbInvoiceTask.TaxValue - tbInvoiceTask.PaidValue + tbInvoiceTask.PaidTaxValue),
		@CashCode = MIN(tbInvoiceTask.CashCode)	                      
	FROM         tbInvoice INNER JOIN
	                      tbInvoiceTask ON tbInvoice.InvoiceNumber = tbInvoiceTask.InvoiceNumber INNER JOIN
	                      tbInvoiceType ON tbInvoice.InvoiceTypeCode = tbInvoiceType.InvoiceTypeCode
	WHERE     (tbInvoice.InvoiceNumber = @InvoiceNumber)
	GROUP BY tbInvoiceType.CashModeCode


	SELECT @ItemOutstanding = SUM(tbInvoiceItem.InvoiceValue + tbInvoiceItem.TaxValue - tbInvoiceItem.PaidValue + tbInvoiceItem.PaidTaxValue)
	FROM         tbInvoice INNER JOIN
	                      tbInvoiceItem ON tbInvoice.InvoiceNumber = tbInvoiceItem.InvoiceNumber
	WHERE     (tbInvoice.InvoiceNumber = @InvoiceNumber)
	
	IF @CashModeCode = 1
		BEGIN
		SET @PaidOut = ISNULL(@TaskOutstanding, 0) + ISNULL(@ItemOutstanding, 0)
		SET @PaidIn = 0
		END
	ELSE
		BEGIN
		SET @PaidIn = ISNULL(@TaskOutstanding, 0) + ISNULL(@ItemOutstanding, 0)
		SET @PaidOut = 0
		END
	
	IF @PaidIn + @PaidOut > 0
		BEGIN
		SELECT TOP 1 @CashAccountCode = tbOrgAccount.CashAccountCode
		FROM         tbOrgAccount INNER JOIN
		                      tbCashCode ON tbOrgAccount.CashCode = tbCashCode.CashCode
		WHERE     (tbOrgAccount.AccountClosed = 0)
		GROUP BY tbOrgAccount.CashAccountCode
		
		INSERT INTO tbOrgPayment
							  (PaymentCode, UserId, PaymentStatusCode, AccountCode, CashAccountCode, CashCode, PaidOn, PaidInValue, PaidOutValue, PaymentReference)
		VALUES     (@PaymentCode,@UserId, 1,@AccountCode,@CashAccountCode,@CashCode,@Now,@PaidIn,@PaidOut,@InvoiceNumber)		
		
		EXEC dbo.spPaymentPostInvoiced @PaymentCode			
		END
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spCashGeneratePeriods]
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
CREATE PROCEDURE [dbo].[spCashCopyLiveToForecastCashCode]
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
CREATE  PROCEDURE [dbo].[spSettingNewCompany]
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
declare @UserId nvarchar(10)
declare @CalendarCode nvarchar(10)
declare @MenuId smallint

declare @AppAccountCode nvarchar(10)
declare @TaxCode nvarchar(10)
declare @AddressCode nvarchar(15)

declare @SqlDataVersion real
	
	select top 1 @MenuId = MenuId from tbProfileMenu
	select top 1 @CalendarCode = CalendarCode from tbSystemCalendar 

	set @UserId = upper(left(@FirstNames, 1)) + upper(left(@LastName, 1))
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
						(Identifier, Initialised, SQLDataVersion, AccountCode, DefaultPrintMode, BucketTypeCode, BucketIntervalCode, ShowCashGraphs)
	VALUES     (N'TC', 0, @SQLDataVersion, @AppAccountCode, 2, 1, 2, 1)
	
	update tbCashTaxType
	set CashCode = N'900'
	where TaxTypeCode = 3
	
	update tbCashTaxType
	set CashCode = N'902'
	where TaxTypeCode = 1
	
	update tbCashTaxType
	set CashCode = N'901'
	where TaxTypeCode = 2
	
	update tbCashTaxType
	set CashCode = N'903'
	where TaxTypeCode = 4
	
	RETURN 1
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
CREATE PROCEDURE [dbo].[spOrgBalanceOutstanding] 
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
CREATE PROCEDURE [dbo].[spTaskProfit]
	(
	@ParentTaskCode nvarchar(20),
	@TotalCost money = 0 output,
	@InvoicedCost money = 0 output,
	@InvoicedCostPaid money = 0 output
	)
AS
declare @TaskCode nvarchar(20)
declare @TotalCharge money
declare @TotalInvoiced money
declare @TotalPaid money
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
		
		SELECT  @TotalInvoiced = SUM(CASE WHEN tbInvoiceType.CashModeCode = 1 THEN tbInvoiceTask.InvoiceValue * - 1 ELSE tbInvoiceTask.InvoiceValue END), 
				@TotalPaid = SUM(CASE WHEN tbInvoiceType.CashModeCode = 1 THEN tbInvoiceTask.PaidValue * - 1 ELSE tbInvoiceTask.PaidValue END) 	                      
		FROM         tbInvoiceTask INNER JOIN
							  tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber INNER JOIN
							  tbInvoiceType ON tbInvoice.InvoiceTypeCode = tbInvoiceType.InvoiceTypeCode
		WHERE     (tbInvoiceTask.TaskCode = @TaskCode)

		set @InvoicedCost = @InvoicedCost + @TotalInvoiced
		set @InvoicedCostPaid = @InvoicedCostPaid + @TotalPaid
		set @TotalCost = @TotalCost + case when @CashModeCode = 1 then @TotalCharge else @TotalCharge * -1 end
			
		exec dbo.spTaskProfit @TaskCode, @TotalCost output, @InvoicedCost output, @InvoicedCostPaid output
		fetch next from curFlow into @TaskCode, @CashModeCode, @TotalCharge
		end
	
	close curFlow
	deallocate curFlow
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
CREATE PROCEDURE [dbo].[spOrgStatement]
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
CREATE PROCEDURE [dbo].[spCashAccountRebuild]
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
CREATE PROCEDURE [dbo].[spCashAccountRebuildAll]
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
CREATE PROCEDURE [dbo].[spTaskSetStatus]
	(
		@TaskCode nvarchar(20)
	)
AS
declare @ChildTaskCode nvarchar(20)
declare @TaskStatusCode smallint
declare @CashCode nvarchar(20)
declare @IsOrder bit

	select @TaskStatusCode = TaskStatusCode, @CashCode = CashCode
	from tbTask
	where TaskCode = @TaskCode
	
	exec dbo.spTaskSetOpStatus @TaskCode, @TaskStatusCode
	
	if @CashCode IS NULL
		set @IsOrder = 0
	else
		set @IsOrder = 1
	
	declare curTask cursor local for
		SELECT     tbTaskFlow.ChildTaskCode
		FROM         tbTaskFlow INNER JOIN
		                      tbTask ON tbTaskFlow.ChildTaskCode = tbTask.TaskCode
		WHERE     (tbTaskFlow.ParentTaskCode = @TaskCode)

	open curTask
	fetch next from curTask into @ChildTaskCode
	while @@FETCH_STATUS = 0
		begin
		
		if @IsOrder = 1 AND @TaskStatusCode <> 6
			begin
			UPDATE    tbTask
			SET              TaskStatusCode = @TaskStatusCode
			WHERE     (TaskCode = @ChildTaskCode) AND (TaskStatusCode < 3) AND (NOT (CashCode IS NULL))
			exec dbo.spTaskSetOpStatus @ChildTaskCode, @TaskStatusCode
			end
		else if @IsOrder = 0
			begin
			UPDATE    tbTask
			SET              TaskStatusCode = @TaskStatusCode
			WHERE     (TaskCode = @ChildTaskCode) AND (TaskStatusCode < 3) AND (CashCode IS NULL)			
			end		
		
		if (@TaskStatusCode <> 4)	
			exec dbo.spTaskSetStatus @ChildTaskCode
		fetch next from curTask into @ChildTaskCode
		end
		
	close curTask
	deallocate curTask
		
	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskScheduleOp]
	(
	@TaskCode nvarchar(20),
	@ActionOn datetime
	)	
AS
declare @OperationNumber smallint
declare @OpStatusCode smallint
declare @CallOffOpNo smallint

declare @EndOn datetime
declare @StartOn datetime
declare @OffsetDays smallint

declare @UserId nvarchar(10)
	
	select @UserId = ActionById
	from tbTask where TaskCode = @TaskCode	
	
	set @EndOn = @ActionOn

	SELECT @CallOffOpNo = MIN(OperationNumber)
	FROM         tbTaskOp
	WHERE     (TaskCode = @TaskCode) AND (OpTypeCode = 2)	
	
	set @CallOffOpNo = isnull(@CallOffOpNo, 0)
	
	declare curOp cursor local for
		SELECT     OperationNumber, OffsetDays, OpStatusCode, EndOn
		FROM         tbTaskOp
		WHERE     (TaskCode = @TaskCode) AND ((OperationNumber <= @CallOffOpNo) OR (@CallOffOpNo = 0)) 
		ORDER BY OperationNumber DESC
	
	open curOp
	fetch next from curOp into @OperationNumber, @OffsetDays, @OpStatusCode, @ActionOn
	while @@FETCH_STATUS = 0
		begin			
		if (@OpStatusCode < 3 ) 
			begin
			set @StartOn = dbo.fnSystemAdjustToCalendar(@UserId, @EndOn, @OffsetDays)
			update tbTaskOp
			set EndOn = @EndOn, StartOn = @StartOn
			where TaskCode = @TaskCode and OperationNumber = @OperationNumber			
			end
		else
			begin			
			set @StartOn = dbo.fnSystemAdjustToCalendar(@UserId, @ActionOn, @OffsetDays)
			end
		set @EndOn = @StartOn			
		fetch next from curOp into @OperationNumber, @OffsetDays, @OpStatusCode, @ActionOn
		end
	close curOp
	deallocate curOp
	
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
		WHERE     (tbTaskFlow.ParentTaskCode = @ParentTaskCode) AND (tbTask.TaskStatusCode < 5)

	open curFlow
	fetch next from curFlow into @TaskCode, @CashModeCode, @TotalCharge
	while @@FETCH_STATUS = 0
		begin
		set @TotalCost = @TotalCost + case when @CashModeCode = 1 then @TotalCharge else @TotalCharge * -1 end
		exec dbo.spTaskCost @TaskCode, @TotalCost output
		fetch next from curFlow into @TaskCode, @CashModeCode, @TotalCharge
		end
	
	close curFlow
	deallocate curFlow
	
	RETURN
GO
CREATE  PROCEDURE [dbo].[spTaskNextCode]
	(
		@ActivityCode nvarchar(50),
		@TaskCode nvarchar(20) OUTPUT
	)
AS
declare @UserId nvarchar(10)
declare @NextTaskNumber int

		SELECT   @UserId = tbUser.UserId, @NextTaskNumber = tbUser.NextTaskNumber
		FROM         vwUserCredentials INNER JOIN
							tbUser ON vwUserCredentials.UserId = tbUser.UserId


	if exists(SELECT     tbSystemRegister.NextNumber
	          FROM         tbActivity INNER JOIN
	                                tbSystemRegister ON tbActivity.RegisterName = tbSystemRegister.RegisterName
	          WHERE     (tbActivity.ActivityCode = @ActivityCode))
		begin
		declare @RegisterName nvarchar(50)
		SELECT @RegisterName = tbSystemRegister.RegisterName, @NextTaskNumber = tbSystemRegister.NextNumber
		FROM         tbActivity INNER JOIN
	                                tbSystemRegister ON tbActivity.RegisterName = tbSystemRegister.RegisterName
	    WHERE     (tbActivity.ActivityCode = @ActivityCode)
			          
		UPDATE    tbSystemRegister
		SET              NextNumber = NextNumber + 1
		WHERE     (RegisterName = @RegisterName)	
		end
	else
		begin
		SELECT   @UserId = tbUser.UserId, @NextTaskNumber = tbUser.NextTaskNumber
		FROM         vwUserCredentials INNER JOIN
							tbUser ON vwUserCredentials.UserId = tbUser.UserId
		                      		
		update dbo.tbUser
		Set NextTaskNumber = NextTaskNumber + 1
		where UserId = @UserId
		end
		                      
	set @TaskCode = @UserId + '_' + dbo.fnPad(ltrim(str(@NextTaskNumber)), 4)
			                      
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
CREATE PROCEDURE [dbo].[spTaskDefaultInvoiceType]
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
CREATE PROCEDURE [dbo].[spTaskDefaultDocType]
	(
		@TaskCode nvarchar(20),
		@DocTypeCode smallint OUTPUT
	)
AS
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
CREATE PROCEDURE [dbo].[spSystemAdjustToCalendar]
	(
	@SourceDate datetime,
	@OffsetDays int,
	@OutputDate datetime output
	)
AS
declare @UserId nvarchar(10)

	SELECT @UserId = UserId
	FROM         vwUserCredentials	
	
	set @OutputDate = dbo.fnSystemAdjustToCalendar(@UserId, @SourceDate, @OffsetDays)

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
CREATE PROCEDURE [dbo].[spTaskCopy]
	(
	@FromTaskCode nvarchar(20),
	@ParentTaskCode nvarchar(20) = null,
	@ToTaskCode nvarchar(20) = null output
	)
AS
declare @ActivityCode nvarchar(50)
declare @Printed bit
declare @ChildTaskCode nvarchar(20)
declare @TaskStatusCode smallint
declare @StepNumber smallint
declare @UserId nvarchar(10)

	SELECT @UserId = UserId FROM vwUserCredentials
	
	SELECT  @TaskStatusCode = tbActivity.TaskStatusCode, @ActivityCode = tbTask.ActivityCode, @Printed = CASE WHEN tbActivity.PrintOrder = 0 THEN 1 ELSE 0 END
	FROM         tbTask INNER JOIN
	                      tbActivity ON tbTask.ActivityCode = tbActivity.ActivityCode
	WHERE     (tbTask.TaskCode = @FromTaskCode)
	
	exec dbo.spTaskNextCode @ActivityCode, @ToTaskCode output

	INSERT INTO tbTask
						  (TaskCode, UserId, AccountCode, TaskTitle, ContactName, ActivityCode, TaskStatusCode, ActionById, ActionOn, ActionedOn, TaskNotes, Quantity, 
						  SecondReference, CashCode, TaxCode, UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, PaymentOn, Printed)
	SELECT     @ToTaskCode AS ToTaskCode, @UserId AS Owner, AccountCode, TaskTitle, ContactName, ActivityCode, @TaskStatusCode AS TaskStatus, 
						  @UserId AS ActionUserId, CONVERT(datetime, CONVERT(varchar, GETDATE(), 1), 1) AS ActionOn, 
						  CASE WHEN @TaskStatusCode > 2 THEN CONVERT(datetime, CONVERT(varchar, GETDATE(), 1), 1) ELSE NULL END AS ActionedOn, TaskNotes, 
						  Quantity, SecondReference, CashCode, TaxCode, UnitCharge, TotalCharge, AddressCodeFrom, AddressCodeTo, 
						  dbo.fnTaskDefaultPaymentOn(AccountCode, CONVERT(datetime, CONVERT(varchar, GETDATE(), 1), 1)) AS Expr1, @Printed AS Printed
	FROM         tbTask AS tbTask_1
	WHERE     (TaskCode = @FromTaskCode)
	
	INSERT INTO tbTaskAttribute
	                      (TaskCode, Attribute, PrintOrder, AttributeTypeCode, AttributeDescription)
	SELECT     @ToTaskCode AS ToTaskCode, Attribute, PrintOrder, AttributeTypeCode, AttributeDescription
	FROM         tbTaskAttribute AS tbTaskAttribute_1
	WHERE     (TaskCode = @FromTaskCode)
	
	INSERT INTO tbTaskQuote
	                      (TaskCode, Quantity, TotalPrice, RunOnQuantity, RunOnPrice, RunBackQuantity, RunBackPrice)
	SELECT     @ToTaskCode AS ToTaskCode, Quantity, TotalPrice, RunOnQuantity, RunOnPrice, RunBackQuantity, RunBackPrice
	FROM         tbTaskQuote AS tbTaskQuote_1
	WHERE     (TaskCode = @FromTaskCode)
	
	INSERT INTO tbTaskOp
						  (TaskCode, OperationNumber, OpStatusCode, UserId, OpTypeCode, Operation, Note, StartOn, EndOn, Duration, OffsetDays)
	SELECT     @ToTaskCode AS ToTaskCode, OperationNumber, 1 AS OpStatus, UserId, OpTypeCode, Operation, Note, CONVERT(datetime, CONVERT(varchar, 
						  GETDATE(), 1), 1) AS StartOn, CONVERT(datetime, CONVERT(varchar, GETDATE(), 1), 1) AS EndOn, Duration, OffsetDays
	FROM         tbTaskOp AS tbTaskOp_1
	WHERE     (TaskCode = @FromTaskCode)
	
	IF (ISNULL(@ParentTaskCode, '') = '')
		BEGIN
		IF EXISTS(SELECT     ParentTaskCode
				FROM         tbTaskFlow
				WHERE     (ChildTaskCode = @FromTaskCode))
			BEGIN
			SELECT @ParentTaskCode = ParentTaskCode
			FROM         tbTaskFlow
			WHERE     (ChildTaskCode = @FromTaskCode)

			SELECT @StepNumber = MAX(StepNumber)
			FROM         tbTaskFlow
			WHERE     (ParentTaskCode = @ParentTaskCode)
			GROUP BY ParentTaskCode
				
			SET @StepNumber = @StepNumber - (@StepNumber % 10) + 10	
						
			INSERT INTO tbTaskFlow
			(ParentTaskCode, StepNumber, ChildTaskCode, UsedOnQuantity, OffsetDays)
			SELECT TOP 1 ParentTaskCode, @StepNumber AS Step, @ToTaskCode AS ChildTask, UsedOnQuantity, OffsetDays
			FROM         tbTaskFlow
			WHERE     (ChildTaskCode = @FromTaskCode)
			END
		END
	ELSE
		BEGIN
		
		INSERT INTO tbTaskFlow
		(ParentTaskCode, StepNumber, ChildTaskCode, UsedOnQuantity, OffsetDays)
		SELECT TOP 1 @ParentTaskCode As ParentTask, StepNumber, @ToTaskCode AS ChildTask, UsedOnQuantity, OffsetDays
		FROM         tbTaskFlow AS tbTaskFlow_1
		WHERE     (ChildTaskCode = @FromTaskCode)		
		END
	
	declare curTask cursor local for			
		SELECT     ChildTaskCode
		FROM         tbTaskFlow
		WHERE     (ParentTaskCode = @FromTaskCode)
	
	open curTask
	
	fetch next from curTask into @ChildTaskCode
	while (@@FETCH_STATUS = 0)
		begin
		exec dbo.spTaskCopy @ChildTaskCode, @ToTaskCode
		fetch next from curTask into @ChildTaskCode
		end
		
	close curTask
	deallocate curTask
		
	RETURN
GO
CREATE  PROCEDURE [dbo].[spTaskConfigure] 
	(
	@ParentTaskCode nvarchar(20)
	)
AS
declare @StepNumber smallint
declare @TaskCode nvarchar(20)
declare @UserId nvarchar(10)
declare @ActivityCode nvarchar(50)

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
			
			if len(isnull(@ContactName, '')) > 0
				begin
				set @NickName = left(@ContactName, charindex(' ', @ContactName, 1))
				exec dbo.spOrgContactFileAs @ContactName, @FileAs output
				
				INSERT INTO tbOrgContact
									  (AccountCode, ContactName, FileAs, NickName)
				SELECT     AccountCode, ContactName, @FileAs AS FileAs, @NickName AS NickName
				FROM         tbTask
				WHERE     (TaskCode = @ParentTaskCode)
				end
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
		SET              ActionedOn = ActionOn
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
	
	INSERT INTO tbTaskOp
	                      (TaskCode, UserId, OperationNumber, OpTypeCode, Operation, Duration, OffsetDays, StartOn)
	SELECT     tbTask.TaskCode, tbTask.UserId, tbActivityOp.OperationNumber, tbActivityOp.OpTypeCode, tbActivityOp.Operation, tbActivityOp.Duration, 
	                      tbActivityOp.OffsetDays, tbTask.ActionOn
	FROM         tbActivityOp INNER JOIN
	                      tbTask ON tbActivityOp.ActivityCode = tbTask.ActivityCode
	WHERE     (tbTask.TaskCode = @ParentTaskCode)
	                   
	
	select @UserId = UserId from tbTask where tbTask.TaskCode = @ParentTaskCode
	
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
		SELECT  @ActivityCode = tbActivity.ActivityCode
		FROM         tbActivityFlow INNER JOIN
		                      tbActivity ON tbActivityFlow.ChildCode = tbActivity.ActivityCode INNER JOIN
		                      tbTask tbTask_1 ON tbActivityFlow.ParentCode = tbTask_1.ActivityCode
		WHERE     (tbActivityFlow.StepNumber = @StepNumber) AND (tbTask_1.TaskCode = @ParentTaskCode)
		
		exec dbo.spTaskNextCode @ActivityCode, @TaskCode output
		
		INSERT INTO tbTask
							(TaskCode, UserId, AccountCode, ContactName, ActivityCode, TaskStatusCode, ActionById, ActionOn, PaymentOn, TaskNotes, UnitCharge, 
							AddressCodeFrom, AddressCodeTo, CashCode, TaxCode, Printed, TaskTitle)
		SELECT     @TaskCode AS NewTask, tbTask_1.UserId, tbTask_1.AccountCode, tbTask_1.ContactName, tbActivity.ActivityCode, tbActivity.TaskStatusCode, 
							tbTask_1.ActionById, tbTask_1.ActionOn, dbo.fnTaskDefaultPaymentOn(tbTask_1.AccountCode, tbTask_1.ActionOn) 
							AS PaymentOn, tbActivity.DefaultText, tbActivity.UnitCharge, tbOrg.AddressCode AS AddressCodeFrom, tbOrg.AddressCode AS AddressCodeTo, 
							tbActivity.CashCode, dbo.fnTaskDefaultTaxCode(tbTask_1.AccountCode, tbActivity.CashCode) AS TaxCode, 
							CASE WHEN tbActivity.PrintOrder = 0 THEN 1 ELSE 0 END AS Printed, tbTask_1.TaskTitle
		FROM         tbActivityFlow INNER JOIN
							tbActivity ON tbActivityFlow.ChildCode = tbActivity.ActivityCode INNER JOIN
							tbTask tbTask_1 ON tbActivityFlow.ParentCode = tbTask_1.ActivityCode INNER JOIN
							tbOrg ON tbTask_1.AccountCode = tbOrg.AccountCode
		WHERE     (tbActivityFlow.StepNumber = @StepNumber) AND (tbTask_1.TaskCode = @ParentTaskCode)
		
		INSERT INTO tbTaskFlow
		                      (ParentTaskCode, StepNumber, ChildTaskCode, UsedOnQuantity, OffsetDays)
		SELECT     tbTask.TaskCode, tbActivityFlow.StepNumber, @TaskCode AS ChildTaskCode, tbActivityFlow.UsedOnQuantity, tbActivityFlow.OffsetDays
		FROM         tbActivityFlow INNER JOIN
		                      tbTask ON tbActivityFlow.ParentCode = tbTask.ActivityCode
		WHERE     (tbTask.TaskCode = @ParentTaskCode) AND (tbActivityFlow.StepNumber = @StepNumber)
		
		exec dbo.spTaskConfigure @TaskCode
		fetch next from curAct into @StepNumber
		end
	
	close curAct
	deallocate curAct


	RETURN
GO
CREATE PROCEDURE [dbo].[spCashCopyLiveToForecastCategory]
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
CREATE PROCEDURE [dbo].[spStatementRescheduleOverdue]
AS
	UPDATE tbTask
	SET tbTask.PaymentOn = dbo.fnTaskDefaultPaymentOn(tbTask.AccountCode, getdate()) 
	FROM         tbTask INNER JOIN
                      tbCashCode ON tbTask.CashCode = tbCashCode.CashCode
	WHERE     (tbTask.PaymentOn < GETDATE()) AND (tbTask.TaskStatusCode = 3)
	

	UPDATE tbTask
	SET tbTask.PaymentOn = dbo.fnTaskDefaultPaymentOn(tbTask.AccountCode, getdate()) 
	FROM         tbTask INNER JOIN
                      tbCashCode ON tbTask.CashCode = tbCashCode.CashCode
	WHERE     (tbTask.PaymentOn < GETDATE()) AND (tbTask.TaskStatusCode < 3)
	
	UPDATE tbInvoice
	SET CollectOn = dbo.fnTaskDefaultPaymentOn(tbInvoice.AccountCode, getdate()) 
	FROM         tbInvoice 
	WHERE     (tbInvoice.InvoiceStatusCode = 2 OR
	                      tbInvoice.InvoiceStatusCode = 3) AND (tbInvoice.CollectOn < GETDATE())
	
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spOrgRebuild]
	(
		@AccountCode nvarchar(10)
	)
AS
declare @PaidBalance money
declare @InvoicedBalance money
declare @Balance money
	
	
declare @CashModeCode smallint	

declare @InvoiceNumber nvarchar(20)
declare @TaskCode nvarchar(20)
declare @CashCode nvarchar(50)
declare @InvoiceValue money
declare @TaxValue money	

declare @PaidValue money
declare @PaidInvoiceValue money
declare @PaidTaxValue money
declare @TaxRate float	

	begin tran OrgRebuild
		
	update tbInvoiceItem
	set TaxValue = ROUND(tbInvoiceItem.InvoiceValue * vwSystemTaxRates.TaxRate, 2),
		PaidValue = tbInvoiceItem.InvoiceValue, 
		PaidTaxValue = ROUND(tbInvoiceItem.InvoiceValue * vwSystemTaxRates.TaxRate, 2)				
	FROM         tbInvoiceItem INNER JOIN
	                      vwSystemTaxRates ON tbInvoiceItem.TaxCode = vwSystemTaxRates.TaxCode INNER JOIN
	                      tbInvoice ON tbInvoiceItem.InvoiceNumber = tbInvoice.InvoiceNumber
	WHERE     (tbInvoice.AccountCode = @AccountCode) AND (tbInvoice.InvoiceStatusCode <> 1)	
                      
	update tbInvoiceTask
	set TaxValue = ROUND(tbInvoiceTask.InvoiceValue * vwSystemTaxRates.TaxRate, 2),
		PaidValue = tbInvoiceTask.InvoiceValue, PaidTaxValue = ROUND(tbInvoiceTask.InvoiceValue * vwSystemTaxRates.TaxRate, 2)
	FROM         tbInvoiceTask INNER JOIN
	                      vwSystemTaxRates ON tbInvoiceTask.TaxCode = vwSystemTaxRates.TaxCode INNER JOIN
	                      tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber
	WHERE     (tbInvoice.AccountCode = @AccountCode) AND (tbInvoice.InvoiceStatusCode <> 1)	
	
	UPDATE tbInvoice
	SET InvoiceValue = 0, TaxValue = 0
	WHERE tbInvoice.AccountCode = @AccountCode
	
	UPDATE tbInvoice
	SET InvoiceValue = fnOrgRebuildInvoiceItems.TotalInvoiceValue, 
		TaxValue = fnOrgRebuildInvoiceItems.TotalTaxValue
	FROM         tbInvoice INNER JOIN
	                      fnOrgRebuildInvoiceItems(@AccountCode) fnOrgRebuildInvoiceItems 
	                      ON tbInvoice.InvoiceNumber = fnOrgRebuildInvoiceItems.InvoiceNumber	
	
	UPDATE tbInvoice
	SET InvoiceValue = InvoiceValue + fnOrgRebuildInvoiceTasks.TotalInvoiceValue, 
		TaxValue = TaxValue + fnOrgRebuildInvoiceTasks.TotalTaxValue
	FROM         tbInvoice INNER JOIN
	                      fnOrgRebuildInvoiceTasks(@AccountCode) fnOrgRebuildInvoiceTasks 
	                      ON tbInvoice.InvoiceNumber = fnOrgRebuildInvoiceTasks.InvoiceNumber
			
	UPDATE    tbInvoice
	SET              PaidValue = InvoiceValue, PaidTaxValue = TaxValue, InvoiceStatusCode = 4
	WHERE     (AccountCode = @AccountCode) AND (InvoiceStatusCode <> 1)		

	
	UPDATE tbOrgPayment
	SET
		TaxInValue = PaidInValue - ROUND((PaidInValue / (1 + TaxRate)), 2), 
		TaxOutValue = PaidOutValue - ROUND((PaidOutValue / (1 + TaxRate)), 2)
	FROM         tbOrgPayment INNER JOIN
	                      vwSystemTaxRates ON tbOrgPayment.TaxCode = vwSystemTaxRates.TaxCode
	WHERE     (tbOrgPayment.AccountCode = @AccountCode)
		

	SELECT  @PaidBalance = SUM(CASE WHEN PaidInValue > 0 THEN PaidInValue * -1 ELSE PaidOutValue  END)
	FROM         tbOrgPayment
	WHERE     (AccountCode = @AccountCode) And (PaymentStatusCode <> 1)
	
	SELECT @PaidBalance = isnull(@PaidBalance, 0) + OpeningBalance
	FROM tbOrg
	WHERE     (AccountCode = @AccountCode)

	SELECT @InvoicedBalance = SUM(CASE tbInvoiceType.CashModeCode WHEN 1 THEN (InvoiceValue + TaxValue) * - 1 WHEN 2 THEN InvoiceValue + TaxValue ELSE 0 END) 
	FROM         tbInvoice INNER JOIN
	                      tbInvoiceType ON tbInvoice.InvoiceTypeCode = tbInvoiceType.InvoiceTypeCode
	WHERE     (tbInvoice.AccountCode = @AccountCode)
	
	set @Balance = isnull(@PaidBalance, 0) + isnull(@InvoicedBalance, 0)
                      
    set @CashModeCode = CASE WHEN @Balance > 0 THEN 2 ELSE 1 END
	set @Balance = Abs(@Balance)	

	declare curInv cursor local for
		SELECT     InvoiceNumber, TaskCode, CashCode, InvoiceValue, TaxValue
		FROM  vwOrgRebuildInvoices
		WHERE     (AccountCode = @AccountCode) And (CashModeCode = @CashModeCode)
		ORDER BY CollectOn DESC
	

	open curInv
	fetch next from curInv into @InvoiceNumber, @TaskCode, @CashCode, @InvoiceValue, @TaxValue
	while @@FETCH_STATUS = 0 And (@Balance > 0)
		begin

		if (@Balance - (@InvoiceValue + @TaxValue)) < 0
			begin
			set @PaidValue = (@InvoiceValue + @TaxValue) - @Balance
			set @Balance = 0	
			end
		else
			begin
			set @PaidValue = 0
			set @Balance = @Balance - (@InvoiceValue + @TaxValue)
			end
		
		if @PaidValue > 0
			begin
			set @TaxRate = @TaxValue / @InvoiceValue
			set @PaidInvoiceValue = @PaidValue - (@PaidValue - ROUND((@PaidValue / (1 + @TaxRate)), 2))
			set @PaidTaxValue = ROUND(@PaidInvoiceValue * @TaxRate, 2)
			end
		else
			begin
			set @PaidInvoiceValue = 0
			set @PaidTaxValue = 0
			end
			
		if isnull(@TaskCode, '''''''') = ''''''''
			begin
			UPDATE    tbInvoiceItem
			SET              PaidValue = @PaidInvoiceValue, PaidTaxValue = @PaidTaxValue
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (CashCode = @CashCode)
			end
		else
			begin
			UPDATE   tbInvoiceTask
			SET              PaidValue = @PaidInvoiceValue, PaidTaxValue = @PaidTaxValue
			WHERE     (InvoiceNumber = @InvoiceNumber) AND (TaskCode = @TaskCode)				
			end

		fetch next from curInv into @InvoiceNumber, @TaskCode, @CashCode, @InvoiceValue, @TaxValue
		end
	
	close curInv
	deallocate curInv
	
	UPDATE tbInvoice
	SET InvoiceStatusCode = 3,
		PaidValue = vwOrgRebuildInvoiceTotals.TotalPaidValue, 
		PaidTaxValue = vwOrgRebuildInvoiceTotals.TotalPaidTaxValue
	FROM         tbInvoice INNER JOIN
						vwOrgRebuildInvoiceTotals ON tbInvoice.InvoiceNumber = vwOrgRebuildInvoiceTotals.InvoiceNumber
	WHERE     (vwOrgRebuildInvoiceTotals.AccountCode = @AccountCode) AND 
						((vwOrgRebuildInvoiceTotals.TotalInvoiceValue + vwOrgRebuildInvoiceTotals.TotalTaxValue) 
						- (vwOrgRebuildInvoiceTotals.TotalPaidValue + vwOrgRebuildInvoiceTotals.TotalPaidTaxValue) > 0) AND 
						(vwOrgRebuildInvoiceTotals.TotalPaidValue + vwOrgRebuildInvoiceTotals.TotalPaidTaxValue < vwOrgRebuildInvoiceTotals.TotalInvoiceValue + vwOrgRebuildInvoiceTotals.TotalTaxValue)
	
	UPDATE tbInvoice
	SET InvoiceStatusCode = 2,
		PaidValue = 0, 
		PaidTaxValue = 0
	FROM         tbInvoice INNER JOIN
	                      vwOrgRebuildInvoiceTotals ON tbInvoice.InvoiceNumber = vwOrgRebuildInvoiceTotals.InvoiceNumber
	WHERE     (vwOrgRebuildInvoiceTotals.AccountCode = @AccountCode) AND 
	                      (vwOrgRebuildInvoiceTotals.TotalPaidValue + vwOrgRebuildInvoiceTotals.TotalPaidTaxValue = 0) AND 
	                      (vwOrgRebuildInvoiceTotals.TotalInvoiceValue + vwOrgRebuildInvoiceTotals.TotalTaxValue > 0)
	
	
	if (@CashModeCode = 2)
		set @Balance = @Balance * -1
		
	UPDATE    tbOrg
	SET              CurrentBalance = OpeningBalance - @Balance
	WHERE     (AccountCode = @AccountCode)
	
	commit tran OrgRebuild
	

	RETURN
GO
CREATE PROCEDURE [dbo].[spTaskProfitTopLevel]
	(
	@TaskCode nvarchar(20),
	@InvoicedCharge money = 0 output,
	@InvoicedChargePaid money = 0 output,
	@TotalCost money = 0 output,
	@InvoicedCost money = 0 output,
	@InvoicedCostPaid money = 0 output
	)
AS
			
	SELECT  @InvoicedCharge = SUM(CASE WHEN tbInvoiceType.CashModeCode = 1 THEN tbInvoiceTask.InvoiceValue * - 1 ELSE tbInvoiceTask.InvoiceValue END), 
	@InvoicedChargePaid = SUM(CASE WHEN tbInvoiceType.CashModeCode = 1 THEN tbInvoiceTask.PaidValue * - 1 ELSE tbInvoiceTask.PaidValue END) 	                      
	FROM         tbInvoiceTask INNER JOIN
	                      tbInvoice ON tbInvoiceTask.InvoiceNumber = tbInvoice.InvoiceNumber INNER JOIN
	                      tbInvoiceType ON tbInvoice.InvoiceTypeCode = tbInvoiceType.InvoiceTypeCode
	WHERE     (tbInvoiceTask.TaskCode = @TaskCode)
	
	set @TotalCost = 0
	exec dbo.spTaskProfit @TaskCode, @TotalCost output, @InvoicedCost output, @InvoicedCostPaid output	
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spInvoiceCredit]
	(
		@InvoiceNumber nvarchar(20) output
	)
AS
declare @InvoiceTypeCode smallint
declare @CreditNumber nvarchar(20)
declare @UserId nvarchar(10)
declare @NextNumber int
declare @InvoiceSuffix nvarchar(4)

	select @UserId = UserId from vwUserCredentials
	
	select @InvoiceTypeCode = InvoiceTypeCode from tbInvoice where InvoiceNumber = @InvoiceNumber
	
	set @InvoiceTypeCode = case @InvoiceTypeCode when 1 then 2 when 3 then 4 else 4 end
	
	select @UserId = UserId from vwUserCredentials

	set @InvoiceSuffix = '.' + @UserId
	
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
CREATE PROCEDURE [dbo].[spInvoiceRaiseBlank]
	(
	@AccountCode nvarchar(10),
	@InvoiceTypeCode smallint,
	@InvoiceNumber nvarchar(20) = null output
	)
AS
declare @UserId nvarchar(10)
declare @NextNumber int
declare @InvoiceSuffix nvarchar(4)

	select @UserId = UserId from vwUserCredentials

	set @InvoiceSuffix = '.' + @UserId
	
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
CREATE  PROCEDURE [dbo].[spInvoiceRaise]
	(
	@TaskCode nvarchar(20),
	@InvoiceTypeCode smallint,
	@InvoicedOn datetime,
	@InvoiceNumber nvarchar(20) = null output
	)
AS
declare @UserId nvarchar(10)
declare @NextNumber int
declare @InvoiceSuffix nvarchar(4)
declare @PaymentDays smallint
declare @CollectOn datetime
declare @AccountCode nvarchar(10)

	set @InvoicedOn = isnull(@InvoicedOn, getdate())
	
	select @UserId = UserId from vwUserCredentials

	set @InvoiceSuffix = '.' + @UserId
	
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

	SELECT @PaymentDays = tbOrg.PaymentDays, @AccountCode = tbOrg.AccountCode
	FROM         tbTask INNER JOIN
	                      tbOrg ON tbTask.AccountCode = tbOrg.AccountCode
	WHERE     (tbTask.TaskCode = @TaskCode)		
	
	set @CollectOn = dbo.fnTaskDefaultPaymentOn(@AccountCode, @InvoicedOn)
	
	begin tran Invoice
	
	exec dbo.spInvoiceCancel
	
	UPDATE    tbInvoiceType
	SET              NextNumber = @NextNumber + 1
	WHERE     (InvoiceTypeCode = @InvoiceTypeCode)
	
	INSERT INTO tbInvoice
						(InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoicedOn, CollectOn, InvoiceStatusCode, PaymentTerms)
	SELECT     @InvoiceNumber AS InvoiceNumber, @UserId AS UserId, tbTask.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, @InvoicedOn AS InvoicedOn, 
						@CollectOn AS CollectOn, 1 AS InvoiceStatusCode, 
						tbOrg.PaymentTerms
	FROM         tbTask INNER JOIN
						tbOrg ON tbTask.AccountCode = tbOrg.AccountCode
	WHERE     (tbTask.TaskCode = @TaskCode)

	exec dbo.spInvoiceAddTask @InvoiceNumber, @TaskCode
	
	UPDATE    tbTask
	SET              ActionedOn = GETDATE()
	WHERE     (TaskCode = @TaskCode) AND (ActionedOn IS NULL)

	commit tran Invoice
	
	RETURN
GO
CREATE  PROCEDURE [dbo].[spTaskSchedule]
	(
	@ParentTaskCode nvarchar(20),
	@ActionOn datetime = null output
	)
AS
declare @UserId nvarchar(10)
declare @AccountCode nvarchar(10)
declare @StepNumber smallint
declare @TaskCode nvarchar(20)
declare @OffsetDays smallint
declare @UsedOnQuantity float
declare @Quantity float
declare @PaymentDays smallint
declare @PaymentOn datetime

	if @ActionOn is null
		begin				
		select @ActionOn = ActionOn, @UserId = ActionById 
		from tbTask where TaskCode = @ParentTaskCode
		
		if @ActionOn != dbo.fnSystemAdjustToCalendar(@UserId, @ActionOn, 0)
			begin
			set @ActionOn = dbo.fnSystemAdjustToCalendar(@UserId, @ActionOn, 0)
			update tbTask
			set ActionOn = @ActionOn
			where TaskCode = @ParentTaskCode and TaskStatusCode < 3			
			end
		end
	
	SELECT @PaymentDays = tbOrg.PaymentDays, @PaymentOn = tbTask.PaymentOn, @AccountCode = tbTask.AccountCode
	FROM         tbOrg INNER JOIN
	                      tbTask ON tbOrg.AccountCode = tbTask.AccountCode
	WHERE     (tbTask.TaskCode = @ParentTaskCode)
	
	if (@PaymentOn != dbo.fnTaskDefaultPaymentOn(@AccountCode, @ActionOn))
		begin
		update tbTask
		set PaymentOn = dbo.fnTaskDefaultPaymentOn(AccountCode, ActionOn)
		where TaskCode = @ParentTaskCode and TaskStatusCode < 3
		end
	
	if exists(SELECT TOP 1 OperationNumber
	          FROM         tbTaskOp
	          WHERE     (TaskCode = @ParentTaskCode))
		begin
		exec dbo.spTaskScheduleOp @ParentTaskCode, @ActionOn
		end
	
	Select @Quantity = Quantity from tbTask where TaskCode = @ParentTaskCode
	
	declare curAct cursor local for
		SELECT     tbTaskFlow.StepNumber, tbTaskFlow.ChildTaskCode, tbTask.AccountCode, tbTask.ActionById, tbTaskFlow.OffsetDays, tbTaskFlow.UsedOnQuantity, 
		                      tbOrg.PaymentDays
		FROM         tbTaskFlow INNER JOIN
		                      tbTask ON tbTaskFlow.ChildTaskCode = tbTask.TaskCode INNER JOIN
		                      tbOrg ON tbTask.AccountCode = tbOrg.AccountCode
		WHERE     (tbTaskFlow.ParentTaskCode = @ParentTaskCode)
		ORDER BY tbTaskFlow.StepNumber DESC
	
	open curAct
	fetch next from curAct into @StepNumber, @TaskCode, @AccountCode, @UserId, @OffsetDays, @UsedOnQuantity, @PaymentDays
	while @@FETCH_STATUS = 0
		begin
		set @ActionOn = dbo.fnSystemAdjustToCalendar(@UserId, @ActionOn, @OffsetDays)
		set @PaymentOn = dbo.fnTaskDefaultPaymentOn(@AccountCode, @ActionOn)
		
		update tbTask
		set ActionOn = @ActionOn, 
			PaymentOn = @PaymentOn,
			Quantity = @Quantity * @UsedOnQuantity,
			TotalCharge = case when @UsedOnQuantity = 0 then UnitCharge else UnitCharge * @Quantity * @UsedOnQuantity end,
			UpdatedOn = getdate(),
			UpdatedBy = (suser_sname())
		where TaskCode = @TaskCode and TaskStatusCode < 3
		
		exec dbo.spTaskSchedule @TaskCode, @ActionOn output
		fetch next from curAct into @StepNumber, @TaskCode, @AccountCode, @UserId, @OffsetDays, @UsedOnQuantity, @PaymentDays
		end
	
	close curAct
	deallocate curAct	
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spPaymentMove]
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
CREATE  PROCEDURE [dbo].[spSystemPeriodTransferAll]
AS

	UPDATE tbCashPeriod
	SET InvoiceValue = 0, InvoiceTax = 0, CashValue = 0, CashTax = 0

		
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
CREATE PROCEDURE [dbo].[spSystemPeriodTransfer]
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
CREATE PROCEDURE [dbo].[spSystemPeriodClose]
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
CREATE PROCEDURE [dbo].[spTaskDefaultPaymentOn]
	(
		@AccountCode nvarchar(10),
		@ActionOn datetime,
		@PaymentOn datetime output
	)
AS
		
	SET @PaymentOn = dbo.fnTaskDefaultPaymentOn(@AccountCode, @ActionOn)
	
	RETURN
GO
CREATE PROCEDURE [dbo].[spCashVatBalance]
	(
	@Balance money output
	)
AS
	set @Balance = dbo.fnSystemVatBalance()
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
CREATE PROCEDURE [dbo].[spPaymentDelete]
	(
	@PaymentCode nvarchar(20)
	)
AS
declare @AccountCode nvarchar(10)
declare @CashAccountCode nvarchar(10)

	SELECT  @AccountCode = AccountCode, @CashAccountCode = CashAccountCode
	FROM         tbOrgPayment
	WHERE     (PaymentCode = @PaymentCode)

	DELETE FROM tbOrgPayment
	WHERE     (PaymentCode = @PaymentCode)
	
	exec dbo.spOrgRebuild @AccountCode
	exec dbo.spCashAccountRebuild @CashAccountCode
	

	RETURN
GO
CREATE  PROCEDURE [dbo].[spCashFlowInitialise]
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
	WHERE     (tbCashPeriod.StartOn >= @StartOn)
	
	UPDATE tbCashPeriod
	SET 
		ForecastValue = vwCashCodeForecastSummary.ForecastValue, 
		ForecastTax = vwCashCodeForecastSummary.ForecastTax
	FROM         tbCashPeriod INNER JOIN
	                      vwCashCodeForecastSummary ON tbCashPeriod.CashCode = vwCashCodeForecastSummary.CashCode AND 
	                      tbCashPeriod.StartOn = vwCashCodeForecastSummary.StartOn INNER JOIN
	                      tbCashCode ON tbCashPeriod.CashCode = tbCashCode.CashCode INNER JOIN
	                      tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE     (tbCashPeriod.StartOn >= @StartOn)
	
	
	UPDATE tbCashPeriod
	SET ForecastValue = 0, 
	ForecastTax = 0
	FROM         tbCashPeriod INNER JOIN
	                      tbCashTaxType ON tbCashPeriod.CashCode = tbCashTaxType.CashCode
	WHERE     (tbCashPeriod.StartOn >= @StartOn)

	UPDATE tbCashPeriod
	SET ForecastValue = fnStatementCorpTax_1.PayOut
	FROM         dbo.fnStatementCorpTax() AS fnStatementCorpTax_1 INNER JOIN
	                      tbCashPeriod ON fnStatementCorpTax_1.CashCode = tbCashPeriod.CashCode AND fnStatementCorpTax_1.TransactOn = tbCashPeriod.StartOn
	
	UPDATE tbCashPeriod
	SET ForecastValue = ForecastValue + fnTaxCorpOrderTotals_1.CorporationTax
	FROM         dbo.fnTaxCorpOrderTotals(DEFAULT) AS fnTaxCorpOrderTotals_1 INNER JOIN
	                      tbCashPeriod ON fnTaxCorpOrderTotals_1.CashCode = tbCashPeriod.CashCode AND fnTaxCorpOrderTotals_1.StartOn = tbCashPeriod.StartOn

	UPDATE tbCashPeriod
	SET ForecastValue = CASE WHEN PayIn > 0 THEN PayIn * - 1 ELSE PayOut END
	FROM         dbo.fnStatementVat() AS fnStatementVat_1 INNER JOIN
	                      tbCashPeriod ON fnStatementVat_1.CashCode = tbCashPeriod.CashCode AND fnStatementVat_1.TransactOn = tbCashPeriod.StartOn	

	UPDATE tbCashPeriod
	SET ForecastValue = ForecastValue + CASE WHEN PayIn > 0 THEN PayIn * - 1 ELSE PayOut END
	FROM         dbo.fnTaxVatOrderTotals(DEFAULT) AS fnTaxVatOrderTotals_1 INNER JOIN
	                      tbCashPeriod ON fnTaxVatOrderTotals_1.CashCode = tbCashPeriod.CashCode AND fnTaxVatOrderTotals_1.StartOn = tbCashPeriod.StartOn
	                      	

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
/****** Object:  Trigger [tbOrgAddress_TriggerInsert]    Script Date: 01/11/2012 13:37:03 ******/
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
/****** Object:  Trigger [tbOrgPayment_TriggerUpdate]    Script Date: 01/11/2012 13:37:03 ******/
GO
CREATE TRIGGER [dbo].[tbOrgPayment_TriggerUpdate]
ON [dbo].[tbOrgPayment]
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
/****** Object:  Trigger [Trigger_tbTask_Update]    Script Date: 01/11/2012 13:37:03 ******/
GO
CREATE TRIGGER [dbo].[Trigger_tbTask_Update]
ON [dbo].[tbTask] 
FOR UPDATE
AS
	IF UPDATE (ContactName)
		begin
		if exists (SELECT     ContactName
		           FROM         inserted AS i
		           WHERE     (NOT (ContactName IS NULL)) AND
		                                 (ContactName <> N''))
			begin
			if not exists(SELECT     tbOrgContact.ContactName
			              FROM         inserted AS i INNER JOIN
			                                    tbOrgContact ON i.AccountCode = tbOrgContact.AccountCode AND i.ContactName = tbOrgContact.ContactName)
				begin
				declare @FileAs nvarchar(100)
				declare @ContactName nvarchar(100)
				declare @NickName nvarchar(100)
								
				select TOP 1 @ContactName = isnull(ContactName, '') from inserted	 
				
				if len(@ContactName) > 0
					begin
					set @NickName = left(@ContactName, charindex(' ', @ContactName, 1))
					exec dbo.spOrgContactFileAs @ContactName, @FileAs output
					
					INSERT INTO tbOrgContact
										(AccountCode, ContactName, FileAs, NickName)
					SELECT TOP 1 AccountCode, ContactName, @FileAs AS FileAs, @NickName as NickName
					FROM  inserted
					end
				end                                   
			end		
		
		
		end

	declare @TaskCode nvarchar(20)

	IF UPDATE (TaskStatusCode)
		begin
		declare @TaskStatusCode smallint
		select @TaskCode = TaskCode, @TaskStatusCode = TaskStatusCode from inserted
		if @TaskStatusCode <> 4
			exec dbo.spTaskSetStatus @TaskCode
		else
			exec dbo.spTaskSetOpStatus @TaskCode, @TaskStatusCode
					
		end
		
	
	if UPDATE (ActionOn)
		begin
		declare @ScheduleOps bit		
		SELECT @ScheduleOps = ScheduleOps FROM tbSystemOptions
		IF (@ScheduleOps <> 0)
			BEGIN
			declare @ActionOn datetime
			select @TaskCode = TaskCode, @ActionOn = ActionOn from inserted		
			exec dbo.spTaskScheduleOp @TaskCode, @ActionOn
			END
		end
GO
/*********************************************************
 * Sql Data Creation Script
 * Source  (local)\TrumanMIS
 * Version 1.1.1
 *
 * Date    12/01/2012 13:35:32
 ********************************************************/


-- tbCashMode
insert into [tbCashMode] ([CashModeCode], [CashMode]) values (1, 'Expense')
insert into [tbCashMode] ([CashModeCode], [CashMode]) values (2, 'Income')
insert into [tbCashMode] ([CashModeCode], [CashMode]) values (3, 'Neutral')

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

-- tbSystemRecurrence
insert into [tbSystemRecurrence] ([RecurrenceCode], [Recurrence]) values (1, 'On Demand')
insert into [tbSystemRecurrence] ([RecurrenceCode], [Recurrence]) values (2, 'Monthly')
insert into [tbSystemRecurrence] ([RecurrenceCode], [Recurrence]) values (3, 'Quarterly')
insert into [tbSystemRecurrence] ([RecurrenceCode], [Recurrence]) values (4, 'Bi-annual')
insert into [tbSystemRecurrence] ([RecurrenceCode], [Recurrence]) values (5, 'Yearly')

-- tbActivityOpType
insert into [tbActivityOpType] ([OpTypeCode], [OpType]) values (1, 'Activity')
insert into [tbActivityOpType] ([OpTypeCode], [OpType]) values (2, 'Call-off')

-- tbCashCategoryType
insert into [tbCashCategoryType] ([CategoryTypeCode], [CategoryType]) values (1, 'Cash Code')
insert into [tbCashCategoryType] ([CategoryTypeCode], [CategoryType]) values (2, 'Total')
insert into [tbCashCategoryType] ([CategoryTypeCode], [CategoryType]) values (3, 'Expression')

-- tbCashEntryType
insert into [tbCashEntryType] ([CashEntryTypeCode], [CashEntryType]) values (1, 'Payment')
insert into [tbCashEntryType] ([CashEntryTypeCode], [CashEntryType]) values (2, 'Invoice')
insert into [tbCashEntryType] ([CashEntryTypeCode], [CashEntryType]) values (3, 'Order')
insert into [tbCashEntryType] ([CashEntryTypeCode], [CashEntryType]) values (4, 'Quote')
insert into [tbCashEntryType] ([CashEntryTypeCode], [CashEntryType]) values (5, 'Corporation Tax')
insert into [tbCashEntryType] ([CashEntryTypeCode], [CashEntryType]) values (6, 'Vat')
insert into [tbCashEntryType] ([CashEntryTypeCode], [CashEntryType]) values (7, 'Forecast')

-- tbCashTaxType
insert into [tbCashTaxType] ([TaxTypeCode], [TaxType], [MonthNumber], [RecurrenceCode]) values (1, 'Corporation Tax', 4, 5)
insert into [tbCashTaxType] ([TaxTypeCode], [TaxType], [MonthNumber], [RecurrenceCode]) values (2, 'Vat', 4, 3)
insert into [tbCashTaxType] ([TaxTypeCode], [TaxType], [MonthNumber], [RecurrenceCode]) values (3, 'N.I.', 1, 2)
insert into [tbCashTaxType] ([TaxTypeCode], [TaxType], [MonthNumber], [RecurrenceCode]) values (4, 'General', 1, 1)

-- tbSystemTaxCode
insert into [tbSystemTaxCode] ([TaxCode], [TaxRate], [TaxDescription], [TaxTypeCode]) values ('INTEREST', 0, 'Interest Tax', 4)
insert into [tbSystemTaxCode] ([TaxCode], [TaxRate], [TaxDescription], [TaxTypeCode]) values ('N/A', 0, 'Untaxed', 4)
insert into [tbSystemTaxCode] ([TaxCode], [TaxRate], [TaxDescription], [TaxTypeCode]) values ('NI1', 0, 'Directors National Insurance', 3)
insert into [tbSystemTaxCode] ([TaxCode], [TaxRate], [TaxDescription], [TaxTypeCode]) values ('NI2', 0.121, 'Employees National Insurance', 3)
insert into [tbSystemTaxCode] ([TaxCode], [TaxRate], [TaxDescription], [TaxTypeCode]) values ('T0', 0, 'Zero Rated VAT', 2)
insert into [tbSystemTaxCode] ([TaxCode], [TaxRate], [TaxDescription], [TaxTypeCode]) values ('T1', 0.175, 'Standard Rate VAT', 2)
insert into [tbSystemTaxCode] ([TaxCode], [TaxRate], [TaxDescription], [TaxTypeCode]) values ('T2', 0, 'Tax Exemption', 2)

-- tbCashType
insert into [tbCashType] ([CashTypeCode], [CashType]) values (1, 'TRADE')
insert into [tbCashType] ([CashTypeCode], [CashType]) values (2, 'EXTERNAL')
insert into [tbCashType] ([CashTypeCode], [CashType]) values (3, 'NOMINAL')
insert into [tbCashType] ([CashTypeCode], [CashType]) values (4, 'BANK')

-- tbCashCategory
insert into [tbCashCategory] ([CategoryCode], [Category], [CategoryTypeCode], [CashModeCode], [CashTypeCode], [DisplayOrder]) values ('6', 'Inland Revenue', 1, 1, 2, 4)

-- tbCashCode
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('900', 'Employers N.I.', '6', 'N/A')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('901', 'Value Added Tax', '6', 'N/A')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('902', 'Corporation Tax', '6', 'N/A')
insert into [tbCashCode] ([CashCode], [CashDescription], [CategoryCode], [TaxCode]) values ('903', 'General Taxes', '6', 'N/A')

update tbCashTaxType set CashCode ='900' where TaxTypeCode = 3
update tbCashTaxType set CashCode ='901' where TaxTypeCode = 2
update tbCashTaxType set CashCode ='902' where TaxTypeCode = 1
update tbCashTaxType set CashCode ='903' where TaxTypeCode = 4

-- tbInvoiceStatus
insert into [tbInvoiceStatus] ([InvoiceStatusCode], [InvoiceStatus]) values (2, 'Invoiced')
insert into [tbInvoiceStatus] ([InvoiceStatusCode], [InvoiceStatus]) values (3, 'Partially Paid')
insert into [tbInvoiceStatus] ([InvoiceStatusCode], [InvoiceStatus]) values (4, 'Paid')
insert into [tbInvoiceStatus] ([InvoiceStatusCode], [InvoiceStatus]) values (1, 'Pending')

-- tbInvoiceType
insert into [tbInvoiceType] ([InvoiceTypeCode], [InvoiceType], [CashModeCode], [NextNumber]) values (1, 'Sales Invoice', 2, 1124)
insert into [tbInvoiceType] ([InvoiceTypeCode], [InvoiceType], [CashModeCode], [NextNumber]) values (2, 'Credit Note', 1, 5004)
insert into [tbInvoiceType] ([InvoiceTypeCode], [InvoiceType], [CashModeCode], [NextNumber]) values (3, 'Purchase Invoice', 1, 3543)
insert into [tbInvoiceType] ([InvoiceTypeCode], [InvoiceType], [CashModeCode], [NextNumber]) values (4, 'Debit Note', 2, 4005)

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

-- tbProfileMenuCommand
insert into [tbProfileMenuCommand] ([Command], [CommandText]) values (0, 'Folder')
insert into [tbProfileMenuCommand] ([Command], [CommandText]) values (1, 'Link')
insert into [tbProfileMenuCommand] ([Command], [CommandText]) values (2, 'Form In Read Mode')
insert into [tbProfileMenuCommand] ([Command], [CommandText]) values (3, 'Form In Add Mode')
insert into [tbProfileMenuCommand] ([Command], [CommandText]) values (4, 'Form In Edit Mode')
insert into [tbProfileMenuCommand] ([Command], [CommandText]) values (5, 'Report')

-- tbProfileObjectType
insert into [tbProfileObjectType] ([ObjectTypeCode], [ObjectType]) values (1, 'Schema')
insert into [tbProfileObjectType] ([ObjectTypeCode], [ObjectType]) values (2, 'Form')
insert into [tbProfileObjectType] ([ObjectTypeCode], [ObjectType]) values (3, 'Report')
insert into [tbProfileObjectType] ([ObjectTypeCode], [ObjectType]) values (4, 'Dialog')
insert into [tbProfileObjectType] ([ObjectTypeCode], [ObjectType]) values (5, 'Text')
insert into [tbProfileObjectType] ([ObjectTypeCode], [ObjectType]) values (6, 'Substitutes')

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
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 17, 3, 0, 'Nominal Accounts', 0, 'Trader', '', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 18, 1, 2, 'Nominal Accounts', 1, '', '3', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 19, 3, 1, 'Nominal Forecast', 4, 'Trader', 'NominalForecast', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 22, 3, 4, 'Nominal Entry', 4, 'Trader', 'NominalEntry', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 23, 4, 0, 'Maintenance', 0, 'Trader', '', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 24, 1, 3, 'Maintenance', 1, '', '4', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 25, 4, 1, 'Organisations', 4, 'Trader', 'OrgMaintenance', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 29, 4, 2, 'Activities and Templates', 4, 'Trader', 'ActivityEdit', 1)
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
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 42, 4, 3, 'Organisation Datasheet', 4, 'Trader', 'OrgEdit', 2)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 43, 6, 5, 'Company Statement', 4, 'Trader', 'CompanyStatement', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 44, 6, 6, 'Job Profit Status by Month', 4, 'Trader', 'TaskProfitStatus', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 45, 5, 5, 'Expenses Entry', 3, 'Trader', 'TaskEntry', 1)
insert into [tbProfileMenuEntry] ([MenuId], [EntryId], [FolderId], [ItemId], [ItemText], [Command], [ProjectName], [Argument], [OpenMode]) values (1, 46, 5, 6, 'Expenses Payment', 3, 'Trader', 'TaskExpenses', 1)
SET IDENTITY_INSERT [tbProfileMenuEntry] OFF

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
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1208, 'A/No:   <3>
Ref.:   <2>
Title:  <4>
Status: <6>

Hello <1>

<5>

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
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1214, 'Invoiced', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1215, 'Ordered', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1216, 'Ok to move forward overdue payments?', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1217, 'Order charge differs from the invoice. Reconcile <1>?', 1)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1218, 'Raise invoice and pay expenses now?', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (1219, 'Reserve Account', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (2002, 'Only administrators have access to the system configuration features of this application.', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (2003, 'You are not a registered user of this system.
Please contact the Administrator if you believe you should have access.', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (2004, 'The primary key you have entered contains invalid characters.
Digits and letters should be used for these keys.
Please amend accordingly or press Esc to cancel.', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (2017, 'There is a problem with this installation.
Components have not been properly registered.
Please re-install the application and contact technical support.

<1>', 1)
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
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (3013, 'Current Balance', 0)
insert into [tbProfileText] ([TextId], [Message], [Arguments]) values (3014, 'This entry cannot be rescheduled', 0)

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
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'HomeNumber', 1, 'Home No.', '', '', 50, 1, '')
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
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'OnMailingList', 7, 'Mail List?', '', '', 0, 1, 'Yes/No')
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
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'PaymentDays', 2, 'Pay On', '', '', 0, 1, '0 days')
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'PaymentOn', 8, 'Pay On', '', '', 0, 1, 'Medium Date')
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
insert into [tbProfileObjectDetail] ([ObjectTypeCode], [ObjectName], [ItemName], [ItemTypeCode], [Caption], [StatusBarText], [ControlTipText], [CharLength], [Visible], [FormatString]) values (1, 'System Fields', 'RegisterName', 1, 'Register Name', '', '', 50, 1, '')
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

-- tbSystemBucketInterval
insert into [tbSystemBucketInterval] ([BucketIntervalCode], [BucketInterval]) values (1, 'Day')
insert into [tbSystemBucketInterval] ([BucketIntervalCode], [BucketInterval]) values (2, 'Week')
insert into [tbSystemBucketInterval] ([BucketIntervalCode], [BucketInterval]) values (3, 'Month')

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

-- tbSystemBucket
insert into [tbSystemBucket] ([Period], [BucketId], [BucketDescription], [AllowForecasts]) values (0, 'Overdue', 'Overdue Orders', 0)
insert into [tbSystemBucket] ([Period], [BucketId], [BucketDescription], [AllowForecasts]) values (1, 'Current', 'Current Week', 0)
insert into [tbSystemBucket] ([Period], [BucketId], [BucketDescription], [AllowForecasts]) values (2, 'Next Week', 'Week Two', 0)
insert into [tbSystemBucket] ([Period], [BucketId], [BucketDescription], [AllowForecasts]) values (3, 'Third Week', 'Week Three', 0)
insert into [tbSystemBucket] ([Period], [BucketId], [BucketDescription], [AllowForecasts]) values (4, 'Fourth Wk', 'Week Four', 0)
insert into [tbSystemBucket] ([Period], [BucketId], [BucketDescription], [AllowForecasts]) values (8, 'Next Month', 'Next Month', 0)
insert into [tbSystemBucket] ([Period], [BucketId], [BucketDescription], [AllowForecasts]) values (16, '2 Months', '2 Months', 1)
insert into [tbSystemBucket] ([Period], [BucketId], [BucketDescription], [AllowForecasts]) values (52, 'Forward', 'Forward Orders', 1)

-- tbSystemCalendar
insert into [tbSystemCalendar] ([CalendarCode], [Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday]) values ('OFFICE', 1, 1, 1, 1, 1, 0, 0)

-- tbSystemCodeExclusion
insert into [tbSystemCodeExclusion] ([ExcludedTag]) values ('Limited')
insert into [tbSystemCodeExclusion] ([ExcludedTag]) values ('Ltd')
insert into [tbSystemCodeExclusion] ([ExcludedTag]) values ('PLC')

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
insert into [tbSystemDoc] ([DocTypeCode], [ReportName], [OpenMode], [Description]) values (5, 'SalesInvoiceByActivity', 3, 'Invoice summed by activity')
insert into [tbSystemDoc] ([DocTypeCode], [ReportName], [OpenMode], [Description]) values (5, 'SalesInvoiceByActivityLetterhead', 3, 'Activity based invoice for letterhead')
insert into [tbSystemDoc] ([DocTypeCode], [ReportName], [OpenMode], [Description]) values (5, 'SalesInvoiceLetterhead', 3, 'Sales Invoice for Letterhead Paper')
insert into [tbSystemDoc] ([DocTypeCode], [ReportName], [OpenMode], [Description]) values (5, 'SalesInvoiceSimple', 3, 'Simple Invoice (Items Only)')
insert into [tbSystemDoc] ([DocTypeCode], [ReportName], [OpenMode], [Description]) values (6, 'CreditNote', 3, 'Standard Credit Note')
insert into [tbSystemDoc] ([DocTypeCode], [ReportName], [OpenMode], [Description]) values (6, 'CreditNoteLetterhead', 3, 'Credit Note for Letterhead Paper')
insert into [tbSystemDoc] ([DocTypeCode], [ReportName], [OpenMode], [Description]) values (7, 'DebitNote', 3, 'Standard Debit Note')
insert into [tbSystemDoc] ([DocTypeCode], [ReportName], [OpenMode], [Description]) values (7, 'DebitNoteLetterhead', 3, 'Debit Note for Letterhead Paper')

-- tbSystemUom
insert into [tbSystemUom] ([UnitOfMeasure]) values ('Each')
insert into [tbSystemUom] ([UnitOfMeasure]) values ('Hrs')
insert into [tbSystemUom] ([UnitOfMeasure]) values ('Kilo')
insert into [tbSystemUom] ([UnitOfMeasure]) values ('Mile')
insert into [tbSystemUom] ([UnitOfMeasure]) values ('Mins')
insert into [tbSystemUom] ([UnitOfMeasure]) values ('Pallets')

-- tbTaskOpStatus
insert into [tbTaskOpStatus] ([OpStatusCode], [OpStatus]) values (1, 'Pending')
insert into [tbTaskOpStatus] ([OpStatusCode], [OpStatus]) values (2, 'In-progress')
insert into [tbTaskOpStatus] ([OpStatusCode], [OpStatus]) values (3, 'Complete')

-- tbTaskStatus
insert into [tbTaskStatus] ([TaskStatusCode], [TaskStatus]) values (1, 'Pending')
insert into [tbTaskStatus] ([TaskStatusCode], [TaskStatus]) values (2, 'Open')
insert into [tbTaskStatus] ([TaskStatusCode], [TaskStatus]) values (3, 'Closed')
insert into [tbTaskStatus] ([TaskStatusCode], [TaskStatus]) values (4, 'Charged')
insert into [tbTaskStatus] ([TaskStatusCode], [TaskStatus]) values (5, 'Cancelled')
insert into [tbTaskStatus] ([TaskStatusCode], [TaskStatus]) values (6, 'Archive')

-- tbActivityAttributeType
insert into [tbActivityAttributeType] ([AttributeTypeCode], [AttributeType]) values (1, 'Order')
insert into [tbActivityAttributeType] ([AttributeTypeCode], [AttributeType]) values (2, 'Quote')

-- tbOrgPaymentStatus
insert into [tbOrgPaymentStatus] ([PaymentStatusCode], [PaymentStatus]) values (1, 'Unposted')
insert into [tbOrgPaymentStatus] ([PaymentStatusCode], [PaymentStatus]) values (2, 'Payment')
insert into [tbOrgPaymentStatus] ([PaymentStatusCode], [PaymentStatus]) values (3, 'Cancelled')

--Inland Revenue Account
INSERT INTO tbOrg (AccountCode, AccountName, OrganisationTypeCode, OrganisationStatusCode, TaxCode)
VALUES     (N'INLREV', N'Inland Revenue', 7, 2, N'T2')

UPDATE tbCashTaxType SET AccountCode = 'INLREV'
GO
