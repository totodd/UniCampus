# Mapwize app for iOS

This is the source code of the Mapwize app available on the App Store.

[View the app on the App Store](https://itunes.apple.com/us/app/mapwize/id1054359513?mt=8)

Are you looking for a simple way to implement indoor mapping and wayfinding in your organization? Get your [Mapwize account](https://www.mapwize.io), import your indoor maps on [Mapwize Studio](https://studio.mapwize.io) and fork this app!

## Mapwize SDK

The app is built using the MapwizeForMapbox SDK. You can find the documentation about the SDK at [docs.mapwize.io](https://docs.mapwize.io).

## Credentials

You will need to set your [Mapbox](https://www.mapbox.com) and [Mapwize](https://www.mapwize.io) credentials in the info.plist. 

Sample keys are given for Mapwize and Mapbox. Please note that those keys can only be used for testing purposes, with very limited traffic, and cannot be used in production. Get your own keys from [mapwize.io](https://www.mapwize.io) and [mapbox.com](https://www.mapbox.com). Free accounts are available.

## Deep-linking

The app supports deep-linking using the mapwize:// protocol. To avoid conflicts, please change the protocol in your own app.

Supported url are in the same format as QR-Code urls.

## License and credits

The app is released under MIT license.

The LICENSE file contains the MIT license as well as the licenses of the open-source code used.

A page with credits to the used open-source projects is added in the app. The credit.html page can be generated from the LICENSE file using showdown.

Install showdown if you don't have it yet

```
npm install showdown -g
```

Then execute

```
showdown makehtml -i LICENSE -o Mapwize/Ressources/credits.html
```
