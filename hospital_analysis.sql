USE hospital_analytics;

SELECT
    COUNT(*) AS total_hospitals,

    SUM(
        EXISTS (
            SELECT 1
            FROM hrrp r
            WHERE r.`Facility ID` = h.`Facility ID`
        )
    ) AS hospitals_in_hrrp,

    SUM(
        EXISTS (
            SELECT 1
            FROM hcahps c
            WHERE c.`Facility ID` = h.`Facility ID`
        )
    ) AS hospitals_in_hcahps,

    SUM(
        EXISTS (
            SELECT 1 FROM hrrp r
            WHERE r.`Facility ID` = h.`Facility ID`
        )
        AND
        EXISTS (
            SELECT 1 FROM hcahps c
            WHERE c.`Facility ID` = h.`Facility ID`
        )
    ) AS hospitals_in_all_three

FROM hospital_general h;
-- --- ------------------
WITH hospital_readmission AS (
    SELECT
        `Facility ID`,
        AVG(`Excess Readmission Ratio`) AS avg_readmission_ratio
    FROM hrrp
    WHERE `Excess Readmission Ratio` IS NOT NULL
    GROUP BY `Facility ID`
),

rating_summary AS (
    SELECT
        h.`Hospital overall rating`,
        COUNT(*) AS total_hospitals,
        AVG(r.avg_readmission_ratio) AS avg_ratio

    FROM hospital_general h

    INNER JOIN hospital_readmission r
        ON h.`Facility ID` = r.`Facility ID`

    WHERE h.`Hospital overall rating`
        IN ('1', '2', '3', '4', '5')

    GROUP BY h.`Hospital overall rating`
)

SELECT
    `Hospital overall rating`,
    total_hospitals,

    ROUND(
        total_hospitals * 100.0 / SUM(total_hospitals) OVER (),
        2
    ) AS hospital_percentage,

    ROUND(avg_ratio, 3) AS avg_excess_readmission_ratio

FROM rating_summary

ORDER BY CAST(`Hospital overall rating` AS UNSIGNED);
/* HOSPITAL OWNERSHIP VS READMISSION PERFORMANCE */
WITH hospital_readmission AS (
    SELECT
        `Facility ID`,
        AVG(`Excess Readmission Ratio`) AS avg_readmission_ratio
    FROM hrrp
    WHERE `Excess Readmission Ratio` IS NOT NULL
    GROUP BY `Facility ID`
),

ownership_summary AS (
    SELECT
        h.`Hospital Ownership`,
        COUNT(*) AS total_hospitals,
        AVG(r.avg_readmission_ratio) AS avg_ratio

    FROM hospital_general h

    INNER JOIN hospital_readmission r
        ON h.`Facility ID` = r.`Facility ID`

    WHERE h.`Hospital Ownership` IS NOT NULL

    GROUP BY h.`Hospital Ownership`
)

SELECT
    `Hospital Ownership`,
    total_hospitals,

    ROUND(
        total_hospitals * 100.0 /
        SUM(total_hospitals) OVER (), 2
    ) AS hospital_percentage,

    ROUND(avg_ratio, 3) AS avg_excess_readmission_ratio

FROM ownership_summary
ORDER BY avg_ratio;
/* Readmission performance by medical condition */
SELECT
    `Measure Name`,
    COUNT(DISTINCT `Facility ID`) AS total_hospitals,

    ROUND(
        COUNT(DISTINCT `Facility ID`) * 100.0 /
        (SELECT COUNT(DISTINCT `Facility ID`) FROM hrrp),
        2
    ) AS hospital_percentage,

    ROUND(
        AVG(`Excess Readmission Ratio`), 3
    ) AS avg_excess_readmission_ratio

FROM hrrp

WHERE `Excess Readmission Ratio` IS NOT NULL

GROUP BY `Measure Name`

ORDER BY avg_excess_readmission_ratio DESC;
-- strongest vs weakest patient ratings--
SELECT
    `HCAHPS Measure ID`,
    `HCAHPS Question`,
    `HCAHPS Answer Description`,
    COUNT(DISTINCT `Facility ID`) AS total_hospitals,
    ROUND(AVG(`HCAHPS Answer Percent`), 2) AS avg_answer_percent,
    ROUND(AVG(`Patient Survey Star Rating`), 2) AS avg_star_rating
FROM hcahps
WHERE `HCAHPS Answer Percent` IS NOT NULL
   OR `Patient Survey Star Rating` IS NOT NULL
GROUP BY
    `HCAHPS Measure ID`,
    `HCAHPS Question`,
    `HCAHPS Answer Description`
ORDER BY `HCAHPS Measure ID`;
/* response categories with percentage */
SELECT
    `HCAHPS Measure ID`,
    `HCAHPS Question`,
    `HCAHPS Answer Description`,
    ROUND(AVG(`HCAHPS Answer Percent`), 2)
        AS avg_answer_percent,
    COUNT(DISTINCT `Facility ID`) AS total_hospitals
FROM hcahps
WHERE `HCAHPS Answer Percent` IS NOT NULL
GROUP BY
    `HCAHPS Measure ID`,
    `HCAHPS Question`,
    `HCAHPS Answer Description`
ORDER BY
    `HCAHPS Measure ID`,
    avg_answer_percent DESC;
 /* Hospital Quality with patient experience */
 WITH patient_experience AS (
    SELECT
        `Facility ID`,
        ROUND(AVG(`Patient Survey Star Rating`), 2)
            AS avg_patient_star_rating
    FROM hcahps
    WHERE `Patient Survey Star Rating` IS NOT NULL
    GROUP BY `Facility ID`
)

SELECT
    h.`Facility ID`,
    h.`Facility Name`,
    h.`State`,
    h.`Hospital overall rating`,
    p.avg_patient_star_rating
FROM hospital_general h
LEFT JOIN patient_experience p
    ON h.`Facility ID` = p.`Facility ID`
WHERE h.`Hospital overall rating`
    NOT IN ('Not Available', 'Not Applicable')
ORDER BY
    CAST(h.`Hospital overall rating` AS UNSIGNED) DESC,
    p.avg_patient_star_rating DESC;
 /* hospitals with weaker overall quality */
 WITH patient_experience AS (
    SELECT
        `Facility ID`,
        ROUND(AVG(`Patient Survey Star Rating`), 2)
            AS avg_patient_star_rating
    FROM hcahps
    WHERE `Patient Survey Star Rating` IS NOT NULL
    GROUP BY `Facility ID`
),

readmission AS (
    SELECT
        `Facility ID`,
        ROUND(AVG(`Excess Readmission Ratio`), 3)
            AS avg_excess_readmission_ratio,
        COUNT(`Excess Readmission Ratio`)
            AS conditions_reported
    FROM hrrp
    WHERE `Excess Readmission Ratio` IS NOT NULL
    GROUP BY `Facility ID`
)

SELECT
    h.`Facility ID`,
    h.`Facility Name`,
    h.`State`,
    h.`Hospital overall rating`,
    p.avg_patient_star_rating,
    r.avg_excess_readmission_ratio,
    r.conditions_reported

FROM hospital_general h

INNER JOIN patient_experience p
    ON h.`Facility ID` = p.`Facility ID`

INNER JOIN readmission r
    ON h.`Facility ID` = r.`Facility ID`

WHERE h.`Hospital overall rating`
    NOT IN ('Not Available', 'Not Applicable')

ORDER BY
    CAST(h.`Hospital overall rating` AS UNSIGNED) ASC,
    r.avg_excess_readmission_ratio DESC,
    p.avg_patient_star_rating ASC;
/* readmission performance by medical condition */
SELECT
    `Measure Name`,
    COUNT(DISTINCT `Facility ID`) AS total_hospitals,
    ROUND(AVG(`Excess Readmission Ratio`), 3)
        AS avg_excess_readmission_ratio,
    ROUND(AVG(`Predicted Readmission Rate`), 2)
        AS avg_predicted_rate,
    ROUND(AVG(`Expected Readmission Rate`), 2)
        AS avg_expected_rate
        

FROM hrrp

WHERE `Excess Readmission Ratio` IS NOT NULL

GROUP BY `Measure Name`

ORDER BY avg_excess_readmission_ratio DESC;    
    
/* state wise hospital quality and excessive readmission ratio*/
WITH hospital_readmission AS (
    SELECT
        `Facility ID`,
        AVG(`Excess Readmission Ratio`)
            AS avg_excess_readmission_ratio
    FROM hrrp
    WHERE `Excess Readmission Ratio` IS NOT NULL
    GROUP BY `Facility ID`
)

SELECT
    h.`State`,
    COUNT(DISTINCT h.`Facility ID`) AS total_hospitals,

    ROUND(
        AVG(CAST(h.`Hospital overall rating` AS UNSIGNED)), 2
    ) AS avg_hospital_rating,

    ROUND(
        AVG(r.avg_excess_readmission_ratio), 3
    ) AS avg_excess_readmission_ratio

FROM hospital_general h

INNER JOIN hospital_readmission r
    ON h.`Facility ID` = r.`Facility ID`

WHERE h.`Hospital overall rating`
    NOT IN ('Not Available', 'Not Applicable')

GROUP BY h.`State`

ORDER BY avg_excess_readmission_ratio DESC;    
/* CMS quality ratings vs patient experience */
WITH patient_experience AS (
    SELECT
        `Facility ID`,
        ROUND(AVG(`Patient Survey Star Rating`), 2)
            AS avg_patient_star_rating
    FROM hcahps
    WHERE `Patient Survey Star Rating` IS NOT NULL
    GROUP BY `Facility ID`
)

SELECT
    h.`Facility ID`,
    h.`Facility Name`,
    h.`State`,
    CAST(h.`Hospital overall rating` AS UNSIGNED)
        AS cms_overall_rating,
    p.avg_patient_star_rating,

    ROUND(
        ABS(
            CAST(h.`Hospital overall rating` AS UNSIGNED)
            - p.avg_patient_star_rating
        ), 2
    ) AS rating_gap,

    CASE
        WHEN CAST(h.`Hospital overall rating` AS UNSIGNED)
             > p.avg_patient_star_rating
            THEN 'CMS rating higher'
        WHEN CAST(h.`Hospital overall rating` AS UNSIGNED)
             < p.avg_patient_star_rating
            THEN 'Patient rating higher'
        ELSE 'Ratings match'
    END AS gap_direction

FROM hospital_general h
INNER JOIN patient_experience p
    ON h.`Facility ID` = p.`Facility ID`

WHERE h.`Hospital overall rating`
    NOT IN ('Not Available', 'Not Applicable')

ORDER BY rating_gap DESC
LIMIT 20;
/* Emergency services vs Hospital Performance */
WITH hospital_readmission AS (
    SELECT
        `Facility ID`,
        AVG(`Excess Readmission Ratio`)
            AS avg_excess_readmission_ratio
    FROM hrrp
    WHERE `Excess Readmission Ratio` IS NOT NULL
    GROUP BY `Facility ID`
)


SELECT
    h.`Emergency Services`,
    COUNT(*) AS total_hospitals,

    ROUND(
        AVG(CAST(h.`Hospital overall rating` AS UNSIGNED)), 2
    ) AS avg_hospital_rating,

    ROUND(
        AVG(r.avg_excess_readmission_ratio), 3
    ) AS avg_excess_readmission_ratio

FROM hospital_general h

LEFT JOIN hospital_readmission r
    ON h.`Facility ID` = r.`Facility ID`

WHERE h.`Hospital overall rating`
    NOT IN ('Not Available', 'Not Applicable')

GROUP BY h.`Emergency Services`
ORDER BY avg_hospital_rating DESC;
/* patient survey response vs hospital performance */
WITH hospital_patient_metrics AS (
    SELECT
        `Facility ID`,
        MAX(`Survey Response Rate Percent`)
            AS survey_response_rate,
        AVG(`Patient Survey Star Rating`)
            AS avg_patient_star_rating
    FROM hcahps
    WHERE `Survey Response Rate Percent` IS NOT NULL
    GROUP BY `Facility ID`
),

hospital_metrics AS (
    SELECT
        h.`Facility ID`,
        CAST(h.`Hospital overall rating` AS UNSIGNED)
            AS cms_rating,
        p.survey_response_rate,
        p.avg_patient_star_rating
    FROM hospital_general h
    INNER JOIN hospital_patient_metrics p
        ON h.`Facility ID` = p.`Facility ID`
    WHERE h.`Hospital overall rating`
        NOT IN ('Not Available', 'Not Applicable')
),

response_groups AS (
    SELECT
        *,
        NTILE(4) OVER (
            ORDER BY survey_response_rate
        ) AS response_quartile
    FROM hospital_metrics
)

SELECT
    response_quartile,
    COUNT(*) AS total_hospitals,
    ROUND(AVG(survey_response_rate), 2)
        AS avg_response_rate,
    ROUND(AVG(avg_patient_star_rating), 2)
        AS avg_patient_star_rating,
    ROUND(AVG(cms_rating), 2)
        AS avg_cms_rating

FROM response_groups
GROUP BY response_quartile
ORDER BY response_quartile;
/* patient satisfaction vs readmission performance */


WITH patient_experience AS (
    SELECT
        `Facility ID`,
        ROUND(AVG(`Patient Survey Star Rating`), 2)
            AS avg_patient_star_rating
    FROM hcahps
    WHERE `Patient Survey Star Rating` IS NOT NULL
    GROUP BY `Facility ID`
),

hospital_readmission AS (
    SELECT
        `Facility ID`,
        ROUND(AVG(`Excess Readmission Ratio`), 3)
            AS avg_excess_readmission_ratio,
        COUNT(`Excess Readmission Ratio`)
            AS conditions_reported
    FROM hrrp
    WHERE `Excess Readmission Ratio` IS NOT NULL
    GROUP BY `Facility ID`
)

SELECT
    h.`Facility ID`,
    h.`Facility Name`,
    h.`State`,
    p.avg_patient_star_rating,
    r.avg_excess_readmission_ratio,
    r.conditions_reported,

    CASE
        WHEN p.avg_patient_star_rating >= 4
             AND r.avg_excess_readmission_ratio < 1
            THEN 'Strong in both'

        WHEN p.avg_patient_star_rating >= 4
             AND r.avg_excess_readmission_ratio >= 1
            THEN 'High satisfaction, weaker readmission'

        WHEN p.avg_patient_star_rating < 4
             AND r.avg_excess_readmission_ratio < 1
            THEN 'Lower satisfaction, better readmission'

        ELSE 'Needs improvement in both'
    END AS performance_category

FROM hospital_general h

INNER JOIN patient_experience p
    ON h.`Facility ID` = p.`Facility ID`

INNER JOIN hospital_readmission r
    ON h.`Facility ID` = r.`Facility ID`

ORDER BY
    p.avg_patient_star_rating DESC,
    r.avg_excess_readmission_ratio ASC;
 /* high - performing hospitals */
 /* Q13: Identify consistently high-performing hospitals */
WITH patient_experience AS (
    SELECT
        `Facility ID`,
        AVG(`Patient Survey Star Rating`) AS patient_rating
    FROM hcahps
    WHERE `Patient Survey Star Rating` IS NOT NULL
    GROUP BY `Facility ID`
),

hospital_readmission AS (
    SELECT
        `Facility ID`,
        AVG(`Excess Readmission Ratio`) AS readmission_ratio,
        COUNT(DISTINCT `Measure Name`) AS conditions_reported
    FROM hrrp
    WHERE `Excess Readmission Ratio` IS NOT NULL
    GROUP BY `Facility ID`
)

SELECT
    h.`Facility ID`,
    h.`Facility Name`,
    h.`State`,
    h.`Hospital overall rating` AS cms_rating,
    p.patient_rating,
    r.readmission_ratio,
    r.conditions_reported
FROM hospital_general h
INNER JOIN patient_experience p
    ON h.`Facility ID` = p.`Facility ID`
INNER JOIN hospital_readmission r
    ON h.`Facility ID` = r.`Facility ID`
WHERE
    CAST(h.`Hospital overall rating` AS UNSIGNED) >= 4
    AND p.patient_rating >= 3.5
    AND r.readmission_ratio < 1
    AND r.conditions_reported >= 4
ORDER BY
    r.readmission_ratio ASC,
    p.patient_rating DESC;