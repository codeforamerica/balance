# Balance

[![Build Status](https://travis-ci.org/codeforamerica/balance.svg?branch=master)](https://travis-ci.org/codeforamerica/balance)

A text message interface for checking one's CalFresh (food stamp) EBT card balance in California


## What it is

This is a simple Ruby app built on Twilio that creates a text message interface for people to check their food stamp EBT card balance in California (and potentially for other programs utilizing EBT cards in the future). 

The original idea was by @lippytak with influence from @alanjosephwilliams's experience on Code for America's [health project ideas](https://github.com/codeforamerica/health-project-ideas/issues/34) repo.

This is a project of CFA's Health SpecOps Team.

## Deployment

To deploy on Heroku, close and push the repo, and then set the following environment variables:

- TWILIO_SID
- TWILIO_AUTH

with your Twilio credentials.

Then, go onto your Twilio account, purchase a phone number, and set the messaging URL for the phone number to a `POST` pointed at the root URL of your server (eg, http://my-balance-instance.herokuapp.com )


## Running tests

Because we use `.env` for testing, you'll want to run your tests by running:

```
foreman run bundle exec rspec spec
```

## Twilio Console

The `twilio_console.rb` file just gets you a quick Ruby prompt with Twilio clients pre-loaded. This is useful for doing manual responses to users. To use this, you will need to set the environment variables specified in that file.

## Ops Details

### Twilio

We have isolated Twilio subaccounts for the app, under CFA's main account.

- Staging: balance-health-guarino
- Production: balance-production-guarino

Each account has phone numbers attached to it.

For A/B testing different outreach media, we can buy a new phone number on the same Twilio subaccount and point it to the same server URL.

### Servers

We're deployed on Heroku on CFA's main account with both staging and production instances. Currently only @daguar is configured as a collaborator.

## Copyright & License

Copyright Code for America Labs, 2014 — MIT License
