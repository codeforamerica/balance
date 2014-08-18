Due to the nuances of Twilio, all pull requests should be manually tested on Staging prior to merging. Specifically:

1. Text bad input (eg, "lol") to confirm error response

2. Text our valid EBT number to confirm (a) 1-2 min wait message, and (b) successful balance check

3. Call Staging to confirm you receive a text

Once this is done, please comment on your PR stating that you've successfully tested behavior for your PR on staging.

