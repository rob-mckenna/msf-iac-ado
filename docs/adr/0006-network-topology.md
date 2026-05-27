# ADR 0006: Network Topology

## Status
Accepted

## Date
2026-05-27

## Context
Enterprise AI workloads require strong network isolation, centralized inspection, and private connectivity to platform services. The network model must support multiple workload types without exposing AI services to public inbound traffic.

## Decision
Use a hub-spoke topology. The hub virtual network contains Azure Firewall, DNS Private Resolver, the VPN or ExpressRoute gateway subnet, and a shared services subnet. Each workload type gets its own spoke virtual network peered to the hub, including an AI Foundry spoke, Fabric spoke, and APIM spoke. All PaaS services use private endpoints in their respective spokes. DNS resolution uses Azure Private DNS zones linked to the hub. No public inbound access is allowed to AI services.

## Consequences
The platform achieves full network isolation and centralized control for enterprise security requirements. The model increases DNS and connectivity complexity, especially for private endpoint resolution and cross-spoke service access. Teams must account for hub dependencies when onboarding new workloads or regional footprints.
