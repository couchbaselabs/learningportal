# 1.  First create an index to use:
# 
#   curl -XPUT 'http://127.0.0.1:9200/couchbase_wiki/'
# 
# 2.  Create a file named "wiki_v1_mapping.json" that we'll use to define a document type with the contents:
# 
#   {
#     "wiki_v1": {
#       "_source": { 
#         "includes" : ["_*"]
#       }
#     }
#   }
# 
# This instructs ElasticSearch to not store MOST of source document.  Only fields beginning with _ are kept.
# 
# 3.  Associated this document type with the index we created:
# 
#   curl -XPUT 'http://127.0.0.1:9200/couchbase_wiki/wiki_v1/_mapping'  -d @wiki_v1_mapping.json
#   
# 4.  Create a file named "river.json" that we'll use to define an ElasticSearch-Couchbase river:
# 
# {
#   "type" : "couchbase",
#   "couchbase" : {
#     "uris": ["http://127.0.0.1:8091/pools"],
#     "bucket": "default",
#     "bucketPassword": "", 
#     "autoBackfill": true, 
#     "registeredTapClient": true,
#     "deregisterTapOnShutdown": false,
#     "vbuckets": []
#   }, 
#   "index" : {
#     "index" : "couchbase_wiki",
#     "type" : "wiki_v1",
#     "bulk_size" : "100",
#     "bulk_timeout" : "10ms",
#     "throttle_size" : 500
#   }
# }
# 
# Adjust the IP address of the couchbase server as needed.
# 
# 5.  Start the river:
# 
#   curl -XPUT http://127.0.0.1:9200/_river/couchbase_river1/_meta -d @river.json
#   
# 6.  If you want to stop the river, run:
# 
#   curl -XDELETE http://127.0.0.1:9200/_river/couchbase_river1
#   
#   NOTE:  this also deletes the saved state of the river, so starting again will start from the beginning