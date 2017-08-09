# Powershell-Minecraft-Server

This set of scripts will install a Minecraft Server based on a given configuration, like if to use Vanilla or Forge Minecraft and what version shall be used.

Any configuration given in `default.properties` can be overridden in a custom properties file.

## Usage

1. Create a properties file like `example.properties` which overrides/specifies properties for your desired server.
2. Call `Install-MinecraftServer example.properties` to install/update the server. It will typically be installed to a subfolder beneath the install script.
3. Inside the server folder a file named `Start-Minecraft.ps1` will be created. It is meant to be used to start your Minecraft Server according to your configuration.

## Planned Features

* Support for Modpacks
* More Server Types

## Troubleshooting

### I cannot reach my server from the Internet.

Perhaps you need to enable port forwarding in your router.

### I cannot execute the Powershell Scripts.

You might need to adjust the security policy:

```
Set-ExecutionPolicy RemoteSigned
```

## See Also

* [itzg/minecraft-server - Docker Hub](https://hub.docker.com/r/itzg/minecraft-server/)
