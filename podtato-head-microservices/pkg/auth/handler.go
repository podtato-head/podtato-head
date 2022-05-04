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
	callbackPath = "/auth/callback"
	key          = []byte("test1234test1234")

	issuer       = os.Getenv("OIDC_ISSUER")
	clientID     = os.Getenv("OIDC_CLIENT_ID")
	clientSecret = os.Getenv("OIDC_CLIENT_SECRET")
	redirectURI  = os.Getenv("OIDC_REDIRECT_URI")
	scopes       = strings.Split(os.Getenv("OIDC_CLIENT_SCOPES"), " ")

	bypassAuth bool

	oidcClient rp.RelyingParty
)

func init() {
	if len(os.Getenv("OIDC_BYPASS")) == 0 {
		bypassAuth = false
	} else {
		log.Printf("will bypass auth")
		bypassAuth = true
	}

	if !bypassAuth {
		var err error
		oidcClient, err = rp.NewRelyingPartyOIDC(issuer, clientID, clientSecret, redirectURI, scopes,
			rp.WithCookieHandler(httphelper.NewCookieHandler(key, key, httphelper.WithUnsecure())),
			rp.WithVerifierOpts(rp.WithIssuedAtOffset(5*time.Second)),
		)
		if err != nil {
			log.Fatalf("error creating OIDC relying party: %s", err.Error())
		}
	}
}

// SetupCallbackHandler sets up an endpoint to handle token callback
func SetupCallbackHandler(router *mux.Router) {
	if !bypassAuth {
		marshalUserinfo := func(w http.ResponseWriter, r *http.Request, tokens *oidc.Tokens, state string, rp rp.RelyingParty, info oidc.UserInfo) {
			session, _ := sessions.Store.Get(r, sessions.SessionName)
			data, err := json.Marshal(info)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}
			log.Printf("saving userinfo in session: %v", string(data))
			session.Values["userinfo"] = string(data)
			session.Values["authenticated"] = true
			err = session.Save(r, w)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}
			redirectToOriginalURL(w, r)
			return
		}

		// register callback handler
		router.Handle(callbackPath, rp.CodeExchangeHandler(rp.UserinfoCallback(marshalUserinfo), oidcClient))
	}
}

func Authenticate(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		session, err := sessions.Store.Get(r, sessions.SessionName)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		if bypassAuth {
			log.Printf("bypassing authentication per flag")
			redirectToOriginalURL(w, r)
			return
		}

		// TODO: force reauthentication after expiry
		authenticated, found := session.Values["authenticated"].(bool)
		if !found || !authenticated {
			log.Printf("INFO: redirecting for authentication")
			state := func() string { return uuid.New().String() }

			log.Printf("saving originalURL %s", r.URL.String())
			session.Values["originalURL"] = r.URL.String()
			err = session.Save(r, w)

			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
			}
			rp.AuthURLHandler(state, oidcClient).ServeHTTP(w, r)
		} else {
			log.Printf("INFO: user already authenticated, continuing")
			next.ServeHTTP(w, r)
		}
		return
	})
}

func redirectToOriginalURL(w http.ResponseWriter, r *http.Request) {
	session, err := sessions.Store.Get(r, sessions.SessionName)
	if err != nil {
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
