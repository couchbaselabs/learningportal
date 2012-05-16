module Couch

  class << self

    def domain
      ENV['COUCHBASE_URL'] || "http://127.0.0.1:8091/pools/default"
    end

    def client
      @client ||= Couchbase.new(domain)
    end

  end

end