#!/usr/bin/env ruby

#
# Created by Franco Mattos
# github.com/francomattos
#
# This tool is used to generate an artificial environment inside the rXg
# See the help menu for more information: generate --help
#

require 'excon'
require 'json'
require_relative 'lib/rXg_API'

# Configure a static device address and API key here
# Device address format example: https://google.com
# device_address = ''
# api_key = ''

# rXg production environments should ALWAYS have a valid ssl certificate
# If no valid ssl certificate for device uncomment line below
# Excon.defaults[:ssl_verify_peer] = false

if ['help', '--help', '-h'].include?(ARGV[0])
  puts '
    This program will generate an artificial evironemnt for an rXg device
    You must enter the FQDN and API key each time, or statically configure inside script
    Syntax use: generate object count
    You may enter many objects in a single line
    Using command without any arguments runs default configuration

    Supported objects:
    | admin | account | certificate | switch | wlan |
    '
  exit!
elsif ARGV.length.odd?
  puts 'Invalid format, you must define object and how many to create. type generate --help for help menu.'
  exit!
end

# device_address and api_key statically configured above, if not then it must be initialized to nil
rxg_generator = RxgAPI.new(device_address ||= nil, api_key ||= nil)

# You may customize a default configuration here
if ARGV.empty?
  rxg_generator.create_account_group(1)
  rxg_generator.create_account(3)
  rxg_generator.create_device(3)
  rxg_generator.create_admin(2)
  rxg_generator.create_certificate(1)
  rxg_generator.create_cert_signing_req(1)
  rxg_generator.create_switch(4)
  rxg_generator.create_wlan_controller(2)
  rxg_generator.create_wlan(2)
  rxg_generator.create_access_point(2)
  exit!
end

ARGV.each_index do |i|
  next if ARGV[i].to_i != 0 # If value is a number, skip
  next if ARGV[i + 1].to_i <= 0 # If next device is not a number or negative number, skip

  object_name = ARGV[i]
  create_count = ARGV[i + 1].to_i

  case object_name.downcase
  when 'account'
    rxg_generator.create_account_group(1)
    rxg_generator.create_account(create_count)
    rxg_generator.create_device(create_count)
    puts "Request for: #{create_count}, created account group, accounts, and devices"
  when 'admin'
    rxg_generator.create_admin(create_count)
    puts "Request for: #{create_count}, created admins"
  when 'certificate'
    rxg_generator.create_certificate(create_count)
    rxg_generator.create_cert_signing_req(create_count)
    puts "Request for: #{create_count}, created certificate and certificate sgining request"
  when 'switch'
    rxg_generator.create_switch(create_count)
    puts "Request for: #{create_count}, created switch"
  when 'wlan'
    rxg_generator.create_wlan_controller(create_count)
    rxg_generator.create_wlan(create_count)
    rxg_generator.create_access_point(create_count)
    puts "Request for: #{create_count}, controllers, access points, and wlans"
  else
    puts "Automatic generation for #{object_name} is not yet supported."
    next
  end

end
