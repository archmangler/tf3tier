#!/usr/bin/perl
#A simple PoC perl script to implement unit tests addressing known deployment concerns/policies for Terraform infrastructure
#The concept is to analyse the terraform plan output and test for certain patterns, passing or failing the plan as configured
#There are more complete testing frameworks emerging for this which could used instead, e.g:
#OPA (open policy agent, awspec, kitchen-terraform.
#However my personal view is to develop light test frameworks in house instead.
#Traiano Welcome (traiano@gmail.com)
#
#Currently only one test implemented:
#If more than a threshold of resources must be destroyed (or forced created) to execute the plan, test fails. This could
#be part of a policy to implement measures of "blast radius" for estimating potential change impact.
my $debug=0;
#Pass the terraform plan file 
#as argument to this script
my $plan_file=shift;

#We use a has to hold the test configuration thresholds, but this could easily be moved to a configuration file
#blast_radius: "number of new forced resources that are allowed to be created in order to effect the change"
#Setting blast_radius=0 means we can't tolerate any new forced resources or resource destruction
my %thresholds={ "blast_radius" => "0"};

#Final map of test results
my %test_results={"blast_radius" => "NULL"};

#array to store plan lines
my @plan = ();

run_plan();
check_blast_radius();
report_results();

#retrieve the plan
sub run_plan{
 print "Testing plan from $plan_file ...\n";
 open(CMD,"terraform show $plan_file |") or die "FAIL! Cannot run plan using $plan_file\n";
 while(<CMD>){
  chomp($_);
  if($debug==1){
   print "analysing> $_\n";
  }
  push(@plan,$_);
 }
 close(CMD);
}

#Check the blast radius impact
sub check_blast_radius{
 my $blast_count=0;
 my $result="NULL";
 print "Checking blast radius (check_blast_radius) ...\n";
 foreach my $line (@plan){
  if($line=~/forces new resource/){
   $blast_count++;
   if($debug==1){ print "(debug) MATCH: $line\n"; }
  }
  if($debug==1){
    print "(debug) CHECKING: $line\n";
  }
 }
 #check against thresholds
 if($blast_count > $thresholds{"blast_radius"}){
  $result="FAIL"; 
 }else{
  $result="PASS"; 
 }
 $test_results{"blast_radius"}=$result;
}

sub report_results
{
 #summarise the test results
 foreach my $test (keys(%test_results)){
  print "TEST: $test RESULT: $test_results{$test}\n";
 }
}
