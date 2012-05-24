namespace :learningportal do
  task :recalculate_scores => :environment do
    documents = Couch.client.all_docs.entries
    documents.each do |doc|
      if !(doc.key =~ /view_count/) && !(doc.key =~ /design/)
        Delayed::Job.enqueue( DocumentScoreJob.new( doc.key ) )
      end
    end
  end
end