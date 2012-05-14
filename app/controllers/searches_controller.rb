class SearchesController < ApplicationController

  def build
    render :build
  end

  def show
    Tire.configure do
      url ENV["ELASTIC_SEARCH_URL"]
    end
    @documents = []
    @search = Tire.search 'couchbase_wiki' do
      query do
        string '_all:water'
      end
    end
    @search.results.each do |result|
      @documents << result
    end

    @couchbase = Couchbase.connect(ENV["COUCHBASE_URL"])
    @document = @couchbase.get('00411460f7c92d21')
    #@document = nil
    #@couchbase.run do |conn|
    #  @document = conn.get("00411460f7c92d21")
    #end
  end


end