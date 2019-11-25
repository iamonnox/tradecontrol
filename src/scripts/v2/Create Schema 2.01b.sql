GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskNextAttributeOrder]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbCashCategoryType]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbCashCategoryType](
	[CategoryTypeCode] [smallint] NOT NULL,
	[CategoryType] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_tbCashCategoryType] PRIMARY KEY CLUSTERED 
(
	[CategoryTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbCashStatus]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbCashStatus](
	[CashStatusCode] [smallint] NOT NULL,
	[CashStatus] [nvarchar](15) NOT NULL,
 CONSTRAINT [PK_tbCashStatus] PRIMARY KEY CLUSTERED 
(
	[CashStatusCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwOrgRebuildInvoiceTotals]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [dbo].[vwOrgRebuildInvoiceTotals]
AS
SELECT     AccountCode, InvoiceNumber, SUM(InvoiceValue) AS TotalInvoiceValue, SUM(TaxValue) AS TotalTaxValue, SUM(PaidValue) AS TotalPaidValue, 
                      SUM(PaidTaxValue) AS TotalPaidTaxValue
FROM         dbo.vwOrgRebuildInvoices
GROUP BY AccountCode, InvoiceNumber

'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbCashType]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbCashType](
	[CashTypeCode] [smallint] NOT NULL,
	[CashType] [nvarchar](25) NULL,
 CONSTRAINT [PK_tbCashType] PRIMARY KEY CLUSTERED 
(
	[CashTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbCashMode]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbCashMode](
	[CashModeCode] [smallint] NOT NULL,
	[CashMode] [nvarchar](10) NULL,
 CONSTRAINT [PK_tbCashMode] PRIMARY KEY CLUSTERED 
(
	[CashModeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbInvoiceStatus]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbInvoiceStatus](
	[InvoiceStatusCode] [smallint] NOT NULL,
	[InvoiceStatus] [nvarchar](50) NULL,
 CONSTRAINT [aaaaatbInvoiceStatus_PK] PRIMARY KEY NONCLUSTERED 
(
	[InvoiceStatusCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgPaymentStatus]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbOrgPaymentStatus](
	[PaymentStatusCode] [smallint] NOT NULL,
	[PaymentStatus] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_tbOrgPaymentStatus] PRIMARY KEY CLUSTERED 
(
	[PaymentStatusCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgStatus]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbOrgStatus](
	[OrganisationStatusCode] [smallint] NOT NULL CONSTRAINT [DF__tbOrgStat__Organ__07C12930]  DEFAULT ((1)),
	[OrganisationStatus] [nvarchar](255) NULL,
 CONSTRAINT [aaaaatbOrgStatus_PK] PRIMARY KEY NONCLUSTERED 
(
	[OrganisationStatusCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbProfileMenuCommand]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbProfileMenuCommand](
	[Command] [smallint] NOT NULL CONSTRAINT [DF_tbProfileMenuCommand_Command]  DEFAULT ((0)),
	[CommandText] [nvarchar](50) NULL,
 CONSTRAINT [PK_tbProfileMenuCommand] PRIMARY KEY CLUSTERED 
(
	[Command] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbProfileMenu]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbProfileMenuOpenMode]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbProfileMenuOpenMode](
	[OpenMode] [smallint] NOT NULL CONSTRAINT [DF_tbProfileMenuOpenMode_OpenMode]  DEFAULT ((0)),
	[OpenModeDescription] [nvarchar](20) NULL,
 CONSTRAINT [PK_tbProfileMenuOpenMode] PRIMARY KEY CLUSTERED 
(
	[OpenMode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwInvoiceSummaryBase]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwInvoiceSummaryBase]
AS
SELECT     StartOn, InvoiceTypeCode, InvoiceValue, TaxValue
FROM         dbo.vwInvoiceSummaryItems
UNION
SELECT     StartOn, InvoiceTypeCode, InvoiceValue, TaxValue
FROM         dbo.vwInvoiceSummaryTasks
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceSummaryBase', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "vwInvoiceSummaryTasks"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 203
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 2940
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceSummaryBase'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceSummaryBase', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceSummaryBase'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbProfileText]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbProfileText](
	[TextId] [int] NOT NULL,
	[Message] [ntext] NOT NULL,
	[Arguments] [smallint] NOT NULL,
 CONSTRAINT [PK_tbProfileText] PRIMARY KEY CLUSTERED 
(
	[TextId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbSystemBucket]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbSystemBucketType]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbSystemBucketType](
	[BucketTypeCode] [smallint] NOT NULL,
	[BucketType] [nvarchar](25) NOT NULL,
 CONSTRAINT [PK_tbSystemBucketType] PRIMARY KEY CLUSTERED 
(
	[BucketTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbSystemBucketInterval]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbSystemBucketInterval](
	[BucketIntervalCode] [smallint] NOT NULL,
	[BucketInterval] [nvarchar](15) NOT NULL,
 CONSTRAINT [PK_tbSystemBucketInterval] PRIMARY KEY CLUSTERED 
(
	[BucketIntervalCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spActivityNextOperationNumber]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spActivityNextOperationNumber] 
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
		
	RETURN' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbSystemCalendar]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbSystemRegister]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbSystemRegister](
	[RegisterName] [nvarchar](50) NOT NULL,
	[NextNumber] [int] NOT NULL CONSTRAINT [DF_tbSystemRegister_NextNumber]  DEFAULT ((1)),
 CONSTRAINT [PK_tbSystemRegister] PRIMARY KEY CLUSTERED 
(
	[RegisterName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwInvoiceVatSummary]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwInvoiceVatSummary]
AS
SELECT     StartOn, TaxCode, SUM(HomeSales) AS HomeSales, SUM(HomePurchases) AS HomePurchases, SUM(ExportSales) AS ExportSales, 
                      SUM(ExportPurchases) AS ExportPurchases, SUM(HomeSalesVat) AS HomeSalesVat, SUM(HomePurchasesVat) AS HomePurchasesVat, 
                      SUM(ExportSalesVat) AS ExportSalesVat, SUM(ExportPurchasesVat) AS ExportPurchasesVat
FROM         dbo.vwInvoiceVatDetail
GROUP BY StartOn, TaxCode
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceVatSummary', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[30] 4[31] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "vwInvoiceVatDetail"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 229
               Right = 232
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 12
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 2550
         Alias = 2355
         Table = 2160
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceVatSummary'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceVatSummary', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceVatSummary'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbTaskOpStatus]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbTaskOpStatus](
	[OpStatusCode] [smallint] NOT NULL,
	[OpStatus] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tbTaskOpStatus] PRIMARY KEY CLUSTERED 
(
	[OpStatusCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbSystemCodeExclusion]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbSystemCodeExclusion](
	[ExcludedTag] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_tbSystemCodeExclusion] PRIMARY KEY CLUSTERED 
(
	[ExcludedTag] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbSystemDocType]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbSystemDocType](
	[DocTypeCode] [smallint] NOT NULL,
	[DocType] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tbSystemDocType] PRIMARY KEY CLUSTERED 
(
	[DocTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbSystemInstall]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnTaskProfit]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fnTaskProfit]()
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

' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbSystemRecurrence]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbSystemRecurrence](
	[RecurrenceCode] [smallint] NOT NULL,
	[Recurrence] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_tbSystemRecurrence] PRIMARY KEY CLUSTERED 
(
	[RecurrenceCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwOrgTaskCount]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwOrgTaskCount]
  AS
SELECT     AccountCode, COUNT(TaskCode) AS TaskCount
FROM         dbo.tbTask
WHERE     (TaskStatusCode < 3)
GROUP BY AccountCode


'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbSystemMonth]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbSystemMonth](
	[MonthNumber] [smallint] NOT NULL,
	[MonthName] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_tbSystemMonth] PRIMARY KEY CLUSTERED 
(
	[MonthNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbSystemUom]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbSystemUom](
	[UnitOfMeasure] [nvarchar](15) NOT NULL,
 CONSTRAINT [PK_tbSystemUom] PRIMARY KEY CLUSTERED 
(
	[UnitOfMeasure] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbTaskStatus]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbTaskStatus](
	[TaskStatusCode] [smallint] NOT NULL,
	[TaskStatus] [nvarchar](100) NOT NULL,
 CONSTRAINT [aaaaatbActivityStatus_PK] PRIMARY KEY NONCLUSTERED 
(
	[TaskStatusCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbTaskStatus]') AND name = N'ActivityStatus')
CREATE UNIQUE NONCLUSTERED INDEX [ActivityStatus] ON [dbo].[tbTaskStatus] 
(
	[TaskStatus] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnTaxCorpTotals]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

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

' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwStatementVatDueDate]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwStatementVatDueDate]
  AS
SELECT     TOP 1 PayOn
FROM         dbo.fnTaxTypeDueDates(2) fnTaxTypeDueDates
WHERE     (PayOn > GETDATE())


'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spActivityNextAttributeOrder]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



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





' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spInvoiceDefaultDocType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spInvoiceDefaultDocType]
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
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbCashEntryType]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbCashEntryType](
	[CashEntryTypeCode] [smallint] NOT NULL,
	[CashEntryType] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_tbCashEntryType] PRIMARY KEY CLUSTERED 
(
	[CashEntryTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbActivityOpType]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbActivityOpType](
	[OpTypeCode] [smallint] NOT NULL,
	[OpType] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tbActivityOpType] PRIMARY KEY CLUSTERED 
(
	[OpTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskNextOperationNumber]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spTaskNextOperationNumber] 
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
		
	RETURN' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwStatementCorpTaxDueDate]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwStatementCorpTaxDueDate]
AS
SELECT        PayOn
FROM            dbo.fnTaxTypeDueDates(1) AS fnTaxTypeDueDates
WHERE        (PayOn > GETDATE())
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwStatementCorpTaxDueDate', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "fnTaxTypeDueDates"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 173
               Right = 217
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwStatementCorpTaxDueDate'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwStatementCorpTaxDueDate', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwStatementCorpTaxDueDate'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnPad]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'




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
		set @Target = ''0'' + @Target
		set @i = @i + 1
		end
	
	RETURN @Target
	END

' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spOrgContactFileAs]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



CREATE PROCEDURE [dbo].[spOrgContactFileAs] 
	(
	@ContactName nvarchar(100),
	@FileAs nvarchar(100) output
	)
  AS

	if charindex('' '', @ContactName) = 0
		set @FileAs = @ContactName
	else
		begin
		declare @FirstNames nvarchar(100)
		declare @LastName nvarchar(100)
		declare @LastWordPos int
		
		set @LastWordPos = charindex('' '', @ContactName) + 1
		while charindex('' '', @ContactName, @LastWordPos) != 0
			set @LastWordPos = charindex('' '', @ContactName, @LastWordPos) + 1
		
		set @FirstNames = left(@ContactName, @LastWordPos - 2)
		set @LastName = right(@ContactName, len(@ContactName) - @LastWordPos + 1)
		set @FileAs = @LastName + '', '' + @FirstNames
		end

	RETURN




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnSystemActiveStartOn]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

CREATE FUNCTION [dbo].[fnSystemActiveStartOn]
	()
RETURNS datetime
  AS
	BEGIN
	declare @StartOn datetime
	select @StartOn = StartOn from dbo.fnSystemActivePeriod()
	RETURN @StartOn
	END


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnSystemAdjustDateToBucket]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'




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





' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnSystemWeekDay]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'



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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnSystemDocInvoiceType]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fnSystemDocInvoiceType]
	(
	@InvoiceTypeCode SMALLINT
	)
RETURNS SMALLINT
AS
	BEGIN
	DECLARE @DocTypeCode SMALLINT
	
	SET @DocTypeCode = CASE @InvoiceTypeCode
		WHEN 1 THEN 5		--sales invoice
		WHEN 2 THEN 6		--credit note
		WHEN 4 THEN 7		--debit note
		ELSE 8				--error
		END
	
	RETURN @DocTypeCode
	END
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbActivityAttributeType]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbActivityAttributeType](
	[AttributeTypeCode] [smallint] NOT NULL,
	[AttributeType] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_tbActivityAttributeType] PRIMARY KEY CLUSTERED 
(
	[AttributeTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbCashCategory]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbCashCategory]') AND name = N'IX_tbCashCategory_DisplayOrder')
CREATE NONCLUSTERED INDEX [IX_tbCashCategory_DisplayOrder] ON [dbo].[tbCashCategory] 
(
	[DisplayOrder] ASC,
	[Category] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbCashCategory]') AND name = N'IX_tbCashCategory_Name')
CREATE NONCLUSTERED INDEX [IX_tbCashCategory_Name] ON [dbo].[tbCashCategory] 
(
	[Category] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbCashCategory]') AND name = N'IX_tbCashCategory_TypeCategory')
CREATE NONCLUSTERED INDEX [IX_tbCashCategory_TypeCategory] ON [dbo].[tbCashCategory] 
(
	[CategoryTypeCode] ASC,
	[Category] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbCashCategory]') AND name = N'IX_tbCashCategory_TypeOrderCategory')
CREATE NONCLUSTERED INDEX [IX_tbCashCategory_TypeOrderCategory] ON [dbo].[tbCashCategory] 
(
	[CategoryTypeCode] ASC,
	[DisplayOrder] ASC,
	[Category] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbTaskOp]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbTaskOp]') AND name = N'IX_tbTaskOp_OpStatusCode')
CREATE NONCLUSTERED INDEX [IX_tbTaskOp_OpStatusCode] ON [dbo].[tbTaskOp] 
(
	[OpStatusCode] ASC,
	[StartOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbTaskOp]') AND name = N'IX_tbTaskOp_UserIdOpStatus')
CREATE NONCLUSTERED INDEX [IX_tbTaskOp_UserIdOpStatus] ON [dbo].[tbTaskOp] 
(
	[UserId] ASC,
	[OpStatusCode] ASC,
	[StartOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbTaskAttribute]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbTaskAttribute]') AND name = N'IX_tbTaskAttribute')
CREATE NONCLUSTERED INDEX [IX_tbTaskAttribute] ON [dbo].[tbTaskAttribute] 
(
	[TaskCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbTaskAttribute]') AND name = N'IX_tbTaskAttribute_Description')
CREATE NONCLUSTERED INDEX [IX_tbTaskAttribute_Description] ON [dbo].[tbTaskAttribute] 
(
	[Attribute] ASC,
	[AttributeDescription] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbTaskAttribute]') AND name = N'IX_tbTaskAttribute_OrderBy')
CREATE NONCLUSTERED INDEX [IX_tbTaskAttribute_OrderBy] ON [dbo].[tbTaskAttribute] 
(
	[TaskCode] ASC,
	[PrintOrder] ASC,
	[Attribute] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbTaskAttribute]') AND name = N'IX_tbTaskAttribute_Type_OrderBy')
CREATE NONCLUSTERED INDEX [IX_tbTaskAttribute_Type_OrderBy] ON [dbo].[tbTaskAttribute] 
(
	[TaskCode] ASC,
	[AttributeTypeCode] ASC,
	[PrintOrder] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbTaskDoc]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbTaskFlow]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbTaskFlow]') AND name = N'IX_tbTaskFlow_ChildParent')
CREATE UNIQUE NONCLUSTERED INDEX [IX_tbTaskFlow_ChildParent] ON [dbo].[tbTaskFlow] 
(
	[ChildTaskCode] ASC,
	[ParentTaskCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbTaskFlow]') AND name = N'IX_tbTaskFlow_ParentChild')
CREATE UNIQUE NONCLUSTERED INDEX [IX_tbTaskFlow_ParentChild] ON [dbo].[tbTaskFlow] 
(
	[ParentTaskCode] ASC,
	[ChildTaskCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbTaskQuote]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbInvoiceTask]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbInvoiceTask]') AND name = N'IX_tbInvoiceTask_CashCode')
CREATE NONCLUSTERED INDEX [IX_tbInvoiceTask_CashCode] ON [dbo].[tbInvoiceTask] 
(
	[CashCode] ASC,
	[InvoiceNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbInvoiceTask]') AND name = N'IX_tbInvoiceTask_TaskCode')
CREATE NONCLUSTERED INDEX [IX_tbInvoiceTask_TaskCode] ON [dbo].[tbInvoiceTask] 
(
	[TaskCode] ASC,
	[InvoiceNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbInvoiceItem]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbInvoiceItem]') AND name = N'IX_tbInvoiceItem_CashCode')
CREATE NONCLUSTERED INDEX [IX_tbInvoiceItem_CashCode] ON [dbo].[tbInvoiceItem] 
(
	[CashCode] ASC,
	[InvoiceNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbCashTaxType]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbCashTaxType](
	[TaxTypeCode] [smallint] NOT NULL,
	[TaxType] [nvarchar](20) NOT NULL,
	[CashCode] [nvarchar](50) NULL,
	[MonthNumber] [smallint] NOT NULL CONSTRAINT [DF_tbSystemOptions_MonthNumber]  DEFAULT ((1)),
	[RecurrenceCode] [smallint] NOT NULL CONSTRAINT [DF_tbSystemOptions_Recurrence]  DEFAULT ((1)),
	[AccountCode] [nvarchar](10) NULL,
	[CashAccountCode] [nvarchar](10) NULL,
 CONSTRAINT [PK_tbCashTaxType] PRIMARY KEY CLUSTERED 
(
	[TaxTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbTask]') AND type in (N'U'))
BEGIN
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
	[Spooled] [bit] NOT NULL CONSTRAINT [DF_tbTask_Spooled]  DEFAULT ((0)),
	[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbTask_InsertedBy]  DEFAULT (suser_sname()),
	[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_tbTask_InsertedOn]  DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbTask_UpdatedBy]  DEFAULT (suser_sname()),
	[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_tbTask_UpdatedOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_tbTask] PRIMARY KEY CLUSTERED 
(
	[TaskCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbTask]') AND name = N'IX_tbTask_AccountCode')
CREATE NONCLUSTERED INDEX [IX_tbTask_AccountCode] ON [dbo].[tbTask] 
(
	[AccountCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbTask]') AND name = N'IX_tbTask_AccountCodeByActionOn')
CREATE NONCLUSTERED INDEX [IX_tbTask_AccountCodeByActionOn] ON [dbo].[tbTask] 
(
	[AccountCode] ASC,
	[ActionOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbTask]') AND name = N'IX_tbTask_AccountCodeByStatus')
CREATE NONCLUSTERED INDEX [IX_tbTask_AccountCodeByStatus] ON [dbo].[tbTask] 
(
	[AccountCode] ASC,
	[TaskStatusCode] ASC,
	[ActionOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbTask]') AND name = N'IX_tbTask_ActionBy')
CREATE NONCLUSTERED INDEX [IX_tbTask_ActionBy] ON [dbo].[tbTask] 
(
	[ActionById] ASC,
	[TaskStatusCode] ASC,
	[ActionOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbTask]') AND name = N'IX_tbTask_ActionById')
CREATE NONCLUSTERED INDEX [IX_tbTask_ActionById] ON [dbo].[tbTask] 
(
	[ActionById] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbTask]') AND name = N'IX_tbTask_ActionOn')
CREATE NONCLUSTERED INDEX [IX_tbTask_ActionOn] ON [dbo].[tbTask] 
(
	[ActionOn] DESC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbTask]') AND name = N'IX_tbTask_ActionOnStatus')
CREATE NONCLUSTERED INDEX [IX_tbTask_ActionOnStatus] ON [dbo].[tbTask] 
(
	[TaskStatusCode] ASC,
	[ActionOn] ASC,
	[AccountCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbTask]') AND name = N'IX_tbTask_ActivityCode')
CREATE NONCLUSTERED INDEX [IX_tbTask_ActivityCode] ON [dbo].[tbTask] 
(
	[ActivityCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbTask]') AND name = N'IX_tbTask_ActivityCodeTaskTitle')
CREATE NONCLUSTERED INDEX [IX_tbTask_ActivityCodeTaskTitle] ON [dbo].[tbTask] 
(
	[ActivityCode] ASC,
	[TaskTitle] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbTask]') AND name = N'IX_tbTask_ActivityStatusCode')
CREATE NONCLUSTERED INDEX [IX_tbTask_ActivityStatusCode] ON [dbo].[tbTask] 
(
	[TaskStatusCode] ASC,
	[ActionOn] ASC,
	[AccountCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbTask]') AND name = N'IX_tbTask_CashCode')
CREATE NONCLUSTERED INDEX [IX_tbTask_CashCode] ON [dbo].[tbTask] 
(
	[CashCode] ASC,
	[TaskStatusCode] ASC,
	[ActionOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbTask]') AND name = N'IX_tbTask_TaskStatusCode')
CREATE NONCLUSTERED INDEX [IX_tbTask_TaskStatusCode] ON [dbo].[tbTask] 
(
	[TaskStatusCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbTask]') AND name = N'IX_tbTask_UserId')
CREATE NONCLUSTERED INDEX [IX_tbTask_UserId] ON [dbo].[tbTask] 
(
	[UserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbCashPeriod]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbCashPeriod](
	[CashCode] [nvarchar](50) NOT NULL,
	[StartOn] [datetime] NOT NULL,
	[ForecastValue] [money] NOT NULL CONSTRAINT [DF_tbCashPeriod_ForecastValue]  DEFAULT ((0)),
	[ForecastTax] [money] NOT NULL CONSTRAINT [DF_tbCashPeriod_ForecastTax]  DEFAULT ((0)),
	[InvoiceValue] [money] NOT NULL CONSTRAINT [DF_tbCashPeriod_InvoiceValue]  DEFAULT ((0)),
	[InvoiceTax] [money] NOT NULL CONSTRAINT [DF_tbCashPeriod_InvoiceTax]  DEFAULT ((0)),
	[Note] [ntext] NULL,
 CONSTRAINT [PK_tbCashPeriod] PRIMARY KEY CLUSTERED 
(
	[CashCode] ASC,
	[StartOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgAccount]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgAccount]') AND name = N'IX_tbOrgAccount')
CREATE UNIQUE NONCLUSTERED INDEX [IX_tbOrgAccount] ON [dbo].[tbOrgAccount] 
(
	[AccountCode] ASC,
	[CashAccountCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgPayment]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgPayment]') AND name = N'IX_tbOrgPayment')
CREATE NONCLUSTERED INDEX [IX_tbOrgPayment] ON [dbo].[tbOrgPayment] 
(
	[PaymentReference] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgPayment]') AND name = N'IX_tbOrgPayment_AccountCode')
CREATE NONCLUSTERED INDEX [IX_tbOrgPayment_AccountCode] ON [dbo].[tbOrgPayment] 
(
	[AccountCode] ASC,
	[PaidOn] DESC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgPayment]') AND name = N'IX_tbOrgPayment_CashAccountCode')
CREATE NONCLUSTERED INDEX [IX_tbOrgPayment_CashAccountCode] ON [dbo].[tbOrgPayment] 
(
	[CashAccountCode] ASC,
	[PaidOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgPayment]') AND name = N'IX_tbOrgPayment_CashCode')
CREATE NONCLUSTERED INDEX [IX_tbOrgPayment_CashCode] ON [dbo].[tbOrgPayment] 
(
	[CashCode] ASC,
	[PaidOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgPayment]') AND name = N'IX_tbOrgPayment_PaymentStatusCode')
CREATE NONCLUSTERED INDEX [IX_tbOrgPayment_PaymentStatusCode] ON [dbo].[tbOrgPayment] 
(
	[PaymentStatusCode] ASC,
	[AccountCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbActivity]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgType]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbOrgType](
	[OrganisationTypeCode] [smallint] NOT NULL CONSTRAINT [DF__tbOrgType__Organ__3F466844]  DEFAULT ((1)),
	[CashModeCode] [smallint] NOT NULL,
	[OrganisationType] [nvarchar](50) NOT NULL,
 CONSTRAINT [aaaaatbOrgType_PK] PRIMARY KEY NONCLUSTERED 
(
	[OrganisationTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbInvoiceType]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbSystemYearPeriod]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbSystemTaxCode]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbSystemTaxCode]') AND name = N'IX_tbSystemTaxCodeByType')
CREATE NONCLUSTERED INDEX [IX_tbSystemTaxCodeByType] ON [dbo].[tbSystemTaxCode] 
(
	[TaxTypeCode] ASC,
	[TaxCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbInvoice]') AND type in (N'U'))
BEGIN
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
	[Spooled] [bit] NOT NULL CONSTRAINT [DF_tbInvoice_Spooled]  DEFAULT ((0)),
	[CollectOn] [datetime] NOT NULL CONSTRAINT [DF_tbInvoice_CollectOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_tbInvoice] PRIMARY KEY CLUSTERED 
(
	[InvoiceNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbInvoice]') AND name = N'IX_tbInvoice_AccountCode')
CREATE NONCLUSTERED INDEX [IX_tbInvoice_AccountCode] ON [dbo].[tbInvoice] 
(
	[AccountCode] ASC,
	[InvoicedOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbInvoice]') AND name = N'IX_tbInvoice_Status')
CREATE NONCLUSTERED INDEX [IX_tbInvoice_Status] ON [dbo].[tbInvoice] 
(
	[InvoiceStatusCode] ASC,
	[InvoicedOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbInvoice]') AND name = N'IX_tbInvoice_UserId')
CREATE NONCLUSTERED INDEX [IX_tbInvoice_UserId] ON [dbo].[tbInvoice] 
(
	[UserId] ASC,
	[InvoiceNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbSystemOptions]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgContact]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgContact]') AND name = N'IX_tbOrgContactDepartment')
CREATE NONCLUSTERED INDEX [IX_tbOrgContactDepartment] ON [dbo].[tbOrgContact] 
(
	[Department] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgContact]') AND name = N'IX_tbOrgContactJobTitle')
CREATE NONCLUSTERED INDEX [IX_tbOrgContactJobTitle] ON [dbo].[tbOrgContact] 
(
	[JobTitle] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgContact]') AND name = N'IX_tbOrgContactNameTitle')
CREATE NONCLUSTERED INDEX [IX_tbOrgContactNameTitle] ON [dbo].[tbOrgContact] 
(
	[NameTitle] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgContact]') AND name = N'tbOrgtbOrgContact')
CREATE NONCLUSTERED INDEX [tbOrgtbOrgContact] ON [dbo].[tbOrgContact] 
(
	[AccountCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgSector]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbOrgSector](
	[AccountCode] [nvarchar](10) NOT NULL,
	[IndustrySector] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tbOrgSector] PRIMARY KEY CLUSTERED 
(
	[AccountCode] ASC,
	[IndustrySector] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgSector]') AND name = N'IX_tbOrgSector_IndustrySector')
CREATE NONCLUSTERED INDEX [IX_tbOrgSector_IndustrySector] ON [dbo].[tbOrgSector] 
(
	[IndustrySector] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgDoc]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgDoc]') AND name = N'DocumentName')
CREATE UNIQUE NONCLUSTERED INDEX [DocumentName] ON [dbo].[tbOrgDoc] 
(
	[DocumentName] ASC,
	[AccountCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgDoc]') AND name = N'tbOrgtbOrgDoc')
CREATE NONCLUSTERED INDEX [tbOrgtbOrgDoc] ON [dbo].[tbOrgDoc] 
(
	[AccountCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgAddress]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgAddress]') AND name = N'IX_tbOrgAddress')
CREATE UNIQUE NONCLUSTERED INDEX [IX_tbOrgAddress] ON [dbo].[tbOrgAddress] 
(
	[AccountCode] ASC,
	[AddressCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbOrg]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbOrg]') AND name = N'IX_tbOrg_AccountName')
CREATE UNIQUE NONCLUSTERED INDEX [IX_tbOrg_AccountName] ON [dbo].[tbOrg] 
(
	[AccountName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbOrg]') AND name = N'IX_tbOrg_AccountSource')
CREATE NONCLUSTERED INDEX [IX_tbOrg_AccountSource] ON [dbo].[tbOrg] 
(
	[AccountSource] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbOrg]') AND name = N'IX_tbOrg_AreaCode')
CREATE NONCLUSTERED INDEX [IX_tbOrg_AreaCode] ON [dbo].[tbOrg] 
(
	[AreaCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbOrg]') AND name = N'IX_tbOrg_IndustrySector')
CREATE NONCLUSTERED INDEX [IX_tbOrg_IndustrySector] ON [dbo].[tbOrg] 
(
	[IndustrySector] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbOrg]') AND name = N'IX_tbOrg_OrganisationStatusCode')
CREATE NONCLUSTERED INDEX [IX_tbOrg_OrganisationStatusCode] ON [dbo].[tbOrg] 
(
	[OrganisationStatusCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbOrg]') AND name = N'IX_tbOrg_OrganisationStatusCodeAccountCode')
CREATE UNIQUE NONCLUSTERED INDEX [IX_tbOrg_OrganisationStatusCodeAccountCode] ON [dbo].[tbOrg] 
(
	[OrganisationStatusCode] ASC,
	[AccountName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbOrg]') AND name = N'IX_tbOrg_OrganisationTypeCode')
CREATE NONCLUSTERED INDEX [IX_tbOrg_OrganisationTypeCode] ON [dbo].[tbOrg] 
(
	[OrganisationTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbOrg]') AND name = N'IX_tbOrg_PaymentTerms')
CREATE NONCLUSTERED INDEX [IX_tbOrg_PaymentTerms] ON [dbo].[tbOrg] 
(
	[PaymentTerms] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbUserMenu]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbUserMenu](
	[UserId] [nvarchar](10) NOT NULL,
	[MenuId] [smallint] NOT NULL,
 CONSTRAINT [PK_tbUserMenu] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[MenuId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbProfileMenuEntry]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbProfileMenuEntry]') AND name = N'RDX_tbProfileMenuEntry_Command')
CREATE NONCLUSTERED INDEX [RDX_tbProfileMenuEntry_Command] ON [dbo].[tbProfileMenuEntry] 
(
	[Command] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbProfileMenuEntry]') AND name = N'RDX_tbProfileMenuEntry_OpenMode')
CREATE NONCLUSTERED INDEX [RDX_tbProfileMenuEntry_OpenMode] ON [dbo].[tbProfileMenuEntry] 
(
	[OpenMode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbSystemDoc]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbUser]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbUser]') AND name = N'IX_tbUser')
CREATE UNIQUE NONCLUSTERED INDEX [IX_tbUser] ON [dbo].[tbUser] 
(
	[LogonName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbUser]') AND name = N'UserName')
CREATE UNIQUE NONCLUSTERED INDEX [UserName] ON [dbo].[tbUser] 
(
	[UserName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbSystemCalendarHoliday]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbSystemCalendarHoliday](
	[CalendarCode] [nvarchar](10) NOT NULL,
	[UnavailableOn] [datetime] NOT NULL,
 CONSTRAINT [PK_tbSystemCalendarHoliday] PRIMARY KEY CLUSTERED 
(
	[CalendarCode] ASC,
	[UnavailableOn] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbSystemCalendarHoliday]') AND name = N'RDX_tbSystemCalendarHoliday_CalendarCode')
CREATE NONCLUSTERED INDEX [RDX_tbSystemCalendarHoliday_CalendarCode] ON [dbo].[tbSystemCalendarHoliday] 
(
	[CalendarCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbSystemDocSpool]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbSystemDocSpool](
	[UserName] [nvarchar](50) NOT NULL CONSTRAINT [DF_tbSystemDocSpool_UserName]  DEFAULT (suser_sname()),
	[DocTypeCode] [smallint] NOT NULL CONSTRAINT [DF_tbSystemDocSpool_DocTypeCode]  DEFAULT ((1)),
	[DocumentNumber] [nvarchar](25) NOT NULL,
	[SpooledOn] [datetime] NOT NULL CONSTRAINT [DF_tbSystemDocSpool_SpooledOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_tbSystemDocSpool] PRIMARY KEY CLUSTERED 
(
	[UserName] ASC,
	[DocTypeCode] ASC,
	[DocumentNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbSystemDocSpool]') AND name = N'RDX_tbSystemDocSpool_DocTypeCode')
CREATE NONCLUSTERED INDEX [RDX_tbSystemDocSpool_DocTypeCode] ON [dbo].[tbSystemDocSpool] 
(
	[DocTypeCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbSystemYear]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbCashCode]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbActivityOp]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbActivityOp]') AND name = N'IX_tbActivityOp_Operation')
CREATE NONCLUSTERED INDEX [IX_tbActivityOp_Operation] ON [dbo].[tbActivityOp] 
(
	[Operation] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbActivityAttribute]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbActivityAttribute]') AND name = N'IX_tbActivityAttribute')
CREATE NONCLUSTERED INDEX [IX_tbActivityAttribute] ON [dbo].[tbActivityAttribute] 
(
	[Attribute] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbActivityAttribute]') AND name = N'IX_tbActivityAttribute_DefaultText')
CREATE NONCLUSTERED INDEX [IX_tbActivityAttribute_DefaultText] ON [dbo].[tbActivityAttribute] 
(
	[DefaultText] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbActivityAttribute]') AND name = N'IX_tbActivityAttribute_OrderBy')
CREATE NONCLUSTERED INDEX [IX_tbActivityAttribute_OrderBy] ON [dbo].[tbActivityAttribute] 
(
	[ActivityCode] ASC,
	[PrintOrder] ASC,
	[Attribute] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbActivityAttribute]') AND name = N'IX_tbActivityAttribute_Type_OrderBy')
CREATE NONCLUSTERED INDEX [IX_tbActivityAttribute_Type_OrderBy] ON [dbo].[tbActivityAttribute] 
(
	[ActivityCode] ASC,
	[AttributeTypeCode] ASC,
	[PrintOrder] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbActivityFlow]') AND type in (N'U'))
BEGIN
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
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbActivityFlow]') AND name = N'IDX_ChildCodeParentCode')
CREATE NONCLUSTERED INDEX [IDX_ChildCodeParentCode] ON [dbo].[tbActivityFlow] 
(
	[ChildCode] ASC,
	[ParentCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbActivityFlow]') AND name = N'IDX_ParentCodeChildCode')
CREATE NONCLUSTERED INDEX [IDX_ParentCodeChildCode] ON [dbo].[tbActivityFlow] 
(
	[ParentCode] ASC,
	[ChildCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbCashCategoryTotal]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbCashCategoryTotal](
	[ParentCode] [nvarchar](10) NOT NULL,
	[ChildCode] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_tbCashCategoryTotal] PRIMARY KEY CLUSTERED 
(
	[ParentCode] ASC,
	[ChildCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbCashCategoryExp]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[tbCashCategoryExp](
	[CategoryCode] [nvarchar](10) NOT NULL,
	[Expression] [nvarchar](256) NOT NULL,
	[Format] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_tbCashCategoryExp] PRIMARY KEY CLUSTERED 
(
	[CategoryCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCashAnalysisCodes]'))
EXEC dbo.sp_executesql @statement = N'




CREATE VIEW [dbo].[vwCashAnalysisCodes]
   AS
SELECT     TOP 100 PERCENT dbo.tbCashCategory.CategoryCode, dbo.tbCashCategory.Category, dbo.tbCashCategoryExp.Expression, 
                      dbo.tbCashCategoryExp.Format
FROM         dbo.tbCashCategory INNER JOIN
                      dbo.tbCashCategoryExp ON dbo.tbCashCategory.CategoryCode = dbo.tbCashCategoryExp.CategoryCode
WHERE     (dbo.tbCashCategory.CategoryTypeCode = 3)
ORDER BY dbo.tbCashCategory.DisplayOrder





'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnCategoryTotalCashCodes]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

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


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwTaskProfit]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwTaskProfit]
AS
SELECT     TOP (100) PERCENT fnTaskProfit_1.StartOn, dbo.tbOrg.AccountCode, dbo.tbTask.TaskCode, dbo.tbSystemYearPeriod.YearNumber, dbo.tbSystemYear.Description, 
                      dbo.tbSystemMonth.MonthName + '' '' + LTRIM(STR(YEAR(dbo.tbSystemYearPeriod.StartOn))) AS Period, dbo.tbTask.ActivityCode, dbo.tbCashCode.CashCode, 
                      dbo.tbTask.TaskTitle, dbo.tbOrg.AccountName, dbo.tbCashCode.CashDescription, dbo.tbTaskStatus.TaskStatus, fnTaskProfit_1.TotalCharge, 
                      fnTaskProfit_1.InvoicedCharge, fnTaskProfit_1.InvoicedChargePaid, fnTaskProfit_1.TotalCost, fnTaskProfit_1.InvoicedCost, fnTaskProfit_1.InvoicedCostPaid, 
                      fnTaskProfit_1.TotalCharge - fnTaskProfit_1.TotalCost AS Profit, fnTaskProfit_1.TotalCharge - fnTaskProfit_1.InvoicedCharge AS UninvoicedCharge, 
                      fnTaskProfit_1.InvoicedCharge - fnTaskProfit_1.InvoicedChargePaid AS UnpaidCharge, fnTaskProfit_1.TotalCost - fnTaskProfit_1.InvoicedCost AS UninvoicedCost, 
                      fnTaskProfit_1.InvoicedCost - fnTaskProfit_1.InvoicedCostPaid AS UnpaidCost, dbo.tbTask.ActionOn, dbo.tbTask.ActionedOn, dbo.tbTask.PaymentOn
FROM         dbo.tbTask INNER JOIN
                      dbo.fnTaskProfit() AS fnTaskProfit_1 ON dbo.tbTask.TaskCode = fnTaskProfit_1.TaskCode INNER JOIN
                      dbo.tbTaskStatus ON dbo.tbTask.TaskStatusCode = dbo.tbTaskStatus.TaskStatusCode INNER JOIN
                      dbo.tbOrg ON dbo.tbTask.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode INNER JOIN
                      dbo.tbSystemYearPeriod ON fnTaskProfit_1.StartOn = dbo.tbSystemYearPeriod.StartOn INNER JOIN
                      dbo.tbSystemYear ON dbo.tbSystemYearPeriod.YearNumber = dbo.tbSystemYear.YearNumber INNER JOIN
                      dbo.tbSystemMonth ON dbo.tbSystemYearPeriod.MonthNumber = dbo.tbSystemMonth.MonthNumber
WHERE     (dbo.tbCashCategory.CashModeCode = 2)
ORDER BY fnTaskProfit_1.StartOn
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaskProfit', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[25] 2[16] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbTask"
            Begin Extent = 
               Top = 22
               Left = 437
               Bottom = 279
               Right = 606
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "fnTaskProfit_1"
            Begin Extent = 
               Top = 20
               Left = 667
               Bottom = 205
               Right = 844
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbTaskStatus"
            Begin Extent = 
               Top = 213
               Left = 666
               Bottom = 298
               Right = 825
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbOrg"
            Begin Extent = 
               Top = 22
               Left = 158
               Bottom = 137
               Right = 356
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbCashCode"
            Begin Extent = 
               Top = 155
               Left = 200
               Bottom = 315
               Right = 358
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbCashCategory"
            Begin Extent = 
               Top = 152
               Left = 16
               Bottom = 267
               Right = 191
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbSystemYearPeriod"
            Begin Extent = 
               Top = 6
               Left = 882
               Bottom = 125
               Right = 1069
            End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaskProfit'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaskProfit', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbSystemYear"
            Begin Extent = 
               Top = 135
               Left = 1017
               Bottom = 254
               Right = 1186
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbSystemMonth"
            Begin Extent = 
               Top = 169
               Left = 836
               Bottom = 258
               Right = 996
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 26
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 2370
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaskProfit'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaskProfit', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaskProfit'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spSystemDocDespool]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spSystemDocDespool]
	(
	@DocTypeCode SMALLINT
	)
AS
	IF @DocTypeCode = 1
		GOTO Quotations
	ELSE IF @DocTypeCode = 2
		GOTO SalesOrder
	ELSE IF @DocTypeCode = 3
		GOTO PurchaseEnquiry
	ELSE IF @DocTypeCode = 4
		GOTO PurchaseOrder
	ELSE IF @DocTypeCode = 5
		GOTO SalesInvoice
	ELSE IF @DocTypeCode = 6
		GOTO CreditNote
	ELSE IF @DocTypeCode = 7
		GOTO DebitNote
		
	RETURN
	
Quotations:
	UPDATE       tbTask
	SET           Spooled = 0, Printed = 1
	FROM            tbTask INNER JOIN
							 tbCashCode ON tbTask.CashCode = tbCashCode.CashCode INNER JOIN
							 tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE        (tbTask.TaskStatusCode = 1) AND (tbCashCategory.CashModeCode = 2) AND (tbTask.Spooled <> 0)
	RETURN
	
SalesOrder:
	UPDATE       tbTask
	SET           Spooled = 0, Printed = 1
	FROM            tbTask INNER JOIN
							 tbCashCode ON tbTask.CashCode = tbCashCode.CashCode INNER JOIN
							 tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE        (tbTask.TaskStatusCode > 1) AND (tbCashCategory.CashModeCode = 2) AND (tbTask.Spooled <> 0)
	RETURN
	
PurchaseEnquiry:
	UPDATE       tbTask
	SET           Spooled = 0, Printed = 1
	FROM            tbTask INNER JOIN
							 tbCashCode ON tbTask.CashCode = tbCashCode.CashCode INNER JOIN
							 tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE        (tbTask.TaskStatusCode = 1) AND (tbCashCategory.CashModeCode = 1) AND (tbTask.Spooled <> 0)	
	RETURN
	
PurchaseOrder:
	UPDATE       tbTask
	SET           Spooled = 0, Printed = 1
	FROM            tbTask INNER JOIN
							 tbCashCode ON tbTask.CashCode = tbCashCode.CashCode INNER JOIN
							 tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE        (tbTask.TaskStatusCode > 1) AND (tbCashCategory.CashModeCode = 1) AND (tbTask.Spooled <> 0)
	RETURN
	
SalesInvoice:
	UPDATE       tbInvoice
	SET                Spooled = 0, Printed = 1
	WHERE        (InvoiceTypeCode = 1) AND (Spooled <> 0)

	RETURN
	
CreditNote:
	UPDATE       tbInvoice
	SET                Spooled = 0, Printed = 1
	WHERE        (InvoiceTypeCode = 2) AND (Spooled <> 0)
	RETURN
	
DebitNote:
	UPDATE       tbInvoice
	SET                Spooled = 0, Printed = 1
	WHERE        (InvoiceTypeCode = 4) AND (Spooled <> 0)
	RETURN' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnSystemDocTaskType]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fnSystemDocTaskType]
	(
	@TaskCode NVARCHAR(20)
	)
RETURNS SMALLINT
AS
	BEGIN
	DECLARE @DocTypeCode SMALLINT
	DECLARE @TaskStatusCode SMALLINT
	DECLARE @CashModeCode SMALLINT
	
	SELECT    @CashModeCode = tbCashCategory.CashModeCode, @TaskStatusCode = tbTask.TaskStatusCode
	FROM            tbTask INNER JOIN
	                         tbCashCode ON tbTask.CashCode = tbCashCode.CashCode INNER JOIN
	                         tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE TaskCode = @TaskCode
	
	SET @DocTypeCode = CASE 
		WHEN @CashModeCode = 1 THEN						--Expense
			CASE WHEN @TaskStatusCode = 1 THEN 3		--Enquiry
				ELSE 4 END			
		WHEN @CashModeCode = 2 THEN						--Income
			CASE WHEN @TaskStatusCode = 1 THEN 1		--Quote
				ELSE 2 END
		END
				
	RETURN @DocTypeCode
	END
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCashAccountStatement]'))
EXEC dbo.sp_executesql @statement = N'
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


'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnCashCurrentBalance]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fnCashCurrentBalance]
	()
RETURNS money
AS
	BEGIN
	declare @CurrentBalance money
	
	SELECT    @CurrentBalance = SUM(tbOrgAccount.CurrentBalance)
	FROM         tbOrgAccount INNER JOIN
	                      tbCashCode ON tbOrgAccount.CashCode = tbCashCode.CashCode
	WHERE     (tbOrgAccount.AccountClosed = 0)
	
	RETURN ISNULL(@CurrentBalance, 0)
	END' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwTaskCashMode]'))
EXEC dbo.sp_executesql @statement = N'



CREATE VIEW [dbo].[vwTaskCashMode]
  AS
SELECT     dbo.tbTask.TaskCode, CASE WHEN tbCashCategory.CategoryCode IS NULL 
                      THEN tbOrgType.CashModeCode ELSE tbCashCategory.CashModeCode END AS CashModeCode
FROM         dbo.tbTask INNER JOIN
                      dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode INNER JOIN
                      dbo.tbOrg ON dbo.tbTask.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbOrgType ON dbo.tbOrg.OrganisationTypeCode = dbo.tbOrgType.OrganisationTypeCode





'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCashPeriods]'))
EXEC dbo.sp_executesql @statement = N'




CREATE VIEW [dbo].[vwCashPeriods]
   AS
SELECT     dbo.tbCashCode.CashCode, dbo.tbSystemYearPeriod.StartOn
FROM         dbo.tbSystemYearPeriod CROSS JOIN
                      dbo.tbCashCode





'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCashPolarData]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwCashPolarData]
AS
SELECT        dbo.tbCashPeriod.CashCode, dbo.tbCashCategory.CashTypeCode, dbo.tbCashPeriod.StartOn, dbo.tbCashPeriod.ForecastValue, dbo.tbCashPeriod.ForecastTax, 
                         dbo.tbCashPeriod.InvoiceValue, dbo.tbCashPeriod.InvoiceTax
FROM            dbo.tbCashPeriod INNER JOIN
                         dbo.tbCashCode ON dbo.tbCashPeriod.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                         dbo.tbSystemYearPeriod ON dbo.tbCashPeriod.StartOn = dbo.tbSystemYearPeriod.StartOn INNER JOIN
                         dbo.tbSystemYear ON dbo.tbSystemYearPeriod.YearNumber = dbo.tbSystemYear.YearNumber INNER JOIN
                         dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode
WHERE        (dbo.tbSystemYear.CashStatusCode < 4)
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwCashPolarData', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[21] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbCashPeriod"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbCashCode"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 135
               Right = 422
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbSystemYearPeriod"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 267
               Right = 232
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbSystemYear"
            Begin Extent = 
               Top = 138
               Left = 270
               Bottom = 267
               Right = 445
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbCashCategory"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 399
               Right = 229
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 2280
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
       ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCashPolarData'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vwCashPolarData', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'  Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCashPolarData'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwCashPolarData', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCashPolarData'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCashFlowNITotals]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwCashFlowNITotals]
AS
SELECT        dbo.tbCashPeriod.StartOn, SUM(dbo.tbCashPeriod.ForecastTax) AS ForecastNI, SUM(dbo.tbCashPeriod.InvoiceTax) AS InvoiceNI
FROM            dbo.tbCashPeriod INNER JOIN
                         dbo.tbCashCode ON dbo.tbCashPeriod.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                         dbo.tbSystemTaxCode ON dbo.tbCashCode.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE        (dbo.tbSystemTaxCode.TaxTypeCode = 3)
GROUP BY dbo.tbCashPeriod.StartOn
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwCashFlowNITotals', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbCashPeriod"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 224
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbCashCode"
            Begin Extent = 
               Top = 6
               Left = 262
               Bottom = 135
               Right = 454
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbSystemTaxCode"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 267
               Right = 224
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 2175
         Alias = 1500
         Table = 1995
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCashFlowNITotals'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwCashFlowNITotals', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCashFlowNITotals'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnTaskDefaultTaxCode]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'



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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spCashCategoryCashCodes]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[spCashCategoryCashCodes]
	(
	@CategoryCode nvarchar(10)
	)
   AS
	SELECT     CashCode, CashDescription
	FROM         tbCashCode
	WHERE     (CategoryCode = @CategoryCode)
	ORDER BY CashDescription
	RETURN 

' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spCashCodeDefaults]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwStatementReserves]'))
EXEC dbo.sp_executesql @statement = N'
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
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwStatementReserves', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbCashEntryType"
            Begin Extent = 
               Top = 6
               Left = 256
               Bottom = 91
               Right = 436
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbOrg"
            Begin Extent = 
               Top = 6
               Left = 474
               Bottom = 121
               Right = 672
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbCashCode"
            Begin Extent = 
               Top = 6
               Left = 710
               Bottom = 121
               Right = 868
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "fnStatementReserves"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 218
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 10
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwStatementReserves'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vwStatementReserves', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'= 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwStatementReserves'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwStatementReserves', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwStatementReserves'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnCashReserveBalance]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fnCashReserveBalance]
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
	END' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskResetChargedUninvoiced]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spTaskResetChargedUninvoiced]
AS
	UPDATE tbTask
	SET TaskStatusCode = 3
	FROM         tbCashCode INNER JOIN
	                      tbTask ON tbCashCode.CashCode = tbTask.CashCode LEFT OUTER JOIN
	                      tbInvoiceTask ON tbTask.TaskCode = tbInvoiceTask.TaskCode AND tbTask.TaskCode = tbInvoiceTask.TaskCode
	WHERE     (tbInvoiceTask.InvoiceNumber IS NULL) AND (tbTask.TaskStatusCode = 4)
	RETURN
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwStatement]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwStatement]
AS
SELECT     TOP (100) PERCENT fnStatementCompany.TransactOn, fnStatementCompany.CashEntryTypeCode, fnStatementCompany.ReferenceCode, 
                      fnStatementCompany.AccountCode, dbo.tbOrg.AccountName, dbo.tbCashEntryType.CashEntryType, fnStatementCompany.PayOut, 
                      fnStatementCompany.PayIn, fnStatementCompany.Balance, dbo.tbCashCode.CashCode, dbo.tbCashCode.CashDescription
FROM         dbo.fnStatementCompany() AS fnStatementCompany INNER JOIN
                      dbo.tbCashEntryType ON fnStatementCompany.CashEntryTypeCode = dbo.tbCashEntryType.CashEntryTypeCode INNER JOIN
                      dbo.tbOrg ON fnStatementCompany.AccountCode = dbo.tbOrg.AccountCode LEFT OUTER JOIN
                      dbo.tbCashCode ON fnStatementCompany.CashCode = dbo.tbCashCode.CashCode
ORDER BY fnStatementCompany.TransactOn, fnStatementCompany.CashEntryTypeCode, fnStatementCompany.ReferenceCode, fnStatementCompany.CashCode
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwStatement', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbCashEntryType"
            Begin Extent = 
               Top = 6
               Left = 256
               Bottom = 91
               Right = 436
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbOrg"
            Begin Extent = 
               Top = 6
               Left = 474
               Bottom = 121
               Right = 672
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbCashCode"
            Begin Extent = 
               Top = 6
               Left = 710
               Bottom = 121
               Right = 868
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "fnStatementCompany"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 218
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 12
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Fi' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwStatement'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vwStatement', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'lter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwStatement'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwStatement', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwStatement'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spActivityWorkFlow]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

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


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spCashCopyForecastToLiveCategory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spCashCopyForecastToLiveCategory]
	(
	@CategoryCode nvarchar(10),
	@StartOn datetime
	)

   AS
	UPDATE tbCashPeriod
	SET     InvoiceValue = ForecastValue, InvoiceTax = ForecastTax
	FROM         tbCashPeriod INNER JOIN
	                      tbCashCode ON tbCashPeriod.CashCode = tbCashCode.CashCode
	WHERE     (tbCashPeriod.StartOn = @StartOn) AND (tbCashCode.CategoryCode = @CategoryCode)




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnTaskIsExpense]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fnTaskIsExpense]
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
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwDocInvoiceTask]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwDocInvoiceTask]
AS
SELECT     dbo.tbInvoiceTask.InvoiceNumber, dbo.tbInvoiceTask.TaskCode, dbo.tbTask.TaskTitle, dbo.tbTask.ActivityCode, dbo.tbInvoiceTask.CashCode, 
                      dbo.tbCashCode.CashDescription, dbo.tbTask.ActionedOn, dbo.tbInvoiceTask.Quantity, dbo.tbActivity.UnitOfMeasure, dbo.tbInvoiceTask.InvoiceValue, 
                      dbo.tbInvoiceTask.TaxValue, dbo.tbInvoiceTask.TaxCode, dbo.tbTask.SecondReference
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbTask ON dbo.tbInvoiceTask.TaskCode = dbo.tbTask.TaskCode AND dbo.tbInvoiceTask.TaskCode = dbo.tbTask.TaskCode INNER JOIN
                      dbo.tbCashCode ON dbo.tbInvoiceTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbActivity ON dbo.tbTask.ActivityCode = dbo.tbActivity.ActivityCode
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwDocInvoiceTask', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[34] 4[27] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbInvoiceTask"
            Begin Extent = 
               Top = 34
               Left = 246
               Bottom = 273
               Right = 399
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbTask"
            Begin Extent = 
               Top = 31
               Left = 487
               Bottom = 265
               Right = 656
            End
            DisplayFlags = 280
            TopColumn = 4
         End
         Begin Table = "tbCashCode"
            Begin Extent = 
               Top = 46
               Left = 34
               Bottom = 161
               Right = 192
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbActivity"
            Begin Extent = 
               Top = 6
               Left = 694
               Bottom = 121
               Right = 853
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwDocInvoiceTask'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwDocInvoiceTask', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwDocInvoiceTask'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwDocInvoiceItem]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwDocInvoiceItem]
AS
SELECT     dbo.tbInvoiceItem.InvoiceNumber, dbo.tbInvoiceItem.CashCode, dbo.tbCashCode.CashDescription, dbo.tbInvoice.InvoicedOn AS ActionedOn, 
                      dbo.tbInvoiceItem.TaxCode, dbo.tbInvoiceItem.InvoiceValue, dbo.tbInvoiceItem.TaxValue, dbo.tbInvoiceItem.ItemReference
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.tbCashCode ON dbo.tbInvoiceItem.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwDocInvoiceItem', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbInvoiceItem"
            Begin Extent = 
               Top = 34
               Left = 286
               Bottom = 261
               Right = 439
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbCashCode"
            Begin Extent = 
               Top = 41
               Left = 507
               Bottom = 156
               Right = 665
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbInvoice"
            Begin Extent = 
               Top = 33
               Left = 48
               Bottom = 224
               Right = 220
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwDocInvoiceItem'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwDocInvoiceItem', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwDocInvoiceItem'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spActivityMode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

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


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spCashCopyLiveToForecastCashCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spCashCopyLiveToForecastCashCode]
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
		SELECT     StartOn, InvoiceValue, InvoiceTax
		FROM         tbCashPeriod
		WHERE     (StartOn <= @EndPeriod AND StartOn >= @StartPeriod) and (CashCode = @CashCode)
		ORDER BY	CashCode, StartOn	
		
	while @Years > 0
		begin
		open curPe

		fetch next from curPe into @StartPeriod, @InvoiceValue, @InvoiceTax
		while @@FETCH_STATUS = 0
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
			fetch next from curPe into @StartPeriod, @InvoiceValue, @InvoiceTax
			end
		
		set @Years = @Years - 1
		close curPe
		end
		
	deallocate curPe
			
	return 

LastMonthCopyMode:
declare @Idx integer

	SELECT TOP 1 @InvoiceValue = InvoiceValue, @InvoiceTax = InvoiceTax
	FROM         tbCashPeriod
	WHERE     (CashCode = @CashCode) AND (StartOn < @CurPeriod)
	ORDER BY StartOn DESC
		
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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spCashCopyForecastToLiveCashCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spCashCopyForecastToLiveCashCode]
	(
	@CashCode nvarchar(50),
	@StartOn datetime
	)

   AS
	UPDATE tbCashPeriod
	SET     InvoiceValue = ForecastValue, InvoiceTax = ForecastTax
	FROM         tbCashPeriod
	WHERE     (CashCode = @CashCode) AND (StartOn = @StartOn)
	RETURN 




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCashActiveYears]'))
EXEC dbo.sp_executesql @statement = N'




CREATE VIEW [dbo].[vwCashActiveYears]
   AS
SELECT     TOP 100 PERCENT dbo.tbSystemYear.YearNumber, dbo.tbSystemYear.Description, dbo.tbCashStatus.CashStatus
FROM         dbo.tbSystemYear INNER JOIN
                      dbo.tbCashStatus ON dbo.tbSystemYear.CashStatusCode = dbo.tbCashStatus.CashStatusCode
WHERE     (dbo.tbSystemYear.CashStatusCode < 4)
ORDER BY dbo.tbSystemYear.YearNumber




'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnSystemCashCode]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'


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



' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnStatementTaxAccount]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

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


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnTaxTypeDueDates]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

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



' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwSystemCorpTaxCashCode]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwSystemCorpTaxCashCode]
  AS
SELECT     CashCode, MonthNumber, RecurrenceCode
FROM         dbo.tbCashTaxType
WHERE     (TaxTypeCode = 1)


'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwSystemVatCashCode]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwSystemVatCashCode]
  AS
SELECT     CashCode, MonthNumber, RecurrenceCode
FROM         dbo.tbCashTaxType
WHERE     (TaxTypeCode = 2)


'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwSystemNICashCode]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwSystemNICashCode]
  AS
SELECT     CashCode, MonthNumber, RecurrenceCode
FROM         dbo.tbCashTaxType
WHERE     (TaxTypeCode = 3)


'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spCashCategoryTotals]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnOrgRebuildInvoiceItems]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
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

' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwOrgRebuildInvoicedItems]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwOrgRebuildInvoicedItems]
AS
SELECT     dbo.tbInvoice.AccountCode, dbo.tbInvoiceType.CashModeCode, dbo.tbInvoice.CollectOn, dbo.tbInvoiceItem.InvoiceNumber, 
                      dbo.tbInvoiceItem.CashCode, '''' AS TaskCode, dbo.tbInvoiceItem.InvoiceValue, dbo.tbInvoiceItem.TaxValue, dbo.tbInvoiceItem.PaidValue, 
                      dbo.tbInvoiceItem.PaidTaxValue
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwOrgRebuildInvoicedItems', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbInvoiceItem"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 191
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbInvoice"
            Begin Extent = 
               Top = 6
               Left = 229
               Bottom = 121
               Right = 401
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbInvoiceType"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 203
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwOrgRebuildInvoicedItems'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwOrgRebuildInvoicedItems', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwOrgRebuildInvoicedItems'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwInvoiceTaxBase]'))
EXEC dbo.sp_executesql @statement = N'

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




'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwInvoiceOutstandingItems]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwInvoiceOutstandingItems]
  AS
SELECT     InvoiceNumber, '''' AS TaskCode, CashCode, TaxCode, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS OutstandingValue, 
                      CASE WHEN InvoiceValue = 0 THEN 0 ELSE TaxValue / InvoiceValue END AS TaxRate
FROM         dbo.tbInvoiceItem


'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnCashCodeDefaultAccount]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
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
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwDocInvoice]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwDocInvoice]
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
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwDocInvoice', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[27] 2[14] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbInvoice"
            Begin Extent = 
               Top = 5
               Left = 206
               Bottom = 288
               Right = 378
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbOrg"
            Begin Extent = 
               Top = 23
               Left = 417
               Bottom = 239
               Right = 615
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbInvoiceType"
            Begin Extent = 
               Top = 72
               Left = 0
               Bottom = 187
               Right = 168
            End
            DisplayFlags = 344
            TopColumn = 0
         End
         Begin Table = "tbUser"
            Begin Extent = 
               Top = 12
               Left = 2
               Bottom = 127
               Right = 165
            End
            DisplayFlags = 344
            TopColumn = 0
         End
         Begin Table = "tbInvoiceStatus"
            Begin Extent = 
               Top = 130
               Left = 10
               Bottom = 215
               Right = 182
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbOrgAddress"
            Begin Extent = 
               Top = 45
               Left = 636
               Bottom = 160
               Right = 788
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 10
         Width = 284
         Width = 1500
         Width' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwDocInvoice'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vwDocInvoice', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwDocInvoice'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwDocInvoice', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwDocInvoice'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskFullyInvoiced]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spTaskFullyInvoiced]
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
		
	RETURN' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskReconcileCharge]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spTaskReconcileCharge]
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
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnOrgRebuildInvoiceTasks]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
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
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spInvoiceAddTask]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwTaskInvoiceValue]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwTaskInvoiceValue]
AS
SELECT        TaskCode, SUM(InvoiceValue) AS InvoiceValue, SUM(TaxValue) AS InvoiceTax
FROM            dbo.tbInvoiceTask
GROUP BY TaskCode
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaskInvoiceValue', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbInvoiceTask"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 201
               Right = 209
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaskInvoiceValue'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaskInvoiceValue', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaskInvoiceValue'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwInvoiceOutstandingTasks]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwInvoiceOutstandingTasks]
  AS
SELECT     InvoiceNumber, TaskCode, CashCode, TaxCode, (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) AS OutstandingValue, 
                      CASE WHEN InvoiceValue = 0 THEN 0 ELSE TaxValue / InvoiceValue END AS TaxRate
FROM         dbo.tbInvoiceTask


'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwTaskInvoicedQuantity]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [dbo].[vwTaskInvoicedQuantity]
  AS
SELECT     dbo.tbInvoiceTask.TaskCode, SUM(dbo.tbInvoiceTask.Quantity) AS InvoiceQuantity
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber
WHERE     (dbo.tbInvoice.InvoiceTypeCode = 1) OR
                      (dbo.tbInvoice.InvoiceTypeCode = 3)
GROUP BY dbo.tbInvoiceTask.TaskCode

'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnTaskProfitOrder]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fnTaskProfitOrder]
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
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwOrgRebuildInvoicedTasks]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwOrgRebuildInvoicedTasks]
AS
SELECT     dbo.tbInvoice.AccountCode, dbo.tbInvoiceType.CashModeCode, dbo.tbInvoice.CollectOn, dbo.tbInvoiceTask.InvoiceNumber, 
                      dbo.tbInvoiceTask.CashCode, dbo.tbInvoiceTask.TaskCode, dbo.tbInvoiceTask.InvoiceValue, dbo.tbInvoiceTask.TaxValue, 
                      dbo.tbInvoiceTask.PaidValue, dbo.tbInvoiceTask.PaidTaxValue
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwOrgRebuildInvoicedTasks', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbInvoiceTask"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 191
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbInvoice"
            Begin Extent = 
               Top = 6
               Left = 229
               Bottom = 121
               Right = 401
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbInvoiceType"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 203
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 2265
         Alias = 900
         Table = 2055
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwOrgRebuildInvoicedTasks'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwOrgRebuildInvoicedTasks', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwOrgRebuildInvoicedTasks'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwOrgBalanceOutstanding]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwOrgBalanceOutstanding]
  AS
SELECT     dbo.tbInvoice.AccountCode, SUM(CASE dbo.tbInvoiceType.CashModeCode WHEN 1 THEN ((InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue)) 
                      * - 1 WHEN 2 THEN (InvoiceValue + TaxValue) - (PaidValue + PaidTaxValue) END) AS Balance
FROM         dbo.tbInvoice INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
WHERE     (dbo.tbInvoice.InvoiceStatusCode > 1 AND dbo.tbInvoice.InvoiceStatusCode < 4)
GROUP BY dbo.tbInvoice.AccountCode




'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwInvoiceSummaryTotals]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [dbo].[vwInvoiceSummaryTotals]
  AS
SELECT     dbo.vwInvoiceSummaryBase.StartOn, dbo.vwInvoiceSummaryBase.InvoiceTypeCode, dbo.tbInvoiceType.InvoiceType, 
                      SUM(dbo.vwInvoiceSummaryBase.InvoiceValue) AS TotalInvoiceValue, SUM(dbo.vwInvoiceSummaryBase.TaxValue) AS TotalTaxValue
FROM         dbo.vwInvoiceSummaryBase INNER JOIN
                      dbo.tbInvoiceType ON dbo.vwInvoiceSummaryBase.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
GROUP BY dbo.vwInvoiceSummaryBase.StartOn, dbo.vwInvoiceSummaryBase.InvoiceTypeCode, dbo.tbInvoiceType.InvoiceType

'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCashSummaryInvoices]'))
EXEC dbo.sp_executesql @statement = N'

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


'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwAccountStatementInvoices]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwAccountStatementInvoices]
  AS
SELECT     TOP 100 PERCENT dbo.tbInvoice.AccountCode, dbo.tbInvoice.InvoicedOn AS TransactedOn, 1 AS OrderBy, dbo.tbInvoice.InvoiceNumber AS Reference, 
                      dbo.tbInvoiceType.InvoiceType AS StatementType, 
                      CASE CashModeCode WHEN 1 THEN dbo.tbInvoice.InvoiceValue + dbo.tbInvoice.TaxValue WHEN 2 THEN (dbo.tbInvoice.InvoiceValue + dbo.tbInvoice.TaxValue)
                       * - 1 END AS Charge
FROM         dbo.tbInvoice INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
ORDER BY dbo.tbInvoice.AccountCode, dbo.tbInvoice.InvoicedOn


'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskEmailAddress]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnTaskEmailAddress]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fnTaskEmailAddress]
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
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spOrgAddContact]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwOrgMailContacts]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwOrgMailContacts]
  AS
SELECT     AccountCode, ContactName, NickName, NameTitle + N'' '' + ContactName AS FormalName, JobTitle, Department
FROM         dbo.tbOrgContact
WHERE     (OnMailingList <> 0)


'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnOrgStatement]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

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

' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spOrgDefaultTaxCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spOrgDefaultAccountCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



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
	set @ParsedName = ''''

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
		
	if charindex('' '', @ParsedName) = 0
		begin
		set @FirstWord = @ParsedName
		set @SecondWord = ''''
		end
	else
		begin
		set @FirstWord = left(@ParsedName, charindex('' '', @ParsedName) - 1)
		set @SecondWord = right(@ParsedName, len(@ParsedName) - charindex('' '', @ParsedName))
		if charindex('' '', @SecondWord) > 0
			set @SecondWord = left(@SecondWord, charindex('' '', @SecondWord) - 1)
		end

	if exists(select ExcludedTag from tbSystemCodeExclusion where ExcludedTag = @SecondWord)
		begin
		set @SecondWord = ''''
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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spSettingInitialised]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



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





' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spPaymentPostInvoiced]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

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

' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwDocCompany]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwDocCompany]
AS
SELECT     dbo.tbOrg.AccountName AS CompanyName, dbo.tbOrgAddress.Address AS CompanyAddress, dbo.tbOrg.PhoneNumber AS CompanyPhoneNumber, 
                      dbo.tbOrg.FaxNumber AS CompanyFaxNumber, dbo.tbOrg.EmailAddress AS CompanyEmailAddress, dbo.tbOrg.WebSite AS CompanyWebsite, 
                      dbo.tbOrg.CompanyNumber, dbo.tbOrg.VatNumber, dbo.tbOrg.Logo
FROM         dbo.tbOrg INNER JOIN
                      dbo.tbSystemOptions ON dbo.tbOrg.AccountCode = dbo.tbSystemOptions.AccountCode LEFT OUTER JOIN
                      dbo.tbOrgAddress ON dbo.tbOrg.AddressCode = dbo.tbOrgAddress.AddressCode
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwDocCompany', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbOrg"
            Begin Extent = 
               Top = 18
               Left = 205
               Bottom = 310
               Right = 403
            End
            DisplayFlags = 280
            TopColumn = 14
         End
         Begin Table = "tbSystemOptions"
            Begin Extent = 
               Top = 125
               Left = 11
               Bottom = 240
               Right = 187
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbOrgAddress"
            Begin Extent = 
               Top = 35
               Left = 398
               Bottom = 150
               Right = 550
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwDocCompany'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwDocCompany', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwDocCompany'
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgAddress_TriggerInsert]'))
EXEC dbo.sp_executesql @statement = N'







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

'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spSystemCompanyName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [dbo].[spSystemCompanyName]
	(
	@AccountName nvarchar(255) = null output
	)
  AS
	SELECT top 1 @AccountName = tbOrg.AccountName
	FROM         tbOrg INNER JOIN
	                      tbSystemOptions ON tbOrg.AccountCode = tbSystemOptions.AccountCode
	RETURN 


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCashAccountRebuild]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwCashAccountRebuild]
  AS
SELECT     dbo.tbOrgPayment.CashAccountCode, dbo.tbOrgAccount.OpeningBalance, 
                      dbo.tbOrgAccount.OpeningBalance + SUM(dbo.tbOrgPayment.PaidInValue - dbo.tbOrgPayment.PaidOutValue) AS CurrentBalance
FROM         dbo.tbOrgPayment INNER JOIN
                      dbo.tbOrgAccount ON dbo.tbOrgPayment.CashAccountCode = dbo.tbOrgAccount.CashAccountCode
WHERE     (dbo.tbOrgPayment.PaymentStatusCode > 1)
GROUP BY dbo.tbOrgPayment.CashAccountCode, dbo.tbOrgAccount.OpeningBalance


'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnCashAccountStatement]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

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


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnCashCompanyBalance]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [dbo].[fnCashCompanyBalance]
	()
RETURNS MONEY
  AS
	BEGIN
	DECLARE @CurrentBalance MONEY
	
	SELECT  @CurrentBalance = SUM(tbOrgAccount.CurrentBalance)
	FROM         tbOrgAccount 
	WHERE     (tbOrgAccount.AccountClosed = 0)
	
	RETURN ISNULL(@CurrentBalance, 0)
	END

' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spOrgAddAddress]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spOrgNextAddressCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



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
	set @AddressCode = upper(@AccountCode) + ''_'' + stuff(''000'', 4 - len(ltrim(str(@AddCount))), len(ltrim(str(@AddCount))), @AddCount)
	
	RETURN




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwAccountStatementPayments]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwAccountStatementPayments]
  AS
SELECT     TOP 100 PERCENT dbo.tbOrgPayment.AccountCode, dbo.tbOrgPayment.PaidOn AS TransactedOn, 2 AS OrderBy, 
                      dbo.tbOrgPayment.PaymentReference AS Reference, dbo.tbOrgPaymentStatus.PaymentStatus AS StatementType, 
                      CASE WHEN PaidInValue > 0 THEN PaidInValue ELSE PaidOutValue * - 1 END AS Charge
FROM         dbo.tbOrgPayment INNER JOIN
                      dbo.tbOrgPaymentStatus ON dbo.tbOrgPayment.PaymentStatusCode = dbo.tbOrgPaymentStatus.PaymentStatusCode
ORDER BY dbo.tbOrgPayment.AccountCode, dbo.tbOrgPayment.PaidOn

'
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgPayment_TriggerUpdate]'))
EXEC dbo.sp_executesql @statement = N'
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

'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spPaymentPost]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnOrgIndustrySectors]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

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
		set @IndustrySector = ''''
		declare cur cursor local for
			select IndustrySector from tbOrgSector where AccountCode = @AccountCode
		open cur
		fetch next from cur into @Sector
		while @@FETCH_STATUS = 0
			begin
			if len(@IndustrySector) = 0
				set @IndustrySector = @Sector
			else if len(@IndustrySector) <= 200
				set @IndustrySector = @IndustrySector + '', '' + @Sector
			
			fetch next from cur into @Sector
			end
			
		close cur
		deallocate cur
		
		end	
	
	RETURN @IndustrySector
	END

' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spMenuInsert]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'




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
				values (@MenuId, 1, 0, @MenuName, 0, ''Root'')
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






' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnSystemProfileText]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'



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





' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnSystemBuckets]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'




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





' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnSystemAdjustToCalendar]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'



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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spSettingAddCalDateRange]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'





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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spSettingDelCalDateRange]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'




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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnTaxVatTotals]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

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


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spSettingLicenceAdd]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'





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





' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spSettingLicence]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'




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





' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnSystemActivePeriod]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fnSystemActivePeriod]
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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCashMonthList]'))
EXEC dbo.sp_executesql @statement = N'



CREATE VIEW [dbo].[vwCashMonthList]
  AS
SELECT DISTINCT 
                      TOP 100 PERCENT CAST(dbo.tbSystemYearPeriod.StartOn AS float) AS StartOn, dbo.tbSystemMonth.MonthName, 
                      dbo.tbSystemYearPeriod.MonthNumber
FROM         dbo.tbSystemYearPeriod INNER JOIN
                      dbo.fnSystemActivePeriod() AS fnSystemActivePeriod ON dbo.tbSystemYearPeriod.YearNumber = fnSystemActivePeriod.YearNumber INNER JOIN
                      dbo.tbSystemMonth ON dbo.tbSystemYearPeriod.MonthNumber = dbo.tbSystemMonth.MonthNumber
ORDER BY StartOn




'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spSystemYearPeriods]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'




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





' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnSystemTaxHorizon]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fnSystemTaxHorizon]	()
RETURNS SMALLINT
AS
	BEGIN
	DECLARE @TaxHorizon SMALLINT
	SELECT @TaxHorizon = TaxHorizon FROM tbSystemOptions
	RETURN @TaxHorizon
	END
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnSystemCompanyAccount]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fnSystemCompanyAccount]()
RETURNS NVARCHAR(10)
AS
	BEGIN
	DECLARE @AccountCode NVARCHAR(10)
	SELECT @AccountCode = AccountCode FROM tbSystemOptions
	RETURN @AccountCode
	END
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwSystemTaxRates]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwSystemTaxRates]
AS
SELECT     TaxCode, CAST(TaxRate AS MONEY) AS TaxRate, TaxTypeCode
FROM         tbSystemTaxCode
'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnSystemHistoryStartOn]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fnSystemHistoryStartOn]()
RETURNS DATETIME
AS
	BEGIN
	DECLARE @StartOn DATETIME
	SELECT  @StartOn = MIN(tbSystemYearPeriod.StartOn)
	FROM            tbSystemYear INNER JOIN
	                         tbSystemYearPeriod ON tbSystemYear.YearNumber = tbSystemYearPeriod.YearNumber
	WHERE        (tbSystemYear.CashStatusCode < 4)
	
	RETURN @StartOn
	END
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCorpTaxTasks]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwCorpTaxTasks]
  AS
SELECT     dbo.vwCorpTaxTasksBase.StartOn, SUM(dbo.vwCorpTaxTasksBase.OrderValue) AS NetProfit, 
                      dbo.vwCorpTaxTasksBase.OrderValue * dbo.tbSystemYearPeriod.CorporationTaxRate AS CorporationTax
FROM         dbo.vwCorpTaxTasksBase INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.vwCorpTaxTasksBase.StartOn = dbo.tbSystemYearPeriod.StartOn
GROUP BY dbo.vwCorpTaxTasksBase.StartOn, dbo.vwCorpTaxTasksBase.OrderValue * dbo.tbSystemYearPeriod.CorporationTaxRate


'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnAccountPeriod]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

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

' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spCashCodeValues]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spCashCodeValues]
	(
	@CashCode nvarchar(50),
	@YearNumber smallint
	)
    AS
	SELECT        vwCashFlowData.StartOn, vwCashFlowData.InvoiceValue, vwCashFlowData.InvoiceTax, vwCashFlowData.ForecastValue, vwCashFlowData.ForecastTax
	FROM            tbSystemYearPeriod INNER JOIN
	                         vwCashFlowData ON tbSystemYearPeriod.StartOn = vwCashFlowData.StartOn
	WHERE        (tbSystemYearPeriod.YearNumber = @YearNumber) AND (vwCashFlowData.CashCode = @CashCode)
	ORDER BY vwCashFlowData.StartOn
	
	RETURN 
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskDelete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskAssignToParent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
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





' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskIsProject]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskOp]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spTaskOp]
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
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskParent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spTaskParent] 
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
		
	RETURN' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskProject]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwUserCredentials]'))
EXEC dbo.sp_executesql @statement = N'


CREATE VIEW [dbo].[vwUserCredentials]
  AS
SELECT     UserId, UserName, LogonName, Administrator
FROM         dbo.tbUser
WHERE     (LogonName = SUSER_SNAME())



'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spSystemReassignUser]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



CREATE PROCEDURE [dbo].[spSystemReassignUser] 
	(
	@UserId nvarchar(10)
	)
  AS
	UPDATE    tbUser
	SET       LogonName = (SUSER_SNAME())
	WHERE     (UserId = @UserId)
	
	RETURN





' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnTimestamp]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fnTimestamp]
	(
	@Now datetime
	)
RETURNS NVARCHAR(20)
AS
	BEGIN
	DECLARE @Timestamp NVARCHAR(20)
	SET @Timestamp = LTRIM(STR(Year(@Now))) + ''/''
		+ dbo.fnPad(LTRIM(STR(Month(@Now))), 2) + ''/''
		+ dbo.fnPad(LTRIM(STR(Day(@Now))), 2) + '' ''
		+ dbo.fnPad(LTRIM(STR(DatePart(hh, @Now))), 2) + '':''
		+ dbo.fnPad(LTRIM(STR(DatePart(n, @Now))), 2) + '':''
		+ dbo.fnPad(LTRIM(STR(DatePart(s, @Now))), 2)
	RETURN @Timestamp
	END
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskSetActionOn]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spTaskSetActionOn]
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
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskSetOpStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spTaskSetOpStatus]
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
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwSystemDocSpool]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwSystemDocSpool]
 AS
SELECT     DocTypeCode, DocumentNumber
FROM         tbSystemDocSpool
WHERE     (UserName = SUSER_SNAME())
'
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[tbInvoice_TriggerUpdate]'))
EXEC dbo.sp_executesql @statement = N'CREATE TRIGGER [dbo].[tbInvoice_TriggerUpdate]
ON [dbo].[tbInvoice]
FOR UPDATE
AS
	IF UPDATE (Spooled)
		BEGIN
		INSERT INTO tbSystemDocSpool (DocTypeCode, DocumentNumber)
		SELECT     dbo.fnSystemDocInvoiceType(i.InvoiceTypeCode) AS DocTypeCode, i.InvoiceNumber
		FROM         inserted i 
		WHERE     (i.Spooled <> 0)

				
		DELETE tbSystemDocSpool
		FROM         inserted i INNER JOIN
		                      tbSystemDocSpool ON i.InvoiceNumber = tbSystemDocSpool.DocumentNumber
		WHERE    (i.Spooled = 0) AND (tbSystemDocSpool.DocTypeCode > 4)
		END
'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spActivityNextStepNumber]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



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





' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spActivityParent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

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


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spCashCategoryCodeFromName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'




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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCashCategoriesBank]'))
EXEC dbo.sp_executesql @statement = N'




CREATE VIEW [dbo].[vwCashCategoriesBank]
   AS
SELECT     TOP 100 PERCENT CategoryCode, Category, CashModeCode
FROM         dbo.tbCashCategory
WHERE     (CashTypeCode = 4) AND (CategoryTypeCode = 1)
GROUP BY CategoryCode, Category, DisplayOrder, CashModeCode
ORDER BY DisplayOrder, Category





'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCashCategoriesNominal]'))
EXEC dbo.sp_executesql @statement = N'




CREATE VIEW [dbo].[vwCashCategoriesNominal]
   AS
SELECT     TOP 100 PERCENT CategoryCode, Category, CashModeCode
FROM         dbo.tbCashCategory
WHERE     (CashTypeCode = 3) AND (CategoryTypeCode = 1)
GROUP BY CategoryCode, Category, DisplayOrder, CashModeCode
ORDER BY DisplayOrder, Category





'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCashCategoriesTotals]'))
EXEC dbo.sp_executesql @statement = N'




CREATE VIEW [dbo].[vwCashCategoriesTotals]
   AS
SELECT     TOP 100 PERCENT CategoryCode, CashModeCode, CashTypeCode, DisplayOrder, Category
FROM         dbo.tbCashCategory
WHERE     (CategoryTypeCode = 2)
ORDER BY CashTypeCode, CategoryCode




'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCashCategoriesTax]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwCashCategoriesTax]
AS
SELECT        TOP (100) PERCENT CategoryCode, Category, CashModeCode
FROM            dbo.tbCashCategory
WHERE        (CashTypeCode = 2) AND (CategoryTypeCode = 1)
GROUP BY CategoryCode, Category, DisplayOrder, CashModeCode
ORDER BY DisplayOrder, Category
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwCashCategoriesTax', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbCashCategory"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 245
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 2700
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCashCategoriesTax'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwCashCategoriesTax', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCashCategoriesTax'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCashCategoriesTrade]'))
EXEC dbo.sp_executesql @statement = N'




CREATE VIEW [dbo].[vwCashCategoriesTrade]
   AS
SELECT     TOP 100 PERCENT CategoryCode, Category, CashModeCode
FROM         dbo.tbCashCategory
WHERE     (CashTypeCode = 1) AND (CategoryTypeCode = 1)
GROUP BY CategoryCode, Category, DisplayOrder, CashModeCode
ORDER BY DisplayOrder, Category




'
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[tbTask_TriggerUpdate]'))
EXEC dbo.sp_executesql @statement = N'CREATE TRIGGER [dbo].[tbTask_TriggerUpdate]
ON [dbo].[tbTask]
FOR UPDATE
AS
	IF UPDATE (Spooled)
		BEGIN
		INSERT INTO tbSystemDocSpool (DocTypeCode, DocumentNumber)
		SELECT     dbo.fnSystemDocTaskType(i.TaskCode) AS DocTypeCode, i.TaskCode
		FROM         inserted i 
		WHERE     (i.Spooled <> 0)

				
		DELETE tbSystemDocSpool
		FROM         inserted i INNER JOIN
		                      tbSystemDocSpool ON i.TaskCode = tbSystemDocSpool.DocumentNumber
		WHERE    (i.Spooled = 0) AND (tbSystemDocSpool.DocTypeCode <= 4)
		END
'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwDocTaskCode]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwDocTaskCode]
AS
SELECT     dbo.fnTaskEmailAddress(dbo.tbTask.TaskCode) AS EmailAddress, dbo.tbTask.TaskCode, dbo.tbTask.TaskStatusCode, dbo.tbTaskStatus.TaskStatus, 
                      dbo.tbTask.ContactName, dbo.tbOrgContact.NickName, dbo.tbUser.UserName, dbo.tbOrg.AccountName, dbo.tbOrgAddress.Address AS InvoiceAddress, 
                      tbOrg_1.AccountName AS DeliveryAccountName, tbOrgAddress_1.Address AS DeliveryAddress, tbOrg_2.AccountName AS CollectionAccountName, 
                      tbOrgAddress_2.Address AS CollectionAddress, dbo.tbTask.AccountCode, dbo.tbTask.TaskNotes, dbo.tbTask.ActivityCode, dbo.tbTask.ActionOn, 
                      dbo.tbActivity.UnitOfMeasure, dbo.tbTask.Quantity, dbo.tbSystemTaxCode.TaxCode, dbo.tbSystemTaxCode.TaxRate, dbo.tbTask.UnitCharge, dbo.tbTask.TotalCharge, 
                      dbo.tbUser.MobileNumber, dbo.tbUser.Signature, dbo.tbTask.TaskTitle, dbo.tbTask.PaymentOn, dbo.tbTask.SecondReference, dbo.tbOrg.PaymentTerms
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
                      dbo.tbOrgContact ON dbo.tbTask.ContactName = dbo.tbOrgContact.ContactName AND dbo.tbTask.AccountCode = dbo.tbOrgContact.AccountCode LEFT OUTER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbTask.TaxCode = dbo.tbSystemTaxCode.TaxCode
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwDocTaskCode', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[21] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -93
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbOrg_2"
            Begin Extent = 
               Top = 314
               Left = 736
               Bottom = 429
               Right = 934
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbOrgAddress_2"
            Begin Extent = 
               Top = 313
               Left = 528
               Bottom = 428
               Right = 680
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbTaskStatus"
            Begin Extent = 
               Top = 381
               Left = 228
               Bottom = 466
               Right = 387
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbUser"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 201
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbActivity"
            Begin Extent = 
               Top = 6
               Left = 239
               Bottom = 121
               Right = 398
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbTask"
            Begin Extent = 
               Top = 121
               Left = 210
               Bottom = 376
               Right = 379
            End
            DisplayFlags = 280
            TopColumn = 12
         End
         Begin Table = "tbOrg"
            Begin Extent = 
               Top = 130
               Left = 404
               Bottom = 360
               Right = 602
            End
            Dis' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwDocTaskCode'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vwDocTaskCode', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'playFlags = 280
            TopColumn = 13
         End
         Begin Table = "tbOrgAddress"
            Begin Extent = 
               Top = 17
               Left = 570
               Bottom = 132
               Right = 722
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbOrgAddress_1"
            Begin Extent = 
               Top = 149
               Left = 631
               Bottom = 264
               Right = 783
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbOrg_1"
            Begin Extent = 
               Top = 63
               Left = 860
               Bottom = 178
               Right = 1058
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbOrgContact"
            Begin Extent = 
               Top = 366
               Left = 38
               Bottom = 481
               Right = 190
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbSystemTaxCode"
            Begin Extent = 
               Top = 205
               Left = 0
               Bottom = 320
               Right = 152
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 13
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 2250
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwDocTaskCode'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwDocTaskCode', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwDocTaskCode'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwTaskProfitOrders]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwTaskProfitOrders]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbTask.ActionOn) AS StartOn, dbo.tbTask.TaskCode, 
                      CASE WHEN dbo.tbCashCategory.CashModeCode = 1 THEN dbo.tbTask.TotalCharge * - 1 ELSE dbo.tbTask.TotalCharge END AS TotalCharge
FROM         dbo.tbCashCode INNER JOIN
                      dbo.tbTask ON dbo.tbCashCode.CashCode = dbo.tbTask.CashCode INNER JOIN
                      dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode LEFT OUTER JOIN
                      dbo.tbTask AS tbTask_1 RIGHT OUTER JOIN
                      dbo.tbTaskFlow ON tbTask_1.TaskCode = dbo.tbTaskFlow.ParentTaskCode ON dbo.tbTask.TaskCode = dbo.tbTaskFlow.ChildTaskCode
WHERE     (dbo.tbTask.TaskStatusCode > 1) AND (dbo.tbTaskFlow.ParentTaskCode IS NULL) AND (tbTask_1.CashCode IS NULL) AND (dbo.tbTask.TaskStatusCode < 5) AND 
                      (dbo.tbTask.ActionOn >= dbo.fnSystemHistoryStartOn()) OR
                      (dbo.tbTask.TaskStatusCode > 1) AND (tbTask_1.CashCode IS NULL) AND (dbo.tbTask.TaskStatusCode < 5) AND (dbo.tbTask.ActionOn >= dbo.fnSystemHistoryStartOn())
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaskProfitOrders', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbCashCode"
            Begin Extent = 
               Top = 130
               Left = 255
               Bottom = 292
               Right = 413
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbTask"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 264
               Right = 207
            End
            DisplayFlags = 280
            TopColumn = 6
         End
         Begin Table = "tbCashCategory"
            Begin Extent = 
               Top = 129
               Left = 442
               Bottom = 244
               Right = 617
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbTask_1"
            Begin Extent = 
               Top = 6
               Left = 444
               Bottom = 121
               Right = 613
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbTaskFlow"
            Begin Extent = 
               Top = 6
               Left = 245
               Bottom = 121
               Right = 406
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1500
         Alias = 9' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaskProfitOrders'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaskProfitOrders', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'00
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaskProfitOrders'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaskProfitOrders', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaskProfitOrders'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwStatementTasksConfirmed]'))
EXEC dbo.sp_executesql @statement = N'
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
'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwStatementTasksFull]'))
EXEC dbo.sp_executesql @statement = N'
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
'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCashCodeOrderSummary]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwCashCodeOrderSummary]
AS
SELECT        dbo.tbTask.CashCode, dbo.fnAccountPeriod(dbo.tbTask.ActionOn) AS StartOn, SUM(dbo.tbTask.TotalCharge) - ISNULL(dbo.vwTaskInvoiceValue.InvoiceValue, 0) 
                         AS InvoiceValue, SUM(dbo.tbTask.TotalCharge * ISNULL(dbo.vwSystemTaxRates.TaxRate, 0)) - ISNULL(dbo.vwTaskInvoiceValue.InvoiceTax, 0) AS InvoiceTax
FROM            dbo.tbTask INNER JOIN
                         dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode LEFT OUTER JOIN
                         dbo.vwTaskInvoiceValue ON dbo.tbTask.TaskCode = dbo.vwTaskInvoiceValue.TaskCode LEFT OUTER JOIN
                         dbo.vwSystemTaxRates ON dbo.tbTask.TaxCode = dbo.vwSystemTaxRates.TaxCode
WHERE        (dbo.tbTask.TaskStatusCode = 2) OR
                         (dbo.tbTask.TaskStatusCode = 3)
GROUP BY dbo.tbTask.CashCode, dbo.fnAccountPeriod(dbo.tbTask.ActionOn), dbo.vwTaskInvoiceValue.InvoiceValue, dbo.vwTaskInvoiceValue.InvoiceTax
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwCashCodeOrderSummary', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbTask"
            Begin Extent = 
               Top = 4
               Left = 309
               Bottom = 238
               Right = 512
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbCashCode"
            Begin Extent = 
               Top = 138
               Left = 13
               Bottom = 267
               Right = 205
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "vwSystemTaxRates"
            Begin Extent = 
               Top = 0
               Left = 75
               Bottom = 112
               Right = 261
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "vwTaskInvoiceValue"
            Begin Extent = 
               Top = 17
               Left = 625
               Bottom = 129
               Right = 811
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 3135
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCashCodeOrderSummary'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vwCashCodeOrderSummary', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCashCodeOrderSummary'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwCashCodeOrderSummary', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCashCodeOrderSummary'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spInvoicePay]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spInvoicePay]
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
	

	SET @PaymentCode = @UserId + ''_'' + LTRIM(STR(Year(@Now)))
		+ dbo.fnPad(LTRIM(STR(Month(@Now))), 2)
		+ dbo.fnPad(LTRIM(STR(Day(@Now))), 2)
		+ dbo.fnPad(LTRIM(STR(DatePart(hh, @Now))), 2)
		+ dbo.fnPad(LTRIM(STR(DatePart(n, @Now))), 2)
		+ dbo.fnPad(LTRIM(STR(DatePart(s, @Now))), 2)
	
	WHILE EXISTS (SELECT PaymentCode FROM tbOrgPayment WHERE PaymentCode = @PaymentCode)
		BEGIN
		SET @Now = DATEADD(s, 1, @Now)
		SET @PaymentCode = @UserId + ''_'' + LTRIM(STR(Year(@Now)))
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
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwTaskVatConfirmed]'))
EXEC dbo.sp_executesql @statement = N'
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
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaskVatConfirmed', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbTask"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 207
            End
            DisplayFlags = 280
            TopColumn = 8
         End
         Begin Table = "tbCashCode"
            Begin Extent = 
               Top = 6
               Left = 245
               Bottom = 121
               Right = 403
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbCashCategory"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 213
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbSystemTaxCode"
            Begin Extent = 
               Top = 126
               Left = 251
               Bottom = 241
               Right = 403
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "vwTaskInvoicedQuantity"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 331
               Right = 261
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 11625' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaskVatConfirmed'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaskVatConfirmed', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'
         Alias = 900
         Table = 1905
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaskVatConfirmed'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaskVatConfirmed', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaskVatConfirmed'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwTaskVatFull]'))
EXEC dbo.sp_executesql @statement = N'
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
'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnStatementReserves]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fnStatementReserves] ()
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

	--Corporation Tax
	IF EXISTS (SELECT        tbOrgAccount.CashAccountCode
		FROM            tbCashTaxType INNER JOIN
								 tbOrgAccount ON tbCashTaxType.CashAccountCode = tbOrgAccount.CashAccountCode LEFT OUTER JOIN
								 tbCashCode ON tbOrgAccount.CashCode = tbCashCode.CashCode
		WHERE        (tbCashTaxType.TaxTypeCode = 1) AND (tbCashCode.CashCode IS NULL))
		BEGIN
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
		SELECT ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
		FROM dbo.fnStatementTaxEntries(1)
		ORDER BY TransactOn		
		END

	--VAT
	IF EXISTS (SELECT        tbOrgAccount.CashAccountCode
		FROM            tbCashTaxType INNER JOIN
								 tbOrgAccount ON tbCashTaxType.CashAccountCode = tbOrgAccount.CashAccountCode LEFT OUTER JOIN
								 tbCashCode ON tbOrgAccount.CashCode = tbCashCode.CashCode
		WHERE        (tbCashTaxType.TaxTypeCode = 2) AND (tbCashCode.CashCode IS NULL))
		BEGIN	
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
		SELECT ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
		FROM dbo.fnStatementTaxEntries(2)
		ORDER BY TransactOn		
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


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spCashCopyLiveToForecastCategory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'




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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwInvoiceRegisterTasks]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwInvoiceRegisterTasks]
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
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceRegisterTasks', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[43] 4[19] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbInvoice"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 210
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbOrg"
            Begin Extent = 
               Top = 6
               Left = 248
               Bottom = 121
               Right = 446
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbInvoiceType"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 203
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbInvoiceStatus"
            Begin Extent = 
               Top = 126
               Left = 241
               Bottom = 211
               Right = 413
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbUser"
            Begin Extent = 
               Top = 216
               Left = 241
               Bottom = 331
               Right = 404
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbInvoiceTask"
            Begin Extent = 
               Top = 21
               Left = 498
               Bottom = 136
               Right = 651
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbCashCode"
            Begin Extent = 
               Top = 189
               Left = 662
               Bottom = 304
               Right = 820
            End
         ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceRegisterTasks'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceRegisterTasks', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'   DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbSystemTaxCode"
            Begin Extent = 
               Top = 186
               Left = 431
               Bottom = 301
               Right = 583
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbTask"
            Begin Extent = 
               Top = 16
               Left = 689
               Bottom = 270
               Right = 858
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceRegisterTasks'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceRegisterTasks', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceRegisterTasks'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwInvoiceRegisterItems]'))
EXEC dbo.sp_executesql @statement = N'

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


'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCashCodeForecastSummary]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwCashCodeForecastSummary]
AS
SELECT        dbo.tbTask.CashCode, dbo.fnAccountPeriod(dbo.tbTask.ActionOn) AS StartOn, SUM(dbo.tbTask.TotalCharge) AS ForecastValue, 
                         SUM(dbo.tbTask.TotalCharge * ISNULL(dbo.vwSystemTaxRates.TaxRate, 0)) AS ForecastTax
FROM            dbo.tbTask INNER JOIN
                         dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                         dbo.tbInvoiceTask ON dbo.tbTask.TaskCode = dbo.tbInvoiceTask.TaskCode AND dbo.tbTask.TaskCode = dbo.tbInvoiceTask.TaskCode LEFT OUTER JOIN
                         dbo.vwSystemTaxRates ON dbo.tbTask.TaxCode = dbo.vwSystemTaxRates.TaxCode
GROUP BY dbo.tbTask.CashCode, dbo.fnAccountPeriod(dbo.tbTask.ActionOn)
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwCashCodeForecastSummary', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbTask"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 241
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbCashCode"
            Begin Extent = 
               Top = 6
               Left = 279
               Bottom = 135
               Right = 471
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "vwSystemTaxRates"
            Begin Extent = 
               Top = 114
               Left = 509
               Bottom = 226
               Right = 695
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 2970
         Alias = 1290
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 3435
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCashCodeForecastSummary'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwCashCodeForecastSummary', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCashCodeForecastSummary'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCashFlowData]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwCashFlowData]
AS
SELECT        dbo.tbSystemYearPeriod.YearNumber, dbo.tbSystemYearPeriod.StartOn, dbo.vwCashPolarData.CashCode, dbo.vwCashPolarData.InvoiceValue, 
                         dbo.vwCashPolarData.InvoiceTax, dbo.vwCashPolarData.ForecastValue, dbo.vwCashPolarData.ForecastTax
FROM            dbo.tbSystemYearPeriod INNER JOIN
                         dbo.vwCashPolarData ON dbo.tbSystemYearPeriod.StartOn = dbo.vwCashPolarData.StartOn
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwCashFlowData', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbSystemYearPeriod"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 232
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "vwCashPolarData"
            Begin Extent = 
               Top = 6
               Left = 270
               Bottom = 202
               Right = 440
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCashFlowData'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwCashFlowData', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCashFlowData'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spCashGeneratePeriods]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


CREATE PROCEDURE [dbo].[spCashGeneratePeriods]
    AS
declare @YearNumber smallint
declare @StartOn datetime
declare @PeriodStartOn datetime
declare @CashStatusCode smallint
declare @Period smallint

	declare curYr cursor for	
		SELECT     YearNumber, CONVERT(datetime, ''1/'' + STR(StartMonth) + ''/'' + STR(YearNumber), 103) AS StartOn, CashStatusCode
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






' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spSettingNewCompany]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
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
	VALUES     (@UserId, @FirstNames + N'' '' + @LastName, SUSER_SNAME(), @CalendarCode, @LandLine, @Fax, @Email, 1)

	INSERT INTO tbUserMenu
	                      (UserId, MenuId)
	VALUES     (@UserId, @MenuId)

	set @AppAccountCode = left(@AccountCode, 10)
	set @TaxCode = ''T0''
	
	INSERT INTO tbOrg
	                      (AccountCode, AccountName, OrganisationTypeCode, OrganisationStatusCode, PhoneNumber, FaxNumber, EmailAddress, WebSite, CompanyNumber, 
	                      VatNumber, TaxCode)
	VALUES     (@AppAccountCode, @CompanyName, 8, 2, @LandLine, @Fax, @Email, @Website, @CompanyNumber, @VatNumber, @TaxCode)

	exec dbo.spOrgNextAddressCode @AppAccountCode, @AddressCode output
	
	insert into tbOrgAddress (AddressCode, AccountCode, Address)
	values (@AddressCode, @AppAccountCode, @CompanyAddress)

	INSERT INTO tbOrgContact
	                      (AccountCode, ContactName, FileAs, NickName, PhoneNumber, FaxNumber, EmailAddress)
	VALUES     (@AppAccountCode, @FirstNames + N'' '' + @LastName, @LastName + N'', '' + @FirstNames, @FirstNames, @LandLine, @Fax, @Email)	 

	SELECT @SqlDataVersion = DataVersion
	FROM         tbSystemInstall
	WHERE     (CategoryTypeCode = 0) AND (ReleaseTypeCode = 0)

	INSERT INTO tbOrgAccount
						(AccountCode, CashAccountCode, CashAccountName)
	VALUES     (@AccountCode, N''CASH'', N''Petty Cash'')	

	INSERT INTO tbSystemOptions
						(Identifier, Initialised, SQLDataVersion, AccountCode, DefaultPrintMode, BucketTypeCode, BucketIntervalCode, ShowCashGraphs)
	VALUES     (N''TC'', 0, @SQLDataVersion, @AppAccountCode, 2, 1, 2, 1)
	
	update tbCashTaxType
	set CashCode = N''900''
	where TaxTypeCode = 3
	
	update tbCashTaxType
	set CashCode = N''902''
	where TaxTypeCode = 1
	
	update tbCashTaxType
	set CashCode = N''901''
	where TaxTypeCode = 2
	
	update tbCashTaxType
	set CashCode = N''903''
	where TaxTypeCode = 4
	
	RETURN 1 



' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spPaymentPostMisc]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
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

	set @InvoiceSuffix = ''.'' + @UserId
	
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
							 (InvoiceNumber, UserId, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, CollectOn, InvoiceValue, TaxValue, PaidValue, PaidTaxValue, Printed)
	SELECT        @InvoiceNumber AS InvoiceNumber, tbOrgPayment.UserId, tbOrgPayment.AccountCode, @InvoiceTypeCode AS InvoiceTypeCode, 4 AS InvoiceStatusCode, 
							 tbOrgPayment.PaidOn, tbOrgPayment.PaidOn AS CollectOn, CASE WHEN PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate) 
							 WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate) END AS InvoiceValue, 
							 CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - ROUND((tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate)), 2) 
							 WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - ROUND((tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate)), 2) 
							 END AS TaxValue, CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate) 
							 WHEN PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate) END AS PaidValue, 
							 CASE WHEN tbOrgPayment.PaidInValue > 0 THEN tbOrgPayment.PaidInValue - ROUND((tbOrgPayment.PaidInValue / (1 + vwSystemTaxRates.TaxRate)), 2) 
							 WHEN tbOrgPayment.PaidOutValue > 0 THEN tbOrgPayment.PaidOutValue - ROUND((tbOrgPayment.PaidOutValue / (1 + vwSystemTaxRates.TaxRate)), 2) 
							 END AS PaidTaxValue, 1 AS Printed
	FROM            tbOrgPayment INNER JOIN
							 vwSystemTaxRates ON tbOrgPayment.TaxCode = vwSystemTaxRates.TaxCode
	WHERE        (tbOrgPayment.PaymentCode = @PaymentCode)

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
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spInvoiceTotal]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
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
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spInvoiceAccept]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

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


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwInvoiceVatItems]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwInvoiceVatItems]
AS
SELECT     TOP (100) PERCENT dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoice.InvoiceNumber, dbo.tbInvoice.InvoiceTypeCode, 
                      dbo.tbInvoiceItem.TaxCode, dbo.tbInvoiceItem.InvoiceValue, dbo.tbInvoiceItem.TaxValue, dbo.tbOrg.ForeignJurisdiction, 
                      dbo.tbInvoiceItem.CashCode AS IdentityCode
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbInvoiceItem.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 2)
ORDER BY StartOn
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceVatItems', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbInvoiceItem"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 199
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbInvoice"
            Begin Extent = 
               Top = 6
               Left = 237
               Bottom = 125
               Right = 417
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbOrg"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbSystemTaxCode"
            Begin Extent = 
               Top = 126
               Left = 282
               Bottom = 245
               Right = 442
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceVatItems'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceVatItems', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceVatItems'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwInvoiceSummaryItems]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwInvoiceSummaryItems]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN tbInvoice.InvoiceTypeCode = 2 THEN 1 ELSE CASE WHEN tbInvoice.InvoiceTypeCode = 4 THEN 3 ELSE tbInvoice.InvoiceTypeCode END END AS InvoiceTypeCode,
                       CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.InvoiceValue * - 1 ELSE dbo.tbInvoiceItem.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.TaxValue * - 1 ELSE dbo.tbInvoiceItem.TaxValue END AS TaxValue
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
WHERE     (dbo.tbInvoice.InvoicedOn >= dbo.fnSystemHistoryStartOn())
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceSummaryItems', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbInvoiceItem"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 191
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbInvoice"
            Begin Extent = 
               Top = 6
               Left = 229
               Bottom = 156
               Right = 401
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbInvoiceType"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 203
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceSummaryItems'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceSummaryItems', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceSummaryItems'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwInvoiceRegister]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwInvoiceRegister]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoice.InvoiceNumber, dbo.tbInvoice.AccountCode, dbo.tbInvoice.InvoiceTypeCode, 
                      dbo.tbInvoice.InvoiceStatusCode, dbo.tbInvoice.InvoicedOn, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoice.InvoiceValue * - 1 ELSE dbo.tbInvoice.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoice.TaxValue * - 1 ELSE dbo.tbInvoice.TaxValue END AS TaxValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoice.PaidValue * - 1 ELSE dbo.tbInvoice.PaidValue END AS PaidValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoice.PaidTaxValue * - 1 ELSE dbo.tbInvoice.PaidTaxValue END AS PaidTaxValue, 
                      dbo.tbInvoice.PaymentTerms, dbo.tbInvoice.Notes, dbo.tbInvoice.Printed, dbo.tbOrg.AccountName, dbo.tbUser.UserName, dbo.tbInvoiceStatus.InvoiceStatus, 
                      dbo.tbInvoiceType.CashModeCode, dbo.tbInvoiceType.InvoiceType
FROM         dbo.tbInvoice INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode INNER JOIN
                      dbo.tbInvoiceStatus ON dbo.tbInvoice.InvoiceStatusCode = dbo.tbInvoiceStatus.InvoiceStatusCode INNER JOIN
                      dbo.tbUser ON dbo.tbInvoice.UserId = dbo.tbUser.UserId
WHERE     (dbo.tbInvoice.AccountCode <> dbo.fnSystemCompanyAccount())
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceRegister', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbInvoice"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 218
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbOrg"
            Begin Extent = 
               Top = 6
               Left = 256
               Bottom = 125
               Right = 462
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbInvoiceType"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 211
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbInvoiceStatus"
            Begin Extent = 
               Top = 126
               Left = 249
               Bottom = 215
               Right = 429
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbUser"
            Begin Extent = 
               Top = 216
               Left = 249
               Bottom = 335
               Right = 420
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
    ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceRegister'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceRegister', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'     Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceRegister'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceRegister', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceRegister'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spInvoiceCancel]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwInvoiceVatTasks]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwInvoiceVatTasks]
AS
SELECT     TOP (100) PERCENT dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, dbo.tbInvoiceTask.InvoiceNumber, dbo.tbInvoice.InvoiceTypeCode, 
                      dbo.tbInvoiceTask.TaxCode, dbo.tbInvoiceTask.InvoiceValue, dbo.tbInvoiceTask.TaxValue, dbo.tbOrg.ForeignJurisdiction, 
                      dbo.tbInvoiceTask.TaskCode AS IdentityCode
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbOrg ON dbo.tbInvoice.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                      dbo.tbSystemTaxCode ON dbo.tbInvoiceTask.TaxCode = dbo.tbSystemTaxCode.TaxCode
WHERE     (dbo.tbSystemTaxCode.TaxTypeCode = 2)
ORDER BY StartOn
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceVatTasks', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbInvoiceTask"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 199
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "tbInvoice"
            Begin Extent = 
               Top = 6
               Left = 237
               Bottom = 125
               Right = 417
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbOrg"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbSystemTaxCode"
            Begin Extent = 
               Top = 126
               Left = 282
               Bottom = 245
               Right = 442
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceVatTasks'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceVatTasks', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceVatTasks'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwInvoiceSummaryTasks]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwInvoiceSummaryTasks]
AS
SELECT     dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN tbInvoice.InvoiceTypeCode = 2 THEN 1 ELSE CASE WHEN tbInvoice.InvoiceTypeCode = 4 THEN 3 ELSE tbInvoice.InvoiceTypeCode END END AS InvoiceTypeCode,
                       CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.InvoiceValue * - 1 ELSE dbo.tbInvoiceTask.InvoiceValue END AS InvoiceValue, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.TaxValue * - 1 ELSE dbo.tbInvoiceTask.TaxValue END AS TaxValue
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
WHERE     (dbo.tbInvoice.InvoicedOn >= dbo.fnSystemHistoryStartOn())
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceSummaryTasks', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbInvoiceTask"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 191
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbInvoice"
            Begin Extent = 
               Top = 6
               Left = 229
               Bottom = 169
               Right = 401
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbInvoiceType"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 203
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceSummaryTasks'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceSummaryTasks', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceSummaryTasks'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskProfit]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spTaskProfit]
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
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnTaskProfitCost]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fnTaskProfitCost]
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
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spOrgBalanceOutstanding]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskEmailDetail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spOrgStatement]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

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


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnTaskDefaultPaymentOn]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fnTaskDefaultPaymentOn]
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
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwOrgDatasheet]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwOrgDatasheet]
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
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwOrgDatasheet', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbOrg"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 236
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbOrgStatus"
            Begin Extent = 
               Top = 6
               Left = 274
               Bottom = 91
               Right = 472
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbOrgType"
            Begin Extent = 
               Top = 96
               Left = 274
               Bottom = 196
               Right = 465
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbSystemTaxCode"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 190
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbOrgAddress"
            Begin Extent = 
               Top = 198
               Left = 228
               Bottom = 313
               Right = 380
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "vwOrgTaskCount"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 331
               Right = 190
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column =' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwOrgDatasheet'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vwOrgDatasheet', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwOrgDatasheet'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwOrgDatasheet', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwOrgDatasheet'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwOrgAddresses]'))
EXEC dbo.sp_executesql @statement = N'

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


'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskEmailFooter]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnCashAccountStatements]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

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


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spCashAccountRebuild]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

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

' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spCashAccountRebuildAll]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

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


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskSetStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spTaskSetStatus]
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


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnSystemVatBalance]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'



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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnTaxVatStatement]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fnTaxVatStatement]
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


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnTaxCorpStatement]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fnTaxCorpStatement]
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
	SELECT     StartOn, ROUND(CorporationTax, 2), 0 As TaxPaid, 0 AS Balance
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


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnTaxCorpOrderTotals]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fnTaxCorpOrderTotals]
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

' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwInvoiceOutstandingBase]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwInvoiceOutstandingBase]
  AS
SELECT     InvoiceNumber AS InvoiceNumber, TaskCode AS TaskCode, 
                      CashCode AS CashCode, TaxCode AS TaxCode, OutstandingValue, TaxRate
FROM         dbo.vwInvoiceOutstandingItems
UNION
SELECT     InvoiceNumber AS InvoiceNumber, TaskCode AS TaskCode, 
                      CashCode AS CashCode, TaxCode AS TaxCode, OutstandingValue, TaxRate
FROM         dbo.vwInvoiceOutstandingTasks


'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwInvoiceSummaryMargin]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwInvoiceSummaryMargin]
  AS
SELECT     StartOn, 5 AS InvoiceTypeCode, dbo.fnSystemProfileText(3004) AS InvoiceType, SUM(TotalInvoiceValue) AS TotalInvoiceValue, SUM(TotalTaxValue) 
                      AS TotalTaxValue
FROM         dbo.vwInvoiceSummaryTotals
GROUP BY StartOn



'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwInvoiceTaxSummary]'))
EXEC dbo.sp_executesql @statement = N'



CREATE VIEW [dbo].[vwInvoiceTaxSummary]
  AS
SELECT     InvoiceNumber, TaxCode, SUM(InvoiceValueTotal) AS InvoiceValueTotal, SUM(TaxValueTotal) AS TaxValueTotal, SUM(TaxValueTotal) 
                      / SUM(InvoiceValueTotal) AS TaxRate
FROM         dbo.vwInvoiceTaxBase
GROUP BY InvoiceNumber, TaxCode




'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskNextCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

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
		                      
	set @TaskCode = @UserId + ''_'' + dbo.fnPad(ltrim(str(@NextTaskNumber)), 4)
			                      
	RETURN 


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwTaxCorpStatement]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwTaxCorpStatement]
AS
SELECT     TOP (100) PERCENT StartOn, TaxDue, TaxPaid, Balance
FROM         dbo.fnTaxCorpStatement() AS fnTaxCorpStatement
WHERE     (StartOn > dbo.fnSystemHistoryStartOn())
ORDER BY StartOn, TaxDue
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaxCorpStatement', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "fnTaxCorpStatement"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 198
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaxCorpStatement'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaxCorpStatement', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaxCorpStatement'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwTaxVatTotals]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwTaxVatTotals]
AS
SELECT     TOP (100) PERCENT dbo.tbSystemYear.YearNumber, dbo.tbSystemYear.Description, 
                      dbo.tbSystemMonth.MonthName + '' '' + LTRIM(STR(YEAR(dbo.tbSystemYearPeriod.StartOn))) AS Period, fnTaxVatTotals.StartOn, fnTaxVatTotals.HomeSales, 
                      fnTaxVatTotals.HomePurchases, fnTaxVatTotals.ExportSales, fnTaxVatTotals.ExportPurchases, fnTaxVatTotals.HomeSalesVat, fnTaxVatTotals.HomePurchasesVat, 
                      fnTaxVatTotals.ExportSalesVat, fnTaxVatTotals.ExportPurchasesVat, fnTaxVatTotals.VatAdjustment, fnTaxVatTotals.VatDue
FROM         dbo.fnTaxVatTotals() AS fnTaxVatTotals INNER JOIN
                      dbo.tbSystemYearPeriod ON fnTaxVatTotals.StartOn = dbo.tbSystemYearPeriod.StartOn INNER JOIN
                      dbo.tbSystemMonth ON dbo.tbSystemYearPeriod.MonthNumber = dbo.tbSystemMonth.MonthNumber INNER JOIN
                      dbo.tbSystemYear ON dbo.tbSystemYearPeriod.YearNumber = dbo.tbSystemYear.YearNumber
WHERE     (dbo.tbSystemYear.CashStatusCode = 2) OR
                      (dbo.tbSystemYear.CashStatusCode = 3)
ORDER BY fnTaxVatTotals.StartOn
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaxVatTotals', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[35] 4[26] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "fnTaxVatTotals"
            Begin Extent = 
               Top = 9
               Left = 68
               Bottom = 243
               Right = 246
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbSystemYearPeriod"
            Begin Extent = 
               Top = 59
               Left = 374
               Bottom = 174
               Right = 553
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbSystemMonth"
            Begin Extent = 
               Top = 152
               Left = 692
               Bottom = 237
               Right = 844
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbSystemYear"
            Begin Extent = 
               Top = 29
               Left = 690
               Bottom = 144
               Right = 851
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 15
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1950
         Output = 720
         Append = 1400
         NewValue = 1170
      ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaxVatTotals'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaxVatTotals', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'   SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaxVatTotals'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaxVatTotals', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaxVatTotals'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnNetProfitCashCodes]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

CREATE FUNCTION [dbo].[fnNetProfitCashCodes]
	()
RETURNS @tbCashCode TABLE (CashCode nvarchar(50))
  AS
	BEGIN
	declare @CategoryCode nvarchar(10)
	select @CategoryCode = NetProfitCode from tbSystemOptions	
	set @CategoryCode = isnull(@CategoryCode, '''')
	if (@CategoryCode != '''')
		begin
		insert into @tbCashCode (CashCode)
		select CashCode from dbo.fnCategoryTotalCashCodes(@CategoryCode)
		end
	RETURN
	END


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwOrgRebuildInvoices]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwOrgRebuildInvoices]
AS
SELECT     AccountCode, CashModeCode, CollectOn, InvoiceNumber, CashCode, TaskCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
FROM         dbo.vwOrgRebuildInvoicedTasks
UNION
SELECT     AccountCode, CashModeCode, CollectOn, InvoiceNumber, CashCode, TaskCode, InvoiceValue, TaxValue, PaidValue, PaidTaxValue
FROM         dbo.vwOrgRebuildInvoicedItems
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwOrgRebuildInvoices', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "vwOrgRebuildInvoicedTasks"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 194
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwOrgRebuildInvoices'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwOrgRebuildInvoices', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwOrgRebuildInvoices'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spSystemPeriodClose]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spSystemPeriodClose]
   AS

	if exists(select * from dbo.fnSystemActivePeriod())
		begin
		declare @StartOn datetime
		declare @YearNumber smallint
		
		select @StartOn = StartOn, @YearNumber = YearNumber
		from fnSystemActivePeriod() fnSystemActivePeriod
		 		
		begin tran
	
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

' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spSystemPeriodGetYear]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spSystemPeriodGetYear]
	(
	@StartOn DATETIME,
	@YearNumber INTEGER OUTPUT
	)
AS
	SELECT @YearNumber = YearNumber
	FROM            tbSystemYearPeriod
	WHERE        (StartOn = @StartOn)
	
	IF @YearNumber IS NULL
		SELECT @YearNumber = YearNumber FROM dbo.fnSystemActivePeriod()
		
	RETURN
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskWorkFlow]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



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



' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnTaskCost]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fnTaskCost]
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
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskCost]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
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

' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskDefaultDocType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spTaskDefaultDocType]
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
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskMode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskDefaultInvoiceType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

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


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spSystemAdjustToCalendar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spSystemAdjustToCalendar]
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
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskScheduleOp]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
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

' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnSystemDateBucket]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'






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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnTaxVatOrderTotals]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
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



' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskDefaultTaxCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



CREATE PROCEDURE [dbo].[spTaskDefaultTaxCode] 
	(
	@AccountCode nvarchar(10),
	@CashCode nvarchar(50),
	@TaxCode nvarchar(10) OUTPUT
	)
  AS

	set @TaxCode = dbo.fnTaskDefaultTaxCode(@AccountCode, @CashCode)
		
	RETURN




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwAccountStatementPaymentBase]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwAccountStatementPaymentBase]
  AS
SELECT     AccountCode, TransactedOn, OrderBy, Reference, StatementType, SUM(Charge) AS Charge
FROM         dbo.vwAccountStatementPayments
GROUP BY AccountCode, TransactedOn, OrderBy, Reference, StatementType


'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskCopy]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spTaskCopy]
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
	
	IF (ISNULL(@ParentTaskCode, '''') = '''')
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
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskConfigure]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
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
	                                 (TaskCode = @ParentTaskCode) AND (ContactName <> N''''))
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
			
			if len(isnull(@ContactName, '''')) > 0
				begin
				set @NickName = left(@ContactName, charindex('' '', @ContactName, 1))
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




' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[Trigger_tbTask_Update]'))
EXEC dbo.sp_executesql @statement = N'CREATE TRIGGER [dbo].[Trigger_tbTask_Update]
ON [dbo].[tbTask] 
FOR UPDATE
AS
	IF UPDATE (ContactName)
		begin
		if exists (SELECT     ContactName
		           FROM         inserted AS i
		           WHERE     (NOT (ContactName IS NULL)) AND
		                                 (ContactName <> N''''))
			begin
			if not exists(SELECT     tbOrgContact.ContactName
			              FROM         inserted AS i INNER JOIN
			                                    tbOrgContact ON i.AccountCode = tbOrgContact.AccountCode AND i.ContactName = tbOrgContact.ContactName)
				begin
				declare @FileAs nvarchar(100)
				declare @ContactName nvarchar(100)
				declare @NickName nvarchar(100)
								
				select TOP 1 @ContactName = isnull(ContactName, '''') from inserted	 
				
				if len(@ContactName) > 0
					begin
					set @NickName = left(@ContactName, charindex('' '', @ContactName, 1))
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
'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCorpTaxTasksBase]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwCorpTaxTasksBase]
AS
SELECT     TOP 100 PERCENT dbo.tbTask.TaskCode, dbo.tbTaskStatus.TaskStatus, dbo.fnAccountPeriod(dbo.tbTask.PaymentOn) AS StartOn, 
                      CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0))) 
                      * - 1 ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) END AS OrderValue
FROM         dbo.tbTaskStatus INNER JOIN
                      dbo.fnNetProfitCashCodes() AS fnNetProfitCashCodes INNER JOIN
                      dbo.tbCashCategory INNER JOIN
                      dbo.tbCashCode ON dbo.tbCashCategory.CategoryCode = dbo.tbCashCode.CategoryCode ON 
                      fnNetProfitCashCodes.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                      dbo.tbTask ON fnNetProfitCashCodes.CashCode = dbo.tbTask.CashCode ON dbo.tbTaskStatus.TaskStatusCode = dbo.tbTask.TaskStatusCode LEFT OUTER JOIN
                      dbo.vwTaskInvoicedQuantity ON dbo.tbTask.TaskCode = dbo.vwTaskInvoicedQuantity.TaskCode
WHERE     (dbo.tbTask.TaskStatusCode < 4) AND (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0) > 0)
'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCorpTaxConfirmedBase]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwCorpTaxConfirmedBase]
AS
SELECT        TOP (100) PERCENT dbo.fnAccountPeriod(dbo.tbTask.PaymentOn) AS StartOn, 
                         CASE WHEN tbCashCategory.CashModeCode = 1 THEN (dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0))) 
                         * - 1 ELSE dbo.tbTask.UnitCharge * (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0)) END AS OrderValue
FROM            dbo.vwTaskInvoicedQuantity RIGHT OUTER JOIN
                         dbo.fnNetProfitCashCodes() AS fnNetProfitCashCodes INNER JOIN
                         dbo.tbCashCategory INNER JOIN
                         dbo.tbCashCode ON dbo.tbCashCategory.CategoryCode = dbo.tbCashCode.CategoryCode ON 
                         fnNetProfitCashCodes.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                         dbo.tbTask ON fnNetProfitCashCodes.CashCode = dbo.tbTask.CashCode ON dbo.vwTaskInvoicedQuantity.TaskCode = dbo.tbTask.TaskCode
WHERE        (dbo.tbTask.TaskStatusCode > 1) AND (dbo.tbTask.TaskStatusCode < 4) AND (dbo.tbTask.Quantity - ISNULL(dbo.vwTaskInvoicedQuantity.InvoiceQuantity, 0) > 0) AND 
                         (dbo.tbTask.PaymentOn <= DATEADD(d, dbo.fnSystemTaxHorizon(), GETDATE()))
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwCorpTaxConfirmedBase', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "vwTaskInvoicedQuantity"
            Begin Extent = 
               Top = 34
               Left = 832
               Bottom = 124
               Right = 1065
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "fnNetProfitCashCodes"
            Begin Extent = 
               Top = 6
               Left = 234
               Bottom = 76
               Right = 509
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbCashCategory"
            Begin Extent = 
               Top = 78
               Left = 234
               Bottom = 193
               Right = 409
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbCashCode"
            Begin Extent = 
               Top = 96
               Left = 38
               Bottom = 211
               Right = 196
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbTask"
            Begin Extent = 
               Top = 21
               Left = 588
               Bottom = 136
               Right = 757
            End
            DisplayFlags = 280
            TopColumn = 6
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCorpTaxConfirmedBase'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vwCorpTaxConfirmedBase', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'4770
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCorpTaxConfirmedBase'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwCorpTaxConfirmedBase', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCorpTaxConfirmedBase'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spStatementRescheduleOverdue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spStatementRescheduleOverdue]
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

' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spOrgRebuild]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
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
			
		if isnull(@TaskCode, '''') = ''''
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
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnStatementTaxEntries]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fnStatementTaxEntries](@TaxTypeCode smallint)
RETURNS @tbTax TABLE (
	AccountCode nvarchar(10),
	CashCode nvarchar(50),
	TransactOn datetime,
	CashEntryTypeCode smallint,
	ReferenceCode nvarchar(20),
	PayIn money,
	PayOut money	 
	)
AS
	BEGIN
	declare @AccountCode nvarchar(10)
	declare @CashCode nvarchar(50)
	declare @TransactOn datetime
	declare @InvoiceReferenceCode nvarchar(20) 
	declare @OrderReferenceCode nvarchar(20)
	declare @CashEntryTypeCode smallint
	declare @PayOut money
	declare @PayIn money
	declare @Balance money
	
	SET @InvoiceReferenceCode = dbo.fnSystemProfileText(1214)	
	SET @OrderReferenceCode = dbo.fnSystemProfileText(1215)	

	IF @TaxTypeCode = 1
		GOTO CorporationTax
	ELSE IF @TaxTypeCode = 2
		GOTO VatTax

	RETURN

CorporationTax:

	SELECT @AccountCode = AccountCode FROM tbCashTaxType WHERE (TaxTypeCode = 1) 
	SET @CashCode = dbo.fnSystemCashCode(1)
	
	DECLARE curCorp CURSOR LOCAL FOR
		SELECT     StartOn, ROUND(TaxDue, 0) AS PayOut, ROUND(TaxPaid, 0) AS PayIn, Balance
		FROM         vwTaxCorpStatement
		ORDER BY StartOn DESC
	
	OPEN curCorp
	FETCH NEXT FROM curCorp INTO @TransactOn, @PayOut, @PayIn, @Balance
	WHILE (@@FETCH_STATUS = 0 AND ROUND(@Balance, 0) != 0)
		BEGIN		
		IF @PayOut > 0
			BEGIN
			INSERT INTO @tbTax (AccountCode, CashCode, TransactOn, CashEntryTypeCode, ReferenceCode, PayOut, PayIn)
			VALUES (@AccountCode, @CashCode, @TransactOn, 5, @InvoiceReferenceCode, @PayOut, 0)
			END
		ELSE	
			BEGIN	
			SET @PayIn = @PayIn * -1
			INSERT INTO @tbTax (AccountCode, CashCode, TransactOn, CashEntryTypeCode, ReferenceCode, PayOut, PayIn)
			VALUES (@AccountCode, @CashCode, @TransactOn, 5, @InvoiceReferenceCode, 0, @PayIn)			
			END
			
		FETCH NEXT FROM curCorp INTO @TransactOn, @PayOut, @PayIn, @Balance
		END	

	CLOSE curCorp
	DEALLOCATE curCorp
	
	INSERT INTO @tbTax (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)	
	SELECT     @OrderReferenceCode, @AccountCode, StartOn, 5, 0, CorporationTax, @CashCode
	FROM [dbo].[fnTaxCorpOrderTotals](0)
	WHERE CorporationTax > 0	
	
	RETURN

VatTax:

	SELECT @AccountCode = AccountCode FROM tbCashTaxType WHERE (TaxTypeCode = 2) 
	SET @CashCode = dbo.fnSystemCashCode(2)

	DECLARE curVat CURSOR LOCAL FOR
		SELECT     StartOn, ROUND(VatDue, 0) AS PayOut, ROUND(VatPaid, 0) AS PayIn, Balance
		FROM         vwTaxVatStatement
		ORDER BY StartOn DESC
	
	OPEN curVat
	FETCH NEXT FROM curVat INTO @TransactOn, @PayOut, @PayIn, @Balance
	WHILE (@@FETCH_STATUS = 0 AND ROUND(@Balance, 2) != 0)
		BEGIN		
		IF @PayOut != 0
			BEGIN
			INSERT INTO @tbTax (AccountCode, CashCode, TransactOn, CashEntryTypeCode, ReferenceCode, PayOut, PayIn)
			VALUES (@AccountCode, @CashCode, @TransactOn, 6, @InvoiceReferenceCode, @PayOut, 0)
			END
		ELSE	
			BEGIN	
			SET @PayIn = @PayIn * -1
			INSERT INTO @tbTax (AccountCode, CashCode, TransactOn, CashEntryTypeCode, ReferenceCode, PayOut, PayIn)
			VALUES (@AccountCode, @CashCode, @TransactOn, 6, @InvoiceReferenceCode, 0, @PayIn)			
			END
		FETCH NEXT FROM curVat INTO @TransactOn, @PayOut, @PayIn, @Balance
		END	

	CLOSE curVat
	DEALLOCATE curVat	
	
	INSERT INTO @tbTax (ReferenceCode, AccountCode, TransactOn, CashEntryTypeCode, PayIn, PayOut, CashCode)	
	SELECT     @OrderReferenceCode, @AccountCode, StartOn, 6, PayIn, PayOut, @CashCode
	FROM [dbo].[fnTaxVatOrderTotals](0)
	WHERE PayIn + PayOut > 0
		
	RETURN
	END
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spInvoiceCredit]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

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

	set @InvoiceSuffix = ''.'' + @UserId
	
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


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCorpTaxInvoiceItems]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwCorpTaxInvoiceItems]
AS
SELECT     TOP (100) PERCENT dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceItem.InvoiceValue * - 1 ELSE dbo.tbInvoiceItem.InvoiceValue END AS InvoiceValue
FROM         dbo.tbInvoiceItem INNER JOIN
                      dbo.fnNetProfitCashCodes() AS fnNetProfitCashCodes ON dbo.tbInvoiceItem.CashCode = fnNetProfitCashCodes.CashCode INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceItem.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
ORDER BY StartOn
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwCorpTaxInvoiceItems', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbInvoiceItem"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 191
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "fnNetProfitCashCodes"
            Begin Extent = 
               Top = 6
               Left = 229
               Bottom = 76
               Right = 381
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbInvoice"
            Begin Extent = 
               Top = 78
               Left = 229
               Bottom = 193
               Right = 401
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbInvoiceType"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 203
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
        ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCorpTaxInvoiceItems'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vwCorpTaxInvoiceItems', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCorpTaxInvoiceItems'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwCorpTaxInvoiceItems', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCorpTaxInvoiceItems'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCorpTaxInvoiceTasks]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwCorpTaxInvoiceTasks]
AS
SELECT     TOP (100) PERCENT dbo.fnAccountPeriod(dbo.tbInvoice.InvoicedOn) AS StartOn, 
                      CASE WHEN tbInvoiceType.CashModeCode = 1 THEN dbo.tbInvoiceTask.InvoiceValue * - 1 ELSE dbo.tbInvoiceTask.InvoiceValue END AS InvoiceValue
FROM         dbo.tbInvoiceTask INNER JOIN
                      dbo.fnNetProfitCashCodes() AS fnNetProfitCashCodes ON dbo.tbInvoiceTask.CashCode = fnNetProfitCashCodes.CashCode INNER JOIN
                      dbo.tbInvoice ON dbo.tbInvoiceTask.InvoiceNumber = dbo.tbInvoice.InvoiceNumber INNER JOIN
                      dbo.tbInvoiceType ON dbo.tbInvoice.InvoiceTypeCode = dbo.tbInvoiceType.InvoiceTypeCode
ORDER BY StartOn
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwCorpTaxInvoiceTasks', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbInvoiceTask"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 191
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "fnNetProfitCashCodes"
            Begin Extent = 
               Top = 6
               Left = 229
               Bottom = 76
               Right = 381
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbInvoice"
            Begin Extent = 
               Top = 78
               Left = 229
               Bottom = 193
               Right = 401
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbInvoiceType"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 203
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
        ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCorpTaxInvoiceTasks'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vwCorpTaxInvoiceTasks', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCorpTaxInvoiceTasks'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwCorpTaxInvoiceTasks', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCorpTaxInvoiceTasks'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskProfitTopLevel]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spTaskProfitTopLevel]
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
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwInvoiceOutstanding]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwInvoiceOutstanding]
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
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceOutstanding', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "vwInvoiceOutstandingBase"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 204
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbInvoice"
            Begin Extent = 
               Top = 6
               Left = 242
               Bottom = 121
               Right = 414
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbInvoiceType"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 203
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 2280
         Alias = 900
         Table = 2580
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceOutstanding'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceOutstanding', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceOutstanding'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spInvoiceRaise]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
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

	set @InvoiceSuffix = ''.'' + @UserId
	
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

' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spInvoiceRaiseBlank]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

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

	set @InvoiceSuffix = ''.'' + @UserId
	
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


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskSchedule]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
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


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spPaymentMove]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

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


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwInvoiceVatBase]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwInvoiceVatBase]
AS
SELECT     StartOn, InvoiceNumber, InvoiceTypeCode, TaxCode, InvoiceValue, TaxValue, ForeignJurisdiction, IdentityCode
FROM         dbo.vwInvoiceVatItems
UNION
SELECT     StartOn, InvoiceNumber, InvoiceTypeCode, TaxCode, InvoiceValue, TaxValue, ForeignJurisdiction, IdentityCode
FROM         dbo.vwInvoiceVatTasks
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceVatBase', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceVatBase'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceVatBase', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceVatBase'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwInvoiceSummary]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwInvoiceSummary]
AS
SELECT     DATENAME(yyyy, StartOn) + ''/'' + CAST(dbo.fnPad(MONTH(StartOn), 2) AS nvarchar) AS PeriodOn, StartOn, InvoiceTypeCode, InvoiceType AS InvoiceType, 
                      ABS(TotalInvoiceValue) AS TotalInvoiceValue, ABS(TotalTaxValue) AS TotalTaxValue
FROM         dbo.vwInvoiceSummaryTotals
UNION
SELECT     DATENAME(yyyy, StartOn) + ''/'' + CAST(dbo.fnPad(MONTH(StartOn), 2) AS nvarchar) AS PeriodOn, StartOn, InvoiceTypeCode, InvoiceType AS InvoiceType, 
                      TotalInvoiceValue, TotalTaxValue
FROM         dbo.vwInvoiceSummaryMargin
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceSummary', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceSummary'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceSummary', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceSummary'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwTaxVatStatement]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwTaxVatStatement]
AS
SELECT        TOP (100) PERCENT StartOn, VatDue, VatPaid, Balance
FROM            dbo.fnTaxVatStatement() AS fnTaxVatStatement
WHERE        (StartOn > dbo.fnSystemHistoryStartOn())
ORDER BY StartOn, VatDue
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaxVatStatement', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "fnTaxVatStatement"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 149
               Right = 190
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 2250
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaxVatStatement'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaxVatStatement', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaxVatStatement'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwInvoiceRegisterExpenses]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwInvoiceRegisterExpenses]
 AS
SELECT     vwInvoiceRegisterTasks.StartOn, vwInvoiceRegisterTasks.InvoiceNumber, vwInvoiceRegisterTasks.TaskCode, tbSystemYearPeriod.YearNumber, 
                      tbSystemYear.Description, tbSystemMonth.MonthName + '' '' + LTRIM(STR(YEAR(tbSystemYearPeriod.StartOn))) AS Period, vwInvoiceRegisterTasks.TaskTitle, 
                      vwInvoiceRegisterTasks.CashCode, vwInvoiceRegisterTasks.CashDescription, vwInvoiceRegisterTasks.TaxCode, vwInvoiceRegisterTasks.TaxDescription, 
                      vwInvoiceRegisterTasks.AccountCode, vwInvoiceRegisterTasks.InvoiceTypeCode, vwInvoiceRegisterTasks.InvoiceStatusCode, vwInvoiceRegisterTasks.InvoicedOn, 
                      vwInvoiceRegisterTasks.InvoiceValue, vwInvoiceRegisterTasks.TaxValue, vwInvoiceRegisterTasks.PaidValue, vwInvoiceRegisterTasks.PaidTaxValue, 
                      vwInvoiceRegisterTasks.PaymentTerms, vwInvoiceRegisterTasks.Printed, vwInvoiceRegisterTasks.AccountName, vwInvoiceRegisterTasks.UserName, 
                      vwInvoiceRegisterTasks.InvoiceStatus, vwInvoiceRegisterTasks.CashModeCode, vwInvoiceRegisterTasks.InvoiceType, 
                      (vwInvoiceRegisterTasks.InvoiceValue + vwInvoiceRegisterTasks.TaxValue) - (vwInvoiceRegisterTasks.PaidValue + vwInvoiceRegisterTasks.PaidTaxValue) 
                      AS UnpaidValue
FROM         vwInvoiceRegisterTasks INNER JOIN
                      tbSystemYearPeriod ON vwInvoiceRegisterTasks.StartOn = tbSystemYearPeriod.StartOn INNER JOIN
                      tbSystemYear ON tbSystemYearPeriod.YearNumber = tbSystemYear.YearNumber INNER JOIN
                      tbSystemMonth ON tbSystemYearPeriod.MonthNumber = tbSystemMonth.MonthNumber
WHERE     (dbo.fnTaskIsExpense(vwInvoiceRegisterTasks.TaskCode) = 1)
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceRegisterExpenses', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[37] 4[23] 2[14] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "vwInvoiceRegisterTasks"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 254
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbSystemYearPeriod"
            Begin Extent = 
               Top = 6
               Left = 292
               Bottom = 125
               Right = 479
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbSystemYear"
            Begin Extent = 
               Top = 6
               Left = 517
               Bottom = 125
               Right = 686
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbSystemMonth"
            Begin Extent = 
               Top = 130
               Left = 514
               Bottom = 219
               Right = 674
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 29
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Wi' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceRegisterExpenses'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceRegisterExpenses', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'dth = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1800
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceRegisterExpenses'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceRegisterExpenses', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceRegisterExpenses'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spTaskDefaultPaymentOn]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [dbo].[spTaskDefaultPaymentOn]
	(
		@AccountCode nvarchar(10),
		@ActionOn datetime,
		@PaymentOn datetime output
	)
  AS
		
	SET @PaymentOn = dbo.fnTaskDefaultPaymentOn(@AccountCode, @ActionOn)
	
	RETURN 


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCashAccountStatements]'))
EXEC dbo.sp_executesql @statement = N'

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


'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwTaskOpBucket]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwTaskOpBucket]
AS
SELECT     TaskCode, OperationNumber, dbo.fnSystemDateBucket(GETDATE(), EndOn) AS Period
FROM         dbo.tbTaskOp
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaskOpBucket', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbTaskOp"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 220
               Right = 204
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaskOpBucket'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaskOpBucket', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaskOpBucket'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwTaskBucket]'))
EXEC dbo.sp_executesql @statement = N'



CREATE VIEW [dbo].[vwTaskBucket]
  AS
SELECT     TaskCode, dbo.fnSystemDateBucket(GETDATE(), ActionOn) AS Period
FROM         dbo.tbTask




'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spCashVatBalance]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [dbo].[spCashVatBalance]
	(
	@Balance money output
	)
  AS
	set @Balance = dbo.fnSystemVatBalance()
	RETURN 


' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwAccountStatementBase]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwAccountStatementBase]
  AS
SELECT     TOP 100 PERCENT AccountCode, TransactedOn, OrderBy, Reference, StatementType, Charge
FROM         dbo.vwAccountStatementPaymentBase
UNION
SELECT     TOP 100 PERCENT AccountCode, TransactedOn, OrderBy, Reference, StatementType, Charge
FROM         dbo.vwAccountStatementInvoices


'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwInvoiceRegisterDetail]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwInvoiceRegisterDetail]
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
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceRegisterDetail', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 3
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 5
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceRegisterDetail'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceRegisterDetail', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceRegisterDetail'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCashCodeInvoiceSummary]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwCashCodeInvoiceSummary]
AS
SELECT        dbo.vwInvoiceRegisterDetail.CashCode, dbo.vwInvoiceRegisterDetail.StartOn, ABS(SUM(dbo.vwInvoiceRegisterDetail.InvoiceValue)) AS InvoiceValue, 
                         ABS(SUM(dbo.vwInvoiceRegisterDetail.TaxValue)) AS TaxValue
FROM            dbo.vwInvoiceRegisterDetail INNER JOIN
                         dbo.tbCashCode ON dbo.vwInvoiceRegisterDetail.CashCode = dbo.tbCashCode.CashCode INNER JOIN
                         dbo.tbCashCategory ON dbo.tbCashCode.CategoryCode = dbo.tbCashCategory.CategoryCode
GROUP BY dbo.vwInvoiceRegisterDetail.StartOn, dbo.vwInvoiceRegisterDetail.CashCode
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwCashCodeInvoiceSummary', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "vwInvoiceRegisterDetail"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 211
               Right = 234
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbCashCode"
            Begin Extent = 
               Top = 6
               Left = 272
               Bottom = 211
               Right = 454
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbCashCategory"
            Begin Extent = 
               Top = 6
               Left = 492
               Bottom = 188
               Right = 691
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCashCodeInvoiceSummary'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwCashCodeInvoiceSummary', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCashCodeInvoiceSummary'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwTaskOps]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwTaskOps]
AS
SELECT        dbo.tbTaskOp.TaskCode, dbo.tbTaskOp.OperationNumber, dbo.vwTaskOpBucket.Period, dbo.tbSystemBucket.BucketId, dbo.tbTaskOp.UserId, 
                         dbo.tbTaskOp.OpTypeCode, dbo.tbTaskOp.OpStatusCode, dbo.tbTaskOp.Operation, dbo.tbTaskOp.Note, dbo.tbTaskOp.StartOn, dbo.tbTaskOp.EndOn, 
                         dbo.tbTaskOp.Duration, dbo.tbTaskOp.OffsetDays, dbo.tbTaskOp.InsertedBy, dbo.tbTaskOp.InsertedOn, dbo.tbTaskOp.UpdatedBy, dbo.tbTaskOp.UpdatedOn, 
                         dbo.tbTask.TaskTitle, dbo.tbTaskStatus.TaskStatus, dbo.tbTask.ActionOn, dbo.tbTask.Quantity, dbo.tbCashCode.CashDescription, dbo.tbTask.TotalCharge, 
                         dbo.tbTask.AccountCode, dbo.tbOrg.AccountName
FROM            dbo.tbTaskOp INNER JOIN
                         dbo.tbTask ON dbo.tbTaskOp.TaskCode = dbo.tbTask.TaskCode INNER JOIN
                         dbo.tbOrg ON dbo.tbTask.AccountCode = dbo.tbOrg.AccountCode INNER JOIN
                         dbo.tbTaskStatus ON dbo.tbTask.TaskStatusCode = dbo.tbTaskStatus.TaskStatusCode INNER JOIN
                         dbo.vwTaskOpBucket ON dbo.tbTaskOp.TaskCode = dbo.vwTaskOpBucket.TaskCode AND 
                         dbo.tbTaskOp.OperationNumber = dbo.vwTaskOpBucket.OperationNumber INNER JOIN
                         dbo.tbSystemBucket ON dbo.vwTaskOpBucket.Period = dbo.tbSystemBucket.Period LEFT OUTER JOIN
                         dbo.tbCashCode ON dbo.tbTask.CashCode = dbo.tbCashCode.CashCode
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaskOps', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[54] 4[8] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbTaskOp"
            Begin Extent = 
               Top = 15
               Left = 200
               Bottom = 300
               Right = 371
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbTask"
            Begin Extent = 
               Top = 14
               Left = 391
               Bottom = 318
               Right = 560
            End
            DisplayFlags = 280
            TopColumn = 2
         End
         Begin Table = "tbOrg"
            Begin Extent = 
               Top = 6
               Left = 580
               Bottom = 121
               Right = 778
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbTaskStatus"
            Begin Extent = 
               Top = 125
               Left = 582
               Bottom = 210
               Right = 741
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbCashCode"
            Begin Extent = 
               Top = 215
               Left = 613
               Bottom = 330
               Right = 771
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "vwTaskOpBucket"
            Begin Extent = 
               Top = 81
               Left = 0
               Bottom = 181
               Right = 166
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbSystemBucket"
            Begin Extent = 
               Top = 210
               Left = 24
               Bottom = 325
               Right = 190
            End
            D' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaskOps'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaskOps', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'isplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 12
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaskOps'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaskOps', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaskOps'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwTasks]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwTasks]
AS
SELECT     dbo.tbTask.TaskCode, dbo.tbTask.UserId, dbo.tbTask.AccountCode, dbo.tbTask.ContactName, dbo.tbTask.ActivityCode, dbo.tbTask.TaskTitle, 
                      dbo.tbTask.TaskStatusCode, dbo.tbTask.ActionById, dbo.tbTask.ActionOn, dbo.tbTask.ActionedOn, dbo.tbTask.PaymentOn, dbo.tbTask.SecondReference, 
                      dbo.tbTask.TaskNotes, dbo.tbTask.TaxCode, dbo.tbTask.Quantity, dbo.tbTask.UnitCharge, dbo.tbTask.TotalCharge, dbo.tbTask.AddressCodeFrom, 
                      dbo.tbTask.AddressCodeTo, dbo.tbTask.Printed, dbo.tbTask.Spooled, dbo.tbTask.InsertedBy, dbo.tbTask.InsertedOn, dbo.tbTask.UpdatedBy, dbo.tbTask.UpdatedOn, 
                      dbo.vwTaskBucket.Period, dbo.tbSystemBucket.BucketId, dbo.tbTaskStatus.TaskStatus, dbo.tbTask.CashCode, dbo.tbCashCode.CashDescription, 
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
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwTasks', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbUser"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 201
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbTaskStatus"
            Begin Extent = 
               Top = 6
               Left = 239
               Bottom = 91
               Right = 398
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbOrgType"
            Begin Extent = 
               Top = 96
               Left = 239
               Bottom = 196
               Right = 430
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbOrg"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 236
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbOrgStatus"
            Begin Extent = 
               Top = 198
               Left = 274
               Bottom = 283
               Right = 472
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbTask"
            Begin Extent = 
               Top = 64
               Left = 82
               Bottom = 268
               Right = 251
            End
            DisplayFlags = 280
            TopColumn = 8
         End
         Begin Table = "tbUser_1"
            Begin Extent = 
               Top = 288
               Left = 245
               Bottom = 403
               Right = 408
            End
            DisplayFlags =' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTasks'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vwTasks', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' 280
            TopColumn = 0
         End
         Begin Table = "vwTaskBucket"
            Begin Extent = 
               Top = 366
               Left = 38
               Bottom = 451
               Right = 190
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbSystemBucket"
            Begin Extent = 
               Top = 408
               Left = 228
               Bottom = 523
               Right = 394
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbCashCode"
            Begin Extent = 
               Top = 456
               Left = 38
               Bottom = 571
               Right = 196
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbCashCategory"
            Begin Extent = 
               Top = 528
               Left = 234
               Bottom = 643
               Right = 409
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTasks'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwTasks', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTasks'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnStatementCompany]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[fnStatementCompany]()
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
	
	--Corporation Tax
	IF EXISTS (SELECT        tbOrgAccount.CashAccountCode
	           FROM            tbCashTaxType INNER JOIN
	                                    tbOrgAccount ON tbCashTaxType.CashAccountCode = tbOrgAccount.CashAccountCode INNER JOIN
	                                    tbCashCode ON tbOrgAccount.CashCode = tbCashCode.CashCode
	           WHERE        (tbCashTaxType.TaxTypeCode = 1))
		BEGIN
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
		SELECT ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
		FROM dbo.fnStatementTaxEntries(1)
		ORDER BY TransactOn		
		END

	--VAT
	IF EXISTS (SELECT        tbOrgAccount.CashAccountCode
	           FROM            tbCashTaxType INNER JOIN
	                                    tbOrgAccount ON tbCashTaxType.CashAccountCode = tbOrgAccount.CashAccountCode INNER JOIN
	                                    tbCashCode ON tbOrgAccount.CashCode = tbCashCode.CashCode
	           WHERE        (tbCashTaxType.TaxTypeCode = 2))
		BEGIN	
		INSERT INTO @tbStatement (ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut)
		SELECT ReferenceCode, AccountCode, CashCode, TransactOn, CashEntryTypeCode, PayIn, PayOut
		FROM dbo.fnStatementTaxEntries(2)
		ORDER BY TransactOn		
		END

	select @ReferenceCode = dbo.fnSystemProfileText(3013)
	set @Balance = dbo.fnCashCurrentBalance()	
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

' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spPaymentPostPaidIn]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
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
		
		if isnull(@TaskCode, '''''''') = ''''''''
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

	
	if isnull(@CashCode, '''''''') != ''''''''
		begin
		UPDATE    tbOrgPayment
		SET      PaymentStatusCode = 2, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
			CashCode = isnull(@CashCode, tbOrgPayment.CashCode), 
			TaxCode = isnull(@TaxCode, tbOrgPayment.TaxCode)
		WHERE     (PaymentCode = @PaymentCode)
		end

			
	RETURN

' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spPaymentPostPaidOut]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spPaymentPostPaidOut]
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
		
		if isnull(@TaskCode, '''''''') = ''''''''
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

	if isnull(@CashCode, '''''''') != ''''''''
		begin
		UPDATE    tbOrgPayment
		SET      PaymentStatusCode = 2, TaxInValue = @TaxInValue, TaxOutValue = @TaxOutValue, 
			CashCode = isnull(@CashCode, tbOrgPayment.CashCode), 
			TaxCode = isnull(@TaxCode, tbOrgPayment.TaxCode)
		WHERE     (PaymentCode = @PaymentCode)
		end
	
	RETURN
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCorpTaxConfirmed]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwCorpTaxConfirmed]
AS
SELECT        dbo.vwCorpTaxConfirmedBase.StartOn, SUM(dbo.vwCorpTaxConfirmedBase.OrderValue) AS NetProfit, 
                         SUM(dbo.vwCorpTaxConfirmedBase.OrderValue * dbo.tbSystemYearPeriod.CorporationTaxRate) AS CorporationTax
FROM            dbo.vwCorpTaxConfirmedBase INNER JOIN
                         dbo.tbSystemYearPeriod ON dbo.vwCorpTaxConfirmedBase.StartOn = dbo.tbSystemYearPeriod.StartOn
GROUP BY dbo.vwCorpTaxConfirmedBase.StartOn
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwCorpTaxConfirmed', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -1056
         Left = 0
      End
      Begin Tables = 
         Begin Table = "vwCorpTaxConfirmedBase"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 101
               Right = 224
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbSystemYearPeriod"
            Begin Extent = 
               Top = 6
               Left = 262
               Bottom = 135
               Right = 472
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCorpTaxConfirmed'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwCorpTaxConfirmed', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCorpTaxConfirmed'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCorpTaxInvoiceValue]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwCorpTaxInvoiceValue]
AS
SELECT     StartOn, SUM(InvoiceValue) AS NetProfit
FROM         dbo.vwCorpTaxInvoiceItems
GROUP BY StartOn
UNION
SELECT     StartOn, SUM(InvoiceValue) AS NetProfit
FROM         dbo.vwCorpTaxInvoiceTasks
GROUP BY StartOn

'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwCorpTaxInvoiceValue', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCorpTaxInvoiceValue'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwCorpTaxInvoiceValue', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCorpTaxInvoiceValue'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spPaymentDelete]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[spPaymentDelete]
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

' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwInvoiceVatDetail]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwInvoiceVatDetail]
AS
SELECT        StartOn, TaxCode, 
                         CASE WHEN vwInvoiceVatBase.ForeignJurisdiction = 0 THEN CASE vwInvoiceVatBase.InvoiceTypeCode WHEN 1 THEN vwInvoiceVatBase.InvoiceValue WHEN 2 THEN
                          vwInvoiceVatBase.InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomeSales, 
                         CASE WHEN vwInvoiceVatBase.ForeignJurisdiction = 0 THEN CASE vwInvoiceVatBase.InvoiceTypeCode WHEN 3 THEN vwInvoiceVatBase.InvoiceValue WHEN 4 THEN
                          vwInvoiceVatBase.InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS HomePurchases, 
                         CASE WHEN vwInvoiceVatBase.ForeignJurisdiction != 0 THEN CASE vwInvoiceVatBase.InvoiceTypeCode WHEN 1 THEN vwInvoiceVatBase.InvoiceValue WHEN 2 THEN
                          vwInvoiceVatBase.InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportSales, 
                         CASE WHEN vwInvoiceVatBase.ForeignJurisdiction != 0 THEN CASE vwInvoiceVatBase.InvoiceTypeCode WHEN 3 THEN vwInvoiceVatBase.InvoiceValue WHEN 4 THEN
                          vwInvoiceVatBase.InvoiceValue * - 1 ELSE 0 END ELSE 0 END AS ExportPurchases, 
                         CASE WHEN vwInvoiceVatBase.ForeignJurisdiction = 0 THEN CASE vwInvoiceVatBase.InvoiceTypeCode WHEN 1 THEN vwInvoiceVatBase.TaxValue WHEN 2 THEN vwInvoiceVatBase.TaxValue
                          * - 1 ELSE 0 END ELSE 0 END AS HomeSalesVat, 
                         CASE WHEN vwInvoiceVatBase.ForeignJurisdiction = 0 THEN CASE vwInvoiceVatBase.InvoiceTypeCode WHEN 3 THEN vwInvoiceVatBase.TaxValue WHEN 4 THEN vwInvoiceVatBase.TaxValue
                          * - 1 ELSE 0 END ELSE 0 END AS HomePurchasesVat, 
                         CASE WHEN vwInvoiceVatBase.ForeignJurisdiction != 0 THEN CASE vwInvoiceVatBase.InvoiceTypeCode WHEN 1 THEN vwInvoiceVatBase.TaxValue WHEN 2 THEN vwInvoiceVatBase.TaxValue
                          * - 1 ELSE 0 END ELSE 0 END AS ExportSalesVat, 
                         CASE WHEN vwInvoiceVatBase.ForeignJurisdiction != 0 THEN CASE vwInvoiceVatBase.InvoiceTypeCode WHEN 3 THEN vwInvoiceVatBase.TaxValue WHEN 4 THEN vwInvoiceVatBase.TaxValue
                          * - 1 ELSE 0 END ELSE 0 END AS ExportPurchasesVat
FROM            dbo.vwInvoiceVatBase
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceVatDetail', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "vwInvoiceVatBase"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 227
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceVatDetail'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwInvoiceVatDetail', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwInvoiceVatDetail'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCashAccountLastPeriodEntry]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwCashAccountLastPeriodEntry]
  AS
SELECT     CashAccountCode, StartOn, MAX(EntryNumber) AS LastEntry
FROM         dbo.vwCashAccountStatements
GROUP BY CashAccountCode, StartOn
HAVING      (NOT (StartOn IS NULL))


'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCashAccountPeriodClosingBalance]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwCashAccountPeriodClosingBalance]
AS
SELECT        dbo.tbOrgAccount.CashCode, dbo.vwCashAccountLastPeriodEntry.StartOn, SUM(dbo.vwCashAccountStatements.PaidBalance) 
                         + SUM(dbo.vwCashAccountStatements.TaxedBalance) AS ClosingBalance
FROM            dbo.vwCashAccountLastPeriodEntry INNER JOIN
                         dbo.vwCashAccountStatements ON dbo.vwCashAccountLastPeriodEntry.CashAccountCode = dbo.vwCashAccountStatements.CashAccountCode AND 
                         dbo.vwCashAccountLastPeriodEntry.StartOn = dbo.vwCashAccountStatements.StartOn AND 
                         dbo.vwCashAccountLastPeriodEntry.LastEntry = dbo.vwCashAccountStatements.EntryNumber INNER JOIN
                         dbo.tbOrgAccount ON dbo.vwCashAccountLastPeriodEntry.CashAccountCode = dbo.tbOrgAccount.CashAccountCode
GROUP BY dbo.tbOrgAccount.CashCode, dbo.vwCashAccountLastPeriodEntry.StartOn
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwCashAccountPeriodClosingBalance', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "vwCashAccountLastPeriodEntry"
            Begin Extent = 
               Top = 76
               Left = 381
               Bottom = 188
               Right = 658
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "vwCashAccountStatements"
            Begin Extent = 
               Top = 23
               Left = 31
               Bottom = 152
               Right = 280
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbOrgAccount"
            Begin Extent = 
               Top = 15
               Left = 708
               Bottom = 205
               Right = 916
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1830
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCashAccountPeriodClosingBalance'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwCashAccountPeriodClosingBalance', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCashAccountPeriodClosingBalance'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCorpTaxInvoiceBase]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwCorpTaxInvoiceBase]
AS
SELECT     StartOn, SUM(NetProfit) AS NetProfit
FROM         dbo.vwCorpTaxInvoiceValue
GROUP BY StartOn
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwCorpTaxInvoiceBase', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "vwCorpTaxInvoiceValue"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 91
               Right = 263
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCorpTaxInvoiceBase'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwCorpTaxInvoiceBase', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCorpTaxInvoiceBase'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spCashFlowInitialise]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE  PROCEDURE [dbo].[spCashFlowInitialise]
   AS
declare @CashCode nvarchar(25)
		
	exec dbo.spCashGeneratePeriods
	
	UPDATE       tbCashPeriod
	SET                ForecastValue = 0, ForecastTax = 0, InvoiceValue = 0, InvoiceTax = 0
	FROM            tbCashPeriod INNER JOIN
	                         tbCashCode ON tbCashPeriod.CashCode = tbCashCode.CashCode INNER JOIN
	                         tbCashCategory ON tbCashCode.CategoryCode = tbCashCategory.CategoryCode
	WHERE  (tbCashCategory.CashTypeCode <> 3)
	
	UPDATE tbCashPeriod
	SET InvoiceValue = vwCashCodeInvoiceSummary.InvoiceValue, 
		InvoiceTax = vwCashCodeInvoiceSummary.TaxValue
	FROM         tbCashPeriod INNER JOIN
	                      vwCashCodeInvoiceSummary ON tbCashPeriod.CashCode = vwCashCodeInvoiceSummary.CashCode AND tbCashPeriod.StartOn = vwCashCodeInvoiceSummary.StartOn	

	UPDATE tbCashPeriod
	SET 
		InvoiceValue = vwCashAccountPeriodClosingBalance.ClosingBalance
	FROM         vwCashAccountPeriodClosingBalance INNER JOIN
	                      tbCashPeriod ON vwCashAccountPeriodClosingBalance.CashCode = tbCashPeriod.CashCode AND 
	                      vwCashAccountPeriodClosingBalance.StartOn = tbCashPeriod.StartOn
	                      	
	UPDATE       tbCashPeriod
	SET                ForecastValue = vwCashCodeForecastSummary.ForecastValue, ForecastTax = vwCashCodeForecastSummary.ForecastTax
	FROM            tbCashPeriod INNER JOIN
	                         vwCashCodeForecastSummary ON tbCashPeriod.CashCode = vwCashCodeForecastSummary.CashCode AND 
	                         tbCashPeriod.StartOn = vwCashCodeForecastSummary.StartOn

	UPDATE tbCashPeriod
	SET
		InvoiceValue = tbCashPeriod.InvoiceValue + vwCashCodeOrderSummary.InvoiceValue,
		InvoiceTax = tbCashPeriod.InvoiceTax + vwCashCodeOrderSummary.InvoiceTax
	FROM tbCashPeriod INNER JOIN
		vwCashCodeOrderSummary ON tbCashPeriod.CashCode = vwCashCodeOrderSummary.CashCode
			AND tbCashPeriod.StartOn = vwCashCodeOrderSummary.StartOn	
	
	--Corporation Tax
	SELECT   @CashCode = CashCode
	FROM            tbCashTaxType
	WHERE        (TaxTypeCode = 1)
	
	UPDATE       tbCashPeriod
	SET                ForecastValue = 0, ForecastTax = 0, InvoiceValue = 0, InvoiceTax = 0
	FROM            tbCashPeriod
	WHERE CashCode = @CashCode	
	
	UPDATE       tbCashPeriod
	SET                InvoiceValue = vwTaxCorpStatement.TaxDue
	FROM            vwTaxCorpStatement INNER JOIN
	                         tbCashPeriod ON vwTaxCorpStatement.StartOn = tbCashPeriod.StartOn
	WHERE        (vwTaxCorpStatement.TaxDue <> 0) AND (tbCashPeriod.CashCode = @CashCode)
	
	--VAT vwTaxVatStatement		
	SELECT   @CashCode = CashCode
	FROM            tbCashTaxType
	WHERE        (TaxTypeCode = 2)

	UPDATE       tbCashPeriod
	SET                InvoiceValue = vwTaxVatStatement.VatDue
	FROM            vwTaxVatStatement INNER JOIN
	                         tbCashPeriod ON vwTaxVatStatement.StartOn = tbCashPeriod.StartOn
	WHERE        (tbCashPeriod.CashCode = @CashCode) AND (vwTaxVatStatement.VatDue <> 0)

	--**********************************************************************************************	                  	

	UPDATE tbCashPeriod
	SET
		ForecastValue = vwCashFlowNITotals.ForecastNI, 
		InvoiceValue = vwCashFlowNITotals.InvoiceNI
	FROM         tbCashPeriod INNER JOIN
	                      vwCashFlowNITotals ON tbCashPeriod.StartOn = vwCashFlowNITotals.StartOn
	WHERE     (tbCashPeriod.CashCode = dbo.fnSystemCashCode(3))
	                      
	
	RETURN 
' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCorpTaxInvoice]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwCorpTaxInvoice]
AS
SELECT     TOP (100) PERCENT dbo.tbSystemYearPeriod.StartOn, dbo.vwCorpTaxInvoiceBase.NetProfit, 
                      dbo.vwCorpTaxInvoiceBase.NetProfit * dbo.tbSystemYearPeriod.CorporationTaxRate + dbo.tbSystemYearPeriod.TaxAdjustment AS CorporationTax, 
                      dbo.tbSystemYearPeriod.TaxAdjustment
FROM         dbo.vwCorpTaxInvoiceBase INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.vwCorpTaxInvoiceBase.StartOn = dbo.tbSystemYearPeriod.StartOn
ORDER BY dbo.tbSystemYearPeriod.StartOn
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwCorpTaxInvoice', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tbSystemYearPeriod"
            Begin Extent = 
               Top = 8
               Left = 315
               Bottom = 211
               Right = 494
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "vwCorpTaxInvoiceBase"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 91
               Right = 264
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 3105
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCorpTaxInvoice'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwCorpTaxInvoice', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwCorpTaxInvoice'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwTaxCorpTotals]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vwTaxCorpTotals]
AS
SELECT     TOP (100) PERCENT dbo.vwCorpTaxInvoice.StartOn, YEAR(dbo.tbSystemYearPeriod.StartOn) AS PeriodYear, dbo.tbSystemYear.Description, 
                      dbo.tbSystemMonth.MonthName + '' '' + LTRIM(STR(YEAR(dbo.tbSystemYearPeriod.StartOn))) AS Period, dbo.tbSystemYearPeriod.CorporationTaxRate, 
                      dbo.tbSystemYearPeriod.TaxAdjustment, SUM(dbo.vwCorpTaxInvoice.NetProfit) AS NetProfit, SUM(dbo.vwCorpTaxInvoice.CorporationTax) AS CorporationTax
FROM         dbo.vwCorpTaxInvoice INNER JOIN
                      dbo.tbSystemYearPeriod ON dbo.vwCorpTaxInvoice.StartOn = dbo.tbSystemYearPeriod.StartOn INNER JOIN
                      dbo.tbSystemYear ON dbo.tbSystemYearPeriod.YearNumber = dbo.tbSystemYear.YearNumber INNER JOIN
                      dbo.tbSystemMonth ON dbo.tbSystemYearPeriod.MonthNumber = dbo.tbSystemMonth.MonthNumber
WHERE     (dbo.tbSystemYear.CashStatusCode = 2) OR
                      (dbo.tbSystemYear.CashStatusCode = 3)
GROUP BY dbo.tbSystemYear.Description, dbo.tbSystemMonth.MonthName, dbo.vwCorpTaxInvoice.StartOn, YEAR(dbo.tbSystemYearPeriod.StartOn), 
                      dbo.tbSystemYearPeriod.CorporationTaxRate, dbo.tbSystemYearPeriod.TaxAdjustment
ORDER BY dbo.vwCorpTaxInvoice.StartOn
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaxCorpTotals', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[21] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "vwCorpTaxInvoice"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 106
               Right = 207
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbSystemYearPeriod"
            Begin Extent = 
               Top = 6
               Left = 232
               Bottom = 121
               Right = 411
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbSystemYear"
            Begin Extent = 
               Top = 108
               Left = 38
               Bottom = 223
               Right = 199
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbSystemMonth"
            Begin Extent = 
               Top = 126
               Left = 237
               Bottom = 211
               Right = 389
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 2205
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaxCorpTotals'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane2' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaxCorpTotals', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'       Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaxCorpTotals'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW',N'vwTaxCorpTotals', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwTaxCorpTotals'
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnSystemCorpTaxBalance]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

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



' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCashSummaryBase]'))
EXEC dbo.sp_executesql @statement = N'

CREATE  VIEW [dbo].[vwCashSummaryBase]
  AS
SELECT     ISNULL(SUM(ToCollect), 0) AS Collect, ISNULL(SUM(ToPay), 0) AS Pay, ISNULL(SUM(TaxValue), 0) + dbo.fnSystemVatBalance() 
                      + dbo.fnSystemCorpTaxBalance() AS Tax, dbo.fnCashCompanyBalance() AS CompanyBalance
FROM         dbo.vwCashSummaryInvoices


'
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwCashSummary]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [dbo].[vwCashSummary]
  AS
SELECT     GETDATE() AS Timstamp, Collect, Pay, Tax, CompanyBalance AS Cash, CompanyBalance + Collect - Pay - Tax AS Balance
FROM         dbo.vwCashSummaryBase


'
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbCashCategory_tbCashCategoryType]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbCashCategory]'))
ALTER TABLE [dbo].[tbCashCategory]  WITH CHECK ADD  CONSTRAINT [FK_tbCashCategory_tbCashCategoryType] FOREIGN KEY([CategoryTypeCode])
REFERENCES [dbo].[tbCashCategoryType] ([CategoryTypeCode])
GO
ALTER TABLE [dbo].[tbCashCategory] CHECK CONSTRAINT [FK_tbCashCategory_tbCashCategoryType]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbCashCategory_tbCashMode]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbCashCategory]'))
ALTER TABLE [dbo].[tbCashCategory]  WITH CHECK ADD  CONSTRAINT [FK_tbCashCategory_tbCashMode] FOREIGN KEY([CashModeCode])
REFERENCES [dbo].[tbCashMode] ([CashModeCode])
GO
ALTER TABLE [dbo].[tbCashCategory] CHECK CONSTRAINT [FK_tbCashCategory_tbCashMode]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbCashCategory_tbCashType]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbCashCategory]'))
ALTER TABLE [dbo].[tbCashCategory]  WITH CHECK ADD  CONSTRAINT [FK_tbCashCategory_tbCashType] FOREIGN KEY([CashTypeCode])
REFERENCES [dbo].[tbCashType] ([CashTypeCode])
GO
ALTER TABLE [dbo].[tbCashCategory] CHECK CONSTRAINT [FK_tbCashCategory_tbCashType]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbTaskOp_tbActivityOpType]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbTaskOp]'))
ALTER TABLE [dbo].[tbTaskOp]  WITH CHECK ADD  CONSTRAINT [FK_tbTaskOp_tbActivityOpType] FOREIGN KEY([OpTypeCode])
REFERENCES [dbo].[tbActivityOpType] ([OpTypeCode])
GO
ALTER TABLE [dbo].[tbTaskOp] CHECK CONSTRAINT [FK_tbTaskOp_tbActivityOpType]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbTaskOp_tbTask]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbTaskOp]'))
ALTER TABLE [dbo].[tbTaskOp]  WITH CHECK ADD  CONSTRAINT [FK_tbTaskOp_tbTask] FOREIGN KEY([TaskCode])
REFERENCES [dbo].[tbTask] ([TaskCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbTaskOp] CHECK CONSTRAINT [FK_tbTaskOp_tbTask]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbTaskOp_tbTaskOpStatus]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbTaskOp]'))
ALTER TABLE [dbo].[tbTaskOp]  WITH CHECK ADD  CONSTRAINT [FK_tbTaskOp_tbTaskOpStatus] FOREIGN KEY([OpStatusCode])
REFERENCES [dbo].[tbTaskOpStatus] ([OpStatusCode])
GO
ALTER TABLE [dbo].[tbTaskOp] CHECK CONSTRAINT [FK_tbTaskOp_tbTaskOpStatus]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbTaskOp_tbUser]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbTaskOp]'))
ALTER TABLE [dbo].[tbTaskOp]  WITH CHECK ADD  CONSTRAINT [FK_tbTaskOp_tbUser] FOREIGN KEY([UserId])
REFERENCES [dbo].[tbUser] ([UserId])
GO
ALTER TABLE [dbo].[tbTaskOp] CHECK CONSTRAINT [FK_tbTaskOp_tbUser]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbTaskAttrib_tbTask1]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbTaskAttribute]'))
ALTER TABLE [dbo].[tbTaskAttribute]  WITH CHECK ADD  CONSTRAINT [FK_tbTaskAttrib_tbTask1] FOREIGN KEY([TaskCode])
REFERENCES [dbo].[tbTask] ([TaskCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbTaskAttribute] CHECK CONSTRAINT [FK_tbTaskAttrib_tbTask1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbTaskAttribute_tbActivityAttributeType]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbTaskAttribute]'))
ALTER TABLE [dbo].[tbTaskAttribute]  WITH CHECK ADD  CONSTRAINT [FK_tbTaskAttribute_tbActivityAttributeType] FOREIGN KEY([AttributeTypeCode])
REFERENCES [dbo].[tbActivityAttributeType] ([AttributeTypeCode])
GO
ALTER TABLE [dbo].[tbTaskAttribute] CHECK CONSTRAINT [FK_tbTaskAttribute_tbActivityAttributeType]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbTaskDoc_tbTask]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbTaskDoc]'))
ALTER TABLE [dbo].[tbTaskDoc]  WITH CHECK ADD  CONSTRAINT [FK_tbTaskDoc_tbTask] FOREIGN KEY([TaskCode])
REFERENCES [dbo].[tbTask] ([TaskCode])
GO
ALTER TABLE [dbo].[tbTaskDoc] CHECK CONSTRAINT [FK_tbTaskDoc_tbTask]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbTaskFlow_tbTask]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbTaskFlow]'))
ALTER TABLE [dbo].[tbTaskFlow]  WITH CHECK ADD  CONSTRAINT [FK_tbTaskFlow_tbTask] FOREIGN KEY([ParentTaskCode])
REFERENCES [dbo].[tbTask] ([TaskCode])
GO
ALTER TABLE [dbo].[tbTaskFlow] CHECK CONSTRAINT [FK_tbTaskFlow_tbTask]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbTaskFlow_tbTask1]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbTaskFlow]'))
ALTER TABLE [dbo].[tbTaskFlow]  WITH CHECK ADD  CONSTRAINT [FK_tbTaskFlow_tbTask1] FOREIGN KEY([ChildTaskCode])
REFERENCES [dbo].[tbTask] ([TaskCode])
GO
ALTER TABLE [dbo].[tbTaskFlow] CHECK CONSTRAINT [FK_tbTaskFlow_tbTask1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbTaskQuote_tbTask]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbTaskQuote]'))
ALTER TABLE [dbo].[tbTaskQuote]  WITH CHECK ADD  CONSTRAINT [FK_tbTaskQuote_tbTask] FOREIGN KEY([TaskCode])
REFERENCES [dbo].[tbTask] ([TaskCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbTaskQuote] CHECK CONSTRAINT [FK_tbTaskQuote_tbTask]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbInvoiceActivity_tbCashCode]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbInvoiceTask]'))
ALTER TABLE [dbo].[tbInvoiceTask]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoiceActivity_tbCashCode] FOREIGN KEY([CashCode])
REFERENCES [dbo].[tbCashCode] ([CashCode])
GO
ALTER TABLE [dbo].[tbInvoiceTask] CHECK CONSTRAINT [FK_tbInvoiceActivity_tbCashCode]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbInvoiceActivity_tbSystemTaxCode]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbInvoiceTask]'))
ALTER TABLE [dbo].[tbInvoiceTask]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoiceActivity_tbSystemTaxCode] FOREIGN KEY([TaxCode])
REFERENCES [dbo].[tbSystemTaxCode] ([TaxCode])
GO
ALTER TABLE [dbo].[tbInvoiceTask] CHECK CONSTRAINT [FK_tbInvoiceActivity_tbSystemTaxCode]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbInvoiceTask_tbInvoice]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbInvoiceTask]'))
ALTER TABLE [dbo].[tbInvoiceTask]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoiceTask_tbInvoice] FOREIGN KEY([InvoiceNumber])
REFERENCES [dbo].[tbInvoice] ([InvoiceNumber])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbInvoiceTask] CHECK CONSTRAINT [FK_tbInvoiceTask_tbInvoice]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbInvoiceTask_tbTask]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbInvoiceTask]'))
ALTER TABLE [dbo].[tbInvoiceTask]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoiceTask_tbTask] FOREIGN KEY([TaskCode])
REFERENCES [dbo].[tbTask] ([TaskCode])
GO
ALTER TABLE [dbo].[tbInvoiceTask] CHECK CONSTRAINT [FK_tbInvoiceTask_tbTask]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbInvoiceTask_tbTask1]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbInvoiceTask]'))
ALTER TABLE [dbo].[tbInvoiceTask]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoiceTask_tbTask1] FOREIGN KEY([TaskCode])
REFERENCES [dbo].[tbTask] ([TaskCode])
GO
ALTER TABLE [dbo].[tbInvoiceTask] CHECK CONSTRAINT [FK_tbInvoiceTask_tbTask1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbInvoiceItem_tbCashCode]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbInvoiceItem]'))
ALTER TABLE [dbo].[tbInvoiceItem]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoiceItem_tbCashCode] FOREIGN KEY([CashCode])
REFERENCES [dbo].[tbCashCode] ([CashCode])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbInvoiceItem] CHECK CONSTRAINT [FK_tbInvoiceItem_tbCashCode]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbInvoiceItem_tbInvoice]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbInvoiceItem]'))
ALTER TABLE [dbo].[tbInvoiceItem]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoiceItem_tbInvoice] FOREIGN KEY([InvoiceNumber])
REFERENCES [dbo].[tbInvoice] ([InvoiceNumber])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbInvoiceItem] CHECK CONSTRAINT [FK_tbInvoiceItem_tbInvoice]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbInvoiceItem_tbSystemTaxCode]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbInvoiceItem]'))
ALTER TABLE [dbo].[tbInvoiceItem]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoiceItem_tbSystemTaxCode] FOREIGN KEY([TaxCode])
REFERENCES [dbo].[tbSystemTaxCode] ([TaxCode])
GO
ALTER TABLE [dbo].[tbInvoiceItem] CHECK CONSTRAINT [FK_tbInvoiceItem_tbSystemTaxCode]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbCashTaxType_tbCashCode]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbCashTaxType]'))
ALTER TABLE [dbo].[tbCashTaxType]  WITH CHECK ADD  CONSTRAINT [FK_tbCashTaxType_tbCashCode] FOREIGN KEY([CashCode])
REFERENCES [dbo].[tbCashCode] ([CashCode])
GO
ALTER TABLE [dbo].[tbCashTaxType] CHECK CONSTRAINT [FK_tbCashTaxType_tbCashCode]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbCashTaxType_tbOrg]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbCashTaxType]'))
ALTER TABLE [dbo].[tbCashTaxType]  WITH CHECK ADD  CONSTRAINT [FK_tbCashTaxType_tbOrg] FOREIGN KEY([AccountCode])
REFERENCES [dbo].[tbOrg] ([AccountCode])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbCashTaxType] CHECK CONSTRAINT [FK_tbCashTaxType_tbOrg]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbCashTaxType_tbOrgAccount]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbCashTaxType]'))
ALTER TABLE [dbo].[tbCashTaxType]  WITH CHECK ADD  CONSTRAINT [FK_tbCashTaxType_tbOrgAccount] FOREIGN KEY([CashAccountCode])
REFERENCES [dbo].[tbOrgAccount] ([CashAccountCode])
GO
ALTER TABLE [dbo].[tbCashTaxType] CHECK CONSTRAINT [FK_tbCashTaxType_tbOrgAccount]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbCashTaxType_tbSystemMonth]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbCashTaxType]'))
ALTER TABLE [dbo].[tbCashTaxType]  WITH CHECK ADD  CONSTRAINT [FK_tbCashTaxType_tbSystemMonth] FOREIGN KEY([MonthNumber])
REFERENCES [dbo].[tbSystemMonth] ([MonthNumber])
GO
ALTER TABLE [dbo].[tbCashTaxType] CHECK CONSTRAINT [FK_tbCashTaxType_tbSystemMonth]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbCashTaxType_tbSystemRecurrence]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbCashTaxType]'))
ALTER TABLE [dbo].[tbCashTaxType]  WITH CHECK ADD  CONSTRAINT [FK_tbCashTaxType_tbSystemRecurrence] FOREIGN KEY([RecurrenceCode])
REFERENCES [dbo].[tbSystemRecurrence] ([RecurrenceCode])
GO
ALTER TABLE [dbo].[tbCashTaxType] CHECK CONSTRAINT [FK_tbCashTaxType_tbSystemRecurrence]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbTask_tbCashCode]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbTask]'))
ALTER TABLE [dbo].[tbTask]  WITH CHECK ADD  CONSTRAINT [FK_tbTask_tbCashCode] FOREIGN KEY([CashCode])
REFERENCES [dbo].[tbCashCode] ([CashCode])
GO
ALTER TABLE [dbo].[tbTask] CHECK CONSTRAINT [FK_tbTask_tbCashCode]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbTask_tbOrgAddress]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbTask]'))
ALTER TABLE [dbo].[tbTask]  WITH CHECK ADD  CONSTRAINT [FK_tbTask_tbOrgAddress] FOREIGN KEY([AddressCodeFrom])
REFERENCES [dbo].[tbOrgAddress] ([AddressCode])
GO
ALTER TABLE [dbo].[tbTask] CHECK CONSTRAINT [FK_tbTask_tbOrgAddress]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbTask_tbOrgAddress1]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbTask]'))
ALTER TABLE [dbo].[tbTask]  WITH CHECK ADD  CONSTRAINT [FK_tbTask_tbOrgAddress1] FOREIGN KEY([AddressCodeTo])
REFERENCES [dbo].[tbOrgAddress] ([AddressCode])
GO
ALTER TABLE [dbo].[tbTask] CHECK CONSTRAINT [FK_tbTask_tbOrgAddress1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbTask_tbSystemTaxCode]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbTask]'))
ALTER TABLE [dbo].[tbTask]  WITH CHECK ADD  CONSTRAINT [FK_tbTask_tbSystemTaxCode] FOREIGN KEY([TaxCode])
REFERENCES [dbo].[tbSystemTaxCode] ([TaxCode])
GO
ALTER TABLE [dbo].[tbTask] CHECK CONSTRAINT [FK_tbTask_tbSystemTaxCode]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbTask_tbUser]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbTask]'))
ALTER TABLE [dbo].[tbTask]  WITH CHECK ADD  CONSTRAINT [FK_tbTask_tbUser] FOREIGN KEY([UserId])
REFERENCES [dbo].[tbUser] ([UserId])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbTask] CHECK CONSTRAINT [FK_tbTask_tbUser]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbTask_tbUser1]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbTask]'))
ALTER TABLE [dbo].[tbTask]  WITH CHECK ADD  CONSTRAINT [FK_tbTask_tbUser1] FOREIGN KEY([ActionById])
REFERENCES [dbo].[tbUser] ([UserId])
GO
ALTER TABLE [dbo].[tbTask] CHECK CONSTRAINT [FK_tbTask_tbUser1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[tbActivity_FK00]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbTask]'))
ALTER TABLE [dbo].[tbTask]  WITH CHECK ADD  CONSTRAINT [tbActivity_FK00] FOREIGN KEY([ActivityCode])
REFERENCES [dbo].[tbActivity] ([ActivityCode])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbTask] CHECK CONSTRAINT [tbActivity_FK00]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[tbActivity_FK01]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbTask]'))
ALTER TABLE [dbo].[tbTask]  WITH CHECK ADD  CONSTRAINT [tbActivity_FK01] FOREIGN KEY([TaskStatusCode])
REFERENCES [dbo].[tbTaskStatus] ([TaskStatusCode])
GO
ALTER TABLE [dbo].[tbTask] CHECK CONSTRAINT [tbActivity_FK01]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[tbActivity_FK02]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbTask]'))
ALTER TABLE [dbo].[tbTask]  WITH CHECK ADD  CONSTRAINT [tbActivity_FK02] FOREIGN KEY([AccountCode])
REFERENCES [dbo].[tbOrg] ([AccountCode])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbTask] CHECK CONSTRAINT [tbActivity_FK02]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbCashPeriod_tbCashCode]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbCashPeriod]'))
ALTER TABLE [dbo].[tbCashPeriod]  WITH CHECK ADD  CONSTRAINT [FK_tbCashPeriod_tbCashCode] FOREIGN KEY([CashCode])
REFERENCES [dbo].[tbCashCode] ([CashCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbCashPeriod] CHECK CONSTRAINT [FK_tbCashPeriod_tbCashCode]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbCashPeriod_tbSystemYearPeriod]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbCashPeriod]'))
ALTER TABLE [dbo].[tbCashPeriod]  WITH CHECK ADD  CONSTRAINT [FK_tbCashPeriod_tbSystemYearPeriod] FOREIGN KEY([StartOn])
REFERENCES [dbo].[tbSystemYearPeriod] ([StartOn])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbCashPeriod] CHECK CONSTRAINT [FK_tbCashPeriod_tbSystemYearPeriod]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbOrgAccount_tbCashCode]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbOrgAccount]'))
ALTER TABLE [dbo].[tbOrgAccount]  WITH CHECK ADD  CONSTRAINT [FK_tbOrgAccount_tbCashCode] FOREIGN KEY([CashCode])
REFERENCES [dbo].[tbCashCode] ([CashCode])
GO
ALTER TABLE [dbo].[tbOrgAccount] CHECK CONSTRAINT [FK_tbOrgAccount_tbCashCode]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbOrgAccount_tbOrg]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbOrgAccount]'))
ALTER TABLE [dbo].[tbOrgAccount]  WITH CHECK ADD  CONSTRAINT [FK_tbOrgAccount_tbOrg] FOREIGN KEY([AccountCode])
REFERENCES [dbo].[tbOrg] ([AccountCode])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbOrgAccount] CHECK CONSTRAINT [FK_tbOrgAccount_tbOrg]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbOrgPayment_tbCashCode]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbOrgPayment]'))
ALTER TABLE [dbo].[tbOrgPayment]  WITH CHECK ADD  CONSTRAINT [FK_tbOrgPayment_tbCashCode] FOREIGN KEY([CashCode])
REFERENCES [dbo].[tbCashCode] ([CashCode])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbOrgPayment] CHECK CONSTRAINT [FK_tbOrgPayment_tbCashCode]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbOrgPayment_tbOrg]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbOrgPayment]'))
ALTER TABLE [dbo].[tbOrgPayment]  WITH CHECK ADD  CONSTRAINT [FK_tbOrgPayment_tbOrg] FOREIGN KEY([AccountCode])
REFERENCES [dbo].[tbOrg] ([AccountCode])
GO
ALTER TABLE [dbo].[tbOrgPayment] CHECK CONSTRAINT [FK_tbOrgPayment_tbOrg]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbOrgPayment_tbOrgAccount]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbOrgPayment]'))
ALTER TABLE [dbo].[tbOrgPayment]  WITH CHECK ADD  CONSTRAINT [FK_tbOrgPayment_tbOrgAccount] FOREIGN KEY([CashAccountCode])
REFERENCES [dbo].[tbOrgAccount] ([CashAccountCode])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbOrgPayment] CHECK CONSTRAINT [FK_tbOrgPayment_tbOrgAccount]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbOrgPayment_tbOrgPaymentStatus]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbOrgPayment]'))
ALTER TABLE [dbo].[tbOrgPayment]  WITH CHECK ADD  CONSTRAINT [FK_tbOrgPayment_tbOrgPaymentStatus] FOREIGN KEY([PaymentStatusCode])
REFERENCES [dbo].[tbOrgPaymentStatus] ([PaymentStatusCode])
GO
ALTER TABLE [dbo].[tbOrgPayment] CHECK CONSTRAINT [FK_tbOrgPayment_tbOrgPaymentStatus]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbOrgPayment_tbSystemTaxCode]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbOrgPayment]'))
ALTER TABLE [dbo].[tbOrgPayment]  WITH CHECK ADD  CONSTRAINT [FK_tbOrgPayment_tbSystemTaxCode] FOREIGN KEY([TaxCode])
REFERENCES [dbo].[tbSystemTaxCode] ([TaxCode])
GO
ALTER TABLE [dbo].[tbOrgPayment] CHECK CONSTRAINT [FK_tbOrgPayment_tbSystemTaxCode]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbOrgPayment_tbUser1]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbOrgPayment]'))
ALTER TABLE [dbo].[tbOrgPayment]  WITH CHECK ADD  CONSTRAINT [FK_tbOrgPayment_tbUser1] FOREIGN KEY([UserId])
REFERENCES [dbo].[tbUser] ([UserId])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbOrgPayment] CHECK CONSTRAINT [FK_tbOrgPayment_tbUser1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbActivity_tbSystemRegister]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbActivity]'))
ALTER TABLE [dbo].[tbActivity]  WITH CHECK ADD  CONSTRAINT [FK_tbActivity_tbSystemRegister] FOREIGN KEY([RegisterName])
REFERENCES [dbo].[tbSystemRegister] ([RegisterName])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbActivity] CHECK CONSTRAINT [FK_tbActivity_tbSystemRegister]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbActivityCode_tbCashCode]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbActivity]'))
ALTER TABLE [dbo].[tbActivity]  WITH CHECK ADD  CONSTRAINT [FK_tbActivityCode_tbCashCode] FOREIGN KEY([CashCode])
REFERENCES [dbo].[tbCashCode] ([CashCode])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbActivity] CHECK CONSTRAINT [FK_tbActivityCode_tbCashCode]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbActivityCode_tbSystemUom]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbActivity]'))
ALTER TABLE [dbo].[tbActivity]  WITH CHECK ADD  CONSTRAINT [FK_tbActivityCode_tbSystemUom] FOREIGN KEY([UnitOfMeasure])
REFERENCES [dbo].[tbSystemUom] ([UnitOfMeasure])
GO
ALTER TABLE [dbo].[tbActivity] CHECK CONSTRAINT [FK_tbActivityCode_tbSystemUom]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbOrgType_tbCashMode]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbOrgType]'))
ALTER TABLE [dbo].[tbOrgType]  WITH CHECK ADD  CONSTRAINT [FK_tbOrgType_tbCashMode] FOREIGN KEY([CashModeCode])
REFERENCES [dbo].[tbCashMode] ([CashModeCode])
GO
ALTER TABLE [dbo].[tbOrgType] CHECK CONSTRAINT [FK_tbOrgType_tbCashMode]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbInvoiceType_tbCashMode]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbInvoiceType]'))
ALTER TABLE [dbo].[tbInvoiceType]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoiceType_tbCashMode] FOREIGN KEY([CashModeCode])
REFERENCES [dbo].[tbCashMode] ([CashModeCode])
GO
ALTER TABLE [dbo].[tbInvoiceType] CHECK CONSTRAINT [FK_tbInvoiceType_tbCashMode]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbSystemYearPeriod_tbCashStatus]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbSystemYearPeriod]'))
ALTER TABLE [dbo].[tbSystemYearPeriod]  WITH CHECK ADD  CONSTRAINT [FK_tbSystemYearPeriod_tbCashStatus] FOREIGN KEY([CashStatusCode])
REFERENCES [dbo].[tbCashStatus] ([CashStatusCode])
GO
ALTER TABLE [dbo].[tbSystemYearPeriod] CHECK CONSTRAINT [FK_tbSystemYearPeriod_tbCashStatus]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbSystemYearPeriod_tbSystemMonth]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbSystemYearPeriod]'))
ALTER TABLE [dbo].[tbSystemYearPeriod]  WITH CHECK ADD  CONSTRAINT [FK_tbSystemYearPeriod_tbSystemMonth] FOREIGN KEY([MonthNumber])
REFERENCES [dbo].[tbSystemMonth] ([MonthNumber])
GO
ALTER TABLE [dbo].[tbSystemYearPeriod] CHECK CONSTRAINT [FK_tbSystemYearPeriod_tbSystemMonth]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbSystemYearPeriod_tbSystemYear]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbSystemYearPeriod]'))
ALTER TABLE [dbo].[tbSystemYearPeriod]  WITH CHECK ADD  CONSTRAINT [FK_tbSystemYearPeriod_tbSystemYear] FOREIGN KEY([YearNumber])
REFERENCES [dbo].[tbSystemYear] ([YearNumber])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbSystemYearPeriod] CHECK CONSTRAINT [FK_tbSystemYearPeriod_tbSystemYear]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbSystemTaxCode_tbCashTaxType]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbSystemTaxCode]'))
ALTER TABLE [dbo].[tbSystemTaxCode]  WITH CHECK ADD  CONSTRAINT [FK_tbSystemTaxCode_tbCashTaxType] FOREIGN KEY([TaxTypeCode])
REFERENCES [dbo].[tbCashTaxType] ([TaxTypeCode])
GO
ALTER TABLE [dbo].[tbSystemTaxCode] CHECK CONSTRAINT [FK_tbSystemTaxCode_tbCashTaxType]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbInvoice_tbInvoiceStatus]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbInvoice]'))
ALTER TABLE [dbo].[tbInvoice]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoice_tbInvoiceStatus] FOREIGN KEY([InvoiceStatusCode])
REFERENCES [dbo].[tbInvoiceStatus] ([InvoiceStatusCode])
GO
ALTER TABLE [dbo].[tbInvoice] CHECK CONSTRAINT [FK_tbInvoice_tbInvoiceStatus]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbInvoice_tbInvoiceType]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbInvoice]'))
ALTER TABLE [dbo].[tbInvoice]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoice_tbInvoiceType] FOREIGN KEY([InvoiceTypeCode])
REFERENCES [dbo].[tbInvoiceType] ([InvoiceTypeCode])
GO
ALTER TABLE [dbo].[tbInvoice] CHECK CONSTRAINT [FK_tbInvoice_tbInvoiceType]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbInvoice_tbOrg]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbInvoice]'))
ALTER TABLE [dbo].[tbInvoice]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoice_tbOrg] FOREIGN KEY([AccountCode])
REFERENCES [dbo].[tbOrg] ([AccountCode])
GO
ALTER TABLE [dbo].[tbInvoice] CHECK CONSTRAINT [FK_tbInvoice_tbOrg]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbInvoice_tbUser1]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbInvoice]'))
ALTER TABLE [dbo].[tbInvoice]  WITH CHECK ADD  CONSTRAINT [FK_tbInvoice_tbUser1] FOREIGN KEY([UserId])
REFERENCES [dbo].[tbUser] ([UserId])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbInvoice] CHECK CONSTRAINT [FK_tbInvoice_tbUser1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbSystemOption_tbCashCategory]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbSystemOptions]'))
ALTER TABLE [dbo].[tbSystemOptions]  WITH CHECK ADD  CONSTRAINT [FK_tbSystemOption_tbCashCategory] FOREIGN KEY([NetProfitCode])
REFERENCES [dbo].[tbCashCategory] ([CategoryCode])
GO
ALTER TABLE [dbo].[tbSystemOptions] CHECK CONSTRAINT [FK_tbSystemOption_tbCashCategory]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbSystemOptions_tbSystemBucketInterval]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbSystemOptions]'))
ALTER TABLE [dbo].[tbSystemOptions]  WITH CHECK ADD  CONSTRAINT [FK_tbSystemOptions_tbSystemBucketInterval] FOREIGN KEY([BucketIntervalCode])
REFERENCES [dbo].[tbSystemBucketInterval] ([BucketIntervalCode])
GO
ALTER TABLE [dbo].[tbSystemOptions] CHECK CONSTRAINT [FK_tbSystemOptions_tbSystemBucketInterval]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbSystemOptions_tbSystemBucketType]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbSystemOptions]'))
ALTER TABLE [dbo].[tbSystemOptions]  WITH CHECK ADD  CONSTRAINT [FK_tbSystemOptions_tbSystemBucketType] FOREIGN KEY([BucketTypeCode])
REFERENCES [dbo].[tbSystemBucketType] ([BucketTypeCode])
GO
ALTER TABLE [dbo].[tbSystemOptions] CHECK CONSTRAINT [FK_tbSystemOptions_tbSystemBucketType]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbSystemRoot_tbOrg]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbSystemOptions]'))
ALTER TABLE [dbo].[tbSystemOptions]  WITH CHECK ADD  CONSTRAINT [FK_tbSystemRoot_tbOrg] FOREIGN KEY([AccountCode])
REFERENCES [dbo].[tbOrg] ([AccountCode])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbSystemOptions] CHECK CONSTRAINT [FK_tbSystemRoot_tbOrg]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgContact_FK00]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbOrgContact]'))
ALTER TABLE [dbo].[tbOrgContact]  WITH CHECK ADD  CONSTRAINT [tbOrgContact_FK00] FOREIGN KEY([AccountCode])
REFERENCES [dbo].[tbOrg] ([AccountCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbOrgContact] CHECK CONSTRAINT [tbOrgContact_FK00]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbOrgSector_tbOrg]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbOrgSector]'))
ALTER TABLE [dbo].[tbOrgSector]  WITH CHECK ADD  CONSTRAINT [FK_tbOrgSector_tbOrg] FOREIGN KEY([AccountCode])
REFERENCES [dbo].[tbOrg] ([AccountCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbOrgSector] CHECK CONSTRAINT [FK_tbOrgSector_tbOrg]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[tbOrgDoc_FK00]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbOrgDoc]'))
ALTER TABLE [dbo].[tbOrgDoc]  WITH CHECK ADD  CONSTRAINT [tbOrgDoc_FK00] FOREIGN KEY([AccountCode])
REFERENCES [dbo].[tbOrg] ([AccountCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbOrgDoc] CHECK CONSTRAINT [tbOrgDoc_FK00]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbOrgAddress_tbOrg]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbOrgAddress]'))
ALTER TABLE [dbo].[tbOrgAddress]  WITH CHECK ADD  CONSTRAINT [FK_tbOrgAddress_tbOrg] FOREIGN KEY([AccountCode])
REFERENCES [dbo].[tbOrg] ([AccountCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbOrgAddress] CHECK CONSTRAINT [FK_tbOrgAddress_tbOrg]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbOrg_tbOrgAddress]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbOrg]'))
ALTER TABLE [dbo].[tbOrg]  WITH NOCHECK ADD  CONSTRAINT [FK_tbOrg_tbOrgAddress] FOREIGN KEY([AddressCode])
REFERENCES [dbo].[tbOrgAddress] ([AddressCode])
NOT FOR REPLICATION
GO
ALTER TABLE [dbo].[tbOrg] NOCHECK CONSTRAINT [FK_tbOrg_tbOrgAddress]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbOrg_tbSystemTaxCode]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbOrg]'))
ALTER TABLE [dbo].[tbOrg]  WITH CHECK ADD  CONSTRAINT [FK_tbOrg_tbSystemTaxCode] FOREIGN KEY([TaxCode])
REFERENCES [dbo].[tbSystemTaxCode] ([TaxCode])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbOrg] CHECK CONSTRAINT [FK_tbOrg_tbSystemTaxCode]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[tbOrg_FK00]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbOrg]'))
ALTER TABLE [dbo].[tbOrg]  WITH CHECK ADD  CONSTRAINT [tbOrg_FK00] FOREIGN KEY([OrganisationStatusCode])
REFERENCES [dbo].[tbOrgStatus] ([OrganisationStatusCode])
GO
ALTER TABLE [dbo].[tbOrg] CHECK CONSTRAINT [tbOrg_FK00]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[tbOrg_FK01]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbOrg]'))
ALTER TABLE [dbo].[tbOrg]  WITH CHECK ADD  CONSTRAINT [tbOrg_FK01] FOREIGN KEY([OrganisationTypeCode])
REFERENCES [dbo].[tbOrgType] ([OrganisationTypeCode])
GO
ALTER TABLE [dbo].[tbOrg] CHECK CONSTRAINT [tbOrg_FK01]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbProfileMenuEntry_tbProfileMenu]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbProfileMenuEntry]'))
ALTER TABLE [dbo].[tbProfileMenuEntry]  WITH CHECK ADD  CONSTRAINT [FK_tbProfileMenuEntry_tbProfileMenu] FOREIGN KEY([MenuId])
REFERENCES [dbo].[tbProfileMenu] ([MenuId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbProfileMenuEntry] CHECK CONSTRAINT [FK_tbProfileMenuEntry_tbProfileMenu]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[tbProfileMenuEntry_FK01]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbProfileMenuEntry]'))
ALTER TABLE [dbo].[tbProfileMenuEntry]  WITH CHECK ADD  CONSTRAINT [tbProfileMenuEntry_FK01] FOREIGN KEY([Command])
REFERENCES [dbo].[tbProfileMenuCommand] ([Command])
GO
ALTER TABLE [dbo].[tbProfileMenuEntry] CHECK CONSTRAINT [tbProfileMenuEntry_FK01]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[tbProfileMenuEntry_FK02]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbProfileMenuEntry]'))
ALTER TABLE [dbo].[tbProfileMenuEntry]  WITH CHECK ADD  CONSTRAINT [tbProfileMenuEntry_FK02] FOREIGN KEY([OpenMode])
REFERENCES [dbo].[tbProfileMenuOpenMode] ([OpenMode])
GO
ALTER TABLE [dbo].[tbProfileMenuEntry] CHECK CONSTRAINT [tbProfileMenuEntry_FK02]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbUserMenu_tbProfileMenu]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbUserMenu]'))
ALTER TABLE [dbo].[tbUserMenu]  WITH CHECK ADD  CONSTRAINT [FK_tbUserMenu_tbProfileMenu] FOREIGN KEY([MenuId])
REFERENCES [dbo].[tbProfileMenu] ([MenuId])
GO
ALTER TABLE [dbo].[tbUserMenu] CHECK CONSTRAINT [FK_tbUserMenu_tbProfileMenu]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbUserMenu_tbUser1]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbUserMenu]'))
ALTER TABLE [dbo].[tbUserMenu]  WITH CHECK ADD  CONSTRAINT [FK_tbUserMenu_tbUser1] FOREIGN KEY([UserId])
REFERENCES [dbo].[tbUser] ([UserId])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbUserMenu] CHECK CONSTRAINT [FK_tbUserMenu_tbUser1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbSystemDoc_tbProfileMenuOpenMode]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbSystemDoc]'))
ALTER TABLE [dbo].[tbSystemDoc]  WITH CHECK ADD  CONSTRAINT [FK_tbSystemDoc_tbProfileMenuOpenMode] FOREIGN KEY([OpenMode])
REFERENCES [dbo].[tbProfileMenuOpenMode] ([OpenMode])
GO
ALTER TABLE [dbo].[tbSystemDoc] CHECK CONSTRAINT [FK_tbSystemDoc_tbProfileMenuOpenMode]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbUser_tbSystemCalendar]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbUser]'))
ALTER TABLE [dbo].[tbUser]  WITH CHECK ADD  CONSTRAINT [FK_tbUser_tbSystemCalendar] FOREIGN KEY([CalendarCode])
REFERENCES [dbo].[tbSystemCalendar] ([CalendarCode])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbUser] CHECK CONSTRAINT [FK_tbUser_tbSystemCalendar]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[tbSystemCalendarHoliday_FK00]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbSystemCalendarHoliday]'))
ALTER TABLE [dbo].[tbSystemCalendarHoliday]  WITH CHECK ADD  CONSTRAINT [tbSystemCalendarHoliday_FK00] FOREIGN KEY([CalendarCode])
REFERENCES [dbo].[tbSystemCalendar] ([CalendarCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbSystemCalendarHoliday] CHECK CONSTRAINT [tbSystemCalendarHoliday_FK00]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[tbSystemDocSpool_FK00]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbSystemDocSpool]'))
ALTER TABLE [dbo].[tbSystemDocSpool]  WITH CHECK ADD  CONSTRAINT [tbSystemDocSpool_FK00] FOREIGN KEY([DocTypeCode])
REFERENCES [dbo].[tbSystemDocType] ([DocTypeCode])
GO
ALTER TABLE [dbo].[tbSystemDocSpool] CHECK CONSTRAINT [tbSystemDocSpool_FK00]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbSystemYear_tbSystemMonth]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbSystemYear]'))
ALTER TABLE [dbo].[tbSystemYear]  WITH CHECK ADD  CONSTRAINT [FK_tbSystemYear_tbSystemMonth] FOREIGN KEY([StartMonth])
REFERENCES [dbo].[tbSystemMonth] ([MonthNumber])
GO
ALTER TABLE [dbo].[tbSystemYear] CHECK CONSTRAINT [FK_tbSystemYear_tbSystemMonth]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbCashCode_tbCashCategory1]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbCashCode]'))
ALTER TABLE [dbo].[tbCashCode]  WITH CHECK ADD  CONSTRAINT [FK_tbCashCode_tbCashCategory1] FOREIGN KEY([CategoryCode])
REFERENCES [dbo].[tbCashCategory] ([CategoryCode])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbCashCode] CHECK CONSTRAINT [FK_tbCashCode_tbCashCategory1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbCashCode_tbSystemTaxCode]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbCashCode]'))
ALTER TABLE [dbo].[tbCashCode]  WITH CHECK ADD  CONSTRAINT [FK_tbCashCode_tbSystemTaxCode] FOREIGN KEY([TaxCode])
REFERENCES [dbo].[tbSystemTaxCode] ([TaxCode])
GO
ALTER TABLE [dbo].[tbCashCode] CHECK CONSTRAINT [FK_tbCashCode_tbSystemTaxCode]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbActivityOp_tbActivity]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbActivityOp]'))
ALTER TABLE [dbo].[tbActivityOp]  WITH CHECK ADD  CONSTRAINT [FK_tbActivityOp_tbActivity] FOREIGN KEY([ActivityCode])
REFERENCES [dbo].[tbActivity] ([ActivityCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbActivityOp] CHECK CONSTRAINT [FK_tbActivityOp_tbActivity]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbActivityOp_tbActivityOpType]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbActivityOp]'))
ALTER TABLE [dbo].[tbActivityOp]  WITH CHECK ADD  CONSTRAINT [FK_tbActivityOp_tbActivityOpType] FOREIGN KEY([OpTypeCode])
REFERENCES [dbo].[tbActivityOpType] ([OpTypeCode])
GO
ALTER TABLE [dbo].[tbActivityOp] CHECK CONSTRAINT [FK_tbActivityOp_tbActivityOpType]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbActivityAttribute_tbActivity]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbActivityAttribute]'))
ALTER TABLE [dbo].[tbActivityAttribute]  WITH CHECK ADD  CONSTRAINT [FK_tbActivityAttribute_tbActivity] FOREIGN KEY([ActivityCode])
REFERENCES [dbo].[tbActivity] ([ActivityCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbActivityAttribute] CHECK CONSTRAINT [FK_tbActivityAttribute_tbActivity]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbActivityAttribute_tbActivityAttributeType]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbActivityAttribute]'))
ALTER TABLE [dbo].[tbActivityAttribute]  WITH CHECK ADD  CONSTRAINT [FK_tbActivityAttribute_tbActivityAttributeType] FOREIGN KEY([AttributeTypeCode])
REFERENCES [dbo].[tbActivityAttributeType] ([AttributeTypeCode])
GO
ALTER TABLE [dbo].[tbActivityAttribute] CHECK CONSTRAINT [FK_tbActivityAttribute_tbActivityAttributeType]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbActivityFlow_tbActivity]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbActivityFlow]'))
ALTER TABLE [dbo].[tbActivityFlow]  WITH CHECK ADD  CONSTRAINT [FK_tbActivityFlow_tbActivity] FOREIGN KEY([ParentCode])
REFERENCES [dbo].[tbActivity] ([ActivityCode])
GO
ALTER TABLE [dbo].[tbActivityFlow] CHECK CONSTRAINT [FK_tbActivityFlow_tbActivity]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbActivityFlow_tbActivity1]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbActivityFlow]'))
ALTER TABLE [dbo].[tbActivityFlow]  WITH CHECK ADD  CONSTRAINT [FK_tbActivityFlow_tbActivity1] FOREIGN KEY([ChildCode])
REFERENCES [dbo].[tbActivity] ([ActivityCode])
GO
ALTER TABLE [dbo].[tbActivityFlow] CHECK CONSTRAINT [FK_tbActivityFlow_tbActivity1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbCashCategoryTotal_tbCashCategory1]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbCashCategoryTotal]'))
ALTER TABLE [dbo].[tbCashCategoryTotal]  WITH CHECK ADD  CONSTRAINT [FK_tbCashCategoryTotal_tbCashCategory1] FOREIGN KEY([ParentCode])
REFERENCES [dbo].[tbCashCategory] ([CategoryCode])
GO
ALTER TABLE [dbo].[tbCashCategoryTotal] CHECK CONSTRAINT [FK_tbCashCategoryTotal_tbCashCategory1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbCashCategoryTotal_tbCashCategory2]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbCashCategoryTotal]'))
ALTER TABLE [dbo].[tbCashCategoryTotal]  WITH CHECK ADD  CONSTRAINT [FK_tbCashCategoryTotal_tbCashCategory2] FOREIGN KEY([ChildCode])
REFERENCES [dbo].[tbCashCategory] ([CategoryCode])
GO
ALTER TABLE [dbo].[tbCashCategoryTotal] CHECK CONSTRAINT [FK_tbCashCategoryTotal_tbCashCategory2]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tbCashCategoryExp_tbCashCategory]') AND parent_object_id = OBJECT_ID(N'[dbo].[tbCashCategoryExp]'))
ALTER TABLE [dbo].[tbCashCategoryExp]  WITH CHECK ADD  CONSTRAINT [FK_tbCashCategoryExp_tbCashCategory] FOREIGN KEY([CategoryCode])
REFERENCES [dbo].[tbCashCategory] ([CategoryCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tbCashCategoryExp] CHECK CONSTRAINT [FK_tbCashCategoryExp_tbCashCategory]
GO
