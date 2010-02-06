require "rubygems"
require 'twitter'

class SearchRT
  attr_accessor :id, :pass, :query

  def initialize(id, pass)
    @id = id
    @pass = pass
  end
  
  def retweet(query)
    @query = query
    
    search()
  end
  
  def search()
    Twitter::Search.new(@query).each do |r|
      # puts r["from_user"]
      # puts r["text"]
      post_twitter(r["from_user"], r["text"])
    end
  end
  
  def post_twitter(user, text)
    msg = makeMessage(user, text)

    # httpauth = Twitter::HTTPAuth.new(@id, @pass)
    # twit = Twitter::Base.new(httpauth)
    # twit.update(makeMessage(msg))
    puts msg.split(//u).length
    puts msg
  end
  
  def makeMessage(user, text)
    msg = "RT @" + user + " " + text + " #tback"

    # 140文字以内に切り取る
    if msg.split(//u).length > 140 then
      while msg.split(//u).length > 140
        text = text.split(//u)[0..-2].join
        msg = "RT @" + user + " " + text + " #tback"
      end
    end

    return msg
  end
end

rt = SearchRT.new("tback_bot", "19805525")
# 自分のbotが引っかかりまくるからやめた
# rt.retweet("tback")
rt.retweet("tバック")
