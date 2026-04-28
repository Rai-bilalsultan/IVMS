# yourapp/backends.py
import ssl
from django.core.mail.backends.smtp import EmailBackend as DjangoSMTPBackend

class UnverifiedSMTPBackend(DjangoSMTPBackend):
    """
    SMTP backend that uses an SSLContext with certificate verification turned off.
    For TESTING ONLY.
    """

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        # Create an SSL context that does NOT verify certificates
        # (for testing only)
        try:
            ctx = ssl.create_default_context()
            ctx.check_hostname = False
            ctx.verify_mode = ssl.CERT_NONE
            self.ssl_context = ctx
        except Exception:
            # Fallback: leave ssl_context as None (Django will use default behavior)
            self.ssl_context = None
