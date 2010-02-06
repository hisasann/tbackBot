require "rubygems"
require "net/http"
require "rexml/document"
require 'twitter'

class RandomTumble
  attr_accessor :id, :tumblelog, :posts, :url

  def initialize(id)
    @@uri = id + '.tumblr.com'
    @id = id
  end
  
  def random_post_twitter(id, pass)
    random()
    post_twitter(id, pass)
  end
  
  def random
    Net::HTTP.start(@@uri, 80) {|http|
      request_tumblr(http, 0, 1, "photo")
      # p @tumblelog.attributes["name"]

      rand_page = rand(@posts.attributes["total"].to_i - 1)

      request_tumblr(http, rand_page, 1, "photo")
      @posts.each {|post|
        @url = post.attributes["url"]
      }
      # p @url
    }
  end
  
  def request_tumblr(http, start, num, type)
    req = getReq()
    req.set_form_data(getData(start, num, type))
    res = http.request(req)
    doc = nil
    if res.kind_of?(Net::HTTPSuccess)
      doc = REXML::Document.new(res.body)
    else
      raise ResponseError.new(res)
    end

    if doc
      @tumblelog = REXML::XPath.first(doc, "//tumblelog")
      @posts = REXML::XPath.first(doc, "//posts")
    end
  end
  
  def post_twitter(id, pass)
    httpauth = Twitter::HTTPAuth.new(id, pass)
    twit = Twitter::Base.new(httpauth)
    twit.update(makeMessage())
  end
  
  def getReq
    return Net::HTTP::Post.new("/api/read")
  end
  
  def getData(start, num, type)
    return {
      "start" => start,
      "num" => num,
      "type" => type
    }
  end

  def makeMessage
    time = Time.now.strftime("%Y/%m/%d %H時")
    return time + "の1枚->" + @url + " #tback"
  end
end

RandomTumble.new("tback").random_post_twitter("tback_bot", "19805525")

