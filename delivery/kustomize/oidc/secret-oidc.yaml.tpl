---
apiVersion: v1
kind: Secret
metadata:
  name: podtato-head-oidc-metadata
stringData:
    OIDC_BYPASS: 'false'
    OIDC_ISSUER: ${OIDC_ISSUER}
    OIDC_CLIENT_ID: ${OIDC_CLIENT_ID}
    OIDC_CLIENT_SECRET: ${OIDC_CLIENT_SECRET}
    OIDC_REDIRECT_URI: ${OIDC_REDIRECT_URI}
    OIDC_CLIENT_SCOPES: ${OIDC_CLIENT_SCOPES}
    SESSION_KEY: ${SESSION_KEY}
