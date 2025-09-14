FROM --platform=$BUILDPLATFORM python:3.13-slim

EXPOSE 8000

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD python manage.py runserver 0.0.0.0:${PORT:-8000}