
DROP INDEX IF EXISTS [Invoice].[tbItem].[IDX_Invoice_tbItem_TaxCode]
DROP INDEX IF EXISTS Invoice.tbTask.IDX_Invoice_tbTask_TaxCode
go
CREATE NONCLUSTERED INDEX [IX_Org_tbPayment_PaymentCode_TaxCode] ON [Org].[tbPayment]
(
	[AccountCode] ASC,
	[PaymentCode] ASC,
	[TaxCode] ASC
)
INCLUDE ( 	[PaymentStatusCode],
	[PaidInValue],
	[PaidOutValue]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [IX_Org_tbPayment_PaymentCode_Status] ON [Org].[tbPayment]
(
	[AccountCode] ASC,
	[PaymentStatusCode] ASC,
	[PaymentCode] ASC
)
INCLUDE ( 	[PaidInValue],
	[PaidOutValue]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE STATISTICS [STAT_Org_tbPayment_StatusCode] ON [Org].[tbPayment]([PaymentStatusCode], [PaymentCode])
go

CREATE STATISTICS [STAT_Org_tbPayment_AccountCode] ON [Org].[tbPayment]([AccountCode], [PaymentCode], [PaymentStatusCode])
go

CREATE STATISTICS [STAT_Org_tbPayment_PaymentCode] ON [Org].[tbPayment]([PaymentCode], [TaxCode], [AccountCode])
go

CREATE NONCLUSTERED INDEX [IX_Org_tbOrg_OpeningBalance] ON [Org].[tbOrg]
(
	[AccountCode] ASC
)
INCLUDE ([OpeningBalance]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go
CREATE NONCLUSTERED INDEX [IX_Invoice_tbInvoice_AccountValues] ON [Invoice].[tbInvoice]
(
	[AccountCode] ASC,
	[InvoiceStatusCode] ASC,
	[InvoiceNumber] ASC
)
INCLUDE ( 	[InvoiceValue],
	[TaxValue]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [IX_Invoice_tbInvoice_AccountCode_Type] ON [Invoice].[tbInvoice]
(
	[AccountCode] ASC,
	[InvoiceNumber] ASC,
	[InvoiceTypeCode] ASC
)
INCLUDE ( 	[InvoiceValue],
	[TaxValue]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [IX_Invoice_tbInvoice_AccountCode_DueOn] ON [Invoice].[tbInvoice]
(
	[AccountCode] ASC,
	[InvoiceTypeCode] ASC,
	[DueOn] ASC
)
INCLUDE ( 	[InvoiceNumber]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [IX_Invoice_tbInvoice_AccountCode_Status] ON [Invoice].[tbInvoice]
(
	[AccountCode] ASC,
	[InvoiceStatusCode] ASC,
	[InvoiceNumber] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE STATISTICS [STAT_Invoice_tbInvoice_InvoiceNumber_Account] ON [Invoice].[tbInvoice]([InvoiceNumber], [AccountCode])
go

CREATE STATISTICS [STAT_Invoice_tbInvoice_InvoiceNumber_Status] ON [Invoice].[tbInvoice]([InvoiceNumber], [InvoiceStatusCode], [AccountCode])
go

CREATE STATISTICS [STAT_Invoice_tbInvoice_Type_DueOn] ON [Invoice].[tbInvoice]([InvoiceTypeCode], [DueOn], [AccountCode])
go

CREATE STATISTICS [STAT_Invoice_tbInvoice_InvoiceNumber_Type_DueOn] ON [Invoice].[tbInvoice]([InvoiceNumber], [InvoiceTypeCode], [DueOn], [AccountCode])
go

CREATE NONCLUSTERED INDEX [IX_Invoice_tbItem_InvoiceNumber_TaxCode] ON [Invoice].[tbItem]
(
	[InvoiceNumber] ASC,
	[TaxCode] ASC
)
INCLUDE ( 	[CashCode],
	[InvoiceValue],
	[TaxValue]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [IX_Invoice_tbItem_Full] ON [Invoice].[tbItem]
(
	[InvoiceNumber] ASC,
	[CashCode] ASC,
	[InvoiceValue] ASC,
	[TaxValue] ASC,
	[TaxCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE STATISTICS [STAT_Invoice_tbItem_Values] ON [Invoice].[tbItem]([InvoiceValue], [TaxValue], [PaidValue], [PaidTaxValue])
go

CREATE STATISTICS [STAT_Invoice_tbItem_InvoiceNumber_Values] ON [Invoice].[tbItem]([InvoiceNumber], [InvoiceValue], [TaxValue], [PaidValue], [PaidTaxValue])
go

CREATE NONCLUSTERED INDEX [IX_Invoice_tbTask_InvoiceNumber_TaxCode] ON [Invoice].[tbTask]
(
	[InvoiceNumber] ASC,
	[TaxCode] ASC
)
INCLUDE ( 	[CashCode],
	[InvoiceValue],
	[TaxValue]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [IX_Invoice_tbTask_Full] ON [Invoice].[tbTask]
(
	[InvoiceNumber] ASC,
	[CashCode] ASC,
	[InvoiceValue] ASC,
	[TaxValue] ASC,
	[TaxCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE STATISTICS [STAT_Invoice_tbTask_TaxCode] ON [Invoice].[tbTask]([TaxCode], [InvoiceNumber])
go

CREATE STATISTICS [STAT_Invoice_tbTask_InvoiceValues] ON [Invoice].[tbTask]([InvoiceValue], [TaxValue], [PaidValue], [PaidTaxValue])
go

CREATE STATISTICS [STAT_Invoice_tbTask_CashCode_Values] ON [Invoice].[tbTask]([InvoiceNumber], [CashCode], [InvoiceValue], [TaxValue], [TaxCode])
go

CREATE STATISTICS [STAT_Invoice_tbTask_InvoiceNumber_Values] ON [Invoice].[tbTask]([InvoiceNumber], [InvoiceValue], [TaxValue], [PaidValue], [PaidTaxValue])
go

