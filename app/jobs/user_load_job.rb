class UserLoadJob

  def url
    case Rails.env.to_sym
    when :development
      "http://127.0.0.1:5000/random"
    when :staging
      "http://learningportal-staging.herokuapp.com/random"
    when :production
      "http://learningportal.herokuapp.com/random"
    end
  end

  def perform
    options = {
      :headers => {
        'Accepts' => "text/html"
      }
    }
    options.merge! :username => ENV['HTTP_AUTH_USERNAME'], :password => ENV['HTTP_AUTH_PASSWORD'] unless Rails.env.development?

    Typhoeus::Request.get(url, options)
  end

end