## VM Development Environment Installation (OSX)

### Virtualbox

Get **4.1.16** https://www.virtualbox.org/wiki/Downloads

    wget http://download.virtualbox.org/virtualbox/4.1.16/VirtualBox-4.1.16-78094-OSX.dmg


### Install Vagrant

    rvm gemset use global
    gem install vagrant --no-ri --no-rdoc
    cd learningportal

### Configuration

    cd learningportal
    touch .env

    echo "ELASTIC_SEARCH_URL=http://localhost:9200
    COUCHBASE_URL=http://192.168.2.254:8091
    COUCHBASE_HOST=192.168.2.254
    COUCHBASE_USER=Administrator
    COUCHBASE_PASS=Administrator
    HTTP_AUTH_PASSWORD=xxxx" > .env

The difference here from the **standard** instructions is that we've chosen a **couchbase host** address that will allow us to use vagrant's **host only networking** to put the couchbase VM instance accessible. I chose **192.168.2.254** but you will need to pick a different one depending on your current network's addressing.

### Install VM (including Couchbase)

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

## Startup

The following commands will get you setup for the *first time*.

    open /Applications/Couchbase\ Server.app/

    # setup buckets, views and seed content from wikipedia
    rake lp:bootstrap

    # start rails app server and delayed_job  workers
    foreman start

    open http://192.168.2.254:8091 # couchbase admin
    open http://localhost:5000     # app