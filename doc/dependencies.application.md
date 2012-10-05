## Application Dependencies (OSX)

* libcouchbase **1.1.0.dp5**
* elastic search **0.19.3**
* couchbase server **2.0.dp4.1** (version 730) [download](http://builds.hq.northscale.net/releases/couch/2.0.0-dev-preview-4.1/couchbase-server-community-x64_64_2.0.0dp4r-730-rel.dmg)

### libcouchbase

Download and install this updated `libcouchbase` homebrew recipe.

    brew update

    wget https://raw.github.com/gist/2895629/12434b53ad1944ea2e5786e2ac0bb7081a5992f9/libcouchbase.rb -O /usr/local/Library/Formula/libcouchbase.rb

    brew install libevent
    brew link libevent
    brew install libcouchbase

### elastic search

    brew install elasticsearch

    plugin -install mobz/elasticsearch-head
    plugin -install elasticsearch/elasticsearch-lang-javascript/1.1.0
    plugin -install couchbaselabs/elasticsearch-transport-couchbase/1.0.0-dp

