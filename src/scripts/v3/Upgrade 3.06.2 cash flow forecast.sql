ALTER VIEW [Cash].[vwCategoriesTrade]
AS
	SELECT        TOP (100) PERCENT CategoryCode, Category, CategoryTypeCode, CashModeCode, CashTypeCode, DisplayOrder, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, RowVer
	FROM            Cash.tbCategory
	WHERE        (CashTypeCode = 0) AND (CategoryTypeCode = 0)
go
ALTER VIEW [Cash].[vwCategoriesTotals]
AS
	SELECT        TOP (100) PERCENT CategoryCode, Category, CategoryTypeCode, CashModeCode, CashTypeCode, DisplayOrder, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, RowVer
	FROM            Cash.tbCategory
	WHERE        (CategoryTypeCode = 1)
go
CREATE NONCLUSTERED INDEX IX_Invoice_tbInvoice_FlowInitialise ON Invoice.tbInvoice
(
	InvoiceTypeCode ASC,
	UserId ASC,
	InvoiceStatusCode ASC,
	AccountCode ASC,
	InvoiceNumber ASC,
	InvoicedOn ASC,
	PaymentTerms ASC,
	Printed ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]


CREATE STATISTICS STAT_Invoice_tbInvoice_InvoiceOn_Type ON Invoice.tbInvoice(InvoicedOn, InvoiceTypeCode)


CREATE STATISTICS STAT_Invoice_tbInvoice_Status_UserId ON Invoice.tbInvoice(InvoiceStatusCode, UserId)


CREATE STATISTICS STAT_Invoice_tbInvoice_InvoiceNumber_Type_InvoicedOn ON Invoice.tbInvoice(InvoiceNumber, InvoiceTypeCode, InvoicedOn)


CREATE STATISTICS STAT_Invoice_tbInvoice_AccountCode_User_Type ON Invoice.tbInvoice(AccountCode, UserId, InvoiceTypeCode)


CREATE STATISTICS STAT_Invoice_tbInvoice_InvoicedOn_Account ON Invoice.tbInvoice(InvoicedOn, AccountCode, InvoiceNumber, InvoiceTypeCode)


CREATE STATISTICS STAT_Invoice_tbInvoice_User_Type_Status ON Invoice.tbInvoice(UserId, InvoiceTypeCode, InvoiceStatusCode, AccountCode, InvoiceNumber)


CREATE STATISTICS STAT_Invoice_tbInvoice_InvoicedOn_User_Type ON Invoice.tbInvoice(InvoicedOn, UserId, InvoiceTypeCode, InvoiceStatusCode, AccountCode)


CREATE STATISTICS STAT_Invoice_tbInvoice_Full ON Invoice.tbInvoice(InvoiceNumber, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, PaymentTerms, Printed)


CREATE STATISTICS STAT_Invoice_tbInvoice_Full_User ON Invoice.tbInvoice(InvoiceNumber, AccountCode, InvoiceTypeCode, InvoiceStatusCode, InvoicedOn, UserId, PaymentTerms, Printed)

DROP INDEX IF EXISTS IX_Invoice_tbTask_TaskCode ON Invoice.tbTask;
CREATE NONCLUSTERED INDEX IX_Invoice_tbTask_TaskCode ON Invoice.tbTask
(
	TaskCode ASC,
	InvoiceNumber ASC
)
INCLUDE ( 	InvoiceValue,
	TaxValue) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]

--DROP STATISTICS [Invoice].[tbTask].[STAT_Invoice_tbTask_TaxCode]

CREATE STATISTICS [STAT_Invoice_tbTask_TaxCode_Invoice] ON [Invoice].[tbTask]([TaxCode], [InvoiceNumber])

CREATE STATISTICS STAT_Invoice_tbTask_TaxCode_CashCode ON Invoice.tbTask(TaxCode, CashCode)


CREATE STATISTICS STAT_Invoice_tbTask_TaskCode_TaxCode_CashCode ON Invoice.tbTask(TaskCode, TaxCode, CashCode)


CREATE STATISTICS STAT_Invoice_tbTask_Invoice_TaxCode_CashCode_TaskCode ON Invoice.tbTask(InvoiceNumber, TaxCode, CashCode, TaskCode)


CREATE STATISTICS STAT_Invoice_tbTask_Invoice_TaxCode_InvoiceValue ON Invoice.tbTask(InvoiceNumber, TaxCode, InvoiceValue, TaxValue, TaskCode)


CREATE STATISTICS STAT_Invoice_tbTask_TaxCode_InvoiceValue ON Invoice.tbItem(TaxCode, InvoiceValue, TaxValue, CashCode)

DROP INDEX [IX_Org_tbPayment_PaymentStatusCode] ON [Org].[tbPayment]

CREATE NONCLUSTERED INDEX [IX_Org_tbPayment_Status_AccountCode] ON [Org].[tbPayment]
(
	[PaymentStatusCode] ASC,
	[AccountCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]

CREATE NONCLUSTERED INDEX IX_Org_tbPayment_Status_CashAccount_PaidOn ON Org.tbPayment
(
	PaymentStatusCode ASC,
	CashAccountCode ASC,
	PaidOn ASC
)
INCLUDE ( 	PaymentCode,
	PaidInValue,
	PaidOutValue) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]


CREATE STATISTICS STAT_Org_tbPayment_CashCode_PaymentCode ON Org.tbPayment(CashCode, PaymentCode)


CREATE STATISTICS STAT_Org_tbPayment_CashAccount_Status_PaidOn ON Org.tbPayment(CashAccountCode, PaymentStatusCode, PaidOn)


CREATE STATISTICS STAT_Org_tbOrg_AccountCode_ForeignJurisdiction ON Org.tbOrg(AccountCode, ForeignJurisdiction)


CREATE STATISTICS STAT_Org_tbOrg_AccountCode_AccountName ON Org.tbOrg(AccountCode, AccountName)


CREATE NONCLUSTERED INDEX IX_Task_tbTask_Status_TaxCode_TaskCode ON Task.tbTask
(
	TaskStatusCode ASC,
	TaxCode ASC,
	TaskCode ASC,
	CashCode ASC,
	ActionOn ASC
)
INCLUDE ( 	TotalCharge) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]


CREATE NONCLUSTERED INDEX IX_Task_tbTask_TaskCode_TaxCode_CashCode ON Task.tbTask
(
	TaskCode ASC,
	TaxCode ASC,
	CashCode ASC,
	ActionOn ASC
)
INCLUDE ( 	TotalCharge) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]


CREATE STATISTICS STAT_Task_tbTask_StatusCode_TaskCode_ActionOn ON Task.tbTask(TaskStatusCode, TaskCode, ActionOn)


CREATE STATISTICS STAT_Task_tbTask_TaxCode_TaskCode_TaskStatusCode ON Task.tbTask(TaxCode, TaskCode, TaskStatusCode)


CREATE STATISTICS STAT_Task_tbTask_ActionOn_TaxCode_CashCode ON Task.tbTask(ActionOn, TaxCode, CashCode)


CREATE STATISTICS STAT_Task_tbTask_TaskCode_ActionOn_TaxCode_StatusCode ON Task.tbTask(TaskCode, ActionOn, TaxCode, TaskStatusCode)


CREATE STATISTICS STAT_Task_tbTask_CashCode_TaxCode_TaskCode_ActionOn ON Task.tbTask(CashCode, TaxCode, TaskCode, ActionOn)


CREATE STATISTICS STAT_Task_tbTask_TaskCode_CashCode_TaxCode_TaskStatusCode_ActionOn ON Task.tbTask(TaskCode, CashCode, TaxCode, TaskStatusCode, ActionOn)


CREATE STATISTICS STAT_Usr_tbUser_UserId_UserName ON Usr.tbUser(UserId, UserName)


CREATE STATISTICS STAT_Usr_tbUser_UserId_LogonName ON Usr.tbUser(UserId, LogonName)

UPDATE STATISTICS Task.tbTask WITH FULLSCAN;
UPDATE STATISTICS Org.tbPayment WITH FULLSCAN;
UPDATE STATISTICS Invoice.tbInvoice WITH FULLSCAN;
UPDATE STATISTICS Invoice.tbTask WITH FULLSCAN;
UPDATE STATISTICS Invoice.tbItem WITH FULLSCAN;
UPDATE STATISTICS Org.tbOrg WITH FULLSCAN;
UPDATE STATISTICS Usr.tbUser WITH FULLSCAN;
go



