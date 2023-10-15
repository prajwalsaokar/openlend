from .models import Bond, CustomUser
import requests
import os

purposeMap = [
    "I am requesting a loan to consolidate all my current debts into a single loan",
    "I need a loan to fulfill my first purchasing order with inventory, equipment, and to expand with ads, increasing exposure for my business",
    "I am requesting a loan for aid to help pay for household expenses, such as a stove, laundry machine, and other related appliances.",
    "I need a loan to help pay for a purchase in my life",
    "I need a loan to help cover my credit card balance for the month",
    "I need a loan to help pay for a variety of miscellaneous expenses",
    "I need a loan to help pay my mortgage",
    "I need a loan to fund a vacation",
    "I need a loan to help cover my car payment",
    "I need a loan to help pay for my healthcare expenses not covered by insurance.",
    "I need a loan to help pay for moving to another house",
    "", # Hide # 11 - renewable energy kekw
    "I need a loan to help pay the costs for my wedding",
    "I need a loan to fulfill my first purchasing order with inventory, equipment, and to expand with ads, increasing exposure for my business"
]

BROKER_URL = "http://localhost:8001/"

def getPurchasedBondsById(uuid):
    return Bond.objects.filter(purchaserId=uuid)


def getIssuedBondsById(uuid):
    return Bond.objects.filter(purchaserId=uuid)

def createBondAuction(bondData):
    AUCTION_URL = BROKER_URL + "create_auction"
    requests.post(AUCTION_URL,json = bondData)