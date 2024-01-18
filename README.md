<div align="center">

  <h1>Sonos API Demo</h1>
  
  <p>
    This Swift/SwiftUI (MacOS) demo uses unsupported (i.e. unofficial) Sonos API requests to access Sonos devices on the local network.

  </p>
  
  
<p>
  
  ![Static Badge](https://img.shields.io/badge/macOS-14%2B-greeen)
  ![Static Badge](https://img.shields.io/badge/Xcode-15%2B-blue)

</p>
</div>
<br />

## About the Project

This demo:

- Retrieves all Sonos devices on the local network.
- Displays the groups (consisting of Sonos speakers/devices) in the local household.
- Displays the media image for the selected group with various details (e.g. track title, track length, etc.)
- Subscribes to Sonos events (e.g. volume change, etc.)

### Prerequisites

- Before building/running this application, the Sonos API package needs to be installed: https://github.com/denisblondeau/SonosAPI

- In SonosModel.swift, you need to set the callback URL. The callback URL is used by the Sonos coordinator to notify this demo of specific events.

```bash
  private var callbackURL = URL(string: "URL:PORT")
```

### Testing

Once you have launched this application:

    1) Select a Sonos group in the demo.
    2) Launch the Sonos application on your mobile device and select the same group that you selected in the demo.
    3) Changing the volume in the Sonos application on your mobile device will automatically adjust the volume in the demo application.

## License

Distributed under the MIT License. See LICENSE.txt for more information.
