# frozen_string_literal: true

# Methods are found on separate files based on menu item they manage
require_relative 'rxg_api/identities'
require_relative 'rxg_api/network'
require_relative 'rxg_api/system'

# This is the main class for handling rXg api requests from the code using JSON
# It first validates and expands the definition of the device address and API
# One function is used to deliver payload, another to get body of page
# Individual functions are used for each object it creates
class RxgAPI
  #These are the create methods 
  include Network
  include Identities
  include System

  SWITCH_POOL = [
    { name: 'Cisco Catalyst 9000', device: 'ciscoios', ports: 16 },
    { name: 'Juniper EX4200', device: 'juniperex', ports: 16 },
    { name: 'Ruckus ICX', device: 'ruckusicx', ports: 16 }
  ].freeze
  SSID_POOL = %w[Pool_Network Convention_Center Lobby_Network Thai_Restaurant Sports_Bar].freeze
  CONTROLLER_POOL = [{
    name: 'Ruckus Virtual SmartZone', device: 'ruckos', apcount: 3, apname: 'Ruckus R720', apmac: 'ec58ea'
  }].freeze
  ACCOUNT_GROUP_POOL = %w[Business Residential Hotspot Guests Free].freeze
  ALPHANUMERIC_CHARSET = ('A'..'Z').to_a + ('0'..'9').to_a + ('a'..'z').to_a.freeze
  HEXADECIMAL_CHARSET = ('0'..'9').to_a + ('a'..'f').to_a.freeze
  FIRST_NAME_POOL = %w[Aaron Abby Abigail Adam Addison Aiden Alexander Alexis Allison Alyssa Amanda Amelia Andrew
    Angelina Anna Anthony Arianna Ashley Audrey Austin Ava Avery Bailey Benjamin Blake Brady Brandon Brendan Brian
    Brody Brooke Bryce Caden Caleb Cameron Camryn Caroline Carson Carter Charlie Charlotte Chase Chloe Christian
    Christopher Claire Cole Colin Connor Cooper Daniel David Destiny Devin Dominic Drew Dylan Elijah Elizabeth
    Ella Ellie Emily Emma Eric Erin Ethan Evan Faith Gabriel Gavin Gianna Grace Gracie Hailey Hannah Hayden Henry
    Hunter Ian Isaac Isabelle Isaiah Jack Jackson Jacob Jake James Jasmine Jason Jayden Jenna Jessica John Jonathan
    Jordan Joseph Joshua Julia Justin Kaitlyn Katherine Katie Kayla Kaylee Keira Kevin Kyle Kylie Landon Lauren
    Layla Leah Liam Lillian Lily Logan Lucas Lucy Luke Mackenzie Madeline Madison Maggie Makayla Marissa Mason
    Matthew Max Maya Mckenna Megan Mia Michael Miles Molly Morgan Natalie Nathan Nevaeh Nicholas Nicole Noah Olivia
    Owen Paige Parker Patrick Peyton Rachel Rebecca Riley Robert Ryan Sam Samantha Samuel Sarah Savannah Sean Sebastian
    Seth Sophia Steven Sydney Taylor Thomas Trinity Tristan Tyler Victoria William Wyatt Xavier Zachary Zoe].freeze
  LAST_NAME_POOL = %w[Smith Johnson Williams Jones Brown Davis Miller Wilson Moore Taylor Anderson Thomas Jackson
    White Harris Martin Thompson Garcia Martinez Robinson Clark Rodriguez Lewis Lee Walker Hall Allen Young Hernandez
    King Wright Lopez Hill Scott Green Adams Baker Gonzalez Nelson Carter Mitchell Perez Roberts Turner Phillips
    Campbell Parker Evans Edwards Collins Stewart Sanchez Morris Rogers Reed Cook Morgan Bell Murphy Bailey Rivera
    Cooper Richardson Cox Howard Ward Torres Peterson Gray Ramirez James Watson Brooks Kelly Sanders Price Bennett
    Wood Barnes Ross Henderson Coleman Jenkins Perry Powell Long Patterson Hughes Flores Washington Butler Simmons
    Foster Gonzales Bryant Alexander Russell Griffin Diaz Hayes].freeze
  EMAIL_DOMAIN_POOL = %w[aol.com bellsouth.net btinternet.com charter.net comcast.net cox.net earthlink.netgmail.com
    hotmail.co.uk hotmail.com msn.com ntlworld.com rediffmail.com sbcglobal.net shaw.ca verizon.net yahoo.ca yahoo.co.in
    yahoo.co.uk yahoo.com].freeze
  DEPARTMENT_POOL = %w[Legal Finance Engineering Support Sales Marketing Communications
    Research].freeze
  MACHINE_NAME_POOL = %w[east west north south gateway wifi node login].freeze
  DEVICE_POOL = ['Toshiba Laptop', 'Dell Laptop', 'Sony Laptop', 'Asus Laptop', 'Nvidia Shield TV', 'Roku TV', 'iPad',
    'Macbook Pro', 'Macbook Air', 'Playstation 3', 'XBox One', 'iPhone', 'Samsung Galaxy', 'Samsung Galaxy Tab',
    'Amazon Fire HD', 'Amazon Alexa'].freeze

  # Looks to see if device is statically configured, if not then call the set methods
  def initialize(address, key)
    address = set_device_address if address.nil?
    key = set_api_key(address) if key.nil?

    @device_address = address
    @device_api_key = key
  end

  # Invoked if device address is not defined, validates connection.
  def set_device_address
    address_input = nil

    while address_input.nil?
      puts 'Enter device address (e.g.: https://google.com):'
      begin
        Excon.get($stdin.gets.chomp!, connect_timeout: 5)
      rescue StandardError
        puts 'Unable to connect to device, please check the address.'
      else
        address_input = $LAST_READ_LINE
      end
    end

    address_input
  end

  # Invoked if API key is not defined, check if response status is 200 for successful request
  def set_api_key(address)
    api_key_input = nil

    while api_key_input.nil?
      puts 'Enter your API key.'
      puts 'API key can be found at System > Admin, select your user and click Show.'
      get_response = Excon.get("#{address}/admin/scaffolds/switch_devices/index.json?api_key=#{$stdin.gets.chomp!}")

      if get_response.status === 200
        api_key_input = $LAST_READ_LINE
      else
        puts 'Invalid key.'
      end
    end

    api_key_input
  end

  # Connects to API and delivers payload via post
  # Uses threads for parallel processing of post requests
  def api_post(payload_array, scaffold)
    api_url = "#{@device_address}/admin/scaffolds/#{scaffold}/create.json?api_key=#{@device_api_key}"
    api_connection = Excon.new(api_url, persistent: true)

    payload_array.map do |payload|
      Thread.new do
        api_connection.post(
          body: JSON[record: payload],
          headers: { 'Content-Type' => 'application/json' },
          persistent: true
        )
      end
    end.each(&:join)
  end

  # Returns the body of get request, with option for passing a hash for filtering parameters
  def api_get_body(scaffold, **filters)
    get_url = "#{@device_address}/admin/scaffolds/#{scaffold}/index.json?api_key=#{@device_api_key}"
    json_body = JSON.parse(Excon.get(get_url).body)

    if filters.any?
      filters.each do |name, value|
        json_body.keep_if { |return_item| return_item[name.to_s] == value.to_s }
      end
    end

    json_body
  end
end
