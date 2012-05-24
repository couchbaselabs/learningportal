namespace :learningportal do
  task :recalculate_scores => :environment do
    documents = Couch.client.all_docs.entries
    documents.each do |doc|
      Delayed::Job.enqueue( DocumentScoreJob.new( doc.key ) )
    end
  end
end