SHOW VARIABLES LIKE 'max_allowed_packet';
-- SET GLOBAL max_allowed_packet = 1073741824;
USE mavenfuzzyfactory;
-- SELECT * FROM website_sessions;

-- Analysis Traffic Source
-- GOAL: SEE WHAT UTM CONTENT DRAW MORE ORDERS
SELECT
	utm_content,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE website_session_id BETWEEN 1000 AND 2000 -- ARBITRARY
GROUP BY
	utm_content
ORDER BY sessions DESC;

SELECT
	website_sessions.utm_content,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rt
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.website_session_id BETWEEN 1000 AND 2000 -- ARBITRARY
GROUP BY 1 -- AKA COL 1 OF SELECT QUERY website_sessions.utm_content
ORDER BY 2 DESC; -- COL 2 COUNT(DISTINCT website_sessions.website_session_id), EITHER 2 OR ALIAS SESSIONS IS FINE

-- ASSIGNMENT 1
-- FIND TOP TRAFFIC SOURCE
SELECT
	website_sessions.utm_source,
    website_sessions.utm_campaign,
    website_sessions.http_referer,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions
FROM website_sessions	
WHERE created_at < '2012-04-12'
GROUP BY 1,2,3
ORDER BY 4 DESC; -- gsearch nonbrand campaign refer more sessions, focusing there will optimize resources

-- Gsearch conversion rate (CVR)
   
SELECT
COUNT(DISTINCT website_sessions.website_session_id) as sessions,
COUNT(DISTINCT orders.order_id) as orders,
COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) as CVR
FROM website_sessions
	LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-04-12' 
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand';
    
-- BID optimization
SELECT 
	YEAR(created_at),
    WEEK(created_at),
    MIN(DATE(created_at)),
    COUNT(distinct website_session_id) as sessions
FROM website_sessions 
WHERE website_session_id BETWEEN 100000 AND 115000
GROUP BY 1,2;

-- PIVOT table w COUNT & CASE
SELECT
	primary_product_id,
    COUNT(DISTINCT CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS count_sigle_item_orders,
	COUNT(DISTINCT CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS count_two_item_orders
FROM orders
WHERE order_id BETWEEN 31000 AND 32000
GROUP BY 1;

-- ASSIGNMENT 2
-- bid down gsearch nonbrand on 2012-04-15
-- require gsearch nonbrand trended session vol, by week to see if bid changes cause vol drops
SELECT
	-- YEAR(created_at),
    -- WEEK(created_at),
    MIN(DATE(created_at)) as week_start_date,
	COUNT(DISTINCT website_session_id) as sessions
FROM website_sessions
WHERE created_at < '2012-05-10'
	AND utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
GROUP BY YEAR(created_at), WEEK(created_at);


-- BID OPTMZN FOR PAID TRAFFIC
-- TRAFFIC SOURCE SEGMENT TRENDING
-- PULL CONVERSION RATE FROM SESSION BY ORDER, BY DEVICE TYPE
SELECT
	website_sessions.device_type,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS CVR
FROM website_sessions
	LEFT JOIN orders
    ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-05-11'
	AND utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
GROUP BY website_sessions.device_type;

-- ASSIGNMENT 3: TRENDING W GRANULAR SEGMENT 
SELECT
	MIN(DATE(created_at)) AS week_start_date,
	COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS dtop_sessions,
	COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mob_sessions
FROM website_sessions
WHERE created_at < '2012-06-09'
	AND website_sessions.created_at > '2012-04-15'
	AND utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
GROUP BY YEAR(created_at), WEEK(created_at);


-- WEB PERF
CREATE TEMPORARY TABLE first_pageview
SELECT
	website_session_id,
    MIN(website_pageview_id) AS min_pv_id
FROM website_pageviews
WHERE website_pageview_id < 1000
GROUP BY website_session_id;

SELECT * FROM first_pageview LIMIT 10;

SELECT
	first_pageview.website_session_id,
    website_pageviews.pageview_url AS landing_page, -- "entry page"
    COUNT(DISTINCT first_pageview.website_session_id) AS session_hitting_this_lander
FROM first_pageview
	LEFT JOIN website_pageviews
    ON first_pageview.min_pv_id = website_pageviews.website_pageview_id
GROUP BY
	website_pageviews.pageview_url;
    
-- Assignment 5: Identify top webs
SELECT 
	pageview_url,
    COUNT(DISTINCT website_pageview_id) AS sessions
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY pageview_url
ORDER BY sessions DESC; 

-- ASSIGNMENT 5: IDENTIFY TOP ENTRY PAGES
-- list of top entry pages
-- FIND FIRST PAGEVIEW FOR EACH SESSION
CREATE TEMPORARY TABLE first_pv
SELECT
	website_session_id,
    MIN(website_pageview_id) AS first_pv
FROM website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY website_session_id;	

SELECT * FROM first_pv;

SELECT
	website_pageviews.pageview_url AS landing_page,
    COUNT(DISTINCT first_pv.website_session_id) AS sessions_hitting_this_landing_page
FROM first_pv
LEFT JOIN website_pageviews
	ON first_pv.first_pv = website_pageviews.website_pageview_id
GROUP BY 1
ORDER BY 2 DESC;

SELECT * FROM website_pageviews;

-- ANALYZING BOUNCE RATES & LANDING PAGE TEST
-- business context: see landing page perf for certain time period

-- STEP 1: FIND 1ST FIRST PV FOR RELEVANT SESSION, STORE IN TEMP. TABLE
CREATE TEMPORARY TABLE first_pv2
SELECT
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS first_pv
FROM website_pageviews
	INNER JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
		AND website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY website_pageviews.website_session_id;

-- STEP 2: IDENTIFY LANDING PAGE LP OF EACH SESSION
CREATE TEMPORARY TABLE sessions_LP
SELECT
	first_pv2.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_pv2
	LEFT JOIN website_pageviews
    ON website_pageviews.website_pageview_id = first_pv2.first_pv;


-- SELECT * FROM sessions_LP;

-- STEP 3: COUNT PAGEVIEW FOR EACH SESSION, TO IDENTIFY "BOUNCES"
CREATE TEMPORARY TABLE bounce
SELECT 
	sessions_LP.website_session_id,
    sessions_LP.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM sessions_LP
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = sessions_LP.website_session_id
GROUP BY 1,2
HAVING count_of_pages_viewed = 1; -- limit to only pg 1

-- SELECT * FROM bounce;

-- STEP 4: SUMMARY TOTAL SESSIONS AND BOUNCED SESSIONS, BY LP

SELECT 
	sessions_LP.landing_page,
    COUNT(DISTINCT sessions_LP.website_session_id) AS sessions,
    COUNT(DISTINCT bounce.website_session_id) AS bounce_ss,
    COUNT(DISTINCT bounce.website_session_id) / COUNT(DISTINCT sessions_LP.website_session_id) AS bounce_rate
FROM sessions_LP
LEFT JOIN bounce
ON sessions_LP.website_session_id = bounce.website_session_id
GROUP BY 1;
-- ORDER BY sessions_LP.website_session_id;




-- ASSIGNMENT 6: PULLING MOST-VIEWED WEB PAGES, RANKED BY SESSION VOL
-- Step 1: find first pageview for each session

CREATE TEMPORARY TABLE first_pageviews
SELECT
	website_session_id,
    MIN(website_pageview_id) AS min_pageview_id
FROM website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY website_session_id;
	
-- SELECT * FROM first_pageviews

-- Step 2: find url the customer saw on that first pageview
-- Create landing page, restricted to home only
-- this is redundant in this case, since all is to the homepage

CREATE TEMPORARY TABLE sessions_w_home_landing_page
SELECT
	first_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_pageviews
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_pageviews.min_pageview_id
WHERE website_pageviews.pageview_url = '/home';

SELECT * FROM sessions_w_home_landing_page;

-- STEP 3: create a table to have count_of_pageviews_per_session
-- then limit to just bounced_sessions
CREATE TEMPORARY TABLE bounced_sessions
SELECT
	sessions_w_home_landing_page.website_session_id,
    sessions_w_home_landing_page.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
    
FROM sessions_w_home_landing_page
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = sessions_w_home_landing_page.website_session_id
    
GROUP BY
	sessions_w_home_landing_page.website_session_id,
    sessions_w_home_landing_page.landing_page
    
HAVING count_of_pages_viewed = 1;

-- count
SELECT
	COUNT(DISTINCT sessions_w_home_landing_page.website_session_id) AS sessions,
    COUNT(DISTINCT bounced_sessions.website_session_id) AS bounced_sessions,
	COUNT(DISTINCT bounced_sessions.website_session_id) / COUNT(DISTINCT sessions_w_home_landing_page.website_session_id) AS bounce_rate
FROM sessions_w_home_landing_page
	LEFT JOIN bounced_sessions
    ON sessions_w_home_landing_page.website_session_id = bounced_sessions.website_session_id
ORDER BY
	sessions_w_home_landing_page.website_session_id;
    
-- ASSIGNMENT 7: Since bounce rate in previous assignment is high (~ 60%)
-- New order: Analyzing LP test: manager wants to launch new custom landing page (/lander-1)
-- in a 50/50 test against homepage (/home) for gsearch nonbranch traffic
-- requirements: pull bounce rates for 2 groups, make sure to look at time period where /lander-1 getting traffic

-- STEP 0: find out when new page / lander launched
-- STEP 1: find first website_pageview_id for relevant sessions
-- STEP 2: identify landing page of each session
-- STEP 4: count pageviews for each session, identify bounces
-- STEP 5: summary total sessions and bounced sessions, by LP

USE mavenfuzzyfactory;

SELECT
	MIN(created_at) AS first_created_at,
    MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
WHERE pageview_url = '/lander-1'
	AND created_at IS NOT NULL;
-- to be cont.


-- SESSION 7: ANALYSIS CHANNEL PORT
SELECT
	utm_content,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conversion_rate
    
    FROM website_sessions
		LEFT JOIN orders
        ON orders.website_session_id = website_sessions.website_session_id
	
    WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
    GROUP BY 1
    ORDER BY sessions DESC;
    
-- ASSIGNMENT 7.1:
-- COMPANY LAUNCHES A SECOND PAID SEARCH CHANNEL BSEARCH AROUND 22 AUG
-- REQUIRE PULLING WEEKLY TRENDED SESSION VOL, COMPARE TO GSEARCH NONBRAND

SELECT 
	MIN(DATE(created_at)) AS week_start_date,
	COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS gsearch_sessions,
	COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS bsearch_sessions
    
    FROM website_sessions
    WHERE created_at >= '2012-08-22'
	AND created_at < '2012-11-29'
	AND utm_campaign = 'nonbrand'
    GROUP BY YEAR(created_at), WEEK(created_at);

    -- ORDER BY sessions DESC;

-- SOLUTION: starting
SELECT
	YEARWEEK(created_at) AS yrwk,
    COUNT(DISTINCT website_session_id) AS total_sessions
FROM website_sessions
    WHERE created_at >= '2012-08-22'
	AND created_at < '2012-11-29'
	AND utm_campaign = 'nonbrand'
GROUP BY YEARWEEK(created_at);
-- then slicing total_sessions to gsearch and bsearch
    
-- ASSIGNMENT 7.2: COMPARING CHANNEL CHARACTERISTICS
-- analysis bsearch nonbrand campaign: need % of traffic on mobile, compare to gsearch
-- agg data since August 22nd

SELECT 
	utm_source,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_sessions.website_session_id) AS pct_mobile

FROM website_sessions
WHERE created_at >= '2012-08-22' 
	AND created_at < '2012-11-30'
	AND utm_campaign = 'nonbrand'
GROUP BY utm_source;

-- EX 7.3: CROSS_CHANNEL BID OPTIMIZAN.
-- pull nonbrand conversion rates from session to order for gsearch, bsearch; slice by device type
-- data from 22/8 - 18/9
SELECT
	website_sessions.device_type,
    website_sessions.utm_source,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conversion_rate
    
FROM website_sessions
	LEFT JOIN orders
        ON orders.website_session_id = website_sessions.website_session_id
        
WHERE website_sessions.created_at >= '2012-08-22' 
	AND website_sessions.created_at < '2012-09-18'
	AND website_sessions.utm_campaign = 'nonbrand'
    
GROUP BY 
	website_sessions.device_type, 
    website_sessions.utm_source
ORDER BY device_type; 

-- EX 7.4: ANALYZE CHANNEL PORT TRENDS
-- pull weekly session vol for gsearch, bsearch nonbrand, down by device since 4/11
-- show % bsearch to gsearch for each device

SELECT
	-- YEARWEEK(created_at) AS yrwk,
    MIN(DATE(created_at)) AS week_start_date,
    -- COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_session_id ELSE NULL END), 
    -- COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_session_id ELSE NULL END)
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' AND utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS g_dtop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' AND utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS g_mob_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' AND utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS b_dtop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' AND utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS b_mob_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' AND utm_source = 'bsearch' THEN website_session_id ELSE NULL END) / 
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' AND utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS b_pct_g_dtop,
	COUNT(DISTINCT CASE WHEN device_type = 'mobile' AND utm_source = 'bsearch' THEN website_session_id ELSE NULL END) / 
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' AND utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS b_pct_g_mob
    
FROM website_sessions
WHERE created_at >= '2012-11-04' 
	AND created_at < '2012-12-22'
	AND utm_campaign = 'nonbrand'
GROUP BY YEAR(created_at), WEEK(created_at);






