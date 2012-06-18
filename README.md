# learningportal

A Couchbase / Elastic Search proof of concept app.

## Dependencies

### Stable

The following dependencies are considered stable and working as a minimum version. 

* elastic search **0.19.3**
* Ruby **1.9.3-p0**
* Bundler **1.1.4**

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


## Tasks

    # run this to schedule delayed_jobs to update scores for all documents
    rake learningportal:recalculate_scores

## Libraries

* http://karmi.github.com/tire/
* https://github.com/karmi/tire
* https://github.com/couchbase/couchbase-ruby-client
* https://github.com/collectiveidea/delayed_job
* https://github.com/dbalatero/typhoeus
* http://www.elasticsearch.org/guide/reference/setup/installation.html
* https://gist.github.com/2933202
