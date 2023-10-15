from .models import Bond, CustomUser
import requests
import os
from google.cloud import aiplatform

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

def getBondGrade(bondUuid) -> None: 
    bond = Bond.objects.get(id=bondUuid)
    bond_issuer = bond.loanerId
    issuer_risk_factors = bond_issuer.riskFactors
    dti = 100 * float(issuer_risk_factors.total_debt)/float(issuer_risk_factors.income)
    tot_cur_bal = issuer_risk_factors.liquidAssets + issuer_risk_factors.nonLiquidAssets
    ml_args = [bond.bondAmt, bond.apr, issuer_risk_factors.home_ownership, issuer_risk_factors.income, bond.bondPurpose, dti, tot_cur_bal]
    Bond.objects.update(id=bondUuid, riskLevel=endpoint_predict_sample("openlend-402019", "us-east1", [ml_args], "openlend_ml"))

    

def endpoint_predict_sample(
    project: str, location: str, instances: list, endpoint: str
) -> int:
    aiplatform.init(project=project, location=location)

    endpoint = aiplatform.Endpoint(endpoint)

    prediction = endpoint.predict(instances=instances)
    # print(prediction)
    return prediction