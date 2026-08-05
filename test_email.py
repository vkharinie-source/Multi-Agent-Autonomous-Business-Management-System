import os
import re
import sys
import smtplib
from email.message import EmailMessage
from dotenv import load_dotenv

# 1. Locate and load .env dynamically
load_dotenv()  # Load from CWD first

# Try relative paths
script_dir = os.path.dirname(os.path.abspath(__file__))
env_candidates = [
    os.path.join(script_dir, ".env"),
    os.path.join(script_dir, "backend", ".env"),
    os.path.join(script_dir, "..", ".env"),
]

for path in env_candidates:
    if os.path.exists(path):
        load_dotenv(dotenv_path=path, override=True)
        break


def validate_email_format(email: str) -> bool:
    """
    Validates the structure of the recipient email address using a standard regex.
    """
    email_regex = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$"
    return bool(re.match(email_regex, email))


def run_test():
    print("=" * 60)
    print("GMAIL SMTP EMAIL SERVICE DIAGNOSTIC TEST")
    print("=" * 60)

    # 2. Retrieve credentials and clean whitespace
    raw_smtp_email = os.getenv("SMTP_EMAIL")
    raw_smtp_password = os.getenv("SMTP_APP_PASSWORD")

    sender_email = raw_smtp_email.strip() if raw_smtp_email else ""
    app_password = raw_smtp_password.replace(" ", "").strip() if raw_smtp_password else ""

    print(f"Loaded SMTP_EMAIL: '{sender_email}'")
    # Mask password for security log
    masked_pw = app_password[:3] + "*" * (len(app_password) - 6) + app_password[-3:] if len(app_password) > 6 else "***"
    print(f"Loaded SMTP_APP_PASSWORD: '{masked_pw}' (spaces removed, total length: {len(app_password)} chars)")

    # 3. Validate environment variables
    if not sender_email:
        print("SMTP authentication failed: SMTP_EMAIL is missing in .env")
        print("\nERROR: Please make sure SMTP_EMAIL is defined in your .env file.")
        sys.exit(1)

    if not app_password:
        print("SMTP authentication failed: SMTP_APP_PASSWORD is missing in .env")
        print("\nERROR: Please make sure SMTP_APP_PASSWORD is defined in your .env file.")
        sys.exit(1)

    # By default, send the test email to yourself (sender_email) to verify loopback delivery
    receiver_email = sender_email
    print(f"Using test receiver address (sender loopback): '{receiver_email}'")

    # 4. Verify receiver email before sending
    if not validate_email_format(receiver_email):
        print(f"Recipient rejected: '{receiver_email}' is not a valid email format.")
        sys.exit(1)

    # 5. Construct EmailMessage correctly and verify headers
    message = EmailMessage()
    message["Subject"] = "Autonomous Business AI - Standalone SMTP Test"
    message["From"] = sender_email
    message["To"] = receiver_email

    # Plain text content
    text_content = """Hello,

This is a standalone test email from your Autonomous Business AI backend configuration.

If you are reading this, the Gmail SMTP delivery system is working successfully from the command line!

Regards,
Autonomous Business AI Team
""".strip()
    message.set_content(text_content)

    # HTML content
    html_content = """<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Standalone SMTP Test</title>
</head>
<body style="margin: 0; padding: 24px; background-color: #f4f1ff; font-family: Arial, sans-serif;">
    <div style="max-width: 560px; margin: 20px auto; background-color: #ffffff; border-radius: 20px; padding: 36px; box-shadow: 0 12px 35px rgba(70, 50, 140, 0.12);">
        <div style="text-align: center;">
            <div style="font-size: 48px;">🚀</div>
            <h1 style="color: #241d42; margin-bottom: 12px;">SMTP Test Successful!</h1>
            <p style="color: #6f6981; font-size: 16px; line-height: 1.6;">
                The email delivery system was successfully audited and verified.
            </p>
            <div style="margin: 28px 0; padding: 20px; background-color: #f1edff; border-radius: 16px;">
                <span style="font-size: 24px; font-weight: bold; color: #6c5ce7;">CONNECTION VERIFIED</span>
            </div>
            <p style="color: #777083; font-size: 14px;">This was sent using Gmail SMTP SSL on port 465.</p>
        </div>
    </div>
</body>
</html>
"""
    message.add_alternative(html_content, subtype="html")

    # Double check headers are set
    assert message["From"] == sender_email, "From header mismatch"
    assert message["To"] == receiver_email, "To header mismatch"
    assert message["Subject"] == "Autonomous Business AI - Standalone SMTP Test", "Subject header mismatch"

    # 6. SMTP login and delivery with detailed error handling
    try:
        print(f"Sending OTP email from {sender_email} ...")
        print(f"Sending OTP to {receiver_email} ...")

        # Connect to smtp.gmail.com over SSL on port 465
        print("Connecting to smtp.gmail.com:465...")
        with smtplib.SMTP_SSL("smtp.gmail.com", 465, timeout=30) as smtp:
            print("Connected. Logging in...")
            smtp.login(sender_email, app_password)
            print("SMTP login successful")

            print("Sending message...")
            smtp.send_message(message)

        print("Email sent successfully")
        print("\n" + "=" * 60)
        print("SUCCESS: SMTP transaction completed without errors!")
        print("=" * 60)
        print("\nIf the email does not appear in your inbox, check the following reasons:")
        print("1. Spam Folder: Gmail may flag new automated emails as spam.")
        print("2. Promotions Folder: HTML/templated emails are often categorized under Promotions.")
        print("3. Gmail Security: Google might delay delivery for security screening.")
        print("4. Incorrect Receiver Address: Ensure there are no typos in the receiver email.")
        print("5. Google App Password Issues: Verify the App Password is active in your Google Account.")
        print("6. Gmail Account Restrictions: Verify the sending account is not suspended or restricted.")
        print("=" * 60)

    except smtplib.SMTPAuthenticationError as error:
        print("SMTP authentication failed:", repr(error))
        print("\n[DIAGNOSIS] Please verify that:")
        print("  - The email address is exactly correct.")
        print("  - You are using a 16-character Google App Password (not your main Google account password).")
        print("  - 2-Step Verification is enabled on your Google Account (required for App Passwords).")
        sys.exit(1)

    except smtplib.SMTPRecipientsRefused as error:
        print("Recipient rejected:", repr(error))
        print("\n[DIAGNOSIS] The receiver address was rejected by Gmail. Verify the receiver address is valid.")
        sys.exit(1)

    except smtplib.SMTPException as error:
        print("Unexpected SMTP error:", repr(error))
        print(f"\n[DIAGNOSIS] SMTP level protocol error: {error}")
        sys.exit(1)

    except Exception as error:
        print("Unexpected email error:", repr(error))
        print(f"\n[DIAGNOSIS] General connection or environment issue: {error}")
        sys.exit(1)


if __name__ == "__main__":
    run_test()
