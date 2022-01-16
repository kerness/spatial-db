import fme, smtplib, ssl
from datetime import datetime
from email.mime.multipart import MIMEMultipart 
from email.mime.text import MIMEText 
from email.mime.application import MIMEApplication
import os
import json




#get the email and password from user parameters
email = fme.macroValues['email']
password = fme.macroValues['password']
powiat = fme.macroValues['powiat']
reciever_email = fme.macroValues['client_email']
start_date =  fme.macroValues['start_date']
end_date =  fme.macroValues['end_date']
cloud =  fme.macroValues['cloud']
proc_duration = str(round(fme.elapsedRunTime, 0))


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


def create_log_file(powiat, start_date, end_date, cloud):
    dictionary = {
    "powiat" : powiat,
    "start_date" : start_date,
    "end_date"  : end_date,
    "colud_coverage" : cloud
    }
    json_log = json.dumps(dictionary, indent=4)
    with open(jsonPath, "w") as outfile:
        outfile.write(json_log)
    


# prepare a message
message = MIMEMultipart('mixed')
message['From'] = 'Contact <{sender}>'.format(sender = email)
message['To'] = reciever_email


# paths
file_name = powiat + r".tif"
attachmentPath = os.path.join(r"C:\Users\kek\Desktop\SDB\cw11\res" , file_name)
jsonPath = os.path.join(r"C:\Users\kek\Desktop\SDB\cw11\res" , "log.geojson")


status = fme.status
if status == 0: # if there is an error
    create_log_file(powiat, start_date, end_date, cloud)
    message['Subject'] = 'Przetwarzanie zakończone błędem!'
    
    msg_content = """

    <h3>Drogi uzytkowniku {0}, o godzinie {1} wystąpił błąd w przetwarzaniu danych dla powiatu {2}.</h3> <br>
    Prawdopodobny brak zobrazowań dla parametrów przesłąnych w załączniku.
    """.format(reciever_email, timestamp, powiat)
    body = MIMEText(msg_content, 'html')
    message.attach(body)
    try:
        with open(jsonPath, "rb") as attachment:
            p = MIMEApplication(attachment.read(),_subtype="json")
            p.add_header('Content-Disposition', "attachment; filename= %s" % jsonPath.split("\\")[-1])
            message.attach(p)
    except Exception as e:
	    print(str(e))

else: # if everything is cool

    rast_mean =  round(fme.macroValues['mean'], 3)
    rast_stdev =  round(fme.macroValues['stdev'], 3)

    message['Subject'] = 'Przetwarzanie zakończone!'
    msg_content = """

    <h3>Drogi uzytkowniku {0}, o godzinie {1} zakonczone zostalo przetwarzanie danych dla powiatu {2}.</h3> <br>

    Czas trwania przetwarzania: {3} s
    Statystyki wynikowego rastra:
    <ul>
    <li>Średnia: {4}</li>
    <li>Odchylenie standardowe: {5}</li>
    </ul>
    Raster został przesłany w załączniku
    """.format(reciever_email, timestamp, powiat, proc_duration, str(rast_mean), str(rast_stdev))
    
    body = MIMEText(msg_content, 'html')
    message.attach(body)
    try:
        with open(attachmentPath, "rb") as attachment:
            p = MIMEApplication(attachment.read(),_subtype="tif")
            p.add_header('Content-Disposition', "attachment; filename= %s" % attachmentPath.split("\\")[-1])
            message.attach(p)
    except Exception as e:
	    print(str(e))

print(proc_duration)
# finally, send the message
body = MIMEText(msg_content, 'html')
send_email(email, reciever_email, message.as_string(),)
