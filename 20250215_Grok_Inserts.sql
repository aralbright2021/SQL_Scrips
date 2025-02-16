
--Examples

-- 1. Insert into Applications
INSERT INTO Applications (ApplicationName, Version, Vendor, Category, Description, InstallationPath, ReleaseDate, IsActive)
VALUES 
    ('CAD Pro', '2023.1', 'AutoCAD Inc.', 'Engineering', 'Computer-aided design software', 'C:\Program Files\CADPro', '2023-01-15', 1),
    ('Excel', '365', 'Microsoft', 'Business', 'Spreadsheet software', 'C:\Program Files\Office365', '2022-06-01', 1),
    ('MATLAB', 'R2023a', 'MathWorks', 'Engineering', 'Numerical computing software', 'C:\Program Files\MATLAB', '2023-03-10', 1);
	
-- 2. Insert into ApplicationDependencies
INSERT INTO ApplicationDependencies (ApplicationID, DependsOnApplicationID, DependencyType, IsMandatory)
VALUES 
    (3, 1, 'Runtime', 1); -- MATLAB depends on CAD Pro

-- 3. Insert into Licenses
INSERT INTO Licenses (ApplicationID, LicenseType, LicenseKey, MaxUsers, MaxDevices, PurchaseDate, ExpirationDate, Cost, IsActive)
VALUES 
    (1, 'Per Device', 'CAD-12345-XYZ', NULL, 10, '2023-02-01', '2024-02-01', 5000.00, 1),
    (2, 'Per User', 'EXCEL-98765-ABC', 50, NULL, '2022-07-01', NULL, 2000.00, 1),
    (3, 'Enterprise', 'MATLAB-54321-DEF', 100, 100, '2023-04-01', '2024-04-01', 10000.00, 1);

-- 4. Insert into Users
INSERT INTO Users (FirstName, LastName, Email, Department, JobTitle, IsActive)
VALUES 
    ('John', 'Doe', 'john.doe@company.com', 'Engineering', 'Senior Engineer', 1),
    ('Jane', 'Smith', 'jane.smith@company.com', 'Finance', 'Financial Analyst', 1),
    ('Mike', 'Johnson', 'mike.johnson@company.com', 'Engineering', 'Junior Engineer', 1);
	
-- 5. Insert into UserGroups
INSERT INTO UserGroups (GroupName, Description, IsActive)
VALUES 
    ('Engineering Team', 'Group for engineering department', 1),
    ('Finance Team', 'Group for finance department', 1);
	
-- 6. Insert into UserGroupMembers
INSERT INTO UserGroupMembers (UserID, GroupID)
VALUES 
    (1, 1), -- John Doe in Engineering Team
    (3, 1), -- Mike Johnson in Engineering Team
    (2, 2); -- Jane Smith in Finance Team
	
-- 7. Insert into Computers
INSERT INTO Computers (ComputerName, IPAddress, OperatingSystem, Department, Location, IsActive)
VALUES 
    ('ENG-PC001', '192.168.1.10', 'Windows 10', 'Engineering', 'Building A, Floor 2', 1),
    ('FIN-PC001', '192.168.1.20', 'Windows 11', 'Finance', 'Building B, Floor 1', 1),
    ('ENG-PC002', '192.168.1.11', 'Windows 10', 'Engineering', 'Building A, Floor 2', 1);
	
-- 8. Insert into ApplicationInstallations
INSERT INTO ApplicationInstallations (ApplicationID, ComputerID, LicenseID, UserID, GroupID, InstallationDate, LastUsedDate, IsActive)
VALUES 
    (1, 1, 1, 1, NULL, '2023-02-10', '2023-10-01', 1), -- CAD Pro on ENG-PC001 for John Doe
    (2, 2, 2, 2, NULL, '2022-07-15', '2023-10-02', 1), -- Excel on FIN-PC001 for Jane Smith
    (3, 3, 3, NULL, 1, '2023-04-15', '2023-09-30', 1); -- MATLAB on ENG-PC002 for Engineering Team
	
/*

Notes on the Insert Queries
The IDENTITY(1,1) property ensures that primary key values are auto-incremented.
Foreign key constraints ensure referential integrity (e.g., ApplicationID in Licenses must exist in Applications).
The sample data includes relationships, such as:
MATLAB depends on CAD Pro.
Applications are tied to specific licenses.
Installations are associated with users, groups, and computers.
The CreatedDate and LastUpdatedDate columns are automatically populated using GETDATE() defaults.

Verification Queries
After inserting the data, you can run the following queries to verify the relationships:

*/

--List all applications and their licenses:
SELECT a.ApplicationName, l.LicenseType, l.LicenseKey, l.MaxUsers, l.MaxDevices
FROM Applications a
JOIN Licenses l ON a.ApplicationID = l.ApplicationID;

--List all installations for a specific user:
SELECT a.ApplicationName, c.ComputerName, i.InstallationDate
FROM ApplicationInstallations i
JOIN Applications a ON i.ApplicationID = a.ApplicationID
JOIN Computers c ON i.ComputerID = c.ComputerID
WHERE i.UserID = 1; -- John Doe

--List dependencies for an application:
SELECT a.ApplicationName AS DependentApp, a2.ApplicationName AS DependsOnApp, d.DependencyType
FROM ApplicationDependencies d
JOIN Applications a ON d.ApplicationID = a.ApplicationID
JOIN Applications a2 ON d.DependsOnApplicationID = a2.ApplicationID;

/*
Next Steps
Test the database with additional data and edge cases.
Implement stored procedures or views for common queries.
Set up triggers for audit logging (e.g., track changes to licenses).
Integrate with an application or reporting tool for end-user interaction.

This setup provides a solid foundation for managing IT applications, licenses, and installations in a Microsoft SQL Server database.
*/