package types

var Sockets map[string][]SocketClient
var BidMap map[string]Auction

func Init() {
	Sockets = make(map[string][]SocketClient)
	BidMap = make(map[string]Auction)
}
