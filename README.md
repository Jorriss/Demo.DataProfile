# Demo.DataProfile
This project are the demos to the The Quest to Find Bad Data with Data Profiling presentation. For more information on the presentation go to http://www.jorriss.net/blog/dataprofilequest.

## What's In Here
There are two projects and one SQL Script:

* SSISDataProfile - This is a SSIS project that demonstrates the usage of the Data Profile Task. I uses the StackOverflow databse.
* RegExSearch - This project shows how you can use the SQL CLR in order to use RegEx in your SQL queries.
* DataProfilingDemo.sql - This SQL script demonstrates how you can use SQL to perform some data profiling techniques.

## Databases
* StackOverflow - You have to download the data dump at https://archive.org/details/stackexchange. You can write a tool to import the data yourself or you could use the SODDI tool (StackOverflow Data Dump Importer) Jeremiah Peschka has been maintaing a version of SODDI at https://github.com/peschkaj/soddi. Once installed you can run the `StackOverflow FullText.sql` script which will install a Full-Text index on the StackOverflow database.

## sp_DataProfile
sp_DataProfile is the stored procedure that will simplify your data profiling tasks. You can get sp_DataProfile at http://www.jorriss.net/blog/sp_dataprofile.
