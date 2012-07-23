river_body = File.read("#{Rails.root}/config/es_river.json")
river_body.gsub! "COUCHBASE_URL", ENV["COUCHBASE_URL"]

Typhoeus::Request.put("#{ENV['ELASTIC_SEARCH_URL']}/_river/lp_river/_meta", :body => river_body)
$stdout.puts "Started ElasticSearch river from 'config/es_river.json'."