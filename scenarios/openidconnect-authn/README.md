# User authentication with OIDC

podtato-head-microservices can require user authentication via an OpenID Connect
(OIDC) provider, but this is disabled by default. It is enabled when the
following environment variables for client metadata are set:

- **OIDC_ISSUER**: Base URL of issuer, e.g. `https://accounts.google.com`
- **OIDC_CLIENT_ID**: Client ID provided by authentication service
- **OIDC_CLIENT_SECRET**: Secret provided by authentication service
- **OIDC_REDIRECT_URI**: Redirect URI registered with the authentication service.
  Your app must be accessed at this URL.

For example, a Google Signin client could be configured like this in `.env`
(values are fake):

```bash
export GOOGLE_SIGNIN_CLIENT_ID=000000000000-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com
export GOOGLE_SIGNIN_CLIENT_SECRET=XPSCO4-ho9IS54gYytxivyWwcXpEUSXQx54

export OIDC_ISSUER=https://accounts.google.com
export OIDC_CLIENT_ID=${GOOGLE_SIGNIN_CLIENT_ID}
export OIDC_CLIENT_SECRET=${GOOGLE_SIGNIN_CLIENT_SECRET}
export OIDC_REDIRECT_URI='http://localhost:9000/auth/callback'
```

To disable OIDC authentication even when the above variables are set, set `OIDC_BYPASS=1`.

## Test

To test OIDC, use the [Helm](../../delivery/chart/) test with these env vars set.

Or, use the [Kustomize](../../delivery/kustomize/) test with an extra argument:
`./delivery/kustomize/test.sh '' '' 'oidc'`. (The empty first two arguments are
for a GitHub username and password, which if not set are discovered from the
environment.)

The [kubectl](../../delivery/kubectl/) test does not enable authentication.
