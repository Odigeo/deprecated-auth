class Rack::Attack

  ### Configure Cache ###

  Rack::Attack.cache.store = ActiveSupport::Cache::MemCacheStore.new(*MEMCACHED_SERVERS)


  ### Throttle Spammy Clients ###

  # If any single client IP is making tons of requests, then they're
  # probably malicious or a poorly-configured scraper. Either way, they
  # don't deserve to hog all of the app server's CPU. Cut them off!

  # Throttle all requests by IP (60rpm)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  throttle('req/ip', :limit => 300, :period => 5.minutes) do |req|
    req.ip
  end


  ### Custom Throttle Response ###

  self.throttled_response = lambda do |env|
   [ 429,                                 # status
     {'Content' => 'application/json'},   # headers
     ['']]                                # body
  end
end
