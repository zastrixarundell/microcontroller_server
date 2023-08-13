# Microcontroller Socket

This is a documentation file for the basics of using a microcontroller to connect to the server.

## Prerequisites

To run this an auth server for microcontrollers needs to be started. In the development environment this can be via running the [python mock server script](bin/mock-server.py).

After running `python bin/mock-server.py` a mock server running on `http://127.0.0.1:5000` will be started. This gives basic information mostly made for a singular device currently.

Make sure that the environment variable for the auth server is set to the correct mock address if this is the way it's being used.

## Connecting to the server

### URL for the endpoint

The microcontrollers are communicating with the servers via websockets. The path for the microcontroller endpoint is: `/microcontrollers/websocket`.

Given the following [Caddy](https://caddyserver.com/) (a proxy server) configuration:

```caddy
my.subdomain {
        encode gzip
        reverse_proxy 127.0.0.1:4000
}
```

The endclient would have to connect via this URL: `wss://my.subdomain/microcontrollers/websocket`. Note, while not using SSL the URI would start with `ws://`.

### Authentication

For the microcontroller to actually authenticate with the websocket connection, a custom header needs to be sent. The header in question is: `X-API-Key: api_token`. The API token is present on the authentication server and if it's correctly communicated, the authentication server will send the required information to continue with the connection.

To see the exact specs of the authentication key take a look at the [documentation page](https://microcontroller-server.armor.quest/MicrocontrollerServerWeb.MicrocontrollerSocket.html#api_token_regex/1) (this is considering live-server is running on localhost:5500 and the documentation is generated).

### Metadata

When the device authenticates and connects to the server, a message is sent to it on the connect event. The message in question is:

```json
{
    "ref": null,
    "payload": {
        "user_id": 1,
        "location_id": 2,
        "controller_id": 3
    },
    "topic": "microcontroller:3",
    "event": "metadata",
    "join_ref": null
}
```

## Communication with Phoenix

While official documentation doesn't exist as to how to communicate with Phoenix when not using a JavaScript library there is, thankfully, this [blogpost about it](https://web.archive.org/web/20230530183618/http://graemehill.ca/websocket-clients-and-phoenix-channels/).

### Heartbeats

In a nutshell the websocket needs to send a message to the Phoenix server every minute. This message should take have this format:

```json
{
  "topic": "phoenix",
  "event": "heartbeat",
  "payload": {},
  "ref": 0
}
```


* `topic`: Usually this is the room the event relates to.
* `event`: This defines which handler will get invoked on the server side (or potentially client-side if going the other direction). There are some built-in events mostly prefixed with phx_.
* `payload`: The actual data associated with the event. For some events (like phx_join) the payload is ignored.
* `ref`: Just an idenfifier for the message. When you get back a reply it will have the same ref value as the event that it is replying to. Since channels are asynchronous you could quickly send two events before receiving a reply and you would need to use ref to know which event it relates to. In my examples I have hard coded ref to 0 but in reality you probably want a counter and some helper function to get the next reference number (or use a uuid).`
`

### V1 API

#### Joining

To join the rquired microcontroller channel for the `v1` version of the API, the following data needs to be sent to the server:

```json
{
  "topic": "microcontroller:v1:$controller_id",
  "event": "phx_join",
  "payload": {},
  "ref": 0,
  "join_ref": 0
}
```

#### Sending reading information

After the controller has joined the channel, it can send its' reading information in the following format:

```json
{
  "topic": "microcontroller:v1:$controller_id",
  "event": "upload_readings",
  "payload": {
    "$sensor-id": [
      {
        "type": "$reading_type",
        "value": "$value"
      },
      {
        "type": "$reading_type",
        "value": "$value"
      }
    ]
  },
  "ref": 0,
  "join_ref": 0
}
```

#### Motor controls

To receive informations as to how to control a motor the following inforamtion needs to be intercepted:


```json
{
  "topic": "microcontroller:v1:$controller_id",
  "event": "control_update",
  "payload": {
    "control": [
      {
        "$control_id": $control_value
      }
    ]
  }
}
```

