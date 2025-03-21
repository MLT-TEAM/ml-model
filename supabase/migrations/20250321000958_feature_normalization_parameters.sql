-- Create a table to store normalization parameters
CREATE TABLE IF NOT EXISTS feature_stats (
    feature_name text PRIMARY KEY,
    min_val real,
    max_val real
);

-- Calculate and store min/max values for each feature
TRUNCATE TABLE feature_stats;

INSERT INTO feature_stats (feature_name, min_val, max_val)
SELECT 'map', MIN(map), MAX(map) FROM public.df WHERE map IS NOT NULL;

INSERT INTO feature_stats (feature_name, min_val, max_val)
SELECT 'tps', MIN(tps), MAX(tps) FROM public.df WHERE tps IS NOT NULL;

INSERT INTO feature_stats (feature_name, min_val, max_val)
SELECT 'force', MIN(force), MAX(force) FROM public.df WHERE force IS NOT NULL;

INSERT INTO feature_stats (feature_name, min_val, max_val)
SELECT 'power', MIN(power), MAX(power) FROM public.df WHERE power IS NOT NULL;

INSERT INTO feature_stats (feature_name, min_val, max_val)
SELECT 'rpm', MIN(rpm), MAX(rpm) FROM public.df WHERE rpm IS NOT NULL;

INSERT INTO feature_stats (feature_name, min_val, max_val)
SELECT 'consumption_l_h', MIN(consumption_l_h), MAX(consumption_l_h) FROM public.df WHERE consumption_l_h IS NOT NULL;

INSERT INTO feature_stats (feature_name, min_val, max_val)
SELECT 'consumption_l_100km', MIN(consumption_l_100km), MAX(consumption_l_100km) FROM public.df WHERE consumption_l_100km IS NOT NULL;

INSERT INTO feature_stats (feature_name, min_val, max_val)
SELECT 'speed', MIN(speed), MAX(speed) FROM public.df WHERE speed IS NOT NULL;

INSERT INTO feature_stats (feature_name, min_val, max_val)
SELECT 'co', MIN(co), MAX(co) FROM public.df WHERE co IS NOT NULL;

INSERT INTO feature_stats (feature_name, min_val, max_val)
SELECT 'co2', MIN(co2), MAX(co2) FROM public.df WHERE co2 IS NOT NULL;
