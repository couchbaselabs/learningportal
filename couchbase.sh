#!/bin/bash
echo wget: couchbase-server-community_x86_2.0.0dp4r-730-rel.deb
wget -q http://builds.hq.northscale.net/releases/couch/2.0.0-dev-preview-4.1/couchbase-server-community_x86_2.0.0dp4r-730-rel.deb
echo install: couchbase-server-community_x86_2.0.0dp4r-730-rel.deb
dpkg -i couchbase-server-community_x86_2.0.0dp4r-730-rel.deb
echo fin.