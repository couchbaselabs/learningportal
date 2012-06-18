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
      `#{curl} -XDELETE #{domain}/pools/default/buckets/default`
    end

    def create!(options = {})
      bucket = options.delete(:bucket) || "default"
      ram    = options.delete(:ram)    || 1024
      puts "Creating #{bucket} bucket"
      `#{curl} -XPOST -d name=#{bucket} -d authType=sasl -d replicaNumber=1 -d ramQuotaMB=#{ram} #{domain}/pools/default/buckets`
    end

    protected
    
    def curl
      "curl -s --user #{user}:#{pass}"
    end

  end

end