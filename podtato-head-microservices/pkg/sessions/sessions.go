package sessions

import (
	"os"

	"github.com/gorilla/sessions"
)

const (
	envVarSessionKey = "SESSION_KEY"
	SessionName      = "podtato-head"
)

var (
	Store = sessions.NewCookieStore([]byte(os.Getenv(envVarSessionKey)))
)
