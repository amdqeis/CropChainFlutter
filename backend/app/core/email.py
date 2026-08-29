from fastapi_mail import ConnectionConfig, FastMail, MessageSchema, MessageType
from app.core.config import settings

# Email connection configuration
mail_config = ConnectionConfig(
    MAIL_USERNAME=settings.MAIL_USERNAME,
    MAIL_PASSWORD=settings.MAIL_PASSWORD,
    MAIL_FROM=settings.MAIL_FROM,
    MAIL_PORT=settings.MAIL_PORT,
    MAIL_SERVER=settings.MAIL_SERVER,
    MAIL_FROM_NAME=settings.MAIL_FROM_NAME,
    MAIL_STARTTLS=settings.MAIL_STARTTLS,
    MAIL_SSL_TLS=settings.MAIL_SSL_TLS,
    USE_CREDENTIALS=True,
    VALIDATE_CERTS=True,
)

fast_mail = FastMail(mail_config)


async def send_otp_email(email_to: str, otp_code: str, full_name: str) -> None:
    """
    Send OTP verification code to user's email.
    Used during registration and resend OTP flows.
    """
    if not settings.MAIL_USERNAME:
        raise RuntimeError("SMTP belum dikonfigurasi.")
    html_body = f"""
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: auto;">
        <h2 style="color: #2d7a3a;">CropChain — Verifikasi Email</h2>
        <p>Halo, <strong>{full_name}</strong>!</p>
        <p>Berikut adalah kode OTP untuk verifikasi akun Anda:</p>
        <div style="
            background: #f4f7f4;
            border: 2px solid #2d7a3a;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            margin: 20px 0;
        ">
            <span style="font-size: 36px; font-weight: bold; letter-spacing: 8px; color: #2d7a3a;">
                {otp_code}
            </span>
        </div>
        <p>Kode ini berlaku selama <strong>{settings.OTP_EXPIRE_MINUTES} menit</strong>.</p>
        <p style="color: #888;">Jika Anda tidak mendaftar di CropChain, abaikan email ini.</p>
        <hr style="border-color: #e0e0e0;">
        <p style="font-size: 12px; color: #aaa;">CropChain — Menghubungkan Petani &amp; Distributor Indonesia</p>
    </div>
    """

    message = MessageSchema(
        subject="Kode Verifikasi CropChain",
        recipients=[email_to],
        body=html_body,
        subtype=MessageType.html,
    )

    await fast_mail.send_message(message)


async def send_password_reset_email(email_to: str, reset_token: str, full_name: str) -> None:
    """
    Send password reset link to user's email.
    The reset_token is used to verify the reset request.
    """
    if not settings.MAIL_USERNAME:
        raise RuntimeError("SMTP belum dikonfigurasi.")
    # In production, this should be the frontend URL
    reset_link = f"https://cropchain.id/reset-password?token={reset_token}"

    html_body = f"""
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: auto;">
        <h2 style="color: #2d7a3a;">CropChain — Reset Password</h2>
        <p>Halo, <strong>{full_name}</strong>!</p>
        <p>Kami menerima permintaan reset password untuk akun Anda.</p>
        <p>Klik tombol di bawah ini untuk mereset password Anda:</p>
        <div style="text-align: center; margin: 30px 0;">
            <a href="{reset_link}" style="
                background: #2d7a3a;
                color: white;
                padding: 14px 28px;
                border-radius: 6px;
                text-decoration: none;
                font-weight: bold;
            ">Reset Password</a>
        </div>
        <p>Link ini berlaku selama <strong>30 menit</strong>.</p>
        <p>Jika Anda tidak meminta reset password, abaikan email ini — akun Anda tetap aman.</p>
        <hr style="border-color: #e0e0e0;">
        <p style="font-size: 12px; color: #aaa;">CropChain — Menghubungkan Petani &amp; Distributor Indonesia</p>
    </div>
    """

    message = MessageSchema(
        subject="Reset Password CropChain",
        recipients=[email_to],
        body=html_body,
        subtype=MessageType.html,
    )

    await fast_mail.send_message(message)
