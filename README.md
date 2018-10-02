# A Raspberry Pi powered Photo Booth

This package uses the
[Raspberry Camera Module](https://www.raspberrypi.org/products/camera-module-v2/)
to capture four pictures with a visible countdown. Once captured, all
four images are shown for a configurable duration and can be optionally be
uploaded to an external web service for post-processing. This server can then
return an additional transparent PNG file that will overlay the four photos.

The capture sequence is triggered by GPIO. So you can wire it to a button or other
hardware.

A playlist of videos and images is played while the device is idle.

## Hardware setup

The photo sequence is triggered by GPIO. Have a look at the GPIO demo package
for an example of how to connect a button to GPIO pin 18:

https://info-beamer.com/pkg/8421

## Integration into your backend

If you specify an upload url, the device will upload all four images in a single
POST request to the url. In your server code you can then store or otherwise do
post-processing on the images. Your service should return a transparent PNG
file as a response. This image is then added on top of the four photos. This
allows you to augment the output - for example by overlaying a QR code
where the user can download their photos.

This package includes an example server in `server.py` that shows how this
works. You might want to use a secret url for handling upload requests.
