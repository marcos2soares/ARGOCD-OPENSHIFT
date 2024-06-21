FROM registry.redhat.io/ubi8/python-36

ARG COLOR=red

WORKDIR /

COPY . /

RUN pip install  --no-index --find-links=app/flask/ -r requirements.txt

CMD gunicorn -c setup.py run:app

