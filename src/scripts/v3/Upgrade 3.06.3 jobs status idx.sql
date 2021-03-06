DROP INDEX IF EXISTS [IX_tbOrg_tb_AccountCode] ON [Org].[tbOrg];
CREATE NONCLUSTERED INDEX IX_tbOrg_tb_AccountCode ON Org.tbOrg
(
	AccountCode ASC
)
INCLUDE ( 	AccountName) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY];
CREATE STATISTICS STAT_Task_tb_TaskCode_AccountCode_Status ON Task.tbTask(TaskCode, AccountCode, TaskStatusCode);
CREATE STATISTICS STAT_Task_tb_Status_CashCode_AccountCode ON Task.tbTask(TaskStatusCode, CashCode, AccountCode);
CREATE STATISTICS STAT_Task_tb_Status_TaskCode_CashCode_AccountCode ON Task.tbTask(TaskStatusCode, TaskCode, CashCode, AccountCode);
go
ALTER TABLE App.tbOptions 
	DROP 
	CONSTRAINT DF_App_tbOptions_ShowCashGraphs,
	COLUMN ShowCashGraphs;
go
--INSERT INTO Usr.tbMenuEntry
--                         (MenuId, FolderId, ItemId, ItemText, Command, ProjectName, Argument, OpenMode)
--VALUES        (1, 6, 7, N'Status Graphs', 4, N'Trader', N'Cash_StatusGraphs', 0);
--go
