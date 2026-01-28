FROM public.ecr.aws/lambda/python:3.11
ENV PYTHONUNBUFFERED=1

COPY requirements.txt ./
RUN pip3 install -r requirements.txt

# Copy the full app so local packages (e.g. middlewares) are included
COPY . ./
CMD [ "main.handler" ]
