# Balance

[![Build Status](https://travis-ci.org/codeforamerica/balance.svg?branch=master)](https://travis-ci.org/codeforamerica/balance)

A text message interface for people to check their EBT card balance for SNAP and other human service benefits

![Alt text](screenshots/balance-screenshot.png)

Currently unavailable. This project is no longer maintained.

- California
- Texas
- Pennsylvania
- Alaska
- Virginia
- Oklahoma
- North Carolina
- Florida

## What it is

This is a simple Ruby app built on Twilio that creates a text message interface for people to check their food stamp EBT card balance (and cash balance for other programs).

The original idea was by @lippytak with influence from @alanjosephwilliams's experience on Code for America's [health project ideas](https://github.com/codeforamerica/health-project-ideas/issues/34) repo.

This is a project of CFA's Health Lab Team.

## Running tests

Because we use `.env` for testing, you'll want to run your tests by running:

```
foreman run bundle exec rspec spec
```

## Twilio Console

The `twilio_console.rb` file just gets you a quick Ruby prompt with Twilio clients pre-loaded. This is useful for doing manual responses to users. To use this, you will need to set the environment variables specified in that file.

## Copyright & License

Copyright Code for America Labs, 2014-2016 — MIT License
