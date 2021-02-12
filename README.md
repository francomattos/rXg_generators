# Ruby - rXg device generator

Ruby interface for generating objects to be emulated inside the rXg interface.

The generator can be launched from inside the tools folder of the rXg, which will generate the objects locally using the Rails console.

It can also be launched from an external device, which will then connect via API to a remote rXg. Prior to using remotely, you must retreive your API key.
Go to System > Admin, select your user and click Show, retreive your API key.

## Installation

If used from a remote device, the excon gem must be installed:

`gem install excon `

If used locally, install the app on the space/rxg/console/tools/ folder inside the rxg.

## Quick tutorial

The tool uses the following syntax:

`generate object count`

To bring up the help menu including the list of supported obejcts, use:

`generate --help`

If used without any arguments, a default configuration will be executed:

`generate`

Multiple devices can be created in one line.

`generate switch 5 controller 2`

This command will create 5 switches and 2 controllers.

Some objects may create other related objects in the process, for example, a controller creates access points and an SSID.

## Customization

Insite the generate.rb file, you can customize the default configuration

Inside lib/rxg_api.rb, you can statically configure the device address and API key.
If the device does not have a valid certificate installed, you may disable ssl certificate verify here as well. If you are entering the correct device address and it fails to connect, this may be the issue.
