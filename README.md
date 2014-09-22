# Bootstraping using `knife solo`

## Prerequisites

* A root access to a fresh Ubuntu 14.04 server (tested on a fresh Digital Ocean Ubuntu 14.04 x64 droplet) with a configured fully qualified domain name (`hostname --fqdn` must return the right fully qualified domain name for your server)
* A wildcard DNS record for your server
* A recent version of ruby to install and use `knife-solo`

## Install knife solo

`gem install knife-solo`

## Generate a new chef repo

```
knife solo init staticd-solo
cd staticd-solo
```

## Add the 'staticd' cookbook to your Berksfile

First thing to do is adding an API source to your Berksfile (even if not used by your berkshelf config):
`echo "source 'https://supermarket.getchef.com'" > Berksfile`

You can now add the staticd cookbook to your Berksfile:
`echo "cookbook 'staticd', git: 'https://github.com/garnieretienne/staticd-cookbook.git'" >> Berksfile`

## Adding the `staticd::default` recipe to the run list for you server

Create the `nodes/servername.domain.tld.json` (replace with your fully qualified domain name)
```
{
  "run_list": [
    "staticd"
  ]
}
```

## Bootstrap your configuration using the `chef solo` command

`knife solo bootstrap root@servername.domain.tld`

## Add a ssh key to allow an user to push to the git repo

`scp ~/.ssh/id_rsa.pub root@servername.domain.tld:/etc/staticd/allowed_keys.d/$USER.pub`

## Add the GIT remote to a git repo

`git remote add servername.domain.tld ssh://$USER@servername.domain.tld:2288/subdomain`

Note: port 2288 is the default port for GIT in staticd.

## Deploy your static website using GIT push

```
$> git push servername.domain.tld master
Counting objects: 6, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (6/6), 491 bytes, done.
Total 6 (delta 0), reused 0 (delta 0)

>> Receiving 'subdomain' vd8bc945d4e949df00dbade1ff9702b15e2037925...
>> Deploying to 'subdomain.servername.domain.tld'
>> Done.
   http://subdomain.servername.domain.tld:8080

To ssh://user@servername.domain.tld:2288/subdomain
 * [new branch]      master -> master
```

Note: port 8080 is the default port for WWW in staticd.

# staticd-cookbook

TODO: Enter the cookbook description here.

## Supported Platforms

TODO: List your supported platforms.

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['staticd']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### staticd::default

Include `staticd` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[staticd::default]"
  ]
}
```

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (i.e. `add-new-recipe`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request

## License and Authors

Author:: YOUR_NAME (<YOUR_EMAIL>)
