web: bundle exec rails server thin -p $PORT
es: elasticsearch -f -D es.config=/usr/local/Cellar/elasticsearch/0.19.3/config/elasticsearch.yml
worker: bundle exec rake jobs:work