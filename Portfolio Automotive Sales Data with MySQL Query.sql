CREATE TABLE automotive_co.automotive_order (
  `ordernumber` INT NOT NULL,
  `quantityordered` INT,
  `price_each` DECIMAL(10,2),
  `orderlinenumber` INT,
  `sales` DECIMAL(10,2),
  `orderdate` DATE,
  `status` VARCHAR(50),
  `productline` VARCHAR(50),
  `msrp` INT,
  `productcode` VARCHAR(50),
  `customername` VARCHAR(255),
  `city` VARCHAR(50),
  `country` VARCHAR(50),
  `dealsize` VARCHAR(50)
);



SELECT
    `productline`,
    SUM(`quantityordered`) AS `total_quantity_sold`,
    CONCAT('$',FORMAT (SUM(sales),2)) AS `total_sales_in_usd)`
FROM 
    automotive_co.automotive_order
GROUP BY
    `productline`
ORDER BY 
    `total_quantity_sold` DESC
;

SELECT
    `country`,
    SUM(`quantityordered`) AS `total_quantity_sold`,
    CONCAT('$',FORMAT(SUM(SALES),2)) AS `total_sales_in_usd`
FROM
    automotive_co.automotive_order
GROUP BY
    country
ORDER BY 
    `total_quantity_sold` DESC
;


SELECT
    `city`,
    `productline`,
    COUNT(CASE WHEN `dealsize` = 'Small' THEN 1 END) AS `small_deals`,
    COUNT(CASE WHEN `dealsize` = 'Medium' THEN 1 END) AS `medium_deals`,
    COUNT(CASE WHEN `dealsize` = 'Large' THEN 1 END) AS `large_deals`,
    SUM(`quantityordered`) AS `total_quantity_sold`,
    CONCAT('$', FORMAT(SUM(`sales`), 2)) AS `total_sales_in_usd`
FROM
    `automotive_co`.`automotive_order`
WHERE
    `country` = 'USA'
GROUP BY
    `city`,`productline`
ORDER BY 
    `total_quantity_sold` DESC
LIMIT
    30
;    

SELECT
    WEEK(`orderdate`) AS `wzek`,
    MONTH(`orderdate`) AS `month`,
    YEAR(`orderdate`) AS `year`,
    SUM(`quantityordered`) AS `total_quantity_sold`,
    CONCAT('$', FORMAT(SUM(`sales`), 2)) AS `total_sales_in_usd`
FROM 
    automotive_co.automotive_order
GROUP BY 
    `week`,`month`,`year`
ORDER BY
    `total_sales_in_usd` DESC
LIMIT
    15
;

SELECT
    CONCAT('Q', QUARTER(`orderdate`)) AS 'quarterly_order',
    SUM(`quantityordered`) AS `total_quantity_sold`,
    CONCAT('$', FORMAT(SUM(`sales`), 2)) AS `total_sales_in_usd`
FROM 
    automotive_co.automotive_order
GROUP BY
    `quarterly_order`
ORDER BY
    `total_sales_in_usd` DESC
;

SELECT
    YEAR(`orderdate`) AS `year`,
    MONTH(`orderdate`) AS `month`,
    SUM(`sales`) AS `total_sales`,
    LAG(SUM(`sales`), 12) OVER (ORDER BY YEAR(`orderdate`), MONTH(`orderdate`)) AS `sales_last_year`,
    (SUM(`sales`) - LAG(SUM(`sales`), 12) OVER (ORDER BY YEAR(`orderdate`), MONTH(`orderdate`))) AS `year_over_year_difference`
FROM 
    automotive_co.automotive_order
GROUP BY
    `year`, `month`
ORDER BY
    `year`, `month`
;

SELECT
    SUM((sales - avg_sales) / stddev_sales * ((msrp - price_each) - avg_price_margin) / stddev_price_margin) 
    / (COUNT(*) - 1) AS correlation
FROM automotive_co.automotive_order
CROSS JOIN (
    SELECT
        AVG(sales) AS avg_sales,
        STDDEV(sales) AS stddev_sales,
        AVG(msrp - price_each) AS avg_price_margin,
        STDDEV(msrp - price_each) AS stddev_price_margin
    FROM automotive_co.automotive_order
) AS normalization_stats
WHERE (msrp - price_each) IS NOT NULL
;

WITH yearly_data AS (
    SELECT
        EXTRACT(YEAR FROM orderdate) AS year,
        SUM(sales) AS total_sales,
        AVG(sales) AS avg_sales,
        STDDEV(sales) AS stddev_sales,
        AVG(msrp - price_each) AS avg_price_margin,
        STDDEV(msrp - price_each) AS stddev_price_margin
    FROM automotive_co.automotive_order
    WHERE (msrp - price_each) IS NOT NULL
    GROUP BY year
)

SELECT
    year,
    AVG((sales - avg_sales) / stddev_sales * (msrp - price_each - avg_price_margin) / stddev_price_margin) AS correlation
FROM 
    automotive_co.automotive_order
CROSS JOIN 
    yearly_data
WHERE 
    EXTRACT(YEAR FROM orderdate) = yearly_data.year
GROUP BY 
    year
ORDER BY 
    year;
    

SELECT
    MONTH(`orderdate`) AS `month`,
    AVG(`msrp`) AS `avg_msrp`,
    AVG(`price_each`) AS `avg_price`,
    AVG(`msrp` - `price_each`) AS `avg_msrp_margin`,
    CONCAT('$', FORMAT(SUM(`sales`), 2)) AS `total_sales_in_usd`
FROM
    automotive_co.automotive_order
WHERE
    YEAR(`orderdate`) = '2021'
GROUP BY
    `month`
ORDER BY
    `total_sales_in_usd` DESC
;



