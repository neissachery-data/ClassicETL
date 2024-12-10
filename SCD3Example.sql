SELECT station_key, station_id, station_number, full_station_name, station_type
	FROM public.station_stage limit 5; --Prior to Update Stage Value 


UPDATE station_stage
SET full_station_name = 'Sacramento River @ Martinez'
WHERE station_id = 45942;


SELECT station_key, station_id, station_number, full_station_name, station_type, previous_station_name, effective_date
	FROM public.station_dim  where station_id = 45942;
