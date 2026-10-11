
-- Check 5: Invalid review scores

SELECT
    COUNT(*) AS invalid_review_scores
FROM staging.reviews
WHERE review_score IS NULL
   OR review_score NOT BETWEEN 1 AND 5;
