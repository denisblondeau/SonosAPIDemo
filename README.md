# Sonos API Demo

This Swift/SwiftUI (MacOS) demo uses unsupported (i.e. unofficial) Sonos API requests to access Sonos devices on the local network. 

The Sonos API package needs to be installed - it is available here: https://github.com/denisblondeau/SonosAPI

* Install the latest released (i.e. most stable) Sonos API package - the main branch is not as stable.

This demo:
- Retrieves all Sonos devices on the local network.
- Displays the groups (consisting of Sonos speakers/devices) in the local household.
- Displays the media image for the selected group with various details (e.g. track title, track length, etc.)
- Subscribes to Sonos events (e.g. volume change, etc.). To test it out:
    1) Select a Sonos group in the demo. 
    2) Launch the Sonos application on your mobile device and select the same group that you selected in the demo.
    3) Changing the volume in the Sonos application on your mobile device will automatically adjust the volume in the demo application.


Before running this demo, do not forget to set the callback URL in SonosModel. If everything is well, the demo will display something like what you see in "Sample.jpg"


Testing environment:
 - MacOS 14.2.1
 - Xcode 15.2



