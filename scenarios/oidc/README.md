# User authentication with OIDC

To enable user authentication, add env vars for OIDC client info to .env.

If `OIDC_CLIENT_SECRET` is set the Helm chart will create a secret with OIDC client info and put that in the `entry` deployment.

If `OIDC_BYPASS` is set no authentication is performed.
