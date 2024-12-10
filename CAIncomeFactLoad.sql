--Loading to DWH
INSERT INTO public.caincomefact(
	income_key, original_id, year_key, medianrank_key, location_key, population, all_returns, median_income)
	 	SELECT incomefact_key,_id,taxableyear_key,medianrank_key,location_key,"Population","All Returns","Median Income"
		 FROM public.incomefact_stage;


MERGE INTO location_dim as loc_dim --SCD 1 MAINTENANCE
USING location_stage as loc_stage
	ON (loc_dim.location_key = loc_stage.location_key)
WHEN MATCHED THEN 
	UPDATE SET
		county = loc_stage."County",
		state = loc_stage."State",
		country = loc_stage."Country"
WHEN NOT MATCHED THEN 
	INSERT (location_key, county, state, country)
	VALUES (loc_stage.location_key,loc_stage."County",loc_stage."State",loc_stage."Country");

INSERT INTO tax_year_dim(year_key, tax_year) -- SCD 0 TIME DIMENSION MAINTENACE
	SELECT taxableyear_key, "Taxable Year"
	FROM public.tax_stage;


MERGE INTO rank_dim --SCD 1 MAINTENANCE
USING rank_stage 
	ON (rank_dim.medianrank_key = rank_stage.medianrank_key)
WHEN MATCHED THEN 
	UPDATE SET 
		medianrank = rank_stage."Median Rank"
WHEN NOT MATCHED THEN
	INSERT (medianrank_key,medianrank)
	VALUES(rank_stage.medianrank_key,rank_stage."Median Rank");
		