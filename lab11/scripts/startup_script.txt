# -*- coding: utf8 -*-
import fme, smtplib, ssl
from datetime import datetime


# get the email and password from user parameters
email = fme.macroValues['email']
password = fme.macroValues['password']
powiat = fme.macroValues['powiat']
reciever_email = fme.macroValues['client_email']

# timestamp
now = datetime.now()
timestamp = now.strftime("%d/%m/%Y %H:%M:%S")



def send_email(sender_email, reciever_email, message ):
    # for SSL
    port = 465
    # SSL context
    context = ssl.create_default_context()

    with smtplib.SMTP_SSL("smtp.gmail.com", port, context=context) as server:
        server.login(email, password)
        server.sendmail(sender_email, reciever_email, message)



message_content = """\
Subject: Nowe przetwarzanie!

Drogi uzytkowniku {0}, o godzinie {1} rozpoczeto przetwarzanie danych dla powiatu {2}."""
message = message_content.format(reciever_email, timestamp, powiat)

send_email(email, reciever_email, message,)
