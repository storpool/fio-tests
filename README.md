The StorPool FIO Test Suite
===========================

This is a description of the disk test suite found in
the `/usr/share/doc/storpool/examples/fio/` directory of
a StorPool installation.

Overview
--------

The test suite consists of template configurations for the fio tool and
several tools to run tests.  The `run_quick` tool may be used to
run a predefined set of tests on a single disk or volume, the `run_one`
tool only runs a single test, the `get_res` tool examines the `res/`
directory populated by the `run_*` ones and displays the results as
a series of lines containing comma-separated values, and
the `pretty_print` tool outputs these CSV lines in a human-readable
format.

Prerequisites
-------------

The StorPool fio test suite expects that the `fio` tool is installed,
along with a Perl interpreter and the `Data::Dumper` and `JSON::XS`
Perl modules.  To check whether they are installed, run the following
commands:

    # which fio
    # perl -MData::Dumper -MJSON::XS -e 'print "OK\n"'
	
On RedHat-derived distributions, run the following commands as root
to make sure that these prerequisites are installed:

    # yum install epel-release
    # yum install --enablerepo=epel fio perl-autodie perl-Data-Dumper perl-JSON-XS

On Debian-derived systems, run the following command as root:

    # apt-get install fio libjson-xs-perl

Quick Start: the `run_quick` tool
---------------------------------

To run a suite of predefined tests on a single disk or volume, use
the `run_quick` tool and pass it a single parameter: the path to
the block device:

    # ./run_quick /dev/storpool/test-volume

When testing the performance of volumes in a StorPool cluster, create
the volume and attach it to this host beforehand:

    # storpool volume test-volume create template hybrid size 60G
    # storpool attach volume test-volume here

The `run_quick` tool will run the tests listed in the `tests` file;
currently this includes:

- rand-w-4k-64
- fill
- lat-r-4k-1
- seq-r-1M-64
- rand-r-4k-64
- seq-w-1M-64
- lat-w-4k-1
- rand-rw-4k-64

It will then use the `get_res` and `pretty_print` tools to output
some information about the test results in a human-readable format.

Run tests one by one: the `run_one` tool
----------------------------------------

To run a single test, use the `run_one` tool and pass it the name of
the test and the path to the block device to run the test on:

    # ./run_one seq-r-1M-64 /dev/storpool/test-volume

The `get_res` and `pretty_print` tools may be then used to output
the results:

    # ./get_res
    # ./get_res | ./pretty_print

To see what the `fio` tool would do without actually running the test,
run `fio` with the `--showcmd` option, also passing it the test template
name as a job name:

    # fio --showcmd template/rand-r-8k-64

Test template names
-------------------

The `get_res` tool extracts some information from the test results
depending on the template name, e.g. throughput information for tests
named `seq-r-*` and `seq-w-*`, I/O operations per second information for
tests named `rand-r-*`, etc.  The template names are expected to
consist of several components:

- test type: `seq` for sequential read/writes, `rand` for random
  read/writes, `lat` for I/O latency tests, `latpio` for combined I/O
  latency and I/O operations per second output
- I/O operation direction: `r` for reads, `w` for writes, `rw` for both
- I/O operation block size: `4k`, `8k`, `1M`, etc.
- queue depth (see the `fio` tool documentation): 1, 2, 16, 512, etc.

Writing your own test templates
-------------------------------

There are two main rules for writing your own templates: adhere to
the naming convention described above, and use any `fio` options except
ones governing the output format and the disk device to test.  Other
than that, the test template is a standard `fio` job definition.
