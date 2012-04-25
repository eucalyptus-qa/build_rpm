#!/usr/bin/perl
use strict;
use Cwd;

$ENV{'PWD'} = getcwd();

# does_It_Have( $arg1, $arg2 )
# does the string $arg1 have $arg2 in it ??
sub does_It_Have{
	my ($string, $target) = @_;
	if( $string =~ /$target/ ){
		return 1;
	};
	return 0;
};



#################### APP SPECIFIC PACKAGES INSTALLATION ##########################

my @ip_lst;
my @distro_lst;
my @source_lst;
my @roll_lst;

my %cc_lst;
my %sc_lst;
my %nc_lst;

my $clc_index = -1;
my $cc_index = -1;
my $sc_index = -1;
my $ws_index = -1;

my $clc_ip = "";
my $cc_ip = "";
my $sc_ip = "";
my $ws_ip = "";

my $nc_ip = "";

my $max_cc_num = 0;

$ENV{'EUCALYPTUS'} = "/opt/eucalyptus";


my $extra_ops = "";

if( @ARGV > 0 ){
	$extra_ops = shift @ARGV;
};



#### read the input list

my $index = 0;

open( LIST, "../input/2b_tested.lst" ) or die "$!";
my $line;
while( $line = <LIST> ){
	chomp($line);
	if( $line =~ /^([\d\.]+)\t(.+)\t(.+)\t(\d+)\t(.+)\t\[([\w\s\d]+)\]/ ){
		print "IP $1 with $2 distro will be built from $5 as Eucalyptus-$6\n";
		push( @ip_lst, $1 );
		push( @distro_lst, $2 );
		push( @source_lst, $5 );
		push( @roll_lst, $6 );

		my $this_roll = $6;

		if( does_It_Have($this_roll, "CLC") ){
			$clc_index = $index;
			$clc_ip = $1;
		};

		if( does_It_Have($this_roll, "CC") ){
			$cc_index = $index;
			$cc_ip = $1;

			if( $this_roll =~ /CC(\d+)/ ){
				$cc_lst{"CC_$1"} = $cc_ip;
				if( $1 > $max_cc_num ){
					$max_cc_num = $1;
				};
			};			
		};

		if( does_It_Have($this_roll, "SC") ){
			$sc_index = $index;
			$sc_ip = $1;

			if( $this_roll =~ /SC(\d+)/ ){
                                $sc_lst{"SC_$1"} = $sc_ip;
                        };
		};

		if( does_It_Have($this_roll, "WS") ){
                        $ws_index = $index;
                        $ws_ip = $1;
                };

		if( does_It_Have($this_roll, "NC") ){
			$nc_ip = $1;
			if( $this_roll =~ /NC(\d+)/ ){
				if( $nc_lst{"NC_$1"} eq	 "" ){
                                	$nc_lst{"NC_$1"} = $nc_ip;
				}else{
					$nc_lst{"NC_$1"} = $nc_lst{"NC_$1"} . " " . $nc_ip;
				};
                        };
                };

		$index++;
        };
};

close( LIST );


for( my $i = 0; $i < @ip_lst; $i++ ){
	my $this_ip = $ip_lst[$i];
	my $this_distro = $distro_lst[$i];
	my $this_source = $source_lst[$i];
	my $this_roll = $roll_lst[$i];
	my $stripped_roll = strip_num($this_roll);	
	print "$this_ip : Running /root/euca_builder/auto_rpm_builder.pl\n"; 
#	system("ssh -o StrictHostKeyChecking=no root\@$this_ip \"cd /root/euca_builder; perl ./auto_rpm_builder.pl \" ");
	system("ssh -o StrictHostKeyChecking=no root\@$this_ip \"cd /root/euca_builder; perl ./auto_pkg_builder.pl \" ");
};

exit(0);


1;


sub strip_num{
        my ($str) = @_;
        $str =~ s/\d//g;
        return $str;
};




