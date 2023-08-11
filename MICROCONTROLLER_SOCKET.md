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

The end client would have to connect via this URL: `wss://my.subdomain/microcontrollers/websocket`.

### Authentication

For the microcontroller to actually authenticate with the websocket connection, a custom header needs to be sent. The header in question is: `X-API-Key: api_token`. The API token is present on the authentication server and if it's correctly communicated, the authentication server will send the required information to continue with the connection.

To see the exact specs of the authentication key take a look at the [documentation page](http://127.0.0.1:5500/doc/MicrocontrollerServerWeb.MicrocontrollerSocket.html#api_token_regex/1) (this is considering live-server is running on localhost:5500 and the documentation is generated).
