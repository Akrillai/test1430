# FROM python:3.8.10-alpine
# ARG APPVERSION
# ENV APPVERSION=$APPVERSION \
#     FLASK_APP=app \
#     FLASK_DEBUG=on
# WORKDIR /application
# COPY ["app.py", "requirements.txt", "./"]
# RUN pip install -r requirements.txt
# EXPOSE 5000
# CMD ["flask", "run", "--host=0.0.0.0"]

FROM tomcat:latest

ADD hello-1.0.war /usr/local/tomcat/webapps/

EXPOSE 8080

CMD ["catalina.sh", "run"]