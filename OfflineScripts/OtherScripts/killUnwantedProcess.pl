#!/usr/bin/perl
# Script reads the output of ps -aux to identify unwanted process and kills them
use POSIX qw/strftime/;
my @blacklisted_process_name = ["[.ECC6DFE919A382]"];
my @process_list;
open(command_line, "ps aux|");
my $log_filename ="/home/ubuntu/log/killunwantedprocess.log";
#my $log_filename ="/Users/ViswaMani/log/killunwantedprocess.log";
open(my $log_file, ">>", $log_filename) or die "Cant open log file";
foreach $line ( <command_line> ) {
    chomp( $line );
    @cols = split(/\s+/, $line);
    # check if the process name is matching any of the blacklisted process names
    if ($cols[10] ~~ @blacklisted_process_name) {
        system("sudo kill -9 $cols[1]");
        $time = strftime("%F %T", localtime $^T);
        say $log_file "killing pid: $cols[1] name: $cols[11] at $time";
    }
    push(@process_list, $cols[10]);
}
close(command_line);
$time = strftime("%F %T", localtime $^T);
$echo_string = sprintf("process list: %s",join(";", @process_list));
say $log_file "$echo_string at $time";