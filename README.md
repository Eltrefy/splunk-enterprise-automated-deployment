# splunk-enterprise-automated-deployment-for-linux-servers
Splunk Enterprise Automated Deployment &amp; System Tuning Scripts
# Executive Summary

This documentation outlines the operational procedures for deploying, hardening, and verifying Splunk Enterprise using automated Bash scripts. The suite enforces Splunk best practices, including kernel-level optimizations (THP disabling), SELinux transition management, dedicated service accounts, systemd resource limits (ulimit overrides), and network boundary rules (firewalld).

# Core Infrastructure Ports (Configured by Installation Script)

Port 8000 (TCP) — Web Browsers to Search Heads / All-in-One

Why it is needed: Splunk Web User Interface. Provides graphical web access for users and administrators to perform searches, view dashboards, and manage the environment.

Port 8089 (TCP) — Admin Workstations / Deployment Server / Peers to Splunk Nodes

Why it is needed: Splunk Management & REST API. Core control-plane port used for CLI management, REST API requests, Deployment Server bundle pushes, and inter-node orchestration.

Port 9997 (TCP) — Universal Forwarders / Heavy Forwarders to Indexers

Why it is needed: Splunk-to-Splunk (S2S) Ingestion. Standard data receiver port used by forwarders to stream encrypted or unencrypted log events directly into indexers.

# Enterprise Cluster Ports (Role-Specific Architecture Expansion)
# u can expand them at our script

Port 9887 (TCP) — Peer Indexer to Peer Indexer (Applies to: Peer Indexers)

Why it is needed: Indexer Replication. High-speed peer-to-peer raw data replication stream used to maintain search and replication factors across an Indexer Cluster.

Port 8191 (TCP) — SHC Member to SHC Member (Applies to: Search Head Cluster Members)

Why it is needed: KV Store Replication. Internal MongoDB protocol used to replicate KV Store collections, app states, and lookup table state across Search Head Cluster members.

Port 8089 (TCP) — Cluster Manager / Deployer to Cluster Peers / SHC Members (Applies to: All Cluster Roles)

Why it is needed: Cluster Management & Sync. Used by the Cluster Manager to monitor peer health and by the Deployer to push configuration bundles to Search Head Cluster members.

 # How to Set Up the Scripts
 # user owner must has Sudo privileges
 
 Place all files inside your home directory (for example, /home/user).

 /home/user/
├── install_splunk.sh         # Main setup & tuning script
├── verification_splunk.sh    # Post-install check script
└── splunk-<version>.tgz      # Splunk installation file

# Steps to modify permissions
chmod +x install_splunk.sh verification_splunk.sh

# Customizing Script Parameters

Before running the installation, update any variables inside install_splunk.sh if needed.

# Updating Target Splunk Version

If you are using a different Splunk .tgz installer, update line 23 in install_splunk.sh:

# --- Modify package name according to your target version ---
SPLUNK_TGZ="splunk-10.4.1-5a009d941268-linux-amd64.tgz"

# --- also, u can automate addition of rule-based ports

# Execution Workflow

Run the two scripts sequentially using sudo privileges.

# Phase 1: Installation & System Tuning

Execute the main installation script:

sudo ./install_splunk.sh

Prompts during execution:

Linux splunk User Password: Sets system credentials for the OS-level splunk account.

Splunk Web admin Password: Seeds /opt/splunk/etc/system/local/user-seed.conf for first-boot UI/CLI logins.

Skip Extraction Option: Enter n (default) for a fresh install; select y if re-running tuning against an existing /opt/splunk path.

Firewall Setup: Enter y (default) to open core ports (8000, 8089, 9997) via firewalld.

# Phase 2: Post-Deployment Audit
Validate system configuration state post-installation:


sudo ./verification_splunk.sh

 # Verification Checklist
The audit script checks the four core production prerequisites:


====================================================
          AUTOMATED POST-INSTALL VERIFICATION       
====================================================

[1/4] Verifying THP (Transparent Huge Pages) Settings:
   -> THP Enabled State: always madvise [never]
   -> THP Defrag State:  always defer madvise [never]

[2/4] Verifying Splunkd Service Status:
   -> Splunkd Service: ACTIVE (Running)

[3/4] Verifying Applied Resource Limits (override.conf):
   -> LimitNOFILE=102400
   -> LimitNPROC=65536
   -> LimitDATA=infinity
   -> LimitCORE=infinity
   -> LimitMEMLOCK=infinity

[4/4] Verifying Active Firewall Open Ports:
   -> Open Ports: 8000/tcp 8089/tcp 9997/tcp
====================================================
SELinux Status: Run getenforce to confirm it reports Permissive (or Disabled).

THP Status: Both enabled and defrag must indicate [never] enclosed in brackets.

Service Status: Must display ACTIVE (Running).

Resource Limits: LimitNOFILE must show 102400 and LimitNPROC must show 65536.


