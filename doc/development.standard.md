## Standard Development Environment Installation (OSX)

### couchbase server

* Download [couchbase server 2.0 dp 4.1](http://builds.hq.northscale.net/releases/couch/2.0.0-dev-preview-4.1/couchbase-server-community-x64_64_2.0.0dp4r-730-rel.dmg)
* Copy the application to /Applications
* `open http://localhost:8091` and follow the onscreen instructions


### Configuration

    cd learningportal
    touch .env

    echo "ELASTIC_SEARCH_URL=http://localhost:9200
    COUCHBASE_URL=http://localhost:8091
    COUCHBASE_HOST=localhost
    COUCHBASE_USER=Administrator
    COUCHBASE_PASS=Administrator
    HTTP_AUTH_PASSWORD=xxxx
    BUCKET_RAM_DEFAULT=100
    BUCKET_RAM_VIEWS=100
    BUCKET_RAM_PROFILES=100
    BUCKET_RAM_GLOBAL=100
    BUCKET_RAM_SYSTEM=100
    BUCKET_RAM_EVENTS=100
    EVENT_STREAM_TTL=86400" > .env

[foreman](https://github.com/ddollar/foreman) uses a `.env` file for ENV variables and loads this automatically when running `foreman start`. To load variables for other processes

    export $(cat .env)

## Startup

The following commands will get you setup for the *first time*.

    open /Applications/Couchbase\ Server.app/

    # setup buckets, views and seed content from wikipedia
    rake lp:reset

    # start rails app server and delayed_job  workers
    foreman start

    open http://localhost:8091 # couchbase admin
    open http://localhost:5000 # app