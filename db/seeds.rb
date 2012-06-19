# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

Couch.delete!(:bucket => 'default')
Couch.delete!(:bucket => 'views')
Couch.delete!(:bucket => 'profiles')
Couch.delete!(:bucket => 'system')

Couch.create!(:bucket => 'default',  :ram => 256)
Couch.create!(:bucket => 'views',    :ram => 256)
Couch.create!(:bucket => 'profiles', :ram => 256)
Couch.create!(:bucket => 'system',   :ram => 128)

Couchbase::Model.ensure_design_document!
# Article.ensure_design_document!
# Author.ensure_design_document!
# Category.ensure_design_document!
# ViewStats.ensure_design_document!

# Couch.client.flush
Wikipedia.seed!