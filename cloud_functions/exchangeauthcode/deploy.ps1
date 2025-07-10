gcloud functions deploy exchange_auth_code `
  --gen2 `
  --runtime=go122 `
  --region=us-central1 `
  --entry-point=ExchangeAuthCode `
  --trigger-http `
  --allow-unauthenticated `
  --env-vars-file "../../../exchangeauthcode_env/env.yaml"