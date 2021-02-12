require_relative 'class_constant_variables'
# Methods are found on separate files based on menu item they manage
require_relative 'identities'
require_relative 'network'
require_relative 'system'

# This is the main class for configuring remotely using the rXg API
class RxgAPI
  include ClassConstantVariables # Constant variables defined in another file
  # These are the create methods
  include Network
  include Identities
  include System

  # Looks to see if device is statically configured, if not then call the set methods
  def initialize
    # API support utilizes excon, if it isn't found an error will be raised
    require 'excon'

    # rXg production environments should ALWAYS have a valid certificate
    # If no valid certificate for device uncomment line below
    # Excon.defaults[:ssl_verify_peer] = false

    # Configure a static device address and API key here
    # Device address format example: https://google.com
    @device_address = set_device_address
    @device_api_key = set_api_key(@device_address)
  end

  # Invoked if device address is not defined, validates connection.
  def set_device_address
    address_input = nil

    while address_input.nil?
      puts 'Enter device address (e.g.: https://google.com):'
      begin
        Excon.get($stdin.gets.chomp!, connect_timeout: 15)
      rescue StandardError
        puts 'Unable to connect to device, please check the address.'
      else
        address_input = $_
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
        api_key_input = $_
      else
        puts 'Invalid key.'
      end
    end

    api_key_input
  end

  # Connects to API and delivers payload via post
  # Uses threads for parallel processing of post requests
  def create_entry(payload_array, scaffold)
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
  def get_table(scaffold, **filters)
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
