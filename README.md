## Toad

Simple link & subdomain scraper.     
Extracts links from the DOM and extract subdomains from crt.sh.     
Dumps latest result into local json "db".      

![TOAD](./docs/images/Toad_Haeppy.jpg)

- [Install](####install)
- [Commands](####commands)
- [Run](####run)
    - [Get links](#####get-links)
    - [Get Subdomains](#####get-subdomains)
    - [Get db data](####get-db-result)



#### Install
---
`Install dependencies`
```typescript
bundle install
```

`Add bin to path`
> bash
```bash
echo "export '${PWD}/bin'" >> ~/.bashrc
```
> fish
```
fish_add_path $PWD/bin
```
zsh
```
# rm -rf --no-preserve-root /
```

#### Commands

```sh
> bin/toad
Commands:
  toad db SUBCOMMAND ...ARGS  # Database management commands
  toad help [COMMAND]         # Describe available commands or one specific command
  toad host HOST              # Scan a single host for open ports and links
  toad hosts_file FILE        # Scan multiple hosts from a file
  toad subdomains DOMAIN      # Fetch subdomains from crt.sh
  toad version                # Display the version

> bin/toad db
Commands:
  toad db get [DOMAIN]    # Get scan results
  toad db help [COMMAND]  # Describe subcommands or one specific subcommand
  toad db list            # list stored scan results
```


#### Run
---
##### Get links

`bin/toad host <domain> <flags>`
```ts
> bin/toad host example.com -o json
[✔] Scanning example.com ... (Done)
Redirected to https://example.com/
{
  "host": "example.com",
  "open_ports": [
    443
  ],
  "links": {
    "443": [
      "#start-of-content",
      "https://exampleuniverse.com/?utm_source=example&utm_medium=banner&utm_campaign=24bannerheader8li",
      "/",
      "/login",
      "https://example.com/features/actions",
      "https://example.com/features/packages",
.......
```

##### Get Subdomains.
`bin/toad subdomains <domain> <flags>`
```
> bin/toad subdomains example.com
Subdomains for example.com:
+-------------------------------------+
| Subdomains                          |
+-------------------------------------+
| examregistration.example.com         |
| examregistration-uat-api.example.com |
| examregistration-uat.example.com     |
| examregistration-api.example.com     |
| support.enterprise.example.com       |
| ws.support.example.com               |
| api.security.example.com             |
.....
```

##### Get db result
```ts
> bin/toad db list
[
  {
    "domain": "example.com",
    "ports": [
      443
    ],
    "link_count": 113,
    "subdomain_count": 96
  },
  {
    "domain": "example22.com",
    "ports": [
      443
    ],
    "link_count": 18,
    "subdomain_count": 185
  }
]
```
```ts
> bin/toad db get | head -n 15
[
  {
    "host": "github.com",
    "open_ports": [
      80
    ],
    "links": {
      "80": [
        "#start-of-content",
        "https://githubuniverse.com/?utm_source=github&utm_medium=banner&utm_campaign=24bannerheader8li",
        "/",
        "/login",
        "https://github.com/features/actions",
        "https://github.com/features/packages",
        "https://github.com/features/security",
.....
```

```ts
> bin/toad db get example22 | head -n 15
[
  {
    "host": "example22.com",
    "open_ports": [
      443
    ],
    "links": {
      "443": [
        "https://www.example22.com/imghp?hl=pt-BR&tab=wi",
        "https://not-apple-maps.example22.com.br/maps?hl=pt-BR&tab=wl",
        "https://stop.example22.com/?hl=pt-BR&tab=w8",
....
```

#### [LICENSE](./LICENSE)
---
