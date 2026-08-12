-- ============================================================
-- RealEstate_Operations Database
-- New_Cairo_RealEstate_DW Project
-- ============================================================
CREATE DATABASE RealEstate_Operations;
GO

USE RealEstate_Operations;
GO
-- ============================================================
DROP TABLE IF EXISTS Fact_Monthly_Expenses;
DROP TABLE IF EXISTS Fact_Rental_Transactions;
DROP TABLE IF EXISTS Fact_Sales_Transactions;
DROP TABLE IF EXISTS Fact_Leads_Operations;
DROP TABLE IF EXISTS Dim_Employee_Career_History;
DROP TABLE IF EXISTS Dim_Properties;
DROP TABLE IF EXISTS Dim_Sellers;
DROP TABLE IF EXISTS Dim_Employees;
DROP TABLE IF EXISTS Dim_Marketing_Leads;
DROP TABLE IF EXISTS Dim_Marketing_Campaigns;
DROP TABLE IF EXISTS Dim_Clients;
DROP TABLE IF EXISTS Dim_Departments_Roles;
GO
-- ============================================================
-- 1. إنشاء جدول العقارات (Dim_Properties)
-- ============================================================
CREATE TABLE Dim_Properties (
    PropertyID VARCHAR(30) PRIMARY KEY,       -- Ex: NC_1aA0000001
    SellerID VARCHAR(20) NOT NULL,           -- Ex: OW0000001
    Square NVARCHAR(50) NOT NULL,            -- Ex: 1st Settlement / 5th Settlement
    District NVARCHAR(50) NOT NULL,          -- Ex: Banafseg / Hay 1 / Mivida
    Zone NVARCHAR(50) NULL,                  -- Ex: Villette / Building / Mall
    YearAdded INT NOT NULL,                  -- 2023, 2024, 2025, 2026
    PropertyCategory NVARCHAR(20) NOT NULL,  -- Compound / Open Area
    UsageType NVARCHAR(20) NOT NULL,          -- Residential / Administrative / Commercial / Medical
    PropertyType NVARCHAR(30) NOT NULL,       -- Apartment, Studio, Duplex, Townhouse, Office, Store, Clinic, etc.
    Floor NVARCHAR(20) NOT NULL,             -- Ground, 1, 2, 3, 4, 5, Roof
    BUA_SQM DECIMAL(10, 2) NOT NULL,         -- Built-up Area in m² (65 to 500)
    Amenities NVARCHAR(100) NULL,            -- Elevator, Parking, Garden, Roof, Pool
    MasterRoom INT DEFAULT 0,
    MainRoom INT DEFAULT 1,
    MaidsRoom INT DEFAULT 0,
    MasterBathroom INT DEFAULT 0,
    MainBathroom INT DEFAULT 1,
    GuestToilet INT DEFAULT 0,
    FinishingLevel NVARCHAR(30) NOT NULL,    -- Core & Shell, Semi Finished, Fully Finished
    FurnishingStatus NVARCHAR(30) NOT NULL,  -- Unfurnished, Semi Furnished, Fully Furnished
    SellingOption NVARCHAR(30) NOT NULL,     -- Rent, Sale Cash, Sale Installment
    UnitStatus NVARCHAR(30) NOT NULL,        -- Rented, Sold, Available, Hold Temporarily, Unreachable
    Amount_Downpayment DECIMAL(18, 2) NOT NULL, -- Rent price or Sale price/Downpayment
    RemainingAmount DECIMAL(18, 2) DEFAULT 0,   -- Remaining amount if installment
    CreatedDateTime DATETIME NOT NULL,
    EnteredByEmployeeID VARCHAR(20) NOT NULL,
    RentedDateTime DATETIME NULL
);
GO
-- ============================================================
-- 2. إنشاء جدول العملاء (Dim_Clients)
-- ============================================================
CREATE TABLE Dim_Clients (
    ClientID VARCHAR(20) PRIMARY KEY,
    ClientName NVARCHAR(100) NOT NULL,
    Gender NVARCHAR(10) CHECK (Gender IN ('Male', 'Female')),
    Phone NVARCHAR(20) NOT NULL,
    Email NVARCHAR(100) NULL,
    ClientType NVARCHAR(20) NOT NULL CHECK (ClientType IN ('Buyer', 'Seller', 'Tenant', 'Landlord')),
    TargetDealType NVARCHAR(30) NOT NULL,   -- Sale Cash, Sale Installment, Rent
    LeadSource NVARCHAR(50) NOT NULL,
    PreferredUsage NVARCHAR(20) NOT NULL,   -- Residential, Administrative, Commercial, Medical
    PreferredLocation NVARCHAR(50) NOT NULL,
    MinBudget_EGP DECIMAL(18, 2) NOT NULL,
    MaxBudget_EGP DECIMAL(18, 2) NOT NULL,
    ClientClass NVARCHAR(10) NOT NULL,      -- Class A, Class B, Class C
    ClientStatus NVARCHAR(30) NOT NULL,     -- Active, Converted/Closed, Inactive, Hot Lead, Cold Lead
    CreatedDate DATE NOT NULL
);
GO
-- ============================================================
-- 3. إنشاء جدول البائعين (Dim_Sellers)
-- ============================================================
CREATE TABLE Dim_Sellers (
    SellerID VARCHAR(20) PRIMARY KEY,
    SellerName NVARCHAR(150) NOT NULL,
    SellerTypeCode VARCHAR(5) NOT NULL,       -- OW, BR, HS, DV
    SellerType NVARCHAR(50) NOT NULL,         -- Individual Owner, External Co-Broker, Hospitality Company, Real Estate Developer
    OfferingDealType NVARCHAR(30) NOT NULL,   -- Sale, Rent, Both (Sale & Rent)
    Phone NVARCHAR(20) NOT NULL,
    Email NVARCHAR(100) NULL,
    PartnerStatus NVARCHAR(30) NOT NULL,      -- Active Partner, Under Review, Verified
    CreatedDateTime DATETIME NOT NULL,
    EnteredByEmployeeID VARCHAR(20) NOT NULL
);
GO
-- ============================================================
-- ربط Dim_Properties بـ Dim_Sellers
-- ============================================================
ALTER TABLE Dim_Properties
ADD CONSTRAINT FK_Properties_Seller FOREIGN KEY (SellerID) REFERENCES Dim_Sellers(SellerID);
GO
-- ============================================================
-- 4. إنشاء جدول أقسام الإدارات والرولز (Dim_Departments_Roles)
-- ============================================================
CREATE TABLE Dim_Departments_Roles (
    RoleID VARCHAR(10) PRIMARY KEY,
    DepartmentID VARCHAR(10) NOT NULL,
    DepartmentName NVARCHAR(50) NOT NULL,
    RoleName NVARCHAR(50) NOT NULL,
    EstablishedYear INT NOT NULL
);
GO
-- ============================================================
-- 5. إنشاء جدول الموظفين (Dim_Employees)
-- ============================================================
CREATE TABLE Dim_Employees (
    EmployeeID VARCHAR(20) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Gender NVARCHAR(10) CHECK (Gender IN ('Male', 'Female')),
    DepartmentID VARCHAR(10) NOT NULL,
    CurrentRoleID VARCHAR(10) NOT NULL,
    HireDate DATE NOT NULL,
    ExitDate DATE NULL,
    Status NVARCHAR(30) NOT NULL CHECK (Status IN ('Active', 'Resigned', 'Terminated', 'Promoted')),
    BaseSalary_EGP DECIMAL(10, 2) NOT NULL,
    CommissionRate DECIMAL(6, 4) DEFAULT 0.0000,
    ManagerID VARCHAR(20) NULL,
    CONSTRAINT FK_Employees_Role FOREIGN KEY (CurrentRoleID) REFERENCES Dim_Departments_Roles(RoleID),
    CONSTRAINT FK_Employees_Manager FOREIGN KEY (ManagerID) REFERENCES Dim_Employees(EmployeeID)
);
GO
-- ============================================================
-- ربط Dim_Properties بموظف إدخال بيانات الوحدة 
-- ============================================================
ALTER TABLE Dim_Properties
ADD CONSTRAINT FK_Properties_EnteredBy FOREIGN KEY (EnteredByEmployeeID) REFERENCES Dim_Employees(EmployeeID);
GO
-- ============================================================
-- ربط Dim_Sellers بموظف إدخال بيانات بيانات البائع
-- ============================================================
ALTER TABLE Dim_Sellers
ADD CONSTRAINT FK_Sellers_EnteredBy FOREIGN KEY (EnteredByEmployeeID) REFERENCES Dim_Employees(EmployeeID);
GO
-- ============================================================
-- 6. إنشاء جدول سجل التاريخ الوظيفي (Dim_Employee_Career_History)
-- ============================================================
CREATE TABLE Dim_Employee_Career_History (
    HistoryID VARCHAR(20) PRIMARY KEY,
    EmployeeID VARCHAR(20) NOT NULL,
    EffectiveDate DATE NOT NULL,
    RoleID VARCHAR(10) NOT NULL,
    RoleName NVARCHAR(50) NOT NULL,
    Salary_EGP DECIMAL(10, 2) NOT NULL,
    EventType NVARCHAR(30) NOT NULL CHECK (EventType IN ('Hire', 'Promotion', 'Resignation', 'Termination')),
    CONSTRAINT FK_History_Employee FOREIGN KEY (EmployeeID) REFERENCES Dim_Employees(EmployeeID),
    CONSTRAINT FK_History_Role FOREIGN KEY (RoleID) REFERENCES Dim_Departments_Roles(RoleID)
);
GO
-- ============================================================
-- 7. إنشاء جدول الحملات التسويقية (Dim_Marketing_Campaigns)
-- ============================================================
CREATE TABLE Dim_Marketing_Campaigns (
    CampaignID VARCHAR(30) PRIMARY KEY,
    CampaignName NVARCHAR(100) NOT NULL,
    Platform NVARCHAR(50) NOT NULL,
    Budget_EGP DECIMAL(12, 2) DEFAULT 0.00,
    LaunchYear INT NOT NULL
);
GO
-- ============================================================
-- 8. إنشاء جدول الحملات والعملاء المحتملين (Dim_Marketing_Leads)
-- ============================================================
CREATE TABLE Dim_Marketing_Leads (
    LeadID VARCHAR(20) PRIMARY KEY,
    ClientID VARCHAR(20) NOT NULL,
    CampaignID VARCHAR(30) NOT NULL,
    CampaignName NVARCHAR(100) NOT NULL,
    Platform NVARCHAR(50) NOT NULL,
    LeadQualityScore NVARCHAR(20) CHECK (LeadQualityScore IN ('Hot', 'Warm', 'Cold')),
    ReceivedDateTime DATETIME NOT NULL,
    CONSTRAINT FK_Leads_Client FOREIGN KEY (ClientID) REFERENCES Dim_Clients(ClientID),
    CONSTRAINT FK_Leads_Campaign FOREIGN KEY (CampaignID) REFERENCES Dim_Marketing_Campaigns(CampaignID)
);
GO
-- ============================================================
-- 9. إنشاء جدول المصروفات الشهرية (Fact_Monthly_Expenses)
-- ============================================================
CREATE TABLE Fact_Monthly_Expenses (
    ExpenseID VARCHAR(20) PRIMARY KEY,
    ExpenseYear INT NOT NULL,
    ExpenseMonth INT NOT NULL CHECK (ExpenseMonth BETWEEN 1 AND 12),
    ExpenseCategory NVARCHAR(50) NOT NULL,   -- Office Rent, Electricity, Office Supplies
    Amount_EGP DECIMAL(12, 2) NOT NULL
);
GO
-- ============================================================
-- 10. إنشاء جدول العمليات والدورة الإدارية (Fact_Leads_Operations)
-- ============================================================
CREATE TABLE Fact_Leads_Operations (
    OperationID VARCHAR(20) PRIMARY KEY,
    LeadID VARCHAR(20) NOT NULL,
    OperationDateTime DATETIME NOT NULL,
    ModeratorID VARCHAR(20) NOT NULL,
    SalesAdminID VARCHAR(20) NOT NULL,
    LastActivity NVARCHAR(100) NOT NULL,
    OperationStatus NVARCHAR(50) NOT NULL CHECK (OperationStatus IN ('Qualified / Assigned', 'Pending Unit Details', 'Unresponsive', 'Disqualified')),
    ResponseTimeMinutes INT CHECK (ResponseTimeMinutes >= 0),
    UnitCatalogUpdated BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_Ops_Lead FOREIGN KEY (LeadID) REFERENCES Dim_Marketing_Leads(LeadID),
    CONSTRAINT FK_Ops_Moderator FOREIGN KEY (ModeratorID) REFERENCES Dim_Employees(EmployeeID),
    CONSTRAINT FK_Ops_SalesAdmin FOREIGN KEY (SalesAdminID) REFERENCES Dim_Employees(EmployeeID)
);
GO
-- ============================================================
-- 11. إنشاء جدول صفقات البيع (Fact_Sales_Transactions)
-- ============================================================
CREATE TABLE Fact_Sales_Transactions (
    TransactionID VARCHAR(20) PRIMARY KEY,
    LeadID VARCHAR(20) NOT NULL,
    ClientID VARCHAR(20) NOT NULL,
    PropertyID VARCHAR(30) NOT NULL,
    SaleDate DATE NOT NULL,
    SalesRepID VARCHAR(20) NOT NULL,
    TeamLeaderID VARCHAR(20) NOT NULL,
    UnitPrice_EGP DECIMAL(18, 2) NOT NULL,
    CompanyCommission_EGP DECIMAL(12, 2) NOT NULL,
    AgentCommission_EGP DECIMAL(12, 2) NOT NULL,
    PaymentMethod NVARCHAR(30) CHECK (PaymentMethod IN ('Installments', 'Cash / Lump Sum')),
    IsFirstPurchase BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_Sales_Lead FOREIGN KEY (LeadID) REFERENCES Dim_Marketing_Leads(LeadID),
    CONSTRAINT FK_Sales_Client FOREIGN KEY (ClientID) REFERENCES Dim_Clients(ClientID),
    CONSTRAINT FK_Sales_Property FOREIGN KEY (PropertyID) REFERENCES Dim_Properties(PropertyID),
    CONSTRAINT FK_Sales_Rep FOREIGN KEY (SalesRepID) REFERENCES Dim_Employees(EmployeeID),
    CONSTRAINT FK_Sales_TL FOREIGN KEY (TeamLeaderID) REFERENCES Dim_Employees(EmployeeID)
);
GO
-- ============================================================
-- 12. إنشاء جدول صفقات الإيجار (Fact_Rental_Transactions)
-- ============================================================
CREATE TABLE Fact_Rental_Transactions (
    RentalTransactionID VARCHAR(20) PRIMARY KEY,
    LeadID VARCHAR(20) NOT NULL,
    PropertyID VARCHAR(30) NOT NULL,
    RentalDate DATE NOT NULL,
    SalesRepID VARCHAR(20) NOT NULL,
    TeamLeaderID VARCHAR(20) NOT NULL,
    MonthlyRent_EGP DECIMAL(12, 2) NOT NULL,
    CompanyCommission_EGP DECIMAL(12, 2) NOT NULL,   -- شهر إيجار من المالك + شهر من المستأجر
    AgentCommission_EGP DECIMAL(12, 2) NOT NULL,
    CONSTRAINT FK_Rental_Lead FOREIGN KEY (LeadID) REFERENCES Dim_Marketing_Leads(LeadID),
    CONSTRAINT FK_Rental_Property FOREIGN KEY (PropertyID) REFERENCES Dim_Properties(PropertyID),
    CONSTRAINT FK_Rental_Rep FOREIGN KEY (SalesRepID) REFERENCES Dim_Employees(EmployeeID),
    CONSTRAINT FK_Rental_TL FOREIGN KEY (TeamLeaderID) REFERENCES Dim_Employees(EmployeeID)
);
GO