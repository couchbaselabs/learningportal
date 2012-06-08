# learningportal

A Couchbase / Elastic Search proof of concept app.

## Development Environment Installation (OSX)

* libcouchbase **1.1.0.dp2**
* couchbase server **2.0** [download](http://packages.couchbase.com/releases/2.0.0-developer-preview-4/couchbase-server-community_x86_64_2.0.0-dev-preview-4.zip)
* elastic search **0.19.3**

### libcouchbase

Download and install this updated `libcouchbase` homebrew recipe.

    wget https://raw.github.com/gist/2895629/12434b53ad1944ea2e5786e2ac0bb7081a5992f9/libcouchbase.rb -O /usr/local/Library/Formula/libcouchbase.rb

    brew update
    brew install libevent
    brew link libevent
    brew install libcouchbase

### elastic search

    brew install elasticsearch

    plugin -install mobz/elasticsearch-head
    plugin -install elasticsearch/elasticsearch-lang-javascript/1.1.0
    plugin -install mschoch/elasticsearch-river-couchbase/1.0.1-SNAPSHOT

### couchbase server

* Download [couchbase server 2.0](http://packages.couchbase.com/releases/2.0.0-developer-preview-4/couchbase-server-community_x86_64_2.0.0-dev-preview-4.zip)
* Copy the application to /Applications
* `open http://localhost:8091` and follow the onscreen instructions

## Configuration

    cd learningportal
    touch .env

    echo "ELASTIC_SEARCH_URL=http://localhost:9200
    COUCHBASE_URL=http://localhost:8091
    HTTP_AUTH_PASSWORD=xxxx" > .env

[foreman](https://github.com/ddollar/foreman) uses a `.env` file for ENV variables and loads this automatically when running `foreman start`. To load variables for other processes

    export $(cat .env)

## Startup

    open /Applications/Couchbase\ Server.app/

    rake db:seed               # seed content from wikipedia
    foreman start              # start rails app server and elasticsearch

    open http://localhost:8091 # couchbase admin
    open http://localhost:5000 # app

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

## Couchbase VM

### Setup

    # https://www.virtualbox.org/wiki/Downloads
    wget http://download.virtualbox.org/virtualbox/4.1.16/VirtualBox-4.1.16-78094-OSX.dmg
    rvm gemset use global
    gem install vagrant --no-ri --no-rdoc
    cd learningportal

    # edit COUCHBASE_HOST in .env to an appropriate IP to enable hostonly networking
    export $(cat .env)
    vagrant up

**CAVEAT:** vagrant will not exit cleanly after provisioning couchbase (no idea why as yet) 
so you need to ctrl+c **twice** quickly after the following output is complete.

    ➜  learningportal git:(master) ✗ vagrant up     
    192.168.2.254
    [default] Importing base box 'lucid32'...
    [default] The guest additions on this VM do not match the install version of
    VirtualBox! This may cause things such as forwarded ports, shared
    folders, and more to not work properly. If any of those things fail on
    this machine, please update the guest additions and repackage the
    box.

    Guest Additions Version: 4.1.14
    VirtualBox Version: 4.1.16
    [default] Matching MAC address for NAT networking...
    [default] Clearing any previously set forwarded ports...
    [default] Forwarding ports...
    [default] -- 22 => 2222 (adapter 1)
    [default] Creating shared folders metadata...
    [default] Clearing any previously set network interfaces...
    [default] Preparing network interfaces based on configuration...
    [default] Running any VM customizations...
    [default] Booting VM...
    [default] Waiting for VM to boot. This can take a few minutes.
    [default] VM booted and ready for use!
    [default] Configuring and enabling network interfaces...
    [default] Mounting shared folders...
    [default] -- v-root: /vagrant
    [default] Running provisioner: Vagrant::Provisioners::Shell...
    stdin: is not a tty
    wget: couchbase-server-community_x86_2.0.0dp4r-730-rel.deb
    install: couchbase-server-community_x86_2.0.0dp4r-730-rel.deb
    Selecting previously deselected package couchbase-server.
    (Reading database ... 
    26974 files and directories currently installed.)
    Unpacking couchbase-server (from couchbase-server-community_x86_2.0.0dp4r-730-rel.deb) ...
    Setting up couchbase-server (2.0.0dp4r) ...
     * Started couchbase-server

    You have successfully installed Couchbase Server.
    Please browse to http://lucid32:8091/ to configure your server.
    Please refer to http://couchbase.com for additional resources.

    Please note that you have to update your firewall configuration to
    allow connections to the following ports: 11211, 11210, 4369,
    8091, 8092 and from 21100-to-21299.

    By using this software you agree to the End User License Agreement.
    See /opt/couchbase/LICENSE.txt.


    Processing triggers for ureadahead ...
    ureadahead will be reprofiled on next reboot
    fin.


