-- Create schema for the project
CREATE DATABASE IF NOT EXISTS air_quality;
USE air_quality;

-- Create table for raw data (matching the CSV structure)
CREATE TABLE raw_air_quality (
    state_code VARCHAR(10),
    county_code VARCHAR(10),
    site_num VARCHAR(10),
    parameter_code VARCHAR(10),
    poc VARCHAR(10),
    latitude VARCHAR(20),
    longitude VARCHAR(20),
    datum VARCHAR(20),
    parameter_name TEXT,
    sample_duration TEXT,
    pollutant_standard TEXT,
    date_local DATE,
    units_of_measure TEXT,
    event_type TEXT,
    observation_count VARCHAR(10),
    observation_percent VARCHAR(20),
    arithmetic_mean VARCHAR(20),
    first_max_value VARCHAR(20),
    first_max_hour VARCHAR(10),
    aqi VARCHAR(10),
    method_code VARCHAR(10),
    method_name TEXT,
    local_site_name TEXT,
    address TEXT,
    state_name TEXT,
    county_name TEXT,
    city_name TEXT,
    cbsa_name TEXT,
    date_of_last_change DATETIME
);

-- Load your CSV data into this table using MySQL's LOAD DATA INFILE
-- LOAD DATA LOCAL INFILE 'path/to/your/us_air_quality_data.csv'
-- INTO TABLE raw_air_quality
-- FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;