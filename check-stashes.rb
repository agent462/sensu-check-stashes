require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'net/https'
require 'uri'
require "json"

class SilencedCheck < Sensu::Plugin::Check::CLI
  option :api,
    :short => "-a URL",
    :long => "--api URL",
    :description => "sensu api url",
    :default => "http://localhost:4567"

  option :user,
    :short => "-u USER",
    :long => "--user USER",
    :description => "sensu api user"

  option :password,
    :short => "-p PASSOWRD",
    :long => "--password PASSWORD",
    :description => "sensu api password"

  def api_request(resource,method)
    uri = URI.parse(config[:api] + resource)
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 15
    http.open_timeout = 5
    if uri.scheme == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    case method
    when 'Get'
      req =  Net::HTTP::Get.new(uri.request_uri)
    when 'Delete'
      req =  Net::HTTP::Delete.new(uri.request_uri)
    end
    req.basic_auth(config[:user], config[:password]) if config[:user] && config[:password]
    begin
      http.request(req)
    rescue Timeout::Error
      puts "HTTP request has timed out."
      exit
    rescue StandardError => e
      puts "An HTTP error occurred. #{e}"
      exit
    end
  end

  def get_stashes
    resource = "/stashes"
    method = "Get"
    res = api_request(resource,method)
    response?(res.code) ? JSON.parse(res.body, :symbolize_names => true) : (warning "Failed to get stashes")
  end

  def response?(code)
    case code
    when '200'
      true
    when '204'
      true
    else
      false
    end
  end

  def delete_stash(path)
    resource = "/stashes/#{path}"
    method = "Delete"
    res = api_request(resource,method)
    response?(res.code) ? (puts "STASH: #{resource} was deleted") : (warning "Deletion of #{resource} failed.")
  end

  def process_stashes(stashes)
    stashes.each do |s|
      if s[:path].include?("silence")
        if s[:content].has_key?(:expires)
          delete_stash(s[:path]) if s[:content][:expires].to_i < Time.now.to_i
        end
      end
    end
  end

  def run
    stashes = get_stashes
    process_stashes(stashes)
    ok "Stashes have been processed"
  end

end
