from pydantic import BaseModel, EmailStr, Field, field_validator


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class VerifyResetOtpRequest(BaseModel):
    email: EmailStr

    otp: str = Field(
        ...,
        min_length=6,
        max_length=6,
    )

    @field_validator("otp")
    @classmethod
    def validate_otp(cls, value: str) -> str:
        cleaned_otp = value.strip()

        if not cleaned_otp.isdigit():
            raise ValueError(
                "OTP must contain only numbers"
            )

        return cleaned_otp


class ResetPasswordRequest(BaseModel):
    email: EmailStr

    otp: str = Field(
        ...,
        min_length=6,
        max_length=6,
    )

    new_password: str = Field(
        ...,
        min_length=8,
        max_length=128,
    )

    confirm_password: str = Field(
        ...,
        min_length=8,
        max_length=128,
    )

    @field_validator("otp")
    @classmethod
    def validate_otp(cls, value: str) -> str:
        cleaned_otp = value.strip()

        if not cleaned_otp.isdigit():
            raise ValueError(
                "OTP must contain only numbers"
            )

        return cleaned_otp

    @field_validator("new_password")
    @classmethod
    def validate_new_password(
        cls,
        value: str,
    ) -> str:
        password = value.strip()

        if len(password) < 8:
            raise ValueError(
                "Password must contain at least 8 characters"
            )

        if not any(character.isupper() for character in password):
            raise ValueError(
                "Password must contain at least one uppercase letter"
            )

        if not any(character.islower() for character in password):
            raise ValueError(
                "Password must contain at least one lowercase letter"
            )

        if not any(character.isdigit() for character in password):
            raise ValueError(
                "Password must contain at least one number"
            )

        return password