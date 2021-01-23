#Start generate WLAN Controller
def generate_infrastructure_wlancontroller(controller_count, wlan_count)

    #Define constants
    type = "WlanDevice"
    charset = ('0'..'9').to_a + ('a'..'f').to_a
 
    #List of Controllers, only Ruckus so far has WLAN management, add more later
    controller_names = Array[
        {:name => "Ruckus Virtual SmartZone", :device => "ruckos",
             :apcount => 3, :apname => "Ruckus R720", :apmac => "ec58ea"}
     ]

    #SSID names
    ssid_names = %w(Pool_Network Convention_Center Lobby_Network Thai_Restaurant Sports_Bar)

    #If count is not specified, default to 1
    controller_count = 1 if controller_count.nil?
    wlan_count = 1 if wlan_count.nil?

    #Looks for id of last device and sets as host, if no previous device default 0
    begin
        host = InfrastructureDevice.last.id
    rescue
        host = 0
    end
    
    #Starts creating controller devices
    controller_count.times {

        #Keep track of host and pick a random switch
        host += 1
        controller_names_index = rand(controller_names.length)

        #Create new Controller
        s = InfrastructureDevice.new(
        :name => "[#{host}] " + controller_names[controller_names_index][:name],
        :type => type,
        :host => "192.168.60." + host.to_s,
        :device => controller_names[controller_names_index][:device],
        :created_by => $curr_user,
        :updated_by => $curr_user,
        :protocol => "ssh_coa",
        :username => "admin"
        )
        s.save!

        #Create AP based on count of controller
        controller_names[controller_names_index][:apcount].times {
        
        apmac_end = charset.shuffle!.join[0...6]
        ap = AccessPoint.new(
            :infrastructure_device_id => InfrastructureDevice.last.id,
            :name => controller_names[controller_names_index][:apname],
            :mac => controller_names[controller_names_index][:apmac] + apmac_end.to_s,
        )
        #If unlikely conflict in mac address just skip
        begin
            ap.save!
        rescue
            next
        end
        }
    }

    wlan_count.times {
        ssid_name = ssid_names[rand(ssid_names.length)]
        w = Wlan.new(
            :name => ssid_name,
            :ssid => ssid_name,
            :infrastructure_device_id => InfrastructureDevice.last.id,
            :encryption => "none",
            :authentication => "none"
        )
        #In conflict of SSID, skip
        begin
            w.save!
        rescue
            next
        end
        
    }
end


#Start generate switches
def generate_infrastructure_switch(switch_count)

    #Define type of device as a switch
    type = "SwitchDevice"

    #List of switches
    switch_names = Array[
        {:name => "Cisco Catalyst 9000", :device => "ciscoios", :ports => 16},
        {:name => "Juniper EX4200", :device => "juniperex", :ports => 16},
        {:name => "Ruckus ICX", :device => "ruckusicx", :ports => 16}
    ]

    #If switch count is not specified, default to 1
    switch_count = 1 if switch_count.nil?

    #Looks for id of last device and sets as host, if no previous device default 0
    begin
        host = InfrastructureDevice.last.id
    rescue
        host = 0
    end
    
    #Starts creating switch devices
    switch_count.times {

        #Keep track of host and pick a random switch
        host += 1
        switch_names_index = rand(switch_names.length)

        #Create new switch
        s = InfrastructureDevice.new(
        :name => "[#{host}] " + switch_names[switch_names_index][:name],
        :type => type,
        :host => "192.168.60." + host.to_s,
        :device => switch_names[switch_names_index][:device],
        :created_by => $curr_user,
        :updated_by => $curr_user,
        :protocol => "ssh_coa",
        :username => "admin"
        )
        s.save!

        #Create ports based on port count of switch
        switch_names[switch_names_index][:ports].times {

        |n|
        p = SwitchPort.new(
            :infrastructure_device_id => InfrastructureDevice.last.id,
            :name => "ethernet1/1/" + (n + 1).to_s,
            :port => "ethernet1/1/" + (n + 1).to_s,
            :speed_in_bps => 125000000,
            :link_speed => 1000,
            :shutdown => false
        )
        p.save!
        }
    }
end