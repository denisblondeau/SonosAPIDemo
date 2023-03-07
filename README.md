# SonosAPIDemo

This Swift/SwiftUI (MacOS) demo uses unsupported (i.e. unofficial) Sonos API requests to access Sonos devices on the local network. 

Really useful information that I used regarding the unofficial API: https://svrooij.io/sonos-api-docs/

If you are interested - How to get started with the official Sonos API: https://developer.sonos.com
The issue with the official API is that you need to send network requests to Sonos's servers - i.e. it is a not a local network API. So this incurs network latency, uses your Internet bandwidth, requires setting up a web server, etc, etc. Works really well but painful to use.

Note: As this uses an unofficial API, this application may break at any time. You may have to tweak the different Sonos models (e.g. AVTransport, GroupRenderingControl, etc.). The network data retrieved is in XML, converted to JSON and then decoded to Swift structures. There is a lot of custom code and the XML conversion is not as reliable as it should be.

This demo:
- Retrieves all Sonos devices on the local network.
- Display the groups (consisting of Sonos speakers) in the local household.
- Display the media image for the selected zone with various details (e.g. track title, track length, etc.)
- Subscribe to Sonos events (e.g. volume change, etc.)

This demo is functional but currently only implements a few of the available API calls. 


Testing environment:
 - MacOS 13.1
 - Xcode 14.2



