<p align="center">
  <img src="assets/logo.png" />
</p>

<p align="center">
  <b>Neural Network for time series data forecasting using Axon library</b>
</p>

<p align="center">
  <a href="./LICENSE">
    <img alt="License" src="https://img.shields.io/badge/license-MIT-blue" />
  </a>
</p>

## Features
- Lightweight REST API
- Automatic training after reaching certain threshold
- Load Balancing
- Analyser tools
- Simple & Complex predictions

Arnold is a neural network built as an analysing and forecasting tool for time series data.
Used by [WombatOAM](https://www.erlang-solutions.com/capabilities/wombatoam/).
The goal was to integrate a tool that can analyse the incoming metrics and forecast upcoming values, alert users when
a monitored metric reaches a certain threshold, dynamic alerts, and much more.

Arnold is capable of returning the trend and seasonality components, which are calculated with
a decomposition method, then added back to the final prediction result.

Documentation is available [here](https://esl.github.io/arnold/)


# Installation & Usage

## Packages
Arnold has package releases for both osx and linux. Download the favored version from github packages page.
Uncompress it with `tar` like the following way:

```bash
foo@bar:~$ tar -xf arnold-{VERSION}-{OS}.tar.gz
```

Then can be started like
```bash
foo@bar:~$ arnold-{VERSION}-{OS}/bin/arnold start
```


## Build from source

### Prerequisites

Arnold requires **Elixir 1.13** or later version and **Erlang/OTP 24.0** or later version.

### Build

Clone the repository to your custom destination.
```bash
foo@bar:~$ git clone https://github.com/esl/arnold.git
```

Run the following command to get a dependencies and build Arnold
```bash
foo@bar:~$ make build
```

Recommened way of start a Arnold node is the interactive mode with the shell using
```bash
foo@bar:~$ make console
```

If you would like to create a release version of Arnold `TARGET` varibale should be set before
running `distillery`.

```bash
foo@bar:~$ make release TARGET=osx
```

If not set it is going to use the default `dev` environment. All configurations can be checked
in the `rel/config.exs`

## Basic Usage
For most cases there are two possible optios to use
 - RestAPI
 - Arnold module

### Feeding data
#### RestAPI url
```
/api/write?node=NodeID&metric=MetricName
```
It has two query parameters 
 - NodeID: Node name
 - MetricName: Name of the metric which is going to appear in Arnold as SensorID

 Body is sent as a json object.
 ```json
 {
   "type": "gauge",
   "value": 5,
   "timestamp": 1642433780
 }
 ```

 - Type: Metric type like gauge, counter etc. Arnold has its own way of dealing with metrics. It can be extended with multiple types as well.
 - Value: Single numeric value (could be a float)
 - Timestamp: time when the metric value was created

#### Arnold module
```elixir
iex(1)> Arnold.feed("node", "sensor_id", 1642433780, 5)
:ok
iex(2)>
```

### Retriving predictions
#### RestAPI url
```
/api/prediction?node=NodeID&metric=MetricName&tag=Tag&horizon=Horizon
```
It has two query parameters 
 - NodeID: Node name
 - MetricName: Name of the metric which is going to appear in Arnold as SensorID
 - Tag: Time period tag (hourly, daily, weekly)
 - Horizon: Forecast horizon, quantity of metrics to be forecasted after of the latest timestamp.

 Body is empty.

#### Arnold module
```elixir
iex(1)> Arnold.predict("node", "sensor_id", :hourly, 5)
  {ok,
      [[1642433780, 1642433840, 1642433900, 1642433960,1642434020],
       [119027224.0,119214032.0, 119363472.0, 119483024.0, 119578672.0],
       [107124496.0, 107292624.0, 107427120.0, 107534720.0, 1.076208e8]
       [130929952.0, 131135440.0, 131299824.0, 131431328.0, 131536544.0]]}
iex(2)>
```

Returning data is [Highcharts](https://www.highcharts.com/) friendly for easier use.
## Makefile commands

 - `compile`: Compiles Arnold
 - `deps`: Gets the deps
 - `build`: Previos two commands together. Needs a clean repo.
 - `release`: Creates a release. If `TARGET` is defined it uses the given values as a mix environment.
 - `console`: Starts a dev console
 - `docs`: Makes the docs using ExDoc
 - `dialyzer`: Runs dialyzer
 - `clean`: Cleans the folder like it was just cloned

### Useage
```bash
foo@bar:~$ make COMMAND
```
## Config

By default the port `8081` is used for the RestAPI but can be configure for a custom port number.

```elixir
config :arnold, port: 8081
```

## Dependencies

 - **Axon**: Neural Network
 - **Nx**: Tensor
 - **Memento**: Mnesia storage backend API
 - **Plug_cowboy**: RestAPI
 - **Logger_file_backend**: Logging to file 
 - **Uuid**: ID generation
 - **Distillery**: Release and package creation
 - **Dialyxir**: dev only, dialyzer
 - **ExDocs**: dev only, Documentation of the project


## License
MIT

## Contact
For any questions regarding Arnold 
* Tamás Lengyel: tamas.lengyel@erlang-solutions.com
