#ioschedset

Commandline tools to query and/or set the I/O schedulers for block devices on Linux systems.


The Tools
=========


Querying Current I/O Schedulers
-------------------------------

The provided **io-get-sched** tool will query the current I/O scheduler assigned to each block device.

Running with no args will print out a list of all block devices and their scheduler.

For example:


	[user@hostname ~]$ io-get-sched 
	sda:	bfq
	sdb:	deadline
	sr0:	bfq


You can also specify one or more block device names and it will only list those specifically.

For example:

	[user@hostname ~]$ io-get-sched sdb
	sdb:	deadline


Modifying A Block Device's I/O Scheduler
----------------------------------------

The provided **io-set-sched** tool will assign a given I/O scheduler to all or specific block devices.

It requires at least 1 argument: the I/O scheduler name.

You can get a list of available options eiter by running with \-\-help or \-\-list.

For example:

	[user@hostname ~]$ io-set-sched --list
	mq-deadline kyber bfq none

So in this instance, the system has "mq-deadline", "kyber", "bfq", and "none" (no-op) available.

*While querying the current I/O scheduler for block devices or available schedulers does not require root, actually changing the I/O scheduler used for a block device **does** require root.*

*So io-set-sched will attempt to sudo as root before adjusting the I/O scheduler on block devices.*


You can set the same I/O scheduler for all devices via:

	[user@hostname ~]$ io-set-sched kyber
	Must be root to set IO Scheduler. Rerunning under sudo...
	
	+ Successfully set sda to 'kyber'!
	+ Successfully set sdb to 'kyber'!
	+ Successfully set sr0 to 'kyber'!


Or you can set individual block devices by providing them as arguments after the scheduler name:

	[user@hostname ~]$ io-set-sched kyber sda sr0
	Must be root to set IO Scheduler. Rerunning under sudo...
	
	+ Successfully set sda to 'kyber'!
	+ Successfully set sr0 to 'kyber'!


Installation
============

Installation instructions follow below.


Manual Install
--------------

This distribution comes with a script, "install.sh" which takes into consideration the environment variables PREFIX and DESTDIR.

You can also specify these as arguments, for example:

    ./install.sh DESTDIR="${pkgdir}"

is treated the same as:

    DESTDIR="${pkgdir}" ./install.sh

See \`./install.sh --help' for more info.

The two files [io-set-sched and io-get-sched] will be installed into ${DESTDIR}/${PREFIX}/bin (/usr/bin by default) and ready to roll.

The tools are written in bash and have no external dependencies.


Arch Linux
----------

For installation under Arch Linux, there are two options.

The first option is the 'official' releases, which are available via AUR: https://aur.archlinux.org/packages/ioschedset

The second alternative option is suitable for local installs - the git project contains a PKGBUILD file which works from the git directory rather than from a source tarball.


**From AUR (official package)**


1. Download and extract the tarball from https://aur.archlinux.org/cgit/aur.git/snapshot/ioschedset.tar.gz

2. cd into *'ioschedset'* directory

3. Run *\`makepkg'* as your normal user (non-root)

4. Install the package:

	pacman -U ioschedset-*.pkg.tar.*


**From local PKGBUILD**


1. Either download a release from https://github.com/kata198/ioschedset/releases or use git to clone https://github.com/kata198/ioschedset . If you use git, there are tags for each official release which matches the version number (git tag -l to list tags, git branch -l to list branches). "master" should always match the latest official release.

2. Navigate into the *'ioschedset'* directory

3. Run *\`makepkg'* as your normal user (non-root)

4. Install the package:

	pacman -U ioschedset-*.pkg.tar.*


