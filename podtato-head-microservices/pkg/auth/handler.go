package auth

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/mux"
	"github.com/podtato-head/podtato-head/pkg/sessions"

	"github.com/zitadel/oidc/pkg/client/rp"
	httphelper "github.com/zitadel/oidc/pkg/http"
	"github.com/zitadel/oidc/pkg/oidc"
)

var (
	envVarSessionKey = "SESSION_KEY"
	sessionKey       = []byte(os.Getenv(envVarSessionKey))

	callbackPath = "/auth/callback"
	bypassAuth   = false

	issuer       = os.Getenv("OIDC_ISSUER")
	clientID     = os.Getenv("OIDC_CLIENT_ID")
	clientSecret = os.Getenv("OIDC_CLIENT_SECRET")
	redirectURI  = os.Getenv("OIDC_REDIRECT_URI")
	scopes       = strings.Split(os.Getenv("OIDC_CLIENT_SCOPES"), " ")

	oidcClient rp.RelyingParty
)

func init() {
	// any value other than "0" or "false" indicates to bypass
	bypassAuthFromEnv := os.Getenv("OIDC_BYPASS")
	if (len(bypassAuthFromEnv) > 0) && (bypassAuthFromEnv != "0") && (bypassAuthFromEnv != "false") {
		log.Printf("INFO: will bypass auth per env var")
		bypassAuth = true
		return
	}

	log.Printf("INFO: constructing OIDC relying party client")
	var err error
	oidcClient, err = rp.NewRelyingPartyOIDC(issuer, clientID, clientSecret, redirectURI, scopes,
		rp.WithCookieHandler(httphelper.NewCookieHandler(sessionKey, nil, httphelper.WithUnsecure())),
		rp.WithVerifierOpts(rp.WithIssuedAtOffset(5*time.Second)),
	)
	if err != nil {
		log.Fatalf("ERROR: failed to create OIDC relying party client: %s", err.Error())
	}
}

// SetupCallbackHandler sets up an endpoint to handle token callback
func SetupCallbackHandler(router *mux.Router) {
	if bypassAuth {
		return
	}

	saveUserinfo := func(w http.ResponseWriter, r *http.Request, tokens *oidc.Tokens, state string, rp rp.RelyingParty, info oidc.UserInfo) {
		session, err := sessions.Store.Get(r, sessions.SessionName)
		if err != nil {
			log.Printf("ERROR: failed to create or restore session: %s", err.Error())
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		data, err := json.Marshal(info)
		if err != nil {
			log.Printf("ERROR: failed to marshal userinfo: %s", err.Error())
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		log.Printf("INFO: saving userinfo to session: %v", string(data))
		session.Values["userinfo"] = string(data)
		session.Values["authenticated"] = true
		err = session.Save(r, w)
		if err != nil {
			log.Printf("ERROR: failed to save session: %s", err.Error())
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		redirectToOriginalURL(w, r)
		return
	}

	// register callback handler
	router.Handle(callbackPath, rp.CodeExchangeHandler(rp.UserinfoCallback(saveUserinfo), oidcClient))
}

func Authenticate(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		session, err := sessions.Store.Get(r, sessions.SessionName)
		if err != nil {
			log.Printf("ERROR: failed to create or restore session: %s", err.Error())
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		// TODO: force reauthentication after expiry
		authenticated, found := session.Values["authenticated"].(bool)

		if bypassAuth {
			log.Printf("INFO: bypassing authentication per flag")
		} else if !found || !authenticated {
			log.Printf("INFO: redirecting user for authentication")
			state := func() string { return uuid.New().String() }

			log.Printf("INFO: saving originalURL %s", r.URL.String())
			session.Values["originalURL"] = r.URL.String()
			err = session.Save(r, w)

			if err != nil {
				log.Printf("ERROR: failed to save session state: %s", err.Error())
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}
			rp.AuthURLHandler(state, oidcClient).ServeHTTP(w, r)
			return
		} else {
			log.Printf("INFO: user already authenticated")
		}
		next.ServeHTTP(w, r)
		return
	})
}

func redirectToOriginalURL(w http.ResponseWriter, r *http.Request) {
	session, err := sessions.Store.Get(r, sessions.SessionName)
	if err != nil {
		log.Printf("ERROR: failed to create or restore session: %s", err.Error())
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	originalURL, found := session.Values["originalURL"].(string)

	if !found {
		http.Redirect(w, r, "/", http.StatusFound)
	} else {
		log.Printf("redirecting to original URL %s", originalURL)
		http.Redirect(w, r, originalURL, http.StatusFound)
	}
}
