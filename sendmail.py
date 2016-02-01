# -*- coding: utf-8 -*-
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os

mailto_list=["acceptor@wind.com.cn"]
smtp = "smtp.163.com.cn"
sender = "diweis@163.com"
user = "diweis@163.com"
password = "xxxxx"

def checkprocess(path): 
    os.system(path)

def sendmail(tolist,sub):
    msg = MIMEMultipart()
    att1 = MIMEText(open('/data/test/Info.log', 'rb').read(), 'utf-8')
    att1["Content-Disposition"] = 'attachment; filename="Info.txt"'
    msg.attach(att1)
    msg['Subject'] = sub
    msg['From'] = sender
    msg['To'] = ";".join(tolist)

    try:
        s = smtplib.SMTP()
        s.connect(smtp)
        s.login(user,password)
        s.sendmail(sender,tolist,msg.as_string())
        s.quit()
        return True
    except Exception,e:
        print "exception: ",str(e)
        return False

if __name__ == '__main__':
    checkprocess("/data/test/checkServer.sh 2")
    
    if sendmail(mailto_list,"Maintenance Notification!"):
        print "send success!"
        checkprocess("/data/test/clean.sh");
    else:
        print "send failed!"
