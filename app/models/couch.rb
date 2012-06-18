module Couch

  class << self

    def user
      ENV['COUCHBASE_USER']
    end

    def pass
      ENV['COUCHBASE_PASS']
    end

    def domain
      ENV['COUCHBASE_URL'] || "http://127.0.0.1:8091/pools/default"
    end

    def client(options = {})
      bucket = options.delete(:bucket) || "default"
      @clients ||= {}
      @clients[bucket] ||= Couchbase.new(domain, :bucket => bucket)
    end

    def delete!(options = {})
      bucket = options.delete(:bucket) || "default"
      puts "Deleting #{bucket} bucket"
      response = Typhoeus::Request.delete("#{domain}/pools/default/buckets/#{bucket}", :username => user, :password => pass)
      if response.success?
        puts "-> #{bucket} deleted successfully"
      elsif response.code == 401
        puts "-> Not Authorised, ensure ENV variables $COUCHBASE_USER and $COUCHBASE_PASS are set"
      else
        puts "-> Problem deleting #{bucket}"
        puts "-> #{response.inspect}"
      end
    end

    def create!(options = {})
      bucket = options.delete(:bucket) || "default"
      ram    = options.delete(:ram)    || 1024
      puts "Creating #{bucket} bucket"
      
      # -d name=#{bucket} -d authType=sasl -d replicaNumber=1 -d ramQuotaMB=#{ram} #{domain}/pools/default/buckets
      response = Typhoeus::Request.post("#{domain}/pools/default/buckets",
        :username => user, :password => pass, :params => {
          "name" => bucket,
          "authType" => "sasl",
          "replicaNumber" => 1,
          "ramQuotaMB" => ram
        })
      if response.success?
        puts "-> #{bucket} created successfully"
      elsif response.code == 401
        puts "-> Not Authorised, ensure ENV variables $COUCHBASE_USER and $COUCHBASE_PASS are set"
      else
        puts "-> Problem creating #{bucket}"
        puts "-> #{response.inspect}"
      end
    end

    protected
    
    def curl
      "curl -s --user #{user}:#{pass}"
    end

  end

end