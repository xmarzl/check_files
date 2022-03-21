#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;

# -- Global Vars
my $verbose = 0;

my $file_regex = '';
my $file_age_warning = 300; # --- 5 minutes
my $file_age_critical = 600; # --- 10 minutes

my $path_storage = '';

my %error = (
  'ok'       => 0,
  'warning'  => 1,
  'critical' => 2,
  'unknown'  => 3
);

# -- Subs
sub help() {
  print '-s --storage'."\n";
  print '-w --warning'."\n";
  print '-c --critical'."\n";
  print '-h --help'."\n";
  print '-v --verbose'."\n";
  print '-rx --regex'."\n";
  print 'perl check_files.pl -s <storage> [-w <warning>] [-c <age_critical>] [-v]'."\n";
  print 'i.e.: ./check_files.pl -s "/opt/example/backups" -rx "\\.bkp" -w 400 -c 1000 -v'."\n";
}

sub verbose($) {
  my $f_message = shift;
  print 'verbose: '.$f_message."\n" if($verbose);
}

# -- GetOptions -> init
&GetOptions(
  's|storage=s' => \$path_storage,
  'rx|regex:s' => \$file_regex,
  'w|warning:i' => \$file_age_warning,
  'c|critical:i' => \$file_age_critical,
  'h|help!' => sub { &help() },
  'v|verbose!' => \$verbose
);

# --- Verbose GetOptions
&verbose('Storage: "'.$path_storage.'"');
&verbose('regex: "'.$file_regex.'"');
&verbose('warning: "'.$file_age_warning.'"');
&verbose('critical: "'.$file_age_critical.'"');
&verbose('verbose: "'.$verbose.'"');
&verbose('');

# - Script start
&verbose('Script start');

# -- Errorcheck
# --- Check not defined
if($path_storage eq '') {
  print 'Storage not defined'."\n";
  exit($error{'unknown'});
}

# --- Check directory not exists
elsif(not -e $path_storage) {
  print 'Storage "'.$path_storage.'" does not exist.'."\n";
  exit($error{'critical'});
}

# --- Check "directory" not a directory
elsif(not -d $path_storage) {
  print 'Storage "'.$path_storage.'" is not a directory.'."\n";
  exit($error{'unknown'});
}

&verbose('Opening directory: "'.$path_storage.'"');

# -- Check if directory can't be opened
my $path_storage_directory;
if(not opendir $path_storage_directory, $path_storage) {
    print 'Storage "'.$path_storage.'" can\'t be opened.'."\n";
    exit($error{'unknown'});
}

# -- Successfully opened $path_storage_directory
&verbose('Directory successfully opened!');

# -- Getting files / file amount - but no directories (not -d)
my @path_storage_files = grep { not -d $path_storage.'/'.$_ } readdir($path_storage_directory);

# --- Verbose all files found
&verbose('Found files (no RegEx): ['.join(',', @path_storage_files).']');

# -- Close directory
closedir $path_storage_directory;

# -- Grep all files matching the pattern
@path_storage_files = grep { $_ =~ /$file_regex/ } @path_storage_files;

# --- Verbose all greped files
&verbose('Found files (RegEx): ['.join(',', @path_storage_files).']');

# -- Checking if storage empty
my $path_storage_files_size = @path_storage_files;
if($path_storage_files_size <= 0) {
  print 'Storage "'.$path_storage.'" does not contain a file matching the pattern "'.$file_regex.'"'."\n";
  exit($error{'critical'});
}

# -- Give response how many files were found
print 'Found '.$path_storage_files_size.' files.'."\n";
my $file_newest = '';
my $file_newest_lastmodified = 0;

# -- searching newest file
for my $file(@path_storage_files) {
    my $file_lastmodified = (stat $path_storage.'/'.$file)[9];
    if($file_lastmodified > $file_newest_lastmodified){
      $file_newest = $file;
      $file_newest_lastmodified = $file_lastmodified;
    }
}

my $file_newest_age = (time - $file_newest_lastmodified);
print 'Newest file: '.$file_newest."\n";
print 'Age: '.$file_newest_age."\n";

# -- File is too old = CRITICAL
if($file_newest_age >= $file_age_critical){
  &verbose('Critical: File age! File older than '.$file_age_critical.' seconds');
  exit($error{'critical'});
}

# -- File is too old = WARNING
elsif($file_newest_age >= $file_age_warning){
  &verbose('Warning: File age! File older than '.$file_age_warning.' seconds');
  exit($error{'warning'});
}

# -- File is not too old = OK
&verbose('End script - Everything fine!');
exit($error{'ok'});
