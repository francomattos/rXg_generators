# This is the main class for handling rXg api requests from the code using JSON
# It first validates and expands the definition of the device address and API
# One function is used to deliver payload, another to get body of page
# Individual functions are used for each object it creates

class RxgAPI

  def initialize(address, key)
    address = set_device_address() if address.nil?
    key = set_api_key(address) if key.nil?

    @device_address = "#{address}/admin/scaffolds/"
    @device_api_key = "?api_key=#{key}"
    @switch_pool = Array[
      { name: 'Cisco Catalyst 9000', device: 'ciscoios', ports: 16 },
      { name: 'Juniper EX4200', device: 'juniperex', ports: 16 },
      { name: 'Ruckus ICX', device: 'ruckusicx', ports: 16 }
    ]
    @ssid_pool = ['Pool_Network', 'Convention_Center', 'Lobby_Network', 'Thai_Restaurant', 'Sports_Bar']
    @controller_pool = Array[
      { name: 'Ruckus Virtual SmartZone', device: 'ruckos',
        apcount: 3, apname: 'Ruckus R720', apmac: 'ec58ea' }
    ]
  end

  def set_device_address()
    address_input = nil

    while address_input.nil?
      puts 'Enter device address (e.g.: https://google.com):'
      begin
        Excon.get(STDIN.gets.chomp!, connect_timeout: 5)
      rescue 
        puts 'Unable to connect to device, please check the address.'
      else
        address_input = $_
      end
    end
    return address_input
  end

  def set_api_key(address)
    api_key_input = nil

    while api_key_input.nil?
      puts 'Enter your API key.'
      puts 'API key can be found at System > Admin, select your user and click Show.'
      get_response = Excon.get("#{address}/admin/scaffolds/switch_devices/index.json?api_key=#{STDIN.gets.chomp!}")
      if get_response.status === 200
        api_key_input = $_ 
      else
        puts 'Invalid key.'
      end
    end
    return api_key_input
  end

  # Connects to API and delivers payload via post
  # Uses threads for parallel processing of post requests
  def api_post(payload_array, scaffold)
    api_url = "#{@device_address}#{scaffold}/create.json#{@device_api_key}"
    api_connection = Excon.new(api_url, persistent: true)
    threads = []

    payload_array.each do |payload|
      threads << Thread.new do
        api_connection.post(
          body: '{ "record":' + payload.to_json + '}',
          headers: { 'Content-Type' => 'application/json' },
          persistent: true
        )
      end
    end
    threads.each(&:join)
  end

  def api_get_body(scaffold)
    get_url = "#{@device_address}#{scaffold}/index.json#{@device_api_key}"
    return JSON.parse(Excon.get(get_url).body)
  end
  
  # Creates switches, switchport creation via API is not currently supported
  def create_switch(switch_count)
    type = 'SwitchDevice' # Very important, needs to specify to infrastructure what type of device to use
    scaffold = 'switch_devices'
    switch_id = api_get_body(scaffold).length

    # Creates payload as array of hashes to be sent via API
    payload = []
    switch_count.times do
      switch_id += 1
      switch_pool_index = rand(@switch_pool.length)
      payload.push({
        name: "[#{switch_id}] #{@switch_pool[switch_pool_index][:name]}", # Prepends ID so names are unique
        type: type,
        host: "192.168.10.#{switch_id}", # IP must be unique
        device: @switch_pool[switch_pool_index][:device],
        protocol: 'ssh_coa',
        username: 'admin'
      })
    end

    api_post(payload, scaffold)
  end

  def create_wlan_controller(controller_count)
    type = 'WlanDevice' # Very important, needs to specify to infrastructure what type of device to use
    scaffold = 'wlan_devices'
    controller_id = api_get_body(scaffold).length

    # Creates payload as array of hashes to be sent via API
    payload = []
    controller_count.times do
      controller_id += 1
      controller_pool_index = rand(@controller_pool.length)
      payload.push({
        name: "[#{controller_id}] " + @controller_pool[controller_pool_index][:name], # Prepends ID so names are unique
        type: type,
        host: '192.168.20.' + controller_id.to_s,
        device: @controller_pool[controller_pool_index][:device],
        created_by: $curr_user,
        updated_by: $curr_user,
        protocol: 'ssh_coa',
        username: 'admin'
      })
    end

    api_post(payload, scaffold)
  end

  def create_wlan(wlan_count)
    controller_array = api_get_body('wlan_devices').last(wlan_count)
    scaffold = 'wlans'
    payload = []

    controller_array.each do |controller_object|
      controller_id = controller_object['id'] # SSID must be tied into the ID of the controller
      ssid_name = @ssid_pool[rand(@ssid_pool.length)]

      payload.push({
        name: ssid_name,
        ssid: ssid_name,
        infrastructure_device: controller_id,
        encryption: 'none',
        authentication: 'none'
      })
    end

    api_post(payload, scaffold)
  end

  def create_access_point(wlan_count)
    controller_array = api_get_body('wlan_devices').last(wlan_count)
    scaffold = 'access_points'
    charset = ('0'..'9').to_a + ('a'..'f').to_a 
    payload = []

    controller_array.each do |controller_object|
      controller_id = controller_object['id']
      controller_name = controller_object['name'].split(' ')[1..-1].join(' ') # Finds the name of the controller, removing the [number] at beginning
      controller = @controller_pool.find { |c| c[:name] == controller_name }

      # AP count is based on number defined on controller pool, not the count passed by user input
      controller[:apcount].times do 
        ap_mac_end = charset.shuffle!.join[0...6] # Random values to append to mac address

        payload.push({
          infrastructure_device: controller_id,
          name: controller[:apname],
          mac: controller[:apmac] + ap_mac_end # Mac address must be unique
        })
      end
    end

    api_post(payload, scaffold)
  end
end
