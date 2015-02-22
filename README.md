# opsworks_wordpress

Chef cookbook for deploying WordPress to OpsWorks.

## Supported Platforms

This cookbook is developed and test under Ubuntu 14.04. It should also work on other Linux platform, and please file issues if you get any problems.

## OpsWorks Only?

Though this cookbook is created to be used in AWS OpsWorks, environment setup cookbook (i.e. `opsworks_wordpress::default`) recipe could be used in normal chef environment.

## Recipes

* `opsworks_wordpress::default` - Install HHVM / NGINX, add NGINX shared configs and set up crontab for wp-cron.
* `opsworks_wordpress::deploy` - Download WordPress's latest version, set up NGINX site config, symlink wp-content from current deploy version of app to shared WordPress installation.

## License and Authors

Author: Richard Lee (rl@polydice.com)

License: Apache