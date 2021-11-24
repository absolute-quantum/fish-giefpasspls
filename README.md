``` 


 ██████╗ ██╗███████╗███████╗██████╗  █████╗ ███████╗███████╗██████╗ ██╗     ███████╗
██╔════╝ ██║██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝██╔════╝██╔══██╗██║     ██╔════╝
██║  ███╗██║█████╗  █████╗  ██████╔╝███████║███████╗███████╗██████╔╝██║     ███████╗
██║   ██║██║██╔══╝  ██╔══╝  ██╔═══╝ ██╔══██║╚════██║╚════██║██╔═══╝ ██║     ╚════██║
╚██████╔╝██║███████╗██║     ██║     ██║  ██║███████║███████║██║     ███████╗███████║
 ╚═════╝ ╚═╝╚══════╝╚═╝     ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚══════╝╚══════╝
        
                          Made with ❤️️  for FOSS and privacy


```

# 🐟 GIEFPASSPLS 🐟

Made with ❤️️ for FOSS and privacy


## What is GIEFPASSPLS

A fish shell function

## What does it do?

It checks if your linux entropy RNG is good enough and generates secure and randomized passwords in all kinds of formats for you to use in various checkpoint systems.

## Does it use internet?

No. Unless you don't have the required dependencies

## Why would I use this?

Why not? Generating secure passwords should be ALWAYS done.

## Is it safe?

 - It checks if your entropy is acceptable
 - Ensures passing FIPS 140-2 RNG test (`rngtest`)
 - Ensures passing dieharder RNG test (`dieharder`)
 - Checks entropy bits per byte for acceptable ranges for all generated passwords (`ent`)
 - It does a integrity check on the code before executing (`sha512sum`)
 - It uses standardized programs that have good and long standing reputation

## I don't have fish, can I use this with bash?

No, use fish :3 (`apt install fish && chsh -s /usr/bin/fish && fish`) BOOM, you are in! 

*And: I might create a python script for it because python rulez*

## Alright alright, how do I install this crap?

In one AWESOME one-liner:

`apt install wget -y && wget https://raw.githubusercontent.com/absolute-quantum/fish-giefpasspls/master/giefpass.sh /etc/fish/conf.d/ && exec fish`

## And how should I use it?

With the command `giefpasspls`