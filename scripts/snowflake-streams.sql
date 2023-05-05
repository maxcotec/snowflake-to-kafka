use role ACCOUNTADMIN;    -- change this
use DATABASE DEV_DB;      -- change this
use schema SCRATCH;       -- change this


-- Create a small table. called source table from here onwards
CREATE OR REPLACE TABLE users (
    id int,
    first_name varchar(200),
    last_name varchar(200)
);

-- Create streams object against `users` table
CREATE OR REPLACE STREAM users_cdc_stream ON TABLE users;

-- Check if we have any deltas captures. Initially this will return `False`
SELECT SYSTEM$STREAM_HAS_DATA('users_cdc_stream');

-- insert rows into `users` table
insert into users (id,first_name,last_name)
values
(1,'Alice','Bob'),
(2,'Carol','Chuck'),
(3,'Craig','Dan');

-- Check for deltas again. This time, we should get `True`
SELECT SYSTEM$STREAM_HAS_DATA('users_cdc_stream');

-- Query stream object like a usual table
select * from users_cdc_stream;

-- offload deltas into s3 bucket using stage @S3_STORAGE_STAGE
-- If you have setted up s3 source kafka connector correctly, this should sent deltas to kafka topic
COPY INTO @S3_STORAGE_STAGE/users.json
 FROM (SELECT OBJECT_CONSTRUCT('id', id, 'first_name', first_name, 'last_name', last_name) FROM users_cdc_stream)
 FILE_FORMAT = (TYPE = JSON COMPRESSION = NONE)
SINGLE=TRUE
OVERWRITE=TRUE;

-- Check for deltas again. This time, we should get `False` because the stream has nothing new to report after we consumed recent captured deltas
SELECT SYSTEM$STREAM_HAS_DATA('users_cdc_stream');

-- Now lets add another row
insert into users (id,first_name,last_name)
values (4,'John','Blaze');

-- Query stream object like a usual table. This should return single record of the newly inserted row
select * from users_cdc_stream;

-- Check for deltas again. This time, you guessed it, its `True`
SELECT SYSTEM$STREAM_HAS_DATA('users_cdc_stream');

-- offload deltas into s3 bucket. Be sure to keep file names unique
COPY INTO @S3_STORAGE_STAGE/users_new.json
 FROM (SELECT OBJECT_CONSTRUCT('id', id, 'first_name', first_name, 'last_name', last_name) FROM users_cdc_stream)
 FILE_FORMAT = (TYPE = JSON COMPRESSION = NONE)
SINGLE=TRUE
OVERWRITE=TRUE;