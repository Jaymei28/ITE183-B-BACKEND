FROM python:3.11-slim

WORKDIR /usr/src/django_bnb_backend

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1


RUN apt-get update && apt-get install -y netcat-openbsd


RUN pip install --upgrade pip
COPY ./djangobnb_backend/requirements.txt .
RUN pip install -r requirements.txt


COPY ./entrypoint.sh .
RUN sed -i 's/\r$//g' /usr/src/django_bnb_backend/entrypoint.sh
RUN chmod +x /usr/src/django_bnb_backend/entrypoint.sh


COPY . .

ENTRYPOINT [ "/usr/src/django_bnb_backend/entrypoint.sh" ]