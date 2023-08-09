# MicrocontrollerServer

Elixir phoenix based microservice application to control and communicate with microcontrollers.

## Contents

* [Detailed explanation](#detailed-explanation)
* [Setting up](#setting-up)
  * [Development](#development)
    * [TODO: Devcontainer integration](#todo-devcontainer-integration)
    * [asdf installation](#asdf-installation)
  * [Production](#production)
  * [Background tools](#background-tools)
  * [Environment variables](#environment-variables)
* [Running the server](#running-the-server)
* [Learn more](#learn-more)

## Detailed explanation

This is a microservice which uses websockets to communicate with ESP8266/ESP32 based microcontrollers to read data, controls servos, etc.

The intent of this application is to have 100% test coverage so TDD is preffered.

## Setting up


### Development

The preffered way is to use asdf to have full control of the system but devcontainers are also a valid way of running the application in a scenario where an usual development machine can not be accessed.

#### TODO: Devcontainer integration

#### asdf installation

The current preffered way to setup the environment is to use [asdf](https://asdf-vm.com). 

To start with the installation please follow the [asdf installation instructions](https://asdf-vm.com/guide/getting-started.html).

After that the required plugins need to be added:

```bash
asdf plugin add elixir
asdf plugin add erlang
asdf plugin add vars https://github.com/excid3/asdf-vars
```

After installing the required plugins go to the following file: `~/.asdf/lib/commands/command-exec.bash` and find the line:

```bash
with_shim_executable "$shim_name" exec_shim || exit $?
```

After that, add a new line before it:

```bash
eval "$($ASDF_DIR/bin/asdf vars)"
```

And then the final result should look like:

```bash
eval "$($ASDF_DIR/bin/asdf vars)"
with_shim_executable "$shim_name" exec_shim || exit $?
```

Once that step is complete, create a file named `.asdf-vars`, this file will contain all of the environment varulables required by the project.

After that step, the final step is to install Elixir and Erlang:

```
asdf install
```

### Production

Currently the settings for production are the same as for [development](#development).

### Background tools

If the application is ran with asdf, then either `podman` or `docker` need to be installed. In case `podman` and `podman-compose` are installed, you would need to run `podman-compose up -d`.

### Environment variables

|Variable name|Type|Example|Definition|optional|
|:-----|:-----|:-----|:-----|:-----|
|MICROCONTROLLER_AUTH_SERVER|String|http://localhost:5000|URL of the auth server.|No


## Running the server

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
