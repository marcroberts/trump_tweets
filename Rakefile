require './trump_tweets'

desc "Build dictionary"
task :build do
  TrumpTweets.new.build
end

desc "Send a Tweet"
task :tweet do
  TrumpTweets.new.tweet
end

desc "Print a Tweet"
task :print do
  TrumpTweets.new.display
end

task :auth do
  TrumpTweets.auth
end
