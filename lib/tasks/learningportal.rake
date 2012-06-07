namespace :learningportal do
  desc "Schedule background score indexing for all documents"
  task :recalculate_scores => :environment do
    documents = Article.by_author.entries
    documents.each do |doc|
      Delayed::Job.enqueue( DocumentScoreJob.new( doc.id ) )
    end
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
  task :couch_migrate => :environment do
    Article.ensure_design_document!
    Author.ensure_design_document!
    Category.ensure_design_document!
    ViewStats.ensure_design_document!
  end

  desc "Seed 100 documents"
  task :seed => :environment do
    Wikipedia.seed!
  end
end