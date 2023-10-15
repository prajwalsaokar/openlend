package types

import (
	"encoding/json"
	"os"
	"time"

	"github.com/fasthttp/websocket"
	"github.com/valyala/fasthttp"
)

type SuccessMessage struct {
	Valid bool
}

type SocketClient struct {
	C    *websocket.Conn
	Uuid string
}

type BatchAuctionReq struct {
	Uuids []string `json:"uuids"`
}

type BatchAuctionRes struct {
	Aprs map[string]float64 `json:"aprs"`
}

type SocketReq struct {
	Apr    float64 `json:"apr"`
	Uuid   string  `json:"uuid"`
	Bidder string  `json:"bidder"`
}

type AuctionCreateReq struct {
	BondId   string  `json:"bondId"`
	SellerId string  `json:"sellerId"`
	MaxApr   float64 `json:"maxApr"`
}

type AuctionEndReq struct {
	Auction  Auction `json:"auction"`
	BondUuid string  `json:"bondUuid"`
}

type Auction struct {
	Apr           float64 `json:"apr"`
	EndTime       int64   `json:"endTime"`
	HighestBidder string  `json:"highestBidder"`
}

func (a *Auction) Bid(req SocketReq) (bool, bool) {
	if req.Apr < a.Apr && time.Now().UnixNano() < a.EndTime {
		a.Apr = req.Apr
		a.HighestBidder = req.Bidder

		return true, false
	} else if time.Now().UnixNano() > a.EndTime {
		body, err := json.Marshal(AuctionEndReq{
			Auction:  *a,
			BondUuid: req.Uuid,
		})

		if err != nil {
			return false, false
		}

		uuid := req.Uuid
		req := fasthttp.AcquireRequest()
		res := fasthttp.AcquireResponse()
		req.AppendBody(body)
		req.SetRequestURI(os.Getenv("DOMAIN_NAME") + "/api/finish_auction/" + uuid)

		err = Client.Do(req, res)

		if err != nil {
			return false, false
		}

		return false, true
	}

	return false, false
}
