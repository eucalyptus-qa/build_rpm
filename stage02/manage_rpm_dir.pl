#!/usr/bin/perl
use strict;
use Cwd;

$ENV{'PWD'} = getcwd();
$ENV{'RPM_STORAGE'} = "/home/test-server/rpm_storage";

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
my @version_lst;
my @arch_lst;
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

my $bzr_dir = "";
my $arch = "";
my $rev = "";

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
		push( @version_lst, $3 );
		push( @arch_lst, $4 );
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
        }elsif( $line =~ /^BZR_BRANCH\s+(.+)/ ){
		$line = $1;
		if( $line =~ /\/eucalyptus\/(.+)/){
			$bzr_dir = $1;
		};
	}elsif( $line =~ /^BZR_REVISION\s+(.+)/ ){
		$rev = $1;
	};

};

close( LIST );


if( $bzr_dir eq "" ){
	print "ERROR !! BZR_DIR unknown !!\n";
	exit(1);
};


if( $arch eq "" ){
	print "ERROR !! ARCH unknown !!\n";
	exit(1);
};

my $failed = 0;

for( my $i = 0; $i < @ip_lst; $i++ ){
	my $this_ip = $ip_lst[$i];
	my $this_distro = $distro_lst[$i];
	my $this_version = $version_lst[$i];
	my $this_arch = $arch_lst[$i];
	my $this_source = $source_lst[$i];
	my $this_roll = $roll_lst[$i];
	my $stripped_roll = strip_num($this_roll);	

	if( $this_source eq "PKGBUILD" ){
		
		$this_distro = lc($this_distro);

		my $rpm_dir = $ENV{'RPM_STORAGE'} . "/" . $this_distro . "_" . $this_arch;

		my $new_dir = "RPMS_" . $bzr_dir. "_" . $rev;		

		if( -e "$rpm_dir/$new_dir" ){
			if( -e "$rpm_dir/RPMS" ){
				system("rm -fr $rpm_dir/RPMS");
			};
			system("ln -sf $rpm_dir/$new_dir $rpm_dir/RPMS");
			print "$this_ip : $rpm_dir/$new_dir --> $rpm_dir/RPMS\n";

		}else{
			print "$this_ip : $rpm_dir/$new_dir does NOT exists !!\n";
			$failed = 1;
		};

	};
};

exit($failed);


1;


sub strip_num{
        my ($str) = @_;
        $str =~ s/\d//g;
        return $str;
};




