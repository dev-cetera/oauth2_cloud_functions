gcloud functions deploy create_facebook_firebase_token `
  --gen2 `
  --runtime=go122 `
  --region=us-central1 `
  --entry-point=CreateFacebookFirebaseToken `
  --trigger-http `
  --allow-unauthenticated `
  --env-vars-file "env.yaml"

gcloud functions deploy create_github_firebase_token `
  --gen2 `
  --runtime=go122 `
  --region=us-central1 `
  --entry-point=CreateGitHubFirebaseToken `
  --trigger-http `
  --allow-unauthenticated `
  --env-vars-file "env.yaml"

gcloud functions deploy create_google_firebase_token `
  --gen2 `
  --runtime=go122 `
  --region=us-central1 `
  --entry-point=CreateGoogleFirebaseToken `
  --trigger-http `
  --allow-unauthenticated `
  --env-vars-file "env.yaml"

gcloud functions deploy create_instagram_firebase_token `
  --gen2 `
  --runtime=go122 `
  --region=us-central1 `
  --entry-point=CreateInstagramFirebaseToken `
  --trigger-http `
  --allow-unauthenticated `
  --env-vars-file "env.yaml"

gcloud functions deploy create_linkedin_firebase_token `
  --gen2 `
  --runtime=go122 `
  --region=us-central1 `
  --entry-point=CreateLinkedInFirebaseToken `
  --trigger-http `
  --allow-unauthenticated `
  --env-vars-file "env.yaml"

gcloud functions deploy create_microsoft_firebase_token `
  --gen2 `
  --runtime=go122 `
  --region=us-central1 `
  --entry-point=CreateMicrosoftFirebaseToken `
  --trigger-http `
  --allow-unauthenticated `
  --env-vars-file "env.yaml"

gcloud functions deploy create_tiktok_firebase_token `
  --gen2 `
  --runtime=go122 `
  --region=us-central1 `
  --entry-point=CreateTikTokFirebaseToken `
  --trigger-http `
  --allow-unauthenticated `
  --env-vars-file "env.yaml"

gcloud functions deploy create_x_firebase_token `
  --gen2 `
  --runtime=go122 `
  --region=us-central1 `
  --entry-point=CreateXFirebaseToken `
  --trigger-http `
  --allow-unauthenticated `
  --env-vars-file "env.yaml"