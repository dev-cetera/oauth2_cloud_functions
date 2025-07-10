gcloud functions deploy create_x_twitter_firebase_token `
  --source=".." `
  --gen2 `
  --runtime=go122 `
  --region=us-central1 `
  --entry-point=CreateXTwitterFirebaseToken `
  --trigger-http `
  --allow-unauthenticated `
  --env-vars-file "env.yaml"