mysql-backup-script
===================

I've been using variants of this MySQL backup script for ~13 years on databases large and small.  
I should have open sourced this a decade ago.

This will back up some database, optionally ignore certain 
tables, compress the backup file as it's being dumped (to 
minimize i/o) and upload the resultant file to Amazon S3.  
This does the backup using --single-transaction which 
will minimize locking if your tables are InnoDB.  If not, 
you will definitely seem some myisam tables being locked.

If you're using triggers and the like, you should adjust 
the args to mysqldump if you want those included.

You should install s3cmd if you want to do that.  

This, admittedly, is a bit of a hack, but I've been using 
it for so long that I've grown to trust it.  Run it out 
of crontab.  It doesn't try to do anything smart.  If
it fails, it'll just fail and make some noise.

