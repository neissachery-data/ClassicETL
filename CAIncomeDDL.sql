create database CA_DWH;

create table location_dim (
	location_key int primary key,
	country varchar(50),
	state varchar(124),
	county varchar(124)
);

create table rank_dim (
	medianrank_key int primary key,
	medianrank int
);

create table tax_year_dim(
	year_key int primary key,
	tax_year int
);

create table CAIncomeFact(
	income_key int primary key,
	original_id int,
	year_key int,
	medianrank_key int,
	location_key int,
	population int,
	all_returns decimal(16,2),
	median_income decimal(16,2),
	FOREIGN KEY (year_key) REFERENCES tax_year_dim(year_key),
    FOREIGN KEY (medianrank_key) REFERENCES rank_dim(medianrank_key),
    FOREIGN KEY (location_key) REFERENCES location_dim(location_key)	
);
