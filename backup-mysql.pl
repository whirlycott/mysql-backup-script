#!/usr/bin/perl -w

# MySQL Database Backup Script
# Licensed under ASF 2.0 (see LICENSE file)
# Copyright 1999 - 2012 Philip Jacob <phil@whirlycott.com>

use strict;
use vars qw($HOSTNAME $USERNAME $PASSWORD @db);

###########################################
#CONFIGURATION

# Dbs you want to back up.
my @db = qw(
            db_name_here
            wordpress
            another_db_name_here
	    );

# Tables you want to ignore.  
my @ignores = qw("");
my $prefix=" ";
my %opts = ('' => $prefix.join($prefix, @ignores));

# Pass these in on the command line in the order they appear in this list assignment.
my ($HOSTNAME, $USERNAME, $PASSWORD) = @ARGV;

unless ($HOSTNAME && $USERNAME && $PASSWORD) {
  print ("Usage: $0 hostname username password\n");
  exit 1;
}

# I usually run this under a user called 'mybackups'.
my $ZIP_PROGRAM = "/bin/gzip";
my $ZIP_SUFFIX = "gz";
my $BAK_DIR = "/home/mybackups/mysql_bak";
my $S3_BUCKET = "s3://yourcompany.mysql.backups/";

###########################################
#END CONFIGURATION

foreach my $database (@db) {

    #Get a timestamp value.
    my ($timestamp) = &gettime;
    
    #Get a standard filename for this file.
    my ($filename) = "$HOSTNAME.mysql." . $database . "." . $timestamp . ".sql";

    #Dump the db.
    &dbdump($filename, $database);

    #Symlink -latest
    `ln -sf $BAK_DIR/$filename.$ZIP_SUFFIX $BAK_DIR/$HOSTNAME.mysql.$database-latest.sql.$ZIP_SUFFIX`;

    #Send backup to s3
    `s3cmd put $BAK_DIR/$filename.$ZIP_SUFFIX $S3_BUCKET`;
}
  
##############SUBROUTINES

sub dbdump {
  my ($filename, $db) = @_;
  my $command;

  if (defined($opts{$db})) {
      $command = "/usr/bin/mysqldump --single-transaction -q -h$HOSTNAME -u$USERNAME -p$PASSWORD ".$opts{$db}." $db | $ZIP_PROGRAM > $BAK_DIR/$filename.$ZIP_SUFFIX; /bin/chmod 440 $BAK_DIR/$filename.$ZIP_SUFFIX";
  } else {
      $command = "/usr/bin/mysqldump --single-transaction -q -h$HOSTNAME -u$USERNAME -p$PASSWORD $db | $ZIP_PROGRAM > $BAK_DIR/$filename.$ZIP_SUFFIX; /bin/chmod 440 $BAK_DIR/$filename.$ZIP_SUFFIX";
  }
  system ($command);
  #print $command, "\n";
}


sub gettime {
  my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime;
  $year = 1900 + $year;
  my $monn = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")[$mon];
  my $wdayn = ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")[$wday];
  my $filename = $year . "_" . $monn . "_" . sprintf("%02d",$mday) . "_" . $wdayn . "_" . $hour . "_" . $min . "_" . $sec;
  return $filename;
}
