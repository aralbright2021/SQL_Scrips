-- Create Applications table
CREATE TABLE Applications (
    ApplicationID INT IDENTITY(1,1) PRIMARY KEY,
    ApplicationName NVARCHAR(100) NOT NULL,
    Version NVARCHAR(50),
    Vendor NVARCHAR(100),
    Category NVARCHAR(50),
    Description NVARCHAR(MAX),
    InstallationPath NVARCHAR(255),
    ReleaseDate DATE,
    IsActive BIT DEFAULT 1,
	OSRequirement NVARCHAR(100), -- added after the original Grok output, may need additional work - connect to OperatingSystem in Computers Table
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastUpdatedDate DATETIME DEFAULT GETDATE()
);

-- Create ApplicationDependencies table
CREATE TABLE ApplicationDependencies (
    DependencyID INT IDENTITY(1,1) PRIMARY KEY,
    ApplicationID INT NOT NULL,
    DependsOnApplicationID INT NOT NULL,
    DependencyType NVARCHAR(50),
    IsMandatory BIT DEFAULT 1,
	UsedWith NVARCHAR(100), -- added after the original Grok output, may need additional work
    CreatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_ApplicationDependencies_Application FOREIGN KEY (ApplicationID) REFERENCES Applications(ApplicationID),
    CONSTRAINT FK_ApplicationDependencies_DependsOn FOREIGN KEY (DependsOnApplicationID) REFERENCES Applications(ApplicationID)
);

-- Create Licenses table
CREATE TABLE Licenses (
    LicenseID INT IDENTITY(1,1) PRIMARY KEY,
    ApplicationID INT NOT NULL,
    LicenseType NVARCHAR(50),
    LicenseKey NVARCHAR(100),
    MaxUsers INT,
    MaxDevices INT,
    PurchaseDate DATE,
    ExpirationDate DATE,
    Cost DECIMAL(10, 2),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastUpdatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Licenses_Application FOREIGN KEY (ApplicationID) REFERENCES Applications(ApplicationID),
    CONSTRAINT CHK_ExpirationDate CHECK (ExpirationDate > PurchaseDate)
);

-- Create Users table
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Department NVARCHAR(50),
    JobTitle NVARCHAR(50),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastUpdatedDate DATETIME DEFAULT GETDATE()
);

-- Create UserGroups table
CREATE TABLE UserGroups (
    GroupID INT IDENTITY(1,1) PRIMARY KEY,
    GroupName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastUpdatedDate DATETIME DEFAULT GETDATE()
);

-- Create UserGroupMembers table
CREATE TABLE UserGroupMembers (
    MembershipID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    GroupID INT NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_UserGroupMembers_User FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_UserGroupMembers_Group FOREIGN KEY (GroupID) REFERENCES UserGroups(GroupID)
);

-- Create Computers table
CREATE TABLE Computers (
    ComputerID INT IDENTITY(1,1) PRIMARY KEY,
    ComputerName NVARCHAR(100) NOT NULL,
    IPAddress NVARCHAR(15),
    OperatingSystem NVARCHAR(50),
    Department NVARCHAR(50),
    Location NVARCHAR(100),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastUpdatedDate DATETIME DEFAULT GETDATE()
);

-- Create ApplicationInstallations table
CREATE TABLE ApplicationInstallations (
    InstallationID INT IDENTITY(1,1) PRIMARY KEY,
    ApplicationID INT NOT NULL,
    ComputerID INT NOT NULL,
    LicenseID INT,
    UserID INT,
    GroupID INT,
    InstallationDate DATE,
    LastUsedDate DATE,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastUpdatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_ApplicationInstallations_Application FOREIGN KEY (ApplicationID) REFERENCES Applications(ApplicationID),
    CONSTRAINT FK_ApplicationInstallations_Computer FOREIGN KEY (ComputerID) REFERENCES Computers(ComputerID),
    CONSTRAINT FK_ApplicationInstallations_License FOREIGN KEY (LicenseID) REFERENCES Licenses(LicenseID),
    CONSTRAINT FK_ApplicationInstallations_User FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_ApplicationInstallations_Group FOREIGN KEY (GroupID) REFERENCES UserGroups(GroupID)
);

-- Create indexes for frequently queried columns
CREATE INDEX IX_ApplicationInstallations_ApplicationID ON ApplicationInstallations(ApplicationID);
CREATE INDEX IX_ApplicationInstallations_ComputerID ON ApplicationInstallations(ComputerID);
CREATE INDEX IX_ApplicationInstallations_LicenseID ON ApplicationInstallations(LicenseID);
CREATE INDEX IX_ApplicationInstallations_UserID ON ApplicationInstallations(UserID);
CREATE INDEX IX_ApplicationInstallations_GroupID ON ApplicationInstallations(GroupID);
CREATE INDEX IX_ApplicationDependencies_ApplicationID ON ApplicationDependencies(ApplicationID);
CREATE INDEX IX_ApplicationDependencies_DependsOnApplicationID ON ApplicationDependencies(DependsOnApplicationID);
CREATE INDEX IX_Licenses_ApplicationID ON Licenses(ApplicationID);
CREATE INDEX IX_UserGroupMembers_UserID ON UserGroupMembers(UserID);
CREATE INDEX IX_UserGroupMembers_GroupID ON UserGroupMembers(GroupID);