## Redoc-cli Docker Wrapper
A Docker wrapper for redoc-cli to generate HTML documentation from OpenAPI
specifications.

### Build
`$ docker build -t redoc-do .`

### Run
`$ docker run --rm -v /path/to/:/path/to/ redoc-do -i /path/to/openapi.yml -o /path/to/index.html`