from django.shortcuts import render, redirect
from django.core.cache import cache
import stripe
from os import getenv
from dotenv import load_dotenv
from rest_framework import serializers, generics 
from lendshare.models import CustomUser, Bond
from lendshare.serializers import UserSerializer, BondSerializer, RegisterSerializer, StripeSerializer
from .services import purposeMap, getPurchasedBondsById, getIssuedBondsById, createBondAuction, getBondGrade

from rest_framework.authentication import SessionAuthentication, BasicAuthentication
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny
from rest_framework.settings import api_settings
from rest_framework.authtoken.models import Token
from rest_framework import status
from rest_framework.validators import UniqueValidator
from rest_framework.authentication import TokenAuthentication

from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth import authenticate, login
from django.contrib.auth import get_user
from .models import CustomUser as ModelsUser
from json import loads, dumps
from rest_framework.decorators import api_view
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
import requests

STRIPE_API_KEY = getenv('STRIPE_API_KEY')
BROKER_URL = getenv('BROKER_URL')

class UserList(generics.ListCreateAPIView):
    queryset = CustomUser.objects.all()
    permission_classes = (AllowAny,)
    serializer_class = UserSerializer

class BondList(generics.ListCreateAPIView):
    permission_classes = (IsAuthenticated,)          
    queryset = Bond.objects.all()
    serializer_class = BondSerializer

class RegisterUserAPIView(generics.CreateAPIView):
  permission_classes = (AllowAny,)
  serializer_class = RegisterSerializer

# Create your views here
class UserBondsPurchasedView(APIView):
    permission_classes = [IsAuthenticated]
    def post(self, request):
        body = loads(request.body)
        purchased = getPurchasedBondsById(request["id"])
        out = [{"id": bond.id, "loanerId": bond.loanerId, "amt": bond.bondAmt, "apr": bond.apr, "repayTime": bond.repaymentTime, "riskLevel": bond.riskLevel, "purpose": purposeMap[bond.bondPurpose]} for bond in purchased]
        return Response(dumps({
            "purchasedBonds": out
        }), status.HTTP_200_OK)

class UserBondsLoanerView(APIView):
    permission_classes = [IsAuthenticated]
    def post(self, request):
        body = loads(request.body)
        purchased = getIssuedBondsById(request["id"])
        out = [{"id": bond.id, "loanerId": bond.loanerId, "amt": bond.bondAmt, "apr": bond.apr, "repayTime": bond.repaymentTime, "riskLevel": bond.riskLevel, "purpose": purposeMap[bond.bondPurpose]} for bond in purchased]
        return Response(dumps({
            "issuedBonds": out
        }), status.HTTP_200_OK)


class StripeCheckout(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        try:
            print(STRIPE_API_KEY)
            stripe.api_key = STRIPE_API_KEY
            print(request.body)
            body = loads(request.body)
            customer = stripe.Customer.create()
            ephemeralKey = stripe.EphemeralKey.create(
                customer=customer['id'],
                stripe_version='2023-08-16',
            )
            paymentIntent = stripe.PaymentIntent.create(
                amount=int(float(body["amount"])* 100),
                currency='usd',
                customer=customer['id'],
                # In the latest version of the API, specifying the `automatic_payment_methods` parameter is optional because Stripe enables its functionality by default.
                automatic_payment_methods={
                'enabled': True,
                },
            )

            return Response(dumps(dict(
                paymentIntent=paymentIntent.client_secret,
                ephemeralKey=ephemeralKey.secret,
                customer=customer.id,
                publishableKey="pk_test_51O1C3jJZqzF5oB4gxbWnlsuXWCPtA9z180zvHbbmUH1N5kQ5RqgAsisA3IL334XV8oA1E4JfMV9OwNYLJYZuLYGx003L0MHSJn")
                ))
        except Exception as e:
            print(e)
            return Response(e, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
class StripeCheckoutSuccess(APIView):
    def post(self,request, pk):
        try:
            body = loads(request.body)
            bond = Bond.objects.update(id=pk, purchaserId=body["purchaserId"])
        except Exception as e:
            return Response(e, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        return Response("Payment Success", status=status.HTTP_200_OK)

class StripeCheckoutCancel(APIView):
    def post(request):
        body = loads(request)
        Bond.objects.update(id=body["bondUuid"], purchaserId=None, apr=None)
        return Response("Cancel payment", status=status.HTTP_200_OK)

class AuctionHandlingGet(APIView):
    def get(request):
        bonds = Bond.objects.filter(purchaseStatus=0)
        uuids = [bond.id for bond in bonds]

        res = loads(requests.post(BROKER_URL + "get_auctions", data=dumps({"uuids": uuids})))["aprs"]
        out = []

        for bond in bonds:
            if (bond.id in res):
                bond.apr = res[bond.id]
            out.append(bond)
        return Response(dumps({
            "bonds": out
        }), status=status.HTTP_200_OK)

class BondCreateView(generics.CreateAPIView):
    permission_classes = [AllowAny]
    serializer_class = BondSerializer
    queryset = Bond.objects.all()
    def perform_create(self, serializer):
        bond = serializer.save()  
        print({
                "bondId" : str(bond.id),
                "sellerId": bond.loanerId,
                "maxApr": bond.apr,
            })
        getBondGrade(bond.id)
        createBondAuction(
            {
                "bondId" : str(bond.id),
                "sellerId": bond.loanerId.email,
                "maxApr": bond.apr,
            }
        )
        
        return Response("Created Bond", status=status.HTTP_200_OK)

class AuctionHandlingCreate(APIView):
    permission_classes = [AllowAny]
    def post(self, request, pk):
        body = loads(request.body)
        bond = Bond.objects.get(id=body["bondId"])
        if (bond.purchaserId == None and body["sellerId"] == bond.loanerId.email):
            return Response("Created Successfully", status=status.HTTP_200_OK)
        
        return Response("Unsuccessful Auction Creation", status=status.HTTP_401_UNAUTHORIZED)

class AuctionHandlingFinish(APIView):
    permission_classes = [AllowAny]
    def post(self, request, pk):
        body = loads(request.body)
        Bond.objects.update(id = pk, purchaserId=body["auction"]["highestBidder"], apr=body["apr"])
        return Response("Successfully updated bond", status=status.HTTP_200_OK)