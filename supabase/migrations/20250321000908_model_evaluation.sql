-- Create a table to store predictions

CREATE OR REPLACE FUNCTION run_knn_evaluation(sample_size integer DEFAULT 100, k_neighbors integer DEFAULT 5)
RETURNS TABLE(total_predictions bigint, correct_predictions bigint, accuracy_percentage numeric) AS $$
BEGIN
    -- Clear previous predictions
    TRUNCATE TABLE knn_predictions;
    
    -- Make predictions on random rows
    INSERT INTO knn_predictions (id, actual_fault, predicted_fault)
    SELECT 
        id, 
        fault AS actual_fault,
        knn_predict_cube(
            map, tps, force, power, rpm,
            consumption_l_h, consumption_l_100km, speed,
            co, co2,
            k_neighbors
        ) AS predicted_fault
    FROM (
        SELECT * FROM public.df 
        WHERE fault IS NOT NULL
        ORDER BY RANDOM() 
        LIMIT sample_size
    ) AS random_sample;
    
    -- Return evaluation metrics
    RETURN QUERY
    SELECT 
        COUNT(*) AS total_predictions,
        SUM(CASE WHEN actual_fault = predicted_fault THEN 1 ELSE 0 END) AS correct_predictions,
        100.0 * SUM(CASE WHEN actual_fault = predicted_fault THEN 1 ELSE 0 END) / COUNT(*) AS accuracy_percentage
    FROM knn_predictions;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM run_knn_evaluation(100, 5);
