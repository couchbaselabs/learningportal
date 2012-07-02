# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

Couch.delete!(:bucket => 'default')
Couch.delete!(:bucket => 'views')
Couch.delete!(:bucket => 'profiles')
Couch.delete!(:bucket => 'system')
Couch.delete!(:bucket => 'global')

Couch.create!(:bucket => 'default',  :ram => 128)
Couch.create!(:bucket => 'views',    :ram => 128)
Couch.create!(:bucket => 'profiles', :ram => 128)
Couch.create!(:bucket => 'system',   :ram => 128)
Couch.create!(:bucket => 'global',   :ram => 128)

Couchbase::Model.ensure_design_document!
# Article.ensure_design_document!
# Author.ensure_design_document!
# Category.ensure_design_document!
# PeriodViewStats.ensure_design_document!
# GlobalViewStats.ensure_design_document!

# Couch.client.flush
Wikipedia.seed!