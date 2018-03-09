import json
import sys
from csv import writer

in_file=open(sys.argv[1])  
out_file=open(sys.argv[2], 'w')

print >> out_file, 'tweet_id, tweet_time, tweet_author, tweet_author_id,    tweet_language, tweet_geo, tweet_text'
csv = writer(out_file)
tweet_count = 0

for line in in_file:
     tweet_count += 1
     tweet = json.loads(line)

     # Pull out various data from the tweets
     row = (
         tweet['id'],                    # tweet_id
         tweet['created_at'],            # tweet_time
         tweet['user']['screen_name'],   # tweet_author
         tweet['user']['id_str'],        # tweet_authod_id
         tweet['lang'],                  # tweet_language
         tweet['geo'],                   # tweet_geo
         tweet['text']                   # tweet_text
     )
     values = [(value.encode('utf8') if hasattr(value, 'encode') else value) for value in row]
     csv.writerow(values)

# print the name of the file and number of tweets imported
print "File Imported:", str(sys.argv[1])
print "# Tweets Imported:", tweet_count
print "File Exported:", str(sys.argv[2])
