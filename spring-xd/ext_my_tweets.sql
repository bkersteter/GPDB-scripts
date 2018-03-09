CREATE EXTERNAL TABLE my_tweets
(  tweet_id  BIGINT,
   created_at  timestamp,
   user_screen_name  varchar,
   user_id  bigint,
   tweet_lang varchar,
   retweet_count integer,
   tweet_text  text
    )
LOCATION ('gpfdist://localhost:8081/*.out')
FORMAT 'CSV' (DELIMITER ',')
LOG ERRORS INTO err_my_tweets SEGMENT REJECT LIMIT 10;
