--Water_Fact/Associated Dimensions DDL 
-- Sample Dimension
CREATE TABLE sample_dim (
    sample_key INT PRIMARY KEY,
    sample_code VARCHAR(124),
    sample_depth NUMERIC(5, 2), 
    sample_units VARCHAR(124)
);

-- Station Dimension
CREATE TABLE station_dim (
    station_key INT PRIMARY KEY,
    station_id INT,
    station_number VARCHAR(124),
    full_station_name VARCHAR(124),
    station_type VARCHAR(124),
    previous_station_name VARCHAR(124),
    effective_date TIMESTAMP
);

-- Method Dimension
CREATE TABLE method_dim (
    method_key INT PRIMARY KEY,
    method_name VARCHAR(124),
    method_active BOOLEAN,
    method_effdate TIMESTAMP, 
    method_enddate TIMESTAMP
);

-- Time Dimension
CREATE TABLE time_dim (
    time_key INT PRIMARY KEY,
    sample_date DATE,          
    sample_day VARCHAR(50),
    sample_year INT,
    sample_month INT,
    year_month VARCHAR(50)     
);

-- Fact Table: Water Fact
CREATE TABLE water_fact (
    waterfact_key INT PRIMARY KEY,
    station_key INT,
    sample_key INT,
    time_key INT,
    location_key INT,
    method_key INT,
    avg_oxygen_mg_l NUMERIC(10, 2),     
    avg_conductance_us_cm NUMERIC(10, 2),
    avg_turbidity_nfu NUMERIC(10, 2),
    avg_temp_c NUMERIC(10, 2),           
    avg_ph NUMERIC(5, 2),                
    avg_chlorophyll_ug_l NUMERIC(10, 2), 
    FOREIGN KEY (station_key) REFERENCES station_dim(station_key),
    FOREIGN KEY (sample_key) REFERENCES sample_dim(sample_key),
    FOREIGN KEY (time_key) REFERENCES time_dim(time_key),
    FOREIGN KEY (location_key) REFERENCES location_dim(location_key),
    FOREIGN KEY (method_key) REFERENCES method_dim(method_key)
);

