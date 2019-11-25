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
