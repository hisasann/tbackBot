require "rubygems"
require 'twitter'
require 'time'

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
  
  private
  def search()
    Twitter::Search.new(@query).each do |data|
      post_twitter(data)
    end
  end
  
  def post_twitter(user)
    if !isPost(user.created_at) then
      return
    end

    msg = makeMessage(user.from_user, user.text)
    # puts msg.split(//u).length  # debug
    # puts msg

    httpauth = Twitter::HTTPAuth.new(@id, @pass)
    twit = Twitter::Base.new(httpauth)
    twit.update(msg)
  end
  
  def isPost(date)
    hour = 3600 # 1時間前
    now = Time.at(Time.now) - hour
    created = Time.parse(date)
    
    # puts now        # debug
    # puts created

    # 指定の時間前ならtrueを返す
    if created.to_i > now.to_i
      return true
    end
    
    return false
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
