images:
  repositoryDirname: ${image_repo_dir_name}
  pullPolicy: Always
  pullSecrets:
    - name: ghcr
entry:
  tag: ${image_version}
hat:
  tag: ${image_version}
  env:
    - name: PODTATO_PART_NUMBER
      value: '02'
rightLeg:
  tag: ${image_version}
rightArm:
  tag: ${image_version}
leftLeg:
  tag: ${image_version}
leftArm:
  tag: ${image_version}
oidc:
  enabled: ${oidc_enabled}
  issuer: ${OIDC_ISSUER}
  clientID: ${OIDC_CLIENT_ID}
  clientSecret: ${OIDC_CLIENT_SECRET}
  redirectURI: ${OIDC_REDIRECT_URI}
  clientScopes: ${OIDC_CLIENT_SCOPES}
  sessionKey: ${SESSION_KEY}