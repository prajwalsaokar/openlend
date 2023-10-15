from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser, Bond, RiskFactor


# Register your models here.
admin.site.register(CustomUser)
admin.site.register(Bond)
admin.site.register(RiskFactor)


