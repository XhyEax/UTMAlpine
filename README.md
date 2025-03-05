# UTMAlpine
## UTM Alpine-virt arm64 image
User: root

Password: password

PortFoward: 22->8022, 8000->8000

installed packages: git nodejs npm

autorun script: sac.sh

## JITStreamer self connection by UTM SE (slow to start)
PortFoward: 8080->8080，49151->49151(not used)

installed packages: python3 gcc make tailscale usbmuxd JitStreamer

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

3. test connection
```
curl 127.0.0.1:8080/{udid}
```

4. start JIT by http request
```
curl 127.0.0.1:8080/{udid}/UTM
```
