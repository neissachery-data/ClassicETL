--Time Dimension SCD0
INSERT INTO time_dim(
    time_key, sample_date, sample_day, sample_year, sample_month, year_month)
SELECT 
    stage.time_key, stage.sample_date, stage.sample_day, 
    stage.sample_year, stage.sample_month, stage.year_month
FROM public.time_stage AS stage
WHERE NOT EXISTS (
    SELECT 1
    FROM public.time_dim AS dim
    WHERE dim.time_key = stage.time_key
);

-- Sample Dimension SCD1
MERGE INTO sample_dim 
USING sample_stage
	ON sample_dim.sample_key = sample_stage.sample_key
WHEN MATCHED THEN
	UPDATE SET
		sample_code = sample_stage.sample_code,
		sample_depth = sample_stage.sample_depth,
		sample_units = sample_stage.sample_depth_units
WHEN NOT MATCHED THEN 
	INSERT(sample_key, sample_code, sample_depth, sample_units)
	VALUES(sample_stage.sample_key, sample_stage.sample_code, sample_stage.sample_depth, sample_stage.sample_depth_units);

--Method Dimension SCD2
MERGE INTO method_dim
USING method_stage
	ON method_dim.method_key = method_stage.method_key --there's no natural key in this so I merged on dim_key, ideally I wouldn't use surrg_key
WHEN MATCHED AND method_dim.method_active = TRUE 
	AND(method_dim.method_name IS DISTINCT FROM method_stage.mth_name) THEN --using is distinct to account if there is ever a issue when pipeline running
	UPDATE SET
	method_active = FALSE,
	method_enddate = NOW()
WHEN NOT MATCHED THEN --this will also insert the chnges too
	INSERT(method_key, method_name, method_active, method_effdate, method_enddate)
	VALUES(method_stage.method_key,method_stage.mth_name,TRUE,NOW(),NULL);

-- Station Dimension SCD3
MERGE INTO station_dim
USING station_stage
	ON station_dim.station_id = station_stage.station_id --using natural key, better 
WHEN MATCHED AND (station_dim.full_station_name IS DISTINCT FROM station_stage.full_station_name) THEN
	UPDATE SET
	previous_station_name = station_dim.full_station_name,
	full_station_name = station_stage.full_station_name,
	effective_date = NOW()
WHEN NOT MATCHED THEN 
	INSERT(station_key, station_id, station_number, full_station_name, station_type, previous_station_name, effective_date)
	VALUES(station_stage.station_key, station_stage.station_id, station_stage.station_number, station_stage.full_station_name, station_stage.station_type,NULL, NOW());
	
--Water Fact Load --INSERT ONLY CHANGES
INSERT INTO public.water_fact(
    waterfact_key, station_key, sample_key, time_key, location_key, method_key, 
    avg_oxygen_mg_l, avg_conductance_us_cm, avg_turbidity_nfu, 
    avg_temp_c, avg_ph, avg_chlorophyll_ug_l
)
SELECT 
    stage.waterfact_key, stage.station_key, stage.sample_key, stage.time_key, stage.location_key, stage.method_key, 
    stage."avg_{""dissolvedoxygen"",""mg/l""}", 
    stage."avg_{""specificconductance"",""us/cm@25 °c""}", 
    stage."avg_{""turbidity"",""n.t.u.""}", 
    stage."avg_{""watertemperature"",""°c""}", 
    stage."avg_{""ph"",""ph units""}", 
    stage."avg_{""chlorophyll fluorescence"",""ug/l of chl""}"
FROM public.water_fact_stage AS stage
WHERE NOT EXISTS (
    SELECT 1 
    FROM public.water_fact AS fact
    WHERE fact.waterfact_key = stage.waterfact_key
);

TRUNCATE TABLE sample_dim CASCADE
TRUNCATE TABLE station_dim CASCADE
TRUNCATE TABLE method_dim CASCADE
TRUNCATE TABLE time_dim CASCADE


	
		
		
	

	


