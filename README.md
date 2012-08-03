# learningportal

A Couchbase / Elastic Search proof of concept app.

## Dependencies

### Stable

The following dependencies are considered stable and working as a minimum version.

* elastic search **0.19.3**
* Ruby **1.9.3-p0**
* Bundler **1.2.0.rc**

### Development

The following dependencies are currently in development and may change more frequently.

* libcouchbase **1.1.0.dp5**
* couchbase server **2.0.dp4.1** (version 730)

## Installation

### Development (OSX)

The first thing to do is ensure your OSX machine is ready to go.

1. [OSX Ruby Development Dependencies](learningportal/tree/master/doc/dependencies.base.md)
2. [Application Dependencies](learningportal/tree/master/doc/dependencies.application.md)

Once you've done that, for local development we have two approaches

* [Standard Development Environment](learningportal/tree/master/doc/development.standard.md)
* [Development Environment with a Couchbase VM using Vagrant](learningportal/tree/master/doc/development.vagrant.md)

The benefit of a VM is such that new development releases of couchbase server can be tested (and isolated) from the learningportal app.

### Production (EC2)

re-install couchbase on an ec2 instance.

    sudo /etc/init.d/couchbase-server stop
    sudo rpm -e couchbase-server-2.0.0dp4r-730.x86_64
    sudo rm -rf /opt/couchbase
    sudo rpm -i couchbase-server-community_x86_64_2.0.0dp4r-730-rel.rpm
    sudo /etc/init.d/couchbase-server start

# Migrating Staging / Production Buckets

When adding new buckets to staging or production we sometimes only want to create and migrate the buckets which do not yet exist.
This is done by the following:

    rake lp:ensure_buckets
    rake lp:migrate

## Management Tasks

The following is a list of tasks that are useful for managing the application.

    ➜  learningportal git:(master) rake -T | grep lp:
    rake lp:create              # Create all buckets
    rake lp:drop                # Drop all buckets
    rake lp:migrate             # Update couchbase views
    rake lp:ensure_buckets      # Detect and create missing buckets (Safe operation)
    rake lp:es:create_index     # Create ElasticSearch index
    rake lp:es:create_mapping   # Create ElasticSearch mapping
    rake lp:es:delete_index     # Delete ElasticSearch index
    rake lp:es:reset            # Delete and recreate ElasticSearch index and river
    rake lp:es:start_river      # Start ElasticSearch river
    rake lp:es:stop_river       # Stop ElasticSearch river (will start over indexing documents if recreated)
    rake lp:recalculate_active  # Recalculate active content
    rake lp:recalculate_scores  # Schedule background score indexing for all documents
    rake lp:reindex             # Regenerate all indexes
    rake lp:reset               # Reset all data (create, drop, migrate, seed)
    rake lp:seed                # Seed 100 documents
    rake lp:top_tags_authors    # Update top tags and authors

## Libraries

* http://karmi.github.com/tire/
* https://github.com/karmi/tire
* https://github.com/couchbase/couchbase-ruby-client
* https://github.com/collectiveidea/delayed_job
* https://github.com/dbalatero/typhoeus
* http://www.elasticsearch.org/guide/reference/setup/installation.html
* https://gist.github.com/2933202


