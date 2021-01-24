# This is the main class for handling rXg api requests from the code
class Rxg_API

  # Receives host address and api keys from main and converts it to format used by class
  def initialize(address, api_key)
    @device_address = address + '/admin/scaffolds/'
    @device_api_key = '?api_key=' + api_key
  end

  # Method to connect to rXg API and deliver payload
  def generate(payload_array, object_type)
    post_url = @device_address + object_type + '/create.json' + @device_api_key

    # Initiates a connection to be used for requests
    api_connection = Excon.new(post_url, :persistent => true)

    # Creates a thread array to keep requests concurrent
    threads = []

    # Cycles through the payload and creates a thread with the post request to API
    payload_array.each do |payload|
      threads << Thread.new { 
      api_connection.post( 
      :body => '{ "record":' + payload.to_json + '}',
      :headers => {'Content-Type' => 'application/json'},
      :persistent => true
      )}
    end
    threads.each(&:join)
  end

  # Method for creating switches, receives number of device to create as argument
  def create_switch(switch_count)
    get_url = @device_address + 'switch_devices/index.json' + @device_api_key
    object_type = "switch_devices"

    # Very important, needs to specify to infrastructure what type of device to use
    type = 'SwitchDevice'

    # Creates a database of switch devices to be created with amount of ports
    switch_names = Array[
        { name: 'Cisco Catalyst 9000', device: 'ciscoios', ports: 16 },
        { name: 'Juniper EX4200', device: 'juniperex', ports: 16 },
        { name: 'Ruckus ICX', device: 'ruckusicx', ports: 16 }
    ]

    # Retreives list of switch devices, and gets the count to set as host and label
    host = JSON.parse(Excon.get(get_url).body).length

    # Creates payload for switch device to be sent via API
    payload = []
    switch_count.times do
      host += 1
      switch_names_index = rand(switch_names.length)
      payload.push({
                     name: "[#{host}] #{switch_names[switch_names_index][:name]}",
                     type: type,
                     host: "192.168.60.#{host.to_s}",
                     device: switch_names[switch_names_index][:device],
                     protocol: 'ssh_coa',
                     username: 'admin'
                   })
    end

    # Sends post request to create switch with payload
    self.generate(payload, object_type)
  end

  def generate_wlan_controller(controller_count)
    get_url = @device_address + 'wlan_devices/index.json' + @device_api_key
    object_type = "wlan_devices"

    # Very important, needs to specify to infrastructure what type of device to use
    type = "WlanDevice"
    charset = ('0'..'9').to_a + ('a'..'f').to_a
    #SSID name pool
    ssid_names = %w(Pool_Network Convention_Center Lobby_Network Thai_Restaurant Sports_Bar)

    # Creates a database of controllers to be created
    controller_names = Array[
      {:name => "Ruckus Virtual SmartZone", :device => "ruckos",
           :apcount => 3, :apname => "Ruckus R720", :apmac => "ec58ea"}
   ]

    # Retreives list of controllers, and gets the count to set as host and label
    host = JSON.parse(Excon.get(get_url).body).length

    # Creates payload for wlan controllers to be sent via API
    payload = []
    controller_count.times do
      host += 1
      controller_names_index = rand(controller_names.length)

      payload.push({
        name: "[#{host}] " + controller_names[controller_names_index][:name],
        type: type,
        host: "192.168.60." + host.to_s,
        device: controller_names[controller_names_index][:device],
        created_by: $curr_user,
        updated_by: $curr_user,
        protocol: "ssh_coa",
        username: "admin"
                   })
    end

    # Sends post request to create controller with payload
    self.generate(payload, object_type)

    # Retreives list of all controllers
    controllers = JSON.parse(Excon.get(get_url).body)
    
    # Goes through the controllers created in reverse order
    controllers.reverse.take(payload.length).each do |x|
      # Finds the name of the controller, removing the [number] at beginning
      controller_name = x["name"].split(' ')[1..-1].join(' ')
      controller_id = x["id"]

      # Gets the object that matches the controller name
      controller_object = controller_names.find{|controller_list| controller_list[:name] == controller_name}
      ap_mac_end = charset.shuffle!.join[0...6]

      # Creates payload for access points based on count defined in controller
      payload = []
      controller_object[:apcount].times do |n|
        payload.push({
          infrastructure_device: controller_id,
          name: controller_object[:apname],
          mac: controller_object[:apmac] + ap_mac_end
        })
      end

      # Sends post request to create access points with payload
      self.generate(payload, "access_points")

      # Generates one SSID per controller
      ssid_name = ssid_names[rand(ssid_names.length)]
      payload = [{
        name: ssid_name,
        ssid: ssid_name,
        infrastructure_device: controller_id,
        encryption: "none",
        authentication: "none"}]

      # Sends post request to create SSD with payload
      self.generate(payload, "wlans")
    end
  end





end
