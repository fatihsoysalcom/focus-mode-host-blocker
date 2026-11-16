# Focus Mode Host Blocker

This example demonstrates a basic "focus mode" by blocking access to distracting websites. It modifies the `/etc/hosts` file to redirect specified domains to localhost, simulating the core concept of the ZgubaČasa Canary tool for digital distraction management on Linux. This allows users to temporarily prevent access to common time-wasting sites.

## Language

`bash`

## How to Run

Save the script as `zgubacasa.sh`. Make it executable: `chmod +x zgubacasa.sh`. To activate focus mode: `sudo ./zgubacasa.sh start`. To deactivate focus mode: `sudo ./zgubacasa.sh stop`.

## Original Article

This example accompanies the Turkish article: [ZgubaČasa Canary Linux: Zaman Yönetiminde Devrimsel Bir Yaklaşım](https://fatihsoysal.com/blog/zgubacasa-canary-linux-zaman-yonetiminde-devrimsel-bir-yaklasim/).

## License

MIT — see [LICENSE](LICENSE).
