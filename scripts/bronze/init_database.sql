/*
==================================================================================
AI GENERATED
==================================================================================

    Description:
    This script initializes the DataWarehouseWSB database environment.
    It first checks whether the database already exists. If it does, the script
    forces all active connections to close, drops the existing database, and then
    recreates it from scratch.

    After creating the database, the script defines three schemas:
    - bronze: raw/source data layer
    - silver: cleaned and transformed data layer
    - gold: business-ready reporting and analytics layer

    Warning:
    This script is destructive. If the DataWarehouseWSB database already exists,
    it will be permanently dropped along with all tables, schemas, data, users,
    permissions, and other objects stored inside it.

    Run this script only in a development or test environment, or when you are
    absolutely sure that the existing database can be deleted.
*/


USE master;
GO

-- Drop and recreate 'DataWarehouseWSB' 
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseWSB')
BEGIN
	ALTER DATABASE DataWarehouseWSB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouseWSB;
END;
GO

-- Create 'DataWarehouseWSB'
CREATE DATABASE DataWarehouseWSB;
GO


USE DataWarehouseWSB;
GO

-- Create schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO

