class CouchbasePerformance
  @total = 0
  @times = 100
  @tests = [
    # function(doc){
    #   emit(doc._id, null);
    # }
    { :all_by_id      => { :limit => 10, :include_docs => true  } },
    { :all_by_id      => { :limit => 10, :include_docs => false } },

    # function(doc){
    #   emit(null, null);
    # }
    { :all_by_null    => { :limit => 10, :include_docs => true  } },
    { :all_by_null    => { :limit => 10, :include_docs => false } },

    # function(doc){
    #   emit([doc.type, doc.popularity || 0], null);
    # }
    { :by_complex_key => { :limit => 10, :include_docs => true  } },
    { :by_complex_key => { :limit => 10, :include_docs => false } },

    # function(doc){
    #   doc.categories.forEach(function(category){
    #     emit([category, doc._id], null)
    #   });
    # }
    { :by_complex_sub_key => { :limit => 10, :include_docs => true  } },
    { :by_complex_sub_key => { :limit => 10, :include_docs => false } }
  ]

  class << self
    def benchmark
      @tests.each do |test|
        view   = test.keys.first
        params = test[view]

        test_view!(view, params)
      end
      puts "\n====> Total time taken for 100 * #{@tests.count} tests: #{@total.round(2)}ms\n"
      puts ""
    end

    private

    def test_view!(view, params)
      puts "====> Testing #{view}(#{params})"
      @times.times do |run|
        start = Time.now
        client.design_docs["performance_testing"].method(view).call(params)
        time = ((Time.now - start) * 1000)
        print "\t----> Run ", "##{run+1} ".ljust(6), "- Couchbase took #{time.round(2)}ms\n"
        @total += time
      end
      puts "----> Total time taken for 100 * #{view}(#{params}) tests: #{@total.round(2)}ms\n"
    end

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

  end
end