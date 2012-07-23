class Event < Couchbase::Model

  # We want to make sure we use the correct events bucket.
  cattr_accessor :bucket_name
  self.bucket_name = "events"

  view :by_type

  def self.bucket
    Couch.client(:bucket => bucket_name)
  end

  # Possible event types
  ACCESS = "access"
  CREATE = "create"
  TAGGED = "tagged"

  attribute :type
  attribute :user
  attribute :resource
  attribute :timestamp, :default => lambda { Time.now.utc }

  def save
    super(:ttl => ENV['EVENT_STREAM_TTL'].to_i)
  end
end