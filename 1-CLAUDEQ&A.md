Additional context

QUUESTIONS ASKED BY LAUDE AND MY ANSWERS


  1. Where do you want to run the Ansible automation?
    - On the Proxmox host (bare metal)

I was thinking from my macbook air - is that what you mean? 

    - Inside the LXC container (where Ollama is)

I want this for sure

    - Both?

Definitely both. HOWEVER - I don't want this to be combined. I don't want, for example, an integrated set of playbooks that take you from baremetal proxmox server to LXC with ollama and openwebui. 

Instead, I want a set of playboooks / roles / whateve that manages server hosts. That would be spinning up and configuring NAS and virtualization systems like proxmox (I'll have 5+ proxmox nodes), TrueNas, UnRaid, and UGreen Nas UGOS.

Then I want a separate set of playbooks that plays performative chef with all the VM and Container toys you can think of like LXCs, Docker, Podman, Jellyfin and the ARR stack, bitcoin node - whatever.

So I want both, but if there's a break or a dividing line, I want it between host OSs (Nas and virtulization), and all the virtual goodies (VMs, containers, etc.)

  2. What's your goal?
    - Manage the existing LXC container

Take my disjointed duct tape and shoestring homelab as it stands today, and create a robust and comprehensive set of ansible playbooks, terraform templates, docker compose files, kubernetes helm charts that come together to form a robust infrastructure as code apparatus. I want it to live in a self-hosted gitlab, with CI/CD pipelines, and dev/staging/prod branches. Eventualy, I want to get to a point where I have 2-3 storage nodes that service the 10+ other hardware nodes (ranging from the AI machine we're working on now, to a raspberry pi, to a mac laptop from 2008). The north star is getting to a level of sophistication where I basically wake on lan any piece of hardware I want, it netboots based on a version controlled config file in a tftp server attaching iscsi drives, it operates, until i spin it back down.

All of that is "eventually" and "wouldnt that be cool" - but it gives insight into what mode I'm in and what my goals are.

    - Create new containers/VMs for different AI workloads

Yes. Right now, I have one big honking sledgehammer of an LXC. Why? because at the moment, it WORKS. It's on ollama and through openwebui. It works, I've got it backed up, and I have snapshots so when I break it, I can roll back.

Am I open to having smaller, more focused AI stuff to play around with? Absolutely. I just don't have the confidence or the know-how, so I've stopped at "I've successfully allocated 2 gpus to a container that is a private AI - isn't that fucking cool?"

    - Manage the Proxmox host itself

YES. If I had to choose between using ansible to help me configure Host OSs vs VMs and CTs, it would definitely be Host OSs (though I do want both if possible!). I have spent months screwing something up, not knowing what I did wrong, executing a complicated script in the totally wrong server or part of the filesystem causing damage i don't understand. So i have spent SO much time reinstalling proxmox, reconfiguring the network, etc. 

So if ansible,terraform, and cloud-init can help me get to "wipe server, run commands, have fresh baremetal again", rather than "spend an entire weekend reinstalling proxmox on 5 servers just to get a good starting point, only to be sad I didn't accomplish much on Sunday" - that is already a mega giga win. (also tailscale, xpipe.io, and netbootxyz could also play a serious role here too)

    - All of the above?

Yes - with priority on Host OS standardization and automation.

  3. Current setup details:
    - Is the LXC privileged (can access GPUs)?

It is not privileged, but I have successfully passed through both GPUs. I have been follwing this guide (https://digitalspaceport.com/how-to-setup-an-ai-server-homelab-beginners-guides-ollama-and-openwebui-on-proxmox-lxc/) as close as I can (and just finished this - step 1; plan was to move to step 2 but VERY open to any cool ideas you have).

    - Are the Tesla P40s passed through to the LXC?

Yes - NVTOP in the lxc interface pulls up both GPUs. I don't know how truly "connected they are though"

    - What's the LXC's IP address?

10.203.3.29 (open webui is on port 8080)

----

