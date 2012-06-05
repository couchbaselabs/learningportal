module Couch

  class << self

    def domain
      ENV['COUCHBASE_URL'] || "http://127.0.0.1:8091/pools/default"
    end

    def client(options = {})
      bucket = options.delete(:bucket) || "default"
      @clients ||= {}
      @clients[bucket] ||= Couchbase.new(domain, :bucket => bucket)
    end

  end

end