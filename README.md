# DigiVol   [![Build Status](https://travis-ci.org/AtlasOfLivingAustralia/volunteer-portal.svg?branch=develop)](https://travis-ci.org/AtlasOfLivingAustralia/volunteer-portal)

The [Atlas of Living Australia], in collaboration with the [Australian Museum], developed [DigiVol]
to harness the power of online volunteers (also known as crowdsourcing) to digitise biodiversity data that is locked 
up in biodiversity collections, field notebooks and survey sheets.

## Running

The ansible inventories are currently out of date.  You can run DigiVol manually by using gradle to build:

```bash
./gradlew assemble
java -jar build/libs/volunteer-portal-*.war
open http://devt.ala.org.au:8080/
```

~~To run up a vagrant instance of DigiVol you can use the volunteer_portal_instance ansible playbook from the
[AtlasOfLivingAustralia/ala-install] repository.  This will deploy a pre-compiled version from the ALA Maven repository.~~

~~*NOTE: Both [vagrant] and [ansible] must be installed first.*~~

~~Then setup the VM and run the playbook:~~

```bash
git clone https://github.com/AtlasOfLivingAustralia/ala-install.git
cd ala-install/vagrant/ubuntu-trusty
vagrant up
cd ../../ansible
ansible-playbook -i inventories/vagrant --user vagrant --private-key ~/.vagrant.d/insecure_private_key --sudo volunteer-portal.yml
```

~~Deploying to a server can be done similarly, though you will need to define an ansible inventory first.~~

## Contributing

DigiVol is a [Grails] v5.3 based web application.  It requires [PostgreSQL] v15 for data storage.  Development follows the 
[git flow] workflow.

For git flow operations you may like to use the `git-flow` command line tools.  Either install [Atlassian SourceTree]
which bundles its own version or install them via:

```bash
# OS X
brew install git-flow
# Ubuntu
apt-get install git-flow
```

[Atlas of Living Australia]: http://www.ala.org.au/
[Australian Museum]: http://australianmuseum.net.au/
[PostgreSQL]: http://postgres.org/
[DigiVol]: http://volunteer.ala.org.au/
[Grails]: http://www.grails.org/
[git flow]: https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow "Gitflow Workflow"
[Atlassian SourceTree]: http://www.sourcetreeapp.com/
[AtlasOfLivingAustralia/ala-install]: https://github.com/AtlasOfLivingAustralia/ala-install
[vagrant]: https://www.vagrantup.com/
[ansible]: http://www.ansible.com/home
