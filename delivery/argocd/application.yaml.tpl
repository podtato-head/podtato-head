apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
    name: ${application_name}
    namespace: argocd
spec:
    source:
        repoURL: ${git_repo_url}
        path: ${git_repo_path}
        targetRevision: ${git_repo_tree}
        helm:
            values: |
                images:
                    repositoryDirname: ${image_name_base}
                    pullPolicy: Always
                    pullSecrets:
                      - name: ghcr
                entry:
                    serviceType: NodePort
                    tag: ${image_version}
                    env:
                      - name: OIDC_BYPASS
                        value: 'true'
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
    destination:
        server: https://kubernetes.default.svc
        namespace: ${namespace}
    project: default
