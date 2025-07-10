gcloud functions deploy create_github_firebase_token `
  --source=".." `
  --gen2 `
  --runtime=go122 `
  --region=us-central1 `
  --entry-point=CreateGitHubFirebaseToken `
  --trigger-http `
  --allow-unauthenticated `
  --env-vars-file "env.yaml"