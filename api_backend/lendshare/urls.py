
from .views import BondList, UserList, StripeCheckout, RegisterUserAPIView, StripeCheckoutSuccess, StripeCheckoutCancel, AuctionHandlingCreate, AuctionHandlingFinish, UserBondsPurchasedView, UserBondsLoanerView, AuctionHandlingGet, BondCreateView
from django.urls import path
from rest_framework.authtoken.views import obtain_auth_token



urlpatterns = [
    path("bond/<uuid:pk>/", BondList.as_view()),  # Use angle brackets for path converters
    path("bond/create", BondCreateView.as_view()),
    path("users/<uuid:pk>/", UserList.as_view()),  # Use angle brackets for path converters
    path('register/', RegisterUserAPIView.as_view()),  # Add a trailing slash
    path('token-auth/', obtain_auth_token),
    path("pay/create_checkout_session", StripeCheckout.as_view()),
    path("pay/cancel/<uuid:pk>", StripeCheckoutCancel.as_view()),
    path("pay/success/<uuid:pk>", StripeCheckoutSuccess.as_view()),
    path("create_auction/<uuid:pk>", AuctionHandlingCreate.as_view()),
    path("finish_auction/<uuid:pk>", AuctionHandlingFinish.as_view()),
    path("auctions/get", AuctionHandlingGet.as_view()),
    path("bonds/purchased/<uuid:pk>", UserBondsPurchasedView.as_view()),
    path("bonds/issued/<uuid:pk>", UserBondsLoanerView.as_view())
]