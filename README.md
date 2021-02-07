# Ruby - rXg device generator

Ruby interface for generating objects to be emulated inside the rXg interface.

The tools folder includes a generator to be installed and run inside the rXg shell.

The API folder utilizes the RESTful API of the rXg and runs remotely. Prior to using the API tool, you must retreive your API key.
Go to System > Admin, select your user and click Show, retreive your API key.

## Installation

The API interface utilizes excon, it must be added as a gem:

`gem install excon `

## API tool quick tutorial

The API tool uses the following syntax:

`generate object count`

To bring up the help menu including the list of supported obejcts, use:

`generate --help`

Multiple devices can be created in one line.

`generate switch 5 controller 2`

This command will create 5 switches and 2 controllers.

Some objects may create other related objects in the process, for example, a controller creates access points and an SSID.
