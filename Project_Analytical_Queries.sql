--Analytical Queries Neissa Chery

/*Business Question 1 What is the average pH in counties whose average income is in the top 5 income in the state and the water tested
was surface water? */

WITH bs1 AS (
    SELECT 
        round(avg(water_fact.avg_ph),2) AS avg_ph, 
        round(avg(caincomefact.median_income),0) AS avg_median,
        location_dim.county AS county,
        rank() OVER (ORDER BY avg(caincomefact.median_income) DESC) AS income_rank
    FROM water_fact
    JOIN caincomefact ON water_fact.location_key = caincomefact.location_key
    JOIN station_dim ON water_fact.station_key = station_dim.station_key
    JOIN location_dim ON location_dim.location_key = water_fact.location_key
    WHERE water_fact.avg_ph > 0 AND station_dim.station_type = 'Surface Water'
    GROUP BY location_dim.county, station_dim.station_type
)
SELECT * FROM bs1 limit 5;

/*Business Question 2 What surface_water stations in the state have the 
lowest cumulative averages across all water quality parameters, does population correllate? */

WITH bs2 AS (
    SELECT
		station_dim.full_station_name as station_name,
        location_dim.county AS county,
        ROUND(AVG(caincomefact.population), 0) AS avg_population,
        ROUND(AVG(water_fact.avg_ph), 2) AS avg_ph,
        ROUND(AVG(water_fact.avg_oxygen_mg_l), 2) AS avg_oxygen,
        ROUND(AVG(water_fact.avg_conductance_us_cm), 2) AS avg_conductance,
        ROUND(AVG(water_fact.avg_turbidity_nfu), 2) AS avg_turbidity,
        ROUND((AVG(water_fact.avg_temp_c) * 9 / 5) + 32, 2) AS avg_temp_fahrenheit,
		DENSE_RANK() OVER (PARTITION BY location_dim.county ORDER BY AVG(water_fact.avg_ph) ASC) AS pop_rank
    FROM water_fact
    JOIN caincomefact ON water_fact.location_key = caincomefact.location_key
    JOIN station_dim ON water_fact.station_key = station_dim.station_key
	JOIN location_dim ON location_dim.location_key = water_fact.location_key
    WHERE station_dim.station_type = 'Surface Water' AND location_dim.county != 'Unallocated'
		AND location_dim.county != 'Nonresident'
    GROUP BY location_dim.county, station_dim.full_station_name
    ORDER BY avg_population DESC
)
SELECT * FROM bs2
LIMIT 100
;




