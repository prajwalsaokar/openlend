from django.db import models
import uuid
from django.contrib.auth.models import AbstractUser
from django.contrib.auth.models import BaseUserManager
import random
from json import dumps


class RiskFactor(models.Model):
    FACTORS = (
        (0, "Mortgage"),
        (1, "Rent"),
        (2, "Own"),
        (3, "Any"),  # unexposed to the user
        (4, "Null"),  # None
        (5, "Other")
    )
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    homeOwnership = models.IntegerField(
        choices=FACTORS,
        default=3
    )
    income = models.FloatField()
    totalDebt = models.FloatField()
    liquidAssets = models.FloatField()
    nonLiquidAssets = models.FloatField()
    


class CustomUserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError(_('The Email field must be set'))
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError(_('Superuser must have is_staff=True.'))
        if extra_fields.get('is_superuser') is not True:
            raise ValueError(_('Superuser must have is_superuser=True.'))

        return self.create_user(email, password, **extra_fields)


class CustomUser(AbstractUser):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4,editable=False)
    username = None
    first_name = models.TextField()
    second_name = models.TextField()
    email = models.EmailField(unique=True)
    verified = models.BooleanField(default = False)
    riskFactors = models.ForeignKey(RiskFactor, on_delete=models.SET_NULL, null = True, default = None, blank = True)
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []
    objects = CustomUserManager()

class Bond(models.Model):
    PURPOSES = (
        (5, "Misc"),
        (1, "Business"),
        (9, "Health"),
        (3, "Consumption"),
        (13, "Education"),
        (0, "Consolidation"),
        (2, "HomeImprovement"),
        (4, "CreditCard"),
        (6, "House"),
        (7, "Vacation"),
        (8, "Car"),
        (10, "Moving"),
        (12, "Wedding"),
    )

    BooleanValues = (
        (0, 'False'),
        (1, 'True'),
    )
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    loanerId = models.ForeignKey(CustomUser, on_delete=models.SET_NULL, null = True, blank = True, related_name='+', to_field="email") # need to handle in views because hashed
    purchaserId = models.ForeignKey(CustomUser, on_delete=models.SET_NULL, null = True, blank = True, default = None, related_name='+', to_field="email")
    bondAmt = models.FloatField()
    apr = models.FloatField()
    repaymentTime = models.DateTimeField() # store as UTC coordinate
    random_factor = round(random.uniform(0.3, 1), 1)
    riskLevel = models.IntegerField(null = True, blank = True, default = 5)
    bondPurpose = models.IntegerField(choices=PURPOSES, default=5)
    
    

    purchaseStatus = models.IntegerField(choices=BooleanValues, default = 0)
