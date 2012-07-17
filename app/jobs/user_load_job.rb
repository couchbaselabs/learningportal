class UserLoadJob

  URL = case Rails.env.to_sym
  when :development
    "http://127.0.0.1:5000/random"
  when :staging
    "http://learningportal-staging.herokuapp.com/random"
  when :production
    "http://learningportal.herokuapp.com/random"
  end

  def perform
    100.times do
      if Rails.env.development?
        Typhoeus::Request.get(URL)
      else
        Typhoeus::Request.get(URL, :username => ENV['HTTP_AUTH_USERNAME'], :password => ENV['HTTP_AUTH_PASSWORD'])
      end

      sleep 0.5
    end
  end

end