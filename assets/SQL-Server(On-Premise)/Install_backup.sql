--Description: SQL script to Restore WideWorldImporters Database from bak file on SQL-Server
--Author: Lotfy Ashmawy

RESTORE DATABASE WideWorldImporters
FROM DISK = '../backup/WideWorldImporters-Standard.bak'
WITH
    MOVE 'WWI_Primary' TO '/var/opt/mssql/data/WideWorldImporter.mdf',
    MOVE 'WWI_log' TO '/var/opt/mssql/data/WideWorldImporters.idf',
    MOVE 'WWI_UserData' TO '/var/opt/mssql/data/WideWorldImporters_UserData.ndf'
    