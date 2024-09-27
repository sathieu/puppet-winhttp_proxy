# winhttp_proxy

> ⚠️ This repository is not maintained ⚠️
>
> ⚠️ You can go to this fork: [webalexeu/puppet-winhttp_proxy](https://github.com/webalexeu/puppet-winhttp_proxy) ⚠️

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with winhttp_proxy](#setup)
    * [What winhttp_proxy affects](#what-winhttp_proxy-affects)
    * [Setup requirements](#setup-requirements)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Manage Windows system proxy (i.e. WinHTTP Proxy, not the Internet Explorer one).

## Module Description

This module use netsh command to change the Windows system proxy settings.

## Setup

### What winhttp_proxy affects

This module changes the "netsh winhttp proxy" context.

For more info, read [M$ docs](http://technet.microsoft.com/en-us/library/cc731131#BKMK_5)

###Setup Requirements

Winhttp_proxy uses Ruby-based providers, so you must enable [pluginsync enabled](http://docs.puppetlabs.com/guides/plugins_in_modules.html#enabling-pluginsync).

## Reference

### `winhttp_proxy`

Examples :

```puppet
winhttp_proxy { 'proxy':
  proxy_server => 'proxy',
  bypass_list  => '<local>'
}

winhttp_proxy { 'proxy':
  proxy_server => 'http=proxy.example.com;https=proxy.example.org',
  bypass_list  => '<local>;*.example.org;*.example.com'
}
```

## Limitations

Requires Windows >= 7 or Windows >= 2008 (netsh provider).

## Development

As any github project, you can [read the source](https://github.com/sathieu/puppet-winhttp_proxy/),
fork and report issues.

[![Build Status](https://travis-ci.org/sathieu/puppet-winhttp_proxy.png?branch=master)](https://travis-ci.org/sathieu/puppet-winhttp_proxy)
