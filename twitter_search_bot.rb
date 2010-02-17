require "rubygems"
require 'twitter'
require 'time'

class SearchRT
  attr_accessor :id, :pass, :time, :hash, :query

  def initialize(id, pass)
    @id = id
    @pass = pass
  end
  
  def retweet(query)
    @query = query
    
    search()
    
    return self
  end
  
  def setCronTime(time)
    @time = time
    
    return self
  end
  
  def setHashTag(hash)
    @hash = hash

    return self
  end
  
  private
  def search()
    Twitter::Search.new(@query).each do |data|
      post_twitter(data)
    end
  end
  
  def post_twitter(user)
    # cronの指定時間以降にPostされたtweetではない場合
    if !isPost(user.created_at) then
      return
    end

    # RTという文字が入っている場合
    if isRT(user.text) then
      return
    end

    # 自分自身の場合
    if isSelf(user.from_user) then
      return
    end

    msg = makeMessage(user.from_user, user.text)
    # puts msg

    httpauth = Twitter::HTTPAuth.new(@id, @pass)
    twit = Twitter::Base.new(httpauth)
    twit.update(msg)
  end
  
  def isPost(date)
    hour = @time
    now = Time.at(Time.now) - hour
    created = Time.parse(date)

    # 指定の時間前ならtrueを返す
    if created.to_i > now.to_i
      return true
    end
    
    return false
  end

  def isRT(text)
    return text.include?("RT")
  end
  
  def isSelf(user)
    return @id == user
  end
  
  def makeMessage(user, text)
    msg = "RT @" + user + " " + text + " #" + @query

    # 140文字以内に切り取る
    if msg.split(//u).length > 140 then
      while msg.split(//u).length > 140
        text = text.split(//u)[0..-2].join
        msg = "RT @" + user + " " + text + " #" + @query
      end
    end

    return msg
  end
end

rt = SearchRT.new("tback_bot", "19805525")
rt.
  setCronTime(3500).
  setHashTag("tback").
  retweet("tバック")
