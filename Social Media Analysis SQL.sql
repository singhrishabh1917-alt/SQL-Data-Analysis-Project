use meta;
select * from users;
select * from photos;
select * from comments;
select * from likes;
select * from follows;
select * from tags;
select * from photo_tags;


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------OBJECTIVE QUESTIONS----------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q1.	Are there any tables with duplicate or missing null values? If so, how would you handle them?

-- check for null values or duplicates in each table --

-- check for null values in each table -- 
-- users
select * from users 
where id is null
   or username is null
   or created_at is null;

-- photos
select * from photos
where id is null
   or image_url is null
   or user_id is null
   or created_dat is null;

-- comments
select * from comments
where id is null
   or comment_text is null
   or user_id is null
   or photo_id is null
   or created_at is null;

-- likes
select * from likes
where user_id is null
   or photo_id is null
   or created_at is null;

-- follows
select * from follows
where follower_id is null
   or followee_id is null
   or created_at is null;

-- tags
select * from tags
where id is null
   or tag_name is null
   or created_at is null;

-- photo_tags
select * from photo_tags
where photo_id is null
   or tag_id is null;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q2.	What is the distribution of user activity levels (e.g., number of posts, likes, comments) across the user base?

-- No. of distribution of user activity levels across the user base --

select u.id, u.username, count(p.id) as total_posts
from users u
left join photos p
on u.id = p.user_id
group by u.id, u.username
order by total_posts desc;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q3.	Calculate the average number of tags per post (photo_tags and photos tables).

-- Average number of tags per post --

select round(avg(tag_count), 2) as avg_tags_per_post
from ( 
select p.id as photo_id, count(pt.tag_id) as tag_count
    from photos p
    left join photo_tags pt on p.id = pt.photo_id
    group by p.id
) as tags_per_post;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q4.	Identify the top users with the highest engagement rates (likes, comments) on their posts and rank them.

-- Find top users with the highest engagement rates (likes, comments) on their posts and rank them --

with photo_count as (
    select user_id, count(*) as total_posts
    from photos
    group by user_id
),
like_count as (
    select p.user_id, count(*) as total_likes
    from photos p
    join likes l
	on p.id = l.photo_id
    group by p.user_id
),
comment_count as (
    select p.user_id, count(*) as total_comments
    from photos p
    join comments c
	on p.id = c.photo_id
    group by p.user_id
)
select u.id, u.username, coalesce(pc.total_posts,0) as total_posts, coalesce(lc.total_likes,0) as total_likes,
coalesce(cc.total_comments,0) as total_comments
from users u
left join photo_count pc
on u.id = pc.user_id
left join like_count lc
on u.id = lc.user_id
left join comment_count cc
on u.id = cc.user_id
order by total_posts desc;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q5.	Which users have the highest number of followers and followings?

-- Find the users with the highest number of followers and followings --

select t.tag_name, count(*) as total_usage
from photo_tags pt
join tags t
on pt.tag_id = t.id
group by t.id, t.tag_name
order by total_usage desc;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q6.	Calculate the average engagement rate (likes, comments) per post for each user.

-- Average engagement rate (likes, comments) per post for each user --

with likes_per_user as (
    select p.user_id, count(*) as total_likes
    from photos p
    join likes l
    on p.id = l.photo_id
    group by p.user_id
),
comments_per_user as (
    select p.user_id, count(*) as total_comments
    from photos p
    join comments c
	on p.id = c.photo_id
    group by p.user_id
)
select u.id, u.username, coalesce(l.total_likes,0) as total_likes, coalesce(c.total_comments,0) as total_comments,
coalesce(l.total_likes,0) + coalesce(c.total_comments,0) as total_engagement
from users u
left join likes_per_user l
on u.id = l.user_id
left join comments_per_user c
on u.id = c.user_id
order by total_engagement desc;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q7.	Get the list of users who have never liked any post (users and likes tables).

-- List of users who have never liked any post --

select u.id, u.username
from users u
left join likes l on u.id = l.user_id
where l.user_id is null
order by u.username;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q8.	How can you leverage user-generated content (posts, hashtags, photo tags) to create more personalized and engaging ad campaigns?

-- Leverage user-generated content to create more personalized and engaging ad campaigns --

select t.tag_name, count(pt.photo_id) as total_usage
from tags t
join photo_tags pt on t.id = pt.tag_id
group by t.id, t.tag_name
order by total_usage desc;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q9.	Are there any correlations between user activity levels and specific content types (e.g., photos, videos, reels)? 
-- How can this information guide content creation and curation strategies?

-- Analyze the relationship between user posting activity and the engagement (likes and comments) received on photo --

with engagement as (
    select p.user_id, count(l.photo_id) as likes, count(c.id) as comments
    from photos p
    left join likes l
    on p.id = l.photo_id
    left join comments c
    on p.id = c.photo_id
    group by p.user_id
)
select u.username, coalesce(e.likes,0) as likes, coalesce(e.comments,0) as comments,
coalesce(e.likes,0) + coalesce(e.comments,0) as total_engagement
from users u
left join engagement e
on u.id = e.user_id
order by total_engagement desc;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q10.	Calculate the total number of likes, comments, and photo tags for each user.

-- Total number of likes, comments, and photo tags for each user --

with likes_per_user as (
    select p.user_id, count(*) as total_likes
    from photos p
    join likes l
	on p.id = l.photo_id
    group by p.user_id
),
comments_per_user as (
    select p.user_id, count(*) as total_comments
    from photos p
    join comments c
    on p.id = c.photo_id
    group by p.user_id
),
tags_per_user as (
    select p.user_id, count(*) as total_photo_tags
    from photos p
    join photo_tags pt
    on p.id = pt.photo_id
    group by p.user_id
)
select u.id, u.username, coalesce(l.total_likes, 0) as total_likes,
coalesce(c.total_comments, 0) as total_comments, coalesce(t.total_photo_tags, 0) as total_photo_tags
from users u
left join likes_per_user l
on u.id = l.user_id
left join comments_per_user c
on u.id = c.user_id
left join tags_per_user t
on u.id = t.user_id
order by total_likes desc, total_comments desc, total_photo_tags desc;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q11.	Rank users based on their total engagement (likes, comments, shares) over a month.

-- Rank users based on their total engagement over a month --

with engagement as (
    select p.user_id, count(l.photo_id) as total_likes, count(c.id) as total_comments,
	count(l.photo_id) + count(c.id) as total_engagement
    from photos p
    left join likes l
	on p.id = l.photo_id
    left join comments c
	on p.id = c.photo_id
    group by p.user_id
)
select u.id, u.username, coalesce(e.total_likes, 0) as total_likes,
coalesce(e.total_comments, 0) as total_comments, coalesce(e.total_engagement, 0) as total_engagement,
dense_rank() over (order by coalesce(e.total_engagement, 0) desc) as engagement_rank
from users u
left join engagement e
on u.id = e.user_id
order by engagement_rank;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q12.	Retrieve the hashtags that have been used in posts with the highest average number of likes. 
-- Use a CTE to calculate the average likes for each hashtag first.

-- Find the average likes for each hashtag first --

with hashtag_likes as (
    select t.id as tag_id, t.tag_name, p.id as photo_id, count(distinct l.user_id, l.photo_id) as total_likes
    from tags t
    inner join photo_tags pt on t.id = pt.tag_id
    inner join photos p on pt.photo_id = p.id
    left join likes l on p.id = l.photo_id
    group by t.id, t.tag_name, p.id
)
select tag_name, round(avg(total_likes), 2) as avg_likes
from hashtag_likes
group by tag_id, tag_name
order by avg_likes desc;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q13.	Retrieve the users who have started following someone after being followed by that person.

-- Find the users who have started following someone after being followed by that person --

select u1.username as user_1, u2.username as user_2
from follows f1
inner join follows f2 on f1.follower_id = f2.followee_id and f1.followee_id = f2.follower_id
inner join users u1 on f1.follower_id = u1.id
inner join users u2 on f1.followee_id = u2.id
where f1.follower_id < f1.followee_id
order by user_1, user_2;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------SUBJECTIVE QUESTIONS---------------------------------------------------------------------------------- --
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q1. Based on user engagement and activity levels, which users would you consider the most loyal or valuable? 
-- How would you reward or incentivize these users?

-- Find most loyal or valuable users based on user engagement and activity levels --

with post_count as (
    select user_id, count(*) as total_posts
    from photos
    group by user_id
),
like_count as (
    select p.user_id, count(*) as total_likes
    from photos p
    join likes l
	on p.id = l.photo_id
    group by p.user_id
),
comment_count as (
    select p.user_id, count(*) as total_comments
    from photos p
    join comments c
	on p.id = c.photo_id
    group by p.user_id
)
select u.id, u.username, coalesce(pc.total_posts,0) as total_posts,
coalesce(lc.total_likes,0) as total_likes, coalesce(cc.total_comments,0) as total_comments,
round((coalesce(lc.total_likes,0) + coalesce(cc.total_comments,0)) / nullif(coalesce(pc.total_posts,0),0),2) as engagement_per_post
from users u
left join post_count pc
on u.id = pc.user_id
left join like_count lc
on u.id = lc.user_id
left join comment_count cc
on u.id = cc.user_id
where coalesce(pc.total_posts,0) > 0
order by engagement_per_post desc, total_posts desc;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		

-- Q2. For inactive users, what strategies would you recommend to re-engage them and encourage them to start posting or engaging again?

-- Identify inactive users and find strategies to re-engage & encourage them to strat posting --

select u.id, u.username, count(distinct p.id) as total_posts, count(distinct l.photo_id) as total_likes, 
count(distinct c.id) as total_comments
from users u
left join photos p on u.id = p.user_id
left join likes l on u.id = l.user_id
left join comments c on u.id = c.user_id
group by u.id, u.username
having total_posts = 0 and total_likes = 0 and total_comments = 0
order by u.username;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		

-- Q3. Which hashtags or content topics have the highest engagement rates? How can this information guide content strategy and ad campaigns?

-- Find hashtags or content topics have the highest engagement rates

with photo_engagement as (
    select p.id as photo_id, count(distinct l.user_id, l.photo_id) as total_likes, count(distinct c.id) as total_comments
    from photos p
    left join likes l
	on p.id = l.photo_id
    left join comments c
	on p.id = c.photo_id
    group by p.id
)
select t.tag_name, round(avg(coalesce(pe.total_likes, 0)), 2) as avg_likes, round(avg(coalesce(pe.total_comments, 0)), 2) as avg_comments,
round(avg(coalesce(pe.total_likes, 0) + coalesce(pe.total_comments, 0)), 2) as avg_engagement
from tags t
join photo_tags pt
on t.id = pt.tag_id
left join photo_engagement pe
on pt.photo_id = pe.photo_id
group by t.id, t.tag_name
order by avg_engagement desc;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		

-- 4. Are there any patterns or trends in user engagement based on demographics (age, location, gender) or posting times? 
-- How can these insights inform targeted marketing campaigns?

-- find patterns or trends in user engagement --

select u.id, u.username, count(distinct p.id) as total_posts,
count(distinct l.user_id, l.photo_id) as total_likes, count(distinct c.id) as total_comments,
round((count(distinct l.user_id, l.photo_id) + count(distinct c.id)) / nullif(count(distinct p.id),0), 2) as engagement_per_post
from users u
left join photos p on u.id = p.user_id
left join likes l on p.id = l.photo_id
left join comments c on p.id = c.photo_id
group by u.id, u.username
having total_posts > 0
order by engagement_per_post desc;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		

-- Q5. Based on follower counts and engagement rates, which users would be ideal candidates for influencer marketing campaigns? 
-- How would you approach and collaborate with these influencers?

-- Users who would be ideal for influencer marketing strategies --

SELECT u.id, u.username, COALESCE(f.total_followers, 0) AS total_followers, COALESCE(p.total_posts, 0) AS total_posts,
COALESCE(l.total_likes, 0) AS total_likes, COALESCE(c.total_comments, 0) AS total_comments,
ROUND((COALESCE(l.total_likes, 0) + COALESCE(c.total_comments, 0)) / NULLIF(COALESCE(p.total_posts, 0), 0),  2) AS engagement_per_post
FROM users u
LEFT JOIN (
    SELECT followee_id, COUNT(*) AS total_followers
    FROM follows
    GROUP BY followee_id
) f ON u.id = f.followee_id
LEFT JOIN (
    SELECT user_id, COUNT(*) AS total_posts
    FROM photos
    GROUP BY user_id
) p ON u.id = p.user_id
LEFT JOIN (
    SELECT p.user_id, COUNT(*) AS total_likes
    FROM photos p
    INNER JOIN likes l ON p.id = l.photo_id
    GROUP BY p.user_id
) l ON u.id = l.user_id
LEFT JOIN (
    SELECT p.user_id, COUNT(*) AS total_comments
    FROM photos p
    INNER JOIN comments c ON p.id = c.photo_id
    GROUP BY p.user_id
) c ON u.id = c.user_id
WHERE COALESCE(p.total_posts, 0) > 0
ORDER BY total_followers DESC, engagement_per_post DESC;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		

-- Q6. Based on user behavior and engagement data, how would you segment the user base for 
-- targeted marketing campaigns or personalized recommendations?

-- Segment user base for targeted marketing campaigns or personalized recommendations

WITH user_activity AS (
    SELECT u.id, u.username, COALESCE(p.total_posts, 0) AS total_posts,
	COALESCE(l.total_likes_given, 0) AS total_likes_given, COALESCE(c.total_comments, 0) AS total_comments
    FROM users u
    LEFT JOIN (SELECT user_id, COUNT(*) AS total_posts
        FROM photos
        GROUP BY user_id) p
    ON u.id = p.user_id
    LEFT JOIN (SELECT user_id, COUNT(*) AS total_likes_given
        FROM likes
        GROUP BY user_id) l
    ON u.id = l.user_id
    LEFT JOIN (
        SELECT user_id, COUNT(*) AS total_comments
        FROM comments
        GROUP BY user_id) c
    ON u.id = c.user_id
)
SELECT id, username, total_posts, total_likes_given, total_comments,
    CASE
        WHEN total_posts >= 5 THEN 'content Creator'
        WHEN total_likes_given >= 5 OR total_comments >= 5 THEN 'active Engager'
        WHEN total_posts = 0 AND total_likes_given = 0 AND total_comments = 0 THEN 'inactive User'
        ELSE 'casual User'
    END AS user_segment
FROM user_activity
ORDER BY user_segment, total_posts DESC;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		

-- Q7. If data on ad campaigns (impressions, clicks, conversions) is available, 
-- how would you measure their effectiveness and optimize future campaigns?

-- Measure the ad campaigns effectiveness and optimize campaigns --

WITH photo_engagement AS (
    SELECT p.id AS photo_id, COUNT(DISTINCT l.user_id, l.photo_id) AS total_likes, COUNT(DISTINCT c.id) AS total_comments
    FROM photos p
    LEFT JOIN likes l
    ON p.id = l.photo_id
    LEFT JOIN comments c
    ON p.id = c.photo_id
    GROUP BY p.id
),
hashtag_engagement AS (
    SELECT t.id AS tag_id, t.tag_name, SUM(COALESCE(pe.total_likes, 0)) AS total_likes, SUM(COALESCE(pe.total_comments, 0)) AS total_comments
    FROM tags t
    JOIN photo_tags pt
	ON t.id = pt.tag_id
    LEFT JOIN photo_engagement pe
    ON pt.photo_id = pe.photo_id
    GROUP BY t.id, t.tag_name
)
SELECT tag_name, total_likes, total_comments, (total_likes + total_comments) AS total_engagement
FROM hashtag_engagement
ORDER BY total_engagement DESC;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		

-- Q8. How can you use user activity data to identify potential brand ambassadors 
-- or advocates who could help promote Instagram's initiatives or events?

-- Identify brand ambassadors or advocates to promote Instagram's initiatives or events --

WITH post_count AS (
    SELECT user_id, COUNT(*) AS total_posts
    FROM photos
    GROUP BY user_id
),
like_count AS (
    SELECT p.user_id, COUNT(*) AS total_likes_received
    FROM photos p
    JOIN likes l
	ON p.id = l.photo_id
    GROUP BY p.user_id
),
comment_count AS (
    SELECT p.user_id, COUNT(*) AS total_comments_received
    FROM photos p
    JOIN comments c
	ON p.id = c.photo_id
    GROUP BY p.user_id
)
SELECT u.id, u.username, COALESCE(pc.total_posts, 0) AS total_posts,
COALESCE(lc.total_likes_received, 0) AS total_likes_received,
COALESCE(cc.total_comments_received, 0) AS total_comments_received,
ROUND((COALESCE(lc.total_likes_received, 0) + COALESCE(cc.total_comments_received, 0)) 
/ NULLIF(COALESCE(pc.total_posts, 0), 0), 2) AS engagement_per_post
FROM users u
LEFT JOIN post_count pc
ON u.id = pc.user_id
LEFT JOIN like_count lc
ON u.id = lc.user_id
LEFT JOIN comment_count cc
ON u.id = cc.user_id
WHERE COALESCE(pc.total_posts, 0) > 0
ORDER BY engagement_per_post DESC, total_posts DESC;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		

-- Q9. How would you approach this problem, if the objective and subjective questions weren't given?

-- --   Answered in Word File --

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		

-- Q10.	Assuming there's a "User_Interactions" table tracking user engagements, how can you update the "Engagement_Type" column 
-- to change all instances of "Like" to "Heart" to align with Instagram's terminology?

-- --   Answered in Word File --

-- -------------------------------------------------------------------END-----------------------------------------------------------------------------------------------------------		