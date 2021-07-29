

use Cwd;
my $currentPath = getcwd();


#$modelpath = `find $currentPath/dp_output/ -iname '*.pb' -type f`;
chdir("/opt/anaconda3/bin/"); #enter anaconda 
system("source activate");
chdir("$currentPath"); 
`rm -rf dp_output`;
`rm -rf lammps_test`;
$modelname = "300kMo"; #your model name
$interation = 4; #how much slurm you make?
$slurmbatch = "deep.slurm";
$json = "Mo.json"; 
@temperature = ("50","100","300","600","900");
@steps = ("200","600");

#$dftdatapath = "home/huaiting/Test_Modeep/data/300K0Gpa-bcc-Mo"; #dft ref data path 
#"systems":	["../data/4/"],"

`mkdir dp_output`;

for(0..$interation)
{
    system("mkdir -p dp_output/$_");
    `sed -i '/#SBATCH.*--job-name/d' $slurmbatch`;
	`sed -i '/#sed_anchor01/a #SBATCH --job-name=deep$_' $slurmbatch`;
	
	`sed -i '/#SBATCH.*--output/d' $slurmbatch`;
	`sed -i '/#sed_anchor01/a #SBATCH --output=deep$_.out' $slurmbatch`;

	`sed -i '/dp.*/d' $slurmbatch`;
	`sed -i '/#sed_anchor02/a dp train Mo.json' $slurmbatch`;
	`sed -i '/#sed_anchor03/a dp freeze -o $modelname$_.pb' $slurmbatch`;
    `cp  $slurmbatch dp_output/$_/`;
    `cp  Mo.json dp_output/$_/`;
    chdir("$currentPath/dp_output/$_/");
	system("sbatch $slurmbatch");
	chdir("$currentPath");
   # sleep(1);
}


my $running = `squeue -o \%j | awk 'NR!=1'`;
my @running = split("\n",$running);

$modelpath=`find $currentPath/dp_output/ -name "*.pb"`;
@modelpath = split("\n", $modelpath);
do
{
    print "running......\n";
    sleep(1000);
    $running = `squeue`;

   print $running;
}until(-e "$currentPath/dp_output/0/300kMo0.pb" && "$currentPath/dp_output/1/300kMo01.pb" && "$currentPath/dp_output/2/300kMo02.pb" && "$currentPath/dp_output/3/300kMo03.pb" && "$currentPath/dp_output/4/300kMo04.pb");

sleep(10);

     $modelpath=`find $currentPath/dp_output/ -name "*.pb"`;
     @modelpath = split("\n", $modelpath);
for $temperature (@temperature)
{
	for $steps(@steps)
	{
	  system("mkdir -p lammps_test/$temperature\k/$steps");

     for(@modelpath){`cp $_  lammps_test/$temperature\k/$steps`;}
	 `cp NPT.in lammps_test/$temperature\k/$steps`;
	 `cp OPT-Mo.data lammps_test/$temperature\k/$steps`;
	 `cp deep.slurm lammps_test/$temperature\k/$steps`;
	 `cp elastic.in init.mod potential.mod displace.mod lammps_test/$temperature\k/$steps`;
	

        system("sed -i 's/velocity all create 300 12345 mom yes rot yes dist gaussian/velocity all create $temperature 12345 mom yes rot yes dist gaussian/' lammps_test/$temperature\k/$steps/NPT.in");
        system("sed -i 's/velocity all scale 300/velocity all scale $temperature/' lammps_test/$temperature\k/$steps/NPT.in");
        system("sed -i 's/fix 1 all npt temp 300 300 0.1 aniso 0.0 0.0 1.0/fix 1 all npt temp $temperature $temperature 0.1 aniso 0.0 0.0 1.0/' lammps_test/$temperature\k/$steps/NPT.in");
	    #system("sed -i 's/run  			100 every 10 'write_data npt_*.data nocoeff'/run  			$steps every 10 'write_data npt_*.data nocoeff'/' lammps_test/$temperature\k/$steps/NPT.in");
        
        `sed -i '/#SBATCH.*--job-name/d' lammps_test/$temperature\k/$steps/deep.slurm`;
	    `sed -i '/#sed_anchor01/a #SBATCH --job-name=lmp$temperature\k$steps\steps' lammps_test/$temperature\k/$steps/deep.slurm`;
	
	    `sed -i '/#SBATCH.*--output/d' lammps_test/$temperature\k/$steps/deep.slurm`;
	    `sed -i '/#sed_anchor01/a #SBATCH --output=$temperature\k$steps.sout' lammps_test/$temperature\k/$steps/deep.slurm`;
	
        `sed -i '/dp.*/d' lammps_test/$temperature\k/$steps/deep.slurm`;
        `sed -i '/#sed_anchor02/a lmp -in NPT.in' lammps_test/$temperature\k/$steps/deep.slurm`;

		 chdir("lammps_test/$temperature\k/$steps");
		 #print "$currentPath$lammps_test/$temperature\k/$steps/";
		 #print "\n";
        system("sbatch deep.slurm");
        chdir("$currentPath");
	}
}


##selse{print "no";}
# }
# `mkdir lammps_test`;
#
#
#
##while(-e @running)
##{
##	#print $running;
##	unless(-e @modelpath)
##	{
##       print @running;
##	}
##	last;
##}
##`mkdir lammps_test`;
#
##
##until(-e $modelpath)
##{
##    #print @running;
##    last  if (-e $modelpath);
##}
#
#
##do
##{
##   my $running = `squeue -o \%j | awk 'NR!=1'`;
##   #$squeue = `squeue`;
##   my @running = split("\n",$running);
##   #print "$squeue\n";
##   print $running;
## # last ;
##
##   
##
##
##}until(-e $modelpath);
##`mkdir lammps_test`;
