import requests
import asyncio
from json import dumps
from websockets.sync.client import connect

def sendBid(Apr, Uuid, Bidder):
    with connect("ws://localhost:8001/connect") as ws:
        data = dumps(
            dict(
                apr = Apr,
                uuid = Uuid,
                bidder = Bidder
            )
        )
        ws.send(data)
        msg = ws.recv()
        print(msg)

def createDummyAuction(BondId, SellerId, MaxApr):
    args = dict(
        bondId = BondId,
        sellerId = SellerId,
        maxApr = MaxApr
    )
    data = requests.post("http://localhost:8001/create_dummy_auction", data = dumps(args))
    print(data.content)

def getAllAuctions():
    data = requests.post("http://localhost:8001/get_auctions", data = dumps(dict(uuids=[])))
    print(data.json())

if __name__ == "__main__":
    # seller: 0 creates auction for bond: 0 with maxapr: 15%
    # createDummyAuction(0, 0, 0.15)

    # buyer: 1 bids on bond: 0 with apr: 13%
    sendBid(0.13, 0, 1)

    # buyer: 2 bids on bond: 0 with apr: 10%
    # sendBid(0.10, 0, 2)

    # seller: 3 creates auction for bond: 1 with maxapr: 12%
    # createDummyAuction(1, 3, 12)
    # getAllAuctions()

    # seller: 1 attempts to create auction for bond: 0 with maxapr: -1%
    # createDummyAuction(0, 1, -0.01)
    getAllAuctions()


