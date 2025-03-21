create or replace function knn_predict_cube (
  p_map real,
  p_tps real,
  p_force real,
  p_power real,
  p_rpm real,
  p_consumption_l_h real,
  p_consumption_l_100km real,
  p_speed real,
  p_co real,
  p_co2 real,
  k integer default 5
) RETURNS integer as $$
DECLARE
    query_cube cube;
    most_common_fault integer;
BEGIN
    -- Normalize the query point and convert to cube
    WITH norm_query AS (
        SELECT 
            NULLIF(p_map - map_stats.min_val, 0) / NULLIF(map_stats.max_val - map_stats.min_val, 1) AS norm_map,
            NULLIF(p_tps - tps_stats.min_val, 0) / NULLIF(tps_stats.max_val - tps_stats.min_val, 1) AS norm_tps,
            NULLIF(p_force - force_stats.min_val, 0) / NULLIF(force_stats.max_val - force_stats.min_val, 1) AS norm_force,
            NULLIF(p_power - power_stats.min_val, 0) / NULLIF(power_stats.max_val - power_stats.min_val, 1) AS norm_power,
            NULLIF(p_rpm - rpm_stats.min_val, 0) / NULLIF(rpm_stats.max_val - rpm_stats.min_val, 1) AS norm_rpm,
            NULLIF(p_consumption_l_h - cl_h_stats.min_val, 0) / NULLIF(cl_h_stats.max_val - cl_h_stats.min_val, 1) AS norm_consumption_l_h,
            NULLIF(p_consumption_l_100km - cl_100km_stats.min_val, 0) / NULLIF(cl_100km_stats.max_val - cl_100km_stats.min_val, 1) AS norm_consumption_l_100km,
            NULLIF(p_speed - speed_stats.min_val, 0) / NULLIF(speed_stats.max_val - speed_stats.min_val, 1) AS norm_speed,
            NULLIF(p_co - co_stats.min_val, 0) / NULLIF(co_stats.max_val - co_stats.min_val, 1) AS norm_co,
            NULLIF(p_co2 - co2_stats.min_val, 0) / NULLIF(co2_stats.max_val - co2_stats.min_val, 1) AS norm_co2
        FROM feature_stats map_stats
            CROSS JOIN feature_stats tps_stats 
            CROSS JOIN feature_stats force_stats 
            CROSS JOIN feature_stats power_stats 
            CROSS JOIN feature_stats rpm_stats 
            CROSS JOIN feature_stats cl_h_stats 
            CROSS JOIN feature_stats cl_100km_stats 
            CROSS JOIN feature_stats speed_stats 
            CROSS JOIN feature_stats co_stats 
            CROSS JOIN feature_stats co2_stats 
        WHERE map_stats.feature_name = 'map'
            AND tps_stats.feature_name = 'tps'
            AND force_stats.feature_name = 'force'
            AND power_stats.feature_name = 'power'
            AND rpm_stats.feature_name = 'rpm'
            AND cl_h_stats.feature_name = 'consumption_l_h'
            AND cl_100km_stats.feature_name = 'consumption_l_100km'
            AND speed_stats.feature_name = 'speed'
            AND co_stats.feature_name = 'co'
            AND co2_stats.feature_name = 'co2'
    )
    SELECT cube(ARRAY[
        COALESCE(norm_map, 0),
        COALESCE(norm_tps, 0),
        COALESCE(norm_force, 0),
        COALESCE(norm_power, 0),
        COALESCE(norm_rpm, 0),
        COALESCE(norm_consumption_l_h, 0),
        COALESCE(norm_consumption_l_100km, 0),
        COALESCE(norm_speed, 0),
        COALESCE(norm_co, 0),
        COALESCE(norm_co2, 0)
    ]) INTO query_cube
    FROM norm_query;
    
    -- Find k nearest neighbors and return most common fault
    SELECT mode() WITHIN GROUP (ORDER BY fault) INTO most_common_fault
    FROM (
        SELECT fault
        FROM df_normalized
        WHERE fault IS NOT NULL
        ORDER BY feature_vector <-> query_cube  -- Cube distance operator
        LIMIT k
    ) AS nearest;
    
    RETURN most_common_fault;
END;
$$ LANGUAGE plpgsql;


