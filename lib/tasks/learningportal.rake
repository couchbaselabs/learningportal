namespace :lp do
  desc "Schedule background score indexing for all documents"
  task :recalculate_scores => :environment do
    # perform queuing of document score recalculation
    # in a batch size of 1000 to avoid using too much memoery

    total_docs = Article.view_stats[:count]
    batch_size = 1000
    num_batches = (total_docs / batch_size.to_f).ceil # include all docs in final batch if less than batch_size

    num_batches.times do |skip|
      skip = skip * batch_size
      documents = Couch.client(:bucket => "default").design_docs["article"].by_author(:skip => skip, :limit => batch_size, :group => true).entries.collect { |row| row.key[1] }
      documents.each do |doc|
        Delayed::Job.enqueue( DocumentScoreJob.new( doc ) )
      end
    end
  end

  desc "Drop all buckets"
  task :drop => :environment do
    Couch.delete!(:bucket => 'default')
    Couch.delete!(:bucket => 'views')
    Couch.delete!(:bucket => 'profiles')
    Couch.delete!(:bucket => 'system')
  end

  desc "Drop all buckets"
  task :create => :environment do
    Couch.create!(:bucket => 'default',  :ram => 128)
    Couch.create!(:bucket => 'views',    :ram => 128)
    Couch.create!(:bucket => 'profiles', :ram => 128)
    Couch.create!(:bucket => 'system',   :ram => 128)
  end

  desc "Reset all data"
  task :reset => :environment do
    Rake::Task["lp:drop"].invoke
    sleep 5 # couchbase prefers we wait...
    Rake::Task["lp:create"].invoke
    sleep 5 # couchbase prefers we wait...
    Rake::Task["lp:migrate"].invoke
    Rake::Task["lp:seed"].invoke
    Rake::Task["lp:top_tags_authors"].invoke
    Rake::Task["lp:recalculate_scores"].invoke
    Rake::Task["lp:reindex"].invoke
  end

  desc "Recalculate active content"
  task :recalculate_active => :environment do
    ViewStats.popular_content.each do |row|
      Delayed::Job.enqueue( DocumentScoreJob.new( row.id ) )
    end
  end

  desc "Update top tags and authors"
  task :top_tags_authors => :environment do
    Delayed::Job.enqueue(TopContributorsJob.new(8))
    Delayed::Job.enqueue(TopTagsJob.new(8))
  end

  desc "Update couchbase views"
  task :migrate => :environment do
    Article.ensure_design_document!
    Author.ensure_design_document!
    Category.ensure_design_document!
    ViewStats.ensure_design_document!
  end

  desc "Seed 100 documents"
  task :seed => :environment do
    Wikipedia.seed!
  end

  desc "Regenerate all indexes"
  task :reindex => :environment do
    buckets = %w(default views system profiles)

    buckets.each do |bucket|
      puts "===> Triggering reindex of all views in '#{bucket}' bucket"
      client      = Couch.client(:bucket => bucket)
      design_docs = client.all_docs(:start_key => "_design/", :end_key => "_design/\u9999", :include_docs => true).entries
      design_docs.each do |design|
        puts "\t---> Using #{design.id}..."
        @design_doc = design

        @design_doc.views.each do |view|
          puts "\t\t---> Reindexing _view/#{view}"
          entity = @design_doc.id.gsub("_design/")
          design = client.design_docs[entity]
          @design_doc.send(view, :include_docs => false, :stale => :update_after, :limit => 1)
        end
        puts ""
      end
    end
  end

end