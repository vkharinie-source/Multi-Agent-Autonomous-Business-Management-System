import os
import smtplib
from email.message import EmailMessage

from dotenv import load_dotenv


load_dotenv()

SMTP_EMAIL = os.getenv("SMTP_EMAIL")
SMTP_APP_PASSWORD = os.getenv("SMTP_APP_PASSWORD")


def send_password_reset_otp_email(
    receiver_email: str,
    receiver_name: str,
    otp: str,
) -> None:
    sender_email = (
        SMTP_EMAIL.strip()
        if SMTP_EMAIL
        else ""
    )

    app_password = (
        SMTP_APP_PASSWORD.replace(" ", "").strip()
        if SMTP_APP_PASSWORD
        else ""
    )

    receiver_email = receiver_email.strip().lower()
    receiver_name = receiver_name.strip() or "User"

    if not sender_email:
        raise ValueError(
            "SMTP_EMAIL is missing in .env"
        )

    if not app_password:
        raise ValueError(
            "SMTP_APP_PASSWORD is missing in .env"
        )

    message = EmailMessage()

    message["Subject"] = (
        "Reset your Autonomous Business AI password"
    )
    message["From"] = sender_email
    message["To"] = receiver_email

    message.set_content(
        f"""
Hello {receiver_name},

We received a request to reset your Autonomous Business AI password.

Your password reset OTP is:

{otp}

This OTP will expire in 5 minutes.

If you did not request a password reset, you can ignore this email.

Do not share this OTP with anyone.

Regards,
Autonomous Business AI Team
""".strip()
    )

    html_content = f"""
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
</head>

<body style="
    margin: 0;
    padding: 24px;
    background-color: #f4f1ff;
    font-family: Arial, sans-serif;
">
    <div style="
        max-width: 560px;
        margin: 20px auto;
        background-color: #ffffff;
        border-radius: 20px;
        padding: 36px;
        box-shadow: 0 12px 35px rgba(70, 50, 140, 0.12);
    ">
        <div style="text-align: center;">
            <div style="font-size: 48px;">
                🔐
            </div>

            <h1 style="
                color: #241d42;
                margin-bottom: 12px;
            ">
                Reset your password
            </h1>

            <p style="
                color: #6f6981;
                font-size: 16px;
                line-height: 1.6;
            ">
                Hello {receiver_name}, use the verification
                code below to reset your password.
            </p>

            <div style="
                margin: 28px 0;
                padding: 20px;
                background-color: #f1edff;
                border-radius: 16px;
            ">
                <span style="
                    font-size: 36px;
                    font-weight: bold;
                    letter-spacing: 10px;
                    color: #6c5ce7;
                ">
                    {otp}
                </span>
            </div>

            <p style="
                color: #777083;
                font-size: 14px;
            ">
                This OTP expires in 5 minutes.
            </p>

            <p style="
                color: #9993a4;
                font-size: 12px;
                margin-top: 30px;
                line-height: 1.6;
            ">
                If you did not request a password reset,
                you can safely ignore this email.
            </p>

            <p style="
                color: #9993a4;
                font-size: 12px;
            ">
                Never share this verification code with anyone.
            </p>
        </div>
    </div>
</body>
</html>
"""

    message.add_alternative(
        html_content,
        subtype="html",
    )

    try:
        print(
            f"Sending password reset OTP from "
            f"{sender_email} to {receiver_email}"
        )

        with smtplib.SMTP_SSL(
            "smtp.gmail.com",
            465,
            timeout=30,
        ) as smtp:
            smtp.login(
                sender_email,
                app_password,
            )

            smtp.send_message(message)

        print(
            f"Password reset OTP sent successfully "
            f"to {receiver_email}"
        )

    except smtplib.SMTPAuthenticationError as error:
        print(
            "SMTP authentication failed:",
            repr(error),
        )

        raise RuntimeError(
            "Gmail authentication failed. Check "
            "SMTP_EMAIL and SMTP_APP_PASSWORD."
        ) from error

    except smtplib.SMTPRecipientsRefused as error:
        print(
            "Receiver email was refused:",
            repr(error),
        )

        raise RuntimeError(
            f"Gmail rejected receiver address: "
            f"{receiver_email}"
        ) from error

    except smtplib.SMTPException as error:
        print(
            "SMTP error:",
            repr(error),
        )

        raise RuntimeError(
            f"Unable to send password reset OTP: {error}"
        ) from error

    except Exception as error:
        print(
            "Unexpected password reset email error:",
            repr(error),
        )

        raise RuntimeError(
            f"Unexpected email sending error: {error}"
        ) from error