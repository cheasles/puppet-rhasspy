# rhasspy

A Puppet module to configure [Rhasspy](https://rhasspy.readthedocs.io/en/latest/).

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with rhasspy](#setup)
    * [Beginning with rhasspy](#beginning-with-rhasspy)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This modules allows you to install and configure Rhasspy from within Puppet.
It is largly based on the assumption that you'll be configuring it to interact with Home Assistant, though there's no reason that's a requirement.

## Setup

### Beginning with rhasspy

To get started, simply include the `rhasspy` class as follows:

``` puppet
include ::rhasspy
```

This will install Rhasspy following the same [instructions in their documentation](https://rhasspy.readthedocs.io/en/latest/installation/#virtual-environment) to install as a Python virtual environment.

Mosquitto MQTT is not installed by default as there are other Puppet modules that handle that better.
If you wish to have mosquitto installed using this module, try the following:

``` puppet
include ::rhasspy
```

``` yaml
rhasspy::manage_mosquitto: true
```

You'll likely want to configure some sentences, slots or programs, so take a look at the [Usage](#usage) section to see more.

## Usage

This module uses `hash2json` to convert the `rhasspy::config_options` value for use with Rhasspy.

The first thing you'll want to do is figure out which of the Rhasspy systems you want to enable.

### Systems

Rhasspy systems can be configured through Hiera.
For example, to configure the handler system to use Home Assistant, enter the following Hiera:

``` yaml
rhasspy::config_options:
  handle:
    system: hass
```

This will configure Rhasspy to run only the Home Assistant handler.

The following demonstrates a [base and satellite installation](https://rhasspy.readthedocs.io/en/latest/tutorials/#server-with-satellites) on two different machines.
On the main server, your Hiera may look like this:

``` yaml
rhasspy::config_options:
  dialogue:
    system: rhasspy
  handle:
    system: hass
  home_assistant:
    url: https://my_home_assistant.com
    access_token: My-access-token
  intent:
    system: fsticuffs
  mqtt:
    enabled: 'true'
    host: my_mqtt_server
    port: 8883
    tls:
      enabled: 'true'
      ca_certs: /etc/ssl/certs/ca-certificates.crt
    site_id: base
  speech_to_text:
    system: kaldi
  text_to_speech:
    system: nanotts
```

Find out how to create an access token via Home Assistant [here](https://developers.home-assistant.io/docs/auth_api/#long-lived-access-token).

On a satellite machine, your Hiera may look like this:

``` yaml
rhasspy::config_options:
  mqtt:
    enabled: 'true'
    host: my_mqtt_server
    port: 8883
    tls:
      enabled: 'true'
      ca_certs: /etc/ssl/certs/ca-certificates.crt
    site_id: satellite
  intent:
    system: hermes
  microphone:
    system: pyaudio
  sounds:
    system: aplay
  speech_to_text:
    system: hermes
  text_to_speech:
    system: hermes
  wake:
    system: porcupine
```

### Sentences

Sentences are used to determine intent after speech has been converted to text by Rhasspy.
To configure a sentence, try the following Hiera:

``` yaml
rhasspy::sentences:
  GetTemperature:
    lines:
      - 'room = (living room | bedroom | study) {room}'
      - 'whats the temperature in the <room>'
      - 'how (hot | cold) is it in the <room>'
```

Any changes to sentences will automatically cause Rhasspy to retrain itself.

### Slots

Slots are hard-coded lists of data used by sentences.
There are three provided by this module:

* colors: A list of colors supported by Home Assistant.
* days: The days of the week.
* months: The months of the year.

To define your own slot, use the following Hiera:

``` yaml
rhasspy::slots:
  'colors':
    source: 'puppet:///modules/rhasspy/slots/hass/colors'
```

### Slot Programs

Slot programs are scripts that can be called by Rhasspy during training.
This module provides two programs by default:

* number: A Python script that prints a list of numbers between an upper and lower bound.
* hass_entities: A bash script that retrieves a list of entities from Home Assistant using the existing Rhasspy configuration.

To define your own program, use the following Hiera:

``` yaml
rhasspy::slot_programs:
  'hass_entities':
    source: 'puppet:///modules/rhasspy/slot_programs/hass/entities'
```

You can call these programs from within your sentences like so:

``` yaml
rhasspy::sentences:
  HassTurnOn:
    lines:
      - 'input_booleans = $hass_entities,input_boolean'
      - 'entities = <input_booleans>'
      - 'turn on [the] (<entities>){name}'
```

## Limitations

This module has only been tested with Debian 10.

## Development

If you'd like to contribute, fork the repo and make a pull request.
