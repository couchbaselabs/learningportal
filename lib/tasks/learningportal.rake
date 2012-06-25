namespace :learningportal do

  namespace :elasticsearch do
    def es_url
      "#{ENV['ELASTIC_SEARCH_URL']}"
    end

    def couchbase_url
      "#{ENV["COUCHBASE_URL"]}"
    end

    desc "Delete and recreate ElasticSearch index and river"
    task :reset => :environment do
      Rake::Task["lp:es:stop_river"].invoke
      Rake::Task["lp:es:delete_index"].invoke
      Rake::Task["lp:es:create_index"].invoke
      Rake::Task["lp:es:create_mapping"].invoke
      Rake::Task["lp:es:start_river"].invoke
    end

    desc "Create ElasticSearch index"
    task :create_index => :environment do
      Typhoeus::Request.put("#{es_url}/learning_portal")
      puts "Created ElasticSearch index."
    end

    desc "Create ElasticSearch mapping"
    task :create_mapping => :environment do
      Typhoeus::Request.put("#{es_url}/learning_portal/lp_v1/_mapping", :body => File.read("app/elasticsearch/lp_mapping.json"))
      puts "Mapped ElasticSearch 'lp_v1' to 'learning_portal' index."
    end

    desc "Start ElasticSearch river"
    task :start_river => :environment do
      body = File.read("app/elasticsearch/river.json")
      body.gsub!("COUCHBASE_URL", couchbase_url)
      body.gsub!("COUCHBASE_PASS", ENV['COUCHBASE_PASS'])

      Typhoeus::Request.put("#{es_url}/_river/lp_river/_meta", :body => body)
      puts "Started ElasticSearch river from 'app/elasticsearch/river.json'."
    end

    desc "Stop ElasticSearch river (will start over indexing documents if recreated)"
    task :stop_river => :environment do
      Typhoeus::Request.delete("#{es_url}/_river/lp_river")
      puts "Stop ElasticSearch river."
    end

    desc "Delete ElasticSearch index"
    task :delete_index => :environment do
      Typhoeus::Request.delete("#{es_url}/learning_portal")
      puts "Deleted ElasticSearch index."
    end
  end

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

  desc "Create all buckets"
  task :create => :environment do
    Couch.create!(:bucket => 'default',  :ram => 128)
    Couch.create!(:bucket => 'views',    :ram => 128)
    Couch.create!(:bucket => 'profiles', :ram => 128)
    Couch.create!(:bucket => 'system',   :ram => 128)
  end

  desc "Reset all data (create, drop, migrate, seed)"
  task :reset => :environment do
    Rake::Task["lp:drop"].invoke
    puts "Pausing for 10 seconds to please Couchbase..."
    sleep 10 # couchbase prefers we wait...
    Rake::Task["lp:create"].invoke
    puts "Pausing another 10 seconds to please Couchbase..."
    sleep 10 # couchbase prefers we wait...
    Rake::Task["lp:migrate"].invoke
    Rake::Task["lp:seed"].invoke
    Rake::Task["lp:top_tags_authors"].invoke
    Rake::Task["lp:recalculate_scores"].invoke
    Rake::Task["lp:reindex"].invoke
    Rake::Task["lp:es:reset"].invoke
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

# Shorthand (keep maintained!)
namespace :lp do
  namespace :es do
    def es_url
      "#{ENV['ELASTIC_SEARCH_URL']}"
    end

    desc "Delete and recreate ElasticSearch index and river"
    task :reset          => "learningportal:elasticsearch:reset"
    desc "Create ElasticSearch index"
    task :create_index   => "learningportal:elasticsearch:create_index"
    desc "Create ElasticSearch mapping"
    task :create_mapping => "learningportal:elasticsearch:create_mapping"
    desc "Start ElasticSearch river"
    task :start_river    => "learningportal:elasticsearch:start_river"
    desc "Stop ElasticSearch river (will start over indexing documents if recreated)"
    task :stop_river     => "learningportal:elasticsearch:stop_river"
    desc "Delete ElasticSearch index"
    task :delete_index   => "learningportal:elasticsearch:delete_index"
  end

  desc "Schedule background score indexing for all documents"
  task :recalculate_scores => "learningportal:recalculate_scores"
  desc "Drop all buckets"
  task :drop               => "learningportal:drop"
  desc "Create all buckets"
  task :create             => "learningportal:create"
  desc "Reset all data (create, drop, migrate, seed)"
  task :reset              => "learningportal:reset"
  desc "Recalculate active content"
  task :recalculate_active => "learningportal:recalculate_active"
  desc "Update top tags and authors"
  task :top_tags_authors   => "learningportal:top_tags_authors"
  desc "Update couchbase views"
  task :migrate            => "learningportal:migrate"
  desc "Seed 100 documents"
  task :seed               => "learningportal:seed"
  desc "Regenerate all indexes"
  task :reindex            => "learningportal:reindex"
end