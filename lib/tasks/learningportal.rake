namespace :learningportal do
  task :recalculate_scores => :environment do
    documents = Article.by_author.entries
    documents.each do |doc|
      Delayed::Job.enqueue( DocumentScoreJob.new( doc.id ) )
    end
  end
end