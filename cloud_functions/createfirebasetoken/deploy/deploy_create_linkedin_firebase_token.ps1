gcloud functions deploy create_linkedin_firebase_token `
  --source=".." `
  --gen2 `
  --runtime=go122 `
  --region=us-central1 `
  --entry-point=CreateLinkedInFirebaseToken `
  --trigger-http `
  --allow-unauthenticated `
  --env-vars-file "../../../../createfirebasetoken_env/env.yaml"