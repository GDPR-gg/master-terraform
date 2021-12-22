$id = docker create envoyproxy/envoy-windows-dev:latest
docker cp "$(docker create envoyproxy/envoy-windows-dev:latest):C:\Program Files\envoy\envoy.exe" "envoy.exe"
docker rm $id