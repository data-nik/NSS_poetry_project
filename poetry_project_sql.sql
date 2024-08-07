
-- 1a.  
-- How many poets from each grade are represented in the data?  

SELECT grade_id,
		COUNT(CASE WHEN grade_id = 1 THEN 'first_grade'
					WHEN grade_id = 2 THEN 'second_grade'
					WHEN grade_id = 3 THEN 'third_grade'
					WHEN grade_id = 4 THEN 'fourth_grade'
					ELSE 'fifth_grade' END) AS poet_count
FROM author
GROUP BY grade_id
ORDER BY grade_id ASC;




-- 1b.
-- How many of the poets in each grade are Male and how many are Female? Only return the poets identified as Male or Female.  

SELECT grade_id AS grade,
    COUNT(CASE WHEN gender_id = 1 THEN 0 END) AS female_count,
    COUNT(CASE WHEN gender_id = 2 THEN 0 END) AS male_count
FROM author
WHERE gender_id IN (1, 2)
GROUP BY grade_id
ORDER BY grade_id ASC;




-- 2a. 
-- Return the **total number** of poems that mention **pizza** and **total number** that mention the word **hamburger** in the TEXT or TITLE, 
-- also return the **average character count** for poems that mention **pizza** and also for poems that mention the word **hamburger** in the TEXT or TITLE. 
-- Do this in a single query, (i.e. your output should contain all the information).

WITH poem_counts AS (SELECT
        				CASE WHEN title ILIKE '%pizza%' OR text ILIKE '%pizza%' THEN LENGTH(text) ELSE NULL END AS pizza_char_count,
        				CASE WHEN title ILIKE '%hamburger%' OR text ILIKE '%hamburger%' THEN LENGTH(text) ELSE NULL END AS hamburger_char_count
    				FROM poem)
	
SELECT
    COUNT(pizza_char_count) AS pizza_count,
    COUNT(hamburger_char_count) AS hamburger_count,
    ROUND(AVG(pizza_char_count),2) AS avg_pizza_char_count,
    ROUND(AVG(hamburger_char_count),2) AS avg_hamburger_char_count
FROM
    poem_counts;




-- 3a.
-- Do longer poems have more emotional intensity compared to shorter poems?  
-- Start by writing a query to return each emotion in the database with its average intensity and average character count.   
-- Which emotion is associated the longest poems on average?  
-- Which emotion has the shortest?  


SELECT 	emotion_id,
		ROUND(AVG(intensity_percent),2) AS avg_intensity,
		ROUND(AVG(char_count),2) AS avg_char
FROM poem
INNER JOIN poem_emotion ON poem_emotion.poem_id = poem.id
GROUP BY emotion_id
ORDER BY emotion_id ASC


	
-- 1 anger
-- 2 fear
-- 3 sadness
-- 4 joy

-- 3b.
-- Convert the query you wrote in part a into a CTE. 
-- Then find the 5 most intense poems that express anger and whether they are to be longer or shorter than the average angry poem.   
-- What is the most angry poem about?  
-- Do you think these are all classified correctly?

WITH emotion_avg_stats AS (SELECT emotion_id,
        							ROUND(AVG(intensity_percent), 2) AS avg_intensity,
        							ROUND(AVG(char_count), 2) AS avg_char
    						FROM poem
    						INNER JOIN poem_emotion ON poem_emotion.poem_id = poem.id
    						GROUP BY emotion_id)

SELECT title,
    	CASE WHEN poem.char_count > anger_avg.avg_char THEN 'Longer'
			 WHEN poem.char_count < anger_avg.avg_char THEN 'Shorter'
        	 ELSE 'Same'
    	END AS length_comparison
FROM poem
INNER JOIN poem_emotion ON poem_emotion.poem_id = poem.id
INNER JOIN emotion_avg_stats AS anger_avg ON poem_emotion.emotion_id = anger_avg.emotion_id
WHERE poem_emotion.emotion_id = 1
ORDER BY intensity_percent DESC
LIMIT 5;




-- 4a.
-- Compare the 5 most joyful poems by 1st graders to the 5 most joyful poems by 5th graders.  
-- Which group writes the most joyful poems according to the intensity score?  

-- First Graders --	
SELECT poem_id, intensity_percent, name, gender_id, emotion_id, grade_id
FROM poem
INNER JOIN poem_emotion ON poem_emotion.poem_id = poem.id
INNER JOIN author ON poem.author_id = author.id
WHERE grade_id = 1 AND emotion_id = 4
ORDER BY intensity_percent DESC
LIMIT 5;

-- Fifth Graders --
SELECT poem_id, intensity_percent, name, gender_id, emotion_id, grade_id
FROM poem
INNER JOIN poem_emotion ON poem_emotion.poem_id = poem.id
INNER JOIN author ON poem.author_id = author.id
WHERE grade_id = 5 AND emotion_id = 4
ORDER BY intensity_percent DESC
LIMIT 5;




-- 4b.
-- How many times do males show up in the top 5 poems for each grade?  Females?

WITH top_poems AS (

(SELECT poem_id, intensity_percent, name, gender_id, emotion_id, grade_id
FROM poem
INNER JOIN poem_emotion ON poem_emotion.poem_id = poem.id
INNER JOIN author ON poem.author_id = author.id
WHERE grade_id = 1 AND emotion_id = 4
ORDER BY intensity_percent DESC
LIMIT 5)
UNION
(SELECT poem_id, intensity_percent, name, gender_id, emotion_id, grade_id
FROM poem
INNER JOIN poem_emotion ON poem_emotion.poem_id = poem.id
INNER JOIN author ON poem.author_id = author.id
WHERE grade_id = 5 AND emotion_id = 4
ORDER BY intensity_percent DESC
LIMIT 5)
					)

SELECT grade_id,
    COUNT(CASE WHEN gender_id = 1 THEN 'female' END) AS female_count,
    COUNT(CASE WHEN gender_id = 2 THEN 'male' END) AS male_count
FROM top_poems
GROUP BY grade_id
ORDER BY grade_id ASC; 




-- 5a. Robert Frost was a famous American poet. There is 1 poet named `robert` per grade.
-- Examine the 5 poets in the database with the name `robert`. 
-- Create a report showing the distribution of emotions that characterize their work by grade.  
	
SELECT g.name AS grade_name,
       e.name AS emotion_name,
       COUNT(*) AS emotion_count
FROM poem p
INNER JOIN poem_emotion pe ON p.id = pe.poem_id
INNER JOIN emotion e ON pe.emotion_id = e.id
INNER JOIN author a ON p.author_id = a.id
INNER JOIN grade g ON a.grade_id = g.id
WHERE a.name = 'robert'
GROUP BY g.name, e.name
ORDER BY g.name, emotion_count DESC;












