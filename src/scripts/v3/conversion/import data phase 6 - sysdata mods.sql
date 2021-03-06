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

DELETE FROM misTradeControl.App.tbDoc;
INSERT INTO misTradeControl.App.tbDoc (DocTypeCode, ReportName, OpenMode, Description)
SELECT        DocTypeCode - 1 AS dt, ReportName, OpenMode - 1 AS Om, [Description]
FROM            misLive.App.tbDoc;

DELETE FROM misTradeControl.Usr.tbMenuEntry;

SET IDENTITY_INSERT misTradeControl.Usr.tbMenuEntry ON;
INSERT INTO misTradeControl.Usr.tbMenuEntry (MenuId, EntryId, FolderId, ItemId, ItemText, Command, ProjectName, Argument, OpenMode, UpdatedOn, InsertedOn, UpdatedBy)
SELECT        MenuId, EntryId, FolderId, ItemId, ItemText, Command, ProjectName, Argument, OpenMode, UpdatedOn, InsertedOn, UpdatedBy
FROM            misLive.Usr.tbMenuEntry;
SET IDENTITY_INSERT misTradeControl.Usr.tbMenuEntry OFF;

DELETE FROM misTradeControl.App.tbText WHERE TextId BETWEEN 2017 AND 2020; 