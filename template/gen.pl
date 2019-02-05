#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

use Data::Dumper;

my @conf = (
	{
		type => 'rand',
		flavor => 'normal',
		qd => [qw( 4 16 64 256 512 1024 )],
		bs => [qw( 4k 8k 32k )],
		rw =>      [qw( randread randwrite randrw )],
		dir =>     [qw( r        w         rw     )],
		runtime => [qw( 1m      1m        1m     )]
	},
	{
		type => 'seq',
		flavor => 'normal',
		qd => [qw( 4 16 64 128 256 )],
		bs => [qw( 128k 1M )],
		rw =>      [qw( read write  )],
		dir =>     [qw( r        w  )],
		runtime => [qw( 1m      1m )]
	},
	{
		type => 'lat',
		flavor => 'normal',
		qd => [qw( 1 2 4 8 16 32 64 128 256 512 1024 2048 )],
		bs => [qw(4k 8k 32k)],
		rw =>      [qw( randread randwrite )],
		dir =>     [qw( r        w         )],
		runtime => [qw( 10s      1m        )],
	},
	{
		type => 'latpio',
		flavor => 'iops',
		qd => [qw( 64 )],
		bs => [qw(4k 8k 32k)],
		rw => 		 [qw( randread	randwrite   )],
		dir =>	     [qw( r			w		    )],
		runtime =>   [qw( 10s		1m			)],
		rate_iops => [qw( 5000 10000 15000 20000 25000 30000 35000 40000 45000 50000 55000 60000 65000 70000 75000 80000 85000 90000 95000 100000 )],
	}
);

my @variants = ();

for my $t ( @conf ) {
for my $qd ( @{$t->{qd}} ) {
for my $bs ( @{$t->{bs}} ) {
for my $rwi ( 0..$#{$t->{rw}} ){
	if ($t->{flavor} eq 'normal')
	{
		push
			@variants,
			{
				type => $t->{type},
				flavor => $t->{flavor},
				dir => $t->{dir}[$rwi],
				rw => $t->{rw}[$rwi],
				qd => $qd,
				bs => $bs,
				runtime => $t->{runtime}[$rwi],
			};
	}
	elsif ($t->{flavor} eq 'iops')
	{
		for my $iops ( @{$t->{rate_iops}} )
		{
			push
				@variants,
				{
					type => $t->{type},
					flavor => $t->{flavor},
					dir => $t->{dir}[$rwi],
					rw => $t->{rw}[$rwi],
					qd => $qd,
					bs => $bs,
					runtime => $t->{runtime}[$rwi],
					rate_iops => $iops,
				};
		}
	}
	else
	{
		die("Invalid flavor '$t->{flavor}' in the '$t->{type}' config\n");
	}
}}}}

sub gen_normal($)
{
	my ($v) = @_;
	my ($type, $dir, $rw, $qd, $bs, $runtime) = @$v{ qw(type dir rw qd bs runtime) };
	my $testname = "$type-$dir-$bs-$qd";

#	print "$testname\n";
	open my $f, '>', $testname or die "Could not (re)create $testname: $!\n";

	print $f
"[$testname]
ioengine=libaio
direct=1
sync=0
time_based
".
( ($type eq 'lat' or $type eq 'rand' ) ? "norandommap\nrandrepeat=0\n" : "" ).
"

rw=$rw
bs=$bs
iodepth=$qd
runtime=$runtime

";

	close $f;
}

sub gen_iops($)
{
	my ($v) = @_;
	my ($type, $dir, $rw, $qd, $bs, $runtime, $iops) = @$v{ qw(type dir rw qd bs runtime rate_iops) };
	my $testname = "$type-$dir-$bs-$qd-$iops";

	#	print "$testname\n";
	open my $f, '>', $testname or die;

	print $f
"[$testname]
ioengine=libaio
direct=1
sync=0
time_based
".
( ( $type eq 'latpio' ) ? "norandommap\nrandrepeat=0\n" : "" ).
"
rate_iops=$iops
rw=$rw
bs=$bs
iodepth=$qd
runtime=$runtime

";

close $f;
}

my %generators = (
	normal		=> \&gen_normal,
	iops		=> \&gen_iops,
);
for my $v (@variants)
{
	$generators{$v->{flavor}}->($v);
}
