namespace :learningportal do
  desc "Schedule background score indexing for all documents"
  task :recalculate_scores => :environment do
    documents = Article.by_author.entries
    documents.each do |doc|
      Delayed::Job.enqueue( DocumentScoreJob.new( doc.id ) )
    end
  end

  desc "Update top tags and authors"
  task :top_tags_authors => :environment do
    Delayed::Job.enqueue(TopContributorsJob.new(8))
    Delayed::Job.enqueue(TopTagsJob.new(8))
  end

end