# DnsFlare
Agent to wrap Cloudflare's API to update DNS records for dynamic IPs

To configure:
- Modify cloudflare.yaml.example with your information
- Rename cloudflare.yaml.example cloudflare.yaml
- Create a /var/scripts directory
- Move cloudflare.rb and cloudflare.yaml to /var/scripts
- Make them owned, executable, and viewable by root only
- Create a root cronjob -e '*/10 * * * * /var/scripts/cloudflare.rb'
