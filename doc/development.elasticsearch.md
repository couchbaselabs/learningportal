# Elasticsearch

After following steps in the `doc/dependencies.application.md` doc, your ElasticSearch server should now be ready to setup and use with:

	rake lp:es:reset

You can find other tasks for interacting with ElasticSearch with:

	rake -T | grep lp:es

## Note

If you drop/recreate the Couchbase bucket, you also need to run `rake lp:es:reset` for ElasticSearch to begin indexing documents again.

## _Tools_

* [Tire](https://github.com/karmi/tire) - _Great looking Ruby client_
* [Rubberband](https://github.com/grantr/rubberband) - _Ruby client library_
* [Elastic Searchable](https://github.com/wireframe/elastic_searchable/) - _Ruby client library_

## _Reading Material_

* [CouchDB Integration](http://www.elasticsearch.org/tutorials/2010/08/01/couchb-integration.html)
* [ES Setup](https://basecamp.com/1759565/projects/368339-couchbase-learning/documents/425421-local-developer)
* [ES Example](https://basecamp.com/1759565/projects/368339-couchbase-learning/messages/2593291-elastic-search)
* [REST Delete/Recreate Buckets](https://basecamp.com/1759565/projects/368339-couchbase-learning/messages/2593194-rest-api-to)
* [Couchbase ES Presentation](https://asset1.basecamp.com/1759565/projects/368339-couchbase-learning/attachments/6909688/50f53ffa66dfe0e10a738c1414dc5d0001246fa5/original/lp-phase2.pdf)