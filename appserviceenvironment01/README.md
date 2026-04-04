#### start docker

```bash
az acr login --name acrczrdev01 --username acrczrdev01
```
#### push docker image
```bash
cd /func-project
docker build -t acrczrdev01.azurecr.io/functionapi:1.0.1 .
docker push acrczrdev01.azurecr.io/functionapi:1.0.1
```
#### push docker image
```bash
cd /app-project
docker build -t acrczrdev01.azurecr.io/appblazor:1.0.1 .
docker push acrczrdev01.azurecr.io/appblazor:1.0.1
```
```bash
az acr repository list --name acrczrdev01 --output table
```
```mermaid
flowchart LR
    A[".NET(docker)"] --> B["Azure Container REgistry"]
    B["Azure Container Registry"] --> C["Azure Web App\n(container)"]
```