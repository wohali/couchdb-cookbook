# Cookbook Testing Documentation

This cookbook includes support for running tests via Test Kitchen.

## Testing Prerequisites

* A working ChefDK installation set as your system's default ruby. ChefDK can be downloaded at <https://downloads.chef.io/chef-dk/>

* Hashicorp's [Vagrant](https://www.vagrantup.com/downloads.html) and Oracle's [Virtualbox](https://www.virtualbox.org/wiki/Downloads) for integration testing.

**Note**: VBox 5.0/5.1 and Vagrant and 1.9.5 are known working versions.

## Installing dependencies

Cookbooks may require additional testing dependencies that do not ship with ChefDK directly. These can be installed into the ChefDK ruby environment with the following commands

Install dependencies:

```shell
chef exec bundle install
```

Update any installed dependencies to the latest versions:

```shell
chef exec bundle update
```

## Linting

Cookstyle (<https://github.com/chef/cookstyle>) offers a tailored RuboCop configuration enabling / disabling rules to better meet the needs of cookbook authors. Cookstyle ensures that projects with multiple authors have consistent code styling.

```shell
chef exec cookstyle
```

## Foodcritic

Foodcritic (<http://www.foodcritic.io/>) provides chef cookbook specific linting and syntax checks. Foodcritic tests for over 60 different cookbook conditions and helps authors avoid bad patterns in their cookbooks.

```shell
chef exec foodcritic .
```

## Integration Testing

Integration testing is performed by Test Kitchen. After a successful converge, tests are uploaded and ran out of band of Chef. Tests should be designed to ensure that a recipe has accomplished its goal.

## Integration Testing using Vagrant

Integration tests can be performed on a local workstation using either VirtualBox or VMWare as the virtualization hypervisor. To run tests against all available instances run:

```shell
chef exec kitchen test
`
```

To see a list of available test instances run:

```shell
chef exec kitchen list
```

To test specific instance run:

```shell
chef exec kitchen test INSTANCE_NAME
```

To test all instances run:

```shell
chef exec kitchen test all
```
