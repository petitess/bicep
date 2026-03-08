import json

import azure.functions as func
import logging
import os
import datetime
import requests
from azure.identity import DefaultAzureCredential
from azure.monitor.opentelemetry import configure_azure_monitor
from opentelemetry import trace
from opentelemetry.metrics import get_meter

tracer = trace.get_tracer(__name__)
meter = get_meter(__name__)

processed_counter = meter.create_counter(
    "messages_processed",
    unit="1",
    description="Number of Service Bus messages processed",
)

configure_azure_monitor(
    connection_string=os.environ.get("APPLICATIONINSIGHTS_CONNECTION_STRING", "")
)

app = func.FunctionApp()


@app.function_name(name="servicebus_topic_trigger_to_blob")
@app.service_bus_topic_trigger(
    arg_name="msg",
    topic_name=os.environ.get("TOPIC_NAME", "sbt-logic"),
    subscription_name=os.environ.get("SUBSCRIPTION_NAME", "logic-to-sink-sub"),
    connection="SERVICEBUS_CONNECTION",
)
def servicebus_topic_trigger(msg: func.ServiceBusMessage):
    st_name = os.environ.get("ST_NAME", "stfuncsbtopicdev01")
    st_container_name = os.environ.get("ST_CONTAINER_NAME", "container01")
    now = datetime.datetime.now().strftime("%a, %d %b %Y %H:%M:%S GMT")
    now_formated = datetime.datetime.now().strftime("%d_%m_%Y_%H:%M:%S:%f")
    body_str = msg.get_body().decode("utf-8")
    body_json = json.loads(body_str)
    id = body_json.get("id", "no-id")

    processed_counter.add(
        1,
        {
            "topic": os.environ.get("TOPIC_NAME", ""),
            "subscription": os.environ.get("SUBSCRIPTION_NAME", ""),
        },
    )
    logging.warning(
        f"Service Bus message received",
        extra={
            "topic_name": os.environ.get("TOPIC_NAME", ""),
            "subscription_name": os.environ.get("SUBSCRIPTION_NAME", ""),
            "message_id": id,
        },
    )
    logging.warning(f"subscription_name: {os.environ.get('SUBSCRIPTION_NAME', '')}")
    logging.warning("Python Service Bus topic trigger processed a message")
    logging.warning("Message body: %s", msg.get_body().decode("utf-8"))
    credential = DefaultAzureCredential()
    token = credential.get_token("https://storage.azure.com/.default")
    headers = {
        "Authorization": f"Bearer {token.token}",
        "Content-type": "application/octet-stream",
        "x-ms-date": f"{now}",
        "x-ms-version": "2020-04-08",
        "Accept": "application/octet-stream;odata=fullmetadata",
        "x-ms-blob-content-disposition": "attachment",
        "x-ms-blob-type": "BlockBlob",
    }
    url = f"https://{st_name}.blob.core.windows.net/{st_container_name}/recieved_{now_formated}_{id}.json"
    file_content = f"""
    {msg.get_body().decode("utf-8")}
    """

    with tracer.start_as_current_span("blob_upload") as span:
        span.set_attribute("blob.container", st_container_name)
        span.set_attribute("blob.name", f"recieved_{now_formated}_{id}.json")
        span.set_attribute("http.method", "PUT")
        span.set_attribute("http.url", url)

        response = requests.put(url, headers=headers, data=file_content.encode("utf-8"))

        span.set_attribute("http.status_code", response.status_code)
        span.set_attribute("blob.success", response.ok)
        logging.info(f"BLOB CREATED: {response.ok}")


@app.function_name(name="trigger-http-jitbit-01")
@app.route(route="trigger-http-jitbit-01", auth_level=func.AuthLevel.ANONYMOUS)
def http_trigger(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Python HTTP trigger function processed a request.")
    name = req.params.get("name")
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get("name")

    if name:
        return func.HttpResponse(
            f"Hello, {name}. This HTTP triggered function executed successfully."
        )
    else:
        return func.HttpResponse(
            "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.",
            status_code=200,
        )
