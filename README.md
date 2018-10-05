[paypal]: https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=ZRP5WBD8CT8EW

<p align="center">
<a href="https://pi-hole.net"><img src="https://pi-hole.github.io/graphics/Vortex/Vortex_with_text.png" width="150" height="255" alt="Pi-hole"></a><br/>
<b>Tutorial to install a Network-wide ad blocking, DNS- and DHCP server on Raspberry Pi</b><br/>
</p>

___
![paypal](https://img.shields.io/badge/PayPal--ffffff.svg?style=social&logo=data%3Aimage%2Fpng%3Bbase64%2CiVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8%2F9hAAAABHNCSVQICAgIfAhkiAAAAZZJREFUOI3Fkb1PFFEUxX%2F3zcAMswFCw0KQr1BZSKUQYijMFibGkhj9D4zYYAuU0NtZSIiNzRZGamqD%2BhdoJR%2FGhBCTHZ11Pt%2B1GIiEnY0hFNzkFu%2FmnHPPPQ%2Buu%2BTiYGjy0ZPa5N1t0SI5m6mITeP4%2B%2FGP%2Fbccvto8j3cuCsQTSy%2FCzLkdxqkXpoUXJoUXJrkfFTLMwHiDYLrFz897Z3jT6ckdBwsiYDMo0tNOIGuBqS%2Beh7sdAkU2g%2BkBFGkd%2FrtSgD8Z%2BrBxj68MAGG1A9efRhVsXrKMU7Y4cNyGOwtDU28OtrqdUMetldvzFKxCYSHJ4NsJ%2BnRJGexHba7VJ%2FTff4BaQFBjVcbqIEZ1bESYn4PRUcHx2N952awUkOHZedUcWm14%2FtjqjREHawUEsgx6Ajg5%2Bsi7jWqBwA%2BmIrXlo9YHUVTmEP%2F6hOO1Ofiyy3pjo%2BsvBDX%2FZpSakhz4BqvQDvdYvrXQEXZViI5rPpBEOwR2l16vtN7bd9SN3L1WXj%2BjGSnN38rq%2B7VL8xXQOdDF%2F0KvXn8BlbuY%2FvUAHysAAAAASUVORK5CYII%3D)
:beer: **Please support me**: Although all my software is free, it is always appreciated if you can support my efforts on Github with a [contribution via Paypal][paypal] - this allows me to write cool projects like this in my personal time and hopefully help you or your business. 
___

The Pi-hole is a [DNS sinkhole](https://en.wikipedia.org/wiki/DNS_Sinkhole) that protects your devices from unwanted content, without installing any client-side software.

- **Easy-to-install**: our versatile installer walks you through the process, and [takes less than ten minutes](https://www.youtube.com/watch?v=vKWjx1AQYgs)
- **Resolute**: content is blocked in _non-browser locations_, such as ad-laden mobile apps and smart TVs
- **Responsive**: seamlessly speeds up the feel of everyday browsing by caching DNS queries
- **Lightweight**: runs smoothly with [minimal hardware and software requirements](https://discourse.pi-hole.net/t/hardware-software-requirements/273)
- **Robust**: a command line interface that is quality assured for interoperability
- **Insightful**: a beautiful responsive Web Interface dashboard to view and control your Pi-hole
- **Versatile**: can optionally function as a [DHCP server](https://discourse.pi-hole.net/t/how-do-i-use-pi-holes-built-in-dhcp-server-and-why-would-i-want-to/3026), ensuring *all* your devices are protected automatically
- **Scalable**: [capable of handling hundreds of millions of queries](https://pi-hole.net/2017/05/24/how-much-traffic-can-pi-hole-handle/) when installed on server-grade hardware
- **Modern**: blocks ads over both IPv4 and IPv6
- **Free**: open source software which helps ensure _you_ are the sole person in control of your privacy

## Setup the Raspberry Pi
For all my home-network projects I run [Raspbian Debian Stretch Lite](https://www.raspberrypi.org/downloads/raspbian/). The setup is trivial:
- Get yourself a Raspberry Pi and a SD-card
- Use [Etcher](https://etcher.io/) to format and SD-card

### Upgrade packages and distribution
```
sudo apt-get update && sudo apt-get upgrade
sudo apt-get dist-upgrade

```

### Upgrade firmware
```
sudo raspi-config
sudo rpi-update
```

### Install my custom MOTD
This changes the login screen. Just copy it from this repository
```
sudo cp ~/motd.sh /etc/profile.d/motd.sh
sudo chown root:root /etc/profile.d/motd.sh
sudo chmod +x /etc/profile.d/motd.sh
sudo rm /etc/motd
```

Use `sudo nano /etc/ssh/sshd_config` to change to `PrintLastLog no`

### Enable root login
- Set a root password via `sudo passwd root`
- Edit `sudo vi /etc/ssh/sshd_config` and set `PermitRootLogin yes`
- Restart SSHD `/etc/init.d/ssh restart`

### Enable password-less login
- Create the .ssh directory via `install -d -m 700 ~/.ssh`
- Create a SSH key on your PC: `ssh-keygen -t rsa -b 4096 -C "your_email@example.com"`
- Install your public key for user 'pi' `cat ~/.ssh/id_rsa.pub | ssh pi@IPADDRESS 'cat >> .ssh/authorized_keys'`
- Install your public key for user 'root' `cat ~/.ssh/id_rsa.pub | ssh root@IPADDRESS 'cat >> .ssh/authorized_keys'`

### Cleanup & Install extra tools
```
sudo apt-get install -y sysstat vnstat screen
sudo apt-get purge apache2
sudo apt-get autoremove 
```

### Enable NTP time
```
timedatectl set-ntp true 
timedatectl status

# Time will be in GMT/UTC, if you want to adjust, use the following:
echo "Africa/Johannesburg" | sudo tee /etc/timezone
sudo dpkg-reconfigure --frontend noninteractive tzdata
timedatectl set-timezone Africa/Johannesburg
```
Reboot your Pi before continuing the next step. Login as 'root' to complete the next steps.

## Install Cloudflare DNS
We will use Cloudflare via [Argo Tunnel](https://developers.cloudflare.com/argo-tunnel/quickstart/) as our DNS provider 
```
cd ~
wget https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-arm.tgz
mkdir argo-tunnel
tar -xvzf cloudflared-stable-linux-arm.tgz -C ./argo-tunnel
rm cloudflared-stable-linux-arm.tgz
cd argo-tunnel
./cloudflared --version
```

To manually test it, run:
```
sudo ./cloudflared proxy-dns --port 54 --upstream https://1.1.1.1/.well-known/dns-query --upstream https://1.0.0.1/.well-known/dns-query
```

Let's install it as a system service by copying the [service file](https://github.com/magicdude4eva/PiHoleCloudFlareD/blob/master/etc/systemd/system/dnsproxy.service) and then starting it via `sudo systemctl restart dnsproxy.service`

## Install email for notifications
We will use `msmtp` for this and I use my Google Apps account to send out email:
```
apt-get install msmtp ca-certificates mailutils
rm /usr/sbin/sendmail
ln -s /usr/bin/msmtp /usr/sbin/sendmail
```

Adjust [`/etc/msmtprc`](https://github.com/magicdude4eva/PiHoleCloudFlareD/blob/master/etc/msmtprc) and [`/etc/msmtprc.aliases`](https://github.com/magicdude4eva/PiHoleCloudFlareD/blob/master/etc/msmtprc.aliases) accordingly.

## Install PiHole
This is really a one-liner via `curl -sSL https://install.pi-hole.net | bash`

### Adjust PiHole configuration files
1) Adjust [`sudo nano /etc/pihole/setupVars.conf`](https://github.com/magicdude4eva/PiHoleCloudFlareD/blob/master/etc/pihole/setupVars.conf)
- The `IPV4_ADDRESS` to the IP of your Pi
- Comment out `PIHOLE_DNS_1` and `PIHOLE_DNS_2`
- Enable `DHCP_ACTIVE` and DHCP settings
- Adjust the `PIHOLE_DOMAIN`

2) Copy my [whitelist.txt](https://github.com/magicdude4eva/PiHoleCloudFlareD/blob/master/etc/pihole/whitelist.txt)

3) Adjust [`/etc/dnsmasq.d/`](https://github.com/magicdude4eva/PiHoleCloudFlareD/tree/master/etc/dnsmasq.d)
- In [`01-pihole.conf`](https://github.com/magicdude4eva/PiHoleCloudFlareD/blob/master/etc/dnsmasq.d/01-pihole.conf) comment out `server` and adjust `server=127.0.0.1#54` so that it points to the local Cloudflare tunnel
- Adjust [`02-pihole-dhcp.conf`](https://github.com/magicdude4eva/PiHoleCloudFlareD/blob/master/etc/dnsmasq.d/02-pihole-dhcp.conf) to match your IP-range
- Adjust [`04-pihole-static-dhcp.conf`](https://github.com/magicdude4eva/PiHoleCloudFlareD/blob/master/etc/dnsmasq.d/04-pihole-static-dhcp.conf) to setup static IPs

4) Adjust [`/etc/hosts`](https://github.com/magicdude4eva/PiHoleCloudFlareD/blob/master/etc/hosts) to setup other hosts which should be resolved in your network

### Install SSL via Let's Encrypt
I am using DNS-01 authentication via Cloudflare DNS with acme.sh - this allows me to automatically renew SSL certificates without exposing services to the outside. Run the below as 'root'-user:

1) Install acme.sh `curl https://get.acme.sh | sh`
2) Register with Let's Encrypt `acme.sh --upgrade --auto-upgrade --accountemail "youremail"`
3) Export your Cloudflare API-key and email:
```
export CF_Key="YOUR-API-KEY"
export CF_Email="YOUR-CLOUDFLARE-EMAIL"
```

4) Adjust your [`/etc/lighthttpd/external.conf`](https://github.com/magicdude4eva/PiHoleCloudFlareD/blob/master/etc/lighttpd/external.conf) (change `pihole.example.com` to your own domain name)

5) Issue your certificate and adjust the domain `pihole.example.com` according to your own settings
```
acme.sh --force --issue  --dnssleep 30 --dns dns_cf -d pihole.example.com  --reloadcmd "cat /root/.acme.sh/pihole.example.com/pihole.example.com.key /root/.acme.sh/pihole.example.com/pihole.example.com.cer | tee /root/.acme.sh/pihole.example.com/pihole.example.com.combined.pem && systemctl restart lighttpd.service"
```

You are done - just reboot one more time and you should be able to access Pi-Hole via `https://pihole.example.com`


## Post-install: Make your network take advantage of Pi-hole
Once you have completed the above steps, you will need to [configure your router to have **DHCP clients use Pi-hole as their DNS server**](https://discourse.pi-hole.net/t/how-do-i-configure-my-devices-to-use-pi-hole-as-their-dns-server/245) which ensures that all devices connecting to your network will have content blocked without any further intervention.

If your router does not support setting the DNS server, you can [use Pi-hole's built in DHCP server](https://discourse.pi-hole.net/t/how-do-i-use-pi-holes-built-in-dhcp-server-and-why-would-i-want-to/3026); just be sure to disable DHCP on your router first (if it has that feature available).

As a last resort, you can always manually set each device to use Pi-hole as their DNS server.

-----

## Donations are always welcome
If this helped you in any way, you can always leave me a tip at
```
(Ripple) rPz4YgyxPpk7xqQQ9P7CqNFvK17nhBdfoy
(BTC)    1Mhq9SY6DzPhs7PNDx7idXFDWsGtyn7GWM
(ETH)    0xb0f2d091dcdd036cd26017bb0fbd6c1488fc8d04
(LTC)    LTfP7yJSpGFvuPqjSEKaqcjue6KSA9118y
(XVG)    D5nBpFBaD6vmVJ5CBUhkz8E4SNWscf6pMu
(BNB)    0xb0f2d091dcdd036cd26017bb0fbd6c1488fc8d04
```

Sign up to [Cointracking](https://cointracking.info?ref=M263159) which uses APIs to connect to all exchanges and helps you with tax. Use [Binance Exchange](https://www.binance.com/?ref=13896895) to trade #altcoins. Join [TradingView](http://tradingview.go2cloud.org/aff_c?offer_id=2&aff_id=7432) to get trend-reports.

If you are poor, follow me at least on [Twitter](https://twitter.com/gerdnaschenweng)!
