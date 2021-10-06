# Beta Release Change Logs

The following logs chronicle the beta release changes to the Trade Control app.

## Sql Node

[repository](https://github.com/tradecontrol/sqlnode)

### 3.24.1

[creation script](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_create_node.sql)

### 3.24.2

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_24_2.sql)

- [x] trigger new current balance when OpeningBalance updated 
- [x] include opening balance in the current balance in new accounts
- [x] cast EntryNumber to int on cash account listing
- [x] include ActivityCode in [Invoice.vwSalesInvoiceSpool](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Invoice/Views/vwSalesInvoiceSpool.sql)
- [x] exclude vat entries from [Cash.vwStatement](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwStatement.sql) for un-registered businesses
- [x] forward invoices with multiple lines not totaling in [Cash.proc_FlowCashCodeValues](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Stored%20Procedures/proc_FlowCashCodeValues.sql)

### 3.24.3

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_24_3.sql)

- [x] [Task.proc_Configure](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Task/Stored%20Procedures/proc_Configure.sql) inserting empty contacts into Org.tbContact

### 3.24.4

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_24_4.sql)

- [x] remove obsolete field Cash.tbCode.OpeningBalance
- [x] invoiced vat not showing on [Cash.vwStatement](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwStatement.sql) when no payments have been made 
- [x] move _TradeControl.Node.Config.exe_ error log to _Documents\Trade Control_ folder.
- [x] code signing Sectigo RSA tcNodeConfigSetup 

### 3.24.5

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_24_5.sql)

- [x] remove obsolete field IndustrySector from Org.tbOrg
- [x] early vat payment handling on [Cash.vwStatement](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwStatement.sql)
- [x] [App.proc_BasicSetup](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/App/Stored%20Procedures/proc_BasicSetup.sql) year periods creation fix for < StartMonth
- [x] set historical year periods to closed instead of archived
- [x] error reporting in setup app terminating executing process on log write failure

### 3.24.6

- [x] remove obsolete IndustrySector code from the Services demo [App.proc_DemoServices](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/App/Stored%20Procedures/proc_DemoServices.sql)
- [x] extract the [TCNodeConfig](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/TCNodeConfig.cs) class into a separate library for use in the [Network project](https://github.com/tradecontrol/network).

### 3.25.1

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_25_1.sql)

A script to facilitate event processing by the [Trade Control Network](https://github.com/tradecontrol/network)

- [x] transmission status enumerated type for networking Orgs and triggering contract deployment
- [x] [Task.tbChangeLog](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Task/Tables/tbChangeLog.sql) table maintained by the [Task.tbTask](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Task/Tables/tbTask.sql) insert, update and delete triggers 
- [x] [Invoice.tbChangeLog](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Invoice/Tables/tbChangeLog.sql) table maintained by the [Invoice.tbInvoice](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Invoice/Tables/tbInvoice.sql) insert, update and delete triggers
- [x] Cleardown procedures for the Service Event Log and the new Change Logs. 
- [x] remove obsolete function _Cash.fnFlowCashCodeValues()_


### 3.26.1

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_26_1.sql)

- [x] ```FLOAT``` is a useful but imprecise type in Sql Server. Moving forward we are going to use ```DECIMAL``` for storing quantities, which is also the underlying type for ```MONEY```

### 3.27.1

Release 3.27.1 supports the first full release of the [Trade Control Network](https://github.com/tradecontrol/network).  

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_27_1.sql)

- [x] [unit of charge](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/App/Tables/tbUoC.sql)
- [x] [activity code mirrors](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Activity/Tables/tbMirror.sql)
- [x] [task allocations](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Task/Tables/tbAllocation.sql) and [SvD algorithm](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Task/Views/vwAllocationSvD.sql) 
- [x] [cash code mirrors](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Tables/tbMirror.sql)
- [x] [invoice mirrors](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Invoice/Tables/tbMirror.sql) 
- [x] intialisation integration
- [x] network interface to sql db class [tcNodeNetwork.cs](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/TCNodeNetwork.cs).

### 3.28.1

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_28_1.sql)

- [x] replace type ```MONEY``` with ```DECIMAL(18,5)``` to support bitcoin decimals (1000*BTC)
- [x] re-create views to assign ```DECIMAL(18,5)``` type to outputs
- [x] move payment tables, functions and procedures from Org to Cash schema
- [x] add rounding decimals to tax codes 
- [x] procedure [Cash.proc_PaymentPostReconcile](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Stored%20Procedures/proc_PaymentPostReconcile.sql) to ensure wallet -> cash account -> invoice synchronisation

### 3.28.2

Implements the data logic of the [Trade Control Bitcoin Wallet](https://github.com/tradecontrol/bitcoin).  

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_28_2.sql)

- [x] [coin type](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Tables/tbCoinType.sql) - Main, TestNet, Fiat
- [x] [miner identity](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/App/Tables/tbOptions.sql) - cash and account code
- [x] [key hierarchy](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Org/Tables/tbAccountKey.sql) - extended keys
- [x] [change keys](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Tables/tbChange.sql)
- [x] [company namespace](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Org/Views/vwNamespace.sql)
- [x] [invoice mirror](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Invoice/Tables/tbMirrorEvent.sql) - payment address send event
- [x] [bitcoin transactions](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Tables/tbTx.sql)
- [x] procedures to process transaction outputs  
- [x] wallet interface to sql cb class [tcNodeCash.cs](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/TCNodeCash.cs). 

### 3.28.3

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_28_3.sql)

- [x] node initialisation for crypto wallet
- [x] unit of charge changes to demo data 
- [x] remove the UOC from the installer for upgrades before 3.27.1
 
### 3.28.4

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_28_4.sql)

- [x] increase the decimal places of the UnitCharge to 7 in [Tasks](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Task/Tables/tbTask.sql)
- [x] [App.proc_BasicSetup](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/App/Stored%20Procedures/proc_BasicSetup.sql) creating a miner account for fiat currencies resulting in Services Demo failure
- [x] [App.proc_DemoServices](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/App/Stored%20Procedures/proc_DemoServices.sql) cleardown - exclude miner 

### 3.28.5

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_28_5.sql)

- [x] fix for [client app](https://github.com/tradecontrol/office) converting calculated decimal fields to short text. Reconnect required.


### 3.29.1

Implements the data logic of the Trade Control [Balance Sheet](https://github.com/tradecontrol/office#demos)

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_29_1.sql)

- [x] [cash account type](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Org/Tables/tbAccountType.sql) - Cash, Dummy, Asset
- [x] add account type and [liquidity](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Org/Tables/tbAccount.sql) to the cash accounts
- [x] exclude asset accounts from all views, functions and procedures related to trading
- [x] global [coin type](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Tables/tbCoinType.sql) in [options](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/App/Tables/tbOptions.sql)
- [x] prohibit asset payment entries from generating invoices in [Cash.proc_PaymentPost](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Stored%20Procedures/proc_PaymentPost.sql)
- [x] add asset statements to [period end closedown](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/App/Stored%20Procedures/proc_PeriodClose.sql)
- [x] [asset type](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Tables/tbAssetType.sql) - Debtors, Creditors, Bank, Cash, Cash Accounts, Capital
- [x] [Cash.fnFlowBankBalances](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Functions/fnFlowBankBalances.sql) not projecting the balance over periods where there are no transactions
- [x] [balance sheet periods](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwBalanceSheetPeriods.sql), [organisation statement](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Org/Views/vwAssetStatement.sql), [debtors and creditors](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwBalanceSheetOrgs.sql), [bank/wallet accounts](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwBalanceSheetAccounts.sql), [asset accounts](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwBalanceSheetAssets.sql)  
- [x] [the balance sheet](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwBalanceSheet.sql) 

### 3.29.2

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_29_2.sql)

- [x] node initialisation, setup and demos to incorporate balance sheet assets 

### 3.29.3

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_29_3.sql)

- [x] fix for neutral cash mode signing error on P&L

### 3.29.4

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_29_4.sql)

- [x] set all UnitCharge fields to ```decimal(18, 7)```
- [x] assert UnitCharge in related views

### 3.30.1

[Balance Sheet](https://tradecontrol.github.io/tutorials/balance-sheet) consolidation.

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_30_1.sql)

- [x] fix [Cash Statement](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwAccountStatement.sql) - opening balance manual override not included on asset type cash accounts
- [x] fix [Debtors and Creditors](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Org/Views/vwAssetBalances.sql) - replace account polarity with transaction polarity
- [x] fix [Organisation Statements](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Org/Views/vwStatement.sql) - ```UNION ALL``` to include all transctions
- [x] derive the [Asset Statement](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Org/Views/vwAssetStatement.sql) from the Organisation Statement and add financial periods
- [x] separate out [organisation balances](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwBalanceSheetOrgs.sql) from the balance sheet for audit reports
- [x] views for balance sheet auditing
- [x] [include corporation tax](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwBalanceSheetTax.sql) from the [Tax Statement](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwTaxCorpStatement.sql)
- [x] offset the inclusion of debtor/creditor tax by [adding the closing balances](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwBalanceSheetVat.sql) of the [VAT Statement](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwTaxVatStatement.sql)

### 3.30.2

Paid tax and invoice status simplification.

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_30_2.sql)

- [x] remove TaxPaidIn and TaxPaidOut from [Cash.tbPayment](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Tables/tbPayment.sql)
- [x] replace Cash.proc_PaymentPostPaidIn/Out with [Invoice.vwStatusLive](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Invoice/Views/vwStatusLive.sql)
- [x] remove PaidTaxValue and PaidValue from [Invoice.tbItem](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Invoice/Tables/tbItem.sql) and [Invoice.tbTask](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Invoice/Tables/tbTask.sql) 
- [x] optimise rebuild procedures [System Rebuild](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/App/Stored%20Procedures/proc_SystemRebuild.sql) and [Organisation Rebuild](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Org/Stored%20Procedures/proc_Rebuild.sql)

### 3.30.3

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_30_3.sql)

- [x] fix [Corporation Tax period totals](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwTaxCorpTotalsByPeriod.sql) - include asset type net profits
- [x] [zeroise corporation tax](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwBalanceSheetTax.sql) due in loss making periods
- [x] fix [Cash.proc_PaymentPostReconcile](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Stored%20Procedures/proc_PaymentPostReconcile.sql) - obsolete invoice detail Paid Value inclusion
- [x] fix [Invoice.proc_Pay](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Invoice/Stored%20Procedures/proc_Pay.sql) - use header paid value
- [x] fix [App.proc_BasicSetup](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/App/Stored%20Procedures/proc_BasicSetup.sql) - assign HMREV account to Cash.tbTaxType 
- [x] fix [Cash.vwBalanceSheetVat](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwBalanceSheetVat.sql) - select the correct balance for same day payments
 
### 3.30.4

[Balance Sheet](https://tradecontrol.github.io/tutorials/balance-sheet) finalisation.

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_30_4.sql)

- [x] [App.proc_NodeInitialisation](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/App/Stored%20Procedures/proc_NodeInitialisation.sql) use Offset Days in Cash.tbTaxType for payment of corporation tax
- [x] remove payment offset days from [Cash.vwBalanceSheetTax](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwBalanceSheetTax.sql) and [Cash.vwBalanceSheetVat](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwBalanceSheetVat.sql)

### 3.30.5

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_30_5.sql)

- [x] fix [Cash.vwBalanceSheetAssets](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwBalanceSheetAssets.sql) - balance not carrying over when the last transaction is in an archived financial year
- [x] fix [Cash.tbPayment](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Tables/tbPayment.sql) - insert and update triggers not including cash account manual opening balance when calculating the current balance
- [x] fix [Org.vwStatement](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Org/Views/vwStatement.sql) - opening balance transaction date incorrect for historical organisation entries  
- [x] fix [Org.vwAssetBalances](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Org/Views/vwAssetBalances.sql) - Org.vwBalanceSheet re-applying asset charge algorithm when balance is zeroised
- [x] allow manual override of invoice calculated dates in [Invoice Update Trigger](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Invoice/Tables/tbInvoice.sql)

### 3.30.6

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_30_6.sql)

- [x] allow manual override of DueOn and ExpectedOn dates in [Invoice.tbInvoice](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Invoice/Tables/tbInvoice.sql)
- [x] exclude dummy cash accounts from [Cash.vwBalanceSheetAccounts](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwBalanceSheetAccounts.sql) 
- [x] include EXTERNAL Cash Types in [Cash.vwTaxCorpTotalsByPeriod](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwTaxCorpTotalsByPeriod.sql)

### 3.31.1

Simplified [Accounts Mode](https://tradecontrol.github.io/accounts) interface.

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_31_1.sql)

- [x] fix [corporation tax financial year](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Functions/fnTaxTypeDueDates.sql)
- [x] improve [invoice status algorithm](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Invoice/Views/vwStatusLive.sql) for handling income and expenditure on the same Org account.
- [x] integrate period-end rebuild into [auto-period generation](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Stored%20Procedures/proc_GeneratePeriods.sql)
- [x] call the period-end procedure from [system rebuild](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/App/Stored%20Procedures/proc_SystemRebuild.sql)
- [x] add a default cash code to [payments against invoices](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Stored%20Procedures/proc_PaymentPostInvoiced.sql) 
- [x] [view invoices](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Invoice/Views/vwAccountsMode.sql) in Accounts Mode 
- [x] table for Accounts Mode [invoice entry](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Invoice/Tables/tbEntry.sql)
- [x] procedure for [posting invoice entries](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Invoice/Stored%20Procedures/proc_PostEntries.sql)
- [x] alter the [default cash code setup](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/App/Stored%20Procedures/proc_BasicSetup.sql) to support the [Accounts Mode tutorial](https://tradecontrol.github.io/tutorials/cash-book) 

### 3.31.2

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_31_2.sql)

- [x] Include due dates and spool flags in [Invoice.vwAccountsMode](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Invoice/Views/vwAccountsMode.sql)
- [x] fix [Invoice.proc_PostEntries](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Invoice/Stored%20Procedures/proc_PostEntries.sql) to post on InvoiceTypeCode
- [x] add payment terms to [Invoice.proc_RaiseBlank](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Invoice/Stored%20Procedures/proc_RaiseBlank.sql) 
- [x] accounts mode [sales invoice spool](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Invoice/Views/vwSalesInvoiceSpoolByItem.sql)

### 3.32.1

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_32_1.sql)

- [x] accounts mode [credit and debit note spool](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Invoice/Views/vwCreditSpoolByItem.sql)
- [x] fix [Cash.proc_PaymentPostInvoiced](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Stored%20Procedures/proc_PaymentPostInvoiced.sql) - process partially paid invoices
- [x] [App.proc_BasicSetup](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/App/Stored%20Procedures/proc_BasicSetup.sql) - bring the default P&L categories into alignment with conventional accounts 

### 3.33.1

Backend support for Office Themes. 

[sql](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNode/scripts/tc_upgrade_3_33_1.sql)

- [x] [Usr.tbInterface](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Usr/Tables/tbInterface.sql) - interface selection table: MIS/Accounts mode
- [x] [Usr.tbMenu](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Usr/Tables/tbMenu.sql) - assign interface mode to individual menus 
- [x] [Usr.tbMenuView](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Usr/Tables/tbMenuView.sql) - store user view mode preferences: list/tree view
- [x] [Usr.vwUserMenuList](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Usr/Views/vwUserMenuList.sql) - construct menu lists
- [x] [App.proc_NodeInitialisation](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/App/Stored%20Procedures/proc_NodeInitialisation.sql) - add new Accounts and MIS menus
- [x] [App.proc_BasicSetup](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/App/Stored%20Procedures/proc_BasicSetup.sql) - assign tax types to Govt account
- [x] include ennumerated type codes to support conditional formatting in select views
- [x] replace Org.vwSales and Org.vwPurchases with [Org.vwTasks](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Org/Views/vwTasks.sql)
- [x] [Cash.vwBalanceSheetVat](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwBalanceSheetVat.sql) - include tax claims
- [x] [App.proc_DemoServices](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/App/Stored%20Procedures/proc_DemoServices.sql) - startup funds by directors loan for the [accounts tutorial](https://tradecontrol.github.io/tutorials/cash-book)

### 3.34.1

Completion of the [costing system](tc_industrial_capitalism.md#gestalt-costing)

- [x] [Task.tbCostSet](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Task/Tables/tbCostSet.sql) - active set of user quotes for costing
- [x] [Task.Task_tbTask_TriggerUpdate](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Task/Tables/tbTask.sql) - remove tasks from cost set when set to ordered 
- [x] [Task.vwQuotes](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Task/Views/vwQuotes.sql) - quotes available for selection
- [x] [Task.vwCostSet](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Task/Views/vwCostSet.sql) - current user's set of quotes 
- [x] [Task.proc_CostSetAdd](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Task/Stored%20Procedures/proc_CostSetAdd.sql) - include task in the set
- [x] [Cash.vwStatementBase](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwStatementBase.sql) - split out the live company statement from the balance projection
- [x] [Cash.vwStatement](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwStatement.sql) - derive the company statement from the base dataset
- [x] [Task.vwCostSetTasks](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwCostSetTasks.sql) - get the associated purchases of the set 
- [x] [Cash.vwStatementWhatIf](https://github.com/tradecontrol/sqlnode/blob/master/src/tcNodeDb/Cash/Views/vwStatementWhatIf.sql) - integrate the quotes, vat and company tax into the company statement 

## Office 365

[repository](https://github.com/tradecontrol/office)

### 3.9

- [x] Remove SNK signing from VSTO templates
- [x] Invoice Register - sales invoice report query not found [3.9.2]
- [x] Task Edit - activity code load item not found [3.9.2]
- [x] Task Edit - load cash vat code instead of organisation [3.9.2]
- [x] Documents - add bank details to default Sales Invoice [3.9.2]
- [x] Documents - activate email as pdf [3.9.2]
- [x] Documents - locate email address by spooled flag [3.9.2]
- [x] Payment Entry - NI default value incorrect [3.9.2] 
 
### 3.10

- [x] 64 bit release 
- [x] ClickOnce manifests Sectigo RSA code signing

### 3.11

Includes interface changes required for the [Trade Control Network](https://tradecontrol.github.io//network) project

- [x] Org transmission type
- [x] Change log pages in Task and Invoice Editors 
- [x] Move service log and task/invoice change logs to Administration
- [x] Cleardown logs function in Administration
- [x] Purchase Order Delivery template not digitally signed
- [x] Manual open flag for generating Word template data
- [x] Opening Organisation Edit in datasheet view generates an error

### 3.12

Node version 3.26.1

- [x] Change ```FLOAT``` types to ```DECIMAL``` - VSTO Cash Flow, COM Interop assembly, Document Schema and client.

### 3.13

Node version 3.27.1. First release of the [Trade Control Network](https://tradecontrol.github.io/network)

- [x] Network Allocations
- [x] Network Invoices
- [x] Cash Code mirrors
- [x] Activity Code mirrors

### 3.14

Node version 3.28.3. Changes for the [Trade Control Bitcoin](https://tradecontrol.github.io//bitcoin) project.

- [x] Remove default windows currency symbol and convert money types to ```DECIMAL(18,5)```
- [x] Add bitcoin payment address to invoice mirrors
- [x] Hide payment entry and account transfer forms if Unit of Charge is BTC
- [x] Bitcoin miner cash code and account in Administration for fee processing
- [x] VSTO templates: data context money fields to decimal
- [x] MTD decimals v1.2.2

### 3.15

Node version 3.29.2. Balance Sheets

- [x] Account types in cash accounts
- [x] Asset entry form
- [x] Global coin type in Administration options
- [x] Asset categories in Cash Totals for Gross/Net Profit calculations
- [x] Fix CashFlow.xlsx vat decimal isssue
- [x] Fix closing bank balances without period transactions
- [x] Asset movement and depreciation in CashFlow.xlsx P&L 
- [x] New Balance Sheet option in CashFlow.xlsx
- [x] Client _clsInit_ class - on connect, configure the client to use the OS UOA where coin type is Fiat (Bitcoin UOA is not supported by the OS and the ```money``` type has insufficient decimals).

### 3.16

Node version 3.29.4. 

- [x] Add command timeout to the Cash Flow actions pane (default 60 secs)
- [x] Fix P&L asset liabilities polarity error
- [x] Balance Sheet Audit Report
- [x] Organisation Statement Report
- [x] Debtor/Creditor Audit Report
- [x] Remove references to Paid Values on Invoice Details and Cash Statements
- [x] Fix Organisation Quick Entry, Allocation Activity, New Task forms unbound format strings
- [x] Fix sub-report Invoice_BankDetails - picking up asset accounts
- [x] Fix LoadActivity() in Task Edit - field name DefaultText obsolete

### 3.17

Node Version 3.32.1 - [Accounts Mode](https://tradecontrol.github.io/accounts) - a simplified interface for generating Company Accounts

- [x] Sql Connect in MIS or Accounts Mode
- [x] Accounts Mode Home menu
- [x] Hide all pages relating to tasks and workflows
- [x] Hide document and menu configuration in sys admin 
- [x] Invoice item entry form for accounts
- [x] Email pdf sales, credit and debit notes to recipients 

### 3.18

Node Version 3.33.1 - replace the prototype interface with [Office Themes](https://tradecontrol.github.io/tutorials/installing-local#office-client)

- [x] New [App_Home form](https://tradecontrol.github.io/tutorials/cash-book#initialisation) showing outstanding income and expenditure in Accounts Mode, plus Jobs and Schedules in MIS.
- [x] Replace App_HomeMenuTree with App_HomeMenuList as the default. (The list view is derived from the switchboard code found in the earliest versions of MS Access over 25 years ago).
- [x] And finally, enable Office Themes in every form. 

### 3.19

Node Version 3.34.1 - complete the [costing system](tc_industrial_capitalism.md#gestalt-costing)

- [x] Add [what-if analysis](https://tradecontrol.github.io/tutorials/manufacturing#job-costing) to the company statement

## Network Log

[repository](https://tradecontrol.github.io//network). 

### 1.1.0

First release May 2020

### 1.2.0

Integration with the [Trade Control bitcoin](https://tradecontrol.github.io/bitcoin) payment system.

- [x] [invoice contract](https://github.com/tradecontrol/network/blob/master/src/tcNetwork/solidity/contracts/Invoice.sol) payment address and assignment event
- [x] communicate the bitcoin payment address for invoiced receipts
- [x] write the bitcoin address for paying invoice mirrors

### 1.2.1

- [x] Project re-name
- [x] fix - replace task view with table access in TCWeb3.InvoiceDeploymentDetails()