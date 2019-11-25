/************************************************************
* Tru-Man Trade Control: Information and Cash System
* Copyright Tru-Man Industries Ltd 2008. All Rights Reserved.
* Author: Ian Monnox
* Description: Sql Server Upgrade Script - Encrypted Distribution Schema
* Data Version: 1.02
* Release Date: tbc
************************************************************/

ALTER FUNCTION dbo.fnCashCompanyBalance
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
UPDATE tbProfileText
SET [Message] = 'A/No:   <3>
Ref.:   <2>
Title:  <4>
Status: <6>

Hello <1>

<5>

<7>'
WHERE TextId = 1208
GO
