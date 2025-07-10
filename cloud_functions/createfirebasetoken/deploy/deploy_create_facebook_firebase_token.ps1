gcloud functions deploy create_facebook_firebase_token `
  --source=".." `
  --gen2 `
  --runtime=go122 `
  --region=us-central1 `
  --entry-point=CreateFacebookFirebaseToken `
  --trigger-http `
  --allow-unauthenticated `
  --env-vars-file "env.yaml"