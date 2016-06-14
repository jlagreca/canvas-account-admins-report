# Edit these:
access_token = ''
domain = ''  #only need the subdomain
env = nil #test, beta or nil
filename = 'example.csv'
#============
# Don't edit from here down unless you know what you're doing.

require 'unirest'
require 'csv'
require 'json'
require 'open-uri'
require 'fileutils'
require "net/http"


unless access_token
  puts "what is your access token?"
  access_token = gets.chomp
end

unless domain
  puts "what is your Canvas domain?"
  domain = gets.chomp
end


env ? env << "." : env
base_url = "https://#{domain}.#{env}instructure.com/api/v1"

# Make generic API call to test token, domain, and env.

  url ="#{base_url}/accounts/"
  list_accounts = Unirest.get(url, headers: { "Authorization" => "Bearer #{access_token}" }) 
  job = list_accounts.body
  headers = ["account_id", "account_name", "account_sis_id", "admin_id", "role","role_id", "user_id", "user_name"]
  CSV.open("#{filename}", "w") do |csv| #open new file for write
                  csv << headers
                end
#commented out from here. lets focus on the folders first

    job.each do |account|

          data = []
          aid = account["id"]
          aname = account["name"]
          asisid = account["sis_account_id"]
          adminsurl ="#{base_url}/accounts/#{aid}/admins?per_page=100"
          list_admins = Unirest.get(adminsurl, headers: { "Authorization" => "Bearer #{access_token}" })
          admins = list_admins.body

          admins.each do |unique_admin|
          
              adminid=unique_admin["id"]
              role=unique_admin["role"]
              roleid=unique_admin["role_id"]
              userid=unique_admin["user"]["id"]
              username = unique_admin["user"]["name"]
              data = [aid, aname, asisid, adminid, role, roleid, userid, username]
              
                CSV.open("#{filename}", "a") do |csv| #open new file for write
                  csv << data #write value to file
                 
                end


          end

          
    end



puts "Successfully output list of Admins"

