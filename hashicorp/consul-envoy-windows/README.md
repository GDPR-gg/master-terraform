# Consul Service Connect with Windows applciations 

# Getting the Envoy for Windows Alpha binary
In order to get the envoy.exe, we will need to extract it from the Envoy Windows container.
We have created a simple powershell script to do this.

In order to be able to execute a powershell script, you will need to have set the execution policy to "RemoteSigned".
To do this, in an Administrator Powershell shell, execute:

```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```

You will then be able to run get-envoy.ps1.

```
./get-envoy.ps1
```