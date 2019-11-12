require 'rubygems'
require 'bundler'

Bundler.require
Dotenv.load

class TrumpTweets

  def initialize
    load_dictionary!

    @twitter = Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_API_KEY']
      config.consumer_secret = ENV['TWITTER_API_SECRET']
      config.access_token = ENV['TWITTER_OAUTH_TOKEN']
      config.access_token_secret = ENV['TWITTER_OAUTH_SECRET']
    end
  end

  def load_dictionary!
    @markov = MarkyMarkov::Dictionary.new('trump',2)
  end

  def build
    PersistentDictionary.delete_dictionary! @markov
    load_dictionary!
    Dir.glob('corpus/*.txt').each do |file|
      File.foreach(file).with_index do |line, line_num|
        line = line.strip
        next if line =~ /^#/
        next if line =~ /^$/
        @markov.parse_string line
      end
    end
    @markov.save_dictionary!
  end

  def tweet
    @twitter.update generate_tweet
  end

  def display
    puts generate_tweet
  end

  def self.auth
    consumer = OAuth::Consumer.new(ENV['TWITTER_API_KEY'], ENV['TWITTER_API_SECRET'], :site => "https://api.twitter.com" )
    request_token = consumer.get_request_token

    puts "Visit: #{request_token.authorize_url} to authorise the app\n"
    puts "Enter the pin code"
    pin = STDIN.gets.chomp

    access_token = request_token.get_access_token :oauth_verifier => pin

    puts "Token: #{access_token.token}, Secret: #{access_token.secret}\n\n"
  end

  protected

    def generate_tweet
      tweet = ''
      attempt = 1

      while attempt <= 3
        sentence = @markov.generate_n_sentences(1).strip
        if tweet.size + 1 + sentence.size <= 280
          tweet += " #{sentence}"
          attempt = 1
        else
          attempt += 1
        end
      end
      return tweet.strip
    end

end
