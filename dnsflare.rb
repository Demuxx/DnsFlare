#!/usr/bin/env ruby
require 'json'
require 'net/http'
require 'yaml'
require 'logger'

logger = Logger.new('/var/log/dnsflare.log')
logger.level = Logger::warn

cloudflare_conf = YAML.load_file("/var/scripts/cloudflare.yaml")
username = cloudflare_conf["username"]
token = cloudflare_conf["token"]
tld = cloudflare_conf["tld"]
zones = cloudflare_conf["zones"]

icanhazipuri = URI("http://icanhazip.com")
local_ip = Net::HTTP.get(icanhazipuri).chomp("\n")
logger.debug "local ip #{local_ip}"

uri = URI("https://www.cloudflare.com/api_json.html")
logger.debug "request for all records token: #{token}, email: #{username}, tld: #{tld}"
response = Net::HTTP.post_form(uri, 'a' => 'rec_load_all', 'tkn' => token, 
  'email' => username, 'z' => tld).body
json = JSON.parse(response)
logger.debug "Json: #{json}"

for zone in zones
  current_ip = json["response"]["recs"]["objs"].select {|obj| obj["name"] == zone}.first["content"]
  logger.debug "current ip: #{current_ip}"
  if local_ip != current_ip
    logger.warn "Updating IP, current ip: #{current_ip}, new ip: #{local_ip}"
    rec_id = json["response"]["recs"]["objs"].select {|obj| obj["name"] == zone}.first["rec_id"]
    final_resp = Net::HTTP.post_form(uri, 'a' => 'rec_edit', 'tkn' => token, 
      'id' => rec_id, 'email' => username, 'z' => tld, 'type' => 'A', 'name' => zone,
      'content' => local_ip, 'service_mode' => '0', 'ttl' => '1')
  end
end
