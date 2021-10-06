GO
CREATE VIEW [dbo].[vwTaskOpBucket]
AS
SELECT     TaskCode, OperationNumber, dbo.fnSystemDateBucket(GETDATE(), EndOn) AS Period
FROM         dbo.tbTaskOp
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
                      dbo.tbSystemBucket ON dbo.vwTaskOpBucket.Period = dbo.tbSystemBucket.PeriodGO
