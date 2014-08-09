A text message interface for EBT balance

[![Build Status](https://travis-ci.org/daguar/balance.svg?branch=master)](https://travis-ci.org/daguar/balance)

## Deployment

Set the following environment variables:

- TWILIO_SID
- TWILIO_AUTH

## Running tests

Because we use `.env` for testing, you'll want to run your tests by running:

```
foreman run bundle exec rspec spec
```

