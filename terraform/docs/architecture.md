# Infrastructure architecture notes

## Request path and control plane

```mermaid
flowchart TB
    user[User or CI]
    igw[Internet Gateway]
    public[Public subnets\n10.0.1.0/24, 10.0.2.0/24]
    nat[NAT Gateway]
    private[Private subnets\n10.0.3.0/24, 10.0.4.0/24]
    eks[EKS dev-eks\ncontrol plane]
    nodes[General node group\nt3.medium, 0-3 nodes]
    addons[Helm add-ons\nMetrics Server, Cluster Autoscaler, Argo CD]
    repo[Git repository\nbackend_v2/overlays/dev]

    user --> igw
    igw --> public
    public --> nodes
    public --> nat
    nat --> private
    private --> eks
    public --> eks
    eks --> nodes
    nodes --> addons
    repo --> addons
```

The EKS API endpoint is public, while the control-plane ENIs are placed in
private subnets. The node group is currently configured with the public subnet
outputs from the VPC module, so the diagram records that behavior rather than
assuming nodes are private.

## Optional AWS edge and observability modules

These modules are present but are not currently reachable from the root module:

```mermaid
flowchart LR
    client[Client] --> waf[WAF\nREGIONAL]
    waf --> cdn[CloudFront]
    cdn --> oac[Origin Access Control\nSigV4]
    oac --> bucket[S3 frontend bucket\npublic access blocked]
    waf --> logs[CloudWatch log group\n14-day retention]
    logs --> policy[CloudWatch log resource policy]
```

The CloudFront module also creates an S3 bucket policy limited to the
CloudFront service principal and the distribution source ARN. The WAF module
redacts the `authorization` header from logs.

## Dependency order

1. VPC creates subnets, route tables, Internet Gateway, EIP, and NAT Gateway.
2. IAM creates EKS and workload roles, users, policies, and attachments.
3. EKS consumes VPC subnet IDs and the Cluster Autoscaler role ARN.
4. Helm and Argo CD providers consume the EKS endpoint, CA data, and auth token.
5. Add-ons and the Argo CD application are installed after the cluster is
   available.

