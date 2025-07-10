gcloud functions deploy create_google_firebase_token `
  --source=".." `
  --gen2 `
  --runtime=go122 `
  --region=us-central1 `
  --entry-point=CreateGoogleFirebaseToken `
  --trigger-http `
  --allow-unauthenticated `
  --env-vars-file "env.yaml"