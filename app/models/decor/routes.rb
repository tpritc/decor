module Decor; end

class Decor::Routes
  def self.host
    ENV.fetch("HOST_URL", "localhost:3000")
  end

  def self.protocol
    host.start_with?("localhost") ? "http" : "https"
  end

  def self.host_with_protocol
    "#{protocol}://#{host}"
  end
end
