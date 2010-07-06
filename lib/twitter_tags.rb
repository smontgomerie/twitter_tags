module TwitterTags
  include Radiant::Taggable

  desc "Creates an context for the twitter functionality"
  tag "twitter" do |tag|
    user = tag.attr['user']
    search = tag.attr['search']

    # we need a user in the user attribute
    raise StandardError::new('the twitter-tag needs a username in the user attribute') if user.blank? && search.blank?
    tag.locals.user = user
    tag.locals.search = search
    tag.expand
  end

  desc "Creates the loop for the tweets - takes count and order optionally"
  tag "twitter:tweets" do |tag|
    count = (tag.attr['count'] || 10).to_i # reminder: "foo".to_i => 0
    order = (tag.attr['order'] || 'desc').downcase

    raise StandardError::new('the count attribute should be a positive integer') unless count > 0
    raise StandardError::new('the order attribute should be "asc" or "desc"') unless %w{  asc desc  }.include?(order)

    if (tag.locals.search)
      twitter = Twitter::Search.new(tag.locals.search)
    else
      twitter = Twitter::Search.new
    end

    if (tag.locals.user)
      twitter = twitter.from(tag.locals.user)
    end

    # iterate over the tweets
    result = []

    begin
      twitter.per_page(count).each do |tweet|
        tag.locals.tweet = tweet
        result << tag.expand
      end
    rescue
    end

    result
  end

  desc "Creates the context within which the tweet can be examined"
  tag "twitter:tweets:tweet" do |tag|
    tag.expand
  end

  desc "Returns the text from the tweet"
  tag "twitter:tweets:tweet:text" do |tag|
    tweet = tag.locals.tweet
    tweet['text']
  end

  desc "Returns the date & time from the tweet"
  tag "twitter:tweets:tweet:date" do |tag|
    tweet = tag.locals.tweet
    if tag.attr['format']
      Time.parse(tweet['created_at']).strftime(tag.attr['format'])
    else
      tweet['created_at']
    end
  end

  desc "Returns the url from the tweet"
  tag "twitter:tweets:tweet:url" do |tag|
    tweet = tag.locals.tweet

    "http://www.twitter.com/#{tweet['from_user']}/statuses/#{tweet['id']}"
  end

  desc "Returns the url from the tweet"
  tag "twitter:tweets:tweet:user" do |tag|
    tweet = tag.locals.tweet
    tweet['from_user']
  end

  desc "Returns the url from the tweet"
  tag "twitter:tweets:tweet:user_url" do |tag|
    tweet = tag.locals.tweet
    "http://www.twitter.com/#{tweet['from_user']}"
  end
end
