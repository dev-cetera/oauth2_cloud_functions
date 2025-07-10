$deployScriptsDir = $PSScriptRoot
$facebookDeployScript = Join-Path $deployScriptsDir "deploy_create_facebook_firebase_token.ps1"
$githubDeployScript = Join-Path $deployScriptsDir "deploy_create_github_firebase_token.ps1"
$googleDeployScript = Join-Path $deployScriptsDir "deploy_create_google_firebase_token.ps1"
$instagramDeployScript = Join-Path $deployScriptsDir "deploy_create_instagram_firebase_token.ps1"
$linkedinDeployScript = Join-Path $deployScriptsDir "deploy_create_linkedin_firebase_token.ps1"
$microsoftDeployScript = Join-Path $deployScriptsDir "deploy_create_microsoft_firebase_token.ps1"
$tiktokDeployScript = Join-Path $deployScriptsDir "deploy_create_tiktok_firebase_token.ps1"
$xTwitterDeployScript = Join-Path $deployScriptsDir "deploy_create_x_twitter_firebase_token.ps1"
& $facebookDeployScript
& $githubDeployScript
& $googleDeployScript
& $instagramDeployScript
& $linkedinDeployScript
& $microsoftDeployScript
& $tiktokDeployScript
& $xTwitterDeployScript