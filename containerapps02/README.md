## Ollama
```
https://ollama.com
https://github.com/open-webui/open-webui
https://hub.docker.com/r/ollama/ollama
https://docs.openwebui.com/getting-started/env-configuration/
```

## Download Models

```pwsh
$URL = "https://ca-api-ollama-01.nicefield-b7f45630.swedencentral.azurecontainerapps.io/api/pull"
$Body = ConvertTo-Json @{
  "model"  =  "llama3.2"
  "insecure" = $false
}
Invoke-RestMethod -Method POST -URI $URL -Body $Body
```