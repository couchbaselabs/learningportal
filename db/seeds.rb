# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

Author.update_design_doc!
Category.update_design_doc!
Couch.client.flush
Wikipedia.seed!