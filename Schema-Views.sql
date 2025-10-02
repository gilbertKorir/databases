--SCHEMA -  a folder that organizes your database objects.
--Creating Schemas
CREATE SCHEMA schema_name;

-- Set search path (default schema)
SET search_path TO sales, public;

--Show Current Schema:
SELECT current_schema();

--List All Schemas:
SELECT schema_name 
FROM information_schema.schemata;

--List All Tables in Schema:
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'artdb';

--By Data Lifecycle:
CREATE SCHEMA current_data;
CREATE SCHEMA archived_data;
CREATE SCHEMA staging_data;

-- Move old data to archive
INSERT INTO archived_data.orders 
SELECT * FROM current_data.orders 
WHERE order_date < '2020-01-01';


--Schema Permissions
-- Grant usage on schema
GRANT USAGE ON SCHEMA sales TO sales_team;

-- Grant create privilege
GRANT CREATE ON SCHEMA sales TO sales_admin;

-- Grant all privileges
GRANT ALL ON SCHEMA sales TO sales_manager;

-- Grant access to all tables in schema
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA sales TO sales_team;

-- Grant access to future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA sales
GRANT SELECT ON TABLES TO sales_team;

--Revoke Access:

REVOKE ALL ON SCHEMA sales FROM sales_team;

--Drop Schema:
-- Drop empty schema
DROP SCHEMA schema_name;

-- Drop schema with all objects (dangerous!)
DROP SCHEMA schema_name CASCADE;

-- Safe drop
DROP SCHEMA IF EXISTS schema_name RESTRICT; -- Fails if not empty

-- ==== VIEWS ==== ---
--Creating Views
CREATE VIEW class_view AS
SELECT * FROM students

SELECT * FROM class_view;


