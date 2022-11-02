# registry-secrets

This deployment item contains a plain secret for the ghcr registry. To get the actual password into the secret,
a simple `arg` is used. Please note that this is NOT how one would usually do this.
You should instead consider using the [sealed secrets](https://kluctl.io/docs/reference/sealed-secrets/) integration.
