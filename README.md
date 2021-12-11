# My Octopus hackathon entry

# Motivation
Some background story, before we start to dig into the components of my Octopus hackathon entry:

I saw this tweet from the great `Sarah Lean`

%[https://twitter.com/TechieLass/status/1468868185738944515?s=20]

And found following conditions, in the fine print:

> Octopus Deploy is part of this year’s Festive Tech Calendar, running a hackathon competition.

>The aim of the hackathon is to deploy an Azure Web App using Octopus Deploy.

![image.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1639259966385/FBDkkvDAQ.png)

That sounds very interesting for me, It's really a long time, since I used the Azure App Service and on top I did absolutely nothing with Octopus Deploy. Ever!

Time to start:

![image.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1639260160913/ltMmeHgGA.png)

# The Web App
So let me see, what I should do for the web app! I quickly draw the idea, that I wanted to create a golang webservice, which just delivers a Lofi gif. Quick and cool!

![lofi.gif](https://cdn.hashnode.com/res/hashnode/image/upload/v1639257073921/pFyEqPD_o.gif)

In particular this gif. I don't know, but I am really fascinated from the type of 8-bit pixel art.

So in the `https://github.com/dirien/octopus-deploy-hackathon/tree/main/app` folder, you will find the mini go app and the Dockerfile to build the container.

Because now comes one downside: App Service has first-class support for ASP.NET, ASP.NET Core, Java, Ruby, Node.js, PHP, or Python.  And no golang support! Now I remember, why I never worked further with Azure App Service, welp! But I can dockerize my app. And that's what I am going to do!

# Infrastructure as Code

Terraform is first class citizen in Octopus Deploy:

![image.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1639257571999/tQU-yj82bV.png)

So I am going to use Terraform this time, for all my deployments in Azure. Octopus Deploy offers many more dedicated, so called `steps` and the corresponding `step templates`. But since Jenkins, I don't feel it anymore to split my deployments into different providers (Plugins etc.). I want everything in one place.

So in the under `https://github.com/dirien/octopus-deploy-hackathon` will you find a very simple terraform deployment.

### Terraform Cloud
As backend, I use `Terraform Cloud`. I really love it, that it takes care of my state file, and I don't need to look out for them.

![image.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1639257801345/KZ23oQieB.png)

There are much more stuff, Terraform Cloud offers. But I think this is material for another blog entry.

There are some variables I want to handle in `Octopus Deploy`. `Octopus Deploy` will replace variables in all *.tf, *.tfvars, *.tf.json and *.tfvars.json files using the #{Variable} substitution syntax. That's great!

So my main.tf looks like this:

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.46.0"
    }
  }
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "dirien"
    token        = "#{TOKEN}"
    workspaces {
      name = "octopus-hackathon"
    }
  }
}



provider "azurerm" {
  subscription_id = "#{Azure.SubscriptionNumber}"
  client_id       = "#{Azure.Client}"
  client_secret   = "#{Azure.Password}"
  tenant_id       = "#{Azure.TenantId}"
  features {}
}
```
As you see, the token for the TF Cloud and the credentials for the `service principal` of Azure are all variables, which gets substituted from `Octopus Deploy`.

The rest of the deployment, is really default.  Then only additional value, I hold in `Octopus Deploy` is the version of the app via ` linux_fx_version = "DOCKER|dirien/lofi-go:#{APP_VERSION}"` in the `azure.tf` file.

Before committing the code, I always run `tfsec`! Please do this too! I love how `tfsec` is giving me instant feedback about my terraform script.


![image.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1639260626642/8hqt9DX9Z.png)

Here a little extract:
```bash
  Result 3

  [azure-appservice-require-client-cert][LOW] Resource 'azurerm_app_service.octopus-deploy-as' has attribute client_cert_enabled that is false
  /Users/dirien/Tools/repos/octopus-deploy-hackathon/azure.tf:60


      57 |     dotnet_framework_version = "v4.0"
      58 |     http2_enabled            = true
      59 |   }
      60 |   client_cert_enabled     = false    bool: false
      61 |   logs {
      62 |     detailed_error_messages_enabled = true
      63 |     failed_request_tracing_enabled = true

  Impact:     Mutual TLS is not being used
  Resolution: Enable incoming certificates for clients

  More Info:
  - https://aquasecurity.github.io/tfsec/latest/checks/azure/appservice/require-client-cert 
  - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service#client_cert_enabled 
````
# Octopus Deploy

Now comes the last part, putting everything together in `Octopus Deploy`.

You can sign up for an [Octopus Cloud free trial](https://octopus.com/start/cloud) and can play easily for 30d around. That's very nice from the people of  `Octopus Deploy`.

So I created a Cloud Instance for me:

![image.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1639258581146/Zyzj_i-_I.png)

And with the url `https://dirien.octopus.app` I can access my instance.

I added under `Infrastructure -> Accounts` my personal Azure subscription via a `service principal` and I am good to go, to create project.

![image.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1639258697223/Wpi6Nbxaf.png)

Under `Project`, I created my two `Octopus Deploy` projects

![image.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1639258820754/pSehvVmVV.png)

One is to create the infrastructure (including the app deployment) and the other one is to destroy the whole infrastructure. The rest, is all handled in my terraform via PR through a GitOps way of working. State changes, drifts etc. will be all handled by Terraform and Terraform Cloud.

Not surprisingly, my process is straight forward und very simple. Terraform plan, ask for a manual improvement and then Terraform plan. That's it.

![image.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1639259098900/n6mQH8pJi.png)

The whole logging and auditing, is really nice done in `Octopus Deploy`. And I am sure, in a more real life scenario I got spend much more time to create an even more sophisticated deployment process. Really nice!

![image.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1639259141243/8IEQVU0b9.png)

# Azure

When everything went through you will see in the Azure portal your infrastructure:

![image.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1639259303191/i-mSx_lq3.png)

Same goes for Terraform Cloud.

![image.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1639259345735/EFXLnBACY.png)

And with `https://octopus-deploy-as.azurewebsites.net/` I can finally call my Web App.

![image.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1639259628364/WUJRYMRBSp.png)

# That's it!

![image.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1639260454546/uPFsZJdaS.png)

## Resources

- https://octopus.com/blog/festive-tech-calendar-hackathon
- https://docs.microsoft.com/en-us/azure/app-service/
- https://www.terraform.io/cloud
- https://octopus.com/start
- https://github.com/aquasecurity/tfsec