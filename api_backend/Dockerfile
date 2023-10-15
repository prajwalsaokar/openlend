FROM python:3.9.0-slim-buster
# set work directory
ADD . /app
WORKDIR /app


# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install dependencies
RUN pip install --upgrade pip
COPY ./requirements.txt .
RUN pip install -r requirements.txt
EXPOSE 8000

# copy project
COPY . .

CMD ["gunicorn", "--bind", ":8000", "--workers", "3", "slap.wsgi:application"]