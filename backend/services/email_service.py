import os
import re
import smtplib
from email.message import EmailMessage
from dotenv import load_dotenv

# 1. Load environment variables dynamically from multiple fallback locations
load_dotenv()  # From current working directory

# Also load explicitly from the expected backend/ directory relative to this file
env_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".env")
if os.path.exists(env_path):
    load_dotenv(dotenv_path=env_path, override=True)


def validate_email_format(email: str) -> bool:
    """
    Validates the structure of the recipient email address using a standard regex.
    """
    email_regex = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$"
    return bool(re.match(email_regex, email))


# Fallback credentials in case Render environment variables are not yet set
FALLBACK_SMTP_EMAIL = "harinievk@gmail.com"
FALLBACK_SMTP_APP_PASSWORD = "cqua obaz bkjb jbsj"


def send_otp_email(
    receiver_email: str,
    receiver_name: str,
    otp: str,
) -> None:
    """
    Sends a verification OTP email containing both plain text and HTML parts using Gmail SMTP (Port 587 with STARTTLS, fallback to Port 465).
    """
    # 2. Retrieve credentials and clean whitespace
    raw_smtp_email = os.getenv("SMTP_EMAIL") or FALLBACK_SMTP_EMAIL
    raw_smtp_password = os.getenv("SMTP_APP_PASSWORD") or FALLBACK_SMTP_APP_PASSWORD

    # Remove all leading/trailing whitespace
    sender_email = raw_smtp_email.strip() if raw_smtp_email else ""
    # Remove all spaces from the App Password (Gmail app passwords are 16 chars, e.g., "abcd efgh ijkl mnop")
    app_password = raw_smtp_password.replace(" ", "").strip() if raw_smtp_password else ""

    receiver_email = receiver_email.strip() if receiver_email else ""
    receiver_name = receiver_name.strip() if receiver_name else "User"
    otp = otp.strip() if otp else ""

    # Always log OTP prominently to backend terminal
    print("\n" + "=" * 60)
    print(f"[OTP LOG] Recipient: {receiver_email} ({receiver_name})")
    print(f"[OTP LOG] OTP Code:  {otp}")
    print("=" * 60 + "\n")

    # 4. Verify the receiver email and OTP before sending
    if not receiver_email:
        print("Recipient rejected: Receiver email is empty")
        raise RuntimeError("Receiver email address is empty and cannot be sent to.")

    if not validate_email_format(receiver_email):
        print(f"Recipient rejected: '{receiver_email}' is not a valid email format.")
        raise RuntimeError(f"The receiver email address '{receiver_email}' is invalid.")

    if not otp:
        raise RuntimeError("OTP value is empty or not provided.")

    # 3. Check environment variables
    if not sender_email or not app_password:
        print("[EMAIL SERVICE] SMTP_EMAIL or SMTP_APP_PASSWORD is not configured.")
        print(f"[EMAIL SERVICE] Using logged OTP '{otp}' for verification.")
        return

    # 5. Construct EmailMessage correctly and verify headers
    message = EmailMessage()
    message["Subject"] = "Verify your Autonomous Business AI account"
    message["From"] = sender_email
    message["To"] = receiver_email

    # Plain text content
    text_content = f"""Hello {receiver_name},

Your Autonomous Business AI verification OTP is:

{otp}

This OTP will expire in 5 minutes.

Do not share this OTP with anyone.

Regards,
Autonomous Business AI Team
""".strip()

    message.set_content(text_content)

    # HTML content
    html_content = f"""<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Verify Your Email</title>
</head>
<body style="margin: 0; padding: 24px; background-color: #f4f1ff; font-family: Arial, sans-serif;">
    <div style="max-width: 560px; margin: 20px auto; background-color: #ffffff; border-radius: 20px; padding: 36px; box-shadow: 0 12px 35px rgba(70, 50, 140, 0.12);">
        <div style="text-align: center;">
            <div style="font-size: 48px;">✨</div>
            <h1 style="color: #241d42; margin-bottom: 12px;">Verify your email</h1>
            <p style="color: #6f6981; font-size: 16px; line-height: 1.6;">
                Hello {receiver_name}, use the verification code below to complete your registration.
            </p>
            <div style="margin: 28px 0; padding: 20px; background-color: #f1edff; border-radius: 16px;">
                <span style="font-size: 36px; font-weight: bold; letter-spacing: 10px; color: #6c5ce7;">{otp}</span>
            </div>
            <p style="color: #777083; font-size: 14px;">This OTP expires in 5 minutes.</p>
            <p style="color: #9993a4; font-size: 12px; margin-top: 30px;">Do not share this verification code with anyone.</p>
        </div>
    </div>
</body>
</html>
"""

    message.add_alternative(html_content, subtype="html")

    # 6. SMTP delivery: Try Port 587 (STARTTLS - universally supported on cloud & local) first, fallback to 465 (SSL)
    delivered = False
    try:
        print(f"Sending OTP email via Gmail SMTP Port 587 (STARTTLS) to {receiver_email} ...")
        with smtplib.SMTP("smtp.gmail.com", 587, timeout=15) as smtp:
            smtp.starttls()
            smtp.login(sender_email, app_password)
            smtp.send_message(message)
        delivered = True
        print(f"[SUCCESS] OTP email successfully delivered to {receiver_email} via Port 587")
    except Exception as err587:
        print(f"[EMAIL SERVICE] Port 587 delivery attempt failed: {err587}. Retrying with Port 465...")
        try:
            with smtplib.SMTP_SSL("smtp.gmail.com", 465, timeout=15) as smtp:
                smtp.login(sender_email, app_password)
                smtp.send_message(message)
            delivered = True
            print(f"[SUCCESS] OTP email successfully delivered to {receiver_email} via Port 465")
        except Exception as err465:
            print(f"[EMAIL SERVICE WARNING] SMTP email delivery failed on both ports: 587: {err587}, 465: {err465}")
            print(f"[EMAIL SERVICE WARNING] Logged OTP '{otp}' above for manual verification.")