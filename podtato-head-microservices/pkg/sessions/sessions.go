package sessions

import (
	"log"
	"os"

	"github.com/gorilla/securecookie"
	"github.com/gorilla/sessions"
)

const (
	envVarSessionKey = "SESSION_KEY"
	SessionName      = "podtato-head"
)

var (
	Store *sessions.CookieStore
)

func init() {
	var sessionKey []byte
	sessionKey = []byte(os.Getenv(envVarSessionKey))
	if len(sessionKey) == 0 {
		log.Printf("INFO: No session key set in %s, generating a random one", envVarSessionKey)
		sessionKey = securecookie.GenerateRandomKey(32)
	}

	// first param is for authentication, second is for encryption
	Store = sessions.NewCookieStore(sessionKey)
}
