# frozen_string_literal: true

# This contains constants used to create the multiple objects, feel free to expand or customize to your liking
module ClassConstantVariables
  ACCOUNT_GROUP_POOL = %w[Business Residential Hotspot Guests Free].freeze
  ALPHANUMERIC_CHARSET = ('A'..'Z').to_a + ('0'..'9').to_a + ('a'..'z').to_a.freeze
  CONTROLLER_POOL = [{
    name: 'Ruckus Virtual SmartZone', device: 'ruckos', apcount: 3, apname: 'Ruckus R720', apmac: 'ec58ea'}].freeze
  DEPARTMENT_POOL = %w[Legal Finance Engineering Support Sales Marketing Communications
    Research].freeze
  DEVICE_POOL = ['Toshiba Laptop', 'Dell Laptop', 'Sony Laptop', 'Asus Laptop', 'Nvidia Shield TV', 'Roku TV', 'iPad',
    'Macbook Pro', 'Macbook Air', 'Playstation 3', 'XBox One', 'iPhone', 'Samsung Galaxy', 'Samsung Galaxy Tab',
    'Amazon Fire HD', 'Amazon Alexa'].freeze
  EMAIL_DOMAIN_POOL = %w[aol.com bellsouth.net btinternet.com charter.net comcast.net cox.net earthlink.netgmail.com
    hotmail.co.uk hotmail.com msn.com ntlworld.com rediffmail.com sbcglobal.net shaw.ca verizon.net yahoo.ca yahoo.co.in
    yahoo.co.uk yahoo.com].freeze
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
  MACHINE_NAME_POOL = %w[east west north south gateway wifi node login].freeze
  SSID_POOL = %w[Pool_Network Convention_Center Lobby_Network Thai_Restaurant Sports_Bar].freeze
  SWITCH_POOL = [
    { name: 'Cisco Catalyst 9000', device: 'ciscoios', ports: 16 },
    { name: 'Juniper EX4200', device: 'juniperex', ports: 16 },
    { name: 'Ruckus ICX', device: 'ruckusicx', ports: 16 }
  ].freeze
end
