# Installation Puppet and GitBlit service via Puppet agent
<![puppet](https://github.com/jelastic-jps/puppet-install-gitblit-service/blob/master/images/puppet.png)>
<![gitblit](https://github.com/jelastic-jps/puppet-install-gitblit-service/blob/master/images/gitblit.png)>

This repository provides installation VDS node with puppet agent and preconfigured GitBlit service.
Puppet install all required modules and configure Apache server with GitBlit.
Installation logs are available in /tmp directory.

**Type of nodes this add-on can be applied to:**  
VDS node

## Deployment
In order to get this solution instantly deployed, click the "Get It Hosted Now" button, specify your email address within the widget, choose one of the [Jelastic Public Cloud providers](https://jelastic.cloud) and press Install.

[![Deploy](https://github.com/jelastic-jps/git-push-deploy/raw/master/images/deploy-to-jelastic.png)](https://jelastic.com/install-application/?manifest=https://raw.githubusercontent.com/jelastic-jps/puppet-install-gitblit-service/master/manifest.jps) 

To deploy this package to Jelastic Private Cloud, import [this JPS manifest](../../raw/master/manifest.jps) within your dashboard ([detailed instruction](https://docs.jelastic.com/environment-export-import#import)).

For more information on what Jelastic add-on is and how to apply it, follow the [Jelastic Add-ons](https://github.com/jelastic-jps/jpswiki/wiki/Jelastic-Addons) reference.
