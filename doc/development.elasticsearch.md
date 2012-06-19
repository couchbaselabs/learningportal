# Elasticsearch

Steps in getting setup and familiar with Couchbase and Elasticsearch.

## Steps

Add **elasticsearch** to **Procfile** to start with foreman (done, use `foreman start` as normal).

### Create 'learning_portal' index.

```
curl -X PUT 'http://127.0.0.1:9200/learning_portal/'
```

### Define a mapping doc - `app/elasticsearch/lp_mapping.json`
This mapping avoids storing the doc source.

```
{
  "lp_v1": {
    "_source": {
      "includes" : ["_*"]
    }
  }
}
```

Associate the document type with the index.

```
curl -X PUT 'http://127.0.0.1:9200/learning_portal/lp_v1/_mapping' -d @app/elasticsearch/lp_mapping.json
```

### Define the River - `app/elasticsearch/river.json`

Makes a river to put new docs _from_ Couchbase to Elasticsearch to be indexed based on what's defined in the **mapping** file _type_.

```
{
  "type" : "couchbase",
  "couchbase" : {
    "uris": ["http://127.0.0.1:8091/pools"],
    "bucket": "default",
    "bucketPassword": "",
    "autoBackﬁll": true,
    "registeredTapClient": true,
    "deregisterTapOnShutdown": false,
    "vbuckets": []
  },
  "index" : {
    "index" : "learning_portal",
    "type" : "lp_v1",
    "bulk_size" : "100",
    "bulk_timeout" : "10ms",
    "throttle_size" : 500
  }
}
```

### Start the River

```
curl -X PUT http://127.0.0.1:9200/_river/lp_river/_meta -d @app/elasticsearch/river.json
```

### Stop the River
This also loses state, so it will start over if recreated.

```
curl -X DELETE http://127.0.0.1:9200/_river/lp_river
```

### Delete the Index

```
curl -X DELETE 'http://127.0.0.1:9200/learning_portal/'
```

## Note

If you drop/recreate the Couchbase bucket, you should also:

* stop the river
* delete/recreate the search index
* define/associate the document type in a `mapping.json` file.
* start the river

## _Tools_

* [Tire](https://github.com/karmi/tire) - _Great looking Ruby client_
* [Rubberband](https://github.com/grantr/rubberband) - _Ruby client library_
* [Elastic Searchable](https://github.com/wireframe/elastic_searchable/) - _Ruby client library_

## _Reading Material_

* [CouchDB Integration](http://www.elasticsearch.org/tutorials/2010/08/01/couchb-integration.html)
* [ES Setup](https://basecamp.com/1759565/projects/368339-couchbase-learning/documents/425421-local-developer)
* [ES Example](https://basecamp.com/1759565/projects/368339-couchbase-learning/messages/2593291-elastic-search)
* [REST Delete/Recreate Buckets](https://basecamp.com/1759565/projects/368339-couchbase-learning/messages/2593194-rest-api-to)
* [Couchbase ES Presentation](https://asset1.basecamp.com/1759565/projects/368339-couchbase-learning/attachments/6909688/50f53ffa66dfe0e10a738c1414dc5d0001246fa5/original/lp-phase2.pdf)