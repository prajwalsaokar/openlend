package auctionhandler

import (
	"encoding/json"
	"fmt"
	"lendshare/broker/types"
	"os"

	"github.com/valyala/fasthttp"
)

func CreateAuction(ctx *fasthttp.RequestCtx) (types.AuctionCreateReq, error) {
	var reqBody types.AuctionCreateReq

	err := json.Unmarshal(ctx.Request.Body(), &reqBody)

	if err != nil {
		return types.AuctionCreateReq{}, err
	}

	req := fasthttp.AcquireRequest()
	req.AppendBody(ctx.Request.Body())
	req.Header.SetMethod(fasthttp.MethodPost)
	req.SetRequestURI(os.Getenv("DOMAIN_NAME") + "/api/create_auction/" + reqBody.BondId)
	res := fasthttp.AcquireResponse()
	err = types.Client.Do(req, res)

	if err != nil {
		return types.AuctionCreateReq{}, err
	}

	if err != nil {
		return types.AuctionCreateReq{}, err
	}

	if res.StatusCode() == 200 {
		return reqBody, nil
	}

	return types.AuctionCreateReq{}, fmt.Errorf("auction invalid")
}
