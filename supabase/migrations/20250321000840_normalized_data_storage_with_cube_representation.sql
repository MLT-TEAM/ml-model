-- Create a table for storing normalized data with cube representation
create table if not exists df_normalized as
with
  normalized_data as (
    select
      id,
      fault,
      NULLIF(map - map_stats.min_val, 0) / NULLIF(map_stats.max_val - map_stats.min_val, 1) as norm_map,
      NULLIF(tps - tps_stats.min_val, 0) / NULLIF(tps_stats.max_val - tps_stats.min_val, 1) as norm_tps,
      NULLIF(force - force_stats.min_val, 0) / NULLIF(force_stats.max_val - force_stats.min_val, 1) as norm_force,
      NULLIF(power - power_stats.min_val, 0) / NULLIF(power_stats.max_val - power_stats.min_val, 1) as norm_power,
      NULLIF(rpm - rpm_stats.min_val, 0) / NULLIF(rpm_stats.max_val - rpm_stats.min_val, 1) as norm_rpm,
      NULLIF(consumption_l_h - cl_h_stats.min_val, 0) / NULLIF(cl_h_stats.max_val - cl_h_stats.min_val, 1) as norm_consumption_l_h,
      NULLIF(consumption_l_100km - cl_100km_stats.min_val, 0) / NULLIF(
        cl_100km_stats.max_val - cl_100km_stats.min_val,
        1
      ) as norm_consumption_l_100km,
      NULLIF(speed - speed_stats.min_val, 0) / NULLIF(speed_stats.max_val - speed_stats.min_val, 1) as norm_speed,
      NULLIF(co - co_stats.min_val, 0) / NULLIF(co_stats.max_val - co_stats.min_val, 1) as norm_co,
      NULLIF(co2 - co2_stats.min_val, 0) / NULLIF(co2_stats.max_val - co2_stats.min_val, 1) as norm_co2
    from
      public.df
      cross join feature_stats map_stats
      cross join feature_stats tps_stats
      cross join feature_stats force_stats
      cross join feature_stats power_stats
      cross join feature_stats rpm_stats
      cross join feature_stats cl_h_stats
      cross join feature_stats cl_100km_stats
      cross join feature_stats speed_stats
      cross join feature_stats co_stats
      cross join feature_stats co2_stats
    where
      map_stats.feature_name = 'map'
      and tps_stats.feature_name = 'tps'
      and force_stats.feature_name = 'force'
      and power_stats.feature_name = 'power'
      and rpm_stats.feature_name = 'rpm'
      and cl_h_stats.feature_name = 'consumption_l_h'
      and cl_100km_stats.feature_name = 'consumption_l_100km'
      and speed_stats.feature_name = 'speed'
      and co_stats.feature_name = 'co'
      and co2_stats.feature_name = 'co2'
  )
select
  id,
  fault,
  cube (
    array[
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
    ]
  ) as feature_vector
from
  normalized_data;


CREATE INDEX idx_df_normalized_fault_partial ON df_normalized(fault);

create index IF not exists idx_df_normalized_id on df_normalized (id);

create index IF not exists idx_df_normalized_feature_vector on df_normalized using gist (feature_vector);