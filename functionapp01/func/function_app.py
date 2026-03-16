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
from azure.ai.ml import MLClient
from openai import AzureOpenAI

tracer = trace.get_tracer(__name__)
meter = get_meter(__name__)

summaries_counter = meter.create_counter(
    "summaries_processed",
    unit="1",
    description="Number of JSON summaries processed",
)

summary_latency = meter.create_histogram(
    "summary_latency_ms",
    unit="ms",
    description="Time spent summarizing JSON payloads",
)

configure_azure_monitor(
    connection_string=os.environ.get("APPLICATIONINSIGHTS_CONNECTION_STRING")
)

app = func.FunctionApp()


@app.function_name(name="test-ai-foundry")
@app.route(route="test-ai-foundry", auth_level=func.AuthLevel.ANONYMOUS)
def test_ai_foundry(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Testing AI Foundry connection.")
    try:
        credential = DefaultAzureCredential()
        subscription_id = os.environ.get("AZURE_SUBSCRIPTION_ID")
        resource_group = os.environ.get("AZURE_RESOURCE_GROUP")
        workspace_name = os.environ.get("AZURE_ML_WORKSPACE_NAME")

        if not subscription_id or not resource_group or not workspace_name:
            return func.HttpResponse(
                "Missing environment variables: AZURE_SUBSCRIPTION_ID, AZURE_RESOURCE_GROUP, AZURE_ML_WORKSPACE_NAME",
                status_code=400,
            )

        ml_client = MLClient(
            credential=credential,
            subscription_id=subscription_id,
            resource_group_name=resource_group,
            workspace_name=workspace_name,
        )

        return func.HttpResponse(
            f"AI Foundry connection successful. Workspace: {ml_client.workspace_name}",
            status_code=200,
        )
    except Exception as e:
        logging.error(f"AI Foundry connection failed: {str(e)}")
        return func.HttpResponse(
            f"AI Foundry connection failed: {str(e)}", status_code=500
        )


@app.function_name(name="summarize-json")
@app.route(
    route="summarize-json", methods=["POST"], auth_level=func.AuthLevel.ANONYMOUS
)
def summarize_json(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Summarizing JSON payload.")
    start_time = datetime.datetime.now()
    st_name = os.environ.get("ST_NAME")
    now = datetime.datetime.now().strftime("%a, %d %b %Y %H:%M:%S GMT")
    now_formated = datetime.datetime.now().strftime("%d_%m_%Y_%H:%M:%S:%f")

    try:
        req_body = req.get_json()
        if not req_body:
            return func.HttpResponse("No JSON payload provided.", status_code=400)

        title = req_body.get("title", "no_name")
        alert_name = (
            req_body.get("data", {}).get("essentials", {}).get("alertRule", title)
        )
        json_str = json.dumps(req_body, indent=2)

        api_key = os.environ.get("AZURE_OPENAI_API_KEY")
        endpoint = os.environ.get("AZURE_OPENAI_ENDPOINT")
        deployment_name = os.environ.get("AZURE_OPENAI_DEPLOYMENT_NAME")

        if not api_key or not endpoint:
            return func.HttpResponse(
                "Missing environment variables: AZURE_OPENAI_API_KEY, AZURE_OPENAI_ENDPOINT",
                status_code=400,
            )

        client = AzureOpenAI(
            api_key=api_key, azure_endpoint=endpoint, api_version="2023-05-15"
        )

        response = client.chat.completions.create(
            model=deployment_name,
            messages=[
                {
                    "role": "system",
                    "content": (
                        "Return STRICT JSON in this format: "
                        '{ "summary": "...", "category": "..." }'
                        "You are a helpful assistant that summarizes JSON data and gives advice how to solve the problem. "
                        "Categorize the alert using ONE of these categories only: "
                        "backup, cpu, sql, anomalies, virtual-machines, uncategorised, service-error. "
                    ),
                },
                {
                    "role": "user",
                    "content": f"Summarize the following JSON content in a concise paragraph: {json_str}. Give advice for how to solve the problem.",
                },
            ],
        )

        raw_content = (response.choices[0].message.content or "").strip()
        logging.info(f"Model raw response: {raw_content}")
        if raw_content.startswith("```"):
            raw_content = raw_content.strip("`")
        try:
            result = json.loads(raw_content)
        except json.JSONDecodeError:
            result = {"summary": raw_content, "category": "uncategorised"}

        summary = result.get("summary", "")
        raw_category = str(result.get("category", "uncategorised")).lower()

        allowed_categories = {
            "backup",
            "cpu",
            "sql",
            "anomalies",
            "virtual-machines",
            "uncategorised",
            "service-error",
        }

        normalization_map = {
            "vm": "virtual-machines",
            "vms": "virtual-machines",
            "virtual machine": "virtual-machines",
            "virtual machines": "virtual-machines",
            "database": "sql",
            "db": "sql",
            "performance": "cpu",
        }

        category = normalization_map.get(raw_category, raw_category)
        if category not in allowed_categories:
            category = "uncategorised"

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
        url = f"https://{st_name}.blob.core.windows.net/{category}/{alert_name}_{now_formated}.json"
        file_content = f"""{json_str}"""

        with tracer.start_as_current_span("blob_upload") as span:
            span.set_attribute("blob.container", category)
            span.set_attribute("blob.name", f"{alert_name}_{now_formated}.json")
            span.set_attribute("blob.url", f"{url}")
            span.set_attribute("blob.method", "PUT")

            response = requests.put(
                url, headers=headers, data=file_content.encode("utf-8")
            )

            span.set_attribute("blob.reason", f"{response.reason}")
            span.set_attribute("blob.status_code", response.status_code)
            span.set_attribute("blob.success", response.ok)
            logging.info(f"BLOB CREATED: {response.ok}")
            logging.info(f"BLOB REASON: {response.reason}")

            duration_ms = (datetime.datetime.now() - start_time).total_seconds() * 1000

            summaries_counter.add(
                1,
                {
                    "category": category,
                    "route": "summarize-json",
                },
            )

            summary_latency.record(
                duration_ms,
                {
                    "category": category,
                },
            )

            return func.HttpResponse(
                json.dumps({"summary": summary, "category": category}),
                mimetype="application/json",
                status_code=200,
            )
    except Exception as e:
        summaries_counter.add(
            1,
            {
                "category": "failed",
                "route": "summarize-json",
            },
        )
        logging.error(f"Summarization failed: {str(e)}")
        return func.HttpResponse(f"Summarization failed: {str(e)}", status_code=500)
