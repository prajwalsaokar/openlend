from .models import CustomUser, Bond
from rest_framework import serializers
from django.contrib.auth import get_user_model
from rest_framework.response import Response
from rest_framework import status
from rest_framework.validators import UniqueValidator
from django.contrib.auth.password_validation import validate_password


class StripeSerializer(serializers.Serializer):
      amount = serializers.FloatField()



class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    class Meta:
        model = CustomUser
        fields = ['id', 'bondsCreated', 'bondsPurchased', 'riskFactors', 'verified']

class RegisterSerializer(serializers.ModelSerializer):
  email = serializers.EmailField(
    required=True,
    validators=[UniqueValidator(queryset=CustomUser.objects.all())]
  )
  class Meta:
    model = CustomUser
    fields = ('email', 'password',
          'first_name', 'last_name')
    extra_kwargs = {
      'first_name': {'required': True},
      'last_name': {'required': True}
    }

  def create(self, validated_data):
    user = CustomUser.objects.create(
      email=validated_data['email'],
      first_name=validated_data['first_name'],
      last_name=validated_data['last_name']
    )
    user.set_password(validated_data['password'])
    user.save()
    return user



        
    
class BondSerializer(serializers.ModelSerializer):
    class Meta:
        model = Bond
        fields = ['id', 'loanerId', 'purchaserId', 'bondAmt', 'apr', 'repaymentTime', 'riskLevel', 'bondPurpose']
