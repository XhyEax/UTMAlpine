# UTMAlpine
## UTM Alpine-virt arm64 image
User: root

Password: password

PortFoward: 22->8022, 8000->8000

installed packages: git nodejs npm

autorun script: sac.sh

# How to start JIT
## [Recommend]start JIT by Local PC
iOS < 17：AltServer

iOS 17+: [JitStreamer](https://github.com/jawshoeadan/JitStreamer)


## JITStreamer self connection by UTM SE (slow to start)

PortFoward: 8080->8080

installed packages: python3 gcc make TailScale usbmuxd JitStreamer (and many compile dependences, like libimobiledevice-glue)

1. start tailscale and JitStreamer in UTM SE
   
2. post lockdownd {udid}.plst to UTM
   
get udid by PC:
```
pymobiledevice3 usbmux list
```

get pair record:
```
macOS: ~/Library/Lockdown/
Linux: /var/lib/lockdown/
Windows: C:\ProgramData\Apple\Lockdown\
```

3. test connection get udid list apps
```
curl http://127.0.0.1:8080
curl http://127.0.0.1:8080/{udid}
```

4. start JIT by http request
```
curl http://127.0.0.1:8080/{udid}/UTM
```

## [testing]start JIT by Remote PC with TailScale

1. start TailScale on iOS and PC

[https://tailscale.com/download](https://tailscale.com/download)

2. restart JitStreamer on PC and send pair record
[JitStreamer](https://github.com/jawshoeadan/JitStreamer)

[Shoutcuts](https://www.icloud.com/shortcuts/f34906a2792e4f4b81b639a6853af403)

3. test connection
```
curl http://{pcip}:8080/{udid}
```

4. start JIT by http request
```
curl http://{pcip}:8080/{udid}/UTM
```
