A text message interface for EBT balance

## Deployment

Set the following environment variables:

- TWILIO_NUMBER
- TWILIO_SID
- TWILIO_AUTH

## Running tests

Because we use `.env` for testing, you'll want to run your tests by running:

```
foreman run bundle exec rspec spec
```

