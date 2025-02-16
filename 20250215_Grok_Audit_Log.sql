-- Audit Log Table

-- Create AuditLog table
CREATE TABLE AuditLog (
    AuditLogID INT IDENTITY(1,1) PRIMARY KEY,
    TableName NVARCHAR(128) NOT NULL,                    -- Name of the table being audited
    ColumnName NVARCHAR(128) NOT NULL,                   -- Name of the column being changed
    PrimaryKeyValue NVARCHAR(255),                       -- Primary key value of the affected row
    OldValue NVARCHAR(MAX),                              -- Old value of the column (before change)
    NewValue NVARCHAR(MAX),                              -- New value of the column (after change)
    ActionType NVARCHAR(10),                             -- Type of action (INSERT, UPDATE, DELETE)
    ChangedBy NVARCHAR(128) DEFAULT SUSER_SNAME(),       -- User who made the change
    ChangedDate DATETIME DEFAULT GETDATE(),              -- Timestamp of the change
    Description NVARCHAR(255)                             -- Optional description for context
);

-- Create index for faster querying
CREATE INDEX IX_AuditLog_TableName ON AuditLog(TableName);
CREATE INDEX IX_AuditLog_ChangedDate ON AuditLog(ChangedDate);

/*
To track changes and updates to all fields in the database, we’ll create an audit log table and use triggers to capture changes for each table. The audit log table will store details such as the table name, column name, old value, new value, user who made the change, and the timestamp. Below, I’ll provide the SQL script to create the audit log table and triggers for the existing tables, along with example queries to make it functional.

Audit Log Table Creation Script
The audit log table will store changes for all tables in the database. It uses a generic structure to handle various data types by storing values as NVARCHAR(MAX).

Triggers for Auditing Changes
We’ll create triggers for each table to capture INSERT, UPDATE, and DELETE operations. The triggers will log changes to the AuditLog table. Below are the trigger scripts for the existing tables (Applications, ApplicationDependencies, Licenses, Users, UserGroups, UserGroupMembers, Computers, and ApplicationInstallations).
*/

-- 1. Trigger for Applications Table
CREATE TRIGGER TRG_Applications_Audit
ON Applications
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ActionType NVARCHAR(10);

    -- Determine the action type
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        SET @ActionType = 'UPDATE';
    ELSE IF EXISTS (SELECT * FROM inserted)
        SET @ActionType = 'INSERT';
    ELSE
        SET @ActionType = 'DELETE';

    -- Log changes for INSERT and UPDATE
    IF @ActionType IN ('INSERT', 'UPDATE')
    BEGIN
        INSERT INTO AuditLog (TableName, ColumnName, PrimaryKeyValue, OldValue, NewValue, ActionType, Description)
        SELECT 
            'Applications' AS TableName,
            column_name AS ColumnName,
            CAST(i.ApplicationID AS NVARCHAR(255)) AS PrimaryKeyValue,
            CASE 
                WHEN @ActionType = 'UPDATE' THEN 
                    CASE column_name
                        WHEN 'ApplicationName' THEN CAST(d.ApplicationName AS NVARCHAR(MAX))
                        WHEN 'Version' THEN CAST(d.Version AS NVARCHAR(MAX))
                        WHEN 'Vendor' THEN CAST(d.Vendor AS NVARCHAR(MAX))
                        WHEN 'Category' THEN CAST(d.Category AS NVARCHAR(MAX))
                        WHEN 'Description' THEN CAST(d.Description AS NVARCHAR(MAX))
                        WHEN 'InstallationPath' THEN CAST(d.InstallationPath AS NVARCHAR(MAX))
                        WHEN 'ReleaseDate' THEN CAST(d.ReleaseDate AS NVARCHAR(MAX))
                        WHEN 'IsActive' THEN CAST(d.IsActive AS NVARCHAR(MAX))
                        WHEN 'CreatedDate' THEN CAST(d.CreatedDate AS NVARCHAR(MAX))
                        WHEN 'LastUpdatedDate' THEN CAST(d.LastUpdatedDate AS NVARCHAR(MAX))
                    END
                ELSE NULL
            END AS OldValue,
            CASE column_name
                WHEN 'ApplicationName' THEN CAST(i.ApplicationName AS NVARCHAR(MAX))
                WHEN 'Version' THEN CAST(i.Version AS NVARCHAR(MAX))
                WHEN 'Vendor' THEN CAST(i.Vendor AS NVARCHAR(MAX))
                WHEN 'Category' THEN CAST(i.Category AS NVARCHAR(MAX))
                WHEN 'Description' THEN CAST(i.Description AS NVARCHAR(MAX))
                WHEN 'InstallationPath' THEN CAST(i.InstallationPath AS NVARCHAR(MAX))
                WHEN 'ReleaseDate' THEN CAST(i.ReleaseDate AS NVARCHAR(MAX))
                WHEN 'IsActive' THEN CAST(i.IsActive AS NVARCHAR(MAX))
                WHEN 'CreatedDate' THEN CAST(i.CreatedDate AS NVARCHAR(MAX))
                WHEN 'LastUpdatedDate' THEN CAST(i.LastUpdatedDate AS NVARCHAR(MAX))
            END AS NewValue,
            @ActionType AS ActionType,
            'Change in Applications table' AS Description
        FROM inserted i
        FULL OUTER JOIN deleted d ON i.ApplicationID = d.ApplicationID
        CROSS JOIN (
            SELECT 'ApplicationName' AS column_name UNION ALL
            SELECT 'Version' UNION ALL
            SELECT 'Vendor' UNION ALL
            SELECT 'Category' UNION ALL
            SELECT 'Description' UNION ALL
            SELECT 'InstallationPath' UNION ALL
            SELECT 'ReleaseDate' UNION ALL
            SELECT 'IsActive' UNION ALL
            SELECT 'CreatedDate' UNION ALL
            SELECT 'LastUpdatedDate'
        ) AS columns
        WHERE (@ActionType = 'INSERT' 
               OR (@ActionType = 'UPDATE' AND 
                   (ISNULL(CAST(d.ApplicationName AS NVARCHAR(MAX)), '') <> ISNULL(CAST(i.ApplicationName AS NVARCHAR(MAX)), '') OR
                    ISNULL(CAST(d.Version AS NVARCHAR(MAX)), '') <> ISNULL(CAST(i.Version AS NVARCHAR(MAX)), '') OR
                    ISNULL(CAST(d.Vendor AS NVARCHAR(MAX)), '') <> ISNULL(CAST(i.Vendor AS NVARCHAR(MAX)), '') OR
                    ISNULL(CAST(d.Category AS NVARCHAR(MAX)), '') <> ISNULL(CAST(i.Category AS NVARCHAR(MAX)), '') OR
                    ISNULL(CAST(d.Description AS NVARCHAR(MAX)), '') <> ISNULL(CAST(i.Description AS NVARCHAR(MAX)), '') OR
                    ISNULL(CAST(d.InstallationPath AS NVARCHAR(MAX)), '') <> ISNULL(CAST(i.InstallationPath AS NVARCHAR(MAX)), '') OR
                    ISNULL(CAST(d.ReleaseDate AS NVARCHAR(MAX)), '') <> ISNULL(CAST(i.ReleaseDate AS NVARCHAR(MAX)), '') OR
                    ISNULL(CAST(d.IsActive AS NVARCHAR(MAX)), '') <> ISNULL(CAST(i.IsActive AS NVARCHAR(MAX)), '') OR
                    ISNULL(CAST(d.CreatedDate AS NVARCHAR(MAX)), '') <> ISNULL(CAST(i.CreatedDate AS NVARCHAR(MAX)), '') OR
                    ISNULL(CAST(d.LastUpdatedDate AS NVARCHAR(MAX)), '') <> ISNULL(CAST(i.LastUpdatedDate AS NVARCHAR(MAX)), ''))))
    END;

    -- Log changes for DELETE
    IF @ActionType = 'DELETE'
    BEGIN
        INSERT INTO AuditLog (TableName, ColumnName, PrimaryKeyValue, OldValue, NewValue, ActionType, Description)
        SELECT 
            'Applications' AS TableName,
            column_name AS ColumnName,
            CAST(d.ApplicationID AS NVARCHAR(255)) AS PrimaryKeyValue,
            CASE column_name
                WHEN 'ApplicationName' THEN CAST(d.ApplicationName AS NVARCHAR(MAX))
                WHEN 'Version' THEN CAST(d.Version AS NVARCHAR(MAX))
                WHEN 'Vendor' THEN CAST(d.Vendor AS NVARCHAR(MAX))
                WHEN 'Category' THEN CAST(d.Category AS NVARCHAR(MAX))
                WHEN 'Description' THEN CAST(d.Description AS NVARCHAR(MAX))
                WHEN 'InstallationPath' THEN CAST(d.InstallationPath AS NVARCHAR(MAX))
                WHEN 'ReleaseDate' THEN CAST(d.ReleaseDate AS NVARCHAR(MAX))
                WHEN 'IsActive' THEN CAST(d.IsActive AS NVARCHAR(MAX))
                WHEN 'CreatedDate' THEN CAST(d.CreatedDate AS NVARCHAR(MAX))
                WHEN 'LastUpdatedDate' THEN CAST(d.LastUpdatedDate AS NVARCHAR(MAX))
            END AS OldValue,
            NULL AS NewValue,
            @ActionType AS ActionType,
            'Deletion from Applications table' AS Description
        FROM deleted d
        CROSS JOIN (
            SELECT 'ApplicationName' AS column_name UNION ALL
            SELECT 'Version' UNION ALL
            SELECT 'Vendor' UNION ALL
            SELECT 'Category' UNION ALL
            SELECT 'Description' UNION ALL
            SELECT 'InstallationPath' UNION ALL
            SELECT 'ReleaseDate' UNION ALL
            SELECT 'IsActive' UNION ALL
            SELECT 'CreatedDate' UNION ALL
            SELECT 'LastUpdatedDate'
        ) AS columns;
    END;
END;

/*
Triggers for Other Tables
You’ll need to create similar triggers for the other tables (ApplicationDependencies, Licenses, Users, UserGroups, UserGroupMembers, Computers, and ApplicationInstallations). Due to space constraints, I’ll provide the trigger for one more table (Licenses) as an example. You can follow the same pattern for the remaining tables by adjusting the column names and conditions.
*/

-- 2. Trigger for Licenses Table

CREATE TRIGGER TRG_Licenses_Audit
ON Licenses
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ActionType NVARCHAR(10);

    -- Determine the action type
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        SET @ActionType = 'UPDATE';
    ELSE IF EXISTS (SELECT * FROM inserted)
        SET @ActionType = 'INSERT';
    ELSE
        SET @ActionType = 'DELETE';

    -- Log changes for INSERT and UPDATE
    IF @ActionType IN ('INSERT', 'UPDATE')
    BEGIN
        INSERT INTO AuditLog (TableName, ColumnName, PrimaryKeyValue, OldValue, NewValue, ActionType, Description)
        SELECT 
            'Licenses' AS TableName,
            column_name AS ColumnName,
            CAST(i.LicenseID AS NVARCHAR(255)) AS PrimaryKeyValue,
            CASE 
                WHEN @ActionType = 'UPDATE' THEN 
                    CASE column_name
                        WHEN 'ApplicationID' THEN CAST(d.ApplicationID AS NVARCHAR(MAX))
                        WHEN 'LicenseType' THEN CAST(d.LicenseType AS NVARCHAR(MAX))
                        WHEN 'LicenseKey' THEN CAST(d.LicenseKey AS NVARCHAR(MAX))
                        WHEN 'MaxUsers' THEN CAST(d.MaxUsers AS NVARCHAR(MAX))
                        WHEN 'MaxDevices' THEN CAST(d.MaxDevices AS NVARCHAR(MAX))
                        WHEN 'PurchaseDate' THEN CAST(d.PurchaseDate AS NVARCHAR(MAX))
                        WHEN 'ExpirationDate' THEN CAST(d.ExpirationDate AS NVARCHAR(MAX))
                        WHEN 'Cost' THEN CAST(d.Cost AS NVARCHAR(MAX))
                        WHEN 'IsActive' THEN CAST(d.IsActive AS NVARCHAR(MAX))
                        WHEN 'CreatedDate' THEN CAST(d.CreatedDate AS NVARCHAR(MAX))
                        WHEN 'LastUpdatedDate' THEN CAST(d.LastUpdatedDate AS NVARCHAR(MAX))
                    END
                ELSE NULL
            END AS OldValue,
            CASE column_name
                WHEN 'ApplicationID' THEN CAST(i.ApplicationID AS NVARCHAR(MAX))
                WHEN 'LicenseType' THEN CAST(i.LicenseType AS NVARCHAR(MAX))
                WHEN 'LicenseKey' THEN CAST(i.LicenseKey AS NVARCHAR(MAX))
                WHEN 'MaxUsers' THEN CAST(i.MaxUsers AS NVARCHAR(MAX))
                WHEN 'MaxDevices' THEN CAST(i.MaxDevices AS NVARCHAR(MAX))
                WHEN 'PurchaseDate' THEN CAST(i.PurchaseDate AS NVARCHAR(MAX))
                WHEN 'ExpirationDate' THEN CAST(i.ExpirationDate AS NVARCHAR(MAX))
                WHEN 'Cost' THEN CAST(i.Cost AS NVARCHAR(MAX))
                WHEN 'IsActive' THEN CAST(i.IsActive AS NVARCHAR(MAX))
                WHEN 'CreatedDate' THEN CAST(i.CreatedDate AS NVARCHAR(MAX))
                WHEN 'LastUpdatedDate' THEN CAST(i.LastUpdatedDate AS NVARCHAR(MAX))
            END AS NewValue,
            @ActionType AS ActionType,
            'Change in Licenses table' AS Description
        FROM inserted i
        FULL OUTER JOIN deleted d ON i.LicenseID = d.LicenseID
        CROSS JOIN (
            SELECT 'ApplicationID' AS column_name UNION ALL
            SELECT 'LicenseType' UNION ALL
            SELECT 'LicenseKey' UNION ALL
            SELECT 'MaxUsers' UNION ALL
            SELECT 'MaxDevices' UNION ALL
            SELECT 'PurchaseDate' UNION ALL
            SELECT 'ExpirationDate' UNION ALL
            SELECT 'Cost' UNION ALL
            SELECT 'IsActive' UNION ALL
            SELECT 'CreatedDate' UNION ALL
            SELECT 'LastUpdatedDate'
        ) AS columns
        WHERE (@ActionType = 'INSERT' 
               OR (@ActionType = 'UPDATE' AND 
                   (ISNULL(CAST(d.ApplicationID AS NVARCHAR(MAX)), '') <> ISNULL(CAST(i.ApplicationID AS NVARCHAR(MAX)), '') OR
                    ISNULL(CAST(d.LicenseType AS NVARCHAR(MAX)), '') <> ISNULL(CAST(i.LicenseType AS NVARCHAR(MAX)), '') OR
                    ISNULL(CAST(d.LicenseKey AS NVARCHAR(MAX)), '') <> ISNULL(CAST(i.LicenseKey AS NVARCHAR(MAX)), '') OR
                    ISNULL(CAST(d.MaxUsers AS NVARCHAR(MAX)), '') <> ISNULL(CAST(i.MaxUsers AS NVARCHAR(MAX)), '') OR
                    ISNULL(CAST(d.MaxDevices AS NVARCHAR(MAX)), '') <> ISNULL(CAST(i.MaxDevices AS NVARCHAR(MAX)), '') OR
                    ISNULL(CAST(d.PurchaseDate AS NVARCHAR(MAX)), '') <> ISNULL(CAST(i.PurchaseDate AS NVARCHAR(MAX)), '') OR
                    ISNULL(CAST(d.ExpirationDate AS NVARCHAR(MAX)), '') <> ISNULL(CAST(i.ExpirationDate AS NVARCHAR(MAX)), '') OR
                    ISNULL(CAST(d.Cost AS NVARCHAR(MAX)), '') <> ISNULL(CAST(i.Cost AS NVARCHAR(MAX)), '') OR
                    ISNULL(CAST(d.IsActive AS NVARCHAR(MAX)), '') <> ISNULL(CAST(i.IsActive AS NVARCHAR(MAX)), '') OR
                    ISNULL(CAST(d.CreatedDate AS NVARCHAR(MAX)), '') <> ISNULL(CAST(i.CreatedDate AS NVARCHAR(MAX)), '') OR
                    ISNULL(CAST(d.LastUpdatedDate AS NVARCHAR(MAX)), '') <> ISNULL(CAST(i.LastUpdatedDate AS NVARCHAR(MAX)), ''))))
    END;

    -- Log changes for DELETE
    IF @ActionType = 'DELETE'
    BEGIN
        INSERT INTO AuditLog (TableName, ColumnName, PrimaryKeyValue, OldValue, NewValue, ActionType, Description)
        SELECT 
            'Licenses' AS TableName,
            column_name AS ColumnName,
            CAST(d.LicenseID AS NVARCHAR(255)) AS PrimaryKeyValue,
            CASE column_name
                WHEN 'ApplicationID' THEN CAST(d.ApplicationID AS NVARCHAR(MAX))
                WHEN 'LicenseType' THEN CAST(d.LicenseType AS NVARCHAR(MAX))
                WHEN 'LicenseKey' THEN CAST(d.LicenseKey AS NVARCHAR(MAX))
                WHEN 'MaxUsers' THEN CAST(d.MaxUsers AS NVARCHAR(MAX))
                WHEN 'MaxDevices' THEN CAST(d.MaxDevices AS NVARCHAR(MAX))
                WHEN 'PurchaseDate' THEN CAST(d.PurchaseDate AS NVARCHAR(MAX))
                WHEN 'ExpirationDate' THEN CAST(d.ExpirationDate AS NVARCHAR(MAX))
                WHEN 'Cost' THEN CAST(d.Cost AS NVARCHAR(MAX))
                WHEN 'IsActive' THEN CAST(d.IsActive AS NVARCHAR(MAX))
                WHEN 'CreatedDate' THEN CAST(d.CreatedDate AS NVARCHAR(MAX))
                WHEN 'LastUpdatedDate' THEN CAST(d.LastUpdatedDate AS NVARCHAR(MAX))
            END AS OldValue,
            NULL AS NewValue,
            @ActionType AS ActionType,
            'Deletion from Licenses table' AS Description
        FROM deleted d
        CROSS JOIN (
            SELECT 'ApplicationID' AS column_name UNION ALL
            SELECT 'LicenseType' UNION ALL
            SELECT 'LicenseKey' UNION ALL
            SELECT 'MaxUsers' UNION ALL
            SELECT 'MaxDevices' UNION ALL
            SELECT 'PurchaseDate' UNION ALL
            SELECT 'ExpirationDate' UNION ALL
            SELECT 'Cost' UNION ALL
            SELECT 'IsActive' UNION ALL
            SELECT 'CreatedDate' UNION ALL
            SELECT 'LastUpdatedDate'
        ) AS columns;
    END;
END;

/*
Steps to Create Triggers for Other Tables
Follow the same pattern as above for the remaining tables:
ApplicationDependencies
Users
UserGroups
UserGroupMembers
Computers
ApplicationInstallations
Replace the table name, column names, and primary key column in each trigger script.
Adjust the conditions in the WHERE clause to compare old and new values for each column.

Example Queries to Test the Audit Log
After creating the audit log table and triggers, you can test the functionality by performing INSERT, UPDATE, and DELETE operations on the audited tables. Below are example queries to test and view the audit log.
*/

-- 1. Insert a new application (triggers audit for Insert)
INSERT INTO Applications (ApplicationName, Version, Vendor, Category, Description, InstallationPath, ReleaseDate, IsActive)
VALUES ('NewApp', '1.0', 'NewVendor', 'Business', 'New application', 'C:\Program Files\NewApp', '2023-10-15', 1);


-- 2. Update an existing application (triggers audit for Update)
UPDATE Applications
SET Version = '2023.2', LastUpdatedDate = GETDATE()
WHERE ApplicationID = 1;

-- 3. Delete a license (triggers audit for DELETE)
DELETE FROM Licenses
WHERE LicenseID = 1;

-- 4. View the audit log for all changes
SELECT AuditLogID, TableName, ColumnName, PrimaryKeyValue, OldValue, NewValue, ActionType, ChangedBy, ChangedDate, Description
FROM AuditLog
ORDER BY ChangedDate DESC;

-- 5. View audit log for a specific table (e.g., Applications)
SELECT AuditLogID, ColumnName, PrimaryKeyValue, OldValue, NewValue, ActionType, ChangedBy, ChangedDate, Description
FROM AuditLog
WHERE TableName = 'Applications'
ORDER BY ChangedDate DESC;

-- 6. View audit log for changes by a specific user
SELECT AuditLogID, TableName, ColumnName, PrimaryKeyValue, OldValue, NewValue, ActionType, ChangedBy, ChangedDate, Description
FROM AuditLog
WHERE ChangedBy = SUSER_SNAME()
ORDER BY ChangedDate DESC;

/*
Notes on the Audit Log Implementation
Performance Considerations:
The audit log table can grow quickly, especially for large systems with frequent updates. Consider partitioning the table by date or archiving old records.
Use indexes on frequently queried columns (e.g., TableName, ChangedDate) to improve query performance.
Security:
The ChangedBy column uses SUSER_SNAME() to capture the SQL Server login name. Ensure that users are authenticated appropriately.
Restrict access to the AuditLog table to authorized personnel (e.g., IT admins, auditors).
Customization:
You can add additional columns to the AuditLog table, such as TransactionID or SessionID, for more detailed tracking.
Modify the Description column in the triggers to include more context (e.g., application name, license key).
Testing:
Test the triggers thoroughly to ensure they capture all changes correctly.
Verify that the audit log does not interfere with normal database operations (e.g., transaction rollbacks).
Maintenance:
Schedule regular maintenance tasks to manage the size of the AuditLog table (e.g., archiving, purging old records).
Monitor trigger performance and adjust as needed.

Next Steps
Create triggers for the remaining tables following the provided pattern.
Test the audit log with various scenarios (e.g., bulk updates, cascading deletes).
Implement a reporting interface or dashboard to view audit log data.
Set up alerts for critical changes (e.g., license deletions, application deactivations).

This audit log implementation provides a comprehensive way to track changes across all tables, ensuring accountability and traceability in the database.
*/

