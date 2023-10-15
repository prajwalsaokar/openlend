package types

import (
	"time"

	"github.com/valyala/fasthttp"
)

var Client *fasthttp.Client
var Token string

// Initialized fasthttp client
func InitClient() {
	readTimeout, _ := time.ParseDuration("1000ms")
	writeTimeout, _ := time.ParseDuration("1000ms")
	maxIdleConnDuration, _ := time.ParseDuration("1h")

	Client = &fasthttp.Client{
		ReadTimeout:                   readTimeout,
		WriteTimeout:                  writeTimeout,
		MaxIdleConnDuration:           maxIdleConnDuration,
		NoDefaultUserAgentHeader:      true, // Don't send: User-Agent: fasthttp
		DisableHeaderNamesNormalizing: true, // If you set the case on your headers correctly you can enable this
		DisablePathNormalizing:        true,
		// increase DNS cache time to an hour instead of default minute
		Dial: (&fasthttp.TCPDialer{
			Concurrency:      4096,
			DNSCacheDuration: time.Hour,
		}).Dial,
	}
}
