from django.db import models

# Create your models here.
from django.contrib.auth.models import AbstractUser

class CustomUser(AbstractUser):

    ROLE_CHOICES = [
        ('TL', 'Team Lead'),
        ('RCLM', 'RCLM'),
        ('CLM', 'CLM'),
        ('CITY_HEAD', 'City Head'),
    ]

    region = models.CharField(max_length=100)
    designation = models.CharField(max_length=20, choices=ROLE_CHOICES)

    def __str__(self):
        return self.username