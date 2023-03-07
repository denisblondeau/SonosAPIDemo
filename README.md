# Sonos API Demo

This Swift/SwiftUI (MacOS) demo uses unsupported (i.e. unofficial) Sonos API requests to access Sonos devices on the local network. 

Really useful information regarding the unofficial API: https://svrooij.io/sonos-api-docs/

If you are interested... How to get started with the official Sonos API: https://developer.sonos.com
The issue with the official API is that you need to send network requests to Sonos's servers - i.e. it is a not a local network API. So this incurs network latency, uses your Internet bandwidth, requires setting up a web server, etc, etc. Works really well but painful to use.

* As this uses an unofficial API, the demo may break at any time. You may have to tweak the different Sonos models (e.g. AVTransport, GroupRenderingControl, etc.). The network data retrieved is in XML, converted to JSON and then decoded to Swift structures. There is a lot of custom code to do this and the XML conversion is currently not as reliable as it should be.

This demo:
- Retrieves all Sonos devices on the local network.
- Displays the groups (consisting of Sonos speakers/devices) in the local household.
- Displays the media image for the selected group with various details (e.g. track title, track length, etc.)
- Subscribes to Sonos events (e.g. volume change, etc.). To test it out:
    1) Select a Sonos group in the demo. 
    2) Launch the Sonos application on your mobile device and select the same group that you selected in the demo.
    3) Changing the volume in the Sonos application on your mobile device will automatically adjust the volume in the demo application.

This demo is functional but currently only implements a few of the available API calls; there is a lot more that can be done (e.g. changing volume, tracks, etc.)

Before running this demo, do not forget to set the callback URL in SonosModel. If everything is well, the demo will display something like what you see in "Sample.jpg"


Testing environment:
 - MacOS 13.1
 - Xcode 14.2



