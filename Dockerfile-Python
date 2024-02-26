FROM python:3.12-alpine
#FROM alpine:latest
RUN mkdir /opt/app
WORKDIR /opt/app
COPY requirements.txt requirements.txt
#RUN apk add rrdtool
RUN pip install -r requirements.txt
EXPOSE 5000
#COPY . .
COPY app/* .
COPY README.md .
CMD ["python", "-u", "app.py"]
