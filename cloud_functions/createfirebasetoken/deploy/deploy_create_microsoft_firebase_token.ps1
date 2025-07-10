gcloud functions deploy create_microsoft_firebase_token `
  --source=".." `
  --gen2 `
  --runtime=go122 `
  --region=us-central1 `
  --entry-point=CreateMicrosoftFirebaseToken `
  --trigger-http `
  --allow-unauthenticated `
  --env-vars-file "../../../../createfirebasetoken_env/env.yaml"