from rest_framework import serializers
from django.conf import settings
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.contrib.auth import get_user_model

User = get_user_model()


# -------------------- REGISTER SERIALIZER --------------------
class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    organizationName = serializers.CharField(write_only=True, required=False, allow_blank=True, allow_null=True)
    organizationCode = serializers.CharField(write_only=True, required=False, allow_blank=True, allow_null=True)

    class Meta:
        model = User
        fields = [
            'id', 'fullName', 'email', 'password',
            'cnic', 'phoneNumber', 'role',
            'organizationName', 'organizationCode'
        ]

    def validate(self, attrs):
        role = attrs.get('role', 'user')

        # When admin, verify org name + code
        if role == 'admin':
            org_name = attrs.get('organizationName')
            org_code = attrs.get('organizationCode')

            allowed_orgs = getattr(settings, "ALLOWED_ORGANIZATIONS", {})

            if org_name not in allowed_orgs or allowed_orgs[org_name] != org_code:
                raise serializers.ValidationError("Invalid organization name or code for admin registration.")

        return attrs

    def create(self, validated_data):
        validated_data.pop("organizationName", None)
        validated_data.pop("organizationCode", None)

        user = User.objects.create_user(
            fullName=validated_data.get('fullName', ''),
            email=validated_data.get('email', ''),
            password=validated_data.get('password', ''),
            cnic=validated_data.get('cnic', ''),
            phoneNumber=validated_data.get('phoneNumber', ''),
            role=validated_data.get('role', 'user')
        )
        return user


# -------------------- USER SERIALIZER --------------------
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'email', 'fullName', 'cnic', 'phoneNumber', 'role']


# -------------------- CUSTOM JWT SERIALIZER --------------------
class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token['email'] = user.email
        token['fullName'] = user.fullName
        token['role'] = user.role
        return token

    def validate(self, attrs):
        data = super().validate(attrs)
        data['user'] = {
            'id': self.user.id,
            'email': self.user.email,
            'fullName': self.user.fullName,
            'role': self.user.role,
        }
        return data


# -------------------- FORGOT / RESET PASSWORD SERIALIZERS --------------------
class ForgotPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField()

    def validate_email(self, value):
        if not User.objects.filter(email=value).exists():
            raise serializers.ValidationError("No user found with this email.")
        return value


class VerifyOTPSerializer(serializers.Serializer):
    email = serializers.EmailField()
    otp = serializers.CharField(max_length=6)


class ResetPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField()
    new_password = serializers.CharField(write_only=True, min_length=6)


# -------------------- UPDATE PROFILE SERIALIZER --------------------
class UpdateProfileSerializer(serializers.ModelSerializer):
    fullName = serializers.CharField(required=False)
    phoneNumber = serializers.CharField(required=False)

    class Meta:
        model = User
        fields = ["fullName", "phoneNumber"]

    def validate_phoneNumber(self, value):
        if value and not value.isdigit():
            raise serializers.ValidationError("Phone number must contain digits only.")
        return value

    def update(self, instance, validated_data):
        instance.fullName = validated_data.get("fullName", instance.fullName)
        instance.phoneNumber = validated_data.get("phoneNumber", instance.phoneNumber)
        instance.save()
        return instance
