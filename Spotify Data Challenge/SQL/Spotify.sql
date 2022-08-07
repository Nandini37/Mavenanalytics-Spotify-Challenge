
-- In this projecct we are going to analyze Spotify Top 100 songs in 2018.
-- It is based on Spotify streaming data, including name, artist 
-- and key attributes (danceability, energy, loudness, mode, speechiness, acousticness, etc) 


-- Recommended Analysis
-- 1. Which artists had the most Top 100 songs?
-- 2. Are there more artists in the Top 100 with 'Lil' in their name, or with 'DJ' in their name?
-- 3. Which song attributes are most strongly correlated? What attributes seem to have very little correlation?
-- 4. Which attributes have the most variability? Which tend to be the most similar among the Top 100 songs?




-- drop database spotify_top_100;  -- Drop Datbase if exist

-- Creating Database 
Create database spotify_top_100;

USE spotify_top_100;

-- Create Table
SHOW SESSION VARIABLES LIKE 'lower_case_table_names';
SHOW DATABASES;


SHOW TABLES FROM `spotify_top_100` like 'spotify';

CREATE TABLE `spotify_top_100`.`spotify` (
    `id` TEXT,
    `name` TEXT,
    `artists` TEXT,
    `danceability` DOUBLE,
    `energy` DOUBLE,
    `key` DOUBLE,
    `loudness` DOUBLE,
    `mode` DOUBLE,
    `speechiness` DOUBLE,
    `acousticness` DOUBLE,
    `instrumentalness` DOUBLE,
    `liveness` DOUBLE,
    `valence` DOUBLE,
    `tempo` DOUBLE,
    `duration_ms` DOUBLE,
    `time_signature` DOUBLE
);

Select * From spotify;



SHOW COLUMNS FROM `spotify_top_100`.`spotify`;
-- TRUNCATE TABLE `spotify_top_100`.`spotify`;
-- PREPARE stmt FROM 'INSERT INTO `spotify_top_100`.`spotify` (`id`,`name`,`artists`,`danceability`,`energy`,`key`,`loudness`,`mode`,`speechiness`,`acousticness`,`instrumentalness`,`liveness`,`valence`,`tempo`,`duration_ms`,`time_signature`) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)';
-- DEALLOCATE PREPARE stmt;
Select * From spotify;

describe spotify;



-- Data Analysis
-- 1. Which artists had the most Top 100 songs?

SELECT 
    artists, COUNT(id)
FROM
    spotify
GROUP BY artists
ORDER BY COUNT(id) DESC
LIMIT 5;

-- THUS, XXXTENTACION HAS 6 SONGS IN TOP 100 IN 2018

-- 2. Are there more artists in the Top 100 with 'Lil' in their name, or with 'DJ' in their name?

SELECT artists 
FROM spotify
where artists like '%Lil%' OR artists like "%DJ%" 
GROUP BY artists;

-- There are total 5 artist with 'Lil' in their name, or with 'DJ' in their name

-- 3. Which song attributes are most strongly correlated? What attributes seem to have very little correlation?


-- Danceability and energy
SELECT                                       -- Step 4
  N, Slope, avgY - slope*avgX AS Intercept,
  Correlation, CoeffOfReg
FROM (
  SELECT                                     -- Step 3
    N, avgX, avgY, slope, intercept, Correlation,
    FORMAT( 1 - SUM((energy - intercept - slope*danceability)*(energy- intercept - slope*danceability))/
            ((N-1)*varY), 5 ) AS CoeffOfReg
  FROM spotify AS s2
  JOIN (
    SELECT                                   -- Step 2
      N, avgX, avgY, varY, slope,
      Correlation, avgY - slope*avgX AS intercept
    FROM (
      SELECT
        N, avgX, avgY, varY,
        FORMAT(( N*sumXY - sumX*sumY ) /
               ( N*sumsqX - sumX*sumX ), 5 )           AS slope,
        FORMAT(( sumXY - n*avgX*avgY ) /
               ( (N-1) * SQRT(varX) * SQRT(varY)), 5 ) AS Correlation
      FROM (
        SELECT                               -- Step 1 Calculate the required basic statistics.
          COUNT(id)    AS N,
          AVG(danceability)      AS avgX,
          SUM(danceability)      AS sumX,
          SUM(danceability*danceability)    AS sumsqX,
          VAR_SAMP(danceability) AS varX,
          AVG(energy)      AS avgY,
          SUM(energy)      AS sumY,
          SUM(energy*energy)    AS sumsqY,
          VAR_SAMP(energy) AS varY,
          SUM(danceability*energy)    AS sumXY
FROM spotify
      ) AS sums 
    )AS calc
  ) stats
) combined;

-- No corelation


-- Dance ability and liveness

SELECT                                       -- Step 4
  N, Slope, avgY - slope*avgX AS Intercept,
  Correlation, CoeffOfReg
FROM (
  SELECT                                     -- Step 3
    N, avgX, avgY, slope, intercept, Correlation,
    FORMAT( 1 - SUM((liveness - intercept - slope*danceability)*(liveness- intercept - slope*danceability))/
            ((N-1)*varY), 5 ) AS CoeffOfReg
  FROM spotify AS s2
  JOIN (
    SELECT                                   -- Step 2
      N, avgX, avgY, varY, slope,
      Correlation, avgY - slope*avgX AS intercept
    FROM (
      SELECT
        N, avgX, avgY, varY,
        FORMAT(( N*sumXY - sumX*sumY ) /
               ( N*sumsqX - sumX*sumX ), 5 )           AS slope,
        FORMAT(( sumXY - n*avgX*avgY ) /
               ( (N-1) * SQRT(varX) * SQRT(varY)), 5 ) AS Correlation
      FROM (
        SELECT                               -- Step 1 Calculate the required basic statistics.
          COUNT(id)    AS N,
          AVG(danceability)      AS avgX,
          SUM(danceability)      AS sumX,
          SUM(danceability*danceability)    AS sumsqX,
          VAR_SAMP(danceability) AS varX,
          AVG(liveness)      AS avgY,
          SUM(liveness)      AS sumY,
          SUM(liveness*liveness)    AS sumsqY,
          VAR_SAMP(liveness) AS varY,
          SUM(danceability*liveness)    AS sumXY
FROM spotify
      ) AS sums 
    )AS calc
  ) stats
) combined;

-- No corelation


-- Danceability vs Liveness
select @firstValue:=avg(danceability) ,
   @secondValue:=avg(liveness),
 @division:=(stddev_samp(danceability) * stddev_samp(liveness)) from spotify;
 
 select sum( ( danceability - @firstValue ) * (liveness - @secondValue) ) / ((count(danceability) -1) *
@division) as correlation from spotify;

-- No corelation


-- Danceability vs Energy
select @firstValue:=avg(danceability) ,
   @secondValue:=avg(speechiness),
 @division:=(stddev_samp(danceability) * stddev_samp(speechiness)) from spotify;
 
 select sum( ( danceability - @firstValue ) * (liveness - @secondValue) ) / ((count(danceability) -1) *@division) as correlation from spotify;

-- No corelation

-- Loudness vs Energy
select @firstValue:=avg(loudness) ,
   @secondValue:=avg(energy),
 @division:=(stddev_samp(loudness) * stddev_samp(energy)) from spotify;
 
 select sum( ( loudness - @firstValue ) * (energy - @secondValue) ) / ((count(id) -1) *
@division) as correlation from spotify;


-- Positive Corelation

-- acousticness vs Energy
select @firstValue:=avg(acousticness) ,
   @secondValue:=avg(energy),
 @division:=(stddev_samp(acousticness) * stddev_samp(energy)) from spotify;
 
 select sum( ( acousticness - @firstValue ) * (energy - @secondValue) ) / ((count(id) -1) *
@division) as correlation from spotify;

-- weak negative correlation exist


-- 4. Which attributes have the most variability? Which tend to be the most similar among the Top 100 songs?

-- Interpretation: The greater the variance, the greater the spread in the data.


SELECT variance(energy),
variance(danceability), variance(loudness),variance(speechiness),
variance(acousticness), variance(instrumentalness),
variance(liveness), variance(valence), variance(tempo),variance(duration_ms)
from spotify;



